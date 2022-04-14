-- @Author: lwj
-- @Date:   2019-04-28 15:12:44
-- @Last Modified time: 2019-04-28 15:13:00

WantedPanel = WantedPanel or class("WantedPanel", BasePanel)
local WantedPanel = WantedPanel

function WantedPanel:ctor()
    self.abName = "wanted"
    self.assetName = "WantedPanel"
    self.layer = "UI"

    self.is_show_open_action = true

    self.model = WantedModel.GetInstance()
    self.panel_type = 2
    self.use_background = true
    self.click_bg_close = true
end

function WantedPanel:dctor()

end

function WantedPanel:Open()
    WantedPanel.super.Open(self)
end

function WantedPanel:LoadCallBack()
    self.nodes = {
        "btn_go/btn_text", "icon", "des_img", "condition", "skill_bg", "btn_go", "btn_close",
        "btn_go/gray_text", "red_con",
    }
    self:GetChildren(self.nodes)
    self.btn_text = GetText(self.btn_text)
    self.btn_img = GetImage(self.btn_go)
    self.icon = GetImage(self.icon)
    self.des = GetImage(self.des_img)
    self.condition = GetText(self.condition)
    self.skill_bg = GetImage(self.skill_bg)

    self:AddEvent()
    self:InitPanel()
end

function WantedPanel:AddEvent()
    AddButtonEvent(self.btn_close.gameObject, handler(self, self.Close))

    local function callback()
        local mode = self.model.btn_mode
        if mode == 1 then
            local type = self.cf.link_type
            if type == 1 then
            elseif type == 2 then
            elseif type == 3 then
                local tbl = String2Table(self.cf.link)[1]
                OpenLink(unpack(tbl))
                self:Close()
            end
        elseif mode == 2 then
            self.model:Brocast(WantedEvent.FetchReward)
        elseif mode == 3 then
            Notify.ShowText("Claimed")
        end
    end
    AddButtonEvent(self.btn_go.gameObject, callback)

    local function callback()
        local tip = lua_panelMgr:GetPanelOrCreate(TipsSkillPanel)
        tip:Open()
        tip:SetId(self.cf.skill, self.icon.transform)
    end
    AddClickEvent(self.icon.gameObject, callback)

    self.update_panel_event_id = self.model:AddListener(WantedEvent.UpdateWantedPanel, handler(self, self.InitPanel))
end

function WantedPanel:OpenCallBack()
end

function WantedPanel:InitPanel()
    self.info = self.model:GetInfo()
    self.cf = Config.db_wanted[self.info.id]
    self:UpdateView()
end

function WantedPanel:UpdateView()
    --local skill_id = self.cf.skill
    --local skill_cf = Config.db_skill[skill_id]
    lua_resMgr:SetImageTexture(self, self.icon, "wanted_image", "icon_" .. self.cf.skill, false, nil, false)
    lua_resMgr:SetImageTexture(self, self.des, "wanted_image", "name_" .. self.cf.skill, false, nil, false)
    lua_resMgr:SetImageTexture(self, self.skill_bg, "wanted_image", "bg_" .. self.cf.skill, false, nil, false)
    local color_str = "ff2a2a"
    if self.info.state == enum.WANTED_TASK_STATE.WANTED_TASK_STATE_FINISH then
        color_str = "0cfd2e"
    end
    if self.cf.id == 1 then

        local tar = String2Table(self.cf.show)[1]
        self.condition.text = string.format(ConfigLanguage.Wanted.ArriveToLevels, ChineseNumber(tar), color_str, self.info.progress, tar)
    else
        local tbl = String2Table(self.cf.show)
        local lv = tbl[1]
        local tar = tbl[2]
        self.condition.text = string.format(ConfigLanguage.Wanted.DefeatWorldBoss, lv, tar, color_str, self.info.progress, tar)
    end
    if self.info.state == enum.WANTED_TASK_STATE.WANTED_TASK_STATE_UNDONE then
        self.model.btn_mode = 1
        self.btn_text.text = ConfigLanguage.Wanted.GoAndFinish
        self:SetRedDot(false)
    elseif self.info.state == enum.WANTED_TASK_STATE.WANTED_TASK_STATE_FINISH then
        self.model.btn_mode = 2
        self.btn_text.text = ConfigLanguage.Wanted.FetchReward
        self:SetRedDot(true)
    elseif self.info.state == enum.WANTED_TASK_STATE.WANTED_TASK_STATE_REWARD then
        ShaderManager.GetInstance():SetImageGray(self.btn_img)
        SetVisible(self.gray_text, true)
        SetVisible(self.btn_text, false)
        self.model.btn_mode = 3
        self.btn_text.text = ConfigLanguage.Wanted.AlreadyFetched
        self:SetRedDot(false)
    end
end

function WantedPanel:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end

function WantedPanel:CloseCallBack()
    WantedController.GetInstance():IsShowMainRD()
    if self.update_panel_event_id then
        self.model:RemoveListener(self.update_panel_event_id)
        self.update_panel_event_id = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

