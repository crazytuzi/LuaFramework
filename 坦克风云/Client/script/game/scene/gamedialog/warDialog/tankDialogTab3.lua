tankDialogTab3={

}

function tankDialogTab3:new(repairText)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil;
    self.bgLayer=nil;
    self.myLayerTab3=nil;
    self.repairTank={};
    self.repairTankCopy={};
    
    self.layerNum=nil;
    self.enTime=nil;
    self.isGuide=nil;
    self.touchRepairSp2=nil
    self.numLabelTab={}
    self.repairText = repairText
    
    return nc;

end

function tankDialogTab3:initTab3Layer()

    self.repairTankCopy=tankVoApi:getRepairTanks()
    self.myLayerTab3=CCLayer:create();
    self.bgLayer:addChild(self.myLayerTab3)
    
    local tHeight = G_VisibleSize.height-230
    local repairAllLb=GetTTFLabelWrap(getlocal("repairAll"),24,CCSizeMake(30*6,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
    repairAllLb:setAnchorPoint(ccp(0.5,0.5));
    repairAllLb:setPosition(ccp(98,tHeight - 10));
    self.myLayerTab3:addChild(repairAllLb)
    
    local totalGlodCost=0
    local totalGemCost=0
    local totalNum = 0
    local repairVate
    local vo = activityVoApi:getActivityVo("baifudali")
    if vo and activityVoApi:isStart(vo)==true then
        repairVate = vo.repairVate
    end

    for k,v in pairs(self.repairTank) do
        local m_tankIndex=self.repairTank[k][1]
        local numTanks=self.repairTank[k][2]
        local glodCost=tonumber(tankCfg[m_tankIndex].glodCost)*numTanks
        local gemCost =math.ceil(tonumber(tankCfg[m_tankIndex].gemCost)*numTanks)
        if repairVate then
            glodCost = math.ceil(glodCost*(1-repairVate))
            gemCost = math.ceil(gemCost*(1-repairVate))
        end
        totalNum = totalNum+numTanks
        --玩家如果添加了高阶维修的军团科技，水晶修理费用随科技等级的提高而减少
        local repairRate = allianceSkillVoApi:getGoldRepairRate()
        glodCost=math.ceil(glodCost*repairRate)
        --角色技能，减少修坦克消耗
        local skillReduce=skillVoApi:getSkillAddPerById("s302")
        glodCost=math.ceil(glodCost*(1 - skillReduce))
        totalGlodCost=tonumber(totalGlodCost)+glodCost
        totalGemCost=totalGemCost+gemCost
    
    end
    --勇往直前活动, 水晶修理费用减少50%
    local vo=activityVoApi:getActivityVo("yongwangzhiqian")
    local ywzq2018Vo = activityVoApi:getActivityVo("ywzq")
    if vo and activityVoApi:isStart(vo) then
        totalGlodCost=totalGlodCost*vo.activeRes
    elseif ywzq2018Vo and activityVoApi:isStart(ywzq2018Vo) then
        totalGlodCost=totalGlodCost*ywzq2018Vo.activeRes
    end

    --主基地装扮减少的水晶修理费用
    if buildDecorateVoApi and buildDecorateVoApi.declineGoldCost and base.isSkin == 1 then
        totalGlodCost = math.ceil(totalGlodCost * (1-buildDecorateVoApi:declineGoldCost()))
    end

    local totalGlodCost2=totalGlodCost
    totalGlodCost=FormatNumber(tonumber(totalGlodCost))

    
    local function touchRepairByGem()   
        if totalNum==0 then
            do
                return
            end
        end
        self:removeGuied()
        if playerVoApi:getGems()>=totalGemCost then
            local function realRepair()
                local function serverRepair(fn,data)
                    if base:checkServerData(data)==true then
                        self:refreshTab3()
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allDamageFleetRepairSuccess"),28)
                    end
                end
                socketHelper:repairTanks(2,nil,nil,serverRepair)
            end
            local key="repairTank_gem_buy"
            if G_isPopBoard(key) then
                local function secondTipFunc(flag)
                    local sValue=base.serverTime .. "_" .. flag
                    G_changePopFlag(key,sValue)
                end
                G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{totalGemCost}),true,realRepair,secondTipFunc)
            else
                realRepair()
            end
        else
            vipVoApi:showRechargeDialog(3)
            -- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("repairNoMoney"),nil,self.layerNum+1)            
        end

    end
    
    local function touchRepairByGold()
        if totalNum==0 then
            do
                return
            end
        end
   self:removeGuied()
        if playerVoApi:getGold()>=totalGlodCost2 then
        
             local function serverRepair(fn,data)
                --local retTb=OBJDEF:decode(data)
                if base:checkServerData(data)==true then
                    self:refreshTab3()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allDamageFleetRepairSuccess"),28)
                    
                  end
             end
            socketHelper:repairTanks(1,nil,nil,serverRepair)
        else
            smallDialog:showBuyResDialog(5,7)
            -- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("repairNoMoney"),nil,self.layerNum+1)            
        end

    end
    
    local capInSet = CCRect(34, 26, 2, 2);
    local touchRepairSp1=LuaCCScale9Sprite:createWithSpriteFrameName("TeamRepairBtn.png",capInSet,touchRepairByGem)
    touchRepairSp1:setContentSize(CCSizeMake(150,100))
    touchRepairSp1:setPosition(ccp(340,tHeight-10));
    touchRepairSp1:setIsSallow(true)
    touchRepairSp1:setTouchPriority((-(self.layerNum-1)*20-2))

    self.myLayerTab3:addChild(touchRepairSp1)
    
    self.touchRepairSp2=LuaCCScale9Sprite:createWithSpriteFrameName("TeamRepairBtn.png",capInSet,touchRepairByGold)
    self.touchRepairSp2:setContentSize(CCSizeMake(150,100))
    self.touchRepairSp2:setPosition(ccp(520,tHeight-10));
    self.myLayerTab3:addChild(self.touchRepairSp2)
    self.touchRepairSp2:setIsSallow(true)
    self.touchRepairSp2:setTouchPriority((-(self.layerNum-1)*20-2))
    
    local repair1Lb=GetTTFLabel(getlocal("repairItem"),20);
    repair1Lb:setPosition(ccp(self.touchRepairSp2:getContentSize().width/2,self.touchRepairSp2:getContentSize().height/2-20));
    touchRepairSp1:addChild(repair1Lb)
    
    if self.isGuide~=nil then
            local scale1=(self.touchRepairSp2:getContentSize().width+20)/40
     local scale2=(self.touchRepairSp2:getContentSize().height+10)/80

        G_addFlicker(self.touchRepairSp2,scale1,scale1,ccp(self.touchRepairSp2:getContentSize().width/2,self.touchRepairSp2:getContentSize().height/2))
    end

    
    local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
    goldIcon:setPosition(ccp(30,self.touchRepairSp2:getContentSize().height/2+15));
    touchRepairSp1:addChild(goldIcon)
    
    local price1Lb=GetTTFLabel(totalGemCost,20);
    price1Lb:setPosition(ccp(touchRepairSp1:getContentSize().width-30,self.touchRepairSp2:getContentSize().height/2+15));
    price1Lb:setAnchorPoint(ccp(1,0.5));
    touchRepairSp1:addChild(price1Lb)
    if playerVoApi:getGems()<totalGemCost then
        price1Lb:setColor(G_ColorRed)
    end

    local repair2Lb=GetTTFLabel(getlocal("repairItem"),20);
    repair2Lb:setPosition(ccp(self.touchRepairSp2:getContentSize().width/2,self.touchRepairSp2:getContentSize().height/2-20));
    self.touchRepairSp2:addChild(repair2Lb)
    
    local gemIcon=CCSprite:createWithSpriteFrameName("IconCrystal-.png");
    gemIcon:setPosition(ccp(30,self.touchRepairSp2:getContentSize().height/2+15));
    self.touchRepairSp2:addChild(gemIcon)
    
    local price2Lb=GetTTFLabel(totalGlodCost,20);
    --勇往直前活动, 水晶修理费用减少50%
    local vo=activityVoApi:getActivityVo("yongwangzhiqian")
    local ywzq2018Vo = activityVoApi:getActivityVo("ywzq")
    if vo and activityVoApi:isStart(vo) then
        price2Lb:setColor(G_ColorYellowPro)
    elseif ywzq2018Vo and activityVoApi:isStart(ywzq2018Vo) then
        price2Lb:setColor(G_ColorYellowPro)
    end
    if playerVoApi:getGold()<totalGlodCost2 then
        price2Lb:setColor(G_ColorRed)
    end
    price2Lb:setPosition(ccp(self.touchRepairSp2:getContentSize().width-30,self.touchRepairSp2:getContentSize().height/2+15));
    price2Lb:setAnchorPoint(ccp(1,0.5));
    self.touchRepairSp2:addChild(price2Lb)

    self.numLabelTab[#self.numLabelTab+1]={{totalGemCost,price1Lb},{totalGlodCost2,price2Lb}}
    
    if SizeOfTable(tankVoApi:getRepairTanks())==0 then
        local noRepairLb=GetTTFLabel(getlocal("haveNoDamageFleet"),24);
        noRepairLb:setPosition(ccp(self.myLayerTab3:getContentSize().width/2,self.myLayerTab3:getContentSize().height/2-100));
        self.myLayerTab3:addChild(noRepairLb)
        noRepairLb:setColor(G_ColorGray)
    end
    local repairStr
    if self.repairText then
        repairStr = self.repairText
    else
        local skillReduce=skillVoApi:getSkillAddPerById("s303")
        local death=math.max(20*(1 - skillReduce),0)
        local left=math.floor(100 - death,2)
        repairStr = getlocal("fleetRepairText",{left})
    end
    local noRepairLb1=GetTTFLabelWrap(repairStr,22,CCSizeMake(25*20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
        noRepairLb1:setPosition(ccp(self.myLayerTab3:getContentSize().width/2,100));
        self.myLayerTab3:addChild(noRepairLb1)

    if ywzq2018Vo and activityVoApi:isStart(ywzq2018Vo) then
        noRepairLb1:setVisible(false)
    end
end
function tankDialogTab3:removeGuied()
    G_removeFlicker(self.touchRepairSp2)
  self.isGuide=nil;
end
function tankDialogTab3:init(layerNum,isGuide)


    self.isGuide=isGuide
    self.repairTank=tankVoApi:getRepairTanks()
    self.bgLayer=CCLayer:create();
    self.layerNum=layerNum;
    self:initTableView();
    self:initTab3Layer()
    
    return self.bgLayer
end

function tankDialogTab3:initTableView()

    self.cellHeight = 120
    if G_isAsia() == false then
        self.cellHeight = 150
        if G_isIOS() == false then
            self.cellHeight  = 180
        end
    end

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,G_VisibleSize.height-85-260-110),nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30+110))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function tankDialogTab3:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then

           return SizeOfTable(self.repairTank)
           
   elseif fn=="tableCellSizeForIndex" then
   
       local tmpSize
       tmpSize=CCSizeMake(600,self.cellHeight)
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
       backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight))
       backSprie:ignoreAnchorPointForPosition(false);
       backSprie:setAnchorPoint(ccp(0,0));
       backSprie:setTag(1000+idx)
       backSprie:setIsSallow(false)
       backSprie:setTouchPriority((-(self.layerNum-1)*20-2))
       cell:addChild(backSprie,1)
       local m_tankIndex=self.repairTank[idx+1][1]
       
        local spriteIcon = tankVoApi:getTankIconSp(m_tankIndex)--CCSprite:createWithSpriteFrameName(tankCfg[m_tankIndex].icon);
        spriteIcon:setAnchorPoint(ccp(0,0.5));
        spriteIcon:setScale(0.7)
        spriteIcon:setPosition(15,backSprie:getContentSize().height/2)
        cell:addChild(spriteIcon,2)
        
        --local lbName=GetTTFLabel(getlocal(tankCfg[m_tankIndex].name),26)
        local lbName=GetTTFLabelWrap(getlocal(tankCfg[m_tankIndex].name),24,CCSizeMake(154, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
       lbName:setPosition(125,backSprie:getContentSize().height/2+30)
       lbName:setAnchorPoint(ccp(0,0.5));
       cell:addChild(lbName,2)
       
       local lbNum=GetTTFLabel(self.repairTank[idx+1][2],20)
       lbNum:setPosition(125,lbName:getPositionY()-lbName:getContentSize().height/2-lbNum:getContentSize().height/2 - 5)
       lbNum:setAnchorPoint(ccp(0,0.5));
       cell:addChild(lbNum,2)

        --本次修理 修理厂保护的量
        if FuncSwitchApi:isEnabled("diku_repair")==true then
            local proNum = tankVoApi:getProdamagedTankNum(m_tankIndex)
            local protectLb = GetTTFLabelWrap(getlocal("repair_tankProtect", {proNum}), 18, CCSizeMake(154, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            protectLb:setPosition(lbNum:getPositionX(), lbNum:getPositionY() - lbNum:getContentSize().height / 2 - protectLb:getContentSize().height / 2 - 5)
            protectLb:setAnchorPoint(ccp(0, 0.5))
            protectLb:setColor(G_ColorRed)
            cell:addChild(protectLb,2)
        end

       local m_tankIndex=self.repairTank[idx+1][1]
        local numTanks=self.repairTank[idx+1][2]
        local goldCost=tonumber(tankCfg[m_tankIndex].glodCost)*numTanks
        --军团科技高阶维修减少修复消耗
        -- print("before goldCost ===== ",goldCost)
        local repairRate = allianceSkillVoApi:getGoldRepairRate()
        goldCost=math.ceil(goldCost*repairRate)
        --个人技能减少维修消耗
        local skillReduce=skillVoApi:getSkillAddPerById("s302")
        goldCost=math.ceil(goldCost*(1 - skillReduce))
        -- print("after goldCost ===== ",goldCost)
        local goldCostStr=FormatNumber(goldCost)
        local gemCost =math.ceil(tonumber(tankCfg[m_tankIndex].gemCost)*numTanks)
        
        local repairVate
        local vo = activityVoApi:getActivityVo("baifudali")
        if vo and activityVoApi:isStart(vo)==true then
            repairVate = vo.repairVate
        end
        if repairVate then
            goldCost=math.ceil(goldCost*(1-repairVate))
            goldCostStr=FormatNumber(goldCost)
            gemCost = math.ceil(gemCost*(1-repairVate))
        end
        --勇往直前活动, 水晶修理费用减少50%
        local vo=activityVoApi:getActivityVo("yongwangzhiqian")
        local ywzq2018Vo = activityVoApi:getActivityVo("ywzq")
        if vo and activityVoApi:isStart(vo) then
            goldCost=goldCost*vo.activeRes
            goldCostStr=FormatNumber(goldCost)
        elseif ywzq2018Vo and activityVoApi:isStart(ywzq2018Vo) then
            goldCost=goldCost*ywzq2018Vo.activeRes
            goldCostStr=FormatNumber(goldCost)
        end

        if buildDecorateVoApi and buildDecorateVoApi.declineGoldCost and base.isSkin == 1 then
            goldCost = math.ceil(goldCost * (1-buildDecorateVoApi:declineGoldCost()))
            goldCostStr=FormatNumber(goldCost)
        end

       
       local function touchRepairByGem()
            if self.tv:getIsScrolled()==true then
                do
                    return
                end
            end

            if playerVoApi:getGems()>=tonumber(tankCfg[m_tankIndex].gemCost) then
                local repairNum,realCost
                if(playerVoApi:getGems()>=gemCost)then
                    repairNum=numTanks
                    realCost=gemCost
                else
                    repairNum=math.floor(playerVoApi:getGems()/tonumber(tankCfg[m_tankIndex].gemCost))
                    realCost=repairNum*tonumber(tankCfg[m_tankIndex].gemCost)
                end
                local function realRepair()
                    local function serverRepair(fn,data)
                        if base:checkServerData(data)==true then
                            self:refreshTab3()
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("damageFleetRepairSuccess",{getlocal(tankCfg[m_tankIndex].name)}),28)
                        end
                    end
                    socketHelper:repairTanks(2,m_tankIndex,repairNum,serverRepair)
                end
                local key="repairTank_gem_buy"
                if G_isPopBoard(key) then
                    local function secondTipFunc(flag)
                        local sValue=base.serverTime .. "_" .. flag
                        G_changePopFlag(key,sValue)
                    end
                    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{realCost}),true,realRepair,secondTipFunc)
                else
                    realRepair()
                end
            else
                -- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("repairNoMoney"),nil,self.layerNum+1)
                vipVoApi:showRechargeDialog(3)
            end
        end
        
        local function touchRepairByGold()
            if self.tv:getIsScrolled()==true then
                do
                    return
                end
            end
            local singleCost=tonumber(tankCfg[m_tankIndex].glodCost)
            --勇往直前活动, 水晶修理费用减少50%
            local vo=activityVoApi:getActivityVo("yongwangzhiqian")
            local ywzq2018Vo = activityVoApi:getActivityVo("ywzq")
            if vo and activityVoApi:isStart(vo) then
                singleCost=singleCost*vo.activeRes
            elseif ywzq2018Vo and activityVoApi:isStart(ywzq2018Vo) then
                singleCost=singleCost*ywzq2018Vo.activeRes
            end


            if playerVoApi:getGold()>=goldCost then
            
                 local function serverRepair(fn,data)
                    --local retTb=OBJDEF:decode(data)
                    if base:checkServerData(data)==true then
                        self:refreshTab3()
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("damageFleetRepairSuccess",{getlocal(tankCfg[m_tankIndex].name)}),28)
                        
                      end
                 end
                socketHelper:repairTanks(1,m_tankIndex,numTanks,serverRepair)
            elseif playerVoApi:getGold()<singleCost then
                -- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("repairNoMoney"),nil,self.layerNum+1)
                smallDialog:showBuyResDialog(5,7)
            else
                local function serverRepair(fn,data)
                    --local retTb=OBJDEF:decode(data)
                    if base:checkServerData(data)==true then
                        self:refreshTab3()
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("damageFleetRepairSuccess",{getlocal(tankCfg[m_tankIndex].name)}),28)
                        
                      end
                 end
                
                local rnum=math.floor(playerVoApi:getGold()/tonumber(singleCost))
                socketHelper:repairTanks(1,m_tankIndex,rnum,serverRepair)
                
            end
        

        end

        local capInSetRepair = CCRect(34, 26, 2, 2);
        local touchRepairSp1=LuaCCScale9Sprite:createWithSpriteFrameName("TeamRepairBtn.png",capInSetRepair,touchRepairByGem)
        touchRepairSp1:setContentSize(CCSizeMake(130,80))
        touchRepairSp1:setPosition(ccp(365,backSprie:getContentSize().height/2));
        touchRepairSp1:setIsSallow(true)
        touchRepairSp1:setTouchPriority((-(self.layerNum-1)*20-2))

        cell:addChild(touchRepairSp1,2)
        
        local touchRepairSp2=LuaCCScale9Sprite:createWithSpriteFrameName("TeamRepairBtn.png",capInSetRepair,touchRepairByGold)
        touchRepairSp2:setContentSize(CCSizeMake(130,80))
        touchRepairSp2:setPosition(ccp(500,backSprie:getContentSize().height/2));
        cell:addChild(touchRepairSp2,2)
        touchRepairSp2:setIsSallow(true)
        touchRepairSp2:setTouchPriority((-(self.layerNum-1)*20-2))
        
        

        local repair1Lb=GetTTFLabel(getlocal("repairItem"),20);
        repair1Lb:setPosition(ccp(touchRepairSp2:getContentSize().width/2,touchRepairSp2:getContentSize().height/2-18));
        touchRepairSp1:addChild(repair1Lb)
        
        local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
        goldIcon:setPosition(ccp(20,touchRepairSp2:getContentSize().height/2+15));
        touchRepairSp1:addChild(goldIcon)

        local price1Lb=GetTTFLabel(gemCost,20);
        price1Lb:setPosition(ccp(touchRepairSp1:getContentSize().width-20,touchRepairSp2:getContentSize().height/2+15));
        price1Lb:setAnchorPoint(ccp(1,0.5));
        touchRepairSp1:addChild(price1Lb)
        if playerVoApi:getGems()<gemCost then
            price1Lb:setColor(G_ColorRed)
        end
        
        local repair2Lb=GetTTFLabel(getlocal("repairItem"),20);
        repair2Lb:setPosition(ccp(touchRepairSp2:getContentSize().width/2,touchRepairSp2:getContentSize().height/2-18));
        touchRepairSp2:addChild(repair2Lb)
        
        local gemIcon=CCSprite:createWithSpriteFrameName("IconCrystal-.png");
        gemIcon:setPosition(ccp(20,touchRepairSp2:getContentSize().height/2+15));
        touchRepairSp2:addChild(gemIcon)
        
        local price2Lb=GetTTFLabel(goldCostStr,20);
        --勇往直前活动, 水晶修理费用减少50%
        local vo=activityVoApi:getActivityVo("yongwangzhiqian")
        local ywzq2018Vo = activityVoApi:getActivityVo("ywzq")
        if vo and activityVoApi:isStart(vo) then
            price2Lb:setColor(G_ColorYellowPro)
        elseif ywzq2018Vo and activityVoApi:isStart(ywzq2018Vo) then
            price2Lb:setColor(G_ColorYellowPro)
        end
        if playerVoApi:getGold()<goldCost then
            price2Lb:setColor(G_ColorRed)
        end
        price2Lb:setPosition(ccp(touchRepairSp2:getContentSize().width-20,touchRepairSp2:getContentSize().height/2+15));
        price2Lb:setAnchorPoint(ccp(1,0.5));
        touchRepairSp2:addChild(price2Lb)

        self.numLabelTab[#self.numLabelTab+1]={{gemCost,price1Lb},{goldCost,price2Lb}}

       return cell;   
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end


end

function tankDialogTab3:tick()
    
    local repairTankTb=tankVoApi:getRepairTanks()
    local isSame=true;
    for k,v in pairs(repairTankTb) do
        if self.repairTankCopy[k]==nil then
            isSame=false;
            break;
        else
            if self.repairTankCopy[k][1]~=v[1] or self.repairTankCopy[k][2]~=v[2] then
            isSame=false;
            break;
            end
        end
        
    end
    
    if isSame==false then
        self:refreshTab3()
    end

    if self.numLabelTab then
        for k,v in pairs(self.numLabelTab) do
            local num1, lb1 = v[1][1], v[1][2]
            local num2, lb2 = v[2][1], v[2][2]
            if lb1 and tolua.cast(lb1,"CCLabelTTF") and playerVoApi:getGems()>=num1 then
                tolua.cast(lb1,"CCLabelTTF"):setColor(G_ColorWhite)
            end
            if lb2 and tolua.cast(lb2,"CCLabelTTF") and playerVoApi:getGold()>=num2 then
                tolua.cast(lb2,"CCLabelTTF"):setColor(G_ColorWhite)
            end
        end
    end


end

function tankDialogTab3:refreshTab3()
    self.repairTank=tankVoApi:getRepairTanks()
    if self.myLayerTab3~=nil then
        self.myLayerTab3:removeFromParentAndCleanup(true)
        self.myLayerTab3=nil
    end
    self:initTab3Layer()
    self.myLayerTab3:setVisible(true)
    self.myLayerTab3:setPosition(ccp(0,0))
    self.tv:reloadData()

end


--用户处理特殊需求,没有可以不写此方法
function tankDialogTab3:doUserHandler()

end

--点击了cell或cell上某个按钮
function tankDialogTab3:cellClick(idx)
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
function tankDialogTab3:dispose()
    
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil;
    self.myLayerTab3=nil;
    self.repairTank={};
    self.repairTank=nil;
    self.tv=nil;
    self.layerNum=nil;
    self.numLabelTab=nil;
    
end
