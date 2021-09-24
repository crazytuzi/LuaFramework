tankDialogTab2={

}

function tankDialogTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil;
    self.bgLayer=nil;
    self.tanksSlotTab={};
    self.tickSlotTab={};
    self.tickSlotBG={};
    self.layerNum=nil;
    self.enTime=nil;
    self.isfirstTime1=nil;
    self.isfirstTime2=nil;
    self.isfirstTime3=nil;
    self.noAtkLb=nil;
    self.sendBtn=nil;
    self.sendMenu=nil;
    self.type=nil;
    
    return nc;

end

function tankDialogTab2:init(parent,type,layerNum)

    self.type=type;
    self.isfirstTime1=1;
    self.isfirstTime2=1;
    self.isfirstTime3=1;
    self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
    self.bgLayer=CCLayer:create();
    self.layerNum=layerNum;
    self:initTableView();


    
    if type~=2 then
    
        self.noAtkLb=GetTTFLabelWrap(getlocal("jumpToWorld"),24,CCSizeMake(500, 100),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        --self.noAtkLb=GetTTFLabel(getlocal("jumpToWorld"),25);
        self.noAtkLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2));
        self.noAtkLb:setColor(ccc3(144,144,144))
        self.bgLayer:addChild(self.noAtkLb)
        
        local function sendHandler()
            parent:close()
            mainUI:changeToWorld()
        end
        self.sendBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",sendHandler,nil,getlocal("jumpButton"),25)
        self.sendMenu=CCMenu:createWithItem(self.sendBtn)
        self.sendMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-200))
        self.sendMenu:setTouchPriority(-(self.layerNum-1)*20-5)
        self.bgLayer:addChild(self.sendMenu,2)
        
        self.noAtkLb:setVisible(false)
        self.sendMenu:setVisible(false)

        if SizeOfTable(attackTankSoltVoApi:getAllAttackTankSlots())>0 then
            self.noAtkLb:setVisible(false)
            self.sendMenu:setVisible(false)
        else
            self.noAtkLb:setVisible(true)
            self.sendMenu:setVisible(true)

        end
    end

    local function refreshSlot(event,data)
        if self.tv then
            self.tickSlotBG={}
            self.tickSlotTab={}
            self.tanksSlotTab={}
            self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
            self.tv:reloadData()
        end
    end
    self.refreshSlotListener=refreshSlot
    eventDispatcher:addEventListener("attackTankSlot.refreshSlot",refreshSlot)

    return self.bgLayer
end

