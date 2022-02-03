-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      雇佣掠夺界面,打别人的
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EscortPlunderWindow = EscortPlunderWindow or BaseClass(BaseView)

local controller = EscortController:getInstance()
local model = controller:getModel()
local game_net = GameNet:getInstance()
local table_insert = table.insert
local string_format = string.format
local table_sort = table.sort 

function EscortPlunderWindow:__init()
    self.is_full_screen = false
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.layout_name = "escort/escort_plunder_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("escort", "escort"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("form", "form"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_52"), type = ResourcesType.single}, 
	}
end

function EscortPlunderWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)
	local main_panel = main_container:getChildByName("main_panel") 
	main_panel:getChildByName("win_title"):setString(TI18N("掠夺信息"))
	main_panel:getChildByName("title"):setString(TI18N("掠夺获得"))
	main_panel:getChildByName("name_title"):setString(TI18N("玩家名字:")) 
	main_panel:getChildByName("guild_title"):setString(TI18N("公会:")) 
	main_panel:getChildByName("power_title"):setString(TI18N("战斗力:")) 
	main_panel:getChildByName("form_title"):setString(TI18N("对方阵容")) 
	main_panel:getChildByName("times_title"):setString(TI18N("掠夺次数:")) 
	main_panel:getChildByName("server_title"):setString(TI18N("服务器:"))
	
	self.close_btn = main_panel:getChildByName("close_btn") 

	self.plunder_btn = main_panel:getChildByName("plunder_btn")
	self.plunder_btn:getChildByName("label"):setString(TI18N("我要掠夺"))

	self.form_icon = main_panel:getChildByName("form_icon")		-- 阵法信息,sprite
	self.item_name = main_panel:getChildByName("item_name")		-- 雇佣名字,区分颜色
	self.times_value = main_panel:getChildByName("times_value")	-- 剩余次数
	self.name_value = main_panel:getChildByName("name_value")	-- 玩家名字
	self.guild_value = main_panel:getChildByName("guild_value")	-- 公会名字
	self.power_value = main_panel:getChildByName("power_value")	-- 战力
	self.form_value = main_panel:getChildByName("form_value")	-- 阵法名称和等级
	self.server_value = main_panel:getChildByName("server_value")	-- 服务器名字

	self.main_width = main_panel:getContentSize().width
	self.main_panel = main_panel 
end

function EscortPlunderWindow:register_event()
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			customClickAction(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				controller:openEscortPlunderWindow(false) 
			end
		end)
	end
	if self.plunder_btn then
		self.plunder_btn:addTouchEventListener(function(sender, event_type) 
			customClickAction(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				if self.data then
					controller:requestPlunderEscort(self.data.rid, self.data.srv_id)
				end
			end
		end)
	end
end

function EscortPlunderWindow:openRootWnd(data)
	self.data = data
	if data then
		self:createBaseInfo()
		self:createFormList()
		self:createRewardsList()
	end
	-- 掠夺次数
	local my_info = model:getMyInfo()
	if my_info then
		local max_plunder_times = model:getMyMaxCount(EscortConst.times_type.plunder)
		local num = max_plunder_times - model:getMyCount(EscortConst.times_type.plunder)
		if num  < 0 then num = 0 end
		self.times_value:setString(num.."/"..max_plunder_times)
	end
end

function EscortPlunderWindow:createBaseInfo()
	if self.data == nil then return end

	local config = Config.EscortData.data_baseinfo[self.data.quality]
	if config then
		self.item_name:setString(config.title)
		local color = EscortConst.quality_color[self.data.quality]
		if color then
			self.item_name:setTextColor(color)
		end
		if self.player == nil then
			self.player = createEffectSpine(config.res, cc.p(142, 588), cc.p(0.5,0.5), true, PlayerAction.action_1)
			self.player:setScale(0.9)
			self.main_panel:addChild(self.player)
		end
	end
	if self.data.guild_name == "" then
		self.guild_value:setString(TI18N("暂无"))
	else
		self.guild_value:setString(self.data.guild_name)
	end

	self.server_value:setString(getServerName(self.data.srv_id))
	self.power_value:setString(self.data.power)
	self.name_value:setString(self.data.name)

	local form_type = self.data.formation_type or 1
	local form_lev = self.data.formation_lev or 1
	if form_type then
		local form_config = Config.FormationData.data_form_data[form_type]
		if form_config then
			self.form_value:setString(form_config.name.."Lv."..(form_lev or 0))

			local form_res = PathTool.getResFrame("form","form_icon_"..form_type)
			loadSpriteTexture(self.form_icon, form_res, LOADTEXT_TYPE_PLIST)
		end
	end
end

function EscortPlunderWindow:createFormList()
	if self.data == nil then return end

	local list = self.data.p_list
	if list and next(list) then
		self.partner_list = {}
		local offx = 10
		local p_list_size = #list 
		local total_width = p_list_size * 104 + (p_list_size - 1) * offx
		local start_x = ( self.main_width - total_width ) / 2 
		local partner_item = nil
		for i,v in ipairs(list) do
			partner_item = HeroExhibitionItem.new(1, false)
			partner_item:setPosition(start_x+104*0.5+(i-1)*(104+offx), 410)
			partner_item:setData(v)
			self.main_panel:addChild(partner_item)
			table_insert( self.partner_list, partner_item )
		end
	end
end

function EscortPlunderWindow:createRewardsList()
	if self.data == nil then return end
	local awards_config = Config.EscortData.data_rewards(getNorKey(self.data.quality, self.data.lev)) 
	if awards_config and awards_config.plunder_award then
		self.item_list = {}
		local is_double = model:isDoubleTimes() or false
		local num_scale = 1
		if is_double == true then
			num_scale = 2
		end
		local item = nil
		local scale = 0.9
		local off = 40
		local _x, _y = 0, 212
		local sum = #awards_config.plunder_award
		local item_conf = nil
		local total_width = sum * BackPackItem.Width * scale + (sum - 1) * off
		local start_x =(self.main_width - total_width) / 2 
		local assets_config = Config.ItemData.data_assets_id2label
		for i, v in ipairs(awards_config.plunder_award) do
			if v[1] and v[2] then
				local bid = v[1]
				local num = v[2] * num_scale 
				item_conf = Config.ItemData.data_get_data(bid)
				if item_conf then
					item = BackPackItem.new(false, true, false, scale, false, true)
					_x = start_x + (BackPackItem.Width * scale + off) * (i-1) + BackPackItem.Width*scale*0.5
					item:setBaseData(bid, num)
					item:setPosition(_x, _y)
					item:setDoubleIcon(is_double)
					self.main_panel:addChild(item)
					table.insert(self.item_list, item)
				end
			end
		end 
	end
end

function EscortPlunderWindow:close_callback()
	for i,v in ipairs(self.partner_list) do
		v:DeleteMe()
	end
	self.partner_list = nil

	for i,v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil
    controller:openEscortPlunderWindow(false)
end