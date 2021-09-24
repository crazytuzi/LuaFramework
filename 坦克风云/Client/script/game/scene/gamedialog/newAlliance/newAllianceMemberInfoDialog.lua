-- @Author hj
-- @Date 2018-11-20
-- @Description 信息列表

newAllianceMemberInfoDialog = {}

function newAllianceMemberInfoDialog:new(layerNum,subTabtype)
	
	local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum = layerNum
    self.subTabtype = subTabtype
    return nc

end

function newAllianceMemberInfoDialog:init( ... )
	
  self.bgLayer=CCLayer:create()

  local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
  tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-240-65-20))
  tvBg:ignoreAnchorPointForPosition(false)
  tvBg:setAnchorPoint(ccp(0.5,0))
  tvBg:setPosition(ccp(G_VisibleSizeWidth/2,95))
  self.tvBg = tvBg
  self.bgLayer:addChild(tvBg)

	self:initTabLayer()
  return self.bgLayer

end

function newAllianceMemberInfoDialog:initTabLayer( ... )
	-- body
	self:resetTab()
	self:initTabLayer1()
  self:initTabLayer2()
  self:initTabLayer3()
  if not self.subTabtype then
    self:tabClick(0)
  else
    self:tabClick(self.subTabtype)
  end

end

-- 成员列表
function newAllianceMemberInfoDialog:initTabLayer1( ... )
	-- body
  self.bgLayer1=CCLayer:create()
  self.bgLayer:addChild(self.bgLayer1,2)

  self.tableMemberTb1=allianceMemberVoApi:getMemberTab()
  self.memberCellTb={}


  local wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function () end)
  wholeBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,40))
  wholeBgSp:setAnchorPoint(ccp(0.5,1))
  wholeBgSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-240))
  self.bgLayer1:addChild(wholeBgSp)

  local lbSize=22
  local lbHeight=230

  local rankLb=GetTTFLabel(getlocal("alliance_list_scene_rank"),lbSize)
  rankLb:setAnchorPoint(ccp(0.5,0.5))
  rankLb:setPosition(ccp(58,wholeBgSp:getContentSize().height/2))
  rankLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(rankLb)
  
  local memberLb=GetTTFLabel(getlocal("alliance_scene_member_list"),lbSize)
  memberLb:setAnchorPoint(ccp(0.5,0.5))
  memberLb:setPosition(ccp(175,wholeBgSp:getContentSize().height/2))
  memberLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(memberLb)

  
  local dutyLb=GetTTFLabel(getlocal("alliance_scene_member_duty"),lbSize)
  dutyLb:setAnchorPoint(ccp(0.5,0.5))
  dutyLb:setPosition(ccp(270,wholeBgSp:getContentSize().height/2))
  dutyLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(dutyLb)

  local levelLb=GetTTFLabel(getlocal("RankScene_level"),lbSize)
  levelLb:setAnchorPoint(ccp(0.5,0.5))
  levelLb:setPosition(ccp(345,wholeBgSp:getContentSize().height/2))
  levelLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(levelLb)
  
  local attackLb=GetTTFLabelWrap(getlocal("showAttackRank"),lbSize,CCSizeMake(80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  attackLb:setAnchorPoint(ccp(0.5,0.5))
  attackLb:setPosition(ccp(432,wholeBgSp:getContentSize().height/2))
  attackLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(attackLb)
  
  local operatorLb=GetTTFLabel(getlocal("alliance_list_scene_operator"),lbSize)
  operatorLb:setAnchorPoint(ccp(0.5,0.5))
  operatorLb:setPosition(ccp(517+operatorLb:getContentSize().width/4,wholeBgSp:getContentSize().height/2))
  operatorLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(operatorLb)

  local amaxnum
  if(allianceVoApi:getSelfAlliance() and allianceVoApi:getSelfAlliance().maxnum)then
      amaxnum=allianceVoApi:getSelfAlliance().maxnum
  else
      amaxnum=playerCfg["allianceMember"][allianceVoApi:getSelfAlliance().level]
  end

  self.memberNumLb=GetTTFLabel(getlocal("alliance_memberNum",{allianceVoApi:getSelfAlliance().num,amaxnum}),25)
  self.memberNumLb:setAnchorPoint(ccp(0,0.5))
  self.memberNumLb:setPosition(ccp(25,45))
  self.memberNumLb:setTag(99)
  self.bgLayer1:addChild(self.memberNumLb)

  local function sendEmail()
    PlayEffect(audioCfg.mouseClick)
    self:sendEmail()
  end
  local widthButton = 260
  local rect = CCRect(44,33,1,1)
  local function nilFunc()
    
  end
  local sNormal =LuaCCScale9Sprite:createWithSpriteFrameName("newGreenBtn.png",rect,nilFunc)
  local sSelected =LuaCCScale9Sprite:createWithSpriteFrameName("newGreenBtn_down.png",rect,nilFunc)
  local sDisabled =LuaCCScale9Sprite:createWithSpriteFrameName("newGreenBtn_down.png",rect,nilFunc)
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
  self.sendEmailMenu:setPosition(ccp(480,45))
  self.sendEmailMenu:setTouchPriority(-(self.layerNum-1)*20-4)
  self.bgLayer1:addChild(self.sendEmailMenu)
  self.sendEmailMenuPosition=ccp(self.sendEmailMenu:getPositionX(),self.sendEmailMenu:getPositionY())

  if tostring(allianceVoApi:getSelfAlliance().role)~="2" or tostring(allianceVoApi:getSelfAlliance().role)~="1" then
     self.sendEmailMenu:setPosition(ccp(3000,0))
  end
  self:initTableView1()

end

function newAllianceMemberInfoDialog:initTableView1()
    local function callBack1(...)
       return self:eventHandler1(...)
    end
    local hd1= LuaEventHandler:createHandler(callBack1)
    self.tv1=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-240-65-50-40),nil)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv1:setPosition(ccp(25,105))
    self.bgLayer1:addChild(self.tv1)
    self.tv1:setMaxDisToBottomOrTop(120)
