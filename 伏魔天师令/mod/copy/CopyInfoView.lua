local CopyInfoView=classGc(view,function(self,_copyId,_copysMsg,_offLineData,_guideCopyId)
	self.m_copyId=_copyId
	self.m_copysMsg=_copysMsg
	self.m_offLineData=_offLineData
	self.m_guideCopyId=_guideCopyId
	self.m_winSize=cc.Director:getInstance():getWinSize()
	self.m_mediator=require("mod.copy.CopyInfoMediator")(self)
	self.m_resourcesArray={}

	self.m_myProperty=_G.GPropertyProxy:getMainPlay()
	self.m_myVip=self.m_myProperty:getVipLv()
	self.m_canBuyTimes=_G.Cfg.vip[self.m_myVip].tran_buy

	local mainCopyInfo=self.m_myProperty:getTaskInfo()
	if mainCopyInfo and mainCopyInfo.type==_G.Const.CONST_TASK_TRACE_DAILY_TASK then
		local haveCount,allCount=self.m_myProperty:getTaskCount()
		if haveCount<allCount then
			self.m_wantMopTimes=allCount - haveCount
		end
	end
end)


function CopyInfoView.create(self)
	local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

	self.m_rootLayer=cc.Layer:create()
	self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

	self:__initView()
	return self.m_rootLayer
end

