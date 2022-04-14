--
-- @Author: LaoY
-- @Date:   2018-11-01 19:27:10
--

MapLayer = MapLayer or class("MapLayer",BaseManager)
local this = MapLayer

local math_ceil = math.ceil
local math_floor = math.floor
local math_max = math.max
local math_abs = math.abs
local Time = Time
local table_sort = table.sort

function MapLayer:ctor()
	MapLayer.Instance = self
	-- FixedUpdateBeat:Add(self.Update, self, 4, 1)
	LateUpdateBeat:Add(self.Update,self,4,1)
	self.mgr = MapManager:GetInstance()
	self.map_cache_list = {}

	self.has_load_map_count = 0
	self.all_load_map_count = 1
	self:Init()
end

function MapLayer:AddEvent()
	local function call_back()
		self:ClearAllObjectState()	
	end
	GlobalEvent:AddListener(LoginEvent.OpenLoginScene, call_back)
	GlobalEvent:AddListener(EventName.GameReset, call_back)
end

function MapLayer:Init()
	-- 场景地图
	self.scene_map_list = {}
	-- 场景对象 npc 跳跃点 
	self.scene_object_list = {}

	self.last_check_pos = Vector2(0,0)

	self.proload_offset = 200
	self.check_offset = SceneConstant.BlockSize.w

	self.check_bottom_left_pos = Vector2(0,0)
	self.check_top_rigth_pos = Vector2(0,0)

	self.screen_bottom_left_pos = Vector2(0,0)
	self.screen_top_right_pos = Vector2(0,0)

	self.cur_scene_id = nil
	self.last_scene_id = nil

	self.sky_box_list = {}

    if not PlatformManager:GetInstance():IsMobile() then
        MapLayer.ExecuteFrequence = 1;
    end
end

function MapLayer.GetInstance()
	if MapLayer.Instance == nil then
		MapLayer()
	end
	return MapLayer.Instance
end

function MapLayer:Load()
	
end

function MapLayer:LoadMapling()
	if self.WaitLoadList and #self.WaitLoadList > 0 then
		local fun = self.WaitLoadList[1];
		table.remove(self.WaitLoadList , 1);
		fun();
	end
end

function MapLayer:AddLoadMap(fun)
	if not self.WaitLoadList then
		self.WaitLoadList = {};
	end
	if fun then
		table.insert(self.WaitLoadList , fun);
	end
end
MapLayer.ExecuteFrequence = 1;
MapLayer.elapse = 0;
function MapLayer:Update()
	if not self.mgr.is_loaded or not self.is_load_fuzzy then
		return false
	end
	MapLayer.elapse = MapLayer.elapse + 1;
	if (MapLayer.elapse % MapLayer.ExecuteFrequence == 0) then
		self:LoadMapling();
	end

	if SceneManager:GetInstance():GetChangeSceneState() then
		return
	end

	for k,sky_box in pairs(self.sky_box_list) do
		sky_box:Update()
	end

	local cur_block_x,cur_block_y = SceneManager:GetInstance():GetBlockPos(self.mgr.sceneCamCanMoveToPosTemp.x,self.mgr.sceneCamCanMoveToPosTemp.y)
	--两次位置不超过self.check_offset
	-- if math_abs(self.mgr.sceneCamCanMoveToPosTemp.x - self.last_check_pos.x) >= self.check_offset
	-- 		or math_abs(self.mgr.sceneCamCanMoveToPosTemp.y - self.last_check_pos.y) >= self.check_offset then
		-- self.last_check_pos.x = self.mgr.sceneCamCanMoveToPosTemp.x
		-- self.last_check_pos.y = self.mgr.sceneCamCanMoveToPosTemp.y
	if cur_block_x ~= self.last_check_pos.x or cur_block_y ~= self.last_check_pos.y or self.mgr:IsUpdateCameraSize() then
		self.last_check_pos.x = cur_block_x
		self.last_check_pos.y = cur_block_y
		
		-- 主需要判断左下角和右上角是否越界就行
		-- local count = math_ceil(self.proload_offset/self.mgr.split_map_size)
		local count = math_ceil(self.proload_offset/self.mgr.split_map_size)
		count = 0.2
		local preload_offset = count * self.mgr.split_map_size
		--左下角
		local b_l_x = self.mgr.sceneCamCanMoveToPosTemp.x - self.mgr.halfScreenWidth - preload_offset
		local b_l_y = self.mgr.sceneCamCanMoveToPosTemp.y - self.mgr.halfScreenHeight - preload_offset
		b_l_x = b_l_x < 0 and 0 or b_l_x
		b_l_y = b_l_y < 0 and 0 or b_l_y
		self.check_bottom_left_pos.x = b_l_x
		self.check_bottom_left_pos.y = b_l_y
		--右上角
		local t_r_x = self.mgr.sceneCamCanMoveToPosTemp.x + self.mgr.halfScreenWidth + preload_offset
		local t_r_y = self.mgr.sceneCamCanMoveToPosTemp.y + self.mgr.halfScreenHeight + preload_offset
		t_r_x = t_r_x >= self.mgr.map_pixels_width and self.mgr.map_pixels_width - 1 or t_r_x
		t_r_y = t_r_y >= self.mgr.map_pixels_height and self.mgr.map_pixels_height - 1 or t_r_y
		self.check_top_rigth_pos.x = t_r_x
		self.check_top_rigth_pos.y = t_r_y
		
		self.screen_bottom_left_pos.x = self.mgr.sceneCamCanMoveToPosTemp.x - self.mgr.halfScreenWidth
		self.screen_bottom_left_pos.y = self.mgr.sceneCamCanMoveToPosTemp.y - self.mgr.halfScreenWidth
		self.screen_top_right_pos.x = self.mgr.sceneCamCanMoveToPosTemp.x + self.mgr.halfScreenWidth
		self.screen_top_right_pos.y = self.mgr.sceneCamCanMoveToPosTemp.y + self.mgr.halfScreenWidth
		-- 刷新地图
		self:UpdateMap()
		--刷新场景
		self:UpdateObject()
	end
