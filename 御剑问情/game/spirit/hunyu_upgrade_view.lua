HunYuUpGradeView = HunYuUpGradeView or BaseClass(BaseRender)

function HunYuUpGradeView:__init(instance)
	self.attackhunshouyu_lv = self:FindObj("attackhunshouyu_lv"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attackhunshouyu_cur_rate = self:FindObj("attackhunshouyu_cur_rate"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attackhunshouyu_next_rate = self:FindObj("attackhunshouyu_next_rate"):GetComponent(typeof(UnityEngine.UI.Text))
	self.defensehunshouyu_lv = self:FindObj("defensehunshouyu_lv"):GetComponent(typeof(UnityEngine.UI.Text))
	self.defensehunshouyu_cur_rate = self:FindObj("defensehunshouyu_cur_rate"):GetComponent(typeof(UnityEngine.UI.Text))
	self.defensehunshouyu_next_rate = self:FindObj("defensehunshouyu_next_rate"):GetComponent(typeof(UnityEngine.UI.Text))
	self.lifehunshouyu_lv = self:FindObj("lifehunshouyu_lv"):GetComponent(typeof(UnityEngine.UI.Text))
	self.lifehunshouyu_cur_rate = self:FindObj("lifehunshouyu_cur_rate"):GetComponent(typeof(UnityEngine.UI.Text))
	self.lifehunshouyu_next_rate = self:FindObj("lifehunshouyu_next_rate"):GetComponent(typeof(UnityEngine.UI.Text))

	self:ListenEvent("UpGardeAttackHunShouYu", BindTool.Bind(self.OnClickUpGardeAttackHunYu, self))
	self:ListenEvent("UpGardeDenfenseHunShouYu", BindTool.Bind(self.OnClickUpGardeDefenseHunYu, self))
	self:ListenEvent("UpGardeLifeHunShouYu", BindTool.Bind(self.OnClickUpGardeLifeHunYu, self))

	self.hunyu_type = {
	lifehunyu = 0,
	attackhunyu = 1,
	defensehunyu = 2
	}

	self.hunyu_max_level = 5

	self.text_upgrade_cost_list = {}
	self.text_hunyu_level_list = {}
	self.text_curattack_rate_list = {}
	self.text_nextattack_rate_list = {}
	self.is_hunyu_maxlevel = {}
	self.is_can_up_list = {}
	for i=HUNYU_TYPE.LIFE_HUNYU,HUNYU_TYPE.DEFENSE_HUNYU do
		self.text_upgrade_cost_list[i] = self:FindVariable("text_upgrade_cost_" .. i)
		self.text_hunyu_level_list[i] = self:FindVariable("text_hunyu_level_" .. i)
		self.text_curattack_rate_list[i] = self:FindVariable("text_curattack_rate_" .. i)
		self.text_nextattack_rate_list[i] = self:FindVariable("text_nextattack_rate_" .. i)
		self.is_hunyu_maxlevel[i] = self:FindVariable("is_hunyu_maxlevel" .. i)
		self.is_can_up_list[i] = self:FindVariable("is_can_up_" .. i)
	end
end

function HunYuUpGradeView:__delete()
	self.hunyu_type = nil
	self.attackhunshouyu_lv = nil
	self.attackhunshouyu_cur_rate = nil
	self.attackhunshouyu_next_rate = nil
	self.defensehunshouyu_lv = nil
	self.defensehunshouyu_cur_rate = nil
	self.defensehunshouyu_next_rate = nil
	self.lifehunshouyu_lv = nil
	self.lifehunshouyu_cur_rate = nil
	self.lifehunshouyu_next_rate = nil

	self.text_upgrade_cost_list = {}
	self.text_hunyu_level_list = {}
	self.text_curattack_rate_list = {}
	self.text_nextattack_rate_list = {}
	self.is_hunyu_maxlevel = {}
	self.is_can_up_list = {}
end

function HunYuUpGradeView:OnFlush()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local hunyu_level_list = spirit_info.hunyu_level_list
	local attackhunyu_level = hunyu_level_list[HUNYU_TYPE.ATTACK_HUNYU]
	local defensehunyu_level = hunyu_level_list[HUNYU_TYPE.DEFENSE_HUNYU]
	local lifehunyu_level = hunyu_level_list[HUNYU_TYPE.LIFE_HUNYU]

	if 0 == attackhunyu_level then
		self.attackhunshouyu_lv.text = "LV." ..attackhunyu_level
		self.attackhunshouyu_cur_rate.text = 0 .. "%"	
	end

	for i=HUNYU_TYPE.LIFE_HUNYU,HUNYU_TYPE.DEFENSE_HUNYU do
		-- 物品消耗描述
		local next_hunyu_level = hunyu_level_list[i] + 1
		local hunyu_level = hunyu_level_list[i]
		local hunyu_cfg = SpiritData.Instance:GetHunyuCfg(i, hunyu_level) or {}
		--local hunyu_next_cfg = hunyu_level_list[i] < self.hunyu_max_level and SpiritData.Instance:GetHunyuCfg(i, next_hunyu_level) or SpiritData.Instance:GetHunyuCfg(i, hunyu_level)
		local hunyu_next_cfg = SpiritData.Instance:GetHunyuCfg(i, next_hunyu_level) and SpiritData.Instance:GetHunyuCfg(i, next_hunyu_level) or SpiritData.Instance:GetHunyuCfg(i, hunyu_level)
		local item_id = hunyu_next_cfg.stuff_id or 0
		local item_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
		local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id)
		local cost_item_num = hunyu_next_cfg.stuff_num
		if SpiritData.Instance:GetHunyuMaxLevel() == hunyu_level then
			self.is_hunyu_maxlevel[i]:SetValue(true)
		end
		if have_item_num >= cost_item_num then
			self.is_can_up_list[i]:SetValue(true)
			local str = string.format(Language.JingLing.ZhenFaCostDesc, item_cfg.name or "",have_item_num or 0,cost_item_num or 0)
			self.text_upgrade_cost_list[i]:SetValue(str)
		else
			self.is_can_up_list[i]:SetValue(false)
			local str = string.format(Language.JingLing.ZHenFaHunYuLessCostDesc, item_cfg.name or "",have_item_num or 0,cost_item_num or 0)
			self.text_upgrade_cost_list[i]:SetValue(str)
		end
		-- 魂玉等级
		self.text_hunyu_level_list[i]:SetValue("LV." .. hunyu_level_list[i])
		--当前额外转换率

		local convert_rate = hunyu_cfg and hunyu_cfg.convert_rate or 0
		convert_rate = convert_rate / 100
		--convert_rate = ToColorStr(convert_rate, TEXT_COLOR.BLUE_SPECIAL)
		self.text_curattack_rate_list[i]:SetValue(string.format("%s%s", convert_rate, "%"))
		self.text_nextattack_rate_list[i]:SetValue(hunyu_next_cfg.convert_rate / 100 .. "%")
	end
end

function HunYuUpGradeView:OnClickUpGardeAttackHunYu()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_HUNYU,self.hunyu_type.attackhunyu)
end

function HunYuUpGradeView:OnClickUpGardeDefenseHunYu()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_HUNYU,self.hunyu_type.defensehunyu)
end

function HunYuUpGradeView:OnClickUpGardeLifeHunYu()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_HUNYU,self.hunyu_type.lifehunyu)
end