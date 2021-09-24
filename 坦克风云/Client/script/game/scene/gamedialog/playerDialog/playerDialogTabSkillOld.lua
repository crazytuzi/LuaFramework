--旧技能系统的页签
playerDialogTabSkillOld = {}

function playerDialogTabSkillOld:new(parent)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    nc.tv = nil;
    nc.bgLayer = nil;
    nc.tableCell2 = {};
    nc.tableCellItem2 = {};
    nc.layerNum = nil;
    nc.parent = parent
    nc.isGuide = nil;
    nc.skillBtn = nil;
    nc.index = nil;
    nc.oldSkillCfg = nil
    return nc;
end

function playerDialogTabSkillOld:init(layerNum, isGuide)
    
    self.isGuide = isGuide;
    self.bgLayer = CCLayer:create();
    self.layerNum = layerNum;
    self.oldSkillCfg = {}
    for i = 1, 12 do
        local skillCfg = playerSkillCfg.skillList["s" .. (100 + i)]
        self.oldSkillCfg[i] = skillCfg
    end
    self:initTableView();
    
    if newGuidMgr:isNewGuiding() == true and self.guideItem then
        newGuidMgr:setGuideStepField(40, self.guideItem)
    end
    
    local function touch1()
        
        PlayEffect(audioCfg.mouseClick)
        
        if skillVoApi:getSkillIsAllZero() == true then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("no_skill_to_clear"), true, self.layerNum + 1)
            do
                return
            end
        end
        
        local function reset()
            local function callback()
                self:refreshTableCell2()
                self:checkItemEnable()
            end
            skillVoApi:reset(callback)
        end
        
        local function buyGems()
            if G_checkClickEnable() == false then
                do
                    return
                end
            end
            vipVoApi:showRechargeDialog(self.layerNum + 1)
            
        end
        if playerVo.gems < 28 then
            local num = 28 - playerVo.gems
            local smallD = smallDialog:new()
            smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), buyGems, getlocal("dialog_title_prompt"), getlocal("gemNotEnough", {28, playerVo.gems, num}), nil, self.layerNum + 1)
        else
            local smallD = smallDialog:new()
            smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), reset, getlocal("dialog_title_prompt"), getlocal("player_info_clear_skill_tip", {28}), nil, self.layerNum + 1)
        end
        
    end
    local function touch2()
        --[[
            if self.tv:getIsScrolled()==true then
                    return
            end
            ]]
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        
        self.parent:close();
        local td = shopVoApi:showPropDialog(self.layerNum, true)
        td:tabClick(1)
        td:tabSubClick(13)
        PlayEffect(audioCfg.mouseClick)
    end
    
    local menuItem1 = GetButtonItem("BtnOkSmall.png", "BtnOkSmall_Down.png", "BtnOkSmall_Down.png", touch1, 10, getlocal("player_info_clear_skill"), 30)
    local menu1 = CCMenu:createWithItem(menuItem1);
    menu1:setPosition(ccp(320, 110));
    menu1:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
    self.bgLayer:addChild(menu1, 1);
    menu1:setTag(21)
    
    local menuItem2 = GetButtonItem("BtnOkSmall.png", "BtnOkSmall_Down.png", "BtnOkSmall_Down.png", touch2, 11, getlocal("player_info_shopping"), 30)
    local menu2 = CCMenu:createWithItem(menuItem2);
    menu2:setPosition(ccp(510, 110));
    menu2:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
    self.bgLayer:addChild(menu2, 3);
    menu2:setTag(22)
    
    local function touch3()
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable == false then
            return
        end
        
        -- 服务器交互代码
        local function autoUpdate()
            local function serverAutoUpdate()
                self:refreshTableCell2()
                self:checkItemEnable()
            end
            skillVoApi:autoUpgrade(serverAutoUpdate)
        end
        -- local minID,minLv
        -- for k,v in pairs(self.oldSkillCfg) do
        --     local lv=skillVoApi:getAllSkills()["s"..v.sid].lv
        --     if(minLv==nil or lv<minLv)then
        --         minID=v.sid
        --         minLv=lv
        --     elseif(lv==minLv and v.sid<minID)then
        --         minID=v.sid
        --     end
        -- end
        -- minID="s"..minID
        -- local skillName = skillVoApi:getSkillNameById(minID)
        
        -- local updateToLevel = minLv
        -- local medalNum = bagVoApi:getItemNumId(19)
        -- while updateToLevel<playerVoApi:getPlayerLevel() do
        --     medalNum = medalNum - updateToLevel - 1
        --     if medalNum < 0 then
        --         break
        --     else
        --         updateToLevel = updateToLevel + 1
        --     end
        -- end
        
        local smallD = smallDialog:new()
        smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), autoUpdate, getlocal("dialog_title_prompt"), getlocal("nbSkill_autoUpgrade"), nil, self.layerNum + 1, nil, nil, nil, nil, nil, nil, true)
        
    end
    local btnSize = 30
    if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" then
        btnSize = 25
    end
    self.menuItem3 = GetButtonItem("BtnOkSmall.png", "BtnOkSmall_Down.png", "BtnOkSmall_Down.png", touch3, 11, getlocal("hero_skills_automatic_update"), btnSize)
    local menu3 = CCMenu:createWithItem(self.menuItem3);
    menu3:setPosition(ccp(130, 110))
    menu3:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
    self.bgLayer:addChild(menu3, 3);
    menu3:setTag(23)
    
    self:checkItemEnable()
    
    local honorLb = GetTTFLabel(getlocal("currentMedal", {bagVoApi:getItemNumId(19)}), 32)
    honorLb:setPosition(ccp(310, 50))
    self.bgLayer:addChild(honorLb, 1)
    honorLb:setTag(23)
    
    return self.bgLayer
