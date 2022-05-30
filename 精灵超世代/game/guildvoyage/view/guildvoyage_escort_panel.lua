-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会远航正在护送界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildVoyageEscortPanel = class("GuildVoyageEscortPanel", function()
	return ccui.Layout:create()
end)

local controller = GuildvoyageController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local game_net = GameNet:getInstance()

function GuildVoyageEscortPanel:ctor()
	self.voyage_line = {}
	self.distance = 28
	self.point_zorder = 4			-- 路线的层级
	self.end_point_zorder = 5		-- 结束点的层级
	self.ship_zorder = 6			-- 船舶的层级
	self.time_zorder = 7			-- 剩余时间的层级

	self:createRootWnd()
end

function GuildVoyageEscortPanel:createRootWnd()
	self.size = cc.size(619,753)
	self:setContentSize(self.size)
	self:setPositionX(4)

	self.resources_load = createResourcesLoad(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_38"), ResourcesType.single, function() 
		self.bg_img = createImage(self, PathTool.getPlistImgForDownLoad("bigbg", "bigbg_38"), 0, 0, cc.p(0, 0), false)
	end)

	-- local notice_label = createLabel(24, 188, nil, 4, 770, TI18N("Vip等级越高，可同时护送上限数越高！"), self, nil, cc.p(0,0.5))

	-- self.order_sum = createLabel(24, 175, nil, 470, 770, TI18N("正在护送:2/6"), self, nil, cc.p(0,0.5))

	-- 地图层
	self.map_container = ccui.Layout:create()
	self.map_container:setContentSize(self.size)
	self.map_container:setPosition(0, 0)
	self:addChild(self.map_container, 2)

	-- 先确定起点的位置
	self.start_pos = cc.p(240, 112)
	self.start_pos_img = createImage(self.map_container, PathTool.getResFrame("guildvoyage","guildvoyage_1011"), self.start_pos.x, self.start_pos.y, cc.p(0.5, 0.5), true)
	self.start_port_label = createLabel(22, 1, 2, self.start_pos.x, self.start_pos.y - 40, TI18N("港口"), self.map_container, nil, cc.p(0.5, 0,5)) 

	self.point = createImage(self.map_container, PathTool.getResFrame("guildvoyage", "guildvoyage_1013"), 0, 0, cc.p(0.5, 0.5), true) 
	self.point:setVisible(false)


	-- 时间计时节点
	local ship_root = createCSBNote(PathTool.getTargetCSB("guildvoyage/guildvoyage_escort_ship"))
	ship_root:setVisible(false)
	self.map_container:addChild(ship_root)
	self.ship = ship_root:getChildByName("container")
end

function GuildVoyageEscortPanel:registerEvent(status)
	if status == true then
		if self.update_voyage_status_event == nil then
			self.update_voyage_status_event = GlobalEvent:getInstance():Bind(GuildvoyageEvent.UpdateGuildvoyageOrderStatus, function(order_id, status)
				self:checkVoyegeStatus(order_id, status)
			end)
		end
		if self.time_ticket == nil then
			self.time_ticket = GlobalTimeTicket:getInstance():add(function() 
				self:escortTimeCount()
			end, 1)
		end
	else
		if self.update_voyage_status_event then
			GlobalEvent:getInstance():UnBind(self.update_voyage_status_event)
			self.update_voyage_status_event = nil
		end
		if self.time_ticket then
			GlobalTimeTicket:getInstance():remove(self.time_ticket)
			self.time_ticket = nil
		end
	end
end 

--==============================--
--desc:时间倒计时
--time:2018-07-05 02:01:13
--@return 
--==============================--
function GuildVoyageEscortPanel:escortTimeCount()
	for k,object in pairs(self.voyage_line) do
		if object.is_pause == false and object.order and object.ship_node then  -- 初始化全部结束之后在做判断
			local end_time = object.order.end_time - game_net:getTime()
			if end_time >= 0 then
				if object.ship_node.time then
					object.ship_node.time:setString(TimeTool.GetTimeFormat(end_time)) 
				end
				if object.ship_node.cost then
					local total_value = model:getFinishCost(end_time)
					if object.ship_node.total_value ~= total_value then
						object.ship_node.total_value = total_value
						object.ship_node.cost:setString(total_value)
					end 
				end
			end
		end
	end
end

