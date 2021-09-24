require "luascript/script/game/scene/gamedialog/Boss/BossBattleScene"
require "luascript/script/game/scene/gamedialog/activityAndNote/acNewYearsEveDialogTab1"
require "luascript/script/game/scene/gamedialog/activityAndNote/acNewYearsEveDialogTab2"
require "luascript/script/game/scene/gamedialog/activityAndNote/acNewYearsEveDialogTab3"
acNewYearsEveDialog=commonDialog:new()

function acNewYearsEveDialog:new()
    local nc={
        tabName={DETAIL=1,DAMAGE_RANK=2,TEAM_SET=3},
        layerTab1=nil,
        layerTab2=nil,
        layerTab3=nil,

        yearEveTab1=nil,
        yearEveTab2=nil,
        yearEveTab3=nil,

        dataNeedRefresh=nil,
        hasRefreshInfo = false,
        isEnd=false,

    }
    setmetatable(nc,self)
    self.__index=self


    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
   
    return nc
end

function acNewYearsEveDialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)

         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    self.isEnd=acNewYearsEveVoApi:acIsStop()

    if self.isEnd == true then
        local function listCallback1()
            local function listCallback2()
                self:refreshIconTipVisible()
                self:tabClick(0,false)
            end
            acNewYearsEveVoApi:activeNewyeareva("ranklist",2,listCallback2)
        end
        acNewYearsEveVoApi:activeNewyeareva("ranklist",1,listCallback1)
    else
        self:tabClick(0,false)
    end
end

function acNewYearsEveDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
        if (self.selectedTabIndex==1) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-175+70))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 175+70))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 165))
        elseif (self.selectedTabIndex==0) then
            self.topforbidSp:setContentSize(CCSizeMake(0, 0))
            self.bottomforbidSp:setContentSize(CCSizeMake(0, 0))
        elseif (self.selectedTabIndex==2) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-210))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 210))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 130))
        end
    end
end

function acNewYearsEveDialog:initTableView()
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local function callBack(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,165))
    -- self.tv:setPosition(ccp(30,130))
    -- self.bgLayer:addChild(self.tv)

end

function acNewYearsEveDialog:tabClick(idx,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    local function realSwitchSubTab()
        for k,v in pairs(self.allTabs) do
            if v:getTag()==idx then
                v:setEnabled(false)
                self:getDataByType(idx+1)
                self.selectedTabIndex=idx
            else
                v:setEnabled(true)
            end
        end
    end

    local curTab=self["yearEveTab"..3]
    if (idx==0 or idx==1) and curTab and curTab.isChangeFleet then
        local isChangeFleet,costTanks=curTab:isChangeFleet()
        if isChangeFleet==true then
            local function onConfirm()
                local function saveBack()
                    realSwitchSubTab()
                end
                curTab:saveHandler(saveBack)
            end
            local function onCancle()
                if curTab.refreshTroops then
                    curTab:refreshTroops()
                end
                realSwitchSubTab()
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("world_war_set_changed_fleet"),nil,self.layerNum+1,nil,nil,onCancle)
        else
            realSwitchSubTab()
        end
    else
        realSwitchSubTab()
    end

    --self:switchTab()
end
function acNewYearsEveDialog:hideTabAll()
    for i=1,3 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end
function acNewYearsEveDialog:getDataByType(tabType)
    self:hideTabAll()
    if tabType == nil then
        tabType = self.tabName.DETAIL
    end
    if tabType == self.tabName.DETAIL then
        local function infoCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data then
                    acNewYearsEveVoApi:updateData(sData.data)
                    self:switchTab(tabType)
                    self.hasRefreshInfo = true
                end
            end
        end
        if self.hasRefreshInfo == true then
            self:switchTab(tabType)
        else
            socketHelper:getNewYearEvaInfo(infoCallback)
        end        
    elseif tabType == self.tabName.DAMAGE_RANK then
        self:switchTab(tabType)
    else
        self:switchTab(tabType)
    end
end

function acNewYearsEveDialog:switchTab(tabType)
    if tabType==nil then
        tabType=self.tabName.DETAIL
    end
   	if self["yearEveTab"..tabType]==nil then
   		local tab
   		if(tabType==self.tabName.DETAIL)then
	   		tab=acNewYearsEveDialogTab1:new()
	   	elseif(tabType==self.tabName.DAMAGE_RANK)then
	   		tab=acNewYearsEveDialogTab2:new()
	   	else
	   		tab=acNewYearsEveDialogTab3:new()
	   	end
	   	self["yearEveTab"..tabType]=tab
	   	self["layerTab"..tabType]=tab:init(self.layerNum,self)
	   	self.bgLayer:addChild(self["layerTab"..tabType])
   	end
    self.panelLineBg:setVisible(true)
    for i=1,3 do
    	if(i==tabType)then
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(0,0))
    			self["layerTab"..i]:setVisible(true)
                if i==self.tabName.DETAIL then
                    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
                        self.panelLineBg:setVisible(false)
                    end
                end
                if i==self.tabName.DAMAGE_RANK then
                    if self["yearEveTab"..tabType].refresh then
                        self["yearEveTab"..tabType]:refresh()
                    end
                end
                if i==self.tabName.TEAM_SET then
                    -- if self["yearEveTab"..tabType].clearTouchSp then
                    --     self["yearEveTab"..tabType]:clearTouchSp()
                    -- end
                end
    		end
    	else
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(999333,0))
    			self["layerTab"..i]:setVisible(false)
    		end
    	end
    end
end


function acNewYearsEveDialog:tick()
    if acNewYearsEveVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if self and self.bgLayer then
        -- if self.layerTab1 then
        --     self["yearEveTab1"]:tick()
        -- end
        for i=1,2 do
            if self["yearEveTab"..i]~=nil and self["yearEveTab"..i].tick then
                self["yearEveTab"..i]:tick()
            end
        end
    end

    if self.isEnd~=acNewYearsEveVoApi:acIsStop() then
        self.isEnd=acNewYearsEveVoApi:acIsStop()
        local function listCallback1()
            local function listCallback2()
                if self.refreshIconTipVisible then
                    self:refreshIconTipVisible()
                end
            end
            acNewYearsEveVoApi:activeNewyeareva("ranklist",2,listCallback2)
        end
        acNewYearsEveVoApi:activeNewyeareva("ranklist",1,listCallback1)
    end
end

function acNewYearsEveDialog:refreshIconTipVisible()
    if acNewYearsEveVoApi:acIsStop() == true then
        local canReward1 = acNewYearsEveVoApi:canRankReward(1)
        local canReward2 = acNewYearsEveVoApi:canRankReward(2)
        if canReward1 == false and canReward2 == false then
            if self.setIconTipVisibleByIdx then
                self:setIconTipVisibleByIdx(false,2)
            end
        else
            if self.setIconTipVisibleByIdx then
                self:setIconTipVisibleByIdx(true,2)
            end
        end
    end
end

function acNewYearsEveDialog:dispose()
    --CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("allianceWar/warMap.plist")
    --CCTextureCache:sharedTextureCache():removeTextureForKey("allianceWar/warMap.pvr.ccz")
    self.tabName = nil

    if self.yearEveTab1 then
        self.yearEveTab1:dispose()
    end
    if self.yearEveTab2 then
        self.yearEveTab2:dispose()
    end
    if self.yearEveTab3 then
        self.yearEveTab3:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.yearEveTab1=nil
    self.yearEveTab2=nil
    self.yearEveTab3=nil

    self.dataNeedRefresh=nil
    self.hasRefreshInfo = false
    self.isEnd=false
end
