acFeixutansuoNewTab1={}

function acFeixutansuoNewTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.isToday=nil
	self.heightTab={}
	self.rewardList={}

	self.citySp = {}
  CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  spriteController:addPlist("public/acNewYearsEva.plist")
  spriteController:addTexture("public/acNewYearsEva.png")
  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
  CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	return nc
end

function acFeixutansuoNewTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.isToday=acFeixutansuoVoApi:isToday()
	self:initLayer1()
	return self.bgLayer
end
function acFeixutansuoNewTab1:initLayer1( ... )
  local function onRechargeChange(event,data)
    self:updateVipNUm()
    self:updateShowBtn()
  end
  self.fxtsListener=onRechargeChange
  eventDispatcher:addEventListener("acFeixutansuo.recharge",onRechargeChange)
  local addH1=0
  if G_isIphone5() == true then
    addH1=30
  end
	local function bgClick()
  	end
  
  local w = G_VisibleSizeWidth - 50 -- 背景框的宽度
  local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
  backSprie:setContentSize(CCSizeMake(w, 200))
  backSprie:setAnchorPoint(ccp(0.5,0))
  backSprie:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 365-addH1))
  self.bgLayer:addChild(backSprie)
  
  local function touch(tag,object)
    PlayEffect(audioCfg.mouseClick)
    local tabStr={};
    local tabColor ={};
    local td=smallDialog:new()
    tabStr = {"\n",getlocal("acFeixutansuoNew_tip4"),"\n",getlocal("acFeixutansuoNew_tip3"),"\n",getlocal("acFeixutansuoNew_tip2"),"\n",getlocal("acFeixutansuoNew_tip1"),"\n"}
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil})
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

  local acVo = acFeixutansuoVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,25)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 150))
  backSprie:addChild(messageLabel)
  self.timeLb=messageLabel
  self:updateAcTime()

  local aid,tankID = acFeixutansuoVoApi:getTankID()
  local function showTankInfo( ... )
  	tankInfoDialog:create(nil,tankID,self.layerNum+1, nil)
  end


  local version = acFeixutansuoVoApi:getVersion()
  if version >9 then
    if  version<14 then
      if version  ==10 then
        version = 1
      elseif version ==11 then
        version = 2
      elseif version ==12 then
        version = 3
      elseif version ==13 then
        version = 4
      end
    elseif version >= 14 then
      if version ==14 then
        version = 5
      elseif version ==15 then
        version = 6
      elseif version ==16 then
        version = 7
      elseif version ==17 then
        version = 8
      elseif version >=18 then
        version = 9        
      end
    end
  end
  local iconLeft
  local iconPaoGuan = nil
  local iconPosW=10
  if version ==nil or version<5 then
        if version ==1 or version ==nil then
        	 iconLeft = "t10054_1.png"
        elseif version ==2 then
        	 iconLeft = "t10044_1.png"
        elseif version ==3 then
        	 iconLeft = "t10064_1.png"
        elseif version ==4 then
        	 iconLeft = "t10074_1.png"
        end
  elseif version >=5 then
        if version ==5 then
        	 iconLeft = "t10083_1.png"
        	 iconPosW=-10
        elseif version ==6 then
        	 iconLeft = "t10094_1.png"
        	 iconPaoGuan = "t10094_1_1.png"
        	 iconPosW= -30
        elseif version ==7 then
        	 iconLeft = "t10114_1.png"
        	 iconPaoGuan = "t10114_1_1.png"
        	 iconPosW= -20
        elseif version ==8 then
        	 iconLeft = "t10124_1.png"
        	 iconPaoGuan = "t10124_1_1.png"
        	 iconPosW= -20
        elseif version >=9 then
           iconLeft = "t10134_1.png"
           iconPaoGuan = "t10134_1_1.png"
           iconPosW= -20
        end
  end
  local icon = LuaCCSprite:createWithSpriteFrameName(iconLeft,showTankInfo)
  icon:setTouchPriority(-(self.layerNum-1)*20-5)
  icon:setAnchorPoint(ccp(0,0.5))

  icon:setPosition(iconPosW,80)
  backSprie:addChild(icon)

  if iconPaoGuan then
  	local paoGuan = CCSprite:createWithSpriteFrameName(iconPaoGuan)
  	paoGuan:setAnchorPoint(ccp(0.5,0.5))
  	paoGuan:setPosition(ccp(icon:getContentSize().width*0.5,icon:getContentSize().height*0.5))
  	icon:addChild(paoGuan)
  end

  local upLb = nil 
    if version ==nil or version <5 then
        	if version ==1 or version ==nil then
        		upLb = getlocal("activity_feixutansuo_content",{getlocal(tankCfg[tankID].name)})
        	elseif version ==2 then
        		upLb = getlocal("activity_feixutansuo_content2",{getlocal(tankCfg[tankID].name)})
        	elseif version ==3 then
        		upLb = getlocal("activity_feixutansuo_content3",{getlocal(tankCfg[tankID].name)})
        	elseif version ==4 then
        		upLb = getlocal("activity_feixutansuo_content4",{getlocal(tankCfg[tankID].name)})
          end
    elseif version >=5 then
        	if version ==5 then
        		upLb = getlocal("activity_feixutansuo_content5",{getlocal(tankCfg[tankID].name)})
        	elseif version ==6 then
        		upLb = getlocal("activity_feixutansuo_content6",{getlocal(tankCfg[tankID].name)})
        	elseif version ==7 then
        		upLb = getlocal("activity_feixutansuo_content7",{getlocal(tankCfg[tankID].name)})
        	elseif version ==8 then
        		upLb = getlocal("activity_feixutansuo_content8",{getlocal(tankCfg[tankID].name)})
          elseif version >=9 then
            upLb = getlocal("activity_feixutansuo_content9",{getlocal(tankCfg[tankID].name)})
        	end
    end

  local desTv, desLabel = G_LabelTableView(CCSizeMake(w-110, 110),upLb,25,kCCTextAlignmentLeft)
  backSprie:addChild(desTv)
  desTv:setPosition(ccp(170,10))
  desTv:setAnchorPoint(ccp(0,0))
  desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  desTv:setMaxDisToBottomOrTop(100)

  local addH2=0
  if G_isIphone5() == true then
    addH2=65
  end
    self.background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	self.background:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,160))
	self.background:setAnchorPoint(ccp(0.5,1))
	self.background:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 370-addH2))
	self.bgLayer:addChild(self.background)

	local titleLb = GetTTFLabelWrap(getlocal("rewardRecord"),25,CCSizeMake(self.background:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	titleLb:setAnchorPoint(ccp(0,1))
	titleLb:setPosition(10,self.background:getContentSize().height-10)
	self.background:addChild(titleLb)

	self.noTansuoLb = GetTTFLabelWrap(getlocal("activity_feixutansuo_noReward"),25,CCSizeMake(self.background:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.noTansuoLb:setAnchorPoint(ccp(0.5,0.5))
	self.noTansuoLb:setPosition(self.background:getContentSize().width/2,self.background:getContentSize().height/2)
	self.background:addChild(self.noTansuoLb)

	self:updateShowTv()

	local mapHeight
  local desbgH=270
  if G_isIphone5() == true then
  	mapHeight = G_VisibleSizeHeight - 640
    desbgH=280
  else
  	mapHeight = G_VisibleSizeHeight - 535
    -- desbgH=270
  end

  local function nilFunc()
  end
  local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
  descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,desbgH))
  descBg:setPosition(self.bgLayer:getContentSize().width/2,mapHeight)
  descBg:setAnchorPoint(ccp(0.5,1))
  self.bgLayer:addChild(descBg)

  local goldLineSprite1 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
  goldLineSprite1:setAnchorPoint(ccp(0.5,1))
  goldLineSprite1:setPosition(ccp(descBg:getContentSize().width/2,descBg:getContentSize().height-5))
  descBg:addChild(goldLineSprite1)

  local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("orangeMask.png",CCRect(20,0,552,42),nilFunc)
  titleBg:setContentSize(CCSizeMake(descBg:getContentSize().width,40))
  titleBg:setAnchorPoint(ccp(0.5,1))
  titleBg:setPosition(descBg:getContentSize().width/2,descBg:getContentSize().height-25)
  descBg:addChild(titleBg)
  local limitLb = GetTTFLabelWrap(getlocal("limitedTask"),25,CCSizeMake(540,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  titleBg:addChild(limitLb)
  limitLb:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2)

  self.commomReward={}
  self.vipReward={}
  for i=1,4 do
    local rewardCfg = acFeixutansuoVoApi:getRewardByID(i)
    for k,v in pairs(rewardCfg) do
      local flag=true
      for kk,vv in pairs(self.commomReward) do
        if tonumber(v.num)==tonumber(vv.num) and v.key==vv.key then
          flag=false
          break
        end
      end
      if flag then
        table.insert(self.commomReward,v)
      end
      if i==4 then
        table.insert(self.vipReward,v)
      end
    end
  end

  local function touchInfoItem(idx)
    if G_checkClickEnable()==false then
      do
          return
      end
    else
      base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acFeixutansuoNewSmallDialog"
    local td=acFeixutansuoNewSmallDialog:new()
    local rewardList={}
    local title=getlocal("taskReward")
    local desStr = getlocal("acFeixutansuoNew_canReward")
    local dialog=td:init("PanelPopup.png",CCSizeMake(550,650),nil,false,false,self.layerNum+1,self.commomReward,self.vipReward,title,desStr,getlocal("commonDonate"),getlocal("vipDonate"))
    sceneGame:addChild(dialog,self.layerNum+1)
  end
  local infoItem = GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",touchInfoItem,11,nil,nil)
  local infoMenu=CCMenu:createWithItem(infoItem)
  infoMenu:setPosition(ccp(descBg:getContentSize().width-60,descBg:getContentSize().height-100))
  infoMenu:setTouchPriority(-(self.layerNum-1)*20-4)
  descBg:addChild(infoMenu)

  local buildingBg=CCSprite:createWithSpriteFrameName("map_base_building_4.png")
  buildingBg:setAnchorPoint(ccp(0,0.5))
  buildingBg:setPosition(15,(descBg:getContentSize().height-80)/2)
  descBg:addChild(buildingBg)
  self:addFireAction(buildingBg)

  local buildingDes1=GetTTFLabel(getlocal("acFeixutansuoNew_des1"),23)
  buildingDes1:setAnchorPoint(ccp(0,0))
  buildingDes1:setPosition(ccp(180,(descBg:getContentSize().height-80)/2+25))
  descBg:addChild(buildingDes1,1)
  local buildingDes2=GetTTFLabelWrap(getlocal("acFeixutansuoNew_des2"),23,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  buildingDes2:setAnchorPoint(ccp(0,1))
  buildingDes2:setPosition(180,(descBg:getContentSize().height-80)/2+15)
  descBg:addChild(buildingDes2,1)


	local gemCost=acFeixutansuoVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
	local oneGems=gemCost       --一次抽奖需要金币
	local tenGems=acFeixutansuoVoApi:getLotteryTenCost()      --十次抽奖需要金币
	local vipCost = acFeixutansuoVoApi:getVipCost()
	local vipTotal = acFeixutansuoVoApi:getVipTansuoTotal()
	local vipHadNum = acFeixutansuoVoApi:getVipHadTansuoNum()

      local leftPosX=self.bgLayer:getContentSize().width/2-200
      local centerPosX = self.bgLayer:getContentSize().width/2
      local rightPosX=self.bgLayer:getContentSize().width/2+200

      local lbY=200-70
      if G_isIphone5() == true then
        lbY=200-35
      end
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


      local goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
      goldSp2:setAnchorPoint(ccp(0,0.5))
      goldSp2:setPosition(ccp(centerPosX,lbY))
      self.bgLayer:addChild(goldSp2)
      goldSp2:setScale(1.5)

      self.gemsLabel2=GetTTFLabel(tenGems,25)
      self.gemsLabel2:setAnchorPoint(ccp(1,0.5))
      self.gemsLabel2:setPosition(ccp(centerPosX,lbY))
      self.bgLayer:addChild(self.gemsLabel2,1)


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

      -- self.vipNum = GetTTFLabel("("..getlocal("scheduleChapter",{vipHadNum,vipTotal})..")",25)
      -- self.vipNum:setAnchorPoint(ccp(0.5,0.5))
      -- self.vipNum:setPosition(rightPosX,iconY-20)
      -- self.bgLayer:addChild(self.vipNum)
      self:updateVipNUm()
  	  self:updateShowBtn()
end

function acFeixutansuoNewTab1:updateShowBtn()
	local free = 0
	if acFeixutansuoVoApi:isToday() == true then
		free = 1
	end
	local gemCost=acFeixutansuoVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
	local oneGems=gemCost       --一次抽奖需要金币
	local tenGems=acFeixutansuoVoApi:getLotteryTenCost()      --十次抽奖需要金币
	local vipCost = acFeixutansuoVoApi:getVipCost()
	local vipTotal = acFeixutansuoVoApi:getVipTansuoTotal()
	local vipHadNum = acFeixutansuoVoApi:getVipHadTansuoNum()

	  local leftPosX=self.bgLayer:getContentSize().width/2-200
	  local centerPosX = self.bgLayer:getContentSize().width/2
	  local rightPosX=self.bgLayer:getContentSize().width/2+200

	  local lbY=200
      local iconY = 150
      local btnY = 70
      if G_isIphone5() == true then
        btnY=90
    end

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
            local vipTotal = acFeixutansuoVoApi:getVipTansuoTotal()
          local vipHadNum = acFeixutansuoVoApi:getVipHadTansuoNum()
				if acFeixutansuoVoApi:isToday() == true then
					free = 1
				end
	          local num
	          if tag==1 or tag==4 then
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
	        		if vipHadNum>=vipTotal then
	        			local function callBack() --充值
					        vipVoApi:showRechargeDialog(self.layerNum+1)
  					    end
                local desStr
                if vipTotal==0 then
                  desStr = getlocal("activity_feixutansuo_NoVip")
                else
                  desStr = getlocal("acFeixutansuoNew_vipDes1")
                end
                local tsD=smallDialog:new()
                tsD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),desStr,nil,self.layerNum+1)
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
	                
	                if (tag==1 or tag==4) and free == 1 then
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
	                if sData.data["feixutansuo"] then
	                 local awardData=sData.data["feixutansuo"]["clientReward"]
	                  local nameStr 
	                  local content = {}
	                  local chat = false
	                  local aid,tankID = acFeixutansuoVoApi:getTankID()
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
	                  if sData.data["feixutansuo"]["location"] then
	                  	acFeixutansuoVoApi:updateShowCityID(sData.data["feixutansuo"]["location"])
	                  end
	                  if sData.data["feixutansuo"]["list"] then
	                  	acFeixutansuoVoApi:setRewardList(sData.data["feixutansuo"]["list"])
	                  end
	                  
	                  if tag==3 then
	                  	acFeixutansuoVoApi:addVipHadTansuoNum(1)
	                  end

	                  local function confirmHandler(index)
	                  	if free == 0 then
		                  	acFeixutansuoVoApi:updateLastTime()
		                  	self.isToday=acFeixutansuoVoApi:isToday()
		                  	acFeixutansuoVoApi:updateShow()
		                end
		                  self:updateVipNUm()
		                  self:updateShowBtn()
		                  self:updateShowTv()
                      end
                      smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,true)
	                  
	                  if chat == true then
	                      --聊天公告
                      local paramTab={}
                      paramTab.functionStr="feixutansuo"
                      paramTab.addStr="i_also_want"
			                local nameData={key=tankCfg[tankID].name,param={}}
			                local message={key="activity_feixutansuo_tansuo_chatSystemMessage",param={playerVoApi:getPlayerName(),nameData}}
			                chatVoApi:sendSystemMessage(message,paramTab)
		            	end
	                end
	              end
	           end
	         if tag == 3 then
	         	local function sureClick( ... )
	         		socketHelper:activityFeixutansuoTansuo(num,lotteryCallback)
	         	end
	         	local tsD=smallDialog:new()
				tsD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureClick,getlocal("dialog_title_prompt"),getlocal("acFeixutansuoNew_vipDes2",{vipCost,vipTotal-vipHadNum}),nil,self.layerNum+1)
	         else
	         	socketHelper:activityFeixutansuoTansuo(num,lotteryCallback)
	         end
	      end	 	
	   
		if self.lotteryTenBtn == nil then
			self.lotteryTenBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnCallback,2,getlocal("donateTenNum"),25)
		    self.lotteryTenBtn:setAnchorPoint(ccp(0.5,0.5))
		    local lotteryMenu1=CCMenu:createWithItem(self.lotteryTenBtn)
		    lotteryMenu1:setPosition(ccp(centerPosX,btnY))
		    lotteryMenu1:setTouchPriority(-(self.layerNum-1)*20-3)
		    self.bgLayer:addChild(lotteryMenu1,2)
		end
	    
		if self.vipBtn == nil then
		    self.vipBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnCallback,3,getlocal("vipDonate"),25)
		 	self.vipBtn:setAnchorPoint(ccp(0.5,0.5))
			local vipMenu=CCMenu:createWithItem(self.vipBtn)
			vipMenu:setPosition(ccp(rightPosX,btnY))
			vipMenu:setTouchPriority(-(self.layerNum-1)*20-3)
			self.bgLayer:addChild(vipMenu,2)
		end


    if self.lotteryOneBtn1 == nil then
        self.lotteryOneBtn1=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",btnCallback,1,getlocal("daily_lotto_tip_2"),25)
        -- self.lotteryOneBtn1:setScale(btnScale)
        self.lotteryOneBtn1:setAnchorPoint(ccp(0.5,0.5))
        local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn1)
        lotteryMenu:setPosition(leftPosX,btnY)
        lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
        self.bgLayer:addChild(lotteryMenu,2)

        local needName = "alliance_scene_donate"
        if G_getCurChoseLanguage() =="ko" then
           needName ="commonDonate"
        end
        self.lotteryOneBtn2=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnCallback,4,getlocal(needName),25)
        -- self.lotteryOneBtn2:setScale(btnScale)
        self.lotteryOneBtn2:setAnchorPoint(ccp(0.5,0.5))
        local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn2)
        lotteryMenu:setPosition(leftPosX,btnY)
        lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
        self.bgLayer:addChild(lotteryMenu,2)
  end

	

	if free == 0 then
  		self.lotteryTenBtn:setEnabled(false)
  		self.vipBtn:setEnabled(false)
      self.lotteryOneBtn1:setVisible(true)
      self.lotteryOneBtn2:setVisible(false)
	else
  		self.lotteryTenBtn:setEnabled(true)
      self.lotteryOneBtn1:setVisible(true)
      self.lotteryOneBtn2:setVisible(true)
  		-- if vipTotal>0 and vipHadNum>=vipTotal then
  		-- 	 self.vipBtn:setEnabled(false)
  		-- else
  			self.vipBtn:setEnabled(true)
  		-- end
	end

