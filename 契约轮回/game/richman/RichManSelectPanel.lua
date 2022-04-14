---
--- Created by  Administrator
--- DateTime: 2020/4/15 19:11
---
RichManSelectPanel = RichManSelectPanel or class("RichManSelectPanel", BasePanel)
local this = RichManSelectPanel

function RichManSelectPanel:ctor(parent_node, parent_panel)
    self.abName = "richman"
    self.assetName = "RichManSelectPanel"
    self.image_ab = "richman_image";
    self.layer = "UI"
    self.use_background = true
    self.show_sidebar = false
    --self.click_bg_close = true

    self.model = RichManModel:GetInstance()
end

function RichManSelectPanel:dctor()
    --GlobalEvent:RemoveTabListener(self.events)
end

function RichManSelectPanel:LoadCallBack()
    self.nodes = {
        "yktouzi/yktouziBg","touzi/touziBg","closeBtn"
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function RichManSelectPanel:InitUI()

end

function RichManSelectPanel:AddEvent()

    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)
    local function call_back()
        self:Close()
        self.model:Brocast(RichManEvent.RichManTouZiSelect,1)
    end
    AddClickEvent(self.touziBg.gameObject,call_back)

    local function call_back()
        self:Close()
        self.model:Brocast(RichManEvent.RichManTouZiSelect,2)
    end
    AddClickEvent(self.yktouziBg.gameObject,call_back)
end