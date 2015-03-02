# -*- coding: utf-8 -*-
class QAE2014Forms
  class << self
    def promotion_step3
      @promotion_step3 ||= proc do
        textarea :reasons_to_nominate, "Explain why your nominee deserves a Queen's Award for Enterprise Promotion." do
          ref "C 1"
          required
          context %(
            <p>
              How have they made a significant contribution in their area of activity
              whether in public/private and/or voluntary sectors?
              What makes your nominee stand out against others?
            </p>
                    )
          rows 3
          words_max 500
        end

        textarea :benefits_from_nominee_service, "Describe the benefits of your nominee’s services to a particular field, group, community or society as a whole." do
          ref "C 2"
          required
          context %(
            <p>
              What has their impact been? How wide is their influence?
              What are their achievements?
              Include details of the length of time
              involved and quantitative evidence
              that demonstrate the clear impact of the nominee’s activities.
              <br />
              Include when your nominee's activities have taken place
              within challenging circumstances
              or disadvantaged/deprived communities,
              or where young people or under-represented groups have benefited.
            </p>
                    )
          rows 3
          words_max 600
        end

        options :nominee_active_in_сurrent_enterprise_promotion_role,
          "Has your nominee been active in their current enterprise promotion role for over ten years?" do
          required
          ref "C 3"
          yes_no
        end

        header :nominee_is_eligible_for_lifetime_achievement_award,
               "Your nominee is eligible for a Lifetime Achievement Award." do
          context %(
            <p>
              A Lifetime Achievement Award is a special Enterprise Promotion award
              that is given for outstanding, consistent and effective promotion of business
              enterprise skills and attitudes
              <u>over at least ten years.</u>.
              All those nominated for Lifetime Achievement are still considered
              for the standard award.
            </p>
          )
          conditional :nominee_active_in_сurrent_enterprise_promotion_role, :yes
        end

        textarea :reasons_to_nominate_for_lifetime_achievemnt_award, "Explain why they deserve this award." do
          conditional :nominee_active_in_сurrent_enterprise_promotion_role, :yes
          words_max 300
          rows 3
          classes "sub-question"
        end
      end
    end
  end
end
