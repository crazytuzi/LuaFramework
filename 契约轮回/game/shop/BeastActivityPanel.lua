BeastActivityPanel = BeastActivityPanel or class("BeastActivityPanel", BasePanel)
local BeastActivityPanel = BeastActivityPanel

function BeastActivityPanel:ctor()
    self.abName = "beast_actvity"
    self.assetName = "BeastActivityPanel"
    self.layer = "UI"

    self.use_background = true
    self.change_scene_close = true
    self.select_id = 90001
    self.panel_type = 2
    self.item_list = {}
    self.global_events = {}
    self.act_type = 1           --1:异兽限购        2：机甲限购

    self.model = ShopModel:GetInstance()
end

function BeastActivityPanel:dctor()
end

function BeastActivityPanel:Open()
    BeastActivityPanel.super.Open(self)
end

function BeastActivityPanel:LoadCallBack()
    self.nodes = {
        "menu_group/Toggle1", "menu_group/Toggle2", "menu_group/Toggle3", "menu_group/Toggle4",
        "desc", "bg2/ScrollView/Viewport/Content", "model_img", "title_bg/title", "oldpricetitle/oldprice", "title_bg",
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
    self:AddEvent()
    -- self.ui_effect = UIEffect(self.effect, 10311)

    if self.title_bg then
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.title_bg.transform, nil, true, nil, nil, 2)
    end
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.timetitle.transform, nil, true, nil, nil, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.CountDown.transform, nil, true, nil, nil, 4)
end

function BeastActivityPanel:AddEvent()
    local function call_back(target, value)
        if value then
            self:SelectToggle(1)
        end
    end
    AddValueChange(self.Toggle1.gameObject, call_back)

    local function call_back(target, value)
        if value then
            self:SelectToggle(2)
        end
    end
    AddValueChange(self.Toggle2.gameObject, call_back)

    local function call_back(target, value)
        if value then
            self:SelectToggle(3)
        end
    end
    AddValueChange(self.Toggle3.gameObject, call_back)

    local function call_back(target, value)
        if value then
            self:SelectToggle(4)
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

function BeastActivityPanel:SelectToggle(index)
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.model_img.transform)
    if index == 1 then
        self.select_id = 90001
        SetLocalPosition(self.model_img, -161.3, -12.6)
        self:UpdateView()
        self:PlayAni1()
    elseif index == 2 then
        self.select_id = 90002
        SetLocalPosition(self.model_img, -161.3, -12.6)
        self:UpdateView()
        self:PlayAni()
    elseif index == 3 then
        self.select_id = 90003
        SetLocalPosition(self.model_img, -170.1, 30.2)
        self:UpdateView()
        self:PlayAni3()
    elseif index == 4 then
        self.select_id = 90004
        SetLocalPosition(self.model_img, -192.1, 44.8)
        self:UpdateView()
        self:PlayAni4()
    end
end

function BeastActivityPanel:PlayAni()
    local move_x = -120.65
    if self.act_type == 1 then
        move_x = -161.3
    end
    local action = cc.MoveTo(1, move_x, 16.7)
    action = cc.Sequence(action, cc.MoveTo(1, move_x, -27.5))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.model_img.transform)
end

function BeastActivityPanel:PlayAni1()
    local move_x = -120.65
    if self.act_type == 1 then
        move_x = -161.3
    end
    local action = cc.MoveTo(1, move_x, 0)
    action = cc.Sequence(action, cc.MoveTo(1, move_x, -24.5))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.model_img.transform)
end

function BeastActivityPanel:PlayAni3()
    local move_x = -120.65
    if self.act_type == 1 then
        move_x = -170.3
    end
    local action = cc.MoveTo(1, move_x, 40.2)
    action = cc.Sequence(action, cc.MoveTo(1, move_x, 20.2))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.model_img.transform)
end

function BeastActivityPanel:PlayAni4()
    local move_x = -120.65
    if self.act_type == 1 then
        move_x = -192.3
    end
    local action = cc.MoveTo(1, move_x, 54)
    action = cc.Sequence(action, cc.MoveTo(1, move_x, 34.8))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.model_img.transform)
end

function BeastActivityPanel:OpenCallBack()
    self:UpdateView()
end

