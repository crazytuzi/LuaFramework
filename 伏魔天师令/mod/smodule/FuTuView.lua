local FuTuView=classGc(view,function(self)
	self.m_winSize=cc.Director:getInstance():getWinSize()
	self.m_leftSize=cc.size(520,472)
	self.m_rightSize=cc.size(240,472)

	-- self.m_preChallengeTimes=0
	self.m_preMopTimes=0
end)

local P_TAG_CHALLENGE=1
local P_TAG_MOP=2
local P_TAG_BUY_TIME=3
local P_TAG_RESET=4
local P_FONT_NAME=_G.FontName.Heiti
local P_COLOR_BROWN=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN)
local P_COLOR_GOLD=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD)
local P_COLOR_DARKORANGE=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE)
local P_COLOR_RED=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED)

function FuTuView.create(self)
	self.m_normalView=require("mod.general.NormalView")()
	self.m_rootLayer=self.m_normalView:create()

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	self:__initParameter()
	self:__initView()
	self:__requestAllMsg()
	-- self:__createRightView()
	-- self:__createLeftView()

	self.m_mediator=require("mod.smodule.FuTuMediator")(self)

	return tempScene
end

function FuTuView.__initParameter(self)
	self.m_myLv=_G.GPropertyProxy:getMainPlay():getLv()
	self.m_copyChapCnf=_G.Cfg.copy_chap[_G.Const.CONST_COPY_TYPE_FIGHTERS]
	local tempArray={}
	local tempCount=0
	for k,v in pairs(self.m_copyChapCnf) do
		tempCount=tempCount+1
		tempArray[tempCount]=k
	end
	local function nSort(v1,v2)
		return v1<v2
	end
	table.sort(tempArray,nSort)
	self.m_chapPosArray={}
	for i=1,tempCount do
		self.m_chapPosArray[tempArray[i]]=i
	end
	self.m_chapIdArray=tempArray
end

function FuTuView.__initView(self)
	local function nCloseFun()
		self:closeWindow()
	end
	self.m_normalView:addCloseFun(nCloseFun)
	self.m_normalView:showSecondBg()
	self.m_normalView:setTitle("通天浮屠")

	self.m_mainNode=cc.Node:create()
	self.m_mainNode:setPosition(self.m_winSize.width*0.5,self.m_winSize.height*0.5)
	self.m_rootLayer:addChild(self.m_mainNode)

	local doubleSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double.png")
	doubleSpr:setPreferredSize(self.m_rightSize)
	doubleSpr:setPosition(296,-40)
	self.m_mainNode:addChild(doubleSpr)

	local rightBgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
	rightBgSpr:setPreferredSize(cc.size(self.m_rightSize.width-10,self.m_rightSize.height-10))
	rightBgSpr:setPosition(296,-41)
	self.m_mainNode:addChild(rightBgSpr)

	-- 左边基础控件=============================================
	local floorBg=cc.Sprite:create("ui/bg/bg_futu.jpg")
	floorBg:setPosition(-123,-40)
	floorBg:setScale(0.99)
	self.m_mainNode:addChild(floorBg)

	-- local tipsSpr = cc.Sprite:createWithSpriteFrameName("general_tanhao.png")
	-- tipsSpr:setPosition(50,20)
	-- floorBg:addChild(tipsSpr,10)

	local noticLabel=_G.Util:createLabel("当层若无法全部通关,第二天需要重新挑战!",18)
	noticLabel:setPosition(self.m_leftSize.width*0.5,18)
	noticLabel:setColor(P_COLOR_RED)
	floorBg:addChild(noticLabel,10)

	local function r(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_JINGXIU) then return false else
			self:closeWindow()
			_G.GLayerManager : openSubLayerByMapOpenId(_G.Const.CONST_MAP_JINGXIU) end
		end
	end
	local challengeBtn=gc.CButton:create("futu_go.png")
    challengeBtn:setPosition(40,self.m_leftSize.height-40)
    challengeBtn:addTouchEventListener(r)
    -- floorBg:addChild(challengeBtn)

	self.m_leftBgSpr=floorBg
	self.m_rightBgSpr=rightBgSpr
