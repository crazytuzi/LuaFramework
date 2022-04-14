---
--- Created by  Administrator
--- DateTime: 2019/4/22 14:47
---
GodCeleRechargeItem = GodCeleRechargeItem or class("GodCeleRechargeItem", BaseCloneItem)
local this = GodCeleRechargeItem

function GodCeleRechargeItem:ctor(obj, parent_node, parent_panel)
    GodCeleRechargeItem.super.Load(self)
    self.events = {}
    self.itemicon = {}
    self.model = GodCelebrationModel:GetInstance()
end

function GodCeleRechargeItem:dctor()
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

function GodCeleRechargeItem:LoadCallBack()
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

function GodCeleRechargeItem:InitUI()

end

function GodCeleRechargeItem:AddEvent()

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
function GodCeleRechargeItem:SetData(data, actId, type, stencilId)
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

function GodCeleRechargeItem:UpdateInfo(data)

    self:SetDes()
    self:SetState(data.state)
end

function GodCeleRechargeItem:SetDes()

    --local tab = String2Table(self.cfgData.task)
    --local num = tab[2]
    --print2(self.data.count)
    --dump(self.data)
    --dump(self.cfgData)
    if self.type == 3 then
        --local color = "0DB420"
        --if self.data.count < num then
        --    color = "FF0000"
        --end
        local curNum
        --   if self.data.count ~= 0 then
        if self.actId == 110302 then
            --坐骑
            local tab = String2Table(self.cfgData.task)
            local num = tab[2]
            if self.data.count ~= 0 then
                curNum = self.model:GetMountNumByID(self.data.count)
                local color = "0DB420"
                if curNum.order < tab[2] then
                    color = "FF0000"
                else
                    if curNum.level < tab[3] then
                        color = "FF0000"
                    end
                end
                self.numTex.text = string.format("<color=#%s>%sTier %sStar/%sTier %sStar</color>", color, curNum.order, curNum.level, num, tab[3])
            else
                self.numTex.text = string.format("<color=#%s>%sTier %sStar/%sTier %sStar</color>", "FF0000", 0, 0, num, tab[3])
            end

        elseif self.actId == 110303 then
            local tab = String2Table(self.cfgData.task)
            local num = tab[2]
            if self.data.count ~= 0 then
                curNum = self.model:GetOffhandNumByID(self.data.count)
                local color = "0DB420"
                if curNum.order < tab[2] then
                    color = "FF0000"
                else
                    if curNum.level < tab[3] then
                        color = "FF0000"
                    end
                end
                self.numTex.text = string.format("<color=#%s>%sTier %sStar/%sTier %sStar</color>", color, curNum.order, curNum.level, num, tab[3])
            else
                self.numTex.text = string.format("<color=#%s>%sTier %sStar/%sTier %sStar</color>", "FF0000", 0, 0, num, tab[3])
            end

        elseif self.actId == 110305 then
            local tab = String2Table(self.cfgData.task)
            local num = tonumber(self.cfgData.task)
            local color = "0DB420"
            if self.data.count < num then
                color = "FF0000"
            end
            local cNum = self.data.count
            if self.data.count > num then
                cNum = num
            end
            self.numTex.text = string.format("<color=#%s>%s/%s</color>", color, cNum, num)
        else
            --  print2("333333333333333333")

            --local tab = self.cfgData.task
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
            self.numTex.text = string.format("<color=#%s>%s/%s</color>", color, cNum, num)

            -- self.numTex.text = string.format("<color=#%s>%s/%s</color>",color,curNum,self.cfgData.task)
        end
        --end

        -- self.numTex.text = string.format("<color=#%s>%s/%s</color>",color,curNum,num)
        SetVisible(self.zhuanshiIcon, false)
        self.des.text = self.cfgData.desc
        SetLocalPositionX(self.numTex.transform, self.des.preferredWidth)
        SetLocalPositionX(self.lqTex, self.numTex.preferredWidth + self.des.preferredWidth + 10)
    end

end

function GodCeleRechargeItem:SetState(state)
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

function GodCeleRechargeItem:CreateRewards()
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



