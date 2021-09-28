TipShowTreasureView = TipShowTreasureView or BaseClass(BaseView)

local ROW = 10
local COLUMN = 5
local MAX_NUM = 50

local TREASURE_TYPE =
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
	JINYINTA = 11,			-- 金银塔抽奖
	JINYINTA_REWARD = 12,	-- 金银塔累计抽奖
	SPIRIT_HOME_QUICK = 13, -- 精灵家园加速
	GUAJITA_REWARD = 14,	-- 副本塔扫荡
    ZHUANZHUANLE = 15,       --转转乐抽奖
	ZHUANZHUANLE_REWARD = 16,	-- 转转乐累计抽奖
	PUSH_FB_STAR_REWARD = 17,	-- 推图星星奖励
	HUNQI_BAOZANG = 18,			--魂器宝藏
	FANFANZHUAN = 19,			-- 翻翻转奖励
	LUCK_CHESS = 20,            -- 幸运棋奖励
	HAPPY_RECHARGE = 21,		-- 充值大乐透
	WaBao = 22,
	LUCKLY_TURNTABLE = 23,		-- 转盘
	GuaGuaLe = 24,              --刮刮乐
	MIJINGXUNBAO3 = 25,			--秘境寻宝
	HAPPYERNIE = 26,			--欢乐摇奖
	Happy_Hit_Egg = 27,         -- 欢乐砸蛋
	LITTLE_PET = 28,			-- 小宠物
	ZHONGQIUHAPPYERNIE = 29,    --中秋欢乐摇奖
	LOCKY_DRAW = 30,   			--占卜十次
	SYMBOL = 31, 				-- 五行之灵
	SYMBOL_NIUDAN = 32, 		-- 五行之灵扭蛋
}

function TipShowTreasureView:__init()
	self.ui_config = {"uis/views/tips/showtreasuretips_prefab", "ShowTreasureTips"}
	TipShowTreasureView.Instance = self
	self.current_grid_index = -1
	self.chest_shop_mode = nil
	self.play_audio = true
	self.contain_cell_list = {}
	self.view_layer = UiLayer.Pop
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

	-- 清理变量和对象
	self.list_view = nil
	self.page_toggle_1 = nil
	--self.effect_1 = nil
	self.text_animator = nil
	self.btn_text_1 = nil
	self.btn_text_2 = nil
	self.is_play_ani = nil
	self.show_toggle_list = nil
	self.list_view = nil
	self.back_warehouse_btn = nil
	self.show_one_btn = nil
	self.is_wabao =nil
end

function TipShowTreasureView:LoadCallBack()
	self.contain_cell_list = {}
	self.list_view = self:FindObj("list_view")
	self:ListenEvent("close_tips_click",BindTool.Bind(self.OnCloseTipsClick, self))
	self:ListenEvent("back_warehouse_click",BindTool.Bind(self.OnBackWareHouseClick, self))
	self:ListenEvent("again_click",BindTool.Bind(self.OnAgainClick, self))
	self:ListenEvent("OneClick",BindTool.Bind(self.OneClick, self))


	self.page_toggle_1 = self:FindObj("page_toggle_1")
	--self.effect_1 = self:FindObj("EffectRoot")
	self.text_animator = self:FindObj("text_frame").animator

	self.is_wabao = self:FindVariable("IsWaBao")
	self.btn_text_1 = self:FindVariable("btn_text_1")
	self.btn_text_2 = self:FindVariable("btn_text_2")
	self.is_play_ani = self:FindVariable("is_play_ani")
	self.show_one_btn = self:FindVariable("ShowOneBtn")

	self.show_toggle_list = {}
	for i=1,7 do
		self.show_toggle_list[i] = self:FindVariable("show_page_toggle_"..i)
	end
	self:InitListView()

	--引导用按钮
	self.back_warehouse_btn = self:FindObj("BackWareHouseBtn")

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.TreasureReward, BindTool.Bind(self.GetUiCallBack, self))
end

--判断能否播放动画
function TipShowTreasureView:IsPlayAni()
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50  then
		return not TreasureData.Instance:GetIsShield()
	elseif (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10
		or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_50) and SpiritData.Instance:IsNoPlayAni() then
		return false
	elseif (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_MODE_10) and RuneData.Instance:IsStopPlayAni() then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.LUCKLY_TURNTABLE_GET_REWARD then
		return false
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL_NIUDAN then
		return false
	-- elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_30 then
	-- 	return false
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
	end
end

