-- @Author: lwj
-- @Date:   2019-05-30 15:30:45
-- @Last Modified time: 2019-05-30 15:30:46

MCItem = MCItem or class("MCItem", BaseCloneItem)
local MCItem = MCItem

function MCItem:ctor(parent_node, layer)
    MCItem.super.Load(self)
end

function MCItem:dctor()
    if self.itemIcon then
        self.itemIcon:destroy()
        self.itemIcon = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function MCItem:LoadCallBack()
    self.model = VipModel.GetInstance()
    self.nodes = {
        "tip", "money", "des", "btn_fetch", "money_icon", "icon", "btn_fetch/btn_text", "no_achi",
        "red_con",
    }
    self:GetChildren(self.nodes)
    self.tip = GetText(self.tip)
    self.money = GetText(self.money)
    self.des = GetText(self.des)
    self.money_icon = GetImage(self.money_icon)
    self.btn_text = GetText(self.btn_text)
    self.btn_img = GetImage(self.btn_fetch)
    self.no_achi = GetImage(self.no_achi)

    self:AddEvent()
end

function MCItem:AddEvent()
    local function callback()
        self.model.is_fetching_mc_rewa = true
        self.model:Brocast(VipEvent.FetchMCReward, self.data.day)
    end
    AddButtonEvent(self.btn_fetch.gameObject, callback)
end

function MCItem:SetData(data, ser_data)
    self.data = data
    self.ser_data = ser_data
    self:UpdateView()
end

function MCItem:UpdateView()
    if self.itemIcon then
        self.itemIcon:destroy()
        self.itemIcon = nil
    end
    self.money_tbl = String2Table(self.data.reward)
    local param = {}
    local operate_param = {}
    param["item_id"] = self.money_tbl[1][1]
    param["model"] = self.model
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 76, y = 76 }
    self.itemIcon = GoodsIconSettorTwo(self.icon)
    self.itemIcon:SetIcon(param)
    if self.data.type == 1 then
        self.des.text = ConfigLanguage.Vip.CanFetchImediatly
    elseif self.data.type == 0 then
        self.des.text = string.format(ConfigLanguage.Vip.CanFetchAtSomeDay, self.data.day)
    end
    GoodIconUtil.GetInstance():CreateIcon(self, self.money_icon, self.money_tbl[1][1], true)
    self.money.text = self.money_tbl[1][2]
    self.tip.text = self.data.desc

    if self.ser_data == nil then
        --未达成
        SetVisible(self.no_achi, true)
        SetVisible(self.btn_fetch, false)
        lua_resMgr:SetImageTexture(self, self.no_achi, "common_image", "img_have_notReached", false, nil, false)
    elseif self.ser_data == false then
        --已购买，未领取
        SetVisible(self.no_achi, false)
        SetVisible(self.btn_fetch, true)
    else
        SetVisible(self.no_achi, true)
        SetVisible(self.btn_fetch, false)
        lua_resMgr:SetImageTexture(self, self.no_achi, "common_image", "img_have_received_1", false, nil, false)
    end
    self:CheckRD()
end

function MCItem:CheckRD()
    self:SetRedDot(self.model:GetMCItemRDByDay(self.data.day))
end

function MCItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end
