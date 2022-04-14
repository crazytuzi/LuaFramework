---
--- Created by  Administrator
--- DateTime: 2020/6/22 19:15
---
ArtifactPageItem = ArtifactPageItem or class("ArtifactPageItem", BaseCloneItem)
local this = ArtifactPageItem

function ArtifactPageItem:ctor(obj, parent_node, parent_panel)
    ArtifactPageItem.super.Load(self)
    self.events = {}
    self.model = ArtifactModel:GetInstance()
end

function ArtifactPageItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function ArtifactPageItem:LoadCallBack()
    self.nodes = {
        "sel_img","Image","MenuText"
    }
    self:GetChildren(self.nodes)
    self.Image = GetImage(self.Image)
    self.MenuText = GetText(self.MenuText)
    self:InitUI()
    self:AddEvent()
end

function ArtifactPageItem:InitUI()

end

function ArtifactPageItem:AddEvent()

    local function call_back()
        self.model:Brocast(ArtifactEvent.PageItemClick,self.data);
    end
    AddClickEvent(self.Image.gameObject,call_back)
end

function ArtifactPageItem:SetData(data)
    self.data = data
    self.MenuText.text = self.model:GetTypeName(self.data)
    lua_resMgr:SetImageTexture(self, self.Image, "iconasset/icon_artifact", "artifact_t_"..self.data)
end

function ArtifactPageItem:SetSelect(isShow)
    SetVisible(self.sel_img,isShow)
end

function ArtifactPageItem:SetRedPoint(IsShow)
    if not  self.red then
        self.red = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.red:SetPosition(136, 29)
    end
    self.red:SetRedDotParam(IsShow)
end