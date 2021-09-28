-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_cardPacket = i3k_class("wnd_cardPacket", ui.wnd_base)

-- 图鉴界面
-- [eUIID_CardPacket]	= {name = "cardPacket", layout = "tujian", order = eUIO_TOP_MOST,},
-------------------------------------------------------

local STATE_CHALLENAGE = 1 -- 成就
local STATE_FAME = 2 -- 名声
local STATE_ADV = 3 -- 奇缘
function wnd_cardPacket:ctor()

end

function wnd_cardPacket:configure()
	self._selectCard = nil
	self._DEFAULT_SELECT = 1
	self:setButtons()
end

function wnd_cardPacket:refresh(state)
	self._oldState = state -- 对应dailyTask中的state
	self:setScrolls()
	self:onTypeChanged(nil, self._DEFAULT_SELECT)
	self:updateRightRedPoint()
	self:updateCardBackRed()
end

function wnd_cardPacket:onUpdate(dTime)

end


function wnd_cardPacket:setButtons()
	local widgets = self._layout.vars
	widgets.cardBack:onClick(self, self.oncardBackBtn)
	widgets.close:onClick(self, self.oncloseBtn)
	widgets.cardColl:setText(i3k_get_string(50111))
	widgets.challengeBtn:onClick(self, self.onChangeToDailyTask, STATE_CHALLENAGE)
	widgets.fame_btn:onClick(self, self.onChangeToDailyTask, STATE_FAME)
	widgets.advtBtn:onClick(self, self.onChangeToDailyTask, STATE_ADV)
	widgets.outcastBtn:stateToPressed()
end
-- 道具解锁
function wnd_cardPacket:setShowItemLock(bValue)
	local widgets = self._layout.vars
	widgets.itemRoot1:setVisible(bValue)
	widgets.itemRoot2:setVisible(bValue)
	if not bValue then
		self._selectCard = nil
	end
end
function wnd_cardPacket:setItemUnlock(id, count)
	local widgets = self._layout.vars
	widgets.cover:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widgets.itemName:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	widgets.itemName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	local have = g_i3k_game_context:GetCommonItemCanUseCount(id)
	widgets.itemCount:setTextColor(g_i3k_get_cond_color(have >= count))
	local itemEnough = have >= count
	widgets.itemCount:setText("x"..count)
	widgets.itemBtn:onClick(self, self.onItem, id)
	widgets.itemUnlock:onClick(self, self.onUnlockItem)
	widgets.itemUnlock:setVisible(itemEnough)
	widgets.condTxt:setVisible(not itemEnough)
end
function wnd_cardPacket:setItemUnlockDesc(cardID)
	local widgets = self._layout.vars
	local text = g_i3k_db.i3k_db_cardPacket_get_unlock_desc(cardID)
	widgets.condTxt:setText(text)
end
function wnd_cardPacket:onUnlockItem(sender)
	local cardID = self._selectCard
	local cfg = g_i3k_db.i3k_db_cardPacket_get_card_cfg(cardID)
	local itemID = cfg.args[1]
	local needItems = 
	{
		{id = cfg.args[1], count = cfg.args[2]},
	}
	i3k_sbean.useCardItem(cardID, needItems, itemID)
end
function wnd_cardPacket:onItem(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_cardPacket:oncardBackBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_CardPacketBack)
	g_i3k_ui_mgr:RefreshUI(eUIID_CardPacketBack)
end

function wnd_cardPacket:oncloseBtn(sender)
	self:onCloseUI()
end


function wnd_cardPacket:setScrolls()
	local widgets = self._layout.vars
	self:setScroll_scrollLeft( i3k_db_cardPacket.types )
end


function wnd_cardPacket:setScroll_scrollLeft(list)
	local widgets = self._layout.vars
	local scroll = widgets.scrollLeft
	scroll:removeAllChildren()
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/tujiant")()
		ui.vars.btn:onClick(self, self.onTypeChanged, k)
		-- ui.vars.icon:setImage()
		ui.vars.name:setText(i3k_get_string(v.id))
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.image))
		ui.vars.lock:setVisible(false) -- TODO
		local red = g_i3k_game_context:getCardPackeSheetRed(k)
		ui.vars.red:setVisible(red)
		scroll:addItem(ui)
	end
end


