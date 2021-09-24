acKafkaGiftDialog=commonDialog:new()

function acKafkaGiftDialog:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/heroRecruitImage.plist")

    self.totalMoneyLabel = nil
    self.goldIcon = nil
    self.moneyX = nil
    self.rewardBtn = nil
    self.awardCellIconTB={}
    self.awardIdxInCellTB={}
    self.isToday = nil
    self.adaH = 0
    if G_getIphoneType() == G_iphoneX then
      self.adaH = 1250 - 1136
    end
	return nc
end

function acKafkaGiftDialog:initTableView( )
  self.isToday = acKafkaGiftVoApi:isToday()

	local function callBack( ... )
		return self:eventHandler(...)
	end 
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 395 - self.adaH))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 100+self.adaH))
 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 460-self.adaH),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(10,110+self.adaH))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)

  local awardCells = acKafkaGiftVoApi:getAwardCells( )
  if awardCells ~= nil and awardCells>0 then
    if 120 * awardCells + 20 > G_VisibleSizeHeight - 460 then
      local recordPoint = self.tv:getRecordPoint()
      recordPoint.y = 0
      self.tv:recoverToRecordPoint(recordPoint)
    end
  end 
end

function acKafkaGiftDialog:eventHandler( handler,fn,idx,cel )
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    local awardCells = acKafkaGiftVoApi:getAwardCells( )
    if awardCells ~= nil and awardCells >0 then
      return  CCSizeMake(G_VisibleSizeWidth - 20,120 * awardCells + 20)
    end
    return  CCSizeMake(G_VisibleSizeWidth - 20,120)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()	

    local rewardLabelH = 20
    local rewardBtnH = 0
    local barH = 120

    local totalH  -- 总高度

    local awardCells = acKafkaGiftVoApi:getAwardCells( )
    if awardCells ~= nil and awardCells >0 then
      totalH = barH * awardCells
    else
      totalH = barH
    end

    local totalW = G_VisibleSizeWidth - 20
    local leftW = totalW * 0.3
    local rightW = totalW * 0.7    

    local rechargedAllGold = acKafkaGiftVoApi:getRechargedGold( )
    local per = 0
    local perWidth = 0
    local addContinue = true

    local function chooseAnyLargeAward( object,fn,tag )
        if G_checkClickEnable()==false then
              do
                  return
              end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
       local listIdx = SizeOfTable(acKafkaGiftVoApi:getAwardList())
       local idx = tag
       
       acKafkaGiftVoApi:setBigAwardCellIdx(idx)
       local awardCells = acKafkaGiftVoApi:getAwardCells( )
       local hadReward = acKafkaGiftVoApi:checkIfHadAwardById(awardCells-idx+1)
       if hadReward ==false then
         local function needRefresh(  )
              local awardCell = acKafkaGiftVoApi:getBigAwardCellIdx()
              local awardIdx = acKafkaGiftVoApi:getBigAwardInIdx()
              local award = FormatItem(acKafkaGiftVoApi:getRewardR2ById(awardCells-awardCell+1),true,true)
              -- print("~~~~~~~~~",awardCell,awardIdx)
              -- G_dayin(acKafkaGiftVoApi:getRewardR2ById(awardCell))
              -- print("~~~~~~~~~")
              self.awardIdxInCellTB[awardCell]=awardIdx
              if acKafkaGiftVoApi:getSureToAward() then
                self.awardCellIconTB[awardCell]=award[awardIdx]
                acKafkaGiftVoApi:setSureToAward(false)
                self.tv:reloadData()
              end
              acKafkaGiftVoApi:setBigAwardInIdx(nil)
         end 
         local td = acKafkaGiftSmallDialog:new(awardCells-idx+1)
         local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(480,500),getlocal("activity_customLottery_RewardRecode"),needRefresh)
         dialog:setTag(667)
         sceneGame:addChild(dialog,self.layerNum+1)      
       end
    end

    self:frushBigAwardList()

    if awardCells and awardCells>0 then
    	for i=1,awardCells do
    		local h = barH*(awardCells -i)+rewardBtnH --每条奖励信息的y坐标起始位置
        local largeAwardIcon 
    		local award = FormatItem(acKafkaGiftVoApi:getRewardR1ById(awardCells-i+1),true)
        local freshIcon=nil
        local  awardFlagOn = acKafkaGiftVoApi:getAwardFlagList( )
        if (awardFlagOn[awardCells-i+1] ==0 or awardFlagOn[awardCells-i+1] ==nil) and acKafkaGiftVoApi:checkIfHadAwardById(awardCells-i+1) ==false then
          -- if acKafkaGiftVoApi:checkIfHadAwardById(awardCells-i+1) ==false then
            freshIcon = CCSprite:createWithSpriteFrameName("freshIcon.png")
            freshIcon:setAnchorPoint(ccp(1,1))
        end

        if self.awardCellIconTB[i] then
            largeAwardIcon = acKafkaGiftVoApi:getItemIcon(self.awardCellIconTB[i],100,true,self.layerNum,chooseAnyLargeAward)
            local locaAward,awardNums = acKafkaGiftVoApi:getRewardR2ById(awardCells-i+1)
            local iconScaleX=1
            local iconScaleY=1                
            if largeAwardIcon:getContentSize().width>100 then
              iconScaleX=0.78*100/150
              iconScaleY=0.78*100/150
            else
              iconScaleX=0.78
              iconScaleY=0.78
            end
            local numLabel=GetTTFLabel("x"..awardNums[i],21)
            numLabel:setAnchorPoint(ccp(0,0))
            numLabel:setPosition(8,8)
            largeAwardIcon:addChild(numLabel,1)
            numLabel:setScaleX(1/iconScaleX)
            numLabel:setScaleY(1/iconScaleY)

            if freshIcon then
              freshIcon:setScale(1.5)
              freshIcon:setPosition(ccp(largeAwardIcon:getContentSize().width,largeAwardIcon:getContentSize().height))
              largeAwardIcon:addChild(freshIcon)
            end
        else
            largeAwardIcon = LuaCCSprite:createWithSpriteFrameName("unKnowIcon.png",chooseAnyLargeAward)
            if freshIcon then
              freshIcon:setPosition(ccp(largeAwardIcon:getContentSize().width,largeAwardIcon:getContentSize().height))
              largeAwardIcon:addChild(freshIcon)
            end
            -- local freshIcon = CCSprite:createWithSpriteFrameName("freshIcon.png")
            -- freshIcon:setAnchorPoint(ccp(1,1))
            -- freshIcon:setPosition(ccp(largeAwardIcon:getContentSize().width,largeAwardIcon:getContentSize().height))
            -- largeAwardIcon:addChild(freshIcon)
        end


        largeAwardIcon:ignoreAnchorPointForPosition(false)
        largeAwardIcon:setAnchorPoint(ccp(0,0.5))
        largeAwardIcon:setPosition(ccp(leftW-20,h+barH/2))
        largeAwardIcon:setIsSallow(false)
        largeAwardIcon:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(largeAwardIcon,1)
        largeAwardIcon:setTag(i)          



    		if award and SizeOfTable(award)>0 then
    			for k,v in pairs(award) do
	    				local icon,iconScale = G_getItemIcon(v,100,true,self.layerNum)
		                icon:ignoreAnchorPointForPosition(false)
		                icon:setAnchorPoint(ccp(0,0.5))
		                icon:setPosition(ccp(90+(k-1)*110 + leftW ,h+barH/2))
		                icon:setIsSallow(false)
		                icon:setTouchPriority(-(self.layerNum-1)*20-2)
		                cell:addChild(icon,1)
		                icon:setTag(k)  

                if tostring(v.name)~=getlocal("honor") then
                  local numLabel=GetTTFLabel("x"..v.num,25)
                  numLabel:setAnchorPoint(ccp(1,0))
                  numLabel:setPosition(icon:getContentSize().width-10,0)
                  icon:addChild(numLabel,1)
                  numLabel:setScaleX(1/iconScale)
                  numLabel:setScaleY(1/iconScale)
                end
    			end
    		end

    		local canReward = acKafkaGiftVoApi:checkIfCanRewardById(awardCells-i+1)
    		if canReward ==true then
        			local hadReward = acKafkaGiftVoApi:checkIfHadAwardById(awardCells-i+1)
        			if hadReward ==true then
	                local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
	                rightIcon:setAnchorPoint(ccp(1,0.5))
	                rightIcon:setPosition(ccp(totalW - 10,h+barH/2))
	                cell:addChild(rightIcon,1)
	            else
                  local function rewardHandler(idx,object)
                    PlayEffect(audioCfg.mouseClick)
                    acKafkaGiftVoApi:setBigAwardCellIdx(idx-50)
                    local awardCell = acKafkaGiftVoApi:getBigAwardCellIdx()
                    local whiIdx = self.awardIdxInCellTB[awardCell]
                    local chooseFlag = acKafkaGiftVoApi:getChooseFlagList()
                    local awardChoseIdx = awardCells-awardCell+1
