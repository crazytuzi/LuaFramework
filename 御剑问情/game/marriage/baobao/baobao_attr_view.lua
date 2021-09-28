BaoBaoAttrView = BaoBaoAttrView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
local BAOBAO_MAX_COUNT = 10    -- 可生宝宝最大数
function BaoBaoAttrView:__init(instance, mother_view)
    self:ListenEvent("UpGrade", BindTool.Bind(self.UpGradeClick, self, false))
    self:ListenEvent("AutoUpGrade", BindTool.Bind(self.AutoUpGradeClick, self))
    self:ListenEvent("ClickTitleShow", BindTool.Bind(self.ClickTitleShow, self))
	self:ListenEvent("ClickSpecial", BindTool.Bind(self.ClickSpecial, self))
	self:ListenEvent("ClickLittleTarget", BindTool.Bind(self.ClickLittleTarget, self))
    self.attr_t = {}
    self.attr_n = {}
    self.selectindex = 1
    for i = 1, 3 do
        self.attr_t[i] = self:FindVariable("Attr" .. i)
        self.attr_n[i] = self:FindVariable("NextAttr"..i)
    end

    self.temp_grade = {}
    for i=1, BAOBAO_MAX_COUNT do
         self.temp_grade[i] = -1
    end

    self.stuff = self:FindVariable("Stuff")
    self.item_stuff = self:FindVariable("ItemStuff")
    self.capacity = self:FindVariable("Cap")
    self.progress_txt = self:FindVariable("ProgressTxt")
    self.progress = self:FindVariable("Progress")
    self.auo_btn_name = self:FindVariable("AuoBtnName")
    self.up_btn_gray = self:FindVariable("UpBtnGray")
    self.auto_btn_gray = self:FindVariable("AutoBtnGray")
    self.auto_buy = self:FindObj("AutoBuy")
    self.all_next_att = self:FindObj("NextAtt")
    self.attr_count = self:FindObj("AttrCount")
    self.show_effect = self:FindVariable("ShowEffect")
	self.show_special_effect = self:FindVariable("ShowSpecialEffect")
	self.special_icon = self:FindVariable("SpecialIcon")
	self.is_active_super_baby = self:FindVariable("IsActiveSuperBaby")
	self.little_target_res = self:FindVariable("LittleTargetRes")
	self.can_fetch_little_target = self:FindVariable("CanFetchLittleTarget")
	self.show_little_target = self:FindVariable("ShowLittleTarget")
	self.show_super_baby = self:FindVariable("ShowSuperBaby")
	self.time_des = self:FindVariable("TimeDes")
    self.stuff_item = ItemCell.New()
    self.stuff_item:SetInstanceParent(self:FindObj("StuffItem"))
end

function BaoBaoAttrView:__delete()
    if nil ~= self.upgrade_timer_quest then
        GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
        self.upgrade_timer_quest = nil
    end

    if self.stuff_item then
        self.stuff_item:DeleteMe()
        self.stuff_item = nil
    end

    self.temp_grade = nil
    self.attr_t = nil
    self.attr_n = nil
    self.selectindex = nil
    self.stuff = nil
    self.capacity = nil
    self.progress_txt = nil
    self.progress = nil
    self.auo_btn_name = nil
    self.up_btn_gray = nil
    self.auto_btn_gray = nil
    self.auto_buy = nil
    self.all_next_att = nil
    self.attr_count = nil
    self.show_effect = nil
end

function BaoBaoAttrView:AutoUpGradeClick()
    if self.is_auto_upgrade then
        self.is_auto_upgrade = false
        self.up_btn_gray:SetValue(true)
        self.auo_btn_name:SetValue(self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
        return
    end
    self.selectindex = BaobaoData.Instance:GetSelectedBabyIndex()-- 记录谁被进阶
    local baby_list = BaobaoData.Instance:GetListBabyData() or {}
    if #baby_list <= 0 then
        SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.HaveNotBaby)
        return
    end
    local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
    if nil == baby_info then return end
        local baby_grade = baby_info.grade or 0
        local upgrade_cfg = BaobaoData.Instance:GetBabyUpgradeCfg(baby_grade)
        if upgrade_cfg == nil then return end
            local item_id = upgrade_cfg.consume_stuff_id
    if not self.auto_buy.toggle.isOn and ItemData.Instance:GetItemNumInBagById(item_id) < upgrade_cfg.consume_stuff_num then
        self:AutoBuyConfirm(item_id)
        return
    end
    self.is_auto_upgrade = true
    self.up_btn_gray:SetValue(false)
    self:AutoUpGradeOnce()

end