--==============================--
--desc:移除一个订单对象
--time:2018-07-05 03:55:18
--@order_object:
--@return 
--==============================--
function GuildVoyageEscortPanel:removeOrder(order_object)
	if order_object == nil then return end
	if order_object.ship_node then
		-- 移除宝箱
		self:handleRewardsBox(false, order_object.ship_node) 

		-- 移除航线的点
		for i, item in ipairs(order_object.pos) do
			if not tolua.isnull(item.point) then
				item.point:removeFromParent()
			end
		end
		-- 移除船只
		if not tolua.isnull(order_object.ship_node.node) then
			order_object.ship_node.node:stopAllActions()
			order_object.ship_node.node:removeFromParent()
		end

		if not tolua.isnull(order_object.ship_node.time_container) then
			order_object.ship_node.time_container:stopAllActions()
			order_object.ship_node.time_container:removeFromParent()
		end

		-- 移除终点和名字
		if not tolua.isnull(order_object.end_point_icon) then
			order_object.end_point_icon:removeFromParent()
		end
		if not tolua.isnull(order_object.name) then
			order_object.name:removeFromParent()
		end
	end
end

--==============================--
--desc:判断状态的
--time:2018-07-05 02:02:05
--@order_id:
--@status:
--@return 
--==============================--
function GuildVoyageEscortPanel:checkVoyegeStatus(order_id, status)
	if order_id == nil then return end
	local object = self.voyage_line[order_id] 
	if object == nil then return end
	if status == GuildvoyageConst.status.over then					-- 这个移除该订单
		self:removeOrder(object)
		self.voyage_line[order_id] = nil
		local escort_list = model:escortList() 
		if escort_list then
			local num = #escort_list
			-- self.order_sum:setString(string.format(TI18N("正在护送:%s/%s"), num, model:getMaxSubTimes()))
			self:showStartEffect(num==0)
		end
	elseif status == GuildvoyageConst.status.submit then			-- 这个标识达到终点
		if object.ship_node and not tolua.isnull(object.ship_node.node) then
			object.ship_node.node:stopAllActions()
			object.ship_node.node:setPosition(object.end_point.x, object.end_point.y - 14)
			object.ship_node.bubble:setContentSize(cc.size(86, 44))
			object.ship_node.ship:setVisible(false)
			object.ship_node.icon:setVisible(false)
			object.ship_node.cost:setVisible(false)
			object.ship_node.time:setString(TI18N("可提交"))
			self:handleRewardsBox(true, object.ship_node)
		end
	elseif status == GuildvoyageConst.status.doing then				-- 这个只是endtime时间变化,
		if object.ship_node and not tolua.isnull(object.ship_node.node) then
			object.ship_node.node:stopAllActions()
		end
	end
end

