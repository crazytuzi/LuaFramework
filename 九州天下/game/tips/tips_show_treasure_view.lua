TipShowTreasureView = TipShowTreasureView or BaseClass(BaseView)

local ROW = 10
local COLUMN = 5
local MAX_NUM = 50

TREASURE_TYPE =
{
	XUNBAO = 1,
	JING_LING = 2,
	MOKA = 3,
	PET = 4,
	SWORD = 5,
	RUNE = 6,
	RUNE_BAOXIANG = 7,
	SHEN_GE_BLESS = 8,
	ERNIE_BLESS = 9,			-- 摇奖机
	NORMAL = 10,			-- 通用普通类型

	BEAUTY = 11,
	GENERAL = 12,

	JINYINTA = 13,			-- 金银塔抽奖
	JINYINTA_REWARD = 14,	-- 金银塔累计抽奖
	ZHUANZHUANLE = 15,       --转转乐抽奖
	ZHUANZHUANLE_REWARD = 16,	-- 转转乐累计抽奖
	GUAJITA_REWARD = 17,	-- 副本塔扫荡
	FANFANZHUAN = 18,			-- 翻翻转奖励
	LUCK_CHESS = 19,			-- 幸运棋
	GIFT = 20,
	LUCKY_TURNTABLE = 21,		-- 幸运转盘
	HAPPY_LOTTERY = 22,			-- 欢乐抽
	ADVENTURE_SHOP = 23,
	MID_AUTUMN_LOTTERY = 24,    --月饼大作战
	LITTLE_PET = 25,
	LUCKY_TURN_EGG = 26,		-- 幸运扭蛋机
	LUCKY_TURN_EGG_REWARD = 27,	-- 幸运扭蛋机
	LUCKY_BOX = 28,				-- 幸运宝箱抽奖
	LUCKY_BOX_REWARD = 29,		-- 幸运宝箱累计抽奖	
	DASHE_TIAN_XIA = 30,		-- 大射天下抽奖
	DASHE_TIAN_XIA_REWARD = 31,	-- 大赦天下累计抽奖
	SYMBOL = 32, 				-- 五行之灵
	SYMBOL_NIUDAN = 33, 		-- 五行之灵扭蛋
}

function TipShowTreasureView:__init()
	self.ui_config = {"uis/views/tips/showtreasuretips", "ShowTreasureTips"}
	self:SetMaskBg(true)
	TipShowTreasureView.Instance = self
	self.current_grid_index = -1
	self.chest_shop_mode = nil
	self.play_audio = true
	self.contain_cell_list = {}
	self.view_layer = UiLayer.Pop
	self.no_play_ani_list = {}
	self.gift_data_list = {}
	self.is_show_pingbi = false
	self.hook_call = nil
end

function TipShowTreasureView:__delete()
	TipShowTreasureView.Instance = nil
end

function TipShowTreasureView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.TreasureReward)
	end

	for k, v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
	self.is_show_pingbi = false
	self.hook_call = nil

	-- 清理变量和对象
	self.list_view = nil
	self.page_toggle_1 = nil
	self.effect_1 = nil
	self.text_animator = nil
	self.btn_text_1 = nil
	self.btn_text_2 = nil
	self.is_play_ani = nil
	self.show_toggle_list = nil
	self.list_view = nil
	self.back_warehouse_btn = nil
	self.show_one_btn = nil
	self.show_pingbi = nil
	self.show_hook = nil
	self.check_obj = nil
	self.gift_data_list = {}
end

function TipShowTreasureView:LoadCallBack()
	self.contain_cell_list = {}
	self.list_view = self:FindObj("list_view")
	self:ListenEvent("close_tips_click",BindTool.Bind(self.OnCloseTipsClick, self))
	self:ListenEvent("back_warehouse_click",BindTool.Bind(self.OnBackWareHouseClick, self))
	self:ListenEvent("again_click",BindTool.Bind(self.OnAgainClick, self))
	self:ListenEvent("OneClick",BindTool.Bind(self.OneClick, self))

	self.page_toggle_1 = self:FindObj("page_toggle_1")
	self.effect_1 = self:FindObj("EffectRoot")
	self.text_animator = self:FindObj("text_frame").animator

	self.btn_text_1 = self:FindVariable("btn_text_1")
	self.btn_text_2 = self:FindVariable("btn_text_2")
	self.is_play_ani = self:FindVariable("is_play_ani")
	self.show_one_btn = self:FindVariable("ShowOneBtn")

	self.show_pingbi = self:FindVariable("ShowPingBi")
	self.show_hook = self:FindVariable("ShowHook")
	self:ListenEvent("OnClickHook",BindTool.Bind(self.OnClickHook, self))

	self.check_obj = self:FindObj("CheckObj")

	self.show_toggle_list = {}
	for i=1,5 do
		self.show_toggle_list[i] = self:FindVariable("show_page_toggle_"..i)
	end
	self:InitListView()

	--引导用按钮
	self.back_warehouse_btn = self:FindObj("BackWareHouseBtn")

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.TreasureReward, BindTool.Bind(self.GetUiCallBack, self))
end

function TipShowTreasureView:OnClickHook()
	local treasure_type = self:GetTreasureType()
	if treasure_type == nil then
		return
	end

	if self.is_show_pingbi and treasure_type ~= nil then
		if self.no_play_ani_list[treasure_type] == nil then
			self.no_play_ani_list[treasure_type] = false
		end

		local flag = self.no_play_ani_list[treasure_type]
		if flag ~= nil then
			self.no_play_ani_list[treasure_type] = not flag
			if self.show_hook ~= nil then
				self.show_hook:SetValue(not flag)
			end
		end
	end
end

function TipShowTreasureView:GetPlayAniFlag(treasure_type)
	local is_play = false
	if treasure_type ~= nil then
		is_play = self.no_play_ani_list[treasure_type] or false
	end

	return is_play
end

function TipShowTreasureView:SetPlayAniFlag(treasure_type, value)
	if treasure_type ~= nil then
		self.no_play_ani_list[treasure_type] = value or false
	end	
end

--判断能否播放动画
function TipShowTreasureView:IsPlayAni()

	local is_no_ani = MagicCardData.Instance:GetIsNoAni()

	local treasure_type = self:GetTreasureType()
	if treasure_type ~= nil then
		if self.no_play_ani_list[treasure_type] ~= nil then
			return not self.no_play_ani_list[treasure_type]
		end
	end
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_PET_10 and PetData.Instance:GetIsMask() then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1 and is_no_ani then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_5 and is_no_ani then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_10 and is_no_ani then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_1 and is_no_ani then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_5 and is_no_ani then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_10 and is_no_ani then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_1 and is_no_ani then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_5 and is_no_ani then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_10 and is_no_ani then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50  then
		return not TreasureData.Instance:GetIsShield()
	elseif (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_50) and SpiritData.Instance:IsNoPlayAni() then
		return false
	elseif (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_10) and RuneData.Instance:IsStopPlayAni() then
		return false
	elseif (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10) and not ShenGeData.Instance:GetBlessAniState() then
		return false
	elseif (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_10) and ShengXiaoData.Instance:GetErnieIsStopPlayAni() then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_10 then
		return ZhuangZhuangLeData.Instance:GetAniState()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAN_LUCKY_TURNTABLE then
		return LuckyTurntableData.Instance:GetAniState()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_HAPPY_LOTTERY_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_HAPPY_LOTTERY_10 then 
		return HappyBargainData.Instance:GetAniState()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_10 then
		return MidAutumnLotteryData.Instance:GetAnimState()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_MODE_10 then
		return LuckyTurnEggData.Instance:GetAniState()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_DASHE_TIAN_XIA_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_DASHE_TIAN_XIA_MODE_10 then
		return DaSheTianXiaData.Instance:GetAniState()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_lUCKY_BOX_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_lUCKY_BOX_10 then
		return LuckyBoxData.Instance:GetAniState()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL_NIUDAN then
		return false
	end
	return true
