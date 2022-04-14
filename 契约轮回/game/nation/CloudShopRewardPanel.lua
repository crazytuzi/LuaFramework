-- @Author: lwj
-- @Date:   2019-12-27 14:51:41 
-- @Last Modified time: 2019-12-27 14:51:44

CloudShopRewardPanel = CloudShopRewardPanel or class("CloudShopRewardPanel", WindowPanel)
local CloudShopRewardPanel = CloudShopRewardPanel

function CloudShopRewardPanel:ctor()
    self.abName = "nation"
    self.assetName = "CloudShopRewardPanel"
    self.layer = "UI"

    self.panel_type = 3
    self.use_background = true
    self.hide_other_panel = true
    self.model = NationModel.GetInstance()
end

function CloudShopRewardPanel:dctor()

end

function CloudShopRewardPanel:Open(act_id)
    self.act_id = act_id
    WindowPanel.Open(self)
end

function CloudShopRewardPanel:LoadCallBack()
    self.nodes = {
        "des", "Scroll/Viewport", "Scroll/Viewport/content/CloudShopRewaItem", "Scroll/Viewport/content",
    }
    self:GetChildren(self.nodes)
    self:SetPanelSize(650, 550)
    self:SetBgLocalPos(-10, 5, 0)
    self:SetTitleImgPos(-37.9, 7.87)

    self.des = GetText(self.des)
    local des_rect = GetRectTransform(self.des)
    SetSizeDelta(des_rect, 597.75, 176)
    SetLocalPositionY(self.des.transform, -164)
    self.item_obj = self.CloudShopRewaItem.gameObject

    self:SetTileTextImage(self.abName .. "_image", "CloudShopRewaTitle")
    self:SetMask()

    self:AddEvent()
    GlobalEvent:Brocast(OperateEvent.REQUEST_SHOP_BOUGHT_RECO, self.act_id)
    self:InitPanel()
end

function CloudShopRewardPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function CloudShopRewardPanel:AddEvent()
    self.reco_event_id = GlobalEvent:AddListener(OperateEvent.DILIVER_SHOP_BOUGHT_RECO, handler(self, self.LoadRewaItem))
end

function CloudShopRewardPanel:InitPanel()
    self.des.text = HelpConfig.nation.CloundShopRecordDesc
end

function CloudShopRewardPanel:LoadRewaItem(id, info)
    if id ~= self.act_id then
        return
    end
    local list = {}
    if (not info) or table.isempty(info) then
        --未开奖
        local temp = self.model:DealShopItemList(self.act_id, self.model.shop_info.list)
        for i = 1, #temp do
            local data = {}
            data.id = temp[i].id
            list[#list + 1] = data
        end
    else
        --已开奖
        list = info
    end
    self.rewa_item_list = self.rewa_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = CloudShopRewaItem(self.item_obj, self.content)
            self.rewa_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i], self.StencilId)
    end
    for i = len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end
end

function CloudShopRewardPanel:CloseCallBack()
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
    if self.reco_event_id then
        GlobalEvent:RemoveListener(self.reco_event_id)
        self.reco_event_id = nil
    end
    if not table.isempty(self.rewa_item_list) then
        destroyTab(self.rewa_item_list, true)
    end
end

