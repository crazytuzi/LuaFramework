acJunzipaisongDialog = commonDialog:new()

function acJunzipaisongDialog:new()
	local  nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.isToday = nil
	self.isPlay=false
	self.iconList={}
	self.itemList={}

	self.haloPos=0

	return nc
end

--初始化对话框面板
function acJunzipaisongDialog:initTableView( )
	--base:removeFromNeedRefresh(self)
	local function touchDialog()
      if self.state == 2 then
        PlayEffect(audioCfg.mouseClick)
        self.state = 3
        -- 暂停动画
        -- self:close()
      end
  	end
  self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
  self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
  local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
  self.touchDialogBg:setContentSize(rect)
  self.touchDialogBg:setOpacity(0)
  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
  self.touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
  self.bgLayer:addChild(self.touchDialogBg,10)
	
	-----拿数据
	self.isToday = acJunzipaisongVoApi:isToday()
	localHeight=self.bgLayer:getContentSize().height*0.25-30
	self.panelLineBg:setVisible(false)
	local function callBack( ... )
		return self:eventHandler(...)
	end
	local hd = LuaEventHandler:createHandler(callBack)

	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,localHeight*3),nil)

	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setPosition(ccp(10,20))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(120)

	local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
	actTime:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-110))
	actTime:setColor(G_ColorGreen)
	self.bgLayer:addChild(actTime,5)

	local acVo =acJunzipaisongVoApi:getAcVo()  ---
	if acVo ~=nil then
		local timeStr = activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
		local timeLabel=GetTTFLabel(timeStr,26)
		timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-145))
		self.bgLayer:addChild(timeLabel,5)
        self.timeLb=timeLabel
        G_updateActiveTime(acVo,self.timeLb)
	end

	local function tmpFunc()
    end
    local maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
    -- maskSp:setOpacity(255)
    local size=CCSizeMake(self.bgLayer:getContentSize().width-40,345)
    maskSp:setContentSize(size)
    maskSp:setAnchorPoint(ccp(0.5,1))
    maskSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-85))
	maskSp:setIsSallow(true)
	maskSp:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(maskSp,4)


	local citySp = CCSprite:create("scene/cityR1_mi.jpg")
	citySp:setScaleX(maskSp:getContentSize().width/citySp:getContentSize().width)
	citySp:setScaleY(maskSp:getContentSize().height/citySp:getContentSize().height)
	citySp:setAnchorPoint(ccp(0.5,1))
	citySp:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-85)
	self.bgLayer:addChild(citySp,1)

	local characterSp
    if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
        characterSp = CCSprite:create("public/guide.png")
    else
        characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
    end
    -- characterSp:setScale(0.8)
    characterSp:setAnchorPoint(ccp(0,1))
    characterSp:setPosition(ccp(20,self.bgLayer:getContentSize().height - 167))
    self.bgLayer:addChild(characterSp,5)

  local lbStr = nil
  local ver = acJunzipaisongVoApi:getVersion()
  if ver ==nil or ver ==1 then
    lbStr=getlocal("activity_junzipaisong_content")
  else
    lbStr=getlocal("activity_junzipaisong_contentB")
  end

	local tabelLb = G_LabelTableView(CCSizeMake(self.bgLayer:getContentSize().width-40-characterSp:getContentSize().width,220),lbStr,26,kCCTextAlignmentLeft)
	tabelLb:setPosition(ccp(260,self.bgLayer:getContentSize().height-410))
	tabelLb:setAnchorPoint(ccp(0,0))
	tabelLb:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	tabelLb:setMaxDisToBottomOrTop(70)
	self.bgLayer:addChild(tabelLb,5)

	local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX((G_VisibleSizeWidth)/lineSprite:getContentSize().width)
    lineSprite:setPosition(ccp((G_VisibleSizeWidth)/2,self.bgLayer:getContentSize().height - 440))
    self.bgLayer:addChild(lineSprite,6)



    local oneGems=acJunzipaisongVoApi:getLotteryOnceCost()       --一次抽奖需要金币
    local tenGems = acJunzipaisongVoApi:getLotteryTenCost()

    local btnY = (self.bgLayer:getContentSize().height-420)/2

    local lbY=(self.bgLayer:getContentSize().height-420)/2+50
    local leftPosX=self.bgLayer:getContentSize().width/2-80
    local rightPosX=self.bgLayer:getContentSize().width/2+80
    self.goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp1:setAnchorPoint(ccp(0,0.5))
    self.goldSp1:setPosition(ccp(leftPosX+10,lbY))
    self.bgLayer:addChild(self.goldSp1)
    self.goldSp1:setScale(1.2)

    self.gemsLabel1=GetTTFLabel(oneGems,25)
    self.gemsLabel1:setAnchorPoint(ccp(1,0.5))
    self.gemsLabel1:setPosition(ccp(leftPosX,lbY))
    self.bgLayer:addChild(self.gemsLabel1,1)

    self.goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp2:setAnchorPoint(ccp(0,0.5))
    self.goldSp2:setPosition(ccp(rightPosX+10,lbY))
    self.bgLayer:addChild(self.goldSp2)
    self.goldSp2:setScale(1.2)

    self.gemsLabel2=GetTTFLabel(tenGems,25)
    self.gemsLabel2:setAnchorPoint(ccp(1,0.5))
    self.gemsLabel2:setPosition(ccp(rightPosX,lbY))
    self.bgLayer:addChild(self.gemsLabel2,1)

    self:updateBtnShow()

    local iconWidth=120
    local iconHeight=(self.bgLayer:getContentSize().height-420)/3-50
    local wSpace=30
    local hSpace=30
    local xSpace=self.bgLayer:getContentSize().width/2-230
    local ySpace=70

    local rewardCfg = acJunzipaisongVoApi:getCircleListCfg()

    local award = FormatItem(rewardCfg,true,true) or {}
	  if award ~= nil then
	     for m,n in pairs(award) do
	      local icon, iconScale = G_getItemIcon(n ,100, true, self.layerNum)

	      local numLb = GetTTFLabel("x"..n.num,25)
	      numLb:setAnchorPoint(ccp(1,0))
	      numLb:setPosition(ccp(icon:getContentSize().width-10,10))
	      icon:addChild(numLb)
	      self.iconList[n.index]=icon
	      self.itemList[n.index]=n

	      icon:setAnchorPoint(ccp(0.5,0.5))
	        if(n.index<5)then
	            icon:setPosition(ccp((iconWidth+wSpace)*(n.index-1)+xSpace,btnY+iconHeight))
	        elseif(n.index==5)then
	            icon:setPosition(ccp(xSpace+450,btnY))
	        elseif(n.index<10)then
	            icon:setPosition(ccp((iconWidth+wSpace)*(9-n.index)+xSpace,btnY-iconHeight))
	        elseif(n.index==10)then
	            icon:setPosition(ccp(xSpace,btnY))
	        end

	      icon:setTouchPriority(-(self.layerNum-1)*20-4)
	      self.bgLayer:addChild(icon)
	    end
	  end


  local function nilFunc()
  end
  self.halo=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),nilFunc)
  self.halo:setContentSize(CCSizeMake(100+8,100+8))
  self.halo:setAnchorPoint(ccp(0.5,0.5))
  self.halo:setTouchPriority(0)
  self.halo:setVisible(false)
  local tx,ty=self.iconList[1]:getPosition()
  self.halo:setPosition(tx,ty)
  self.bgLayer:addChild(self.halo,3)
