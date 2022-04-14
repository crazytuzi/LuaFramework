-- @Author: lwj
-- @Date:   2019-09-04 16:50:29  
-- @Last Modified time: 2019-09-04 16:50:34

NationPanel = NationPanel or class("NationPanel", BasePanel)
local NationPanel = NationPanel

function NationPanel:ctor()
    self.abName = "nation"
    self.assetName = "NationPanel"
    self.layer = "UI"

    self.use_background = true
    self.is_hide_other_panel = true
    self.panel_type = 2
    self.money_data = { Constant.GoldType.Gold, Constant.GoldType.BGold, Constant.GoldType.Coin }
    --self.is_hide_bottom_panel = true

    self.item_list = {}
    self.model = NationModel.GetInstance()
end

function NationPanel:dctor()

end

function NationPanel:GetAllCf()
    local list = self.model.act_id_list
    for i, v in pairs(list) do
        local id = OperateModel.GetInstance():GetActIdByType(v)
        local theme_cf = OperateModel.GetInstance():GetConfig(id)
        self.model:SetThemeCf(theme_cf)
    end
    self.model:GetRewaCf()
end

function NationPanel:SetMoney(list)
    if table.isempty(list) then
        return
    end
    self.money_list = {}
    local offX = 220
    for i = 1, #list do
        local item = MoneyItem(self.money_con, nil, list[i])
        local x = (i - #list) * offX
        local y = 0
        item:SetPosition(x, y)
        self.money_list[i] = item
    end
end

function NationPanel:Open()
    NationPanel.super.Open(self)
end

function NationPanel:OpenCallBack()
    local data = {}
    data.act_id = OperateModel.GetInstance():GetActIdByType(401)
    NationController.GetInstance():CheckNaitonRD(data)
end

function NationPanel:LoadCallBack()
    self:GetAllCf()
    self.nodes = {
        "menu_con", "view_con", "btn_close", "menu_con/NationMenuItem", "money_con",
        "right", "title", "left", "Sundires/dont_dele_1",
    }
    self:GetChildren(self.nodes)
    self.item_obj = self.NationMenuItem.gameObject
    self.right_img = GetImage(self.right)
    self.left_img = GetImage(self.left)
    self.title_img = GetImage(self.title)

    SetLocalPosition(self.dont_dele_1, 487, 257, 0)

    self:AddEvent()
    self:InitPanel()
    self:SetMoney(self.money_data)

    local theme_cf = self.model:GetThemeCf()
    if not theme_cf then
        return
    end
    local inter = table.pairsByKey(theme_cf)
    local tbl
    for act_id, cf in inter do
        if OperateModel.GetInstance():IsActOpenByTime(act_id) then
            tbl = String2Table(cf.icon)
            break
        end
    end
    if not tbl or table.isempty(tbl) then
        return
    end
    lua_resMgr:SetImageTexture(self, self.title_img, "iconasset/icon_festival", tbl[2] .. "_title", false, nil, false)
    lua_resMgr:SetImageTexture(self, self.left_img, "iconasset/icon_festival", tbl[2] .. "_left", false, nil, false)
    lua_resMgr:SetImageTexture(self, self.right_img, "iconasset/icon_festival", tbl[2] .. "_right", false, nil, false)
end

function NationPanel:AddEvent()
    AddButtonEvent(self.btn_close.gameObject, handler(self, self.Close))
    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(NationEvent.MenuItemClick, handler(self, self.HandleMenuClick))
    self.model_event[#self.model_event + 1] = self.model:AddListener(NationEvent.CloseNationPanel, handler(self, self.Close))
    self.model_event[#self.model_event + 1] = self.model:AddListener(NationEvent.UpdateMenuRD, handler(self, self.HandleUpdateMenuRD))
end

function NationPanel:InitPanel()
    self:LoadThemeItem()
end

function NationPanel:LoadThemeItem()
    self:DestroyItems()
    local list = self.model:GetNationThemeList()
    self.model.show_theme_first_id = list[1].id
    self.item_list = self.item_list or {}
    local len = #list
    for i = 1, len do
        if list[i].id ~= OperateModel.GetInstance():GetActIdByType(405) then
            local item = NationMenuItem(self.item_obj, self.menu_con)
            self.item_list[list[i].id] = item
            list[i].idx = i
            item:SetData(list[i])
        end
    end
end

function NationPanel:HandleMenuClick(act_id)
    if act_id == OperateModel.GetInstance():GetActIdByType(401) then
        --道具兑换
        if not self.exchange_view then
            self.exchange_view = NationExchangeView(self.view_con, "UI")
        end
        self:PopUpChild(self.exchange_view)
    elseif act_id == OperateModel.GetInstance():GetActIdByType(402) then
        --掉落活动
        if not self.drop_view then
            self.drop_view = NationDropView(self.view_con, "UI")
        end
        self:PopUpChild(self.drop_view)
    elseif act_id == OperateModel.GetInstance():GetActIdByType(403) then
        --嗨点
        if not self.high_view then
            self.high_view = NationHighView(self.view_con, "UI")
        end
        self:PopUpChild(self.high_view)
    elseif act_id == OperateModel.GetInstance():GetActIdByType(404) then
        --连充
        if not self.recharge_view then
            self.recharge_view = NationSeqRechargeView(self.view_con, "UI")
        end
        self:PopUpChild(self.recharge_view)
    elseif act_id == OperateModel.GetInstance():GetActIdByType(406) then
        if not self.egg_view then
            self.egg_view = NationEggSmashView(self.view_con, "UI")
        end
        self:PopUpChild(self.egg_view)
    elseif act_id == OperateModel.GetInstance():GetActIdByType(407) then
        if not self.consum_view then
            self.consum_view = ChristmasConsumeView(self.view_con, "UI", act_id)
        end
        self:PopUpChild(self.consum_view)
    elseif act_id == OperateModel.GetInstance():GetActIdByType(730) then
        if not self.hanabi_view then
            self.hanabi_view = ChristmasHanabiView(self.view_con, "UI", act_id)
        end
        self:PopUpChild(self.hanabi_view)
    elseif act_id == OperateModel.GetInstance():GetActIdByType(780) then
        if not self.cloud_view then
            self.cloud_view = CloudLotteryView(self.view_con, "UI", act_id)
        end
	    SetVisible(self.menu_con, false)
        self:PopUpChild(self.cloud_view)
    end
end

function NationPanel:HandleUpdateMenuRD()
    local list = self.model.side_rd_list
    for act_id, is_show in pairs(list) do
        local item = self.item_list[act_id]
        if item then
            item:SetRedDot(is_show)
        end
    end
end

function NationPanel:DestroyItems()
    for i, v in pairs(self.item_list) do
        if v then
            v:destroy()
        end
    end
    self.item_list = {}
end

function NationPanel:CloseCallBack()
    if not table.isempty(self.money_list) then
        for _, item in pairs(self.money_list) do
            item:destroy()
        end
        self.money_list = {}
    end
    if self.drop_view then
        self.drop_view:destroy()
        self.drop_view = nil
    end
    if self.exchange_view then
        self.exchange_view:destroy()
        self.exchange_view = nil
    end
    if self.high_view then
        self.high_view:destroy()
        self.high_view = nil
    end
    if self.recharge_view then
        self.recharge_view:destroy()
        self.recharge_view = nil
    end
    if self.egg_view then
        self.egg_view:destroy()
        self.egg_view = nil
    end
    if self.consum_view then
        self.consum_view:destroy()
        self.consum_view = nil
    end
    if self.hanabi_view then
        self.hanabi_view:destroy()
        self.hanabi_view = nil
    end
    if self.cloud_view then
        self.cloud_view:destroy()
        self.cloud_view = nil
    end
    for i, v in pairs(self.model_event) do
        self.model:RemoveListener(v)
    end
    self.model_event = {}
    self:DestroyItems()
end