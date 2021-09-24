require "luascript/script/game/scene/gamedialog/arenaDialog/arenaDialog"

heroManagerDialog = commonDialog:new()

function heroManagerDialog:new(layerNum)
    
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.leftBtn = nil
    self.expandIdx = {}
    self.layerNum = layerNum
    
    return nc
end

--设置或修改每个Tab页签
function heroManagerDialog:resetTab()
    
    local index = 0
    local tabHeight = 0
    for k, v in pairs(self.allTabs) do
        local tabBtnItem = v
        
        if index == 0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width / 2 + 20, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 80 - tabHeight)
        elseif index == 1 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width / 2 + 23 + tabBtnItem:getContentSize().width, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 80 - tabHeight)
        elseif index == 2 then
            tabBtnItem:setPosition(521, self.bgSize.height - tabBtnItem:getContentSize().height / 2 - 80 - tabHeight)
            
        end
        if index == self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index = index + 1
    end
    
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth / 2, self.bgLayer:getContentSize().height / 2 - 36))
    
end

function heroManagerDialog:initFunctionTb()
    
    self.heroTb1 = heroVoApi:getHeroList()
    self.heroTb2 = heroVoApi:getShowSoul()
    
    self.tvNum = SizeOfTable(self.heroTb1) + 1 + SizeOfTable(self.heroTb2)
    self.tvN = SizeOfTable(self.heroTb1) + 1
    
end

