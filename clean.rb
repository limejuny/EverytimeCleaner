require "io/console"
require "mechanize"

agent = Mechanize.new
page = agent.get("https://everytime.kr/login")
form = page.forms.first

print "User ID >> "
form.userid = gets.chomp
print "Password >> "
form.password = $stdin.noecho(&:gets).chomp
form.submit # Mechanize::Page

puts
puts
puts "=============="
puts "=============="

# ARTICLE
puts "REMOVE ARTICLE"
loop do
  # page = agent.get('https://everytime.kr/myarticle')
  posted = agent.post("https://api.everytime.kr/find/board/article/list", {
    id: "myarticle",
    limit_num: 20,
    start_num: 0,
    moiminfo: true,
  })

  c = posted.xml.root.children
  # puts c.length
  if c.length == 0
    break
  end
  (1...c.length).step(2) do |i|
    # board_id = c[i].attributes['board_id'].value
    id = c[i].attributes["id"].value
    # uri = "https://everytime.kr/#{board_id}/v/#{id}"

    del = agent.post("https://api.everytime.kr/remove/board/article", {
      id: id,
    })
  end
end

# COMMENT
puts "REMOVE COMMENT"
loop do
  # page = agent.get('https://everytime.kr/mycommentarticle')
  posted = agent.post("https://api.everytime.kr/find/board/article/list", {
    id: "mycommentarticle",
    limit_num: 20,
    start_num: 0,
    moiminfo: true,
  })

  c = posted.xml.root.children
  # puts c.length
  if c.length == 0
    break
  end
  (1...c.length).step(2) do |i|
    # board_id = c[i].attributes['board_id'].value
    id = c[i].attributes["id"].value
    # uri = "https://everytime.kr/#{board_id}/v/#{id}"

    article = agent.get("https://api.everytime.kr/find/board/comment/list", {
      id: id,
      limit_num: -1,
      moiminfo: true,
    })
    c2 = article.xml.root.children
    (5...c2.length).step(2) do |j|
      next if c2[j].attributes["is_mine"].value == "0"
      del = agent.post("https://api.everytime.kr/remove/board/comment", {
        id: c2[j].attributes["id"].value,
      })
    end
  end
end