function TipShowTreasureView:OpenCallBack()
	self:ChangeBtnCount()
	self:SetTreasureType()
	self.page_toggle_1.toggle.isOn = true
	self.text_animator:SetBool("is_open", true)
	for i=1,7 do
		self.show_toggle_list[i]:SetValue(true)
	end
	local count = self:GetShowCount()
	if count <= 10 then
		self:SetToggleActiveFalse(1,7)
	elseif count > 10 and count <= 20 then
		self:SetToggleActiveFalse(3,7)
	elseif count > 20 and count <= 30 then
		self:SetToggleActiveFalse(4,7)
	elseif count > 30 and count <= 40 then
		self:SetToggleActiveFalse(5,7)
	elseif count > 40 and count <= 50 then
		self:SetToggleActiveFalse(6,7)
	elseif count > 50 and count <= 60 then
		self:SetToggleActiveFalse(7,7)
	end

	self.list_view.scroller:ReloadData(0)

	self:CheckToPlayAni()
	GlobalTimerQuest:AddDelayTimer(function()
		self:PlayEffect()
	end, 0.5)
end

function TipShowTreasureView:PlayEffect()
	-- EffectManager.Instance:PlayAtTransformCenter(
	-- 	"effects/prefabs",
	-- 	"UI_gongxihuode_1",
	-- 	self.effect_1.transform,
	-- 	1)
