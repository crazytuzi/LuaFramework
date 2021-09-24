--地图左上角为（0,0）点
--横向坐标  1*80 3*80 5*80  7*80  (公式: 横向地块坐标索引为x   像素坐标为: (2x-1)*80 )
--纵向坐标  60    60+100  60+200  (公式: 纵向地块坐标索引为y   像素坐标为: 60+(y-1)*100)
worldScene = {
    clayer,
    sceneSp,
    touchEnable = true,
    touchArr = {},
    mapSprites = {},
    spSize,
    fieldSize = CCSizeMake(100, 100),
    worldSize = CCSizeMake((2 * 601 - 1) * 80, 60 + 600 * 100),
    topGap = 110,
    bottomGap = 180,
    curShowBases = {},
    isMoved = false,
    showInfo = true,
    lastRefreshTime = 0,
    waitShowBase = false,
    writeSpriteMenu = nil,
    openCollectSpriteMenu = nil,
    islandInfoDialog = nil,
    btnTab = {},
    clickAreaAble = false,
    needFadeEffectPos = nil, --定位时需要闪烁的基地
    baseOldx,
    baseOldy,
    posTipBar,
    lastTouchDownPoint,
    hasGetDataFromServer = {},
    checkcodeValue = 0,
    
    showTankLine = {}, -- 存储行军路线的路线精灵  slotId是索引  在clayer的1000层
    -- showTankLineIcon = {}, -- 存储行军路线的图标精灵
    tankLineState = {}, -- 存储行军路线的状态
    tankLineIcon = {}, -- 存储行军图标精灵
    tankLineCount = 0, -- 已经显示的路线数量
    tankLineRefreshTime = 0, -- 行军路线的刷新计数器
    oneWarEventTd = nil, -- 行军事件窗口类，控制窗口数量
    tankLineDialogNum = 0, -- 控制行军事件窗口的数量
    showEnemyLine = {}, -- 存储敌军来袭的路线精灵  slotId是索引  在clayer的1000层
    enemyLineIcon = {}, -- 存储敌军来袭图标精灵
    firebuildBg = nil,
    fireBuildParent = nil,
    isGloryOver = false,
    buildSelfTb = {},
    leftTimeLbTb = {},
    targetItemPos = nil, --定位时需要加特殊标志的矿点或者基地
    
    tmx = {},
    tmxIndex = 1,
    tmxLand = {},
    tmxLandIndex = 1,
    xuanzhuanJ = 0,
    mapTileObjs = {},
    spiralEagleTb = {},
    flyEagleTb = {},
    cloudTb = {},
    planeTb = {},
    startDeaccleary = false,
    mapMoveDisPos = ccp(0, 0),
    clickFlag = false, --是否点击建筑的标记
    mapPic = "scene/world_map_mi.jpg",
    movingSpeed = 0.1,
    movingtc = 0,
    isMovingBuilding = false, --是否是在移动军团城市的标识
    movingSpaceX = 0, --移动世界地图的X速度（一次移动多少格）
    movingSpaceY = 0, --移动世界地图的Y速度（一次移动多少格）
    buildingPoint = ccp(0, 0), --当前要建造的城市或者领地所在位置
    mapTerritoryTb = {}, --世界地图中的领土分界线
    buildingType = 0, --建造军团城市还是领地（1：军团城市，2：军团领地）
    acityEffectSlot = {}, --存放攻打军团城市的效果创建出来的精灵(用于攻打完成后清除效果)，一个进攻队列，一个效果
    minScale = 1.0,
    curScale = 1.2,
    maxScale = 2.5,
    zoomMidPosForWorld,
    zoomMidPosForSceneSp,
}

function worldScene:init()
    if base.smmap == 1 then --小地图的话，y坐标为300的矿点会在聊天框下面点击不到，所以地图height多加一个格子为60+(G_maxMapy+1)*100
        self.worldSize = CCSizeMake((2 * (G_maxMapx + 1) - 1) * 80, 60 + (G_maxMapy + 1) * 100)
    else
        self.worldSize = CCSizeMake((2 * (G_maxMapx + 1) - 1) * 80, 60 + G_maxMapy * 100)
    end
end

function worldScene:toPiexl(point, scale)
    if scale == nil then
        scale = 1
    end
    return ccp((2 * point.x - 1) * 80 * scale, 60 + 100 * point.y * scale)
end

function worldScene:toCellPoint(point)
    return ccp(math.ceil((point.x / 80 + 1) / 2), G_maxMapy - math.ceil((point.y - 60) / 100))
end

function worldScene:getNearPiexlPoint(point)
    local minPiexlx, maxPiexlx, minPiexly, maxPiexly = 80, (2 * G_maxMapx - 1) * 80, 160, G_maxMapy * 100 + 60
    if point.y <= minPiexly then
        point.y = minPiexly
    end
    if point.y >= maxPiexly then
        point.y = maxPiexly
    end
    
    if point.x < minPiexlx then
        point.x = minPiexlx
    end
    
    if point.x > maxPiexlx then
        point.x = maxPiexlx
    end
    
    local cpmin = ccp(math.floor((point.x + 80) / 160), math.floor((point.y - 60) / 100)) --基地坐标，不是像素坐标
    local cpmax = ccp(math.ceil((point.x + 80) / 160), math.ceil((point.y - 60) / 100))
    local cpmin_p = self:toPiexl(cpmin) --转像素坐标
    local cpmax_p = self:toPiexl(cpmax) --转像素坐标
    
    local resultX
    local resultY
    if math.abs(cpmin_p.x - point.x) > math.abs(cpmax_p.x - point.x) then
        resultX = cpmax.x
    else
        resultX = cpmin.x
    end
    
    if math.abs(cpmin_p.y - point.y) > math.abs(cpmax_p.y - point.y) then
        resultY = cpmax.y
    else
        resultY = cpmin.y
    end
    local resultPiexl = self:toPiexl(ccp(resultX, resultY))
    local areaX = math.ceil(resultPiexl.x / 1000)
    local areaY = math.ceil(resultPiexl.y / 1000)
    -- if worldBaseVoApi.allBaseByArea[areaX*1000+areaY]==nil then
    --     do
    --         return nil,nil
    --     end
    -- end
    
    -- if worldBaseVoApi.allBaseByArea[areaX*1000+areaY][resultX*1000+resultY]~=nil then
    --         do
    --             return nil,nil
    --         end
    -- else
    --         do
    --             return  resultPiexl,ccp(resultX,resultY)
    --         end
    -- end
    
    if resultPiexl.x % 1000 == 0 then
        areaX = areaX + 1
    end
    if resultPiexl.y % 1000 == 0 then
        areaY = areaY + 1
    end
    
    if worldBaseVoApi.allBaseByArea[areaX * 1000 + areaY] and worldBaseVoApi.allBaseByArea[areaX * 1000 + areaY][resultX * 1000 + resultY] and (worldBaseVoApi.allBaseByArea[areaX * 1000 + areaY][resultX * 1000 + resultY]).type < 100 then
        local mapVo = (worldBaseVoApi.allBaseByArea[areaX * 1000 + areaY][resultX * 1000 + resultY])
        if (mapVo.type == 0 and mapVo.aid) or mapVo.type == 9 then --如果该地块是空地块但属于军团的领地(或者是欧米伽小队的领地)，此地块也可以点击
            return resultPiexl, ccp(resultX, resultY)
        end
        return nil, ccp(resultX, resultY)
    else
        return resultPiexl, ccp(resultX, resultY)
    end
end

function worldScene:getMinAndMaxXYByAreaID(areaID)
    
    local x, y = math.floor(areaID / 1000), areaID % 1000
    
    local pMinX, pMinY, pMaxX, pMaxY = (x - 1) * 1000, (y - 1) * 1000, x * 1000, y * 1000
    
    local minX, maxX, minY, maxY = math.ceil((pMinX + 80) / 160), math.floor((pMaxX + 80) / 160), math.ceil((pMinY - 60) / 100), math.floor((pMaxY - 60) / 100)
    
    if (pMaxX + 80) % 160 == 0 then --一个区域取最小的 不取最大的（边界问题）
        maxX = maxX - 1
    end
    
    if (pMaxY - 60) % 100 == 0 then --一个区域取最小的 不取最大的（边界问题）
        maxY = maxY - 1
    end
    
    return minX, maxX, minY, maxY
end

--convertToWorldSpace
--convertToNodeSpace
--ccpMidpoint
function worldScene:show()
    self.clayer = CCLayer:create()
    self.clayer:setTouchEnabled(true)
    self.clayer:setPosition(ccp(0, 0))
    if G_isUseNewMap() == true then
        self.mapPic = "scene/world_map_miNew.jpg"
    end
    if G_isUseNewMap() == true then
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
        self.sceneSp = CCSprite:create(self.mapPic)
        self.spSize = self.sceneSp:getContentSize()
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        
        self.spBatchNode = CCSpriteBatchNode:create("scene/mapOrnamentals.png")
        self.clayer:addChild(self.spBatchNode, 2)
        
        self.spBatchNode_1 = CCSpriteBatchNode:create("scene/mapSurface.png")
        self.clayer:addChild(self.spBatchNode_1, 1)
        
        self.eagleBatchNode = CCSpriteBatchNode:create("scene/ui_home_eagle.pvr.ccz")
        self.clayer:addChild(self.eagleBatchNode, 10002)
        
        self.planeBatchNode = CCSpriteBatchNode:create("scene/mapPlane.png")
        self.clayer:addChild(self.planeBatchNode, 10002)
        
        local showLayer = CCLayer:create()
        showLayer:setContentSize(CCSizeMake(G_VisibleSize.width, G_VisibleSize.height))
        sceneGame:addChild(showLayer, 1)
        showLayer:addChild(self.clayer)
        showLayer:setAnchorPoint(ccp(0, 0))
        self.showLayer = showLayer
        -- showLayer:runAction(
        --   CCOrbitCamera:create(0, 1, 0, self.xuanzhuanJ, 0, 270, 0)
        -- )
        
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        local function nilFunc()
        end
        local mapFogSp = CCSprite:createWithSpriteFrameName("worldMapFog.png")
        mapFogSp:setScaleX(G_VisibleSize.width / mapFogSp:getContentSize().width)
        mapFogSp:setAnchorPoint(ccp(0.5, 1))
        if G_checkUseAuditUI() == true or G_getGameUIVer() == 1 then
            mapFogSp:setPosition(G_VisibleSize.width / 2, G_VisibleSize.height - 140)
        else
            mapFogSp:setPosition(G_VisibleSize.width / 2, G_VisibleSize.height - 120)
        end
        sceneGame:addChild(mapFogSp, 1)
        
        self.mapFogSp = mapFogSp
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    else
        self.sceneSp = CCSprite:create(self.mapPic)
        self.spSize = self.sceneSp:getContentSize()
        sceneGame:addChild(self.clayer)
    end
    
    -- self.curScale = self.minScale
    self.showLayer:setScale(self.curScale)
    
    self.mapBatchNode = CCSpriteBatchNode:create(self.mapPic)
    self.clayer:addChild(self.mapBatchNode)
    self:focus(playerVoApi:getMapX(), playerVoApi:getMapY())
    self.clayer:setTouchPriority(-2)
    self.clayer:setBSwallowsTouches(true)
    local function tmpHandler(...)
        return self:touchEvent(...)
    end
    self.clayer:registerScriptTouchHandler(tmpHandler, false, -2, true)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconLevel.plist")
    local function onMineChange(event, data)
        self:mineChange(data)
    end
    self.mineChangeListener = onMineChange
    eventDispatcher:addEventListener("worldScene.mineChange", onMineChange)
    --CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
    local function refreshMine(event, data)
        self:refreshMine(data)
    end
    self.mineListener = refreshMine
    eventDispatcher:addEventListener("worldScene.refreshMine", refreshMine)
    
    if base.allianceCitySwitch == 1 then --军团城市
        spriteController:addPlist("scene/areaEdgeImages.plist")
        spriteController:addTexture("scene/areaEdgeImages.png")
        spriteController:addPlist("scene/allianceCityImages.plist")
        spriteController:addTexture("scene/allianceCityImages.png")
        spriteController:addPlist("scene/worldFightTank.plist")
        spriteController:addTexture("scene/worldFightTank.png")
        spriteController:addPlist("scene/worldFightEffect.plist")
        spriteController:addTexture("scene/worldFightEffect.png")
        self.edgeBatchSp = CCSpriteBatchNode:create("scene/areaEdgeImages.png")
        self.clayer:addChild(self.edgeBatchSp, 1)
    end
end

--coords：指定坐标
function worldScene:setShow(coords, targetType)
    if G_notShowWorldMap() == true then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_notOpen"), 28)
        do return end
    end
    self.clickFlag = false
    self.clickFlag = false
    if self.clayer == nil then
        self:show()
    end
    if coords then
        self:focus(coords.x, coords.y, nil, targetType)
    end
    if self.mapFogSp then
        self.mapFogSp:setVisible(true)
    end
    self.touchEnable = true
    self.clayer:setVisible(true)
    
    if G_isUseNewMap() == true then
        self:addOrnamentals()
        --先去掉飞机鹰和云的特效
        -- self:showAniOrnamentals()
    end
end

function worldScene:setHide()
    if self.clayer ~= nil then
        self.touchArr = nil
        self.touchArr = {}
        self.touchEnable = false
        self.clayer:setVisible(false)
        self.clayer:stopAllActions()
        if self.mapFogSp then
            self.mapFogSp:setVisible(false)
        end
    end
    if base.allianceCitySwitch == 1 and self.buildingSp then --移除掉创建军团或领地的层
        self:removeBuildLayer()
    end
end

function worldScene:focus(x, y, isTarget, targetType)
    self.needFadeEffectPos = ccp(x, y)
    if isTarget then
        self.targetItemPos = self.needFadeEffectPos
    end
    
    mainUI:worldLandMove(self.needFadeEffectPos)
    local cPoint = self:toPiexl(ccp(x, y), self.curScale)
    x = cPoint.x
    y = cPoint.y
    
    local xPos = G_VisibleSize.width / 2 - x
    local yPos = y + G_VisibleSize.height / 2 - self.worldSize.height * self.curScale
    if targetType and targetType == 8 then --如果跳转军团城市，坐标需调整到屏幕中间
        xPos = xPos + 80 * self.curScale
        yPos = yPos - 50 * self.curScale
    end
    self.showLayer:setPosition(ccp(xPos, yPos))
    if self.mapLayer then
        self.mapLayer:setPosition(self.clayer:getPosition())
    end
    
    mainUI:directSignMove(self.needFadeEffectPos)
    
    self:getNeedShowSps()
    if G_isUseNewMap() == true then
        self:addOrnamentals()
    end
    self:checkBound()
    --self:showBase()
    self.waitShowBase = true
    self.checkcodeValue = 5
    self:twinkleOnFocus(isTarget)
    
    if isTarget then
        self:blinkOnFocus()
    end
end

