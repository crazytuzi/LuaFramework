acYuandanxianliDialogTab3 = {}

function acYuandanxianliDialogTab3:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.middleLineH=nil
	self.bgLayer=nil
	self.layerNum=nil
  self.isLastRew=nil
	self.days={}
	return nc
end

function acYuandanxianliDialogTab3:init( layerNum )
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()

	self:initUpDesc()
	self:initTableView(self.layerNum)

	return self.bgLayer
end

function acYuandanxianliDialogTab3:initUpDesc(  )
	
	local descTv1=G_LabelTableView(CCSize(480,100),getlocal("activity_yuandanxianli_everyDesc"),25,kCCTextAlignmentLeft)
    descTv1:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv1:setAnchorPoint(ccp(0,0))
    descTv1:setPosition(ccp(self.bgLayer:getContentSize().width*0.1-20,self.bgLayer:getContentSize().height*0.72))
    self.bgLayer:addChild(descTv1,5)
    descTv1:setMaxDisToBottomOrTop(30)

    local function showInfo()
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end 
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("activity_yuandanxianli_everyExplain3",24),"\n",getlocal("activity_yuandanxianli_everyExplain2",24),"\n",getlocal("activity_yuandanxianli_everyExplain1",24),"\n",}  --按钮内的说明信息
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-30,G_VisibleSize.height-170))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn,5)	--按钮

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX((G_VisibleSizeWidth)/lineSprite:getContentSize().width)
    lineSprite:setScaleY(1.2)
    lineSprite:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.72-10))
    self.bgLayer:addChild(lineSprite,6)

    local onlyBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),function () do return end end)
    onlyBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,140))
    onlyBg:setAnchorPoint(ccp(0.5,0))
    onlyBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,lineSprite:getPositionY()-150))
    self.bgLayer:addChild(onlyBg,4)

    local lineSprite2 = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite2:setScaleX((G_VisibleSizeWidth)/lineSprite:getContentSize().width)
    lineSprite2:setScaleY(1.2)
    lineSprite2:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,onlyBg:getPositionY()-10))
    self.bgLayer:addChild(lineSprite2,6)
    self.middleLineH=lineSprite2:getPositionY()

    local bigRe  = acYuandanxianliVoApi:getBigReward()
    local bigReward = FormatItem(bigRe,nil,true)
    if bigReward ~= nil then
       for k,v in pairs(bigReward) do
        local icon
        local icon,iconScale = G_getItemIcon(v,100,true,self.layerNum)
        icon:ignoreAnchorPointForPosition(false)
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(ccp(20+(k-1)*100,onlyBg:getContentSize().height/2))
        icon:setIsSallow(false)
        icon:setTouchPriority(-(self.layerNum-1)*20-4)
        onlyBg:addChild(icon)

        local nameLb=GetTTFLabel("x"..v.num,25)
        nameLb:setAnchorPoint(ccp(1,0))
        nameLb:setPosition(ccp(icon:getContentSize().width-10,5))
        icon:addChild(nameLb)
      end
    end

    --背景布上的领奖信息，以及领奖前后的判断和交互处理
    self.noBigre = GetTTFLabelWrap(getlocal("activity_dayRecharge_no"),30,CCSizeMake(170, 0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
    self.noBigre:setPosition(ccp(onlyBg:getContentSize().width*0.7,onlyBg:getContentSize().height*0.5))
    self.noBigre:setAnchorPoint(ccp(0,0.5))
    onlyBg:addChild(self.noBigre)
    self.noBigre:setVisible(false)

    local function rewardHandler(tag,object)
      PlayEffect(audioCfg.mouseClick)
      self:CanLastReward()
    end

    self.rewardBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rewardHandler,0,getlocal("daily_scene_get"),28)
    self.rewardBtn:setAnchorPoint(ccp(0, 0.5))
    local menuAward=CCMenu:createWithItem(self.rewardBtn)
    menuAward:setPosition(ccp(onlyBg:getContentSize().width*0.7,onlyBg:getContentSize().height*0.5))
    menuAward:setTouchPriority(-(self.layerNum-1)*20-4)
    self.rewardBtn:setVisible(false)
    onlyBg:addChild(menuAward,1) 
      

    local verticalLine = CCSprite:createWithSpriteFrameName("LineCross.png")
    verticalLine:setScaleX((G_VisibleSizeWidth)/verticalLine:getContentSize().width)
    verticalLine:setScaleY(0.7)
    verticalLine:setRotation(90)
    verticalLine:setPosition(ccp(self.bgLayer:getContentSize().width*0.3 ,self.bgLayer:getContentSize().height*0.3))
    self.bgLayer:addChild(verticalLine,-129)

    self:refreshRewardBtn()
end

function acYuandanxianliDialogTab3:CanLastReward( ) --取到最终大奖
    local function getRawardCallback(fn,data)
      local ret,sData = base:checkServerData(data)
      if ret==true then
        local bigRe  = acYuandanxianliVoApi:getBigReward()
        local bigReward = FormatItem(bigRe,nil,true)
        if bigReward ~= nil then
           for k,v in pairs(bigReward) do  
              G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num),nil,true)
           end
           G_showRewardTip(bigReward,true)
        end
        acYuandanxianliVoApi:setHadBigReward()
        self:refreshRewardBtn()
      end
    end
    socketHelper:activityYuandanxianliBig("getLastReward",getRawardCallback)
