module Jekyll
  class CategoryTags < Liquid::Tag

    def render(context)
		temparray = Array.new
		techarray = Hash.new
		catarray  = Array.new		
		site = context.registers[:site]
		html=""
		
		site.categories.each do |category,post|
		catarray.push(category)
		end
		
		for cat in catarray
			if cat == "netsec" || cat == "linux"
				for post in site.categories[cat]
					for tag in post.tags
						temparray.push(tag)
					end
				end
			end
		end
		
		for tag in temparray
			techarray[tag] = temparray.grep(tag).size
		end
		
		
		html << "<ul id=\"tagmenu\">"
		techarray.each do |tag , count|
			html << "<li> <a href=\"/tag/tech/"
			html << tag
			html << "\">"
			html << tag
			html << " ("<<count.to_s<<") </a> </li>"
			
		end
		html << "</ul>"
		html
	end
  end
end

Liquid::Template.register_tag('cat_tag', Jekyll::CategoryTags)
