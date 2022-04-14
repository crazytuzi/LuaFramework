-- 
-- @Author: LaoY
-- @Date:   2018-07-19 15:16:28
-- 
EffectManager = EffectManager or class("EffectManager",BaseManager)
local EffectManager = EffectManager


EffectManager.BeHitEffectCount = 8

EffectManager.SceneEffectType = {
	Pos = 1,		--指定坐标点
	Target = 2,		--指定对象节点
	Shoot = 3,		--弹道特效
}
function EffectManager:ctor()
	EffectManager.Instance = self

	self.camera_effect_list = {}
	self:Reset()

	self.effect_callback_list = {}
	self.scene_effect_list = {}

	self.be_hit_effect_ref = Ref()

	LateUpdateBeat:Add(self.Update,self)

	self.model_effect_list = {}
	self.model_effect_count = 0

	self:AddEvent()
end

function EffectManager:dctor()

end

function EffectManager:AddModelEffect(effect)
	self.model_effect_list[effect] = true
	self.model_effect_count = self.model_effect_count + 1
end

function EffectManager:RemoveModelEffect(effect)
	-- Constant.AllEffectCount
	if self.model_effect_list[effect] then
		self.model_effect_count = self.model_effect_count - 1
		self.model_effect_count = self.model_effect_count < 0 and 0 or self.model_effect_count
		self.model_effect_list[effect] = nil

		if effect.model_effect_config.show_type == 3 and effect.is_show then
			self:UpdateModelCountEffect()
		end
	end
end

function EffectManager:IsCanShow(effect)
	if effect.is_ui or effect.ower_object.is_main_role then
		return true
	end
	if not effect.model_effect_config.show_type then
		if AppConfig.Debug then
			logError("没有配置模型特效的显示类型")
		end
		return false
	end

	local show_count = self:GetShowModelEffectCount()
	-- if show_count >= Constant.AllEffectCount then
	-- 	return false
	-- end
	if effect.model_effect_config.show_type == 1 then
		return true
	elseif effect.model_effect_config.show_type == 2 then
		return false
	else
		if show_count < Constant.AllEffectCount then
			return true
		end
		return self:IsHigherPriority(effect)
	end
	return false
end

function EffectManager:GetShowModelEffectCount()
	local count = 0
	for effect,v in pairs(self.model_effect_list) do
		if effect.is_show then
			count = count + 1 
		end
	end
	return count
end

function EffectManager:IsHigherPriority(effect)
	local list = self:GetLimitShowEffectList()
	local lower_effect = list[Constant.AllEffectCount]
	if not lower_effect then
		return true
	end
	if effect.model_effect_config.load_lv > lower_effect.model_effect_config.load_lv then
		effect:ClearEffect()
		return true
	end
	return false
end

function EffectManager:GetLimitShowEffectList()
	local list = {}
	for k,v in pairs(self.model_effect_list) do
		if k.model_effect_config.show_type == 3 then
			list[#list+1] = k
		end
	end	
	local function sortFunc(a,b)
		if a.model_effect_config.load_lv == b.model_effect_config.load_lv then
			return a.create_index < b.create_index
		else
			return a.model_effect_config.load_lv > b.model_effect_config.load_lv
		end
	end
	table.sort(list,sortFunc)
	return list
end

function EffectManager:UpdateModelCountEffect()
	local list = self:GetLimitShowEffectList()
	local show_count = self:GetShowModelEffectCount()
	local len = #list
	for i=1,len do
		local effect = list[i]

		if show_count >= Constant.AllEffectCount then
			if effect.is_show then
				show_count = show_count - 1
			end
			effect:ClearEffect()
		else
			if not effect.is_show and not self.is_loaded then
				effect.is_show = true
				show_count = show_count + 1
				if not effect.loading then
					effect:Load()
				end
			end
		end
	end
end

function EffectManager:Reset()
	self:DelCameraList()
end

function EffectManager:AddEvent()
	local function call_back()
		self:UpdateCameraList()
	end
	GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)
end

function EffectManager.GetInstance()
	if EffectManager.Instance == nil then
		EffectManager()
	end
	return EffectManager.Instance
end

function EffectManager:DelCameraList()
	for k,v in pairs(self.camera_effect_list) do
		v:destroy()
	end
	self.camera_effect_list = {}
end

