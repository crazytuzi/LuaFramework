acRewardingBackDialog=commonDialog:new()

function acRewardingBackDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.cellHeight=nil
    self.cellHeightTab={}
    
    return nc
end

function acRewardingBackDialog:initTableView()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-95))
    
    self:initCellHeight()
    local function click(hd,fn,idx)
    end
    local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight - 200))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(15, 110))
    self.bgLayer:addChild(tvBg)

    local function eventCallback(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(eventCallback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-220),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(15,110))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)


    local function rechargeHandler(tag,object)
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      PlayEffect(audioCfg.mouseClick)
      vipVoApi:showRechargeDialog(self.layerNum+2)
      self:close()
    end
    local rechargeBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rechargeHandler,0,getlocal("recharge"),28)
    rechargeBtn:setAnchorPoint(ccp(0.5, 0)) 
    local rechargeMenu=CCMenu:createWithItem(rechargeBtn)
    rechargeMenu:setPosition(ccp(G_VisibleSizeWidth/2-130,20))
    rechargeMenu:setTouchPriority(-(self.layerNum-1)*20-4) 

    self.bgLayer:addChild(rechargeMenu,1) 


    local function rewardHandler(tag,object)
        if G_checkClickEnable()==false then
              do
                  return
              end
        end
      PlayEffect(audioCfg.mouseClick)
      local function socketCallBack(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_RewardingBack_rewardTip",{math.ceil(acRewardingBackVoApi:getRechargeGolds()*acRewardingBackVoApi:getGemsRate()),acRewardingBackVoApi:getRechargeGolds()*acRewardingBackVoApi:getGoldsRate()}),28)
            local awardTab = {u={gems=math.ceil(acRewardingBackVoApi:getRechargeGolds()*acRewardingBackVoApi:getGemsRate()),gold=acRewardingBackVoApi:getRechargeGolds()*acRewardingBackVoApi:getGoldsRate()}}
            local award=FormatItem(awardTab) or {}
            for k,v in pairs(award) do
                G_addPlayerAward(v.type,v.key,v.id,v.num)
            end
           -- G_showRewardTip(award, true)
            acRewardingBackVoApi:afterGotReward()
            self:updateRewardBtn()
        end
      end
      
      socketHelper:activeRewardingBack(socketCallBack)
    end   
    self.rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,0,getlocal("daily_scene_get"),25)
    self.rewardBtn:setAnchorPoint(ccp(0.5,0))
    local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    rewardMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2 + 130,20))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(rewardMenu)
    self:updateRewardBtn()

end

