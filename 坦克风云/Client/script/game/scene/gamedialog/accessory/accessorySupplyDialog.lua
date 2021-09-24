accessorySupplyDialog=commonDialog:new()

function accessorySupplyDialog:new(defaultTab)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerTab2=nil
    
    self.accessoryTab2=nil

    self.isToday=true
    self.leftECNum=0
    self.defaultTab=defaultTab
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/tankImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    
    return nc
end

function accessorySupplyDialog:resetTab()

end

--显示面板,加效果
function accessorySupplyDialog:show()
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
                self:getDataByType(1)
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

function accessorySupplyDialog:resetForbidLayer()
    if self and self.topforbidSp and self.bottomforbidSp then
        self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-175+70))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 175+70))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 165))
    end
end

function accessorySupplyDialog:initTableView()
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local function callBack(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,165))


    G_WeakTb.accessorySupplyDialog=self
end

function accessorySupplyDialog:tabClick(idx,isEffect)
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


function accessorySupplyDialog:getDataByType(type)
    --self:hideTabAll()
    if accessoryVoApi:getFlag()==-1 then
        local function echallengeListCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.echallenge then
                    if self and self.bgLayer then
                        accessoryVoApi:formatECData(sData.data)
                        accessoryVoApi:setFlag(1)
                        self:switchTab()
                    end
                end
            end
        end
        socketHelper:echallengeList(echallengeListCallback)
    else
        self:switchTab()
    end

end

function accessorySupplyDialog:switchTab()
    local function onDelay()
        if self and self.bgLayer and self.isCloseing==false then
            require "luascript/script/game/scene/gamedialog/accessory/accessoryDialogTab2"
            self.accessoryTab2=accessoryDialogTab2:new()
            self.layerTab2=self.accessoryTab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab2)
            if(accessoryVoApi:getGuideStep()>0)then
                accessoryGuideMgr:setCurStep(2)
                accessoryVoApi:setGuideStep(2)
            end
        end
    end
    local callFunc=CCCallFunc:create(onDelay)
    local delay=CCDelayTime:create(0.1)
    local acArr=CCArray:create()
    acArr:addObject(delay)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.bgLayer:runAction(seq)
end


function accessorySupplyDialog:tick()
    if self and self.bgLayer then



        if accessoryVoApi:getFlag()==0 or accessoryVoApi:isToday()~=self.isToday then
            if self.accessoryTab2~=nil and self.bgLayer:isVisible()==true then
                if accessoryVoApi:isToday()~=self.isToday then
                    accessoryVoApi:resetECData()
                    self.isToday=accessoryVoApi:isToday()
                end
                self.accessoryTab2:refresh()
                accessoryVoApi:setFlag(1)
            end
        end

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

function accessorySupplyDialog:dispose()

    if self.accessoryTab2 then
        self.accessoryTab2:dispose()
    end
    self.bgLayer:stopAllActions()

    self.layerTab2=nil
    self.accessoryTab2=nil

    self.isToday=nil
    self.leftECNum=nil
    if G_WeakTb and G_WeakTb.accessorySupplyDialog then
        G_WeakTb.accessorySupplyDialog=nil
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/tankImage.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/tankImage.png")
    -- CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.pvr.ccz")
    -- CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage2.pvr.ccz")
end
