require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2MapDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2CityRankDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2BidDialog"
-- require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/war2RecordDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2Dialog"

allianceWar2OverviewDialog=commonDialog:new()

function allianceWar2OverviewDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum
	self.mapList=nil
	self.dialogList=nil
	self.mapLayer=nil
	self.curMapDialog=nil
	self.selectedCityID=nil
	self.selectedCityData=nil
	self.countdown=nil
	self.status={-1,-1}
	self.cdSpTab={}
	self.lastNumSpTab={}
	self.battleEnd=false
	self.expiredTime=0
	self.callNum=0
	self.cityStatus={-1,-1}
	
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
	spriteController:addPlist("public/acLuckyCat.plist") 
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acChunjiepansheng.plist")
	spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar2.plist")
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar.plist")
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/serverWarLocal/serverWarLocal2.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/serverWarLocal/serverWarLocalCity.plist")

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acNewYearsEva.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	return nc
end

function allianceWar2OverviewDialog:doUserHandler()
	local function callback(result)
		if(result)then
			local cityID=1
			if allianceWar2VoApi.targetCity then
				cityID=allianceWar2VoApi.targetCity
			end
			local function callback1(resultcityID,result1)
				if(result1)then
					self.selectedCityID=resultcityID
					self.selectedCityData=allianceWar2VoApi:getCityDataByID(resultcityID)
					self:initWithData()
				end
			end
			allianceWar2VoApi:requestCityInfo(cityID,callback1)
		end
	end
	allianceWar2VoApi:requestAllianceWarInfo(callback)

	G_AllianceWarDialogTb["allianceWar2OverviewDialog"]=self
end

function allianceWar2OverviewDialog:initWithData()
	self.battleEnd=allianceWar2VoApi:getIsEnd()
	self:initPage()
	self:initBtn()
	self:resize()
	-- local targetCfg=allianceWar2VoApi:getCityCfgByID(allianceWar2VoApi.targetCity)
	-- if(targetCfg and targetCfg.area==allianceWar2VoApi.todayArea and allianceWar2VoApi.targetState>0)then
	if(allianceWar2VoApi.targetState>0)then
		self:showCityInfo(allianceWar2VoApi.targetCity)
	else
		self:showCityInfo(1)
		-- if(allianceWar2VoApi.todayArea==1)then
		-- 	self:showCityInfo(1)
		-- else
		-- 	self:showCityInfo(5)
		-- end
	end
	self:initTableView1()
end

function allianceWar2OverviewDialog:initTableView()

end

function allianceWar2OverviewDialog:initTableView1()
    local function callBack(...)
		return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-550),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setPosition(ccp(20,135))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    self:resetForbidLayer()
end

function allianceWar2OverviewDialog:resetForbidLayer()
    if self and self.topforbidSp and self.bottomforbidSp then
        self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-100))
        self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,100))
        self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height-400))
    end
end

