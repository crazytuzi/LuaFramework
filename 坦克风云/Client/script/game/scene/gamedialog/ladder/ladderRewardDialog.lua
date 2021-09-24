--天梯帮助和奖励面板
require "luascript/script/game/scene/gamedialog/ladder/ladderRewardDialogTab1"
require "luascript/script/game/scene/gamedialog/ladder/ladderRewardDialogTab2"
ladderRewardDialog=commonDialog:new()
function ladderRewardDialog:new()
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  self.tab1=nil
  self.tab2=nil
  self.layerTab1=nil
  self.layerTab2=nil
  return nc
end

function ladderRewardDialog:resetTab()
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
    local indexSub=0
    for k,v in pairs(self.allSubTabs) do
        local  tabSubBtnItem=v
        if indexSub==0 then
            tabSubBtnItem:setPosition(100,self.bgSize.height-tabSubBtnItem:getContentSize().height/2-160)
        elseif indexSub==1 then
            tabSubBtnItem:setPosition(248,self.bgSize.height-tabSubBtnItem:getContentSize().height/2-160)
        elseif indexSub==2 then
            tabSubBtnItem:setPosition(394,self.bgSize.height-tabSubBtnItem:getContentSize().height/2-160)
        elseif indexSub==3 then
            tabSubBtnItem:setPosition(540,self.bgSize.height-tabSubBtnItem:getContentSize().height/2-160)
        end
        if indexSub==self.selectedSubTabIndex then
            tabSubBtnItem:setEnabled(false)
        end
        -- print("---dmj-----selectedSubTabIndex:"..self.selectedSubTabIndex.."--indexSub:"..indexSub)
        if self.selectedTabIndex==0 then
            tabSubBtnItem:setVisible(false)
        else

        end
        indexSub=indexSub+1
    end
    self.panelLineBg:setAnchorPoint(ccp(0.5,0))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))

    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
end

function ladderRewardDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)

    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    for k,v in pairs(self.allSubTabs) do
        local  tabSubBtnItem=v
        if self.selectedTabIndex==0 then
            tabSubBtnItem:setVisible(false)
        else
            tabSubBtnItem:setVisible(true)
        end
    end
    self:getDataByType(idx+1)
end

--点击subTab页签 idx:索引
function ladderRewardDialog:tabSubClick(idx)
    if self.selectedSubTabIndex == idx then
        return
    end
    PlayEffect(audioCfg.mouseClick)
    if self.selectedTabIndex ~= 1 then
        return
    end
    self.selectedSubTabIndex=idx
    for k,v in pairs(self.allSubTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
        else
            v:setEnabled(true)
        end
    end
    if(self.tab2)then
        self.tab2:switchSubTab(self.selectedSubTabIndex)
    end
end

function ladderRewardDialog:getDataByType(type)
    if(type==nil)then
        type=1
    end
    local selectedIndex = self.selectedIndex
    if(type==1)then
        if(self.tab1==nil)then
                if self.tab2 then
                  selectedIndex=self.tab2.selectedIndex
                end
                self.tab1=ladderRewardDialogTab1:new()
                self.layerTab1=self.tab1:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab1)

                if(self.selectedTabIndex==0)then
                    self:switchTab(1)
                end
        else
            self:switchTab(1)
        end
    elseif(type==2)then
        if(self.tab2==nil)then
            local function openTab2( ... )
                if self.tab1 then
                  selectedIndex=self.tab1.selectedIndex
                end
                self.tab2=ladderRewardDialogTab2:new()
                self.layerTab2=self.tab2:init(self.layerNum,10)
                self.bgLayer:addChild(self.layerTab2)
                if(self.selectedTabIndex==1)then
                    self:switchTab(2,false)
                end
            end
            local function callbackHandler(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.ladder then
                        ladderVoApi:formatData(sData.data.ladder)
                        ladderVoApi.lastRequestTime1=base.serverTime
                    end
                    openTab2()
                end
            end
            if (ladderVoApi:getPersonLadderList()==nil and ladderVoApi:checkIfNeedRequestByNoData()) or ladderVoApi:checkIfNeedRequestData(1)==true then
                local isCountScore=ladderVoApi:ifCountingScore()
                if isCountScore==false then
                    local expiration_time,isShowRank = ladderVoApi:getLadderEndTime()
                    if isShowRank==true then
                        socketHelper:getLadderRank(1,callbackHandler)
                    else
                        openTab2()        
                    end
                else
                    openTab2()    
                end
            else
                openTab2()
            end
        else
            self:switchTab(2)
        end
    end
end

function ladderRewardDialog:switchTab(type)
    if type==nil then
        type=1
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

function ladderRewardDialog:tick()
    -- for i=1,2 do
    --       if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
    --         self["tab"..i]:tick()
    --     end
    -- end
end

function ladderRewardDialog:dispose()
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