end

function FuTuView.__requestAllMsg(self)
	local msg=REQ_FIGHTERS_REQUEST()
	msg:setArgs(0)
	_G.Network:send(msg)
end

function FuTuView.msgCallBack(self,_ackMsg)
	local curFloor=self.m_chapPosArray[_ackMsg.chap]
	_ackMsg.curFloor=curFloor

	if not _ackMsg.curCopyId or not _ackMsg.curPos then
		CCMessageBox("后端没发副本数据过来 chap=".._ackMsg.chap,"ERROR")
		return
	elseif self.m_chapPosArray[_ackMsg.chap]==nil then
		CCMessageBox("前端找不到这个章节 chap=".._ackMsg.chap,"ERROR")
		return
	end

	-- local preAckMsg=self.m_curMsgData
	self.m_curMsgData=_ackMsg

	if self.m_rightArray==nil then
		self:__createRightView()
		self:__createLeftView()
	-- else
	end
end

function FuTuView.showMopAction(self,_ackMsg)
	if self.m_mopScheduler then return end

	self.m_myLv=_G.GPropertyProxy:getMainPlay():getLv()
	cc.Director:getInstance():getEventDispatcher():setEnabled(false)

	self.m_curMsgData.times=self.m_curMsgData.times-1
	self.m_curMsgData.times_used=self.m_curMsgData.times_used+1

	if self.m_curMsgData.times<=0 then
    	self.m_rightArray.mopBtn:setEnabled(false)
		self.m_rightArray.mopBtn:setBright(false)
	end
	local szSurplus=string.format("%d次",self.m_curMsgData.times)
	self.m_rightArray.surplusLabel:setString(szSurplus)

	local mopChapPos=1
	local mopCopyPos=1
	local maxChapPos=self.m_curMsgData.curFloor
	local toCopyId=self.m_curMsgData.curCopyId

	local function nScheduler()
		_G.Util:playAudioEffect("Dong")
		if mopChapPos>maxChapPos then
			self:__endMopAction(_ackMsg.goods)
			return
		end
		local chapId=self.m_chapIdArray[mopChapPos]
		local copyArray=self.m_copyChapCnf[chapId].copy_id
		local curCopyId=copyArray[mopCopyPos]
		local isPass=true
		if toCopyId==curCopyId then
			if not self.m_curMsgData.allPass then
				isPass=false
			end
			self:__endMopAction(_ackMsg.goods)
		end
		-- print("nScheduler====>>>",mopChapPos,mopCopyPos,curCopyId,chapId,isPass)
		self:updateRightView(curCopyId,chapId)
		self:updateLeftView(curCopyId,chapId,isPass)
		if #copyArray==mopCopyPos then
			mopChapPos=mopChapPos+1
			mopCopyPos=1
		else
			mopCopyPos=mopCopyPos+1
		end
	end
	self.m_mopScheduler=_G.Scheduler:schedule(nScheduler,0.2)
	nScheduler()
end
function FuTuView.__endMopAction(self,_rewardData)
	cc.Director:getInstance():getEventDispatcher():setEnabled(true)
	self:__removeMopScheduler()

 	if #_rewardData==0 then
 		print("__endMopAction===>>>>> 没有返回扫荡物品数据")
 		return
 	end
 	local goodsId=_rewardData[1].goods_id
 	local goodsCount=_rewardData[1].count
 	local goodsCnf=_G.Cfg.goods[goodsId]
 	if goodsCnf==nil then
 		CCMessageBox("没配置物品goodsId="..goodsId,"ERROR")
 		return
 	end
 	local szMsg=string.format("本次扫荡获得 %s*%d",goodsCnf.name,goodsCount)
 	local command=CErrorBoxCommand(szMsg)
	controller:sendCommand(command)
