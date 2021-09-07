TipWaBaoView = TipWaBaoView or BaseClass(BaseView)

local FIX_DISTANCE_X = 20
local FIX_DISTANCE_Y = 60
local FIX_DROP_HP = 1000

local TOUCH_STATE =
{
	UP = 1,
	DOWN = 2,
}

-- local FIX_MOUSE_POS =
-- {
-- 	x1 = 463,
-- 	x2 = 866,
-- 	y1 = 206,
-- 	y2 = 555,
-- }

local HURT_BOSS_POS =
{
	CENTER_X = 695,
	CENTER_Y1 = 222,
	CENTER_Y2 = 550,
}

local KILL_TYPE =
{
	DEAD = 1,
	NO_DEAD = 0,
}

local BOSS_FIX_EXIT = 1.5      --BOSS界面退出时间
local BOSS_EXIT_ADD_TIME = 1.5 --BOSS界面增加退出时间
function TipWaBaoView:__init()
	self.ui_config = {"uis/views/tips/wabaotips", "WaBaoTips"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.vew_cache_time = 10000000
	self.time_quest_list = {}
	self.old_touch_state = ""
	self.is_cal = false
	self.destory_hp_timer = 0
	self.exit_time = 0
	self.is_completed = false 		 	--时间到了, 或时间规定内击杀boss标记
	self.is_play_dead_anim = false	 	--播放完死亡动画的标记
	self.is_play_hide_anim = false		--播放完渐变动画的标记
	self.is_paly_anim = false			--是否刷新界面,如果正在播放动画或击打boss,协议来了则暂不刷新界面
end

function TipWaBaoView:ReleaseCallBack()
	self.show_daoju_view = nil
	self.time_text = nil
	self.boss_progress_value = nil
	self.boss_progress_text = nil
	if self.daoju_model_view then
		self.daoju_model_view:DeleteMe()
		self.daoju_model_view = nil
	end
	if self.boss_model_view then
		self.boss_model_view:DeleteMe()
		self.boss_model_view = nil
	end

	for i=1,3 do
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
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.drop_hp_parent = nil
	self.begin_pos_go = nil
	self.daoju_display = nil
end

function TipWaBaoView:LoadCallBack()
	self.text_list = {}
	self.daoju_display = self:FindObj("daoju_display")
	self.boss_display = self:FindObj("boss_display")
	self.drop_hp_parent = self:FindObj("drop_hp_parent")

	self.time_text = self:FindVariable("time_text")
	self.boss_progress_value = self:FindVariable("boss_progress_value")
	self.boss_progress_text = self:FindVariable("boss_progress_text")
	self.show_daoju_view = self:FindVariable("show_daoju_view")
	self.show_daoju_block = self:FindVariable("show_daoju_block")
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self.begin_pos_go = self:FindObj("begin_pos")

	self.item_cell_list = {}
	for i=1,3 do
		self.item_cell_list[i] = {}
		self.item_cell_list[i].item_cell = ItemCell.New()
		self.item_cell_list[i].item_game = self:FindObj("item"..i)
		self.item_cell_list[i].item_cell:SetInstanceParent(self.item_cell_list[i].item_game)
		self.item_cell_list[i].item_fix_pos = self:FindObj("item_pos"..i)
		self.item_cell_list[i].is_show = self:FindVariable("show_item_" .. i)
		self.item_cell_list[i].show_item_pos = self:FindVariable("show_item_pos_" .. i)
	end

end

function TipWaBaoView:SetData()
	if self.is_paly_anim == false then --true的话 等boss死亡表现完后,再自动刷新
		local reward_type = WaBaoData.Instance:GetWaBaoInfo().wabao_reward_type
		if reward_type ~= 4 then
			self.wabao_type = WABAO_REWARD_TYPE.DAOJU
		else
			self.wabao_type = WABAO_REWARD_TYPE.BOSS
		end
		self:Flush()
	end
end

function TipWaBaoView:OpenCallBack()
	local wabao_data = WaBaoData.Instance
	self.max_shouhu_time = wabao_data:GetOtherCfg().shouhuzhe_time
	self.max_hp = wabao_data:GetOtherCfg().shouhuzhe_hp
	self.hp = self.max_hp
	self.exit_time = 0
	self.is_completed = false
	self.is_play_dead_anim = false
	self.is_play_hide_anim = false
	if self.wabao_type == WABAO_REWARD_TYPE.BOSS then
		self:StartPlay()
	end
end

function TipWaBaoView:CloseCallBack()
	if self.wabao_type == WABAO_REWARD_TYPE.BOSS then
		self:StopPlay()
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end

	for i=1,3 do
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


	for k,v in pairs(self.text_list) do
		GameObject.Destroy(v.gameObject)
		v = nil
	end
	self.text_list = {}
	self.wabao_type = nil

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TipWaBaoView:OnCloseClick()
	self:Close()
end

function TipWaBaoView:OnFlush()
	self.show_daoju_view:SetValue(self.wabao_type == WABAO_REWARD_TYPE.DAOJU)
	if self.wabao_type == WABAO_REWARD_TYPE.DAOJU then
		if self.daoju_model_view == nil then
			self.daoju_model_view = RoleModel.New()
			self.daoju_model_view:SetDisplay(self.daoju_display.ui3d_display)
		end
		if self.cal_time_quest == nil then
			self:CalTimeToMove()
		end

		local reward_items = WaBaoData.Instance:GetRewardItems()
		if reward_items and next(reward_items) then
			for i=1,3 do
				if self.item_cell_list[i] then
					self.item_cell_list[i].item_game.transform.position = self.begin_pos_go.transform.position
				end
				if reward_items[i] then
					self.item_cell_list[i].item_cell:SetData(reward_items[i])
				else
					self.item_cell_list[i].show_item_pos:SetValue(false)
				end
				self.item_cell_list[i].is_show:SetValue(false)
			end
		end

		local res_id = WaBaoData.Instance:GetRewardResId()
		self.daoju_model_view:SetMainAsset(ResPath.GetBoxModel(res_id))
		self.daoju_model_view:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.BOX], res_id, DISPLAY_PANEL.PROP_TIP)
		local flag = WaBaoData.Instance:GetFastWaBaoFlag()
		if not flag then
			self:SetAutoTalkTime()
		end
		WaBaoData.Instance:SetFastWaBaoFlag(false)
	elseif self.wabao_type == WABAO_REWARD_TYPE.BOSS then
		self.is_paly_anim = true
		if self.boss_model_view == nil then
			self.boss_model_view = RoleModel.New()
			self.boss_model_view:SetDisplay(self.boss_display.ui3d_display)
			local res_id = 3014001
			self.boss_model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
			self.boss_model_view:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MONSTER], res_id, DISPLAY_PANEL.HUAN_HUA)
		end
		self.boss_progress_text:SetValue(self.hp .."/".. self.max_hp)
		self.boss_progress_value:SetValue(self.hp/self.max_hp)
	end
