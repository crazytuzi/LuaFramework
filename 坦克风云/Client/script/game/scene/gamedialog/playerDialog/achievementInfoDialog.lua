--指定成就线的成就信息
achievementInfoDialog = commonDialog:new()

--atype：1个人，2全服，avtId成就线的id，selectIdx跳转的成就id
function achievementInfoDialog:new(atype, avtId, parent, selectIdx)
    local nc = {
        atype = atype, 
        avtId = avtId, 
        parent = parent, 
        selectIdx = selectIdx, 
    }
    setmetatable(nc, self)
    self.__index = self
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/avt_images.plist")
    spriteController:addTexture("public/avt_images.png")
    spriteController:addPlist("public/avt_images1.plist")
    spriteController:addTexture("public/avt_images1.png")
    spriteController:addPlist("public/avt_images2.plist")
    spriteController:addTexture("public/avt_images2.png")
    spriteController:addPlist("public/youhuaUI4.plist")
    spriteController:addTexture("public/youhuaUI4.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    return nc
end

function achievementInfoDialog:reloadData()
    if self.atype == 2 then
        self.subIndex = 1
        self.index = 1
    end
    self.canActivateTb = nil
    if self.tv then
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function achievementInfoDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight - 82)
    local panelBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png", CCRect(30, 0, 2, 3), function ()end)
    panelBg:setAnchorPoint(ccp(0.5, 0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 85))
    panelBg:setPosition(G_VisibleSizeWidth / 2, 5)
    self.bgLayer:addChild(panelBg)
    if self.atype == 1 then
        self.avtCfg = achievementVoApi:getPersonAvtCfgById(self.avtId)
    elseif self.atype == 2 then
        self.avtCfg = achievementVoApi:getServerAvtCfgById(self.avtId)
        self.subIndex = 1
        self.index = 1
    end
    self.canActivateTb = nil
    
    local avtEffectLevel = achievementVoApi:getNextEffectUnlockLv()
    
    local function buttonHandler(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        achievementVoApi:socketAchievementReward(self.atype, self.avtId, function()
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("achievement_reward_tip"), 30)
                
                if self.canActivateTb then
                    self.button:setEnabled(false)
                    for k, v in pairs(self.canActivateTb) do
                        local _callback
                        local _cupIcon = v[1]
                        local _reward = v[2]
                        if k == SizeOfTable(self.canActivateTb) then
                            _callback = function()
                                if (avtEffectLevel == nil or achievementVoApi:getAchievementLv() >= avtEffectLevel) and self.parent and self.parent.showMainLayer then
                                    self:close()
                                    self.parent:showMainLayer()
                                else
                                    self:reloadData()
                                end
                            end
                        end
                        G_playBoomAction(_cupIcon, ccp(_cupIcon:getContentSize().width / 2, _cupIcon:getContentSize().height / 2), _callback, 0.6, 1.8)
                        if _reward then
                            local rewardTb = FormatItem(_reward)
                            for m, n in pairs(rewardTb) do
                                G_addPlayerAward(n.type, n.key, n.id, tonumber(n.num), nil, true)
                            end
                        end
                    end
                end
                
        end)
    end
    local strSize = 24
    if G_isAsia() == false then
        strSize = 18
    end
    local btnScale = 0.8
    self.button = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", buttonHandler, 11, getlocal("achievement_info_buttonStr"), strSize / btnScale)
    self.button:setScale(btnScale)
    self.button:setAnchorPoint(ccp(0.5, 0.5))
    local menu = CCMenu:createWithItem(self.button)
    menu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    menu:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 30 + self.button:getContentSize().height * btnScale / 2))
    self.bgLayer:addChild(menu)
    self.button:setEnabled(false)
    
    local function tvCallBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 108 - self.button:getContentSize().height * btnScale - 35), nil)
    self.tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(0, 20 + self.button:getContentSize().height * btnScale + 35)
    self.tv:setMaxDisToBottomOrTop(100)
    self.bgLayer:addChild(self.tv)
end

