-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_boss_records = i3k_class("wnd_boss_records", ui.wnd_base)

local THIS_TIMES_STATE = 1
local LAST_TIMES_STATE = 2
local f_recordCount = 10
local f_rankImg = {2718, 2719, 2720}

function wnd_boss_records:ctor()
	self._state = THIS_TIMES_STATE
end

function wnd_boss_records:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
    self._layout.vars.help_btn:onClick(self, self.Showhelp)
	self._tabbar = {
		self._layout.vars.nowTab,
		self._layout.vars.lastTab,
	}
	for i,v in ipairs(self._tabbar) do
		v:setTag(i)
		if i==self._state then
			v:stateToPressedAndDisable()
		end
	end
	self._layout.vars.scroll:setBounceEnabled(false)
end

function wnd_boss_records:onShow()

end

function wnd_boss_records:refresh(bossId, records, isLast, selfReward)
	self._state = isLast==1 and LAST_TIMES_STATE or THIS_TIMES_STATE
	for i,v in ipairs(self._tabbar) do
		if i==self._state then
			v:stateToPressedAndDisable()
		else
			v:stateToNormal()
			v:onClick(self, self.changeState, bossId)
		end
	end

	--设置击杀相关信息
	local killerItemTable = {}
	for k=1, 5 do
		local item = {}
		item.root = self._layout.vars[string.format("root%d", k)]
		item.icon = self._layout.vars[string.format("icon%d", k)]
		item.btn = self._layout.vars[string.format("btn%d", k)]
		item.countLabel = self._layout.vars[string.format("countLabel%d", k)]
		item.lock = self._layout.vars[string.format("lock%d", k)]
		item.root:hide()
		table.insert(killerItemTable, item)
	end
	self._layout.vars.killLabel:show()
	if records and records.killer and records.killer.damage.roleID and records.killer.damage.roleID ~= 0 then
		local data = records.killer
		local roleId = data.damage.roleID
		local killerName = data.damage.roleName
		if roleId < 0 then
			killerName = string.format("%s的队伍", killerName)
		end
		self._layout.vars.nameLabel:setText(killerName)
		self._layout.vars.killLabel:setText(string.format("击败"))
		local index = 1
		for k,v in pairs(data.reward) do
			local itemNode = killerItemTable[index]
			local rank = g_i3k_db.i3k_db_get_common_item_rank(k)
			itemNode.root:setImage(g_i3k_get_icon_frame_path_by_rank(rank))
			itemNode.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(k,i3k_game_context:IsFemaleRole()))
			itemNode.countLabel:setText(string.format("x%d", v))
			itemNode.lock:setVisible(g_i3k_common_item_has_binding_icon(k))
			itemNode.btn:setTag(k)
			itemNode.btn:onClick(self, self.checkItemGrade)
			itemNode.root:show()
			index = index + 1
		end
	else
		self._layout.vars.nameLabel:setText(string.format("无"))
		self._layout.vars.killLabel:setText(string.format("无"))
		for _,v in ipairs(killerItemTable) do
			v.countLabel:hide()
			v.lock:hide()
			v.root:setImage(g_i3k_db.i3k_db_get_icon_path(106))--空图标底框
			v.icon:setImage(g_i3k_db.i3k_db_get_icon_path(2665))--问号图标
			v.root:show()
		end
	end

	--设置伤害相关信息
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren(true)
	for index=1, f_recordCount do
		local node = require("ui/widgets/bosspmt")()
		node.vars.rankImg:setVisible(index<=3)
		node.vars.rankLabel:setVisible(not node.vars.rankImg:isVisible())
		if index<=3 then
			node.vars.rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(f_rankImg[index]))
		else
			node.vars.rankLabel:setText(string.format("%d.", index))
		end
		local itemTable = {}
		for k=1, 5 do
			local item = {}
			item.root = node.vars[string.format("root%d", k)]
			item.icon = node.vars[string.format("icon%d", k)]
			item.btn = node.vars[string.format("btn%d", k)]
			item.countLabel = node.vars[string.format("countLabel%d", k)]
			item.lock = node.vars[string.format("lock%d", k)]
			item.root:hide()
			table.insert(itemTable, item)
		end
		node.vars.killLabel:hide()--根据标志判断
		if not records or not records.rank[index] then
			node.vars.nameLabel:setText(string.format("无"))
			node.vars.damageLabel:setText(string.format("无"))
			for _,v in ipairs(itemTable) do
				v.countLabel:hide()
				v.lock:hide()
				v.icon:setImage(g_i3k_db.i3k_db_get_icon_path(2665))
				v.root:show()
			end
		elseif records.rank[index] then
			local data = records.rank[index]
			node.vars.nameLabel:setText(data.damage.roleName)
			node.vars.damageLabel:setText(data.damage.damage)
			local dex = 1
			for k,v in pairs(data.reward) do
				local itemNode = itemTable[dex]
				local rank = g_i3k_db.i3k_db_get_common_item_rank(k)
				itemNode.root:setImage(g_i3k_get_icon_frame_path_by_rank(rank))
				itemNode.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(k,i3k_game_context:IsFemaleRole()))
				itemNode.countLabel:setText(string.format("x%d", v))
				itemNode.lock:setVisible(g_i3k_common_item_has_binding_icon(k))
				itemNode.btn:setTag(k)
				itemNode.btn:onClick(self, self.checkItemGrade)
				itemNode.root:show()
				dex = dex + 1
			end
		end
		scroll:addItem(node)
	end
	if selfReward then
		self:addSelfReward(selfReward)
	end
