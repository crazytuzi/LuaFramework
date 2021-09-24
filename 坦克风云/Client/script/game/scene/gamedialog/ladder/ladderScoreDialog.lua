--天梯积分明细面板
require "luascript/script/game/scene/gamedialog/ladder/ladderScoreDialogTab1"
ladderScoreDialog=commonDialog:new()
function ladderScoreDialog:new(tabType)
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  self.tab1=nil
  self.tab2=nil
  self.layerTab1=nil
  self.layerTab2=nil
  self.selectedTabIndex=tabType-1
  return nc
end

function ladderScoreDialog:resetTab()
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
            self:tabClick(index)
            self:tabClickColor(index)
        end
        index=index+1
    end
    self.panelLineBg:setAnchorPoint(ccp(0.5,0))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))

    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
end

function ladderScoreDialog:tabClick(idx)
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

function ladderScoreDialog:getDataByType(type)
    
    if(type==nil)then
        -- type=1
        return
    end
    local selectedIndex = self.selectedIndex
    if(type==1)then
        if(self.tab1==nil)then
            local function openTab1( ... )
                if self.tab2 then
                  selectedIndex=self.tab2.selectedIndex
                end
                self.tab1=ladderScoreDialogTab1:new()
                self.layerTab1=self.tab1:init(self.layerNum,1)
                self.bgLayer:addChild(self.layerTab1)

                if(self.selectedTabIndex==0)then
                    self:switchTab(1)
                end
            end
            local function callbackHandler(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.ladder then
                        ladderVoApi:formatData(sData.data.ladder)
                        ladderVoApi.lastRequestTime3=base.serverTime
                    end
                    openTab1()
                end
            end
            local totalScore = ladderVoApi:getMyselfTotalScore()
            if (ladderVoApi:getPersonScoreDetailList()==nil and (ladderVoApi:checkIfNeedRequestByNoData() or totalScore>=0 )) or ladderVoApi:checkIfNeedRequestData(3)==true then
                local isCountScore=ladderVoApi:ifCountingScore()
                if isCountScore==false then
                    socketHelper:getLadderLog(1,callbackHandler)
                else
                    openTab1()
                end
            else
                openTab1()
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
                self.tab2=ladderScoreDialogTab1:new()
                self.layerTab2=self.tab2:init(self.layerNum,2)
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
                        ladderVoApi.lastRequestTime4=base.serverTime
                    end
                    openTab2()
                end
            end
            local totalScore = ladderVoApi:getMyAllianceTotalScore()
            if (ladderVoApi:getAllianceScoreDetailList()==nil and (ladderVoApi:checkIfNeedRequestByNoData()or totalScore>=0)) or ladderVoApi:checkIfNeedRequestData(4)==true then
                local isCountScore=ladderVoApi:ifCountingScore()
                if isCountScore==false then
                    socketHelper:getLadderLog(2,callbackHandler)
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

function ladderScoreDialog:switchTab(type)
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

function ladderScoreDialog:tick()
    for i=1,2 do
          if self["tab"..i]~=nil and self["tab"..i].tick and self.selectedTabIndex+1==i then
            self["tab"..i]:tick()
        end
    end
end

function ladderScoreDialog:dispose()
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