--军团战对阵列表
championshipAllianceWarDialog = commonDialog:new()

function championshipAllianceWarDialog:new()
    local nc = {}
    
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function championshipAllianceWarDialog:doUserHandler()
    local selfAlliance = allianceVoApi:getSelfAlliance()
    self.myAid = base.curZoneID
    if selfAlliance and selfAlliance.aid then
        self.myAid = self.myAid.."-"..selfAlliance.aid
    end
    self:getSelfGroupId()
    self.iphoneType = G_getIphoneType()
    self.warState = championshipWarVoApi:getWarState() --军团战状态
    self.lastWarState = self.warState
    self.pullFlag = false --是否拉取过数据的标识
end

function championshipAllianceWarDialog:getSelfGroupId()
    self.battleInfo = championshipWarVoApi:getAllianceWarBattleInfo()
    if self.battleInfo.info and self.battleInfo.info[1] then
        local num = SizeOfTable(self.battleInfo.info[1])
        for k, v in pairs(self.battleInfo.info[1]) do
            for gk, graid in pairs(v) do
                if tostring(graid) ~= "0" then
                    local aidArr = Split(graid, "-")
                    local aid = aidArr[1] .. "-"..aidArr[2]
                    if aid == self.myAid then
                        if k >= (num / 2 + 1) then --自己军团数据在下半组
                            return 2
                        else
                            return 1
                        end
                    end
                end
            end
        end
    end
    return 1
end

