module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_gameEntrance = i3k_class("wnd_gameEntrance", ui.wnd_base)

local DiceID = 0
local KNIEF_SHOOTING_ID = 6
local DiceIconID = i3k_db_dice_entrance_cfg.diceIconID
local DiceSortId = 0

local SortOffset = 1000

function wnd_gameEntrance:ctor()

end

function wnd_gameEntrance:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_gameEntrance:refresh()
	self:updateScroll()
end

function wnd_gameEntrance:updateScroll()
	local widgets = self._layout.vars
	widgets.scroll:removeAllChildren()

	local activityInfo = self:getActivityInfo()
	for _, v in ipairs(activityInfo) do
		local item = require("ui/widgets/gnhdrkt")()
		item.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconID))
		item.vars.btn:onClick(self, self.onSelectActivity, v.id)
		item.vars.redPoint:hide()
		item.vars.not_open:setVisible(v.sortID >= SortOffset)
		widgets.scroll:addItem(item)
	end
end

function wnd_gameEntrance:getActivityInfo()
	local info = {}
	for id, v in ipairs(i3k_db_findMooncake) do
		if self:isShowEntrance(v.isShowIcon) then
			if g_i3k_db.i3k_db_get_findMooncake_is_open_by_id(id) then
				table.insert(info, {id = id, iconID = v.iconID, sortID = id})
			else
				table.insert(info, {id = id, iconID = v.iconID, sortID = id + SortOffset})
			end
		end
	end

	--大富翁
	local diceActivityID = g_i3k_db.i3k_db_open_dice_activity_id()
	local diceSortID = diceActivityID and DiceSortId or (DiceSortId + SortOffset)
	if self:isShowEntrance(i3k_db_dice_entrance_cfg.diceIconShow) then
		table.insert(info, {id = DiceID, iconID = DiceIconID, sortID = diceSortID})
	end

	table.sort(info, function(a, b)
		return a.sortID < b.sortID
	end)
	return info
end

--是否显示游戏入口
function wnd_gameEntrance:isShowEntrance(isShow)
	return isShow == 1
end

function wnd_gameEntrance:onSelectActivity(sender, id)
	if id == DiceID then
		self:openDiceUI()
	elseif id == KNIEF_SHOOTING_ID then
		g_i3k_logic:openKniefShootingUI(id)
	else
		self:openFindMooncakeUI(id)
	end
end

function wnd_gameEntrance:openFindMooncakeUI(id)
	local isOpen = g_i3k_db.i3k_db_get_findMooncake_is_open_by_id(id)
	if not isOpen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16405))
	elseif g_i3k_game_context:GetLevel() < i3k_db_findMooncake[id].openLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3205, i3k_db_findMooncake[id].openLevel))
	else
		local useCells = g_i3k_game_context:GetBagUseCell()
		local totalCells = g_i3k_game_context:GetBagSize()
		local leftCells = totalCells - useCells
		if leftCells < 2 then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16502))
		else
		i3k_sbean.findMooncake_start(id)
		end
	end
end

function wnd_gameEntrance:openDiceUI()
	g_i3k_logic:openDiceUI()
end

function wnd_create(layout)
	local wnd = wnd_gameEntrance.new();
		wnd:create(layout);
	return wnd;
end
