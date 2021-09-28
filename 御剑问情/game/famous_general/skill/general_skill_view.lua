GeneralSkillView = GeneralSkillView or BaseClass(BaseRender)
local function SkillInfo()
	return {
		icon = nil,
		skill_id = 0,
		is_exist = false,
	}
end

function GeneralSkillView:__init(instance, parent)
	-- 初始化

	self.skill_infos = {}
	for i = 1, 3 do
		table.insert(self.skill_infos, SkillInfo())
	end

	-- 找到要控制的变量
	self.skill_icon_pos_list = {}
	self.skill_icons = {}
	self.skill_cd_progress = {}
	self.skill_cd_time = {}
	for i = 1, 3 do
		self.skill_icon_pos_list[i] = self:FindObj("Skill" .. i)
		self.skill_icons[i] = self:FindVariable("SkillIcon" .. i)
	end

	for i = 2, 3 do
		self.skill_cd_progress[i] = self:FindVariable("SkillCDProgress" .. i)
		self.skill_cd_progress[i]:SetValue(0)
		self.skill_cd_time[i] = self:FindVariable("SkillCDTime" .. i)
		self.skill_cd_time[i]:SetValue(0)
	end

	self.skill_count_down = {}
	self.is_lock_skill = false

	-- 监听UI事件
	self:ListenEvent("AttackDown", BindTool.Bind(self.OnClickAttackDown, self, self.skill_infos[1]))
	self:ListenEvent("AttackUp", BindTool.Bind(self.OnClickAttackUp, self, self.skill_infos[1])) 
	self:ListenEvent("Skill2", BindTool.Bind(self.OnClickSkill, self, self.skill_infos[2]))
	self:ListenEvent("Skill3", BindTool.Bind(self.OnClickSkill, self, self.skill_infos[3]))

	-- 监听系统事件
	-- self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	-- self:BindGlobalEvent(MainUIEventType.ROLE_SKILL_CHANGE, BindTool.Bind(self.OnSkillChange, self))
	self:BindGlobalEvent(ObjectEventType.MAIN_ROLE_USE_SKILL, BindTool.Bind(self.OnMainRoleUseSkill, self))

	-- 首次刷新数据

	self.select_obj_group_list = {}
end

function GeneralSkillView:__delete()
	if self.change_area_type ~= nil then
		GlobalEventSystem:UnBind(self.change_area_type)
		self.change_area_type = nil
	end
	GlobalTimerQuest:CancelQuest(self.delete_area_tips_timer) 
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.menu_toggle_change ~= nil then
		GlobalEventSystem:UnBind(self.menu_toggle_change)
		self.menu_toggle_change = nil
	end
end

function GeneralSkillView:ConstructData()
	local seq = GeneralSkillData.Instance:GetCurUseSeq()
	if seq == -1 then
		return
	end
	for i, v in ipairs(self.skill_infos) do
		v.skill_id = FamousGeneralData.Instance:GetSkillIconBySeq(seq, i)
	end
end

function GeneralSkillView:OnRecvMainRoleInfo()
end

-- function GeneralSkillView:OnSkillChange(change_type, skill_id)
-- 	local skill_info = nil
-- 	local skill_cfg = nil
-- 	for i, v in ipairs(self.skill_infos) do
-- 		skill_info = ConfigManager.Instance:GetAutoConfig("roleskill_auto").normal_skill[v.skill_id]
-- 		v.is_exist = nil ~= skill_info

-- 		skill_cfg = SkillData.GetSkillinfoConfig(v.skill_id)
-- 		if nil ~= skill_cfg then			
-- 			v.skill_icon = skill_cfg.skill_icon
-- 		end

-- 		if skill_info and ("list" == change_type or nil == change_type) then
-- 			self:OnMainRoleUseSkill(v.skill_id)
-- 		end
-- 	end
-- end

function GeneralSkillView:OnMainRoleUseSkill(skill_id)
	for i, v in ipairs(self.skill_infos) do
		if v.skill_id == skill_id and self.skill_cd_progress[i] then
			if self.skill_count_down[skill_id] then
				
				return
			end
			self.skill_count_down[skill_id] = true
			local skill_info = SkillData.Instance:GetSkillInfoById(skill_id) or {}
			
			local cd = skill_info.cd_end_time and skill_info.cd_end_time - Status.NowTime or 0
			cd = cd > 0 and cd or 0

			self.skill_cd_progress[i]:SetValue(0)
			CountDown.Instance:RemoveCountDown(v.countdonw1)
			CountDown.Instance:RemoveCountDown(v.countdonw2)
			v.countdonw1 = CountDown.Instance:AddCountDown(
				cd, 0.05, function(elapse_time, total_time)
					if total_time <= 0 then
						self.skill_cd_progress[i]:SetValue(0)
					else
						local progress = (total_time - elapse_time) / total_time
						self.skill_cd_progress[i]:SetValue(progress)
					end					
				end)

			if self.skill_cd_time[i] then
				self.skill_cd_time[i]:SetValue(math.ceil(cd))
				v.countdonw2 = CountDown.Instance:AddCountDown(
					cd, 1.0, function(elapse_time, total_time)
						self.skill_cd_time[i]:SetValue(math.ceil(total_time - elapse_time))
						if total_time - elapse_time <= 0 then
							self.skill_count_down[skill_id] = false
						end
					end)
			end
			break
		end
	end
