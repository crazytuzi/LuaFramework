acShuijinghuikuiDialog = commonDialog:new()

function acShuijinghuikuiDialog:new()
	local  nc = {}
	setmetatable(nc,self)
	self.__index=self
	self.isToday = nil
	return nc
end

--初始化对话框面板
function acShuijinghuikuiDialog:initTableView( )
	
	-----拿数据
	self.isToday = acShuijinghuikuiVoApi:isToday()
	localHeight=self.bgLayer:getContentSize().height*0.25-30
	self.panelLineBg:setVisible(false)
	local function callBack( ... )
		return self:eventHandler(...)
	end
	local hd = LuaEventHandler:createHandler(callBack)

	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,localHeight*3),nil)

	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setPosition(ccp(10,20))
	--self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(120)
    

	local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
	actTime:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-110))
	actTime:setColor(G_ColorGreen)
	self.bgLayer:addChild(actTime,5)

	local acVo =acShuijinghuikuiVoApi:getAcVo()  ---
	if acVo ~=nil then
		local timeStr = activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
		local timeLabel=GetTTFLabel(timeStr,26)
		timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-145))
		self.bgLayer:addChild(timeLabel,5)
		self.timeLb=timeLabel
		G_updateActiveTime(vo,self.timeLb)
	end

	local function showInfo()
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("activity_shuijinghuikui_Tip4"),"\n",getlocal("activity_shuijinghuikui_Tip3",{acShuijinghuikuiVoApi:getGemsVate()}),"\n",getlocal("activity_shuijinghuikui_Tip2",{FormatNumber(acShuijinghuikuiVoApi:getDailyGold()),acShuijinghuikuiVoApi:getGemsVate()}),"\n",getlocal("activity_shuijinghuikui_Tip1"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setAnchorPoint(ccp(1,1))
    -- infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-35,self.bgLayer:getContentSize().height-95))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn,3)

   	local descBgH = 120
    if G_isIphone5()==true then
    	descBgH=170
    end
    local h = self.bgLayer:getContentSize().height-185

	local function nilFunc()
	end
	local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
	descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, descBgH))
	descBg:ignoreAnchorPointForPosition(false)
	descBg:setIsSallow(false)
	descBg:setTouchPriority(-(self.layerNum-1)*20-2)
	descBg:setAnchorPoint(ccp(0.5,1))
	descBg:setPosition(self.bgLayer:getContentSize().width/2,h)
	self.bgLayer:addChild(descBg)
	local desTv, desLabel = G_LabelTableView(CCSizeMake(self.bgLayer:getContentSize().width-60,descBgH-20),getlocal("activity_shuijinghuikui_content"),26,kCCTextAlignmentLeft)
	desLabel:setColor(G_ColorYellow)
	desTv:setPosition(ccp(10,10))
	desTv:setAnchorPoint(ccp(0,0))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	desTv:setMaxDisToBottomOrTop(70)
	descBg:addChild(desTv,5)

	h=h-descBgH-10
	local headBsH = 220
    if G_isIphone5()==true then
    	headBsH=300
    end

	local headBs=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
    headBs:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,headBsH))
    headBs:setAnchorPoint(ccp(0.5,1))
    headBs:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,h))
    self.bgLayer:addChild(headBs,4)

    local iconSp = CCSprite:createWithSpriteFrameName("iconGold3.png")
    iconSp:setAnchorPoint(ccp(0,0.5))
    iconSp:setScale(1.4)
    iconSp:setPosition(20,headBs:getContentSize().height/2)
    headBs:addChild(iconSp)

    local posHeight =0
    local posWidth =0
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="ru" then
        posHeight =20
    end
    if G_getCurChoseLanguage() == "ru" then
    	posWidth =30
    end
    for i=1,3 do
    	local giveLb = GetTTFLabel(getlocal("activity_shuijinghuikui_give"),20*i)
    	giveLb:setAnchorPoint(ccp(1,0.5))
        if i ==3 then
            giveLb:setPosition(130+(i-1)*70+50*i+posWidth,headBs:getContentSize().height/2+(i-1)*30+posHeight)
        else
            giveLb:setPosition(130+(i-1)*70+50*i+posWidth,headBs:getContentSize().height/2+(i-1)*30)
        end
    	headBs:addChild(giveLb)
    	giveLb:setColor(G_ColorYellow)
    end

    local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    lightSp:setScale(1.5)
    --lightSp:setColor(ccc3(255, 0, 255))
    lightSp:setAnchorPoint(ccp(0.5,0.5))
    lightSp:setPosition(headBs:getContentSize().width-100+posWidth,headBs:getContentSize().height/2)
    headBs:addChild(lightSp)

    local Crystal1=CCSprite:createWithSpriteFrameName("IconCrystal-.png")
    Crystal1:setScale(3)
    Crystal1:setAnchorPoint(ccp(0.5,0))
    Crystal1:setPosition(headBs:getContentSize().width-100,headBs:getContentSize().height/2-15)
    headBs:addChild(Crystal1)
    local Crystal2=CCSprite:createWithSpriteFrameName("IconCrystal-.png")
    Crystal2:setAnchorPoint(ccp(0.5,1))
    Crystal2:setScale(3)
    Crystal2:setPosition(headBs:getContentSize().width-140,headBs:getContentSize().height/2+30)
    headBs:addChild(Crystal2)
    local Crystal3=CCSprite:createWithSpriteFrameName("IconCrystal-.png")
    Crystal3:setAnchorPoint(ccp(0.5,1))
    Crystal3:setScale(3)
    Crystal3:setPosition(headBs:getContentSize().width-100,headBs:getContentSize().height/2+10)
    headBs:addChild(Crystal3)
    local Crystal4=CCSprite:createWithSpriteFrameName("IconCrystal-.png")
    Crystal4:setAnchorPoint(ccp(0.5,1))
    Crystal4:setScale(3)
    Crystal4:setPosition(headBs:getContentSize().width-60,headBs:getContentSize().height/2+20)
    headBs:addChild(Crystal4)

    local proportion = GetTTFLabel(getlocal("timeLabel2",{1,acShuijinghuikuiVoApi:getGemsVate()}),30)
    proportion:setAnchorPoint(ccp(0.5,0))
    proportion:setPosition(headBs:getContentSize().width/2,30)
    headBs:addChild(proportion)

    h=h-headBsH-10
    local backSprite1 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
    
    local borderHight=280
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() == "ru" then
        borderHight=305
    end
    backSprite1:setContentSize(CCSizeMake((self.bgLayer:getContentSize().width-40)/2,borderHight))
    backSprite1:setAnchorPoint(ccp(0.5,1))
    backSprite1:setPosition(self.bgLayer:getContentSize().width/4,h)
    self.bgLayer:addChild(backSprite1)

    local CrystalTv,CrystalLb= G_LabelTableView(CCSizeMake(backSprite1:getContentSize().width-20,100),getlocal("activity_shuijinghuikui_CrystalDesc",{acShuijinghuikuiVoApi:getGemsVate()}),25,kCCTextAlignmentCenter)
	CrystalTv:setPosition(ccp(10,backSprite1:getContentSize().height/2+30))
	CrystalTv:setAnchorPoint(ccp(0,0))
	CrystalTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	CrystalTv:setMaxDisToBottomOrTop(70)
	backSprite1:addChild(CrystalTv,5)

	local canRewardLb = GetTTFLabelWrap(getlocal("activity_shuijinghuikui_canGetCrystal"),25,CCSizeMake(backSprite1:getContentSize().width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	canRewardLb:setAnchorPoint(ccp(0,1))
	canRewardLb:setPosition(30,backSprite1:getContentSize().height/2+25)
	backSprite1:addChild(canRewardLb)
	canRewardLb:setColor(G_ColorYellow)

    local iconHpos=backSprite1:getContentSize().height/2-30
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() == "ru" then
        iconHpos =iconHpos -20
    end
	local icon = CCSprite:createWithSpriteFrameName("IconCrystal-.png")
	icon:setScale(1.2)
	icon:setAnchorPoint(ccp(0,0.4))
	icon:setPosition(30,iconHpos)
	backSprite1:addChild(icon)

    local iconNumPos=icon:getPositionY()
	self.numLb=GetTTFLabel("",25)
	self.numLb:setAnchorPoint(ccp(0,0.5))
	self.numLb:setPosition(30+icon:getContentSize().width+10,iconNumPos)
	backSprite1:addChild(self.numLb)

	local function CrystalReward( ... )
		if G_checkClickEnable()==false then
	      do
	        return
	      end
	    else
	    	base.setWaitTime=G_getCurDeviceMillTime()
	    end
	    PlayEffect(audioCfg.mouseClick)
		local function callBack(fn,data)
			local ret,sData=base:checkServerData(data)
			if(ret==true)then
				if sData.data.shuijinghuikui.clientReward then
					local reward = sData.data.shuijinghuikui.clientReward
					local content = {}
					for k,v in pairs(reward) do
						if v then
							local pType = v[1]
							local pid = v[2]
							local pNum = v[3]
							local award = {}
		                    local name,pic,desc,id,index,eType,equipId=getItem(pid,pType)
		                    award={name=name,num=pNum,pic=pic,desc=desc,id=id,type=pType,index=index,key=pid,eType=eType,equipId=equipId}
		                    G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
		                   	table.insert(content,award)
						end
					end
					G_showRewardTip(content)
				end
				if sData.data.shuijinghuikui.gems then
					acShuijinghuikuiVoApi:setAllRechargeNum(sData.data.shuijinghuikui.gems)
					self:updateRewardBtn()
				end
				acShuijinghuikuiVoApi:updateShow()
			end
		end

		socketHelper:activityShuijinghuikuiReward(acShuijinghuikuiVoApi:getAllRechargeNum(),callBack)
		
	end

	self.CrystalBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",CrystalReward,nil,getlocal("newGiftsReward"),25)
	local menu =CCMenu:createWithItem(self.CrystalBtn)
	menu:setPosition(ccp(backSprite1:getContentSize().width/2,50))
	menu:setTouchPriority(-(self.layerNum-1)*20-5)
	backSprite1:addChild(menu)

    local bspHeight =280
    local lbHpos =0
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() == "ru" then
        bspHeight =310
        lbHpos = 30
    end
    local backSprite2 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
    backSprite2:setContentSize(CCSizeMake((self.bgLayer:getContentSize().width-40)/2,bspHeight))
    backSprite2:setAnchorPoint(ccp(0.5,1))
    backSprite2:setPosition(self.bgLayer:getContentSize().width/4*3,h)
    self.bgLayer:addChild(backSprite2)

	local dayDescTv,dayDescLb= G_LabelTableView(CCSizeMake(backSprite2:getContentSize().width-20,backSprite2:getContentSize().height/2),getlocal("activity_shuijinghuikui_dayCrystalDesc",{FormatNumber(acShuijinghuikuiVoApi:getDailyGold())}),25,kCCTextAlignmentCenter)
	dayDescTv:setPosition(ccp(10,backSprite2:getContentSize().height/2-lbHpos))
	dayDescTv:setAnchorPoint(ccp(0,0))
	dayDescTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	dayDescTv:setMaxDisToBottomOrTop(70)
	backSprite2:addChild(dayDescTv,5)

    local function dayReward( ... )
		if G_checkClickEnable()==false then
	      do
	        return
	      end
	    else
	    	base.setWaitTime=G_getCurDeviceMillTime()
	    end
	    PlayEffect(audioCfg.mouseClick)

	    local function callBack(fn,data)
			local ret,sData=base:checkServerData(data)
			if(ret==true)then
				
				if sData.data.shuijinghuikui.clientReward then
					local reward = sData.data.shuijinghuikui.clientReward
					local content = {}
					for k,v in pairs(reward) do
						if v then
							local pType = v[1]
							local pid = v[2]
							local pNum = v[3]
							local award = {}
		                    local name,pic,desc,id,index,eType,equipId=getItem(pid,pType)
		                    award={name=name,num=pNum,pic=pic,desc=desc,id=id,type=pType,index=index,key=pid,eType=eType,equipId=equipId}
		                    G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
		                   	table.insert(content,award)
						end
					end
					G_showRewardTip(content)
				end
				acShuijinghuikuiVoApi:refreshDailyRechargeNum()
				self:updateDailyRewardBtn()
				acShuijinghuikuiVoApi:updateShow()
			end
		end

		socketHelper:activityShuijinghuikuiDailyReward(callBack)
	end

	self.dayRewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",dayReward,nil,getlocal("newGiftsReward"),25)
	local menu =CCMenu:createWithItem(self.dayRewardBtn)
	menu:setPosition(ccp(backSprite2:getContentSize().width/2,50))
	menu:setTouchPriority(-(self.layerNum-1)*20-5)
	backSprite2:addChild(menu)

	self.hadRewardLb = GetTTFLabelWrap(getlocal("activity_hadReward"),30,CCSizeMake(backSprite2:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	self.hadRewardLb:setPosition(backSprite2:getContentSize().width/2,50)
	backSprite2:addChild(self.hadRewardLb)
	self.hadRewardLb:setColor(G_ColorGreen)

	self:updateRewardBtn()
	self:updateDailyRewardBtn()

	local function rechange( ... )
		if G_checkClickEnable()==false then
	      do
	        return
	      end
	    else
	    	base.setWaitTime=G_getCurDeviceMillTime()
	    end
	    PlayEffect(audioCfg.mouseClick)
	    activityAndNoteDialog:closeAllDialog()
    	vipVoApi:showRechargeDialog(self.layerNum+1)
	end
	local rechangeBtn =GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",rechange,nil,getlocal("recharge"),25)
	local menu =CCMenu:createWithItem(rechangeBtn)
	menu:setPosition(ccp(G_VisibleSizeWidth/2,70))
	menu:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:addChild(menu)
end

function acShuijinghuikuiDialog:updateRewardBtn()
	local recharge = acShuijinghuikuiVoApi:getAllRechargeNum()
	if recharge and recharge>0 then
		self.CrystalBtn:setEnabled(true)
		self.numLb:setString(tostring(FormatNumber(recharge*acShuijinghuikuiVoApi:getGemsVate())))
	else
		self.CrystalBtn:setEnabled(false)
		self.numLb:setString(tostring(0))
	end
end

function acShuijinghuikuiDialog:updateDailyRewardBtn()
	local dailyRecharge = acShuijinghuikuiVoApi:getDailyRechargeNum()
	if dailyRecharge and dailyRecharge>0 then
		self.dayRewardBtn:setVisible(true)
		self.dayRewardBtn:setEnabled(true)
		self.hadRewardLb:setVisible(false)
	elseif dailyRecharge and dailyRecharge==0 then
		self.dayRewardBtn:setVisible(true)
		self.dayRewardBtn:setEnabled(false)
		self.hadRewardLb:setVisible(false)
	else
		self.dayRewardBtn:setVisible(false)
		self.dayRewardBtn:setEnabled(false)
		self.hadRewardLb:setVisible(true)
	end
end

function acShuijinghuikuiDialog:eventHandler( handler,fn,idx,cel )
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn =="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-15,localHeight)
		return tmpSize
	elseif fn =="tableCellAtIndex" then
		local  cell = CCTableViewCell:new()
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

function acShuijinghuikuiDialog:tick( ... )
    
	local istoday = acShuijinghuikuiVoApi:isToday()
	if istoday ~= self.isToday then
		self.isToday = istoday
		acShuijinghuikuiVoApi:refreshData()
		self:updateDailyRewardBtn()
		acShuijinghuikuiVoApi:updateShow()
	end
	if self.timeLb then
		local acVo = acShuijinghuikuiVoApi:getAcVo()
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acShuijinghuikuiDialog:update()
  local acVo = acShuijinghuikuiVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    end
  end 
end
function acShuijinghuikuiDialog:dispose( ... )
	self.isToday = nil
	self = nil
end