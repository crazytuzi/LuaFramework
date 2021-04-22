--
-- Author: Your Name
-- Date: 2015-01-17 11:36:24
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilverMineFigterInfo = class("QUIDialogSilverMineFigterInfo", QUIDialog)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QScrollView = import("...views.QScrollView") 

function QUIDialogSilverMineFigterInfo:ctor(options)
 	local ccbFile = "ccb/Dialog_SilverMine_Prompt.ccbi"
    local callBacks = {}
    QUIDialogSilverMineFigterInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._info = options.info
    self._layer = options.layer
    if self._info == nil then assert(false, "the dialog options info can't is nil") end
    -- QPrintTable(self._info)
    self._ccbOwner.tf_name:setString(self._info.name or "")
    self._ccbOwner.tf_level:setString("LV."..(self._info.level or 0))
    self._ccbOwner.vip:setString("VIP  " .. tostring(self._info.vip or 0))
    self._ccbOwner.tf_force_name:setString("战力：")
    local num,unit = q.convertLargerNumber(self._info.force)
    self._ccbOwner.tf_battleforce:setString(num..(unit or ""))
    self._ccbOwner.tf_uion:setString(self._info.consortiaName or "无")

	self.head = QUIWidgetAvatar.new(self._info.avatar)
    self.head:setSilvesArenaPeak(self._info.championCount)
    self._ccbOwner.node_head:addChild(self.head)

    self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
    self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

    self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {sensitiveDistance = 10})
    self._scrollView:replaceGradient(self._ccbOwner.top_shadow, self._ccbOwner.bottom_shadow, nil, nil)

    local deadIndex = 1
    local lineDistance = 10
    local rowDistance = 40
    local line = 1
    local row = 1
    local offsetY = 20
    local totalHeight = 0
    local totalWidth = 0

    for index, value in ipairs(self._info.heros) do
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
        heroHead:setHp()
        heroHead:setMp(500, 1000)

        local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
        local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)

        -- self:_showHpMp( heroHead, value.actorId, false, options.allDead, options.initMp )

        self._contentSize = heroHead:getHeroHeadSize()
        local positionX = (((self._contentSize.width + lineDistance) * (line - 1)) ) + self._contentSize.width/2
        local positionY = -(((self._contentSize.height + rowDistance) * (row - 1)) ) - self._contentSize.height/2 - offsetY
        heroHead:setPosition(ccp(positionX, positionY))

        self._scrollView:addItemBox(heroHead)
        -- if (value.currHp and value.currHp <= 0) or (value.hp and value.hp <= 0) or options.allDead then
        --     -- heroHead:setDead(true)
        --     self._ccbOwner["node_dead_"..deadIndex]:setVisible(true)
        --     self._ccbOwner["node_dead_"..deadIndex]:setVisible(true)
        --     self._ccbOwner["node_dead_"..deadIndex]:retain()
        --     self._ccbOwner["node_dead_"..deadIndex]:removeFromParent()
        --     self._scrollView:addItemBox(self._ccbOwner["node_dead_"..deadIndex])
        --     self._ccbOwner["node_dead_"..deadIndex]:setPosition(ccp(positionX, positionY))
        --     self._ccbOwner["node_dead_"..deadIndex]:release()
        --     deadIndex = deadIndex + 1

        --     makeNodeFromNormalToGray(heroHead)
        -- end

        line = line + 1
        if line > 4 then
            line = 1
            row = row + 1
            totalHeight = totalHeight + self._contentSize.height + rowDistance
        end
        totalWidth = (self._contentSize.width + lineDistance) * 4 - self._contentSize.width/2
    end
    for index, value in ipairs(self._info.subheros or {}) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHeroSkinId(value.skinId)
        heroHead:setHero(value.actorId)
        heroHead:setLevel(value.level)
        heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
        heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setHeadScale(0.8)
        heroHead:setHp()
        heroHead:setMp(500, 1000)

        local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
        local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)
        
        heroHead:setTeam(2)
        -- self:_showHpMp( heroHead, value.actorId, true, options.allDead, options.initMp )

        self._contentSize = heroHead:getHeroHeadSize()
        local positionX = (((self._contentSize.width + lineDistance) * (line - 1)) ) + self._contentSize.width/2
        local positionY = -(((self._contentSize.height + rowDistance) * (row - 1)) ) - self._contentSize.height/2 - offsetY
        heroHead:setPosition(ccp(positionX, positionY))

        self._scrollView:addItemBox(heroHead)
        -- if (value.currHp and value.currHp <= 0) or (value.hp and value.hp <= 0) or options.allDead then
        --     makeNodeFromNormalToGray(heroHead)
        -- end


        line = line + 1
        if line > 4 then
            line = 1
            row = row + 1
            totalHeight = totalHeight + self._contentSize.height + rowDistance
        end
    end

    for index, value in ipairs(self._info.sub2heros or {}) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHeroSkinId(value.skinId)
        heroHead:setHero(value.actorId)
        heroHead:setLevel(value.level)
        heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
        heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setHeadScale(0.8)
        heroHead:setHp()
        heroHead:setMp(500, 1000)

        local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
        local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)
        
        heroHead:setTeam(2)
        -- self:_showHpMp( heroHead, value.actorId, true, options.allDead, options.initMp )

        self._contentSize = heroHead:getHeroHeadSize()
        local positionX = (((self._contentSize.width + lineDistance) * (line - 1)) ) + self._contentSize.width/2
        local positionY = -(((self._contentSize.height + rowDistance) * (row - 1)) ) - self._contentSize.height/2 - offsetY
        heroHead:setPosition(ccp(positionX, positionY))

        self._scrollView:addItemBox(heroHead)

        -- if (value.currHp and value.currHp <= 0) or (value.hp and value.hp <= 0) or options.allDead then
        --     makeNodeFromNormalToGray(heroHead)
        -- end

        line = line + 1
        if line > 4 then
            line = 1
            row = row + 1
            totalHeight = totalHeight + self._contentSize.height + rowDistance + offsetY
        end
    end
    
    for index, value in ipairs(self._info.sub3heros or {}) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHeroSkinId(value.skinId)
        heroHead:setHero(value.actorId)
        heroHead:setLevel(value.level)
        heroHead:setBreakthrough(value.breakthrough)
        heroHead:setGodSkillShowLevel(value.godSkillGrade)
        heroHead:setStar(value.grade)
        heroHead:showSabc()
        heroHead:setHeadScale(0.8)
        heroHead:setHp()
        heroHead:setMp(500, 1000)

        local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(value.actorId))
        local profession = heroInfo.func or "dps"
        heroHead:setProfession(profession)
        
        heroHead:setTeam(2)
        -- self:_showHpMp( heroHead, value.actorId, true, options.allDead, options.initMp )

        self._contentSize = heroHead:getHeroHeadSize()
        local positionX = (((self._contentSize.width + lineDistance) * (line - 1)) ) + self._contentSize.width/2
        local positionY = -(((self._contentSize.height + rowDistance) * (row - 1)) ) - self._contentSize.height/2 - offsetY
        heroHead:setPosition(ccp(positionX, positionY))

        self._scrollView:addItemBox(heroHead)

        -- if (value.currHp and value.currHp <= 0) or (value.hp and value.hp <= 0) or options.allDead then
        --     makeNodeFromNormalToGray(heroHead)
        -- end

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

    self._scrollView:setVerticalBounce(true)
    -- if #(self._info.heros or {}) + #(self._info.subheros or {}) + #(self._info.sub2heros or {}) <= 4 then
    --     local size = self._ccbOwner.node_bg:getContentSize()
    --     self._ccbOwner.node_bg:setPreferredSize(CCSize(size.width, size.height - 240))
    --     -- self._ccbOwner.node_extends_tips:setPositionY(self._ccbOwner.node_extends_tips:getPositionY() + 140)
    --     self._scrollView:setVerticalBounce(false)
    -- elseif #(self._info.heros or {}) + #(self._info.subheros or {}) + #(self._info.sub2heros or {}) <= 8 then
    --     local size = self._ccbOwner.node_bg:getContentSize()
    --     self._ccbOwner.node_bg:setPreferredSize(CCSize(size.width, size.height - 120))
    --     -- self._ccbOwner.node_extends_tips:setPositionY(self._ccbOwner.node_extends_tips:getPositionY() + 140)
    --     self._scrollView:setVerticalBounce(false)
    -- end

    if #(self._info.heros or {}) + #(self._info.subheros or {}) + #(self._info.sub2heros or {}) <= 4 then
        local size = self._ccbOwner.node_bg:getContentSize()
        self._ccbOwner.node_bg:setPreferredSize(CCSize(size.width, size.height - 140))
        -- self._ccbOwner.node_extends_tips:setPositionY(self._ccbOwner.node_extends_tips:getPositionY() + 140)
        self._scrollView:setVerticalBounce(false)
    end

    -- if options.firstAward then
    --     QPrintTable(options.firstAward)
    --     self._ccbOwner.node_extends_tips:setVisible(true)

    --     local tbl = options.firstAward
    --     local index = 1
    --     for _, value in pairs(tbl) do
    --         if self._ccbOwner["node_first_award_"..index] then
    --             local node = self:_getIcon(value.typeName, value.id, value.count)
    --             self._ccbOwner["node_first_award_"..index]:addChild( node )
    --             self._ccbOwner["node_first_award_"..index]:setVisible(true)
    --             index = index + 1
    --         end
    --     end
    -- end

    -- if options.award then
    --     QPrintTable(options.award)
    --     self._ccbOwner.node_extends_tips:setVisible(true)

    --     local tbl = options.award
    --     local node = self:_getIcon(tbl[1].typeName, tbl[1].id, tbl[1].count)
    --     self._ccbOwner.node_award:addChild( node )
    --     self._ccbOwner.node_award:setVisible(true)
    --     -- self._ccbOwner.tf_count:setString(tbl[1].count)
    -- end
