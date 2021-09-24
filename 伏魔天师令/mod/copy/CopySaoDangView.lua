
local CopySaoDangView = classGc(view, function (self,_data) 
    self.m_winSize    = cc.Director:getInstance():getWinSize()
	self.m_mainSize   = cc.size(650,410)  
	self.m_copyId     = _data._copyId
	self.m_selectTimes=_data._selectTimes
	self.m_surplusTimes=_data._surplusTimes
	self.m_canMopTimes=_data._canMopTimes
	self.view = _data._view
	self.m_copyEVA=_data._eva
	end)

local P_TAG_SUB=1
local P_TAG_SUB=1
local P_TAG_ADD=2
local P_TAG_MAX=3
local P_TAG_SPEED=11
local P_TAG_MOP=12
local P_TAG_STOP=13
local P_TAG_REWARD=14
local P_TAG_VIPMOP=15

local P_TYPE_STOP=1
local P_TYPE_MOP=2
local P_TYPE_SPEED=3
local P_TYPE_REWARD=4


function CopySaoDangView.create( self )
    local function onTouchBegan() return true end
	local listerner=cc.EventListenerTouchOneByOne:create()
	listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listerner:setSwallowTouches(true)

	self.m_rootLayer=cc.Layer:create()
	self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)
	self : __addMediator ()
    self : __initParams ()
	self : initSaoDaoView ()
	return self.m_rootLayer
end

function CopySaoDangView.__addMediator( self )
	self.m_mediator=require("mod.copy.CopyMopMediator")(self)
end

function CopySaoDangView.startHuangup( self, _ackMsg )
	if self.m_myType~=P_TYPE_STOP then return end

	if self.m_vipUseTimes==0 then
		self :setCurState(P_TYPE_SPEED)
	else
		local huangupTimes = _ackMsg.sumtimes
		local oneTimes     = self.m_vipUseTimes
		self.m_endHuangupTime = huangupTimes*oneTimes+_G.TimeUtil:getTotalSeconds()
		self :setCurState(P_TYPE_MOP)
	end

	self.m_addRewardNum=0
	self.m_preMopTimes=_ackMsg.sumtimes
	self.m_canMopTimes=self.m_canMopTimes-_ackMsg.sumtimes

	self:createScrollView()
end

