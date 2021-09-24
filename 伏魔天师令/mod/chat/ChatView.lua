-- 是否支持语音
local IS_SUPPORT_VOICE=_G.SysInfo:isYayaImSupport()

local ChatView = classGc(view,function (self,_chatData)
	self.m_chatData=_chatData
	self.m_winSize=cc.Director:getInstance():getWinSize()
	self.m_viewSize=cc.size(854,640)
	self.m_myUid=_G.GPropertyProxy:getMainPlay():getUid()
	self.m_myLv=_G.GPropertyProxy:getMainPlay():getLv()

	self.m_lastRecordTimes=0

	if not _G.g_Stage.m_isCity then
		_G.SysInfo:setGameIntervalLow()
	end

	if _G.g_SmallChatView then
		_G.g_SmallChatView:hideChatbtnAction()
	end
end)

local FOUTSIZE		= 20
local P_TAG_FACE 	= 10
local P_TAG_SEND 	= 20 
local P_TAG_SAY     = 30
local P_TAG_VOICE   = 40 

local P_VERTICAL_SPACE=0
local P_MAX_COUNT=50

local P_CHANNEL_ALL = _G.Const.CONST_CHAT_ALL
local P_CHANNEL_WORLD = _G.Const.CONST_CHAT_WORLD
local P_CHANNEL_CLAN = _G.Const.CONST_CHAT_CLAN
local P_CHANNEL_TEAM = _G.Const.CONST_CHAT_TEAM
local P_CHANNEL_PM = _G.Const.CONST_CHAT_PM
local P_CHANNEL_SYSTEM = _G.Const.CONST_CHAT_SYSTEM

local P_SIZE_SYACHANNEL=cc.size(85,250)
local P_SIZE_FRIEND=cc.size(145,P_SIZE_SYACHANNEL.height)

function ChatView.create(self)
	self.m_generalView=require("mod.general.TabUpView")()
	self.m_lpRootLayer=self.m_generalView:create("聊 天",true)

	local __rectContainsPoint=cc.rectContainsPoint
	local function onTouchBegan(touch,event)
		if self.m_insertScheduler then return true end

		local touchPoint=touch:getStartLocation()
		if not __rectContainsPoint(self.m_viewRect,touchPoint) then
			return true
		end
		for richNode,array in pairs(self.m_touchNodeArray) do
			for node,chatMsg in pairs(array) do
				local arPoint=node:getAnchorPoint()
				local nodeSize=node:getContentSize()
				local forNodePos=node:convertToNodeSpaceAR(touchPoint)
				local touchRect=cc.rect(-arPoint.x*nodeSize.width,-arPoint.y*nodeSize.height,nodeSize.width,nodeSize.height)

				if __rectContainsPoint(touchRect,forNodePos) then
					-- print("点中！！！！！！！")
					self:__touchEnvetHandle(chatMsg,node)
					node:stopAllActions()
					node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1,1.1),cc.ScaleTo:create(0.1,1,1)))
					return true
				end
			end
		end

		if not IS_SUPPORT_VOICE then return true end

		for i=1,#self.m_voiceNodeArray do
			local node=self.m_voiceNodeArray[i].node
			local chatMsg=self.m_voiceNodeArray[i].msg

			local arPoint=node:getAnchorPoint()
			local nodeSize=node:getContentSize()
			local forNodePos=node:convertToNodeSpaceAR(touchPoint)
			local touchRect=cc.rect(-arPoint.x*nodeSize.width,-arPoint.y*nodeSize.height,nodeSize.width,nodeSize.height)
			
			if __rectContainsPoint(touchRect,forNodePos) then
				-- print("点中！！！！！！！")
				self:__playVoiceHandle(i)
				node:stopAllActions()
				node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1,1.1),cc.ScaleTo:create(0.1,1,1)))
				return true
			end
		end
		return true
	end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)
    self.m_lpRootLayer:getEventDispatcher():removeEventListenersForTarget(self.m_lpRootLayer)
    self.m_lpRootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_lpRootLayer)

	self:__initView()
	self:__initData()
	self:__initAutoScheduler()
	return self.m_lpRootLayer
end

function ChatView.__initView( self )
	self.m_lpMainNode=cc.Node:create()
	self.m_lpMainNode:setPosition(self.m_winSize.width/2,self.m_winSize.height/2-30)
	self.m_lpRootLayer:addChild(self.m_lpMainNode,11)

	local secondSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png",cc.rect(24,24,1,1))
    secondSpr:setPreferredSize(cc.size(845,437))
    secondSpr:setPosition(0,5)
    self.m_lpMainNode:addChild(secondSpr)

	local function operateButton( sender,eventType )
		if eventType==ccui.TouchEventType.ended then
			local nTag=sender:getTag()
			if nTag==P_TAG_FACE then
				self:__showFaceTips()
			elseif nTag==P_TAG_SEND then
				self:__sendMsg()
			elseif nTag==P_TAG_SAY then
				self:__createChannelTips()
			elseif nTag==P_TAG_VOICE then
				print("停止录音1")
				self:__recordVoiceStop(false)
			end
		elseif eventType==ccui.TouchEventType.began then
			local nTag=sender:getTag()
			if nTag==P_TAG_VOICE then
				self:__recordVoiceStart()
			end
		elseif eventType==ccui.TouchEventType.canceled then
			local nTag=sender:getTag()
			if nTag==P_TAG_VOICE then
				print("停止录音2")
				self:__recordVoiceStop(true)
			end
		end
	end

    local channelButton=gc.CButton:create("general_chat_tab.png")
    local cBtnSize=channelButton:getContentSize()
    channelButton:setPosition(-376,-242)
    channelButton:addTouchEventListener(operateButton)
    channelButton:setTag(P_TAG_SAY)
    channelButton:ignoreContentAdaptWithSize(false)
    channelButton:setContentSize(cc.size(cBtnSize.width+40,cBtnSize.height+30))
    self.m_lpMainNode:addChild(channelButton)
    self.m_sayChannelBtn=channelButton

    local hColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_XSTROKE)
    self.m_syaChannel=P_CHANNEL_WORLD
	self.m_lpChannelLabel=_G.Util:createBorderLabel(_G.Lang.Chat_Channel_Name[P_CHANNEL_WORLD],20)
	self.m_lpChannelLabel:setPosition(channelButton:getContentSize().width/2,channelButton:getContentSize().height/2)
	-- self.m_lpChannelLabel:setColor(_G.ColorUtil:getRGB(_G.Const.kChatChannelColor[self.m_syaChannel]))
	channelButton:addChild(self.m_lpChannelLabel)

	local faceBtnRes="chat_01.png"
	local faceButton=gc.CButton:create(faceBtnRes)
	local faceSize=faceButton:getContentSize()
	faceButton:setPosition(260,-242)
	faceButton:addTouchEventListener(operateButton)
	faceButton:setButtonScale(1.2)
	faceButton:setTag(P_TAG_FACE)
	faceButton:ignoreContentAdaptWithSize(false)
	faceButton:setContentSize(cc.size(faceSize.width+15,faceSize.height+15))
	self.m_lpMainNode:addChild(faceButton)

	local inputSize=cc.size(550,40)
	if IS_SUPPORT_VOICE then
		local voiceBtnRes="general_voice.png"
		local voiceButton=gc.CButton:create(voiceBtnRes)
		local voiceSize=voiceButton:getContentSize()
		voiceButton:setPosition(200,-242)
		voiceButton:addTouchEventListener(operateButton)
		voiceButton:setTag(P_TAG_VOICE)
		voiceButton:ignoreContentAdaptWithSize(false)
		voiceButton:setContentSize(cc.size(voiceSize.width+15,voiceSize.height+15))
		self.m_lpMainNode:addChild(voiceButton)

		self.m_voiceButton=voiceButton

		inputSize=cc.size(480,40)
	end

	local contentSpri=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
	self.m_lpTextField=ccui.EditBox:create(inputSize,contentSpri)
    self.m_lpTextField:setPosition(-325+inputSize.width*0.5,-242)
    self.m_lpTextField:setFont(_G.FontName.Heiti,FOUTSIZE)
    self.m_lpTextField:setPlaceholderFont(_G.FontName.Heiti,FOUTSIZE)
    self.m_lpTextField:setPlaceHolder("请输入聊天内容")
    self.m_lpTextField:setMaxLength(90)
    self.m_lpTextField:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.m_lpMainNode:addChild(self.m_lpTextField)

	
	local sendBtnRes = "general_btn_gold.png"	
	local sendButton=gc.CButton:create(sendBtnRes)
	sendButton:setPosition(355,-242)
	sendButton:setTitleText("发 送")
	sendButton:setTitleFontSize(FOUTSIZE+5)
	sendButton:setTitleFontName(_G.FontName.Heiti)
	sendButton:addTouchEventListener(operateButton)
	sendButton:setTag(P_TAG_SEND)
	sendButton:setButtonScale(0.85)
	self.m_lpMainNode:addChild(sendButton)

	local function nCloseFun()
		self:closeWindow()
	end
	local function nTabCall(tag)
		self:__chuangChannelTab(tag)
	end
	self.m_generalView:addCloseFun(nCloseFun)
	self.m_generalView:addTabFun(nTabCall)

	self.m_generalView:addTabButton(_G.Lang.Chat_Channel_Name[P_CHANNEL_ALL],P_CHANNEL_ALL)
	self.m_generalView:addTabButton(_G.Lang.Chat_Channel_Name[P_CHANNEL_WORLD],P_CHANNEL_WORLD)
	self.m_generalView:addTabButton(_G.Lang.Chat_Channel_Name[P_CHANNEL_CLAN],P_CHANNEL_CLAN)
	self.m_generalView:addTabButton(_G.Lang.Chat_Channel_Name[P_CHANNEL_PM],P_CHANNEL_PM)
	-- self.m_generalView:addTabButton(_G.Lang.Chat_Channel_Name[P_CHANNEL_SYSTEM],P_CHANNEL_SYSTEM)
	self.m_generalView:addTabButton(_G.Lang.Chat_Channel_Name[P_CHANNEL_TEAM],P_CHANNEL_TEAM)
	
	self:__createContentView()

	self.m_mediator=require("mod.chat.ChatViewMediator")(self)
