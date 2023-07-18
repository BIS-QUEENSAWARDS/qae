require "award_years/v2019/international_trade/international_trade_step1"
require "award_years/v2019/international_trade/international_trade_step2"
require "award_years/v2019/international_trade/international_trade_step3"
require "award_years/v2019/international_trade/international_trade_step4"
require "award_years/v2019/international_trade/international_trade_step5"
require "award_years/v2019/international_trade/international_trade_step6"

class AwardYears::V2019::QaeForms
  class << self
    def trade
      @trade ||= QaeFormBuilder.build "International Trade Award Application" do
        step "Company Information",
             "Company Information",
             &AwardYears::V2019::QaeForms.trade_step1

        step "Your International Trade",
             "Your International Trade",
             &AwardYears::V2019::QaeForms.trade_step2

        step "Commercial Performance",
             "Commercial Performance",
             &AwardYears::V2019::QaeForms.trade_step3

        step "Declaration of Corporate Responsibility",
             "Declaration of Corporate Responsibility",
             &AwardYears::V2019::QaeForms.trade_step4

        step "Add Website Address/Documents",
             "Add Website Address/Documents",
             { id: :add_website_address_documents_step },
             &AwardYears::V2019::QaeForms.trade_step5

        step "Authorise & Submit",
             "Authorise & Submit",
             &AwardYears::V2019::QaeForms.trade_step6
      end
    end
  end
end