end

function TipShowTreasureView:CheckToPlayAni()
	if self.play_count_down then
		CountDown.Instance:RemoveCountDown(self.play_count_down)
		self.play_count_down = nil
	end
	if self:IsPlayAni() then
		self.star_ani = false
		self.root_node:GetComponent(typeof(UnityEngine.CanvasGroup)).alpha = 0
		self.is_play_ani:SetValue(true)

		--开始播放获取特效
		GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.StartPlayEffect, self), 0.5)
	else
		self.root_node:GetComponent(typeof(UnityEngine.CanvasGroup)).alpha = 1
		self.is_play_ani:SetValue(false)

		local treasure_type = self:GetTreasureType()
		if treasure_type ~= nil and self.is_show_pingbi then
			if self.show_hook ~= nil then
				self.show_hook:SetValue(self.no_play_ani_list[treasure_type] or false)
			end			
		end
	end


	-- if self.is_show_pingbi then
	-- 	self.check_obj.transform.localPosition = Vector3(349, -69, 0)
	-- else
	-- 	self.check_obj.transform.localPosition = Vector3(0, 0, 0)
	-- end
end

function TipShowTreasureView:OpenCallBack()
	self:ChangeBtnCount()
	self:SetTreasureType()
	self.page_toggle_1.toggle.isOn = true
	self.text_animator:SetBool("is_open", true)
	for i=1,5 do
		self.show_toggle_list[i]:SetValue(true)
	end
	local count = self:GetShowCount()
	if count <= 10 then
		self:SetToggleActiveFalse(1,5)
	elseif count > 10 and count <= 20 then
		self:SetToggleActiveFalse(3,5)
	elseif count > 20 and count <= 30 then
		self:SetToggleActiveFalse(4,5)
	elseif count > 30 and count <= 40 then
		self:SetToggleActiveFalse(5,5)
	end

	if self.is_show_pingbi and count > 10 then
		self.check_obj.transform.localPosition = Vector3(349, -69, 0)
	else
		self.check_obj.transform.localPosition = Vector3(0, 0, 0)
	end

	self.list_view.scroller:ReloadData(0)

	if self.show_pingbi ~= nil then
		self.show_pingbi:SetValue(self.is_show_pingbi or false) 
	end

	self:CheckToPlayAni()
	-- GlobalTimerQuest:AddDelayTimer(function()
	-- 	self:PlayEffect()
	-- end, 0.5)
end

function TipShowTreasureView:PlayEffect()
	-- EffectManager.Instance:PlayAtTransformCenter(
	-- 	"effects2/prefab/ui_prefab",
	-- 	"UI_choujiang_011",
	-- 	self.effect_1.transform,
	-- 	1)
end

function TipShowTreasureView:OnFlush()
	self:SetTreasureType()
	self.page_toggle_1.toggle.isOn = true
	-- self.text_animator:SetBool("is_open", true)
	for i=1,5 do
		self.show_toggle_list[i]:SetValue(true)
	end
	local count = self:GetShowCount()
	if count <= 10 then
		self:SetToggleActiveFalse(1,5)
	elseif count > 10 and count <= 20 then
		self:SetToggleActiveFalse(3,5)
	elseif count > 20 and count <= 30 then
		self:SetToggleActiveFalse(4,5)
	elseif count > 30 and count <= 40 then
		self:SetToggleActiveFalse(5,5)
	end

	if self.is_show_pingbi and count > 10 then
		self.check_obj.transform.localPosition = Vector3(349, -69, 0)
	else
		self.check_obj.transform.localPosition = Vector3(0, 0, 0)
	end

	self.list_view.scroller:ReloadData(0)
end

function TipShowTreasureView:LoadEffect(item_num, group_cell, obj)
	if not obj then
		return
	end
	if not group_cell or group_cell:IsNil() then
		GameObjectPool.Instance:Free(obj)
		return
	end
	local transform = obj.transform
	transform:SetParent(group_cell:GetTransForm(item_num), false)
	local function Free()
		if IsNil(obj) then
			return
		end
		GameObjectPool.Instance:Free(obj)
	end
	GlobalTimerQuest:AddDelayTimer(Free, 1)
end

function TipShowTreasureView:PlayTime(group_cell, count, elapse_time, total_time)
	if self.step >= count or elapse_time >= total_time then
		self.is_play_ani:SetValue(false)
		if self.play_count_down then
			CountDown.Instance:RemoveCountDown(self.play_count_down)
			self.play_count_down = nil
		end
		return
	end
	self.step = self.step + 1

	local item_num = self.step
	GameObjectPool.Instance:SpawnAsset("effects2/prefab/ui/ui_choujiang_01_prefab", "UI_choujiang_01", BindTool.Bind(self.LoadEffect, self, item_num, group_cell))

	group_cell:SetAlpha(self.step, 1)
end

function TipShowTreasureView:StartPlayEffect()
	self.root_node:GetComponent(typeof(UnityEngine.CanvasGroup)).alpha = 1
	for k, v in pairs(self.contain_cell_list) do
		--只有第一页有动画

		if v:GetPage() == 1 and not v:IsNil() then
			--先隐藏item
			self.star_ani = true
			local count = self:GetShowCount()
			count = count > 10 and 10 or count
			for i = 1, count do
				v:SetAlpha(i, 0)
			end
			--创建计时器分步显示item
			self.step = 0
			self.play_count_down = CountDown.Instance:AddCountDown(10, 0.17, BindTool.Bind(self.PlayTime, self, v, count))
		end
	end
	if not self.star_ani then
		if self.play_count_down then
			CountDown.Instance:RemoveCountDown(self.play_count_down)
			self.play_count_down = nil
		end
		self.is_play_ani:SetValue(false)
	end
end

function TipShowTreasureView:GetTreasureType()
	return self.treasure_type
end

--是否只展示一个按钮
function TipShowTreasureView:ChangeBtnCount()
	local show_one_btn = false
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE then
		show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_GET_REWARD then
		show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_GET_REWARD then
		show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_GET_REWARD then
		show_one_bth = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GUAJITA_REWARD then
		show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_GIFT then
		show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAN_ADVENTURE_SHOP then
		show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_DASHE_TIAN_XIA_GET_REWARD then
		show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL then
		show_one_btn = true
	end

	self.show_one_btn:SetValue(show_one_btn)
