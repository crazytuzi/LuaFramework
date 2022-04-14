-- @Author: lwj
-- @Date:   2018-11-29 19:12:20
-- @Last Modified time: 2019-10-25 10:44:29

VipPanel = VipPanel or class("VipPanel", WindowPanel)
local VipPanel = VipPanel

function VipPanel:ctor()
    self.abName = "vip"
    self.assetName = "VipPanel"
    self.layer = "UI"

    self.panel_type = 7
    self.is_set_side_bar_img = true
    self.is_hide_other_panel = true
    self.is_show_indepen_title_bg = true
    self.role_update_list = {}
    self.model = VipModel.GetInstance()
end

function VipPanel:dctor()
end

function VipPanel:Open(default_tag)
    WindowPanel.Open(self)
    if tonumber(default_tag) then
        self.default_table_index = tonumber(default_tag)
    end
end

function VipPanel:LoadCallBack()
    self.nodes = {
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    self:BindRoleUpdate()
end

function VipPanel:AddEvent()
    self.global_event = {}
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(VipEvent.CloseVipPanel, handler(self, self.HandleVipPanelClose))
    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(VipEvent.UpdateVipSideRD, handler(self, self.UpdateSideRD))
    self.model_event[#self.model_event + 1] = self.model:AddListener(VipEvent.SucessActivate, handler(self, self.Close))
end

function VipPanel:BindRoleUpdate()
    self.role_update_list = self.role_update_list or {}
    local function call_back()
        self.model:Brocast(VipEvent.RoleInfoUpdate)
    end
    self.role_update_list[#self.role_update_list + 1] = RoleInfoModel.GetInstance():GetMainRoleData():BindData("viplv", call_back)

    local function call_back()
        self.model.roleData = RoleInfoModel.GetInstance():GetMainRoleData()
        self.model:Brocast(VipEvent.VipExpChange)
    end
    self.role_update_list[#self.role_update_list + 1] = RoleInfoModel.GetInstance():GetMainRoleData():BindData("vipexp", call_back)
end

function VipPanel:OpenCallBack()
    GlobalEvent:Brocast(ShopEvent.GetShopItemList)
    VipController.GetInstance():RequestHavePayList()
    self:UpdateSideRD()
end

function VipPanel:UpdateSideRD()
    for i = 1, 5 do
        self:SetIndexRedDotParam(i, self.model:GetSideRD(i))
    end
end

function VipPanel:HandleVipPanelClose()
    self:Close()
end

function VipPanel:SwitchCallBack(index)
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    --if self.default_tag then
    --    index = self.default_tag
    --    self.default_tag = nil
    --end

    --请求投资计划数据
    VipController.GetInstance():RequestInvestInfo()
    local title_idx = index
	
    if index == 4 then
        title_idx = 6
    end

    local title_name = ConfigLanguage.Vip.TitleTextHead .. title_idx
    self:SetTileTextImage("vip_image", title_name, false)
    if index == 1 then
        local lv = RoleInfoModel.GetInstance():GetMainRoleVipLevel(true)
        local is_taste = RoleInfoModel.GetInstance():GetRoleValue("viptype") == enum.VIP_TYPE.VIP_TYPE_TASTE
        local is_out = self.model:IsOutOfDate()
        local is_taste_out = is_out and is_taste
        if lv == 0 or is_taste_out then
            if not self.introPanel then
                self.introPanel = VipIntroPanel(self.child_transform, "UI")
            end
            self:PopUpChild(self.introPanel)
        else
            self.model:Brocast(VipEvent.RequestVipInfo)
            if not self.exclu_panel then
                self.exclu_panel = VipExclusivePanel(self.child_transform, "UI")
            end
            self:PopUpChild(self.exclu_panel)
        end
    elseif index == 2 then
        if not self.rechargePanel then
            self.rechargePanel = RechargePanel(self.child_transform, "UI")
        end
        self:PopUpChild(self.rechargePanel)
    elseif index == 3 then
        if not self.gift_panel then
            self.gift_panel = VipGiftPanel(self.child_transform, "UI")
        end
        self:PopUpChild(self.gift_panel)
    elseif index == 4 then
        --月卡
        if not self.mc_panel then
            self.mc_panel = MonthCardPanel(self.child_transform, "UI")
        end
        self:PopUpChild(self.mc_panel)
    elseif index == 5 then
        if not self.inves_panel then
            self.inves_panel = InvestPanel(self.child_transform, "UI")
        end
        self:PopUpChild(self.inves_panel)
    end
end

function VipPanel:CloseCallBack()
    if self.role_update_list and self.role_data then
        for k, event_id in pairs(self.role_update_list) do
            self.role_data:RemoveListener(event_id)
        end
        self.role_update_list = nil
    end
    if self.introPanel then
        self.introPanel:destroy()
        self.introPanel = nil
    end
    if self.exclu_panel then
        self.exclu_panel:destroy()
        self.exclu_panel = nil
    end
    if self.rechargePanel then
        self.rechargePanel:destroy()
        self.rechargePanel = nil
    end
    if self.mc_panel then
        self.mc_panel:destroy()
        self.mc_panel = nil
    end
    if self.inves_panel then
        self.inves_panel:destroy()
        self.inves_panel = nil
    end
    if self.gift_panel then
        self.gift_panel:destroy()
        self.gift_panel = nil
    end
    if not table.isempty(self.model_event) then
        for i = 1, #self.model_event do
            self.model:RemoveListener(self.model_event[i])
        end
        self.model_event = {}
    end

    if self.model.is_show_rd_after_close then
        self.model.is_had_invesrd_showed = false
        VipController.GetInstance():CheckInvesRD()
    end
end

--标签栏重写
-- function VipPanel:SetSidebarData()
--     if not self.show_sidebar or not self.sidebar_data then
--         return
--     end
--     local data = {}
--     local len = #self.sidebar_data
--     for i = 1, len do
--         local info = self.sidebar_data[i]
--         local level = info.show_lv or 1
--         local task = info.show_task or 0
--         if info.show_func then
--             if not info.show_func() then
--                 data[#data + 1] = info
--             end
--         elseif IsOpenModular(level, task) then
--             data[#data + 1] = info
--         end
--     end
--     self.bg_win:SetData(data)
--     self.show_sidebar_list = data
--     if self.switch_index then
--         self:SetTabIndex(self.switch_index, self.toggle_id, true)
--     end
-- end