end
function TipShowTreasureView:OnFlush()
	self:SetTreasureType()
	self.page_toggle_1.toggle.isOn = true
	-- self.text_animator:SetBool("is_open", true)
	for i=1,7 do
		self.show_toggle_list[i]:SetValue(true)
	end
	local count = self:GetShowCount()
	if count <= 10 then
		self:SetToggleActiveFalse(1,7)
	elseif count > 10 and count <= 20 then
		self:SetToggleActiveFalse(3,7)
	elseif count > 20 and count <= 30 then
		self:SetToggleActiveFalse(4,7)
	elseif count > 30 and count <= 40 then
		self:SetToggleActiveFalse(5,7)
	elseif count > 40 and count <= 50 then
		self:SetToggleActiveFalse(6,7)
	elseif count > 50 and count <= 60 then
		self:SetToggleActiveFalse(7,7)
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
		if self.is_play_ani then
			self.is_play_ani:SetValue(false)
		end
		if self.play_count_down then
			CountDown.Instance:RemoveCountDown(self.play_count_down)
			self.play_count_down = nil
		end
		return
	end
	self.step = self.step + 1

	local item_num = self.step
	GameObjectPool.Instance:SpawnAsset("effects2/prefab/ui/ui_jinengshengji_1_prefab", "UI_Jinengshengji_1", BindTool.Bind(self.LoadEffect, self, item_num, group_cell))

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
			if self.play_count_down then
				CountDown.Instance:RemoveCountDown(self.play_count_down)
				self.play_count_down = nil
			end
			self.step = 0
			self.play_count_down = CountDown.Instance:AddCountDown(10, 0.05, BindTool.Bind(self.PlayTime, self, v, count))
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

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GUAJITA_REWARD then
		show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_GET_REWARD then
		show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_PUSH_FB_STAR_REWARD then
		show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.HAPPY_RECHARGE then
		show_one_btn = true
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.LUCKLY_TURNTABLE_GET_REWARD then
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
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_1 then
		self.treasure_type = TREASURE_TYPE.XUNBAO
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 then
		self.treasure_type = TREASURE_TYPE.XUNBAO
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50 then
		self.treasure_type = TREASURE_TYPE.XUNBAO
		btn_text_2_value = Language.RechargeChouChouLe.AgainThirty
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.LUCKLY_TURNTABLE_GET_REWARD then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		self.treasure_type = TREASURE_TYPE.LUCKLY_TURNTABLE
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1  then
		self.treasure_type = TREASURE_TYPE.JING_LING
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_50 then
		self.treasure_type = TREASURE_TYPE.JING_LING
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
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GUAJITA_REWARD then
		self.treasure_type = TREASURE_TYPE.GUAJITA_REWARD -- zcz
		btn_text_1_value = Language.RechargeChouChouLe.Sure
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
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HUNQI_BAOZANG_1 then
		self.treasure_type = TREASURE_TYPE.HUNQI_BAOZANG
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HUNQI_BAOZANG_10 then
		self.treasure_type = TREASURE_TYPE.HUNQI_BAOZANG
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_1 then
		self.treasure_type = TREASURE_TYPE.JINYINTA
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_10 then
		self.treasure_type = TREASURE_TYPE.JINYINTA
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_GET_REWARD then
		self.treasure_type = TREASURE_TYPE.JINYINTA_REWARD
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_1 then
		self.treasure_type = TREASURE_TYPE.ZHUANZHUANLE
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_10 then
		self.treasure_type = TREASURE_TYPE.ZHUANZHUANLE
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.LOCKY_DRAW_10 then
		self.treasure_type = TREASURE_TYPE.LOCKY_DRAW
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_GET_REWARD then
		self.treasure_type = TREASURE_TYPE.ZHUANZHUANLE_REWARD
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE then
		self.treasure_type = TREASURE_TYPE.NORMAL
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_QUICK_REWARD then
		self.treasure_type = TREASURE_TYPE.SPIRIT_HOME_QUICK
		btn_text_2_value = Language.JingLing.AgainQuick
		btn_text_1_value = Language.Common.Confirm
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_PUSH_FB_STAR_REWARD then
		self.treasure_type = TREASURE_TYPE.PUSH_FB_STAR_REWARD
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
		btn_text_1_value = Language.RechargeChouChouLe.BackWareHouse
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
		self.treasure_type = TREASURE_TYPE.LUCK_CHESS
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.HAPPY_RECHARGE_1 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.HAPPY_RECHARGE
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.HAPPY_RECHARGE_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
		self.treasure_type = TREASURE_TYPE.HAPPY_RECHARGE
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_30 then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.RechargeChouChouLe.MiJingXunBao3Text[self.chest_shop_mode]
		self.treasure_type = TREASURE_TYPE.MIJINGXUNBAO3
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_WABAO_QUICKL then
		btn_text_2_value = Language.RechargeChouChouLe.GetReward
		self.treasure_type = TREASURE_TYPE.WaBao
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_1 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.Happy_Hit_Egg
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_10 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.Happy_Hit_Egg
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_30 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.Happy_Hit_Egg
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		self.treasure_type = TREASURE_TYPE.SYMBOL
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL_NIUDAN then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
		self.treasure_type = TREASURE_TYPE.SYMBOL_NIUDAN
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_30 then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.HappyErnie.TreasureHunt[self.chest_shop_mode]
		self.treasure_type = TREASURE_TYPE.HAPPYERNIE
	elseif (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_1) or (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_10) or (self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_30) then
		btn_text_1_value = Language.RechargeChouChouLe.Back
		btn_text_2_value = Language.HappyErnie.TreasureHunt[self.chest_shop_mode]
		self.treasure_type = TREASURE_TYPE.ZHONGQIUHAPPYERNIE
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_1 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_10 or self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_50 then
		btn_text_1_value = Language.RechargeChouChouLe.Sure
		self.treasure_type = TREASURE_TYPE.GuaGuaLe
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_1 then
		self.treasure_type = TREASURE_TYPE.LITTLE_PET
		btn_text_2_value = Language.RechargeChouChouLe.AgainOne
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_10 then
		self.treasure_type = TREASURE_TYPE.LITTLE_PET
		btn_text_2_value = Language.RechargeChouChouLe.AgainTen
	end
	if self.treasure_type == TREASURE_TYPE.WaBao then
		self.is_wabao:SetValue(true)
	else
		self.is_wabao:SetValue(false)
	end
	self.btn_text_1:SetValue(btn_text_1_value)
	self.btn_text_2:SetValue(btn_text_2_value)
end

