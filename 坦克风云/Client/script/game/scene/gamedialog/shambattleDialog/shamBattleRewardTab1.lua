shamBattleRewardTab1 = {}

function shamBattleRewardTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.normalHeight=140
	return nc
end

function shamBattleRewardTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initLayer()
    self:initTableView()

	return self.bgLayer
end

function shamBattleRewardTab1:initLayer()
	local backSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),function () do return end end)
    backSprie1:setContentSize(CCSizeMake(595,170))
    backSprie1:setAnchorPoint(ccp(0.5,1))
    backSprie1:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-165)
    self.bgLayer:addChild(backSprie1)

    local desStr = getlocal("shanBattle_scoreDes") .. "\n" .. getlocal("shanBattle_refreshScore")
    local desTv, desLabel = G_LabelTableView(CCSizeMake(550, 90),desStr,25,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(20,70))
    desTv:setAnchorPoint(ccp(0,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(80)
    backSprie1:addChild(desTv)

    local successStr = getlocal("shanBattle_successScore",{getlocal("serverwar_point") .. "+" .. arenaCfg.winPoint})
    local successLb = GetTTFLabelWrap(successStr,25,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    backSprie1:addChild(successLb)
    successLb:setAnchorPoint(ccp(0,0))
    successLb:setPosition(20, 30)
    successLb:setColor(G_ColorYellowPro)

    local failureStr = getlocal("shanBattle_failureScore",{getlocal("serverwar_point") .. "+" .. arenaCfg.losePoint})
    local failureLb = GetTTFLabelWrap(failureStr,25,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    backSprie1:addChild(failureLb)
    failureLb:setAnchorPoint(ccp(0,0))
    failureLb:setPosition(320, 30)
    failureLb:setColor(G_ColorYellowPro)

    self.MyScore = arenaVoApi:getArenaVo().score or 0
    local myStr = getlocal("serverwar_my_point") .. arenaVoApi:getArenaVo().score or 0
    local myScoreLb = GetTTFLabelWrap(myStr,25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.bgLayer:addChild(myScoreLb)
    myScoreLb:setAnchorPoint(ccp(0.5,0.5))
    myScoreLb:setPosition((self.bgLayer:getContentSize().width)/2, self.bgLayer:getContentSize().height-100-200-100+30)
    myScoreLb:setColor(G_ColorGreen)
    self.myScoreLb=myScoreLb

   
end

function shamBattleRewardTab1:initTableView()
    self.pointReward = arenaVoApi:getPointRewardCfg() or {}
    self.numCell = SizeOfTable(self.pointReward)
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-100-200-100-40),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,40))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)

    self.recordPoint = self.tv:getRecordPoint()
    self:recorderToReward()

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function shamBattleRewardTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local num=1
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,self.normalHeight*self.numCell)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        

        for j=1,self.numCell do
            local function touch()
            end
            local capInSet = CCRect(20, 20, 10, 10)
            local backsprite =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
            backsprite:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-140,self.normalHeight-5))
            backsprite:setAnchorPoint(ccp(0,0))
            backsprite:setPosition(ccp(85,5+(self.numCell-j)*self.normalHeight))
            cell:addChild(backsprite,1)

            

            -- local tb = {r={r4=1000,r3=1000,r2=1000,r1=1000}}
            local tb = self.pointReward[j].reward
            local item = FormatItem(tb)

            if self.MyScore>=self.pointReward[j].point and self:isLingqujiangli(j)==false then
                local sp = CCSprite:createWithSpriteFrameName("7daysLight.png")
                backsprite:addChild(sp)
                sp:setScaleX(backsprite:getContentSize().width/sp:getContentSize().width)
                sp:setPosition(backsprite:getContentSize().width/2, backsprite:getContentSize().height/2)
            end

            for k,v in pairs(item) do
                local iconSp = G_getItemIcon(v,80,true,self.layerNum+1)
                iconSp:setAnchorPoint(ccp(0,0.5))
                iconSp:setPosition(10+(k-1)*90, backsprite:getContentSize().height/2)
                -- iconSp:setScale(80/iconSp:getContentSize().width)
                iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
                backsprite:addChild(iconSp)

                local numLb = GetTTFLabel(v.num,25)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
                iconSp:addChild(numLb)
            end

            if self.MyScore>=self.pointReward[j].point and self:isLingqujiangli(j)==false then
                local function touchReward()
                    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end

                        local function getScoreReward(fn,data)
                            local ret,sData=base:checkServerData(data)
                            if ret==true then
                                local drTb =  arenaVoApi:getDr()
                                table.insert(drTb,j)
                                arenaVoApi:setDr(drTb)

                                local nameStr=getlocal("you_get_title")
                                for k,v in pairs(item) do
                                    G_addPlayerAward(v.type,v.key,v.id,v.num)
                                    if k==SizeOfTable(item) then
                                        nameStr=nameStr .. v.name .. "*" .. v.num
                                    else
                                        nameStr=nameStr .. v.name .. "*" .. v.num .. ","
                                    end
                                end

                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nameStr,30,nil,nil,item)
                                
                                self:recorderToReward()
                            end
                        end

                        socketHelper:shamBattleGetScoreReward(j,getScoreReward)
                    end
                end
                local rewardItem=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",touchReward,nil,nil,0)
                rewardItem:setAnchorPoint(ccp(1,0.5))
                local rewardMenu=CCMenu:createWithItem(rewardItem)
                rewardMenu:setAnchorPoint(ccp(0,0))
                rewardMenu:setPosition(ccp(backsprite:getContentSize().width-5,backsprite:getContentSize().height/2))
                rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
                backsprite:addChild(rewardMenu,1)
            elseif self.MyScore>=self.pointReward[j].point and self:isLingqujiangli(j)==true then
                local alreadyLb=GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                backsprite:addChild(alreadyLb)
                alreadyLb:setPosition(ccp(backsprite:getContentSize().width-75,backsprite:getContentSize().height/2))
                alreadyLb:setColor(G_ColorYellowPro)

            else
                local noZigeLb=GetTTFLabelWrap(getlocal("noReached"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                backsprite:addChild(noZigeLb)
                noZigeLb:setPosition(ccp(backsprite:getContentSize().width-75,backsprite:getContentSize().height/2))
                -- noZigeLb:setColor(G_ColorGray)
            end

            -- 
            local scale = 0.4
            local numBg =CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
            numBg:setAnchorPoint(ccp(0.5,0.5))
            numBg:setPosition(ccp(35,backsprite:getPositionY()+self.normalHeight/2))
            cell:addChild(numBg,4)
            numBg:setScaleX(scale)

            local numPoint = self.pointReward[j].point
            local numLb = GetTTFLabel(numPoint,25)
            numBg:addChild(numLb)
            numLb:setColor(G_ColorYellowPro)
            numLb:setPosition(numBg:getContentSize().width/2, numBg:getContentSize().height/2)
            numLb:setScaleX(1/scale)
        end



        -- 进度条
        local barWidth=self.normalHeight*self.numCell

        local function click(hd,fn,idx)
        end
        local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("HelpBgBottom.png", CCRect(20,20,1,1),click)
        barSprie:setContentSize(CCSizeMake(barWidth, 50))
        barSprie:setRotation(90)
        barSprie:setPosition(ccp(35,barWidth/2))
        cell:addChild(barSprie,1)

        AddProgramTimer(cell,ccp(35,barWidth/2),11,12,nil,"VipIconYellowBarBg.png","AllXpBar.png",13,1,1)
        local per = arenaVoApi:getPercentage()
        local timerSpriteLv = cell:getChildByTag(11)
        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
        timerSpriteLv:setPercentage(per)
        timerSpriteLv:setRotation(90)
        timerSpriteLv:setScaleX((barWidth+20)/timerSpriteLv:getContentSize().width)
        timerSpriteLv:setScaleY(1.3)

        local bg = cell:getChildByTag(13)
        bg:setScaleX(barWidth/timerSpriteLv:getContentSize().width)
        bg:setRotation(90)
        bg:setVisible(false)

        
       

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function shamBattleRewardTab1:isLingqujiangli(idx)
    local drTb = arenaVoApi:getDr()
    local flag=false
    for k,v in pairs(drTb) do
        if v==idx then
            flag=true
            break
        end
    end
    return flag
end

function shamBattleRewardTab1:recorderToReward()
    local num = self:getRecordNum()
    local recordPoint = self.tv:getRecordPoint()
    recordPoint.y=self.recordPoint.y+num*self.normalHeight

    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
end

function shamBattleRewardTab1:getRecordNum()
    local drTb = arenaVoApi:getDr()
    local num=0

    for i=1,self.numCell do
        if self.MyScore>=self.pointReward[i].point then
            local flag=0
            for k,v in pairs(drTb) do
                if i==v then
                    flag=1
                end
            end
            if flag==0 then
                return i-1
            end
        else
            break
        end
    end

    return num
end



function shamBattleRewardTab1:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.tv=nil
    self.MyScore=nil
end

