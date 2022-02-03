--[[
	服务器选择界面
]]
ServerPanel = class("ServerPanel", function() 
	return ccui.Widget:create()
end)

local table_insert = table.insert
local string_format = string.format
local table_sort = table.sort 
local table_remove= table.remove

function ServerPanel:ctor(parent, ctrl)
	self.ctrl = ctrl
	self.size = parent and parent:getContentSize() or cc.size(SCREEN_WIDTH, SCREEN_HEIGHT)
	self.last_login = 0
	self.model = self.ctrl:getModel()
	self.data = self.model:getLoginData()
    self:setContentSize(self.size)
	self:setPosition(self.size.width/2, self.size.height/2)
	self:setCascadeOpacityEnabled(true)

	self.server_item_list = {}			-- 当前显示的服务器列表
	self.server_poll_list = {}			-- 服务器列表对象池

	self.cell_list 		= {}
	self.tab_list 		= {}
	self.server_list 	= {}
	self.tui_list 		= {}
	self.tab_num 		= 0
	self.select_item 	= nil
	self.scroll_w       = 0
	self.scroll_h 		= 0
	self.recent_h		= 0
	self.cell_h			= 86      		-- Y间隔
	self.cell_w			= 429			-- X间距
	self.page_sum  		= 10 			-- 一页对多显示服务器列表个数
	self.pos_y 			= 0
	self.isRenderFinish = false
	self.is_have 		= false
	self:layoutUI()
	self:registerEvent()
end

function ServerPanel:layoutUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("login/server_panel_view"))
	self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
	self.root_wnd:setPosition(self.size.width / 2, self.size.height / 2)
	self:addChild(self.root_wnd)
	
	local main_container = self.root_wnd:getChildByName("main_container")
	main_container:getChildByName("win_title"):setString(TI18N("选择服务器"))

	self.btn_close = main_container:getChildByName("close_btn")

	-- 左侧服务器列表的父节点
	self.server_list = main_container:getChildByName("server_list")
	
	-- 右边滚动容器
	self.server_scroll_view = main_container:getChildByName("server_scroll_view")
	self.server_scroll_view:setScrollBarEnabled(false)
	self.scroll_h = self.server_scroll_view:getContentSize().height
	self.scroll_w = self.server_scroll_view:getContentSize().width

	if PLATFORM_NAME == "release2" then
		self.editbox =  createEditBox(self.root_wnd, PathTool.getResFrame("common", "common_1021"), cc.size(320,50), nil, 24, Config.ColorData.data_color3[151],
			20, "输入平台+服务器id", nil, nil, LOADTEXT_TYPE_PLIST, nil, nil--[[, cc.KEYBOARD_RETURNTYPE_SEND]])
		self.editbox:setPosition(360, 1000)
		local function editBoxTextEventHandle(strEventName,pSender)
			if strEventName == "return" or strEventName == "ended" then
				local server_name = pSender:getText()
				local all_server_list = LoginController:getInstance():getModel().server_list
				if all_server_list and next(all_server_list) then
					for k,v in pairs(all_server_list) do
						if server_name == v.main_srv_id then
							local loginData = self.model:getLoginData()
							self.model:setCurSrv(v, true)
							self.ctrl:requestLoginGame(loginData.usrName, v.ip, v.port, false, true)  
						end
					end
				end
			elseif strEventName == "began" then
			elseif strEventName == "changed" then
	
			end
		end
		self.editbox:registerScriptEditBoxHandler(editBoxTextEventHandle)
	end
    
	for i = 1, 3 do
		local label = main_container:getChildByName("status_tips_" .. i)
		if label then
			if i == 1 then
				label:setString(TI18N("爆满"))
			elseif i == 2 then
				label:setString(TI18N("流畅"))
			else
				label:setString(TI18N("维护"))
			end
		end
	end
end 

function ServerPanel:effectHandler()
end 

function ServerPanel:update()
	if self.scroll_view == nil then
		local size = self.server_list:getContentSize()
		local setting = {
			item_class = ServerListItem,
			start_x = 0,
			space_x = 0,
			start_y = 0,
			space_y = 0,
			item_width = 204,
			item_height = 86,
			row = 1,
			col = 1
		}
		self.scroll_view = CommonScrollViewLayout.new(self.server_list, nil, nil, nil, size, setting)
		
		self:renderServerList()
	end
end