end

function wnd_boss_records:addSelfReward(selfReward)
	local scroll = self._layout.vars.scroll
	local node = require("ui/widgets/bosspmt")()
	local itemTable = {}
	for k=1, 5 do
		local item = {}
		item.root = node.vars[string.format("root%d", k)]
		item.icon = node.vars[string.format("icon%d", k)]
		item.btn = node.vars[string.format("btn%d", k)]
		item.countLabel = node.vars[string.format("countLabel%d", k)]
		item.lock = node.vars[string.format("lock%d", k)]
		item.root:hide()
		table.insert(itemTable, item)
	end

	node.vars.rankImg:hide()
	node.vars.killLabel:hide()
	node.vars.rankLabel:setText("榜外")
	node.vars.nameLabel:setText(selfReward.damage.roleName)
	node.vars.damageLabel:setText(selfReward.damage.damage)
	local dex = 1
	for k,v in pairs(selfReward.reward) do
		local itemNode = itemTable[dex]
		if itemNode then
			local rank = g_i3k_db.i3k_db_get_common_item_rank(k)
			itemNode.root:setImage(g_i3k_get_icon_frame_path_by_rank(rank))
			itemNode.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(k,i3k_game_context:IsFemaleRole()))
			itemNode.countLabel:setText(string.format("x%d", v))
			itemNode.lock:setVisible(g_i3k_common_item_has_binding_icon(k))
			itemNode.btn:setTag(k)
			itemNode.btn:onClick(self, self.checkItemGrade)
			itemNode.root:show()
		end
		dex = dex + 1
	end
	scroll:addItem(node)
end


function wnd_boss_records:checkItemGrade(sender)
	local itemId = sender:getTag()
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_boss_records:changeState(sender, bossId)
	local state = sender:getTag()
	local isLast = state==LAST_TIMES_STATE and 1 or 0
	i3k_sbean.sync_boss_record(bossId, isLast)
end

function wnd_boss_records:Showhelp(sender)
   g_i3k_ui_mgr:ShowHelp(i3k_get_string(15549))
end

function wnd_create(layout, ...)
	local wnd = wnd_boss_records.new()
	wnd:create(layout, ...)
	return wnd;
end
