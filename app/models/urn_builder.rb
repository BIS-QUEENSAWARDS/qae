class UrnBuilder
  attr_reader :fa, :award_year

  def initialize(form_answer)
    @fa = form_answer
    @award_year = form_answer.award_year
  end

  def assign
    return if fa.urn
    return unless fa.submitted
    return unless fa.award_type

    sequence_attr = "urn_seq_promotion_#{award_year.year}" if fa.promotion?
    sequence_attr ||= "urn_seq_#{award_year.year}"

    next_seq = fa.class.connection.select_value("SELECT nextval(#{ActiveRecord::Base.sanitize(sequence_attr)})")

    generated_urn = "QA#{sprintf('%.4d', next_seq)}/"
    suffix = {
      "promotion" => "EP",
      "development" => "S",
      "innovation" => "I",
      "trade" => "T"
    }[fa.award_type]
    generated_urn += "#{award_year.year.to_s[2..-1]}#{suffix}"

    fa.urn = generated_urn
  end
end
