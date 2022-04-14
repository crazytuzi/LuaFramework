---
--- Created by  Administrator
--- DateTime: 2020/4/15 19:19
---
RichManPointPanel = RichManPointPanel or class("RichManPointPanel", BasePanel)
local this = RichManPointPanel

function RichManPointPanel:ctor(parent_node, parent_panel)
    self.abName = "richman"
    self.assetName = "RichManPointPanel"
    self.image_ab = "richman_image";
    self.layer = "UI"
    self.use_background = true
    self.show_sidebar = false
   -- self.click_bg_close = true
    self.seleces = {}
    self.model = RichManModel:GetInstance()
end

function RichManPointPanel:dctor()
    --GlobalEvent:RemoveTabListener(self.events)
    self.seleces = {}
end

function RichManPointPanel:LoadCallBack()
    self.nodes = {
        "n_4","closeBtn","n_3/n_3_s","n_5","n_2/n_2_s","n_2","n_1","n_6/n_6_s","n_1/n_1_s","n_3","n_4/n_4_s","n_5/n_5_s","n_6",
        "okBtn"
    }
    self:GetChildren(self.nodes)
    self.seleces[1] = self.n_1_s
    self.seleces[2] = self.n_2_s
    self.seleces[3] = self.n_3_s
    self.seleces[4] = self.n_4_s
    self.seleces[5] = self.n_5_s
    self.seleces[6] = self.n_6_s
    self:InitUI()
    self:AddEvent()
    self:SetSelect(1)
end

function RichManPointPanel:InitUI()

end

function RichManPointPanel:AddEvent()

    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)

    for i = 1, 6 do
        local function call_back(name)
            self:SetSelect(i)
        end
        AddClickEvent(self["n_"..i].gameObject,call_back)
    end
    local function call_back()
        self.model:Brocast(RichManEvent.RichManTouZiClick,self.selectPoint)
        self:Close()
    end
    AddButtonEvent(self.okBtn.gameObject,call_back)

end

function RichManPointPanel:SetSelect(index)
    for i = 1, #self.seleces do
        if i == index then
            SetVisible(self.seleces[i],true)
            self.selectPoint = index
           -- self.model:Brocast(RichManEvent.RichManTouZiClick,index)
        else
            SetVisible(self.seleces[i],false)
        end
    end
  --  SetVisible( self[name.."_s"],true)

end