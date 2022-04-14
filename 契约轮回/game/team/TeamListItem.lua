TeamListItem = TeamListItem or class("TeamListItem", BaseItem)
local TeamListItem = TeamListItem

function TeamListItem:ctor(parent_node, layer)
    self.abName = "team"
    self.assetName = "TeamListItem"
    self.layer = layer

    self.model = TeamModel:GetInstance()
    self.vipTxts = {}
    TeamListItem.super.Load(self)
end

function TeamListItem:dctor()

    if self.event_id then
        self.model:RemoveListener(self.event_id)
        self.event_id = nil
    end
end

function TeamListItem:LoadCallBack()
    self.nodes = {
        "level",
        "limit_level",
        "level/lv_value",
        "info/name",
        "role_icon",
        "num",
        "target",
        "btn_apply",
        "btn_apply/Text",

        "info/vip",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    self.role_icon_img = self.role_icon:GetComponent('Image')
    self.level_img = self.level:GetComponent('Image')
    self.lv_value_txt = self.lv_value:GetComponent('Text')
    self.limit_level_txt = self.limit_level:GetComponent('Text')
    self.vip = GetText(self.vip)

    self:UpdateView()
end

function TeamListItem:AddEvent()
    local function call_back(target, x, y)
        local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
        if roleData.level >= self.data.min_level then
            TeamController:GetInstance():RequestApply(self.data.id)
        else
            Notify.ShowText(ConfigLanguage.Team.NotLevel)
        end

    end
    AddClickEvent(self.btn_apply.gameObject, call_back)

    local function call_back()
        self:UpdateApplyBtn()
    end
    self.event_id = self.model:AddListener(TeamEvent.ApplyTeamSuccess, call_back)
end

function TeamListItem:SetData(data, index)
    self.data = data
    self.index = index
    if self.is_loaded then
        self:UpdateView()
    end
end

function TeamListItem:SetPosition()
    local rectTra = self.transform:GetComponent('RectTransform')
    rectTra.anchoredPosition = Vector2(0, -self:GetHeight() * (self.index - 1))
end
function TeamListItem:UpdateApplyBtn()
    local apply_team_ids = self.model:GetApplyTeamIds()
    if apply_team_ids[self.data.id] then
        self.Text:GetComponent('Text').text = ConfigLanguage.Team.TeamApplied
    else
        self.Text:GetComponent('Text').text = ConfigLanguage.Team.TeamApply
    end
end

function TeamListItem:UpdateView()
    if self.data then
        self:SetPosition()
        self.target:GetComponent('Text').text = Config.db_team_target_sub[self.data.type_id].name
        self.num:GetComponent('Text').text = "(" .. string.format(ConfigLanguage.Team.TeamNum, #self.data.members) .. ")"
        local captain = self.model:GetCaptain(self.data)
        self.lv_value_txt.text = GetLevelShow(captain.level)
        self.limit_level_txt.text = "(Lv " .. self.data.min_level .. "~" .. self.data.max_level .. ")"
        local team_info = self.model:GetTeamInfo()
        if (team_info and team_info.id == self.data.id) or #self.data.members >= 3 then
            SetVisible(self.btn_apply, false)
        else
            SetVisible(self.btn_apply, true)
        end
        self:UpdateApplyBtn()

        self.vip.text = string.format(ConfigLanguage.Common.Vip, captain.viplv)

        if captain.gender == 2 then
            self.name:GetComponent('Text').text = string.format("<color=#b23636>%s</color>", captain.name)
            lua_resMgr:SetImageTexture(self, self.role_icon_img, "common_image", "sex_icon_2")
            lua_resMgr:SetImageTexture(self, self.level_img, "team_image", "team_role_bg_2", true)
        else
            self.name:GetComponent('Text').text = string.format("<color=#2e7299>%s</color>", captain.name)
            lua_resMgr:SetImageTexture(self, self.role_icon_img, "common_image", "sex_icon_1")
            lua_resMgr:SetImageTexture(self, self.level_img, "team_image", "team_role_bg_1", true)
        end
    end
end

function TeamListItem:GetHeight()
    return 100
end