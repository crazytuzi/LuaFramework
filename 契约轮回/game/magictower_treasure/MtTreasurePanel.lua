--
-- @Author: LaoY
-- @Date:   2018-12-20 14:27:23
--
MtTreasurePanel = MtTreasurePanel or class("MtTreasurePanel", BasePanel)

function MtTreasurePanel:ctor()
    self.abName = "magictower_treasure"
    self.assetName = "MtTreasurePanel"
    self.layer = "UI"

    self.use_background = true
    self.change_scene_close = true
    self.panel_type = 1

    self.model = MagictowerTreasureModel:GetInstance()

    self.dungeon_type = enum.SCENE_STYPE.SCENE_STYPE_DUNGE_MAGICTOWER

    self.is_show_money = { Constant.GoldType.Gold, Constant.GoldType.BGold, Constant.GoldType.Coin }    --是否显示钱，不显示为false,默认显示元宝，绑完,金币可配置
    self.model_event_list = {}
    self.global_event_list = {}
end

function MtTreasurePanel:dctor()
    if self.model_event_list then
        self.model:RemoveTabListener(self.model_event_list)
        self.model_event_list = {}
    end

    if self.global_event_list then
        GlobalEvent:RemoveTabListener(self.global_event_list)
        self.global_event_list = {}
    end

    if self.money_list then
        for k, item in pairs(self.money_list) do
            item:destroy()
        end
        self.money_list = {}
    end

    if self.magic_card_1 then
        self.magic_card_1:destroy()
        self.magic_card_1 = nil
    end

    if self.magic_card_2 then
        self.magic_card_2:destroy()
        self.magic_card_2 = nil
    end

    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end

    if self.lua_link_image_text_1 then
        self.lua_link_image_text_1:destroy()
        self.lua_link_image_text_1 = nil
    end

    if self.lua_link_image_text_10 then
        self.lua_link_image_text_10:destroy()
        self.lua_link_image_text_10 = nil
    end

    self:RemoveEffect()
end

function MtTreasurePanel:Open()
    MtTreasurePanel.super.Open(self)
end

function MtTreasurePanel:LoadCallBack()
    self.nodes = {
        "btn_close", "money_con", "btn_time_10", "con/btn_book", "btn_time_1", "con/btn_log", "img_text_title_1_1/btn_help", "group/img_bar_bg_3_1/img_slider", "group/img_bar_bg_3_1/text_value",
        "text_des_1", "btn_time_1/img_text_bg/text_cost_1", "btn_time_10/img_text_bg/text_cost_10",
        "con", "img_text_title_1_1", "img_bg", "group", "group/img_text_btn", "con/toggle", "con/toggle/toggle_text",
        "group/text_des_2",
        "group/text_des_3",
        "group/img_bar_bg_3_1",
        "img_text_title_1_1/btn_proba"
    }
    self:GetChildren(self.nodes)

    self.img_bg_component = self.img_bg:GetComponent('Image')
    local res = "img_mtt_bg_1"
    lua_resMgr:SetImageTexture(self, self.img_bg_component, "iconasset/icon_big_bg_" .. res, res, false)

    self.text_des_1_component = self.text_des_1:GetComponent('Text')

    self.text_cost_1_component = GetLinkText(self.text_cost_1)
    self.lua_link_image_text_1 = LuaLinkImageText(self, self.text_cost_1_component)
    self.text_cost_10_component = GetLinkText(self.text_cost_10)
    self.lua_link_image_text_10 = LuaLinkImageText(self, self.text_cost_10_component)

    self.text_value_component = self.text_value:GetComponent('Text')

    self.img_slider_component = self.img_slider:GetComponent('Image')
    local percent = 0.5
    self.img_slider_component.fillAmount = percent

    self.toggle_component = self.toggle:GetComponent('Toggle')

    SetAlignType(self.con, bit.bor(AlignType.Left, AlignType.Bottom))
    SetAlignType(self.img_text_title_1_1, bit.bor(AlignType.Left, AlignType.Top))
    SetAlignType(self.btn_close, bit.bor(AlignType.Right, AlignType.Top))
    SetAlignType(self.group, bit.bor(AlignType.Null, AlignType.Bottom))
    SetAlignType(self.money_con, bit.bor(AlignType.Null, AlignType.Top))

    self.text_des_2_component = self.text_des_2:GetComponent('Text')
    self.text_des_2_component.text = "Buy Magic Crystals and get treasure hunt pills"
    self.text_des_3_component = self.text_des_3:GetComponent('Text')
    local cf = Config.db_game["mchunt_power_add"]
    self.text_des_3_component.text = string.format("Restore %spts/h until %s", cf and cf.value or 8, MtTreasureConstant.StarPowerMax)

    self.toggle_text_component = self.toggle_text:GetComponent('Text')
    self.toggle_text_component.text = "Totally random"

    -- self.magic_card_1 = MagicCardItem(self.img_bg)
    -- self.magic_card_2 = MagicCardItem(self.img_bg)
    -- self.magic_card_1:SetPosition(-346,-30)
    -- self.magic_card_2:SetPosition(345,-30)

    -- self.magic_card_1:SetScale(1.7)
    -- self.magic_card_2:SetScale(1.7)

    -- self.magic_card_1:SetRotation(10)
    -- self.magic_card_2:SetRotation(-14)

    local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
    local skip = CacheManager:GetBool(MtTreasureConstant.CacheSkipKey, false)
    SetVisible(self.toggle, lv >= MtTreasureConstant.SKipLevel)
    if lv < MtTreasureConstant.SKipLevel or not skip then
        self.is_skip = false
        self.toggle_component.isOn = false
    else
        self.is_skip = true
        self.toggle_component.isOn = true
    end

    self.red_dot = RedDot(self.btn_time_1)
    self.red_dot:SetPosition(105, 40)

    self:AddEvent()
    self:SetMoney(self.is_show_money)
