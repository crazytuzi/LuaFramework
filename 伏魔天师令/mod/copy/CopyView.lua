local P_WINSIZE=cc.Director:getInstance():getWinSize()
local ZORDER_FIRST_VIEW=10
local ZORDER_SECOND_VIEW=20
local ZORDER_THIRD_VIEW=30

local CopyView=classGc(view,function(self,_chapId)
	self.m_viewSize=cc.size(854,640)
	self.m_chapCopyMsgArray={}
	self.m_defaultChapId=_chapId

	self.m_mediator=require("mod.copy.CopyViewMediator")(self)
	self.m_myProperty=_G.GPropertyProxy:getMainPlay()

	-- 初始化新手指引参数
	local guideId=_G.GGuideManager:getCurGuideId()
	local guideMapCopyId,guideCopyId
    if guideId==_G.Const.CONST_NEW_GUIDE_SYS_COPY_FIRST then
    	guideMapCopyId=10011
    	guideCopyId=10011
    elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_COPY_KUNNAN then
    	guideMapCopyId=10011
    	guideCopyId=20011
    elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_COPY_REWARD1 then
    	self.m_guide_chapid=10100
    	self.m_guide_reward_idx=1
    elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_COPY_REWARD2 then
    	self.m_guide_chapid=10200
    	self.m_guide_reward_idx=1
    elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_COPY_REWARD3 then
    	self.m_guide_chapid=10300
    	self.m_guide_reward_idx=1
    elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_COPY_REWARD4 then
    	self.m_guide_chapid=10400
    	self.m_guide_reward_idx=1
    elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_COPY_REWARD5 then
    	self.m_guide_chapid=10500
    	self.m_guide_reward_idx=1
    elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_COPY_REWARD6 then
    	self.m_guide_chapid=10600
    	self.m_guide_reward_idx=1
    end

    if guideMapCopyId and guideCopyId then
    	local copyCnf=_G.GCopyProxy:getCopyNodeByCopyId(guideMapCopyId)
    	if copyCnf then
    		self.m_guide_map_copyid=guideMapCopyId --副本ID（必须是普通副本,在章节副本列表界面上对应副本按钮）
    		self.m_guide_copyid=guideCopyId        --副本ID (普通、困难、地狱的副本ID,用在副本信息界面的不同挑战难度)
    		self.m_guide_chapid=copyCnf.belong_id  --章节ID
    		self.m_defaultChapId=nil
    	end
    end

    if not self.m_guide_map_copyid and not self.m_guide_chapid then
	    self.m_mainCopyInfo=self.m_myProperty:getTaskInfo()
		if self.m_mainCopyInfo then
			local haveCount,allCount=self.m_myProperty:getTaskCount()
			if haveCount>=allCount then
				self.m_myProperty:setTaskInfo()
				self.m_mainCopyInfo=nil
			else
				self.m_copyMopCount=allCount-haveCount
				if self.m_mainCopyInfo.copyId then
					local sceneCopyCnf=_G.GCopyProxy:getCopyNodeByCopyId(self.m_mainCopyInfo.copyId)
					if sceneCopyCnf then
						if self.m_mainCopyInfo.type==_G.Const.CONST_TASK_TRACE_MAIN_TASK then
							self.m_defaultChapId=sceneCopyCnf.belong_id
						else
							self.m_copyMopId=self.m_mainCopyInfo.copyId
							self.m_defaultChapId=nil
						end
					end
				end
			end
		end
	end

	if self.m_guide_chapid then
		self.m_defaultChapId=nil
	end
end)

local GUIDE_COPY_ID=10021
function CopyView.create(self)
	local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rootLayer=cc.Layer:create()
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	local isFirstEnter=true
	local function onNodeEvent(event)
        if "enter"==event then
        	if isFirstEnter then
        		isFirstEnter=false

				local msg=REQ_COPY_IS_UP()
				_G.Network:send(msg)

				_G.Util:showLoadCir()
			end
        end
    end
    tempScene:registerScriptHandler(onNodeEvent)

	return tempScene
end

function CopyView.__initView(self)
	self:__addCloseBtn()	

	if self.m_copyMopId then
		local msg=REQ_COPY_COPY_OPEN()
		msg:setArgs(self.m_copyMopId)
		_G.Network:send(msg)
	elseif self.m_defaultChapId then
		local chapIdx=self:__getChpIdxByChapId(self.m_defaultChapId)
		if chapIdx then
			self:__requestMsg()
			self:__requestChapData(chapIdx)
		else
			self.m_defaultChapId=nil
			self:__requestMsg()
		end
	else
    	self:__requestMsg()
    end
end
function CopyView.__addCloseBtn(self)
	local function c(sender,eventType)
    	if eventType == ccui.TouchEventType.ended then
            _G.Util:playAudioEffect("ui_sys_clickoff")
            self:closeWindow()
    	end
	end
	local closeBtn=gc.CButton:create("general_view_close.png")
    closeBtn:setAnchorPoint(cc.p(1,1))
    closeBtn:setPosition(P_WINSIZE.width+13,P_WINSIZE.height+20)
    closeBtn:addTouchEventListener(c)
    closeBtn:enableSound()
    closeBtn:ignoreContentAdaptWithSize(false)
    closeBtn:setContentSize(cc.size(120,120))
    self.m_rootLayer:addChild(closeBtn,11)

    -- local titleSpr=cc.Sprite:createWithSpriteFrameName("general_view_closebg.png")
    -- titleSpr:setAnchorPoint(cc.p(1,1))
    -- titleSpr:setPosition(P_WINSIZE.width+2,P_WINSIZE.height)
    -- self.m_rootLayer:addChild(titleSpr,10)
end

function CopyView.ACK_COPY_COPY_OPEN_REPLY(self,_ackMsg)
	if _ackMsg.flag==0 then
		-- local command=CErrorBoxCommand("副本未开启,请先通关前面副本")
		-- _G.controller:sendCommand(command)
		self:selectCopy(_ackMsg.copy_id)
		self.m_copyMopId=_ackMsg.copy_id
	else
		self:selectCopy(self.m_copyMopId)
	end
end

function CopyView.__requestMsg(self,_type)
	local msg=REQ_COPY_REQUEST_ALL()
	_G.Network:send(msg)
