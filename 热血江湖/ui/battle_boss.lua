-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/taskBase");
local BASE = ui.taskBase
-------------------------------------------------------
wnd_battle_boss = i3k_class("wnd_battle_boss", ui.taskBase)

function wnd_battle_boss:ctor()

end

function wnd_battle_boss:configure()
	BASE.configure(self)
    BASE.setTabState(self, 3)
	self._layout.vars.bossBtn:setVisible(true)
end


function wnd_battle_boss:onShow()
	BASE.onShow(self)
	local scroll = self._layout.vars.task_scroll
	local datas, bossId, selfDamage = g_i3k_game_context:GetBossDamageData()
	local roleID = g_i3k_game_context:GetRoleId()
	local containSelf = false
	self._bossId = bossId
	for i,v in ipairs(datas) do
		local node = require("ui/widgets/zdbosspmt2")()
		node.vars.rankLabel:setText(string.format("%d.", i))
		node.vars.nameLabel:setText(v.roleName)
		node.vars.damageLabel:setText(v.damage)
		node.rootVar:setTag(v.roleID)
		scroll:addItem(node)
		if v.roleID == roleID then
			containSelf = true
		end
	end
	-- if selfDamage and not containSelf then
	-- 	local node = require("ui/widgets/zdbosspmt2")()
	-- 	node.vars.rankLabel:setText("榜外")
	-- 	node.vars.nameLabel:setText(g_i3k_game_context:GetRoleName())
	-- 	node.vars.damageLabel:setText(selfDamage)
	-- 	self:setLabelColor(node)
	-- 	scroll:addItem(node)
	-- end
end

function wnd_battle_boss:updateDamageData(datas, bossId, selfDamage)
	local scroll = self._layout.vars.task_scroll
	if self._bossId and self._bossId ~= bossId then
		self._bossId = bossId
		scroll:removeAllChildren()
	end
	local roleID = g_i3k_game_context:GetRoleId()
	local containSelf = false
	local children = scroll:getAllChildren()
	-- if #children > #datas then
	-- 	-- 当打了一个boss，又打了另外一个boss可能会出现这个问题
	-- 	error(string.format("error! boss activity #children shouldn't more than #datas"))
	-- end
	for i,v in ipairs(datas) do
		local hasNode = children[i]
		if hasNode then
			hasNode.vars.rankLabel:setText(string.format("%d.", i))
			hasNode.vars.nameLabel:setText(v.roleName)
			hasNode.vars.damageLabel:setText(v.damage)
			-- self:setLabelColor(hasNode, false)
			hasNode.rootVar:setTag(v.roleID)
		else
			local node = require("ui/widgets/zdbosspmt2")()
			node.vars.rankLabel:setText(string.format("%d.", i))
			node.vars.nameLabel:setText(v.roleName)
			node.vars.damageLabel:setText(v.damage)
			node.rootVar:setTag(v.roleID)
			scroll:addItem(node)
		end
		if v.roleID == roleID then
			containSelf = true
		end
	end
	if selfDamage then
		local hasNode = children[#datas + 1]
		if not containSelf then
			if hasNode then
				-- hasNode.vars.nameLabel:setText(g_i3k_game_context:GetRoleName())
				hasNode.vars.damageLabel:setText(selfDamage)
			else
				local node = require("ui/widgets/zdbosspmt2")()
				node.vars.rankLabel:setText("榜外")
				node.vars.nameLabel:setText(g_i3k_game_context:GetRoleName())
				node.vars.damageLabel:setText(selfDamage)
				self:setLabelColor(node, true)
				scroll:addItem(node)
			end
		else
			if hasNode then
				scroll:removeChildAtIndex(#datas + 1)
			end
		end
	end
end

function wnd_battle_boss:setLabelColor(node, isMe) --"hlgreen"  g_i3k_get_green_color() or g_i3k_get_white_color()
	local color = isMe and g_i3k_get_hl_green_color() or g_i3k_get_white_color()
	node.vars.rankLabel:setTextColor(color)
	node.vars.nameLabel:setTextColor(color)
	node.vars.damageLabel:setTextColor(color)
end

function wnd_create(layout, ...)
	local wnd = wnd_battle_boss.new()
	wnd:create(layout, ...)
	return wnd;
end
