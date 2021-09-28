SpiritHomeFightView = SpiritHomeFightView or BaseClass(BaseView)

function SpiritHomeFightView:__init()
	self.ui_config = {"uis/views/spiritview_prefab","SpirteHomeFight"}
	self.view_layer = UiLayer.Pop
	self.str = ""
	self.early_close_state = false

	self.my_fight = false
	self.enemy_fight = false
	self.spirit_list = {}
	self.current_text_count = 0
	self.max_text_count = 25
	self.text_t = {}
	self.my_attack_ok = false
	self.enemy_attack_ok = false
	self.fight_index = 1
	self.fight_list = {}
	self.fight_end_my = false
	self.fight_end_enemy = false
	self.is_fight_end = nil
	self.fighting = false
end

function SpiritHomeFightView:__delete()
end

function SpiritHomeFightView:ReleaseCallBack()
	self.fighting = false
	self.my_fight = false
	self.enemy_fight = false
	self.my_attack_ok = false
	self.enemy_attack_ok = false
	self.fight_end_my = false
	self.fight_end_enemy = false
	self.is_fight_end = nil
	self.fight_index = 1
	self.fight_list = {}
	self.save_fight_obj = nil

	if self.animator_handle_t_my ~= nil then
		self.animator_handle_t_my:Dispose()
		self.animator_handle_t_my = nil
	end

	if self.animator_handle_t_enemy ~= nil then
		self.animator_handle_t_enemy:Dispose()
		self.animator_handle_t_enemy = nil
	end

	if self.spirit_list["my"] ~= nil then
		if self.spirit_list["my"].tween ~= nil then
			self.spirit_list["my"].tween:Pause()
		end

		self.spirit_list["my"]:DeleteMe()
	end

	if self.spirit_list["enemy"] ~= nil then
		if self.spirit_list["enemy"].tween ~= nil then
			self.spirit_list["enemy"].tween:Pause()
		end

		self.spirit_list["enemy"]:DeleteMe()
	end

	if self.end_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.end_timer)
		self.end_timer = nil
	end

	if self.fight_action_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.fight_action_timer)
		self.fight_action_timer = nil
	end

	self:RemoveAll()

	self.spirit_list = {}
	self.fight_effect = nil

	self.my_obj = nil
	self.enemy_obj = nil
	self.my_head = nil
	self.enemy_head = nil
	self.my_hp = nil
	self.enemy_hp = nil
	self.my_name = nil
	self.enemy_name = nil
	self.my_hp_value = nil
	self.enemy_hp_value = nil
	self.my_head_res = nil
	self.enemy_head_res = nil
	self.my_text_pos = nil
	self.enemy_text_pos = nil
	self.can_click = nil
	self.btn_limlit = nil

	self.fight_eff_pos = nil
	self.fight_tip = nil
end

