--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-10-19 15:05:13
-- @description    : 
		-- 对阵列表
---------------------------------
GuildwarBattleListWindow = GuildwarBattleListWindow or BaseClass(BaseView)

local controller = GuildwarController:getInstance()
local model = controller:getModel()

function GuildwarBattleListWindow:__init(  )
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big
	self.is_full_screen = false
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guildwar", "guildwar"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), type = ResourcesType.single },
	}
	self.layout_name = "guildwar/guildwar_against_list_panel"
end

function GuildwarBattleListWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(container, 1)

    local win_title = container:getChildByName("win_title")
    win_title:setString(TI18N("战斗列表"))

    self.close_btn = container:getChildByName("close_btn")
    self.explain_btn = container:getChildByName("explain_btn")

    local title_label_1 = container:getChildByName("title_label_1")
    title_label_1:setString(TI18N("本会对阵"))
    local title_label_2 = container:getChildByName("title_label_2")
    title_label_2:setString(TI18N("其他对阵"))

    self.time_label = container:getChildByName("time_label")
    self.item_list = container:getChildByName("item_list")
    self.my_item_bg = container:getChildByName("image_3")

    self.no_log_image = container:getChildByName("no_log_image")
    self.no_log_label = container:getChildByName("no_log_label")
    self.no_log_label:setString(TI18N("暂无其他对阵"))
    self.tips_label = container:getChildByName("tips_label")

    local time_str = Config.GuildWarData.data_const.time_desc.desc or ""
    self.time_label:setString(time_str)

    local bgSize = self.item_list:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height-8)
    local setting = {
        item_class = GuildwarBattleListItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 616,               -- 单元的尺寸width
        item_height = 124,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.item_list, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function GuildwarBattleListWindow:setData( data )
	data.match_info = data.match_info or {}

	local guild_info = GuildController:getInstance():getModel():getMyGuildInfo()

	-- 选出我方联盟对战数据
	local myGuildWarBattleInfo = {}
	local is_join = false  -- 是否参与了匹配
	if guild_info then
		for k,v in pairs(data.match_info) do
			if v.g_id1 == guild_info.gid and v.g_sid1 == guild_info.gsrv_id then
				if v.g_id2 ~= 0 then
					myGuildWarBattleInfo = table.remove(data.match_info, k)
				end
				is_join = true
				break
			elseif v.g_id2 == guild_info.gid and v.g_sid2 == guild_info.gsrv_id then
				if v.g_id1 ~= 0 then
					myGuildWarBattleInfo = table.remove(data.match_info, k)
				end
				is_join = true
				break
			end
		end
	end

	self.data = {}
	-- 排除掉轮空的
	for i,v in ipairs(data.match_info) do
		if v.g_id1 ~= 0 and v.g_id2 ~= 0 then
			table.insert(self.data, v)
		end
	end

	local function sortFunc( objA, objB )
		if objA.rank1 == 0 and objB.rank1 == 0 then
			return false
		elseif objA.rank1 ~= 0 and objB.rank1 == 0 then
			return true
		elseif objA.rank1 == 0 and objB.rank1 ~= 0 then
			return false
		else
			return objA.rank1 < objB.rank1
		end
	end
	table.sort(self.data, sortFunc)

	if myGuildWarBattleInfo and next(myGuildWarBattleInfo) ~= nil then
		self.tips_label:setVisible(false)
		if not self.my_guildwar_battle_item then
			self.my_guildwar_battle_item = GuildwarBattleListItem.new()
			self.my_item_bg:addChild(self.my_guildwar_battle_item)
			local item_bg_size = self.my_item_bg:getContentSize()
    		self.my_guildwar_battle_item:setPosition(cc.p(item_bg_size.width/2, item_bg_size.height/2))
			self.my_guildwar_battle_item:setData(myGuildWarBattleInfo)
		end
	else
		self.tips_label:setVisible(true) 
		if is_join then
			self.tips_label:setString(TI18N("本次公会战轮空"))
		else
			self.tips_label:setString(TI18N("由于公会内活跃人数不足，无法参与本次公会战"))
		end
	end

	if self.data and next(self.data) ~= nil then
		self.item_scrollview:setData(self.data)
		self.no_log_image:setVisible(false)
		self.no_log_label:setVisible(false)
	else
		self.no_log_image:setVisible(true)
		self.no_log_label:setVisible(true)
	end
end

function GuildwarBattleListWindow:register_event(  )
	self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openBattleListWindow(false)
        end
    end)
    
	self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openBattleListWindow(false)
        end
    end)

    self.explain_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            MainuiController:getInstance():openCommonExplainView(true, Config.GuildWarData.data_explain)
        end
    end)
