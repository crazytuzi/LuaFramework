-- @Author hj
-- @Description 新春聚惠总板子
-- @Date 2018-12-24

acXcjhDialog=commonDialog:new()

function acXcjhDialog:new( ... )
	local nc = {
		layerTab1=nil,
		layerTab2=nil,
		layerTab3=nil,
		tab1=nil,
		tab2=nil,
		tab3=nil
	}
	setmetatable(nc,self)
	self.__index = self
	return nc
end

function acXcjhDialog:resetTab( ... )

	local index=0

    for k,v in pairs(self.allTabs) do
         
	    local  tabBtnItem=v
	    if index==0 then
	     	tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		elseif index==1 then
	     	tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
	    elseif index==2 then
	     	tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
	    end

	    if index==self.selectedTabIndex then
	         tabBtnItem:setEnabled(false)
	    end 
	    index=index+1

    end

end

function acXcjhDialog:tabClick(idx)

	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end

	self:switchTab(idx+1)
end

function acXcjhDialog:switchTab(idx)

	if idx==nil then
		idx=1
	end

	if self["tab"..idx]==nil then
   		local tab
   		if (idx==1) then
   			tab=acXcjhZcjbDialog:new(self.layerNum,self)
   		elseif (idx==2) then
   			tab=acXcjhDailyTaskDialog:new(self.layerNum,self)
   		elseif (idx==3) then
   			tab=acXcjhRewardDialog:new(self.layerNum,self)
   		end
	   	self["tab"..idx]=tab
	   	self["layerTab"..idx]=tab:init()
	   	self.bgLayer:addChild(self["layerTab"..idx],3)
   	end

   	-- 刷新数据

   	if idx == 2 and self["tab"..2] and self["tab"..2].refreshTv then
   		self["tab"..2]:refreshTv()
   	elseif idx == 3 and self["tab"..3] then
		if self["tab"..3].refreshStatus then
   			self["tab"..3]:refreshStatus()
   		end
   		if self["tab"..3].refreshTv then
   			self["tab"..3]:refreshTv()
   		end
   		if self["tab"..3].refreshHero then
   			self["tab"..3]:refreshHero()
   		end
   	end

   	if self.bgLayer and self.bgLayer:getChildByTag(1016) then
   		if idx == 1 then
   			self.bgLayer:getChildByTag(1016):setPosition(ccp(0,0))
   		else
   			self.bgLayer:getChildByTag(1016):setPosition(ccp(99999,0))
   		end
   	end

   	-- 设置位置
	for i=1,3 do
		local pos=ccp(999999,0)
		local visible=false
		if(i==idx)then
			pos=ccp(0,0)
			visible=true
		end
		if(self["layerTab"..i]~=nil)then
			self["layerTab"..i]:setPosition(pos)
			self["layerTab"..i]:setVisible(visible)
		end
	end

end

