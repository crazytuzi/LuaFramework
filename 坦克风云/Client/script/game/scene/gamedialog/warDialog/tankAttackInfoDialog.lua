tankAttackInfoDialog={

}

function tankAttackInfoDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bgLayer=nil
    self.closeBtn=nil
    self.tankSlotVo=nil
    self.tankTb=nil
    self.isAlienMines=false
    self.messageTb=nil
    self.cellHeightTb=nil
    self.output=nil
    self.txtSize=26
    self.resTb=nil
    return nc;

end

function tankAttackInfoDialog:init(tankSlotVo,tankTb,layerNum,isAlienMines)
    self.tankSlotVo=tankSlotVo
    self.tankTb=tankTb
    self.isAlienMines=isAlienMines
    -- self.repairTank=tankVoApi:getRepairTanks()
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

    local titleLable = GetTTFLabel(getlocal("fleetInfoTitle1"),40)
    titleLable:setAnchorPoint(ccp(0.5,1))
    titleLable:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-20));
    self.bgLayer:addChild(titleLable,1)
    
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
    
    sceneGame:addChild(self.bgLayer,layerNum)
    --return self.bgLayer
    table.insert(base.commonDialogOpened_WeakTb,self)

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,self.bgLayer:getContentSize().height-120),nil)
    self.tv:setPosition(ccp(25,30))
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv,2)
end

