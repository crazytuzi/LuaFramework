--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-01 20:37:25
-- @description    : 
		-- 天梯战报
---------------------------------
LadderLogWindow = LadderLogWindow or BaseClass(BaseView)

local controller = LadderController:getInstance()
local model = controller:getModel()

function LadderLogWindow:__init()
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "ladder/ladder_log_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), type = ResourcesType.single },
	}

	self.tab_list = {}
end

function LadderLogWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container , 1) 

	local win_title = container:getChildByName("win_title")
	win_title:setString(TI18N("战 报"))

	self.title_bg = container:getChildByName("title_bg")
	local enemy_title = self.title_bg:getChildByName("enemy_title")
	enemy_title:setString(TI18N("对手"))
	local more_title = self.title_bg:getChildByName("more_title")
	more_title:setString(TI18N("详细"))

	self.share_panel = self.root_wnd:getChildByName("share_panel")
	self.share_panel:setVisible(false)
	local share_bg = self.share_panel:getChildByName("share_bg")
	self.share_bg = share_bg
	self.btn_guild = share_bg:getChildByName("btn_guild")
	self.btn_world = share_bg:getChildByName("btn_world")
	self.btn_cross = share_bg:getChildByName("btn_cross")
	local guild_label = share_bg:getChildByName("guild_label")
	guild_label:setString(TI18N("公会频道"))
	local world_label = share_bg:getChildByName("world_label")
	world_label:setString(TI18N("世界频道"))
	local cross_label = share_bg:getChildByName("cross_label")
	cross_label:setString(TI18N("跨服频道"))

	local tab_container = container:getChildByName("tab_container")
    for i=1,2 do
		local object = {}
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local title = tab_btn:getChildByName("title")
            if i == 1 then
                title:setString(TI18N("我的记录"))
            elseif i == 2 then
                title:setString(TI18N("大神风采"))
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
    self.no_log_label = container:getChildByName("no_log_label")
    self.no_log_image = container:getChildByName("no_log_image")
    self.my_log_panel = container:getChildByName("my_log_panel")
    self.god_log_panel = container:getChildByName("god_log_panel")
    self.no_log_label:setString(TI18N("暂无战报"))

    local myLogBgSize = self.my_log_panel:getContentSize()
	local scroll_view_size = cc.size(myLogBgSize.width, myLogBgSize.height-8)
    local setting = {
        item_class = LadderMyLogItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = -5,                    -- 第一个单元的Y起点
        space_y = -5,                   -- y方向的间隔
        item_width = 612,               -- 单元的尺寸width
        item_height = 135,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }

    self.my_log_scrollview = CommonScrollViewLayout.new(self.my_log_panel, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.my_log_scrollview:setSwallowTouches(false)

    local godLogBgSize = self.god_log_panel:getContentSize()
	local scroll_view_size = cc.size(godLogBgSize.width, godLogBgSize.height-8)
    local setting = {
        item_class = LadderGodLogItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 612,               -- 单元的尺寸width
        item_height = 153,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }

    self.god_log_scrollview = CommonScrollViewLayout.new(self.god_log_panel, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.god_log_scrollview:setSwallowTouches(false)
end

function LadderLogWindow:openRootWnd( index )
	index = index or 1
	self:changeSelectedTab(index)
end

function LadderLogWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.share_panel, handler(self, self._onClickSharePanel))
	registerButtonEventListener(self.btn_world, handler(self, self._onClickBtnShareWorld))
	registerButtonEventListener(self.btn_guild, handler(self, self._onClickBtnShareGuild))
	registerButtonEventListener(self.btn_cross, handler(self, self._onClickBtnShareCross))
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

    if self.ladder_mylog_event == nil then
        self.ladder_mylog_event = GlobalEvent:getInstance():Bind(LadderEvent.UpdateLadderMyLogData, function ( data )
            self.my_log_replay_srv_id = data.replay_srv_id
            if data.log_list then
            	self:setMyLogData(data.log_list)
            end
        end)
    end

    if self.ladder_godlog_event == nil then
        self.ladder_godlog_event = GlobalEvent:getInstance():Bind(LadderEvent.UpdateLadderGodLogData, function ( data )
            self.god_log_replay_srv_id = data.replay_srv_id
            if data.log_list then
            	self:setGodLogData(data.log_list)
            end
        end)
    end
end

function LadderLogWindow:_onClickSharePanel(  )
	self.share_panel:setVisible(false)
end

function LadderLogWindow:_onShowSharePanel( world_pos, replay_id, name, srv_id )
	self.replay_id = replay_id
	self.def_name = name
	self.share_srv_id = srv_id
	local node_pos = self.share_panel:convertToNodeSpace(world_pos)
	if node_pos then
		self.share_bg:setPosition(cc.p(node_pos.x-32, node_pos.y+70))
		self.share_panel:setVisible(true)
	end
end

function LadderLogWindow:_onClickBtnShareWorld(  )
	if self.replay_id and self.def_name and self.share_srv_id then
		controller:requestShareVideo( self.replay_id, self.share_srv_id, ChatConst.Channel.World, self.def_name )
	end
	self.share_panel:setVisible(false)
end

function LadderLogWindow:_onClickBtnShareGuild(  )
	local role_vo = RoleController:getInstance():getRoleVo()
	if role_vo and role_vo.gid ~= 0 and role_vo.gsrv_id ~= "" then
		if self.replay_id and self.def_name and self.share_srv_id then
			controller:requestShareVideo( self.replay_id, self.share_srv_id, ChatConst.Channel.Gang, self.def_name )
		end
	else
		message(TI18N("暂无公会"))
	end
	self.share_panel:setVisible(false)
end

function LadderLogWindow:_onClickBtnShareCross(  )
	if self.replay_id and self.def_name and self.share_srv_id then
		controller:requestShareVideo( self.replay_id, self.share_srv_id, ChatConst.Channel.Cross, self.def_name )
	end
	self.share_panel:setVisible(false)
end

function LadderLogWindow:changeSelectedTab( index )
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

	self.title_bg:setVisible(index == 1)
	self.my_log_scrollview:setVisible(index == 1)
	self.god_log_scrollview:setVisible(index == 2)

	if (index == 1 and self.myLogData and next(self.myLogData) ~= nil) or (index == 2 and self.godLogData and next(self.godLogData) ~= nil) then
		self.no_log_image:setVisible(false)
		self.no_log_label:setVisible(false)
	else
		self.no_log_image:setVisible(true)
		self.no_log_label:setVisible(true)
	end

	if index == 1 and not self.init_my_log then
		controller:requestMyLogData()
		self.init_my_log = true
	elseif index == 2 and not self.init_god_log then
		controller:requestGodLogData()
		self.init_god_log = true
	end
end

function LadderLogWindow:setMyLogData( myLogData )
	if self.tab_object == nil or self.tab_object.index ~= 1 then return end
	self.myLogData = myLogData
	if myLogData and next(myLogData) ~= nil then
		self.my_log_scrollview:setVisible(true)
		self.no_log_image:setVisible(false)
		self.no_log_label:setVisible(false)

		local extend = {}
		extend.callback = handler(self,self._onShowSharePanel)
		extend.replay_srv_id = self.my_log_replay_srv_id
		self.my_log_scrollview:setData(myLogData,nil,nil,extend)
	else
		self.my_log_scrollview:setVisible(false)
		self.no_log_image:setVisible(true)
		self.no_log_label:setVisible(true)
	end
end

function LadderLogWindow:setGodLogData( godLogData )
	if self.tab_object == nil or self.tab_object.index ~= 2 then return end
	self.godLogData = godLogData
	if godLogData and next(godLogData) ~= nil then
		self.god_log_scrollview:setVisible(true)
		self.no_log_image:setVisible(false)
		self.no_log_label:setVisible(false)

		self.god_log_scrollview:setData(godLogData,nil,nil,self.god_log_replay_srv_id)
	else
		self.god_log_scrollview:setVisible(false)
		self.no_log_image:setVisible(true)
		self.no_log_label:setVisible(true)
	end
end

function LadderLogWindow:_onClickBtnClose(  )
	controller:openLadderLogWindow(false)
end

function LadderLogWindow:close_callback(  )
	model:updateLadderRedStatus(LadderConst.RedType.BattleLog, false)
	controller:openLadderLogWindow(false)

	if self.ladder_mylog_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.ladder_mylog_event)
        self.ladder_mylog_event = nil
    end

    if self.ladder_godlog_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.ladder_godlog_event)
        self.ladder_godlog_event = nil
    end

	if self.my_log_scrollview then
		self.my_log_scrollview:DeleteMe()
	end
	self.my_log_scrollview = nil

	if self.god_log_scrollview then
		self.god_log_scrollview:DeleteMe()
	end
	self.god_log_scrollview = nil
