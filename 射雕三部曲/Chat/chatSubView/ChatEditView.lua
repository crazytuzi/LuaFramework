--[[
文件名: ChatEditView.lua
描述: 聊天输入框相关控件
创建人: liaoyuangang
创建时间: 2017.06.14
-- ]]

local ChatEditView = class("ChatEditView", function(params)
    return display.newLayer()
end)

--记录聊天发送时间 计算冷却
local LastChatTime = {}

--[[
-- 参数 
	params 中的各项为：
	{
		viewSize: 显示区域的大小
		inputMode: 输入模式类型, 取值在Enums.lua文件的“Enums.ChatInputMode”中定义，默认为文本输入模式
		sendMsgCb: 发送消息的回调函数 sendMsgCb(msgStr, voiceStr)
		getChatCD: 获取发送cd时间的回调函数
        channeType:当前是那个频道
	}
]]
function ChatEditView:ctor(params)
	params = params or {}

    local _, _, eventID = Guide.manager:getGuideInfo()
    local layerName = LayerManager.getTopCleanLayerName()
    if ChatForbidCleanUpList[layerName] or eventID then
        self.mForbidCleanUp = true
    end

	-- 显示区域的大小
	self.mViewSize = params.viewSize
	-- 发送消息的回调函数
	self.sendMsgCb = params.sendMsgCb
    -- 设置语音任务对象发送消息的回调函数
    VoiceMsgTaskObj:setSendMsgFunc(params.sendMsgCb)
    self.mChatChanne = params.channeType or Enums.ChatChanne.eUnknown
    -- 默认为文本输入模式
    self.mInputMode = VoiceMsgTaskObj:getInputMode() or Enums.ChatInputMode.textInput
    -- 获取发送cd时间的回调函数
    self.getChatCD = function(channeType)
        if params.getChatCD then
            return params.getChatCD(channeType)
        else
            return 10  -- 默认cd时间为10秒
        end
    end

    -- 发送消息的最大长度
    self.mMaxChatLen = 100

	self:setIgnoreAnchorPointForPosition(false)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.mViewSize)

    -- 初始化页面控件
    self:initUI()
end

-- 初始化页面控件
function ChatEditView:initUI()
    -- 如果是喇叭频道只需要显示使用喇叭按钮
    if self.mChatChanne == Enums.ChatChanne.eHorn then
        -- 
        local tempBtn = ui.newButton({
            normalImage = "lt_21.png",
            size = cc.size(590, 51),
            clickAction = function()
                -- 发送小喇叭信息按钮的点击事件
                self:onMarqueeBtnClick()
            end
        })
        tempBtn:setPressedActionEnabled(false)
        tempBtn:setPosition(self.mViewSize.width / 2, self.mViewSize.height / 2)
        self:addChild(tempBtn)

        -- 小喇叭数量
        local tempLabel = ui.newLabel({
            text = "",
            size = 24,
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x22, 0x4e, 0x0a),
            outlineSize = 2,
        })
        tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
        tempLabel:setPosition(self.mViewSize.width * 0.5, self.mViewSize.height / 2)
        self:addChild(tempLabel)

        local useModelId = 16050086
        -- 道具数量改变后的事件通知
        local function setGoodsChange()
            local tempModel = GoodsModel.items[useModelId]
            local tempImg = tempModel and Utility.getDaibiImage(tempModel.typeID, useModelId) or "db_50086.png"
            local tempStr = TR("点击使用小喇叭功能{%s} x %s%d", tempImg, "#cbff86", GoodsObj:getCountByModelId(useModelId))
            tempLabel:setString(tempStr)
        end
        Notification:registerAutoObserver(tempLabel, setGoodsChange, {EventsName.ePropRedDotPrefix .. tostring(useModelId)})
        -- 
        setGoodsChange()
    else
        -- 输入模式UI的父控件
        self.mInputBgSprite = ui.newScale9Sprite("c_83.png", self.mViewSize)
        self.mInputBgSprite:setPosition(self.mViewSize.width / 2, self.mViewSize.height / 2)
        self:addChild(self.mInputBgSprite)

        -- 输入模式和语音模式切换按钮
        self.mModeChangeBtn = ui.newButton({
            normalImage = self.mInputMode == Enums.ChatInputMode.textInput and "lt_07.png" or "lt_26.png", 
            clickAction = function()
                if self.mInputMode == Enums.ChatInputMode.textInput then
                    self.mInputMode = Enums.ChatInputMode.voiceInput
                    self.mModeChangeBtn:loadTextures("lt_26.png", "lt_26.png")
                    self:createVoiceInputUI()
                else
                    self.mInputMode = Enums.ChatInputMode.textInput
                    self.mModeChangeBtn:loadTextures("lt_07.png", "lt_07.png")
                    self:createTextInputUI()
                end

                VoiceMsgTaskObj:setInputMode(self.mInputMode)
            end
        })
        self.mModeChangeBtn:setPosition(58, self.mViewSize.height / 2)
        self:addChild(self.mModeChangeBtn)

        -- 
        if self.mInputMode == Enums.ChatInputMode.textInput then
            self:createTextInputUI()
        else
            self:createVoiceInputUI()
        end
    end
