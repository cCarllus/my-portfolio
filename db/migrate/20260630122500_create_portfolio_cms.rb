class CreatePortfolioCms < ActiveRecord::Migration[8.1]
  def change
    create_table :portfolio_profiles do |t|
      t.string :full_name, null: false
      t.string :nickname
      t.json :roles, null: false, default: {}
      t.json :locations, null: false, default: {}
      t.json :philosophies, null: false, default: {}
      t.json :summaries, null: false, default: {}
      t.json :map_labels, null: false, default: {}
      t.json :email_subjects, null: false, default: {}
      t.json :email_bodies, null: false, default: {}
      t.string :contact_email
      t.string :phone
      t.string :linkedin_url
      t.string :github_url
      t.decimal :map_x_percent, precision: 5, scale: 2, null: false, default: 35
      t.decimal :map_y_percent, precision: 5, scale: 2, null: false, default: 60

      t.timestamps
    end

    create_table :skills do |t|
      t.references :portfolio_profile, null: false, foreign_key: true
      t.string :name, null: false
      t.string :category, null: false, default: "backend"
      t.string :color, null: false, default: "violet"
      t.integer :position, null: false, default: 0
      t.boolean :featured, null: false, default: true
      t.boolean :published, null: false, default: true

      t.timestamps
      t.index [ :portfolio_profile_id, :position ]
    end

    create_table :experiences do |t|
      t.references :portfolio_profile, null: false, foreign_key: true
      t.string :company, null: false
      t.string :period, null: false
      t.json :roles, null: false, default: {}
      t.json :locations, null: false, default: {}
      t.json :summaries, null: false, default: {}
      t.integer :position, null: false, default: 0
      t.boolean :published, null: false, default: true

      t.timestamps
      t.index [ :portfolio_profile_id, :position ]
    end

    create_table :highlights do |t|
      t.references :portfolio_profile, null: false, foreign_key: true
      t.string :metric
      t.json :titles, null: false, default: {}
      t.json :descriptions, null: false, default: {}
      t.integer :position, null: false, default: 0
      t.boolean :published, null: false, default: true

      t.timestamps
      t.index [ :portfolio_profile_id, :position ]
    end

    create_table :educations do |t|
      t.references :portfolio_profile, null: false, foreign_key: true
      t.json :courses, null: false, default: {}
      t.json :institutions, null: false, default: {}
      t.json :statuses, null: false, default: {}
      t.integer :position, null: false, default: 0
      t.boolean :published, null: false, default: true

      t.timestamps
      t.index [ :portfolio_profile_id, :position ]
    end

    create_table :portfolio_documents do |t|
      t.references :portfolio_profile, null: false, foreign_key: true
      t.json :titles, null: false, default: {}
      t.json :bodies, null: false, default: {}
      t.integer :position, null: false, default: 0
      t.boolean :published, null: false, default: true

      t.timestamps
      t.index [ :portfolio_profile_id, :position ]
    end

    create_table :contact_requests do |t|
      t.string :email, null: false
      t.string :contact_name
      t.string :company_name
      t.string :job_title
      t.string :locale, null: false, default: "pt"
      t.string :status, null: false, default: "pending"
      t.datetime :sent_at
      t.text :error_message
      t.string :request_ip
      t.string :user_agent

      t.timestamps
      t.index :email
      t.index :status
    end
  end
end