function CopySaoDangView.initSaoDaoView(self) 
	local blackLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
	self.m_rootLayer:addChild(blackLayer,-10)

	local mainBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
	mainBg:setPreferredSize(self.m_mainSize)
	mainBg:setPosition(self.m_winSize.width*0.5,self.m_winSize.height*0.5)
	self.m_rootLayer:addChild(mainBg)

	local floorSize=cc.size(400,375)
	local mainBg2=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
	mainBg2:setPreferredSize(floorSize)
	mainBg2:setPosition(self.m_mainSize.width*0.5+108,self.m_mainSize.height*0.5)
	mainBg:addChild(mainBg2)

    self.m_rewardSize=cc.size(207,375)
	local leftBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
	leftBg:setPreferredSize(self.m_rewardSize)
	leftBg:setPosition(120,self.m_mainSize.height*0.5)
	mainBg:addChild(leftBg)

	self.m_rewardSize=cc.size(400,375)
	self.m_rightBg=mainBg

 	self.rewardSpr={}
    for i=1,3 do
    	local bgSize=cc.size(floorSize.width-8,floorSize.height/3-2)
		self.rewardSpr[i]=ccui.Scale9Sprite:createWithSpriteFrameName("general_nothis.png")
		self.rewardSpr[i]:setPreferredSize(bgSize)
		self.rewardSpr[i]:setPosition(floorSize.width/2,floorSize.height-(i-1)*bgSize.height-bgSize.height/2-5)
		mainBg2:addChild(self.rewardSpr[i])

		for j=1,4 do
			local goodSpr=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
			goodSpr:setPosition(58+92*(j-1),45)
			goodSpr:setScale(0.8)
			self.rewardSpr[i]:addChild(goodSpr)
		end
    end

	local function c(serder,eventType)
		if eventType==ccui.TouchEventType.ended then
			print("=========>>>>> close touch")
			self:closeWindow()
		end
	end
	local closeBtn=gc.CButton:create("general_close.png")
    closeBtn:setPosition(self.m_winSize.width*0.5+self.m_mainSize.width*0.5+1,self.m_winSize.height*0.5+self.m_mainSize.height*0.5+2)
    closeBtn:setAnchorPoint(cc.p(1,1))
    closeBtn:addTouchEventListener(c)
    closeBtn:setSoundPath("bg/ui_sys_clickoff.mp3")
    self.m_rootLayer:addChild(closeBtn,10)

    local function f(serder,eventType)
    	if eventType==ccui.TouchEventType.ended then
    		local tag=serder:getTag()
			print("=========>>>>> orther touch 444",tag)
			if tag==P_TAG_SUB then
				if self.m_selectTimes>1 then
					self.m_selectTimes=self.m_selectTimes-1
					self:__updateLabel()
				end
			elseif tag==P_TAG_ADD then
				if self.m_selectTimes<self.m_canMopTimes then
					self.m_selectTimes=self.m_selectTimes+1
					self:__updateLabel()
				end
			elseif tag==P_TAG_MAX then
				if self.m_selectTimes~=self.m_canMopTimes then
					self.m_selectTimes=self.m_canMopTimes
					self:__updateLabel()
				end
			elseif tag==P_TAG_SPEED then
				local function local_sureHuangup()
					self:REQ_COPY_UP_SPEED()
				end
				local serverTimes = _G.TimeUtil:getTotalSeconds()
				local times    = self.m_endHuangupTime-serverTimes
				local oneTimes = 60
				local minNum = (times%oneTimes==0) and times/oneTimes or (math.floor(times/oneTimes)+1)
				local useRmb = minNum*_G.Const.CONST_COPY_SPEED_RMB
				local szMsg  = string.format("花费%d元宝进行扫荡？\n(元宝不足则消耗钻石)",useRmb)
				_G.Util:showTipsBox(szMsg,local_sureHuangup)
			elseif tag==P_TAG_MOP then
				local curTimes=self.m_selectTimes
				if curTimes>0 then
					--发协议
					self:REQ_COPY_UP_START(0,curTimes,1)
					self:__removeScrollView()
				else
					local energyHas=self.m_myProperty:getAllEnergy()
					local sceneCopyNode=_G.GCopyProxy:getCopyNodeByCopyId(self.m_copyId)
					local times=math.floor(energyHas/sceneCopyNode.use_energy)
					if times<=0 then
						local command = CErrorBoxCommand(14150)
	    				controller :sendCommand(command)
	    			else
	    				local command = CErrorBoxCommand(14160)
	    				controller :sendCommand(command)
	    			end
				end
				if self.m_guideNode~=nil then
					self.m_guideNode:removeFromParent(true)
					self.m_guideNode=nil
				end
			elseif tag==P_TAG_VIPMOP then  --- 取消扫荡

				 self:closeWindow()  
				local curTimes=self.m_selectTimes
				if curTimes>0 then
				   --[[
					--发协议
					local function cfun()
						self:REQ_COPY_UP_START(0,curTimes,2)
					end
					
					local rmb=0
					--[[
					local drawrmb=self.m_sceneCopy_Cnf.draw_rmb
					print("drawrmb--->",drawrmb[1])
					for i=self.m_copyEVA,3 do
						rmb=rmb+drawrmb[i][2]
					end
					--]]
					--[[
					rmb=rmb*curTimes
					local tipsStr=string.format("当前副本通关星级为%d",self.m_copyEVA)
					local tips1Str=string.format("花费%d钻石扫荡%d次取出所有奖励?",rmb,curTimes)
					local tipsBox = require("mod.general.TipsBox")()
					local layer   = tipsBox :create( tipsStr, cfun)
					layer : setPosition(cc.p(self.m_mainSize.width/2,self.m_mainSize.height/2))
					mainBg : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
					tipsBox : setTitleLabel("提 示")
					local Lab_2 = _G.Util : createLabel(tips1Str, 20  )
				    tipsBox:getMainlayer() : addChild( Lab_2 )
				    --]]
				    --self:__removeScrollView()



				else
					local energyHas=self.m_myProperty:getAllEnergy()
					local sceneCopyNode=_G.GCopyProxy:getCopyNodeByCopyId(self.m_copyId)
					local times=math.floor(energyHas/sceneCopyNode.use_energy)
					if times<=0 then
						local command = CErrorBoxCommand(14150)
	    				controller :sendCommand(command)
	    			else
	    				local command = CErrorBoxCommand(14160)
	    				controller :sendCommand(command)
	    			end
				end
				if self.m_guideNode~=nil then
					self.m_guideNode:removeFromParent(true)
					self.m_guideNode=nil
				end
			elseif tag==P_TAG_STOP then
				if self.m_myType~=P_TYPE_MOP then return end

				local function cfun()
					local msg=REQ_COPY_UP_STOP()
					_G.Network:send(msg)
				end
				_G.Util:showTipsBox("是否取消扫荡?",cfun)
			elseif tag==P_TAG_REWARD then
				-- local msg=REQ_COPY_UP_REWARD_GET()
				-- _G.Network:send(msg)
				self:closeWindow()
			end
		end
    end 

    local normalLabel
    local fontSize1=20
    local fontSize2=20
    local midPosX=118
    local nPosX=24

    -- ********************************************************
    -- 次数选择
    normalLabel=_G.Util:createLabel("扫荡次数:",22)
    normalLabel:setAnchorPoint(cc.p(0,0.5))
    normalLabel:setPosition(nPosX,345)
    mainBg:addChild(normalLabel)

    local nPosY=298
    local blackSize=cc.size(85,33)
    local blackSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
	blackSpr:setPreferredSize(blackSize)
	blackSpr:setPosition(nPosX+85,nPosY)
	mainBg:addChild(blackSpr)

	local subBtn=gc.CButton:create()
    subBtn:loadTextures("general_btn_reduce.png")
    subBtn:setContentSize(70,70)
    subBtn:setAnchorPoint(cc.p(0,0.5))
    subBtn:addTouchEventListener(f)
    subBtn:setTag(P_TAG_SUB)
    subBtn:setPosition(nPosX-20,nPosY)
    mainBg:addChild(subBtn)

    local addBtn=gc.CButton:create()
    addBtn:loadTextures("general_btn_add.png")
    addBtn:setContentSize(70,70)
    addBtn:setAnchorPoint(cc.p(0,0.5))
    addBtn:addTouchEventListener(f)
    addBtn:setTag(P_TAG_ADD)
    addBtn:setPosition(nPosX+117,nPosY)
    mainBg:addChild(addBtn)

    self.m_selectLabel=_G.Util:createLabel("99",fontSize1)
    self.m_selectLabel:setPosition(blackSize.width*0.5,blackSize.height*0.5-2)
    blackSpr:addChild(self.m_selectLabel)
    
    -- 剩余次数
    nPosY=232
    normalLabel=_G.Util:createLabel("剩余次数:",fontSize2)
    normalLabel:setAnchorPoint(cc.p(0,0.5))
    normalLabel:setPosition(nPosX,nPosY)
    mainBg:addChild(normalLabel)

    local labelSize=normalLabel:getContentSize()
    
	self.m_surplusTimesLabel=_G.Util:createLabel("5",fontSize1)
	self.m_surplusTimesLabel:setAnchorPoint(cc.p(0,0.5))
    self.m_surplusTimesLabel:setPosition(nPosX+labelSize.width+10,nPosY)
    self.m_surplusTimesLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    mainBg:addChild(self.m_surplusTimesLabel)

    -- ********************************************************
    -- 消耗体力
    nPosY=190
    normalLabel=_G.Util:createLabel("消耗体力:",fontSize2)
    normalLabel:setAnchorPoint(cc.p(0,0.5))
    normalLabel:setPosition(nPosX,nPosY)
    mainBg:addChild(normalLabel)
    self.normalLabel  = normalLabel

    local labelSize=normalLabel:getContentSize()

	self.m_useEnergyLabel=_G.Util:createLabel("999",fontSize1)
	self.m_useEnergyLabel:setAnchorPoint(cc.p(0,0.5))
    self.m_useEnergyLabel:setPosition(nPosX+labelSize.width+10,nPosY)
    self.m_useEnergyLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    mainBg:addChild(self.m_useEnergyLabel)


    -- ********************************************************
    -- 预计时间
    nPosY=148
    normalLabel=_G.Util:createLabel("预计时间:",fontSize1)
    normalLabel:setAnchorPoint(cc.p(0,0.5))
    normalLabel:setPosition(nPosX,nPosY)
    mainBg:addChild(normalLabel)

    labelSize=normalLabel:getContentSize()

	self.m_useTimesLabel=_G.Util:createLabel("24:00:00",fontSize1)
	self.m_useTimesLabel:setAnchorPoint(cc.p(0,0.5))
    self.m_useTimesLabel:setPosition(nPosX+labelSize.width+10,nPosY)
    self.m_useTimesLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    mainBg:addChild(self.m_useTimesLabel)

    -- ********************************************************
    -- 挂机提示
    nPosY=107
    -- print ("self.m_vipMaxToSpeed-->",self.m_vipMaxToSpeed)
    -- normalLabel=_G.Util:createLabel(string.format("VIP%d可自动加速。",self.m_vipMaxToSpeed),fontSize1)
    -- normalLabel:setPosition(midPosX,nPosY)
    -- normalLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LABELBLUE))
    -- mainBg:addChild(normalLabel)
    -- self.m_mopNoticLabel=normalLabel

    -- labelSize=normalLabel:getContentSize()
    -- local noticSpr=cc.Sprite:createWithSpriteFrameName("general_tanhao.png")
    -- noticSpr:setAnchorPoint(cc.p(1,0.5))
    -- noticSpr:setPosition(midPosX-labelSize.width*0.5,nPosY)
    -- mainBg:addChild(noticSpr)



    -- ********************************************************
    -- 按钮
    nPosY=48
    local mopBtn=gc.CButton:create()
    mopBtn:loadTextures("general_btn_gold.png")
    mopBtn:addTouchEventListener(f)
    mopBtn:setTag(P_TAG_MOP)
    mopBtn:setTitleFontSize(24)
    mopBtn:setTitleText("取消扫荡")
    mopBtn:setTitleFontName(_G.FontName.Heiti)
    mainBg:addChild(mopBtn)
    self.m_mopBtn=mopBtn
    if self.m_vipUseTimes==0 and self.m_copyType==_G.Const.CONST_COPY_TYPE_NORMAL then
    	mopBtn:setPosition(midPosX,nPosY)
    else
    	local speedBtn=gc.CButton:create()
	    speedBtn:loadTextures("general_btn_gold.png")
	    speedBtn:addTouchEventListener(f)
	    speedBtn:setTag(P_TAG_SPEED)
	    speedBtn:setTitleFontSize(24)
	    speedBtn:setTitleText("加  速")
	    speedBtn:setButtonScale(0.75)
	    speedBtn:setTitleFontName(_G.FontName.Heiti)
	    mainBg:addChild(speedBtn)
	    self.m_speedBtn=speedBtn

	    mopBtn  :setButtonScale(0.75)
	    mopBtn  :setPosition(midPosX+45,nPosY)
	    speedBtn:setPosition(midPosX-55,nPosY)
    end

    local rewardBtn=gc.CButton:create()
    rewardBtn:loadTextures("general_btn_gold.png")
    rewardBtn:addTouchEventListener(f)
    rewardBtn:setTag(P_TAG_REWARD)
    rewardBtn:setTitleFontSize(24)
    rewardBtn:setTitleText("领 取")
    rewardBtn:setTitleFontName(_G.FontName.Heiti)
    rewardBtn:setPosition(midPosX,nPosY)
    mainBg:addChild(rewardBtn)
    self.m_rewardBtn=rewardBtn

	self:setCurState(P_TYPE_STOP)
	self:__updateLabel()
	self:updateSurplusTimes(self.m_surplusTimes)

	if not self.m_isOffLine then
		local mopGuideCnf=_G.GGuideManager.m_mopGuideCnf
		if mopGuideCnf~=nil then
			local mopBtnSize=mopBtn:getContentSize()
			local guideNode=_G.GGuideManager:createTouchNode()
			guideNode:setPosition(mopBtnSize.width*0.5,mopBtnSize.height*0.5)
			mopBtn:addChild(guideNode,10)

			local isTurn,posX,posY,anPoint,szContent
			if mopGuideCnf.step and mopGuideCnf.step[1] then
				local step1Data=mopGuideCnf.step[1]
				isTurn=step1Data.turn==1
				posX=step1Data.notic_off[1]
				posY=step1Data.notic_off[2]
				anPoint=cc.p(step1Data.notic_mid[1],step1Data.notic_mid[1])
				szContent=step1Data.notic
			else
				isTurn=true
				posX=-225
				posY=0
				anPoint=cc.p(0.5,0.5)
				szContent="[ERROR]"
			end
			local noticNode=_G.GGuideManager:createNoticNode(szContent,isTurn)
			noticNode:setAnchorPoint(anPoint)
			noticNode:setPosition(posX,posY)
			guideNode:addChild(noticNode,10)
			self.m_guideNode=guideNode

			_G.GGuideManager.m_mopGuideCnf=nil
		end
	end
