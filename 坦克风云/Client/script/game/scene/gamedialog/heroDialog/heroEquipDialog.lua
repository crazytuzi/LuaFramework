--将领授勋的面板
require "luascript/script/game/scene/gamedialog/heroDialog/heroEquipDialogTab1"
require "luascript/script/game/scene/gamedialog/heroDialog/heroEquipDialogTab2"

heroEquipDialog=commonDialog:new()

function heroEquipDialog:new(selectedIndex,heroVoList,parentDialog)
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  self.tab1=nil
  self.tab2=nil
  self.layerTab1=nil
  self.layerTab2=nil
  self.selectedIndex=selectedIndex        --当前选择的将领索引
  self.heroVoList=heroVoList              --所有的将领vo数组
  self.parentDialog=parentDialog
  CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/hero/heroequip/equipCompress.plist")
  CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  return nc
end

function heroEquipDialog:resetTab()
    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v
        local ifShowTipIcon = false
        self.heroVo=self.heroVoList[self.selectedIndex]
        if index==0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
            if self.heroVo then
                ifShowTipIcon=heroEquipVoApi:checkIfCanUpOrJinjieByHid(self.heroVo.hid,self.heroVo.productOrder)
            end
        elseif index==1 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
            if self.heroVo then
                ifShowTipIcon=heroEquipVoApi:checkIfCanAwakenByHid(self.heroVo.hid,self.heroVo.productOrder)
            end
        end
        -- if ifShowTipIcon==true then
            local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
            tipSp:setAnchorPoint(CCPointMake(1,0.5))
            tipSp:setPosition(ccp(self.dialogLayer:getContentSize().width/2+(self.dialogLayer:getContentSize().width-20)/2*index,self.bgLayer:getContentSize().height-98))
            self.bgLayer:addChild(tipSp,3)
            -- tabBtnItem:addChild(tipSp)
            tipSp:setVisible(ifShowTipIcon)
            tipSp:setTag(60+index)
        -- end
        if index==self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index=index+1
    end
    self.panelLineBg:setAnchorPoint(ccp(0.5,0))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))

    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
end

function heroEquipDialog:refreshTabStage()
    local index=0
    if self == nil then
        return
    end
    for k,v in pairs(self.allTabs) do
        local ifShowTipIcon = false
        local  tabBtnItem=v
        local selectedIndex = self.selectedIndex
        -- print("----dmj----selectedIndex:"..selectedIndex.."----self.tab1.selectedIndex:"..self.tab1.selectedIndex)
        if self.selectedTabIndex==0 and self.tab1 then
          selectedIndex=self.tab1.selectedIndex
        end
        if self.selectedTabIndex==1 and self.tab2 then
          selectedIndex=self.tab2.selectedIndex
        end
        self.heroVo=self.heroVoList[selectedIndex]
        local tipSp=tolua.cast(self.bgLayer:getChildByTag(60+index),"CCSprite")
        if index==0 then
            if self.heroVo then
                ifShowTipIcon=heroEquipVoApi:checkIfCanUpOrJinjieByHid(self.heroVo.hid,self.heroVo.productOrder)
            end
        elseif index==1 then
            if self.heroVo then
                ifShowTipIcon=heroEquipVoApi:checkIfCanAwakenByHid(self.heroVo.hid,self.heroVo.productOrder)
            end
        end
        if self and tipSp then
            tipSp:setVisible(ifShowTipIcon)
        end
        index=index+1
    end
end

function heroEquipDialog:tabClick(idx)
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
end

function heroEquipDialog:getDataByType(type)
    if(type==nil)then
        type=1
    end
    local selectedIndex = self.selectedIndex
    if(type==1)then
        if(self.tab1==nil)then
                if self.tab2 then
                  selectedIndex=self.tab2.selectedIndex
                end
                self.tab1=heroEquipDialogTab1:new(selectedIndex,self.heroVoList,self)
                self.layerTab1=self.tab1:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab1)

                if(self.selectedTabIndex==0)then
                    self:switchTab(1,false)
                end
        else
            self:switchTab(1)
        end
    elseif(type==2)then
        if(self.tab2==nil)then
                if self.tab1 then
                  selectedIndex=self.tab1.selectedIndex
                end
                self.tab2=heroEquipDialogTab2:new(selectedIndex,self.heroVoList,self)
                self.layerTab2=self.tab2:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab2)
                if(self.selectedTabIndex==1)then
                    self:switchTab(2,false)
                end
        else
            self:switchTab(2)
        end
    end
end

function heroEquipDialog:switchTab(type,ifShowHero)
    if type==nil then
        type=1
    end
    if ifShowHero==nil then
        ifShowHero=true
    end
    for i=1,2 do
        if(i==type)then
            if(self["layerTab"..i]~=nil)then
                local selectedIndex = self.selectedIndex
                if type==1 and self.tab2 then
                    selectedIndex=self.tab2.selectedIndex
                elseif type==2 and self.tab1 then
                    selectedIndex=self.tab1.selectedIndex
                end
                if ifShowHero==true then
                  self["tab"..i]:switchHero(selectedIndex)
                end
                self["layerTab"..i]:setPosition(ccp(0,0))
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

function heroEquipDialog:closeParentDialog()
    if self and self.parentDialog then
        self.parentDialog:close()
        self.parentDialog=nil
    end
    if self then
        self:close()
    end
end

function heroEquipDialog:tick()
    for i=1,2 do
          if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
            self["tab"..i]:tick()
        end
    end
end

function heroEquipDialog:dispose()
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
  CCTextureCache:sharedTextureCache():removeTextureForKey("public/expeditionImage.png")
  for i=1,2 do
      if (self["tab"..i]~=nil and self["tab"..i].dispose) then
          self["tab"..i]:dispose()
      end
  end
  if self and self.parentDialog then
      self.parentDialog:refresh()
  end
  self.parentDialog=nil
  self.tab1=nil
  self.tab2=nil
  self.layerTab1=nil
  self.layerTab2=nil
end