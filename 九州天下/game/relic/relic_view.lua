RelicView = RelicView or BaseClass(BaseView)

local MAX_BOSS_NUM = 4

function RelicView:__init()
	self.ui_config = {"uis/views/relicview","RelicView"}
	self.view_layer = UiLayer.MainUILow

	self.temp_box_num = 0
	self.is_safe_area_adapter = true
end

function RelicView:__delete()

end

function RelicView:LoadCallBack()
	self.show_info = self:FindVariable("ShowInfo")
	self.rest_boss_count = self:FindVariable("RestBossCount")
	self.rest_box_count = self:FindVariable("RestBoxCount")
	self.box_list = {}
	for i = 1, 4 do
		self.box_list[i] = self:FindVariable("BoxCount"..i)
	end

	self.time = self:FindVariable("Time")
	self.show_over = self:FindVariable("GameOver")
	self.over_text = self:FindVariable("OverText")

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end

function RelicView:OpenCallBack()
	self.temp_box_num = 0
	self:FlushBossTime()
	self:Flush()
	FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.OnClickBossIcon, self))
end

function RelicView:CloseCallBack()
end

function RelicView:ReleaseCallBack()
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	self:RemoveCountDown()

	self.show_info = nil
	self.rest_boss_count = nil
	self.rest_box_count = nil
	self.box_list = nil
	self.time = nil
	self.show_over = nil
	self.over_text = nil
end

function RelicView:SwitchButtonState(enable)
	self.show_info:SetValue(enable)
end

function RelicView:OnClickBossIcon()
	local info = RelicData.Instance:GetXingzuoYijiInfo()
	if nil == next(info) then return end

	if info.now_boss_num <= 0 then return end

	local x, y = self:GetMonsterPos()

	if x and y then
		self:MoveToPosOperateFight(x, y)
	end
end

function RelicView:MoveToPosOperateFight(x, y)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)

	local scene_id = Scene.Instance:GetSceneId()
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 3, 0)
end

-- 获取打怪的位置
function RelicView:GetMonsterPos()
	local target_distance = 1000 * 1000
	local target_x = nil
	local target_y = nil
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local obj_move_info_list = Scene.Instance:GetObjMoveInfoList()
	local monster_list = Scene.Instance:GetMonsterList()

	for k, v in pairs(monster_list) do
		local vo = v:GetVo()
		if not v:IsRealDead()
			and BaseSceneLogic.IsAttackMonster(vo.monster_id)
			and vo.obj_type == SceneObjType.Monster
			and not AStarFindWay:IsBlock(vo.pos_x, vo.pos_y) then

			local distance = GameMath.GetDistance(x, y, vo.pos_x, vo.pos_y, false)
			if distance < target_distance then
				target_x = vo.pos_x
				target_y = vo.pos_y
				target_distance = distance
			end
		end
	end

	if nil ~= target_x and nil ~= target_y then
		return target_x, target_y
	end

	for k, v in pairs(obj_move_info_list) do
		local vo = v:GetVo()
		if vo.obj_type == SceneObjType.Monster
			and BaseSceneLogic.IsAttackMonster(vo.type_special_id)
			and not AStarFindWay:IsBlock(vo.pos_x, vo.pos_y) then

			local distance = GameMath.GetDistance(x, y, vo.pos_x, vo.pos_y, false)
			if distance < target_distance then
				target_x = vo.pos_x
				target_y = vo.pos_y
				target_distance = distance
			end
		end
	end

	return target_x, target_y
end

function RelicView:OnFlush(param_t)
	self:SetInfo()
	self:FlushBossTime()

	FuBenCtrl.Instance:FlushFbIconView("xzyj_info")
end

function RelicView:SetInfo()
	local info = RelicData.Instance:GetXingzuoYijiInfo()
	if nil == next(info) then return end

	-- self.rest_boss_count:SetValue(info.now_boss_num)
	-- self.rest_box_count:SetValue(info.now_box_num)

	for k,v in pairs(self.box_list) do
		v:SetValue(info.gather_box_num_list[k] or 0)
	end

	self.show_over:SetValue(info.next_boss_refresh_time <= 0)

	FuBenCtrl.Instance:SetMonsterIconState(true)
	FuBenCtrl.Instance:ShowMonsterHadFlush(true, string.format(Language.ShengXiao.ClickGoTo, info.now_boss_num, MAX_BOSS_NUM))
	FuBenCtrl.Instance:SetMonsterIconGray(info.now_boss_num <= 0)
end

function RelicView:FlushBossTime()
	local info = RelicData.Instance:GetXingzuoYijiInfo()
	if nil == next(info) then return end

	local total_time = info.next_boss_refresh_time or 0
	if total_time > 0 then
		if self.temp_box_num > info.now_box_num and info.now_box_num <= 0  then
			self:RemoveCountDown()
		end

		if nil == self.count_down then
			self:DiffTime(0, total_time)
			self.count_down = CountDown.Instance:AddCountDown(total_time, 1, BindTool.Bind(self.DiffTime, self))
		end
	else
		self.over_text:SetValue(Language.ShengXiao.CloseDoor)
		self:RemoveCountDown()
	end

	self.temp_box_num = info.now_box_num
end

function RelicView:DiffTime(elapse_time, total_time)
	local left_time = math.floor(total_time - elapse_time)
	local the_time_text = TimeUtil.FormatSecond(left_time, 4)
	self.time:SetValue(the_time_text)
	if left_time <= 0 then
		self:RemoveCountDown()
	end
end

function RelicView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end