end 

function CopySaoDangView.__initParams( self )
	print("self.m_copyId--->",self.m_copyId)
	if self.m_copyId == nil then
		return
	end
   
	self.m_sceneCopy_Cnf  = _G.Cfg.scene_copy[self.m_copyId]
	self.m_copyReward_Cnf = _G.Cfg.copy_reward[self.m_copyId]
	if self.m_sceneCopy_Cnf == nil then
		CCMessageBox( "data error  "..self.m_copyId,"scene_copy" )
	end
	self.m_useEnergy = self.m_sceneCopy_Cnf.use_energy
	self.m_copyType  = self.m_sceneCopy_Cnf.copy_type

	self.m_myProperty = _G.GPropertyProxy:getMainPlay()
	local myVip = self.m_myProperty:getVipLv() or 0
	local vipCnf= _G.Cfg.vip[myVip]
	self.m_vipUseTimes=0
	if vipCnf~=nil then
		if self.m_copyType==_G.Const.CONST_COPY_TYPE_NORMAL then
			self.m_vipUseTimes=vipCnf.normal
		elseif self.m_copyType==_G.Const.CONST_COPY_TYPE_HERO then
			self.m_vipUseTimes=vipCnf.hero
		else
			self.m_vipUseTimes=vipCnf.fiend
		end
	end

	self.m_vipMaxToSpeed=0
	local vipArray=_G.Cfg.vip
	print("vipArray-->",vipArray)
	for i=0,#vipArray do
		if self.m_copyType==_G.Const.CONST_COPY_TYPE_NORMAL then
			if vipArray[i].normal==0 then
				self.m_vipMaxToSpeed=i
				break
			end
		elseif self.m_copyType==_G.Const.CONST_COPY_TYPE_HERO then
			if vipArray[i].hero==0 then
				self.m_vipMaxToSpeed=i
				break
			end
		else
			if vipArray[i].fiend==0 then
				self.m_vipMaxToSpeed=i
				break
			end
		end
	end

	CCLOG("[CopySaoDangView.__initParams]--->>>vip=%d,  %d,  %d",myVip,self.m_vipUseTimes,self.m_vipMaxToSpeed)
