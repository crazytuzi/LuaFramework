acGeneralRecallDialog = commonDialog:new()

function acGeneralRecallDialog:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.tab1 = nil
	self.layerTab1 = nil
	self.tab2 = nil
	self.layerTab2 = nil

	  spriteController:addPlist("public/acthreeyear_images.plist")
    spriteController:addTexture("public/acthreeyear_images.png")
    spriteController:addPlist("public/acGeneralRecallImage.plist")
    spriteController:addTexture("public/acGeneralRecallImage.png")
    spriteController:addPlist("public/acolympic_images.plist")
    spriteController:addTexture("public/acolympic_images.png")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/serverWarLocal/serverWarLocal2.plist")
    spriteController:addTexture("public/serverWarLocal/serverWarLocal2.png")
    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")
    spriteController:addPlist("public/acRadar_images.plist")
    spriteController:addTexture("public/acRadar_images.png")
    spriteController:addPlist("public/acOpenyearImage.plist")
    spriteController:addTexture("public/acOpenyearImage.png")
    spriteController:addPlist("public/acDjrecall_images.plist")
    spriteController:addTexture("public/acDjrecall_images.png")
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")

    local function addPlist()
        spriteController:addPlist("public/wsjdzzImage.plist")
        spriteController:addTexture("public/wsjdzzImage.png")
    end
    G_addResource8888(addPlist)
	return nc
end

function acGeneralRecallDialog:resetTab( )
	
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
    self:tabClick(0,false)
end

function acGeneralRecallDialog:tabClick(idx )

    -- PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self:getDataByIdx(idx+1)
            self.selectedTabIndex=idx
         else
            v:setEnabled(true)
         end
    end
end

function acGeneralRecallDialog:switchTab(idx)
    if idx==2 then

        if self.layerTab2==nil then
            self.tab2=acGeneralRecallTab2:new()
            self.layerTab2=self.tab2:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab2)
        else
            self.layerTab2:setVisible(true)
        end
        self.layerTab2:setPosition(ccp(0,0))

        if self.layerTab1 ~= nil then
           self.layerTab1:setPosition(ccp(999333,0))
           self.layerTab1:setVisible(false)
        end
            
    elseif idx==1 then
            
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
        
        if self.layerTab1==nil then
            self.tab1=acGeneralRecallTab1:new()
            self.layerTab1=self.tab1:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab1)
        else
          self.layerTab1:setVisible(true)
        end
        self.layerTab1:setPosition(ccp(0,0))

    end

    if self["tab"..idx].updateUI then --切换页签时页面刷新处理
      self["tab"..idx]:updateUI()
    end
end

function acGeneralRecallDialog:getDataByIdx(tabType)
    -- self:hideTabAll()
    if tabType==nil then
        tabType=1
    end
    local ptype=acGeneralRecallVoApi:getPlayerType() --玩家类型（流失玩家还是活跃玩家）
    if tabType==2 then
      if ptype==2 then
          local function callBack()
              self:switchTab(tabType)
          end
          acGeneralRecallVoApi:socketGeneralRecall("active.djrecall.task",nil,callBack)
      else
        self:switchTab(tabType)
      end
    else
      if ptype==2 then
        local function callBack()
            local function onGetAccessoryCallBack()
              self:switchTab(tabType)
            end
            acGeneralRecallVoApi:getAllAccessory(onGetAccessoryCallBack)
        end
        acGeneralRecallVoApi:socketGeneralRecall("active.djrecall.bindList",nil,callBack)
      else
        self:switchTab(tabType)
      end
    end
end

function acGeneralRecallDialog:tick()
  local acVo = acGeneralRecallVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    end
  end
  if self and self.bgLayer then
      for i=1,2 do
          if self["tab"..i]~=nil and self["tab"..i].tick then
              self["tab"..i]:tick()
          end
      end
  end
end

function acGeneralRecallDialog:dispose()
    if self.layerTab1 then
        self.tab1:dispose()
        self.tab1 = nil
	    self.layerTab1 = nil
    end

    if self.layerTab2 then
    	self.tab2:dispose()
    	self.tab2 =nil
    	self.layerTab2=nil
    end--acGeneralRecallImage
    spriteController:removePlist("public/acGeneralRecallImage.plist")
    spriteController:removeTexture("public/acGeneralRecallImage.png")
    spriteController:removePlist("public/acthreeyear_images.plist")
    spriteController:removeTexture("public/acthreeyear_images.png")
    spriteController:removePlist("public/acolympic_images.plist")
    spriteController:removeTexture("public/acolympic_images.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/wsjdzzImage.plist")
    spriteController:removeTexture("public/wsjdzzImage.png")
    spriteController:removePlist("public/serverWarLocal/serverWarLocal2.plist")
    spriteController:removeTexture("public/serverWarLocal/serverWarLocal2.png")
    spriteController:removePlist("public/acAnniversary.plist")
    spriteController:removeTexture("public/acAnniversary.png")
    spriteController:removePlist("public/acRadar_images.plist")
    spriteController:removeTexture("public/acRadar_images.png")
    spriteController:removePlist("public/acOpenyearImage.plist")
    spriteController:removeTexture("public/acOpenyearImage.png")
    spriteController:removePlist("public/acDjrecall_images.plist")
    spriteController:removeTexture("public/acDjrecall_images.png")
    spriteController:removePlist("public/acChunjiepansheng.plist")
    spriteController:removeTexture("public/acChunjiepansheng.png")
end