end

function MapLayer:UpdateObject()
	local scene_id = self.cur_scene_id
	if not scene_id then
		return
	end
	self.scene_object_list[scene_id] = self.scene_object_list[scene_id] or {}
	local object_list = self.scene_object_list[scene_id]
	local x,y
	local sceneMgr = SceneManager:GetInstance()
	for k,type_list in pairs(object_list) do
		for _,info in pairs(type_list) do
			x,y = info.coord.x,info.coord.y
			if not self:IsInCamCan(x,y) then
				if info.is_add_scene then
					info.is_add_scene = false
					sceneMgr:RemoveObject(info.uid)
				end
			else
				if not info.is_add_scene then
					info.is_add_scene = true
					sceneMgr:SetObjectInfo(info)
					sceneMgr:AddObject(info.uid)
				end
			end
		end
	end
end

function MapLayer:LoadFuzzyLayer()
    --print2("MapLayer:LoadFuzzyLayer" .. debug.traceback() .. Time.timeSinceLevelLoad);
	self.is_load_fuzzy = false
	local res_scene_id = self.mgr.ref_scene_id or self.cur_scene_id
	local abName = "mapasset/mapcompres_" .. res_scene_id
	local assetName = res_scene_id .. "_0"
	local function load_call_back()
		self.is_load_fuzzy = true
        --print2("MapLayer:LoadFuzzyLayer" .. tostring(self.is_load_fuzzy) .. debug.traceback() .. Time.timeSinceLevelLoad);
	end
    lua_resMgr:LoadSceneSprite(self,res_scene_id,abName,assetName,load_call_back,Constant.LoadResLevel.Urgent,false)
end