end

------------------------------@ 我的记录item
LadderMyLogItem = class("LadderMyLogItem", function()
    return ccui.Widget:create()
end)

function LadderMyLogItem:ctor()
	self:configUI()
	self:register_event()
end

function LadderMyLogItem:configUI(  )
	self.size = cc.size(612,135)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("ladder/ladder_my_log_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.attk_label = container:getChildByName("attk_label")
    self.name_label = container:getChildByName("name_label")
    self.defend_label = container:getChildByName("defend_label")
    self.time_label = container:getChildByName("time_label")
    self.btn_share = container:getChildByName("btn_share")
    self.btn_watch = container:getChildByName("btn_watch")
    self.rank_label = createRichLabel(22, cc.c3b(169,95,15), cc.p(0, 0.5), cc.p(275, 30))
    container:addChild(self.rank_label)
    self.my_head = PlayerHead.new(PlayerHead.type.circle)
    self.my_head:setHeadLayerScale(0.7)
    self.my_head:setPosition(60, 85)
    container:addChild(self.my_head)

    local function onClickHeadCallBack(  )
    	if self.data then
    		if self.data.srv_id == "robot" then
    			message(TI18N("神秘人太高冷，不给查看"))
    		else
    			local f_data = {rid = self.data.rid, srv_id = self.data.srv_id}
				ChatController:getInstance():openFriendInfo(f_data,cc.p(0,0))
    		end
    	end
    end
    self.my_head:addCallBack(onClickHeadCallBack)
end

function LadderMyLogItem:register_event(  )
	registerButtonEventListener(self.btn_share, handler(self, self._onClickBtnShare))
	registerButtonEventListener(self.btn_watch, handler(self, self._onClickBtnWatch))
end

function LadderMyLogItem:_onClickBtnShare( param, sender, event_type )
	local world_pos = sender:convertToWorldSpace(cc.p(0, 0))
	if self._onShareCallBack and self.data then
		local srv_id = self.data.srv_id
		if self.data.type == 1 then -- 如果是进攻，则取自身的srv_id
			local role_vo = RoleController:getInstance():getRoleVo()
			srv_id = role_vo.srv_id
		end
		self._onShareCallBack(world_pos, self.data.replay_id, self.data.name, srv_id)
	end
end

function LadderMyLogItem:_onClickBtnWatch(  )
	if self.data and self.replay_srv_id then
		local srv_id = self.replay_srv_id
		if self.data.type == 2 then
			srv_id = self.data.srv_id
		end
		BattleController:getInstance():csRecordBattle(self.data.replay_id, srv_id)
	end
end

function LadderMyLogItem:setExtendData( extend )
	self._onShareCallBack = extend.callback
	self.replay_srv_id = extend.replay_srv_id
end

function LadderMyLogItem:setData( data )
	data = data or {}
	self.data = data

	self.my_head:setHeadRes(data.face, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
	self.attk_label:setString(data.power or 0)
	self.name_label:setString(transformNameByServ(data.name, data.srv_id))

	local time_str = TimeTool.getYMDHMS(data.time)
	time_str = string.sub(time_str, 3, -1)
	self.time_label:setString(time_str)

	if data.type == 1 and data.ret == 1 then
		self.defend_label:setTextColor(cc.c3b(36, 144, 3))
		self.defend_label:setString(TI18N("进攻成功"))
	elseif data.type == 1 and data.ret == 2 then
		self.defend_label:setTextColor(cc.c3b(217, 80, 20))
		self.defend_label:setString(TI18N("进攻失败"))
	elseif data.type == 2 and data.ret == 1 then
		self.defend_label:setTextColor(cc.c3b(36, 144, 3))
		self.defend_label:setString(TI18N("防守成功"))
	elseif data.type == 2 and data.ret == 2 then
		self.defend_label:setTextColor(cc.c3b(217, 80, 20))
		self.defend_label:setString(TI18N("防守失败"))
	end

	if data.rank_type == 0 then
		self.rank_label:setString(TI18N("排名保持不变"))
	elseif data.rank_type == 1 then
		self.rank_label:setString(string.format(TI18N("排名升至<div fontcolor=#249003>%d</div>名"), data.rank or 0))
	elseif data.rank_type == 2 then
		if not data.rank or data.rank <= 0 then
			self.rank_label:setString(TI18N("排名降至<div fontcolor=#D95014>1000名外</div>"))
		else
			self.rank_label:setString(string.format(TI18N("排名降至<div fontcolor=#D95014>%d</div>名"), data.rank or 0))
		end
	end
end

function LadderMyLogItem:DeleteMe(  )
	if self.my_head then
		self.my_head:DeleteMe()
		self.my_head = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end

--------------------------------------@ 大神风采 item
LadderGodLogItem = class("LadderGodLogItem", function()
    return ccui.Widget:create()
end)

function LadderGodLogItem:ctor()
	self:configUI()
	self:register_event()
end

function LadderGodLogItem:configUI(  )
	self.size = cc.size(612,153)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("ladder/ladder_god_log_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.time_label = container:getChildByName("time_label")
    self.rank_label_1 = container:getChildByName("rank_label_1")
    self.name_label_1 = container:getChildByName("name_label_1")
    self.rank_label_2 = container:getChildByName("rank_label_2")
    self.name_label_2 = container:getChildByName("name_label_2")
    self.btn_watch = container:getChildByName("btn_watch")

    self.role_head_1 = PlayerHead.new(PlayerHead.type.circle)
    self.role_head_1:setHeadLayerScale(0.8)
    self.role_head_1:setPosition(60, 88)
    container:addChild(self.role_head_1)

    self.role_head_2 = PlayerHead.new(PlayerHead.type.circle)
    self.role_head_2:setHeadLayerScale(0.8)
    self.role_head_2:setPosition(480, 88)
    container:addChild(self.role_head_2)

    local function onClickHeadCallBack(  )
    	self:_onClickRoleHead(1)
    end
    self.role_head_1:addCallBack(onClickHeadCallBack)

    local function onClickHeadCallBack(  )
    	self:_onClickRoleHead(2)
    end
    self.role_head_2:addCallBack(onClickHeadCallBack)
end

function LadderGodLogItem:_onClickRoleHead( index )
	local roleVo = RoleController:getInstance():getRoleVo()
	if self.data then
		local rid
		local srv_id
		if index == 1 then
			rid = self.data.atk_rid
			srv_id = self.data.atk_srv_id
		elseif index == 2 then
			rid = self.data.def_rid
			srv_id = self.data.def_srv_id
		end
		if rid and srv_id then
			if srv_id == "robot" then
				message(TI18N("神秘人太高冷，不给查看"))
			elseif roleVo.rid == rid and roleVo.srv_id == srv_id then
				message(TI18N("你不认识你自己了么？"))
			else
				local f_data = {rid = rid, srv_id = srv_id}
				ChatController:getInstance():openFriendInfo(f_data,cc.p(0,0))
			end
		end
	end
end

function LadderGodLogItem:register_event(  )
	registerButtonEventListener(self.btn_watch, handler(self, self._onClickBtnWatch))
end

function LadderGodLogItem:_onClickBtnWatch(  )
	if self.data and self.data.replay_id and self.data.atk_srv_id then
		BattleController:getInstance():csRecordBattle(self.data.replay_id, self.data.atk_srv_id)
	end
end

function LadderGodLogItem:setExtendData( replay_srv_id )
	self.replay_srv_id = replay_srv_id
end

function LadderGodLogItem:setData( data )
	data = data or {}
	self.data = data

	self.time_label:setString(TimeTool.getYMDHMS(data.time or 0))

	-- 进攻方
	self.role_head_1:setHeadRes(data.atk_face, false, LOADTEXT_TYPE, data.atk_face_file, data.atk_face_update_time)
	self.rank_label_1:setString(string.format(TI18N("排名：%d"), data.atk_rank or 0))
	self.name_label_1:setString(transformNameByServ(data.atk_name, data.atk_srv_id))

	-- 防守方
	self.role_head_2:setHeadRes(data.def_face, false, LOADTEXT_TYPE, data.def_face_file ,data.def_face_update_time)
	self.rank_label_2:setString(string.format(TI18N("排名：%d"), data.def_rank or 0))
	self.name_label_2:setString(transformNameByServ(data.def_name, data.def_srv_id))

	if data.ret == 1 then
		self.role_head_1:showBattleResultIcon(1)
		self.role_head_2:showBattleResultIcon(0)
	else
		self.role_head_1:showBattleResultIcon(0)
		self.role_head_2:showBattleResultIcon(1)
	end
end

function LadderGodLogItem:DeleteMe(  )
	if self.role_head_1 then
		self.role_head_1:DeleteMe()
		self.role_head_1 = nil
	end

	if self.role_head_2 then
		self.role_head_2:DeleteMe()
		self.role_head_2 = nil
	end

	self:removeAllChildren()
	self:removeFromParent()
end