--==============================--
--desc:渲染左侧服务器列表,主要是标签页
--time:2017-08-03 10:37:39
--@return 
--==============================--
function ServerPanel:renderServerList()
	self.server_list = self.model:getServerList()
	if self.server_list == nil or next(self.server_list) == nil then return end
	self.select_list_item = nil

	-- 按照服务器区号和服务器号重新排序
	local function sortFunc( a, b )
		if a.group_id == b.group_id then
			return tonumber(a.group_num) > tonumber(b.group_num)
		else
			return tonumber(a.group_id) > tonumber(b.group_id)
		end
	end
	table_sort(self.server_list, sortFunc)

	self.tab_list = {}
	self.cell_list = {}

	for k,v in ipairs(self.server_list) do
		local group_id = tonumber(v.group_id)
		if not self.tab_list[group_id] then -- group_id:区号，一定是从1开始且不间断往上增
			self.tab_list[group_id] = {}
		end
		table_insert(self.tab_list[group_id], v)
	end
	self.tab_num = #self.tab_list
	
	for i, v in ipairs(self.server_list) do
		if v.role_count > 0 then
			self.is_have = true
			break
		end
	end

	local function click_callback(item)
		self:changeTabBarIndex(item)
	end

	local server_list_data = {}
	table_insert(server_list_data, {order="recommend", desc=TI18N("推荐")})
	if self.is_have == true then
		table_insert(server_list_data, {order="role", desc=TI18N("角色")})
	end
	for i = self.tab_num, 1, - 1 do
		local group_data = self.tab_list[i]
		if group_data and group_data[1] then
			local group_id = group_data[1].group_id
			local group_name = LoginController:getInstance():getModel():getSrvGroupNameByGroupId(group_id)
			table_insert(server_list_data, {order=i, desc=group_name})
		end
	end 
	self.scroll_view:setData(server_list_data, click_callback)
end 

function ServerPanel:changeTabBarIndex(item)
	if item == nil or item.data == nil then return end
	if self.select_list_item == item then return end
	if self.select_list_item then
		self.select_list_item:setSelected(false)
		self.select_list_item = nil
	end

	self.select_list_item = item
	if self.select_list_item then
		self.select_list_item:setSelected(true)
	end

	-- 缓存对象池
	if self.server_scroll_view then
		GlobalTimeTicket:getInstance():remove("ServerPanel_selectItemHandler_ticket")
		for i,v in ipairs(self.server_item_list) do
			v:clearLayout()
			table_insert(self.server_poll_list, v)
		end
		self.server_item_list = {}
		self.select_item = nil
	end

	local index = item.data.order
	self.cell_list = {}
	if index == "recommend" then						-- 推荐服务器
		self:createRecommendServer()
	elseif index == "role" then					-- 角色服务器
		self:createRoleServer()
	else									-- 标准服务器
		self:createServerList(self.tab_list[index])
	end
end 

--==============================--
--desc:创建已有角色服务器列表,也只取12个
--time:2017-08-03 10:46:29
--@return 
--==============================--
function ServerPanel:createRoleServer()
	local temp_list = {}
	for i, v in ipairs(self.server_list) do
		if v.role_count > 0 then
			table_insert(temp_list, v)
		end
	end
	
	local role_list = {}
	if temp_list and #temp_list > 0 then
		table_sort(temp_list, function(a, b) return b.role_logintime < a.role_logintime end)
		
		for i = 1, 100 do
			if temp_list[i] ~= nil then
				table_insert(role_list, temp_list[i])
			end
		end
	end
	self:createServerList(role_list, true)
end

--==============================--
--desc:推荐服务器从后面往前选取12个
--time:2017-08-03 10:42:36
--@return 
--==============================--
function ServerPanel:createRecommendServer()
	local recommend_list = {}
	if not self.server_list or next(self.server_list) == nil then return end
	for i=1,2 do
		if self.server_list[i] then
			table_insert(recommend_list, self.server_list[i])
		end
	end
	self:createServerList(recommend_list)
end 

