--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年10月20日
-- @description    : 
        -- 聊天
---------------------------------
ArenateamChatPanel = ArenateamChatPanel or BaseClass(BaseView)

local controller = ArenateamController:getInstance()
local model = controller:getModel()

local ref_controller = RefController:getInstance()
local chat_controller = ChatController:getInstance()

local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format

function ArenateamChatPanel:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arenateam_hall", "arenateam_hall"), type = ResourcesType.plist}
    }
    self.layout_name = "arenateam/arenateam_chat_panel"

    self.item_desc_list = {} 
    self.item_code_list = {}

    self.default_msg = TI18N("请输入信息...")

    self.time = 0
end

function ArenateamChatPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)

    local main_panel = self.main_container:getChildByName("main_panel")

    self.close_btn = self.main_container:getChildByName("close_btn")

    
    -- self:createTabBtnList()
     --频道背景
    -- self.main_container_size = self.main_container:getContentSize()
    local buttomBg = createScale9Sprite(PathTool.getResFrame("mainui","mainui_chat_bottom_bg"),0,0,LOADTEXT_TYPE_PLIST,self.main_container)
    local buttonBg_size = cc.size(680,75)
    buttomBg:setContentSize(buttonBg_size)
    buttomBg:setAnchorPoint(0.5,0)
    buttomBg:setPosition(cc.p(360,230))

    -- self.container_size = cc.size(self.main_container_size.width-22,self.main_container_size.height- buttonBg_size.height-9)
    --提示文字
    self.notice_label = createLabel(22,Config.ColorData.data_color4[58],nil,buttonBg_size.width/2,buttonBg_size.height/2,TI18N("该频道下无法发言"),buttomBg)
    self.notice_label:setAnchorPoint(0.5,0.5)
    self.notice_label:setVisible(false)
    --发送按钮
    self.btn_send = CustomButton.New(buttomBg, PathTool.getResFrame("common", "common_1017"), PathTool.getResFrame("common", "common_1017"),nil,LOADTEXT_TYPE_PLIST)
    self.btn_send:setBtnLableColor(Config.ColorData.data_color4[1])
    self.btn_send:setSize(cc.size(155,62))
    self.btn_send:setLabelSize(26)

    -- self.btn_send:getButton():setScaleX(0.8)
    self.btn_send:setPosition(cc.p(590,buttonBg_size.height/2))
    self.btn_send:setBtnLabel(TI18N("发送"))
    self.btn_send:getLabel():enableOutline(cc.c3b(108,43,0),2)
    self.btn_send:setLocalZOrder(4)

    --输入组件
    self.chat_input = ChatInput.new(ChatConst.ChatInputType.eArenateam, self.default_msg)
    self.chat_input:setPosition(78, buttonBg_size.height/2-12)
    self.chat_input:setInputFunc(function()
        self:onSendBtn()
    end)
    self.chat_input:setVoiceFunc(function(sender, event)
        self:beginRecord(sender, event)
    end)
    buttomBg:addChild(self.chat_input, 5)

    self.lay_srollview = self.main_container:getChildByName("lay_srollview")
    local size = self.lay_srollview:getContentSize()
    self.scroll = NewCoseList.new(size, self.lay_srollview)
    self.scroll:setPosition(cc.p(0,0))
    self.scroll.msg_bg:setPositionY(15)
    self.lay_srollview:addChild(self.scroll)
end

function ArenateamChatPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)

    -- registerButtonEventListener(self.btn_send, function() self:onSendBtn() end ,true, 1)
     --发送按钮
    handleTouchEnded(self.btn_send, function()
        self:onSendBtn()
    end)


    --添加表情
    self:addGlobalEvent(EventId.CHAT_SELECT_FACE, function(face_id, from_name)
        if from_name and from_name == ChatConst.ChatInputType.eArenateam then
            self:onEditTextAddFace(face_id)
        end
    end)

    --添加物品
    self:addGlobalEvent(EventId.CHAT_SELECT_ITEM, function(data, from_name)
        if from_name and from_name == ChatConst.ChatInputType.eArenateam then
            self:onEditTextAddItem(data)
        end
    end)

    --更新聊天
    self:addGlobalEvent(EventId.CHAT_UDMSG_WORLD, function(channel)
        if channel and channel == ChatConst.Channel.Team or channel == ChatConst.Channel.Team_Sys then 
            self:updateChat()
        end
    end)