function GuildVoyageEscortPanel:addToParent(status)
	if status == true then
		local escort_list = model:escortList()
		if #escort_list == 0 then
			self:showStartEffect(true)
		else
			self:showStartEffect(false)
			for i,order in ipairs(escort_list) do
				delayRun(self.map_container, i*2/display.DEFAULT_FPS, function()
					self:createVoyageLine(order)
				end)
			end
		end
		-- self.order_sum:setString(string.format(TI18N("正在护送:%s/%s"), #escort_list, model:getMaxSubTimes()))
		self:createSceneEffect()
	else
		-- 给个标识,所有的状态处于暂停
		self.map_container:stopAllActions()
		for k, object in pairs(self.voyage_line) do
			if object.ship_node and not tolua.isnull(object.ship_node.node) then
				object.ship_node.node:stopAllActions()
			end
			object.is_pause = true
		end
	end
	self:setVisible(status)
	self:registerEvent(status)
end

--==============================--
--desc:创建订单
--time:2018-07-04 04:52:58
--@order:
--@return 
--==============================--
function GuildVoyageEscortPanel:createVoyageLine(order)
	if order == nil then return end
	if self.voyage_line[order.order_id] == nil then
		self.voyage_line[order.order_id] = {}
	end
	local line_object = self.voyage_line[order.order_id] 
	if line_object == nil then return end
	line_object.order = order

	-- 创建线路和重点
	if line_object.pos == nil then
		self:createVoyageLinePoint(line_object)
	end
	
	-- 创建船只
	if line_object.ship_node == nil then
		self:createVoyageShip(line_object)
	end

	-- 重点地方创建相关信息
	local ship_node = line_object.ship_node 
	if ship_node and line_object.end_point then
		if ship_node.bubble == nil then
			if not tolua.isnull(self.ship) then
				local container = self.ship:clone()
				container:setVisible(true)
				container:setAnchorPoint(cc.p(0.5, 1))
				container:setPosition(line_object.end_point.x, line_object.end_point.y - 15)
				self.map_container:addChild(container, self.time_zorder)
				ship_node.time_container = container
				ship_node.bubble = container:getChildByName("bubble")
				ship_node.time = container:getChildByName("time")
				ship_node.icon = container:getChildByName("icon")
				ship_node.cost = container:getChildByName("cost") 
				container:addTouchEventListener(function(sender, event_type)
					if event_type == ccui.TouchEventType.ended then
						self:clickOrderEvent(line_object)
					end
				end) 
			end
		end
	end

	-- 显示对象创建完成之后,设置相关数据
	self:setOrderStatus(line_object)
end

--==============================--
--desc:创建航海路线的点
--time:2018-07-04 04:56:34
--@return 
--==============================--
function GuildVoyageEscortPanel:createVoyageLinePoint(line_object)
	if line_object == nil or line_object.order == nil then return end
	local order = line_object.order
	if order.line_id == nil or order.config == nil then return end
	local line_config = Config.GuildShippingData.data_pos[order.line_id]
	if line_config == nil or line_config.pos == nil or line_config.pos[1] == nil or line_config.pos[2] == nil then return end
	
	line_object.pos = {}  -- point, pos
	local posData = {}
	table_insert(posData, self.start_pos)		-- 起点
	for i, v in ipairs(line_config.t_pos) do
		if v[1] and v[2] then
			table_insert(posData, cc.p(v[1], v[2]))
		end
	end
	local _x = line_config.pos[1]
	local _y = line_config.pos[2]
	table_insert(posData, cc.p(_x, _y))		-- 终点
	
	-- 创建目标点
	line_object.end_point_icon = createImage(self.map_container, PathTool.getResFrame("guildvoyage", "guildvoyage_1012"), _x, _y, cc.p(0.5, 0.5), true, self.end_point_zorder)
	line_object.end_point = cc.p(_x, _y)
	line_object.end_point_icon:setTouchEnabled(true)
	line_object.end_point_icon:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			self:clickOrderEvent(line_object)
		end
	end) 
	
	-- 这里创建目标订单的名字
	line_object.name = createLabel(22, 1, self:getOutlineByQuality(order.config.quality), _x, _y + 22, order.config.name, self.map_container, nil, cc.p(0.5, 0))
	
	-- 创建目标点
	local startPos = posData[1]       --起始点位置
	local time = 0
	while time < 1 do
		local pos = self:getBezierPos(posData, time)
		local d = cc.pGetDistance(pos, startPos)
		if d >= self.distance then
			local object = {}
			local point = self.point:clone()
			point:setVisible(true)
			point:setPosition(pos.x, pos.y)
			self.map_container:addChild(point, self.point_zorder)
			object.point = point
			object.pos = pos
			table_insert(line_object.pos, object)
			startPos = pos
		end
		time = time + 0.001
	end
end 

--==============================--
--desc:创建船只
--time:2018-07-13 05:42:01
--@line_object:
--@return 
--==============================--
function GuildVoyageEscortPanel:createVoyageShip(line_object)
	if line_object == nil then return end
	line_object.ship_node = {}
	line_object.ship_node.node = ccui.Layout:create()
	line_object.ship_node.node:setTouchEnabled(true)
	line_object.ship_node.node:setContentSize(cc.size(80, 80))
	line_object.ship_node.node:setAnchorPoint(cc.p(0.5, 0))
	self.map_container:addChild(line_object.ship_node.node, self.ship_zorder)

	if line_object.ship_node.ship == nil then
		line_object.ship_node.ship = createEffectSpine(PathTool.getEffectRes(301), cc.p(40, 15), cc.p(0.5, 0.5), true, PlayerAction.action)
		line_object.ship_node.node:addChild(line_object.ship_node.ship)
	end
	line_object.ship_node.node:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			self:clickOrderEvent(line_object)
		end
	end) 
end