function TipShowTreasureView:GetData(index)
	local data = {}
	if self.treasure_type == TREASURE_TYPE.XUNBAO then
		data = TreasureData.Instance:GetChestShopItemInfo()[index]
	elseif self.treasure_type == TREASURE_TYPE.JING_LING then
		data = SpiritData.Instance:GetHuntSpiritItemList()[index]
	elseif self.treasure_type == TREASURE_TYPE.RUNE then
		data = RuneData.Instance:GetTreasureList()[index]
	elseif self.treasure_type == TREASURE_TYPE.RUNE_BAOXIANG then
		data = RuneData.Instance:GetBaoXiangList()[index]
	elseif self.treasure_type == TREASURE_TYPE.MIJINGXUNBAO3 then 					--秘境寻宝
		data = SecretTreasureHuntingData.Instance:GetChestShopItemInfo()[index]
	elseif self.treasure_type == TREASURE_TYPE.GUAJITA_REWARD then
		data = GuaJiTaData.Instance:GetAutoRewardData()[index]
	elseif self.treasure_type == TREASURE_TYPE.SHEN_GE_BLESS then
		data = ShenGeData.Instance:GetShenGeBlessRewardDataList()[index]
	elseif self.treasure_type == TREASURE_TYPE.ERNIE_BLESS then
		data = ShengXiaoData.Instance:GetErnieBlessRewardDataList()[index]
	elseif self.treasure_type == TREASURE_TYPE.HUNQI_BAOZANG then
		data = ItemData.Instance:GetNormalRewardList()[index]
	elseif self.treasure_type == TREASURE_TYPE.NORMAL then
		data = ItemData.Instance:GetNormalRewardList()[index]
	elseif self.treasure_type == TREASURE_TYPE.JINYINTA then
		data = JinYinTaData.Instance:GetLevelLotteryRewardList()[index]
	elseif self.treasure_type == TREASURE_TYPE.JINYINTA_REWARD then
		data = JinYinTaData.Instance:GetLeiJiRewardList()[index - 1]
	elseif self.treasure_type == TREASURE_TYPE.SPIRIT_HOME_QUICK then
		local cfg = SpiritData.Instance:GetQuickGetList()
		if cfg ~= nil and cfg.item_list ~= nil then
			if cfg.item_list[41] ~= nil then
				table.remove(cfg.item_list, 41)
			end
			data = cfg.item_list[index]
		end
	elseif self.treasure_type == TREASURE_TYPE.ZHUANZHUANLE then
		data = ZhuangZhuangLeData.Instance:GetGridLotteryTreeRewardData()[index]
	elseif self.treasure_type == TREASURE_TYPE.LOCKY_DRAW then
		data = LuckyDrawData.Instance:GetRewardData()[index]
	elseif self.treasure_type == TREASURE_TYPE.ZHUANZHUANLE_REWARD then
		local seq = ZhuangZhuangLeData.Instance:GetLinRewardSeq()
		data = ZhuangZhuangLeData.Instance:GetRewardBySeq(seq)[index]

	elseif self.treasure_type == TREASURE_TYPE.PUSH_FB_STAR_REWARD then
		data = SlaughterDevilData.Instance:GetPushFbFetchShowStarReward()[index]
	elseif self.treasure_type == TREASURE_TYPE.FANFANZHUAN then
		data = FanFanZhuanData.Instance:GetTreasureItemList()[index]
	elseif self.treasure_type == TREASURE_TYPE.LUCK_CHESS then
		data = LuckyChessData.Instance:GetTreasureViewShowList()[index]
	elseif self.treasure_type == TREASURE_TYPE.HAPPY_RECHARGE then
		data = HappyRechargeData.Instance:GetRewardListInfo()[index]
	elseif self.treasure_type == TREASURE_TYPE.WaBao then
		data = WaBaoData.Instance:GetRewardItems()[index]
	elseif self.treasure_type == TREASURE_TYPE.LITTLE_PET then
		data = LittlePetData.Instance:GetChouJiangRewardDataList()[index]
	elseif self.treasure_type == TREASURE_TYPE.LUCKLY_TURNTABLE then
		data = HefuActivityData.Instance:GetRollResult()[index]
	elseif self.treasure_type == TREASURE_TYPE.Happy_Hit_Egg then 					--欢乐砸蛋
		data = HappyHitEggData.Instance:GetChestShopItemInfo()[index]
	elseif self.treasure_type == TREASURE_TYPE.HAPPYERNIE then 					--欢乐摇奖
		data = HappyErnieData.Instance:GetChestShopItemInfo()[index]
	elseif self.treasure_type == TREASURE_TYPE.ZHONGQIUHAPPYERNIE then 					--中秋欢乐摇奖
		data = AutumnHappyErnieData.Instance:GetChestShopItemInfo()[index]
	elseif self.treasure_type == TREASURE_TYPE.GuaGuaLe then 					--刮刮乐
		data = ScratchTicketData.Instance:GetChestShopItemInfo()[index]
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
		count = #TreasureData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.RUNE then
		count = #RuneData.Instance:GetTreasureList()
	elseif self.treasure_type == TREASURE_TYPE.RUNE_BAOXIANG then
		count = #RuneData.Instance:GetBaoXiangList()
	elseif self.treasure_type == TREASURE_TYPE.MIJINGXUNBAO3 then 				--秘境寻宝
		count = #SecretTreasureHuntingData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.GUAJITA_REWARD then
		count = #GuaJiTaData.Instance:GetAutoRewardData()
	elseif self.treasure_type == TREASURE_TYPE.SHEN_GE_BLESS then
		count = #ShenGeData.Instance:GetShenGeBlessRewardDataList()
	elseif self.treasure_type == TREASURE_TYPE.ERNIE_BLESS then
		count = #ShengXiaoData.Instance:GetErnieBlessRewardDataList()
	elseif self.treasure_type == TREASURE_TYPE.HUNQI_BAOZANG then
		count = #ItemData.Instance:GetNormalRewardList()
	elseif self.treasure_type == TREASURE_TYPE.NORMAL then
		count = #ItemData.Instance:GetNormalRewardList()
	elseif self.treasure_type == TREASURE_TYPE.JINYINTA then
		count = #JinYinTaData.Instance:GetLevelLotteryRewardList()
	elseif self.treasure_type == TREASURE_TYPE.JINYINTA_REWARD then
		count = #JinYinTaData.Instance:GetLeiJiRewardList()
	elseif self.treasure_type == TREASURE_TYPE.SPIRIT_HOME_QUICK then
		local cfg = SpiritData.Instance:GetQuickGetList()
		if cfg ~= nil and cfg.item_list ~= nil then
			count = #cfg.item_list >= 40 and 40 or #cfg.item_list
		end
	elseif self.treasure_type == TREASURE_TYPE.ZHUANZHUANLE then
		count = #ZhuangZhuangLeData.Instance:GetGridLotteryTreeRewardData()
	elseif self.treasure_type == TREASURE_TYPE.LOCKY_DRAW then
		count = #LuckyDrawData.Instance:GetRewardData()
	elseif self.treasure_type == TREASURE_TYPE.ZHUANZHUANLE_REWARD then
		local seq = ZhuangZhuangLeData.Instance:GetLinRewardSeq()
		count = #ZhuangZhuangLeData.Instance:GetRewardBySeq(seq)
	elseif self.treasure_type == TREASURE_TYPE.PUSH_FB_STAR_REWARD then
		local seq = SlaughterDevilData.Instance:GetPushFbFetchShowStarReward()
		count = #ZhuangZhuangLeData.Instance:GetRewardBySeq(seq)
	elseif self.treasure_type == TREASURE_TYPE.FANFANZHUAN then
		count = #FanFanZhuanData.Instance:GetTreasureItemList()
	elseif self.treasure_type == TREASURE_TYPE.LUCK_CHESS then
		count = #LuckyChessData.Instance:GetTreasureViewShowList()
	elseif self.treasure_type == TREASURE_TYPE.HAPPY_RECHARGE then
		count = #HappyRechargeData.Instance:GetRewardListInfo()
	elseif self.treasure_type == TREASURE_TYPE.WaBao then
		count = #WaBaoData.Instance:GetRewardItems()
	elseif self.treasure_type == TREASURE_TYPE.LITTLE_PET then
		count = #LittlePetData.Instance:GetChouJiangRewardDataList()
	elseif self.treasure_type == TREASURE_TYPE.LUCKLY_TURNTABLE then
		count = #HefuActivityData.Instance:GetRollResult()
	elseif self.treasure_type == TREASURE_TYPE.Happy_Hit_Egg then 				--欢乐砸蛋
		count = #HappyHitEggData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.HAPPYERNIE then 				--欢乐摇奖
		count = #HappyErnieData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.ZHONGQIUHAPPYERNIE then 				--欢乐摇奖
		count = #AutumnHappyErnieData.Instance:GetChestShopItemInfo()
	elseif self.treasure_type == TREASURE_TYPE.GuaGuaLe then 				--刮刮乐
		count = #ScratchTicketData.Instance:GetChestShopItemInfo()
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

