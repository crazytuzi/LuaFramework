---
--- Created by  Administrator
--- DateTime: 2019/8/19 14:57
---
WarriorEndPanel = WarriorEndPanel or class("WarriorEndPanel", BasePanel)
local this = WarriorEndPanel

function WarriorEndPanel:ctor(parent_node, parent_panel)
    self.abName = "Warrior";
    self.assetName = "WarriorEndPanel"
    self.layer = "Top"
    self.events = {}
    self.model = WarriorModel:GetInstance()
    self.itemicon = {}

end

function WarriorEndPanel:Open(data)
    self.data = data
    WindowPanel.Open(self)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
end

function WarriorEndPanel:dctor()
    if self.endItem then
        self.endItem:destroy()
    end
    GlobalEvent:RemoveTabListener(self.events)
end

function WarriorEndPanel:LoadCallBack()
    self.nodes = {
        "obj/floorTex","obj/iconParent","obj/scoreTex","obj/rankTex",
    }
    self:GetChildren(self.nodes)
    self.floorTex = GetText(self.floorTex)
    self.scoreTex = GetText(self.scoreTex)
    self.rankTex = GetText(self.rankTex)
    self:InitUI()
    self:AddEvent()
end

function WarriorEndPanel:InitUI()
    local data = {}
    data.isClear =  true
    data.IsCancelAutoSchedule = false
    data.layer = "UI"
    self.endItem = DungeonEndItem(self.transform, data);
    self.endItem:StartAutoClose(5)

    local floor = self.data.floor
    local rank = self.data.rank
    local score = self.data.score
    self.floorTex.text = string.format("Improved to F%s",floor)
    self.rankTex.text = string.format("Point rankings：<color=#41f345>%s</color>",rank)
    self.scoreTex.text = string.format("Personal points：<color=#41f345>%s</color>",score)
    self:CreatIcons()

end

function WarriorEndPanel:AddEvent()
    local function call_back()
        local  scene_data = SceneManager:GetInstance():GetSceneInfo()
        if self.model:IsWarriorScene(scene_data.scene) then
            SceneControler:GetInstance():RequestSceneLeave();
        end
        self:Close()
    end
    self.endItem:SetCloseCallBack(call_back);
    self.endItem:SetAutoCloseCallBack(call_back)
end

function WarriorEndPanel:CreatIcons()
    local cfg = self.model:GetRewardCfg(self.data.rank)
    local rewardTab = String2Table(cfg.gain)
    if   self.data.is_cross == 1 then --是跨服
        rewardTab = String2Table(cfg.cross_gain)
    end
    for i = 1, #rewardTab do
        --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        end
        local param = {}
        param["model"] = BagModel
        param["item_id"] = rewardTab[i][1]
        param["num"] = rewardTab[i][2]
        --param["bind"] = rewardTab[i][3]
        param["can_click"] = true
        param["size"] = {x = 78,y = 78}
        self.itemicon[i]:SetIcon(param)
    end
end