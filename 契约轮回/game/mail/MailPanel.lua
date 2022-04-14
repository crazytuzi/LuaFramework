--
-- @Author: chk
-- @Date:   2018-09-08 19:47:33
--

MailPanel = MailPanel or class("MailPanel", WindowPanel)
local MailPanel = MailPanel

function MailPanel:ctor()
    self.abName = "mail"
    self.assetName = "MailPanel"
    self.layer = "UI"

    self.panel_type = 2
    self.use_background = true
    self.is_exist_always = false
    self.model = MailModel:GetInstance()

    --[[self.show_sidebar = true        --是否显示侧边栏
    if self.show_sidebar then
        -- 侧边栏配置
        self.sidebar_data = {
            { text = ConfigLanguage.Mail.Friend, id = 1, img_title = "mail:mail_friend_f", },
            { text = ConfigLanguage.Mail.Mail, id = 2, img_title = "mail:mail_mail_f", },
            { text = ConfigLanguage.Mail.Service, id = 3, img_title = "mail:mail_service_f", },
        }
    end]]--

    local roleData = RoleInfoModel.Instance:GetMainRoleData()
    Chkprint("角色id____", roleData.id)
end

function MailPanel:dctor()
    if self.mail_view ~= nil then
        self.mail_view:destroy()
    end
    if self.friend_view then
        self.friend_view:destroy()
    end
    if self.service_view then
        self.service_view:destroy()
        self.service_view = nil
    end
    self.model.viewContainer = nil
end

function MailPanel:Open(index, sub_index)
    self.default_table_index = index or 1
    self.sub_index = sub_index
    MailPanel.super.Open(self)
end

function MailPanel:OnEnable()
    self.default_table_index = self.model.crntIndex or 1
    self.sub_index = self.sub_index
    if self.is_load_cb then
        if self.bg_win ~= nil then
            self.bg_win:SetTabIndex(self.default_table_index)
        end

        self:SwitchCallBack(self.default_table_index)
    else
        self.need_load_end = true
    end

    --	self.transform:SetAsLastSibling()
end

function MailPanel:LoadCallBack()
    self.nodes = {
        "viewContainer",
        "panelContain",
        "btnContain/frendBtn",
        "btnContain/mailBtn",
        "btnContain/feedBackBtn",
        "btnContain/frendBtn/friendSelect",
        "btnContain/mailBtn/mailSelect",
        "btnContain/feedBackBtn/feedbackSelect",
        "CloseBtn",
    }
    self:GetChildren(self.nodes)

    self:AddEvent()

    self.model.viewContainer = self.viewContainer
    --self:SwitchPanel(self.model.crntIndex)
    self.is_load_cb = true
end

function MailPanel:AddEvent()
    local function call_back(target, x, y)
        self:Close()
    end
    AddClickEvent(self.CloseBtn.gameObject, call_back)
end

function MailPanel:OpenCallBack()
    self:UpdateView()
end

function MailPanel:UpdateView()
    self:SetTabIndex(self.default_table_index)
end

function MailPanel:CloseCallBack()

end

function MailPanel:SwitchCallBack(index)
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    self.model.crntIndex = index
    if index == 2 then
        if not self.mail_view then
            self.mail_view = MailView(self.panelContain, "UI")
        end
        self:PopUpChild(self.mail_view)
    elseif index == 1 then
        if not self.friend_view then
            self.friend_view = FriendView(self.panelContain, "UI", self.sub_index)
        else
            self.friend_view:UpdateShow(self.sub_index)
        end
        self:PopUpChild(self.friend_view)
    elseif index == 3 then
        if not self.service_view then
            self.service_view = ServiceView(self.panelContain, "UI")
        end
        self:PopUpChild(self.service_view)
    end
end

function MailPanel:IsShow()
    return self.isShow
end