end

function CopySaoDangView.createScrollView( self )
	self :__removeScrollView()
	local viewSize=cc.size(self.m_rewardSize.width,self.m_rewardSize.height-4)
	self.m_rewardScoSize=viewSize
	self.m_rewardScrollView=cc.ScrollView:create()
    self.m_rewardScrollView:setPosition(227,17.5)
    self.m_rewardScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_rewardScrollView:setViewSize(viewSize)
    self.m_rewardScrollView:setContentSize(viewSize)
    self.m_rewardScrollView:setBounceable(false)
    self.m_rewardScrollView:setTouchEnabled(true)
    self.m_rightBg:addChild( self.m_rewardScrollView )

 --    self.m_mopingLabel=_G.Util:createLabel("扫荡中...",24)
 --    self.m_mopingLabel:setAnchorPoint(cc.p(0,0.5))
	-- self.m_mopingLabel:setPosition(30,viewSize.height-30)
	-- self.m_mopingLabel:setVisible(false)
	-- self.m_rewardScrollView:addChild(self.m_mopingLabel)

    self.m_rewardNodeList = {}
    self.m_barView=require("mod.general.ScrollBar")(self.m_rewardScrollView)
    self.m_barView:setPosOff(cc.p(1,0))
end

function CopySaoDangView.__removeScrollView( self )
	if self.m_rewardScrollView~=nil then
		self.m_rewardScrollView:removeFromParent(true)
		self.m_rewardScrollView=nil
	end
	if self.m_barView~=nil then
		self.m_barView:remove()
		self.m_barView=nil
	end
	-- self.m_mopingLabel=nil