function worldScene:getNeedShowSps()
    local screenCenterPosInClayer = self.showLayer:convertToNodeSpace(ccp(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    local xIndex = math.floor(screenCenterPosInClayer.x / self.spSize.width) + 1
    local yIndex = math.floor(screenCenterPosInClayer.y / self.spSize.height) + 1
    local inTableIndex
    
    local needShowIndexs = {} --所有需要加载地图图片的格子
    for xv = xIndex - 1, xIndex + 1 do --这个循环只限制了最小值没有限制最大值
        if xv >= 0 then
            for yv = yIndex - 2, yIndex + 2 do
                if yv >= 0 then
                    inTableIndex = xv * 10000 + yv
                    needShowIndexs[inTableIndex] = {xv, yv}
                end
            end
        end
    end
    -- if G_isOpenWinterSkin then
    --      G_onlyInitWorldMap(needShowIndexs)
    --      buildingSkinAddress["worldMapNeedSHowIndexs"] = needShowIndexs
    -- else
    for k, v in pairs(needShowIndexs) do
        if self.mapSprites[k] == nil then --加载地图并显示
            local tmpSp = CCSprite:create(self.mapPic)
            tmpSp:setTag(700 + k)
            tmpSp:setAnchorPoint(ccp(0, 0))
            tmpSp:setPosition((v[1] - 1) * self.spSize.width, (v[2] - 1) * self.spSize.height)
            -- self.clayer:addChild(tmpSp)
            self.mapBatchNode:addChild(tmpSp)
            self.mapSprites[k] = tmpSp
        end
    end
    -- end
    
    local needRemoveSp = {}
    for k, v in pairs(self.mapSprites) do
        if needShowIndexs[k] == nil then --需要移除掉了
            table.insert(needRemoveSp, k)
        end
    end
    
    for k, v in pairs(needRemoveSp) do
        self.mapSprites[v]:removeFromParentAndCleanup(true)
        self.mapSprites[v] = nil
    end
    needRemoveSp = nil
end

function worldScene:touchEvent(fn, x, y, touch)
    if fn == "began" then
        if self.touchEnable == false or SizeOfTable(self.touchArr) >= 2 then
            return 0
        end
        self.isMoved = false
        self.touchArr[touch] = touch
        local touchIndex = 0
        for k, v in pairs(self.touchArr) do
            if touchIndex == 0 then
                self.firstOldPos = CCDirector:sharedDirector():convertToGL(v:getLocationInView())
            else
                self.secondOldPos = CCDirector:sharedDirector():convertToGL(v:getLocationInView())
            end
            touchIndex = touchIndex + 1
        end
        if touchIndex == 1 then
            self.secondOldPos = nil
            self.lastTouchDownPoint = self.firstOldPos
        end
        if SizeOfTable(self.touchArr) > 1 then
            self.multTouch = true
        else
            self.multTouch = false
        end
        
        --判断开始触摸的位置是否是要创建的军团城市
        if base.allianceCitySwitch == 1 then
            if self.buildingSp and self:checkTouchBuilding(self.buildingSp, x, y) == true and self.buildingType ~= 4 then --（self.buildingType~=4）表示领地回收的时候不可以移动领地
                -- print("self.buildingSp,+++++++触摸到城市+++++++",self.buildingSp)
                self.isMovingBuilding = true
                local function movingMap()
                    if self.isMovingBuilding == true then
                        self.movingtc = self.movingtc + 0.04
                        if self.movingtc >= self.movingSpeed then
                            self.movingtc = 0
                            self:checkMapMoving()
                        end
                    end
                end
                local moveArr = CCArray:create()
                local delay = CCDelayTime:create(0.02)
                local callFunc = CCCallFunc:create(movingMap)
                moveArr:addObject(delay)
                moveArr:addObject(callFunc)
                local seq = CCSequence:create(moveArr)
                self.buildingSp:runAction(CCRepeatForever:create(seq))
            else
                self.isMovingBuilding = false
            end
        end
        return 1
    elseif fn == "moved" then
        if self.touchEnable == false then
            do
                return
            end
        end
        if self.isMovingBuilding == true and self.buildingSp then
            self:hideOperateLayer()
            self:checkMapMovingSpace(x, y)
            local tmp_x, tmp_y = x, y
            if tmp_x < 80 then
                tmp_x = 80
            elseif tmp_x > (G_VisibleSizeWidth - 80) then
                tmp_x = G_VisibleSizeWidth - 80
            end
            if tmp_y < 180 then
                tmp_y = 180
            elseif tmp_y > (G_VisibleSizeHeight - 150) then
                tmp_y = G_VisibleSizeHeight - 150
            end
            local cityPos = self.showLayer:convertToNodeSpace(ccp(tmp_x, tmp_y))
            self.buildingSp:setPosition(cityPos.x, cityPos.y)
            local cp = self:getBuildingSpCellPoint()
            if cp.x ~= self.buildingPoint.x or cp.y ~= self.buildingPoint.y then
                self.buildingPoint = cp
                self:adjustTerritories(cp.x, cp.y)
            end
            do return end
        end
        self.isMoved = true
        self.needFadeEffectPos = nil
        self.clickAreaAble = false
        if self.multTouch == false then --单点触摸
            local curPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            local moveDisPos = ccpSub(curPos, self.firstOldPos)
            local moveDisTmp = ccpSub(curPos, self.lastTouchDownPoint)
            self.mapMoveDisPos = moveDisPos
            if (math.abs(moveDisTmp.y) + math.abs(moveDisTmp.x)) < 3 then
                self.clickAreaAble = true
                self.isMoved = false
                do
                    return
                end
            end
            self.autoMoveAddPos = ccp((curPos.x - self.firstOldPos.x) * 3, (curPos.y - self.firstOldPos.y) * 3)
            
            local tmpPos = ccpAdd(ccp(self.showLayer:getPosition()), moveDisPos)
            self.showLayer:setPosition(tmpPos)
            if self.mapLayer then
                self.mapLayer:setPosition(self.clayer:getPosition())
            end
            self.firstOldPos = curPos
            self.isMoving = true
            self:getNeedShowSps()
            self:checkBound()
            self:drawMapMoveAndDirectSign() --地图方向标以及当前坐标
        else
            -- 双点触摸
            self.zoomMidPosForSceneSp = self.showLayer:convertToNodeSpace(ccpMidpoint(self.firstOldPos, self.secondOldPos))
            self.zoomMidPosForWorld = ccpMidpoint(self.firstOldPos, self.secondOldPos)
            local beforeZoomDis = ccpDistance(self.firstOldPos, self.secondOldPos)
            local pIndex = 0
            local curFirstPos
            local curSecondPos
            for k, v in pairs(self.touchArr) do
                if v == touch then
                    if pIndex == 0 then
                        curFirstPos = CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                    else
                        curSecondPos = CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                    end
                    do break end
                end
                pIndex = pIndex + 1
            end
            local afterZoomDis
            if curFirstPos ~= nil then
                afterZoomDis = ccpDistance(curFirstPos, self.secondOldPos)
                self.firstOldPos = curFirstPos
            elseif curSecondPos ~= nil then
                afterZoomDis = ccpDistance(self.firstOldPos, curSecondPos)
                self.secondOldPos = curSecondPos
            end
            local subDis = 0
            local sl = 1
            
            if afterZoomDis == nil or beforeZoomDis == nil then
                afterZoomDis = 0
                beforeZoomDis = 0
            end
            if afterZoomDis > beforeZoomDis then --放大
                subDis = afterZoomDis - beforeZoomDis
                sl = (subDis / 200) * 0.2
                self.curScale = math.min(self.maxScale, sl + self.showLayer:getScale())
                self.showLayer:setScale(self.curScale)
            else --缩小
                subDis = afterZoomDis - beforeZoomDis
                sl = (subDis / 200) * 0.2
                self.curScale = math.max(self.minScale, sl + self.showLayer:getScale())
                self.showLayer:setScale(self.curScale)
            end
            local newPosForSceneSpToWorld = self.showLayer:convertToWorldSpace(self.zoomMidPosForSceneSp)
            local newAddPos = ccpSub(newPosForSceneSpToWorld, self.zoomMidPosForWorld)
            local newClayerPos = ccpSub(ccp(self.showLayer:getPosition()), newAddPos)
            self.showLayer:setPosition(newClayerPos)
            self:checkBound()
        end
    elseif fn == "ended" then
        if self.touchEnable == false then
            do
                return
            end
        end
        if self.isMoved == true then
            self.waitShowBase = true
            self.checkcodeValue = 1
            self.lastRefreshTime = G_getCurDeviceMillTime()
        end
        self:checkRemoveBase()
        if G_isUseNewMap() == false then
            self:checkIfHide()
        end
        if self.touchArr[touch] ~= nil then
            self.touchArr[touch] = nil
            local touchIndex = 0
            for k, v in pairs(self.touchArr) do
                if touchIndex == 0 then
                    self.firstOldPos = CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                else
                    self.secondOldPos = CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                end
                touchIndex = touchIndex + 1
            end
            if touchIndex == 1 then
                self.secondOldPos = nil
            end
            if SizeOfTable(self.touchArr) > 1 then
                self.multTouch = true
            else
                self.multTouch = false
            end
        end
        if self.buildingSp then
            if self.isMovingBuilding == false and self.isMoved == false then --如果触摸的不是城市则移除创建城市的页面
                self:removeBuildLayer()
            else
                self:adjustBuildingSp()
                self:showOperateLayer()
            end
            if self.isMovingBuilding == true then
                if self.buildingSp then
                    self.buildingSp:stopAllActions()
                end
                self.waitShowBase = true
                self:getNeedShowSps()
                self:checkBound()
                self.isMovingBuilding = false
                do return end
            end
        end
        if self.isMoving == true then
            self.isMoving = false
            -- self.startDeaccleary=true
            
            -- if G_isUseNewMap()==false then
            local tmpToPos = ccpAdd(ccp(self.showLayer:getPosition()), self.autoMoveAddPos)
            tmpToPos = self:checkBound(tmpToPos)
            
            local ccmoveTo = CCMoveTo:create(0.15, tmpToPos)
            local cceaseOut = CCEaseOut:create(ccmoveTo, 3)
            local function callBack()
                self:getNeedShowSps()
                self:addOrnamentals()
            end
            local callFunc = CCCallFunc:create(callBack)
            local arr = CCArray:create()
            arr:addObject(cceaseOut)
            arr:addObject(callFunc)
            local seq = CCSequence:create(arr)
            self.showLayer:runAction(seq)
            -- end
            
        else --地图没有移动过
            deviceHelper:luaPrint("=========*******"..tostring(self.clickAreaAble) .. "  "..tostring(self.clickFlag))
            if G_isUseNewMap() == true then
                if self.clickAreaAble == true and self.clickFlag == false then
                    --self.firstOldPos
                    local mapPosX, mapPosY = self:countNodeSpace(self.firstOldPos.x, self.firstOldPos.y, self.xuanzhuanJ)
                    local mapPos = self.showLayer:convertToNodeSpace(ccp(mapPosX, mapPosY))
                    
                    local realPoint = ccp(mapPos.x, self.worldSize.height - mapPos.y)
                    local piexlPoint, pt = self:getNearPiexlPoint(realPoint)
                    if piexlPoint ~= nil then
                        local clickData = worldBaseVoApi:getBaseVo(pt.x, pt.y)
                        if clickData == nil or tonumber(clickData.type) >= 100 or (clickData.type == 0 and clickData.aid) then
                            PlayEffect(audioCfg.mouseClick)
                            self:showSelectedArea(piexlPoint.x, piexlPoint.y, pt.x, pt.y)
                        else
                            if clickData then
                                PlayEffect(audioCfg.mouseClick)
                                local function clickHandler()
                                    if(base.landFormOpen == 1)then
                                        self:clickIslandHandler(clickData)
                                    else
                                        self:clickIslandHandlerOld(clickData)
                                    end
                                end
                                self:clickBaseEffect(clickData, clickHandler)
                            end
                        end
                    elseif piexlPoint == nil and pt ~= nil then
                        PlayEffect(audioCfg.mouseClick)
                        local clickData = worldBaseVoApi:getBaseVo(pt.x, pt.y)
                        local function clickHandler()
                            if(base.landFormOpen == 1)then
                                self:clickIslandHandler(clickData)
                            else
                                self:clickIslandHandlerOld(clickData)
                            end
                        end
                        self:clickBaseEffect(clickData, clickHandler)
                    end
                end
            else
                if self.clickAreaAble == true then
                    --self.firstOldPos
                    PlayEffect(audioCfg.mouseClick)
                    local mapPos = self.showLayer:convertToNodeSpace(self.firstOldPos)
                    
                    local realPoint = ccp(mapPos.x, self.worldSize.height - mapPos.y)
                    local piexlPoint, pt = self:getNearPiexlPoint(realPoint)
                    if piexlPoint ~= nil then
                        local baseVo = worldBaseVoApi:getBaseVo(pt.x, pt.y)
                        if baseVo == nil or (baseVo.type == 0 and baseVo.aid) then --如果该地块为空，或者地块为空但属于军团的领地时都可以操作此地块
                            self:showSelectedArea(piexlPoint.x, piexlPoint.y, pt.x, pt.y)
                        end
                    end
                end
            end
        end
    else
        self.touchArr = nil
        self.touchArr = {}
    end
end

--地图方向标以及当前坐标
function worldScene:drawMapMoveAndDirectSign()
    if self.posTipBar == nil or self.posTipBar.status == 0 then
        self.posTipBar = tipDialog:showTipsBar(mainUI.myUILayer, ccp(320, G_VisibleSizeHeight + 26), ccp(320, G_VisibleSizeHeight - 180), "", 80, 11, false)
    end
    local screenCenterPosInClayer = self.showLayer:convertToNodeSpace(ccp(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    --local pxPos,indexPos=self:getNearPiexlPoint(screenCenterPosInClayer)
    local centerRealPos = ccp(screenCenterPosInClayer.x, self.worldSize.height - screenCenterPosInClayer.y)
    local pPos = ccp(math.floor((centerRealPos.x + 80 * self.curScale) / 160), math.floor((centerRealPos.y - 60 * self.curScale) / 100))
    local tipLb = tolua.cast(self.posTipBar.lable, "CCLabelTTF")
    if tipLb ~= nil then
        tipLb:setString(pPos.x..","..pPos.y)
    end
    mainUI:worldLandMove(pPos)
    mainUI:directSignMove(pPos)
end

function worldScene:checkBound(pos)
    
    local overXFlag, overYFlag = false, false
    local currentPos
    if pos == nil then
        currentPos = ccp(self.showLayer:getPosition())
    else
        currentPos = pos
    end
    if currentPos.x > 0 then
        currentPos.x = 0
        overXFlag = true
    end
    
    local limitW = (G_VisibleSize.width - self.worldSize.width * self.curScale)
    local limitH = (G_VisibleSize.height - (self.worldSize.height * self.curScale + self.topGap))
    if currentPos.x < limitW then
        currentPos.x = limitW
        overXFlag = true
    end
    
    if currentPos.y < limitH then
        currentPos.y = limitH
        overYFlag = true
    end
    
    if currentPos.y > self.bottomGap then
        currentPos.y = self.bottomGap
        overYFlag = true
    end
    if pos == nil then
        self.showLayer:setPosition(currentPos)
        if self.mapLayer then
            self.mapLayer:setPosition(self.clayer:getPosition())
        end
    else
        return currentPos, overXFlag, overYFlag
    end
end

function worldScene:showBase(needSendRequest)
    if self.clayer == nil then
        do return end
    end
    self.clickFlag = false
    local areaTb = {}
    local centerScenePoint = self.showLayer:convertToNodeSpace(ccp(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    
    local fourPoints = self:get4Points()
    for k, v in pairs(fourPoints) do
        if areaTb[v.x * 1000 + v.y] == nil and self.curShowBases[v.x * 1000 + v.y] == nil then --没有显示在地图上的，已经显示的不再进行处理
            areaTb[v.x * 1000 + v.y] = v.x * 1000 + v.y
        end
    end
    
    local needShowInMapTb = {}
    local needRequestFromServer = {}
    for k, v in pairs(areaTb) do
        local tmpTb = worldBaseVoApi:getBasesByArea(k)
        if((tmpTb == nil or SizeOfTable(tmpTb) < 2) and needSendRequest == true)then
            --if self.hasGetDataFromServer[k]==nil then
            needRequestFromServer[k] = v --需要请求服务器获取数据
        else
            needShowInMapTb[k] = tmpTb
        end
    end
    
    self:realShowBase(needShowInMapTb)
    if needSendRequest == true then
        if SizeOfTable(needRequestFromServer) > 0 then
            --发送网络请求
            local retMinX, retMinY, retMaxX, retMaxY = 9999, 9999, 0, 0
            for k, v in pairs(needRequestFromServer) do
                local minX, maxX, minY, maxY = worldScene:getMinAndMaxXYByAreaID(v)
                if retMinX > minX then
                    retMinX = minX
                end
                if retMinY > minY then
                    retMinY = minY
                end
                if maxX > retMaxX then
                    retMaxX = maxX
                end
                if maxY > retMaxY then
                    retMaxY = maxY
                end
            end
            local function serverResponseHandler(fn, data)
                
                local retStr, retTb = base:checkServerData(data, false)
                
                if not retTb then
                    do return end
                end
                if retTb and retTb.ret == -151 then
                    base.mapCoolingEndTs = retTb and retTb.data and retTb.data.forbidTs or base.serverTime + 3600
                    G_showCoolingTimeTip(-151)
                    do return end
                end
                
                --local retTb=OBJDEF:decode(data)
                if retTb.msg ~= "Success" then
                    do
                        
                        return false
                    end
                end
                -- worldBaseVoApi:setGoldmineFlag(true)
                --检查验证码
                -- print("base.isCheckCode ========== "..base.isCheckCode)
                if base.isCheckCode == 1 then
                    -- print("self.checkcodeValue ======== "..self.checkcodeValue)
                    local checkcodeNum = CCUserDefault:sharedUserDefault():getIntegerForKey(G_checkCodeKey..playerVoApi:getUid())
                    CCUserDefault:sharedUserDefault():setIntegerForKey(G_checkCodeKey..playerVoApi:getUid(), (checkcodeNum + self.checkcodeValue))
                    CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastMapscoutTime..playerVoApi:getUid(), base.serverTime)
                    CCUserDefault:sharedUserDefault():flush()
                end
                --做一个兼容性处理，如果用户没有重新登录游戏然后打开了地图，后台的data.map是字符串，而客户端的开关没有开，这时候会报错
                --长度大于20是为了防止后端返回空字符串或者false之类其他异常情况
                if(base.fsaok == 1 or (type(retTb.data.map) == "string" and string.len(retTb.data.map) > 20))then
                    if(type(retTb.data.map) == "string")then
                        local decodeData = G_decodeMap2(retTb.data.map, retTb.data.faker)
                        if(type(decodeData) == "string" and string.len(decodeData) > 20)then
                            retTb.data.map = G_Json.decode(decodeData)
                        end
                    end
                end
                if(retTb.data.map == nil or type(retTb.data.map) ~= "table")then
                    retTb.data.map = {}
                end
                for k, v in pairs(retTb.data.map) do
                    if tonumber(v[4]) == 9 then --记录欧米伽小队地块坐标
                        if self.omegaPosTb == nil then
                            self.omegaPosTb = {}
                        end
                        table.insert(self.omegaPosTb, {x = tonumber(v[2]), y = tonumber(v[3])})
                    end
                    --[[
                                     local ttppoint=self:toPiexl(ccp(tonumber(v[2]),tonumber(v[3])))
                                     local ttareaX=math.ceil(ttppoint.x/1000)
                                     local ttareaY=math.ceil(ttppoint.y/1000)
                                     if self.hasGetDataFromServer[ttareaX*1000+ttareaY]==nil then
                                            self.hasGetDataFromServer[ttareaX*1000+ttareaY]=1
                                     end
                                     ]]
                    worldBaseVoApi:add(tonumber(v[1]), tonumber(v[7]), v[8], tonumber(v[4]), tonumber(v[5]), tonumber(v[2]), tonumber(v[3]), tonumber(v[10]), tonumber(v[9]), tonumber(v[11]), tonumber(v[12]), v[13], tonumber(v[14]), tonumber(v[15]), v[16], tonumber(v[17]), tonumber(v[18]), tonumber(v[19]), tonumber(v[20]), tonumber(v[21]), tonumber(v[22]), tonumber(v[23]), v[24], v[25], v[26], v[27])
                end
                
                -- --测试使用
                --  retTb.data.goldMineMap={
                --    ["61591"]={61591,1478780023,40},
                --    ["62192"]={62192,1478780083,40},
                --    ["62791"]={62791,1478780143,40},
                --    }
                
                if retTb.data.goldMineMap then
                    for k, v in pairs(retTb.data.goldMineMap) do
                        goldMineVoApi:addGoldMine(tonumber(v[1]), tonumber(v[3]), tonumber(v[2]))
                    end
                end
                if retTb.data.privateMineMap then
                    for k, v in pairs(retTb.data.privateMineMap) do
                        privateMineVoApi:addprivateMine(tonumber(v[1]), tonumber(v[2]))
                    end
                end
                
                if(retTb.data.eagleEyeMap)then
                    skillVoApi:formatEagleEyeData(retTb.data.eagleEyeMap)
                end
                self:showBase(false)
                self:checkRemoveBase()
                self.clickAreaAble = true
                if self.buildingSp then
                    self:adjustBuildingSp(true)
                    -- self:showOperateLayer()
                end
            end
            
            local function realGetWorldMap()
                if base.mapCoolingEndTs and base.serverTime < base.mapCoolingEndTs then --地图请求次数过多，认定为外挂，则在冷却时间内不允许再次请求
                    G_showCoolingTimeTip(-151)
                    do return end
                end
                if G_isUseNewMap() == false then
                    base:setNetWait()
                end
                -- local flag=worldBaseVoApi:getGoldmineFlag()
                local goldmineflag
                if base.wl == 1 and base.goldmine == 1 then
                    goldmineflag = 1
                end
                local privatemineFlag = base.privatemine == 1 and 1 or nil
                --鹰眼技能
                local eagleEye = skillVoApi:checkEagleEyeInit()
                if(eagleEye)then
                    socketHelper:getWorldMap(retMinX, retMinY, retMaxX, retMaxY, nil, goldmineflag, privatemineFlag, serverResponseHandler)
                else
                    socketHelper:getWorldMap(retMinX, retMinY, retMaxX, retMaxY, 1, goldmineflag, privatemineFlag, serverResponseHandler)
                end
                --检测扫矿是否合法
                local searchFlag = worldBaseVoApi:getSearchFlag()
                if searchFlag == true then
                    worldBaseVoApi:checkSaokIllegal()
                    worldBaseVoApi:setSearchFlag(false)
                end
            end
            
            local function checkcodeHandler()
                local function checkcodeSuccess(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        -- print("++++++++领取奖励成功++++++++1111111111")
                        --领取验证码奖励成功后再更新lastCheckcodeNum
                        local checkcodeNum = CCUserDefault:sharedUserDefault():getIntegerForKey(G_checkCodeKey..playerVoApi:getUid())
                        CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastCheckCodeKey..playerVoApi:getUid(), checkcodeNum)
                        CCUserDefault:sharedUserDefault():flush()
                        if sData and sData.data and sData.data.reward then
                            local reward = FormatItem(sData.data.reward)
                            local rewardStr = getlocal("daily_lotto_tip_10")
                            if reward then
                                for k, v in pairs(reward) do
                                    if k == SizeOfTable(reward) then
                                        rewardStr = rewardStr .. v.name .. " x" .. v.num
                                    else
                                        rewardStr = rewardStr .. v.name .. " x" .. v.num .. ","
                                    end
                                end
                                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), rewardStr, 30)
                            end
                        end
                    elseif sData.ret == -6010 then
                        -- print("++++++++领取奖励失败++++++++1111111111")
                        CCUserDefault:sharedUserDefault():setIntegerForKey(G_checkCodeKey..playerVoApi:getUid(), G_maxCheckCount)
                        CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastCheckCodeKey..playerVoApi:getUid(), G_maxCheckCount)
                        CCUserDefault:sharedUserDefault():flush()
                    end
                    realGetWorldMap()
                end
                socketHelper:checkcodereward(checkcodeSuccess)
            end
            
            if G_isCheckCode() == true then
                local layerNum = 4
                smallDialog:initCheckCodeDialog(layerNum, checkcodeHandler)
            else
                realGetWorldMap()
            end
        else --不需要请求服务器
            self.clickAreaAble = true
        end
    end
end

function worldScene:realShowBase(dataTb, isMoveBase)
    if self.clayer == nil then
        do return end
    end
    if self.mapFogSp then
        self.mapFogSp:stopAllActions()
    end
    for k, v in pairs(dataTb) do
        if self.curShowBases[k] == nil then
            self.curShowBases[k] = {}
        end
        for kk, vv in pairs(v) do
            -- print("vv.type,vv.x,vv.y,vv.aid,vv.oid--------->>>",vv.type,vv.x,vv.y,vv.aid,vv.oid)
            if base.allianceCitySwitch == 1 then
                if self:checkIsTerritory(vv) == true then --检测是否是军团领地
                    self:drawTerritoryBoundary(vv.x, vv.y) --画城市领地分界线
                else
                    self:removeTerritoryBoundary(vv.x, vv.y) --移除领地分界线
                end
            end
            if vv.type and vv.type == 0 and vv.aid == 0 then --如果是空地则移除
                worldBaseVoApi:removeBaseVo(vv.x, vv.y)
            end
            if self.curShowBases[k][vv.x * 1000 + vv.y] == nil and vv.type ~= 0 and vv.type then
                local function baseClick()
                    if G_isUseNewMap() == true then --如果是新地图的话，所有的触摸事件处理都是在touchEvent里面
                        do return end
                    end
                    if self.touchEnable == false then
                        return
                    end
                    if G_checkClickEnable() == false then
                        do
                            return
                        end
                    end
                    if self.isMoved == false then
                        base.setWaitTime = G_getCurDeviceMillTime()
                        PlayEffect(audioCfg.mouseClick)
                        if(base.landFormOpen == 1)then
                            self:clickIslandHandler(vv)
                        else
                            self:clickIslandHandlerOld(vv)
                        end
                    end
                end
                local illegalFlag = worldBaseVoApi:isIllegalSaok()
                if illegalFlag == true then
                    if vv.richLv then
                        vv.richLv = 0
                    end
                end
                local mineLv = vv.curLv
                local flag, level = goldMineVoApi:isGoldMine(vv.id)
                if flag == true then
                    mineLv = level
                end
                -- print("vv.type,vv.x,vv.y,vv.level---->",vv.type,vv.x,vv.y,vv.level)
                local resStr, isSkin = worldBaseVoApi:getBaseResource(vv.type, mineLv, vv.oid, vv, vv.skinInfo)
                local baseSp
                if(vv.type == 7)then
                    baseSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(0, 0, 10, 10), baseClick)
                    baseSp:setOpacity(0)
                    local tankSp, tankID
                    if vv.pic and vv.pic >= 100 then
                        local picName = rebelVoApi:getSpecialRebelPic(vv.pic)
                        if picName then
                            local function clickHandler()
                            end
                            tankSp = LuaCCSprite:createWithSpriteFrameName(picName, clickHandler)
                        else
                            tankID = tonumber(RemoveFirstChar(rebelVoApi:getRebelIconTank(vv.level, vv.rebelIndex)))
                            tankSp = G_getTankPic(tankID, nil, nil, nil, nil, false)
                        end
                    else
                        tankID = tonumber(RemoveFirstChar(rebelVoApi:getRebelIconTank(vv.level, vv.rebelIndex)))
                        tankSp = G_getTankPic(tankID, nil, nil, nil, nil, false)
                    end
                    if tankSp then
                        local iconH = 90
                        if tankID then
                            if tonumber(tankID) == 10025 or tonumber(tankID) == 20153 then
                                iconH = 160
                            end
                        end
                        tankSp:setScale(iconH / tankSp:getContentSize().height)
                        tankSp:setPosition(80, 50)
                        tankSp:setIsSallow(false)
                        baseSp:addChild(tankSp)
                    end
                elseif (vv.type == 8) then --军团城市
                    local realx, realy = self:getBaseSpRealPoint(vv)
                    if realx and realy then
                        local bx, by = worldBaseVoApi:getAreaXY(realx, realy)
                        if self.curShowBases[bx] == nil or self.curShowBases[bx][by] == nil then
                            if self.curShowBases[bx] == nil then
                                self.curShowBases[bx] = {}
                            end
                            baseSp = allianceCityVoApi:getAllianceCityIcon(baseClick, 1)
                            self.curShowBases[bx][by] = baseSp
                            
                            local cx, cy = self:toCityPiexl(realx, realy)
                            baseSp:setPosition(cx, cy)
                            local nameStr = vv.allianceName
                            local cityNameLb = GetTTFLabelWrap(nameStr, 24, CCSizeMake(250, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                            local tmpLb = GetTTFLabel(nameStr, 24)
                            local realW = tmpLb:getContentSize().width
                            if realW > cityNameLb:getContentSize().width then
                                realW = cityNameLb:getContentSize().width
                            end
                            realW = realW + 40
                            if realW < 120 then
                                realW = 120
                            end
                            local realH = 36
                            if realH < (cityNameLb:getContentSize().height + 4) then
                                realH = cityNameLb:getContentSize().height + 4
                            end
                            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png", CCRect(20, 20, 10, 10), function () end)
                            nameBg:setAnchorPoint(ccp(0, 0.5))
                            nameBg:setOpacity(255 * 0.7)
                            nameBg:setContentSize(CCSizeMake(realW, realH))
                            nameBg:setPosition(baseSp:getContentSize().width / 2 - 30, 40)
                            baseSp:addChild(nameBg, 2)
                            cityNameLb:setPosition(getCenterPoint(nameBg))
                            -- cityNameLb:setColor(G_ColorYellowPro)
                            nameBg:addChild(cityNameLb)
                            nameBg:setScale(0.7)
                            
                            --如果是玩家自己的军团城市
                            if vv.oid == playerVoApi:getUid() or (allianceVoApi:getSelfAlliance() ~= nil and vv.allianceName == allianceVoApi:getSelfAlliance().name) then
                                cityNameLb:setColor(G_ColorYellowPro)
                            end
                            
                            local baseVo = worldBaseVoApi:getBaseVo(realx, realy)
                            if baseVo.ptEndTime and baseVo.ptEndTime > 0 then
                                self:addCityProtect(baseVo.x, baseVo.y, baseVo.ptEndTime)
                            end
                            if base.isAf == 1 then
                                if vv.allianceName and vv.allianceName ~= "" then -- 有军团
                                    local defaultSelect
                                    -- 军团旗帜
                                    defaultSelect = allianceVoApi:getFlagIconTab(vv.banner)
                                    local allianceSp = allianceVoApi:createShowFlag(defaultSelect[1], defaultSelect[2], defaultSelect[3], 0.2 * 0.7)
                                    allianceSp:setPosition(ccp(nameBg:getPositionX() - 45, nameBg:getPositionY()))
                                    baseSp:addChild(allianceSp, 2)
                                    allianceSp:setTag(103)
                                end
                            end
                        end
                    end
                elseif (vv.type == 0 and vv.aid) then --空的领地
                elseif (vv.type == 9) then --飞艇欧米伽小队
                    if airShipVoApi:isOpen() == true then
                        local realx, realy = self:getBaseSpRealPoint(vv)
                        print("cjl ----->>> 1", realx, realy)
                        if realx and realy and vv.extendData and vv.extendData.b then
                            local bx, by = worldBaseVoApi:getAreaXY(realx, realy)
                            if self.curShowBases[bx] == nil or self.curShowBases[bx][by] == nil then
                                print("cjl ----->>> 2", bx, by)
                                if self.curShowBases[bx] == nil then
                                    self.curShowBases[bx] = {}
                                end
                                local cx, cy = self:toCityPiexl(realx, realy)
                                -- local tankID = airShipVoApi:getBossWorldMapTankId(vv.extendData.b[1])
                                -- baseSp = G_getTankPic(tankID, baseClick, nil, nil, nil, false)
                                baseSp = worldScene:createOmegaTroops(vv.extendData.b[3] or "s1", cx, cy, baseClick)
                                self.curShowBases[bx][by] = baseSp
                                local bossTypeIcon = CCSprite:createWithSpriteFrameName(airShipVoApi:getBossIconPic(vv.extendData.b[2]))
                                if bossTypeIcon then
                                    local iconBg = CCSprite:createWithSpriteFrameName("productItemBg.png")
                                    iconBg:setAnchorPoint(ccp(0.5, 1))
                                    iconBg:setScale(50 / iconBg:getContentSize().width)
                                    iconBg:setPosition(ccp(baseSp:getContentSize().width / 2, baseSp:getContentSize().height))
                                    baseSp:addChild(iconBg)
                                    bossTypeIcon:setScale(iconBg:getContentSize().width / bossTypeIcon:getContentSize().width)
                                    bossTypeIcon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2 + 6)
                                    iconBg:addChild(bossTypeIcon)
                                end
                                local nameStr = getlocal("airShip_worldTroops")
                                local cityNameLb = GetTTFLabelWrap(nameStr, 24, CCSizeMake(250, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                                local tmpLb = GetTTFLabel(nameStr, 24)
                                local realW = tmpLb:getContentSize().width
                                if realW > cityNameLb:getContentSize().width then
                                    realW = cityNameLb:getContentSize().width
                                end
                                realW = realW + 40
                                if realW < 120 then
                                    realW = 120
                                end
                                local realH = 36
                                if realH < (cityNameLb:getContentSize().height + 4) then
                                    realH = cityNameLb:getContentSize().height + 4
                                end
                                local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png", CCRect(20, 20, 10, 10), function () end)
                                nameBg:setAnchorPoint(ccp(0.5, 0.5))
                                nameBg:setOpacity(255 * 0.7)
                                nameBg:setContentSize(CCSizeMake(realW, realH))
                                nameBg:setPosition(baseSp:getContentSize().width / 2, 40)
                                baseSp:addChild(nameBg, 2)
                                cityNameLb:setPosition(getCenterPoint(nameBg))
                                -- cityNameLb:setColor(G_ColorYellowPro)
                                nameBg:addChild(cityNameLb)
                                nameBg:setScale(0.7)
                            end
                        end
                    end
                else
                    baseSp = LuaCCSprite:createWithSpriteFrameName(resStr, baseClick)
                    if G_isUseNewMap() == true then
                        if vv.type >= 1 and vv.type <= 5 then
                            if vv.type == 1 then
                                local spcArr = CCArray:create()
                                for kk = 1, 8 do
                                    local nameStr = "tie_kuang_building_"..kk..".png"
                                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                    spcArr:addObject(frame)
                                end
                                local animation = CCAnimation:createWithSpriteFrames(spcArr)
                                animation:setDelayPerUnit(0.3)
                                local animate = CCAnimate:create(animation)
                                local repeatForever = CCRepeatForever:create(animate)
                                baseSp:runAction(repeatForever)
                                
                                baseSp:setScale(0.5)
                            elseif vv.type == 2 then
                                local spcArr = CCArray:create()
                                for kk = 1, 8 do
                                    local nameStr = "shi_you_building_"..kk..".png"
                                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                    spcArr:addObject(frame)
                                end
                                local animation = CCAnimation:createWithSpriteFrames(spcArr)
                                animation:setDelayPerUnit(0.3)
                                local animate = CCAnimate:create(animation)
                                local repeatForever = CCRepeatForever:create(animate)
                                baseSp:runAction(repeatForever)
                                
                                baseSp:setScale(0.5)
                            elseif vv.type == 5 then
                                local spcArr = CCArray:create()
                                for kk = 1, 8 do
                                    local nameStr = "shui_jing_world_building_"..kk..".png"
                                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                    spcArr:addObject(frame)
                                end
                                local animation = CCAnimation:createWithSpriteFrames(spcArr)
                                animation:setDelayPerUnit(0.3)
                                local animate = CCAnimate:create(animation)
                                local repeatForever = CCRepeatForever:create(animate)
                                baseSp:runAction(repeatForever)
                                
                                baseSp:setScale(0.5)
                            else
                                baseSp:setScale(0.5)
                            end
                        end
                    end
                end
                if baseSp then
                    if base.isGlory == 1 and vv.type == 6 then--------------------------------------------------------------------Glory 示意显示（需修改的！！！）
                        self:fireBuilding(baseSp, vv.oid, vv.type, vv.boomBmd)
                    end----------------------------------------------------------------------------------------------------
                    if vv.type == 6 then
                        local scaleNum = 0.5
                        if isSkin == "b11" or isSkin == "b12" or isSkin == "b13" then
                            scaleNum = 0.35
                        end
                        baseSp:setScale(scaleNum)
                        baseSp.szieScale = scaleNum
                    elseif(vv.type == 7)then
                        baseSp:setContentSize(CCSizeMake(160, 100))
                    end
                    if vv.oid == playerVoApi:getUid() and vv.type == 6 then
                        self.buildSelfTb = vv
                        self.fireBuildParent = baseSp
                        self.firebuildBg = nil
                        self.isGloryOver = false
                    end
                    baseSp:setAnchorPoint(ccp(0.5, 0.5))
                    local toLayerPoint = self:toPiexl(ccp(vv.x, vv.y))
                    baseSp:setTouchPriority(-1)
                    baseSp:setIsSallow(false)
                    if vv.type ~= 8 and vv.type ~= 9 then
                        local realPoint = ccp(toLayerPoint.x, self.worldSize.height - toLayerPoint.y)
                        baseSp:setPosition(realPoint)
                    end
                    self.clayer:addChild(baseSp, 10 + vv.y)
                    if vv.type ~= 8 and vv.type ~= 9 then
                        if self.curShowBases[k] == nil then
                            self.curShowBases[k] = {}
                        end
                        self.curShowBases[k][vv.x * 1000 + vv.y] = baseSp
                    end
                    if G_isUseNewMap() == true and self.mapTileObjs[k] and self.mapTileObjs[k][vv.x * 1000 + vv.y] then
                        local ornamentalSp = self.mapTileObjs[k][vv.x * 1000 + vv.y]
                        if ornamentalSp then
                            ornamentalSp = tolua.cast(ornamentalSp, "CCSprite")
                            if ornamentalSp then
                                ornamentalSp:setVisible(false)
                            end
                        end
                    end
                    --table.insert(self.curShowBases[k],baseSp)
                    if(vv.type == 7)then
                        local middleX = baseSp:getContentSize().width / 2
                        local lb = GetTTFLabel(vv.name, 20)
                        local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("rebelNameBg.png", CCRect(10, 4, 2, 2), function (...)end)
                        nameBg:setOpacity(200)
                        nameBg:setContentSize(CCSizeMake(lb:getContentSize().width + 20, lb:getContentSize().height + 4))
                        nameBg:setPosition(middleX, 15)
                        baseSp:addChild(nameBg)
                        lb:setPosition(nameBg:getContentSize().width / 2, nameBg:getContentSize().height / 2)
                        nameBg:addChild(lb)
                        local lvTipBg = CCSprite:createWithSpriteFrameName("rebelIconLevel.png")
                        lvTipBg:setPosition(middleX - 65, baseSp:getContentSize().height - 5)
                        baseSp:addChild(lvTipBg, 1)
                        local lvTipLb = GetTTFLabel(vv.level, 22)
                        lvTipLb:setPosition(middleX - 65, lvTipBg:getPositionY())
                        baseSp:addChild(lvTipLb, 1)
                        local progressBg = CCSprite:createWithSpriteFrameName("rebelProgressBg.png")
                        progressBg:setScaleX(122 / progressBg:getContentSize().width)
                        progressBg:setPosition(middleX, lvTipBg:getPositionY())
                        baseSp:addChild(progressBg)
                        local progressHp = CCSprite:createWithSpriteFrameName("rebelProgress.png")
                        progressHp:setTag(101)
                        progressHp:setAnchorPoint(ccp(0, 0.5))
                        progressHp:setScaleX(vv.hp / vv.maxHp * 120 / progressHp:getContentSize().width)
                        progressHp:setPosition(middleX - 60, lvTipBg:getPositionY())
                        baseSp:addChild(progressHp)
                        local lbHp = GetTTFLabel(G_keepNumber(vv.hp / vv.maxHp * 100, 2) .. "%", 20)
                        lbHp:setTag(103)
                        lbHp:setPosition(middleX, lvTipBg:getPositionY())
                        baseSp:addChild(lbHp)
                        local lbTime = GetTTFLabel(GetTimeStr(math.max(vv.ptEndTime - base.serverTime, 0)), 20)
                        lbTime:setTag(104)
                        lbTime:setOpacity(0)
                        lbTime:setPosition(middleX, lvTipBg:getPositionY())
                        baseSp:addChild(lbTime)
                    elseif vv.type == 6 then --玩家基地
                        
                        buildDecorateVoApi:playSkinAction(isSkin, baseSp)
                        -- print("--------vv.x,vv.y",vv.x,vv.y)
                        local lb = GetTTFLabel((vv.name == "" and "****" or vv.name), 30, true)
                        lb:setAnchorPoint(ccp(0.5, 0.5))
                        --baseSp:setUData(6)
                        --lb:setPosition(ccp(baseSp:getContentSize().width/2,baseSp:getContentSize().height/2))
                        
                        --如果是玩家自己 或 自己同一联盟成员
                        if vv.oid == playerVoApi:getUid() or (allianceVoApi:getSelfAlliance() ~= nil and vv.allianceName == allianceVoApi:getSelfAlliance().name) then
                            lb:setColor(G_ColorYellowPro)
                        end
                        
                        local function userNameClick()
                            
                        end
                        local userNameSp = LuaCCScale9Sprite:createWithSpriteFrameName("BattleTankNumBg.png", CCRect(10, 4, 2, 2), userNameClick)
                        userNameSp:setOpacity(200)
                        userNameSp:setAnchorPoint(ccp(0.5, 0.5))
                        userNameSp:setPosition(ccp(baseSp:getContentSize().width / 2, 40))
                        baseSp:addChild(userNameSp, 4)
                        --baseSp:addChild(lb)
                        userNameSp:setContentSize(CCSizeMake(lb:getContentSize().width + 15, lb:getContentSize().height + 4))
                        userNameSp:addChild(lb)
                        lb:setTag(1001)
                        lb:setPosition(ccp(userNameSp:getContentSize().width / 2, userNameSp:getContentSize().height / 2))
                        userNameSp:setTag(100)
                        userNameSp:setVisible(self.showInfo)
                        
                        local showProtectSp = false
                        if vv.oid == playerVoApi:getUid() then --玩家自己
                            if playerVoApi:getProtectEndTime() > base.serverTime then
                                showProtectSp = true
                            end
                        else
                            if vv.ptEndTime > base.serverTime then
                                showProtectSp = true
                            end
                        end
                        if showProtectSp == true then
                            local protectedSp = CCSprite:createWithSpriteFrameName("ShieldingShape.png")
                            protectedSp:setAnchorPoint(ccp(0.5, 0.5))
                            protectedSp:setPosition(ccp(baseSp:getContentSize().width / 2 + 10, baseSp:getContentSize().height / 2))
                            baseSp:addChild(protectedSp)
                            protectedSp:setTag(102)
                            protectedSp:setScale(1.9)
                            if isSkin == "b11" or isSkin == "b12" or isSkin == "b13"then
                                protectedSp:setScale(3.3)
                            end
                        end
                        local nameSpScale = 1
                        if isSkin == "b11" or isSkin == "b12" or isSkin == "b13" then
                            nameSpScale = 0.5 / 0.35
                            userNameSp:setScale(nameSpScale)
                        end
                        if base.isAf == 1 then
                            if vv.oid == playerVoApi:getUid() and allianceVoApi:getSelfAlliance() == nil then
                                -- 是自己且没有军团
                            elseif vv.allianceName and vv.allianceName ~= "" then -- 有军团
                                local defaultSelect
                                -- 军团
                                defaultSelect = allianceVoApi:getFlagIconTab(vv.banner)
                                -- 新的军团图标
                                local allianceSp = allianceVoApi:createShowFlag(defaultSelect[1], defaultSelect[2], defaultSelect[3], 0.2)
                                allianceSp:setPosition(ccp(userNameSp:getPositionX() - userNameSp:getContentSize().width / 2 * nameSpScale - 20, userNameSp:getPositionY()))
                                baseSp:addChild(allianceSp, 2)
                                allianceSp:setTag(103)
                                if isSkin == "b11" or isSkin == "b12" or isSkin == "b13" then
                                    allianceSp:setScale(0.1 / 0.35)
                                end
                            end
                        else
                            if allianceVoApi:getSelfAlliance() ~= nil and vv.allianceName == allianceVoApi:getSelfAlliance().name then
                                local allianceSp = CCSprite:createWithSpriteFrameName("ArmyGroupIcon.png")
                                allianceSp:setAnchorPoint(ccp(1, 0.5))
                                allianceSp:setPosition(ccp(userNameSp:getPositionX() - userNameSp:getContentSize().width / 2 * nameSpScale, userNameSp:getPositionY()))
                                baseSp:addChild(allianceSp, 2)
                                allianceSp:setTag(103)
                                if isSkin == "b11" or isSkin == "b12" or isSkin == "b13" then
                                    allianceSp:setScale(0.1 / 0.35)
                                end
                            end
                        end
                    elseif vv.type == 9 then --欧米伽小队
                    else
                        self:baseShowLvTip(baseSp, vv)
                    end
                    baseSp:setVisible(false)
                    -- if baseSp.setCascadeColorEnabled then
                    --   baseSp:setCascadeColorEnabled(true)
                    --   baseSp:setOpacity(0)
                    --   local rdtime=math.random(1,9)*0.03
                    --   local fadeto=CCFadeTo:create(0.3+rdtime,255)
                    --   baseSp:runAction(fadeto)
                    -- end
                end
            else
                if vv.type ~= 6 and vv.type ~= 7 and vv.type ~= 9 and vv.type ~= 0 and self.curShowBases[k][vv.x * 1000 + vv.y] then
                    self:baseShowLvTip(self.curShowBases[k][vv.x * 1000 + vv.y], vv)
                end
            end
        end
    end
    
    self:checkIfHide()
    if self.targetItemPos then
        self:blinkOnFocus()
    end
    G_setWholeSkin(G_isOpenWinterSkin)
end

function worldScene:clickIslandHandler(islandData)
    local island = islandData
    local islandType
    if island.type == 6 then
        if island.oid == playerVoApi:getUid() then
            islandType = 1
        else
            islandType = 2
        end
    elseif(island.type == 7)then
        local function showDialog()
            require "luascript/script/game/scene/gamedialog/worldRebelSmallDialog"
            local sd = worldRebelSmallDialog:new(island)
            sd:init(3)
        end
        rebelVoApi:rebelGet(showDialog, 1)
        do return end
    elseif (island.type == 8 and island.oid > 0) then --如果是军团城市话，打开查看军团城市的页面
        if base.allianceCitySwitch == 0 then --如果该地块属于军团城市，但是功能开关没有开，则提示玩家）
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage26000"), 28)
            do return end
        end
        local isOther = false
        local myAlliance = allianceVoApi:getSelfAlliance()
        if myAlliance == nil or myAlliance.aid == nil or myAlliance.aid ~= island.oid then --不是自己军团
            isOther = true
        end
        require "luascript/script/game/gamemodel/alliance/allianceCity/allianceCityCheckVo"
        local checkVo = allianceCityCheckVo:new()
        local realx, realy = self:getBaseSpRealPoint(island)
        local baseVo = worldBaseVoApi:getBaseVo(realx, realy)
        checkVo:initWithData(baseVo)
        local function showCityDialog()
            allianceCityVoApi:showCheckCityDialog(checkVo, isOther, 3)
        end
        if isOther == true then
            local flag = allianceCityVoApi:hasCity()
            if flag == false and myAlliance and myAlliance.aid > 0 then
                allianceCityVoApi:initCity(showCityDialog)
            else
                showCityDialog()
            end
        else --请求数据
            local function checkHandler()
                local function checkCity(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        if sData.data then
                            if sData.data.acitydetail then
                                checkVo:initWithData(sData.data.acitydetail) --更新城市数据
                            end
                            allianceCityVoApi:updateData(sData.data) --同步user数据
                            showCityDialog()
                        end
                    end
                end
                socketHelper:scoutAllianceCity({checkVo.x, checkVo.y}, checkCity)
            end
            local flag = allianceCityVoApi:hasCity()
            if flag == false then
                allianceCityVoApi:initCity(checkHandler)
            else
                checkHandler()
            end
        end
        do return end
    elseif (island.type == 9) then --如果是欧米伽小队
        if airShipVoApi:isCanEnter(true) == true then
            if base.serverTime >= island.extendData.eTs then
                G_showTipsDialog(getlocal("backstage65021"))
            else
                print("cjl ------>>> 打开欧米伽小队面板")
                airShipVoApi:showWorldAirShipDialog(island, 3)
            end
        end
        do return end
    else
        islandType = 3
    end
    local function showBaseSmallDialog(extra)
        require "luascript/script/game/scene/gamedialog/worldBaseSmallDialog"
        local sd = worldBaseSmallDialog:new(islandType, island, extra)
        return sd:init(3)
    end
    if island.type == 6 then --如果查看的是玩家基地的话，会拉取一些玩家数据（比如该玩家被战机革新技能攻击的数据等）
        if tonumber(island.oid) ~= tonumber(playerVoApi:getUid()) then
            local function getinfoCallBack(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    if sData and sData.data and sData.data.usergetinfo then
                        showBaseSmallDialog(sData.data.usergetinfo)
                    end
                end
            end
            print("island.oid", island.oid)
            socketHelper:alienMinesGetEnemyInfo(island.oid, getinfoCallBack)
        else
            local extra = {flags = {ba = playerVo.flags.ba}} --战机革新戏谑信息
            showBaseSmallDialog(extra)
        end
    else
        showBaseSmallDialog()
    end
end

function worldScene:clickBaseEffect(clickData, clickHandler)
    if clickData and clickData.x and clickData.y then
        local baseVo = worldBaseVoApi:getBaseVo(clickData.x, clickData.y)
        if (baseVo.type == 8 and baseVo.aid) or baseVo.type == 9 then
            clickData.x, clickData.y = self:getBaseSpRealPoint(baseVo)
        end
        if clickData.x == nil or clickData.y == nil then
            self.clickFlag = false
            do return end
        end
        self.clickFlag = true
        local x, y = worldBaseVoApi:getAreaXY(clickData.x, clickData.y)
        if(self.curShowBases == nil or self.curShowBases[x] == nil)then
            self.clickFlag = false
            do return end
        end
        local baseSp = self.curShowBases[x][y]
        if baseSp then
            baseSp = tolua.cast(baseSp, "LuaCCSprite")
            if baseSp then
                if baseSp then
                    local acArr = CCArray:create()
                    local rgbv = 255
                    local fadeOut = CCTintTo:create(0.2, 80, 80, 80)
                    local fadeIn = CCTintTo:create(0.2, rgbv, rgbv, rgbv)
                    local function fadeEnd()
                        self.clickFlag = false
                        if clickHandler then
                            clickHandler()
                        end
                    end
                    local fadeCall = CCCallFunc:create(fadeEnd)
                    acArr:addObject(fadeOut)
                    acArr:addObject(fadeIn)
                    acArr:addObject(fadeCall)
                    local seq = CCSequence:create(acArr)
                    baseSp:runAction(seq)
                end
            end
        else
            self.clickFlag = false
        end
    end
end

function worldScene:clickIslandHandlerOld(islandData)
    local island = islandData
    local islandType
    if island.type == 6 then
        if island.oid == playerVoApi:getUid() then
            islandType = 1
        else
            islandType = 2
        end
    else
        islandType = 3
    end
    local bookmarkTypeTab = {0, 0, 0}
    local function writeHandler(tag, object)
        if island.type ~= 6 then
            do return end
        end
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        local target = island.name
        local lyNum = 4
        emailVoApi:showWriteEmailDialog(lyNum, getlocal("email_write"), target)
        PlayEffect(audioCfg.mouseClick)
    end
    local writeBtn = GetButtonItem("worldBtnModify.png", "worldBtnModify_Down.png", "worldBtnModify_Down.png", writeHandler, nil, nil, nil)
    local writeSpriteMenu = CCMenu:createWithItem(writeBtn)
    writeSpriteMenu:setAnchorPoint(ccp(1, 0))
    writeSpriteMenu:setPosition(ccp(480, 280))
    writeSpriteMenu:setTouchPriority(-4)
    
    local function openCollectHandler(tag, object)
        PlayEffect(audioCfg.mouseClick)
        if self.islandInfoDialog then
            self.islandInfoDialog.dialogLayer:setVisible(false)
            self.islandInfoDialog:close()
            self.islandInfoDialog = nil
        end
        local function operateHandler(tag1, object)
            PlayEffect(audioCfg.mouseClick)
            local selectIndex = self.btnTab[tag1]:getSelectedIndex()
            if selectIndex == 1 then
                bookmarkType = tag1
            else
                bookmarkType = 0
            end
            bookmarkTypeTab[tag1] = bookmarkType
        end
        
        self.btnTab = {}
        local tabBtn = CCMenu:create()
        for i = 1, 3 do
            local height = 0
            local tabBtnItem
            if i == 1 then
                local selectSp1 = CCSprite:createWithSpriteFrameName("worldBtnSelf.png")
                local selectSp2 = CCSprite:createWithSpriteFrameName("worldBtnSelf.png")
                local menuItemSp1 = CCMenuItemSprite:create(selectSp1, selectSp2)
                local selectSp3 = CCSprite:createWithSpriteFrameName("worldBtnSelf_Down.png")
                local selectSp4 = CCSprite:createWithSpriteFrameName("worldBtnSelf_Down.png")
                local menuItemSp2 = CCMenuItemSprite:create(selectSp3, selectSp4)
                tabBtnItem = CCMenuItemToggle:create(menuItemSp1)
                tabBtnItem:addSubItem(menuItemSp2)
                tabBtnItem:setPosition(0, height)
            elseif i == 2 then
                local selectSp1 = CCSprite:createWithSpriteFrameName("worldBtnEnemy.png")
                local selectSp2 = CCSprite:createWithSpriteFrameName("worldBtnEnemy.png")
                local menuItemSp1 = CCMenuItemSprite:create(selectSp1, selectSp2)
                local selectSp3 = CCSprite:createWithSpriteFrameName("worldBtnEnemy_Down.png")
                local selectSp4 = CCSprite:createWithSpriteFrameName("worldBtnEnemy_Down.png")
                local menuItemSp2 = CCMenuItemSprite:create(selectSp3, selectSp4)
                tabBtnItem = CCMenuItemToggle:create(menuItemSp1)
                tabBtnItem:addSubItem(menuItemSp2)
                tabBtnItem:setPosition(160, height)
            elseif i == 3 then
                local selectSp1 = CCSprite:createWithSpriteFrameName("worldBtnFriend.png")
                local selectSp2 = CCSprite:createWithSpriteFrameName("worldBtnFriend.png")
                local menuItemSp1 = CCMenuItemSprite:create(selectSp1, selectSp2)
                local selectSp3 = CCSprite:createWithSpriteFrameName("worldBtnFriend_Down.png")
                local selectSp4 = CCSprite:createWithSpriteFrameName("worldBtnFriend_Down.png")
                local menuItemSp2 = CCMenuItemSprite:create(selectSp3, selectSp4)
                tabBtnItem = CCMenuItemToggle:create(menuItemSp1)
                tabBtnItem:addSubItem(menuItemSp2)
                tabBtnItem:setPosition(320, height)
            end
            tabBtnItem:setAnchorPoint(CCPointMake(0, 0))
            tabBtnItem:registerScriptTapHandler(operateHandler)
            tabBtnItem:setSelectedIndex(0)
            tabBtn:addChild(tabBtnItem)
            tabBtnItem:setTag(i)
            self.btnTab[i] = tabBtnItem
        end
        tabBtn:setPosition(ccp(70, 20))
        
        local function returnHandler()
            local writeBtn = GetButtonItem("worldBtnModify.png", "worldBtnModify_Down.png", "worldBtnModify_Down.png", writeHandler, nil, nil, nil)
            local writeSpriteMenu = CCMenu:createWithItem(writeBtn)
            writeSpriteMenu:setAnchorPoint(ccp(1, 0))
            writeSpriteMenu:setPosition(ccp(480, 280))
            writeSpriteMenu:setTouchPriority(-4)
            
            local openCollectBtn = GetButtonItem("worldBtnadd.png", "worldBtnadd_Down.png", "worldBtnadd_Down.png", openCollectHandler, nil, nil, nil)
            local openCollectSpriteMenu = CCMenu:createWithItem(openCollectBtn)
            openCollectSpriteMenu:setAnchorPoint(ccp(1, 0))
            openCollectSpriteMenu:setPosition(ccp(480, 205))
            openCollectSpriteMenu:setTouchPriority(-4)
            
            self.islandInfoDialog = self:showIslandInfo(islandType, island, writeSpriteMenu, openCollectSpriteMenu)
        end
        local function saveHandler()
            local maxNum = bookmarkVoApi:getMaxNum()
            if bookmarkVoApi:getBookmarkNum(0) >= maxNum then
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("collect_border_max_num", {maxNum}), nil, 4)
                do return end
            end
            if bookmarkVoApi:isBookmark(island.x, island.y) then
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("collect_border_same_book_mark", {island.x, island.y}), nil, 4)
                do return end
            end
            
            local ifAddToNoTag = true
            local desc = G_getIslandName(island.type, island.name)..getlocal("city_info_level", {island.level})
            
            local function serverSuperMark(fn, data)
                --local retTb=OBJDEF:decode(data)
                
                if base:checkServerData(data) == true then
                end
            end
            
            socketHelper:markBookmark(bookmarkTypeTab, desc, island.x, island.y, serverSuperMark)
            return true
        end
        local title = getlocal("collect_border_title")
        local content1 = getlocal("collect_border_siteInfo")
        local nameStr = G_getIslandName(island.type, island.name)
        local content2 = getlocal("collect_border_name_loc", {nameStr, island.x, island.y})
        local content3 = getlocal("collect_border_type")
        local content = {{content1, 30}, {content2, 25}, {content3, 30}}
        local leftStr = getlocal("collect_border_return")
        local rightStr = getlocal("collect_border_save")
        local itemTab = {tabBtn}
        smallDialog:showPlayerInfoSmallDialog("PanelHeaderPopup.png", CCSizeMake(550, 450), CCRect(0, 0, 400, 400), CCRect(168, 86, 10, 10), leftStr, returnHandler, rightStr, saveHandler, title, content, nil, 3, 5, itemTab, nil, nil, island.pic, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, island.bpic)
    end
    local openCollectBtn = GetButtonItem("worldBtnadd.png", "worldBtnadd_Down.png", "worldBtnadd_Down.png", openCollectHandler, nil, nil, nil)
    local openCollectSpriteMenu = CCMenu:createWithItem(openCollectBtn)
    openCollectSpriteMenu:setAnchorPoint(ccp(1, 0))
    openCollectSpriteMenu:setPosition(ccp(480, 205))
    openCollectSpriteMenu:setTouchPriority(-4)
    
    self.islandInfoDialog = self:showIslandInfo(islandType, island, writeSpriteMenu, openCollectSpriteMenu)
end

function worldScene:showIslandInfo(islandType, island, writeSpriteMenu, openCollectSpriteMenu)
    local title
    local content = {}
    local content1
    local content2
    local content3
    local content4
    local leftStr
    local rightStr
    local itemTab = {}
    local leftHandler
    local rightHandler
    local titleSize = 30
    local labelSize = 25
    local function enterPort()
        mainUI:changeToMyPort()
    end
    local function scoutCallBack()
        print("---------dmj-----------scoutCallBack:scout")
        --判断是否被占领
        if island.oid == playerVoApi:getUid() then
            --smallDialog:showTipsDialog("SuccessPanelSmall.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("city_info_cant_scout_tip"),30)
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("city_info_cant_scout_tip"), true, 4)
            do return end
        end
        --判断被保护
        if island.ptEndTime >= base.serverTime then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("playerhavenoFightBuffview"), true, 4)
            do return end
        end
        --[[
        --判断是否是盟友 同联盟
        if island.allianceName and allianceVoApi:isSameAlliance(island.allianceName) then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("city_info_cant_attack_tip_1"),true,4)
            do return end
        end
        ]]
        local scoutRes = tonumber(mapCfg.scoutConsume[island.level]) or 0
        local function callBack()
            if playerVoApi:getGold() >= scoutRes then
                local function mapScoutHandler(fn, data)
                    local cresult, retTb = base:checkServerData(data)
                    if cresult == true then
                        if base.isCheckCode == 1 then
                            local checkcodeNum = CCUserDefault:sharedUserDefault():getIntegerForKey(G_checkCodeKey..playerVoApi:getUid())
                            CCUserDefault:sharedUserDefault():setIntegerForKey(G_checkCodeKey..playerVoApi:getUid(), (checkcodeNum + 10))
                            CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastMapscoutTime..playerVoApi:getUid(), base.serverTime)
                            CCUserDefault:sharedUserDefault():flush()
                            -- print("-----------dmj----------checkcodeNum:"..checkcodeNum.."   base.serverTime:"..base.serverTime)
                        end
                        if self.islandInfoDialog then
                            self.islandInfoDialog:realClose()
                        end
                        local reportTb
                        if retTb.data.mail and retTb.data.mail.report then
                            reportTb = retTb.data.mail.report
                        end
                        if reportTb then
                            local eid
                            for k, v in pairs(reportTb) do
                                eid = v.eid
                            end
                            if eid then
                                require "luascript/script/game/scene/gamedialog/emailDetailDialog"
                                local layerNum = 4
                                local td = emailDetailDialog:new(layerNum, 2, eid)
                                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("scout_content_scout_title"), false, layerNum)
                                sceneGame:addChild(dialog, layerNum)
                            end
                        end
                    end
                end
                -- local target={x=island.x,y=island.y}
                -- socketHelper:mapScout(target,mapScoutHandler)
                local function realMapScout()
                    local target = {x = island.x, y = island.y}
                    socketHelper:mapScout(target, mapScoutHandler)
                end
                -- 验证码
                
                local function checkcodeHandler(...)
                    
                    if base.isCheckCode == 1 then
                        local function checkcodeSuccess(fn, data)
                            local ret, sData = base:checkServerData(data)
                            if ret == true then
                                -- print("++++++++领取奖励成功++++++++11111111112222222222")
                                --领取验证码奖励成功后再更新lastCheckcodeNum
                                local checkcodeNum = CCUserDefault:sharedUserDefault():getIntegerForKey(G_checkCodeKey..playerVoApi:getUid())
                                CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastCheckCodeKey..playerVoApi:getUid(), checkcodeNum)
                                CCUserDefault:sharedUserDefault():flush()
                                if sData and sData.data and sData.data.reward then
                                    local reward = FormatItem(sData.data.reward)
                                    local rewardStr = getlocal("daily_lotto_tip_10")
                                    if reward then
                                        for k, v in pairs(reward) do
                                            if k == SizeOfTable(reward) then
                                                rewardStr = rewardStr .. v.name .. " x" .. v.num
                                            else
                                                rewardStr = rewardStr .. v.name .. " x" .. v.num .. ","
                                            end
                                        end
                                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), rewardStr, 30)
                                    end
                                    -- print("----------dmj----------checkcodesuccessreward:"..#reward)
                                end
                            elseif sData.ret == -6010 then
                                -- print("++++++++领取奖励失败++++++++11111111112222222222")
                                CCUserDefault:sharedUserDefault():setIntegerForKey(G_checkCodeKey..playerVoApi:getUid(), G_maxCheckCount)
                                CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastCheckCodeKey..playerVoApi:getUid(), G_maxCheckCount)
                                CCUserDefault:sharedUserDefault():flush()
                            end
                            realMapScout()
                        end
                        socketHelper:checkcodereward(checkcodeSuccess)
                    end
                end
                
                if G_isCheckCode() == true then
                    if self.islandInfoDialog then
                        self.islandInfoDialog:realClose()
                    end
                    local layerNum = 4
                    smallDialog:initCheckCodeDialog(layerNum, checkcodeHandler)
                else
                    realMapScout()
                end
                
            else
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("reputation_scene_money_require"), true, 4)
            end
            
        end
        if island.type == 7 then
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), callBack, getlocal("dialog_title_prompt"), getlocal("rebel_info_scout_tip", {scoutRes}), nil, 4)
        else
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), callBack, getlocal("dialog_title_prompt"), getlocal("city_info_scout_tip", {scoutRes}), nil, 4)
        end
    end
    local function attackCallBack()
        --判断是否被占领
        if island.oid == playerVoApi:getUid() then
            --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("city_info_cant_attack_tip"),30)
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("city_info_cant_attack_tip"), true, 4)
            do return end
        end
        --判断被保护
        if island.ptEndTime >= base.serverTime then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("playerhavenoFightBuffattack"), true, 4)
            do return end
        end
        --判断是否是盟友 同联盟
        if island.allianceName and allianceVoApi:isSameAlliance(island.allianceName) then
            --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("city_info_cant_attack_tip_1"),30)
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("city_info_cant_attack_tip_1"), true, 4)
            do return end
        end
        --判断是否有能量
        if playerVoApi:getEnergy() <= 0 then
            
            local function buyEnergy()
                G_buyEnergy(5)
            end
            smallDialog:showEnergySupplementDialog(4)
            
            do return end
        end
        --[[
        if G_checkClickEnable()==false then
                do
                    return
                end
        end
        ]]
        if self.islandInfoDialog then
            self.islandInfoDialog:realClose()
        end
        require "luascript/script/game/scene/gamedialog/warDialog/tankAttackDialog"
        local td = tankAttackDialog:new(island.type, island, 4)
        local tbArr = {getlocal("AEFFighting"), getlocal("dispatchCard"), getlocal("repair")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("AEFFighting"), true, 7)
        sceneGame:addChild(dialog, 4)
    end
    local function helpDefendCallBack()
        --判断是否是盟友 同联盟
        if island.allianceName and allianceVoApi:isSameAlliance(island.allianceName) then
            --判断是否有能量
            if playerVoApi:getEnergy() <= 0 then
                
                local function buyEnergy()
                    G_buyEnergy(5)
                end
                smallDialog:showEnergySupplementDialog(4)
                do return end
            end
            --关小板子
            if self.islandInfoDialog then
                self.islandInfoDialog:realClose()
            end
            --弹大板子
            require "luascript/script/game/scene/gamedialog/warDialog/tankAttackDialog"
            local td = tankAttackDialog:new(island.type, island, 4)
            local tbArr = {getlocal("AEFFighting"), getlocal("dispatchCard"), getlocal("repair")}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("fleetCover"), true, 7)
            sceneGame:addChild(dialog, 4)
        else
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("backstage5009"), true, 4)
        end
    end
    --判断岛屿类型 1自己 2敌人 3资源岛
    if islandType == 1 then
        title = getlocal("city_info_myIsland")
        local rank = tonumber(playerVoApi:getRank())
        if rank == nil or rank == 0 then
            rank = 1
        end
        content1 = getlocal("player_message_info_name", {playerVoApi:getPlayerName(), playerVoApi:getPlayerLevel(), playerVoApi:getRankName(tonumber(rank))})
        content2 = getlocal("city_info_coordinate") .. "    "..getlocal("city_info_coordinate_style", {playerVoApi:getMapX(), playerVoApi:getMapY()})
        content3 = getlocal("player_message_info_power") .. "    "..playerVoApi:getPlayerPower()
        --是否有联盟
        if island.allianceName and island.allianceName ~= "" then
            content4 = getlocal("player_message_info_alliance") .. "    "..island.allianceName
        else
            content4 = getlocal("player_message_info_alliance") .. "    "..getlocal("alliance_info_content")
        end
        content = {{content1, titleSize}, {content2, labelSize}, {content3, labelSize}, {content4, labelSize}}
        leftStr = getlocal("city_info_enterPort")
        itemTab = {nil, nil}
        leftHandler = enterPort
    elseif islandType == 2 then
        title = getlocal("scout_content_target_info")
        local rank = tonumber(island.rank)
        if rank == nil or rank == 0 then
            rank = 1
        end
        content1 = getlocal("player_message_info_name", {island.name, island.level, playerVoApi:getRankName(rank)})
        content2 = getlocal("city_info_coordinate") .. "    "..getlocal("city_info_coordinate_style", {island.x, island.y})
        content3 = getlocal("player_message_info_power") .. "    "..island.power
        --是否有联盟
        if island.allianceName and island.allianceName ~= "" then
            content4 = getlocal("player_message_info_alliance") .. "    "..island.allianceName
        else
            content4 = getlocal("player_message_info_alliance") .. "    "..getlocal("alliance_info_content")
        end
        content = {{content1, titleSize}, {content2, labelSize}, {content3, labelSize}, {content4, labelSize}}
        leftStr = getlocal("city_info_scout")
        rightStr = getlocal("city_info_attack")
        itemTab = {writeSpriteMenu, openCollectSpriteMenu}
        leftHandler = scoutCallBack
        --判断是否是盟友 同联盟
        if island.allianceName and allianceVoApi:isSameAlliance(island.allianceName) then
            rightStr = getlocal("city_info_doubleCover")
            rightHandler = helpDefendCallBack
        else
            rightStr = getlocal("city_info_attack")
            rightHandler = attackCallBack
        end
    elseif islandType == 3 then
        title = getlocal("scout_content_target_info")
        content1 = getlocal("world_island_" .. (island.type))..getlocal("city_info_level", {island.level})
        content2 = getlocal("city_info_coordinate") .. "    "..getlocal("city_info_coordinate_style", {island.x, island.y})
        content = {{content1, titleSize}, {content2, labelSize}}
        --判断是否被占领
        if island.oid == playerVoApi:getUid() then
            content3 = getlocal("city_info_ownned")
            table.insert(content, {content3, labelSize, G_ColorYellow})
        end
        leftStr = getlocal("city_info_scout")
        rightStr = getlocal("city_info_attack")
        itemTab = {nil, openCollectSpriteMenu}
        leftHandler = scoutCallBack
        rightHandler = attackCallBack
    end
    --判断被保护
    local protected = false
    if island.ptEndTime >= base.serverTime then
        protected = true
    end
    return smallDialog:showPlayerInfoSmallDialog("PanelHeaderPopup.png", CCSizeMake(550, 450), CCRect(0, 0, 400, 400), CCRect(168, 86, 10, 10), leftStr, leftHandler, rightStr, rightHandler, title, content, nil, 3, islandType + 1, itemTab, nil, protected, island.pic, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, island.bpic)
