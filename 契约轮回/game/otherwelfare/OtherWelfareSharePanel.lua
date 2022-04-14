OtherWelfareSharePanel = OtherWelfareSharePanel or class("OtherWelfareSharePanel", BasePanel)
local this = OtherWelfareSharePanel

function OtherWelfareSharePanel:ctor(parent_node, parent_panel)
    self.abName = "otherwelfare"
    self.assetName = "OtherWelfareSharePanel"
    self.layer = LayerManager.LayerNameList.UI

    self.use_background = true
    self.change_scene_close = true
    self.click_bg_close = true
    self.is_hide_other_panel = true
    self.events = {}
    self.itemicon ={}
    self.itemicon1 = {}
    self.model = OtherWelfareModel:GetInstance()

end

function OtherWelfareSharePanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if not table.isempty(self.itemicon) then
        for i, v in pairs(self.itemicon) do
            v:destroy()
        end
        self.itemicon = {}
    end
    if not table.isempty(self.itemicon1) then
        for i, v in pairs(self.itemicon1) do
            v:destroy()
        end
        self.itemicon1 = {}
    end


    if self.scheduleId then
        GlobalSchedule:Stop(self.scheduleId)
    end
    self.scheduleId = nil

    if self.scheduleId1 then
        GlobalSchedule:Stop(self.scheduleId1)
    end
    self.scheduleId1 = nil
end

function OtherWelfareSharePanel:Open()
    OtherWelfareSharePanel.super.Open(self)
end

function OtherWelfareSharePanel:LoadCallBack()
    self.nodes = {
        "share/shareIconParent","zan/zanIconParent","share/shareBtn","zan/zanBtn","share/closeBtn",
        "share/shareLqBtn","zan/zanLqBtn","share","zan"
    }
    self:GetChildren(self.nodes)
    self.shareBtnImg = GetImage(self.shareBtn)
    self.zanBtnImg = GetImage(self.zanBtn)
    SetVisible(self.zanLqBtn,false)
    SetVisible(self.shareLqBtn,false)
    self:InitUI()
    self:AddEvent()
end

function OtherWelfareSharePanel:InitUI()
    self:CreateShareIcon();
    self:CreateZanIcon()
    self:SetBtnState()
end

function OtherWelfareSharePanel:AddEvent()
    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)

    local function call_back()
        if self.model.miscInfo[2].is_get then
            --Notify.ShowText("今天已分享，請明日再來")
            return
        end
        PlatformManager:GetInstance():FBsharelink()
       -- WelfareController:GetInstance():ReqeustMiscRewardInfo(2)
        --local function call_back1()
        --
        --end
        --self.scheduleId = GlobalSchedule:StartOnce(call_back1,0.5)
    end
    AddClickEvent(self.shareBtn.gameObject,call_back)

    local function call_back()
        if self.model.miscInfo[3].is_get then
            --Notify.ShowText("您已領取該獎勵")
            return
        end
        PlatformManager:GetInstance():dz()
        --WelfareController:GetInstance():ReqeustMiscRewardInfo(3)
        --local function call_back1()
        --
        --end
        --self.scheduleId1 = GlobalSchedule:StartOnce(call_back1,0.5)
    end
    AddClickEvent(self.zanBtn.gameObject,call_back)

    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.FbShareInfo,handler(self,self.FbShareInfo))
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.DianZanInfo,handler(self,self.DianZanInfo))
    self.events[#self.events + 1] = GlobalEvent:AddListener(OtherWelfareEvent.MiscRewardInfo,handler(self,self.MiscRewardInfo))
end

function OtherWelfareSharePanel:FbShareInfo()
    --SetVisible(self.shareBtn,false)
    --SetVisible(self.shareLqBtn,false)

end

function OtherWelfareSharePanel:DianZanInfo()
    --SetVisible(self.zanBtn,false)
    --SetVisible(self.zanLqBtn,false)
end

function OtherWelfareSharePanel:MiscRewardInfo(data)
    --Notify.ShowText("領取成功")
    self:SetBtnState()
end

function OtherWelfareSharePanel:SetBtnState()
    -- 2分享 3点赞
    local state1 = self.model.miscInfo[2].is_get
    local state2= self.model.miscInfo[3].is_get
    if state1 then
        ShaderManager:GetInstance():SetImageGray(self.shareBtnImg)
    else
        ShaderManager:GetInstance():SetImageNormal(self.shareBtnImg)
    end

    if state2 then
        ShaderManager:GetInstance():SetImageGray(self.zanBtnImg)
    else
        ShaderManager:GetInstance():SetImageNormal(self.zanBtnImg)
    end
    self:SetPos(state2)
end

function OtherWelfareSharePanel:SetPos(isHide)
    SetVisible(self.zan,not isHide)
    if  isHide then
        SetLocalPositionY(self.share,-140)
    else
        SetLocalPositionY(self.share,0)
    end
end


function OtherWelfareSharePanel:CreateShareIcon()
    local  reward = self.model:GetRewardCfg(2)
    for i = 1, #reward do
        --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.shareIconParent)
        end
        local param = {}

        param["model"] = self.model
        param["item_id"] = reward[i][1]
        param["num"] = reward[i][2]
        param["can_click"] = true
        self.itemicon[i]:SetIcon(param)
    end
end

function OtherWelfareSharePanel:CreateZanIcon()
    local  reward = self.model:GetRewardCfg(3)
    for i = 1, #reward do
        --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
        if self.itemicon1[i] == nil then
            self.itemicon1[i] = GoodsIconSettorTwo(self.zanIconParent)
        end
        local param = {}

        param["model"] = self.model
        param["item_id"] = reward[i][1]
        param["num"] = reward[i][2]
        param["can_click"] = true
        self.itemicon1[i]:SetIcon(param)
    end
end