end

function ChatView.__initData(self)
	self.m_sendGoodsList={}
	self.m_sendGoodsIndex=0

	if self.m_chatData~=nil then
		if self.m_chatData.dataType==_G.Const.kChatDataTypeSL then
			self:__privateChat(self.m_chatData.chatId,self.m_chatData.chatName)
			self:__chuangChannelTab(P_CHANNEL_PM)
			return
		elseif self.m_chatData.dataType==_G.Const.kChatDataTypeWP then
			self.m_sendGoodsIndex=self.m_sendGoodsIndex+1

			local goodsMsg=REQ_CHAT_MSG_GOODS_XXX()
			goodsMsg:setArgs(self.m_chatData.type,self.m_chatData.id,self.m_chatData.idx)
			self.m_sendGoodsList[self.m_sendGoodsIndex]=goodsMsg

			local tempStr=string.format("<#G%d%s>",self.m_sendGoodsIndex,self.m_chatData.name)
			self:__addInputContent(tempStr)

			self.m_isHasGoodsMsg=true
		elseif self.m_chatData.dataType==_G.Const.kChatDataTypeTeam then
			self:__chuangChannelTab(P_CHANNEL_TEAM)
			self.m_isInTeamView=true
			return
		end
	end
	self:__chuangChannelTab(P_CHANNEL_ALL)
end

function ChatView.__removeAutoScheduler(self)
	if self.m_autoScheduler then
		_G.Scheduler:unschedule(self.m_autoScheduler)
		self.m_autoScheduler=nil
	end
end
function ChatView.__initAutoScheduler(self)
	local function nFun()
		local curCount=#self.m_lpRichTextArray
		if curCount<P_MAX_COUNT then
			local tempOff=self.m_lpScrollView:getContentOffset()
			local maxOffY=self.m_viewSize.height-self.m_curHeight+self.m_removeHeight
			if math.abs(tempOff.y-maxOffY)<5 then
				local curChannelData=_G.GChatProxy:getChatMsgArray(self.m_curChannel)
				local subCount=#curChannelData-curCount
				if subCount>0 then
					local idx=subCount>5 and subCount-5+1 or 1
					for i=subCount,idx,-1 do
						self:insertRichTextArrayByEnd(curChannelData[i],true)
					end
				end
			end
		end
	end
	self.m_autoScheduler=_G.Scheduler:schedule(nFun,1)
end

function ChatView.__createContentView(self,dataList)
	local cSize=cc.size(830,70)
	-- local contentSpri=ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
	-- contentSpri:setPreferredSize(cSize)
	-- contentSpri:setPosition(0,-182)
	-- self.m_lpMainNode:addChild(contentSpri,-1)

	self.m_viewSize=cc.size(cSize.width,430)
	self.m_richSize=cc.size(self.m_viewSize.width-10,0)

	local tempPos=cc.p(-self.m_viewSize.width*0.5-5,-245+cSize.height*0.5)
	self.m_lpScrollView=cc.ScrollView:create()
	self.m_lpScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	self.m_lpScrollView:setViewSize(self.m_viewSize)
	self.m_lpScrollView:setTouchEnabled(true)
	self.m_lpScrollView:setBounceable(false)
	self.m_lpScrollView:setPosition(tempPos)
	self.m_lpMainNode:addChild(self.m_lpScrollView)

	local worldPos=self.m_lpScrollView:convertToWorldSpace(cc.p(0,0))
	self.m_viewRect=cc.rect(worldPos.x,worldPos.y,self.m_viewSize.width,self.m_viewSize.height)

	self.m_lpScrollBar=require("mod.general.ScrollBar")(self.m_lpScrollView)
	self.m_lpScrollBar:setPosOff(cc.p(5,0))
	-- self.m_lpScrollBar:setMoveHeightOff(0)
end

function ChatView.__chuangChannelTab( self, _tag )
	print("ChatView --- tag --->",_tag)

	if _tag~=P_CHANNEL_ALL and _tag~=P_CHANNEL_SYSTEM then
		self:__chuangSyaChannel(_tag)
	end

	if self.m_curChannel==_tag then return end

	self.m_curChannel=_tag
	self:clearRichText()

	local chatMsgArray=_G.GChatProxy:getChatMsgArray(_tag)
	self:__insertChatMsgArray(chatMsgArray)

	self.m_generalView:selectTagByTag(_tag)
end

