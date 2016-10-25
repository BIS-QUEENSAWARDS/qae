require 'rails_helper'
include Warden::Test::Helpers

describe "Verification of Commercial Figures", %q{
As a User
I want to be able to download an Verification of Commercial Figures
So that I can check, complete it and then upload it to application
} do

  let!(:user) do
    create :user
  end

  let!(:form_answer) do
    create :form_answer, :innovation,
      user: user,
      urn: "QA0001/19T",
      document: generate(:financial_data_sample)
  end

  before do
    login_as user
  end

  describe "Visit Verification of Commercial Figures details page" do
    before do
      visit users_form_answer_audit_certificate_url(form_answer)
    end

    it "should render page" do
      expect_to_see "Verification of Commercial Figures"
      expect(page).to have_link(
        "this Verification of Commercial Figures",
        href: users_form_answer_audit_certificate_url(form_answer, format: :pdf)
      )
    end
  end

  describe "Download Verification of Commercial Figures prefilled with my financial data" do
    let(:audit_certificate_filename) do
      "verification_of_commercial_figures_#{form_answer.decorate.pdf_filename}"
    end

    before do
      visit users_form_answer_audit_certificate_url(form_answer, format: :pdf)
    end

    it "should generate pdf file" do
      expect(page.status_code).to eq(200)
      expect(page.response_headers["Content-Disposition"]).to be_eql(
        "attachment; filename=\"#{audit_certificate_filename}\""
      )
      expect(page.response_headers["Content-Type"]).to be_eql "application/pdf"
    end
  end
end
