HomeModel = HomeModel or BaseClass(BaseModel)

function HomeModel:__init()
	self.editType = false
	self.previewType = false

	self.window = nil
	self.petTrainWindow = nil
	self.createHomeWindow = nil
	self.getHomeWindow = nil
	self.visitHomeWindow = nil
	self.magicBeenPanel = nil
	self.inviteMagicBeenWindow = nil
	self.furnitureListWindow = nil

	self.editPanel = nil
	self.mapArea = nil
	self.homeFloor = nil

	self.home_lev = 1 -- 家园等级
	self.home_name = "" -- 家园名字
	self.master_name = "" -- 主人名字
	self.visit_lock = 1 -- 权限(1 所有 2 好友 3 公会 4好友与公会 5 关闭)
	self.updateVisitTime = 0 -- 上次更新好友、公会家园列表时间
	self.cleanness = 0 -- 清洁度
	self.housekeeper_action_times = 0 -- 管家劳动次数
	self.env_val = 0 -- 繁华度
    self.bean_data = nil -- 豌豆数据
    self.warehouse_original_list = {} -- 仓库原始数据列表，这里按照baseid和主人id堆叠
	self.warehouse_list = {} -- 仓库列表，这里按照baseid堆叠
	self.furniture_list = {} -- 家具列表

	self.build_list = {} -- 建筑列表

    self.shop_datalist = {} -- 家具商店数据

    self.effect_list = {} -- 家具建筑效果
    self.use_info = {} -- 建筑使用次数信息
    self.train_info = {} -- 宠物训练信息

    self.home_friend_list = {} -- 好友家园信息列表
	self.home_guild_list = {} -- 公会成员家园信息列表

    self.home_bean_info = nil

	self.fid = 0 --家园id
	self.platform = "" --平台标识
	self.zone_id = 0 --区号
	self.map_id = 0 --地图id
	self.floor_data = nil --地板数据

	self.eidtIndex = 1 -- 编辑家具的临时id，每编辑一个家具加一

	self.zoomValue = { 1.2, SceneManager.Instance.DefaultCameraSize, 2.5}
    self.zoomIndex = 2
    self.zooming = false

    self.mapGrid = {}

    self.confirmMark = true
    -- 初级地图的窗帘区域
 	-- 170,874 170,637 1140,390 1140,150
	-- 1170,150  1170,390  2130,631 2130,870
	------------------------------------------------
	-- 300,1096 300,854  1650,420  1650,180
	-- 中级级地图的窗帘区域
	-- 300,1096 300,854  1650,420  1650,180
	-- 1770,420 1770,180  3106,1090 3106,846

	-- self.wallArea = { {{315,878}, {1925,52}, {315,1152}, {1925,339}}, {{2046,56}, {3645,855}, {2046,330}, {3645,1141}} } -- 家园没换地图前的数据，参考用
	self.wallArea = {
		[30012] = { {{170,637}, {1140,150}, {170,874}, {1140,390}}, {{1170,150}, {2130,631}, {1170,390}, {2130,870}} }
		, [30013] = { {{300,854}, {1650,180}, {300,1096}, {1650,420}}, {{1770,180}, {3106,846}, {1770,420}, {3106,1090}} }
	}

	-- 1545,1215  1613, 1272 1881,1146  1815,1091 初始地图 1560,1230,   1680,1290,  1680,1200,  1770,1140, 1800,1260,  1920,1200
	-- 2295,1579 2388,1666  2653,1400  2740,1479  中级地图 2310,1590,   2490,1680,   2460,1530,   2640,1620,  2610,1470,  2760,1530
	self.teleporterArea = {
		[30012] = { 1559,1223,  1700,1281, 1680,1180,  1800,1240, 1760,1120,  1900,1200 }
		, [30013] = { 2300, 1573, 2480,1680,    2460,1540,  2640,1620,  2560,1480,  2760,1540 }
	}

	self.type_list = { {3, 5, 12, 6}, {10, 8, 7}, {9, 13}, {11, 1, 2, 14, 4}, {15, 16} }

	self.furniture_type_list = {
		{ name =   TI18N("屏风"), type = { 1, 2 } }
		, { name = TI18N("沙发"), type = { 3 } }
		, { name = TI18N("桌子"), type = { 5, 12 } }
		, { name = TI18N("椅子"), type = { 6 } }
		, { name = TI18N("柜子"), type = { 7, 8 } }
		, { name = TI18N("窗帘"), type = { 9 } }
		, { name = TI18N("床"), type = { 10 } }
		, { name = TI18N("宠物室"), type = { 11 } }
		, { name = TI18N("地板"), type = { 15 } }
		, { name = TI18N("地毯"), type = { 16 } }
		, { name = TI18N("装饰"), type = { 4, 14} }
		, { name = TI18N("墙饰"), type = { 13 } }
	}

	-- 记录未建筑引导是否播过
	self.isGuidePlay = false