function ChatView.clearRichText(self)
	if self.m_lpScrollContainer~=nil then
		-- self.m_lpScrollContainer:removeFromParent(true)
		-- self.m_lpScrollContainer=nil
		self:__releaseScrollContainer()
	end

	self.m_lpScrollContainer=cc.Node:create()
	self.m_lpScrollView:addChild(self.m_lpScrollContainer)
	self.m_lpScrollView:setContentSize(self.m_viewSize)
	self.m_lpScrollView:setContentOffset(cc.p(0,0))
	self.m_lpScrollBar:chuangeSize()

	self.m_touchNodeArray={}
	self.m_lpRichTextArray={}

	self.m_curHeight=0
	self.m_removeHeight=0

	-- 语音
	self.m_voiceNodeArray={}
	self.m_curPlayingVoiceIdx=nil
	self.m_nextPlayVoiceIdx=nil
end

function ChatView.__removeInsertScheduler(self)
	if self.m_insertScheduler then
		_G.Scheduler:unschedule(self.m_insertScheduler)
		self.m_insertScheduler=nil
	end
end
function ChatView.__insertChatMsgArray(self,_chatMsgArray)
	local chatCount=#_chatMsgArray
	-- for i=1,chatCount do
	-- 	local chaMsg=_chatMsgArray[i]
	-- 	self:insertRichTextArrayByEnd(chaMsg)
	-- end

	local idx=chatCount>12 and chatCount-12+1 or 1
	for i=idx,chatCount do
		local chaMsg=_chatMsgArray[i]
		self:insertRichTextArrayByEnd(chaMsg)
	end

	do return end

	self:__removeInsertScheduler()

	local index=1
	local function nFun()
		self:insertRichTextArrayByEnd(_chatMsgArray[index])

		index=index+1

		if index>chatCount then
			self:__removeInsertScheduler()
			return
		end
	end

	local function nFun2()
		if index<(chatCount-3) then
			nFun()
			nFun()
			nFun()
		else
			nFun()
		end
	end

	local minCount=chatCount>8 and 8 or chatCount
	for i=1,minCount do
		nFun()
	end

	if minCount<chatCount then
		self.m_insertScheduler=_G.Scheduler:schedule(nFun2,0)
	end
end
function ChatView.insertOneChatMsg(self,_chatMsg)
	if self.m_insertScheduler then return end

	if _chatMsg.channel~=self.m_curChannel and self.m_curChannel~=P_CHANNEL_ALL then return end
	self:insertRichTextArrayByEnd(_chatMsg)
end