end

--将像素坐标转换为区域坐标
function worldScene:getAreaPos(x, y)
    x = math.ceil(x / 1000)
    y = math.ceil((self.worldSize.height - y) / 1000)
    if x <= 0 then
        x = 1
    end
    if y <= 0 then
        y = 1
    end
    return x, y
end

function worldScene:checkRemoveBase()
    local fourPoints = self:get4Points()
    local inScreen = false
    for k, v in pairs(self.curShowBases) do
        inScreen = false
        
        for kk, vv in pairs(fourPoints) do
            if k == (vv.x * 1000 + vv.y) then --移除掉出了显示屏的基地图片
                inScreen = true
            end
        end
        
        if inScreen == false then
            for kk, vv in pairs(v) do
                vv:removeFromParentAndCleanup(true)
                vv = nil
            end
            self.curShowBases[k] = nil
        end
    end
    if base.allianceCitySwitch == 1 then
        local bigFourPoints = self:get4Points(4)
        for k, v in pairs(self.mapTerritoryTb) do
            inScreen = false
            local minPoint, maxPoint = bigFourPoints[1], bigFourPoints[4]
            if k >= (minPoint.x * 1000 + minPoint.y) and k <= (maxPoint.x * 1000 + maxPoint.y) then
                -- print("territory in screen!!!")
                inScreen = true
            end
            if inScreen == false then
                for kk, vv in pairs(v) do --移除掉出了屏幕外的城市领地分界线
                    for kkk, edgeSp in pairs(vv) do
                        if edgeSp then
                            -- print("remove out screen territory!!!")
                            edgeSp:removeFromParentAndCleanup(true)
                        end
                    end
                end
                self.mapTerritoryTb[k] = nil
            end
        end
    end
end

function worldScene:twinkleOnFocus(isTarget)
    local winPos = ccp(0, 0)
    for k, v in pairs(self.curShowBases) do
        
        for kk, vv in pairs(v) do
            if self.needFadeEffectPos ~= nil then
                if math.floor(kk / 1000) == self.needFadeEffectPos.x and kk % 1000 == self.needFadeEffectPos.y then
                    --闪烁
                    local acArr = CCArray:create()
                    local fadeOut = CCTintTo:create(0.3, 80, 80, 80)
                    local fadeIn = CCTintTo:create(0.3, 255, 255, 255)
                    acArr:addObject(fadeOut)
                    acArr:addObject(fadeIn)
                    acArr:addObject(fadeOut)
                    acArr:addObject(fadeIn)
                    local seq = CCSequence:create(acArr)
                    vv:runAction(seq)
                end
            end
        end
    end
    self.needFadeEffectPos = nil
end

function worldScene:blinkOnFocus()
    for k, v in pairs(self.curShowBases) do
        for kk, vv in pairs(v) do
            if self.targetItemPos ~= nil then
                if math.floor(kk / 1000) == self.targetItemPos.x and kk % 1000 == self.targetItemPos.y then
                    self:addFlicker(vv)
                    self.targetItemPos = nil
                end
            end
        end
    end
end

function worldScene:addFlicker(parentBg)
    if parentBg then
        local targetSp = tolua.cast(parentBg:getChildByTag(202), "CCSprite")
        if targetSp then
            return
        end
        targetSp = CCSprite:createWithSpriteFrameName("target_1.png")
        targetSp:setAnchorPoint(ccp(0.5, 0.5))
        targetSp:setPosition(getCenterPoint(parentBg))
        parentBg:addChild(targetSp, 5)
        targetSp:setTag(202)
        local scaleTo1 = CCScaleTo:create(0.5, 1.2)
        local scaleTo2 = CCScaleTo:create(0.5, 1)
        local scaleTo3 = CCScaleTo:create(0.5, 1.2)
        local scaleTo4 = CCScaleTo:create(0.5, 1)
        local acArr = CCArray:create()
        acArr:addObject(scaleTo1)
        acArr:addObject(scaleTo2)
        acArr:addObject(scaleTo3)
        acArr:addObject(scaleTo4)
        
        local function removeFunc()
            targetSp:removeFromParentAndCleanup(true)
        end
        local callFunc = CCCallFunc:create(removeFunc)
        acArr:addObject(callFunc)
        local seq = CCSequence:create(acArr)
        targetSp:runAction(seq)
        return targetSp
    end
    return nil
end

function worldScene:checkIfHide()
    local winPos = ccp(0, 0)
    for k, v in pairs(self.curShowBases) do
        for kk, vv in pairs(v) do
            winPos = self.showLayer:convertToWorldSpace(ccp(vv:getPosition()))
            if winPos.x >= -100 and winPos.x <= 700 and winPos.y > -100 and winPos.y < G_VisibleSizeHeight + 60 then
                vv:setVisible(true)
            else
                vv:setVisible(false)
            end
        end
    end
end

--设置信息是否显示
function worldScene:setShowInfo()
    local vis
    if self.showInfo == true then
        vis = false
        self.showInfo = false
    else
        vis = true
        self.showInfo = true
    end
    local userSp
    local alliacneSp = nil
    for k, v in pairs(self.curShowBases) do
        for kk, vv in pairs(v) do
            if vv:getChildByTag(100) ~= nil then
                userSp = tolua.cast(vv:getChildByTag(100), "LuaCCScale9Sprite")
                alliacneSp = tolua.cast(vv:getChildByTag(103), "LuaCCScale9Sprite")
            else
                userSp = tolua.cast(vv:getChildByTag(101), "CCSprite")
            end
            if userSp ~= nil then
                if vis == true then
                    userSp:setVisible(true)
                else
                    userSp:setVisible(false)
                end
            end
            if alliacneSp ~= nil then
                if vis == true then
                    alliacneSp:setVisible(true)
                else
                    alliacneSp:setVisible(false)
                end
            end
            
        end
    end
end

