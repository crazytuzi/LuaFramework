-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      护送主界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EscortMainWindow = EscortMainWindow or BaseClass(BaseView)

local controller = EscortController:getInstance()
local model = controller:getModel()
local table_remove = table.remove
local table_insert = table.insert
local game_net = GameNet:getInstance()
local role_vo = RoleController:getInstance():getRoleVo()

function EscortMainWindow:__init()
	self.is_full_screen = true
	self.view_tag = ViewMgrTag.EFFECT_TAG 
	self.win_type = WinType.Full
	self.index = 2 
	self.layout_name = "escort/escort_main_window"
	self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_53", true), type = ResourcesType.single},
		{path = PathTool.getPlistImgForDownLoad("escort", "escort"), type = ResourcesType.plist},
	}
	self.escort_player_list = {}			-- 护送列表
	self.escort_player_pool = {}			-- 当移动到最待距离的时候,就把该对象丢到缓存列表去

	self.render_list = {}

	self.step = 1
	self.step_interval = 5

	self.escort_pos_list = {}				-- 当前护送位置
end

function EscortMainWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_53", true), LOADTEXT_TYPE)
	self.background:setPositionY(98+display.getBottom())

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)

	self.container = main_container:getChildByName("container")

	self.explain_btn = main_container:getChildByName("explain_btn")

	self.bottom = main_container:getChildByName("bottom")
	self.finish_btn = self.bottom:getChildByName("finish_btn")				-- 立即完成或者刷新列表的面板
	self.finish_btn_label = self.finish_btn:getChildByName("label")			-- 根据自身状态显示不同的label
	self.finish_btn_tips = self.finish_btn:getChildByName("tips")
	self.escort_times = self.bottom:getChildByName("escort_times")			-- 今日剩余护送次数
	self.atk_times = self.bottom:getChildByName("atk_times")				-- 今日剩余打劫次数
	self.in_escort_time = self.bottom:getChildByName("in_escort_time")		-- 当前护送剩余时间
	self.in_escort_title = self.bottom:getChildByName("in_escort_title")
	self.in_escort_title:setString(TI18N("护送中:"))

	self.bottom:getChildByName("escort_title"):setString(TI18N("雇佣次数:"))
	self.bottom:getChildByName("atk_title"):setString(TI18N("掠夺次数:"))
	-- 做一下适配报读
	self.bottom:setPositionY(MainuiController:getInstance():getBottomHeight()+display.getBottom())

	local title_container = main_container:getChildByName("title_container")
	title_container:getChildByName("label"):setString(TI18N("萌兽寻宝"))
	local title_bg = title_container:getChildByName("title_bg")
	title_bg:setContentSize(cc.size(SCREEN_WIDTH, 50))
	self.close_btn = title_container:getChildByName("close_btn")
	self.close_btn:setPositionX(SCREEN_WIDTH)

	self.log_btn = main_container:getChildByName("log_btn")
	self.log_btn:getChildByName("label"):setString(TI18N("掠夺记录"))
	self.log_tips = self.log_btn:getChildByName("tips")
	
	local top_y = title_container:getPositionY()
	local bottom_y = self.bottom:getPositionY() + self.bottom:getContentSize().height 

	self.container_size = cc.size(SCREEN_WIDTH, top_y - bottom_y - 224)
	self.container_center_y = self.container_size.height * 0.5
	self.container:setPositionY(self.bottom:getPositionY() + self.bottom:getContentSize().height)
	self.container:setContentSize(self.container_size)
end

function EscortMainWindow:register_event()
	self.close_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
    		controller:openEscortMainWindow(false)
		end
	end)
	self.finish_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.my_status == 1 then			-- 我要雇佣
				controller:openEscortEmployWindow(true)
			else
				controller:openEscortMyInfoWindow(true)
			end
		end
	end)
	self.log_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			controller:openEscortLogWindow(true)
			-- 关掉被打劫红点
			model:updateEscortRedStatus(RedPointType.escort_plunder, false)
			self.log_tips:setVisible(false)
		end
	end)
	self.explain_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			MainuiController:getInstance():openCommonExplainView(true, Config.EscortData.data_explain)
		end
	end)
	if self.update_base_info_event == nil then
		self.update_base_info_event = GlobalEvent:getInstance():Bind(EscortEvent.UpdateEscortBaseEvent, function()
			self:initPlunderList()
		end)
	end

	if self.update_my_info_event == nil then
		self.update_my_info_event = GlobalEvent:getInstance():Bind(EscortEvent.UpdateEscortMyInfoEvent, function() 
			self:updateMyInfo(true)
		end)
	end

	if self.update_escort_player_list_event == nil then
		self.update_escort_player_list_event = GlobalEvent:getInstance():Bind(EscortEvent.UpdateEscortPlayerList, function(data)
			self:updateEscortPlayerList(data)
		end)
	end
	
    if self.chat_ui_size_change == nil then
        self.chat_ui_size_change = GlobalEvent:getInstance():Bind(EventId.CHAT_HEIGHT_CHANGE, function() 
			self.bottom:setPositionY(MainuiController:getInstance():getBottomHeight()+display.getBottom())
        end)
    end