function SpiritHomeFightView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("JumpFight", BindTool.Bind(self.OnClickJumpFight, self))

	self.my_obj = self:FindObj("Fight1")
	self.enemy_obj = self:FindObj("Fight2")
	self.my_head = self:FindObj("MyHead")
	self.enemy_head = self:FindObj("EnemyHead")

	self.my_text_pos = self:FindObj("FightPos1").transform
	self.enemy_text_pos = self:FindObj("FightPos2").transform
	self.my_pos = self:FindObj("FightPos1").transform.localPosition
	self.enemy_pos = self:FindObj("FightPos2").transform.localPosition
	self.my_born = Vector3(self.my_obj.transform.localPosition.x, self.my_obj.transform.localPosition.y, self.my_obj.transform.localPosition.z)
	self.enemy_born = Vector3(self.enemy_obj.transform.localPosition.x, self.enemy_obj.transform.localPosition.y, self.enemy_obj.transform.localPosition.z)

	self.my_hp = self:FindObj("MySlider"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.enemy_hp = self:FindObj("EnemySlider"):GetComponent(typeof(UnityEngine.UI.Slider))

	self.my_name = self:FindVariable("MyName")
	self.enemy_name = self:FindVariable("EnemyName")
	self.my_hp_value = self:FindVariable("MyHp")
	self.enemy_hp_value = self:FindVariable("EnemyHp")
	self.my_head_res = self:FindVariable("MyHeadRes")
	self.enemy_head_res = self:FindVariable("EnemyHeadRes")
	self.can_click = self:FindVariable("CanClick")

	self.btn_limlit = self:FindVariable("BtnLimlit")

	self.fight_eff_pos = self:FindObj("FightEff")

	self.fight_tip = self:FindVariable("ShowFightTip")
end

function SpiritHomeFightView:OpenCallBack()
	self.save_fight_obj = nil
	self.my_fight = false
	self.enemy_fight = false
	self.my_attack_ok = false
	self.enemy_attack_ok = false
	self.fight_end_my = false
	self.fight_end_enemy = false
	self.is_fight_end = nil
	self.fight_index = 1
	self.fighting = true
	--self.fight_list = {}

	if self.fight_tip ~= nil then
		self.fight_tip:SetValue(self.fight_type ~= nil and SPIRIT_FIGHT_TYPE.EXPLORE == self.fight_type)
	end

	if self.can_click ~= nil then
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		local vip_level = main_vo.vip_level
		self.can_click:SetValue(vip_level < 1)
	end

	if self.btn_limlit ~= nil then
		self.btn_limlit:SetValue(Language.JingLing.SpiritHomeFightBtnLimlit)
	end

	if self.my_item ~= nil and self.enemy_item ~= nil then
		self:InitHead(self.my_item, "my")
		self:InitHead(self.enemy_item, "enemy")
	end
end

function SpiritHomeFightView:CloseCallBack()
	if self.animator_handle_t_my ~= nil then
		self.animator_handle_t_my:Dispose()
		self.animator_handle_t_my = nil
	end

	if self.animator_handle_t_enemy ~= nil then
		self.animator_handle_t_enemy:Dispose()
		self.animator_handle_t_enemy = nil
	end

	if self.spirit_list["my"] ~= nil then
		if self.spirit_list["my"].tween ~= nil then
			self.spirit_list["my"].tween:Pause()
		end
	end

	if self.spirit_list["enemy"] ~= nil then
		if self.spirit_list["enemy"].tween ~= nil then
			self.spirit_list["enemy"].tween:Pause()
		end
	end

	if self.end_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.end_timer)
		self.end_timer = nil
	end

	if self.fight_action_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.fight_action_timer)
		self.fight_action_timer = nil
	end

	if self.fight_effect ~= nil then
		GameObject.Destroy(self.fight_effect)
		self.fight_effect = nil
	end
	self:RemoveAll()

	self.fighting = false
end

function SpiritHomeFightView:RemoveAll()
	for k,v in pairs(self.text_t) do
		--GameObjectPool.Instance:Free(k)
		GameObject.Destroy(k)
	end
	self.text_t = {}
	self.current_text_count = 0
end

function SpiritHomeFightView:OnClickClose()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local vip_level = main_vo.vip_level
	if vip_level < 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritNoCanClose)
		return
	end
	self:FightEnd(true)
	self.save_fight_obj = nil
end

function SpiritHomeFightView:OnClickJumpFight()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local vip_level = main_vo.vip_level
	if vip_level < 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.VipLimitTips)
		return
	end
	self:FightEnd(true)
end

function SpiritHomeFightView:SetData(my_res, enemy_res, fight_type)
	self.my_item = my_res
	self.enemy_item = enemy_res
	self.fight_type = fight_type

	if self.fight_type ~= nil and SPIRIT_FIGHT_TYPE.EXPLORE == self.fight_type then
		self.fight_list = SpiritData.Instance:GetSpiritExpFightList()
		if self.fight_list == nil or next(self.fight_list) == nil then
			return
		end
	else
		self.fight_list = SpiritData.Instance:GetFightInfo()
		if self.fight_list == nil or next(self.fight_list) == nil then
			return
		end
	end

	self:Open()
end