--multiple：扩大范围倍数
function worldScene:get4Points(multiple)
    multiple = multiple or 1
    local centerScenePoint = self.showLayer:convertToNodeSpace(ccp(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    local fourPoints = {}
    local x, y = self:getAreaPos(centerScenePoint.x - multiple * G_VisibleSize.width / 2, centerScenePoint.y + multiple * ((G_VisibleSize.height / 2) > 480 and 480 or (G_VisibleSize.height / 2))) --左上角
    fourPoints[1] = ccp(x, y)
    x, y = self:getAreaPos(centerScenePoint.x - multiple * G_VisibleSize.width / 2, centerScenePoint.y - multiple * ((G_VisibleSize.height / 2) > 480 and 480 or (G_VisibleSize.height / 2))) --左下角
    fourPoints[2] = ccp(x, y)
    
    x, y = self:getAreaPos(centerScenePoint.x + multiple * G_VisibleSize.width / 2, centerScenePoint.y + multiple * ((G_VisibleSize.height / 2) > 480 and 480 or (G_VisibleSize.height / 2))) --右上角
    fourPoints[3] = ccp(x, y)
    
    x, y = self:getAreaPos(centerScenePoint.x + multiple * G_VisibleSize.width / 2, centerScenePoint.y - multiple * ((G_VisibleSize.height / 2) > 480 and 480 or (G_VisibleSize.height / 2))) --右下角
    fourPoints[4] = ccp(x, y)
    --[[
    if G_isIphone5()==true then
         x,y=self:getAreaPos(centerScenePoint.x,centerScenePoint.y)    --中心点
         fourPoints[5]=ccp(x,y)
    end
    ]]
    return fourPoints
end

function worldScene:baseShowLvTip(baseSp, vv)
    if baseSp:getChildByTag(101) ~= nil then
        tolua.cast(baseSp:getChildByTag(101), "CCSprite"):removeFromParentAndCleanup(true)
    end
    if false then
        local lvTip, occupySp
        local lv = vv.richLv
        local rLv = worldBaseVoApi:getRichLv(vv.id)
        if rLv > 0 then
            lv = rLv
        end
        local color = ccc3(137, 137, 137)
        local flag, level = goldMineVoApi:isGoldMine(vv.id)
        if flag == true then
            lvTip = CCSprite:createWithSpriteFrameName("goldMineLvTip.png")
            if vv.oid ~= playerVoApi:getUid() then
                self:addDisappearTimeLb(baseSp, vv.type, vv.id, vv.x, vv.y)
            else
                self:addDisappearTimeLb(baseSp, vv.type, vv.id, vv.x, vv.y, true)
            end
            color = ccc3(255, 255, 255)
        else
            lvTip = CCSprite:createWithSpriteFrameName("mineLvTip.png")
        end
        if lv > 0 and lvTip then
            color = worldBaseVoApi:getRichMineColorByLv(lv)
        end
        if vv.oid ~= playerVoApi:getUid() then
        else
            occupySp = CCSprite:createWithSpriteFrameName("mineOccupy.png")
        end
        if occupySp then
            occupySp:setScale(1 / baseSp:getScale())
            local posCfg = {ccp(80, 111), ccp(80, 114), ccp(80, 109), ccp(80, 114), ccp(80, 114)}
            local pos = posCfg[vv.type] or ccp(0, 0)
            occupySp:setPosition(ccp(pos.x, pos.y - 20))
            baseSp:addChild(occupySp, 5)
        end
        lvTip:setColor(color)
        lvTip:setScale(1 / baseSp:getScale())
        local lvTipPosCfg = {ccp(121, 28), ccp(117, 22.5), ccp(119, 37), ccp(126, 33.5), ccp(116, 31.5)}
        local lvTipPos = lvTipPosCfg[vv.type] or ccp(0, 0)
        lvTip:setPosition(lvTipPos)
        
        local mineLv = vv.curLv
        if flag == true then
            mineLv = level
        end
        local lvLb = GetTTFLabel(mineLv, 16)
        if vv.oid ~= playerVoApi:getUid() then
            lvLb:setPosition(ccp(lvTip:getContentSize().width / 2, lvTip:getContentSize().height / 2))
        else
            lvLb:setPosition(ccp(lvTip:getContentSize().width / 2, lvTip:getContentSize().height / 2 - 10))
        end
        lvLb:setSkewY(25)
        lvLb:setPosition(ccp(lvTip:getContentSize().width / 2 + 1, lvTip:getContentSize().height / 2))
        lvTip:addChild(lvLb)
        baseSp:addChild(lvTip, 5)
        lvTip:setTag(101)
        lvTip:setVisible(self.showInfo)
    elseif vv.type >= 1 and vv.type <= 5 or (vv.type == 6 or vv.type == 8) then
        local lvTip
        local lv = vv.richLv
        local rLv = worldBaseVoApi:getRichLv(vv.id)
        if rLv > 0 then
            lv = rLv
        end
        local flag, level = goldMineVoApi:isGoldMine(vv.id)
        local pFlag = privateMineVoApi:isPrivateMine(vv.id)
        if vv.oid ~= playerVoApi:getUid() then
            if flag == true then
                lvTip = CCSprite:createWithSpriteFrameName("goldmine_lv_bg.png")
                self:addDisappearTimeLb(baseSp, vv.type, vv.id, vv.x, vv.y)
            elseif pFlag then
                lvTip = CCSprite:createWithSpriteFrameName("privateMine_lv_bg.png")
                self:addDisappearTimeLb(baseSp, vv.type, vv.id, vv.x, vv.y, nil, "private")
            elseif(lv > 0)then
                lvTip = CCSprite:createWithSpriteFrameName("IconLevelWhite.png")
                lvTip:setColor(worldBaseVoApi:getRichMineColorByLv(lv))
            else
                lvTip = CCSprite:createWithSpriteFrameName("IconLevel.png")
            end
        else
            if flag == true then
                lvTip = CCSprite:createWithSpriteFrameName("IconLevelFlag.png")
                local tmp = CCSprite:createWithSpriteFrameName("goldmine_lv_bg.png")
                tmp:setPosition(ccp(lvTip:getContentSize().width / 2, lvTip:getContentSize().height / 2 - 10))
                tmp:setScale(0.9)
                lvTip:addChild(tmp)
                self:addDisappearTimeLb(baseSp, vv.type, vv.id, vv.x, vv.y, true)
            elseif pFlag then
                lvTip = CCSprite:createWithSpriteFrameName("IconLevelFlag.png")
                local tmp = CCSprite:createWithSpriteFrameName("privateMine_lv_bg.png")
                tmp:setPosition(ccp(lvTip:getContentSize().width / 2, lvTip:getContentSize().height / 2 - 10))
                tmp:setScale(0.9)
                lvTip:addChild(tmp)
                self:addDisappearTimeLb(baseSp, vv.type, vv.id, vv.x, vv.y, true, "private")
            elseif(lv > 0)then
                lvTip = CCSprite:createWithSpriteFrameName("IconLevelFlag.png")
                local tmp = CCSprite:createWithSpriteFrameName("IconLevelWhite.png")
                tmp:setColor(worldBaseVoApi:getRichMineColorByLv(lv))
                tmp:setPosition(ccp(lvTip:getContentSize().width / 2, lvTip:getContentSize().height / 2 - 10))
                tmp:setScale(0.9)
                lvTip:addChild(tmp)
            else
                lvTip = CCSprite:createWithSpriteFrameName("IconLevelOccupy.png")
            end
        end
        lvTip:setPosition(ccp(baseSp:getContentSize().width / 2 + 5, 40))
        local mineLv = vv.curLv
        if flag == true then
            mineLv = level
        end
        local lvLb = GetTTFLabel(mineLv, 25)
        if vv.oid ~= playerVoApi:getUid() then
            lvLb:setPosition(ccp(lvTip:getContentSize().width / 2, lvTip:getContentSize().height / 2))
        else
            lvLb:setPosition(ccp(lvTip:getContentSize().width / 2, lvTip:getContentSize().height / 2 - 10))
        end
        -- lvTip:setScale(0.7/baseSp:getScale())
        lvTip:addChild(lvLb)
        lvTip:setAnchorPoint(ccp(0.5, 0.5))
        baseSp:addChild(lvTip, 5)
        lvTip:setTag(101)
        lvTip:setVisible(self.showInfo)
        if vv.type == 8 then
            lvTip:setScale(0.7)
            lvTip:setPosition(baseSp:getContentSize().width / 2 - 38, 42)
        end
    else
        local lvTip
        local lv = vv.richLv
        local rLv = worldBaseVoApi:getRichLv(vv.id)
        if rLv > 0 then
            lv = rLv
        end
        local flag, level = goldMineVoApi:isGoldMine(vv.id)
        local pFlag = privateMineVoApi:isPrivateMine(vv.id)
        if vv.oid ~= playerVoApi:getUid() then
            if flag == true then
                lvTip = CCSprite:createWithSpriteFrameName("goldmine_lv_bg.png")
                self:addDisappearTimeLb(baseSp, vv.type, vv.id, vv.x, vv.y)
            elseif pFlag then
                lvTip = CCSprite:createWithSpriteFrameName("privateMine_lv_bg.png")
                self:addDisappearTimeLb(baseSp, vv.type, vv.id, vv.x, vv.y, nil, "private")
            elseif(lv > 0)then
                lvTip = CCSprite:createWithSpriteFrameName("IconLevelWhite.png")
                lvTip:setColor(worldBaseVoApi:getRichMineColorByLv(lv))
            else
                lvTip = CCSprite:createWithSpriteFrameName("IconLevel.png")
            end
        else
            if flag == true then
                lvTip = CCSprite:createWithSpriteFrameName("IconLevelFlag.png")
                local tmp = CCSprite:createWithSpriteFrameName("goldmine_lv_bg.png")
                tmp:setPosition(ccp(lvTip:getContentSize().width / 2, lvTip:getContentSize().height / 2 - 10))
                tmp:setScale(0.9)
                -- tmp:setScale(0.9)
                lvTip:addChild(tmp)
                self:addDisappearTimeLb(baseSp, vv.type, vv.id, vv.x, vv.y, true)
            elseif pFlag then
                lvTip = CCSprite:createWithSpriteFrameName("IconLevelFlag.png")
                local tmp = CCSprite:createWithSpriteFrameName("privateMine_lv_bg.png")
                tmp:setPosition(ccp(lvTip:getContentSize().width / 2, lvTip:getContentSize().height / 2 - 10))
                -- tmp:setScale(0.9)
                lvTip:addChild(tmp)
                self:addDisappearTimeLb(baseSp, vv.type, vv.id, vv.x, vv.y, true, "private")
            elseif(lv > 0)then
                lvTip = CCSprite:createWithSpriteFrameName("IconLevelFlag.png")
                local tmp = CCSprite:createWithSpriteFrameName("IconLevelWhite.png")
                tmp:setColor(worldBaseVoApi:getRichMineColorByLv(lv))
                tmp:setPosition(ccp(lvTip:getContentSize().width / 2, lvTip:getContentSize().height / 2 - 10))
                tmp:setScale(0.9)
                lvTip:addChild(tmp)
            else
                lvTip = CCSprite:createWithSpriteFrameName("IconLevelOccupy.png")
            end
        end
        lvTip:setPosition(ccp(baseSp:getContentSize().width / 2, baseSp:getContentSize().height - 15))
        local mineLv = vv.curLv
        if flag == true then
            mineLv = level
            -- lvTip:setPosition(ccp(baseSp:getContentSize().width/2-40,baseSp:getContentSize().height-10))
        end
        local lvLb = GetTTFLabel(mineLv, 25)
        if vv.oid ~= playerVoApi:getUid() then
            lvLb:setPosition(ccp(lvTip:getContentSize().width / 2, lvTip:getContentSize().height / 2))
        else
            lvLb:setPosition(ccp(lvTip:getContentSize().width / 2, lvTip:getContentSize().height / 2 - 10))
        end
        lvTip:setScale(0.7)
        lvTip:addChild(lvLb)
        lvTip:setAnchorPoint(ccp(0.5, 0.5))
        baseSp:addChild(lvTip, 5)
        lvTip:setTag(101)
        lvTip:setVisible(self.showInfo)
        if vv.type == 8 then
            lvTip:setPosition(baseSp:getContentSize().width / 2, baseSp:getContentSize().height - 55)
        end
    end
    
    local radarBg = baseSp:getChildByTag(151)
    if(radarBg)then
        radarBg = tolua.cast(radarBg, "CCSprite")
        radarBg:removeFromParentAndCleanup(true)
    end
    if(skillVoApi:checkBaseScout(vv.x, vv.y))then
        radarBg = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
        radarBg:setTag(151)
        radarBg:setOpacity(0)
        radarBg:setPosition(baseSp:getContentSize().width / 2, baseSp:getContentSize().height / 2)
        baseSp:addChild(radarBg, -1)
        local radar = CCParticleSystemQuad:create("public/skillRadar.plist")
        radar.positionType = kCCPositionTypeRelative
        radar:setPosition(radarBg:getContentSize().width / 2, radarBg:getContentSize().height / 2)
        radarBg:addChild(radar)
    end
end

function worldScene:worldBaseTick()
    if self.clayer:isVisible() == false then
        do
            return
        end
    end
    local tankSlots = attackTankSoltVoApi:getAllAttackTankSlots()
    local userResoureBases = {}
    for k, v in pairs(tankSlots) do
        if ((v.isGather == 2 and v.bs == nil) or (v.isGather == 3 and v.bs == nil)) then
            userResoureBases[v.targetid[1] * 1000 + v.targetid[2]] = 1
        end
        if v.type == 8 and v.isGather == 0 and v.isDef == 0 and v.bs ~= nil then --战斗结束后移除军团城市攻击效果
            self:removeAttackAllianceCityEffect(v.slotId)
        elseif v.type == 8 and v.isGather == 5 and v.isDef == 0 then --如果进攻军团城市到达后，显示进攻效果
            if v.targetid and v.targetid[1] and v.targetid[2] then
                local mid = worldBaseVoApi:getMidByPos(v.targetid[1], v.targetid[2])
                local startPoint, endPoint = v:getStartPoint(), v:getEndPoint()
                if startPoint == nil or endPoint == nil then
                    startPoint, endPoint = self:getSlotPoint(v)
                end
                if startPoint and endPoint then
                    self:playAttackAllianceCityEffect(startPoint, endPoint, v.slotId, v.targetid[1], v.targetid[2])
                end
            end
        end
    end
    if self.acityEffectSlot then --移除军团城市攻击效果
        for slotId, v in pairs(self.acityEffectSlot) do
            local slotVo = attackTankSoltVoApi:getSlotIndexById(slotId)
            if slotVo == nil then
                self:removeAttackAllianceCityEffect(slotId)
            end
        end
    end
    for k, v in pairs(self.curShowBases) do
        for kk, vv in pairs(v) do
            local curBaseVo = worldBaseVoApi:getBaseVo(math.floor(kk / 1000), kk % 1000)
            if(curBaseVo and curBaseVo.type == 7)then
                if(base.serverTime >= curBaseVo.ptEndTime or curBaseVo.hp <= 0)then
                    curBaseVo.expireTime = 0
                    vv:removeFromParentAndCleanup(true)
                    self.curShowBases[k][kk] = nil
                else
                    local lbTime = tolua.cast(vv:getChildByTag(104), "CCLabelTTF")
                    lbTime:setString(GetTimeStr(curBaseVo.ptEndTime - base.serverTime))
                    if(base.serverTime % 6 == 0)then
                        lbTime:setOpacity(0)
                        local lbHp = tolua.cast(vv:getChildByTag(103), "CCLabelTTF")
                        lbHp:setOpacity(255)
                        lbHp:setString(G_keepNumber(curBaseVo.hp / curBaseVo.maxHp * 100, 2) .. "%")
                    elseif(base.serverTime % 3 == 0)then
                        lbTime:setOpacity(255)
                        local lbHp = tolua.cast(vv:getChildByTag(103), "CCLabelTTF")
                        local progressHp = tolua.cast(vv:getChildByTag(101), "CCSprite")
                        lbHp:setOpacity(0)
                        lbHp:setString(G_keepNumber(curBaseVo.hp / curBaseVo.maxHp * 100, 2) .. "%")
                        progressHp:setScaleX(curBaseVo.hp / curBaseVo.maxHp * 120 / progressHp:getContentSize().width)
                    end
                end
            elseif curBaseVo ~= nil and curBaseVo.type ~= 6 and curBaseVo.type ~= 9 then
                
                if userResoureBases[kk] ~= nil then
                    --此岛被占领
                    if curBaseVo.oid == 0 then
                        --设置占领图标
                        curBaseVo.oid = playerVoApi:getUid()
                        self:baseShowLvTip(vv, curBaseVo)
                    end
                else
                    --此岛没被占领
                    if curBaseVo.oid == playerVoApi:getUid() then
                        --设置未占领图标
                        curBaseVo.oid = 0
                        self:baseShowLvTip(vv, curBaseVo)
                    end
                end
            elseif curBaseVo and curBaseVo.type == 8 then --军团城市
                if baseSp.serverTime >= curBaseVo.ptEndTime and curBaseVo.ptEndTime > 0 then
                    self:removeCityProtect(curBaseVo.x, curBaseVo.y)
                end
            end
        end
    end
    
    -- 刷新行军路线的剩余时间label
    if self.tankLineIcon ~= nil then
        for k, v in pairs(self.tankLineIcon) do
            local index, slotVo = attackTankSoltVoApi:getSlotIndexById(k)
            if slotVo then
                local leftTime = 0
                if slotVo.bs ~= nil then
                    leftTime = slotVo.bs - base.serverTime
                else
                    leftTime = slotVo.dist - base.serverTime
                end
                if leftTime <= 0 then
                    self:removeTankSlotSp(slotVo.slotId)
                else
                    local menuItem = tolua.cast(v:getChildByTag(343), "CCMenuItem")
                    if menuItem ~= nil then
                        local timeLbl = tolua.cast(menuItem:getChildByTag(171), "CCLabelTTF")
                        if timeLbl ~= nil then
                            timeLbl:setString(GetTimeStr(leftTime))
                        end
                    end
                end
            end
        end
    end
    
    -- 刷新敌军来袭路线的剩余时间label
    if self.enemyLineIcon ~= nil then
        for k, v in pairs(self.enemyLineIcon) do
            local slotVo = enemyVoApi:getEnemyById(k)
            if slotVo and slotVo.time then
                local leftTime = slotVo.time - base.serverTime
                if leftTime <= 0 then
                    self:removeEnemyTankSlotSp(slotVo.slotId)
                else
                    local menuItem = tolua.cast(v:getChildByTag(343), "CCMenuItem")
                    if menuItem ~= nil then
                        local timeLbl = tolua.cast(menuItem:getChildByTag(171), "CCLabelTTF")
                        if timeLbl ~= nil then
                            timeLbl:setString(GetTimeStr(leftTime))
                        end
                    end
                end
            end
        end
    end
    if worldBaseVoApi:isNeedRefreshMine() == true then
        -- print("**********矿点数据发生变化**********")
        worldBaseVoApi:setRefreshMineFlag(false)
        self:refreshChangedMine()
    end
    if goldMineVoApi:needRefreshNewMine() == true then
        --有新的金矿刷新出来
        -- print("*******有新的金矿刷新出来*******")
        goldMineVoApi:setRefreshNewMineFlag(false)
        self:refreshChangedMine()
    end
    if privateMineVoApi:needRefreshNewMine() == true then
        -- 新的保护矿
        privateMineVoApi:setRefreshNewMineFlag(false)
        self:refreshChangedMine()
    end
    --刷新金矿消失倒计时
    if (base.wl == 1 and base.goldmine == 1) or base.privatemine == 1 then
        if self.leftTimeLbTb then
            local overFlag = false --金矿过期的标记
            local overArea = {} --过期金矿的坐标
            for areaX, v in pairs(self.leftTimeLbTb) do
                for areaY, timeLb in pairs(v) do
                    if self.curShowBases[areaX] ~= nil and self.curShowBases[areaX][areaY] ~= nil then
                        if timeLb and tolua.cast(timeLb, "CCLabelTTF") and timeLb.setString then
                            local baseVo = worldBaseVoApi:getBaseVoByAreaXY(areaX, areaY)
                            if baseVo then
                                local isGoldMine = goldMineVoApi:isGoldMine(baseVo.id)
                                local leftTime = 0
                                if isGoldMine then
                                    leftTime = goldMineVoApi:getGoldMineLeftTime(baseVo.id)
                                else
                                    leftTime = privateMineVoApi:getPrivateMineLeftTime(baseVo.id)
                                end
                                if leftTime > 0 then
                                    timeLb:setString(GetTimeStr(leftTime))
                                else
                                    self:removeDisappearTimeLb(areaX, areaY)
                                    worldBaseVoApi:setRefreshMineFlag(true)
                                    if base.fsaok == 1 then
                                        table.insert(overArea, {x = baseVo.x, y = baseVo.y}) --记录过期金矿(或是保护矿)的坐标
                                        overFlag = true
                                    end
                                end
                            end
                        end
                    else
                        self:removeDisappearTimeLb(areaX, areaY)
                    end
                end
            end
            if overFlag == true then
                self:mineChange(overArea) --处理过期的金矿或保护矿（刷新成普通矿）
            end
        end
    end
end

function worldScene:tick()
    if self.waitShowBase == true then
        if self.lastRefreshTime == 0 then
            self.lastRefreshTime = G_getCurDeviceMillTime()
        end
        if (G_getCurDeviceMillTime() - self.lastRefreshTime) >= 1000 and (self.startDeaccleary == false or G_isUseNewMap() == false) then
            self.waitShowBase = false
            self.lastRefreshTime = G_getCurDeviceMillTime()
            if self.posTipBar ~= nil and self.posTipBar.status == 1 then
                self.posTipBar:close()
                self.posTipBar = nil
            end
            self:showBase(true)
        end
        
    end
    
    -- 检测行军路线
    self:checkTankSlot()
    if base.isGlory == 1 and self.isGloryOver ~= gloryVoApi:isGloryOver() and self.buildSelfTb ~= nil then
        -- print("self.isGloryOver-----gloryVoApi:isGloryOver()----->",self.isGloryOver ,gloryVoApi:isGloryOver())
        self.isGloryOver = gloryVoApi:isGloryOver()
        -- print("self.isGloryOver----->",self.isGloryOver)
        self:firByMySelf(self.isGloryOver)
    end
    if base.isGlory == 1 then
        local ischange, tbX, tbY = gloryVoApi:getWorldSceneBuildActionChange()
        if ischange == 1 then
            gloryVoApi:worldSceneBuildActionChange(0)
            if self.curShowBases and self.curShowBases[tbX]~=nil and self.curShowBases[tbX][tbY] ~= nil then
                local buildPic = self.curShowBases[tbX][tbY]
                local sonPic = tolua.cast(buildPic:getChildByTag(9527), "CCSprite")
                if sonPic == nil then
                    if worldBaseVoApi.allBaseByArea[tbX][tbY] ~= nil then
                        local oid, tType, boomBmd = worldBaseVoApi.allBaseByArea[tbX][tbY].id, worldBaseVoApi.allBaseByArea[tbX][tbY].type, worldBaseVoApi.allBaseByArea[tbX][tbY].boomBmd
                        self:fireBuilding(buildPic, oid, tType, boomBmd)
                    end
                else
                    sonPic:stopAllActions()
                    sonPic:removeFromParentAndCleanup(true)
                    sonPic = nil
                    tolua.cast(buildPic, "CCSprite"):setColor(ccc3(255, 255, 255))
                end
            end
        end
    end
    if(self.clayer and self.clayer:isVisible())then
        if(skillVoApi:checkEagleEyeCD() == false)then
            local function callback()
                self:refreshChangedMine()
            end
            skillVoApi:getEagleEyeData(callback)
        end
    end
    if G_isUseNewMap() == true then
        self:fastTick()
    end
    if self.mapLayer then
        local mx, my = self.mapLayer:getPosition()
        local cx, cy = self.clayer:getPosition()
        if mx ~= cx or my ~= cy then
            self.mapLayer:setPosition(cx, cy)
        end
    end
    if self.omegaPosTb then --检测欧米伽小队是否过期
        for k, v in pairs(self.omegaPosTb) do
            local baseVo = worldBaseVoApi:getBaseVo(v.x, v.y)
            if baseVo and baseVo.extendData and baseVo.extendData.eTs and base.serverTime >= baseVo.extendData.eTs then
                local realx, realy = self:getBaseSpRealPoint(baseVo)
                if realx and realy then
                    local bx, by = worldBaseVoApi:getAreaXY(realx, realy)
                    if self.curShowBases and self.curShowBases[bx] and self.curShowBases[bx][by] then
                        self.curShowBases[bx][by]:removeFromParentAndCleanup(true)
                        self.curShowBases[bx][by] = nil
                    end
                end
                worldBaseVoApi:removeBaseVo(v.x,v.y)
                table.remove(self.omegaPosTb, k)
            end
        end
    end
end

function worldScene:fastTick()
    if self.startDeaccleary == true then --缓动减速效果
        if self.mapMoveDisPos.x > 60 then
            self.mapMoveDisPos.x = 60
        elseif self.mapMoveDisPos.x < -60 then
            self.mapMoveDisPos.x = -60
        end
        
        if self.mapMoveDisPos.y > 50 then
            self.mapMoveDisPos.y = 50
        elseif self.mapMoveDisPos.y < -50 then
            self.mapMoveDisPos.y = -50
        end
        
        self.mapMoveDisPos = ccpMult(self.mapMoveDisPos, 0.95)
        local tmpPos = ccpAdd(ccp(self.showLayer:getPosition()), self.mapMoveDisPos)
        
        if tmpPos.x > 0 then
            tmpPos.x = 0
            self.mapMoveDisPos.x = 0
        elseif tmpPos.x < (G_VisibleSize.width - self.worldSize.width) then
            tmpPos.x = G_VisibleSize.width - self.worldSize.width
            self.mapMoveDisPos.x = 0
        end
        if tmpPos.y >= self.bottomGap then
            tmpPos.y = self.bottomGap
            self.mapMoveDisPos.y = 0
        elseif tmpPos.y < (G_VisibleSize.height - (self.worldSize.height + self.topGap)) then
            tmpPos.y = G_VisibleSize.height - (self.worldSize.height + self.topGap)
            self.mapMoveDisPos.y = 0
        end
        
        self.showLayer:setPosition(ccpAdd(ccp(self.showLayer:getPosition()), self.mapMoveDisPos))
        if self.mapLayer then
            self.mapLayer:setPosition(self.clayer:getPosition())
        end
        if (math.abs(self.mapMoveDisPos.x) + math.abs(self.mapMoveDisPos.y)) < 1 then
            self:checkIfHide()
            self:addOrnamentals()
            self.startDeaccleary = false
            self.clickFlag = false
        end
    end
end

function worldScene:dispose()
    eventDispatcher:removeEventListener("worldScene.mineChange", self.mineChangeListener)
    eventDispatcher:removeEventListener("worldScene.refreshMine", self.mineListener)
    self.mineChangeListener = nil
    self.mineListener = nil
    if self.clayer then
        self.clayer:stopAllActions()
        self.clayer:removeFromParentAndCleanup(true)
        self.clayer = nil
    end
    if self.showLayer then
        self.showLayer:stopAllActions()
        self.showLayer:removeFromParentAndCleanup(true)
        self.showLayer = nil
    end
    self.sceneSp = nil
    self.touchEnable = true
    self.touchArr = {}
    self.mapSprites = {}
    self.spSize = nil
    self.fieldSize = CCSizeMake(100, 100)
    self.worldSize = CCSizeMake((2 * 601 - 1) * 80, 60 + 600 * 100)
    self.topGap = 110
    self.bottomGap = 180
    self.curShowBases = {}
    self.isMoved = false
    self.showInfo = true
    self.lastRefreshTime = 0
    self.waitShowBase = false
    self.writeSpriteMenu = nil
    self.openCollectSpriteMenu = nil
    self.islandInfoDialog = nil
    self.btnTab = {}
    self.hasGetDataFromServer = {}
    self.checkcodeValue = 0
    
    self.showTankLine = {} -- 存储行军路线的精灵  slotId是索引
    -- self.showTankLineIcon = {} -- 存储行军路线的图标精灵
    self.tankLineState = {} -- 存储行军路线的状态
    self.tankLineIcon = {} -- 存储行军图标精灵
    self.tankLineCount = 0 --已经显示的路线数量
    self.tankLineRefreshTime = 0 -- 行军路线的刷新计数器
    -- self.tankLineDialogNum = 0 -- 控制行军事件窗口的数量
    self.oneWarEventTd = nil -- 行军事件窗口类，控制窗口数量
    self.showEnemyLine = {} -- 存储敌军来袭路线的精灵  slotId是索引
    self.enemyLineIcon = {} -- 存储敌军来袭图标精灵
    
    self.firebuildBg = nil
    self.isGloryOver = false
    self.fireBuildParent = nil
    self.buildSelfTb = nil
    self.leftTimeLbTb = {}
    self.targetItemPos = nil
    self.spiralEagleTb = {}
    self.flyEagleTb = {}
    self.cloudTb = {}
    self.planeTb = {}
    self.mapTileObjs = {}
    self.spBatchNode = nil
    self.spBatchNode_1 = nil
    self.eagleBatchNode = nil
    self.planeBatchNode = nil
    self.mapBatchNode = nil
    self.startDeaccleary = false
    self.mapMoveDisPos = ccp(0, 0)
    self.clickFlag = false
    self.tmx = {}
    self.tmxLand = {}
    self.isMovingBuilding = false --是否是在移动军团城市的标识
    self.movingSpaceX = 0 --移动世界地图的X速度（一次移动多少格）
    self.movingSpaceY = 0 --移动世界地图的Y速度（一次移动多少格）
    self.buildingPoint = ccp(0, 0) --城市所在位置
    self.areaSpTb = nil
    self.operateLayer = nil
    if self.buildingSp then
        self:removeBuildLayer()
    end
    self.mapTerritoryTb = {}
    self.acityEffectSlot = {}
    self:removeMapLayer()
    self.edgeBatchSp = nil
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("homeBuilding/mapBaseBuilding.plist")
    self.minScale = 1.0
    self.curScale = 1.2
    self.maxScale = 2.5
    self.zoomMidPosForWorld = nil
    self.zoomMidPosForSceneSp = nil
end

function worldScene:showSelectedArea(x, y, px, py)
    if G_checkClickEnable() == false then
        do
            return
        end
    end
    self.clickFlag = true
    base.setWaitTime = G_getCurDeviceMillTime()
    base:setWait()
    local function clickAreaHandler()
        
    end
    local selectPic = "guide_res.png"
    local rect = CCRect(28, 28, 2, 2)
    local size = CCSizeMake(150, 80)
    if G_isUseNewMap() == true then
        selectPic = "BlackAlphaBg.png"
        rect = CCRect(10, 10, 1, 1)
        size = CCSizeMake(160, 100)
    end
    local selectSp = LuaCCScale9Sprite:createWithSpriteFrameName(selectPic, rect, clickAreaHandler)
    selectSp:setAnchorPoint(ccp(0.5, 0.5))
    selectSp:setTouchPriority(0)
    selectSp:setIsSallow(false)
    selectSp:setPosition(ccp(x, self.worldSize.height - y))
    selectSp:setContentSize(size)
    self.clayer:addChild(selectSp, 10)
    
    local function callBack() --弹出移岛确认对话框(指定移岛位置)
        self.clickFlag = false
        base:cancleWait()
        selectSp:removeFromParentAndCleanup(true)
        selectSp = nil
        local descStr
        if bagVoApi:getItemNumId(16) > 0 then
            descStr = getlocal("move_island_tip1", {getlocal("sample_prop_name_1006"), px, py})
        else
            if playerVoApi:getGems() < 98 then
                descStr = getlocal("move_island_alert", {98 - playerVoApi:getGems()})
            else
                descStr = getlocal("move_island_tip2", {98, px, py})
            end
        end
        local function callBack()
            
            if playerVoApi:getGems() < 98 and bagVoApi:getItemNumId(16) == 0 then --弹出充值面板
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                end
                vipVoApi:showRechargeDialog(4)
            else
                --向后台发送请求
                
                local function baseChangeCallback(fn, data)
                    local cresult, retTb = base:checkServerData(data)
                    if cresult == true then
                        if retTb.data.status == 1 then --迁岛成功
                            local refreshTb = {}
                            self.baseOldx, self.baseOldy = playerVoApi:getMapOldPoint()
                            enemyVoApi:deleteEnemy(self.baseOldx, self.baseOldy)
                            local newid, aid = 0, 0
                            local newBaseVo = worldBaseVoApi:getBaseVo(px, py)
                            if newBaseVo then
                                newid, aid = newBaseVo.id, newBaseVo.aid
                            else
                                newid = worldBaseVoApi:getMidByPos(px, py)
                            end
                            local playerBaseVo = worldBaseVoApi:getBaseVo(self.baseOldx, self.baseOldy)
                            if playerBaseVo ~= nil then
                                --worldBaseVoApi:removeBaseVo(self.baseOldx,self.baseOldy) --移除旧的Vo
                                
                                newBaseVo = worldBaseVoApi:add(newid, playerBaseVo.oid, playerBaseVo.name, playerBaseVo.type, playerBaseVo.level, px, py, playerBaseVo.ptEndTime, playerBaseVo.power, playerBaseVo.rank, playerBaseVo.pic, playerBaseVo.allianceName, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, playerBaseVo.skinInfo, playerBaseVo.banner) --添加新的Vo
                                
                                local oldid, baseAid = playerBaseVo.id, playerBaseVo.aid
                                
                                worldBaseVoApi:removeBaseVo(self.baseOldx, self.baseOldy) --移除旧的Vo
                                if baseAid > 0 then --说明该地块是军团领地，则需改变该地块的数据
                                    local baseVo = worldBaseVoApi:add(oldid, 0, "", 0, 0, self.baseOldx, self.baseOldy)
                                    baseVo:updateData({aid = baseAid})
                                end
                            else
                                newBaseVo = worldBaseVoApi:add(newid, playerVoApi:getUid(), playerVoApi:getPlayerName(), 6, playerVoApi:getPlayerLevel(), px, py, playerVoApi:getProtectEndTime(), playerVoApi:getPlayerPower(), playerVoApi:getRank(), playerVoApi:getPic(), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil) --添加新的Vo
                            end
                            if newBaseVo then
                                newBaseVo:updateData({aid = aid, bpic = playerVoApi:getHfid()})
                            end
                            
                            local ppoint = self:toPiexl(ccp(self.baseOldx, self.baseOldy))
                            local areaX = math.ceil(ppoint.x / 1000)
                            local areaY = math.ceil(ppoint.y / 1000)
                            local oldAreaX, oldAreaY = worldBaseVoApi:getAreaXY(self.baseOldx, self.baseOldy)
                            if self.curShowBases[oldAreaX] ~= nil then --显示在屏幕上
                                local playerBaseSp = self.curShowBases[oldAreaX][oldAreaY]
                                if playerBaseSp ~= nil then
                                    local newPixelPoint = self:toPiexl(ccp(px, py))
                                    playerBaseSp:setPosition(ccp(newPixelPoint.x, self.worldSize.height - newPixelPoint.y)) --基地改变坐标
                                    playerBaseSp:setVisible(true)
                                    self.curShowBases[areaX * 1000 + areaY][self.baseOldx * 1000 + self.baseOldy] = nil
                                    local newAreaX, newAreaY = worldBaseVoApi:getAreaXY(px, py)
                                    self.curShowBases[newAreaX][newAreaY] = playerBaseSp
                                    if G_isUseNewMap() == true and self.mapTileObjs[newAreaX] and self.mapTileObjs[newAreaX][newAreaY] then
                                        local ornamentalSp = self.mapTileObjs[newAreaX][newAreaY]
                                        if ornamentalSp then
                                            ornamentalSp = tolua.cast(ornamentalSp, "CCSprite")
                                            if ornamentalSp then
                                                ornamentalSp:setVisible(false)
                                            end
                                        end
                                    end
                                end
                            else
                                local tmpDataTb = {}
                                local curUserBaseVo = worldBaseVoApi:getBaseVo(px, py)
                                local newAreaX, newAreaY = worldBaseVoApi:getAreaXY(px, py)
                                tmpDataTb[newAreaX] = {[newAreaY] = curUserBaseVo}
                                self:realShowBase(tmpDataTb, true)
                                --[[
                            local playerBaseSp=self.curShowBases[newAreaX*1000+newAreaY][px*1000+py]
                            if playerBaseSp~=nil then
                                playerBaseSp:setVisible(true)
                            end
                            ]]
                            end
                            --更改用户基地坐标
                            playerVoApi:setBasePos(px, py)
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("promptIslandMove", {px, py}), 28)
                            local boom, boomMax, boomAt, boomBmd
                            if base.isGlory == 1 then--boom,boomMax,boomAt,boomBmd
                                boom = gloryVo.curBoom
                                boomMax = gloryVo.curBoomMax
                                boomAt = gloryVo.boom_ts
                                boomBmd = gloryVo.isGloryOver
                            end
                            if playerBaseVo then
                                local params = {uid = playerVoApi:getUid(), oldx = self.baseOldx, oldy = self.baseOldy, newx = px, newy = py, id = playerBaseVo.id, oid = playerBaseVo.oid, name = playerBaseVo.name, type = playerBaseVo.type, level = playerBaseVo.level, x = playerBaseVo.x, y = playerBaseVo.y, ptEndTime = playerBaseVo.ptEndTime, power = playerBaseVo.power, rank = playerBaseVo.rank, pic = playerBaseVo.pic, allianceName = playerBaseVo.allianceName, boom = boom, boomMax = boomMax, boomAt = boomAt, boomBmd = boomBmd, skinInfo = playerBaseVo.skinInfo, banner = playerBaseVo.banner}
                                chatVoApi:sendUpdateMessage(3, params) --搬家后发通知给全服
                            end
                            
                            if base.isGlory == 1 and self.isGloryOver == true then
                                self.firebuildBg = nil
                                self:firByMySelf(self.isGloryOver)
                            end
                            
                            helpDefendVoApi:clear()--清空协防
                            eventDispatcher:dispatchEvent("user.basemove")
                        end
                    end
                end
                if SizeOfTable(attackTankSoltVoApi:getAllAttackTankSlots()) > 0 then
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("randomMoveIslandError1"), nil, 4)
                elseif helpDefendVoApi:isHasArrive() then
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("backstage2007"), nil, 4)
                else
                    self.baseOldx, self.baseOldy = playerVoApi:getMapX(), playerVoApi:getMapY()
                    socketHelper:baseChange(baseChangeCallback, px, py)
                end
                
            end
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), callBack, getlocal("dialog_title_prompt"), descStr, nil, 4)
        
    end
    if G_isUseNewMap() == true then
        selectSp:setOpacity(0)
        local fadeOut = CCFadeTo:create(0.3, 0)
        local fadeIn = CCFadeTo:create(0.3, 120)
        local delayTime = CCDelayTime:create(0)
        local callFunc = CCCallFunc:create(callBack)
        local arr = CCArray:create()
        arr:addObject(delayTime)
        arr:addObject(fadeIn)
        arr:addObject(fadeOut)
        arr:addObject(callFunc)
        local seq = CCSequence:create(arr)
        selectSp:runAction(seq)
    else
        local fadeOut = CCTintTo:create(0.5, 150, 150, 150)
        local fadeIn = CCTintTo:create(0.5, 255, 255, 255)
        local callFunc = CCCallFunc:create(callBack)
        local arr = CCArray:create()
        arr:addObject(fadeOut)
        arr:addObject(fadeIn)
        arr:addObject(callFunc)
        local seq = CCSequence:create(arr)
        selectSp:runAction(seq)
    end