function TipShowTreasureView:CloseCallBack()
	SpiritData.Instance:ClearData()
	TreasureData.Instance:ClearData()
	self.current_grid_index = nil
	if self.text_animator then
		self.text_animator:SetBool("is_open", false)
	end
	if self.play_count_down then
		CountDown.Instance:RemoveCountDown(self.play_count_down)
		self.play_count_down = nil
	end
	for _, v in pairs(self.contain_cell_list) do
		v:SetPage(0)
	end

	if self.close_call_back then
		self.close_call_back()
		self.close_call_back = nil
	end
	-- self:Release()
end

function TipShowTreasureView:SetChestMode(chest_shop_mode)
	self.chest_shop_mode = chest_shop_mode
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
	elseif count > 50 and count <= 60 then
		show_count = 6
	elseif count > 60 and count <= 70 then
		show_count = 7
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
	self:Close()
	if self.chest_shop_mode >= CHEST_SHOP_MODE.CHEST_SHOP_MC_MODE_P_1 then
		if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCK_CHESS_10 then
			LuckyChessCtrl.Instance.view:OnClickOpen()
		elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_1 or
			self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_10 then
			ViewManager.Instance:Open(ViewName.LittlePetWarehouseView)	--跳到小宠物仓库
		end
		return
	end
	if self.chest_shop_mode > CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_30 then
		return
	end
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_1 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_10 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_50 or
		self.chest_shop_mode == CHEST_HAPPYHITEGG_MODE_1  or 
		self.chest_shop_mode == CHEST_HAPPYHITEGG_MODE_10	or
		self.chest_shop_mode == CHEST_HAPPYHITEGG_MODE_30 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_50 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_50 or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_1 or
   		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_10 or
   		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_50 then

		ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)  --跳到寻宝仓库
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1 or 
			self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10
			then

			self:Close()
	else
		SpiritCtrl.Instance.spirit_view:OpenWarehouse()
	end
