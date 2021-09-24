--将领授勋的面板
require "luascript/script/game/scene/gamedialog/heroDialog/heroHonorDialogTabSB"
require "luascript/script/game/scene/gamedialog/heroDialog/heroHonorDialogTabNB"

heroHonorDialog=commonDialog:new()

function heroHonorDialog:new()
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  self.tab1=nil
  self.tab2=nil
  -- self.tab3=nil
  self.layerTab1=nil
  self.layerTab2=nil
  -- self.layerTab3=nil
  return nc
end

function heroHonorDialog:resetTab()
    spriteController:addPlist("public/serverWarLocal/serverWarLocal2.plist")
    spriteController:addTexture("public/serverWarLocal/serverWarLocal2.png")
    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v
        if index==0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
        elseif index==1 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
        -- elseif index==2 then
        --     tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
        end
        if index==self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index=index+1
    end
    self.panelLineBg:setAnchorPoint(ccp(0.5,0))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))

    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
end

function heroHonorDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)

    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    self:getDataByType(idx+1)

    -- if idx==2 then
    --     worldWarVoApi:setShopHasOpen()
    --     self:setIconTipVisibleByIdx(false,3)
    -- end
end

function heroHonorDialog:getDataByType(type)
    if(type==nil)then
        type=1
    end
    if(type==1)then
        if(self.tab1==nil)then
            -- local function getWarInfoHandler()
                self.tab1=heroHonorDialogTabSB:new()
                self.layerTab1=self.tab1:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab1)
                if(self.selectedTabIndex==0)then
                    self:switchTab(1)
                end
            -- end
            -- worldWarVoApi:getWarInfo(getWarInfoHandler)
        else
            self:switchTab(1)
        end
    elseif(type==2)then
        if(self.tab2==nil)then
            -- local function callback2()
                self.tab2=heroHonorDialogTabNB:new()
                self.layerTab2=self.tab2:init(self.layerNum,self)
                self.bgLayer:addChild(self.layerTab2)
                if(self.selectedTabIndex==1)then
                    self:switchTab(2)
                end
            -- end
            -- local bType=worldWarVoApi:getSignStatus()
            -- if bType~=nil then
            --     worldWarVoApi:getScheduleInfo(bType,callback2)
            -- else
            --     callback2()
            -- end
        else
            self:switchTab(2)
        end
    end
end

function heroHonorDialog:switchTab(type)
    if type==nil then
        type=1
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

function heroHonorDialog:tick()
    for i=1,2 do
          if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
            self["tab"..i]:tick()
        end
    end
end

function heroHonorDialog:dispose()
  for i=1,2 do
      if (self["tab"..i]~=nil and self["tab"..i].dispose) then
          self["tab"..i]:dispose()
      end
  end
  self.tab1=nil
  self.tab2=nil
  -- self.tab3=nil
  self.layerTab1=nil
  self.layerTab2=nil
  -- self.layerTab3=nil
  CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblemBlackBg.jpg")
  spriteController:removePlist("public/serverWarLocal/serverWarLocal2.plist")
  spriteController:removeTexture("public/serverWarLocal/serverWarLocal2.png")
end