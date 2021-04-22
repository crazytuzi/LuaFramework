--
-- Kumo.Wang
-- 時裝衣櫃主界面 -- 皮膚頭像按鈕菜單
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetFashionMainMenu = class("QUIWidgetFashionMainMenu", QUIWidget)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")

QUIWidgetFashionMainMenu.EVENT_CLICK = "QUIWIDGETFASHIONMAINMENU.EVENT_CLICK"

function QUIWidgetFashionMainMenu:ctor(options)
	local ccbFile = "Widget_Fashion_Menu.ccbi"
	local callBacks = {}
	QUIWidgetFashionMainMenu.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetFashionMainMenu:getInfo()
	return self._info
end

function QUIWidgetFashionMainMenu:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetFashionMainMenu:setInfo(info)
	self._info = info
	if not self._info then return end
	self:refreshInfo()
end

function QUIWidgetFashionMainMenu:refreshInfo()
	if not self._info then return end

	self._ccbOwner.node_head:removeAllChildren()
    local headBox = QUIWidgetHeroHead.new()
    headBox:setHeroSkinId(self._info.skins_id)
    headBox:setHero(self._info.character_id)
    headBox:setBreakthrough()
    headBox:setGodSkillShowLevel()
    self._ccbOwner.node_head:addChild(headBox)

    local isActivity = remote.fashion:checkSkinActivityBySkinId(self._info.skins_id)
    self:setUnActivite(not isActivity)
end

function QUIWidgetFashionMainMenu:setUnActivite(b)
	self._ccbOwner.node_unActivite:setVisible(b)
end

function QUIWidgetFashionMainMenu:setSelect(b)
	self._ccbOwner.node_selected:setVisible(b)
end

function QUIWidgetFashionMainMenu:onTriggerClick()
	self:dispatchEvent({name = QUIWidgetFashionMainMenu.EVENT_CLICK, info = self._info})
end

return QUIWidgetFashionMainMenu
