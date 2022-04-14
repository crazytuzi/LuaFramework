EnterDungeonItem = EnterDungeonItem or class("EnterDungeonItem", BaseCloneItem)
local EnterDungeonItem = EnterDungeonItem

function EnterDungeonItem:ctor(obj, parent_node, layer)
    EnterDungeonItem.super.Load(self)

end

function EnterDungeonItem:dctor()
    if self.event_id then
        self.model:RemoveListener(self.event_id)
        self.event_id = nil
    end
    if self.role_icon then
        self.role_icon:destroy()
    end
end

function EnterDungeonItem:LoadCallBack()
    self.nodes = {
        "roleIcon", "check", "name", "check/checked", "merge"
    }
    self.model = TeamModel:GetInstance()
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.merge = GetText(self.merge)
    --self.roleIcon = GetImage(self.roleIcon)
    self:AddEvent()
end

function EnterDungeonItem:AddEvent()
    local function call_back()
        self:UpdateAgree()
    end
    self.event_id = self.model:AddListener(TeamEvent.EnterDungeAsk, call_back)
end

--data:#p_team_member
function EnterDungeonItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function EnterDungeonItem:UpdateView()
    local role = self.data.role
    local param = {}
    param['is_can_click'] = false
    param["is_squared"] = false
    param["is_hide_frame"] = false
    param["size"] = 75
    param["role_data"] = role
    if not self.role_icon then
        self.role_icon = RoleIcon(self.roleIcon)
    end
    self.role_icon:SetData(param)

    self.name.text = role.name
    self:UpdateAgree()
end

function EnterDungeonItem:UpdateAgree()
    if self.model:IsAgree(self.data.role_id) then
        SetVisible(self.checked, true)
    else
        SetVisible(self.checked, false)
    end
    local merge_count = self.model.merges[self.data.role_id] or 0
    if merge_count > 1 then
        SetVisible(self.merge, true)
        self.merge.text = string.format("Merge %s times", merge_count)
    else
        SetVisible(self.merge, false)
    end
end