end

function CopyView.copyChapBack(self,_chapArray)
	if #_chapArray==0 then
		CCMessageBox("no data come?","plz find sever")
		return
	end

	-- for i=1,5 do
	-- 	_chapArray[#_chapArray+1]=_chapArray[#_chapArray]
	-- end

	local curChapIdx=#_chapArray
	self.m_maxChapIdx=curChapIdx
	local nextChapId
	local lastChapCnf=_G.GCopyProxy:getScetionNodeById(_G.Const.CONST_COPY_TYPE_NORMAL,_chapArray[#_chapArray].chap_id)
	if lastChapCnf and lastChapCnf.next_chap_id~=0 then
		nextChapId=lastChapCnf.next_chap_id
	end

	if nextChapId then
		_chapArray[#_chapArray+1]={
			chap_id=nextChapId,
			isNoOpen=true,
			star=0
		}
	end

	self.m_chapTotalArray=_chapArray
	if self.m_copyMopId then
		local copyCnf=_G.GCopyProxy:getCopyNodeByCopyId(self.m_copyMopId)
		local chapIdx=self:__getChpIdxByChapId(copyCnf.belong_id)
		self:__requestChapData(chapIdx)
	elseif self.m_defaultChapId then
		-- for i=1,_chapArray do
		-- 	if _chapArray[i].chap_id==self.m_defaultChapId then
		-- end
		self.m_defaultChapId=nil
	else
		self:initChapView(curChapIdx)
	end
end

local P_CHAP_BTN_INTERVAL=P_WINSIZE.width/3
local P_CHAP_BTN_SMALLSCALE=0.85
local P_CHAP_BTN_BIGSCALE=1
local P_CHAP_BTN_SCALESPEED=(P_CHAP_BTN_BIGSCALE-P_CHAP_BTN_SMALLSCALE)/P_CHAP_BTN_INTERVAL
local P_CHAP_BTN_SIZE=cc.size(382,525)
local P_CHAP_BG_SIZE=cc.size(285,P_CHAP_BTN_SIZE.height)
function CopyView.initChapView(self,_idx)
	if self.m_chapScrollView then return end

	self.m_chapContainer=cc.Node:create()
	self.m_chapContainer:setPosition(P_WINSIZE.width*0.5,P_WINSIZE.height*0.5)
	self.m_rootLayer:addChild(self.m_chapContainer,10)

	-- local function c(sender,eventType)
 --    	if eventType == ccui.TouchEventType.ended then
 --            _G.Util:playAudioEffect("ui_sys_clickoff")
 --            self:closeWindow()
 --    	end
	-- end
	-- local closeBtn=gc.CButton:create("general_view_close.png")
 --    closeBtn:setAnchorPoint(cc.p(1,1))
 --    closeBtn:setPosition(P_WINSIZE.width*0.5+2,P_WINSIZE.height*0.5)
 --    closeBtn:addTouchEventListener(c)
 --    closeBtn:enableSound()
 --    self.m_chapContainer:addChild(closeBtn,20)

    local tempHeight=74
    local mainBg=ccui.Scale9Sprite:createWithSpriteFrameName("newcopy_frame_4.png")
    mainBg:setContentSize(cc.size(P_WINSIZE.width,P_WINSIZE.height-tempHeight))
    mainBg:setPosition(0,-tempHeight*0.5)
    self.m_chapContainer:addChild(mainBg)

    local titleFrameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("newcopy_frame_1.png")
    titleFrameSpr:setContentSize(cc.size(P_WINSIZE.width,tempHeight))
    titleFrameSpr:setAnchorPoint(cc.p(0.5,1))
    titleFrameSpr:setPosition(0,P_WINSIZE.height*0.5)
    self.m_chapContainer:addChild(titleFrameSpr,10)

	-- local middleShadeSpr=cc.Sprite:createWithSpriteFrameName("general_view_shade_middle.png")
	-- middleShadeSpr:setPosition(0,-35)
	-- self.m_chapContainer:addChild(middleShadeSpr)

	local viewSize=cc.size(P_WINSIZE.width,600)
	self.m_chapScrollView=cc.ScrollView:create()
    self.m_chapScrollView:setPosition(-viewSize.width*0.5,-320)
    self.m_chapScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self.m_chapScrollView:setViewSize(viewSize)
    self.m_chapScrollView:setBounceable(false)
    self.m_chapScrollView:setTouchEnabled(true)
    self.m_chapScrollView:setDelegate()
    self.m_chapContainer:addChild(self.m_chapScrollView)

    local touchOff=nil
    local function c(sender,eventType)
    	if eventType==ccui.TouchEventType.began then
			touchOff=self.m_chapScrollView:getContentOffset()
			return true
    	elseif eventType==ccui.TouchEventType.ended then
    		local offsetPos=self.m_chapScrollView:getContentOffset()
    		local subOffX=math.abs(offsetPos.x-touchOff.x)
    		if subOffX>10 then return end

    		_G.Util:playAudioEffect("ui_sys_click")

    		local idx=sender:getTag()
    		if self.m_inMiddleChapIdx~=idx then
    			self:adjustChapBtnPos(idx)
    			return
    		end

    		if subOffX>0 then
    			self:adjustChapBtnPos(self.m_inMiddleChapIdx,true)
    		end

    		self:__requestChapData(idx)
    		-- self:showCopyArrayEffect(idx)
    	end
    end
    self.m_chapButtonArray={}
    
    local initChapIdx=_idx
    local guideChapIdx=nil
    for i=1,#self.m_chapTotalArray do
    	local chapId=self.m_chapTotalArray[i].chap_id
    	local chapCnf=_G.GCopyProxy:getScetionNodeById(_G.Const.CONST_COPY_TYPE_NORMAL,chapId)

    	local btnSize=P_CHAP_BTN_SIZE
    	local tempBtn=ccui.Widget:create()
		tempBtn:setContentSize(btnSize)
		tempBtn:setPosition((i+0.5)*P_CHAP_BTN_INTERVAL,viewSize.height*0.5-15)
		tempBtn:addTouchEventListener(c)
		tempBtn:setScale(P_CHAP_BTN_SMALLSCALE)
		tempBtn:setTag(i)
		tempBtn:enableSound()
		self.m_chapScrollView:addChild(tempBtn)

		local szImg,nameFontSize
		-- if self.m_chapTotalArray[i].isNoOpen then
		-- 	szImg="newcopy_chap_bg_1.png"
		-- 	nameFontSize=34
		-- else
			szImg="newcopy_chap_bg_1.png"
			nameFontSize=24
		-- end

    	local tempBg=ccui.Scale9Sprite:createWithSpriteFrameName(szImg)
    	tempBg:setPosition(btnSize.width*0.5,btnSize.height*0.5)
    	tempBg:setTag(1688)
    	tempBg:setContentSize(P_CHAP_BG_SIZE)
    	tempBtn:addChild(tempBg,-10)

    	local szName=string.format("第%s章",_G.Lang.number_Chinese[i])
		local chapIdxLabel=_G.Util:createLabel(szName,nameFontSize)
		chapIdxLabel:setDimensions(25,0)
		chapIdxLabel:setAnchorPoint(cc.p(0,1))
		chapIdxLabel:setPosition(70,btnSize.height-35)
		tempBtn:addChild(chapIdxLabel)

		local idxSize=chapIdxLabel:getContentSize()
	    local chapNameLabel=_G.Util:createLabel(chapCnf.chap_name,nameFontSize)
	    chapNameLabel:setDimensions(25,0)
	    chapNameLabel:setAnchorPoint(cc.p(0,1))
	    chapNameLabel:setPosition(70,btnSize.height-idxSize.height-40)
	    tempBtn:addChild(chapNameLabel)

	    if self.m_chapTotalArray[i].isNoOpen then
	    	-- chapNameLabel:setPosition(btnSize.width*0.5,btnSize.height*0.5)

	    	local szDec=string.format("%d级开启",chapCnf.chap_lv)
	    	local tempLabel=_G.Util:createBorderLabel(szDec,24)
	    	tempLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
	    	tempLabel:setPosition(btnSize.width*0.5,90)
	    	tempBtn:addChild(tempLabel)
	    else
	    	tempBtn:setTouchEnabled(true)
	    	tempBtn:setSwallowTouches(false)

			local starSpr=cc.Sprite:createWithSpriteFrameName("newcopy_star.png")
			starSpr:setPosition(btnSize.width*0.5-22,75)
			tempBtn:addChild(starSpr)

			local szStarCount=string.format("%d/%d",self.m_chapTotalArray[i].star,#chapCnf.copy_id*3)
			local starCountLabel=_G.Util:createLabel(szStarCount,24)
			starCountLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
			starCountLabel:setAnchorPoint(cc.p(0,0.5))
			starCountLabel:setPosition(btnSize.width*0.5-5,75)
			tempBtn:addChild(starCountLabel)
	    end

	    if self.m_chapTotalArray[i].state==1 then
	    	local boxSpr=cc.Sprite:createWithSpriteFrameName("newcopy_copybox.png")
	    	boxSpr:setPosition(80,75)
	    	boxSpr:setTag(887)
	    	tempBtn:addChild(boxSpr)
	    end

	    if self.m_guide_chapid==chapId then
	    	guideChapIdx=i
	    end

	    self.m_chapButtonArray[i]=tempBtn
    end

    local addNum=self.m_chapTotalArray[#self.m_chapTotalArray].isNoOpen and 1 or 2
    local contentWidth=(#self.m_chapTotalArray+addNum)*P_CHAP_BTN_INTERVAL
    if contentWidth<viewSize.width then
    	contentWidth=viewSize.width
    end
    self.m_chapScrollView:setContentSize(cc.size(contentWidth,viewSize.height))
    self.m_chapScrollView:setContentOffset(cc.p(-P_CHAP_BTN_INTERVAL*(_idx-1),0))

    local function onTouchBegan()
    	return true
    end
    local function onTouchEnded()
    	if self.m_chapScrollView:isTouchEnabled() then
    		self:adjustChapBtnPos()
    	end
    end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listerner:setSwallowTouches(false)

    local tempContainer=self.m_chapScrollView:getContainer()
    tempContainer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,tempContainer)

    local function nFun1()
    	self:adjustChapBtnScale()
	end

    self.m_chapScrollView:registerScriptHandler(nFun1,cc.SCROLLVIEW_SCRIPT_SCROLL)
    
    initChapIdx=guideChapIdx or initChapIdx
    self.m_inMiddleChapIdx=initChapIdx
    self:adjustChapBtnPos(self.m_inMiddleChapIdx,true)
    self:adjustChapBtnScale()
    self:resetChapHightLine()

    if guideChapIdx then
    	self.m_chapScrollView:setTouchEnabled(false)

    	_G.GGuideManager:initGuideView(self.m_rootLayer)
    	_G.GGuideManager:registGuideData(1,self.m_chapButtonArray[guideChapIdx])
    	_G.GGuideManager:runNextStep()
    	self.m_guide_chap_idx=guideChapIdx

    	for i=1,#self.m_chapButtonArray do
    		if i~=guideChapIdx then
    			self.m_chapButtonArray[i]:setTouchEnabled(false)
    		end
    	end
    end
end
function CopyView.adjustChapBtnScale(self)
	local offsetPos=self.m_chapScrollView:getContentOffset()
	local midPosX=-offsetPos.x+P_WINSIZE.width*0.5

	if self.m_prePosX==midPosX then return end

	self.m_prePosX=midPosX

	for i=1,#self.m_chapButtonArray do
		local tX=(i+0.5)*P_CHAP_BTN_INTERVAL
		local subX=midPosX-tX
		local tempScale=math.abs(subX)*P_CHAP_BTN_SCALESPEED
		local tempBtn=self.m_chapButtonArray[i]
		if tempScale>P_CHAP_BTN_BIGSCALE then
			tempBtn:setVisible(false)
		else
			tempScale=1-tempScale
			tempBtn:setVisible(true)
			tempBtn:setScale(tempScale)

			local tempSize=tempBtn:getContentSize()
			local tempX=tempBtn:getPositionX()
			local isVis=true
			if (tempX+tempSize.width*0.5*tempScale+offsetPos.x)<0 then
				isVis=false
			elseif (tempX-tempSize.width*0.5*tempScale+offsetPos.x)>P_WINSIZE.width then
				isVis=false
			end

			-- if not self.m_chapTotalArray[i].isNoOpen then
				local tempSpine=tempBtn:getChildByTag(1689)
				if isVis then
					if not tempSpine then
						local chapCnf=_G.GCopyProxy:getScetionNodeById(_G.Const.CONST_COPY_TYPE_NORMAL,self.m_chapTotalArray[i].chap_id)
						if chapCnf.boss and chapCnf.boss~=0 then
						    -- local szName=string.format("spine/%d",chapCnf.boss)
						    -- tempSpine=_G.SpineManager.createSpine(szName,0.5)
						    -- if tempSpine then
						    -- 	local btnSize=tempBtn:getContentSize()
						    -- 	tempSpine:setPosition(btnSize.width*0.5,20)
						    -- 	tempSpine:setAnimation(0,"idle",true)
						    -- 	tempSpine:setTag(1689)
						    -- 	tempBtn:addChild(tempSpine,-10)

						    -- 	if self.m_chapTotalArray[i].isNoOpen then
						    -- 		tempSpine:setColor(cc.c4b(60,60,60,150))
						    -- 	end
						    -- end

						    local btnSize=tempBtn:getContentSize()
						    local szImg=string.format("painting/a%d.png",chapCnf.boss)

						    if _G.FilesUtil:check(szImg)==false then
						    	local tempNode=cc.Node:create()
						    	tempNode:setTag(1689)
						    	tempBtn:addChild(tempNode,-20)
						    else
						    	local tempSpr=_G.ImageAsyncManager:createNormalSpr(szImg)
							    tempSpr:setPosition(btnSize.width*0.5,btnSize.height*0.5)
							    tempSpr:setTag(1689)
							    tempBtn:addChild(tempSpr,-20)

							    if self.m_chapTotalArray[i].isNoOpen then
							    	tempSpr:setGray()
							    end
						    end
						end
					end
				end
			-- end
		end
	end
end
function CopyView.adjustChapBtnPos(self,_adjustChapIdx,_isNoAction)
	local offsetPos=self.m_chapScrollView:getContentOffset()
	local midPosX=-offsetPos.x+P_WINSIZE.width*0.5
	local chapIdx=_adjustChapIdx
	if not chapIdx then
		local minWid=100000
		for i=1,#self.m_chapButtonArray do
			local tX=(i+0.5)*P_CHAP_BTN_INTERVAL
			local subX=math.abs(tX-midPosX)
			if subX<minWid then
				chapIdx=i
				minWid=subX
			end
		end
	end

	self.m_inMiddleChapIdx=chapIdx
	local moveOffX=-((chapIdx+0.5)*P_CHAP_BTN_INTERVAL-P_WINSIZE.width*0.5)
	if _isNoAction then
		self.m_chapScrollView:setContentOffset(cc.p(moveOffX,0))
		self:adjustChapBtnScale()
		return
	end

	local moveTime=math.abs(moveOffX-offsetPos.x)/1500
	local function nFun()
		self.m_chapScrollView:setTouchEnabled(true)
		self:adjustChapBtnScale()
		self:removeChapScrollViewSchudler()
		self:resetChapHightLine()
	end
	self.m_chapScrollView:setTouchEnabled(false)
	self.m_chapScrollView:getContainer():stopAllActions()
	self.m_chapScrollView:getContainer():runAction(cc.Sequence:create(cc.MoveTo:create(moveTime,cc.p(moveOffX,0)),cc.CallFunc:create(nFun)))
	self:addChapScrollViewSchudler()
end
function CopyView.addChapScrollViewSchudler(self)
	if self.m_chapScoSchedule then return end

	local function nFun()
		self:adjustChapBtnScale()
	end
	self.m_chapScoSchedule=_G.Scheduler:schedule(nFun,0.1)
end
function CopyView.removeChapScrollViewSchudler(self)
	if self.m_chapScoSchedule then
		_G.Scheduler:unschedule(self.m_chapScoSchedule)
		self.m_chapScoSchedule=nil
	end
end
function CopyView.resetChapHightLine(self)
	for i=1,#self.m_chapButtonArray do
		local tempBtn=self.m_chapButtonArray[i]
		local bgSpr=tempBtn:getChildByTag(1688)
		if bgSpr then
			local tempMsg=self.m_chapTotalArray[i]
			if not tempMsg.isNoOpen then
				if i==self.m_inMiddleChapIdx then
					local tempFrame=cc.SpriteFrameCache:getInstance():getSpriteFrame("newcopy_chap_bg_2.png")
					bgSpr:setSpriteFrame(tempFrame,cc.rect(0,104,1,1))
					bgSpr:setContentSize(P_CHAP_BG_SIZE)
				else
					local tempFrame=cc.SpriteFrameCache:getInstance():getSpriteFrame("newcopy_chap_bg_1.png")
					bgSpr:setSpriteFrame(tempFrame,cc.rect(0,104,1,1))
					bgSpr:setContentSize(P_CHAP_BG_SIZE)
				end
				
			end
		end
	end
end

function CopyView.__getChapIdByChapIdx(self,_chapIdx)
	local chapCnfArray=_G.Cfg.copy_chap[_G.Const.CONST_COPY_TYPE_NORMAL]
	for k,v in pairs(chapCnfArray) do
		if v.paixu==_chapIdx then
			return k
		end
	end
end
function CopyView.__getChpIdxByChapId(self,_chapId)
	local chapCnf=_G.GCopyProxy:getScetionNodeById(_G.Const.CONST_COPY_TYPE_NORMAL,_chapId)
	return chapCnf.paixu
end

function CopyView.__requestChapData(self,_chapIdx)
	if self.m_chapCopyMsgArray[_chapIdx] then
		if self.m_chapArrayContianer then
			self:__turnChapView(_chapIdx)
		else
			self:__createCopyArrayView(_chapIdx)
		end
	else
		--print("__requestChapData===>>>",debug.traceback())
		local chapId=self:__getChapIdByChapIdx(_chapIdx)
		local msg=REQ_COPY_REQUEST()
		msg:setArgs(chapId)
		_G.Network:send(msg)
	end
end

function CopyView.copyChapMsgBack(self,_chapId,_chapMsg)
	local chapIdx=self:__getChpIdxByChapId(_chapId)
	self.m_chapCopyMsgArray[chapIdx]=_chapMsg

	if not self.m_chapArrayContianer then
		self:__createCopyArrayView(chapIdx)
	else
		self:__turnChapView(chapIdx)
	end
end
function CopyView.updateCopyMsg(self,_ackMsg)
	local copyId=_ackMsg.copy_one_data[1].copy_id
	local copyCnf=_G.GCopyProxy:getCopyNodeByCopyId(copyId)
	local chapIdx=self:__getChpIdxByChapId(copyCnf.belong_id)

	local chapMsg=self.m_chapCopyMsgArray[chapIdx]
	if chapMsg then
		for i=1,#chapMsg do
			if chapMsg[i].copy_one_data[1].copy_id==copyId then
				chapMsg[i]=_ackMsg
				return
			end
		end
	end
end

function CopyView.__removeCopyArrayView(self)
	if self.m_chapArrayContianer then
		self.m_chapArrayContianer:removeFromParent(true)
		self.m_chapArrayContianer=nil
	end
	self.m_curChapContainer=nil
	self.m_nextChapContainer=nil
	self.m_showingChapIdx=nil
	self.m_chapArrayLeftBtn=nil
	self.m_chapArrayRightBtn=nil
end
function CopyView.__createCopyArrayView(self,_chapIdx)
	if self.m_chapContainer then
		self.m_chapContainer:setVisible(false)
	end
	self:__removeCopyArrayView()

	local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

	self.m_chapArrayContianer=cc.Layer:create()
	self.m_chapArrayContianer:setPosition(P_WINSIZE.width*0.5,0)
	self.m_chapArrayContianer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_chapArrayContianer)
	self.m_rootLayer:addChild(self.m_chapArrayContianer,20)

	local function c(sender,eventType)
    	if eventType == ccui.TouchEventType.ended then
    		local nTag=sender:getTag()
    		if nTag==1 then
    			if self.m_guide_wait_next then
    				self.m_guide_wait_next=nil
    				_G.GGuideManager:runThisStep(1)
    			end
	            self:__removeCopyArrayView()
	            if not self.m_chapContainer then
	            	self:initChapView(self.m_maxChapIdx)
	            else
	            	self.m_chapContainer:setVisible(true)
	            end
	        elseif nTag==2 then
	        	local turnIdx=self.m_showingChapIdx-1
	        	if turnIdx<=0 then return end
	        	self:__requestChapData(turnIdx)
	        elseif nTag==3 then
	        	local turnIdx=self.m_showingChapIdx+1
	        	if turnIdx>self.m_maxChapIdx then return end
	        	self:__requestChapData(turnIdx)
	        end
    	end
	end
	local closeBtn=gc.CButton:create("general_btn_back.png")
    closeBtn:setPosition(P_WINSIZE.width*0.5-40,600)
    closeBtn:addTouchEventListener(c)
    closeBtn:setTag(1)
    self.m_chapArrayContianer:addChild(closeBtn,20)

    local leftBtn=gc.CButton:create("general_fanye.png")
    leftBtn:setPosition(-P_WINSIZE.width*0.5+100,320)
    leftBtn:addTouchEventListener(c)
    leftBtn:setTag(2)
    self.m_chapArrayContianer:addChild(leftBtn,20)
    self.m_chapArrayLeftBtn=leftBtn

    local rightBtn=gc.CButton:create("general_fanye.png")
    rightBtn:setPosition(P_WINSIZE.width*0.5-100,320)
    rightBtn:addTouchEventListener(c)
    rightBtn:setTag(3)
    rightBtn:setButtonScale(-1)
    self.m_chapArrayContianer:addChild(rightBtn,20)
    self.m_chapArrayRightBtn=rightBtn

	self.m_curChapContainer=self:__createSingleChapView(_chapIdx)
	self.m_chapArrayContianer:addChild(self.m_curChapContainer)

	self.m_showingChapIdx=_chapIdx
	self:__resetChapDirBtn()

	if self.m_guide_wait_next then
		_G.GGuideManager:runNextStep()
		leftBtn:setTouchEnabled(false)
		rightBtn:setTouchEnabled(false)
	end
end
function CopyView.__resetChapDirBtn(self)
	if self.m_showingChapIdx and self.m_chapArrayRightBtn then
		if self.m_showingChapIdx<=1 then
			self.m_chapArrayLeftBtn:setVisible(false)
		else
			self.m_chapArrayLeftBtn:setVisible(true)
		end
		if self.m_showingChapIdx>=self.m_maxChapIdx then
			self.m_chapArrayRightBtn:setVisible(false)
		else
			self.m_chapArrayRightBtn:setVisible(true)
		end
	end
end
function CopyView.__turnChapView(self,_chapIdx)
	if not self.m_chapArrayContianer or self.m_nextChapContainer then return end
	if self.m_showingChapIdx==_chapIdx then return end

	local tempPos
	if self.m_showingChapIdx>_chapIdx then
		tempPos=cc.p(-P_WINSIZE.width-300,0)
	else
		tempPos=cc.p(P_WINSIZE.width+300,0)
	end

	self.m_nextChapContainer=self:__createSingleChapView(_chapIdx)
	self.m_nextChapContainer:setPosition(tempPos)
	self.m_chapArrayContianer:addChild(self.m_nextChapContainer)

	local function nFun()
		if self.m_curChapContainer then
			self.m_curChapContainer:removeFromParent(true)
			self.m_curChapContainer=nil
		end
		self.m_curChapContainer=self.m_nextChapContainer
		self.m_nextChapContainer=nil

		self.m_showingChapIdx=_chapIdx
		self:__resetChapDirBtn()
	end
	local act=cc.EaseBackOut:create(cc.MoveTo:create(0.5,cc.p(0,0)))
	-- self.m_nextChapContainer:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,cc.p(0,0)),cc.CallFunc:create(nFun)))
	self.m_nextChapContainer:runAction(cc.Sequence:create(act,cc.CallFunc:create(nFun)))
end

function CopyView.__createSingleChapView(self,_chapIdx)
	local tempContainer=cc.Node:create()

	local chapId=self:__getChapIdByChapIdx(_chapIdx)
	local chapCnf=_G.GCopyProxy:getScetionNodeById(_G.Const.CONST_COPY_TYPE_NORMAL,chapId)
	local copyMsg=self.m_chapCopyMsgArray[_chapIdx]
	local suCaiArray=chapCnf.sucai

	_G.SysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)
	local tempBg=cc.Sprite:create(string.format("ui/bg/copy_bg_%d.jpg",chapCnf.beijing))
	tempBg:setPosition(0,320)
	tempContainer:addChild(tempBg,-10)
	_G.SysInfo:resetTextureFormat()

	local titleFrameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("newcopy_frame_3.png")
	titleFrameSpr:setContentSize(cc.size(P_WINSIZE.width,80))
	titleFrameSpr:setAnchorPoint(cc.p(0.5,1))
	titleFrameSpr:setPosition(0,640)
	tempContainer:addChild(titleFrameSpr,10)

	local chapNameBg=cc.Sprite:createWithSpriteFrameName("newcopy_chap_0.png")
	chapNameBg:setAnchorPoint(cc.p(0.5,1))
	chapNameBg:setPosition(-P_WINSIZE.width*0.5+70,550)
	tempContainer:addChild(chapNameBg,5)

	local bgSize=chapNameBg:getContentSize()

	local nColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKRED)
	local szName=string.format("第%s章",_G.Lang.number_Chinese[_chapIdx])
	local chapIdxLabel=_G.Util:createLabel(szName,22)
	chapIdxLabel:setDimensions(22,0)
	chapIdxLabel:setAnchorPoint(cc.p(0,1))
	chapIdxLabel:setPosition(bgSize.width+2,bgSize.height-5)
	chapIdxLabel:setColor(nColor)
	chapNameBg:addChild(chapIdxLabel)

	local idxSize=chapIdxLabel:getContentSize()
	local chapNameLabel=_G.Util:createLabel(chapCnf.chap_name,32)
	chapNameLabel:setDimensions(22,0)
	chapNameLabel:setPosition(bgSize.width*0.5,bgSize.height*0.5)
	chapNameLabel:setColor(nColor)
	chapNameBg:addChild(chapNameLabel)

	local function c(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if self.m_nextChapContainer then return end

			local tag=sender:getTag()
            local curMsg=copyMsg[tag].copy_one_data[1]
			local copyId=curMsg.copy_id

			local guideCopyId=nil
			if self.m_guide_wait_next then
				if self.m_guide_map_copyid then
					if self.m_guide_map_copyid==copyId then
						guideCopyId=self.m_guide_copyid
					else
						_G.GGuideManager:hideGuideByStep(2)
					end
				elseif self.m_guide_wait_reward then
					_G.GGuideManager:hideGuideByStep(2)
				end
			end

            self:selectCopy(copyId,copyMsg[tag],nil,guideCopyId)
        end
    end

    local isNextCopy=true
    local passStarCount=0
	for i=1,#copyMsg do
		local msgData=copyMsg[i]
		local curInfoData=suCaiArray[i]
		local curMsg=msgData.copy_one_data[1]
		local copyId=curMsg.copy_id
		local copyCnf=_G.GCopyProxy:getCopyNodeByCopyId(copyId)

		local isNoPass=curMsg.pass~=1
		local sprNum=curInfoData[3]
		if sprNum~=101 and sprNum~=102 and sprNum~=103 then
			sprNum=101
		end
		local szImg
		if isNoPass then
			szImg=string.format("newcopy_copybtn_%d_gray.png",sprNum)
		else
			szImg=string.format("newcopy_copybtn_%d.png",sprNum)
		end

		local copyBtn=gc.CButton:create(szImg)
	    copyBtn:setPosition(curInfoData[1],curInfoData[2])
	    copyBtn:addTouchEventListener(c)
	    copyBtn:setTag(i)
	    tempContainer:addChild(copyBtn,2)

	    local btnSize=copyBtn:getContentSize()
	    local addHeight=0
	    if sprNum~=103 then
	    	local nScale=sprNum==101 and 2 or 1.5
	    	btnSize=cc.size(btnSize.width*nScale,btnSize.height*nScale)
	    	copyBtn:ignoreContentAdaptWithSize(false)
    		copyBtn:setContentSize(btnSize)
    		addHeight=btnSize.height*(0.5-1/nScale*0.5)
	    end

	    local nameLabel=_G.Util:createBorderLabel(copyCnf.copy_name,20)
	    nameLabel:setPosition(btnSize.width*0.5,-12+addHeight)
	    copyBtn:addChild(nameLabel)

	    local starCount=0
	    for j=1,#msgData.copy_one_data do
	    	if msgData.copy_one_data[j].pass==1 then
	    		starCount=starCount+1
	    		passStarCount=passStarCount+1
	    	end
	    end
	    for j=1,3 do
	    	local tempStarSpr=gc.GraySprite:createWithSpriteFrameName("newcopy_star.png")
	    	tempStarSpr:setPosition(btnSize.width*0.5+(j-2)*30,-35+addHeight)
	    	copyBtn:addChild(tempStarSpr)
	    	if starCount<j then
	    		tempStarSpr:setGray()
	    	end
	    end
	    
	    if isNoPass then
	    	local copylv=_G.Cfg.scene_copy[copyId].lv
	    	if self.m_myProperty:getLv()>=copylv then
	    		if not isNextCopy then
		   --  		local nonoLab1=_G.Util:createBorderLabel("通关前一",18)
					-- nonoLab1:setPosition(btnSize.width/2-6,btnSize.height/2+20)
					-- nonoLab1:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
					-- copyBtn:addChild(nonoLab1,20)
					-- local nonoLab2=_G.Util:createBorderLabel("副本开启",18)
					-- nonoLab2:setPosition(btnSize.width/2-6,btnSize.height/2)
					-- nonoLab2:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
					-- copyBtn:addChild(nonoLab2,20)
					copyBtn:setEnabled(false)
					-- copyBtn:setGray()
				else
					isNextCopy=false

					local tempSpr=cc.Sprite:createWithSpriteFrameName("newcopy_arrow.png")
					-- tempSpr:setScale(2,-2)
					tempSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(0,20)),cc.MoveBy:create(0.5,cc.p(0,-20)))))
					tempSpr:setPosition(curInfoData[1],curInfoData[2]+btnSize.height*0.5+15)
					tempContainer:addChild(tempSpr,3)
				end
			else
				-- local nonoLab=_G.Util:createBorderLabel(string.format("%d级开启",copylv),18)
				-- nonoLab:setPosition(btnSize.width/2,btnSize.height/2+7)
				-- nonoLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
				-- copyBtn:addChild(nonoLab,20)
				copyBtn:setEnabled(false)
				-- copyBtn:setGray()
	    	end
	    end

	    -- 连接点
	    if i>1 then
	    	local preInfoData=suCaiArray[i-1]
	    	local subX=curInfoData[1]-preInfoData[1]
	    	local subY=curInfoData[2]-preInfoData[2]
	    	local tempDis=math.sqrt(subX*subX+subY*subY)
	    	local minCount=math.floor(tempDis/30)
	    	minCount=minCount<2 and 1 or minCount-1

	    	for tt=1,minCount do
	    		local tempScale=tt/(minCount+1)
	    		local posX=preInfoData[1]+subX*tempScale
	    		local posY=preInfoData[2]+subY*tempScale
	    		local pointSpr=gc.GraySprite:createWithSpriteFrameName("newcopy_point.png")
	    		pointSpr:setPosition(posX,posY)
	    		tempContainer:addChild(pointSpr,-1)

	    		if not copyBtn:isEnabled() then
	    			pointSpr:setGray()
	    		end
	    	end
	    end

	    if self.m_guide_chap_idx then
	    	if self.m_guide_map_copyid==copyId then
	    		_G.GGuideManager:registGuideData(2,copyBtn)
	    		self.m_guide_wait_next=true
	    	end
	    end
	end

	local totalStarCount=#chapCnf.copy_id*3
	local barBgSpr=cc.Sprite:createWithSpriteFrameName("newcopy_bar_1.png")
	barBgSpr:setPosition(0,45)
	tempContainer:addChild(barBgSpr,20)

	-- passStarCount=18
	local tempSize=barBgSpr:getContentSize()
	local tempSpr=cc.Sprite:createWithSpriteFrameName("newcopy_bar_2.png")
	local progressSpr=cc.ProgressTimer:create(tempSpr)
    progressSpr:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progressSpr:setBarChangeRate(cc.p(1,0))
    progressSpr:setMidpoint(cc.p(0,0.5))
    progressSpr:setPosition(tempSize.width*0.5+8,tempSize.height*0.5)
    progressSpr:setPercentage(passStarCount/totalStarCount*100)
    barBgSpr:addChild(progressSpr)

    local tempSpr=cc.Sprite:createWithSpriteFrameName("newcopy_star_bg.png")
    tempSpr:setPosition(0,tempSize.height*0.5)
    barBgSpr:addChild(tempSpr)

    local starSpr=cc.Sprite:createWithSpriteFrameName("newcopy_star.png")
    starSpr:setPosition(32,42)
    tempSpr:addChild(starSpr)

    local starCountLabel=_G.Util:createBorderLabel(string.format("%d/%d",passStarCount,totalStarCount),20)
    starCountLabel:setPosition(32,18)
    starCountLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
    tempSpr:addChild(starCountLabel)

    local function c(sender,eventType)
    	if eventType==ccui.TouchEventType.ended then
    		local nTag=sender:getTag()
    		local rewardData=chapCnf.chap_reward[nTag]

    		local needStar=rewardData[1]
    		if not copyMsg.box_idx[nTag] and passStarCount>=needStar then
    			local msg=REQ_COPY_CHAP_REWARD()
    			msg:setArgs(_G.Const.CONST_COPY_TYPE_NORMAL,chapId,nTag)
    			_G.Network:send(msg)
    		else
    			local goodsId=rewardData[2]
    			local goodsCount=rewardData[3]
    			local nPos=sender:getWorldPosition()
    			local tempNode=_G.TipsUtil:createById(goodsId,nil,nPos,0)

    			local goodsCnf=_G.Cfg.goods[goodsId]
    			if goodsCnf.type~=_G.Const.CONST_GOODS_EQUIP
					and goodsCnf.type~=_G.Const.CONST_GOODS_WEAPON
					and goodsCnf.type~=_G.Const.CONST_GOODS_MAGIC then

					local lablen=string.len(goodsCnf.name)
					local tempLabel=_G.Util:createLabel(string.format("*%d",goodsCount),20)
					tempLabel:setAnchorPoint(0,0.5) 
					tempLabel:setPosition(110+lablen*7,-50)
					tempNode:addChild(tempLabel)
				end
			    cc.Director:getInstance():getRunningScene():addChild(tempNode,1000)
    		end

    		if self.m_guide_wait_reward then
    			self.m_guide_wait_reward=nil
    			self.m_guide_wait_next=nil
    			self.m_guide_chapid=nil
    			_G.GGuideManager:removeCurGuideNode()
    		end
    	end
    end

    self.m_curRewardBtnArray={}
    for i=1,#chapCnf.chap_reward do
    	local isRewardGet=copyMsg.box_idx[i]
    	local szImg=string.format("%d.png",chapCnf.chap_reward[i][2])
    	local isOpen=false
    	if isRewardGet then
    		isOpen=true
    	else
    		isOpen=false
    	end

    	local rewardData=chapCnf.chap_reward[i]
    	local iPer=rewardData[1]/totalStarCount
    	local boxBtn=gc.CButton:create(szImg)
    	boxBtn:setPosition(tempSize.width*iPer+45,tempSize.height)
    	boxBtn:addTouchEventListener(c)
    	boxBtn:setTag(i)
    	boxBtn:setBright(isOpen)
    	tempSpr:addChild(boxBtn)

    	local starSpr=cc.Sprite:createWithSpriteFrameName("newcopy_star.png")
    	starSpr:setPosition(45,60)
    	boxBtn:addChild(starSpr)

    	local numLabel=_G.Util:createBorderLabel(tostring(rewardData[1]),20)
    	numLabel:setAnchorPoint(cc.p(1,0.5))
    	numLabel:setPosition(33,60)
    	numLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
    	boxBtn:addChild(numLabel)

    	if not isRewardGet then
    		self.m_curRewardBtnArray[i]=boxBtn

    		if passStarCount>=rewardData[1] then
	    		local btnSize=boxBtn:getContentSize()
			    local tempSpr=cc.Sprite:createWithSpriteFrameName("main_icon_effect.png")
			    tempSpr:setPosition(btnSize.width*0.5,btnSize.height*0.5)
			    tempSpr:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.35,90)))
			    tempSpr:setTag(2001)
			    boxBtn:addChild(tempSpr,-1)

			    local spine=_G.SpineManager.createSpine("spine/6048")
				spine:setPosition(cc.p(btnSize.width*0.5,btnSize.height*0.5))
			  	spine:setAnimation(0,"idle",true)
			  	spine:setTag(2002)
			  	boxBtn:addChild(spine)
			  	boxBtn:setBright(true)
			end
    	end
	    if self.m_guide_chap_idx and self.m_guide_reward_idx and self.m_guide_reward_idx==i then
	    	_G.GGuideManager:registGuideData(2,boxBtn)
	    	self.m_guide_wait_next=true
	    	self.m_guide_wait_reward=true
	    end
    end

	return tempContainer