function allianceWar2OverviewDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
	   	self.cellHight = 500
		return  CCSizeMake(600,self.cellHight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local statusStr=""
		local descStr=""
		local cityName=""
		local selectedCityID=self.selectedCityID
		local selectedCityData=self.selectedCityData
		local status=allianceWar2VoApi:getStatus(selectedCityID)
		local isShowVS=false
		local allianceName1=getlocal("fight_content_null")
		local allianceName2=getlocal("fight_content_null")
		local cityCfg=allianceWar2VoApi:getCityCfgByID(selectedCityID)
		if cityCfg and cityCfg.name then
			cityName=getlocal(cityCfg.name)
		end

		-- print("status",status)
        if status==0 or status==50 then
            statusStr=getlocal("allianceWar2_wait_signup")
            descStr=getlocal("allianceWar2_signup_start")
		elseif status==40 then
			statusStr=getlocal("local_war_occupied_time")
			if selectedCityData and selectedCityData.ownerName then
				descStr=selectedCityData.ownerName
			else
				descStr=getlocal("allianceWar2_no_occupied")
			end
		elseif status>=10 and status<20 then
			statusStr=getlocal("allianceWar2_signup_time")
			if allianceWar2VoApi.targetCity and allianceWar2VoApi.targetCity==selectedCityID then
				descStr=getlocal("allianceWar2_signup_end_wait",{cityName})
			else
				descStr=getlocal("allianceWar2_signup_cdTime")
			end
		elseif status>=20 and status<40 then
			if status>=20 and status<30 then
				statusStr=getlocal("allianceWar2_battle_prepare")
			else
				statusStr=getlocal("serverwarteam_battleing")
			end
			-- print("selectedCityData.allianceName1",selectedCityData.allianceName1)
			-- print("selectedCityData.allianceName2",selectedCityData.allianceName2)
			if selectedCityData and (selectedCityData.allianceName1 or selectedCityData.allianceName2) then
				if selectedCityData.allianceName1 then
					allianceName1=selectedCityData.allianceName1
				end
				if selectedCityData.allianceName2 then
					allianceName2=selectedCityData.allianceName2
				end
				descStr=getlocal("allianceWar2_vs",{allianceName1,allianceName2})
				isShowVS=true
			else
				descStr=getlocal("allianceWar2_battle_no_body")
			end
		end
		local cellWidth=600

		local posy=self.cellHight-40
		if G_getIphoneType() == G_iphoneX then
			posy = posy - 60
		end
		local statusLb=GetTTFLabelWrap(statusStr,25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		statusLb:setAnchorPoint(ccp(0,0.5))
		statusLb:setPosition(20,posy)
		statusLb:setColor(G_ColorYellowPro)
		cell:addChild(statusLb,1)

		local cdTime=0
		if self.countdown and self.countdown>0 then
			cdTime=self.countdown
		end
		-- print("cdTime",cdTime)
		local hours=math.floor(cdTime/3600)
		local minutes=math.floor((cdTime%3600)/60)
		local seconds=cdTime%60
		local numTab={math.floor(hours/10),hours%10,math.floor(minutes/10),minutes%10,math.floor(seconds/10),seconds%10}
		self.cdSpTab={}
		-- G_dayin(numTab)
		for i=1,6 do
			local numBg=CCSprite:createWithSpriteFrameName("goldSpr.png")
			local scale=50/numBg:getContentSize().height
			local spacex=numBg:getContentSize().width*scale
			local posx=cellWidth/2-spacex*3.5+(i-1)*spacex+math.floor((i-1)/2)*spacex
			numBg:setPosition(ccp(posx,posy))
			cell:addChild(numBg,1)
			numBg:setScale(scale)

			local num=numTab[i]
			-- print("num",num)
			-- local numLb=GetTTFLabel(numTab[i],30)
			-- numLb:setPosition(getCenterPoint(numBg))
			-- numBg:addChild(numLb,1)
			-- numLb:setColor(G_ColorYellowPro)
			-- numLb:setScale(1/scale)
			local numSp=CCSprite:createWithSpriteFrameName("numb_"..num..".png")
			numSp:setPosition(getCenterPoint(numBg))
			numSp:setTag(500+i)
			numBg:addChild(numSp,1)
			-- numSp:setScale(1/scale)

			if i==2 or i==4 then
				local colonLb=GetTTFLabel(":",35)
				local px
				if i==2 then
					px=cellWidth/2-spacex*3.5+i*spacex
				else
					px=cellWidth/2-spacex*3.5+i*spacex+spacex
				end
				colonLb:setPosition(ccp(px,posy))
				cell:addChild(colonLb,1)
				colonLb:setColor(G_ColorYellowPro)
			end
			table.insert(self.cdSpTab,numBg)
		end
		self.lastNumSpTab=numTab

		posy=posy-60
		if G_getIphoneType() == G_iphoneX then
			posy = posy - 40
		end
		if isShowVS==true then
			-- local titleBg1=CCSprite:createWithSpriteFrameName("orangeMask.png")
			-- titleBg1:setPosition(ccp(100,posy))
			-- cell:addChild(titleBg1)
			local allianceNameLb1=GetTTFLabel(allianceName1,30)
			allianceNameLb1:setPosition(ccp(125,posy))
			cell:addChild(allianceNameLb1,1)
			-- local titleBg2=CCSprite:createWithSpriteFrameName("orangeMask.png")
			-- titleBg2:setPosition(ccp(cellWidth-100,posy))
			-- cell:addChild(titleBg2)
			local allianceNameLb2=GetTTFLabel(allianceName2,30)
			allianceNameLb2:setPosition(ccp(cellWidth-125,posy))
			cell:addChild(allianceNameLb2,1)

			local vsSp=CCSprite:createWithSpriteFrameName("awVS.png")
			vsSp:setPosition(ccp(cellWidth/2,posy))
			cell:addChild(vsSp,1)
			local vsSp1=CCSprite:createWithSpriteFrameName("awVS1.png")
			vsSp1:setPosition(ccp(cellWidth/2,posy))
			cell:addChild(vsSp1,2)
		    local fadeIn=CCFadeIn:create(0.5)
		    local fadeOut=CCFadeOut:create(0.5)
		    local seq=CCSequence:createWithTwoActions(fadeIn,fadeOut)
		    vsSp1:runAction(CCRepeatForever:create(seq))

		    local lbBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
			lbBg:setPosition(ccp(cellWidth/2,posy))
			cell:addChild(lbBg)
			local lbBg1=CCSprite:createWithSpriteFrameName("awYellowBg.png")
			lbBg1:setPosition(ccp(cellWidth/2,posy))
			cell:addChild(lbBg1) 
		else
			local descLb=GetTTFLabelWrap(descStr,30,CCSizeMake(cellWidth-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			descLb:setPosition(cellWidth/2,posy)
			cell:addChild(descLb,1)
		end
		-- local lbBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
		-- lbBg:setPosition(ccp(cellWidth/2,posy))
		-- cell:addChild(lbBg)
		-- local lbBg1=CCSprite:createWithSpriteFrameName("awYellowBg.png")
		-- lbBg1:setPosition(ccp(cellWidth/2,posy))
		-- cell:addChild(lbBg1) 

	    posy=posy-60
	    if G_getIphoneType() == G_iphoneX then
	    	posy = posy-40
	    end
	    local rewardBg1=CCSprite:createWithSpriteFrameName("orangeMask.png")
		rewardBg1:setPosition(ccp(cellWidth/2,posy))
		cell:addChild(rewardBg1)
	    local reward1Lb=GetTTFLabelWrap(getlocal("allianceWar2_reward1_title",{cityName}),25,CCSizeMake(cellWidth-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		reward1Lb:setPosition(cellWidth/2,posy)
		cell:addChild(reward1Lb,1)
		
		local spacew=130
		local reward1Cfg
		if cityCfg and cityCfg.type and allianceWar2Cfg["reward"..cityCfg.type] and allianceWar2Cfg["reward"..cityCfg.type].reward then
			reward1Cfg=allianceWar2Cfg["reward"..cityCfg.type].reward
		end
		if reward1Cfg then
			posy=posy-80
			local awardTb1=FormatItem(reward1Cfg,nil,true)
			local num1=SizeOfTable(awardTb1)
			for k,v in pairs(awardTb1) do
				local px,py=cellWidth/2-spacew*(num1-1)/2+(k-1)*spacew,posy
				local hideNum=nil
				if v and v.num and v.num<=0 then
					hideNum=true
				end
				local icon=G_getItemIcon(v,100,true,self.layerNum+1,nil,self.tv,nil,nil,hideNum)
				icon:setPosition(ccp(px,py))
				icon:setTouchPriority(-(self.layerNum-1)*20-4)
				cell:addChild(icon,1)
				if v and v.num and v.num>0 then
					local numLb=GetTTFLabel("x"..v.num,25)
					numLb:setAnchorPoint(ccp(1,0))
					numLb:setPosition(ccp(icon:getContentSize().width-5,5))
					icon:addChild(numLb,1)
				end
			end
		end

		posy=posy-80
		local rewardBg2=CCSprite:createWithSpriteFrameName("orangeMask.png")
		rewardBg2:setPosition(ccp(cellWidth/2,posy))
		cell:addChild(rewardBg2)
		local reward2Lb=GetTTFLabelWrap(getlocal("allianceWar2_reward2_title",{cityName}),25,CCSizeMake(cellWidth-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		reward2Lb:setPosition(cellWidth/2,posy)
		cell:addChild(reward2Lb,1)

		local reward2Cfg
		if cityCfg and cityCfg.type and allianceWar2Cfg["activeReward"..cityCfg.type] and allianceWar2Cfg["reward"..cityCfg.type].reward then
			reward2Cfg=allianceWar2Cfg["activeReward"..cityCfg.type].reward
		end
		if reward2Cfg then
			posy=posy-80
			local awardTb2=FormatItem(reward2Cfg,nil,true)
			local num2=SizeOfTable(awardTb2)
			for k,v in pairs(awardTb2) do
				local px,py=cellWidth/2-spacew*(num2-1)/2+(k-1)*spacew,posy
				local hideNum=nil
				if v and v.num and v.num<=0 then
					hideNum=true
				end
				local icon=G_getItemIcon(v,100,true,self.layerNum+1,nil,self.tv,nil,nil,hideNum)
				icon:setPosition(ccp(px,py))
				icon:setTouchPriority(-(self.layerNum-1)*20-4)
				cell:addChild(icon,1)
				if v and v.num and v.num>0 then
					local numLb=GetTTFLabel("x"..v.num,25)
					numLb:setAnchorPoint(ccp(1,0))
					numLb:setPosition(ccp(icon:getContentSize().width-5,5))
					icon:addChild(numLb,1)
				end
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

--点击城市，显示城市信息，如果数据过期或者没有数据，就从后台拉数据，否则就显示缓存在内存中的数据
function allianceWar2OverviewDialog:showCityInfo(cityID)
	if cityID==nil then
		do return end
	end
	local cityData=allianceWar2VoApi:getCityDataByID(cityID)
	--数据缓存180秒
	-- print("cityID",cityID)
	if self.callBackNum==nil then
		self.callBackNum=0
	end
	-- if(cityData and base.serverTime-cityData.updateTime<180)then
	if(cityData and base.serverTime-allianceWar2VoApi:getCityUpdateTime()<180)then
		self.selectedCityID=cityID
		self.selectedCityData=cityData
		self:initTick()
		self:refresh()
		self.curMapDialog:showSelectedEffect(cityID)
	elseif self.callBackNum<5 then
		local function callback(resultcityID,result)
			if(result)then
				-- local function callback1(resultcityID1,result1)
				-- 	if(result1)then
						self.selectedCityID=resultcityID
						self.selectedCityData=allianceWar2VoApi:getCityDataByID(resultcityID)
						self:initTick()
						self:refresh()
						self.curMapDialog:showSelectedEffect(resultcityID)
						self.callBackNum=0
				-- 	end
				-- end
				-- local cityIndex1=2
				-- allianceWar2VoApi:requestCityInfo(cityIndex1,callback1)
			end
		end
		-- local cityIndex=1
		allianceWar2VoApi:requestCityInfo(cityID,callback)
		self.callBackNum=self.callBackNum+1
	end
end

function allianceWar2OverviewDialog:initPage()
	local mapDialog=allianceWar2MapDialog:new(self,1)
	local layer=mapDialog:init(self.layerNum)
	self.bgLayer:addChild(layer,1)
	layer:setPosition(ccp(30,G_VisibleSizeHeight-85-10-500))

	self.curMapDialog=mapDialog
	local page=1
	local isShowBg=false
	local isShowPageBtn=true
	local posY=G_VisibleSizeHeight-85-10-250
end

function allianceWar2OverviewDialog:initBtn()
	local function clickDetaiBtn()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if self.selectedCityData and self.selectedCityData.id then
        	local cityID=self.selectedCityData.id
        	if allianceWar2Cfg.city and allianceWar2Cfg.city[cityID] and allianceWar2Cfg.city[cityID].type then
        		local cType=allianceWar2Cfg.city[cityID].type
        		allianceWar2VoApi:showDetailDialog(self.layerNum+1,self.selectedCityData,cType)
        	end
        end
	end

	local detailItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",clickDetaiBtn,nil,getlocal("playerInfo"),28,518)
	detailItem:setAnchorPoint(ccp(0,0))
	local detailBtn = CCMenu:createWithItem(detailItem);
	detailBtn:setAnchorPoint(ccp(0,0))
   	detailBtn:setPosition(ccp(60,28))
	detailBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	self.bgLayer:addChild(detailBtn,3);

	local function onEnter()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self:enterBattle()
	end
	-- 参战
	self.enterItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onEnter,nil,getlocal("allianceWar_enterBattle"),28,518)
	self.enterItem:setAnchorPoint(ccp(1,0))
	self.enterBtn = CCMenu:createWithItem(self.enterItem);
	self.enterBtn:setAnchorPoint(ccp(1,0))
	self.enterBtn:setTouchPriority(-(self.layerNum-1)*20-8);
	self.enterBtn:setPosition(ccp(self.bgLayer:getContentSize().width-60,28))
	self.bgLayer:addChild(self.enterBtn,3);
	self.enterItem:setVisible(false)
	self.enterItem:setEnabled(false)

	local function onSign()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self:bidForCity()
	end
	-- 报名
	self.signItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onSign,nil,getlocal("allianceWar_sign"),28,518)
	self.signItem:setAnchorPoint(ccp(1,0))
	self.signBtn = CCMenu:createWithItem(self.signItem);
	self.signBtn:setAnchorPoint(ccp(1,0))
	self.signBtn:setTouchPriority(-(self.layerNum-1)*20-8);
	self.signBtn:setPosition(ccp(self.bgLayer:getContentSize().width-60,28))
	self.bgLayer:addChild(self.signBtn,3);
	self.signItem:setVisible(false)
	self.signItem:setEnabled(false)

	local function onReport()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        allianceWar2VoApi:showRecordDialog(self.layerNum+1)
	end
	-- 战报
	self.reportItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",onReport,nil,getlocal("allianceWar_battleReport"),28,518)
	self.reportItem:setAnchorPoint(ccp(1,0))
	self.reportBtn = CCMenu:createWithItem(self.reportItem);
	self.reportBtn:setAnchorPoint(ccp(1,0))
	self.reportBtn:setTouchPriority(-(self.layerNum-1)*20-8);
	self.reportBtn:setPosition(ccp(self.bgLayer:getContentSize().width-60,28))
	self.bgLayer:addChild(self.reportBtn,3);
	self.reportItem:setVisible(false)
	self.reportItem:setEnabled(false)

	self:refresh()



	-- local function onClickLeftBtn()
	-- 	if(status>=10 and status<20)then
	-- 		self:bidForCity()
	-- 	elseif(status>=20)then
	-- 		self:showDetailAllianceRank()
	-- 	end
	-- end
	-- self.leftBtnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickLeftBtn,nil,getlocal("playerInfo"),28,518)
	-- self.leftBtnItem:setAnchorPoint(ccp(0,0))
	-- self.leftBtn = CCMenu:createWithItem(self.leftBtnItem);
	-- self.leftBtn:setAnchorPoint(ccp(0,0))
 --   	self.leftBtn:setPosition(ccp(60,28))
	-- self.leftBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	-- self.bgLayer:addChild(self.leftBtn,3);
	-- local function onEnter()
	-- 	self:enterBattle()
	-- end
	-- self.enterItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onEnter,nil,getlocal("allianceWar_enterBattle"),28,518)
	-- self.enterItem:setAnchorPoint(ccp(1,0))
	-- self.enterBtn = CCMenu:createWithItem(self.enterItem);
	-- self.enterBtn:setAnchorPoint(ccp(1,0))
	-- self.enterBtn:setTouchPriority(-(self.layerNum-1)*20-8);
	-- self.enterBtn:setPosition(ccp(self.bgLayer:getContentSize().width-60,28))
	-- self.bgLayer:addChild(self.enterBtn,3);

	-- -- local tmpSize=countDownBg:getContentSize()
	-- -- self.countDownDescLb:setPosition(ccp(tmpSize.width/2,tmpSize.height/2+50))
	-- -- self.countDownLb:setPosition(tmpSize.width/2,tmpSize.height/2-30)
	-- -- self.occupyNameLb:setPosition(tmpSize.width/2,tmpSize.height/2)
	local strSize2 =22
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
		strSize2 =25
	end
	local dataKey="allianceWar2@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
	local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local tabStr={};
		local tabColor ={nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil};
		local td=smallDialog:new()
		local timeStr1=allianceWar2VoApi:formatTimeStrByTb(allianceWar2VoApi.signUpTime.start)
		local timeStr2=allianceWar2VoApi:formatTimeStrByTb(allianceWar2VoApi.signUpTime.finish)
		tabStr = {"\n",getlocal("allianceWar2_tip_desc4",{allianceWar2Cfg.winPointMax}),"\n",getlocal("allianceWar2_tip_desc3"),"\n",getlocal("allianceWar2_tip_desc2",{allianceWar2Cfg.tankeTransRate}),"\n",getlocal("allianceWar2_tip_desc1",{timeStr1,timeStr2}),"\n"}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,strSize2,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1)
		
		local boolData=CCUserDefault:sharedUserDefault():getBoolForKey(dataKey)
		if boolData==nil or boolData==false  then
			CCUserDefault:sharedUserDefault():setBoolForKey(dataKey,true)
			CCUserDefault:sharedUserDefault():flush()
			G_removeFlicker(self.infoItem)
		end
	end
	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem);
	infoBtn:setAnchorPoint(ccp(1,1))
	infoBtn:setPosition(ccp(self.bgLayer:getContentSize().width-25,self.bgLayer:getContentSize().height-90))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	-- countDownBg:addChild(infoBtn)
	self.bgLayer:addChild(infoBtn,5)
	self.infoItem=infoItem

	local boolData=CCUserDefault:sharedUserDefault():getBoolForKey(dataKey)
	if boolData==nil or boolData==false then
		G_addFlicker(infoItem,2,2)
	end

	
end

function allianceWar2OverviewDialog:resize()
	self.panelLineBg:setPositionY(G_VisibleSizeHeight/2-35)
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight-105))

	local goldLine1=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
	goldLine1:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-400))
	self.bgLayer:addChild(goldLine1,1)
	local goldLine2=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
	goldLine2:setPosition(ccp(G_VisibleSizeWidth/2,115))
	self.bgLayer:addChild(goldLine2,1)
