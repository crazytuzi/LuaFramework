-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_dragon_lucky = i3k_class("wnd_dragon_lucky", ui.wnd_base)

function wnd_dragon_lucky:ctor()
	self.totalLongyun = 0
	self.times = 0
end

function wnd_dragon_lucky:configure()
	local widgets = self._layout.vars
	widgets.normalSend:onClick(self, self.onDragonLucky, 0)
	widgets.superSend:onClick(self, self.onDragonLucky, 1)
	widgets.closeBtn:onClick(self, self.onClose)
	widgets.helpBtn:onClick(self, self.onHelp)
	self.longyunIcon = widgets.longyunIcon
	self.longyunBtn = widgets.longyunBtn
	self.longyunBtn:onTouchEvent(self, self.description)
end

function wnd_dragon_lucky:refresh(canUseDestiny, dayGiftTimes)
	self.longyunIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_dragon.dragonCfg.longyunIcon))
	self.times = i3k_db_faction_dragon.dragonCfg.longyunTimes - dayGiftTimes
	self.totalLongyun = canUseDestiny
	self:updataInfo(canUseDestiny, dayGiftTimes)
end

function wnd_dragon_lucky:updataInfo(canUseDestiny, dayGiftTimes)
	local widgets = self._layout.vars
	widgets.longyun1:setText(string.format("龙运消耗：%d", i3k_db_faction_dragon.dragonCfg.normalConsume))
	widgets.longyun2:setText(string.format("龙运消耗：%d", i3k_db_faction_dragon.dragonCfg.superConsume))
	widgets.totalLongyun:setText(string.format("%d", canUseDestiny))
	widgets.leftTimes:setText(string.format("剩余次数：%s", self.times))
	widgets.desc:setText(i3k_get_string(5494))
	local normalIcon = 
	{
		i3k_db_longyun_reward[1].itemId1,
		i3k_db_longyun_reward[1].itemId2,
		i3k_db_longyun_reward[1].itemId3,
		i3k_db_longyun_reward[1].itemId4,
	}
	local superIcon = 
	{
		i3k_db_longyun_reward[2].itemId1,
		i3k_db_longyun_reward[2].itemId2,
		i3k_db_longyun_reward[2].itemId3,
		i3k_db_longyun_reward[2].itemId4,
	}
	for k = 1, 4 do
		widgets["normalIcon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(normalIcon[k]))
		widgets["normalBg"..k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(normalIcon[k]))
		widgets["normalBtn"..k]:onClick(self, self.showItem, normalIcon[k])
		widgets["superIcon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(superIcon[k]))
		widgets["superBg"..k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(superIcon[k]))
		widgets["superBtn"..k]:onClick(self, self.showItem, superIcon[k])
	end
end

function wnd_dragon_lucky:onDragonLucky(sender, rewardType)
	local position = g_i3k_game_context:GetSectPosition()
	local needDragonLucky = rewardType == 0 and i3k_db_faction_dragon.dragonCfg.normalConsume or i3k_db_faction_dragon.dragonCfg.superConsume
	if g_i3k_game_context:GetLevel() < i3k_db_faction_dragon.dragonCfg.longyunLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16800, i3k_db_faction_dragon.dragonCfg.longyunLvl))
	elseif i3k_db_faction_power[position].dragonLucky == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16801))
	elseif self.times <= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16802))
	elseif self.totalLongyun < needDragonLucky then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16803))
	else
		i3k_sbean.send_destiny_reward(rewardType)
	end
end

function wnd_dragon_lucky:showItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_dragon_lucky:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_DragonLucky)
end

function wnd_dragon_lucky:description(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_NewTips, i3k_get_string(16764), self:getBtnPosition())
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
		end
	end
end

function wnd_dragon_lucky:getBtnPosition()
	local btnSize = self.longyunBtn:getParent():getContentSize()
	local sectPos = self.longyunBtn:getPosition()
	local btnPos = self.longyunBtn:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_dragon_lucky:onHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(16763, i3k_db_faction_dragon.dragonCfg.factionMaxNum))
end

function wnd_create(layout, ...)
	local wnd = wnd_dragon_lucky.new();
		wnd:create(layout, ...);
	return wnd;
end