-- print("canReward~~~~~~1~~~~~~",awardChoseIdx,awardCell)
-- G_dayin(chooseFlag)
-- print("canReward~~~~~~2~~~~~~")
-- G_dayin(self.awardCellIconTB)
-- print("canReward~~~~~3~~~~~~\n")
                    if whiIdx and whiIdx>0 then
                      self:getReward(2,awardCells-(idx-50)+1,whiIdx,awardCells)
                    elseif chooseFlag[awardChoseIdx] ~=nil and chooseFlag[awardChoseIdx]>0  then
                      -- print("in here??????")
                      -- acKafkaGiftVoApi:setBigAwardCellIdx(awardCell)
                      local award = acKafkaGiftVoApi:getBigAwardCellIdx()
                      local awardIdx = chooseFlag[awardChoseIdx]
                      self:getReward(2,awardCells-(idx-50)+1,awardIdx,awardCells)

                      -- local award = FormatItem(acKafkaGiftVoApi:getRewardR2ById(awardCell),true,true)
                      --   self.awardCellIconTB[awardCells-i+1]=award[awardIdx]
                    else
                      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("awardNoChoose"),28)
                    end
                  end
                  local rewardBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",rewardHandler,0,getlocal("daily_scene_get"),28)
                  rewardBtn:setAnchorPoint(ccp(1,0.5))
                  rewardBtn:setScale(0.55)
                  local menuAward=CCMenu:createWithItem(rewardBtn)
                  menuAward:setPosition(ccp(totalW - 4,h+barH/2))
                  menuAward:setTouchPriority(-(self.layerNum-1)*20-4) 
                  cell:addChild(menuAward,1) 
                  rewardBtn:setTag(i+50)
	            end
        else
          local noRechargeSize = 24
          local strWidthSize = 28*5
          local strPosWidth = -5
          if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="tw" then
            noRechargeSize =28
            strWidthSize = 28*7
            strPosWidth=20
          elseif G_getCurChoseLanguage() =="ru" then
            noRechargeSize =21
          end
          local noLabel = GetTTFLabelWrap(getlocal("activity_totalRecharge_no"),noRechargeSize,CCSizeMake(strWidthSize,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
          noLabel:setAnchorPoint(ccp(1,0.5))
          noLabel:setPosition(ccp(totalW +10+strPosWidth,h+barH/2))
          cell:addChild(noLabel,1)
        end



		    -- self.rewardBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rewardHandler,0,getlocal("daily_scene_get"),28)
		    -- self.rewardBtn:setAnchorPoint(ccp(1,0.5))
		    -- self.rewardBtn:setScale(0.8)
		    -- local menuAward=CCMenu:createWithItem(self.rewardBtn)
		    -- menuAward:setPosition(ccp(totalW - 20,h+barH/2))
		    -- menuAward:setTouchPriority(-(self.layerNum-1)*20-4)
		    -- if acKafkaGiftVoApi:canReward() == true then
		    --   self.rewardBtn:setVisible(false)
		    --   self.rewardBtn:setEnabled(true)
		    -- else
		    --   self.rewardBtn:setEnabled(false)
		    --   self.rewardBtn:setVisible(false)
		    -- end  

		    -- cell:addChild(menuAward,1) 


            local needGolds = self:initNeedGolds(awardCells-i+1)
            needGolds:setAnchorPoint(ccp(1,0))
            needGolds:setPosition(ccp(leftW-40,h+barH - 30))	
            cell:addChild(needGolds,2)

            local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSprite:setScaleX((totalW + 30)/lineSprite:getContentSize().width)
            lineSprite:setPosition(ccp((totalW + 30)/2 + 30,h + barH))
            cell:addChild(lineSprite,5)
            if i == awardCells then
              local lineSprite2 = CCSprite:createWithSpriteFrameName("LineCross.png")
              lineSprite2:setScaleX((totalW + 30)/lineSprite:getContentSize().width)
              lineSprite2:setPosition(ccp((totalW + 30)/2 + 30,h))
              cell:addChild(lineSprite2,5)
            end
    	end
 		for j=1,awardCells do
	        local money = acKafkaGiftVoApi:getNeedGoldById(j) -- 当前需要的金币
	        if addContinue == true then
	          if tonumber(rechargedAllGold) >= tonumber(money) then
	            perWidth = perWidth + barH
	          else
	            local lastMoney
	            if j == 1 then
	              lastMoney = 0
	            else
	              lastMoney = acKafkaGiftVoApi:getNeedGoldById(j - 1)
	            end
	            perWidth = perWidth + barH * ((rechargedAllGold - lastMoney) / (money - lastMoney))
	            addContinue = false
	          end
	        end
	    end
    end

    local barWidth = totalH + rewardBtnH
    local function click(hd,fn,idx)
    end
    local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("HelpBgBottom.png", CCRect(20,20,1,1),click)
    barSprie:setContentSize(CCSizeMake(barWidth, 50))
    barSprie:setRotation(90)
    barSprie:setPosition(ccp(35,barWidth/2))
    cell:addChild(barSprie,1)

    AddProgramTimer(cell,ccp(35,barWidth/2),11,12,nil,"AllBarBg.png","AllXpBar.png",13,1,1)
    local per = tonumber(perWidth)/tonumber(barWidth) * 100
    local timerSpriteLv = cell:getChildByTag(11)
    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
    timerSpriteLv:setPercentage(per)
    timerSpriteLv:setRotation(-90)
    timerSpriteLv:setScaleX(barWidth/timerSpriteLv:getContentSize().width)
    local bg = cell:getChildByTag(13)
    bg:setVisible(false)
    -- bg:setRotation(-90)
    -- bg:setScaleX(barWidth/bg:getContentSize().width)


    local verticalLine = CCSprite:createWithSpriteFrameName("LineCross.png")
    verticalLine:setScaleX(totalH/verticalLine:getContentSize().width)
    verticalLine:setRotation(90)
    verticalLine:setPosition(ccp(leftW-30 ,totalH/2 + rewardBtnH))
    cell:addChild(verticalLine,2)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
  end
end

function acKafkaGiftDialog:initNeedGolds(id)
  local needMoney = acKafkaGiftVoApi:getNeedGoldById(id)
  local needMoneyLabel=GetTTFLabel(tostring(needMoney),28)
  needMoneyLabel:setColor(G_ColorGreen)
  return needMoneyLabel
end

function acKafkaGiftDialog:getReward(action,cid,mid,sxIdx) --缺少参数
  if acKafkaGiftVoApi:canReward() == true then
    local function getRawardCallback(fn,data)
      if base:checkServerData(data)==true then
          if self==nil or self.tv==nil then
              do return end
          end

          local chooseFlag = acKafkaGiftVoApi:getChooseFlagList()
          -- if chooseFlag[sxIdx] ~=cid then
              acKafkaGiftVoApi:setAwardFlagList(cid,sxIdx)
          -- end
          acKafkaGiftVoApi:setHadAwardList(cid,mid)
          acKafkaGiftVoApi:afterGetReward(index)
          acKafkaGiftVoApi:updateLastTime()
          self.isToday = acKafkaGiftVoApi:isToday()

         
             local award = FormatItem(acKafkaGiftVoApi:getRewardR2ById(cid),true,true)
             local commonReward = FormatItem(acKafkaGiftVoApi:getRewardR1ById(cid),true)
             local reward={}
             for k,v in pairs(commonReward) do
               table.insert(reward,v)
             end
             table.insert(reward,award[mid])
           G_showRewardTip(reward,true)
          if award[mid].type=="h" then
            -- local heroId,orderId = acKafkaGiftVoApi:takeHeroOrder(award[mid].key)
            -- print("award[mid].key,award[mid].num~~~~~~",award[mid].key,award[mid].num)
            heroVoApi:addSoul(award[mid].key,award[mid].num)
           
          else
             -- accessoryVoApi:addNewData(data)
          end
          -- 刷新tv后tv仍然停留在当前位置
          local recordPoint = self.tv:getRecordPoint()
          self.tv:reloadData()
          self.tv:recoverToRecordPoint(recordPoint)
      end
    end
    socketHelper:acKafkaGift(action,cid,mid,getRawardCallback)
  end
end

function acKafkaGiftDialog:doUserHandler()
  self.isToday = acKafkaGiftVoApi:isToday()
  if self.isToday ==false then
    acKafkaGiftVoApi:clearAwardFlagList()
    acKafkaGiftVoApi:updateLastTime()
    acKafkaGiftVoApi:setRechargeGold()
    local awardCells = acKafkaGiftVoApi:getAwardCells( )
    for i=1,awardCells do
      if self.awardCellIconTB[i] then
        self.awardCellIconTB[i]=nil
      end
    end
  end

  local function cellClick(hd,fn,index)
  end
  
  local w = G_VisibleSizeWidth - 20 -- 背景框的宽度
  local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
  backSprie:setContentSize(CCSizeMake(w, 200))
  backSprie:setAnchorPoint(ccp(0,0))
  backSprie:setPosition(ccp(10, G_VisibleSizeHeight - 290))
  backSprie:setTag(99)
  self.bgLayer:addChild(backSprie)
  
  
  
  local function touch(tag,object)
    self:openInfo()
  end

  w = w - 10 -- 按钮的x坐标
  local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touch,nil,nil,0)
  menuItemDesc:setAnchorPoint(ccp(1,0.5))
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(w, 50))
  backSprie:addChild(menuDesc)
  
  w = w - menuItemDesc:getContentSize().width

  local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
  acLabel:setAnchorPoint(ccp(0.5,1))
  acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 190))
  backSprie:addChild(acLabel)

  local acVo = acKafkaGiftVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,28)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 150))
  backSprie:addChild(messageLabel)
  self.timeLb=messageLabel
  self:updateAcTime()

  local desStr = getlocal("activity_kafkagift_des")
  local version = acKafkaGiftVoApi:getVersion()
  if version==nil or version<3 then
     desStr = getlocal("activity_kafkagift_des")
  else
     desStr = getlocal("activity_kafkagift_des" .. version)
  end
  local desTv, desLabel= G_LabelTableView(CCSizeMake(w, 60),desStr,23,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(10, 50))
    desTv:setAnchorPoint(ccp(0,1))
  desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  desTv:setMaxDisToBottomOrTop(100)
  backSprie:addChild(desTv)  


  local rechargeLabel = GetTTFLabel(getlocal("activity_totalRecharge_totalMoney"),28)
  rechargeLabel:setAnchorPoint(ccp(0,0))
  rechargeLabel:setPosition(ccp(10, 10))
  backSprie:addChild(rechargeLabel)
  
  self.moneyX = 20 + rechargeLabel:getContentSize().width
  -- print("acKafkaGiftVoApi:getRechargedGold().....>>>>>\n",acKafkaGiftVoApi:getRechargedGold())
  self.totalMoneyLabel = GetTTFLabel(tostring(acKafkaGiftVoApi:getRechargedGold()), 30)
  self.totalMoneyLabel:setAnchorPoint(ccp(0,0))
  self.totalMoneyLabel:setPosition(ccp(self.moneyX, 10))
  self.totalMoneyLabel:setColor(G_ColorYellowPro)
  backSprie:addChild(self.totalMoneyLabel)

  self.goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
  self.goldIcon:setAnchorPoint(ccp(0,0))
  self.goldIcon:setPosition(ccp(self.moneyX + self.totalMoneyLabel:getContentSize().width + 20,10))
  backSprie:addChild(self.goldIcon)

 
  local totalW = G_VisibleSizeWidth - 20

  local backSprie2 = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),cellClick)
  backSprie2:setContentSize(CCSizeMake(totalW, 40))
  backSprie2:setAnchorPoint(ccp(0.5,0.5))
  backSprie2:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 320))
  self.bgLayer:addChild(backSprie2)

  local goldLabel=GetTTFLabel(getlocal("gem"),28)
  goldLabel:setPosition(ccp(100 ,20))
  goldLabel:setColor(G_ColorGreen)
  backSprie2:addChild(goldLabel)

  local rewardLabel=GetTTFLabel(getlocal("award"),28)
  rewardLabel:setPosition(ccp(totalW - 180,20))
  rewardLabel:setColor(G_ColorGreen)
  backSprie2:addChild(rewardLabel)  




    local function rechargeCallback(tag,object)
    	PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        --activityAndNoteDialog:closeAllDialog()
    	vipVoApi:showRechargeDialog(self.layerNum+1)
    end
    local rewardBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",rechargeCallback,nil,getlocal("recharge"),25,11)
    rewardBtn:setAnchorPoint(ccp(0.5,0))
    local rewardMenu=CCMenu:createWithItem(rewardBtn)
    local adaH = 20
    if G_getIphoneType() == G_iphoneX then
      adaH = 50
    end
    rewardMenu:setPosition(ccp(G_VisibleSizeWidth/2,adaH))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(rewardMenu,1)
