module CaseSummaryPdfs::General::DataPointer
  PREVIOUS_AWARDS = { "innovation" => "Innovation",
                      "international_trade" => "International Trade",
                      "sustainable_development" => "Sustainable Development" }

  POSSIBLE_RAGS = {
    negative: "Red",
    average: "Amber",
    positive: "Green"
  }

  def undefined_value
    FeedbackPdfs::Pointer::UNDEFINED_VALUE
  end

  # EMPLOYEES BLOCK BEGIN

  def employees_question
    all_questions.detect do |q|
      q.delegate_obj.is_a?(QAEFormBuilder::ByYearsQuestion) &&
      q.employees_question.present?
    end
  end

  def employees_question_active_fields
    employees_question.decorate(answers: filled_answers).active_fields
  end

  def employees_by_years
    res = employees_question_active_fields.map do |field|
      employees_year_entry(field)
    end.compact

    res.present? ? res.map(&:to_s).max : undefined_value
  end

  def employees_year_entry(field)
    entry = filled_answers.detect do |k, _v|
      k == "#{employees_question.key}_#{field}"
    end

    entry[1] if entry.present?
  end

  def employees
    if employees_question.present?
      employees_by_years
    else
      undefined_value
    end
  end

  # EMPLOYEES BLOCK END

  def sic_code
    form_answer.sic_code || undefined_value
  end

  def current_awards_question
    all_questions.detect do |q|
      q.delegate_obj.is_a?(QAEFormBuilder::QueenAwardHolderQuestion)
    end
  end

  def current_awards
    if current_awards_question.present?
      answer = filled_answers[current_awards_question.key.to_s]

      if answer.present?
        res = answer.map do |item|
          if item["category"].present? && item["year"].present?
            "#{item["year"]} - #{PREVIOUS_AWARDS[item["category"].to_s]}"
          end
        end.compact

        res.present? ? res.join(", ") : undefined_value
      else
        undefined_value
      end
    else
      undefined_value
    end
  end

  def application_background_table_items
    [
      [
        "Application background",
        data["application_background_section_desc"]
      ]
    ]
  end

  def case_summaries_table_headers
    [
      [
        "Case summary comments",
        "RAG"
      ]
    ]
  end

  def case_summaries_entries
    AppraisalForm.struct(form_answer).map do |key, value|
      [
        value[:label].gsub(":", ""),
        data["#{key}_desc"] || undefined_value,
        data["#{key}_rate"].present? ? POSSIBLE_RAGS[data["#{key}_rate"].to_sym] : undefined_value
      ]
    end
  end

  def render_data!
    pdf_doc.move_down 50.mm
    render_application_background

    pdf_doc.move_down 10.mm
    render_case_summary_comments

    if financial_pointer.present? && !financial_pointer.period_length.zero?
      pdf_doc.move_down 10.mm
      render_financial_table
    end
  end

  def render_application_background
    render_table(application_background_table_items, {
      0 => 100,
      1 => 667
    })
  end

  def render_case_summary_comments
    render_case_summaries_header
    render_items
  end

  def render_case_summaries_header
    pdf_doc.table case_summaries_table_headers, row_colors: %w(FFFFFF),
                                                cell_style: { size: 12, font_style: :bold },
                                                column_widths: {
                                                  0 => 667,
                                                  1 => 100
                                                }
  end

  def render_items
    pdf_doc.table(case_summaries_entries,
                  cell_style: { size: 12 },
                  column_widths: {
                    0 => 100,
                    1 => 567,
                    2 => 100
                  }) do

      values = cells.columns(2).rows(0..-1)
      green_rags = values.filter do |cell|
        cell.content.to_s.strip == "Green"
      end
      green_rags.background_color = "6B8E23"

      amber_rags = values.filter do |cell|
        cell.content.to_s.strip == "Amber"
      end
      amber_rags.background_color = "DAA520"

      red_rags = values.filter do |cell|
        cell.content.to_s.strip == "Red"
      end
      red_rags.background_color = "FF0000"
    end
  end

  def render_financial_table
    render_financial_section_header
    render_financial_table_header
    render_financials
    render_financial_benchmarks
  end

  def render_financial_section_header
    pdf_doc.text "Financial Summary", header_text_properties
    pdf_doc.move_down 5.mm
  end

  def render_financial_table_header
    pdf_doc.table [year_rows], row_colors: %w(FFFFFF),
                  cell_style: { size: 12, font_style: :bold },
                  column_widths: column_widths
  end

  def render_financials
    rows = [date_rows]

    financial_metrics_by_years.map do |row|
      rows << row
    end

    pdf_doc.table(rows,
      cell_style: { size: 12 },
      column_widths: column_widths
    )
  end

  def column_widths
    first_row_width = case financial_pointer.period_length
    when 2
      first_row_width = 607
    when 3
      first_row_width = 527
    when 5
      first_row_width = 367
    when 6
      first_row_width = 287
    end

    res = { 0 => first_row_width }

    financial_pointer.period_length.times do |i|
      res[i + 1] = 80
    end

    res
  end

  def benchmarks_column_widths
    first_row_width = case financial_pointer.period_length
    when 2
      {
        0 => 607,
        1 => 160
      }
    when 3
      {
        0 => 527,
        1 => 240
      }
    when 5
      {
        0 => 367,
        1 => 400
      }
    when 6
      {
        0 => 287,
        1 => 480
      }
    end
  end

  def render_financial_benchmarks
    pdf_doc.move_down 10.mm
    render_financial_table_header
    render_base_growth_table

    pdf_doc.move_down 10.mm
    render_overall_growth_table
  end

  def render_base_growth_table
    rows = if @form_answer.trade?
      [
        financial_pointer.growth_overseas_earnings_list.unshift("% Growth overseas earnings"),
        financial_pointer.sales_exported_list.unshift("% Sales exported"),
        financial_pointer.average_growth_for_list.unshift("% Sector average growth")
      ]
    else
      [
        financial_pointer.growth_in_total_turnover_list.unshift("% Growth in total turnover")
      ]
    end

    pdf_doc.table(rows,
      cell_style: { size: 12 },
      column_widths: column_widths
    )
  end

  def render_overall_growth_table
    rows = [
      [
        "Overall growth £[year 1 - #{financial_pointer.period_length}]",
        financial_pointer.overall_growth
      ],
      [
        "Overall growth %[year 1 - #{financial_pointer.period_length}]",
        financial_pointer.overall_growth_in_percents
      ]
    ]

    pdf_doc.table(rows,
      cell_style: { size: 12 },
      column_widths: benchmarks_column_widths
    )
  end
end
