-- modify by zhangbing 2019/02/14
-- eUIID_MartialSoulSkin
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/profile")

-------------------------------------------------------
wnd_martialSoulSkin = i3k_class("wnd_martialSoulSkin", ui.wnd_profile)
local WIDGET_WUHUNHHT2 = "ui/widgets/wuhunhh2t"
local ROW_ITEM_COUNT = 3

local STATE_CURSHOW	= 10 ^ 6 --正在使用
local STATE_CANUSE	= 10 ^ 5 -- 已拥有可使用
local STATE_CANLOCK = 10 ^ 4 --可解锁
local STATE_UNLOCK	= 10 ^ 3 --显示解锁按钮
local STATE_DEFAULT = 10 --默认

function wnd_martialSoulSkin:ctor()
	self._showType = 0 --列表类型：1基础，2追加
	self._showTypeButton = {}
	self._skinID = 0 --当前皮肤ID
	self._changeState = true --切换状态：false人物模型，true 只是武魂模型
	self._rankDesc = g_i3k_db.i3k_db_get_martialsoul_rank_desc()
end

function wnd_martialSoulSkin:configure()
	local widgets = self._layout.vars
	self._widget = {}

	-- 玩家设置皮肤显隐
	self._widget.isAtuoSkin = widgets.isAtuoSkin
	self._widget.isHideSkin = widgets.isHideSkin
	widgets.baseSkinRed:hide()
	widgets.isAtuoSkinBtn:onClick(self, self.IsAtuoSkin)
	widgets.isHideSkinBtn:onClick(self, self.IsHideSkin)
	-- 皮肤类型按钮
	self._showTypeButton = {widgets.baseSkinBtn, widgets.addSkinBtn}
	for i, e in ipairs(self._showTypeButton) do
		e:onClick(self, self.onTypeChanged, i)
	end
	-- 模型旋转 切换
	self.revolve = widgets.revolveBtn
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
	self.hero_module = widgets.hero_module
	self.changeBtn = widgets.changeBtn
	widgets.changeBtn:onClick(self, self.onChangeBtn)

	-- 功能按钮
	self._widget.useIcon = widgets.useIcon
	self._widget.funcBtn = widgets.funcBtn
	widgets.funcBtn:onClick(self, self.onFuncBtn)
	self._widget.funcTxt = widgets.funcTxt
	self._widget.funcRedPoint = widgets.funcRedPoint

	widgets.close:onClick(self, self.onCloseUI)

end

function wnd_martialSoulSkin:refresh()
	self._skinID = g_i3k_game_context:GetWeaponSoulCurShow()
	self:setShowType(g_MARTIALSOUL_BASE)
	self:loadSetUI()
	self:updateAddSkinRed()
	self:updateShowModel()
end

function wnd_martialSoulSkin:onTypeChanged(sender, showType)
	self:setShowType(showType)
end

function wnd_martialSoulSkin:setShowType(showType)
	if self._showType ~= showType then
		self._showType = showType
		for _, e in ipairs(self._showTypeButton) do
			e:stateToNormal()
		end
		self._showTypeButton[showType]:stateToPressed()
		self:loadSkinScroll()
	end
end

-- 排序
function wnd_martialSoulSkin:sortSkins(skinData)
	for _, e in ipairs(skinData) do
		local id = e.id
		local skinState = self:getSinkState(id)
		e.sortID = id - skinState
	end
	table.sort(skinData, function(a, b)
		return a.sortID < b.sortID
	end)
	return skinData
end


-- 皮肤列表
function wnd_martialSoulSkin:loadSkinScroll()
	self._layout.vars.skinScroll:removeAllChildren()
	local cfg = g_i3k_db.i3k_get_martialsoul_skin_by_type(self._showType)
	cfg = self:sortSkins(cfg)
	local nodes = self._layout.vars.skinScroll:addChildWithCount(WIDGET_WUHUNHHT2, ROW_ITEM_COUNT, #cfg)
	for i, e in ipairs(nodes) do
		self:updateCell(e.vars, cfg, i)
	end
end

-- 皮肤格子
function wnd_martialSoulSkin:updateCell(widget, cfg, idx)
	local skinCfg = cfg[idx]
	local skinID = skinCfg.id
	local skinState = self:getSinkState(skinID)
	widget.name:setText(skinCfg.data.name)
	widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(skinCfg.data.icon))
	widget.redPoint:setVisible(self._showType == g_MARTIALSOUL_ADD and g_i3k_game_context:isCanUnlockAddSkin(skinID))
	widget.iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(skinCfg.data.rank))
	if g_i3k_game_context:isHaveWeaponSoulSkin(skinID) then
		widget.root:enableWithChildren()
	else
		widget.root:disableWithChildren()
	end
	widget.equipingIcon:setVisible(skinState == STATE_CURSHOW)
	widget.desc:setText(self:getBaseSkinDesc(skinID))
	widget.selectBtn:onClick(self, self.onSelectMartialSoul, skinID)
end

function wnd_martialSoulSkin:onSelectMartialSoul(sender, skinID)
	if self._skinID ~= skinID then
		self._skinID = skinID
		self:updateShowModel()
	end
end

function wnd_martialSoulSkin:getBaseSkinDesc(skinID)
	local descTxt
	local skinCfg = i3k_db_martial_soul_display[skinID]
	if skinCfg.diaplayType == g_MARTIALSOUL_BASE and skinID ~= 1 and not g_i3k_game_context:isHaveWeaponSoulSkin(skinID) then
		descTxt = i3k_get_string(1069, self._rankDesc[skinID].rankName)
	end
	return descTxt
