acVipActionDialog=commonDialog:new()

function acVipActionDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.layerNum=layerNum

    self.selectedTabIndex=0
    self.cellHeight=nil

    self.awardTv = nil
    self.dayCostDesLabel = nil -- “您今日充值了：”
    self.dayCostLabel = nil   -- 今日充值金额
    self.totalCostDesLabel = nil  -- “您累计充值了：”
    self.totalCostLabel = nil -- 累计充值金额
	return nc
end

function acVipActionDialog:initTab(tabTb)
   local tabBtn=CCMenu:create()
   local tabIndex=0
   local tabBtnItem;
   if tabTb~=nil then
       for k,v in pairs(tabTb) do

           tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
           
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))
           tabBtnItem:setScaleY(1.4)
           --tabBtnItem:setScaleX(1.5)
           local function tabClick(idx)
               return self:tabClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabClick)
           
           local lb=GetTTFLabelWrap(v,20,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
           lb:setScaleY(1/1.4)
           --lb:setScaleX(1/1.5)
		   lb:setTag(31)
           if k~=1 then
              lb:setColor(G_TabLBColorGreen)
           end
			
           self.allTabs[k]=tabBtnItem
           tabBtn:addChild(tabBtnItem)
           tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
           tabBtnItem:setTag(tabIndex)
           tabIndex=tabIndex+1
       end
   end
   tabBtn:setPosition(0,0)
   self.bgLayer:addChild(tabBtn,6)

end
function acVipActionDialog:resetTab()
	self.allTabs={getlocal("activity_vipAction_tab1"),getlocal("activity_vipAction_tab2")}
    self:initTab(self.allTabs)
    local index=0
    for k,v in pairs(self.allTabs) do
         local tabBtnItem=v
         local tabBtnHeight=G_VisibleSizeHeight/2-tabBtnItem:getContentSize().height/2+40
         if index==0 then
            tabBtnItem:setPosition(100,tabBtnHeight)
         elseif index==1 then
            tabBtnItem:setPosition(248,tabBtnHeight)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

function acVipActionDialog:initTableView()
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSize.height-105))
	self.panelLineBg:setAnchorPoint(ccp(0,0))
	self.panelLineBg:setPosition(ccp(15,15))


	local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	girlDescBg:setContentSize(CCSizeMake(410,200))
	girlDescBg:setAnchorPoint(ccp(0,0))
	girlDescBg:setPosition(ccp(180,G_VisibleSizeHeight/2+70))
	self.bgLayer:addChild(girlDescBg,1)

	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(410,200-20),nil)
	girlDescBg:addChild(self.tv)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(0,10))
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setMaxDisToBottomOrTop(60)
	
    self:initBg()
    self:resetTab()

	local function callBackAwardArea(...)
        return self:eventHandlerForAwardArea(...)
    end
    hd= LuaEventHandler:createHandler(callBackAwardArea)

    self.awardTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight/2 - 170),nil)
	self.bgLayer:addChild(self.awardTv)
	self.awardTv:setAnchorPoint(ccp(0,0))
	self.awardTv:setPosition(ccp(20,105))
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.awardTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.awardTv:setMaxDisToBottomOrTop(10)
end

