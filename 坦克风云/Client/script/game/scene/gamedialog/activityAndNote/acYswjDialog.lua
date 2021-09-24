acYswjDialog=commonDialog:new()

function acYswjDialog:new()
    local nc={
        layerTab1=nil,
        layerTab2=nil,
        layerTab3=nil,

        yswjTab1=nil,
        yswjTab2=nil,
        yswjTab3=nil,

        requestFlag=false,
        isEnd=false,
    }
    setmetatable(nc,self)
    self.__index=self
   
    return nc
end

function acYswjDialog:resetTab()
    spriteController:addPlist("public/acBlessWords.plist")
    spriteController:addTexture("public/acBlessWords.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acyswj_images1.plist")
    spriteController:addTexture("public/acyswj_images1.png")
    spriteController:addPlist("public/acyswj_images2.plist")
    spriteController:addTexture("public/acyswj_images2.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

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
         if G_getCurChoseLanguage() =="ru" and index ==1 then
            local lb = tabBtnItem:getChildByTag(31)
            lb:setFontSize(25)
         end
         index=index+1
         
    end
    self.isEnd=acYswjVoApi:isEnd()
    self:refreshIconTipVisible()
    local function callback()
        self:tabClick(0,false)
    end
    acYswjVoApi:checkInit(callback)
end

function acYswjDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
        if (self.selectedTabIndex==1) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-175+70))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 175+70))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 165))
        elseif (self.selectedTabIndex==0) then
            self.topforbidSp:setContentSize(CCSizeMake(0,0))
            self.bottomforbidSp:setContentSize(CCSizeMake(0,0))
        elseif (self.selectedTabIndex==2) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-210))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 210))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 130))
        end
    end
end

function acYswjDialog:initTableView()
    local function refreshTip(event,data)
        self:refreshIconTipVisible()
    end
    self.tipListener=refreshTip
    eventDispatcher:addEventListener("yswj.refreshTip",self.tipListener)
end

function acYswjDialog:tabClick(idx,isEffect)
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

function acYswjDialog:hideTabAll()
    for i=1,3 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end
function acYswjDialog:getDataByIdx(tabType)
    self:hideTabAll()
    if tabType==nil then
        tabType=1
    end
    if tabType==2 and self.requestFlag==false then
        local function callback()
            self:switchTab(tabType)
            self.requestFlag=true
        end
        alienTechVoApi:getTechData(callback)
    else
        self:switchTab(tabType)
    end
end

function acYswjDialog:switchTab(tabType)
    if tabType==nil then
        tabType=1
    end
   	if self["yswjTab"..tabType]==nil then
   		local tab
   		if(tabType==1)then
	   		tab=acYswjLottery:new()
	   	elseif(tabType==2)then
	   		tab=acYswjRefinery:new()
	   	else
	   		tab=acYswjTask:new()
	   	end
	   	self["yswjTab"..tabType]=tab
	   	self["layerTab"..tabType]=tab:init(self.layerNum,self)
	   	self.bgLayer:addChild(self["layerTab"..tabType],10)
   	end
    for i=1,3 do
    	if(i==tabType)then
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(0,0))
    			self["layerTab"..i]:setVisible(true)
                if self["yswjTab"..tabType].updateUI then
                    self["yswjTab"..tabType]:updateUI()
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


function acYswjDialog:tick()
    if acYswjVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if self and self.bgLayer then
        for i=1,3 do
            if self["yswjTab"..i]~=nil and self["yswjTab"..i].tick then
                self["yswjTab"..i]:tick()
            end
        end
    end

    if self.isEnd~=acYswjVoApi:isEnd() then
        self.isEnd=acYswjVoApi:isEnd()
    end
end

function acYswjDialog:fastTick()
    if acYswjVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if self and self.bgLayer then
        for i=1,3 do
            if self["yswjTab"..i]~=nil and self["yswjTab"..i].fastTick then
                self["yswjTab"..i]:fastTick()
            end
        end
    end
end

function acYswjDialog:refreshIconTipVisible()
    if acYswjVoApi:isEnd()==false then
        local flag=acYswjVoApi:canTaskReward()
        if flag==false then
            if self.setIconTipVisibleByIdx then
                self:setIconTipVisibleByIdx(false,3)
            end
        else
            if self.setIconTipVisibleByIdx then
                self:setIconTipVisibleByIdx(true,3)
            end
        end
    end
end

function acYswjDialog:dispose()
    if self.yswjTab1 then
        self.yswjTab1:dispose()
    end
    if self.yswjTab2 then
        self.yswjTab2:dispose()
    end
    if self.yswjTab3 then
        self.yswjTab3:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.yswjTab1=nil
    self.yswjTab2=nil
    self.yswjTab3=nil

    self.isEnd=false
    spriteController:removePlist("public/acBlessWords.plist")
    spriteController:removeTexture("public/acBlessWords.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/acyswj_images1.plist")
    spriteController:removeTexture("public/acyswj_images1.png")
    spriteController:removePlist("public/acyswj_images2.plist")
    spriteController:removeTexture("public/acyswj_images2.png")

    eventDispatcher:removeEventListener("yswj.refreshTip",self.tipListener)
    self.tipListener=nil
end
