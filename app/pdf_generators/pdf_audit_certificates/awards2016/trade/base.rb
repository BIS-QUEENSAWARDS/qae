module PdfAuditCertificates::Awards2016::Trade
  class Base < PdfAuditCertificates::Base
    # HERE YOU CAN OVERRIDE STANDART METHODS
    def header_full_award_type
      "International Trade Award"
    end

    def render_guidance_section
      render_guidance_intro
      move_down 3.mm
      render_guidance_general_notes
      move_down 3.mm
      render_guidance_estimated_figures
      move_down 3.mm
      render_guidance_employees
      move_down 3.mm
      render_guidance_overseas_sales
      move_down 3.mm
    end
  end
end