function BeastActivityPanel:UpdateView()
    local limitcfg = Config.db_beast_limit[self.select_id]
    local function call_back(sp)
        self.title.sprite = sp
        if not self.texlayer2 then
            self.texlayer2 = LayerManager:GetInstance():AddOrderIndexByCls(self, self.title.transform, nil, true, nil, nil, 4)
        end
    end
    lua_resMgr:SetImageTexture(self, self.title, 'beast_actvity_image', limitcfg.name, nil, call_back)

    if limitcfg.type == 1 then
        SetVisible(self.model_img, true)
        SetVisible(self.model_con, false)
        local function call_back(sp)
            self.model_img_img.sprite = sp
            if not self.texlayer then
                self.texlayer = LayerManager:GetInstance():AddOrderIndexByCls(self, self.model_img_img.transform, nil, true, nil, nil, 4)
            end
        end
        lua_resMgr:SetImageTexture(self, self.model_img_img, 'beast_actvity_image', limitcfg.model, nil, call_back)
    elseif limitcfg.type == 2 then
        SetVisible(self.model_img, false)
        SetVisible(self.model_con, true)
        if not self.ui_model then
            local cfg = {}
            cfg.pos = { x = -1994, y = -167.4, z = 500 }
            --cfg.scale = {x = ratio,y = ratio,z = ratio}
            cfg.trans_x = 900
            cfg.trans_y = 900
            cfg.trans_offset = { x = -126, y = 0 }
            cfg.carmera_size = 6
            self.ui_model = UIModelCommonCamera(self.model_con, nil, limitcfg.model, nil, false)
            self.ui_model:SetConfig(cfg)
            SetLocalScale(self.ui_model.transform, 1.6)
        end
    end

    lua_resMgr:SetImageTexture(self, self.desc, 'beast_actvity_image', limitcfg.desc)
    self:PlayAni1()
    for i = 1, #self.item_list do
        self.item_list[i]:destroy()
    end
    self.item_list = {}
    local mallcfg = Config.db_mall[self.select_id]
    local rewards = String2Table(mallcfg.item)
    for i = 1, #rewards do
        local item = GoodsIconSettorTwo(self.Content)
        local reward = rewards[i]
        local param = {}
        param["item_id"] = reward[1]
        param["num"] = reward[2]
        param["bind"] = reward[3]
        param["size"] = { x = 75, y = 75 }
        param["can_click"] = true
        item:SetIcon(param)
        self.item_list[i] = item
    end
    self.oldprice.text = String2Table(mallcfg.original_price)[2]
    self.price.text = String2Table(mallcfg.price)[2]
    local beast_list = {}
    if self.act_type == 2 then
        beast_list = self.model:GetGundamList()
    elseif self.act_type == 1 then
        beast_list = self.model:GetBeastList()
    end
    local mall_item = nil
    local end_time
    for i = 1, #beast_list do
        end_time = beast_list[i].end_time
        if beast_list[i].id == self.select_id then
            mall_item = beast_list[i]
            break
        end
    end
    if end_time then
        local param = {
            duration = 0.033,
            formatText = "%s",
            formatTime = "%d",
            isShowDay = true,
            isShowHour = true,
            isShowMin = true,
            isChineseType = true,
        }
        SetVisible(self.CountDown, true)
        if not self.countdown_item then
            self.countdown_item = CountDownText(self.CountDown, param)
            self.countdown_item:StartSechudle(end_time)
        end
    else
        SetVisible(self.CountDown, false)
    end
    if mall_item then
        SetVisible(self.btn_buy, true)
        SetVisible(self.btn_finish, false)
    else
        SetVisible(self.btn_buy, false)
        SetVisible(self.btn_finish, true)
    end
end

function BeastActivityPanel:CloseCallBack()
    if self.ui_model then
        self.ui_model:destroy()
        self.ui_model = nil
    end
    for i = 1, #self.item_list do
        self.item_list[i]:destroy()
    end
    self.item_list = nil
    if self.countdown_item then
        self.countdown_item:destroy()
        self.countdown_item = nil
    end

    GlobalEvent:RemoveTabListener(self.global_events)
    self.global_events = nil

    if self.texlayer then
        self.texlayer:destroy()
        self.texlayer = nil
    end
    if self.texlayer2 then
        self.texlayer2:destroy()
        self.texlayer2 = nil
    end

    if self.ui_effect then
        self.ui_effect:destroy()
        self.ui_effect = nil
    end
end