end

function CopySaoDangView.setCurState( self, _type )
	self.m_myType = _type

	-- if self.m_mopingLabel then
	-- 	self.m_mopingLabel:setVisible(false)
	-- end
	if _type==P_TYPE_REWARD then
		self.m_rewardBtn:setVisible(true)
		self.m_mopBtn:setVisible(false)
		if self.m_speedBtn then
			self.m_speedBtn:setVisible(false)
		end
		self.m_endHuangupTime=nil
		return
	else
		self.m_rewardBtn:setVisible(false)
		self.m_mopBtn:setVisible(true)
		if self.m_speedBtn then
			self.m_speedBtn:setVisible(true)
		end
	end

	if _type==P_TYPE_STOP then
		if self.m_copyType==_G.Const.CONST_COPY_TYPE_NORMAL then
			if self.m_speedBtn then
				self.m_speedBtn:setEnabled(false)
				self.m_speedBtn:setBright(false)

				self.m_mopBtn:setTitleText("扫 荡")
				self.m_mopBtn:setTag(P_TAG_MOP)
			else
				self.m_mopBtn:setEnabled(true)
				self.m_mopBtn:setBright(true)
			end
		else
			if self.m_speedBtn then
				self.m_speedBtn:setTitleText("扫 荡")
				self.m_speedBtn:setTag(P_TAG_MOP)
				---self.m_mopBtn:setTitleText("高级扫荡")
				self.m_mopBtn:setTag(P_TAG_VIPMOP)
			else
				self.m_mopBtn:setEnabled(true)
				self.m_mopBtn:setBright(true)
			end
		end
		self.m_endHuangupTime=nil
	elseif _type==P_TYPE_MOP then
		if self.m_copyType==_G.Const.CONST_COPY_TYPE_NORMAL then
			if self.m_speedBtn then
				self.m_speedBtn:setEnabled(true)
				self.m_speedBtn:setBright(true)

				self.m_mopBtn:setTitleText("停 止")
				self.m_mopBtn:setTag(P_TAG_STOP)
			else
				self.m_mopBtn:setEnabled(false)
				self.m_mopBtn:setBright(false)
			end
		else
			if self.m_speedBtn then
				self.m_speedBtn:setTitleText("加 速")
				self.m_speedBtn:setTag(P_TAG_SPEED)

				self.m_mopBtn:setTitleText("停 止")
				self.m_mopBtn:setTag(P_TAG_STOP)
			else
				self.m_mopBtn:setEnabled(false)
				self.m_mopBtn:setBright(false)
			end
		end
		self:__registerSchedule()
	elseif _type==P_TYPE_SPEED then
		self.m_mopBtn:setEnabled(false)
		self.m_mopBtn:setBright(false)
		if self.m_speedBtn then
			self.m_speedBtn:setEnabled(false)
			self.m_speedBtn:setBright(false)
		end
		self.m_endHuangupTime=nil
	end
end
function CopySaoDangView.__updateLabel(self)
	local hasEnergy=_G.GPropertyProxy:getMainPlay():getAllEnergy()
	-- local szTimes=string.format("%d/%d",self.m_selectTimes,self.m_canMopTimes)
	self.m_selectLabel:setString(tostring(self.m_selectTimes))
	if self.m_useEnergy<=0 then
		self.m_useEnergyLabel:setVisible(false)
		self.normalLabel:setString("不消耗体力")
	else
		local syTimes=string.format("%d/%d",self.m_selectTimes*self.m_useEnergy,hasEnergy)
		self.m_useEnergyLabel:setString(syTimes)
		self.m_useEnergyLabel:setVisible(true)
		-- self.normalLabel:setString("消耗体力:")
	end

	self:__updateUseTimesLabel()
end

function CopySaoDangView.updateSurplusTimes(self,_times)
	self.m_surplusTimes=_times
	self.m_surplusTimesLabel:setString(tostring(_times))
