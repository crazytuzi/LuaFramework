acDailyRechargeByNewGuiderDialog=commonDialog:new()

function acDailyRechargeByNewGuiderDialog:new()--activePicUseInNewGuid.png
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.todayMoneyLabel = nil
    self.rewardBtn = nil
    self.addPosX = 5
    self.addPosX2 = 0
    self.flickCfg ={}
    self.lightPos = {{{0.42,0.2},{0.54,0.92}},{{0.43,0.39},{0.54,0.19}},{{0.21,0.43},{0.89,0.15}},{{0.44,0.4},{0.49,0.25}},{{0.6,0.62}}}
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/activePicUseInNewGuid.plist")
    spriteController:addTexture("public/activePicUseInNewGuid.png")
    spriteController:addPlist("public/acChunjiepansheng3.plist")
    spriteController:addTexture("public/acChunjiepansheng3.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    return nc
end

function acDailyRechargeByNewGuiderDialog:initTableView()
  if G_isIphone5() then
  	self.addPosX = 20
    self.addPosX2 = 10
  end
  self.allAwardArr = SizeOfTable(acDailyRechargeByNewGuiderVoApi:getAcCfg().reward)
  self.flickCfg = acDailyRechargeByNewGuiderVoApi:getFlickCfg( )
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 15))

  local blueBg =CCSprite:create("public/superWeapon/weaponBg.jpg")
  blueBg:setAnchorPoint(ccp(0.5,0))
  blueBg:setScaleX((G_VisibleSizeWidth-24)/blueBg:getContentSize().width)
  blueBg:setScaleY((G_VisibleSizeHeight-122)/blueBg:getContentSize().height)
  blueBg:setPosition(ccp(G_VisibleSizeWidth*0.5, 32))
  self.bgLayer:addChild(blueBg)

  local tvBgHeight = G_VisibleSizeHeight - 395--460
  local tvHeight = tvBgHeight - 60
  local function noData( ) end
  local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg3.png",CCRect(19,19,1,1),noData)
  tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 24,tvBgHeight))
  tvBg:setAnchorPoint(ccp(0,0))
  -- tvBg:setOpacity(200)
  tvBg:setPosition(ccp(12,110))
  self.bgLayer:addChild(tvBg,1)

  -- local blueBg2 =CCSprite:create("public/superWeapon/weaponBg.jpg")
  -- blueBg2:setAnchorPoint(ccp(0.5,0.5))
  -- blueBg2:setOpacity(220)
  -- blueBg2:setScaleX((tvBg:getContentSize().width-8)/blueBg2:getContentSize().width)
  -- blueBg2:setScaleY((tvBg:getContentSize().height-10)/blueBg2:getContentSize().height)
  -- blueBg2:setPosition(getCenterPoint(tvBg))
  -- tvBg:addChild(blueBg2)

  local rechargeLabel = GetTTFLabel(getlocal("activity_dailyRechargeByNewGuider_todayMoney"),25)
  rechargeLabel:setAnchorPoint(ccp(0,0.5))
  rechargeLabel:setPosition(ccp(10, tvBg:getContentSize().height-40))
  tvBg:addChild(rechargeLabel)

  self.todayMoneyLabel = GetTTFLabel(tostring(acDailyRechargeByNewGuiderVoApi:getTodayMoney()), 30)
  self.todayMoneyLabel:setAnchorPoint(ccp(0,0.5))
  self.todayMoneyLabel:setPosition(ccp(20 + rechargeLabel:getContentSize().width, rechargeLabel:getPositionY()))
  self.todayMoneyLabel:setColor(G_ColorYellowPro)
  tvBg:addChild(self.todayMoneyLabel)

  self.moneyGoldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
  self.moneyGoldSp:setAnchorPoint(ccp(0,0.5))
  tvBg:addChild(self.moneyGoldSp)
  self.moneyGoldSp:setPosition(ccp(self.todayMoneyLabel:getPositionX()+self.todayMoneyLabel:getContentSize().width+3,self.todayMoneyLabel:getPositionY()))

  -- threeyear_numbg.png

  local goldLineSprite1 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
  goldLineSprite1:setAnchorPoint(ccp(0.5,1))
  goldLineSprite1:setScaleX(tvBg:getContentSize().width/goldLineSprite1:getContentSize().width)
  goldLineSprite1:setPosition(ccp(tvBg:getContentSize().width*0.5,tvBg:getContentSize().height))
  tvBg:addChild(goldLineSprite1,1)

  self.cellWidth = G_VisibleSizeWidth - 24
  self.cellHeight = tvHeight*0.2

  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,tvHeight),nil)
  self.bgLayer:addChild(self.tv,1)
  self.tv:setPosition(ccp(10,115))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)
  -- local recordPoint = self.tv:getRecordPoint()
  -- recordPoint.y = 0
  -- self.tv:recoverToRecordPoint(recordPoint)

  -- local acCfg = acDailyRechargeByNewGuiderVoApi:getAcCfg()
  -- if acCfg ~= nil and acCfg.reward ~= nil then
  --     if self.cellHeight * SizeOfTable(acCfg.reward) + 10 > tvHeight then
  --         local recordPoint = self.tv:getRecordPoint()
  --         recordPoint.y = 0
  --         self.tv:recoverToRecordPoint(recordPoint)
  --     end
  -- end

