acRecyclingTab1={}

function acRecyclingTab1:new(layerNum)
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum
	self.bgLayer=nil
	self.isToday=nil
	self.heightTab={}
	self.rewardList={}
	self.citySp = {}

	return nc
end

function acRecyclingTab1:init( )
	self.bgLayer=CCLayer:create()
	self.isToday=acRecyclingVoApi:isToday()
	self:initLayer1()
	return self.bgLayer	
end

function acRecyclingTab1:initLayer1( ... )
	local function bgClick()
  	end
  
  local w = G_VisibleSizeWidth - 50 -- 背景框的宽度
  local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
  backSprie:setContentSize(CCSizeMake(w, 200))
  backSprie:setAnchorPoint(ccp(0.5,0))
  backSprie:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 365))
  self.bgLayer:addChild(backSprie)
  
  local function touch(tag,object)
    PlayEffect(audioCfg.mouseClick)
    local tabStr={};
    local tabColor ={};
    local td=smallDialog:new()
    tabStr = {"\n",getlocal("activity_feixutansuo_tab1_tip6"),"\n",getlocal("activity_feixutansuo_tab1_tip5"),"\n",getlocal("activity_feixutansuo_tab1_tip4"),"\n",getlocal("activity_feixutansuo_tab1_tip3"),"\n",getlocal("activity_feixutansuo_tab1_tip2"),"\n",getlocal("activity_feixutansuo_tab1_tip1"),"\n"}
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorRed,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil})
    sceneGame:addChild(dialog,self.layerNum+1)
  end

  w = w - 10 -- 按钮的x坐标
  local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
  menuItemDesc:setAnchorPoint(ccp(1,1))
  menuItemDesc:setScale(0.8)
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(w-10, 190))
  backSprie:addChild(menuDesc)
  
  w = w - menuItemDesc:getContentSize().width

  local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
  acLabel:setAnchorPoint(ccp(0.5,1))
  acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 190))
  backSprie:addChild(acLabel)
  acLabel:setColor(G_ColorGreen)

  local acVo = acRecyclingVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,25)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 150))
  backSprie:addChild(messageLabel)
  self.timeLb=messageLabel
  G_updateActiveTime(acVo,self.timeLb)

  local aid,tankID = acRecyclingVoApi:getTankID()
  local function showTankInfo( ... )
  	tankInfoDialog:create(nil,tankID,self.layerNum+1, nil)
  end


  local version = acRecyclingVoApi:getVersion()
  local iconLeft
  local iconPaoGuan = nil
  local iconPosW=10
  if version ==1 or version ==nil then
  	 iconLeft = "t"..tankID.."_1.png"
  elseif version ==2 then
  	 iconLeft = "t"..tankID.."_1.png"
  -- elseif version ==3 then
  -- 	 iconLeft = "t10064_1.png"
  -- elseif version ==4 then
  -- 	 iconLeft = "t10074_1.png"
  -- elseif version ==5 then
  -- 	 iconLeft = "t10083_1.png"
  -- 	 iconPosW=-10
  -- elseif version ==6 then
  -- 	 iconLeft = "t10094_1.png"
  -- 	 iconPaoGuan = "t10094_1_1.png"
  -- 	 iconPosW= -30
  -- elseif version ==7 then
  -- 	 iconLeft = "t10114_1.png"
  -- 	 iconPaoGuan = "t10114_1_1.png"
  -- 	 iconPosW= -20
  -- elseif version ==8 then
  -- 	 iconLeft = "t10124_1.png"
  -- 	 iconPaoGuan = "t10124_1_1.png"
  -- 	 iconPosW= -20
  end
  local icon = LuaCCSprite:createWithSpriteFrameName(iconLeft,showTankInfo)
  icon:setTouchPriority(-(self.layerNum-1)*20-5)
  icon:setAnchorPoint(ccp(0,0.5))

  local ver = acRecyclingVoApi:getVersion()
  local posX = 20
  if ver ==2 then
    posX =10
  end
  icon:setPosition(iconPosW-posX,80)
  backSprie:addChild(icon)

   local tankBarrel="t"..tankID.."_1_1.png"  --炮管 第6层
   local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
   tankBarrelSP:setPosition(ccp(icon:getContentSize().width*0.5,icon:getContentSize().height*0.5))
   tankBarrelSP:setAnchorPoint(ccp(0.5,0.5))
   icon:addChild(tankBarrelSP)
   
  if iconPaoGuan then
  	local paoGuan = CCSprite:createWithSpriteFrameName(iconPaoGuan)
  	paoGuan:setAnchorPoint(ccp(0.5,0.5))
  	paoGuan:setPosition(ccp(icon:getContentSize().width*0.5,icon:getContentSize().height*0.5))
  	icon:addChild(paoGuan)
  end

  local upLb = nil 
  	if version ==1 or version ==nil then
  		upLb = getlocal("activity_recycling_a10114",{getlocal(tankCfg[tankID].name)})
  	elseif version ==2 then
  		upLb = getlocal("activity_recycling_a10054",{getlocal(tankCfg[tankID].name)})
  	-- elseif version ==3 then
  	-- 	upLb = getlocal("activity_feixutansuo_content3",{getlocal(tankCfg[tankID].name)})
  	-- elseif version ==4 then
  	-- 	upLb = getlocal("activity_feixutansuo_content4",{getlocal(tankCfg[tankID].name)})
  	-- elseif version ==5 then
  	-- 	upLb = getlocal("activity_feixutansuo_content5",{getlocal(tankCfg[tankID].name)})
  	-- elseif version ==6 then
  	-- 	upLb = getlocal("activity_feixutansuo_content6",{getlocal(tankCfg[tankID].name)})
  	-- elseif version ==7 then
  	-- 	upLb = getlocal("activity_feixutansuo_content7",{getlocal(tankCfg[tankID].name)})
  	-- elseif version ==8 then
  	-- 	upLb = getlocal("activity_feixutansuo_content8",{getlocal(tankCfg[tankID].name)})
  	end

  local desTv, desLabel = G_LabelTableView(CCSizeMake(w-110, 110),upLb,25,kCCTextAlignmentLeft)
  backSprie:addChild(desTv)
  desTv:setPosition(ccp(170,10))
  desTv:setAnchorPoint(ccp(0,0))
  desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  desTv:setMaxDisToBottomOrTop(100)


    self.background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	self.background:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,160))
	self.background:setAnchorPoint(ccp(0.5,1))
	self.background:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 370))
	self.bgLayer:addChild(self.background)

	local titleLb = GetTTFLabelWrap(getlocal("activity_feixutansuo_rewardTitle"),25,CCSizeMake(self.background:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	titleLb:setAnchorPoint(ccp(0,1))
	titleLb:setPosition(10,self.background:getContentSize().height-10)
	self.background:addChild(titleLb)

	self.noTansuoLb = GetTTFLabelWrap(getlocal("activity_feixutansuo_noReward"),25,CCSizeMake(self.background:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.noTansuoLb:setAnchorPoint(ccp(0.5,0.5))
	self.noTansuoLb:setPosition(self.background:getContentSize().width/2,self.background:getContentSize().height/2)
	self.background:addChild(self.noTansuoLb)

	self:updateShowTv()

	local mapHeight
	  if G_isIphone5() == true then
	  	mapHeight = G_VisibleSizeHeight - 630
	  else
	  	mapHeight = G_VisibleSizeHeight - 540
	  end

	local mapSp = CCSprite:create("scene/world_map_mi.jpg")
	mapSp:setScaleX((self.bgLayer:getContentSize().width-60)/mapSp:getContentSize().width)
	mapSp:setScaleY(200/mapSp:getContentSize().height)
	mapSp:setAnchorPoint(ccp(0.5,1))
	mapSp:setPosition(self.bgLayer:getContentSize().width/2,mapHeight)
	self.bgLayer:addChild(mapSp)

	for i=1,4 do
		local cityIconStr=""
		local posX --= 120+(i-1)*250
		local posY --= mapSp:getContentSize().height/2-((i-1)%2）*(mapSp:getContentSize().height-140)-20

		local arrowPos
		local aimPos
		local arrow=CCSprite:createWithSpriteFrameName("GuideArow.png")
        arrow:setAnchorPoint(ccp(0.5,0.5))
        mapSp:addChild(arrow)

        local redArrow
		if i == 1 then
			cityIconStr="CheckPointIcon1.png"
			arrow:setRotation(180)
			posX=110
			posY=mapSp:getContentSize().height-80
			arrowPos=ccp(posX,mapSp:getContentSize().height/4+50)
			aimPos=ccp(posX,mapSp:getContentSize().height/4+20)
			arrow:setPosition(arrowPos)

			redArrow=CCSprite:createWithSpriteFrameName("CheckPointArow.png")
			redArrow:setRotation(300)
	        redArrow:setAnchorPoint(ccp(0.5,0.5))
	        redArrow:setPosition(200,180)
	        mapSp:addChild(redArrow)
		elseif i==2 then
			cityIconStr="CheckPointIcon3.png"
			posX=280
			posY=100
			arrow:setRotation(0)
			arrowPos=ccp(posX,mapSp:getContentSize().height/4*3-30)
			aimPos=ccp(posX,mapSp:getContentSize().height/4*3)
			arrow:setPosition(arrowPos)
			redArrow=CCSprite:createWithSpriteFrameName("CheckPointArow.png")
	        redArrow:setAnchorPoint(ccp(0.5,0.5))
	        redArrow:setPosition(400,150)
	        redArrow:setRotation(240)
	        mapSp:addChild(redArrow)
		elseif i==3 then
			cityIconStr="CheckPointIcon7.png"
			posX=560
			posY=mapSp:getContentSize().height-100
			arrow:setRotation(180)
			arrowPos=ccp(posX,mapSp:getContentSize().height/4+20)
			aimPos=ccp(posX,mapSp:getContentSize().height/4-10)
			arrow:setPosition(arrowPos)
			redArrow=CCSprite:createWithSpriteFrameName("CheckPointArow.png")
	        redArrow:setAnchorPoint(ccp(0.5,0.5))
	        redArrow:setPosition(720,200)
	        redArrow:setRotation(300)
	        mapSp:addChild(redArrow)

		elseif i== 4 then
			cityIconStr="CheckPointIcon11.png"
			posX=860
			posY=130
			arrow:setRotation(0)
			arrowPos=ccp(posX,mapSp:getContentSize().height/4*3+40)
			aimPos=ccp(posX,mapSp:getContentSize().height/4*3+10)
			arrow:setPosition(arrowPos)
		end

		local function showArrowAction()
            local mvTo=CCMoveTo:create(0.35,aimPos)
            local mvBack=CCMoveTo:create(0.35,arrowPos)
            local seq=CCSequence:createWithTwoActions(mvTo,mvBack)
            arrow:runAction(CCRepeatForever:create(seq))
        end
        local fadeIn=CCFadeIn:create(0.3)
        --arrow:setOpacity(0)
        local ffunc=CCCallFuncN:create(showArrowAction)
        local fseq=CCSequence:createWithTwoActions(fadeIn,ffunc)
        arrow:runAction(fseq)

		

        local lockPointSp=GraySprite:createWithSpriteFrameName(cityIconStr)
        lockPointSp:setAnchorPoint(ccp(0.5,0.5))
        lockPointSp:setPosition(ccp(posX,posY))
        mapSp:addChild(lockPointSp,5)
        lockPointSp:setScale(0.8)

        local function clickHandler( ... )
        	local rewardCfg = acRecyclingVoApi:getRewardByID(i)
        	-- local content = FormatItem(rewardCfg)
        	local td = acFeixutansuoRewardTip:new()
        	td:init("PanelHeaderPopup.png",getlocal("activity_feixutansuo_tipTitle",{i}),getlocal("activity_feixutansuo_rewardDesc"),rewardCfg,nil,self.layerNum+1)
        end

        local checkPointSp=LuaCCSprite:createWithSpriteFrameName(cityIconStr,clickHandler)
        checkPointSp:setPosition(ccp(posX,posY))
        checkPointSp:setAnchorPoint(ccp(0.5,0.5))
        checkPointSp:setTouchPriority(-(self.layerNum-1)*20-5)
        checkPointSp:setIsSallow(true)
        mapSp:addChild(checkPointSp,4)
        checkPointSp:setScale(0.8)

        self.citySp[i]={}
        self.citySp[i].checkPointSp = checkPointSp
        self.citySp[i].lockPointSp = lockPointSp
        self.citySp[i].arrow = arrow
	end

	self:updateShowMap()

	local gemCost=acRecyclingVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
	local oneGems=gemCost       --一次抽奖需要金币
	local tenGems=acRecyclingVoApi:getLotteryTenCost()      --十次抽奖需要金币
	local vipCost = acRecyclingVoApi:getVipCost()
	local vipTotal = acRecyclingVoApi:getVipTansuoTotal()
	local vipHadNum = acRecyclingVoApi:getVipHadTansuoNum()

      local leftPosX=self.bgLayer:getContentSize().width/2-200
      local centerPosX = self.bgLayer:getContentSize().width/2
      local rightPosX=self.bgLayer:getContentSize().width/2+200

      local lbY=200
      local iconY = 150
      local btnY = 70
      self.goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
      self.goldSp1:setAnchorPoint(ccp(0,0.5))
      self.goldSp1:setPosition(ccp(leftPosX,lbY))
      self.bgLayer:addChild(self.goldSp1)
      self.goldSp1:setScale(1.5)

      self.gemsLabel1=GetTTFLabel(oneGems,25)
      self.gemsLabel1:setAnchorPoint(ccp(1,0.5))
      self.gemsLabel1:setPosition(ccp(leftPosX,lbY))
      self.bgLayer:addChild(self.gemsLabel1,1)

      local iconSP1 = CCSprite:createWithSpriteFrameName("Telescope.png")
      --iconSP1:setScale(0.5)
      iconSP1:setAnchorPoint(ccp(0.5,0.5))
      iconSP1:setPosition(leftPosX,iconY)
      self.bgLayer:addChild(iconSP1)

      local goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
      goldSp2:setAnchorPoint(ccp(0,0.5))
      goldSp2:setPosition(ccp(centerPosX,lbY))
      self.bgLayer:addChild(goldSp2)
      goldSp2:setScale(1.5)

      self.gemsLabel2=GetTTFLabel(tenGems,25)
      self.gemsLabel2:setAnchorPoint(ccp(1,0.5))
      self.gemsLabel2:setPosition(ccp(centerPosX,lbY))
      self.bgLayer:addChild(self.gemsLabel2,1)

       local iconSP2= CCSprite:createWithSpriteFrameName("Telescope.png")
      iconSP2:setAnchorPoint(ccp(0.5,0.5))
      iconSP2:setPosition(centerPosX,iconY)
      self.bgLayer:addChild(iconSP2)


      self.goldSp3=CCSprite:createWithSpriteFrameName("IconGold.png")
      self.goldSp3:setAnchorPoint(ccp(0,0.5))
      self.goldSp3:setPosition(ccp(rightPosX,lbY))
      self.bgLayer:addChild(self.goldSp3)
      self.goldSp3:setScale(1.5)

      self.gemsLabel3=GetTTFLabel(vipCost,25)
      self.gemsLabel3:setAnchorPoint(ccp(1,0.5))
      self.gemsLabel3:setPosition(ccp(rightPosX,lbY))
      self.bgLayer:addChild(self.gemsLabel3,1)

      local vipLbWidth = rightPosX
      if G_getCurChoseLanguage() =="fr" then
      		vipLbWidth = vipLbWidth-20
      end
      local vipIcon = GetTTFLabel(getlocal("vipTitle"),25)
      vipIcon:setAnchorPoint(ccp(0.5,0.5))
      vipIcon:setPosition(vipLbWidth,lbY-35)
      self.bgLayer:addChild(vipIcon)
      vipIcon:setColor(G_ColorYellow)

      self.vipNum = GetTTFLabel("("..getlocal("scheduleChapter",{vipHadNum,vipTotal})..")",25)
      self.vipNum:setAnchorPoint(ccp(0.5,0.5))
      self.vipNum:setPosition(rightPosX,iconY-20)
      self.bgLayer:addChild(self.vipNum)
      self:updateVipNUm()
	  self:updateShowBtn()
end

function acRecyclingTab1:updateShowBtn()
	local free = 0
	if acRecyclingVoApi:isToday() == true then
		free = 1
	end
	local gemCost=acRecyclingVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
	local oneGems=gemCost       --一次抽奖需要金币
	local tenGems=acRecyclingVoApi:getLotteryTenCost()      --十次抽奖需要金币
	local vipCost = acRecyclingVoApi:getVipCost()
	local vipTotal = acRecyclingVoApi:getVipTansuoTotal()
	local vipHadNum = acRecyclingVoApi:getVipHadTansuoNum()

	  local leftPosX=self.bgLayer:getContentSize().width/2-200
	  local centerPosX = self.bgLayer:getContentSize().width/2
	  local rightPosX=self.bgLayer:getContentSize().width/2+200

	  local lbY=200
      local iconY = 150
      local btnY = 70

	 local function btnCallback(tag,object)
	            if G_checkClickEnable()==false then
	                do
	                    return
	                end
	            else
	                base.setWaitTime=G_getCurDeviceMillTime()
	            end 

	          PlayEffect(audioCfg.mouseClick)
	          local free = 0
				if acRecyclingVoApi:isToday() == true then
					free = 1
				end
	          local num
	          if tag==1 then
	            if playerVoApi:getGems()<oneGems and free==1 then
	              GemsNotEnoughDialog(nil,nil,oneGems-playerVoApi:getGems(),self.layerNum+1,oneGems)
	              do return end
	            end
	            if free == 0 then
	            	 num=0
	            else
	            	 num=1
	            end
	           
	          elseif tag==2 then
	            if playerVoApi:getGems()<tenGems then
	              GemsNotEnoughDialog(nil,nil,tenGems-playerVoApi:getGems(),self.layerNum+1,tenGems)
	              do return end
	            end
	            num=10
	        	elseif tag == 3 then
	        		if vipTotal==0 then
	        			local function callBack() --充值
					        vipVoApi:showRechargeDialog(self.layerNum+1)
					    end
					    local tsD=smallDialog:new()
					    tsD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("activity_feixutansuo_NoVip"),nil,self.layerNum+1)
	        			do return end
	        		elseif playerVoApi:getGems()<vipCost then
	         			GemsNotEnoughDialog(nil,nil,vipCost-playerVoApi:getGems(),self.layerNum+1,vipCost)
	              		do return end
	              	end
	              	num=99
	          end
	          
	          local function lotteryCallback(fn,data)
	            local ret,sData=base:checkServerData(data)
	            if ret==true then
	                if sData.data==nil then
	                  do return end
	                end
	                
	                if tag==1 and free == 1 then
	                   playerVoApi:setValue("gems",playerVoApi:getGems()-oneGems)
	                elseif tag==2 then
	                   playerVoApi:setValue("gems",playerVoApi:getGems()-tenGems)
	                elseif tag==3 then
	                   playerVoApi:setValue("gems",playerVoApi:getGems()-vipCost)
	                end

	              --刷新活动数据
	                local tipStr=""
	                local getTank1=false
	                local getTank2=false
	                if sData.data["huiluzaizao"] then
	                 local awardData=sData.data["huiluzaizao"]["clientReward"]
	                  local nameStr 
	                  local content = {}
	                  local chat = false
	                  local aid,tankID = acRecyclingVoApi:getTankID()
	                  if awardData then
	                  	for k,v in pairs(awardData) do
		                    local ptype = v[1]
		                    local pID = v[2]
		                    local num = v[3]
		                    local award = {}
		                    local name,pic,desc,id,index,eType,equipId=getItem(pID,ptype)
		                    award={name=name,num=num,pic=pic,desc=desc,id=id,type=ptype,index=index,key=pID,eType=eType,equipId=equipId}
		                    G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
		                   	table.insert(content,{award=award})
		                    if ptype=="o" and pID==aid then
		                    	chat = true
		                    end
		                  end
		                  --G_showRewardTip(content)
	                  end
	                  if sData.data["huiluzaizao"]["location"] then
	                  	acRecyclingVoApi:updateShowCityID(sData.data["huiluzaizao"]["location"])
	                  end
	                  if sData.data["huiluzaizao"]["list"] then
	                  	acRecyclingVoApi:setRewardList(sData.data["huiluzaizao"]["list"])
	                  end
	                  
	                  if tag==3 then
	                  	acRecyclingVoApi:addVipHadTansuoNum(1)
	                  end

	                  local function confirmHandler(index)
	                  	if free == 0 then
		                  	acRecyclingVoApi:updateLastTime()
		                  	self.isToday=acRecyclingVoApi:isToday()
		                  	acRecyclingVoApi:updateShow()
		                end
	                      self:updateShowMap()
		                  self:updateVipNUm()
		                  self:updateShowBtn()
		                  self:updateShowTv()
                      end
                      smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,true)
	                  
	                  if chat == true then
	                      --聊天公告
			                local nameData={key=tankCfg[tankID].name,param={}}
			                local message={key="activity_recycling_tansuo_chatSystemMessage",param={playerVoApi:getPlayerName(),nameData}}
			                chatVoApi:sendSystemMessage(message)
		            	end
	                end
	              end
	           end
	         if tag == 3 then
	         	local function sureClick( ... )
	         		socketHelper:activityhuiluzaizao(num,lotteryCallback)
	         	end
	         	local tsD=smallDialog:new()
				tsD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureClick,getlocal("dialog_title_prompt"),getlocal("activity_feixutansuo_VipTansuo",{vipCost}),nil,self.layerNum+1)
	         else
	         	socketHelper:activityhuiluzaizao(num,lotteryCallback)
	         end
	      end	 	
	  local strSize2 = 25
    if G_getCurChoseLanguage() =="ru" then
        strSize2 =18
    end 
		if self.lotteryTenBtn == nil then
			self.lotteryTenBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnCallback,2,getlocal("activity_feixutansuo_continuousBtn"),strSize2)
		    self.lotteryTenBtn:setAnchorPoint(ccp(0.5,0.5))
		    local lotteryMenu1=CCMenu:createWithItem(self.lotteryTenBtn)
		    lotteryMenu1:setPosition(ccp(centerPosX,btnY))
		    lotteryMenu1:setTouchPriority(-(self.layerNum-1)*20-3)
		    self.bgLayer:addChild(lotteryMenu1,2)
		end
	    
		if self.vipBtn == nil then
		    self.vipBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnCallback,3,getlocal("activity_feixutansuo_highBtn"),strSize2)
		 	self.vipBtn:setAnchorPoint(ccp(0.5,0.5))
			local vipMenu=CCMenu:createWithItem(self.vipBtn)
			vipMenu:setPosition(ccp(rightPosX,btnY))
			vipMenu:setTouchPriority(-(self.layerNum-1)*20-3)
			self.bgLayer:addChild(vipMenu,2)
		end

	

	if free == 0 then
		self.lotteryOneBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",btnCallback,1,getlocal("daily_lotto_tip_2"),25)
		self.lotteryTenBtn:setEnabled(false)
		self.vipBtn:setEnabled(false)
	else
		self.lotteryOneBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnCallback,1,getlocal("activity_equipSearch_subTitle_1"),25)
		self.lotteryTenBtn:setEnabled(true)
		if vipTotal>0 and vipHadNum>=vipTotal then
			 self.vipBtn:setEnabled(false)
		else
			self.vipBtn:setEnabled(true)
		end
	end

	self.lotteryOneBtn:setAnchorPoint(ccp(0.5,0.5))
	local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn)
	lotteryMenu:setPosition(leftPosX,btnY)
	lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
	self.bgLayer:addChild(lotteryMenu,2)
