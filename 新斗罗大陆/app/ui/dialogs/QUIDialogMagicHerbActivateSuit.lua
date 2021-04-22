--
-- Author: Kumo.Wang
-- 仙品养成套装激活展示界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbActivateSuit = class("QUIDialogMagicHerbActivateSuit", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

QUIDialogMagicHerbActivateSuit.TAB_WEAR = "TAB_WEAR"
QUIDialogMagicHerbActivateSuit.TAB_NO_WEAR = "TAB_NO_WEAR"

function QUIDialogMagicHerbActivateSuit:ctor(options)
	local ccbFile = "ccb/Dialog_MagicHerb_taozhuangjihuo.ccbi"
	local callBack = {}
	QUIDialogMagicHerbActivateSuit.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	app.sound:playSound("hero_grow_up")
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

    if options then
		self._actorId = options.actorId
		self._suitSkill = options.suitSkill
		self._callback = options.callback
		self._magicHerbSuitConfig = options.magicHerbSuitConfig
	end

	self:_init()
end

function QUIDialogMagicHerbActivateSuit:viewDidAppear()
	QUIDialogMagicHerbActivateSuit.super.viewDidAppear(self)
end

function QUIDialogMagicHerbActivateSuit:viewWillDisappear()
	QUIDialogMagicHerbActivateSuit.super.viewWillDisappear(self)
end

function QUIDialogMagicHerbActivateSuit:_init()
	self._uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local minAptitude = 999
	local minBreedLevel = 1
	local typeName = ""
	for i = 1, 3, 1 do
		local magicHerbWearedInfo = self._uiHeroModel:getMagicHerbWearedInfoByPos(i)
		local sid = magicHerbWearedInfo.sid
		local node = self._ccbOwner["node_icon_"..i]
		if node then
			node:removeAllChildren()
			local box = QUIWidgetMagicHerbBox.new()
			box:setInfo(sid)
			node:addChild(box)
			node:setVisible(true)
		end
		local breedLevel = magicHerbWearedInfo.breedLevel or 0
		local maigcHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
		if maigcHerbItemInfo then
			local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(maigcHerbItemInfo.itemId)
			if magicHerbConfig and minAptitude > magicHerbConfig.aptitude then
				minAptitude = magicHerbConfig.aptitude
				typeName = magicHerbConfig.type_name
			end
		end
	end
	if self._magicHerbSuitConfig  then
		minBreedLevel = self._magicHerbSuitConfig.breed
		minAptitude= self._magicHerbSuitConfig.aptitude
	end

	local aptitude = remote.magicHerb:getAptitudeByAptitudeAndBreedLv(minAptitude,minBreedLevel)
	local aptitudeInfo = db:getSABCByQuality(aptitude)
	local skillConfig = db:getSkillByID(self._suitSkill)
	local add = ""
	if minBreedLevel > 0 and minBreedLevel < remote.magicHerb.BREED_LV_MAX then
		add= "+"..minBreedLevel
	end

	self._ccbOwner.tf_skillName:setString("【"..aptitudeInfo.qc..add.."级"..typeName.."】"..skillConfig.name.."：")
	self._ccbOwner.tf_skillDesc:setString(skillConfig.description)
end

function QUIDialogMagicHerbActivateSuit:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMagicHerbActivateSuit:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogMagicHerbActivateSuit:viewAnimationOutHandler()
	self:popSelf()

	if self._callback then
		self._callback(self._suitSkill)
	end
end

return QUIDialogMagicHerbActivateSuit