end

function EscortMainWindow:openRootWnd(data)
	controller:requestEscortBaseInfo(rid, srv_id)

	self:setWindowData(data)

	RenderMgr:getInstance():add(self)
	if self.time_ticket == nil then
		self.time_ticket = GlobalTimeTicket:getInstance():add(function()
			self:timeTicketCount()
		end, 1)
	end
	-- 更新自身数据
	self:updateMyInfo()
end

--==============================--
--desc:可能在打开面板的情况下 通过聊天连接进来之后
--time:2018-09-05 01:56:00
--@data:
--@return 
--==============================--
function EscortMainWindow:setWindowData(data)
	if data == nil or data.rid == 0 or data.srv_id == "" then return end
	if data.type ~= nil then
		controller:requestPlunderInfo(data.rid, data.srv_id, data.id, data.type)
	else
		controller:requestCheckEscortPlayer(data.rid, data.srv_id)
	end
end

function EscortMainWindow:timeTicketCount()
	self.step = self.step + 1
	-- 每隔5秒创建一个
	if self.step % self.step_interval == 0 then
		self:createEscortItem()
	end
	-- 每秒计算一下倒计时
	self:countEndTime()

	-- 如果自己在护送中,则刷新时间
	self:countDownMyInfo()
end

function EscortMainWindow:countEndTime()
	for k, player in pairs(self.escort_player_list) do
		player:changeTime()
	end
end

--==============================--
--desc:计算自己的护送时间状态
--time:2018-09-04 10:24:32
--@return 
--==============================--
function EscortMainWindow:countDownMyInfo()
	if self.my_info then
		if self.my_info.status == 1 then
			local _time = self.my_info.end_time - game_net:getTime()
			if _time >= 0 then
				self.in_escort_time:setString(TimeTool.GetTimeFormat(_time))
			else
				if self.my_status ~= 0 then
					self.finish_btn_label:setString(TI18N("夺宝完成"))
					self.in_escort_title:setVisible(false)
					self.in_escort_time:setVisible(false)
					self.my_status = 0
				end
			end
		end
	end
end

--==============================--
--desc:刷新自身,是事件的才做创建移除处理
--time:2018-09-03 10:09:07
--@is_event:
--@return 
--==============================--
function EscortMainWindow:updateMyInfo(is_event)
	local my_info = model:getMyInfo()
	self.my_info = my_info 
	self.my_status = 0
	if my_info then
		self:updateMyBaseCount()
		if my_info.status == 1 then -- 进行中
			if my_info.end_time <= game_net:getTime() then
				self.finish_btn_label:setString(TI18N("夺宝完成"))
				self.in_escort_title:setVisible(false)
				self.in_escort_time:setVisible(false)
			else
				self.finish_btn_label:setString(TI18N("立即完成"))
				self.in_escort_title:setVisible(true)
				self.in_escort_time:setVisible(true)
				self:countDownMyInfo()
			end
		else
			self.my_status = 1
			self.finish_btn_label:setString(TI18N("我要雇佣"))
			self.in_escort_title:setVisible(false)
			self.in_escort_time:setVisible(false)
		end
		-- 事件更新的话,就可能存在,是添加或者是移除
		if is_event == true then
			self:checkMyInfoStatus()
		end
		-- 红点
		local have_times = model:checkRedStatus(RedPointType.escort)
		local have_awards = model:checkRedStatus(RedPointType.escort_awards) 
		local be_plunder = model:checkRedStatus(RedPointType.escort_plunder) 

		if have_times and my_info.status == 0 then
			self.finish_btn_tips:setVisible(true)
		elseif have_awards == true then
			self.finish_btn_tips:setVisible(true)
		else
			self.finish_btn_tips:setVisible(false)
		end
		self.log_tips:setVisible(be_plunder)
	end
