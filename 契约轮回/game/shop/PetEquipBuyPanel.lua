---
--- Created by  Administrator
--- DateTime: 2020/4/13 14:29
---
PetEquipBuyPanel = PetEquipBuyPanel or class("PetEquipBuyPanel", BeastActivityPanel)
local this = PetEquipBuyPanel

function PetEquipBuyPanel:ctor(parent_node, parent_panel)
    self.abName = "beast_actvity"
    self.assetName = "PetEquipBuyPanel"
    self.layer = "UI"

    self.use_background = true
    self.change_scene_close = true
    self.select_id = 90201
    self.panel_type = 2
    self.item_list = {}
    self.act_type = 3
    self.global_events = {}
    self.model = ShopModel:GetInstance()

end

--function PetEquipBuyPanel:dctor()
--    GlobalEvent:RemoveTabListener(self.events)
--end

function PetEquipBuyPanel:LoadCallBack()
    self.nodes = {
        "menu_group/Toggle1", "menu_group/Toggle2", "menu_group/Toggle3", "menu_group/Toggle4",
        "desc", "bg2/Content", "model_img", "oldpricetitle/oldprice",
        "pricetitle/price", "CountDown", "btn_buy", "btn_close", "btn_finish", "effect",
        "timetitle", "model_con","powerObj/power",
    }
    self:GetChildren(self.nodes)
    SetVisible(self.btn_finish, false)
    self.Toggle1 = GetToggle(self.Toggle1)
    self.Toggle2 = GetToggle(self.Toggle2)
    self.Toggle3 = GetToggle(self.Toggle3)
    self.Toggle4 = GetToggle(self.Toggle4)
    self.power = GetText(self.power)
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
   -- LayerManager.GetInstance():AddOrderIndexByCls(self, self.title_bg.transform, nil, true, nil, nil, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.timetitle.transform, nil, true, nil, nil, 4)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.CountDown.transform, nil, true, nil, nil, 5)
end

function PetEquipBuyPanel:InitUI()

end

function PetEquipBuyPanel:AddEvent()
    local function call_back(target, value)
        if value then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.model_img.transform)
            self.select_id = 90201
            SetLocalPosition(self.model_img, -161.3, -12.6)
            self:UpdateView()
            self:PlayAni1()
        end
    end
    AddValueChange(self.Toggle1.gameObject, call_back)

    local function call_back(target, value)
        if value then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.model_img.transform)
            self.select_id = 90202
            SetLocalPosition(self.model_img, -120.65, -12.6)
            self:UpdateView()
            self:PlayAni()
        end
    end
    AddValueChange(self.Toggle2.gameObject, call_back)

    local function call_back(target, value)
        if value then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.model_img.transform)
            self.select_id = 90203
            SetLocalPosition(self.model_img, -120.65, 30.2)
            self:UpdateView()
            self:PlayAni3()
        end
    end
    AddValueChange(self.Toggle3.gameObject, call_back)

    local function call_back(target, value)
        if value then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.model_img.transform)
            self.select_id = 90204
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
        local message = string.format(" Cost %s diamonds to buy？", need_gold)
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


function PetEquipBuyPanel:UpdateView()
    local limitcfg = Config.db_beast_limit[self.select_id]
    self.power.text = limitcfg.power
    local function call_back(sp)
        self.title.sprite = sp
        if not self.texlayer2 then
            self.texlayer2 = LayerManager:GetInstance():AddOrderIndexByCls(self, self.title.transform, nil, true, nil, nil, 4)
        end
    end
    --lua_resMgr:SetImageTexture(self, self.title, 'beast_actvity_image', limitcfg.name, nil, call_back)

    if limitcfg.type == 1 then
        SetVisible(self.model_img, true)
        SetVisible(self.model_con, false)
        local function call_back(sp)
            self.model_img_img.sprite = sp
            if not self.texlayer then
                self.texlayer = LayerManager:GetInstance():AddOrderIndexByCls(self, self.model_img_img.transform, nil, true, nil, nil, 4)
            end
        end
        lua_resMgr:SetImageTexture(self, self.model_img_img, 'beast_actvity_image', "PetEquipBuy_model_"..self.select_id, nil, call_back)
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

    lua_resMgr:SetImageTexture(self, self.desc, 'beast_actvity_image', "PetEquipBuy_des_"..self.select_id)
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

        local item_cfg = Config.db_item[param["item_id"]]
        if item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
            --宠物装备特殊处理配置表
            param["cfg"] = Config.db_pet_equip[param["item_id"].."@"..1]
        end

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
    elseif self.act_type == 3 then
        beast_list = self.model:GetPetEquipList()
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