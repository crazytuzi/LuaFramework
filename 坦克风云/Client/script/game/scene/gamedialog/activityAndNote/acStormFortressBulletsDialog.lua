acStormFortressBulletsDialog=commonDialog:new()

function acStormFortressBulletsDialog:new(parent)
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	nc.tv =nil
	nc.downLb =nil
	nc.parent =parent
	nc.textLb={t1="rechargeGoldNums",t2="attMysticSystem",t3="snatchSupperArms",t4="equipStudy",t5="warExercise"}
	nc.AllNumsTb=acStormFortressVoApi:getTaskAllTb( )---------------------------从配置 拿到每个任务的总次数
	nc.picWidth=nil
	nc.picHeight=nil
  nc.isSelfParentClose =false
	nc.currBullet=acStormFortressVoApi:getCurrentBullet( )
	nc.taskRecedTb=acStormFortressVoApi:getTaskRecedTb()
	return nc
end
function acStormFortressBulletsDialog:dispose(isSelfParentClose)
  if self.parent and self.isSelfParentClose ==false then
    if isSelfParentClose ~=nil then
      self.isSelfParentClose =isSelfParentClose
    end
  	self.parent:refresh()
  end
	self.tv=nil
	self.downLb =nil
	self.picWidth=nil
	self.picHeight=nil
	self.currBullet=nil
	self.taskRecedTb=nil
	self.AllNumsTb=nil
	self.textLb=nil
  self.isSelfParentClose =nil
	self=nil
end

