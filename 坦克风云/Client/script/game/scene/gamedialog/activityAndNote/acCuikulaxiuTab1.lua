acCuikulaxiuTab1={

}

function acCuikulaxiuTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
   
    self.layerNum=nil

    self.gotoMenu = nil
    self.adaH = 0
    if G_getIphoneType() == G_iphoneX then
        self.adaH = 15
    end
    return nc;

end

function acCuikulaxiuTab1:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    
    self:initTableView()


    return self.bgLayer
end

-- 更新领奖按钮显示
function acCuikulaxiuTab1:update()
    if self.tv then
        self.tv:reloadData()
    end
    if self.medalsLb then
        self.medalsLb:setString(acCuikulaxiuVoApi:getMyPoint())
    end
end

function acCuikulaxiuTab1:initTableView()


    local characterSp
    if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
        characterSp = CCSprite:create("public/guide.png")
    else
        characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter_new.png") --姑娘
    end
    characterSp:setScale(0.8)
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(30,self.bgLayer:getContentSize().height - 460))
    self.bgLayer:addChild(characterSp,5)

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX((G_VisibleSizeWidth)/lineSprite:getContentSize().width)
    lineSprite:setPosition(ccp((G_VisibleSizeWidth)/2,self.bgLayer:getContentSize().height - 465))
    self.bgLayer:addChild(lineSprite,6)
    
    local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    girlDescBg:setContentSize(CCSizeMake(410,150+self.adaH))
    girlDescBg:setAnchorPoint(ccp(0,0))
    girlDescBg:setPosition(ccp(180,self.bgLayer:getContentSize().height - 450))
    self.bgLayer:addChild(girlDescBg,4)

    self.descTv,self.descLb=G_LabelTableView(CCSize(300,130+self.adaH),getlocal("activity_cuikulaxiu_content"),25,kCCTextAlignmentCenter)
    self.descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.descTv:setAnchorPoint(ccp(0,0))
    self.descTv:setPosition(ccp(70,10))
    girlDescBg:addChild(self.descTv,2)
    self.descTv:setMaxDisToBottomOrTop(50)

    local rankSp=CCSprite:createWithSpriteFrameName("top1.png")
    rankSp:setScale(100/rankSp:getContentSize().width)
    rankSp:setAnchorPoint(ccp(0,0.5))
    rankSp:setPosition(20,self.bgLayer:getContentSize().height-530)
    self.bgLayer:addChild(rankSp)

    local jungongLb = GetTTFLabelWrap(getlocal("activity_cuikulaxiu_acHadPoint"),25,CCSizeMake(self.bgLayer:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    jungongLb:setAnchorPoint(ccp(0,0.5))
    jungongLb:setPosition(130,self.bgLayer:getContentSize().height-500)
    self.bgLayer:addChild(jungongLb)

    local acMedals = acCuikulaxiuVoApi:getMyPoint()
    self.medalsLb = GetTTFLabel(tostring(acMedals),30)
    self.medalsLb:setAnchorPoint(ccp(0,0))
    self.medalsLb:setPosition(160,self.bgLayer:getContentSize().height-570)
    self.bgLayer:addChild(self.medalsLb)
    self.medalsLb:setColor(G_ColorYellowPro)

    local needWidth = 20
    local strSize2 = 23
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        needWidth = 0
        strSize2 =28
    end
    
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),strSize2)
    actTime:setPosition(ccp(50-needWidth,self.bgLayer:getContentSize().height-195))
    actTime:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)
    
    local rewardTimeStr = GetTTFLabel(getlocal("recRewardTime"),strSize2)
    rewardTimeStr:setAnchorPoint(ccp(0,0.5))
    rewardTimeStr:setColor(G_ColorYellowPro)
    rewardTimeStr:setPosition(ccp(50-needWidth,self.bgLayer:getContentSize().height-230))
    self.bgLayer:addChild(rewardTimeStr,5)

    local acVo = acCuikulaxiuVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,strSize2-2)
        timeLabel:setAnchorPoint(ccp(0,0.5))
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2-110+needWidth, self.bgLayer:getContentSize().height-195))
        self.bgLayer:addChild(timeLabel)

        local timeStr2=activityVoApi:getActivityRewardTimeStr(acVo.acEt,60,86400)
        local timeLabel2=GetTTFLabel(timeStr2,strSize2-2)
        timeLabel2:setAnchorPoint(ccp(0,0.5))
        timeLabel2:setPosition(ccp(self.bgLayer:getContentSize().width/2-110+needWidth, self.bgLayer:getContentSize().height-230))
        self.bgLayer:addChild(timeLabel2)

        self.timeLb1=timeLabel
        self.timeLb2=timeLabel2
        self:updateAcTime()
    end

    local function showInfo()
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("activity_cuikulaxiu_rankTip3"),"\n",getlocal("activity_cuikulaxiu_goalsTip2"),"\n",getlocal("activity_cuikulaxiu_goalsTip1"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorRed,nil,nil,nil,nil,nil})
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",showInfo,11,nil,nil)
    --infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-35,self.bgLayer:getContentSize().height-195))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn,3);
  
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height - 690))
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,110))
    self.bgLayer:addChild(tvBg)

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,tvBg:getContentSize().height-10),nil)

    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(0,0))
    tvBg:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local function gotoHandler(tag,object)
        if G_checkClickEnable()==false then
          do
            return
          end
        end
        PlayEffect(audioCfg.mouseClick)
        mainUI:changeToWorld()
        activityAndNoteDialog:closeAllDialog()
        
      end

      self.gotoBtn =GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",gotoHandler,3,getlocal("activity_cuikulaxiu_gotoBtn"),28)
      self.gotoBtn:setAnchorPoint(ccp(0.5, 0))
      self.gotoMenu=CCMenu:createWithItem(self.gotoBtn)
      self.gotoMenu:setPosition(ccp(G_VisibleSizeWidth/2,30))
      self.gotoMenu:setTouchPriority(-(self.layerNum-1)*20-8)
      self.bgLayer:addChild(self.gotoMenu) 

      if acCuikulaxiuVoApi:getEndTime()<=base.serverTime then
        self.gotoBtn:setEnabled(false)
        self.descLb:setString(getlocal("activity_cuikulaxiu_contentEnd"))
      else
        self.gotoBtn:setEnabled(true)
        self.descLb:setString(getlocal("activity_cuikulaxiu_content"))
      end

