championshipWarPersonalDialog = commonDialog:new()

function championshipWarPersonalDialog:new(layerNum)
    local nc = {
        layerNum = layerNum
    }
    setmetatable(nc, self)
    self.__index = self
    
    local function addPlist()
        spriteController:addPlist("public/youhuaUI3.plist")
        spriteController:addTexture("public/youhuaUI3.png")
        spriteController:addPlist("public/youhuaUI4.plist")
        spriteController:addTexture("public/youhuaUI4.png")
    end
    G_addResource8888(addPlist)
    spriteController:addPlist("public/reportyouhua.plist")
    spriteController:addTexture("public/reportyouhua.png")
    
    return nc
end

function championshipWarPersonalDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    
    self:refreshUI()
    
    self.eventListener = function(evetn, data)
        if data and data.refreshType == 1 then
            self:refreshBestNum()
        else
            self:refreshUI()
        end
    end
    eventDispatcher:addEventListener("championshipWarPersonalDialog.refreshUI", self.eventListener)
end

function championshipWarPersonalDialog:refreshUI()
    local showType = 1
    if championshipWarVoApi:isEndBattle() == true then
        showType = 3
    elseif championshipWarVoApi:isSelectBuff() == true then
        showType = 2
    end
    self:initTop(showType)
    self:initScore(showType)
    self:initCenter(showType)
    self:initBottom(showType)
end

function championshipWarPersonalDialog:initTop(showType)
    if self.timeBg and tolua.cast(self.timeBg, "CCSprite") then
        self.timeBg:removeFromParentAndCleanup(true)
        self.timeLb = nil
        self.timeBg = nil
    end
    if self.titleBg and tolua.cast(self.titleBg, "CCSprite") then
        self.titleBg:removeFromParentAndCleanup(true)
        self.titleBg = nil
    end
    
    if showType == 1 or showType == 3 then
        self.timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png", CCRect(103, 0, 2, 80), function()end)
        self.timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, self.timeBg:getContentSize().height))
        self.timeBg:setAnchorPoint(ccp(0.5, 1))
        self.timeBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 86)
        self.bgLayer:addChild(self.timeBg)
        local state, time = championshipWarVoApi:getWarState()
        local tiemStr = ""
        if state == 10 then
            tiemStr = getlocal("championshipWar_personal_endTime") .. G_formatActiveDate(time)
        else
            tiemStr = getlocal("championshipWar_personal_endTips")
        end
        self.timeLb = GetTTFLabel(tiemStr, 24)
        self.timeLb:setAnchorPoint(ccp(0.5, 1))
        self.timeLb:setPosition(self.timeBg:getContentSize().width / 2, self.timeBg:getContentSize().height - 8)
        self.timeBg:addChild(self.timeLb)
        local function onTouchInfo()
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local warCfg = championshipWarVoApi:getWarCfg()
            local args = {
                [6] = {warCfg.extraStageReward},
            }
            local textFormatTb = {
                [6] = {richFlag = true, richColor = {nil, G_ColorYellowPro, nil}},
            }
            local tabStr = {}
            for k = 1, 11 do
                local str = getlocal("championshipWar_personal_tip"..k, args[k])
                table.insert(tabStr, str)
            end
            local titleStr = getlocal("activity_baseLeveling_ruleTitle")
            require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
            tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25, textFormatTb)
        end
        local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", onTouchInfo)
        local infoMenu = CCMenu:createWithItem(infoBtn)
        infoMenu:setPosition(ccp(self.timeBg:getContentSize().width - 8 - infoBtn:getContentSize().width / 2, self.timeBg:getContentSize().height / 2))
        infoMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        self.timeBg:addChild(infoMenu)
    elseif showType == 2 then
        self.titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
        self.titleBg:setAnchorPoint(ccp(0.5, 1))
        self.titleBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 106)
        self.bgLayer:addChild(self.titleBg)
        local titleLb = GetTTFLabel(getlocal("championshipWar_selectProperty"), 24, true)
        titleLb:setPosition(self.titleBg:getContentSize().width / 2, self.titleBg:getContentSize().height / 2)
        titleLb:setColor(G_ColorYellowPro)
        self.titleBg:addChild(titleLb)
    end
end

function championshipWarPersonalDialog:refreshBestNum()
    local scoreNum = championshipWarVoApi:getBestScore()
    if scoreNum > self.prevBestScore then
        if self.scoreBg and tolua.cast(self.scoreBg, "CCSprite") then
            local scoreBg = tolua.cast(self.scoreBg, "CCSprite")
            local bestBg = scoreBg:getChildByTag(10)
            local bestNum = bestBg:getChildByTag(10)
            bestNum = tolua.cast(bestNum, "CCLabelTTF")
            local bestNumStrokeLb = tolua.cast(bestNum:getChildByTag(10), "CCLabelTTF")
            self.prevBestScore = scoreNum
            for i=1,2 do
                local particleSystem = CCParticleSystemQuad:create("public/textShine" ..  i .. ".plist")
                particleSystem:setScale(1)
                particleSystem:setPosition(ccp(bestBg:getContentSize().width / 2, 0))
                particleSystem:setAutoRemoveOnFinish(true)
                bestBg:addChild(particleSystem, 10)
            end
            local arr = CCArray:create()
            arr:addObject(CCDelayTime:create(0.3))
            arr:addObject(CCCallFunc:create(function()
                bestNum:setString(tostring(self.prevBestScore))
                bestNumStrokeLb:setString(bestNum:getString())
                bestNumStrokeLb:setPosition(bestNum:getContentSize().width / 2 + 2, bestNum:getContentSize().height / 2 - 2)
                bestNum:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.3, 1.2),CCScaleTo:create(0.3, 1)))
            end))
            bestBg:runAction(CCSequence:create(arr))
        end
    end
end