function SpiritHomeFightView:InitModel(model_type, res_id)
	if self.spirit_list == nil then
		self.spirit_list = {}
	end

	if self.spirit_list[model_type] == nil then
		if self[model_type .. "_obj"] ~= nil then
			self.spirit_list[model_type] = RoleModel.New()
			self.spirit_list[model_type]:SetDisplay(self[model_type .. "_obj"].ui3d_display)
			local config_id = model_type == "my" and DISPLAY_PANEL.SPIRIT_HOME_FIGHT or DISPLAY_PANEL.SPIRIT_HOME_ENEMY
		-- 	self.spirit_list[model_type]:SetLoadComplete(function()
		-- 		--local root = self.spirit_list[model_type].display
  --              local rorate = model_type == "my" and -90 or 90
  --              if 10008001 == res_id then
  --              		if model_type == "my" then
  --              			rorate = 0
  --              		else
  --              			rorate = 180
  --              		end
  --              end
  --              self.spirit_list[model_type]:SetRotation(Vector3(0, rorate, 0))
		-- 	end)
		end
	end

	--if model_type == "enemy" then
		self.spirit_list[model_type]:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], res_id, DISPLAY_PANEL.SPIRIT_HOME_FIGHT)
	--end

	if self[model_type .. "_obj"] ~= nil and self[model_type .. "_born"] ~= nil then
		local pos = self[model_type .. "_born"]
		self[model_type .. "_obj"].transform.localPosition = pos
	end

   local rorate = model_type == "my" and -90 or 90
   if 10008001 == res_id then
   		if model_type == "my" then
   			rorate = 0
   		else
   			rorate = 180
   		end
   end

   self.spirit_list[model_type]:SetRotation(Vector3(0, rorate, 0))

	self.spirit_list[model_type]:SetMainAsset(ResPath.GetSpiritModel(res_id))
end

function SpiritHomeFightView:InitHead(item_id, model_type)
	if item_id == nil or model_type == nil then
		return
	end

	local cfg = ItemData.Instance:GetItemConfig(item_id)
	if cfg == nil then
		return
	end

	local name = cfg.name
	local cur_hp = 10000
	local max_hp = 10000
	local per_value = 1
	if self.fight_type ~= nil and self.fight_type == SPIRIT_FIGHT_TYPE.EXPLORE then
		cur_hp, max_hp = SpiritData.Instance:GetStageHPStr(model_type, true)
		if model_type == "enemy" then
			name = SpiritData.Instance:GetExpSpiritName(cfg.name)
		end
		per_value = cur_hp / max_hp
	else
		cur_hp = SpiritData.Instance:GetHomeFightMaxHp(model_type)
		max_hp = cur_hp
	end

	if self[model_type .. "_hp"] ~= nil then
		self[model_type .. "_hp"].value = per_value
	end

	if self[model_type .. "_name"] ~= nil then
		self[model_type .. "_name"]:SetValue(name)
	end

	if self[model_type .. "_hp_value"] ~= nil then
		self[model_type .. "_hp_value"]:SetValue(cur_hp .. "/" .. max_hp)
	end

	if self[model_type .. "_head_res"] ~= nil then
		local bundle, asset = ResPath.GetItemIcon(item_id)
		self[model_type .. "_head_res"]:SetAsset(bundle, asset)
	end

	local model_res = SpiritData.Instance:GetSpiritResIdByItemId(item_id)

	if model_res ~= nil and model_res.res_id ~= nil then
		self:InitModel(model_type, model_res.res_id)
	end

	self:StartFight(model_type)
end

function SpiritHomeFightView:StartFight(model_type)
	if self.spirit_list[model_type] ~= nil then
		if self[model_type .. "_pos"] ~= nil then
			local pos = self[model_type .. "_pos"]
			if self[model_type .. "_obj"] ~= nil then
				self.spirit_list[model_type]:SetInteger(ANIMATOR_PARAM.STATUS, 1)
				local tween = self[model_type .. "_obj"].transform:DOLocalMove(pos, 1)
				tween:SetEase(DG.Tweening.Ease.Linear)
				tween:OnComplete(function()
					self.spirit_list[model_type]:SetInteger(ANIMATOR_PARAM.STATUS, 0)
					self[model_type .. "_fight"] = true
					self:CheckBeginFight()
				end)
				self[model_type .. "_obj"].tween = tween
			end
		end
	end
