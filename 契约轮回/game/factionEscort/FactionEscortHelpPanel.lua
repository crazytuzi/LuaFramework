FactionEscortHelpPanel = FactionEscortHelpPanel or class("FactionEscortHelpPanel", WindowPanel)

function FactionEscortHelpPanel:ctor()
    self.abName = "factionEscort"
    self.assetName = "FactionEscortHelpPanel"
    self.layer = "UI"
    self.panel_type = 4							--窗体样式  1 1280*720  2 850*545
    self.Events = {} --事件
    self.items = {}
    self.model = FactionEscortModel:GetInstance()

end

function FactionEscortHelpPanel:dctor()
    GlobalEvent.RemoveTabEventListener(self.Events)
    for i, v in pairs(self.items) do
        v:destroy()
    end
end

function FactionEscortHelpPanel:Open()
    FactionEscortHelpPanel.super.Open(self)
end

function FactionEscortHelpPanel:LoadCallBack()
    self.nodes =
    {
        "FactionEscortHelpItem","itemScrollView/Viewport/itemContent","okBtn","NoObj",
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self:AddEvent()
    self:InitUI()
end

function FactionEscortHelpPanel:AddEvent()
    self.Events[#self.Events +  1] =  GlobalEvent:AddListener(FactionEscortEvent.FactionEscortClickHelpBtn, handler(self, self.FactionEscortClickHelpBtn))
end

function FactionEscortHelpPanel:InitUI()
    self.members =  FactionModel:GetInstance():GetMember()
    table.sort(self.members, function(a,b)   --战力由大到小排序
            return a.base.power > b.base.power
    end)
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    for i = 1, #self.members do
        if role.id ~= self.members[i].base.id then  --不包括自己
            self.items[i] = FactionEscortHelpItem(self.FactionEscortHelpItem.gameObject,self.itemContent,"UI")
            self.items[i]:SetData(self.members[i])
        end
    end
   -- dump(self.members)
end

function FactionEscortHelpPanel:FactionEscortClickHelpBtn(item)
   -- dump(item)
   -- print2(item.name)
end