function acStormFortressBulletsDialog:initTableView( )
	local strSize2 = 22
  local kccAlig = kCCTextAlignmentLeft
  local subHeight2 = 20
  -- local kccVerAlig = kCCVerticalTextAlignmentTop
  	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
    	strSize2 =25
      kccAlig = kCCTextAlignmentCenter
      subHeight2 =40
  	end
	self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight-100))
  	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth*0.5, 5))

  	local function noData( ) end
  	local bgPic = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",CCRect(20, 20, 10, 10),noData)
  	bgPic:setContentSize(CCSizeMake(G_VisibleSizeWidth-22, G_VisibleSizeHeight-102))
  	bgPic:setAnchorPoint(ccp(0.5, 0))
  	bgPic:setOpacity(0)
  	bgPic:setPosition(ccp(G_VisibleSizeWidth*0.5+1, 6))
  	self.bgLayer:addChild(bgPic,1)

  	local picWidth = bgPic:getContentSize().width
  	local picHeight = bgPic:getContentSize().height
  	self.picWidth=picWidth
	self.picHeight=picHeight

  	local upLb = GetTTFLabelWrap(getlocal("activity_stormFortress_bulletDec"),strSize2,CCSizeMake(picWidth-20,0),kccAlig,kCCVerticalTextAlignmentTop)
  	upLb:setAnchorPoint(ccp(0.5,1))
  	upLb:setPosition(ccp(picWidth*0.5,picHeight-subHeight2))
  	bgPic:addChild(upLb)

  	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),noData)
  	tvBg:setContentSize(CCSizeMake(picWidth ,picHeight*0.8))
  	tvBg:setOpacity(0)
  	tvBg:setAnchorPoint(ccp(0,0))
  	tvBg:setPosition(ccp(0,100))
  	bgPic:addChild(tvBg)

  	local function callBack111(...)
	    return self:eventHandler(...)
	end
  	local hd= LuaEventHandler:createHandler(callBack111)
  	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(picWidth ,picHeight*0.8-30),nil)
  	bgPic:addChild(self.tv)
  	self.tv:setPosition(ccp(0,80))
  	self.tv:setAnchorPoint(ccp(0,0))
  	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
  	-- self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 3)
  	self.tv:setMaxDisToBottomOrTop(120)

  	local bulletNums = acStormFortressVoApi:getCurrentBullet( )--------获取当前炮弹数量
  	self.downLb = GetTTFLabelWrap(getlocal("activity_stormFortress_bulletNums",{bulletNums}),strSize2,CCSizeMake(picWidth-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
  	self.downLb:setColor(G_ColorYellow)
  	self.downLb:setAnchorPoint(ccp(0,0))
  	self.downLb:setPosition(ccp(10,30))
  	bgPic:addChild(self.downLb)
end

function acStormFortressBulletsDialog:eventHandler(handler,fn,idx,cel)
   local cellWidth = self.picWidth
   local cellHeight = (self.picHeight*0.6-30)/4
   local strSize2 = 22

  	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
    	strSize2 =25
  	end
   if fn=="numberOfCellsInTableView" then
       return 5
   elseif fn=="tableCellSizeForIndex" then
	   return    CCSizeMake(cellWidth,cellHeight)
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
 	   
 	     local function noData( ) end
       local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),noData)
  	   cellBg:setContentSize(CCSizeMake(cellWidth ,cellHeight-10))
  	   cellBg:setOpacity(250)
  	   cellBg:setAnchorPoint(ccp(0.5,1))
  	   cellBg:setPosition(ccp(cellWidth*0.5,cellHeight-2))
  	   cell:addChild(cellBg)

  	   local bulletIconBg = CCSprite:createWithSpriteFrameName("Icon_BG.png")----------------------需要弹药的图标
       bulletIconBg:setScale(1.3)
       bulletIconBg:setAnchorPoint(ccp(0,0.5))
       bulletIconBg:setPosition(ccp(10,cellHeight*0.5))
       cell:addChild(bulletIconBg,1)

       local bulletIcon = CCSprite:createWithSpriteFrameName("dartIcon.png")----------------------弹药的图标
       -- bulletIcon:setScale(1.3)
       bulletIcon:setAnchorPoint(ccp(0.5,0.5))
       bulletIcon:setPosition(getCenterPoint(bulletIconBg))
       bulletIconBg:addChild(bulletIcon,1)

       local numLabel=GetTTFLabel("x"..self.AllNumsTb["t"..idx+1][2],21)
       numLabel:setAnchorPoint(ccp(1,0))
       numLabel:setPosition(bulletIconBg:getContentSize().width-5, 5)
       numLabel:setScale(0.75)
       bulletIconBg:addChild(numLabel,1)


       local titleLb = GetTTFLabelWrap(getlocal(self.textLb["t"..idx+1],{self.AllNumsTb["t"..idx+1][1]}),strSize2,CCSizeMake(self.picWidth-280,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
       titleLb:setAnchorPoint(ccp(0,1))
       titleLb:setPosition(ccp(40+bulletIconBg:getContentSize().width,cellHeight*0.5+bulletIconBg:getContentSize().height*0.5))
       cell:addChild(titleLb)

       -----------------------------------------需要确定完成进度的数据
       local taskRecedNum = 0
       local showRecedNums = 0
       if SizeOfTable(self.taskRecedTb)>0 and self.taskRecedTb["t"..idx+1] then
       	taskRecedNum =self.taskRecedTb["t"..idx+1]
        if math.abs(taskRecedNum) > self.AllNumsTb["t"..idx+1][1] then
          showRecedNums =self.AllNumsTb["t"..idx+1][1]
        else
          showRecedNums = taskRecedNum
        end
       end
       -- print("showRecedNums----->",showRecedNums,SizeOfTable(self.taskRecedTb))
       local numsNow =GetTTFLabelWrap(getlocal("schedule_count",{math.abs(showRecedNums),self.AllNumsTb["t"..idx+1][1]}),strSize2,CCSizeMake(self.picWidth-270,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
       numsNow:setAnchorPoint(ccp(0,0))
       numsNow:setPosition(ccp(40+bulletIconBg:getContentSize().width,cellHeight*0.5-bulletIconBg:getContentSize().height*0.5))
       cell:addChild(numsNow)


       	local function getReward(tag,object)
  	  		-- print("tag----->",tag)
  	  		self:getReward(tag,object)
	  	  end
       	local btnLb = "daily_scene_get"
       	if taskRecedNum <0 then
       		btnLb ="activity_hadReward"
       	end
  		local recBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",getReward,nil,getlocal(btnLb),strSize2)
  		recBtn:setAnchorPoint(ccp(1,0.5))
  		recBtn:setTag(idx+1)
  		local recBtnMenu=CCMenu:createWithItem(recBtn);
  		recBtnMenu:setTouchPriority(-(self.layerNum-1)*20-3);
  		recBtnMenu:setPosition(ccp(cellBg:getContentSize().width-10,cellBg:getContentSize().height*0.5))
  		cellBg:addChild(recBtnMenu)

      --activity_heartOfIron_goto
      local function goToCall( tag,object )
        self:goToFun(tag)
      end
      local goToBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",goToCall,nil,getlocal("activity_heartOfIron_goto"),strSize2)
      goToBtn:setAnchorPoint(ccp(1,0.5))
      goToBtn:setTag(idx+1)
      goToMenu = CCMenu:createWithItem(goToBtn)
      goToMenu:setTouchPriority(-(self.layerNum-1)*20-3)
      goToMenu:setPosition(ccp(cellBg:getContentSize().width-10,cellBg:getContentSize().height*0.5))
      cellBg:addChild(goToMenu)

      -- print("taskRecedNum < self.AllNumsTb[t..idx+1][1]------------>",taskRecedNum , self.AllNumsTb["t"..idx+1][1])
  		if taskRecedNum < self.AllNumsTb["t"..idx+1][1] or taskRecedNum < 0  then
       		recBtn:setEnabled(false)

     	end
      if math.abs(taskRecedNum) >=self.AllNumsTb["t"..idx+1][1] then
          goToBtn:setVisible(false)
      end

       cell:autorelease()
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acStormFortressBulletsDialog:goToFun(tag)
  
    if tag ==1 then
      self:close()
      self.parent:close()
      activityAndNoteDialog:closeAllDialog()
      vipVoApi:showRechargeDialog(self.layerNum+1)
    elseif tag ==2 then-- 超级武器
      self:close()
      self.parent:close()
      activityAndNoteDialog:closeAllDialog()
      G_goToDialog("wp",self.layerNum+1)
    elseif tag ==3 then
      self:close()
      self.parent:close()
      activityAndNoteDialog:closeAllDialog()
      G_goToDialog("wh",self.layerNum+1)
    elseif tag ==4 then
      self:close()
      self.parent:close()
      activityAndNoteDialog:closeAllDialog()
      G_goToDialog("hy",self.layerNum+1)
    elseif tag ==5 then
      self:close()
      self.parent:close()
      activityAndNoteDialog:closeAllDialog()
      G_goToDialog("mb",self.layerNum+1)
    else
      print("wrong tag------>",tag)
    end
    
end


function acStormFortressBulletsDialog:getReward(tag,object)
  -- print("in getReward~~~~")
	local function callback(fn,data)
    	local ret,sData = base:checkServerData(data)
        if ret==true then
	        	if sData and sData.data and sData.data.stormFortress and sData.data.stormFortress.info then
	        		local info = sData.data.stormFortress.info
	        		acStormFortressVoApi:setCurrentBullet(info.missile)--重置炮弹数量
              acStormFortressVoApi:updateTaskRefTime(info.t)
	        		if info.d and info.d.task then
		        		acStormFortressVoApi:setTaskRecedTb(info.d.task)--重置任务领奖状态
                self.taskRecedTb=acStormFortressVoApi:getTaskRecedTb()
		        	end
              self.tv:reloadData()
              self.downLb:setString(getlocal("activity_stormFortress_bulletNums",{acStormFortressVoApi:getCurrentBullet( )}))
              smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
              acStormFortressVoApi:updateShow()
            end
        end
    end
    socketHelper:stormFortressSock(callback,3,nil,nil,"t"..tag)
end