end

function TipShowTreasureView:OneClick()
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_GET_REWARD then
		self:Close()
	end
	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_GET_REWARD then
		self:Close()
	end
	if self.chest_shop_mode == CHEST_SHOP_MODE.LUCKLY_TURNTABLE_GET_REWARD then
		self:Close()
	end

	if self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GUAJITA_REWARD or
		self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_PUSH_FB_STAR_REWARD then
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
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE_1)
		TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE_1, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE_10)
		TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE_10, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50 then
		TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE_50)
		TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE_50, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1 then
		SpiritCtrl.Instance:SendHuntSpiritReq(CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10 then
		SpiritCtrl.Instance:SendHuntSpiritReq(CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_50 then
		SpiritCtrl.Instance:SendHuntSpiritReq(CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_50, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
		----------------------------------------------------------欢乐砸蛋-------------------------------------------------------------------------
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_1 then
		--HappyHitEggData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_1)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN, RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_TAO, RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_1)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_10 then
		--HappyHitEggData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_MiJingXunBao_MODE_10)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN, RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_TAO, RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_10)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPYHITEGG_MODE_30 then
		--HappyHitEggData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_MiJingXunBao_MODE_50)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_ZADAN, RA_HUANLEZADAN_OPERA_TYPE.RA_HUANLEZADAN_OPERA_TYPE_TAO, RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_30)
		----------------------------------------------------------刮刮乐------------------------------------------------------------------
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_1 then
		ScratchTicketData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_1)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_PLAY_TIMES, RA_GUAGUA_PLAY_MULTI_TYPES.RA_GUAGUA_PLAY_ONE_TIME)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_10 then
		ScratchTicketData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_10)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_PLAY_TIMES, RA_GUAGUA_PLAY_MULTI_TYPES.RA_GUAGUA_PLAY_TEN_TIMES)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_50 then
		ScratchTicketData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_GuaGuaLe_MODE_50)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA, RA_GUAGUA_OPERA_TYPE.RA_GUAGUA_OPERA_TYPE_PLAY_TIMES, RA_GUAGUA_PLAY_MULTI_TYPES.RA_GUAGUA_PLAY_THIRTY_TIMES)
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
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RUNE_BAOXIANG_MODE then -- zcz 再来一次
		local item_id = RuneData.Instance:GetBaoXiangId()
		local have_num = ItemData.Instance:GetItemNumInBagById(item_id)
		if have_num > 0 then
			RuneData.Instance:SetBaoXiangId(item_id)
			local index = ItemData.Instance:GetItemIndex(item_id)
			local used_num = have_num > 6 and 6 or have_num
			PackageCtrl.Instance:SendUseItem(index, used_num)
		else
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			if item_cfg then
				local des = string.format(Language.Rune.NumNotEnough, ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
				SysMsgCtrl.Instance:ErrorRemind(des)
			end
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1 then
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 1)
		-- if not ShenGeData.Instance:GetBlessAniState() then
		-- 	return
		-- end
		-- self:Close()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10 then
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 10)
		-- if not ShenGeData.Instance:GetBlessAniState() then
		-- 	return
		-- end
		-- self:Close()
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_1 then
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_GUNGUN_LE_REQ, 0)
		if not ShengXiaoData.Instance:GetErnieIsStopPlayAni() then
			self:Close()
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_10 then
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_GUNGUN_LE_REQ, 1)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HUNQI_BAOZANG_1 then
		HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_OPEN_BOX, 1)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HUNQI_BAOZANG_10 then
		HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_OPEN_BOX, 10)
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
		--有10抽钥匙的时候
		local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
		local item_id = randact_cfg.other[1].jinyinta_consume_item
		local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
		if item_num > 0 then
			local bags_grid_num = ItemData.Instance:GetEmptyNum()
			if bags_grid_num > 0 then
				JinYinTaData.Instance:SetTenNotClick(false)
			end
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_DO_LOTTERY,CHARGE_OPERA.CHOU_TEN)
		else
			-- 有足够的钻石
			if role_gold >= need_gold  then
				local bags_grid_num = ItemData.Instance:GetEmptyNum()
				if bags_grid_num > 0 then
					JinYinTaData.Instance:SetTenNotClick(false)
				end
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_DO_LOTTERY,CHARGE_OPERA.CHOU_TEN)
			else
				TipsCtrl.Instance:ShowLackDiamondView()
			end
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_JINYIN_QUICK_REWARD then
		local cfg = SpiritData.Instance:GetQuickGetList()
		if cfg ~= nil and cfg.index ~= nil then
			local spirit_data = SpiritData.Instance:GetSpiritHomeInfoByIndex(cfg.index)
			if spirit_data ~= nil and spirit_data.reward_times ~= nil then
				local limlit_time = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_times_limit") or 0
				if spirit_data.reward_times >= limlit_time then
					SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritHomeQuickLimlit)
					self:Close()
					return
				end
			end
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_QUICK, main_role_vo.role_id, cfg.index - 1)
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_1 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU,1)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_10 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU,10)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.LOCKY_DRAW_10 then --占卜十次
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, RA_TIANMING_DIVINATION_OPERA_TYPE.RA_TIANMING_DIVINATION_OPERA_TYPE_START_CHOU,10)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_10 then
		local cur_level = FanFanZhuanData.Instance:GetCurLevel()
		local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
		local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
		if randact_cfg then
			if cur_level == 0 then
				gold = randact_cfg.other[1].king_draw_chuji_once_gold
			elseif cur_level == 1 then
				gold = randact_cfg.other[1].king_draw_zhongji_once_gold
			elseif cur_level == 2 then
				gold = randact_cfg.other[1].king_draw_gaoji_once_gold
			end
		end
		local need_gold = gold * 10 or 0
		if role_gold >= need_gold then
			--有足够元宝
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_PLAY_TIMES, cur_level, 10)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_FANFANZHUANG_50 then
		--大奖翻翻转50次改为30次
		local cur_level = FanFanZhuanData.Instance:GetCurLevel()
		local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
		local item_id = randact_cfg.other[1].king_draw_gaoji_consume_item
		local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
		local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
		if randact_cfg then
			if cur_level == 0 then
				gold = randact_cfg.other[1].king_draw_chuji_once_gold
			elseif cur_level == 1 then
				gold = randact_cfg.other[1].king_draw_zhongji_once_gold
			elseif cur_level == 2 then
				gold = randact_cfg.other[1].king_draw_gaoji_once_gold
			end
		end
		local need_gold = gold * 30 or 0
		if item_num > 0 then
			--当有钥匙的时候
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_PLAY_TIMES, cur_level, 30)
		else
			if role_gold >= need_gold then
				--有足够元宝
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_PLAY_TIMES, cur_level, 30)
			else
				TipsCtrl.Instance:ShowLackDiamondView()
			end
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_RANK_LUCK_CHESS_10 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP, RA_PROMOTING_POSITION_OPERA_TYPE.RA_PROMOTING_POSITION_OPERA_TYPE_PLAY, 10)
	--秘境寻宝
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_1 then
		SecretTreasureHuntingData.Instance:SetChestShopModeByTreasureView(CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_1)
		SecretTreasureHuntingCtrl.Instance:SendGetKaifuActivityInfo(RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_TAO, RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_1)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_10 then
		SecretTreasureHuntingData.Instance:SetChestShopModeByTreasureView(CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_10)
		SecretTreasureHuntingCtrl.Instance:SendGetKaifuActivityInfo(RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_TAO, RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_10)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_30 then
		SecretTreasureHuntingData.Instance:SetChestShopModeByTreasureView(CHEST_SHOP_MODE.CHEST_MIJINGXUNBAO3_MODE_30)
		SecretTreasureHuntingCtrl.Instance:SendGetKaifuActivityInfo(RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_TAO, RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_30)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.HAPPY_RECHARGE_1 then
		if ItemData.Instance:GetEmptyNum() >= 1 then
			HappyRechargeCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE,
				RA_CHONGZHI_NIU_EGG_OPERA_TYPE.RA_CHONGZHI_NIU_EGG_OPERA_TYPE_CHOU, 1)
		else
			TipsCtrl.Instance:ShowSystemMsg("背包已满")
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.HAPPY_RECHARGE_10 then
		if ItemData.Instance:GetEmptyNum() >= 10 then
			HappyRechargeCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE,
				RA_CHONGZHI_NIU_EGG_OPERA_TYPE.RA_CHONGZHI_NIU_EGG_OPERA_TYPE_CHOU, 10)
		else
			TipsCtrl.Instance:ShowSystemMsg("背包已满")
		end
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_WABAO_QUICKL then
		ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_WABAO)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_1 then
		local opera_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_CHOUJIANG
		local param1 = LITTLE_PET_CHOUJIANG_TYPE.ONE
		LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, param1, param2, param3)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_10 then
		local opera_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_CHOUJIANG
		local param1 = LITTLE_PET_CHOUJIANG_TYPE.TEN
		LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, param1, param2, param3)