end

function acRecyclingTab1:updateVipNUm()
	local oneGems=acRecyclingVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
	local tenGems=acRecyclingVoApi:getLotteryTenCost()      --十次抽奖需要金币
	local vipCost = acRecyclingVoApi:getVipCost()
	local playerGems = playerVoApi:getGems()
	if oneGems>playerGems and self.gemsLabel1 then
		self.gemsLabel1:setColor(G_ColorRed)
	else
		self.gemsLabel1:setColor(G_ColorWhite)
	end
	if tenGems>playerGems and self.gemsLabel2 then
		self.gemsLabel2:setColor(G_ColorRed)
	else
		self.gemsLabel2:setColor(G_ColorWhite)
	end
	if vipCost>playerGems and self.gemsLabel3 then
		self.gemsLabel3:setColor(G_ColorRed)
	else
		self.gemsLabel3:setColor(G_ColorWhite)
	end
	if self.vipNum then
		local vipTotal = acRecyclingVoApi:getVipTansuoTotal()
		local vipHadNum = acRecyclingVoApi:getVipHadTansuoNum()
		self.vipNum:setString("("..getlocal("scheduleChapter",{vipHadNum,vipTotal})..")")
	end
end

function acRecyclingTab1:updateShowTv()
	self.rewardList = acRecyclingVoApi:getRewardList()
	if self.rewardList == nil then
		do return end
	end

	if SizeOfTable(self.rewardList)<=0 then
		self.noTansuoLb:setVisible(true)
	else
		self.noTansuoLb:setVisible(false)

		if self.tv1~=nil then
			self.tv1:reloadData()
		else

			local function callBack(...)

				return self:eventHandler1(...)
			end
			local hd= LuaEventHandler:createHandler(callBack)
		 	self.tv1=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(self.background:getContentSize().width-20,self.background:getContentSize().height-50),nil)
			self.tv1:setAnchorPoint(ccp(0,0))
			self.tv1:setPosition(ccp(10,10))
			self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
			self.tv1:setMaxDisToBottomOrTop(100)
			self.background:addChild(self.tv1,1)
		end
	end