end

function HomeModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end


function HomeModel:OpenWindow(args)
    if self.window == nil then
        self.window = HomeWindow.New(self)
    end
    self.window:Open(args)
end

function HomeModel:CloseWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function HomeModel:OpenPetTrainWindow(args)
    if self.petTrainWindow == nil then
        self.petTrainWindow = HomePetTrainView.New(self)
    end
    self.petTrainWindow:Open(args)
end

function HomeModel:ClosePetTrainWindow()
    if self.petTrainWindow ~= nil then
        self.petTrainWindow:DeleteMe()
        self.petTrainWindow = nil
    end
end

function HomeModel:OpenShopWindow(args)
    if self.shopwindow == nil then
        self.shopwindow = HomeWindow_FurnitureShop.New(self)
    end
    self.shopwindow:Open(args)
end

function HomeModel:CloseShopWindow()
    if self.shopwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.shopwindow)
    end
end

function HomeModel:OpenCreateHomeWindow(args)
    if self.createHomeWindow == nil then
        self.createHomeWindow = CreateHomeView.New(self)
    end
    self.createHomeWindow:Open(args)
end

function HomeModel:CloseCreateHomeWindow()
    if self.createHomeWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.createHomeWindow)
    end
end

function HomeModel:OpenGetHomeWindow(args)
    if self.getHomeWindow == nil then
        self.getHomeWindow = GetHomeView.New(self)
        self.getHomeWindow.callback = function()
        		self:CloseGetHomeWindow()
        		if args == nil then HomeManager.Instance:EnterHome() end
    		end
    end
    self.getHomeWindow:Show(args)
end

function HomeModel:CloseGetHomeWindow()
    if self.getHomeWindow ~= nil then
        -- WindowManager.Instance:CloseWindow(self.getHomeWindow)
        self.getHomeWindow:DeleteMe()
        self.getHomeWindow = nil
    end
end

function HomeModel:OpenVisitHomeWindow(args)
	if self.visitHomeWindow == nil then
        self.visitHomeWindow = VisitHomeWindow.New(self)
    end
    self.visitHomeWindow:Open(args)
end

function HomeModel:CloseVisitHomeWindow()
    if self.visitHomeWindow ~= nil then
        self.visitHomeWindow:DeleteMe()
        self.visitHomeWindow = nil
    end
end


function HomeModel:OpenBeanInviteWindow(args)
    if self.beaninvitewindow == nil then
        self.beaninvitewindow = MagicBeanInviteWindow.New(self)
    end
    self.beaninvitewindow:Open(args)
end

function HomeModel:CloseBeanInviteWindow()
    if self.beaninvitewindow ~= nil then
        self.beaninvitewindow:DeleteMe()
        self.beaninvitewindow = nil
    end
end


function HomeModel:OpenMagicBeenPanel(args)
	if self.magicBeenPanel == nil then
        self.magicBeenPanel = MagicBeenPanel.New(self)
    end
    self.magicBeenPanel:Open(args)
end

function HomeModel:CloseMagicBeenPanel()
	if self.magicBeenPanel ~= nil then
        self.magicBeenPanel:DeleteMe()
        self.magicBeenPanel = nil
    end
end

function HomeModel:OpenInviteMagicBeenWindow(args)
	if self.inviteMagicBeenWindow == nil then
        self.inviteMagicBeenWindow = InviteMagicBeenWindow.New(self)
    end
    self.inviteMagicBeenWindow:Open(args)
end

function HomeModel:CloseInviteMagicBeenWindow()
    if self.inviteMagicBeenWindow ~= nil then
        self.inviteMagicBeenWindow:DeleteMe()
        self.inviteMagicBeenWindow = nil
    end
end

function HomeModel:OpenFurnitureListWindow(args)
	if self.furnitureListWindow == nil then
        self.furnitureListWindow = FurnitureListWindow.New(self)
    end
    self.furnitureListWindow:Open(args)
end

function HomeModel:CloseFurnitureListWindow()
    if self.furnitureListWindow ~= nil then
        self.furnitureListWindow:DeleteMe()
        self.furnitureListWindow = nil
    end
end
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
function HomeModel:ShowEditPanel()
	self.editType = true
    if self.editPanel == nil then
        self.editPanel = HomeEditPanel.New(self)
    else
    	self.editPanel:Show()
    end
	HomeManager.Instance:ShowOtherUI()
    self:UpdateMapButton()
    SceneManager.Instance.sceneElementsModel:Show_Npc(false)
end

function HomeModel:ShowUsePanel()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.home_window, {1})
end

function HomeModel:HideEditPanel()
	self.editType = false
    if self.editPanel ~= nil then
    	self.editPanel:Hide()
    end
    HomeManager.Instance:ShowOtherUI()
    self:UpdateMapButton()
    SceneManager.Instance.sceneElementsModel:Show_Npc(true)