local P_RICH_SPACE=10
function ChatView.insertRichTextArrayByEnd(self,_chatMsg,_isInsertToStart)
	local richCount=#self.m_lpRichTextArray
	if _isInsertToStart and richCount>=P_MAX_COUNT then return end

	local tempRichText=ccui.RichText:create()
	tempRichText:setTouchEnabled(true)
	tempRichText:setSwallowTouches(false)
	tempRichText:ignoreContentAdaptWithSize(false)
	tempRichText:setContentSize(self.m_richSize)
	tempRichText:setPosition(self.m_richSize.width*0.5,-self.m_curHeight)

	if ccui.RichText.setVerticalFixationHeight then
		tempRichText:setVerticalFixationHeight(35)
	end

	local msgArray=_chatMsg.contentArray
	for i=1,#msgArray do
		local touchNode=_G.GChatProxy:insertRichTextOne(msgArray[i],tempRichText)
		if touchNode~=nil then
			if msgArray[i].touchType==_G.Const.kChatTouchVoice then
				self.m_voiceNodeArray[#self.m_voiceNodeArray+1]={node=touchNode,msg=msgArray[i],parent=tempRichText}
			else
				if self.m_touchNodeArray[tempRichText]==nil then
					self.m_touchNodeArray[tempRichText]={}
				end
				self.m_touchNodeArray[tempRichText][touchNode]=msgArray[i]
			end
		end
	end

	if richCount>=P_MAX_COUNT then
		local firstRichText=self.m_lpRichTextArray[1]
		local firstSize=firstRichText:getIgnoreContentSize()
        self.m_removeHeight=self.m_removeHeight+firstSize.height+P_VERTICAL_SPACE

        self.m_touchNodeArray[firstRichText]=nil

        if IS_SUPPORT_VOICE then
	        if self.m_voiceNodeArray[1] and self.m_voiceNodeArray[1].parent==firstRichText then
	        	local voiceNode=self.m_voiceNodeArray[1].node
	        	if 1==self.m_curPlayingVoiceIdx then
	        		self.m_curPlayingVoiceIdx=nil
	        	end
	        	table.remove(self.m_voiceNodeArray,1)
	        end

	        if self.m_nextPlayVoiceIdx==1 then
	        	self.m_nextPlayVoiceIdx=nil
	        	self:__removeAutoPlayVoice()
	        end
	    end

        firstRichText:removeFromParent(true)
        table.remove(self.m_lpRichTextArray,1)
	end

	tempRichText:formatText()
	local contentSize=tempRichText:getIgnoreContentSize()
	
	if _isInsertToStart then
		self.m_removeHeight=self.m_removeHeight-contentSize.height-P_VERTICAL_SPACE
		table.insert(self.m_lpRichTextArray,1,tempRichText)
		tempRichText:setPosition(self.m_richSize.width*0.5,-self.m_removeHeight)
	else
		self.m_curHeight=self.m_curHeight+contentSize.height+P_VERTICAL_SPACE
		self.m_lpRichTextArray[#self.m_lpRichTextArray+1]=tempRichText
	end
	self.m_lpScrollContainer:addChild(tempRichText)

	if self.m_curHeight>self.m_viewSize.height then
		local subHeight=self.m_curHeight-self.m_removeHeight
		print("AEEEEEEE",self.m_curHeight,self.m_removeHeight)
        if subHeight>self.m_viewSize.height then
            self.m_lpScrollView:setContentSize(cc.size(self.m_viewSize.width,subHeight))
        else
            self.m_lpScrollView:setContentSize(cc.size(self.m_viewSize.width,self.m_viewSize.height))
        end
		self.m_lpScrollBar:chuangeSize()
		self.m_lpScrollContainer:setPosition(0,self.m_curHeight)
	else
		self.m_lpScrollContainer:setPosition(0,self.m_viewSize.height+self.m_removeHeight)
	end
	
end
function ChatView.__addInputContent(self,_content)
	local chatString=self.m_lpTextField:getText()
	chatString=chatString.._content
	self.m_lpTextField:setText(chatString)
end

function ChatView.__privateChat(self,_privateChatId,_privateChatName)
	self.m_privateChatId=_privateChatId
	self.m_privateChatName=_privateChatName

	self.m_lpTextField:setText(string.format("/%s ",_privateChatName))
end

function ChatView.__sendVoiceMsg(self,_msgT)
	self:__hideVoiceSend()

	if not self.m_isSendVoice or self.m_voiceChannel==nil then
		print("__sendVoiceMsg===>>>  cancel send msg!!!")
		return
	end

	if _msgT.second<600 then
        local command=CErrorBoxCommand("录音时长太短或无声音")
        _G.controller:sendCommand(command)
        return
    end

	local sendType
	-- if self.m_voiceChannel==P_CHANNEL_TEAM then
	-- 	sendType=_G.Const.CONST_CHAT_TYPE_TEAM
	-- elseif self.m_voiceChannel==P_CHANNEL_CLAN then
	-- 	sendType=_G.Const.CONST_CHAT_TYPE_CLAN
	-- else
		sendType=_G.Const.CONST_CHAT_TYPE_CHAT
	-- end

	local szContent=_msgT.szMean
	if szContent then
		local len=string.len(szContent)
		local szLastChat=string.sub(szContent,len-2,len)
		if szLastChat=="，" then
			szContent=string.sub(szContent,1,len-3)
		end
	end

	print("__sendVoiceMsg=====>>>>",_msgT.second,szContent)
	local reqMsg=REQ_CHAT_SEND_YUYIN()
	reqMsg:setArgs(self.m_voiceChannel,sendType,self.m_privateChatId or 0,math.ceil(_msgT.second*0.001),_msgT.szUrl,szContent)
	_G.Network:send(reqMsg)
end

function ChatView.__sendMsg(self)
	if self.m_myLv<_G.Const.CONST_CHAT_LV_LIMIT then
		local command=CErrorBoxCommand(39802)
		controller:sendCommand(command)
		return
	end

	local chatString=self.m_lpTextField:getText()
	local sendString=nil

	print("__sendMsg---->",chatString)

	if self.m_syaChannel==P_CHANNEL_PM then
		if self.m_privateChatId==nil or self.m_privateChatName==nil then
			-- 发送失败，请选择私聊对象后，再发送！
			local command=CErrorBoxCommand("请选择私聊对象后再发送!")
			controller:sendCommand(command)
			return
		end
		local prefixName=string.format("/%s",self.m_privateChatName)
		if prefixName~=string.sub(chatString,1,string.len(prefixName)) then
			local command=CErrorBoxCommand("请选择私聊对象后再发送!")
			controller:sendCommand(command)
			return
		end
		sendString=string.sub(chatString,string.len(self.m_privateChatName)+3,-1)
	elseif self.m_syaChannel==P_CHANNEL_TEAM and not self.m_isInTeamView and _G.g_Stage:getScenesType()~=_G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
		local command=CErrorBoxCommand(2655)
		controller:sendCommand(command)
		return
	else
		sendString=chatString
	end

	if sendString then
		sendString=string.gsub(sendString,"\n","")
	end

	if sendString==nil or string.len(sendString)==0 then
		-- 发送失败，请输入聊天内容！
		local command=CErrorBoxCommand("请输入聊天内容！")
		controller:sendCommand(command)
		return
	end

	self.m_wordFilter=self.m_wordFilter or require("util.WordFilter")
	if not self.m_wordFilter:checkString(chatString) then
        return
    end

	if self.m_syaChannel==P_CHANNEL_CLAN then
		local myProperty=_G.GPropertyProxy:getMainPlay()
		local clanId=myProperty:getClan()
		if not clanId or clanId==0 then
			local szError="您还未加入门派"
			local command=CErrorBoxCommand(szError)
			controller:sendCommand(command)
			return
		end
	end

	local curTimes=_G.TimeUtil:getTotalSeconds()
	if self.m_lastSendTimes==nil then
		self.m_lastSendTimes=curTimes
	else
		if curTimes-self.m_lastSendTimes<5 then
			-- 间隔没到
			local needSecond=5-curTimes+self.m_lastSendTimes
			local szError=string.format("%d秒后才能继续发言",needSecond)
			local command=CErrorBoxCommand(szError)
			controller:sendCommand(command)
			return
		end
		self.m_lastSendTimes=curTimes
	end

	if string.find(sendString,"@")==1 then
		local msg=REQ_CHAT_GM()
		msg:setArgs(sendString)
		_G.Network:send(msg)
		print("__sendMsg---->  GM 命令")
		return
	end

	if self.m_syaChannel~=P_CHANNEL_PM then
		self.m_lpTextField:setText("")

		local msg=REQ_CHAT_SEND()
		if self.m_isHasGoodsMsg==true then
			local goodsArray=self:generateGoodsMsg(sendString)
			if #goodsArray>0 then
				msg:setArgs(self.m_syaChannel,0,0,sendString,#goodsArray,goodsArray)
				_G.Network:send(msg)
				self.m_sendGoodsIndex=0
				self.m_isHasGoodsMsg=nil
				self.m_sendGoodsList={}
				return
			end
		end

		msg:setArgs(self.m_syaChannel,0,0,sendString,0)
		_G.Network:send(msg)
	else
		self.m_lpTextField:setText(string.format("/%s ",self.m_privateChatName))

		local msg=REQ_CHAT_NAME()
		if self.m_isHasGoodsMsg==true then
			local goodsArray=self:generateGoodsMsg(sendString)
			if #goodsArray>0 then
				msg:setArgs(self.m_syaChannel,0,1,sendString,#goodsArray,goodsArray)
				_G.Network:send(msg)
				self.m_sendGoodsIndex=0
				self.m_isHasGoodsMsg=nil
				self.m_sendGoodsList={}
				return
			end
		end

		msg:setArgs(self.m_syaChannel,self.m_privateChatName,sendString,0)
		_G.Network:send(msg)
	end
end

function ChatView.generateGoodsMsg(self,_chat_msg)
    local searchIndex = 0
    local goodsList = {}
    while true do
        searchIndex = string.find(_chat_msg, "<#G", searchIndex+1)
        if searchIndex == nil then 
            break 
        end

        local closeTagIndex=string.find(_chat_msg, ">", searchIndex+1)
        if closeTagIndex == nil then 
            break 
        end

        local subStr = string.sub(_chat_msg,searchIndex+3,searchIndex+3)
        local goodsIndex=tonumber(subStr)
        if goodsIndex~=nil and goodsIndex<=self.m_sendGoodsIndex and goodsIndex<10 and goodsIndex>0 then
            local goodsInfo = self.m_sendGoodsList[goodsIndex]
            table.insert(goodsList,goodsInfo)
            searchIndex=closeTagIndex
        else
            searchIndex=searchIndex+1
        end
    end
    return goodsList
end

function ChatView.__chuangSyaChannel(self,_channel)
	if self.m_syaChannel==_channel then return end

	if self.m_syaChannel==P_CHANNEL_PM then
		self.m_lpTextField:setText("")
	end
	self.m_syaChannel=_channel
	self.m_lpChannelLabel:setString(_G.Lang.Chat_Channel_Name[_channel])
	-- self.m_lpChannelLabel:setColor(_G.ColorUtil:getRGB(_G.Const.kChatChannelColor[_channel]))
end

function ChatView.__releaseChannelTip(self)
	if self.m_channelTipsNode~=nil then
		self.m_channelTipsNode:removeFromParent(true)
		self.m_channelTipsNode=nil
	end
	self.m_rectChannelTips=nil
	self.m_rectFriendTips=nil
end
function ChatView.__createChannelTips( self )
	if self.m_channelTipsNode~=nil then return end

	self.m_channelTipsNode=cc.Node:create()

	local function nBenganCall(touch,sender)
		local touchPoint=touch:getStartLocation()
		if self.m_rectChannelTips~=nil then
			if cc.rectContainsPoint(self.m_rectChannelTips,touchPoint) then
				return true
			end
		end
		if self.m_rectFriendTips~=nil then
			if cc.rectContainsPoint(self.m_rectFriendTips,touchPoint) then
				return true
			end
		end

		local function nDelay()
			self:__releaseChannelTip()
		end
		performWithDelay(self.m_channelTipsNode,nDelay,0.05)
		return true
	end

	local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(nBenganCall,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)
 
    self.m_channelTipsNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_channelTipsNode)
	self.m_lpMainNode:addChild(self.m_channelTipsNode)

	local function nActionCall()
		if self.m_syaChannel==P_CHANNEL_PM then
			self:__createFriendArray()
		end
	end

	local channelBtnPos=cc.p(self.m_sayChannelBtn:getPosition())
	local framPos=cc.p(channelBtnPos.x,channelBtnPos.y+32)
	local backFrameSpri=ccui.Scale9Sprite:createWithSpriteFrameName("general_rolekuang.png")
	backFrameSpri:setPreferredSize(P_SIZE_SYACHANNEL)
	backFrameSpri:setPosition(framPos)
	backFrameSpri:setAnchorPoint(cc.p(0.5,0))
	backFrameSpri:setScaleY(0.01)
	backFrameSpri:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1,1),cc.CallFunc:create(nActionCall)))
	self.m_channelTipsNode:addChild(backFrameSpri)

	local worldPos=backFrameSpri:convertToWorldSpace(cc.p(0,0))
	self.m_rectChannelTips=cc.rect(worldPos.x,
									worldPos.y,
									P_SIZE_SYACHANNEL.width,
									P_SIZE_SYACHANNEL.height)

	local function nCallBack( sender,eventType )
		if eventType == ccui.TouchEventType.ended then
			local nChannel=sender:getTag()
			if nChannel==P_CHANNEL_PM then
				self:__createFriendArray()
				return
			end
			self:__chuangSyaChannel(nChannel)
			self:__releaseChannelTip()
		end
	end
	local tagArray={P_CHANNEL_WORLD,P_CHANNEL_CLAN,P_CHANNEL_PM,P_CHANNEL_TEAM}
	local nPos=P_SIZE_SYACHANNEL.height-42
	for i=1,#tagArray do
		local nChannel=tagArray[i]
		local buttonOne=gc.CButton:create("general_chat_tab.png")
		buttonOne:setTitleText(_G.Lang.Chat_Channel_Name[nChannel])
		buttonOne:setTitleColor(_G.ColorUtil:getRGBA(_G.Const.kChatChannelColor[nChannel]))
		buttonOne:setTitleFontSize(20)
		buttonOne:setTitleFontName(_G.FontName.Heiti)
		buttonOne:setPosition(P_SIZE_SYACHANNEL.width*0.5,nPos)
		buttonOne:addTouchEventListener(nCallBack)
		buttonOne:setTag(nChannel)
		-- buttonOne:setTitleOffset(cc.p(-5,0))
		backFrameSpri:addChild(buttonOne)
		nPos=nPos-56
	end
