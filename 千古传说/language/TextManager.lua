
local TextManager  = class("TextManager")

-- local LanguagePack = require("language.Chinese.tips")
require("language.Chinese.tips")

-- 本地化
-- localizable

-- print("LanguagePack = ", LanguagePack)

-- function getString( index )
-- 	local  msg = LanguagePack[index]
-- 	if msg == nil then
-- 		print("can't find index == ", index)
-- 		msg = ""
-- 	else
-- 		print("find msg = ", msg)
-- 	end

-- 	-- m = n + 1
-- 	return msg
-- 	-- return LanguagePack[index] or ""
-- end

function TextManager:reset()

end

function TextManager:ctor()

end

function TextManager:getString( key )
	-- print("can't find key == ", key)
	-- return getString(key)	
	local  msg = LanguagePack[key]
	if msg == nil then
		print("can't find key == ", key)
		msg = ""
	end

	return msg
end


return TextManager:new()