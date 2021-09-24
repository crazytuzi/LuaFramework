--require "luascript/script/componet/commonDialog"
buffStateDialog = {
    
}

function buffStateDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.expandIdx = {}
    self.layerNum = nil
    self.dialogLayer = nil
    self.bgLayer = nil
    self.closeBtn = nil
    self.bgSize = nil
    self.tv = nil
    self.expandHeight = G_VisibleSize.height - 140 + 102
    self.normalHeight = 120
    self.extendSpTag = 113
    self.timeLbTab = {}
    self.isCloseing = false
    self.buffTab = {}
    
    return nc
end

function buffStateDialog:init(layerNum)
    self.layerNum = layerNum
    base:setWait()
    
    local size = CCSizeMake(640, G_VisibleSize.height)
    
    self.isTouch = false
    self.isUseAmi = true
    if layerNum then
        self.layerNum = layerNum
    else
        self.layerNum = 4
    end
    local rect = size
    local function touchHander()
        
    end
    
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png", CCRect(168, 86, 10, 10), touchHander)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer = dialogBg
    self.bgSize = size
    self.bgLayer:setContentSize(size)
    
    local function touchDialog()
        
    end
    
    local function close()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png", "closeBtn_Down.png", "closeBtn_Down.png", close, nil, nil, nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0, 0))
    
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.closeBtn:setPosition(ccp(rect.width - closeBtnItem:getContentSize().width, rect.height - closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn)
    
    local titleLb = GetTTFLabel(getlocal("gainInformation"), 40)
    titleLb:setAnchorPoint(ccp(0.5, 0.5))
    titleLb:setPosition(ccp(size.width / 2, size.height - titleLb:getContentSize().height / 2 - 25))
    dialogBg:addChild(titleLb)
    
    local buygems = playerVoApi:getBuygems()
    if buygems == 0 then
        self.isFirstRecharge = true
    elseif buygems > 0 then
        self.isFirstRecharge = false
    end
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png", CCRect(168, 86, 10, 10), touchLuaSpr);
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, 960)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(0)
    touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(touchDialogBg, 1);
    
    self.bgLayer:setPosition(getCenterPoint(sceneGame))
    
    self:upgradeTab()
    
    self:initTableView()
    self.bgLayer:setPosition(CCPointMake(G_VisibleSize.width / 2, -self.bgLayer:getContentSize().height))
    sceneGame:addChild(self.bgLayer, self.layerNum)
    
    self:show()
    
    --return self.bgLayer
end

function buffStateDialog:upgradeTab()
    self.buffTab = {}
    for k, v in pairs(buffCfg) do
        -- if platCfg.platCfgBMImage[G_curPlatName()]~=nil  then
        --     if k~=2 and k~=3 then
        --         local tem=v
        --         self.buffTab[k]=tem
        --     end
        -- else
        local tem = G_clone(v) -- 拷贝一份不改动原配置文件
        self.buffTab[k] = tem
        -- end
    end
    
    for k, v in pairs(useItemSlotVoApi:getAllSlots()) do
        if propCfg["p"..v.id].buffType == 10 then
            local tb = {sid = "10", name = "buffDes10", icon = "Icon_precisionIncreased1.png", propId = "9", buyId = nil, time = "0", type = 10}
            table.insert(self.buffTab, tb)
        elseif propCfg["p"..v.id].buffType == 11 then
            local tb = {sid = "11", name = "buffDes11", icon = "Icon_dodgeIncrease1.png", propId = "9", buyId = nil, time = "0", type = 11}
            table.insert(self.buffTab, tb)
        elseif propCfg["p"..v.id].buffType == 12 then
            local tb = {sid = "12", name = "buffDes12", icon = "Icon_crit1.png", propId = "9", buyId = nil, time = "0", type = 12}
            table.insert(self.buffTab, tb)
        elseif propCfg["p"..v.id].buffType == 13 then
            local tb = {sid = "13", name = "buffDes13", icon = "Icon_armoredIncrease1.png", propId = "9", buyId = nil, time = "0", type = 13}
            table.insert(self.buffTab, tb)
        end
    end
    
    for k, v in pairs(self.buffTab) do
        local propId = tonumber(v.propId)
        local buffTb = useItemSlotVoApi:getAllSlots()
        for i, j in pairs(buffTb) do
            local ppid = "p"..i
            if propCfg[ppid].buffType == v.type then
                propId = i
                break
            end
        end
        
        local timeStr = useItemSlotVoApi:getLeftTimeById(tonumber(propId))
        if timeStr == nil then
            timeStr = 0
        end
        v.time = timeStr
    end
    local tab1 = {}
    local tab2 = {}
    for k, v in pairs(self.buffTab) do
        if v.time > 0 then
            local tem = v
            table.insert(tab1, tem)
        else
            local tem = v
            table.insert(tab2, tem)
        end
    end
    table.sort(tab1, function(a, b) return tonumber(a.sid) < tonumber(b.sid) end)
    table.sort(tab2, function(a, b) return tonumber(a.sid) < tonumber(b.sid) end)
    self.buffTab = {}
    for k, v in pairs(tab1) do
        table.insert(self.buffTab, v)
    end
    for k, v in pairs(tab2) do
        table.insert(self.buffTab, v)
    end
    self:closeAllCell()
    