end

function acDailyRechargeByNewGuiderDialog:eventHandler(handler,fn,idx,cel)
  local strSize3 = 20
  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
    strSize3 = 25
  end
  if fn=="numberOfCellsInTableView" then
    return self.allAwardArr
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(self.cellWidth,self.cellHeight)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    -- print("idx------>",idx)
    local function noData( ) end
    local curAwardIdx = self.allAwardArr - idx
    local cellBgStr = nil
    local canReward = acDailyRechargeByNewGuiderVoApi:checkIfCanRewardById(curAwardIdx)
    local inRightPos = ccp(self.cellWidth-70,self.cellHeight*0.5)
    if canReward == true then
    	local hadReward = acDailyRechargeByNewGuiderVoApi:checkIfHadRewardById(curAwardIdx)
    	if hadReward then
	      	local hadLb = GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)--activity_hadReward
			hadLb:setAnchorPoint(ccp(0.5,0.5))
			hadLb:setPosition(inRightPos)
			hadLb:setColor(G_ColorGray)
			cell:addChild(hadLb,1)
			cellBgStr = "lightGreyBrownBg.png"
	    else
	    	local function rewardHandler(tag,object)
	    	  print("tag----->",tag)
		      PlayEffect(audioCfg.mouseClick)
		      self:getReward(tag)
		    end
		    local awarding = GetButtonItem("taskReward.png","taskReward_down.png","taskReward_down.png",rewardHandler,curAwardIdx,nil,nil)
		    awarding:setAnchorPoint(ccp(0.5, 0.5))
		    local menuAward=CCMenu:createWithItem(awarding)
		    menuAward:setPosition(inRightPos)
		    menuAward:setTouchPriority(-(self.layerNum-1)*20-4)
			cell:addChild(menuAward,1)
			cellBgStr = "BrightBrownBg.png"

			G_addFlicker(awarding,2,2)
	    end
    else
    	local noLabel = GetTTFLabelWrap(getlocal("noReached"),strSize3,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)--noReached
		noLabel:setAnchorPoint(ccp(0.5,0.5))
		noLabel:setPosition(inRightPos)
		cell:addChild(noLabel,1)
		cellBgStr = "darkBrownBg.png"
    end  
    
    if cellBgStr ~= nil then
    	cellBg = LuaCCScale9Sprite:createWithSpriteFrameName(cellBgStr,CCRect(15,15,1,1),noData)
    	cellBg:setContentSize(CCSizeMake(self.cellWidth-20,self.cellHeight-4))
		cellBg:setAnchorPoint(ccp(0.5,0.5))
		-- cellBg:setOpacity(255)
		cellBg:setPosition(ccp(self.cellWidth*0.5+2,self.cellHeight*0.5))
		cell:addChild(cellBg)
	end

	local gemsSp = CCSprite:createWithSpriteFrameName("iconGold"..self.allAwardArr-idx..".png")
	gemsSp:setScale(self.cellHeight*0.68/gemsSp:getContentSize().height*(1-idx*0.1))
	gemsSp:setAnchorPoint(ccp(0.5,1))
	gemsSp:setPosition(ccp(self.cellWidth*0.085+self.addPosX,self.cellHeight-10-idx*2))
	cellBg:addChild(gemsSp)
	local usePos = self.lightPos[idx+1]
	for m,n in pairs(usePos) do
		local lightSp = CCSprite:createWithSpriteFrameName("whiteLightPoint.png")
		lightSp:setPosition(ccp(gemsSp:getContentSize().width*n[1],gemsSp:getContentSize().height*n[2]))
		gemsSp:addChild(lightSp)
	end

	local needMoney = acDailyRechargeByNewGuiderVoApi:getNeedMoneyById(curAwardIdx)
	local needMoneyStr = GetTTFLabel(needMoney,28)
	needMoneyStr:setAnchorPoint(ccp(0.5,0))
	needMoneyStr:setPosition(ccp(gemsSp:getPositionX(),1+idx*1.5))
	cellBg:addChild(needMoneyStr,1)

	-- local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
 --    grayBgSp:setOpacity(100)
 --    grayBgSp:setContentSize(CCSizeMake(needMoneyStr:getContentSize().width+4,needMoneyStr:getContentSize().height))
	-- grayBgSp:setAnchorPoint(ccp(0.5,0))
	-- grayBgSp:setPosition(ccp(needMoneyStr:getPositionX(),needMoneyStr:getPositionY()))
	-- cellBg:addChild(grayBgSp)

	local pointPic=CCSprite:createWithSpriteFrameName("pointYellowLight.png")
	if self.cellHeight*0.8 < pointPic:getContentSize().height then
		pointPic:setScaleY(self.cellHeight*0.8/pointPic:getContentSize().height)
	end
    pointPic:setPosition(ccp(self.cellWidth*0.23+self.addPosX,self.cellHeight*0.5))
    pointPic:setAnchorPoint(ccp(0.5,0.5))
    -- pointPic:setFlipX(true)
    cellBg:addChild(pointPic)

    local award=FormatItem(acDailyRechargeByNewGuiderVoApi:getRewardById(curAwardIdx),true)
    for k,v in pairs(award) do
    	local scale=1
    	local propSp=G_getItemIcon(v,85,true,self.layerNum+1)
        propSp:setAnchorPoint(ccp(0,0.5))
        propSp:setTouchPriority(-(self.layerNum-1)*20-2)
        -- propSp:setScale(self.cellHeight*0.85/propSp:getContentSize().height)
        propSp:setPosition(ccp(pointPic:getPositionX()+(50-self.addPosX2)+98*(k-1),self.cellHeight*0.5-2))
        cellBg:addChild(propSp,1)

        local itemW=propSp:getContentSize().width*scale
        local itemH=propSp:getContentSize().height*scale

        local numLb=GetTTFLabel("x"..v.num,25)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(itemW-5,5))
        numLb:setScale(1/propSp:getScale())
        propSp:addChild(numLb,1)

        if self.flickCfg and SizeOfTable(self.flickCfg) > 0 then
  			for x,z in pairs(self.flickCfg) do
  				for m,n in pairs(z) do
  					for i,j in pairs(n) do
  						if i == v.key and j == v.num then
  							G_addRectFlicker2(propSp,1.2,1.2,2,"p",nil,10)
  						end
  					end
  				end
  			end
		end
    end

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acDailyRechargeByNewGuiderDialog:getReward(awardIdx)
  if acDailyRechargeByNewGuiderVoApi:canReward() == true then
    local function getRawardCallback(fn,data)
      local ret,sData=base:checkServerData(data)
      if base:checkServerData(data)==true then
          if self==nil or self.tv==nil then
              do return end
          end
          local currentCanGetReward,index = acDailyRechargeByNewGuiderVoApi:getRewardById(awardIdx)
          local reward = FormatItem(currentCanGetReward, true)
          for k,v in pairs(reward) do
            -- print("v.name---->",v.name)
            G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
          end
          G_showRewardTip(reward,true)
          smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
          if sData and sData.data and sData.data.mrcz and sData.data.mrcz.r then
              acDailyRechargeByNewGuiderVoApi:afterGetReward(awardIdx,sData.data.mrcz.r)
          end
          
          -- 刷新tv后tv仍然停留在当前位置
          local recordPoint = self.tv:getRecordPoint()
          self.tv:reloadData()
          self.tv:recoverToRecordPoint(recordPoint)
          
      end
    end
    socketHelper:getDailyRechargeByNewGuiderReward(getRawardCallback,awardIdx)
  end