end

-- 设置关闭倒计时
function TipWaBaoView:SetAutoTalkTime()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_START, 0)
	self.count_down = CountDown.Instance:AddCountDown(8, 1, BindTool.Bind(self.CountDown, self))
end

-- 倒计时结束后自动挖下一个宝
function TipWaBaoView:CountDown(elapse_time, total_time)
	if elapse_time >= total_time then
		local pos_cfg = WaBaoData.Instance:GetWaBaoInfo()
		if pos_cfg.baozang_scene_id and pos_cfg.baozang_scene_id ~= 0 then
			MoveCache.cant_fly = true
			GuajiCtrl.Instance:MoveToPos(pos_cfg.baozang_scene_id, pos_cfg.baozang_pos_x, pos_cfg.baozang_pos_y, 0, 0)
		end
		self:Close()
	end
end

function TipWaBaoView:StartPlay()
	Runner.Instance:AddRunObj(self)
end

function TipWaBaoView:StopPlay()
	Runner.Instance:RemoveRunObj(self)
end

function TipWaBaoView:Update()
	if self.is_completed == false then
		local time = math.max(0, WaBaoData.Instance:GetWaBaoInfo().shouhuzhe_time - TimeCtrl.Instance:GetServerTime())
		if time > 0 then
			self.time_text:SetValue(ToColorStr(TimeUtil.FormatSecond(time, 2)))
		else
			if self.hp > 0 then --时间到了,未杀死boss
				self.kill_type = KILL_TYPE.NO_DEAD
				self.is_completed = true
				local draw_obj = self.boss_model_view.draw_obj
				local DecayMounstCount = 0
				if nil ~= draw_obj then
					DecayMounstCount = DecayMounstCount + 1
					draw_obj:PlayDead(1, function()
						DecayMounstCount = DecayMounstCount - 1
					end)
				end
			end
		end
	else --boss死亡
		self.exit_time = self.exit_time + UnityEngine.Time.deltaTime
		if self.kill_type == KILL_TYPE.NO_DEAD then --时间到了boss未被击杀
			if self.is_play_hide_anim == false then
				self.is_play_hide_anim = true
				self:HideBoss()
			end
			if self.exit_time > BOSS_FIX_EXIT and self.is_play_dead_anim == false then
				self.is_play_dead_anim = true
				self.is_paly_anim = false
				self:ExitBoss()
			end
		elseif self.kill_type == KILL_TYPE.DEAD then
			if self.exit_time > BOSS_FIX_EXIT and self.is_play_dead_anim == false then
				self.is_play_dead_anim = true
				if self.is_play_hide_anim == false then
					self.is_play_hide_anim = true
					self:HideBoss()
				end
			end

			if self.exit_time > BOSS_FIX_EXIT + BOSS_EXIT_ADD_TIME then
				self.is_paly_anim = false
				self:ExitBoss()
			end
		end
	end

	if self:IsTouchDown() and "down" ~= self.old_touch_state then
		self.old_touch_state = "down"
		self:OnTouchBegin()
		return
	end

	if self.old_touch_state == "down" then
		if self:IsTouchUp() then
			self.old_touch_state = ""
			self:OnTouchEnd()
		else
			if "down" == self.old_touch_state then
				self:OnTouchMove()
				return
			end
		end
	end
	if #self.text_list > 0 then
		self.destory_hp_timer = self.destory_hp_timer + UnityEngine.Time.deltaTime
		if self.destory_hp_timer > 0.6 then
			if self.text_list[1] then
				GameObject.Destroy(self.text_list[1].gameObject)
				table.remove(self.text_list, 1)
			end
			self.destory_hp_timer = 0
		end
	end