end
function buffStateDialog:closeAllCell()
    local tab = {1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013}
    for k, v in pairs(tab) do
        if self.expandIdx["k" .. (v - 1000)] ~= nil then
            self.expandIdx["k" .. (v - 1000)] = nil
            self.tv:closeByCellIndex(v - 1000, self.expandHeight)
        end
    end
    
end

--设置对话框里的tableView
function buffStateDialog:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 10, self.bgLayer:getContentSize().height - 102), nil)
    self.bgLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(10, 20))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    base:addNeedRefresh(self)
    
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function buffStateDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return SizeOfTable(self.buffTab)
        
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize
        
        if self.expandIdx["k"..idx] ~= nil then
            tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 20, self.expandHeight)
        else
            tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 20, self.normalHeight)
        end
        
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        
        local cell = CCTableViewCell:new()
        cell:autorelease()
        self:loadCCTableViewCell(cell, idx)
        return cell
        
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end
--点击了cell或cell上某个按钮
function buffStateDialog:cellClick(idx)
    if self.tv == nil then
        do
            return
        end
    end
    if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
        PlayEffect(audioCfg.mouseClick)
        if self.expandIdx["k" .. (idx - 1000)] == nil then
            self.expandIdx["k" .. (idx - 1000)] = idx - 1000
            self.tv:openByCellIndex(idx - 1000, self.normalHeight)
        else
            --self.requires[idx-1000+1]:dispose()
            --self.requires[idx-1000+1]=nil
            --self.allCellsBtn[idx-1000+1]=nil
            self.expandIdx["k" .. (idx - 1000)] = nil
            self.tv:closeByCellIndex(idx - 1000, self.expandHeight)
        end
    end
