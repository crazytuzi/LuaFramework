-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_powerReputationCommit = i3k_class("wnd_powerReputationCommit", ui.wnd_base)

function wnd_powerReputationCommit:ctor()

end

function wnd_powerReputationCommit:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_powerReputationCommit:onShow()

end

function wnd_powerReputationCommit:refresh(npcID)
	local powerSide = g_i3k_db.i3k_db_power_rep_get_type_by_npcid(npcID)
	local list = g_i3k_game_context:getPowerRepCommit(powerSide)

	self:setUI(powerSide)
	self:setItems(list, powerSide)
end

function wnd_powerReputationCommit:setUI(powerSide)
	local widgets = self._layout.vars
	local powerSideCfg = i3k_db_power_reputation[powerSide]
	widgets.taskName:setText(i3k_get_string(17250, powerSideCfg.name)) --("捐赠如下道具改善"..powerSideCfg.name.."关系")
	widgets.desc:setText(""..powerSideCfg.commitDesc)

	local max = g_i3k_game_context:getPowerRepMaxCommitPoints(powerSide)
	local cur = g_i3k_game_context:getPowerRepCurrentCommitPoints(powerSide)
	widgets.commitLabel:setText("今日已经捐赠:"..cur.."/"..max)
	local cfg = g_i3k_db.i3k_db_get_power_reputation_info(powerSide)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
	widgets.name:setText(cfg.name)

end


function wnd_powerReputationCommit:setItems(list, powerSide)
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	local temp = {powerSide = powerSide, items = {}}
	self._items = {}
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/shengwangjzt")()
		local cfg = g_i3k_db.i3k_db_power_rep_get_commit_cfg(powerSide, k)
		local itemID = cfg.id
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
		temp.items[itemID] = {itemID = itemID, reputation = cfg.reputation, maxCommitCount = cfg.maxCommitCount}
		ui.vars.count:setText("x"..haveCount) -- 当前选了几个道具
		ui.vars.count:setTextColor(g_i3k_get_cond_color(haveCount > 0))
		self._items[itemID] = {countLabel = ui.vars.count}

		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID))
		ui.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		ui.vars.lock:setVisible(itemID > 0)
		ui.vars.btn:onClick(self, self.onItem, itemID)
		ui.vars.point:setText(cfg.reputation.."点/个")
		scroll:addItem(ui)
	end
	g_i3k_game_context:setPowerRepUselessInfo(temp)
end

function wnd_powerReputationCommit:onItem(sender, id)
	local tempInfo = g_i3k_game_context:getPowerRepUselessInfo()
	local times = g_i3k_game_context:getCurrentPowerRepCommitCount(tempInfo.powerSide, id)
	local maxTimes = tempInfo.items[id].maxCommitCount
	if times >=  maxTimes then
		g_i3k_ui_mgr:PopupTipMessage("当日已经捐赠了"..maxTimes.."次，不可再捐赠")
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_UseItems)
	g_i3k_ui_mgr:RefreshUI(eUIID_UseItems, id, UseItemPowerRep)
end

-- InvokeUIFunction
function wnd_powerReputationCommit:updateItemsCount(itemID)
	local label = self._items[itemID].countLabel
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
	label:setText("x"..haveCount)
end

-- function wnd_powerReputationCommit:onItemTip(sender, itemId)
-- 	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
-- end

function wnd_create(layout, ...)
	local wnd = wnd_powerReputationCommit.new()
	wnd:create(layout, ...)
	return wnd;
end
