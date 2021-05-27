Decoration = Decoration or BaseClass(SceneObj)

function Decoration:__init(vo)
	self.obj_type = SceneObjType.Decoration
	self:SetObjId(vo.obj_id)
	self.vo = vo

	self.res_id = 1
end

function Decoration:__delete()

end

function Decoration:GetVo()
	return self.vo
end

function Decoration:LoadInfoFromVo()
	self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)

	local decoration_config = Config.decoration[self.vo.decoration_id]
	if nil == decoration_config then
		Log("decoration_config not find, decoration_id:" .. self.vo.decoration_id)
		return
	end

	self.res_id = tonumber(decoration_config.id)
	if nil == self.res_id then
		self.res_id = 1
		Log("decoration_config resid == nil decoration_id:" .. self.vo.decoration_id)
	end

	self.name = decoration_config.name

	local scale = tonumber(decoration_config.scale)
	if nil ~= scale then
		self.model:SetScale(scale)
	end
end

function Decoration:InitAnimation()
	if self:IsParticleSystem(self.res_id) then
		local ps_path = ResPath.GetParticleSystemPath(self.res_id)
		local ps_node = ParticleSystemCommon:create(ps_path)
		if nil == ps_node then
			Log("Decoration:LoadInfoFromVo ps not find. res_id:" .. self.res_id)
			return
		end

		self.model:AttachNode(ps_node, cc.p(0, 0), GRQ_SCENE_OBJ, 0)
	else
		local decoration_config = Config.decoration[self.vo.decoration_id]
		local anim_path = nil
		local anim_name = nil

		if nil ~= decoration_config and decoration_config.effect_id ~= nil and decoration_config.effect_id ~= 0 then
			anim_path, anim_name = ResPath.GetEffectAnimPath(decoration_config.effect_id)
		else
			anim_path, anim_name = ResPath.GetDecorationAnimPath(self.res_id)
		end
		
		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Main, anim_path, anim_name, false, FrameTime.Decoration)
	end
end

function Decoration:IsParticleSystem(res_id)
	return res_id > 10000	-- 大于10000表示用的是粒子特效
end

function Decoration:CanClick()
	return false
end
