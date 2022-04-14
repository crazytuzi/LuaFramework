-- @Author: lwj
-- @Date:   2019-02-14 11:21:38
-- @Last Modified time: 2019-02-14 11:21:40

RechargeItem = RechargeItem or class("RechargeItem", BaseCloneItem)
local RechargeItem = RechargeItem

function RechargeItem:ctor(parent_node, layer)
    self.global_event_list = {}
    RechargeItem.super.Load(self)
end

function RechargeItem:dctor()
    if self.global_event_list then
        GlobalEvent:RemoveTabListener(self.global_event_list)
        self.global_event_list = {}
    end
    if self.eft ~= nil then
        self.eft:destroy()
        self.eft = nil
    end
    if self.handle_paid_list_event_id then
        self.model:RemoveListener(self.handle_paid_list_event_id)
        self.handle_paid_list_event_id = nil
    end
end

function RechargeItem:LoadCallBack()
    self.model = VipModel.GetInstance()
    self.nodes = {
        "icon", "btn_buy", "diamand_num", "btn_buy/price", "bg", "discount_bg/extra_num", "discount_bg/extra_icon", "discount_bg",
    }
    self:GetChildren(self.nodes)
    self.icon = GetImage(self.icon)
    self.extra_icon = GetImage(self.extra_icon)
    self.extra_num = GetText(self.extra_num)
    self.diamand_num = GetText(self.diamand_num)
    self.price = GetText(self.price)

    self:AddEvent()
end

function RechargeItem:AddEvent()
    local function call_back(target, x, y)
        -- do
        --     Notify.ShowText("充值功能未开启")
        --     return
        -- end
        local  boo1,perPriece = RealNameModel:GetInstance():IsCanOneCharge(self.data.price)
        if not boo1 then
            Dialog.ShowTwo("Tip",string.format("Anti-addiction measures applied. Your max single recharge amount will be %s",perPriece),"Confirm")
            return
        end

        local  boo,maxPrice = RealNameModel:GetInstance():IsCanCharge(self.data.price)
        if not boo then
            Dialog.ShowTwo("Tip",string.format("Anti-addiction measures applied. Your max monthly recharge amount will be %s",maxPrice),"Confirm")
            return
        end
        VipController:GetInstance():RequestPayInfo(self.data.id)
    end
    AddClickEvent(self.bg.gameObject, call_back)

    local function call_back(data)
        if data.goods_id == self.data.id then
            local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
            if not AppConfig.Debug then
                local productCount = self.cf_diamand_num or 1
                local id = self.data.id

		
                PlatformManager:GetInstance():buy(data.order_id, role_data.id, role_data.name, role_data.suid, "Diamond", id, productCount .. "Diamond", self.cf_diamand_num, self.data.price, data.pay_back, self.cf_diamand_num, self.data.AppStoreid or id, data.goods_id)
            end
        end
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(EventName.REQ_PAYINFO, call_back)
    self.handle_paid_list_event_id = self.model:AddListener(VipEvent.HandlePaidList, handler(self, self.UpdateFirstPay))
end

function RechargeItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function RechargeItem:UpdateView()
    self:UpdateFirstPay()
    if self.eft ~= nil then
        self.eft:destroy()
    end
    self.eft = UIEffect(self.icon.transform, 10601, false, self.layer)
    self.eft:SetConfig({ is_loop = true })
    self.eft.is_hide_clean = false
    self.eft:SetOrderIndex(423)

    lua_resMgr:SetImageTexture(self, self.icon, "iconasset/icon_recharge", self.data.icon, true, nil, false)
    local extra_tbl = String2Table(self.data.extra_num)
    GoodIconUtil.GetInstance():CreateIcon(self, self.extra_icon, tostring(extra_tbl[1]), true)
    self.extra_num.text = extra_tbl[2]
    self.cf_diamand_num = String2Table(self.data.diamand_num)[2]
    self.diamand_num.text = self.cf_diamand_num
    if PlatformManager:GetInstance():IsEN() then
        self.price.text = "$ " .. self.data.price
    else
        self.price.text = "￥ " .. self.data.price
    end
end

function RechargeItem:UpdateFirstPay()
    self.data.is_payed = self.model:CheckPayedById(self.data.id)
    SetVisible(self.discount_bg, not self.data.is_payed)
end