end


function acJunzipaisongDialog:updateBtnShow()

  local oneGems=acJunzipaisongVoApi:getLotteryOnceCost()      --一次抽奖需要金币
  local tenGems = acJunzipaisongVoApi:getLotteryTenCost()

  local btnY=(self.bgLayer:getContentSize().height-420)/2
  local leftPosX=self.bgLayer:getContentSize().width/2-80
  local rightPosX=self.bgLayer:getContentSize().width/2+80

  local function btnCallback(tag,object)
          if G_checkClickEnable()==false then
              do
                  return
              end
          else
              base.setWaitTime=G_getCurDeviceMillTime()
          end 

          PlayEffect(audioCfg.mouseClick)

          local free=0              --是否是第一次免费
          if acJunzipaisongVoApi:isToday()==true then
            free=1
          end
          local num
          local function closeCallback( ... )
          	self:close()
          end
          if tag==1 then
            if free==1 and playerVoApi:getGems()<oneGems then
              GemsNotEnoughDialog(nil,nil,oneGems-playerVoApi:getGems(),self.layerNum+1,oneGems,closeCallback)
              do return end
            end
            num=1
          elseif tag==2 then
          	if playerVoApi:getGems()<tenGems then
              GemsNotEnoughDialog(nil,nil,tenGems-playerVoApi:getGems(),self.layerNum+1,tenGems,closeCallback)
              do return end
            end
            num=10
          end
          
          local function lotteryCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData.data==nil then
                  do return end
                end
                local free=0              --是否是第一次免费
		        if acJunzipaisongVoApi:isToday()==true then
		           free=1
		        end
                if tag==1 then
                  if free==1 then
                    playerVoApi:setValue("gems",playerVoApi:getGems()-oneGems)
                  end
                elseif tag==2 then
                	playerVoApi:setValue("gems",playerVoApi:getGems()-tenGems)
                end

              --刷新活动数据
                local tipStr=""
                local getTank1=false
                local getTank2=false
                if sData.data["junzipaisong"] then
                  self.awardData=sData.data["junzipaisong"]["clientreward"]

                  
                  local str = ""
                  local nameStr 
                  local content = {}
                  for k,v in pairs(self.awardData) do
                    local ptype = v[1]
                    local pID = v[2]
                    local num = v[3]
                    local award = {}

                    self.lotteryPtype = ptype
                    self.lotteryPID = pID
                    self.lotteryPNum= num
                    local name,pic,desc,id,index,eType,equipId=getItem(pID,ptype)
                    -- nameStr = name
                    local award = {}
                    award={name=name,num=num,pic=pic,desc=desc,id=id,type=ptype,index=index,key=pID,eType=eType,equipId=equipId}
                    self.reward = award
                    table.insert(content,{award=award,point=0,index=award.index})
                    G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                    if acJunzipaisongVoApi:checkIsChatByID(ptype,pID,num) ==true then
                        local message={key="activity_chatSystemMessage",param={playerVoApi:getPlayerName(),getlocal("activity_junzipaisong_title"),award.name.." x"..award.num}}
                        chatVoApi:sendSystemMessage(message)
                	end
                  end
                  if tag ==1  then
                  	if free == 0 then
                      acJunzipaisongVoApi:updateLastTime()
                      self.isToday=acJunzipaisongVoApi:isToday()
                      acJunzipaisongVoApi:updateShow()
                  	end
                  	self.state = 2
                  	self.lotteryOneBtn:setEnabled(false)
                  	self.lotteryTenBtn:setEnabled(false)
                  	self:play()
                  elseif tag==2 then
                  	local function confirmHandler( ... )
                  		-- body
                  	end
                  	smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,true)
                  end
                  
                end
              end
           end
          socketHelper:activityJunzipaisongLottery(num,lotteryCallback)
          
      end
  local strSize2 = 22
  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" then
      strSize2 =25
  end
  if self.lotteryTenBtn ==nil then
  	self.lotteryTenBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnCallback,2,getlocal("active_lottery_btn2"),strSize2)
  	self.lotteryTenBtn:setAnchorPoint(ccp(0.5,0.5))
	local lotteryTenMenu=CCMenu:createWithItem(self.lotteryTenBtn)
	lotteryTenMenu:setPosition(ccp(rightPosX,btnY))
	lotteryTenMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(lotteryTenMenu,2)
	self.lotteryTenBtn:setScale(0.8)
  end

  if self.lotteryOneBtn then
  	self.lotteryOneBtn:removeFromParentAndCleanup(true)
  	self.lotteryOneBtn=nil
  end
  if acJunzipaisongVoApi:isToday()==false then
    self.goldSp1:setVisible(false)
    self.gemsLabel1:setVisible(false)
    self.goldSp2:setVisible(false)
    self.gemsLabel2:setVisible(false)
    self.lotteryTenBtn:setEnabled(false)
    self.lotteryOneBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",btnCallback,1,getlocal("daily_lotto_tip_2"),25)
  else
    self.goldSp1:setVisible(true)
    self.gemsLabel1:setVisible(true)
    self.goldSp2:setVisible(true)
    self.gemsLabel2:setVisible(true)
    self.lotteryTenBtn:setEnabled(true)
    if playerVoApi:getGems()<oneGems then
    	self.gemsLabel1:setColor(G_ColorRed)
    else
    	self.gemsLabel1:setColor(G_ColorWhite)
    end

    if playerVoApi:getGems()<tenGems then
    	self.gemsLabel2:setColor(G_ColorRed)
    else
    	self.gemsLabel2:setColor(G_ColorWhite)
    end
  	self.lotteryOneBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnCallback,1,getlocal("activity_wheelFortune_subTitle_1"),25)
  end
  self.lotteryOneBtn:setScale(0.8)
  self.lotteryOneBtn:setAnchorPoint(ccp(0.5,0.5))
  local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn)
  lotteryMenu:setPosition(ccp(leftPosX,btnY))
  lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
  self.bgLayer:addChild(lotteryMenu,2)
  