end

function HomeModel:DeleteEditPanel()
	self:HideEditPanel()
    if self.editPanel ~= nil then
    	self.editPanel:DeleteMe()
    	self.editPanel = nil
    end
end

function HomeModel:ShowMapArea()
    if self.mapArea == nil then
        self.mapArea = HomeMapArea.New(self)
    else
    	self.mapArea:ShowCanvas(true)
    	self.mapArea:update()
    end
end

function HomeModel:HideMapArea()
    if self.mapArea ~= nil then
    	self.mapArea:ShowCanvas(false)
    end
end

function HomeModel:DeleteMapArea()
    if self.mapArea ~= nil then
    	self.mapArea:DeleteMe()
    	self.mapArea = nil
    end
end

function HomeModel:UpdateMapButton()
    if self.mapArea ~= nil then
    	self.mapArea:update_button()
    end
end

function HomeModel:ShowFloor()
    if self.homeFloor == nil then
        self.homeFloor = HomeFloor.New(self)
        self.homeFloor:SetFloor()
    else
    	self.homeFloor:SetFloor()
    	self.homeFloor:ShowCanvas(true)
    end
end

function HomeModel:HideFloor()
    if self.homeFloor ~= nil then
    	self.homeFloor:ShowCanvas(false)
    end
end

---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
-- 是否有家园控制权限
function HomeModel:CanEditHome()
	local roleData = RoleManager.Instance.RoleData
	return self.unique_roleid == BaseUtils.get_unique_roleid(roleData.fid, roleData.family_zone_id, roleData.family_platform)
end

-- 初始化仓库与家园场景的物品
function HomeModel:SetFurnishings(furnishings)
	local list1 = {}
	local list2 = {}
	for _,value in ipairs(furnishings) do
		local base = DataFamily.data_unit[value.base_id]
		if base ~= nil then
			value.base = base
			if value.status == 1 then
				local key = string.format("%s_%s_%s_%s", value.base_id, value.rid, value.platform, value.zone_id)
				if list1[key] == nil then
					list1[key] = value
				else
					list1[key].num = list1[key].num + value.num
				end
			elseif value.status == 2 or value.status == 3 then
				value.battle_id = 998 -- 强制复制battle_id为 998
				table.insert(list2, value)
			end
		end
	end

	return list1, list2
end

-- 更新仓库的家具，从原始数据堆叠成显示数据
function HomeModel:UpdateWarehouse()
	-- BaseUtils.dump(self.warehouse_original_list)
	local roleData = RoleManager.Instance.RoleData
	self.warehouse_list = {}
	local list = {}
	for _, value in pairs(self.warehouse_original_list) do
		if list[value.base_id] == nil then
			list[value.base_id] = BaseUtils.copytab(value)
		else
			list[value.base_id].num = list[value.base_id].num + value.num
			local tab = list[value.base_id]
			if tab.rid ~= roleData.id or tab.platform ~= roleData.platform or tab.zone_id ~= roleData.zone_id then
				tab.rid = roleData.id
				tab.platform = roleData.platform
				tab.zone_id = roleData.zone_id
			end
		end
	end

	for _, value in pairs(list) do
		table.insert(self.warehouse_list, value)
	end
	-- BaseUtils.dump(self.warehouse_list)
end

-- 获取仓库中该类型的家具
function HomeModel:GetWarehouseByType(type)
	local list = {}
	for _,value in ipairs(self.warehouse_list) do
		if value.status == 1 then
			if table.containValue(self.type_list[type], value.base.type) then
				table.insert(list, value)
			end
		elseif value.status == 2 or value.status == 3 then

		end
	end
	return list
end

-- 获取该类型的全部家具
function HomeModel:GetAllByType(type)
	local warehouse_list = self:GetWarehouseByType(type)
	local list = {}
	for _,value in pairs(DataFamily.data_unit) do
		if table.containValue(self.type_list[type], value.type) then
			local furniture = nil
			for __,value2 in ipairs(warehouse_list) do
				if value2.base_id == value.id then
					furniture = value2
					break
				end
			end
			if furniture == nil then
				table.insert(list, { base_id = value.id, base = BaseUtils.copytab(value), num = 0 })
			else
				table.insert(list, furniture)
			end
		end
	end

	local function sortfun(a,b)
        return a.num > b.num
    end
	table.sort(list, sortfun)

	return list
end

-- 获取仓库中的物品，item_id 物品id
function HomeModel:GetFurnitureByItemId(item_id)
	for _,value in ipairs(self.warehouse_list) do
		if value.base.item_id == item_id then
			return value
		end
	end
	return nil
end