end

--==============================--
--desc:更新自己的一些关联次数数据
--time:2018-09-04 11:21:11
--@return 
--==============================--
function EscortMainWindow:updateMyBaseCount()
	if self.my_info == nil then return end
	local my_info = self.my_info
	local max_escort_times = model:getMyMaxCount(EscortConst.times_type.escort)
	local max_plunder_times = model:getMyMaxCount(EscortConst.times_type.plunder) 
	
	-- 已护送次数
	local num_1 = max_escort_times - model:getMyCount(EscortConst.times_type.escort)
	if num_1 < 0 then num_1 = 0 end
	
	-- 已掠夺次数
	local num_2 = max_plunder_times - model:getMyCount(EscortConst.times_type.plunder)
	if num_2 < 0 then num_2 = 0 end
	if num_2 == 0 then
		self.atk_times:setTextColor(cc.c4b(0xff,0x33,0x1b,0xff))
	else
		self.atk_times:setTextColor(cc.c4b(0x14,0xff,0x32,0xff)) 
	end
	self.escort_times:setString(num_1.."/"..max_escort_times)
	self.atk_times:setString(num_2.."/".. max_plunder_times)


	GlobalEvent:getInstance():Fire(ActivityEvent.EscortCount)
end

function EscortMainWindow:checkMyInfoStatus()
	if self.my_info == nil then return end

	local my_info = self.my_info
	if my_info.status == 0 then			-- 状态未开始
		self:removeEscortPlayer(role_vo.rid, role_vo.srv_id)
	elseif my_info.status == 1 then		-- 状态进行中
		-- 状态变化也可能存在是自己其他属性,所以要判断当前是否存在以及待创建的缓存是否存在
		local need_create = true
		for i,v in ipairs(self.render_list) do
			if getNorKey(role_vo.rid, role_vo.srv_id) == getNorKey(v.rid, v.srv_id) then
				need_create = false
				break
			end
		end
		if need_create == true then
			if self.escort_player_list[getNorKey(role_vo.rid, role_vo.srv_id)] ~= nil then
				need_create = false
			end
		end
		if need_create == true then
			self:insertMyInfoToList()
		end
	end
end

--==============================--
--desc:没隔1秒中,从初始位置创建一个互动对象出来,这个也可呢是新的,也有可能是运送到尽头循环回来的
--time:2018-09-03 02:10:34
--@return 
--==============================--
function EscortMainWindow:createEscortItem(init)
	if next(self.render_list) == nil then return end
	local data = table_remove( self.render_list, 1 )
	local player = nil
	if #self.escort_player_pool > 0 then
		player = table_remove( self.escort_player_pool, 1)
	else
		player = EscortPlayer.New(self.container)
	end
	local _x, _y = 0, 0
	if self.index == 1 then
		_y = math.random(0, 25)
	elseif self.index == 2 then
		_y = math.random( self.container_center_y-50, self.container_center_y+50 )
	elseif self.index == 3 then
		_y = math.random( self.container_size.height-100, self.container_size.height  )
	end
	if init == true then
		_x = math.random( 100, self.container_size.width*0.5 )
	else
		_x = math.random( -100, 0 )
	end
	player:handlePlayerStatus(true)
	player:setData(data)
	player:setWorldPos(_x, _y)

	-- 按照key区缓存起来
	self.escort_player_list[getNorKey(data.rid, data.srv_id)] = player

	self.index = self.index + 1
	if self.index > 3 then
		self.index = 1
	end 
end

function EscortMainWindow:update()
	for i, player in pairs(self.escort_player_list) do
		player:move()
		if player:getPositionX() > (SCREEN_WIDTH + 100) then
			if player.data then
				self:removeEscortPlayer(player.data.rid, player.data.srv_id, true)
			end
		end
	end
end

