searchResultSmallDialog=smallDialog:new()

function searchResultSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.reward={}
	self.dialogHeight=600
	self.dialogWidth=550
	-- self.pageCellNum=10
	self.cellHeight=120
	return nc
end

function searchResultSmallDialog:init(layerNum,eid)
	self.layerNum=layerNum
	self.eid=eid

	local report=emailVoApi:getReport(self.eid)
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.dialogLayer=CCLayer:create()
	
	if report and report.searchtype~=1 then
		self.dialogHeight=400
	end
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgSize=size
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
		 
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)

	
	if report==nil then
		do return end
	end


	local lbSize2 = 30
	if G_getCurChoseLanguage() =="ko" then
		lbSize2 =25
	end
	local titleLb=GetTTFLabelWrap(getlocal("search_report_title_3305"),lbSize2,CCSizeMake(self.dialogWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)

	--确定
    local function sureHandler()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem)
    sureMenu:setPosition(ccp(self.dialogWidth/2,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:addChild(sureMenu)

	

    local lbSize=25
	local searchtype=report.searchtype
	if searchtype==1 then
		local rect = CCRect(0, 0, 50, 50)
	    local capInSet = CCRect(20, 20, 10, 10)
	    local function cellClick(hd,fn,idx)
	    end
	    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
		backSprie:setContentSize(CCSizeMake(self.bgSize.width-50, 150))
	    backSprie:ignoreAnchorPointForPosition(false)
	    backSprie:setAnchorPoint(ccp(0.5,1))
	    backSprie:setIsSallow(false)
	    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		backSprie:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-170))
	    self.bgLayer:addChild(backSprie)


	    local leftPosX1=25
	    local leftPosX2=40
	    local placex,placey
	    local nameStr=G_getIslandName(report.islandType,report.name)
		if report and report.place and report.place[1] then
			placex,placey=report.place[1],report.place[2]
		elseif report and report.place and report.place.x then
			placex,placey=report.place.x,report.place.y
		end
		local posStr=getlocal("collect_border_name_loc",{nameStr,placex,placey})
		-- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		-- local lbTb={
	 --        {str,lbSize,ccp(0,0.5),ccp(leftPosX1,self.bgSize.height-130),self.bgLayer,1,G_ColorWhite,CCSize(self.bgSize.width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
	 --        {str,lbSize,ccp(0,0.5),ccp(leftPosX2,220),self.bgLayer,1,G_ColorWhite,CCSize(self.bgSize.width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
	 --        {str,lbSize,ccp(0,0.5),ccp(leftPosX2,155),self.bgLayer,1,G_ColorRed,CCSize(self.bgSize.width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
	 --        {str,lbSize,ccp(0,0.5),ccp(leftPosX2,155),self.bgLayer,1,G_ColorWhite,CCSize(self.bgSize.width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},

	 --        {str,lbSize,ccp(0,0.5),ccp(100,backSprie:getContentSize().height/2+40),backSprie,1,G_ColorWhite,CCSize(backSprie:getContentSize().width-230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
	 --        {str,lbSize,ccp(0,0.5),ccp(100,backSprie:getContentSize().height/2),backSprie,1,G_ColorWhite,CCSize(backSprie:getContentSize().width-230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
	 --    }
	    local lbTb={
	        {getlocal("search_fleet_desc1",{report.name}),lbSize,ccp(0,0.5),ccp(leftPosX1,self.bgSize.height-130),self.bgLayer,1,G_ColorWhite,CCSize(self.bgSize.width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
	        {getlocal("search_fleet_desc2"),lbSize,ccp(0,0.5),ccp(leftPosX2,235),self.bgLayer,1,G_ColorWhite,CCSize(self.bgSize.width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
	        {getlocal("search_fleet_desc3"),lbSize,ccp(0,0.5),ccp(leftPosX2,170),self.bgLayer,1,G_ColorRed,CCSize(self.bgSize.width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
	        {getlocal("search_fleet_desc4"),lbSize,ccp(0,0.5),ccp(leftPosX2,170),self.bgLayer,1,G_ColorWhite,CCSize(self.bgSize.width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},

	        {posStr,lbSize,ccp(0,0.5),ccp(100,backSprie:getContentSize().height/2+40),backSprie,1,G_ColorWhite,CCSize(backSprie:getContentSize().width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
	        {getlocal("search_fleet_report_desc_4",{FormatNumber(report.power)}),lbSize,ccp(0,0.5),ccp(100,backSprie:getContentSize().height/2),backSprie,1,G_ColorWhite,CCSize(backSprie:getContentSize().width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
	    }
	    for k,v in pairs(lbTb) do
	        local lb=GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
	        if report.isHasFleet==1 then
	        	if k==4 then
	        		lb:setVisible(false)
	        	end
	        else
	        	if k==3 then
	        		lb:setVisible(false)
	        	end
	        end
	    end

	    local occupyIcon=CCSprite:createWithSpriteFrameName("IconOccupy.png")
	    occupyIcon:setPosition(ccp(50,backSprie:getContentSize().height/2))
	    backSprie:addChild(occupyIcon,1)

	    local curRes,maxRes=report.curRes or 0,report.fleetload or 0
	    AddProgramTimer(backSprie,ccp(220,backSprie:getContentSize().height/2-40),9,12,getlocal("attckarrivade"),"TeamTravelBarBg.png","TeamTravelBar.png",11,0.9,0.9)
	    local moneyTimerSprite = tolua.cast(backSprie:getChildByTag(9),"CCProgressTimer")
	    local per=curRes/maxRes*100
	    moneyTimerSprite:setPercentage(per)
	    local lbPer = tolua.cast(moneyTimerSprite:getChildByTag(12),"CCLabelTTF")
	    lbPer:setString(getlocal("stayForResource",{FormatNumber(curRes),FormatNumber(maxRes)}))


	    local function attackHandler()
	    	if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
	        PlayEffect(audioCfg.mouseClick)
	        
	        require "luascript/script/game/scene/gamedialog/warDialog/tankAttackDialog"
			local island={type=report.islandType,x=placex,y=placey}
            local td=tankAttackDialog:new(type,island,self.layerNum+1)
            local tbArr={getlocal("AEFFighting"),getlocal("dispatchCard"),getlocal("repair")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("AEFFighting"),true,self.layerNum+1)
            sceneGame:addChild(dialog,self.layerNum+1)
	    end
	    local attackItem=GetButtonItem("IconAttackBtn.png","IconAttackBtn_Down.png","IconAttackBtn_Down.png",attackHandler)
	    local attackMenu=CCMenu:createWithItem(attackItem)
	    attackMenu:setPosition(ccp(backSprie:getContentSize().width-40,backSprie:getContentSize().height/2))
	    attackMenu:setTouchPriority(-(layerNum-1)*20-4)
	    backSprie:addChild(attackMenu)

	    local function showInfoHandler()
	    	if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
	        PlayEffect(audioCfg.mouseClick)

	        require "luascript/script/game/scene/gamedialog/emailDetailDialog"
            local layerNum=self.layerNum+1
            local td=emailDetailDialog:new(layerNum,2,self.eid)
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("search_report_title_3305"),false,layerNum)
            sceneGame:addChild(dialog,layerNum)
	    end
	    local scale=0.9
	    local infoItem=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfoHandler)
	    infoItem:setScale(scale)
	    local infoMenu=CCMenu:createWithItem(infoItem)
	    infoMenu:setPosition(ccp(backSprie:getContentSize().width-110,backSprie:getContentSize().height/2))
	    infoMenu:setTouchPriority(-(layerNum-1)*20-4)
	    backSprie:addChild(infoMenu)


	    --继续侦查
	    local function goOnSearchHandler()
	    	if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
	        PlayEffect(audioCfg.mouseClick)

			local function mapRadarscanCallback()
	        	self:close()
	        end
	        local targetName=report.name or ""
		    bagVoApi:mapRadarscan("p3305",targetName,layerNum,mapRadarscanCallback)
	    end
	    local goOnItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",goOnSearchHandler,2,getlocal("go_on_search_btn"),25)
	    local goOnMenu=CCMenu:createWithItem(goOnItem)
	    goOnMenu:setPosition(ccp(self.dialogWidth/2,55))
	    goOnMenu:setTouchPriority(-(layerNum-1)*20-2)
	    self.bgLayer:addChild(goOnMenu)

	    if report.isHasFleet==1 then
	    	sureMenu:setPosition(ccp(self.dialogWidth/2-150,55))
	    	goOnMenu:setPosition(ccp(self.dialogWidth/2+150,55))

	    	local pNum=bagVoApi:getItemNumId(3305) or 0
	    	if pNum then
		    	local propNumLb=GetTTFLabel(getlocal("sample_prop_name_3305")..": "..pNum,25)
		    	propNumLb:setPosition(self.dialogWidth/2+150,110)
		    	self.bgLayer:addChild(propNumLb,1)
			    if pNum>0 then
			    else
			    	propNumLb:setColor(G_ColorRed)
			    	goOnItem:setEnabled(false)
			    end
			end
		else
			goOnItem:setVisible(false)
			goOnItem:setEnabled(false)
		end
	elseif searchtype==2 then
		local lbTb={
	        {getlocal("search_fleet_desc6"),lbSize,ccp(0.5,0.5),ccp(self.bgSize.width/2,self.bgSize.height/2),self.bgLayer,1,G_ColorWhite,CCSize(self.bgSize.width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
	    }
	    for k,v in pairs(lbTb) do
	        local lb=GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
	    end
	elseif searchtype==3 then
		local lbTb={
	        {getlocal("search_fleet_desc4"),lbSize,ccp(0.5,0.5),ccp(self.bgSize.width/2,self.bgSize.height/2+40),self.bgLayer,1,G_ColorWhite,CCSize(self.bgSize.width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
	        {getlocal("search_fleet_desc5"),lbSize,ccp(0.5,0.5),ccp(self.bgSize.width/2,self.bgSize.height/2-40),self.bgLayer,1,G_ColorWhite,CCSize(self.bgSize.width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
	    }
	    for k,v in pairs(lbTb) do
	        local lb=GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
	    end
	end

	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end