end

function ChatEditView:onEnterTransitionFinish()
    -- 如是战斗进入则设置为true
    local _, _, eventID = Guide.manager:getGuideInfo()
    local layerName = LayerManager.getTopCleanLayerName()
    if ChatForbidCleanUpList[layerName] or eventID then
        self.mForbidCleanUp = true
    end
end

-- 创建文本输入模式UI
function ChatEditView:createTextInputUI()
	self.mInputBgSprite:removeAllChildren()

    -- 发送按钮的点击事件函数声明
    local sendBtnOnClick = nil

	-- 输入聊天内容的editbox
    local msgEidtBox = ui.newEditBox({
        image = "lt_13.png",
        fontColor = Enums.Color.eNormalWhite,
        fontSize = 22,
        size = cc.size(290, 46),
        listener = function(event, pSender)
            if event == "ended" then
                local tempStr = pSender:getText()
                tempStr = string.trim(self:cleanStr(tempStr))
                pSender:setText(tempStr)
            elseif event == "done" then
                sendBtnOnClick()
            end
        end,
    })
    msgEidtBox:setAnchorPoint(cc.p(0, 0.5))
    msgEidtBox:setPosition(100, self.mViewSize.height / 2)
    msgEidtBox:setPlaceHolder(TR("点击输入文字"))
    msgEidtBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self.mInputBgSprite:addChild(msgEidtBox)

    --创建表情按钮
    local faceBtn = ui.newButton({
        normalImage = "lt_10.png",
        clickAction = function()
            self:createFaceLayer(msgEidtBox)
        end,
    })
    faceBtn:setPosition(420, self.mViewSize.height / 2)
    self.mInputBgSprite:addChild(faceBtn)

    --红包按钮
    local marqueeBtn = ui.newButton({
        normalImage = "xn_83.png",
        clickAction = function()
            if not ModuleInfoObj:moduleIsOpen(ModuleSub.eRedPurse, true) then
                return
            end
            LayerManager.addLayer({
                name = "Chat.ChatRedPackageLayer",
                cleanUp = false,
                zOrder = self.mForbidCleanUp and Enums.ZOrderType.ePopLayer or nil,
            })
        end,
    })
    marqueeBtn:setScale(0.7)
    marqueeBtn:setPosition(470, self.mViewSize.height / 2)
    self.mInputBgSprite:addChild(marqueeBtn)

    -- 创建发送按钮
    local sendBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("发送"),
        fontSize = 24,
        clickAction = function()
            sendBtnOnClick()
        end,
    })
    sendBtn:setScale(0.9)
   	sendBtn:setPosition(self.mViewSize.width - 81, self.mViewSize.height / 2)
    self.mInputBgSprite:addChild(sendBtn)
    self:setChatCDTime(sendBtn)

    -- 定义发送按钮点击事件函数
    sendBtnOnClick = function()
        local msgStr = msgEidtBox:getText()
        if not self:allowSendMsg(msgStr) then
            return
        end

        if self.sendMsgCb then
    		self.sendMsgCb(msgStr)
    	end

        --记录该次发送消息的时间
        LastChatTime[self.mChatChanne] = Player:getCurrentTime()
        self:setChatCDTime(sendBtn)
        msgEidtBox:setText("")
    end
