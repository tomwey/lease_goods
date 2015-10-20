# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Tag.create!([
  { name: "儿童玩具", sort: 1000 }, 
  { name: '儿童读物', sort: 999 }, 
  { name: '自行车', sort: 998 },
  { name: '帐篷', sort: 997 },
  { name: '单反相机', sort: 991 },
  { name: '烧烤架子', sort: 990 },
  ])