end

function worldScene:changeBaseRandom(oldx, oldy, newx, newy, uid, tb, boom, boomMax, boomAt, boomBmd, skinInfo, banner)
    if SizeOfTable(self.curShowBases) == 0 then
        do
            return
        end
    end
    local aid, newid = 0, 0
    local newBaseVo = worldBaseVoApi:getBaseVo(newx, newy)
    if newBaseVo then
        aid = newBaseVo.aid --保留军团城市领地标识
    end
    newid = worldBaseVoApi:getMidByPos(newx, newy)
    local playerBaseVo = worldBaseVoApi:getBaseVo(oldx, oldy)
    if playerBaseVo == nil and uid ~= nil then
        if uid ~= playerVoApi:getUid() then --不是自己的基地
            playerBaseVo = worldBaseVo:new(tb.id, tb.oid, tb.name, tb.type, tb.level, tb.x, tb.y, tb.ptEndTime, tb.power, tb.rank, tb.pic, tb.allianceName, nil, nil, nil, boom, boomMax, boomAt, boomBmd, playerBaseVo.mineExp, skinInfo, banner)
        end
    end
    if playerBaseVo ~= nil then
        local areaX, areaY = worldBaseVoApi:getAreaXY(oldx, oldy)
        if self.curShowBases[areaX] ~= nil then --显示在屏幕上
            local playerBaseSp = self.curShowBases[areaX][areaY]
            if playerBaseSp ~= nil then
                self.curShowBases[areaX][areaY] = nil
                local newAreaX, newAreaY = worldBaseVoApi:getAreaXY(newx, newy)
                if self.curShowBases[newAreaX] ~= nil then
                    --[[
            playerBaseSp:setPosition(ccp(newPixelPoint.x,self.worldSize.height-newPixelPoint.y)) --基地改变坐标
            self.curShowBases[newAreaX*1000+newAreaY][newx*1000+newy]=playerBaseSp
        worldBaseVoApi:add(playerBaseVo.id,playerBaseVo.oid,playerBaseVo.name,playerBaseVo.type,playerBaseVo.level,newx,newy,playerBaseVo.ptEndTime,playerBaseVo.power,playerBaseVo.rank,playerBaseVo.pic) --添加新的Vo
            ]]
                    playerBaseSp:removeFromParentAndCleanup(true)
                    newBaseVo = worldBaseVoApi:add(newid, playerBaseVo.oid, playerBaseVo.name, playerBaseVo.type, playerBaseVo.level, newx, newy, playerBaseVo.ptEndTime, playerBaseVo.power, playerBaseVo.rank, playerBaseVo.pic, playerBaseVo.allianceName, nil, nil, nil, boom, boomMax, boomAt, boomBmd, playerBaseVo.mineExp, playerBaseVo.richLv, nil, nil, skinInfo, banner) --添加新的Vo
                    newBaseVo:updateData({aid = aid, bpic = playerBaseVo.bpic})
                    local tmpDataTb = {}
                    tmpDataTb[newAreaX] = {[newAreaY] = worldBaseVoApi:getBaseVo(newx, newy)}
                    self:realShowBase(tmpDataTb, true)
                else
                    newBaseVo = worldBaseVoApi:add(newid, playerBaseVo.oid, playerBaseVo.name, playerBaseVo.type, playerBaseVo.level, newx, newy, playerBaseVo.ptEndTime, playerBaseVo.power, playerBaseVo.rank, playerBaseVo.pic, playerBaseVo.allianceName, nil, nil, nil, boom, boomMax, boomAt, boomBmd, playerBaseVo.mineExp, playerBaseVo.richLv, nil, nil, skinInfo, banner) --添加新的Vo
                    newBaseVo:updateData({aid = aid, bpic = playerBaseVo.bpic})
                    
                    playerBaseSp:removeFromParentAndCleanup(true)
                    if self.fireBuildParent then
                        self.fireBuildParent = nil
                    end
                end
            end
        else
            local tmpDataTb = {}
            local newAreaX, newAreaY = worldBaseVoApi:getAreaXY(newx, newy)
            newBaseVo = worldBaseVoApi:add(newid, playerBaseVo.oid, playerBaseVo.name, playerBaseVo.type, playerBaseVo.level, newx, newy, playerBaseVo.ptEndTime, playerBaseVo.power, playerBaseVo.rank, playerBaseVo.pic, playerBaseVo.allianceName, nil, nil, nil, boom, boomMax, boomAt, boomBmd, playerBaseVo.mineExp, playerBaseVo.richLv, nil, nil, skinInfo, banner) --添加新的Vo
            newBaseVo:updateData({aid = aid, bpic = playerBaseVo.bpic})
            
            tmpDataTb[newAreaX] = {[newAreaY] = worldBaseVoApi:getBaseVo(newx, newy)}
            if self.curShowBases[newAreaX] ~= nil then
                -- newBaseVo=worldBaseVoApi:add(playerBaseVo.id,playerBaseVo.oid,playerBaseVo.name,playerBaseVo.type,playerBaseVo.level,newx,newy,playerBaseVo.ptEndTime,playerBaseVo.power,playerBaseVo.rank,playerBaseVo.pic,playerBaseVo.allianceName,nil,nil,nil,boom,boomMax,boomAt,boomBmd,playerBaseVo.mineExp,playerBaseVo.richLv) --添加新的Vo
                self:realShowBase(tmpDataTb, true)
            end
        end
        local oldBaseId, oldBaseAid = 0, 0
        local oldBaseVo = worldBaseVoApi:getBaseVo(oldx, oldy)
        if oldBaseVo then
            oldBaseId, oldBaseAid = oldBaseVo.id, oldBaseVo.aid
        end
        
        worldBaseVoApi:removeBaseVo(oldx, oldy) --移除旧的Vo
        
        if oldBaseAid > 0 then --如果旧位置属于军团领地的话，baseVo需要重新创建
            oldBaseVo = worldBaseVoApi:add(oldBaseId, nil, "", 0, 0, oldx, oldy) --添加新的Vo
            oldBaseVo:updateData({aid = oldBaseAid})
        end
        
        if playerBaseVo.oid == playerVoApi:getUid() then --自己搬家发通知给全服
            -- print("bdata.bid----->>>>",bdata.bid)
            local params = {uid = playerVoApi:getUid(), oldx = oldx, oldy = oldy, newx = newx, newy = newy, id = playerBaseVo.id, oid = playerBaseVo.oid, name = playerBaseVo.name, type = playerBaseVo.type, level = playerBaseVo.level, x = playerBaseVo.x, y = playerBaseVo.y, ptEndTime = playerBaseVo.ptEndTime, power = playerBaseVo.power, rank = playerBaseVo.rank, pic = playerBaseVo.pic, allianceName = playerBaseVo.allianceName, boom = boom, boomMax = boomMax, boomAt = boomAt, boomBmd = boomBmd, bpic = playerBaseVo.bpic, banner = banner}
            chatVoApi:sendUpdateMessage(3, params)
            if base.isGlory == 1 and self.isGloryOver == true then
                self.firebuildBg = nil
                self:firByMySelf(self.isGloryOver)
            end
        end
    end
end

--移除旧的军团城市
function worldScene:removeAllianceCity(oldpinfo, alliance)
    if oldpinfo == nil or type(oldpinfo) ~= "table" or alliance == nil then
        do return end
    end
    local refreshMapTb = {}
    for k, v in pairs(oldpinfo) do
        for kk, mid in pairs(v) do
            local pos = worldBaseVoApi:getPosByMid(mid)
            local x, y = pos.x, pos.y
            local baseVo = worldBaseVoApi:getBaseVo(x, y)
            if baseVo then
                local bx, by = worldBaseVoApi:getAreaXY(x, y)
                if baseVo.type == 8 then
                    if self.curShowBases[bx] ~= nil then
                        local baseSp = self.curShowBases[bx][by]
                        if baseSp then
                            baseSp:removeFromParentAndCleanup(true)
                        end
                        self.curShowBases[bx][by] = nil
                    end
                end
                if (baseVo.aid > 0 and baseVo.aid == alliance.aid) or (baseVo.aid == 0)then --如果该地块属于该军团的领地，做以下处理
                    if baseVo.type ~= 8 and baseVo.type ~= 0 then
                        baseVo.aid = 0 --如果不是空地或者军团城市所占地块，则领地标识aid置为0
                    else
                        worldBaseVoApi:removeBaseVo(x, y) --否则移除旧的数据
                    end
                else --如果不是该军团的军团领地，做以下处理
                    if baseVo.type == 8 then --如果是军团城市所占地块，则地块类型置为空地，军团领地标识aid不变
                        baseVo:updateData({type = 0, level = 0, ptEndTime = 0, allianceName = "", oid = 0, banner = ""})
                    end
                end
                if self.curShowBases[bx] ~= nil then
                    if refreshMapTb[bx] == nil then
                        refreshMapTb[bx] = {}
                    end
                    refreshMapTb[bx][by] = baseVo
                end
            end
            self:removeTerritoryBoundary(x, y)
        end
    end
    self:realShowBase(refreshMapTb)
end

--创建新的军团城市
function worldScene:createAllianceCity(pinfo, alliance)
    if pinfo == nil or type(pinfo) ~= "table" or alliance == nil then
        do return end
    end
    local refreshMapTb = {}
    local aid, name, level, ptEndTime = alliance.aid, alliance.name, alliance.level, alliance.ptEndTime
    local banner = alliance.banner
    for k, v in pairs(pinfo) do
        for kk, mid in pairs(v) do
            local pos = worldBaseVoApi:getPosByMid(mid)
            local x, y = pos.x, pos.y
            local bx, by = worldBaseVoApi:getAreaXY(x, y)
            if worldBaseVoApi:getShowBasesByArea(bx) ~= nil then
                local baseVo = worldBaseVoApi:getBaseVo(x, y)
                if baseVo == nil then --如果原先没有数据则添加军团城市数据
                    if k == 1 then
                        baseVo = worldBaseVoApi:add(mid, aid, "", 8, level, x, y, 0)
                        baseVo:updateData({ptEndTime = ptEndTime, allianceName = name, banner = banner})
                    else
                        baseVo = worldBaseVoApi:add(mid, nil, "", 0, 0, x, y, 0)
                        baseVo:updateData({aid = aid})
                    end
                else
                    if k == 1 then
                        baseVo:updateData({type = 8, oid = aid, level = level, allianceName = name, ptEndTime = ptEndTime, banner = banner})
                    else
                        baseVo:updateData({aid = aid})
                    end
                end
                if self.curShowBases[bx] ~= nil then
                    local baseSp = self.curShowBases[bx][by]
                    if baseSp then
                        baseSp:removeFromParentAndCleanup(true)
                    end
                    self.curShowBases[bx][by] = nil
                    if refreshMapTb[bx] == nil then
                        refreshMapTb[bx] = {}
                    end
                    refreshMapTb[bx][by] = baseVo
                end
            end
        end
    end
    self:realShowBase(refreshMapTb)
end

--拓展或回收领地
function worldScene:createOrRecycleTerritory(mid, alliance, recycleFlag)
    if mid == nil or alliance == nil then
        do return end
    end
    local refreshMapTb = {}
    local pos = worldBaseVoApi:getPosByMid(mid)
    local x, y = pos.x, pos.y
    local bx, by = worldBaseVoApi:getAreaXY(x, y)
    if self.curShowBases[bx] ~= nil then
        local baseVo = worldBaseVoApi:getBaseVo(x, y)
        if baseVo then
            if recycleFlag == true then
                baseVo.aid = 0 --如果是回收领地，清空aid
            else
                baseVo.aid = alliance.aid --如果是拓展领地，则设置aid
            end
        elseif recycleFlag ~= true then
            baseVo = worldBaseVoApi:add(mid, nil, "", 0, 0, x, y)
            baseVo:updateData({aid = alliance.aid})
        end
        if baseVo then
            if refreshMapTb[bx] == nil then
                refreshMapTb[bx] = {}
            end
            refreshMapTb[bx][by] = baseVo
        end
        local refreshTb = {{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}}
        for kk, vv in pairs(refreshTb) do --如果是拓展领地或者回收领地则需要刷新该地块周围的地块的数据
            local tmpx, tmpy = vv[1], vv[2]
            local bx, by = worldBaseVoApi:getAreaXY(tmpx, tmpy)
            local baseVo = worldBaseVoApi:getBaseVo(tmpx, tmpy)
            if baseVo then
                if refreshMapTb[bx] == nil then
                    refreshMapTb[bx] = {}
                end
                refreshMapTb[bx][by] = baseVo
            end
        end
    end
    self:realShowBase(refreshMapTb)
end

--刷新部分地块的数据
function worldScene:refreshMapBase(mapData)
    if mapData == nil or type(mapData) ~= "table" then
        do return end
    end
    local refreshMapTb = {}
    for k, baseData in pairs(mapData) do
        local x, y = baseData.x, baseData.y
        local baseVo = worldBaseVoApi:getBaseVo(x, y)
        if baseVo then
            baseVo:updateData(baseData)
            local bx, by = worldBaseVoApi:getAreaXY(x, y)
            if self.curShowBases[bx] ~= nil then
                local baseSp = self.curShowBases[bx][by]
                if baseSp then
                    baseSp:removeFromParentAndCleanup(true)
                end
                self.curShowBases[bx][by] = nil
                if refreshMapTb[bx] == nil then
                    refreshMapTb[bx] = {}
                end
                refreshMapTb[bx][by] = baseVo
            end
        end
    end
    self:realShowBase(refreshMapTb)
end

function worldScene:addProtect(x, y, uid, edTime)
    local mapx, mapy, oid, endTime, skinId
    if uid == nil then
        mapx = playerVoApi:getMapX()
        mapy = playerVoApi:getMapY()
        oid = playerVoApi:getUid()
        endTime = playerVoApi:getProtectEndTime()
        skinId = buildDecorateVoApi:getNowUse()
    else
        mapx = x
        mapy = y
        oid = uid
        endTime = edTime
    end
    local playerBaseVo = worldBaseVoApi:getBaseVo(mapx, mapy)
    if playerBaseVo ~= nil and playerBaseVo.type == 6 and playerBaseVo.oid == oid then
        playerBaseVo.ptEndTime = endTime
    end
    if uid == nil then --玩家自己加了保护要通知全服
        local params = {uid = playerVoApi:getUid(), x = playerVoApi:getMapX(), y = playerVoApi:getMapY(), endTime = endTime, skinId = skinId}
        chatVoApi:sendUpdateMessage(1, params)
    end
    if playerBaseVo ~= nil and playerBaseVo.type == 6 then
        for k, v in pairs(self.curShowBases) do
            
            for kk, vv in pairs(v) do
                if worldBaseVoApi:getBaseVo(math.floor(kk / 1000), kk % 1000).oid == oid and worldBaseVoApi:getBaseVo(math.floor(kk / 1000), kk % 1000).type == 6 then
                    -- print("worldBaseVoApi:getBaseVo(math.floor(kk / 1000), kk % 1000).isSkin====>>>> ",worldBaseVoApi:getBaseVo(math.floor(kk / 1000), kk % 1000).isSkin)
                    if vv:getChildByTag(102) == nil then
                        local protectedSp = CCSprite:createWithSpriteFrameName("ShieldingShape.png")
                        protectedSp:setAnchorPoint(ccp(0.5, 0.5))
                        protectedSp:setPosition(ccp(vv:getContentSize().width / 2 + 10, vv:getContentSize().height / 2))
                        protectedSp:setTag(102)
                        protectedSp:setScale(1.9)
                        vv:addChild(protectedSp)
                        if skinId == "b11" or skinId == "b12" or skinId == "b13" then
                            protectedSp:setScale(3.2)
                        end
                    end
                    do
                        return
                    end
                end
            end
        end
    end
end

function worldScene:removeProtect(x, y, uid)
    local mapx, mapy, oid
    if uid == nil then
        mapx = playerVoApi:getMapX()
        mapy = playerVoApi:getMapY()
        oid = playerVoApi:getUid()
    else
        mapx = x
        mapy = y
        oid = uid
    end
    local playerBaseVo = worldBaseVoApi:getBaseVo(mapx, mapy)
    if playerBaseVo == nil then
        do
            return
        end
    end
    if oid == playerVoApi:getUid() then --先判断自己是不是有保护
        
        if playerBaseVo.ptEndTime > 0 and playerBaseVo.ptEndTime >= base.serverTime then
            playerBaseVo.ptEndTime = 0
        else
            do
                
                return
            end
        end
    end
    
    if playerBaseVo ~= nil and playerBaseVo.type == 6 and playerBaseVo.oid == oid then
        playerBaseVo.ptEndTime = 0
    end
    if oid == playerVoApi:getUid() then --玩家自己移除了保护，发消息通知全服
        local params = {uid = playerVoApi:getUid(), x = playerVoApi:getMapX(), y = playerVoApi:getMapY(), endTime = 0}
        chatVoApi:sendUpdateMessage(2, params)
    end
    if playerBaseVo ~= nil and playerBaseVo.type == 6 then
        for k, v in pairs(self.curShowBases) do
            for kk, vv in pairs(v) do
                if worldBaseVoApi:getBaseVo(math.floor(kk / 1000), kk % 1000).oid == oid then
                    if oid == playerVoApi:getUid() then
                        if vv:getChildByTag(102) ~= nil then
                            tolua.cast(vv:getChildByTag(102), "CCSprite"):removeFromParentAndCleanup(true)
                        end
                        
                    else
                        vv:removeFromParentAndCleanup(true)
                        self.curShowBases[k][kk] = nil
                        local tmpDataTb = {}
                        local newPixelPt = self:toPiexl(ccp(mapx, mapy))
                        local newAreaX = math.ceil(newPixelPt.x / 1000)
                        local newAreaY = math.ceil(newPixelPt.y / 1000)
                        tmpDataTb[newAreaX * 1000 + newAreaY] = {[mapx * 1000 + mapy] = worldBaseVoApi:getBaseVo(mapx, mapy)}
                        self:realShowBase(tmpDataTb, true)
                    end
                    do
                        return
                    end
                end
            end
        end
    end
end

--给城市加保护罩
function worldScene:addCityProtect(x, y, ptEndTime)
    local baseVo = worldBaseVoApi:getBaseVo(x, y)
    if baseVo == nil then
        do return end
    end
    baseVo.ptEndTime = ptEndTime or 0
    if baseVo.type == 8 and ptEndTime > base.serverTime then
        local areaX, areaY = worldBaseVoApi:getAreaXY(x, y)
        if self.curShowBases[areaX] and self.curShowBases[areaX][areaY] then
            local baseSp = tolua.cast(self.curShowBases[areaX][areaY], "LuaCCSprite")
            if baseSp and baseSp:getChildByTag(102) == nil then
                local protectedSp = CCSprite:createWithSpriteFrameName("ShieldingShape.png")
                protectedSp:setAnchorPoint(ccp(0.5, 0.5))
                protectedSp:setPosition(ccp(baseSp:getContentSize().width / 2, baseSp:getContentSize().height / 2))
                protectedSp:setTag(102)
                protectedSp:setScale(2)
                baseSp:addChild(protectedSp)
            end
        end
    end
end

--移除军团城市保护罩
function worldScene:removeCityProtect(x, y)
    local baseVo = worldBaseVoApi:getBaseVo(x, y)
    if baseVo == nil then
        do return end
    end
    baseVo.ptEndTime = 0
    if baseVo.type == 8 and baseVo.aid then
        local areaX, areaY = worldBaseVoApi:getAreaXY(x, y)
        if self.curShowBases[areaX] and self.curShowBases[areaX][areaY] then
            local baseSp = tolua.cast(self.curShowBases[areaX][areaY], "LuaCCSprite")
            if baseSp and baseSp:getChildByTag(102) then
                local protectedSp = tolua.cast(baseSp:getChildByTag(102), "CCSprite")
                if protectedSp then
                    protectedSp:removeFromParentAndCleanup(true)
                    protectedSp = nil
                end
            end
        end
    end
end

function worldScene:updateUserName(x, y, uid, uName)
    local mapx, mapy, oid, userName
    if uid == nil then
        mapx = playerVoApi:getMapX()
        mapy = playerVoApi:getMapY()
        oid = playerVoApi:getUid()
        userName = ""
        if playerVoApi:getPlayerName() then
            userName = playerVoApi:getPlayerName() --获取自己玩家名称
        end
    else
        mapx = x
        mapy = y
        oid = uid
        userName = uName or "*****"
    end
    local playerBaseVo = worldBaseVoApi:getBaseVo(mapx, mapy)
    if playerBaseVo ~= nil and playerBaseVo.type == 6 and playerBaseVo.oid == oid then
        playerBaseVo.name = userName
    end
    local areaX, areaY = worldBaseVoApi:getAreaXY(mapx, mapy)
    if self.curShowBases[areaX] and self.curShowBases[areaX][areaY] then
        local baseSp = tolua.cast(self.curShowBases[areaX][areaY], "LuaCCSprite")
        if baseSp then
            local userNameSp = baseSp:getChildByTag(100)
            if userNameSp then
                local lb = tolua.cast(userNameSp:getChildByTag(1001), "CCLabelTTF")
                if lb then
                    lb:setString(userName)
                    userNameSp:setContentSize(CCSizeMake(lb:getContentSize().width + 15, lb:getContentSize().height + 4))
                    lb:setPosition(ccp(userNameSp:getContentSize().width / 2, userNameSp:getContentSize().height / 2))
                    local allianceSp = baseSp:getChildByTag(103)
                    if allianceSp and tolua.cast(allianceSp, "CCSprite") then
                        allianceSp:setPositionX(userNameSp:getPositionX() - userNameSp:getContentSize().width / 2 - 20)
                    end
                end
            end
        end
    end
end

function worldScene:updateAllianceName(x, y, uid, aName, aBanner)
    local mapx, mapy, oid, allianceName, banner
    if uid == nil then
        mapx = playerVoApi:getMapX()
        mapy = playerVoApi:getMapY()
        oid = playerVoApi:getUid()
        allianceName = ""
        local alliance = allianceVoApi:getSelfAlliance()
        if alliance and alliance.name then
            allianceName = alliance.name --获取自己的公会名
            banner = alliance.banner
        end
    else
        mapx = x
        mapy = y
        oid = uid
        allianceName = aName or ""
        banner = aBanner
        local playerBaseVo = worldBaseVoApi:getBaseVo(mapx, mapy)
        for k, v in pairs(self.curShowBases) do
            for kk, vv in pairs(v) do
                if mapx == math.floor(kk / 1000) and mapy == kk % 1000 then
                    local curBaseVo = worldBaseVoApi:getBaseVo(mapx, mapy)
                    if curBaseVo ~= nil and curBaseVo.type == 6 then
                        curBaseVo.allianceName = allianceName
                        curBaseVo.banner = banner
                        if allianceName == "" then
                            if tolua.cast(vv, "CCSprite"):getChildByTag(103) ~= nil then
                                
                                tolua.cast(vv:getChildByTag(103), "CCSprite"):removeFromParentAndCleanup(true)
                            end
                        elseif allianceVoApi:getSelfAlliance() and allianceName == allianceVoApi:getSelfAlliance().name then
                            if base.isAf == 1 then
                                if tolua.cast(vv, "CCNode"):getChildByTag(103) == nil then
                                    local userNameSp = vv:getChildByTag(100)
                                    -- 新的军团图标
                                    local alliance = allianceVoApi:getSelfAlliance()
                                    local defaultSelect = allianceVoApi:getFlagIconTab(alliance.banner)
                                    local allianceSp = allianceVoApi:createShowFlag(defaultSelect[1], defaultSelect[2], defaultSelect[3], 0.2)
                                    allianceSp:setPosition(ccp(userNameSp:getPositionX() - userNameSp:getContentSize().width / 2 - 20, userNameSp:getPositionY()))
                                    vv:addChild(allianceSp, 2)
                                    allianceSp:setTag(103)
                                end
                            else
                                if tolua.cast(vv, "CCSprite"):getChildByTag(103) == nil then
                                    local userNameSp = vv:getChildByTag(100)
                                    local allianceSp = CCSprite:createWithSpriteFrameName("ArmyGroupIcon.png")
                                    allianceSp:setAnchorPoint(ccp(1, 0.5))
                                    allianceSp:setPosition(ccp(userNameSp:getPositionX() - userNameSp:getContentSize().width / 2, userNameSp:getPositionY()))
                                    vv:addChild(allianceSp, 2)
                                    allianceSp:setTag(103)
                                end
                            end
                        elseif tostring(curBaseVo.allianceName) == tostring(allianceName) then
                            if base.isAf == 1 then
                                if tolua.cast(vv, "CCNode"):getChildByTag(103) == nil then
                                    local userNameSp = vv:getChildByTag(100)
                                    -- 新的军团图标
                                    local defaultSelect = allianceVoApi:getFlagIconTab(banner)
                                    local allianceSp = allianceVoApi:createShowFlag(defaultSelect[1], defaultSelect[2], defaultSelect[3], 0.2)
                                    allianceSp:setPosition(ccp(userNameSp:getPositionX() - userNameSp:getContentSize().width / 2 - 20, userNameSp:getPositionY()))
                                    vv:addChild(allianceSp, 2)
                                    allianceSp:setTag(103)
                                end
                            end
                        end
                    end
                end
            end
        end
        
    end
    local playerBaseVo = worldBaseVoApi:getBaseVo(mapx, mapy)
    if playerBaseVo ~= nil and playerBaseVo.type == 6 and playerBaseVo.oid == oid then
        playerBaseVo.allianceName = allianceName
        playerBaseVo.banner = banner
    end
end
--修改地图上自己的名字
function worldScene:addSelfAllianceName()
    local playerBaseVo = worldBaseVoApi:getBaseVo(playerVoApi:getMapX(), playerVoApi:getMapY())
    if playerBaseVo ~= nil and playerBaseVo.type == 6 then
        local alliance = allianceVoApi:getSelfAlliance()
        if alliance and alliance.name then
            playerBaseVo.allianceName = alliance.name --获取自己的公会名
            playerBaseVo.banner = alliance.banner -- 军团旗帜
        end
    end
end