end

function MtTreasurePanel:AddEvent()
    local function call_back(target, x, y)
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject, call_back)

    local function call_back(target, x, y)
        local tipInfo = HelpConfig.MtT.search
        ShowHelpTip(tipInfo, true)
    end
    AddClickEvent(self.btn_help.gameObject, call_back)

    local function call_back(target,x,y)
        lua_panelMgr:OpenPanel(ProbaTipPanel,2)
    end
    AddClickEvent(self.btn_proba.gameObject,call_back)

    local function call_back(target, x, y)
        -- Notify.ShowText("图鉴")
        BrocastModelEvent(CardEvent.HANDBOOK_OPEN);
    end
    AddClickEvent(self.btn_book.gameObject, call_back)

    local function call_back(target, x, y)
        -- Notify.ShowText("日志")
        lua_panelMgr:OpenPanel(MtTreasureRecordPanel)
    end
    AddClickEvent(self.btn_log.gameObject, call_back)

    local function call_back(target, x, y)
        if not self.model.mt_treasure_info then
            return
        end
        if self.model.mt_treasure_info.dig ~= 0 then
            Dialog.ShowOne("Tip", "You are participating in a magic card hunt, please finish the current hunt first", "Confirm", nil, 10)
            return
        end
        local function ok_func()
            self.model:Brocast(MagictowerTreasureEvent.REQ_HUNT, 1)
        end
        self.model:CheckGoods(self.cost_1, ok_func, true)
    end
    AddClickEvent(self.btn_time_1.gameObject, call_back)

    local function call_back(target, x, y)
        if not self.model.mt_treasure_info then
            return
        end
        if self.model.mt_treasure_info.dig ~= 0 then
            Dialog.ShowOne("Tip", "You are participating in a magic card hunt, please finish the current hunt first", "Confirm", nil, 10)
            return
        end
        local function ok_func()
            self.model:Brocast(MagictowerTreasureEvent.REQ_HUNT, 2)
        end
        self.model:CheckGoods(self.cost_2, ok_func, true)
    end
    AddClickEvent(self.btn_time_10.gameObject, call_back)

    local function call_back(target, x, y)
        -- Notify.ShowText("跳转")
        UnpackLinkConfig(MtTreasureConstant.LinkShopID)
        -- OpenLink(180,1,1,2,MtTreasureConstant.LinkShopID)
    end
    AddClickEvent(self.img_text_btn.gameObject, call_back)

    local function call_back(target, bool)
        Yzprint('--LaoY MtTreasurePanel.lua,line 155--', target, bool, self.toggle_component.isOn)
        self.is_skip = self.toggle_component.isOn
        CacheManager:SetBool(MtTreasureConstant.CacheSkipKey, self.is_skip)
        self.model.is_skip = self.is_skip
    end
    AddValueChange(self.toggle_component.gameObject, call_back)

    local function call_back()
        self:Close()
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MagictowerTreasureEvent.ACC_HUNT, call_back)

    local function call_back(id)
        self:SetValue()
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MagictowerTreasureEvent.UpdatePower, call_back)

    local function call_back(id)
        self:SetValue()
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MagictowerTreasureEvent.ACC_INFO, call_back)

    local function call_back(dungeon_type, data)
        if dungeon_type == self.dungeon_type then
            -- self:UpdateData(data)
            self:SetDungeonInfo()
        end
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonData, call_back)

    --    local function call_back(id)
    -- 	self:SetValue()
    -- end
    -- self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
end

