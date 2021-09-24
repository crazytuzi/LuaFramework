acVipRightDialog=commonDialog:new()

function acVipRightDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.layerNum=layerNum
	self.bgLayer1=nil
	self.bgLayer2=nil
	self.bgLayer3=nil
    self.selectedTabIndex=0
    self.lbTab={}
    self.btnTab={}
    self.cellHeight=nil
    self.isToday=true
	return nc
end

function acVipRightDialog:initTab(tabTb)
   local tabBtn=CCMenu:create()
   local tabIndex=0
   local tabBtnItem;
   if tabTb~=nil then
       for k,v in pairs(tabTb) do

           tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
           
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))
           tabBtnItem:setScaleY(1.4) 
           local function tabClick(idx)
               return self:tabClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabClick)
           
           local lb=GetTTFLabelWrap(v,20,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
           lb:setScaleY(1/1.4)
		   lb:setTag(31)
           if k~=1 then
              lb:setColor(G_TabLBColorGreen)
           end
		   
		   
	  --  		local numHeight=25
			-- local iconWidth=36
			-- local iconHeight=36
	  --  		local newsNumLabel = GetTTFLabel("0",numHeight)
	  --  		newsNumLabel:setPosition(ccp(newsNumLabel:getContentSize().width/2+5,iconHeight/2))
	  --  		newsNumLabel:setTag(11)
	  --  	    local capInSet1 = CCRect(17, 17, 1, 1)
	  --  	    local function touchClick()
	  --  	    end
	  --       local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
			-- if newsNumLabel:getContentSize().width+10>iconWidth then
			-- 	iconWidth=newsNumLabel:getContentSize().width+10
			-- end
	  --       newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
	  --  		newsIcon:ignoreAnchorPointForPosition(false)
	  --  		newsIcon:setAnchorPoint(CCPointMake(1,0.5))
	  --       newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width-2,tabBtnItem:getContentSize().height-30))
	  --       newsIcon:addChild(newsNumLabel,1)
			-- newsIcon:setTag(10)
	  --  		newsIcon:setVisible(false)
		 --    tabBtnItem:addChild(newsIcon)
		   
           -- local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
		   -- lockSp:setAnchorPoint(CCPointMake(0,0.5))
		   -- lockSp:setPosition(ccp(10,tabBtnItem:getContentSize().height/2))
		   -- lockSp:setScaleX(0.7)
		   -- lockSp:setScaleY(0.7)
		   -- tabBtnItem:addChild(lockSp,3)
		   -- lockSp:setTag(30)
		   -- lockSp:setVisible(false)
			
           self.allTabs[k]=tabBtnItem
           tabBtn:addChild(tabBtnItem)
           tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
           tabBtnItem:setTag(tabIndex)
           tabIndex=tabIndex+1
       end
   end
   tabBtn:setPosition(0,0)
   self.bgLayer:addChild(tabBtn)

end
function acVipRightDialog:resetTab()
    local cfg=acVipRightVoApi:getAcCfg()
	local boxCfg=cfg or {}
	if SizeOfTable(boxCfg)==3 then
		self.allTabs={getlocal("activity_vipRight_box_1"),getlocal("activity_vipRight_box_2"),getlocal("activity_vipRight_box_3")}
	elseif SizeOfTable(boxCfg)==2 then
		self.allTabs={getlocal("activity_vipRight_box_1"),getlocal("activity_vipRight_box_2")}
	end
    self:initTab(self.allTabs)
    local index=0
    for k,v in pairs(self.allTabs) do
         local tabBtnItem=v
         local tabBtnHeight=G_VisibleSizeHeight/2-tabBtnItem:getContentSize().height/2+30
         if G_getIphoneType() == G_iphoneX then
         	tabBtnHeight = tabBtnHeight + 20
         end
         if index==0 then
            tabBtnItem:setPosition(100,tabBtnHeight)
         elseif index==1 then
            tabBtnItem:setPosition(248,tabBtnHeight)
         elseif index==2 then
            tabBtnItem:setPosition(394,tabBtnHeight)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    
end

function acVipRightDialog:initTableView()
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
	
	local cfg=acVipRightVoApi:getAcCfg()
	if cfg and SizeOfTable(cfg)>0 then
		-- local function callback()
			self:initBg()
		-- end
		-- acVipRightVoApi:init(callback)
		self:initTabLayer()
		self:tabClick(0)
	end
