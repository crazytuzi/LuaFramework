-- @Author hj
-- @Date 2018-11-15
-- @Description 军团活跃福利板子

newAllianceActiveWelfareDialog = {}

function newAllianceActiveWelfareDialog:new(layerNum,parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=layerNum
    self.parent=parent

    return nc
end

function newAllianceActiveWelfareDialog:init()

    self.bgLayer=CCLayer:create()
    self:initTabLayer()
    return self.bgLayer

end

function newAllianceActiveWelfareDialog:initTabLayer()

	self:resetTab()
	self:initTabLayer1()
	self:initTabLayer2()
	self:tabClick(0)
	
end

function newAllianceActiveWelfareDialog:initTabLayer1( ... )

	self.bgLayer1=CCLayer:create()

	local rect = CCRect(0, 0, 50, 50);
	local capInSet = CCRect(20, 20, 10, 10);
	local function click(hd,fn,idx)
	end

	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
	tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-240-65-20))
	tvBg:ignoreAnchorPointForPosition(false)
	tvBg:setAnchorPoint(ccp(0.5,0))
	tvBg:setPosition(ccp(G_VisibleSizeWidth/2,95))

	self.tvBg = tvBg
	self.bgLayer1:addChild(tvBg)    

	local strSize3 = 23
	local subWidth = 230
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
	    strSize3 =25
	    subWidth = 260
	end
	local noteLb = GetTTFLabelWrap(getlocal("alliance_activie_rewardNote"),strSize3,CCSizeMake(self.bgLayer1:getContentSize().width-subWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	noteLb:setAnchorPoint(ccp(0,0.5))
	noteLb:setPosition(30,50)
	self.bgLayer1:addChild(noteLb)
	noteLb:setColor(G_ColorRed)

  	local alliance=allianceVoApi:getSelfAlliance()

	local function onConfirm()

	    if G_checkClickEnable()==false then
	        do
	            return
	        end
	    else
	        base.setWaitTime=G_getCurDeviceMillTime()
	    end
	    PlayEffect(audioCfg.mouseClick)
 	
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
		          	self:getCanReward()
		          	if self.tv1 then
		            	self.tv1:reloadData()
		          	end
		          	self:updateShowBtn()
		          	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,28)
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

	self.okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onConfirm,nil,getlocal("activity_shareHappiness_getAll"),30)
	local okBtn=CCMenu:createWithItem(self.okItem)
	self.okItem:setScale(0.8)
	okBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	okBtn:setAnchorPoint(ccp(0.5,0.5))
	okBtn:setPosition(ccp(self.bgLayer:getContentSize().width-110,50))
	self.bgLayer1:addChild(okBtn)

  	local function gotoConfirm()
    	if G_checkClickEnable()==false then
    	    do
            	return
        	end
    	else
        	base.setWaitTime=G_getCurDeviceMillTime()
    	end
    	PlayEffect(audioCfg.mouseClick)
    	activityAndNoteDialog:closeAllDialog()
    	mainUI:changeToWorld()
  	end

  	self.gotoItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",gotoConfirm,nil,getlocal("alliance_activie_gotoResource"),30)
  	local gotoBtn=CCMenu:createWithItem(self.gotoItem)
  	self.gotoItem:setScale(0.8)
  	gotoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
  	gotoBtn:setAnchorPoint(ccp(0.5,0.5))
  	gotoBtn:setPosition(ccp(self.bgLayer:getContentSize().width-110,50))
  	self.bgLayer1:addChild(gotoBtn)

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
		        self:getCanReward()
		        self:initTv()
		        self:updateShowBtn()
		    end
		end
	end

  	local alliance = allianceVoApi:getSelfAlliance()
  	if (alliance.alevel and allianceActiveCfg.allianceActiveReward[alliance.alevel]>0) and  (allianceVoApi.lastActiveSt + 60 < base.serverTime) then
    socketHelper:allianceActiveCanReward(resourceCallback)
  	else
    	self:getCanReward()
    	self:initTv()
    	self:updateShowBtn()
	end

	self.bgLayer:addChild(self.bgLayer1,2)