function tankDialogTab2:initTableView()

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,G_VisibleSize.height-85-120),nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function tankDialogTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
            self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
           return SizeOfTable(self.tanksSlotTab)
           
   elseif fn=="tableCellSizeForIndex" then
   
       local tmpSize
       tmpSize=CCSizeMake(600,100)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
            cell:autorelease()
            local rect = CCRect(0, 0, 50, 50);
            local capInSet = CCRect(20, 20, 10, 10);
            local function cellClick(hd,fn,idx)
                --return self:cellClick(idx)
            end

            local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 100))
            backSprie:ignoreAnchorPointForPosition(false);
            backSprie:setAnchorPoint(ccp(0,0));
            backSprie:setTag(1000+idx)
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority((-(self.layerNum-1)*20-2))
            cell:addChild(backSprie,1)

            local nameStr;
            if self.tanksSlotTab[idx+1].type>0 and self.tanksSlotTab[idx+1].type<6 then
                nameStr=getlocal("world_island_"..self.tanksSlotTab[idx+1].type).." "..getlocal("lower_level").."."..self.tanksSlotTab[idx+1].level.."("..self.tanksSlotTab[idx+1].targetid[1]..","..self.tanksSlotTab[idx+1].targetid[2]..")"
                if G_getCurChoseLanguage()=="ar" then
                    nameStr=" "..getlocal("lower_level").."."..self.tanksSlotTab[idx+1].level.."("..self.tanksSlotTab[idx+1].targetid[1]..","..self.tanksSlotTab[idx+1].targetid[2]..")"..getlocal("world_island_"..self.tanksSlotTab[idx+1].type)
                end
            elseif(self.tanksSlotTab[idx+1].type==6)then
                nameStr=self.tanksSlotTab[idx+1].tName.." "..getlocal("lower_level").."."..self.tanksSlotTab[idx+1].level;
            elseif(self.tanksSlotTab[idx+1].type==7)then
                local rebelPic=self.tanksSlotTab[idx+1].rebelRpic
                nameStr=rebelVoApi:getRebelName(self.tanksSlotTab[idx+1].level,self.tanksSlotTab[idx+1].rebelIndex,false,rebelPic)
            elseif self.tanksSlotTab[idx+1].type==8 then
                nameStr=allianceCityVoApi:getAllianceCityName(self.tanksSlotTab[idx+1].tName,self.tanksSlotTab[idx+1].level)
            end
            
            local labName=GetTTFLabelWrap(nameStr,20,CCSizeMake(24*12,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            labName:setAnchorPoint(ccp(0,0.5));
            labName:setPosition(ccp(106,backSprie:getContentSize().height-30))
            backSprie:addChild(labName)
                        
            AddProgramTimer(backSprie,ccp(240,backSprie:getContentSize().height/2-15),9,12,getlocal("attckarrivade"),"TeamTravelBarBg.png","TeamTravelBar.png",11,nil,nil,nil,nil,20);
            local moneyTimerSprite = tolua.cast(backSprie:getChildByTag(9),"CCProgressTimer")
            self.tickSlotTab[idx+1]=moneyTimerSprite;
            
            local cellTankSlot = self.tanksSlotTab[idx+1]
            --判断如果不为采集满 并且不为协防已经到达那种 就显示正确的进度条
            if cellTankSlot.isGather~=3 and cellTankSlot.isGather~=4 and cellTankSlot.isGather~=5 then
                local lefttime,totaletime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.tanksSlotTab[idx+1].slotId)
                local per=(totaletime-lefttime)/totaletime*100
                moneyTimerSprite:setPercentage(per);
            end
            
            
            local lbPer = tolua.cast(moneyTimerSprite:getChildByTag(12),"CCLabelTTF")
            
            local iconSp;
            --情况1 采集中的时候
            if cellTankSlot.isGather==2 and cellTankSlot.bs==nil then
            
                iconSp=CCSprite:createWithSpriteFrameName("IconOccupy.png")
                iconSp:setTag(101);
                local nowRes,maxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotId(self.tanksSlotTab[idx+1].slotId)

                local per=nowRes/maxRes*100
                moneyTimerSprite:setPercentage(per);
                if nowRes>=maxRes then
                   nowRes=maxRes
                end

                lbPer:setString(getlocal("stayForResource",{FormatNumber(nowRes),FormatNumber(maxRes)}))
                
                local function backTouch()
                    local cityFlag
                    if self.tanksSlotTab[idx+1].type==8 then
                        cityFlag=1
                    end

                    if self.tv:getIsScrolled()==true then
                        do
                            return
                        end
                    end
                    local nowRes,maxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotId(self.tanksSlotTab[idx+1].slotId)
                    if nowRes<maxRes then

                        local function backSure()

                            local function serverBack(fn,data)
                                --local retTb=OBJDEF:decode(data)
                                if base:checkServerData(data)==true then
                                    self.tickSlotBG={}
                                    self.tickSlotTab={}
                                    self.tanksSlotTab={}
                                    self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                                    self.tv:reloadData()		
                                    enemyVoApi:deleteEnemy(self.tanksSlotTab[idx+1].targetid[1],self.tanksSlotTab[idx+1].targetid[2])
                                    eventDispatcher:dispatchEvent("worldScene.mineChange",{{x=self.tanksSlotTab[idx+1].targetid[1],y=self.tanksSlotTab[idx+1].targetid[2]}})
                                end
                             end
                            socketHelper:troopBack(self.tanksSlotTab[idx+1].slotId,serverBack,nil,cityFlag)
                        end
                        
                        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),backSure,getlocal("dialog_title_prompt"),getlocal("fleetStaying"),nil,self.layerNum+1)
                    else

                            local function serverBack(fn,data)
                                --local retTb=OBJDEF:decode(data)
                                if base:checkServerData(data)==true then
                                    self.tickSlotBG={}
                                    self.tickSlotTab={}
                                    self.tanksSlotTab={}
                                    self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                                    self.tv:reloadData()		
                                    enemyVoApi:deleteEnemy(self.tanksSlotTab[idx+1].targetid[1],self.tanksSlotTab[idx+1].targetid[2])
                                    eventDispatcher:dispatchEvent("worldScene.mineChange",{{x=self.tanksSlotTab[idx+1].targetid[1],y=self.tanksSlotTab[idx+1].targetid[2]}})
                                end
                             end
                            socketHelper:troopBack(self.tanksSlotTab[idx+1].slotId,serverBack,nil,cityFlag)

                    end

                    
                end
                local backItem=GetButtonItem("yh_IconReturnBtn.png","yh_IconReturnBtn_Down.png","yh_IconReturnBtn.png",backTouch,nil,nil,nil)
                local backMenu=CCMenu:createWithItem(backItem);
            backMenu:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2))
                backMenu:setTouchPriority(-(self.layerNum-1)*20-2);
                backSprie:addChild(backMenu)
            --情况2 采集满的时候
            elseif cellTankSlot.isGather==3 and cellTankSlot.bs==nil then
                iconSp=CCSprite:createWithSpriteFrameName("IconOccupy.png")
                iconSp:setTag(101);
                local nowRes,maxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotId(self.tanksSlotTab[idx+1].slotId)

                local per=100
                moneyTimerSprite:setPercentage(per);

                lbPer:setString(getlocal("stayForResource",{FormatNumber(maxRes),FormatNumber(maxRes)}))
                
                local function backTouch()
                    local cityFlag
                    if self.tanksSlotTab[idx+1].type==8 then
                        cityFlag=1
                    end
                    local function serverBack(fn,data)
                        --local retTb=OBJDEF:decode(data)
                        if base:checkServerData(data)==true then
                            self.tickSlotBG={}
                            self.tickSlotTab={}
                            self.tanksSlotTab={}
                            self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                            self.tv:reloadData()
							enemyVoApi:deleteEnemy(self.tanksSlotTab[idx+1].targetid[1],self.tanksSlotTab[idx+1].targetid[2])
                            eventDispatcher:dispatchEvent("worldScene.mineChange",{{x=self.tanksSlotTab[idx+1].targetid[1],y=self.tanksSlotTab[idx+1].targetid[2]}})
                        end
                     end
                    socketHelper:troopBack(self.tanksSlotTab[idx+1].slotId,serverBack,nil,cityFlag)
                    
                end
                local backItem=GetButtonItem("yh_IconReturnBtn.png","yh_IconReturnBtn_Down.png","yh_IconReturnBtn.png",backTouch,nil,nil,nil)
                local backMenu=CCMenu:createWithItem(backItem);
            backMenu:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2))
                backMenu:setTouchPriority(-(self.layerNum-1)*20-2);
                backSprie:addChild(backMenu)
            --情况3 协防正在进行时(包括驻防军团城市 isDef表明是驻防军团城市)
            elseif (cellTankSlot.isHelp~=nil and cellTankSlot.bs==nil and cellTankSlot.isGather~=4 and cellTankSlot.isGather~=5) or (cellTankSlot.isDef>0 and cellTankSlot.bs==nil and cellTankSlot.isGather~=5 and cellTankSlot.isGather~=6) then
                iconSp=CCSprite:createWithSpriteFrameName("IconAttack.png")
                iconSp:setTag(104)
                
                local function touch1()
                    if self.tv:getIsScrolled()==true then
                        do
                            return
                        end
                    end
                
                    local function cronBack()
                        local function cronAttackCallBack(fn,data)
                              local retTb=G_Json.decode(tostring(data))
                              --OBJDEF:decode(data)
                              if base:checkServerData(data)==true then
                                   
                                    for k,v in pairs(self.tickSlotTab) do
                                        v:removeFromParentAndCleanup(true)
                                        v=nil
                                    end
                                    self.tickSlotTab={}
                                    self.tanksSlotTab={}
                                    self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                                    self.tv:reloadData()

                                    if base.heroSwitch==1 then
                                        --请求英雄数据
                                        local function heroGetlistHandler(fn,data)
                                            local ret,sData=base:checkServerData(data)
                                            if ret==true then
                                                if base.he==1 and sData and sData.data and sData.data.equip and heroEquipVoApi then
                                                    heroEquipVoApi:formatData(sData.data.equip)
                                                    heroEquipVoApi.ifNeedSendRequest=true
                                                end
                                            end
                                        end
                                        socketHelper:heroGetlist(heroGetlistHandler)
                                    end
                                    --更新邮件
                                    --G_updateEmailList(2)
                              end
                        end
                        local cronidSend=self.tanksSlotTab[idx+1].slotId;
                        local targetSend=self.tanksSlotTab[idx+1].targetid;
                        local attackerSend=playerVoApi:getUid()

                        socketHelper:cronAttack(cronidSend,targetSend,attackerSend,1,cronAttackCallBack);
                    end
                    
                    local leftTime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.tanksSlotTab[idx+1].slotId)
                    
                    if leftTime>=0 then
                            local needGemsNum=TimeToGems(leftTime)
                            local needGems=getlocal("speedUp",{needGemsNum})
                         if needGemsNum>playerVoApi:getGems() then --金币不足
                            GemsNotEnoughDialog(nil,nil,needGemsNum-playerVoApi:getGems(),self.layerNum+1,needGemsNum)
                         else
                            local smallD=smallDialog:new()
                            smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),cronBack,getlocal("dialog_title_prompt"),needGems,nil,self.layerNum+1)
                         end
                     end
                end
                
                local menuItem1 = GetButtonItem("yh_BtnRight.png","yh_BtnRight_Down.png","yh_BtnRight_Down.png",touch1,10,nil,nil)
                    local menu1 = CCMenu:createWithItem(menuItem1);
                menu1:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2));
                menu1:setTouchPriority(-(self.layerNum-1)*20-2);
                backSprie:addChild(menu1,3);

                local time=GetTimeStr(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.tanksSlotTab[idx+1].slotId))
                lbPer:setString(getlocal("attckarrivade",{time}))


            
            --情况4 协防已经达到的时候、军团城市驻防到达、进攻军团城市到达
            elseif (cellTankSlot.isGather==4 or cellTankSlot.isGather==5) and cellTankSlot.bs==nil then
                iconSp=CCSprite:createWithSpriteFrameName("IconDefense.png")
                iconSp:setTag(105);
                local stateStr,backFlag=nil,true
                if cellTankSlot.isGather==4 then
                    stateStr=getlocal("standbying")
                elseif cellTankSlot.isGather==5 and cellTankSlot.isDef==0 and cellTankSlot.isHelp==1 then --协防玩家城市
                    stateStr=getlocal("defensing")
                elseif cellTankSlot.isGather==5 and cellTankSlot.isDef==0 and cellTankSlot.isHelp==nil and cellTankSlot.type==8 then --军团城市战斗中。。。
                    stateStr=getlocal("cityattacking")
                    backFlag=attackTankSoltVoApi:isCanBackTroops(cellTankSlot) --战斗中撤回部队限制
                elseif cellTankSlot.isGather==5 and cellTankSlot.isDef>0 then --军团城市驻防中
                    stateStr=getlocal("citydefending")
                end
                local per=100
                moneyTimerSprite:setPercentage(per);
                
                lbPer:setString(stateStr)
                local function backTouch()
                    local cityFlag
                    if self.tanksSlotTab[idx+1].type==8 then
                        cityFlag=1
                    end
                    local function serverBack(fn,data)
                        --local retTb=OBJDEF:decode(data)
                        if base:checkServerData(data)==true then
                            self.tickSlotBG={}
                            self.tickSlotTab={}
                            self.tanksSlotTab={}
                            self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                            self.tv:reloadData()
							enemyVoApi:deleteEnemy(self.tanksSlotTab[idx+1].targetid[1],self.tanksSlotTab[idx+1].targetid[2])
                        end
                     end
                    socketHelper:troopBack(self.tanksSlotTab[idx+1].slotId,serverBack,nil,cityFlag)
                    
                end
                local backItem=GetButtonItem("yh_IconReturnBtn.png","yh_IconReturnBtn_Down.png","yh_IconReturnBtn.png",backTouch,nil,nil,nil)
                local backMenu=CCMenu:createWithItem(backItem);
            backMenu:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2))
                backMenu:setTouchPriority(-(self.layerNum-1)*20-2);
                backSprie:addChild(backMenu)
                backItem:setEnabled(backFlag)
                backItem:setVisible(backFlag)
            --情况5 返航的时候
            elseif self.tanksSlotTab[idx+1].bs~=nil then
                
                local function touch1()
                    if self.tv:getIsScrolled()==true then
                        do
                            return
                        end
                    end
                
                    local function speedBack()
                        local function troopBackSpeedupCallBack(fn,data)
                              local retTb=G_Json.decode(tostring(data))
                              --OBJDEF:decode(data)
                              if base:checkServerData(data)==true then
                                   
                                    for k,v in pairs(self.tickSlotTab) do
                                        v:removeFromParentAndCleanup(true)
                                        v=nil
                                    end
                                    self.tickSlotBG={}
                                    self.tickSlotTab={}
                                    self.tanksSlotTab={}
                                    self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                                    self.tv:reloadData()
                              end
                        end
                     if self.tanksSlotTab[idx+1]~=nil then
                            local cidSend=self.tanksSlotTab[idx+1].slotId;
                            socketHelper:troopBackSpeedup(cidSend,troopBackSpeedupCallBack);
                     end
                    end
                    local leftTime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.tanksSlotTab[idx+1].slotId)
                    
                    if leftTime>=0 then
                            local needGemsNum=TimeToGems(leftTime)
                            local needGems=getlocal("speedUp",{needGemsNum})
                         if needGemsNum>playerVoApi:getGems() then --金币不足
                            GemsNotEnoughDialog(nil,nil,needGemsNum-playerVoApi:getGems(),self.layerNum+1,needGemsNum)
                         else
                            local smallD=smallDialog:new()
                            smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),speedBack,getlocal("dialog_title_prompt"),needGems,nil,self.layerNum+1)
                         end
                     end
                end
                
                local menuItem1 = GetButtonItem("yh_BtnRight.png","yh_BtnRight_Down.png","yh_BtnRight_Down.png",touch1,10,nil,nil)
                    local menu1 = CCMenu:createWithItem(menuItem1);
                menu1:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2));
                menu1:setTouchPriority(-(self.layerNum-1)*20-2);
                backSprie:addChild(menu1,3);

                iconSp=CCSprite:createWithSpriteFrameName("IconReturn-.png")
                iconSp:setTag(102);
                local time=GetTimeStr(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.tanksSlotTab[idx+1].slotId))
                lbPer:setString(getlocal("returnarrivade",{time}))
            --情况6 部队前行中
            else
                
                local function touch1()
                    if self.tv:getIsScrolled()==true then
                        do
                            return
                        end
                    end
                
                    local function cronBack()
                        local function cronAttackCallBack(fn,data)
                              local retTb=G_Json.decode(tostring(data))
                              --OBJDEF:decode(data)
                              if base:checkServerData(data)==true then
                                   
                                    for k,v in pairs(self.tickSlotTab) do
                                        v:removeFromParentAndCleanup(true)
                                        v=nil
                                    end
                                    self.tickSlotTab={}
                                    if(self.tanksSlotTab[idx+1].targetid[1] and self.tanksSlotTab[idx+1].targetid[2])then
                                        eventDispatcher:dispatchEvent("worldScene.mineChange",{{x=self.tanksSlotTab[idx+1].targetid[1],y=self.tanksSlotTab[idx+1].targetid[2]}})
                                    end
                                    self.tanksSlotTab={}
                                    self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                                    self.tv:reloadData()
                                    if base.heroSwitch==1 then
                                        --请求英雄数据
                                        local function heroGetlistHandler(fn,data)
                                            local ret,sData=base:checkServerData(data)
                                            if ret==true then
                                                if base.he==1 and sData and sData.data and sData.data.equip and heroEquipVoApi then
                                                    heroEquipVoApi:formatData(sData.data.equip)
                                                    heroEquipVoApi.ifNeedSendRequest=true
                                                end
                                            end
                                        end
                                        socketHelper:heroGetlist(heroGetlistHandler)
                                    end
                                    --更新邮件
                                    --G_updateEmailList(2)
                              end
                        end
                        local cronidSend=self.tanksSlotTab[idx+1].slotId;
                        local targetSend=self.tanksSlotTab[idx+1].targetid;
                        local attackerSend=playerVoApi:getUid()

                        socketHelper:cronAttack(cronidSend,targetSend,attackerSend,1,cronAttackCallBack);
                    end
                    
                    local leftTime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.tanksSlotTab[idx+1].slotId)
                    
                    if leftTime>=0 then
                            local needGemsNum=TimeToGems(leftTime)
                            local needGems=getlocal("speedUp",{needGemsNum})
                         if needGemsNum>playerVoApi:getGems() then --金币不足
                            GemsNotEnoughDialog(nil,nil,needGemsNum-playerVoApi:getGems(),self.layerNum+1,needGemsNum)
                         else
                            local smallD=smallDialog:new()
                            smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),cronBack,getlocal("dialog_title_prompt"),needGems,nil,self.layerNum+1)
                         end
                     end
                end
                
                local menuItem1 = GetButtonItem("yh_BtnRight.png","yh_BtnRight_Down.png","yh_BtnRight_Down.png",touch1,10,nil,nil)
                    local menu1 = CCMenu:createWithItem(menuItem1);
                menu1:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2));
                menu1:setTouchPriority(-(self.layerNum-1)*20-2);
                backSprie:addChild(menu1,3);

                local time=GetTimeStr(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.tanksSlotTab[idx+1].slotId))
                iconSp=CCSprite:createWithSpriteFrameName("IconAttack.png")
                iconSp:setTag(103);
                lbPer:setString(getlocal("attckarrivade",{time}))
            end
            iconSp:setPosition(ccp(50,backSprie:getContentSize().height/2));
            backSprie:addChild(iconSp)
            self.tickSlotBG[idx+1]=iconSp;
            
            
            local function touch2()
                if self.tv:getIsScrolled()==true then
                        do
                            return
                        end
                end
                require "luascript/script/game/scene/gamedialog/warDialog/tankAttackInfoDialog"
                local tankInfo = tankAttackInfoDialog:new()
                local infoBg = tankInfo:init(self.tanksSlotTab[idx+1],self.tanksSlotTab[idx+1].troops,self.layerNum+1)                
            end
            
            
            
            local menuItem2 = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch2,11,nil,nil)
            local menu2 = CCMenu:createWithItem(menuItem2);
            menu2:setPosition(ccp(455,backSprie:getContentSize().height/2));
            menu2:setTouchPriority(-(self.layerNum-1)*20-2);
            backSprie:addChild(menu2,3);



            return cell
   
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end


