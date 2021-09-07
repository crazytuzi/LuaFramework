IdentifyContentView = IdentifyContentView or BaseClass(BaseRender)

function IdentifyContentView:__init(instance)
	IdentifyContentView.Instance = self

	self.consume_exp 		= self:FindVariable("consume_exp")
	self.possess_exp 		= self:FindVariable("possess_exp")
	self.obtainable_exp 	= self:FindVariable("obtainable_exp")
	self.exchange_consume 	= self:FindVariable("exchange_consume")
	self.exchange_num 		= self:FindVariable("exchange_num")
	self.describe 			= self:FindVariable("describe")
	self.exchange_exp_btn	= self:FindObj("exchange_exp_btn")
	self.level_up_btn		= self:FindObj("level_up_btn")
	self.lbl_identify_level = self:FindVariable("level")

	self.cur_hp 			= self:FindVariable("cur_hp")
	self.cur_gongji 		= self:FindVariable("cur_gongji")
	self.cur_fangyu 		= self:FindVariable("cur_fangyu")
	self.cur_power 			= self:FindVariable("cur_power")
	self.next_hp 			= self:FindVariable("next_hp")
	self.next_gongji 		= self:FindVariable("next_gongji")
	self.next_fangyu 		= self:FindVariable("next_fangyu")
	self.star_progress 		= self:FindVariable("star_progress")
	self.gold_type 			= self:FindVariable("gold_type")
	self.is_max_level 		= self:FindVariable("is_max_level")
	self.present 			= self:FindVariable("present")

	self:ListenEvent("exchange_exp",BindTool.Bind(self.ExchangeExpOnClick, self))
	self:ListenEvent("click_help",BindTool.Bind(self.HelpOnClick, self))

	self.star_list = {}
	for i=1,10 do
		self.star_list[i] = self:FindObj("star"..i)
	end
	self.is_max_level:SetValue(false)
end

function IdentifyContentView:__delete()

end

function IdentifyContentView:HelpOnClick()
	local tips_id = 51 -- 鉴定帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function IdentifyContentView:SetStarListGray()
	local star_level = MagicWeaponData.Instance:GetLastIdentifyStarLevel()
	for i=1,10 do
		if i <= star_level then
			self.star_list[i].grayscale.GrayScale = 0
		else
			self.star_list[i].grayscale.GrayScale = 255
		end
	end

	self:FlusStarProperty()
end

function IdentifyContentView:FlusStarProperty()
	local cur_star_level = MagicWeaponData.Instance:GetLastIdentifyStarLevel()
	local cur_identify_level = MagicWeaponData.Instance:GetIdentifyLevel()
	local cur_star_level_cfg = MagicWeaponData.Instance:GetStarLevelCfg(cur_identify_level, cur_star_level)

	local next_star_level = cur_star_level + 1
	local next_identify_level = cur_identify_level
	if cur_star_level >= GameEnum.IDENTIFY_STAR_MAX_LEVEL then
		next_star_level = 1
		next_identify_level = next_identify_level + 1
	end

	--达到最大等级最大星级
	if cur_identify_level == GameEnum.IDENTIFY_MAX_LEVEL and cur_star_level == GameEnum.IDENTIFY_STAR_MAX_LEVEL then
		next_star_level = GameEnum.IDENTIFY_STAR_MAX_LEVEL
		next_identify_level = GameEnum.IDENTIFY_MAX_LEVEL
		self.is_max_level:SetValue(true)
	end
	local next_star_level_cfg = MagicWeaponData.Instance:GetStarLevelCfg(next_identify_level, next_star_level)

	local game_vo = GameVoManager.Instance:GetMainRoleVo()

	local cur_power_value = MagicWeaponData.Instance:GetStarCapacity(cur_star_level_cfg)

	self.cur_hp:SetValue(cur_star_level_cfg.maxhp)
	self.cur_gongji:SetValue(cur_star_level_cfg.gongji)
	self.cur_fangyu:SetValue(cur_star_level_cfg.fangyu)
	self.cur_power:SetValue(cur_power_value)

	self.next_hp:SetValue(next_star_level_cfg.maxhp - cur_star_level_cfg.maxhp)
	self.next_gongji:SetValue(next_star_level_cfg.gongji - cur_star_level_cfg.gongji)
	self.next_fangyu:SetValue(next_star_level_cfg.fangyu - cur_star_level_cfg.fangyu)
end

function IdentifyContentView:OpenCallBack()
	self.describe:SetValue(Language.EquipShen.TipShenzhouText)
	self:FlushAppraisalView()
end