end

function SpiritHomeFightView:CheckBeginFight()
	if not self.my_fight or not self.enemy_fight then
		return
	end

	self:EnterStateAttack("my")
	self:EnterStateAttack("enemy")
	local fight_obj = "my"
	if self.fight_type ~= nil and SPIRIT_FIGHT_TYPE.EXPLORE == self.fight_type then
		local result = SpiritData.Instance:GetExploreResult()
		if result == "my" then
			fight_obj = "enemy"
		end
	else
		local result = SpiritData.Instance:GetFightResult()
		if result == "my" then
			fight_obj = "enemy"
		end
	end
	self:DoFight(fight_obj)
	-- self:DoFight("enemy")
end

function SpiritHomeFightView:DoFight(attacker, target)
	if self.spirit_list[attacker] ~= nil then
		self.spirit_list[attacker]:SetTrigger("attack1")

		if self.fight_action_timer ~= nil then
			GlobalTimerQuest:CancelQuest(self.fight_action_timer)
		end

		local read_target = attacker == "my" and "enemy" or "my"
		self.fight_action_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.FightAction, self, read_target), 0.5)
	end
end

function SpiritHomeFightView:EnterStateAttack(model_type)
	if self.spirit_list[model_type] == nil then
		return
	end

	local model = self.spirit_list[model_type]
	local part = model.draw_obj:GetPart(SceneObjPart.Main)
	local part_obj = part:GetObj()
	if part_obj == nil or IsNil(part_obj.gameObject) then
		return
	end

	local anim_name = "attack1"
	local animator = part_obj.animator

	if nil == self["animator_handle_t_" .. model_type] then
		local target = model_type == "my" and "enemy" or "my"
		self["animator_handle_t_" .. model_type] = animator:ListenEvent(anim_name.."/end", BindTool.Bind3(self.OnAnimatorEnd, self, target))
	end
end

function SpiritHomeFightView:FightAction(target)
	if self.spirit_list[target] ~= nil then
		local obj_main = self.spirit_list[target].draw_obj:GetPart(SceneObjPart.Main)
		local deliverer_obj = obj_main:GetObj()
		local attacker_obj = deliverer_obj.actor_ctrl
		attacker_obj:Blink()

		-- self:ShowEffect(target)

		local data = nil
		--if self.fight_type ~= nil and SPIRIT_FIGHT_TYPE.EXPLORE == self.fight_type then
			if self.fight_list[self.fight_index] == nil then
				self:Close()
				return
			end

			data = self.fight_list[self.fight_index][target]
			if self.fight_index > # self.fight_list then
				self:Close()
				return
			end
		--else
			--data = SpiritData.Instance:GetFightInfo(target)
		--end

		if data == nil then
			self:Close()
			return
		end

		local floating_point = self.spirit_list[target].draw_obj:GetAttachPoint(AttachPoint.BuffBottom)
		if FIGHT_TYPE.BAOJI == data.fighttype then
			self:ShowCritical(
				data.blood, data.pos, floating_point, target)
		else
			self:ShowBeHurt(
				data.blood, data.pos, floating_point, target)
		end

		-- if not self:IsOpen() then
		-- 	if self.fight_effect ~= nil then
		-- 		GameObject.Destroy(self.fight_effect)
		-- 		self.fight_effect = nil
		-- 	end
		-- 	self:RemoveAll()
		-- end
	end
end

function SpiritHomeFightView:OnAnimatorEnd(target)
	if self.spirit_list[target] ~= nil and self[target .. "_hp"] then
		local data = nil
		--if self.fight_type ~= nil and SPIRIT_FIGHT_TYPE.EXPLORE == self.fight_type then
			if self.fight_list[self.fight_index] == nil then
				self:Close()
				return
			end

			data = self.fight_list[self.fight_index][target]
			if self.fight_index > # self.fight_list then
				self:Close()
				return
			end
		--else
			--data = SpiritData.Instance:GetFightInfo(target)
		--end

		if data == nil then
			self:Close()
			return
		end

		-- local floating_point = self.spirit_list[target].draw_obj:GetAttachPoint(AttachPoint.BuffBottom)
		-- if FIGHT_TYPE.BAOJI == data.fighttype then
		-- 	self:ShowCritical(
		-- 		data.blood, data.pos, floating_point, target)
		-- else
		-- 	self:ShowBeHurt(
		-- 		data.blood, data.pos, floating_point, target)
		-- end

		-- if self.spirit_list[target] ~= nil then
		-- 	local obj_main = self.spirit_list[target].draw_obj:GetPart(SceneObjPart.Main)
		-- 	local deliverer_obj = obj_main:GetObj()
		-- 	local attacker_obj = deliverer_obj.actor_ctrl
		-- 	attacker_obj:Blink()

		-- 	self:ShowEffect(target)
		-- end

		local now_hp = self[target .. "_hp"].value
		local value_str = 10000
		local real_hp = 0
		if self.fight_type ~= nil and self.fight_type == SPIRIT_FIGHT_TYPE.EXPLORE then
			value_str = SpiritData.Instance:GetExpMaxHp(target)
			real_hp = now_hp - (data.blood / value_str)
			if data.cur_hp <= 0 then
				real_hp = 0
			end
			real_hp = real_hp <= 0 and 0 or real_hp
			self[target .. "_hp"]:DOValue(real_hp, 0.8, false)
			if self[target .. "_hp_value"] ~= nil then
				local cur_value = data.cur_hp <= 0 and 0 or data.cur_hp
				self[target .. "_hp_value"]:SetValue(math.floor(cur_value) .. "/" .. value_str)
			end
		else
			value_str = SpiritData.Instance:GetHomeFightMaxHp(target)
			real_hp = now_hp - (data.blood / value_str)
			real_hp = real_hp <= 0 and 0 or real_hp
			self[target .. "_hp"]:DOValue(real_hp, 0.8, false)
			if self[target .. "_hp_value"] ~= nil then
				self[target .. "_hp_value"]:SetValue(math.floor(real_hp * value_str) .. "/" .. value_str)
			end
		end

		-- if self[target .. "_hp_value"] ~= nil then
		-- 	if self.fight_type ~= nil and self.fight_type == SPIRIT_FIGHT_TYPE.EXPLORE then
		-- 		self[target .. "_hp_value"]:SetValue(math.floor(real_hp * value_str) .. "/" .. value_str)
		-- 	else
		-- 		self[target .. "_hp_value"]:SetValue(math.floor(real_hp * 10000) .. "/10000")
		-- 	end
		-- end

		if real_hp <= 0 then
			self.is_fight_end = target
		end

		self[target .. "_attack_ok"] = true
		--if self.my_attack_ok and self.enemy_attack_ok then
			if self.is_fight_end ~= nil then
				local result = self.is_fight_end
				self.is_fight_end = nil
				self:FightEnd(result)
				return
			end

			--self.my_attack_ok = false
			--self.enemy_attack_ok = false
			-- self:[target .. "_attack_ok"] = true
			if self.my_attack_ok and self.enemy_attack_ok then
				self.fight_index = self.fight_index + 1
				self.my_attack_ok = false
				self.enemy_attack_ok = false
			end
			-- self:DoFight("my")
			-- self:DoFight("enemy")
			if target == "my" then
				self:DoFight("my")
			else
				self:DoFight("enemy")
			end
		--end
	end
end