end

function TipWaBaoView:IsTouchDown()
	return UnityEngine.Input.GetMouseButtonDown(0) or UnityEngine.Input.touchCount > 0 --0是左键
end

function TipWaBaoView:ExitBoss()
	self:SetData()
	self:StopPlay()
end

function TipWaBaoView:HideBoss()
	local draw_obj = self.boss_model_view.draw_obj
	local DecayMounstCount = 0
	if nil ~= draw_obj then
		DecayMounstCount = DecayMounstCount + 1
		draw_obj:PlayDead(1, function()
			DecayMounstCount = DecayMounstCount - 1
		end)
	end
end

function TipWaBaoView:IsTouchUp()
	return UnityEngine.Input.GetMouseButtonUp(0)
end

function TipWaBaoView:OnTouchBegin()
	self.is_left = UnityEngine.Input.mousePosition.x <= HURT_BOSS_POS.CENTER_X
	self.is_cal = false
end

function TipWaBaoView:OnTouchEnd()
	self.is_cal = false
end

function TipWaBaoView:OnTouchMove()
	if self.is_cal == false then
			local cur_x = UnityEngine.Input.mousePosition.x
			local cur_y = UnityEngine.Input.mousePosition.y
			self.begin_pos_x = cur_x
			self.begin_pos_y = cur_y
			self.begin_pos = UnityEngine.Input.mousePosition
			self.is_cal = true
	else
		if self:CheckIsHurtBoss() then
			local end_pos = {}
			local end_pos_x, end_pos_y = UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y
			end_pos = Vector3(end_pos_x, end_pos_y, 0)

			local begin_pos = {}
			local begin_pos_x, begin_pos_y = self.begin_pos.x, self.begin_pos.y
			begin_pos = Vector3(begin_pos_x, begin_pos_y, 0)

			local move_dir = nil
			local delta_pos = u3d.v2Sub(end_pos, begin_pos)
			local move_total_distance = u3d.v2Length(delta_pos)
			move_dir = u3d.v2Normalize(delta_pos)
			if self.hp > 0 then
				self.hp = self.hp - FIX_DROP_HP
				self.boss_model_view:SetTrigger("hurt")
				self.boss_progress_text:SetValue(self.hp .."/".. self.max_hp)
				self.boss_progress_value:SetValue(self.hp/self.max_hp)
				self:PlayDropHpAnim()
				local z = math.deg(math.atan2(move_dir.y, move_dir.x))
				local rotation = Quaternion.Euler(0, 0, z)
				-- local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
				-- --转换屏幕坐标为本地坐标
				-- local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
				-- local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, self.begin_pos, uicamera, Vector2(0, 0))
				EffectManager.Instance:PlayAtTransform("effects2/prefab/ui/ui_daoguang_01_prefab", "UI_daoguang_01", self.root_node.transform, 1.0, nil, rotation)
				if self.is_left == true then
					self.is_left = false
				else
					self.is_left = true
				end
				self.is_cal = false
			end
			if self.hp <= 0 and self.is_completed == false then --杀死boss后发协议
				self.kill_type = KILL_TYPE.DEAD
				self.is_completed = true
				self.boss_model_view:SetInteger("status", 2)
				WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_SHOUHUZHE_TIME, self.kill_type)
			end
		end
	end
