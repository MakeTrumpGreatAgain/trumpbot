require 'json'
lines = IO.readlines("../TRUMP-WP.txt")
	puts lines
	lines = lines.select do |line|
		not (/^\s*$/ =~ line)
	end

	lines.reverse!
	trumpFound = false
	trumpText = ""

	puts lines
	lines = lines.reduce([]) do |all, line|
		if m = /TRUMP\s*:(.+)/.match(line)
			trumpFound = true
			trumpText = m[1]
		elsif m = /(.+):(.+)/.match(line)
			if trumpFound
				trumpText.split(".").each do |sentence|
					all << {question: m[2], answer: sentence}
				end
				trumpFound = false
			end
		end
		all
	end

	puts lines.length

	open("../json/washington-post-2016-03-21.json","w") do |io|
		io.puts JSON.generate(lines)
	end