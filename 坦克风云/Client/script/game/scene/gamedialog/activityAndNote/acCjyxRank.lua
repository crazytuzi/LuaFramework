acCjyxRank={}

function acCjyxRank:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil
    self.bgLayer=nil
    
    self.layerNum=nil
    self.lowFightLabel=nil
    self.parent=nil
    self.noRankLb=nil
    self.rankList=nil
    self.cellNum=0
    self.isEnd=false
    self.pointLb=nil
    self.myRankLb=nil
    
    return nc
end

function acCjyxRank:init(layerNum,parent)
    local strSize2 = 22
    local subHeight = 308
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
        subHeight = 320
    end
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self.rankList=acCjyxVoApi:getRankList() or {}
    self.cellNum=SizeOfTable(self.rankList)
    self.isEnd=acCjyxVoApi:acIsStop()

    self:tick()
    self:initTitleAndBtn()
    self:initTableView()

    local function click(hd,fn,idx)
    end
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-465))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(25,110))
    self.bgLayer:addChild(tvBg)

    self.noRankLb=GetTTFLabelWrap(getlocal("activity_fightRanknew_no_rank"),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRankLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRankLb:setPosition(tvBg:getContentSize().width/2,tvBg:getContentSize().height/2)
    tvBg:addChild(self.noRankLb,1)
    self.noRankLb:setColor(G_ColorGray)

    local pointStr=getlocal("cjyx_point_str").."："..acCjyxVoApi:getMyPoint()
    local pointLb=GetTTFLabelWrap(pointStr,strSize2,CCSize(G_VisibleSizeWidth*0.4,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    pointLb:setAnchorPoint(ccp(0,0))
    pointLb:setPosition(40,70)
    self.bgLayer:addChild(pointLb)
    self.pointLb=pointLb
    local adaptWidth = 50
    if G_getCurChoseLanguage() == "ar" then
        adaptWidth = 150
    end
    local promptLb=GetTTFLabelWrap(getlocal("cjyx_rankin",{getlocal("cjyx_point_str"),acCjyxVoApi:getRankLimit()}),strSize2,CCSize(G_VisibleSizeWidth-adaptWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    promptLb:setAnchorPoint(ccp(0,1))
    promptLb:setPosition(30,G_VisibleSizeHeight-subHeight)
    promptLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(promptLb)

    self:refreshMyRank()
    
    return self.bgLayer
end

function acCjyxRank:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-520),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,120))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acCjyxRank:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(G_VisibleSizeWidth-50,76)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellWidth=G_VisibleSizeWidth-50
        local cellHeight=76
        local rank
        local name
        local value
        local rankData=self.rankList[idx+1]
        if rankData then
            rank=idx+1
            name=rankData[2] or ""
            value=rankData[3] or 0
        end
        
        if rank and name and value then
            local height=40
            local w=(G_VisibleSizeWidth-60)/3
            local function getX(index)
                return -5+w*index+w/2
            end
            local capInSet = CCRect(40, 40, 10, 10);
            local capInSetNew=CCRect(20, 20, 10, 10)
            local widthSpace=50
            local backSprie
            local function cellClick1(hd,fn,idx)
            end
            if idx+1==1 then
                backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",capInSetNew,cellClick1)
            elseif idx+1==2 then
                backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png",capInSetNew,cellClick1)
            elseif idx+1==3 then
                backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png",capInSetNew,cellClick1)
            else
                backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick1)
            end
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-58,76))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setPosition(ccp(cellWidth/2,cellHeight/2))
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-42)
            cell:addChild(backSprie,1)

            local height=backSprie:getContentSize().height/2
            local rankSp
            if tonumber(rank)==1 then
                rankSp=CCSprite:createWithSpriteFrameName("top1.png")
            elseif tonumber(rank)==2 then
                rankSp=CCSprite:createWithSpriteFrameName("top2.png")
            elseif tonumber(rank)==3 then
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

function acCjyxRank:tick()
    local isEnd=acCjyxVoApi:acIsStop()
    if isEnd~=self.isEnd and isEnd==true then
        self.isEnd=isEnd
        local canReward=acCjyxVoApi:canRankReward()
        if canReward==true then
            if self.rewardBtn then
                self.rewardBtn:setEnabled(true)
            end
        end
    end
end

