-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      留言回复
-- <br/> 2019年6月22日
-- --------------------------------------------------------------------
RoleMessageBoardReplyPanel = RoleMessageBoardReplyPanel or BaseClass(BaseView)

local controller = RoleController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local string_len =  string.len
local string_find =  string.find
local string_sub =  string.sub


function RoleMessageBoardReplyPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "roleinfo/role_message_board_reply_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    local max_count = 48
    local config = Config.RoomGrowData.data_const.bbs_writing_number
    if config then
        max_count = config.val
    end
    self.limit_sad_count = max_count 
    -- self.limit_sad_count = 10

    -- self.default_content_msg = string_format(TI18N("回复留言, 最多%s字"), max_count)
    self.default_content_msg = TI18N("回复:")
    self.content_str = ""
end

function RoleMessageBoardReplyPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("留言回复"))

    self.close_btn = self.main_panel:getChildByName("close_btn")

    local res = PathTool.getResFrame("common","common_99998")
    self.label_content = createRichLabel(22, Config.ColorData.data_color4[151], cc.p(0,1), cc.p(52,344), 6, nil, 580)
    self.label_content:setString(self.default_content_msg)
    self.main_container:addChild(self.label_content)
    --内容输入框
    self.edit_content = createEditBox(self.main_container, res, cc.size(580,200), nil, 22, nil, 22, "", nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_content:setAnchorPoint(cc.p(0,1))
    self.edit_content:setPlaceholderFontColor(Config.ColorData.data_color4[63])
    self.edit_content:setFontColor(Config.ColorData.data_color4[66])
    self.edit_content:setPosition(cc.p(52,344))
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if self.begin_change_label then  
                self.begin_change_label = false
                self.label_content:setVisible(true)
                local str = pSender:getText()
                pSender:setText("")
                if str ~= "" then
                    self:setLabelContent(str)
                else
                    self.label_content:setString(self.default_content_msg)
                end 

            end
        elseif strEventName == "began" then
            if not self.begin_change_label then
                self.label_content:setVisible(false)
                self.begin_change_label = true
            end
            if self.content_str ~= nil and self.content_str ~= "" then
                pSender:setText(self.content_str) 
            end
        elseif strEventName == "changed" then

        end
    end
    self.edit_content:registerScriptEditBoxHandler(editBoxTextEventHandle)

    self.limit_count = self.main_container:getChildByName("limit_count")
    self.limit_count:setString(string_format(TI18N("限制%s字以内"), self.limit_sad_count))

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("回 复"))

    self.face_btn = self.main_container:getChildByName("face_btn")
    self.face_btn:getChildByName("label"):setString(TI18N("添加表情"))
end

function RoleMessageBoardReplyPanel:register_event()
    -- registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.comfirm_btn, handler(self, self.onClickBtnComfirm) ,true, 1)
    registerButtonEventListener(self.face_btn, handler(self, self.onClickBtnFace) ,true, 1)

    self:addGlobalEvent(EventId.CHAT_SELECT_FACE, function(face_id, from_name)
        if from_name and from_name == ChatConst.ChatInputType.eMessageBoardReplyPanel then
            if self.content_str == nil then
                self.content_str = ""
            end
            self.content_str = self.content_str..face_id
            self:setLabelContent(self.content_str)
            local count = WordCensor:getInstance():relapceFaceIconTag(self.content_str)[1] or 0
            GlobalEvent:getInstance():Fire(ChatEvent.FACE_COUNT_EVENT, count)
        end
        
    end)
    self:addGlobalEvent(RoleEvent.ROLE_MESSAGE_BOARD_REPLY_EVENT, function(data)
        if data.result == TRUE then
            self:onClickBtnClose()
        end
    end)
end

function RoleMessageBoardReplyPanel:setLabelContent(str)
    if not str then return end
    if StringUtil.SubStringGetTotalIndex(str) > self.limit_sad_count then
        str = StringUtil.SubStringUTF8(str, 1, self.limit_sad_count)
    end
    self.content_str = str
    self.label_content:setString(str)
end

--提交
function RoleMessageBoardReplyPanel:onClickBtnComfirm()
    if not self.rid or not self.srv_id or not self.bbs_id then return end
    if self.content_str == nil or self.content_str == "" then
        message(TI18N("请输入回复内容"))
        return
    end

    controller:send25836(self.rid, self.srv_id, self.bbs_id, self.content_str)
end

--关闭
function RoleMessageBoardReplyPanel:onClickBtnClose()
    controller:openRoleMessageBoardReplyPanel(false)
end

--添加表情
function RoleMessageBoardReplyPanel:onClickBtnFace()
    local world_pos = self.face_btn:convertToWorldSpace(cc.p(0, 0))
    local setting = {}
    setting.world_pos = world_pos
    setting.offset_y = -328
    RefController:getInstance():openView(ChatConst.ChatInputType.eMessageBoardReplyPanel, setting, ChatConst.Channel.Province)
end


function RoleMessageBoardReplyPanel:openRootWnd(setting)
    local setting = setting or {}
    local name = setting.name or "玩家"
    self.rid = setting.rid
    self.srv_id = setting.srv_id
    self.bbs_id = setting.bbs_id

    self.default_content_msg = string_format(TI18N("回复%s:"), name)
    if self.label_content then
        self.label_content:setString(self.default_content_msg)
    end
end


function RoleMessageBoardReplyPanel:close_callback()
    controller:openRoleMessageBoardReplyPanel(false)
end