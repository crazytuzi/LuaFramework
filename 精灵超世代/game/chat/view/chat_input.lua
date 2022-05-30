--聊天输入/语音切换组件
--author:hp

ChatInput = ChatInput or class("ChatInput", function()
	return ccui.Widget:create()
end)

function ChatInput:ctor(from, default_msg)
    self.from_name = from or "chatPanel"
    self.ctrl = ChatController:getInstance()
    -- 文字太长，界面放不下 [2021/9/30 pjl]
    -- self.default_msg = default_msg or TI18N("请输入，长按玩家头像可快捷@人")
    self.default_msg = default_msg or TI18N("")
    self.input_model = 1 -- 当前输入方式 1为键盘，2为语音
    self:initView()
    self:initCtrl()
end

function ChatInput:initView()
    local height = 62 -- 整体高度
    local editSize = cc.size(287,height)
    local voiceBtnSize = cc.size(287,height)
    if self.from_name == "chatPanel" then
        height = 62
        editSize = cc.size(331,60)
        voiceBtnSize = cc.size(498,height)
    elseif self.from_name == "chatWindow" or self.from_name == ChatConst.ChatInputType.eArenateam then
        height = 62
        editSize = cc.size(331,60)
        voiceBtnSize = cc.size(412,height)
    end

    --self.model_btn = CustomButton.New(self,PathTool.getResFrame("mainui", "mainui_chat_sound_icon"),nil,nil,LOADTEXT_TYPE_PLIST)
    --self.model_btn:setAnchorPoint(0.5,0.5)
    --self.model_btn:setPosition(cc.p(-26,12))
    --self.model_btn:setVisible(IS_SHOW_VOICE)
    
    self.edit_box = createEditBox(self, PathTool.getResFrame("common", "common_1002"),editSize, nil, 22, Config.ColorData.data_new_color4[6], 20, self.default_msg, nil, nil, LOADTEXT_TYPE_PLIST, nil, nil--[[, cc.KEYBOARD_RETURNTYPE_SEND]])
    self.edit_box:setAnchorPoint(cc.p(0,0))
    self.edit_box:setPlaceholderFontColor(ChatConst.MianInputColor)
    self.edit_box:setFontColor(Config.ColorData.data_color4[66])
    self.edit_box:setPosition(18,-18)
    self.edit_box:setMaxLength(40)

    --self.voice_btn = CustomButton.New(self,PathTool.getResFrame("mainui", "mainui_chat_btn_1"),nil,nil,LOADTEXT_TYPE_PLIST)
    --self.voice_btn:setAnchorPoint(0.5,0.5)
    --self.voice_btn:setPosition(cc.p(16+voiceBtnSize.width/2,voiceBtnSize.height/2-20))
    --self.voice_btn:setSize(voiceBtnSize)
    --local voiceStr = string.format("<div fontcolor=#643223 >%s</div>", TI18N("长按输入语音"))
    --self.voice_btn:setRichText(voiceStr,24)
    --self.voice_btn:setVisible(false)

    -- local function editBoxTextEventHandle(strEventName,pSender)
        -- if strEventName == "return" then
        -- elseif strEventName == "ended" then
        -- else
        -- end
    -- end
    -- self.edit_box:registerScriptEditBoxHandler(editBoxTextEventHandle)

    self.link_btn = CustomButton.New(self.edit_box,PathTool.getResFrame("commonicon", "mainui_chat_face_icon"),nil,nil,LOADTEXT_TYPE_PLIST)
    self.link_btn:setAnchorPoint(0.5,0.5)
    self.link_btn:setPosition(cc.p(self.edit_box:getPositionX()+editSize.width+24,editSize.height/2))
end

-- 切换输入方式
function ChatInput:changeInputModel(  )
    if IS_IOS_PLATFORM == true then
        -- message("语音暂不可用!")
        return
    end

    if self.input_model == 1 then
        self.input_model = 2
        local res = PathTool.getResFrame("mainui", "mainui_chat_keybord_icon")
        self.model_btn:loadTextures(PathTool.getResFrame("mainui", "mainui_chat_keybord_icon"), "", "", LOADTEXT_TYPE_PLIST)
    else
        self.input_model = 1
        self.model_btn:loadTextures(PathTool.getResFrame("mainui", "mainui_chat_sound_icon"), "", "", LOADTEXT_TYPE_PLIST)
    end

    self.link_btn:setVisible(self.input_model == 1)
    self.edit_box:setVisible(self.input_model == 1)
    --self.voice_btn:setVisible(self.input_model == 2)
end

function ChatInput:initCtrl()
    -- self.voice_btn:addTouchEventListener(function(sender, event)
    --    if IS_IOS_PLATFORM == true then
    --        -- message("语音暂不可用!")
    --    else
    --        if self.voice_func then
    --            self.voice_func(sender, event)
    --        end
    --    endrole_setname_view
    --end)

    --self.model_btn:addTouchEventListener(function(sender, event)
    --    if event == ccui.TouchEventType.ended then
    --        self:changeInputModel()
    --    end
    --end)

    self.link_btn:addTouchEventListener(function( sender,eventType )
        if eventType == ccui.TouchEventType.ended then
            local world_pos = self.link_btn.layout:convertToWorldSpace(cc.p(0, 0))
            local setting = {}
            setting.world_pos = world_pos
            setting.offset_y = 78
            RefController:getInstance():openView(self.from_name, setting, self.chat_channel)
        end    
    end)
end

function ChatInput:showVoice(bool)
    --self.model_btn:setVisible(not bool)
    --self.edit_box:setVisible(not bool)
    --self.link_btn:setVisible(not bool)
end

-- 设置文本回调
function ChatInput:setInputFunc(func)
    self.input_func = func
end

-- 点击语音回调
function ChatInput:setVoiceFunc(func)
    self.voice_func = func
end

-- 文本框内容
function ChatInput:getInputText()
    return self.edit_box:getText(), self.extend
end

function ChatInput:setInputText(str, extend)
    self.extend = extend
    if self.edit_box then
        if not str then
            str=""
        end
        -- self.edit_box._text_ = str
        self.edit_box:setText(str)
    end
end

-- 文本框内容是否为空
function ChatInput:isNothing()
    local text = self.edit_box:getText()
    if text == "" or text == self.default_msg then
        return true
    end
end

--设置当前聊天频道
function ChatInput:setChatChannel( channel )
    self.chat_channel = channel
end