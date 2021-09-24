localWarDetailDialogTab2={}

function localWarDetailDialogTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bgLayer=nil
    self.layerNum=nil
    self.height = 130

    return nc
end

function localWarDetailDialogTab2:init(layerNum,parent,addH)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    if addH then
        self.addH=addH
    else
        self.addH=0
    end
    self:initLayer()
    self:initTableView()
    return self.bgLayer
end

function localWarDetailDialogTab2:initLayer()
    local scale=1.15
    local startH=G_VisibleSizeHeight-210+self.addH
    local titleBg1=CCSprite:createWithSpriteFrameName("awTitleBg.png")
    titleBg1:setPosition(ccp(G_VisibleSizeWidth/2,startH))
    titleBg1:setScale(scale)
    titleBg1:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:addChild(titleBg1,1)

    local fontSize=25
    local titleLb1=GetTTFLabelWrap(getlocal("allianceWar2_reward1_title",{getlocal("local_war_name_title")}),fontSize,CCSizeMake(340,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb1:setAnchorPoint(ccp(0.5,0.5))
    titleLb1:setPosition(ccp(titleBg1:getContentSize().width/2,titleBg1:getContentSize().height/2+5))
    titleLb1:setScale(1/scale)
    titleBg1:addChild(titleLb1)

    local function helpInfo(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
            PlayEffect(audioCfg.mouseClick)
            local tabStr={};
            local tabColor ={};
            local td=smallDialog:new()
            tabStr = {"\n",getlocal("local_war_reward_tip"),"\n"}
            local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,nil,nil,nil})
            sceneGame:addChild(dialog,self.layerNum+1)
        end
       
    end
    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",helpInfo,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
    menuDesc:setPosition(ccp(G_VisibleSizeWidth-30,startH+6))
    self.bgLayer:addChild(menuDesc,2)

    local fadeH=160
    local fadeW=640
    local fadePosH=startH-titleBg1:getContentSize().height/2-fadeH/2
    local fadeBg=CCSprite:createWithSpriteFrameName("redFadeLine.png")
    fadeBg:setPosition(ccp(G_VisibleSizeWidth/2,fadePosH+20))
    fadeBg:setScaleY(fadeH/fadeBg:getContentSize().height)
    fadeBg:setScaleX(fadeW/fadeBg:getContentSize().width)
    fadeBg:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:addChild(fadeBg)

    local iconh=fadePosH+10
    local reward=localWarCfg.winreward.reward
    local rewardItem=FormatItem(reward,nil,true)
    for k,v in pairs(rewardItem) do

        local function touchPropInfo()
            local flag=false
            if v.num==0 then
                flag=true
            end
            propInfoDialog:create(sceneGame,v,self.layerNum+1,nil,nil,nil,nil,nil,nil,flag)
        end
        local iconSp,scale=G_getItemIcon(v,100,nil,self.layerNum+1,touchPropInfo)
        iconSp:setTouchPriority(-(self.layerNum-1)*20-3)
        iconSp:setPosition(20+15+75+(k-1)*140,iconh)
        self.bgLayer:addChild(iconSp)

        if v.num~=0 then
            local numLabel=GetTTFLabel("x"..v.num,22)
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(iconSp:getContentSize().width-5, 5)
            numLabel:setScale(1/scale)
            iconSp:addChild(numLabel,1)
        end
    end

    
    local titleLb2=GetTTFLabelWrap(getlocal("allianceWar2_reward2_title",{getlocal("local_war_name_title")}),fontSize,CCSizeMake(340,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)

    local lbSize=titleLb2:getContentSize().height+20
    local orangeH=fadePosH-fadeH/2-lbSize/2+20

    titleLb2:setAnchorPoint(ccp(0.5,0.5))
    titleLb2:setPosition(ccp(G_VisibleSizeWidth/2,orangeH))
    self.bgLayer:addChild(titleLb2,2)

    local orangeMask = CCSprite:createWithSpriteFrameName("orangeMask.png")
    orangeMask:setScaleY(lbSize/orangeMask:getContentSize().height)
    orangeMask:setPosition(G_VisibleSizeWidth/2,orangeH)
    self.bgLayer:addChild(orangeMask,1)

    self.tvBgh=orangeH-lbSize/2

    local function nilFunc()
    end
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
    descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.tvBgh-40))
    descBg:setAnchorPoint(ccp(0.5,0))
    descBg:setPosition(ccp(G_VisibleSizeWidth/2,35))
    self.bgLayer:addChild(descBg)

    local rewardDes=getlocal("local_war_reward_notion",{getlocal("email_email")})
    if base.rewardcenter==1 then
        rewardDes=getlocal("local_war_reward_notion",{getlocal("rewardCenterTitle")})
    end
    local rewardLb=GetTTFLabelWrap(rewardDes,25,CCSizeMake(descBg:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    rewardLb:setAnchorPoint(ccp(0,0))
    rewardLb:setPosition(ccp(15,15))
    descBg:addChild(rewardLb)
    rewardLb:setColor(G_ColorRed)
    self.rewardLb=rewardLb

end

function localWarDetailDialogTab2:initTableView()
    local function callback( ... )
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.tvBgh-50-self.rewardLb:getContentSize().height-25),nil)
    self.tv:setPosition(ccp(30,60+self.rewardLb:getContentSize().height))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)

