HtmlTool = HtmlTool or {}

function HtmlTool.GetHtml(content, color , size)
	local html_str = "<font"
	local color_str = nil
	if color ~= nil then
		if type(color) == "table" then
			color_str = string.format("#%x%x%x", color.r,color.g, color.b)
		else
			color_str = color
		end		
		html_str = html_str .. " color='" .. color_str .. "'"
	end
	if size ~= nil then
		html_str = html_str .. " size='" .. size .. "'"
	end
	html_str = html_str .. ">" .. content .. "</font>"
	return html_str
end

function HtmlTool.BlankReplace(content)
	local str = content or ""
	if IS_IOS_OR_ANDROID then
		str = string.gsub(str, " ", "  ")
	end
	return str
end
