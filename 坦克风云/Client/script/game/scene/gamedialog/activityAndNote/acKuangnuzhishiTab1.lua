acKuangnuzhishiTab1={

}

function acKuangnuzhishiTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
   
    self.layerNum=nil
    self.isToday = nil 
    self.isEnd = nil 
    touchEnabledSp=nil
    self.rewardIconList={}

    return nc;

end

function acKuangnuzhishiTab1:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    
    self:initTableView()


    return self.bgLayer
end

-- 更新领奖按钮显示
function acKuangnuzhishiTab1:update()

end

function acKuangnuzhishiTab1:initTableView()

	self.isToday = acKuangnuzhishiVoApi:isToday()
	self.isEnd = acKuangnuzhishiVoApi:checkIsEnd()

	local function touchDialog()
      -- if self.state == 2 then
      --   PlayEffect(audioCfg.mouseClick)
      --   self.state = 3
      --   -- 暂停动画
      --   -- self:close()
      -- end
  end
    self.touchEnabledSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchDialog)
	self.touchEnabledSp:setAnchorPoint(ccp(0,0))
	self.touchEnabledSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	self.touchEnabledSp:setIsSallow(true)
	self.touchEnabledSp:setTouchPriority(-(self.layerNum-1)*20-7)
	-- sceneGame:addChild(self.touchEnabledSp,self.layerNum)
	self.bgLayer:addChild(self.touchEnabledSp,self.layerNum)
	self.touchEnabledSp:setOpacity(0)
	self.touchEnabledSp:setPosition(ccp(10000,0))
	self.touchEnabledSp:setVisible(false)


	local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)

	backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,200))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
	backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-165))
    self.bgLayer:addChild(backSprie,1)

    local tankSp = CCSprite:createWithSpriteFrameName("kuangnuSp.png")
    tankSp:setScaleX((self.bgLayer:getContentSize().width-60)/tankSp:getContentSize().width)
    tankSp:setScaleY(190/tankSp:getContentSize().height)
    tankSp:setAnchorPoint(ccp(0.5,0.5))
    tankSp:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2)
    backSprie:addChild(tankSp)

    local timeSP = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),cellClick)
    timeSP:setAnchorPoint(ccp(0.5,1))
    timeSP:setPosition(ccp(backSprie:getContentSize().width/2, backSprie:getContentSize().height-10))
    backSprie:addChild(timeSP)

    local acVo = acKuangnuzhishiVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        self.timeLabel=GetTTFLabelWrap(timeStr,25,CCSizeMake(backSprie:getContentSize().width-250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        self.timeLabel:setAnchorPoint(ccp(0.5,1))
        self.timeLabel:setPosition(ccp(backSprie:getContentSize().width/2, backSprie:getContentSize().height-20))
        backSprie:addChild(self.timeLabel,10)
    end
    timeSP:setContentSize(CCSizeMake(backSprie:getContentSize().width-250,self.timeLabel:getContentSize().height+20))
    local function showInfo()
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("activity_kuangnuzhishi_lotteryTip4"),"\n",getlocal("activity_kuangnuzhishi_lotteryTip3"),"\n",getlocal("activity_kuangnuzhishi_lotteryTip2"),"\n",getlocal("activity_kuangnuzhishi_lotteryTip1"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorRed,nil,nil,nil,nil,nil,nil,nil})
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(backSprie:getContentSize().width-35,backSprie:getContentSize().height-10))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    backSprie:addChild(infoBtn,3)

    local function tankInfo1( ... )
    	tankInfoDialog:create(nil,10113,self.layerNum+1, nil)
    end
    local tankItem1 = GetButtonItem("xieerman.png","xieerman_down.png","xieerman_down.png",tankInfo1,11,nil,nil)
    tankItem1:setAnchorPoint(ccp(0,0))
    local tankIcon1 = CCMenu:createWithItem(tankItem1)
    tankIcon1:setTouchPriority(-(self.layerNum-1)*20-5)
    tankIcon1:setPosition(250,0)
    tankSp:addChild(tankIcon1)

    local function tankInfo2()
		tankInfoDialog:create(nil,10123,self.layerNum+1, nil)
    end
    local tankItem2 = GetButtonItem("hushitank.png","hushitank_down.png","hushitank_down.png",tankInfo2,11,nil,nil)
    tankItem1:setAnchorPoint(ccp(1,0))
    local tankIcon2 = CCMenu:createWithItem(tankItem2)
    tankIcon2:setTouchPriority(-(self.layerNum-1)*20-5)
    tankIcon2:setPosition(tankSp:getContentSize().width-120,70)
    tankSp:addChild(tankIcon2)

    local explainLb = GetTTFLabelWrap(getlocal("shuoming")..":",25,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    explainLb:setAnchorPoint(ccp(0,1))
    explainLb:setPosition(30,self.bgLayer:getContentSize().height-380)
    self.bgLayer:addChild(explainLb)
    explainLb:setColor(G_ColorGreen)

    self.descTv,self.descLb=G_LabelTableView(CCSize(self.bgLayer:getContentSize().width-180,70),getlocal("activity_kuangnuzhishi_lotteryContent"),25,kCCTextAlignmentCenter)
    self.descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.descTv:setAnchorPoint(ccp(0,0))
    self.descTv:setPosition(ccp(120,self.bgLayer:getContentSize().height-440))
    self.bgLayer:addChild(self.descTv,2)
    self.descTv:setMaxDisToBottomOrTop(50)


    local gemCost=acKuangnuzhishiVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
    local oneGems=gemCost       --一次抽奖需要金币
    local tenGems=acKuangnuzhishiVoApi:getLotteryTenCost()      --十次抽奖需要金币

	  local leftPosX=self.bgLayer:getContentSize().width/2-150
	  local rightPosX=self.bgLayer:getContentSize().width/2+150

	  local lbY=140
	  self.goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
	  self.goldSp1:setAnchorPoint(ccp(0,0.5))
	  self.goldSp1:setPosition(ccp(leftPosX,lbY))
	  self.bgLayer:addChild(self.goldSp1)
	  self.goldSp1:setScale(1.5)

	  self.gemsLabel1=GetTTFLabel(oneGems,30)
	  self.gemsLabel1:setAnchorPoint(ccp(1,0.5))
	  self.gemsLabel1:setPosition(ccp(leftPosX,lbY))
	  self.bgLayer:addChild(self.gemsLabel1,1)

	  local goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
	  goldSp2:setAnchorPoint(ccp(0,0.5))
	  goldSp2:setPosition(ccp(rightPosX,lbY))
	  self.bgLayer:addChild(goldSp2)
	  goldSp2:setScale(1.5)

	  -- local oldgemsLabel2=GetTTFLabel(acKuangnuzhishiVoApi:getLotteryOldTenCost(),25)
	  -- oldgemsLabel2:setAnchorPoint(ccp(0,0.5))
	  -- oldgemsLabel2:setPosition(ccp(rightPosX-70,lbY))
	  -- self.bgLayer:addChild(oldgemsLabel2,1)

	  -- local line = CCSprite:createWithSpriteFrameName("redline.jpg")
	  -- line:setScaleX((oldgemsLabel2:getContentSize().width+20) / line:getContentSize().width)
	  -- line:setAnchorPoint(ccp(0, 0))
	  -- line:setPosition(ccp(rightPosX-80,lbY-3))
	  -- self.bgLayer:addChild(line,7)

	  local gemsLabel2=GetTTFLabel(tenGems,30)
	  gemsLabel2:setAnchorPoint(ccp(1,0.5))
	  gemsLabel2:setPosition(ccp(rightPosX,lbY))
	  self.bgLayer:addChild(gemsLabel2,1)
      self:updateShow()

      if self.lotterySprie==nil then
      	local function nilfun( ... )
      		-- body
      	end
		self.lotterySprie =LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilfun)
	    self.lotterySprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-600))
	    self.lotterySprie:setAnchorPoint(ccp(0,0))
	    self.lotterySprie:setPosition(ccp(30,150))
	    self.bgLayer:addChild(self.lotterySprie,1)
	end
	self.rewardList = acKuangnuzhishiVoApi:FormatItem()
    self:doUserHandler()
    self:endUpdate()
