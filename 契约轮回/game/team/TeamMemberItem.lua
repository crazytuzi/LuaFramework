TeamMemberItem = TeamMemberItem or class("TeamMemberItem", BaseCloneItem)
local TeamMemberItem = TeamMemberItem

function TeamMemberItem:ctor(obj, parent_node, layer)
    --[[	self.abName = "main"
        self.assetName = "TeamMemberItem"
        self.layer = layer--]]

    self.model = TeamModel:GetInstance()
    TeamMemberItem.super.Load(self)
end

function TeamMemberItem:dctor()
    if self.lv_item then
        self.lv_item:destroy()
        self.lv_item = nil
    end
end

function TeamMemberItem:LoadCallBack()
    self.nodes = {
        "lv_con",
        "name",
        "location"
    }
    self:GetChildren(self.nodes)
    self:AddEvent()

    --self:UpdateView()
end

function TeamMemberItem:AddEvent()
    local function call_back(target, x, y)
        lua_panelMgr:GetInstance():GetPanelOrCreate(MyTeamPanel):Open()
    end
    AddClickEvent(self.gameObject, call_back)
end

function TeamMemberItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function TeamMemberItem:UpdateView()
    local role = self.data.role
    --self.level:GetComponent('Text').text = string.format(ConfigLanguage.Team.Level, role.level)
    if not self.lv_item then
        self.lv_item = LevelShowItem(self.lv_con, "UI")
        self.lv_item:SetData(18, role.level, "FFF7E5")
    else
        self.lv_item:UpdateLevel(role.level)
    end
    --self.level:GetComponent('Text').text = GetLevelShow(role.level, )
    self.name:GetComponent('Text').text = role.name
    local my_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
    local MyMember = self.model:GetMember(my_role_id)
    if self.data.is_online == 1 then
        if my_role_id == role.id
                or self.data.scene_id == MyMember.scene_id
                or faker:is_fake(role.id) then
            lua_resMgr:SetImageTexture(self, self.location:GetComponent('Image'), "team_image", "team_location_n", true)
        else
            lua_resMgr:SetImageTexture(self, self.location:GetComponent('Image'), "team_image", "team_location_f", true)
        end
    else
        lua_resMgr:SetImageTexture(self, self.location:GetComponent('Image'), "team_image", "team_location_o", true)
    end

end

function TeamMemberItem:GetHeight()
    return 50
end