end
--创建或刷新CCTableViewCell
function buffStateDialog:loadCCTableViewCell(cell, idx, refresh)
    local expanded = false
    if self.expandIdx["k"..idx] == nil then
        expanded = false
    else
        expanded = true
    end
    if expanded then
        cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 20, self.expandHeight))
    else
        cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 20, self.normalHeight))
    end
    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    local function cellClick(hd, fn, idx)
        local buffIdx = idx - 1000 + 1
        if self.buffTab[buffIdx].type >= 10 or self.buffTab[buffIdx].buyId == "" or self.buffTab[buffIdx].buyId == nil then
            do return end
        end
        return self:cellClick(idx)
    end
    local headerSprie = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png", capInSet, cellClick)
    headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 20, self.normalHeight - 4))
    headerSprie:ignoreAnchorPointForPosition(false);
    headerSprie:setAnchorPoint(ccp(0, 0));
    headerSprie:setTag(1000 + idx)
    headerSprie:setIsSallow(false)
    headerSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    headerSprie:setPosition(ccp(0, cell:getContentSize().height - headerSprie:getContentSize().height));
    cell:addChild(headerSprie)
    
    local iconSp = CCSprite:createWithSpriteFrameName(self.buffTab[idx + 1].icon)
    iconSp:setAnchorPoint(ccp(0, 0.5))
    iconSp:setPosition(ccp(10, headerSprie:getContentSize().height / 2))
    headerSprie:addChild(iconSp)
    
    local propId = tonumber(self.buffTab[idx + 1].propId)
    local buffTb = useItemSlotVoApi:getAllSlots()
    for k, v in pairs(buffTb) do
        local ppid = "p"..k
        if propCfg[ppid].buffType == self.buffTab[idx + 1].type then
            propId = k
            break
        end
    end
    local valueStr = ""
    if propCfg["p"..propId].buffValue ~= nil then
        valueStr = propCfg["p"..propId].buffValue.."%%"
    end
    local labelSize = CCSize(30 * 15, 50);
    local desLb = GetTTFLabelWrap(getlocal(self.buffTab[idx + 1].name, {valueStr}), 22, labelSize, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    desLb:setPosition(125, headerSprie:getContentSize().height / 2);
    desLb:setAnchorPoint(ccp(0, 0));
    headerSprie:addChild(desLb, 2)
    
    --local propId=tonumber(self.buffTab[idx+1].propId)
    
    local timeStr = useItemSlotVoApi:getLeftTimeById(propId)
    if timeStr ~= nil then
        local timeSp = CCSprite:createWithSpriteFrameName("IconTime.png");
        timeSp:setAnchorPoint(ccp(0, 0.5));
        timeSp:setPosition(120, 30)
        headerSprie:addChild(timeSp, 2)
        
        local iconSpBg = CCSprite:createWithSpriteFrameName("TimeBg.png")
        iconSpBg:setAnchorPoint(ccp(0, 0.5))
        iconSpBg:setPosition(ccp(175, 30))
        headerSprie:addChild(iconSpBg)
        
        local timeLb = GetTTFLabel(GetTimeForItemStrState(timeStr), 26)
        timeLb:setPosition(iconSpBg:getContentSize().width / 2, iconSpBg:getContentSize().height / 2)
        timeLb:setAnchorPoint(ccp(0.5, 0.5));
        timeLb:setColor(G_ColorYellow)
        iconSpBg:addChild(timeLb, 2)
        self.timeLbTab[propId] = timeLb
    end
    
    local btn
    if self.buffTab[idx + 1].type < 10 and self.buffTab[idx + 1].buyId ~= nil and self.buffTab[idx + 1].buyId ~= "" then
        
        if expanded == false then
            btn = CCSprite:createWithSpriteFrameName("moreBtn.png")
        else
            btn = CCSprite:createWithSpriteFrameName("lessBtn.png")
        end
        btn:setAnchorPoint(ccp(0, 0.5))
        btn:setPosition(ccp(headerSprie:getContentSize().width - 10 - btn:getContentSize().width, headerSprie:getContentSize().height / 2))
        headerSprie:addChild(btn)
        btn:setTag(self.extendSpTag)
        
    end
    
    if expanded == true then --显示展开信息
        
        local function touchHander()
            
        end
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(40, 40, 10, 10);
        local exBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemInforBg.png", capInSet, touchHander)
        exBg:setAnchorPoint(ccp(0, 0))
        exBg:setContentSize(CCSize(620, self.expandHeight - self.normalHeight))
        exBg:setPosition(ccp(0, 0))
        exBg:setTag(2)
        cell:addChild(exBg)
        local heightExBg = exBg:getContentSize().height
        local btype = Split(self.buffTab[idx + 1].buyId, ",")
        for k, v in pairs(btype) do
            self:exbgCellForId(tonumber(v), exBg, heightExBg - 200 * k)
        end
        
    end
    
end

function buffStateDialog:exbgCellForId(id, parent, m_height)
    
    local pid = "p"..id
    local lbName = GetTTFLabelWrap(getlocal(propCfg[pid].name), 26, CCSizeMake(26 * 12, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    lbName:setPosition(150, 160 + m_height)
    lbName:setAnchorPoint(ccp(0, 0.5));
    parent:addChild(lbName, 2)
    
    local lbNum = GetTTFLabel(getlocal("propHave")..bagVoApi:getItemNumId(id), 22)
    lbNum:setPosition(530, 23 + m_height + 10)
    lbNum:setAnchorPoint(ccp(0.5, 0.5));
    parent:addChild(lbNum, 2)
    
    local sprite = CCSprite:createWithSpriteFrameName(propCfg[pid].icon);
    sprite:setAnchorPoint(ccp(0, 0.5));
    sprite:setPosition(20, 120 + m_height)
    parent:addChild(sprite, 2)
    
    local labelSize = CCSize(300, 0);
    local lbDescription = GetTTFLabelWrap(getlocal(propCfg[pid].description), 22, labelSize, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    lbDescription:setPosition(130, 80 + m_height)
    lbDescription:setAnchorPoint(ccp(0, 0.5));
    parent:addChild(lbDescription, 2)
    
    local gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png");
    gemIcon:setPosition(ccp(510, 50 + m_height + 110));
    parent:addChild(gemIcon, 2)
    
    local lbPrice = GetTTFLabel(propCfg[pid].gemCost, 24)
    lbPrice:setPosition(gemIcon:getPositionX() + 30, gemIcon:getPositionY())
    lbPrice:setAnchorPoint(ccp(0, 0.5));
    parent:addChild(lbPrice, 2)
    
    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSprite:setAnchorPoint(ccp(0, 0.5));
    lineSprite:setPosition(20, m_height)
    parent:addChild(lineSprite, 2)
    
    if bagVoApi:getItemNumId(id) > 0 then
        local function touch1()
            PlayEffect(audioCfg.mouseClick)
            
            if self:useBuffItem(id) > 0 then
                do
                    return
                end
            end
            
            if id == 10 then
                
            end
            if newGuidMgr:isNewGuiding() then --新手引导
                if id == 21 then
                    newGuidMgr:toNextStep()
                end
            end
            if id == 15 or id == 16 or id == 14 or id == 45 or id == 46 then
                if playerVoApi:getPlayerLevel() < 3 then
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("needRoleLevel", {3}), nil, self.layerNum + 1)
                    do return end
                end
            end
            local function callbackUseProc(fn, data)
                --local retTb=OBJDEF:decode(data)
                if base:checkServerData(data) == true then
                    --统计使用物品
                    statisticsHelper:useItem(pid, 1)
                    if id == 14 or id == 45 or id == 46 then
                        worldScene:addProtect()
                    end
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("use_prop_success", {getlocal(propCfg[pid].name)}), 28)
                    self:upgradeTab()
                    self.tv:reloadData()
                    
                end
                
            end
            
            socketHelper:useProc(id, nil, callbackUseProc)
            
        end
        local menuItem1 = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", touch1, 11, getlocal("use"), 26)
        menuItem1:setScale(0.8)
        local menu1 = CCMenu:createWithItem(menuItem1);
        menu1:setPosition(ccp(530, 40 + m_height + 60));
        menu1:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
        parent:addChild(menu1, 3);
        
    else
        local function touch1()
            if id == 15 or id == 16 or id == 14 or id == 45 or id == 46 then
                if playerVoApi:getPlayerLevel() < 3 then
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("needRoleLevel", {3}), nil, self.layerNum + 1)
                    do return end
                end
            end
            
            local function touchBuy()
                local function callbackUseProc(fn, data)
                    --local retTb=OBJDEF:decode(data)
                    if base:checkServerData(data) == true then
                        --统计购买物品
                        statisticsHelper:buyItem(pid, propCfg[pid].gemCost, 1, propCfg[pid].gemCost)
                        --统计使用物品
                        statisticsHelper:useItem(pid, 1)
                        if id == 14 or id == 45 or id == 46 then
                            worldScene:addProtect()
                        end
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("use_prop_success", {getlocal(propCfg[pid].name)}), 28)
                        self:upgradeTab()
                        self.tv:reloadData()
                        
                    end
                    
                end
                
                socketHelper:useProc(id, 1, callbackUseProc)
            end
            
            local function buyGems()
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                end
                vipVoApi:showRechargeDialog(self.layerNum + 1)
                
            end
            if playerVo.gems < tonumber(propCfg[pid].gemCost) then
                local num = tonumber(propCfg[pid].gemCost) - playerVo.gems
                local smallD = smallDialog:new()
                smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), buyGems, getlocal("dialog_title_prompt"), getlocal("gemNotEnough", {tonumber(propCfg[pid].gemCost), playerVo.gems, num}), nil, self.layerNum + 1)
            else
                if self:useBuffItem(id) > 0 then
                    do
                        return
                    end
                end
                
                local smallD = smallDialog:new()
                smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), touchBuy, getlocal("dialog_title_prompt"), getlocal("prop_buy_tip", {propCfg[pid].gemCost, getlocal(propCfg[pid].name)}), nil, self.layerNum + 1)
            end
            
        end
        local menuItem1 = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", touch1, 11, getlocal("buyAndUse"), 25)
        menuItem1:setScale(0.8)
        local menu1 = CCMenu:createWithItem(menuItem1);
        menu1:setPosition(ccp(530, 40 + m_height + 60));
        menu1:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
        parent:addChild(menu1, 3);
        
    end
    