end

function allianceWar2OverviewDialog:initTick()
	-- base:removeFromNeedRefresh(self)
	self.countdown=nil
	local status=allianceWar2VoApi:getStatus(self.selectedCityID)
	-- print("status",status)
	local endTime
	local zeroTime=G_getWeeTs(base.serverTime)
	if(status<10 or status>=40)then
		-- local selfAlliance=allianceVoApi:getSelfAlliance()
		-- print("selfAlliance.alliancewar.own_at",selfAlliance.alliancewar.own_at)
		-- print("self.selectedCityData.ownerID",self.selectedCityData.ownerID)
		-- if(selfAlliance and selfAlliance.alliancewar and selfAlliance.alliancewar.own_at and self.selectedCityData.ownerID==selfAlliance.aid)then
		-- 	local ownTime=tonumber(selfAlliance.alliancewar.own_at)
		-- 	if(base.serverTime<=ownTime+24*3600)then
		-- 		endTime=ownTime+24*3600
		-- 	end
		-- end
		-- local cityCfg=allianceWar2VoApi.startWarTime[self.selectedCityID]
		-- local startTime=G_getWeeTs(base.serverTime)+cityCfg[1]*3600+cityCfg[2]*60

		local isInOccupy,et=allianceWar2VoApi:getIsInOccupy(self.selectedCityID)
		-- print("isInOccupy,et",isInOccupy,et)
		if isInOccupy==true and et and et>0 then
			endTime=et
		else
			local signUpTime=G_getWeeTs(base.serverTime)+allianceWar2VoApi.signUpTime.start[1]*3600+allianceWar2VoApi.signUpTime.start[2]*60
			if allianceWar2VoApi:isOpenBattle()==true then
				if status==40 then
					endTime=signUpTime+86400*2
				else
					endTime=signUpTime
				end
			else
				endTime=signUpTime+86400
			end
		end
	elseif(status<20)then
		endTime=zeroTime+allianceWar2VoApi.signUpTime.finish[1]*3600+allianceWar2VoApi.signUpTime.finish[2]*60
	elseif(status<30)then
		local cityCfg=allianceWar2VoApi.startWarTime[self.selectedCityID]
		local tmpTime=zeroTime+cityCfg[1]*3600+cityCfg[2]*60
		if(status==20)then
		-- 	endTime=tmpTime-allianceWar2Cfg.prepareTime
		-- elseif(status==21)then
			endTime=tmpTime
		end
	elseif(status<40)then
		local cityCfg=allianceWar2VoApi.startWarTime[self.selectedCityID]
		local tmpTime=zeroTime+cityCfg[1]*3600+cityCfg[2]*60+allianceWar2Cfg.maxBattleTime
		endTime=tmpTime
	end
	-- print("endTime~~~~~~1",endTime)
	if(endTime)then
		self.countdown=endTime-base.serverTime
		if self.countdown<=0 then
			self.countdown=0
		end
		-- base:addNeedRefresh(self)
		-- print("self.countdown~~~~~~1",self.countdown)
	end
	if self.selectedCityID and self.status and self.status[self.selectedCityID]==-1 then
		self.status[self.selectedCityID]=status
	end
	if self.selectedCityID and self.cityStatus and self.cityStatus[self.selectedCityID]==-1 then
		self.cityStatus[self.selectedCityID]=status
	end
