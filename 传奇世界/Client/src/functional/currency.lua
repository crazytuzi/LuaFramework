--[[
用法示例:
local Mcurrency = require "src/functional/currency"
local node = Mcurrency.new(
{
	-- (金币 PLAYER_MONEY | 绑定金币 PLAYER_BINDMONEY | 元宝 PLAYER_INGOT | 绑定元宝 PLAYER_BINDINGOT | 魂值 PLAYER_SOUL_SCORE)
	cate = PLAYER_MONEY, 
	bg = "res/common/19.png", -- 可选
	color = MColor.yellow, -- 可选
	unit = 10000, -- 可选
	margin = 2, -- 可选
	scale = 0.8, -- icon 缩放的缩放系数
})
]]

local transitUnit = function(number, unit)
	if unit == 1 then
		return tostring(number)
	elseif unit == 10000 then
		local value = number/unit
		return tostring(value - value % 0.01) .. game.getStrByKey("task_num")
	else
		return ""
	end
end

return { new = function(params)
------------------------------------------------------------------------------------
local MRoleStruct = require "src/layers/role/RoleStruct"
local Mnode = require "src/young/node"
local MColor = require "src/config/FontColor"
------------------------------------------------------------------------------------
-- 货币类型
local cate = params.cate or PLAYER_MONEY

-- 货币单位(1 | 1万)
local unit = params.unit or 1

-- 背景图片(可选)
local baseboard = params.bg

-- 字体大小
local size = params.size or 22

-- 字体颜色
local color = params.color

-- 图标和数值之间的间隔
local margin = params.margin or 8

-- 占位符
local placeholder = params.placeholder or "123456789万"

-- icon 缩放的缩放系数
local scale = params.scale or 0.7

-- 数值变化特效
local effect = params.effect

-- 是否描边
local isOutline = params.isOutline
------------------------------------------------------------------------------------

-- 货币图标所在位置
local iconPath = "res/group/currency/"

-- 货币图标文件
local tIconPath = {
	[PLAYER_MONEY] = "1",
	[PLAYER_BINDMONEY] = "2",
	[PLAYER_INGOT] = "3",
	[PLAYER_BINDINGOT] = "4",
	[PLAYER_SOUL_SCORE] = "6", -- 魂值
	[PLAYER_VITAL] = "7", -- 真气
	[PLAYER_MERITORIOUS] = "8.png",
}

local icon = cc.Sprite:create(iconPath .. tIconPath[cate] .. ".png")
icon:setScale(scale)

local label = {
	src = placeholder, 
	color = color,
	size = size,
	isOutline = isOutline,
}

local pair = Mnode.createKVP(
{
	k = icon,
	v = label,
	margin = margin,
})

local root = baseboard and 
Mnode.overlayNode(
{
	parent = cc.Sprite:create(baseboard),
	{ node = pair }
}) or pair

pair:setValue( transitUnit(MRoleStruct:getAttr(cate), unit) )

------------------------------------------------------------------------------------
-- 货币数值发生了变化
local onDataSourceChanged = function(observable, attrId, objId, isMe, attrValue)
	if not isMe or attrId ~= cate then return end
	pair:setValue( transitUnit(MRoleStruct:getAttr(cate), unit), effect )
end

root:registerScriptHandler(function(event)
	if event == "enter" then
		MRoleStruct:register(onDataSourceChanged)
	elseif event == "exit" then
		MRoleStruct:unregister(onDataSourceChanged)
	end
end)
------------------------------------------------------------------------------------
return root

end }