end
function acFeixutansuoNewTab1:updateVipNUm()
	local oneGems=acFeixutansuoVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
	local tenGems=acFeixutansuoVoApi:getLotteryTenCost()      --十次抽奖需要金币
	local vipCost = acFeixutansuoVoApi:getVipCost()
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
	-- if self.vipNum then
	-- 	local vipTotal = acFeixutansuoVoApi:getVipTansuoTotal()
	-- 	local vipHadNum = acFeixutansuoVoApi:getVipHadTansuoNum()
	-- 	self.vipNum:setString("("..getlocal("scheduleChapter",{vipHadNum,vipTotal})..")")
	-- end
end

function acFeixutansuoNewTab1:updateShowTv()
	self.rewardList = acFeixutansuoVoApi:getRewardList()
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

function acFeixutansuoNewTab1:eventHandler1(handler,fn,idx,cel)
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

function acFeixutansuoNewTab1:addFireAction(buildSp)
  local pzFrameName="bf1.png"
  local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
  -- metalSp:setScale(1.3)
  metalSp:setPosition(ccp(buildSp:getContentSize().width*0.70,buildSp:getContentSize().height*0.45))
  local pzArr=CCArray:create()
  for kk=1,11 do
    local nameStr="bf"..kk..".png"
    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
    pzArr:addObject(frame)
  end
  local animation=CCAnimation:createWithSpriteFrames(pzArr)
  animation:setDelayPerUnit(0.08)
  local animate=CCAnimate:create(animation)
  local repeatForever=CCRepeatForever:create(animate)
  metalSp:runAction(repeatForever)
  buildSp:addChild(metalSp)
end


function acFeixutansuoNewTab1:tick()
	local today=acFeixutansuoVoApi:isToday()
	if self.isToday~=today then
		acFeixutansuoVoApi:updateVipHadTansuoNum()
		self:updateVipNUm()
		self:updateShowBtn()
		self.isToday=today
	end
  self:updateAcTime()
end

function acFeixutansuoNewTab1:updateAcTime()
  local acVo=acFeixutansuoVoApi:getAcVo()
  if acVo and self.timeLb then
    G_updateActiveTime(acVo,self.timeLb)
  end
end

function acFeixutansuoNewTab1:dispose()
  self.timeLb=nil
  eventDispatcher:removeEventListener("acFeixutansuo.recharge",self.fxtsListener)
	spriteController:removePlist("public/acNewYearsEva.plist")
  spriteController:removeTexture("public/acNewYearsEva.png")
end