--设置对话框里的tableView
function heroManagerDialog:initTableView()
    self:initFunctionTb()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    local height = 0;
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 10, self.bgLayer:getContentSize().height - 25 - 120), nil)
    self.bgLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(30, 30))
    self.bgLayer:addChild(self.tv)
    
    self.tv:setMaxDisToBottomOrTop(120)
    
    if SizeOfTable(self.heroTb1) + SizeOfTable(self.heroTb2) == 0 then
        local noHeroLb = GetTTFLabel(getlocal("noHero"), 35)
        noHeroLb:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.bgLayer:getContentSize().height / 2))
        self.bgLayer:addChild(noHeroLb)
        noHeroLb:setColor(G_ColorGray)
    end
    
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function heroManagerDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.tvNum
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize
        tmpSize = CCSizeMake(400, 130)
        if idx == self.tvN - 1 then
            tmpSize = CCSizeMake(400, 80)
        end
        
        return tmpSize
        
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd, fn, idx)
            --return self:cellClick(idx)
        end
        
        if idx < self.tvN - 1 then
            local hei = 130
            local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, cellClick)
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, hei))
            backSprie:ignoreAnchorPointForPosition(false);
            backSprie:setAnchorPoint(ccp(0, 0));
            backSprie:setTag(1000 + idx)
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            cell:addChild(backSprie, 1)
            
            local mIcon = heroVoApi:getHeroIcon(self.heroTb1[idx + 1].hid, self.heroTb1[idx + 1].productOrder)
            mIcon:setAnchorPoint(ccp(0, 0.5))
            mIcon:setPosition(ccp(20, backSprie:getContentSize().height / 2))
            backSprie:addChild(mIcon)
            mIcon:setScale(0.6)
            local heroVo = self.heroTb1[idx + 1]
            local nameStr = getlocal(heroListCfg[heroVo.hid].heroName)
            if heroVoApi:isInQueueByHid(heroVo.hid) then
                nameStr = nameStr..getlocal("designate")
            end
            
            local xxx = 0
            local nameFontSize = 24
            if G_getCurChoseLanguage() == "ar" then
                nameFontSize = 22
                xxx = -10
            end
            local nameLb = GetTTFLabel(nameStr, nameFontSize, true)
            local color = heroVoApi:getHeroColor(heroVo.productOrder)
            nameLb:setColor(color)
            nameLb:setAnchorPoint(ccp(0, 0.5))
            nameLb:setPosition(ccp(xxx + mIcon:getContentSize().width, backSprie:getContentSize().height - 50))
            backSprie:addChild(nameLb)
            local lvStr = G_LV()..self.heroTb1[idx + 1].level.."/"..G_LV()..heroCfg.heroLevel[self.heroTb1[idx + 1].productOrder]
            local lvLb = GetTTFLabel(lvStr, 20)
            lvLb:setAnchorPoint(ccp(0, 0.5))
            lvLb:setPosition(ccp(xxx + mIcon:getContentSize().width, 30))
            backSprie:addChild(lvLb)
            
            local function callBack()
                if self.tv:getIsScrolled() == true then
                    do return end
                end
                require "luascript/script/game/scene/gamedialog/heroDialog/heroInfoDialog"
                local td = heroInfoDialog:new(self.heroTb1[idx + 1], self, self.layerNum + 1)
                
                local tbArr = {}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("heroManage"), true, self.layerNum + 1)
                sceneGame:addChild(dialog, self.layerNum + 1)
            end
            
            if base.he and base.he == 1 then
                
                local function openHeroEquipDialog()
                    if self.tv:getIsScrolled() == true then
                        do return end
                    end
                    require "luascript/script/game/scene/gamedialog/heroDialog/heroEquipDialog"
                    require "luascript/script/game/scene/gamedialog/heroDialog/heroEquipSmallDialog"
                    local td = heroEquipDialog:new((idx + 1), self.heroTb1, self)
                    local tbArr = {getlocal("upgrade"), getlocal("awaken")}
                    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("heroEquip"), true, self.layerNum + 1)
                    sceneGame:addChild(dialog, self.layerNum + 1)
                end
                
                local function clickEquipHandler()
                    local equipOpenLv = base.heroEquipOpenLv or 30
                    if playerVoApi:getPlayerLevel() >= equipOpenLv then
                    else
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("equip_open_condition", {equipOpenLv}), 28)
                        return
                    end
                    local function callbackHandler4(fn, data)
                        openHeroEquipDialog()
                    end
                    if heroEquipVoApi and heroEquipVoApi.ifNeedSendRequest == true then
                        heroEquipVoApi:equipGet(callbackHandler4)
                    else
                        openHeroEquipDialog()
                    end
                end
                local heroInfoBtn = GetButtonItem("mainBtnTask.png", "mainBtnTask_Down.png", "mainBtnTask_Down.png", callBack, 11, nil, 0)
                local heroInfoMenu = CCMenu:createWithItem(heroInfoBtn)
                heroInfoMenu:setAnchorPoint(ccp(0, 0))
                heroInfoMenu:setPosition(ccp(backSprie:getContentSize().width - 150, backSprie:getContentSize().height / 2))
                heroInfoMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                backSprie:addChild(heroInfoMenu, 1)
                
                if FuncSwitchApi:isEnabled("hero_equip") == true then
                    local equipBtn = GetButtonItem("equipBtn.png", "equipBtn_Down.png", "equipBtn_Down.png", clickEquipHandler, 11, nil, 0)
                    local equipMenu = CCMenu:createWithItem(equipBtn)
                    equipMenu:setAnchorPoint(ccp(0, 0))
                    equipMenu:setPosition(ccp(backSprie:getContentSize().width - equipBtn:getContentSize().width / 2 - 10, backSprie:getContentSize().height / 2))
                    equipMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                    backSprie:addChild(equipMenu, 1)
                    
                    if heroEquipVoApi:checkIfCanUpOrJinjieByHid(heroVo.hid, heroVo.productOrder) == true or heroEquipVoApi:checkIfCanAwakenByHid(heroVo.hid, heroVo.productOrder) == true then
                        local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
                        tipSp:setAnchorPoint(CCPointMake(1, 0.5))
                        tipSp:setPosition(ccp(equipBtn:getContentSize().width + 10, equipBtn:getContentSize().height - 10))
                        equipBtn:addChild(tipSp)
                    end
                else
                    heroInfoMenu:setPosition(backSprie:getContentSize().width - heroInfoBtn:getContentSize().width / 2 - 10, backSprie:getContentSize().height / 2)
                end
            else
                local selectAllItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", callBack, nil, getlocal("playerInfo"), 25 / 0.7)
                selectAllItem:setScale(0.7)
                selectAllItem:setAnchorPoint(ccp(1, 0.5))
                local selectAllBtn = CCMenu:createWithItem(selectAllItem);
                selectAllBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
                selectAllBtn:setPosition(ccp(backSprie:getContentSize().width - 10, backSprie:getContentSize().height / 2))
                backSprie:addChild(selectAllBtn)
            end
            
        elseif idx > self.tvN - 1 then
            
            local hei = 130
            local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, cellClick)
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, hei))
            backSprie:ignoreAnchorPointForPosition(false);
            backSprie:setAnchorPoint(ccp(0, 0));
            backSprie:setTag(1000 + idx)
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            cell:addChild(backSprie, 1)
            
            local sVo = self.heroTb2[idx - self.tvN + 1]
            local hid = heroCfg.soul2hero[sVo.sid]
            
            local mIcon = heroVoApi:getHeroIcon(hid, 1, false, nil, true)
            mIcon:setAnchorPoint(ccp(0, 0.5))
            mIcon:setPosition(ccp(20, backSprie:getContentSize().height / 2))
            backSprie:addChild(mIcon)
            mIcon:setScale(0.6)
            
            local nameLb = GetTTFLabel(getlocal(heroListCfg[hid].heroName), 24, true)
            nameLb:setAnchorPoint(ccp(0, 0.5))
            nameLb:setPosition(ccp(0 + mIcon:getContentSize().width, backSprie:getContentSize().height - 30))
            backSprie:addChild(nameLb)
            
            local sid = self.heroTb2[idx - self.tvN + 1].sid
            local num = self.heroTb2[idx - self.tvN + 1].num
            local maxNum = heroListCfg[heroCfg.soul2hero[sid]].fusion.soul[sid]
            local str = num.."/"..maxNum
            
            AddProgramTimer(backSprie, ccp(282, 50), 10, 12, str, "VipIconYellowBarBg.png", "VipIconYellowBar.png", 11, 0.6)
            local timerSprite = tolua.cast(backSprie:getChildByTag(10), "CCProgressTimer")
            timerSprite:setPercentage(num * 100 / maxNum)
            local proLb = tolua.cast(timerSprite:getChildByTag(12), "CCLabelTTF")
            proLb:setScaleX(1 / 0.6)
            
            if num >= heroListCfg[heroCfg.soul2hero[sid]].fusion.soul[sid] then
                local function callBack()
                    local function callbackFusion(fn, data)
                        local ret, sData = base:checkServerData(data)
                        if ret == true then
                            local hid = heroCfg.soul2hero[sid]
                            local hData = {h = {}}
                            hData.h[hid] = heroListCfg[hid].fusion.p
                            local heroTb = FormatItem(hData)
                            if heroTb and heroTb[1] then
                                G_recruitShowHero(1, heroTb[1], self.layerNum + 1)
                            end
                            self:refresh()
                            heroVoApi:getNewHeroChat(hid)
                        end
                    end
                    socketHelper:heroFusion(hid, callbackFusion)
                end
                local selectAllItem = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", callBack, nil, getlocal("recruit"), 25 / 0.7)
                selectAllItem:setScale(0.7)
                selectAllItem:setAnchorPoint(ccp(1, 0.5))
                local selectAllBtn = CCMenu:createWithItem(selectAllItem);
                selectAllBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
                selectAllBtn:setPosition(ccp(backSprie:getContentSize().width - 10, backSprie:getContentSize().height / 2))
                backSprie:addChild(selectAllBtn)
                
            end
            
        else
            if SizeOfTable(self.heroTb2) > 0 then
                local qualityLb = GetTTFLabelWrap(getlocal("noRecruit"), 26, CCSizeMake(400, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                qualityLb:setPosition(ccp(300, 40))
                qualityLb:setColor(G_ColorGreen)
                cell:addChild(qualityLb)
            end
            
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end

function heroManagerDialog:refresh()
    if self and self.tv then
        self.heroTb1 = heroVoApi:getHeroList()
        self.heroTb2 = heroVoApi:getShowSoul()
        self.tvNum = SizeOfTable(self.heroTb1) + 1 + SizeOfTable(self.heroTb2)
        self.tvN = SizeOfTable(self.heroTb1) + 1
        
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
    
end

--点击tab页签 idx:索引
function heroManagerDialog:tabClick(idx)
    if newGuidMgr:isNewGuiding() then --新手引导
        if newGuidMgr.curStep == 39 and idx ~= 1 then
            do
                return
            end
        end
    end
    PlayEffect(audioCfg.mouseClick)
    
    for k, v in pairs(self.allTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
            self:tabClickColor(idx)
            self:doUserHandler()
            self:getDataByType(idx)
            
        else
            v:setEnabled(true)
        end
    end
    
    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function heroManagerDialog:doUserHandler()
    
end

--点击了cell或cell上某个按钮
function heroManagerDialog:cellClick(idx)
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

function heroManagerDialog:tick()
    
end

function heroManagerDialog:dispose()
    self.expandIdx = nil
    
    self = nil
    
end