end

function TipWaBaoView:CheckIsHurtBoss()
	if self.is_left then
		return UnityEngine.Input.mousePosition.x > HURT_BOSS_POS.CENTER_X and
		(UnityEngine.Input.mousePosition.y > HURT_BOSS_POS.CENTER_Y1 or UnityEngine.Input.mousePosition.y < HURT_BOSS_POS.CENTER_Y2)
	else
		return UnityEngine.Input.mousePosition.x < HURT_BOSS_POS.CENTER_X and
		(UnityEngine.Input.mousePosition.y > HURT_BOSS_POS.CENTER_Y1 or UnityEngine.Input.mousePosition.y < HURT_BOSS_POS.CENTER_Y2)
	end
end

function TipWaBaoView:MoveToTarget(index)
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
			   ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_WABAO)
			end
		end
		tweener:OnComplete(close_view)
		item.loop_tweener = tweener
	end, 0)
end

function TipWaBaoView:CalTimeToMove()
	if self.cal_time_quest then return end
	self.show_daoju_block:SetValue(true)
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		local reward_items = WaBaoData.Instance:GetRewardItems()
		for i=1,3 do
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

function TipWaBaoView:PlayDropHpAnim()
	PrefabPool.Instance:Load(AssetID("uis/views/tips/wabaotips_prefab", "DropHpText"), function (prefab)
		if nil == prefab then
			return
		end
		local obj = GameObject.Instantiate(prefab)
		local obj_transform = obj.transform
		obj_transform:SetParent(self.drop_hp_parent.transform, false)
		table.insert(self.text_list, obj_transform)
		PrefabPool.Instance:Free(prefab)
	end)
end