end

-- 创建语音输入模式UI
function ChatEditView:createVoiceInputUI()
	self.mInputBgSprite:removeAllChildren()

	-- 是否需要语音转文字
	local needToText = self.mInputMode == Enums.ChatInputMode.voiceTextInput

	-- 说话控件
    local btnText = needToText and TR("按住说话，自动转文字发送") or TR("按住说话，发送语音")
	local speechBtn = ui.newButton({
		normalImage = "lt_18.png",
        lightedImage = "lt_37.png",
        size = cc.size(424, 46),
		text = btnText,
        fontSize = 24,
	})
    speechBtn:setPressedActionEnabled(false)
	speechBtn:setPosition(316, self.mViewSize.height / 2)
	self.mInputBgSprite:addChild(speechBtn)
	local speechRect = speechBtn:getBoundingBox()
    self:setChatCDTime(speechBtn, btnText)

	-- 注册触摸事件
	local statusNode = nil -- 说话时状态图片
    local recordFilename = nil -- 当前正在录制语音保存的文件名
    local isBeginRecord = false -- 是否已开始录制语音
    local touchBeginTime = nil -- 录制语音的开始时间
	speechBtn:addTouchEventListener(function(sender, event)     
        if event == ccui.TouchEventType.began then
            speechBtn.mBeginPos = sender:getTouchBeganPosition()

            -- 创建语音状态控件
            statusNode = self:createSpeechStatusUI()
            statusNode:setPosition(display.cx, display.cy)
            statusNode:setScale(Adapter.MinScale)
            LayerManager.getMainScene():addChild(statusNode, 1024)

            VoiceMsgTaskObj:initGVoice(function(hadVoiceKey)
                if not hadVoiceKey or not statusNode then
                    return 
                end

                -- 开始录音
                recordFilename = string.format("%s.spx", tostring(os.time()))
                local errno = CloudVoiceMng:StartRecording(recordFilename)
                isBeginRecord = errno == gv.GCloudVoiceErrno.GCLOUD_VOICE_SUCC
                touchBeginTime = Player:getCurrentTime()
            end)
        elseif event == ccui.TouchEventType.moved then
        	local touchPos = self.mInputBgSprite:convertToNodeSpace(sender:getTouchMovePosition())
		    if cc.rectContainsPoint(speechRect, touchPos) then
		    	statusNode:showSpeech()
		    else
		    	statusNode:cancelSpeech()
		    end
        elseif event == ccui.TouchEventType.ended then
            if not tolua.isnull(statusNode) then
	            statusNode:removeFromParent()
	            statusNode = nil
            end

            -- 结束录音并上传
            if isBeginRecord then
                CloudVoiceMng:StopRecording()
                local currTime = Player:getCurrentTime()
                if (currTime - touchBeginTime) >= 2 then -- 小于2秒不算
                    --记录该次发送消息的时间    
                    LastChatTime[self.mChatChanne] = currTime
                    local needToText = self.mInputMode == Enums.ChatInputMode.voiceTextInput
                    local btnText = needToText and TR("按住说话，自动转文字发送") or TR("按住说话，发送语音")
                    self:setChatCDTime(speechBtn, btnText)
                    -- 添加上传文件任务 
                    VoiceMsgTaskObj:addUploadTask(recordFilename)
                else
                    ui.showFlashView(TR("说话时间太短，无法识别"))
                    CloudVoiceMng:deleteRecordFile(recordFilename)
                end
            else
                if not VoiceMsgTaskObj:getHadVoiceKey() then
                    ui.showFlashView(TR("还未获取语音消息安全密钥信息")) 
                end
            end
            isBeginRecord = false
        elseif event == ccui.TouchEventType.canceled then
        	if not tolua.isnull(statusNode) then
	            statusNode:removeFromParent()
	            statusNode = nil
            end

            -- 结束录音，删除录制的文件
            if isBeginRecord then
                CloudVoiceMng:StopRecording()
                CloudVoiceMng:deleteRecordFile(recordFilename)
            end
            isBeginRecord = false
        end
    end)

	-- 语音模式切换
	-- local changeVoiceMode 

	-- -- 是否需要转文字切换按钮
	-- local modeChangeBtn = ui.newButton({
	-- 	normalImage = needToText and "lt_27.png" or "lt_07.png", 
	-- 	clickAction = function()
	-- 		if self.mInputMode == Enums.ChatInputMode.voiceTextInput then
	-- 			self.mInputMode = Enums.ChatInputMode.voiceInput
	-- 		else
	-- 			self.mInputMode = Enums.ChatInputMode.voiceTextInput
	-- 		end

 --            VoiceMsgTaskObj:setInputMode(self.mInputMode)
	-- 		changeVoiceMode()
	-- 	end
	-- })
	-- modeChangeBtn:setPosition(self.mViewSize.width - 58, self.mViewSize.height / 2)
	-- self.mInputBgSprite:addChild(modeChangeBtn)

	-- changeVoiceMode = function()
	-- 	-- 切换语音sdk的模式 和UI显示
	-- 	if self.mInputMode == Enums.ChatInputMode.voiceTextInput then
	-- 		modeChangeBtn:loadTextures("lt_27.png", "lt_27.png")
	-- 		speechBtn:setTitleText(TR("按住说话，自动转文字发送"))
	-- 	else
	-- 		modeChangeBtn:loadTextures("lt_27.png", "lt_27.png")
	-- 		speechBtn:setTitleText(TR("按住说话，发送语音"))
	-- 	end
	-- end
	-- changeVoiceMode()