end
function ChatView.__createFriendArray(self)
	if self.m_channelTipsNode==nil then return end
	if self.m_rectFriendTips~=nil then return end

	local channelBtnPos=cc.p(self.m_sayChannelBtn:getPosition())
	local framPos=cc.p(channelBtnPos.x+P_SIZE_SYACHANNEL.width*0.5+P_SIZE_FRIEND.width*0.5,channelBtnPos.y+P_SIZE_SYACHANNEL.height*0.5+32)
	local backFrameSpri=ccui.Scale9Sprite:createWithSpriteFrameName("general_fram_chat.png")
	backFrameSpri:setPreferredSize(P_SIZE_FRIEND)
	backFrameSpri:setPosition(framPos)
	self.m_channelTipsNode:addChild(backFrameSpri)

	local worldPos=backFrameSpri:convertToWorldSpace(cc.p(0,0))
	self.m_rectFriendTips=cc.rect(worldPos.x,
									worldPos.y,
									P_SIZE_FRIEND.width,
									P_SIZE_FRIEND.height)

	local midPosX=P_SIZE_FRIEND.width*0.5

	local friendMsgArray=_G.GFriendProxy:getDatalList(_G.Const.CONST_FRIEND_FRIEND)
	local friendCount=#friendMsgArray
	if friendCount==0 then
		local tempLabel=_G.Util:createLabel("没有好友",18)
		tempLabel:setPosition(midPosX,P_SIZE_FRIEND.height*0.5)
		backFrameSpri:addChild(tempLabel)
		return
	end

	local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
        	local fUid=sender:getTag()
        	local _,fMsg=_G.GFriendProxy:hasThisFriend(fUid)
        	if fMsg==nil then return end

        	local chatData={}
			chatData.dataType=_G.Const.kChatDataTypeSL
			chatData.chatName=fMsg.name
			chatData.chatId=fUid

			self.m_chatData=chatData
			self:__initData()
        end
    end

    local scrollHei=P_SIZE_FRIEND.height-6
	local oneHeight=scrollHei/4
	local maxHeight=friendCount>4 and oneHeight*friendCount or scrollHei
	local ceilSize=cc.size(P_SIZE_FRIEND.width,oneHeight)

	local scoView=cc.ScrollView:create()
    scoView:setDirection(ccui.ScrollViewDir.vertical)
    scoView:setTouchEnabled(true)
    scoView:setViewSize(cc.size(P_SIZE_FRIEND.width,scrollHei))
    scoView:setContentSize(cc.size(P_SIZE_FRIEND.width,maxHeight))
    scoView:setContentOffset(cc.p(0,P_SIZE_FRIEND.height-maxHeight))
    scoView:setPosition(0,(P_SIZE_FRIEND.height-scrollHei)*0.5)
    backFrameSpri:addChild(scoView)

	local nPosY=maxHeight-oneHeight*0.5
	for i=1,friendCount do
		local fMsg=friendMsgArray[i]
		local fUid=fMsg.id
		local fName=fMsg.name

		local touchWidget=ccui.Widget:create()
        touchWidget:setContentSize(ceilSize)
        touchWidget:setTouchEnabled(true)
        touchWidget:setTag(fUid)
        touchWidget:addTouchEventListener(c)
        touchWidget:setPosition(ceilSize.width*0.5,nPosY)
        touchWidget:setSwallowTouches(false)
        scoView:addChild(touchWidget)

        local nameLabel=_G.Util:createLabel(fName,18)
        nameLabel:setPosition(ceilSize.width*0.5,oneHeight*0.5)
        touchWidget:addChild(nameLabel)

        nPosY=nPosY-oneHeight
	end
end

function ChatView.__hideFaceTip( self )
	if self.m_faceContainer ~= nil then
		self.m_faceContainer:setVisible(false)
		self.m_faceListerner:setEnabled(false)
	end