end

function buffStateDialog:tick()
    for k, v in pairs(self.timeLbTab) do
        local timeLb = v
        timeLb = tolua.cast(timeLb, "CCLabelTTF")
        if useItemSlotVoApi:getLeftTimeById(k) == nil then
            self.timeLbTab = {}
            self:upgradeTab()
            self.tv:reloadData()
            do
                return
            end
        end
        local timeStr = useItemSlotVoApi:getLeftTimeById(k)
        timeLb:setString(GetTimeForItemStrState(timeStr))
        
    end
end
function buffStateDialog:close()
    if self.isCloseing == true then
        do return end
    end
    if self.isCloseing == false then
        self.isCloseing = true
    end
    
    if hasAnim == nil then
        hasAnim = true
    end
    base.allShowedCommonDialog = base.allShowedCommonDialog - 1
    for k, v in pairs(base.commonDialogOpened_WeakTb) do
        if v == self then
            table.remove(base.commonDialogOpened_WeakTb, k)
            break
        end
    end
    if base.allShowedCommonDialog < 0 then
        base.allShowedCommonDialog = 0
    end
    if newGuidMgr:isNewGuiding() and (newGuidMgr.curStep == 9 or newGuidMgr.curStep == 46 or newGuidMgr.curStep == 17 or newGuidMgr.curStep == 35 or newGuidMgr.curStep == 42) then --新手引导
        newGuidMgr:toNextStep()
    end
    local function realClose()
        return self:realClose()
    end
    if base.allShowedCommonDialog == 0 and storyScene.isShowed == false then
        if portScene.clayer ~= nil then
            if sceneController.curIndex == 0 then
                portScene:setShow()
            elseif sceneController.curIndex == 1 then
                mainLandScene:setShow()
            elseif sceneController.curIndex == 2 then
                worldScene:setShow()
            end
            mainUI:setShow()
        end
    end
    base:removeFromNeedRefresh(self) --停止刷新
    local fc = CCCallFunc:create(realClose)
    local moveTo = CCMoveTo:create((hasAnim == true and 0.3 or 0), CCPointMake(G_VisibleSize.width / 2, -self.bgLayer:getContentSize().height))
    local acArr = CCArray:create()
    acArr:addObject(moveTo)
    acArr:addObject(fc)
    local seq = CCSequence:create(acArr)
    self.bgLayer:runAction(seq)
    
