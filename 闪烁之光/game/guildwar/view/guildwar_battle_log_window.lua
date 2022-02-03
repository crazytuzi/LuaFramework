--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-10-19 15:17:29
-- @description    : 
		-- 战场日志
---------------------------------
GuildwarBattleLogWindow = GuildwarBattleLogWindow or BaseClass(BaseView)

local controller = GuildwarController:getInstance()
local model = controller:getModel()

function GuildwarBattleLogWindow:__init(  )
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big
	self.is_full_screen = false
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guildwar", "guildwar"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), type = ResourcesType.single },
	}
	self.layout_name = "guildwar/guildwar_battle_log_window"

	self.tab_list = {}
end

function GuildwarBattleLogWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 1)

    local win_title = container:getChildByName("win_title")
    win_title:setString(TI18N("战场日志"))
    local tips_label = container:getChildByName("tips_label")
    tips_label:setString(TI18N("本次公会战战况"))

    local tab_container = container:getChildByName("tab_container")
    for i=1,2 do
		local object = {}
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local title = tab_btn:getChildByName("title")
            if i == 1 then
                title:setString(TI18N("战场日志"))
            elseif i == 2 then
                title:setString(TI18N("我的日志"))
            end
            title:setTextColor(cc.c4b(0xf5, 0xe0, 0xb9, 0xff))
			local tips = tab_btn:getChildByName("tips")

            object.tab_btn = tab_btn
			object.label = title
			object.index = i
			object.tips = tips
            self.tab_list[i] = object
        end
    end

    self.close_btn = container:getChildByName("close_btn")
    self.confirm_btn = container:getChildByName("confirm_btn")
    self.log_panel = container:getChildByName("log_panel")
    self.no_log_label = container:getChildByName("no_log_label")
    self.no_log_image = container:getChildByName("no_log_image")

    local bgSize = self.log_panel:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height-8)
    local setting = {
        item_class = GuildwarBattleLogItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 612,               -- 单元的尺寸width
        item_height = 163,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.log_panel, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function GuildwarBattleLogWindow:register_event(  )
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openBattleLogWindow(false)
		end
	end)
	
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openBattleLogWindow(false)
		end
	end)

	self.confirm_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openBattleLogWindow(false)
		end
	end)

	for k, object in pairs(self.tab_list) do
		if object.tab_btn then
			object.tab_btn:addTouchEventListener(function(sender, event_type)
				if event_type == ccui.TouchEventType.ended then
					playTabButtonSound()
					self:changeSelectedTab(object.index)
				end
			end)
		end
    end
end

function GuildwarBattleLogWindow:changeSelectedTab( index )
	if self.tab_object ~= nil and self.tab_object.index == index then return end
	if self.tab_object then
		self.tab_object.tab_btn:loadTextures(PathTool.getResFrame("common","common_2023"), "", "", LOADTEXT_TYPE_PLIST)
		self.tab_object.label:setTextColor(cc.c4b(245, 224, 185, 255)) 
		self.tab_object = nil
	end
	self.tab_object = self.tab_list[index]
	if self.tab_object then
		self.tab_object.tab_btn:loadTextures(PathTool.getResFrame("common","common_2021"), "", "", LOADTEXT_TYPE_PLIST)
		self.tab_object.label:setTextColor(cc.c4b(105, 55, 5, 255)) 
	end

	if self.data and next(self.data) ~= nil then
		self:refreshLogList()
	end
end

function GuildwarBattleLogWindow:refreshLogList(  )
	if self.tab_object and self.tab_object.index then
		if self.data and next(self.data) ~= nil then
			self.no_log_label:setVisible(false)
			self.no_log_image:setVisible(false)
		else
			self.no_log_label:setVisible(true)
			self.no_log_image:setVisible(true)
		end
		if self.tab_object.index == 1 then
			if self.all_log_data and next(self.all_log_data) ~= nil then
				self.item_scrollview:setData(self.all_log_data)
			else
				for i,lData in ipairs(self.data) do
					local is_win = false
					for _,args in pairs(lData.int_args) do
						if args.key == 5 then
							is_win = (args.val == 1) -- 全部日志中只显示胜利的
							break
						end
					end
					if is_win then
						table.insert(self.all_log_data, lData)
					end
				end
				self.item_scrollview:setData(self.all_log_data)
			end
		else
			if self.my_log_data and next(self.my_log_data) ~= nil then
				self.item_scrollview:setData(self.my_log_data)
			else
				local role_vo = RoleController:getInstance():getRoleVo()
				for i,lData in ipairs(self.data) do
					if role_vo.rid == lData.rid1 and role_vo.srv_id == lData.srv_id1 then
						table.insert(self.my_log_data, lData)
					end
				end
				self.item_scrollview:setData(self.my_log_data)
			end
		end
	end
