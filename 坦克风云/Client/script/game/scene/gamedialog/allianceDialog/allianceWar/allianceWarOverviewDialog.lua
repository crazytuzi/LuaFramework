require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar/allianceWarMapDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar/allianceWarCityRankDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar/allianceWarBidDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar/warRecordDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar/allianceWarDialog"

allianceWarOverviewDialog=commonDialog:new()

function allianceWarOverviewDialog:new(layerNum)
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
	self.status=0
	return nc
end

function allianceWarOverviewDialog:doUserHandler()
	local function callback(result)
		if(result)then
			self:initWithData()
		end
	end
	allianceWarVoApi:requestAllianceWarInfo(callback)

	G_AllianceWarDialogTb["allianceWarOverviewDialog"]=self
end

function allianceWarOverviewDialog:initWithData()
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
	self:initPage()
	self:initBtn()
	self:resize()
	local targetCfg=allianceWarVoApi:getCityCfgByID(allianceWarVoApi.targetCity)
	if(targetCfg and targetCfg.area==allianceWarVoApi.todayArea and allianceWarVoApi.targetState>0)then
		self:showCityInfo(allianceWarVoApi.targetCity)
	else
		if(allianceWarVoApi.todayArea==1)then
			self:showCityInfo(1)
		else
			self:showCityInfo(5)
		end
	end
end

--点击城市，显示城市信息，如果数据过期或者没有数据，就从后台拉数据，否则就显示缓存在内存中的数据
function allianceWarOverviewDialog:showCityInfo(cityID)
	local cityData=allianceWarVoApi:getCityDataByID(cityID)
	--数据缓存180秒
	if(cityData and base.serverTime-cityData.updateTime<180)then
		self.selectedCityID=cityID
		self.selectedCityData=cityData
		self:initTick()
		self:refresh()
		self.curMapDialog:showSelectedEffect(cityID)
	else
		local function callback(resultcityID,result)
			if(result)then
				self.selectedCityID=resultcityID
				self.selectedCityData=allianceWarVoApi:getCityDataByID(resultcityID)
				self:initTick()
				self:refresh()
				self.curMapDialog:showSelectedEffect(resultcityID)
			end
		end
		allianceWarVoApi:requestCityInfo(cityID,callback)
	end
end

function allianceWarOverviewDialog:initPage()
	self.mapList={}
	self.layerList={}
	for i=1,2 do
		local mapDialog
		if(allianceWarVoApi.todayArea==2)then
			mapDialog=allianceWarMapDialog:new(self,3-i)
		else
			mapDialog=allianceWarMapDialog:new(self,i)
		end		
		local layer=mapDialog:init(self.layerNum)
		self.bgLayer:addChild(layer,1)
		layer:setPosition(ccp(30,G_VisibleSizeHeight-85-10-500))
		self.layerList[i]=layer
		self.mapList[i]=mapDialog
	end
	self.curMapDialog=self.mapList[1]
	self.mapLayer=pageDialog:new()
	local page=1
	local isShowBg=false
	local isShowPageBtn=true
	local function onPage(topage)
		self.curMapDialog=self.mapList[topage]
		self.curMapDialog.curShowDescID=nil
		self:showCityInfo(self.curMapDialog.lastSelectedCityID)
	end
	local posY=G_VisibleSizeHeight-85-10-250
	local leftBtnPos=ccp(40,posY)
	local rightBtnPos=ccp(self.bgLayer:getContentSize().width-40,posY)
	self.mapLayer:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,page,self.layerList,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos)

	local maskSpHeight=self.bgLayer:getContentSize().height-133
	for k=1,2 do
		local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
		leftMaskSp:setAnchorPoint(ccp(0,0))
		leftMaskSp:setPosition(0,38)
		leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
		self.bgLayer:addChild(leftMaskSp,6)

		local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
		rightMaskSp:setFlipX(true)
		rightMaskSp:setAnchorPoint(ccp(0,0))
		rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,38)
		rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
		self.bgLayer:addChild(rightMaskSp,6)
	end
end