function championshipAllianceWarDialog:initTableView()
    spriteController:addPlist("public/championshipWar/championshipImage.plist")
    spriteController:addTexture("public/championshipWar/championshipImage.png")
    spriteController:addPlist("public/acZnqd2017.plist")
    spriteController:addTexture("public/acZnqd2017.png")
    spriteController:addPlist("public/newButton180711.plist")
    spriteController:addTexture("public/newButton180711.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acItemBg.plist")
    local function addPlist()
        spriteController:addPlist("public/championshipWar/championshipImage2.plist")
        spriteController:addTexture("public/championshipWar/championshipImage2.png")
    end
    G_addResource8888(addPlist)
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    
    local allianceBg = CCSprite:createWithSpriteFrameName("csi_alliancewarBg.jpg")
    allianceBg:setAnchorPoint(ccp(0.5, 1))
    allianceBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 82)
    allianceBg:setScale((G_VisibleSizeHeight - 87) / allianceBg:getContentSize().height)
    self.bgLayer:addChild(allianceBg)
    
    local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBgBottom.png", CCRect(34, 32, 2, 6), function ()end)
    bottomBg:setAnchorPoint(ccp(0.5, 0))
    bottomBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, bottomBg:getContentSize().height))
    bottomBg:setPosition(G_VisibleSizeWidth / 2, 0)
    self.bgLayer:addChild(bottomBg, 3)
    
    local tipLb = GetTTFLabelWrap(getlocal("championshipWar_report_overview_tip"), 22, CCSizeMake(250, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    tipLb:setAnchorPoint(ccp(0, 0.5))
    tipLb:setColor(G_ColorRed)
    tipLb:setPosition(10, (G_VisibleSizeHeight - 82) / 2)
    self.bgLayer:addChild(tipLb)
    
    --本场军团排名
    local rankBtn
    local scale, priority = 1, -(self.layerNum - 1) * 20 - 4
    local function rankHandler()
        local function realHandler()
            local state = championshipWarVoApi:getWarState()
            if state < 30 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_check_alliancewar_rankTip"), 28)
                do return end
            elseif state == 40 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage31001"), 28)
                do return end
            end
            championshipWarVoApi:showAllianceWarRankDialog(self.layerNum + 1)
        end
        G_touchedItem(rankBtn, realHandler, 0.8 * scale)
    end
    rankBtn = G_createBotton(self.bgLayer, ccp(G_VisibleSizeWidth - 60, tipLb:getPositionY()), {}, "acZnqd2017Func51.png", "acZnqd2017Func50.png", "acZnqd2017Func50.png", rankHandler, scale, priority)
    
    if self.warState < 30 then
        local clipLayer = CCClippingNode:create() --裁切层
        clipLayer:setContentSize(CCSizeMake(G_VisibleSize.width, G_VisibleSize.height))
        clipLayer:setAnchorPoint(ccp(0.5, 0.5))
        clipLayer:setPosition(G_VisibleSize.width / 2, G_VisibleSize.height / 2)
        self.clipLayer = clipLayer
        stencilLayer = CCNode:create()
        stencilLayer:setContentSize(CCSizeMake(G_VisibleSize.width, G_VisibleSize.height))
        stencilLayer:setAnchorPoint(ccp(0.5, 0.5))
        stencilLayer:setPosition(getCenterPoint(clipLayer))
        clipLayer:setStencil(stencilLayer)
        self.bgLayer:addChild(clipLayer, 2)
        self.stencilLayer = stencilLayer
    end
    
    self.borderSpTb = {}
    self.scoreLbTb = {}
    self:arrangeBattleListView(true)
end

--对阵列表详情
function championshipAllianceWarDialog:arrangeBattleListView(initFlag)
    local groupId = self:getSelfGroupId()
    local fontSize = 20
    local warState = self.lastWarState --因到结算点拉取数据有可能还是没有结算数据，这个时候状态不能变化，则取历史状态
    local stateTb = {0, 21, 22, 23, 24} --每一层对应的进阶状态列表
    local roundTb = {4, 3, 2, 1} --轮数配置，跟后端交互使用
    local warCfg = championshipWarVoApi:getWarCfg()
    local winScore = warCfg.allianceJoinNum * warCfg.winScore --判断输赢的分数
    local group = {4, 2, 1, 1}
    local rowBorderWidthTb = {112, 150, 192, 192}
    local rowSpaceTb, rowSpaceY = {160, 160, 320, 0}, 60
    local addSpaceY = 0
    local firstPosX = {5, 5, 64, 224}
    local firstPosY = {G_VisibleSizeHeight - 90, 40}
    if self.iphoneType == G_iphone5 then
        addSpaceY = 10
        firstPosY = {G_VisibleSizeHeight - 120, 80}
    elseif self.iphoneType == G_iphoneX then
        addSpaceY = 20
        firstPosY = {G_VisibleSizeHeight - 120, 80}
    end
    local characterTb = {8, 10, 12, 12}
    local borderHeight = 42
    local infoTb = self.battleInfo.info or {} --对阵列表信息
    local allianceTb = self.battleInfo.ainfo or {} --参战军团的信息（目前只有军团名称）
    for k = 1, 2 do
        local borderIdx = (k - 1) * 15
        for row = 1, 4 do
            for i = 1, group[row] do
                local infoIdx = math.abs(groupId - k) * group[row] + i
                if row == 4 then
                    infoIdx = 1 --最后一轮pk只有一组
                end
                local groupTb = infoTb[row] or {}
                local againstTb = groupTb[infoIdx] or {0, 0} --对战双方军团信息
                local posY = 0
                if row ~= 1 then
                    posY = firstPosY[k] + (-1) ^ k * (2 * borderHeight + 10 + (row - 1) * (rowSpaceY + addSpaceY) + (2 * (row - 1) - 1) * borderHeight * 0.5)
                end
                local jc = (row == 4) and 1 or 2
                for j = 1, jc do
                    local binfo = {}
                    if row == 4 then
                        if groupId == 2 and k == 2 then
                            binfo = Split(tostring(againstTb[1]), "-")
                        else
                            binfo = Split(tostring(againstTb[groupId * k]), "-")
                        end
                    else
                        binfo = Split(tostring(againstTb[j]), "-")
                    end
                    local borderPic = "csi_borderBg.png"
                    if (SizeOfTable(binfo) == 0) or ((tonumber(binfo[3]) or 0) < winScore) or (warState <= stateTb[row]) then --该位置没有军团，或者有军团但该军团对抗失败，或者该阶段还未结算则边框置灰显示
                        borderPic = "csi_borderGrayBg.png"
                    end
                    
                    borderIdx = borderIdx + 1
                    if self.borderSpTb[borderIdx] and tolua.cast(self.borderSpTb[borderIdx], "CCSprite") then
                        local borderSp = tolua.cast(self.borderSpTb[borderIdx], "CCSprite")
                        borderSp:removeFromParentAndCleanup(true)
                        self.borderSpTb[borderIdx] = nil
                    end
                    local function touch()
                        if G_checkClickEnable() == false then
                            do
                                return
                            end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        if self.warState == 40 then --休赛期直接返回
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage31001"), 28)
                            do return end
                        end
                        if binfo[1] == nil or binfo[2] == nil then --轮空
                            do return end
                        end
                        if (warState == stateTb[row + 1]) or warState <= stateTb[row] then --正在结算中
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_round_settlementing"), 28)
                            do return end
                        end
                        local agbinfo = {} --对立方数据
                        if row ~= 4 then
                            agbinfo = Split(tostring(againstTb[3 - j] or 0), "-")
                        else
                            agbinfo = Split(tostring(againstTb[3 - k] or 0), "-")
                        end
                        if agbinfo[1] == nil or agbinfo[2] == nil then --对立方轮空，则直接提示进入下一轮次
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_round_nullaid"), 28)
                            do return end
                        end
                        local rid = self.battleInfo.id
                        local round = roundTb[row]
                        local zaid1, zaid2
                        local ainfo1 = Split(tostring(againstTb[1]), "-")
                        local ainfo2 = Split(tostring(againstTb[2]), "-")
                        if ainfo1[1] == nil or ainfo1[2] == nil or ainfo2[1] == nil or ainfo2[2] == nil then --军团数据异常了
                            do return end
                        end
                        zaid1 = ainfo1[1] .. "-" .. ainfo1[2]
                        zaid2 = ainfo2[1] .. "-" .. ainfo2[2]
                        --回放对阵双方对阵过程
                        local function reviewReport(report)
                            championshipWarVoApi:showReplayDialog(rid, round, report, self.layerNum + 1)
                        end
                        championshipWarVoApi:getReport(2, rid, round, zaid1, zaid2, reviewReport)
                    end
                    local borderSp = LuaCCScale9Sprite:createWithSpriteFrameName(borderPic, CCRect(16, 20, 2, 2), touch)
                    borderSp:setContentSize(CCSizeMake(rowBorderWidthTb[row], borderHeight))
                    borderSp:setAnchorPoint(ccp(0, 0.5))
                    borderSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
                    self.bgLayer:addChild(borderSp)
                    self.borderSpTb[borderIdx] = borderSp
                    if row == 1 then
                        borderSp:setPosition(firstPosX[row] + (i - 1) * rowSpaceTb[row], firstPosY[k] + (-1) ^ k * ((2 * j - 1) * borderHeight * 0.5 + (j - 1) * 10))
                        if k == 1 then
                            borderSp:setPositionY(borderSp:getPositionY() - 12)
                        end
                    else
                        borderSp:setPosition(firstPosX[row] + (2 * (i - 1) + j - 1) * rowSpaceTb[row], posY)
                    end
                    
                    if row > 1 and warState == stateTb[row] then --结算中显示特殊流光效果
                        self:playSettlementAni(borderSp, borderIdx)
                    elseif self.stencilSpTb and self.stencilSpTb[borderIdx] then --移除以前的流光效果
                        for k, v in pairs(self.stencilSpTb[borderIdx]) do
                            local sp
                            if k == 1 or k == 2 then
                                sp = tolua.cast(v, "LuaCCScale9Sprite")
                            else
                                sp = tolua.cast(v, "CCSprite")
                            end
                            if sp then
                                sp:removeFromParentAndCleanup(true)
                                sp = nil
                            end
                        end
                        self.stencilSpTb[borderIdx] = nil
                    end
                    
                    local nameStr = ""
                    if warState == stateTb[row] then --该阶层正在结算中
                        nameStr = getlocal("championshipWar_settlementing")
                    elseif warState < stateTb[row] then --还未结算到该阶层，待定中
                        nameStr = getlocal("championshipWar_hold")
                    elseif binfo[1] and binfo[2] then
                        local aid = binfo[1] .. "-" .. binfo[2]
                        local score = binfo[3] or 0
                        nameStr = (allianceTb[aid] and allianceTb[aid][1]) and allianceTb[aid][1] or ""
                        nameStr = G_getShortStr(nameStr, characterTb[row]) --军团名称简写
                        if warState > stateTb[row + 1] then --该阶层已经结算显示对阵双方的分数
                            --分数显示
                            local scoreLb
                            if self.scoreLbTb[borderIdx] and tolua.cast(self.scoreLbTb[borderIdx], "CCLabelTTF") then
                                scoreLb = tolua.cast(self.scoreLbTb[borderIdx], "CCLabelTTF")
                                scoreLb:setString(score)
                            else
                                scoreLb = GetTTFLabel(score, fontSize)
                                local swidth, sheight = scoreLb:getContentSize().width, scoreLb:getContentSize().height
                                self.bgLayer:addChild(scoreLb)
                                local scorePosX, scorePosY = 0, 0
                                if row == 1 then
                                    local addH = (k == 2) and 10 or 8
                                    scorePosX = borderSp:getPositionX() + rowBorderWidthTb[row] + 9
                                    scorePosY = borderSp:getPositionY() + sheight * 0.5 + addH
                                elseif row == 4 then
                                    scorePosX = borderSp:getPositionX() - 28
                                    scorePosY = borderSp:getPositionY() + (-1) ^ (k - 1) * (5 + sheight * 0.5)
                                else
                                    scorePosX = borderSp:getPositionX() + rowBorderWidthTb[row] * 0.5 + (-1) ^ j * (10 + swidth * 0.5)
                                    scorePosY = borderSp:getPositionY() + (-1) ^ k * (borderHeight * 0.5 + 25 + addSpaceY * 0.5)
                                end
                                scoreLb:setPosition(scorePosX, scorePosY)
                                self.scoreLbTb[borderIdx] = scoreLb
                            end
                        end
                        if row == 4 then --判断显示冠军
                            if warState >= 24 then --本场已经结算完，显示冠军
                                if infoTb[5] and infoTb[5][1] then
                                    local firstInfo = infoTb[5][1][1]
                                    if firstInfo then
                                        firstInfoTb = Split(tostring(firstInfo), "-")
                                        local firstAid = firstInfoTb[1] .. "-"..firstInfoTb[2]
                                        if firstAid == aid then --此军团是冠军
                                            local tag = 99999
                                            local firstSp = tolua.cast(self.bgLayer:getChildByTag(tag), "CCSprite")
                                            if firstSp == nil then
                                                firstSp = CCSprite:createWithSpriteFrameName("csi_champion.png")
                                                firstSp:setAnchorPoint(ccp(0, 0.5))
                                                firstSp:setTag(tag)
                                                firstSp:setPosition(borderSp:getPositionX() + rowBorderWidthTb[row] + 20, posY)
                                                self.bgLayer:addChild(firstSp)
                                                --播放随机星星的效果
                                                self:playChampionAni(firstSp)
                                            end
                                            
                                        end
                                    end
                                end
                            end
                        end
                        if self.myAid == aid then --我方军团
                            local tipSp = CCSprite:createWithSpriteFrameName("csi_hexagonBg.png")
                            tipSp:setScale(0.3)
                            tipSp:setPosition(borderSp:getContentSize().width - tipSp:getContentSize().width * tipSp:getScale() / 2 - 5, borderSp:getContentSize().height - 10)
                            borderSp:addChild(tipSp, 2)
                        end
                    else --该位置没有军团，轮空
                        nameStr = getlocal("championshipWar_nullaid")
                    end
                    local nameLb = GetTTFLabelWrap(nameStr, fontSize, CCSizeMake(rowBorderWidthTb[row], 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                    nameLb:setAnchorPoint(ccp(0, 0.5))
                    nameLb:setPosition(10, borderHeight * 0.5)
                    borderSp:addChild(nameLb)
                end
                --画连接线
                local linePic = "csi_battleline"..row..".png"
                local flipX = false
                if row ~= 4 then
                    local binfo1 = Split(tostring(againstTb[1]), "-")
                    local binfo2 = Split(tostring(againstTb[2]), "-")
                    if warState > stateTb[row] then --该阶段已经结算，连线会根据每组对战军团输赢发生变化
                        if binfo1[1] and binfo1[2] and tonumber(binfo1[3] or 0) >= winScore then --每组的第一个军团赢了
                            if row == 1 then
                                linePic = "csi_battleline"..row.."_1" .. ".png"
                            else
                                linePic = "csi_battleline"..row.."_1" .. ".png"
                            end
                        end
                        if binfo2[1] and binfo2[2] and tonumber(binfo2[3] or 0) >= winScore then --每组的第二个军团赢了
                            if row == 1 then
                                linePic = "csi_battleline"..row.."_2" .. ".png"
                            else
                                linePic = "csi_battleline"..row.."_1" .. ".png"
                                flipX = true
                            end
                        end
                    end
                end
                local lineTag = k * 1000 + row * 100 + i
                if initFlag == true then
                    if row == 4 then
                        local lineHeight = 0
                        if k == 2 then
                            local borderSp1, borderSp2 = self.borderSpTb[(k - 1) * 15], self.borderSpTb[k * 15]
                            lineHeight = math.abs(borderSp1:getPositionY() - borderSp2:getPositionY())
                            local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName(linePic, CCRect(1, 8, 1, 2), function ()end)
                            lineSp:setContentSize(CCSizeMake(34, lineHeight + 7))
                            lineSp:setAnchorPoint(ccp(1, 0.5))
                            lineSp:setTag(lineTag)
                            lineSp:setPosition(borderSp2:getPositionX() - 10, borderSp2:getPositionY() + lineHeight * 0.5)
                            self.bgLayer:addChild(lineSp)
                        end
                    else
                        local lineSp = CCSprite:createWithSpriteFrameName(linePic)
                        lineSp:setFlipX(flipX)
                        lineSp:setTag(lineTag)
                        if k == 2 then
                            lineSp:setFlipY(true)
                        end
                        if row == 1 then
                            lineSp:setAnchorPoint(ccp(1, 0.5))
                            lineSp:setPosition(firstPosX[row] + i * rowSpaceTb[row] - 15, firstPosY[k] + (-1) ^ k * 85)
                        else
                            lineSp:setPosition(firstPosX[row] + (2 * i - 1) * rowSpaceTb[row] - (rowSpaceTb[row] - rowBorderWidthTb[row]) / 2, posY + (-1) ^ k * (borderHeight * 0.5 + (rowSpaceY + addSpaceY) * 0.5))
                        end
                        self.bgLayer:addChild(lineSp)
                    end
                else
                    if row ~= 4 then
                        local lineSp = tolua.cast(self.bgLayer:getChildByTag(lineTag), "CCSprite")
                        if lineSp then --刷新连线状态
                            lineSp:setFlipX(flipX)
                            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(linePic)
                            lineSp:setDisplayFrame(frame)
                        end
                    end
                end
            end
        end
    end
end

--结算中的特殊效果显示
function championshipAllianceWarDialog:playSettlementAni(itemSp, index)
    if itemSp == nil or self.stencilLayer == nil or self.clipLayer == nil then
        do return end
    end
    if self.stencilSpTb == nil then
        self.stencilSpTb = {}
    end
    if self.stencilSpTb[index] then
        do return end
    end
    local opacity, lightWidth, lightHeight = 50, 50, 6
    local itemSize = itemSp:getContentSize()
    local upStencilSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function () end)
    upStencilSp:setPosition(itemSp:getPositionX(), itemSp:getPositionY() + itemSize.height / 2)
    upStencilSp:setAnchorPoint(ccp(0, 1))
    upStencilSp:setContentSize(CCSizeMake(itemSize.width - 20, lightHeight))
    self.stencilLayer:addChild(upStencilSp)
    
    local downStencilSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function () end)
    downStencilSp:setPosition(itemSp:getPositionX() + 8, itemSp:getPositionY() - itemSize.height / 2)
    downStencilSp:setAnchorPoint(ccp(0, 0))
    downStencilSp:setContentSize(CCSizeMake(itemSize.width - 8, lightHeight))
    self.stencilLayer:addChild(downStencilSp)
    
    self.stencilSpTb[index] = {upStencilSp, downStencilSp}
    
    local anchor = {ccp(1, 1), ccp(1, 0)}
    local stencil = {upStencilSp, downStencilSp}
    for k = 1, 2 do
        local lightSp = CCSprite:createWithSpriteFrameName("acItemlight.png")
        local stencilSp = stencil[k]
        local beginPos = ccp(itemSp:getPositionX(), stencilSp:getPositionY())
        local targetPos = ccp(itemSp:getPositionX() + itemSp:getContentSize().width + lightWidth, beginPos.y)
        lightSp:setAnchorPoint(anchor[k])
        lightSp:setOpacity(opacity)
        lightSp:setScaleX(lightWidth / lightSp:getContentSize().width)
        lightSp:setScaleY(lightHeight / lightSp:getContentSize().height)
        self.clipLayer:addChild(lightSp, 2)
        lightSp:setPosition(beginPos)
        
        local mt = (targetPos.x - beginPos.x) / 250
        local moveTo = CCMoveTo:create(mt, targetPos)
        local fadeTo1 = CCFadeTo:create(mt / 2, 255)
        local fadeTo2 = CCFadeTo:create(mt / 2, opacity)
        local fadeSeq = CCSequence:createWithTwoActions(fadeTo1, fadeTo2)
        local spawnArr = CCArray:create()
        spawnArr:addObject(moveTo)
        spawnArr:addObject(fadeSeq)
        local spawnAc = CCSpawn:create(spawnArr)
        local function moveEnd()
            lightSp:setPosition(beginPos)
            lightSp:setOpacity(opacity)
        end
        local acArr = CCArray:create()
        acArr:addObject(spawnAc)
        acArr:addObject(CCCallFunc:create(moveEnd))
        local delay = CCDelayTime:create(0.5)
        acArr:addObject(delay)
        local seq = CCSequence:create(acArr)
        lightSp:runAction(CCRepeatForever:create(seq))
        table.insert(self.stencilSpTb[index], lightSp)
    end
end

function championshipAllianceWarDialog:playChampionAni(championSp)
    if championSp == nil then
        do return end
    end
    local xingRandomCfg = {{ccp(1, 30), 0.4}, {ccp(46, 35), 0.4}, {ccp(24, 43), 0.3}}
    local timeTb = {0.3, 1.5, 2.6}
    local cfg = G_clone(xingRandomCfg)
    local function playOne(index)
        local idx = math.random(1, SizeOfTable(cfg))
        local pos, scale = cfg[idx][1], cfg[idx][2]
        local dt = timeTb[index]
        table.remove(cfg, idx)
        local xingSp = CCSprite:createWithSpriteFrameName("whiteStar.png")
        xingSp:setPosition(pos)
        xingSp:setScale(0)
        local blendFunc = ccBlendFunc:new()
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE_MINUS_SRC_COLOR
        xingSp:setBlendFunc(blendFunc)
        championSp:addChild(xingSp)
        
        local acArr = CCArray:create()
        local delayAc = CCDelayTime:create(dt)
        acArr:addObject(delayAc)
        
        local spawnArr1 = CCArray:create()
        local rotateAC1 = CCRotateBy:create(0.5, 30)
        local scaleTo1 = CCScaleTo:create(0.5, scale)
        spawnArr1:addObject(rotateAC1)
        spawnArr1:addObject(scaleTo1)
        local spawnAc1 = CCSpawn:create(spawnArr1)
        acArr:addObject(spawnAc1)
        
        local spawnArr2 = CCArray:create()
        local rotateAC2 = CCRotateBy:create(0.5, 30)
        local scaleTo2 = CCScaleTo:create(0.5, 0)
        spawnArr2:addObject(rotateAC2)
        spawnArr2:addObject(scaleTo2)
        local spawnAc2 = CCSpawn:create(spawnArr2)
        acArr:addObject(spawnAc2)
        
        local function removeSp()
            if index < 3 then
                playOne(index + 1)
            else
                cfg = G_clone(xingRandomCfg)
                playOne(1)
            end
            xingSp:removeFromParentAndCleanup(true)
        end
        local callFunc = CCCallFuncN:create(removeSp)
        acArr:addObject(callFunc)
        local seq = CCSequence:create(acArr)
        xingSp:runAction(seq)
    end
    playOne(1)
end

function championshipAllianceWarDialog:tick()
    local state = championshipWarVoApi:getWarState()
    if state == 40 or state <= 10 then --休息期
        do return end
    end
    self.warState = state
    local flag = championshipWarVoApi:checkIfSettledByWarState(state)
    if flag == true then --该轮次有数据，怎无需重新拉取数据
        do return end
    end
    if (self.lastWarState ~= state and self.pullFlag == false) or (self.refreshTs and self.refreshTs >= base.serverTime and self.pullFlag == true) then --军团战状态发生变化或者延迟后需要重新拉取对阵信息
        local function refresh()
            self.pullFlag = true
            local flag = championshipWarVoApi:checkIfSettledByWarState(state)
            if flag ~= true then --如果拉取完数据，本轮次还是没有数据的话，则延迟5分钟后再拉取一次
                self.refreshTs = base.serverTime + 5 * 60
            else
                self.lastWarState = state
                self.pullFlag = false
                self:arrangeBattleListView() --重新刷新对阵信息
            end
        end
        championshipWarVoApi:championshipWarScheduleGet(refresh, false)
    end
end

function championshipAllianceWarDialog:dispose()
    spriteController:removePlist("public/championshipWar/championshipImage.plist")
    spriteController:removeTexture("public/championshipWar/championshipImage.png")
    spriteController:removePlist("public/championshipWar/championshipImage2.plist")
    spriteController:removeTexture("public/championshipWar/championshipImage2.png")
    spriteController:removePlist("public/acZnqd2017.plist")
    spriteController:removeTexture("public/acZnqd2017.png")
    spriteController:removePlist("public/newButton180711.plist")
    spriteController:removeTexture("public/newButton180711.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acItemBg.plist")
    self.lastWarState = nil
    self.pullFlag = nil
    self.borderSpTb = nil
    self.scoreLbTb = nil
    self.stencilSpTb = nil
    self.refreshTs = nil
    self.warState = nil
    self.myAid = nil
    self.battleInfo = nil
    self.iphoneType = nil
    self.stencilLayer = nil
    self.clipLayer = nil
end