--用户处理特殊需求,没有可以不写此方法
function acCjyxRank:initTitleAndBtn()
    local rect=CCRect(0, 0, 50, 50)
    local capInSet=CCRect(60, 20, 1, 1)
    local function touch(hd,fn,idx)

    end

    local height=380
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",capInSet,touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-70,38))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,0.5))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-height))
    self.bgLayer:addChild(backSprie,1)

    local w=(G_VisibleSizeWidth-60)/3
    local function getX(index)
        return 20+w*index+w/2-35
    end

    local height=G_VisibleSizeHeight-230
    local lbSize=22
    local widthSpace=80
    local color=G_ColorGreen
    local rankLabel=GetTTFLabel(getlocal("alliance_scene_rank_title"),lbSize)
    rankLabel:setPosition(getX(0),backSprie:getContentSize().height/2)
    backSprie:addChild(rankLabel,1)
    rankLabel:setColor(color)
  
    local playerNameLabel=GetTTFLabel(getlocal("playerName"),lbSize)
    playerNameLabel:setPosition(getX(1),backSprie:getContentSize().height/2)
    backSprie:addChild(playerNameLabel,1)
    playerNameLabel:setColor(color)
    
    local valueLabel=GetTTFLabel(getlocal("cjyx_point_str"),lbSize)
    valueLabel:setPosition(getX(2),backSprie:getContentSize().height/2)
    backSprie:addChild(valueLabel,1)
    valueLabel:setColor(color)

    local rewardLb=GetTTFLabel(getlocal("award"),lbSize)
    rewardLb:setPosition(getX(3),backSprie:getContentSize().height/2)
    backSprie:addChild(rewardLb,1)
    rewardLb:setColor(color)

    local function rewardHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local canReward,status,rank=acCjyxVoApi:canRankReward()
        if canReward==true and status~=2 then
            local function callback(resultFlag,rewardlist)
                if resultFlag==true then
                    if self.rewardBtn then
                        self.rewardBtn:setEnabled(false)
                        tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
                    end
                    --前三名领取奖励发送系统公告
                    if rank<=3 then
                        acCjyxVoApi:sendCjyxNotice({ntype=2,rank=rank})
                    end
                    require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"                      
                    local titleStr=getlocal("cjyx_rank_reward",{getlocal("cjyx_point_str")})
                    local detailStr=getlocal("activity_cuikulaxiu_myRank")..rank
                    local content={}
                    for k,v in pairs(rewardlist) do
                        table.insert(content,{award=v})              
                    end
                    acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,detailStr,nil,content,false,self.layerNum+1,nil,getlocal("confirm"),nil,nil,nil,nil,true,false)
                end
            end
            acCjyxVoApi:cjyxAcRequest("active.cjyx.rankreward",{rank=rank},callback)
        end
    end
    local rewardBtnImage1,rewardBtnImage2,rewardBtnImage3="BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png"
    if acCjyxVoApi:getAcShowType()==acCjyxVoApi.acShowType.TYPE_2 then
        rewardBtnImage1,rewardBtnImage2,rewardBtnImage3="creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png"
    end
    self.rewardBtn=GetButtonItem(rewardBtnImage1,rewardBtnImage2,rewardBtnImage3,rewardHandler,nil,getlocal("newGiftsReward"),25,11)
    local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    rewardMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2+140,67))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4) 
    self.bgLayer:addChild(rewardMenu,1)

    local canReward,status=acCjyxVoApi:canRankReward()
    if canReward==true then
    else
        self.rewardBtn:setEnabled(false)
        if status==2 then
            tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
        end
    end
end

function acCjyxRank:refresh()
    if self.rewardBtn then
        local canReward,status=acCjyxVoApi:canRankReward()
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

function acCjyxRank:refreshMyRank()
    local strSize2 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
    end
    if self.myRankLb then
        self.myRankLb:removeFromParentAndCleanup(true)
        self.myRankLb=nil
    end
    if self.pointLb then
        local colorTab={G_ColorYellowPro,G_ColorRed}
        local myPoint=acCjyxVoApi:getMyPoint()
        local rankLimit=acCjyxVoApi:getRankLimit()        
        if tonumber(myPoint)>=tonumber(rankLimit) then
            colorTab={G_ColorYellowPro,G_ColorYellowPro}
        end
        local myRankStr=getlocal("shanBattle_myRank",{"<rayimg>"..acCjyxVoApi:getSelfRank().."<rayimg>"})
        local myRankLb,lbHeight=G_getRichTextLabel(myRankStr,colorTab,strSize2,G_VisibleSizeWidth*0.45,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0)
        myRankLb:setAnchorPoint(ccp(0,1))
        myRankLb:setPosition(40,self.pointLb:getPositionY()-10)
        self.bgLayer:addChild(myRankLb)
        self.myRankLb=myRankLb
        if G_isShowRichLabel()==false then
            myRankLb:setColor(G_ColorYellowPro)
        end
    end
end

function acCjyxRank:updateUI()
    if self then
        self:refresh()
        if self.tv then
            self.rankList=acCjyxVoApi:getRankList() or {}
            self.cellNum=SizeOfTable(self.rankList)
            self.tv:reloadData()
        end
        if self.noRankLb then
            local rankList=acCjyxVoApi:getRankList() or {}
            if rankList and SizeOfTable(rankList)>0 then
                self.noRankLb:setVisible(false)
            else
                self.noRankLb:setVisible(true)
            end
        end
        if self.pointLb and self.myRankLb then
            local pointStr=getlocal("cjyx_point_str").."："..acCjyxVoApi:getMyPoint()
            self.pointLb:setString(pointStr)
            self:refreshMyRank()
        end
    end
end

function acCjyxRank:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.tv=nil
    self.layerNum=nil
    self.lowFightLabel=nil
    self.parent=nil
    self.noRankLb=nil
    self.rankList=nil
    self.cellNum=0
    self.pointLb=nil
    self.myRankLb=nil
    self=nil
end
