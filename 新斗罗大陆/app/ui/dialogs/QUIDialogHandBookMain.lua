--
-- Kumo
-- 图鉴主界面
--

local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogHandBookMain = class("QUIDialogHandBookMain", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QListView = import("...views.QListView")
local QUIWidgetHeroSkinSmallClient = import("..widgets.QUIWidgetHeroSkinSmallClient")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")
local QActorProp = import("...models.QActorProp")

QUIDialogHandBookMain.drawPos = {

}

function QUIDialogHandBookMain:ctor(options)
    local ccbFile = "ccb/Dialog_HandBook_Main.ccbi"
    local callBack = {
        {ccbCallbackName = "onTriggerAdmire", callback = handler(self, self._onTriggerAdmire)},
        {ccbCallbackName = "onTriggerDoComment", callback = handler(self, self._onTriggerDoComment)},
        {ccbCallbackName = "onTriggerCard", callback = handler(self, self._onTriggerCard)},
        {ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
        {ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggereRight)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggereLeft)},
        {ccbCallbackName = "onTriggerAvatar", callback = handler(self, self._onTriggerAvatar)},
        {ccbCallbackName = "onTriggerChange", callback = handler(self, self._onTriggerChange)},
        {ccbCallbackName = "onTriggerSkill", callback = handler(self, self._onTriggerSkill)},
        {ccbCallbackName = "onTriggerFashion",callback = handler(self,self._onTriggerFashion)},
    }
    QUIDialogHandBookMain.super.ctor(self, ccbFile, callBack, options)


    q.setButtonEnableShadow(self._ccbOwner.btn_fashion)

    self._herosID = options.herosID or {}
    self._pos = options.pos or 0
    self._callback = options.callback
    self._swithType = options.swithType or 1     --1，左下角显示英雄属性；2，左下角显示英雄皮肤
    self._selectSkinId = options.selectSinkId         --选中皮肤id

    self._isSkinShop = options.isSkinShop or false
    self._showSkinId = options.showSkinId or nil
    self._isItem = options.isItem or false

    self._ccbOwner.node_fashion:setVisible(self._isSkinShop)



    if self._herosID and #self._herosID > 0 then
        self._ccbOwner.node_btn:setVisible(true)
    else
        self._ccbOwner.node_btn:setVisible(false)
    end


    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page:setScalingVisible(false)
 
  
    self._isFirstOpen = true
    self:_init()
end

function QUIDialogHandBookMain:initSkinDataList( )
    self._skinDataList = remote.heroSkin:getHeroSkinConfigListById(self._actorId)

    for i, value in ipairs(self._skinDataList) do
        value.isActivation = remote.heroSkin:checkSkinIsActivation(value.character_id, value.skins_id)
        if value.is_nature == 0 then
            value.isActivation = true
        end
    end

    table.sort( self._skinDataList, function(a, b) 
            if a.is_nature ~= b.is_nature then
                return a.is_nature == 0
            elseif a.isActivation ~= b.isActivation then
                return a.isActivation
            else
                return a.skins_id > b.skins_id 
            end
        end )
end
-- function QUIDialogHandBookMain:_onBackTriggered()
--     app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
-- end

function QUIDialogHandBookMain:viewDidAppear()
    QUIDialogHandBookMain.super.viewDidAppear(self)
    self:addBackEvent(false)
    remote.handBook.showActorId = nil
end

function QUIDialogHandBookMain:viewWillDisappear()
    QUIDialogHandBookMain.super.viewWillDisappear(self)
    self:removeBackEvent()

    remote.handBook.showActorId = self._actorId
end