function worldScene:addAllianceSp()
    for k, v in pairs(self.curShowBases) do
        for kk, vv in pairs(v) do
            local curBaseVo = worldBaseVoApi:getBaseVo(math.floor(kk / 1000), kk % 1000)
            if curBaseVo ~= nil and curBaseVo.type == 6 and curBaseVo.allianceName == allianceVoApi:getSelfAlliance().name then
                if base.isAf == 1 then
                    if tolua.cast(vv, "CCNode"):getChildByTag(103) == nil then
                        local userNameSp = vv:getChildByTag(100)
                        -- 新的军团图标
                        local alliance = allianceVoApi:getSelfAlliance()
                        local defaultSelect = allianceVoApi:getFlagIconTab(alliance.banner)
                        local allianceSp = allianceVoApi:createShowFlag(defaultSelect[1], defaultSelect[2], defaultSelect[3], 0.2)
                        allianceSp:setPosition(ccp(userNameSp:getPositionX() - userNameSp:getContentSize().width / 2 - 20, userNameSp:getPositionY()))
                        vv:addChild(allianceSp, 2)
                        allianceSp:setTag(103)
                    end
                else
                    if tolua.cast(vv, "CCSprite"):getChildByTag(103) == nil then
                        local userNameSp = vv:getChildByTag(100)
                        local allianceSp = CCSprite:createWithSpriteFrameName("ArmyGroupIcon.png")
                        allianceSp:setAnchorPoint(ccp(1, 0.5))
                        allianceSp:setPosition(ccp(userNameSp:getPositionX() - userNameSp:getContentSize().width / 2, userNameSp:getPositionY()))
                        vv:addChild(allianceSp, 2)
                        allianceSp:setTag(103)
                    end
                end
            end
        end
    end
    
end
function worldScene:removeAllianceSp()
    if base.isAf == 1 then
        do return end
    end
    for k, v in pairs(self.curShowBases) do
        for kk, vv in pairs(v) do
            local curBaseVo = worldBaseVoApi:getBaseVo(math.floor(kk / 1000), kk % 1000)
            if curBaseVo ~= nil and curBaseVo.type == 6 then
                if tolua.cast(vv, "CCSprite"):getChildByTag(103) ~= nil then
                    tolua.cast(vv:getChildByTag(103), "CCSprite"):removeFromParentAndCleanup(true)
                end
            end
        end
    end
end

function worldScene:firByMySelf(isF)
    -- print("isf-----SizeOfTable(self.buildSelfTb)",isF,SizeOfTable(self.buildSelfTb),self.fireBuildParent , self.firebuildBg  )
    -- print("111111",isF,SizeOfTable(self.buildSelfTb))
    if isF == true and SizeOfTable(self.buildSelfTb) > 0 and self.fireBuildParent ~= nil and self.firebuildBg == nil then
        self:fireBuilding(self.fireBuildParent, self.buildSelfTb.oid, self.buildSelfTb.type, true)
    elseif isF == false then
        if self.firebuildBg ~= nil then
            self.firebuildBg:stopAllActions()
            self.firebuildBg:removeFromParentAndCleanup(true)
            self.firebuildBg = nil
            tolua.cast(self.fireBuildParent, "CCSprite"):setColor(ccc3(255, 255, 255))
        end
    end
end

function worldScene:fireBuilding(buildPic, oid, tType, boomBmd)
    
    if boomBmd then
        local isFire = gloryVoApi:getIsFire(boomBmd)
        if isFire == true then
            buildPic:setColor(ccc3(136, 136, 136))
            local pzFrameName = "bf1.png"
            local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
            if oid == playerVoApi:getUid() and tType == 6 then
                self.firebuildBg = metalSp
            end
            metalSp:setAnchorPoint(ccp(0.5, 0.5))
            if tType == 6 then
                metalSp:setScale(2.0)
                metalSp:setPosition(ccp(buildPic:getContentSize().width * 0.55, buildPic:getContentSize().height * 0.28))
            else
                metalSp:setScale(1.3)
                metalSp:setPosition(ccp(buildPic:getContentSize().width * 0.55, buildPic:getContentSize().height * 0.4))
            end
            -- metalSp:setScale(1.3)
            -- metalSp:setPosition(ccp(buildPic:getContentSize().width*0.55,buildPic:getContentSize().height*0.4))
            local pzArr = CCArray:create()
            for kk = 1, 11 do
                local nameStr = "bf"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
            end
            local animation = CCAnimation:createWithSpriteFrames(pzArr)
            animation:setDelayPerUnit(0.08)
            local animate = CCAnimate:create(animation)
            local repeatForever = CCRepeatForever:create(animate)
            metalSp:runAction(repeatForever)
            metalSp:setTag(9527)
            buildPic:addChild(metalSp, 3)
        end
    end
end

function worldScene:mineChange(data)
    if(base.landFormOpen ~= 1 or base.richMineOpen ~= 1) and ((base.wl ~= 1 or base.goldmine ~= 1) or base.privatemine ~= 1) then
        do return end
    end
    local needRefresh = false
    for k, v in pairs(data) do
        local vo = worldBaseVoApi:getBaseVo(v.x, v.y)
        if(vo and vo.type >= 1 and vo.type <= 5)then
            vo.expireTime = 0
            for areaIndex, areaTb in pairs(self.curShowBases) do
                if(needRefresh)then
                    break
                end
                for kk, vv in pairs(areaTb) do
                    if(math.floor(kk / 1000) == v.x and kk % 1000 == v.y)then
                        needRefresh = true
                        break
                    end
                end
            end
        end
    end
    if(needRefresh)then
        self.waitShowBase = true
        self.checkcodeValue = 0
        self.lastRefreshTime = G_getCurDeviceMillTime()
        for k, v in pairs(self.curShowBases) do
            for kk, vv in pairs(v) do
                vv:removeFromParentAndCleanup(true)
                vv = nil
            end
            self.curShowBases[k] = nil
        end
    end
end

function worldScene:refreshChangedMine()
    if self.clayer == nil then
        return
    end
    local areaTb = {}
    local fourPoints = self:get4Points()
    for k, v in pairs(fourPoints) do
        if self.curShowBases[v.x * 1000 + v.y] ~= nil then --只刷新地图上显示出来的矿点
            areaTb[v.x * 1000 + v.y] = v.x * 1000 + v.y
        end
    end
    local needShowInMapTb = {}
    for k, v in pairs(areaTb) do
        local refreshTb = worldBaseVoApi:getShowBasesByArea(k)
        if refreshTb then
            needShowInMapTb[k] = refreshTb
        end
    end
    self:realShowBase(needShowInMapTb)
end

function worldScene:refreshMine(data)
    if data then
        for k, v in pairs(data) do
            local areaX, areaY = worldBaseVoApi:getAreaXY(v.x, v.y)
            if self.curShowBases[areaX] then
                local baseSp = self.curShowBases[areaX][areaY]
                local baseVo = worldBaseVoApi:getBaseVo(v.x, v.y)
                if baseSp and baseVo then
                    baseVo.level = v.lv
                    if base.minellvl == 1 and base.wl == 1 and baseVo.mineExp then
                        baseVo.curLv = worldBaseVoApi:getMineLvByBaseLevelAndExp(baseVo.mineExp, baseVo.level)
                    else
                        baseVo.curLv = baseVo.level
                    end
                    local dataTb = {}
                    dataTb[areaX] = {[areaY] = baseVo}
                    self:realShowBase(dataTb)
                end
            end
        end
    end
end

-- 更新地块
function worldScene:refreshTileCell(data)
    if data then
        local isUpdate = false
        for areax, v in pairs(data) do
            for areay, vv in pairs(v) do
                if self.curShowBases[areax] ~= nil and self.curShowBases[areax][areay] ~= nil then
                    local baseSp = self.curShowBases[areax][areay]
                    if baseSp then
                        baseSp:removeFromParentAndCleanup(true)
                        baseSp = nil
                        self.curShowBases[areax][areay] = nil
                        isUpdate = true
                    end
                end
            end
        end
        
        if isUpdate then
            self:realShowBase(data)
        end
    end
end

