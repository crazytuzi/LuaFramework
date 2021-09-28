-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_lucky_star_gift = i3k_class("wnd_lucky_star_gift", ui.wnd_base)

local LAYER_MFITEM = "ui/widgets/xingyunxing"
local LAYER_SHENGDANKA = "ui/widgets/shengdanka"

function wnd_lucky_star_gift:ctor()
	
end

function wnd_lucky_star_gift:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_lucky_star_gift:refresh()
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	scroll:setBounceEnabled(false)
	local node = require(LAYER_MFITEM)()
	local vars = node.vars
	scroll:addItem(node)
	local card = require(LAYER_SHENGDANKA)()
	local card_vars = card.vars
	scroll:addItem(card)
	local lkData = g_i3k_game_context:GetLuckyStarData()
	--幸运星
	if lkData.dayRecvTimes > 0 then
		vars.state:setText(i3k_get_string(3038))
		vars.remainNum:setText(i3k_get_string(3039)..lkData.lastGiftTimes)
		self:ShowLuckyStarRewards(vars)
		if lkData.lastGiftTimes > 0 then
			vars.desc:setText(i3k_get_string(914))
		else
			vars.desc:setText(i3k_get_string(916))
		end
	else
		vars.desc2:hide()
		vars.remainNum:setText(i3k_get_string(3040))
		vars.state:setText(i3k_get_string(3041))
		vars.desc:setText(i3k_get_string(915))
		for i = 1 , 3 do
			vars["itemRoot"..i]:hide()
		end
	end
	--圣诞贺卡
	local openType = g_TYPE_Scan
	if g_i3k_checkIsInDateByStringTime(i3k_db_christmas_wish_cfg.startTime, i3k_db_christmas_wish_cfg.endTime) then
		openType = g_TYPE_Edit
	end
	local cardInfo = g_i3k_game_context:GetMyChristmasCardInfo()
	if cardInfo.wishUpdateTime > 0 then
		card_vars.time:setText(i3k_get_string(16936, g_i3k_get_YearAndDayTime(cardInfo.wishUpdateTime)))
		card_vars.btn:onClick(self, function()
			cardInfo.overview.roleName = g_i3k_game_context:GetRoleName()
			g_i3k_ui_mgr:OpenUI(eUIID_ChristmasWish)
			g_i3k_ui_mgr:RefreshUI(eUIID_ChristmasWish, cardInfo.wishUpdateTime, cardInfo.overview, openType)
		end)
	else
		card_vars.time:setText(i3k_get_string(16937))
		card_vars.btn:onClick(self, function()
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16937))
		end)
	end
	card_vars.brick_num:setText(string.format("x%s", cardInfo.overview.brick))
	card_vars.flower_num:setText(string.format("x%s", cardInfo.overview.flower))
end

function wnd_lucky_star_gift:ShowLuckyStarRewards(vars)
	local reward = g_i3k_game_context:GetLuckyStarDB()
	for i = 1 , 3 do
		if reward then
			local one = reward[i]
			if one.itemID ~= 0 then
				vars["itemRoot"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(one.itemID))
				vars["itemIcon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(one.itemID,i3k_game_context:IsFemaleRole()))
				vars["itemBtn"..i]:onTouchEvent(self,self.onTips,one.itemID)
				vars["itemCnt"..i]:setText("x"..i3k_get_num_to_show(one.count))
			else
				vars["itemRoot"..i]:hide()
			end
		else
			vars["itemRoot"..i]:hide()
			vars.desc2:hide()
		end
	end
end

function wnd_lucky_star_gift:onTips(sender, eventType,id)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:ShowCommonItemInfo(id)
	end
end

function wnd_create(layout)
	local wnd = wnd_lucky_star_gift.new()
		wnd:create(layout)
	return wnd
end
