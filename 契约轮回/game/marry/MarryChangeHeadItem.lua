---
--- Created by  Administrator
--- DateTime: 2019/7/16 21:30
---
MarryChangeHeadItem = MarryChangeHeadItem or class("MarryChangeHeadItem", BaseCloneItem)
local this = MarryChangeHeadItem

function MarryChangeHeadItem:ctor(obj, parent_node, parent_panel)
    MarryChangeHeadItem.super.Load(self)
    self.events = {}
    self.model = MarryModel:GetInstance()
    self.role =  RoleInfoModel.GetInstance():GetMainRoleData()
end

function MarryChangeHeadItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function MarryChangeHeadItem:LoadCallBack()
    self.nodes = {
        "headKuang","head","select"
    }
    self:GetChildren(self.nodes)
    self.head = GetImage(self.head)
    self:InitUI()
    self:AddEvent()
end

function MarryChangeHeadItem:InitUI()

end

function MarryChangeHeadItem:AddEvent()
    local function call_back()
        self.model:Brocast(MarryEvent.MarryClickHead,self.data)
    end
    AddClickEvent(self.headKuang.gameObject,call_back)
end

function MarryChangeHeadItem:SetData(data)
    self.data = data
    local gender = self.role.gender
    self.headName = "2"..data
    if gender == 1 then
        --role_image_11
        self.headName = "1"..data
    end
    lua_resMgr:SetImageTexture(self, self.head, "main_image", self.headName, true, nil, false)
end
function MarryChangeHeadItem:SetSelect(isShow)
    SetVisible(self.select,isShow)
end