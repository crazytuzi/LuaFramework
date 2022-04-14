---
--- Created by  Administrator
--- DateTime: 2019/7/10 14:45
---
MarryDivorcePanel = MarryDivorcePanel or class("MarryDivorcePanel", BasePanel)
local this = MarryDivorcePanel

function MarryDivorcePanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "MarryDivorcePanel"
    self.layer = LayerManager.LayerNameList.UI
    self.use_background = true
    self.change_scene_close = true
    self.events = {}
    self.items = {}
    self.model = MarryModel:GetInstance()
end

function MarryDivorcePanel:dctor()
    self.model:RemoveTabListener(self.events)
end

function MarryDivorcePanel:LoadCallBack()
    self.nodes = {
        "ok_Btn","closeBtn"
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function MarryDivorcePanel:InitUI()

end

function MarryDivorcePanel:AddEvent()

    local function call_back()

        Dialog.ShowTwo("Tip", "Are you sure you want to divorce?", "Confirm", handler(self, self.OK_CallBack), nil, "Cancel", nil, nil)
       -- MarryController:GetInstance():RequsetDivorce()
    end
    AddClickEvent(self.ok_Btn.gameObject,call_back)
    
    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.DivorceSuscc,handler(self,self.DivorceSuscc))
end

function MarryDivorcePanel:OK_CallBack()
    MarryController:GetInstance():RequsetDivorce()
end

function MarryDivorcePanel:DivorceSuscc()
    self:Close()
end