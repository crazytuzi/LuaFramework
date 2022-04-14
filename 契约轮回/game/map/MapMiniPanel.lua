--
-- @Author: LaoY
-- @Date:   2018-11-28 14:23:11
--
MapMiniPanel = MapMiniPanel or class("MapMiniPanel",BaseItem)
local MapMiniPanel = MapMiniPanel

function MapMiniPanel:ctor(parent_node,layer)
	self.abName = "map"
	self.assetName = "MapMiniPanel"
	self.layer = layer

	MapMiniPanel.super.Load(self)

	self.item_list = {}
	self.object_list = {}
	self.point_list = {}
	self.cfgObj_list = {}
	self.astar_path = nil
	self.scene_data = SceneManager:GetInstance():GetSceneInfo()
end

function MapMiniPanel:dctor()
	self:CloseMonsterInfoPanel()
	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end

	if self.scene_data_event_1 then
		self.scene_data:RemoveListener(self.scene_data_event_1)
	end

	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}

	for k,item in pairs(self.object_list) do
		item:destroy()
	end
	self.object_list = {}

	for k,item in pairs(self.point_list) do
		destroy(item.gameObject)
	end
	self.point_list = {}

	for k,item in pairs(self.cfgObj_list) do
		destroy(item.gameObject)
	end
	self.cfgObj_list = {}


	if self.main_role_item then
		self.main_role_item:destroy()
		self.main_role_item = nil
	end
end

function MapMiniPanel:LoadCallBack()
	self.nodes = {
		"img_bg","text_title","btn_line/text_line","img_line_2_1","btn_line","btn_go","scroll","scroll/Viewport/Content","MapMiniItem","MapMiniIcon",
		"img_bg/im_end_icon","img_bg/im_path_icon","img_bg/mini_map",
	}
	self:GetChildren(self.nodes)
	self.text_title_component = self.text_title:GetComponent('Text')
	self.text_line_component = self.text_line:GetComponent('Text')
	self.img_bg_component = self.img_bg:GetComponent('Image')

	self.mini_map_component = self.mini_map:GetComponent('Image')
	--local x,y = GetGlobalPosition(self.mini_map)
	--self.mini_map_pos = {x = x*SceneConstant.PixelsPerUnit + ScreenWidth*0.5,y = y*SceneConstant.PixelsPerUnit + ScreenHeight*0.5}
	local parent_x,parent_y = GetLocalPosition(self.img_bg)
	local x,y = GetLocalPosition(self.mini_map)
	self.mini_map_pos = {x = parent_x+x+ ScreenWidth*0.5,y = parent_y+y+ ScreenHeight*0.5}
  
	SetVisible(self.MapMiniItem,false)
	SetVisible(self.MapMiniIcon,false)

	SetVisible(self.im_path_icon,false)
	SetVisible(self.im_end_icon,false)

	self.res_width = GetSizeDeltaX(self.img_bg)
	self.res_height = GetSizeDeltaY(self.img_bg)
	
	SetVisible(self.btn_go,false)

	self:AddEvent()
	
	self:SetData()

	self.main_role_item = MapMiniIcon(self.MapMiniIcon.gameObject,self.img_bg)
	self.main_role_item:SetData({type = enum.ACTOR_TYPE.ACTOR_TYPE_ROLE})
	self:UpdateRolePosition()
	self:UpdateAStarPath()
end

function MapMiniPanel:OnDisable()
	self:CloseMonsterInfoPanel()
end

