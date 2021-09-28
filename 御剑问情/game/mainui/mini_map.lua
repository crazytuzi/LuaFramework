MiniMap = MiniMap or BaseClass(BaseRender)

local MERGE_TEXTURE = false			-- 是否合并贴图
function MiniMap:__init(instance)
	if instance == nil then
		return
	end

	self.mini_map = self:FindObj("MiniMap"):GetComponent(typeof(UIMiniMap))
	self.mini_map.IsMergeTexture = MERGE_TEXTURE
	self:FlushTexture()
	self:SetMainRole()
	self:FlushMainRolePos()

	self.eh_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.OnSceneLoadingQuite, self))
	self.eh_pos_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind1(self.OnMainRolePosChangeFunc, self))

	self.monster_texture = nil
	self.npc_texture = nil
	self.gather_texture = nil
	self.door_texture = nil

	if MERGE_TEXTURE then
		self:LoadMonsterTexture()
		self:LoadNpcTexture()
		self:LoadGatherTexture()
		self:LoadDoorTexture()
	end
end

function MiniMap:__delete()
	if nil ~= self.eh_load_quit then
		GlobalEventSystem:UnBind(self.eh_load_quit)
		self.eh_load_quit = nil
	end
	if nil ~= self.eh_pos_change then
		GlobalEventSystem:UnBind(self.eh_pos_change)
		self.eh_pos_change = nil
	end
	if nil ~= self.monster_texture then
		TexturePool.Instance:Free(self.monster_texture)
		self.monster_texture = nil
	end
	if nil ~= self.npc_texture then
		TexturePool.Instance:Free(self.npc_texture)
		self.npc_texture = nil
	end
	if nil ~= self.gather_texture then
		TexturePool.Instance:Free(self.gather_texture)
		self.gather_texture = nil
	end
	if nil ~= self.door_texture then
		TexturePool.Instance:Free(self.door_texture)
		self.door_texture = nil
	end
end

function MiniMap:OnSceneLoadingQuite()
	self:FlushTexture()
	self:SetMainRole()
	self:FlushMainRolePos()
	if MERGE_TEXTURE then
		self:MergeMonsterTexture()
		self:MergeNpcTexture()
		self:MergeGatherTexture()
		self:MergeDoorTexture()
	end
end

function MiniMap:OnMainRolePosChangeFunc()
	self:FlushMainRolePos()
end

function MiniMap:FlushTexture()
	if MinimapCamera.Instance then
		self.mini_map.TextTure = MinimapCamera.Instance.MapTexture
	end
end

function MiniMap:FlushMainRolePos()
	if MinimapCamera.Instance then
		local pos_x, pos_y = Scene.Instance:GetMainRole():GetRealPos()
		local uv_pos = MinimapCamera.Instance:TransformWorldToUV(Vector3(pos_x, 0, pos_y))
		uv_pos = Vector2(uv_pos.x + 0.5, uv_pos.y + 0.5)
		self.mini_map.UVPos = uv_pos
	end
end

function MiniMap:SetMainRole()
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		local root = main_role:GetRoot()
		if root and not IsNil(root.gameObject) then
			self.mini_map.MainRole = root.gameObject.transform
		end
	end
end

function MiniMap:LoadMonsterTexture()
	TexturePool.Instance:Load(AssetID("uis/views/map/images_atlas", "Map_Monster 1"), function(texture)
		if nil == texture then
			return
		end

		self.monster_texture = texture
		self:MergeMonsterTexture()
	end)
end

function MiniMap:LoadNpcTexture()
	TexturePool.Instance:Load(AssetID("uis/views/map/images_atlas", "Map_Teamate_Pos"), function(texture)
		if nil == texture then
			return
		end

		self.npc_texture = texture
		self:MergeNpcTexture()
	end)
end

function MiniMap:LoadGatherTexture()
	TexturePool.Instance:Load(AssetID("uis/views/map/images_atlas", "Map_Gather"), function(texture)
		if nil == texture then
			return
		end

		self.gather_texture = texture
		self:MergeGatherTexture()
	end)
end

function MiniMap:LoadDoorTexture()
	TexturePool.Instance:Load(AssetID("uis/views/map/images_atlas", "Map_Target 1"), function(texture)
		if nil == texture then
			return
		end

		self.door_texture = texture
		self:MergeDoorTexture()
	end)
end

function MiniMap:MergeMonsterTexture()
	local config = MapData.Instance:GetMapConfig(Scene.Instance:GetSceneId())
	if not config then
		return
	end
	if self.monster_texture and MinimapCamera.Instance then
		local last_monster_id = 0
		for _, v in pairs(config.monsters) do
			if last_monster_id ~= v.id then
				last_monster_id = v.id
				local wx, wy = GameMapHelper.LogicToWorld(v.x, v.y)
				local uv_pos = MinimapCamera.Instance:TransformWorldToUV(Vector3(wx, 0, wy))
				uv_pos = Vector2(uv_pos.x + 0.5, uv_pos.y + 0.5)
				self.mini_map:MergeImage(self.monster_texture, uv_pos)
			end
		end
	end
end

function MiniMap:MergeNpcTexture()
	local config = MapData.Instance:GetMapConfig(Scene.Instance:GetSceneId())
	if not config then
		return
	end
	if self.npc_texture and MinimapCamera.Instance then
		for _, v in pairs(config.npcs) do
			local wx, wy = GameMapHelper.LogicToWorld(v.x, v.y)
			local uv_pos = MinimapCamera.Instance:TransformWorldToUV(Vector3(wx, 0, wy))
			uv_pos = Vector2(uv_pos.x + 0.5, uv_pos.y + 0.5)
			self.mini_map:MergeImage(self.npc_texture, uv_pos)
		end
	end
end

function MiniMap:MergeGatherTexture()
	local config = MapData.Instance:GetMapConfig(Scene.Instance:GetSceneId())
	if not config then
		return
	end
	if self.gather_texture and MinimapCamera.Instance then
		local last_gather_id = 0
		for _, v in pairs(config.gathers) do
			if last_gather_id ~= v.id then
				last_gather_id = v.id
				local wx, wy = GameMapHelper.LogicToWorld(v.x, v.y)
				local uv_pos = MinimapCamera.Instance:TransformWorldToUV(Vector3(wx, 0, wy))
				uv_pos = Vector2(uv_pos.x + 0.5, uv_pos.y + 0.5)
				self.mini_map:MergeImage(self.gather_texture, uv_pos)
			end
		end
	end
end

function MiniMap:MergeDoorTexture()
	local config = MapData.Instance:GetMapConfig(Scene.Instance:GetSceneId())
	if not config then
		return
	end
	if self.door_texture and MinimapCamera.Instance then
		for _, v in pairs(config.doors) do
			local wx, wy = GameMapHelper.LogicToWorld(v.x, v.y)
			local uv_pos = MinimapCamera.Instance:TransformWorldToUV(Vector3(wx, 0, wy))
			uv_pos = Vector2(uv_pos.x + 0.5, uv_pos.y + 0.5)
			self.mini_map:MergeImage(self.door_texture, uv_pos)
		end
	end
end