end

function newAllianceMemberInfoDialog:eventHandler1(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then           
           local num=0;
            num=SizeOfTable(self.tableMemberTb1)
           return num
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
            tmpSize=CCSizeMake(G_VisibleSizeWidth-50,70)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then

       local cell=CCTableViewCell:new()
       cell:autorelease()
        cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,70))
        local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function ()end)
        grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,70))
        grayBgSp:setAnchorPoint(ccp(0.5,1))
        grayBgSp:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height))
        cell:addChild(grayBgSp) 
        if (idx+1)%2 == 1 then
          grayBgSp:setOpacity(0)
        end

       self.memberCellTb[idx+1]=cell

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
        grayBgSp:addChild(rankLb)
        rankLb:setColor(lbColor)

        
        local memberLb=GetTTFLabel(self.tableMemberTb1[idx+1].name,lbSize)
        memberLb:setPosition(ccp(203-lbWidth,lbHeight))
        grayBgSp:addChild(memberLb)
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

        roleSp:setPosition(ccp(300-lbWidth,lbHeight))
        grayBgSp:addChild(roleSp)
        roleSp:setTag(101)

        local levelLb=GetTTFLabel(self.tableMemberTb1[idx+1].level,lbSize)
        levelLb:setPosition(ccp(372-lbWidth,lbHeight))
        grayBgSp:addChild(levelLb)
        levelLb:setTag(102)
        levelLb:setColor(lbColor)
        
        local attackLb=GetTTFLabel(FormatNumber(self.tableMemberTb1[idx+1].fight),lbSize)
        attackLb:setPosition(ccp(458-lbWidth,lbHeight))
        grayBgSp:addChild(attackLb)
        attackLb:setTag(103)
        attackLb:setColor(lbColor)
        
        local function checkMember()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
            allianceSmallDialog:showMember(getlocal("alliance_member_setting_title"),true,self.tableMemberTb1[idx+1],self.layerNum+1,self.parentDialog,self.tv1)
        end
        local checkItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",checkMember,nil,getlocal("alliance_list_check_info"),25/0.6)
        checkItem:setScale(0.5)
        local checkMenu=CCMenu:createWithItem(checkItem);
        checkMenu:setPosition(ccp(G_VisibleSizeWidth-checkItem:getContentSize().width/2-10,lbHeight))
        checkMenu:setTouchPriority(-(self.layerNum-1)*20-2);
        grayBgSp:addChild(checkMenu)

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

-- 捐献列表
function newAllianceMemberInfoDialog:initTabLayer2( ... )
	-- body
  self.bgLayer2=CCLayer:create()
  self.bgLayer:addChild(self.bgLayer2,2)
  self.tableMemberTb2=allianceMemberVoApi:getMemberTabByDonate()
  local wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function () end)
  wholeBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,40))
  wholeBgSp:setAnchorPoint(ccp(0.5,1))
  wholeBgSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-240))
  self.bgLayer2:addChild(wholeBgSp)

  local lbSize=22
  local lbHeight=230
  local rankLb=GetTTFLabel(getlocal("alliance_list_scene_rank"),lbSize)
  rankLb:setAnchorPoint(ccp(0.5,0.5))
  rankLb:setPosition(ccp(58,wholeBgSp:getContentSize().height/2))
  rankLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(rankLb)
  
  local memberLb=GetTTFLabel(getlocal("alliance_scene_member_list"),lbSize)
  memberLb:setAnchorPoint(ccp(0.5,0.5))
  memberLb:setPosition(ccp(205,wholeBgSp:getContentSize().height/2))
  memberLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(memberLb)

  
  local dutyLb=GetTTFLabel(getlocal("alliance_scene_member_duty"),lbSize)
  dutyLb:setAnchorPoint(ccp(0.5,0.5))
  dutyLb:setPosition(ccp(350,wholeBgSp:getContentSize().height/2))
  dutyLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(dutyLb)

  local levelLb=GetTTFLabel(getlocal("RankScene_level"),lbSize)
  levelLb:setAnchorPoint(ccp(0.5,0.5))
  levelLb:setPosition(ccp(425,wholeBgSp:getContentSize().height/2))
  levelLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(levelLb)

  local attackLb=GetTTFLabelWrap(getlocal("alliance_donateWeek"),lbSize,CCSizeMake(lbSize*5+20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
  attackLb:setAnchorPoint(ccp(0.5,0.5))
  attackLb:setPosition(ccp(530,wholeBgSp:getContentSize().height/2))
  attackLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(attackLb)
  
  
  local donateLb=GetTTFLabelWrap(getlocal("alliance_donateDes"),25,CCSizeMake(30*18,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
  donateLb:setPosition(ccp(G_VisibleSizeWidth/2,45))
  self.bgLayer2:addChild(donateLb)

  self:initTableView2()

end

function newAllianceMemberInfoDialog:initTableView2( ... )
    local function callBack2(...)
       return self:eventHandler2(...)
    end
    local hd2= LuaEventHandler:createHandler(callBack2)
    self.tv2=LuaCCTableView:createWithEventHandler(hd2,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-240-65-50-40),nil)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv2:setPosition(ccp(25,105))
    self.bgLayer2:addChild(self.tv2)
    self.tv2:setMaxDisToBottomOrTop(120)

end

function newAllianceMemberInfoDialog:eventHandler2(handler,fn,idx,cel)

  if fn=="numberOfCellsInTableView" then
            
           local num=0;
            num=SizeOfTable(self.tableMemberTb2)

           return num

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
            tmpSize=CCSizeMake(G_VisibleSizeWidth-50,70)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
        
       local cell=CCTableViewCell:new()
       cell:autorelease()
        cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,70))
        local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function ()end)
        grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,70))
        grayBgSp:setAnchorPoint(ccp(0.5,1))
        grayBgSp:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height))
        cell:addChild(grayBgSp) 
        if (idx+1)%2 == 1 then
          grayBgSp:setOpacity(0)
        end
       

       self.memberCellTb[idx+1]=cell

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
        grayBgSp:addChild(rankLb)
        rankLb:setColor(lbColor)

        local memberLb=GetTTFLabel(self.tableMemberTb2[idx+1].name,lbSize)
        memberLb:setPosition(ccp(203-lbWidth+30,lbHeight))
        grayBgSp:addChild(memberLb)
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

        roleSp:setPosition(ccp(300-lbWidth+75,lbHeight))
        grayBgSp:addChild(roleSp)
        roleSp:setTag(101)
       
        local levelLb=GetTTFLabel(self.tableMemberTb2[idx+1].level,lbSize)
        levelLb:setPosition(ccp(372-lbWidth+80,lbHeight))
        grayBgSp:addChild(levelLb)
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
        grayBgSp:addChild(donateLb1)
        donateLb1:setTag(103)
        donateLb1:setColor(lbColor)

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

-- 申请加入
function newAllianceMemberInfoDialog:initTabLayer3( ... )
	-- body
  self.bgLayer3=CCLayer:create()
  self.bgLayer:addChild(self.bgLayer3,2)

  local wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function () end)
  wholeBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,40))
  wholeBgSp:setAnchorPoint(ccp(0.5,1))
  wholeBgSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-240))
  self.bgLayer3:addChild(wholeBgSp)

  local lbSize=22
  local lbHeight=230

  self.noApplyPlayerLb=GetTTFLabelWrap(getlocal("alliance_noapply"),30,CCSizeMake(30*20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
  self.noApplyPlayerLb:setPosition(ccp(self.bgLayer3:getContentSize().width/2,self.bgLayer3:getContentSize().height/2))
  self.noApplyPlayerLb:setColor(G_ColorGray)
  self.bgLayer3:addChild(self.noApplyPlayerLb)
  if SizeOfTable(allianceApplicantVoApi:getApplicantTab())==0 then
      self.noApplyPlayerLb:setVisible(true)
  else
      self.noApplyPlayerLb:setVisible(false)
  end


  local memberLb=GetTTFLabel(getlocal("alliance_scene_member_list"),lbSize)
  memberLb:setAnchorPoint(ccp(0,0.5))
  memberLb:setPosition(ccp(37,wholeBgSp:getContentSize().height/2))
  memberLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(memberLb)

  local levelLb=GetTTFLabel(getlocal("RankScene_level"),lbSize)
  levelLb:setAnchorPoint(ccp(0,0.5))
  levelLb:setPosition(ccp(161,wholeBgSp:getContentSize().height/2))
  levelLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(levelLb)
  
  local attackLb=GetTTFLabel(getlocal("showAttackRank"),lbSize)
  attackLb:setAnchorPoint(ccp(0,0.5))
  attackLb:setPosition(ccp(235,wholeBgSp:getContentSize().height/2))
  attackLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(attackLb)
  
  local operatorLb=GetTTFLabel(getlocal("alliance_list_scene_operator"),lbSize)
  operatorLb:setAnchorPoint(ccp(0,0.5))
  operatorLb:setPosition(ccp(440,wholeBgSp:getContentSize().height/2))
  operatorLb:setColor(G_ColorYellowPro2)
  wholeBgSp:addChild(operatorLb)
    
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
              self:refreshTips()
          end
      end
      socketHelper:allianceDeny(allianceVoApi:getSelfAlliance().aid,nil,refuseAllCallBack)
  end

  if G_getCurChoseLanguage()=="in" then
      self.refuseButton = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",refuseAllMember,nil,getlocal("alliance_refuse_all"),23)
      self.refuseButton:setScale(0.7)
  else
      self.refuseButton = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",refuseAllMember,nil,getlocal("alliance_refuse_all"),28)
      self.refuseButton:setScale(0.7)
  end
  local checkMenu=CCMenu:createWithItem(self.refuseButton);
  checkMenu:setPosition(ccp(G_VisibleSizeWidth/2,45))
  checkMenu:setTouchPriority(-(self.layerNum-1)*20-2);
  self.bgLayer3:addChild(checkMenu)

  if SizeOfTable(allianceApplicantVoApi:getApplicantTab())==0 then
      self.refuseButton:setEnabled(false)
  end
  self.beforeApplicant = SizeOfTable(allianceApplicantVoApi:getApplicantTab())
  self:initTableView3()
end

function newAllianceMemberInfoDialog:initTableView3( ... )
    local function callBack3(...)
       return self:eventHandler3(...)
    end
    local hd3= LuaEventHandler:createHandler(callBack3)
    self.tv3=LuaCCTableView:createWithEventHandler(hd3,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-240-65-50-40),nil)
    self.tv3:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv3:setPosition(ccp(25,105))
    self.bgLayer3:addChild(self.tv3)
    self.tv3:setMaxDisToBottomOrTop(120)

end


function newAllianceMemberInfoDialog:eventHandler3(handler,fn,idx,cel)

  if fn=="numberOfCellsInTableView" then
            
           local num=0;
           num=SizeOfTable(allianceApplicantVoApi:getApplicantTab())
           return num

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
            tmpSize=CCSizeMake(G_VisibleSizeWidth-50,70)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
        
        local cell=CCTableViewCell:new()
       cell:autorelease()
        cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,70))
        local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function ()end)
        grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,70))
        grayBgSp:setAnchorPoint(ccp(0.5,1))
        grayBgSp:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height))
        cell:addChild(grayBgSp) 
        if (idx+1)%2 == 1 then
          grayBgSp:setOpacity(0)
        end

        local lbSize=25
        local lbHeight=35
        local lbWidth=30
        
        local memberLb=GetTTFLabel(allianceApplicantVoApi:getApplicantTab()[idx+1].name,lbSize)
        memberLb:setPosition(ccp(107-lbWidth,lbHeight))
        grayBgSp:addChild(memberLb)
        
        local levelLb=GetTTFLabel(allianceApplicantVoApi:getApplicantTab()[idx+1].level,lbSize)
        levelLb:setPosition(ccp(213-lbWidth,lbHeight))
        grayBgSp:addChild(levelLb)

        local attackLb=GetTTFLabel(FormatNumber(allianceApplicantVoApi:getApplicantTab()[idx+1].fight),lbSize)
        attackLb:setPosition(ccp(294-lbWidth,lbHeight))
        grayBgSp:addChild(attackLb)
        
        local function acceptMember()
            if self.tv3:getIsScrolled()==true then
                do
                    return
                end
            end
            
            local function acceptCallBack(fn,data)
                base:cancleWait()
                base:cancleNetWait()                
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
                    self.tv3:reloadData()
                    G_isRefreshAllianceApplicantTb=true
                    --工会活动刷新数据
                    activityVoApi:updateAc("fbReward")
                    activityVoApi:updateAc("allianceLevel")
                    activityVoApi:updateAc("allianceFight")
                    G_getAlliance()
                    self:refreshTips()
                elseif sData.ret==-8010 then --已加入别人军团后弹出面板并前台删除数据
                    local mUid=allianceApplicantVoApi:getApplicantTab()[idx+1].uid
                    allianceApplicantVoApi:deleteApplicantByUid(mUid)
                    self.tv3:reloadData()
                    self:refreshTips()
                    do
                        return
                    end
                end
            end
        socketHelper:allianceAccept(allianceVoApi:getSelfAlliance().aid,allianceApplicantVoApi:getApplicantTab()[idx+1].uid,acceptCallBack)

        end

        local acceptItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",acceptMember,nil,getlocal("accpet"),28)
        acceptItem:setScale(0.5)
        local acceptMenu=CCMenu:createWithItem(acceptItem);
        acceptMenu:setPosition(ccp(G_VisibleSizeWidth-acceptItem:getContentSize().width/2-20,lbHeight))
        acceptMenu:setTouchPriority(-(self.layerNum-1)*20-2);
        grayBgSp:addChild(acceptMenu)

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
                    self:refreshTips()
                end
            end
            socketHelper:allianceDeny(allianceVoApi:getSelfAlliance().aid,allianceApplicantVoApi:getApplicantTab()[idx+1].uid,refuseCallBack)
        end
        local refuseItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",refuseMember,nil,getlocal("alliance_request_refuse"),28)
        refuseItem:setScale(0.5)
        local refuseMenu=CCMenu:createWithItem(refuseItem);
        refuseMenu:setPosition(ccp(G_VisibleSizeWidth-refuseItem:getContentSize().width/2-140,lbHeight))
        refuseMenu:setTouchPriority(-(self.layerNum-1)*20-2);
        grayBgSp:addChild(refuseMenu)

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
function newAllianceMemberInfoDialog:resetTab( ... )
	
	  self.allTabs={getlocal("alliance_scene_member_list"),getlocal("alliance_donate"),getlocal("alliance_info_apply")}
    self:initTab(self.allTabs)
    self:refreshTips()
    local index=0
    local tabH = 0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
            tabBtnItem:setPosition(100,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-10-160)
         elseif index==1 then
            tabBtnItem:setPosition(248,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-10-160)
         elseif index==2 then
            tabBtnItem:setPosition(397,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-10-160)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         tabH = tabBtnItem:getContentSize().height
         index=index+1
    end
    local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-tabH-10-160)
    self.bgLayer:addChild(tabLine,5)

end

function newAllianceMemberInfoDialog:initTab( tabTb )

	local tabBtn=CCMenu:create()
   	local tabIndex=0
   	local tabBtnItem

   	if tabTb~=nil then

       	for k,v in pairs(tabTb) do
           	tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png","yh_ltzdzHelp_tab_down.png")
           
           	tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))

           	local function tabClick(idx)
            	return self:tabClick(idx)
           	end
           	tabBtnItem:registerScriptTapHandler(tabClick)
           
           	local lb=GetTTFLabel(v,24,true)
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

function newAllianceMemberInfoDialog:sendEmail( ... )

    if allianceVoApi:canSendAllianceEmail() then
      emailVoApi:showWriteEmailDialog(self.layerNum+1,getlocal("alliance_scene_email"),getlocal("alliance_scene_all_member"),nil,true)
    else
      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_email_num_max"),30)     
    end
end

function newAllianceMemberInfoDialog:tabClick(idx)

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

    elseif self.selectedTabIndex==1 then
       self.bgLayer2:setVisible(true)
       self.bgLayer2:setPosition(ccp(0,0))
       
       self.bgLayer1:setVisible(false)
       self.bgLayer1:setPosition(ccp(10000,0))
       
       self.bgLayer3:setVisible(false)
       self.bgLayer3:setPosition(ccp(10000,0))

    elseif self.selectedTabIndex==2 then
       self.bgLayer3:setVisible(true)
       self.bgLayer3:setPosition(ccp(0,0))
       
       self.bgLayer2:setVisible(false)
       self.bgLayer2:setPosition(ccp(10000,0))
       
       self.bgLayer1:setVisible(false)
       self.bgLayer1:setPosition(ccp(10000,0))

    end