function MapMiniPanel:AddEvent()
	local function call_back(target,x,y)
		x,y = ScreenToViewportPosition(x,y)
		local half_w = self.mini_res_width * 0.5
		local half_h = self.mini_res_height * 0.5
		if x < self.mini_map_pos.x - half_w or x > self.mini_map_pos.x + half_w or 
			y < self.mini_map_pos.y - half_h or y > self.mini_map_pos.y + half_h then
			return
		end
		local new_x = x - (self.mini_map_pos.x - half_w)
		new_x = new_x * self.adaption_rate
		local new_y = y - (self.mini_map_pos.y - half_h)
		new_y = new_y * self.adaption_rate
		self.touch_icon_pos = {x = new_x,y=new_y}
		self.touch_icon_id = nil
		self:MoveToPosition()
		self:CloseMonsterInfoPanel()
	end
	AddClickEvent(self.mini_map.gameObject,call_back)

	local function call_back(target,x,y)
		if self.isCfg then
			local end_pos = {x=self.touch_icon_pos.x,y=self.touch_icon_pos.y}
			local function call_back()
				if not AutoFightManager:GetInstance():GetAutoFightState() then
					GlobalEvent:Brocast(FightEvent.AutoFight)
				end
			end
			local bo = OperationManager:GetInstance():TryMoveToPosition(self.scene_id,nil,end_pos,call_back,100)
			if bo then
				AutoFightManager:GetInstance():StopAutoFight()
			end
		else
			self:MoveToPosition()
		end

		self:CloseMonsterInfoPanel()
	end
	AddClickEvent(self.btn_go.gameObject,call_back)

	local function call_back(target,x,y)
		lua_panelMgr:GetPanelOrCreate(MapLinePanel):Open()
	end
	AddClickEvent(self.btn_line.gameObject,call_back)

	local function call_back()
		self:UpdateInfo()
	end
	self.scene_data_event_1 = self.scene_data:BindData("line", call_back)

	local function call_back(x,y,block_pos_x,block_pos_y)
		self:UpdateRolePosition(x,y)
	end
	self.global_event_list = self.global_event_list or {}
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(SceneEvent.MainRolePos, call_back)

	local function call_back(id,pos,is_find_way,isCfg,index)
		if not self.touch_icon_pos then
			self.touch_icon_pos = {}
		end
		self.touch_icon_id = id
		self.touch_icon_pos.x = pos.x
		self.touch_icon_pos.y = pos.y
		self.isCfg = isCfg

		if isCfg then
			local end_pos = {x=pos.x,y=pos.y}
			--AutoFightManager:GetInstance():StopAutoFight()
			--SceneManager:GetInstance():AttackCreepByTypeId(id,true)
			local function call_back()
				if not AutoFightManager:GetInstance():GetAutoFightState() then
					GlobalEvent:Brocast(FightEvent.AutoFight)
			end
			end
			if is_find_way then
				local bo = OperationManager:GetInstance():TryMoveToPosition(self.scene_id,nil,end_pos,call_back,100)
				if bo then
					AutoFightManager:GetInstance():StopAutoFight()
				end
			end
			self:SelectCfgIcon(index)
			return
		end



		local item = self.object_list[id]
		if not item then
			return
		end
		local object_type = item.data.type
		if object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP and not is_find_way then
			local afk_map_config = DailyModel:GetInstance():GetHookConfigByid(id)
			if afk_map_config then
				local x,y = item:GetGlobalPosition()
				lua_panelMgr:OpenPanel(MapMonsterInfoPanel,id,x,y)
			end
		else
			self:CloseMonsterInfoPanel()
		end
		self:SelectIcon(id)
		if is_find_way then
			SetVisible(self.btn_go,false)
			self:MoveToPosition()
		else
			SetVisible(self.btn_go,true)
		end
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(MainEvent.MapTouchIcon, call_back)

	local function call_back(path)
		self.astar_path = path
		self:UpdateAStarPath()
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(SceneEvent.FIND_WAY_START, call_back)

	local function call_back()
		self.astar_path = nil
		self:UpdateAStarPath()
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(SceneEvent.FIND_WAY_END, call_back)

	local function call_back(SceneId)
		self.astar_path = nil
		self:SetData(SceneId)
		SetVisible(self.btn_go,false)
		self:UpdateRolePosition()
		self:UpdateAStarPath()
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)
end

function MapMiniPanel:CloseMonsterInfoPanel()
	lua_panelMgr:ClosePanel(MapMonsterInfoPanel)
end