--==============================--
--desc:创建当前服务器列表
--time:2017-08-03 10:43:11
--@data: is_role:标识是否为已有角色
--@return 
--==============================--
function ServerPanel:createServerList(data, is_role)
	doStopAllActions(self.root_wnd)
	self.temp_new_pos = nil
	local tamp = #data
	local total = tamp * self.cell_h + (tamp + 1)
	self.total_h = total
	self.maxH = math.max(total, self.scroll_h)
	self.server_scroll_view:stopAutoScroll()
	self.server_scroll_view:setInnerContainerSize(cc.size(self.scroll_w, self.maxH))

	local _h, vo, _x, _y, cell = 0 
	for i,v in ipairs(data) do
		delayRun(self.root_wnd, i / display.DEFAULT_FPS, function (  )
			vo = {idx=i, v=v}
			_x = (self.scroll_w - self.cell_w) * 0.5
			_y = self.maxH - (i-1)*(self.cell_h)
			if #self.server_poll_list > 0 then
				cell = table_remove(self.server_poll_list, 1)
			else
				cell = ServerCell.new() 
			end

			table_insert(self.server_item_list, cell)
			self.server_scroll_view:addChild(cell)
			cell:setBaseData(vo, is_role)

			local curPos = cell.idx - 1
			if self.temp_new_pos and curPos > self.temp_new_pos then
				local offH = 88
				if self.select_item then
					offH = self.select_item.scroll_h or 88
				end
				_y = _y - offH
			end
			cell:setPosition(_x, _y)

			local function callBack(item)
				if not self.model:isNeedReload(nil, v, sdkOnSwitchAccount) then
					self.model:setCurSrv(v, true)
					self:selectItemHandler(item, false, true)
				end
			end
			cell:addCallBack(callBack)
			self.cell_list[i] = cell
		end)
	end
	
	-- self:selectItemHandler(self.cell_list[1])
end

--==============================--
--desc:点击选择一个服务器之后的具体操作
--time:2017-08-03 10:48:43
--@cell:
--@force:
--@return 
--==============================--
function ServerPanel:selectItemHandler(cell, force, auto_login)
	if cell == nil or cell.data == nil or cell.data.v == nil then return end
	if self.select_item and self.select_item == cell then return end
	if self.select_item ~= nil then
		self.select_item:setSelected(false)
	end

	self.pre_cell = self.select_item
	
	local loginData = deepCopy(self.model:getLoginData())
	local is_connect = GameNet:getInstance():IsServerConnect()
	if self.select_item ~= cell or force or not is_connect then
		loginData.ip = cell.data.v.ip
		loginData.port = cell.data.v.port
		loginData.srv_id = cell.data.v.srv_id
        loginData.host = cell.data.v.host or ""
        loginData.open_time = cell.data.v.open_time or 0
		loginData.rid = 0
		if is_connect and self.ctrl:isReadyEnterGame() == false then
	        GameNet:getInstance():DisconnectByClient(false)
		end
        GlobalTimeTicket:getInstance():remove("LOGIN_REQUEST_tiket")
        self.model:setGatewayCallState(0)
		local function call_back()
			local is_agree = SysEnv:getInstance():getBool(SysEnv.keys.user_proto_agree, false)
		    if checkUserProto and checkUserProto() and not is_agree then
		    	message(TI18N("请勾选同意开始游戏按钮下方的 诗悦游戏用户协议 和 隐私保护指引,即可进入游戏")) 
		        return
		    end

			if NEED_CHECK_CLOSE and (loginData.isClose or GameNet:getInstance():getTime() - loginData.open_time < 0) then
				NoticeController:getInstance():openNoticeView()
				return 
			end
		    GlobalTimeTicket:getInstance():remove("ServerPanel_selectItemHandler_ticket")
            loginData.host = cell.data.v.host or ""
            loginData.open_time = cell.data.v.open_time or 0
			self.ctrl:requestLoginGame(loginData.usrName, cell.data.v.ip, cell.data.v.port, false, auto_login)  
		end
		GlobalTimeTicket:getInstance():add(call_back, 2/display.DEFAULT_FPS, 1, "ServerPanel_selectItemHandler_ticket")
	end

	loginData.srv_id = cell.data.v.srv_id
    loginData.host = cell.data.v.host or ""
    loginData.open_time = cell.data.v.open_time or 0
    loginData.srv_name = cell.data.v.srv_name or ""

    self.select_item = cell
	if self.select_item ~= nil then
		self.select_item:setSelected(true)
	end
end

