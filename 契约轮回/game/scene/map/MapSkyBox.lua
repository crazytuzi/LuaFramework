--
-- @Author: LaoY
-- @Date:   2019-02-19 19:36:11
-- 天空盒
MapSkyBox = MapSkyBox or class("MapSkyBox",BaseWidget)

function MapSkyBox:ctor(parent_node,builtin_layer)
	self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.MapSkyBox)
	self.abName = "mapasset/mapres_tilemap"
	self.assetName = "tilemap"
	-- 场景对象才需要修改
	self.builtin_layer = LayerManager.BuiltinLayer.Default

	self.mgr = MapManager:GetInstance()

	self.extra_list = {}
	self.update_list = {}
	self.pos = Vector3(0,0,0)

	MapSkyBox.super.Load(self)
end

function MapSkyBox:dctor()
	self:RemoveExtra()

	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end
end

-- 天空盒不缓存 个数不多
-- function MapSkyBox:__reset()
-- 	self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.MapSkyBox)
-- 	MapSkyBox.super.__reset(self)
-- end

function MapSkyBox:RemoveExtra()
	for k,v in pairs(self.extra_list) do
		v:destroy()
	end
	self.extra_list = {}
end

function MapSkyBox:LoadCallBack()
	self.img_component = self.transform:GetComponent('SpriteRenderer')
	self:AddEvent()
end

function MapSkyBox:AddEvent()
	self.global_event_list = {}
	local function call_back()
		self:UpdateRatio()
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.UpdateCameraSize, call_back)
end

function MapSkyBox:LoadSkyBox(scene_id,assetName)
	local abName ="mapasset/skybox_" .. scene_id .. ".unity3d"
	local assetName = assetName
	if self.last_abName == abName and self.last_assetName == assetName then
		return
	end
	self.last_abName = abName
	self.last_assetName = assetName
	self.is_loaded_res = false
	self.is_loading = 1
	local function callBack(uobject_list)
		self.is_loading = 2
        if self.is_dctored then
            return
        end
		if uobject_list and uobject_list[0] then
			local sprite = uobject_list[0]
			self.img_component.sprite = sprite
			self.transform.name = assetName

			local function step()
				if self.is_dctored then
					return
				end
				self:InitSkyBox()
			end
			GlobalSchedule:StartOnce(step,0)
		end
	end
	local load_level = Constant.LoadResLevel.Super
	lua_resMgr:LoadSceneSprite(self,scene_id,abName,assetName,callBack,load_level,true,false)
end

function MapSkyBox:UpdateRatio()

	if not self.width or not self.height then
		return
	end

	local check_map_w = self.mgr.map_pixels_width - self.mgr.halfScreenWidth * 2
	local check_map_h = self.mgr.map_pixels_height - self.mgr.halfScreenHeight * 2

	local check_skybox_w = self.mgr.map_pixels_width - self.width
	local check_skybox_h = self.mgr.map_pixels_height - self.height
	check_skybox_w = check_skybox_w < 0 and check_map_w or check_skybox_w
	check_skybox_h = check_skybox_h < 0 and check_map_h or check_skybox_h

	self.check_ratio_w = check_skybox_w/check_map_w
	self.check_ratio_h = check_skybox_h/check_map_h
end