function SpiritHomeFightView:FightEnd(jump)
	if self.spirit_list["my"] ~= nil then
		self.spirit_list["my"]:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	end

	if self.spirit_list["enemy"] ~= nil then
		self.spirit_list["enemy"]:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	end

	if self.animator_handle_t_my ~= nil then
		self.animator_handle_t_my:Dispose()
		self.animator_handle_t_my = nil
	end

	if self.animator_handle_t_enemy ~= nil then
		self.animator_handle_t_enemy:Dispose()
		self.animator_handle_t_enemy = nil
	end

	self.fighting = false

	local is_exp = false
	if self.fight_type ~= nil and self.fight_type == SPIRIT_FIGHT_TYPE.EXPLORE then
		is_exp = true
	end

	local result = SpiritData.Instance:GetFightResult()
	if is_exp then
		result = SpiritData.Instance:GetExploreResult()
	end

	function end_call()
		if "my" == result then
			if is_exp then
				SpiritCtrl.Instance:OpenSpiritExploreVictory()
				SpiritData.Instance:SetExpFightCfg(nil)
			else
				SpiritCtrl.Instance:OpenHarvertVictory()
			end
		else
			if is_exp then
				SpiritCtrl.Instance:OpenSpiritExploreLose()
				SpiritData.Instance:SetExpFightCfg(nil)
			else
				SpiritCtrl.Instance:OpenHarvertLose()
			end
		end

		self:Close()
	end

	if is_exp then
		local delay_time = 0.5
		if "my" == result then
			local value_str = SpiritData.Instance:GetExpMaxHp(result)
			local data = self.fight_list[self.fight_index][result]
			delay_time = jump and 0.5 or 3
			local all_data = SpiritData.Instance:GetSpiritExploreInfo()
			local real_hp = (all_data.explore_hp) / value_str
			self[result .. "_hp"]:DOValue(real_hp, 1.5, false)

			if self[result .. "_hp_value"] ~= nil then
				self[result .. "_hp_value"]:SetValue(math.floor(all_data.explore_hp) .. "/" .. value_str)
			end
		end
		self.end_timer = GlobalTimerQuest:AddDelayTimer(end_call, delay_time)
	else
		end_call()
	end
end

function SpiritHomeFightView:ShowBeHurt(text, pos, attach_point, target)
	local add_str = pos.is_top and "1" or ""
	local is_left = target == "enemy"
	if is_left then
		self:ShowText("uis/views/floatingtext_prefab", "BeHurtLeft" .. add_str, text, attach_point, target)
	else
		self:ShowText("uis/views/floatingtext_prefab", "BeHurtRight" .. add_str, text, attach_point, target)
	end
end

function SpiritHomeFightView:ShowCritical(text, pos, attach_point, target)
	local add_str = pos.is_top and "1" or ""
	local is_left = target == "enemy"
	if is_left then
		self:ShowText("uis/views/floatingtext_prefab", "CriticalLeft" .. add_str, Language.Common.PassvieSkillAttr.bao_ji .. text, attach_point, target)
	else
		self:ShowText("uis/views/floatingtext_prefab", "CriticalRight" .. add_str, Language.Common.PassvieSkillAttr.bao_ji .. text, attach_point, target)
	end
end

function SpiritHomeFightView:ShowText(bundle, asset, text, attach_point, target)
	if self.current_text_count > self.max_text_count then
		return
	end

	self.current_text_count = self.current_text_count + 1
	local attach_position = attach_point.position
	GameObjectPool.Instance:SpawnAsset(bundle, asset, function(obj)
		if not obj then
			return
		end

		if nil == MainCamera then
			GameObjectPool.Instance:Free(obj)
			return
		end

		local text_obj = obj.transform:Find("Text")
		local text_component = text_obj:GetComponent(typeof(UnityEngine.UI.Text))
		text_component.text = text

		local animator = obj:GetComponent(typeof(UnityEngine.Animator))
		animator:WaitEvent("exit", function(param)
			if self.text_t[obj] then
				self.text_t[obj] = nil
				GameObjectPool.Instance:Free(obj)
				self.current_text_count = math.max(self.current_text_count - 1, 0)
			end
		end)

		obj.transform:SetParent(self[target .. "_text_pos"], false)
		self.text_t[obj] = true

		if not self:IsOpen() then
			if self.text_t[obj] then
				self.text_t[obj] = nil
				GameObjectPool.Instance:Free(obj)
				self.current_text_count = math.max(self.current_text_count - 1, 0)
			end
		end
	end)
