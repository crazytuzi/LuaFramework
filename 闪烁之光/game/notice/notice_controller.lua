-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-08-08
-- --------------------------------------------------------------------
NoticeController = NoticeController or BaseClass(BaseController)

function NoticeController:config()
    self.model = NoticeModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function NoticeController:getModel()
    return self.model
end

function NoticeController:registerEvents()
end

function NoticeController:registerProtocals()
    self:RegisterProtocal(10810, "handle10810")  --发送反馈
    self:RegisterProtocal(10811, "handle10811")  --发送反馈
    --self:RegisterProtocal(10812, "handle10812")  --反馈状态
    self:RegisterProtocal(10813, "handle10813")  --反馈记录
    self:RegisterProtocal(10814, "handle10814")  --反馈详情
end

-- 发送反馈
function NoticeController:sender10810(issue_type, title, content, phone, email, phone_info, id)
    local protocal = {}
    protocal.issue_type = issue_type or ""
    protocal.title = title or "" 
    protocal.content = content or ""
    protocal.phone = phone or ""
    protocal.email = email or ""
    protocal.phone_info = phone_info
    protocal.id = id or 0
    self:SendProtocal(10810,protocal)
end

-- 反馈是否成功
function NoticeController:handle10810(data)
    message(data.msg)
    if data ~= nil and next(data) ~= nil then
        self.dispather:Fire(NoticeEvent.Feedback_Success_Event, data)
    end
end
-- 发送反馈
function NoticeController:sender10811(id, score)
    local protocal = {}
    protocal.id = id
    protocal.score = score
    self:SendProtocal(10811,protocal)
end

-- 反馈是否成功
function NoticeController:handle10811( data )
    if data ~= nil and next(data) ~= nil then
        self.dispather:Fire(NoticeEvent.Feedback_Evaluate_Success_Event, data)
    end
end

-- -- 发送反馈
-- function NoticeController:sender10812(issue_type, title, content, phone, email, phone_info, id)
--     local protocal = {}
--     protocal.issue_type = issue_type
--     protocal.title = title
--     protocal.content = content
--     protocal.phone = phone
--     protocal.email = email
--     protocal.phone_info = phone_info
--     protocal.id = id or 0
--     self:SendProtocal(10812,protocal)
-- end

-- -- 反馈是否成功
-- function NoticeController:handle10812( data )
--     message(data.msg)
-- end

-- 获取反馈列表
function NoticeController:sender10813()
    self:SendProtocal(10813,{})
end

function NoticeController:handle10813( data )
    if data ~= nil and next(data) ~= nil then
        self.model:setFeedBackData(data)
        self.dispather:Fire(NoticeEvent.All_Feedback_Event_Data)
    end
end

-- 获取反馈记录详情
function NoticeController:sender10814( id )
    local protocal = {}
    protocal.id = id
    self:SendProtocal(10814,protocal)
end

-- 内容列表
function NoticeController:handle10814(data)
     if data ~= nil and next(data) ~= nil then
        self.model:setContentData(data)
        self.dispather:Fire(NoticeEvent.All_Question_Info_List_Event)
    end
end

--打开游戏公告
--默认请url请传nil值，改url为邮件超链接情况传值
function NoticeController:openNoticeView( url)
    if not self.notice_view then
        self.notice_view = NoticeWindow.New( url)
    end
    if not self.notice_view:isOpen() then
        self.notice_view:open()
    end
end
function NoticeController:closeNoticeView()
    if self.notice_view then 
        self.notice_view:close()
        self.notice_view = nil
    end
end

function NoticeController:setNoticeContent(str)
    self.notice_content = str
end

function NoticeController:getNoticeContent()
    return self.notice_content
end

--打开bug反馈
-- function NoticeController:openBugPanel()
--     if not self.bug_panel then
--         self.bug_panel = BugPanel.New()
--     end
--     if not self.bug_panel:isOpen() then
--         self.bug_panel:open()
--     end
-- end

-- 打开新版bug反馈(客服中心)
function NoticeController:openServiceCenterWindow(status, sub_type)
    if status == true then
        if not self.service_center_window then
            self.service_center_window = ServiceCenterWindow.New()
        end
        if self.service_center_window:isOpen() == false then
            self.service_center_window:open(sub_type)
        end
    else
        if self.service_center_window then
            self.service_center_window:close()
            self.service_center_window = nil
        end
    end
end

-- 打开新版bug反馈(客服中心)
function NoticeController:openFeedbackDetailWindow(status, id, title, state)
    if status == true then
        if not self.feedback_detail_window then
            self.feedback_detail_window = FeedbackDetailWindow.New()
        end
        if self.feedback_detail_window:isOpen() == false then
            self.feedback_detail_window:open(id, title, state)
        end
    else
        if self.feedback_detail_window then
            self.feedback_detail_window:close()
            self.feedback_detail_window = nil
        end
    end
end

function NoticeController:closeBugPanel()
    if self.bug_panel then 
        self.bug_panel:close()
        self.bug_panel = nil
    end
end

function NoticeController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end