function IdentifyContentView:LevelUpOnClick()
	MagicWeaponCtrl.Instance:SendMagicLevelUpReq(SHENZHOU_WEAPON_REQ_TYPE.SHENZHOU_WEAPON_REQ_TYPE_UPGRADE_IDENTIFY)
end

function IdentifyContentView:ExchangeExpOnClick()
	if UnityEngine.PlayerPrefs.GetInt("exchange_exp") == 1 then
		MagicWeaponCtrl.Instance:SendMagicLevelUpReq(SHENZHOU_WEAPON_REQ_TYPE.SHENZHOU_WEAPON_REQ_TYPE_EXCHANGE_IDENTIFY_EXP)
	else
		local func = function()
			self.is_click = false
			MagicWeaponCtrl.Instance:SendMagicLevelUpReq(SHENZHOU_WEAPON_REQ_TYPE.SHENZHOU_WEAPON_REQ_TYPE_EXCHANGE_IDENTIFY_EXP)
		end
		local identify_exp_cfg = MagicWeaponData.Instance:GetIdentifyExpCfg()
		local exchange_times = MagicWeaponData.Instance:GetTodayExchangeIdentifyExpTimes()
		local gold_num = identify_exp_cfg[exchange_times+1].consume_gold
		local tip_text = string.format(Language.EquipShen.ExchangeTips,gold_num)
		TipsCtrl.Instance:ShowCommonTip(func, nil, tip_text, nil, nil, true, false,"exchange_exp")
	end
end

-- flush ------------------------
function IdentifyContentView:FlushAppraisalView()
	self:SetStarListGray()
	local identify_exp_cfg = MagicWeaponData.Instance:GetIdentifyExpCfg()
	local exchange_times = MagicWeaponData.Instance:GetTodayExchangeIdentifyExpTimes()

	self.gold_type:SetAsset(ResPath.GetYuanBaoIcon(1))
	if exchange_times < #identify_exp_cfg then
		if identify_exp_cfg[exchange_times+1].consume_gold > 0 then
			self.gold_type:SetAsset(ResPath.GetYuanBaoIcon(0))
		end
	end

	if identify_exp_cfg ~= nil and next(identify_exp_cfg) ~= nil and self.exchange_consume ~= nil then
		if exchange_times < #identify_exp_cfg then
            --消耗元宝升级
            local gold_num = identify_exp_cfg[exchange_times+1].consume_gold
			self.exchange_consume:SetValue(gold_num)
			local reward_text = string.format("兑换可获得经验:<color=#00fd00ff>%s</color>",identify_exp_cfg[exchange_times+1].reward_exp)
			self.obtainable_exp:SetValue(reward_text)
			self.exchange_exp_btn.button.interactable = true
		else
			self.exchange_consume:SetValue(0)
			self.obtainable_exp:SetValue("今日兑换次数已用完")
			self.exchange_exp_btn.button.interactable = false
		end
		self.exchange_num:SetValue(#identify_exp_cfg - exchange_times)
	end

	local identify_level = MagicWeaponData.Instance:GetIdentifyLevel()
	local last_identify_level = MagicWeaponData.Instance:GetLastIdentifyLevel()
	local identify_level_cfg = MagicWeaponData.Instance:GetIdentifyLevelCfg()
	local cur_star_level = MagicWeaponData.Instance:GetLastIdentifyStarLevel()
	local star_level_cfg = MagicWeaponData.Instance:GetStarLevelCfg(identify_level, cur_star_level)

	local my_identify_exp = MagicWeaponData.Instance:GetIdentifyExp()
	if identify_level_cfg ~= nil and next(identify_level_cfg) ~= nil and self.possess_exp ~= nil
		and identify_level_cfg[identify_level+1] ~= nil and identify_level_cfg[identify_level+1].need_exp ~= nil then
		self.possess_exp:SetValue(my_identify_exp)
		self.consume_exp:SetValue(star_level_cfg.need_exp or 0)

		self.lbl_identify_level:SetValue(Language.EquipShen.Num[identify_level])
		self.star_progress:SetValue(my_identify_exp/star_level_cfg.need_exp)
		local present_value = math.floor(100 * (my_identify_exp/star_level_cfg.need_exp))
		self.present:SetValue(present_value .. "%")

		if my_identify_exp >= star_level_cfg.need_exp then

		 	if cur_star_level == GameEnum.IDENTIFY_STAR_MAX_LEVEL and identify_level == GameEnum.IDENTIFY_MAX_LEVEL then
		 		return
		 	end
			--自动升级
			self:LevelUpOnClick()
		end
	end

	if last_identify_level < identify_level then
		MagicWeaponData.Instance:SetLastIdentifyLevel(identify_level)
	end
end