end
function CopyView.getRewardBack(self,_ackMsg)
	local chapId=_ackMsg.chap_id
	local chapIdx=self:__getChpIdxByChapId(chapId)
	local copyMsg=self.m_chapCopyMsgArray[chapIdx]
	if copyMsg then
		copyMsg.box_idx[_ackMsg.star]=true
		local chapCnf=_G.GCopyProxy:getScetionNodeById(_G.Const.CONST_COPY_TYPE_NORMAL,chapId)
		if self.m_chapArrayContianer then
			if self.m_showingChapIdx==chapIdx and self.m_curRewardBtnArray and not self.m_nextChapContainer then
				local rewardBtn=self.m_curRewardBtnArray[_ackMsg.star]
				if rewardBtn then
					rewardBtn:loadTextures(string.format("%d.png",chapCnf.chap_reward[_ackMsg.star][2]))
					rewardBtn:removeChildByTag(2001)
					rewardBtn:removeChildByTag(2002)
				end
			end
		end

		local passStarCount=self.m_chapTotalArray[chapIdx].star
		local hasOrtherReward=false
		for i=1,#chapCnf.chap_reward do
			local isRewardGet=copyMsg.box_idx[i]
			local rewardData=chapCnf.chap_reward[i]
			if not isRewardGet and passStarCount>=rewardData[1] then
				hasOrtherReward=true
				break
			end
		end
		if not hasOrtherReward then
			self:__removeChapRewardBoxSpr(chapIdx)
		end
	end
