--天梯名人堂面板
require "luascript/script/game/scene/gamedialog/ladder/ladderHOFDialogTab1"

ladderHOFDialog=commonDialog:new()
function ladderHOFDialog:new()
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  self.tab1=nil
  self.tab2=nil
  self.layerTab1=nil
  self.layerTab2=nil
  return nc
end

function ladderHOFDialog:resetTab()
    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v
        local ifShowTipIcon = false
        if index==0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
        elseif index==1 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
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

function ladderHOFDialog:tabClick(idx)
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

function ladderHOFDialog:getDataByType(type)
    if(type==nil)then
        type=1
    end
    local selectedIndex = self.selectedIndex
    if(type==1)then
        if(self.tab1==nil)then
                -- if self.tab2 then
                --   selectedIndex=self.tab2.selectedIndex
                -- end
                self.tab1=ladderHOFDialogTab1:new(1)
                self.layerTab1=self.tab1:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab1)

                -- if(self.selectedTabIndex==0)then
                --     self:switchTab(1)
                -- end
        else
            self:switchTab(1)
        end
    elseif(type==2)then
        if(self.tab2==nil)then
                -- if self.tab1 then
                --   selectedIndex=self.tab1.selectedIndex
                -- end
                self.tab2=ladderHOFDialogTab1:new(2)
                self.layerTab2=self.tab2:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab2)
                if(self.selectedTabIndex==1)then
                    -- print("----dmj-----self.selectedTabIndex:"..self.selectedTabIndex)
                    self:switchTab(2)
                end
        else
            self:switchTab(2)
        end
    end
end

function ladderHOFDialog:switchTab(type)
    if type==nil then
        type=1
    end
    print("----dmj-----type:"..type)
    for i=1,2 do
        if(i==type)then
            if(self["layerTab"..i]~=nil)then
                -- local selectedIndex = self.selectedIndex
                -- if type==1 and self.tab2 then
                --     selectedIndex=self.tab2.selectedIndex
                -- elseif type==2 and self.tab1 then
                --     selectedIndex=self.tab1.selectedIndex
                -- end
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

function ladderHOFDialog:tick()
    -- for i=1,2 do
    --       if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
    --         self["tab"..i]:tick()
    --     end
    -- end
end

function ladderHOFDialog:dispose()
  for i=1,2 do
      if (self["tab"..i]~=nil and self["tab"..i].dispose) then
          self["tab"..i]:dispose()
      end
  end
  self.tab1=nil
  self.tab2=nil
  self.layerTab1=nil
  self.layerTab2=nil
end