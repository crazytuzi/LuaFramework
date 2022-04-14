-- @Author: lwj
-- @Date:   2019-12-08 10:45:33 
-- @Last Modified time: 2019-12-08 10:45:36

RechargeRecoPanel = RechargeRecoPanel or class("RechargeRecoPanel", BasePanel)
local RechargeRecoPanel = RechargeRecoPanel

function RechargeRecoPanel:ctor()
    self.abName = "dial"
    self.assetName = "RechargeRecoPanel"
    self.layer = "UI"

    self.model = DialModel.GetInstance()
end

function RechargeRecoPanel:dctor()

end

function RechargeRecoPanel:Open(act_Id)
    self.act_id = act_Id
    RechargeRecoPanel.super.Open(self)
end

function RechargeRecoPanel:OpenCallBack()
end

function RechargeRecoPanel:LoadCallBack()
    self.nodes = {
        "Scroll/Viewport/Content/RechargeRecoItem", "Scroll/Viewport/Content", "mask",
    }
    self:GetChildren(self.nodes)
    self.reco_obj = self.RechargeRecoItem.gameObject

    self:AddEvent()
    GlobalEvent:Brocast(OperateEvent.REQUEST_YY_LOG, self.act_id)
    self:InitPanel()
end

function RechargeRecoPanel:AddEvent()
    self.recive_yy_log_event_id = GlobalEvent:AddListener(OperateEvent.DELIVER_YY_LOG, handler(self, self.HandleReciveYYLog))

    AddClickEvent(self.mask.gameObject, handler(self, self.Close))
end

function RechargeRecoPanel:InitPanel()
end

function RechargeRecoPanel:CloseCallBack()
    if self.recive_yy_log_event_id then
        GlobalEvent:RemoveListener(self.recive_yy_log_event_id)
        self.recive_yy_log_event_id = nil
    end
    destroyTab(self.reco_item_list, true)
end

function RechargeRecoPanel:HandleReciveYYLog(act_id, data)
    if act_id ~= self.act_id then
        return
    end
    self:LoadReco(data)
end

function RechargeRecoPanel:LoadReco(list)
    self.reco_item_list = self.reco_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.reco_item_list[i]
        if not item then
            item = RechargeRecoItem(self.reco_obj, self.Content)
            self.reco_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.reco_item_list do
        local item = self.reco_item_list[i]
        item:SetVisible(false)
    end
end