end
function CopyView.__removeChapRewardBoxSpr(self,_chapIdx)
	if not self.m_chapButtonArray then return end
	
	local tempBtn=self.m_chapButtonArray[_chapIdx]
	if tempBtn then
		tempBtn:removeChildByTag(887)
	end
end

function CopyView.copyInfoViewClose(self)
	-- self.m_copyContainerDown:setVisible(true)
	-- self.m_copyContainerUp:setVisible(true)
	-- self.m_chapContainer:setVisible(true)
	self.m_copyInfoView=nil

	if self.m_mainCopyInfo and self.m_mainCopyInfo.type==_G.Const.CONST_TASK_TRACE_MATERIAL then
		self:closeWindow()
		return
	end

	if self.m_copyMopId and not self.m_chapArrayContianer then
		-- self:__requestChapData(chapCnf.paixu)
		-- self.m_wantTo
		self:__requestMsg()
	elseif self.m_chapArrayContianer then
		self.m_chapArrayContianer:setVisible(true)
	end

	if self.m_guide_wait_next then
		_G.GGuideManager:showGuideByStep(2)
	end
end

function CopyView.selectCopy(self,_copyId,_copysMsg,_offLineData,_guideCopyId)
	if self.m_copyInfoView then return end

	local tempView=require("mod.copy.CopyInfoView")(_copyId,_copysMsg,_offLineData,_guideCopyId)
	local tempLayer=tempView:create()
	self.m_rootLayer:addChild(tempLayer,100)

	self.m_copyInfoView=tempView

	if self.m_chapArrayContianer then
		self.m_chapArrayContianer:setVisible(false)
	end
