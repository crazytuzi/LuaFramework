require "luascript/script/game/scene/gamedialog/Boss/BossBuyBuffDialog"
-- require "luascript/script/game/scene/gamedialog/Boss/BossBattleMyselfAttack"

BossBattleDialogTab1 = {}

function BossBattleDialogTab1:new(...)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.parent = nil
    self.selectMyselfAttack = nil
    self.bossHp = nil
    self.destoryPaotou = {}
    self.bossState = nil
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")
    return nc
end

function BossBattleDialogTab1:init(layerNum, parent)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    self.bossHp = BossBattleVoApi:getBossNowHp()
    self.selectMyselfAttack = BossBattleVoApi:getAttackSelf()
    self.bossState = BossBattleVoApi:getBossState()
    self:initTableView()
    return self.bgLayer
end

function BossBattleDialogTab1:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 40, self.bgLayer:getContentSize().height - 205), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 5)
    self.tv:setPosition(ccp(20, 40))
    self.bgLayer:addChild(self.tv, 5)
    self.tv:setMaxDisToBottomOrTop(120)
    
end
--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function BossBattleDialogTab1:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 1
        
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 40, 935)
        return tmpSize
        
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 40, 935))
        local function showInfo()
            if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if newGuidMgr:isNewGuiding() == true then
                    do return end
                end
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                local tabStr = {};
                local tabColor = {};
                local td = smallDialog:new()
                tabStr = {"\n", getlocal("BossBattle_tip8", {bossCfg.rebound * 100}), "\n", getlocal("BossBattle_tip7"), "\n", getlocal("BossBattle_tip6"), "\n", getlocal("BossBattle_tip5"), "\n", getlocal("BossBattle_tip4"), "\n", getlocal("BossBattle_tip3"), "\n", getlocal("BossBattle_tip2"), "\n", getlocal("BossBattle_tip1"), "\n"}
                local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 25)
                sceneGame:addChild(dialog, self.layerNum + 1)
            end
        end
        
        local infoItem = GetButtonItem("BtnInfor.png", "BtnInfor_Down.png", "BtnInfor_Down.png", showInfo, 11, nil, nil)
        infoItem:setScale(0.8)
        infoItem:setAnchorPoint(ccp(1, 1))
        local infoBtn = CCMenu:createWithItem(infoItem);
        infoBtn:setAnchorPoint(ccp(1, 1))
        infoBtn:setPosition(ccp(cell:getContentSize().width - 35, cell:getContentSize().height - 10))
        infoBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
        cell:addChild(infoBtn, 3)
        local posX = 20
        local h = cell:getContentSize().height - 10
        
        local acTimeLb = GetTTFLabelWrap(getlocal("activity_timeLabel"), 27, CCSizeMake(cell:getContentSize().width - 130, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        acTimeLb:setAnchorPoint(ccp(0, 1))
        acTimeLb:setPosition(posX, h)
        acTimeLb:setColor(G_ColorGreen)
        cell:addChild(acTimeLb)
        
        h = h - acTimeLb:getContentSize().height - 20
        
        self.CDTime = GetTTFLabelWrap(getlocal("acCD"), 25, CCSizeMake(cell:getContentSize().width - 130, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        self.CDTime:setAnchorPoint(ccp(0, 1))
        self.CDTime:setPosition(posX, h)
        cell:addChild(self.CDTime)
        
        h = h - self.CDTime:getContentSize().height - 20
        self.myDamageLb = GetTTFLabelWrap(getlocal("BossBattle_myDamage", {BossBattleVoApi:getMyselfPoint()}), 25, CCSizeMake(cell:getContentSize().width - 150, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        self.myDamageLb:setAnchorPoint(ccp(0, 1))
        self.myDamageLb:setPosition(posX, h)
        cell:addChild(self.myDamageLb)
        
        local attackMySelf = GetTTFLabelWrap(getlocal("BossBattle_MyselfAttack"), 25, CCSizeMake(100, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        attackMySelf:setAnchorPoint(ccp(0, 0.5))
        attackMySelf:setPosition(cell:getContentSize().width - 120, h)
        cell:addChild(attackMySelf)
        
        local mulX = cell:getContentSize().width - 100
        local mulY = h
        local function touch(...)
            if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if newGuidMgr:isNewGuiding() == true then
                    do return end
                end
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                if playerVoApi:getVipLevel() < bossCfg.vipLimit then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("BossBattle_VipLimit", {bossCfg.vipLimit}), 30)
                    do return end
                end
                if self:checkNoTroops() == false then
                    do return end
                end
                if self.selectMyselfAttack == 1 then
                    self.selectMyselfAttack = 0
                    --self.attackMyselfSp:setVisible(false)
                else
                    self.selectMyselfAttack = 1
                    --self.attackMyselfSp:setVisible(true)
                end
                
                local tankTb = tankVoApi:getTanksTbByType(12)
                local hTb = nil
                if heroVoApi:isHaveTroops() then
                    hTb = heroVoApi:getMachiningHeroList(tankTb)
                end
                local AITroopsTb = AITroopsFleetVoApi:getMatchAITroopsList(tankTb)
                local emblemID = emblemVoApi:getBattleEquip(12)
                local planePos = planeVoApi:getBattleEquip(12)
                local airShipId = airShipVoApi:getBattleEquip(12)
                local function callback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        heroVoApi:setBossHeroList(hTb)
                        AITroopsFleetVoApi:setBossAITroopsList(AITroopsTb)
                        if sData.data.worldboss then
                            BossBattleVoApi:onRefreshData(sData.data.worldboss)
                        end
                        if self.selectMyselfAttack == 0 then
                            --self.selectMyselfAttack = 0
                            self.attackMyselfSp:setVisible(false)
                        else
                            --self.selectMyselfAttack = 1
                            -- local zoneId=tostring(base.curZoneID)
                            -- local gameUid=tostring(playerVoApi:getUid())
                            -- local key = G_local_BossAttackSelf..zoneId..gameUid
                            -- local settingsValue = CCUserDefault:sharedUserDefault():getStringForKey(key)
                            -- print("settingsValue......",key,settingsValue)
                            -- if settingsValue==nil or settingsValue=="" then
                            --     BossBattleMyselfAttack:create(self.layerNum+1)
                            -- end
                            self.attackMyselfSp:setVisible(true)
                        end
                    end
                end
                local realEmblemId = emblemVoApi:getEquipIdForBattle(emblemID)
                if realEmblemId ~= -1 then
                    socketHelper:BossBattleSettroops(tankVoApi:getTanksTbByType(12), callback, hTb, self.selectMyselfAttack, realEmblemId, planePos, AITroopsTb, nil, airShipId)
                end
            end
        end
        local AttackSelfbgSp = GetButtonItem("LegionCheckBtnUn.png", "LegionCheckBtnUn.png", "LegionCheckBtnUn.png", touch, 5, nil)
        AttackSelfbgSp:setAnchorPoint(ccp(0, 0.5))
        self.attackSelfBtn = CCMenu:createWithItem(AttackSelfbgSp)
        self.attackSelfBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        self.attackSelfBtn:setPosition(mulX - 80, mulY)
        cell:addChild(self.attackSelfBtn)
        
        self.attackMyselfSp = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
        self.attackMyselfSp:setAnchorPoint(ccp(0, 0.5))
        self.attackMyselfSp:setPosition(mulX - 80, mulY)
        cell:addChild(self.attackMyselfSp)
        if self.selectMyselfAttack == 0 then
            self.attackMyselfSp:setVisible(false)
        end
        
        h = h - self.myDamageLb:getContentSize().height - 20
        
        local function nilFun()
        end
        local capInSet = CCRect(20, 20, 10, 10);
        self.BossMainSP = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png", capInSet, nilFun)
        self.BossMainSP:setContentSize(CCSizeMake(cell:getContentSize().width - 20, 460))
        self.BossMainSP:setAnchorPoint(ccp(0.5, 1))
        self.BossMainSP:setPosition(cell:getContentSize().width / 2, h)
        cell:addChild(self.BossMainSP)
        
        self.bossTankIcon = CCSprite:createWithSpriteFrameName("t99999_1.png")
        self.bossTankIcon:setScale(0.5)
        self.bossTankIcon:setAnchorPoint(ccp(0, 0))
        self.bossTankIcon:setPosition(10, 60)
        self.BossMainSP:addChild(self.bossTankIcon)
        
        local function tmpFunc(...)
            -- body
        end
        self.iconMask = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), tmpFunc)
        self.iconMask :setOpacity(255)
        local size = CCSizeMake(self.BossMainSP:getContentSize().width / 2 + 80, self.BossMainSP:getContentSize().height / 2 + 30)
        self.iconMask:setContentSize(size)
        self.iconMask:setAnchorPoint(ccp(0, 0))
        self.iconMask:setPosition(ccp(10, 60))
        self.iconMask:setIsSallow(true)
        self.iconMask:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        self.BossMainSP:addChild(self.iconMask, 4)
        
        self.maskLb = GetTTFLabelWrap("", 25, CCSizeMake(self.iconMask:getContentSize().width - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        self.maskLb:setPosition(self.iconMask:getContentSize().width / 2, self.iconMask:getContentSize().height / 2)
        self.iconMask:addChild(self.maskLb)
        self.maskLb:setColor(G_ColorYellow)
        
        local bossH = self.BossMainSP:getContentSize().height - 10
        
        local shuomingLb = GetTTFLabelWrap(getlocal("shuoming"), 27, CCSizeMake(self.BossMainSP:getContentSize().width / 2, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        shuomingLb:setAnchorPoint(ccp(0, 1))
        shuomingLb:setPosition(20, bossH)
        self.BossMainSP:addChild(shuomingLb)
        
        local contentLb = GetTTFLabelWrap(getlocal("BossBattle_tankContent"), 25, CCSizeMake(self.BossMainSP:getContentSize().width - 200, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        contentLb:setAnchorPoint(ccp(0, 1))
        contentLb:setPosition(30, bossH - 40)
        self.BossMainSP:addChild(contentLb)
        
        local bossLv = GetTTFLabelWrap(getlocal("buffLv", {BossBattleVoApi:getBossLv()}), 27, CCSizeMake(200, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        bossLv:setAnchorPoint(ccp(0.5, 1))
        bossLv:setPosition(self.BossMainSP:getContentSize().width - 100, bossH)
        self.BossMainSP:addChild(bossLv)
        
        bossH = bossH - bossLv:getContentSize().height - 5
        
        local lineSP = CCSprite:createWithSpriteFrameName("LineCross.png");
        lineSP:setAnchorPoint(ccp(0.5, 0.5))
        lineSP:setScaleX(200 / lineSP:getContentSize().width)
        lineSP:setScaleY(1.2)
        lineSP:setPosition(ccp(self.BossMainSP:getContentSize().width - 100, bossH))
        self.BossMainSP:addChild(lineSP, 2)
        
        bossH = bossH - 5
        
        local landLb = GetTTFLabelWrap(getlocal("BossBattle_ground"), 27, CCSizeMake(200, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        landLb:setAnchorPoint(ccp(0.5, 1))
        landLb:setPosition(self.BossMainSP:getContentSize().width - 100, bossH)
        self.BossMainSP:addChild(landLb)
        
        bossH = bossH - landLb:getContentSize().height - 10
        
        local gType = BossBattleVoApi:getBossGround()
        local function showGroundDetail()
            if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if newGuidMgr:isNewGuiding() == true then
                    do return end
                end
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                if(gType)then
                    local tabStr = {}
                    local tabColor = {}
                    local td = smallDialog:new()
                    local attackCfg = worldGroundCfg[gType]
                    for k, v in pairs(attackCfg.attType) do
                        local valueStr
                        if(attackCfg.attValue[k] > 0)then
                            valueStr = "+"..attackCfg.attValue[k]
                            table.insert(tabColor, 1, G_ColorGreen)
                        else
                            valueStr = attackCfg.attValue[k]
                            table.insert(tabColor, 1, G_ColorRed)
                        end
                        table.insert(tabColor, 1, G_ColorWhite)
                        table.insert(tabStr, 1, getlocal("world_ground_effect_"..v) .. " "..valueStr.."%")
                        table.insert(tabStr, 1, "\n")
                    end
                    local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 25, tabColor, getlocal("world_ground_name_"..gType))
                    sceneGame:addChild(dialog, self.layerNum + 1)
                else
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("world_ground_no_ground"), 30)
                end
            end
            
        end
        local landSp
        if(gType == nil)then
            landSp = LuaCCSprite:createWithSpriteFrameName("world_ground_0.png", showGroundDetail)
        else
            landSp = LuaCCSprite:createWithSpriteFrameName("world_ground_"..gType..".png", showGroundDetail)
        end
        landSp:setAnchorPoint(ccp(0.5, 1))
        landSp:setPosition(self.BossMainSP:getContentSize().width - 100, bossH)
        landSp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
        self.BossMainSP:addChild(landSp)
        
        local lineSP1 = CCSprite:createWithSpriteFrameName("LineCross.png");
        lineSP1:setAnchorPoint(ccp(0.5, 0.5))
        lineSP1:setScaleX(200 / lineSP1:getContentSize().width)
        lineSP1:setScaleY(1.2)
        lineSP1:setPosition(ccp(self.BossMainSP:getContentSize().width - 100, bossH - 60))
        self.BossMainSP:addChild(lineSP1, 2)
        
        local function clickHandler()
            if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if newGuidMgr:isNewGuiding() == true then
                    do return end
                end
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                if self:checkNoTroops() == false then
                    do return end
                end
                local isLive = 0
                if BossBattleVoApi:getAttackTime() and BossBattleVoApi:getAttackTime() > 0 and (base.serverTime - BossBattleVoApi:getAttackTime()) <= bossCfg.reBornTime then
                    isLive = 1
                end
                local function attakcCallback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        if BossBattleVoApi:getAttackTime() and BossBattleVoApi:getAttackTime() > 0 and (base.serverTime - BossBattleVoApi:getAttackTime()) <= bossCfg.reBornTime then
                            playerVoApi:setGems(playerVoApi:getGems() - bossCfg.reBorn)
                        end
                        if sData.data.worldboss then
                            self:attakcCallback(sData.data.worldboss)
                        end
                        if sData.data.report then
                            local attackData = {data = sData.data, isAttacker = true, isReport = false, destoryPaotou = self.destoryPaotou}
                            if self.selectMyselfAttack == 1 then
                                BossBattleVoApi:getHurtNumAndMuzzle(attackData)
                            else
                                BossBattleScene:initData(attackData)
                            end
                        end
                        
                        -- activityAndNoteDialog:closeAllDialog()
                    end
                end
                if isLive == 1 then
                    if playerVoApi:getGems() < bossCfg.reBorn then
                        local function closeHandler(...)
                            activityAndNoteDialog:closeAllDialog()
                        end
                        GemsNotEnoughDialog(nil, nil, bossCfg.reBorn - playerVoApi:getGems(), self.layerNum + 1, bossCfg.reBorn, closeHandler)
                        do return end
                    end
                    local function onConfirm(...)
                        socketHelper:BossBattleAttack(isLive, attakcCallback)
                    end
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("BossBattle_toLiveConfirm", {bossCfg.reBorn}), nil, self.layerNum + 1)
                else
                    socketHelper:BossBattleAttack(isLive, attakcCallback)
                end
            end
        end
        self.btnItem = GetButtonItem("BtnCancleSmall.png", "BtnCancleSmall_Down.png", "BtnCancleSmall.png", clickHandler, nil, getlocal("tankAtk"), 25, 111)
        local menu = CCMenu:createWithItem(self.btnItem);
        menu:setTouchPriority(-(self.layerNum - 1) * 20 - 3);
        menu:setPosition(ccp(self.BossMainSP:getContentSize().width - 100, 200))
        self.BossMainSP:addChild(menu)
        
        self.liveLb = GetTTFLabelWrap("", 25, CCSizeMake(self.BossMainSP:getContentSize().width / 2 + 100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        self.liveLb:setAnchorPoint(ccp(1, 0))
        self.liveLb:setPosition(self.BossMainSP:getContentSize().width, 80)
        self.BossMainSP:addChild(self.liveLb, 5)
        
        local capInSet = CCRect(20, 20, 10, 10);
        local function nilFunc(hd, fn, idx)
        end
        self.titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png", capInSet, nilFunc)
        self.titleBg:setScaleX(self.liveLb:getContentSize().width / self.titleBg:getContentSize().width)
        self.titleBg:setScaleY((self.liveLb:getContentSize().height + 20) / self.titleBg:getContentSize().height)
        self.titleBg:setAnchorPoint(ccp(1, 0))
        self.titleBg:setPosition(ccp(self.BossMainSP:getContentSize().width, 70))
        self.BossMainSP:addChild(self.titleBg, 2)
        
        local paotouNum = tonumber(BossBattleVoApi:getBossNowHp()) / tonumber(BossBattleVoApi:getBossMaxHp()) * 6
        AddProgramTimer(self.BossMainSP, ccp(self.BossMainSP:getContentSize().width / 2 - 50, 40), 111, 12, "", "VipIconYellowBarBg.png", "VipIconYellowBar.png", 131, 1, 1)
        --local per = tonumber(BossBattleVoApi:getBossNowHp())/tonumber(BossBattleVoApi:getBossMaxHp()) * 100
        local per = (paotouNum - math.floor(paotouNum)) * 100
        if tonumber(BossBattleVoApi:getBossNowHp()) > 0 and per == 0 then
            per = 100
        end
        self.timerSpriteLv = self.BossMainSP:getChildByTag(111)
        self.timerSpriteLv = tolua.cast(self.timerSpriteLv, "CCProgressTimer")
        self.timerSpriteLv:setPercentage(per)
        --self.timerSpriteLv:setScaleX((self.BossMainSP:getContentSize().width-40)/self.timerSpriteLv:getContentSize().width)
        
        self.perLb = tolua.cast(self.timerSpriteLv:getChildByTag(12), "CCLabelTTF")
        self.perLb:setString(getlocal("scheduleChapter", {BossBattleVoApi:getBossNowHp(), BossBattleVoApi:getBossMaxHp()}))
        
        --self.perLb=GetTTFLabel(BossBattleVoApi:getBossNowHp().."/"..BossBattleVoApi:getBossMaxHp(),25)
        -- timerSpriteLv:setRotation(-90)
        self.timerSpritebg = self.BossMainSP:getChildByTag(131)
        self.timerSpritebg:setVisible(true)
        -- bg:setRotation(-90)
        --self.timerSpritebg:setScaleX((self.BossMainSP:getContentSize().width-40)/self.timerSpritebg:getContentSize().width)
        
        self.bossPaotouLb = GetTTFLabel("x"..math.ceil(paotouNum), 50)
        self.bossPaotouLb:setAnchorPoint(ccp(1, 0.5))
        self.bossPaotouLb:setPosition(self.BossMainSP:getContentSize().width - 60, 45)
        self.BossMainSP:addChild(self.bossPaotouLb)
        
        h = h - self.BossMainSP:getContentSize().height - 10
        
        local function nilFun()
        end
        local capInSet = CCRect(20, 20, 10, 10);
        local buffSP = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png", capInSet, nilFun)
        buffSP:setContentSize(CCSizeMake(cell:getContentSize().width - 20, 300))
        buffSP:setAnchorPoint(ccp(0.5, 1))
        buffSP:setPosition(cell:getContentSize().width / 2, h)
        cell:addChild(buffSP)
        
        local buffLine = CCSprite:createWithSpriteFrameName("LineCross.png");
        buffLine:setAnchorPoint(ccp(0.5, 0.5))
        buffLine:setScaleX(buffSP:getContentSize().width / buffLine:getContentSize().width)
        buffLine:setScaleY(1.2)
        buffLine:setPosition(ccp(buffSP:getContentSize().width / 2, buffSP:getContentSize().height / 2))
        buffSP:addChild(buffLine, 2)
        
        local buffCfg = bossCfg.buffSkill
        local len = SizeOfTable(buffCfg)
        
        for i = 1, len do
            local buffId = "b"..i
            local buffData = buffCfg[buffId]
            local posX = 10 + ((i - 1) % 2) * (buffSP:getContentSize().width - 20) / 2
            local posY = buffSP:getContentSize().height - math.floor((i - 1) / 2) * 140 - 80
            local function buyBuff(object, name, tag)
                if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                    if newGuidMgr:isNewGuiding() == true then
                        do return end
                    end
                    if G_checkClickEnable() == false then
                        do
                            return
                        end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    local function updateCallback(...)
                        if self.tv then
                            self.tv:reloadData()
                        end
                    end
                    BossBuyBuffDialog:createWithBuffId(i, self.layerNum + 1, updateCallback)
                end
                
            end
            local icon = LuaCCSprite:createWithSpriteFrameName(buffData.icon, buyBuff)
            icon:setAnchorPoint(ccp(0, 0.5))
            icon:setPosition(posX, posY)
            icon:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
            buffSP:addChild(icon)
            
            local buffSize = 25
            if G_getCurChoseLanguage() == "de" then
                buffSize = 20
            end
            
            local buffName = GetTTFLabelWrap(getlocal(buffData.name), buffSize, CCSizeMake(150, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            buffName:setAnchorPoint(ccp(0, 1))
            buffName:setPosition(posX + icon:getContentSize().width + 10, posY + 50)
            buffSP:addChild(buffName)
            
            local buffLv = tonumber(BossBattleVoApi:getBattlefieldUser()[buffId])
            
            local buffLvLb = GetTTFLabelWrap(getlocal("buffLv", {buffLv}), 25, CCSizeMake(180, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            buffLvLb:setAnchorPoint(ccp(0, 0))
            buffLvLb:setPosition(posX + icon:getContentSize().width + 10, posY - 60)
            buffSP:addChild(buffLvLb)
            
            -- local buffDesc = GetTTFLabelWrap(getlocal(buffData.des,{buffData["per"]*100}),25,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            -- buffDesc:setAnchorPoint(ccp(0,0))
            -- buffDesc:setPosition(posX+icon:getContentSize().width+10,posY-50)
            -- buffSP:addChild(buffDesc)
            
        end
        self:refresh()
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end

function BossBattleDialogTab1:checkNoTroops()
    local isEableAttack = true
    local num = 0;
    for k, v in pairs(BossBattleVoApi:getBossTroops()) do
        if SizeOfTable(v) == 0 then
            num = num + 1;
        end
    end
    if num == 6 or SizeOfTable(BossBattleVoApi:getBossTroops()) == 0 then
        isEableAttack = false
    end
    if isEableAttack == false then
        self:updateSelect()
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("arena_noTroops"), nil, self.layerNum + 1, nil)
    end
    return isEableAttack
end

function BossBattleDialogTab1:updateSelect()
    if self.selectMyselfAttack == 1 then
        self.selectMyselfAttack = 0
    end
end

function BossBattleDialogTab1:refresh()
    local bossState, leftTime = BossBattleVoApi:getBossState()
    if bossState == 3 then --boss战进行中
        if self.bossState ~= bossState then
            local function onRequestEnd(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    self.bossState = bossState
                    if sData and sData.data and sData.data.worldboss then
                        BossBattleVoApi:onRefreshData(sData.data.worldboss)
                        if self and self.tv then
                            self.tv:reloadData()
                            do return end
                        end
                    end
                end
            end
            socketHelper:BossBattleInfo(onRequestEnd)
        end
        if self.BossMainSP and self.bossTankIcon then
            local bossNowHp = BossBattleVoApi:getBossNowHp()
            if bossNowHp < self.bossHp then
                local damage = self.bossHp - bossNowHp
                self.bossHp = bossNowHp
                self.subLifeLb = GetBMLabel(-damage, G_FontSrc, 20)
                self.subLifeLb:setAnchorPoint(ccp(0.5, 0.5))
                self.subLifeLb:setPosition(self.BossMainSP:getContentSize().width / 4 + 50, 230)
                self.BossMainSP:addChild(self.subLifeLb)
                
                local function subMvEnd()
                    if self.subLifeLb then
                        self.subLifeLb:removeFromParentAndCleanup(true)
                        self.subLifeLb = nil
                    end
                end
                local subMvTo = CCMoveTo:create(0.2, ccp(self.BossMainSP:getContentSize().width / 4 + 50, 230))
                local delayTime = CCDelayTime:create(0.3)
                local subMvTo2 = CCMoveTo:create(0.4, ccp(self.BossMainSP:getContentSize().width / 4 + 50, 310))
                local subfunc = CCCallFuncN:create(subMvEnd);
                local fadeOut = CCFadeTo:create(0.4, 0)
                local fadeArr = CCArray:create()
                fadeArr:addObject(subMvTo2)
                fadeArr:addObject(fadeOut)
                local spawn = CCSpawn:create(fadeArr)
                local acArr = CCArray:create()
                acArr:addObject(subMvTo)
                local wzScaleTo = CCScaleTo:create(0.2, 1.5)
                local wzScaleBack = CCScaleTo:create(0.2, 1.1)
                acArr:addObject(wzScaleTo)
                acArr:addObject(wzScaleBack)
                acArr:addObject(delayTime)
                acArr:addObject(spawn)
                acArr:addObject(subfunc)
                local subseq = CCSequence:create(acArr)
                self.subLifeLb:runAction(subseq)
                
            end
        end
        if self.maskLb then
            self.maskLb:setVisible(false)
        end
        if self.iconMask then
            self.iconMask:setVisible(false)
        end
        
        if self.timerSpriteLv and self.timerSpritebg then
            self.timerSpriteLv:setVisible(true)
            self.timerSpritebg:setVisible(true)
            
            local paotouNum = tonumber(BossBattleVoApi:getBossNowHp()) / tonumber(BossBattleVoApi:getBossMaxHp()) * 6
            local per = (paotouNum - math.floor(paotouNum)) * 100
            if tonumber(BossBattleVoApi:getBossNowHp()) > 0 and per == 0 then
                per = 100
            end
            -- local per = tonumber(BossBattleVoApi:getBossNowHp())/tonumber(BossBattleVoApi:getBossMaxHp()) * 100
            self.timerSpriteLv:setPercentage(per)
            
            self.perLb:setString(getlocal("scheduleChapter", {BossBattleVoApi:getBossNowHp(), BossBattleVoApi:getBossMaxHp()}))
            if self.bossPaotouLb then
                self.bossPaotouLb:setVisible(true)
            end
            self.bossPaotouLb:setString("x"..math.ceil(paotouNum))
        end
        if self.CDTime then
            self.CDTime:setString(getlocal("BossBattle_bossEndTime", {G_getTimeStr(leftTime)}))
        end
        if self.btnItem then
            self.btnItem:setVisible(true)
        end
        if BossBattleVoApi:getAttackTime() and BossBattleVoApi:getAttackTime() > 0 and (base.serverTime - BossBattleVoApi:getAttackTime()) <= bossCfg.reBornTime then
            if self.liveLb then
                self.liveLb:setVisible(true)
                local btnLb = tolua.cast(self.btnItem:getChildByTag(111), "CCLabelTTF")
                btnLb:setString(getlocal("BossBattle_toLiveBtn"))
                self.liveLb:setString(getlocal("BossBattle_toLive", {G_getTimeStr(bossCfg.reBornTime - (base.serverTime - BossBattleVoApi:getAttackTime()))}))
            end
            if self.titleBg then
                self.titleBg:setScaleX(self.liveLb:getContentSize().width / self.titleBg:getContentSize().width)
                self.titleBg:setScaleY((self.liveLb:getContentSize().height + 20) / self.titleBg:getContentSize().height)
                self.titleBg:setVisible(true)
            end
        else
            
            if self.titleBg then
                self.titleBg:setVisible(false)
            end
            if self.liveLb then
                self.liveLb:setVisible(false)
                local btnLb = tolua.cast(self.btnItem:getChildByTag(111), "CCLabelTTF")
                btnLb:setString(getlocal("tankAtk"))
            end
            if self.selectMyselfAttack == 1 then
                self:checkNoTroops()
                local function attakcCallback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        if sData.data.worldboss then
                            self:attakcCallback(sData.data.worldboss)
                        end
                    else
                        local function onRequestEnd(fn, data)
                            local ret, sData = base:checkServerData(data)
                            if ret == true then
                                if sData and sData.data and sData.data.worldboss then
                                    if self and self.bgLayer then
                                        BossBattleVoApi:onRefreshData(sData.data.worldboss)
                                        self.bossState = BossBattleVoApi:getBossState()
                                        if self.tv then
                                            self.tv:reloadData()
                                        end
                                    end
                                end
                            end
                        end
                        socketHelper:BossBattleInfo(onRequestEnd)
                    end
                end
                socketHelper:BossBattleAttack(0, attakcCallback)
                self.btnItem:setVisible(false)
            end
        end
    else
        if self.bossPaotouLb then
            self.bossPaotouLb:setVisible(false)
        end
        if self.timerSpriteLv then
            self.timerSpriteLv:setVisible(false)
            self.timerSpritebg:setVisible(false)
        end
        if self.liveLb then
            self.liveLb:setVisible(false)
        end
        if self.titleBg then
            self.titleBg:setVisible(false)
        end
        if self.btnItem then
            self.btnItem:setVisible(false)
        end
        if self.iconMask then
            self.iconMask:setVisible(true)
        end
        if bossState == 2 then--boss战即将开始
            if self.maskLb then
                self.maskLb:setVisible(true)
                self.maskLb:setString(getlocal("BossBattle_isComing"))
            end
            if self.CDTime then
                self.CDTime:setString(getlocal("BossBattle_bossStartTime", {G_getTimeStr(leftTime)}))
            end
        else
            if self.maskLb then
                self.maskLb:setVisible(true)
                self.maskLb:setString(getlocal("BossBattle_isDie"))
            end
            if self.CDTime then
                self.CDTime:setString(getlocal("BossBattle_bossComeTime", {G_getTimeStr(leftTime)}))
            end
        end
    end
end

function BossBattleDialogTab1:attakcCallback(data)
    
    if data then
        local params = {}
        local uid = playerVoApi:getUid()
        if data.boss then
            local bossData = data.boss
            local damage = 0
            if bossData[3] then
                damage = (bossData[3])
            end
            if damage >= 0 then
                params.damage = damage
                chatVoApi:sendUpdateMessage(15, params)
            end
        end
        BossBattleVoApi:onRefreshData(data)
        if self.tv then
            self.tv:reloadData()
        end
        self.destoryPaotou = BossBattleVoApi:getDestoryPaotouByHP((data.boss[2] - data.boss[3]), data.boss[5])
        if self.destoryPaotou and type(self.destoryPaotou) == "table" and SizeOfTable(self.destoryPaotou) > 0 then
            local isKill = false
            for k, v in pairs(self.destoryPaotou) do
                if bossCfg.paotou[v] == 6 then
                    isKill = true
                else
                    local paramTab = {}
                    paramTab.functionStr = "boss"
                    paramTab.addStr = "go_attack"
                    local message = {key = "BossBattle_destory_chatSystemMessage", param = {playerVoApi:getPlayerName(), getlocal("BossBattle_name")}}
                    chatVoApi:sendSystemMessage(message, paramTab)
                    local params = {key = "BossBattle_destory_chatSystemMessage", param = {{playerVoApi:getPlayerName(), 1}, {"BossBattle_name", 2}}}
                    chatVoApi:sendUpdateMessage(41, params)
                end
            end
            if isKill == true then
                local paramTab = {}
                paramTab.functionStr = "boss"
                paramTab.addStr = "go_attack"
                local message = {key = "BossBattle_kill_chatSystemMessage", param = {playerVoApi:getPlayerName(), getlocal("BossBattle_name")}}
                chatVoApi:sendSystemMessage(message, paramTab)
                local params = {key = "BossBattle_kill_chatSystemMessage", param = {{playerVoApi:getPlayerName(), 1}, {"BossBattle_name", 2}}}
                chatVoApi:sendUpdateMessage(41, params)
                
            end
        end
    end
end
function BossBattleDialogTab1:tick()
    if self then
        self:refresh()
    end
end

function BossBattleDialogTab1:dispose()
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/world_ground.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/world_ground.pvr.ccz")
    self.selectMyselfAttack = nil
    self.bgLayer = nil
    self.layerNum = nil
    self.bossHp = nil
    self.destoryPaotou = nil
    
end
