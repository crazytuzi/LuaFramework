OtherWelfareBindPanel = OtherWelfareBindPanel or class("OtherWelfareBindPanel", BasePanel)
local this = OtherWelfareBindPanel

function OtherWelfareBindPanel:ctor(parent_node, parent_panel)
    self.abName = "otherwelfare"
    self.assetName = "OtherWelfareBindPanel"
    self.layer = LayerManager.LayerNameList.UI

    self.use_background = true
    self.change_scene_close = true
    self.click_bg_close = true
    self.is_hide_other_panel = true
    self.events = {}
    self.itemicon = {}
    self.model = OtherWelfareModel:GetInstance()

end

function OtherWelfareBindPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if not table.isempty(self.itemicon) then
        for i, v in pairs(self.itemicon) do
            v:destroy()
        end
        self.itemicon = {}
    end
end

function OtherWelfareBindPanel:Open()
    OtherWelfareBindPanel.super.Open(self)
end

function OtherWelfareBindPanel:LoadCallBack()
    self.nodes = {
        "btn_close","goBtn","des","iconParent","lqBtn"
    }
    self:GetChildren(self.nodes)
    self:InitUI()
    self:AddEvent()
end

function OtherWelfareBindPanel:InitUI()
    self:CreateIcon();
    if self.model.emailBindState == 0 then --未绑定
        SetVisible(self.goBtn,true)
        SetVisible(self.lqBtn,false)
    else
        SetVisible(self.goBtn,false)
        SetVisible(self.lqBtn,true)
    end
end

function OtherWelfareBindPanel:AddEvent()
    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.btn_close.gameObject,call_back)

    local function call_back()
        PlatformManager:GetInstance():ShowUserCenter()
       -- WelfareController:GetInstance():ReqeustMiscRewardInfo(4)
    end
    AddClickEvent(self.goBtn.gameObject,call_back)
    
    local function call_back()
        WelfareController:GetInstance():ReqeustMiscRewardInfo(4)
    end
    AddClickEvent(self.lqBtn.gameObject,call_back)
    local function call_back()
       -- self:Close()
        SetVisible(self.goBtn,false)
        SetVisible(self.lqBtn,true)
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.BindEmailInfo,call_back)
    self.events[#self.events + 1] = GlobalEvent:AddListener(OtherWelfareEvent.MiscRewardInfo,handler(self,self.MiscRewardInfo))

end

function OtherWelfareBindPanel:BindEmailInfo()
    
end
function OtherWelfareBindPanel:MiscRewardInfo(data)
    if data.type == 4 then
        self:Close()
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "bind", false)
    end

end



function OtherWelfareBindPanel:CreateIcon()
    local  reward = self.model:GetRewardCfg(4)
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