end

--关闭
function ArenateamChatPanel:onClosedBtn()
    controller:openArenateamChatPanel(false)
end

function ArenateamChatPanel:onEditTextAddFace(face_id)
    if not self.chat_input then return end
    local text = self.chat_input:getInputText()
    if text == self.default_msg then
        text = ""
    end
    local content_str = text..face_id
    self.chat_input:setInputText(content_str)

    local count = WordCensor:getInstance():relapceFaceIconTag(content_str)[1] or 0
    GlobalEvent:getInstance():Fire(ChatEvent.FACE_COUNT_EVENT, count)
end

-- 输入框添加表情
function ArenateamChatPanel:onEditTextAddItem(data)
    if data == nil then return end

    local text = self.chat_input:getInputText()
    if text == self.default_msg then
        text = ""
    end

    -- 如果没有文字内容，则清一下数据
    if text == "" then
        self.item_desc_list = {} 
        self.item_code_list = {}
    end

    local base_id = data.base_id
    local share_id = data.share_id
    local count = data.count
    local role_vo =  RoleController:getInstance():getRoleVo()
    local item_config = Config.ItemData.data_get_data(base_id)
    local code = data.code

    if item_config then
        local key = string.format("{%s,%s}", share_id, item_config.name)
        local desc = ref_controller:buildItemMsg(base_id, role_vo.srv_id, share_id, count)

        if self.item_code_list[code] then
            local cur_object = self.item_code_list[code]
            local cur_key = cur_object.key
            local cur_desc = cur_object.desc

            -- 获取原有的
            text = string.gsub(text, cur_key, key, 1)
        else
            text = text..key
        end
        self.item_code_list[code] = {key=key, desc=desc}

        self.item_desc_list[key] = desc
        self.chat_input:setInputText(text)
    end
end 

--发送
function ArenateamChatPanel:onSendBtn()
    local text, srv_id = self.chat_input:getInputText()
    if self.chat_input:isNothing() then
        message(TI18N("请输入聊天信息"))
        return
    end

    local data = WordCensor:getInstance():relapceFaceIconTag(text)
    if data[1] > 5 then
        message(TI18N("发言中不能超过5个表情"))
        return
    end

    text = WordCensor:getInstance():relpaceChatTag(text)
    -- 展示物品替换
    if self.item_desc_list and next(self.item_desc_list) then
        for k,v in pairs(self.item_desc_list) do
            text = string.gsub(text, k, v, 1)
        end
    end
    if self.time == 0 or  GameNet:getInstance():getTime() - self.time > 1 then
        self.time =  GameNet:getInstance():getTime()
        local is_success = chat_controller:sendChatMsg(ChatConst.Channel.Team, 0, text)
        if is_success then
            self:cleatInputText()
        end
    end
end

function ArenateamChatPanel:cleatInputText()
    self.chat_input:setInputText("")
    self.item_desc_list = {}
    self.item_code_list = {} 
end

-- 录音
function ArenateamChatPanel:beginRecord(sender, event)
    local channel = ChatConst.Channel.Team
    ChatHelp.RecordTouched(sender, event, channel)
end

function ArenateamChatPanel:openRootWnd(setting)
    local setting = setting or {}
    local index = setting.index or ArenateamConst.AddPlayerTabType.eApplyList
    -- 开始了

    local data_list = ChatController:getInstance().stack_list[ChatConst.Channel.Team]
    self.scroll:createMsg(data_list, 1)
end

function ArenateamChatPanel:updateChat()
    if self.scroll then
        self.scroll:SetEnabled(true)
        self.scroll:initData(chat_controller.stack_list[ChatConst.Channel.Team])
        self.scroll:updateMsg()
    end
end

function ArenateamChatPanel:close_callback()

    model:setIsChatRedpoint(false)
    controller:openArenateamChatPanel(false)
end