end
function CopySaoDangView.__updateUseTimesLabel( self )
	if self.m_myType~=P_TYPE_STOP and self.m_myType~=P_TYPE_REWARD then
		return
	end
	if self.m_vipUseTimes==0 then
		-- self.m_useTimesLabel:setString("VIP"..self.m_vipMaxToSpeed.._G.Lang.LAB_N[144])
		self.m_useTimesLabel:setString("00:00:00")
	else
		local totalTimes=self.m_selectTimes*self.m_vipUseTimes
		local szTimes=self:getTimeStr(totalTimes)
		self.m_useTimesLabel:setString(szTimes)
		print("__updateUseTimesLabel===>>",totalTimes,szTimes)
	end
end

function CopySaoDangView.__registerSchedule( self )
	CCLOG("CopySaoDangView.__registerSchedule------>>>> 11")
	if self.m_mySchedule ~= nil then
		return
	end
	local _timeUtil=_G.TimeUtil
	local curTimes=_timeUtil:getTotalSeconds()
	local delayTimes=self.m_endHuangupTime-curTimes
	local nCount=math.floor(self.m_vipUseTimes/10)
	nCount=nCount<=0 and 1 or nCount
	local tCount=nCount-delayTimes%self.m_vipUseTimes%6

	print("__registerSchedule   1===>>>",curTimes)
	print("__registerSchedule   2===>>>",self.m_endHuangupTime)
	print("__registerSchedule   3===>>>",delayTimes)
	print("__registerSchedule   4===>>>",nCount)
	print("__registerSchedule   5===>>>",tCount)

	local function local_updateFun()
		if self.m_endHuangupTime~=nil then
			local serverTimes=_timeUtil:getTotalSeconds()
			local syTimes    =self.m_endHuangupTime-serverTimes
			-- print("===>>>>",self.m_endHuangupTime,serverTimes,syTimes)
			if syTimes>=0 then
				local timeStr=self:getTimeStr(syTimes)
				self.m_useTimesLabel:setString(timeStr)
			end

			if tCount>=nCount then
				tCount=0
				local msg=REQ_COPY_UP_REQUEST()
				_G.Network:send(msg)
			end
			tCount=tCount+1
		else
			self:unregisterSchedule()
		end
	end

	CCLOG("CopySaoDangView.__registerSchedule------>>>> 22")
	self.m_mySchedule=_G.Scheduler:schedule(local_updateFun,1)
end

function CopySaoDangView.unregisterSchedule( self )
	CCLOG("CopySaoDangView.unregisterSchedule------>>>>")
	if self.m_mySchedule~=nil then
		_G.Scheduler:unschedule(self.m_mySchedule)
		self.m_mySchedule=nil
	end
end

function CopySaoDangView.updateTimesByOffLine(self)
	if self.m_endHuangupTime==nil or self.m_useTimesLabel==nil then return end
	local serverTimes=_G.TimeUtil:getTotalSeconds()
	local syTimes    =self.m_endHuangupTime-serverTimes
	if syTimes>=0 then
		local timeStr=self:getTimeStr(syTimes)
		self.m_useTimesLabel:setString(timeStr)
	end
end

function CopySaoDangView.addOneReward( self, _ackMsg )
	if self.m_rewardScrollView==nil then
		self:createScrollView()
	end

	if self.m_addRewardNum>=_ackMsg.nowtimes then return end
	self.m_addRewardNum=_ackMsg.nowtimes

	local oneHeight=self.m_rewardScoSize.height/3
	local isLastReward=_ackMsg.nowtimes==_ackMsg.sumtimes
	local curCount=#self.m_rewardNodeList + 1
	local totalHeight=curCount>2 and curCount*oneHeight or self.m_rewardScoSize.height
	local nnnnnnnn=totalHeight-oneHeight
	-- nnnnnnnn=_ackMsg.sumtimes==1 and self.m_rewardScoSize.height*0.5 or nnnnnnnn
	self.m_rewardNodeList[curCount]=self:__createOneReward(_ackMsg)
	self.m_rewardNodeList[curCount]:setPosition(0,nnnnnnnn)
	self.m_rewardScrollView:addChild(self.m_rewardNodeList[curCount])
	if self.rewardSpr[curCount]~=nil then
		self.rewardSpr[curCount]:setVisible(false)
	end
	if curCount>2 then
		if not isLastReward then
			curCount=curCount+1
		end

		for i=1,curCount-1 do
			local node=self.m_rewardNodeList[i]
			node:setPosition(0,(i-1)*oneHeight)
		end
		
		self.m_rewardScrollView:setContentSize(cc.size(self.m_rewardScoSize.width,totalHeight))
		self.m_rewardScrollView:setContentOffset(cc.p(0,self.m_rewardScoSize.height-totalHeight))
		self.m_barView:chuangeSize()
	elseif curCount==2 then
		self.m_rewardNodeList[1]:setPosition(0,nnnnnnnn-oneHeight)
	end

	if isLastReward then
		self:huangupFinish()
		if self.m_vipUseTimes==0 then
			_G.Util:playAudioEffect("ui_kill")
		end
	-- else
		-- self.m_mopingLabel:setPosition(30,self.m_rewardScoSize.height*0.5-30)
	end
	if self.m_vipUseTimes~=0 then
		_G.Util:playAudioEffect("ui_kill")
	end

	self.m_isEverHuangup=true
end

