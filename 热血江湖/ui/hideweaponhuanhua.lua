
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_hideWeaponHuanhua = i3k_class("wnd_hideWeaponHuanhua",ui.wnd_base)

local HIDEWEAPON_EFFECT = 
{
	[1] = {title = "解锁幻化主题", effect = "【%s】", keyName = "skinName"}, 
	[2] = {title = "技能增强", effect = "%s", keyName = "skinEffectText"}, 
	[3]	= {title = "属性提升", effect = "暗器命中加成：%s%%\n暗器识破加成：%s%%", keyName = "skinFightRate", keyName1 = "skinAgainstRate"}, 
}

function wnd_hideWeaponHuanhua:ctor()
	self._anqiID = nil
end

function wnd_hideWeaponHuanhua:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.jihuo_btn:onClick(self, self.onUnlock)
	widgets.markBtn:onClick(self, self.onChangeSkin)

	self.tipsUI = {}
	for i = 1, 3 do
		self.tipsUI[i] = {
			img = widgets["tipsImg" .. i],
			btn = widgets["tipsBtn" .. i],
		}
	end
end

function wnd_hideWeaponHuanhua:refresh(anqiID)
	self._anqiID = anqiID
	local skinID, skinCfg = self:getAnqiSkinCfg(anqiID)

	self:setSkinTips(skinCfg)
	self:setModule(skinCfg)
	self:setLabelText(skinCfg)
	self:setEffect(skinCfg)
	self:setBtnState(anqiID, skinID)
end

function wnd_hideWeaponHuanhua:getAnqiSkinCfg(anqiID)
	local skinIDTbl = g_i3k_db.i3k_db_get_anqi_skinID_by_anqiID(anqiID)
	local skinID = skinIDTbl[1]
	local skinCfg = g_i3k_db.i3k_db_get_anqi_skin_by_skinID(skinID)
	return skinID, skinCfg
end

function wnd_hideWeaponHuanhua:setSkinTips(skinCfg)
	local widgets = self._layout.vars
	for i, v in ipairs(self.tipsUI) do
		local skinTag = skinCfg.skinTag[i]
		if skinTag then
			v.img:setImage(g_i3k_db.i3k_db_get_icon_path(skinTag.imgID))
			local tipsPos = self:getTipsBtnPosition(v.btn)
			v.btn:onTouchEvent(self, self.onOpenSkinTips, {imgID = skinTag.imgID, desc = skinTag.desc, tipsPos = tipsPos})
		else
			v.img:hide()
		end
	end
end

function wnd_hideWeaponHuanhua:getTipsBtnPosition(btn)
	local btnSize = btn:getParent():getContentSize()
	local sectPos = btn:getPosition()
	local btnPos = btn:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_hideWeaponHuanhua:onOpenSkinTips(sender, eventType, data)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_HideWeaponHuanhuaTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeaponHuanhuaTips, data.imgID, data.desc, data.tipsPos)
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_HideWeaponHuanhuaTips)
		end
	end
end

function wnd_hideWeaponHuanhua:setModule(skinCfg)
	local widgets = self._layout.vars
	local modelID = skinCfg.skinModel
	local path = i3k_db_models[modelID].path
	local uiscale = i3k_db_models[modelID].uiscale
	widgets.hero_module:setSprite(path)
	widgets.hero_module:setSprSize(uiscale)
	widgets.hero_module:playAction("stand")
end

function wnd_hideWeaponHuanhua:setLabelText(skinCfg)
	local widgets = self._layout.vars
	widgets.battle_power:setText(skinCfg.fightPower)
	widgets.name:setText(skinCfg.skinName)
end

function wnd_hideWeaponHuanhua:setEffect(skinCfg)
	local scroll = self._layout.vars.effectScroll
	scroll:removeAllChildren()

	for _, v in ipairs(HIDEWEAPON_EFFECT) do
		local header = require("ui/widgets/anqihht1")()
		header.vars.desc:setText(v.title)
		scroll:addItem(header)

		local value1 = skinCfg[v.keyName]
		local desc = ""
		if v.keyName1 then  --识破和命中加成
			local value2 = skinCfg[v.keyName1]
			desc = string.format(v.effect, value1/100, value2/100)
		else
			desc = string.format(v.effect, value1)
		end

		local annText = require("ui/widgets/anqihht2")()
		annText.vars.sda:setText(desc)
		annText.vars.sda:setRichTextFormatedEventListener(function(sender)
			local nheight = annText.vars.sda:getInnerSize().height
			local tSizeH = annText.vars.sda:getSize().height

			if nheight > tSizeH then
				local size = annText.rootVar:getContentSize()
				annText.rootVar:changeSizeInScroll(scroll, size.width, size.height + nheight - tSizeH + 5, true)
		 	end
			annText.vars.sda:setRichTextFormatedEventListener(nil)
		end)
		scroll:addItem(annText)
	end
end

function wnd_hideWeaponHuanhua:setBtnState(anqiID, skinID)
	local widgets = self._layout.vars
	local skinLib = g_i3k_game_context:GetAnqiSkinLib(anqiID)
	local weaponData = g_i3k_game_context:getHideWeaponByID(anqiID)

	local isUnlock = skinLib[skinID]
	local isActivate = weaponData and (not isUnlock)
	widgets.jihuo_btn:setVisible(isActivate)
	widgets.jihuo_img:setVisible(isUnlock)

	local curSkinID = g_i3k_game_context:GetAnqiCurSkin(anqiID)
	widgets.markRoot:setVisible(skinLib[skinID])
	widgets.markImg:setVisible(curSkinID == skinID)
end

function wnd_hideWeaponHuanhua:onUnlock(sender)
	local anqiID = self._anqiID
	local skinID, skinCfg = self:getAnqiSkinCfg(anqiID)
	local cost = skinCfg.skinUnlockItem
	
	g_i3k_ui_mgr:OpenUI(eUIID_HideWeaponHuanhuaUnlock)
	g_i3k_ui_mgr:RefreshUI(eUIID_HideWeaponHuanhuaUnlock, anqiID, skinID, cost)
end

function wnd_hideWeaponHuanhua:onChangeSkin(sender)
	local anqiID = self._anqiID
	local skinID, skinCfg = self:getAnqiSkinCfg(anqiID)
	if self._layout.vars.markImg:isVisible() then
		skinID = 0  --使用原始模型
	end
	i3k_sbean.hideweapon_change_skin(anqiID, skinID)
end

function wnd_create(layout, ...)
	local wnd = wnd_hideWeaponHuanhua.new()
	wnd:create(layout, ...)
	return wnd;
end

