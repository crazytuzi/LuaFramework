XmlUtil = XmlUtil or BaseClass()

--获得标签里的内容
--如<sex0>兄弟们</sex0>,上吧~
function XmlUtil.GetTagContent(str, tag)
	if str == nil or tag == nil then
		return str
	end
	local i, j = string.find(str, "<".. tag ..">(.-)</" .. tag .. ">")
	if i == nil or j == nil then
		return nil
	end
	local content = string.sub(str, i, j)
	content = string.gsub(content, "<".. tag ..">", "")
	content = string.gsub(content, "</".. tag ..">", "")
	return content
end

--替换标签里带的内容
function XmlUtil.ReplaceTagContent(str, tag, rep_content)
	if str == nil or tag == nil or rep_content == nil then
		return str
	end
	content = string.gsub(str, "<".. tag ..">(.-)</" .. tag .. ">", rep_content)
	return content
end


