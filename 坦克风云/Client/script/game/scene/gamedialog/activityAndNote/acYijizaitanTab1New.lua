acYijizaitanTab1New={}

function acYijizaitanTab1New:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.isToday=nil
	self.heightTab={}
	self.rewardList={}
	self.state = 0 
	self.citySp = {}
	self.oldShowIndex = 1
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addPlist("serverWar/serverWar.plist")
	spriteController:addTexture("serverWar/serverWar.pvr.ccz")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	return nc
end

function acYijizaitanTab1New:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.isToday=acYijizaitanVoApi:isToday()

	local function onRechargeChange(event,data)
		self:updateVipNUm()
		self:updateShowBtn()
	end
	self.activityListener=onRechargeChange
	eventDispatcher:addEventListener("acYijizaitan.recharge",onRechargeChange)

	self:initLayer1()
	return self.bgLayer
end

function acYijizaitanTab1New:initLayer1( ... )
	local function bgClick()
	end
	local bsSizeH
	local startH = G_VisibleSizeHeight - 170
	if (G_isIphone5())then
		bsSizeH=200
	else
		bsSizeH=150
	end
	local w = G_VisibleSizeWidth - 50 -- 背景框的宽度
	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
	backSprie:setContentSize(CCSizeMake(w, bsSizeH))
	backSprie:setAnchorPoint(ccp(0.5,1))
	backSprie:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 170))
	self.bgLayer:addChild(backSprie)
  
	local function touch(tag,object)
		PlayEffect(audioCfg.mouseClick)
		local tabStr={};
		local tabColor ={};
		local td=smallDialog:new()
		tabStr = {"\n",getlocal("activity_yijizaitanNew_tip4"),"\n",getlocal("activity_yijizaitanNew_tip3"),"\n",getlocal("activity_yijizaitanNew_tip2"),"\n",getlocal("activity_yijizaitanNew_tip1"),"\n"}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,nil,nil,nil,nil,nil,nil,nil})
		sceneGame:addChild(dialog,self.layerNum+1)
	end

	w = w - 10 -- 按钮的x坐标
	local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,1))
	menuItemDesc:setScale(0.8)
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(w-10, bsSizeH-10))
	backSprie:addChild(menuDesc)

	w = w - menuItemDesc:getContentSize().width

	local centerW = backSprie:getContentSize().width/2

	local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp(centerW, bsSizeH-10))
	backSprie:addChild(acLabel)
	acLabel:setColor(G_ColorGreen)

	local acVo = acYijizaitanVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local messageLabel=GetTTFLabel(timeStr,25)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setPosition(ccp(centerW, bsSizeH-10-acLabel:getContentSize().height))
	backSprie:addChild(messageLabel)

	local aid,tankID = acYijizaitanVoApi:getTankIdAndAid()
	local function showTankInfo( ... )
		local function callback()
			self:showBattle()
		end
	    if acYijizaitanVoApi:returnTankData()==nil then
	      tankInfoDialog:create(nil,tankID,self.layerNum+1)
	    else
	      tankInfoDialog:create(nil,tankID,self.layerNum+1,nil,true,callback)
	    end
	end

	local version = acYijizaitanVoApi:getVersion()

	local orderId=GetTankOrderByTankId(tonumber(tankID))
	local tankStr="t"..orderId.."_1.png"

	local tScale
	if (G_isIphone5())then
		tScale=1
	else
		tScale=0.8
	end

	local tankSp=LuaCCSprite:createWithSpriteFrameName(tankStr,showTankInfo)
	tankSp:setTouchPriority(-(self.layerNum-1)*20-5)
	tankSp:setAnchorPoint(ccp(0,0.5))
	tankSp:setPosition(-18,bsSizeH/2-15)
	tankSp:setScale(tScale)
	backSprie:addChild(tankSp)
	if version then 
	    if tonumber(version)==2 then
	      tankSp:setPosition(0,75)
	    elseif tonumber(version) == 7 then
	      tankSp:setPosition(-40,75)
	    elseif tonumber(version) == 8 then
	      tankSp:setPosition(-25,75)
      	elseif tonumber(version)==9 then
	      tankSp:setPosition(-5,75)
	    end
	end

	local tankBarrel="t"..orderId.."_1_1.png"  --炮管 第6层
	local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
	if tankBarrelSP and version ~=8 then
		tankBarrelSP:setPosition(ccp(tankSp:getContentSize().width*0.5,tankSp:getContentSize().height*0.5))
		tankBarrelSP:setAnchorPoint(ccp(0.5,0.5))
		tankSp:addChild(tankBarrelSP)
	end

	local upLb = nil 
	if version and tonumber(version)<=11 then
		upLb=getlocal("activity_yijizaitan_desc"..version)
	else
		upLb=getlocal("activity_yijizaitan_desc1")
	end
    
    local desTvSize
    local desPos
    if (G_isIphone5())then
		desTvSize=CCSizeMake(w-110, 110)
		desPos=ccp(170,10)
	else
		desTvSize=CCSizeMake(w-90, 70)
		desPos=ccp(152,10)
	end

	local desTv, desLabel = G_LabelTableView(desTvSize,upLb,25,kCCTextAlignmentLeft)
	backSprie:addChild(desTv)
	desTv:setPosition(desPos)
	desTv:setAnchorPoint(ccp(0,0))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(80)


    local backGroundPosH = startH-bsSizeH-5
    local backGroundSize
    if (G_isIphone5())then
    	backGroundSize=CCSizeMake(G_VisibleSizeWidth-50,180)
	else
		backGroundSize=CCSizeMake(G_VisibleSizeWidth-50,120)
	end
    self.background=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function () end)
    self.background:setContentSize(backGroundSize)
    self.background:setAnchorPoint(ccp(0.5,1))
    self.background:setPosition(ccp(G_VisibleSizeWidth/2,backGroundPosH))
    self.bgLayer:addChild(self.background)

    local titleLb
    if (G_isIphone5()) then
    	titleLb = GetTTFLabelWrap(getlocal("serverwar_point_record"),25,CCSizeMake(80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		titleLb:setAnchorPoint(ccp(0.5,1))
		titleLb:setPosition(self.background:getContentSize().width/2,self.background:getContentSize().height-10)
    else
    	titleLb = GetTTFLabelWrap(getlocal("serverwar_point_record") .. ":",25,CCSizeMake(80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    	titleLb:setAnchorPoint(ccp(0,0.5))
	    titleLb:setPosition(10,self.background:getContentSize().height/2)
    end
    
    self.background:addChild(titleLb)

    self.noTansuoLb = GetTTFLabelWrap(getlocal("activity_yijizaitanNew_noReward"),25,CCSizeMake(self.background:getContentSize().width-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noTansuoLb:setAnchorPoint(ccp(0.5,0.5))
    self.noTansuoLb:setPosition(self.background:getContentSize().width/2,self.background:getContentSize().height/2)
    self.background:addChild(self.noTansuoLb)

	self:updateShowTv()

	local selfBackSize=CCSizeMake(G_VisibleSizeWidth/2-40,startH-bsSizeH-5-backGroundSize.height-35)
	
  	local function nilFunc()
  	end
	local backSprie1 =LuaCCScale9Sprite:createWithSpriteFrameName("iconTitlebg.png",CCRect(27, 29, 2, 2),nilFunc)
	backSprie1:setContentSize(selfBackSize)
	backSprie1:setAnchorPoint(ccp(0.5,0));
	backSprie1:setPosition(G_VisibleSizeWidth/4+10,30)
	backSprie1:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(backSprie1,1)
	self.backSprie1=backSprie1

	local backSprie2 =LuaCCScale9Sprite:createWithSpriteFrameName("iconTitlebg.png",CCRect(27, 29, 2, 2),nilFunc)
	backSprie2:setContentSize(selfBackSize)
	backSprie2:setAnchorPoint(ccp(0.5,0));
	backSprie2:setPosition(G_VisibleSizeWidth/4*3-10,30)
	backSprie2:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(backSprie2,1)
	self.backSprie2=backSprie2

	-- 购买的礼包
	local backSp
	local subH=120
	if not (G_isIphone5())then 
		subH=100
	end
	for i=1,3 do
		local mustReward
		if i==1 then
			mustReward=acYijizaitanVoApi:getMustReward1()
		elseif i==2 then
			mustReward=acYijizaitanVoApi:getMustReward2()
		else
			mustReward=acYijizaitanVoApi:getMustReward3()
		end
		local rewardItem = FormatItem(mustReward.reward)
		self["rewardItem" .. i]=rewardItem
	end
	for i=1,2 do
		local pic
		local nameStr
		if i==1 then
			backSp=backSprie1
			pic="juniorMaterialBox.png"
			nameStr=getlocal("juniorMaterialBox")
		else
			backSp=backSprie2
			pic="advanceMaterialBox.png"
			nameStr=getlocal("advanceMaterialBox")
		end

		local halfW = backSp:getContentSize().width/2
		local bsH = backSp:getContentSize().height
		-- local icon=CCSprite:createWithSpriteFrameName(pic)
		local function touchInfoItem(idx)
			print("idx------>",idx)
			
			if G_checkClickEnable()==false then
		      do
		          return
		      end
		    else
		      base.setWaitTime=G_getCurDeviceMillTime()
		    end
		    local title = getlocal("juniorMaterialBox")
		    local mustReward = acYijizaitanVoApi:getCurMustAward(idx)[1]
		    if idx >1 then
				title = getlocal("advanceMaterialBox")
			end
		    PlayEffect(audioCfg.mouseClick)
		    local awardCfg = acYijizaitanVoApi:getAwardCfgByIdx(idx)
		    require "luascript/script/game/scene/gamedialog/activityAndNote/acYijizaitanNewSmallDialog"
		    local td=acYijizaitanNewSmallDialog:new()
		    -- local rewardList={}
		    local desStr2 = getlocal("otherRandom_ger")
		    local desStr1 = getlocal("but_get")
		    local dialog=td:init("PanelPopup.png",CCSizeMake(550,700),nil,false,false,self.layerNum+1,awardCfg,mustReward,title,desStr1,desStr2,idx)
		    sceneGame:addChild(dialog,self.layerNum+1)


		end 
		local iconBtn = GetButtonItem(pic,pic,pic,touchInfoItem,i,nil,nil)
		local iconMenu=CCMenu:createWithItem(iconBtn)
	  	iconMenu:setPosition(ccp(halfW,bsH-subH))
	  	iconMenu:setTouchPriority(-(self.layerNum-1)*20-4)

		-- icon:setTouchPriority(-(self.layerNum-1)*20-3)
		backSp:addChild(iconMenu)

		local nameLb=GetTTFLabelWrap(nameStr,25,CCSizeMake(260,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		backSp:addChild(nameLb)
		nameLb:setPosition(ccp(halfW,bsH-(subH-50)/2)
		)
		local decStr
		if i==1 then
			decStr=getlocal("activity_yijizaitanNew_des1",{self["rewardItem1"][1].name})
		else
			decStr=getlocal("activity_yijizaitanNew_des2",{self["rewardItem3"][1].name})
		end
		local desLb=GetTTFLabelWrap(
		decStr,22,CCSizeMake(260,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		desLb:setAnchorPoint(ccp(0.5,1))
		backSp:addChild(desLb)
		desLb:setPosition(ccp(halfW,bsH-(subH+50+10))
		)
	end
	

	local gemCost=acYijizaitanVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
	local oneGems=gemCost       --一次抽奖需要金币
	local tenGems=acYijizaitanVoApi:getLotteryTenCost()      --十次抽奖需要金币
	local vipCost = acYijizaitanVoApi:getVipCost()
	local vipTotal = acYijizaitanVoApi:getVipTansuoTotal()
	local vipHadNum = acYijizaitanVoApi:getVipHadTansuoNum()

	local leftPosX=self.backSprie1:getContentSize().width/2-30
	local centerPosX = self.bgLayer:getContentSize().width/2
	local rightPosX=self.backSprie1:getContentSize().width/2+200

	local btnY = 70
	local chaH = 120
	local addH=10
	if not (G_isIphone5()) then
		chaH=105
		addH=0
	end
	local lbY=50+50+chaH+addH
	self.goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.goldSp1:setAnchorPoint(ccp(0,0.5))
	self.goldSp1:setPosition(ccp(leftPosX-5,lbY))
	backSprie1:addChild(self.goldSp1)

	self.gemsLabel1=GetTTFLabel(oneGems,25)
	self.gemsLabel1:setAnchorPoint(ccp(0,0.5))
	self.gemsLabel1:setPosition(ccp(leftPosX+35,lbY))
	backSprie1:addChild(self.gemsLabel1,1)


	local goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
	goldSp2:setAnchorPoint(ccp(0,0.5))
	goldSp2:setPosition(ccp(leftPosX-15,lbY-chaH))
	backSprie1:addChild(goldSp2)

	self.gemsLabel2=GetTTFLabel(tenGems,25)
	self.gemsLabel2:setAnchorPoint(ccp(0,0.5))
	self.gemsLabel2:setPosition(ccp(leftPosX+25,lbY-chaH))
	backSprie1:addChild(self.gemsLabel2,1)

	self.goldSp3=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.goldSp3:setAnchorPoint(ccp(0,0.5))
	self.goldSp3:setPosition(ccp(leftPosX-15,lbY-chaH))
	backSprie2:addChild(self.goldSp3)

	self.gemsLabel3=GetTTFLabel(vipCost,25)
	self.gemsLabel3:setAnchorPoint(ccp(0,0.5))
	self.gemsLabel3:setPosition(ccp(leftPosX+25,lbY-chaH))
	backSprie2:addChild(self.gemsLabel3,1)

	local vipLbWidth = backSprie2:getContentSize().width/2
	local vipIcon = GetTTFLabel(getlocal("vipTitle"),25)
	vipIcon:setAnchorPoint(ccp(0.5,0.5))
	vipIcon:setPosition(vipLbWidth,lbY-chaH+85)
	backSprie2:addChild(vipIcon)
	vipIcon:setColor(G_ColorYellow)

	self.vipNum = GetTTFLabel("("..getlocal("scheduleChapter",{vipHadNum,vipTotal})..")",25)
	self.vipNum:setAnchorPoint(ccp(0.5,0.5))
	self.vipNum:setPosition(vipLbWidth,lbY-chaH+50)
	backSprie2:addChild(self.vipNum)

	local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX(260/lineSp:getContentSize().width)
	lineSp:setPosition(vipLbWidth,lbY-chaH+25)
	backSprie2:addChild(lineSp)
	self:updateVipNUm()
	self:updateShowBtn()
end

function acYijizaitanTab1New:updateShowBtn()
	local free = 0
	if acYijizaitanVoApi:isToday() == true then
		free = 1
	end
	local gemCost=acYijizaitanVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
	local oneGems=gemCost       --一次抽奖需要金币
	local tenGems=acYijizaitanVoApi:getLotteryTenCost()      --十次抽奖需要金币
	local vipCost = acYijizaitanVoApi:getVipCost()
	local vipTotal = acYijizaitanVoApi:getVipTansuoTotal()
	local vipHadNum = acYijizaitanVoApi:getVipHadTansuoNum()



	local leftPosX=self.backSprie1:getContentSize().width/2
	local centerPosX = leftPosX
	local rightPosX=self.backSprie2:getContentSize().width/2

	local lbY=200
	local btnY = 50
	local btnScale=0.8
	local chaH=105
	if (G_isIphone5()) then
		btnScale=1
		chaH=120
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
		if acYijizaitanVoApi:isToday() == true then
			free = 1
		end
		local vipTotal = acYijizaitanVoApi:getVipTansuoTotal()
		local vipHadNum = acYijizaitanVoApi:getVipHadTansuoNum()
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
			self.oldShowIndex = acYijizaitanVoApi:getShowCityID()
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
				if sData.data["yijizaitan"] then
					local awardData=sData.data["yijizaitan"]["clientReward"]
					local nameStr 
					local content = {}
					local addDestr={}
					local chat = false
					local aid,tankID = acYijizaitanVoApi:getTankIdAndAid()
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
					if sData.data["yijizaitan"]["location"] then
						acYijizaitanVoApi:updateShowCityID(sData.data["yijizaitan"]["location"])
					end
                    if tag==1 or tag==4 then
						local showIndex = acYijizaitanVoApi:getShowCityID()
						if showIndex==1 then
							if self.oldShowIndex==4 then
								table.insert(addDestr,getlocal("activity_yijizaitan_startAgain"))
							else
								table.insert(addDestr,getlocal("activity_yijizaitan_failure"))
							end
						else
							table.insert(addDestr,getlocal("activity_yijizaitan_success"))
						end
                    elseif tag==2 then
						local localtionList = sData.data["yijizaitan"]["locationList"]
						for k,v in pairs(localtionList) do
							if v==1 then
								if  k==1 and self.oldShowIndex==4 then
									table.insert(addDestr,getlocal("activity_yijizaitan_startAgain"))
								elseif localtionList[k-1]==4 then
									table.insert(addDestr,getlocal("activity_yijizaitan_startAgain"))
								else
									table.insert(addDestr,getlocal("activity_yijizaitan_failure"))
								end
							else
								table.insert(addDestr,getlocal("activity_yijizaitan_success"))
							end
						end
                    end
					if sData.data["yijizaitan"]["list"] then
						acYijizaitanVoApi:setRewardList(sData.data["yijizaitan"]["list"])
					end
	                  
					if tag==3 then
						acYijizaitanVoApi:addVipHadTansuoNum(1)
					end

					local function confirmHandler(index)
						if free == 0 then
							acYijizaitanVoApi:updateLastTime()
							self.isToday=acYijizaitanVoApi:isToday()
							acYijizaitanVoApi:updateShow()
						end
						self:updateShowMap()
						self:updateVipNUm()
						self:updateShowBtn()
						self:updateShowTv()
					end
					local rewardItem
					if tag==1 or tag==4 or tag==2 then
						rewardItem=self.rewardItem1[1]
					else
						rewardItem=self.rewardItem2[1]
					end
					-- table.insert(content,1,{award=rewardItem})
                    smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,true,nil,nil,nil,nil,nil,nil,nil,nil)
	                  
					if chat == true then
						--聊天公告
						local paramTab={}
	                    paramTab.functionStr="yijizaitan"
	                    paramTab.addStr="i_also_want"
						local nameData={key=tankCfg[tankID].name,param={}}
						local message={key="activity_yijizaitanNew_chatSystemMessage",param={playerVoApi:getPlayerName(),nameData}}
						chatVoApi:sendSystemMessage(message,paramTab)
					end
                end
			end
		end
		-- if tag == 3 then
		-- 	local function sureClick( ... )
				-- socketHelper:activityYijizaitanTansuo(num,lotteryCallback)
		-- 	end
		-- 	local tsD=smallDialog:new()
		-- 	tsD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureClick,getlocal("dialog_title_prompt"),getlocal("activity_feixutansuo_VipTansuo",{vipCost}),nil,self.layerNum+1)
		-- else
			socketHelper:activityYijizaitanTansuo(num,lotteryCallback)
		-- end
	end	 	
	   
	if self.lotteryTenBtn == nil then
		self.lotteryTenBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnCallback,2,getlocal("but_ten"),25)
	    self.lotteryTenBtn:setAnchorPoint(ccp(0.5,0.5))
	    self.lotteryTenBtn:setScale(btnScale)
	    
	    local lotteryMenu1=CCMenu:createWithItem(self.lotteryTenBtn)
	    lotteryMenu1:setPosition(ccp(centerPosX,btnY))
	    lotteryMenu1:setTouchPriority(-(self.layerNum-1)*20-3)
	    self.backSprie1:addChild(lotteryMenu1,2)
	end
    
	if self.vipBtn == nil then
	    self.vipBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnCallback,3,getlocal("buy"),25)
	 	self.vipBtn:setAnchorPoint(ccp(0.5,0.5))
	 	self.vipBtn:setScale(btnScale)
		local vipMenu=CCMenu:createWithItem(self.vipBtn)
		vipMenu:setPosition(ccp(rightPosX,btnY))
		vipMenu:setTouchPriority(-(self.layerNum-1)*20-3)
		self.backSprie2:addChild(vipMenu,2)
	end

	if self.lotteryOneBtn1 == nil then
		self.lotteryOneBtn1=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",btnCallback,1,getlocal("daily_lotto_tip_2"),25)
		self.lotteryOneBtn1:setScale(btnScale)
		self.lotteryOneBtn1:setAnchorPoint(ccp(0.5,0.5))
		local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn1)
		lotteryMenu:setPosition(leftPosX,btnY+chaH)
		lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
		self.backSprie1:addChild(lotteryMenu,2)

		self.lotteryOneBtn2=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",btnCallback,4,getlocal("buy"),25)
		self.lotteryOneBtn2:setScale(btnScale)
		self.lotteryOneBtn2:setAnchorPoint(ccp(0.5,0.5))
		local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn2)
		lotteryMenu:setPosition(leftPosX,btnY+chaH)
		lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
		self.backSprie1:addChild(lotteryMenu,2)
	end

	if free == 0 then
		self.vipBtn:setEnabled(false)
		self.lotteryTenBtn:setEnabled(false)
		self.lotteryOneBtn1:setVisible(true)
		self.lotteryOneBtn2:setVisible(false)
		self.goldSp1:setVisible(false)
		self.gemsLabel1:setVisible(false)
	else
		self.goldSp1:setVisible(true)
		self.gemsLabel1:setVisible(true)
		self.lotteryTenBtn:setEnabled(true)
		self.lotteryOneBtn1:setVisible(true)
		self.lotteryOneBtn2:setVisible(true)
		if vipTotal>0 and vipHadNum>=vipTotal then
			 self.vipBtn:setEnabled(false)
		else
			self.vipBtn:setEnabled(true)
		end
	end


	
end
function acYijizaitanTab1New:updateVipNUm()
	local oneGems=acYijizaitanVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
	local tenGems=acYijizaitanVoApi:getLotteryTenCost()      --十次抽奖需要金币
	local vipCost = acYijizaitanVoApi:getVipCost()
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
		local vipTotal = acYijizaitanVoApi:getVipTansuoTotal()
		local vipHadNum = acYijizaitanVoApi:getVipHadTansuoNum()
		self.vipNum:setString("("..getlocal("scheduleChapter",{vipHadNum,vipTotal})..")")
	end
end

function acYijizaitanTab1New:updateShowTv()
  	self.rewardList = acYijizaitanVoApi:getRewardList()
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
  			local tvSize
  			local tvPos
  			if (G_isIphone5()) then
  				tvSize=CCSizeMake(self.background:getContentSize().width-20,self.background:getContentSize().height-50)
  				tvPos=ccp(10,10)
  			else
  				tvSize=CCSizeMake(self.background:getContentSize().width-100,self.background:getContentSize().height-10)
  				tvPos=ccp(90,5)
  			end
  			self.tvSize=tvSize
  			local function callBack(...)
  				return self:eventHandler1(...)
  			end
  			local hd= LuaEventHandler:createHandler(callBack)
  		 	self.tv1=LuaCCTableView:createHorizontalWithEventHandler(hd,tvSize,nil)
  			self.tv1:setAnchorPoint(ccp(0,0))
  			self.tv1:setPosition(tvPos)
  			self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
  			self.tv1:setMaxDisToBottomOrTop(100)
  			self.background:addChild(self.tv1,1)
  		end
  	end
end


function acYijizaitanTab1New:updateShowMap()
	local showIndex = acYijizaitanVoApi:getShowCityID()
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
function acYijizaitanTab1New:eventHandler1(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if SizeOfTable(self.rewardList) >=10 then
			return 10
		else
			return SizeOfTable(self.rewardList)
		end
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(105,self.tvSize.height)
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
            icon:setPosition(10,self.tvSize.height/2)
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


function acYijizaitanTab1New:tick()
	local today=acYijizaitanVoApi:isToday()
	if self.isToday~=today then
		acYijizaitanVoApi:updateVipHadTansuoNum()
		self:updateVipNUm()
		self:updateShowBtn()
		self.isToday=today
	end
end

function acYijizaitanTab1New:fastTick()
end

function acYijizaitanTab1New:showBattle()
	local battleStr=acYijizaitanVoApi:returnTankData()
	local report=G_Json.decode(battleStr)
	local isAttacker=true
	local data={data={report=report},isAttacker=isAttacker,isReport=true}
	battleScene:initData(data)
end
function acYijizaitanTab1New:dispose()
	eventDispatcher:removeEventListener("acYijizaitan.recharge",self.activityListener)
	self.tv1 = nil
	self.oldShowIndex = nil
	spriteController:removePlist("serverWar/serverWar.plist")
	spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
end