function CopySaoDangView.__createOneReward( self, _reward )
	print("__createOneReward",_reward.exp,_reward.gold)
	local node=cc.Node:create()

	local bgSize=cc.size(self.m_rewardScoSize.width-8,(self.m_rewardScoSize.height+4)/3-2)
	local tempBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_nothis.png")
	tempBg:setPreferredSize(bgSize)
	tempBg:setAnchorPoint(cc.p(0,0))
	tempBg:setPosition(10,0)
	node:addChild(tempBg)

	local color2=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE)
	local fontSize=22
	local tLabel1=_G.Util:createLabel("第",fontSize)
	local tLabel2=_G.Util:createLabel(tostring(_reward.nowtimes),fontSize)
	local tLabel3=_G.Util:createLabel("次扫荡",fontSize)
	tLabel1:setColor(color2)
	tLabel3:setColor(color2)
	tLabel1:setAnchorPoint(cc.p(0,0.5))
	tLabel2:setAnchorPoint(cc.p(0,0.5))
	tLabel3:setAnchorPoint(cc.p(0,0.5))
	local tSize1=tLabel1:getContentSize()
	local tSize2=tLabel2:getContentSize()
	local tSize3=tLabel3:getContentSize()
	local posX=bgSize.width*0.5-(tSize1.width+tSize2.width+tSize3.width)*0.5
	local posY=bgSize.height-20
	tLabel1:setPosition(posX,posY)
	tLabel2:setPosition(posX+tSize1.width+2,posY)
	tLabel3:setPosition(posX+tSize1.width+tSize2.width+4,posY)
	tempBg:addChild(tLabel1)
	tempBg:addChild(tLabel2)
	tempBg:addChild(tLabel3)

	local function r(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local pos=sender:getWorldPosition()
			if pos.y<162 or pos.y>437 then return end
			local goodId=sender:getTag()
            local temp=_G.TipsUtil:createById(goodId,nil,pos)
            cc.Director:getInstance():getRunningScene():addChild(temp,1000)
		end
	end

	local goodsArray={}
	local goodsCount=0
	if _reward.exp>0 then
		goodsCount=goodsCount+1
		goodsArray[goodsCount]={goods_id=46700,count=_reward.exp}
	end
	if _reward.gold>0 then
		goodsCount=goodsCount+1
		goodsArray[goodsCount]={goods_id=46000,count=_reward.gold}
	end
	for i=1,#_reward.data do
		goodsCount=goodsCount+1
		goodsArray[goodsCount]=_reward.data[i]
	end

	posY=45
	posX=68
	local szWan=_G.Lang.LAB_N[55]
	-- local countColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD)
	local pUtil=_G.Util
	local play=_G.g_lpMainPlay
	local goldUp=play.m_goldUP
	local expUP=play.m_expUP
	print("goodsCount",goodsCount,play,goldUp,expUP)
	for i=1,4 do
		local goodSpr=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
		goodSpr:setPosition(posX+92*(i-1),posY)
		goodSpr:setScale(0.8)
		node:addChild(goodSpr)

		local sprSize=goodSpr:getContentSize()
		if goodsArray[i]~=nil then
			local goodId=goodsArray[i].goods_id
			local count =goodsArray[i].count
			local goodsCnf=_G.Cfg.goods[goodId]
			if goodsCnf~=nil then
				local iconBtn=_G.ImageAsyncManager:createGoodsBtn(goodsCnf,r,goodId)
				iconBtn:setPosition(sprSize.width*0.5,sprSize.height*0.5)
				iconBtn:setSwallowTouches(false)
				goodSpr:addChild(iconBtn)

				if goodId == 46000 then
					print( "goodId == 46000 ", goldUp )
					if goldUp and goldUp ~= 1 then
						local node     = self : createUPNum( goldUp )
		                goodSpr  : addChild( node )
					end
				end
				if goodId == 46700 then
					if expUP and expUP ~= 1 then
						local node     = self : createUPNum( expUP )
		                goodSpr  : addChild( node,5 )
					end
				end

			end

			local szCount=count>10000 and math.modf(count*0.0001)..szWan or tostring(count)
			local numLabel=pUtil:createLabel(szCount,fontSize-2)
			numLabel:setAnchorPoint(cc.p(1,0))
			numLabel:setPosition(sprSize.width-6,3)
			-- numLabel:setColor(countColor)
			goodSpr:addChild(numLabel)
		end
	end

	return node
end