end
function ChatView.__showFaceTips( self )
	if self.m_faceContainer~=nil then
		self.m_faceContainer:setVisible(true)
		self.m_faceListerner:setEnabled(true)
		return
	end

	local faceViewSize=cc.size(470,370)
	self.m_faceContainer=cc.Node:create()

	self.m_faceContainer:setPosition(183,-25)
	self.m_lpMainNode:addChild(self.m_faceContainer)

	local backFrameSpri=ccui.Scale9Sprite:createWithSpriteFrameName("general_rolekuang.png")
	backFrameSpri:setPreferredSize(faceViewSize)
	self.m_faceContainer:addChild(backFrameSpri)

	local spriteBatchNode=cc.Node:create()
	self.m_faceContainer:addChild(spriteBatchNode)

	self.m_faceIcons={}
    local xPosition = -faceViewSize.width/2+15
    local yPosition = faceViewSize.height/2-10
    local columNum  = 9
	for i=1,63 do
		local spriteName = string.format("chat_%.2d.png",i)
		local faceIcon=cc.Sprite:createWithSpriteFrameName(spriteName)
		faceIcon:setAnchorPoint(cc.p(0,1)) 
		spriteBatchNode:addChild(faceIcon)
		faceIcon:setPosition(xPosition+(i-1)%columNum*50,yPosition-math.floor((i-1)/columNum)*50)
		self.m_faceIcons[i]=faceIcon
	end

	local faceSize=cc.size(41,41)
	local faceRect=cc.rect(0,-faceSize.height,faceSize.width,faceSize.height)
	local nnnnnn=backFrameSpri:convertToWorldSpace(cc.p(0,0))
	local bgRect=cc.rect(nnnnnn.x,nnnnnn.y,faceViewSize.width,faceViewSize.height)
	local __rectContainsPoint=cc.rectContainsPoint
	local function nBenganCall(touch,event)
		local touchPoint=touch:getStartLocation()
		local touchFace=nil
		for faceId,faceIcon in pairs(self.m_faceIcons) do
			local arPoint=faceIcon:convertToNodeSpaceAR(touchPoint)
			local isInFace=__rectContainsPoint(faceRect,arPoint)
			if isInFace then
				touchFace=faceId
				break
			end
		end
		if touchFace~=nil then
			local chatString=self.m_lpTextField:getText()
			local StrNum = string.len(chatString)
			local yuStrNum = math.floor((90-StrNum)/6)

			if yuStrNum>0 then
				local faceStr = string.format("<#F%.2d>",touchFace)
				local currentStr = string.format("%s%s",self.m_lpTextField:getText(),faceStr)
				self.m_lpTextField:setText(currentStr)
			end
			self:__hideFaceTip()
		elseif not __rectContainsPoint(bgRect,touchPoint) then
			self:__hideFaceTip()
		end
		return true
	end

    self.m_faceListerner=cc.EventListenerTouchOneByOne:create()
    self.m_faceListerner:registerScriptHandler(nBenganCall,cc.Handler.EVENT_TOUCH_BEGAN )
    self.m_faceListerner:setSwallowTouches(true)
    self.m_faceContainer:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_faceListerner,self.m_faceContainer)
end

function ChatView.teamCheckBack(self,_teamState)
	if _teamState==1 then
		if self.m_chatTeamData==nil then return end
		self:closeWindow()
		_G.GLayerManager:delayOpenLayer(_G.Const.CONST_FUNC_OPEN_TEAM,nil,self.m_chatTeamData.teamId)
	-- elseif _teamState==0 then
	-- 	local command=CErrorBoxCommand(_G.Lang.ERROR_N[88])
	-- 	controller:sendCommand(command)
	-- elseif _teamState==2 then
	-- 	local command=CErrorBoxCommand(_G.Lang.ERROR_N[89])
	-- 	controller:sendCommand(command)
	end
end

function ChatView.__touchEnvetHandle(self,_chatMsg,_node)
	if _chatMsg==nil then return end
	local tType=_chatMsg.touchType
	if tType==_G.Const.kChatTouchName then
		local uid=tonumber(_chatMsg.uid)
		print(string.format("【聊天】点击人物名字: uid=%d,name=%s",uid,_chatMsg.name))
		if uid==self.m_myUid then return end
		local nData={
			type=1,
			uid=uid,
			name=_chatMsg.name,
		}
		self:__showNormalTips(nData)
	elseif tType==_G.Const.kChatTouchGood then
		print("【聊天】点击物品:")
		local nPos=_node:convertToWorldSpace(cc.p(0,0))
		if _chatMsg.goods_id~=nil then
			print(string.format("基本物品:goods_id=%d",_chatMsg.goods_id))
			local temp=_G.TipsUtil:createById(_chatMsg.goods_id,nil,nPos)
			self.m_lpRootLayer:addChild(temp,1000)
		else
			print(string.format("数据物品:goods_id=%d",_chatMsg.goodMsg.goods_id))
			local temp=_G.TipsUtil:create(_chatMsg.goodMsg,nil,nPos)
        	self.m_lpRootLayer:addChild(temp,1000)
		end
	elseif tType==_G.Const.kChatTouchTeam then
		print(string.format("【聊天】点击组队: teamId=%d, copyId=%d",_chatMsg.teamId,_chatMsg.copyId))
		if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_TEAM) then
			return
		end

		if not _G.g_Stage.m_isCity then
			local command=CErrorBoxCommand(_G.Lang.ERROR_N[86])
			controller:sendCommand(command)
			return
		end
		if _G.GLayerManager:isTeamViewOpen() then
			local command=CErrorBoxCommand(_G.Lang.ERROR_N[87])
			controller:sendCommand(command)
			return
		end

		local msg=REQ_TEAM_LIVE_REQ()
		msg:setArgs(_chatMsg.teamId,3)
		_G.Network:send(msg)

		self.m_chatTeamData={}
		self.m_chatTeamData.teamId=_chatMsg.teamId
		self.m_chatTeamData.copyId=_chatMsg.copyId

	elseif tType==_G.Const.kChatTouchClan then
		print(string.format("【聊天】点击门派: clanId=%d,clanName=%s",_chatMsg.clanId,_chatMsg.clanName))
		local nData={
			type=2,
			clan_id=tonumber(_chatMsg.clanId),
			clan_name=_chatMsg.clanName,
		}
		self:__showNormalTips(nData)
	end
end

function ChatView.__hideNormalTips(self)
	if self.m_normalTipsNode==nil then return end
	local function f(_node)
		_node:removeFromParent(true)
	end
	local action=cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(f))
	self.m_normalTipsNode:runAction(action)
	self.m_normalTipsNode=nil
end
function ChatView.__showNormalTips(self,_nData)
	self:__hideNormalTips()

	self.m_normalTipsDta=_nData

	local winSize=self.m_winSize
	self.m_normalTipsNode=cc.LayerColor:create(cc.c4b(0,0,0,150))
	-- self.m_normalTipsNode:setPosition()

	local btnInfoArray={}
	local btnInfoCount=0

	local szTitle
	if _nData.type==2 then
		szTitle=_nData.clan_name
		local myClanId=_G.GPropertyProxy:getMainPlay():getClan()
		print("==========>>>>>>>>",myClanId,_nData.clan_id)
		if myClanId==_nData.clan_id then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={9,"退出门派"}
		else
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={8,"加入门派"}
		end
		btnInfoCount=btnInfoCount+1
		btnInfoArray[btnInfoCount]={7,"查看门派"}
	else
		szTitle=_nData.name
		if not _G.GFriendProxy:hasThisBlackFriend(_nData.uid) then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={6,"加黑名单"}
		else
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={5,"解除黑名"}
		end
		if not _G.GFriendProxy:hasThisFriend(_nData.uid) then
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={4,"加为好友"}
		else
			btnInfoCount=btnInfoCount+1
			btnInfoArray[btnInfoCount]={3,"删除好友"}
		end
		btnInfoCount=btnInfoCount+1
		btnInfoArray[btnInfoCount]={2,"发起私聊"}
		
		btnInfoCount=btnInfoCount+1
		btnInfoArray[btnInfoCount]={1,"查看信息"}
	end

	local buttonCount=#btnInfoArray
	local oneHeight=55
	local tipsSize=cc.size(176,55+(oneHeight)*buttonCount)
	local backFrameSpri=ccui.Scale9Sprite:createWithSpriteFrameName("general_friendkuang.png")
	backFrameSpri:setPosition( winSize.width*0.5,winSize.height*0.5)
	backFrameSpri:setPreferredSize(tipsSize)
	self.m_normalTipsNode:addChild(backFrameSpri)

	local midPos=tipsSize.width*0.5
	local nameLabel=_G.Util:createLabel(szTitle,20)
	nameLabel:setPosition(midPos,tipsSize.height-30)
	nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	backFrameSpri:addChild(nameLabel)

	for i=1,#btnInfoArray do
		self:createLightButton(i,btnInfoArray[i][1],btnInfoArray[i][2],tipsSize,backFrameSpri)
	end

	local function onTouchBegan()
		self:__hideNormalTips()
		return true 
	end
	local listerner=cc.EventListenerTouchOneByOne:create()
	listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	listerner:setSwallowTouches(true)
	self.m_normalTipsNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_normalTipsNode)
	cc.Director:getInstance():getRunningScene():addChild(self.m_normalTipsNode,999)