function championshipWarPersonalDialog:initScore(showType)
    if self.scoreBg and tolua.cast(self.scoreBg, "CCSprite") then
        self.scoreBg:removeFromParentAndCleanup(true)
        self.scoreBg = nil
    end
    
    if showType == 1 or showType == 2 then
        local scoreBgHeight = 120
        local scoreBgPosY = 0
        if showType == 1 then
            local space = 10
            if G_getIphoneType() == G_iphone5 or G_getIphoneType() == G_iphoneX then
                scoreBgHeight = 180
                space = 15
            end
            scoreBgPosY = self.timeBg:getPositionY() - self.timeBg:getContentSize().height - space
        elseif showType == 2 then
            scoreBgHeight = 160
            if G_getIphoneType() == G_iphoneX then
                scoreBgHeight = 180
            end
            scoreBgPosY = self.titleBg:getPositionY() - self.titleBg:getContentSize().height - 20
        end
        self.scoreBg = LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png", CCRect(15, 15, 2, 2), function()end)
        self.scoreBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, scoreBgHeight))
        self.scoreBg:setAnchorPoint(ccp(0.5, 1))
        self.scoreBg:setPosition(G_VisibleSizeWidth / 2, scoreBgPosY)
        self.bgLayer:addChild(self.scoreBg)
        local scoreItemSpace = 20 --横向间距
        local bestBg = CCSprite:createWithSpriteFrameName("csi_bestBg.png")
        bestBg:setPosition(scoreItemSpace + bestBg:getContentSize().width / 2, self.scoreBg:getContentSize().height / 2)
        bestBg:setTag(10)
        self.scoreBg:addChild(bestBg)
        local bestLb = GetTTFLabel(getlocal("championshipWar_personal_best"), 18, true)
        bestLb:setPosition(bestBg:getContentSize().width / 2, 22)
        bestBg:addChild(bestLb)
        if self.prevBestScore == nil then
            self.prevBestScore = championshipWarVoApi:getBestScore()
        end
        local bestNum = GetTTFLabel(tostring(self.prevBestScore), 46)
        bestNum:setPosition(bestBg:getContentSize().width / 2, bestBg:getContentSize().height / 2)
        bestNum:setTag(10)
        bestBg:addChild(bestNum, 2)

        --添加描边效果
        local bestNumStrokeLb = GetTTFLabel(bestNum:getString(), bestNum:getFontSize(), bestNum:getFontName())
        bestNumStrokeLb:setPosition(bestNum:getContentSize().width / 2 + 2, bestNum:getContentSize().height / 2 - 2)
        bestNumStrokeLb:setColor(ccc3(0,0,0))
        bestNumStrokeLb:setTag(10)
        bestNum:addChild(bestNumStrokeLb, -1)
        -- local textLbTb = G_addStroke(bestBg, bestNum, bestScoreStr, 46, false, 1, 2) --加投影
        -- if textLbTb then
        --     for k,v in pairs(textLbTb) do
        --         if k==2 or k==3 then
        --             v:setOpacity(0.5*255)
        --         else
        --             v:setVisible(false)
        --         end
        --     end
        -- end
        
        local function onRewardBtn()
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            -- print("cjl --------->>>  奖励")
            championshipWarVoApi:showFiveStageRewardDialog(false, self.layerNum + 1)
        end
        local rewardBtn = GetButtonItem("friendBtn.png", "friendBtnDOwn.png", "friendBtn.png", onRewardBtn)
        rewardBtn:setAnchorPoint(ccp(0.5, 0.5))
        local rewardMenu = CCMenu:createWithItem(rewardBtn)
        rewardMenu:setPosition(ccp(self.scoreBg:getContentSize().width - scoreItemSpace - rewardBtn:getContentSize().width / 2, self.scoreBg:getContentSize().height / 2))
        rewardMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        self.scoreBg:addChild(rewardMenu)
        local cfg = championshipWarVoApi:getWarCfg()
        local surplusNum = cfg.buffStageNum - ((championshipWarVoApi:getCurrentCheckpointId() - 1) % cfg.buffStageNum)
        local lbW = self.scoreBg:getContentSize().width - bestBg:getContentSize().width - rewardBtn:getContentSize().width - scoreItemSpace * 2 - 20
        local lbStr = getlocal("championshipWar_personal_checkpoint_tips", {championshipWarVoApi:getCurrentCheckpointId() - 1, surplusNum})
        local scoreLb = GetTTFLabelWrap(lbStr, 20, CCSizeMake(lbW, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        scoreLb:setAnchorPoint(ccp(0, 0))
        scoreLb:setPosition(bestBg:getPositionX() + bestBg:getContentSize().width / 2 + 10, self.scoreBg:getContentSize().height / 2 - 10)
        self.scoreBg:addChild(scoreLb)
        local ownStarNum = championshipWarVoApi:getStarNum(championshipWarVoApi:getAttackNum()) --已获得的星星数
        local surplusStarNum = ownStarNum - championshipWarVoApi:getCostStarNum(championshipWarVoApi:getAttackNum()) --剩余的星星数
        local lb1 = GetTTFLabel(getlocal("activity_vipAction_had") .. "：" .. ownStarNum, 20)
        lb1:setAnchorPoint(ccp(0, 1))
        lb1:setPosition(scoreLb:getPositionX(), scoreLb:getPositionY() - 10)
        self.scoreBg:addChild(lb1)
        local starSp1 = CCSprite:createWithSpriteFrameName("avt_star.png")
        starSp1:setScale((lb1:getContentSize().height + 10) / starSp1:getContentSize().height)
        starSp1:setPosition(lb1:getPositionX() + lb1:getContentSize().width + starSp1:getContentSize().width * starSp1:getScale() / 2, lb1:getPositionY() - lb1:getContentSize().height / 2)
        self.scoreBg:addChild(starSp1)
        local lb2 = GetTTFLabel("，" .. getlocal("expeditionSurplus") .. "：" .. surplusStarNum, 20)
        lb2:setAnchorPoint(ccp(0, 1))
        lb2:setPosition(starSp1:getPositionX() + starSp1:getContentSize().width * starSp1:getScale() / 2, lb1:getPositionY())
        self.scoreBg:addChild(lb2)
        local starSp2 = CCSprite:createWithSpriteFrameName("avt_star.png")
        starSp2:setScale((lb2:getContentSize().height + 10) / starSp2:getContentSize().height)
        starSp2:setPosition(lb2:getPositionX() + lb2:getContentSize().width + starSp2:getContentSize().width * starSp2:getScale() / 2, lb2:getPositionY() - lb2:getContentSize().height / 2)
        self.scoreBg:addChild(starSp2)
    end
end

function championshipWarPersonalDialog:initCenter(showType)
    if self.contentBg and tolua.cast(self.contentBg, "CCSprite") then
        self.contentBg:removeFromParentAndCleanup(true)
        self.contentBg = nil
    end
    if self.contentTv and tolua.cast(self.contentTv, "LuaCCTableView") then
        self.contentTv:removeFromParentAndCleanup(true)
        self.contentTv = nil
    end
    
    if showType == 1 or showType == 2 then
        local contentBgHeight = 490
        local contentBgTopSpace = 10
        if G_getIphoneType() == G_iphone5 then
            contentBgHeight = 530
            contentBgTopSpace = 15
        elseif G_getIphoneType() == G_iphoneX then
            contentBgHeight = 600
            contentBgTopSpace = 15
        end
        if showType == 2 then
            contentBgTopSpace = 15
            contentBgHeight = 450
            if G_getIphoneType() == G_iphone5 then
                contentBgHeight = 550
            elseif G_getIphoneType() == G_iphoneX then
                contentBgHeight = 600
            end
        end
        self.contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
        self.contentBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, contentBgHeight))
        self.contentBg:setAnchorPoint(ccp(0.5, 1))
        self.contentBg:setPosition(ccp(G_VisibleSizeWidth / 2, self.scoreBg:getPositionY() - self.scoreBg:getContentSize().height - contentBgTopSpace))
        self.bgLayer:addChild(self.contentBg)
    end
    
    if showType == 1 then
        local troops = championshipWarVoApi:getCurrentCheckpointTroops()
        if troops then
            local space = 15
            local iconSize = 85
            local iconSpace = 12
            if G_getIphoneType() == G_iphone5 then
                space, iconSpace = 20, 16
            elseif G_getIphoneType() == G_iphoneX then
                space, iconSpace = 25, 18
                iconSize = 100
            end
            local posY = self.contentBg:getContentSize().height - space - 3
            local titleStrTb = {getlocal("championshipWar_personal_easy"), getlocal("championshipWar_personal_medium"), getlocal("championshipWar_personal_difficulty")}
            local cfg = championshipWarVoApi:getWarCfg()
            local ratioCount = SizeOfTable(cfg.getStarRatio)
            local checkpointIconId = championshipWarVoApi:getCurrentCheckpointIconId()
            for k, v in ipairs(cfg.getStarRatio) do
                if troops[k] then
                    local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
                    titleBg:setContentSize(CCSizeMake(self.contentBg:getContentSize().width - 55, titleBg:getContentSize().height))
                    titleBg:setAnchorPoint(ccp(0, 1))
                    titleBg:setPosition(10, posY)
                    self.contentBg:addChild(titleBg)
                    local titleLb = GetTTFLabel(titleStrTb[k], 24, true)
                    titleLb:setAnchorPoint(ccp(0, 0.5))
                    titleLb:setPosition(15, titleBg:getContentSize().height / 2)
                    titleLb:setColor(G_ColorYellowPro)
                    titleBg:addChild(titleLb)
                    posY = posY - titleBg:getContentSize().height - iconSpace
                    local iconId = checkpointIconId[k] or headCfg.default
                    local iconFrameId = cfg.npcIconFrame[k] or headFrameCfg.default
                    local iconSp = playerVoApi:GetPlayerBgIcon(playerVoApi:getPersonPhotoName(iconId), nil, nil, nil, nil, iconFrameId)
                    iconSp:setScale(iconSize / iconSp:getContentSize().height)
                    iconSp:setPosition(30 + iconSp:getContentSize().width * iconSp:getScale() / 2, posY - iconSp:getContentSize().height * iconSp:getScale() / 2)
                    self.contentBg:addChild(iconSp)
                    local fight = championshipWarVoApi:getCheckpointFight(k)
                    local troopNum = 0
                    for m, n in pairs(troops[k]) do
                        if n[1] then
                            troopNum = troopNum + 1
                        end
                    end
                    local fightLb = GetTTFLabel(getlocal("ltzdz_fight") .. FormatNumber(fight), 20)
                    local troopNumLb = GetTTFLabel(getlocal("championshipWar_personal_troopNum") .. troopNum, 20)
                    local rewardLb = GetTTFLabel(getlocal("seasonRewardStr"), 20)
                    local starSp = CCSprite:createWithSpriteFrameName("avt_star.png")
                    local starNumLb = GetTTFLabel("x" .. v, 20)
                    fightLb:setAnchorPoint(ccp(0, 0))
                    troopNumLb:setAnchorPoint(ccp(0, 0.5))
                    rewardLb:setAnchorPoint(ccp(0, 1))
                    troopNumLb:setPosition(iconSp:getPositionX() + iconSp:getContentSize().width * iconSp:getScale() / 2 + 20, iconSp:getPositionY())
                    fightLb:setPosition(troopNumLb:getPositionX(), troopNumLb:getPositionY() + troopNumLb:getContentSize().height / 2 + 10)
                    rewardLb:setPosition(troopNumLb:getPositionX(), troopNumLb:getPositionY() - troopNumLb:getContentSize().height / 2 - 10)
                    starSp:setScale((rewardLb:getContentSize().height + 10) / starSp:getContentSize().height)
                    starSp:setPosition(rewardLb:getPositionX() + rewardLb:getContentSize().width, rewardLb:getPositionY() - rewardLb:getContentSize().height / 2)
                    starNumLb:setAnchorPoint(ccp(0, 1))
                    starNumLb:setPosition(starSp:getPositionX() + starSp:getContentSize().width * starSp:getScale() / 2, rewardLb:getPositionY())
                    self.contentBg:addChild(fightLb)
                    self.contentBg:addChild(troopNumLb)
                    self.contentBg:addChild(rewardLb)
                    self.contentBg:addChild(starSp)
                    self.contentBg:addChild(starNumLb)
                    posY = iconSp:getPositionY() - iconSp:getContentSize().height * iconSp:getScale() / 2
                    if k ~= ratioCount then
                        posY = posY - iconSpace
                        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
                        lineSp:setContentSize(CCSizeMake(self.contentBg:getContentSize().width - 18, 2))
                        lineSp:setAnchorPoint(ccp(0.5, 1))
                        lineSp:setPosition(self.contentBg:getContentSize().width / 2, posY)
                        self.contentBg:addChild(lineSp)
                        posY = posY - lineSp:getContentSize().height
                    end
                    posY = posY - space
                    local function touchAttackHandler()
                        if G_checkClickEnable() == false then
                            do return end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)
                        local state = championshipWarVoApi:getWarState()
                        if state ~= 10 then
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_notin_personalwar"), 30)
                            do return end
                        end
                        -- if self.isQuickBattle == true then
                        --     -- print("cjl --------->>> 扫荡...", titleStrTb[k])
                        --     local tid = championshipWarVoApi:getCurrentCheckpointId()
                        --     -- print("tid----->>>", tid)
                        --     local function quickBattle(report)
                        --         local function battleResultHandler() --战斗结算页面关闭后弹出每五关的奖励页面
                        --             local function refresh() --刷新一些页面
                        --                 eventDispatcher:dispatchEvent("championshipWarPersonalDialog.refreshUI", {refreshType = 1})
                        --             end
                        --             local warCfg = championshipWarVoApi:getWarCfg()
                        --             if tid > 0 and tid % warCfg.extraStageReward == 0 then --达到5关标准
                        --                 championshipWarVoApi:showFiveStageRewardDialog(true, self.layerNum + 1, refresh)
                        --             else
                        --                 refresh()
                        --             end
                        --         end
                        --         -- print("k,report.star------->>>", k, report.star)
                        --         local result = {star = report.star / k, diffId = k}
                        --         championshipWarVoApi:showPersonalWarBattleResultDialog(true, result, true, self.layerNum + 1, battleResultHandler)
                        --     end
                        --     championshipWarVoApi:personalWarRaid(tid, k, quickBattle)
                        -- else
                            -- print("cjl --------->>> 去设置部队页面...", titleStrTb[k])
                            championshipWarVoApi:showPersonalWarTroopDialog(k, self.layerNum + 1)
                        -- end
                    end
                    local attackBtn = GetButtonItem("yh_IconAttackBtn.png", "yh_IconAttackBtn_Down.png", "yh_IconAttackBtn.png", touchAttackHandler)
                    local attackMenu = CCMenu:createWithItem(attackBtn)
                    attackMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
                    attackMenu:setPosition(self.contentBg:getContentSize().width - 35 - attackBtn:getContentSize().width * attackBtn:getScale() / 2, iconSp:getPositionY())
                    self.contentBg:addChild(attackMenu)
                end
            end
        end
    elseif showType == 2 then
        local buffData = championshipWarVoApi:getSelectBuffData()
        if buffData then
            local fontSize = 20
            local buffSize = SizeOfTable(buffData)
            local itemTopSpace = 30
            if G_getIphoneType() == G_iphone5 then
                itemTopSpace = 50
            elseif G_getIphoneType() == G_iphoneX then
                itemTopSpace = 60
            end
            local posY = self.contentBg:getContentSize().height - itemTopSpace
            for k, v in pairs(buffData) do
                local function touchSelectHandler()
                    if G_checkClickEnable() == false then
                        do return end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    local state = championshipWarVoApi:getWarState()
                    if state ~= 10 then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_notin_personalwar"), 30)
                        do return end
                    end
                    -- print("cjl --------->>> 选择属性", k)
                    local ownStarNum = championshipWarVoApi:getStarNum(championshipWarVoApi:getAttackNum()) --已获得的星星数
                    local surplusStarNum = ownStarNum - championshipWarVoApi:getCostStarNum(championshipWarVoApi:getAttackNum()) --剩余的星星数
                    if surplusStarNum < v.starNum then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_starNoEnough"), 30)
                        do return end
                    end
                    championshipWarVoApi:selectProperty(k, function()
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_selectPropertySuccceed"), 30)
                        self:refreshUI()
                    end)
                end
                local iconSize = 100
                local icon = CCSprite:createWithSpriteFrameName(v.icon)
                icon:setScale(iconSize / icon:getContentSize().height)
                icon:setPosition(20 + iconSize / 2, posY - iconSize / 2)
                self.contentBg:addChild(icon)
                local btnScale = 0.6
                local selectBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", touchSelectHandler, nil, getlocal("dailyAnswer_tab1_btn"), 24 / btnScale)
                selectBtn:setScale(btnScale)
                local selectMenu = CCMenu:createWithItem(selectBtn)
                selectMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
                selectMenu:setPosition(self.contentBg:getContentSize().width - selectBtn:getContentSize().width * btnScale / 2 - 20, icon:getPositionY() - iconSize / 2 + selectBtn:getContentSize().height * btnScale / 2)
                self.contentBg:addChild(selectMenu)
                local costLb = GetTTFLabel(getlocal("raids_cost"), fontSize)
                local costNumLb = GetTTFLabel(tostring(v.starNum), fontSize)
                local starSp = CCSprite:createWithSpriteFrameName("avt_star.png")
                starSp:setScale((costNumLb:getContentSize().height + 10) / starSp:getContentSize().height)
                starSp:setPosition(selectMenu:getPositionX() + 20, selectMenu:getPositionY() + selectBtn:getContentSize().height * btnScale / 2 + starSp:getContentSize().height * starSp:getScale() / 2 + 10)
                self.contentBg:addChild(starSp)
                costLb:setAnchorPoint(ccp(1, 0.5))
                costLb:setPosition(starSp:getPositionX() - starSp:getContentSize().width * starSp:getScale() / 2, starSp:getPositionY())
                self.contentBg:addChild(costLb)
                costNumLb:setAnchorPoint(ccp(0, 0.5))
                costNumLb:setPosition(starSp:getPositionX() + starSp:getContentSize().width * starSp:getScale() / 2, starSp:getPositionY())
                self.contentBg:addChild(costNumLb)
                local desclBWidth = self.contentBg:getContentSize().width - iconSize - selectBtn:getContentSize().width * btnScale - 60
                local descLb, descLbHeight
                if type(v.desc) == "table" then
                    descLb, descLbHeight = G_getRichTextLabel(v.desc[1], v.desc[2], fontSize, desclBWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                elseif type(v.desc) == "string" then
                    descLb = GetTTFLabelWrap(v.desc, fontSize, CCSizeMake(desclBWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                    descLbHeight = descLb:getContentSize().height
                end
                descLb:setAnchorPoint(ccp(0, 1))
                descLb:setPosition(icon:getPositionX() + iconSize / 2 + 10, icon:getPositionY() + descLbHeight / 2)
                self.contentBg:addChild(descLb)
                posY = icon:getPositionY() - iconSize / 2
                if k ~= buffSize then
                    local lineSpTopSpace = 20
                    if G_getIphoneType() == G_iphone5 then
                        lineSpTopSpace = 35
                    elseif G_getIphoneType() == G_iphoneX then
                        lineSpTopSpace = 45
                    end
                    posY = posY - lineSpTopSpace
                    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
                    lineSp:setContentSize(CCSizeMake(self.contentBg:getContentSize().width - 18, 3))
                    lineSp:setAnchorPoint(ccp(0.5, 1))
                    lineSp:setPosition(self.contentBg:getContentSize().width / 2, posY)
                    self.contentBg:addChild(lineSp)
                    posY = posY - lineSp:getContentSize().height
                end
                local itemSpace = 20
                if G_getIphoneType() == G_iphone5 then
                    itemSpace = 35
                elseif G_getIphoneType() == G_iphoneX then
                    itemSpace = 45
                end
                posY = posY - itemSpace
            end
        end
        
        --属性总览
        local propertyBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
        propertyBg:setContentSize(self.contentBg:getContentSize())
        propertyBg:setAnchorPoint(ccp(0, 1))
        propertyBg:setPosition(G_VisibleSizeWidth, self.contentBg:getContentSize().height)
        self.contentBg:addChild(propertyBg)
        local titleBg = G_createNewTitle({getlocal("battlebuff_overview"), 24}, CCSizeMake(300, 0), nil, nil, "Helvetica-bold")
        titleBg:setPosition(propertyBg:getContentSize().width / 2, propertyBg:getContentSize().height - 40)
        propertyBg:addChild(titleBg)
        local buffDescTb = championshipWarVoApi:getTotalBuffDescStr()
        local fontSize, fontWidth = 22, propertyBg:getContentSize().width - 40
        local cellHeightTb = {}
        local cellNum = SizeOfTable(buffDescTb)
        for k, v in pairs(buffDescTb) do
            local descLb, lbheight = G_getRichTextLabel(v[1], v[2], fontSize, fontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            cellHeightTb[k] = lbheight + 10
        end
        if cellNum == 0 then
            local tipLb = GetTTFLabelWrap(getlocal("championshipWar_no_buff"), 22, CCSize(propertyBg:getContentSize().width - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
            tipLb:setColor(G_ColorGray2)
            tipLb:setPosition(getCenterPoint(tipLb))
            propertyBg:addChild(tipLb)
        end
        local function tvCallBack(handler, fn, index, cel)
            if fn == "numberOfCellsInTableView" then
                return cellNum
            elseif fn == "tableCellSizeForIndex" then
                return CCSizeMake(propertyBg:getContentSize().width - 6, cellHeightTb[index + 1])
            elseif fn == "tableCellAtIndex" then
                local cell = CCTableViewCell:new()
                cell:autorelease()
                local cellW = propertyBg:getContentSize().width - 6
                local desc = buffDescTb[index + 1]
                local descLb, lbheight = G_getRichTextLabel(desc[1], desc[2], fontSize, fontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                descLb:setAnchorPoint(ccp(0, 1))
                descLb:setPosition((cellW - fontWidth) / 2, 5 + lbheight)
                cell:addChild(descLb)
                return cell
            elseif fn == "ccTouchBegan" then
                return true
            elseif fn == "ccTouchMoved" then
            elseif fn == "ccTouchEnded" then
            end
        end
        local hd = LuaEventHandler:createHandler(tvCallBack)
        propertyTv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(propertyBg:getContentSize().width - 6, propertyBg:getContentSize().height - 76), nil)
        propertyTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
        propertyTv:setMaxDisToBottomOrTop(100)
        propertyTv:setPosition(3, 10)
        propertyBg:addChild(propertyTv)
    elseif showType == 3 then
        self:initPersonalResult()
    end
end

function championshipWarPersonalDialog:initPersonalResult()
    local fontSize = 24
    local cellNum = 3
    local cellHeightTb = {}
    local tempSp = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    for i = 1, cellNum do
        local height = 0
        if i == 1 then
            height = height + 230
        else
            height = height + 10 + tempSp:getContentSize().height + 10
            local descTb
            if i == 2 then
                local maxStageNum, maxFirst = championshipWarVoApi:getMaxStageNumAndFirst()
                descTb = {
                    {getlocal("championshipWar_allianceCheckpointNum", {championshipWarVoApi:getAllianceStageNum(), maxStageNum}), {nil, G_ColorRed, nil}},
                    {getlocal("championshipWar_addFirstValue", {championshipWarVoApi:getFirst(), maxFirst}), {nil, G_ColorRed, nil}},
                }
                height = height + 20
            elseif i == 3 then
                descTb = championshipWarVoApi:getTotalBuffDescStr(true)
            end
            if descTb then
                for k, v in pairs(descTb) do
                    local lb, lbHeight = G_getRichTextLabel(v[1], v[2], fontSize, (G_VisibleSizeWidth - 30) - 80, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                    height = height + lbHeight + 5
                end
            end
            height = height + 10
        end
        cellHeightTb[i] = height
    end
    tempSp = nil
    local function tvCallBack(handler, fn, index, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(G_VisibleSizeWidth - 30, cellHeightTb[index + 1])
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local cellW, cellH = G_VisibleSizeWidth - 30, cellHeightTb[index + 1]
            
            local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
            if index == 1 then
                bgSp:setContentSize(CCSizeMake(cellW, cellH - 20))
            else
                bgSp:setContentSize(CCSizeMake(cellW, cellH))
            end
            bgSp:setPosition(cellW / 2, cellH / 2)
            cell:addChild(bgSp)
            local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
            titleBg:setAnchorPoint(ccp(0.5, 1))
            titleBg:setPosition(bgSp:getContentSize().width / 2, bgSp:getContentSize().height - 10)
            bgSp:addChild(titleBg)
            local titleStr = ""
            if index == 0 then
                titleStr = getlocal("championshipWar_personal_score")
            elseif index == 1 then
                titleStr = getlocal("championshipWar_alliance_score")
            elseif index == 2 then
                titleStr = getlocal("battlebuff_overview")
            end
            local titleLb = GetTTFLabel(titleStr, fontSize, true)
            titleLb:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2)
            titleLb:setColor(G_ColorYellowPro)
            titleBg:addChild(titleLb)
            if index == 0 then
                local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png", CCRect(4, 4, 1, 1), function()end)
                nameBg:setContentSize(CCSizeMake(bgSp:getContentSize().width - 5, 40))
                nameBg:setAnchorPoint(ccp(0.5, 1))
                nameBg:setPosition(bgSp:getContentSize().width / 2, titleBg:getPositionY() - titleBg:getContentSize().height - 10)
                bgSp:addChild(nameBg)
                local nameTb = {
                    {str = getlocal("championshipWar_round"), posX = nameBg:getContentSize().width * 0.1},
                    {str = getlocal("championshipWar_score"), posX = nameBg:getContentSize().width * 0.35},
                    {str = getlocal("serverwar_point"), posX = nameBg:getContentSize().width * 0.6},
                    {str = getlocal("championshipWar_getProperty"), posX = nameBg:getContentSize().width * 0.85},
                }
                for k, v in pairs(nameTb) do
                    local nameLb = GetTTFLabel(v.str, fontSize)
                    nameLb:setPosition(v.posX, nameBg:getContentSize().height / 2)
                    nameLb:setColor(G_ColorGreen)
                    nameBg:addChild(nameLb)
                end
                local cfg = championshipWarVoApi:getWarCfg()
                local attackNum = championshipWarVoApi:getAttackNum()
                local bestAttackNum = championshipWarVoApi:getBestAttackNum() --最优轮次
                local posY = nameBg:getPositionY() - nameBg:getContentSize().height - 3
                local firstLbBg
                for i = 1, attackNum do
                    local attrRate = championshipWarVoApi:getAttrRate(i)
                    local starNum, checkpointNum = championshipWarVoApi:getStarNum(i)
                    local integral = championshipWarVoApi:getPersonalIntegral(i)
                    local valueTb = {
                        tostring(i),
                        getlocal("championshipWar_scoreDesc", {checkpointNum, starNum}),
                        tostring(integral),
                        "+" .. (attrRate * 100) .. "%",
                    }
                    local lbBg = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function()end)
                    lbBg:setContentSize(CCSizeMake(bgSp:getContentSize().width - 6, 34))
                    lbBg:setAnchorPoint(ccp(0.5, 1))
                    lbBg:setPosition(bgSp:getContentSize().width / 2, posY)
                    bgSp:addChild(lbBg)
                    if i == bestAttackNum and firstLbBg then
                        local tempPosY = lbBg:getPositionY()
                        lbBg:setPositionY(firstLbBg:getPositionY())
                        firstLbBg:setPositionY(tempPosY)
                    end
                    if firstLbBg == nil then
                        firstLbBg = lbBg
                    end
                    for k, v in pairs(valueTb) do
                        local lb = GetTTFLabel(v, fontSize)
                        lb:setPosition(nameTb[k].posX, lbBg:getContentSize().height / 2)
                        if i == bestAttackNum then
                            lb:setColor(G_ColorYellowPro)
                        end
                        lbBg:addChild(lb)
                        if k == 2 then
                            local starSp = CCSprite:createWithSpriteFrameName("avt_star.png")
                            starSp:setScale((lb:getContentSize().height + 10) / starSp:getContentSize().height)
                            starSp:setPosition(lb:getPositionX() + lb:getContentSize().width / 2 + starSp:getContentSize().width * starSp:getScale() / 2, lb:getPositionY())
                            lbBg:addChild(starSp)
                        end
                    end
                    posY = posY - lbBg:getContentSize().height - 3
                end
            else
                local descTb
                if index == 1 then
                    local maxStageNum, maxFirst = championshipWarVoApi:getMaxStageNumAndFirst()
                    descTb = {
                        {getlocal("championshipWar_allianceCheckpointNum", {championshipWarVoApi:getAllianceStageNum(), maxStageNum}), {nil, G_ColorRed, nil}},
                        {getlocal("championshipWar_addFirstValue", {championshipWarVoApi:getFirst(), maxFirst}), {nil, G_ColorRed, nil}},
                    }
                elseif index == 2 then
                    descTb = championshipWarVoApi:getTotalBuffDescStr(true)
                end
                if descTb then
                    local lbPosY = titleBg:getPositionY() - titleBg:getContentSize().height - 10
                    for k, v in pairs(descTb) do
                        local lb, lbHeight = G_getRichTextLabel(v[1], v[2], fontSize, bgSp:getContentSize().width - 80, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                        lb:setAnchorPoint(ccp(0, 1))
                        lb:setPosition(40, lbPosY)
                        bgSp:addChild(lb)
                        lbPosY = lbPosY - lbHeight - 5
                    end
                end
            end
            
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    local contentTvTopSapce = 150
    local contentTvPosY = 140
    if G_getIphoneType() == G_iphone5 then
        contentTvTopSapce = 180
        contentTvPosY = 170
    elseif G_getIphoneType() == G_iphoneX then
        contentTvTopSapce = 190
        contentTvPosY = 180
    end
    self.contentTv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(G_VisibleSizeWidth - 30, self.timeBg:getPositionY() - self.timeBg:getContentSize().height - contentTvTopSapce), nil)
    self.contentTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.contentTv:setMaxDisToBottomOrTop(100)
    self.contentTv:setPosition(15, contentTvPosY)
    self.bgLayer:addChild(self.contentTv)
end

function championshipWarPersonalDialog:initBottom(showType)
    if self.bottomNode and tolua.cast(self.bottomNode, "CCNode") then
        self.bottomNode:removeAllChildrenWithCleanup(true)
    else
        self.bottomNode = CCNode:create()
        self.bgLayer:addChild(self.bottomNode)
    end
    
    if showType == 1 or showType == 3 then
        local btnBottomSpace = 45
        if G_getIphoneType() == G_iphone5 then
            btnBottomSpace = 75
        elseif G_getIphoneType() == G_iphoneX then
            btnBottomSpace = 85
        end
        local btnScale = 0.8
        local cfg = championshipWarVoApi:getWarCfg()

        local function quickHandle( )
            local function sureClick()
                local function quickBattleEndBack( )
                    print "quickBattleEndBack~~~~"
                    self:refreshUI()
                end
                championshipWarVoApi:quickBattleNow(self.layerNum + 1,quickBattleEndBack)
            end
            local function secondTipFunc(sbFlag)
                local keyName="championshipWarQuickBattle"
                local sValue=base.serverTime .. "_" .. sbFlag
                G_changePopFlag(keyName,sValue)
            end
            if G_isPopBoard("championshipWarQuickBattle") then
                self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("championshipWarQuickBattleTip"),true,sureClick,secondTipFunc)
            else
                sureClick()
            end

        end 
        local priority = -(self.layerNum-1)*20-4
        local quickBtn,quickMenu = G_createBotton(self.bottomNode,ccp(G_VisibleSizeWidth * 0.21 , btnBottomSpace + 27),{getlocal("elite_challenge_raid_btn"),22},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",quickHandle,btnScale,priority)
        quickBtn:setEnabled(false)

        if showType == 1 then
            -- self.isQuickBattle = nil
            local function touchRankHandler()
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                local state = championshipWarVoApi:getWarState()
                if state ~= 10 then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_notin_personalwar"), 30)
                    do return end
                end
                -- print("cjl --------->>> 排行")
                championshipWarVoApi:showRankDialog(self.layerNum + 1, 1)
            end
            
            local rankBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", touchRankHandler, nil, getlocal("alienMines_rank"), 24 / btnScale)
            rankBtn:setScale(btnScale)
            local rankMenu = CCMenu:createWithItem(rankBtn)
            rankMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            rankMenu:setPosition(G_VisibleSizeWidth * 0.5, btnBottomSpace + rankBtn:getContentSize().height * btnScale / 2)
            self.bottomNode:addChild(rankMenu)
            
            if championshipWarVoApi:getAttackNum() > 1 then --第一轮不显示扫荡
                if quickBtn and championshipWarVoApi:isCanQuickBattle() then
                    quickBtn:setEnabled(true)
                end
                -- local isCanQuickBattle = championshipWarVoApi:isCanQuickBattle(championshipWarVoApi:getAttackNum(), championshipWarVoApi:getCurrentCheckpointId())
                -- local checkBox
                -- local function operateHandler(...)
                --     local state = championshipWarVoApi:getWarState()
                --     if state ~= 10 then
                --         smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_notin_personalwar"), 30)
                --         do return end
                --     end
                --     if checkBox and checkBox:getSelectedIndex() == 1 then
                --         if isCanQuickBattle == true then
                --             self.isQuickBattle = true
                --         else
                --             self.isQuickBattle = nil
                --             smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_personal_unableQuickBattle"), 30)
                --             checkBox:setSelectedIndex(0)
                --         end
                --     else
                --         self.isQuickBattle = nil
                --     end
                -- end
                -- local menu = CCMenu:create()
                -- local switchSp1 = CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
                -- local switchSp2 = CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
                -- local menuItemSp1 = CCMenuItemSprite:create(switchSp1, switchSp2)
                -- local switchSp3 = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
                -- local switchSp4 = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
                -- local menuItemSp2 = CCMenuItemSprite:create(switchSp3, switchSp4)
                -- checkBox = CCMenuItemToggle:create(menuItemSp1)
                -- checkBox:addSubItem(menuItemSp2)
                -- checkBox:setAnchorPoint(CCPointMake(0.5, 0.5))
                -- checkBox:registerScriptTapHandler(operateHandler)
                -- menu:addChild(checkBox)
                -- local checkBoxBottomSpace = 5
                -- if G_getIphoneType() == G_iphone5 then
                --     checkBoxBottomSpace = 25
                -- elseif G_getIphoneType() == G_iphoneX then
                --     checkBoxBottomSpace = 40
                -- end
                -- menu:setPosition(55, rankMenu:getPositionY() + rankBtn:getContentSize().height * btnScale / 2 + checkBox:getContentSize().height / 2 + checkBoxBottomSpace)
                -- menu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
                -- self.bottomNode:addChild(menu)
                -- local checkBoxLb = GetTTFLabel(getlocal("elite_challenge_raid_btn"), 22)
                -- checkBoxLb:setAnchorPoint(ccp(0, 0.5))
                -- checkBoxLb:setPosition(menu:getPositionX() + checkBox:getContentSize().width / 2, menu:getPositionY())
                -- self.bottomNode:addChild(checkBoxLb)
                -- if isCanQuickBattle == true then
                --     checkBox:setSelectedIndex(1)
                --     self.isQuickBattle = true
                -- end
            end
        else
            local price = cfg.singleWarCost[championshipWarVoApi:getAttackNum() + 1] or 0
            local function touchResetHandler()
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                local state = championshipWarVoApi:getWarState()
                if state ~= 10 then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_notin_personalwar"), 30)
                    do return end
                end
                -- print("cjl --------->>> 重置战斗")
                local function onSureLogic()
                    local ownGems = playerVoApi:getGems()
                    if ownGems < price then
                        local function buyGems()
                            vipVoApi:showRechargeDialog(self.layerNum + 1)
                        end
                        G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("gemNotEnough", {price,ownGems,price - ownGems}), false, buyGems)
                        do return end
                    end
                    championshipWarVoApi:buyBuffOrTroops(2, function()
                        playerVoApi:setGems(playerVoApi:getGems() - price)
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("success_str"), 30)
                        self:refreshUI()
                    end)
                end
                local function secondTipFunc(sbFlag)
                    local sValue = base.serverTime .. "_" .. sbFlag
                    G_changePopFlag("cswPersonalDialog_resetBattle", sValue)
                end
                if G_isPopBoard("cswPersonalDialog_resetBattle") then
                    G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("second_tip_des", {price}), true, onSureLogic, secondTipFunc)
                else
                    onSureLogic()
                end
            end
            local resetBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", touchResetHandler, nil, getlocal("championshipWar_personal_resetBattle"), 24 / btnScale)
            resetBtn:setScale(btnScale)
            local resetMenu = CCMenu:createWithItem(resetBtn)
            resetMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            resetMenu:setPosition(G_VisibleSizeWidth * 0.5 , btnBottomSpace + resetBtn:getContentSize().height * btnScale / 2)
            self.bottomNode:addChild(resetMenu)
            if championshipWarVoApi:getAttackNum() == cfg.singleWarTimes then
                resetBtn:setEnabled(false)
            end
            local goldLb = GetTTFLabel(tostring(price), 20)
            goldLb:setAnchorPoint(ccp(1, 0.5))
            goldLb:setPosition(resetMenu:getPositionX(), resetMenu:getPositionY() + resetBtn:getContentSize().height * btnScale / 2 + 20)
            self.bottomNode:addChild(goldLb)
            local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
            goldSp:setAnchorPoint(ccp(0, 0.5))
            goldSp:setPosition(goldLb:getPosition())
            self.bottomNode:addChild(goldSp)
            local countLb = GetTTFLabel(getlocal("activity_znkh2017_lottery_num", {championshipWarVoApi:getAttackNum() .. "/" .. cfg.singleWarTimes}), 22)
            countLb:setAnchorPoint(ccp(0.5, 1))
            countLb:setPosition(resetMenu:getPositionX(), resetMenu:getPositionY() - resetBtn:getContentSize().height * btnScale / 2)
            self.bottomNode:addChild(countLb)
        end
        
        local price = cfg.BuyTroopsCost[championshipWarVoApi:getBuyTroopsNum() + 1] or 0
        local function touchAddTroopHandler()
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local state = championshipWarVoApi:getWarState()
            if state ~= 10 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_notin_personalwar"), 30)
                do return end
            end
            -- print("cjl --------->>> 增加带兵")
            local function onSureLogic()
                local ownGems = playerVoApi:getGems()
                if ownGems < price then
                    local function buyGems()
                        vipVoApi:showRechargeDialog(self.layerNum + 1)
                    end
                    G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("gemNotEnough", {price,ownGems,price - ownGems}), false, buyGems)
                    do return end
                end
                championshipWarVoApi:buyBuffOrTroops(1, function()
                    playerVoApi:setGems(playerVoApi:getGems() - price)
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("success_str"), 30)
                    self:refreshUI()
                end)
            end
            local function secondTipFunc(sbFlag)
                local sValue = base.serverTime .. "_" .. sbFlag
                G_changePopFlag("cswPersonalDialog_addTroops", sValue)
            end
            if G_isPopBoard("cswPersonalDialog_addTroops") then
                local topContent = {
                    getlocal("championshipWar_buyTroopsTips", {price, cfg.troopsAdd}),
                    {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil},
                }
                G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), topContent, true, onSureLogic, secondTipFunc)
            else
                onSureLogic()
            end
        end
        local addTroopBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", touchAddTroopHandler, nil, getlocal("championshipWar_personal_addTroop"), 24 / btnScale)
        addTroopBtn:setScale(btnScale)
        local addTroopMenu = CCMenu:createWithItem(addTroopBtn)
        addTroopMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        addTroopMenu:setPosition(G_VisibleSizeWidth * 0.79 , btnBottomSpace + addTroopBtn:getContentSize().height * btnScale / 2)
        self.bottomNode:addChild(addTroopMenu)
        if championshipWarVoApi:getBuyTroopsNum() == cfg.BuyTroopsNum then
            addTroopBtn:setEnabled(false)
        end
        local goldLb = GetTTFLabel(tostring(price), 20)
        goldLb:setAnchorPoint(ccp(1, 0.5))
        goldLb:setPosition(addTroopMenu:getPositionX(), addTroopMenu:getPositionY() + addTroopBtn:getContentSize().height * btnScale / 2 + 20)
        self.bottomNode:addChild(goldLb)
        local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
        goldSp:setAnchorPoint(ccp(0, 0.5))
        goldSp:setPosition(goldLb:getPosition())
        self.bottomNode:addChild(goldSp)
        local countLb = GetTTFLabel(getlocal("activity_znkh2017_lottery_num", {championshipWarVoApi:getBuyTroopsNum() .. "/" .. cfg.BuyTroopsNum}), 22)
        countLb:setAnchorPoint(ccp(0.5, 1))
        countLb:setPosition(addTroopMenu:getPositionX(), addTroopMenu:getPositionY() - addTroopBtn:getContentSize().height * btnScale / 2)
        self.bottomNode:addChild(countLb)
    elseif showType == 2 then
        local switchLb
        local showIdx = 1
        local isMoving = false
        local function onSwitchHandler()
            if isMoving == true then
                do return end
            end
            local moveDis = 0
            if showIdx == 1 then
                showIdx = 2
                switchLb:setString(getlocal("coverFleetBack"))
                moveDis = -G_VisibleSizeWidth
            else
                showIdx = 1
                switchLb:setString(getlocal("battlebuff_overview"))
                moveDis = G_VisibleSizeWidth
            end
            local moveBy = CCMoveBy:create(0.5, ccp(moveDis, 0))
            local function moveEnd()
                isMoving = false
            end
            isMoving = true
            self.contentBg:runAction(CCSequence:createWithTwoActions(moveBy, CCCallFunc:create(moveEnd)))
        end
        local switchBtnBottomSpace = 35
        if G_getIphoneType() == G_iphone5 then
            switchBtnBottomSpace = 70
        elseif G_getIphoneType() == G_iphoneX then
            switchBtnBottomSpace = 90
        end
        local switchBtn = LuaCCSprite:createWithSpriteFrameName("reportDetailBtn.png", onSwitchHandler)
        switchBtn:setPosition(G_VisibleSizeWidth / 2, switchBtnBottomSpace + switchBtn:getContentSize().height / 2)
        switchBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        self.bottomNode:addChild(switchBtn)
        switchLb = GetTTFLabel(getlocal("battlebuff_overview"), 24, true)
        switchLb:setPosition(switchBtn:getContentSize().width / 2, switchBtn:getContentSize().height / 2)
        switchBtn:addChild(switchLb)
        
        local descLb = GetTTFLabelWrap(getlocal("championshipWar_selectPropertyDesc"), 24, CCSizeMake(G_VisibleSizeWidth - 50, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
        descLb:setAnchorPoint(ccp(0, 0))
        descLb:setPosition(25, switchBtn:getPositionY() + switchBtn:getContentSize().height / 2 + 20)
        self.bottomNode:addChild(descLb)
    end
end

function championshipWarPersonalDialog:tick()
    if self then
        if self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
            local timeLb = tolua.cast(self.timeLb, "CCLabelTTF")
            local state, time = championshipWarVoApi:getWarState()
            if state == 10 then
                timeLb:setString(getlocal("championshipWar_personal_endTime") .. G_formatActiveDate(time))
            else
                timeLb:setString(getlocal("championshipWar_personal_endTips"))
            end
        end
    end
end

function championshipWarPersonalDialog:dispose()
    eventDispatcher:removeEventListener("championshipWarPersonalDialog.refreshUI", self.eventListener)
    self.eventListener = nil
    self.prevBestScore = nil
    self = nil
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    spriteController:removePlist("public/youhuaUI4.plist")
    spriteController:removeTexture("public/youhuaUI4.png")
    spriteController:removePlist("public/reportyouhua.plist")
    spriteController:removeTexture("public/reportyouhua.png")
end