end

function TipShowTreasureView:SetTreasureType()
	local btn_text_1_value = Language.RechargeChouChouLe.BackWareHouse
	local btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50 then
		self.treasure_type = TREASURE_TYPE.XUNBAO
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_50 then
		self.treasure_type = TREASURE_TYPE.JING_LING
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_5 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		self.treasure_type = TREASURE_TYPE.MOKA
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_5 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		self.treasure_type = TREASURE_TYPE.MOKA
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_5 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		self.treasure_type = TREASURE_TYPE.MOKA
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_PET_10 then
		self.treasure_type = TREASURE_TYPE.PET
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SWORD_BIND_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_10 then
		self.treasure_type = TREASURE_TYPE.SWORD
		btn_text_1_value = Language.RechargeChouChouLe.Back
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_1 then
		self.treasure_type = TREASURE_TYPE.RUNE
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_10 then
		self.treasure_type = TREASURE_TYPE.RUNE
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_BAOXIANG_MODE then
		self.treasure_type = TREASURE_TYPE.RUNE_BAOXIANG
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1 then
		self.treasure_type = TREASURE_TYPE.SHEN_GE_BLESS
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10 then
		self.treasure_type = TREASURE_TYPE.SHEN_GE_BLESS
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_1 then
		self.treasure_type = TREASURE_TYPE.ERNIE_BLESS
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_10 then
		self.treasure_type = TREASURE_TYPE.ERNIE_BLESS
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE then
		self.treasure_type = TREASURE_TYPE.NORMAL
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_BEAUTY_PRAY10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_BEAUTY_PRAY1 then
		self.treasure_type = TREASURE_TYPE.BEAUTY
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_1
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_10
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_50 then
		self.treasure_type = TREASURE_TYPE.GENERAL
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_1 then
		self.treasure_type = TREASURE_TYPE.JINYINTA
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_10 then
		self.treasure_type = TREASURE_TYPE.JINYINTA
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_GET_REWARD then
		self.treasure_type = TREASURE_TYPE.JINYINTA_REWARD
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_1 then
		self.treasure_type = TREASURE_TYPE.ZHUANZHUANLE
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_10 then
		self.treasure_type = TREASURE_TYPE.ZHUANZHUANLE
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_GET_REWARD then
		self.treasure_type = TREASURE_TYPE.ZHUANZHUANLE_REWARD
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GUAJITA_REWARD then
		self.treasure_type = TREASURE_TYPE.GUAJITA_REWARD -- zcz
		btn_text_1_value = Language.RechargeChouChouLe.Sure
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.FANFANZHUAN
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_50 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.FANFANZHUAN
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCK_CHESS_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.LUCK_CHESS
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_GIFT then
		self.treasure_type = TREASURE_TYPE.GIFT
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAN_LUCKY_TURNTABLE then
		self.treasure_type = TREASURE_TYPE.LUCKY_TURNTABLE
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_HAPPY_LOTTERY_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_HAPPY_LOTTERY_10 then
		self.treasure_type = TREASURE_TYPE.HAPPY_LOTTERY
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAN_ADVENTURE_SHOP then
		self.treasure_type = TREASURE_TYPE.ADVENTURE_SHOP
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_10 then
		self.treasure_type = TREASURE_TYPE.MID_AUTUMN_LOTTERY
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_1 then
		self.treasure_type = TREASURE_TYPE.LITTLE_PET
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_10 then
		self.treasure_type = TREASURE_TYPE.LITTLE_PET
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_lUCKY_BOX_1 then
		self.treasure_type = TREASURE_TYPE.LUCKY_BOX
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_lUCKY_BOX_10 then
		self.treasure_type = TREASURE_TYPE.LUCKY_BOX
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_lUCKY_BOX_GET_REWARD then
		self.treasure_type = TREASURE_TYPE.LUCKY_BOX_REWARD
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_MODE_10 then
		self.treasure_type = TREASURE_TYPE.LUCKY_TURN_EGG
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_GET_REWARD then
		self.treasure_type = TREASURE_TYPE.LUCKY_TURN_EGG_REWARD
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_DASHE_TIAN_XIA_MODE_1 then
		self.treasure_type = TREASURE_TYPE.DASHE_TIAN_XIA
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_DASHE_TIAN_XIA_MODE_10 then
		self.treasure_type = TREASURE_TYPE.DASHE_TIAN_XIA
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_DASHE_TIAN_XIA_GET_REWARD then
		self.treasure_type = TREASURE_TYPE.DASHE_TIAN_XIA_REWARDs
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		self.treasure_type = TREASURE_TYPE.SYMBOL
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL_NIUDAN then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.SYMBOL_NIUDAN
	end
	self.btn_text_1:SetValue(btn_text_1_value)
	self.btn_text_2:SetValue(btn_text_2_value)
end