function acRewardingBackDialog:initCellHeight()
    self.cellHeightTab={}
    local titleLb = GetTTFLabelWrap("",27,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local acVo = acRewardingBackVoApi:getAcVo()
        local cheight1
        local cheight2
        local cheight3
        local cheight4
        titleLb:setString(getlocal("activity_timeLabel"))
        local timeStr
        local timeLabel=GetTTFLabel("",25)
        if acVo ~= nil then
            timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
            timeLabel:setString(timeStr)
        end
        self.cellHeightTab[1]=titleLb:getContentSize().height+timeLabel:getContentSize().height+50

        titleLb:setString(getlocal("activity_contentLabel"))
        local contentLb = GetTTFLabelWrap(getlocal("activity_RewardingBack_content",{acRewardingBackVoApi:getGemsRate()*100,acRewardingBackVoApi:getGoldsRate()}),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        self.cellHeightTab[2]=titleLb:getContentSize().height+contentLb:getContentSize().height+60

        titleLb:setString(getlocal("activity_awardLabel"))
        local award = acRewardingBackVoApi:getRewardCfg()
        local iconHeight = 0
        if award~=nil then
            local awardNum=SizeOfTable(award)
            iconHeight = (math.floor(awardNum/2))*120
        end
        self.cellHeightTab[3] = titleLb:getContentSize().height+iconHeight+60

        titleLb:setString(getlocal("activityDescription"))
        local descLb1 = GetTTFLabelWrap(getlocal("activity_RewardingBack_desc1"),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local descLb2 = GetTTFLabelWrap(getlocal("activity_RewardingBack_desc2"),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local descLb3 = GetTTFLabelWrap(getlocal("activity_RewardingBack_desc3"),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local exampleLb = GetTTFLabel(getlocal("activity_RewardingBack_example"),25)
        local  tmpStoreCfg=G_getPlatStoreCfg()
        local  mPrice=tmpStoreCfg["gold"][3]
        local addGems = math.ceil(mPrice*acRewardingBackVoApi:getGemsRate())
        local addGolds=mPrice*acRewardingBackVoApi:getGoldsRate()
        local exampleDescLb = GetTTFLabelWrap(getlocal("activity_RewardingBack_exampleDesc",{mPrice,addGems,addGolds}),25,CCSizeMake(self.bgLayer:getContentSize().width-80-exampleLb:getContentSize().width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        self.cellHeightTab[4]=titleLb:getContentSize().height+descLb1:getContentSize().height+descLb2:getContentSize().height+descLb3:getContentSize().height+exampleDescLb:getContentSize().height+65
end
function acRewardingBackDialog:updateRewardBtn()
    if self.rewardBtn~=nil then 
        if acRewardingBackVoApi:canReward()==false then
            self.rewardBtn:setEnabled(false)
        else
            self.rewardBtn:setEnabled(true)
        end
    end
    
end

function acRewardingBackDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 4
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local cheight=self.cellHeightTab[idx+1]
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,cheight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        self.cellHeight = self.cellHeightTab[idx+1]
        local titleLb = GetTTFLabelWrap("",30,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        titleLb:setAnchorPoint(ccp(0,1))
        titleLb:setPosition(ccp(10,self.cellHeight-10))
        cell:addChild(titleLb)

        local acVo = acRewardingBackVoApi:getAcVo()
        titleLb:setColor(G_ColorGreen)
        local posX = 30
        if idx==0 then
            titleLb:setString(getlocal("activity_timeLabel"))
            if acVo ~= nil then
                local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
                local timeLabel=GetTTFLabel(timeStr,25)
                timeLabel:setAnchorPoint(ccp(0,1))
                timeLabel:setPosition(ccp(posX, self.cellHeight-10-titleLb:getContentSize().height-10))
                cell:addChild(timeLabel)
            end 
        elseif idx==1 then
            titleLb:setString(getlocal("activity_contentLabel"))
            local contentLb = GetTTFLabelWrap(getlocal("activity_RewardingBack_content",{acRewardingBackVoApi:getGemsRate()*100,acRewardingBackVoApi:getGoldsRate()}),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            contentLb:setAnchorPoint(ccp(0,1))
            contentLb:setPosition(ccp(posX,self.cellHeight-10-titleLb:getContentSize().height-10))
            cell:addChild(contentLb)
        elseif idx==2 then
            titleLb:setString(getlocal("activity_awardLabel"))
            local award = acRewardingBackVoApi:getRewardCfg()
            if award~=nil then
                local awardNum=SizeOfTable(award)
                for k,v in pairs(award) do
                    if v~=nil then
                        local awidth = posX+((k-1)%2)*290
                        local aheight = self.cellHeight-titleLb:getContentSize().height-40-math.floor((k-1)/2)*120
                        local iconSize=100
                        local icon
                       --[[ if v.type and v.type=="e" then
                            if v.eType then
                                if v.eType=="a" then
                                    icon = accessoryVoApi:getAccessoryIcon(v.key,nil,iconSize)
                                elseif v.eType=="f" then
                                    icon = accessoryVoApi:getFragmentIcon(v.key,nil,iconSize)
                                elseif v.pic and v.pic~="" then
                                    icon = CCSprite:createWithSpriteFrameName(v.pic)
                                end
                            end--]]
                        if v.pic and v.pic~="" then
                            icon = CCSprite:createWithSpriteFrameName(v.pic)
                        elseif v.gems~=nil then
                            icon =CCSprite:createWithSpriteFrameName("Icon_BG.png")
                            icon:setScale(100/78)

                             local mIcon2=CCSprite:createWithSpriteFrameName("iconGold3.png")
                             mIcon2:setScale(78/100)
                             mIcon2:setPosition(ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))
                             icon:addChild(mIcon2,2)
                        elseif v.gold~=nil then 
                            icon = CCSprite:createWithSpriteFrameName("resourse_normal_gold.png")
                        end
                        if icon then
                            icon:setAnchorPoint(ccp(0,1))
                            icon:setPosition(ccp(awidth,aheight))
                            cell:addChild(icon,1)
                            local scale=iconSize/icon:getContentSize().width
                            icon:setScale(scale)
                        end
                        local nameLable 
                        local nameStr
                        if v.gems~=nil or v.gold~=nil then
                            nameStr="activity_RewardingBack_rechargeGold"
                        end
                        nameLable= GetTTFLabelWrap(getlocal(nameStr),25,CCSize(175,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                        nameLable:setAnchorPoint(ccp(0,0.5))
                        nameLable:setPosition(ccp(awidth+iconSize+5,aheight-10))
                        cell:addChild(nameLable,1)
                        local numStr
                        if v.gems~=nil then
                            local gemStr = acRewardingBackVoApi:getGemsRate()*100
                            numStr=gemStr.."%"
                        elseif v.gold~=nil then
                             local glodsStr = acRewardingBackVoApi:getGoldsRate()
                            numStr="*"..glodsStr
                        end
                        local numLable = GetTTFLabel(numStr,50)
                        numLable:setAnchorPoint(ccp(0,0))
                        numLable:setPosition(ccp(awidth+iconSize+5,aheight-iconSize-5))
                        cell:addChild(numLable,1)
                        numLable:setColor(G_ColorYellow)
                    end
                end
            end

        elseif idx==3 then
            titleLb:setString(getlocal("activityDescription"))
            local descLb1 = GetTTFLabelWrap(getlocal("activity_RewardingBack_desc1"),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb1:setAnchorPoint(ccp(0,1))
            descLb1:setPosition(ccp(posX,self.cellHeight-10-titleLb:getContentSize().height-10))
            cell:addChild(descLb1)

            local descLb2 = GetTTFLabelWrap(getlocal("activity_RewardingBack_desc2"),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb2:setAnchorPoint(ccp(0,1))
            descLb2:setPosition(ccp(posX,self.cellHeight-10-titleLb:getContentSize().height-descLb1:getContentSize().height-15))
            cell:addChild(descLb2)

            local descLb3 = GetTTFLabelWrap(getlocal("activity_RewardingBack_desc3"),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb3:setAnchorPoint(ccp(0,1))
            descLb3:setPosition(ccp(posX,self.cellHeight-10-titleLb:getContentSize().height-descLb1:getContentSize().height-descLb2:getContentSize().height-15))
            cell:addChild(descLb3)

            local exampleLb = GetTTFLabel(getlocal("activity_RewardingBack_example"),25)
            exampleLb:setAnchorPoint(ccp(0,1))
            exampleLb:setPosition(ccp(posX,self.cellHeight-10-titleLb:getContentSize().height-descLb1:getContentSize().height-descLb2:getContentSize().height-descLb3:getContentSize().height-25))
            exampleLb:setColor(G_ColorYellow)
            cell:addChild(exampleLb)

            local  tmpStoreCfg=G_getPlatStoreCfg()
            local  mPrice=tmpStoreCfg["gold"][3]
            local addGems = math.ceil(mPrice*acRewardingBackVoApi:getGemsRate())
            local addGolds=mPrice*acRewardingBackVoApi:getGoldsRate()
            local exampleDescLb = GetTTFLabelWrap(getlocal("activity_RewardingBack_exampleDesc",{mPrice,addGems,addGolds}),25,CCSizeMake(self.bgLayer:getContentSize().width-80-exampleLb:getContentSize().width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            exampleDescLb:setAnchorPoint(ccp(0,1))
            exampleDescLb:setPosition(ccp(posX+exampleLb:getContentSize().width,exampleLb:getPositionY()))
            cell:addChild(exampleDescLb)
        end
        if idx~=3 then
            local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png");
            lineSp:setAnchorPoint(ccp(0.5,0));
            lineSp:setPosition((self.bgLayer:getContentSize().width-40)/2,0)
            lineSp:setScaleY(1.2)
            lineSp:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp:getContentSize().width)
            cell:addChild(lineSp)
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
function acRewardingBackDialog:tick( ... )
    self:updateRewardBtn()
end
function acRewardingBackDialog:dispose()
    self.cellHeight=nil
    self.bgLayer=nil
    self.layerNum=nil
end