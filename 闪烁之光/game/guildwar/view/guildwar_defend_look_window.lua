--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-10-15 20:35:23
-- @description    : 
		-- 联盟战 据点防守记录
---------------------------------
GuildwarDefendLookWindow = GuildwarDefendLookWindow or BaseClass(BaseView)

local controller = GuildwarController:getInstance()
local model = controller:getModel()

function GuildwarDefendLookWindow:__init(  )
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big 
	self.is_full_screen = false
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guildwar", "guildwar"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), type = ResourcesType.single }
	}
	self.layout_name = "guildwar/guildwar_defend_look_window"
end

function GuildwarDefendLookWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self.container = container
    self:playEnterAnimatianByObj(container, 1)

    local win_title = container:getChildByName("win_title")
    win_title:setString(TI18N("防守记录"))

    local title_label_1 = container:getChildByName("title_label_1")
    title_label_1:setString(TI18N("据点防守阵容"))
    local title_label_2 = container:getChildByName("title_label_2")
    title_label_2:setString(TI18N("防守录像"))

    self.close_btn = container:getChildByName("close_btn")
    self.no_vedio_image = container:getChildByName("no_vedio_image")
    self.no_vedio_label = container:getChildByName("no_vedio_label")
    self.time_label = container:getChildByName("time_label")
    self.list_panel = container:getChildByName("list_panel")

    local time_str = Config.GuildWarData.data_const.time_desc.desc or ""
    self.time_label:setString(time_str)

    local bgSize = self.list_panel:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height-8)
    local setting = {
        item_class = GuildwarDefendLookItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 616,               -- 单元的尺寸width
        item_height = 218,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.list_panel, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function GuildwarDefendLookWindow:register_event(  )
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openDefendLookWindow(false)
		end
	end) 

	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openDefendLookWindow(false)
		end
	end) 

end

function GuildwarDefendLookWindow:setData( data )
	data = data or {}

	-- 敌方阵容
	if not self.enemy_battle_array_panel then
		self.enemy_battle_array_panel = GuildwarBattleArrayPanel.new()
		local container_size = self.container:getContentSize()
		self.container:addChild(self.enemy_battle_array_panel)
		self.enemy_battle_array_panel:setPanelContentSize(cc.size(616, 190))
		self.enemy_battle_array_panel:setPosition(cc.p(87, 625))
	end
	local battle_array_data = {}
	local partner_list = {}
	for k,v in pairs(data.defense) do
		table.insert(partner_list, v)
	end
	battle_array_data.partner_list = partner_list
	battle_array_data.power = data.power
	battle_array_data.formation_type = data.formation_type
	battle_array_data.formation_lev = data.formation_lev
	self.enemy_battle_array_panel:setData(battle_array_data)

	-- 防守列表
	if data.guild_war_role_log and next(data.guild_war_role_log) ~= nil then
		self.item_scrollview:setData(data.guild_war_role_log)
		self.no_vedio_image:setVisible(false)
		self.no_vedio_label:setVisible(false)
	else
		self.no_vedio_image:setVisible(true)
		self.no_vedio_label:setVisible(true)
	end
		
end

function GuildwarDefendLookWindow:openRootWnd( g_id, g_sid, pos )
	controller:requestPositionDefendData(g_id, g_sid, pos)
end

function GuildwarDefendLookWindow:close_callback(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end

	if self.enemy_battle_array_panel then
		self.enemy_battle_array_panel:DeleteMe()
		self.enemy_battle_array_panel = nil
	end

	controller:openDefendLookWindow(false)
end


---------------------------------------------------------
--@ 子项
GuildwarDefendLookItem = class("GuildwarDefendLookItem", function()
    return ccui.Widget:create()
end)

function GuildwarDefendLookItem:ctor()
	self.ctrl = GuildwarController:getInstance()

	self.hero_item_list = {}

	self:configUI()
	self:register_event()
end

function GuildwarDefendLookItem:configUI(  )
	self.size = cc.size(616,218)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("guildwar/guildwar_defend_look_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.name_label = self.container:getChildByName("name_label")
    self.time_label = self.container:getChildByName("time_label")
    self.attk_label = self.container:getChildByName("attk_label")
    self.result_label = self.container:getChildByName("result_label")
    self.magic_label = self.container:getChildByName("magic_label")
    self.diff_label = self.container:getChildByName("diff_label")
    
    self.vedio_btn = self.container:getChildByName("vedio_btn")
    self.role_list = self.container:getChildByName("role_list")
    self.role_list:setTouchEnabled(false)

    local scrollCon_size = self.role_list:getContentSize()
    self.scroll_view_size = cc.size(scrollCon_size.width - 10, scrollCon_size.height)
    self.scroll_view = createScrollView(self.scroll_view_size.width,self.scroll_view_size.height,8,0,self.role_list,ccui.ScrollViewDir.horizontal)
    self.scroll_view:setSwallowTouches(false)
end

function GuildwarDefendLookItem:register_event(  )
	self.vedio_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data and self.data.repaly_id then
				BattleController:getInstance():csRecordBattle(self.data.repaly_id)
			end
		end
	end)
end

function GuildwarDefendLookItem:setData( data )
	self.data = data

	self.name_label:setString(string.format(TI18N("挑战者：%s"), data.name))
	self.attk_label:setString(string.format(TI18N("战力：%d"), data.power))
	self.time_label:setString(TimeTool.getYMDHMS(data.time))

	local form_data = Config.FormationData.data_form_data[data.formation_type]
    if form_data then
        local form_lv = data.formation_lev or 1
        self.magic_label:setString(string.format("%s Lv.%d", form_data.name, form_lv))
    end

	if data.result == TRUE then
		self.result_label:setString(TI18N("挑战失败"))
		self.result_label:setTextColor(cc.c4b(217, 80, 20, 255))
	else
		self.result_label:setString(TI18N("挑战成功"))
		self.result_label:setTextColor(cc.c4b(36, 144, 3, 255))
	end

	if data.hp == 1 then
		self.diff_label:setString(TI18N("[简单]"))
	elseif data.hp == 2 then
		self.diff_label:setString(TI18N("[普通]"))
	elseif data.hp == 3 then
		self.diff_label:setString(TI18N("[困难]"))
	end

	-- 阵容
	local temp_partner_vo = {}
	for k,v in pairs(data.defense) do
		local vo = HeroVo.New()
		vo:updateHeroVo(v)
		table.insert(temp_partner_vo,vo)
	end

	local scale = 0.77
	local p_list_size = #temp_partner_vo
    local total_width = p_list_size * HeroExhibitionItem.Width*scale + (p_list_size - 1) * 6
    local start_x = 0
    local max_width = math.max(total_width,self.scroll_view_size.width) 
    self.scroll_view:setInnerContainerSize(cc.size(max_width,self.scroll_view_size.height))

    for i,v in ipairs(temp_partner_vo) do
        local partner_item = HeroExhibitionItem.new(scale, false)
        partner_item:setPosition(start_x+HeroExhibitionItem.Width*scale*0.5+(i-1)*(HeroExhibitionItem.Width*scale+6), self.scroll_view_size.height*0.5)
        partner_item:setData(v,nil,is_spec)
        table.insert(self.hero_item_list, partner_item)
        self.scroll_view:addChild(partner_item)
    end
end

function GuildwarDefendLookItem:DeleteMe(  )
	for k,v in pairs(self.hero_item_list) do
		v:DeleteMe()
		v = nil
	end
end