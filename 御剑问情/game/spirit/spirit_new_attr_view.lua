-- 精灵属性
SpiritNewAttrView = SpiritNewAttrView or BaseClass(BaseRender)

function SpiritNewAttrView:__init(instance)
    self.level = self:FindVariable("level")
    self.name = self:FindVariable("name")
    self.item_obj = self:FindObj("item")
    self.item = ItemCell.New()
    self.item:SetInstanceParent(self.item_obj)
    self.on_auto = false
    self.attr = {}
    for i=1,3 do
        self.attr[i] = self:FindVariable("attr".. i)
    end
    self.processvalue = self:FindVariable("processvalue")
    self.show_button = self:FindVariable("ShowButton")
    self.max_process_value = self:FindVariable("max_process_value")
    self.cur_process_value = self:FindVariable("cur_process_value")

    self.fight_power = self:FindVariable("fight_power")

    self:ListenEvent("ClickAdvance",BindTool.Bind(self.ClickAdvance,self))
    self.button_string = self:FindVariable("button_string")
    self.button_string:SetValue(Language.Common.AutoUpgrade2[1])
    self.fight_power_value = 0
end

function SpiritNewAttrView:__delete()
    if self.item then
        self.item:DeleteMe()
        self.item = nil
    end
end

function SpiritNewAttrView:SetSpiritAttr(data)
    --print_error("刷新")
    if data == nil or data.param == nil then return end
    if self.cur_index == nil then
        self.cur_index = data.index
    end
    if self.cur_index ~= data.index then
        if nil ~= self.upgrade_timer_quest then
            if self.jinjie_next_time >= Status.NowTime then
                jinjie_next_time = self.jinjie_next_time - Status.NowTime
             end
            GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
        end
    end
    self.cur_index = data.index
    local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
    local spirit_info = SpiritData.Instance:GetSpiritInfo()
    --print_error(data.index)
    local spirit_level_cfg = SpiritNewSysData.Instance:GetLevelCfg()[data.index]
    local attr = CommonDataManager.GetAttributteNoUnderline(spirit_level_cfg)
    local had_base_attr = {}

    local attr_name = {[2] = "攻 击：",[3] ="防 御：",[1] = "生 命："}

    --print_error(spirit_level_cfg)
    if item_cfg and spirit_level_cfg then
        self.item:SetShowNumTxtLessNum(0)       --物品大于0显示数字
        self.item:SetData(SpiritNewSysData.Instance:GetUseItem().item_info)
        local attr_value = {[1] = spirit_level_cfg.maxhp,[2]=spirit_level_cfg.gongji,[3]=spirit_level_cfg.fangyu}
        for i,v in ipairs(self.attr) do
            v:SetValue(attr_name[i] .. attr_value[i])
        end
        local max_process_value = SpiritNewSysData.Instance:GetUseItem(data.index).need_num
        local cur_process_value = data.param.rand_attr_val_3 or 0

        self.processvalue:SetValue(cur_process_value / max_process_value)
        self.max_process_value:SetValue(max_process_value)
        self.cur_process_value:SetValue(cur_process_value)

        self.level_value = data.param.rand_attr_val_1 or 1
        local max_level = SpiritNewSysData.Instance:GetMaxGrade()
        self.show_button:SetValue(self.level_value < max_level)
        self.level:SetValue(self.level_value)
        local all_attr = spirit_level_cfg
        local fight_power = CommonDataManager.GetCapabilityCalculation(all_attr)
        self.fight_power:SetValue(fight_power)

        self.fight_power_value = fight_power
        -- self.have_num:SetValue(SpiritNewSysData.Instance:GetUseItem(self.cur_index).have_num)
        -- self.need_num:SetValue(SpiritNewSysData.Instance:GetUseItem(self.cur_index).need_num)
        local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">"..item_cfg.name.."</color>"
        self.name:SetValue(name_str)


        --仙宠比拼，当战力达到10000时请求活动信息
        local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.spirit_spirit)
        local is_act_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPIRIT)
        if fight_power > GameEnum.BIPIN_POWER_COND and not is_get_reward and is_act_open then
            KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPIRIT, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
        end
    end
end