end
function acRecyclingTab1:updateShowMap()
	local showIndex = acRecyclingVoApi:getShowCityID()
	for k,v in pairs(self.citySp) do
		if k == showIndex then
			tolua.cast(v.lockPointSp,"CCNode"):setVisible(false)
			tolua.cast(v.arrow,"CCNode"):setVisible(true)
		else
			tolua.cast(v.lockPointSp,"CCNode"):setVisible(true)
			tolua.cast(v.arrow,"CCNode"):setVisible(false)
		end
	end
end

function acRecyclingTab1:eventHandler1(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if SizeOfTable(self.rewardList) >=10 then
			return 10
		else
			return SizeOfTable(self.rewardList)
		end
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(105,105)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local index = SizeOfTable(self.rewardList)-idx
	    local rewardCfg = self.rewardList[index]
	    local ptype = rewardCfg[1]
	    local pID = rewardCfg[2]
	    local num = rewardCfg[3]
	    local award = {}
	    local name,pic,desc,id,index,eType,equipId=getItem(pID,ptype)
	    award={name=name,num=num,pic=pic,desc=desc,id=id,type=ptype,index=index,key=pID,eType=eType,equipId=equipId}
	    if award then
           local icon,iconScale = G_getItemIcon(award,100,true,self.layerNum,nil,self.tv1)
            icon:setTouchPriority(-(self.layerNum-1)*20-5)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(10,50)
            cell:addChild(icon)

            local num = GetTTFLabel("x"..award.num,25/iconScale)
            num:setAnchorPoint(ccp(1,0))
            num:setPosition(icon:getContentSize().width-10,10)
            icon:addChild(num)
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

function acRecyclingTab1:tick()
	local today=acRecyclingVoApi:isToday()
	if self.isToday~=today then
		acRecyclingVoApi:updateVipHadTansuoNum()
		self:updateVipNUm()
		self:updateShowBtn()
		self.isToday=today
	end
  if self.timeLb then
    local acVo = acRecyclingVoApi:getAcVo()
    G_updateActiveTime(acVo,self.timeLb)
  end
end
function acRecyclingTab1:dispose()
	--self.tv1 = nil
    self.bgLayer=nil
  self.isToday=nil
  self.heightTab=nil
  self.rewardList=nil
  self.citySp = nil
  self.timeLb=nil
end