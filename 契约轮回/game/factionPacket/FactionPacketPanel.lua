-- @Author: lwj
-- @Date:   2019-05-10 16:15:39
-- @Last Modified time: 2019-05-10 16:15:41

FactionPacketPanel = FactionPacketPanel or class("FactionPacketPanel", BasePanel)
local FactionPacketPanel = FactionPacketPanel

function FactionPacketPanel:ctor()
    self.abName = "factionPacket"
    self.assetName = "FactionPacketPanel"
    self.layer = "UI"

    self.model = FPacketModel.GetInstance()
    self.is_hide_other_panel = true
    self.task_item_list = {}
    self.rp_item_list = {}
    self.use_background = true

end

function FactionPacketPanel:dctor()

end

function FactionPacketPanel:Open()
    FactionPacketPanel.super.Open(self)
end

function FactionPacketPanel:OpenCallBack()
end

function FactionPacketPanel:LoadCallBack()
    self.nodes = {
        "Left/reco_content", "Left/task_content", "Left/reco_content/reco_scroll/Viewport/reco_con", "Rgiht/packet_scroll/Viewport/packet_con/FPacketItem", "btn_ques", "Left/reco_content/reco_scroll/Viewport/reco_con/FPLeftItem", "Rgiht/packet_scroll/Viewport/packet_con", "Left/task_content/FPacketTaskItem", "btn_close", "Rgiht/tip",
        "Left/reco_content/reco_scroll/Viewport",
    }
    self:GetChildren(self.nodes)
    self.task_obj = self.FPacketTaskItem.gameObject
    self.rp_obj = self.FPacketItem.gameObject
    self.reco_obj = self.FPLeftItem.gameObject

    self:AddEvent()
    self:InitPanel()
    self:SetMask()   -- scroll 防止穿透
end

function FactionPacketPanel:AddEvent()
    AddButtonEvent(self.btn_close.gameObject, handler(self, self.Close))
    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(FPacketEvent.CloseFPanel, handler(self, self.Close))
    self.model_event[#self.model_event + 1] = self.model:AddListener(FPacketEvent.SuccessSendFP, handler(self, self.LoadRP))

    local function callback()
        ShowHelpTip(HelpConfig.FPacket.HowToFetchFP, true)
    end
    AddButtonEvent(self.btn_ques.gameObject, callback)
end

function FactionPacketPanel:InitPanel()
    self:LoadTaskItems()
    self:LoadRP()
    self:LoadReco()
end

function FactionPacketPanel:LoadTaskItems()
    self.task_item_list = self.task_item_list or {}
    local list = self.model.task_cf
    local len = #list
    for i = 1, len do
        local item = self.task_item_list[i]
        if not item then
            item = FPacketTaskItem(self.task_obj, self.task_content)
            self.task_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.task_item_list do
        local item = self.task_item_list[i]
        item:SetVisible(false)
    end
end

function FactionPacketPanel:LoadRP()
    SetVisible(self.tip, self.model:IsHavePacket())
    local list = self.model:GetInfoList()

    self.rp_item_list = self.rp_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.rp_item_list[i]
        if not item then
            item = FPacketItem(self.rp_obj, self.rewardContent)
            self.rp_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.rp_item_list do
        local item = self.rp_item_list[i]
        item:SetVisible(false)
    end
end

function FactionPacketPanel:LoadReco()
    local list = self.model:GetRecoList()
    self.reco_item_list = self.reco_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.reco_item_list[i]
        if not item then
            item = FPLeftItem(self.reco_obj, self.reco_con)
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

function FactionPacketPanel:CloseCallBack()
    for i, v in pairs(self.task_item_list) do
        if v then
            v:destroy()
        end
    end
    self.task_item_list = {}
    for i, v in pairs(self.rp_item_list) do
        if v then
            v:destroy()
        end
    end
    self.rp_item_list = {}
    for i, v in pairs(self.model_event) do
        self.model:RemoveListener(v)
    end
    self.model_event = {}
    for i, v in pairs(self.reco_item_list) do
        if v then
            v:destroy()
        end
    end
    self.reco_item_list = {}
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function FactionPacketPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