function QUIDialogHandBookMain:_init()
    -- QPrintTable(self._herosID)
    -- print("self._pos = ", self._pos)
    self._actorId = tonumber(self._herosID[self._pos]) or self:getOptions().actorId or 0
    self._heroHandBookConfig = remote.handBook:getHeroHandBookConfigByActorID(self._actorId)
    self._heroCharacterConfig = remote.handBook:getHeroInfoByActorID(self._actorId)
    self._aptitudeInfo = remote.handBook:getHeroAptitudeInfoByActorID(self._actorId)
    self._selectSkinIndex = 1

    self._colour = COLORS.A
    if self._aptitudeInfo and self._aptitudeInfo.colour3 then
        self._colour = self._aptitudeInfo.colour3
    end

    if self._isSkinShop then
        self._swithType = 2
        self:initSkinDataList()
    end
   
    self:_updateAvatarActionList()
    self:_setSwitchStatus()
    -- self:_setHeroInfo()
    self:_setProfession()
    self:_setSABC()
    self:_setHeroDataInfo()
    self:_setAvatar()
    self:_setAdmireInfo()
    self:_initSkinAttrInfo()
end

function QUIDialogHandBookMain:_updateAvatarActionList(skinActionStr)
    print("[ QUIDialogHandBookMain:_updateAvatarActionList ] ", self._skinId, self._lastSkinId)
    if self._skinId and self._lastSkinId and self._skinId == self._lastSkinId then
        return 
    end
    self._avatarName = {}
    self._totalRate = 0
    local actionStr
    if skinActionStr then
        print("[SKIN_ACTION] ", skinActionStr)
        actionStr = skinActionStr
    elseif self._heroCharacterConfig then
        print("[NORMAL_ACTION] ", self._heroCharacterConfig.information_action)
        actionStr = self._heroCharacterConfig.information_action
    end
    if actionStr ~= nil then
        local actionArr = string.split(actionStr, ";")
        if actionArr ~= false then
            for _,value in pairs(actionArr) do
                local arr = string.split(value, ":")
                self._totalRate = self._totalRate + tonumber(arr[2])
                table.insert(self._avatarName, {name = arr[1], rate = tonumber(arr[2])})
            end
        end
    end
end

function QUIDialogHandBookMain:_setAdmireInfo(isAnimation)
    local admireInfo = remote.handBook:getAdmireInfoByActorID( self._actorId )
    if admireInfo then
        if isAnimation and admireInfo.isAdmire then
            self:_showHeartAnimation()
        else
            self._ccbOwner.sp_admire_on:setVisible(admireInfo.isAdmire)
            self._ccbOwner.sp_admire_off:setVisible(not admireInfo.isAdmire)
        end
        self._ccbOwner.tf_admire_count:setString(remote.handBook:getTotalAdmireCount(admireInfo.totalAdmireCount))
    else
        self._ccbOwner.sp_admire_on:setVisible(false)
        self._ccbOwner.sp_admire_off:setVisible(true)
        self._ccbOwner.tf_admire_count:setString(0)
    end
end

function QUIDialogHandBookMain:_initSkinAttrInfo( )
    if not self._isItem then 
        self._ccbOwner.node_skin_attr:setVisible(false)
        return
    end

    self._ccbOwner.node_skin_attr:setVisible(true)

    self._ccbOwner.node_hero_data:setVisible(false)
    self._ccbOwner.node_hero_skin:setVisible(false)
    self._ccbOwner.node_switch:setVisible(false)
    self._ccbOwner.node_side_btn:setVisible(false)
    self._ccbOwner.node_btn:setVisible(false)
    local heroId = self._actorId
    local skinId = self._showSkinId
    print(heroId)
    print(skinId)
    local skinInfo = remote.heroSkin:getHeroSkinBySkinId(heroId, skinId)
    QPrintTable(skinInfo)
    local index = 1
    local propFields = QActorProp:getPropFields()

    for i = 1, 4 do
        self._ccbOwner["tf_prop_"..i]:setVisible(false)
        self._ccbOwner["tf_propdesc_"..i]:setVisible(false)
    end

    for key, value in pairs(skinInfo) do
        if propFields[key] and self._ccbOwner["tf_propdesc_"..index] and self._ccbOwner["tf_prop_"..index] then
            self._ccbOwner["tf_propdesc_"..index]:setVisible(true)
            self._ccbOwner["tf_prop_"..index]:setVisible(true)

            local name = propFields[key].uiName
            if name == nil then
                name = propFields[key].name
            end
             self._ccbOwner["tf_propdesc_"..index]:setString(name)
            if propFields[key].isPercent then
                self._ccbOwner["tf_prop_"..index]:setString(string.format("+%.01f%%",  value*100))
            else
                self._ccbOwner["tf_prop_"..index]:setString(string.format("+%s", (value or "")))
            end
            index = index + 1
        end
    end

    local oneSkinNode = QUIWidgetHeroSkinSmallClient.new()
    oneSkinNode:setInfo(skinInfo, 1)
    oneSkinNode:setSelectStatus(true)    
    self._ccbOwner.node_one_skin:addChild(oneSkinNode)
  
