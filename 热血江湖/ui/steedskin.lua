-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_steed_skin = i3k_class("wnd_steed_skin",ui.wnd_base)

local ZQPFT_WIDGET = "ui/widgets/zqpft"
local RowitemCount = 4
local TRADITION_SKIN = 1 --传统皮肤
local ADDITIONAL_SKIN = 2 --追加皮肤

function wnd_steed_skin:ctor()
	self._showType = 0 --1传统皮肤 2追加皮肤 
end

function wnd_steed_skin:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	
	self.skinName = widgets.skinName
	self.attrBtn = widgets.attrBtn
	self.haveSkin = widgets.haveSkin
	self.additionalBtn = widgets.additionalBtn
	self.horseModule = widgets.horseModule
	self.typeButton = {widgets.haveSkin, widgets.additionalBtn}
	self.typeButton[1]:stateToPressed(true)
	for i, e in ipairs(self.typeButton) do
		e:onClick(self, self.onShowTypeChanged, i)
	end
	self.scroll = widgets.scroll
	widgets.restoreBtn:onClick(self, self.onRestroeBtn)
	widgets.attrBtn:onTouchEvent(self, self.onPropertyBtn)
	widgets.steedBtn:onClick(self, self.onSteedBtn)
	widgets.steedBtn:stateToNormal()
	widgets.steedSkinBtn:stateToPressed()
	self.steed_point = widgets.steed_point
	self.steedSkinPoint = widgets.steedSkinPoint
	widgets.helpBtn:onClick(self, function ()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(15531))
	end)
	self.fightRedPoint = widgets.fightRedPoint
	if g_i3k_game_context:GetLevel() >= i3k_db_steed_fight_base.openLvl then
		widgets.steedFightBtn:show():onClick(self, self.onFightBtn)
	else
		widgets.steedFightBtn:hide()
	end
	self.awardBtn = widgets.awardBtn
	widgets.awardBtn:onClick(self, self.onAwardBtn)
end

function wnd_steed_skin:refresh()
	self._showType = 0
	self:onTypeChanged(TRADITION_SKIN)
	self:updateSteedNotice()
	self:loadModuleAndName(g_i3k_game_context:getSteedCurShowID())
	self.awardBtn:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_steed_fight_base.openLvl)
end

function wnd_steed_skin:loadModuleAndName(showID)
	local cfg = i3k_db_steed_huanhua[showID]
	self.skinName:setText(cfg.name)
	ui_set_hero_model(self.horseModule, cfg.modelId)
	self.horseModule:playAction("show")
	if cfg.modelRotation ~= 0 then
		self.horseModule:setRotation(cfg.modelRotation)
	end
end

function wnd_steed_skin:onShowTypeChanged(sender, sbowType)
	self:onTypeChanged(sbowType)
end

function wnd_steed_skin:onTypeChanged(showType)
	if self._showType ~= showType then
		self._showType = showType
		self:updateTypeBtnState()
		self:updateScroll()
		self.scroll:jumpToListPercent(0)
	end
end

function wnd_steed_skin:updateTypeBtnState()
	for i, e in ipairs(self.typeButton) do
		e:stateToNormal(true)
	end
	self.typeButton[self._showType]:stateToPressed(true)
end