end


function localWarDetailDialogTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(localWarCfg.task)
    elseif fn=="tableCellSizeForIndex" then
        return  CCSizeMake(G_VisibleSizeWidth - 60,self.height)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setAnchorPoint(ccp(0.5,0))
        lineSp:setPosition(ccp((G_VisibleSizeWidth - 60)/2,0))
        cell:addChild(lineSp)

        -- if idx==0 then
        --     local reward={p={{p974=1}}}
        --     local rewardItem=FormatItem(reward)

        --     local function touchPropInfo()
        --         propInfoDialog:create(sceneGame,rewardItem[1],self.layerNum+1,nil,nil,nil,nil,nil,nil,true)
        --     end
        --     local iconSp,scale=G_getItemIcon(rewardItem[1],100,nil,self.layerNum+1,touchPropInfo,self.tv)
        --     iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
        --     iconSp:setAnchorPoint(ccp(0,0.5))
        --     iconSp:setPosition(20,self.height/2)
        --     cell:addChild(iconSp)

        --     local desLb=GetTTFLabelWrap(getlocal("allianceWar2_donate_des"),25,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        --     desLb:setAnchorPoint(ccp(0,0.5))
        --     desLb:setPosition(ccp(140,self.height/2))
        --     cell:addChild(desLb)
        --     return cell
        -- end
        local tid="t" .. (idx+1)
        local reward=localWarCfg.taskreward[tid][1]
        local rewardItem=FormatItem(reward)

        local iconSp,scale=G_getItemIcon(rewardItem[1],100,true,self.layerNum+1,nil,self.tv)
        iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
        iconSp:setAnchorPoint(ccp(0,0.5))
        iconSp:setPosition(20,self.height/2)
        cell:addChild(iconSp)

        local numLabel=GetTTFLabel("x"..rewardItem[1].num,22)
        numLabel:setAnchorPoint(ccp(1,0))
        numLabel:setPosition(iconSp:getContentSize().width-5, 5)
        numLabel:setScale(1/scale)
        iconSp:addChild(numLabel,1)


        

        local desLb=""
        -- if idx==0 then
        --  desLb=getlocal("allianceWar2_" .. localWarCfg.task[2])
        -- else
            desLb=getlocal("allianceWar2_" .. localWarCfg.task[tid][2],{localWarCfg.task[tid][1]})
        -- end
        -- print("++++++++localWarCfg.task[tid][1]",localWarCfg.task[tid][1])
        local desLb=GetTTFLabelWrap(desLb,25,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        desLb:setPosition(ccp(140,self.height/4*3))
        cell:addChild(desLb)

        local haveNum=0
        -- if self.flag then
            -- local haveTask=allianceWar2VoApi:getBattlefieldUser()["task"] or {}
            local haveTask=localWarVoApi:getTask() or {}
            if haveTask and haveTask[tid] then
                haveNum=haveTask[tid] or 0
            end
        -- end
        
        local pressStr=""
        local color=G_ColorWhite

        -- if idx==0 then
        --     pressStr=getlocal("allianceWar2_haveGot",{haveNum})
        -- else

            local flag=false
            if tid=="t7" or tid=="t8" or tid=="t9" then
                if haveNum and haveNum>0 and haveNum<=localWarCfg.task[tid][1] then
                    flag=true
                end
            elseif haveNum and haveNum>=localWarCfg.task[tid][1] then
                flag=true
            end
            
            if tid=="t7" or tid=="t8" or tid=="t9" then
                local status=localWarVoApi:checkStatus()
                if status>=30 and flag then
                    pressStr=getlocal("activity_wanshengjiedazuozhan_complete")
                    color=G_ColorGreen
                else
                    pressStr=getlocal("local_war_incomplete")
                end
            else
                if flag then
                    pressStr=getlocal("activity_wanshengjiedazuozhan_complete")
                    color=G_ColorGreen
                else
                    pressStr=getlocal("allianceWar2_nowComplection",{haveNum})
                end
            end
        -- end
        
        local progressLb=GetTTFLabelWrap(pressStr,25,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        progressLb:setAnchorPoint(ccp(0,0.5))
        progressLb:setPosition(ccp(140,self.height/4))
        progressLb:setColor(color)
        cell:addChild(progressLb)
        
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end


function localWarDetailDialogTab2:refresh()
    if self.tv then
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function localWarDetailDialogTab2:tick()
end

function localWarDetailDialogTab2:dispose()
end