end


function QUIDialogHandBookMain:_showHeartAnimation()
    local ccbFile = remote.handBook:getHeartAnimation()
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, nil, function()
            self:_setAdmireInfo()
        end, false)
end

function QUIDialogHandBookMain:_setAvatar()
    self._ccbOwner.sp_avatar_bg:setColor(self._colour)

    self._ccbOwner.node_avatar:removeAllChildren()
    local skinId
    local skinInfo
    if q.isEmpty(self._skinDataList) == false then
        skinInfo = self._skinDataList[self._selectSkinIndex]
        skinId = skinInfo.skins_id
    end
    self._lastSkinId = self._skinId
    self._skinId = skinId
    self:_updateAvatarActionList(skinInfo and skinInfo.information_action_skins)
    self._avatar = QUIWidgetActorDisplay.new(self._actorId, {heroInfo = {skinId = skinId}})
    self._ccbOwner.node_avatar:addChild(self._avatar)
    self._avatar:setScaleX(-1)

    self:_setHeroInfo(skinId)
end

function QUIDialogHandBookMain:_randomPlayAvatar()
    if #self._avatarName == 0 or self._totalRate == 0 then return end
    local num = math.random(self._totalRate)
    local rate = 0
    local actionName = nil
    for _,value in pairs(self._avatarName) do
        if num < (rate + value.rate) then
            actionName = value.name
            break
        end
        rate = rate + value.rate
    end
    if actionName ~= nil then
        self:_avatarPlayAnimation(actionName, true)
    end
end

--显示特效
function QUIDialogHandBookMain:_avatarPlayAnimation(value, isPalySound, callback)
    if self._avatar ~= nil then
        self._avatar:displayWithBehavior(value)
        self._avatar:setDisplayBehaviorCallback(callback)
        if isPalySound ~= nil or isPalySound == true then
            self:_playSound(value)
        end
    end
end

function QUIDialogHandBookMain:_playSound(value)
    if self._avatarSound ~= nil then
        app.sound:stopSound(self._avatarSound)
        self._avatarSound = nil
    end

    local cheer, walk
    if self._skinId then
        local skinConfig = db:getHeroSkinConfigByID(self._skinId)
        cheer = skinConfig.cheer
        walk = skinConfig.walk
    end
    if not cheer then
        cheer = self._heroCharacterConfig.cheer
    end
    if not walk then
        walk = self._heroCharacterConfig.walk
    end

    if value == ANIMATION_EFFECT.VICTORY then
        self._avatarSound = app.sound:playSound(cheer)
    elseif value == ANIMATION_EFFECT.WALK then
        self._avatarSound = app.sound:playSound(walk)
    end
end

