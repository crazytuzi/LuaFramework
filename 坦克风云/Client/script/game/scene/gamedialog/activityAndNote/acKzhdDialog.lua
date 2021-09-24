acKzhdDialog=commonDialog:new()

function acKzhdDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.acTab1=nil
	self.acTab2=nil
	self.layerTab1=nil
	self.layerTab2=nil

	local function addPlist()
		spriteController:addPlist("public/acSuperShopImage.plist")
		spriteController:addTexture("public/acSuperShopImage.png")
		spriteController:addPlist("public/acDouble11_NewImage.plist")
		spriteController:addTexture("public/acDouble11_NewImage.png")
	end
	G_addResource8888(addPlist)
	spriteController:addPlist("public/commonBtn1.plist")
    spriteController:addTexture("public/commonBtn1.png")
    spriteController:addPlist("public/packsImage.plist")
    spriteController:addTexture("public/packsImage.png")

    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")
    spriteController:addPlist("public/blueFilcker.plist")
    spriteController:addTexture("public/blueFilcker.png")
    spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addTexture("public/yellowFlicker.png")
	return nc
end

function acKzhdDialog:resetTab()
	local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end

         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    self.selectedTabIndex = 0
end

function acKzhdDialog:initTableView()
	local function refreshFunc(event,data)
		self:refresh()
    end
    self.refreshFunc=refreshFunc
    eventDispatcher:addEventListener("active.kzhd",self.refreshFunc)


	
	-- local function callback( ... )
	-- 	--return self:eventHandler(...)
	-- end
	-- local hd= LuaEventHandler:createHandler(callback)
	-- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)

	self.panelLineBg:setVisible(false)


	if acKzhdVoApi:isToday()==false then
    	acKzhdVoApi:clearData(true)
    end

	--self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    --self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-105))
	self:tabClick(0,false)
end
function acKzhdDialog:tabClick(idx,isEffect)
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
	if(idx==0)then
		if(self.acTab1==nil)then
			self.acTab1=acKzhdDialogTab1:new()
			self.layerTab1=self.acTab1:init(self.layerNum)
			self.bgLayer:addChild(self.layerTab1)
		end
		if self.layerTab1 then
			self.layerTab1:setPosition(ccp(0,0))
			self.layerTab1:setVisible(true)
		end
		if self.layerTab2 then
			self.layerTab2:setPosition(ccp(999333,0))
			self.layerTab2:setVisible(false)
		end
	elseif(idx==1)then
		if(self.acTab2==nil)then
			self.acTab2=acKzhdDialogTab2:new()
			self.layerTab2=self.acTab2:init(self.layerNum)
			self.bgLayer:addChild(self.layerTab2)
		end
		if self.layerTab1 then
			self.layerTab1:setPosition(ccp(999333,0))
			self.layerTab1:setVisible(false)
		end
		if self.layerTab2 then
			self.layerTab2:setPosition(ccp(0,0))
			self.layerTab2:setVisible(true)
			-- self.acTab2:updateTv()
		end
	end
end
function acKzhdDialog:doUserHandler()
end
function acKzhdDialog:tick()
	local vo=acKzhdVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    if self.acTab1 and self.acTab1.tick then
		self.acTab1:tick()
	end

    if acKzhdVoApi:isToday()==false then
    	acKzhdVoApi:clearData(true)
    end
end

function acKzhdDialog:refresh()
	if self.acTab1 and self.acTab1.refresh then
		self.acTab1:refresh(true)
	end
	if self.acTab2 and self.acTab2.refresh then
		self.acTab2:refresh()
	end
end

function acKzhdDialog:fastTick( )
end
function acKzhdDialog:dispose()
	eventDispatcher:removeEventListener("active.kzhd",self.refreshFunc)
	if self.layerTab1 then
        self.acTab1:dispose()
    end
    if self.layerTab2 then
        self.acTab2:dispose()
    end
	self.layerTab1=nil
	self.layerTab2=nil
	self.acTab2=nil
	self.acTab1=nil
	spriteController:removePlist("public/acSuperShopImage.plist")
	spriteController:removeTexture("public/acSuperShopImage.png")
	spriteController:removePlist("public/acDouble11_NewImage.plist")
	spriteController:removeTexture("public/acDouble11_NewImage.png")
	spriteController:removePlist("public/commonBtn1.plist")
    spriteController:removeTexture("public/commonBtn1.png")
    spriteController:removePlist("public/packsImage.plist")
    spriteController:removeTexture("public/packsImage.png")

    spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removeTexture("public/purpleFlicker.png")
    spriteController:removePlist("public/blueFilcker.plist")
    spriteController:removeTexture("public/blueFilcker.png")
    spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")
end