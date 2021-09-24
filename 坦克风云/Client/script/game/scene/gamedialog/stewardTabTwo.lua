stewardTabTwo={}

function stewardTabTwo:init(layerNum,parent)
	self.layerNum = layerNum
	self.parent   = parent
	self.bgSize	  = parent.bgSize
	self.bgLayer = CCLayer:create()
	self.notOpenTb  = {}--未开放
	self.tvViewTb 	= {}
	self.openNum 	= 0
	self.allOpen 	= nil
	self.needZeroTime = stewardVoApi:getZeroTime( )
	self:initUI()

	return self.bgLayer
end
function stewardTabTwo:dispose()
	self.tvViewTb	= nil
	self.notOpenTb  = nil
	self.openNum 	= nil
	self.allOpen 	= nil
	self.tv 		= nil
end

function stewardTabTwo:initUI()
	self.allOpen,self.notOpenTb,self.openNum  = stewardVoApi:isAllSweepOpened( )--所有功能是否开启
	self:initEveryModuldData()
	self:initTvViewData()

	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    tvBg:setContentSize(CCSizeMake(self.bgSize.width-40,self.bgSize.height-210))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(self.bgSize.width/2,self.bgSize.height-85)
    self.bgLayer:addChild(tvBg)

	local function tvCallBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgSize.width-40,tvBg:getContentSize().height-4),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,tvBg:getPositionY()-tvBg:getContentSize().height+2))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local tipLabel = GetTTFLabelWrap(getlocal("steward_tabTwo_tip"),20,CCSizeMake(tvBg:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    tipLabel:setAnchorPoint(ccp(0.5,1))
    tipLabel:setPosition(self.bgSize.width/2,tvBg:getPositionY()-tvBg:getContentSize().height-10)
    tipLabel:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(tipLabel)

    local function extractHandler(tag,obj)
    	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        print("cjl --------->>>> 一键扫荡")
        -- if self.slCanRaid == 0 and self.swCan == false and self.expCan ==false then
        	-- local raidReward=sData.data.echallengeraid.report
         --    if raidReward and SizeOfTable(raidReward)==1 then
         --        for k,v in pairs(raidReward) do
         --            if tonumber(v) and tonumber(v)<0 then
         --                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("accessory_bag_full"),nil,layerNum+1)
         --                do return end
         --            end
         --        end
         --    end
        -- end
        local function sucessCall(allAwardTb,allAwardTipTb)
        	require "luascript/script/game/scene/gamedialog/stewardLotterySmallDialogTwo"
        	G_playBoomAction(self.bgLayer,ccp(self.bgSize.width/2,self.bgSize.height/2),
        		function()
        			stewardLotterySmallDialogTwo:showLotteryRewardDialog(self.layerNum+1, getlocal("award"), allAwardTb,allAwardTipTb,self.parent)
        		end,0.6,3)
        	self:refreshSelf()
        end 
        stewardVoApi:socketSweeping(self.layerNum,sucessCall)
    end
    local btnScale = 0.8
    local strSize = 24/btnScale 
    if G_isAsia() == false then
    	if G_isIOS() == true then
    		strSize = 20/btnScale 
    	else
    		strSize = 17/btnScale 
    	end
    end
    local extractBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",extractHandler,11,getlocal("steward_title_tabTwo"),strSize)
    extractBtn:setScale(btnScale)
    extractBtn:setAnchorPoint(ccp(0.5,1))
    local menu=CCMenu:createWithItem(extractBtn)
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    menu:setPosition(ccp(self.bgSize.width/2,tipLabel:getPositionY()-tipLabel:getContentSize().height-10))
    self.bgLayer:addChild(menu)

    self.extractBtn  = extractBtn
    self:BtnCanUse()

    self:tick()

end

function stewardTabTwo:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.openNum
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.bgSize.width-40,90)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellW, cellH = self.bgSize.width-40,90

		local iconBg = CCSprite:createWithSpriteFrameName(self.tvViewTb[idx+1].icon)
		iconBg:setAnchorPoint(ccp(0,0.5))
		iconBg:setPosition(15,cellH * 0.5)
		iconBg:setScale((cellH-18)/iconBg:getContentSize().height)
		cell:addChild(iconBg)

		local strSize = 22
		if G_isAsia() == false then
			strSize = 16
		end
		local sizeWidth = cellW * 0.7
		if G_getCurChoseLanguage() == "ar" then
			sizeWidth = cellW * 0.4
		end
		local nameLb = GetTTFLabelWrap(self.tvViewTb[idx+1].title,strSize,CCSizeMake(sizeWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
		nameLb:setAnchorPoint(ccp(0,1))
		nameLb:setPosition(iconBg:getPositionX()+iconBg:getContentSize().width*iconBg:getScale()+10,cellH-10)
		cell:addChild(nameLb,1)

		local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
        lineSp:setContentSize(CCSizeMake(cellW-18, 3))
        lineSp:ignoreAnchorPointForPosition(false)
        lineSp:setAnchorPoint(ccp(0.5,0.5))
        lineSp:setPosition(cellW/2,0)
        cell:addChild(lineSp,1)

        local descStr,useBlack = nil,true
		if self.tvViewTb[idx + 1].typeName == "sl" then
			-- print("self.slCanRaid====>>>>",self.slCanRaid)
			if self.slCanRaid == 0 then
				useBlack =false
			end
			self:addSlTipCell(self.slCanRaid,cell,ccp(iconBg:getPositionX()+iconBg:getContentSize().width*iconBg:getScale()+10,10),cellW,cellH,useBlack)

			
		elseif self.tvViewTb[idx + 1].typeName == "exp" then
			if self.expCan then
				useBlack = false
			end
			self:addExpTipCell(self.expCan,cell,ccp(iconBg:getPositionX()+iconBg:getContentSize().width*iconBg:getScale()+10,10),cellW,cellH,useBlack)
			
		elseif self.tvViewTb[idx + 1].typeName == "sw" then
			if self.swCan then
				useBlack = false
			end
			self:addSwTipCell(self.swCan,cell,ccp(iconBg:getPositionX()+iconBg:getContentSize().width*iconBg:getScale()+10,10),cellW,cellH,useBlack)
		end
		if useBlack then
			nameLb:setColor(G_ColorGray)
			iconBg:setColor(G_ColorGray)
	        local cellAlpha = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
	        cellAlpha:setContentSize(CCSizeMake(cellW-4,cellH-3))
	        cellAlpha:setPosition(cellW * 0.5,cellH * 0.5)
	        cellAlpha:setOpacity(100)
	        cell:addChild(cellAlpha,0)
    	end
		return cell
	end
end

function stewardTabTwo:tick()
	if stewardVoApi:isSocketExpFun() == false then
		stewardVoApi:setIsSocketExp(true)
		if base.expeditionSwitch > 0 and base.ea > 0 and playerVoApi:getPlayerLevel() >= expeditionCfg.openLevel then
			local function getExpCall(fn,data)
				local ret,sData=base:checkServerData(data)
		        if ret==true then
		        	self:refreshSelf()
		        end
		    end
		    socketHelper:expeditionGet(getExpCall)
		end
	elseif self.needZeroTime < base.serverTime + 1 then
		 stewardVoApi:setIsSocketExp(true)

		 stewardVoApi:setZeroTime(self.needZeroTime + 86400)
		 self.needZeroTime = stewardVoApi:getZeroTime( )
		 if base.expeditionSwitch > 0 and base.ea > 0 and playerVoApi:getPlayerLevel() >= expeditionCfg.openLevel then
			local function getExpCall(fn,data)
				local ret,sData=base:checkServerData(data)
		        if ret==true then
					local function refreshCall( )
						if accessoryVoApi and accessoryVoApi.resetECData then
							accessoryVoApi:resetECData()
						end
						self:refreshSelf()	
					end
					buildingCueMgr:getTipData(refreshCall)
				end
			end
			socketHelper:expeditionGet(getExpCall)
		else
			local function refreshCall( )
				if accessoryVoApi and accessoryVoApi.resetECData then
					accessoryVoApi:resetECData()
				end
				self:refreshSelf()	
			end
			buildingCueMgr:getTipData(refreshCall)
		end
	end
	local leftTime=superWeaponVoApi:getRaidLeftTime()
    if leftTime > 0 then--超武 神秘组织 扫荡中
    	if self.swCurFloorLb then
    		local curFloor,leftFloor=superWeaponVoApi:getRaidFloor()
    		if curFloor ~= self.swCurFloor then
    			self.swCurFloor = curFloor
    			self.swCurFloorLb:setString(getlocal("sw_raid_current_floor",{curFloor}))
    		end
    	end
	    if self.swSpeedUpGemsLb then
	        local speedUpGems=superWeaponVoApi:raidSpeedUpCost(leftTime)
	        if speedUpGems<0 then
	            speedUpGems=0
	        end
	        self.swSpeedUpGemsLb:setString(speedUpGems)
	    end
	elseif self.swCurFloorLb then
		self.swCurFloorLb,self.swSpeedUpGemsLb = nil,nil
		print(" in tick refreshSelf~~~~~~~~~~")
		self:refreshSelf()
	end
end

function stewardTabTwo:BtnCanUse( )
	-- print("self.slCanRaid > 0 and self.expCan == false and self.swCan=======>>>>",self.slCanRaid, self.expCan , self.swCan)
	--if superWeaponVoApi:getRaidLeftTime() > 0 or 
	if self.slCanRaid > 0 and self.expCan == false and (self.swCan == false or superWeaponVoApi:getRaidLeftTime() > 0) then
		self.extractBtn:setEnabled(false)
	else
		self.extractBtn:setEnabled(true)
	end
end
function stewardTabTwo:initTvViewData( )
	self.tvViewTb[1] = {title = getlocal("accessory_title_2"),icon = "icon_supply_lines.png",typeName = "sl"}
	if self.allOpen then
			self.tvViewTb[2] = {title = getlocal("expedition"),icon = "epdtIcon.png",typeName = "exp"}
			self.tvViewTb[3] = {title = getlocal("super_weapon_title_2"),icon = "sw_2.png",typeName = "sw"}
	else
		if not self.notOpenTb[2] then
			self.tvViewTb[2] = {title = getlocal("expedition"),icon = "epdtIcon.png",typeName = "exp"}
		elseif not self.notOpenTb[3] then
			self.tvViewTb[2] = {title = getlocal("super_weapon_title_2"),icon = "sw_2.png",typeName = "sw"}
		end
	end
end
function stewardTabTwo:initEveryModuldData( )
	self.slCanRaid,self.slNeedVipLevel,self.slLeftResetNum = stewardVoApi:vipUseInSupplyLine()--补给线
	if not self.notOpenTb[2] then
		self.expCan,self.expStarts,self.expResetNum = stewardVoApi:expeditionCanSweep()--远征
	else
		self.expCan = false
	end
	if not self.notOpenTb[3] then
		self.swCan,self.swCurPos = stewardVoApi:superWeaponCanSweep()--超武
		self.swResetNum = stewardVoApi:getLeftResetNum()
	else
		self.swCan = false
	end
end

function stewardTabTwo:addSlTipCell(whiId,parent,descPos,pWidth,pHeight,useBlack)--补给线cell的分类
	
	whiId = whiId > 4 and 2 or whiId
	local btnScale = 0.83
	local descStr,btnLb  = nil,{getlocal("dailyTaskReset"),getlocal("steward_tabTwo_btnLb"..whiId),getlocal("dailyTaskReset"),getlocal("hold_name3"),getlocal("buy")}
	local btnPic1,btnPic2 = "steward_green_midBtn.png","steward_green_midBtn_down.png"

	if whiId == 4 then
		btnPic1,btnPic2 = "creatRoleBtn.png","creatRoleBtn_Down.png"
		btnScale = 0.6
	elseif (whiId == 0 or whiId == 2) and accessoryVoApi:getLeftResetNum() == 0 then
		btnPic1,btnPic2 = "yh_nbSkillGoto.png","yh_nbSkillGoto_Down.png"
		btnScale = 0.95
		btnLb[whiId + 1] = ""
	end

	-- if whiId > 0 then
		local strSize1 = 20
		if G_isAsia() == false then
			strSize1 = 16
		end
		local useValue = whiId == 1 and self.slNeedVipLevel or ""
		desc = (whiId == 0 or whiId == 2) and getlocal("steward_tabTwo_resetDesc",{self.slLeftResetNum}) or getlocal("steward_tabTwo_slVipLevel_"..(whiId),{useValue})
		local sizeWidth = pWidth * 0.7
		if G_getCurChoseLanguage() == "ar" then
			sizeWidth = pWidth * 0.4
		end
		descStr = GetTTFLabelWrap(desc,strSize1,CCSizeMake(sizeWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
		descStr:setColor(G_ColorGray)
	-- end
	if descStr then
		descStr:setAnchorPoint(ccp(0,0))
		descStr:setPosition(descPos)
		parent:addChild(descStr,1)
	end

	local function gotoCallback(tag ,obj)--0：可以，1：vip等级不够，2：没有剩余的3星关卡，3：仓库不足，4：能量不足
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		print("tag==>>",tag)
		if tag == 2 or tag == 4 then
			if self.parent and self.parent.closeDialog then
	    		self.parent:closeDialog()
	    	end
	    end

		if tag == 1 or tag == 3 then--tag = whiId + 1
			local cfg=accessoryVoApi:getEChallengeCfg()
			local resetGemsTab=cfg.resetGems
			local usedResetNum=accessoryVoApi:getUsedResetNum()
			-- if usedResetNum>=accessoryVoApi:getResetMaxNum() then
			-- 	do return end
			-- end
			local resetGems=resetGemsTab[usedResetNum+1]
	        if(activityVoApi:checkActivityEffective("accessoryFight"))then
	            resetGems=resetGems * activityCfg.accessoryFight.serverreward.reducePrice
	        end
			local needGem=resetGems-playerVoApi:getGems()
			if needGem>0 then
				GemsNotEnoughDialog(nil,nil,needGem,self.layerNum+1,resetGems)
			else
				local remainNum=accessoryVoApi:getLeftResetNum()
				local function resetConfirm()
					local function ecResetCallback(fn,data)
						local ret,sData=base:checkServerData(data)
	                	if ret==true then
	                		if sData and sData.ts then
	                			playerVoApi:setValue("gems",playerVoApi:getGems()-resetGems)
		                		accessoryVoApi:resetData(sData.ts)
		                		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_reset_success"),30)

		                		self:refreshSelf()
		                	end
						end
					end
					socketHelper:echallengeReset(ecResetCallback)
				end
				if remainNum>0 then
					local secondDialog = G_showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),getlocal("elite_challenge_reset_remind",{resetGems}),nil,resetConfirm)
				else
					if self.parent and self.parent.closeDialog then
			    		self.parent:closeDialog()
			    	end
					G_goToDialog2("av",self.layerNum,true)
				end
			end
		elseif tag == 2 then--gb
			G_goToDialog2("gb",self.layerNum,true)
		elseif tag == 3 then
			G_goToDialog2("av",self.layerNum,true)
		elseif tag == 4 then
			G_goToDialog2("au",self.layerNum,true,1)
		elseif tag == 5 then	
			local function refreshSelf( )
				self:refreshSelf()
			end
			-- G_buyEnergy(self.layerNum+1,nil,refreshSelf)
			smallDialog:showEnergySupplementDialog(self.layerNum+1, refreshSelf)
		end		
	end
	local strSize3 = 24
	if G_isAsia() == false then
		strSize3 = 20
	end
	local gotoItem = GetButtonItem(btnPic1,btnPic2,btnPic1,gotoCallback,whiId + 1,btnLb[whiId + 1],strSize3)
    gotoItem:setAnchorPoint(ccp(1,0.5))
    gotoMenu = CCMenu:createWithItem(gotoItem)
    gotoMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    gotoMenu:setPosition(pWidth - 15 - 54 - 15,pHeight * 0.5)
    parent:addChild(gotoMenu,1)

	gotoItem:setScale(btnScale)

    if (whiId == 0 or whiId == 2) then 
    	if self.slLeftResetNum > 0 then
	    	descStr:setColor(G_ColorWhite)
	    	gotoItem:setEnabled(true)
	    end
    end
    if useBlack then
    	descStr:setColor(G_ColorGray)
    end

    local function goSupply()
		if self.parent and self.parent.closeDialog then
    		self.parent:closeDialog()
    	end
    	G_goToDialog2("supply",self.layerNum,true)
    end
    local goSupplyBtn=G_createBotton(parent,ccp(pWidth - 15,pHeight * 0.5),{},"yh_nbSkillGoto.png","yh_nbSkillGoto_Down.png","yh_nbSkillGoto.png",goSupply,54/57,-(self.layerNum-1)*20-5)
    goSupplyBtn:setAnchorPoint(ccp(1,0.5))
end
function stewardTabTwo:addExpTipCell(expIsCan,parent,descPos,pWidth,pHeight,useBlack)
	local descStr,descLb = nil,nil
	local btnPic1,btnPic2 = "steward_green_midBtn.png","steward_green_midBtn_down.png"
	local btnLb,btnCallId = nil,2
	local gotoLbScale = 0.83
	if self.expStarts >= expeditionCfg.acount then --and self.expResetNum > 0 then
		descStr = getlocal("steward_tabTwo_resetDesc",{self.expResetNum})
		btnLb 	= getlocal("dailyTaskReset")
		btnCallId = 1
		-- gotoLbScale = 0.6
		if self.expResetNum == 0 then
			btnPic1,btnPic2 = "yh_nbSkillGoto.png","yh_nbSkillGoto_Down.png"
			btnCallId,btnLb = 2,nil
		end
	else
		descStr = getlocal("steward_tabTwo_expStartsNotEnought")
		btnPic1,btnPic2 = "yh_nbSkillGoto.png","yh_nbSkillGoto_Down.png"
		btnLb = nil
		gotoLbScale = 0.95
	end
	if descStr then
		local useValue = whiId == 1 and self.slNeedVipLevel or ""
		local strSize1 = 20
		if G_isAsia() == false then
			strSize1 = 16
		end
		local sizeWidth = pWidth * 0.7
		if G_getCurChoseLanguage() == "ar" then
			sizeWidth = pWidth * 0.4
		end
		descLb = GetTTFLabelWrap(descStr,strSize1,CCSizeMake(sizeWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
		descLb:setAnchorPoint(ccp(0,0))
		descLb:setPosition(descPos)
		parent:addChild(descLb,1)
		if useBlack then
			descLb:setColor(G_ColorGray)
		end
	end

	local function gotoCallback(tag,obj)
		print("tag===inExp>>>",tag,self.expResetNum)
		if tag == 2 then--eb
			if self.parent and self.parent.closeDialog then
	    		self.parent:closeDialog()
	    	end
	    	-- print('self.layerNum========>>>>>',self.layerNum)
			G_goToDialog2("eb",4,true)
		elseif tag == 1 then--重置 有问题！！！！！！！！！！！！
        	local acount = expeditionVoApi:getAcount() or 0
			if expeditionVoApi:getWin() == false and acount >= expeditionCfg.acount then
	            G_showTipsDialog(getlocal("expedition_reset_notip"))
	            do return end
	        end
			local function onConfirm(flag)
	           	local function callback(fn,data)
	                local ret,sData=base:checkServerData(data)
	                if ret==true then
	                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionRestartSuccess"),30)
	                    self:refreshSelf()
	                end
	            end
	           socketHelper:expeditionReset(callback,flag or 0)
	        end

	        if expeditionVoApi:getFailNum() >= (expeditionVoApi:getFailTimeCfg()-1)  and expeditionVoApi:getWin() == false then
	            local contentStr = getlocal("expeditionHaveTroopsSure")
	            if expeditionVoApi:isAllReward() == false then
	                contentStr = getlocal("expeditionNoRewardSure")
	            end
	            G_showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),contentStr,true,nil,onConfirm,nil,nil,nil,nil,nil,nil,nil,nil,getlocal("expeditionFailGradeCheck"),getlocal("expeditionFailGradeSure",{expeditionVoApi:getFailTimeCfg(),expeditionVoApi:getGradeDown()}))
	            do return end
	        end

	        if expeditionVoApi:isAllReward()==false  then
	        	local secondDialog = G_showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),getlocal("expeditionNoRewardSure"),nil,onConfirm)
	            do return end
	        end

	        if expeditionVoApi:isHaveLeftTanks() and expeditionVoApi:getWin()==false then
	        	local secondDialog = G_showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),getlocal("expeditionHaveTroopsSure"),nil,onConfirm)
	            do return end

	        end
	        local secondDialog = G_showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),getlocal("expeditionRestart"),nil,onConfirm)
		end
	end

	local strSize2 = 20
	if G_isAsia() == false then
		strSize2 = 18
	end

	local gotoItem = GetButtonItem(btnPic1,btnPic2,btnPic1,gotoCallback,btnCallId,btnLb,strSize2)
    gotoItem:setAnchorPoint(ccp(1,0.5))
    gotoItem:setScale(gotoLbScale)
    gotoMenu = CCMenu:createWithItem(gotoItem)
    gotoMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    gotoMenu:setPosition(pWidth - 15,pHeight * 0.5)
    parent:addChild(gotoMenu,1)

	if descLb and (self.expStarts < 3 or self.expResetNum == 0) then
		descLb:setColor(G_ColorGray)
	end
	-- if self.expStarts >= 3 and self.expResetNum == 0 then
	-- 	gotoItem:setEnabled(false)
	-- end	
	
