exerWarFirstPVPDialog = {}

function exerWarFirstPVPDialog:new(layerNum, period)
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	self.layerNum = layerNum
	self.period = period
	G_addResource8888(function()
        spriteController:addPlist("public/youhuaUI4.plist")
        spriteController:addTexture("public/youhuaUI4.png")
    end)
    spriteController:addPlist("serverWar/serverWar.plist")
	return nc
end

function exerWarFirstPVPDialog:initTableView()
	self.bgLayer = CCLayer:create()
	self:tick()
end

function exerWarFirstPVPDialog:showUI(tag)
	if type(tag) ~= "number" then
    	return
    end
	if type(self.curShowUITag) == "number" then
        local uiNode = tolua.cast(self.bgLayer:getChildByTag(self.curShowUITag), "CCNode")
        if uiNode then
            uiNode:removeFromParentAndCleanup(true)
            uiNode = nil
        end
    end
    local tabTitle
    if exerWarVoApi:isEnterFirstPVP() == false then
    	tabTitle = { getlocal("serverwar_playerList") }
    else
	    if tag == 100 then
			tabTitle = { getlocal("world_war_sub_title21"), getlocal("world_war_sub_title22"), getlocal("world_war_sub_title23"), getlocal("world_war_sub_title24") }
		else
			tabTitle = { getlocal("world_war_sub_title21"), getlocal("serverwar_playerList") }
		end
	end
	local tabBtnBottomPos
	self.allTabBtn = {}
	local tabMenu = CCMenu:create()
    for k, v in pairs(tabTitle) do
        local tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", "yh_ltzdzHelp_tab_down.png")
        tabBtnItem:setAnchorPoint(ccp(0.5, 0.5))
        tabBtnItem:setPosition(15 + tabBtnItem:getContentSize().width / 2 + (k - 1) * (tabBtnItem:getContentSize().width + 3), G_VisibleSizeHeight - ((G_getIphoneType() == G_iphone4) and 180 or 190))
        tabMenu:addChild(tabBtnItem)
        tabBtnItem:setTag(k)
        local titleLb = GetTTFLabelWrap(v, 20, CCSizeMake(tabBtnItem:getContentSize().width * tabBtnItem:getScaleX(), 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        titleLb:setPosition(tabBtnItem:getContentSize().width / 2, tabBtnItem:getContentSize().height / 2)
        tabBtnItem:addChild(titleLb)
        tabBtnItem:registerScriptTapHandler(function(...)
                PlayEffect(audioCfg.mouseClick)
                return self:switchTab(...)
        end)
        self.allTabBtn[k] = tabBtnItem
        tabBtnBottomPos = tabBtnItem:getPositionY() - tabBtnItem:getContentSize().height / 2
    end
    tabMenu:setPosition(0, 0)
    tabMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    tabMenu:setTag(tag)
    self.bgLayer:addChild(tabMenu)
    self.curShowUITag = tag
    self.curShowTabIndex = 1
    if self.tabBgLayer == nil then
    	local tabBgOffsetH
	    if G_getIphoneType() == G_iphone5 then
	        tabBgOffsetH = 160
	    elseif G_getIphoneType() == G_iphoneX then
	        tabBgOffsetH = 200
	    else --默认是 G_iphone4
	        tabBgOffsetH = 135
	    end
    	local borderSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    	borderSp:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, tabBtnBottomPos - tabBgOffsetH))
    	borderSp:setAnchorPoint(ccp(0.5, 1))
    	borderSp:setPosition(G_VisibleSizeWidth / 2, tabBtnBottomPos)
    	self.bgLayer:addChild(borderSp)
    	self.tabBgLayer = CCNode:create()
    	self.tabBgLayer:setContentSize(borderSp:getContentSize())
    	self.tabBgLayer:setAnchorPoint(ccp(0, 0))
    	self.tabBgLayer:setPosition(0, 0)
    	borderSp:addChild(self.tabBgLayer)
    end
    self:switchTab(self.curShowTabIndex)
end

function exerWarFirstPVPDialog:isCanClose()
	if self.closeFlag == true and (exerWarVoApi:isEnterFirstPVP() == true and self.curShowUITag == 100 and self.curShowTabIndex >= 2 and self.curShowTabIndex <= 4) then
		return exerWarVoApi:checkSameTroops(self.tempTroopsData, self.checkTroopsData)
	end
	return true
end

function exerWarFirstPVPDialog:switchTab(idx)
	if self.allTabBtn then
		if (exerWarVoApi:isEnterFirstPVP() == true and self.curShowUITag == 100 and self.curShowTabIndex >= 2 and self.curShowTabIndex <= 4) and idx == 1 then
			if exerWarVoApi:checkSameTroops(self.tempTroopsData, self.checkTroopsData) == false then --部队信息发生变化
				smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), function()
					self.tempTroopsData = nil
					self.checkTroopsData = nil
					self:switchTab(idx)
				end, getlocal("dialog_title_prompt"), getlocal("exerwar_troopsChangeTipsText"), nil, self.layerNum + 1, nil, nil, function()end)
				do return end
			end
		end

        for k, v in pairs(self.allTabBtn) do
            if v:getTag() == idx then
                v:setEnabled(false)
                self.curShowTabIndex = idx
            else
                v:setEnabled(true)
            end
        end

        if self.tabBgLayer then
        	self.tabBgLayer:removeAllChildrenWithCleanup(true)

	        if (exerWarVoApi:isEnterFirstPVP() == false and self.curShowTabIndex == 1) or 
	        	(exerWarVoApi:isEnterFirstPVP() == true and self.curShowUITag ~= 100 and self.curShowTabIndex == 2) then
	        	self:showCompetitionListUI()
	        end

	        if (exerWarVoApi:isEnterFirstPVP() == true and self.curShowTabIndex == 1) then
	        	self:showPandectUI()
	        end

	        if (exerWarVoApi:isEnterFirstPVP() == true and self.curShowUITag == 100 and self.curShowTabIndex >= 2 and self.curShowTabIndex <= 4) then
	        	self:showSettingsTroopsUI()
	        end
	    end

    end
end

