---
--- Created by  Administrator
--- DateTime: 2019/10/24 17:39
---
BannerPanel = BannerPanel or class("BannerPanel", BasePanel)
local this = BannerPanel

function BannerPanel:ctor()
    self.abName = "banner"
    self.assetName = "BannerPanel"
    self.layer = "UI"
    self.events = {}
    self.use_background = true
    self.itemicon = {}
    self.model = BannerModel.GetInstance()
end


function BannerPanel:Open(remain)
    BannerPanel.super.Open(self)
end


function BannerPanel:dctor()
    if self.effect then
        self.effect:destroy()
    end
    TaskModel.GetInstance():RemoveTabListener(self.events)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
end

function BannerPanel:LoadCallBack()
    self.nodes = {
        "btn","Image","EffectParent","closeBtn","iconParent",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
   -- self:PlayAni()
    --self.info = TaskModel:GetInstance():GetTask(10000)
    self:CreateIcon()

end

function BannerPanel:PlayAni()
    local action = cc.ScaleTo(0.4, 0.85)
    action = cc.Sequence(action, cc.ScaleTo(0.4, 1))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.Image)

end



function BannerPanel:InitUI()
    --self.effect = UIEffect(self.EffectParent, 10123, false)
    --self.effect:SetConfig({ is_loop = true ,})
end

function BannerPanel:CloseCallBack()
    TaskController:GetInstance():RequestTaskSubmit(10000)
end

function BannerPanel:AddEvent()
    --AutoTaskManager:GetInstance():SetAutoTaskState(false)
    local function call_back()
       -- TaskController:GetInstance():RequestTaskSubmit(10000)
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)
    
    local function call_back()
        --TaskController:GetInstance():RequestTaskSubmit(10000)
        self:Close()
    end
    AddButtonEvent(self.btn.gameObject,call_back)

   -- local function call_back()
   --     self:Close()
   -- end
   --self.events[#self.events + 1] =  TaskModel.GetInstance():AddListener(TaskEvent.DoTask,call_back)
end

function BannerPanel:CreateIcon()
    self.itemicon = {}
    local cfg = Config.db_task[self.model.taskId]
    if not cfg then
        return
    end
    local rewardTab = String2Table(cfg.gain)
    for i = 1, #rewardTab do
        local param = {}
        param["item_id"] = rewardTab[i][1]
        param["num"] = rewardTab[i][2]
        param["model"] = BagModel
        param["can_click"] = true
        param["show_num"] = true
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        end
        self.itemicon[i]:SetIcon(param)
    end
end