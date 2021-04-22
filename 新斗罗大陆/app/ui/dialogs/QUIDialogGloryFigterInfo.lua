--
-- Author: Your Name
-- Date: 2015-01-17 11:36:24
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGloryFigterInfo = class("QUIDialogGloryFigterInfo", QUIDialog)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 

function QUIDialogGloryFigterInfo:ctor(options)
 	local ccbFile = "ccb/Dialog_ArenaPrompt.ccbi"
    local callBacks = {}
    QUIDialogGloryFigterInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self.info = options.info
    self._selfLevel = options.selfLevel or 1
    if self.info == nil then assert(false,"the dialog options info can't is nil") end

    self._ccbOwner.count_text:setString(self.info.text or "")
    self._ccbOwner.tf_name:setString(self.info.name or "")
    self._ccbOwner.vip:setString("VIP  " .. tostring(self.info.vip or 0))
    self._ccbOwner.tf_level:setString("LV."..(self.info.level or 0))
    self._ccbOwner.tf_win_count:setString(self.info.victory or 0)
    self._ccbOwner.tf_force_name:setString("防守总战力：")
    self._ccbOwner.tf_uion:setString(self.info.consortiaName or "无")
    self._ccbOwner.tf_uion_name:setString(self.info.consortiaNameLabel or "所属宗门：")
    self._ccbOwner.count_text:setVisible(not self.info.no_victory)
    self._ccbOwner.tf_win_count:setVisible(not self.info.no_victory)

    -- local force = 0
    -- for _, heroInfo in pairs(self.info.heros) do
    --     force = force + app:createHeroWithoutCache(heroInfo):getBattleForce()
    -- end
    local num,unit = q.convertLargerNumber(self.info.force or 0)
    self._ccbOwner.tf_battleforce:setString(num..(unit or ""))

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
    local rowDistance = 10
    local line = 1
    local row = 1
    local offsetY = 20
    local totalHeight = 0
    local totalWidth = 0

    if type(self.info.heros) == "table" then
        for index, value in pairs(self.info.heros) do
        	local heroHead = QUIWidgetHeroHead.new()
            heroHead:setHeroSkinId(value.skinId)
    		heroHead:setHero(value.actorId)
    		heroHead:setLevel(value.level)
    		heroHead:setBreakthrough(value.breakthrough)
            heroHead:setGodSkillShowLevel(value.godSkillGrade)
    		heroHead:setStar(value.grade)
            heroHead:showSabc()
            heroHead:setTeam(1)
            heroHead:setHeadScale(0.8)

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
            local heroHead = QUIWidgetHeroHead.new()
            heroHead:setHeroSkinId(value.skinId)
            heroHead:setHero(value.actorId)
            heroHead:setLevel(value.level)
            heroHead:setBreakthrough(value.breakthrough)
            heroHead:setGodSkillShowLevel(value.godSkillGrade)
            heroHead:setStar(value.grade)
            heroHead:showSabc()
            heroHead:setTeam(2)
            heroHead:setHeadScale(0.8)

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
            local heroHead = QUIWidgetHeroHead.new()
            heroHead:setHeroSkinId(value.skinId)
            heroHead:setHero(value.actorId)
            heroHead:setLevel(value.level)
            heroHead:setBreakthrough(value.breakthrough)
            heroHead:setGodSkillShowLevel(value.godSkillGrade)
            heroHead:setStar(value.grade)
            heroHead:showSabc()
            heroHead:setTeam(2)
            heroHead:setHeadScale(0.8)

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
            local heroHead = QUIWidgetHeroHead.new()
            heroHead:setHeroSkinId(value.skinId)
            heroHead:setHero(value.actorId)
            heroHead:setLevel(value.level)
            heroHead:setBreakthrough(value.breakthrough)
            heroHead:setGodSkillShowLevel(value.godSkillGrade)
            heroHead:setStar(value.grade)
            heroHead:showSabc()
            heroHead:setTeam(2)
            heroHead:setHeadScale(0.8)

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
    end

    if options.isLong then
        self._ccbOwner.node_bg_long:setVisible(true)
        self._ccbOwner.node_bg_short:setVisible(false)            
        self._ccbOwner.node_extends_tips:setVisible(true)

        local moneyNum  = 0
        if options.isGloryArena then
            if options.rivalsPos then
                moneyNum = remote.tower:getGloryArenaMoneyByRivals(options.rivalsPos, self.info.rank)
            end
        else
            local baseNum = QStaticDatabase:sharedDatabase():getTeamConfigByTeamLevel(remote.user.level).tower_money or 1
            local dropNum = QStaticDatabase:sharedDatabase():getGloryTower(self._selfLevel).tower_money_factor or 0
            moneyNum = baseNum * dropNum
        end

        self._ccbOwner.tf_arena_count:setString(moneyNum)

        local currencyInfo = remote.items:getWalletByType("towerMoney")
        local skillTexture = CCTextureCache:sharedTextureCache():addImage(currencyInfo.alphaIcon)
        local size = skillTexture:getContentSize()
        local rect = CCRectMake(0, 0, size.width, size.height)
        self._ccbOwner.currency_icon:setDisplayFrame(CCSpriteFrame:createWithTexture(skillTexture, rect))
    else
        self._ccbOwner.node_bg_long:setVisible(false)
        self._ccbOwner.node_bg_short:setVisible(true)            
        self._ccbOwner.node_extends_tips:setVisible(false)
    end
end

function QUIDialogGloryFigterInfo:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogGloryFigterInfo:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogGloryFigterInfo:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogGloryFigterInfo