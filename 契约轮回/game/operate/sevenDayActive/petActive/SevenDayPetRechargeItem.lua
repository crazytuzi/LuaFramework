---
--- Created by  Administrator
--- DateTime: 2019/8/23 15:38
---
SevenDayPetRechargeItem = SevenDayPetRechargeItem or class("SevenDayPetRechargeItem", BaseCloneItem)
local this = SevenDayPetRechargeItem

function SevenDayPetRechargeItem:ctor(obj, parent_node, parent_panel)
    SevenDayPetRechargeItem.super.Load(self)
    self.events = {}
    self.itemicon = {}
    self.model = SevenDayActiveModel:GetInstance()
end

function SevenDayPetRechargeItem:dctor()
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

function SevenDayPetRechargeItem:LoadCallBack()
    self.nodes = {
        "btn/btnText","btn","ylq","num/numTex","num/lqTex","rewardParent","num/zhuanshiIcon","num/des"
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

function SevenDayPetRechargeItem:InitUI()

end

function SevenDayPetRechargeItem:AddEvent()
    local function call_back()
        if  self.data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then --未完成
            GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
        elseif self.data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then --已完成
            -- Notify.ShowText("领取奖励")
            -- print2(self.actId,self.data.id,self.data.level)
            OperateController:GetInstance():Request1700004(self.actId,self.data.id,self.data.level)
        end
    end
    AddClickEvent(self.btn.gameObject,call_back)
end
-- type == 1充值  3目标
function SevenDayPetRechargeItem:SetData(data,actId,type,stencilId )
    self.data = data
    self.cfgData = OperateModel:GetInstance():GetRewardConfig(actId,self.data.id)
    self.type = type
    self.actId = actId
    self.StencilId = stencilId
    self:UpdateInfo(self.data)
    self:CreateRewards()
end

function SevenDayPetRechargeItem:UpdateInfo(data)
    self:SetDes()
    self:SetState(data.state)
end

function SevenDayPetRechargeItem:SetDes()
    if self.type == 1 then
        local tab = String2Table(self.cfgData.task)
        local num = tab[2]
        local color = "0DB420"
        if self.data.count < num then
            color = "FF0000"
        end
        local cNum = self.data.count
        if self.data.count > num then
            cNum = num
        end
        self.numTex.text = string.format("<color=#%s>%s/%s</color>",color,cNum,num)

        --  self.numTex.text = string.format("<color=#%s>%s/%s</color>",color,self.data.count,num)
        SetLocalPositionX(self.numTex.transform,self.des.preferredWidth)
        SetLocalPositionX(self.zhuanshiIcon.transform,self.numTex.preferredWidth + self.des.preferredWidth )
        SetLocalPositionX(self.lqTex,self.numTex.preferredWidth + self.des.preferredWidth + 30)
    else
        --logError(self.cfgData.event)
        if self.cfgData.event == 69 then  --宠物总战力达到
            local num = tonumber(self.cfgData.task)
              local color = "0DB420"
              if self.data.count < num then
                  color = "FF0000"
              end
              local cNum = self.data.count
              if self.data.count > num then
                  cNum = num
              end
              self.numTex.text = string.format("<color=#%s>%s/%s</color>",color,cNum,num)
            self.des.text = self.cfgData.desc
        elseif  self.cfgData.event == 33 then --合成xx体宠物xx只
            local tab = String2Table(self.cfgData.task)
            local num = tab[2]
            local color = "0DB420"
            if self.data.count < num then
                color = "FF0000"
            end
            local cNum = self.data.count
            self.numTex.text = string.format("<color=#%s>%s/%s</color>",color,cNum,num)
            self.des.text = string.format(self.cfgData.desc,"<color=#0DB420>"..ConfigLanguage.Pet["Quality_Name_"..tab[1]].."</color>",num)

        elseif self.cfgData.event == 53 then-- 上阵xx体宠物a
           -- local tab = String2Table(self.cfgData.task)
            local petId = tonumber(self.cfgData.task)
            local petCfg = Config.db_pet[petId]
            local level = petCfg.quality
            local name = petCfg.name
            local color = "0DB420"
            if self.data.count < 1 then
                color = "FF0000"
            end
            local cNum = self.data.count
            self.numTex.text = string.format("<color=#%s>%s/%s</color>",color,cNum,1)
            self.des.text = string.format(self.cfgData.desc,"<color=#0DB420>"..ConfigLanguage.Pet["Quality_Name_"..level].."</color>","<color=#0DB420>"..name.."</color>")
        elseif self.cfgData.event == 3 then --击杀xx品质的首领xx只
            local quaTab = {[1] = "Blue",[2] = "Purple",[3] = "Orange",[4] = "Red",[5] = "Pink",}
            local tab = String2Table(self.cfgData.task)
            local qua = tab[2]
            local num = tab[3]
            local color = "0DB420"
            local cNum = self.data.count
            if self.data.count < num then
                color = "FF0000"
            end
            self.numTex.text = string.format("<color=#%s>%s/%s</color>",color,cNum,num)
            self.des.text = string.format(self.cfgData.desc,enumName.COLOR[qua],num)
        elseif  self.cfgData.event == 80 or 83 then -- 图鉴战力达到
            local num = tonumber(self.cfgData.task)
            local color = "0DB420"
            if self.data.count < num then
                color = "FF0000"
            end
            local cNum = self.data.count
            if self.data.count > num then
                cNum = num
            end
            self.numTex.text = string.format("<color=#%s>%s/%s</color>",color,cNum,num)
            self.des.text = self.cfgData.desc
        end
        SetVisible(self.zhuanshiIcon,false)

        SetLocalPositionX(self.numTex.transform,self.des.preferredWidth)
        SetLocalPositionX(self.lqTex,self.numTex.preferredWidth + self.des.preferredWidth + 10)
        --local tab = String2Table(self.cfgData.task)
        --local num = tonumber(self.cfgData.task)
       -- logError(type(self.cfgData.task))
      --  logError(num)
      --  local color = "0DB420"
      --  if self.data.count < num then
      --      color = "FF0000"
      --  end
      --  local cNum = self.data.count
      --  if self.data.count > num then
      --      cNum = num
      --  end
      --  self.numTex.text = string.format("<color=#%s>%s/%s</color>",color,cNum,num)
    end
end

function SevenDayPetRechargeItem:SetState(state)
    if self.type == 1 then
        if state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then --未完成
            self.btnText.text = "Recharge"
            SetVisible(self.btn,true)
            SetVisible(self.ylq,false)
            self.rewardBtn_red:SetRedDotParam(false)
        elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then --已完成
            self.btnText.text = "Claim"
            SetVisible(self.btn,true)
            SetVisible(self.ylq,false)
            self.rewardBtn_red:SetRedDotParam(true)
        elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then --已领取
            SetVisible(self.btn,false)
            SetVisible(self.ylq,true)
            self.rewardBtn_red:SetRedDotParam(false)
        end
    else
        if state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then --未完成
            SetVisible(self.ylq,true)
            SetVisible(self.btn,false)
            self.rewardBtn_red:SetRedDotParam(false)
            lua_resMgr:SetImageTexture(self, self.ylqImg, "common_image", "img_have_notReached", true, nil, false)
        elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then --已完成
            self.btnText.text = "Claim"
            SetVisible(self.btn,true)
            SetVisible(self.ylq,false)
            self.rewardBtn_red:SetRedDotParam(true)
        elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then --已领取
            SetVisible(self.btn,false)
            SetVisible(self.ylq,true)
           self.rewardBtn_red:SetRedDotParam(false)
            lua_resMgr:SetImageTexture(self, self.ylqImg, "common_image", "img_have_received_1", true, nil, false)
        end
    end
end

function SevenDayPetRechargeItem:CreateRewards()
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
end