function wnd_steed_skin:updateScroll()
	self.scroll:removeAllChildren()
	local items = self:getSkinInfoFromType()
	local skinItem = self:sortSkin(items)
	local fightData = g_i3k_game_context:getSteedFightShowIDs()
	local allWidgets = self.scroll:addChildWithCount(ZQPFT_WIDGET, RowitemCount, #items)
	for i, e in ipairs(skinItem) do
		local widget = allWidgets[i].vars
		local cfg = i3k_db_steed_huanhua[e.id]
		widget.id = e.id
		self:updateCell(widget, cfg, fightData[e.id])
	end
end

function wnd_steed_skin:getSkinInfoFromType()
	local steedShowIDs = g_i3k_game_context:getSteedShowIDs()
	local data = {}
	local showType = self._showType == TRADITION_SKIN and g_HS_TRADITIONAL or g_HS_ADDITIONAL
	for k, v in pairs(i3k_db_steed_huanhua) do
		if showType == v.skinType and v.isOpen ~= 0 then
			if v.skinType == g_HS_TRADITIONAL then --显示拥有的传统皮肤
				if steedShowIDs[k] then
					table.insert(data, k)
				end
			else
				table.insert(data, k)
			end
		end
	end
	return data
end

-- 排序
function wnd_steed_skin:sortSkin(sort_items)
	local tmp = {}
	local steedShowIDs = g_i3k_game_context:getSteedShowIDs()
	for _, e in ipairs(sort_items) do
		local cfg = i3k_db_steed_huanhua[e]
		local order = e
		local isUse = g_i3k_game_context:getSteedCurShowID() == e
		local isCanActivate = false
		if cfg.skinType == g_HS_ADDITIONAL then
			isCanActivate = cfg.actNeedId > 0 and g_i3k_game_context:GetCommonItemCanUseCount(cfg.actNeedId) >= cfg.needCount or false
		end
		local isHave = false
		if steedShowIDs[e] then
			isHave = steedShowIDs[e] == -1 or steedShowIDs[e] > i3k_game_get_time()
		end
		if isUse then --使用中
			order = order + 300000
		elseif isCanActivate then --可激活
			order = order + 200000
		elseif isHave then --拥有
			order = order + 100000
		elseif cfg.rideNum > 1 then --可骑乘人数
			order = order + 50000
		end
		table.insert(tmp, {id = e, order = order})
	end
	table.sort(tmp, function (a,b)
		return a.order > b.order
	end)
	return tmp
end

--填充格子信息
function wnd_steed_skin:updateCell(widget, cfg, isActivateFight)
	local showIDs = g_i3k_game_context:getSteedShowIDs()
	widget.skinName:setText(cfg.name)
	widget.skinIcon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.steedRankIconId))
	widget.isMulIcon:setVisible(cfg.rideNum > 1)
	local isShowFightIcon = cfg.fightSkinType == g_HS_SKIN_FIGHT and g_i3k_game_context:GetLevel() >= i3k_db_steed_fight_base.openLvl
	widget.fightIcon:setVisible(isShowFightIcon)
	if isShowFightIcon then
		if isActivateFight then
			widget.fightIcon:enableWithChildren()
		else
			widget.fightIcon:disableWithChildren()
		end
	end
	local isCanActivate = false
	if cfg.skinType ~= g_HS_TRADITIONAL and cfg.actNeedId ~= 0 and not showIDs[cfg.id] then --是追加皮肤
		isCanActivate = g_i3k_game_context:GetCommonItemCanUseCount(cfg.actNeedId) >= cfg.needCount
	end
	widget.canActivate:setVisible(isCanActivate) --可激活
	if showIDs[cfg.id] then
		if showIDs[cfg.id] > i3k_game_get_time() or showIDs[cfg.id] == -1 then
			widget.skinRoot:enableWithChildren()
		else
			widget.skinRoot:disableWithChildren()
		end
	else
		widget.skinRoot:disableWithChildren()
	end
	widget.isUse:setVisible(cfg.id == g_i3k_game_context:getSteedCurShowID())
	widget.skinBtn:onClick(self, self.onSkinTips, cfg)
end

function wnd_steed_skin:updateSteedFightIconState(showID)
	local allWigets = self.scroll:getAllChildren()
	for i, e in ipairs(allWigets) do
		if e.vars.id == showID then
			e.vars.fightIcon:enableWithChildren()
		end
	end
end

--还原
function wnd_steed_skin:onRestroeBtn(sender)
	self:loadModuleAndName(g_i3k_game_context:getSteedCurShowID())
end

function wnd_steed_skin:onSkinTips(sender, cfg)
	self:loadModuleAndName(cfg.id)
	g_i3k_ui_mgr:OpenUI(eUIID_SteedSkinTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_SteedSkinTips, cfg)
end

function wnd_steed_skin:onPropertyBtn(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_SteedSkinProperty)
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedSkinProperty)
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_SteedSkinProperty)
		end
	end
end

function wnd_steed_skin:onFightBtn(sender)
	if g_i3k_game_context:getIsUnlockSteedSpirit() then -- 达到良驹之灵开启等级默认打开良驹之灵
		g_i3k_logic:OpenSteedSpriteUI()
		self:onCloseUI()
	else
	if g_i3k_game_context:getUseSteed() ~= 0 then
		if g_i3k_game_context:getSteedFightShowCount() ~= 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_SteedFight)
			g_i3k_ui_mgr:RefreshUI(eUIID_SteedFight)
			self:onCloseUI()
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1258))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15530))
		end
	end
end

function wnd_steed_skin:onSteedBtn(sender)
	g_i3k_logic:OpenSteedUI()
	self:onCloseUI()
end

function wnd_steed_skin:updateSteedNotice()
	self.steed_point:setVisible(g_i3k_game_context:canBetterSteed() or g_i3k_game_context:canAddBook())
	self.fightRedPoint:setVisible(g_i3k_game_context:getIsShowSteedFightRed())
end

function wnd_steed_skin:onAwardBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SteedFightAwardProp)
	g_i3k_ui_mgr:RefreshUI(eUIID_SteedFightAwardProp)
end

function wnd_create(layout)
	local wnd = wnd_steed_skin.new()
	wnd:create(layout)
	return wnd
end