function allianceWarOverviewDialog:initBtn()
	

	local capInSet = CCRect(20, 20, 10, 10);
	local function nilFunc(hd,fn,idx)
	end
	local function onShowDetail()
		if((self.status==10 or self.status==11) and self.selectedCityData and self.selectedCityData.applycount>0)then
			self:showJoinedAllianceNum()
		else
			if(self.status==12)then
				local cityCfg=allianceWarVoApi:getCityCfgByID(allianceWarVoApi.targetCity)
				if(cityCfg)then
					local name=getlocal(cityCfg.name)
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_cantShowRankTip",{name}),30)
				end
			end
		end
	end
	local moneyBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,onShowDetail)
	moneyBg:setIsSallow(true)
	moneyBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,110))
	moneyBg:setAnchorPoint(ccp(0,1))
	moneyBg:setPosition(ccp(30,G_VisibleSizeHeight-85-10-500-8))
	moneyBg:setTouchPriority(-(self.layerNum-1)*20-2)
	self.moneyLb=GetTTFLabelWrap(getlocal("allianceWar_fundNum",{allianceVoApi:getSelfAlliance().point}),25,CCSizeMake(G_VisibleSizeWidth-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.moneyLb:setAnchorPoint(ccp(0.5,0))
	self.moneyLb:setPosition(getCenterPoint(moneyBg))
	moneyBg:addChild(self.moneyLb,2)
	self.numLb=GetTTFLabelWrap(getlocal("allianceWar_joinedAllianceNum",{0}),25,CCSizeMake((G_VisibleSizeWidth-80),0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.numLb:setAnchorPoint(ccp(0.5,1))
	self.numLb:setPosition(getCenterPoint(moneyBg))
	moneyBg:addChild(self.numLb,2)

	local selectedBg=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),function ( ... ) end)
	selectedBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-56,114))
	selectedBg:setPosition(getCenterPoint(moneyBg))
	moneyBg:addChild(selectedBg,1)

	self.bgLayer:addChild(moneyBg)

	local countDownBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,nilFunc)
	countDownBg:setIsSallow(true)
	countDownBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-85-10-500-8-110-8-30))
	countDownBg:setAnchorPoint(ccp(0.5,0))
	countDownBg:setPosition(ccp(G_VisibleSizeWidth/2,30))

	self.countDownDescLb=GetTTFLabelWrap("",25,CCSizeMake(G_VisibleSizeWidth-220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	countDownBg:addChild(self.countDownDescLb)
	self.countDownLb=GetTTFLabel("",25)
	countDownBg:addChild(self.countDownLb)
	self.occupyNameLb=GetTTFLabel("",28)
	self.occupyNameLb:setColor(G_ColorYellowPro)
	countDownBg:addChild(self.occupyNameLb)
	local function onClickLeftBtn()
		if(self.status>=10 and self.status<20)then
			self:bidForCity()
		elseif(self.status>=20)then
			self:showDetailAllianceRank()
		end
	end
	self.leftBtnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickLeftBtn,nil,getlocal("playerInfo"),28,518)
	self.leftBtnItem:setAnchorPoint(ccp(0,0))
	self.leftBtn = CCMenu:createWithItem(self.leftBtnItem);
	self.leftBtn:setAnchorPoint(ccp(0,0))
   	self.leftBtn:setPosition(ccp(30,8))
	self.leftBtn:setTouchPriority(-(self.layerNum-1)*20-2);
	countDownBg:addChild(self.leftBtn,3);
	local function onEnter()
		self:enterBattle()
	end
	self.enterItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onEnter,nil,getlocal("allianceWar_enterBattle"),28,518)
	self.enterItem:setAnchorPoint(ccp(1,0))
	self.enterBtn = CCMenu:createWithItem(self.enterItem);
	self.enterBtn:setAnchorPoint(ccp(1,0))
	self.enterBtn:setTouchPriority(-(self.layerNum-1)*20-8);
	self.enterBtn:setPosition(ccp(countDownBg:getContentSize().width-30,8))
	countDownBg:addChild(self.enterBtn,3);
	self.bgLayer:addChild(countDownBg)

	local tmpSize=countDownBg:getContentSize()
	self.countDownDescLb:setPosition(ccp(tmpSize.width/2,tmpSize.height/2+50))
	self.countDownLb:setPosition(tmpSize.width/2,tmpSize.height/2-30)
	self.occupyNameLb:setPosition(tmpSize.width/2,tmpSize.height/2)

	local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local tabStr={};
		local tabColor ={nil,G_ColorYellowPro,nil,G_ColorWhite,nil,G_ColorWhite,nil,G_ColorWhite,nil};
		local td=smallDialog:new()
		local timeStr1=allianceWarVoApi:formatTimeStrByTb(allianceWarVoApi.signUpTime.start)
		local timeStr2=allianceWarVoApi:formatTimeStrByTb(allianceWarVoApi.signUpTime.finish)
		tabStr = {"\n",getlocal("allianceWar_overviewInfo5"),"\n",getlocal("allianceWar_overviewInfo3",{allianceWarCfg.prepareTime/60}),"\n",getlocal("allianceWar_overviewInfo2",{timeStr1,timeStr2}),"\n",getlocal("allianceWar_overviewInfo1"),"\n",}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1)
	end

	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	infoItem:setAnchorPoint(ccp(1,1))
	local infoBtn = CCMenu:createWithItem(infoItem);
	infoBtn:setAnchorPoint(ccp(1,1))
	infoBtn:setPosition(ccp(tmpSize.width-5,tmpSize.height-5))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-2);
	countDownBg:addChild(infoBtn)
