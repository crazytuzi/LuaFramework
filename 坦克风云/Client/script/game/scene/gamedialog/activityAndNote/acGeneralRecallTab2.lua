acGeneralRecallTab2 ={}
function acGeneralRecallTab2:new(layerNum)
        local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=layerNum
    self.tv=nil
    self.cellArea =nil
    self.taskList={}
    self.rewardList={}
    self.taskTb=nil
    self.numTb=nil
    self.sicon=nil
    self.scoreLb=nil
    self.taskIndexTb=nil
    self.exchangeBtn=nil
    return nc;

end
function acGeneralRecallTab2:dispose( )
    self.bgLayer=nil
    self.layerNum=nil
    self.tv=nil
    self.cellArea=nil
    self.taskList=nil
    self.cellNum=0
    self.sicon=nil
    self.scoreLb=nil
    self.taskIndexTb=nil
    self.exchangeBtn=nil
end

function acGeneralRecallTab2:init(layerNum)
    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()
    self:initTaskLayer()

    return self.bgLayer
end

function acGeneralRecallTab2:initTaskLayer()
    self.taskIndexTb=acGeneralRecallVoApi:getTaskIndexTb() or {}
    self.taskList=acGeneralRecallVoApi:getDailyTaskCfg()----配置给
    if self.taskList then
        self.cellNum=SizeOfTable(self.taskList)
        for k,v in pairs(self.taskList) do
            local reward=FormatItem(v.reward)
            self.rewardList[k]=reward
        end
    end
    self.taskTb,self.numTb=acGeneralRecallVoApi:getDailyTaskData()
  
    local count=math.floor((G_VisibleSizeHeight-160)/80)
    for i=1,count do
        local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        bgSp:setAnchorPoint(ccp(0.5,1))
        bgSp:setScaleX((G_VisibleSizeWidth-50)/bgSp:getContentSize().width)
        bgSp:setScaleY(80/bgSp:getContentSize().height)
        bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)-(i-1)*bgSp:getContentSize().height)
        self.bgLayer:addChild(bgSp)
        if G_isIphone5()==false and i==count then
            bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+20))
        end
    end

    local strSize2 = 20
    local strSize3 = 30
    local strSize4 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
        strSize3 =28
        strSize4 = 25
    end
    
    local function noData(hd,fn,index) end
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),noData)
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-44, G_VisibleSizeHeight-185))
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setOpacity(0)
    backSprie:setPosition(ccp(G_VisibleSizeWidth*0.5,25))
    self.bgLayer:addChild(backSprie,100)
    local fullWidth=backSprie:getContentSize().width
    local fullHeight=backSprie:getContentSize().height

    local scoreBg=LuaCCScale9Sprite:createWithSpriteFrameName("acRadar_integralBg.png",CCRect(75,35,50,30),noData)
    scoreBg:setAnchorPoint(ccp(0.5,0.5))
    scoreBg:setScaleX(2)
    scoreBg:setPosition(ccp(fullWidth*0.5,fullHeight-35))
    backSprie:addChild(scoreBg)

    local sicon=CCSprite:createWithSpriteFrameName("acChunjiepansheng_tanskPoint.png")
    sicon:setAnchorPoint(ccp(0,0.5))
    sicon:setScale(0.5)
    backSprie:addChild(sicon,1)
    self.sicon=sicon
    local score=acGeneralRecallVoApi:getCurScore()
    local scoreLb=GetTTFLabel(tostring(score),strSize2)
    scoreLb:setAnchorPoint(ccp(0,0.5))
    backSprie:addChild(scoreLb,1)
    self.scoreLb=scoreLb
    sicon:setPosition((fullWidth-sicon:getContentSize().width*sicon:getScale()-scoreLb:getContentSize().width)/2,scoreBg:getPositionY()+5)
    scoreLb:setPosition(ccp(sicon:getPositionX()+sicon:getContentSize().width*sicon:getScale(),sicon:getPositionY()))

    local upPosY=fullHeight-G_VisibleSizeHeight*0.07
    local taskBg=LuaCCScale9Sprite:createWithSpriteFrameName("wsjdzz_di3.png",CCRect(48,48,2,2),noData) 
    taskBg:setContentSize(CCSizeMake(fullWidth,180))
    taskBg:setAnchorPoint(ccp(0.5,1))
    taskBg:setPosition(ccp(fullWidth*0.5,upPosY))
    backSprie:addChild(taskBg)
    ---需要 检测！！！！！！！！~~~~~~~~
    local exAward,exNeed,exLimit=acGeneralRecallVoApi:getExchangeCfg()
    local icon,scale=G_getItemIcon(exAward,120,true,self.layerNum+1)
    icon:ignoreAnchorPointForPosition(false)
    icon:setAnchorPoint(ccp(0,0.5))
    icon:setIsSallow(false)
    icon:setTouchPriority(-(self.layerNum-1)*20-4)
    icon:setPosition(20,taskBg:getContentSize().height/2)
    taskBg:addChild(icon,1)
    local flickScale=1.3
    G_addRectFlicker(icon,flickScale,flickScale)
    local needPosY2=icon:getPositionX()+icon:getContentSize().width*scale+2
    local nameLb=GetTTFLabelWrap(exAward.name,strSize3,CCSizeMake(taskBg:getContentSize().width*0.5,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    nameLb:setAnchorPoint(ccp(0,0.5))
    nameLb:setPosition(ccp(needPosY2,taskBg:getContentSize().height*0.75))
    nameLb:setColor(G_ColorYellowPro)
    taskBg:addChild(nameLb)

    local needLb=GetTTFLabel(getlocal("curScoreNums",{exNeed}),strSize4)---配置给~~~~~~
    needLb:setAnchorPoint(ccp(0,0.5))
    needLb:setPosition(ccp(needPosY2,taskBg:getContentSize().height*0.25))
    taskBg:addChild(needLb)
    local curEx=acGeneralRecallVoApi:getCurExchange()
    local limitLb=GetTTFLabel(getlocal("limitBuy",{curEx,exLimit}),25)---配置给~~~~~~
    limitLb:setAnchorPoint(ccp(1,0.5))
    limitLb:setPosition(ccp(taskBg:getContentSize().width-30,taskBg:getContentSize().height/2+30))
    taskBg:addChild(limitLb)
    self.limitLb=limitLb

    local function exchangeHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        local function callBack()
            self:refreshExchangeLayer()
            self:refreshScoreLb()
        end
        acGeneralRecallVoApi:socketGeneralRecall("active.djrecall.shop",nil,callBack,{exAward})
        
    end
    local exchangeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",exchangeHandler,111,getlocal("code_gift"),25)
    exchangeItem:setAnchorPoint(ccp(0.5,0.5))
    exchangeItem:setScale(0.8)
    local exchageMenu=CCMenu:createWithItem(exchangeItem)
    exchageMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    exchageMenu:setPosition(ccp(taskBg:getContentSize().width-80,taskBg:getContentSize().height/2-30))
    taskBg:addChild(exchageMenu)
    self.exchangeBtn=exchangeItem
    if (tonumber(exNeed)>tonumber(score)) or (tonumber(curEx)>=tonumber(exLimit)) then
        exchangeItem:setEnabled(false)
    end
    self.cellArea=CCSizeMake(taskBg:getContentSize().width,175)
    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellArea.width,taskBg:getPositionY()-taskBg:getContentSize().height-10),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(20,30))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acGeneralRecallTab2:eventHandler(handler,fn,idx,cel)
    local strSize2 = 21
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize2 =25
    end
    if fn=="numberOfCellsInTableView" then--要配置
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        return  self.cellArea 
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local indexCfg=self.taskIndexTb[idx+1]
        if indexCfg==nil then
            do return end
        end
        local taskId=indexCfg.taskId
        local taskCfg=self.taskList[taskId]
        local rewardCfg=self.rewardList[taskId]
        local descKey=acGeneralRecallVoApi:getTaskDescKey(taskId)
        if taskCfg==nil or rewardCfg==nil or descKey==nil then
            do return end
        end
        local cur=self.taskTb[taskId] or 0
        local num=self.numTb[taskId] or 0
        --self.taskList 
        local function noData(hd,fn,index) end
        local cellBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("wsjdzz_di3.png",CCRect(48,48,2,2),noData) 
        cellBgSp:ignoreAnchorPointForPosition(false)
        cellBgSp:setContentSize(self.cellArea)
        cellBgSp:setPosition(self.cellArea.width/2,self.cellArea.height/2)
        cell:addChild(cellBgSp)

        local tIdx=0
        local iconSize=100
        for k,item in pairs(rewardCfg) do
            local icon,scale=G_getItemIcon(item,iconSize,true,self.layerNum+1)
            if icon and scale then
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setIsSallow(false)
                icon:setTouchPriority(-(self.layerNum-1)*20-3)
                icon:setPosition(20+tIdx*(iconSize+10),self.cellArea.height/2-10)
                cellBgSp:addChild(icon,1)

                local numLb=GetTTFLabel(FormatNumber(item.num),25)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setScale(1/scale)
                numLb:setPosition(ccp(icon:getContentSize().width-5,0))
                icon:addChild(numLb,4)
                local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                numBg:setAnchorPoint(ccp(1,0))
                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
                numBg:setPosition(ccp(icon:getContentSize().width-5,5))
                numBg:setOpacity(150)
                icon:addChild(numBg,3)
            end
            tIdx=tIdx+1
        end
        
        local dailyTaskNeed,vipNeed    
        if type(taskCfg.needNum)=="table" then
            dailyTaskNeed=taskCfg.needNum[1]
            vipNeed=taskCfg.needNum[2]
        else
            dailyTaskNeed=taskCfg.needNum
        end
        ---缺当前的数据信息 需要前台取后台信息 然后自己计算
        local ptype=acGeneralRecallVoApi:getPlayerType()
        local desStr=""
        if ptype==2 and taskCfg.type==2 then
            desStr=getlocal(descKey,{cur,dailyTaskNeed,vipNeed,vipNeed})
        else
            desStr=getlocal(descKey,{cur,dailyTaskNeed,vipNeed})
        end
        local taskLb=GetTTFLabelWrap(desStr,strSize2,CCSizeMake(cellBgSp:getContentSize().width*0.8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        taskLb:setAnchorPoint(ccp(0,1))
        taskLb:setPosition(ccp(25,cellBgSp:getContentSize().height-10))
        taskLb:setColor(G_ColorYellowPro)
        cellBgSp:addChild(taskLb)

        local limitStr=GetTTFLabel(getlocal("limitBuy",{num,taskCfg.limit}),25)---配置给~~~~~~
        limitStr:setAnchorPoint(ccp(1,0.5))
        limitStr:setPosition(ccp(cellBgSp:getContentSize().width-30,self.cellArea.height/2+30))
        cellBgSp:addChild(limitStr)

        local handlerStr=""
        local btnPic="BtnOkSmall.png"
        local downPic="BtnOkSmall_Down.png"
        local ptype=acGeneralRecallVoApi:getPlayerType() --玩家类型（流失玩家还是活跃玩家）
        local isFinished,isAllGet=acGeneralRecallVoApi:getTaskState(taskId)
        -- print("taskId,ptype,isFinished,isAllGet",taskId,ptype,isFinished,isAllGet)
        if isFinished==false and ptype==1 then
            if taskId=="t1" then
                handlerStr=getlocal("recharge")
                btnPic="BtnCancleSmall.png"
                downPic="BtnCancleSmall_Down.png"
            else
                handlerStr=getlocal("activity_heartOfIron_goto")
                btnPic="BtnCancleSmall.png"
                downPic="BtnCancleSmall_Down.png"
            end
        elseif isAllGet==true then
            handlerStr=getlocal("activity_wanshengjiedazuozhan_complete")
        else
            handlerStr=getlocal("daily_scene_get")
        end
        local function handler(tag,object) --前往或者购买奖励的处理
            if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                -- print("taskId======",taskId)
                if ptype==1 and isFinished==false then --跳转各任务功能页面
                    acGeneralRecallVoApi:goToTaskDialog(taskId,self.layerNum+1)
                elseif isFinished==true and isAllGet==false then --领取任务奖励
                    local function rewardHandler()
                        self:refresh()
                    end
                    local cmd
                    if ptype==1 then --流失玩家领取奖励
                        cmd="active.djrecall.taskReward1"
                    elseif ptype==2 then --活跃玩家领取奖励
                        cmd="active.djrecall.taskReward2"
                    end
                    if cmd then
                        local rewardlist=rewardCfg
                        -- print("taskCfg.getdonate",taskCfg.getdonate)
                        acGeneralRecallVoApi:socketGeneralRecall(cmd,{tid=taskId},rewardHandler,rewardlist)
                    end
                end
            end
        end
        local handlerBtn=GetButtonItem(btnPic,downPic,downPic,handler,11+idx,handlerStr,25)
        handlerBtn:setAnchorPoint(ccp(0.5,0.5))
        handlerBtn:setScale(0.8)
        local handlerMenu=CCMenu:createWithItem(handlerBtn)
        handlerMenu:setTouchPriority(-(self.layerNum-1)*20-3)
        handlerMenu:setPosition(ccp(self.cellArea.width-80,self.cellArea.height/2-30))
        cellBgSp:addChild(handlerMenu)
        if (isFinished==false and ptype==2) or (isAllGet==true) then
            handlerBtn:setEnabled(false)
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

function acGeneralRecallTab2:refresh()
    self:refreshScoreLb()
    if self.tv then
        self.taskIndexTb=acGeneralRecallVoApi:getTaskIndexTb()
        self.taskTb,self.numTb=acGeneralRecallVoApi:getDailyTaskData()
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
    self:refreshExchangeLayer()
end

function acGeneralRecallTab2:refreshScoreLb()
    local score=acGeneralRecallVoApi:getCurScore()
    if self.scoreLb and self.sicon then
        self.scoreLb:setString(tostring(score))
        self.sicon:setPosition((G_VisibleSizeWidth-44-self.sicon:getContentSize().width*self.sicon:getScale()-self.scoreLb:getContentSize().width)/2,self.sicon:getPositionY())
        self.scoreLb:setPosition(ccp(self.sicon:getPositionX()+self.sicon:getContentSize().width*self.sicon:getScale(),self.sicon:getPositionY()))
    end
end
function acGeneralRecallTab2:refreshExchangeLayer()
    self:refreshScoreLb()
    if self.limitLb and self.exchangeBtn then
        local exAward,exNeed,exLimit=acGeneralRecallVoApi:getExchangeCfg()
        local score=acGeneralRecallVoApi:getCurScore()
        local curEx=acGeneralRecallVoApi:getCurExchange()
        local limitStr=getlocal("limitBuy",{acGeneralRecallVoApi:getCurExchange(),exLimit})
        self.limitLb:setString(limitStr)
        if (tonumber(exNeed)>tonumber(score)) or (tonumber(curEx)>=tonumber(exLimit)) then
            self.exchangeBtn:setEnabled(false)
        else
            self.exchangeBtn:setEnabled(true)
        end
    end
end
function acGeneralRecallTab2:updateUI()
    self:refresh()
end