end

function CopyView.closeWindow(self)
	if self.m_rootLayer==nil then return end
    self.m_rootLayer=nil
    
	self.m_myProperty:setTaskInfo()
	cc.Director:getInstance():popScene()
	self:destroy()
	self:removeChapScrollViewSchudler()
	_G.g_Stage:autoSearchRoad()

	self=nil
end

function CopyView.getCurCanMopTimes( self, _copyid )
    local energyHas = self.m_myProperty:getAllEnergy()
    local useEnergy = self:getCurUseEnergy(_copyid)
    if useEnergy==0 then return 100 end
    return math.floor(energyHas/useEnergy)
end

function CopyView.getCurUseEnergy( self, _copyId)
    local sceneCopyNode = _G.GCopyProxy:getCopyNodeByCopyId( _copyId )
    return sceneCopyNode.use_energy
end

function CopyView.showOffLineMop(self,_ackMsg)
	if _ackMsg.copy_id==0 then
		self.m_myProperty.mopType=0
		local command=CMainUiCommand(CMainUiCommand.MOPTYPE)
	    command.mopType=self.m_myProperty.mopType
	    controller:sendCommand(command)

	    self:__initView()
		return
	end

	self.m_guide_map_copyid=nil
	self.m_guide_copyid=nil
	self.m_guide_chapid=nil

	self:__addCloseBtn()

	self.m_copyMopId=_ackMsg.copy_id
	self:selectCopy(self.m_copyMopId,nil,_ackMsg)

	gcprint("离线挂机中.....")
end

function CopyView.__showBuyEnergy(self)
	local msg=REQ_ROLE_ASK_BUY_ENERGY()
	_G.Network:send(msg)
end

return CopyView