end

function allianceWarOverviewDialog:resize()
	self.panelLineBg:setPositionY(G_VisibleSizeHeight/2-35)
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight-105))
end

function allianceWarOverviewDialog:initTick()
	base:removeFromNeedRefresh(self)
	self.countdown=nil
	self.status=allianceWarVoApi:getStatus(self.selectedCityID)
	local endTime
	local zeroTime=G_getWeeTs(base.serverTime)
	if(self.status<10 or self.status==40)then
		local selfAlliance=allianceVoApi:getSelfAlliance()
		if(selfAlliance and selfAlliance.alliancewar and selfAlliance.alliancewar.own_at and self.selectedCityData.ownerID==selfAlliance.aid)then
			local ownTime=tonumber(selfAlliance.alliancewar.own_at)
			if(base.serverTime<=ownTime+24*3600)then
				endTime=ownTime+24*3600
			end
		end
	elseif(self.status<20)then
		endTime=zeroTime+allianceWarVoApi.signUpTime.finish[1]*3600+allianceWarVoApi.signUpTime.finish[2]*60
	elseif(self.status<30)then
		local cityCfg=allianceWarVoApi.startWarTime[self.selectedCityID]
		local tmpTime=zeroTime+cityCfg[1]*3600+cityCfg[2]*60
		if(self.status==20)then
			endTime=tmpTime-allianceWarCfg.prepareTime
		elseif(self.status==21)then
			endTime=tmpTime
		end
	end
	if(endTime)then
		self.countdown=endTime-base.serverTime
		base:addNeedRefresh(self)
	end
end

function allianceWarOverviewDialog:tick()
	local str=G_getTimeStr(self.countdown)
	if(self.status==0 or self.status==40)then
		if(self.countDownDescLb:isVisible())then
			self.countDownDescLb:setString(getlocal("allianceWar_resourceCountDown").."\n"..str)
		end
	else
		if(self.countDownLb:isVisible())then
			self.countDownLb:setString(str)
		end
	end
	local endTime
	local zeroTime=G_getWeeTs(base.serverTime)
	if(self.status<10 or self.status==40)then
		if(allianceVoApi:getSelfAlliance().alliancewar and allianceVoApi:getSelfAlliance().alliancewar.own_at)then
			local ownTime=tonumber(allianceVoApi:getSelfAlliance().alliancewar.own_at)
			if(ownTime)then
				endTime=ownTime+24*3600
			end
		end
	elseif(self.status<20)then
		endTime=zeroTime+allianceWarVoApi.signUpTime.finish[1]*3600+allianceWarVoApi.signUpTime.finish[2]*60
	elseif(self.status<30)then
		local cityCfg=allianceWarVoApi.startWarTime[self.selectedCityID]
		local tmpTime=zeroTime+cityCfg[1]*3600+cityCfg[2]*60
		if(self.status==20)then
			endTime=tmpTime-allianceWarCfg.prepareTime
		elseif(self.status==21)then
			endTime=tmpTime
		end
	end
	if(endTime)then
		self.countdown=endTime-base.serverTime
	end
	if(self.countdown<=0)then
		base:removeFromNeedRefresh(self)
		allianceWarVoApi:setCityInfoExpire()
		self:showCityInfo(self.selectedCityID)
	end
end