end

function acDailyRechargeByNewGuiderDialog:getAwardStr(reward)
  local awardTab = reward
  local str = getlocal("daily_lotto_tip_10")
  if awardTab then
    for k,v in pairs(awardTab) do
      if k==SizeOfTable(awardTab) then
        str = str .. v.name .. " x" .. v.num
      else
        str = str .. v.name .. " x" .. v.num .. ","
      end
    end
  end
  return str
end


function acDailyRechargeByNewGuiderDialog:initNeedMoney(id)
  local needMoney = acDailyRechargeByNewGuiderVoApi:getNeedMoneyById(id)
  local needMoneyLabel=GetTTFLabel(tostring(needMoney),28)
  needMoneyLabel:setColor(G_ColorGreen)
  return needMoneyLabel
end

function acDailyRechargeByNewGuiderDialog:doUserHandler()
  local strColor = G_ColorWhite
  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
      strColor = G_ColorYellowPro
  end
  local function cellClick(hd,fn,index)
  end
  
  local w = G_VisibleSizeWidth - 26 -- 背景框的宽度
  local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("goldAndTankBg_2.jpg",CCRect(20, 20, 10, 10),cellClick)
  backSprie:setContentSize(CCSizeMake(w, 200))
  backSprie:setAnchorPoint(ccp(0.5,0))
  backSprie:setPosition(ccp(G_VisibleSizeWidth*0.5, G_VisibleSizeHeight - 287))
  self.bgLayer:addChild(backSprie,1)
  
  
  
  local function touch(tag,object)
    self:openInfo()
  end

  w = w - 10 -- 按钮的x坐标
  local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
  menuItemDesc:setAnchorPoint(ccp(1,1))
  menuItemDesc:setScale(0.8)
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(w, backSprie:getContentSize().height-10))
  backSprie:addChild(menuDesc)
  
  w = w - menuItemDesc:getContentSize().width

  local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
  acLabel:setAnchorPoint(ccp(0.5,1))
  acLabel:setPosition(ccp(backSprie:getContentSize().width*0.5, 190))
  acLabel:setColor(strColor)
  backSprie:addChild(acLabel)

  local acVo = acDailyRechargeByNewGuiderVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,28)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setColor(strColor)
  messageLabel:setPosition(ccp(backSprie:getContentSize().width*0.5, 150))
  backSprie:addChild(messageLabel)
  self.messageLabel=messageLabel
  self:updateAcTime()

  local desLb = getlocal("activity_dailyRechargeByNewGuider_des")
  local version = acDailyRechargeByNewGuiderVoApi:getVersion()
  if version ==3 then
      desLb = getlocal("activity_dailyRechargeByNewGuider_des_c")
  end
  local desLabel = GetTTFLabel(desLb,25)--,CCSizeMake(w+50, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  if desLabel:getContentSize().width > G_VisibleSizeWidth*0.9 then
    desLabel = GetTTFLabelWrap(desLb,25,CCSizeMake(450, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  end
  desLabel:setAnchorPoint(ccp(0.5,0))
  desLabel:setPosition(ccp(backSprie:getContentSize().width*0.5, 15))
  backSprie:addChild(desLabel,1)

  local desLabelBg = CCSprite:createWithSpriteFrameName("blackGradualChange.png")
  desLabelBg:setAnchorPoint(ccp(0.5,0.5))
  local nScaleX = (desLabel:getContentSize().width+6)/desLabelBg:getContentSize().width
  desLabelBg:setScaleX(nScaleX)
  desLabelBg:setScaleY((desLabel:getContentSize().height+6)/desLabelBg:getContentSize().height)
  desLabelBg:setPosition(ccp(backSprie:getContentSize().width*0.5,desLabel:getContentSize().height*0.5+desLabel:getPositionY()))
  backSprie:addChild(desLabelBg)

  for i=1,2 do
  		local posY = i ==1 and desLabel:getPositionY()+desLabel:getContentSize().height+3 or desLabel:getPositionY()-3
  		local yellowLine = CCSprite:createWithSpriteFrameName("yellowLightPoint.png")
	    yellowLine:setAnchorPoint(ccp(0.5,0.5))
	    yellowLine:setScaleX((desLabel:getContentSize().width+6)/yellowLine:getContentSize().width)
	    yellowLine:setScaleY(1.2)
	    yellowLine:setPosition(ccp(backSprie:getContentSize().width*0.5,posY))
		backSprie:addChild(yellowLine)	    

		local addPosX = i == 1 and 40 or -50
		local yellowStar = CCSprite:createWithSpriteFrameName("yellowLightPointBg.png")
		yellowStar:setAnchorPoint(ccp(0.5,0.5))
		yellowStar:setPosition(yellowLine:getPositionX()+addPosX,yellowLine:getPositionY())
		yellowStar:setScaleY(0.9)
		backSprie:addChild(yellowStar)

  end
 
  local function rewardHandler(tag,object)
      PlayEffect(audioCfg.mouseClick)
	    if G_checkClickEnable()==false then
	        do
	            return
	        end
	    else
	        base.setWaitTime=G_getCurDeviceMillTime()
	    end
	    activityAndNoteDialog:closeAllDialog()
	    vipVoApi:showRechargeDialog(self.layerNum+1)
  end

    self.rewardBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",rewardHandler,0,getlocal("new_recharge_recharge_now"),28)
    self.rewardBtn:setAnchorPoint(ccp(0.5, 0))
    local menuAward=CCMenu:createWithItem(self.rewardBtn)
    menuAward:setPosition(ccp(G_VisibleSizeWidth/2,35))
    menuAward:setTouchPriority(-(self.layerNum-1)*20-4)

    self.bgLayer:addChild(menuAward,1) 
end

-- 更新今日充值金额
function acDailyRechargeByNewGuiderDialog:updateTodayMoneyLabel()
  if self == nil then
    do 
     return
    end
  end

  if self.todayMoneyLabel ~= nil then
    self.todayMoneyLabel:setString(tostring(acDailyRechargeByNewGuiderVoApi:getTodayMoney()))
    self.moneyGoldSp:setPosition(ccp(self.todayMoneyLabel:getPositionX()+self.todayMoneyLabel:getContentSize().width+3,self.todayMoneyLabel:getPositionY()))
  end
  -- if self.rewardBtn ~= nil then
  --   if acDailyRechargeByNewGuiderVoApi:canReward() == true then
  --     self.rewardBtn:setEnabled(true)
  --   else
  --     self.rewardBtn:setEnabled(false)
  --   end
  -- end

end

function acDailyRechargeByNewGuiderDialog:openInfo()
  local td=smallDialog:new()
  local tabStr = {"\n",getlocal("activity_dailyRechargeByNewGuider_detail3"),"\n",getlocal("activity_dailyRechargeByNewGuider_detail2"),"\n", getlocal("activity_dailyRechargeByNewGuider_detail1"),"\n"}
  local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
  sceneGame:addChild(dialog,self.layerNum+1)
end

function acDailyRechargeByNewGuiderDialog:tick()
    if self then
      self:updateAcTime()
    end
end

function acDailyRechargeByNewGuiderDialog:updateAcTime()
  local acVo = acDailyRechargeByNewGuiderVoApi:getAcVo()
  if acVo and self.messageLabel then
    G_updateActiveTime(acVo,self.messageLabel)
  end
end

function acDailyRechargeByNewGuiderDialog:update()
  local acVo = acDailyRechargeByNewGuiderVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      self:updateTodayMoneyLabel()
      local recordPoint = self.tv:getRecordPoint()
      self.tv:reloadData()
      self.tv:recoverToRecordPoint(recordPoint)
    end
  end
end

function acDailyRechargeByNewGuiderDialog:dispose()
  self.todayMoneyLabel = nil
  self.rewardBtn = nil
  self.messageLabel = nil
  self=nil

  	spriteController:removePlist("public/activePicUseInNewGuid.plist")
    spriteController:removeTexture("public/activePicUseInNewGuid.png")
    spriteController:removePlist("public/acChunjiepansheng3.plist")
    spriteController:removeTexture("public/acChunjiepansheng3.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removeTexture("public/purpleFlicker.png")
end