function achievementInfoDialog:getCellNum()
    if self.cellNum == nil then
        self.cellNum = 0
        if self.avtCfg then
            if self.atype == 1 then
                self.cellNum = SizeOfTable(self.avtCfg.needNum)
            elseif self.atype == 2 then
                for k, v in pairs(self.avtCfg.num) do
                    self.cellNum = self.cellNum + SizeOfTable(v)
                end
            end
        end
    end
    return self.cellNum
end

function achievementInfoDialog:getDesc(ownNum, needNum, subNeedNum, index)
    local descStr, descColorTab
    local _numColor = (ownNum >= needNum) and G_ColorGreen or G_ColorRed
    --needType 1:总个数, 2:总等级
    if self.avtCfg.type == "aitroops" then
        local level = nil
        local _needType = 1

        if self.avtId == "a15" then
            level = self.avtCfg.level
            if self.atype == 2 then
                local personAvtCfg = achievementVoApi:getPersonAvtCfgById(self.avtId)
                level = personAvtCfg.level
            end
        else
            level = self.avtCfg.value
            if self.atype == 2 then
                local personAvtCfg = achievementVoApi:getPersonAvtCfgById(self.avtId)
                level = personAvtCfg.value
            end
            _needType = 2
        end

        local params = {}
        if self.atype == 2 then
            table.insert(params, subNeedNum)
        end

        if level then
            table.insert(params, level)
        end
        table.insert(params, ownNum)
        table.insert(params, needNum)
        descColorTab = { nil, _numColor, nil }
        descStr = getlocal("achievement_aitroops_" .. self.atype .. "_infoDes_" .. _needType, params)
    elseif self.avtCfg.type == "accessory" then --配件
        local _needType = 1
        local level = nil
        if self.avtId == "a12" then
            local _color = self.avtCfg.color
            if self.atype == 2 then
                local personAvtCfg = achievementVoApi:getPersonAvtCfgById(self.avtId)
                _color = personAvtCfg.color
            end    
            level = getlocal("armorMatrix_color_" .. _color)
        else
            level = self.avtCfg.level
            if self.atype == 2 then
                local personAvtCfg = achievementVoApi:getPersonAvtCfgById(self.avtId)
                level = personAvtCfg.level
            end
            _needType = self.avtId == "a13" and 2 or 3
        end
 
        local params = {}
        if self.atype == 2 then
            table.insert(params, subNeedNum)
        end

        if level then
            table.insert(params, level)
        end
        table.insert(params, ownNum)
        table.insert(params, needNum)
        descColorTab = { nil, _numColor, nil }
         descStr = getlocal("achievement_accessory_" .. self.atype .. "_infoDes_" .. _needType, params)
    elseif self.avtCfg.type == "armor" then --装甲矩阵
        local _color = self.avtCfg.color
        local _needType = self.avtCfg.needType
        local personAvtCfg
        if self.atype == 2 then
            local personAvtCfg = achievementVoApi:getPersonAvtCfgById(self.avtId)
            _color = personAvtCfg.color
            _needType = personAvtCfg.needType
        end
        
        local params = {}
        
        table.insert(params, getlocal("armorMatrix_color_" .. _color))
        if self.atype == 2 then
            table.insert(params, subNeedNum)
        end
        table.insert(params, ownNum)
        table.insert(params, needNum)
        
        if self.atype == 1 then
            if _needType == 1 then
                descColorTab = {nil, armorMatrixVoApi:getColorByQuality(_color), _numColor, nil}
            elseif _needType == 2 then
                descColorTab = {nil, armorMatrixVoApi:getColorByQuality(_color), nil, _numColor}
            end
        elseif self.atype == 2 then
            descColorTab = {nil, armorMatrixVoApi:getColorByQuality(_color), nil, _numColor}
        end
        descStr = getlocal("achievement_armor_" .. self.atype .. "_infoDes_" .. _needType, params)
    elseif self.avtCfg.type == "sequip" then --军徽
        local _color = self.avtCfg.color
        local _addLvStr = self.avtCfg.level and ("+" .. self.avtCfg.level) or ""
        if self.atype == 2 then
            local personAvtCfg = achievementVoApi:getPersonAvtCfgById(self.avtId)
            _color = personAvtCfg.color
            _addLvStr = personAvtCfg.level and ("+" .. personAvtCfg.level) or ""
        end
        
        local params = {}
        
        table.insert(params, getlocal("armorMatrix_color_" .. _color))
        table.insert(params, _addLvStr)
        if self.atype == 2 then
            table.insert(params, subNeedNum)
        end
        table.insert(params, ownNum)
        table.insert(params, needNum)
        
        if self.atype == 1 then
            descColorTab = {nil, emblemVoApi:getColorByQuality(_color), _numColor, nil}
        elseif self.atype == 2 then
            descColorTab = {nil, emblemVoApi:getColorByQuality(_color), nil, _numColor}
        end
        descStr = getlocal("achivement_sequip_" .. self.atype .. "_infoDes", params)
    elseif self.avtCfg.type == "weapon" then --超级武器
        local params = {}
        
        local _subType = self.avtCfg.subType
        if self.atype == 2 then
            local personAvtCfg = achievementVoApi:getPersonAvtCfgById(self.avtId)
            _subType = personAvtCfg.subType
            table.insert(params, subNeedNum)
        end
        table.insert(params, ownNum)
        table.insert(params, needNum)
        
        if _subType == "c" then
            descStr = getlocal("achivement_weapon_" .. self.atype .. "_infoDes_2", params)
        else
            descStr = getlocal("achivement_weapon_" .. self.atype .. "_infoDes_1", params)
        end
        descColorTab = {nil, _numColor}
    elseif self.avtCfg.type == "hero" then --将领英雄
        local _color = self.avtCfg.color
        local _subType = self.avtCfg.subType
        
        if self.atype == 2 then
            local personAvtCfg = achievementVoApi:getPersonAvtCfgById(self.avtId)
            _color = personAvtCfg.color
            _subType = personAvtCfg.subType
        end
        local params = {}
        if _subType == "e" then
        	local _cfg = self.avtCfg
        	if self.atype == 2 then
        		_cfg = achievementVoApi:getPersonAvtCfgById(self.avtId)
        	end
        	table.insert(params, _cfg.value)
        else
	        if _color then
	            table.insert(params, _color)
	        end
    	end
        if self.atype == 2 then
            table.insert(params, subNeedNum)
        end
        table.insert(params, ownNum)
        table.insert(params, needNum)
        descColorTab = { nil, _numColor, nil }
        if _subType == "e" then
            descStr = getlocal("achievement_hero_" .. self.atype .. "_infoDes_2", params)
        else
            descStr = getlocal("achievement_hero_" .. self.atype .. "_infoDes_1", params)
        end
    elseif self.avtCfg.type == "plane" then --飞机
        local _color = self.avtCfg.color
        local _addLvStr = self.avtCfg.level and ("+" .. self.avtCfg.level) or ""
        local _subType = self.avtCfg.subType
        if self.atype == 2 then
            local personAvtCfg = achievementVoApi:getPersonAvtCfgById(self.avtId)
            _color = personAvtCfg.color
            _addLvStr = personAvtCfg.level and ("+" .. personAvtCfg.level) or ""
            _subType = personAvtCfg.subType
        end
        local params = {}
        if _subType ~= "f" then
            if _color then
                table.insert(params, getlocal("armorMatrix_color_" .. _color))
            end
            table.insert(params, _addLvStr)
        end
        if self.atype == 2 then
            table.insert(params, subNeedNum)
        end
        table.insert(params, ownNum)
        table.insert(params, needNum)
        if _subType == "f" then
            descColorTab = { nil, _numColor, nil }
            descStr = getlocal("achievement_plane_" .. self.atype .. "_infoDes_2", params)
        else
            descColorTab = { nil, planeVoApi:getColorByQuality(_color), nil, _numColor, nil }
            descStr = getlocal("achievement_plane_"  .. self.atype .. "_infoDes_1", params)
        end
    end
    return descStr, descColorTab