--==============================--
--desc:点击订单
--time:2018-07-13 05:34:29
--@return 
--==============================--
function GuildVoyageEscortPanel:clickOrderEvent(line_object)
	if line_object.order then
		if line_object.order.status == GuildvoyageConst.status.submit then
			controller:openGuildvoyageChooseConfirmWindow(true, line_object.order)
		elseif line_object.order.status == GuildvoyageConst.status.doing then
			controller:openGuildvoyageOrderEscortWindow(true, GuildvoyageConst.escort_type.escort, line_object.order.order_id)
		end
	end 
end

--==============================--
--desc:设置订单状态
--time:2018-07-05 09:16:22
--@order:
--@return 
--==============================--
function GuildVoyageEscortPanel:setOrderStatus(line_object)
	if line_object == nil or line_object.order == nil or line_object.order.config == nil then return end
	local order = line_object.order
	if order.status == GuildvoyageConst.status.submit then
		line_object.ship_node.node:setPosition(line_object.end_point.x, line_object.end_point.y - 14)
		line_object.ship_node.ship:setVisible(false)
		self:handleRewardsBox(true, line_object.ship_node)

		line_object.ship_node.bubble:setContentSize(cc.size(86, 44))
		line_object.ship_node.icon:setVisible(false)
		line_object.ship_node.cost:setVisible(false)
		line_object.ship_node.time:setString(TI18N("可提交"))
		-- 创建宝箱特效
	else
		line_object.ship_node.ship:setVisible(true)
		self:handleRewardsBox(false, line_object.ship_node)

		line_object.ship_node.bubble:setContentSize(cc.size(86, 60))
		line_object.ship_node.icon:setVisible(true)
		line_object.ship_node.cost:setVisible(true) 

		local end_time = order.end_time - GameNet.getInstance():getTime()
		if end_time <= 0 then
			end_time = 0
		end
		-- 设置时间
		line_object.ship_node.time:setString(TimeTool.GetTimeFormat(end_time))
		local total_value = model:getFinishCost(end_time)
        line_object.ship_node.total_value = total_value
		line_object.ship_node.cost:setString(total_value)

		-- 这里是设置位置的
		local line_pos_list = line_object.pos 
		if end_time > 0 and line_pos_list and #line_pos_list > 0 then
			local pos_sum = #line_pos_list
			
			local total_time = order.config.time
			local percent = (total_time - end_time) / total_time
			if percent <= 0 then percent = 0 end
			local pos_index = math.floor( pos_sum * percent + 0.5 )
			if pos_index == 0 then pos_index = 1 end
			local cur_target = line_pos_list[pos_index]
			line_object.ship_node.speed = order.config.time / pos_sum
			if cur_target then
				line_object.ship_node.node:setPosition(cur_target.pos.x, cur_target.pos.y - 14)
				line_object.ship_node.cur_pos_index = pos_index
			end
			-- 开始移动
			self:doNextAction(line_object)
		end
	end
	line_object.is_pause = false
end

--==============================--
--desc:重复移动
--time:2018-07-05 03:20:11
--@line_object:
--@return 
--==============================--
function GuildVoyageEscortPanel:doNextAction(line_object)
	if line_object == nil or line_object.ship_node == nil or tolua.isnull(line_object.ship_node.node) then return end
	local cur_pos_index = line_object.ship_node.cur_pos_index
	local cur_pos_x, _y = line_object.ship_node.node:getPosition()
	local line_pos_list = line_object.pos 
	local pos_sum = #line_pos_list
	if cur_pos_index < pos_sum then
		local next_target = line_pos_list[cur_pos_index+1]
		if next_target and next_target.pos then
			-- 船头方向反转
			if not tolua.isnull(line_object.ship_node.ship) then
				local dir = 1
				if cur_pos_x < next_target.pos.x then
					dir = -1
				end
				if line_object.ship_node.dir ~= dir then
					line_object.ship_node.dir = dir
					line_object.ship_node.ship:setScaleX(dir) 
				end
			end
			local move_action = cc.MoveTo:create(line_object.ship_node.speed, next_target.pos) 
			line_object.ship_node.node:runAction(cc.Sequence:create(move_action, cc.CallFunc:create(function()
				line_object.ship_node.cur_pos_index = line_object.ship_node.cur_pos_index + 1
				self:doNextAction(line_object)
			end))) 
		end
	end
end

