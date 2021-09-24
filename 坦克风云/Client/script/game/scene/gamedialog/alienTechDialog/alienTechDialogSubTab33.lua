alienTechDialogSubTab33={}
function alienTechDialogSubTab33:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.layerNum=nil
	self.bgLayer=nil

	return nc
end

function alienTechDialogSubTab33:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self:initTableView()
	base:addNeedRefresh(self)
	return self.bgLayer
end

function alienTechDialogSubTab33:initTableView()
	local function callBack(...)
		return self:eventHandler3(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-410),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(25,145)
	self.bgLayer:addChild(self.tv,1)
	self.tv:setMaxDisToBottomOrTop(100)

	local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
	bgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-237))
	bgSp:setScaleY(55/bgSp:getContentSize().height)
	bgSp:setScaleX(self.bgLayer:getContentSize().width/bgSp:getContentSize().width)
	self.bgLayer:addChild(bgSp,1)

	local collectionLb=GetTTFLabelWrap(getlocal("alien_tech_collection_competence"),24,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	-- local collectionLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	collectionLb:setAnchorPoint(ccp(0.5,0.5))
	collectionLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-237))
	self.bgLayer:addChild(collectionLb,1)


	local function jumpHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if self.parent and self.parent.closeDialog then
        	self.parent:closeDialog()
        end
        mainUI:changeToWorld()
    end
    local buttonSize = 22
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        	buttonSize =24
    	end
    local jumpBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",jumpHandler,25,getlocal("alien_tech_go_collection"),buttonSize/0.8,101)
	jumpBtn:setScale(0.8)
	local btnLb = jumpBtn:getChildByTag(101)
	if btnLb then
		btnLb = tolua.cast(btnLb,"CCLabelTTF")
		btnLb:setFontName("Helvetica-bold")
	end
	local jumpMenu=CCMenu:createWithItem(jumpBtn)
    jumpMenu:setAnchorPoint(ccp(0.5,0.5))
    jumpMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,80))
    jumpMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(jumpMenu,2)

    local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local tabStr={"\n",getlocal("alien_tech_collection_info_4"),"\n",getlocal("alien_tech_collection_info_3"),"\n",getlocal("alien_tech_collection_info_2"),"\n",getlocal("alien_tech_collection_info_1"),"\n"}
		local tabColor={nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil}
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1) 
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
	-- infoItem:setScale(0.9)
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(550,80))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(infoBtn,2)
end

