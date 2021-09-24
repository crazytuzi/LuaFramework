acSecretshopDialog=commonDialog:new()

function acSecretshopDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.acTab1=nil
	self.acTab2=nil
	self.layerTab1=nil
	self.layerTab2=nil
	spriteController:addPlist("public/packsImage.plist")
    spriteController:addTexture("public/packsImage.png")
    spriteController:addPlist("public/bgFireImage.plist")
    spriteController:addTexture("public/bgFireImage.png")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/acSecretshopImage.plist")
    spriteController:addTexture("public/acSecretshopImage.png")

	-- local function addPlist()
	-- end
	-- G_addResource8888(addPlist)
	-- spriteController:addPlist("public/commonBtn1.plist")
 --    spriteController:addTexture("public/commonBtn1.png")
   CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	return nc
end

function acSecretshopDialog:resetTab()
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

    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight - 158)
end

function acSecretshopDialog:initTableView()
	local function refreshFunc(event,data)
		self:refresh()
    end
    self.refreshFunc=refreshFunc
    eventDispatcher:addEventListener("active.secretshop",self.refreshFunc)
	-- local function callback( ... )
	-- 	--return self:eventHandler(...)
	-- end
	-- local hd= LuaEventHandler:createHandler(callback)
	-- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)

	self.panelLineBg:setVisible(false)


	if acSecretshopVoApi:isToday()==false then
    	acSecretshopVoApi:clearData(true)
    end

	--self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    --self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-105))
	self:tabClick(0,false)
end
function acSecretshopDialog:tabClick(idx,isEffect)
	if isEffect==nil then
		isEffect=true
	end
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
			self.acTab1=acSecretshopDialogTab1:new()
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
			self.acTab2=acSecretshopDialogTab2:new()
			self.layerTab2=self.acTab2:init(self.layerNum)
			self.bgLayer:addChild(self.layerTab2)
		else
			self.acTab2:refresh()
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
function acSecretshopDialog:doUserHandler()
end
function acSecretshopDialog:tick()
	local vo=acSecretshopVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    if self.acTab1 and self.acTab1.tick then
		self.acTab1:tick()
	end

    if acSecretshopVoApi:isToday()==false then
    	acSecretshopVoApi:clearData(true)
    end
end

function acSecretshopDialog:refresh()
	if self.acTab1 and self.acTab1.refresh then
		self.acTab1:refresh(true)
	end
	if self.acTab2 and self.acTab2.refresh then
		self.acTab2:refresh()
	end
end

function acSecretshopDialog:fastTick( )
end
function acSecretshopDialog:dispose()
	eventDispatcher:removeEventListener("active.secretshop",self.refreshFunc)
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
	spriteController:removePlist("public/packsImage.plist")
    spriteController:removeTexture("public/packsImage.png")
    spriteController:removePlist("public/bgFireImage.plist")
    spriteController:removeTexture("public/bgFireImage.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/acSecretshopImage.plist")
    spriteController:removeTexture("public/acSecretshopImage.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	
end