function MapMiniPanel:MoveToPosition()
	if not self.touch_icon_pos then
		return
	end
	local item = self.object_list[self.touch_icon_id]
	local touch_icon_id = self.touch_icon_id
	local object_type
	if item then
		object_type = item.data.type
	end
	local callback
	local dis_range
	if object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
		-- dis_range = 100
		-- callback = function()
		-- 	local creep_object = SceneManager:GetInstance():GetCreepByTypeId(touch_icon_id)
		-- 	if creep_object then
		-- 		creep_object:OnClick()
		-- 	end
		-- end
		AutoFightManager:GetInstance():StopAutoFight()
		SceneManager:GetInstance():AttackCreepByTypeId(touch_icon_id,true)
		return
	elseif object_type == enum.ACTOR_TYPE.ACTOR_TYPE_NPC then
		-- callback = function()
		-- 	local npc_object = SceneManager:GetInstance():GetObject(touch_icon_id)
		-- 	if npc_object then
		-- 		npc_object:OnClick()
		-- 	end
		-- end
		-- dis_range = SceneConstant.NPCRange * 0.5
		AutoFightManager:GetInstance():StopAutoFight()
		SceneManager:GetInstance():FindNpc(touch_icon_id)
		return
	end
	local end_pos = {x=self.touch_icon_pos.x,y=self.touch_icon_pos.y}
	local bo = OperationManager:GetInstance():TryMoveToPosition(self.scene_id,nil,end_pos,callback,dis_range)
	if bo then
		AutoFightManager:GetInstance():StopAutoFight()
	end
end

function MapMiniPanel:UpdateInfo()
	if not self.is_loaded then
		return
	end
	if self.scene_data then
		self.text_line_component.text = "Line"..(self.scene_data.line or 1)
	end
end

function MapMiniPanel:SetData(scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	if self.scene_id == scene_id then
		return
	end
	if not self.is_loaded then
		return
	end
	self.scene_id = scene_id
	self:UpdateInfo()
	local config = SceneConfigManager:GetInstance():GetSceneConfig(scene_id)
	self.scene_width = config.SceneMap.scene_width
	self.scene_height = config.SceneMap.scene_height

	if self.scene_width == 0 or self.scene_height == 0 then
		if AppConfig.Debug then
			logError(string.format("场景配置%s.lua 的宽 = %s 高 = %s ",scene_id,self.scene_width,self.scene_height))
		end
	end

	local scene_type = SceneConfigManager:GetInstance():GetSceneType(scene_id)
	self.scene_type = scene_type
	local show_list
	local title
	local npc_list = SceneConfigManager:GetInstance():GetSceneNpcList(scene_id)
	--local monster_list = SceneConfigManager:GetInstance():GetMonsterWithoutCollect(scene_id)
	local sceneConfig = Config.db_scene[scene_id]
	self.sceneType = sceneConfig.stype 
	
	local monster_list
    local spawn_List
	if (self.sceneType == enum.SCENE_STYPE.SCENE_STYPE_GUILD_WAR) then
		monster_list = SceneConfigManager:GetInstance():GetMonsterList(scene_id)
        spawn_List = FactionBattleModel.GetInstance():GetSpawnList()
	else
		monster_list = SceneConfigManager:GetInstance():GetMonsterWithoutCollect(scene_id)
	end
	
	local door_list = SceneConfigManager:GetInstance():GetSceneDoorList(scene_id)


	self.npc_list = npc_list
	self.monster_list = monster_list
	self.door_list = door_list
    if (spawn_List) then
        self.spawn_List = spawn_List
    end

	self:UpdateObjectList()

	local res_id = MapManager:GetInstance().ref_scene_id or scene_id
	self:LoadMiniRes(res_id)

	if scene_type == SceneConstant.SceneType.City then
		show_list = npc_list
		SetVisible(self.img_line_2_1,true)
		self.text_title_component.text = "NPC"
	else
		show_list = monster_list
		SetVisible(self.img_line_2_1,false)
		self.text_title_component.text = "Premium farming spot"
		local scenecfg = Config.db_scene[self.scene_id]
		if scenecfg  then
			local tab = String2Table(scenecfg.minimap_icon)
			if not table.isempty(tab) then
				for i = 1,#tab do
					local cfg = Config.db_creep[tab[i][1]]
					local data = {}
					data["coord"] = {x = tab[i][2],y = tab[i][3]}
					data.gen_type = 1
					data.id = tab[i][1]
					data.level = cfg.level
					data.type = 2
					data.uid = tab[i][1]
					data.index = i
					data.isCfg = true
					table.insert(show_list,data)
				end

			end
		end
	end

	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}

	if not table.isempty(show_list) then
		local height = 70
		local content_height = height * #show_list
		SetSizeDeltaY(self.Content,content_height)
		local function callback(index)
			for k,item in pairs(self.item_list) do
				item:SetSelectState(index)
			end
		end
		for i=1, #show_list do
			local item = self.item_list[i]
			if not item then
				item = MapMiniItem(self.MapMiniItem.gameObject,self.Content)
				self.item_list[i] = item
				local x = 130
				local y = -(i - 0.5) * height
				item:SetPosition(x, y)
				item:SetCallBack(callback)
			end
			item:SetData(i,show_list[i])
		end

		if scene_type == SceneConstant.SceneType.City or scene_type == SceneConstant.SceneType.Dungeon then
			if #show_list > 0 then
				local item = self.item_list[1]
				if item then
					item:OnClick()
				end
			end
		else
			if #show_list > 0 then
				local level = RoleInfoModel:GetInstance():GetRoleValue("level") or 0
				local right_index
				local right_lv
				for k,v in pairs(show_list) do
					local cf = Config.db_creep[v.id]
					if cf then
						if cf.level == level then
							right_index = k
							right_lv = cf.level
							break
						end
						if not right_index then
							right_lv = cf.level
							right_index = k
						end

						local cur_abs_lv = math.abs(level - right_lv)
						local new_abs_lv = math.abs(level - cf.level)
						if  new_abs_lv < cur_abs_lv then
							right_lv = cf.level
							right_index = k
						elseif new_abs_lv == cur_abs_lv and cf.level > right_lv then
							right_lv = cf.level
							right_index = k
						end
					end
					
				end
				if right_index then
					local item = self.item_list[right_index]
					if item then
						item:OnClick()
					end
				end
			end
		end
	end