function BaoBaoAttrView:AutoBuyConfirm(item_id)
    local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
    MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
    self.auto_buy.toggle.isOn = is_buy_quick
    end
    TipsCtrl.Instance:ShowCommonBuyView(func, item_id, BindTool.Bind2(self.TipsCancelCallback, self), 1)
    return true
end

function BaoBaoAttrView:TipsCancelCallback()
    self.up_btn_gray:SetValue(true)
    self.is_auto_upgrade = false
    self.auo_btn_name:SetValue(self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
end

function BaoBaoAttrView:UpGradeClick(auto)
    local baby_list = BaobaoData.Instance:GetListBabyData() or {}
    if #baby_list <= 0 then
        SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.HaveNotBaby)
        return
    end
    -- if not ViewManager.Instance:IsOpen(ViewName.Marriage) then
        -- self.is_auto_upgrade = false
        -- self.up_btn_gray:SetValue(true)
        -- self.auo_btn_name:SetValue(self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
        -- return
    -- end
    local is_one_key = 0

    local selected_baby_index = BaobaoData.Instance:GetSelectedBabyIndex()
    if nil == selected_baby_index then return end
    local baby_info = BaobaoData.Instance:GetBabyInfo(selected_baby_index)
    if nil == baby_info then return end

    local baby_grade = baby_info.grade
    local baby_upgrade_cfg = BaobaoData.Instance:GetBabyUpgradeCfg(baby_grade)

    if baby_upgrade_cfg == nil then return end
    local next_time = baby_upgrade_cfg.next_time or 0

    if baby_grade ~= nil then
        local upgrade_all = BaobaoData.Instance:GetMaxBabyGrade()
        if baby_grade < upgrade_all then
            local is_auto_buy = self.auto_buy.toggle.isOn and 1 or 0
            if false == auto then
                is_one_key = 0
            elseif true == auto then
                is_one_key = 1
            end
            self.is_click_btn = true
            if not self.auto_buy.toggle.isOn and ItemData.Instance:GetItemNumInBagById(baby_upgrade_cfg.consume_stuff_id) < baby_upgrade_cfg.consume_stuff_num then
                self:AutoBuyConfirm(baby_upgrade_cfg.consume_stuff_id)
                return
            end
            BaobaoCtrl.Instance:SendBabyUpgradeReq(selected_baby_index - 1, is_auto_buy, 0)
            self.jinjie_next_time = Status.NowTime + next_time
        end
    end
end

function BaoBaoAttrView:CloseCallBack()
    if self.is_auto_upgrade then
        self:AutoUpGradeClick()
    end
    if nil ~= self.upgrade_timer_quest then
        GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
        self.upgrade_timer_quest = nil
    end
    self.show_effect:SetValue(false)
	self:StopCountDown()
end


function BaoBaoAttrView:AutoUpGradeOnce()
    local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
    if nil == baby_info then return end

    local baby_grade = baby_info.grade or 0
    local upgrade_all = BaobaoData.Instance:GetBabyUpgradeCfgLength()

    local jinjie_next_time = 0
    if nil ~= self.upgrade_timer_quest then
        if self.jinjie_next_time >= Status.NowTime then
            jinjie_next_time = self.jinjie_next_time - Status.NowTime
        end
        GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
    end

    if baby_grade >= 0 and baby_grade < upgrade_all then
        if self.is_auto_upgrade then
            self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.UpGradeClick,self,true), jinjie_next_time)
        end
    end
end