-- 获取该id的地板模型信息
function HomeModel:GetFloorData(id, list)
	local skin = nil
	for k, v in ipairs(list) do
		if v.id == id then
			local data_unit = DataFamily.data_unit[v.base_id]
			if data_unit ~= nil then
				skin = data_unit.skin
				break
			end
		end
	end

	local floor_data = DataFamily.data_floor_data[self.home_lev]
	if skin == nil or floor_data == nil then return end
	return { skin = skin, res = floor_data.res }
end

-- 是否可行走
function HomeModel:Walkable(gx, gy)
    if gx >= ctx.sceneManager.Map.Collumn or gy >= ctx.sceneManager.Map.Row then return false end
    if gx <= 0 or gy <= 0 then return false end

    -- local pathNode = ctx.sceneManager.Map.Grid[gx][gy]
    -- if pathNode.Status ~= 1 then
    --     return true
    -- end
    local pathNode = self.mapGrid[string.format("%s_%s", gx-1, gy)]
    if pathNode ~= 1 then
    	return true
    end

    return false
end

function HomeModel:GetMapGridByX(tx)
	local  v = math.floor(math.floor(tx / SceneManager.Instance.Mapsizeconvertvalue + 0.5) / ctx.sceneManager.Map.GridWidth + 0.5)
	if v < 1 then
	    v = 1
	end

	if v > ctx.sceneManager.Map.Collumn - 1 then
	    v = ctx.sceneManager.Map.Collumn - 1
	end

	return v
end

function HomeModel:GetMapGridByY(ty)
	local v = math.floor(math.floor(ty / SceneManager.Instance.Mapsizeconvertvalue + 0.5) / ctx.sceneManager.Map.GridHeight + 0.5)
	if v < 1 then
	    v = 1
	end

	if v > ctx.sceneManager.Map.Row - 1 then
	    v = ctx.sceneManager.Map.Row - 1
	end

	return v
end

function HomeModel:InitMapGrid()
	self.mapGrid = {}
    local grid = ctx.sceneManager.Map.Grid
    for i=1,ctx.sceneManager.Map.Collumn do
        for j=0,ctx.sceneManager.Map.Row-1 do
            self.mapGrid[string.format("%s_%s", i-1, j)] = grid[i][j].Status
        end
    end
end

function HomeModel:UpdateMapGrid(map_data)
	if SceneManager.Instance:CurrentMapId() == map_data.base_id then
	    local flag = map_data.flag
	    for _,value in ipairs(map_data.pos) do
	        self.mapGrid[string.format("%s_%s", value.x, value.y)] = flag
	    end
	end
end

-- 是否在墙面上
function HomeModel:IsInRect(pos_list, dir)
	local inRect = true
	local i = 1
	if dir == 1 or dir == 5 then
	    i = 2
	elseif dir == 3 or dir == 7 then
	    i = 1
	end
	local home_data = DataFamily.data_home_data[self.home_lev]
	if home_data == nil then
		Log.Error(string.format(TI18N("[HomeModel]: %s %s"), TI18N("家园信息中没有配置该等级的地图"), self.home_lev))
		return false
	end
	local wallArea = self.wallArea[home_data.map_id]
	if wallArea == nil then
		Log.Error(string.format(TI18N("[HomeModel]: %s %s"), TI18N("家园信息中配置的地图信息错误"), home_data.map_id))
		return false
	end
	local list = wallArea[i]
		local x1 = list[1][1]
		local x2 = list[2][1]
		local x3 = list[3][1]
		local x4 = list[4][1]
		local y1 = list[1][2]
		local y2 = list[2][2]
		local y3 = list[3][2]
		local y4 = list[4][2]

		for __, p in ipairs(pos_list) do
			local x = p.x
			local y = p.y

			if (math.atan((y2 - y1)/(x2 - x1)) > math.atan((y - y1)/(x - x1))) or (math.atan((y4 - y3)/(x4 - x3)) < math.atan((y - y3)/(x - x3)))
				or x < x1 or x > x2 then
				inRect = false
				break
			end
		end

	return inRect
end