end

-- 创建说话状态UI
function ChatEditView:createSpeechStatusUI()
	local retSprite = ui.newSprite("c_38.png")
	local retSize = retSprite:getContentSize()

	-- -- 描述label
	-- local hintLabel = ui.newLabel({
	-- 	text = TR("手指上滑，取消发送"),
	-- 	align = cc.TEXT_ALIGNMENT_CENTER,
 --        color = cc.c3b(0x72, 0x45, 0x1e),
	-- })
	-- hintLabel:setPosition(retSize.width / 2, -15)
	-- retSprite:addChild(hintLabel)

	retSprite.showSpeech = function()
        retSprite:setTexture("lt_39.png")
		-- hintLabel:setString(TR("手指上滑，取消发送"))
	end 

	retSprite.cancelSpeech = function()
		retSprite:setTexture("lt_38.png")
		-- hintLabel:setString(TR("松开手指，取消发送"))
	end

    retSprite:showSpeech()

	return retSprite
end

-- 创建表情选中弹窗
function ChatEditView:createFaceLayer(editBoxObj)
    local swallowNode = ccui.Widget:create()
    self:addChild(swallowNode)

    --点击任何区域关闭表情框
    ui.registerSwallowTouch({
        node = swallowNode,
        endedEvent = function(touch, event)
            swallowNode:removeFromParent()
        end,

        cancelledEvent = function(touch, event)
            swallowNode:removeFromParent()
        end,
    })

    local btnScale = 0.6  -- 表情需要缩放的比例
    local bqCount, rowCount = 40, 7  -- 表情的总个数和 每行的个数
    -- 表情的大小
    local faceSize = ui.getImageSize("bq_1.png") 
    -- 表情背景的大小
    local tempCount = math.ceil(bqCount / rowCount)
    local faceBgSize = cc.size((faceSize.width * btnScale + 5) * rowCount, tempCount * (faceSize.height * btnScale + 5)) 
    
    -- 创建表情的背景
    local faceBgSprite = ui.newScale9Sprite("c_17.png", faceBgSize)
    faceBgSprite:setAnchorPoint(0.5, 0)
    faceBgSprite:setPosition(self.mViewSize.width / 2, self.mViewSize.height)
    swallowNode:addChild(faceBgSprite)

    -- 创建表情
    local startPosX = faceSize.width * btnScale / 2
    local startPosY = faceBgSize.height - faceSize.height * btnScale / 2
    for i = 1, bqCount do
        local tempPosX = startPosX + math.mod(i - 1, rowCount) * (faceSize.width * btnScale + 5)
        local tempPosY = startPosY - math.floor((i - 1) / rowCount) * (faceSize.height * btnScale + 5)
        local tempBtn = ui.newButton({
            normalImage = string.format("bq_%d.png", i),
            clickAction = function()
                local tempStr = editBoxObj:getText()
                editBoxObj:setText(string.format("%s@%d ", tempStr, i))
            end,
        })
        tempBtn:setPosition(tempPosX, tempPosY)
        tempBtn:setScale(btnScale)
        faceBgSprite:addChild(tempBtn)
    end
