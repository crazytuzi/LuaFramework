accessoryDialog=commonDialog:new()

function accessoryDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.accessoryTab1=nil
    self.accessoryTab2=nil
    self.accessoryTab3=nil

    self.isToday=true
    self.leftECNum=0
    require "luascript/script/game/scene/gamedialog/accessory/accessoryDialogTab1"
    require "luascript/script/game/scene/gamedialog/accessory/accessoryDialogTab2"
    require "luascript/script/game/scene/gamedialog/accessory/accessoryDialogTab3"
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/tankImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/refiningImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acItemBg.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    -- spriteController:addPlist("public/redAccessory.plist")
    -- spriteController:addTexture("public/redAccessory.png")
    spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
    spriteController:addTexture("public/allianceWar2/allianceWar2.png")

    return nc
end

function accessoryDialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
    else
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    if accessoryVoApi.dataNeedRefresh==true then
    else
        self:tabClick(0,false)
    end
end

--显示面板,加效果
function accessoryDialog:show()
   local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
   local function callBack()
       if self and self.isCloseing==false then
            if portScene.clayer~=nil then
                if sceneController.curIndex==0 then
                    portScene:setHide()
                elseif sceneController.curIndex==1 then
                    mainLandScene:setHide()
                elseif sceneController.curIndex==2 then
                    worldScene:setHide()
                end
                
              
                mainUI:setHide()
                self:getDataByType()
            end
       end
       base:cancleWait()
   end
   base.allShowedCommonDialog=base.allShowedCommonDialog+1
   table.insert(base.commonDialogOpened_WeakTb,self)
   local callFunc=CCCallFunc:create(callBack)
   local seq=CCSequence:createWithTwoActions(moveTo,callFunc)
   self.bgLayer:runAction(seq)
end

function accessoryDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
        if (self.selectedTabIndex==1) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-210))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 210))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 130))
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

function accessoryDialog:initTableView()
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local function callBack(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,165))
    -- self.tv:setPosition(ccp(30,130))
    -- self.bgLayer:addChild(self.tv)

    local leftNum=accessoryVoApi:getLeftECNum()
    -- if self.leftECNum~=leftNum then
    --     if leftNum>0 then
    --         self:setTipsVisibleByIdx(true,2,leftNum)
    --     else
    --         self:setTipsVisibleByIdx(false,2,leftNum)
    --     end
    --     self.leftECNum=leftNum
    -- end
    if(accessoryVoApi.unusedNum~=nil and accessoryVoApi.unusedNum>0)then
        self:setTipsVisibleByIdx(true,1,accessoryVoApi.unusedNum)
    else
        self:setTipsVisibleByIdx(false,1,0)
    end

    G_WeakTb.accessoryDialog=self
end

function accessoryDialog:tabClick(idx,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:getDataByType(idx+1)
        else
            v:setEnabled(true)
        end
    end
    self:resetForbidLayer()
end
function accessoryDialog:hideTabAll()
    for i=1,3 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end
function accessoryDialog:getDataByType(type)
    self:hideTabAll()
    if type==nil then
        type=1
    end 
    if type==2 then
        if accessoryVoApi.dataNeedRefresh==true then
            local function onRequestEnd(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.accessory then
                        if self and self.bgLayer then
                            accessoryVoApi:onRefreshData(sData.data.accessory)
                            self:tabClick(type-1,false)
                        end
                    end
                end
            end
            socketHelper:getAllAccesory(onRequestEnd)
        else
            for k,v in pairs(self.allTabs) do
                if v:getTag()==type-1 then
                    v:setEnabled(false)
                    self.selectedTabIndex=type-1
                else
                    v:setEnabled(true)
                end
            end
            self:switchTab(type)
        end
    else
        if accessoryVoApi.dataNeedRefresh==true then
            local function onRequestEnd(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.accessory then
                        if self and self.bgLayer then
                            accessoryVoApi:onRefreshData(sData.data.accessory)
                            self:tabClick(type-1,false)
                        end
                    end
                end
            end
            socketHelper:getAllAccesory(onRequestEnd)
        else
            for k,v in pairs(self.allTabs) do
                if v:getTag()==type-1 then
                    v:setEnabled(false)
                    self.selectedTabIndex=type-1
                else
                    v:setEnabled(true)
                end
            end
            self:switchTab(type)
        end
    end
end

function accessoryDialog:switchTab(type)
    if type==nil then
        type=1
    end
   	if self["accessoryTab"..type]==nil then
   		local tab
   		if(type==1)then
	   		tab=accessoryDialogTab1:new()
	   	elseif(type==2)then
	   		tab=accessoryDialogTab3:new()
	   	-- else
	   	-- 	tab=accessoryDialogTab3:new()
	   	end
	   	self["accessoryTab"..type]=tab
	   	self["layerTab"..type]=tab:init(self.layerNum,self)
	   	self.bgLayer:addChild(self["layerTab"..type])
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
    if self and self.accessoryTab1 then
        if type==1 then
            self.accessoryTab1:showPageLayer()
        else
            self.accessoryTab1:hidePageLayer()
        end
    end
end


function accessoryDialog:tick()
    if self and self.bgLayer then
        if(accessoryVoApi.unusedNeedRefresh)then
            if(accessoryVoApi.unusedNum~=nil and accessoryVoApi.unusedNum>0)then
                self:setTipsVisibleByIdx(true,1,accessoryVoApi.unusedNum)
            else
                self:setTipsVisibleByIdx(false,1,0)
            end
            accessoryVoApi.unusedNeedRefresh=false
        end
        -- if accessoryVoApi:getFlag()==0 or accessoryVoApi:isToday()~=self.isToday then
        --     if self.accessoryTab2~=nil and self.bgLayer:isVisible()==true then
        --         if accessoryVoApi:isToday()~=self.isToday then
        --             accessoryVoApi:resetECData()
        --             self.isToday=accessoryVoApi:isToday()
        --         end
        --         self.accessoryTab2:refresh()
        --         accessoryVoApi:setFlag(1)
        --     end
        -- end

        -- local leftNum=accessoryVoApi:getLeftECNum()
        -- if self.leftECNum~=leftNum then
        --     if leftNum>0 then
        --         self:setTipsVisibleByIdx(true,2,leftNum)
        --     else
        --         self:setTipsVisibleByIdx(false,2,leftNum)
        --     end
        --     self.leftECNum=leftNum
        -- end
    end
end

function accessoryDialog:dispose()
    if self.accessoryTab1 then
        self.accessoryTab1:dispose()
    end
    if self.accessoryTab2 then
        self.accessoryTab2:dispose()
    end
    if self.accessoryTab3 then
        self.accessoryTab3:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.accessoryTab1=nil
    self.accessoryTab2=nil
    self.accessoryTab3=nil

    self.isToday=nil
    self.leftECNum=nil
    if G_WeakTb and G_WeakTb.accessoryDialog then
        G_WeakTb.accessoryDialog=nil
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/tankImage.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/tankImage.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acItemBg.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/acItemBg.png")
    -- CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.pvr.ccz")
    -- CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage2.pvr.ccz")
    -- spriteController:removePlist("public/redAccessory.plist")
    -- spriteController:removeTexture("public/redAccessory.png")
    spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
    spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
end