-- 是否不跟别的家具重叠
function HomeModel:IsNoOtherFurniture(id, pos_list, type_list)
	local other_pos_list = {}
	for _,furniture in ipairs(self.furniture_list) do
		if furniture.status == 2 then
			local data_unit = DataFamily.data_unit[furniture.base_id]
	    	local gird = nil
	    	if data_unit == nil then
	    	    gird = nil
	    	else
	    	    if furniture.dir == 1 then
	    	        gird = DataFamily.data_gird[data_unit.gird_id].gird_list_1
	    	    elseif furniture.dir == 3 then
	    	        gird = DataFamily.data_gird[data_unit.gird_id].gird_list_2
	    	    elseif furniture.dir == 5 then
	    	        gird = DataFamily.data_gird[data_unit.gird_id].gird_list_3
	    	    elseif furniture.dir == 7 then
	    	        gird = DataFamily.data_gird[data_unit.gird_id].gird_list_4
	    	    end
	    	end

	    	if furniture.id ~= id and table.containValue(type_list, data_unit.type) and gird ~= nil then
		    	local p = SceneManager.Instance.sceneModel:transport_small_pos(furniture.x, furniture.y)
				local gx = self:GetMapGridByX(p.x)
				local gy = self:GetMapGridByY(p.y)
		    	for __, girdPoint in ipairs(gird) do
		    		table.insert(other_pos_list, { x = gx + girdPoint[2], y = gy - girdPoint[1] })
		    	end
		    end
		end
	end

	for _,value in ipairs(pos_list) do
	    local p = SceneManager.Instance.sceneModel:transport_small_pos(value.x, value.y)
	    -- value = { x = self:GetMapGridByX(p.x), y = self:GetMapGridByY(p.y) }
	    local x = self:GetMapGridByX(p.x)
	    local y = self:GetMapGridByY(p.y)
	    for __, value2 in ipairs(other_pos_list) do
    		if x == value2.x and y == value2.y then
    			return false
    		end
    	end
	end

	return true
end

function HomeModel:sort_build_list()
	local function sortfun(a,b)
        return a.type < b.type
    end

    table.sort(self.build_list, sortfun)
end

function HomeModel:getbuilddata(type, lev)
	return DataFamily.data_build_data[string.format("%s_%s", type, lev)]
end

-- 获取建筑数据 type建筑类型
function HomeModel:getbuild(type)
	for _, value in ipairs(self.build_list) do
		if value.type == tonumber(type) then
			return value
		end
	end
	return nil
end

-- 获取总的建筑面积
function HomeModel:gettotalbuildspace()
	local space = 0
	for _, value in ipairs(self.build_list) do
		local data = DataFamily.data_build_data[string.format("%s_%s", value.type, value.lev)]
		if data ~= nil then
			space = space + data.use_space
		end
	end
	return space
end

-- 获取建筑的效果值 effectType 需要获取的效果类型
function HomeModel:getbuilddataeffecttype(type, lev, effectType)
	local data = DataFamily.data_build_data[string.format("%s_%s", type, lev)]
	if data ~= nil then
		for _, effect in ipairs(data.effect) do
			if effect.effect_type == effectType then
				return effect.val[1]
			end
		end
	end
	return 0
end

-- 获取当前场景的效果值（包括建筑和家具） effectType 需要获取的效果类型
function HomeModel:geteffecttypevalue(effectType)
	for _, effect in ipairs(self.effect_list) do
		if effect.effect_type == effectType then
			return effect.val
		end
	end
	return 0
end

-- 获取建筑使用次数 effectType 需要获取的效果类型
function HomeModel:getbuildeffecttypevalue(effectType)
	for _, effect in ipairs(self.use_info) do
		if effect.effect_type == effectType then
			return effect.val
		end
	end
	return 0
end

-- 获取宠物训练栏状态
function HomeModel:getpettrainlist()
	local list = {}
	for _, pet in ipairs(self.train_info) do
		if pet.id <= 3 and pet.end_time > BaseUtils.BASE_TIME then
			local petData = PetManager.Instance.model:getpet_byid(pet.pet_id)
			pet.petData = BaseUtils.copytab(petData)
			list[pet.id] = pet
		end
	end
	return list
end

-- 仓库新增、修改物品
function HomeModel:insert_warehouse_list(info)
	local newKey = string.format("%s_%s_%s_%s", info.base_id, info.rid, info.platform, info.zone_id)
	for key,value in ipairs(self.warehouse_original_list) do
		if key == newKey then
			value.id = info.id
			value.num = info.num
			local base = DataFamily.data_unit[value.base_id]
			if base ~= nil then
				value.base = base
			end
			break
		end
	end

	local base = DataFamily.data_unit[info.base_id]
	if base ~= nil then
		info.base = base
	end
	self.warehouse_original_list[newKey] = info

	self:UpdateWarehouse()
end

-- 仓库删除物品
function HomeModel:remove_warehouse_list(info)
	local newKey = string.format("%s_%s_%s_%s", info.base_id, info.rid, info.platform, info.zone_id)
	self.warehouse_original_list[newKey] = nil

	self:UpdateWarehouse()
	-- local index = nil
	-- for i,value in ipairs(self.warehouse_original_list) do
	-- 	if value.base_id == info.base_id then
	-- 		index = i
	-- 	end
	-- end
	-- if index ~= nil then
	-- 	table.remove(self.warehouse_original_list, index)
	-- end
end