function ServerPanel:updateCellListPos(  )
	local preCell = self.pre_cell
	local idx = self.select_item.idx
	local oldPos = 0 -- 之前展开时的起始改变位置
	local newPos = 0 -- 要开始改变位置的
	local offH = self.select_item.scroll_h or 88
	local oldOffH = 0
	if  preCell ~= nil and preCell.idx then
		oldPos = preCell.idx - 1
		oldOffH = preCell.scroll_h or 88
	end
	if self.select_item.idx then
		newPos = self.select_item.idx - 1
		self.temp_new_pos = newPos
	end

	local maxH = math.max(self.total_h + offH, self.scroll_h)

	if preCell ~= nil then
		if preCell.isOpenRoles then
			for i, item in ipairs(self.cell_list) do
				_y = maxH - (i-1)*(self.cell_h)
				item:setPositionY(_y)
			end
			preCell:closeRoles()
		end
	end

	for i, item in ipairs(self.cell_list) do
		local curPos = item.idx - 1
		_y = maxH - (i-1)*(self.cell_h)
		if curPos > newPos then
			_y = _y - offH
		end
		item:setPositionY(_y)
	end
	self.select_item:showRoles()

	self.maxH = maxH
	self.server_scroll_view:setInnerContainerSize(cc.size(self.scroll_w,maxH))
	if self.select_item.idx > 8 then
		local percent = (self.select_item.idx)/(#self.cell_list)*100
		self.server_scroll_view:scrollToPercentVertical(percent, 0, true)
	end
end

function ServerPanel:registerEvent()
	if self.btn_close then
	    self.btn_close:addTouchEventListener(function(sender, event_type)
	        if event_type == ccui.TouchEventType.ended then
	        	playCloseSound()
				GameNet:getInstance():DisconnectByClient(false)
	        	self.ctrl:openView(LoginController.type.enter_game)
	        end
	    end)
	end
	if self.role_list_change_event == nil then
    	self.role_list_change_event = GlobalEvent:getInstance():Bind(LoginEvent.SERVER_ROLELIST_CHANGE, function()
			self:updateCell()
    	end)
    end
end

--==============================--
--desc:更新选中服务器列表数据
--time:2018-06-25 06:36:49
--@return 
--==============================--
function ServerPanel:updateCell()
	local roles = self.model:getLoginInfo().roles
	if self.select_item  then
		self.select_item:updateRoleData(roles)
		self:updateCellListPos()
	end
end


function ServerPanel:DeleteMe()
	doStopAllActions(self.root_wnd)
	GlobalTimeTicket:getInstance():remove("ServerPanel_selectItemHandler_ticket")

	if self.scroll_view then
		self.scroll_view:DeleteMe()
		self.scroll_view = nil
	end

	for i,v in ipairs(self.server_item_list) do
		v:DeleteMe()
	end
	self.server_item_list = nil

	for i,v in ipairs(self.server_poll_list) do
		v:DeleteMe()
	end
	self.server_poll_list = nil

	for i=1,self.server_scroll_view:getChildrenCount() do
		local cell = self.server_scroll_view:getChildByTag(i)
		if cell and cell.DeleteMe then
			cell:DeleteMe()
		end
	end

	self:removeAllChildren()
    self:removeFromParent()

    if self.role_list_change_event then
        GlobalEvent:getInstance():UnBind(self.role_list_change_event)
        self.role_list_change_event = nil
    end
end


-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      服务器列表左侧列表
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ServerListItem = class("ServerListItem", function()
	return ccui.Layout:create()
end)

function ServerListItem:ctor()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("login/server_list_item"))
	self.size = self.root_wnd:getContentSize()
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	self:setTouchEnabled(true)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)

	self.normal_bg = self.root_wnd:getChildByName("normal_bg")
	self.select_bg = self.root_wnd:getChildByName("select_bg") 
	self.list_desc = self.root_wnd:getChildByName("list_desc") 			-- 未选中 68452a   选中 d7a98e
	
	self:registerEvent()
end

function ServerListItem:registerEvent()
	self:addTouchEventListener(function(sender, event_type)
	if event_type == ccui.TouchEventType.ended then	
        self.touch_end = sender:getTouchEndPosition()
			local is_click = true
			if self.touch_began ~= nil then
				is_click = math.abs( self.touch_end.x - self.touch_began.x ) <= 20 and math.abs( self.touch_end.y - self.touch_began.y ) <= 20
			end
			if is_click == true then
				if self.call_back and self.data then
					self.call_back(self)
				end			
			end
		elseif event_type == ccui.TouchEventType.began then			
            self.touch_began = sender:getTouchBeganPosition()
		end
	end)
end

function ServerListItem:addCallBack(call_back)
	self.call_back = call_back
end

--==============================--
--desc:设置选中状态
--time:2018-06-25 03:56:17
--@status:
--@return 
--==============================--
function ServerListItem:setSelected(status)
	if status == true then
		self.list_desc:setTextColor(cc.c4b(162,62,1,255))
	else
		self.list_desc:setTextColor(cc.c4b(104,69,42,255))
	end
	self.normal_bg:setVisible(status == false)
	self.select_bg:setVisible(status)
end

function ServerListItem:setData(data)
	if data ~= nil then
		self.data = data
		self.list_desc:setString(data.desc)

		-- 创建之后默认选中第一个
		if data.order == "recommend" then
			self.call_back(self)
		end
	end
end

function ServerListItem:DeleteMe()
	if self.rank_num ~= nil then
		self.rank_num:DeleteMe()
		self.rank_num = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end 