function MapSkyBox:InitSkyBox()
	self.is_loaded_res = true
	self.width = self.img_component.bounds.size.x * 100
	self.height = self.img_component.bounds.size.y * 100

	self.width = math.round(self.width)
	self.height = math.round(self.height)

	if self.data and self.data.type == 3 and (self.width < ScreenWidth or self.height < ScreenHeight) then
		local standardScale = math.max(ScreenWidth/self.width,ScreenHeight/self.height)
		SetLocalScale(self.transform,standardScale)
		self.width = self.width * standardScale
		self.height = self.height * standardScale
		self.width = math.round(self.width)
		self.height = math.round(self.height)
	end
	
	self:UpdateRatio()

	self:RemoveExtra()
	-- 如果需要动态滚动。需要额外创建
	-- 第一个才有 self.data
	if self.data and self.data.type == 11 then
		local rate = 1
		if self.data.speed and self.data.speed < 0 then
			rate = -1
		end
		local y = self.mgr.camera_pos.y + (self.mgr.halfScreenHeight - self.height * 0.5) * rate
		self:SetGlobalPosition(self.mgr.map_pixels_width * 0.5,y,2000 + self.data.layer)
		y = y - self.height * rate
		local need_count = math.ceil(self.mgr.halfScreenHeight * 2/self.height)
		self.update_list = {}
		self.update_list[#self.update_list+1] = self
		for i=1,need_count do
			local item = self.extra_list[i]
			if not item then
				item = MapSkyBox()
				item:SetGlobalPosition(self.mgr.map_pixels_width * 0.5,y,2000 + self.data.layer)
				y = y - self.height * rate
				self.extra_list[i] = item
			end
			item:LoadSkyBox(self.data.ref_scene,self.data.assetName)
			item.transform.name = self.data.assetName .. "_" .. i+1
			self.update_list[#self.update_list+1] = item
		end
	end
end

function MapSkyBox:SetGlobalPosition(x,y,z)
	self.pos.x = x
	self.pos.y = y
	self.pos.z = z
	SetGlobalPosition(self.transform,self.pos.x/SceneConstant.PixelsPerUnit,self.pos.y/SceneConstant.PixelsPerUnit,self.pos.z)
end

function MapSkyBox:Update()
	if not self.is_loaded_res then
		if (not self.is_loading ) and MapLayer.GetInstance().is_load_fuzzy then
			self:LoadSkyBox(self.data.ref_scene,self.data.assetName)
		end
		return
	end
	if self.data.type == 11 then
		self:UpdatePos()
		return
	end
	local cur_x = 0
	local cur_y = 0
	if self.data.type == 1 then
		cur_x = self.mgr.camera_pos.x
		cur_y = (self.mgr.camera_pos.y - math.round(self.mgr.halfScreenHeight)) * self.check_ratio_h + self.height * 0.5
	elseif self.data.type == 2 then
		cur_x = (self.mgr.camera_pos.x - math.round(self.mgr.halfScreenWidth)) * self.check_ratio_w + self.width * 0.5
		cur_y = self.mgr.camera_pos.y
	elseif self.data.type == 3 then
		cur_x = (self.mgr.camera_pos.x - math.round(self.mgr.halfScreenWidth)) * self.check_ratio_w + self.width * 0.5
		cur_y = (self.mgr.camera_pos.y - math.round(self.mgr.halfScreenHeight)) * self.check_ratio_h + self.height * 0.5
	end
	
	if self.last_check_x == cur_x and self.last_check_y == cur_y then
		return
	end
	self.last_check_x = cur_x
	self.last_check_y = cur_y

	SetGlobalPosition(self.transform, cur_x/SceneConstant.PixelsPerUnit, cur_y/SceneConstant.PixelsPerUnit, 2000 + self.data.layer)
end

function MapSkyBox:UpdatePos()
	for k,item in pairs(self.update_list) do
		item:SetGlobalPosition(item.pos.x,item.pos.y + (self.data.speed or 10),item.pos.z)
	end
	local item = self.update_list[1]
	if not item then
		return
	end
	if self.data.speed and self.data.speed > 0 then
		if item.pos.y - self.height * 0.5 > self.mgr.camera_pos.y + self.mgr.halfScreenHeight then
			table.remove(self.update_list,1)
			local last_item = self.update_list[#self.update_list]
			item:SetGlobalPosition(last_item.pos.x,last_item.pos.y - self.height,last_item.pos.z)
			table.insert(self.update_list,item)
		end
	elseif self.data.speed and self.data.speed < 0 then
		if item.pos.y + self.height * 0.5 < self.mgr.camera_pos.y - self.mgr.halfScreenHeight then
			table.remove(self.update_list,1)
			local last_item = self.update_list[#self.update_list]
			item:SetGlobalPosition(last_item.pos.x,last_item.pos.y + self.height,last_item.pos.z)
			table.insert(self.update_list,item)
		end
	end
	
end

function MapSkyBox:SetData(data)
	self.data = data
	self.is_loading = nil
	self.is_loaded_res = nil
end