function wnd_cardPacket:setScroll_scrollRight(list)
	local widgets = self._layout.vars
	local scroll = widgets.scrollRight
	scroll:removeAllChildren()
	local unlockCount = 0
	local firstUnlockCard = nil
	local firstUnlockCardCfg = nil

	widgets.nocards:setText(i3k_get_string(18275))
	widgets.nocards:setVisible(#list == 0)
	local children = scroll:addChildWithCount("ui/widgets/tujiant2", 4, #list)
	for i,v in ipairs(children) do
		local cfg = list[i]
		v.vars.name:setText(cfg.name)
		v.vars.image:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imageID))
		v.vars.red:hide()
		v.vars.back:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.coverImageID))
		local isUnlocked = g_i3k_game_context:getCardUnlock(cfg.id)
		v._cardID = cfg.id
		if not isUnlocked then
			if not firstUnlockCard then
				firstUnlockCard = i
				firstUnlockCardCfg = cfg
			end
			v.vars.image:disable() -- TODO 萌灰
			v.vars.back:disable()
			local canUnlock = g_i3k_game_context:checkCardPacketCanUnlock(cfg)
			v.vars.red:setVisible(canUnlock)
		else
			unlockCount = unlockCount + 1
		end
		v.vars.btn:onClick(self, self.onCard, i)
	end
	widgets.count:setText(unlockCount)
	if firstUnlockCard then
		self:onCardSelect(firstUnlockCardCfg)
	end
end

function wnd_cardPacket:onTypeChanged(sender, id)
	self:setShowItemLock(false)
	self._groupID = id -- 组id
	self._DEFAULT_SELECT = id
	local cfg = i3k_db_cardPacket_card[id] or {}
	self:setScroll_scrollRight( cfg )

	local widgets = self._layout.vars
	local scroll = widgets.scrollLeft
	local children = scroll:getAllChildren()
	for k, v in ipairs(children) do
		if id == k then
			v.vars.btn:stateToPressed()
		else
			v.vars.btn:stateToNormal()
		end
	end
end

function wnd_cardPacket:onCardSelect(cfg)
	local cardID = cfg.id
	self._selectCard = cardID
	local widgets = self._layout.vars
	local scroll = widgets.scrollRight
	local children = scroll:getAllChildren()
	for k, v in ipairs(children) do
		v.vars.selected:setVisible(v._cardID == cardID)
	end
	local isItemUnlock = cfg.type == g_CARD_PACKET.UNLOCK_TYPE_ITEM
	local isUnlocked = g_i3k_game_context:getCardUnlock(cfg.id)
	if isItemUnlock and not isUnlocked then
		self:setItemUnlock(cfg.args[1], cfg.args[2])
		self:setShowItemLock(isItemUnlock)
	end
	self:setItemUnlockDesc(cfg.id)
	if isItemUnlock then
		widgets.itemRoot2:setVisible(false)
		widgets.itemRoot1:setVisible(true)
	else
		widgets.itemRoot2:setVisible(true)
		widgets.itemRoot1:setVisible(false)
	end
	if isUnlocked then
		-- hide all 
		self:setShowItemLock(false)
	end
end
function wnd_cardPacket:onCard(sender, id)
	local groupID = self._groupID
	local cfg = i3k_db_cardPacket_card[groupID][id]
	-- 如果解锁了
	local isUnlocked = g_i3k_game_context:getCardUnlock(cfg.id)
	if isUnlocked then
		g_i3k_ui_mgr:OpenUI(eUIID_CardPacketDesc)
		g_i3k_ui_mgr:RefreshUI(eUIID_CardPacketDesc, cfg.id)
	else
		-- g_i3k_ui_mgr:OpenUI(eUIID_CardPacketShow)
		-- g_i3k_ui_mgr:RefreshUI(eUIID_CardPacketShow, cfg.id)
	end
	self:onCardSelect(cfg)
end


--右侧红点  TODO 
function wnd_cardPacket:updateRightRedPoint()
	local widgets = self._layout.vars
	for k,v in pairs (g_i3k_game_context:getDailyTaskRedPoint()) do
		if k == G_NOTICE_TYPE_CAN_REWARD_CHALLENGE_TASK and v then
			widgets.red_point2:show()
		end
		if k == g_NOTICE_TYPE_CAN_FAME and v then
			widgets.red_point3:show()
		end
	end
	widgets.red_point5:setVisible(g_i3k_game_context:getCardPacketRed())
end
function wnd_cardPacket:onChangeToDailyTask(sender, state)
	g_i3k_logic:OpenDailyTask(state)
end
function wnd_cardPacket:updateCardBackRed()
	local widgets = self._layout.vars
	local red = widgets.redBack
	local backRed = g_i3k_game_context:getCardPacketBackRed()
	red:setVisible(backRed)
end
function wnd_create(layout, ...)
	local wnd = wnd_cardPacket.new()
	wnd:create(layout, ...)
	return wnd;
end