function QUIDialogHandBookMain:_setHeroInfo(skinId)
    if not self._heroCharacterConfig then return end

    self._ccbOwner.tf_hero_name:setString((self._heroCharacterConfig.title or "")..(self._heroCharacterConfig.name or ""))
    self._ccbOwner.tf_hero_desc:setString(self._heroCharacterConfig.role_definition or "")


    local _heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    local _skinId = 0
    if skinId then
        _skinId = skinId
    elseif _heroInfo and _heroInfo.skinId and _heroInfo.skinId > 0 then
        _skinId = _heroInfo.skinId
    end
    print("_skinId = ", _skinId, skinId)
    -- QPrintTable(_heroInfo)
    local _cardPath = ""
    local ccbPath = ""
    local right_frame = ""
    local left_frame = ""

    if _skinId > 0 then
        local skinConfig = remote.heroSkin:getHeroSkinBySkinId(self._actorId, _skinId)

        right_frame = skinConfig.right_frame or ""
        left_frame = skinConfig.left_frame or ""

        if skinConfig.skins_card then
            -- print("use skin handBookCard", self._actorId, skinConfig.skins_name)
            _cardPath = skinConfig.skins_card
        end
        
        if skinConfig.skins_ccb then
            ccbPath = skinConfig.skins_ccb
        end
    end
    if _cardPath == "" then
        _cardPath = self._heroCharacterConfig.card
        right_frame = self._heroCharacterConfig.right_frame or ""
        left_frame = self._heroCharacterConfig.left_frame or ""
    end

    if ccbPath == "" and self._heroCharacterConfig.chouka_show2 then
        ccbPath = self._heroCharacterConfig.chouka_show2
        right_frame = self._heroCharacterConfig.right_frame or ""
        left_frame = self._heroCharacterConfig.left_frame or ""
    end

    if self._aptitudeInfo.aptitude == APTITUDE.SS or self._aptitudeInfo.aptitude == APTITUDE.SSR then
        self._ccbOwner.sp_background:setVisible(false)
        self._ccbOwner.node_hero_card:setVisible(true)
        if ccbPath ~= "" then
            self._ccbOwner.node_hero_card:removeAllChildren()
            local widget = QUIWidget.new(ccbPath)
            widget:setPosition(-display.ui_width/2, -display.ui_height/2)
            if nil ~= widget._ccbOwner.sp_ad then
                widget._ccbOwner.sp_ad:setVisible(false)
                if widget._ccbOwner.sp_hero_introduce then
                    widget._ccbOwner.sp_hero_introduce:setVisible(false)
                end
            end
            self._ccbOwner.node_hero_card:addChild(widget)
            --CalculateUIBgSize(self._ccbOwner.node_hero_card, 1280)

 
        end
    else
        if _cardPath ~= "" then
            self._ccbOwner.node_hero_card:setVisible(false)
            self._ccbOwner.sp_background:setVisible(true)
            QSetDisplayFrameByPath(self._ccbOwner.sp_background, _cardPath)
            --CalculateUIBgSize(self._ccbOwner.sp_background)
        else
            self._ccbOwner.sp_background:setVisible(false)
        end
    end


    self._ccbOwner.node_frame_bg:removeAllChildren()
    if right_frame ~="" and left_frame ~="" then
        local spRightFrame = CCSprite:create(right_frame)
        spRightFrame:setAnchorPoint(ccp(0, 0.5))
        if self._aptitudeInfo.aptitude == APTITUDE.SS or self._aptitudeInfo.aptitude == APTITUDE.SSR then
            spRightFrame:setPositionX( UI_VIEW_MIN_WIDTH * 0.5 - 2)
        else
            spRightFrame:setPositionX( UI_VIEW_MIN_WIDTH * 0.5)
        end
        self._ccbOwner.node_frame_bg:addChild(spRightFrame)

        local spLeftFrame = CCSprite:create(left_frame)
        spLeftFrame:setAnchorPoint(ccp(1, 0.5))
        spLeftFrame:setPositionX( - UI_VIEW_MIN_WIDTH * 0.5)
        self._ccbOwner.node_frame_bg:addChild(spLeftFrame)
    end

end

function QUIDialogHandBookMain:_setProfession()
    if self._professionalIcon == nil then 
        self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
        self._ccbOwner.node_hero_profession:addChild(self._professionalIcon)
    end
    self._professionalIcon:setHero(self._actorId)
end

function QUIDialogHandBookMain:_setSABC()
    self._ccbOwner.node_aptitude:setVisible(false)
    if self._aptitudeInfo and self._aptitudeInfo.lower then
        q.setAptitudeShow(self._ccbOwner, self._aptitudeInfo.lower)
        self._ccbOwner.node_aptitude:setVisible(true)
    end
end