end

--[[
    设置icon
]]
function QUIDialogSilverMineFigterInfo:_getIcon( type, id, count )
    local node = nil
    node = QUIWidgetItemsBox.new({ccb = "small"})
    node:setGoodsInfo(id, type, count)

    return node
end

-- function QUIDialogSilverMineFigterInfo:_showHpMp( heroHead, actorId, isSubhero, isAllDead, initMp )
--     if not heroHead or not actorId then return end

--     local maxMp = 1000
    
--     if isSubhero then 
--         heroHead:setHp()
--         if initMp then
--             heroHead:setMp(initMp, maxMp)
--         else
--             heroHead:setMp(500, maxMp)
--             -- 盗贼初始连击点数满
--             local character_config = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
--             if character_config.combo_points_auto then
--                 heroHead:setMp(maxMp, maxMp)
--             end
--         end
--         return
--     end

--     local npcTbl = remote.sunWar:getNpcHeroInfo()
--     if not npcTbl or table.nums(npcTbl) == 0 then
--         -- NPC满血
--         heroHead:setHp()
--         if initMp then
--             heroHead:setMp(initMp, maxMp)
--         else
--             heroHead:setMp(500, maxMp)
--             -- 盗贼初始连击点数满
--             local character_config = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
--             if character_config.combo_points_auto then
--                 heroHead:setMp(maxMp, maxMp)
--             end
--         end
--         return
--     end