end

-- 显示聊天的冷却时间
function ChatEditView:setChatCDTime(btnObj, btnText, channeType)
    channeType = channeType or self.mChatChanne
    if not btnObj:isEnabled() or not LastChatTime[channeType] then
        return 
    end
    
    btnObj:stopAllActions()
    Utility.schedule(btnObj, function( ... )
        local timeLeft = self.getChatCD(channeType) - (Player:getCurrentTime() - LastChatTime[channeType])
        if timeLeft > 0 then
            btnObj:setEnabled(false)
            local tempStr = btnText and string.format("%s(%d)", btnText, timeLeft) or tostring(timeLeft)
            btnObj:setTitleText(tempStr)
        else
            btnObj:stopAllActions()
            btnObj:setEnabled(true)
            btnObj:setTitleText(btnText or TR("发送"))
        end
    end, 1)
end

--检测发送消息是否合法 长度 时间 等检测
function ChatEditView:allowSendMsg(msgStr, voiceId, channeType)
    channeType = channeType or self.mChatChanne
    -- 网络是否连接
    if not ChatMng:isConnected() then
        ui.showFlashView(TR("网络未连接"))
        return
    end
    --检测模块是否开放
    if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eChat, true) then
        return 
    end

    --检测玩家是否在世界频道被禁言
    if channeType == Enums.ChatChanne.eWorld and PlayerAttrObj:getPlayerAttrByName("IfDisableSendMsg") then
        ui.showFlashView(TR("本服频道你被禁言"))
        return 
    end

    --检测玩家是否在跨服频道被禁言
    if channeType == Enums.ChatChanne.eCrossServer and PlayerAttrObj:getPlayerAttrByName("IfDisableSendMsg") then
        ui.showFlashView(TR("跨服频道你被禁言"))
        return 
    end

    --检测玩家是否在小喇叭频道被禁言
    if channeType == Enums.ChatChanne.eHorn and PlayerAttrObj:getPlayerAttrByName("IfDisableSendMsg") then
        ui.showFlashView(TR("跨服频道你被禁言"))
        return 
    end

    if channeType == Enums.ChatChanne.eUnion then
        local guildInfo = GuildObj:getGuildInfo()
        if guildInfo.Name == "" or not Utility.isEntityId(guildInfo.Id) then
            ui.showFlashView(TR("请创建或加入一个战盟"))
            return 
        end
    end

    if msgStr:utf8len() == 0 and (not voiceId or voiceId and voiceId:utf8len() == 0) then
        ui.showFlashView(TR("消息不能为空"))
        return 
    end

    local tempStr, msgLen = ChatMng:faceStrUnpack(msgStr)
    if msgLen > self.mMaxChatLen then
        ui.showFlashView(TR("请输入不超过%d个字", self.mMaxChatLen))
        return 
    end

    --不能发送6个或者6个以上的连续数字
    if channeType == Enums.ChatChanne.eWorld or channeType == Enums.ChatChanne.eCrossServer then
        if msgStr:find("%d%d%d%d%d%d%d%d%d") then
            ui.showFlashView(TR("请勿发送9位以上连续数字"))
            return 
        end
    end

    --冷却时间
    if LastChatTime[channeType] then
        local timeLeft = self.getChatCD(channeType) - (Player:getCurrentTime() - LastChatTime[channeType])
        timeLeft = math.ceil(timeLeft)
        if timeLeft > 0 then
            ui.showFlashView(TR("发送频繁,") .. TR("%d秒后重试", timeLeft))
            return 
        end
    end

    return true
