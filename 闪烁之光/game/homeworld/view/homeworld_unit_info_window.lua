--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-07-08 11:36:50
-- @description    : 
		-- 家具信息
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

HomeworldUnitInfoWindow = HomeworldUnitInfoWindow or BaseClass(BaseView)

function HomeworldUnitInfoWindow:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "homeworld/homeworld_unit_info_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("homeworld", "homeworld"), type = ResourcesType.plist},
	}

	self.goto_id = {} --跳转id
	self.source_list = {}
end

function HomeworldUnitInfoWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(main_container , 2) 

	main_container:getChildByName("win_title"):setString(TI18N("家具信息"))
	main_container:getChildByName("num_title"):setString(TI18N("获取来源"))

	self.sp_icon = main_container:getChildByName("sp_icon")
	self.soft_label = main_container:getChildByName("soft_label")
	self.grid_label = main_container:getChildByName("grid_label")

	self.close_btn = main_container:getChildByName("close_btn")

	for i=1,4 do
		local source_bg = main_container:getChildByName("source_bg_" .. i)
		if source_bg then
			local object = {}
			object.index = i
			object.source_bg = source_bg
			object.source_bg:setVisible(false)
			object.btn = source_bg:getChildByName("btn_go")
			object.label = source_bg:getChildByName("desc_txt")
			_table_insert(self.source_list, object)
		end
	end
end

function HomeworldUnitInfoWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openFurnitureInfoWindow(false)
	end, false, 2)

	registerButtonEventListener(self.close_btn, function (  )
		_controller:openFurnitureInfoWindow(false)
	end, true, 2)

	--跳转
	for i,v in pairs(self.source_list) do
		registerButtonEventListener(v.btn, function()
			if self.goto_id[v.index] then
				self:JumpSourceType(self.goto_id[v.index])
			end
		end, true, 1)
	end
end
--跳转
function HomeworldUnitInfoWindow:JumpSourceType(evt_type)
	if evt_type == 132 then --家具
        HomeworldController:getInstance():openHomeworldShopWindow(true, {index = 1})
    elseif evt_type == 133 then --出行
    	HomeworldController:getInstance():openHomeworldShopWindow(true, {index = 2})
    elseif evt_type == 134 then --随机
    	HomeworldController:getInstance():openHomeworldShopWindow(true, {index = 3})
    elseif evt_type == 135 then
    	HomeworldController:getInstance():openHomeperBag()
    end	
end

function HomeworldUnitInfoWindow:openRootWnd( id )
	if not id then return end
	self.unit_config = Config.HomeData.data_home_unit(id)
	self:setData()
end

function HomeworldUnitInfoWindow:setData(  )
	if not self.unit_config then return end

	if not self.name_label then
		self.name_label = createRichLabel(22, 274, cc.p(0, 0.5), cc.p(207, 420), nil, nil, 450)
		self.main_container:addChild(self.name_label)
	end
	local name_str = ""
	local item_config = Config.ItemData.data_get_data(self.unit_config.bid)
	if item_config then
		name_str = _string_format("<div fontcolor=%s>%s</div>", BackPackConst.getWhiteQualityColorStr(item_config.quality), self.unit_config.name)
	else
		name_str = self.unit_config.name
	end
	local suit_cfg = Config.HomeData.data_suit[self.unit_config.set_id]
	if suit_cfg then
		name_str = name_str .. _string_format(TI18N(" <div fontcolor=955322>【所属主题:%s】</div>"), suit_cfg.name)
	end
	self.name_label:setString(name_str)

	local item_res = PathTool.getFurnitureNormalRes(self.unit_config.icon)
	loadSpriteTexture(self.sp_icon, item_res, LOADTEXT_TYPE)

	-- 描述
	if not self.desc_txt then
		self.desc_txt = createRichLabel(20, cc.c4b(134,79,53,255), cc.p(0, 0.5), cc.p(207, 376), 5, nil, 380)
		self.main_container:addChild(self.desc_txt)
	end
	self.desc_txt:setString(self.unit_config.desc)

	-- 舒适度
	self.soft_label:setString(_string_format(TI18N("舒适度+%d"), self.unit_config.soft))
	-- 占地
	self.grid_label:setString(_string_format(TI18N("占地:%s"), self.unit_config.grid_desc))

	-- 来源 todo
	local source_data = Config.SourceData.data_source_data
	if self.unit_config.soruce_id then
		for i,v in ipairs(self.unit_config.soruce_id) do
			self.source_list[i].source_bg:setVisible(true)
			self.source_list[i].label:setString(source_data[v[1]].name)
			self.goto_id[i] = v[1]
		end
	end
end

function HomeworldUnitInfoWindow:close_callback(  )
	_controller:openFurnitureInfoWindow(false)
end