--     if npcTbl[actorId] then
--         if not npcTbl[actorId].currHp then
--             heroHead:setHp()
--         else
--             local maxHp = remote.sunWar:getNpcHeroMaxHp( actorId )
--             heroHead:setHp( npcTbl[actorId].currHp, maxHp )
--         end

--         if not npcTbl[actorId].currMp then
--             if initMp then
--                 heroHead:setMp(initMp, maxMp)
--             else
--                 heroHead:setMp(500, maxMp)
--                 -- 盗贼初始连击点数满
--                 local character_config = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
--                 if character_config.combo_points_auto then
--                     heroHead:setMp(maxMp, maxMp)
--                 end
--             end
--         else
--             heroHead:setMp( npcTbl[actorId].currMp, maxMp )
--         end
--     else
--         heroHead:setHp()
--         if initMp then
--             heroHead:setMp(initMp, maxMp)
--         else
--             heroHead:setMp(500, maxMp)
--             -- 盗贼初始连击点数满
--             local character_config = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
--             if character_config.combo_points_auto then
--                 heroHead:setMp(maxMp, maxMp)
--             end
--         end
--     end
-- end

function QUIDialogSilverMineFigterInfo:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogSilverMineFigterInfo:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogSilverMineFigterInfo:viewAnimationOutHandler()
    if self._layer then
        app:getNavigationManager():popViewController(self._layer, QNavigationController.POP_TOP_CONTROLLER)
    else
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    end
end

return QUIDialogSilverMineFigterInfo