end

function buffStateDialog:useBuffItem(id)
    local isEnabledUse = 0 --1:已经有小的 覆盖使用 2:已有大的 不能使用 0:直接使用
    local pid = "p"..id
    local buffTb = useItemSlotVoApi:getAllSlots()
    for k, v in pairs(buffTb) do
        local ppid = "p"..k
        if propCfg[ppid].buffType ~= nil and propCfg[ppid].buffType < 6 and propCfg[pid].buffType == 6 then
            if propCfg[ppid].buffLevel < propCfg[pid].buffLevel then
                isEnabledUse = 1
                break
            elseif propCfg[ppid].buffLevel > propCfg[pid].buffLevel then
                isEnabledUse = 3
                break
            end
        elseif propCfg[ppid].buffType ~= nil and propCfg[ppid].buffType == propCfg[pid].buffType then
            if propCfg[ppid].buffLevel < propCfg[pid].buffLevel then
                isEnabledUse = 1
                break
            elseif propCfg[ppid].buffLevel > propCfg[pid].buffLevel then
                isEnabledUse = 2
                break
            end
        end
    end
    
    if isEnabledUse == 1 then
        local function sure()
            local function callbackUseProc1(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    local nameStr = getlocal(propCfg[pid].name)
                    local str = getlocal("use_prop_success", {nameStr})
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), str, 28)
                end
                
            end
            socketHelper:useProc(id, nil, callbackUseProc1, 1)
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), sure, getlocal("dialog_title_prompt"), getlocal("sureUseItem1"), nil, self.layerNum + 1)
        
    elseif isEnabledUse == 2 then
        local function sure()
            
        end
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("sureUseItem2"), nil, self.layerNum + 1)
    elseif isEnabledUse == 3 then
        local str = ""
        local keyTb = {"metal", "oil", "silicon", "uranium", "money"}
        for k, v in pairs(buffTb) do
            local ppid = "p"..k
            if propCfg[ppid].buffType < 6 then
                str = str..getlocal(keyTb[propCfg[ppid].buffType])
            end
        end
        local function sure()
            
        end
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("sureUseItem3", {str}), nil, self.layerNum + 1)
        
    end
    return isEnabledUse
    
end

function buffStateDialog:realClose()
    
    self.bgLayer:removeFromParentAndCleanup(true)
    self:dispose()
    
end
--显示面板,加效果
function buffStateDialog:show()
    local moveTo = CCMoveTo:create(0.3, CCPointMake(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    local function callBack()
        if portScene.clayer ~= nil then
            if sceneController.curIndex == 0 then
                portScene:setHide()
            elseif sceneController.curIndex == 1 then
                mainLandScene:setHide()
            elseif sceneController.curIndex == 2 then
                worldScene:setHide()
            end
            
            mainUI:setHide()
            --self:getDataByType() --只有Email使用这个方法
        end
        base:cancleWait()
    end
    base.allShowedCommonDialog = base.allShowedCommonDialog + 1
    table.insert(base.commonDialogOpened_WeakTb, self)
    local callFunc = CCCallFunc:create(callBack)
    local seq = CCSequence:createWithTwoActions(moveTo, callFunc)
    self.bgLayer:runAction(seq)
end
function buffStateDialog:dispose()
    self.expandIdx = nil
    self.layerNum = nil
    self.dialogLayer = nil
    self.bgLayer = nil
    self.closeBtn = nil
    self.bgSize = nil
    self.tv = nil
    self.expandHeight = nil
    self.normalHeight = nil
    self.extendSpTag = nil
    self.timeLbTab = nil
    self.buffTab = nil
    base:removeFromNeedRefresh(self) --停止刷新
    self = nil
    
end