end

function allianceWar2OverviewDialog:tick()
	-- local str=G_getTimeStr(self.countdown)
	-- if(status==0 or status==40)then
	-- 	if(self.countDownDescLb:isVisible())then
	-- 		self.countDownDescLb:setString(getlocal("allianceWar_resourceCountDown").."\n"..str)
	-- 	end
	-- else
	-- 	if(self.countDownLb:isVisible())then
	-- 		self.countDownLb:setString(str)
	-- 	end
	-- end
	-- print("self.countdown",self.countdown)
	if allianceWar2VoApi.signUpTime==nil then
		do return end
	end
	if self.curMapDialog and self.curMapDialog.tick then
		self.curMapDialog:tick()
	end
	local endTime
	local zeroTime=G_getWeeTs(base.serverTime)
	local status=allianceWar2VoApi:getStatus(self.selectedCityID)
	-- print("status",status)
	if self.selectedCityID and self.status and self.status[self.selectedCityID]>=0 and self.status[self.selectedCityID]~=status then
		self.status[self.selectedCityID]=status
		self:refreshCity(isUpdate)
	end
	if(status<10 or status>=40)then
		-- if(allianceVoApi:getSelfAlliance().alliancewar and allianceVoApi:getSelfAlliance().alliancewar.own_at)then
		-- 	local ownTime=tonumber(allianceVoApi:getSelfAlliance().alliancewar.own_at)
		-- 	if(ownTime)then
		-- 		endTime=ownTime+24*3600
		-- 	end
		-- end
		-- print("allianceWar2VoApi.signUpTime",allianceWar2VoApi.signUpTime)
		local isInOccupy,et=allianceWar2VoApi:getIsInOccupy(self.selectedCityID)
		-- print("isInOccupy,et",isInOccupy,et)
		if isInOccupy==true and et and et>0 then
			endTime=et
		else
			local signUpTime=G_getWeeTs(base.serverTime)+allianceWar2VoApi.signUpTime.start[1]*3600+allianceWar2VoApi.signUpTime.start[2]*60
			if allianceWar2VoApi:isOpenBattle()==true then
				if status==40 then
					endTime=signUpTime+86400*2
				else
					endTime=signUpTime
				end
			else
				endTime=signUpTime+86400
			end
		end
	elseif(status<20)then
		endTime=zeroTime+allianceWar2VoApi.signUpTime.finish[1]*3600+allianceWar2VoApi.signUpTime.finish[2]*60
	elseif(status<30)then
		local cityCfg=allianceWar2VoApi.startWarTime[self.selectedCityID]
		local tmpTime=zeroTime+cityCfg[1]*3600+cityCfg[2]*60
		if(status==20)then
		-- 	endTime=tmpTime-allianceWar2Cfg.prepareTime
		-- elseif(status==21)then
			endTime=tmpTime
		end
	elseif(status<40)then
		local cityCfg=allianceWar2VoApi.startWarTime[self.selectedCityID]
		local tmpTime=zeroTime+cityCfg[1]*3600+cityCfg[2]*60+allianceWar2Cfg.maxBattleTime
		endTime=tmpTime
	end
	-- print("endTime~~~~~~2",endTime)
	-- print("base.serverTime",base.serverTime)
	if(endTime)then
		self.countdown=endTime-base.serverTime
		if self.countdown<=0 then
			self.countdown=0
		end
		-- print("self.countdown~~~~~~2",self.countdown)
		if self.cdSpTab then
			local hours=math.floor(self.countdown/3600)
			local minutes=math.floor((self.countdown%3600)/60)
			local seconds=self.countdown%60
			local numTab={math.floor(hours/10),hours%10,math.floor(minutes/10),minutes%10,math.floor(seconds/10),seconds%10}
			-- G_dayin(numTab)
			for k,v in pairs(self.cdSpTab) do
				-- print("k--------",k,v)
				local spBg=tolua.cast(v,"CCSprite")
				if v and spBg:getChildByTag(500+k) and numTab and numTab[k] and self.lastNumSpTab[k] and self.lastNumSpTab[k]~=numTab[k] then
					local sp=tolua.cast(spBg:getChildByTag(500+k),"CCSprite")
					-- print("sp~~~~~~~",sp)
					-- print("numTab[k]",numTab[k])
					sp:removeFromParentAndCleanup(true)
					sp=CCSprite:createWithSpriteFrameName("numb_"..numTab[k]..".png")
					if sp then
						sp:setPosition(getCenterPoint(spBg))
						sp:setTag(500+k)
						spBg:addChild(sp,1)
					end
				end
			end
			self.lastNumSpTab=numTab
		end
		if(self.countdown and self.countdown<=1)then
			if status==30 then
				local isEnd=allianceWar2VoApi:getIsEnd()
				if self.battleEnd==false and isEnd==true then
					self:refreshCity(isUpdate)
					self.battleEnd=isEnd
				end
			else
				self:refreshCity()
			end
		end
	end

	if self.selectedCityID and self.cityStatus and self.cityStatus[self.selectedCityID]==-1 then
		self.cityStatus[self.selectedCityID]=status
	end

	if self.cityStatus then
		for k,v in pairs(self.cityStatus) do
			local cityStatus
			if k==self.selectedCityID then
				cityStatus=status
			else
				cityStatus=allianceWar2VoApi:getStatus(k)
			end
			if cityStatus and v and cityStatus~=v and self.curMapDialog and self.curMapDialog.refreshOccupy then
				self.cityStatus[k]=cityStatus
				self.curMapDialog:refreshOccupy()
			end
		end
	end