function TipShowTreasureView:GetData(index)
	local data = {}
	if self.treasure_type == TREASURE_TYPE.XUNBAO then
		data = TreasureData.Instance:GetSplitChestShopItemInfo()[index]
	elseif self.treasure_type == TREASURE_TYPE.JING_LING then
		data = SpiritData.Instance:GetHuntSpiritItemList()[index]
	elseif self.treasure_type == TREASURE_TYPE.MOKA then
		data = MagicCardData.Instance:GetLottoData()[index]
	elseif self.treasure_type == TREASURE_TYPE.PET then
		list = PetData.Instance:GetRewardList()[index]
		data = ItemData.Instance:GetItemConfig(list.item_id)
		data.item_id = list.item_id
		data.is_bind = list.is_bind
		data.num = list.item_num
	elseif self.treasure_type == TREASURE_TYPE.SWORD then
		data = SwordArtOnlineData.Instance:GetBuyLottoData()[index]
	elseif self.treasure_type == TREASURE_TYPE.RUNE then
		data = RuneData.Instance:GetTreasureList()[index]
	elseif self.treasure_type == TREASURE_TYPE.RUNE_BAOXIANG then
		data = RuneData.Instance:GetBaoXiangList()[index]
	elseif self.treasure_type == TREASURE_TYPE.SHEN_GE_BLESS then
		data = ShenGeData.Instance:GetShenGeBlessRewardDataList()[index]
	elseif self.treasure_type == TREASURE_TYPE.ERNIE_BLESS then
		data = ShengXiaoData.Instance:GetErnieBlessRewardDataList()[index]
	elseif self.treasure_type == TREASURE_TYPE.NORMAL then
		data = ItemData.Instance:GetNormalRewardList()[index]
	elseif self.treasure_type == TREASURE_TYPE.BEAUTY then
		data = BeautyData.Instance:GetPrayItemList()[index]
	elseif self.treasure_type == TREASURE_TYPE.GENERAL then
		data = FamousGeneralData.Instance:GetItemList()[index]
	elseif self.treasure_type == TREASURE_TYPE.JINYINTA then
		data = JinYinTaData.Instance:GetLevelLotteryRewardList()[index]
	elseif self.treasure_type == TREASURE_TYPE.JINYINTA_REWARD then
		data = JinYinTaData.Instance:GetLeiJiRewardList()[index - 1]
	elseif self.treasure_type == TREASURE_TYPE.ZHUANZHUANLE then
		data = ZhuangZhuangLeData.Instance:GetGridLotteryTreeRewardData()[index]
	elseif self.treasure_type == TREASURE_TYPE.ZHUANZHUANLE_REWARD then
		local seq = ZhuangZhuangLeData.Instance:GetLinRewardSeq()
		data = ZhuangZhuangLeData.Instance:GetRewardBySeq(seq)[index]
	elseif self.treasure_type == TREASURE_TYPE.GUAJITA_REWARD then
		data = GuaJiTaData.Instance:GetAutoRewardData()[index]
	elseif self.treasure_type == TREASURE_TYPE.FANFANZHUAN then
		data = FanFanZhuanData.Instance:GetTreasureItemList()[index]
	elseif self.treasure_type == TREASURE_TYPE.LUCK_CHESS then
		data = LuckyChessData.Instance:GetTreasureViewShowList()[index]
	elseif self.treasure_type == TREASURE_TYPE.GIFT then
		--data = self.gift_data_list[index]
		local data_list = ItemData.Instance:GetNormalRewardList()
		if data_list  then
			data = data_list[index]
		end
	elseif self.treasure_type == TREASURE_TYPE.LUCKY_TURNTABLE then
		data = LuckyTurntableData.Instance:GetReward()[index]
	elseif self.treasure_type == TREASURE_TYPE.HAPPY_LOTTERY then
		data = HappyBargainData.Instance:GetDrawResultList()[index]
	elseif self.treasure_type == TREASURE_TYPE.ADVENTURE_SHOP then
		data = AdventureShopData.Instance:GetDrawReward()[index]
	elseif self.treasure_type ==  TREASURE_TYPE.MID_AUTUMN_LOTTERY then
		data = MidAutumnLotteryData.Instance:GetDrawResultList()[index]
	elseif self.treasure_type == TREASURE_TYPE.LITTLE_PET then
		data = LittlePetData.Instance:GetChouJiangRewardDataList()[index]
	elseif self.treasure_type == TREASURE_TYPE.LUCKY_TURN_EGG then
		data = LuckyTurnEggData.Instance:GetGridLotteryTreeRewardData()[index]
	elseif self.treasure_type == TREASURE_TYPE.LUCKY_TURN_EGG_REWARD then
		local seq = LuckyTurnEggData.Instance:GetLinRewardSeq()
		data = LuckyTurnEggData.Instance:GetRewardBySeq(seq)[index]
	elseif self.treasure_type == TREASURE_TYPE.LUCKY_BOX then
		data = LuckyBoxData.Instance:GetGridLotteryTreeRewardData()[index]
	elseif self.treasure_type == TREASURE_TYPE.LUCKY_BOX_REWARD then
		local seq = LuckyBoxData.Instance:GetLinRewardSeq()
		data = LuckyBoxData.Instance:GetRewardBySeq(seq)[index]

	elseif self.treasure_type == TREASURE_TYPE.DASHE_TIAN_XIA then
		data = DaSheTianXiaData.Instance:GetGridLotteryTreeRewardData()[index]
	elseif self.treasure_type == TREASURE_TYPE.DASHE_TIAN_XIA_REWARD then
		local seq = DaSheTianXiaData.Instance:GetLinRewardSeq()
		data = DaSheTianXiaData.Instance:GetRewardBySeq(seq)[index]
	elseif self.treasure_type == TREASURE_TYPE.SYMBOL then
		data = SymbolData.Instance:GetElementProductListInfo()[index] or {}
	elseif self.treasure_type == TREASURE_TYPE.SYMBOL_NIUDAN then
		data = SymbolData.Instance:GetElementHeartRewardList()[index] or {}
	end
	return data
end

function TipShowTreasureView:GetShowCount()
	local count = 0
	if self.treasure_type == TREASURE_TYPE.JING_LING then
		count = #SpiritData.Instance:GetHuntSpiritItemList()
	elseif self.treasure_type == TREASURE_TYPE.XUNBAO then
		count = #TreasureData.Instance:GetSplitChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.MOKA then
		count = #MagicCardData.Instance:GetLottoData()
	elseif self.treasure_type == TREASURE_TYPE.PET then
		count = #PetData.Instance:GetRewardList()
	elseif self.treasure_type == TREASURE_TYPE.SWORD then
		count = #SwordArtOnlineData.Instance:GetBuyLottoData()
	elseif self.treasure_type == TREASURE_TYPE.RUNE then
		count = #RuneData.Instance:GetTreasureList()
	elseif self.treasure_type == TREASURE_TYPE.RUNE_BAOXIANG then
		count = #RuneData.Instance:GetBaoXiangList()
	elseif self.treasure_type == TREASURE_TYPE.SHEN_GE_BLESS then
		count = #ShenGeData.Instance:GetShenGeBlessRewardDataList()
	elseif self.treasure_type == TREASURE_TYPE.ERNIE_BLESS then
		count = #ShengXiaoData.Instance:GetErnieBlessRewardDataList()
	elseif self.treasure_type == TREASURE_TYPE.NORMAL then
		count = #ItemData.Instance:GetNormalRewardList()
	elseif self.treasure_type == TREASURE_TYPE.BEAUTY then
		count = #BeautyData.Instance:GetPrayItemList()
	elseif self.treasure_type == TREASURE_TYPE.GENERAL then
		count = #FamousGeneralData.Instance:GetItemList()
	elseif self.treasure_type == TREASURE_TYPE.JINYINTA then
		count = #JinYinTaData.Instance:GetLevelLotteryRewardList()
	elseif self.treasure_type == TREASURE_TYPE.JINYINTA_REWARD then
		count = #JinYinTaData.Instance:GetLeiJiRewardList()
	elseif self.treasure_type == TREASURE_TYPE.GUAJITA_REWARD then
		count = #GuaJiTaData.Instance:GetAutoRewardData()
	elseif self.treasure_type == TREASURE_TYPE.FANFANZHUAN then
		count = #FanFanZhuanData.Instance:GetTreasureItemList()
	elseif self.treasure_type == TREASURE_TYPE.LUCK_CHESS then
		count = #LuckyChessData.Instance:GetTreasureViewShowList()
	elseif self.treasure_type == TREASURE_TYPE.ZHUANZHUANLE then
		count = #ZhuangZhuangLeData.Instance:GetGridLotteryTreeRewardData()
	elseif self.treasure_type == TREASURE_TYPE.ZHUANZHUANLE_REWARD then
		local seq = ZhuangZhuangLeData.Instance:GetLinRewardSeq()
		count = #ZhuangZhuangLeData.Instance:GetRewardBySeq(seq)	
	elseif self.treasure_type == TREASURE_TYPE.GIFT then
		--count = #self.gift_data_list
		count = #ItemData.Instance:GetNormalRewardList()
	elseif self.treasure_type == TREASURE_TYPE.LUCKY_TURNTABLE then
		count = #LuckyTurntableData.Instance:GetReward()
	elseif self.treasure_type == TREASURE_TYPE.HAPPY_LOTTERY then
		count = #HappyBargainData.Instance:GetDrawResultList()
	elseif self.treasure_type == TREASURE_TYPE.ADVENTURE_SHOP then
		count = #AdventureShopData.Instance:GetDrawReward()
	elseif self.treasure_type ==  TREASURE_TYPE.MID_AUTUMN_LOTTERY then
		count = #MidAutumnLotteryData.Instance:GetDrawResultList()
	elseif self.treasure_type == TREASURE_TYPE.LITTLE_PET then
		count = #LittlePetData.Instance:GetChouJiangRewardDataList()
	elseif self.treasure_type == TREASURE_TYPE.LUCKY_TURN_EGG then
		count = #LuckyTurnEggData.Instance:GetGridLotteryTreeRewardData()
	elseif self.treasure_type == TREASURE_TYPE.LUCKY_TURN_EGG_REWARD then
		local seq = LuckyTurnEggData.Instance:GetLinRewardSeq()
		count = #LuckyTurnEggData.Instance:GetRewardBySeq(seq)
	elseif self.treasure_type == TREASURE_TYPE.LUCKY_BOX then
		count = #LuckyBoxData.Instance:GetGridLotteryTreeRewardData()
	elseif self.treasure_type == TREASURE_TYPE.LUCKY_BOX_REWARD then
		local seq = LuckyBoxData.Instance:GetLinRewardSeq()
		count = #LuckyBoxData.Instance:GetRewardBySeq(seq)		
	elseif self.treasure_type == TREASURE_TYPE.DASHE_TIAN_XIA then
		count = #DaSheTianXiaData.Instance:GetGridLotteryTreeRewardData()
	elseif self.treasure_type == TREASURE_TYPE.DASHE_TIAN_XIA_REWARD then
		local seq = DaSheTianXiaData.Instance:GetLinRewardSeq()
		count = #DaSheTianXiaData.Instance:GetRewardBySeq(seq)
	elseif self.treasure_type == TREASURE_TYPE.SYMBOL then
		count = #SymbolData.Instance:GetElementProductListInfo()
	elseif self.treasure_type == TREASURE_TYPE.SYMBOL_NIUDAN then
		count = #SymbolData.Instance:GetElementHeartRewardList()
	end
	return count
