class Assessor::FormAnswersController < Assessor::BaseController
  helper_method :resource,
                :primary_assessment,
                :secondary_assessment,
                :moderated_assessment,
                :current_award_type

  def index
    authorize :form_answer, :index?
    params[:search] ||= FormAnswerSearch::DEFAULT_SEARCH
    scope = current_assessor.applications_assigned_to_as.where(award_type: current_award_type)

    @search = FormAnswerSearch.new(scope, current_assessor).search(params[:search])
    @form_answers = @search.results.page(params[:page]).includes(:comments)
  end

  def show
    authorize resource, :show?
  end

  def review
    authorize resource, :review?
    sign_in(resource.user, bypass: true)
    session[:admin_in_read_only_mode] = true

    redirect_to edit_form_path(resource, anchor: "company-information")
  end

  private

  def resource
    @form_answer ||= current_assessor.applications_assigned_to_as.find(params[:id]).decorate
  end

  def primary_assessment
    @primary_assessment ||= resource.assessor_assignments.primary.decorate
  end

  def secondary_assessment
    @secondary_assessment ||= resource.assessor_assignments.secondary.decorate
  end

  def moderated_assessment
    if current_subject.lead?(resource)
      @moderated_assessment ||= resource.assessor_assignments.moderated.decorate
    end
  end

  def current_award_type
    categories = current_subject.categories_as_lead
    if params[:award_type].present?
      params[:award_type] if categories.include?(params[:award_type])
    else
      categories.first
    end
  end
end
