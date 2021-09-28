SpiritExpRewardView = SpiritExpRewardView or BaseClass(BaseView)

local FIX_DISTANCE_X = 20
local FIX_DISTANCE_Y = 60
local FIX_DROP_HP = 1000

function SpiritExpRewardView:__init()
	self.ui_config = {"uis/views/spiritview_prefab", "SpiritExpRewardTip"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.vew_cache_time = 10000000
	self.time_quest_list = {}
	self.old_touch_state = ""
	self.is_cal = false
	self.destory_hp_timer = 0
	self.exit_time = 0
	self.is_paly_anim = false			--是否刷新界面,如果正在播放动画或击打boss,协议来了则暂不刷新界面
end

function SpiritExpRewardView:ReleaseCallBack()
	self.show_daoju_view = nil
	if self.daoju_model_view then
		self.daoju_model_view:DeleteMe()
		self.daoju_model_view = nil
	end

	for i=1,4 do
		self.item_cell_list[i].item_cell:DeleteMe()
		self.item_cell_list[i].item_cell = nil
		self.item_cell_list[i].is_show = nil
		self.item_cell_list[i].show_item_pos = nil
		if self.time_quest_list[i] then
			GlobalTimerQuest:CancelQuest(self.time_quest_list[i])
			self.time_quest_list[i] = nil
		end
	end
	self.item_cell_list = {}
	self.time_quest_list = {}

	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end

	self.drop_hp_parent = nil
	self.begin_pos_go = nil
	self.daoju_display = nil
	self.show_reward_btn = nil
	self.show_daoju_block = nil
	self.str_consume = nil
	self.show_dia = nil
	self.show_consume = nil
end

function SpiritExpRewardView:LoadCallBack()
	self.text_list = {}
	self.begin_pos_go = self:FindObj("begin_pos")
	self.daoju_display = self:FindObj("daoju_display")

	self.show_daoju_view = self:FindVariable("show_daoju_view")
	self.show_daoju_block = self:FindVariable("show_daoju_block")
	self.show_reward_btn = self:FindVariable("show_reward_btn")

	self.str_consume = self:FindVariable("StrConsume")
	self.show_dia = self:FindVariable("ShowDia")
	self.show_consume = self:FindVariable("ShowConsume")

	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("clik_reward",BindTool.Bind(self.OnRewardClick, self))

	self.item_cell_list = {}
	for i=1,4 do
		self.item_cell_list[i] = {}
		self.item_cell_list[i].item_cell = ItemCell.New()
		self.item_cell_list[i].item_game = self:FindObj("item"..i)
		self.item_cell_list[i].item_cell:SetInstanceParent(self.item_cell_list[i].item_game)
		self.item_cell_list[i].item_fix_pos = self:FindObj("item_pos"..i)
		self.item_cell_list[i].is_show = self:FindVariable("show_item_" .. i)
		self.item_cell_list[i].show_item_pos = self:FindVariable("show_item_pos_" .. i)
	end

end

function SpiritExpRewardView:SetData(data)
	if self.is_paly_anim == false then --true的话 等boss死亡表现完后,再自动刷新
		-- local reward_type = WaBaoData.Instance:GetWaBaoInfo().wabao_reward_type
		-- if reward_type ~= 4 then
		-- 	self.wabao_type = WABAO_REWARD_TYPE.DAOJU
		-- else
		-- 	self.wabao_type = WABAO_REWARD_TYPE.BOSS
		-- end
		self.stage_index = data
		if not self:IsOpen() then
			self:Open()
		end
		--self:Flush()
	end
end

function SpiritExpRewardView:OpenCallBack()
	-- local wabao_data = WaBaoData.Instance
	-- self.max_shouhu_time = wabao_data:GetOtherCfg().shouhuzhe_time
	-- self.max_hp = wabao_data:GetOtherCfg().shouhuzhe_hp
	-- self.hp = self.max_hp
	self.exit_time = 0
	self.is_completed = false
	-- self.is_play_dead_anim = false
	-- self.is_play_hide_anim = false
	-- if self.wabao_type == WABAO_REWARD_TYPE.BOSS then
	-- 	self:StartPlay()
	-- end
	self:Flush()
end

function SpiritExpRewardView:CloseCallBack()
	-- if self.wabao_type == WABAO_REWARD_TYPE.BOSS then
	-- 	self:StopPlay()
	--if self.wabao_type == WABAO_REWARD_TYPE.DAOJU then
		-- local pos_cfg = WaBaoData.Instance:GetWaBaoInfo()
		-- if pos_cfg.baozang_scene_id and pos_cfg.baozang_scene_id ~= 0 then
		-- 	MoveCache.cant_fly = true
		-- 	GuajiCtrl.Instance:MoveToPos(pos_cfg.baozang_scene_id, pos_cfg.baozang_pos_x, pos_cfg.baozang_pos_y, 0, 0)
		-- end
		-- if self.is_reward == false then
		-- 	self.is_reward = true
		-- 	ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_WABAO)
		-- end
	--end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end

	for i=1,4 do
		if self.item_cell_list[i] then
			self.item_cell_list[i].item_game.transform.position = self.begin_pos_go.transform.position
		end
		if self.time_quest_list[i] then
			GlobalTimerQuest:CancelQuest(self.time_quest_list[i])
			self.time_quest_list[i] = nil
		end
		self.time_quest_list = {}
		self.item_cell_list[i].show_item_pos:SetValue(true)
	end


	-- for k,v in pairs(self.text_list) do
	-- 	GameObject.Destroy(v.gameObject)
	-- 	v = nil
	-- end
	--self.text_list = {}
	--self.wabao_type = nil

	self.show_reward_btn:SetValue(false)
	--self.is_reward = false