end

function GuildwarBattleListWindow:openRootWnd(  )
	controller:requestGuildWarBattleList()
end

function GuildwarBattleListWindow:close_callback(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil

	controller:openBattleListWindow(false)
end


------------------------------
-- 子项
GuildwarBattleListItem = class("GuildwarBattleListItem", function()
    return ccui.Widget:create()
end)

function GuildwarBattleListItem:ctor()
	self:configUI()
	self:register_event()
end

function GuildwarBattleListItem:configUI(  )
	self.size = cc.size(616,124)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("guildwar/guildwar_against_list_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")

    self.state_label = main_container:getChildByName("state_label")
    self.gname_label_1 = main_container:getChildByName("gname_label_1")
    self.srvname_label_1 = main_container:getChildByName("srvname_label_1")
    self.rank_label_1 = main_container:getChildByName("rank_label_1")
    self.win_image_1 = main_container:getChildByName("win_image_1")
    self.gname_label_2 = main_container:getChildByName("gname_label_2")
    self.srvname_label_2 = main_container:getChildByName("srvname_label_2")
    self.rank_label_2 = main_container:getChildByName("rank_label_2")
    self.win_image_2 = main_container:getChildByName("win_image_2")
end

function GuildwarBattleListItem:register_event(  )
end

function GuildwarBattleListItem:setData( data )
	data = data or {}
	self.gname_label_1:setString(data.guild_name1)
	local index_1 = string.find(data.g_sid1, "_")
	local srv_index_1 = 1
	if index_1 then
		srv_index_1 = string.sub(data.g_sid1, index_1+1)
	end
	local srv_name_1 = string.format(TI18N("[S%s] %s"), tostring(srv_index_1), data.srv_name1)
	self.srvname_label_1:setString(srv_name_1)
	local rank_str_1 = ""
	if data.rank1 <= 0 then
		rank_str_1 = TI18N("未上榜")
	else
		rank_str_1 = tostring(data.rank1)
	end
	self.rank_label_1:setString(string.format(TI18N("服务器排名：%s"), rank_str_1))

	self.gname_label_2:setString(data.guild_name2)
	local index_2 = string.find(data.g_sid2, "_")
	local srv_index_2 = 1
	if index_2 then
		srv_index_2 = string.sub(data.g_sid2, index_2+1)
	end
	local srv_name_2 = string.format(TI18N("[S%s] %s"), tostring(srv_index_2), data.srv_name2)
	self.srvname_label_2:setString(srv_name_2)
	local rank_str_2 = ""
	if data.rank2 <= 0 then
		rank_str_2 = TI18N("未上榜")
	else
		rank_str_2 = tostring(data.rank2)
	end
	self.rank_label_2:setString(string.format(TI18N("服务器排名：%s"), rank_str_2))

	self.win_image_1:setVisible(false)
	self.win_image_2:setVisible(false)
	local guildwar_status = model:getGuildWarStatus()
	if data.status == TRUE then
		self.state_label:setVisible(true)
		if data.g_id == 0 then -- 平局
			self.state_label:setString(TI18N("平局"))
			self.state_label:setTextColor(GuildwarConst.against_color[3])
		else
			self.state_label:setString(TI18N("已结束"))
			self.state_label:setTextColor(GuildwarConst.against_color[1])
			if data.g_id and data.g_id == data.g_id1 and data.g_sid == data.g_sid1 then
				self.win_image_1:setVisible(true)
			else
				self.win_image_2:setVisible(true)
			end
		end
	elseif guildwar_status == GuildwarConst.status.processing then
		self.state_label:setVisible(true)
		self.state_label:setString(TI18N("进行中"))
		self.state_label:setTextColor(GuildwarConst.against_color[2])
	else
		self.state_label:setVisible(false)
	end
end

function GuildwarBattleListItem:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end