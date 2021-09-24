--月度签到
acMonthlySignDialogTabFree={
   rewardBtnState = nil,
}

function acMonthlySignDialogTabFree:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.tv=nil
	self.bgLayer=nil
	self.layerNum=nil
	return nc;

end

function acMonthlySignDialogTabFree:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	local theBg = LuaCCScale9Sprite:create("arImage/monthlysignFreeBg_ar.jpg",CCRect(0, 0, 598, 780),CCRect(525, 775, 1, 1),function ( ... )end)
	theBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-160-28))
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	theBg:setAnchorPoint(ccp(0.5,1))
	theBg:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-160)
	self.bgLayer:addChild(theBg)
	self:initTableView()

	local capInSet1 = CCRect(20, 20, 10, 10);
	local topForbidHeight = self.bgLayer:getContentSize().height*0.2
	self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet1,function ( ... )end)
	self.topforbidSp:setTouchPriority(-(layerNum-1)*20-3)
	self.topforbidSp:setAnchorPoint(ccp(0.5,1))
	self.topforbidSp:setContentSize(CCSize(self.bgLayer:getContentSize().width,358))
	self.topforbidSp:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height)
	self.bgLayer:addChild(self.topforbidSp)
	self.topforbidSp:setVisible(false)
	if self.tv then
		local freeCfg = acMonthlySignVoApi:getFreeCfg()
		if freeCfg then
			local maxLen = math.ceil(SizeOfTable(freeCfg)/4)
			local todayCfgIndex = acMonthlySignVoApi:getCurrentDay()
			if todayCfgIndex then
				local itemH = (G_VisibleSizeWidth - 100)/4
				local posIndex = math.ceil(todayCfgIndex/4)
				local hang = -itemH * (maxLen - posIndex)+(self.bgLayer:getContentSize().height-430) - (itemH+10) --(maxLen - todayCfgIndex + 1)--maxLen - todayCfgIndex + 1 -- tv 自动跑到当天所在行
				if hang > 0 then
					hang = 0
				end
				-- local hang = -((G_VisibleSizeWidth - 140)/4) * (maxLen - todayCfgIndex)-- tv 自动跑到当天所在行
				local recordPoint = self.tv:getRecordPoint()
				recordPoint.y = hang
				self.tv:recoverToRecordPoint(recordPoint)
			end
		end
	end
	return self.bgLayer
end

function acMonthlySignDialogTabFree:initTableView()

	local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local tabStr={};
		local tabColor ={};
		local td=smallDialog:new()
		tabStr = {"\n",getlocal("activity_monthlysign_freeDesc4"),"\n",getlocal("activity_monthlysign_freeDesc3"),"\n",getlocal("activity_monthlysign_freeDesc2"),"\n",getlocal("activity_monthlysign_freeDesc1"),"\n"}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
		sceneGame:addChild(dialog,self.layerNum+1)
	end

	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	infoItem:setScale(0.8)
	infoItem:setAnchorPoint(ccp(1,0.5))
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setAnchorPoint(ccp(1,0.5))
	infoBtn:setPosition(ccp(G_VisibleSizeWidth - 20,self.bgLayer:getContentSize().height - 190))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(infoBtn,3)
	
	local function callBack(...)
	   return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-400),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(20,48))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(100)
end

