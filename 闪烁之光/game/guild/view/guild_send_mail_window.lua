-------------------------------------
-- @Author: zj@qqg.com
-- @Date:   2019-06-03 11:48:31
-- @Description: 公会发送邮件面板
-------------------------------------
GuildSendMailWindow = GuildSendMailWindow or BaseClass(BaseView)

local controller = GuildController:getInstance()
local model = GuildController:getInstance():getModel()
local string_format = string.format

function GuildSendMailWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.win_type = WinType.Mini
	self.set_index = 1
	self.condition_index = 1
	self.layout_name = "guild/guild_send_mail_window"

    self.default_title_msg = TI18N("@all")
    self.default_content_msg = TI18N("点击输入邮件内容，字数不能超过100")
end

function GuildSendMailWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale()) 

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    self.btn_close = container:getChildByName("btn_close")
    self.btn_send = container:getChildByName("btn_send")

    self.btn_send:getChildByName("label"):setString(TI18N("发  送"))
    container:getChildByName("win_title"):setString(TI18N("发送邮件"))

    container:getChildByName("txt_send_name"):setString(self.default_title_msg) 
    container:getChildByName("txt_send_name_title"):setString(TI18N("收件人id:"))
    container:getChildByName("txt_send_cont_title"):setString(TI18N("内容:")) 

    self.label_content = createRichLabel(24, Config.ColorData.data_color4[151], cc.p(0,1), cc.p(40, 560), 6, nil, 550)
    self.label_content:setString(self.default_content_msg)
    container:addChild(self.label_content)

    local res = PathTool.getResFrame("common", "common_99998")
    self.edit_cont = createEditBox(container, res, cc.size(550, 440), nil, 24, nil, 24, nil, nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_cont:setAnchorPoint(cc.p(0, 1))
    self.edit_cont:setFontColor(Config.ColorData.data_color4[175])
    self.edit_cont:setPosition(cc.p(35, 565))
    self.edit_cont:setMaxLength(100)
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if self.begin_change_label then  
                self.begin_change_label = false
                self.label_content:setVisible(true)
                local str = pSender:getText()
                pSender:setText("")  
                if str ~= "" and str ~= self.content_str then
                    self.content_str = str
                    if self.label_content then
                        self.label_content:setString(str)
                    end
                end 
            end
        elseif strEventName == "began" then
            if not self.begin_change_label then
                self.label_content:setVisible(false)
                self.begin_change_label = true
            end
        end
    end
    self.edit_cont:registerScriptEditBoxHandler(editBoxTextEventHandle) 
end

function GuildSendMailWindow:register_event()
    registerButtonEventListener(self.background, function()
        controller:openGuildSendMailWindow(false)
    end, false, 2)

    registerButtonEventListener(self.btn_close, function()
        controller:openGuildSendMailWindow(false)
    end, false, 2)

    registerButtonEventListener(self.btn_send, function()
        local content = self.content_str or ""
        if string.len(content) == 0 or content == self.default_content_msg then 
            message(TI18N("请输入邮件内容"))
            return
        end
        controller:send13580(content)
        controller:openGuildSendMailWindow(false)
    end, true, 1)
end

function GuildSendMailWindow:openRootWnd()
end

function GuildSendMailWindow:close_callback()
    controller:openGuildSendMailWindow(false)
end

