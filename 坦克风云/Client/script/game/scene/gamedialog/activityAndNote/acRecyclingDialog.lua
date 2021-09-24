acRecyclingDialog=commonDialog:new()

function acRecyclingDialog:new( layerNum )
	local nc = {}
	setmetatable(nc,self)
	self.__index =self
	self.acTab1=nil
	self.acTab2=nil
	self.acTab3=nil

	self.layerTab1=nil
	self.layerTab2=nil
	self.layerTab3=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFeixutansuo.plist")
  spriteController:addPlist("serverWar/serverWar.plist")
  spriteController:addTexture("serverWar/serverWar.pvr.ccz")
  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("scene/radianSliderUI.plist")
	self.layerNum=layerNum
	return nc
end

function acRecyclingDialog:resetTab( )
	local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end

            self.acTab1=acRecyclingTab1:new(self.layerNum)
            self.layerTab1=self.acTab1:init()
            self.bgLayer:addChild(self.layerTab1);
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)

            self.acTab2=acRecyclingTab2:new(self.layerNum)
            self.layerTab2=self.acTab2:init()
            self.bgLayer:addChild(self.layerTab2);
            self.layerTab2:setPosition(ccp(10000,0))
            self.layerTab2:setVisible(false)

            self.acTab3=acRecyclingTab3:new(self.layerNum)
            self.layerTab3=self.acTab3:init()
            self.bgLayer:addChild(self.layerTab3)
            self.layerTab3:setPosition(ccp(10000,0))
            self.layerTab3:setVisible(false)
end

function acRecyclingDialog:tabClick(idx,isEffect)
	if(isEffect)then
		PlayEffect(audioCfg.mouseClick)
	end
  	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
    if idx==0 then
        self.layerTab1:setVisible(true)
        self.layerTab1:setPosition(ccp(0,0))
        
        self.layerTab2:setVisible(false)
        self.layerTab2:setPosition(ccp(99930,0))
        if self.layerTab3~=nil then
           self.layerTab3:setVisible(false)
           self.layerTab3:setPosition(ccp(99930,0))
        end
    elseif idx==1 then
        self.layerTab1:setVisible(false)
        self.layerTab1:setPosition(ccp(10000,0))
        
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))
        if self.layerTab2 then
            self.acTab2:updateTv()
        end
        if self.layerTab3~=nil then
           self.layerTab3:setVisible(false)
           self.layerTab3:setPosition(ccp(99930,0))
        end    
    elseif idx==2 then
        self.layerTab1:setVisible(false)
        self.layerTab1:setPosition(ccp(99930,0))
        
        self.layerTab2:setVisible(false)
        self.layerTab2:setPosition(ccp(99930,0))
        
        if self.layerTab3==nil then

                    self.acTab3=acRecyclingTab3:new(self.layerNum)
                    self.layerTab3=self.acTab3:init()
                    self.bgLayer:addChild(self.layerTab3);
                    self.layerTab3:setVisible(true)
                    self.layerTab3:setPosition(ccp(0,0))

        else
           self.layerTab3:setVisible(true)
           self.layerTab3:setPosition(ccp(0,0))
        end
        if self.layerTab3 then
            self.acTab3:resetSlider()
        end
    end
end

function acRecyclingDialog:initTableView()
	
	local function callback( ... )
		--return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)

	--self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    --self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-105))


    local function callback(fn,data)
    	  local ret,sData=base:checkServerData(data)
	      if ret==true then
	      	if sData.data["huiluzaizao"]["list"] then
	      		acRecyclingVoApi:setRewardList(sData.data["huiluzaizao"]["list"])
	      		self:update()
	      	end
	      end
    end

    if acRecyclingVoApi:getRewardList()==nil then
    	socketHelper:activityhuiluzaizaoRewardList(callback)
    end
	self:tabClick(0,false)
end

function acRecyclingDialog:tick()
	local vo=acRecyclingVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
	if self and self.bgLayer and self.acTab1 and self.layerTab1 then 
		self.acTab1:tick()
	end
end

function acRecyclingDialog:update()
	if self and self.bgLayer and self.acTab1 and self.layerTab1 then 
		self.acTab1:updateShowTv()
	end
end

function acRecyclingDialog:dispose()
	if self.layerTab1 then
		self.acTab1:dispose()
	end
	if self.layerTab2 then
		self.acTab2:dispose()
	end
  if self.layerTab3 then
    self.acTab3:dispose()
  end
	self.acTab1=nil
	self.acTab2=nil
	self.layerTab1=nil
	self.layerTab2=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acFeixutansuo.plist")
  spriteController:removePlist("serverWar/serverWar.plist")
  spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("scene/radianSliderUI.plist")
end