function CopySaoDangView.createUPNum( self, _num )
	print( "CopySaoDangView.createUPNum" )
    local node = cc.Node : create()

    local num = _num*100
    local allNum = {}
    allNum[1] = math.floor(num/100)
    allNum[3] = math.floor(num%100/10)
    allNum[4] = math.floor(num%10)
    print( "allNum ===>> ", allNum[1],allNum[3],allNum[4] )

    local base = cc.Sprite : createWithSpriteFrameName( "shop_bei.png" )
    base : setAnchorPoint( 0, 0 )
    base : setPosition( 4, 6 )
    node : addChild( base )

    local node2 = cc.Layer : create()
    node2 : setRotation( -45 )

    local width = 0
    for i=1,4 do
        local sprName = nil
        local posy    = 0
        if i == 2 then
            sprName = "shop_dian.png"
        else
            sprName = string.format( "shop_%d.png", allNum[i] )
        end
        local spr = cc.Sprite : createWithSpriteFrameName( sprName )
        spr   : setAnchorPoint( 0, 0 )
        spr   : setPosition( width+35, 11 )
        node2 : addChild( spr )
        if i == 2 then
            spr : setPosition( width+35, 6 )
        end
        width = width + spr:getContentSize().width
        if i == 1 or i == 2 then
            width = width - 6
        end
    end

    node2 : setScale( 0.8 )
    node2 : setContentSize( cc.size( width, 1 ) )
    node2 : setAnchorPoint( 0, 0 )
    node2 : setPosition(0, 0 )
    node  : addChild( node2,1 )
    return node
end

function CopySaoDangView.closeWindow( self )
	if not self.m_rootLayer then return end
	self:unregisterSchedule()
	self:destroy()

	self.m_rootLayer:removeFromParent(true)
	self.m_rootLayer=nil

	if self.m_myType==P_TYPE_REWARD then
		local msg=REQ_COPY_UP_REWARD_GET()
		_G.Network:send(msg)
	elseif self.m_myType==P_TYPE_MOP then
		local command=CCopyMapCommand(CCopyMapCommand.HUANGUP_END3)
		controller:sendCommand(command)
		return
	end
	if self.m_isEverHuangup then
		--至少挂机过一次才发
		local command=CCopyMapCommand(CCopyMapCommand.HUANGUP_END2)
		command.copyId=self.m_copyId
		controller:sendCommand(command)
	else
		local command=CCopyMapCommand(CCopyMapCommand.HUANGUP_END1)
		controller:sendCommand(command)
	end
	self.view : REQ_HOOK_REQUEST()
end

--飘字
function CopySaoDangView.showErrorCode( self, _msg, _colorType )
    local command=CErrorBoxCommand(_msg,_colorType)
    controller:sendCommand(command)
end

-- [7840]开始挂机 -- 副本 
function CopySaoDangView.REQ_COPY_UP_START( self, _isUseAll, _num, _type )
	local msg=REQ_COPY_UP_START()
	msg:setArgs(self.m_copyId,_isUseAll,_num,_type)
	_G.Network:send(msg)
end

-- [7845]加速挂机 -- 副本 
function CopySaoDangView.REQ_COPY_UP_SPEED( self )
	local msg=REQ_COPY_UP_SPEED()
	_G.Network:send(msg)
end
-- [7870]停止挂机 -- 副本 
function CopySaoDangView.REQ_COPY_UP_STOP( self )
	local msg=REQ_COPY_UP_STOP()
	_G.Network:send(msg)
end

function CopySaoDangView.getTimeStr( self, _time )
    local hour    = math.floor( _time/3600 )
    local min     = math.floor( _time%3600/60 )
    local second  = _time%60
    local timeStr = string.format("%.2d",hour)..":"..string.format("%.2d",min)..":"..string.format("%.2d",second)
    return timeStr
end

function CopySaoDangView.unregisterSchedule( self )
	CCLOG("CopySaoDangView.unregisterSchedule------>>>>")
	if self.m_mySchedule~=nil then
		_G.Scheduler:unschedule(self.m_mySchedule)
		self.m_mySchedule=nil
	end
end

function CopySaoDangView.ACK_COPY_UP_OVER( self, _ackMsg )
	local nType=_ackMsg.type
	if nType==_G.Const.CONST_COPY_UPTYPE_NORMAL then
		if self.m_preMopTimes then
			local useTimes=self.m_preMopTimes-self.m_addRewardNum
			self.m_canMopTimes=self.m_canMopTimes+useTimes
		end
		self:huangupFinish()
	elseif nType==_G.Const.CONST_COPY_UPTYPE_SPEED then
		-- local command=CErrorBoxCommand( _G.Lang.LAB_N[149] )
    	-- controller:sendCommand( command )

    	if self.m_myType~=P_TYPE_MOP then return end

		self :setCurState(P_TYPE_SPEED)
		-- self.m_useTimesLabel :setString(_G.Lang.LAB_N[150])
		self.m_useTimesLabel:setString("00:00:00")
	elseif nType==_G.Const.CONST_COPY_UPTYPE_BAG_FULL then
		self :showErrorCode( _G.Lang.ERROR_N[27] )
		self :huangupFinish()
	-- elseif nType==_G.Const.CONST_COPY_UPTYPE_VIP then
		-- self :showErrorCode( "挂机完成 VIP" )
		-- self :huangupFinish()
	end
end

function CopySaoDangView.getRewardCallBack(self)
	self:setCurState(P_TYPE_STOP)
end

function CopySaoDangView.huangupFinish(self)
	if self.m_addRewardNum>0 then
		self:setCurState(P_TYPE_REWARD)
	else
		self:setCurState(P_TYPE_STOP)
	end

	if self.m_canMopTimes>0 then
		self.m_selectTimes=1
	else
		self.m_selectTimes=0
	end
	self:__updateLabel()
end

return CopySaoDangView 