function EffectManager:UpdateCameraList()
	self:DelCameraList()
	local cur_scene_id = SceneManager:GetInstance():GetSceneId()
	local cf = SceneConfigManager:GetInstance():GetSceneEffectList(cur_scene_id)
	if not cf then
		return
	end
	local tab = {}
	for k,v in pairs(cf) do
		if v.level == 4 then
			tab[k] = v
		end
	end
	local count = 0
	for k,v in table.pairsByKey(tab) do
		count = count + 1
		local config = {
	        pos = {x = v.x,y = v.y}, scale = 1, speed = 1, is_loop = true,
	    }
	    local parent = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.Scene)
	    local effect = SceneTargetEffect(parent, v.name, EffectManager.SceneEffectType.Target, self,LayerManager.BuiltinLayer.UI)
	    effect:SetConfig(config)
	    effect:SetOrderIndex(count)
		self.camera_effect_list[#self.camera_effect_list+1] = effect
	end
end

function EffectManager:AddBeHitEffectRef()
	self.be_hit_effect_ref:Retain()
end

function EffectManager:RemoveBeHitEffectRef()
	self.be_hit_effect_ref:Release()
end

function EffectManager:IsCanAddBeHitEffect()
	if self.be_hit_effect_ref:GetReferenceCount() >= EffectManager.BeHitEffectCount then
		return false
	end
	return true
end

--[[
	@author LaoY
	@des	场景特效 	 只播放一次
	@param1 effect_name	 特效名字
--]]
function EffectManager:PlayPositionEffect(effect_name,pos)
	local scene_obj_layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneObj)
	local effect = ScenePositionEffect(scene_obj_layer,effect_name,EffectManager.SceneEffectType.Pos)
	local config = {pos = pos}
	effect:SetConfig(config)
end

--[[
	@author LaoY
	@des	链接技能
--]]
function EffectManager:ReleaseLinkSkillEffect()
end

--[[
	@author LaoY
	@des	新加场景对象，挂在场景对象上的。删掉怪物要删除引用
	@param1 sceneobject		场景对象
	@param2 effect          特效实例
--]]
function EffectManager:AddSceneEffect(sceneobject,effect)
	self.scene_effect_list[sceneobject] = self.scene_effect_list[sceneobject] or {}
	self.scene_effect_list[sceneobject][effect] = effect
end

function EffectManager:RemoveSceneEffect(sceneobject,effect)
	if not self.scene_effect_list[sceneobject] then
		return
	end
	if effect then
		self.scene_effect_list[sceneobject][effect] = nil
	else
		self.scene_effect_list[sceneobject] = nil
	end
end

function EffectManager:GetTargetEffectList(sceneobject)
	return self.scene_effect_list[sceneobject]
end

function EffectManager:RemoveAllSceneEffect(sceneobject)
	if not self.scene_effect_list[sceneobject] then
		return
	end
	local effect_list = {}
	for effect,_ in pairs(self.scene_effect_list[sceneobject]) do
		effect_list[#effect_list+1] = effect
	end
	for k,effect in pairs(effect_list) do
		effect:destroy()
	end
end

function EffectManager:AddEffectCallBack(cls,callback)
	self.effect_callback_list[cls] = callback
end

function EffectManager:RemoveEffectCallBack(cls)
	self.effect_callback_list[cls] = nil
end

function EffectManager:IsCanShowOtherEffect()
	return not SettingModel:GetInstance().isHideOtherEffect
	or ArenaModel:GetInstance():IsArenaFight()
	or PeakArenaModel:GetInstance():Is1v1Fight()
	or StigmasModel:GetInstance():IsStigmasMap()
	or CompeteModel:GetInstance():IsCompeteDungeon()
	or SceneManager:GetInstance():GetSceneId() == 60011
end

function EffectManager:Update(deltaTime)
	local delete_tab = nil
	-- 特效结束相关
	for cls,callback in pairs(self.effect_callback_list) do
		if cls.is_dctored or IsNil(cls.gameObject) or (cls.is_loaded and not cls.is_loop and (cls.is_hide_clean or cls.gameObject.activeInHierarchy) and GetParticlePlayState(cls.gameObject)) then
			-- callback(cls)
			delete_tab = delete_tab or {}
			delete_tab[#delete_tab + 1] = cls
		end
	end

	if delete_tab then
		for k,cls in pairs(delete_tab) do
			-- self:RemoveEffectCallBack(cls)
			local callback = self.effect_callback_list[cls]
			if callback then
				callback(cls)
			end
		end
		delete_tab = nil
	end

	--技能特效不需要结束回调，用时间控制
	for sceneobject,effect_list in pairs(self.scene_effect_list) do
		for _,effect in pairs(effect_list) do
			if effect.is_dctored then
				delete_tab = delete_tab or {}
				delete_tab[#delete_tab + 1] = {sceneobject = sceneobject,effect = effect}
			elseif effect.is_loaded and effect.config then
				effect.pass_time = effect.pass_time + deltaTime
				if not effect:IsPlay() and effect.pass_time >= effect.config.start_time then
					effect:PlayEffect(true)
				end
				if not effect.is_loop and effect.play_time and effect.pass_time >= effect.config.start_time + effect.play_time then
					-- effect:PlayCallBack()
					delete_tab = delete_tab or {}
					delete_tab[#delete_tab + 1] = {sceneobject = sceneobject,effect = effect}
				end
			end
		end
	end
	if delete_tab then
		for k,info in pairs(delete_tab) do
			if info.effect and not info.effect.is_dctored then
				info.effect:PlayCallBack()
			end
			self:RemoveSceneEffect(info.sceneobject,info.effect)
		end
		delete_tab = nil
	end
end