function tankAttackInfoDialog:getCellHight(idx)
    if self.cellHeightTb==nil then
        self.cellHeightTb={}
    end
    local tankSlotVo=self.tankSlotVo   
    if self.cellHeightTb[idx]==nil then
        self.cellHeightTb[idx]=0
        if idx==1 then
            local content={}
            local strState
            local timeStr
            local fleetloadStr
            local boomStr
            if tankSlotVo.bs~=nil and tankSlotVo.isHelp==nil then
                strState=getlocal("state3")
            elseif tankSlotVo.isDef>0 and tankSlotVo.isGather==5 then --军团城市驻防
                strState=getlocal("state5")
            elseif tankSlotVo.isDef==0 and tankSlotVo.isGather==5 and tankSlotVo.isHelp==nil and tankSlotVo.type==8 then
                strState=getlocal("state6")
            elseif tankSlotVo.isHelp~=nil then
                strState=getlocal("state4")
            elseif tankSlotVo.isGather==2 then
                strState=getlocal("state2")
            else
                strState=getlocal("state1")
            end
            table.insert(content,{strState,G_ColorWhite})

            local lefttime,totletime
            if self.isAlienMines==true then
                lefttime,totletime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotIdForAlienMines(tankSlotVo.slotId)
            else
                lefttime,totletime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(tankSlotVo.slotId)
            end
            local time=GetTimeStr(lefttime)
            if tankSlotVo.isGather==2 and tankSlotVo.bs==nil then
                time=GetTimeStr(lefttime)
            end
            timeStr=getlocal("costTime1",{time})
            table.insert(content,{timeStr,G_ColorWhite})

            local temTb={}
            for k,v in pairs(self.tankTb) do
                if v[1]~=nil then
                    local slotId=tonumber(RemoveFirstChar(v[1]))
                    temTb[k]={slotId,v[2]}
                end
            end
                
            local fleetload=FormatNumber(tankVoApi:getAttackTanksCarryResource(temTb))
            fleetloadStr=getlocal("limitLoad",{fleetload})
            table.insert(content,{fleetloadStr,G_ColorWhite})

            if (self.isAlienMines==nil or self.isAlienMines==false) and base.isGlory == 1 then
                local nowRes,maxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotId(tankSlotVo.slotId)
                if nowRes~=nil and maxRes~=nil then
                    if nowRes >maxRes then
                        nowRes = maxRes 
                    end
                    local getGloryNums = gloryVoApi:getGloryNums(nowRes)
                    boomStr=getlocal("gloryGetStr",{getGloryNums})
                    table.insert(content,{boomStr,G_ColorWhite})
                end
            end

            for k,v in pairs(content) do
                if content[k]~=nil and content[k]~="" then
                    local contentMsg=content[k]
                    local message=""
                    if type(contentMsg)=="table" then
                        message=contentMsg[1]
                    else
                        message=contentMsg
                    end
                    local contentLb
                    contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(self.txtSize*22,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    contentLb:setAnchorPoint(ccp(0,1))
                    self.cellHeightTb[idx]=self.cellHeightTb[idx]+contentLb:getContentSize().height
                end
            end
            self.messageTb=content
        elseif idx==2 then
            if (self.isAlienMines and self.isAlienMines==true) or (tankSlotVo.isDef>0) then
                self.cellHeightTb[idx]=650
            else
                local nowRes,maxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotId(tankSlotVo.slotId)
                if nowRes==nil then
                    self.cellHeightTb[idx]=0
                    return self.cellHeightTb[idx]
                end
                local lefttime,totletime
                if self.isAlienMines==true then
                    lefttime,totletime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotIdForAlienMines(tankSlotVo.slotId)
                else
                    lefttime,totletime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(tankSlotVo.slotId)
                end
                local resCount=0
                local gemsCount=0
                local goldMineLv=0
                if tankSlotVo.goldMine and tankSlotVo.goldMine[3] then
                    goldMineLv=tankSlotVo.goldMine[3]
                end
                if goldMineLv>0 and tankSlotVo.goldMine then
                  
                    if tankSlotVo.bs~=nil then
                        gemsCount=tankSlotVo.gems
                    else
                        gemsCount=tankSlotVo.gems
                        if tankSlotVo.gts1 then
                            if tonumber(tankSlotVo.gts1)>tonumber(tankSlotVo.goldMine[2]) then
                                tankSlotVo.gts1=tonumber(tankSlotVo.goldMine[2])
                            end
                            local ggs --采集队列上绑定的金矿采集速度
                            if tankSlotVo and tankSlotVo.goldMine and tankSlotVo.goldMine[4] then
                                ggs = tankSlotVo.goldMine[4]
                            end
                            local gatherTime=tonumber(base.serverTime-tonumber(tankSlotVo.gts1))
                            gemsCount=goldMineVoApi:getGatherGemsCount(gatherTime, ggs)+gemsCount
                        end
                    end
                end
                self.output=worldBaseVoApi:getMineResContent(tankSlotVo.type,tankSlotVo.level,tankSlotVo.heatLv,goldMineLv,nil,tankSlotVo)
                if self.output then
                    self.resTb={}
                    for k,v in pairs(self.output) do
                        local count=0
                        if v.type=="u" then
                            if v.key=="gems" then
                                count=gemsCount
                            else
                                count=nowRes
                            end
                        elseif v.type=="r" then
                            count=attackTankSoltVoApi:getAlienResBySlot(tankSlotVo,nowRes,v.key,v.rate)
                        end
                        if self.resTb[v.type]==nil then
                            self.resTb[v.type]={}
                        end
                        if count and tonumber(count)>0 then
                            self.resTb[v.type][v.key]=tonumber(count)
                            resCount=resCount+1
                        end
                    end
          
                end
                local addHeight=0
                if resCount%2==0 then
                    addHeight=(resCount/2)*40
                else
                    addHeight=(resCount/2+1)*40
                end
                addHeight=addHeight
                if resCount>0 then
                    self.cellHeightTb[idx]=addHeight+50
                else
                    self.cellHeightTb[idx]=0
                end
            end
        elseif idx==3 then
            self.cellHeightTb[idx]=650
        end
    end
    return self.cellHeightTb[idx]
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function tankAttackInfoDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        if (self.isAlienMines and self.isAlienMines==true) or (self.tankSlotVo.isDef>0) then
            return 2
        end
        return 3
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local width=self.bgLayer:getContentSize().width
        local height=self:getCellHight(idx+1)+10
        tmpSize=CCSizeMake(width,height)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        if idx==0 then
            if self.messageTb then
                local contentLbHight=0
                local content=self.messageTb
                for k,v in pairs(content) do
                    if content[k]~=nil and content[k]~="" then
                        local contentMsg=content[k]
                        local message=""
                        local color
                        if type(contentMsg)=="table" then
                            message=contentMsg[1]
                            color=contentMsg[2]
                        else
                            message=contentMsg
                        end
                        local contentLb
                        local contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(self.txtSize*22,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                        contentLb:setAnchorPoint(ccp(0,1))
                        if contentLbHight==0 then
                            contentLbHight=self.cellHeightTb[idx+1]
                        end
                        contentLb:setPosition(ccp(20,contentLbHight))
                        contentLbHight=contentLbHight-contentLb:getContentSize().height
                        cell:addChild(contentLb,1)
                        if color~=nil then
                            contentLb:setColor(color)
                        end
                    end
                end
            end
        elseif idx==1 and (self.isAlienMines==nil or self.isAlienMines==false) and self.tankSlotVo.isDef==0 then
            local resCount=0
            if self.output then
                for k,v in pairs(self.output) do
                    local count=self.resTb[v.type][v.key]
                    if count and tonumber(count)>0 then
                        resCount=resCount+1
                    end
                end
            end
            if resCount==0 then
                return cell
            end

            local proLb=GetTTFLabelWrap(getlocal("has_gather_resource"),self.txtSize,CCSizeMake(self.txtSize*22,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            proLb:setAnchorPoint(ccp(0,1))
            proLb:setPosition(ccp(20,self.cellHeightTb[idx+1]))
            cell:addChild(proLb)

            local posY=proLb:getPositionY()-60
            local function initResInfo(picName,resName,value,posX,posY,scale)
                local resSp = CCSprite:createWithSpriteFrameName(picName)
                resSp:setScale(scale)
                resSp:setPosition(ccp(posX,posY))
                cell:addChild(resSp)

                local resNameLb=GetTTFLabel(resName.."：",25)
                resNameLb:setAnchorPoint(ccp(0,0.5))
                resNameLb:setPosition(ccp(posX+30,resSp:getPositionY()))
                cell:addChild(resNameLb)

                local resCountLb=GetTTFLabel(FormatNumber(value),25)
                resCountLb:setAnchorPoint(ccp(0,0.5))
                resCountLb:setPosition(ccp(resNameLb:getPositionX()+resNameLb:getContentSize().width-10,resNameLb:getPositionY()))
                cell:addChild(resCountLb)
            end

            local function showResources()
                local resIdx=0
                local posX=0
                for k,v in pairs(self.output) do
                    local count=self.resTb[v.type][v.key]
                    if count and tonumber(count)>0 then
                        resIdx=resIdx+1
                        if resIdx%2==0 then
                            posX=320
                        else
                            posX=30
                        end
                        local scale=1
                        local pic
                        if v.type=="u" then
                            if v.key=="gems" then
                                pic="IconGold.png"
                            else
                                pic=worldBaseVoApi:getBaseResPicName(self.tankSlotVo.type)
                            end
                            scale=1.2
                        elseif v.type=="r" then
                            local id=RemoveFirstChar(v.key)
                            pic="alien_mines"..id.."_"..id..".png"
                            scale=0.5
                        end
                        if pic==nil then
                            pic=v.pic
                        end
                        initResInfo(pic,v.name,count,posX,posY,scale)

                        if resIdx%2==0 then
                            posY=posY-50
                        end
                    end
                end
            end
            if resCount>0 then
                showResources()
            end
        elseif (idx==1 and ((self.isAlienMines and self.isAlienMines==true) or self.tankSlotVo.isDef>0)) or idx==2 then
            local rect = CCRect(0, 0, 50, 50);
            local capInSet = CCRect(20, 20, 10, 10);
            local function cellClick(hd,fn,idx)
            end
            local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,cellClick)
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 40))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0,1))
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
            backSprie:setPosition(ccp(0,self.cellHeightTb[idx+1]))
            cell:addChild(backSprie,1)

            local titleLable = GetTTFLabel(getlocal("fleetInfoTitle2"),35)
            titleLable:setAnchorPoint(ccp(0.5,0.5))
            titleLable:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2));
            backSprie:addChild(titleLable,2)
            local sizeLb=backSprie:getPositionY()-backSprie:getContentSize().height-30
            for k=1,6 do
                local posX=self.bgLayer:getContentSize().width-math.ceil(k/3)*280
                local posY=sizeLb-(((k-1)%3)*220+10)
                local function touchClick(hd,fn,idx)
                
                end
                local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("BgEmptyTank.png",CCRect(10, 10, 20, 20),touchClick)
                bgSp:setContentSize(CCSizeMake(150, 150))
                bgSp:ignoreAnchorPointForPosition(false)
                bgSp:setAnchorPoint(ccp(0,1))
                bgSp:setIsSallow(false)
                bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
                bgSp:setPosition(ccp(posX,posY))
                cell:addChild(bgSp,1)
                
                local v=nil
                if self.tankTb~=nil then
                    v=self.tankTb[k]
                end
                if v[1]~=nil and v[2]>0 then
                    local slotId=tonumber(RemoveFirstChar(v[1]))
                    local icon = tankVoApi:getTankIconSp(slotId)--CCSprite:createWithSpriteFrameName(tankCfg[slotId].icon)
                    icon:setPosition(getCenterPoint(bgSp))
                    bgSp:addChild(icon,2)

                    if slotId~=G_pickedList(slotId) then
                        local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                        icon:addChild(pickedIcon)
                        pickedIcon:setPosition(icon:getContentSize().width*0.7,icon:getContentSize().height*0.5-20)
                        -- pickedIcon:setScale(icon:getContentSize().width/100)
                    end
                    
                    local str=(getlocal(tankCfg[slotId].name)).."("..tostring(v[2])..")"
                    local descLable = GetTTFLabelWrap(str,26,CCSizeMake(260,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                    descLable:setAnchorPoint(ccp(0.5,1))
                    descLable:setPosition(ccp(bgSp:getContentSize().width/2,-10))
                    bgSp:addChild(descLable,2)
                end
                if k%2==0 then
                    posY=posY-bgSp:getContentSize().height-60
                end
            end
        end
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function tankAttackInfoDialog:close()
    self.bgLayer:removeFromParentAndCleanup(true)
    self:dispose()
    for k,v in pairs(base.commonDialogOpened_WeakTb) do
        if v==self then
            table.remove(base.commonDialogOpened_WeakTb,k)
            break
        end
    end
end
function tankAttackInfoDialog:dispose()
    self.bgLayer=nil
    self.closeBtn=nil
    self.tankSlotVo=nil
    self.tankTb=nil
    self.isAlienMines=false
    self.messageTb=nil
    self.cellHeightTb=nil
    self.output=nil
    self.txtSize=26
    self.resTb=nil
end