end

function GeneralSkillView:OnFlush()
	self:ConstructData()
	self:SetSkillIcon()
end

function GeneralSkillView:SetSkillIcon()
	local seq = GeneralSkillData.Instance:GetCurUseSeq()
	if seq == -1 then
		return
	end
	for k,v in ipairs(self.skill_icons) do
		-- 普通攻击技能
		local bundle, asset = "", ""
		if k == 1 then
			bundle, asset = ResPath.GetRoleChangeSkillIcon(self.skill_infos[k].skill_id .. "1")
		else
			bundle, asset = ResPath.GetRoleChangeSkillIcon(self.skill_infos[k].skill_id)
		end
		v:SetAsset(bundle, asset)
	end
end

local click_attack_down = nil
function GeneralSkillView:OnClickAttackDown(skill_info)
	click_attack_down = UnityEngine.Input.mousePosition
end

function GeneralSkillView:OnClickAttackUp(skill_info)
	if nil == click_attack_down then return end
	local off_y = click_attack_down.y - UnityEngine.Input.mousePosition.y
	if off_y > 1000 or off_y < -1000 then
		return
	elseif math.abs(off_y) < 20 then
		self:OnClickSkill(skill_info)
	else
		if off_y < 0 then
			MainUICtrl.Instance:OpenNearRole()
		else
			self:SelectObj(SceneObjType.Monster, SelectType.Enemy)
		end
	end
	click_attack_down = nil
end

function GeneralSkillView:SelectObj(obj_type, select_type)
	-- 获取所有可选对象
	local obj_list = Scene.Instance:GetObjListByType(obj_type)
	if not next(obj_list) then
		return
	end

	local temp_obj_list = {}
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local target_x, target_y = 0, 0

	local can_select = true
	for k, v in pairs(obj_list) do
		can_select = true
		if SelectType.Friend == select_type then
			can_select = Scene.Instance:IsFriend(v, self.main_role)
		elseif SelectType.Enemy == select_type then
			can_select = Scene.Instance:IsEnemy(v, self.main_role)
		elseif SelectType.Alive == select_type then
			can_select = not v:IsRealDead()
		end

		if can_select then
			target_x, target_y = v:GetLogicPos()
			table.insert(temp_obj_list, {obj = v, dis = GameMath.GetDistance(x, y, target_x, target_y, false)})
		end
	end
	if not next(temp_obj_list) then
		return
	end
	table.sort(temp_obj_list, function(a, b) return a.dis < b.dis end)

	-- 排除已选过的
	local select_obj_list = self.select_obj_group_list[obj_type]
	if nil == select_obj_list then
		select_obj_list = {}
		self.select_obj_group_list[obj_type] = select_obj_list
	end

	local select_obj = nil
	for i, v in ipairs(temp_obj_list) do
		if nil == select_obj_list[v.obj:GetObjId()] then
			select_obj = v.obj
			break
		end
	end

	-- 如果没有选中，选第一个，并清空已选列表
	if nil == select_obj then
		select_obj = temp_obj_list[1].obj
		select_obj_list = {}
		self.select_obj_group_list[obj_type] = select_obj_list
	end
	if nil == select_obj then
		return
	end
	select_obj_list[select_obj:GetObjId()] = select_obj

	GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, select_obj, "select")

	return select_obj
end

function GeneralSkillView:OnClickSkill(skill_info)
	if not Scene.Instance:GetMainRole():CanAttack() then
		
		return
	end

	if SkillData.Instance:IsSkillCD(skill_info.skill_id) and SkillData.IsNotNormalSkill(skill_info.skill_id) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.SkillCD)
	end
	if GuajiCtrl.Instance:IsInSafeTarget() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fight.Safe)
	end
	local target_obj = GuajiCtrl.Instance:SelectAtkTarget(true, {
			[SceneIgnoreStatus.MAIN_ROLE_IN_SAFE] = true,
		}, skill_info.skill_id == 70 or skill_info.skill_id == 71)

	if SkillData.IsBuffSkill(skill_info.skill_id) then
		target_obj = Scene.Instance:GetMainRole()
	end

	if nil == target_obj then
		
		return
	end
	GlobalEventSystem:Fire(MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE)
	GlobalEventSystem:Fire(MainUIEventType.CLICK_SKILL_BUTTON, skill_info.skill_id, target_obj)
	GuajiCtrl.Instance:DoFightByClick(skill_info.skill_id, target_obj)
end

function GeneralSkillView:GetSkillButtonPosition()
	return self.skill_icon_pos_list
end

function GeneralSkillView:FlushSkillName()

end