namespace :form_answers do

  desc 'Adds search indexed data'
  task refresh_search_indexes: :environment do
    FormAnswer.find_each do |f|
      user = f.user
      if user.present?
        f.user_full_name = user.full_name
        f.save
      end
    end
  end

  desc "Adds assessors fk"
  task refresh_assessors_ids: :environment do
    FormAnswer.find_each do |f|
      primary = f.assessors.primary
      secondary = f.assessors.secondary
      f.primary_assessor_id = primary.try(:id)
      f.secondary_assessor_id = secondary.try(:id)
      f.save
    end
  end

  # For single use only
  desc "Rebuilds the urns for all apps"
  task rebuild_urn: :environment do
    FormAnswer.connection.execute("ALTER SEQUENCE urn_seq_2016 RESTART")
    FormAnswer.connection.execute("ALTER SEQUENCE urn_seq_promotion_2016 RESTART")
    FormAnswer.update_all(urn: nil)
    FormAnswer.find_each(&:save!)
  end

  desc "Adds the county/remove country to all form answers"
  task refresh_attributes: :environment do
    FormAnswer.find_each do |f|
      next if f.promotion?
      f.document.delete("principal_address_country")
      f.document["principal_address_county"] = "Buckinghamshire" if f.submitted?
      f.save(validate: false)
    end
  end

  desc "Removes the deprecated answers from forms"
  task remove_overseas_sales: :environment do
    FormAnswer.where(award_type: "trade").find_each do |f|
      attributes = [
        "overseas_sales_direct_1of3",
        "overseas_sales_direct_1of6",
        "overseas_sales_direct_2of3",
        "overseas_sales_direct_3of3",
        "overseas_sales_direct_2of6",
        "overseas_sales_direct_3of6",
        "overseas_sales_direct_4of6",
        "overseas_sales_direct_5of6",
        "overseas_sales_direct_6of6",
        "overseas_sales_indirect_1of3",
        "overseas_sales_indirect_2of3",
        "overseas_sales_indirect_3of3",
        "overseas_sales_indirect_1of6",
        "overseas_sales_indirect_2of6",
        "overseas_sales_indirect_3of6",
        "overseas_sales_indirect_4of6",
        "overseas_sales_indirect_5of6",
        "overseas_sales_indirect_6of6"

      ]
      attributes.each do |a|
        f.document.delete(a)
      end
      f.save(validate: false)
    end
  end

  desc "Populate the form progresses"
  # Remove after use - it assumes that progress set up before save
  task populate_form_answer_progresses: :environment do
    output = {
      saved: [],
      not_saved: []
    }
    FormAnswer.find_each do |f|
      if f.save
        output[:saved] << f.id
      else
        output[:not_saved] << f.id
      end
    end

    p "Saved: #{output[:saved].size}; not saved: #{output[:not_saved].inspect}"
  end
end