function acMonthlySignDialogTabFree:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local freeCfg = acMonthlySignVoApi:getFreeCfg()
		if freeCfg then
			return math.ceil((#freeCfg)/4)
		else
			return 0
		end		
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth - 80,(G_VisibleSizeWidth - 80)/4)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local cfgIndex,cfg
		local MAX = 4
		local freeCfg = acMonthlySignVoApi:getFreeCfg()
		if idx + 1==math.ceil((#freeCfg)/4) then
			MAX=#freeCfg - idx*4
		end
		-- 此时是某月，某天
		local currentMonth,currentDay = acMonthlySignVoApi:getCurrentDate()
		local iconW = (G_VisibleSizeWidth - 80)/4
		local cellH = iconW
		local startX = 20-- 80/2 - 20
		local iconSize = 100--iconW - 10
		for i=1,MAX do
			cfgIndex = idx * 4 + i
			--此条活动配置
			cfg = acMonthlySignVoApi:getFreeCfgByIndex(cfgIndex)
			local vipDouble = tonumber(cfg.vip) or -1 -- 双倍领奖所需要的最小vip等级
			if cfg and cfg.r then
				local reward = FormatItem(cfg.r)
				local function clickIcon(object,fn,tag)
					PlayEffect(audioCfg.mouseClick)
					if(self.tv:getIsScrolled()==true)then
						do return end
					end
					if(tag)then
						local getReward=self:getReward(tag)
						if(getReward==false)then
							local rewardCfg=(acMonthlySignVoApi:getFreeCfgByIndex(tag)).r
							local rewardTmp=FormatItem(rewardCfg)
							local showItemTmp=rewardTmp[1]
							if showItemTmp.type=="e" then
								if showItemTmp.eType=="a" or showItemTmp.eType=="f" then
									local isAccOrFrag=true
									propInfoDialog:create(sceneGame,showItemTmp,self.layerNum+1,nil,nil,nil,nil,nil,isAccOrFrag)
								else
									propInfoDialog:create(sceneGame,showItemTmp,self.layerNum+1)
								end
							elseif showItemTmp.name then
								if showItemTmp.key == "energy" then
									propInfoDialog:create(sceneGame,showItemTmp,self.layerNum+1,nil,true)
								else
									if(showItemTmp.type=="p" and showItemTmp.id>=2001 and showItemTmp.id<=2128) or showItemTmp.key=="p903" or showItemTmp.key=="p904" then
										propInfoDialog:create(sceneGame,showItemTmp,self.layerNum+1,nil,true)
									else
										propInfoDialog:create(sceneGame,showItemTmp,self.layerNum+1)
									end
								end
							end
						end
					end
				end
				local showItem
				for k,v in pairs(reward) do
					if v then
						showItem = v
					end
				end
				local iconBg=LuaCCSprite:createWithSpriteFrameName("monthlysignFreeIconBg.png",clickIcon)
				iconBg:setTag(cfgIndex)
				iconBg:setTouchPriority(-(self.layerNum-1)*20-2)
				iconBg:setIsSallow(false)
				iconBg:setPosition(startX+(i-1)*iconW+iconW/2,cellH-iconBg:getContentSize().height/2)
				cell:addChild(iconBg)

				local icon = G_getItemIcon(showItem,iconSize,false)
				icon:setPosition(getCenterPoint(iconBg))
				iconBg:addChild(icon)
				
				local numBg = CCSprite:createWithSpriteFrameName("monthlysignFreeNumBg.png")
				numBg:setAnchorPoint(ccp(1,0))
				numBg:setPosition(icon:getPositionX()+iconSize/2 - 4,icon:getPositionY()-iconSize/2 +3)
				iconBg:addChild(numBg)

				local numLb = GetTTFLabel("x"..showItem.num,30)
				numLb:setAnchorPoint(ccp(1,0.5))
				numLb:setPosition(numBg:getContentSize().width-5,numBg:getContentSize().height/2)
				numBg:addChild(numLb)
				numLb:setColor(G_ColorYellowPro)
				local vipIcon,doubleLb
				if vipDouble ~= -1 then
					vipIcon = CCSprite:createWithSpriteFrameName("monthlysignFreeVip.png")
					vipIcon:setAnchorPoint(ccp(0,1))
					vipIcon:setPosition(0,iconBg:getContentSize().height)
					iconBg:addChild(vipIcon)
					
					doubleLb=GetTTFLabel(getlocal("activity_monthlysign_free_double",{vipDouble,2}),18)
					doubleLb:setColor(G_ColorYellowPro)
					doubleLb:setAnchorPoint(ccp(0.5,0.5))
					doubleLb:setRotation(-45)
					doubleLb:setPosition(vipIcon:getContentSize().width/2 - 12,vipIcon:getContentSize().height/2 + 11)
					vipIcon:addChild(doubleLb)
				end

				local freeState = acMonthlySignVoApi:getFreeRewardState(cfgIndex)
				if freeState == acMonthlySignVoApi.freeStateHadReward then -- 已领取
					local mask = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
					mask:setContentSize(CCSizeMake(iconBg:getContentSize().width,iconBg:getContentSize().height))
					mask:setOpacity(120)
					mask:setPosition(getCenterPoint(iconBg))
					iconBg:addChild(mask,2)

					local rightIcon=CCSprite:createWithSpriteFrameName("monthlysignFreeGetIcon.png")
					rightIcon:setAnchorPoint(ccp(0.5,0.5))
					rightIcon:setPosition(getCenterPoint(iconBg))
					iconBg:addChild(rightIcon,3)
				elseif freeState == acMonthlySignVoApi.freeStateNoReward then -- 未领奖
					G_addRectFlicker(iconBg,1.8,1.8)
				elseif freeState == acMonthlySignVoApi.freeStateNotOpen then -- 未开启
				elseif freeState == acMonthlySignVoApi.freeStateEnd then -- 时间已过
					local mask = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
					mask:setContentSize(CCSizeMake(iconBg:getContentSize().width,iconBg:getContentSize().height))
					mask:setOpacity(120)
					mask:setPosition(getCenterPoint(iconBg))
					iconBg:addChild(mask,2)
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


function acMonthlySignDialogTabFree:getReward(day)
	print("acMonthlySignDialogTabFree:getReward: ",day)
	local freeState = acMonthlySignVoApi:getFreeRewardState(day)
	if(freeState==acMonthlySignVoApi.freeStateNoReward)then
		local function onRequestEnd(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				local rewardTb
				if sData.data and sData.data.reward then
					rewardTb = FormatItem(sData.data.reward)
				else
					local cfg=acMonthlySignVoApi:getFreeCfgByIndex(day)
					if(cfg and cfg.r)then
						rewardTb = FormatItem(cfg.r)
						local vipDouble=tonumber(cfg.vip) or -1
						if(playerVoApi:getVipLevel()>=vipDouble and vipDouble~=-1)then
							for k,v in pairs(rewardTb) do
								if(v and v.num)then
									v.num=v.num*2
								end
							end
						end
					end
				end
				if rewardTb then
					for k,v in pairs(rewardTb) do
						G_addPlayerAward(v.type,v.key,v.id,v.num,false,true)
					end 
					G_showRewardTip(rewardTb,true)
				end
				acMonthlySignVoApi:afterGetReward()
			end
		end
		socketHelper:monthlysignGetReward(0,day,onRequestEnd)
		return true
	else
		return false
	end
end

function acMonthlySignDialogTabFree:update()
	if self then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
		if self.tv then
			local recordPoint = self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
		end
	end
end

function acMonthlySignDialogTabFree:dispose()
    CCTextureCache:sharedTextureCache():removeTextureForKey("arImage/monthlysignFreeBg_ar.jpg")
end