end


function acKuangnuzhishiTab1:endUpdate()
	if acKuangnuzhishiVoApi:checkIsEnd() == true then
		if self.timeLabel then
			self.timeLabel:setString(getlocal("activity_kuangnuzhishi_endToReward"))
		end
		if self.lotteryOneBtn then
			self.lotteryOneBtn:setEnabled(false)
		end
		if self.lotteryTenBtn then
			self.lotteryTenBtn:setEnabled(false)
		end
	end
end
function acKuangnuzhishiTab1:doUserHandler()
	for i=1,9 do
		local item = acKuangnuzhishiVoApi:getItemByIndex(i)
		local wSpace=170
		local hSpace=(self.lotterySprie:getContentSize().height-25)/3
		local icon,iconScale
		if i==5 then
			
			local function showInfoHandler( ... )
				propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,true,getlocal("activity_kuangnuzhishi_scores",{item.score[1],item.score[2]}))
			end
			icon= LuaCCSprite:createWithSpriteFrameName("SpecialBox.png",showInfoHandler)
			iconScale = 100/icon:getContentSize().width
			local posX,posY=self:getPosition(wSpace,hSpace,i,iconScale)
			icon:setTouchPriority(-(self.layerNum-1)*20-5)
	        icon:setAnchorPoint(ccp(0.5,0.5))
	        icon:setPosition(posX,posY)
	        self.lotterySprie:addChild(icon)
		else
			print(i,item.score)
			icon,iconScale = G_getItemIcon(item,100,true,self.layerNum,nil,nil,getlocal("activity_kuangnuzhishi_scores",{item.score[1],item.score[2]}))
			local posX,posY=self:getPosition(wSpace,hSpace,i,iconScale)
	        icon:setTouchPriority(-(self.layerNum-1)*20-5)
	        icon:setAnchorPoint(ccp(0.5,0.5))
	        icon:setPosition(posX,posY)
	        self.lotterySprie:addChild(icon)

	        local num = GetTTFLabel("x"..item.num,25/iconScale)
	        num:setAnchorPoint(ccp(1,0))
	        num:setPosition(icon:getContentSize().width-10,10)
	        icon:addChild(num)
		end

		self.rewardIconList[i]=icon
		
	end

	local function nilFunc()
    end
    self.halo=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),nilFunc)
    self.halo:setContentSize(CCSizeMake(100+8,100+8))
    self.halo:setAnchorPoint(ccp(0.5,0.5))
    self.halo:setTouchPriority(0)
    self.halo:setVisible(false)
    local tx,ty=self.rewardIconList[1]:getPosition()
    self.halo:setPosition(tx,ty)
    self.lotterySprie:addChild(self.halo,3)