end

-- 追加外显红点
function wnd_martialSoulSkin:updateAddSkinRed()
	self._layout.vars.addSkinRed:setVisible(g_i3k_game_context:isShowAddSkinRed())
end

-- 人物模型
function wnd_martialSoulSkin:loadHeroModule()
	self.hero_module.martialSkinID = self._skinID
	ui_set_hero_model(self.hero_module, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(), g_i3k_game_context:getIsShowArmor())
end

-- 显示武魂模型
function wnd_martialSoulSkin:loadMartialSoulModel()
	local skinCfg = i3k_db_martial_soul_display[self._skinID]
	local mcfg = i3k_db_models[skinCfg.modelID]
	if mcfg then
		self.hero_module:setSprite(mcfg.path)
		self.hero_module:setSprSize(mcfg.uiscale)
		self.hero_module:playAction("show")
		self.hero_module:setColor(tonumber(mcfg.color, 16) or 0xFFFFFFF)
	end
end

function wnd_martialSoulSkin:onChangeBtn(sender)
	self._changeState = not self._changeState
	self:updateShowModel()
end

function wnd_martialSoulSkin:updateShowModel()
	self.changeBtn:setImage(g_i3k_db.i3k_db_get_icon_path(self._changeState and 8483 or 8482))
	if self._changeState then
		self.revolve:disable() --武魂模型状态 不可旋转
		self:loadMartialSoulModel()
	else
		self.revolve:enable()
		self:loadHeroModule()
	end
	self:updateFuncBtn()
end

--通过皮肤ID获取状态
function wnd_martialSoulSkin:getSinkState(skinID)
	local curShow =  g_i3k_game_context:GetWeaponSoulCurShow()
	if curShow == skinID then
		return STATE_CURSHOW
	end
	-- 使用
	if g_i3k_game_context:isHaveWeaponSoulSkin(skinID) and curShow ~= skinID then
		return STATE_CANUSE
	end
	-- 解锁
	local skinCfg = i3k_db_martial_soul_display[skinID]
	if skinCfg.diaplayType == g_MARTIALSOUL_ADD and skinCfg.needItemID > 0 then
		if g_i3k_game_context:isCanUnlockAddSkin(skinID) then
			return STATE_CANLOCK
		else
			return STATE_UNLOCK
		end
	end
	return STATE_DEFAULT
end

local descTable = {
	[STATE_CANUSE] = 1290,
	[STATE_UNLOCK] = 451,
	[STATE_CANLOCK] = 451,
}
-- 功能按钮
function wnd_martialSoulSkin:updateFuncBtn()
	local skinState = self:getSinkState(self._skinID)
	local desc = self:getBaseSkinDesc(self._skinID) --基础皮肤描述
	self._widget.useIcon:setVisible(skinState == STATE_CURSHOW)
	self._widget.funcBtn:setVisible(skinState ~= STATE_CURSHOW)
	local skinCfg = i3k_db_martial_soul_display[self._skinID]
	self._widget.funcRedPoint:setVisible(skinCfg.diaplayType == g_MARTIALSOUL_ADD and g_i3k_game_context:isCanUnlockAddSkin(self._skinID))
	self._widget.funcTxt:setText(descTable[skinState] and i3k_get_string(descTable[skinState]) or desc)
	if desc then
		self._widget.funcBtn:disableWithChildren()
	else
		self._widget.funcBtn:enableWithChildren()
	end
end

function wnd_martialSoulSkin:onFuncBtn(sender)
	local skinState = self:getSinkState(self._skinID)
	if skinState == STATE_CANUSE then
		i3k_sbean.weaponSoulShowSet(self._skinID)
		return
	end
	local skinCfg = i3k_db_martial_soul_display[self._skinID]
	if skinState == STATE_UNLOCK or skinState == STATE_CANLOCK then
		g_i3k_ui_mgr:OpenUI(eUIID_MartialSoulSkinUnlock)
		g_i3k_ui_mgr:RefreshUI(eUIID_MartialSoulSkinUnlock, {id = self._skinID, data = skinCfg})
	end
end

-- 设置
function wnd_martialSoulSkin:loadSetUI()
	self._widget.isAtuoSkin:setVisible(g_i3k_game_context:GetAutoChangeShow())
	self._widget.isHideSkin:setVisible(not g_i3k_game_context:GetWeaponSoulCurHide())
end

-- 自动设置皮肤
function wnd_martialSoulSkin:IsAtuoSkin(sender)
	local autoChange = g_i3k_game_context:GetAutoChangeShow()
	if autoChange then
		sender:stateToNormal()		
	else
		sender:stateToPressed()
	end
	self._widget.isAtuoSkin:setVisible(not autoChange)
	i3k_sbean.weaponSoulShowAuto(autoChange and 0 or 1)
end

-- 隐藏皮肤外显设置
function wnd_martialSoulSkin:IsHideSkin(sender)
	if g_i3k_game_context:IsInMissionMode() or g_i3k_game_context:IsInSuperMode() or g_i3k_game_context:isInvisible() or g_i3k_game_context:IsOnRide() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1109))
	end
	local isHide = g_i3k_game_context:GetWeaponSoulCurHide()
	if isHide then
		sender:stateToPressed()
	else
		sender:stateToNormal()
	end
	self._widget.isHideSkin:setVisible(isHide)
	i3k_sbean.weaponSoulHide(isHide and 1 or 0)
end

function wnd_create(layout)
	local wnd = wnd_martialSoulSkin.new();
		wnd:create(layout);
	return wnd;
end