end

function allianceWar2OverviewDialog:refreshCity(isUpdate)
	-- if isUpdate==true or (self.callNum>=0 and self.callNum<5 and base.serverTime>self.expiredTime) then
	if isUpdate==true or (self.callNum>=0 and self.callNum<5) then
		local function callback(result)
			if(result)then
				allianceWar2VoApi:setCityInfoExpire()
				self:showCityInfo(self.selectedCityID)
				self.callNum=0
				-- self.expiredTime=base.serverTime+5
			end
		end
		allianceWar2VoApi:requestAllianceWarInfo(callback)
		self.callNum=self.callNum+1
	end
end

function allianceWar2OverviewDialog:refresh()
	-- -- self.moneyLb:setString(getlocal("allianceWar_fundNum",{allianceVoApi:getSelfAlliance().point}))
	-- -- self.numLb:setString(getlocal("allianceWar_joinedAllianceNum",{self.selectedCityData.applycount}))
	-- self.enterItem:setEnabled(false)
	-- local lb=tolua.cast(self.enterItem:getChildByTag(518),"CCLabelTTF")
	-- lb:setString(getlocal("allianceWar_enterBattle"))
	-- -- self.countDownLb:setVisible(false)
	-- -- self.occupyNameLb:setVisible(false)
	-- local timeStr
	-- -- if(self.countdown)then
	-- -- 	timeStr=G_getTimeStr(self.countdown)
	-- -- else
	-- -- 	timeStr=""
	-- -- end
	-- -- local cityCfg=allianceWar2VoApi:getCityCfgByID(self.selectedCityID)
	-- -- local timeStartStr=allianceWar2VoApi:formatTimeStrByTb(allianceWar2VoApi.signUpTime.start)
	-- -- local timeEndStr=allianceWar2VoApi:formatTimeStrByTb(allianceWar2VoApi.signUpTime.finish)
	-- -- local nameStr=getlocal(cityCfg.name)
	-- -- local warTimeStr=allianceWar2VoApi:formatTimeStrByTb(allianceWar2VoApi.startWarTime[cityCfg.id])
	-- -- local startTimeStr=getlocal("allianceWar_signTimeDesc2",{nameStr,warTimeStr})
	if self.selectedCityID==nil then
		do return end
	end
	local status=allianceWar2VoApi:getStatus(self.selectedCityID)
	if status==nil then
		do return end
	end
	-- print("status",status)
	if(status<10)then
		if self.signItem then
			self.signItem:setVisible(true)
			self.signItem:setEnabled(false)
		end
		if self.enterItem then
			self.enterItem:setVisible(false)
			self.enterItem:setEnabled(false)
		end
		if self.reportItem then
			self.reportItem:setVisible(false)
			self.reportItem:setEnabled(false)
		end
	elseif(status>=10 and status<20)then
		if self.enterItem then
			self.enterItem:setVisible(false)
			self.enterItem:setEnabled(false)
		end
		if self.reportItem then
			self.reportItem:setVisible(false)
			self.reportItem:setEnabled(false)
		end
		if status==11 then
			if self.signItem then
				self.signItem:setVisible(true)
				self.signItem:setEnabled(true)
			end
		else
			if self.signItem then
				self.signItem:setVisible(true)
				self.signItem:setEnabled(false)
			end
		end
	elseif(status>=20 and status<=30)then
		if self.signItem then
			self.signItem:setVisible(false)
			self.signItem:setEnabled(false)
		end
		if self.enterItem then
			self.enterItem:setVisible(true)
			if(self.selectedCityID==allianceWar2VoApi.targetCity and (allianceWar2VoApi.targetState==1 or allianceWar2VoApi.targetState==2))then
				local isOneSign=allianceWar2VoApi:getIsOneSign(self.selectedCityID)
				if isOneSign==true then
					self.enterItem:setEnabled(false)
				else
					self.enterItem:setEnabled(true)
				end
			else
				self.enterItem:setEnabled(false)
			end
		end
		if self.reportItem then
			self.reportItem:setVisible(false)
			self.reportItem:setEnabled(false)
		end
	elseif(status==40)then
		if self.signItem then
			self.signItem:setVisible(false)
			self.signItem:setEnabled(false)
		end
		if self.enterItem then
			self.enterItem:setVisible(false)
			self.enterItem:setEnabled(false)
		end
		if self.reportItem then
			self.reportItem:setVisible(true)
			self.reportItem:setEnabled(true)
		end
	else
		if self.signItem then
			self.signItem:setVisible(true)
			self.signItem:setEnabled(false)
		end
		if self.enterItem then
			self.enterItem:setVisible(false)
			self.enterItem:setEnabled(false)
		end
		if self.reportItem then
			self.reportItem:setVisible(false)
			self.reportItem:setEnabled(false)
		end
	end

	if self and self.tv then
		self.tv:reloadData()
	end
	if self.curMapDialog then
		self.curMapDialog:refreshOccupy()
	end

	-- if(status<10)then
	-- 	-- -- if(cityCfg.area~=allianceWar2VoApi.todayArea)then
	-- 	-- -- 	self.countDownDescLb:setString(getlocal("backstage4002"))
	-- 	-- -- 	if(self.selectedCityData.ownerID and self.selectedCityData.ownerName)then
	-- 	-- -- 		if(self.selectedCityData.ownerID==allianceVoApi:getSelfAlliance().aid)then
	-- 	-- -- 			self.countDownDescLb:setString(getlocal("allianceWar_resourceCountDown").."\n"..timeStr)
	-- 	-- -- 		end
	-- 	-- -- 		if(self.selectedCityData.ownerName)then
	-- 	-- -- 			self.occupyNameLb:setString(getlocal("allianceWar_occupyName",{self.selectedCityData.ownerName}))
	-- 	-- -- 			self.occupyNameLb:setVisible(true)
	-- 	-- -- 		end
	-- 	-- -- 	end
	-- 	-- -- else
	-- 	-- -- 	local descStr=startTimeStr.."\n"..getlocal("allianceWar_signTimeDesc",{timeStartStr,timeEndStr})
	-- 	-- -- 	self.countDownDescLb:setString(descStr)
	-- 	-- -- end
	-- 	-- self.leftBtnItem:setEnabled(false)
	-- 	-- local lb=tolua.cast(self.leftBtnItem:getChildByTag(518),"CCLabelTTF")
	-- 	-- lb:setString(getlocal("allianceWar_sign"))
	-- 	if self.reportItem then
	-- 		self.reportItem:setVisible(true)
	-- 		self.reportItem:setEnabled(true)
	-- 	end
	-- elseif(status<20)then
	-- 	-- self.countDownLb:setString(timeStr)
	-- 	-- self.countDownLb:setVisible(true)
	-- 	-- self.countDownDescLb:setString(startTimeStr.."\n"..getlocal("allianceWar_signCountDownDesc"))
	-- 	self.leftBtnItem:setEnabled(true)
	-- 	local lb=tolua.cast(self.leftBtnItem:getChildByTag(518),"CCLabelTTF")
	-- 	lb:setString(getlocal("allianceWar_sign"))
	-- else
	-- 	if(self.selectedCityData.allianceID1 and self.selectedCityData.allianceID2)then
	-- 		-- local selfID=allianceVoApi:getSelfAlliance().aid
	-- 		-- if(tonumber(selfID)==tonumber(self.selectedCityData.allianceID1))then
	-- 		-- 	self.countDownDescLb:setString(startTimeStr.."\n"..getlocal("allianceWar_selfVsTitle",{self.selectedCityData.allianceName2}))
	-- 		-- 	self.countDownLb:setVisible(true)
	-- 		-- else
	-- 		-- 	self.countDownDescLb:setString(startTimeStr.."\n"..getlocal("allianceWar_vsTitle",{self.selectedCityData.allianceName1,self.selectedCityData.allianceName2}))
	-- 		-- end
	-- 		if(status==20)then
	-- 			-- self.countDownLb:setString(timeStr)
	-- 			local lb=tolua.cast(self.leftBtnItem:getChildByTag(518),"CCLabelTTF")
	-- 			lb:setString(getlocal("playerInfo"))
	-- 			self.leftBtnItem:setEnabled(true)
	-- 		elseif(status==21 or status==30)then
	-- 			-- self.countDownLb:setString(timeStr)
	-- 			local lb1=tolua.cast(self.leftBtnItem:getChildByTag(518),"CCLabelTTF")
	-- 			lb1:setString(getlocal("playerInfo"))
	-- 			local zeroTime=G_getWeeTs(base.serverTime)
	-- 			if(allianceWar2VoApi.joinTime>=zeroTime)then
	-- 				local lb2=tolua.cast(self.enterItem:getChildByTag(518),"CCLabelTTF")
	-- 				lb2:setString(getlocal("allianceWar_enter"))
	-- 			end
	-- 			self.leftBtnItem:setEnabled(true)
	-- 			if(self.selectedCityID==allianceWar2VoApi.targetCity and (allianceWar2VoApi.targetState==1 or allianceWar2VoApi.targetState==2))then
	-- 				self.enterItem:setEnabled(true)
	-- 			end
	-- 		elseif(status==40)then
	-- 			-- self.countDownLb:setVisible(false)
	-- 			-- if(self.selectedCityData.ownerID==selfID)then
	-- 			-- 	self.countDownDescLb:setString(getlocal("allianceWar_resourceCountDown").."\n"..timeStr)
	-- 			-- else
	-- 			-- 	self.countDownDescLb:setString(getlocal("allianceWar_battleEnd"))
	-- 			-- end
	-- 			-- if(self.selectedCityData.ownerName)then
	-- 			-- 	self.occupyNameLb:setString(getlocal("allianceWar_occupyName",{self.selectedCityData.ownerName}))
	-- 			-- 	self.occupyNameLb:setVisible(true)
	-- 			-- end
	-- 			local lb1=tolua.cast(self.leftBtnItem:getChildByTag(518),"CCLabelTTF")
	-- 			lb1:setString(getlocal("playerInfo"))
	-- 			self.leftBtnItem:setEnabled(true)
	-- 			local lb2=tolua.cast(self.enterItem:getChildByTag(518),"CCLabelTTF")
	-- 			lb2:setString(getlocal("allianceWar_battleReport"))
	-- 			if(self.selectedCityID==allianceWar2VoApi.targetCity and (allianceWar2VoApi.targetState==1 or allianceWar2VoApi.targetState==2))then
	-- 				self.enterItem:setEnabled(true)
	-- 			end
	-- 		end
	-- 	else
	-- 		local lb=tolua.cast(self.leftBtnItem:getChildByTag(518),"CCLabelTTF")
	-- 		lb:setString(getlocal("playerInfo"))
	-- 		self.leftBtnItem:setEnabled(true)
	-- 		-- if(self.selectedCityData.bidList and #self.selectedCityData.bidList>0)then
	-- 		-- 	self.countDownDescLb:setString(startTimeStr.."\n"..getlocal("allianceWar_signNotEnough"))
	-- 		-- else
	-- 		-- 	self.countDownDescLb:setString(startTimeStr.."\n"..getlocal("allianceWar_noSign"))
	-- 		-- end
	-- 	end
	-- end


	--测试
	-- if self.signItem then
	-- 	self.signItem:setVisible(false)
	-- 	self.signItem:setEnabled(false)
	-- end
	-- if self.reportItem then
	-- 	self.reportItem:setVisible(false)
	-- 	self.reportItem:setEnabled(false)
	-- end
	-- if self.enterItem then
	-- 	self.enterItem:setVisible(true)
	-- 	self.enterItem:setEnabled(true)
	-- end
end

function allianceWar2OverviewDialog:bidForCity()
	local canBid=allianceWar2VoApi:checkCanBid(self.selectedCityID)
	if(canBid==0)then
		local smallDialog=allianceWar2BidDialog:new(self,self.selectedCityID)
		smallDialog:init(self.layerNum+1)
	else
		local dialogStr
		if(canBid==1)then
			dialogStr=getlocal("allianceWar_errorNeedAlliance")
		elseif(canBid==2)then
			dialogStr=getlocal("allianceWar_errorNeedPermission")
		elseif(canBid==3)then
			dialogStr=getlocal("allianceWar_errorWrongArea")
		elseif(canBid==4)then
			dialogStr=getlocal("allianceWar_errorAlreadyOwned")
		elseif(canBid==5)then
			local cfg=allianceWar2VoApi:getCityCfgByID(allianceWar2VoApi.targetCity)
			dialogStr=getlocal("allianceWar_errorAlreadySigned",{getlocal(cfg.name)})
		elseif(canBid==6)then
			dialogStr=getlocal("allianceWar_notInSigntime")
		else
			dialogStr=getlocal("backstage9000")
		end
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),dialogStr,nil,self.layerNum+1)
		return false
	end