function BaoBaoAttrView:OnOperateResult(operate, result, param1, param2)
    if 0 == result then
        if self.is_auto_upgrade then
            self.is_auto_upgrade = false
            self.up_btn_gray:SetValue(true)
            self.auo_btn_name:SetValue(self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
        end
    elseif 1 == result then
        self:AutoUpGradeOnce()

    elseif 2 == result then
        if self.is_auto_upgrade then
            self.is_auto_upgrade = false
            self.up_btn_gray:SetValue(true)
            self.auo_btn_name:SetValue(self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
        end
    elseif 3 == result then
        if self.is_auto_upgrade then
            self.is_auto_upgrade = false
            self.up_btn_gray:SetValue(true)
        end
        self:FlushView()
    end
end

function BaoBaoAttrView:FlushAttr(value)
    if value then
        self.all_next_att:SetActive(true)
        self.attr_count:SetActive(false)
        self.attr_count:SetActive(true)
    else
        self.all_next_att:SetActive(false)
    end
end

-- 监听物品变化
function BaoBaoAttrView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
    local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
    if baby_info then
        local grade = baby_info.grade or 0
        local upgrade_cfg = BaobaoData.Instance:GetBabyUpgradeCfg(grade)
        if upgrade_cfg.consume_stuff_id and upgrade_cfg.consume_stuff_id == item_id then
            self:FlushView()
        end
    end
end

function BaoBaoAttrView:FlushView()
    self.auo_btn_name:SetValue(self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
    local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
    if nil == baby_info then
        self.progress_txt:SetValue("--/--")
        self.progress:SetValue(1)
        self.stuff:SetValue("")
        return
    end
    local cur_jie_attr = BaobaoData.Instance:GetBabyJieAttribute(baby_info.grade)
    local next_jie = baby_info.grade >= BaobaoData.Instance:GetMaxBabyGrade() and baby_info.grade or baby_info.grade + 1
    local next_jie_attr = BaobaoData.Instance:GetBabyJieAttribute(next_jie)
    local attr = BaobaoData.Instance:GetBabyInfoCfg(baby_info.baby_id)
    local change_attr = CommonDataManager.GetAttributteByClass(attr)
    local lerp_attr = CommonDataManager.LerpAttributeAttr(cur_jie_attr, next_jie_attr)    -- 属性差
    local had_next_jie = false
    if next_jie == baby_info.grade + 1 then
       had_next_jie = true
    end
    local index = 1
    for i,v in ipairs(BaobaoData.Attr) do
        if self.attr_t[index] and Language.Common.AttrName[v] then
            if tonumber(cur_jie_attr[v]) >= 0 then
                self.attr_t[index]:SetValue(cur_jie_attr[v] + change_attr[v] or 0)
                if had_next_jie and tonumber(lerp_attr[v]) >= 0 then
                    self.attr_n[index]:SetValue(lerp_attr[v] or 0)
                end
                index = index + 1
            end
        end
    end
    self:FlushAttr(had_next_jie)
	self.capacity:SetValue(CommonDataManager.GetCapabilityCalculation(cur_jie_attr)+CommonDataManager.GetCapabilityCalculation(attr))

    local baby_grade = baby_info.grade or 0
    local baby_bless = baby_info.bless or 0

    local upgrade_cfg = BaobaoData.Instance:GetBabyUpgradeCfg(baby_grade)
    if nil == upgrade_cfg then return end
    local item_num = ItemData.Instance:GetItemNumInBagById(upgrade_cfg.consume_stuff_id)
    local item_name = ItemData.Instance:GetItemName(upgrade_cfg.consume_stuff_id) or ""
    local color = upgrade_cfg.consume_stuff_num > item_num and "#ff0000" or "#ffe500"
    self.stuff:SetValue(string.format(Language.Marriage.BaobaoStuffTxt, item_name, upgrade_cfg.consume_stuff_num, color, item_num))
    self.item_stuff:SetValue(string.format(Language.Marriage.BaobaoStuff, color,item_num,upgrade_cfg.consume_stuff_num))
    self.stuff_item:SetData({item_id = upgrade_cfg.consume_stuff_id})

	if baby_bless >= 0 and 0 ~= upgrade_cfg.max_bless_value and baby_grade < 10 then
        self.progress_txt:SetValue(baby_bless .. "/" .. upgrade_cfg.max_bless_value)
        local percent = baby_bless / upgrade_cfg.max_bless_value
        self.progress:SetValue(percent)
    end
    if baby_info.grade >= BaobaoData.Instance:GetMaxBabyGrade() then
        self.progress_txt:SetValue(Language.Common.MaxLv)
        self.progress:SetValue(1)
        self.up_btn_gray:SetValue(false)
        self.auto_btn_gray:SetValue(false)
        self.stuff:SetValue(string.format(Language.Marriage.BaobaoStuffTxt, item_name, upgrade_cfg.consume_stuff_num, color, item_num))
    else
        if self.is_auto_upgrade then
            self.up_btn_gray:SetValue(false)
        else
            self.up_btn_gray:SetValue(true)
            self.auto_btn_gray:SetValue(true)
        end
    end

    local baby_list = BaobaoData.Instance:GetListBabyData() or {}
    local selected_index = BaobaoData.Instance:GetSelectedBabyIndex()
    local cur_baby_info = BaobaoData.Instance:GetBabyInfo(selected_index)
    if cur_baby_info then
        local baby_grade = cur_baby_info.grade
        for i=1,#baby_list do
            if selected_index == i then
                if self.temp_grade[i] ~= - 1 then
                    if self.temp_grade[i] < baby_grade then
                        -- 升级特效
                        if not self.effect_cd or self.effect_cd <= Status.NowTime then
                            self.show_effect:SetValue(false)
                            self.show_effect:SetValue(true)
                            self.effect_cd = EFFECT_CD + Status.NowTime
                        end
                    end
                end
                self.temp_grade[i] = baby_grade
            end
        end
    end

    if self.selectindex ~= BaobaoData.Instance:GetSelectedBabyIndex() then
        self.is_auto_upgrade = false
        self.up_btn_gray:SetValue(true)
        self.auo_btn_name:SetValue(self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
        self.selectindex = BaobaoData.Instance:GetSelectedBabyIndex()
        self:FlushView()
    end

	self:FlushSpecial()
end

function BaoBaoAttrView:StopCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end
function BaoBaoAttrView:StartCountDown()
	self.time_des:SetValue("")
	--小目标奖励可领取时不计时
	if BaobaoData.Instance:CanGetLittleTargetReward() then
		return
	end
	--可领取大目标或者已激活大目标则不计时
	if BaobaoData.Instance:CanGetSuperReward() or BaobaoData.Instance:IsActiveSuperBaby() then
		return
	end
	local other_cfg = BaobaoData.Instance:GetBabyOtherCfg()
	local total_time = other_cfg.award_super_baby_limit_time * 3600
	local left_time = BaobaoData.Instance:LeftTimeByTotalTime(total_time)
	if left_time <= 0 then
		--已超时不处理
		return
	end
	local des = TimeUtil.FormatBySituation(left_time)
	local function time_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self.time_des:SetValue("")
			return
		end
		left_time = total_time - math.floor(elapse_time)
		des = TimeUtil.FormatBySituation(left_time)
		des = string.format(Language.Common.FreeTimeDes, des)
		self.time_des:SetValue(des)
	end
	self.count_down = CountDown.Instance:AddCountDown(left_time, 1, time_func)
	--设置一次时间
	des = string.format(Language.Common.FreeTimeDes, des)
	self.time_des:SetValue(des)
end
function BaoBaoAttrView:FlushSpecial()
	self:StopCountDown()
	local other_cfg = BaobaoData.Instance:GetBabyOtherCfg()
	local is_fetch_little_target = BaobaoData.Instance:IsFetchLittleTarget()
	--设置小目标和大目标的隐藏显示
	self.show_super_baby:SetValue(is_fetch_little_target)
	self.show_little_target:SetValue(not is_fetch_little_target)
	--设置小目标是否激活
	local can_fetch_little_target = BaobaoData.Instance:CanGetLittleTargetReward()
	self.can_fetch_little_target:SetValue(can_fetch_little_target)
	--设置大目标是否激活和特效显示
	local is_active_super_baby = BaobaoData.Instance:IsActiveSuperBaby()
	self.show_special_effect:SetValue(not is_active_super_baby)
	self.is_active_super_baby:SetValue(is_active_super_baby)
	--设置小目标资源展示
	local item_cfg = ItemData.Instance:GetItemConfig(other_cfg.little_target_title_item)
	if nil ~= item_cfg then
		self.little_target_res:SetAsset(ResPath.GetTitleIcon(item_cfg.param1))
	end
	--设置大目标资源展示
	self.special_icon:SetAsset(ResPath.GetItemIcon(other_cfg.sup_baby_card_item_id))
	--设置计时
	self:StartCountDown()
end
function BaoBaoAttrView:ClickTitleShow()
    local baby_title_cfg = BaobaoData.Instance:GetBabyOtherCfg()
    if baby_title_cfg then
      TipsCtrl.Instance:OpenItem({item_id = baby_title_cfg.title_show})
    end
end
function BaoBaoAttrView:ClickSpecial()
	ViewManager.Instance:Open(ViewName.SuperBaoBaoView)
end
function BaoBaoAttrView:ClickLittleTarget()
	local function call_back(call_type)
		if call_type == TIME_LIMIT_TITLE_CALL_TYPE.BUY then
			BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_SUP_BABY_QIFU, nil, nil, nil, 1)
		elseif call_type == TIME_LIMIT_TITLE_CALL_TYPE.FETCH then
			BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_SUP_BABY_AWARD, nil, nil, nil, 1)
		end
	end
	local other_cfg = BaobaoData.Instance:GetBabyOtherCfg()
	local data = CommonStruct.TimeLimitTitleInfo()
	data.item_id = other_cfg.little_target_title_item
	data.cost = other_cfg.title_item_need_gold
	local total_time = other_cfg.award_super_baby_limit_time * 3600
	data.left_time = BaobaoData.Instance:LeftTimeByTotalTime(total_time)
	data.can_fetch = BaobaoData.Instance:CanGetLittleTargetReward()
	data.from_panel = TIME_LIMIT_TITLE_PANEL.BABY
	data.call_back = call_back
	TipsCtrl.Instance:ShowTimeLimitTitleView(data)
end