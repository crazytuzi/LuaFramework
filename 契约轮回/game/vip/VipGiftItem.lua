-- @Author: lwj
-- @Date:   2019-06-11 20:35:14
-- @Last Modified time: 2019-10-22 20:27:46

VipGiftItem = VipGiftItem or class("VipGiftItem", BaseCloneItem)
local VipGiftItem = VipGiftItem

function VipGiftItem:ctor(parent_node, layer)
    VipGiftItem.super.Load(self)
end

function VipGiftItem:dctor()
    if self.handle_succ_buy_event_id then
        GlobalEvent:RemoveListener(self.handle_succ_buy_event_id)
        self.handle_succ_buy_event_id = nil
    end
    self:DestroyGoods()
end

function VipGiftItem:LoadCallBack()
    self.model = VipModel.GetInstance()
    self.nodes = {
        "item_con", "Name_Bg/name",
        "enavailble", "availble/btn_buy", "availble/rest", "availble",
        "Price/cur_bg/cur_mon", "Price/ori_bg/ori_mon_icon", "Price/cur_bg/cur_mon_icon", "Price/ori_bg/ori_mon",
        "discount/disc", "discount",
    }
    self:GetChildren(self.nodes)
    self.cur_m_icon = GetImage(self.cur_mon_icon)
    self.cur_mon = GetText(self.cur_mon)
    self.ori_m_icon = GetImage(self.ori_mon_icon)
    self.rest = GetText(self.rest)
    self.ori_mon = GetText(self.ori_mon)
    self.name = GetText(self.name)
    self.disc = GetText(self.disc)

    self:AddEvent()
end

function VipGiftItem:AddEvent()
    local function callback()
        if RoleInfoModel.GetInstance():GetMainRoleData().viptype == enum.VIP_TYPE.VIP_TYPE_TASTE then
            Notify.ShowText(ConfigLanguage.Vip.BecomeVipFirst)
            return
        end
        local lv = RoleInfoModel.GetInstance():GetMainRoleVipLevel()
        local vip_limit = self.data.limit_vip
        if lv < vip_limit then
            if lv == 0 and RoleInfoModel.GetInstance():GetMainRoleData().viptype == enum.VIP_TYPE.VIP_TYPE_NORM then
                Notify.ShowText(ConfigLanguage.Vip.VipOutOfDate)
                return
            end
            Notify.ShowText(ConfigLanguage.Vip.VipLvNotEnough)
            return
        end
        local pri_tbl = String2Table(self.data.price)
        local balan = RoleInfoModel.GetInstance():GetRoleValue(pri_tbl[1])
        if balan < pri_tbl[2] then
            local name = Config.db_item[pri_tbl[1]].name
            local tips = string.format(ConfigLanguage.Shop.BalanceNotEnough, name)
            local function callback()
                GlobalEvent:Brocast(VipEvent.CloseVipPanel)
                GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
            end
            Dialog.ShowTwo("Tip", tips, "Confirm", callback, nil, "Cancel", nil, nil, nil, false, false);
            return
        end
        GlobalEvent:Brocast(ShopEvent.BuyShopGoods, self.data.id, 1)
    end
    AddButtonEvent(self.btn_buy.gameObject, callback)

    self.handle_succ_buy_event_id = GlobalEvent:AddListener(ShopEvent.SuccessToBuyGoodsInShop, handler(self, self.HandleSuccessBuy))
end

function VipGiftItem:SetData(data, ser_data)
    self.data = data
    self.ser_data = ser_data
    self:UpdateView()
end

function VipGiftItem:UpdateView()
    local limit_vip = tostring(self.data.limit_vip)
    if limit_vip == '1' then
        limit_vip = 'i'
    end
    self.name.text = string.format(ConfigLanguage.Vip.VipGiftName, limit_vip)
    local ori_tbl = String2Table(self.data.original_price)
    local cur_tbl = String2Table(self.data.price)
    self.ori_mon.text = "  " .. ori_tbl[2]
    self.cur_mon.text = "   " .. cur_tbl[2]
    GoodIconUtil.GetInstance():CreateIcon(self, self.ori_m_icon, tostring(ori_tbl[1]), true)
    GoodIconUtil.GetInstance():CreateIcon(self, self.cur_m_icon, tostring(cur_tbl[1]), true)
    local cur_rest
    if not self.ser_data then
        cur_rest = self.data.limit_num
    else
        cur_rest = self.data.limit_num - self.ser_data
    end
    local is_sell_out = cur_rest == 0
    SetVisible(self.enavailble, is_sell_out)
    SetVisible(self.availble, not is_sell_out)
    if not is_sell_out then
        self.rest.text = string.format(ConfigLanguage.Vip.LimitBuyCount, cur_rest, self.data.limit_num)
    end

    self:DestroyGoods()
    local tbl = String2Table(self.data.item)
    if tbl[1] and type(tbl[1]) == "table" then
        for i = 1, #tbl do
            local cf = tbl[i]
            local param = {}
            local operate_param = {}
            param["item_id"] = cf[1]
            param["model"] = self.model
            param["can_click"] = true
            param["operate_param"] = operate_param
            param["size"] = { x = 76, y = 76 }
            param['num'] = cf[2]
            param['can_click'] = true
            local itemIcon = GoodsIconSettorTwo(self.item_con)
            itemIcon:SetIcon(param)
            self.goods_list[#self.goods_list + 1] = itemIcon
        end
    else
        local param = {}
        local operate_param = {}
        param["item_id"] = tbl[1]
        param["model"] = self.model
        param['num'] = tbl[2]
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 76, y = 76 }
        param['can_click'] = true
        local itemIcon = GoodsIconSettorTwo(self.item_con)
        itemIcon:SetIcon(param)
        self.goods_list[#self.goods_list + 1] = itemIcon
    end

    SetVisible(self.discount, self.data.discount ~= 10)
    self.disc.text = 100 - (self.data.discount * 10) .. "%Off"
end

function VipGiftItem:HandleSuccessBuy(id)
    if self.data.id ~= id then
        return
    end
    if not self.ser_data then
        self.ser_data = 0
    end
    self.ser_data = self.ser_data + 1
    self:UpdateView()
end

function VipGiftItem:DestroyGoods()
    if self.goods_list then
        for i, v in pairs(self.goods_list) do
            if v then
                v:destroy()
            end
        end
    end
    self.goods_list = {}
end