end

function newAllianceActiveWelfareDialog:initTv()
  if self.tv1== nil then
    local function callBack(...)
       return self:eventHandler1(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvBg:getContentSize().width-20,self.tvBg:getContentSize().height-20),nil)
    self.bgLayer1:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv1:setPosition(ccp(10,10))
    self.tvBg:addChild(self.tv1)
    self.tv1:setMaxDisToBottomOrTop(120)
  else
    self.tv1:reloadData()
  end
end

function newAllianceActiveWelfareDialog:getCanReward()
  self.canReward={}
  local alliance=allianceVoApi:getSelfAlliance()
  -- local hadReward = allianceMemberVoApi:getUserHadRewardResource(playerVoApi:getUid())
  local hadRewardTotal = allianceVoApi:getActiveRewardTotal()
  local canReward = false
  if alliance.alevel and allianceActiveCfg.allianceActiveReward[alliance.alevel]>0 then
    if alliance.ainfo.r then
      for k,v in pairs(alliance.ainfo.r) do
        if k and v then
          if k and v then
            local hadRewardR = 0
            if hadRewardTotal[k] then
              hadRewardR=hadRewardTotal[k]
            end
            if v>hadRewardR then
              self.canReward[k]=math.ceil((v-hadRewardR)*allianceActiveCfg.allianceActiveReward[alliance.alevel])
            end
          end
        end
      end
    end
  end
end