end
function FuTuView.__removeMopScheduler(self)
	if self.m_mopScheduler then
		_G.Scheduler:unschedule(self.m_mopScheduler)
		self.m_mopScheduler=nil
	end
end

function FuTuView.__getCopyPos(self,_copyId,_chapId)
	local copyArray=self.m_copyChapCnf[_chapId].copy_id
	for i=1,#copyArray do
		if copyArray[i]==_copyId then
			return i
		end
	end
	return 1
end
function FuTuView.__getSomeRewardData(self,_copyId)
	local copyCnf=_G.Cfg.scene_copy[_copyId]
	local reward=copyCnf.reward or {}
	if #reward==0 then
		CCMessageBox("没配置奖励  copyId=".._copyId,"ERROR")
	end
	local goodsId=reward[1][1][1]
	local goodsCount=reward[1][1][2]
	local goodsCnf=_G.Cfg.goods[goodsId]
	if goodsCnf==nil then
		CCMessageBox("没配置物品  goodsId="..goodsId,"ERROR")
	end
	return goodsId,goodsCount,goodsCnf
end

function FuTuView.__getFirstRewardData(self,_copyId)
	print("dsasdasd",_copyId)
	local copyCnf=_G.Cfg.scene_copy[_copyId]
	local reward=copyCnf.first_reward or {}
	if #reward==0 then
		CCMessageBox("没配置奖励  copyId=".._copyId,"ERROR")
	end
	local goodsId=reward[1][1][1]
	local goodsCount=reward[1][1][2]
	local goodsCnf=_G.Cfg.goods[goodsId]
	if goodsCnf==nil then
		CCMessageBox("没配置物品  goodsId="..goodsId,"ERROR")
	end
	return goodsId,goodsCount,goodsCnf
end

