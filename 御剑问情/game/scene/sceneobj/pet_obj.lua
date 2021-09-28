PetObj = PetObj or BaseClass(FollowObj)

-- 小宠物
function PetObj:__init(pet_vo)
	self.obj_type = SceneObjType.PetObj
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(pet_vo.pet_id)

	self.vo = pet_vo
	self.is_pet = true
	self.follow_offset = -1
	self.is_wander = true
	self.mass = 0.5
	self.wander_cd = 10
	self.is_visible = true
	self.bubble_cfg = {}
	self.other_cfg = {}
end

function PetObj:__delete()
	self.obj_type = nil
	self.load_call_back = nil

	self:CancelBobbleTimerQuest()
	self:DestroyPetDisappearedEffect()
	self:CancelReleaseQuest()
	self:RemovePetDisappearedDelay()
end

function PetObj:SetAttr(key, value)
	Character.SetAttr(self, key, value)
end

function PetObj:InitShow()
	if nil == self.vo.pet_id or 0 == self.vo.pet_id then return end

	FollowObj.InitShow(self)
	self:GetRelatedCfg()
	self:ShowFirstBubble()

	local pet_cfg = LittlePetData.Instance:GetSinglePetCfgByPetId(self.vo.pet_id)
	if pet_cfg and pet_cfg.using_img_id and pet_cfg.using_img_id > 0 then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetLittlePetModel(pet_cfg.using_img_id))
		self:ShowFollowUi()
		local pet_name = pet_cfg.name
		self:GetFollowUi():SetName(pet_name)
		self.follow_ui:SetHpVisiable(false)
	end

	if nil == self.draw_obj or self.draw_obj:IsDeleted() then return end

	local complete_func = function(part, obj)
		self:PlayAppearEffect()
	end
	self.draw_obj:SetLoadComplete(complete_func)
end

function PetObj:PlayAppearEffect(time)
	local delay_time = time or 1
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil == main_part or nil == main_part:GetObj() or not self:IsMyPet() then return end

	local pet_obj = main_part:GetObj()
	self.pet_appear_effect = AsyncLoader.New(pet_obj.transform)
	self.pet_appear_effect:Load("effects2/prefab/misc/xianchongchuchang_prefab", "xianchongchuchang")
	self:RemovePetDisappearedDelay()
	self.pet_delay_time = GlobalTimerQuest:AddDelayTimer(function()
		self:DestroyPetDisappearedEffect()
		self:RemovePetDisappearedDelay()
	end, delay_time)
end

-- 带渐变效果移除小宠物
function PetObj:RemovePetWithFade(delete_call_back)
	if not self:IsMyPet() then
		delete_call_back()
		return
	end

	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil == main_part or nil == main_part:GetObj() then return end

	local pet_obj = main_part:GetObj()
	local fade_time = 0.5
	self:PlayPetFade(0, fade_time, delete_call_back)
	if pet_obj and pet_obj.gameObject then
		self:DoPetRun(pet_obj.gameObject, fade_time, 3)
		self:PlayAppearEffect(3)
	end
end

-- 小宠物渐变
function PetObj:PlayPetFade(fade_type, fade_time, call_back)
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	if nil == main_part then return end

	local pet_obj = main_part:GetObj()
	if pet_obj == nil then
		call_back()
		return
	end
	
	local fadeout = pet_obj.actor_fadout
	if fadeout ~= nil then
		if fade_type == 0 then
			fadeout:Fadeout(fade_time, call_back)
		elseif fade_type == 1 then
			fadeout:Fadein(fade_time, call_back)
		end
	else
		call_back()
	end
end

-- 小宠物位移
function PetObj:DoPetRun(obj, time, distance)
	if obj and obj.transform then
		local anim = obj:GetComponent(typeof(UnityEngine.Animator))
		if anim == nil then
			return
		end
		local target_pos = obj.transform.position + obj.transform.forward * distance
		if not self.game_root then
			self.game_root = GameObject.Find("GameRoot/SceneObjLayer")
		end
		if self.game_root then
			obj.transform:SetParent(self.game_root.transform, true)
		end
		anim:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		local tween = obj.transform:DOMove(target_pos, time)
		tween:SetEase(DG.Tweening.Ease.Linear)
	end
end

-- 移除特效
function PetObj:DestroyPetDisappearedEffect()
	if self.pet_appear_effect ~= nil then
		self.pet_appear_effect:Destroy()
		self.pet_appear_effect:DeleteMe()
		self.pet_appear_effect = nil
	end
end