end

-- 更新今日充值金额
function acKafkaGiftDialog:updatetotalMoneyLabel()
  if self == nil then
    do 
     return
    end
  end

  if self.totalMoneyLabel ~= nil then
    self.totalMoneyLabel:setString(tostring(acKafkaGiftVoApi:getRechargedGold()))
    if self.moneyX ~= nil and self.goldIcon ~= nil then
      self.goldIcon:setPosition(ccp(self.moneyX + self.totalMoneyLabel:getContentSize().width + 20,10))
    end
  end
  if self.rewardBtn ~= nil then
    if acKafkaGiftVoApi:canReward() == true then
      self.rewardBtn:setVisible(true)
      self.rewardBtn:setEnabled(true)
    else
      self.rewardBtn:setVisible(false)
      self.rewardBtn:setEnabled(false)
    end
  end

end

function acKafkaGiftDialog:openInfo()
  local td=smallDialog:new()
  local tabStr = {"\n",getlocal("activity_kafkagift_detail3"),"\n",getlocal("activity_kafkagift_detail2"),"\n", getlocal("activity_kafkagift_detail1"),"\n"}
  local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
  sceneGame:addChild(dialog,self.layerNum+1)
end

function acKafkaGiftDialog:tick()
  local isToday = acKafkaGiftVoApi:isToday()
    if isToday ==false then
      acKafkaGiftVoApi:updateLastTime()
      self.isToday=isToday
      acKafkaGiftVoApi:clearAwardFlagList( )
      -- print("tick in setRechargeGold......")
      acKafkaGiftVoApi:setRechargeGold()
      -- local sp = tolua.cast(self.bgLayer:getChildByTag(99),"CCSprite")
      -- local lb=tolua.cast(sp:getChildByTag(100+i),"CCLabelTTF")
      if(self.totalMoneyLabel)then
        self.totalMoneyLabel:setString(tostring(acKafkaGiftVoApi:getRechargedGold()))
      end
          local awardCells = acKafkaGiftVoApi:getAwardCells( )
          for i=1,awardCells do
            if self.awardCellIconTB[i] then
              self.awardCellIconTB[i]=nil
            end
          end
      self.tv:reloadData()
    end
    self:updateAcTime()