end

function SpiritHomeFightView:SetRendering(value)
	BaseView.SetRendering(self, value)

	if self:IsOpen() and self.fighting then
		if not value and self.save_fight_obj == nil then
			self:SaveFightInfo()
		elseif value and self.save_fight_obj then
			self:Flush("continue_fight")
		end
	end
end

function SpiritHomeFightView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if "continue_fight" == k then
			if self.save_fight_obj ~= nil then
				local fight_obj = self.save_fight_obj
				self.save_fight_obj = nil
				self:DoFight(fight_obj)
			end
		end
	end
end

function SpiritHomeFightView:SaveFightInfo()
	self.save_fight_obj = nil

	if self.my_attack_ok and not self.enemy_attack_ok then
		self.save_fight_obj = "my"
	elseif self.enemy_attack_ok and not self.my_attack_ok then
		self.save_fight_obj = "enemy"
	else

		self.save_fight_obj = "my"
		if self.fight_type ~= nil and SPIRIT_FIGHT_TYPE.EXPLORE == self.fight_type then
			local result = SpiritData.Instance:GetExploreResult()
			if result == "my" then
				self.save_fight_obj = "enemy"
			end
		else
			local result = SpiritData.Instance:GetFightResult()
			if result == "my" then
				self.save_fight_obj = "enemy"
			end
		end
	end
end

function SpiritHomeFightView:ShowEffect(model_type)
	if self.spirit_list ~= nil and self.spirit_list[model_type] ~= nil then
		local move_point = self.spirit_list[model_type].draw_obj
		local point = move_point:GetAttachPoint(AttachPoint.BuffMiddle)
		-- if self.fight_eff == nil then
		-- 	self.fight_eff = AsyncLoader.New(point)
		-- 	self.fight_eff:Load(ResPath.GetEffect("baodian_jinse"))
		-- else
		-- 	self.fight_eff:SetActive(true)
		-- end
		--EffectManager.Instance:PlayAtTransform("effects/prefabs", "baodian_jinse", self.my_text_pos, 1.0, self.my_text_pos.position, nil, Vector3(25, 25, 25))
		local pos = Vector3(0, 0, 0)
		if model_type == "my" then
			pos = Vector3(self.my_text_pos.position.x, self.my_text_pos.position.y - 20, self.my_text_pos.position.z)
			--pos = self.my_text_pos.position
		else
			--pos = self.enemy_text_pos.position
			pos = Vector3(self.enemy_text_pos.position.x, self.enemy_text_pos.position.y - 20, self.enemy_text_pos.position.z)
		end

		--pos = Vector3(pos.x, pos.y - 20, pos.z)
		if self.fight_effect == nil then
		  	PrefabPool.Instance:Load(AssetID("effects/prefabs", "UI_baodian_jinse"), function (prefab)
				if not prefab or self.fight_effect then return end

				-- if self.is_is_destroy_effect_loading then
				-- 	self.is_loading = false
				-- 	self.is_is_destroy_effect_loading = false
				-- 	return
				-- end
				local obj = GameObject.Instantiate(prefab)
				PrefabPool.Instance:Free(prefab)
				local transform = obj.transform
				transform.localScale = Vector3(0.7, 0.7, 0.7)
				transform:SetParent(self.fight_eff_pos.transform, false)
				transform.position = pos
				self.fight_effect = obj
				self.fight_effect.gameObject:SetLayerRecursively(self.fight_eff_pos.gameObject.layer)
				self.fight_effect.gameObject:SetActive(true)

				if not self:IsOpen() then
					if self.fight_effect ~= nil then
						GameObject.Destroy(self.fight_effect)
						self.fight_effect = nil
					end
				end
			end)
		else
			self.fight_effect.transform.position = pos
			self.fight_effect.gameObject:SetActive(false)
			self.fight_effect.gameObject:SetActive(true)
		end
	end
end