end

-- 根据荣誉勋章数判断item是否可点击
function playerDialogTabSkillOld:checkItemEnable()
    local minID, minLv
    for k, v in pairs(self.oldSkillCfg) do
        local lv = skillVoApi:getAllSkills()["s"..v.sid].lv
        if(minLv == nil or lv < minLv)then
            minID = v.sid
            minLv = lv
        elseif(lv == minLv and v.sid < minID)then
            minID = v.sid
        end
    end
    minID = "s"..minID
    local playerLevel = playerVoApi:getPlayerLevel()
    local lvRequire = skillVoApi:getLvRequireByIdAndLv(minID)
    local propNeedNum = skillVoApi:getPropRequireByIdAndLv(minID)["p19"]
    if lvRequire > playerLevel or bagVoApi:getItemNumId(19) < propNeedNum then
        self.menuItem3 :setEnabled(false)
    else
        self.menuItem3 :setEnabled(true)
    end
end

function playerDialogTabSkillOld:initTableView()
    
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    local height = 0;
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 10, G_VisibleSize.height - 85 - 250), nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(30, 160))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function playerDialogTabSkillOld:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        -- return SizeOfTable(skillVoApi:getAllSkills())
        return 12
        
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize
        tmpSize = CCSizeMake(400, 150)
        return tmpSize
        
    elseif fn == "tableCellAtIndex" then
        
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd, fn, idx)
            --return self:cellClick(idx)
        end
        
        local hei = 150 - 4
        
        local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, cellClick)
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, hei))
        backSprie:ignoreAnchorPointForPosition(false);
        backSprie:setAnchorPoint(ccp(0, 0));
        backSprie:setTag(1000 + idx)
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        cell:addChild(backSprie, 1)
        
        self.tableCell2[idx + 1] = cell
        local strName;
        local numName = idx + 1
        if idx < 9 then
            strName = "skill_0"..numName..".png"
        else
            strName = "skill_"..numName..".png"
        end
        
        local skillImage = CCSprite:createWithSpriteFrameName(strName);
        skillImage:setAnchorPoint(ccp(0, 0.5));
        skillImage:setPosition(ccp(10, 72));
        cell:addChild(skillImage, 2);
        
        local skillNameStr = getlocal(self.oldSkillCfg[idx + 1].name)..getlocal("fightLevel", {skillVoApi:getAllSkills()["s" .. (101 + idx)].lv})
        local nameLb = GetTTFLabelWrap(skillNameStr, 28, CCSizeMake(28 * 16, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop);
        nameLb:setAnchorPoint(ccp(0, 1));
        nameLb:setPosition(ccp(120, 130));
        cell:addChild(nameLb, 2);
        nameLb:setTag(101)
        
        local addValue = skillVoApi:getSkillAddPerStrById("s" .. (101 + idx))
        addValue = string.gsub(addValue, "%%", "%%%%")
        local skillNameStrDesc = getlocal(self.oldSkillCfg[idx + 1].description1, {addValue})
        local descLb = GetTTFLabelWrap(skillNameStrDesc, 22, CCSizeMake(22 * 12, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop);
        descLb:setAnchorPoint(ccp(0, 1));
        descLb:setPosition(ccp(120, 60));
        cell:addChild(descLb, 2);
        descLb:setTag(102)
        
        local function touch1()
            if self.tv:getIsScrolled() == true then
                return
            end
            
            PlayEffect(audioCfg.mouseClick)
            local lvRequire = skillVoApi:getLvRequireByIdAndLv("s" .. (101 + idx))
            local propRequire = skillVoApi:getPropRequireByIdAndLv("s" .. (101 + idx))
            local propNeedNum = propRequire["p19"]
            
            if tonumber(propNeedNum) <= tonumber(bagVoApi:getItemNumId(19)) and lvRequire <= tonumber(playerVoApi:getPlayerLevel()) then
                local sid = "s" .. (idx + 101)
                local function serverUpgradeSkill()
                    --统计使用物品
                    statisticsHelper:useItem("p19", propNeedNum)
                    self:refreshTableCell2()
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("skillLevelUp", {getlocal(self.oldSkillCfg[idx + 1].name), skillVoApi:getAllSkills()["s" .. (idx + 101)].lv}), 28)
                    self:checkItemEnable()
                    if newGuidMgr:isNewGuiding() then
                        if idx == 0 then
                            newGuidMgr:toNextStep()
                        end
                    end
                end
                skillVoApi:upgrade(sid, nil, serverUpgradeSkill)
            end
            
        end
        
        local function touch2()
            if self.tv:getIsScrolled() == true then
                do
                    return
                end
            end
            if newGuidMgr:isNewGuiding() then --新手引导
                do
                    return
                end
            end
            local tabStr = {};
            local tabColor = {};
            
            PlayEffect(audioCfg.mouseClick)
            local td = smallDialog:new()
            if skillVoApi:getAllSkills()["s" .. (idx + 101)].lv < playerVoApi:getMaxLvByKey("roleMaxLevel") then
                --tip_levelRequire
                local sid = "s" .. (idx + 101)
                local propRequire = skillVoApi:getPropRequireByIdAndLv(sid)
                local propNeedNum = propRequire["p19"]
                local str1 = getlocal("tip_propConsumeNum", {propNeedNum})
                local lvRequire = skillVoApi:getLvRequireByIdAndLv(sid)
                
                local str2 = getlocal("tip_levelRequire", {lvRequire})
                local str3 = getlocal("tip_levelUpRequire")
                
                local skillNameStrDesc = getlocal(self.oldSkillCfg[idx + 1].description);
                local str4 = skillNameStrDesc
                local str5 = getlocal(self.oldSkillCfg[idx + 1].name)..getlocal("fightLevel", {skillVoApi:getAllSkills()["s" .. (idx + 101)].lv})
                
                tabStr = {str1, str2, str3, " ", str4, str5, " "}
                tabColor = {}
                if propNeedNum > bagVoApi:getItemNumId(19) then
                    table.insert(tabColor, 1, G_ColorRed)
                end
                if lvRequire > tonumber(playerVoApi:getPlayerLevel()) then
                    table.insert(tabColor, 2, G_ColorRed)
                end
                
            else
                local str1 = getlocal("show_tip_maxlevel")
                tabStr = {" ", str1, " "};
            end
            
            local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 28, tabColor)
            --dialog:setPosition(getCenterPoint(sceneGame))
            sceneGame:addChild(dialog, self.layerNum + 1)
            
        end
        
        local menuItem1 = GetButtonItem("BtnUp.png", "BtnUp_Down.png", "BtnUp_Down.png", touch1, 10, nil, nil)
        local menu1 = CCMenu:createWithItem(menuItem1);
        menu1:setPosition(ccp(520, 55));
        menu1:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
        cell:addChild(menu1, 3);
        self.tableCellItem2[idx + 1] = menuItem1
        local sid = "s" .. (idx + 101)
        local propRequire = skillVoApi:getPropRequireByIdAndLv(sid)
        local propNeedNum = propRequire["p19"]
        local lvRequire = skillVoApi:getLvRequireByIdAndLv(sid)
        if skillVoApi:getAllSkills()[sid].lv < playerVoApi:getMaxLvByKey("roleMaxLevel") then
            if propNeedNum > bagVoApi:getItemNumId(19) or lvRequire > tonumber(playerVoApi:getPlayerLevel()) then
                menuItem1:setEnabled(false)
            end
        else
            menuItem1:setEnabled(false)
        end
        if idx == 0 then
            self.guideItem = menuItem1
        end
        if self.isGuide == true then
            if menuItem1:isEnabled() == true then
                self.skillBtn = menuItem1;
                self.index = idx + 1;
                self.isGuide = 2;
            end
        end
        if self.index ~= nil and self.index == idx + 1 then
            local scale = (menuItem1:getContentSize().width + 10) / 40
            G_addFlicker(menuItem1, scale, scale, ccp(menuItem1:getContentSize().width / 2, menuItem1:getContentSize().height / 2))
        end
        
        local menuItem2 = GetButtonItem("BtnInfor.png", "BtnInfor_Down.png", "BtnInfor_Down.png", touch2, 11, nil, nil)
        local menu2 = CCMenu:createWithItem(menuItem2);
        menu2:setPosition(ccp(430, 55));
        menu2:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
        cell:addChild(menu2, 3);
        
        return cell;
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    elseif fn == "ccScrollEnable" then
        if newGuidMgr:isNewGuiding() == true then
            return 0
        else
            return 1
        end
    end
    
