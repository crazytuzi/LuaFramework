local black_list = {}

function black_list:isMatchText(text)
	local UTF8 = require("app.common.tools.Utf8")
	local black_units = require("app.cfg.black_units")
	if text == nil or type(text) ~= "string" then
		assert("传入值为空或非string类型")
		return false
	end
	local len = UTF8.utf8len(text)
	for i=1,len do
		local tmp = UTF8.utf8sub (text,i,i)
		local _t = black_units:get(tmp)
		if _t and #_t>0 then
			for i,v in ipairs(_t) do
				for x in string.gmatch(text,v) do
					return true
				end
			end
		end
	end
	return false
end

function black_list:filterBlack(text)
	local UTF8 = require("app.common.tools.Utf8")
	local black_units = require("app.cfg.black_units")
	if text == nil or type(text) ~= "string" then
		assert("传入值为空或非string类型")
		return text
	end
	local len = UTF8.utf8len(text)
	for i=1,len do
		local tmp = UTF8.utf8sub (text,i,i)
		local _t = black_units:get(tmp)
		if _t and #_t>0 then
			for i,v in ipairs(_t) do
				--保存一份tmpText
				local tmpText = text
				for x in string.gmatch(tmpText,v) do
					local len = UTF8.utf8len(v)
					local replace = ""
					for j=1,len do
						replace = replace .. "*"
					end
					text = string.gsub(text,v,replace)
				end
			end
		end
	end
	local gm_black_list = G_Setting:get("gm_black_list")
	if gm_black_list and gm_black_list ~= "" then
		gm_black_list = string.gsub(gm_black_list,"[\n%s\r]","")
		local matches = string.split(gm_black_list,",")

		for i,v in ipairs(matches) do
			text = string.gsub(text,v,"*")
		end
	end
	return text
end

return black_list