function newAllianceActiveWelfareDialog:updateShowBtn()
  if self.okItem and self.gotoItem then
    if self.canReward and SizeOfTable(self.canReward)>0 then
      self.okItem:setEnabled(true)
      self.okItem:setVisible(true)
      self.gotoItem:setEnabled(false)
      self.gotoItem:setVisible(false)
    else
      self.okItem:setEnabled(false)
      self.okItem:setVisible(false)
      self.gotoItem:setEnabled(true)
      self.gotoItem:setVisible(true)
    end
  end
  
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function newAllianceActiveWelfareDialog:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 2
    elseif fn=="tableCellSizeForIndex" then
    	local tmpSize
      local cellHeight = 180
      local alliance=allianceVoApi:getSelfAlliance()
      -- local hadReward = allianceMemberVoApi:getUserHadRewardResource(playerVoApi:getUid())
      local hadReward = allianceVoApi:getActiveReward()
      if alliance.alevel and allianceActiveCfg.allianceActiveReward[alliance.alevel]>0 then
        if idx==1 then
          if self.canReward and SizeOfTable(self.canReward)>0 then
            cellHeight = 60+math.ceil(SizeOfTable(self.canReward)/2)*120
          end
        elseif idx==0 then
          if hadReward and SizeOfTable(hadReward) >0 then
            cellHeight = 60+math.ceil(SizeOfTable(hadReward)/2)*120
          end
        end
      end
      

      tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,cellHeight)
      return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellHeight = 180
        local alliance=allianceVoApi:getSelfAlliance()
        -- local hadReward = allianceMemberVoApi:getUserHadRewardResource(playerVoApi:getUid())
        local hadReward = allianceVoApi:getActiveReward()
        if alliance.alevel and allianceActiveCfg.allianceActiveReward[alliance.alevel]>0 then
          if idx==1 then
            if self.canReward and SizeOfTable(self.canReward)>0 then
              cellHeight = 60+math.ceil(SizeOfTable(self.canReward)/2)*120
            end
          elseif idx==0 then
            if hadReward and SizeOfTable(hadReward) >0 then
              cellHeight = 60+math.ceil(SizeOfTable(hadReward)/2)*120
            end
          end
        end
        
        cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,cellHeight))

        local str 
        if idx==0 then
        	str = "activity_baifudali_dailyHadReward"
        else
        	str = "alliance_activie_memberResource"
        end

        local titleBg,titleLb=G_createNewTitle({getlocal(str),24},CCSizeMake(G_VisibleSizeWidth-60,0),nil,nil,"Helvetica-bold")
		titleLb:setColor(G_ColorYellowPro2)
		titleBg:setAnchorPoint(ccp(0.5,1))
		titleBg:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height-15))
		cell:addChild(titleBg)


        if idx==1 then

          if alliance.alevel and allianceActiveCfg.allianceActiveReward[alliance.alevel]>0 and self.canReward and SizeOfTable(self.canReward)>0 then
            local i = 1

            for k,v in pairs(self.canReward) do
              if k and v then

                local picStr = G_getResourceIcon(k)
                local rect = CCRect(0, 0, 50, 50);
                local capInSet = CCRect(20, 20, 10, 10);
                local function click(hd,fn,idx)
                end
                local sprite =LuaCCScale9Sprite:createWithSpriteFrameName("nbSkillBorder.png",CCRect(116, 58, 1, 1),click)
                sprite:setContentSize(CCSizeMake(cell:getContentSize().width/2-20,110))
                sprite:setAnchorPoint(ccp(0,1))
                sprite:setPosition(10+((i-1)%2)*cell:getContentSize().width/2,cell:getContentSize().height-60-10-math.floor((i-1)/2)*120)
                cell:addChild(sprite)

                local scale = 2

                local icon = CCSprite:createWithSpriteFrameName(picStr)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(20,sprite:getContentSize().height/2)
                sprite:addChild(icon)
                icon:setScale(scale)
                local numlbWdithPos = 30
                if G_getCurChoseLanguage() =="ar" then
                  numlbWdithPos =-60
                end
                local numlb = GetTTFLabelWrap("x"..FormatNumber(v),25,CCSizeMake(sprite:getContentSize().width-20-icon:getContentSize().width*scale,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                numlb:setAnchorPoint(ccp(0,0.5))
                numlb:setPosition(icon:getContentSize().width*scale+numlbWdithPos,sprite:getContentSize().height/2)
                sprite:addChild(numlb)

                i = i+1
              end
            end
          else
            local noResource = GetTTFLabelWrap(getlocal("alliance_activie_noCanResource"),25,CCSizeMake(cell:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            noResource:setPosition(cell:getContentSize().width/2,60)
            cell:addChild(noResource)
            noResource:setColor(G_ColorYellow)
          end
        elseif idx==0 then

          if alliance.alevel and allianceActiveCfg.allianceActiveReward[alliance.alevel]>0 and hadReward and SizeOfTable(hadReward)>0 then
            local i = 1

            for k,v in pairs(hadReward) do
              if k and v then
                local picStr = G_getResourceIcon(k)
                local rect = CCRect(0, 0, 50, 50);
                local capInSet = CCRect(20, 20, 10, 10);
                local function click(hd,fn,idx)
                end
                local sprite =LuaCCScale9Sprite:createWithSpriteFrameName("nbSkillBorder.png",CCRect(116, 58, 1, 1),click)
                sprite:setContentSize(CCSizeMake(cell:getContentSize().width/2-20,110))
                sprite:setAnchorPoint(ccp(0,1))
                sprite:setPosition(10+((i-1)%2)*cell:getContentSize().width/2,cell:getContentSize().height-60-10-math.floor((i-1)/2)*120)
                cell:addChild(sprite)

                local scale = 2

                local icon = CCSprite:createWithSpriteFrameName(picStr)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(20,sprite:getContentSize().height/2)
                sprite:addChild(icon)
                icon:setScale(scale)

                local numlbWdithPos = 30
                if G_getCurChoseLanguage() =="ar" then
                  numlbWdithPos =-60
                end
                local numlb = GetTTFLabelWrap("x"..FormatNumber(math.ceil(v)),30,CCSizeMake(sprite:getContentSize().width-20-icon:getContentSize().width*scale,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                numlb:setAnchorPoint(ccp(0,0.5))
                numlb:setPosition(icon:getContentSize().width*scale+numlbWdithPos,sprite:getContentSize().height/2)
                sprite:addChild(numlb)

                i = i+1
              end
            end
          else
            local hadResource = GetTTFLabelWrap(getlocal("alliance_activie_HadResource"),25,CCSizeMake(cell:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            hadResource:setPosition(cell:getContentSize().width/2,60)
            cell:addChild(hadResource)
            hadResource:setColor(G_ColorYellow)
          end
        end

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




function newAllianceActiveWelfareDialog:initTabLayer2( ... )

	self.bgLayer2=CCLayer:create()
	self.tableMemberTb1=allianceMemberVoApi:getMemberTab()
    self.tableMemberTb2=allianceMemberVoApi:getMemberTabByActive()
    self.memberCellTb={}

	local function click(hd,fn,idx)
	end
	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
	tvBg:setContentSize(CCSizeMake(self.bgLayer2:getContentSize().width-50,self.bgLayer2:getContentSize().height-240-65-20))
	tvBg:ignoreAnchorPointForPosition(false)
	tvBg:setAnchorPoint(ccp(0.5,0))

	local wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function () end)
	wholeBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,40))
	wholeBgSp:setAnchorPoint(ccp(0.5,1))
	wholeBgSp:setPosition(ccp(tvBg:getContentSize().width/2,tvBg:getContentSize().height-10))
	tvBg:addChild(wholeBgSp)

	tvBg:setPosition(ccp(self.bgLayer2:getContentSize().width/2,95))
	self.bgLayer2:addChild(tvBg)


	local lbSize=22
    local lbHeight=230
    local rankLb=GetTTFLabel(getlocal("alliance_list_scene_rank"),lbSize)
    rankLb:setAnchorPoint(ccp(0.5,0.5))
    rankLb:setPosition(ccp(83-25,wholeBgSp:getContentSize().height/2))
    rankLb:setColor(G_ColorYellowPro2)
    wholeBgSp:addChild(rankLb)
    
    local memberLb=GetTTFLabel(getlocal("alliance_scene_member_list"),lbSize)
    memberLb:setAnchorPoint(ccp(0.5,0.5))
    memberLb:setPosition(ccp(160+30+40-25,wholeBgSp:getContentSize().height/2))
    memberLb:setColor(G_ColorYellowPro2)
    wholeBgSp:addChild(memberLb)

    
    local dutyLb=GetTTFLabel(getlocal("alliance_scene_member_duty"),lbSize)
    dutyLb:setAnchorPoint(ccp(0.5,0.5))
    dutyLb:setPosition(ccp(350+25-25,wholeBgSp:getContentSize().height/2))
    dutyLb:setColor(G_ColorYellowPro2)
    wholeBgSp:addChild(dutyLb)

    local levelLb=GetTTFLabel(getlocal("RankScene_level"),lbSize)
    levelLb:setAnchorPoint(ccp(0.5,0.5))
    levelLb:setPosition(ccp(430+20-25,wholeBgSp:getContentSize().height/2))
    levelLb:setColor(G_ColorYellowPro2)
    wholeBgSp:addChild(levelLb)

	local lbbHeight =0
	if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="de" then
		lbbHeight =20
	end

    local attackLb=GetTTFLabelWrap(getlocal("alliance_activie_today"),lbSize,CCSizeMake(lbSize*5+20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    attackLb:setAnchorPoint(ccp(0.5,0.5))
    attackLb:setPosition(ccp(555-25,wholeBgSp:getContentSize().height/2))
    attackLb:setColor(G_ColorYellowPro2)
    wholeBgSp:addChild(attackLb)
    
    
    local donateLb=GetTTFLabelWrap(getlocal("alliance_activie_reset"),25,CCSizeMake(self.bgLayer2:getContentSize().width-90,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    donateLb:setPosition(ccp(G_VisibleSizeWidth/2,50))
    self.bgLayer2:addChild(donateLb)

    local function callBack2(...)
       return self:eventHandler2(...)
    end
    local hd2= LuaEventHandler:createHandler(callBack2)
    self.tv2=LuaCCTableView:createWithEventHandler(hd2,CCSizeMake(self.bgLayer2:getContentSize().width-50,G_VisibleSize.height-85-260-15-25),nil)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv2:setPosition(ccp(25,100))
    self.bgLayer2:addChild(self.tv2)
    self.tv2:setMaxDisToBottomOrTop(120)

	self.bgLayer:addChild(self.bgLayer2,2)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function newAllianceActiveWelfareDialog:eventHandler2(handler,fn,idx,cel)
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
	    local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
	    local function cellClick(hd,fn,idx)
	        --return self:cellClick(idx)
	    end
	 	cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,70))

	 	local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function ()end)
	 	grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,70))
	 	grayBgSp:setAnchorPoint(ccp(0.5,1))
	 	grayBgSp:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height))
	 	cell:addChild(grayBgSp) 

	 	if (idx+1)%2 == 1 then
	 		grayBgSp:setOpacity(0)
	 	end 


       -- if idx==0 then
       --     local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png");
       --     --bgSp:setAnchorPoint(ccp(0,0));
       --     bgSp:setPosition(ccp(310,35));
       --     bgSp:setScaleY(60/bgSp:getContentSize().height)
       --     bgSp:setScaleX(1200/bgSp:getContentSize().width)
       --     cell:addChild(bgSp)
       -- end

       
       self.memberCellTb[idx+1]=cell
       -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
       -- lineSp:setAnchorPoint(ccp(0,0));
       -- lineSp:setPosition(ccp(0,0));
       -- cell:addChild(lineSp,1)

        local lbSize=25
        local lbHeight=35
        local lbWidth=30
        local lbColor=G_ColorWhite
        local loginTime=tonumber(self.tableMemberTb2[idx+1].logined_at)
        if  tonumber(base.serverTime)-loginTime>24*60*60*7 then
            lbColor=G_ColorGray
        end

        local rankLb=GetTTFLabel(self.tableMemberTb2[idx+1].rank5,lbSize)
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
        --[[
        local roleMember="alliance_role"..self.tableMemberTb2[idx+1].role
        local dutyLb=GetTTFLabel(getlocal(roleMember),lbSize)
        ]]
        roleSp:setPosition(ccp(300-lbWidth+75,lbHeight))
        grayBgSp:addChild(roleSp)
        roleSp:setTag(101)
       
        local levelLb=GetTTFLabel(self.tableMemberTb2[idx+1].level,lbSize)
        levelLb:setPosition(ccp(372-lbWidth+80,lbHeight))
        grayBgSp:addChild(levelLb)
        levelLb:setTag(102)
        levelLb:setColor(lbColor)
        
        local apoint
        if G_isToday(self.tableMemberTb2[idx+1].apoint_at) then
            apoint=FormatNumber(tonumber(self.tableMemberTb2[idx+1].apoint))
        else
            apoint=0
        end
        local donateLb1=GetTTFLabel(apoint,lbSize)
        donateLb1:setPosition(ccp(468-lbWidth+90,lbHeight))
        grayBgSp:addChild(donateLb1)
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

--设置或修改每个Tab页签
function newAllianceActiveWelfareDialog:resetTab()
    self.allTabs={getlocal("serverwar_point_record"),getlocal("mainRank")}
    self:initTab(self.allTabs)
    local tabH=0
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
            tabBtnItem:setPosition(100,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-10-160)
         elseif index==1 then
            tabBtnItem:setPosition(248,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-10-160)
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

function newAllianceActiveWelfareDialog:initTab(tabTb)
   local tabBtn=CCMenu:create()
   local tabIndex=0
   local tabBtnItem;
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
function newAllianceActiveWelfareDialog:tabClick(idx)

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

    elseif self.selectedTabIndex==1 then
       self.bgLayer2:setVisible(true)
       self.bgLayer2:setPosition(ccp(0,0))
       
       self.bgLayer1:setVisible(false)
       self.bgLayer1:setPosition(ccp(10000,0))

    end
end

function newAllianceActiveWelfareDialog:refresh()
    self:getCanReward()
    if self.tv1 then
      self.tv1:reloadData()
    end
    if self.tv2 then
      self.tv2:reloadData()
    end
    self:updateShowBtn()
end


function newAllianceActiveWelfareDialog:dispose()
	self.bgLayer=nil
    self.layerNum=nil
    self.parent=nil

	self=nil
end