-- 场景新增、修改物品
function HomeModel:insert_furniture_list(info)
	info.battle_id = 998
	local insert_mark = true
	for i,value in ipairs(self.furniture_list) do
		if value.id == info.id then
			insert_mark = false
			self.furniture_list[i] = info
			break
		end
	end
	if insert_mark then
		table.insert(self.furniture_list, info)
	end

	local uniquenpcid = BaseUtils.get_unique_npcid(info.id, 998)
	local home = HomeManager.Instance.homeElementsModel.WaitForCreateUnitData_List[uniquenpcid]
	if home == nil then
	    local hv = HomeManager.Instance.homeElementsModel.HomeUnitView_List[uniquenpcid]
	    if hv ~= nil then
	        home = hv.data
	    end
	end
	if home == nil then
		home = HomeData.New()
		home:update_data(info)
	else
		local new_home = HomeData.New()
		new_home:update_data(home)
		new_home:update_data(info)
		home = new_home
	end

	HomeManager.Instance.homeElementsModel:UpdateUnitList({home})
end

-- 场景删除物品
function HomeModel:remove_furniture_list(info)
	local index = nil
	for i,value in ipairs(self.furniture_list) do
		if value.id == info.id then
			index = i
			local uniqueid = BaseUtils.get_unique_npcid(info.id, 998)
			HomeManager.Instance.homeElementsModel:RemoveUnit(uniqueid)
			break
		end
	end
	if index ~= nil then
		table.remove(self.furniture_list, index)
	end

	-- BaseUtils.dump(self.furniture_list, "remove_furniture_list")
end

-- 检查繁华度是否下降 (已废弃，交由服务端计算)
function HomeModel:check_env_val(baseData)
	-- local type = baseData.type
	-- local limit_data = DataFamily.data_limit[string.format("%s_%s", self.home_lev, type)]
	-- if limit_data ~= nil then
	-- 	-- 先获取该类型的物品列表
	-- 	local list = {}
	-- 	for _,value in ipairs(self.furniture_list) do
	-- 		if value.status == 2 then
	-- 			if type == value.base.type then
	-- 				table.insert(list, value)
	-- 			end
	-- 		end
	-- 	end
	-- 	-- 按照繁华度排序
	-- 	local function sortfun(a,b)
	--         return a.base.inv_val < b.base.inv_val
	--     end
	--     table.sort(list, sortfun)
	--     -- 计算繁华度大于或等于目标的家具数量
	--     local count = 0
	--     for _,value in ipairs(list) do
	--     	if value.base.inv_val >= baseData.inv_val then
	--     		count = count + 1
	--     	end
	--     end
	--     -- BaseUtils.dump(list)
	--     -- print(string.format("%s, %s", count, limit_data.count))
	--     if count > limit_data.count then
	-- 		return false
	--     else
	--     	return true
	--     end
	-- else
	-- 	return false
	-- end
end

-- 获取该类型的所有家具
function HomeModel:getFurnitureListByType(type)
	-- 先获取该类型的物品列表
	local list = {}
	for _,value in ipairs(self.furniture_list) do
		if value.status == 2 or value.status == 3 then
			if value.base == nil then
				local base = DataFamily.data_unit[value.base_id]
				if base ~= nil then
					value.base = base
				end
			end
			if type == value.base.type then
				table.insert(list, value)
			end
		end
	end
	return list
end

function HomeModel:get_limit(lev, type)
	local limit = DataFamily.data_limit[string.format("%s_%s", lev, type)]
	if limit == nil then
		return 0
	else
		return limit.count
	end
end

-- 减少列表中 处于编辑状态的数量
function HomeModel:sub_edit_list(list)
	local sub_list = {}
	for k,v in pairs(HomeManager.Instance.homeElementsModel.Edit_List) do
		if sub_list[v.baseData.item_id] == nil then
			sub_list[v.baseData.item_id] = 1
		else
			sub_list[v.baseData.item_id] = sub_list[v.baseData.item_id] + 1
		end
	end
	for k,v in pairs(HomeManager.Instance.homeElementsModel.WaitForCreateUnitData_List) do
		if v.isEdit then
			local baseData = DataFamily.data_unit[v.base_id]
			if baseData ~= nil then
				if sub_list[baseData.item_id] == nil then
					sub_list[baseData.item_id] = 1
				else
					sub_list[baseData.item_id] = sub_list[baseData.item_id] + 1
				end
			end
		end
	end
	local data_list = BaseUtils.copytab(list)
	for _,v in ipairs(data_list) do
		if sub_list[v.base.item_id] ~= nil then
			v.num = v.num - sub_list[v.base.item_id]
		end
	end
	return data_list
end

-- 收起家具飞图标
function HomeModel:FlyIcon(unit_view)
	local unit_data = DataFamily.data_unit[unit_view.data.base_id]
	if unit_data ~= nil then
	    local tmp = SceneManager.Instance.MainCamera.camera:WorldToScreenPoint(unit_view.transform.position)
	    tmp = BaseUtils.ScreenToUIPoint(Vector2(tmp.x - ctx.ScreenWidth / 2, tmp.y - ctx.ScreenHeight / 2))
	    local start_pos = Vector3(tmp.x, tmp.y, 0)
	    local end_pos = Vector3(tmp.x, tmp.y + 20, 0)
	    local fun = function()
	    		local end_pos_2 = Vector3(0, -210, 0)
	    		NoticeManager.Instance:FlyItemIcon(unit_data.item_id, end_pos, end_pos_2, 0.6, nil)
			end
	    NoticeManager.Instance:FlyItemIcon(unit_data.item_id, start_pos, end_pos, 0.3, fun)
	end