--==============================--
--desc:处理宝箱状态
--time:2018-07-05 08:57:06
--@status:
--@node:
--@return 
--==============================--
function GuildVoyageEscortPanel:handleRewardsBox(status, ship_node)
	if ship_node == nil or tolua.isnull(ship_node.node) then return end
	if status == true then
		if ship_node.box == nil then
			ship_node.box = createEffectSpine(PathTool.getEffectRes(110), cc.p(47, 5), cc.p(0.5, 0), true, PlayerAction.action_2) 
			ship_node.node:addChild(ship_node.box)
		end
		ship_node.box:clearTracks()
		ship_node.box:setToSetupPose()
		ship_node.box:setAnimation(0, PlayerAction.action_2, true)
	else
		if not tolua.isnull(ship_node.box) then
			ship_node.box:clearTracks()
			ship_node.box:removeFromParent()
			ship_node.box = nil
		end
	end
end

function GuildVoyageEscortPanel:DeleteMe()
	self.map_container:stopAllActions()
	self:registerEvent(false)

	for k, line_object in pairs(self.voyage_line) do
		if line_object.ship_node then
			-- 移除宝箱
			self:handleRewardsBox(false, line_object.ship_node) 

			-- 移除航线的点
			for i, item in ipairs(line_object.pos) do
				if not tolua.isnull(item.point) then
					item.point:removeFromParent()
				end
			end
			-- 移除船只
			if not tolua.isnull(line_object.ship_node.node) then
				line_object.ship_node.node:stopAllActions()
				line_object.ship_node.node:removeFromParent()
			end
		end
	end
	self.voyage_line = nil
	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end
end 

function GuildVoyageEscortPanel:factorial(n)
	if n == 0 then
		return 1
	else
		return n * self:factorial(n - 1)
	end
end 

function GuildVoyageEscortPanel:getBezierPos(posData,t)
    local data = DeepCopy(posData)
    local n = #data -1
    local x = 0
    local y = 0
    for idx,pos in pairs(data) do 
        x = x + pos.x *(self:factorial(n)/(self:factorial(n-idx+1)*self:factorial(idx-1))) * math.pow(1-t,n-idx+1) * math.pow(t,idx-1)
        y = y + pos.y *(self:factorial(n)/(self:factorial(n-idx+1)*self:factorial(idx-1))) * math.pow(1-t,n-idx+1) * math.pow(t,idx-1)
    end
    return cc.p(x,y)
end

--==============================--
--desc:根据品质获得描边色
--time:2018-07-04 07:03:32
--@quality:
--@return 
--==============================--
function GuildVoyageEscortPanel:getOutlineByQuality(quality)
	if quality == BackPackConst.quality.green then
		return cc.c4b(0x0b,0x4d,0x9d,0xff)
	elseif quality == BackPackConst.quality.blue then
		return cc.c4b(0x0f,0x63,0x00,0xff)
	elseif quality == BackPackConst.quality.purple then
		return cc.c4b(0x88,0x00,0xaa,0xff)
	elseif quality == BackPackConst.quality.orange then
		return cc.c4b(0xd6,0x54,0x00,0xff)
	elseif quality == BackPackConst.quality.red then
		return cc.c4b(0xc8,0x14,0x14,0xff)
	end
end

--==============================--
--desc:创建场景动效
--time:2018-07-13 04:43:44
--@status:
--@return 
--==============================--
function GuildVoyageEscortPanel:createSceneEffect(status)
	if status == false then

	else
		if self.scene_effect == nil then
			self.scene_effect = createEffectSpine(PathTool.getEffectRes(300), cc.p(self.size.width*0.5,self.size.height*0.5), cc.p(0.5, 0.5), true, PlayerAction.action)
			self:addChild(self.scene_effect, 1)
		end
	end
end

--==============================--
--desc:起点ZZZZ特效
--time:2018-07-13 05:49:40
--@status:
--@return 
--==============================--
function GuildVoyageEscortPanel:showStartEffect(status)
	if status == false then
		if self.start_effect ~= nil then
			self.start_effect:setVisible(false)
		end
	else
		if self.start_effect == nil then
			self.start_effect = createEffectSpine(PathTool.getEffectRes(302), cc.p(self.start_pos.x,self.start_pos.y), cc.p(0.5, 0.5), true, PlayerAction.action)
			self:addChild(self.start_effect, 3)
		end
		self.start_effect:setVisible(true)
	end
end