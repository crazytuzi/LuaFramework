local wordfilter = {}
local configs = import("csv2cfg.wordfilterCfg")
wordfilter.run = function (text, replaceWrod)
	if not text or text == "" then
		return text
	end

	text = utf8strs(text)

	local function check(group, i, plies, cnt)
		if group[1] then
			cnt = plies
		end

		if #text < i then
			return cnt
		end

		local subGroup = group[text[i]]

		if not subGroup then
			return cnt
		end

		return check(subGroup, i + 1, plies + 1, cnt)
	end

	local i = 1

	while true do
		local cnt = slot2(configs, i, 0, 0)

		if 0 < cnt then
			for j = i, (i + cnt) - 1, 1 do
				text[j] = replaceWrod or "*"
			end

			i = i + cnt
		else
			i = i + 1
		end

		if #text < i then
			break
		end
	end

	return table.concat(text)
end
wordfilter.check = function (text)
	if not text or text == "" then
		return true
	end

	text = utf8strs(text)

	local function check(group, i, plies, cnt)
		if group[1] then
			cnt = plies
		end

		if #text < i then
			return cnt
		end

		local subGroup = group[text[i]]

		if not subGroup then
			return cnt
		end

		return check(subGroup, i + 1, plies + 1, cnt)
	end

	local i = 1

	while true do
		if 0 < slot1(configs, i, 0, 0) then
			return 
		end

		i = i + 1

		if #text < i then
			break
		end
	end

	return true
end

return wordfilter
