class SubmissionDeadlineStatesTransitionWorker
  include Shoryuken::Worker

  shoryuken_options queue: "#{Rails.env}_default", auto_delete: true

  def perform(_sqs_msg)
    FormAnswerStateMachine.trigger_deadlines
  end
end
