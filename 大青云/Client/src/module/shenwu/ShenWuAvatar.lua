--[[
神武 avatar
2015年12月29日14:48:14
haohu
]]

_G.ShenWuAvatar = {}
setmetatable(ShenWuAvatar, {__index = CAvatar})
local metaShenWuAvatar = {__index = ShenWuAvatar}

function ShenWuAvatar:new(skn, skl, san)
	local obj = CAvatar:new()
	obj.avtName = "shenwu"
	obj.name = "shenwu" .. skn
    obj:SetPart("Body", skn)
    obj:ChangeSkl(skl)
    obj.szIdleAction = san
    setmetatable(obj, metaShenWuAvatar)
    return obj
end