end

--清理掉会引起json解析错误的字符
function ChatEditView:cleanStr(str)
    local replace = {
        {'"', "'"},
        {"\\", "\\\\"},
    }
    for k,v in pairs(replace) do
        str = str:gsub(v[1], v[2])
    end
    return str
end

-- 发送小喇叭信息按钮的点击事件
function ChatEditView:onMarqueeBtnClick()
    if not ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eChatHornCrossServicer) then
        ui.showFlashView({text = TR("功能暂未开放")})
        return
    end
    if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eChatHornCrossServicer, true) then
        return
    end

    local function DIYUiCallback(layer, layerBgSprite, layerSize)
        -- 发送小喇叭需要消耗的道具
        local useModelId = 16050086
        -- 
        local numCount = 80

        -- 发送喇叭信息的函数
        local function sendMsgFunc(msgStr)
            -- 检查小喇叭道具是否足够
            if GoodsObj:getCountByModelId(useModelId) < 1 then
                self:requestGetShopGoodsInfo(useModelId, true)
                return 
            end
            -- 去掉回车换行
            msgStr = string.gsub(msgStr or "", "[\r\n]+", "")

            if not self:allowSendMsg(msgStr) then
                return 
            end

            local tempNum = string.asciilen(msgStr)
            if tempNum > numCount then
                ui.showFlashView(TR("最多只能输入%d个字符", numCount))
                return 
            end
            -- 
            ChatMng:sendMessage(Enums.ChatChanne.eHorn, msgStr, "")
            LastChatTime[Enums.ChatChanne.eHorn] = Player:getCurrentTime()
            -- 
            LayerManager.removeLayer(layer)
        end

        -- 输入内容的背景
        local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(465, 180))
        tempSprite:setPosition(layerSize.width / 2, 182)
        layerBgSprite:addChild(tempSprite)

        -- 剩余输入字数提示
        local numLabel = ui.newLabel({
            text = TR("还可以输入%d字", numCount),
            size = 20,
            color = Enums.Color.eLabelText,
        })
        numLabel:setAnchorPoint(cc.p(0, 0.5))
        numLabel:setPosition(35, 118)
        layerBgSprite:addChild(numLabel)

        -- 小喇叭信息的输入框
        local msgEidtBox = ui.newEditBox({
            image = "lt_13.png",
            fontColor = Enums.Color.eBlack,
            fontSize = 22,
            size = cc.size(460, 125),
            listener = function(event, pSender)
                if event == "ended" then
                    local tempStr = pSender:getText()
                    tempStr = string.trim(self:cleanStr(tempStr))
                    pSender:setText(tempStr)
                elseif event == "changed" then
                    local tempStr = pSender:getText()
                    local tempNum = string.asciilen(tempStr)
                    numLabel:setString(TR("还可以输入%d字", math.max(numCount - tempNum, 0)))
                elseif event == "done" then
                    sendMsgFunc()
                end
            end,
        })
        msgEidtBox:setPosition(layerSize.width / 2, 200)
        msgEidtBox:setPlaceHolder(TR("点击输入文字"))
        msgEidtBox:setPlaceholderFontSize(24)
        msgEidtBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
        layerBgSprite:addChild(msgEidtBox)

        -- 提示信息分割线
        local tempSprite = ui.newScale9Sprite("lt_03.png", cc.size(442, 2))
        tempSprite:setPosition(layerSize.width / 2, 132)
        layerBgSprite:addChild(tempSprite)

        -- 发送按钮
        local sendBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("发送"),
            fontSize = 24,
            clickAction = function()
                sendMsgFunc(msgEidtBox:getText())
            end,
        })
        sendBtn:setPosition(layerSize.width / 2, 48)
        sendBtn:setScale(0.85)
        layerBgSprite:addChild(sendBtn)
        self:setChatCDTime(sendBtn, nil, Enums.ChatChanne.eHorn)

        -- 小喇叭数量
        local tempModel = GoodsModel.items[useModelId]
        local tempLabel = ui.createDaibiView({
            resourceTypeSub = tempModel.typeID,
            goodsModelId = useModelId,
            number = 1,
            showOwned = true,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(layerSize.width / 2 + 70, 48)
        layerBgSprite:addChild(tempLabel)
        local function setGoodsChange()
            tempLabel.setNumber(1)
        end
        Notification:registerAutoObserver(tempLabel, setGoodsChange, {EventsName.ePropRedDotPrefix .. tostring(useModelId)})
    end

    local layerData = {
        bgSize = cc.size(517, 333),
        title = TR("小喇叭"),
        msgText = "",
        closeBtnInfo = {},
        btnInfos = {},
        DIYUiCallback = DIYUiCallback,
        isNotAllowTouchOutClose = true,
    }
    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = layerData,
        zOrder = self.mForbidCleanUp and Enums.ZOrderType.ePopLayer or nil,
        cleanUp = false,
        allowSameName = true,
    })
