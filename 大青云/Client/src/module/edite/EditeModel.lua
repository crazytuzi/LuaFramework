_G.EditeModel = Module:new();

EditeModel.scenes = nil;

function EditeModel:NeedSaved()
	return true;
end

function EditeModel:Sava()
	
end

function EditeModel:SetSelected(entity)
	self.currEntity = entity;
	if not entity or not entity.objNode then
		return;
	end
end

function EditeModel:GetEntityInfo(entity)
	local scene = self:GetSceneInfo(CPlayerMap:GetCurMapID());
	local entitys = scene[entity.objNode.dwType];
	if not entitys then
		entitys = {};
		scene[entity.objNode.dwType] = entitys;
	end
	
	local cid = entity.cid;
	if not cid then
		return;
	end
	
	local info  = entitys[cid];
	if not info then
		info = {};
		entitys[cid] = info;
	end
	
	return info;
end

function EditeModel:SetEntityMaterial(entity,material)
	local info = self:GetEntityInfo(entity);
	if not info then
		return;
	end
	info.material = material;
end

function EditeModel:SetEntityHighLight(entity,color)
	local info = self:GetEntityInfo(entity);
	if not info then
		return;
	end
	local hight = info.hight;
	if not hight then
		hight = {};
		info.hight = hight;
	end
	hight.color = color;
end

function EditeModel:SetEntitySelectLight(entity,light)
	local info = self:GetEntityInfo(entity);
	if not info then
		return;
	end
	info.selectLight = light;
end

function EditeModel:SetSceneLight(light,mapid)
	mapid = mapid or CPlayerMap:GetCurMapID();
	local scene = self:GetSceneInfo(mapid);
	scene.light = light;
end

function EditeModel:GetSceneInfo(id)
	if not self.scenes then
		self.scenes = {};
	end
	local info = self.scenes[id];
	if not info then
		info = {};
		self.scenes[id] = info;
	end
	return info;
end

----------------------------------------------------LIGHT---------------------------------------------
EditeModel.BaseLightCommon = nil;
EditeModel.BaseSceneLight = nil;
function EditeModel:Init()
	self.BaseLightCommon = table.clone(LightCommon);
	self.BaseSceneLight = table.clone(SceneLight);
end

function EditeModel:ResetLight()
	_G.LightCommon = table.clone(self.BaseLightCommon);
	_G.SceneLight = table.clone(self.BaseSceneLight);
	
	CPlayerMap:SetPlayerLight();
	CPlayerMap:SetSceneLight();
end

function EditeModel:GetLightByKey(key,mapid,save)
	local light = nil;
	if not key or #key==0 then
		return light;
	end
	
	if not mapid then
		light = LightCommon[key];
		return light;
	end
	
	local map = SceneLight[mapid];
	if not map then
		light = LightCommon[key];
		if save then
			map = {};
			SceneLight[mapid] = map;
			map[key] = light;
		end
		return light;
	end
	
	light = map[key];
	if not light then
		light = LightCommon[key];
		if save then
			map[key] = light;
		end
		return light;
	end
	
	return light;
end

function EditeModel:CheckSceneHasLight(key,mapid)
	if not key or #key == 0 then
		return;
	end
	
	if not mapid then
		return;
	end
	
	local map  = SceneLight[mapid];
	if not map then
		return;
	end
	
	return map[key] ~= nil;
end

function EditeModel:GetEntityLight(enum,mapid,save)
	local light = LightCommon[enum];
	if not mapid then
		return light;
	end
	
	local map = SceneLight[mapid];
	if not map then
		if save then
			map = {};
			SceneLight[mapid] = map;
			map[key] = light;
		end
		return light;
	end
	
	light = map[enum];
	if not light then
		light = LightCommon[enum];
		if save then
			map[enum] = light;
		end
	end
	return light;
end

function EditeModel:GetSceneLight(mapid,save)
	local map = SceneLight[mapid];
	if not map then
		if save then
			map = table.clone(LightCommon);
			SceneLight[mapid] = map;
		end
		return map;
	end
	return map;
end