end

-- 计算当前家园最高可升级等级
function HomeModel:GetHomeMaxLev()
	for i=1,#DataFamily.data_home_data do
		if self.env_val < DataFamily.data_home_data[i].min_env then
			return i - 1
		end
	end
	return #DataFamily.data_home_data
end

-- 检查非法家具（检查到则收起）
function HomeModel:CheckIllegalFurniture()
	if self:CanEditHome() then
		for i, value in pairs(self.furniture_list) do
			if value.dir == 0 and value.base ~= nil and value.base.type ~= 15 then
				HomeManager.Instance:Send11207(value.id)
			end
		end
	end
end
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function HomeModel:On11200(data)
	-- BaseUtils.dump(data, "<color='#00ff00'>On11200</color>")
	self.fid = data.fid --家园id
	self.platform = data.platform --平台标识
	self.zone_id = data.zone_id --区号
    self.battle_id = data.battle_id -- 战场ID

	self.unique_roleid = BaseUtils.get_unique_roleid(data.fid, data.zone_id, data.platform)

	self.map_id = data.map_id --地图id

	self.home_lev = data.lev -- 家园等级

	self.home_name = TI18N("家园名字")
	self.master_name = data.master_name

	self.env_val = data.env_val

	self.cleanness = data.cleanness
	self.housekeeper_action_times = 1 - data.housekeeper_action_times

	self.warehouse_original_list, self.furniture_list = self:SetFurnishings(data.furnishings) -- 家具信息
	self:UpdateWarehouse()

    self.floor_data = self:GetFloorData(data.floor_lev, self.furniture_list) --地板数据

    self.build_list = data.bdg_info --建筑信息
    self:sort_build_list()

    self.visit_lock = data.visit_lock -- 权限(1 所有 2 好友 3 公会 4好友与公会 5 关闭)
    self.is_upgrade_bdg = data.is_upgrade_bdg
    HomeManager.Instance.buildFirstInfo:Fire()

    self.bean_data = data
    EventMgr.Instance:Fire(event_name.home_base_update) -- 更新基础信息
    EventMgr.Instance:Fire(event_name.home_build_update) -- 更新建筑信息
    EventMgr.Instance:Fire(event_name.home_warehouse_update) --更新家具仓库信息
 	HomeManager.Instance.homeElementsModel:UpdateUnitList(self.furniture_list) -- 更新场景家具
    -- print("<color='#ff0000'>魔法豌豆更新</color>")
    EventMgr.Instance:Fire(event_name.home_bean_info_update) -- 魔法豌豆更新

 	local mapId = SceneManager.Instance:CurrentMapId()
  	if mapId == 30012 or mapId == 30013 then
	    self:ShowFloor()
	end

	self:CheckIllegalFurniture()

	if self:CanEditHome() and self.housekeeper_action_times > 0 and self.cleanness < 20 then
		local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("您的家园需要打扫啦~现在清洁度低于<color='#00ff00'>20</color>，没法使用家园建筑哦！{face_1,32}")
        data.sureLabel = TI18N("马上打扫")
        data.cancelLabel = TI18N("没关系")
        data.sureCallback = function()
            HomeManager.Instance:Send11224()
        end
        NoticeManager.Instance:ConfirmTips(data)
	end
end

function HomeModel:On11205(data)
	BaseUtils.dump(data, "On11205")
	for i = 1, #data.update_info do
		local update_info = data.update_info[i]

		if update_info.flag == 1 then
			if update_info.status == 1 then
				self:insert_warehouse_list(update_info)
			elseif update_info.status == 2 or update_info.status == 3 then
				self:insert_furniture_list(update_info)
			end
		elseif update_info.flag == 2 then
			if update_info.status == 1 then
				self:insert_warehouse_list(update_info)
			elseif update_info.status == 2 or update_info.status == 3 then
				self:insert_furniture_list(update_info)
			end
		elseif update_info.flag == 3 then
			if update_info.status == 1 then
				self:remove_warehouse_list(update_info)
			elseif update_info.status == 2 or update_info.status == 3 then
				self:remove_furniture_list(update_info)
			end
		end
	end
	EventMgr.Instance:Fire(event_name.home_warehouse_update)
end

function HomeModel:On11211(data)
    if #data.goods_list <= 1 then
        for k,v in pairs(data.goods_list) do
            for kk,vv in pairs(self.shop_datalist) do
                if vv.id == v.id then
                    self.shop_datalist[kk] = v
                end
            end
        end
    else
        self.shop_datalist = data.goods_list
    end
    -- BaseUtils.dump(self.shop_datalist)
    EventMgr.Instance:Fire(event_name.home_shop_update)
