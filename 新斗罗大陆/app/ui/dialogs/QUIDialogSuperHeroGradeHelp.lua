-- 
-- zxs
-- ss升星玩法说明
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSuperHeroGradeHelp = class("QUIDialogSuperHeroGradeHelp", QUIDialog)
local QColorLabel = import("...utils.QColorLabel")

local DESC_TEXT = {
  "##eSS魂师升星消耗##lS级魂师碎片##e和##lSS魂师升星道具##e！",
	"##eSS+魂师升星消耗##lS级魂师碎片##e和##lSS魂师升星道具##e！",
}

function QUIDialogSuperHeroGradeHelp:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_wfsm.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerClickLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerClickRight)},
    }

    QUIDialogSuperHeroGradeHelp.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._helpPic = QResPath("super_hero_help_pic")
    self._maxNum = #self._helpPic
	
    if self._maxNum == 1 then
        self._ccbOwner.node_arrow:setVisible(false)
    end

	self._curIndex = options.index or 1
	self:updateShowImage()
end

function QUIDialogSuperHeroGradeHelp:updateShowImage()
    self._ccbOwner.tf_desc:setString("")
    self._ccbOwner.node_desc:removeAllChildren()

    local desc = DESC_TEXT[self._curIndex] or ""
    local text = QColorLabel:create(desc, 1000, nil, nil, 22, nil, nil, false, true)
    text:setAnchorPoint(ccp(0.5, 0.5))
    self._ccbOwner.node_desc:addChild(text)

	if self._helpPic[self._curIndex] then
		QSetDisplayFrameByPath(self._ccbOwner.sp_image, self._helpPic[self._curIndex])
	end
end

function QUIDialogSuperHeroGradeHelp:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSuperHeroGradeHelp:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSuperHeroGradeHelp:_onTriggerClickLeft()
  	app.sound:playSound("common_close")

  	self._curIndex = self._curIndex - 1
  	if self._curIndex < 1 then
  		self._curIndex = self._maxNum
  	end
	self:updateShowImage()
end

function QUIDialogSuperHeroGradeHelp:_onTriggerClickRight()
  	app.sound:playSound("common_close")
	self._curIndex = self._curIndex + 1
  	if self._curIndex > self._maxNum then
  		self._curIndex = 1
  	end
  	self:updateShowImage()
end

return QUIDialogSuperHeroGradeHelp
