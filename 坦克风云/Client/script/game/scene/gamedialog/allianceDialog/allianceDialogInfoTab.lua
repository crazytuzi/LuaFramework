require "luascript/script/game/gamemodel/alliance/allianceShopVoApi"
require "luascript/script/config/gameconfig/allianceActiveCfg"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceActiveDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceActiveTab1"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceActiveTab2"
require "luascript/script/game/scene/gamedialog/mergerServersChangeNameDialog"
allianceDialogInfoTab={


}

function allianceDialogInfoTab:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv2=nil;
    self.expandIdx2={}
    self.expandHeight2=G_VisibleSize.height-140-110
    self.normalHeight2=130
    self.extendSpTag2=113
    self.requires={}
    self.header2Tb={}
    self.allianceLv=nil
    self.bgLayer=nil;
    self.layerNum=nil;
    self.allTabs={};
    
    self.bgLayer1=nil;
    self.bgLayer2=nil;
    self.bgLayer3=nil;
    self.bgLayer4=nil;
    self.tv3=nil;


    self.selectedTabIndex=0;
    self.refreshTab={}
    self.nameTab={}
    self.refreshNameTab={}
    self.role=allianceVoApi:getSelfAlliance().role
    self.settingsBtn=nil
    self.skillSwitch=base.isAllianceSkillSwitch

    self.noEventLabel=nil
    self.attackNumLb=nil

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/allianceActiveImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/bubbleImage.plist")
    return nc;

end
--设置或修改每个Tab页签
function allianceDialogInfoTab:resetTab()
    --self.allTabs={getlocal("alliance_info_Introduction"),getlocal("alliance_technology"),getlocal("alliance_scene_event_title"),getlocal("alliance_duplicate")}
    self.allTabs={getlocal("alliance_info_Introduction"),getlocal("alliance_scene_member_list"),getlocal("alliance_donate"),getlocal("alliance_info_apply")}
    self:initTab(self.allTabs)
    self:refreshTips(4)
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
            tabBtnItem:setPosition(100,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         elseif index==1 then
            tabBtnItem:setPosition(248,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         elseif index==2 then
            tabBtnItem:setPosition(394,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         elseif index==3 then
            tabBtnItem:setPosition(540,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

function allianceDialogInfoTab:init(parent,layerNum,subIdx)
    self.allianceLv=allianceVoApi:getSelfAlliance().level

    self.layerNum=layerNum;
    self.parentDialog=parent
    self.bgLayer=CCLayer:create();
    
    local rect = CCRect(0, 0, 50, 50);
  local capInSet = CCRect(20, 20, 10, 10);
  local function click(hd,fn,idx)
  end
  self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),click)
  self.tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-240))
  self.tvBg:ignoreAnchorPointForPosition(false)
  self.tvBg:setAnchorPoint(ccp(0.5,0))
  --self.tvBg:setIsSallow(false)
  --self.tvBg:setTouchPriority(-(self.layerNum-1)*20-2)
  self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,30))
  self.bgLayer:addChild(self.tvBg)

    self:initTabLayer(0);

    if base.allianceAcYouhua==1 then
        local function resourceCallback(fn,data)
            local ret,sData = base:checkServerData(data)
            if ret==true then
                if sData.data.ainfo then
                    local updateData={ainfo=sData.data.ainfo}
                    allianceVoApi:formatSelfAllianceData(updateData)
                    allianceVoApi:setLastActiveSt()
                    local alliance = allianceVoApi:getSelfAlliance()
                    if G_isToday(alliance.apoint_at or 0)==false then
                        local updateData={ainfo={}}
                        allianceVoApi:formatSelfAllianceData(updateData)
                    end
                end
            end
        end
        socketHelper:allianceActiveCanReward(resourceCallback)
    end
    return self.bgLayer
end

function allianceDialogInfoTab:initTabLayer(subIdx)
    self:resetTab()
   -- self:initTabLayer1()
    self:initNewTabLayer1()
    self:initTabLayer2()
    self:initTabLayer3()
    self:initTabLayer4()
    -- if subIdx then
    --     if subIdx==3 and base.isAllianceFubenSwitch==1 then
    --         self:tabClick(3)
    --     elseif base.isAllianceSkillSwitch==1 then
    --         self:tabClick(1)
    --     end
    -- elseif base.isAllianceSkillSwitch==1 then
    --     self:tabClick(1)
    -- end

end


function allianceDialogInfoTab:initNewTabLayer1()
  self.bgLayer1=CCLayer:create()
  local width=self.bgLayer1:getContentSize().width
  local height=self.bgLayer1:getContentSize().height
  local txtSize = 25
  local alliance=allianceVoApi:getSelfAlliance()

  local btnY = 80
  local headBs=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
  headBs:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,230))
  headBs:setAnchorPoint(ccp(0.5,1))
  headBs:setPosition(ccp(width/2,height - 215))
  self.bgLayer1:addChild(headBs,4)

  local icon = CCSprite:createWithSpriteFrameName("helpAlliance.png")
  icon:setAnchorPoint(ccp(0.5,0.5))
  icon:setPosition(100,headBs:getContentSize().height/2+10)
  headBs:addChild(icon)
  icon:setScale(1.8)

  self.myAllianceLv = GetTTFLabel(getlocal("fightLevel",{alliance.level}),30)
  self.myAllianceLv:setAnchorPoint(ccp(0.5,0))
  self.myAllianceLv:setPosition(100,20)
  self.myAllianceLv:setColor(G_ColorGreen)
  headBs:addChild(self.myAllianceLv)

  local leftPosX = 200
  local rightPosX = 400
  local buttomY = 30
  local posY = headBs:getContentSize().height/2-30
  local allianceNameWidth = width-200
  if G_getCurChoseLanguage() =="ar" then
    allianceNameWidth = 300
  end
  self.myAllianceName = GetTTFLabelWrap(alliance.name,40,CCSizeMake(allianceNameWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  self.myAllianceName:setAnchorPoint(ccp(0,1))
  self.myAllianceName:setPosition(leftPosX,headBs:getContentSize().height-20)
  self.myAllianceName:setColor(G_ColorYellow)
  headBs:addChild(self.myAllianceName)

    local function changeName( ... )
        if G_checkClickEnable()==false then
            do
            return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        mergerServersChangeNameDialog:create(self.layerNum+1,getlocal("alliance_changeName"),getlocal("alliance_changeContent",{getlocal("alliance_list_scene_name"),getlocal("alliance_list_scene_name"),getlocal("alliance_list_scene_name")}),2)
    end
    if string.find(alliance.name,"@")~=nil then
        self.changeNameItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",changeName,nil,getlocal("changename"),28)
        self.changeNameItem:setScale(0.6)
        self.changeNameItem:setAnchorPoint(ccp(1,1))
        if tostring(alliance.role)~="2"then
          self.changeNameItem:setEnabled(false)
          self.changeNameItem:setVisible(false)
        end
        local changeNameMenu=CCMenu:createWithItem(self.changeNameItem);
        changeNameMenu:setPosition(ccp(headBs:getContentSize().width-10,headBs:getContentSize().height-10))
        changeNameMenu:setTouchPriority(-(self.layerNum-1)*20-4);
        headBs:addChild(changeNameMenu)
    end

  self.myAllianceLeader = GetTTFLabelWrap(getlocal("alliance_info_leader",{alliance.leaderName}),25,CCSizeMake(allianceNameWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  self.myAllianceLeader:setAnchorPoint(ccp(0,1))
  self.myAllianceLeader:setPosition(leftPosX,headBs:getContentSize().height-self.myAllianceName:getContentSize().height-30)
  headBs:addChild(self.myAllianceLeader)

  local iconScale=0.8

  local myAllianceAttackSp = CCSprite:createWithSpriteFrameName("allianceAttackIcon.png")
  myAllianceAttackSp:setAnchorPoint(ccp(0.5,0.5))
  myAllianceAttackSp:setPosition(leftPosX+50,posY)
  headBs:addChild(myAllianceAttackSp)
  myAllianceAttackSp:setScale(iconScale)

  self.myAllianceAttack = GetTTFLabel(FormatNumber(alliance.fight),25)
  self.myAllianceAttack:setAnchorPoint(ccp(0,0.5))
  self.myAllianceAttack:setPosition(leftPosX+110,posY)
  headBs:addChild(self.myAllianceAttack)

  local myAllianceNumSp = CCSprite:createWithSpriteFrameName("allianceMemberIcon.png")
  myAllianceNumSp:setAnchorPoint(ccp(0.5,0.5))
  myAllianceNumSp:setPosition(rightPosX+50,posY)
  headBs:addChild(myAllianceNumSp)
  myAllianceNumSp:setScale(iconScale)

  local memberNum=0
  local memberTab=allianceMemberVoApi:getMemberTab()
  if memberTab then
    memberNum=SizeOfTable(memberTab)
  end
  local amaxnum
  if(allianceVoApi:getSelfAlliance() and allianceVoApi:getSelfAlliance().maxnum)then
      amaxnum=allianceVoApi:getSelfAlliance().maxnum
  else
      amaxnum=playerCfg["allianceMember"][allianceVoApi:getSelfAlliance().level]
  end
  self.myAllianceNum = GetTTFLabel(getlocal("scheduleChapter",{memberNum,amaxnum}),25)
  self.myAllianceNum:setAnchorPoint(ccp(0,0.5))
  self.myAllianceNum:setPosition(rightPosX+100,posY)
  headBs:addChild(self.myAllianceNum)

  local myAlliancePointSp = CCSprite:createWithSpriteFrameName("helpRecharge.png")
  myAlliancePointSp:setAnchorPoint(ccp(0.5,0.5))
  myAlliancePointSp:setPosition(leftPosX+45,buttomY)
  headBs:addChild(myAlliancePointSp)
  myAlliancePointSp:setScale(0.85*0.8)

  self.myAlliancePoint = GetTTFLabel(FormatNumber(alliance.point),25)
  self.myAlliancePoint:setAnchorPoint(ccp(0,0.5))
  self.myAlliancePoint:setPosition(leftPosX+110,buttomY)
  headBs:addChild(self.myAlliancePoint)

  local myAllianceRankSp = CCSprite:createWithSpriteFrameName("allianceActiveRank.png")
  myAllianceRankSp:setAnchorPoint(ccp(0.5,0.5))
  myAllianceRankSp:setPosition(rightPosX+48,buttomY)
  headBs:addChild(myAllianceRankSp)
  myAllianceRankSp:setScale(0.8*0.8)

  self.myAllianceRank = GetTTFLabel(FormatNumber(alliance.rank),25)
  self.myAllianceRank:setAnchorPoint(ccp(0,0.5))
  self.myAllianceRank:setPosition(rightPosX+100,buttomY)
  headBs:addChild(self.myAllianceRank)


  local function callBack(...)
       return self:eventHandlerNew(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tvNew=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(width-40,height-565),nil)
  --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
  self.tvNew:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  self.tvNew:setPosition(ccp(20,110))
  self.bgLayer1:addChild(self.tvNew)
  self.tvNew:setMaxDisToBottomOrTop(120)



  local function settingHandler()
        PlayEffect(audioCfg.mouseClick)
    local function saveCallback(aid,internalNotice,foreignNotice,joinNeedLv,joinNeedFc,joinType)
      local valueTab={aid=aid,type=joinType,level_limit=joinNeedLv,fight_limit=joinNeedFc,notice=internalNotice,desc=foreignNotice}
      allianceVoApi:setSelfAlliance(valueTab)
      --self.bgLayer1:removeFromParentAndCleanup(true)
      --self.bgLayer1=nil
      --self:initTabLayer1()
    end
    allianceSmallDialog:allianceSettingsDialog("PanelHeaderPopup.png",CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,4,saveCallback,alliance)
    end
    if self.settingsBtn==nil then
      --local settingsItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",settingHandler,1,getlocal("alliance_scene_setting"),25)
      local widthButton = 200
      local rect = CCRect(44,33,1,1)
      local function nilFunc()
          
      end
      local sNormal =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
      local sSelected =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue2.png",rect,nilFunc)
      local sDisabled =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
      sNormal:setContentSize(CCSizeMake(widthButton,60))
      sSelected:setContentSize(CCSizeMake(widthButton,60))
      sDisabled:setContentSize(CCSizeMake(widthButton,60))

      local item = CCMenuItemSprite:create(sNormal, sSelected, sDisabled)  
      item:registerScriptTapHandler(settingHandler)

      local titleLb=GetTTFLabel(getlocal("alliance_scene_setting"),28)
      titleLb:setAnchorPoint(ccp(0.5,0.5))
      titleLb:setPosition(getCenterPoint(item))
      item:addChild(titleLb)

      self.settingsBtn = CCMenu:createWithItem(item)
      self.settingsBtn:setPosition(ccp(width/2-120,btnY))

      -- self.settingsBtn=CCMenu:createWithItem(settingsItem)
      -- self.settingsBtn:setPosition(ccp(width/2,80))
      self.settingsBtn:setTouchPriority(-(self.layerNum-1)*20-4)
      self.bgLayer1:addChild(self.settingsBtn)
      local function sendEmail()
        PlayEffect(audioCfg.mouseClick)
        self:sendEmail()
      end


      local function leaveAlliance()
          local uid=playerVoApi:getUid()
          if allianceVoApi:checkCanQuitAlliance(uid,self.layerNum+1)==false then
            do return end
          end
            local params={}
            if(tonumber(allianceVoApi:getSelfAlliance().role)==2 and SizeOfTable(allianceMemberVoApi:getMemberTab())==1)then
              params["isDismiss"]=1
              params["name"]=allianceVoApi:getSelfAlliance().name
            else
                params["name"]=allianceVoApi:getSelfAlliance().name
                params["list"]={}
                for k,v in pairs(allianceMemberVoApi:getMemberTab()) do
                  if(v.uid~=playerVoApi:getUid())then
                    table.insert(params["list"],{v.uid,v.name})
                  end
                end
            end
            local function leaveAllianceCallBack(fn,data)
                if base:checkServerData(data)==true then
                    -- allianceVoApi:clearSelfAlliance()--清空自己军团信息
                    allianceVoApi:clear()
                    allianceMemberVoApi:clear()--清空成员列表
                    allianceApplicantVoApi:clear()--清空
                    playerVoApi:clearAllianceData()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_tuichuTip"),30)

                    self.parentDialog:close()--关闭板子
                    -- parentDlg:close(true)
                    chatVoApi:sendUpdateMessage(5,params)
                    --socketHelper:chatServerLogout()
                    -- allianceVoApi:clearRankAndGoodList()--清空军团列表
                    worldScene:updateAllianceName()
                    --helpDefendVoApi:clear()--清空协防
                    --工会活动刷新数据
                    activityVoApi:updateAc("fbReward")
                    activityVoApi:updateAc("allianceLevel")
                    activityVoApi:updateAc("allianceFight")
                end
            end
            socketHelper:allianceQuit(allianceVoApi:getSelfAlliance().aid,nil,leaveAllianceCallBack)
        end
        
        local function leaveSureAndCancel()
            if base.localWarSwitch==1 then
                if localWarVoApi:canQuitAlliance(1)==false then
                    do return end
                end
            end
            if base.serverWarLocalSwitch==1 then
                if serverWarLocalVoApi:canQuitAlliance(1)==false then
                    do return end
                end
            end

            if tonumber(allianceVoApi:getSelfAlliance().role)==2 and SizeOfTable(allianceMemberVoApi:getMemberTab())>1 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_wufatuichuTip"),30)

                do
                    return
                end
            elseif tonumber(allianceVoApi:getSelfAlliance().role)==2 and SizeOfTable(allianceMemberVoApi:getMemberTab())==1 then
                
                    allianceSmallDialog:showOKDialog(leaveAlliance,getlocal("alliance_tuanzhangtuichuSureOK"),self.layerNum+1)


            else
                    allianceSmallDialog:showOKDialog(leaveAlliance,getlocal("alliance_tuichuok"),self.layerNum+1)

            end

        end

      local sNormal =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
      local sSelected =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue2.png",rect,nilFunc)
      local sDisabled =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
      sNormal:setContentSize(CCSizeMake(widthButton,60))
      sSelected:setContentSize(CCSizeMake(widthButton,60))
      sDisabled:setContentSize(CCSizeMake(widthButton,60))

      local item = CCMenuItemSprite:create(sNormal, sSelected, sDisabled)  
      item:registerScriptTapHandler(leaveSureAndCancel)

      local titleLb=GetTTFLabel(getlocal("alliance_scene_quit_alliance_title"),28)
      titleLb:setAnchorPoint(ccp(0.5,0.5))
      titleLb:setPosition(getCenterPoint(item))
      item:addChild(titleLb)

      self.sendMenu = CCMenu:createWithItem(item)
      self.sendMenu:setPosition(ccp(width/2-120,btnY))

      -- self.settingsBtn=CCMenu:createWithItem(settingsItem)
      -- self.settingsBtn:setPosition(ccp(width/2,80))
      self.sendMenu:setTouchPriority(-(self.layerNum-1)*20-4)
      self.bgLayer1:addChild(self.sendMenu)


  end
    if self.settingsBtn then
        if tostring(alliance.role)=="1" or tostring(alliance.role)=="2" then
            --self.settingsBtn:setVisible(true)
            --self.settingsBtn:setEnabled(true)
            self.settingsBtn:setPosition(ccp(width/2+120,btnY))
            --self.sendMenu:setPosition(ccp(width/2-100,noticeBg:getPositionY()-noticeBg:getContentSize().height-110))
            self.settingsBtnPosition=ccp(self.settingsBtn:getPositionX(),self.settingsBtn:getPositionY())
            --self.sendMenuPosition=ccp(self.sendMenu:getPositionX(),self.sendMenu:getPositionY())

        else
            --self.settingsBtn:setVisible(false)
            --self.settingsBtn:setEnabled(false)
            self.settingsBtn:setPosition(ccp(3000,0))
            --self.sendMenu:setPosition(ccp(3000,0))
        end
        
    end
    self:addClanplayBtn()

  self.bgLayer:addChild(self.bgLayer1,2)
end


function allianceDialogInfoTab:eventHandlerNew(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
      local tmpSize
            tmpSize=CCSizeMake(self.bgLayer1:getContentSize().width-40,450)
      return  tmpSize
  elseif fn=="tableCellAtIndex" then
      local cell=CCTableViewCell:new()
      cell:autorelease()
      cell:setContentSize(CCSizeMake(self.bgLayer1:getContentSize().width-40,450))
      local cellWidth = cell:getContentSize().width
      local cellHeight = cell:getContentSize().height
      local alliance=allianceVoApi:getSelfAlliance()

      local h = cellHeight
      local noticeLb = GetTTFLabelWrap(getlocal("alliance_notice"),30,CCSizeMake(cellWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
      noticeLb:setAnchorPoint(ccp(0.5,1))
      noticeLb:setPosition(cell:getContentSize().width/2,h)
      cell:addChild(noticeLb)

      h= h-noticeLb:getContentSize().height-5
      local capInSet = CCRect(20, 20, 10, 10) 
      local function touch()
      end
      local noticeBg =LuaCCScale9Sprite:createWithSpriteFrameName("NoticeLine.png",capInSet,touch)
      noticeBg:setContentSize(CCSizeMake(cellWidth-130,150))
      noticeBg:ignoreAnchorPointForPosition(false)
      noticeBg:setAnchorPoint(ccp(0.5,1))
      noticeBg:setPosition(ccp(cellWidth/2,h))
      noticeBg:setIsSallow(false)
      noticeBg:setTouchPriority(-(self.layerNum-1)*20-2)
      cell:addChild(noticeBg,1)
      
      self.noticeValueLable=GetTTFLabelWrap(alliance.notice,25,CCSize(noticeBg:getContentSize().width-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
      self.noticeValueLable:setAnchorPoint(ccp(0,1))
      self.noticeValueLable:setPosition(ccp(5,noticeBg:getContentSize().height-5))
      self.noticeValueLable:setColor(G_ColorYellow)
      noticeBg:addChild(self.noticeValueLable,1)

      h= h-noticeBg:getContentSize().height-20

      local function rightPageHandler()
        if self.tvNew:getScrollEnable()==true and self.tvNew:getIsScrolled()==false then
          if G_checkClickEnable()==false then
              do
                  return
              end
          else
              base.setWaitTime=G_getCurDeviceMillTime()
          end
          PlayEffect(audioCfg.mouseClick)

          if self.activeSP then
            local function callBack()
              local td=allianceActiveDialog:new(self)
              local title=getlocal("alliance_activie")
              local tbArr={getlocal("world_scene_info"),getlocal("alliance_activie_reward")}
              local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,title,true,self.layerNum+1)
              sceneGame:addChild(dialog,self.layerNum+1)
            end
            local callFunc=CCCallFunc:create(callBack)

            local scaleTo1=CCScaleTo:create(0.1,0.9,0.9)
            local scaleTo2=CCScaleTo:create(0.1,1,1)

            local acArr=CCArray:create()
            acArr:addObject(scaleTo1)
            acArr:addObject(scaleTo2)
            acArr:addObject(callFunc)

            local seq=CCSequence:create(acArr)
            self.activeSP:runAction(seq)
          end

        end
      end

      self.activeSP = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),rightPageHandler)
      self.activeSP:setAnchorPoint(ccp(0.5,1))
      self.activeSP:setTouchPriority(-(self.layerNum-1)*20-3)
      self.activeSP:setPosition(ccp(cell:getContentSize().width/2,h))
      self.activeSP:setContentSize(CCSizeMake(cellWidth-40,150))
      cell:addChild(self.activeSP)
      local defaultWidth =cellWidth-20
      if G_getCurChoseLanguage() =="ar" then
        defaultWidth = 450
      end

      local activeLb = GetTTFLabelWrap(getlocal("alliance_activie"),30,CCSizeMake(defaultWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
      activeLb:setAnchorPoint(ccp(0,1))
      activeLb:setPosition(10,self.activeSP:getContentSize().height-10)
      self.activeSP:addChild(activeLb)

      local activeIcon = CCSprite:createWithSpriteFrameName("allianceActiveIcon.png")
      activeIcon:setAnchorPoint(ccp(0,0))
      activeIcon:setPosition(10,10)
      self.activeSP:addChild(activeIcon)

      self.activeLv = GetTTFLabel(tostring(alliance.alevel),25)
      self.activeLv:setAnchorPoint(ccp(0.5,0.5))
      self.activeLv:setPosition(activeIcon:getContentSize().width/2,activeIcon:getContentSize().height/2)
      activeIcon:addChild(self.activeLv,5)
      self.activeLv:setColor(G_ColorYellow)


      local barPosx=self.activeSP:getContentSize().width/2+40
      local barScale=0.8
      if base.allianceAcYouhua==1 then
          barPosx=self.activeSP:getContentSize().width/2+10
          barScale=0.6
      end
      AddProgramTimer(self.activeSP,ccp(barPosx,40),10,nil,nil,"VipIconYellowBarBg.png","VipIconYellowBar.png",11)
      self.timerSprite = tolua.cast(self.activeSP:getChildByTag(10),"CCProgressTimer")
      self.timerSprite:setScaleX(barScale)
      local nowActive = alliance.apoint
      -- local needActive = 0
      -- for k,v in pairs(allianceActiveCfg.allianceALevelPoint) do
      --   if k and k<alliance.alevel and v then
      --     needActive= needActive + tonumber(v) 
      --   end
      -- end
      -- local showActive=0
      -- if nowActive>= needActive then
      --   showActive = nowActive-needActive
      -- end
      if allianceActiveCfg.allianceALevelPoint[alliance.alevel+1]==nil then
        allianceActiveCfg.allianceALevelPoint[alliance.alevel+1]=allianceActiveCfg.ActiveMaxPoint
      end
      local maxActive = allianceActiveCfg.allianceALevelPoint[alliance.alevel+1]

      local showActive = nowActive-allianceActiveCfg.allianceALevelPoint[alliance.alevel]
      local showMaxActive = maxActive-allianceActiveCfg.allianceALevelPoint[alliance.alevel]
       
      if self.timerSprite then
        local percentage = showActive/showMaxActive
        self.timerSprite:setPercentage(percentage*100)
      end

      self.activePerLb=GetTTFLabel(getlocal("scheduleChapter",{nowActive,maxActive}),25)
      self.activePerLb:setAnchorPoint(ccp(0.5,0))
      self.activePerLb:setPosition(barPosx,60)
      self.activeSP:addChild(self.activePerLb)

      local sp = tolua.cast(self.activeSP:getChildByTag(11),"CCSprite")
      sp:setScaleX(barScale)
      
      -- self.rightBtn=GetButtonItem("allianceActiveLeftIcon.png","allianceActiveLeftIcon.png","allianceActiveLeftIcon.png",rightPageHandler,11,nil,nil)
      -- --self.rightBtn:setRotation(180)
      -- self.rightBtn:setScaleY(1.2)
      -- local rightMenu=CCMenu:createWithItem(self.rightBtn)
      -- rightMenu:setAnchorPoint(ccp(0.5,0.5))
      -- rightMenu:setTouchPriority(-(self.layerNum-1)*20-4)
      -- self.activeSP:addChild(rightMenu,1)
      -- rightMenu:setPosition(self.activeSP:getContentSize().width-50,self.activeSP:getContentSize().height/2)


      if base.allianceAcYouhua==1 then
          self.rightsp = CCSprite:createWithSpriteFrameName("IconReturnBtn.png")
          self.rightsp:setPosition(ccp(self.activeSP:getContentSize().width-60,self.activeSP:getContentSize().height/2))
          self.activeSP:addChild(self.rightsp)

          local function onclick()
              local alliance = allianceVoApi:getSelfAlliance()
              local function rewardCallback(fn,data)
                  local ret,sData = base:checkServerData(data)
                  if ret==true then
                      if sData.data.res and type(sData.data.res) and SizeOfTable(sData.data.res)>0 then
                          -- local hadReward = allianceMemberVoApi:getUserHadRewardResource(playerVoApi:getUid())
                          local ar = {}
                          local hadRewardTotal=allianceVoApi:getActiveRewardTotal()
                          local hadReward = allianceVoApi:getActiveReward()
                          local tipStr = getlocal("daily_lotto_tip_10")
                          local i = 1
                          for k,v in pairs(sData.data.res) do
                              playerVoApi:setValue(k,playerVo[k]+tonumber(v))
                              if hadReward[k] then
                                  hadReward[k]=hadReward[k]+v
                              else
                                  hadReward[k]=v
                              end
                              hadRewardTotal[k]=alliance.ainfo.r[k]
                              local name = getItem(tostring(k),"u")
                              if i==SizeOfTable(sData.data.res) then
                                  tipStr = tipStr .. name .. " x" .. v
                              else
                                  tipStr = tipStr .. name .. " x" .. v .. ","
                              end
                              i=i+1
                          end
                          ar.a=hadReward
                          ar.r=hadRewardTotal
                          -- allianceMemberVoApi:setUserHadRewardResource(playerVoApi:getUid(),hadReward,base.serverTime)
                          allianceVoApi:refreshActiveReward(ar,base.serverTime)

                          if self.lightBg then
                              self.lightBg:setVisible(false)
                          end
                          if self.rewardBtn then
                              self.rewardBtn:setVisible(false)
                              self.rewardBtn:setEnabled(false)
                          end
                          if self.rightsp then
                              self.rightsp:setVisible(true)
                          end
                          local award={u=sData.data.res}
                          popDialog:createAllianceAcReward(self.bgLayer,self.layerNum+1,getlocal("activity_getReward"),award)
                          smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
                      end
                  end
              end
              if G_isToday(allianceVoApi:getJoinTime())==true then
                  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_activie_joinToday"),28)
              else
                  if alliance.ainfo and alliance.ainfo.r and SizeOfTable(alliance.ainfo.r)>0 then
                      socketHelper:allianceActiveReward(alliance.ainfo.r,rewardCallback)
                  end
              end
          end
          local time1=0
          self.lightBg1 = CCSprite:createWithSpriteFrameName("equipShine.png")
          self.activeSP:addChild(self.lightBg1)
          self.lightBg1:setPosition(ccp(self.activeSP:getContentSize().width-60,self.activeSP:getContentSize().height/2))
          local rotateBy = CCRotateBy:create(4,360)
          local reverseBy = rotateBy:reverse()
          self.lightBg1:runAction(CCRepeatForever:create(reverseBy))

          self.lightBg = CCSprite:createWithSpriteFrameName("equipShine.png")
          self.activeSP:addChild(self.lightBg)
          self.lightBg:setPosition(ccp(self.activeSP:getContentSize().width-60,self.activeSP:getContentSize().height/2))
          local rotateBy = CCRotateBy:create(4,360)
          self.lightBg:runAction(CCRepeatForever:create(rotateBy))

          -- self.rewardBtn=LuaCCSprite:createWithSpriteFrameName("friendBtn.png",onclick)
          -- self.rewardBtn:setPosition(ccp(self.activeSP:getContentSize().width-60,self.activeSP:getContentSize().height/2))
          -- self.rewardBtn:setIsSallow(true)
          -- self.rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2)
          -- self.lightBg:addChild(self.rewardBtn,1)
          self.rewardBtn=GetButtonItem("friendBtn.png","friendBtn.png","friendBtn.png",onclick)
          local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
          -- rewardMenu:setPosition(ccp(self.activeSP:getContentSize().width-60,self.activeSP:getContentSize().height/2))
          rewardMenu:setTouchPriority(-(self.layerNum-1)*20-5)
          self.activeSP:addChild(rewardMenu,2)
          rewardMenu:setPosition(ccp(self.activeSP:getContentSize().width-self.rewardBtn:getContentSize().width/2-10,self.activeSP:getContentSize().height/2))

          local lbWidth=120
          local rewardLb=GetTTFLabelWrap(getlocal("receive_welfare"),20,CCSizeMake(lbWidth+40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
          local bgHeight=rewardLb:getContentSize().height+10
          self.lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
          self.lbBg:setTouchPriority(-(self.layerNum-1)*20-1)
          self.lbBg:setContentSize(CCSizeMake(lbWidth,bgHeight))
          -- self.lbBg:setOpacity(180)
          self.lbBg:setPosition(ccp(self.activeSP:getContentSize().width-self.lbBg:getContentSize().width/2-5,self.lbBg:getContentSize().height/2+15))
          self.activeSP:addChild(self.lbBg,5)
          rewardLb:setAnchorPoint(ccp(0.5,0.5))
          rewardLb:setColor(G_ColorYellowPro)
          rewardLb:setPosition(getCenterPoint(self.lbBg))
          self.lbBg:addChild(rewardLb,1)

          local time = 0.14
          local rotate1=CCRotateTo:create(time, 30)
          local rotate2=CCRotateTo:create(time, -30)
          local rotate3=CCRotateTo:create(time, 20)
          local rotate4=CCRotateTo:create(time, -20)
          local rotate5=CCRotateTo:create(time, 0)
          local delay=CCDelayTime:create(1)
          local acArr=CCArray:create()
          acArr:addObject(rotate1)
          acArr:addObject(rotate2)
          acArr:addObject(rotate3)
          acArr:addObject(rotate4)
          acArr:addObject(rotate5)
          acArr:addObject(delay)
          local seq=CCSequence:create(acArr)
          local repeatForever=CCRepeatForever:create(seq)
          self.rewardBtn:runAction(repeatForever)

          local canReward=self:getCanReward()
          print("canReward",canReward)
          if canReward==true then
              self.rightsp:setVisible(false)
          else
              self.lightBg:setVisible(false)
              self.lightBg1:setVisible(false)
              self.rewardBtn:setVisible(false)
              self.rewardBtn:setEnabled(false)
              self.lbBg:setVisible(false)
          end
      else
          self.rightsp = CCSprite:createWithSpriteFrameName("allianceActiveLeftIcon.png")
          self.rightsp:setPosition(self.activeSP:getContentSize().width-30,self.activeSP:getContentSize().height/2)
          self.activeSP:addChild(self.rightsp)
      end
      


      -- local posX,posY=rightsp:getPosition()
      -- local posX2=posX-20

      -- local mvTo=CCMoveTo:create(0.5,ccp(posX,posY))
      -- local fadeIn=CCFadeIn:create(0.5)
      -- local carray=CCArray:create()
      -- carray:addObject(mvTo)
      -- carray:addObject(fadeIn)
      -- local spawn=CCSpawn:create(carray)

      -- local mvTo2=CCMoveTo:create(0.5,ccp(posX2,posY))
      -- local fadeOut=CCFadeOut:create(0.5)
      -- local carray2=CCArray:create()
      -- carray2:addObject(mvTo2)
      -- carray2:addObject(fadeOut)
      -- local spawn2=CCSpawn:create(carray2)

      -- local seq=CCSequence:createWithTwoActions(spawn2,spawn)
      -- rightMenu:runAction(CCRepeatForever:create(seq))



      h= h - self.activeSP:getContentSize().height-20
      local joinSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function ()end)
      joinSp:setAnchorPoint(ccp(0.5,1))
      joinSp:setPosition(ccp(cell:getContentSize().width/2,h))
      joinSp:setContentSize(CCSizeMake(cellWidth-40,150))
      cell:addChild(joinSp)

      local joinTypeTitle = GetTTFLabelWrap(getlocal("alliance_join_type"),25,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
      joinTypeTitle:setAnchorPoint(ccp(0,0.5))
      joinTypeTitle:setPosition(10,joinSp:getContentSize().height/4*3-10)
      joinSp:addChild(joinTypeTitle)

      local defaultWidth2 = cellWidth-160
      if G_getCurChoseLanguage() =="ar" then
        defaultWidth2 = 400
      end
      self.joinTypeLb = GetTTFLabelWrap(getlocal("alliance_apply"..alliance.type),25,CCSizeMake(defaultWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
      self.joinTypeLb:setAnchorPoint(ccp(0,0.5))
      self.joinTypeLb:setPosition(joinTypeTitle:getContentSize().width,joinSp:getContentSize().height/4*3-10)
      joinSp:addChild(self.joinTypeLb)
      self.joinTypeLb:setColor(G_ColorYellow)

      local conditionStr=""
      if alliance.level_limit and alliance.level_limit>0 then
        conditionStr=conditionStr..getlocal("fightLevel",{alliance.level_limit})
      end
      if alliance.fight_limit and alliance.fight_limit>0 then
        if conditionStr=="" then
          conditionStr=conditionStr..getlocal("alliance_join_condition_value",{FormatNumber(alliance.fight_limit)})
        else
          conditionStr=conditionStr..getlocal("alliance_join_condition_and")..getlocal("alliance_join_condition_value",{FormatNumber(alliance.fight_limit)})
        end
      end
      if conditionStr=="" then
        conditionStr=getlocal("alliance_info_content")
      end
      local strSize=25
      if G_getCurChoseLanguage() =="de" then
        strSize =21
      end
      local conditionTitle = GetTTFLabelWrap(getlocal("alliance_join_condition"),strSize,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
      conditionTitle:setAnchorPoint(ccp(0,0.5))
      conditionTitle:setPosition(10,joinSp:getContentSize().height/4+10)
      joinSp:addChild(conditionTitle)

      self.conditionLb = GetTTFLabelWrap(conditionStr,25,CCSizeMake(defaultWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
      self.conditionLb:setAnchorPoint(ccp(0,0.5))
      self.conditionLb:setPosition(conditionTitle:getContentSize().width,joinSp:getContentSize().height/4+10)
      joinSp:addChild(self.conditionLb)
      self.conditionLb:setColor(G_ColorYellow)




      return cell

  elseif fn=="ccTouchBegan" then
      self.isMoved=false
      return true
  elseif fn=="ccTouchMoved" then
      self.isMoved=true
  elseif fn=="ccTouchEnded"  then
       
  elseif fn=="ccScrollEnable" then
      if newGuidMgr:isNewGuiding()==true then
          return 0
      else
          return 1
      end
  end

end

function allianceDialogInfoTab:getCanReward()
    local canReward=false
    if base.allianceAcYouhua==1 then
        local canRewardTb={}
        local alliance=allianceVoApi:getSelfAlliance()
        local hadRewardTotal = allianceVoApi:getActiveRewardTotal()
        if alliance and alliance.alevel and allianceActiveCfg.allianceActiveReward[alliance.alevel] and allianceActiveCfg.allianceActiveReward[alliance.alevel]>0 then
            if alliance.ainfo and alliance.ainfo.r then
                for k,v in pairs(alliance.ainfo.r) do
                    if k and v then
                        local hadRewardR = 0
                        if hadRewardTotal and hadRewardTotal[k] then
                            hadRewardR=hadRewardTotal[k]
                        end
                        if v>hadRewardR then
                            canRewardTb[k]=math.ceil((v-hadRewardR)*allianceActiveCfg.allianceActiveReward[alliance.alevel])
                        end
                    end
                end
            end
        end
        if G_isToday(allianceVoApi:getJoinTime())==true then
        elseif alliance.alevel and allianceActiveCfg.allianceActiveReward[alliance.alevel]>0 and canRewardTb and SizeOfTable(canRewardTb)>0 then
            canReward=true
        end
    end
    return canReward
end

function allianceDialogInfoTab:initTabLayer1()
    self.bgLayer1=CCLayer:create()
    self.nameTab={"alliance_scene_button_info_name","alliance_scene_leader_name","alliance_scene_rank","alliance_scene_level","alliance_scene_member_num","alliance_join_type","alliance_join_condition"}
    
        if base.isAllianceWarSwitch==1 then
            self.nameTab={"alliance_scene_button_info_name","alliance_scene_leader_name","alliance_scene_rank","alliance_scene_level","alliance_funds","alliance_scene_member_num","alliance_join_type","alliance_join_condition"}
        end
  
  local width=self.bgLayer1:getContentSize().width
  local height=self.bgLayer1:getContentSize().height
  local txtSize = 25
  --local widthSpace=120
  local heightSpace=215
  local wSpace=50
  local hSpace=40
  local alliance=allianceVoApi:getSelfAlliance()
  local conditionStr=""
  if alliance.level_limit and alliance.level_limit>0 then
    conditionStr=conditionStr..getlocal("fightLevel",{alliance.level_limit})
  end
  if alliance.fight_limit and alliance.fight_limit>0 then
    if conditionStr=="" then
      conditionStr=conditionStr..getlocal("alliance_join_condition_value",{FormatNumber(alliance.fight_limit)})
    else
      conditionStr=conditionStr..getlocal("alliance_join_condition_and")..getlocal("alliance_join_condition_value",{FormatNumber(alliance.fight_limit)})
    end
  end
  if conditionStr=="" then
    conditionStr=getlocal("alliance_info_content")
  end
  local memberNum=0
  local memberTab=allianceMemberVoApi:getMemberTab()
  if memberTab then
    memberNum=SizeOfTable(memberTab)
  end
    local amaxnum
    if(allianceVoApi:getSelfAlliance() and allianceVoApi:getSelfAlliance().maxnum)then
        amaxnum=allianceVoApi:getSelfAlliance().maxnum
    else
        amaxnum=playerCfg["allianceMember"][allianceVoApi:getSelfAlliance().level]
    end
  local valueTab={alliance.name,alliance.leaderName,alliance.rank,alliance.level,getlocal("scheduleChapter",{memberNum,amaxnum}),getlocal("alliance_apply"..alliance.type),conditionStr}
    if base.isAllianceWarSwitch==1 then
        valueTab={alliance.name,alliance.leaderName,alliance.rank,alliance.level,alliance.point,getlocal("scheduleChapter",{memberNum,amaxnum}),getlocal("alliance_apply"..alliance.type),conditionStr}
    end
  --for i=1,SizeOfTable(self.nameTab) do
  local lbhight = height-heightSpace
  for k,v in pairs(self.nameTab) do
    print("kkkkkk=====",k,v)
    local temphight
    local nameLable = GetTTFLabelWrap(getlocal(v),txtSize,CCSizeMake(txtSize*8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
      nameLable:setAnchorPoint(ccp(0,1))
      nameLable:setPosition(ccp(65,lbhight))
    self.bgLayer1:addChild(nameLable,1)
    self.refreshNameTab[k]=nameLable
    temphight = nameLable:getContentSize().height

    if v=="alliance_scene_email" then
        local function sendAllianceEmailHandler()
          PlayEffect(audioCfg.mouseClick)
          self:sendEmail()
        end
        local sendItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",sendAllianceEmailHandler,10,getlocal("alliance_scene_email"),28)
        local scale=0.6
      sendItem:setScale(scale)
      local sendMenu=CCMenu:createWithItem(sendItem)
        --sendMenu:setPosition(ccp(width/2-wSpace+sendItem:getContentSize().width/2*scale,lbhight-25))
        sendMenu:setPosition(ccp(width/2,lbhight-25))
        sendMenu:setAnchorPoint(ccp(0,1))
        sendMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        self.bgLayer1:addChild(sendMenu,1)
       --  if allianceVoApi:canSendAllianceEmail() then
       --   sendItem:setEnabled(true)
        -- else
       --   sendItem:setEnabled(false)
       --  end
        self.refreshTab[v]=sendItem
        self.refreshTab["sendMenu"]= sendMenu
    else
      local nameValueLable = GetTTFLabelWrap(valueTab[k],txtSize,CCSizeMake(txtSize*13,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        nameValueLable:setAnchorPoint(ccp(0,1))
        nameValueLable:setPosition(ccp(width/2-wSpace,lbhight))
        if temphight<nameValueLable:getContentSize().height then
          temphight = nameValueLable:getContentSize().height
        end
      self.bgLayer1:addChild(nameValueLable,1)
      self.refreshTab[v]=nameValueLable
      nameValueLable:setColor(G_ColorYellow)
    end
    lbhight = lbhight - temphight -5
  end
  local noticeLable = GetTTFLabel(getlocal("alliance_notice"),txtSize)
    noticeLable:setAnchorPoint(ccp(0,1))
    noticeLable:setPosition(ccp(65,lbhight-5))
  self.bgLayer1:addChild(noticeLable,1)
  self.refreshTab["alliance_noticeName"]=noticeLable
  lbhight = lbhight - noticeLable:getContentSize().height
  local capInSet = CCRect(20, 20, 10, 10) 
  local function touch()
  end
  local noticeBg =LuaCCScale9Sprite:createWithSpriteFrameName("NoticeLine.png",capInSet,touch)
  noticeBg:setContentSize(CCSizeMake(width-130,180))
  noticeBg:ignoreAnchorPointForPosition(false)
  noticeBg:setAnchorPoint(ccp(0.5,1))
  noticeBg:setPosition(ccp(width/2,lbhight-5))
  noticeBg:setIsSallow(false)
  noticeBg:setTouchPriority(-(self.layerNum-1)*20-2)
  self.bgLayer1:addChild(noticeBg,1)
  self.refreshTab["noticeBg"]=noticeBg
  
    local noticeValueLable=GetTTFLabelWrap(alliance.notice,25,CCSize(width-140,500),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    noticeValueLable:setAnchorPoint(ccp(0,1))
    noticeValueLable:setPosition(ccp(5,noticeBg:getContentSize().height-5))
    noticeValueLable:setColor(G_ColorYellow)
    noticeBg:addChild(noticeValueLable,1)
    self.refreshTab["alliance_notice"]=noticeValueLable
  
  
    local function settingHandler()
        PlayEffect(audioCfg.mouseClick)
    local function saveCallback(aid,internalNotice,foreignNotice,joinNeedLv,joinNeedFc,joinType)
      local valueTab={aid=aid,type=joinType,level_limit=joinNeedLv,fight_limit=joinNeedFc,notice=internalNotice,desc=foreignNotice}
      allianceVoApi:setSelfAlliance(valueTab)
      --self.bgLayer1:removeFromParentAndCleanup(true)
      --self.bgLayer1=nil
      --self:initTabLayer1()
    end
    allianceSmallDialog:allianceSettingsDialog("PanelHeaderPopup.png",CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,4,saveCallback,alliance)
    end
    if self.settingsBtn==nil then
      --local settingsItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",settingHandler,1,getlocal("alliance_scene_setting"),25)
      local widthButton = 200
      local rect = CCRect(44,33,1,1)
      local function nilFunc()
          
      end
      local sNormal =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
      local sSelected =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue2.png",rect,nilFunc)
      local sDisabled =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
      sNormal:setContentSize(CCSizeMake(widthButton,60))
      sSelected:setContentSize(CCSizeMake(widthButton,60))
      sDisabled:setContentSize(CCSizeMake(widthButton,60))

      local item = CCMenuItemSprite:create(sNormal, sSelected, sDisabled)  
      item:registerScriptTapHandler(settingHandler)

      local titleLb=GetTTFLabel(getlocal("alliance_scene_setting"),28)
      titleLb:setAnchorPoint(ccp(0.5,0.5))
      titleLb:setPosition(getCenterPoint(item))
      item:addChild(titleLb)

      self.settingsBtn = CCMenu:createWithItem(item)
      self.settingsBtn:setPosition(ccp(width/2-100,lbhight-335))

      -- self.settingsBtn=CCMenu:createWithItem(settingsItem)
      -- self.settingsBtn:setPosition(ccp(width/2,80))
      self.settingsBtn:setTouchPriority(-(self.layerNum-1)*20-4)
      self.bgLayer1:addChild(self.settingsBtn)
      local function sendEmail()
        PlayEffect(audioCfg.mouseClick)
        self:sendEmail()
      end


      local function leaveAlliance()   
            local uid=playerVoApi:getUid()
            if allianceVoApi:checkCanQuitAlliance(uid,self.layerNum+1)==false then
              do return end
            end
            local params={}
            if(tonumber(allianceVoApi:getSelfAlliance().role)==2 and SizeOfTable(allianceMemberVoApi:getMemberTab())==1)then
              params["isDismiss"]=1
              params["name"]=allianceVoApi:getSelfAlliance().name
            else
                params["name"]=allianceVoApi:getSelfAlliance().name
                params["list"]={}
                for k,v in pairs(allianceMemberVoApi:getMemberTab()) do
                  if(v.uid~=playerVoApi:getUid())then
                    table.insert(params["list"],{v.uid,v.name})
                  end
                end
            end
            local function leaveAllianceCallBack(fn,data)
                if base:checkServerData(data)==true then
                    -- allianceVoApi:clearSelfAlliance()--清空自己军团信息
                    allianceVoApi:clear()
                    allianceMemberVoApi:clear()--清空成员列表
                    allianceApplicantVoApi:clear()--清空
                    playerVoApi:clearAllianceData()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_tuichuTip"),30)

                    self.parentDialog:close()--关闭板子
                    -- parentDlg:close(true)
                    chatVoApi:sendUpdateMessage(5,params)
                    --socketHelper:chatServerLogout()
                    -- allianceVoApi:clearRankAndGoodList()--清空军团列表
                    worldScene:updateAllianceName()
                    --helpDefendVoApi:clear()--清空协防
                    --工会活动刷新数据
                    activityVoApi:updateAc("fbReward")
                    activityVoApi:updateAc("allianceLevel")
                    activityVoApi:updateAc("allianceFight")
                end
            end
            socketHelper:allianceQuit(allianceVoApi:getSelfAlliance().aid,nil,leaveAllianceCallBack)
        end
        
        local function leaveSureAndCancel()
            if base.localWarSwitch==1 then
                if localWarVoApi:canQuitAlliance(1)==false then
                    do return end
                end
            end
            if base.serverWarLocalSwitch==1 then
                if serverWarLocalVoApi:canQuitAlliance(1)==false then
                    do return end
                end
            end

            if tonumber(allianceVoApi:getSelfAlliance().role)==2 and SizeOfTable(allianceMemberVoApi:getMemberTab())>1 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_wufatuichuTip"),30)

                do
                    return
                end
            elseif tonumber(allianceVoApi:getSelfAlliance().role)==2 and SizeOfTable(allianceMemberVoApi:getMemberTab())==1 then
                
                    allianceSmallDialog:showOKDialog(leaveAlliance,getlocal("alliance_tuanzhangtuichuSureOK"),self.layerNum+1)


            else
                    allianceSmallDialog:showOKDialog(leaveAlliance,getlocal("alliance_tuichuok"),self.layerNum+1)

            end

        end

      local sNormal =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
      local sSelected =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue2.png",rect,nilFunc)
      local sDisabled =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
      sNormal:setContentSize(CCSizeMake(widthButton,60))
      sSelected:setContentSize(CCSizeMake(widthButton,60))
      sDisabled:setContentSize(CCSizeMake(widthButton,60))

      local item = CCMenuItemSprite:create(sNormal, sSelected, sDisabled)  
      item:registerScriptTapHandler(leaveSureAndCancel)

      local titleLb=GetTTFLabel(getlocal("alliance_scene_quit_alliance_title"),28)
      titleLb:setAnchorPoint(ccp(0.5,0.5))
      titleLb:setPosition(getCenterPoint(item))
      item:addChild(titleLb)

      self.sendMenu = CCMenu:createWithItem(item)
      self.sendMenu:setPosition(ccp(width/2-100,noticeBg:getPositionY()-noticeBg:getContentSize().height-110))

      -- self.settingsBtn=CCMenu:createWithItem(settingsItem)
      -- self.settingsBtn:setPosition(ccp(width/2,80))
      self.sendMenu:setTouchPriority(-(self.layerNum-1)*20-4)
      self.bgLayer1:addChild(self.sendMenu)


  end
    if self.settingsBtn then
        if tostring(alliance.role)=="1" or tostring(alliance.role)=="2" then
            --self.settingsBtn:setVisible(true)
            --self.settingsBtn:setEnabled(true)
            self.settingsBtn:setPosition(ccp(width/2+100,noticeBg:getPositionY()-noticeBg:getContentSize().height-110))
            --self.sendMenu:setPosition(ccp(width/2-100,noticeBg:getPositionY()-noticeBg:getContentSize().height-110))
            self.settingsBtnPosition=ccp(self.settingsBtn:getPositionX(),self.settingsBtn:getPositionY())
            --self.sendMenuPosition=ccp(self.sendMenu:getPositionX(),self.sendMenu:getPositionY())

        else
            --self.settingsBtn:setVisible(false)
            --self.settingsBtn:setEnabled(false)
            self.settingsBtn:setPosition(ccp(3000,0))
            --self.sendMenu:setPosition(ccp(3000,0))
        end
    end

    self:addClanplayBtn()

    local widthButton = 400
    -- local function allianceShopCallBcak()
    --     allianceShopVoApi:showShopDialog(self.layerNum+1)
    -- end
    -- local function nilFunc()
        
    -- end

    -- local rect = CCRect(44,33,1,1)
    -- local sNormal =LuaCCScale9Sprite:createWithSpriteFrameName("btnYellow1.png",rect,nilFunc)
    -- local sSelected =LuaCCScale9Sprite:createWithSpriteFrameName("btnYellow2.png",rect,nilFunc)
    -- local sDisabled =LuaCCScale9Sprite:createWithSpriteFrameName("btnYellow1.png",rect,nilFunc)
    -- sNormal:setContentSize(CCSizeMake(widthButton,60))
    -- sSelected:setContentSize(CCSizeMake(widthButton,60))
    -- sDisabled:setContentSize(CCSizeMake(widthButton,60))

    -- local item = CCMenuItemSprite:create(sNormal, sSelected, sDisabled)  
    -- item:registerScriptTapHandler(allianceShopCallBcak)

    -- local titleLb=GetTTFLabel(getlocal("allianceShop_title"),28)
    -- titleLb:setAnchorPoint(ccp(0.5,0.5))
    -- titleLb:setPosition(getCenterPoint(item))
    -- item:addChild(titleLb)

    -- if(base.ifAllianceShopOpen==1)then
    --     local menu = CCMenu:createWithItem(item)
    --     menu:setPosition(ccp(width/2,lbhight-225))
    --     menu:setTouchPriority(-(self.layerNum-1)*20-2)
    --     self.bgLayer1:addChild(menu, 3)
    -- end

    local function changeName( ... )
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      PlayEffect(audioCfg.mouseClick)
      mergerServersChangeNameDialog:create(self.layerNum+1,getlocal("alliance_changeName"),getlocal("alliance_changeContent",{getlocal("alliance_list_scene_name"),getlocal("alliance_list_scene_name"),getlocal("alliance_list_scene_name")}),2)
    end

    self.changeNameItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",changeName,nil,getlocal("changename"),28)
    self.changeNameItem:setScale(0.6)
    self.changeNameItem:setAnchorPoint(ccp(1,1))
    local changeNameMenu=CCMenu:createWithItem(self.changeNameItem);
    changeNameMenu:setPosition(ccp(width-50,height-heightSpace))
    changeNameMenu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer1:addChild(changeNameMenu)

    if tostring(alliance.role)=="2" and string.find(alliance.name,"@")~=nil then
      self.changeNameItem:setEnabled(true)
      self.changeNameItem:setVisible(true)
    else
      self.changeNameItem:setEnabled(false)
      self.changeNameItem:setVisible(false)
    end


  self.bgLayer:addChild(self.bgLayer1,2)
end
-- function allianceDialogInfoTab:initTabLayer2()

--     self.bgLayer2=CCLayer:create()
--     self.bgLayer:addChild(self.bgLayer2,2)
    
--     self:initTableView2()

--     self.bgLayer2:setVisible(false)
--     self.bgLayer2:setPosition(ccp(939393,0))

-- end

--阿拉伯聊天认证
function allianceDialogInfoTab:addClanplayBtn()
    -- if base.clanUserID~=nil and base.clanUserID~="" then
    if G_curPlatName()=="androidarab" and G_Version>=13 then
        if self.clanplayBtn==nil then
            local function clanplayHandler( ... )
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                G_authclanplay()
            end
            self.clanplayBtn=LuaCCSprite:createWithSpriteFrameName("clanPlayIcon.png",clanplayHandler)
            self.clanplayBtn:setPosition(ccp(G_VisibleSizeWidth-190,90))
            self.clanplayBtn:setTouchPriority(-(self.layerNum-1)*20-4)
            self.bgLayer1:addChild(self.clanplayBtn,1)
        end
        if self.settingsBtn and self.settingsBtn:getPositionX()~=3000 then
            self.settingsBtn:setPosition(ccp(self.bgLayer1:getContentSize().width/2,self.settingsBtn:getPositionY()))
            if self.sendMenu and self.sendMenu:getPositionX()~=3000 then
                self.sendMenu:setPosition(ccp(self.bgLayer1:getContentSize().width/2-200,self.sendMenu:getPositionY()))
            end
            self.clanplayBtn:setPositionX(G_VisibleSizeWidth-120)
        end
    end
end

function allianceDialogInfoTab:initTabLayer2()
    self.tableMemberTb1=allianceMemberVoApi:getMemberTab()
    self.tableMemberTb2=allianceMemberVoApi:getMemberTabByDonate()
    self.memberCellTb={}
    self.bgLayer2=CCLayer:create();
    local lbSize=22
    local lbHeight=230
    local rankLb=GetTTFLabel(getlocal("alliance_list_scene_rank"),lbSize)
    rankLb:setAnchorPoint(ccp(0.5,0.5))
    rankLb:setPosition(ccp(83,G_VisibleSizeHeight-lbHeight))
    rankLb:setColor(G_ColorGreen)
    self.bgLayer2:addChild(rankLb)
    
    local memberLb=GetTTFLabel(getlocal("alliance_scene_member_list"),lbSize)
    memberLb:setAnchorPoint(ccp(0.5,0.5))
    memberLb:setPosition(ccp(200,G_VisibleSizeHeight-lbHeight))
    memberLb:setColor(G_ColorGreen)
    self.bgLayer2:addChild(memberLb)

    
    local dutyLb=GetTTFLabel(getlocal("alliance_scene_member_duty"),lbSize)
    dutyLb:setAnchorPoint(ccp(0.5,0.5))
    dutyLb:setPosition(ccp(296,G_VisibleSizeHeight-lbHeight))
    dutyLb:setColor(G_ColorGreen)
    self.bgLayer2:addChild(dutyLb)

    local levelLb=GetTTFLabel(getlocal("RankScene_level"),lbSize)
    levelLb:setAnchorPoint(ccp(0.5,0.5))
    levelLb:setPosition(ccp(370,G_VisibleSizeHeight-lbHeight))
    levelLb:setColor(G_ColorGreen)
    self.bgLayer2:addChild(levelLb)
    
    local attackLb=GetTTFLabelWrap(getlocal("showAttackRank"),lbSize,CCSizeMake(80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    attackLb:setAnchorPoint(ccp(0.5,0.5))
    attackLb:setPosition(ccp(457,G_VisibleSizeHeight-lbHeight+(attackLb:getContentSize().height-levelLb:getContentSize().height)/2))
    attackLb:setColor(G_ColorGreen)
    self.bgLayer2:addChild(attackLb)
    
    local operatorLb=GetTTFLabel(getlocal("alliance_list_scene_operator"),lbSize)
    operatorLb:setAnchorPoint(ccp(0.5,0.5))
    operatorLb:setPosition(ccp(542+operatorLb:getContentSize().width/4,G_VisibleSizeHeight-lbHeight))
    operatorLb:setColor(G_ColorGreen)
    self.bgLayer2:addChild(operatorLb)
    
    local amaxnum
    if(allianceVoApi:getSelfAlliance() and allianceVoApi:getSelfAlliance().maxnum)then
        amaxnum=allianceVoApi:getSelfAlliance().maxnum
    else
        amaxnum=playerCfg["allianceMember"][allianceVoApi:getSelfAlliance().level]
    end
    self.memberNumLb=GetTTFLabel(getlocal("alliance_memberNum",{allianceVoApi:getSelfAlliance().num,amaxnum}),30)
    self.memberNumLb:setAnchorPoint(ccp(0,0.5))
    self.memberNumLb:setPosition(ccp(50,60))
    self.memberNumLb:setTag(99)
    self.bgLayer2:addChild(self.memberNumLb)

      local function sendEmail()
          PlayEffect(audioCfg.mouseClick)
          self:sendEmail()
      end
      local widthButton = 260
      local rect = CCRect(44,33,1,1)
      local function nilFunc()
        
      end
      local sNormal =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
      local sSelected =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue2.png",rect,nilFunc)
      local sDisabled =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
      sNormal:setContentSize(CCSizeMake(widthButton,60))
      sSelected:setContentSize(CCSizeMake(widthButton,60))
      sDisabled:setContentSize(CCSizeMake(widthButton,60))

      local item = CCMenuItemSprite:create(sNormal, sSelected, sDisabled)  
      item:registerScriptTapHandler(sendEmail)

      local titleLb=GetTTFLabel(getlocal("alliance_send_email"),28)
      titleLb:setAnchorPoint(ccp(0.5,0.5))
      titleLb:setPosition(getCenterPoint(item))
      item:addChild(titleLb)

      self.sendEmailMenu = CCMenu:createWithItem(item)
      self.sendEmailMenu:setPosition(ccp(480,66))

      -- self.settingsBtn=CCMenu:createWithItem(settingsItem)
      -- self.settingsBtn:setPosition(ccp(width/2,80))
      self.sendEmailMenu:setTouchPriority(-(self.layerNum-1)*20-4)
      self.bgLayer2:addChild(self.sendEmailMenu)
      self.sendEmailMenuPosition=ccp(self.sendEmailMenu:getPositionX(),self.sendEmailMenu:getPositionY())
    if tostring(allianceVoApi:getSelfAlliance().role)~="2" or tostring(allianceVoApi:getSelfAlliance().role)~="1" then
       self.sendEmailMenu:setPosition(ccp(3000,0))
    end

    self:initTableView1()
    self.bgLayer:addChild(self.bgLayer2,2)
    self.bgLayer2:setVisible(false)
    self.bgLayer2:setPosition(ccp(939393,0))
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceDialogInfoTab:eventHandler(handler,fn,idx,cel)
if fn=="numberOfCellsInTableView" then
            
           local num=0;
            num=SizeOfTable(self.tableMemberTb1)

           return num

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
            tmpSize=CCSizeMake(620,70)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
        
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end
       
       if idx==0 then
           local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png");
           --bgSp:setAnchorPoint(ccp(0,0));
           bgSp:setPosition(ccp(310,35));
           bgSp:setScaleY(60/bgSp:getContentSize().height)
           bgSp:setScaleX(1200/bgSp:getContentSize().width)
           cell:addChild(bgSp)
       end

       
       self.memberCellTb[idx+1]=cell
       local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
       lineSp:setAnchorPoint(ccp(0,0));
       lineSp:setPosition(ccp(0,0));
       cell:addChild(lineSp,1)

        local lbSize=25
        local lbHeight=35
        local lbWidth=30
        local lbColor=G_ColorWhite
        local loginTime=tonumber(self.tableMemberTb1[idx+1].logined_at)
        if  tonumber(base.serverTime)-loginTime>24*60*60*7 then
            lbColor=G_ColorGray
        end

        local rankLb=GetTTFLabel(self.tableMemberTb1[idx+1].rank2,lbSize)
        rankLb:setPosition(ccp(87-lbWidth,lbHeight))
        cell:addChild(rankLb)
        rankLb:setColor(lbColor)

        
        local memberLb=GetTTFLabel(self.tableMemberTb1[idx+1].name,lbSize)
        memberLb:setPosition(ccp(203-lbWidth,lbHeight))
        cell:addChild(memberLb)
        memberLb:setColor(lbColor)
        
        local roleSp=nil
        local roleNum=tonumber(self.tableMemberTb1[idx+1].role)
        if roleNum==0 then
            roleSp=CCSprite:createWithSpriteFrameName("soldierIcon.png");
        elseif roleNum==1 then
            roleSp=CCSprite:createWithSpriteFrameName("deputyHead.png");
        elseif roleNum==2 then
            roleSp=CCSprite:createWithSpriteFrameName("positiveHead.png");
        end
        --[[
        local roleMember="alliance_role"..self.tableMemberTb1[idx+1].role
        local dutyLb=GetTTFLabel(getlocal(roleMember),lbSize)
        ]]
        roleSp:setPosition(ccp(300-lbWidth,lbHeight))
        cell:addChild(roleSp)
        roleSp:setTag(101)

        local levelLb=GetTTFLabel(self.tableMemberTb1[idx+1].level,lbSize)
        levelLb:setPosition(ccp(372-lbWidth,lbHeight))
        cell:addChild(levelLb)
        levelLb:setTag(102)
        levelLb:setColor(lbColor)
        
        local attackLb=GetTTFLabel(FormatNumber(self.tableMemberTb1[idx+1].fight),lbSize)
        attackLb:setPosition(ccp(458-lbWidth,lbHeight))
        cell:addChild(attackLb)
        attackLb:setTag(103)
        attackLb:setColor(lbColor)
        
        local function checkMember()
                if self.tv1:getIsScrolled()==true then
                        do
                            return
                        end
                end
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
            allianceSmallDialog:showMember(getlocal("alliance_member_setting_title"),true,self.tableMemberTb1[idx+1],self.layerNum+1,self.parentDialog,self.tv1)
        end
        local checkItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",checkMember,nil,getlocal("alliance_list_check_info"),28)
        checkItem:setScale(0.6)
        local checkMenu=CCMenu:createWithItem(checkItem);
        checkMenu:setPosition(ccp(G_VisibleSizeWidth-checkItem:getContentSize().width/2-30,lbHeight))
        checkMenu:setTouchPriority(-(self.layerNum-1)*20-2);
        cell:addChild(checkMenu)

       return cell;

       elseif fn=="ccTouchBegan" then
           self.isMoved=false
           return true
       elseif fn=="ccTouchMoved" then
           self.isMoved=true
       elseif fn=="ccTouchEnded"  then
           
       elseif fn=="ccScrollEnable" then
           if newGuidMgr:isNewGuiding()==true then
                return 0
           else
                return 1
           end
        end

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceDialogInfoTab:eventHandler2(handler,fn,idx,cel)
if fn=="numberOfCellsInTableView" then
            
           local num=0;
            num=SizeOfTable(self.tableMemberTb2)

           return num

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
            tmpSize=CCSizeMake(620,70)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
        
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end
       
       if idx==0 then
           local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png");
           --bgSp:setAnchorPoint(ccp(0,0));
           bgSp:setPosition(ccp(310,35));
           bgSp:setScaleY(60/bgSp:getContentSize().height)
           bgSp:setScaleX(1200/bgSp:getContentSize().width)
           cell:addChild(bgSp)
       end

       
       self.memberCellTb[idx+1]=cell
       local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
       lineSp:setAnchorPoint(ccp(0,0));
       lineSp:setPosition(ccp(0,0));
       cell:addChild(lineSp,1)

        local lbSize=25
        local lbHeight=35
        local lbWidth=30
        local lbColor=G_ColorWhite
        local loginTime=tonumber(self.tableMemberTb2[idx+1].logined_at)
        if  tonumber(base.serverTime)-loginTime>24*60*60*7 then
            lbColor=G_ColorGray
        end

        local rankLb=GetTTFLabel(self.tableMemberTb2[idx+1].rank3,lbSize)
        rankLb:setPosition(ccp(87-lbWidth,lbHeight))
        cell:addChild(rankLb)
        rankLb:setColor(lbColor)

        local memberLb=GetTTFLabel(self.tableMemberTb2[idx+1].name,lbSize)
        memberLb:setPosition(ccp(203-lbWidth+30,lbHeight))
        cell:addChild(memberLb)
        memberLb:setColor(lbColor)
        
        local roleSp=nil
        local roleNum=tonumber(self.tableMemberTb2[idx+1].role)
        if roleNum==0 then
            roleSp=CCSprite:createWithSpriteFrameName("soldierIcon.png");
        elseif roleNum==1 then
            roleSp=CCSprite:createWithSpriteFrameName("deputyHead.png");
        elseif roleNum==2 then
            roleSp=CCSprite:createWithSpriteFrameName("positiveHead.png");
        end
        --[[
        local roleMember="alliance_role"..self.tableMemberTb2[idx+1].role
        local dutyLb=GetTTFLabel(getlocal(roleMember),lbSize)
        ]]
        roleSp:setPosition(ccp(300-lbWidth+75,lbHeight))
        cell:addChild(roleSp)
        roleSp:setTag(101)
       
        local levelLb=GetTTFLabel(self.tableMemberTb2[idx+1].level,lbSize)
        levelLb:setPosition(ccp(372-lbWidth+80,lbHeight))
        cell:addChild(levelLb)
        levelLb:setTag(102)
        levelLb:setColor(lbColor)
        
        local weekDonate
        if G_getWeekDay(self.tableMemberTb2[idx+1].donateTime,base.serverTime) then
            weekDonate=FormatNumber(tonumber(self.tableMemberTb2[idx+1].weekDonate))
        else
            weekDonate=0
        end
        local donateLb1=GetTTFLabel(weekDonate,lbSize)
        donateLb1:setPosition(ccp(468-lbWidth+90,lbHeight))
        cell:addChild(donateLb1)
        donateLb1:setTag(103)
        donateLb1:setColor(lbColor)
        
        -- local donateLb2=GetTTFLabel(FormatNumber(self.tableMemberTb2[idx+1].donate),lbSize)
        -- donateLb2:setPosition(ccp(562-lbWidth,lbHeight))
        -- cell:addChild(donateLb2)
        -- donateLb2:setTag(103)
        -- donateLb2:setColor(lbColor)


       return cell;

       elseif fn=="ccTouchBegan" then
           self.isMoved=false
           return true
       elseif fn=="ccTouchMoved" then
           self.isMoved=true
       elseif fn=="ccTouchEnded"  then
           
       elseif fn=="ccScrollEnable" then
           if newGuidMgr:isNewGuiding()==true then
                return 0
           else
                return 1
           end
        end

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceDialogInfoTab:eventHandler3(handler,fn,idx,cel)
if fn=="numberOfCellsInTableView" then
            
           local num=0;
           num=SizeOfTable(allianceApplicantVoApi:getApplicantTab())
           return num

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
            tmpSize=CCSizeMake(620,70)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
        
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end
       local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
       lineSp:setAnchorPoint(ccp(0,0));
       lineSp:setPosition(ccp(0,0));
       cell:addChild(lineSp,1)

        local lbSize=25
        local lbHeight=35
        local lbWidth=30
        
        local memberLb=GetTTFLabel(allianceApplicantVoApi:getApplicantTab()[idx+1].name,lbSize)
        memberLb:setPosition(ccp(107-lbWidth,lbHeight))
        cell:addChild(memberLb)
        
        local levelLb=GetTTFLabel(allianceApplicantVoApi:getApplicantTab()[idx+1].level,lbSize)
        levelLb:setPosition(ccp(213-lbWidth,lbHeight))
        cell:addChild(levelLb)

        local attackLb=GetTTFLabel(FormatNumber(allianceApplicantVoApi:getApplicantTab()[idx+1].fight),lbSize)
        attackLb:setPosition(ccp(294-lbWidth,lbHeight))
        cell:addChild(attackLb)
        
        local function acceptMember()
            if self.tv3:getIsScrolled()==true then
                        do
                            return
                        end
            end
            
            local function acceptCallBack(fn,data)

                -- local sData=G_Json.decode(tostring(data))
                base:cancleWait()
                base:cancleNetWait()
                -- if sData.ret==-8010 then --已加入别人军团后弹出面板并前台删除数据
                --     local codeStr="backstage"..RemoveFirstChar(sData.ret)
                --     smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt")..sData.ret,getlocal(codeStr),nil,8,nil,sureCallBackHandler)
                --     local mUid=allianceApplicantVoApi:getApplicantTab()[idx+1].uid
                --     allianceApplicantVoApi:deleteApplicantByUid(mUid)
                --     self.tv3:reloadData()
                --     self:refreshTips(4)
                --     do
                --         return
                --     end
                -- end
                

                local ret,sData=base:checkServerData(data)
                if ret==true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),30)
                    local alliance=allianceVoApi:getSelfAlliance()
                    local params = {allianceName=alliance.name}
                    if sData.data.cPlace then
                        params.x=sData.data.cPlace[1]
                        params.y=sData.data.cPlace[2]
                        params.baseUid=sData.data.cPlace[3]
                    end
                    chatVoApi:sendUpdateMessage(7,params)
                    --[[
                    local mUid=allianceApplicantVoApi:getApplicantTab()[idx+1].uid
                    allianceApplicantVoApi:delseteApplicantByUid(mUid)
                    ]]
                    self.tv3:reloadData()
                    G_isRefreshAllianceApplicantTb=true
                    --工会活动刷新数据
                    activityVoApi:updateAc("fbReward")
                    activityVoApi:updateAc("allianceLevel")
                    activityVoApi:updateAc("allianceFight")
                    G_getAlliance()
                    self:refreshTips(4)
                elseif sData.ret==-8010 then --已加入别人军团后弹出面板并前台删除数据
                    -- local codeStr="backstage"..RemoveFirstChar(sData.ret)
                    -- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt")..sData.ret,getlocal(codeStr),nil,8,nil,sureCallBackHandler)
                    local mUid=allianceApplicantVoApi:getApplicantTab()[idx+1].uid
                    allianceApplicantVoApi:deleteApplicantByUid(mUid)
                    self.tv3:reloadData()
                    self:refreshTips(4)
                    do
                        return
                    end
                end
            end
        socketHelper:allianceAccept(allianceVoApi:getSelfAlliance().aid,allianceApplicantVoApi:getApplicantTab()[idx+1].uid,acceptCallBack)

        end
        local acceptItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",acceptMember,nil,getlocal("accpet"),28)
        acceptItem:setScale(0.6)
        local acceptMenu=CCMenu:createWithItem(acceptItem);
        acceptMenu:setPosition(ccp(G_VisibleSizeWidth-acceptItem:getContentSize().width/2-40,lbHeight))
        acceptMenu:setTouchPriority(-(self.layerNum-1)*20-2);
        cell:addChild(acceptMenu)

        local function refuseMember()
            if self.tv3:getIsScrolled()==true then
                        do
                            return
                        end
            end
            
            local function refuseCallBack(fn,data)
                if base:checkServerData(data)==true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),30)
                    self.tv3:reloadData()
                    self:refreshTips(4)
                end
            end
            socketHelper:allianceDeny(allianceVoApi:getSelfAlliance().aid,allianceApplicantVoApi:getApplicantTab()[idx+1].uid,refuseCallBack)
        end
        local refuseItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",refuseMember,nil,getlocal("alliance_request_refuse"),28)
        refuseItem:setScale(0.6)
        local refuseMenu=CCMenu:createWithItem(refuseItem);
        refuseMenu:setPosition(ccp(G_VisibleSizeWidth-refuseItem:getContentSize().width/2-160,lbHeight))
        refuseMenu:setTouchPriority(-(self.layerNum-1)*20-2);
        cell:addChild(refuseMenu)

       return cell;

       elseif fn=="ccTouchBegan" then
           self.isMoved=false
           return true
       elseif fn=="ccTouchMoved" then
           self.isMoved=true
       elseif fn=="ccTouchEnded"  then
           
       elseif fn=="ccScrollEnable" then
           if newGuidMgr:isNewGuiding()==true then
                return 0
           else
                return 1
           end
        end

end

function allianceDialogInfoTab:initTableView1()

    local rect = CCRect(0, 0, 50, 50);
  local capInSet = CCRect(20, 20, 10, 10);
  local function click(hd,fn,idx)
  end
  -- self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,click)
  -- self.tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345))
  -- self.tvBg:ignoreAnchorPointForPosition(false)
  -- self.tvBg:setAnchorPoint(ccp(0.5,0))
  -- --self.tvBg:setIsSallow(false)
  -- --self.tvBg:setTouchPriority(-(self.layerNum-1)*20-2)
  -- self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,100))
  -- self.bgLayer:addChild(self.tvBg)

    local function callBack1(...)
       return self:eventHandler(...)
    end
    local hd1= LuaEventHandler:createHandler(callBack1)
    local height=0;
    self.tv1=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345),nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv1:setPosition(ccp(30,100))
    self.bgLayer2:addChild(self.tv1)
    self.tv1:setMaxDisToBottomOrTop(120)
end


function allianceDialogInfoTab:initTabLayer3()
    self.bgLayer3=CCLayer:create()
    self.bgLayer:addChild(self.bgLayer3,2)

    local lbSize=22
    local lbHeight=230
    local rankLb=GetTTFLabel(getlocal("alliance_list_scene_rank"),lbSize)
    rankLb:setAnchorPoint(ccp(0.5,0.5))
    rankLb:setPosition(ccp(83,G_VisibleSizeHeight-lbHeight))
    rankLb:setColor(G_ColorGreen)
    self.bgLayer3:addChild(rankLb)
    
    local memberLb=GetTTFLabel(getlocal("alliance_scene_member_list"),lbSize)
    memberLb:setAnchorPoint(ccp(0.5,0.5))
    memberLb:setPosition(ccp(160+30+40,G_VisibleSizeHeight-lbHeight))
    memberLb:setColor(G_ColorGreen)
    self.bgLayer3:addChild(memberLb)

    
    local dutyLb=GetTTFLabel(getlocal("alliance_scene_member_duty"),lbSize)
    dutyLb:setAnchorPoint(ccp(0.5,0.5))
    -- dutyLb:setPosition(ccp(276,G_VisibleSizeHeight-lbHeight))
    dutyLb:setPosition(ccp(350+25,G_VisibleSizeHeight-lbHeight))
    dutyLb:setColor(G_ColorGreen)
    self.bgLayer3:addChild(dutyLb)

    local levelLb=GetTTFLabel(getlocal("RankScene_level"),lbSize)
    levelLb:setAnchorPoint(ccp(0.5,0.5))
    levelLb:setPosition(ccp(430+20,G_VisibleSizeHeight-lbHeight))
    levelLb:setColor(G_ColorGreen)
    self.bgLayer3:addChild(levelLb)

    local attackLb=GetTTFLabelWrap(getlocal("alliance_donateWeek"),lbSize,CCSizeMake(lbSize*5+20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    attackLb:setAnchorPoint(ccp(0.5,0.5))
    attackLb:setPosition(ccp(555,G_VisibleSizeHeight-lbHeight+attackLb:getContentSize().height/2-levelLb:getContentSize().height/2))
    attackLb:setColor(G_ColorGreen)
    self.bgLayer3:addChild(attackLb)
    
    
    local donateLb=GetTTFLabelWrap(getlocal("alliance_donateDes"),25,CCSizeMake(30*18,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    donateLb:setPosition(ccp(G_VisibleSizeWidth/2,65))
    self.bgLayer3:addChild(donateLb)

    
    self:initTableView3()
    self.bgLayer3:setVisible(false)
    self.bgLayer3:setPosition(ccp(939393,0))

end
function allianceDialogInfoTab:initTableView3()
    local function callBack2(...)
       return self:eventHandler2(...)
    end
    local hd2= LuaEventHandler:createHandler(callBack2)
    self.tv2=LuaCCTableView:createWithEventHandler(hd2,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-85-260),nil)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv2:setPosition(ccp(30,100))
    self.bgLayer3:addChild(self.tv2)
    self.tv2:setMaxDisToBottomOrTop(120)

end

function allianceDialogInfoTab:initTabLayer4()
    self.bgLayer4=CCLayer:create()
    self.bgLayer:addChild(self.bgLayer4,2)

    local lbSize=22
    local lbHeight=230

    self.noApplyPlayerLb=GetTTFLabelWrap(getlocal("alliance_noapply"),30,CCSizeMake(30*20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    self.noApplyPlayerLb:setPosition(ccp(self.bgLayer3:getContentSize().width/2,self.bgLayer3:getContentSize().height/2))
    self.noApplyPlayerLb:setColor(G_ColorGray)
    self.bgLayer4:addChild(self.noApplyPlayerLb)
    if SizeOfTable(allianceApplicantVoApi:getApplicantTab())==0 then
        self.noApplyPlayerLb:setVisible(true)
    else
        self.noApplyPlayerLb:setVisible(false)
    end


    local memberLb=GetTTFLabel(getlocal("alliance_scene_member_list"),lbSize)
    memberLb:setAnchorPoint(ccp(0,0.5))
    memberLb:setPosition(ccp(67,G_VisibleSizeHeight-lbHeight))
    memberLb:setColor(G_ColorGreen)
    self.bgLayer4:addChild(memberLb)

    local levelLb=GetTTFLabel(getlocal("RankScene_level"),lbSize)
    levelLb:setAnchorPoint(ccp(0,0.5))
    levelLb:setPosition(ccp(191,G_VisibleSizeHeight-lbHeight))
    levelLb:setColor(G_ColorGreen)
    self.bgLayer4:addChild(levelLb)
    
    local attackLb=GetTTFLabel(getlocal("showAttackRank"),lbSize)
    attackLb:setAnchorPoint(ccp(0,0.5))
    attackLb:setPosition(ccp(265,G_VisibleSizeHeight-lbHeight))
    attackLb:setColor(G_ColorGreen)
    self.bgLayer4:addChild(attackLb)
    
    local operatorLb=GetTTFLabel(getlocal("alliance_list_scene_operator"),lbSize)
    operatorLb:setAnchorPoint(ccp(0,0.5))
    operatorLb:setPosition(ccp(471,G_VisibleSizeHeight-lbHeight))
    operatorLb:setColor(G_ColorGreen)
    self.bgLayer4:addChild(operatorLb)
    
    local function refuseAllMember()
        local function refuseAllCallBack(fn,data)
            if base:checkServerData(data)==true then
                for k,v in pairs(allianceApplicantVoApi:getApplicantTab()) do
                    if v~=nil and v.uid~=nil then
                        local mUid=v.uid
                        allianceApplicantVoApi:deleteApplicantByUid(mUid)
                    end
                end
                self.tv3:reloadData()
                self:refreshTips(4)
            end
        end
        socketHelper:allianceDeny(allianceVoApi:getSelfAlliance().aid,nil,refuseAllCallBack)
    end

    if G_getCurChoseLanguage()=="in" then
        self.refuseButton = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",refuseAllMember,nil,getlocal("alliance_refuse_all"),23)
        self.refuseButton:setScale(1.0)
    else
        self.refuseButton = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",refuseAllMember,nil,getlocal("alliance_refuse_all"),28)
        self.refuseButton:setScale(0.9)
    end
    local checkMenu=CCMenu:createWithItem(self.refuseButton);
    checkMenu:setPosition(ccp(G_VisibleSizeWidth/2,60))
    checkMenu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer4:addChild(checkMenu)
    if SizeOfTable(allianceApplicantVoApi:getApplicantTab())==0 then
        self.refuseButton:setEnabled(false)
    end


    self:initTableView4()
    

    self.bgLayer4:setVisible(false)
    self.bgLayer4:setPosition(ccp(939393,0))

end
function allianceDialogInfoTab:initTableView4()
   local function callBack3(...)
       return self:eventHandler3(...)
    end
    local hd3= LuaEventHandler:createHandler(callBack3)
    self.tv3=LuaCCTableView:createWithEventHandler(hd3,CCSizeMake(self.bgLayer:getContentSize().width-10,G_VisibleSize.height-85-260),nil)
    self.tv3:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv3:setPosition(ccp(30,100))
    self.bgLayer4:addChild(self.tv3)
    self.tv3:setMaxDisToBottomOrTop(120)

end

function allianceDialogInfoTab:initTab(tabTb)
   local tabBtn=CCMenu:create()
   local tabIndex=0
   local tabBtnItem;
   if tabTb~=nil then
       for k,v in pairs(tabTb) do

           tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
           
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))

           local function tabClick(idx)
               return self:tabClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabClick)
           
           local lb=GetTTFLabel(v,24)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
       lb:setTag(31)
       
       
        local numHeight=25
      local iconWidth=36
      local iconHeight=36
        local newsNumLabel = GetTTFLabel("0",numHeight)
        newsNumLabel:setPosition(ccp(newsNumLabel:getContentSize().width/2+5,iconHeight/2))
        newsNumLabel:setTag(11)
          local capInSet1 = CCRect(17, 17, 1, 1)
          local function touchClick()
          end
          local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
      if newsNumLabel:getContentSize().width+10>iconWidth then
        iconWidth=newsNumLabel:getContentSize().width+10
      end
          newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
        newsIcon:ignoreAnchorPointForPosition(false)
        newsIcon:setAnchorPoint(CCPointMake(1,0.5))
          newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width+5,tabBtnItem:getContentSize().height-15))
          newsIcon:addChild(newsNumLabel,1)
      newsIcon:setTag(10)
        newsIcon:setVisible(false)
        tabBtnItem:addChild(newsIcon)
       
       --local lockSp=CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
           local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
       lockSp:setAnchorPoint(CCPointMake(0,0.5))
       lockSp:setPosition(ccp(10,tabBtnItem:getContentSize().height/2))
       lockSp:setScaleX(0.7)
       lockSp:setScaleY(0.7)
       tabBtnItem:addChild(lockSp,3)
       lockSp:setTag(30)
       lockSp:setVisible(false)
      
           self.allTabs[k]=tabBtnItem
           tabBtn:addChild(tabBtnItem)
           tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
           tabBtnItem:setTag(tabIndex)
           tabIndex=tabIndex+1
       end
   end
   tabBtn:setPosition(0,0)
   self.bgLayer:addChild(tabBtn)


end
function allianceDialogInfoTab:tabClick(idx)

    PlayEffect(audioCfg.mouseClick)

    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
         else
            v:setEnabled(true)
         end
    end
    
    if self.selectedTabIndex==0 then
       self.bgLayer1:setVisible(true)
       self.bgLayer1:setPosition(ccp(0,0))
       
       self.bgLayer2:setVisible(false)
       self.bgLayer2:setPosition(ccp(10000,0))
       
       self.bgLayer3:setVisible(false)
       self.bgLayer3:setPosition(ccp(10000,0))

       self.bgLayer4:setVisible(false)
       self.bgLayer4:setPosition(ccp(10000,0))

    elseif self.selectedTabIndex==1 then
       self.bgLayer2:setVisible(true)
       self.bgLayer2:setPosition(ccp(0,0))
       
       self.bgLayer1:setVisible(false)
       self.bgLayer1:setPosition(ccp(10000,0))
       
       self.bgLayer3:setVisible(false)
       self.bgLayer3:setPosition(ccp(10000,0))

       self.bgLayer4:setVisible(false)
       self.bgLayer4:setPosition(ccp(10000,0))

    elseif self.selectedTabIndex==2 then
       self.bgLayer3:setVisible(true)
       self.bgLayer3:setPosition(ccp(0,0))
       
       self.bgLayer2:setVisible(false)
       self.bgLayer2:setPosition(ccp(10000,0))
       
       self.bgLayer1:setVisible(false)
       self.bgLayer1:setPosition(ccp(10000,0))

       self.bgLayer4:setVisible(false)
       self.bgLayer4:setPosition(ccp(10000,0))

    elseif self.selectedTabIndex==3 then

        self.bgLayer4:setVisible(true)
        self.bgLayer4:setPosition(ccp(0,0))

        self.bgLayer3:setVisible(false)
        self.bgLayer3:setPosition(ccp(10000,0))

        self.bgLayer2:setVisible(false)
        self.bgLayer2:setPosition(ccp(10000,0))

        self.bgLayer1:setVisible(false)
        self.bgLayer1:setPosition(ccp(10000,0))
    end

    --self.tv:reloadData()
end
function allianceDialogInfoTab:tick()
    --allianceMemberVoApi:getWeekDonate(uid)
    local alliance=allianceVoApi:getSelfAlliance()
    if alliance==nil then
      do return end
    end
    if allianceVoApi:getSelfAlliance() and tonumber(self.role)~=tonumber(allianceVoApi:getSelfAlliance().role) then
        if allianceVoApi:getSelfAlliance()~=nil and tonumber(allianceVoApi:getSelfAlliance().role)>0 then
            self.allTabs[4]:setVisible(true)
            self.allTabs[4]:setEnabled(true)

        else
            self:tabClick(0)
            self.allTabs[4]:setVisible(false)
            self.allTabs[4]:setEnabled(true)
        end
        self.role=allianceVoApi:getSelfAlliance().role
    end

    if allianceVoApi:isRefreshActiveData()==true then
      print("alliance.get........")
    end

    if self.selectedTabIndex==0 then
      -- local alliance=allianceVoApi:getSelfAlliance()
      -- if alliance then
      --       if self.settingsBtn then
      --           if tostring(alliance.role)=="1" or tostring(alliance.role)=="2" then
      --               --self.settingsBtn:setVisible(true)
      --               --self.settingsBtn:setEnabled(true)
      --               -- self.settingsBtn:setPosition(self.settingsBtnPosition)
      --               self.settingsBtn:setPosition(ccp(self.bgLayer1:getContentSize().width/2+100,self.refreshTab["noticeBg"]:getPositionY()-self.refreshTab["noticeBg"]:getContentSize().height-110))
      --               --self.sendMenu:setPosition(self.sendMenuPosition)

      --           else
      --               --self.settingsBtn:setVisible(false)
      --               --self.settingsBtn:setEnabled(false)
      --               self.settingsBtn:setPosition(ccp(3000,80))
      --               --self.sendMenu:setPosition(ccp(3000,80))
      --           end
      --       end
      --   if self.nameTab then
      --     local conditionStr=""
      --   if alliance.level_limit and alliance.level_limit>0 then
      --     conditionStr=conditionStr..getlocal("fightLevel",{alliance.level_limit})
      --   end
      --   if alliance.fight_limit and alliance.fight_limit>0 then
      --     if conditionStr=="" then
      --       conditionStr=conditionStr..getlocal("alliance_join_condition_value",{FormatNumber(alliance.fight_limit)})
      --     else
      --       conditionStr=conditionStr..getlocal("alliance_join_condition_and")..getlocal("alliance_join_condition_value",{FormatNumber(alliance.fight_limit)})
      --     end
      --   end
      --   if conditionStr=="" then
      --     conditionStr=getlocal("alliance_info_content")
      --   end
      --   local memberNum=0
      --   local memberTab=allianceMemberVoApi:getMemberTab()
      --   if memberTab then
      --     memberNum=SizeOfTable(memberTab)
      --   end
      --           local amaxnum=playerCfg["allianceMember"][allianceVoApi:getSelfAlliance().level]
      --   local valueTab={alliance.name,alliance.leaderName,alliance.rank,alliance.level,getlocal("scheduleChapter",{memberNum,amaxnum}),getlocal("alliance_apply"..alliance.type),conditionStr}
      --           if base.isAllianceWarSwitch==1 then
      --               valueTab={alliance.name,alliance.leaderName,alliance.rank,alliance.level,alliance.point,getlocal("scheduleChapter",{memberNum,amaxnum}),getlocal("alliance_apply"..alliance.type),conditionStr}
      --           end


      --   local lbHight = self.bgLayer:getContentSize().height-215
      --     for k,v in pairs(self.nameTab) do
      --       if tolua.cast(self.refreshNameTab[k],"CCLabelTTF"):getPositionY()~=lbHight then
      --        tolua.cast(self.refreshNameTab[k],"CCLabelTTF"):setPosition(ccp(65,lbHight))
      --      end
      --       local temphight = tolua.cast(self.refreshNameTab[k],"CCLabelTTF"):getContentSize().height
      --       if v then
      --         if v=="alliance_scene_email" then
      --           if allianceVoApi:canSendAllianceEmail() then
      --             self.refreshTab[v]:setEnabled(true)
      --             if self.refreshTab["sendMenu"]:getPositionY() ~= (lbHight-25) then
      --               self.refreshTab["sendMenu"]:setPosition(ccp(self.bgLayer1:getContentSize().width/2,lbHight-25))
      --             end
      --         else
      --             self.refreshTab[v]:setEnabled(false)
      --           end
      --       -- elseif v=="alliance_scene_member_num" then
      --       --  local memberNum=0
      --       --  local memberTab=allianceMemberVoApi:getMemberTab()
      --       --  if memberTab then
      --       --    memberNum=SizeOfTable(memberTab)
      --       --  end
      --       --  tolua.cast(self.refreshTab[v],"CCLabelTTF"):setString(getlocal("scheduleChapter",{memberNum,alliance.maxnum}))
      --       elseif valueTab[k] then
      --         tolua.cast(self.refreshTab[v],"CCLabelTTF"):setString(valueTab[k])
      --         if tolua.cast(self.refreshTab[v],"CCLabelTTF"):getPositionY()~=lbHight then
      --           tolua.cast(self.refreshTab[v],"CCLabelTTF"):setPosition(ccp(self.bgLayer1:getContentSize().width/2-50,lbHight))
      --         end
      --           if temphight< tolua.cast(self.refreshTab[v],"CCLabelTTF"):getContentSize().height then
      --             temphight = tolua.cast(self.refreshTab[v],"CCLabelTTF"):getContentSize().height
      --           end
      --         end
      --       end
      --       lbHight = lbHight -temphight -5
      --     end
      --     if self.refreshTab["alliance_noticeName"] then
      --       if self.refreshTab["alliance_noticeName"]:getPositionY()~=lbHight then
      --         tolua.cast(self.refreshTab["alliance_noticeName"],"CCLabelTTF"):setPosition(ccp(65,lbHight-5))
      --       end
      --       lbHight = lbHight - tolua.cast(self.refreshTab["alliance_noticeName"],"CCLabelTTF"):getContentSize().height
      --     end
      --     if self.refreshTab["noticeBg"]:getPositionY()~=lbHight then
      --       self.refreshTab["noticeBg"]:setPosition(ccp(self.bgLayer1:getContentSize().width/2,lbHight-5))
      --     end
      --     if self.refreshTab["alliance_notice"] then
      --       tolua.cast(self.refreshTab["alliance_notice"],"CCLabelTTF"):setString(alliance.notice)
      --     end
      --   end
      -- end



         local alliance=allianceVoApi:getSelfAlliance()
        if alliance then
        
        if self.changeNameItem then

            if tostring(alliance.role)=="2" and string.find(alliance.name,"@")~=nil then
              self.changeNameItem:setEnabled(true)
              self.changeNameItem:setVisible(true)
            else
              self.changeNameItem:setEnabled(false)
              self.changeNameItem:setVisible(false)
            end
        end


            if self.settingsBtn then
                if tostring(alliance.role)=="1" or tostring(alliance.role)=="2" then
                    self.settingsBtn:setPosition(ccp(self.bgLayer1:getContentSize().width/2+120,80))

                else
                    self.settingsBtn:setPosition(ccp(3000,80))
                end
            end
            self:addClanplayBtn()
            local conditionStr=""
            if alliance.level_limit and alliance.level_limit>0 then
              conditionStr=conditionStr..getlocal("fightLevel",{alliance.level_limit})
            end
            if alliance.fight_limit and alliance.fight_limit>0 then
              if conditionStr=="" then
                conditionStr=conditionStr..getlocal("alliance_join_condition_value",{FormatNumber(alliance.fight_limit)})
              else
                conditionStr=conditionStr..getlocal("alliance_join_condition_and")..getlocal("alliance_join_condition_value",{FormatNumber(alliance.fight_limit)})
              end
            end
            if conditionStr=="" then
              conditionStr=getlocal("alliance_info_content")
            end
            if self.conditionLb then
              self.conditionLb:setString(conditionStr)
            end
            if self.noticeValueLable then
               self.noticeValueLable:setString(alliance.notice)
            end
            if self.joinTypeLb  then
              self.joinTypeLb:setString(getlocal("alliance_apply"..alliance.type))
            end
            if self.myAllianceLv then
              self.myAllianceLv:setString(getlocal("fightLevel",{alliance.level}))
            end
            if self.myAllianceName then
              self.myAllianceName:setString(alliance.name)
            end
            if self.myAllianceLeader then
              self.myAllianceLeader:setString(getlocal("alliance_info_leader",{alliance.leaderName}))
            end
            if self.myAllianceAttack then
              self.myAllianceAttack:setString(FormatNumber(alliance.fight))
            end

            local memberNum=0
            local memberTab=allianceMemberVoApi:getMemberTab()
            if memberTab then
              memberNum=SizeOfTable(memberTab)
            end
            local amaxnum
            if(allianceVoApi:getSelfAlliance() and allianceVoApi:getSelfAlliance().maxnum)then
                amaxnum=allianceVoApi:getSelfAlliance().maxnum
            else
                amaxnum=playerCfg["allianceMember"][allianceVoApi:getSelfAlliance().level]
            end
            if self.myAllianceNum then
              self.myAllianceNum:setString(getlocal("scheduleChapter",{memberNum,amaxnum}))
            end
            if self.myAlliancePoint then
              self.myAlliancePoint:setString(FormatNumber(alliance.point))
            end
            if self.myAllianceRank then
              self.myAllianceRank:setString(FormatNumber(alliance.rank))
            end

            if self.activeLv then
              self.activeLv:setString(tostring(alliance.alevel))
            end

            local nowActive = alliance.apoint
            if allianceActiveCfg.allianceALevelPoint[alliance.alevel+1]==nil then
              allianceActiveCfg.allianceALevelPoint[alliance.alevel+1]=allianceActiveCfg.ActiveMaxPoint
            end
            local maxActive = allianceActiveCfg.allianceALevelPoint[alliance.alevel+1]

            local showActive = nowActive-allianceActiveCfg.allianceALevelPoint[alliance.alevel]
            local showMaxActive = maxActive-allianceActiveCfg.allianceALevelPoint[alliance.alevel]
             
            if self.timerSprite then
              local percentage = showActive/showMaxActive
              self.timerSprite:setPercentage(percentage*100)
            end
            self.activePerLb:setString(getlocal("scheduleChapter",{nowActive,maxActive}))
          end
    
        if base.allianceAcYouhua==1 then
            local canReward=self:getCanReward()
            if canReward==true then
                if self.rightsp then
                    self.rightsp:setVisible(false)
                end
                if self.lightBg then
                    self.lightBg:setVisible(true)
                end
                if self.lightBg1 then
                    self.lightBg1:setVisible(true)
                end
                if self.rewardBtn then
                    self.rewardBtn:setVisible(true)
                    self.rewardBtn:setEnabled(true)
                end
                if self.lbBg then
                    self.lbBg:setVisible(true)
                end
            else
                if self.rightsp then
                    self.rightsp:setVisible(true)
                end
                if self.lightBg then
                    self.lightBg:setVisible(false)
                end
                if self.lightBg1 then
                    self.lightBg1:setVisible(false)
                end
                if self.rewardBtn then
                    self.rewardBtn:setVisible(false)
                    self.rewardBtn:setEnabled(false)
                end
                if self.lbBg then
                    self.lbBg:setVisible(false)
                end
            end
        end
    elseif self.selectedTabIndex==1 then
        local alliance=allianceVoApi:getSelfAlliance()
        if alliance then
            if self.sendEmailMenu then
                if tostring(alliance.role)=="2" or tostring(alliance.role)=="1" then
                    --self.settingsBtn:setVisible(true)
                    --self.settingsBtn:setEnabled(true)
                    self.sendEmailMenu:setPosition(self.sendEmailMenuPosition)
                    --self.sendMenu:setPosition(self.sendMenuPosition)

                else
                    --self.settingsBtn:setVisible(false)
                    --self.settingsBtn:setEnabled(false)
                    self.sendEmailMenu:setPosition(ccp(3000,80))
                    --self.sendMenu:setPosition(ccp(3000,80))
                end
            end
        end

        
        if G_isRefreshAllianceMemberTb==true then
            self.tableMemberTb1=allianceMemberVoApi:getMemberTab()
            self.tv1:reloadData()
            G_isRefreshAllianceMemberTb=false
        end
        local amaxnum
        if(allianceVoApi:getSelfAlliance() and allianceVoApi:getSelfAlliance().maxnum)then
            amaxnum=allianceVoApi:getSelfAlliance().maxnum
        else
            amaxnum=playerCfg["allianceMember"][allianceVoApi:getSelfAlliance().level]
        end
        self.memberNumLb:setString(getlocal("alliance_memberNum",{SizeOfTable(self.tableMemberTb1),amaxnum}))
    elseif self.selectedTabIndex==2 then
        if G_isRefreshAllianceMemberTb==true then
            self.tableMemberTb2=allianceMemberVoApi:getMemberTabByDonate()
            self.tv2:reloadData()
            G_isRefreshAllianceMemberTb=false
        end

    elseif self.selectedTabIndex==3 then
        if G_isRefreshAllianceApplicantTb==true then
            self.tv3:reloadData()
            G_isRefreshAllianceApplicantTb=false
        end
        
        if SizeOfTable(allianceApplicantVoApi:getApplicantTab())==0 then
            self.refuseButton:setEnabled(false)
            self.noApplyPlayerLb:setVisible(true)
        else
            self.refuseButton:setEnabled(true)
            self.noApplyPlayerLb:setVisible(false)
        end
        


    end
    

end

--用户处理特殊需求,没有可以不写此方法
function allianceDialogInfoTab:doUserHandler()
    if self.selectedTabIndex==3 then
        if self.attackNumLb then
            local attackMaxNum=allianceFubenVoApi:getDailyAttackNum()
            local fubenVo=allianceFubenVoApi:getFuben()
            self.attackNumLb:setString(getlocal("alliance_fuben_attack_num",{fubenVo.attackCount,attackMaxNum}))
        end
    end
end

function allianceDialogInfoTab:sendEmail()
    if allianceVoApi:canSendAllianceEmail() then
      emailVoApi:showWriteEmailDialog(self.layerNum+1,getlocal("alliance_scene_email"),getlocal("alliance_scene_all_member"),nil,true)
    else
      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_email_num_max"),30)     
    end
end
--点击了cell或cell上某个按钮
function allianceDialogInfoTab:cellClick(idx)

    if self.tv2:getScrollEnable()==true and self.tv2:getIsScrolled()==false then
        if self.expandIdx2["k"..(idx-1000)]==nil then
                self.expandIdx2["k"..(idx-1000)]=idx-1000
                self.tv2:openByCellIndex(idx-1000,self.normalHeight2)
        else
            self.expandIdx2["k"..(idx-1000)]=nil
            self.tv2:closeByCellIndex(idx-1000,self.expandHeight2)
            self.requires[idx-1000]=nil
        end
    end

end

function allianceDialogInfoTab:setTipsVisibleByIdx(isVisible,idx,num)
    if self==nil then
        do
            return 
        end
    end
    local tabBtnItem=self.allTabs[idx]
    local temTabBtnItem=tolua.cast(tabBtnItem,"CCNode")
    local tipSp=temTabBtnItem:getChildByTag(10)
    if tipSp~=nil then
      if tipSp:isVisible()~=isVisible then
        tipSp:setVisible(isVisible)
      end
      if tipSp:isVisible()==true then
        local numLb=tolua.cast(tipSp:getChildByTag(11),"CCLabelTTF")
        if numLb~=nil then
          if num and numLb:getString()~=tostring(num) then
            numLb:setString(num)
            local width=36
            if numLb:getContentSize().width+10>width then
              width=numLb:getContentSize().width+10
            end
            tipSp:setContentSize(CCSizeMake(width,36))
            numLb:setPosition(getCenterPoint(tipSp))
          end
        end
      end
    end
end

function allianceDialogInfoTab:refreshTips(idx)
  local count=0
  if idx==4 then
    local applylist=allianceApplicantVoApi:getApplicantTab()
    if applylist then
      count=SizeOfTable(applylist)
    end
  end
  if count>0 then
    self:setTipsVisibleByIdx(true,idx,count)
  else
    self:setTipsVisibleByIdx(false,idx)
  end
end

function allianceDialogInfoTab:dispose()

  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/allianceActiveImage.plist")
  CCTextureCache:sharedTextureCache():removeTextureForKey("public/allianceActiveImage.pvr.ccz")
    self.attackNumLb=nil
    self.refreshTab=nil
    self.nameTab=nil
    self.refreshNameTab=nil
    self.settingsBtn=nil
    for k,v in pairs(self.requires) do
        v=nil
    end
    self.noEventLabel=nil
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil;
    
end