end


function acYuandanxianliDialogTab3:initTableView(layerNum )
	
	localHeight=self.middleLineH-45
	--self.panelLineBg:setVisible(false)
	local function callBack( ... )
		return self:eventHandler(...)
	end
	local hd = LuaEventHandler:createHandler(callBack)

	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,localHeight),nil)

	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setPosition(ccp(10,25))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(120)
  local day = acYuandanxianliVoApi:getCurrentDay()
  if day ==4 then
    self.tv:recoverToRecordPoint(ccp(0,-120))
  elseif day >=5 then
    self.tv:recoverToRecordPoint(ccp(0,0))
  end

end

function acYuandanxianliDialogTab3:eventHandler( handler,fn,idx,cel )
	if fn=="numberOfCellsInTableView" then
		return 7
	elseif fn =="tableCellSizeForIndex" then
		local tmpSize
    local cellHeight = 100
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-15,cellHeight)
		return tmpSize
	elseif fn =="tableCellAtIndex" then
		local  cell = CCTableViewCell:new()
		cell:autorelease()
		cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-15,100))

		local capInset = CCRect(20,20,10,10)
		local function cellClick( hd,fn,idx )
			
		end

    local curDay = acYuandanxianliVoApi:getCurrentDay()
    --curDay = 3  --用于测试（假设值）！！！！！！！！！！
    local allDayReward = acYuandanxianliVoApi:getAllReward()

    if idx+1 == curDay then
      local function nilFunc(hd,fn,idx)
      end

      local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(20, 20, 10, 10),nilFunc)
      titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,cell:getContentSize().height))
      titleBg:setScaleX((G_VisibleSizeWidth - 20)/titleBg:getContentSize().width)
      titleBg:setAnchorPoint(ccp(0.5,0.5))
      titleBg:setPosition(ccp((cell:getContentSize().width - 20)/2,cell:getContentSize().height/2))
      cell:addChild(titleBg)
    end


		self.days.idx=idx+1
  	local dayLabel = GetTTFLabelWrap(getlocal("activity_continueRecharge_dayDes",self.days),30,CCSizeMake(100, 0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
  	dayLabel:setAnchorPoint(ccp(0,0.5))
  	dayLabel:setPosition(ccp(30,cell:getContentSize().height*0.5))
  	cell:addChild(dayLabel)

	   local lineSpriteX = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSpriteX:setScaleX((G_VisibleSizeWidth)/lineSpriteX:getContentSize().width)
    lineSpriteX:setScaleY(1.2)
    lineSpriteX:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,cell:getContentSize().height))
    cell:addChild(lineSpriteX)
    if idx==6 then
  	  local lineSpriteX0 = CCSprite:createWithSpriteFrameName("LineCross.png")
	    lineSpriteX0:setScaleX((G_VisibleSizeWidth)/lineSpriteX0:getContentSize().width)
	    lineSpriteX0:setScaleY(1.2)
	    lineSpriteX0:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,0))
	    cell:addChild(lineSpriteX0)
		end

    local receivedSp =CCSprite:createWithSpriteFrameName("7daysCheckmark.png")--已签得图标（对勾）
    receivedSp:setPosition(ccp(cell:getContentSize().width*0.85,cell:getContentSize().height*0.5))
    cell:addChild(receivedSp)
    receivedSp:setVisible(false)

    local function buyGems( )  --跳转到充值页面    --前往
      if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if G_checkClickEnable()==false then
          do
          return
          end
        end
        activityAndNoteDialog:closeAllDialog()
        vipVoApi:showRechargeDialog(self.layerNum+1)--弹出充值页面
      end
    end
    local goItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",buyGems,idx,getlocal("activity_heartOfIron_goto"),28)
    goItem:setScale(0.8)
    local goBtn=CCMenu:createWithItem(goItem)
    goBtn:setTouchPriority(-(self.layerNum-1)*20-3)
    goBtn:setPosition(ccp(cell:getContentSize().width*0.85,cell:getContentSize().height*0.5))
    cell:addChild(goBtn)
    goItem:setVisible(false)
    goItem:setEnabled(false)


    local function toRece( )  --    --领取
      if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
      local allDayReward = acYuandanxianliVoApi:getAllReward()      
        if allDayReward[idx+1] ==1 then --是否达到领奖条件
          local function callback(fn,data )
            local ret,sData=base:checkServerData(data)
            if ret == true then
              if sData and sData.data and sData.data.yuandanxianli then
                local dailReward  = acYuandanxianliVoApi:getDailyReward()
                local dailyReward = FormatItem(dailReward[idx+1],nil,true)
                for k,v in pairs(dailyReward) do
                  G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num),nil,true)
                end
                G_showRewardTip(dailyReward,true)
                acYuandanxianliVoApi:setRece(idx+1)
                self:refresh()
              end
            end
          end
          local day = idx+1
          socketHelper:activityYuandanxianliSeven( "getDailyReward",day,callback)
        end
      end
      
    end
    local receItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",toRece,idx,getlocal("daily_scene_get"),28)
    receItem:setScale(0.8)
    local receBtn=CCMenu:createWithItem(receItem)
    receBtn:setTouchPriority(-(self.layerNum-1)*20-3)
    receBtn:setPosition(ccp(cell:getContentSize().width*0.85,cell:getContentSize().height*0.5))
    cell:addChild(receBtn)
    receItem:setVisible(false)
    receItem:setEnabled(false)


    local function toReTro( )  --    --补签
       if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
          if G_checkClickEnable()==false then
              do
                  return
              end
          else
              base.setWaitTime=G_getCurDeviceMillTime()
          end

          self:revisePanel(idx+1)
        end
    end
    local retroItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",toReTro,idx,getlocal("addSignBtn"),28,33)
    retroItem:setScale(0.8)
    local retroBtn=CCMenu:createWithItem(retroItem)
    retroBtn:setTouchPriority(-(self.layerNum-1)*20-3)
    retroBtn:setPosition(ccp(cell:getContentSize().width*0.85,cell:getContentSize().height*0.5))
    cell:addChild(retroBtn)
    retroItem:setVisible(false)
    retroItem:setEnabled(false)
    local lb=tolua.cast(retroItem:getChildByTag(33),"CCLabelTTF")
    lb:setColor(G_ColorRed)

    local featureLabel=GetTTFLabel(getlocal("activity_heartOfIron_goto"),25)
    featureLabel:setPosition(ccp(cell:getContentSize().width*0.85,cell:getContentSize().height*0.5))
    cell:addChild(featureLabel)
    featureLabel:setVisible(false)
    featureLabel:setColor(G_ColorGray)