end

function tankDialogTab2:tick()
    

    local isChange=false;
    self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
    if self.type~=2 then
        if SizeOfTable(self.tanksSlotTab)>0 then
            self.noAtkLb:setVisible(false)
            self.sendMenu:setVisible(false)
        else
            self.noAtkLb:setVisible(true)
            self.sendMenu:setVisible(true)
        end
    end

    if SizeOfTable(self.tanksSlotTab)~=SizeOfTable(self.tickSlotTab) then
        
        for k,v in pairs(self.tickSlotTab) do
            v:removeFromParentAndCleanup(true)
            v=nil
        end

        self.tickSlotTab={}
        self.tv:reloadData()
        do
            return
        end

    end
    
    
    for k,v in pairs(self.tickSlotTab) do
        
        if self.tanksSlotTab[k].isGather==2 and self.tanksSlotTab[k].bs==nil then
            
            if self.tickSlotBG[k]:getTag()~=101 then
                self.tickSlotBG={}
                self.tickSlotTab={}
                self.tanksSlotTab={}
                self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                self.tv:reloadData()
            end

            local nowRes,maxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotId(self.tanksSlotTab[k].slotId)
            local per=nowRes/maxRes
            v:setPercentage(per*100);


            local totleRes=maxRes
            local lbPer = tolua.cast(v:getChildByTag(12),"CCLabelTTF")
            if nowRes>=totleRes then
               nowRes=totleRes
            end

            lbPer:setString(getlocal("stayForResource",{FormatNumber(math.floor(nowRes)),FormatNumber(totleRes)}))
        elseif (self.tanksSlotTab[k].isHelp~=nil and self.tanksSlotTab[k].bs==nil and self.tanksSlotTab[k].isGather~=4 and self.tanksSlotTab[k].isGather~=5) or (self.tanksSlotTab[k].isDef>0 and self.tanksSlotTab[k].bs==nil and self.tanksSlotTab[k].isGather~=5 and self.tanksSlotTab[k].isGather~=6)then
            if self.tickSlotBG[k]:getTag()~=104 then
                self.tickSlotBG={}
                self.tickSlotTab={}
                self.tanksSlotTab={}
                self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                self.tv:reloadData()
            end
            local lefttime,totletime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.tanksSlotTab[k].slotId)
            local per=(totletime-lefttime)/totletime*100
            v:setPercentage(per);
            local lbPer = tolua.cast(v:getChildByTag(12),"CCLabelTTF")
            
            local time=GetTimeStr(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.tanksSlotTab[k].slotId))
            lbPer:setString(getlocal("attckarrivade",{time}))
        elseif (self.tanksSlotTab[k].isGather==4 or self.tanksSlotTab[k].isGather==5) and self.tanksSlotTab[k].bs==nil then
            if self.tickSlotBG[k]:getTag()~=105 then
                self.tickSlotBG={}
                self.tickSlotTab={}
                self.tanksSlotTab={}
                self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                self.tv:reloadData()
            end

            v:setPercentage(100);
            local lbPer = tolua.cast(v:getChildByTag(12),"CCLabelTTF")

        elseif self.tanksSlotTab[k].isGather==3 and self.tanksSlotTab[k].bs==nil then
            if self.tickSlotBG[k]:getTag()~=101 then
                self.tickSlotBG={}
                self.tickSlotTab={}
                self.tanksSlotTab={}
                self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                self.tv:reloadData()
            end

            local nowRes,maxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotId(self.tanksSlotTab[k].slotId)
            --local per=nowRes/maxRes
            v:setPercentage(100);


            local totleRes=maxRes
            local lbPer = tolua.cast(v:getChildByTag(12),"CCLabelTTF")

            --lbPer:setString(getlocal("stayForResource",{FormatNumber(math.floor(totleRes)),FormatNumber(totleRes)}))

        elseif self.tanksSlotTab[k].bs~=nil then
            if self.tickSlotBG[k]:getTag()~=102 then
                self.tickSlotBG={}
                self.tickSlotTab={}
                self.tanksSlotTab={}
                self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                self.tv:reloadData()
            end
            
            local lefttime,totletime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.tanksSlotTab[k].slotId)
            local per=(totletime-lefttime)/totletime*100
            v:setPercentage(per);
            local lbPer = tolua.cast(v:getChildByTag(12),"CCLabelTTF")
            
            local time=GetTimeStr(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.tanksSlotTab[k].slotId))
            lbPer:setString(getlocal("returnarrivade",{time}))
            if lefttime<=0 then
                
                for k,v in pairs(self.tickSlotTab) do
                    v:removeFromParentAndCleanup(true)
                    v=nil
                end

                self.tickSlotTab={}
                self.tanksSlotTab={}
                self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                self.tv:reloadData()
            end
        
        else
            if self.tickSlotBG[k]:getTag()~=103 then
                self.tickSlotBG={}
                self.tickSlotTab={}
                self.tanksSlotTab={}
                self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                self.tv:reloadData()
            end
            local lefttime,totletime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.tanksSlotTab[k].slotId)
            local per=(totletime-lefttime)/totletime*100
            v:setPercentage(per);
            local lbPer = tolua.cast(v:getChildByTag(12),"CCLabelTTF")
            
            local time=GetTimeStr(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(self.tanksSlotTab[k].slotId))
            lbPer:setString(getlocal("attckarrivade",{time}))
            if lefttime<=0 then
                if self.tanksSlotTab[k].signState==1 then
                    for k,v in pairs(self.tickSlotTab) do
                                v:removeFromParentAndCleanup(true)
                                v=nil
                            end
                            self.tickSlotBG={}

                            self.tickSlotTab={}
                            self.tanksSlotTab={}
                            self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                            self.tv:reloadData()
                end

                
            end
        end

    end
end


--用户处理特殊需求,没有可以不写此方法
function tankDialogTab2:doUserHandler()

end

--点击了cell或cell上某个按钮
function tankDialogTab2:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,120)
        else
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,800)
        end
    end
end
function tankDialogTab2:dispose()
    if self.refreshSlotListener then
        eventDispatcher:removeEventListener("attackTankSlot.refreshSlot",self.refreshSlotListener)
        self.refreshSlotListener=nil
    end
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil;
    self.tv=nil;
    self.tanksSlotTab={};
    self.tanksSlotTab=nil;
    self.tickSlotTab={}
    self.tickSlotTab=nil;
    self.layerNum=nil;
 self.noAtkLb=nil;
 self.sendBtn=nil;
 self.sendMenu=nil;
    
end
