OtherWelfareComPanel = OtherWelfareComPanel or class("OtherWelfareComPanel", BasePanel)
local this = OtherWelfareComPanel

function OtherWelfareComPanel:ctor(parent_node, parent_panel)
    self.abName = "otherwelfare"
    self.assetName = "OtherWelfareComPanel"
    self.layer = LayerManager.LayerNameList.UI

    self.use_background = true
    self.change_scene_close = true
    self.click_bg_close = true
    self.is_hide_other_panel = true
    self.events = {}
    self.itemicon = {}
    self.model = OtherWelfareModel:GetInstance()

end

function OtherWelfareComPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.scheduleId then
        GlobalSchedule:Stop(self.scheduleId)
    end
    self.scheduleId = nil

    if not table.isempty(self.itemicon) then
        for i, v in pairs(self.itemicon) do
            v:destroy()
        end
        self.itemicon = {}
    end

end

function OtherWelfareComPanel:Open()
    OtherWelfareComPanel.super.Open(self)
end

function OtherWelfareComPanel:LoadCallBack()
    self.nodes = {
        "goBtn","iconParent","closeBtn","lqBtn",
    }
    self:GetChildren(self.nodes)
    SetVisible(self.lqBtn,false)
    self:InitUI()
    self:AddEvent()
end

function OtherWelfareComPanel:InitUI()
    self:CreateIcon()
end

function OtherWelfareComPanel:AddEvent()
    
    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)
    local function call_back()
        PlatformManager:GetInstance():comment()

        local function call_back1()
            SetVisible(self.lqBtn,true)
            SetVisible(self.goBtn,false)
        end
        self.scheduleId = GlobalSchedule:StartOnce(call_back1,0.5)
    end
    AddClickEvent(self.goBtn.gameObject,call_back)
    
    local function call_back()
        WelfareController:GetInstance():ReqeustMiscRewardInfo(1)
    end
    AddClickEvent(self.lqBtn.gameObject,call_back)



    self.events[#self.events + 1] = GlobalEvent:AddListener(OtherWelfareEvent.MiscRewardInfo,handler(self,self.MiscRewardInfo))
end

function OtherWelfareComPanel:MiscRewardInfo(data)
    if data.type == 1 then
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "Rating", false)
        --Notify.ShowText("領取成功")
        self:Close()
    end

end

function OtherWelfareComPanel:CreateIcon()
    local  reward = self.model:GetRewardCfg(1)
    for i = 1, #reward do
        --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        end
        local param = {}

        param["model"] = self.model
        param["item_id"] = reward[i][1]
        param["num"] = reward[i][2]
        param["can_click"] = true
        self.itemicon[i]:SetIcon(param)
    end

end