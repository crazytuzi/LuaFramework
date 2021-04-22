--
-- Author: Your Name
-- Date: 2015-01-17 11:36:24
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogNightmareFigterInfo = class("QUIDialogNightmareFigterInfo", QUIDialog)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 

function QUIDialogNightmareFigterInfo:ctor(options)
 	local ccbFile = "ccb/Dialog_Nightmare_prompt.ccbi"
    local callBacks = {}
    QUIDialogNightmareFigterInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self.info = options.info
    if self.info == nil then assert(false,"the dialog options info can't is nil") end

    -- self._ccbOwner.count_text:setString(self.info.text or "")
    if self.info.text == "" then
        -- self._ccbOwner.tf_win_count:setVisible(false)
        self._ccbOwner.tf_battleforce:setPositionY(self._ccbOwner.tf_battleforce:getPositionY() + 20)
        self._ccbOwner.tf_force_name:setPositionY(self._ccbOwner.tf_force_name:getPositionY() + 20)
        self._ccbOwner.tf_uion:setPositionY(self._ccbOwner.tf_uion:getPositionY()+9)
        self._ccbOwner.tf_uion_name:setPositionY(self._ccbOwner.tf_uion_name:getPositionY()+9)
    else
        -- self._ccbOwner.tf_win_count:setString(self.info.number or 0)
    end
    self._ccbOwner.tf_force_name:setString("上阵总战力：")
    self._ccbOwner.vip:setString("VIP  " .. tostring(self.info.vip or 0))
    self._ccbOwner.tf_name:setString(self.info.name or "")
    self._ccbOwner.tf_level:setString("LV."..(self.info.level or 0))
    -- self._ccbOwner.tf_win_count:setPositionX(self._ccbOwner.count_text:getPositionX() + self._ccbOwner.count_text:getContentSize().width + 10)
    self._ccbOwner.tf_uion:setString(self.info.consortiaName or "无")

	self.head = QUIWidgetAvatar.new(self.info.avatar)
    self.head:setSilvesArenaPeak(self.info.championCount)
    self._ccbOwner.node_head:addChild(self.head)

    self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
    self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

    self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {sensitiveDistance = 10})
    self._scrollView:replaceGradient(self._ccbOwner.top_shadow, self._ccbOwner.bottom_shadow, nil, nil)
    -- self._scrollView:setVerticalBounce(false)
    self._scrollView:setVerticalBounce(true)
    -- self._scrollView:setGradient(true)
    local index = 1
    local lineDistance = 10
    local rowDistance = 8
    local line = 1
    local row = 1
    local offsetY = 20
    local totalHeight = 0
    local totalWidth = 0

    local forceCount = 0
    for index, value in ipairs(self.info.heros) do
        forceCount = forceCount + (value.force or 0)
    	local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHeroSkinId(value.skinId)
		heroHead:setHero(value.actorId)
		heroHead:setLevel(value.level)
		heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
		heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setHeadScale(0.8)
        heroHead:setTeam(1)

        self._contentSize = heroHead:getHeroHeadSize()
        local positionX = (((self._contentSize.width + lineDistance) * (line - 1)) ) + self._contentSize.width/2
        local positionY = -(((self._contentSize.height + rowDistance) * (row - 1)) ) - self._contentSize.height/2 - offsetY
        heroHead:setPosition(ccp(positionX, positionY))
        self._scrollView:addItemBox(heroHead)

        local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
        local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)

        line = line + 1
        if line > 4 then
            line = 1
            row = row + 1
            totalHeight = totalHeight + self._contentSize.height + rowDistance
        end
        totalWidth = (self._contentSize.width + lineDistance) * 4 - self._contentSize.width/2
    end

    for index, value in ipairs(self.info.subheros or {}) do
        forceCount = forceCount + (value.force or 0)
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHeroSkinId(value.skinId)
        heroHead:setHero(value.actorId)
        heroHead:setLevel(value.level)
        heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
        heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setHeadScale(0.8)
        heroHead:setTeam(2)

        self._contentSize = heroHead:getHeroHeadSize()
        local positionX = (((self._contentSize.width + lineDistance) * (line - 1)) ) + self._contentSize.width/2
        local positionY = -(((self._contentSize.height + rowDistance) * (row - 1)) ) - self._contentSize.height/2 - offsetY
        heroHead:setPosition(ccp(positionX, positionY))
        self._scrollView:addItemBox(heroHead)

        local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
         local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)

        line = line + 1
        if line > 4 then
            line = 1
            row = row + 1
            totalHeight = totalHeight + self._contentSize.height + rowDistance
        end
    end

    for index, value in ipairs(self.info.sub2heros or {}) do
        forceCount = forceCount + (value.force or 0)
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHeroSkinId(value.skinId)
        heroHead:setHero(value.actorId)
        heroHead:setLevel(value.level)
        heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
        heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setHeadScale(0.8)
        heroHead:setTeam(2)

        self._contentSize = heroHead:getHeroHeadSize()
        local positionX = (((self._contentSize.width + lineDistance) * (line - 1)) ) + self._contentSize.width/2
        local positionY = -(((self._contentSize.height + rowDistance) * (row - 1)) ) - self._contentSize.height/2 - offsetY
        heroHead:setPosition(ccp(positionX, positionY))
        self._scrollView:addItemBox(heroHead)

        local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
         local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)

        line = line + 1
        if line > 4 then
            line = 1
            row = row + 1
            totalHeight = totalHeight + self._contentSize.height + rowDistance + offsetY
        end
    end

    for index, value in ipairs(self.info.sub3heros or {}) do
        forceCount = forceCount + (value.force or 0)
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHeroSkinId(value.skinId)
        heroHead:setHero(value.actorId)
        heroHead:setLevel(value.level)
        heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
        heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setHeadScale(0.8)
        heroHead:setTeam(2)

        self._contentSize = heroHead:getHeroHeadSize()
        local positionX = (((self._contentSize.width + lineDistance) * (line - 1)) ) + self._contentSize.width/2
        local positionY = -(((self._contentSize.height + rowDistance) * (row - 1)) ) - self._contentSize.height/2 - offsetY
        heroHead:setPosition(ccp(positionX, positionY))
        self._scrollView:addItemBox(heroHead)

        local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
         local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)

        line = line + 1
        if line > 4 then
            line = 1
            row = row + 1
            totalHeight = totalHeight + self._contentSize.height + rowDistance + offsetY
        end
    end

    if line > 1 and line <= 4 and row > 1 then
        totalHeight = totalHeight + self._contentSize.height + rowDistance + offsetY
    end
    self._scrollView:setRect(0, -totalHeight, 0, totalWidth)

    local num,unit = q.convertLargerNumber(self.info.force or forceCount)
    self._ccbOwner.tf_battleforce:setString(num..(unit or ""))

    self._ccbOwner.node_bg_long:setVisible(true)
    self._ccbOwner.node_bg_short:setVisible(false)            
    -- self._ccbOwner.node_extends_tips:setVisible(false)
end

function QUIDialogNightmareFigterInfo:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogNightmareFigterInfo:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogNightmareFigterInfo:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogNightmareFigterInfo