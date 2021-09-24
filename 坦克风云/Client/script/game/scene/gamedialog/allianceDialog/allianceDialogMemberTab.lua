allianceDialogMemberTab={

}

function allianceDialogMemberTab:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv1=nil;
    self.tv2=nil;
    self.tv3=nil;
    self.tableMemberTb1={}
    self.tableMemberTb2={}
    self.tableMemberTb3={}
    self.bgLayer=nil;
    self.layerNum=nil;
    self.allTabs={};
    
    self.bgLayer1=nil;
    self.bgLayer2=nil;
    self.bgLayer3=nil;
    self.selectedTabIndex=0;
    self.parentDialog=nil;
    self.memberCellTb={};
    self.memberNumLb=nil
    self.refuseButton=nil
    self.role=allianceVoApi:getSelfAlliance().role
    self.noApplyPlayerLb=nil
    return nc;

end
--设置或修改每个Tab页签
function allianceDialogMemberTab:resetTab()
    self.allTabs={getlocal("alliance_scene_member_list"),getlocal("alliance_donate"),getlocal("alliance_info_apply")}


    self:initTab(self.allTabs)
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
    
    if allianceVoApi:getSelfAlliance()~=nil and tonumber(allianceVoApi:getSelfAlliance().role)>0 then

    else
        self.allTabs[3]:setVisible(false)
        self.allTabs[3]:setEnabled(false)
    end
end

function allianceDialogMemberTab:init(parentDialog,layerNum)
    self.parentDialog=parentDialog
    self.layerNum=layerNum;
    self.bgLayer=CCLayer:create();
    self.tableMemberTb1=allianceMemberVoApi:getMemberTab()
    self.tableMemberTb2=allianceMemberVoApi:getMemberTabByDonate()
    self:initTabLayer();

    return self.bgLayer
end

function allianceDialogMemberTab:initTabLayer()
    self:resetTab()
    self:initTabLayer3()
    self:initTabLayer2()
    self:initTabLayer1()

end

function allianceDialogMemberTab:initTabLayer1()
    self.bgLayer1=CCLayer:create();
    local lbSize=22
    local lbHeight=230
    local rankLb=GetTTFLabel(getlocal("alliance_list_scene_rank"),lbSize)
    rankLb:setAnchorPoint(ccp(0.5,0.5))
    rankLb:setPosition(ccp(83,G_VisibleSizeHeight-lbHeight))
    rankLb:setColor(G_ColorGreen)
    self.bgLayer1:addChild(rankLb)
    
    local memberLb=GetTTFLabel(getlocal("alliance_scene_member_list"),lbSize)
    memberLb:setAnchorPoint(ccp(0.5,0.5))
    memberLb:setPosition(ccp(200,G_VisibleSizeHeight-lbHeight))
    memberLb:setColor(G_ColorGreen)
    self.bgLayer1:addChild(memberLb)

    
    local dutyLb=GetTTFLabel(getlocal("alliance_scene_member_duty"),lbSize)
    dutyLb:setAnchorPoint(ccp(0.5,0.5))
    dutyLb:setPosition(ccp(296,G_VisibleSizeHeight-lbHeight))
    dutyLb:setColor(G_ColorGreen)
    self.bgLayer1:addChild(dutyLb)

    local levelLb=GetTTFLabel(getlocal("RankScene_level"),lbSize)
    levelLb:setAnchorPoint(ccp(0.5,0.5))
    levelLb:setPosition(ccp(370,G_VisibleSizeHeight-lbHeight))
    levelLb:setColor(G_ColorGreen)
    self.bgLayer1:addChild(levelLb)
    
    local attackLb=GetTTFLabelWrap(getlocal("showAttackRank"),lbSize,CCSizeMake(80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    attackLb:setAnchorPoint(ccp(0.5,0.5))
    attackLb:setPosition(ccp(457,G_VisibleSizeHeight-lbHeight+(attackLb:getContentSize().height-levelLb:getContentSize().height)/2))
    attackLb:setColor(G_ColorGreen)
    self.bgLayer1:addChild(attackLb)
    
    local operatorLb=GetTTFLabel(getlocal("alliance_list_scene_operator"),lbSize)
    operatorLb:setAnchorPoint(ccp(0.5,0.5))
    operatorLb:setPosition(ccp(542+operatorLb:getContentSize().width/4,G_VisibleSizeHeight-lbHeight))
    operatorLb:setColor(G_ColorGreen)
    self.bgLayer1:addChild(operatorLb)
    
    local amaxnum
    if(allianceVoApi:getSelfAlliance() and allianceVoApi:getSelfAlliance().maxnum)then
        amaxnum=allianceVoApi:getSelfAlliance().maxnum
    else
        amaxnum=playerCfg["allianceMember"][allianceVoApi:getSelfAlliance().level]
    end
    self.memberNumLb=GetTTFLabel(getlocal("alliance_memberNum",{allianceVoApi:getSelfAlliance().num,amaxnum}),30)
    self.memberNumLb:setPosition(ccp(G_VisibleSizeWidth/2,60))
    self.memberNumLb:setTag(99)
    self.bgLayer1:addChild(self.memberNumLb)


    self:initTableView1()
    self.bgLayer:addChild(self.bgLayer1,2)
end

function allianceDialogMemberTab:initTabLayer2()
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
    memberLb:setPosition(ccp(160+30+40,G_VisibleSizeHeight-lbHeight))
    memberLb:setColor(G_ColorGreen)
    self.bgLayer2:addChild(memberLb)

    
    local dutyLb=GetTTFLabel(getlocal("alliance_scene_member_duty"),lbSize)
    dutyLb:setAnchorPoint(ccp(0.5,0.5))
    -- dutyLb:setPosition(ccp(276,G_VisibleSizeHeight-lbHeight))
    dutyLb:setPosition(ccp(350+25,G_VisibleSizeHeight-lbHeight))
    dutyLb:setColor(G_ColorGreen)
    self.bgLayer2:addChild(dutyLb)

    local levelLb=GetTTFLabel(getlocal("RankScene_level"),lbSize)
    levelLb:setAnchorPoint(ccp(0.5,0.5))
    -- levelLb:setPosition(ccp(350,G_VisibleSizeHeight-lbHeight))
    levelLb:setPosition(ccp(430+20,G_VisibleSizeHeight-lbHeight))
    levelLb:setColor(G_ColorGreen)
    self.bgLayer2:addChild(levelLb)

    local attackLb=GetTTFLabelWrap(getlocal("alliance_donateWeek"),lbSize,CCSizeMake(lbSize*5+20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    attackLb:setAnchorPoint(ccp(0.5,0.5))
    -- attackLb:setPosition(ccp(433,G_VisibleSizeHeight-lbHeight))
    attackLb:setPosition(ccp(555,G_VisibleSizeHeight-lbHeight+attackLb:getContentSize().height/2-levelLb:getContentSize().height/2))
    attackLb:setColor(G_ColorGreen)
    self.bgLayer2:addChild(attackLb)
    
    -- local operatorLb=GetTTFLabel(getlocal("alliance_donateAll"),lbSize)
    -- operatorLb:setAnchorPoint(ccp(0,0.5))
    -- operatorLb:setPosition(ccp(527,G_VisibleSizeHeight-lbHeight))
    -- operatorLb:setColor(G_ColorGreen)
    -- self.bgLayer2:addChild(operatorLb)


    --self:initTableView1()
    self.bgLayer:addChild(self.bgLayer2,2)
    self.bgLayer2:setVisible(false)
    self.bgLayer2:setPosition(ccp(10000,0))
    
    local donateLb=GetTTFLabelWrap(getlocal("alliance_donateDes"),30,CCSizeMake(30*18,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    donateLb:setPosition(ccp(G_VisibleSizeWidth/2,60))
    self.bgLayer2:addChild(donateLb)
end


--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceDialogMemberTab:eventHandler(handler,fn,idx,cel)
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

function allianceDialogMemberTab:initTableView1()

    local rect = CCRect(0, 0, 50, 50);
	local capInSet = CCRect(20, 20, 10, 10);
	local function click(hd,fn,idx)
	end
	self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,click)
	self.tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345))
	self.tvBg:ignoreAnchorPointForPosition(false)
	self.tvBg:setAnchorPoint(ccp(0.5,0))
	--self.tvBg:setIsSallow(false)
	--self.tvBg:setTouchPriority(-(self.layerNum-1)*20-2)
	self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,100))
	self.bgLayer:addChild(self.tvBg)

    local function callBack1(...)
       return self:eventHandler(...)
    end
    local hd1= LuaEventHandler:createHandler(callBack1)
    local height=0;
    self.tv1=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345),nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv1:setPosition(ccp(30,100))
    self.bgLayer1:addChild(self.tv1)
    self.tv1:setMaxDisToBottomOrTop(120)
    
    
    local function callBack2(...)
       return self:eventHandler2(...)
    end
    local hd2= LuaEventHandler:createHandler(callBack2)
    self.tv2=LuaCCTableView:createWithEventHandler(hd2,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-85-260),nil)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv2:setPosition(ccp(30,100))
    self.bgLayer2:addChild(self.tv2)
    self.tv2:setMaxDisToBottomOrTop(120)
    
    local function callBack3(...)
       return self:eventHandler3(...)
    end
    local hd3= LuaEventHandler:createHandler(callBack3)
    self.tv3=LuaCCTableView:createWithEventHandler(hd3,CCSizeMake(self.bgLayer:getContentSize().width-10,G_VisibleSize.height-85-260),nil)
    self.tv3:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv3:setPosition(ccp(30,100))
    self.bgLayer3:addChild(self.tv3)
    self.tv3:setMaxDisToBottomOrTop(120)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceDialogMemberTab:eventHandler2(handler,fn,idx,cel)
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
function allianceDialogMemberTab:eventHandler3(handler,fn,idx,cel)
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

                local sData=G_Json.decode(tostring(data))
                base:cancleWait()
                base:cancleNetWait()
                if sData.ret==-8010 then --已加入别人军团后弹出面板并前台删除数据
                    local codeStr="backstage"..RemoveFirstChar(sData.ret)
                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal(codeStr),nil,8,nil,sureCallBackHandler)
                    local mUid=allianceApplicantVoApi:getApplicantTab()[idx+1].uid
                    allianceApplicantVoApi:deleteApplicantByUid(mUid)
                    self.tv3:reloadData()
                    
                    do
                        return
                    end
                end
                

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


function allianceDialogMemberTab:initTabLayer3()
    self.bgLayer3=CCLayer:create();
    
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
    memberLb:setPosition(ccp(67,G_VisibleSizeHeight-lbHeight))
    memberLb:setColor(G_ColorGreen)
    self.bgLayer3:addChild(memberLb)

    local levelLb=GetTTFLabel(getlocal("RankScene_level"),lbSize)
    levelLb:setAnchorPoint(ccp(0,0.5))
    levelLb:setPosition(ccp(191,G_VisibleSizeHeight-lbHeight))
    levelLb:setColor(G_ColorGreen)
    self.bgLayer3:addChild(levelLb)
    
    local attackLb=GetTTFLabel(getlocal("showAttackRank"),lbSize)
    attackLb:setAnchorPoint(ccp(0,0.5))
    attackLb:setPosition(ccp(265,G_VisibleSizeHeight-lbHeight))
    attackLb:setColor(G_ColorGreen)
    self.bgLayer3:addChild(attackLb)
    
    local operatorLb=GetTTFLabel(getlocal("alliance_list_scene_operator"),lbSize)
    operatorLb:setAnchorPoint(ccp(0,0.5))
    operatorLb:setPosition(ccp(471,G_VisibleSizeHeight-lbHeight))
    operatorLb:setColor(G_ColorGreen)
    self.bgLayer3:addChild(operatorLb)
    
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
            end
        end
        socketHelper:allianceDeny(allianceVoApi:getSelfAlliance().aid,nil,refuseAllCallBack)
    
    end
    
    self.refuseButton = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",refuseAllMember,nil,getlocal("alliance_refuse_all"),28)
    self.refuseButton:setScale(0.9)
    local checkMenu=CCMenu:createWithItem(self.refuseButton);
    checkMenu:setPosition(ccp(G_VisibleSizeWidth/2,60))
    checkMenu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer3:addChild(checkMenu)
    if SizeOfTable(allianceApplicantVoApi:getApplicantTab())==0 then
        self.refuseButton:setEnabled(false)
    end
    
    self.bgLayer:addChild(self.bgLayer3,2)
    self.bgLayer3:setVisible(false)
    self.bgLayer3:setPosition(ccp(10000,0))
end
function allianceDialogMemberTab:initTab(tabTb)
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
           
           local lb=GetTTFLabelWrap(v,24,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
		   lb:setTag(31)
           if k~=1 then
              lb:setColor(G_TabLBColorGreen)
           end
		   
		   
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
	        newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width-2,tabBtnItem:getContentSize().height-30))
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
function allianceDialogMemberTab:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_ColorWhite)
         else
            v:setEnabled(true)
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_TabLBColorGreen)
         end
    end
    
    if self.selectedTabIndex==0 then
       self.bgLayer1:setVisible(true)
       self.bgLayer1:setPosition(ccp(0,0))
       
       self.bgLayer2:setVisible(false)
       self.bgLayer2:setPosition(ccp(10000,0))

       self.bgLayer3:setVisible(false)
       self.bgLayer3:setPosition(ccp(10000,0))
       self.tableMemberTb1=allianceMemberVoApi:getMemberTab()
       self.tv1:reloadData()
    elseif self.selectedTabIndex==1 then
       self.bgLayer2:setVisible(true)
       self.bgLayer2:setPosition(ccp(0,0))
       
       self.bgLayer1:setVisible(false)
       self.bgLayer1:setPosition(ccp(10000,0))

       self.bgLayer3:setVisible(false)
       self.bgLayer3:setPosition(ccp(10000,0))
       self.tableMemberTb2=allianceMemberVoApi:getMemberTabByDonate()
       self.tv2:reloadData()

    else
       self.bgLayer3:setVisible(true)
       self.bgLayer3:setPosition(ccp(0,0))
       
       self.bgLayer1:setVisible(false)
       self.bgLayer1:setPosition(ccp(10000,0))
       
       self.bgLayer2:setVisible(false)
       self.bgLayer2:setPosition(ccp(10000,0))

    end
    --self.tv:reloadData()
end
function allianceDialogMemberTab:tick()
    allianceMemberVoApi:getWeekDonate(uid)
    if tonumber(self.role)~=tonumber(allianceVoApi:getSelfAlliance().role) then
        if allianceVoApi:getSelfAlliance()~=nil and tonumber(allianceVoApi:getSelfAlliance().role)>0 then
            self.allTabs[3]:setVisible(true)
            self.allTabs[3]:setEnabled(true)

        else
            self:tabClick(0)
            self.allTabs[3]:setVisible(false)
            self.allTabs[3]:setEnabled(true)
        end
        self.role=allianceVoApi:getSelfAlliance().role

    end
    
    if self.selectedTabIndex==0 then
        
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
    elseif self.selectedTabIndex==1 then
        if G_isRefreshAllianceMemberTb==true then
            self.tableMemberTb2=allianceMemberVoApi:getMemberTabByDonate()
            self.tv2:reloadData()
            G_isRefreshAllianceMemberTb=false
        end

    elseif self.selectedTabIndex==2 then
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
function allianceDialogMemberTab:doUserHandler()

end

--点击了cell或cell上某个按钮
function allianceDialogMemberTab:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,120)
        else
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,800)
        end
    end
end
function allianceDialogMemberTab:dispose()
    
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil;
    self.memberCellTb={}
    self.memberCellTb=nil
    
end
