acNewYearsEveSubTab21={

}

function acNewYearsEveSubTab21:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil
    self.bgLayer=nil
    
    self.layerNum=nil
    self.lowFightLabel = nil
    self.curTab=1
    self.parent=nil
    self.noRankLb=nil
    
    return nc;

end

function acNewYearsEveSubTab21:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    local function click(hd,fn,idx)
    end
    -- local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight - 320))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(25,110))
    self.bgLayer:addChild(tvBg)

    self.noRankLb = GetTTFLabelWrap(getlocal("activity_fightRanknew_no_rank"),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRankLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRankLb:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2)
    self.bgLayer:addChild(self.noRankLb,1)
    self.noRankLb:setColor(G_ColorGray)
    self:tick()

    self:initTitleAndBtn()

    self:initTableView()
    
    return self.bgLayer
end


function acNewYearsEveSubTab21:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-370),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,120))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acNewYearsEveSubTab21:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local rankList=acNewYearsEveVoApi:getRankList(self.curTab)
        return SizeOfTable(rankList)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(G_VisibleSizeWidth-50,76)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local rankList=acNewYearsEveVoApi:getRankList(self.curTab)
        print("单次伤害排行")
        G_dayin(rankList)
        rankData=rankList[idx+1]
        if rankData then
            local id=rankData[1]
            local name=rankData[2] or ""
            local value=rankData[3] or 0

            local height=40
            local w = (G_VisibleSizeWidth-60) / 3
            local function getX(index)
                return -5 + w * index+ w/2
            end

            local rankSp
            if idx+1==1 then
                rankSp=CCSprite:createWithSpriteFrameName("top1.png")
            elseif idx+1==2 then
                rankSp=CCSprite:createWithSpriteFrameName("top2.png")
            elseif idx+1==3 then
                rankSp=CCSprite:createWithSpriteFrameName("top3.png")
            end
            if rankSp then
                rankSp:setAnchorPoint(ccp(0.5,0.5))
                rankSp:setPosition(ccp(getX(0),height))
                cell:addChild(rankSp,3)
            else
                local rankLabel=GetTTFLabel(idx+1,25)
                rankLabel:setAnchorPoint(ccp(0.5,0.5))
                rankLabel:setPosition(getX(0),height)
                cell:addChild(rankLabel,2)
            end
          
            local playerNameLabel=GetTTFLabelWrap(name,25,CCSizeMake(175,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            playerNameLabel:setAnchorPoint(ccp(0.5,0.5))
            playerNameLabel:setPosition(getX(1),height)
            cell:addChild(playerNameLabel,2)
            
            local valueLabel=GetTTFLabel(FormatNumber(value),25)
            valueLabel:setAnchorPoint(ccp(0.5,0.5))
            valueLabel:setPosition(getX(2),height)
            cell:addChild(valueLabel,2)

            -- local nameLabel=GetTTFLabelWrap(name,25,CCSizeMake(125,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            -- nameLabel:setAnchorPoint(ccp(0.5,0.5))
            -- nameLabel:setPosition(getX(3),height)
            -- cell:addChild(nameLabel,2)  

            local lineSP=CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSP:setAnchorPoint(ccp(0.5,0.5))
            lineSP:setScaleX((G_VisibleSizeWidth-60)/lineSP:getContentSize().width)
            lineSP:setScaleY(1.2)
            lineSP:setPosition(ccp((G_VisibleSizeWidth-60)/2,2))
            cell:addChild(lineSP,2)
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

function acNewYearsEveSubTab21:tick()
    if self.noRankLb then
        local rankList=acNewYearsEveVoApi:getRankList(self.curTab)
        if rankList and SizeOfTable(rankList)>0 then
            self.noRankLb:setVisible(false)
        else
            self.noRankLb:setVisible(true)
        end
    end
end

--用户处理特殊需求,没有可以不写此方法
function acNewYearsEveSubTab21:initTitleAndBtn()
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(60, 20, 1, 1)
    local function touch(hd,fn,idx)

    end

    local heightQ=230
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",capInSet,touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-70, 38))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,0.5))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-heightQ))
    self.bgLayer:addChild(backSprie)

    local w = (G_VisibleSizeWidth - 60) / 3
    local function getX(index)
        return 20 + w * index+ w/2
    end

    local height=G_VisibleSizeHeight-230
    local lbSize=22
    local widthSpace=80
    local color=G_ColorGreen
    local rankLabel=GetTTFLabel(getlocal("alliance_scene_rank_title"),lbSize)
    rankLabel:setPosition(getX(0),height)
    self.bgLayer:addChild(rankLabel,1)
    rankLabel:setColor(color)
  
    local playerNameLabel=GetTTFLabel(getlocal("playerName"),lbSize)
    playerNameLabel:setPosition(getX(1),height)
    self.bgLayer:addChild(playerNameLabel,1)
    playerNameLabel:setColor(color)
    
    local valueLabel=GetTTFLabel(getlocal("BossBattle_damagePoint"),lbSize)
    valueLabel:setPosition(getX(2),height)
    self.bgLayer:addChild(valueLabel,1)
    valueLabel:setColor(color)


    -- local nameLabel=GetTTFLabel(getlocal("alliance_scene_alliance_name_title"),lbSize)
    -- nameLabel:setPosition(getX(3),height)
    -- self.bgLayer:addChild(nameLabel,1)
    -- nameLabel:setColor(color)


    local function rewardHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        local function callback()
            if self.rewardBtn then
                self.rewardBtn:setEnabled(false)
                tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
            end
            if self.parent then
                if self.parent.refreshIconTipVisible then
                    self.parent:refreshIconTipVisible(1)
                    if self.parent.parent then
                        if self.parent.parent.refreshIconTipVisible then
                            self.parent.parent:refreshIconTipVisible()
                        end
                    end
                end
            end
        end
        acNewYearsEveVoApi:activeNewyeareva("rankreward",self.curTab,callback)
    end
    local rewardBtnImage1,rewardBtnImage2,rewardBtnImage3="BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png"
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        rewardBtnImage1,rewardBtnImage2,rewardBtnImage3="creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png"
    end
    self.rewardBtn=GetButtonItem(rewardBtnImage1,rewardBtnImage2,rewardBtnImage3,rewardHandler,nil,getlocal("newGiftsReward"),25,11)
    local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    rewardMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,67))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4) 
    self.bgLayer:addChild(rewardMenu,1)

    local canReward,status=acNewYearsEveVoApi:canRankReward(self.curTab)
    if canReward==true then
    else
        self.rewardBtn:setEnabled(false)
        if status==2 then
            tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
        end
    end
end

function acNewYearsEveSubTab21:refresh()
    if self.rewardBtn then
        local canReward,status=acNewYearsEveVoApi:canRankReward(self.curTab)
        if canReward==true then
            self.rewardBtn:setEnabled(true)
            tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("newGiftsReward"))
        else
            self.rewardBtn:setEnabled(false)
            if status==2 then
                tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
            end
        end
    end
end

function acNewYearsEveSubTab21:updateUI()
    if self then
        self:refresh()
        if self.tv then
            self.tv:reloadData()
        end
    end
end

function acNewYearsEveSubTab21:dispose()
    self.noRankLb=nil
    self.curTab=1
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.lowFightLabel = nil
    self.tv=nil;
    self.layerNum=nil
    self.parent = nil
    self = nil
end