function FuTuView.__createRightView(self)
	local midPosX=self.m_rightSize.width*0.5

	local copyId=self.m_curMsgData.curCopyId
	local copyPos=self:__getCopyPos(copyId,self.m_curMsgData.chap)
	local pUtil=_G.Util

	print("__createRightView",_G.Lang.number_Chinese[copyPos])
	local floorLab=pUtil:createBorderLabel(string.format("第%s关",_G.Lang.number_Chinese[copyPos]),24,P_COLOR_BROWN)
	floorLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	floorLab:setPosition(midPosX,self.m_rightSize.height-40)
	self.m_rightBgSpr:addChild(floorLab)

	local tempLabel=pUtil:createLabel("奖励:",20)
	tempLabel:setColor(P_COLOR_BROWN)
	tempLabel:setPosition(45,375)
	self.m_rightBgSpr:addChild(tempLabel)

	-- local goodsId,goodsCount,goodsCnf=self:__getSomeRewardData(copyId)
	-- local firstId,firstCount,firstCnf=self:__getFirstRewardData(copyId)

	local function r(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local tag=sender:getTag()
			-- print("CCCCCCC========>>>>")
			if tag==P_TAG_CHALLENGE then
				if self.m_hasGuide then
					_G.GGuideManager:clearCurGuideNode()
					self.m_hasGuide=nil
				end

				local copyCnf=_G.Cfg.scene_copy[self.m_curMsgData.curCopyId]
				if copyCnf and copyCnf.lv>self.m_myLv then
					local command=CErrorBoxCommand(136)
					_G.controller:sendCommand(command)
					return
				end
				--self:closeWindow()
				local msg=REQ_COPY_NEW_CREAT()
			    msg:setArgs(self.m_curMsgData.curCopyId)
			    _G.Network:send(msg)
			elseif tag==P_TAG_MOP then
				local curTimes=_G.TimeUtil:getTotalSeconds()
				if curTimes-self.m_preMopTimes<3 then return end
				self.m_preMopTimes=curTimes
				local function nFun1()
					-- 模拟
					-- local msg={}
					-- msg.goods={{goods_id=1001,count=600}}
					-- self:showMopAction(msg)

					-- 正式
					local msg=REQ_FIGHTERS_UP_START()
					_G.Network:send(msg)

				end
				local function nFun2()
					self.m_preMopTimes=0
				end

				local szPassNotic,szUseMoney,szReward=self:__getResetData()
				if not szPassNotic or not szUseMoney or not szReward then return end

				local szContent=szPassNotic.."\n"..szUseMoney
				local view=require("mod.general.TipsBox")()
			    local layer=view:create(szContent,nFun1,nFun2)
			    cc.Director:getInstance():getRunningScene():addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC)
		        view:setNoticLabel(szReward)
		        view:setContentPosOff(cc.p(0,20))
			-- else
			-- 	local pos=sender:getWorldPosition()
   --          	local temp=_G.TipsUtil:createById(tag,nil,pos)
	  --           cc.Director:getInstance():getRunningScene():addChild(temp,1000)
	        end
		end
	end

	local framSpr=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
	framSpr:setPosition(midPosX-60,self.m_rightSize.height*0.5+70)
	self.m_rightBgSpr:addChild(framSpr)

	local firstSpr=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
	firstSpr:setPosition(midPosX+60,self.m_rightSize.height*0.5+70)
	self.m_rightBgSpr:addChild(firstSpr)

	-- local framSize=framSpr:getContentSize()

	self:iconBtnReturn(copyId)

	local challengeBtn=gc.CButton:create("general_btn_gold.png")
    challengeBtn:setPosition(midPosX,210)
    challengeBtn:addTouchEventListener(r)
    challengeBtn:setTag(P_TAG_CHALLENGE)
    challengeBtn:setTitleFontName(P_FONT_NAME)
    challengeBtn:setTitleFontSize(24)
    challengeBtn:setTitleText("挑 战")
    self.m_rightBgSpr:addChild(challengeBtn)

    local mopBtn=gc.CButton:create("general_btn_lv.png")
    mopBtn:setPosition(midPosX,68)
    mopBtn:addTouchEventListener(r)
    mopBtn:setTag(P_TAG_MOP)
    mopBtn:setTitleFontName(P_FONT_NAME)
    mopBtn:setTitleFontSize(24)
    mopBtn:setTitleText("扫 荡")
    --mopBtn:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    self.m_rightBgSpr:addChild(mopBtn)

    if self.m_curMsgData.times<=0 then
    	mopBtn:setEnabled(false)
		mopBtn:setBright(false)
	end

	local yuLab=pUtil:createLabel("剩余次数:",20)
	yuLab:setAnchorPoint(cc.p(0,0.5))
	yuLab:setColor(P_COLOR_BROWN)
    yuLab:setPosition(70,125)
    self.m_rightBgSpr:addChild(yuLab)	

    local szSurplus=string.format("%d次",self.m_curMsgData.times)
    local surplusLabel=pUtil:createLabel(szSurplus,20)
    surplusLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    surplusLabel:setAnchorPoint(cc.p(0,0.5))
    surplusLabel:setPosition(70+yuLab:getContentSize().width,125)
    self.m_rightBgSpr:addChild(surplusLabel)

    local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
	local lineSize=lineSpr:getPreferredSize()
	lineSpr:setPreferredSize(cc.size(self.m_rightSize.width-20,lineSize.height))
	lineSpr:setPosition(self.m_rightSize.width*0.5,170)
	self.m_rightBgSpr:addChild(lineSpr)

    self.m_rightArray={}
    self.m_rightArray.iconBtn=iconBtn
    self.m_rightArray.challengeBtn=challengeBtn
    self.m_rightArray.mopBtn=mopBtn
    self.m_rightArray.surplusLabel=surplusLabel

    local guideId=_G.GGuideManager:getCurGuideId()
    if guideId==_G.Const.CONST_NEW_GUIDE_SYS_TOWER then
		self.m_hasGuide=true
		_G.GGuideManager:initGuideView(self.m_rootLayer)
		_G.GGuideManager:registGuideData(1,challengeBtn)
		_G.GGuideManager:runNextStep()
		local command=CGuideNoticHide()
		controller:sendCommand(command)
	end