--显示设置部队UI
function exerWarFirstPVPDialog:showSettingsTroopsUI()
	local curShowTroopsIndex = self.curShowTabIndex - 1
	local tLayerPosY
    if G_getIphoneType() == G_iphone5 then
        tLayerPosY = 90
    elseif G_getIphoneType() == G_iphoneX then
        tLayerPosY = 90
    else --默认是 G_iphone4
        tLayerPosY = 60
    end
    local troopsLayerObj = exerWarVoApi:createTroopsLayer(self.layerNum, exerWarVoApi:getBaseTroopsNum())
	local troopsLayer = troopsLayerObj.bgLayer
	troopsLayer:setPosition((self.tabBgLayer:getContentSize().width - troopsLayer:getContentSize().width) / 2, tLayerPosY)
	if self.tempTroopsData == nil then
		self.tempTroopsData = {}
		for i = 1, 3 do
			self.tempTroopsData[i] = exerWarVoApi:getTroopsData(i) or {{},{},{}}
		end
		self.checkTroopsData = G_clone(self.tempTroopsData)
	end
	troopsLayerObj:setLineupsData(self.tempTroopsData[curShowTroopsIndex])
	self.tabBgLayer:addChild(troopsLayer, 1)
	if self.canUseTroopsData == nil then
    	self.canUseTroopsData = exerWarVoApi:getCanUseTroops()
    end
    local function filterData()
	    if self.canUseTroopsData then --过滤不可用的部队数据
	    	local ttData = G_clone(self.canUseTroopsData)
	    	if self.tempTroopsData then
	    		for k, v in pairs(self.tempTroopsData) do
	    			if k ~= curShowTroopsIndex and v then
	    				for kk, vv in pairs(v) do
	    					if kk == 1 or kk == 2 or kk == 3 then
		                        for kkk, vvv in pairs(vv) do
		                        	local idA = (type(vvv) == "table") and (vvv[1] or 0) or vvv
		                        	if kk == 1 then
		                        		idA = tonumber(idA) or tonumber(RemoveFirstChar(idA))
		                        	end
		                            for kkkk, vvvv in pairs(ttData[kk]) do
		                                local idB = vvvv[1]
		                                if kk == 1 then
		                                    idB = tonumber(idB) or tonumber(RemoveFirstChar(idB))
		                                end
		                                if idA == idB then
		                                    table.remove(ttData[kk], kkkk)
		                                    break
		                                end
		                            end
		                        end
		                    elseif kk == 4 then
		                        for kkk, vvv in pairs(ttData[kk]) do
		                            if vv == vvv then
		                                table.remove(ttData[kk], kkk)
		                                break
		                            end
		                        end
		                    elseif kk == 5 then
		                        for kkk, vvv in pairs(ttData[kk][1]) do
		                            if vv[1] == vvv then
		                                table.remove(ttData[kk][1], kkk)
		                                break
		                            end
		                        end
		                        for kkk, vvv in pairs(ttData[kk][2]) do
		                            if vv[2] == vvv then
		                                table.remove(ttData[kk][2], kkk)
		                                break
		                            end
		                        end
		                    end
	    				end
	    			end
	    		end
	    	end
	    	troopsLayerObj:setCanUseTroops(ttData)
	    end
	end
	filterData()
    self.closeFlag = true

	local function onClickHandler(tag, obj)
		if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 10 then
        	local function onDismantleEvent()
        		if self.curShowUITag ~= 100 then
        			do return end
        		end
	        	print("cjl ------>>>> 一键下阵")
	        	if self.tempTroopsData and self.tempTroopsData[curShowTroopsIndex] then
	        		self.tempTroopsData[curShowTroopsIndex] = {}
	        		troopsLayerObj:setLineupsData(self.tempTroopsData[curShowTroopsIndex])
	        		troopsLayerObj:setTroopsNumUI()
	        	end
        	end
        	local troopsStrTb = { getlocal("world_war_sub_title22"), getlocal("world_war_sub_title23"), getlocal("world_war_sub_title24") }
        	local tipsStr = getlocal("exerwar_dismantleTroopsTipsText", {troopsStrTb[curShowTroopsIndex]})
        	smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onDismantleEvent, getlocal("dialog_title_prompt"), tipsStr, nil, self.layerNum + 1)
        	--[[
        	print("cjl ------>>>> 可用部队")
            if self.canUseTroopsData then
                exerWarVoApi:showAllTroopsSmallDialog(self.layerNum + 1, self.canUseTroopsData)
            else
                G_showTipsDialog(getlocal("exerwar_notHaveCanUseTroopsText"))
            end
            --]]
        elseif tag == 11 then
        	print("cjl ------>>>> 保存部队")
        	local function isCanSaveTroops()
        		local num = 0
        		if self.tempTroopsData then
        			for k, v in pairs(self.tempTroopsData) do
        				local flag, status = exerWarVoApi:isTroopsFull(v)
        				if flag == true then
        					num = num + 1
        				else
        					return flag, status, k
        				end
        			end
        		end
        		if num == 3 then --三组都得装配完整才可保存部队
        			return true
        		end
        		return false
        	end
        	local flag, status, troopsIndex = isCanSaveTroops()
        	if flag == false then --不可保存部队
        		local troopsStrTb = { getlocal("world_war_sub_title22"), getlocal("world_war_sub_title23"), getlocal("world_war_sub_title24") }
        		if status then
        			G_showTipsDialog(troopsStrTb[troopsIndex] .. getlocal("exerwar_saveTroopsErr" .. status))
        		else
        			G_showTipsDialog(troopsStrTb[curShowTroopsIndex] .. getlocal("exerwar_saveTroopsErr"))
        		end
        		do return end
        	end
        	if exerWarVoApi:checkSameTroops(self.tempTroopsData, self.checkTroopsData) == true then --部队信息未发生变化
        		G_showTipsDialog(getlocal("arrange_nochange_troops_tip"))
        		do return end
        	end
        	exerWarVoApi:saveLineups(function()
        		print("cjl ------>>>> 保存部队成功！~")
                G_showTipsDialog(getlocal("save_success"))
                self.checkTroopsData = G_clone(self.tempTroopsData)
        	end, self.tempTroopsData)
        elseif tag == 12 then
        	local function onRandomEvent()
        		if self.curShowUITag ~= 100 then
        			do return end
        		end
	        	print("cjl ------>>>> 随机部队")
	        	self.tempTroopsData = nil
	        	self.tempTroopsData = exerWarVoApi:randomLineups()
	        	troopsLayerObj:setLineupsData(self.tempTroopsData[curShowTroopsIndex])
	        	filterData()
	        	G_showTipsDialog(getlocal("exerwar_randomTroopsSuccessText"))
	        end
	        require "luascript/script/game/scene/gamedialog/exerwar/exerWarSmallDialog"
	        exerWarSmallDialog:showSelectRandomLineup(self.layerNum + 1, function(randomType)
	        	if self.curShowUITag ~= 100 then
        			do return end
        		end
	        	if randomType == 1 then --随机一支部队
	        		self.tempTroopsData[curShowTroopsIndex] = exerWarVoApi:randomLineups(nil, troopsLayerObj:getCanUseTroops())
	        		troopsLayerObj:setLineupsData(self.tempTroopsData[curShowTroopsIndex])
	        		G_showTipsDialog(getlocal("exerwar_randomTroopsSuccessText"))
	        	elseif randomType == 3 then
	        		smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onRandomEvent, getlocal("dialog_title_prompt"), getlocal("exerwar_randomTroopsTipsText"), nil, self.layerNum + 1)
	        	end
	        end)
        end
	end
	local btnScale, btnFontSize = 0.7, 24
	local canUseBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 10, getlocal("exerwar_dismantleTroopsText"), btnFontSize / btnScale)
	local saveBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 11, getlocal("collect_border_save"), btnFontSize / btnScale)
	local randomBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 12, getlocal("exerwar_randomTroopsText"), btnFontSize / btnScale)
	--[[
	local canUseBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 10, getlocal("exerwar_canUseTroopsText"), btnFontSize / btnScale)
	local saveBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 11, getlocal("collect_border_save"), btnFontSize / btnScale)
	local randomBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 12, getlocal("exerwar_randomTroopsText"), btnFontSize / btnScale)
	--]]
    local menuArr = CCArray:create()
    menuArr:addObject(canUseBtn)
    menuArr:addObject(saveBtn)
    menuArr:addObject(randomBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(ccp(0, 0))
    self.tabBgLayer:addChild(btnMenu)
    canUseBtn:setScale(btnScale)
    saveBtn:setScale(btnScale)
    randomBtn:setScale(btnScale)
    local offsetBtnPosY
    if G_getIphoneType() == G_iphone5 then
        offsetBtnPosY = 15
    elseif G_getIphoneType() == G_iphoneX then
        offsetBtnPosY = 15
    else --默认是 G_iphone4
        offsetBtnPosY = 5
    end
    local btnSpaceW, btnPosY = 55, saveBtn:getContentSize().height * btnScale / 2 + offsetBtnPosY
    saveBtn:setPosition(self.tabBgLayer:getContentSize().width / 2, btnPosY)
    canUseBtn:setPosition(saveBtn:getPositionX() - saveBtn:getContentSize().width * btnScale - btnSpaceW, btnPosY)
    randomBtn:setPosition(saveBtn:getPositionX() + saveBtn:getContentSize().width * btnScale + btnSpaceW, btnPosY)
end

--显示总览UI
function exerWarFirstPVPDialog:showPandectUI()
	if self.curShowUITag == 100 then
		local spaceLineSpOffsetPosY
		local troopsTipsLbOffsetPosY
		local troopsIdxLbOffsetPosY
		if G_getIphoneType() == G_iphone5 then
			spaceLineSpOffsetPosY = 295
			troopsTipsLbOffsetPosY = 270
	        troopsIdxLbOffsetPosY = 300
	    elseif G_getIphoneType() == G_iphoneX then
	        spaceLineSpOffsetPosY = 295
			troopsTipsLbOffsetPosY = 270
	        troopsIdxLbOffsetPosY = 300
	    else --默认是 G_iphone4
	    	spaceLineSpOffsetPosY = 220
	    	troopsTipsLbOffsetPosY = 200
	        troopsIdxLbOffsetPosY = 230
	    end
		local strTb = { getlocal("world_war_sub_title22"), getlocal("world_war_sub_title23"), getlocal("world_war_sub_title24") }
		for i = 1, 2 do
			local spaceLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png", CCRect(26, 0, 2, 6), function()end)
			spaceLineSp:setContentSize(CCSizeMake(200, spaceLineSp:getContentSize().height))
			spaceLineSp:setPosition(i * (self.tabBgLayer:getContentSize().width / 3), self.tabBgLayer:getContentSize().height - spaceLineSp:getContentSize().width / 2 - spaceLineSpOffsetPosY)
			spaceLineSp:setRotation(90)
			self.tabBgLayer:addChild(spaceLineSp)
		end
		local troopsTipsLb = GetTTFLabelWrap(getlocal("exerwar_maneuverTroopsMoveTipsText"), 22, CCSizeMake(self.tabBgLayer:getContentSize().width - 36, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
		troopsTipsLb:setAnchorPoint(ccp(0.5, 0))
		troopsTipsLb:setPosition(self.tabBgLayer:getContentSize().width / 2, self.tabBgLayer:getContentSize().height - troopsTipsLbOffsetPosY)
		troopsTipsLb:setColor(G_ColorRed)
		self.tabBgLayer:addChild(troopsTipsLb)
		local isCanTouchMove = false
		local tankIconSize = 100
		local tankSpTb = {}
		local tTroopsData = {}
		for k, v in pairs(strTb) do
			local troopsIdxLb = GetTTFLabel(v, 25, true)
			troopsIdxLb:setAnchorPoint(ccp(0.5, 1))
			troopsIdxLb:setPosition(k * (self.tabBgLayer:getContentSize().width / 3) - ((self.tabBgLayer:getContentSize().width / 3) / 2), self.tabBgLayer:getContentSize().height - troopsIdxLbOffsetPosY)
			self.tabBgLayer:addChild(troopsIdxLb)
			local troopsData = exerWarVoApi:getTroopsData(k)
			tTroopsData[k] = troopsData
			local tankId
			local tankSp
			if troopsData and troopsData[1] and troopsData[1][1] and troopsData[1][1][1] then
				tankId = tonumber(troopsData[1][1][1]) or tonumber(RemoveFirstChar(troopsData[1][1][1]))
				tankSp = tankVoApi:getTankIconSp(tankId, nil, nil, false)
				isCanTouchMove = true
				local planeName, emblemName, planeSp, emblemSp
				local firstValue = exerWarVoApi:getBaseFirstValue() + exerWarVoApi:getFirstValue(troopsData)
				if troopsData[5] and troopsData[5][1] then
					local planeId = troopsData[5][1]
					planeName = getlocal("plane_name_" .. planeId)
					planeSp = CCSprite:createWithSpriteFrameName("plane_icon_" .. planeId .. ".png")
				end
				if troopsData[4] then
					local emblemId = troopsData[4]
					emblemName = emblemVoApi:getEquipName(emblemId)
					emblemSp = CCSprite:create("public/emblem/icon/emblemIcon_" .. emblemId .. ".png")
					if emblemSp == nil then
						emblemSp = CCSprite:create("public/emblem/icon/emblemIcon_e2.png")
					end
				end
				local spSize = 35
				local tankSpBottom = troopsIdxLb:getPositionY() - troopsIdxLb:getContentSize().height - 10 - tankIconSize
				local spPosX = troopsIdxLb:getPositionX() - tankIconSize / 2 - spSize / 2
				-- local planeSp = CCSprite:createWithSpriteFrameName("plane_icon.png")
				-- local emblemSp = CCSprite:createWithSpriteFrameName("st_emptyShadow.png")
				local firstValueSp = CCSprite:createWithSpriteFrameName("positiveHead.png")
				if planeSp and emblemSp then
					local spOffsetPosY
					if G_getIphoneType() == G_iphone5 then
						spOffsetPosY = 20
				    elseif G_getIphoneType() == G_iphoneX then
				        spOffsetPosY = 20
				    else --默认是 G_iphone4
				    	spOffsetPosY = 15
				    end
					planeSp:setScale(spSize / planeSp:getContentSize().width)
					emblemSp:setScale(spSize / emblemSp:getContentSize().width)
					firstValueSp:setScale(spSize / firstValueSp:getContentSize().width)

					planeSp:setPosition(troopsIdxLb:getPositionX() + tankIconSize / 2 + spSize / 2 + 5, tankSpBottom + tankIconSize / 2 + spSize / 2 + 5)
					emblemSp:setPosition(troopsIdxLb:getPositionX() + tankIconSize / 2 + spSize / 2 + 5, tankSpBottom + tankIconSize / 2 - spSize / 2 - 5)
					firstValueSp:setPosition(spPosX + spSize, tankSpBottom - spSize / 2 - spOffsetPosY)
					self.tabBgLayer:addChild(planeSp)
					self.tabBgLayer:addChild(emblemSp)
					self.tabBgLayer:addChild(firstValueSp)
					local firstValueLb = GetTTFLabel(firstValue or "0", 22)
					firstValueLb:setAnchorPoint(ccp(0, 0.5))
					firstValueLb:setPosition(firstValueSp:getPositionX() + spSize / 2  + 5, firstValueSp:getPositionY())
					self.tabBgLayer:addChild(firstValueLb)
					--[[
					planeSp:setPosition(spPosX, tankSpBottom - spSize / 2 - spOffsetPosY)
					emblemSp:setPosition(spPosX, planeSp:getPositionY() - spSize - 15)
					firstValueSp:setPosition(spPosX, emblemSp:getPositionY() - spSize - 15)
					self.tabBgLayer:addChild(planeSp)
					self.tabBgLayer:addChild(emblemSp)
					self.tabBgLayer:addChild(firstValueSp)
					local planeNameLb = GetTTFLabel(planeName or "", 22)
					local emblemNameLb = GetTTFLabel(emblemName or "", 22)
					local firstValueLb = GetTTFLabel(firstValue or "0", 22)
					planeNameLb:setAnchorPoint(ccp(0, 0.5))
					emblemNameLb:setAnchorPoint(ccp(0, 0.5))
					firstValueLb:setAnchorPoint(ccp(0, 0.5))
					planeNameLb:setPosition(spPosX + spSize / 2 + 5, planeSp:getPositionY())
					emblemNameLb:setPosition(spPosX + spSize / 2 + 5, emblemSp:getPositionY())
					firstValueLb:setPosition(spPosX + spSize / 2  + 5, firstValueSp:getPositionY())
					self.tabBgLayer:addChild(planeNameLb)
					self.tabBgLayer:addChild(emblemNameLb)
					self.tabBgLayer:addChild(firstValueLb)
					--]]
				end
			else
				tankSp = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", function() self:switchTab(k + 1) end)
				tankSp:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
				local addBtnSp = CCSprite:createWithSpriteFrameName("st_addIcon.png")
				addBtnSp:setPosition(tankSp:getContentSize().width / 2, tankSp:getContentSize().height / 2)
				tankSp:addChild(addBtnSp)
				local seq = CCSequence:createWithTwoActions(CCFadeTo:create(1, 55), CCFadeTo:create(1, 255))
				addBtnSp:runAction(CCRepeatForever:create(seq))
			end
			tankSp:setScale(tankIconSize / tankSp:getContentSize().width)
			tankSp:setPosition(troopsIdxLb:getPositionX(), troopsIdxLb:getPositionY() - troopsIdxLb:getContentSize().height - 10 - tankSp:getContentSize().height * tankSp:getScale() / 2)
			self.tabBgLayer:addChild(tankSp, 1)
			tankSpTb[k] = { tankSp, ccp(tankSp:getPosition()), tankId }
		end
		if isCanTouchMove then
			local touchLayer = CCLayer:create()
			touchLayer:setContentSize(self.tabBgLayer:getContentSize())
			local touchArray, isMultTouch, beganPos, movePos, touchSpIndex, touchTankSp
			local function touchEvent(fn, x, y, touch)
				if fn == "began" then
					if touchArray == nil then
		                touchArray = {}
		            end
		            table.insert(touchArray, touch)
		            if SizeOfTable(touchArray) > 1 then
		                isMultTouch = true
		                return true
		            end
					if tankSpTb then
						for k, v in pairs(tankSpTb) do
							local tankSp = v[1]
							local vPos = tankSp:getParent():convertToWorldSpace(ccp(tankSp:getPosition()))
							local vAnchorPoint = tankSp:getAnchorPoint()
							local vSizeWidth, vSizeHeight = tankSp:getContentSize().width * tankSp:getScale(), tankSp:getContentSize().height * tankSp:getScale()
							local vRect = CCRect(vPos.x - vSizeWidth * vAnchorPoint.x, vPos.y - vSizeHeight * vAnchorPoint.y, vSizeWidth, vSizeHeight)
							if vRect:containsPoint(ccp(x, y)) == true then
								beganPos = ccp(x, y)
                            	movePos = ccp(x, y)
                            	touchSpIndex = k
                            	-- tankSp:getParent():reorderChild(tankSp, 2)
								return true
							end
						end
					end
					return false
				elseif fn == "moved" then
					if isMultTouch == true then --多点触摸
			            return
			        end
			        if touchSpIndex and tankSpTb[touchSpIndex] and tolua.cast(tankSpTb[touchSpIndex][1], "CCSprite") then
			        	local curTouchPos = ccp(x, y)
			            local moveDisPos = ccpSub(curTouchPos, movePos)
			            local moveDisTem = ccpSub(curTouchPos, beganPos)
			            --部分安卓设备可能存在灵敏度问题
			            local offset = (G_isIOS() == false) and 13 or 30
			            if math.abs(moveDisTem.y) + math.abs(moveDisTem.x) < offset then
			                return
			            end
			            if touchTankSp == nil and tankSpTb[touchSpIndex][3] then
			            	touchTankSp = tankVoApi:getTankIconSp(tankSpTb[touchSpIndex][3], nil, nil, false)
			            	touchTankSp:setScale(tankSpTb[touchSpIndex][1]:getScale())
			            	touchTankSp:setPosition(tankSpTb[touchSpIndex][1]:getPosition())
			            	touchTankSp:setOpacity(150)
			            	self.tabBgLayer:addChild(touchTankSp, 2)
			            end
			            touchTankSp:setPosition(ccpAdd(ccp(touchTankSp:getPosition()), ccp(moveDisPos.x, moveDisPos.y)))
			            -- local tankSp = tankSpTb[touchSpIndex][1]
			            -- tankSp:setPosition(ccpAdd(ccp(tankSp:getPosition()), ccp(moveDisPos.x, moveDisPos.y)))
                		movePos = curTouchPos
			        end
				elseif fn == "ended" then
					if touchSpIndex and tankSpTb[touchSpIndex] and tolua.cast(tankSpTb[touchSpIndex][1], "CCSprite") and touchTankSp then
						-- local tankSp = tankSpTb[touchSpIndex][1]
						for k, v in pairs(tankSpTb) do
							local tempTankSp = v[1]
							local vPos = ccp(tempTankSp:getPosition())
							local vAnchorPoint = tempTankSp:getAnchorPoint()
							local vSizeWidth, vSizeHeight = tempTankSp:getContentSize().width * tempTankSp:getScale(), tempTankSp:getContentSize().height * tempTankSp:getScale()
							local vRect = CCRect(vPos.x - vSizeWidth * vAnchorPoint.x, vPos.y - vSizeHeight * vAnchorPoint.y, vSizeWidth, vSizeHeight)
							if k ~= touchSpIndex and vRect:containsPoint(ccp(touchTankSp:getPosition())) == true then
							-- if k ~= touchSpIndex and vRect:containsPoint(ccp(tankSp:getPosition())) == true then
								print("cjl ------->>>> 交换阵容顺序")
								local ttData = tTroopsData[touchSpIndex]
								tTroopsData[touchSpIndex] = tTroopsData[k]
								tTroopsData[k] = ttData
								local tempTouchIndex = touchSpIndex
								exerWarVoApi:saveLineups(function()
					                G_showTipsDialog(getlocal("save_success"))
					                if self.tempTroopsData then
										local tempData = G_clone(self.tempTroopsData[tempTouchIndex])
										self.tempTroopsData[tempTouchIndex] = G_clone(self.tempTroopsData[k])
										self.tempTroopsData[k] = tempData
										self.checkTroopsData = G_clone(self.tempTroopsData)
									end
									self.tabBgLayer:removeAllChildrenWithCleanup(true)
									self:showPandectUI()
					        	end, tTroopsData)
								-- tankSp = nil
								break
							end
						end
						-- if tankSp then
							-- tankSp:setPosition(tankSpTb[touchSpIndex][2])
							-- tankSp:getParent():reorderChild(tankSp, 1)
						-- end
					end
					if touchTankSp then
						touchTankSp:removeFromParentAndCleanup(true)
					end
					touchTankSp = nil
					touchSpIndex = nil
					beganPos = nil
					touchArray = nil
        			isMultTouch = nil
				else
					if touchTankSp then
						touchTankSp:removeFromParentAndCleanup(true)
					end
					touchTankSp = nil
					-- if touchSpIndex and tankSpTb[touchSpIndex] and tolua.cast(tankSpTb[touchSpIndex][1], "CCSprite") then
					-- 	local tankSp = tankSpTb[touchSpIndex][1]
					-- 	tankSp:setPosition(tankSpTb[touchSpIndex][2])
					-- 	tankSp:getParent():reorderChild(tankSp, 1)
					-- end
					touchSpIndex = nil
					beganPos = nil
					touchArray = nil
        			isMultTouch = nil
				end
			end
			touchLayer:registerScriptTouchHandler(function(...) return touchEvent(...) end, false, - (self.layerNum - 1) * 20 - 2, true)
			touchLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
	    	touchLayer:setTouchEnabled(true)
	    	self.tabBgLayer:addChild(touchLayer)
		end
		local tipsLbTvData = {
			{ getlocal("exerwar_maneuverTipsText1") },
			{ getlocal("exerwar_maneuverTipsText2", {exerWarVoApi:getAccessoryPercent()}), {nil, G_ColorRed, nil, G_ColorRed, nil} }
		}
		local tipsLbTvSizeOffset
		if G_getIphoneType() == G_iphone5 then
			tipsLbTvSizeOffset = 560
	    elseif G_getIphoneType() == G_iphoneX then
	        tipsLbTvSizeOffset = 560
	    else --默认是 G_iphone4
	    	tipsLbTvSizeOffset = 450
	    end
		local tipsLbTvSize = CCSizeMake(self.tabBgLayer:getContentSize().width - 36, self.tabBgLayer:getContentSize().height - tipsLbTvSizeOffset)
		local tipsLbTv = G_createTableView(tipsLbTvSize, SizeOfTable(tipsLbTvData), function(idx, cellNum)
			local height = 0
			height = height + 15
			local descLb, descLbHieght = G_getRichTextLabel(tipsLbTvData[idx + 1][1], tipsLbTvData[idx + 1][2] or {}, 22, tipsLbTvSize.width, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
			height = height + descLbHieght
			height = height + 15
			return CCSizeMake(tipsLbTvSize.width, height)
		end, function(cell, cellSize, idx, cellNum)
			local descLb, descLbHieght = G_getRichTextLabel(tipsLbTvData[idx + 1][1], tipsLbTvData[idx + 1][2] or {}, 22, tipsLbTvSize.width, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
			descLb:setAnchorPoint(ccp(0, 0.5))
			descLb:setPosition(0, descLbHieght + 15)
			cell:addChild(descLb)
		end)
		tipsLbTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 2)
	    tipsLbTv:setPosition((self.tabBgLayer:getContentSize().width - tipsLbTvSize.width) / 2, self.tabBgLayer:getContentSize().height - tipsLbTvSize.height - 5)
	    tipsLbTv:setMaxDisToBottomOrTop(0)
	    self.tabBgLayer:addChild(tipsLbTv)
	    local signupBg = isCanTouchMove and CCSprite:createWithSpriteFrameName("ydczStateBg.png") or GraySprite:createWithSpriteFrameName("ydczStateBg.png")
	    signupBg:setPosition(self.tabBgLayer:getContentSize().width / 2, signupBg:getContentSize().height / 2 + 25)
	    self.tabBgLayer:addChild(signupBg)
	    local signupLb = GetTTFLabel(getlocal(isCanTouchMove and "dimensionalWar_has_signup" or "exerwar_notSignupText"), 26, true)
	    signupLb:setPosition(signupBg:getContentSize().width / 2, signupBg:getContentSize().height / 2)
	    signupLb:setColor(isCanTouchMove and G_ColorRed or G_ColorGray)
	    signupBg:addChild(signupLb)

	    local function onClickCanUse(tag, obj)
	    	if G_checkClickEnable() == false then
	            do return end
	        else
	            base.setWaitTime = G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)
        	print("cjl ------>>>> 可用部队")
        	if self.canUseTroopsData == nil then
		    	self.canUseTroopsData = exerWarVoApi:getCanUseTroops()
		    end
            if self.canUseTroopsData then
                exerWarVoApi:showAllTroopsSmallDialog(self.layerNum + 1, self.canUseTroopsData)
            else
                G_showTipsDialog(getlocal("exerwar_notHaveCanUseTroopsText"))
            end
	    end
	    local btnScale, btnFontSize = 0.7, 24
		local canUseBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickCanUse, 10, getlocal("exerwar_canUseTroopsText"), btnFontSize / btnScale)
	    local btnMenu = CCMenu:createWithItem(canUseBtn)
	    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
	    btnMenu:setPosition(ccp(0, 0))
	    self.tabBgLayer:addChild(btnMenu)
	    canUseBtn:setScale(btnScale)
	    canUseBtn:setPosition(self.tabBgLayer:getContentSize().width - canUseBtn:getContentSize().width * btnScale / 2 - 25, signupBg:getPositionY())

		--[[
		local strTb = { getlocal("world_war_sub_title22"), getlocal("world_war_sub_title23"), getlocal("world_war_sub_title24") }
		for i = 1, 2 do
			local spaceLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png", CCRect(26, 0, 2, 6), function()end)
			spaceLineSp:setContentSize(CCSizeMake(150, spaceLineSp:getContentSize().height))
			spaceLineSp:setPosition(i * (self.tabBgLayer:getContentSize().width / 3), self.tabBgLayer:getContentSize().height - spaceLineSp:getContentSize().width / 2 - 25)
			spaceLineSp:setRotation(90)
			self.tabBgLayer:addChild(spaceLineSp)
		end
		local troopsTipsLb = GetTTFLabelWrap(getlocal("emblem_set_troops_tips"), 22, CCSizeMake(self.tabBgLayer:getContentSize().width - 36, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
		troopsTipsLb:setAnchorPoint(ccp(0.5, 1))
		troopsTipsLb:setPosition(self.tabBgLayer:getContentSize().width / 2, self.tabBgLayer:getContentSize().height - 190)
		troopsTipsLb:setColor(G_ColorRed)
		self.tabBgLayer:addChild(troopsTipsLb)
		local isCanTouchMove = false
		local tankIconSize = 100
		local tankSpTb = {}
		local tTroopsData = {}
		for k, v in pairs(strTb) do
			local troopsIdxLb = GetTTFLabel(v, 25, true)
			troopsIdxLb:setAnchorPoint(ccp(0.5, 1))
			troopsIdxLb:setPosition(k * (self.tabBgLayer:getContentSize().width / 3) - ((self.tabBgLayer:getContentSize().width / 3) / 2), self.tabBgLayer:getContentSize().height - 30)
			self.tabBgLayer:addChild(troopsIdxLb)
			local troopsData = exerWarVoApi:getTroopsData(k)
			tTroopsData[k] = troopsData
			local tankId
			local tankSp
			if troopsData and troopsData[1] and troopsData[1][1] and troopsData[1][1][1] then
				tankId = tonumber(troopsData[1][1][1]) or tonumber(RemoveFirstChar(troopsData[1][1][1]))
				tankSp = tankVoApi:getTankIconSp(tankId, nil, nil, false)
				isCanTouchMove = true
			else
				tankSp = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", function() self:switchTab(k + 1) end)
				tankSp:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
				local addBtnSp = CCSprite:createWithSpriteFrameName("st_addIcon.png")
				addBtnSp:setPosition(tankSp:getContentSize().width / 2, tankSp:getContentSize().height / 2)
				tankSp:addChild(addBtnSp)
				local seq = CCSequence:createWithTwoActions(CCFadeTo:create(1, 55), CCFadeTo:create(1, 255))
				addBtnSp:runAction(CCRepeatForever:create(seq))
			end
			tankSp:setScale(tankIconSize / tankSp:getContentSize().width)
			tankSp:setPosition(troopsIdxLb:getPositionX(), troopsIdxLb:getPositionY() - troopsIdxLb:getContentSize().height - 10 - tankSp:getContentSize().height * tankSp:getScale() / 2)
			self.tabBgLayer:addChild(tankSp, 1)
			tankSpTb[k] = { tankSp, ccp(tankSp:getPosition()), tankId }
		end
		if isCanTouchMove then
			local touchLayer = CCLayer:create()
			touchLayer:setContentSize(self.tabBgLayer:getContentSize())
			local touchArray, isMultTouch, beganPos, movePos, touchSpIndex, touchTankSp
			local function touchEvent(fn, x, y, touch)
				if fn == "began" then
					if touchArray == nil then
		                touchArray = {}
		            end
		            table.insert(touchArray, touch)
		            if SizeOfTable(touchArray) > 1 then
		                isMultTouch = true
		                return true
		            end
					if tankSpTb then
						for k, v in pairs(tankSpTb) do
							local tankSp = v[1]
							local vPos = tankSp:getParent():convertToWorldSpace(ccp(tankSp:getPosition()))
							local vAnchorPoint = tankSp:getAnchorPoint()
							local vSizeWidth, vSizeHeight = tankSp:getContentSize().width * tankSp:getScale(), tankSp:getContentSize().height * tankSp:getScale()
							local vRect = CCRect(vPos.x - vSizeWidth * vAnchorPoint.x, vPos.y - vSizeHeight * vAnchorPoint.y, vSizeWidth, vSizeHeight)
							if vRect:containsPoint(ccp(x, y)) == true then
								beganPos = ccp(x, y)
                            	movePos = ccp(x, y)
                            	touchSpIndex = k
                            	-- tankSp:getParent():reorderChild(tankSp, 2)
								return true
							end
						end
					end
					return false
				elseif fn == "moved" then
					if isMultTouch == true then --多点触摸
			            return
			        end
			        if touchSpIndex and tankSpTb[touchSpIndex] and tolua.cast(tankSpTb[touchSpIndex][1], "CCSprite") then
			        	local curTouchPos = ccp(x, y)
			            local moveDisPos = ccpSub(curTouchPos, movePos)
			            local moveDisTem = ccpSub(curTouchPos, beganPos)
			            --部分安卓设备可能存在灵敏度问题
			            local offset = (G_isIOS() == false) and 13 or 30
			            if math.abs(moveDisTem.y) + math.abs(moveDisTem.x) < offset then
			                return
			            end
			            if touchTankSp == nil and tankSpTb[touchSpIndex][3] then
			            	touchTankSp = tankVoApi:getTankIconSp(tankSpTb[touchSpIndex][3], nil, nil, false)
			            	touchTankSp:setScale(tankSpTb[touchSpIndex][1]:getScale())
			            	touchTankSp:setPosition(tankSpTb[touchSpIndex][1]:getPosition())
			            	touchTankSp:setOpacity(150)
			            	self.tabBgLayer:addChild(touchTankSp, 2)
			            end
			            touchTankSp:setPosition(ccpAdd(ccp(touchTankSp:getPosition()), ccp(moveDisPos.x, moveDisPos.y)))
			            -- local tankSp = tankSpTb[touchSpIndex][1]
			            -- tankSp:setPosition(ccpAdd(ccp(tankSp:getPosition()), ccp(moveDisPos.x, moveDisPos.y)))
                		movePos = curTouchPos
			        end
				elseif fn == "ended" then
					if touchSpIndex and tankSpTb[touchSpIndex] and tolua.cast(tankSpTb[touchSpIndex][1], "CCSprite") and touchTankSp then
						-- local tankSp = tankSpTb[touchSpIndex][1]
						for k, v in pairs(tankSpTb) do
							local tempTankSp = v[1]
							local vPos = ccp(tempTankSp:getPosition())
							local vAnchorPoint = tempTankSp:getAnchorPoint()
							local vSizeWidth, vSizeHeight = tempTankSp:getContentSize().width * tempTankSp:getScale(), tempTankSp:getContentSize().height * tempTankSp:getScale()
							local vRect = CCRect(vPos.x - vSizeWidth * vAnchorPoint.x, vPos.y - vSizeHeight * vAnchorPoint.y, vSizeWidth, vSizeHeight)
							if k ~= touchSpIndex and vRect:containsPoint(ccp(touchTankSp:getPosition())) == true then
							-- if k ~= touchSpIndex and vRect:containsPoint(ccp(tankSp:getPosition())) == true then
								print("cjl ------->>>> 交换阵容顺序")
								local ttData = tTroopsData[touchSpIndex]
								tTroopsData[touchSpIndex] = tTroopsData[k]
								tTroopsData[k] = ttData
								local tempTouchIndex = touchSpIndex
								exerWarVoApi:saveLineups(function()
					                G_showTipsDialog(getlocal("save_success"))
					                if self.tempTroopsData then
										local tempData = G_clone(self.tempTroopsData[tempTouchIndex])
										self.tempTroopsData[tempTouchIndex] = G_clone(self.tempTroopsData[k])
										self.tempTroopsData[k] = tempData
										self.checkTroopsData = G_clone(self.tempTroopsData)
									end
									self.tabBgLayer:removeAllChildrenWithCleanup(true)
									self:showPandectUI()
					        	end, tTroopsData)
								-- tankSp = nil
								break
							end
						end
						-- if tankSp then
							-- tankSp:setPosition(tankSpTb[touchSpIndex][2])
							-- tankSp:getParent():reorderChild(tankSp, 1)
						-- end
					end
					if touchTankSp then
						touchTankSp:removeFromParentAndCleanup(true)
					end
					touchTankSp = nil
					touchSpIndex = nil
					beganPos = nil
					touchArray = nil
        			isMultTouch = nil
				else
					if touchTankSp then
						touchTankSp:removeFromParentAndCleanup(true)
					end
					touchTankSp = nil
					-- if touchSpIndex and tankSpTb[touchSpIndex] and tolua.cast(tankSpTb[touchSpIndex][1], "CCSprite") then
					-- 	local tankSp = tankSpTb[touchSpIndex][1]
					-- 	tankSp:setPosition(tankSpTb[touchSpIndex][2])
					-- 	tankSp:getParent():reorderChild(tankSp, 1)
					-- end
					touchSpIndex = nil
					beganPos = nil
					touchArray = nil
        			isMultTouch = nil
				end
			end
			touchLayer:registerScriptTouchHandler(function(...) return touchEvent(...) end, false, - (self.layerNum - 1) * 20 - 2, true)
			touchLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
	    	touchLayer:setTouchEnabled(true)
	    	self.tabBgLayer:addChild(touchLayer)
		end
		local tipsTitleLb = GetTTFLabelWrap(getlocal("exerwar_maneuverTipsText"), 24, CCSizeMake(self.tabBgLayer:getContentSize().width - 36, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop, "Helvetica-bold")
		tipsTitleLb:setAnchorPoint(ccp(0.5, 1))
		tipsTitleLb:setPosition(self.tabBgLayer:getContentSize().width / 2, troopsTipsLb:getPositionY() - troopsTipsLb:getContentSize().height - 25)
		tipsTitleLb:setColor(G_ColorYellowPro)
		self.tabBgLayer:addChild(tipsTitleLb)
		local tipsLbTvSize = CCSizeMake(self.tabBgLayer:getContentSize().width - 36, tipsTitleLb:getPositionY() - tipsTitleLb:getContentSize().height - 16)
		local tipsLbTv = G_createTableView(tipsLbTvSize, 5, function(idx, cellNum)
			local height = 0
			height = height + 5
			local str
			if idx + 1 == 5 then
				str = getlocal("exerwar_maneuverTipsText" .. (idx + 1), {exerWarVoApi:getAccessoryPercent()})
			else
				str = getlocal("exerwar_maneuverTipsText" .. (idx + 1))
			end
			local descLb = GetTTFLabelWrap(str, 22, CCSizeMake(tipsLbTvSize.width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
			height = height + descLb:getContentSize().height
			height = height + 5
			return CCSizeMake(tipsLbTvSize.width, height)
		end, function(cell, cellSize, idx, cellNum)
			local str
			if idx + 1 == 5 then
				str = getlocal("exerwar_maneuverTipsText" .. (idx + 1), {exerWarVoApi:getAccessoryPercent()})
			else
				str = getlocal("exerwar_maneuverTipsText" .. (idx + 1))
			end
			local descLb = GetTTFLabelWrap(str, 22, CCSizeMake(cellSize.width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
			descLb:setAnchorPoint(ccp(0, 0.5))
			descLb:setPosition(0, cellSize.height / 2)
			cell:addChild(descLb)
		end)
		tipsLbTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 2)
	    tipsLbTv:setPosition((self.tabBgLayer:getContentSize().width - tipsLbTvSize.width) / 2, 3)
	    tipsLbTv:setMaxDisToBottomOrTop(0)
	    self.tabBgLayer:addChild(tipsLbTv)
	    --]]
	elseif self.curShowUITag == 101 or self.curShowUITag == 102 then
		local tipsStr
		if self.curShowUITag == 101 then
			tipsStr = getlocal("exerwar_fightReadyText")
		elseif self.curShowUITag == 102 then
			tipsStr = getlocal("exerwar_fighting")
		end
		if tipsStr then
			local tipsLb = GetTTFLabelWrap(tipsStr, 24, CCSizeMake(self.tabBgLayer:getContentSize().width - 6, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
		    tipsLb:setPosition(self.tabBgLayer:getContentSize().width / 2, self.tabBgLayer:getContentSize().height / 2)
		    tipsLb:setColor(G_ColorYellowPro)
		    self.tabBgLayer:addChild(tipsLb)
		end
	elseif self.curShowUITag == 103 then
		local list, listSize = nil, 0
	    local reortData = exerWarVoApi:getReportList(self.period)
	    if reortData then
	        if reortData.list then
	            list = reortData.list
	            listSize = SizeOfTable(list or {})
	        end
	    end


	    local myTotalScore = 0
	    if list and listSize > 0 then
	    	for k, v in pairs(list) do
	    		myTotalScore = myTotalScore + tonumber(v[10])
	    	end
	    end
	    local subTitleHeight = 50
	    local tv
	    local function tvCallBack(cell, cellSize, idx, cellNum)
	        local cellWidth = cellSize.width
	        local cellHeight = cellSize.height
	        if idx == 1 and listSize == 0 then
	            local str = getlocal("exerwar_notDataText1")
	            local notLb = GetTTFLabelWrap(str, 24, CCSizeMake(cellWidth - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	            notLb:setAnchorPoint(ccp(0.5, 0.5))
	            notLb:setPosition(cellWidth / 2, cellHeight / 2)
	            notLb:setColor(G_ColorGray)
	            cell:addChild(notLb)
	        elseif idx == 0 then
	            local tipsStr = getlocal("exerwar_maneuverEndText")
	            local titleW = cellWidth - 50
	            if G_getCurChoseLanguage() == "en" then
	                titleW = cellWidth - 180
	            end
	            local titleBg, titleLb, titleLbHeight = G_createNewTitle({tipsStr, 24, G_ColorYellowPro}, CCSizeMake(titleW, 0), nil, true, "Helvetica-bold")
	            titleBg:setAnchorPoint(ccp(0.5, 0))
                titleBg:setPosition(cellWidth / 2, cellHeight - titleLbHeight - 10)
	            cell:addChild(titleBg)
	            local subTipsStr = ""
	            if myTotalScore > 0 then
	            	subTipsStr = getlocal("exerwar_maneuverCurTotalScoreText1", {myTotalScore})
	            end
	            if subTipsStr == "" then
                    titleBg:setPositionY((cellHeight - titleLbHeight) / 2)
                else
                    local sutTitleLb = GetTTFLabel(subTipsStr, 22)
                    sutTitleLb:setAnchorPoint(ccp(0.5, 1))
                    sutTitleLb:setPosition(cellWidth / 2, titleBg:getPositionY() - 5)
                    cell:addChild(sutTitleLb)
                end
	        else
	            local data = list[idx]
	            if data then
	                local id = data[1]
	                local aName = data[3]
	                local rate = data[5]
	                local dName = data[7]
	                local isVictory = (data[9] == 1)
	                local score = data[10]
	                local fontSize = 22

	                if (idx - 1) % 3 == 0 then
		        		cellHeight = cellHeight - subTitleHeight
		        		local vsSp = CCSprite:createWithSpriteFrameName("VS.png")
		        		vsSp:setAnchorPoint(ccp(0.5, 0))
		                vsSp:setScale(30 / vsSp:getContentSize().height)
		                vsSp:setPosition(cellWidth / 2, cellHeight)
		                cell:addChild(vsSp)
		                local myNameLb = GetTTFLabel(aName, 22)
		                myNameLb:setAnchorPoint(ccp(0.5, 0))
		                myNameLb:setPosition(cellWidth / 2 - (cellWidth / 2 - 35) / 2 - 20, vsSp:getPositionY())
		                cell:addChild(myNameLb)
		                local dfNameLb = GetTTFLabel(dName, 22)
		                dfNameLb:setAnchorPoint(ccp(0.5, 0))
		                dfNameLb:setPosition(cellWidth / 2 + (cellWidth / 2 - 35) / 2 + 20, vsSp:getPositionY())
		                cell:addChild(dfNameLb)
		        	end

	                local bgWidth, bgHeight = cellWidth / 2 - 35, cellHeight - 10

                    local resultBgL = CCSprite:createWithSpriteFrameName("ltzdzCampBg" .. (isVictory and 1 or 2) .. ".png")
                    resultBgL:setFlipX(true)
                    resultBgL:setFlipY(isVictory)
                    resultBgL:setScaleX(bgWidth / resultBgL:getContentSize().width)
                    resultBgL:setScaleY(bgHeight / resultBgL:getContentSize().height)
                    resultBgL:setPosition(cellWidth / 2 - bgWidth / 2 - 20, cellHeight / 2)
                    -- resultBgL:setOpacity(255 * 0.3)
                    cell:addChild(resultBgL)
                    local resultBgR = CCSprite:createWithSpriteFrameName("ltzdzCampBg" .. (isVictory and 1 or 2) .. ".png")
                    resultBgR:setFlipY(isVictory)
                    resultBgR:setScaleX(bgWidth / resultBgR:getContentSize().width)
                    resultBgR:setScaleY(bgHeight / resultBgR:getContentSize().height)
                    resultBgR:setPosition(cellWidth / 2 + bgWidth / 2 + 20, cellHeight / 2)
                    -- resultBgR:setOpacity(255 * 0.3)
                    cell:addChild(resultBgR)

                    local statusSp = CCSprite:createWithSpriteFrameName(isVictory and "winnerMedal.png" or "loserMedal.png")
                    statusSp:setAnchorPoint(ccp(0.5, 0))
                    statusSp:setPosition(resultBgL:getPositionX() - bgWidth / 2 + statusSp:getContentSize().width / 2 + 25, resultBgL:getPositionY() - bgHeight / 2 + 5)
                    cell:addChild(statusSp)
                    local statusLb = GetTTFLabel(getlocal(isVictory and "fight_content_result_win" or "fight_content_result_defeat"), fontSize)
                    statusLb:setColor(isVictory and G_ColorGreen or G_ColorRed)
                    statusLb:setAnchorPoint(ccp(0.5, 1))
                    statusLb:setPosition(statusSp:getPositionX(), resultBgL:getPositionY() + bgHeight / 2 - 5)
                    cell:addChild(statusLb)

                    local rateLb = GetTTFLabel(getlocal("exerwar_killRateText"), fontSize)
                    local rateValueLb = GetTTFLabel(G_GetPreciseDecimal(rate * 100, 1) .. "%", fontSize)
                    rateLb:setAnchorPoint(ccp(1, 0))
                    rateValueLb:setAnchorPoint(ccp(1, 0))
                    rateValueLb:setPosition(resultBgR:getPositionX() + bgWidth / 2 - 25, cellHeight / 2 + 5)
                    rateLb:setPosition(rateValueLb:getPositionX() - rateValueLb:getContentSize().width, rateValueLb:getPositionY())
                    rateValueLb:setColor(G_ColorYellowPro)
                    cell:addChild(rateLb)
                    cell:addChild(rateValueLb)
                    local scoreLb = GetTTFLabel(getlocal("exerwar_getScoreText"), fontSize)
                    local scoreValueLb = GetTTFLabel(tostring(score), fontSize)
                    scoreLb:setAnchorPoint(ccp(1, 1))
                    scoreValueLb:setAnchorPoint(ccp(1, 1))
                    scoreValueLb:setPosition(rateValueLb:getPositionX(), cellHeight / 2 - 5)
                    scoreLb:setPosition(scoreValueLb:getPositionX() - scoreValueLb:getContentSize().width, scoreValueLb:getPositionY())
                    scoreValueLb:setColor(G_ColorYellowPro)
                    cell:addChild(scoreLb)
                    cell:addChild(scoreValueLb)

                    local function onClickCamera(tag, obj)
                        if G_checkClickEnable() == false then
                            do return end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)
                        if tv and tv:getIsScrolled() == true then
                            do return end
                        end
                        exerWarVoApi:showReportDetail(self.layerNum + 1, self.period, id, nil, getlocal("exerwar_serverFirstText"))
                    end
                    local cameraBtn = GetButtonItem("cameraBtn.png", "cameraBtn_down.png", "cameraBtn.png", onClickCamera)
                    local cameraMenu = CCMenu:createWithItem(cameraBtn)
                    cameraMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                    cameraMenu:setPosition(0, 0)
                    cameraBtn:setPosition(cellWidth / 2, cellHeight / 2)
                    cell:addChild(cameraMenu)
	            end
	        end
	    end
	    local tvSize = CCSizeMake(self.tabBgLayer:getContentSize().width - 6, self.tabBgLayer:getContentSize().height - 6)
	    local cellNum = 1 + (listSize == 0 and 1 or listSize)
	    tv = G_createTableView(tvSize, cellNum, function(idx)
	        local cellHeight = 130
	        if idx == 1 and listSize == 0 then
	            cellHeight = 85
	        elseif idx == 0 then
	            cellHeight = 80
	        elseif (idx - 1) % 3 == 0 then
	        	cellHeight = cellHeight + subTitleHeight
	        end
	        return CCSizeMake(tvSize.width, cellHeight)
	    end, tvCallBack)
	    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
	    tv:setPosition(ccp(3, 3))
	    self.tabBgLayer:addChild(tv)

	    --[[
	    local tv
	    local function tvCallBack(cell, cellSize, idx, cellNum)
	        local cellWidth = cellSize.width
	        local cellHeight = cellSize.height
	        if idx == 1 and listSize == 0 then
	            local str = getlocal("exerwar_notDataText1")
	            local notLb = GetTTFLabelWrap(str, 24, CCSizeMake(cellWidth - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	            notLb:setAnchorPoint(ccp(0.5, 0.5))
	            notLb:setPosition(cellWidth / 2, cellHeight / 2)
	            notLb:setColor(G_ColorGray)
	            cell:addChild(notLb)
	        elseif idx == 0 then
	            local tipsStr = getlocal("exerwar_maneuverEndText")
	            local titleW = cellWidth - 50
	            if G_getCurChoseLanguage() == "en" then
	                titleW = cellWidth - 180
	            end
	            local titleBg, titleLb, titleLbHeight = G_createNewTitle({tipsStr, 24, G_ColorYellowPro}, CCSizeMake(titleW, 0), nil, true, "Helvetica-bold")
	            titleBg:setPosition(cellWidth / 2, (cellHeight - titleLbHeight) / 2)
	            cell:addChild(titleBg)
	        else
	            local data = list[idx]
	            if data then
	                local id = data[1]
	                local aName = data[3]
	                local rate = data[5]
	                local dName = data[7]
	                local isVictory = data[9]
	                local score = data[10]
	                local attBg, defBg
	                local attStatusLb, defStatusLb
	                local attStatusSp, defStatusSp
	                local fontSize = 22
	                if isVictory == 1 then
	                    attBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg1.png")
	                    attBg:setRotation(180)
	                    defBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg2.png")
	                    attStatusLb = GetTTFLabel(getlocal("fight_content_result_win"), fontSize)
	                    defStatusLb = GetTTFLabel(getlocal("fight_content_result_defeat"), fontSize)
	                    attStatusLb:setColor(G_ColorGreen)
	                    defStatusLb:setColor(G_ColorRed)
	                    attStatusSp = CCSprite:createWithSpriteFrameName("winnerMedal.png")
	                    defStatusSp = CCSprite:createWithSpriteFrameName("loserMedal.png")
	                else
	                    attBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg2.png")
	                    attBg:setFlipX(true)
	                    defBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg1.png")
	                    defBg:setFlipY(true)
	                    attStatusLb = GetTTFLabel(getlocal("fight_content_result_defeat"), fontSize)
	                    defStatusLb = GetTTFLabel(getlocal("fight_content_result_win"), fontSize)
	                    attStatusLb:setColor(G_ColorRed)
	                    defStatusLb:setColor(G_ColorGreen)
	                    attStatusSp = CCSprite:createWithSpriteFrameName("loserMedal.png")
	                    defStatusSp = CCSprite:createWithSpriteFrameName("winnerMedal.png")
	                end
	                local bgWidth, bgHeight = cellWidth / 2 - 35, cellHeight - 60
	                local bgPosY = cellHeight / 2
	                attBg:setScaleX(bgWidth / attBg:getContentSize().width)
	                attBg:setScaleY(bgHeight / attBg:getContentSize().height)
	                defBg:setScaleX(bgWidth / defBg:getContentSize().width)
	                defBg:setScaleY(bgHeight / defBg:getContentSize().height)
	                attBg:setPosition(cellWidth / 2 - bgWidth / 2 - 20, bgPosY)
	                defBg:setPosition(cellWidth / 2 + bgWidth / 2 + 20, bgPosY)
	                cell:addChild(attBg)
	                cell:addChild(defBg)
	                attStatusLb:setAnchorPoint(ccp(0.5, 1))
	                attStatusLb:setPosition(attBg:getPositionX(), attBg:getPositionY() + bgHeight / 2 - 5)
	                cell:addChild(attStatusLb)
	                defStatusLb:setAnchorPoint(ccp(0.5, 1))
	                defStatusLb:setPosition(defBg:getPositionX(), defBg:getPositionY() + bgHeight / 2 - 5)
	                cell:addChild(defStatusLb)
	                attStatusSp:setAnchorPoint(ccp(0.5, 0))
	                attStatusSp:setPosition(attBg:getPositionX(), attBg:getPositionY() - bgHeight / 2)
	                cell:addChild(attStatusSp)
	                defStatusSp:setAnchorPoint(ccp(0.5, 0))
	                defStatusSp:setPosition(defBg:getPositionX(), defBg:getPositionY() - bgHeight / 2)
	                cell:addChild(defStatusSp)
	                local vsSp = CCSprite:createWithSpriteFrameName("VS.png")
	                vsSp:setAnchorPoint(ccp(0.5, 0))
	                vsSp:setScale(0.3)
	                vsSp:setPosition(cellWidth / 2, attBg:getPositionY() + bgHeight / 2)
	                cell:addChild(vsSp)
	                local attNameLb = GetTTFLabel(aName, fontSize)
	                attNameLb:setAnchorPoint(ccp(0.5, 0))
	                attNameLb:setPosition(attBg:getPositionX(), attBg:getPositionY() + bgHeight / 2)
	                cell:addChild(attNameLb)
	                local defNameLb = GetTTFLabel(dName, fontSize)
	                defNameLb:setAnchorPoint(ccp(0.5, 0))
	                defNameLb:setPosition(defBg:getPositionX(), defBg:getPositionY() + bgHeight / 2)
	                cell:addChild(defNameLb)
	                local lbStr = getlocal("believer_kill_rate", {G_GetPreciseDecimal(rate * 100, 1)})
                    lbStr = lbStr .. "            "
                    lbStr = lbStr .. getlocal("believer_get_score", {score})
                    local rateAndScoreLb, rateAndScoreLbHeight = G_getRichTextLabel(lbStr, {nil, G_ColorGreen, nil, G_ColorGreen, nil}, fontSize, cellWidth - 70, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                    rateAndScoreLb:setAnchorPoint(ccp(0, 1))
                    rateAndScoreLb:setPosition(attBg:getPositionX() - bgWidth / 2, attBg:getPositionY() - bgHeight / 2)
                    cell:addChild(rateAndScoreLb)
	                -- local rateLb, rateLbHeight = G_getRichTextLabel(getlocal("believer_kill_rate", {G_GetPreciseDecimal(rate * 100, 1)}), {nil, G_ColorGreen, nil}, fontSize, bgWidth, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	                -- rateLb:setAnchorPoint(ccp(0.5, 1))
	                -- rateLb:setPosition(attBg:getPositionX(), attBg:getPositionY() - bgHeight / 2)
	                -- cell:addChild(rateLb)
	                -- local scoreLb, scoreLbHeight = G_getRichTextLabel(getlocal("believer_get_score", {score}), {nil, G_ColorGreen, nil}, fontSize, bgWidth, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	                -- scoreLb:setAnchorPoint(ccp(0.5, 1))
	                -- scoreLb:setPosition(defBg:getPositionX(), defBg:getPositionY() - bgHeight / 2)
	                -- cell:addChild(scoreLb)
	                local function onClickCamera(tag, obj)
	                    if G_checkClickEnable() == false then
	                        do return end
	                    else
	                        base.setWaitTime = G_getCurDeviceMillTime()
	                    end
	                    PlayEffect(audioCfg.mouseClick)
	                    if tv and tv:getIsScrolled() == true then
                            do return end
                        end
	                    exerWarVoApi:showReportDetail(self.layerNum + 1, self.period, id, nil, getlocal("exerwar_serverFirstText"))
	                end
	                local cameraBtn = GetButtonItem("cameraBtn.png", "cameraBtn_down.png", "cameraBtn.png", onClickCamera)
	                local cameraMenu = CCMenu:createWithItem(cameraBtn)
	                cameraMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
	                cameraMenu:setPosition(0, 0)
	                cameraBtn:setPosition(cellWidth / 2, bgPosY)
	                cell:addChild(cameraMenu)
	            end
	        end
	    end
	    local tvSize = CCSizeMake(self.tabBgLayer:getContentSize().width - 6, self.tabBgLayer:getContentSize().height - 6)
	    local cellNum = 1 + (listSize == 0 and 1 or listSize)
	    tv = G_createTableView(tvSize, cellNum, function(idx)
	        local cellHeight = 175
	        if idx == 1 and listSize == 0 then
	            cellHeight = 85
	        elseif idx == 0 then
	            cellHeight = 65
	        end
	        return CCSizeMake(tvSize.width, cellHeight)
	    end, tvCallBack)
	    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
	    tv:setPosition(ccp(3, 3))
	    self.tabBgLayer:addChild(tv)
	    --]]
	end
end

--显示参赛名单UI
function exerWarFirstPVPDialog:showCompetitionListUI()
	local tvTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png", CCRect(4, 4, 1, 1), function()end)
    tvTitleBg:setContentSize(CCSizeMake(self.tabBgLayer:getContentSize().width - 6, 40))
    tvTitleBg:setAnchorPoint(ccp(0.5, 1))
    tvTitleBg:setPosition(self.tabBgLayer:getContentSize().width / 2, self.tabBgLayer:getContentSize().height - 3)
    self.tabBgLayer:addChild(tvTitleBg)
    local titleWidthRate = {0.08, 0.25, 0.45, 0.63, 0.85}
    local titleStrTb = {
        getlocal("exerwar_rankTab2_t1"), getlocal("exerwar_rankTab2_t2"), getlocal("exerwar_rankTab2_t3"), getlocal("exerwar_rankTab2_t5"), getlocal("exerwar_rankTab2_t6")
    }
    for k, v in pairs(titleStrTb) do
        local titleLb = GetTTFLabel(v, 22, true)
        titleLb:setPosition(tvTitleBg:getContentSize().width * titleWidthRate[k], tvTitleBg:getContentSize().height / 2)
        titleLb:setColor(G_ColorYellowPro)
        tvTitleBg:addChild(titleLb)
    end
	local tipsStr
	if self.curShowUITag == 100 then
		tipsStr = (exerWarVoApi:isEnterFirstPVP() == true) and getlocal("exerwar_notCompetitionListText") or getlocal("exerwar_notQualificationText")
	elseif self.curShowUITag == 101 then
		tipsStr = getlocal("exerwar_createbBattleList")
	end
	if tipsStr then
		local tipsLb = GetTTFLabelWrap(tipsStr, 24, CCSizeMake(self.tabBgLayer:getContentSize().width - 6, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	    tipsLb:setPosition(self.tabBgLayer:getContentSize().width / 2, self.tabBgLayer:getContentSize().height / 2)
	    tipsLb:setColor(G_ColorYellowPro)
	    self.tabBgLayer:addChild(tipsLb)
	else
		local competitionList = exerWarVoApi:getCompetitionList()
		local isShowSelf = false
	    for k, v in pairs(competitionList) do
	        if v[1] == playerVoApi:getUid() and v[3] == base.curZoneID then
	            local selfCellBg = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function () end)
	            selfCellBg:setContentSize(CCSizeMake(self.tabBgLayer:getContentSize().width - 6, 60 - 4))
	            selfCellBg:setPosition(self.tabBgLayer:getContentSize().width / 2, tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - 60 / 2)
	            self.tabBgLayer:addChild(selfCellBg)
	            local labelStrTb = {
	                tonumber(k), v[2] or "", GetServerNameByID(tonumber(v[3] or 0), true), FormatNumber(tonumber(v[4] or 0)), FormatNumber(tonumber(v[5] or 0))
	            }
	            for kk, vv in pairs(labelStrTb) do
                    local label = GetTTFLabel(vv, 22)
                    label:setPosition(self.tabBgLayer:getContentSize().width * titleWidthRate[kk], tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - 60 / 2)
                    self.tabBgLayer:addChild(label)
	            end
	            isShowSelf = true
	            break
	        end
	    end
	    local tvSize = CCSizeMake(self.tabBgLayer:getContentSize().width - 6, self.tabBgLayer:getContentSize().height - 6 - tvTitleBg:getContentSize().height - (isShowSelf and 60 or 0))
	    local tv = G_createTableView(tvSize, SizeOfTable(competitionList), CCSizeMake(tvSize.width, 60), function(cell, cellSize, idx, cellNum)
	        local cellBgPic = "exer_lightGreenFrame.png"
	        if idx + 1 <= 2 then
	            cellBgPic = "exer_lightYellowFrame.png"
	        end
	        local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName(cellBgPic, CCRect(3, 10, 1, 1), function()end)
	        cellBg:setContentSize(CCSizeMake(cellSize.width - 4, cellSize.height - 4))
	        cellBg:setPosition(cellSize.width / 2, cellSize.height / 2)
	        cell:addChild(cellBg)
	        local data = competitionList[idx + 1]
	        local labelStrTb = {
	            tonumber(idx + 1), data[2] or "", GetServerNameByID(tonumber(data[3] or 0), true), FormatNumber(tonumber(data[4] or 0)), FormatNumber(tonumber(data[5] or 0))
	        }
	        for k, v in pairs(labelStrTb) do
                local label = GetTTFLabel(v, 22)
                label:setPosition(cellSize.width * titleWidthRate[k], cellSize.height / 2)
                cell:addChild(label)
	        end
	    end)
	    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
	    tv:setPosition(ccp(3, 3))
	    self.tabBgLayer:addChild(tv)
	end
end

function exerWarFirstPVPDialog:tick()
	local showTag
	local status, et, round = exerWarVoApi:getWarStatus()
	if status < 20 then --未开启
    elseif status >= 30 then --本轮已结束
    	showTag = 103
    else
        if status == 21 then --设置部队报名中
        	showTag = 100
        elseif status == 22 then --生成参赛名单
        	showTag = 101
        elseif status == 23 then --战斗中
        	showTag = 102
        else --本轮已结束查看战报
        	showTag = 103
        end
    end
    if showTag then
    	if self.curShowUITag ~= showTag then
            self:showUI(showTag)
        end
    end
end

function exerWarFirstPVPDialog:dispose()
	self = nil
	spriteController:removePlist("public/youhuaUI4.plist")
    spriteController:removeTexture("public/youhuaUI4.png")
    spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
end