end

function TipShowTreasureView:SetToggleActiveFalse(first,the_end)
	local page = first - 1
	page = page < 1 and 1 or page
	self.page = page
	self.list_view.list_page_scroll:SetPageCount(page)
	for i=first,the_end do
		self.show_toggle_list[i]:SetValue(false)
	end
end

function TipShowTreasureView:GetPageCount()
	return self.page or 0
end

--礼包
function TipShowTreasureView:GetGiftItemList(gift_id)
	self.gift_data_list = ItemData.Instance:GetGiftItemList(gift_id)
end


function TipShowTreasureView:CloseCallBack()
	SpiritData.Instance:ClearData()
	TreasureData.Instance:ClearData()
	self.current_grid_index = nil
	self.text_animator:SetBool("is_open", false)
	if self.play_count_down then
		CountDown.Instance:RemoveCountDown(self.play_count_down)
		self.play_count_down = nil
	end
	for _, v in pairs(self.contain_cell_list) do
		v:SetPage(0)
	end
	-- self:Release()

	self.is_show_pingbi = false

	if self.hook_call ~= nil then
		self.hook_call()
		self.hook_call = nil
	end
end

function TipShowTreasureView:SetChestMode(chest_shop_mode, is_show_pingbi, callback)
	self.chest_shop_mode = chest_shop_mode
	self.is_show_pingbi = is_show_pingbi
	self.hook_call = callback
end

function TipShowTreasureView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipShowTreasureView:GetNumberOfCells()
	local count = self:GetShowCount()
	local show_count = 0
	if count <= 10 then
		show_count = 1
	elseif count > 10 and count <= 20 then
		show_count = 2
	elseif count > 20 and count <= 30 then
		show_count = 3
	elseif count > 30 and count <= 40 then
		show_count = 4
	elseif count > 40 and count <= 50 then
		show_count = 5
	end
	return show_count
end

function TipShowTreasureView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShowTreasureContain.New(cell.gameObject)
		contain_cell.parent_view = self
		self.contain_cell_list[cell] = contain_cell
	end

	--改变排列方式
	contain_cell:ChangeLayoutGroup()

	local page = cell_index + 1
	contain_cell:SetPage(page)
	for i = 1, ROW do
		local index = page * 10 - (ROW - i)
		local data = nil
		data = self:GetData(index) or {}

		contain_cell:SetToggleGroup(i, self.list_view.toggle_group)
		contain_cell:SetData(i, data)
		contain_cell:ShowHighLight(i, next(data) ~= nil)
		contain_cell:ListenClick(i, BindTool.Bind(self.OnClickItem, self, contain_cell, i, index, data))
	end
end

function TipShowTreasureView:GetCurrentGridIndex()
	return self.current_grid_index
end

function TipShowTreasureView:SetCurrentGridIndex(current_grid_index)
	self.current_grid_index = current_grid_index
end

function TipShowTreasureView:OnCloseTipsClick()
	self:Close()
end

function TipShowTreasureView:OnBackWareHouseClick()
	-- if self.chest_shop_mode >= CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1 then
	-- 	return
	-- end
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_BEAUTY_PRAY10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_BEAUTY_PRAY1 then
		self:Close()
		BeautyCtrl.Instance:PrayShowDepot()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_1 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_10 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_50 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50 then
		self:Close()
		ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1 or
			self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10 or
			self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_1 or
			self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_10 then
		self:Close()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_1 
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_10
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_50 
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_HAPPY_LOTTERY_1
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_HAPPY_LOTTERY_10
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_1
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_10 then

		ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
		self:Close()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_1 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_10 then
		ViewManager.Instance:Open(ViewName.LittlePetWarehouseView)	--跳到小宠物仓库
		self:Close()
	else
		self:Close()
	end
end

function TipShowTreasureView:OneClick()
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE 
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10 then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_GET_REWARD then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_GET_REWARD then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_GET_REWARD then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GUAJITA_REWARD then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_GIFT then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAN_ADVENTURE_SHOP then
		self:Close()
	end
	
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL then
		self:Close()
	end
end