end

function newAllianceMemberInfoDialog:refreshTips()
  local count=0
  local applylist=allianceApplicantVoApi:getApplicantTab()
  if applylist then
    count=SizeOfTable(applylist)
  end
  if count>0 then
    self:setTipsVisibleByIdx(true,count)
  else
    self:setTipsVisibleByIdx(false)
  end
end



function newAllianceMemberInfoDialog:setTipsVisibleByIdx(isVisible,num)
    
    if self==nil then
        do
            return 
        end
    end

    local tabBtnItem=self.allTabs[3]
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

function newAllianceMemberInfoDialog:tick( ... )

  if self.selectedTabIndex == 0 then
    local alliance=allianceVoApi:getSelfAlliance()
    if alliance then
        if self.sendEmailMenu then
            if tostring(alliance.role)=="2" or tostring(alliance.role)=="1" then
                self.sendEmailMenu:setPosition(self.sendEmailMenuPosition)

            else
                self.sendEmailMenu:setPosition(ccp(3000,80))
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
  elseif self.selectedTabIndex == 1 then

  elseif self.selectedTabIndex == 2 then
      

      if SizeOfTable(allianceApplicantVoApi:getApplicantTab())==0 then
        self.noApplyPlayerLb:setVisible(true)
        self.refuseButton:setEnabled(false)
      else
          self.noApplyPlayerLb:setVisible(false)
          self.refuseButton:setEnabled(true)
      end
      if self.beforeApplicant ~= SizeOfTable(allianceApplicantVoApi:getApplicantTab()) then
        self.tv3:reloadData()
        self.beforeApplicant = SizeOfTable(allianceApplicantVoApi:getApplicantTab())
      end
  else

  end
end

function newAllianceMemberInfoDialog:dispose( ... )
	-- body
end