end

function acVipRightDialog:initBg()
	local adaH = 0
	if G_getIphoneType() == G_iphoneX then
		adaH = 25
	end
	-- local timeTime = GetTTFLabel(getlocal("activity_timeLabel"),25)
	local timeTime=GetTTFLabelWrap(getlocal("activity_timeLabel"),25,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeTime:setAnchorPoint(ccp(0.5,0.5))
	timeTime:setColor(G_ColorYellowPro)
	timeTime:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-115-adaH))
	self.bgLayer:addChild(timeTime)

	-- local timeLb=GetTTFLabel(acVipRightVoApi:getTimeStr(),25)
	local timeLb=GetTTFLabelWrap(acVipRightVoApi:getTimeStr(),25,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeLb:setAnchorPoint(ccp(0.5,0.5))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160-adaH))
	self.bgLayer:addChild(timeLb)
	self.timeLb=timeLb
	self:updateAcTime()
	
	local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter_new.png")
	girlImg:setScale((G_VisibleSizeHeight/2-85)/girlImg:getContentSize().height*0.6)
	girlImg:setAnchorPoint(ccp(0,0))
	local charaH = 50
	if G_getIphoneType() == G_iphoneX then
		charaH = 58
	end
	girlImg:setPosition(ccp(20,G_VisibleSizeHeight/2+charaH))
	self.bgLayer:addChild(girlImg,2)

    local function showInfo()
        local tabStr={" "," "}
        local maxVip=playerVoApi:getMaxLvByKey("maxVip")
        for i=1,maxVip do
        	local goldNum
        	if(i==1)then
        		goldNum=1
        	else
        		goldNum=(i - 1)*2
        	end
        	table.insert(tabStr,2,getlocal("activity_vipRight_desc_common",{i,i*5,i*5,goldNum}))
        end        
        local strSize=25
        if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage() == "ru" then
            strSize=21
        end
        local tabColor ={}
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,strSize,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",showInfo,11,nil,nil)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,G_VisibleSizeHeight-140));
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn)
end

function acVipRightDialog:initTabLayer()
    self:resetTab()

	local cfg=acVipRightVoApi:getAcCfg()
	local boxCfg=cfg or {}
	for k,v in pairs(boxCfg) do
		self["bgLayer"..k]=CCLayer:create()
	    self:initBox(k)
	    self.bgLayer:addChild(self["bgLayer"..k],2)
	end
end