end

function acCuikulaxiuTab1:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(acCuikulaxiuVoApi:getPointRewardCfg())
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    tmpSize = CCSizeMake(G_VisibleSizeWidth - 60,120-self.adaH*2/3)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-80, 120-self.adaH*2/3))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(10,0))
    cell:addChild(backSprie,1)


    local cfg = acCuikulaxiuVoApi:getPointRewardCfg()
    local index = SizeOfTable(cfg)-idx

    local rewardCfg = acCuikulaxiuVoApi:getPointRewardByID(index)
    local reward = FormatItem(rewardCfg)
    if reward then
        for k,v in pairs(reward) do
           local icon,iconScale = G_getItemIcon(v,100,true,self.layerNum,nil,self.tv)
            icon:setTouchPriority(-(self.layerNum-1)*20-3)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(10,backSprie:getContentSize().height/2)
            backSprie:addChild(icon)

            local num = GetTTFLabel("x"..v.num,25/iconScale)
            num:setAnchorPoint(ccp(1,0))
            num:setPosition(icon:getContentSize().width-10,10)
            icon:addChild(num)
        end
    end
    

    local needMedals = acCuikulaxiuVoApi:getNeedPointByID(index)
    local hasMedals = acCuikulaxiuVoApi:getMyPoint()

    local needMedalsLb = GetTTFLabelWrap(getlocal("activity_cuikulaxiu_needPoint",{needMedals}),25,CCSizeMake(backSprie:getContentSize().width-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    needMedalsLb:setAnchorPoint(ccp(0,1))
    needMedalsLb:setPosition(120,backSprie:getContentSize().height-10)
    backSprie:addChild(needMedalsLb)
    needMedalsLb:setColor(G_ColorGreen)

    local hasMedalsLb = GetTTFLabelWrap("",25,CCSizeMake(backSprie:getContentSize().width-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    hasMedalsLb:setAnchorPoint(ccp(0,0))
    hasMedalsLb:setPosition(120,10)
    backSprie:addChild(hasMedalsLb)

    if hasMedals>= needMedals then
      hasMedalsLb:setString(getlocal("schedule_finish"))
      hasMedalsLb:setColor(G_ColorYellowPro)
      if acCuikulaxiuVoApi:getIsHadRewardByID(index)== true then
        local hadRewardLb = GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        hadRewardLb:setAnchorPoint(ccp(0.5,0.5))
        hadRewardLb:setPosition(backSprie:getContentSize().width-80,backSprie:getContentSize().height/2)
        backSprie:addChild(hadRewardLb)
      else
        local function onClick(tag,object)
           if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end 
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
               PlayEffect(audioCfg.mouseClick)
               
                local function onRequestEnd(fn,data)
                  local ret,sData=base:checkServerData(data)
                    if(ret==true)then
                        acCuikulaxiuVoApi:addHadRewardTb(index)
                        local recordPoint = self.tv:getRecordPoint()
                        self.tv:reloadData()
                        self.tv:recoverToRecordPoint(recordPoint)
                        for k,v in pairs(reward) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num)
                        end
                        G_showRewardTip(reward)
                        acCuikulaxiuVoApi:updateShow()
                    end
                  end
               socketHelper:activityCuikulaxiuPointReward(index,onRequestEnd)
            end
             
          
        end
        local buyItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",onClick,nil,getlocal("daily_scene_get"),25)
        buyItem:setScale(0.8)
        local buyBtn = CCMenu:createWithItem(buyItem)
        buyBtn:setPosition(ccp(backSprie:getContentSize().width-80,backSprie:getContentSize().height/2))
        buyBtn:setTouchPriority(-(self.layerNum-1)*20-3)
        backSprie:addChild(buyBtn)
      end
    else
      hasMedalsLb:setString(getlocal("schedule_count",{hasMedals,needMedals}))
      hasMedalsLb:setColor(G_ColorRed)
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

function acCuikulaxiuTab1:tick()
    self:updateAcTime()
end

function acCuikulaxiuTab1:updateAcTime()
    local acVo=acCuikulaxiuVoApi:getAcVo()
    if acVo and self.timeLb1 and self.timeLb2 then
        G_updateActiveTime(acVo,self.timeLb1,self.timeLb2,nil,true)
    end
end

function acCuikulaxiuTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    self.gotoMenu =nil
    self.timeLb1=nil
    self.timeLb2=nil
    self = nil
end