end

function SpiritExpRewardView:OnCloseClick()
	self:Close()
end

function SpiritExpRewardView:OnRewardClick()
	if self.stage_index == nil then
		return
	end

	local cur_data = SpiritData.Instance:GetStageInfoByIndex(self.stage_index)
	if cur_data == nil or next(cur_data) == nil then
		return
	end

	local other_buy_time = SpiritData.Instance:GetSpiritOtherCfgByName("explore_other_buy") or 0
	local cur_mode = SpiritData.Instance:GetSpiritExpMode()
	local cfg = SpiritData.Instance:GetSpiritExpConfig(cur_mode, self.stage_index - 1)
	local is_buy = 0
	if cfg == nil or next(cfg) == nil then
		return
	end

	local all_time = cfg.free_times + other_buy_time
	if cur_data.reward_times >= all_time then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritExpRewardLimlit)
		return
	end

	if cur_data.reward_times < cfg.free_times then
		SpiritCtrl.Instance:SendJingLingExploreOperReq(JL_EXPLORE_OPER_TYPE.JL_EXPLORE_OPER_TYPE_FETCH, self.stage_index -1, is_buy)
		return
	end

	local has_count = cfg.free_times + other_buy_time - cur_data.reward_times > 0
	local consume_index = other_buy_time - cur_data.reward_times + cfg.free_times
	consume_index = other_buy_time - consume_index + 1
	local consume = 0

	if has_count then
		if cfg["fetch_gold_" .. consume_index] ~= nil then
			consume = cfg["fetch_gold_" .. consume_index]
		end
		str_t = string.format(Language.JingLing.SpiritHomeOpenBox, consume)
		is_buy = 1
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritExpRewardLimlit)
		return
	end


	local str = string.format(string.format(Language.JingLing.SpiritExpRewardAlert, consume))
	TipsCtrl.Instance:ShowCommonAutoView(true, str, function ()
		SpiritCtrl.Instance:SendJingLingExploreOperReq(JL_EXPLORE_OPER_TYPE.JL_EXPLORE_OPER_TYPE_FETCH, self.stage_index -1, is_buy)
	end)
end