end
function ChatView.createLightButton(self,_no,_tag,_szName,_size,_parent)
	local function c(sender,eventType)
		if eventType==ccui.TouchEventType.began then
            sender:setOpacity(180)
		elseif eventType==ccui.TouchEventType.ended then
			sender:setOpacity(255)
			local tag=sender:getTag()
			local uid=self.m_normalTipsDta.uid
			print("createLightButton=========>>>>>",tag,uid)

			if tag==1 then
				if self.m_isInTeamView then
					local command=CErrorBoxCommand("组队界面不支持查看信息")
					controller:sendCommand(command)
					return
				elseif not _G.g_Stage.m_isCity then
					local command=CErrorBoxCommand("战斗界面不支持查看信息")
					controller:sendCommand(command)
					return
				end
				_G.GLayerManager:showPlayerView(uid)
			elseif tag==2 then
				local chatData={}
				chatData.dataType=_G.Const.kChatDataTypeSL
				chatData.chatName=self.m_normalTipsDta.name
				chatData.chatId=uid
				-- _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_CHATTING,nil,chatData)
				self.m_chatData=chatData
				self:__initData()
			elseif tag==4 then
				local msg = REQ_FRIEND_ADD()
				msg:setArgs(_G.Const.CONST_FRIEND_FRIEND,1,{uid})
				_G.Network:send(msg)
			elseif tag==3 then
				local msg=REQ_FRIEND_DEL()
				msg:setArgs(uid,_G.Const.CONST_FRIEND_FRIEND)
				_G.Network:send(msg)
			elseif tag==6 then
				local msg = REQ_FRIEND_ADD()
				msg:setArgs(_G.Const.CONST_FRIEND_BLACKLIST,1,{uid})
				_G.Network:send(msg)
			elseif tag==5 then
				local msg=REQ_FRIEND_DEL()
				msg:setArgs(uid,_G.Const.CONST_FRIEND_BLACKLIST)
				_G.Network:send(msg)
			elseif tag==9 then
				-- 退出门派
				local szMsg="确定要退出门派吗？\n(门派技能保留)"
				local function fun1()
					local msg=REQ_CLAN_ASK_OUT_CLAN()
					msg:setArgs(1)        -- {1 退出门派| 0 解散门派}
					_G.Network:send(msg)
				end
				_G.Util:showTipsBox(szMsg,fun1)
			elseif tag==8 then
				-- 加入门派
				local msg=REQ_CLAN_ASK_CANCEL()
		        msg:setArgs(1,self.m_normalTipsDta.clan_id)
		        _G.Network:send(msg)
			elseif tag==7 then
				-- 查看门派
				if self.m_isInTeamView then
					local command=CErrorBoxCommand("组队界面不支持查看信息")
					controller:sendCommand(command)
					return
				elseif not _G.g_Stage.m_isCity then
					local command=CErrorBoxCommand("战斗界面不支持查看信息")
					controller:sendCommand(command)
					return
				end
				_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_GANGS,nil,self.m_normalTipsDta.clan_id)
			end
			self:__hideNormalTips()
		elseif eventType==ccui.TouchEventType.canceled then
            sender:setOpacity(255)
		end
	end
	local widget=gc.CButton:create("general_btn_gray.png")
	widget:setTouchEnabled(true)
	widget:addTouchEventListener(c)
	widget:setPosition(_size.width/2,5+(_no-0.5)*55)
	widget:setTag(_tag)
	_parent:addChild(widget)

	widget : setTitleText(_szName)
	widget : setTitleFontSize(22)
	widget : setTitleFontName(_G.FontName.Heiti)

	return widget
end

function ChatView.__pauseBackgroundMusic(self)
	cc.SimpleAudioEngine:getInstance():pauseMusic()
	cc.SimpleAudioEngine:getInstance():stopAllEffects()
end
function ChatView.__resumeBackgroundMusic(self)
	cc.SimpleAudioEngine:getInstance():resumeMusic()
end

-- *****************  语音  ******************
function ChatView.__recordVoiceStart(self)
	if self.m_myLv<_G.Const.CONST_CHAT_LV_LIMIT then
		local command=CErrorBoxCommand(39802)
		controller:sendCommand(command)
		return
	end

	if self.m_recordVoiceLayer then return end

	if _G.TimeUtil:getTotalMilliseconds()<(self.m_lastRecordTimes+1000) then
		local command=CErrorBoxCommand("录音不能太频繁哦!")
		_G.controller:sendCommand(command)
		return
	end

	if self.m_syaChannel==P_CHANNEL_PM then
		if self.m_privateChatId==nil then
			local command=CErrorBoxCommand("请选择私聊对象后再录音!")
			controller:sendCommand(command)
			return
		end
	elseif self.m_syaChannel==P_CHANNEL_TEAM then
		if not self.m_isInTeamView and _G.g_Stage:getScenesType()~=_G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
			local command=CErrorBoxCommand(2655)
			controller:sendCommand(command)
			return
		end
	elseif self.m_syaChannel==P_CHANNEL_CLAN then
		local myProperty=_G.GPropertyProxy:getMainPlay()
		local clanId=myProperty:getClan()
		if not clanId or clanId==0 then
			local szError="您还未加入门派!"
			local command=CErrorBoxCommand(szError)
			controller:sendCommand(command)
			return
		end
	end

	self.m_voiceChannel=self.m_syaChannel

	print("开始录音")
	local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_recordVoiceLayer=cc.Layer:create()
    self.m_recordVoiceLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_recordVoiceLayer)
    
    local tempNode=cc.Node:create()
    tempNode:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
    self.m_recordVoiceLayer:addChild(tempNode)
    cc.Director:getInstance():getRunningScene():addChild(self.m_recordVoiceLayer,777)

    local dins = ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")
    dins:setPreferredSize(cc.size(120,100))
    tempNode:addChild(dins)

    local icon = cc.Sprite:createWithSpriteFrameName("general_voice.png")
    icon:setPosition(cc.p(40,60))
    dins:addChild(icon)
    
    local volume = cc.Sprite:create()
    volume:setPosition(80,60)
    volume:runAction(cc.RepeatForever:create(_G.AnimationUtil:getVoiceRecordAnimate()))
    dins:addChild(volume)

    local tipsLabel=_G.Util:createLabel("开始录音...",16)
    tipsLabel:setPosition(cc.p(60,20))
    dins:addChild(tipsLabel)
    gc.VoiceManager:getInstance():starRecord()

    self:__pauseBackgroundMusic()

    local function nFun()
    	self:__recordVoiceStop(false)
    end
    self.m_recordVoiceLayer:runAction(cc.Sequence:create(cc.DelayTime:create(30),cc.CallFunc:create(nFun)))