end

function FuTuView.iconBtnReturn(self,copyId)
	if self.iconBtn~=nil then
		self.iconBtn:removeFromParent(true)
		self.iconBtn=nil
	end
	if self.firstBtn~=nil then
		self.firstBtn:removeFromParent(true)
		self.firstBtn=nil
	end
	local goodsId,goodsCount,goodsCnf=self:__getSomeRewardData(copyId)
	local firstId,firstCount,firstCnf=self:__getFirstRewardData(copyId)

	local function r(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local tag=sender:getTag()
			local pos=sender:getWorldPosition()
        	local temp=_G.TipsUtil:createById(tag,nil,pos)
            cc.Director:getInstance():getRunningScene():addChild(temp,1000)
		end
	end
	
	self.iconBtn=_G.ImageAsyncManager:createGoodsBtn(goodsCnf,r,goodsId,goodsCount)
	self.iconBtn:setPosition(self.m_rightSize.width/2-60,self.m_rightSize.height*0.5+70)
	self.m_rightBgSpr:addChild(self.iconBtn)

	self.firstBtn=_G.ImageAsyncManager:createGoodsBtn(firstCnf,r,firstId,firstCount)
	self.firstBtn:setPosition(self.m_rightSize.width/2+60,self.m_rightSize.height*0.5+70)
	self.m_rightBgSpr:addChild(self.firstBtn)

	local firstSpr=cc.Sprite:createWithSpriteFrameName("futu_first.png")
    firstSpr:setPosition(27,46)
    self.firstBtn:addChild(firstSpr)
end

function FuTuView.updateRightView(self,_copyId,_chapId)
	local goodsId,goodsCount,goodsCnf=self:__getSomeRewardData(_copyId)
	local szReward=string.format("%sX%d",goodsCnf.name,goodsCount)
	local copyPos=self:__getCopyPos(_copyId,_chapId)
	local szFloor=string.format("第%s关",_G.Lang.number_Chinese[copyPos])
	local iconPath=_G.ImageAsyncManager:getIconPath(goodsCnf.icon)

	if self.m_rightArray.iconBtn == nil then return end
	self.m_rightArray.iconBtn:loadTextureNormal(iconPath)
	self.m_rightArray.iconBtn:setTag(goodsId)
end

function FuTuView.__createLeftView(self)
	local copyPos=self.m_curMsgData.curPos
	local chapPos=self.m_curMsgData.curFloor
	local copyArray=self.m_copyChapCnf[self.m_curMsgData.chap].copy_id
	copyPos=self.m_curMsgData.allPass and copyPos+1 or copyPos

	local midPosX=self.m_leftSize.width*0.5
	local floorSpr=self:__createNumSpr(chapPos)
	floorSpr:setPosition(midPosX+30,self.m_leftSize.height-35)
	self.m_leftBgSpr:addChild(floorSpr)

	local function ReturnBtnCallBack(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local tag=sender:getTag()
			print("第几关",tag,copyPos)
			local copyId=copyArray[tag]
			self:iconBtnReturn(copyId)
			for i=1,5 do
				if i==tag then
					self.passSprBg[i]:setVisible(true)
					if copyPos~=tag then
						self.m_rightArray.challengeBtn:setEnabled(false)
						self.m_rightArray.challengeBtn:setBright(false)
					else
						self.m_rightArray.challengeBtn:setEnabled(true)
						self.m_rightArray.challengeBtn:setBright(true)
					end
				else
					self.passSprBg[i]:setVisible(false)
				end
			end
			
		end
	end

	local oneHeight=70
	local passSprArray={}
	-- local passLineArray={}
	local passNumArray={}
	self.passSprBg={}
	for i=1,5 do
		local nn=i%2
		local posX=(nn-0.5)*290+midPosX
		local posY=95+(i-1)*oneHeight

		self.passSprBg[i]=cc.Sprite:createWithSpriteFrameName("futu_select.png")
		self.passSprBg[i]:setPosition(posX,posY)
		if i~=copyPos then
			self.passSprBg[i]:setVisible(false)
		end
		self.m_leftBgSpr:addChild(self.passSprBg[i])

		passSprArray[i]=gc.CButton:create("futu_icon.png")
		passSprArray[i]:addTouchEventListener(ReturnBtnCallBack)
    	passSprArray[i]:setTag(i)
		passSprArray[i]:setPosition(posX,posY)
		passSprArray[i]:setGray()
		self.m_leftBgSpr:addChild(passSprArray[i],5)

		local sprSize=passSprArray[i]:getContentSize()
		local szImg=string.format("futu_pass_%d.png",i)
		local passNode,passArray=self:__createNumSpr(i,true)
		passNode:setPosition(sprSize.width*0.5,5)
		passSprArray[i]:addChild(passNode)
		passNumArray[i]=passArray

		-- if i>1 then
			-- passLineArray[i]=gc.GraySprite:createWithSpriteFrameName("futu_line.png")
			-- passLineArray[i]:setPosition(midPosX,posY-oneHeight*0.5)
			-- self.m_leftBgSpr:addChild(passLineArray[i])
			-- if nn==0 then
				-- passLineArray[i]:setScaleX(-1)
			-- end
		-- end

		print("copyPos--->>>>",copyPos)
		if i>=copyPos then
			local copyId=copyArray[i]
			local copyCnf=_G.Cfg.scene_copy[copyId]
			-- print("TTTTTTTTTTTTTT=======>>>>>>",copyCnf.lv,self.m_myLv)
			if copyCnf and copyCnf.lv>self.m_myLv then
				-- 不能打
				passSprArray[i]:setGray()
				-- for tt=1,#passArray do
				-- 	passArray[tt]:setGray()
				-- end
			end
			-- if passLineArray[i] then
				-- passLineArray[i]:setGray()
			-- end
		elseif i<copyPos then
			self:__showPassIconSpr(passSprArray[i])
		end
	end

	self.m_leftArray={}
	self.m_leftArray.curFloor=chapPos
	self.m_leftArray.floorSpr=floorSpr
	self.m_leftArray.passSprArray=passSprArray
	-- self.m_leftArray.passLineArray=passLineArray
	self.m_leftArray.passNumArray=passNumArray
	if copyPos>5 then copyPos=5 end
	self.m_leftArray.passSprArray[copyPos]:setDefault()
	-- self.willSpr = self.m_leftArray.passSprArray[copyPos]
end
function FuTuView.updateLeftView(self,_copyId,_chapId,_isPass)
	local chapPos=self.m_chapPosArray[_chapId] or 0
	if self.m_leftArray.curFloor~=chapPos then
		local prePos=cc.p(self.m_leftArray.floorSpr:getPosition())
		local floorSpr=self:__createNumSpr(chapPos)
		floorSpr:setPosition(prePos)
		self.m_leftBgSpr:addChild(floorSpr)
		self.m_leftArray.floorSpr:removeFromParent(true)
		self.m_leftArray.floorSpr=floorSpr
		self.m_leftArray.curFloor=chapPos
	end

	local copyArray=self.m_copyChapCnf[_chapId].copy_id
	local findCurCopyPos=nil
	for i=1,#copyArray do
		local copyId=copyArray[i]
		local copyCnf=_G.Cfg.scene_copy[copyId]
		local isHide=false
		if copyCnf and copyCnf.lv>self.m_myLv then
			isHide=true
		end
		if copyId==_copyId then
			findCurCopyPos=i
			if _isPass then
				self:__handlePassCell(i,true,false)
			else
				self:__handlePassCell(i,false,isHide)
			end
		elseif findCurCopyPos~=nil then
			if _isPass and i==findCurCopyPos+1 then
				self:__handlePassCell(i,false,isHide)
			else
				self:__handlePassCell(i,false,true)
			end
		else
			self:__handlePassCell(i,true,false)
		end
	end
	print("self.willSpr--->",findCurCopyPos,_isPass)
end
function FuTuView.__handlePassCell(self,_pos,_isPass,_isHide)
	print("__handlePassCell========>>>>",_pos,_isPass,_isHide)
	local passSpr=self.m_leftArray.passSprArray[_pos]
	-- local lineSpr=self.m_leftArray.passLineArray[_pos]
	local numSprArray=self.m_leftArray.passNumArray[_pos]

	if lineSpr then
		if _isPass then
			lineSpr:setDefault()
		else
			lineSpr:setGray()
		end
	end
	if _isPass then
		self:__showPassIconSpr(passSpr)
	else
		self:__hidePassIconSpr(passSpr)
	end

	if _isHide then
		passSpr:setGray()
		
		-- for i=1,#numSprArray do
		-- 	numSprArray[i]:setGray()
		-- end
	else
		passSpr:setDefault()
		
		-- for i=1,#numSprArray do
		-- 	numSprArray[i]:setDefault()
		-- end
	end
end
function FuTuView.__showPassIconSpr(self,_passSpr)
	local passIconSpr=_passSpr:getChildByTag(166)
	if passIconSpr~=nil then
		passIconSpr:setVisible(true)
	else
		_passSpr:setDefault()
		local sprSize=_passSpr:getContentSize()
		passIconSpr=cc.Sprite:createWithSpriteFrameName("futu_pass.png")
		passIconSpr:setPosition(sprSize.width*0.5,sprSize.height*0.5)
		passIconSpr:setTag(166)
		_passSpr:addChild(passIconSpr)
	end
end
function FuTuView.__hidePassIconSpr(self,_passSpr)
	local passIconSpr=_passSpr:getChildByTag(166)
	if passIconSpr~=nil then
		passIconSpr:setVisible(false)
	end
end

function FuTuView.__createNumSpr(self,_num,_isPassNum)
	print("__createNumSpr===>>>",_num,_isPassNum)
	local szNum=tostring(_num)
	local numLen=string.len(szNum)
	local offX,tempSpr
	if _isPassNum then
		offX=3
		tempSpr=gc.GraySprite:createWithSpriteFrameName("futu_pass_bg.png")
	else
		offX=13
		tempSpr=ccui.Scale9Sprite:createWithSpriteFrameName("futu_floor_bg.png",cc.rect(47,0,1,1))
	end
	local tempArray={}
	local tempCount=1
	tempArray[tempCount]=tempSpr

	local nWidth=0
	local leftPoint=cc.p(0,0.5)
	local tempNode=cc.Node:create()

	if _isPassNum then
		for i=1,numLen do
			local num=string.sub(szNum,i,i)
			if tonumber(num)==0 then break end
			if (tonumber(num)~=1 and numLen>1) or numLen==i then
				-- local szImg=string.format("futu_num_%d.png",num)
				-- local numSpr=gc.GraySprite:createWithSpriteFrameName(szImg)
				-- local tempSize=numSpr:getContentSize()
				-- numSpr:setAnchorPoint(leftPoint)
				-- numSpr:setPosition(nWidth,0)
				-- tempNode:addChild(numSpr)

				local NumLab=_G.Util:createLabel(string.format("第%s关",_G.Lang.number_Chinese[tonumber(num)]),20)
				NumLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
				NumLab:setPosition(15,0)
				tempNode:addChild(NumLab)

				tempCount=tempCount+1
				tempArray[tempCount]=NumLab
				nWidth=nWidth+25
			end

			-- if i==1 and numLen>1 then
			-- -- 	local tenNumSpr=gc.GraySprite:createWithSpriteFrameName("futu_num_10.png")
			-- -- 	local tenSize=tenNumSpr:getContentSize()
			-- -- 	tenNumSpr:setAnchorPoint(leftPoint)
			-- -- 	tenNumSpr:setPosition(nWidth,0)
			-- -- 	tempNode:addChild(tenNumSpr)

			-- 	local tenNumLab=_G.Util:createLabel(string.format("第%s关",_G.Lang.number_Chinese[tonumber(num)]),20)
			-- 	tenNumLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
			-- 	tenNumLab:setPosition(0,0)
			-- 	tempNode:addChild(tenNumLab)

			-- 	tempCount=tempCount+1
			-- 	tempArray[tempCount]=tenNumLab
			-- 	nWidth=nWidth+25
			-- end
			
		end
	else
		local NumLab=_G.Util:createLabel(string.format("第%s层",_G.Lang.number_Chinese[tonumber(szNum)]),24)
		NumLab:setColor(P_COLOR_GOLD)
		NumLab:setPosition(10,10)
		tempNode:addChild(NumLab)

		tempCount=tempCount+1
		tempArray[tempCount]=NumLab
	end
	local sprSize=tempSpr:getContentSize()
	if not _isPassNum and numLen>1 and _num~=10 then
		sprSize=cc.size(sprSize.width+20,sprSize.height)
		tempSpr:setPreferredSize(sprSize)
	end

	tempNode:setPosition(sprSize.width*0.5-nWidth*0.5-offX,sprSize.height*0.5)
	tempSpr:addChild(tempNode)

	return tempSpr,tempArray
end

function FuTuView.closeWindow(self)
	if self.m_rootLayer==nil then return end
	self.m_rootLayer=nil

	cc.Director:getInstance():popScene()
	self:destroy()
	self:__removeMopScheduler()

	if self.m_hasGuide then
		local command=CGuideNoticShow()
		controller:sendCommand(command)
	end
end

function FuTuView.__getResetData(self)
	local maxChapPos=self.m_curMsgData.curFloor
	local toCopyId=self.m_curMsgData.curCopyId
	local passCopyPos=0
	local passCopyId=toCopyId

	local rewardArray={}
	for i=1,maxChapPos do
		local copyArray=self.m_copyChapCnf[self.m_chapIdArray[i]].copy_id
		for nn=1,#copyArray do
			local copyId=copyArray[nn]
			if i==maxChapPos and copyId==toCopyId then
				break
			end
			passCopyPos=nn
			passCopyId=copyId
			local goodsId,goodsCount,goodsCnf=self:__getSomeRewardData(copyId)
			if rewardArray[goodsId]==nil then
				rewardArray[goodsId]={}
				rewardArray[goodsId].count=0
				rewardArray[goodsId].goodsCnf=goodsCnf
			end
			rewardArray[goodsId].count=rewardArray[goodsId].count+goodsCount
		end
	end

	if passCopyPos==0 then
		local command=CErrorBoxCommand(31630)
		controller:sendCommand(command)
		return
	end
	local myChapPos=maxChapPos
	if passCopyPos==5 then
		myChapPos=myChapPos-1
	end

	local goodsId,goodsData=next(rewardArray)
	local szPassNotic=string.format("今日最高通关:第%s层第%d关",_G.Lang.number_Chinese[myChapPos],passCopyPos)
	local szReward=string.format("可获得%s*%d",goodsData.goodsCnf.name,goodsData.count)

	local copyCnf=_G.Cfg.scene_copy[passCopyId]
	local resetMoney=copyCnf.mop_rmb
	local nnnnnTimes=self.m_curMsgData.times_used
	local szUseMoney
	resetMoney=nnnnnTimes==0 and 0 or resetMoney
	-- resetMoney=resetMoney*nnnnnTimes
	if resetMoney==0 then
		szUseMoney="本次扫荡免费,确定扫荡吗?"
	else
		szUseMoney=string.format("花费%d%s进行扫荡?",resetMoney,_G.Lang.Currency_Type[3])
	end
	return szPassNotic,szUseMoney,szReward
end

return FuTuView