end

function GuildwarBattleLogWindow:setData( data )
	self.data = data
	self.all_log_data = {}
	self.my_log_data = {}
	self:refreshLogList()
end

function GuildwarBattleLogWindow:openRootWnd( index )
	index = index or 1
	self:changeSelectedTab(index)
	controller:requestBattleLogData()
end

function GuildwarBattleLogWindow:close_callback(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil

	controller:openBattleLogWindow(false)
end

---------------------------------------------
-- 子项
GuildwarBattleLogItem = class("GuildwarBattleLogItem", function()
    return ccui.Widget:create()
end)

function GuildwarBattleLogItem:ctor()
	self:configUI()
	self:register_event()
end

function GuildwarBattleLogItem:configUI(  )
	self.size = cc.size(616,163)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("guildwar/guildwar_battle_log_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.top_image = container:getChildByName("top_image")
    self.flag_image = container:getChildByName("flag_image")
    self.time_label = container:getChildByName("time_label")
    self.time_label:setTextColor(cc.c3b(169,95,15))
end

function GuildwarBattleLogItem:register_event(  )
	
end

function GuildwarBattleLogItem:setData( data )
	if data.flag1 == 1 then -- 本方
		self.top_image:loadTexture(PathTool.getResFrame("guildwar","guildwar_1025"), LOADTEXT_TYPE_PLIST)
	elseif data.flag1 == 0 then -- 敌方
		self.top_image:loadTexture(PathTool.getResFrame("guildwar","guildwar_1026"), LOADTEXT_TYPE_PLIST)
	end

	--[[if data.flag2 == 0 then
		self.flag_image:loadTexture(PathTool.getResFrame("guildwar","guildwar_1028"), LOADTEXT_TYPE_PLIST)
	elseif data.flag2 == 1 then
		self.flag_image:loadTexture(PathTool.getResFrame("guildwar","guildwar_1027"), LOADTEXT_TYPE_PLIST)
	end--]]
	self.flag_image:loadTexture(PathTool.getResFrame("guildwar","guildwar_1027"), LOADTEXT_TYPE_PLIST)

	self.time_label:setString(TimeTool.getYMDHMS(data.time))

	local role_vo = RoleController:getInstance():getRoleVo()

	local myGuildSrvName = self:getLogSrvName(role_vo.gsrv_id) -- 我方联盟服务器名
	local myRoleSrvName = self:getLogSrvName(data.srv_id1)     -- 我方玩家务器名
	local myRoleName = data.name1 or "" 					   -- 我方玩家名称
	local myGuildName = role_vo.gname or ""					   -- 我方联盟名称
	local enemyGuildSrvName = self:getLogSrvName(data.srv_id)  -- 敌方联盟服务器名
	local enemyRoleSrvName = self:getLogSrvName(data.srv_id2)  -- 敌方玩家务器名
	local enemyRoleName = data.name2 or ""					   -- 敌方玩家名称
	local enemyGuildName = data.gname or "" 				   -- 敌方联盟名

	local star_num = 0 -- 获得星数
	local battle_score = 0 -- 获得战绩
	local enemy_total = 0 -- 敌方总积分
	local buff_lev = 0 -- buff等级
	local is_win = false -- 是否胜利
	local self_total = 0 -- 我方星数
	for k,args in pairs(data.int_args) do
		if args.key == 1 then
			star_num = args.val
		elseif args.key == 2 then
			battle_score = args.val
		elseif args.key == 3 then
			enemy_total = args.val
		elseif args.key == 4 then
			buff_lev = args.val
		elseif args.key == 5 then
			is_win = (args.val == 1)
		elseif args.key == 6 then
			self_total = args.val
		end
	end

	local star_path = PathTool.getResFrame("guildwar","guildwar_1007")
	local star_str = ""
	if star_num > 0 then
		for i=1,star_num do
			star_str = star_str .. string.format("<img src='%s' scale=1 />", star_path)
		end
	end

	local log_str = ""
	if data.flag1 == 1 and data.flag2 == 2 then       -- 我方进攻废墟
		if role_vo.rid == data.rid1 and role_vo.srv_id == data.srv_id1 then -- 玩家自己
			if is_win then
				log_str = string.format(TI18N("      <div fontcolor=#3a78c4>%s</div>挑战<div fontcolor=#d95014>%s%s</div>废墟成功，将公会Buff等级提升至<div fontcolor=#a838bc>%d级</div>。"), myRoleName,enemyRoleSrvName,enemyRoleName,buff_lev)
			else
				log_str = string.format(TI18N("      很遗憾，<div fontcolor=#3a78c4>%s</div>挑战<div fontcolor=#d95014>%s%s</div>废墟失败，下次将卷土重来！"), myRoleName,enemyRoleSrvName,enemyRoleName)
			end
		else
			log_str = string.format(TI18N("      公会成员<div fontcolor=#3a78c4>%s</div>挑战<div fontcolor=#d95014>%s%s</div>废墟成功，将公会Buff等级提升至<div fontcolor=#a838bc>%d级</div>。"), myRoleName,enemyRoleSrvName,enemyRoleName,buff_lev)
		end
	elseif data.flag1 == 1 and data.flag2 == 1 then   -- 我方进攻据点
		if role_vo.rid == data.rid1 and role_vo.srv_id == data.srv_id1 then -- 玩家自己
			if is_win then
				log_str = string.format(TI18N("      <div fontcolor=#3a78c4>%s</div>挑战<div fontcolor=#d95014>%s%s</div>据点成功，获得[%s]和<div fontcolor=#249003>战绩%s点</div>，己方公会<div fontcolor=#249003>%s%s</div>当前星数为<img src='%s' scale=1 /><div fontcolor=#a838bc>%d</div>。"), myRoleName,enemyRoleSrvName,enemyRoleName,star_str,battle_score,myGuildSrvName,myGuildName,star_path,self_total)
			else
				log_str = string.format(TI18N("      很遗憾，<div fontcolor=#3a78c4>%s</div>挑战<div fontcolor=#d95014>%s%s</div>据点失败，下次将卷土重来！"), myRoleName,enemyRoleSrvName,enemyRoleName)
			end
		else
			log_str = string.format(TI18N("      公会成员<div fontcolor=#3a78c4>%s</div>挑战<div fontcolor=#d95014>%s%s</div>据点成功，获得[%s]和<div fontcolor=#249003>战绩%s点</div>，己方公会<div fontcolor=#249003>%s%s</div>当前星数为<img src='%s' scale=1 /><div fontcolor=#a838bc>%d</div>。"), myRoleName,enemyRoleSrvName,enemyRoleName,star_str,battle_score,myGuildSrvName,myGuildName,star_path,self_total)
		end
	elseif data.flag1 == 0 and data.flag2 == 2 then   -- 敌方进攻废墟
		if role_vo.rid == data.rid1 and role_vo.srv_id == data.srv_id1 and not is_win then -- 敌方挑战我的废墟失败
			log_str = string.format(TI18N("      <div fontcolor=#3a78c4>%s</div>的废墟抵挡住了敌方公会成员<div fontcolor=#d95014>%s%s</div>的挑战，固若金汤！"), myRoleName,enemyRoleSrvName,enemyRoleName)
		else
			log_str = string.format(TI18N("      敌方公会成员<div fontcolor=#d95014>%s%s</div>挑战<div fontcolor=#3a78c4>%s%s</div>废墟成功，将公会Buff等级提升至<div fontcolor=#a838bc>%d级</div>。"),enemyRoleSrvName,enemyRoleName,myRoleSrvName,myRoleName,buff_lev)
		end		
	elseif data.flag1 == 0 and data.flag2 == 1 then   -- 敌方进攻据点
		if role_vo.rid == data.rid1 and role_vo.srv_id == data.srv_id1 and not is_win then -- 敌方挑战我的据点失败
			log_str = string.format(TI18N("      <div fontcolor=#3a78c4>%s</div>的据点抵挡住了敌方公会成员<div fontcolor=#d95014>%s%s</div>的挑战，固若金汤！"), myRoleName,enemyRoleSrvName,enemyRoleName)
		else
			log_str = string.format(TI18N("      敌方公会成员<div fontcolor=#d95014>%s%s</div>挑战<div fontcolor=#3a78c4>%s%s</div>据点成功，获得[%s]和<div fontcolor=#249003>战绩%s点</div>，敌方公会<div fontcolor=#d95014>%s%s</div>当前星数为<img src='%s' scale=1 /><div fontcolor=#a838bc>%d</div>。"),enemyRoleSrvName,enemyRoleName,myRoleSrvName,myRoleName,star_str,battle_score,enemyGuildSrvName,enemyGuildName,star_path,enemy_total)
		end		
	end

	if not self.log_text then
		self.log_text = createRichLabel(22, cc.c3b(104,69,42), cc.p(0,0.5), cc.p(20, 63), 8, nil, 576)
		self.container:addChild(self.log_text)
	end
	self.log_text:setString(log_str)
end

function GuildwarBattleLogItem:getLogSrvName( srv_id )
	if not srv_id then return "" end
	local index = string.find(srv_id, "_")
	local srv_index = 1
	if index then
		srv_index = string.sub(srv_id, index+1)
	end
	local srvName = "[s" .. srv_index .."]"
	return srvName
end

function GuildwarBattleLogItem:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end