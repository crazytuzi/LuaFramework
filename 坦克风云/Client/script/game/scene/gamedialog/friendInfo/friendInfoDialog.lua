-- @Author hj
-- @Description 好友系统改版总板子
-- @Date 2018-04-18

friendInfoDialog=commonDialog:new()

function friendInfoDialog:new()
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
	spriteController:addPlist("public/smbdPic.plist")
	spriteController:addPlist("public/chatVipNoLevel.plist")
    spriteController:addTexture("public/chatVipNoLevel.png")
    spriteController:addTexture("public/smbdPic.png")
    spriteController:addPlist("public/youhuaUI3.plist")
	spriteController:addTexture("public/youhuaUI3.png")
	return nc
end

function friendInfoDialog:resetTab( ... )
	self.giftEnabled = FuncSwitchApi:isEnabled("friend_gift")
	local index=0
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v
        if self.giftEnabled == true then
        	if index==0 then
	            tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
	        elseif index==1 then
	            tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
	        elseif index==2 then
	            tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
	        end
        else
        	if index==0 then
         		tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
	        elseif index==1 then
         		tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
	        end
        end
        
        if index==self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index=index+1
    end
    self.selectedTabIndex = 0
end

function friendInfoDialog:tabClick(idx)
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

function friendInfoDialog:switchTab(idx)
	if idx==nil then
		idx=1
	end
	if self["tab"..idx]==nil then
   		local tab
   		if(idx==1) then
   			-- 好友列表
   			tab=friendListDialog:new(self.layerNum)
   		elseif(idx==2) then
   			if self.giftEnabled == true then
	   			-- 好友礼物
	   			tab=friendGiftDialog:new(self.layerNum)	
   			else
   				-- 屏蔽列表
	   			tab=friendShieldDialog:new(self.layerNum)
   			end
   		else
   			-- 屏蔽列表
   			tab=friendShieldDialog:new(self.layerNum)
   		end
	   	self["tab"..idx]=tab
	   	self["layerTab"..idx]=tab:init()
	   	self.bgLayer:addChild(self["layerTab"..idx],3)
   	end
   	-- 设置位置
   	for k,v in pairs(self.allTabs) do
   		local _pos=ccp(999999,0)
		local _visible=false
		if(k==idx)then
			_pos=ccp(0,0)
			_visible=true
		end
		if(self["layerTab"..k]~=nil)then
			self["layerTab"..k]:setPosition(_pos)
			self["layerTab"..k]:setVisible(_visible)
		end
   	end
end

function friendInfoDialog:initTableView()
end

function friendInfoDialog:doUserHandler()
	-- 加载资源
	self.panelLineBg:setVisible(false)
	self.panelTopLine:setVisible(false)
	-- self.bgLayer:reorderChild(self.panelTopLine,2)

	local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-157)
    self.bgLayer:addChild(tabLine,5)

	-- 去渐变线
	local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)
	self:tabClick(0)
end

function friendInfoDialog:refreshRedPiont( ... )
	if self.giftEnabled == false then
		do return end
	end
	local tipBg = tolua.cast(self.allTabs[2]:getChildByTag(10),"CCSprite")
	if friendInfoVoApi:isHasUnreceiveNum() == true then
		tipBg:setVisible(true)
		tipBg:setScale(0.7)
		local numLb = tolua.cast(tipBg:getChildByTag(11),"CCLabelTTF")
		numLb:setVisible(false)
	else
		tipBg:setVisible(false)
	end
end

function friendInfoDialog:tick( ... )
	if self.allTabs == nil or next(self.allTabs) == nil then
		do return end
	end
	for k,v in pairs(self.allTabs) do
		if self["tab"..k] and  self["tab"..k].tick then	
			self["tab"..k]:tick()
		end
	end
	self:refreshRedPiont()
end
function friendInfoDialog:dispose()
	spriteController:removePlist("public/smbdPic.plist")
	spriteController:removePlist("public/chatVipNoLevel.plist")
	spriteController:removeTexture("public/smbdPic.png")
	spriteController:removeTexture("public/chatVipNoLevel.png")
	spriteController:removePlist("public/youhuaUI3.plist")
	spriteController:removeTexture("public/youhuaUI3.png")
	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil
	self.tab1=nil
	self.tab2=nil
	self.tab3=nil
	-- self = nil
end