function alienTechDialogSubTab33:eventHandler3(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 3
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		self.cellHight =250
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        	self.cellHight =150
    	end
		tmpSize=CCSizeMake(G_VisibleSizeWidth-30,self.cellHight)
		return tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function ()end)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.cellHight-5))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setPosition(ccp(5,0))
		cell:addChild(backSprie,1)

		local resourceCfg=alienTechCfg.resource
		local rid="r"..(idx+1)
		local cfg=resourceCfg[rid]
		local iconStr=cfg.icon
		local nameStr=cfg.name
		local descStr=getlocal("alien_tech_collection_desc_"..(idx+1))
		local num=alienTechVoApi:getAlienDailyResByType(rid) or 0
		local maxNum=cfg.maxLv*playerVoApi:getPlayerLevel()
		local acVo = activityVoApi:getActivityVo("alienbumperweek")
		local isShowActivity = false
		local isImminentAc = false
		local vo=activityVoApi:getActivityVo("yichujifa")
		local addUpp=0
		local oldMaxNum = maxNum --保留原有最大上限
		if vo and activityVoApi:isStart(vo) == true then
			addUpp = acImminentVoApi:getUpperLimit()/100*maxNum
			-- addUpp=addUpp+maxNum
			isImminentAc =true
		end
		if acVo and activityVoApi:isStart(acVo)==true then
			local rate = acAlienbumperweekVoApi:getResRate()
			maxNum=maxNum*rate
			isShowActivity=true
		end
		if addUpp>0 then
			maxNum =maxNum+addUpp
		end
		if num>maxNum then
			num=maxNum
		end

		local icon=CCSprite:createWithSpriteFrameName(iconStr)
		icon:setScale(100/icon:getContentSize().height)
		icon:setAnchorPoint(ccp(0.5,0.5))
		icon:setPosition(ccp(70,self.cellHight/2))
		backSprie:addChild(icon)

		-- local numLb=GetTTFLabel(getlocal("propInfoNum",{FormatNumber(num)}),23)
		-- numLb:setAnchorPoint(ccp(0.5,0))
		-- numLb:setPosition(ccp(70,10))
		-- backSprie:addChild(numLb)
		nameStrSize =23
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        	nameStrSize =28
    	end
		local nameLb=GetTTFLabel(getlocal("alien_tech_collection_scheduleChapter",{getlocal(nameStr),FormatNumber(num),FormatNumber(maxNum)}),24,true)
		nameLb:setAnchorPoint(ccp(0,1))
		nameLb:setPosition(ccp(140,backSprie:getContentSize().height-10-10))
		nameLb:setColor(G_ColorYellowPro)
		backSprie:addChild(nameLb)

		

		if isShowActivity==true or isImminentAc == true then
			local rate = nil 
			if isShowActivity ==true then
				rate = acAlienbumperweekVoApi:getResRate()
			end
			-- local activityLb=GetTTFLabel("("..getlocal("activityAddDesc",{acAlienbumperweekVoApi:getResRateStr()})..")",23)

			local activityLb=GetTTFLabel("("..getlocal("activityAddDesc",{(maxNum-oldMaxNum)/oldMaxNum*100})..")",20)
			activityLb:setAnchorPoint(ccp(0,1))
			activityLb:setPosition(ccp(nameLb:getPositionX()+nameLb:getContentSize().width+5,backSprie:getContentSize().height-20))
			activityLb:setColor(G_ColorBlue3)
			backSprie:addChild(activityLb)

			if isImminentAc == true then
				local function tipClick( ... )
					local td=smallDialog:new()
					tabStr = {"\n",getlocal("activity_yichujifa_smTip",{getlocal("activity_yichujifa_title"),acImminentVoApi:getUpperLimit()}),"\n"}
					local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,{nil})			  
				  	sceneGame:addChild(dialog,self.layerNum+1)
				end 
				local scale=0.75
				local tipBtn=GetButtonItem("IconTip.png","IconTip.png","IconTip.png",tipClick,11,nil,nil)
				tipBtn:setScale(scale)
				local tipMenu=CCMenu:createWithItem(tipBtn)
				tipMenu:setAnchorPoint(ccp(0,1))
				tipMenu:setTouchPriority(-(self.layerNum-1)*20-4)
				tipMenu:setPosition(ccp(activityLb:getPositionX()+activityLb:getContentSize().width+25,nameLb:getPositionY()-12))
	            backSprie:addChild(tipMenu,4)
			end
		end

		local descLb=GetTTFLabelWrap(descStr,20,CCSizeMake(G_VisibleSizeWidth-220,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0,0.5))
		descLb:setPosition(ccp(140,(nameLb:getPositionY()-nameLb:getContentSize().height)/2))
		backSprie:addChild(descLb)

		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function alienTechDialogSubTab33:tick()
	alienTechVoApi:checkUpdateDailyRes()
	if alienTechVoApi:getResDailyFlag()==0 then
		if self.tv then
			self.tv:reloadData()
		end
		alienTechVoApi:setResDailyFlag(1)
	end

	-- local acImminentVo = activityVoApi:getActivityVo("yichujifa")
	-- local vo=acImminentVoApi:getAcVo()
	--   if acImminentVo and activityVoApi:isStart(vo) == true then -- 开启一触即发活动
	      
	--   end
end

function alienTechDialogSubTab33:dispose()
	base:removeFromNeedRefresh(self)
	self.bgLayer:removeFromParentAndCleanup(true)
	self.tv=nil
	self.layerNum=nil
	self.bgLayer=nil
end