function acVipRightDialog:initBox(index)
	local cfg=acVipRightVoApi:getAcCfg()
	local boxCfg=cfg[index] or {}
	
	local pid=boxCfg.pid
	local prop=propCfg[pid]
	local pic=prop.icon
	local name=getlocal(prop.name)
	local desc=getlocal(prop.description)

	local num=0
	-- local acVo=acVipRightVoApi:getAcVo()
	-- local buyItems=acVo.buyItems or {}
	-- local item=buyItems[index] or {}
	local item=acVipRightVoApi:getVoByPid(pid)
	if item and item.num and tonumber(item.num) then
		num=tonumber(item.num)
	end
	-- local pic=""
	-- local desc=""
	-- if index==1 then
	-- 	pic="item_baoxiang_03.png"
	-- 	desc=getlocal("activity_vipRight_box_desc_1")
	-- elseif index==2 then
	-- 	pic="item_baoxiang_04.png"
	-- 	desc=getlocal("activity_vipRight_box_desc_2")
	-- elseif index==3 then
	-- 	pic="item_baoxiang_07.png"
	-- 	desc=getlocal("activity_vipRight_box_desc_3")
	-- end

	local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	local adaHeight = 440
	local posY = 0
	local adaLoc = 455
	if G_getIphoneType() == G_iphoneX then
		adaHeight = adaHeight + 150
		posY = 35
		adaLoc = adaHeight
	end
	background:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,adaHeight))
	background:setAnchorPoint(ccp(0.5,0))
	background:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-adaLoc))

	local bgSize=background:getContentSize()

	local chestIcon=CCSprite:createWithSpriteFrameName(pic)
	chestIcon:setAnchorPoint(ccp(0,0.5))
	chestIcon:setPosition(20,bgSize.height-70-posY)
	background:addChild(chestIcon)

	local chestDesc=GetTTFLabelWrap(desc,23,CCSizeMake(450, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	chestDesc:setAnchorPoint(ccp(0,0.5))
	chestDesc:setPosition(ccp(130,bgSize.height-70-posY))
	background:addChild(chestDesc)

	local minPosY
	local iconY=chestIcon:getPositionY()-chestIcon:getContentSize().height/2
	local lbY=chestDesc:getPositionY()-chestDesc:getContentSize().height/2
	if(iconY>lbY)then
		minPosY=lbY
	else
		minPosY=iconY
	end

	if G_getIphoneType() == G_iphoneX then
		minPosY = minPosY -35
	end
	local awardBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegistrationAwardsBox.png",CCRect(40, 40, 1, 1),function () end)
	awardBg:setContentSize(CCSizeMake(bgSize.width-40,minPosY-150))
	awardBg:setAnchorPoint(ccp(0.5,1))
	awardBg:setPosition(ccp(bgSize.width/2,minPosY-10))
	background:addChild(awardBg)


	local rewardDesc=GetTTFLabelWrap(getlocal("activity_vipRight_box_get"),20,CCSizeMake(awardBg:getContentSize().width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	-- local rewardDesc=GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",20,CCSizeMake(awardBg:getContentSize().width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	rewardDesc:setAnchorPoint(ccp(0,0.5))
	rewardDesc:setPosition(ccp(20,awardBg:getContentSize().height-32))
	awardBg:addChild(rewardDesc)
	rewardDesc:setColor(G_ColorGreen)

	print("∑∑boxCfg.reward",G_Json.encode(boxCfg.reward))
	local rewardCfg=FormatItem(boxCfg.reward,true,true)
	for k,v in pairs(rewardCfg) do
		-- local function showInfoHandler(hd,fn,idx)
  --           local item=v
  --           if item.type=="e" then
  --             	if item.eType=="a" or item.eType=="f" then
  --               	local isAccOrFrag=true
  --               	propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,nil,isAccOrFrag)
  --             	elseif item and item.pic and item.pic~="" then
  --               	propInfoDialog:create(sceneGame,item,self.layerNum+1)
  --             	end
  --           elseif item and item.name and item.pic and item.num and item.desc then
  --             		propInfoDialog:create(sceneGame,item,self.layerNum+1)
  --         	end
  --       end
		-- local spSize=100
		-- local icon
		-- if v.type=="e" then
		-- 	if v.eType=="a" then
  --               icon=accessoryVoApi:getAccessoryIcon(v.id,60,80,showInfoHandler)
  --           elseif v.eType=="f" then
  --               icon=accessoryVoApi:getFragmentIcon(v.id,60,80,showInfoHandler)
  --           elseif v.eType=="p" and v.pic and v.pic~="" then
  --               icon=GetBgIcon(v.pic,showInfoHandler,nil,80,80)
  --           end
		-- elseif v.pic and v.pic~="" then
		-- 	icon=LuaCCSprite:createWithSpriteFrameName(v.pic,showInfoHandler)
		-- end
		
		local spSize=100
		local icon=G_getItemIcon(v,spSize,true,self.layerNum)

		if icon then
			icon:setAnchorPoint(ccp(0.5,0.5))
			icon:setPosition(ccp(spSize/2+35+130*(k-1),awardBg:getContentSize().height/2-25))
			local iScale=spSize/icon:getContentSize().width
			icon:setScale(iScale)
			icon:setTouchPriority(-(self.layerNum-1)*20-4)
			awardBg:addChild(icon)

			if v.key~="p36" then
				local numLb=GetTTFLabel(v.num,22)
				numLb:setAnchorPoint(ccp(0.5,0.5))
				numLb:setPosition(ccp(spSize/2+35+130*(k-1)+35,awardBg:getContentSize().height/2-35-25))
				-- numLb:setScale(1/iScale)
				awardBg:addChild(numLb,3)
			end
		end
	end

	local height1=minPosY-10-awardBg:getContentSize().height-35
	local height2=minPosY-10-awardBg:getContentSize().height-95

	local vipLevelLb1=GetTTFLabelWrap(getlocal("activity_vipRight_now_your",{playerVoApi:getVipLevel()}),23,CCSizeMake(350, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	vipLevelLb1:setAnchorPoint(ccp(0,0.5))
	vipLevelLb1:setPosition(ccp(20,height1))
	background:addChild(vipLevelLb1)
	vipLevelLb1:setColor(G_ColorYellowPro)

	local numStr=""
	local maxNum=boxCfg.num4Vip[playerVoApi:getVipLevel()+1]
	if maxNum==0 then
		numStr=maxNum
	else
		numStr=getlocal("scheduleChapter",{num,maxNum})
	end
	local canBuyLb=GetTTFLabelWrap(getlocal("activity_vipRight_can_buy",{numStr}),23,CCSizeMake(350, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	canBuyLb:setAnchorPoint(ccp(0,0.5))
	canBuyLb:setPosition(ccp(20,height2))
	background:addChild(canBuyLb)
	table.insert(self.lbTab,index,canBuyLb)

	local iconSize=36
	local numLb=GetTTFLabel(boxCfg.cost,28)
	numLb:setAnchorPoint(ccp(0.5,0.5))
	numLb:setPosition(ccp(bgSize.width-iconSize-90,height1))
	background:addChild(numLb)
	numLb:setColor(G_ColorYellowPro)
	
	local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	goldIcon:setAnchorPoint(ccp(0.5,0.5))
	goldIcon:setPosition(bgSize.width-iconSize/2-50,height1)
	goldIcon:setScale(iconSize/goldIcon:getContentSize().width)
	background:addChild(goldIcon)

	local function onGetReward(tag,object)
		if acVipRightVoApi:canBuy(pid) then
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_discount_maxNum"),30)
			do return end
		end
		local costGems=tonumber(boxCfg.cost) or 0
		if costGems<=0 then
			do return end
		end
		if playerVoApi:getGems()<costGems then
			GemsNotEnoughDialog(nil,nil,costGems-playerVoApi:getGems(),self.layerNum+1,costGems)
			do return end
		end
		local function rewardCallback(fn,data)
	        local ret,sData=base:checkServerData(data)
    	    if ret==true then
    	    	-- print("pid",pid)
    	    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("buyPropPrompt",{name}),30)
				acVipRightVoApi:setBuyNum(pid,tonumber(sData.ts))
			    self:refresh(index)
	        end
		end
		local id=tonumber(pid) or tonumber(RemoveFirstChar(pid))
		socketHelper:buyProc(id,rewardCallback,1,"vipRight")
	end
	local rewardMenuItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onGetReward,index,getlocal("buy"),25)

	rewardMenuItem:setAnchorPoint(ccp(0.5,0.5))
	local rewardMenuBtn=CCMenu:createWithItem(rewardMenuItem)
	rewardMenuBtn:setAnchorPoint(ccp(0.5,0.5))
	rewardMenuBtn:setPosition(ccp(bgSize.width-rewardMenuItem:getContentSize().width/2-20,height2))
	rewardMenuBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	background:addChild(rewardMenuBtn)
	self.btnTab[index]=rewardMenuItem
	table.insert(self.btnTab,index,rewardMenuItem)

	if index==1 and self.bgLayer1 then
		self.bgLayer1:addChild(background)
	elseif index==2 and self.bgLayer2 then
		self.bgLayer2:addChild(background)
	elseif index==3 and self.bgLayer3 then
		self.bgLayer3:addChild(background)
	end

	return self.bgLayer
end

function acVipRightDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		if self.cellHeight==nil then
			local spScale=((G_VisibleSizeHeight/2-85)/262*0.6)
			local descLb=GetTTFLabelWrap(getlocal("activity_vipRight_desc"),22,CCSizeMake(260*1/spScale,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
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
		local descLb=GetTTFLabelWrap(getlocal("activity_vipRight_desc"),22,CCSizeMake(260*1/spScale,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
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

function acVipRightDialog:tabClick(idx)
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
    if self.selectedTabIndex==0 then
    	if self.bgLayer1 then
			self.bgLayer1:setVisible(true)
			self.bgLayer1:setPosition(ccp(0,0))
		end
		if self.bgLayer2 then
			self.bgLayer2:setVisible(false)
			self.bgLayer2:setPosition(ccp(10000,0))
		end
		if self.bgLayer3 then
			self.bgLayer3:setVisible(false)
			self.bgLayer3:setPosition(ccp(10000,0))
		end
    elseif self.selectedTabIndex==1 then
    	if self.bgLayer2 then
			self.bgLayer2:setVisible(true)
			self.bgLayer2:setPosition(ccp(0,0))
		end
		if self.bgLayer1 then
			self.bgLayer1:setVisible(false)
			self.bgLayer1:setPosition(ccp(10000,0))
		end
		if self.bgLayer3 then
			self.bgLayer3:setVisible(false)
			self.bgLayer3:setPosition(ccp(10000,0))
		end
    else
    	if self.bgLayer3 then
			self.bgLayer3:setVisible(true)
			self.bgLayer3:setPosition(ccp(0,0))
		end
		if self.bgLayer1 then
			self.bgLayer1:setVisible(false)
			self.bgLayer1:setPosition(ccp(10000,0))
		end
		if self.bgLayer2 then
			self.bgLayer2:setVisible(false)
			self.bgLayer2:setPosition(ccp(10000,0))
		end
    end
end

function acVipRightDialog:refresh(index)
	if self then
		if index and self["bgLayer"..index] then
			local num=0
			local maxNum=0
			local cfg=acVipRightVoApi:getAcCfg()
			local boxCfg=cfg[index] or {}
			if boxCfg and boxCfg.num4Vip and boxCfg.num4Vip[playerVoApi:getVipLevel()+1] then
				maxNum=tonumber(boxCfg.num4Vip[playerVoApi:getVipLevel()+1]) or 0
			end
			-- local acVo=acVipRightVoApi:getAcVo()
			-- local buyItems=acVo.buyItems or {}
			-- local item=buyItems[index] or {}
			local pid=boxCfg.pid

			local item=acVipRightVoApi:getVoByPid(pid)
			if item and item.num and tonumber(item.num) then
				num=tonumber(item.num)
				local numStr=""
				if maxNum==0 then
					numStr=maxNum
				else
					numStr=getlocal("scheduleChapter",{num,maxNum})
				end
				tolua.cast(self.lbTab[index],"CCLabelTTF"):setString(getlocal("activity_vipRight_can_buy",{numStr}))
			end
		else
			for i=1,3 do
				if self["bgLayer"..i] then
					local num=0
					local maxNum=0
					local cfg=acVipRightVoApi:getAcCfg()
					local boxCfg=cfg[i] or {}
					if boxCfg and boxCfg.num4Vip and boxCfg.num4Vip[playerVoApi:getVipLevel()+1] then
						maxNum=tonumber(boxCfg.num4Vip[playerVoApi:getVipLevel()+1]) or 0
					end
					-- local acVo=acVipRightVoApi:getAcVo()
					-- local buyItems=acVo.buyItems or {}
					-- local item=buyItems[i] or {}
					local pid=boxCfg.pid
					local item=acVipRightVoApi:getVoByPid(pid)
					if item and item.num and tonumber(item.num) then
						num=tonumber(item.num)
						local numStr=""
						if maxNum==0 then
							numStr=maxNum
						else
							numStr=getlocal("scheduleChapter",{num,maxNum})
						end
						tolua.cast(self.lbTab[i],"CCLabelTTF"):setString(getlocal("activity_vipRight_can_buy",{numStr}))
					end
				end
			end
		end
	end
end

function acVipRightDialog:tick()
	if self and self.bgLayer then 
		local vo=acVipRightVoApi:getAcVo()
	    if activityVoApi:isStart(vo) == false then
	        if self then
	            self:close()
	            do return end
	        end
	    end
	end
	local vo=acVipRightVoApi:getAcVo()
	-- print("base.serverTime",base.serverTime)
	-- print("vo.lastBuyTime",vo.lastBuyTime)
	-- print("self.isToday",self.isToday)
	-- print("acVipRightVoApi:isToday()",acVipRightVoApi:isToday())
	if self.isToday==true and acVipRightVoApi:isToday()==false then
		acVipRightVoApi:resetNum()
		self:refresh()
		self.isToday=acVipRightVoApi:isToday()
	end
	self:updateAcTime()
end

function acVipRightDialog:updateAcTime()
    local acVo=acVipRightVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acVipRightDialog:dispose()
	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil
end