function allianceWarOverviewDialog:refresh()
	self.moneyLb:setString(getlocal("allianceWar_fundNum",{allianceVoApi:getSelfAlliance().point}))
	self.numLb:setString(getlocal("allianceWar_joinedAllianceNum",{self.selectedCityData.applycount}))
	self.enterItem:setEnabled(false)
	local lb=tolua.cast(self.enterItem:getChildByTag(518),"CCLabelTTF")
	lb:setString(getlocal("allianceWar_enterBattle"))
	self.countDownLb:setVisible(false)
	self.occupyNameLb:setVisible(false)
	local timeStr
	if(self.countdown)then
		timeStr=G_getTimeStr(self.countdown)
	else
		timeStr=""
	end
	local cityCfg=allianceWarVoApi:getCityCfgByID(self.selectedCityID)
	local timeStartStr=allianceWarVoApi:formatTimeStrByTb(allianceWarVoApi.signUpTime.start)
	local timeEndStr=allianceWarVoApi:formatTimeStrByTb(allianceWarVoApi.signUpTime.finish)
	local nameStr=getlocal(cityCfg.name)
	local warTimeStr=allianceWarVoApi:formatTimeStrByTb(allianceWarVoApi.startWarTime[cityCfg.id])
	local startTimeStr=getlocal("allianceWar_signTimeDesc2",{nameStr,warTimeStr})
	if(self.status<10)then
		if(cityCfg.area~=allianceWarVoApi.todayArea)then
			self.countDownDescLb:setString(getlocal("backstage4002"))
			if(self.selectedCityData.ownerID and self.selectedCityData.ownerName)then
				if(self.selectedCityData.ownerID==allianceVoApi:getSelfAlliance().aid)then
					self.countDownDescLb:setString(getlocal("allianceWar_resourceCountDown").."\n"..timeStr)
				end
				if(self.selectedCityData.ownerName)then
					self.occupyNameLb:setString(getlocal("allianceWar_occupyName",{self.selectedCityData.ownerName}))
					self.occupyNameLb:setVisible(true)
				end
			end
		else
			local descStr=startTimeStr.."\n"..getlocal("allianceWar_signTimeDesc",{timeStartStr,timeEndStr})
			self.countDownDescLb:setString(descStr)
		end
		self.leftBtnItem:setEnabled(false)
		local lb=tolua.cast(self.leftBtnItem:getChildByTag(518),"CCLabelTTF")
		lb:setString(getlocal("allianceWar_sign"))
	elseif(self.status<20)then
		self.countDownLb:setString(timeStr)
		self.countDownLb:setVisible(true)
		self.countDownDescLb:setString(startTimeStr.."\n"..getlocal("allianceWar_signCountDownDesc"))
		self.leftBtnItem:setEnabled(true)
		local lb=tolua.cast(self.leftBtnItem:getChildByTag(518),"CCLabelTTF")
		lb:setString(getlocal("allianceWar_sign"))
	else
		if(self.selectedCityData.allianceID1 and self.selectedCityData.allianceID2)then
			local selfID=allianceVoApi:getSelfAlliance().aid
			if(tonumber(selfID)==tonumber(self.selectedCityData.allianceID1))then
				self.countDownDescLb:setString(startTimeStr.."\n"..getlocal("allianceWar_selfVsTitle",{self.selectedCityData.allianceName2}))
				self.countDownLb:setVisible(true)
			else
				self.countDownDescLb:setString(startTimeStr.."\n"..getlocal("allianceWar_vsTitle",{self.selectedCityData.allianceName1,self.selectedCityData.allianceName2}))
			end
			if(self.status==20)then
				self.countDownLb:setString(timeStr)
				local lb=tolua.cast(self.leftBtnItem:getChildByTag(518),"CCLabelTTF")
				lb:setString(getlocal("playerInfo"))
				self.leftBtnItem:setEnabled(true)
			elseif(self.status==21 or self.status==30)then
				self.countDownLb:setString(timeStr)
				local lb1=tolua.cast(self.leftBtnItem:getChildByTag(518),"CCLabelTTF")
				lb1:setString(getlocal("playerInfo"))
				local zeroTime=G_getWeeTs(base.serverTime)
				if(allianceWarVoApi.joinTime>=zeroTime)then
					local lb2=tolua.cast(self.enterItem:getChildByTag(518),"CCLabelTTF")
					lb2:setString(getlocal("allianceWar_enter"))
				end
				self.leftBtnItem:setEnabled(true)
				if(self.selectedCityID==allianceWarVoApi.targetCity and (allianceWarVoApi.targetState==1 or allianceWarVoApi.targetState==2))then
					self.enterItem:setEnabled(true)
				end
			elseif(self.status==40)then
				self.countDownLb:setVisible(false)
				if(self.selectedCityData.ownerID==selfID)then
					self.countDownDescLb:setString(getlocal("allianceWar_resourceCountDown").."\n"..timeStr)
				else
					self.countDownDescLb:setString(getlocal("allianceWar_battleEnd"))
				end
				if(self.selectedCityData.ownerName)then
					self.occupyNameLb:setString(getlocal("allianceWar_occupyName",{self.selectedCityData.ownerName}))
					self.occupyNameLb:setVisible(true)
				end
				local lb1=tolua.cast(self.leftBtnItem:getChildByTag(518),"CCLabelTTF")
				lb1:setString(getlocal("playerInfo"))
				self.leftBtnItem:setEnabled(true)
				local lb2=tolua.cast(self.enterItem:getChildByTag(518),"CCLabelTTF")
				lb2:setString(getlocal("allianceWar_battleReport"))
				if(self.selectedCityID==allianceWarVoApi.targetCity and (allianceWarVoApi.targetState==1 or allianceWarVoApi.targetState==2))then
					self.enterItem:setEnabled(true)
				end
			end
		else
			local lb=tolua.cast(self.leftBtnItem:getChildByTag(518),"CCLabelTTF")
			lb:setString(getlocal("playerInfo"))
			self.leftBtnItem:setEnabled(true)
			if(self.selectedCityData.bidList and #self.selectedCityData.bidList>0)then
				self.countDownDescLb:setString(startTimeStr.."\n"..getlocal("allianceWar_signNotEnough"))
			else
				self.countDownDescLb:setString(startTimeStr.."\n"..getlocal("allianceWar_noSign"))
			end
		end
	end
end

function allianceWarOverviewDialog:bidForCity()
	local canBid=allianceWarVoApi:checkCanBid(self.selectedCityID)
	if(canBid==0)then
		local smallDialog=allianceWarBidDialog:new(self,self.selectedCityID)
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
			local cfg=allianceWarVoApi:getCityCfgByID(allianceWarVoApi.targetCity)
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

function allianceWarOverviewDialog:showJoinedAllianceNum()
	local smallDialog=allianceWarCityRankDialog:new(self.selectedCityData,1)
	smallDialog:init(self.layerNum+1)
end

function allianceWarOverviewDialog:showDetailAllianceRank()
	local smallDialog=allianceWarCityRankDialog:new(self.selectedCityData,2)
	smallDialog:init(self.layerNum+1)
end

function allianceWarOverviewDialog:enterBattle()
	if(self.selectedCityID==allianceWarVoApi.targetCity and (allianceWarVoApi.targetState==1 or allianceWarVoApi.targetState==2))then
		if(self.status==21 or self.status==30)then
            
            if allianceVoApi:isCanAllianceWar()==false then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage8062"),30)
                do return end
            end

			local function callback(result)
				if(result==true)then
					self:close()
					local td=allianceWarDialog:new(3)
					local tbArr={getlocal("battlefield"),getlocal("alliance_list_scene_name"),getlocal("fleetInfoTitle2")}
					local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_war"),true,3)
					sceneGame:addChild(dialog,3)
				end
			end
			local zeroTime=G_getWeeTs(base.serverTime)
			if(allianceWarVoApi.joinTime>=zeroTime)then
				callback(true)
			else
				allianceWarVoApi:enterbattle(callback)
			end
		elseif(self.status==40)then
			local td=warRecordDialog:new()
			local tbArr={getlocal("alliance_war_record_title"),getlocal("alliance_war_stats")}
			local tbSubArr={}
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,tbSubArr,nil,getlocal("alliance_war_battle_stats"),true,self.layerNum+1)
			sceneGame:addChild(dialog,self.layerNum+1)
		end
	end
end

function allianceWarOverviewDialog:dispose()
	self.mapList=nil
	self.dialogList=nil
	self.mapLayer=nil
	self.curMapDialog=nil
	self.selectedCityID=nil
	self.selectedCityData=nil
	self.countdown=nil
	self.status=0
	G_AllianceWarDialogTb["allianceWarOverviewDialog"]=nil
	CCTextureCache:sharedTextureCache():removeTextureForKey("allianceWar/warMap.plist")
	-- CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.plist")
end