end

function acKuangnuzhishiTab1:getPosition(wSpace,hSpace,index,scale)
	local posX=wSpace*((index-1)%3)+110+10
	local posY=self.lotterySprie:getContentSize().height/2-(hSpace-10)*(math.ceil(index/3)-2)-100+100
	return posX,posY
end
function acKuangnuzhishiTab1:updateShow()

  	local gemCost=acKuangnuzhishiVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
    local oneGems=gemCost       --一次抽奖需要金币
    local tenGems=acKuangnuzhishiVoApi:getLotteryTenCost()      --十次抽奖需要金币

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
	          if acKuangnuzhishiVoApi:isToday()==true then
	            free=1
	          end
	          local num
	          if tag==1 then
	            if free==1 and playerVoApi:getGems()<oneGems then
	              GemsNotEnoughDialog(nil,nil,oneGems-playerVoApi:getGems(),self.layerNum+1,oneGems)
	              do return end
	            end
	            num=1
	          elseif tag==2 then
	            if playerVoApi:getGems()<tenGems then
	              GemsNotEnoughDialog(nil,nil,tenGems-playerVoApi:getGems(),self.layerNum+1,tenGems)
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
	                
	                if tag==1 then
	                  if free==1 then
	                    playerVoApi:setValue("gems",playerVoApi:getGems()-oneGems)
	                  end
	                elseif tag==2 then
	                  playerVoApi:setValue("gems",playerVoApi:getGems()-tenGems)
	                end

	              --刷新活动数据
	                local tipStr=""
	                if sData.data["kuangnuzhishi"]["clientReward"] then
	                  self.awardData=sData.data["kuangnuzhishi"]["clientReward"]
	                  local Tank1ID = false
	                  local Tank2ID = false
	                  local hadTickets = false
	                  
	                  local str = ""
	                  local nameStr 
	                  local content = {}
	                  for k,v in pairs(self.awardData) do
	                    local ptype = v[1]
	                    local pID = v[2]
	                    local num = v[3]
	                    local point = v[4]
	                    local award = {}

	                    if ptype == "o" and pID=="a10113" then
	                    	Tank1ID = tonumber(Split(pID,"a")[2])
	                    end
	                    if ptype == "o" and pID=="a10123" then
	                    	Tank2ID = tonumber(Split(pID,"a")[2])
	                    end
	                    if ptype == "p" and pID=="p677" then
	                    	hadTickets = true 
	                    end

	                    self.lotteryPtype = ptype
	                    self.lotteryPID = pID
	                    self.lotteryPNum= num
	                    self.point = point
	                    acKuangnuzhishiVoApi:addMyScores(point)
	                    local name,pic,desc,id,index,eType,equipId=getItem(pID,ptype)
	                    award={name=name,num=num,pic=pic,desc=desc,id=id,type=ptype,index=index,key=pID,eType=eType,equipId=equipId}
	                    G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
	                    -- if k==SizeOfTable(self.awardData) then
	                    --     str = str .. nameStr .. " x" .. num
	                    -- else
	                    --     str = str .. nameStr .. " x" .. num .. ","
	                    -- end
	                    table.insert(content,{award=award,point=point})


	                  end
	                  print(Tank1ID)
	                  if Tank1ID then
	                  	local tankName=getlocal(tankCfg[Tank1ID].name)
						local message={key="activity_kuangnuzhishi_tankChatSystemMessage",param={playerVoApi:getPlayerName(),tankName}}
    					chatVoApi:sendSystemMessage(message)
    				  end

    				  if Tank2ID then
	                  	local tankName=getlocal(tankCfg[Tank2ID].name)
						local message={key="activity_kuangnuzhishi_tankChatSystemMessage",param={playerVoApi:getPlayerName(),tankName}}
    					chatVoApi:sendSystemMessage(message)
    				  end

    				  if hadTickets == true then
						local message={key="activity_kuangnuzhishi_ticketsChatSystemMessage",param={playerVoApi:getPlayerName()}}
    					chatVoApi:sendSystemMessage(message)
    					end

	                  if tag==1 then
	                  	   self.touchEnabledSp:setVisible(true)
        				   self.touchEnabledSp:setPosition(ccp(0,0))
        				   if free == 0 then
        				   		acKuangnuzhishiVoApi:updateLastTime()
        				   		self.isToday = acKuangnuzhishiVoApi:isToday()
        				   		acKuangnuzhishiVoApi:updateShow()
        				   end
	                       self:play()
	                    else
	                      if content and SizeOfTable(content)>0 then
	                          local function confirmHandler(index)
	                            if self.lotteryOneBtn then
					          		self.lotteryOneBtn:setEnabled(true)
					          	end
					          	if self.lotteryTenBtn then
					          		self.lotteryTenBtn:setEnabled(true)
					          	end
					          	self:endUpdate()
	                          end
	                          smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(560,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,nil,nil,true,getlocal("activity_kuangnuzhishi_gotScores"))
	                      end
	                    end
	                end
	              else
	              	if self.lotteryOneBtn then
		          		self.lotteryOneBtn:setEnabled(true)
		          	end
		          	if self.lotteryTenBtn then
		          		self.lotteryTenBtn:setEnabled(true)
		          	end
	              end
	           end
	        if self.lotteryOneBtn then
          		self.lotteryOneBtn:setEnabled(false)
          	end
          	if self.lotteryTenBtn then
          		self.lotteryTenBtn:setEnabled(false)
          	end
	         socketHelper:activityKuangnuzhishiLottery(num,lotteryCallback)
      end

    local leftPosX=self.bgLayer:getContentSize().width/2-150
    local rightPosX=self.bgLayer:getContentSize().width/2+150
    local btnY=70
   
    if self.lotteryOneBtn == nil then
	    self.lotteryTenBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",btnCallback,2,getlocal("ten_roulette_btn"),25)
	    self.lotteryTenBtn:setAnchorPoint(ccp(0.5,0.5))
	    local lotteryMenu1=CCMenu:createWithItem(self.lotteryTenBtn)
	    lotteryMenu1:setPosition(ccp(rightPosX,btnY))
	    lotteryMenu1:setTouchPriority(-(self.layerNum-1)*20-3)
	    self.bgLayer:addChild(lotteryMenu1,2)
	end
	if self.lotteryOneBtn then
		self.lotteryOneBtn:removeFromParentAndCleanup(true)
		self.lotteryOneBtn = nil 
	end

  if acKuangnuzhishiVoApi:isToday()==false then
    -- local lb=tolua.cast(self.lotteryOneBtn:getChildByTag(101),"CCLabelTTF")
    -- lb:setString(getlocal("daily_scene_get"))

    self.lotteryOneBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",btnCallback,1,getlocal("daily_lotto_tip_2"),25)


    self.goldSp1:setVisible(false)
    self.lotteryTenBtn:setEnabled(false)
    self.gemsLabel1:setVisible(false)
  else

    self.lotteryOneBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",btnCallback,1,getlocal("active_lottery_btn1"),25,101)

    self.goldSp1:setVisible(true)
    self.gemsLabel1:setVisible(true)
    self.lotteryTenBtn:setEnabled(true)
  end

  self.lotteryOneBtn:setAnchorPoint(ccp(0.5,0.5))
  local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn)
  lotteryMenu:setPosition(ccp(leftPosX,btnY))
  lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
  self.bgLayer:addChild(lotteryMenu,2)