end

function acKafkaGiftDialog:updateAcTime()
    local acVo=acKafkaGiftVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acKafkaGiftDialog:update()
  local acVo = acKafkaGiftVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      self:updatetotalMoneyLabel()
      local recordPoint = self.tv:getRecordPoint()
      self.tv:reloadData()
      self.tv:recoverToRecordPoint(recordPoint)
    end
  end
end

function acKafkaGiftDialog:frushBigAwardList( )
    acKafkaGiftVoApi:initChooseFlagList( )
    local  awardFlag = acKafkaGiftVoApi:getAwardFlagList( )
    local awardCells = acKafkaGiftVoApi:getAwardCells( )
    local chooseFlag = acKafkaGiftVoApi:getChooseFlagList()

    for i=1,SizeOfTable(awardFlag) do
      if awardFlag[i] >0 then
        acKafkaGiftVoApi:setBigAwardCellIdx(i)
        local awardCell = acKafkaGiftVoApi:getBigAwardCellIdx()
        local awardIdx = acKafkaGiftVoApi:getHadAwardList( awardCell)
        local award = FormatItem(acKafkaGiftVoApi:getRewardR2ById(awardCell),true,true)
          self.awardCellIconTB[awardCells-i+1]=award[awardIdx]
      end
    end
    for i=1,SizeOfTable(chooseFlag) do
      if chooseFlag[awardCells-i+1] ~=nil and chooseFlag[awardCells-i+1]>0 and self.awardCellIconTB[i] ==nil then
        -- print(">>>>>>>?",awardCells-i+1)
        acKafkaGiftVoApi:setBigAwardCellIdx(i)
        local awardCell = acKafkaGiftVoApi:getBigAwardCellIdx()
        local awardIdx = chooseFlag[awardCells-i+1]
        local award = FormatItem(acKafkaGiftVoApi:getRewardR2ById(awardCells-awardCell+1),true,true)
          self.awardCellIconTB[i]=award[awardIdx]
      end
    end
    local sp = tolua.cast(sceneGame:getChildByTag(667),"CCSprite")
    if sp==nil then
      acKafkaGiftVoApi:setBigAwardCellIdx(nil)
      acKafkaGiftVoApi:setBigAwardInIdx(nil)
    end
end

function acKafkaGiftDialog:dispose()
  self.totalMoneyLabel = nil
  self.goldIcon = nil
  self.moneyX = nil
  self.rewardBtn = nil
  self.awardCellIconTB=nil
  self.awardIdxInCellTB=nil
  self.isToday=nil
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/heroRecruitImage.plist")
  self=nil
end