function MapLayer:UpdateMap()
	local scene_id = self.cur_scene_id
	if not scene_id then
		return
	end
	self.scene_map_list[scene_id] = self.scene_map_list[scene_id] or {}
	local list = self.scene_map_list[scene_id]
	local dele_tab

	local split_maps_width = self.mgr.split_maps_width
	-- local leftColumn = self:GetMapResPos(self.check_bottom_left_pos.x)
	-- local rightColumn = self:GetMapResPos(self.check_top_rigth_pos.x)

	-- local downRow = self:GetMapResPos(self.check_bottom_left_pos.y)
	-- local upRow = self:GetMapResPos(self.check_top_rigth_pos.y)


	-- local count = math_ceil(self.proload_offset/self.mgr.split_map_size)
	local count = 2
	local is_in_race = RaceModel and RaceModel.GetInstance():IsRaceScene(scene_id)
	local is_in_timeline = TimelineConfig[scene_id] ~= nil

	local is_show_all =  is_in_race or is_in_timeline
	if is_show_all then
		--特定场景地图全部显示
		count = 10000
	end

	local preload_offset = count * self.mgr.split_map_size
	--左下角
	local b_l_x = self.mgr.sceneCamCanMoveToPosTemp.x - self.mgr.halfScreenWidth - preload_offset
	local b_l_y = self.mgr.sceneCamCanMoveToPosTemp.y - self.mgr.halfScreenHeight - preload_offset
	b_l_x = b_l_x < 0 and 0 or b_l_x
	b_l_y = b_l_y < 0 and 0 or b_l_y

	--右上角
	local t_r_x = self.mgr.sceneCamCanMoveToPosTemp.x + self.mgr.halfScreenWidth + preload_offset
	local t_r_y = self.mgr.sceneCamCanMoveToPosTemp.y + self.mgr.halfScreenHeight + preload_offset
	t_r_x = t_r_x >= self.mgr.map_pixels_width and self.mgr.map_pixels_width - 1 or t_r_x
	t_r_y = t_r_y >= self.mgr.map_pixels_height and self.mgr.map_pixels_height - 1 or t_r_y

	local leftColumn = self:GetMapResPos(b_l_x)
	local rightColumn = self:GetMapResPos(t_r_x)

	local downRow = self:GetMapResPos(b_l_y)
	local upRow = self:GetMapResPos(t_r_y)

	local midColumn = self:GetMapResPos(self.mgr.sceneCamCanMoveToPosTemp.x)
	local midRow = self:GetMapResPos(self.mgr.sceneCamCanMoveToPosTemp.y)
	
	local screen_bottom_left_x = self:GetMapResPos(self.screen_bottom_left_pos.x)
	local screen_bottom_left_y = self:GetMapResPos(self.screen_bottom_left_pos.y)

	local screen_top_right_x = self:GetMapResPos(self.screen_top_right_pos.x)
	local screen_top_right_y = self:GetMapResPos(self.screen_top_right_pos.y)

	local row,column
	local offset = 1
	for res_id,map_item in pairs(list) do
		row,column = map_item:GetRowColumn()
		local is_del = false
		if column < leftColumn or column > rightColumn or
		row < downRow or row > upRow then
			dele_tab = dele_tab or {}
			dele_tab[#dele_tab+1] = res_id
			is_del = true
		end

		if not is_del then
			if is_show_all then
				map_item:SetVisible(true)
			elseif column < screen_bottom_left_x - offset or column > screen_top_right_x + offset or
			row < screen_bottom_left_y - offset or row > screen_top_right_y + offset then
				map_item:SetVisible(false)
			else
				map_item:SetVisible(true)
			end
		end
	end
	if not table.isempty(dele_tab) then
		for k,res_id in pairs(dele_tab) do
			list[res_id]:destroy()
			list[res_id] = nil
		end
	end
	
	local frametime = Time.time/Time.frameCount
	local center_circle = 1
	local count = 0
	local res_scene_id = self.mgr.ref_scene_id or scene_id

	local tab = {}
	local need_load_list = {}
	for row = downRow, upRow do
        for column = leftColumn, rightColumn do
        	local resId = row * split_maps_width + column
        	if not list[resId] then
	        	local order = math_max(math_abs(midColumn-column),math_abs(midRow-row))
	        	tab[order] = tab[order] or 0
	        	tab[order] = tab[order] + 1
	        	local x = column * self.mgr.split_map_size + self.mgr.split_map_size*0.5
            	local y = row * self.mgr.split_map_size + self.mgr.split_map_size*0.5
				need_load_list[#need_load_list + 1] = {resId = resId,order = order,index = tab[order],x=x,y=y,row = row,column = column}
			end
        end
    end
	
	local function SortFunc(a,b)
		if a.order == b.order then
			return a.index < b.index
		else
			return a.order < b.order
		end
	end
	table_sort(need_load_list,SortFunc)
    --print2(Table2String(need_load_list));
    --print2(#need_load_list);
    local isFirst = false;
    if not self.need_load_list then
        --print2("ijoi1e2o1nn12mknk1n2e1kn2ej21k3en1k2e" .. #need_load_list .. debug.traceback());
        self.need_load_list = need_load_list;
		self.has_load_map_count = 0
		self.all_load_map_count = table.nums(self.need_load_list)

		GlobalEvent.BrocastEvent(EventName.BLOCK_LOAD_FINISH,self.has_load_map_count,self.all_load_map_count)
        isFirst = true;
    end

	local len = #need_load_list
	for i=1,len do
		local info = need_load_list[i]
		local resId = info.resId
		local x = info.x
		local y = info.y
		local row = info.row
		local column = info.column


		local map_item = MapBlock()
        map_item.isFirst = isFirst;
		map_item:SetPosition(x,y,2000)
		local data = {
        	res_scene_id = res_scene_id,
        	scene_id = scene_id,
        	atlas_id = 1,
        	res_id = resId,
        	-- load_time = math_max(0,new_order) * frametime * 2,
        	load_time = 0,
			row = row,
			column = column,
        }
        map_item:SetData(data)
        list[resId] = map_item
	end
end

function MapLayer:AddLoadMapCount()
	-- MapLayer:GetInstance():AddLoadMapCount()
	self.has_load_map_count = self.has_load_map_count + 1
	GlobalEvent.BrocastEvent(EventName.BLOCK_LOAD_FINISH,self.has_load_map_count,self.all_load_map_count)
end

function MapLayer:GetMapResPos(num)
	return math_floor(num/self.mgr.split_map_size)
end

-- 弃用了
function MapLayer:AddCacheMapSprite(scene_id,res_id,sprite)
	self.map_cache_list[scene_id] = self.map_cache_list[scene_id] or {}
	self.map_cache_list[scene_id][res_id] = sprite
end

-- 弃用了
function MapLayer:GetCacheMapSprite(scene_id,res_id)
	return self.map_cache_list[scene_id] and self.map_cache_list[scene_id][res_id]
end

--弃用了
function MapLayer:ClearCacheMapSprite(scene_id)
	self.map_cache_list[scene_id] = nil
end

function MapLayer:ChangeSceneEnd()
	self.last_check_pos.x = -1
	self.last_check_pos.y = -1
	self.last_scene_id = self.cur_scene_id
	self.cur_scene_id = self.mgr.SceneId
	if self.last_scene_id then
		local list = self.scene_map_list[self.last_scene_id]
		if list then
			for resId,mapblock in pairs(list) do
				mapblock:destroy()
			end
			self.scene_map_list[self.last_scene_id] = nil
		end

		local object_list = self.scene_object_list[self.last_scene_id]
		if object_list then
			for k,tab in pairs(object_list) do
				self:ClearObjectState(tab)
			end
		end

		local last_scene_type = SceneConfigManager:GetInstance():GetSceneType(self.last_scene_id)
		local last_scene_is_city = last_scene_type == SceneConstant.SceneType.City or last_scene_type == SceneConstant.SceneType.Feild

		local cur_scene_id = SceneManager:GetInstance():GetSceneId()
		local cur_scene_type = SceneConfigManager:GetInstance():GetSceneType(cur_scene_id)
		local cur_scene_is_city = cur_scene_type == SceneConstant.SceneType.City or cur_scene_type == SceneConstant.SceneType.Feild
		if not last_scene_is_city or cur_scene_is_city == last_scene_is_city then
			self.map_cache_list[self.last_scene_id] = nil
		end
	end

	self.scene_object_list[self.cur_scene_id] = self.scene_object_list[self.cur_scene_id] or {}
	local object_list = self.scene_object_list[self.cur_scene_id]

	local npc_list = SceneConfigManager:GetInstance():GetSceneNpcList(self.cur_scene_id)
	local door_list = SceneConfigManager:GetInstance():GetSceneDoorList(self.cur_scene_id)
	local jump_list = SceneConfigManager:GetInstance():GetJumpPointList(self.cur_scene_id)
	local effect_list = SceneConfigManager:GetInstance():GetSceneEffectList(self.cur_scene_id)

	object_list[enum.ACTOR_TYPE.ACTOR_TYPE_NPC] = npc_list
	object_list[enum.ACTOR_TYPE.ACTOR_TYPE_PROTAL] = door_list
	object_list[enum.ACTOR_TYPE.ACTOR_TYPE_JUMP] = jump_list
	object_list[enum.ACTOR_TYPE.ACTOR_TYPE_EFFECT] = effect_list

	for k,tab in pairs(self.scene_object_list[self.cur_scene_id]) do
		self:ClearObjectState(tab)
	end

	local has_len = #self.sky_box_list
	for i=1,has_len do
		self.sky_box_list[i]:destroy()
		self.sky_box_list[i] = nil
	end

	-- EventName.DestroyLoading
	if LoadingCtrl:GetInstance().loadingPanel then
		self:StopSetSkyBoxTime()	
	else
		self:StartSetSkyBoxTime()
	end
end

function MapLayer:OnLoadingDestroy()
	self:StartSetSkyBoxTime()
end

function MapLayer:StartSetSkyBoxTime()
	self:StopSetSkyBoxTime()
	local function step()
		self:StopSetSkyBoxTime()
		self:SetSkyBox()
	end
	self.sky_box_time_id = GlobalSchedule:StartOnce(step,0)
end

function MapLayer:StopSetSkyBoxTime()
	if self.sky_box_time_id then
		GlobalSchedule:Stop(self.sky_box_time_id)
	end
	self.sky_box_time_id = nil
end

function MapLayer:SetSkyBox()
	local sky_box_cf = SkyBoxConfig[self.cur_scene_id]
	if sky_box_cf then
		local len = #sky_box_cf
		for i=1, len do
			local item = self.sky_box_list[i]
			if not item then
				item = MapSkyBox()
				self.sky_box_list[i] = item
			end
			item:SetData(sky_box_cf[i])
		end
	end
end

function MapLayer:AddNpc(scene_id,npc_id,x,y)
	scene_id = scene_id or self.cur_scene_id
	local cf = SceneConfigManager:GetInstance():GetSceneConfig(scene_id)
	if not cf then
		return
	end
	if cf.Npcs[npc_id] then
		return
	end
	cf.Npcs[npc_id] = {id=npc_id,x=x,y=y}
end

function MapLayer:RemoveNpc(scene_id,npc_id)
	scene_id = scene_id or self.cur_scene_id
	local cf = SceneConfigManager:GetInstance():GetSceneConfig(scene_id)
	if cf then
		cf.Npcs[npc_id] = nil
	end
	local object = SceneManager:GetInstance():GetObject(npc_id)
	if object then
		object:destroy()
	end
end

-- 动态加载的NPC
function MapLayer:UpdateNpc()
	self.scene_object_list[self.cur_scene_id] = self.scene_object_list[self.cur_scene_id] or {}
	local object_list = self.scene_object_list[self.cur_scene_id]
	local npc_list = SceneConfigManager:GetInstance():GetSceneNpcList(self.cur_scene_id)
	object_list[enum.ACTOR_TYPE.ACTOR_TYPE_NPC] = npc_list
	self:UpdateObject()
end

function MapLayer:ClearAllObjectState()
	for _,object_list in pairs(self.scene_object_list) do
		for k,tab in pairs(object_list) do
			self:ClearObjectState(tab)
		end
	end
end

function MapLayer:ClearObjectState(object_list)
	for k,v in pairs(object_list) do
		v.is_add_scene = false
	end
end

-- 是否在九宫格内
function MapLayer:IsInCamCan(x,y)
	if type(x) == "table" then
		local pos = x
		x = pos.x
		y = pos.y
	end
	if x < self.check_bottom_left_pos.x or y < self.check_bottom_left_pos.y 
	or x > self.check_top_rigth_pos.x or y > self.check_top_rigth_pos.y then
		return false
	end
	return true
end

-- 是否在屏幕内
function MapLayer:IsInScreen(x,y)
	if type(x) == "table" then
		local pos = x
		x = pos.x
		y = pos.y
	end

	if AppConfig.Debug then
		if type(x) == "string" or type(y) == "string" or type(self.screen_bottom_left_pos.x) == "string" or type(self.screen_bottom_left_pos.y) == "string"
		or type(self.screen_top_right_pos.x) == "string" or type(self.screen_top_right_pos.x) == "string" then
			print('--LaoY MapLayer.lua,line 448--',type(x),type(y),type(self.screen_bottom_left_pos.x),type(self.screen_bottom_left_pos.y),type(self.screen_top_right_pos.x),type(self.screen_top_right_pos.y))
		end
	end
	x = tonumber(x)
	y = tonumber(y)
	if x < self.screen_bottom_left_pos.x or y < self.screen_bottom_left_pos.y 
	or x > self.screen_top_right_pos.x or y > self.screen_top_right_pos.y then
		return false
	end
	return true
end