--判断需显示那种图标 或按钮 或文字

    -- allDayReward[1]=2  --用于测试（假设值）！！！！！！！！！！
    -- allDayReward[3]=1  --用于测试（假设值）！！！！！！！！！！

    if idx+1 > curDay then                --大于当前天
      featureLabel:setVisible(false)
    elseif idx+1 ==curDay then            --等于当前天
      if allDayReward[idx+1] ==0 then
          goItem:setVisible(true)
          goItem:setEnabled(true)
      elseif allDayReward[idx+1] == 1 then
          receItem:setVisible(true)
          receItem:setEnabled(true)
      elseif allDayReward[idx+1] ==2 then
          receivedSp:setVisible(true)
      end
    elseif idx+1 <curDay then             --小于当前天
      if allDayReward[idx+1] ==1 then --领取
          receItem:setVisible(true)
          receItem:setEnabled(true)
      elseif allDayReward[idx+1] ==0 then --补签
          retroItem:setVisible(true)
          retroItem:setEnabled(true)
      elseif allDayReward[idx+1] ==2 then
          receivedSp:setVisible(true)
      end
    end

--7天奖励显示
    local dailReward  = acYuandanxianliVoApi:getDailyReward()
    local dailyReward = FormatItem(dailReward[idx+1],nil,true)

    if dailyReward ~= nil then
      for k,v in pairs(dailyReward) do
        local icon,iconScale = G_getItemIcon(v,100,true,self.layerNum)
        icon:ignoreAnchorPointForPosition(false)
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(ccp(190+(k-1)*65 ,cell:getContentSize().height*0.5))
        icon:setIsSallow(false)
        icon:setScale(0.6)
        icon:setTouchPriority(-(self.layerNum-1)*20-3)
        cell:addChild(icon)
    local scale=100/icon:getContentSize().width

        local nameLb=GetTTFLabel("x"..v.num,22)
        nameLb:setAnchorPoint(ccp(1,0))
        nameLb:setPosition(ccp(icon:getContentSize().width-10,5))
        nameLb:setScale(1.5/scale)
        icon:addChild(nameLb)
      end
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

