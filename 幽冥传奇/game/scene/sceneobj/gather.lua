
Gather = Gather or BaseClass(SceneObj)

function Gather:__init(item_vo)
	self.obj_type = SceneObjType.GatherObj
	self:SetObjId(item_vo.obj_id)
	self.vo = item_vo

	self.scale = 1
	self.width_half = 0
	self.res_id = 1
	self.is_gather_visual = 0
end

function Gather:__delete()
	
end

function Gather:GetVo()
	return self.vo
end

function Gather:LoadInfoFromVo()
	self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)
	
	local gather_config = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[self.vo.gather_id]
	if nil == gather_config then
		Log("gather_config not find, gather_id:" .. self.vo.gather_id)
		return
	end

	self.vo.name = gather_config.show_name
	if GuildData.Instance:IsGatherBonfire(self.vo.gather_id) then
		self.name = "【" .. self.vo.param2 .. "】·" .. gather_config.show_name
	else
		self.name = gather_config.show_name
	end

	self.res_id = tonumber(gather_config.resid)
	if nil == self.res_id then
		self.res_id = 1
		Log("Gather res_id == nil gather_id:" .. self.vo.gather_id)
	end

	self.scale = gather_config.scale
end

function Gather:InitAnimation()
	local res_path = ResPath.GetGather(self.res_id)
	local sprite_frame = XUI.GetSpriteFrame(res_path)
	if nil == sprite_frame then
		Log("Gather create sprite error gather_id:" .. self.vo.gather_id .. " res_id:" .. self.res_id)
		return
	end

	local gather_config = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[self.vo.gather_id]
	if nil ~= gather_config then
		self.is_gather_visual = gather_config.visual
	end

	local sprite = cc.Sprite:createWithSpriteFrame(sprite_frame)
	if nil ~= sprite then
		sprite:setScale(self.scale)
		self:GetModel():AttachNode(sprite, cc.p(0, 0), GRQ_SCENE_OBJ, InnerLayerType.Main, true)

		--只是透明度隐藏，但允许点击，可实现点击某个区域采集的效果。真正不可见应由服务端控制
		if gather_config and self.is_gather_visual == 0 then 
			sprite:setOpacity(0)
		end
	end

	if gather_config and gather_config.shine == 1 then
		local ps_path = ResPath.GetParticleSystemPath(10017)
		local ps_node = ParticleSystemCommon:create(ps_path)
		if ps_node then
			ps_node:setScale(self.scale)
			self:GetModel():AttachNode(ps_node, cc.p(0, 20), GRQ_SCENE_OBJ, InnerLayerType.Main + 1)
		end
	end


	if self.vo.gather_id == ConfigManager.Instance:GetAutoConfig("guildbonfire_auto").other_cfg[1].gathar_id then
		if self.vo.param >= 3000 then
			local anim_path, anim_name = ResPath.GetEffectAnimPath(3166)
			local animate_sprite = RenderUnit.CreateAnimSprite(anim_path, anim_name, FrameTime.Effect)
			local scale = string.format("%.1f", (self.vo.param - 3000) / 7000)
			animate_sprite:setScale(1 + scale)
			self:GetModel():AttachNode(animate_sprite, cc.p(0, 50), GRQ_SCENE_OBJ, InnerLayerType.Buff, true)

			local eff_num = 12	--特效数量
			local other_cfg = GuildData.Instance:GetBonfireOtherCfg()
			local radial = other_cfg.timereward_range * 20 	-- 小特效围绕半径
			local angle = 360 / eff_num
			for i=1,eff_num do
				local rad = (90 + angle * (i - 1)) / 180 * math.pi
				local x = -(radial * math.cos(rad))
				local y = radial * math.sin(rad) * 0.8

				local eff_path, eff_name = ResPath.GetEffectAnimPath(3156)
				local eff_sprite = RenderUnit.CreateAnimSprite(eff_path, eff_name, FrameTime.Effect)
				eff_sprite:setScale(0.7)
				self:GetModel():AttachNode(eff_sprite, cc.p(x, y + 110), GRQ_SCENE_OBJ, InnerLayerType.Buff + i)
			end
		end
	end

	local rect = sprite_frame:getRect()
	self.width_half = rect.width / 2 
	local height = rect.height
	if self.scale and self.scale > 0 then
		self.width_half = self.width_half * self.scale
		height = height * self.scale
	end
	self:SetHeight(height)

	self:UpdateSpecialGather()
	self:RefreshAnimation()
end

function Gather:UpdateSpriteFrame()
	-- local res_id = Scene.Instance:GetSceneLogic():GetGatherSpecialRes(self.vo) or self.res_id
	-- local res_path = ResPath.GetGather(res_id)
	-- local sprite_frame = XUI.GetSpriteFrame(res_path)
	-- if nil == sprite_frame then
	-- 	Log("Gather create sprite error gather_id:" .. self.vo.gather_id .. " res_id:" .. self.res_id)
	-- 	return
	-- end
	-- local sprite = self:GetModel():GetLayerNode(GRQ_SCENE_OBJ, InnerLayerType.Main)
	-- if nil ~= sprite then
	-- 	sprite:setSpriteFrame(sprite_frame)
	-- end
end

function Gather:UpdateSpecialGather()
	if 28 == self.res_id then -- 精灵蛋
		local anim_path, anim_name = ResPath.GetEffectAnimPath(3167)
		local animation_sprite = RenderUnit.CreateAnimSprite(anim_path, anim_name, FrameTime.Effect)
		animation_sprite:setScale(1.5)
		self:GetModel():AttachNode(animation_sprite, cc.p(1, 28), GRQ_SCENE_OBJ, InnerLayerType.Main)
	end
end

-- 刷新动画
function Gather:RefreshAnimation()
	if self.vo.gather_id == ConfigManager.Instance:GetAutoConfig("guildbonfire_auto").other_cfg[1].gathar_id then
		local animate_sprite = self:GetModel():GetLayerNode(GRQ_SCENE_OBJ, InnerLayerType.Buff)
		if nil ~= animate_sprite then
			local scale = string.format("%.1f", (self.vo.param - 3000) / 7000)
			animate_sprite:setScale(1 + scale)
		end
	end
end

function Gather:SetHeight(height)
	if nil == self.name_board and nil ~= self.name and "" ~= self.name then
		local name_board = GatherNameBoard.New()
		name_board:SetName(self.name)
		self:SetNameBoard(name_board)
		self:UpdateNameBoard()
	end

	SceneObj.SetHeight(self, height)
end

function Gather:UpdateNameBoard()
	if self.name_board then
		self.name_board:SetGather(self.vo)
	end
end

function Gather:IsClick(x, y)
	return self.real_pos.x - self.width_half <= x and x <= self.real_pos.x + self.width_half 
		and self.real_pos.y <= y and y <= self.real_pos.y + self.height
end

function Gather:OnClick()
	local anim_path, anim_name = ResPath.GetEffectAnimPath(ResPath.SelectBlue)
	self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Select, anim_path, anim_name)
end

function Gather:GetItemID()
	if not self.vo then
		return nil
	end
	return self.vo.item_id
end