end

function acJunzipaisongDialog:eventHandler( handler,fn,idx,cel )
	if fn=="numberOfCellsInTableView" then
		return 3
	elseif fn =="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-15,localHeight)
		return tmpSize
	elseif fn =="tableCellAtIndex" then
		local  cell = CCTableViewCell:new()
		cell:autorelease()
		return cell

   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then

   end
end

function acJunzipaisongDialog:play()
  self.isPlay=true
  self.touchDialogBg:setIsSallow(true)

    self.tickIndex=0
    self.tickInterval=10
    self.tickConst=10
    self.intervalNum=10 --fasttick间隔 3帧一次

    self.haloPos=0
    if self.endIdx then
      self.haloPos=self.endIdx
    end

    self.slowStart=false
    
    self.endIdx=0
    for k,v in pairs(self.itemList) do
        if self.itemList and v and self.reward and self.reward.key and v.key==self.reward.key and self.reward.num == v.num then
            self.endIdx=k
        end
    end


    self.slowTime=4

    if self.endIdx>0 then
        self.count=10*self.tickConst --转1圈之后开始减速
        if self.endIdx>self.slowTime then
            self.slowStartIndex=self.endIdx-self.slowTime
        else
            self.count=self.count-((self.slowTime-1)*self.tickConst)
            self.slowStartIndex=self.endIdx-self.slowTime+10
        end

        -- self.halo:setVisible(true)
        --base:addNeedRefresh(self)
    end