end

-- ======================== 网络请求相关接口 ====================

-- 获取小喇叭的购买信息
function ChatEditView:requestGetShopGoodsInfo(goodsModelId, isNeedTip)
    HttpClient:request({
        moduleName = "ShopGoods",
        methodName = "GetShopGoodsInfo",
        svrMethodData = {Utility.getShopIdByModelId(goodsModelId)},
        callback = function(response)
            if response.Status == 0 then
                local zOrder = self.mForbidCleanUp and Enums.ZOrderType.ePopLayer or nil
                if isNeedTip then
                    MsgBoxLayer.addBuyGoodsLayer(TR("提示"), response.Value[1], function(hintLayer)
                        hintLayer:removeFromParent()

                        MsgBoxLayer.addBuyGoodsCountLayer(TR("购买"), response.Value[1], function(selCount, layerObj, btnObj)
                            if selCount == 0 then return end
                            layerObj:removeFromParent()
                            self:requestBuyGoods(goodsModelId, selCount)
                        end, true, zOrder)
                    end, true, zOrder)
                else
                    MsgBoxLayer.addBuyGoodsCountLayer(TR("购买"), response.Value[1], function(selCount, layerObj, btnObj)
                        if selCount == 0 then return end
                        layerObj:removeFromParent()
                        self:requestBuyGoods(goodsModelId, selCount)
                    end,
                    true, zOrder)
                end
            end
        end
    })
end

-- 道具购买请求
function ChatEditView:requestBuyGoods(goodsModelId, selCount)
    HttpClient:request({
        moduleName = "ShopGoods",
        methodName = "BuyGoods",
        svrMethodData = {Utility.getShopIdByModelId(goodsModelId), selCount},
        callback = function(response)
            if response.Status == 0 then
                ui.showFlashView(TR("购买成功"))
            end
        end
    })
end

return ChatEditView