--==============================--
--desc:移除一个对象,这个时候需要把这个对象丢到缓存池中区
--time:2018-09-03 10:13:32
--@rid:
--@srv_id:
--@is_return: 是否丢到数据列表中去,因为可能是移动到定了
--@return 
--==============================--
function EscortMainWindow:removeEscortPlayer(rid, srv_id, is_return)
	local player = self.escort_player_list[getNorKey(rid, srv_id)]
	if player then
		player:handlePlayerStatus(false)
		table_insert( self.escort_player_pool, player )
		self.escort_player_list[getNorKey(rid, srv_id)] = nil
		if is_return == true then
			table_insert(self.render_list, player.data)
		end
	end

	-- 这个时候表示干掉待创建的
	if not is_return then
		for i,v in ipairs(self.render_list) do
			if getNorKey(rid, srv_id) == getNorKey(v.rid, v.srv_id) then
				table_remove(self.render_list, i)
				break
			end
		end
	end
end

--==============================--
--desc:有其他玩家领取完成护送的时候更新的
--time:2018-09-04 10:51:06
--@data:
--@return 
--==============================--
function EscortMainWindow:updateEscortPlayerList(data)
	if data == nil then return end
	if data.rid ~=0 and data.srv_id ~= "" then
		self:removeEscortPlayer(data.rid, data.srv_id)
	end
	if data.plunders and next(data.plunders) then
		for i,v in ipairs(data.plunders) do
			table_insert(self.render_list, v)
		end
	end
end

--==============================--
--desc:初始化创建,先按照创建3个来处理吧
--time:2018-09-03 07:29:44
--@return 
--==============================--
function EscortMainWindow:initPlunderList()
	local list = model:getPlunderList()
	if list and next(list) then
		self.render_list = list		-- 这次打开需要渲染的数据列表
	end

	-- 这个时候判断一下自己在不在吧.,不管如何都把自己插进去
	self:insertMyInfoToList()

	-- 初始化创建3个
	for i=1,3 do
		self:createEscortItem(true)
	end
end

--==============================--
--desc:把自己数据查到列表最前面个,等下创建
--time:2018-09-03 10:30:17
--@return 
--==============================--
function EscortMainWindow:insertMyInfoToList()
	if self.my_info then
		if self.my_info.status == 1 then --进行中
			local object = {}
			object.rid = role_vo.rid
			object.srv_id = role_vo.srv_id
			object.name = role_vo.name
			object.quality = self.my_info.quality or 0
			object.end_time = self.my_info.end_time or 0
			object.gid = role_vo.gid
			object.gsrv_id = role_vo.gsrv_id
			table_insert(self.render_list, 1, object)
		end
	end
end

--==============================--
--desc:添加待创建的护送列表,这个可以插到前面去
--time:2018-09-03 08:23:44
--@list:
--@return 
--==============================--
function EscortMainWindow:addEscortList(list)
	if list == nil or next(list) == nil then return end
	for i,v in ipairs(list) do
		table_insert(self.render_list, 1, v)
	end
end

function EscortMainWindow:close_callback()
	for k, player in pairs(self.escort_player_list) do
		player:DeleteMe()
	end
	self.escort_player_list = nil
	for k, player in pairs(self.escort_player_pool) do
		player:DeleteMe()
	end
	self.escort_player_pool = nil

	RenderMgr:getInstance():remove(self)

	if self.time_ticket then
		GlobalTimeTicket:getInstance():remove(self.time_ticket)
		self.time_ticket = nil
	end
	if self.update_base_info_event then
		GlobalEvent:getInstance():UnBind(self.update_base_info_event)
		self.update_base_info_event = nil
	end
	if self.update_my_info_event then
		GlobalEvent:getInstance():UnBind(self.update_my_info_event)
		self.update_my_info_event = nil
	end
	if self.update_escort_player_list_event then
		GlobalEvent:getInstance():UnBind(self.update_escort_player_list_event)
		self.update_escort_player_list_event = nil
	end
	if self.chat_ui_size_change then
		GlobalEvent:getInstance():UnBind(self.chat_ui_size_change)
		self.chat_ui_size_change = nil
	end
	if self.add_escort_player_event then
		GlobalEvent:getInstance():UnBind(self.add_escort_player_event)
		self.add_escort_player_event = nil
	end
    controller:openEscortMainWindow(false)
end




-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      护送单位
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EscortPlayer = EscortPlayer or BaseClass()

function EscortPlayer:__init(parent)
    self.parent = parent
	self.is_self  = false
	self._x = 0
	self:createRoorWnd()
	self:registerEvent()
end

