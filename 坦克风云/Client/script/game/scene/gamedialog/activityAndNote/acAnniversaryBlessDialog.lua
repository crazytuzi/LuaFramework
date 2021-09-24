require "luascript/script/game/scene/gamedialog/activityAndNote/acAnniversaryBlessTab1"
require "luascript/script/game/scene/gamedialog/activityAndNote/acAnniversaryBlessTab2"

acAnniversaryBlessDialog=commonDialog:new()

function acAnniversaryBlessDialog:new()
    local nc={
        layerTab1=nil,
        layerTab2=nil,

        anniversaryTab1=nil,
        anniversaryTab2=nil,

        hasRefreshed=false,
        isEnd=false,
        isToday=true,

    }
    setmetatable(nc,self)
    self.__index=self
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acNewYearsEva.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    acAnniversaryBlessVoApi:initWords()

    return nc
end

function acAnniversaryBlessDialog:resetTab()
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

    self:refreshIconTipVisible()
    self:tabClick(0,false)
end

-- function acAnniversaryBlessDialog:resetForbidLayer()
--     if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
--         if (self.selectedTabIndex==1) then
--             self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-175+70))
--             self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 175+70))
--             self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 165))
--         elseif (self.selectedTabIndex==0) then
--             self.topforbidSp:setContentSize(CCSizeMake(0, 0))
--             self.bottomforbidSp:setContentSize(CCSizeMake(0, 0))
--         elseif (self.selectedTabIndex==2) then
--             self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-210))
--             self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 210))
--             self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 130))
--         end
--     end
-- end

function acAnniversaryBlessDialog:initTableView()
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

function acAnniversaryBlessDialog:tabClick(idx,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self:getDataByType(idx+1)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    --self:switchTab()
end
function acAnniversaryBlessDialog:hideTabAll()
    for i=1,2 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end
function acAnniversaryBlessDialog:getDataByType(tabType)
    self:hideTabAll()
    if tabType == nil then
        tabType = 1
    end
    if tabType==1 then
        local function infoCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data then
                    acAnniversaryBlessVoApi:updateData(sData.data.anniversaryBless)
                    self:switchTab(tabType)
                    self.hasRefreshed=true
                end
            end
        end
        
        if self.hasRefreshed==false then
            socketHelper:syncFinishNum(infoCallback)
        else
            self:switchTab(tabType)
        end
    else
        self:switchTab(tabType)
    end
end

function acAnniversaryBlessDialog:switchTab(tabType)
    if tabType==nil then
        tabType=1
    end
    if self["anniversaryTab"..tabType]==nil then
        local tab
        if(tabType==1) then
            tab=acAnniversaryBlessTab1:new()
        elseif(tabType==2) then
            tab=acAnniversaryBlessTab2:new()
        end
        self["anniversaryTab"..tabType]=tab
        self["layerTab"..tabType]=tab:init(self.layerNum,self)
        self.bgLayer:addChild(self["layerTab"..tabType])
    end
    for i=1,2 do
        if(i==tabType)then
            if(self["layerTab"..i]~=nil)then
                self["layerTab"..i]:setPosition(ccp(0,0))
                self["layerTab"..i]:setVisible(true)
                -- if i==self.tabName.DAMAGE_RANK then
                --     if self["anniversaryTab"..tabType].refresh then
                --         self["anniversaryTab"..tabType]:refresh()
                --     end
                -- end
                -- if i==self.tabName.TEAM_SET then
                --     -- if self["yearEveTab"..tabType].clearTouchSp then
                --     --     self["yearEveTab"..tabType]:clearTouchSp()
                --     -- end
                -- end
            end
        else
            if(self["layerTab"..i]~=nil)then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end


function acAnniversaryBlessDialog:tick()
    if acAnniversaryBlessVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if acAnniversaryBlessVoApi:isToday()==false and self.isToday==true then
        acAnniversaryBlessVoApi:resetAc()
        self.isToday=false
    end
    if self and self.bgLayer then
        for i=1,2 do
            if self["anniversaryTab"..i]~=nil and self["anniversaryTab"..i].tick then
                self["anniversaryTab"..i]:tick()
            end
        end
    end
end

function acAnniversaryBlessDialog:refreshIconTipVisible()
    if acAnniversaryBlessVoApi:canReward()==true then
        if self.setIconTipVisibleByIdx then
            self:setIconTipVisibleByIdx(true,2)
        end
    else
        if self.setIconTipVisibleByIdx then
            self:setIconTipVisibleByIdx(false,2)
        end
    end
end

function acAnniversaryBlessDialog:dispose()
    if self.anniversaryTab1 then
        self.anniversaryTab1:dispose()
    end
    if self.anniversaryTab2 then
        self.anniversaryTab2:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    
    self.anniversaryTab1=nil
    self.anniversaryTab2=nil

    self.hasRefreshed=false
    self.isEnd=false

    spriteController:removePlist("public/acNewYearsEva.plist")
end
