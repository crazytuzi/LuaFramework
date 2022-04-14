--
-- @Author: LaoY
-- @Date:   2018-11-01 19:35:49
--
MapBlock = MapBlock or class("MapBlock",BaseWidget)

MapBlock.__cache_count = 26

function MapBlock:ctor()
	self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.MapLayer)
	self.abName = "mapasset/mapres_tilemap"
	self.assetName = "tilemap"
	-- _sceneContainer
	-- 场景对象才需要修改
	self.builtin_layer = LayerManager.BuiltinLayer.Default

	self.start_load_time = Time.time
	self.is_start_load = false
	self.is_load_real_res = false

	MapBlock.super.Load(self)
end

function MapBlock:dctor()
	self:StopTime()
    self.isLoadMapFinish = nil;
    if self.isFirst then
        MapLayer:GetInstance():AddLoadMapCount()
    end
    self.isFirst = false;
end

function MapBlock:__reset()
	self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.MapLayer)
	MapBlock.super.__reset(self)
end

function MapBlock:__clear()
	self:StopTime()
	self:LoadDefault()

	self.abName = nil
	self.assetName = nil
	self.data = nil
	self.scene_id = nil
	self.res_scene_id = nil
	self.atlas_id = nil
	self.res_id = nil
	self.start_load_time = nil
    self.isLoadMapFinish = nil;
    if self.isFirst then
        MapLayer:GetInstance():AddLoadMapCount()
    end
    self.isFirst = false;

    self.is_load_real_res = false
	MapBlock.super.__clear(self)
end

function MapBlock:SetVisible(bo)
	if self.isVisible == bo then
		return
	end
	self.isVisible = bo
	self.gameObject:SetActive(bo)
	if bo then
		self:OnEnable()
	else
		self:OnDisable()
	end
end

function MapBlock:LoadCallBack()
	self.img_component = self.transform:GetComponent('SpriteRenderer')
	self:AddEvent()
end

function MapBlock:LoadDefault()
	self.is_start_load = false
	self.is_load_real_res = false
	self.img_component.sprite = nil
	-- local abName
	-- local assetName
	-- self:LoadImageTexture(abName,assetName,callBack)
end

function MapBlock:StartLoad()
	self.is_start_load = true
	local function callBack(sprite)
		self.img_component.sprite = sprite
		self.is_load_real_res = true
		self.transform.name = self.res_id;
        if self.isLoadMapFinish ~= nil then
            self.isLoadMapFinish = true;
            SetLocalScale(self.img_component.transform , 1,1,1);
            if self.isFirst then
                MapLayer:GetInstance():AddLoadMapCount()
                self.isFirst = false
            end
        else
            SetLocalScale(self.img_component.transform , 16,16,16);
        end
	end
	local scene_res_id = self.res_scene_id
	if scene_res_id == 11001 then
		scene_res_id = LoginModel:GetInstance():GetFirstSceneResID(scene_res_id)
	end
	local abName ="mapasset/mapres_" .. scene_res_id .. ".unity3d";--"_".. self.res_id ..
	local assetName = scene_res_id .. "_".. self.res_id
    --local abName ="mapasset/mapres_" .. self.res_scene_id;
    --print2(abName);
    --local assetName = self.res_scene_id .. "_".. self.res_id
	self.abName = abName
	self.assetName = assetName

	-- local sprite = MapLayer:GetInstance():GetCacheMapSprite(self.res_scene_id,self.res_id)
	local sprite = lua_resMgr:GetCacheObject(abName,assetName)
	if sprite then
        self.isLoadMapFinish = false;
		callBack(sprite[0])
	else
		local fuzzt_abName = "mapasset/mapcompres_" .. self.res_scene_id
		local fuzzy_sprite = lua_resMgr:GetCacheObject(fuzzt_abName,assetName)
		local is_imm_load = true
		if not fuzzy_sprite then
			is_imm_load = false
			fuzzy_sprite = lua_resMgr:LoadSynchronousSprite(fuzzt_abName,assetName)
		end
		callBack(fuzzy_sprite,true);
        self.isLoadMapFinish = false;
		if is_imm_load then
			self:LoadImageTexture(abName,assetName,callBack)
		else
			local function step()
				if self.is_dctored then
					return
				end
				self:LoadImageTexture(abName,assetName,callBack)
			end
            if not PlatformManager:GetInstance():IsMobile() then
                step();
            else
                MapLayer:GetInstance():AddLoadMap(step);
            end

			--GlobalSchedule:StartOnce(step,0.04)--@ling注释
		end
	end
end

function MapBlock:LoadImageTexture(abName,assetName,callBack)
	if self.is_dctored or self.__is_clear then
		return
	end
	-- lua_resMgr:SetImageTexture(self,self.img_component,abName,assetName,true,callBack)
	local function load_call_back(uobject_list)
		if self.is_dctored then
			return
		end
		if self.abName ~= abName or self.assetName ~= assetName then
			return
		end
		if self.scene_id ~= SceneManager:GetInstance():GetSceneId() then
			return
		end
		if uobject_list and uobject_list[0] then
			-- local sprite = newObject(uobject_list[0])
			local sprite = uobject_list[0]
			-- MapLayer:GetInstance():AddCacheMapSprite(self.res_scene_id,self.res_id,sprite)
			if callBack then
				callBack(sprite)
			end
			-- self.img_component:SetNativeSize()
		end
	end
	-- local load_level = Constant.LoadResLevel.Low
	local load_level = Constant.LoadResLevel.Super
	if LoginModel.IsIOSExamine then
		load_level = Constant.LoadResLevel.Urgent
	end
	lua_resMgr:LoadSceneSprite(self,self.res_scene_id,abName,assetName,load_call_back,load_level,true)
end

function MapBlock:AddEvent()
end

--[[
	@author LaoY
	@des	
	@param1 scene_id 			场景ID
	@param2 atlas_id			图集id
	@param3 res_id				资源id
	@param4 start_load_time 	开始加载的时间
--]]
function MapBlock:SetData(data)
	self.data = data
	self.scene_id = data.scene_id
	self.res_scene_id = data.res_scene_id
	self.atlas_id = data.atlas_id
	self.res_id = data.res_id
	self.start_load_time = data.load_time

	self:StartLoad()
end

function MapBlock:StartTime()
	self:StopTime()
	local function step()
		self:StartLoad()
	end
	self.time_id = GlobalSchedule:StartOnce(step,self.start_load_time)
end

function MapBlock:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
	end
end

function MapBlock:SetPosition(x,y,z)
	self.position = self.position or {}
	self.position.x = x
	self.position.y = y
	self.position.z = z
	SetGlobalPosition(self.transform, x/SceneConstant.PixelsPerUnit, y/SceneConstant.PixelsPerUnit, z)
end

function MapBlock:GetPosition()
	return self.position.x,self.position.y,self.position.z
end 

function MapBlock:GetRowColumn()
	return self.data.row,self.data.column
end