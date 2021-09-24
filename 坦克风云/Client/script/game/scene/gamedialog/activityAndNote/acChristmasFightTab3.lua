acChristmasFightTab3={}

function acChristmasFightTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.normalHeight=80
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.descLb=nil
    self.descLb1=nil
    self.rewardBtn=nil
    self.type=2
    return nc
end

function acChristmasFightTab3:init(layerNum,selectedTabIndex,parentDialog)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.selectedTabIndex=selectedTabIndex
    self.parentDialog=parentDialog

    self:initTableView()
    self:doUserHandler()

    return self.bgLayer
end

--设置对话框里的tableView
function acChristmasFightTab3:initTableView()
    local height=self.bgLayer:getContentSize().height-285-35
    local widthSpace=120

    local rankLabel=GetTTFLabel(getlocal("RankScene_rank"),22)
    rankLabel:setPosition(widthSpace-10,height)
    self.bgLayer:addChild(rankLabel,2)
    rankLabel:setColor(G_ColorGreen)
    
    local nameLabel=GetTTFLabel(getlocal("RankScene_name"),22)
    nameLabel:setPosition(self.bgLayer:getContentSize().width/2-30,height)
    self.bgLayer:addChild(nameLabel,2)
    nameLabel:setColor(G_ColorGreen)
    
    -- local levelLabel=GetTTFLabel(getlocal("RankScene_level"),22)
    -- levelLabel:setPosition(widthSpace+120*2+20,height)
    -- self.bgLayer:addChild(levelLabel,2)
    -- levelLabel:setColor(G_ColorGreen)

    -- local powerLabel=GetTTFLabel(getlocal("RankScene_power"),22)
    -- powerLabel:setPosition(widthSpace+120*3+10,height)
    -- self.bgLayer:addChild(powerLabel,2)
    -- powerLabel:setColor(G_ColorGreen)

    local pointLabel=GetTTFLabel(getlocal("activity_christmasfight_active"),22)
    pointLabel:setPosition(self.bgLayer:getContentSize().width-widthSpace-40,height)
    self.bgLayer:addChild(pointLabel,2)
    pointLabel:setColor(G_ColorGreen)

    self.tvHeight=self.bgLayer:getContentSize().height-340-20

    local capInSet = CCRect(20, 20, 10, 10);
    local function bgClick(hd,fn,idx)
    end
    local backBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    backBg:setContentSize(CCSizeMake(G_VisibleSize.width-60, self.tvHeight+10-20))
    backBg:setAnchorPoint(ccp(0,0))
    backBg:setPosition(ccp(30,30))
    self.bgLayer:addChild(backBg)


    local function rewardHandler()
        local status=acChristmasFightVoApi:getRRewardStatus(self.type)
        if status==1 then
            local function rankRewardCallback(sData)
                if sData.ret==-1975 then
                    local function rankCallback(sData1)
                        self:tick()
                        self:refresh()
                    end
                    acChristmasFightVoApi:updateActiveData("rank",self.type,rankCallback)
                else
                    if sData and sData.data and sData.data.reward then
                        local award=FormatItem(sData.data.reward) or {}
                        G_showRewardTip(award, true)
                    end
                    self:refresh()
                end
            end
            acChristmasFightVoApi:updateActiveData("rankreward",self.type,rankRewardCallback)
        end
    end
    local btnStr=getlocal("newGiftsReward")
    local status1=acChristmasFightVoApi:getRRewardStatus(self.type)
    if status1==2 then
        btnStr=getlocal("activity_hadReward")
    end
    if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
        self.rewardBtn = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rewardHandler,nil,btnStr,25,11)
    else
        self.rewardBtn = GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",rewardHandler,nil,btnStr,25,11)
    end
    self.rewardBtn:setAnchorPoint(ccp(0.5,0))
    local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    rewardMenu:setPosition(ccp(backBg:getContentSize().width/2,15))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    backBg:addChild(rewardMenu,2)
    if status1==1 then
        self.rewardBtn:setEnabled(true)
    else
        self.rewardBtn:setEnabled(false)
    end

    -- if acChristmasFightVoApi:rankCanReward()>0 then
    --     self.rewardBtn:setEnabled(true)
    -- end
    -- local isReceive=acChristmasFightVoApi:isReceive()
    -- if isReceive==1 then
    --     tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
    --     self.rewardBtn:setEnabled(false)
    -- else
    --      tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("newGiftsReward"))
    -- end
 

    local function callBack(...)
      return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.tvHeight-90-20),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,40+90))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acChristmasFightTab3:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local num=1
        local rankList=acChristmasFightVoApi:getRanklist(self.type)
        if rankList and SizeOfTable(rankList)>0 then
            num=num+SizeOfTable(rankList)
        end
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-70,self.normalHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local acVo=acChristmasFightVoApi:getAcVo()
        local rankList=acChristmasFightVoApi:getRanklist(self.type)
        local rData

        local rank
        local name=""
        -- local level
        -- local power
        local point=0

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        end

        local cellWidth=self.bgLayer:getContentSize().width-70

        if idx==0 then
            rank=acChristmasFightVoApi:getRank(self.type)
            name=playerVoApi:getPlayerName()
            -- level=playerVoApi:getPlayerLevel()
            -- power=playerVoApi:getPlayerPower()
            point=acVo.aPoint

            local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
            -- bgSp:setAnchorPoint(ccp(0,0.5))
            bgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.normalHeight/2-5));
            bgSp:setScaleY(self.normalHeight/bgSp:getContentSize().height)
            bgSp:setScaleX(1000/bgSp:getContentSize().width)
            cell:addChild(bgSp)
        else
            rData=rankList[idx] or {}
            rank=idx
            if rData and rData[2] then
                name=rData[2] or ""
                -- level=rData[2] or 0
                -- power=rData[3] or 0
                point=rData[3] or 0
            end
        end

        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
        lineSp:setAnchorPoint(ccp(0,1));
        lineSp:setPosition(ccp(0,self.normalHeight));
        cell:addChild(lineSp,1)

        local lbSize=25
        local lbHeight=35
        local lbWidth=80

        if rank==nil or rank==0 then
            rank="10+"
        end
        local rankLb=GetTTFLabel(rank,lbSize)
        rankLb:setPosition(ccp(lbWidth,lbHeight))
        cell:addChild(rankLb)
        rankLb:setColor(G_ColorYellow)

        local rankSp
        if tonumber(rank)==1 then
            rankSp=CCSprite:createWithSpriteFrameName("top1.png")
        elseif tonumber(rank)==2 then
            rankSp=CCSprite:createWithSpriteFrameName("top2.png")
        elseif tonumber(rank)==3 then
            rankSp=CCSprite:createWithSpriteFrameName("top3.png")
        end
        if rankSp then
            rankSp:setPosition(ccp(lbWidth,lbHeight))
            cell:addChild(rankSp,2)
            rankLb:setVisible(false)
        end

        local nameLb=GetTTFLabel(name,lbSize)
        nameLb:setPosition(ccp(cellWidth/2-20,lbHeight))
        cell:addChild(nameLb)

        -- local levelLb=GetTTFLabel(level,lbSize)
        -- levelLb:setPosition(ccp(lbWidth+120*2+20,lbHeight))
        -- cell:addChild(levelLb)

        -- local powerLb=GetTTFLabel(power,lbSize)
        -- powerLb:setPosition(ccp(lbWidth+120*3+10,lbHeight))
        -- cell:addChild(powerLb)

        local pointLb=GetTTFLabel(point,lbSize)
        pointLb:setPosition(ccp(cellWidth-lbWidth-40,lbHeight))
        cell:addChild(pointLb)
        pointLb:setColor(G_ColorYellow)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acChristmasFightTab3:doUserHandler()
    local acVo=acChristmasFightVoApi:getAcVo()
    local capInSet = CCRect(20, 20, 10, 10);
    local function bgClick(hd,fn,idx)
    end
    -- local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
    titleBg:setContentSize(CCSizeMake(G_VisibleSize.width-60, 130))
    titleBg:setAnchorPoint(ccp(0,0));
    titleBg:setPosition(ccp(30,G_VisibleSize.height-85-80-130))
    self.bgLayer:addChild(titleBg,1)

    if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
    else
        local snowSp1=CCSprite:createWithSpriteFrameName("snowBg_1.png")
        snowSp1:setAnchorPoint(ccp(0,1))
        snowSp1:setPosition(ccp(0,titleBg:getContentSize().height+10))
        titleBg:addChild(snowSp1)
        -- snowSp1:setScale(0.5)

        local snowSp2=CCSprite:createWithSpriteFrameName("snowBg_2.png")
        snowSp2:setAnchorPoint(ccp(1,1))
        snowSp2:setPosition(ccp(titleBg:getContentSize().width+10,titleBg:getContentSize().height+10))
        titleBg:addChild(snowSp2)
        -- snowSp2:setFlipX(true)
        -- snowSp2:setScale(snowScale)
    end

    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    self.descLb=GetTTFLabelWrap(getlocal("activity_christmasfight_arank_desc",{acVo.aRankLimit}),25,CCSizeMake(titleBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- self.descLb=GetTTFLabelWrap(str,25,CCSizeMake(titleBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.descLb:setAnchorPoint(ccp(0,0.5));
    self.descLb:setPosition(ccp(15,titleBg:getContentSize().height/2+10));
    titleBg:addChild(self.descLb,2);
    self.descLb:setColor(G_ColorGreen)

    -- self.descLb1=GetTTFLabelWrap(getlocal("allianceShop_myDonate")..acVo.aPoint,25,CCSizeMake(titleBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- self.descLb1=GetTTFLabelWrap(str,25,CCSizeMake(titleBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.descLb1=GetTTFLabel(getlocal("activity_christmasfight_my_active")..acVo.aPoint,25)
    self.descLb1:setAnchorPoint(ccp(0,0.5));
    self.descLb1:setPosition(ccp(15,titleBg:getContentSize().height/2-30));
    titleBg:addChild(self.descLb1,2);
    self.descLb1:setColor(G_ColorYellow)

    local function onClickDesc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local acVo=acChristmasFightVoApi:getAcVo()
        local tabStr={" "}
        local param={FormatNumber(acVo.addRes),1,FormatNumber(acVo.addBp),1}
        for i=1,4 do
            table.insert(tabStr,getlocal("activity_christmasfight_arank_tip"..i,param))
        end
        local tabColor={}
        local acVo=acChristmasFightVoApi:getAcVo()
        local rankRewardCfg=acVo.aRankRewardCfg
        local rewardStrTab={}
        for k,v in pairs(rankRewardCfg) do
            local str=""
            local range=v.range
            if range[1]~=range[2] then
                str=getlocal("rankTwo",{range[1],range[2]})..":"
            else
                str=getlocal("rankOne",{range[1],range[2]})..":"
            end
            local award=FormatItem(v.reward,nil,true)
            str=str..G_showRewardTip(award,false,true)
            table.insert(tabStr,str)
        end
        table.insert(tabStr," ")

        local tab={}
        local tbNum=SizeOfTable(tabStr)
        for i=tbNum,1,-1 do
            table.insert(tab,tabStr[i])
        end

        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tab,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local descBtnItem
    if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
        descBtnItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",onClickDesc)
    else
        descBtnItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",onClickDesc)
    end
    descBtnItem:setAnchorPoint(ccp(0,0.5))
    local descBtn=CCMenu:createWithItem(descBtnItem)
    descBtn:setAnchorPoint(ccp(0,0.5))
    descBtn:setPosition(ccp(titleBg:getContentSize().width-descBtnItem:getContentSize().width-10,titleBg:getContentSize().height-50))
    descBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    titleBg:addChild(descBtn,2)

    if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
    else
        local dscSp=CCSprite:createWithSpriteFrameName("bellPic.png")
        dscSp:setPosition(ccp(titleBg:getContentSize().width-20,0))
        titleBg:addChild(dscSp,5)
    end
end

function acChristmasFightTab3:refresh()
    if self then
        if self.rewardBtn then
            self.rewardBtn:setEnabled(false)
            local status=acChristmasFightVoApi:getRRewardStatus(self.type)
            if status==2 then
                tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
            else
                tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("newGiftsReward"))
                if status==1 then
                    self.rewardBtn:setEnabled(true)
                end
            end
        end
        if self.tv then
            local recordPoint = self.tv:getRecordPoint()
            self.tv:reloadData()
            self.tv:recoverToRecordPoint(recordPoint)
        end
    end
end

function acChristmasFightTab3:tick()
    if self and self.descLb1 then
        local acVo=acChristmasFightVoApi:getAcVo()
        if acVo then
            self.descLb1:setString(getlocal("activity_christmasfight_my_active")..acVo.aPoint)
        end
    end
end

function acChristmasFightTab3:dispose()
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil

    self.descLb=nil
    self.descLb1=nil
    self.rewardBtn=nil
    self.type=2
    self=nil
end





