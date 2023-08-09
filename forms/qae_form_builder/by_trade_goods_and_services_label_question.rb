class QaeFormBuilder
  class ByTradeGoodsAndServicesLabelQuestionValidator < QuestionValidator
    HUMANIZED_ATTRS = {
      "desc_short" => "Description",
      "total_overseas_trade" => "Trade percentage"
    }

    def errors
      result = super

      question.trade_goods_and_services.each_with_index do |entity, index|
        product_number = index + 1

        if product_number <= question.answers["trade_goods_and_services_explanations"].length.to_i
          question.required_sub_fields_list.each do |attr|
            if !entity[attr].present?
              result[question.key] ||= {}
              result[question.key][product_number] ||= {}
              result[question.key][product_number][attr] ||= ""
              result[question.key][product_number][attr] << "#{humanize(attr)} is required and must be filled in."
            end
          end
        end
      end
      result
    end

    def humanize(attr)
      HUMANIZED_ATTRS[attr].presence || attr.humanize.capitalize
    end
  end

  class ByTradeGoodsAndServicesLabelQuestionDecorator < QuestionDecorator
    def trade_goods_and_services
      @trade_goods_and_services ||= (answers[delegate_obj.key.to_s] || [])
    end

    def required_sub_fields_list
      %w(desc_short total_overseas_trade)
    end
  end

  class ByTradeGoodsAndServicesLabelQuestionBuilder < QuestionBuilder
    def rows num=3
      @q.rows = num
    end

    def words_max num
      @q.words_max = num
    end

    def min num
      @q.min = num
    end

    def max num
      @q.max = num
    end

    def product_limit num
      @q.product_limit = num
    end
  end

  class ByAmountCondition
    attr_accessor :question_key
    def initialize question_key
      @question_key = question_key
    end
  end

  class ByTradeGoodsAndServicesLabelQuestion < Question
    attr_accessor :rows, :words_max, :min, :max, :product_limit
  end
end