end

function acJunzipaisongDialog:fastTick()
	if self.isPlay == true then
		self.tickIndex=self.tickIndex+1
	    self.tickInterval=self.tickInterval-1
	    if self.state == 2 then
	       if(self.tickInterval<=0)then
	          self.tickInterval=self.tickConst
	          self.haloPos=self.haloPos+1
	          if(self.haloPos>10)then
	              self.haloPos=self.haloPos-10
	              -- self.haloPos=1
	          end
	          local tx,ty=self.iconList[self.haloPos]:getPosition()
	          self.halo:setPosition(tx,ty)
	          if self.halo:isVisible()==false then
	              self.halo:setVisible(true)
	          end

	          if (self.tickIndex>=self.count) then 

	              if(self.haloPos==self.slowStartIndex)then
	                  self.slowStart=true
	              end
	              if (self.slowStart) then
	                  --此处执行减速逻辑,减到一定速度(60)之后就不再减
	                  -- if(self.tickIndex>self.lastTs)then
	                      if (self.tickConst<self.tickConst*3) then
	                          self.tickConst=self.tickConst+self.tickConst
	                      elseif self.tickConst<self.intervalNum*4 then
	                          self.tickConst=self.tickConst+self.tickConst*2
	                      end
	                  -- end

	                  -- if(self.tickConst>=60)then
	                  --     base:removeFromNeedRefresh(self)
	                  --     self:playEndEffect()
	                  -- end
	              end
	              if self.endIdx>0 and (self.haloPos==self.endIdx) and self.tickIndex~=self.count then
	                  self:stopPlay()
	              end
	          end


	      end
	    elseif self.state == 3 then
	      self.haloPos=self.endIdx
	      self:stopPlay()
	    end
	end
    
   
