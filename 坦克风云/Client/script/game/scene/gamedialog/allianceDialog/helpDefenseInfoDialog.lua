helpDefenseInfoDialog={

}

function helpDefenseInfoDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bgLayer=nil
    self.closeBtn=nil

    self.confirmBtn=nil
    
    return nc;

end

function helpDefenseInfoDialog:init(helpDefendVo,layerNum)
    --self.bgLayer=CCLayer:create();
    self.layerNum=layerNum;
    
    local function tmpFunc()
    
    end
    
    self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",CCRect(168, 86, 10, 10),tmpFunc)
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSize.height)
    self.bgLayer:setContentSize(rect)
    self.bgLayer:ignoreAnchorPointForPosition(false)
    self.bgLayer:setAnchorPoint(CCPointMake(0.5,0.5))
    self.bgLayer:setPosition(CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
    
    local function close()
        PlayEffect(audioCfg.mouseClick)    
        return self:close()
     end
   local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
        closeBtnItem:setPosition(0, 0)
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(rect.width-closeBtnItem:getContentSize().width,rect.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn)

    self:initInfoLayer(helpDefendVo)
    sceneGame:addChild(self.bgLayer,layerNum)
    table.insert(base.commonDialogOpened_WeakTb,self)
    --return self.bgLayer
end

function helpDefenseInfoDialog:initInfoLayer(helpDefendVo)
    local titleLable1 = GetTTFLabel(getlocal("fleetInfoTitle1"),40)
    titleLable1:setAnchorPoint(ccp(0.5,1))
    titleLable1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-20));
    self.bgLayer:addChild(titleLable1,1)
    
    local rect = CCRect(0, 0, 50, 50);
   local capInSet = CCRect(20, 20, 10, 10);
   local function cellClick(hd,fn,idx)
   end
   local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,cellClick)
   backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 40))
   backSprie:ignoreAnchorPointForPosition(false);
   backSprie:setAnchorPoint(ccp(0.5,0.5));
   backSprie:setIsSallow(false)
   backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
   backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-300));
   self.bgLayer:addChild(backSprie,1)

    local titleLable2 = GetTTFLabel(getlocal("fleetInfoTitle2"),35)
    titleLable2:setAnchorPoint(ccp(0.5,0.5))
    titleLable2:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2));
    backSprie:addChild(titleLable2,2)
    
    local strState=getlocal("state4")
    local addX=40;
    local stateLable = GetTTFLabel(strState,30)
    stateLable:setAnchorPoint(ccp(0,0.5))
    stateLable:setPosition(ccp(90-addX,self.bgLayer:getContentSize().height-100));
    self.bgLayer:addChild(stateLable,1)
    
    local lefttime=0
    if helpDefendVo.status==0 then
        lefttime=helpDefendVo.time-base.serverTime
    end
    if lefttime<0 then
        lefttime=0
    end
    local time= GetTimeStr(lefttime)
    
    local timeLable = GetTTFLabel(getlocal("costTime1",{time}),30)
    timeLable:setAnchorPoint(ccp(0,0.5))
    timeLable:setPosition(ccp(90-addX,self.bgLayer:getContentSize().height-150));
    self.bgLayer:addChild(timeLable,1)
    
    
    
    local temTb={};
    for k,v in pairs(helpDefendVo.tankInfoTab) do
        if v[1]~=nil then
            local slotId=tonumber(RemoveFirstChar(v[1]))
            temTb[k]={slotId,v[2]}
        end
    end
        
    local fleetload=FormatNumber(tankVoApi:getAttackTanksCarryResource(temTb))
    local fleetLb=GetTTFLabel(getlocal("limitLoad",{fleetload}),30);
    fleetLb:setAnchorPoint(ccp(0,0.5));
    fleetLb:setPosition(ccp(90-addX,self.bgLayer:getContentSize().height-200));
    self.bgLayer:addChild(fleetLb,2);

    -- local status=helpDefendVo.status
    local function confirmCallback()
        PlayEffect(audioCfg.mouseClick)
        local function confirmHandler(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                local helpDefend=helpDefendVoApi:getHelpDefend(helpDefendVo.id)
                if helpDefend.status==1 then
                    helpDefendVoApi:updateStatus(helpDefendVo.id,2)
                    if self.confirmBtn then
                        tolua.cast(self.confirmBtn:getChildByTag(101),"CCLabelTTF"):setString(getlocal("cancel"))
                    end
                elseif helpDefend.status==2 then
                    helpDefendVoApi:updateStatus(helpDefendVo.id,1)
                    if self.confirmBtn then
                        tolua.cast(self.confirmBtn:getChildByTag(101),"CCLabelTTF"):setString(getlocal("accpet"))
                    end
                end
            end
        end
        socketHelper:troopSethelpdefense(helpDefendVo.id,helpDefendVo.uid,confirmHandler)
    end
    if helpDefendVo.status==2 then
        self.confirmBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",confirmCallback,10,getlocal("cancel"),25,101)
    else
        self.confirmBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",confirmCallback,10,getlocal("accpet"),25,101)
    end
    local scale=0.8
    self.confirmBtn:setScale(scale)
    local confirmMenu=CCMenu:createWithItem(self.confirmBtn)
    confirmMenu:setPosition(ccp(200,self.bgLayer:getContentSize().height-245))
    confirmMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:addChild(confirmMenu,1)
    if lefttime>0 then
        self.confirmBtn:setEnabled(false)
    end

    local function returnCallback()
        PlayEffect(audioCfg.mouseClick)
        local function returnHandler(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                helpDefendVoApi:deleteOne(helpDefendVo.id)
                self:close()
            end
        end
        local cid=RemoveFirstChar(helpDefendVo.id)
        socketHelper:helpTroopBack(cid,helpDefendVo.uid,returnHandler)
    end
    local returnItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",returnCallback,11,getlocal("coverFleetBack"),25)
    local scale=0.8
    returnItem:setScale(scale)
    local returnMenu=CCMenu:createWithItem(returnItem)
    returnMenu:setPosition(ccp(450,self.bgLayer:getContentSize().height-245))
    returnMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:addChild(returnMenu,1)
    if lefttime>0 then
        returnItem:setEnabled(false)
    end

    local sizeLb=220*2+100
    local temHight=0
    if G_isIphone5() then
        temHight=110
    end
    for k=1,6 do

        local width = self.bgLayer:getContentSize().width-(math.ceil(k/3))*260
        local height = sizeLb-(((k-1)%3)*210+60)
        
        local function touchClick(hd,fn,idx)
        
        end
        local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("BgEmptyTank.png",CCRect(10, 10, 20, 20),touchClick)
        bgSp:setContentSize(CCSizeMake(150, 150))
        bgSp:ignoreAnchorPointForPosition(false)
        bgSp:setAnchorPoint(ccp(0,0))
        bgSp:setIsSallow(false)
        bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
        bgSp:setPosition(ccp(width,height+temHight))
        self.bgLayer:addChild(bgSp,1)
        
        local v=nil
        if helpDefendVo.tankInfoTab~=nil then
            v=helpDefendVo.tankInfoTab[k]
        end
        if v[1]~=nil and v[2]~=nil and v[2]>0 then
            local slotId=tonumber(RemoveFirstChar(v[1]))
            local icon = tankVoApi:getTankIconSp(slotId)
            icon:setPosition(getCenterPoint(bgSp))
            bgSp:addChild(icon,2)
            
            local str=(getlocal(tankCfg[slotId].name)).."("..tostring(v[2])..")"
            local descLable = GetTTFLabelWrap(str,26,CCSizeMake(260, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            descLable:setAnchorPoint(ccp(0.5,1))
            descLable:setPosition(ccp(width+bgSp:getContentSize().width/2,height-20+temHight))
            self.bgLayer:addChild(descLable,2)
        end
        
    end

end


function helpDefenseInfoDialog:close()
    self.bgLayer:removeFromParentAndCleanup(true)
    self:dispose()
    for k,v in pairs(base.commonDialogOpened_WeakTb) do
        if v==self then
            table.remove(base.commonDialogOpened_WeakTb,k)
            break
        end
    end
end
function helpDefenseInfoDialog:dispose()
    self.confirmBtn=nil
    self.bgLayer=nil
    self.closeBtn=nil
    
end