function TipShowTreasureView:OnAgainClick()
	if self:IsPlayAni() then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_1 then
		TreasureCtrl.Instance.view.treasure_content_view:OpenOneClick()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 then
		TreasureCtrl.Instance.view.treasure_content_view:OpenTenClick()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE_50)
		TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE_50, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1 then
		SpiritCtrl.Instance:SendHuntSpiritReq(CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10 then
		SpiritCtrl.Instance:SendHuntSpiritReq(CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_50 then
		SpiritCtrl.Instance:SendHuntSpiritReq(CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_50, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1 then
		if MagicCardData.Instance:GetBagCardNum() <= 120 then
			MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,0,1)
			MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.BagFull)
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_5 then
		if MagicCardData.Instance:GetBagCardNum() <= 115 then
			MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,0,5)
			MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_5)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.BagFull)
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_10 then
		if MagicCardData.Instance:GetBagCardNum() <= 110 then
			MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,0,10)
			MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_10)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.BagFull)
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_1 then
		if MagicCardData.Instance:GetBagCardNum() <= 120 then
			MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,1,1)
			MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_1)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.BagFull)
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_5 then
		if MagicCardData.Instance:GetBagCardNum() <= 115 then
			MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,1,5)
			MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_5)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.BagFull)
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_10 then
		if MagicCardData.Instance:GetBagCardNum() <= 110 then
			MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,1,10)
			MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_O_10)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.BagFull)
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_1 then
		if MagicCardData.Instance:GetBagCardNum() <= 120 then
			MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,2,1)
			MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_1)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.BagFull)
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_5 then
		if MagicCardData.Instance:GetBagCardNum() <= 115 then
			MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,2,5)
			MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_5)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.BagFull)
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_10 then
		if MagicCardData.Instance:GetBagCardNum() <= 110 then
			MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_CHOU_CARD,2,10)
			MagicCardLottoView.Instance:SetLottoData(CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_R_10)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.BagFull)
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_PET_10 then
		PetAchieveView.Instance:OnTenClick()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SWORD_BIND_MODE_1 then
		SwordArtOnlineView.Instance:SetLottoType(CHEST_SHOP_MODE.CHEST_SWORD_BIND_MODE_1)
		MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_CHOU_CARD,SwordArtOnlineView.Instance:GetCurSelectIndex(),3)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_1 then
		SwordArtOnlineView.Instance:SetLottoType(CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_1)
		MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_CHOU_CARD,SwordArtOnlineView.Instance:GetCurSelectIndex(),1)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_10 then
		SwordArtOnlineView.Instance:SetLottoType(CHEST_SHOP_MODE.CHEST_SWORD_GOLD_MODE_10)
		MoLongCtrl.Instance:SendSwordArtOnlineOperaReq(CARDZU_REQ_TYPE.CARDZU_REQ_TYPE_CHOU_CARD,SwordArtOnlineView.Instance:GetCurSelectIndex(),2)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_1 then
		local other_cfg = RuneData.Instance:GetOtherCfg()
		local item_id = other_cfg.xunbao_consume_itemid
		local one_consume_num = other_cfg.xunbao_one_consume_num
		local num = ItemData.Instance:GetItemNumInBagById(item_id)
		if num >= one_consume_num then
			--物品充足
			RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_ONE)
		else
			--物品不足
			local shop_data = ShopData.Instance:GetShopItemCfg(item_id)
			if not shop_data then
				return
			end
			local function ok_callback()
				RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_ONE, 1)
			end
			local differ_num = one_consume_num - num
			local item_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
			local color = item_cfg.color or 1
			local color_str = ITEM_COLOR[color]
			local name = item_cfg.name or ""
			local cost = shop_data.gold * differ_num
			local des = string.format(Language.Rune.NotEnoughDes, color_str, name, cost)
			TipsCtrl.Instance:ShowCommonAutoView("rune_one_xunbao", des, ok_callback)
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_10 then
		local other_cfg = RuneData.Instance:GetOtherCfg()
		local item_id = other_cfg.xunbao_consume_itemid
		local ten_consume_num = other_cfg.xunbao_ten_consume_num
		local num = ItemData.Instance:GetItemNumInBagById(item_id)
		if num >= ten_consume_num then
			--物品充足
			RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_TEN)
		else
			--物品不足
			local shop_data = ShopData.Instance:GetShopItemCfg(item_id)
			if not shop_data then
				return
			end
			local function ok_callback()
				RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_TEN, 1)
			end
			local differ_num = ten_consume_num - num
			local item_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
			local color = item_cfg.color or 1
			local color_str = ITEM_COLOR[color]
			local name = item_cfg.name or ""
			local cost = shop_data.gold * differ_num
			local des = string.format(Language.Rune.NotEnoughDes, color_str, name, cost)
			TipsCtrl.Instance:ShowCommonAutoView("rune_ten_xunbao", des, ok_callback)
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_BAOXIANG_MODE then
		local item_id = RuneData.Instance:GetBaoXiangId()
		local have_num = ItemData.Instance:GetItemNumInBagById(item_id)
		if have_num > 0 then
			RuneData.Instance:SetBaoXiangId(item_id)
			local index = ItemData.Instance:GetItemIndex(item_id)
			PackageCtrl.Instance:SendUseItem(index, 1)
		else
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			if item_cfg then
				local des = string.format(Language.Rune.NumNotEnough, ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
				SysMsgCtrl.Instance:ErrorRemind(des)
			end
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1 then
		local cfg = ShenGeData.Instance:GetOtherCfg().once_chou_item
		local item_id = 0
		if cfg == nil then
			return
		else
			item_id = cfg.item_id
		end
		local bless_opera = ShenGeData.Instance:GetCurBlessAutoList()
		local is_auto = (bless_opera.is_auto_buy and bless_opera.is_quick_buy) and 1 or 0
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				TipsCtrl.Instance:HodeAutoBuyValue("auto_shenge_bless", is_buy_quick)
				ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 1, is_auto)
				self:Close()
			end
		end
		if not ShenGeData.Instance:GetBlessAniState() then
			ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 1, is_auto)
			return
		end
		if not bless_opera.is_auto_buy and not bless_opera.is_quick_buy and 1 - ItemData.Instance:GetItemNumInBagById(item_id) > 0 then
			TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1 - ItemData.Instance:GetItemNumInBagById(item_id))
		else
			ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 1, is_auto)
			self:Close()
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10 then
		local cfg = ShenGeData.Instance:GetOtherCfg().once_chou_item
		local item_id = 0
		if cfg == nil then
			return
		else
			item_id = cfg.item_id
		end

		local bless_opera = ShenGeData.Instance:GetCurBlessAutoList()
		local is_auto = (bless_opera.is_auto_buy and bless_opera.is_quick_buy) and 1 or 0
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				TipsCtrl.Instance:HodeAutoBuyValue("auto_shenge_bless", is_buy_quick)
				ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 10, is_auto)
				self:Close()
			end
		end
		if not ShenGeData.Instance:GetBlessAniState() then
			ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 10, is_auto)
			return
		end

		if not bless_opera.is_auto_buy and not bless_opera.is_quick_buy and 9 - ItemData.Instance:GetItemNumInBagById(item_id) > 0 then
			TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 9 - ItemData.Instance:GetItemNumInBagById(item_id))
		else
			ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 10, is_auto)
			self:Close()
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_1 then
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_GUNGUN_LE_REQ, 0)
		if not ShengXiaoData.Instance:GetErnieIsStopPlayAni() then
			self:Close()
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_10 then
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_GUNGUN_LE_REQ, 1)
		if not ShengXiaoData.Instance:GetErnieIsStopPlayAni() then
			self:Close()
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_BEAUTY_PRAY1 then
		local other_cfg = BeautyData.Instance:GetBeautyOther()
		BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_DRAW, 2, self:CheckIsAutoBuy(other_cfg.draw_1_item_id))
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_BEAUTY_PRAY10 then
		local other_cfg = BeautyData.Instance:GetBeautyOther()
		BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_DRAW, 3, self:CheckIsAutoBuy(other_cfg.draw_10_item_id))
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_1 then
		local other_cfg = FamousGeneralData.Instance:GetOtherCfg()
		FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_DRAW, GREATE_SOLDIER_DRAW_TYPE.GREATE_SOLDIER_DRAW_TYPE_1_DRAW, self:CheckIsAutoBuy(other_cfg.draw_1_item_id))
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_10 then
		local other_cfg = FamousGeneralData.Instance:GetOtherCfg()
		FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_DRAW, GREATE_SOLDIER_DRAW_TYPE.GREATE_SOLDIER_DRAW_TYPE_10_DRAW, self:CheckIsAutoBuy(other_cfg.draw_10_item_id))
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GENERAL_MODE_50 then
		local other_cfg = FamousGeneralData.Instance:GetOtherCfg()
		FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_DRAW, GREATE_SOLDIER_DRAW_TYPE.GREATE_SOLDIER_DRAW_TYPE_50_DRAW, self:CheckIsAutoBuy(other_cfg.draw_50_item_id))
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_1 then		
		-- 抽一次之前的层级
 		local old_level = JinYinTaData.Instance:GetLotteryCurLevel()
 		JinYinTaData.Instance:SetOldLevel(old_level)
 		-- 玩家钻石数量
		local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
		local currLevel = JinYinTaData.Instance:GetLotteryCurLevel()
		-- 刷新抽奖励需要的钻石数
		local need_gold = JinYinTaData.Instance:GetChouNeedGold(currLevel)
		if role_gold >= need_gold then
			local bags_grid_num = ItemData.Instance:GetEmptyNum()
	 		if bags_grid_num > 0 then
	 			JinYinTaData.Instance:SetPlayNotClick(false)
	 		end
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_DO_LOTTERY,CHARGE_OPERA.CHOU_ONE)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_10 then
		local currLevel = JinYinTaData.Instance:GetLotteryCurLevel()
		-- 刷新抽奖励需要的钻石数
		local need_gold = JinYinTaData.Instance:GetChouNeedGold(currLevel)
		local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
		-- 有足够的钻石
		if role_gold >= need_gold then
			local bags_grid_num = ItemData.Instance:GetEmptyNum()
			if bags_grid_num > 0 then
				JinYinTaData.Instance:SetTenNotClick(false)
			end
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_DO_LOTTERY,CHARGE_OPERA.CHOU_TEN)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_1 then		
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU,1)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_10 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU,10)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_MODE_1 then	
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_4, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU,1)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_MODE_10 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_4, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU,10)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_DASHE_TIAN_XIA_MODE_1 then		
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_5, RA_CHONGZHI_MONEY_TREE_FIVE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU, 1)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_DASHE_TIAN_XIA_MODE_10 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_5, RA_CHONGZHI_MONEY_TREE_FIVE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU, 10)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_10 then
		local cur_level = FanFanZhuanData.Instance:GetCurLevel()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_PLEASE_DRAW_CARD, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_PLAY_TIMES, cur_level, 10)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_50 then
		local cur_level = FanFanZhuanData.Instance:GetCurLevel()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_PLEASE_DRAW_CARD, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_PLAY_TIMES, cur_level, 50)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCK_CHESS_10 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP, RA_PROMOTING_POSITION_OPERA_TYPE.RA_PROMOTING_POSITION_OPERA_TYPE_PLAY, 10)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAN_LUCKY_TURNTABLE then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_TURNTABLE, RA_ONE_YUAN_DRAW_OPERA_TYPE.RA_ONE_YUAN_DRAW_OPERA_TYPE_DRAW_REWARD)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_HAPPY_LOTTERY_1 then
		local cur_day = HappyBargainData.Instance:GetCurServerOpenServerDay()
		local other_cfg = HappyBargainData.Instance:GetConsumeInfo(cur_day, 1)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_LOTTERY, RA_ONE_YUAN_DRAW_OPERA_TYPE.RA_ONE_YUAN_DRAW_OPERA_TYPE_DRAW_REWARD,0,self:CheckIsAutoBuy(other_cfg.item_id))
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_HAPPY_LOTTERY_10 then
		local cur_day = HappyBargainData.Instance:GetCurServerOpenServerDay()
		local other_cfg = HappyBargainData.Instance:GetConsumeInfo(cur_day, 10)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_LOTTERY, 
			RA_ONE_YUAN_DRAW_OPERA_TYPE.RA_ONE_YUAN_DRAW_OPERA_TYPE_DRAW_REWARD,1,self:CheckIsAutoBuy(other_cfg.item_id))
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_1 then  
		local item_id = MidAutumnLotteryData.Instance:GetComsumeInfoList().item_id
    	local num = ItemData.Instance:GetItemNumInBagById(item_id) 
    	local one_draw_consume_num = MidAutumnLotteryData.Instance:GetComsumeInfoList().num or 1
		if num >= one_draw_consume_num then 
			MidAutumnLotteryData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_1)
			-- 活动类型：2199 -- 操作类型：1 （抽奖）-- 是否十抽：0/1 -- 是否使用元宝：0/1
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY,1,0,0)
		else
			local function ok_callback()
				MidAutumnLotteryData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_1)
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY,1,0,1)
			end
		
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			if item_cfg == nil or not next(item_cfg) then
				return
			end
			local color = item_cfg.color
			local color_str = ITEM_COLOR[color]
			local name = item_cfg.name or "" 
			local need_gold = MidAutumnLotteryData.Instance:GetNeedGoldByDrawTimes()
			local des = string.format(Language.MidAutumn.NotEnoughOnce,color_str,name,need_gold) 
			TipsCtrl.Instance:ShowCommonAutoView("midautumn_lottery", des, ok_callback)
		end
    elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_10 then
    	local item_id = MidAutumnLotteryData.Instance:GetComsumeInfoList(10).item_id
    	local num = ItemData.Instance:GetItemNumInBagById(item_id) 
    	local ten_draw_consume_num = MidAutumnLotteryData.Instance:GetComsumeInfoList(10).num or 10
    	if num >= ten_draw_consume_num then 
			MidAutumnLotteryData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_10)
			-- 活动类型：2199 -- 操作类型：1 （抽奖）-- 是否十抽：0/1 -- 是否使用元宝：0/1
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY,1,1,0) 
			-- local is_no_ani = TipsCtrl.Instance:GetTreasurePlayAniFlag(TREASURE_TYPE.MID_AUTUMN_LOTTERY)
			-- if not is_no_ani then
			-- 	MidAutumnLotteryCtrl.Instance:SetIsTenClick()
			-- end 
		else 
			local function ok_callback()
				MidAutumnLotteryData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_RAND_MID_AUTUMN_LOTTERY_10)
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY,1,1,1) 
				-- local is_no_ani = TipsCtrl.Instance:GetTreasurePlayAniFlag(TREASURE_TYPE.MID_AUTUMN_LOTTERY)
				-- if not is_no_ani then
				-- 	MidAutumnLotteryCtrl.Instance:SetIsTenClick()
				-- end 
			end 
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			if item_cfg == nil or not next(item_cfg) then
				return
			end
			local color = item_cfg.color
			local color_str = ITEM_COLOR[color]
			local name = item_cfg.name or "" 
			local need_gold = MidAutumnLotteryData.Instance:GetNeedGoldByDrawTimes(10)
			local des = string.format(Language.MidAutumn.NotEnoughTenTimes,color_str,name,need_gold)  
			TipsCtrl.Instance:ShowCommonAutoView("midautumn_lottery", des, ok_callback)
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_1 then
		local chou_jiang_call_back = function()
			local opera_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_CHOUJIANG
			local param1 = LITTLE_PET_CHOUJIANG_TYPE.ONE
			LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, param1)
		end
		local other_cfg = LittlePetData.Instance:GetOtherCfg()
		local need_gold = other_cfg[1] and other_cfg[1].one_chou_consume_gold or 0
		local tip_text = string.format(Language.LittlePet.TiShiOnce, need_gold)
		TipsCtrl.Instance:ShowCommonAutoView("pet_shop_chou_jiang", tip_text, chou_jiang_call_back)		
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_10 then
		local chou_jiang_call_back = function()
			local opera_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_CHOUJIANG
			local param1 = LITTLE_PET_CHOUJIANG_TYPE.TEN
			LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, param1)
		end
		local other_cfg = LittlePetData.Instance:GetOtherCfg()
		local need_gold = other_cfg[1] and other_cfg[1].ten_chou_consume_gold or 0
		local tip_text = string.format(Language.LittlePet.TiShiTence, need_gold)
		TipsCtrl.Instance:ShowCommonAutoView("pet_shop_chou_jiang", tip_text, chou_jiang_call_back)	
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_lUCKY_BOX_1 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_3, RA_CHONGZHI_MONEY_TREE_FIVE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU, 1)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_lUCKY_BOX_10 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_3, RA_CHONGZHI_MONEY_TREE_FIVE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU, 10)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL_NIUDAN then
		if ItemData.Instance:GetEmptyNum() >= 10 then
			SymbolCtrl.Instance:SendChoujiangElementHeartReqAgain(10)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Symbol.BagText)
		end
	end
