# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160113113052) do

  create_table "admins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "article_texts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.text     "text",       limit: 16777215
    t.integer  "article_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["article_id"], name: "index_article_texts_on_article_id", using: :btree
  end

  create_table "articles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "novel_id"
    t.string   "link"
    t.string   "title"
    t.string   "subject"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "num",        default: 0
    t.boolean  "is_show",    default: true
    t.string   "slug"
    t.index ["link"], name: "index_articles_on_link", using: :btree
    t.index ["novel_id"], name: "index_articles_on_novel_id", using: :btree
    t.index ["num"], name: "index_articles_on_num", using: :btree
    t.index ["slug"], name: "index_articles_on_slug", using: :btree
  end

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.string   "link"
    t.string   "cat_link"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "is_popular", default: false
    t.string   "slug"
    t.index ["slug"], name: "index_categories_on_slug", using: :btree
  end

  create_table "friendly_id_slugs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
  end

  create_table "from_links", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "novel_id"
    t.string   "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["novel_id"], name: "index_from_links_on_novel_id", using: :btree
  end

  create_table "hot_ships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "novel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["novel_id"], name: "index_hot_ships_on_novel_id", using: :btree
  end

  create_table "novels", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.string   "author"
    t.text     "description",               limit: 65535
    t.string   "pic"
    t.integer  "category_id"
    t.string   "link"
    t.string   "article_num"
    t.string   "last_update"
    t.boolean  "is_serializing"
    t.boolean  "is_category_recommend"
    t.boolean  "is_category_hot"
    t.boolean  "is_category_this_week_hot"
    t.boolean  "is_classic"
    t.boolean  "is_classic_action"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "crawl_times",                             default: 0
    t.integer  "num",                                     default: 0
    t.boolean  "is_show",                                 default: true
    t.string   "slug"
    t.integer  "writer_id"
    t.index ["author"], name: "index_novels_on_author", using: :btree
    t.index ["category_id"], name: "index_novels_on_category_id", using: :btree
    t.index ["is_show"], name: "index_novels_on_is_show", using: :btree
    t.index ["name"], name: "index_novels_on_name", using: :btree
    t.index ["num"], name: "index_novels_on_num", using: :btree
    t.index ["slug"], name: "index_novels_on_slug", using: :btree
    t.index ["writer_id"], name: "index_novels_on_writer_id", using: :btree
  end

  create_table "recommend_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "slug"
    t.index ["slug"], name: "index_recommend_categories_on_slug", using: :btree
  end

  create_table "recommend_category_novel_ships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "novel_id"
    t.integer  "recommend_category_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["novel_id"], name: "index_recommend_category_novel_ships_on_novel_id", using: :btree
    t.index ["recommend_category_id"], name: "index_recommend_category_novel_ships_on_recommend_category_id", using: :btree
  end

  create_table "this_month_hot_ships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "novel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["novel_id"], name: "index_this_month_hot_ships_on_novel_id", using: :btree
  end

  create_table "this_week_hot_ships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "novel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["novel_id"], name: "index_this_week_hot_ships_on_novel_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "email"
    t.text     "collect_novels",  limit: 65535
    t.text     "download_novels", limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["email"], name: "index_users_on_email", using: :btree
  end

  create_table "writers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.string   "email"
    t.string   "url"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "remark",          limit: 65535
    t.text     "decription",      limit: 65535
    t.string   "password_digest"
  end

end
