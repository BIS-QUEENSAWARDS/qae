require "qae_2014_forms/innovation/innovation_step1"
require "qae_2014_forms/innovation/innovation_step2"
require "qae_2014_forms/innovation/innovation_step3"
require "qae_2014_forms/innovation/innovation_step4"
require "qae_2014_forms/innovation/innovation_step5"
require "qae_2014_forms/innovation/innovation_step6"

class QAE2014Forms
  class << self
    def innovation
      @innovation ||= QAEFormBuilder.build "Innovation Award Application" do
        step "Company Information",
             "Company Info",
             &QAE2014Forms.innovation_step1

        step "Your Innovation",
             "Your Innovation",
             &QAE2014Forms.innovation_step2

        step "Commercial Performance",
             "Commercial Performance",
             &QAE2014Forms.innovation_step3

        step "Declaration of Corporate Responsibility",
             "Corporate Responsibility",
             &QAE2014Forms.innovation_step4

        step "Add Website Address/Documents",
             "Add Website Address/Documents",
             &QAE2014Forms.innovation_step5

        step "Authorise & Submit",
             "Authorise & Submit",
             &QAE2014Forms.innovation_step6
      end
    end
  end
end