end

-- function acKuangnuzhishiTab1:startPalyAnimation()
--   --self.speed=5 
--   self.moveDis=0
--   self.isStop=false
--   self.state = 2
--   self.touchDialogBg:setIsSallow(true) -- 点击事件透下去
--   self:play()
--   print("得到抽取结果~")
-- end

-- function acKuangnuzhishiTab1:stopPlayAnimation()
--   print("正常~")
--   self.state = 0
--   self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
--   base:removeFromNeedRefresh(self)
-- end

function acKuangnuzhishiTab1:fastTick()
	if self.tickIndex then
	    self.tickIndex=self.tickIndex+1
	    self.tickInterval=self.tickInterval-1
	    if(self.tickInterval<=0)then
	        self.tickInterval=self.tickConst
	        if self.haloPos == 0 then
	        	self.haloPos =1 
	        elseif self.tickIndex>self.tickTotalInterval then
	        	self.haloPos = self.endIdx
	        else
	        	self.haloPos=math.random(1,9)--self.haloPos+1
	        end
	        if(self.haloPos>9)then
	            self.haloPos=self.haloPos-9
	            -- self.haloPos=1
	        end
	        local tx,ty=self.rewardIconList[self.haloPos]:getPosition()
	        self.halo:setPosition(tx,ty)
	        if self.haloPos == 5 then
	        	self.halo:setScaleX(1.5)
	        else
	        	self.halo:setScaleX(1)
	        end
	        if self.halo:isVisible()==false then
	            self.halo:setVisible(true)
	        end

	        -- if (self.tickIndex>=self.count) then 
	        --     if(self.haloPos==self.slowStartIndex)then
	        --         self.slowStart=true
	        --     end
	        --     if (self.slowStart) then
	        --             if (self.tickConst<self.tickConst*3) then
	        --                 self.tickConst=self.tickConst+self.tickConst
	        --             elseif self.tickConst<self.intervalNum*4 then
	        --                 self.tickConst=self.tickConst+self.tickConst*2
	        --             end
	        --     end
	            if self.endIdx>0 and (self.haloPos==self.endIdx) and self.tickIndex>self.tickTotalInterval then--and self.tickIndex~=self.count then
	                local function playEnd()
	                    --base:removeFromNeedRefresh(self)
	                    self:playEndEffect()
	                end
	                --local delay=CCDelayTime:create(0.5)
	                local callFunc=CCCallFuncN:create(playEnd)
	                
	                local acArr=CCArray:create()
	                --acArr:addObject(delay)
	                acArr:addObject(callFunc)
	                local seq=CCSequence:create(acArr)
	                self.bgLayer:runAction(seq)

	                
	            end
	        --end


	    end
	end