end

function achievementInfoDialog:eventHandler(handler, fn, index, cel)
    if fn == "numberOfCellsInTableView" then
        return self:getCellNum()
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth, 270)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellW, cellH = G_VisibleSizeWidth, 270
        
        local fontSize = 22
        
        local _state
        local cupIcon
        local avtLevel
        if self.atype == 1 then
            _state = achievementVoApi:getAvtState(self.atype, self.avtId, index + 1)
            avtLevel = self.avtCfg.addLevel[index + 1]
            cupIcon = achievementVoApi:getAvtShowIcon(self.atype, self.avtId, index + 1, nil, nil, _state)
        elseif self.atype == 2 then
            if self.avtCfg.num[self.index] == nil then
                self.index = 1
            end
            if self.avtCfg.addLevel[self.index] and self.avtCfg.addLevel[self.index][self.subIndex] == nil then
                self.subIndex = 1
                self.index = self.index + 1
            end
            _state = achievementVoApi:getAvtState(self.atype, self.avtId, self.index, self.subIndex)
            avtLevel = self.avtCfg.addLevel[self.index][self.subIndex]
            cupIcon = achievementVoApi:getAvtShowIcon(self.atype, self.avtId, self.index, self.subIndex, nil, _state)
        end
        
        local cellBg
        if _state == 2 then
            cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png", CCRect(19, 19, 2, 2), function()end)
        else
            cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("newKuang2.png", CCRect(7, 7, 1, 1), function()end)
        end
        cellBg:setContentSize(CCSizeMake(cellW - 40, 208))
        cellBg:setPosition(cellW / 2, cellH / 2)
        cell:addChild(cellBg)
        
        local personAvts = achievementVoApi:getPersonAvtData()
        local ownNum = 0
        local needNum = 0
        local subNeedNum = nil
        local reward = nil
        
        if self.atype == 1 then
            if personAvts.uinfo and personAvts.uinfo[self.avtId] then
                ownNum = personAvts.uinfo[self.avtId]
            end
            needNum = self.avtCfg.needNum[index + 1]
            reward = self.avtCfg.reward[index + 1]
        elseif self.atype == 2 then
            local serverAvts = achievementVoApi:getServerAvtData()
            if serverAvts[self.avtId] and serverAvts[self.avtId][self.index] then
                ownNum = serverAvts[self.avtId][self.index]
            end
            needNum = self.avtCfg.num[self.index][self.subIndex]
            local personAvtCfg = achievementVoApi:getPersonAvtCfgById(self.avtId)
            subNeedNum = personAvtCfg.needNum[self.index]
            reward = self.avtCfg.reward[self.index][self.subIndex]
        end
        
        local _posX = 0
        if cupIcon then
            cupIcon:setAnchorPoint(ccp(0, 0.5))
            cupIcon:setPosition(0, cellBg:getContentSize().height / 2)
            cellBg:addChild(cupIcon, 2)
            
            local stateStr, color = getlocal("emblem_noHad"), G_ColorWhite
            if _state == 2 then
                local _getTime = 0
                if self.atype == 1 then
                    _getTime = achievementVoApi:getActivateTimeById(self.atype, self.avtId, index + 1)
                elseif self.atype == 2 then
                    _getTime = achievementVoApi:getActivateTimeById(self.atype, self.avtId, self.index, self.subIndex)
                end
                stateStr, color = getlocal("activity_xinfulaba_PlayerName", {G_getDateStr(_getTime, true, true)}), G_ColorGray2
            elseif _state == 1 then
                stateStr, color = getlocal("achievement_isActivate"), G_LowfiColorGreen
            end
            local stateLb = GetTTFLabelWrap(stateStr, 18, CCSizeMake(cupIcon:getContentSize().width - 5, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
            stateLb:setPosition(cupIcon:getContentSize().width / 2, 25)
            stateLb:setColor(color)
            cupIcon:addChild(stateLb)
            if _state == 1 then
                if self.canActivateTb == nil then
                    self.canActivateTb = {}
                end
                table.insert(self.canActivateTb, {cupIcon, reward})
                if self.button then
                    self.button:setEnabled(true)
                end
            end
            
            _posX = cupIcon:getPositionX() + cupIcon:getContentSize().width + 10
            if self.selectIdx and self.selectIdx == (index + 1) then --跳转选中的成就id
                local selectSp = LuaCCScale9Sprite:createWithSpriteFrameName("planeSkillSelectBg.png", CCRect(4, 4, 1, 1), function ()end)
                selectSp:setContentSize(CCSizeMake(cupIcon:getContentSize().width + 6, cupIcon:getContentSize().height + 6))
                selectSp:setPosition(cupIcon:getPositionX() + cupIcon:getContentSize().width / 2, cupIcon:getPositionY())
                cellBg:addChild(selectSp)
                local acArr = CCArray:create()
                local fadeOut = CCFadeOut:create(0.5)
                local fadeIn = CCFadeIn:create(0.5)
                acArr:addObject(fadeOut)
                acArr:addObject(fadeIn)
                acArr:addObject(CCDelayTime:create(0.2))
                local seq = CCSequence:create(acArr)
                selectSp:runAction(CCRepeatForever:create(seq))
            end
        end
        
        local descStr, descColorTab = self:getDesc(ownNum, needNum, subNeedNum, (self.atype == 1) and (index + 1) or self.index)
        if descStr then
            local descLb = G_getRichTextLabel(descStr, descColorTab, fontSize, cellBg:getContentSize().width - _posX - 10, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0, 1))
            descLb:setPosition(_posX, cellBg:getContentSize().height - 20)
            cellBg:addChild(descLb)
        end
        -- if avtLevel then
        -- local avtLevelLb=GetTTFLabel(getlocal("achievement_level",{"+"..avtLevel}),fontSize)
        -- avtLevelLb:setAnchorPoint(ccp(0,0))
        -- avtLevelLb:setPosition(_posX,cellBg:getContentSize().height/2+10)
        -- cellBg:addChild(avtLevelLb)
        -- end
        if reward then
            local iconShowSize = 70
            local iconSpaceX = 20
            local iconPosY = iconShowSize / 2 + 20
            local rewardTb = FormatItem(reward)
            
            if avtLevel then
                local avtLevelItem = {
                    num = 1, 
                    pic = "avt_icon.png", 
                    name = getlocal("achievement_level_propName", {avtLevel}), 
                    desc = "achievement_level_propDesc", 
                }
                table.insert(rewardTb, 1, avtLevelItem)
            end
            local adaH = 0
            if G_isAsia() == false then
                adaH = 10
                fontSize = 18
            end
            local rewardLb = GetTTFLabel(getlocal("donateReward"), fontSize)
            rewardLb:setAnchorPoint(ccp(0, 0))
            rewardLb:setPosition(_posX, iconPosY + iconShowSize / 2 + 10 - adaH)
            cellBg:addChild(rewardLb)
            fontSize = 22
            for k, v in pairs(rewardTb) do
                local icon, scale = G_getItemIcon(v, 100, false, self.layerNum, function()
                        G_showNewPropInfo(self.layerNum + 1, true, true, nil, v)
                end)
                icon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                scale = iconShowSize / icon:getContentSize().width
                icon:setScale(scale)
                icon:setPosition(_posX + iconShowSize / 2 + (k - 1) * (iconShowSize + iconSpaceX), iconPosY)
                cellBg:addChild(icon)
                local numLb
                if v.key == nil and avtLevel then
                    numLb = GetTTFLabel("+" .. avtLevel, 20, true)
                    numLb:setColor(G_LowfiColorGreen)
                else
                    numLb = GetTTFLabel(tostring(FormatNumber(v.num)), 18, true)
                end
                numLb:setAnchorPoint(ccp(1, 0))
                numLb:setScale(1 / scale)
                numLb:setPosition(ccp(icon:getContentSize().width - 3, 0))
                icon:addChild(numLb, 2)
            end
        end
        
        local btnImage = {"yh_nbSkillGoto.png", "yh_nbSkillGoto_Down.png", "yh_nbSkillGoto.png"}
        if _state == 2 then
            btnImage = {"yh_BtnUp.png", "yh_BtnUp_Down.png", "yh_BtnUp.png"}
            local stateSp = CCSprite:createWithSpriteFrameName("avtTextTab.png")
            stateSp:setAnchorPoint(ccp(1, 0.5))
            stateSp:setPosition(cellBg:getContentSize().width + 40, cellBg:getContentSize().height)
            cellBg:addChild(stateSp)
            local label = GetTTFLabel(getlocal("activity_ganenjiehuikui_endActivity"), fontSize)
            label:setPosition(stateSp:getContentSize().width / 2 - 10, stateSp:getContentSize().height / 2 + 5)
            stateSp:addChild(label)
        end
        local function onBtnHandler(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if _state == 2 then
                -- print("cjl ---------->>> 跳转到活动")
                activityAndNoteDialog:closeAllDialog() --关闭所有面板
                if acYdczVoApi then
                    jump_judgment("ydcz")
                end
            else
            	if self.avtCfg.type == "hero" then
                	G_goToDialog2("heroM", 4, true)
                elseif self.avtCfg.type == "plane" then
                	local _subType = self.avtCfg.subType
                	if self.atype == 2 then
                		local personAvtCfg = achievementVoApi:getPersonAvtCfgById(self.avtId)
                		_subType = personAvtCfg.subType
                	end
                	G_goToDialog2(self.avtCfg.type, 4, true, (_subType == "f") and 2 or 1)
                else
                	G_goToDialog2(self.avtCfg.type, 4, true)
                end
            end
        end
        if (self.atype == 1 and (_state ~= 2 or (_state == 2 and activityVoApi:isStart(activityVoApi:getActivityVo("ydcz")) == true and acYdczVoApi and acYdczVoApi:isUnlockAvt(self.avtId, index + 1) == true))) or (self.atype == 2 and _state ~= 2) then
            local button = GetButtonItem(btnImage[1], btnImage[2], btnImage[3], onBtnHandler)
            button:setAnchorPoint(ccp(1, 0))
            local menu = CCMenu:createWithItem(button)
            menu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
            menu:setPosition(cellBg:getContentSize().width - 10, 15)
            cellBg:addChild(menu)
        end
        
        if index > 0 then
            local arrowSp = CCSprite:createWithSpriteFrameName("avtgreenArrow.png")
            arrowSp:setPosition(cellBg:getContentSize().width / 2 + 55, cellBg:getContentSize().height + arrowSp:getContentSize().height / 2 + 5)
            cellBg:addChild(arrowSp, 10)
        end
        
        if cupIcon and self.atype == 2 and _state == 2 then
            local _index, _subIndex = self.index, self.subIndex
            local function operateHandler()
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                achievementVoApi:socketAchievementCup(2, self.avtId, self.atype, {_index, _subIndex}, function()
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("achievement_cup_replace_tip"), 30)
                        self:reloadData()
                end)
            end
            local checkBox = LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png", operateHandler)
            checkBox:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
            local _, indexTb = achievementVoApi:getSelectCup(nil, self.atype, self.avtId)
            if indexTb then
                if _index == indexTb[1] and _subIndex == indexTb[2] then
                    checkBox = nil
                    checkBox = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
                end
            end
            checkBox:setScale(0.6)
            checkBox:setPosition(cupIcon:getContentSize().width - checkBox:getContentSize().width * checkBox:getScale() / 2 - 10, checkBox:getContentSize().height * checkBox:getScale() / 2 + 75)
            cupIcon:addChild(checkBox)
        end
        
        if self.atype == 2 then
            self.subIndex = self.subIndex + 1
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function achievementInfoDialog:dispose()
    self.atype = nil
    self.avtId = nil
    self.avtCfg = nil
    self.subIndex = nil
    self.index = nil
    self.cellNum = nil
    self.button = nil
    self.tv = nil
    self.parent = nil
    spriteController:removePlist("public/youhuaUI4.plist")
    spriteController:removeTexture("public/youhuaUI4.png")
    spriteController:removePlist("public/avt_images.plist")
    spriteController:removeTexture("public/avt_images.png")
    spriteController:removePlist("public/avt_images1.plist")
    spriteController:removeTexture("public/avt_images1.png")
    spriteController:removePlist("public/avt_images2.plist")
    spriteController:removeTexture("public/avt_images2.png")
end