function SpiritExpRewardView:OnFlush()
	self.show_daoju_view:SetValue(true)
	self.show_reward_btn:SetValue(false)
	self.is_reward = false
	if self.daoju_model_view == nil then
		self.daoju_model_view = RoleModel.New()
		self.daoju_model_view:SetDisplay(self.daoju_display.ui3d_display)
	end
	if self.cal_time_quest == nil then
		self:CalTimeToMove()
	end

	local data_list = SpiritData.Instance:GetExploreReward(self.stage_index, true)
	if data_list and next(data_list) then
		for i=1,4 do
			if self.item_cell_list[i] then
				self.item_cell_list[i].item_game.transform.position = self.begin_pos_go.transform.position
			end
			if data_list[i] then
				self.item_cell_list[i].item_cell:SetData(data_list[i])
			else
				self.item_cell_list[i].show_item_pos:SetValue(false)
			end
			self.item_cell_list[i].is_show:SetValue(false)
		end
	end

	self.daoju_model_view:SetMainAsset(ResPath.GetBoxModel(17008003))
	self.daoju_model_view:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.BOX], 17008003, DISPLAY_PANEL.PROP_TIP)

	if self.show_consume ~= nil then
		self.show_consume:SetValue(false)
	end

	if self.show_dia ~= nil then
		self.show_dia:SetValue(false)
	end
end

function SpiritExpRewardView:FlushViewText()
	if self.stage_index == nil then
		return
	end

	if self.show_consume ~= nil then
		self.show_consume:SetValue(true)
	end
	local cur_mode = SpiritData.Instance:GetSpiritExpMode()
	local cfg = SpiritData.Instance:GetSpiritExpConfig(cur_mode, self.stage_index - 1)
	if cfg == nil or next(cfg) == nil then
		return
	end

	local data_info = SpiritData.Instance:GetStageInfoByIndex(self.stage_index)
	local has_free = data_info.reward_times < cfg.free_times
	local other_buy_time = SpiritData.Instance:GetSpiritOtherCfgByName("explore_other_buy") or 0
	local has_count = cfg.free_times + other_buy_time - data_info.reward_times > 0
	local consume_index = other_buy_time - data_info.reward_times + cfg.free_times
	consume_index = other_buy_time - consume_index + 1

	if has_count and not has_free then
		if cfg["fetch_gold_" .. consume_index] ~= nil then
			consume = cfg["fetch_gold_" .. consume_index]
		end
		str_t = string.format(Language.JingLing.SpiritHomeOpenBox, consume)
	else
		if has_free then
			str_t = Language.JingLing.SpiritExpRewordFree
		else
			str_t = Language.JingLing.SpiritExpRewardLimlit
		end
	end

	if self.str_consume ~= nil then
		self.str_consume:SetValue(consume)
	end

	if self.show_dia ~= nil then
		self.show_dia:SetValue(has_count and not has_free)
	end
end

function SpiritExpRewardView:MoveToTarget(index)
	if self.time_quest_list[index] then return end
	self.time_quest_list[index] = GlobalTimerQuest:AddDelayTimer(function()
		local item = self.item_cell_list[index].item_game
		local path = {}
		local target_pos = self.item_cell_list[index].item_fix_pos.transform.position
		table.insert(path, target_pos)
		local tweener = item.transform:DOPath(
			path,
			0.8,
			DG.Tweening.PathType.Linear,
			DG.Tweening.PathMode.TopDown2D,
			1,
			nil)
		tweener:SetEase(DG.Tweening.Ease.Linear)
		tweener:SetLoops(0)
		local close_view = function()
			GlobalTimerQuest:CancelQuest(self.time_quest_list[index])
			self.time_quest_list[index] = nil
			if index == 1 then
			   self.show_reward_btn:SetValue(true)
			   self:FlushViewText()
			end
		end
		tweener:OnComplete(close_view)
		item.loop_tweener = tweener
	end, 0)
end

function SpiritExpRewardView:CalTimeToMove()
	if self.cal_time_quest then return end

	self.show_daoju_block:SetValue(true)
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		local reward_items = SpiritData.Instance:GetExploreReward(self.stage_index, true)
		for i=1,4 do
			if reward_items[i] then
				self.item_cell_list[i].is_show:SetValue(true)
				self:MoveToTarget(i)
			end
		end
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
		self.show_daoju_block:SetValue(false)
	end, 2.5)
end