function CopyInfoView.__initView(self)
	local sceneCopyCnf=_G.GCopyProxy:getCopyNodeByCopyId(self.m_copyId)

	-- 场景地图
	if sceneCopyCnf.scene and sceneCopyCnf.scene[1] then
		local sceneCnf=get_scene_data(sceneCopyCnf.scene[1].id)
		if sceneCnf then
			local mapNode=cc.Node:create()
			self.m_rootLayer:addChild(mapNode,-10)
			local tempScale=1--558/640
			mapNode:setScale(tempScale)
			mapNode:setPosition(0,0)

			local mapTable=_G.MapData[sceneCnf.material_id]
			if mapTable.data then
				if mapTable.data.bg then
					for i=1,#mapTable.data.bg do
						local v=mapTable.data.bg[i]
						if v.type==[[jpg]] or v.type==[[png]] then
							if v.x<self.m_winSize.width/tempScale then
								local szImg=string.format("map/%s.%s",v.name,v.type)
								-- local tempSpr=_G.ImageAsyncManager:createNormalSpr(szImg)

								if v.type==[[jpg]] then
									_G.SysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)
								elseif v.type==[[png]] then
									_G.SysInfo:resetTextureFormat()
								end

								local tempSpr=cc.Sprite:create(szImg)
								tempSpr:setPosition(v.x,v.y)
								tempSpr:setAnchorPoint(cc.p(0,0))
								mapNode:addChild(tempSpr)
								self.m_resourcesArray[szImg]=true
							end
						end
					end
				end
				if mapTable.data.map then
					for i=1,#mapTable.data.map do
						local v=mapTable.data.map[i]
						if v.type==[[jpg]] or v.type==[[png]] then
							if v.x<self.m_winSize.width/tempScale then
								local szImg=string.format("map/%s.%s",v.name,v.type)
								-- local tempSpr=_G.ImageAsyncManager:createNormalSpr(szImg)

								if v.type==[[jpg]] then
									_G.SysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)
								elseif v.type==[[png]] then
									_G.SysInfo:resetTextureFormat()
								end

								local tempSpr=cc.Sprite:create(szImg)
								tempSpr:setPosition(v.x,v.y)
								tempSpr:setAnchorPoint(cc.p(0,0))
								mapNode:addChild(tempSpr)
								self.m_resourcesArray[szImg]=true
							end
						end
					end
				end
			end
		end
	end
	_G.SysInfo:resetTextureFormat()

	local titleFrameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("newcopy_frame_3.png")
	titleFrameSpr:setContentSize(cc.size(self.m_winSize.width,80))
	titleFrameSpr:setPosition(self.m_winSize.width*0.5,600)
	self.m_rootLayer:addChild(titleFrameSpr,10)


	local function c(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			self:closeWindow()
		end
	end
	local tempBtn=gc.CButton:create("general_btn_back.png")
    tempBtn:setPosition(self.m_winSize.width-40,600)
    tempBtn:addTouchEventListener(c)
    self.m_rootLayer:addChild(tempBtn,100)

	-- 
	local nnnY=559
	local chapIdxBg=cc.Sprite:createWithSpriteFrameName("newcopy_copy_name.png")
	chapIdxBg:setAnchorPoint(cc.p(0,1))
	chapIdxBg:setPosition(10,nnnY)
	self.m_rootLayer:addChild(chapIdxBg,-1)

	local chapCnf=_G.Cfg.copy_chap[_G.Const.CONST_COPY_TYPE_NORMAL][sceneCopyCnf.belong_id]
	local chapIdx=chapCnf.paixu
	local copyIdx=1
	for i=1,#chapCnf.copy_id do
		local copyId=chapCnf.copy_id[i]
		if copyId==self.m_copyId or (copyId+10000)==self.m_copyId or (copyId+20000)==self.m_copyId then
			copyIdx=i
		end
	end

	local szCopyName=string.format("%d-%d  %s",chapIdx,copyIdx,sceneCopyCnf.copy_name)

	local tempSize=chapIdxBg:getContentSize()
	local chapIdxLabel=_G.Util:createBorderLabel(szCopyName,24)
	chapIdxLabel:setPosition(tempSize.width*0.5,tempSize.height*0.5)
	chapIdxBg:addChild(chapIdxLabel)

	local midPosX=self.m_winSize.width*0.5-15
	local leftSize=cc.size(410,120)
	local nPosX=midPosX-leftSize.width*0.5-3
	local nPosY=leftSize.height*0.5-2

	if sceneCopyCnf.use_spine and sceneCopyCnf.use_spine>0 then
		local monsterId=sceneCopyCnf.use_spine
		local nScale=sceneCopyCnf.bili or 70
		local tempCnf=_G.Cfg.scene_monster[monsterId]
		if tempCnf then
			local szName=string.format("spine/%d",tempCnf.skin)
		    local tempSpine=_G.SpineManager.createSpine(szName,nScale*0.01)
		    if tempSpine then
		    	tempSpine:setPosition(nPosX,nPosY)
		    	tempSpine:setAnimation(0,"idle",true)
		    	self.m_rootLayer:addChild(tempSpine,-1)

		    	if tempCnf.skin_type then
		    		tempSpine:setSkin(tostring(tempCnf.skin_type))
		    	end

		    	local skinCnf=_G.g_SkillDataManager:getSkinData(tempCnf.skin)
		    	if skinCnf and skinCnf.back then
		    		local tempSpine=_G.SpineManager.createSpine(string.format("%s_body",szName),nScale*0.01)
		    		if tempSpine then
		    			tempSpine:setPosition(nPosX,nPosY)
		    			tempSpine:setAnimation(0,"idle",true)
		    			self.m_rootLayer:addChild(tempSpine,-2)
		    		end
		    	end
		    end
		end
	end

	self.m_leftSpr=ccui.Scale9Sprite:createWithSpriteFrameName("newcopy_frame_3.png")
	self.m_leftSpr:setContentSize(leftSize)
	self.m_leftSpr:setPosition(nPosX,nPosY)
	self.m_rootLayer:addChild(self.m_leftSpr)

	local tempLabel=_G.Util:createLabel("通关条件",20)
	tempLabel:setAnchorPoint(cc.p(0,1))
	tempLabel:setPosition(10,leftSize.height-8)
	self.m_leftSpr:addChild(tempLabel)

	local pNpcType=sceneCopyCnf.npc_survival or _G.Const.CONST_COPY_PASS_NPC0
	local pPassType=sceneCopyCnf.pass_condition and sceneCopyCnf.pass_condition[1] or _G.Const.CONST_COPY_PASS_TYPE1
	local pLimitTimes=sceneCopyCnf.pass_condition and sceneCopyCnf.pass_condition[2] or 0
	local szMsg=""
	if pPassType==_G.Const.CONST_COPY_PASS_TYPE1 then
		szMsg="击杀所有怪物"
	elseif pPassType==_G.Const.CONST_COPY_PASS_TYPE2 then
		szMsg=string.format("在%d秒内击杀所有怪物",pLimitTimes)
	elseif pPassType==_G.Const.CONST_COPY_PASS_TYPE3 then
		szMsg=string.format("在%d秒内存活下来",pLimitTimes)
	end
	if pNpcType==_G.Const.CONST_COPY_PASS_NPC1 then
		szMsg=szMsg..",并保证您的配角不被击杀"
	elseif pNpcType==_G.Const.CONST_COPY_PASS_NPC2 then
		szMsg=szMsg..",并保证所有龙套不被击杀"
	end

	local tempLabel=_G.Util:createLabel(szMsg,20)
	tempLabel:setAnchorPoint(cc.p(0,0.5))
	tempLabel:setPosition(53,70)
	self.m_leftSpr:addChild(tempLabel)

	local rightSize=cc.size(425,565)
	self.m_rightSpr=ccui.Scale9Sprite:createWithSpriteFrameName("newcopy_frame_2.png")
	self.m_rightSpr:setContentSize(rightSize)
	self.m_rightSpr:setPosition(midPosX+rightSize.width*0.5+2,rightSize.height*0.5-3)
	self.m_rootLayer:addChild(self.m_rightSpr)

	local tempSpr=ccui.Scale9Sprite:createWithSpriteFrameName("newcopy_frame_3.png")
	tempSpr:setContentSize(cc.size(405,420))
	tempSpr:setPosition(rightSize.width*0.5,305)
	self.m_rightSpr:addChild(tempSpr)

	local tempLabel=_G.Util:createLabel("几率掉落",20)
	tempLabel:setPosition(10,538)
	tempLabel:setAnchorPoint(cc.p(0,0.5))
	self.m_rightSpr:addChild(tempLabel)

	local rewardArray={}
	if sceneCopyCnf.exp>0 then
		rewardArray[#rewardArray+1]={goods_id=46700,count=sceneCopyCnf.exp}
	end
	if sceneCopyCnf.gold>0 then
		rewardArray[#rewardArray+1]={goods_id=46000,count=sceneCopyCnf.gold}
	end
	for i=1,#sceneCopyCnf.reward do
		rewardArray[#rewardArray+1]={goods_id=sceneCopyCnf.reward[i][1][1],count=sceneCopyCnf.reward[i][1][2]}
	end
	local function r(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local pos=sender:getWorldPosition()
			local goodId=sender:getTag()
            local temp=_G.TipsUtil:createById(goodId,nil,pos)
            cc.Director:getInstance():getRunningScene():addChild(temp,1000)
		end
	end
	for i=1,4 do
		local goodSpr=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
		goodSpr:setPosition(70+(i-1)*95,455)
		-- goodSpr:setScale(0.8)
		self.m_rightSpr:addChild(goodSpr)

		if rewardArray[i] then
			local goodId=rewardArray[i].goods_id
			local count=rewardArray[i].count
			local goodsCnf=_G.Cfg.goods[goodId]
			if goodsCnf then
				local sprSize=goodSpr:getContentSize()
				local iconBtn=_G.ImageAsyncManager:createGoodsBtn(goodsCnf,r,goodId,count)
				iconBtn:setPosition(sprSize.width*0.5,sprSize.height*0.5)
				goodSpr:addChild(iconBtn)
			end
		end
	end


	local lineSpr=cc.Sprite:createWithSpriteFrameName("general_line_gold.png")
	lineSpr:setPosition(rightSize.width*0.5,392)
	lineSpr:setScale(2,2)
	self.m_rightSpr:addChild(lineSpr)

	local lineSpr=cc.Sprite:createWithSpriteFrameName("general_line_white.png")
	lineSpr:setPosition(rightSize.width*0.5,290)
	lineSpr:setScale(2,2)
	self.m_rightSpr:addChild(lineSpr)

	local lineSpr=cc.Sprite:createWithSpriteFrameName("general_line_white.png")
	lineSpr:setPosition(rightSize.width*0.5,180)
	lineSpr:setScale(2,2)
	self.m_rightSpr:addChild(lineSpr)
    

    if not self.m_copysMsg then
    	local msg=REQ_COPY_REQUEST_COPY()
    	msg:setArgs(self.m_copyId)
    	_G.Network:send(msg)
    else
    	self:showRightInfo(self.m_copysMsg)
    end
end

function CopyInfoView.showRightInfo(self,_ackMsg)
	self.m_copysMsg=_ackMsg

	if self.m_isInitView then
		self:updateSurplusTimes(_ackMsg.times_all-_ackMsg.times)
		return
	end
	self.m_isInitView=true
	-- for k,v in pairs(_ackMsg.copy_one_data) do
		-- print(k,v.copy_id,v.pass)
	-- end

	local function mopCall(sender,eventType)
		if eventType==ccui.TouchEventType.ended then
			local subTimes=self.m_copysMsg.times_all-self.m_copysMsg.times
			if subTimes<=0 then
				-- local command=CErrorBoxCommand("没有剩余挑战次数")
				-- _G.controller:sendCommand(command)
				self:__showBuyChallengeTimes()
				return
			end

			local copyId=sender:getTag()
			local energyTimes=self:getCurCanMopTimes(copyId)
			if energyTimes<=0 then
				self:__showBuyEnergy()
				return
			end

			local data={}
			local canMopTimes=subTimes
			canMopTimes=canMopTimes>energyTimes and energyTimes or canMopTimes

			local selectTimes=canMopTimes
			if self.m_wantMopTimes then
				selectTimes=selectTimes>self.m_wantMopTimes and self.m_wantMopTimes or selectTimes
			end

			data._copyId      = copyId
			data._selectTimes = selectTimes
			data._canMopTimes = canMopTimes
			data._surplusTimes= subTimes
			data._eva         = 1
			data._isOffLine   = false

			local mopView=require("mod.copy.CopyMopView")(data)
			self.m_mopNode=mopView:create()
			self.m_rootLayer:addChild(self.m_mopNode,100)
		end
	end
	local function enterCall(sender,eventType)
		if eventType==ccui.TouchEventType.ended then
			local subTimes=self.m_copysMsg.times_all-self.m_copysMsg.times
			if subTimes<=0 then
				-- local command=CErrorBoxCommand("没有剩余挑战次数")
				-- _G.controller:sendCommand(command)
				self:__showBuyChallengeTimes()
				return
			end

			local copyId=sender:getTag()
			local energyTimes=self:getCurCanMopTimes(copyId)
			if energyTimes<=0 then
				self:__showBuyEnergy()
				return
			end

			local msg=REQ_COPY_NEW_CREAT()
            msg:setArgs(copyId)
            _G.Network:send(msg)
		end
	end

	local szArray={"简单","困难","地狱"}
	for i=1,3 do
		local tempY=340-(i-1)*100
		local nanduSpr=cc.Sprite:createWithSpriteFrameName("newcopy_nandu_bg.png")
		nanduSpr:setPosition(59,tempY)
		self.m_rightSpr:addChild(nanduSpr)

		local nanduSize=nanduSpr:getContentSize()
		local nanduLabel=_G.Util:createLabel(szArray[i],20)
		nanduLabel:setPosition(nanduSize.width*0.5,nanduSize.height*0.5)
		nanduSpr:addChild(nanduLabel)

		if i>1 and _ackMsg.copy_one_data[i-1].pass~=1 then
			local noticLabel=_G.Util:createLabel(string.format("通关%s难度可解锁",szArray[i-1]),22)
			noticLabel:setPosition(245,tempY-3)
			self.m_rightSpr:addChild(noticLabel)
		else
			local copyId=_ackMsg.copy_one_data[i].copy_id
			local mopBtn=gc.CButton:create("newcopy_btn_sd.png")
			mopBtn:addTouchEventListener(mopCall)
			mopBtn:setTag(copyId)
			mopBtn:setPosition(175,tempY-3)
			self.m_rightSpr:addChild(mopBtn)

			if _ackMsg.copy_one_data[i].pass~=1 then
				mopBtn:setTouchEnabled(false)
				mopBtn:setGray()
			end

			local enterBtn=gc.CButton:create("newcopy_btn_zd.png")
			enterBtn:addTouchEventListener(enterCall)
			enterBtn:setTag(copyId)
			enterBtn:setPosition(327,tempY-3)
			self.m_rightSpr:addChild(enterBtn)

			if self.m_guideCopyId==copyId then
				_G.GGuideManager:registGuideData(3,enterBtn)
				_G.GGuideManager:runNextStep()

				self.m_guide_wait_touch=true
			end
		end
	end

	local tempLabel=_G.Util:createLabel("剩余次数:",18)
	tempLabel:setAnchorPoint(cc.p(1,0.5))
	tempLabel:setPosition(106,55)
	self.m_rightSpr:addChild(tempLabel)

	self.m_surplusTimesLabel=_G.Util:createLabel("",18)
	self.m_surplusTimesLabel:setAnchorPoint(cc.p(0,0.5))
	self.m_surplusTimesLabel:setPosition(107,55)
	self.m_surplusTimesLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	self.m_rightSpr:addChild(self.m_surplusTimesLabel)

	local tempLabel=_G.Util:createLabel("消耗体力:",18)
	tempLabel:setAnchorPoint(cc.p(1,0.5))
	tempLabel:setPosition(225,55)
	self.m_rightSpr:addChild(tempLabel)

	local sceneCopyNode=_G.GCopyProxy:getCopyNodeByCopyId(self.m_copyId)
	local useEnergyLabel=_G.Util:createLabel(sceneCopyNode.use_energy or "",18)
	useEnergyLabel:setAnchorPoint(cc.p(0,0.5))
	useEnergyLabel:setPosition(226,55)
	useEnergyLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	self.m_rightSpr:addChild(useEnergyLabel)

	local tempLabel=_G.Util:createLabel("体力:",18)
	tempLabel:setAnchorPoint(cc.p(1,0.5))
	tempLabel:setPosition(305,55)
	self.m_rightSpr:addChild(tempLabel)

	self.m_myEnergyLabel=_G.Util:createLabel("",18)
	self.m_myEnergyLabel:setAnchorPoint(cc.p(0,0.5))
	self.m_myEnergyLabel:setPosition(306,55)
	self.m_myEnergyLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	self.m_rightSpr:addChild(self.m_myEnergyLabel)

	local function nFun(sender,eventType)
		if eventType==ccui.TouchEventType.ended then
			self:__showBuyEnergy()
		end
	end
	local energyBtn=gc.CButton:create("general_btn_add2.png")
	energyBtn:addTouchEventListener(nFun)
	energyBtn:setPosition(390,55)
	self.m_rightSpr:addChild(energyBtn)

	self:updateSurplusTimes(_ackMsg.times_all-_ackMsg.times)
	self:updateMyEnergy()

	if self.m_offLineData then
		local copyId=self.m_offLineData.copy_id
		local selectTimes=self.m_offLineData.sumtimes
		local surplusTimes=_ackMsg.times_all-_ackMsg.times
		local energyTimes=self:getCurCanMopTimes(copyId)
		local canMopTimes=surplusTimes>energyTimes and energyTimes or surplusTimes
		local subTimes=selectTimes-self.m_offLineData.nowtimes
		local copyCnf=_G.GCopyProxy:getCopyNodeByCopyId(copyId)
		if copyCnf==nil then
			CCMessageBox("离线挂机数据出错,copyId="..copyId,"副本数据")
			return
		end

		local data={}
		data._copyId      = copyId
		data._selectTimes = selectTimes
		data._canMopTimes = canMopTimes
		data._surplusTimes= surplusTimes
		data._eva         = 1
		data._isOffLine   = true

		local mopView=require("mod.copy.CopyMopView")(data)
		self.m_mopNode=mopView:create()
		self.m_rootLayer:addChild(self.m_mopNode,100)

		mopView:createScrollView()
		for i=1,#self.m_offLineData.data do
			local v=self.m_offLineData.data[i]
			mopView:addOneReward(v)
		end

		local myProperty=self.m_myProperty
		if subTimes<=0 then
			-- 挂机完成
			mopView:setCurState(4)
			myProperty.mopType=2
			local command=CMainUiCommand(CMainUiCommand.MOPTYPE)
		    command.mopType=myProperty.mopType
		    controller:sendCommand(command)
		else
			-- 挂机中
			mopView.m_endHuangupTime=self.m_offLineData.time+_G.TimeUtil:getTotalSeconds()
			mopView:updateTimesByOffLine()
			mopView:setCurState(2)
			myProperty.mopType=1
			local command=CMainUiCommand(CMainUiCommand.MOPTYPE)
		    command.mopType=myProperty.mopType
		    controller:sendCommand(command)
		end
		self.m_offLineData=nil
	end
end

function CopyInfoView.getCurCanMopTimes( self, _copyid )
	local myProperty=self.m_myProperty
    local energyHas = myProperty:getAllEnergy()
    local useEnergy = self:getCurUseEnergy(_copyid)
    if useEnergy==0 then return 100 end
    return math.floor(energyHas/useEnergy)
end

function CopyInfoView.getCurUseEnergy( self, _copyId)
    local sceneCopyNode = _G.GCopyProxy:getCopyNodeByCopyId( _copyId )
    return sceneCopyNode.use_energy
end

function CopyInfoView.__showBuyEnergy(self)
	local msg=REQ_ROLE_ASK_BUY_ENERGY()
	_G.Network:send(msg)
end

function CopyInfoView.__showBuyChallengeTimes(self)
	-- local subTimes=self.m_copysMsg.times_all-self.m_copysMsg.times
	local curBuyTimes=math.floor(self.m_copysMsg.times_all/5)
	local copyPayTimesCnf=_G.Cfg.d_copy_times_pay[_G.Const.CONST_COPY_TYPE_NORMAL][curBuyTimes]
	if not copyPayTimesCnf then
		local command=CErrorBoxCommand(21010)
		_G.controller:sendCommand(command)
		return
	elseif curBuyTimes>self.m_canBuyTimes then
		local command=CErrorBoxCommand(21010)
		_G.controller:sendCommand(command)
		return
	end

	local curUseRmb=copyPayTimesCnf.rmb
	local szMsg=string.format("花费%d元宝重置挑战次数？\n(元宝不足则消耗钻石)",curUseRmb)

	local function nSure()
		local msg=REQ_COPY_BUY_REQUEST()
		msg:setArgs(self.m_copysMsg.copy_one_data[1].copy_id)
		_G.Network:send(msg)
	end
	_G.Util:showTipsBox(szMsg,nSure)
end

function CopyInfoView.updateSurplusTimes(self,_times)
	self.m_surplusTimesLabel:setString(tostring(_times))
end

function CopyInfoView.updateMyEnergy(self)
	local myProperty=self.m_myProperty
	local hasEnergy=myProperty:getAllEnergy()
	local maxEnergy=myProperty:getMax()
	local szMsg=string.format("%d/%d",hasEnergy,maxEnergy)
	self.m_myEnergyLabel:setString(szMsg)
end

function CopyInfoView.closeWindow(self)
	if not self.m_rootLayer then return end

	self.m_rootLayer:removeFromParent(true)
	self.m_rootLayer=nil

	local command=CCopyMapCommand(CCopyMapCommand.COPYINFO_CLOSE)
	_G.controller:sendCommand(command)

	ScenesManger.releaseFileArray(self.m_resourcesArray)
	self:destroy()

	if self.m_guide_wait_touch then
		_G.GGuideManager:runThisStep(2)
	end
end

function CopyInfoView.getRewardCallBack(self)
	local msg=REQ_COPY_REQUEST_COPY()
	msg:setArgs(self.m_copyId)
	_G.Network:send(msg)
end

return CopyInfoView