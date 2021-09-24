acXlpdDialog=commonDialog:new()

function acXlpdDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum

	nc.layerTab1=nil
	nc.layerTab2=nil
	nc.tab1=nil
	nc.tab2=nil
	nc.selectIdx = 2--默认为跳转第二个签的idex
	nc.lastTime = G_getWeeTs(base.serverTime)
	-- nc.isCanSocketGetOverData = acXlpdVoApi:isCanSocketGetOverData()
	-- nc.isShowedUpLvl = false
	return nc
end
function acXlpdDialog:dispose()
	if self.tab1 and self.tab1.dispose then
		self.tab1:dispose()
	end
	if self.tab2 and self.tab2.dispose then
		self.tab2:dispose()
	end

    self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil
	self.selectIdx = nil
	spriteController:removePlist("public/youhuaUI4.plist")
    spriteController:removeTexture("public/youhuaUI4.png")
	spriteController:removePlist("public/acXlpdImage1.plist")
    spriteController:removeTexture("public/acXlpdImage1.png")
    spriteController:removePlist("public/acXlpdImage2.plist")
    spriteController:removeTexture("public/acXlpdImage2.png")
    spriteController:removePlist("public/acXlpdImage3.plist")
    spriteController:removeTexture("public/acXlpdImage3.png")
    spriteController:removePlist("public/commonBtn1.plist")
    spriteController:removeTexture("public/commonBtn1.png")
    spriteController:removePlist("public/yellowWaterActionImage.plist")
    spriteController:removeTexture("public/yellowWaterActionImage.png")
    spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removePlist("public/acXlpd_images.plist")
   	spriteController:removeTexture("public/acXlpd_images.png")
   	spriteController:removePlist("public/rewardCenterImage.plist")
	spriteController:removeTexture("public/rewardCenterImage.png")

	-- G_removeRequiredByName("luascript/script/game/scene/gamedialog/activityAndNote/acXlpdTabOne")
	-- package.preload["luascript/script/game/scene/gamedialog/activityAndNote/acXlpdTabOne"] = nil
	-- package.loaded["luascript/script/game/scene/gamedialog/activityAndNote/acXlpdTabOne"] = nil    
end

function acXlpdDialog:resetTab()
	self.panelLineBg:setVisible(false)
	self.panelShadeBg:setVisible(true)--
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/yellowWaterActionImage.plist")
    spriteController:addTexture("public/yellowWaterActionImage.png")
    spriteController:addPlist("public/acXlpdImage1.plist")
    spriteController:addTexture("public/acXlpdImage1.png")
    spriteController:addPlist("public/acXlpdImage2.plist")
    spriteController:addTexture("public/acXlpdImage2.png")
    spriteController:addPlist("public/acXlpdImage3.plist")
    spriteController:addTexture("public/acXlpdImage3.png")
    spriteController:addPlist("public/commonBtn1.plist")
    spriteController:addTexture("public/commonBtn1.png")
    spriteController:addPlist("serverWar/serverWar.plist")
    spriteController:addTexture("serverWar/serverWar.pvr.ccz")
    spriteController:addPlist("public/youhuaUI4.plist")
   	spriteController:addTexture("public/youhuaUI4.png")
   	spriteController:addPlist("public/acXlpd_images.plist")
   	spriteController:addTexture("public/acXlpd_images.png")
   	spriteController:addPlist("public/rewardCenterImage.plist")
	spriteController:addTexture("public/rewardCenterImage.png")

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	local index=0
	local anPosTb = {ccp(1,0),ccp(0,0)}
	local titleTb = {getlocal("activity_xlpd_subTitle2"),getlocal("activity_xlpd_subTitle3")}
	local picTb = {{"lGreenBtn1912.png", "lGreenBtn1912_down.png"}, {"rGreenBtn1912.png", "rGreenBtn1912_down.png"}}
	local function tabHandle(idx,object)
		print("idx===>>>",idx)
		if idx == 1 then
			if not acXlpdVoApi:isCanJoinTeam() then--------------攀登比拼 开关
				G_showTipsDialog(getlocal("activity_xlpd_canNotJoinTeam"))
				do return end
			end
			self:newTabClick(self.selectIdx)
			self.selectIdx = self.selectIdx == 1 and 2 or 1
			local btn   = tolua.cast(object,"CCMenuItemToggle")
			local btnLb = tolua.cast(btn:getChildByTag(101),"CCLabelTTF")
			btnLb:setString(getlocal("activity_xlpd_subTitle"..self.selectIdx))
		else
			local needTb = {}
			needTb[1] = "xlpdShop"
			needTb[2] = getlocal("activity_xlpd_subTitle3")
			needTb[3] = self.tab1 and self.tab1 or nil
			G_showCustomizeSmallDialog(self.layerNum + 10,needTb)
		end
	end
	for i=1,2 do--lbTag:101
		local tabBtnItem,tabBtnMenu = G_createBotton(self.bgLayer, ccp(G_VisibleSizeWidth * 0.5 , 0), {titleTb[i], 25}, picTb[i][1], picTb[i][2], picTb[i][1], tabHandle, 1, -(self.layerNum - 1) * 20 - 2, 1,i,anPosTb[i])
	end
	self:newTabClick(1)
end

function acXlpdDialog:initTableView()
	-- if acXlpdVoApi:isCanSocketGetOverData() then
	-- 	self:showOverPanel()
	-- end
end


function acXlpdDialog:newTabClick(idx)
	local function realSwitch()
		self:switchTab(idx)	
	end
	if idx == 2 then
		if acXlpdVoApi:isShopOpen() then
			realSwitch()
			do return end
		end
		if acXlpdVoApi:getNeedRefreshTeamData() then
			acXlpdVoApi:setNeedRefreshTeamData()
		end
		acXlpdVoApi:xlpdRequest("get", {}, realSwitch)
	else
		realSwitch()
	end
end
function acXlpdDialog:switchTab(type)
	if type==nil then
		type=1
	end

	local function showTab( )
		if self["tab"..type]==nil then
	   		local tab
	   		if(type==1)then
	   			tab=acXlpdTabOne:new(self)
	   		else
	   			tab=acXlpdTabTwo:new(self)
	   		end
		   	self["tab"..type]=tab
		   	self["layerTab"..type]=tab:init(self.layerNum)
		   	self.bgLayer:addChild(self["layerTab"..type])
	   	end
		for i=1,2 do
			if(i==type)then
				if(self["layerTab"..i]~=nil)then
					self["layerTab"..i]:setPosition(ccp(0,0))
					self["layerTab"..i]:setVisible(true)
				end
			else
				if(self["layerTab"..i]~=nil)then
					self["layerTab"..i]:setPosition(ccp(999333,0))
					self["layerTab"..i]:setVisible(false)
				end
			end
		end
	end 

	showTab()
	self:refresh(type)
end

function acXlpdDialog:refresh( tab )
	if tab == 1 then
		if self.tab1 then
			self.tab1:refresh("gBox")
		end
	end
end
function acXlpdDialog:doUserHandler()
end

function acXlpdDialog:tick()
	if acXlpdVoApi:isEnd() then
		self:close()
	else
		if self.lastTime ~= G_getWeeTs(base.serverTime) then
			self.lastTime = G_getWeeTs(base.serverTime)
			if self.selectIdx == 1 then
				self:newTabClick(self.selectIdx)
				self.selectIdx = 2
			end
		end

		if self.tab1 and self.tab1.tick then
			self.tab1:tick()
		end
		if self.tab2 and self.tab2.tick then
			self.tab2:tick()
		end
	end
end