----------------------------------------------------------欢乐摇奖-------------------------------------------------------------------------
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_1 then
		HappyErnieData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_1)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_ERNIE, RA_HAPPYERNIE_OPERA_TYPE.RA_HAPPYERNIE_OPERA_TYPE_TAO, RA_HAPPYERNIE_CHOU_TYPE.RA_HAPPYERNIE_CHOU_TYPE_1)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_10 then
		HappyErnieData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_10)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_ERNIE, RA_HAPPYERNIE_OPERA_TYPE.RA_HAPPYERNIE_OPERA_TYPE_TAO, RA_HAPPYERNIE_CHOU_TYPE.RA_HAPPYERNIE_CHOU_TYPE_10)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_30 then
		HappyErnieData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_HAPPY_ERNIE_MODE_30)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HAPPY_ERNIE, RA_HAPPYERNIE_OPERA_TYPE.RA_HAPPYERNIE_OPERA_TYPE_TAO, RA_HAPPYERNIE_CHOU_TYPE.RA_HAPPYERNIE_CHOU_TYPE_30)

	----------------------------------------------------------中秋欢乐摇奖-------------------------------------------------------------------------
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_1 then
		AutumnHappyErnieData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_1)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2, RA_HUANLE_YAOJIANG_2_OPERA_TYPE.RA_HUANLEYAOJIANG_OPERA_2_TYPE_TAO, RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE.RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_1)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_10 then
		AutumnHappyErnieData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_10)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2, RA_HUANLE_YAOJIANG_2_OPERA_TYPE.RA_HUANLEYAOJIANG_OPERA_2_TYPE_TAO, RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE.RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_10)
	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_30 then
		AutumnHappyErnieData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_ZHONGQIU_HAPPY_ERNIE_MODE_30)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2, RA_HUANLE_YAOJIANG_2_OPERA_TYPE.RA_HUANLEYAOJIANG_OPERA_2_TYPE_TAO, RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE.RA_ZHONGQIUHAPPYERNIE_CHOU_TYPE_30)

	elseif self.chest_shop_mode == CHEST_SHOP_MODE.CHEST_SYMBOL_NIUDAN then
		if ItemData.Instance:GetEmptyNum() >= 10 then
			SymbolCtrl.Instance:SendChoujiangElementHeartReqAgain()
		else
			TipsCtrl.Instance:ShowSystemMsg("背包已满")
		end
	end
	
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

function TipShowTreasureView:SetTreasureViewData(data)
	self.wabao_data = data
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

function TipShowTreasureView:SetCloseCallBack(call_back)
	self.close_call_back = call_back
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
	if not next(data) then
		self:SetActive(false)
	else
		self:SetActive(true)
	end

	if TipShowTreasureView.Instance:GetTreasureType() == TREASURE_TYPE.SWORD then
		if not next(data) then
			return
		end

		self.is_sword:SetValue(true)
		local star_str = "star_bg_"..data.star_count
		self.sword_bg:SetAsset("uis/views/swordartonline/images_atlas",star_str)

		  local sword_str = "sword_"..data.res_id
		self.sword:SetAsset("uis/views/swordartonline/images_atlas",sword_str)
	else
		self.is_sword:SetValue(false)
		self.treasure_item:SetData(data)
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