function MtTreasurePanel:SetValue()
    local id = enum.ITEM.ITEM_MC_HUNT
    if not self.model.mt_treasure_info then
        return
    end
    local value = self.model.mt_treasure_info.power
    if self.goods_value == value then
        return
    end

    self.goods_value = value
    local percent = math.min(self.goods_value / MtTreasureConstant.StarPowerMax, 1)
    self.img_slider_component.fillAmount = percent
    self.text_value_component.text = string.format("%s/%s", self.goods_value, MtTreasureConstant.StarPowerMax)

    if percent >= 1 then
        self:AddEffect()
    else
        self:RemoveEffect()
    end
    -- local res_dot = self.model:GetReddotByIndex(1)

    local cost_id, cost = self.model:GetCostInfo(1)
    local cost_1_dot = self.model.mt_treasure_info.power >= cost * 4
    self.red_dot:SetRedDotParam(cost_1_dot)
end

function MtTreasurePanel:AddEffect()
    if not self.value_effect then
        self.value_effect = UIEffect(self.img_bar_bg_3_1, 20425, false)
    end
end

function MtTreasurePanel:RemoveEffect()
    if self.value_effect then
        self.value_effect:destroy()
        self.value_effect = nil
    end
end

function MtTreasurePanel:SetMoney(list)
    if table.isempty(list) then
        return
    end
    self.money_list = {}
    local offx = 220
    for i = 1, #list do
        local item = MoneyItem(self.money_con, nil, list[i])
        local x = (i - #list) * offx
        local y = 0
        item:SetPosition(x, y)
        self.money_list[i] = item
    end
end

function MtTreasurePanel:OpenCallBack()
    self:UpdateView()
    self:SetValue()
end

function MtTreasurePanel:UpdateView()
    local cf_1 = Config.db_mchunt[1]

    -- self.text_des_2_component.text = "100%\n得橙色"

    self:SetDungeonInfo()
    self:SetInfo()

end

function MtTreasurePanel:SetInfo()
    local cf_1 = Config.db_mchunt[1]
    local cf_2 = Config.db_mchunt[2]

    local cost_1 = String2Table(cf_1.cost)[1]
    local cost_2 = String2Table(cf_2.cost)[1]
    self.cost_1 = cost_1[2]
    self.cost_2 = cost_2[2]

    local item_cf = Config.db_item[cost_1[1]]
    local icon_html = GoodIconUtil:GetGoodsIconHtml(cost_1[1], 35)
    local str_1 = string.format('Cost %s<color=#fdff3c>%s</color>', icon_html, cost_1[2])
    self.text_cost_1_component.text = str_1

    local item_cf = Config.db_item[cost_2[1]]
    local icon_html = GoodIconUtil:GetGoodsIconHtml(cost_2[1], 35)
    local str_2 = string.format('Cost %s<color=#fdff3c>%s</color>', icon_html, cost_2[2])
    self.text_cost_10_component.text = str_2
end

function MtTreasurePanel:SetDungeonInfo()
    local data = DungeonModel:GetInstance().dungeon_info_list[self.dungeon_type]
    local cur_floor = 0
    if data then
        cur_floor = data.info.cur_floor
    end

    local show_reward
    local cf_1 = Config.db_mchunt[1]
    local reward_list = String2Table(cf_1.reward)
    local icon_str = ""
    for i = 1, #reward_list do
        local reward = reward_list[i]
        if cur_floor >= reward[2] then
            local item_cf = Config.db_item[reward[1]]
            if reward[3] and reward[4] and reward[3] == reward[4] then
                icon_str = icon_str .. string.format('<color=#%s>%s</color> %s ', ColorUtil.GetColor(item_cf.color), item_cf.name, reward[3])
            elseif reward[3] and reward[4] then
                icon_str = icon_str .. string.format('<color=#%s>%s</color> %s ~ %s ', ColorUtil.GetColor(item_cf.color), item_cf.name, reward[3], reward[4])
            end
        end
    end
    self.text_des_1_component.text = "hunt will guarantee" .. icon_str

    -- if show_reward then
    -- 	local item_cf = Config.db_item[show_reward[1]]
    -- 	if show_reward[3] and show_reward[4] and show_reward[3] == show_reward[4] then
    -- 		icon_str = string.format('<color=#%s>%s</color>%s个',ColorUtil.GetColor(item_cf.color),item_cf.name,show_reward[3])
    -- 	else
    -- 		icon_str = string.format('<color=#%s>%s</color>%s ~ %s个',ColorUtil.GetColor(item_cf.color),item_cf.name,show_reward[3],show_reward[4])
    -- 	end

    -- 	self.text_des_1_component.text = "每次寻宝必获得" .. icon_str
    -- end

    -- local card_show = String2Table(cf_1.card_show)
    -- card_show = card_show[1]
    -- local card_cf_1 = Config.db_magic_card[card_show[1]]
    -- local card_cf_2 = Config.db_magic_card[card_show[2]]

    -- self.magic_card_1:UpdateData(card_cf_1)
    -- self.magic_card_2:UpdateData(card_cf_2)
end

function MtTreasurePanel:CloseCallBack()

end