end

function allianceWar2OverviewDialog:showJoinedAllianceNum()
	local smallDialog=allianceWarCityRankDialog:new(self.selectedCityData,1)
	smallDialog:init(self.layerNum+1)
end

function allianceWar2OverviewDialog:showDetailAllianceRank()
	local smallDialog=allianceWarCityRankDialog:new(self.selectedCityData,2)
	smallDialog:init(self.layerNum+1)
end

function allianceWar2OverviewDialog:enterBattle()
	-- --测试
	-- self:close()
	-- local td=allianceWar2Dialog:new(self.layerNum+1)
	-- local tbArr={}
	-- local dialog=td:init("panelItemBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(20, 20, 10, 10),tbArr,nil,nil,"",true,self.layerNum+1)
	-- sceneGame:addChild(dialog,self.layerNum+1)
	-- do return end

	-- print("self.selectedCityID",self.selectedCityID)
	-- print("allianceWar2VoApi.targetCity",allianceWar2VoApi.targetCity)
	-- print("allianceWar2VoApi.targetState",allianceWar2VoApi.targetState)
	if(self.selectedCityID==allianceWar2VoApi.targetCity and (allianceWar2VoApi.targetState==1 or allianceWar2VoApi.targetState==2))then
		-- print("status",status)
		local status=allianceWar2VoApi:getStatus(self.selectedCityID)
		if(status>=20 or status<=30)then
			if allianceVoApi:isCanAllianceWar()==false then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage8062"),30)
                do return end
            end

			-- local function callback(result)
			-- 	if(result==true)then
					-- self:close()
					local td=allianceWar2Dialog:new(self.layerNum+1)
					local tbArr={getlocal("battlefield"),getlocal("alliance_list_scene_name"),getlocal("fleetInfoTitle2")}
					local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,"",true,self.layerNum+1)
					sceneGame:addChild(dialog,self.layerNum+1)
			-- 	end
			-- end
			-- local zeroTime=G_getWeeTs(base.serverTime)
			-- if(allianceWar2VoApi.joinTime>=zeroTime)then
			-- 	callback(true)
			-- else
			-- 	allianceWar2VoApi:enterbattle(callback)
			-- end
		elseif(status==40)then
			local td=warRecordDialog:new()
			local tbArr={getlocal("alliance_war_record_title"),getlocal("alliance_war_stats")}
			local tbSubArr={}
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,tbSubArr,nil,getlocal("alliance_war_battle_stats"),true,self.layerNum+1)
			sceneGame:addChild(dialog,self.layerNum+1)
		end
	end
end

function allianceWar2OverviewDialog:dispose()
	self.callBackNum=nil
	self.mapList=nil
	self.dialogList=nil
	self.mapLayer=nil
	self.curMapDialog=nil
	self.selectedCityID=nil
	self.selectedCityData=nil
	self.countdown=nil
	self.status={-1,-1}
	self.cdSpTab={}
	self.lastNumSpTab={}
	self.battleEnd=false
	self.expiredTime=0
	self.callNum=0
	self.cityStatus={-1,-1}

	G_AllianceWarDialogTb["allianceWar2OverviewDialog"]=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acNewYearsEva.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acNewYearsEva.png")

	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("allianceWar/warMap.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("allianceWar/warMap.pvr.ccz")

	spriteController:removePlist("public/acLuckyCat.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acLuckyCat.pvr.ccz")

	spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
	spriteController:removeTexture("public/allianceWar2/allianceWar2.png")

	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWar2.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWar2.png")
	

	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/serverWarLocal/serverWarLocal2.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/serverWarLocal/serverWarLocal2.png")

	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/serverWarLocal/serverWarLocalCity.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/serverWarLocal/serverWarLocalCity.png")

	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acFirstRechargenew.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acFirstRechargenew.png")
end