end

function acKuangnuzhishiTab1:play()
    self.tickIndex=0
    self.tickTotalInterval=120
    self.tickInterval=10
    self.tickConst=10
    self.intervalNum=3 --fasttick间隔 3帧一次

    self.haloPos=0
    self.slowStart=false
    
    self.endIdx=0
    for k,v in pairs(self.rewardList) do
        if self.rewardList and v and v.type==self.lotteryPtype and v.key==self.lotteryPID and  v.num==self.lotteryPNum then
            self.endIdx=k
        end
    end
    self.slowTime=4

    if self.endIdx>0 then
        self.count=9*self.tickConst --转1圈之后开始减速
        if self.endIdx>self.slowTime then
            self.slowStartIndex=self.endIdx-self.slowTime
        else
            self.count=self.count-((self.slowTime-1)*self.tickConst)
            self.slowStartIndex=self.endIdx-self.slowTime+9
        end

        -- self.halo:setVisible(true)
        --base:addNeedRefresh(self)
    end

end

function  acKuangnuzhishiTab1:playEndEffect()
	self.tickIndex =nil
    

    if self.maskSp==nil then
        local function tmpFunc()
        end
        self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
        self.maskSp:setOpacity(255)
        local size=CCSizeMake(G_VisibleSize.width-60,self.bgLayer:getContentSize().height-610)
        self.maskSp:setContentSize(size)
        self.maskSp:setAnchorPoint(ccp(0.5,0))
        self.maskSp:setPosition(ccp(G_VisibleSize.width/2,160))
        self.maskSp:setIsSallow(true)
        self.maskSp:setTouchPriority(-(self.layerNum-1)*20-6)
        self.bgLayer:addChild(self.maskSp,3)
    else
        self.maskSp:setVisible(true)
        self.maskSp:setPosition(ccp(G_VisibleSize.width/2,150))
    end

    local bgSize=self.rewardIconList[self.haloPos]:getContentSize()
    local item=self.rewardList[self.haloPos]
    if self.endIdx == 5 then
    	self.rewardIconBg = CCSprite:createWithSpriteFrameName("SpecialBoxOpen.png")
    	local addSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    	addSp:setPosition(getCenterPoint(self.rewardIconBg))
    	self.rewardIconBg:addChild(addSp)
    else
    	self.rewardIconBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    end
    self.rewardIconBg:setAnchorPoint(ccp(0.5,0.5))
    local tx,ty=self.rewardIconList[self.haloPos]:getPosition()
    -- tx=tx+bgSize.width/2
    -- ty=ty+bgSize.height/2
    self.rewardIconBg:setPosition(tx,ty)


    local rewardIcon=self.rewardIconList[self.haloPos]:getChildByTag(123+self.haloPos)
    -- self.rewardIconList[self.haloPos]:removeChild(rewardIcon,true)
    if item.key=="p677" then
        rewardIcon = GetBgIcon(item.pic,nil,nil,80,100)
    else
        rewardIcon = CCSprite:createWithSpriteFrameName(item.pic)
    end
    rewardIcon:setAnchorPoint(ccp(0.5,0.5))
    rewardIcon:setPosition(ccp(self.rewardIconBg:getContentSize().width/2,self.rewardIconBg:getContentSize().height/2))
    self.rewardIconBg:addChild(rewardIcon)
    self.maskSp:addChild(self.rewardIconBg,4)
    local scale=100/rewardIcon:getContentSize().width
    rewardIcon:setScale(scale)

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
                if self.halo then
                    self.halo:setVisible(false)
                end
                if self.nameLb then
                    self.nameLb:setVisible(false)
                end
                if self.itemDescLb then
                    self.itemDescLb:setVisible(false)
                end

                self:refresh()
            end
        end
        self.confirmBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",hideMask,4,getlocal("confirm"),25)
        self.confirmBtn:setAnchorPoint(ccp(0.5,0.5))
        local boxSpMenu3=CCMenu:createWithItem(self.confirmBtn)
        boxSpMenu3:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2-120))
        boxSpMenu3:setTouchPriority(-(self.layerNum-1)*20-7)
        self.maskSp:addChild(boxSpMenu3,2)

        self.confirmBtn:setEnabled(false)
        self.confirmBtn:setVisible(false)
    else
        self.confirmBtn:setEnabled(false)
        self.confirmBtn:setVisible(false)
    end

    local pointStr=getlocal("activity_kuangnuzhishi_gotScores").." x"..self.point
    if self.nameLb==nil then
        -- self.nameLb=GetTTFLabelWrap(item.name,22,CCSizeMake(G_VisibleSizeWidth-180,300),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        self.nameLb=GetTTFLabel(item.name.." x"..item.num,25)
        self.nameLb:setAnchorPoint(ccp(0.5,1))
        self.nameLb:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2-10))
        self.maskSp:addChild(self.nameLb,2)
        self.nameLb:setVisible(false)
    else
        self.nameLb:setString(item.name.." x"..item.num)
        self.nameLb:setVisible(false)
    end

    -- if self.pointLb==nil then
    --     self.pointLb=GetTTFLabelWrap(pointStr,22,CCSizeMake(G_VisibleSizeWidth-180,300),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    --     -- self.itemDescLb=GetTTFLabel(item.name,22)
    --     self.pointLb:setAnchorPoint(ccp(0.5,1))
    --     self.pointLb:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2+40))
    --     self.maskSp:addChild(self.pointLb,2)
    --     self.pointLb:setVisible(false)
    -- else
    --     self.pointLb:setString(pointStr)
    --     self.pointLb:setVisible(false)
    -- end

    local isShowDesc=true
    for i=1,4 do
        if item.key=="r"..i then
            isShowDesc=false
        end
    end
    if isShowDesc==true then
        if self.itemDescLb==nil then
            self.itemDescLb=GetTTFLabelWrap(pointStr,22,CCSizeMake(G_VisibleSizeWidth-180,300),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            self.itemDescLb:setAnchorPoint(ccp(0.5,1))
            self.itemDescLb:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2-50))
            self.maskSp:addChild(self.itemDescLb,2)
            self.itemDescLb:setVisible(false)
        else
            self.itemDescLb:setString(pointStr)
            self.itemDescLb:setVisible(false)
        end
    else
        if self.itemDescLb then
            self.itemDescLb:setVisible(false)
        end
    end

    local function playEndCallback()
        local str=G_showRewardTip({self.rewardList[self.endIdx]},false)
        if self.point and self.point>0 then
            str=str..","..getlocal("activity_kuangnuzhishi_gotScores").." x"..self.point
        end
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)

        if self.touchEnabledSp then
            self.touchEnabledSp:setVisible(false)
            self.touchEnabledSp:setPosition(ccp(10000,0))
        end

        if self.confirmBtn then
            self.confirmBtn:setEnabled(true)
            self.confirmBtn:setVisible(true)
        end
        if self.nameLb then
            self.nameLb:setVisible(true)
        end
        if isShowDesc==true then
            if self.itemDescLb then
                self.itemDescLb:setVisible(true)
            end
        end
    end

    local delay1=CCDelayTime:create(0.3)
    local scale1=CCScaleTo:create(0.4,150/rewardIcon:getContentSize().width/scale)
    local scale2=CCScaleTo:create(0.4,100/rewardIcon:getContentSize().width/scale)
    -- local tx,ty=self.playBtnBg:getPosition()
    local mvTo=CCMoveTo:create(0.3,ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2+80))
    local scale3=CCScaleTo:create(0.1,200/rewardIcon:getContentSize().width/scale)
    local scale4=CCScaleTo:create(0.2,120/rewardIcon:getContentSize().width/scale)
    local delay2=CCDelayTime:create(0.2)
    local callFunc=CCCallFuncN:create(playEndCallback)
    
    local acArr=CCArray:create()
    acArr:addObject(delay1)
    acArr:addObject(scale1)
    acArr:addObject(scale2)
    acArr:addObject(mvTo)
    acArr:addObject(scale3)
    acArr:addObject(scale4)
    acArr:addObject(delay2)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.rewardIconBg:runAction(seq)
end


function acKuangnuzhishiTab1:tick()
	local istoday = acKuangnuzhishiVoApi:isToday()
	if istoday ~= self.isToday then
		self:updateShow()
		self.isToday =istoday
	end
	local isend = acKuangnuzhishiVoApi:checkIsEnd()
	if isend ~= self.isEnd then
		self:endUpdate()
		self.isEnd=isend
		acKuangnuzhishiVoApi:updateShow()
	end
end

function acKuangnuzhishiTab1:refresh()
    if self and self.bgLayer then
    	if self.lotteryOneBtn then
	  		self.lotteryOneBtn:setEnabled(true)
	  	end
	  	if self.lotteryTenBtn then
	  		self.lotteryTenBtn:setEnabled(true)
	  	end
    	self:updateShow()
    	self:endUpdate()
    end
    
end


function acKuangnuzhishiTab1:dispose()
	if self.touchEnabledSp then
        self.touchEnabledSp:removeFromParentAndCleanup(true)
        self.touchEnabledSp=nil
    end
    self.isToday = nil 
    self.isEnd = nil 
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    touchEnabledSp=nil
    self = nil
end
