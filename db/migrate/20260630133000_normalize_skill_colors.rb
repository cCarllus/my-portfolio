class NormalizeSkillColors < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE skills
      SET color = printf('#%06X', abs(random()) % 16777216)
      WHERE color NOT GLOB '#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]'
    SQL

    change_column_default :skills, :color, from: "violet", to: nil
  end

  def down
    change_column_default :skills, :color, from: nil, to: "violet"
  end
end
