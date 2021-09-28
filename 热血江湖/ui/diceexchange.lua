-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_diceExchange = i3k_class("wnd_diceExchange", ui.wnd_base)

function wnd_diceExchange:ctor()

end

function wnd_diceExchange:configure()

end

function wnd_diceExchange:onShow()

end

function wnd_diceExchange:refresh(groupID)
	self._groupID = groupID
	self:setUI(groupID)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dice, "updateDiceEventStatus", DICE_STATUS_DOING)
end


function wnd_diceExchange:getTaskID(groupID)
	local roleLevel = g_i3k_game_context:GetLevel()
	local index = 0
	for k, v in ipairs(i3k_db_dice_exchange) do
		if v.groupID == groupID then
			if v.level > roleLevel then
				return index
			else
				index = k
			end
		end
	end
	return index
end

function wnd_diceExchange:setUI(groupID)
	if not groupID then
		groupID = self._groupID
	end

	local id = self:getTaskID(groupID)
	local cfg = i3k_db_dice_exchange[id]
	self._cfg = cfg
	if not cfg then
		error("groupID:"..groupID..", id = "..id.." cfg not found")
	end
	local needs = {cfg.needs[1], cfg.needs[2]}
	self:setNeedItem(needs)

	local needDiamond = cfg.needs[3]
	self:setNeedDiamond(needDiamond)

	local gets = cfg.gets
	self:setGetScroll(gets)

	local widgets = self._layout.vars
	widgets.useItemBtn:onClick(self, self.onExchangeBtn, needs)
	widgets.diamondBtn:onClick(self, self.onUseDiamond, needDiamond)
	widgets.closeBtn:onClick(self, self.onCloseBtn, groupID)
	widgets.giveUpBtn:onClick(self, self.onGiveUpBtn, groupID)
	--
	widgets.descLabel:setText(i3k_get_string(16402))
end

function wnd_diceExchange:setNeedItem(cfg)
	local widgets = self._layout.vars
	widgets.needScroll:removeAllChildren()
	for k, v in ipairs(cfg) do
		local node = require("ui/widgets/dhwpt")()
		node.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, i3k_game_context:IsFemaleRole()))
		node.vars.lock:setVisible(v.id > 0)
		local itemCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		if itemCount < v.count then
			node.vars.count:setTextColor(g_i3k_get_hl_red_color())
		else
			node.vars.count:setTextColor(g_i3k_get_hl_green_color())
		end
		node.vars.count:setText(itemCount.."/"..v.count)
		node.vars.btn:onClick(self, self.onItemBtn, v.id)
		widgets.needScroll:addItem(node)
	end
end

function wnd_diceExchange:setNeedDiamond(cfg)
	local widgets = self._layout.vars
	widgets.diamondLock:setVisible(cfg.id > 0)
	widgets.diamondCount:setText(cfg.count)
end

function wnd_diceExchange:setGetScroll(cfg)
	local widgets = self._layout.vars
	widgets.getScroll:removeAllChildren()
	for k, v in ipairs(cfg) do
		local node = require("ui/widgets/dhwpt")()
		node.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, i3k_game_context:IsFemaleRole()))
		node.vars.lock:setVisible(v.id > 0)
		node.vars.count:setText(v.count)
		-- node.vars.count:setTextColor(g_i3k_get_white_color())-- 默认白色
		node.vars.btn:onClick(self, self.onItemBtn, v.id)
		widgets.getScroll:addItem(node)
	end
end


function wnd_diceExchange:onItemBtn(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

-- 使用道具兑换
function wnd_diceExchange:onExchangeBtn(sender, needs)
	-- 检查道具是否满足，背包是否满足
	local cfg = self._cfg
	local flag = true
	for k, v in ipairs(needs) do
		local itemCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		if itemCount < v.count then
			flag = false
		end
	end
	if not flag then
		g_i3k_ui_mgr:PopupTipMessage("道具数量不足")
		return
	end

	local gets = cfg.gets
	local isEnoughTable = {}
	for k, v in ipairs(gets) do
		isEnoughTable[v.id] = v.count
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if not isEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16390))
		return
	end

	local callback = function ()
		g_i3k_ui_mgr:CloseUI(eUIID_DiceExchange)
		for k, v in ipairs(needs) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_DICE_EXCHANGE)
		end
		g_i3k_ui_mgr:ShowGainItemInfo(gets)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dice, "updateDiceEventStatus", DICE_STATUS_FINISH)
	end


	local useDiamond = false
	local groupID = self._groupID
	i3k_sbean.finishDiceEvent(groupID, useDiamond, arg1, callback)
end

-- 使用元宝兑换
function wnd_diceExchange:onUseDiamond(sender, needItem)
	-- 检查元宝是否满足
	local cfg = self._cfg
	local itemCount = g_i3k_game_context:GetCommonItemCanUseCount(needItem.id)
	if itemCount < needItem.count then
		g_i3k_ui_mgr:PopupTipMessage("元宝数量不足")
		return
	end

	local gets = cfg.gets
	local isEnoughTable = {}
	for k, v in ipairs(gets) do
		isEnoughTable[v.id] = v.count
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if not isEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16390))
		return
	end

	local callback = function ()
		g_i3k_ui_mgr:CloseUI(eUIID_DiceExchange)
		g_i3k_game_context:UseCommonItem(needItem.id, needItem.count, AT_DICE_EXCHANGE)
		g_i3k_ui_mgr:ShowGainItemInfo(gets)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dice, "updateDiceEventStatus", DICE_STATUS_FINISH)
	end

	local useDiamond = true
	local groupID = self._groupID

	local msg = i3k_get_string(16401, needItem.count)
	local callback = function (ok)
		if ok then
			i3k_sbean.finishDiceEvent(groupID, useDiamond, arg1, callback)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
end

function wnd_diceExchange:onGiveUpBtn(sender, groupID)
	local msg = i3k_get_string(16396, "兑换任务")
	local callback = function (ok)
		if ok then
			i3k_sbean.giveUpDiceEvent(groupID)
			self:onCloseUI()
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
end

function wnd_diceExchange:onCloseBtn(sender, groupID)
	self:onCloseUI()
end




function wnd_create(layout, ...)
	local wnd = wnd_diceExchange.new()
	wnd:create(layout, ...)
	return wnd;
end