function EscortPlayer:createRoorWnd()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("escort/escort_play"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
	end
	self.root_wnd:setAnchorPoint(cc.p(0.5, 0))

	self.model = self.root_wnd:getChildByName("model")
	self.name_bg = self.root_wnd:getChildByName("name_bg")				-- Image
	self.time_bg = self.root_wnd:getChildByName("time_bg")				--
	self.my_icon = self.root_wnd:getChildByName("my_icon")
	self.role_name = self.root_wnd:getChildByName("role_name")
	self.time_label = self.root_wnd:getChildByName("time_label")
	self.touch = self.root_wnd:getChildByName("touch")
	self.be_plunder = self.root_wnd:getChildByName("be_plunder")
end

function EscortPlayer:registerEvent()
	self.touch:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data then
				if self.is_self then
					controller:openEscortMyInfoWindow(true)
				else
					controller:requestCheckEscortPlayer(self.data.rid, self.data.srv_id)
				end
			end
		end
	end)
end

function EscortPlayer:setWorldPos(x, y)
	self._x = x
	self.root_wnd:setPosition(x, y)
	self.root_wnd:setLocalZOrder(1280-y)
end

function EscortPlayer:move()
	self._x = self._x + 0.5
	self.root_wnd:setPositionX(self._x)
end

function EscortPlayer:getPositionX()
	return self._x
end

function EscortPlayer:handlePlayerStatus(status)
	self.root_wnd:setVisible(status)
end

--[[
    @desc: 剩余时间外部统一处理
    author:{author}
    time:2018-09-02 20:23:04
    @return:
]]
function EscortPlayer:changeTime()
	-- 只有自己才需要显示时间
	if not self.is_self then return end

	if self.data or self.data.end_time then
		local end_time = self.data.end_time - game_net:getTime()
		if end_time < 0 then
			end_time = 0
		end
		self.time_label:setString(TimeTool.GetTimeFormat(end_time))
	end
end

function EscortPlayer:setData(data)
	self.data = data
	self.is_self = false
	if data then
		self.is_self = getNorKey(data.rid, data.srv_id) == getNorKey(role_vo.rid, role_vo.srv_id)
		self.role_name:setString(data.name)
		self.my_icon:setVisible(self.is_self)
		self:createModel(data.quality)
		if self.is_self then
			self:changeTime()
		else
			local gname = TI18N("暂无公会")
			if data.gname ~= "" then
				gname = data.gname
			end
			self.time_label:setString(transformNameByServ(gname, data.srv_id))
		end

		local is_my_guild = getNorKey(data.gid, data.gsrv_id) == getNorKey(role_vo.gid, role_vo.gsrv_id) 
		if self.is_self then
			self.role_name:setTextColor(cc.c4b(0x68,0x45,0x2a,0xff))
		elseif is_my_guild == true and data.gid ~= 0 then
			self.role_name:setTextColor(cc.c4b(0x68,0x45,0x2a,0xff))
		else
			self.role_name:setTextColor(cc.c4b(0xd2,0x32,0x32,0xff))
		end

		-- 是否被掠夺过了
		local be_plunder = false	
		if data.plunder_lists and next(data.plunder_lists) then
			for i,v in ipairs(data.plunder_lists) do
				if getNorKey(role_vo.rid, role_vo.srv_id) == getNorKey(v.rid, v.srv_id) then
					be_plunder = true
				end
			end
		end
		self.be_plunder:setVisible(be_plunder)
	end
end

function EscortPlayer:createModel(quality)
	if self.quality == quality then return end
	self.quality = quality
	if self.body then
		self.body:removeFromParent()
		self.body = nil
	end
	
	-- local name_res = PathTool.getResFrame("escort", "escort_1" ..(quality + 1))
	-- self.name_bg:loadTexture(name_res, LOADTEXT_TYPE_PLIST)
	
	-- local time_res = PathTool.getResFrame("escort", "escort_" ..(quality + 1))
	-- loadSpriteTexture(self.time_bg, time_res, LOADTEXT_TYPE_PLIST)

	local config = Config.EscortData.data_baseinfo[quality]
	if config then
		self.body = createEffectSpine(config.res, cc.p(88, 0), cc.p(0.5, 0), true, PlayerAction.action)
		self.model:addChild(self.body)
	end
end

function EscortPlayer:__delete()
	if not tolua.isnull(self.root_wnd) then
		self.root_wnd:removeFromParent()
	end
end
