-- @Author: lwj
-- @Date:   2019-06-24 17:24:23
-- @Last Modified time: 2019-06-25 10:03:08

ServiceView = ServiceView or class("ServiceView", BaseItem)
local ServiceView = ServiceView

function ServiceView:ctor(parent_node, layer)
    self.abName = "mail"
    self.assetName = "ServiceView"
    self.layer = layer

    self.model = MailModel.GetInstance()
    self.tog_list = {}
    BaseItem.Load(self)
end

function ServiceView:dctor()
    self:StopMySchedule()

    if self.send_cd then
        if self.send_cd > 1 then
            self.model:Brocast(MailEvent.StartSendCD, self.send_cd)
        end
    end

    if self.tog_list then
        for i, v in pairs(self.tog_list) do
            if v then
                v:destroy()
            end
        end
        self.tog_list = {}
    end

    if self.change_title_event_id then
        self.model:RemoveListener(self.change_title_event_id)
        self.change_title_event_id = nil
    end
end

function ServiceView:LoadCallBack()
    self.nodes = {
        "ser_qq", "branch", "Group/ServiceMenuItem", "P_Input/p_qq", "P_Input_1/p_phone", "Group", "btn_sub", "P_Input_2/p_title", "P_Input_3/p_des", "pic",
        "P_Input_2",
        "P_Input_3", "P_Input", "P_Input_1", "btn_sub/btn_text",
    }
    self:GetChildren(self.nodes)
    self.ser_qq = GetText(self.ser_qq)
    self.branch = GetText(self.branch)
    self.p_qq = GetText(self.p_qq)
    self.tog_obj = self.ServiceMenuItem.gameObject
    self.p_phone = GetText(self.p_phone)
    self.title = GetText(self.p_title)
    self.p_des = GetText(self.p_des)
    self.pic = GetImage(self.pic)
    self.ipt_title = GetInputField(self.P_Input_2)
    self.ipt_qq = GetInputField(self.P_Input)
    self.ipt_phone = GetInputField(self.P_Input_1)
    self.ipt_des = GetInputField(self.P_Input_3)
    self.btn_img = GetImage(self.btn_sub)
    self.btn_text = GetText(self.btn_text)
    self.send_cd = 0

    local remain = self.model.res_time
    if remain and remain > 1 then
        self:StartSendCd()
    end

    self:AddEvent()
    self:InitPanel()
end

function ServiceView:AddEvent()
    self.change_title_event_id = self.model:AddListener(MailEvent.ServiceTogClick, handler(self, self.HandleTogClick))

    local function callback()
        --local url = self.model.service_url .. "?key=" .. self.model.service_key
        if self.model.is_startting_send_cd then
            Notify.ShowText(ConfigLanguage.Mail.PleaseWaitAMinit)
        else
            local cur_con = self.p_des.text
            if cur_con == "" then
                Notify.ShowText(ConfigLanguage.Mail.PleaseWriteDownTheCon)
                return
            end
            local cur_title_name = self.title.text
            if cur_title_name == "" then
                self.ipt_title.text = self.model.cur_ser_title
            end
            local url = self.model.service_url
            local form = WWWForm()
            local role_data = RoleInfoModel.GetInstance():GetMainRoleData()
            local sign = Util.md5(role_data.suid .. role_data.id .. self.model.cur_ser_id .. os.time() .. self.model.service_key)
            form:AddField("sign", sign)
            form:AddField("content", self.p_des.text)
            form:AddField("title", self.title.text)
            form:AddField("mobile", self.p_phone.text)
            form:AddField("qq", self.p_qq.text)
            form:AddField('sid', role_data.suid)
            form:AddField('role_id', role_data.id)
            form:AddField('type', self.model.cur_ser_id)
            form:AddField('ts', os.time())

            local function cb(t)
                --dump(t, "<color=#6ce19b>ServiceSend   ServiceSend  ServiceSend  ServiceSend</color>")
                self.ipt_qq.text = ""
                self.ipt_title.text = self.model.cur_ser_title
                self.ipt_phone.text = ""
                self.ipt_des.text = ""
                Notify.ShowText(ConfigLanguage.Mail.SuccessToSend)
                self:StartSendCd()
            end
            HttpManager:ResponsePost(url, cb, form)
        end
    end
    AddButtonEvent(self.btn_sub.gameObject, callback)
end

function ServiceView:InitPanel()
    self:LoadTogItem()
    --self.ser_qq.text = string.format(ConfigLanguage.Mail.ServiceKouKou, 233333333)
    --self.branch.text = string.format(ConfigLanguage.Mail.GameBranch, "10086.996.233")
end

function ServiceView:LoadTogItem()
    for i = 1, 3 do
        local item = ServiceMenuItem(self.tog_obj, self.Group)
        local data = "In-game issues"
        if i == 2 then
            data = "Recharge"
        elseif i == 3 then
            data = "Feedback"
        end
        item:SetData(data, i)
        self.tog_list[#self.tog_list + 1] = item
    end
end

function ServiceView:HandleTogClick(str)
    if self.title.text == "" or self.title.text == self.model.last_ser_title then
        self.ipt_title.text = str
    end
    self.p_des.text = ""
end

function ServiceView:StartSendCd()
    ShaderManager:GetInstance():SetImageGray(self.btn_img)
    self.send_cd = 10
    if self.model.res_time > 1 then
        self.send_cd = self.model.res_time
    end
    self.model.is_startting_send_cd = true
    self:StopMySchedule()
    self.btn_text.text = self.send_cd .. "Refresh in X sec"
    self.schedule = GlobalSchedule.StartFun(handler(self, self.BeginningCD), 1, -1)
end

function ServiceView:BeginningCD()
    if self.send_cd > 1 then
        self.model.is_startting_send_cd = true
        self.send_cd = self.send_cd - 1
        self.btn_text.text = self.send_cd .. "Refresh in X sec"
    else
        self:StopMySchedule()
        ShaderManager:GetInstance():SetImageNormal(self.btn_img)
        self.btn_text.text = "Submit"
        self.model.is_startting_send_cd = false
    end
end

function ServiceView:StopMySchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
end