end

function TipShowTreasureView:CheckIsAutoBuy(item_id)
	return TipsCommonBuyView.AUTO_LIST[item_id] and 1 or 0
end

function TipShowTreasureView:SetToggleActive(is_on)
	for k,v in pairs(self.contain_cell_list) do
		v:SetToggleActive(self.current_grid_index, is_on)
	end
end

function TipShowTreasureView:OnClickItem(group, group_index, index, data)
	self.current_grid_index = index
	group:SetToggle(group_index, index == self.current_grid_index)
	local close_call_back = function()
		group:SetToggle(group_index, false)
	end
	TipsCtrl.Instance:OpenItem(data, nil, nil, close_call_back)
end

function TipShowTreasureView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

----------------------------------------------------------
ShowTreasureContain = ShowTreasureContain  or BaseClass(BaseCell)

function ShowTreasureContain:__init()
	self.parent_view = nil
	self.treasure_contain_list = {}
	for i = 1, 10 do
		self.treasure_contain_list[i] = GiftItemCell.New(self:FindObj("item_" .. i))
	end
end

function ShowTreasureContain:__delete()
	self.parent_view = nil
	for k, v in pairs(self.treasure_contain_list) do
		v:DeleteMe()
	end
	self.treasure_contain_list = {}
end

function ShowTreasureContain:SetPage(page)
	self.page = page
