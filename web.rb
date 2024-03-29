require "sinatra"
require "zlib"
require "atom/pub"
require "open-uri"
require "sinatra/reloader"

get '/giants/:keyword.atom' do
  feed = Atom::Feed.new do |f|
    f.title = "SF Giants Seat Marketplace"
    f.id = "http://sfgiants.seasonticketrights.com/Charter-Seat-Licenses/Charter-Seat-Licenses.aspx"
    f.updated = Time.now

    open("http://sfgiants.seasonticketrights.com/Charter-Seat-Licenses/Charter-Seat-Licenses.aspx") do |g|
      g.read.scan(/title=\".*?\"/) do |m|
        if m =~ /Listing/
          next unless m =~ /#{params["keyword"]}/i
          seats = m[/Seat Number\(s\)(.*)"/, 1].split(" - ")
#          puts seats.inspect
#          next unless seats.first.to_i - seats.last.to_i == -1
          f.entries << Atom::Entry.new do |e|
            m = m[7..-2]
            e.id = m[/(\d+)/, 1]
            e.title = m
            e.content = Atom::Content::Html.new(m)
          end
        end
      end
    end
  end

  feed.to_xml
end