function acYuandanxianliDialogTab3:dispose()
  self.bgLayer:removeFromParentAndCleanup(true)
  self.bgLayer=nil
  self.layerNum=nil
end

function acYuandanxianliDialogTab3:refreshRewardBtn()
  if acYuandanxianliVoApi:isAllReward() == true then
    if acYuandanxianliVoApi:getHadBigReward()>=1 then
      self.rewardBtn:setEnabled(false)
    else
      self.rewardBtn:setEnabled(true)
    end
    self.rewardBtn:setVisible(true)
    self.noBigre:setVisible(false)
  else
    self.rewardBtn:setVisible(false)
    self.rewardBtn:setEnabled(false)
    self.noBigre:setVisible(true)    
  end
end

function acYuandanxianliDialogTab3:refresh()
  self:refreshRewardBtn()
  if self and self.tv then
    local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
  end
end
--补签的跳转，现有问题：是扣掉已有的费用，还是跳转到充值页面
function acYuandanxianliDialogTab3:revisePanel(day)
  local needGems = acYuandanxianliVoApi:getReviseNeedMoneyByDay()
  if needGems>playerVoApi:getGems() then
    GemsNotEnoughDialog(nil,nil,needGems-playerVoApi:getGems(),self.layerNum+1,needGems)
  else
    local function usePropHandler(tag1,object)
        PlayEffect(audioCfg.mouseClick)
        local function reviseSuccess(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                playerVoApi:setValue("gems",playerVoApi:getGems()-needGems)
                -- acYuandanxianliVoApi:updateState()
                acYuandanxianliVoApi:afterSuppleSet(day)
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_continueRecharge_reviseSuc"),28)
                self:refresh()
            end
        end

        socketHelper:activityYuandanxianliSevenBQ("modify",day,reviseSuccess)
    end
    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),usePropHandler,getlocal("dialog_title_prompt"),getlocal("activity_continueRecharge_revise",{day,acYuandanxianliVoApi:getReviseNeedMoneyByDay(day)}),nil,self.layerNum+1)
  end
end
function acYuandanxianliDialogTab3:tick()
  
end


