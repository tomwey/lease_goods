# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Unit.delete_all

u1 = Unit.create!(name: "元/天")
u2 = Unit.create!(name: "元/次")
u3 = Unit.create!(name: "元")

Tag.delete_all
Tag.create!([
  { name: "儿童玩具", sort: 1000, unit_id: u1.id },
  { name: '儿童读物', sort: 999, unit_id: u1.id },
  { name: '自行车', sort: 998, unit_id: u1.id },
  { name: '帐篷', sort: 997, unit_id: u2.id },
  { name: '单反相机', sort: 991, unit_id: u2.id },
  { name: '烧烤架子', sort: 990, unit_id: u1.id },
  ])

Admin.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')Item.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')