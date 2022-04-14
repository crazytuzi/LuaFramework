-- @Author: lwj
-- @Date:   2020-03-12 17:37:56 
-- @Last Modified time: 2020-03-12 17:37:58

GundamLimitBuyPanel = GundamLimitBuyPanel or class("GundamLimitBuyPanel", BeastActivityPanel)
local this = GundamLimitBuyPanel

function GundamLimitBuyPanel:ctor(parent_node, parent_panel, actID)
    self.abName = "beast_actvity"
    self.assetName = "GundamLimitBuyPanel"
    self.layer = "UI"

    self.use_background = true
    self.change_scene_close = true
    self.select_id = 90101
    self.panel_type = 2
    self.item_list = {}
    self.act_type = 2
    self.global_events = {}

    self.model = ShopModel:GetInstance()
end

function GundamLimitBuyPanel:LoadCallBack()
    self.nodes = {
        "menu_group/Toggle1", "menu_group/Toggle2", "menu_group/Toggle3", "menu_group/Toggle4",
        "desc", "bg2/Content", "model_img", "title_bg/title", "oldpricetitle/oldprice", "title_bg",
        "pricetitle/price", "CountDown", "btn_buy", "btn_close", "btn_finish", "effect",
        "timetitle", "model_con",
    }
    self:GetChildren(self.nodes)
    SetVisible(self.btn_finish, false)
    self.Toggle1 = GetToggle(self.Toggle1)
    self.Toggle2 = GetToggle(self.Toggle2)
    self.Toggle3 = GetToggle(self.Toggle3)
    self.Toggle4 = GetToggle(self.Toggle4)
    self.title = GetImage(self.title)
    self.model_img_img = GetImage(self.model_img)
    self.desc = GetImage(self.desc)
    self.oldprice = GetText(self.oldprice)
    self.price = GetText(self.price)
    SetLocalPosition(self.model_img, -161.3, -12.6)
    SetLocalPosition(self.model_con, -14.7, -15)
    self:AddEvent()
    self.ui_effect = UIEffect(self.effect, 10311)

    LayerManager.GetInstance():AddOrderIndexByCls(self, self.model_con.transform, nil, true, nil, nil, 2)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.title_bg.transform, nil, true, nil, nil, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.timetitle.transform, nil, true, nil, nil, 4)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.CountDown.transform, nil, true, nil, nil, 5)
end

function GundamLimitBuyPanel:AddEvent()
    local function call_back(target, value)
        if value then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.model_img.transform)
            self.select_id = 90101
            SetLocalPosition(self.model_img, -161.3, -12.6)
            self:UpdateView()
            self:PlayAni1()
        end
    end
    AddValueChange(self.Toggle1.gameObject, call_back)

    local function call_back(target, value)
        if value then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.model_img.transform)
            self.select_id = 90102
            SetLocalPosition(self.model_img, -120.65, -12.6)
            self:UpdateView()
            self:PlayAni()
        end
    end
    AddValueChange(self.Toggle2.gameObject, call_back)

    local function call_back(target, value)
        if value then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.model_img.transform)
            self.select_id = 90103
            SetLocalPosition(self.model_img, -120.65, 30.2)
            self:UpdateView()
            self:PlayAni3()
        end
    end
    AddValueChange(self.Toggle3.gameObject, call_back)

    local function call_back(target, value)
        if value then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.model_img.transform)
            self.select_id = 90104
            SetLocalPosition(self.model_img, -120.65, 44.8)
            self:UpdateView()
            self:PlayAni4()
        end
    end
    AddValueChange(self.Toggle4.gameObject, call_back)

    local function call_back(target, x, y)
        self:Close()
    end
    AddButtonEvent(self.btn_close.gameObject, call_back)

    local function call_back(target, x, y)
        local mallcfg = Config.db_mall[self.select_id]
        local need_gold = String2Table(mallcfg.price)[2]
        local message = string.format("Spend %s daimond on it?", need_gold)
        local function ok_func()
            local vo = RoleInfoModel:GetInstance():CheckGold(need_gold, Constant.GoldType.Gold)
            if not vo then
                return
            end
            ShopController:GetInstance():RequestBuyGoods(self.select_id, 1)
        end
        Dialog.ShowTwo("Tip", message, "Confirm", ok_func)
    end
    AddButtonEvent(self.btn_buy.gameObject, call_back)

    local function call_back()
        self:UpdateView()
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(ShopEvent.UpdateFlashSale, call_back)
end