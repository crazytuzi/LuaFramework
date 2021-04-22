local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroBattleArrayFighterInfoCell = class("QUIWidgetHeroBattleArrayFighterInfoCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")

QUIWidgetHeroBattleArrayFighterInfoCell.EVENT_FIGHTRT_TEAM_CLICK = "EVENT_FIGHTRT_TEAM_CLICK"
QUIWidgetHeroBattleArrayFighterInfoCell.EVENT_FIGHTRT_INFO_CLICK = "EVENT_FIGHTRT_INFO_CLICK"

function QUIWidgetHeroBattleArrayFighterInfoCell:ctor(options)
	local ccbFile = "ccb/Widget_HeroBattleArray_FighterInfoCell.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTiggerClickTeam", callback = handler(self, self._onTiggerClickTeam)},
		{ccbCallbackName = "onTiggerClickInfo", callback = handler(self, self._onTiggerClickInfo)},
    }
    QUIWidgetHeroBattleArrayFighterInfoCell.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	q.setButtonEnableShadow(self._ccbOwner.btn_info)

end

function QUIWidgetHeroBattleArrayFighterInfoCell:onEnter()
end

function QUIWidgetHeroBattleArrayFighterInfoCell:onExit()
end

function QUIWidgetHeroBattleArrayFighterInfoCell:setInfo(fighterInfo, trialNum , strName)
	self._trialNum = trialNum
	self._fighterInfo = fighterInfo
	self._strName = strName
	self._ccbOwner.tf_title:setString(strName)

	local heroInfo = fighterInfo.heroes[1]
	
	if heroInfo then
		local heroHead =  QUIWidgetHeroHead.new()
		self._ccbOwner.node_head:addChild(heroHead)
		heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onTiggerClickInfo))
		heroHead:setHeroInfo(heroInfo)
	end

end

function QUIWidgetHeroBattleArrayFighterInfoCell:setButtonStated(stated)
	if stated then
		self:getView():setScale(1)
		self._ccbOwner.btn_team:setHighlighted(true)
		self._ccbOwner.btn_team:setEnabled(false)
		self._ccbOwner.sp_gray:setVisible(false)
	else
		self:getView():setScale(0.8)
		self._ccbOwner.btn_team:setHighlighted(false)
		self._ccbOwner.btn_team:setEnabled(true)
		self._ccbOwner.sp_gray:setVisible(true)
	end
end


function QUIWidgetHeroBattleArrayFighterInfoCell:getContentSize()
	local contentSize = self._ccbOwner.sp_bg:getContentSize()
	return CCSize(contentSize.width , contentSize.height)
end

function QUIWidgetHeroBattleArrayFighterInfoCell:_onTiggerClickTeam()
	self:dispatchEvent({name = QUIWidgetHeroBattleArrayFighterInfoCell.EVENT_FIGHTRT_TEAM_CLICK, trialNum = self._trialNum})
end

function QUIWidgetHeroBattleArrayFighterInfoCell:_onTiggerClickInfo()
	self:dispatchEvent({name = QUIWidgetHeroBattleArrayFighterInfoCell.EVENT_FIGHTRT_INFO_CLICK, trialNum = self._trialNum})
end


return QUIWidgetHeroBattleArrayFighterInfoCell