end

function MapMiniPanel:LoadMiniRes(res)
	if self.res == res then
		return
	end
	self.res = res
	local function call_back(sprite)
		self.mini_map_component.sprite = sprite
		-- SetSizeDelta(self.mini_map,self.mini_res_width,self.mini_res_height)
	end
    lua_resMgr:SetImageTexture(self,self.mini_map_component, "iconasset/icon_minimap_"..res, tostring(res),false)
end

function MapMiniPanel:DeleteObjectList()
	for _,item in pairs(self.object_list) do
		item:destroy()
	end
	self.object_list = {}
end

function MapMiniPanel:UpdateObjectList()
	local widht_rate = self.scene_width/self.res_width
	local height_rate = self.scene_height/self.res_height
	self.is_adaption_width =  widht_rate < height_rate
	self.adaption_rate = math.max(widht_rate,height_rate)
	if self.adaption_rate == 0 then
		self.adaption_rate = 1
	end
	self.mini_res_width = self.scene_width/self.adaption_rate
	self.mini_res_height = self.scene_height/self.adaption_rate

	for k,item in pairs(self.object_list) do
		item:destroy()
	end
	self.object_list = {}

	self:UpdateObject(self.npc_list)
	self:UpdateObject(self.monster_list)
	self:UpdateObject(self.door_list)
	self:UpdateCfgObject()
	--self.scene_id
    if (self.spawn_List) then
        self:UpdateObject(self.spawn_List)
    end
end

function MapMiniPanel:SelectIcon(id)
	for k,item in pairs(self.object_list) do
		item:SelectIcon(id)
	end
end

function MapMiniPanel:SelectCfgIcon(index)
	for k,item in pairs(self.cfgObj_list) do
		item:SelectCfgIcon(index)
	end
end

function MapMiniPanel:UpdateCfgObject()
	local scenecfg = Config.db_scene[self.scene_id]
	if scenecfg  then
		local tab = String2Table(scenecfg.minimap_icon)
		if not table.isempty(tab) then
			for i = 1, #tab do
				local item = self.cfgObj_list[i]
				if not item then
					item = MapMiniIcon(self.MapMiniIcon.gameObject,self.img_bg)
					local x,y = self:ChangeScenePosToMiniPos(tab[i][2],tab[i][3])
					item:SetPosition(x,y)
					self.cfgObj_list[i] = item
				end
				local data = {}
				data["coord"] = {x = tab[i][2],y = tab[i][3]}
				data.gen_type = 1;
				data.type = enum.ACTOR_TYPE.ACTOR_TYPE_CREEP
				data.uid = tab[i][1];
				data.isCfg = true;
				item:SetData(data, self.sceneType,self.scene_type,i)
			end
		end
	end
end

