--
-- @Author: LaoY
-- @Date:   2019-03-13 22:10:36
-- 
Buff = Buff or class("Buff")

function Buff:ctor(object_id,p_buff)
	if not p_buff then
		return
	end
	self.object_id = object_id
	self.id = p_buff.id
	self.effect = nil
	self.cf = Config.db_buff[self.id]
	self.is_show_img = false
	self.add_time = Time.time
	self.global_event_list = {}

	self:UpdateBuff(p_buff)
	self:Init()
	self:AddEvent()
end

function Buff:dctor()
	if self.effect then
		self.effect:destroy()
		self.effect = nil
	end

	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end
end

function Buff:AddEvent()
	local function call_back(object)
		if object == SceneManager:GetInstance():GetObject(self.object_id) then
			self:Init()
		end
	end
	-- self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.NewSceneObject, call_back)
end

function Buff:UpdateBuff(p_buff)
	self.p_buff = p_buff
	self:Init()
end

function Buff:Init()
	if self:IsShowEffectType() and not self.effect then
		self:ShowEffect()
	end
end

function Buff:IsEnd()
	if not self.p_buff then
		return true
	end
	if not self.p_buff.etime or self.p_buff.etime == 0 then
		return false
	end
	-- return os.time() > self.p_buff.etime + 10
	return os.time() > self.p_buff.etime
end

function Buff:IsShowImageType()
	if not self.cf then
		return false
	end
	return self.cf.exterior_type == BuffManager.ExteriorType.Image or
	self.cf.exterior_type == BuffManager.ExteriorType.ImageAndEffect
end

function Buff:IsShowEffectType()
	if not self.cf then
		return false
	end
	return self.cf.exterior_type == BuffManager.ExteriorType.Effect or
	self.cf.exterior_type == BuffManager.ExteriorType.ImageAndEffect
end

function Buff:IsShowImg()
	if self.is_dctored then
		return false
	end
	return self.is_show_img
end

function Buff:ShowImage()
	self:SetImageState(true)
	local object = SceneManager:GetInstance():GetObject(self.object_id)
	if object then
		local res = self.cf.exterior_img
		if res == "" then
			res = "buff_" .. self.cf.id
		end
		local abName = "iconasset/icon_headtop"
		if AppConfig.Debug then
			Yzprint('--LaoY Buff.lua,line 100--',self.cf.id,abName,res)
		end
		object:SetBuffImage(abName,res)
	end
end

function Buff:SetImageState(state)
	self.is_show_img = state
end

function Buff:ShowEffect()
	local object = SceneManager:GetInstance():GetObject(self.object_id)
	if object and object.is_loaded then
		local effect_cf = Config.db_effect[self.cf.exterior_effect]
		-- local effect_cf = Config.db_effect[10103]
		if effect_cf then
			if effect_cf.aim == 2 then
				local pet = object:GetDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_PET)
				object = pet
			end
			if not object then
				return
			end
			local parent
			local bone_name = SceneConstant.EffectBoneNode[self.cf.root_type]
			if bone_name then
				parent = object:GetBoneNode(bone_name) or object.transform
			end
			if tostring(self.object_id) == "2000001" then
				Yzprint('--LaoY Buff.lua,line 125--',object.object_info.name,object.object_id)
			end
			local pos = nil
			if object.config and  object.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_CGW_CRYSTAL then
				pos = {x = 0,y = -1 ,z = 0}
			end
			self.effect = object:SetTargetEffect(effect_cf.name,true,parent,pos)
		end
	end
end