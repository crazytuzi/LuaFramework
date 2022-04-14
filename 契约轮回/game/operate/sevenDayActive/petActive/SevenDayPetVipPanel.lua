---
--- Created by  Administrator
--- DateTime: 2019/8/23 14:40
---
---
require("game.pet.BaseInfo.PetBaseSkillView")
SevenDayPetVipPanel = SevenDayPetVipPanel or class("SevenDayPetVipPanel", BaseItem)
local this = SevenDayPetVipPanel
function SevenDayPetVipPanel:ctor(parent_node, parent_panel,actID)
    self.abName = "sevenDayActive"
    self.assetName = "SevenDayPetVipPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.rewardItems = {}
    self.itemicon = {}
    self.model = SevenDayActiveModel:GetInstance()
    self.actID = actID
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    SevenDayRushBuyPanel.super.Load(self)
    self.skillView = self.skillView or PetBaseSkillView()
end

function SevenDayPetVipPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
    if self.monster then
        self.monster:destroy()
    end
    self.monster = nil

    if (self.skillView) then
        self.skillView:destroy()
        self.skillView = nil
    end


    if self.rewardBtn_red then
        self.rewardBtn_red:destroy()
        self.rewardBtn_red = nil
    end
end

function SevenDayPetVipPanel:LoadCallBack()
    self.nodes = {
        "myVipTex","iconParent","lqBtn","ylq","time","modelCon","skillIcon1","skillIcon2","skillIcon3",
        "Skills/SkillIcon1", "Skills/Lock1", "Skills/SkillLevel1", "Skills/SkillTitle1",
        "Skills/SkillIcon2", "Skills/Lock2", "Skills/SkillLevel2", "Skills/SkillTitle2",
        "Skills/SkillIcon3", "Skills/Lock3", "Skills/SkillLevel3", "Skills/SkillTitle3",
        "name",
    }
    self:GetChildren(self.nodes)
    self.myVipTex = GetText(self.myVipTex)
    self.lqBtnImg = GetImage(self.lqBtn)
    self.time = GetText(self.time)
    self.name = GetText(self.name)
    self.rewardBtn_red = RedDot(self.lqBtn, nil, RedDot.RedDotType.Nor)
    self.rewardBtn_red:SetPosition(58, 14)
    self:InitUI()
    self:AddEvent()


end

function SevenDayPetVipPanel:InitUI()
    self:InitActTime()
    --self:InitModel()

    local vipLv = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
    self.myVipTex.text = string.format("My VIP level：<color=#F5FF43>VIP %s</color>",vipLv)
   -- string.format("我的贵族等级等级：<color=#F5FF43>贵族%s</color>",vipLv)

    local rewardCfg = OperateModel:GetInstance():GetRewardConfig(self.actID)
    local rewardtab =  String2Table(rewardCfg[1].reward)
    for i = 1, #rewardtab do
        --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        end
        local param = {}
        param["model"] = self.model
        param["item_id"] = rewardtab[i][1]
        param["num"] = rewardtab[i][2]
        param["bind"] = rewardtab[i][3]
        param["can_click"] = true
        param["size"] = {x = 78,y = 78}
        param["effect_type"] = 1
        param["color_effect"] = 5

        param["stencil_id"] = self.StencilId
        param["stencil_type"] = 3
        self.itemicon[i]:SetIcon(param)
    end
    --dump(OperateModel:GetInstance():GetActInfo(self.actID))

    self.skillView:AddItem(self.SkillIcon1, self.Lock1, self.SkillLevel1, self.SkillTitle1)
    self.skillView:AddItem(self.SkillIcon2, self.Lock2, self.SkillLevel2, self.SkillTitle2)
    self.skillView:AddItem(self.SkillIcon3, self.Lock3, self.SkillLevel3, self.SkillTitle3)
    self:InitSkill()

    self:SetState()
end

function SevenDayPetVipPanel:AddEvent()
    local function call_back() --领取奖励
        if    self.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then --未完成 then
            Notify.ShowText("Your VIP level is too low")
            return
        end
        local rewardCfg = OperateModel:GetInstance():GetRewardConfig(self.actID)
        OperateController:GetInstance():Request1700004(rewardCfg[1].act_id,rewardCfg[1].id,rewardCfg[1].level)
    end
    AddClickEvent(self.lqBtn.gameObject,call_back)

    self.events[#self.events + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandlerRewardInfo))
end

function SevenDayPetVipPanel:SetState()
    local info = OperateModel:GetInstance():GetActInfo(self.actID)
    self.state = info.tasks[1].state
    if self.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then --未完成
        SetVisible(self.ylq,false)
        SetVisible(self.lqBtn,true)
        self.rewardBtn_red:SetRedDotParam(false)
        ShaderManager.GetInstance():SetImageGray(self.lqBtnImg)
       -- lua_resMgr:SetImageTexture(self, self.ylqImg, "common_image", "img_have_notReached", true, nil, false)
    elseif self.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then --已完成
        SetVisible(self.ylq,false)
        SetVisible(self.lqBtn,true)
        self.rewardBtn_red:SetRedDotParam(true)
        ShaderManager.GetInstance():SetImageNormal(self.lqBtnImg)
    elseif self.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then --已领取
        SetVisible(self.lqBtn,false)
        SetVisible(self.ylq,true)
        self.rewardBtn_red:SetRedDotParam(false)
       -- lua_resMgr:SetImageTexture(self, self.ylqImg, "common_image", "img_have_received_1", true, nil, false)
    end
end

function SevenDayPetVipPanel:HandlerRewardInfo(data)
    if data.act_id == self.actID then
        Notify.ShowText("Claimed")
        self:SetState()
       -- self.data = OperateModel:GetInstance():GetActInfo(self.actID)
       -- self:UpdateRewards(self.data.tasks)
    end
end

function SevenDayPetVipPanel:InitActTime()
    local stime = self:GetActTime(self.openData.act_stime)
    local etime = self:GetActTime(self.openData.act_etime)
    self.time.text = string.format("Event Time: %s-%s",stime,etime)
end

function SevenDayPetVipPanel:GetActTime(time)
    local timeTab = TimeManager:GetTimeDate(time)
    local timestr = "";
    if timeTab.month then
        timestr = timestr .. string.format("%02d", timeTab.month) .. "M";
    end
    if timeTab.day then
        timestr = timestr .. string.format("%d", timeTab.day) .. "Sunday ";
    end
    if timeTab.hour then
        timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
    end
    if timeTab.min then
        timestr = timestr .. string.format("%02d", timeTab.min) .. "";
    end
    return timestr
end

function SevenDayPetVipPanel:InitModel()
        if self.monster then
            self.monster:destroy()
        end
        self.monster = UIModelCommonCamera(self.modelCon, nil, "model_pet_20002");--data.icon

        local config = {};

        config.pos =  { x = -1993, y = -203, z = 670};
        self.monster:SetConfig(config)

end

function SevenDayPetVipPanel:InitSkill()
    local petCfg = Config.db_pet[40700506]
    self.name.text = string.format("T%s\n\n%s", ChineseNumber(petCfg.order_show), petCfg.name)
    if not petCfg then
        return
    end
    self.skillView:RefreshView({["Config"]=petCfg,["Data"]={["extra"] =1} })
end


