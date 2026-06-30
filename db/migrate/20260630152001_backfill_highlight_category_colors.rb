require "securerandom"

class BackfillHighlightCategoryColors < ActiveRecord::Migration[8.1]
  class Project < ActiveRecord::Base
    self.table_name = "highlights"
  end

  def up
    Project.where(category_color: [ nil, "" ]).find_each do |project|
      project.update_columns(category_color: format("#%06x", SecureRandom.random_number(0x1000000)))
    end
  end

  def down
    Project.update_all(category_color: nil)
  end
end