end

function HomeModel:On11213(data)
    self.build_list = data.bdg_info

    self:sort_build_list()

    EventMgr.Instance:Fire(event_name.home_build_update)
end

function HomeModel:On11217(data)
	self.effect_list = data.effect_list
	EventMgr.Instance:Fire(event_name.home_build_update)
end

function HomeModel:On11218(data)
	-- BaseUtils.dump(data, "<color='#00ff00'>On11218</color>")
	self.fid = data.fid --家园id
	self.platform = data.platform --平台标识
	self.zone_id = data.zone_id --区号
    self.is_upgrade_bdg = data.is_upgrade_bdg
    HomeManager.Instance.buildFirstInfo:Fire()

	self.map_id = data.map_id --地图id

	if self.home_lev ~= data.lev then
		WindowManager.Instance:OpenWindowById(WindowConfig.WinID.gethome, {data.lev})
	end
	self.home_lev = data.lev -- 家园等级

	self.home_name = TI18N("家园名字")

	self.env_val = data.env_val
	local homeMaxLev = self:GetHomeMaxLev()
	if homeMaxLev > self.home_lev then
		if self.confirmMark then
			local data = NoticeConfirmData.New()
		    data.type = ConfirmData.Style.Normal
		    data.content = string.format("%s%s，%s<color='#ffff00'>%s</color>，%s", TI18N("家园繁华度已经达到"),self.env_val, TI18N("可提升至"), DataFamily.data_home_data[homeMaxLev].name2, TI18N("赶快去扩建吧"))
		    data.sureLabel = TI18N("扩建")
		    data.cancelLabel = TI18N("取消")
		    data.sureCallback = function()
		        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.home_window, {4})
		    end
		    data.cancelCallback = function()
		        self.confirmMark = false
		    end
		    NoticeManager.Instance:ConfirmTips(data)
		end
	end

	self.cleanness = data.cleanness
	self.housekeeper_action_times = 1 - data.housekeeper_action_times

    self.floor_data = self:GetFloorData(data.floor_lev, self.furniture_list) --地板等级

    self.visit_lock = data.visit_lock -- 权限(1 所有 2 好友 3 公会 4好友与公会 5 关闭)

	EventMgr.Instance:Fire(event_name.home_base_update)

    -- self.build_list = data.bdg_info --建筑信息

    -- self:sort_build_list()

    -- EventMgr.Instance:Fire(event_name.home_build_update)

    local mapId = SceneManager.Instance:CurrentMapId()
    if mapId == 30012 or mapId == 30013 then
	    self:ShowFloor()
	end

	if self:CanEditHome() and self.housekeeper_action_times > 0 and self.cleanness < 20 then
		local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("您的家园需要打扫啦~现在清洁度低于<color='#00ff00'>20</color>，没法使用家园建筑哦！{face_1,32}")
        data.sureLabel = TI18N("马上打扫")
        data.cancelLabel = TI18N("没关系")
        data.sureCallback = function()
            HomeManager.Instance:Send11224()
        end
        NoticeManager.Instance:ConfirmTips(data)
	end
end

function HomeModel:On11220(data)
	-- print("On11220")
	-- BaseUtils.dump(data)
	self.train_info = data.train_info
	EventMgr.Instance:Fire(event_name.home_train_info_update)
end

function HomeModel:On11221(data)
	-- print("On11221")
	-- BaseUtils.dump(data)
	self.use_info = data.use_info
	EventMgr.Instance:Fire(event_name.home_use_info_update)
end

function HomeModel:On11223(data)
    -- print("On11223")
    -- BaseUtils.dump(data)
    if data.type == 1 then
        self.home_friend_list = data.family_info
    elseif data.type == 2 then
        self.home_guild_list = data.family_info
    end
    EventMgr.Instance:Fire(event_name.home_visit_info_update, data.type)
end

function HomeModel:on11225(data)
    -- if self:CanEditHome() then
    	self.bean_data = data
        -- print("<color='#ff0000'>魔法豌豆更新</color>")
    	EventMgr.Instance:Fire(event_name.home_bean_info_update)
    -- end
end

function HomeModel:GetWaterTimes(id, platform, zone_id)
    local num = 0
    for i,v in ipairs(self.bean_data.event_record) do
        if v.wid == id and v.wplatform == platform and zone_id == v.wzone_id then
            num = num + 1
        end
    end
    return num
end

-- 是否给过箱子
function HomeModel:IsGivedBox(id, platform, zone_id)
    for i,v in ipairs(self.bean_data.inviters) do
        if v.ivtid == id and v.ivtplatform == platform and zone_id == v.ivtzone_id then
            return true
        end
    end
    return false
end