function MapMiniPanel:UpdateObject(object_list)
	for i=1,#object_list do
		local data = object_list[i]
		local item = self.object_list[data.uid]
		if not item then
			item = MapMiniIcon(self.MapMiniIcon.gameObject,self.img_bg)
			local x,y = self:ChangeScenePosToMiniPos(data.coord.x,data.coord.y)
			item:SetPosition(x,y)
			self.object_list[data.uid] = item
		end
		item:SetData(data, self.sceneType,self.scene_type)
	end
	if self.main_role_item then
		self.main_role_item.transform:SetAsLastSibling()
	end
end

function MapMiniPanel:UpdateAStarPath()
	local move_operation = OperationManager:GetInstance().move_operation
	local astar_path
	
	if move_operation and move_operation:IsAutoWay() then
		-- astar_path = {move_operation.cur_way}
		astar_path = move_operation.all_path
	else
		astar_path = self.astar_path
	end
	if table.isempty(astar_path) then
		for k,item in pairs(self.point_list) do
			if item.isVisible then
				item.isVisible = false
				SetVisible(item.gameObject,false)
			end
		end
		if self.im_end_icon_visible then
			SetVisible(self.im_end_icon,false)
			self.im_end_icon_visible = false
		end
		return
	end
	local offset = 200
	local length = #astar_path
	local index = 0
	for i=length,2,-1 do
		local start_pos
		local cur_pos = astar_path[i]
		if i == 1 then
			-- start_pos = self.main_role_pos
			start_pos = cur_pos[i]
		else
			start_pos = astar_path[i-1]
		end
		local distance = Vector2.Distance(start_pos,cur_pos)
		local vec = GetVector(start_pos,cur_pos)
	    vec:SetNormalize()
		local dis = 0
		while true do
			index = index + 1
			local item = self.point_list[index]
			if not item then
				item = {gameObject = true,transform = true,isVisible = true}
				item.gameObject = newObject(self.im_path_icon.gameObject)
				item.transform = item.gameObject.transform
				item.transform:SetParent(self.img_bg)

				SetLocalScale(item.transform , 1, 1, 1)
				SetLocalRotation(item.transform,0,0,0)
				SetVisible(item.gameObject,true)
				self.point_list[index] = item
			else
				if not item.isVisible then
					item.isVisible = true
					SetVisible(item.gameObject,true)
				end
			end
			item.transform:SetAsLastSibling()
			local x = start_pos.x + vec.x * dis
			local y = start_pos.y + vec.y * dis
			x,y = self:ChangeScenePosToMiniPos(x,y)
			SetLocalPositionXY(item.transform,x,y)
			if dis >= distance then
				break
			end
			dis = math.min(dis+offset,distance)
		end
	end

	local point_count = #self.point_list
	for i=index,point_count do
		local item = self.point_list[i]
		if item.isVisible then
			SetVisible(item.gameObject,false)
			item.isVisible = false
		end
	end

	if not self.im_end_icon_visible then
		SetVisible(self.im_end_icon,true)
		self.im_end_icon_visible = true
	end
	local pos = astar_path[length]
	local x,y = self:ChangeScenePosToMiniPos(pos.x,pos.y)
	SetLocalPositionXY(self.im_end_icon,x,y)
	-- self.im_end_icon:SetAsFirstSibling()
	self.im_end_icon:SetAsLastSibling()
end

function MapMiniPanel:ChangeScenePosToMiniPos(x,y)
	if not self.adaption_rate or not self.mini_res_width or not self.mini_res_height then
		return x,y
	end
	local new_x = x/self.adaption_rate - self.mini_res_width*0.5
	local new_y = y/self.adaption_rate - self.mini_res_height*0.5
	return new_x,new_y
end

function MapMiniPanel:UpdateRolePosition(x,y)
	if not self.main_role_item then
		return
	end
	if not x or not y then
		local main_role = SceneManager:GetInstance():GetMainRole()
		if not main_role then
			return
		end
		local pos = main_role:GetPosition()
		x = pos.x
		y = pos.y
	end
	if not self.main_role_pos then
		self.main_role_pos = {x = x,y = y}
	else
		self.main_role_pos.x = x
		self.main_role_pos.y = y
	end
	x,y = self:ChangeScenePosToMiniPos(x,y)
	self.main_role_item:SetPosition(x,y)

	-- self:UpdateAStarPath()
end