-- 清除特效延迟
function PetObj:RemovePetDisappearedDelay()
	if self.pet_delay_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.pet_delay_time)
		self.pet_delay_time = nil
	end
end

function PetObj:UpdatePetId(pet_id)
	self.vo.pet_id = pet_id or self.vo.pet_id
end

function PetObj:SetPetName(pet_name)
	local pet_cfg = LittlePetData.Instance:GetSinglePetCfgByPetId(self.vo.pet_id)

	if pet_cfg and  pet_cfg.using_img_id and pet_cfg.using_img_id > 0 then
		pet_name = pet_name ~= "" and pet_name or pet_cfg.name
		self:GetFollowUi():SetName(pet_name)
		self.follow_ui:SetHpVisiable(false)
	end
end

function PetObj:SetLoadCallBack(call_back)
	self.load_call_back = call_back
end

function PetObj:LoadOver()
	if self.load_call_back then
		self.load_call_back()
	end
end

function PetObj:IsCharacter()
	return false
end

function PetObj:GetOwerRoleId()
	return self.vo.owner_role_id
end

function PetObj:MoveEnd()
	if nil == self.distance then
		return false
	end
	return self.distance <= 6
end

function PetObj:Ispet()
	return true
end

function PetObj:SetPetVisible(is_visible)
	self.is_visible = is_visible
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		draw_obj:SetVisible(is_visible)
		if is_visible then
			self:GetFollowUi():Show()
		else
			self:GetFollowUi():Hide()
		end
	end
end

function PetObj:GetRelatedCfg()
	local bubble_cfg = ConfigManager.Instance:GetAutoConfig("bubble_list_auto")
	self.bubble_cfg = bubble_cfg and bubble_cfg.bubble_pet_list or {}
	self.other_cfg = bubble_cfg and bubble_cfg.other[1] or {}
end

function PetObj:GetRandBubbletext()
	local text = ""
	local temp_list = {}
	for k,v in pairs(self.bubble_cfg) do
		if v.pet_id == self.vo.pet_id then
			table.insert(temp_list,v)
		end
	end

	if #temp_list > 0 then
		math.randomseed(os.time())
		local bubble_text_index = math.random(1, #temp_list)
		text = temp_list[bubble_text_index] and temp_list[bubble_text_index].bubble_pet_text
	end

	return text
end

function PetObj:GetFirstBubbleText()
	local text = ""

	for k,v in pairs(self.bubble_cfg) do
		if v.pet_id == self.vo.pet_id then
			text = v.bubble_pet_text
			break
		end
	end

	return text
end

function PetObj:ShowFirstBubble()
	if nil == self.release_timer then
		local delay_time = self.other_cfg.pet_bubble_appear or 0

		self.release_timer = GlobalTimerQuest:AddDelayTimer(function()
			self:CancelReleaseQuest()
			if nil ~= self.follow_ui and self:IsMyPet() then
				local text = self:GetFirstBubbleText()
				if text ~= "" then
					self.follow_ui:ChangeBubble(text)
				end
			end
			self.interval_timer = self.other_cfg.pet_interval or 0
			self:UpdataTimer()

		end, delay_time)
	end
end

function PetObj:CancelReleaseQuest()
	if self.release_timer then
		GlobalTimerQuest:CancelQuest(self.release_timer)
		self.release_timer = nil
	end
end

function PetObj:UpdataBubble()
	if nil ~= self.follow_ui then
		local text = self:GetRandBubbletext()
		self.follow_ui:ChangeBubble(text)
	end
end

function PetObj:UpdataTimer()
	local exist_time = self.other_cfg.exist_time or 0
	local pet_interval = self.other_cfg.pet_interval or 0
	
	if self.interval_timer and nil ~= self.follow_ui and self:IsMyPet() then
		if self.interval_timer >= pet_interval then
			self.interval_timer = self.interval_timer - pet_interval
			self:UpdataBubble()
			self.follow_ui:ShowBubble()
		else
			self.follow_ui:HideBubble()
		end
	end
	self.interval_timer = self.interval_timer and (self.interval_timer + exist_time) or exist_time

	self.bobble_timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:UpdataTimer() end, exist_time)
end

function PetObj:CancelBobbleTimerQuest()
	if self.bobble_timer_quest then
		GlobalTimerQuest:CancelQuest(self.bobble_timer_quest)
		self.bobble_timer_quest = nil
	end
end

function PetObj:IsMyPet()
	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if nil ~= obj and obj:IsRole() and role_id == self.vo.owner_role_id then
		return true
	end

	return false
end