function QUIDialogHandBookMain:_setHeroDataInfo()
    self._ccbOwner.node_dataImg:removeAllChildren()
    if not self._heroHandBookConfig then return end

    local vertices = {}
    local tbl = {}

    local getPos = function(dis,beginPos,endPos)
        local len = q.distOf2Points(beginPos,endPos)
        local angle = math.rad(q.angleOf2Points(beginPos,endPos))
        local directionX,directionY = 1,1
        local dirPos = ccp(endPos.x - beginPos.x,endPos.y - beginPos.y)
        if dirPos.x <= 0 then
            directionX = -1
        end

        if dirPos.y <= 0 then
            directionY = -1
        end
        local floatDis = dis / 5
        local percentage = len * floatDis
        local newPos = ccp(beginPos.x + percentage * math.cos(angle), beginPos.y + percentage * math.sin(angle))
        return newPos
    end

    for i = 1, 6, 1 do
        local name = self._heroHandBookConfig["data_name_"..i]
        if name then
            self._ccbOwner["tf_data_"..i]:setString(name)
            self._ccbOwner["tf_data_"..i]:setVisible(true)
        else
            self._ccbOwner["tf_data_"..i]:setVisible(false)
        end
        local data = self._heroHandBookConfig["data_value_"..i] or 0
        local endNode = self._ccbOwner["node_data_"..i.."_"..5]
        local startNode = self._ccbOwner.node_data_0

        local pos = getPos(data,ccp(startNode:getPosition()),ccp(endNode:getPosition()))
        table.insert(tbl, {data = data, pos = pos})
    end

    --  原来使用的方法
    -- for i = 1, 6, 1 do
    --     local name = self._heroHandBookConfig["data_name_"..i]
    --     if name then
    --         self._ccbOwner["tf_data_"..i]:setString(name)
    --         self._ccbOwner["tf_data_"..i]:setVisible(true)
    --     else
    --         self._ccbOwner["tf_data_"..i]:setVisible(false)
    --     end
    --     local data = self._heroHandBookConfig["data_value_"..i] or 0
    --     local node = self._ccbOwner["node_data_"..i.."_"..data]
    --     if not node then
    --         node = self._ccbOwner.node_data_0
    --     end

    --     local pos = ccp(node:getPosition())
    --     table.insert(tbl, {data = data, pos = pos})
    -- end

    -- 方法一：
    -- table.sort(tbl, function(a, b)
    --         return a.data < b.data
    --     end)
    -- for _, value in ipairs(tbl) do
    --     table.insert(vertices, {value.pos.x, value.pos.y})
    -- end
    -- 方法二：
    local minData = 9999999
    local minIndex = 0
    for i, v in ipairs(tbl) do
        if v.data < minData then
            minData = v.data
            minIndex = i
        end
    end
    for i = minIndex, #tbl, 1 do
        table.insert(vertices, {tbl[i].pos.x, tbl[i].pos.y})
    end
    for i = 1, minIndex - 1, 1 do
        table.insert(vertices, {tbl[i].pos.x, tbl[i].pos.y})
    end
    local findCount = 0
    if vertices[1][1] == 366 and vertices[1][2] == -193 and vertices[2][1] == 366 and vertices[2][2] == -193 and 
        (vertices[3][1] ~= 366 or vertices[3][2] ~= -193) and (vertices[6][1] ~= 366 or vertices[6][2] ~= -193) then
        table.insert(vertices, {366, -193})
    end
    
    -- 方法三：
    -- for _, value in ipairs(tbl) do
    --     table.insert(vertices, {value.pos.x, value.pos.y})
    -- end
    -- table.insert(vertices, {tbl[1].pos.x, tbl[1].pos.y})
    -- QPrintTable(vertices)
    -- local param = {
    --     fillColor = ccc4f(self._colour.r/255, self._colour.g/255, self._colour.b/255, 0.5),
    --     borderWidth = 0.5,
    --     borderColor = ccc4f(self._colour.r/255, self._colour.g/255, self._colour.b/255, 1),
    -- }
    local param = {
        fillColor = ccc4f(24/255, 116/255, 208/255, 0.7),
        borderWidth = 0.5,
        borderColor = ccc4f(73/255, 190/255, 233/255, 1),
    }
    local drawNode = CCDrawNode:create()
    drawNode:clear()
    drawNode:drawPolygon(vertices, param)
    self._ccbOwner.node_dataImg:addChild(drawNode)