-- 获得当前屏幕中心点在世界地图的位置
function worldScene:getScreenPos()
    local screenCenterPosInClayer = self.showLayer:convertToNodeSpace(ccp(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    local centerRealPos = ccp(screenCenterPosInClayer.x, self.worldSize.height - screenCenterPosInClayer.y)
    local pPos = ccp(math.floor((centerRealPos.x + 80) / 160), math.floor((centerRealPos.y - 60) / 100))
    return pPos
end

-- 每帧检查是否需要生成行军路线
function worldScene:checkTankSlot()
    -- 判断是否支持行军路线
    if G_isShowLineSprite() == false then
        do return end
    end
    -- 判断是否已创建layer
    if self.clayer == nil or self.clayer:isVisible() == false then
        do return end
    end
    -- 10帧检查一次行军路线
    if self.tankLineRefreshTime < 50 then
        self.tankLineRefreshTime = self.tankLineRefreshTime + 1
        do return end
    end
    -- 回归计数器
    self.tankLineRefreshTime = 0
    
    -- 获取行军队列
    local tankSlot = attackTankSoltVoApi:getAllAttackTankSlots()
    -- 判断是否有新添加的
    for k, v in pairs(tankSlot) do
        -- 逐帧判断是否有未初始化完成的路线
        if self.showTankLine[v.slotId] == nil then
            -- 生成行军路线
            self:addTankLineSp(v)
        else
            local nowState, leftTime = attackTankSoltVoApi:getSlotStateAndTime(v)
            if nowState ~= nil and self.tankLineState[v.slotId] ~= nowState then
                -- print("removeTankSlotSp ~= state",v.slotId)
                -- 移除旧路线
                self:removeTankSlotSp(v.slotId)
                -- 生成新路线 (换方向)
                self:addTankLineSp(v)
            elseif leftTime ~= nil and self.showTankLine[v.slotId] ~= v.slotId and leftTime <= 0 then
                -- print("removeTankSlotSp leftTime<0",v.slotId)
                -- 移除旧路线
                self:removeTankSlotSp(v.slotId)
                -- 生成新路线 (换方向)
                self:addTankLineSp(v)
            end
        end
    end
    
    -- 获取敌军来袭队列
    local enemySlot = enemyVoApi:getEnemyAll()
    -- 判断是否有新添加的
    for k, v in pairs(enemySlot) do
        -- 逐帧判断是否有未初始化完成的路线
        if self.showEnemyLine[v.slotId] == nil then
            -- 生成敌军来袭路线
            self:addEnemyTankLineSp(v)
        elseif v.time then
            local leftTime = v.time - base.serverTime
            if leftTime ~= nil and self.showEnemyLine[v.slotId] ~= v.slotId and leftTime <= 0 then
                -- print("removeEnemyTankSlotSp leftTime<0",v.slotId)
                -- 移除旧路线
                self:removeEnemyTankSlotSp(v.slotId)
                -- 生成新路线 (换方向)
                self:addEnemyTankLineSp(v)
            end
        end
    end
end

-- 添加敌军来袭路线
function worldScene:addEnemyTankLineSp(slotVo)
    if slotVo == nil or slotVo.time == nil then
        do return end
    end
    local totalTime = slotVo.totalTime
    local leftTime = slotVo.time - base.serverTime
    -- 剩余时间和全部时间必须大于0
    if totalTime and totalTime > 0 and leftTime and leftTime > 0 and slotVo.enemyPlace and slotVo.enemyPlace[1] and slotVo.place and slotVo.place[1] then
        -- print("add EnemyTankSlot",slotVo.slotId)
        -- 来袭坐标
        local startPoint, endPoint = self:getSlotPoint(slotVo, true)
        -- openGL实现路线渲染系统
        local tankLineSp = LineSprite:create("public/red_line.png")
        tankLineSp:setSpeed(0.13)
        self.clayer:addChild(tankLineSp, 1000)
        tankLineSp:setLine(startPoint, endPoint)
        self.showEnemyLine[slotVo.slotId] = tankLineSp -- 存储路线精灵
        -- self.tankLineState[slotVo.slotId] = slotState -- 存储路线状态
        self.tankLineCount = self.tankLineCount + 1
        
        -- 航行距离
        local distance = self:getDistance(startPoint, endPoint)
        -- 航行速度
        local speed = distance / totalTime
        -- 已经航行时间
        local passedTime = totalTime - leftTime
        -- 已经航行的距离
        local passedDistance = speed * passedTime
        -- 起始坐标
        local xOff = ((endPoint.x - startPoint.x) / distance) * passedDistance
        local yOff = ((endPoint.y - startPoint.y) / distance) * passedDistance
        -- 添加行军路线的图标
        local function clickEnemyTankIcon()
            PlayEffect(audioCfg.mouseClick)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            -- print("clickEnemyTankIcon")
            smallDialog:showEnemyComingDialog("PanelHeaderPopupRed.png", CCSizeMake(600, 320), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, true, getlocal("attackedTitle"), 4, nil, slotVo.slotId)
        end
        -- 图标背景
        local tankIconItem = GetButtonItem("enemy_slot_icon.png", "enemy_slot_icon_down.png", "enemy_slot_icon_down.png", clickEnemyTankIcon, 343)
        tankIconItem:setAnchorPoint(ccp(0.5, 0))
        -- local tankIconBg = LuaCCSprite:createWithSpriteFrameName("tank_slot_icon.png",clickTankIcon)
        -- tankIconBg:setAnchorPoint(ccp(0.5,0))
        local tankIconBg = CCMenu:createWithItem(tankIconItem)
        tankIconBg:setPosition(ccp(startPoint.x + xOff, startPoint.y + yOff - 10))
        tankIconBg:setTouchPriority(-10)
        -- tankIconBg:setIsSallow(true)
        self.clayer:addChild(tankIconBg, 1001)
        -- 剩余时间显示
        local leftTimeLbl = GetTTFLabel(GetTimeStr(leftTime), 17)
        leftTimeLbl:setAnchorPoint(ccp(0.5, 1))
        leftTimeLbl:setPosition(ccp(tankIconItem:getContentSize().width / 2, tankIconItem:getContentSize().height - 6))
        tankIconItem:addChild(leftTimeLbl, 1)
        leftTimeLbl:setTag(171)
        -- 存储行军图标
        self.enemyLineIcon[slotVo.slotId] = tankIconBg
        
        -- 到达目的地 移除自己
        local function removeSelfCallBack()
            if tankIconBg ~= nil then
                self.enemyLineIcon[slotVo.slotId] = nil
                tankIconBg:removeFromParentAndCleanup(true)
                tankIconBg = nil
            end
        end
        -- 前进动画
        local moveTo = CCMoveTo:create(leftTime, endPoint)
        local removeFunc = CCCallFunc:create(removeSelfCallBack)
        local seq = CCSequence:createWithTwoActions(moveTo, removeFunc)
        tankIconBg:runAction(seq)
        
    end
end
-- 移除敌军来袭信息图标
function worldScene:removeEnemyTankSlotSp(slotIndex)
    if slotIndex and self.showEnemyLine[slotIndex] ~= nil then
        -- print("remove EnemyTankSlot",slotIndex,self.showEnemyLine[slotIndex])
        if type(self.showEnemyLine[slotIndex]) ~= "string" and type(self.showEnemyLine[slotIndex]) ~= "number" then
            if self.showEnemyLine[slotIndex].removeFromParentAndCleanup then
                self.showEnemyLine[slotIndex]:removeFromParentAndCleanup(true)
                -- 移除图标
                if self.enemyLineIcon[slotIndex] ~= nil then
                    self.enemyLineIcon[slotIndex]:removeFromParentAndCleanup(true)
                    self.enemyLineIcon[slotIndex] = nil
                end
            end
        end
        self.showEnemyLine[slotIndex] = nil
        -- self.tankLineState[slotIndex] = nil
        self.tankLineCount = self.tankLineCount - 1
    end
end

-- 每次同步行军队列数据之后，检查是否有需要移除的路线
function worldScene:checkEndTankSlot(isEnemy)
    -- print("worldScene:checkEndTankSlot()")
    -- 判断是否支持行军路线
    if G_isShowLineSprite() == false then
        do return end
    end
    if isEnemy == true then
        local enemyTankSlot = enemyVoApi:getEnemyAll()
        local enemySlotBySlotId = {}
        for k, v in pairs(enemyTankSlot) do
            enemySlotBySlotId[v.slotId] = v.slotId
            -- print("enemySlot id",v.slotId)
        end
        -- 遍历查找是否有需要移除的路线精灵
        for k, v in pairs(self.showEnemyLine) do
            if enemySlotBySlotId[k] == nil then
                -- print("removeEnemyTankSlotSp == nil",k)
                -- 移除路线精灵
                self:removeEnemyTankSlotSp(k)
            end
        end
    else
        local attackTankSlot = attackTankSoltVoApi:getAllAttackTankSlots()
        local tankSlotBySlotId = {}
        for k, v in pairs(attackTankSlot) do
            tankSlotBySlotId[v.slotId] = v.slotId
            -- print("slot id",v.slotId)
        end
        -- 遍历查找是否有需要移除的路线精灵
        for k, v in pairs(self.showTankLine) do
            if tankSlotBySlotId[k] == nil then
                -- print("removeTankSlotSp == nil",k)
                -- 移除路线精灵
                self:removeTankSlotSp(k)
            end
        end
    end
end

-- 添加行军路线
function worldScene:addTankLineSp(slotVo)
    local slotState, leftTime, totalTime = attackTankSoltVoApi:getSlotStateAndTime(slotVo)
    if slotState ~= 1 and slotState ~= 4 then
        self.showTankLine[slotVo.slotId] = slotVo.slotId -- 存储路线精灵
        self.tankLineState[slotVo.slotId] = slotState -- 存储路线状态
        self.tankLineCount = self.tankLineCount + 1
        do return end
    end
    -- print("add TankSlot",slotVo.slotId)
    -- 玩家坐标
    local startPoint, endPoint = self:getSlotPoint(slotVo)
    -- 如果行军状态是4，返航需要调换坐标
    if slotState == 4 then
        local pos = endPoint
        endPoint = startPoint
        startPoint = pos
        pos = nil
    end
    -- openGL实现路线渲染系统
    local tankLineSp = LineSprite:create("public/green_line.png")
    -- local tankLineSp = LineSprite:create("public/tank_slot_line.png")
    -- tankLineSp:setColor(G_ColorGreenLine)
    tankLineSp:setSpeed(0.13)
    self.clayer:addChild(tankLineSp, 1000)
    tankLineSp:setLine(startPoint, endPoint)
    self.showTankLine[slotVo.slotId] = tankLineSp -- 存储路线精灵
    self.tankLineState[slotVo.slotId] = slotState -- 存储路线状态
    self.tankLineCount = self.tankLineCount + 1
    -- 剩余时间和全部时间必须大于0
    if leftTime > 0 and totalTime > 0 then
        -- 航行距离
        local distance = self:getDistance(startPoint, endPoint)
        -- 航行速度
        local speed = distance / totalTime
        -- 已经航行时间
        local passedTime = totalTime - leftTime
        -- 已经航行的距离
        local passedDistance = speed * passedTime
        -- 起始坐标
        local xOff = ((endPoint.x - startPoint.x) / distance) * passedDistance
        local yOff = ((endPoint.y - startPoint.y) / distance) * passedDistance
        -- 添加行军路线的图标
        local function clickTankIcon()
            PlayEffect(audioCfg.mouseClick)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            self:showTankSlotWarEvent(slotVo)
        end
        -- 图标背景
        local tankIconItem = GetButtonItem("tank_slot_icon.png", "tank_slot_icon_down.png", "tank_slot_icon_down.png", clickTankIcon, 343)
        tankIconItem:setAnchorPoint(ccp(0.5, 0))
        -- local tankIconBg = LuaCCSprite:createWithSpriteFrameName("tank_slot_icon.png",clickTankIcon)
        -- tankIconBg:setAnchorPoint(ccp(0.5,0))
        local tankIconBg = CCMenu:createWithItem(tankIconItem)
        tankIconBg:setPosition(ccp(startPoint.x + xOff, startPoint.y + yOff - 10))
        tankIconBg:setTouchPriority(-10)
        -- tankIconBg:setIsSallow(true)
        self.clayer:addChild(tankIconBg, 1001)
        -- 剩余时间显示
        local leftTimeLbl = GetTTFLabel(GetTimeStr(leftTime), 17)
        leftTimeLbl:setAnchorPoint(ccp(0.5, 1))
        leftTimeLbl:setPosition(ccp(tankIconItem:getContentSize().width / 2, tankIconItem:getContentSize().height - 6))
        tankIconItem:addChild(leftTimeLbl, 1)
        leftTimeLbl:setTag(171)
        -- 存储行军图标
        self.tankLineIcon[slotVo.slotId] = tankIconBg
        
        -- 到达目的地 移除自己
        local function removeSelfCallBack()
            if tankIconBg ~= nil then
                self.tankLineIcon[slotVo.slotId] = nil
                tankIconBg:removeFromParentAndCleanup(true)
                tankIconBg = nil
            end
        end
        -- 前进动画
        local moveTo = CCMoveTo:create(leftTime, endPoint)
        local removeFunc = CCCallFunc:create(removeSelfCallBack)
        local seq = CCSequence:createWithTwoActions(moveTo, removeFunc)
        tankIconBg:runAction(seq)
    end
end

-- 移除行军队列信息图标
function worldScene:removeTankSlotSp(slotIndex)
    if self.showTankLine[slotIndex] ~= nil then
        print("remove TankSlot", slotIndex)
        if self.tankLineState[slotIndex] == 1 or self.tankLineState[slotIndex] == 4 then
            self.showTankLine[slotIndex]:removeFromParentAndCleanup(true)
            -- 移除舰队图标
            if self.tankLineIcon[slotIndex] ~= nil then
                self.tankLineIcon[slotIndex]:removeFromParentAndCleanup(true)
                self.tankLineIcon[slotIndex] = nil
            end
        end
        self.showTankLine[slotIndex] = nil
        self.tankLineState[slotIndex] = nil
        self.tankLineCount = self.tankLineCount - 1
    end
end

-- 显示单一行军信息面板
function worldScene:showTankSlotWarEvent(slotVo)
    if self.clayer:isVisible() == false then
        do return end
    end
    local function closeCallBack()
    end
    local dlayerNum = 4
    if self.oneWarEventTd == nil then
        require "luascript/script/game/scene/gamedialog/warEvent/oneWarEventDialog"
        self.oneWarEventTd = oneWarEventDialog:new()
    end
    local dialog = self.oneWarEventTd:initDialog("PanelHeaderPopup.png", CCSizeMake(600, 270), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), dlayerNum, getlocal("fleetEvent"), slotVo, closeCallBack)
    if dialog then
        dialog:setPosition(getCenterPoint(sceneGame))
        sceneGame:addChild(dialog, dlayerNum)
    end
end

-- 定位行军队列信息图标
function worldScene:showTankSlotSp(slotVo)
    -- print("worldScene:showTankSlotSp()")
    -- 判断图标是否存在
    if self.tankLineIcon == nil then
        do return end
    end
    if slotVo.bs == nil and (slotVo.isGather == 2 or slotVo.isGather == 3 or slotVo.isGather == 4 or slotVo.isGather == 5 or slotVo.isGather == 6) then
        local posX = tonumber(slotVo.targetid[1])
        local posY = tonumber(slotVo.targetid[2])
        if posX and posY then
            self:focus(posX, posY)
        end
    else
        for k, v in pairs(self.tankLineIcon) do
            if k == slotVo.slotId then
                -- local slotPosX = v:getPositionX()
                -- local slotPosY = v:getPositionY()
                -- local posX = -(slotPosX - G_VisibleSize.width/2)
                -- local posY = -(slotPosY - G_VisibleSize.height/2)
                -- local pos = ccp(posX,posY)
                self:focusByTankSlot(v)
                do return end
            end
        end
    end
end

-- 定位行军队列信息图标
function worldScene:focusTankSlotSp(slotVo)
    -- 判断是否支持行军路线
    if G_isShowLineSprite() == false then
        self:showTankSlotWarEvent(slotVo)
    else
        self:showTankSlotSp(slotVo)
        local slotState = attackTankSoltVoApi:getSlotStateAndTime(slotVo)
        if slotState ~= 1 and slotState ~= 4 then
            self:showTankSlotWarEvent(slotVo)
        end
    end
end

function worldScene:getDistance(point1, point2)
    local diffX = point1.x - point2.x
    local diffY = point1.y - point2.y
    local distance = math.sqrt((diffX * diffX) + (diffY * diffY))
    return distance
end

-- 根据行军队列定位图标，坐标是clayer的真实坐标，不是世界地图的虚拟坐标（0，0）-（600，600）
function worldScene:focusByTankSlot(icon)
    -- self.showLayer:setPosition(ccp(pos.x,pos.y))
    if icon == nil or tolua.cast(icon, "CCMenu") == nil then
        do return end
    end
    if icon:getParent() == nil then
        do return end
    end
    local worldPos = icon:getParent():convertToWorldSpace(ccp(icon:getPosition()))
    local offsetx, offsety = G_VisibleSizeWidth / 2 - worldPos.x, G_VisibleSizeHeight / 2 - worldPos.y
    local x, y = self.showLayer:getPositionX() + offsetx, self.showLayer:getPositionY() + offsety
    self.showLayer:setPosition(ccp(x, y))
    
    if self.mapLayer then
        self.mapLayer:setPosition(self.clayer:getPosition())
    end
    self.needFadeEffectPos = worldScene:getScreenPos()
    mainUI:directSignMove(self.needFadeEffectPos)
    self:getNeedShowSps()
    self:checkBound()
    self.waitShowBase = true
    
    local function blinkSlotIconFunc(node)
        -- 图标闪烁
        local delayTime = CCDelayTime:create(0.1)
        local fadeOut = CCTintTo:create(0.3, 80, 80, 80)
        local fadeIn = CCTintTo:create(0.3, 255, 255, 255)
        local acArr = CCArray:create()
        acArr:addObject(delayTime)
        acArr:addObject(fadeOut)
        acArr:addObject(fadeIn)
        acArr:addObject(fadeOut)
        acArr:addObject(fadeIn)
        local seq = CCSequence:create(acArr)
        node:runAction(seq)
    end
    if icon ~= nil then
        -- 定位之后，行军图标闪烁
        blinkSlotIconFunc(icon)
    end
    
    -- 获得当前屏幕位置
    self.preScreenPos = self.showLayer:convertToNodeSpace(ccp(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    -- 区分首次显示
    self.preScreenPos.x = self.preScreenPos.x + 1
    self.preScreenPos.y = self.preScreenPos.y + 1
    self.nowScreenPos = self.preScreenPos
end

--添加金矿倒计时,mineType :特殊矿的类型 "private" : 保护矿
function worldScene:addDisappearTimeLb(baseSp, mtype, mid, x, y, isOccupy, mineType)
    if isOccupy == nil then
        isOccupy = false
    end
    local offsetY = 0
    if isOccupy == true then
        offsetY = -8
    end
    if baseSp then
        local ppoint = self:toPiexl(ccp(x, y))
        local areaX = math.ceil(ppoint.x / 1000)
        local areaY = math.ceil(ppoint.y / 1000)
        if ppoint.x % 1000 == 0 then
            areaX = areaX + 1
        end
        if ppoint.y % 1000 == 0 then
            areaY = areaY + 1
        end
        if self.leftTimeLbTb[areaX * 1000 + areaY] == nil then
            self.leftTimeLbTb[areaX * 1000 + areaY] = {}
        end
        -- print("here?????????????????????/",baseSp:getChildByTag(1022),mineType)
        if self.leftTimeLbTb[areaX * 1000 + areaY][x * 1000 + y] == nil then
            -- 背景
            local tipBg = LuaCCScale9Sprite:createWithSpriteFrameName("goldmine_time_bg.png", CCRect(5, 10, 1, 1), function () end)
            tipBg:setAnchorPoint(ccp(0.5, 0))
            -- 时间
            local lefttime = nil
            if mineType and mineType == "private" then
                lefttime = privateMineVoApi:getPrivateMineLeftTime(mid)
            else
                lefttime = goldMineVoApi:getGoldMineLeftTime(mid)
            end
            local timeLb = GetTTFLabel(GetTimeStr(lefttime), 16 / baseSp:getScale())
            timeLb:setAnchorPoint(ccp(0.5, 0.5))
            tipBg:setContentSize(CCSizeMake(timeLb:getContentSize().width + 14, timeLb:getContentSize().height + 8))
            tipBg:setPosition(ccp(baseSp:getContentSize().width / 2, baseSp:getContentSize().height - 30))
            tipBg:setTouchPriority(-2)
            tipBg:setIsSallow(false)
            baseSp:addChild(tipBg, 2)
            
            timeLb:setPosition(ccp(tipBg:getContentSize().width / 2, tipBg:getContentSize().height / 2))
            -- timeLb:setColor(G_ColorYellowPro)
            tipBg:addChild(timeLb)
            self.leftTimeLbTb[areaX * 1000 + areaY][x * 1000 + y] = timeLb
            --添加粒子动画
            if baseSp:getChildByTag(1022) == nil then
                local starAni = nil
                if mineType and mineType == "private" then-----保护矿 换新的粒子
                    starAni = CCSprite:createWithSpriteFrameName("privtateC_1.png")
                    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
                    blendFunc.src = GL_ONE
                    blendFunc.dst = GL_ONE
                    starAni:setBlendFunc(blendFunc)
                    local toSelfArr = CCArray:create()
                    for kk = 1, 12 do
                        local nameStr = "privtateC_"..kk..".png"
                        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                        toSelfArr:addObject(frame)
                    end
                    
                    local bufAnimation = CCAnimation:createWithSpriteFrames(toSelfArr)
                    bufAnimation:setDelayPerUnit(0.125)
                    local animate = CCAnimate:create(bufAnimation)
                    local repeatForever1 = CCRepeatForever:create(animate)
                    starAni:runAction(repeatForever1)
                    starAni:setPosition(baseSp:getContentSize().width * 0.5, baseSp:getContentSize().height * 0.5)
                else
                    starAni = CCParticleSystemQuad:create("public/fukuang.plist")
                    starAni:setPosition(baseSp:getContentSize().width / 2, 30)
                    starAni:setScale(1.5 / baseSp:getScale())
                    starAni:setPositionType(kCCPositionTypeGrouped)
                end
                starAni:setTag(1022)
                baseSp:addChild(starAni)
            end
        elseif baseSp and baseSp:getChildByTag(1022) == nil and mineType == "private" then
            -- 背景
            local tipBg = LuaCCScale9Sprite:createWithSpriteFrameName("goldmine_time_bg.png", CCRect(5, 10, 1, 1), function () end)
            tipBg:setAnchorPoint(ccp(0.5, 0))
            local lefttime = privateMineVoApi:getPrivateMineLeftTime(mid)
            
            local timeLb = GetTTFLabel(GetTimeStr(lefttime), 16 / baseSp:getScale())
            timeLb:setAnchorPoint(ccp(0.5, 0.5))
            tipBg:setContentSize(CCSizeMake(timeLb:getContentSize().width + 14, timeLb:getContentSize().height + 8))
            tipBg:setPosition(ccp(baseSp:getContentSize().width / 2, baseSp:getContentSize().height - 30))
            tipBg:setTouchPriority(-2)
            tipBg:setIsSallow(false)
            baseSp:addChild(tipBg, 2)
            
            timeLb:setPosition(ccp(tipBg:getContentSize().width / 2, tipBg:getContentSize().height / 2))
            -- timeLb:setColor(G_ColorYellowPro)
            tipBg:addChild(timeLb)
            self.leftTimeLbTb[areaX * 1000 + areaY][x * 1000 + y] = timeLb
            
            local starAni = CCSprite:createWithSpriteFrameName("privtateC_1.png")
            local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
            blendFunc.src = GL_ONE
            blendFunc.dst = GL_ONE
            starAni:setBlendFunc(blendFunc)
            local toSelfArr = CCArray:create()
            for kk = 1, 12 do
                local nameStr = "privtateC_"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                toSelfArr:addObject(frame)
            end
            
            local bufAnimation = CCAnimation:createWithSpriteFrames(toSelfArr)
            bufAnimation:setDelayPerUnit(0.125)
            local animate = CCAnimate:create(bufAnimation)
            local repeatForever1 = CCRepeatForever:create(animate)
            starAni:runAction(repeatForever1)
            starAni:setPosition(baseSp:getContentSize().width * 0.5, baseSp:getContentSize().height * 0.5)
            starAni:setTag(1022)
            baseSp:addChild(starAni)
        end
    end
end

function worldScene:removeDisappearTimeLb(x, y)
    if self.curShowBases[x] == nil then
        self.leftTimeLbTb[x] = nil
    elseif self.curShowBases[x][y] == nil then
        self.leftTimeLbTb[x][y] = nil
    else
        if self.leftTimeLbTb and self.leftTimeLbTb[x] and self.leftTimeLbTb[x][y] then
            if tolua.cast(self.leftTimeLbTb[x][y], "CCLabelTTF") and self.leftTimeLbTb[x][y].getParent and self.leftTimeLbTb[x][y]:getParent() then
                if(tolua.cast(self.leftTimeLbTb[x][y]:getParent(), "CCNode"))then
                    self.leftTimeLbTb[x][y]:getParent():removeFromParentAndCleanup(true)
                end
                self.leftTimeLbTb[x][y] = nil
            end
            --添加粒子动画
            local baseSp = self.curShowBases[x][y]
            local starAni = baseSp:getChildByTag(1022)
            if starAni ~= nil then
                starAni:removeFromParentAndCleanup(true)
            end
        end
    end
end

function worldScene:getShowSpriteIndex(pos)
    local px = self:toCellPoint(pos)
    local indexX = math.floor(px.x / 10)
    local indexY = math.floor(px.y / 10)
    return indexX, indexY
end

function worldScene:getNeedShowIndexs()
    local halfWidth, halfHeight = G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2
    local centerPos = self.showLayer:convertToNodeSpace(ccp(halfWidth, halfHeight))
    
    local marginOffset = 75
    local posLeftBottom = ccp(centerPos.x - halfWidth - marginOffset, centerPos.y - halfHeight - marginOffset)
    local posLeft = ccp(centerPos.x - halfWidth - marginOffset, centerPos.y)
    local posLeftTop = ccp(centerPos.x - halfWidth - marginOffset, centerPos.y + halfHeight + marginOffset)
    local posRightBottom = ccp(centerPos.x + halfWidth + marginOffset, centerPos.y - halfHeight - marginOffset)
    local posRight = ccp(centerPos.x + halfWidth + marginOffset, centerPos.y)
    local posRightTop = ccp(centerPos.x + halfWidth + marginOffset, centerPos.y + halfHeight + marginOffset)
    local lbx, lby = self:getShowSpriteIndex(posLeftBottom)
    local lx, ly = self:getShowSpriteIndex(posLeft)
    local ltx, lty = self:getShowSpriteIndex(posLeftTop)
    local rbx, rby = self:getShowSpriteIndex(posRightBottom)
    local rx, ry = self:getShowSpriteIndex(posRight)
    local rtx, rty = self:getShowSpriteIndex(posRightTop)
    
    local start_indexX, start_indexY = self:getShowSpriteIndex(centerPos)
    
    -- 预加载块数
    local needShowIndexs = {}
    for xv = start_indexX - 1, start_indexX + 1 do
        if xv >= 0 then
            for yv = start_indexY - 1, start_indexY + 1 do
                if yv >= 0 then
                    local showGround = false
                    if (xv == lbx and yv == lby) or
                        (xv == lx and yv == ly) or
                        (xv == ltx and yv == lty) or
                        (xv == rbx and yv == rby) or
                        (xv == rx and yv == ry) or
                        (xv == rtx and yv == rty) or
                        (xv == start_indexX and yv == start_indexY) then
                        showGround = true
                    end
                    needShowIndexs[xv * 100 + yv] = {xv, yv, showGround}
                end
            end
        end
    end
    
    return needShowIndexs
end

--给地图加装饰物
function worldScene:addOrnamentals()
    if self.clayer == nil then
        do return end
    end
    local needShowIndexs = self:getNeedShowIndexs()
    self.tmxIndex = 1
    self.tmxLandIndex = 1
    self.mapTileObjs = {}
    local showTmxNum = 0
    for k, v in pairs(needShowIndexs) do
        if v[3] then
            showTmxNum = showTmxNum + 1
            self:showOrnamentals(v[1], v[2])
        end
    end
    
    local totalTMXNum = #self.tmx
    for i = self.tmxIndex, totalTMXNum do
        local ornamentalSp = tolua.cast(self.tmx[i], "CCSprite")
        if ornamentalSp then
            ornamentalSp:setVisible(false)
        end
    end
    
    -- local totalTMXLandNum = #self.tmxLand
end

function worldScene:showOrnamentals(start_indexX, start_indexY)
    local width, height = tonumber(mapOrnamentalCfg["width"]), tonumber(mapOrnamentalCfg["height"])
    local num = width * height
    
    local idxX, idxY = start_indexX, start_indexY
    if idxX > 30 then idxX = idxX - 30 end
    if idxY > 30 then idxY = idxY - 30 end
    local level = (idxY - 1) * 30 + idxX
    if level < 1 then
        level = 1
    elseif level > 900 then
        level = 900
    end
    local function areaAndIndex(landIdx)
        local indexX = start_indexX * 10 + landIdx % 10 + 1
        local indexY = start_indexY * 10 + math.floor(landIdx / 10) + 1
        local pixel = self:toPiexl(ccp(indexX, indexY))
        local areaX = math.ceil(pixel.x / 1000)
        local areaY = math.ceil(pixel.y / 1000)
        if pixel.x % 1000 == 0 then
            areaX = areaX + 1
        end
        if pixel.y % 1000 == 0 then
            areaY = areaY + 1
        end
        local baseIndex1, baseIndex2 = areaX * 1000 + areaY, indexX * 1000 + indexY
        local baseExist = (self.curShowBases[baseIndex1] and self.curShowBases[baseIndex1][baseIndex2]) ~= nil
        
        return areaY, pixel, baseExist, baseIndex1, baseIndex2, indexX, indexY
    end
    
    local landIdx = mapOrnamentalCfg["landCfg"][level]
    local ornamentalCfg = mapOrnamentalCfg["ornamentalCfg"][landIdx]
    local tileCfg = mapOrnamentalCfg["ornamental"]
    for i = 1, num do
        local areaY, pixel, baseExist, baseIndex1, baseIndex2, indexX, indexY = areaAndIndex(i - 1)
        local isShowOrnamental = false
        local idx = ornamentalCfg[i]
        if idx and idx > 0 and tileCfg[idx] ~= nil then
            isShowOrnamental = true
        end
        if isShowOrnamental then
            if not baseExist and isShowOrnamental then
                local treeFrame = tileCfg[idx]
                local tmxSp = self.tmx[self.tmxIndex]
                if tmxSp then
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(treeFrame)
                    local tmxSp = tolua.cast(tmxSp, "CCSprite")
                    if tmxSp and frame then
                        tmxSp:setDisplayFrame(frame)
                        tmxSp:setVisible(true)
                    end
                else
                    self.tmx[self.tmxIndex] = CCSprite:createWithSpriteFrameName(treeFrame)
                    self.spBatchNode:addChild(self.tmx[self.tmxIndex], areaY)
                    tmxSp = self.tmx[self.tmxIndex]
                end
                if tmxSp then
                    tmxSp = tolua.cast(tmxSp, "CCSprite")
                    if tmxSp then
                        tmxSp:setPosition(ccp(pixel.x, self.worldSize.height - pixel.y))
                        self.spBatchNode:reorderChild(tmxSp, areaY)
                        tmxSp:setScale(0.5) -- 装饰缩放
                    end
                end
                if not self.mapTileObjs[baseIndex1] then
                    self.mapTileObjs[baseIndex1] = {}
                end
                self.mapTileObjs[baseIndex1][baseIndex2] = self.tmx[self.tmxIndex]
                
                self.tmxIndex = self.tmxIndex + 1
            end
        end
        
        --通过地块坐标算出地表的位置
        local surfaceX = (indexX - 2) / 3 + 1
        local surfaceY = (indexY - 2) / 3 + 1
        if surfaceX == math.floor(surfaceX) and surfaceY == math.floor(surfaceY) then --该坐标位置可以显示地表
            local surfaceIdx = (surfaceY - 1) * 200 + surfaceX
            local imgId = mapOrnamentalCfg["surfaceCfg"][surfaceIdx]
            if imgId and mapOrnamentalCfg["surface"][imgId] then
                local surfaceFrame = mapOrnamentalCfg["surface"][imgId]
                local tmxLandSp = self.tmxLand[self.tmxLandIndex]
                if tmxLandSp then
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(surfaceFrame)
                    tmxLandSp = tolua.cast(tmxLandSp, "CCSprite")
                    if tmxLandSp and frame then
                        tmxLandSp:setDisplayFrame(frame)
                    end
                else
                    self.tmxLand[self.tmxLandIndex] = CCSprite:createWithSpriteFrameName(surfaceFrame)
                    self.spBatchNode_1:addChild(self.tmxLand[self.tmxLandIndex])
                    tmxLandSp = self.tmxLand[self.tmxLandIndex]
                end
                if tmxLandSp then
                    tmxLandSp:setPosition(ccp(pixel.x, self.worldSize.height - pixel.y))
                end
                self.tmxLandIndex = self.tmxLandIndex + 1
            end
        end
    end
end

function worldScene:showAniOrnamentals()
    local function showOrnamental(delayTime, num, otype, probability)
        if self.clayer == nil then
            do return end
        end
        local delay = CCDelayTime:create(delayTime)
        local function createFunc()
            for i = 1, num do
                local num = math.random(1, 100)
                if num >= probability then
                    local ornamental = self:createOrnamental()
                    if otype == 1 then
                        self:showFlyBird(ornamental)
                    elseif otype == 2 then
                        self:showSpiralBird(ornamental)
                    elseif otype == 3 then
                        self:showCloud(ornamental)
                    else
                        self:showPlane(ornamental)
                    end
                end
            end
        end
        local func = CCCallFunc:create(createFunc)
        local seq = CCSequence:createWithTwoActions(func, delay)
        local repeatForever = CCRepeatForever:create(seq)
        self.clayer:runAction(repeatForever)
    end
    showOrnamental(10, 3, 1, 60)
    showOrnamental(12, 3, 2, 60)
    showOrnamental(14, 3, 3, 60)
    showOrnamental(16, 3, 4, 60)
end

--从世界坐标转到3d场景坐标
function worldScene:countNodeSpace(x, y, angle, anchor)
    -- angle = -angle
    anchor = anchor or {x = 0, y = 0}
    local W = G_VisibleSize.width
    local H = G_VisibleSize.height
    local deltaX = W * anchor.x-- sprite左下角相对于屏幕左下角
    local deltaY = H * anchor.y-- sprite左下角相对于屏幕左下角
    
    x = x / W
    y = y / H
    deltaX = deltaX / W
    deltaY = deltaY / H
    
    local a = 0.5
    local b = 0.5
    local c = math.sqrt(3) / 2
    
    local y0 = c * (y - deltaY) / (c * math.cos(angle * math.pi / 180) - (y - b) * math.sin(angle * math.pi / 180))
    
    local m = c / (c + y0 * math.sin(angle * math.pi / 180))
    local x0 = (x - a) / m - deltaX + a
    
    -- return x0*W + W*anchor.x, y0*H  + H*anchor.y+ angle * 1.5 * y
    -- local m = c / (c + y0 * math.sin(angle * math.pi / 180))
    -- local x0 = (x - a) / m - deltaX + a
    
    return x0 * W + W * anchor.x, y0 * H + H * anchor.y
end

function worldScene:createOrnamental()
    if self.clayer == nil then
        do return end
    end
    local marginOffset = 200
    local radius = 2000
    local halfWidth, halfHeight = G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2
    local centerPos = self.showLayer:convertToNodeSpace(ccp(halfWidth, halfHeight))
    local leftX, rightX = centerPos.x - halfWidth - marginOffset, centerPos.x + halfWidth + marginOffset
    local bottomY, topY = centerPos.y - halfHeight - marginOffset, centerPos.y + halfHeight + marginOffset
    local num = math.random(1, 4)
    local ornamentalX, ornamentalY, direct = 0, 0, 1
    if num == 1 then
        ornamentalX = math.random(leftX, rightX)
        ornamentalY = math.random(bottomY - radius, bottomY)
    elseif num == 2 then
        ornamentalX = math.random(leftX, rightX)
        ornamentalY = math.random(topY, topY + radius)
    elseif num == 3 then
        ornamentalX = math.random(leftX - radius, leftX)
        ornamentalY = math.random(centerPos.y - radius - marginOffset, centerPos.y + radius + marginOffset)
    elseif num == 4 then
        ornamentalX = math.random(rightX, rightX + radius)
        ornamentalY = math.random(centerPos.y - radius - marginOffset, centerPos.y + radius + marginOffset)
    end
    if ornamentalY >= (bottomY - radius) and ornamentalY <= bottomY then
        if ornamentalX <= centerPos.x then
            direct = 3
        else
            direct = 1
        end
    elseif ornamentalY >= topY and ornamentalY <= topY + radius then
        if ornamentalX <= centerPos.x then
            direct = 4
        else
            direct = 2
        end
    else
        if ornamentalX <= centerPos.x then
            direct = math.random(3, 4)
        else
            direct = math.random(1, 2)
        end
    end
    local ornamental = {ornamentalX, ornamentalY, direct}
    
    return ornamental
end

--直线飞翔的鸟
function worldScene:showFlyBird(bird)
    local birdPos = ccp(bird[1], bird[2])
    local xv, yv = self:getShowSpriteIndex(birdPos)
    local idx = xv * 100 + yv
    if self.flyEagleTb[idx] == nil then
        self.flyEagleTb[idx] = {}
    end
    local count = SizeOfTable(self.flyEagleTb[idx])
    if count >= 6 then
        do return end
    end
    local function playBirdFrame(shadeFlag)
        local birdPng = "part-laoying10.png"
        if shadeFlag and shadeFlag == true then
            birdPng = "part-laoying10diying10.png"
        end
        local birdSp = CCSprite:createWithSpriteFrameName(birdPng)
        local animArr = CCArray:create()
        for i = 1, 3 do
            local maxIdx = 9
            if i == 3 then
                maxIdx = 10
            end
            for kk = 1, maxIdx do
                local nameStr = "part-laoying"..kk..".png"
                if shadeFlag and shadeFlag == true then
                    nameStr = "part-laoying"..kk.."diying"..kk..".png"
                end
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                animArr:addObject(frame)
            end
        end
        local delay = CCDelayTime:create(3)
        local animation = CCAnimation:createWithSpriteFrames(animArr)
        animation:setDelayPerUnit(0.1)
        local animate = CCAnimate:create(animation)
        local seq = CCSequence:createWithTwoActions(delay, animate)
        local repeatForever = CCRepeatForever:create(seq)
        birdSp:runAction(repeatForever)
        
        return birdSp
    end
    
    local function playMove(targetSp)
        if targetSp == nil then
            do return end
        end
        local targetPos = ccp(0, 0)
        local moveDis = 30000
        local rotate = 0
        local direct = bird[3] or 1
        local angle = 45
        if direct == 1 then
            targetPos.y = math.sin(math.rad(angle)) * moveDis + birdPos.y
            targetPos.x = -math.cos(math.rad(angle)) * moveDis + birdPos.x
        elseif direct == 2 then
            rotate = 180
            targetPos.y = -math.sin(math.rad(angle)) * moveDis + birdPos.y
            targetPos.x = math.cos(math.rad(angle)) * moveDis + birdPos.x
        elseif direct == 3 then
            rotate = 90
            targetPos.y = math.sin(math.rad(angle)) * moveDis + birdPos.y
            targetPos.x = math.cos(math.rad(angle)) * moveDis + birdPos.x
        elseif direct == 4 then
            rotate = 270
            targetPos.y = -math.sin(math.rad(angle)) * moveDis + birdPos.y
            targetPos.x = -math.cos(math.rad(angle)) * moveDis + birdPos.x
        end
        targetSp:setRotation(rotate)
        local mvTo = CCMoveTo:create(180, targetPos)
        local function spCallBack()
            targetSp:stopAllActions()
            targetSp:removeFromParentAndCleanup(true)
            table.remove(self.flyEagleTb[idx], 1)
            local count = SizeOfTable(self.flyEagleTb[idx])
        end
        local funcHandler = CCCallFunc:create(spCallBack)
        local moveSeq = CCSequence:createWithTwoActions(mvTo, funcHandler)
        targetSp:runAction(moveSeq)
    end
    local scale = 0.35
    local zorder = 10000
    local birdSp = playBirdFrame()
    local shadeBirdSp = playBirdFrame(true)
    birdSp:setPosition(birdPos)
    birdSp:setScale(scale)
    self.eagleBatchNode:addChild(birdSp, zorder)
    playMove(birdSp)
    table.insert(self.flyEagleTb[idx], birdSp)
    
    local x, y = birdPos.x - 150, birdPos.y - 120
    birdPos = ccp(x, y)
    shadeBirdSp:setPosition(birdPos)
    shadeBirdSp:setScale(scale)
    self.eagleBatchNode:addChild(shadeBirdSp, zorder)
    playMove(shadeBirdSp)
    PlayEffect(audioCfg.eagle)
end

--盘旋的鸟
function worldScene:showSpiralBird(bird)
    local radius = 200
    local birdPos = ccp(bird[1], bird[2])
    local cellPoint = self:toCellPoint(ccp(bird[1], bird[2]))
    local xv, yv = self:getShowSpriteIndex(birdPos)
    local idx = xv * 100 + yv
    if self.spiralEagleTb[idx] == nil then
        self.spiralEagleTb[idx] = {}
    end
    local count = SizeOfTable(self.spiralEagleTb[idx])
    if count >= 4 then
        do return end
    end
    local sprite = CCSprite:create()
    sprite:setAnchorPoint(ccp(0, 0))
    sprite:setContentSize(CCSizeMake(1, 320))
    local eagle = CCSprite:createWithSpriteFrameName("spiralEagle.png")
    eagle:setRotation(-45)
    sprite:addChild(eagle)
    eagle:setPosition(ccp(sprite:getContentSize().width, sprite:getContentSize().height))
    self.clayer:addChild(sprite, 2600)
    sprite:setPosition(birdPos)
    local rotate = CCRotateBy:create(10, -180)
    local repeatAc = CCRepeat:create(rotate, 30)
    local function spCallBack()
        sprite:removeFromParentAndCleanup(true)
        sprite = nil
        table.remove(self.spiralEagleTb[idx], 1)
    end
    local func = CCCallFunc:create(spCallBack)
    local seq = CCSequence:createWithTwoActions(repeatAc, func)
    sprite:runAction(seq)
    table.insert(self.spiralEagleTb[idx], sprite)
end

function worldScene:showCloud(cloud)
    local radius = 200
    local cloudPos = ccp(cloud[1], cloud[2])
    local cellPoint = self:toCellPoint(ccp(cloud[1], cloud[2]))
    local xv, yv = self:getShowSpriteIndex(cloudPos)
    local idx = xv * 100 + yv
    if self.cloudTb[idx] == nil then
        self.cloudTb[idx] = {}
    end
    local count = SizeOfTable(self.cloudTb[idx])
    if count >= 2 then
        do return end
    end
    local pngIdx = math.random(1, 2)
    local cloudPng = "mapCloud"..pngIdx..".png"
    local cloudSp = CCSprite:createWithSpriteFrameName(cloudPng)
    if cloudSp then
        cloudSp:setPosition(cloudPos)
        self.spBatchNode:addChild(cloudSp, 10001)
        local moveBy = CCMoveBy:create(360, ccp(-10000, 0))
        local function spCallBack()
            cloudSp:removeFromParentAndCleanup(true)
            cloudSp = nil
            table.remove(self.cloudTb[idx], 1)
        end
        local func = CCCallFunc:create(spCallBack)
        local seq = CCSequence:createWithTwoActions(moveBy, func)
        cloudSp:runAction(seq)
        table.insert(self.cloudTb[idx], cloudSp)
    end
end

function worldScene:showPlane(plane)
    local planePos = ccp(plane[1], plane[2])
    local xv, yv = self:getShowSpriteIndex(planePos)
    local idx = xv * 100 + yv
    if self.planeTb[idx] == nil then
        self.planeTb[idx] = {}
    end
    local count = SizeOfTable(self.planeTb[idx])
    if count >= 6 then
        do return end
    end
    local direct = plane[3] or 1
    if direct == 1 then
        direct = 3
    elseif direct == 4 then
        direct = 2
    end
    local function playRotor(targetSp, pos)
        if targetSp == nil or pos == nil then
            
        end
        local rotorSp = CCSprite:createWithSpriteFrameName("LXJ_01.png")
        rotorSp:setPosition(pos)
        targetSp:addChild(rotorSp)
        local animArr = CCArray:create()
        for kk = 1, 6 do
            local nameStr = "LXJ_0"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            animArr:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(animArr)
        animation:setDelayPerUnit(0.06)
        local animate = CCAnimate:create(animation)
        local repeatForever = CCRepeatForever:create(animate)
        rotorSp:runAction(repeatForever)
    end
    
    local function playMove(targetSp)
        if targetSp == nil then
            do return end
        end
        local targetPos = ccp(0, 0)
        local moveDis = 30000
        local angle = 45
        if direct == 2 then
            targetPos.y = -math.sin(math.rad(angle)) * moveDis + planePos.y
            targetPos.x = -math.cos(math.rad(angle)) * moveDis + planePos.x
        else
            targetPos.y = math.sin(math.rad(angle)) * moveDis + planePos.y
            targetPos.x = math.cos(math.rad(angle)) * moveDis + planePos.x
        end
        local mvTo = CCMoveTo:create(180, targetPos)
        local function spCallBack()
            targetSp:stopAllActions()
            targetSp:removeFromParentAndCleanup(true)
            table.remove(self.planeTb[idx], 1)
            local count = SizeOfTable(self.planeTb[idx])
        end
        local funcHandler = CCCallFunc:create(spCallBack)
        local moveSeq = CCSequence:createWithTwoActions(mvTo, funcHandler)
        targetSp:runAction(moveSeq)
    end
    local zorder = 10000
    local planePng = "mapPlaneA.png"
    local shadePlanePng = "planeShadowA.png"
    if direct == 2 then
        planePng = "mapPlaneB.png"
        shadePlanePng = "planeShadowB.png"
    end
    local planeSp = CCSprite:createWithSpriteFrameName(planePng)
    planeSp:setPosition(planePos)
    local leftRotorPos = ccp(38, planeSp:getContentSize().height - 10)
    local rightRotorPos = ccp(planeSp:getContentSize().width - 15, planeSp:getContentSize().height / 2 + 5)
    if direct == 2 then
        leftRotorPos = ccp(15, planeSp:getContentSize().height - 20)
        rightRotorPos = ccp(planeSp:getContentSize().width / 2 + 16, 22)
    end
    playRotor(planeSp, leftRotorPos)
    playRotor(planeSp, rightRotorPos)
    self.planeBatchNode:addChild(planeSp, zorder)
    playMove(planeSp)
    table.insert(self.planeTb[idx], planeSp)
    
    local x, y = planePos.x - 150, planePos.y - 120
    planePos = ccp(x, y)
    local planeShadowSp = CCSprite:createWithSpriteFrameName(shadePlanePng)
    planeShadowSp:setOpacity(200)
    planeShadowSp:setPosition(planePos)
    self.planeBatchNode:addChild(planeShadowSp, zorder)
    playMove(planeShadowSp)
end

--获取军团城市在地图中的像素坐标
function worldScene:toCityPiexl(x, y)
    local land_p = self:toPiexl(ccp(x, y))
    local realPoint = ccp(land_p.x, self.worldSize.height - land_p.y)
    local city_x, city_y = realPoint.x - 80, realPoint.y + 50 --城市放在四个地块的中心位置，校准坐标
    return city_x, city_y
end

function worldScene:getCityArea(x, y)
    return {{x, y}, {x - 1, y}, {x, y - 1}, {x - 1, y - 1}}
end

--根据城市的像素坐标获取该城市所在的地块坐标
function worldScene:getCityXY(point)
    local ax, ay = (point.x + 80), (point.y - 50)
    return self:toCellPoint(ccp(ax, ay))
end

--根据领地的像素坐标获取该领地所在的地块坐标
function worldScene:getTerritoryXY(point)
    return self:toCellPoint(ccp(point.x, point.y))
end

--添加一个新的操作地图的层
function worldScene:addMapLayer()
    if self.mapLayer == nil then
        local mapLayer = CCLayer:create()
        mapLayer:setTouchEnabled(true)
        local function tmpHandler(...)
            return self:touchEvent(...)
        end
        mapLayer:registerScriptTouchHandler(tmpHandler, false, -3, true)
        self.mapLayer = mapLayer
        self.mapLayer:setPosition(self.clayer:getPosition())
        if G_isUseNewMap() == true then
            self.showLayer:addChild(self.mapLayer, 1)
        else
            sceneGame:addChild(self.mapLayer, 1)
        end
    end
end

function worldScene:removeMapLayer()
    if self.mapLayer then
        self.mapLayer:removeFromParentAndCleanup(true)
        self.mapLayer = nil
    end
end

--创建一个建立城市或者领地的一个操作层
function worldScene:createBuildLayer(x, y, buildType)
    if buildType == 0 or buildType == nil then
        do return end
    end
    self.buildingType = buildType
    if self.buildingSp == nil then
        self:addMapLayer()
        local areaTb, buildingSp
        if buildType == 1 or buildType == 2 then --城市建造和搬迁
            areaTb = self:getCityArea(x, y)
            buildingSp = allianceCityVoApi:getAllianceCityIcon()
        elseif buildType == 3 or buildType == 4 then --领地的拓展和回收
            areaTb = {{x, y}}
            buildingSp = CCSprite:createWithSpriteFrameName("territoryIcon.png")
        end
        local bx, by = self:getBuildingSpPosByCellPoint(ccp(x, y))
        -- print("areaTb,bpic,bx,by",areaTb,bpic,bx,by)
        if areaTb == nil or buildingSp == nil or bx == nil or by == nil then
            do return end
        end
        buildingSp:setPosition(bx, by)
        self.mapLayer:addChild(buildingSp, 99)
        self.buildingSp = buildingSp
        self.buildingPoint = ccp(x, y)
        
        self.areaSpTb = {}
        for k, v in pairs(areaTb) do
            local area_p = self:toPiexl(ccp(v[1], v[2]))
            local landSp = CCSprite:createWithSpriteFrameName("cityArea.png")
            landSp:setPosition(area_p.x, self.worldSize.height - area_p.y)
            if self.buildingType == 4 then
                landSp:setColor(ccc3(0, 155, 20))
            else
                landSp:setColor(ccc3(170, 0, 0))
            end
            landSp:setOpacity(255 * 0.6)
            self.mapLayer:addChild(landSp, 98)
            self.areaSpTb[k] = landSp
        end
        
        local operateLayer = CCSprite:createWithSpriteFrameName("buildBtnBg.png")
        operateLayer:setPosition(buildingSp:getContentSize().width / 2, buildingSp:getContentSize().height)
        buildingSp:addChild(operateLayer)
        self.operateLayer = operateLayer
        
        local function cancel()
            self:removeBuildLayer()
            allianceCityVoApi:showAllianceCityDialog(5)
        end
        local function realDoOperate() --执行操作
            local function doneCallBack(data)
                self:removeBuildLayer()
                -- self:changeBase(data)
            end
            local pos = {self.buildingPoint.x, self.buildingPoint.y}
            if self.buildingType == 1 then --创建军团城市
                allianceCityVoApi:createOrMoveAllianceCity(pos, false, doneCallBack)
            elseif self.buildingType == 2 then --搬迁城市
                allianceCityVoApi:createOrMoveAllianceCity(pos, true, doneCallBack)
            elseif self.buildingType == 3 then --拓展领地
                allianceCityVoApi:createOrRecycleTerritory(1, pos, doneCallBack)
            elseif self.buildingType == 4 then --回收领地
                allianceCityVoApi:createOrRecycleTerritory(2, pos, doneCallBack)
            end
        end
        local function detail()
            local tabStr = {}
            if self.buildingType == 1 or self.buildingType == 2 then
                for i = 1, 3 do
                    local str = getlocal("allinacecity_build_rule"..i)
                    table.insert(tabStr, str)
                end
            elseif self.buildingType == 3 or self.buildingType == 4 then
                for i = 1, 3 do
                    local str = getlocal("alliancecity_territory_rule"..i)
                    table.insert(tabStr, str)
                end
            end
            local titleStr = getlocal("activity_baseLeveling_ruleTitle")
            require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
            tipShowSmallDialog:showStrInfo(5, true, true, nil, titleStr, tabStr, nil, 25)
        end
        local buildStr, buildPic = getlocal("build"), "buildCityBtn.png"
        if self.buildingType == 4 then
            buildStr, buildPic = getlocal("recycleStr"), "recycleSmallBtn.png"
        end
        local btnCfg = {
            {"cancelBuildBtn.png", ccp(2.5, 50), getlocal("cancel"), handler = cancel},
            {"buildDetailBtn.png", ccp(95.5, 90), getlocal("playerInfo"), handler = detail},
        {buildPic, ccp(192.5, 50), buildStr, handler = realDoOperate}}
        for k, v in pairs(btnCfg) do
            local pic, pos, btnText = v[1], v[2], v[3]
            local function touchHandler(...)
                if v.handler then
                    v.handler()
                end
            end
            local btnItem, btn = G_createBotton(operateLayer, pos, {btnText, 18}, "hexagonBtn.png", "hexagonBtnDown.png", "hexagonBtnDown.png", touchHandler, 1, -5)
            local btnSp = CCSprite:createWithSpriteFrameName(pic)
            btnSp:setPosition(getCenterPoint(btnItem))
            btnItem:addChild(btnSp)
            local lb = tolua.cast(btnItem:getChildByTag(101), "CCLabelTTF")
            lb:setPositionY(10)
        end
    end
end

--移除创建军团城市的操作层
function worldScene:removeBuildLayer()
    if self.buildingSp then
        self.buildingSp:stopAllActions()
        self.buildingSp:removeFromParentAndCleanup(true)
        self.buildingSp = nil
        if self.areaSpTb then
            for k, landSp in pairs(self.areaSpTb) do
                landSp = tolua.cast(landSp, "CCSprite")
                if landSp then
                    landSp:removeFromParentAndCleanup(true)
                end
            end
            self.areaSpTb = nil
        end
        self.operateLayer = nil
    end
    self:removeMapLayer()
    self.buildingType = 0
    self.movingSpeed = 0.1
    self.movingtc = 0
    self.isMovingBuilding = false --是否是在移动军团城市的标识
    self.movingSpaceX = 0 --移动世界地图的X速度（一次移动多少格）
    self.movingSpaceY = 0 --移动世界地图的Y速度（一次移动多少格）
    self.buildingPoint = ccp(0, 0) --城市所在位置
end

function worldScene:hideOperateLayer()
    if self.operateLayer then
        self.operateLayer:setVisible(false)
    end
end

function worldScene:showOperateLayer()
    if self.operateLayer then
        self.operateLayer:setVisible(true)
    end
end

--校准领地的位置（包括城市所在的地块）
function worldScene:adjustTerritories(x, y)
    if self.areaSpTb then
        local areaTb, disableArea
        if self.buildingType == 1 or self.buildingType == 2 then
            areaTb = self:getCityArea(x, y)
            local flag, disableTb = self:isCanBuildAllianceCity(x, y)
            disableArea = disableTb
        elseif self.buildingType == 3 or self.buildingType == 4 then
            areaTb = {{x, y}}
            if self.buildingType == 3 then
                local flag = self:isCanBuildTerritory(x, y)
                if flag == false then
                    disableArea = {}
                    disableArea[1] = 1
                end
            end
        end
        if areaTb then
            for k, v in pairs(areaTb) do
                local area_p = self:toPiexl(ccp(v[1], v[2]))
                local landSp = tolua.cast(self.areaSpTb[k], "CCSprite")
                if landSp then
                    if disableArea and disableArea[k] == 1 then
                        landSp:setColor(ccc3(170, 0, 0))
                    else
                        landSp:setColor(ccc3(0, 155, 20))
                    end
                    landSp:setPosition(area_p.x, self.worldSize.height - area_p.y)
                end
            end
        end
    end
end

--校准城市的位置
function worldScene:adjustBuildingSp(adjustAreaFlag)
    if self.buildingSp then
        local cp, bx, by
        local bpos = ccp(self.buildingSp:getPosition())
        local cp = self:getBuildingSpCellPoint()
        if cp then
            local bx, by = self:getBuildingSpPosByCellPoint(cp)
            if bx and by then
                self.buildingPoint = cp
                self.buildingSp:setPosition(bx, by)
                if adjustAreaFlag == true then
                    self:adjustTerritories(cp.x, cp.y)
                end
            end
        end
    end
end

--检测是否触摸到军团城市或者领地
function worldScene:checkTouchBuilding(buildingSp, tx, ty)
    if buildingSp then
        local cwidth, cheight = buildingSp:getContentSize().width, buildingSp:getContentSize().height
        local cityWorldPos = buildingSp:convertToWorldSpaceAR(ccp(0, 0))
        local tRect = CCRect(cityWorldPos.x - cwidth / 2, cityWorldPos.y - cheight / 2, cwidth, cheight)
        if tRect:containsPoint(ccp(tx, ty)) == true then --触摸到军团城市
            return true
        end
    end
    return false
end

--画地图军团领地的边界线（x，y是占领地块的坐标）
function worldScene:drawTerritoryBoundary(x, y)
    local baseVo = worldBaseVoApi:getBaseVo(x, y)
    if baseVo == nil then
        do return end
    end
    local aid = baseVo.aid --该地块所属军团的id
    local lineColor = ccc3(255, 215, 0) --敌方红色线
    local myAlliance = allianceVoApi:getSelfAlliance()
    if myAlliance and myAlliance.aid and myAlliance.aid > 0 then
        if baseVo.aid > 0 and baseVo.aid == myAlliance.aid then
            lineColor = ccc3(65, 215, 40) --己方绿色线
        elseif baseVo.aid == 0 and baseVo.oid and baseVo.oid == myAlliance.aid then
            lineColor = ccc3(65, 215, 40) --己方绿色线
        end
    end
    local areaX, areaY = worldBaseVoApi:getAreaXY(x, y)
    if self.mapTerritoryTb[areaX] == nil then
        self.mapTerritoryTb[areaX] = {}
    end
    if self.mapTerritoryTb[areaX][areaY] == nil then
        self.mapTerritoryTb[areaX][areaY] = {}
    end
    local land_p = self:toPiexl(ccp(x, y))
    land_p.y = self.worldSize.height - land_p.y
    local territoryArea = {
        {x, y - 1, "upEdge.png", ccp(land_p.x, land_p.y + 50 - 6), 0, 2}, --上
        {x, y + 1, "upEdge.png", ccp(land_p.x, land_p.y - 50 + 6), 180, 1}, --下
        {x - 1, y, "leftEdge.png", ccp(land_p.x - 80 + 6, land_p.y), 0, 4}, --左
        {x + 1, y, "leftEdge.png", ccp(land_p.x + 80 - 6, land_p.y), 180, 3} --右
    }
    
    for k, v in pairs(territoryArea) do
        local lx, ly = v[1], v[2]
        local edgeSp
        if self.mapTerritoryTb[areaX][areaY][k] then
            edgeSp = tolua.cast(self.mapTerritoryTb[areaX][areaY][k], "CCSprite")
        end
        local drawFlag = false
        local tmpBaseVo = worldBaseVoApi:getBaseVo(lx, ly)
        if tmpBaseVo then
            if baseVo.aid ~= tmpBaseVo.aid then
                drawFlag = true
                if (baseVo.type == 8 and baseVo.oid == tmpBaseVo.aid) or (tmpBaseVo.type == 8 and baseVo.aid == tmpBaseVo.oid) then
                    drawFlag = false
                    if baseVo.aid > 0 and tmpBaseVo.aid > 0 and baseVo.aid ~= tmpBaseVo.aid then
                        drawFlag = true
                    end
                end
            elseif baseVo.type == 8 and tmpBaseVo.type ~= 8 and baseVo.aid == 0 and tmpBaseVo.aid == 0 then
                drawFlag = true
            elseif baseVo.type == 8 and tmpBaseVo.type == 8 and baseVo.oid ~= tmpBaseVo.oid and baseVo.aid == 0 and tmpBaseVo.aid == 0 then
                drawFlag = true
            end
        else
            if baseVo.aid > 0 or baseVo.type == 8 then
                drawFlag = true
            end
        end
        
        if drawFlag == true then
            local pic, pos, angle = v[3], v[4], (v[5] or 0) --线，位置，旋转角度
            if pic and pos and edgeSp == nil then
                edgeSp = CCSprite:createWithSpriteFrameName(pic)
                if edgeSp then
                    self.edgeBatchSp:addChild(edgeSp)
                    self.mapTerritoryTb[areaX][areaY][k] = edgeSp
                end
            end
            if edgeSp then
                edgeSp:setPosition(pos)
                edgeSp:setRotation(angle)
                edgeSp:setColor(lineColor)
            end
        else
            local bx, by = worldBaseVoApi:getAreaXY(lx, ly)
            local facing = v[6] --该地块相邻地块的对象索引
            if self.mapTerritoryTb[bx] and self.mapTerritoryTb[bx][by] and self.mapTerritoryTb[bx][by][facing] then --请求到新数据后，移除掉已经画出来的老的不应该画出来的分界线
                local adjoinEdgeSp = tolua.cast(self.mapTerritoryTb[bx][by][facing], "CCSprite")
                if adjoinEdgeSp then
                    -- print("+++++remove old adjoin edge!!!+++++")
                    adjoinEdgeSp:removeFromParentAndCleanup(true)
                end
                self.mapTerritoryTb[bx][by][facing] = nil
            end
            if edgeSp then
                edgeSp:removeFromParentAndCleanup(true)
                self.mapTerritoryTb[areaX][areaY][k] = nil
            end
        end
        
    end
end

--移除领地分界线
function worldScene:removeTerritoryBoundary(x, y)
    local bx, by = worldBaseVoApi:getAreaXY(x, y)
    if self.mapTerritoryTb[bx] and self.mapTerritoryTb[bx][by] then
        for k, v in pairs(self.mapTerritoryTb[bx][by]) do
            local edgeSp = tolua.cast(v, "CCSprite")
            if edgeSp then
                edgeSp:removeFromParentAndCleanup(true)
            end
        end
        self.mapTerritoryTb[bx][by] = nil
    end
end

--判断该位置是否可以建造军团城市
function worldScene:isCanBuildAllianceCity(x, y)
    local disableArea = {}
    local cityArea = self:getCityArea(x, y)
    local cityAreaCount = 0
    for k, v in pairs(cityArea) do
        local ax, ay = v[1], v[2]
        if ax < 1 or ax > 600 or ay < 1 or ay > 600 then --出边界
            disableArea[k] = 1
        else
            local baseVo = worldBaseVoApi:getBaseVo(ax, ay)
            if baseVo and baseVo.type ~= 0 then --地块被占用
                disableArea[k] = 1
                if baseVo.type == 8 then
                    cityAreaCount = cityAreaCount + 1
                end
                local myAlliance = allianceVoApi:getSelfAlliance()
                if myAlliance and baseVo.type == 8 and myAlliance.aid == baseVo.oid then
                    disableArea[k] = nil
                end
            end
        end
    end
    if cityAreaCount >= 4 then --四个地块跟原先的军团城市位置重合
        disableArea = {1, 1, 1, 1}
    end
    if SizeOfTable(disableArea) > 0 then
        return false, disableArea
    else
        return true
    end
end

--判断该位置是否可以扩展军团领地
function worldScene:isCanBuildTerritory(x, y)
    if x < 1 or x > 600 or y < 1 or y > 600 then --出边界
        return false, 1
    end
    local baseVo = worldBaseVoApi:getBaseVo(x, y)
    if baseVo and ((baseVo.aid and baseVo.aid > 0) or (baseVo.type == 8 and baseVo.oid > 0)) then --地块所属别的军团或者该地块有军团城市
        return false, 2
    end
    local myAid = -1
    local myAlliance = allianceVoApi:getSelfAlliance()
    if myAlliance and myAlliance.aid then
        myAid = myAlliance.aid
    end
    local territoryArea = {{x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1}, {x - 1, y}, {x + 1, y}, {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}} --接壤的地块
    for k, v in pairs(territoryArea) do
        local ax, ay = v[1], v[2]
        if ax >= 1 and ax <= 600 and ay >= 1 and ay <= 600 then --接壤的地块在地图内
            local baseVo = worldBaseVoApi:getBaseVo(ax, ay)
            if baseVo and baseVo.aid == myAid then --接壤的地块是自己军团的领地
                return true
            end
        end
    end
    return false
end

--检测在移动城市或者领地时地图的移动速度
function worldScene:checkMapMovingSpace(x, y)
    local minGapX, maxGapX = 40, 100
    local minGapY, maxGapY = 40, 100
    local minSpeed, maxSpeed = 0.2, 0.8
    self.movingSpaceX, self.movingSpaceY = 0, 0
    if x <= minGapX then
        self.movingSpaceX = maxSpeed
    elseif x <= maxGapX then
        self.movingSpaceX = minSpeed
    elseif x >= G_VisibleSizeWidth - minGapX then
        self.movingSpaceX = -maxSpeed
    elseif x >= G_VisibleSizeWidth - maxGapX then
        self.movingSpaceX = -minSpeed
    end
    if y <= minGapY + self.bottomGap then
        self.movingSpaceY = maxSpeed
    elseif y <= maxGapY + self.bottomGap then
        self.movingSpaceY = minSpeed
    elseif y >= G_VisibleSizeHeight - minGapY - self.topGap then
        self.movingSpaceY = -maxSpeed
    elseif y >= G_VisibleSizeHeight - maxGapY - self.topGap then
        self.movingSpaceY = -minSpeed
    end
    -- print("self.movingSpaceX,self.movingSpaceY----->>>>",self.movingSpaceX,self.movingSpaceY)
end

function worldScene:checkMapMoving()
    if self.movingSpaceX ~= 0 or self.movingSpaceY ~= 0 then --地图有移动
        self:getNeedShowSps()
        local beforePos = ccp(self.showLayer:getPosition())
        local afterPos = ccpAdd(beforePos, ccp(self.movingSpaceX * 160, self.movingSpaceY * 100))
        local finalPos, overXFlag, overYFlag = self:checkBound(afterPos) --检测边界
        if overXFlag == true then --x方向越界话，x方向移动间隔置为0
            self.movingSpaceX = 0
        end
        if overYFlag == true then --y方向越界话，y方向移动间隔置为0
            self.movingSpaceY = 0
        end
        self.showLayer:setPosition(finalPos)
        if self.mapLayer then
            self.mapLayer:setPosition(finalPos)
        end
        self:drawMapMoveAndDirectSign()
        
        local buildMovePos = ccpSub(finalPos, beforePos)
        local buildPos = ccpSub(ccp(self.buildingSp:getPosition()), buildMovePos)
        self.buildingSp:setPosition(buildPos)
        local cp = self:getBuildingSpCellPoint()
        if cp then
            if cp.x ~= self.buildingPoint.x or cp.y ~= self.buildingPoint.y then
                self.buildingPoint = cp
                self:adjustTerritories(cp.x, cp.y)
            end
        end
    end
end

function worldScene:getBuildingSpCellPoint()
    local bpos = ccp(self.buildingSp:getPosition())
    local cp
    if self.buildingType == 1 or self.buildingType == 2 then
        cp = self:getCityXY(bpos)
    elseif self.buildingType == 3 or self.buildingType == 4 then
        cp = self:getTerritoryXY(bpos)
    end
    return cp
end

--根据城市或者领地的
function worldScene:getBuildingSpPosByCellPoint(point)
    local bx, by
    if self.buildingType == 1 or self.buildingType == 2 then
        bx, by = self:toCityPiexl(point.x, point.y)
    elseif self.buildingType == 3 or self.buildingType == 4 then
        local pos = self:toPiexl(ccp(point.x, point.y))
        bx, by = pos.x, (self.worldSize.height - pos.y)
    end
    return bx, by
end

--检测该地块是不是军团领地
function worldScene:checkIsTerritory(vv)
    if base.allianceCitySwitch == 1 then
        if vv and ((vv.aid and vv.aid > 0) or (vv.oid and vv.oid > 0 and vv.type == 8)) then
            return true
        end
    end
    return false
end

--右下角是军团城市的真正坐标
function worldScene:checkIsRealbuildingPoint(vv)
    -- if base.allianceCitySwitch==1 then --这里不做功能开关判断，考虑到功能关掉后，地图上有军团城市的数据
    if vv and vv.type == 8 and vv.x and vv.y and vv.oid then
        local baseVo = worldBaseVoApi:getBaseVo(vv.x - 1, vv.y - 1) --获取右下角坐标地块数据
        if baseVo and baseVo.type == 8 and baseVo.oid == vv.oid and vv.oid > 0 then
            return true
        end
    end
    -- end
    return false
end

--获取军团城市的真实坐标
function worldScene:getBaseSpRealPoint(vv)
    if vv == nil or (vv.type == 8 and base.allianceCitySwitch == 0) then
        return nil, nil
    end
    if vv.type == 8 or vv.type == 9 then
        local x, y = vv.x, vv.y
        local baseVo = worldBaseVoApi:getBaseVo(x - 1, y - 1)
        if baseVo and (baseVo.type == 8 or baseVo.type == 9) and baseVo.oid == vv.oid then --先判断自己是不是军团城市坐标(或欧米伽小队)
            return x, y
        end
        baseVo = worldBaseVoApi:getBaseVo(x + 1, y + 1)
        if baseVo and (baseVo.type == 8 or baseVo.type == 9) and baseVo.oid == vv.oid then --如果自己不是的话，判断右下角是不是
            return x + 1, y + 1
        end
        local adjoinCfg = {{adjoin = {x, y - 1}, real = {x + 1, y}}, {adjoin = {x - 1, y}, real = {x, y + 1}}}
        for k, v in pairs(adjoinCfg) do
            local adjoin = v.adjoin
            local real = v.real
            baseVo = worldBaseVoApi:getBaseVo(adjoin[1], adjoin[2])
            if baseVo and (baseVo.type == 8 or baseVo.type == 9) and baseVo.oid == vv.oid then
                baseVo = worldBaseVoApi:getBaseVo(real[1], real[2])
                if baseVo and (baseVo.type == 8 or baseVo.type == 9) and baseVo.oid == vv.oid then
                    return real[1], real[2]
                end
            end
        end
    end
    return nil, nil
end

--播放攻击军团城市的战斗效果
function worldScene:playAttackAllianceCityEffect(startPoint, endPoint, slotId, x, y)
    local bx, by = worldBaseVoApi:getAreaXY(x, y)
    if self.curShowBases[bx] == nil or self.curShowBases[bx][by] == nil then
        do return end
    end
    if self.acityEffectSlot[slotId] then
        do return end
    end
    local angleRadians = ccpToAngle(ccpSub(endPoint, startPoint))
    local angleDegrees = math.deg(angleRadians)
    -- print("angleDegrees------>",angleDegrees)
    local tankPic, tpx, tpy, direct
    if angleDegrees >= 0 and angleDegrees < 90 then
        tankPic, direct = "fightTank2.png", 2
        tpx, tpy = endPoint.x - 160, endPoint.y - 100
    elseif angleDegrees >= 90 and angleDegrees < 180 then
        tankPic, direct = "fightTank1.png", 1
        tpx, tpy = endPoint.x + 160, endPoint.y - 100
    elseif angleDegrees >= -180 and angleDegrees < -90 then
        tankPic, direct = "fightTank4.png", 4
        tpx, tpy = endPoint.x + 160, endPoint.y + 100
    elseif angleDegrees >= -90 and angleDegrees < 0 then
        tankPic, direct = "fightTank3.png", 3
        tpx, tpy = endPoint.x - 160, endPoint.y + 100
    end
    if tankPic == nil then
        do return end
    end
    if self.acityEffectSlot[slotId] == nil then
        self.acityEffectSlot[slotId] = {}
    end
    local bgNode = CCNode:create()
    local dipanBg = CCSprite:createWithSpriteFrameName("dipanBg1.png")
    local dipanBg2 = CCSprite:createWithSpriteFrameName("dipanBg2.png")
    bgNode:setContentSize(dipanBg:getContentSize())
    bgNode:setAnchorPoint(ccp(0.5, 0.5))
    bgNode:setPosition(tpx, tpy)
    self.clayer:addChild(bgNode, 9998)
    
    dipanBg:setPosition(getCenterPoint(bgNode))
    dipanBg2:setPosition(getCenterPoint(bgNode))
    bgNode:addChild(dipanBg)
    bgNode:addChild(dipanBg2)
    bgNode:setScaleY(0.7)
    local rotateAc = CCRotateBy:create(3, 180)
    dipanBg2:runAction(CCRepeatForever:create(rotateAc))
    
    local effectIdx = 1
    self.acityEffectSlot[slotId][effectIdx] = bgNode
    
    local function playFrames(frameName, fc, st, target, pos, angle, zorder, addFlag)
        local frameSp = CCSprite:createWithSpriteFrameName(frameName.."1.png")
        frameSp:setAnchorPoint(ccp(0.5, 0.5))
        frameSp:setPosition(pos)
        frameSp:setRotation(angle or 0)
        target:addChild(frameSp, (zorder or 0))
        
        if addFlag == true then
            effectIdx = effectIdx + 1
            self.acityEffectSlot[slotId][effectIdx] = frameSp
        end
        
        local frameArr = CCArray:create()
        for fidx = 1, fc do
            local nameStr = frameName..fidx..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            frameArr:addObject(frame)
        end
        local acArr = CCArray:create()
        local animation = CCAnimation:createWithSpriteFrames(frameArr)
        animation:setDelayPerUnit(st)
        local animate = CCAnimate:create(animation)
        acArr:addObject(animate)
        local function removeSelf()
            frameSp:removeFromParentAndCleanup(true)
            frameSp = nil
            if addFlag == true then
                if self.acityEffectSlot[slotId] and self.acityEffectSlot[slotId][effectIdx] then
                    self.acityEffectSlot[slotId][effectIdx] = nil
                end
            end
        end
        local removeFunc = CCCallFunc:create(removeSelf)
        acArr:addObject(removeFunc)
        local seq = CCSequence:create(acArr)
        frameSp:runAction(seq)
    end
    local sx = 8
    local fireCfg = {{ccp(-3, 101), -150, ccp(sx, -sx)}, {ccp(143, 106), -30, ccp(-sx, -sx)}, {ccp(139, 32.5), 29, ccp(-sx, sx)}, {ccp(5, 40), 150, ccp(sx, sx)}}
    local firePos, angle, movePos = fireCfg[direct][1], fireCfg[direct][2], fireCfg[direct][3]
    local baozaCfg = {{2, ccp(0, 0)}, {1, ccp(60, -40)}, {2, ccp(-30, 30)}, {1, ccp(-55, 20)}, {1, ccp(50, 30)}}
    
    for i = 1, 2 do
        local tankx, tanky, dlt = tpx - 10, tpy + 30, 0.5
        if i == 2 then
            tankx, tanky, dlt = tpx + 10, tpy - 30, 0
        end
        local tankSp = CCSprite:createWithSpriteFrameName(tankPic)
        tankSp:setScale(0.7)
        tankSp:setPosition(tankx, tanky)
        -- tankSp:setOpacity(0)
        self.clayer:addChild(tankSp, 9999)
        
        effectIdx = effectIdx + 1
        self.acityEffectSlot[slotId][effectIdx] = tankSp
        
        local moveArr = CCArray:create()
        local dltAc = CCDelayTime:create(dlt)
        local function tankFire()
            playFrames("tk_kh", 10, 0.06, tankSp, firePos, angle)
            
            local dltCfg = {0, 0.3}
            local baozaArr = CCArray:create()
            for k, dlt in pairs(dltCfg) do
                local delayAc = CCDelayTime:create(dlt)
                baozaArr:addObject(delayAc)
                local function baoza()
                    local baozaIdx = math.random(1, 5)
                    local cfg = baozaCfg[baozaIdx]
                    if cfg then
                        local bztype, bzpos, bzFrameName, fc = cfg[1], cfg[2], "zdk_pj", 15
                        if bztype == 2 then
                            bzFrameName, fc = "zdk_ddbz", 14
                        end
                        playFrames(bzFrameName, fc, 0.06, self.clayer, ccp(endPoint.x + bzpos.x, endPoint.y + bzpos.y), nil, 9999, true)
                    end
                end
                local baozaFunc = CCCallFunc:create(baoza)
                baozaArr:addObject(baozaFunc)
            end
            local seq = CCSequence:create(baozaArr)
            tankSp:runAction(seq)
        end
        local fireFunc = CCCallFunc:create(tankFire)
        local mvTo1 = CCMoveTo:create(0.3, ccp(tankx + movePos.x, tanky + movePos.y))
        local easeMvTo1 = CCEaseExponentialOut:create(mvTo1)
        local mvTo2 = CCMoveTo:create(0.2, ccp(tankx, tanky))
        -- local easeMvTo2=CCEaseExponentialOut:create(mvTo2)
        local delayAc = CCDelayTime:create(1)
        moveArr:addObject(dltAc)
        moveArr:addObject(fireFunc)
        moveArr:addObject(easeMvTo1)
        moveArr:addObject(mvTo2)
        moveArr:addObject(delayAc)
        local seq = CCSequence:create(moveArr)
        local repeatForeverAc = CCRepeatForever:create(seq)
        tankSp:runAction(repeatForeverAc)
    end
end

--移除军团城市攻击效果
function worldScene:removeAttackAllianceCityEffect(slotId)
    if self.acityEffectSlot[slotId] == nil then
        do return end
    end
    for k, v in pairs(self.acityEffectSlot[slotId]) do
        local sprite = tolua.cast(v, "CCNode")
        if sprite then
            sprite:removeFromParentAndCleanup(true)
        end
    end
    self.acityEffectSlot[slotId] = nil
end

function worldScene:getSlotPoint(slotVo, isEnemy)
    local startPoint, endPoint
    if isEnemy == true then
        if slotVo.enemyPlace and slotVo.place then
            startPoint = CCPointMake(tonumber(slotVo.enemyPlace[1]), tonumber(slotVo.enemyPlace[2]))
            startPoint = self:toPiexl(ccp(startPoint.x, startPoint.y))
            startPoint = ccp(startPoint.x, self.worldSize.height - startPoint.y)
            -- 被攻击坐标
            endPoint = CCPointMake(tonumber(slotVo.place[1]), tonumber(slotVo.place[2]))
            if slotVo.islandType == 8 then --如果是目标是军团城市的话，调整一下目标点的位置（四个格子中心位置）
                endPoint = ccp(self:toCityPiexl(endPoint.x, endPoint.y))
            else
                endPoint = self:toPiexl(ccp(endPoint.x, endPoint.y))
                endPoint = ccp(endPoint.x, self.worldSize.height - endPoint.y)
            end
        end
    else
        if playerVoApi:getStartPoint() == nil then
            startPoint = CCPointMake(tonumber(playerVoApi:getMapX()), tonumber(playerVoApi:getMapY()))
            startPoint = self:toPiexl(ccp(startPoint.x, startPoint.y))
            startPoint = ccp(startPoint.x, self.worldSize.height - startPoint.y)
            playerVoApi:setStartPoint(startPoint)
        else
            startPoint = playerVoApi:getStartPoint()
        end
        slotVo:setStartPoint(startPoint)
        -- 目标坐标
        if slotVo.endPoint == nil then
            endPoint = CCPointMake(tonumber(slotVo.targetid[1]), tonumber(slotVo.targetid[2]))
            if slotVo.type == 8 or slotVo.type == 9 then --如果是目标是军团城市或欧米伽小队的话，调整一下目标点的位置（四个格子中心位置）
                endPoint = ccp(self:toCityPiexl(endPoint.x, endPoint.y))
            else
                endPoint = self:toPiexl(ccp(endPoint.x, endPoint.y))
                endPoint = ccp(endPoint.x, self.worldSize.height - endPoint.y)
            end
            slotVo:setEndPoint(endPoint)
        else
            endPoint = slotVo:getEndPoint()
        end
    end
    
    return startPoint, endPoint
end

--检测是不是在可视区域内
function worldScene:checkInScreen(baseVo, multiple)
    if baseVo == nil then
        do return false end
    end
    local bx, by = worldBaseVoApi:getAreaXY(baseVo.x, baseVo.y)
    local fourPoints = self:get4Points(multiple or 1)
    local minPoint, maxPoint = fourPoints[1], fourPoints[4]
    if bx >= (minPoint.x * 1000 + minPoint.y) and bx <= (maxPoint.x * 1000 + maxPoint.y) then
        -- print("base in screen!!!")
        return true
    end
    return false
end

-- --基地打飞处理
function worldScene:baseFlyHandler(hitFly)
    local oldx, oldy, x, y = tonumber(hitFly.oldx), tonumber(hitFly.oldy), tonumber(hitFly.x), tonumber(hitFly.y)
    local oldBaseVo = worldBaseVoApi:getBaseVo(oldx, oldy)
    if oldBaseVo then --如果有旧数据，怎清空旧数据
        worldBaseVoApi:checkRemoveBaseVo(oldx, oldy)
        local bx, by = worldBaseVoApi:getAreaXY(oldx, oldy)
        if self.curShowBases[bx] ~= nil then
            baseSp = self.curShowBases[bx][by]
            if baseSp and tolua.cast(baseSp, "CCSprite") then
                baseSp:removeFromParentAndCleanup(true)
                baseSp = nil
                self.curShowBases[bx][by] = nil
            end
        end
    end
    local areaX, areaY = worldBaseVoApi:getAreaXY(x, y)
    local areaTb = worldBaseVoApi:getShowBasesByArea(areaX)
    if areaTb == nil then --说明新坐标所在区域没有拉取过数据，无需处理
    else
        local newBaseVo = worldBaseVoApi:getBaseVo(x, y)
        if newBaseVo == nil or newBaseVo.aid > 0 then --如果没有新数据或者该地块是军团领地的话则重新添加新坐标的数据
            --wbdata:是搬家之前的玩家数据，所以需要更改x，y，id的数据
            local wbdata = hitFly.wbdata
            wbdata.id = worldBaseVoApi:getMidByPos(x, y)
            wbdata.x, wbdata.y = x, y
            worldBaseVoApi:partAddByServerFormat(wbdata)
            newBaseVo = worldBaseVoApi:getBaseVo(x, y)
            local tmpDataTb = {}
            tmpDataTb[areaX] = {[areaY] = newBaseVo}
            self:realShowBase(tmpDataTb)
        end
    end
    --如果是自己的基地被打飞
    if tonumber(oldx) == playerVoApi:getMapX() and tonumber(oldy) == playerVoApi:getMapY() then
        --更改用户基地坐标
        playerVoApi:setBasePos(x, y)
        G_SyncData() --同步一下数据
    end
end

-- 修改世界地图的玩家基地皮肤
function worldScene:changeBaseSkin(...)
    if self.fireBuildParent and tolua.cast(self.fireBuildParent, "LuaCCSprite") then
        local resStr, isSkin = buildDecorateVoApi:getSkinImg()
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(resStr)
        -- 策划需求 放大缩小玩儿家皮肤
        if frame then
            tolua.cast(self.fireBuildParent, "LuaCCSprite"):setDisplayFrame(frame)
            local buildScale = (isSkin == "b11" or isSkin == "b12" or isSkin == "b13") and 0.35 or 0.5
            tolua.cast(self.fireBuildParent, "LuaCCSprite"):setScale(buildScale)
            
            if tolua.cast(self.fireBuildParent:getChildByTag(1016), "CCSprite") then
                tolua.cast(self.fireBuildParent:getChildByTag(1016), "CCSprite"):removeFromParentAndCleanup(true)
            end
            if tolua.cast(self.fireBuildParent:getChildByTag(1017), "CCSprite") then
                tolua.cast(self.fireBuildParent:getChildByTag(1017), "CCSprite"):removeFromParentAndCleanup(true)
            end
            buildDecorateVoApi:playSkinAction(isSkin, self.fireBuildParent)
            local protectedSp = self.fireBuildParent:getChildByTag(102)
            if protectedSp and tolua.cast(protectedSp, "CCSprite") then
                protectedSp:setPosition(ccp(self.fireBuildParent:getContentSize().width / 2 + 10, self.fireBuildParent:getContentSize().height / 2))
            end
            local userNameSp = self.fireBuildParent:getChildByTag(100)
            local nameSpScale, allianceSpScale = 1, 0.2
            if isSkin == "b11" or isSkin == "b12" or isSkin == "b13"then
                nameSpScale = 0.5 / 0.35
                allianceSpScale = 0.1 / 0.35
            end
            userNameSp:setScale(nameSpScale)
            if userNameSp and tolua.cast(userNameSp, "LuaCCScale9Sprite") then
                userNameSp:setPosition(ccp(self.fireBuildParent:getContentSize().width / 2, 40))
                local allianceSp = tolua.cast(self.fireBuildParent:getChildByTag(103), "CCSprite") --军团旗帜
                if allianceSp then
                    allianceSp:setPosition(ccp(userNameSp:getPositionX() - userNameSp:getContentSize().width / 2 * nameSpScale - 20, userNameSp:getPositionY()))
                    allianceSp:setScale(allianceSpScale)
                end
            end
        end
    end
end

--获取两个地块的距离
function worldScene:getDistanceByPos(sp, ep)
    local startPoint = self:toPiexl(ccp(sp.x, sp.y))
    startPoint = ccp(startPoint.x, self.worldSize.height - startPoint.y)
    local endPoint = self:toPiexl(ccp(ep.x, ep.y))
    endPoint = ccp(endPoint.x, self.worldSize.height - endPoint.y)
    return self:getDistance(startPoint, endPoint)
end

--创建欧米伽小队
--欧米伽小队显示随机出来的坦克皮肤
function worldScene:createOmegaTroops(skinId, x, y, baseClick)
    local baseSp = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", baseClick)
    baseSp:setContentSize(CCSizeMake(320, 200))
    baseSp:setOpacity(0)
    baseSp:setPosition(x, y)
    for k = 1, 3 do
        local tankSp = CCSprite:createWithSpriteFrameName(tankSkinVoApi:getTankSkinIconPic(skinId))--G_getTankPic(tankId)
        if k == 1 then
            tankSp:setPosition(baseSp:getContentSize().width / 2 - 50, baseSp:getContentSize().height / 2 + 30)
        elseif k == 2 then
            tankSp:setPosition(baseSp:getContentSize().width / 2 - 10, baseSp:getContentSize().height / 2 - 40)
        else
            tankSp:setPosition(baseSp:getContentSize().width / 2 + 60, baseSp:getContentSize().height / 2 + 30)
        end
        tankSp:setScale(100 / tankSp:getContentSize().width)
        baseSp:addChild(tankSp)
    end
    return baseSp
end