end
function ChatView.__recordVoiceStop(self,_isCancel)
	self.__resumeBackgroundMusic()

	if not self.m_recordVoiceLayer then
		return
	end

	self.m_recordVoiceLayer:removeFromParent(true)
	self.m_recordVoiceLayer=nil

	-- if _isCancel then
	-- 	self.m_isSendVoice=false
	-- 	self.m_lastRecordTimes=_G.TimeUtil:getTotalMilliseconds() - 500
	-- else
		self.m_isSendVoice=true
		self.m_lastRecordTimes=_G.TimeUtil:getTotalMilliseconds()
	-- end

	gc.VoiceManager:getInstance():stopRecord()

	self:__showVoiceSend()
end

function ChatView.__showVoiceSend(self)
	if not self.m_voiceButton then return end

	self.m_voiceButton:setEnabled(false)
	self.m_voiceButton:setBright(false)

	if self.m_showVoiceSendNode~=nil then
		self.m_showVoiceSendNode:setVisible(true)
		return
	end

	local btnSize=self.m_voiceButton:getContentSize()
	self.m_showVoiceSendNode=cc.Node:create()
	self.m_showVoiceSendNode:setPosition(btnSize.width*0.5,btnSize.height*0.5-10)
	self.m_voiceButton:addChild(self.m_showVoiceSendNode,10)

	local tempSpr=cc.Sprite:createWithSpriteFrameName("general_tip_up.png")
	tempSpr:setPosition(0,15)
	tempSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(0,20)),cc.MoveBy:create(0.01,cc.p(0,-20)))))
	self.m_showVoiceSendNode:addChild(tempSpr)

	local tempLabel=_G.Util:createBorderLabel("发送中",16)
	-- tempLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
	self.m_showVoiceSendNode:addChild(tempLabel)
end
function ChatView.__hideVoiceSend(self)
	if not self.m_voiceButton then return end

	self.m_voiceButton:setEnabled(true)
	self.m_voiceButton:setBright(true)

	if self.m_showVoiceSendNode then
		self.m_showVoiceSendNode:setVisible(false)
	end
end

function ChatView.__autoPlayNextVoice(self,_nextIdx)
	if self.m_autoPlayVoiceScheduler then return end

	if gc.VoiceManager:getInstance():isPlayIng() then return end

	local function nDelay()
		self.m_autoPlayVoiceScheduler=nil
		self:__playVoiceHandle(_nextIdx)
	end

	self.m_autoPlayVoiceScheduler=_G.Scheduler:performWithDelay(0.2,nDelay)
end
function ChatView.__removeAutoPlayVoice(self)
	if self.m_autoPlayVoiceScheduler then
		_G.Scheduler:unschedule(self.m_autoPlayVoiceScheduler)
		self.m_autoPlayVoiceScheduler=nil
	end
end
function ChatView.__setVoiceNodeState(self,_node,_isPlaying)
	local voiceSpr=_node:getChildByTag(100)
	-- local timeLabel=_node:getChildByTag(90)

	if _isPlaying then
		voiceSpr:setColor(_G.Const.kChatVoiceColorPlaySpr)
		-- timeLabel:setColor(_G.Const.kChatVoiceColorPlayLab)
	else
		voiceSpr:setColor(_G.Const.kChatVoiceColorEndSpr)
		-- timeLabel:setColor(_G.Const.kChatVoiceColorEndLab)
	end
end
function ChatView.__playVoiceHandle(self,_idx)
	local _chatMsg=self.m_voiceNodeArray[_idx].msg
	local _node=self.m_voiceNodeArray[_idx].node

	self:__removeAutoPlayVoice()

	print("【聊天】播放语音",_chatMsg.szUrl)
	if gc.VoiceManager:getInstance():isPlayIng() then
		gc.VoiceManager:getInstance():stopPlay()
		self.m_nextPlayVoiceIdx=_idx
		return
	end

	if _idx==self.m_curPlayingVoiceIdx then
		print("【聊天】停止播放")
		self.m_curPlayingVoiceIdx=nil
		self:__resumeBackgroundMusic()
		self:__setVoiceNodeState(_node,false)
		return
	elseif self.m_curPlayingVoiceIdx~=nil then
		local tempNode=self.m_voiceNodeArray[self.m_curPlayingVoiceIdx].node
		self:__setVoiceNodeState(tempNode,false)
	end

	self:__setVoiceNodeState(_node,true)

	self:__pauseBackgroundMusic()

	self.m_curPlayingVoiceIdx=_idx
	gc.VoiceManager:getInstance():playRecord(_chatMsg.szUrl)

	if not _chatMsg.isPlayEnd then
		_chatMsg.isPlayEnd=true
		self.m_isAutoPlayVoice=true
	else
		self.m_isAutoPlayVoice=false
	end
end
function ChatView.playVoiceFinish(self)
	local prePlayIdx=self.m_curPlayingVoiceIdx
	if prePlayIdx then
		self.m_curPlayingVoiceIdx=nil

		local tempNode=self.m_voiceNodeArray[prePlayIdx].node
		self:__setVoiceNodeState(tempNode,false)

		if self.m_nextPlayVoiceIdx then
			self:__autoPlayNextVoice(self.m_nextPlayVoiceIdx)
			self.m_nextPlayVoiceIdx=nil
			return
		end

		if self.m_isAutoPlayVoice then
			self.m_isAutoPlayVoice=false

			local nextIdx=prePlayIdx+1
			local nextNodeData=self.m_voiceNodeArray[nextIdx]
			if nextNodeData~=nil and not nextNodeData.msg.isPlayEnd then
				self:__autoPlayNextVoice(nextIdx)
				return
			end
		end
	end
	self:__resumeBackgroundMusic()
end

function ChatView.closeWindow(self)
	if self.m_lpRootLayer==nil then return end
	self:__removeAutoScheduler()
	self:__removeInsertScheduler()
	self:__releaseScrollContainer()

	self.m_lpRootLayer:removeFromParent(true)
	self.m_lpRootLayer=nil

	self:__removeAutoPlayVoice()
	self:destroy()

	if not _G.g_Stage.m_isCity then
		_G.SysInfo:setGameIntervalHigh()
	end
end

function ChatView.__releaseScrollContainer(self)
	local tempNode=self.m_lpScrollContainer
	if not tempNode then return end
	self.m_lpScrollContainer=nil

	local richArray=self.m_lpRichTextArray
	local richCount=#richArray
	if richCount<10 then
		tempNode:removeFromParent(true)
		return
	end

	tempNode:retain()
	tempNode:removeFromParent(false)

	local nScheduler=nil
	local function nFun()
		if not next(richArray) then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(nScheduler)
			tempNode:release()
			return
		end

		local richText=table.remove(richArray,1)
		richText:removeFromParent(true)
	end

	-- 不用_G.Scheduler 防止过场景清调了....
	nScheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(nFun,0,false)
end

return ChatView