end

function QUIDialogHandBookMain:_setSwitchStatus(shwoEffect)
    self._skinDataList = {}
    self._ccbOwner.btn_change:setVisible(false)
    self._ccbOwner.node_hero_data:setVisible(true)
    self._ccbOwner.node_hero_skin:setVisible(false)

    if remote.heroSkin:checkUnlock() then
        local skinConfig = remote.heroSkin:getHeroSkinConfigListById(self._actorId)
        if q.isEmpty(skinConfig) == false then
            self._ccbOwner.btn_change:setVisible(true)

            local isSkin = self._swithType == 2
            self:initSkinListView(isSkin)
            self._ccbOwner.node_hero_data:setVisible(isSkin)
            self._ccbOwner.node_hero_skin:setVisible(not isSkin)

            local changeFunc = function()
                self._ccbOwner.btn_help:setVisible(not isSkin)
                self._ccbOwner.node_hero_data:setVisible(not isSkin)
                self._ccbOwner.node_hero_skin:setVisible(isSkin)
            end

            if shwoEffect then
                local dTime = 1/6
                local effectArry = CCArray:create()
                effectArry:addObject(CCScaleTo:create(dTime, 0, 1))
                effectArry:addObject(CCCallFunc:create(function()
                        changeFunc()
                    end))
                effectArry:addObject(CCScaleTo:create(dTime, 1, 1))
                self._ccbOwner.node_hero_info:runAction(CCSequence:create(effectArry))
            else
                changeFunc()
            end
        end
    end
end

function QUIDialogHandBookMain:initSkinListView(isSkin)
    if not self._skinDataList or #self._skinDataList == 0 then
        self:initSkinDataList()
    end

    local selectSkinId
    if self._isSkinShop then
        selectSkinId = self._showSkinId
    else
        local _heroInfo = remote.herosUtil:getHeroByID(self._actorId)
        if _heroInfo then
           selectSkinId = _heroInfo.skinId
        end
    end
    if self._selectSkinId and self._selectSkinId > 0 then
        selectSkinId = self._selectSkinId
    end
    if selectSkinId and selectSkinId > 0 then
        for i, value in ipairs(self._skinDataList) do
            if value.skins_id == selectSkinId then
                self._selectSkinIndex = i
                self._selectSkinId = nil
                break
            end
        end
    end

    if not isSkin then return end

    local skinNum = #self._skinDataList
    local cacheCond = 4/skinNum
    if not self._skinListView then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemFunc),
            isVertical = false,
            enableShadow = false,
            ignoreCanDrag = true,
            spaceX = 5,
            totalNumber = skinNum,
            cacheCond = cacheCond,
        }
        self._skinListView = QListView.new(self._ccbOwner.sheet_content, cfg)
    else
        self._skinListView:reload({totalNumber = skinNum})
    end

    --xurui： 首次打开动画结束之后再重新设置listView触摸区域
    if self._isFirstOpen then
        self._isFirstOpen = false
        RunActionDelayTime(self._ccbOwner.node_hero_skin, function()
            if self._skinListView then
                self._skinListView:resetTouchRect()
            end
        end, 0.5)
    end
end

function QUIDialogHandBookMain:_renderItemFunc(listView, index, info)
    local isCacheNode = true
    local itemData = self._skinDataList[index]
    local item = listView:getItemFromCache()
    if not item then
        item = QUIWidgetHeroSkinSmallClient.new()
        item:addEventListener(QUIWidgetHeroSkinSmallClient.EVENT_CLICK, handler(self, self.clickEvent))
        isCacheNode = false
    end
    item:setInfo(itemData, index)
    item:setSelectStatus(self._selectSkinIndex == index)
    info.item = item
    info.size = item:getContentSize()

    listView:registerBtnHandler(index, "btn_click", "_onTriggerClick")

    return isCacheNode
