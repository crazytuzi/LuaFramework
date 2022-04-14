--
-- @Author: chk
-- @Date:   2018-08-30 19:06:17
--
EquipComparePanel = EquipComparePanel or class("EquipComparePanel", BasePanel)
local EquipComparePanel = EquipComparePanel

function EquipComparePanel:ctor()
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)

    self.abName = "system"
    self.assetName = "EquipPanel"
    self.layer = "UI"

    self.events = {}
    --self.click_bg_close = true
    --self.use_background = true
    self.change_scene_close = true

    self.putOnEquipView = nil
    self.outEquipView = nil
    self.model = EquipModel:GetInstance()
end

function EquipComparePanel:dctor()
    for i, v in pairs(self.events) do
        GlobalEvent:RemoveListener(v)
    end

    self.events = {}

    if self.putOnEquipView ~= nil then
        self.putOnEquipView:destroy()
    end
    self.putOnEquipView = nil

    if self.outEquipView ~= nil then
        self.outEquipView:destroy()
    end
    self.outEquipView = nil

    self.model:ClearData()

    if self.delete_scheld_id ~= nil then
        GlobalSchedule:Stop(self.delete_scheld_id)
    end
    self.model = nil;
end

--require_item 在背包的装备item
--require_cfg 第1个参数的配置信息
--puton_item 上身穿戴的装备item
--puton_cfg 第3个参数的配置表信息
--operate_param 操作参数
--model 管理数据的model

function EquipComparePanel:Open(param , parent_node)
    self.param = param;
    self.parent_node = parent_node;
    EquipComparePanel.super.Open(self,parent_node)
end

function EquipComparePanel:LoadCallBack()
    self.nodes = {
        "mask",
        "comPanelContain",
        "normalPanelContain",
    }
    self:GetChildren(self.nodes)

    self:AddEvent()

    --cfg  该物品(装备)的配置
    --p_item 服务器给的，服务器没给，只传cfg就好
    --model 管理该tip数据的实例
    --is_compare --是否有对比
    --operate_param --操作参数

    local outEquipParam = {}
    outEquipParam["p_item"] = self.param["self_item"]
    outEquipParam["cfg"] = self.param["self_cfg"]
    outEquipParam["operate_param"] = self.param["operate_param"]
    outEquipParam["model"] = self.param["model"]
    outEquipParam["bind"] = self.param["bind"]
    outEquipParam["is_compare"] = true

    self.outEquipView = EquipTipView(self.normalPanelContain)
    self.outEquipView:ShowTip(outEquipParam)

    local putOnEquipParam = {}
    putOnEquipParam["p_item"] = self.param["puton_item"]
    putOnEquipParam["cfg"] = self.param["puton_cfg"]
    putOnEquipParam["model"] = self.param["model"]
    putOnEquipParam["is_compare"] = true
    self.putOnEquipView = EquipTipView(self.comPanelContain)
    self.putOnEquipView:ShowTip(putOnEquipParam)

    if self.parent_node then
        SetParent(self.transform , self.parent_node);
    end
end

function EquipComparePanel:AddEvent()

    self.events[#self.events + 1] = GlobalEvent:AddListener(EquipEvent.PutOnEquipSucess, handler(self, self.DealPutOnEquipSucess))
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.SellItems, handler(self, self.DealGoodsSell))
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DealDelItems))
    --self.events[#self.events+1] = GlobalEvent:AddListener(FactionEvent.DestroyEquipSucess,handler(self,self.DealDestroyEquip))
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.CloseTipView, handler(self, self.DealDelItems))
    self.events[#self.events + 1] = GlobalEvent:AddListener(EquipEvent.BrocastSetViewPosition, handler(self, self.DealSetViewPosition))
    self.events[#self.events + 1] = GlobalEvent:AddListener(EquipEvent.PutOffEquip, handler(self, self.CloseTipView))

    local tcher = self.gameObject:AddComponent(typeof(Toucher))
    tcher:SetClickEvent(handler(self, self.OnTouchenBengin))
end

function EquipComparePanel:CloseTipView()
    self:Close()
end

function EquipComparePanel:DealSetViewPosition(param)
    self.positionParam = param
end

function EquipComparePanel:DealDestroyEquip()
    self:Close()
end

function EquipComparePanel:DealDelItems()
    self:Close()
end

function EquipComparePanel:DealGoodsSell()
    self:Close()
end

function EquipComparePanel:DealPutOnEquipSucess()
    self:Close()
end

function EquipComparePanel:DeleteClickClose()
    if self.update_sched_id ~= nil then
        GlobalSchedule:Stop(self.update_sched_id)
        self.update_sched_id = nil
        self:Close()
    end
end

function EquipComparePanel:OnTouchenBengin(x, y)

    local isOnLeft = self.putOnEquipView:OnTouchenBengin(x, y, true)

    local isOnRight = self.outEquipView:OnTouchenBengin(x, y, true)

    if (not isOnLeft) and (not isOnRight) then
        self:Close()
    end

    --local isInOperateBtn = false
    --local isInViewBG = false
    --
    --if x >= self.positionParam.bg_x and x <= self.positionParam.xw and self.positionParam.yw <= y
    --        and self.positionParam.bg_y >= y then
    --    isInViewBG = true
    --end
    --
    --if self.positionParam.operate_param ~= nil then
    --    local num = table.nums(self.positionParam.operate_param)
    --    local btnContainPos = self.outEquipView.btnContain.position
    --    local btnContain_x = ScreenWidth / 2 + btnContainPos.x * 100
    --    local btnContain_y = ScreenHeight / 2 + btnContainPos.y * 100
    --    local btnContain_xw = btnContain_x + 100
    --    local btnContain_yw = btnContain_y + 55 * num + 2 * (num - 1)
    --
    --    if x >= btnContain_x and x <= btnContain_xw and btnContain_y <= y and btnContain_yw >= y then
    --        isInOperateBtn = true
    --    end
    --end
    --
    --if not isInViewBG and not isInOperateBtn then
    --    self:Close()
    --end
end

function EquipComparePanel:OpenCallBack()
    self:UpdateView()
end

function EquipComparePanel:Update()

end

function EquipComparePanel:UpdateView()

end

function EquipComparePanel:CloseCallBack()

end
