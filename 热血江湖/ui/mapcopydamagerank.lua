-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_map_copy_damage_rank = i3k_class("wnd_map_copy_damage_rank",ui.wnd_base)

local WidgetFbphb = "ui/widgets/fbphbt"
local COLOR1 = "fffdb0b0"  --粉红色
local COLOR2 = "ffcdc4f1"  --紫色
local DamageBarBg1 = 3416
local DamageBarBg2 = 3417

function wnd_map_copy_damage_rank:ctor()
	self._timeCounter = 0
end

function wnd_map_copy_damage_rank:configure()
	local widgets = self._layout.vars
	self.rankScroll = widgets.rankScroll
end

function wnd_map_copy_damage_rank:syncMapcopy()
	local flag = g_i3k_db.i3k_db_check_sync_mapcopy()
	if flag then
		i3k_sbean.queryMapCopyDamageRank()
	end
end

function wnd_map_copy_damage_rank:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter > 2 then
		self:syncMapcopy()
		self._timeCounter = 0
	end
end

function wnd_map_copy_damage_rank:onShow()
	self:syncMapcopy()
end



function wnd_map_copy_damage_rank:refresh()
	self:updateOutPut()
end

function wnd_map_copy_damage_rank:updateOutPut()
	self.rankScroll:removeAllChildren()
	local roleID = g_i3k_game_context:GetRoleId()
	local damageRank = self:sortDamgeRank(g_i3k_game_context:GetMapCopyDamageRank())
	local maxDamage = 0
	if #damageRank > 0 then
		maxDamage = damageRank[1].damage
	end
	for i, e in ipairs(damageRank) do
		local widget = require(WidgetFbphb)()
		local name
		if e.attackName ~= "" then
			name = roleID == e.attackId and "主角" or e.attackName
		else -- 名字为空则为自己带的随从
			name = i3k_db_mercenaries[e.attackId].name
		end
		local iconId = roleID == e.attackId and DamageBarBg1 or DamageBarBg2
		widget.vars.name:setText(name)
		widget.vars.damageNum:setText(e.damage)
		widget.vars.name:setTextColor(roleID == e.attackId and COLOR1 or COLOR2)
		widget.vars.damageBar:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
		widget.vars.damageBar:setPercent(e.damage / maxDamage * 100)
		self.rankScroll:addItem(widget)
	end
end

function wnd_map_copy_damage_rank:sortDamgeRank(damageRank)
	local data = {}
	for k, v in pairs(damageRank) do
		table.insert(data, {attackId = k, attackName = v.attackName, damage = v.damage})
	end
	table.sort(data, function (a,b)
		return a.damage > b.damage
	end)
	return data
end

function wnd_create(layout)
	local wnd = wnd_map_copy_damage_rank.new()
	wnd:create(layout)
	return wnd
end