end

function QUIDialogHandBookMain:clickEvent(event)
    if event == nil then return end

    local skinInfo = event.skinInfo
    local index = event.index

    if event.name == QUIWidgetHeroSkinSmallClient.EVENT_CLICK then
        self._selectSkinIndex = index
        if self._skinListView then
            local startIndex = self._skinListView:getCurStartIndex()
            local endIndex = self._skinListView:getCurEndIndex()
            for i = startIndex, endIndex do
                local item = self._skinListView:getItemByIndex(i)
                item:setSelectStatus(self._selectSkinIndex == i)
            end
        end

        self:_setAvatar()
    end
end

function QUIDialogHandBookMain:_onTriggerAdmire()
    app.sound:playSound("common_small")
    remote.handBook:handBookAdmireRequest(self._actorId, 0, self._actorId, self:safeHandler(function()
            self:_setAdmireInfo(true)
        end))
end

function QUIDialogHandBookMain:_onTriggerDoComment(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_doComment) == false then return end
    app.sound:playSound("common_small")
    if remote.handBook:getDoCommentFuncSwitch() then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookBBS", 
            options = {actorId = self._actorId}})
    else
        app.tip:floatTip("敬请期待")
    end
end


function QUIDialogHandBookMain:_onTriggerSkill(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_skills) == false then return end
    app.sound:playSound("common_small")
    if remote.handBook:getDoCommentFuncSwitch() then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroDetailInfoNew"
            , options = {actorId = self._actorId}}, {isPopCurrentDialog = false})
    else
        app.tip:floatTip("敬请期待")
    end
end


function QUIDialogHandBookMain:_onTriggerCard(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_card) == false then return end
    app.sound:playSound("common_small")

    local skinId
    if q.isEmpty(self._skinDataList) == false then
        skinId = self._skinDataList[self._selectSkinIndex].skins_id
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookHeroImageCard", 
        options = {actorId = self._actorId, herosID = self._herosID, pos = self._pos, skinId = skinId}}) 
end

function QUIDialogHandBookMain:_onTriggerHelp(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookHelp"})
end

function QUIDialogHandBookMain:_onTriggereRight()
    app.sound:playSound("common_change")
    if #self._herosID == 0 then return end

    self._pos = self._pos + 1
    if self._pos > #self._herosID then
        self._pos = 1
    end
    local options = self:getOptions()
    options.pos = self._pos
    self._actorId = self._herosID[self._pos]
    self._swithType = 1
    self:_init()
end

function QUIDialogHandBookMain:_onTriggereLeft()
    app.sound:playSound("common_change")
    if #self._herosID == 0 then return end

    self._pos = self._pos - 1
    if self._pos < 1 then
        self._pos = #self._herosID
    end
    local options = self:getOptions()
    options.pos = self._pos
    self._actorId = self._herosID[self._pos]
    self._swithType = 1
    self:_init()
end

function QUIDialogHandBookMain:_onTriggerAvatar()
    self:_randomPlayAvatar()
end

function QUIDialogHandBookMain:_onTriggerChange(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_change) == false then return end
    app.sound:playSound("common_small")

    if self._swithType == 1 then
        self._swithType = 2
    else
        self._swithType = 1
    end
    self._selectSkinIndex = self._selectSkinIndex or 1

    self:_setSwitchStatus(true)
    self:_setAvatar()
end

function QUIDialogHandBookMain:_onTriggerFashion( )
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFashionMain", 
        options = {selectedSkinId = self._showSkinId, selectedHeroId = self._actorId, selectedSkinQuality = nil, callback = nil}})
end

function QUIDialogHandBookMain:onTriggerBackHandler(tag)
  self:_onTriggerBack()
end

function QUIDialogHandBookMain:onTriggerHomeHandler(tag)
  self:_onTriggerHome()
end

function QUIDialogHandBookMain:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogHandBookMain:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogHandBookMain