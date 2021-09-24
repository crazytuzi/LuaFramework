--require "luascript/script/componet/commonDialog"
-- require "luascript/script/game/gamemodel/shop/shopVoApi"
-- require "luascript/script/game/gamemodel/bag/bagVoApi"
propDialog = commonDialog:new()

function propDialog:new(layerNum, isGuide, jumpIdx)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.leftBtn = nil
    self.expandIdx = {}
    self.shoptabItem = {}
    self.shoptabItemType1 = {}
    self.shoptabItemType2 = {}
    self.shoptabItemType3 = {}
    self.isNewShowOnlyBag = true--新版显示，只用于背包
    self.shoptabItemBag = {}
    self.shoptabItemBagType1 = {}
    self.shoptabItemBagType2 = {}
    self.shoptabItemBagType3 = {}
    
    self.platShopItem = {}
    self.platShopItemType1 = {}
    self.platShopItemType2 = {}
    self.platShopItemType3 = {}
    self.layerNum = layerNum
    self.isGuide = isGuide
    self.itemCellIdx = nil
    self.focusCompoundItemId = nil
    self.jumpIdx = jumpIdx
    
    self.cellHight = nil
    self.addBtn = nil
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    spriteController:addPlist("public/datebaseShow.plist")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    return nc
end

--设置或修改每个Tab页签
function propDialog:resetTab()
    local subPosy = 160
    if self.isNewShowOnlyBag then
        self.panelLineBg:setContentSize(CCSizeMake(600, G_VisibleSize.height - 144))
        self.panelLineBg:setPositionY(self.panelLineBg:getPositionY() + 8)
        subPosy = 85
    end
    local index = 0
    local posTb
    if(#self.allTabs == 2)then
        posTb = {self.allTabs[1]:getContentSize().width / 2 + 20, self.allTabs[1]:getContentSize().width / 2 + 24 + self.allTabs[1]:getContentSize().width}
    elseif(#self.allTabs == 3)then
        posTb = {119, 320, 521}
    end
    for k, v in pairs(self.allTabs) do
        local tabBtnItem = v
        tabBtnItem:setPosition(posTb[k], self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 80)
        -- if index==self.selectedTabIndex then
        tabBtnItem:setEnabled(false)
        tabBtnItem:setVisible(false)
        -- end
        index = index + 1
    end
    
    local indexSub = 0
    for k, v in pairs(self.allSubTabs) do
        local tabBtnItem = v
        
        if indexSub == 0 then
            tabBtnItem:setPosition(100, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - subPosy)
        elseif indexSub == 1 then
            tabBtnItem:setPosition(248, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - subPosy)
        elseif indexSub == 2 then
            tabBtnItem:setPosition(394, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - subPosy)
        elseif indexSub == 3 then
            tabBtnItem:setPosition(540, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - subPosy)
            
        end
        
        local numBgW, numBgH = 36, 36
        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png", CCRect(17, 17, 1, 1), function()end)
        local numLb = GetTTFLabel("00", 25)
        if numLb:getContentSize().width + 10 > numBgW then
            numBgW = numLb:getContentSize().width + 10
        end
        numBg:setContentSize(CCSizeMake(numBgW, numBgH))
        numLb:setPosition(numBg:getContentSize().width / 2, numBg:getContentSize().height / 2)
        numLb:setTag(100)
        numBg:addChild(numLb)
        numBg:setAnchorPoint(ccp(1, 1))
        numBg:setPosition(tabBtnItem:getContentSize().width + 3, tabBtnItem:getContentSize().height + 3)
        numBg:setScale(30 / 40)
        numBg:setTag(100)
        tabBtnItem:addChild(numBg)
        numBg:setVisible(false)
        
        local tipIcon = CCSprite:createWithSpriteFrameName("IconTip.png")
        tipIcon:setAnchorPoint(ccp(1, 1))
        tipIcon:setPosition(tabBtnItem:getContentSize().width + 3, tabBtnItem:getContentSize().height + 3)
        tipIcon:setScale(30 / 40)
        tipIcon:setTag(101)
        tabBtnItem:addChild(tipIcon)
        tipIcon:setVisible(false)
        
        if indexSub == self.selectedSubTabIndex then
            tabBtnItem:setEnabled(false)
        end
        indexSub = indexSub + 1
    end
    self.selectedSubTabIndex = 10
end

function propDialog:getType(_subTabIndex)
    if _subTabIndex == 10 then
        return 2
    elseif _subTabIndex == 11 then
        return 1
    elseif _subTabIndex == 12 then
        return 3
    elseif _subTabIndex == 13 then
        return 4
    end
end

--设置对话框里的tableView
function propDialog:initTableView()
    
    local subHeight = 150
    if self.isNewShowOnlyBag then
        subHeight = 85
    end
    local function callBack(...)
        return self:eventHandler(...)
    end
    self.shoptabItem = shopVoApi:getShopItemByType(2)
    self.shoptabItemType1 = shopVoApi:getShopItemByType(1)
    self.shoptabItemType2 = shopVoApi:getShopItemByType(3)
    self.shoptabItemType3 = shopVoApi:getShopItemByType(4)
    
    self.shoptabItemBag = bagVoApi:getShopItemByType(2)
    self.shoptabItemBagType1 = bagVoApi:getShopItemByType(1)
    self.shoptabItemBagType2 = bagVoApi:getShopItemByType(3)
    self.shoptabItemBagType3 = bagVoApi:getShopItemByType(4)
    
    self.platShopItem = shopVoApi:getPlatShopItemByType(2)
    self.platShopItemType1 = shopVoApi:getPlatShopItemByType(1)
    self.platShopItemType2 = shopVoApi:getPlatShopItemByType(3)
    self.platShopItemType3 = shopVoApi:getPlatShopItemByType(4)
    
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 10, self.bgLayer:getContentSize().height - 85 - subHeight), nil)
    self.bgLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(30, 20))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    
    if self.selectedTabIndex == 0 and self.selectedSubTabIndex == 10 then
        for k, v in pairs(self.allSubTabs) do
            local numBg = tolua.cast(v:getChildByTag(100), "CCSprite")
            local numLb = tolua.cast(numBg:getChildByTag(100), "CCLabelTTF")
            local tipIcon = tolua.cast(v:getChildByTag(101), "CCSprite")
            numBg:setVisible(false)
            tipIcon:setVisible(false)
            local _type = self:getType(v:getTag())
            local num = bagVoApi:getItemRedPointNumByType(_type)
            if num > 0 then
                if num > bagVoApi.redPointMaxNum then
                    num = "···"
                end
                numLb:setString(tostring(num))
                numBg:setVisible(true)
                tipIcon:setVisible(false)
            else
                local tipVisible, _id = bagVoApi:isCompound(_type)
                tipIcon:setVisible(tipVisible)
                if tipVisible == true then
                    self.focusCompoundItemId = _id
                end
            end
        end
    end
    self._prevSelectSubTabIndex = self.selectedSubTabIndex
    
    if self.isGuide == true then
        -- G_addFlicker(self.bgLayer,4.3,4.3,ccp(530,G_VisibleSizeHeight-350))
    end
    
    local function dialogListener(event, data)
        if self then
            self:refreshBag()
        end
    end
    self.dialogListener = dialogListener
    eventDispatcher:addEventListener("prop.dialog.useProp", self.dialogListener)
    
    self:recordPoint()
    if self.jumpIdx then
        self:tabSubClick(self.jumpIdx)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function propDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        if self.selectedTabIndex == 0 then
            local tabItem
            
            if self.selectedSubTabIndex == 10 then
                tabItem = self.shoptabItemBag
            elseif self.selectedSubTabIndex == 11 then
                tabItem = self.shoptabItemBagType1
            elseif self.selectedSubTabIndex == 12 then
                tabItem = self.shoptabItemBagType2
            elseif self.selectedSubTabIndex == 13 then
                tabItem = self.shoptabItemBagType3
            end
            
            return SizeOfTable(tabItem)
        elseif self.selectedTabIndex == 1 then
            local tabItem
            
            if self.selectedSubTabIndex == 10 then
                tabItem = self.shoptabItem
            elseif self.selectedSubTabIndex == 11 then
                tabItem = self.shoptabItemType1
            elseif self.selectedSubTabIndex == 12 then
                tabItem = self.shoptabItemType2
            elseif self.selectedSubTabIndex == 13 then
                tabItem = self.shoptabItemType3
            end
            return SizeOfTable(tabItem)
        elseif self.selectedTabIndex == 2 then
            local tabItem
            if(self.selectedSubTabIndex == 10)then
                tabItem = self.platShopItem
            elseif(self.selectedSubTabIndex == 11)then
                tabItem = self.platShopItemType1
            elseif(self.selectedSubTabIndex == 12)then
                tabItem = self.platShopItemType2
            elseif(self.selectedSubTabIndex == 13)then
                tabItem = self.platShopItemType3
            end
            return SizeOfTable(tabItem)
        end
        
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize
        self.cellHight = 180
        if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() == "ja" then
            self.cellHight = 180
        end
        tmpSize = CCSizeMake(400, self.cellHight)
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd, fn, idx)
            --   return self:cellClick(idx)
        end
        local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, cellClick)
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, self.cellHight - 4))
        backSprie:ignoreAnchorPointForPosition(false);
        backSprie:setAnchorPoint(ccp(0, 0));
        backSprie:setTag(1000 + idx)
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        
        local tabItem;
        if self.selectedTabIndex == 0 then
            local tabItem
            
            if self.selectedSubTabIndex == 10 then
                tabItem = self.shoptabItemBag
            elseif self.selectedSubTabIndex == 11 then
                tabItem = self.shoptabItemBagType1
            elseif self.selectedSubTabIndex == 12 then
                tabItem = self.shoptabItemBagType2
            elseif self.selectedSubTabIndex == 13 then
                tabItem = self.shoptabItemBagType3
            end
            
            local m_index = tabItem[idx + 1].id
            
            if bagVoApi:isNewAdd(m_index) or self.focusCompoundItemId == m_index then
                local highligtBg = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png", CCRect(20, 20, 10, 10), function()end)
                highligtBg:setContentSize(backSprie:getContentSize())
                highligtBg:setAnchorPoint(ccp(0, 0))
                backSprie:addChild(highligtBg)
                if self.itemCellIdx == nil then
                    self.itemCellIdx = idx
                end
            end
            
            local pid = "p"..m_index
            
            local lbNameFontSize = 24
            local adaHeight = 0
            if not G_isAsia() then
                lbNameFontSize = 20
                if pid == "p5109" or pid == "p5110" or pid == "p5111" then
                    lbNameFontSize = 18
                    adaHeight = 10
                end
            end
            --特定道具将领魂石箱爆框
            if pid == "p4214" and not G_isAsia() then
                lbNameFontSize = 20
                adaHeight = 20
            end
            local lbName = GetTTFLabelWrap(getlocal(propCfg[pid].name), lbNameFontSize, CCSizeMake(290, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
            lbName:setColor(G_ColorGreen)
            lbName:setPosition(130, self.cellHight - 55 + adaHeight)
            lbName:setAnchorPoint(ccp(0, 0.5));
            cell:addChild(lbName, 2)
            -- local lbNum=GetTTFLabel(getlocal("propHave")..tabItem[idx+1].num,22)
            local lbNum = GetTTFLabel(getlocal("propOwned")..tabItem[idx + 1].num, 20)
            lbNum:setPosition(20, 24)
            lbNum:setAnchorPoint(ccp(0, 0.5));
            cell:addChild(lbNum, 2)
            
            local function touch()
            end
            local sprite = bagVoApi:getItemIcon(pid)
            sprite:setAnchorPoint(ccp(0, 0.5));
            sprite:setPosition(20, self.cellHight / 2)
            cell:addChild(sprite, 2)
            if propCfg[pid].rolelevel ~= nil then
                if playerVoApi:getPlayerLevel() >= propCfg[pid].rolelevel then
                    G_addRectFlicker(sprite, 1.3, 1.3, getCenterPoint(sprite))
                end
            end
            local strSize3 = 20
            if G_getCurChoseLanguage() == "ru" or G_getCurChoseLanguage() == "de" then
                strSize3 = 18
                if lbName then
                    lbName:setPositionY(lbName:getPositionY() + 8)
                end
            end
            local labelSize = CCSizeMake(290, self.cellHight - 60);
            local id = tonumber(pid) or tonumber(RemoveFirstChar(pid))
            -- local descStr = (id > 4823 and id < 4828) and getlocal(propCfg[pid].description,{propCfg[pid].composeGetProp[1]}) or getlocal(propCfg[pid].description)
            local descStr
            if (id > 4819 and id < 4828) or (propCfg[pid] and propCfg[pid].composeGetProp) then
                descStr = getlocal(propCfg[pid].description, {propCfg[pid].composeGetProp[1]})
            else
                descStr = getlocal(propCfg[pid].description)
            end
            local lbDescription = GetTTFLabelWrap(descStr, strSize3, labelSize, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            lbDescription:setPosition(130, (self.cellHight - 60) / 2 + adaHeight / 2)
            lbDescription:setAnchorPoint(ccp(0, 0.5));
            cell:addChild(lbDescription, 2)
            
            local function canUseProps(tag, object, num)
                --间谍雷达
                if self:useBuffItem(tag, idx) > 1 then
                    do return end
                end
                
                if tag == 409 then
                    self:close()
                    smallDialog:showSearchForDialog(self.layerNum + 1)
                    
                    do
                        return
                    end
                end
                
                if tag == 1030 or tag == 1031 or tag == 1032 or tag == 1033 then
                    
                    if propCfg["p"..tag].rolelevel > playerVoApi:getPlayerLevel() then
                        do
                            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("needRoleLevel", {propCfg["p"..tag].rolelevel}), nil, self.layerNum + 1)
                            do return end
                        end
                    end
                end
                
                if tag == 15 or tag == 16 or tag == 14 or tag == 45 or tag == 46 then
                    if playerVoApi:getPlayerLevel() < 3 then
                        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("needRoleLevel", {3}), nil, self.layerNum + 1)
                        do return end
                    end
                end
                if propCfg["p"..tag].rolelevel ~= nil then
                    if playerVoApi:getPlayerLevel() < propCfg["p"..tag].rolelevel then
                        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("needRoleLevel", {propCfg["p"..tag].rolelevel}), nil, self.layerNum + 1)
                        do return end
                    end
                end
                
                -- 配件掉落，判断仓库容量是否足够
                if accessoryVoApi.dataNeedRefresh == false then
                    if propCfg[pid].aDropMaxNum then
                        local leftABagNum = accessoryVoApi:getABagLeftGrid()
                        local needNum = propCfg[pid].aDropMaxNum
                        if num then
                            needNum = needNum * num
                        end
                        if leftABagNum and (leftABagNum - needNum < 0) then
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("accessory_bag_full"), 28)
                            do return end
                        end
                    end
                    if propCfg[pid].fDropTypeMaxNum then
                        if accessoryVoApi:getFragmentByID(propCfg[pid].Aid) == nil then
                            local leftFBagNum = accessoryVoApi:getFBagLeftGrid()
                            local needNum = propCfg[pid].fDropTypeMaxNum
                            if leftFBagNum and (leftFBagNum - needNum < 0) then
                                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("accessory_bag_full"), 28)
                                do return end
                            end
                        end
                    end
                end
                return true
            end
            local function usePropsCallback(tag, object, num)
                -- if self.tv:getIsScrolled()==true then
                --     return
                -- end
                -- PlayEffect(audioCfg.mouseClick)
                --间谍雷达
                if self:useBuffItem(tag, idx, true, num) > 0 then
                    do return end
                end
                
                if tag == 15 then
                    
                    local function baseChangeother()
                        if SizeOfTable(attackTankSoltVoApi:getAllAttackTankSlots()) > 0 then
                            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("randomMoveIslandError1"), nil, self.layerNum + 1)
                            do
                                return
                            end
                        end
                        
                        if helpDefendVoApi:isHasArrive() then
                            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("backstage2007"), nil, self.layerNum + 1)
                            do
                                return
                            end
                        end
                        
                        local function callbackUseProc(fn, data)
                            --local retTb=OBJDEF:decode(data)
                            if base:checkServerData(data) == true then
                                --统计使用物品
                                if num and num > 1 then
                                    statisticsHelper:useItem("p15", num)
                                else
                                    statisticsHelper:useItem("p15", 1)
                                end
                                enemyVoApi:deleteEnemy(playerVo.oldmapx, playerVo.oldmapy)
                                worldScene:changeBaseRandom(playerVo.oldmapx, playerVo.oldmapy, playerVoApi:getMapX(), playerVoApi:getMapY())
                                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("promptIslandMove", {playerVoApi:getMapX(), playerVoApi:getMapY()}), 28)
                                self:refreshBag(idx)
                                helpDefendVoApi:clear()--清空协防
                                eventDispatcher:dispatchEvent("user.basemove")
                                
                            end
                            
                        end
                        socketHelper:baseChange(callbackUseProc)
                    end
                    
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), baseChangeother, getlocal("dialog_title_prompt"), getlocal("randomMoveIsland"), nil, self.layerNum + 1)
                    
                elseif tag == 56 or tag == 406 or (tag >= 2001 and tag <= 2128) then
                    local needGems = 0
                    if propCfg[pid] and propCfg[pid].useConsume and SizeOfTable(propCfg[pid].useConsume) > 0 then
                        local useConsume = propCfg[pid].useConsume
                        for k, v in pairs(useConsume) do
                            if v and SizeOfTable(v) > 0 then
                                local num = tonumber(v[2])
                                local costPid = tonumber(v[1]) or tonumber(RemoveFirstChar(v[1]))
                                local hasNum = bagVoApi:getItemNumId(costPid)
                                
                                if hasNum < num and (tag >= 2001 and tag <= 2128) then
                                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_peijianhuzeng_accessory_tip5", {accessoryName, 1}), 30)
                                    do return end
                                end
                                
                                if hasNum < num and propCfg[v[1]] and propCfg[v[1]].gemCost then
                                    needGems = needGems + propCfg[v[1]].gemCost * (num - hasNum)
                                end
                                
                                --              if id>=2001 and id<=2128 then
                                --   smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_peijianhuzeng_accessory_tip5",{accessoryName,1}),30)
                                --   return
                                -- end
                                
                                -- print("idx+1",idx+1)
                                -- print("k",k,v)
                                -- for m,n in pairs(v) do
                                --     print("m",m,n)
                                --     print("n",n[1],n[2])
                                --     if n and n[2] then
                                --         local num=tonumber(n[2])
                                --         local hasNum=bagVoApi:getItemNumId(n[1])
                                --         local costPid=tonumber(n[1]) or tonumber(RemoveFirstChar(n[1]))
                                --         print("costPid",costPid)
                                --         if hasNum<num and costPid and tabItem[costPid] then
                                --             needGems=needGems+tabItem[costPid].gemCost*(num-hasNum)
                                --         end
                                --     end
                                -- end
                            end
                        end
                    end
                    
                    local function callbackUseProc1(fn, data)
                        local ret, sData = base:checkServerData(data)
                        if ret == true then
                            --统计使用物品
                            statisticsHelper:useItem(pid, 1)
                            if needGems == 0 and propCfg[pid] and propCfg[pid].useConsume and SizeOfTable(propCfg[pid].useConsume) > 0 then
                                local useConsume = propCfg[pid].useConsume
                                for k, v in pairs(useConsume) do
                                    if v and v[2] then
                                        statisticsHelper:useItem(v[1], tonumber(v[2]))
                                    end
                                end
                                -- if v and SizeOfTable(v)>0 then
                                --     for m,n in pairs(v) do
                                --         if n and n[2] then
                                --             statisticsHelper:useItem(n[1],tonumber(n[2]))
                                --         end
                                --     end
                                -- end
                            end
                            if tag == 406 then -- 使用模糊不清的藏宝图获得完整的藏宝图
                                local str = getlocal("getPropSuccess")
                                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), str, 28)
                            elseif tag >= 2001 and tag <= 2128 then
                                
                                local pid = "p" .. tag
                                if sData.data and sData.data.accReward then
                                    if propCfg[pid].isRandom == 1 and propCfg[pid].useType == 2 then
                                    else
                                        local accessory = sData.data.accReward
                                        accessoryVoApi:addNewData(accessory)
                                    end
                                end
                                local getTb = propCfg[pid].useGetAccessory
                                local sbStr = ""
                                for k, v in pairs(getTb) do
                                    local nameStr = getlocal(tostring(accessoryCfg.aCfg[k].name)) or ""
                                    sbStr = sbStr .. nameStr .. "*" .. v
                                end
                                local str = getlocal("activity_peijianhuzeng_accessory_tip6", {getlocal(propCfg[pid].name), sbStr})
                                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), str, 30)
                                
                            elseif sData.data and sData.data.reward then
                                local reward = FormatItem(sData.data.reward, false)
                                G_showRewardTip(reward)
                            end
                            -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("use_prop_success",{getlocal(propCfg[pid].name)}),28)
                            self:refreshBag(idx)
                        end
                    end
                    
                    if needGems > 0 then
                        if needGems > playerVoApi:getGems() then
                            GemsNotEnoughDialog(nil, nil, needGems - playerVoApi:getGems(), self.layerNum + 1, needGems)
                        else
                            local function usePropHandler(tag1, object)
                                PlayEffect(audioCfg.mouseClick)
                                socketHelper:useProc(tag, nil, callbackUseProc1, 1)
                            end
                            if tag == 56 then
                                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), usePropHandler, getlocal("dialog_title_prompt"), getlocal("use_prop_cost", {needGems}), nil, self.layerNum + 1)
                            elseif tag == 406 then
                                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), usePropHandler, getlocal("dialog_title_prompt"), getlocal("activity_miBao_usePropCost", {needGems}), nil, self.layerNum + 1)
                            end
                        end
                    else
                        socketHelper:useProc(tag, nil, callbackUseProc1)
                    end
                else
                    local function callbackUseProc(fn, data)
                        --local retTb=OBJDEF:decode(data)
                        local ret, sData = base:checkServerData(data)
                        if ret == true then
                            if tag == 14 or tag == 45 or tag == 46 then
                                worldScene:addProtect()
                            end
                            --统计使用物品
                            if num then
                                statisticsHelper:useItem(pid, num)
                            else
                                statisticsHelper:useItem(pid, 1)
                            end
                            
                            -- if (tag==88 or tag==89 or tag==90 or tag==91 or tag==229) then
                            --添加配件和碎片、原材料
                            if sData.data and sData.data.accReward then
                                if propCfg[pid].isRandom == 1 and propCfg[pid].useType == 2 then
                                else
                                    local accessory = sData.data.accReward
                                    accessoryVoApi:addNewData(accessory)
                                end
                            end
                            --装甲矩阵，客户端只自己加经验，矩阵服务器给返回
                            if(propCfg[pid].useGetArmor)then
                                for key, v in pairs(propCfg[pid].useGetArmor) do
                                    if(key == "exp")then
                                        if(num)then
                                            armorMatrixVoApi:addArmorExp(v * num)
                                        else
                                            armorMatrixVoApi:addArmorExp(v)
                                        end
                                    end
                                end
                            end
                            if sData.data.reward then
                                for k, v in pairs(sData.data.reward) do
                                    if k == "am" then
                                        for kk, vv in pairs(v) do
                                            if kk == "exp" then
                                                if(num)then
                                                    armorMatrixVoApi:addArmorExp(vv * num)
                                                else
                                                    armorMatrixVoApi:addArmorExp(vv)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            -- end
                            
                            if (propCfg[pid].useGetAllianceWarpoint) then
                                if serverWarTeamVoApi then
                                    local addPoint
                                    if num then
                                        addPoint = propCfg[pid].useGetAllianceWarpoint * num
                                    else
                                        addPoint = propCfg[pid].useGetAllianceWarpoint
                                    end
                                    serverWarTeamVoApi:setPoint(serverWarTeamVoApi:getPoint() + addPoint)
                                end
                            end
                            
                            if (propCfg[pid].useGetAreaAllianceWarpoint) then
                                if serverWarLocalVoApi then
                                    local addPoint
                                    if num then
                                        addPoint = propCfg[pid].useGetAreaAllianceWarpoint * num
                                    else
                                        addPoint = propCfg[pid].useGetAreaAllianceWarpoint
                                    end
                                    serverWarLocalVoApi:setPoint(serverWarLocalVoApi:getPoint() + addPoint)
                                end
                            end
                            
                            -- 军徽碎片，客户端自己添加
                            if propCfg[pid].isEmblem and propCfg[pid].composeGetProp then
                                local composeGetProps = propCfg[pid].composeGetProp
                                if G_rewardType(Split(composeGetProps[2][1], "_")[1]) == "se" then
                                    local emblemNum = 1
                                    if num > 1 and num > composeGetProps[1] then
                                        emblemNum = math.floor(num / composeGetProps[1])
                                    end
                                    local emblemKey = Split(composeGetProps[2][1], "_")[2]
                                    if emblemVoApi then
                                        emblemVoApi:addNumByKey(emblemKey, emblemNum)
                                    end
                                end
                            end
                            if sData.data and sData.data.reward and (propCfg[pid].useGetEquipRes or propCfg[pid].useGetUserarenaRes or propCfg[pid].useGetExpeditionRes) then
                                local reward = FormatItem(sData.data.reward, false)
                                if reward and SizeOfTable(reward) > 0 then
                                    for k, v in pairs(reward) do
                                        if v.type == "f" or v.type == "m" or v.type == "n" then
                                            G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                                        end
                                    end
                                end
                                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("use_prop_success", {getlocal(propCfg[pid].name)}), 28)
                            elseif propCfg[pid].isRandom == 1 and sData.data and sData.data.reward then
                                local reward = FormatItem(sData.data.reward, false)
                                if propCfg[pid].useType == 2 and (tag ~= 407) then
                                    local useNum = 1
                                    if num then
                                        useNum = num
                                    end
                                    for k, v in pairs(reward) do
                                        if (v.type == "e" and (v.eType == "f" or v.eType == "p")) or v.type == "se" then
                                            G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                                        end
                                    end
                                    bagVoApi:showUsePropSmallDialog(self.layerNum + 1, reward, pid, useNum)
                                else
                                    if tag == 818 or tag == 819 then
                                        local tipStr = G_showRewardTip(reward, false)
                                        local rItem = reward[1]
                                        if rItem and rItem.type == "h" and rItem.eType == "s" then
                                            local heroid = heroCfg.soul2hero[rItem.key]
                                            if heroVoApi:heroHonorIsOpen() == true and heroVoApi:getIsHonored(heroid) == true then
                                                tipStr = tipStr..getlocal("hero_honor_recruit_honored_hero", {rItem.num})
                                            end
                                        end
                                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 28)
                                    else
                                        G_showRewardTip(reward)
                                    end
                                    
                                    if tag == 407 then -- 当玩家使用【完整的藏宝图】获得高级道具时，将在世界聊天广播如下内容：
                                        if acMiBaoVoApi then
                                            local showMessage = false
                                            
                                            local vo = acMiBaoVoApi:getAcVo()
                                            if activityVoApi:isStart(vo) == false then
                                                do return end
                                            end
                                            local advanced = acMiBaoVoApi:getAdvanced()
                                            local function isAdvanced(pid)
                                                for k, v in pairs(advanced) do
                                                    if v == pid then
                                                        return true
                                                    end
                                                end
                                                return false
                                            end
                                            
                                            for rk, rv in pairs(sData.data.reward) do
                                                if rk == "p" then
                                                    for rk1, rv1 in pairs(rv) do
                                                        if rk1 ~= nil and rv1 > 0 and isAdvanced(rk1) == true then
                                                            showMessage = true
                                                            break
                                                        end
                                                    end
                                                end
                                            end
                                            -- if showMessage == true then
                                            --     local message = {key = "activity_miBao_noteMsg", param = {playerVoApi:getPlayerName(), G_showRewardTip(reward, false, true)}}
                                            --     chatVoApi:sendSystemMessage(message)
                                            -- end
                                        end
                                    end
                                end
                            else
                                if (self.selectedSubTabIndex == 10 and propCfg[pid].useGetResource) then
                                    local reward = {}
                                    if self.selectedSubTabIndex == 10 and propCfg[pid].useGetResource then
                                        for k, v in pairs(propCfg[pid].useGetResource) do
                                            local key = k
                                            local totalNum = v
                                            if num and num > 0 then
                                                totalNum = v * num
                                            end
                                            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, "u")
                                            local award = {type = "u", key = key, pic = pic, name = name, num = totalNum, desc = desc, id = id, bgname = bgname}
                                            table.insert(reward, award)
                                        end
                                    end
                                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("use_prop_success", {getlocal(propCfg[pid].name)}), 28, nil, nil, reward)
                                else
                                    local nameStr
                                    if(num and num > 1)then
                                        nameStr = getlocal(propCfg[pid].name) .. "*"..num
                                    else
                                        nameStr = getlocal(propCfg[pid].name)
                                    end
                                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("use_prop_success", {nameStr}), 28)
                                end
                                
                            end
                            if sData.data.exter and type(sData.data.exter) == "table" then --建筑装扮
                                local eBid, eTimeLimit
                                if propCfg[pid] and propCfg[pid].useGetExterior then
                                    eBid = propCfg[pid].useGetExterior[1]
                                    eTimeLimit = propCfg[pid].useGetExterior[2]
                                end
                                for k, v in pairs(sData.data.exter) do
                                    -- G_dayin(sData.data.exter)
                                    if buildDecorateVoApi and buildDecorateVoApi.unlockSkin then
                                        buildDecorateVoApi:unlockSkin(v, eTimeLimit) --添加建筑装扮
                                    end
                                end
                            end
                            self:refreshBag(idx)
                        end
                        
                    end
                    local function requestUseProc()
                        if num and num > 1 then
                            socketHelper:useProc(tag, nil, callbackUseProc, nil, nil, num)
                        else
                            socketHelper:useProc(tag, nil, callbackUseProc)
                        end
                    end
                    if propCfg[pid] and propCfg[pid].useGetExterior then
                        local bid = propCfg[pid].useGetExterior[1]
                        if bid then
                            local timeLimit = exteriorCfg.exteriorLit[bid].timeLimit
                            if (timeLimit > 0 and buildDecorateVoApi:judgeHas(bid) == true) or buildDecorateVoApi:isExperience(bid) then
                                G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("timeLimitSkinUseTip"), false, requestUseProc)
                                do return end
                            end
                        end
                    end
                    requestUseProc()
                end
                return true
            end
            local function touch1(tag, object)
                if self.tv:getIsScrolled() == true then
                    return
                end
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                if tag == 4933 then
                    playerVoApi:showPlayerDialog(1, self.layerNum + 1)
                    do return end
                end
                local num = nil
                -- if tag > 4823 and tag < 4828 then
                if (tag > 4819 and tag < 4828) or (propCfg["p"..tag] and propCfg["p"..tag].composeGetProp) then
                    num = bagVoApi:getItemNumId(tag)
                    if num < propCfg["p"..tag].composeGetProp[1] then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("countNotEnoughToUse"), 28)
                        do return end
                    else
                        num = propCfg["p"..tag].composeGetProp[1]
                    end
                    
                end
                if tag == 904 or tag == 3306 then
                    friendMailVoApi:showSelectFriendDialog(self.layerNum, tag)
                    return
                end
                
                if tag == 3304 or tag == 3305 then
                    bagVoApi:showSearchSmallDialog(self.layerNum + 1, "p"..tag)
                    do return end
                end
                
                if propCfg[pid].useGetOne then
                    local reward = G_rewardFromPropCfg(pid)
                    
                    local function usePorp(selectId)
                        if propCfg[pid].rolelevel ~= nil then
                            if playerVoApi:getPlayerLevel() < propCfg[pid].rolelevel then
                                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("needRoleLevel", {propCfg[pid].rolelevel}), nil, self.layerNum + 1)
                                do return end
                            end
                        end
                        local function refreshFunc()
                            local award = {reward[selectId]}
                            G_showRewardTip(award, true)
                            self:refreshBag(idx)
                        end
                        bagVoApi:propUseSelectReward(pid, m_index, selectId, 1, refreshFunc)
                    end
                    local nameStr = getlocal(propCfg[pid].name)
                    bagVoApi:showSelectRewardSmallDialog(self.layerNum + 1, reward, nil, usePorp, nameStr)
                    do return end
                end
                
                local function usePropsHandler(tag, object, num)
                    if canUseProps(tag, object) == true then
                        usePropsCallback(tag, object, num)
                    end
                end
                local function realUseHandler()
                    if (propCfg[pid].aDropMaxNum or propCfg[pid].fDropTypeMaxNum) and (base.ifAccessoryOpen == 1 and accessoryVoApi.dataNeedRefresh == true) then
                        local function accDataCallback()
                            usePropsHandler(tag, object, num)
                        end
                        accessoryVoApi:refreshData(accDataCallback)
                    else
                        usePropsHandler(tag, object, num)
                    end    
                end
                if propCfg[pid] and propCfg[pid].tskinDiscount then --折扣券处理
                    local skinId = propCfg[pid].tskinDiscount[1]
                    if tankSkinVoApi:isSkinOwned(skinId) == true then --如果拥有该涂装则提示兑换成强化图纸
                        local reward = G_rewardFromPropCfg(pid)[1]
                        local tipStr = {getlocal("tskin_disticket_usetip",{reward.num,reward.name}),{nil,G_ColorGreen,nil,G_ColorGreen,nil}}
                        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),tipStr,false,realUseHandler)
                    else --否则跳转到涂装商店
                        activityAndNoteDialog:closeAllDialog()
                        local td = allShopVoApi:showAllPropDialog(self.layerNum, "tskin")
                    end
                else
                    realUseHandler()
                end
            end
            
            local useType = tonumber(propCfg[pid].useType) or 0
            local function useHandler(tag, object)
                if self.tv:getIsScrolled() == true then
                    return
                end
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                local propId = tag - 100000
                -- if propId > 4823 and propId < 4828 then
                if (propId > 4819 and propId < 4828) or (propCfg["p"..propId] and propCfg["p"..propId].composeGetProp) then
                    local num = bagVoApi:getItemNumId(propId)
                    if num < propCfg["p"..propId].composeGetProp[1] then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("countNotEnoughToUse"), 28)
                        do return end
                    end
                end
                
                local function usePropsHandler(tag, object)
                    local propId = tabItem[idx + 1].id
                    if canUseProps(propId, object) == true then
                        if useType then
                            local function useNumProps(num)
                                if canUseProps(propId, object, num) == true then
                                    usePropsCallback(propId, object, num)
                                end
                            end
                            if useType == 1 then
                                if propCfg[pid].useGetOne then
                                    local reward = G_rewardFromPropCfg(pid)
                                    local function usePorp(selectId, count)
                                        if propCfg[pid].rolelevel ~= nil then
                                            if playerVoApi:getPlayerLevel() < propCfg[pid].rolelevel then
                                                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("needRoleLevel", {propCfg[pid].rolelevel}), nil, self.layerNum + 1)
                                                do return end
                                            end
                                        end
                                        local function refreshFunc()
                                            reward[selectId].num = reward[selectId].num * count
                                            local award = {reward[selectId]}
                                            G_showRewardTip(award, true)
                                            self:refreshBag(idx)
                                        end
                                        bagVoApi:propUseSelectReward(pid, m_index, selectId, count, refreshFunc)
                                    end
                                    local nameStr = getlocal(propCfg[pid].name)
                                    bagVoApi:showSelectRewardSmallDialog(self.layerNum + 1, reward, nil, usePorp, nameStr, pid, true)
                                else
                                    bagVoApi:showBatchUsePropSmallDialog(pid, self.layerNum + 1, useNumProps)
                                end
                            elseif useType == 2 or useType == 4 then
                                local num = bagVoApi:getItemNumId(propId)
                                if propCfg[pid].aDropMaxNum then
                                    local leftABagNum = accessoryVoApi:getABagLeftGrid()
                                    if num > leftABagNum then
                                        num = leftABagNum
                                    end
                                end
                                
                                local newId = tonumber(propId) or tonumber(RemoveFirstChar(propId))
                                -- if newId > 4823 and newId < 4828 then
                                if (newId > 4819 and newId < 4828) or (propCfg["p"..propId] and propCfg["p"..propId].composeGetProp) then
                                    local costTopNum = propCfg["p"..propId].composeGetProp[1]
                                    num = math.floor(num / costTopNum) * costTopNum
                                end
                                useNumProps(num)
                            end
                        end
                    end
                end
                
                local function realUseHandler()
                    if (propCfg[pid].aDropMaxNum or propCfg[pid].fDropTypeMaxNum) and (base.ifAccessoryOpen == 1 and accessoryVoApi.dataNeedRefresh == true) then
                        local function accDataCallback()
                            usePropsHandler(tag, object)
                        end
                        accessoryVoApi:refreshData(accDataCallback)
                    else
                        usePropsHandler(tag, object)
                    end
                end
                if propCfg[pid] and propCfg[pid].tskinDiscount then --折扣券处理
                    local skinId = propCfg[pid].tskinDiscount[1]
                    if tankSkinVoApi:isSkinOwned(skinId) == true then --如果拥有该涂装则提示兑换成强化图纸
                        local reward = G_rewardFromPropCfg(pid)[1]
                        local tipStr = {getlocal("tskin_disticket_usetip",{reward.num,reward.name}),{nil,G_ColorGreen,nil,G_ColorGreen,nil}}
                        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),tipStr,false,realUseHandler)
                    else --否则跳转到涂装商店
                        activityAndNoteDialog:closeAllDialog()
                        local td = allShopVoApi:showAllPropDialog(self.layerNum, "tskin")
                    end
                else
                    realUseHandler()
                end
            end
            local btnTb = {}
            if propCfg[pid].isUseable == "true" then
                --加速类道具在背包不显示使用按钮
                if propCfg[pid].useTimeDecrease then
                else
                    local id = tonumber(pid) or tonumber(RemoveFirstChar(pid))
                    -- local useStr = (id > 4823 and id < 4828) and getlocal("activity_gangtieronglu_compose") or getlocal("use")
                    local useStr
                    if (id > 4819 and id < 4828) or (propCfg[pid] and propCfg[pid].composeGetProp) then
                        useStr = getlocal("activity_gangtieronglu_compose")
                    else
                        useStr = getlocal("use")
                    end
                    local strSize2 = 24
                    if useStr == getlocal("activity_gangtieronglu_compose") then
                        if G_getCurChoseLanguage() ~= "cn" or G_getCurChoseLanguage() ~= "tw" or G_getCurChoseLanguage() ~= "ko" or G_getCurChoseLanguage() ~= "ja" then
                            strSize2 = 18
                        end
                    end
                    local menuItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", touch1, tabItem[idx + 1].id, useStr, strSize2, 100)
                    menuItem:setScaleX(0.65)
                    menuItem:setScaleY(0.7)
                    --menuItem:setPosition(ccp(500,40))
                    menuItem:setEnabled(true);
                    local menu3 = CCMenu:createWithItem(menuItem);
                    menu3:setPosition(ccp(500, 55))
                    menu3:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
                    cell:addChild(menu3, 6)
                    local lb = menuItem:getChildByTag(100)
                    if lb then
                        lb = tolua.cast(lb, "CCLabelTTF")
                        lb:setScaleX(1.35)
                        lb:setScaleY(1.3)
                    end
                    
                    table.insert(btnTb, {name = useStr, tag = tabItem[idx + 1].id, callback = touch1})
                    
                    local id = tonumber(pid) or tonumber(RemoveFirstChar(pid))
                    if bagVoApi:getItemNumId(id) > 1 then
                        if useType and useType > 0 then
                            local btnSize = 24
                            if useType == 2 then
                                btnSize = 22
                                if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() == "ja" then
                                    btnSize = 24
                                end
                            elseif useType == 1 then
                                if G_getCurChoseLanguage() == "ru" then
                                    btnSize = 22
                                end
                            elseif useType == 4 then
                                if G_getCurChoseLanguage() ~= "cn" or G_getCurChoseLanguage() ~= "tw" or G_getCurChoseLanguage() ~= "ko" or G_getCurChoseLanguage() ~= "ja" then
                                    btnSize = 18
                                end
                            end
                            if G_getCurChoseLanguage() == "de" then
                                btnSize = 18
                                if useType == 4 then
                                    btnSize = 16
                                end
                            end
                            table.insert(btnTb, {name = getlocal("prop_use_type"..useType), tag = id + 100000, callback = useHandler})
                            local menuItem1 = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", useHandler, id + 100000, getlocal("prop_use_type"..useType), btnSize, 100)
                            menuItem1:setScaleX(0.65)
                            menuItem1:setScaleY(0.7)
                            menuItem1:setEnabled(true);
                            local menu4 = CCMenu:createWithItem(menuItem1);
                            menu4:setPosition(ccp(500, 115))
                            menu4:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
                            cell:addChild(menu4, 6)
                            local lb = menuItem1:getChildByTag(100)
                            if lb then
                                lb = tolua.cast(lb, "CCLabelTTF")
                                lb:setScaleX(1.35)
                                lb:setScaleY(1.3)
                            end
                        end
                    end
                end
            end
            local isShow = propCfg[pid].isShow
            if isShow and isShow == 1 then
                
                local function showDisplayDialog()
                    if self.tv:getIsScrolled() == true then
                        return
                    end
                    if G_checkClickEnable() == false then
                        do
                            return
                        end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    
                    local sbReward = G_rewardFromPropCfg(pid)
                    local titleStr = getlocal(propCfg[pid].name)
                    local desStr
                    local random = propCfg[pid].isRandom
                    if random and random == 1 then
                        desStr = getlocal("database_des1")
                    else
                        desStr = getlocal("database_des2")
                    end
                    if propCfg[pid].useGetOne then
                        desStr = getlocal("database_des3")
                    end
                    bagVoApi:showPropDisplaySmallDialog(self.layerNum + 1, sbReward, titleStr, desStr, btnTb)
                end
                local touchSp = LuaCCSprite:createWithSpriteFrameName("datebaseShow1.png", showDisplayDialog)
                touchSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
                touchSp:setScale(100 / touchSp:getContentSize().width)
                touchSp:setAnchorPoint(ccp(0, 0.5));
                touchSp:setPosition(20, self.cellHight / 2)
                -- touchSp:setOpacity(0)
                cell:addChild(touchSp, 2)
                
                local fangdajinSp = CCSprite:createWithSpriteFrameName("datebaseShow2.png")
                fangdajinSp:setAnchorPoint(ccp(1, 0))
                fangdajinSp:setPosition(touchSp:getContentSize().width - 5, 5)
                -- touchSp:setOpacity(0)
                touchSp:addChild(fangdajinSp, 2)
                if propCfg[pid] and propCfg[pid].tskinDiscount then
                    touchSp:setOpacity(0)
                end
            end
        elseif self.selectedTabIndex == 1 then
            local tabItem
            if self.selectedSubTabIndex == 10 then
                tabItem = self.shoptabItem
            elseif self.selectedSubTabIndex == 11 then
                tabItem = self.shoptabItemType1
            elseif self.selectedSubTabIndex == 12 then
                tabItem = self.shoptabItemType2
            elseif self.selectedSubTabIndex == 13 then
                tabItem = self.shoptabItemType3
            end
            
            local lbNameFontSize = 24
            if G_getCurChoseLanguage() == "de" then
                lbNameFontSize = 20
            end
            local lbName = GetTTFLabelWrap(getlocal(tabItem[idx + 1].name), lbNameFontSize, CCSizeMake(330, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
            lbName:setColor(G_ColorGreen)
            lbName:setPosition(130, self.cellHight - 55)
            lbName:setAnchorPoint(ccp(0, 0.5));
            cell:addChild(lbName, 2)
            
            local pid = "p"..tabItem[idx + 1].sid
            -- local sprite = CCSprite:createWithSpriteFrameName(tabItem[idx+1].icon);
            local sprite
            if pid == "p56" then
                sprite = GetBgIcon(tabItem[idx + 1].icon, nil, nil, 70, 100)
            elseif pid == "p57" then
                sprite = GetBgIcon(tabItem[idx + 1].icon, nil, nil, 80, 100)
            elseif pid == "p866" then
                sprite = CCSprite:createWithSpriteFrameName("item_prop_866.png")
            elseif propCfg[pid].useGetHero then
                local heroData = {h = G_clone(propCfg[pid].useGetHero)}
                local itemTb = FormatItem(heroData)
                local item = itemTb[1]
                if item and item.type == "h" then
                    if item.eType == "h" then
                        local productOrder = item.num
                        sprite = heroVoApi:getHeroIcon(item.key, productOrder, true, touch, nil, nil, nil, {adjutants = {}})
                    else
                        sprite = heroVoApi:getHeroIcon(item.key, 1, false, touch)
                    end
                end
            else
                -- dmj2015-10-19修改，商店统一走G_getItemIcon()
                -- sprite = CCSprite:createWithSpriteFrameName(tabItem[idx+1].icon)
                local propData = {p = {}}
                propData.p[pid] = 0
                local itemTb = FormatItem(propData)
                local item = itemTb[1]
                if item then
                    sprite = G_getItemIcon(item, 100)
                end
            end
            sprite:setAnchorPoint(ccp(0, 0.5));
            sprite:setPosition(20, self.cellHight / 2)
            if sprite and sprite:getContentSize().width > 100 then
                sprite:setScale(100 / sprite:getContentSize().width)
            end
            cell:addChild(sprite, 2)
            
            local desFontSize = 20
            if G_getCurChoseLanguage() == "de" then
                desFontSize = 18
            end
            local labelSize = CCSizeMake(290, self.cellHight - 60);
            local lbDescription = GetTTFLabelWrap(getlocal(tabItem[idx + 1].description), desFontSize, labelSize, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            lbDescription:setPosition(130, (self.cellHight - 60) / 2)
            lbDescription:setAnchorPoint(ccp(0, 0.5));
            cell:addChild(lbDescription, 2)
            
            local gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png");
            
            gemIcon:setPosition(ccp(480, 125));
            cell:addChild(gemIcon, 2)
            
            local lbPrice = GetTTFLabel(tabItem[idx + 1].gemCost, 24)
            lbPrice:setPosition(500, 125)
            lbPrice:setAnchorPoint(ccp(0, 0.5));
            cell:addChild(lbPrice, 2)
            
            local function touch1(tag, object)
                if self.tv:getIsScrolled() == true then
                    return
                end
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                self:removeGuied()
                
                PlayEffect(audioCfg.mouseClick)
                
                local function touchBuy(num)
                    local function callbackBuyprop(fn, data)
                        --local retTb=OBJDEF:decode(data)
                        if base:checkServerData(data) == true then
                            --统计购买物品
                            statisticsHelper:buyItem("p"..tabItem[idx + 1].sid, tabItem[idx + 1].gemCost, 1, tabItem[idx + 1].gemCost)
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("buyPropPrompt", {getlocal(tabItem[idx + 1].name)}), 28)
                            self.shoptabItemBag = bagVoApi:getShopItemByType(2)
                            self.shoptabItemBagType1 = bagVoApi:getShopItemByType(1)
                            self.shoptabItemBagType2 = bagVoApi:getShopItemByType(3)
                            self.shoptabItemBagType3 = bagVoApi:getShopItemByType(4)
                            
                        end
                        
                    end
                    socketHelper:buyProc(tag, callbackBuyprop, num)
                end
                
                local function showBuyDialog()
                    shopVoApi:showBatchBuyPropSmallDialog(pid, self.layerNum + 1, touchBuy)
                end
                local function buyGems()
                    if G_checkClickEnable() == false then
                        do
                            return
                        end
                    end
                    vipVoApi:showRechargeDialog(self.layerNum + 1)
                    
                end
                
                if playerVo.gems < tonumber(tabItem[idx + 1].gemCost) then
                    local num = tonumber(tabItem[idx + 1].gemCost) - playerVo.gems
                    local smallD = smallDialog:new()
                    smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), buyGems, getlocal("dialog_title_prompt"), getlocal("gemNotEnough", {tonumber(tabItem[idx + 1].gemCost), playerVo.gems, num}), nil, self.layerNum + 1)
                else
                    local smallD = smallDialog:new()
                    -- smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("prop_buy_tip",{tabItem[idx+1].gemCost,getlocal(tabItem[idx+1].name)}),nil,self.layerNum+1)
                    showBuyDialog()
                end
                
            end
            
            local menuItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", touch1, tabItem[idx + 1].sid, getlocal("buy"), 24, 100)
            menuItem:setScaleX(0.65)
            menuItem:setScaleY(0.7)
            --menuItem:setPosition(ccp(500,40))
            menuItem:setEnabled(true);
            local menu3 = CCMenu:createWithItem(menuItem);
            menu3:setPosition(ccp(500, 55))
            menu3:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
            cell:addChild(menu3, 6)
            local lb = menuItem:getChildByTag(100)
            if lb then
                lb = tolua.cast(lb, "CCLabelTTF")
                lb:setScaleX(1.35)
                lb:setScaleY(1.3)
            end
            local btnTb = {}
            table.insert(btnTb, {name = getlocal("buy"), tag = tabItem[idx + 1].sid, callback = touch1})
            local isShow = propCfg[pid].isShow
            if isShow and isShow == 1 then
                local function showDisplayDialog()
                    if self.tv:getIsScrolled() == true then
                        return
                    end
                    if G_checkClickEnable() == false then
                        do
                            return
                        end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    
                    local sbReward = G_rewardFromPropCfg(pid)
                    local titleStr = getlocal(propCfg[pid].name)
                    local desStr
                    local random = propCfg[pid].isRandom
                    if random and random == 1 then
                        desStr = getlocal("database_des1")
                    else
                        desStr = getlocal("database_des2")
                    end
                    bagVoApi:showPropDisplaySmallDialog(self.layerNum + 1, sbReward, titleStr, desStr, btnTb)
                end
                local touchSp = LuaCCSprite:createWithSpriteFrameName("datebaseShow1.png", showDisplayDialog)
                touchSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
                touchSp:setScale(100 / touchSp:getContentSize().width)
                touchSp:setAnchorPoint(ccp(0, 0.5));
                touchSp:setPosition(20, self.cellHight / 2)
                -- touchSp:setOpacity(0)
                cell:addChild(touchSp, 2)
                
                local fangdajinSp = CCSprite:createWithSpriteFrameName("datebaseShow2.png")
                fangdajinSp:setAnchorPoint(ccp(1, 0))
                fangdajinSp:setPosition(touchSp:getContentSize().width - 5, 5)
                -- touchSp:setOpacity(0)
                touchSp:addChild(fangdajinSp, 2)
                if propCfg[pid] and propCfg[pid].tskinDiscount then
                    touchSp:setOpacity(0)
                end
            end
            
        elseif self.selectedTabIndex == 2 then
            local goldTo360Rate = 1
            if platCfg.platShopCfg[G_curPlatName()] then
                goldTo360Rate = platCfg.platShopCfg[G_curPlatName()]["rate"]
            end
            local tabItem
            if self.selectedSubTabIndex == 10 then
                tabItem = self.platShopItem
            elseif self.selectedSubTabIndex == 11 then
                tabItem = self.platShopItemType1
            elseif self.selectedSubTabIndex == 12 then
                tabItem = self.platShopItemType2
            elseif self.selectedSubTabIndex == 13 then
                tabItem = self.platShopItemType3
            end
            local nameFontSize, desFontSize = 24, 20
            if G_getCurChoseLanguage() == "de" then
                nameFontSize, desFontSize = 20, 18
            end
            local lbName = GetTTFLabelWrap(getlocal(tabItem[idx + 1].name), nameFontSize, CCSizeMake(26 * 15, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            lbName:setColor(G_ColorGreen)
            lbName:setPosition(150, self.cellHight - 40)
            lbName:setAnchorPoint(ccp(0, 0.5))
            cell:addChild(lbName, 2)
            
            local pid = "p"..tabItem[idx + 1].sid
            local sprite
            if pid == "p56" then
                sprite = GetBgIcon(tabItem[idx + 1].icon, nil, nil, 70, 100)
            elseif pid == "p57" then
                sprite = GetBgIcon(tabItem[idx + 1].icon, nil, nil, 80, 100)
            else
                -- sprite = CCSprite:createWithSpriteFrameName(tabItem[idx+1].icon)
                local propData = {p = {}}
                propData.p[pid] = 0
                local itemTb = FormatItem(propData)
                local item = itemTb[1]
                if item then
                    sprite = G_getItemIcon(item, 100)
                end
            end
            sprite:setAnchorPoint(ccp(0, 0.5));
            sprite:setPosition(20, self.cellHight / 2)
            cell:addChild(sprite, 2)
            
            local labelSize = CCSize(270, 0);
            local lbDescription = GetTTFLabelWrap(getlocal(tabItem[idx + 1].description), desFontSize, labelSize, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            lbDescription:setPosition(150, (self.cellHight - 60) / 2)
            lbDescription:setAnchorPoint(ccp(0, 0.5));
            cell:addChild(lbDescription, 2)
            
            --local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
            local gemIcon = CCSprite:create("public/360gold.png")
            gemIcon:setPosition(ccp(480, 100))
            cell:addChild(gemIcon, 2)
            
            local lbPrice = GetTTFLabel(math.ceil(tabItem[idx + 1].gemCost / goldTo360Rate), 24)
            lbPrice:setPosition(560, 100)
            lbPrice:setAnchorPoint(ccp(1, 0.5))
            cell:addChild(lbPrice, 2)
            
            local function touch1(tag, object)
                if self.tv:getIsScrolled() == true then
                    return
                end
                self:removeGuied()
                PlayEffect(audioCfg.mouseClick)
                local function touchBuy()
                    --[[
                    local function callbackBuyprop(fn,data)
                        if base:checkServerData(data)==true then
                            --统计购买物品
                            statisticsHelper:buyItem("p"..tabItem[idx+1].sid,tabItem[idx+1].gemCost,1,tabItem[idx+1].gemCost)
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("buyPropPrompt",{getlocal(tabItem[idx+1].name)}),28)
                            self.shoptabItemBag=bagVoApi:getShopItemByType(2)
                            self.shoptabItemBagType1=bagVoApi:getShopItemByType(1)
                            self.shoptabItemBagType2=bagVoApi:getShopItemByType(3)
                            self.shoptabItemBagType3=bagVoApi:getShopItemByType(4)
                        end
                    end
                    socketHelper:buyProc(tag,callbackBuyprop)
                    ]]
                    local itemId = "tk_360_p"..tabItem[idx + 1].sid
                    AppStorePayment:shared():buyItemByTypeForAndroid(itemId, getlocal(tabItem[idx + 1].name), "", math.ceil(tabItem[idx + 1].gemCost / goldTo360Rate), 1, "", base.curZoneID, ext1, ext2);
                end
                
                local smallD = smallDialog:new()
                smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), touchBuy, getlocal("dialog_title_prompt"), getlocal("prop_360buy_tip", {math.ceil(tabItem[idx + 1].gemCost / goldTo360Rate), getlocal(tabItem[idx + 1].name)}), nil, self.layerNum + 1)
            end
            
            local menuItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", touch1, tabItem[idx + 1].sid, getlocal("buy"), 24, 100)
            menuItem:setScaleX(0.7)
            menuItem:setScaleY(0.7)
            menuItem:setEnabled(true)
            local menu3 = CCMenu:createWithItem(menuItem)
            menu3:setPosition(ccp(500, 55))
            menu3:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            cell:addChild(menu3, 6)
            local lb = menuItem:getChildByTag(100)
            if lb then
                lb = tolua.cast(lb, "CCLabelTTF")
                lb:setScaleX(1.35)
                lb:setScaleY(1.3)
            end
        end
        backSprie:setPosition(ccp(0, 0))
        cell:addChild(backSprie, 1)
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
        G_removeFlicker(self.bgLayer)
    elseif fn == "ccTouchEnded" then
        
    end
end
function propDialog:useBuffItem(id, idx, isUse, num)
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
                    self:refreshBag(idx)
                end
                
            end
            if num and num > 1 then
                socketHelper:useProc(id, nil, callbackUseProc1, 1, nil, num)
            else
                socketHelper:useProc(id, nil, callbackUseProc1, 1)
            end
        end
        local str = ""
        local keyTb = {[1] = "metal", [2] = "oil", [3] = "silicon", [4] = "uranium", [5] = "money", [7] = "fleetInfoTitle2", [8] = "island", [9] = "fleetInfoTitle2", [10] = "fleetInfoTitle2", [11] = "fleetInfoTitle2", [12] = "fleetInfoTitle2", [13] = "fleetInfoTitle2"}
        for k, v in pairs(buffTb) do
            local ppid = "p"..k
            if propCfg[ppid].buffType ~= nil and propCfg[ppid].buffType < 6 and propCfg[pid].buffType == 6 then
                str = str..getlocal(keyTb[propCfg[ppid].buffType])
            elseif propCfg[ppid].buffType ~= nil and propCfg[pid].buffType == propCfg[ppid].buffType then
                str = getlocal(keyTb[propCfg[ppid].buffType])
            end
        end
        
        if isUse == true then
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), sure, getlocal("dialog_title_prompt"), getlocal("sureUseItem1", {str}), nil, self.layerNum + 1)
        end
    elseif isEnabledUse == 2 then
        local function sure()
            
        end
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("sureUseItem2"), nil, self.layerNum + 1)
    elseif isEnabledUse == 3 then
        local str = ""
        local keyTb = {[1] = "metal", [2] = "oil", [3] = "silicon", [4] = "uranium", [5] = "money", [9] = "sample_prop_name_13"}
        for k, v in pairs(buffTb) do
            local ppid = "p"..k
            if propCfg[ppid].buffType ~= nil and propCfg[ppid].buffType < 6 then
                str = str..getlocal(keyTb[propCfg[ppid].buffType])
            end
        end
        local function sure()
            
        end
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("sureUseItem3", {str}), nil, self.layerNum + 1)
        
    end
    return isEnabledUse
    
end

function propDialog:tabClickColor(idx)
    for k, v in pairs(self.allTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
            local tabBtnItem = v
            local tabBtnLabel = tolua.cast(tabBtnItem:getChildByTag(31), "CCLabelTTF")
            tabBtnLabel:setColor(G_ColorWhite)
            
        else
            v:setEnabled(true)
            local tabBtnItem = v
            local tabBtnLabel = tolua.cast(tabBtnItem:getChildByTag(31), "CCLabelTTF")
            tabBtnLabel:setColor(G_TabLBColorGreen)
            
        end
    end
end

--点击tab页签 idx:索引
function propDialog:tabClick(idx, isEffect)
    if isEffect == false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    self:tabClickColor(idx)
    for k, v in pairs(self.allTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
        else
            v:setEnabled(true)
        end
    end
    
    self.focusCompoundItemId = nil
    for k, v in pairs(self.allSubTabs) do
        local numBg = tolua.cast(v:getChildByTag(100), "CCSprite")
        local numLb = tolua.cast(numBg:getChildByTag(100), "CCLabelTTF")
        local tipIcon = tolua.cast(v:getChildByTag(101), "CCSprite")
        if self.selectedTabIndex ~= 0 then
            numBg:setVisible(false)
            tipIcon:setVisible(false)
        else
            local _type = self:getType(v:getTag())
            local num = bagVoApi:getItemRedPointNumByType(_type)
            if num > 0 then
                if num > bagVoApi.redPointMaxNum then
                    num = "···"
                end
                numLb:setString(tostring(num))
                numBg:setVisible(true)
                tipIcon:setVisible(false)
            else
                local tipVisible, _id = bagVoApi:isCompound(_type)
                tipIcon:setVisible(tipVisible)
                if tipVisible == true then
                    self.focusCompoundItemId = _id
                end
            end
        end
    end
    self._prevSelectSubTabIndex = self.selectedSubTabIndex
    
    if self.selectedTabIndex ~= 1 then
        self:removeGuied()
    end
    self:doUserHandler()
    self.tv:reloadData()
    self:recordPoint()
end

--点击subTab页签 idx:索引
function propDialog:tabSubClick(idx)
    for k, v in pairs(self.allSubTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedSubTabIndex = idx
        else
            v:setEnabled(true)
        end
    end
    if self.selectedTabIndex == 0 then
        if self._prevSelectSubTabIndex then
            local _type = self:getType(self._prevSelectSubTabIndex)
            bagVoApi:setItemRedPointNumByType(_type)
        end
        self._prevSelectSubTabIndex = self.selectedSubTabIndex
        
        self.focusCompoundItemId = nil
        for k, v in pairs(self.allSubTabs) do
            local numBg = tolua.cast(v:getChildByTag(100), "CCSprite")
            local numLb = tolua.cast(numBg:getChildByTag(100), "CCLabelTTF")
            local tipIcon = tolua.cast(v:getChildByTag(101), "CCSprite")
            numBg:setVisible(false)
            tipIcon:setVisible(false)
            local _type = self:getType(v:getTag())
            local num = bagVoApi:getItemRedPointNumByType(_type)
            if num > 0 then
                if num > bagVoApi.redPointMaxNum then
                    num = "···"
                end
                numLb:setString(tostring(num))
                numBg:setVisible(true)
                tipIcon:setVisible(false)
            else
                local tipVisible, _id = bagVoApi:isCompound(_type)
                tipIcon:setVisible(tipVisible)
                if tipVisible == true then
                    self.focusCompoundItemId = _id
                end
            end
        end
    end
    self:removeGuied()
    self:doUserHandler()
    self.tv:reloadData()
    self:recordPoint()
end

function propDialog:recordPoint()
    if self.selectedTabIndex == 0 and self.itemCellIdx then
        local tvPoint = self.tv:getRecordPoint()
        if tvPoint.y < 0 then
            local tabItem
            if self.selectedSubTabIndex == 10 then
                tabItem = self.shoptabItemBag
            elseif self.selectedSubTabIndex == 11 then
                tabItem = self.shoptabItemBagType1
            elseif self.selectedSubTabIndex == 12 then
                tabItem = self.shoptabItemBagType2
            elseif self.selectedSubTabIndex == 13 then
                tabItem = self.shoptabItemBagType3
            end
            local itemSize = SizeOfTable(tabItem)
            local tvSize = self.tv:getViewSize()
            tvPoint.y = tvSize.height - self.cellHight * (itemSize - self.itemCellIdx)
            if tvPoint.y > 0 then
                tvPoint.y = 0
            end
            self.tv:recoverToRecordPoint(tvPoint)
        end
    end
    self.itemCellIdx = nil
end

--用户处理特殊需求,没有可以不写此方法
function propDialog:doUserHandler()
    
end

--点击了cell或cell上某个按钮
function propDialog:cellClick(idx)
    if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
        if self.expandIdx["k" .. (idx - 1000)] == nil then
            self.expandIdx["k" .. (idx - 1000)] = idx - 1000
            self.tv:openByCellIndex(idx - 1000, 120)
        else
            self.expandIdx["k" .. (idx - 1000)] = nil
            self.tv:closeByCellIndex(idx - 1000, 800)
        end
    end
end

function propDialog:refreshBag(idx)
    if(self.tv == nil or self.tv.reloadData == nil)then
        do return end
    end
    self.shoptabItemBag = bagVoApi:getShopItemByType(2)
    self.shoptabItemBagType1 = bagVoApi:getShopItemByType(1)
    self.shoptabItemBagType2 = bagVoApi:getShopItemByType(3)
    self.shoptabItemBagType3 = bagVoApi:getShopItemByType(4)
    local recordPoint = self.tv:getRecordPoint()
    
    self.tv:reloadData()
    
    --print("self.selectedSubTabIndex=",self.selectedSubTabIndex)
    if idx and idx > 3 then
        if self.selectedSubTabIndex == 10 then
            if SizeOfTable(self.shoptabItemBag) > 4 then
                self.tv:recoverToRecordPoint(recordPoint)
            end
        elseif self.selectedSubTabIndex == 11 then
            if SizeOfTable(self.shoptabItemBagType1) > 4 then
                self.tv:recoverToRecordPoint(recordPoint)
            end
        elseif self.selectedSubTabIndex == 12 then
            if SizeOfTable(self.shoptabItemBagType2) > 4 then
                self.tv:recoverToRecordPoint(recordPoint)
            end
        elseif self.selectedSubTabIndex == 13 then
            if SizeOfTable(self.shoptabItemBagType3) > 4 then
                self.tv:recoverToRecordPoint(recordPoint)
            end
        end
    end
    
    if self.selectedTabIndex == 0 then
        self.focusCompoundItemId = nil
        for k, v in pairs(self.allSubTabs) do
            local numBg = tolua.cast(v:getChildByTag(100), "CCSprite")
            local numLb = tolua.cast(numBg:getChildByTag(100), "CCLabelTTF")
            local tipIcon = tolua.cast(v:getChildByTag(101), "CCSprite")
            numBg:setVisible(false)
            tipIcon:setVisible(false)
            local _type = self:getType(v:getTag())
            local num = bagVoApi:getItemRedPointNumByType(_type)
            if num > 0 then
                if num > bagVoApi.redPointMaxNum then
                    num = "···"
                end
                numLb:setString(tostring(num))
                numBg:setVisible(true)
                tipIcon:setVisible(false)
            else
                local tipVisible, _id = bagVoApi:isCompound(_type)
                tipIcon:setVisible(tipVisible)
                if tipVisible == true then
                    self.focusCompoundItemId = _id
                end
            end
        end
    end
    
end

function propDialog:removeGuied()
    
    G_removeFlicker(self.bgLayer)
    self.isGuide = 2;
end

function propDialog:dispose()
    if self.selectedTabIndex == 0 then
        local _type = self:getType(self.selectedSubTabIndex)
        bagVoApi:setItemRedPointNumByType(_type)
    end
    
    if self and self.dialogListener then
        eventDispatcher:removeEventListener("prop.dialog.useProp", self.dialogListener)
    end
    self.itemCellIdx = nil
    self.__index = nil
    self.leftBtn = nil
    for k, v in pairs(self.expandIdx) do
        v = nil
    end
    self.expandIdx = nil
    for k, v in pairs(self.shoptabItem) do
        v = nil
    end
    self.shoptabItem = nil
    for k, v in pairs(self.shoptabItemType1) do
        v = nil
    end
    self.shoptabItemType1 = nil
    
    for k, v in pairs(self.shoptabItemType2) do
        v = nil
    end
    self.shoptabItemType2 = nil
    
    for k, v in pairs(self.shoptabItemType3) do
        v = nil
    end
    self.shoptabItemType3 = nil
    
    for k, v in pairs(self.shoptabItemBag) do
        v = nil
    end
    self.shoptabItemBag = nil
    
    for k, v in pairs(self.shoptabItemBagType1) do
        v = nil
    end
    self.shoptabItemBagType1 = nil
    
    for k, v in pairs(self.shoptabItemBagType2) do
        v = nil
    end
    self.shoptabItemBagType2 = nil
    
    for k, v in pairs(self.shoptabItemBagType3) do
        v = nil
    end
    self.shoptabItemBagType3 = nil
    
    self.cellHight = nil
    self = nil
    
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
    
    -- if G_isCompressResVersion()==true then
    --   CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.png")
    -- else
    --   CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.pvr.ccz")
    -- end
    spriteController:removePlist("public/datebaseShow.plist")
    spriteController:removeTexture("public/datebaseShow.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
end
