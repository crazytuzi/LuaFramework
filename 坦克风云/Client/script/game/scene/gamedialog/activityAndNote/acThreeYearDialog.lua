require "luascript/script/game/scene/gamedialog/activityAndNote/acThreeYearFirst"
require "luascript/script/game/scene/gamedialog/activityAndNote/acThreeYearSecond"
require "luascript/script/game/scene/gamedialog/activityAndNote/acThreeYearThird"
acThreeYearDialog=commonDialog:new()

function acThreeYearDialog:new()
    local nc={
        layerTab1=nil,
        layerTab2=nil,
        layerTab3=nil,

        yearTab1=nil,
        yearTab2=nil,
        yearTab3=nil,

        isEnd=false,
    }
    setmetatable(nc,self)
    self.__index=self
   
    return nc
end

function acThreeYearDialog:resetTab()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")
    spriteController:addPlist("public/acRechargeBag_images.plist")
    spriteController:addTexture("public/acRechargeBag_images.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    spriteController:addPlist("public/acmidautumn_images.plist")
    spriteController:addTexture("public/acmidautumn_images.png")
    spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
    spriteController:addTexture("public/allianceWar2/allianceWar2.png")
    spriteController:addPlist("public/newDisplayImage.plist")
    spriteController:addTexture("public/newDisplayImage.png")
    spriteController:addPlist("public/acDouble11_NewImage.plist")
    spriteController:addTexture("public/acDouble11_NewImage.png")
    spriteController:addPlist("public/acChunjiepansheng3.plist")
    spriteController:addTexture("public/acChunjiepansheng3.png")
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

    self:tabClick(0,false) 
end

function acThreeYearDialog:resetForbidLayer()
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

function acThreeYearDialog:initTableView()
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local function callBack(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.tv:setPosition(ccp(30,165))
end

function acThreeYearDialog:tabClick(idx,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    local function realSwitchSubTab()
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
    realSwitchSubTab()
end

function acThreeYearDialog:hideTabAll()
    for i=1,3 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end
function acThreeYearDialog:getDataByIdx(tabType)
    self:hideTabAll()
    if tabType==nil then
        tabType=1
    end
    if tabType==2 then
        local shoplist=acThreeYearVoApi:getShopList()
        if shoplist==nil then
            local function getShopCallBack()
                self:switchTab(tabType)
            end
            acThreeYearVoApi:threeYearRequest("getshop",nil,nil,getShopCallBack)
        else
            self:switchTab(tabType)
        end
    elseif tabType==1 then
        local isOpen=acThreeYearVoApi:isOpenHistory()
        if isOpen==nil then
            local function callBack()
                self:switchTab(tabType)
            end
            acThreeYearVoApi:threeYearRequest("login",nil,nil,callBack)
        else
            self:switchTab(tabType)
        end
    else
        self:switchTab(tabType)
    end
end

function acThreeYearDialog:switchTab(tabType)
    if tabType==nil then
        tabType=1
    end
    if self["yearTab"..tabType]==nil then
        local tab
        if(tabType==1)then
            tab=acThreeYearFirst:new()
        elseif(tabType==2)then
            tab=acThreeYearSecond:new()
        else
            tab=acThreeYearThird:new()
        end
        self["yearTab"..tabType]=tab
        self["layerTab"..tabType]=tab:init(self.layerNum,self)
        self.bgLayer:addChild(self["layerTab"..tabType],10)
    end
    for i=1,3 do
        if(i==tabType)then
            if(self["layerTab"..i]~=nil)then
                self["layerTab"..i]:setPosition(ccp(0,0))
                self["layerTab"..i]:setVisible(true)
                if self["yearTab"..tabType].updateUI then
                    self["yearTab"..tabType]:updateUI()
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

function acThreeYearDialog:tick()
    if acThreeYearVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if self and self.bgLayer then
        for i=1,3 do
            if self["yearTab"..i]~=nil and self["yearTab"..i].tick then
                self["yearTab"..i]:tick()
            end
        end
    end
end

function acThreeYearDialog:dispose()
    if self.yearTab1 then
        self.yearTab1:dispose()
    end
    if self.yearTab2 then
        self.yearTab2:dispose()
    end
    if self.yearTab3 then
        self.yearTab3:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.yearTab1=nil
    self.yearTab2=nil
    self.yearTab3=nil

    self.isEnd=false
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    spriteController:removePlist("public/acAnniversary.plist")
    spriteController:removeTexture("public/acAnniversary.png")
    spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
    spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
    spriteController:removePlist("public/acRechargeBag_images.plist")
    spriteController:removeTexture("public/acRechargeBag_images.png")
    spriteController:removePlist("public/acChunjiepansheng3.plist")
    spriteController:removeTexture("public/acChunjiepansheng3.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/acmidautumn_images.plist")
    spriteController:removeTexture("public/acmidautumn_images.png")
    spriteController:removePlist("public/acDouble11_NewImage.plist")
    spriteController:removeTexture("public/acDouble11_NewImage.png")
    spriteController:removePlist("public/newDisplayImage.plist")
    spriteController:removeTexture("public/newDisplayImage.png")
end