end

function acJunzipaisongDialog:stopPlay()
	self.isPlay = false
    -- base:removeFromNeedRefresh(self)
    self:playEndEffect()
end

function  acJunzipaisongDialog:playEndEffect()
    local needHeight2 = 150
    local needHeight3 = 40
    local needHeight4 = 10
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
      needHeight2 =100
      needHeight3 =0
      needHeight4 =0
  end
    local bgSize=self.iconList[self.haloPos]:getContentSize()
    local item=self.itemList[self.haloPos]

    local tx,ty=self.iconList[self.haloPos]:getPosition()
    self.halo:setPosition(tx,ty)

    self.rewardIconBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    self.rewardIconBg:setAnchorPoint(ccp(0.5,0.5))
    local tx,ty=self.iconList[self.haloPos]:getPosition()
    -- tx=tx+bgSize.width/2
    -- ty=ty+bgSize.height/2
    self.rewardIconBg:setPosition(tx,ty)

    local rewardIcon=G_getItemIcon(item ,100, true, self.layerNum)
    -- self.rewardIconList[self.haloPos]:removeChild(rewardIcon,true)
    -- if item.key=="energy" then
    --     rewardIcon = GetBgIcon(item.pic)
    -- else
    --     rewardIcon = CCSprite:createWithSpriteFrameName(item.pic)
    -- end
    rewardIcon:setAnchorPoint(ccp(0.5,0.5))
    rewardIcon:setPosition(ccp(self.rewardIconBg:getContentSize().width/2,self.rewardIconBg:getContentSize().height/2))
    self.rewardIconBg:addChild(rewardIcon)
    self.bgLayer:addChild(self.rewardIconBg,4)
    local scale=100/rewardIcon:getContentSize().width
    rewardIcon:setScale(scale)

    if self.maskSp==nil then
        local function tmpFunc()
        end
        self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
        self.maskSp:setOpacity(255)
        local size=CCSizeMake(G_VisibleSize.width-40,self.bgLayer:getContentSize().height-450)
        self.maskSp:setContentSize(size)
        self.maskSp:setAnchorPoint(ccp(0.5,0))
        self.maskSp:setPosition(ccp(G_VisibleSize.width/2,20))
        self.maskSp:setIsSallow(true)
        self.maskSp:setTouchPriority(-(self.layerNum-1)*20-5)
        self.bgLayer:addChild(self.maskSp,3)
    else
        self.maskSp:setVisible(true)
        self.maskSp:setPosition(ccp(G_VisibleSize.width/2,20))
    end

    if self.confirmBtn==nil then
        local function hideMask()
            if self then
                -- self.bgLayer:removeChild(self.rewardIconBg,true)

                self.rewardIconBg:removeFromParentAndCleanup(true)
                self.rewardIconBg=nil

                if self.maskSp then
                    self.maskSp:setPosition(ccp(10000,0))
                    self.maskSp:setVisible(false)
                end
                if self.confirmBtn then
                    self.confirmBtn:setEnabled(false)
                    self.confirmBtn:setVisible(false)
                end
                -- if self.halo then
                --     self.halo:setVisible(false)
                -- end
                if self.nameLb then
                    self.nameLb:setVisible(false)
                end
                if self.itemDescLb then
                    self.itemDescLb:setVisible(false)
                end

                if self.reward then
			        local str=G_showRewardTip({self.reward},false)
			      	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
			    end
		        self:refresh()
            end
        end
        self.confirmBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",hideMask,4,getlocal("confirm"),25)
        self.confirmBtn:setAnchorPoint(ccp(0.5,0.5))
        local boxSpMenu3=CCMenu:createWithItem(self.confirmBtn)
        boxSpMenu3:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2-180))
        boxSpMenu3:setTouchPriority(-(self.layerNum-1)*20-6)
        self.maskSp:addChild(boxSpMenu3,2)

        self.confirmBtn:setEnabled(false)
        self.confirmBtn:setVisible(false)
    else
        self.confirmBtn:setEnabled(false)
        self.confirmBtn:setVisible(false)
    end

    if self.nameLb==nil then
        self.nameLb=GetTTFLabel(item.name.." x"..item.num,25)
        self.nameLb:setAnchorPoint(ccp(0.5,1))
        self.nameLb:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2+10+needHeight3))
        self.maskSp:addChild(self.nameLb,2)
        self.nameLb:setVisible(false)
    else
        self.nameLb:setString(item.name.." x"..item.num)
        self.nameLb:setVisible(false)
    end
    if self.itemDescLb==nil then
        self.itemDescLb=GetTTFLabelWrap(getlocal(item.desc),25,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        self.itemDescLb:setAnchorPoint(ccp(0.5,0.5))
        self.itemDescLb:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2-70+needHeight4))
        self.maskSp:addChild(self.itemDescLb,2)
        self.itemDescLb:setVisible(false)
    else
        self.itemDescLb:setString(getlocal(item.desc))
        self.itemDescLb:setVisible(false)
    end

    local function playEndCallback()
    	
        self.touchDialogBg:setIsSallow(false) 

        if self.confirmBtn then
            self.confirmBtn:setEnabled(true)
            self.confirmBtn:setVisible(true)
        end
        
        if self.touchEnabledSp then
            self.touchEnabledSp:setVisible(false)
            self.touchEnabledSp:setPosition(ccp(10000,0))
        end
        if self.acRoulette5Dialog then
            self.acRoulette5Dialog.canClickTab=true
        end

        if self.nameLb then
            self.nameLb:setVisible(true)
        end
        if self.itemDescLb then
        	self.itemDescLb:setVisible(true)
        end
    end

    local delay1=CCDelayTime:create(0.3)
    local scale1=CCScaleTo:create(0.4,150/rewardIcon:getContentSize().width/scale)
    local scale2=CCScaleTo:create(0.4,100/rewardIcon:getContentSize().width/scale)
    -- local tx,ty=self.playBtnBg:getPosition()
    local tx,ty=self.maskSp:getPosition()
    local mvTo=CCMoveTo:create(0.3,ccp(tx,ty+self.maskSp:getContentSize().height/2+needHeight2))
    local scale3=CCScaleTo:create(0.1,200/rewardIcon:getContentSize().width/scale)
    local scale4=CCScaleTo:create(0.2,120/rewardIcon:getContentSize().width/scale)
    local delay2=CCDelayTime:create(0.2)
    local callFunc=CCCallFuncN:create(playEndCallback)
    
    local acArr=CCArray:create()
    acArr:addObject(delay1)
    -- acArr:addObject(scale1)
    -- acArr:addObject(scale2)
    acArr:addObject(mvTo)
    acArr:addObject(scale3)
    acArr:addObject(scale4)
    acArr:addObject(delay2)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.rewardIconBg:runAction(seq)
end

function acJunzipaisongDialog:refresh()
  if self.lotteryOneBtn then
    self.lotteryOneBtn:setEnabled(true)
  end
  if self.lotteryTenBtn then
    self.lotteryTenBtn:setEnabled(true)
  end
  self:updateBtnShow()
end

function acJunzipaisongDialog:tick()
	local istoday = acJunzipaisongVoApi:isToday()
	if istoday ~= self.isToday then
		if self then
			self:updateBtnShow()
			self.isToday = istoday
			acJunzipaisongVoApi:updateShow()
		end
	end

    if self.timeLb then
        local acVo = acJunzipaisongVoApi:getAcVo()
        if acVo then
            G_updateActiveTime(acVo,self.timeLb)
        end
    end
end

function acJunzipaisongDialog:update()
  local acVo = acJunzipaisongVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    end
  end 
end
function acJunzipaisongDialog:dispose( ... )
	self.isPlay = nil
	self.tv = nil
	self.isToday = nil
	self.iconList={}
	self.itemList={}
  self.timeLb=nil
	self = nil
end