-- 面板上部分活动时间、说明按钮以及美女图片
function acVipActionDialog:initBg()
	local timeTime=GetTTFLabelWrap(getlocal("activity_timeLabel"),25,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeTime:setAnchorPoint(ccp(0.5,0.5))
	timeTime:setColor(G_ColorYellowPro)
	timeTime:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-115))
	self.bgLayer:addChild(timeTime)

	local timeLb=GetTTFLabelWrap(acVipActionVoApi:getTimeStr(),25,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeLb:setAnchorPoint(ccp(0.5,0.5))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
	self.bgLayer:addChild(timeLb)
	local acVo = acVipActionVoApi:getAcVo()
    self.timeLb=timeLb
    G_updateActiveTime(acVo,self.timeLb)
	
	local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
	girlImg:setScale((G_VisibleSizeHeight/2-85)/girlImg:getContentSize().height*0.6)
	girlImg:setAnchorPoint(ccp(0,0))
	girlImg:setPosition(ccp(20,G_VisibleSizeHeight/2+50))
	self.bgLayer:addChild(girlImg,2)

    local function showInfo()
        local tabStr={" ",getlocal("activity_vipAction_desc3")," ",getlocal("activity_vipAction_tab2")," ",getlocal("activity_vipAction_desc2"),getlocal("activity_vipAction_desc1")," ",getlocal("activity_vipAction_tab1")," "}
        local tabColor = {nil,nil,nil,G_ColorYellow,nil,nil,nil,nil,G_ColorYellow,nil}
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,G_VisibleSizeHeight-140));
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn)
    
    local function gotoCharge(tag,object)
	    if G_checkClickEnable()==false then
	      do
	        return
	      end
	    end
	    activityAndNoteDialog:closeAllDialog()
	    vipVoApi:showRechargeDialog(self.layerNum+1)
	end

    local rechargeBtn =GetButtonItem("BtnRecharge.png","BtnRecharge.png","BtnRecharge.png",gotoCharge,nil,getlocal("recharge"),28)
    local rechargeMenu=CCMenu:createWithItem(rechargeBtn)
    rechargeMenu:setPosition(ccp(G_VisibleSizeWidth/2,60))
    rechargeMenu:setTouchPriority(-(self.layerNum-1)*20-8)
    self.bgLayer:addChild(rechargeMenu)
    
    
    
    local background=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function () end)
	background:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,50))
	background:setAnchorPoint(ccp(0.5,0.5))
	background:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 40))
	self.bgLayer:addChild(background,5)
    
    local posX = 20
    local posY = 25
    self.dayCostDesLabel=GetTTFLabel(getlocal("activity_vipAction_dayCost"),25)
	self.dayCostDesLabel:setAnchorPoint(ccp(0,0.5))
	self.dayCostDesLabel:setPosition(ccp(posX, posY))
	background:addChild(self.dayCostDesLabel)
	self.dayCostDesLabel:setVisible(false)

	self.totalCostDesLabel=GetTTFLabel(getlocal("activity_userFund_total"),25)
	self.totalCostDesLabel:setAnchorPoint(ccp(0,0.5))
	self.totalCostDesLabel:setPosition(ccp(posX, posY))
	background:addChild(self.totalCostDesLabel)
	self.totalCostDesLabel:setVisible(false)


	self.dayCostLabel=GetTTFLabel(acVipActionVoApi:getTodayCharge(),25)
	self.dayCostLabel:setAnchorPoint(ccp(0,0.5))
	self.dayCostLabel:setPosition(ccp(posX + self.dayCostDesLabel:getContentSize().width+10, posY))
	background:addChild(self.dayCostLabel)
	self.dayCostLabel:setColor(G_ColorYellowPro)
	self.dayCostLabel:setVisible(false)

	self.totalCostLabel=GetTTFLabel(acVipActionVoApi:getTotalCharge(),25)
	self.totalCostLabel:setAnchorPoint(ccp(0,0.5))
	self.totalCostLabel:setPosition(ccp(posX+ self.totalCostDesLabel:getContentSize().width+10, posY))
	background:addChild(self.totalCostLabel)
	self.totalCostLabel:setColor(G_ColorYellowPro)
	self.totalCostLabel:setVisible(false)

	self.goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.goldIcon:setAnchorPoint(ccp(0,0.5))
	self.goldIcon:setPosition(posX ,posY)
	background:addChild(self.goldIcon)
    
    self:updateCostLabel()
end

function acVipActionDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		if self.cellHeight==nil then
			local spScale=((G_VisibleSizeHeight/2-85)/262*0.6)
			local descLb=GetTTFLabelWrap(getlocal("activity_vipAction_desc"),22,CCSizeMake(260*1/spScale,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			self.cellHeight=descLb:getContentSize().height
		end
		if self.cellHeight<200-20 then
			self.cellHeight=200-20
		end
		tmpSize=CCSizeMake(410,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local spScale=((G_VisibleSizeHeight/2-85)/262*0.6)
		local descLb=GetTTFLabelWrap(getlocal("activity_vipAction_desc"),22,CCSizeMake(260*1/spScale,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		if self.cellHeight==nil then
			self.cellHeight=descLb:getContentSize().height
		end
		if self.cellHeight<200-20 then
			self.cellHeight=200-20
		end
		descLb:setPosition(ccp(100*spScale+140,self.cellHeight/2))
		cell:addChild(descLb)

		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function acVipActionDialog:eventHandlerForAwardArea(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local dayRewardCfg = acVipActionVoApi:getDayRewardCfg()
	    local dayCfg = acVipActionVoApi:getDayCfg()
	    local totalRewardCfg = acVipActionVoApi:getTotalRewardCfg()
	    local totalCfg = acVipActionVoApi:getTotalCfg()

        if dayRewardCfg == nil or dayCfg == nil or totalRewardCfg == nil  or totalCfg == nil then
			return 1
		end
		
		if self.selectedTabIndex == 0 then
		    return SizeOfTable(dayCfg)
		elseif self.selectedTabIndex == 1 then
		    return SizeOfTable(totalCfg)
		end
		return 1
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		local w = G_VisibleSizeWidth-40

		local dayRewardCfg = acVipActionVoApi:getDayRewardCfg()
	    local dayCfg = acVipActionVoApi:getDayCfg()
	    local totalRewardCfg = acVipActionVoApi:getTotalRewardCfg()
	    local totalCfg = acVipActionVoApi:getTotalCfg()

        if dayRewardCfg == nil or dayCfg == nil or totalRewardCfg == nil  or totalCfg == nil then
           tmpSize = CCSizeMake(w, 200+20)
        else
        	if self.selectedTabIndex == 0 then  
			    tmpSize=CCSizeMake(w, SizeOfTable(FormatItem(dayRewardCfg[idx + 1])) * 150 + 50+20)
			elseif self.selectedTabIndex == 1 then
			    tmpSize=CCSizeMake(w, SizeOfTable(FormatItem(totalRewardCfg[idx + 1])) * 150 + 50+20)
			end
		end
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
        
        local cellW = G_VisibleSizeWidth-40
        local cellSingleH = 150
        local titleH = 50+10
        local cellH = 0
        
        local dayRewardCfg = acVipActionVoApi:getDayRewardCfg()
	    local dayCfg = acVipActionVoApi:getDayCfg()
	    local totalRewardCfg = acVipActionVoApi:getTotalRewardCfg()
	    local totalCfg = acVipActionVoApi:getTotalCfg()

        if dayRewardCfg == nil or dayCfg == nil or totalRewardCfg == nil  or totalCfg == nil then
        	return cell
        end
        local singleAward
        local singleCost
        local formatAward
        local titleLabel = ""
        local isDay
		if self.selectedTabIndex == 0 then  
		    singleAward = dayRewardCfg[idx + 1] 
		    singleCost = dayCfg[idx + 1] 
        	titleLabel = getlocal("activity_vipAction_tab1")
        	isDay = true
		elseif self.selectedTabIndex == 1 then
			singleAward = totalRewardCfg[idx + 1]
			singleCost = totalCfg[idx + 1] 
        	titleLabel = getlocal("activity_vipAction_tab2")
        	isDay = false
		end
        if singleAward == nil then
        	singleAward = {}
        end

        formatAward = FormatItem(singleAward)
		cellH = SizeOfTable(formatAward) * cellSingleH + titleH + 10

        local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
		background:setContentSize(CCSizeMake(cellW,cellH))
		background:setAnchorPoint(ccp(0.5,0.5))
		background:setPosition(ccp(cellW/2,cellH/2))
		cell:addChild(background)

        local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function () end)
		titleBg:setContentSize(CCSizeMake(cellW,titleH))
		titleBg:setAnchorPoint(ccp(0.5,1))
		titleBg:setPosition(ccp(cellW / 2, cellH-5))
		cell:addChild(titleBg)
        
        local leftW = 20 -- 标题左侧文字空隙
		local rewardDesc=GetTTFLabel(titleLabel,25)

		rewardDesc:setAnchorPoint(ccp(0,0.5))
		rewardDesc:setPosition(ccp(leftW,titleBg:getContentSize().height/2))
		titleBg:addChild(rewardDesc)
		rewardDesc:setColor(G_ColorGreen)
        
        leftW = leftW + rewardDesc:getContentSize().width + 10
        -- 需要的金币金额
		local numLb=GetTTFLabel(tostring(singleCost),25)
		numLb:setAnchorPoint(ccp(0,0.5))
		numLb:setPosition(ccp(leftW,titleBg:getContentSize().height/2))
		titleBg:addChild(numLb)
		numLb:setColor(G_ColorYellowPro)
 
        leftW = leftW + numLb:getContentSize().width + 10
		local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
		goldIcon:setAnchorPoint(ccp(0,0.5))
		goldIcon:setPosition(leftW ,titleBg:getContentSize().height/2) -- todo
		titleBg:addChild(goldIcon)

        local index = 0
        local maxIndex = SizeOfTable(formatAward)
        local pic
        local chestIcon
        local name
        local nameLabel
        local num
        local desc
        local chestDesc
		for k,v in pairs(formatAward) do
			pic = v.pic
			if pic ~= nil then
                -- chestIcon=CCSprite:createWithSpriteFrameName(pic)
                chestIcon = G_getItemIcon(v,100,true,self.layerNum)
				chestIcon:setAnchorPoint(ccp(0,0.5))
				chestIcon:setPosition(20,cellSingleH * index + cellSingleH/2)
				chestIcon:setTouchPriority(-(self.layerNum-1)*20-10)
				cell:addChild(chestIcon)
			end
            name = v.name
            num = v.num
            if name ~= nil and num ~= nil then
                nameLabel=GetTTFLabelWrap(name .. " x" .. v.num,25,CCSizeMake(450, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				nameLabel:setAnchorPoint(ccp(0,0.5))
				nameLabel:setPosition(ccp(130,cellSingleH * (index + 1) - 30))
				cell:addChild(nameLabel)
				nameLabel:setColor(G_ColorGreen)
            end

			desc = v.desc
			if desc ~= nil then
				chestDesc=GetTTFLabelWrap(getlocal(desc),22,CCSizeMake(340, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				chestDesc:setAnchorPoint(ccp(0,0.5))
				chestDesc:setPosition(ccp(130,cellSingleH * index + cellSingleH/2 - 10))
				cell:addChild(chestDesc)
			end

            -- local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
            -- lineSprite:setScaleX((cellW + 30)/lineSprite:getContentSize().width)
            -- lineSprite:setPosition(ccp((cellW + 30)/2 + 30,cellSingleH * index))
            -- cell:addChild(lineSprite,5)
			index = index + 1
		end
        
        

        local state = acVipActionVoApi:getRewardState(singleCost, isDay, idx + 1) -- 领奖状态
        local getStr
        if state == 2 then
        	if isDay == true then
               getStr = getlocal("activity_vipAction_hadDay")
        	elseif isDay == false then
               getStr = getlocal("activity_vipAction_had")
        	end
        	
            local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
            rightIcon:setAnchorPoint(ccp(0.5,0.5))
            rightIcon:setPosition(ccp(cellW - rightIcon:getContentSize().width/2 - 10, cellSingleH/2))
            cell:addChild(rightIcon,1)
        else
        	getStr = getlocal("activity_vipAction_get")
            -- 领取按钮逻辑
			local function onGetReward(tag,object)
				if state == 1 then
					local function rewardCallback(fn,data)
				        local ret,sData=base:checkServerData(data)
			    	    if ret==true then
						    if self==nil or self.awardTv==nil then
					            do return end
					        end						     
					        for k,v in pairs(formatAward) do
					            G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
					        end
					        G_showRewardTip(formatAward,true)

					        acVipActionVoApi:afterGetReward(isDay, idx + 1)
					          
					          -- 刷新tv后tv仍然停留在当前位置
					        local recordPoint = self.awardTv:getRecordPoint()
					        self.awardTv:reloadData()
					        self.awardTv:recoverToRecordPoint(recordPoint)

				        end
					end
					local total
					if isDay == true then
						total = 0
					elseif isDay == false then
						total = 1
					end
					if total ~= nil then
						socketHelper:getVipActionReward(total,idx + 1, rewardCallback)
					end
				else
                    -- 领取奖励按钮不可以点击
				end
			end
			
			local rewardMenuItem=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",onGetReward,idx,nil,0)
			rewardMenuItem:setAnchorPoint(ccp(0.5,0.5))
			if state == 1 then
				rewardMenuItem:setEnabled(true) 
			elseif state == 0 then
				rewardMenuItem:setEnabled(false)
		    end

			local rewardMenuBtn=CCMenu:createWithItem(rewardMenuItem)
			rewardMenuBtn:setAnchorPoint(ccp(0.5,0))
			rewardMenuBtn:setPosition(ccp(cellW - rewardMenuItem:getContentSize().width/2 - 10,rewardMenuItem:getContentSize().height/2 + 10))
			rewardMenuBtn:setTouchPriority(-(self.layerNum-1)*20-4)
			cell:addChild(rewardMenuBtn) 	
        end

        local canGetDes=GetTTFLabelWrap(getStr,25,CCSizeMake(125,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
		canGetDes:setAnchorPoint(ccp(1,0.5))
		canGetDes:setPosition(ccp(titleBg:getContentSize().width - 10,titleBg:getContentSize().height/2))
		titleBg:addChild(canGetDes)

			


		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function acVipActionDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_ColorWhite)
         else
            v:setEnabled(true)
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_TabLBColorGreen)
         end
    end  
    if self.awardTv ~= nil then
    	self.awardTv:reloadData()
    end
    self:updateCostLabel()
end

function acVipActionDialog:updateCostLabel()
    local posX = 20
    local posY = 25
	if self.selectedTabIndex == 0 then
		self.dayCostDesLabel:setVisible(true)
		self.dayCostLabel:setVisible(true)
		self.dayCostLabel:setString(tostring(acVipActionVoApi:getTodayCharge()))
		self.totalCostDesLabel:setVisible(false)
		self.totalCostLabel:setVisible(false)
		self.goldIcon:setPosition(posX + self.dayCostDesLabel:getContentSize().width +  self.dayCostLabel:getContentSize().width+20, posY)
	elseif self.selectedTabIndex == 1 then
        self.dayCostDesLabel:setVisible(false)
		self.dayCostLabel:setVisible(false)
		self.totalCostDesLabel:setVisible(true)
		self.totalCostLabel:setVisible(true)
		self.totalCostLabel:setString(tostring(acVipActionVoApi:getTotalCharge()))
		self.goldIcon:setPosition(posX + self.totalCostDesLabel:getContentSize().width +  self.totalCostLabel:getContentSize().width+20, posY)
	end
end

function acVipActionDialog:update()
  local acVo = acVipActionVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    elseif self ~= nil and self.awardTv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      local recordPoint = self.awardTv:getRecordPoint()
      self.awardTv:reloadData()
      self.awardTv:recoverToRecordPoint(recordPoint)
      self:updateCostLabel()
    end
  end
end

function acVipActionDialog:tick()
	if self.timeLb then
        local acVo = acVipActionVoApi:getAcVo()
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acVipActionDialog:dispose()
	self.dayCostDesLabel = nil -- “您今日充值了：”
    self.dayCostLabel = nil   -- 今日充值金额
    self.totalCostDesLabel = nil  -- “您累计充值了：”
    self.totalCostLabel = nil -- 累计充值金额
	self.awardTv = nil
	self.cellHeight=nil
end