end
function stewardTabTwo:addSwTipCell(swIsCan,parent,descPos,pWidth,pHeight,useBlack)
	-- print("superWeaponVoApi:getRaidLeftTime()=======>>>>>",superWeaponVoApi:getRaidLeftTime())
	local btnSc = 0.6
	if superWeaponVoApi:getRaidLeftTime() > 0 then -- 扫荡范围内
		local curFloor,leftFloor=superWeaponVoApi:getRaidFloor()
		self.swCurFloor = curFloor

		local strSize1 = 20
		if G_isAsia() == false then
			strSize1 = 16
		end
		-- local sizeWidth = G_VisibleSizeWidth-200
		-- if G_getCurChoseLanguage() == "ar" then
		-- 	sizeWidth = G_VisibleSizeWidth-300
		-- end
		self.swCurFloorLb=GetTTFLabelWrap(getlocal("sw_raid_current_floor",{curFloor}),strSize1,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentBottom)
        self.swCurFloorLb:setAnchorPoint(ccp(1,1))
        self.swCurFloorLb:setPosition(pWidth - 15,pHeight - 10)
        parent:addChild(self.swCurFloorLb,1)

		local function speedUpHandler()
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local leftTime=superWeaponVoApi:getRaidLeftTime()
            -- print("superWeaponVoApi:getRaidFloor()---->>>>",superWeaponVoApi:getRaidFloor())
           	if leftTime>0 then
                local speedUpGems=superWeaponVoApi:raidSpeedUpCost(leftTime)
                if(speedUpGems>playerVoApi:getGems())then
                    GemsNotEnoughDialog(nil,nil,speedUpGems - playerVoApi:getGems(),self.layerNum+1,speedUpGems)
                    do return end
                end
                local function finishCallback() end
                local function onConfirm()
                    superWeaponVoApi:raidChallengeFinish(true,finishCallback)
                end
                local secondDialog = G_showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),getlocal("super_weapon_challenge_speed_up_desc",{speedUpGems}),nil,onConfirm)
            end
        end

        local strSize2 = 24/0.8
		if G_isAsia() == false then
			strSize2 = 20/0.8
		end
        local speedUpBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",speedUpHandler,11,getlocal("gemCompleted"),strSize2)
        speedUpBtn:setScale(btnSc)
        speedUpBtn:setAnchorPoint(ccp(1,0))
        local menuSpeedUp=CCMenu:createWithItem(speedUpBtn)
        menuSpeedUp:setPosition(ccp(pWidth -15,5))
        menuSpeedUp:setTouchPriority(-(self.layerNum-1)*20-4)
        parent:addChild(menuSpeedUp,3)

        local leftTime=superWeaponVoApi:getRaidLeftTime()

	else--重置范围内
		local cVo  = superWeaponVoApi:getSWChallenge()
		local resetNum=superWeaponVoApi:getLeftResetNum()
		-- local free = self:swIsFree(cVo2)

		local function resetHandler( ... )
	        if G_checkClickEnable()==false then
	            do return end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)
	        local leftTime=superWeaponVoApi:getRaidLeftTime()
	        if leftTime>0 then
	            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_challenge_can_not_reset_tip_1"),30)
	            do return end
	        end

	        local function resetChallengeCallback()
	            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionRestartSuccess"),30)
	            self:refreshSelf()
	        end
	        local free
	        local cVo2=superWeaponVoApi:getSWChallenge()
	        local lastRestTime1=cVo2.lastRestTime
	        local tipDesc = ""
	        if G_isToday(lastRestTime1)==false then
	            free=true
	            tipDesc = getlocal("super_weapon_challenge_reset_desc")
	        else
	        	if superWeaponVoApi:getLeftResetNum() <= 0 then
	            	if self.parent and self.parent.closeDialog then
			    		self.parent:closeDialog()
			    	end
					G_goToDialog2("weapon",self.layerNum +1,true,nil,"challenge")
					do return end
	            end
	            local resetCost=superWeaponVoApi:getResetCost()
	            if(resetCost>playerVoApi:getGems())then
	                GemsNotEnoughDialog(nil,nil,resetCost - playerVoApi:getGems(),self.layerNum+1,resetCost)
	                do return end
	            end	            

	            tipDesc = getlocal("super_weapon_challenge_reset_desc2",{resetCost})
	            free=false
	        end
	        local function onConfirm()
	            superWeaponVoApi:resetChallenge(free,resetChallengeCallback)
	        end

	        local secondDialog = G_showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),tipDesc,nil,onConfirm)
	    end

	    local btnName1,btnName2 = "steward_green_midBtn.png","steward_green_midBtn_down.png"
	    local btnLb = getlocal("dailyTaskReset")
	    if resetNum <= 0 then
	    	btnName1,btnName2 = "yh_nbSkillGoto.png","yh_nbSkillGoto_Down.png"
	    	btnLb = ""
	    end
	    local strSize2 = 24
		if G_isAsia() == false then
			strSize2 = 20
		end
	    local resetBtn=GetButtonItem(btnName1,btnName2,btnName1,resetHandler,1,btnLb,strSize2,101)
	    resetBtn:setAnchorPoint(ccp(1,0.5))

	    -- local btnLb = resetBtn:getChildByTag(101)
	    local menuReset=CCMenu:createWithItem(resetBtn)
	    menuReset:setPosition(ccp(pWidth -15,pHeight * 0.5))
	    menuReset:setTouchPriority(-(self.layerNum-1)*20-4)
	    parent:addChild(menuReset,1)
	    resetBtn2=GetButtonItem("steward_green_midBtn.png","steward_green_midBtn_down.png","steward_green_midBtn.png",resetHandler,1,getlocal("dailyTaskReset"),24,101)
	    resetBtn2:setAnchorPoint(ccp(1,0.5))
	    -- local btnLb = resetBtn2:getChildByTag(101)
	    local menuReset2=CCMenu:createWithItem(resetBtn2)
	    menuReset2:setPosition(ccp(pWidth -15,pHeight * 0.5))
	    menuReset2:setTouchPriority(-(self.layerNum-1)*20-4)
	    parent:addChild(menuReset2,1)

	    resetBtn:setScale(0.83)
	    resetBtn2:setScale(0.83)

	    local lastRestTime=cVo.lastRestTime
	    -- print("lastRestTime---->>>>>>",lastRestTime,G_isToday(lastRestTime))
	    if G_isToday(lastRestTime)==false then
	        resetBtn:setVisible(false)
	        resetBtn:setEnabled(false)
	        resetBtn2:setVisible(true)
	        resetBtn2:setEnabled(true)
	    else
	        resetBtn:setVisible(true)
	        resetBtn2:setVisible(false)
	        resetBtn2:setEnabled(false)
	        -- showResetGems()
	        -- if resetNum<=0 then
	        --     resetBtn:setEnabled(false)
	        -- else
	            resetBtn:setEnabled(true)
	        -- end
	        if resetNum <= 0 then
		    	resetBtn:setScale(0.95)
		    end
	    end
	end
	local strSize1 = 20
	if G_isAsia() == false then
		strSize1 = 16
	end
	local sizeWidth = pWidth * 0.7
	if G_getCurChoseLanguage() == "ar" then
			sizeWidth = pWidth * 0.4
	end
	descStr = GetTTFLabelWrap(getlocal("steward_tabTwo_resetDesc",{self.swResetNum}),strSize1,CCSizeMake(sizeWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
	descStr:setPosition(descPos)
	descStr:setAnchorPoint(ccp(0,0))
	parent:addChild(descStr,1)
	if useBlack then
		descStr:setColor(G_ColorGray)
	end
	if self.swResetNum == 0 then
		descStr:setColor(G_ColorGray)
	end
end
function stewardTabTwo:refreshSelf()
	if self.tv then
		self:initEveryModuldData()
		self:BtnCanUse()
		self.tv:reloadData()
		if self.parent and self.parent.checkRedPoint then
	    	self.parent:checkRedPoint(2)
	    end
	end
end
return stewardTabTwo