function SpiritNewAttrView:CloseCallBack(flag)
    if not flag then
        if nil ~= self.upgrade_timer_quest then
        if self.jinjie_next_time >= Status.NowTime then
            jinjie_next_time = self.jinjie_next_time - Status.NowTime
        end
        GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
        end
    end
end

function SpiritNewAttrView:ClickAdvance()
    if self.on_auto then
        self.button_string:SetValue(Language.Common.AutoUpgrade2[1])
        self.on_auto = false
        if nil ~= self.upgrade_timer_quest then
            if self.jinjie_next_time >= Status.NowTime then
                jinjie_next_time = self.jinjie_next_time - Status.NowTime
            end
            GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
        end
    else
        self.on_auto = true
        self:CallOnStartAdvance()
    end
end

function SpiritNewAttrView:GetFightPower()
    if self.fight_power then
        local spirit_info = SpiritData.Instance:GetSpiritInfo()
        local spirit_list = spirit_info.jingling_list
        local fight_power = 0
        for k,v in pairs(spirit_list) do
            local spirit_level_cfg = SpiritNewSysData.Instance:GetLevelCfg()[v.index]
            if spirit_level_cfg then
                fight_power = fight_power + CommonDataManager.GetCapabilityCalculation(spirit_level_cfg)
            end
        end
        return fight_power
    end
    return 0
end

--区分出战与不出战仙宠战力
function SpiritNewAttrView:GetNewFightPower()
    local spirit_info = SpiritData.Instance:GetSpiritInfo()
    local spirit_list = spirit_info.jingling_list or {}
    local chuzhan_spirit_item_id = spirit_info.use_jingling_id

    local fight_power = 0
    for k,v in pairs(spirit_list) do
        if v.item_id == chuzhan_spirit_item_id then
            local spirit_level_cfg = SpiritNewSysData.Instance:GetLevelCfg()[v.index]
            if spirit_level_cfg then
                fight_power = fight_power + CommonDataManager.GetCapabilityCalculation(spirit_level_cfg)
            end
        else
            local no_fight_spirit_level_cfg = SpiritNewSysData.Instance:GetUnFightLevelCfg()[v.index]
            if no_fight_spirit_level_cfg then
                fight_power = fight_power + CommonDataManager.GetCapabilityCalculation(no_fight_spirit_level_cfg)
            end
        end
    end
    return fight_power
end

function SpiritNewAttrView:OnUpgradeResult(result)
    self.is_can_auto = true
    if 0 == result then
        self.button_string:SetValue(Language.Common.AutoUpgrade2[1])
        self.on_auto = false
    else
        if self.on_auto then
            self:AutoUpGradeOnce()
        end
    end
end

function SpiritNewAttrView:AutoUpGradeOnce()
    local jinjie_next_time = 0
    if nil ~= self.upgrade_timer_quest then
        if self.jinjie_next_time >= Status.NowTime then
            jinjie_next_time = self.jinjie_next_time - Status.NowTime
        end
        GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
    end

    if self.level_value <= SpiritNewSysData.Instance:GetMaxGrade() then
        --print_error("manzu")
        self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CallOnStartAdvance,self), jinjie_next_time)
    end
end

function SpiritNewAttrView:CallOnStartAdvance()
    --print_error("kaishi")
    local info = SpiritNewSysData.Instance:GetUseItem(self.cur_index)
    item_id = info.item_info.item_id
    if info.have_num > 0 and self.on_auto then
        self.button_string:SetValue(Language.Common.AutoUpgrade2[2])
        self.on_auto = true
        self.jinjie_next_time = Status.NowTime + (0.1)
        SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_CZ_UPGRADE,self.cur_index,0,info.pack_num)
    else
        -- local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
        -- if item_cfg == nil then

        --     return
        -- end
        self.on_auto = false
        self.button_string:SetValue(Language.Common.AutoUpgrade2[1])
        TipsCtrl.Instance:ShowItemGetWayView(item_id)
        -- if item_cfg.bind_gold == 0 then
        --     TipsCtrl.Instance:ShowShopView(item_id, 2)
        --     return
        -- end

        -- local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
        --     MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
        --     if is_buy_quick then
        --         self.auto_buy_toggle.toggle.isOn = true
        --     end
        -- end
        -- TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
        -- return
    end
end