end

function ShowTreasureContain:GetPage()
	return self.page
end

function ShowTreasureContain:SetToggleGroup(i, toggle_group)
	self.treasure_contain_list[i]:SetToggleGroup(toggle_group)
end

function ShowTreasureContain:SetData(i, data)
	self.treasure_contain_list[i]:SetData(data)
end

function ShowTreasureContain:ListenClick(i, handler)
	self.treasure_contain_list[i]:ListenClick(handler)
end

function ShowTreasureContain:ShowHighLight(i, enable)
	self.treasure_contain_list[i]:ShowHighLight(enable)
end

function ShowTreasureContain:SetToggle(i, enable)
	self.treasure_contain_list[i]:SetToggle(enable)
end

function ShowTreasureContain:SetAlpha(i, value)
	self.treasure_contain_list[i]:SetAlpha(value)
end

function ShowTreasureContain:GetTransForm(i)
	return self.treasure_contain_list[i]:GetTransForm()
end

--改变排列方式
function ShowTreasureContain:ChangeLayoutGroup()
	if self.parent_view then
		local page_count = self.parent_view:GetPageCount()
		local enum = 0
		if page_count > 1 then
			enum = UnityEngine.TextAnchor.UpperLeft
		else
			enum = UnityEngine.TextAnchor.MiddleCenter
		end
		self.root_node.grid_layout_group.childAlignment = enum
	end
end

----------------------------------------------------------
GiftItemCell = GiftItemCell  or BaseClass(BaseRender)

function GiftItemCell:__init()
	self.sword = self:FindVariable("sword")
	self.sword_bg = self:FindVariable("sword_bg")
	self.is_sword = self:FindVariable("is_sword")
	self.treasure_item = ItemCell.New()
	self.treasure_item:SetInstanceParent(self:FindObj("item"))
end

function GiftItemCell:__delete()
	if self.treasure_item then
		self.treasure_item:DeleteMe()
	end
end

function GiftItemCell:SetToggleGroup(toggle_group)
	self.treasure_item:SetToggleGroup(toggle_group)
end

function GiftItemCell:SetData(data)
	if data and data.num and data.num > 0 then
		self:SetActive(true)
	else
		self:SetActive(false)
	end

	if TipShowTreasureView.Instance:GetTreasureType() == TREASURE_TYPE.SWORD then
		if not next(data) then
			return
		end

		self.is_sword:SetValue(true)
		local star_str = "star_bg_"..data.star_count
		self.sword_bg:SetAsset("uis/views/swordartonline",star_str)

		  local sword_str = "sword_"..data.res_id
		self.sword:SetAsset("uis/views/swordartonline",sword_str)
	else
		self.is_sword:SetValue(false)
		self.treasure_item:SetData(data)
		self.treasure_item:SetShenGeInfo(data, false)
	end
end

function GiftItemCell:ListenClick(handler)
	self.treasure_item:ListenClick(handler)
end

function GiftItemCell:ShowHighLight(enable)
	self.treasure_item:ShowHighLight(enable)
end

function GiftItemCell:SetToggle(enable)
	self.treasure_item:SetToggle(enable)
end

function GiftItemCell:SetAlpha(value)
	if self.root_node.canvas_group then
		self.root_node.canvas_group.alpha = value
	end
end

function GiftItemCell:IsNil()
	return not self.root_node or not self.root_node.gameObject.activeInHierarchy
end

function GiftItemCell:GetTransForm()
	return self.root_node.transform
end