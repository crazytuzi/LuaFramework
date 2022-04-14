-- @Author: lwj
-- @Date:   2019-11-28 19:19:07  
-- @Last Modified time: 2019-11-28 19:19:12

NationConsumeItem = NationConsumeItem or class("NationConsumeItem", BaseCloneItem)
local this = NationConsumeItem

function NationConsumeItem:ctor(obj, parent_node, parent_panel)
    NationConsumeItem.super.Load(self)
    self.events = {}
    self.itemicon = {}
    self.model = SevenDayActiveModel:GetInstance()
end

function NationConsumeItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}

    if self.rewardBtn_red then
        self.rewardBtn_red:destroy()
        self.rewardBtn_red = nil
    end
end

function NationConsumeItem:LoadCallBack()
    self.nodes = {
        "btn/btnText", "btn", "ylq", "num/numTex", "num/lqTex", "rewardParent", "num/zhuanshiIcon", "num/des"
    }
    self:GetChildren(self.nodes)
    self.btnText = GetText(self.btnText)
    self.numTex = GetText(self.numTex)
    self.des = GetText(self.des)
    self.ylqImg = GetImage(self.ylq)
    --self.lqTex = GetText(self.lqTex)
    self.rewardBtn_red = RedDot(self.btn, nil, RedDot.RedDotType.Nor)
    self.rewardBtn_red:SetPosition(53, 14)
    self:InitUI()
    self:AddEvent()
end

function NationConsumeItem:InitUI()

end

function NationConsumeItem:AddEvent()

    local function call_back()
        if self.data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            --未完成
            GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
        elseif self.data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            --已完成
            -- Notify.ShowText("领取奖励")
            -- print2(self.actId,self.data.id,self.data.level)
            OperateController:GetInstance():Request1700004(self.actId, self.data.id, self.data.level)
        end
    end
    AddClickEvent(self.btn.gameObject, call_back)
end
--type == 1 开服累冲  2 单日累冲 3 目标
function NationConsumeItem:SetData(data, actId, type, stencilId)
    --  print2(actId,"acttttt")

    --  dump(self.cfgData)
    self.data = data
    self.cfgData = OperateModel:GetInstance():GetRewardConfig(actId, self.data.id)
    self.type = type
    self.actId = actId
    self.StencilId = stencilId
    self:UpdateInfo(self.data)
    self:CreateRewards()

    --print2(type)
    --print2(type)
    --print2(type)
end

function NationConsumeItem:UpdateInfo(data)

    self:SetDes()
    self:SetState(data.state)
end

function NationConsumeItem:SetDes()
    if self.type == 3 then
        local num = tonumber(self.cfgData.task)
        local color = "0DB420"
        if self.data.count < num then
            color = "FF0000"
        end
        --curNum = self.data.count
        local cNum = self.data.count
        if self.data.count > num then
            cNum = num
        end
        self.numTex.text = string.format("<color=#%s>%d/%d</color>", color, cNum, num)
        self.des.text = self.cfgData.desc
        SetVisible(self.zhuanshiIcon, true)
        SetLocalPositionX(self.numTex.transform, self.des.preferredWidth+2)
        SetLocalPositionX(self.zhuanshiIcon.transform, self.numTex.preferredWidth + self.des.preferredWidth + 5)
        SetLocalPositionX(self.lqTex, self.numTex.preferredWidth + self.des.preferredWidth + 30)
    end
end

function NationConsumeItem:SetState(state)
    if self.type == 3 then
        if state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            --未完成
            SetVisible(self.ylq, true)
            SetVisible(self.btn, false)
            self.rewardBtn_red:SetRedDotParam(false)
            lua_resMgr:SetImageTexture(self, self.ylqImg, "common_image", "img_have_notReached", true, nil, false)
        elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            --已完成
            self.btnText.text = "Claim"
            SetVisible(self.btn, true)
            SetVisible(self.ylq, false)
            self.rewardBtn_red:SetRedDotParam(true)
        elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
            --已领取
            SetVisible(self.btn, false)
            SetVisible(self.ylq, true)
            self.rewardBtn_red:SetRedDotParam(false)
            lua_resMgr:SetImageTexture(self, self.ylqImg, "common_image", "img_have_received_1", true, nil, false)
        end

    else
        if state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            --未完成
            self.btnText.text = "Recharge"
            SetVisible(self.btn, true)
            SetVisible(self.ylq, false)
            self.rewardBtn_red:SetRedDotParam(false)
        elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            --已完成
            self.btnText.text = "Claim"
            SetVisible(self.btn, true)
            SetVisible(self.ylq, false)
            self.rewardBtn_red:SetRedDotParam(true)
        elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
            --已领取
            SetVisible(self.btn, false)
            SetVisible(self.ylq, true)
            self.rewardBtn_red:SetRedDotParam(false)
        end
    end

end

function NationConsumeItem:CreateRewards()
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
    local rewardTab = String2Table(self.cfgData.reward)
    -- dump(rewardTab)
    if rewardTab then
        for i = 1, #rewardTab do
            --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
            if self.itemicon[i] == nil then
                self.itemicon[i] = GoodsIconSettorTwo(self.rewardParent)
            end
            local param = {}
            param["model"] = self.model
            param["item_id"] = rewardTab[i][1]
            param["num"] = rewardTab[i][2]
            param["bind"] = rewardTab[i][3]
            param["can_click"] = true
            --  param["size"] = {x = 72,y = 72}
            -- self.StencilId
            param["effect_type"] = 1
            param["color_effect"] = 5
            param["stencil_id"] = self.StencilId
            param["stencil_type"] = 3

            self.itemicon[i]:SetIcon(param)
        end
    end
    -- dump(self.cfgData.reward)

end