end
function playerDialogTabSkillOld:removeGuied()
    G_removeFlicker(self.skillBtn)
    self.skillBtn = nil;
    self.index = nil;
end
function playerDialogTabSkillOld:recordPoint()
    if self.index ~= nil and self.index > 4 then
        local yy = (self.index - 4) * 150
        self.tv:recoverToRecordPoint(ccp(0, -1185 + yy))
    end
end

function playerDialogTabSkillOld:refreshTableCell2()
    
    self:removeGuied()
    for k, v in pairs(self.tableCell2) do
        local cell = self.tableCell2[k]
        local lab1 = cell:getChildByTag(101);
        lab1 = tolua.cast(lab1, "CCLabelTTF")
        local sid = "s" .. (100 + k)
        local skillNameStr = getlocal(self.oldSkillCfg[k].name)..getlocal("fightLevel", {skillVoApi:getAllSkills()[sid].lv})
        lab1:setString(skillNameStr)
        
        local lab2 = cell:getChildByTag(102);
        lab2 = tolua.cast(lab2, "CCLabelTTF")
        local addValue = skillVoApi:getSkillAddPerStrById(sid)
        addValue = string.gsub(addValue, "%%", "%%%%")
        local skillNameStrDesc = getlocal(self.oldSkillCfg[k].description1, {addValue});
        lab2:setString(skillNameStrDesc)
        
        local menuItem1 = self.tableCellItem2[k]
        menuItem1 = tolua.cast(menuItem1, "CCMenuItem")
        local propRequire = skillVoApi:getPropRequireByIdAndLv(sid)
        local propNeedNum = propRequire["p19"]
        local lvRequire = skillVoApi:getLvRequireByIdAndLv(sid)
        if skillVoApi:getAllSkills()[sid].lv < playerVoApi:getMaxLvByKey("roleMaxLevel") then
            if propNeedNum > bagVoApi:getItemNumId(19) or lvRequire > tonumber(playerVoApi:getPlayerLevel()) then
                menuItem1:setEnabled(false)
            else
                menuItem1:setEnabled(true)
            end
        else
            menuItem1:setEnabled(false)
        end
        --[[
                if tonumber(levelRequireTab[skillVoApi:getAllSkills()[k].level+1])>tonumber(playerVoApi:getPlayerLevel()) then
                    menuItem1:setEnabled(false)
                else
                     menuItem1:setEnabled(true)
                end]]
        
    end
    
    local honorLb = self.bgLayer:getChildByTag(23);
    honorLb = tolua.cast(honorLb, "CCLabelTTF")
    honorLb:setString(getlocal("currentMedal", {bagVoApi:getItemNumId(19)}))
    
end

function playerDialogTabSkillOld:tick()
    local honorLb = self.bgLayer:getChildByTag(23);
    if(honorLb)then
        honorLb = tolua.cast(honorLb, "CCLabelTTF")
        honorLb:setString(getlocal("currentMedal", {bagVoApi:getItemNumId(19)}))
    end
end

--用户处理特殊需求,没有可以不写此方法
function playerDialogTabSkillOld:doUserHandler()
    
end

--点击了cell或cell上某个按钮
function playerDialogTabSkillOld:cellClick(idx)
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

function playerDialogTabSkillOld:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer = nil;
    self.tv = nil;
    self.tableCell2 = {};
    self.tableCell2 = nil;
    self.tableCellItem2 = {};
    self.tableCellItem2 = nil;
    self.layerNum = nil;
    self.guideItem = nil
end