function acXcjhDialog:doUserHandler( ... )

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	
	spriteController:addPlist("public/xcjh.plist")
	spriteController:addPlist("public/acChunjiepansheng4.plist")
    spriteController:addTexture("public/xcjh.png")
    spriteController:addTexture("public/acChunjiepansheng4.png")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/acChunjiepansheng4.plist")
	spriteController:addTexture("public/acChunjiepansheng4.png")
	spriteController:addPlist("public/acXcjhTiket.plist")
	spriteController:addTexture("public/acXcjhTiket.png")
    spriteController:addPlist("public/acXcjhImage_v2.plist")
   	spriteController:addTexture("public/acXcjhImage_v2.png")

   	spriteController:addPlist("public/acCustomImage.plist")
    spriteController:addTexture("public/acCustomImage.png")

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)


	if self.panelLineBg then
		self.panelLineBg:setVisible(false)
	end
	if self.panelTopLine then
		self.panelTopLine:setVisible(false)
	end
	
	local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-157)
    self.bgLayer:addChild(tabLine,2)

	-- 去渐变线
	local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,2)
    self.bgLayer:addChild(panelBg)

	--标题框
	local titleBacksprie
	if acXcjhVoApi:getVersion()==1 then
		titleBacksprie = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
		titleBacksprie:setContentSize(CCSizeMake(G_VisibleSizeWidth,90))
	else
		titleBacksprie = LuaCCScale9Sprite:createWithSpriteFrameName("acci_timeBg.png", CCRect(86, 25, 2, 2), function()end)
		titleBacksprie:setContentSize(CCSizeMake(G_VisibleSizeWidth,titleBacksprie:getContentSize().height))
	end
	self.bgLayer:addChild(titleBacksprie,4)
	titleBacksprie:setAnchorPoint(ccp(0.5,1))
	titleBacksprie:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))

	-- i说明
	local function touchTip()
		local tabStr = {}
		for i=1,7 do
			if acXcjhVoApi:getVersion()==1 then
				table.insert(tabStr,getlocal("activity_xcjh_I"..i))
			else
				if i==1 or i==2 then
					table.insert(tabStr,getlocal("activity_xcjh_I"..i.."_v2"))
				else
					table.insert(tabStr,getlocal("activity_xcjh_I"..i))
				end
			end
		end
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	if acXcjhVoApi:getVersion()==1 then
		G_addMenuInfo(titleBacksprie,self.layerNum,ccp(titleBacksprie:getContentSize().width-40,45),{},nil,nil,28,touchTip,true)
	else
		G_addMenuInfo(titleBacksprie,self.layerNum,ccp(titleBacksprie:getContentSize().width-32,32),{},nil,0.7,28,touchTip,true)
	end


	local fontSize
	if acXcjhVoApi:getVersion()==1 then
		fontSize = 24
		if G_isAsia() == false then
			fontSize = 20
		end
	else
		fontSize = 20
		if G_isAsia() == false then
			fontSize = 16
		end
	end

	local descStr1=acXcjhVoApi:getTimeStr()
    local descStr2=acXcjhVoApi:getRewardTimeStr()
	local lbRollView,timeLb,rewardLb
	if acXcjhVoApi:getVersion()==1 then
		lbRollView,timeLb,rewardLb=G_LabelRollView(CCSizeMake(titleBacksprie:getContentSize().width-60,32),descStr1,fontSize,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
		lbRollView:setPosition(30,40)
	else
		lbRollView,timeLb,rewardLb=G_LabelRollView(CCSizeMake(titleBacksprie:getContentSize().width-60,32),descStr1,fontSize,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
		lbRollView:setPosition(30,30)
	end
	self.timeLb = timeLb
	self.rewardLb = rewardLb
	
	titleBacksprie:addChild(lbRollView)
	self.lbRollView = lbRollView

	local strSize
	if acXcjhVoApi:getVersion()==1 then
		strSize = 25
		if G_isAsia() == false then
			strSize = 20
		end
	else
		strSize = 21
		if G_isAsia() == false then
			strSize = 15
		end
	end
	local rewardtimeLb = GetTTFLabel(getlocal("activity_xcjh_allend"),strSize,true)
	rewardtimeLb:setAnchorPoint(ccp(0.5,1))
	rewardtimeLb:setPosition(ccp(9999,0))
	titleBacksprie:addChild(rewardtimeLb)
	self.rewardtimeLb = rewardtimeLb

	self:freshTimelabel()

	-- 跨天加监听事件
	local function listener(event,data)
		self:refreshDay()
	end

	self.listener = listener
	if(eventDispatcher:hasEventHandler("overADay",self.listener)==false)then
		eventDispatcher:addEventListener("overADay",self.listener)
	end

	local bigNumber = acXcjhVoApi:getBigRewardNum()
	if #bigNumber == 0 then
		local function callback(fn,data)
			local ret,sData = base:checkServerData(data)
            if ret==true then 
            	if sData.data and sData.data.tdj then
            		acXcjhVoApi:setBgigRewardNum(sData.data.tdj)
            	end
            end
		end
		socketHelper:acXcjhGetNumber(callback)
	end

	self:tabClick(0)
end

function acXcjhDialog:tick( ... )
	
	local acVo=acXcjhVoApi:getAcVo()
	if acVo then 
		if activityVoApi:isStart(acVo) == false then --活动结束 板子还开着，就要强制关板子
			if self~=nil then
				self:close()
			end
		end
	end

	self:updateAcTime()
	for i=1,3,1 do
		if self["tab"..i] and  self["tab"..i].tick then	
			self["tab"..i]:tick()
		end
	end
	self:refreshRedpoint()
end

function acXcjhDialog:updateAcTime()
	if self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
		self.timeLb:setString(acXcjhVoApi:getTimeStr())
    end
    if self.rewardLb and tolua.cast(self.rewardLb,"CCLabelTTF") then
    	self.rewardLb:setString(acXcjhVoApi:getRewardTimeStr())
    end
end

function acXcjhDialog:fastTick()
	for i=1,3,1 do
		if self["tab"..i] and  self["tab"..i].fastTick then	
			self["tab"..i]:fastTick()
		end
	end
end

function acXcjhDialog:freshTimelabel( ... )
	if acXcjhVoApi:isRewardCenterTime() == true then
		-- if self.timeLb then
		-- 	self.timeLb:setPosition(ccp(99999,0))
		-- end
		-- if self.rTimeLb then
		-- 	self.rTimeLb:setPosition(ccp(99999,0))
		-- end
		if self.lbRollView then
			self.lbRollView:setVisible(false)
		end

		if self.rewardtimeLb then
			if acXcjhVoApi:getVersion()==1 then
				self.rewardtimeLb:setPosition(ccp(G_VisibleSizeWidth/2,80))
			else
				self.rewardtimeLb:setPosition(ccp(G_VisibleSizeWidth/2,60))
			end
		end
	end
end

function acXcjhDialog:refreshDay( ... )

	-- if acXcjhVoApi:isGetRewardTime() == true then
	-- 	-- 抽奖时间跨天重置免费
	-- 	acXcjhVoApi:setFirstFree(0)
	-- end

	-- local vo = acXcjhVoApi:getAcVo()
	-- if vo then
	-- 	activityVoApi:updateShowState(vo)
	-- end

	-- acXcjhVoApi:initTask()
	self:freshTimelabel()

	if  self["tab"..3] then
		if self["tab"..3].refreshHero then
   			self["tab"..3]:refreshHero()
   		end
   		if self["tab"..3].refreshTv then
   			self["tab"..3]:refreshTv()
   		end
   	end

   	if  self["tab"..2] and self["tab"..2].refreshTv then
   		self["tab"..2]:refreshTv()
   	end

	if  self["tab"..1] and self["tab"..1].refreshBtn then
		self["tab"..1]:refreshBtn()
	end

	local acVo=acXcjhVoApi:getAcVo()
	if acVo then 
		if activityVoApi:isStart(acVo) == false then --活动结束 板子还开着，就要强制关板子
			if self~=nil then
				self:close()
			end
		end
	end
end


function acXcjhDialog:refreshRedpoint( ... )

	local num = acXcjhVoApi:getCanRewardNum()
	local tipBg = tolua.cast(self.allTabs[2]:getChildByTag(10),"CCSprite")
	local numLb = tolua.cast(tipBg:getChildByTag(11),"CCLabelTTF")
	if num > 0 then
		tipBg:setVisible(true)
		numLb:setString(num)
		numLb:setPosition(ccp(17,18))
	else
		tipBg:setVisible(false)
   	end

end

function acXcjhDialog:dispose( ... )
	
	spriteController:removePlist("public/xcjh.plist")
	spriteController:removePlist("public/acChunjiepansheng4.plist")
    spriteController:removeTexture("public/xcjh.png")
    spriteController:removeTexture("public/acChunjiepansheng4.png")
    spriteController:removePlist("public/taskYouhua.plist")
	spriteController:removeTexture("public/taskYouhua.png")
	spriteController:removePlist("public/acChunjiepansheng4.plist")
 	spriteController:removeTexture("public/acChunjiepansheng4.png")
 	spriteController:removePlist("public/acXcjhTiket.plist")
	spriteController:removeTexture("public/acXcjhTiket.png")
	spriteController:removePlist("public/acXcjhImage_v2.plist")
   	spriteController:removeTexture("public/acXcjhImage_v2.png")
   	spriteController:removePlist("public/acCustomImage.plist")
   	spriteController:removeTexture("public/acCustomImage.png")

 	eventDispatcher:removeEventListener("overADay",self.listener)
	self.listener = nil
	
	-- body
	if self.layerTab1 then
		self.tab1:dispose()
    end
    if self.layerTab2 then
    	self.tab2:dispose()
    end
    if self.layerTab3 then
    	self.tab3:dispose()
    end

	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil
	self.tab1=nil
	self.tab2=nil
	self.tab3=nil

end