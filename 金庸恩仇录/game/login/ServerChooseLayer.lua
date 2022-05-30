local ServerChooseLayer = class("ServerChooseLayer", function ()
	return require("utility.ShadeLayer").new()
end)

local ServerNameItem = class("ServerNameItem", function (param)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node
	if param.type then
		if param.type == 1 then
			node = CCBuilderReaderLoad("login/last_server_name.ccbi", proxy, rootnode)
		elseif param.type == 2 then
			node = CCBuilderReaderLoad("login/login_server_name.ccbi", proxy, rootnode)
		end
	else
		node = CCBuilderReaderLoad("login/login_server_name.ccbi", proxy, rootnode)
	end
	node._rootnode = rootnode
	return node
end)

function ServerNameItem:ctor(param)
	local _info = param.info
	if _info then
		for k, v in ipairs(_info) do
			self._rootnode["nameNode_" .. tostring(k)]:setVisible(true)
			self._rootnode["serverStat_" .. tostring(k)]:setDisplayFrame(display.newSpriteFrame(string.format("login_state_%d.png", v.status)))
			self._rootnode["serverNameLabel_" .. tostring(k)]:setString(v.name)
			if param.type then
				if param.type == 1 and v.roleName then
					self._rootnode["roleNameLabel_" .. tostring(k)]:setVisible(true)
					self._rootnode["roleNameLabel_" .. tostring(k)]:setString(v.roleName)
				else
					self._rootnode["roleNameLabel_" .. tostring(k)]:setVisible(false)
				end
			end
		end
	end
end


function ServerChooseLayer:ctor(lastServerList, serverList, callback)
	dump(serverList)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local contentNode = CCBuilderReaderLoad("login/login_server_choose.ccbi", proxy, self._rootnode)
	contentNode:setPosition(display.cx, display.cy + 30)
	self:addChild(contentNode, 1)
	local last_height = self._rootnode.listLastLayer:getContentSize().height
	local last_width = self._rootnode.listLastLayer:getContentSize().width
	local last_itemNum = math.ceil(#lastServerList / 2)
	if last_height < last_itemNum * 100 then
		self._rootnode.listLastLayer:setContentSize(CCSizeMake(last_width, last_itemNum * 100))
		self._rootnode.lastLoginScrollView:updateInset()
		self._rootnode.lastLoginScrollView:setContentOffset(CCPointMake(0, last_height - last_itemNum * 100), false)
		last_height = last_itemNum * 100
	end
	local last_nodes = {}
	local last_node
	for i = 1, #lastServerList, 2 do
		local t = {}
		if lastServerList[i] then
			local serverInfo = common:getServerInfoByIdx(serverList, lastServerList[i].idx)
			serverInfo.roleName = lastServerList[i].roleName
			table.insert(t, serverInfo)
		end
		if lastServerList[i + 1] then
			local serverInfo = common:getServerInfoByIdx(serverList, lastServerList[i + 1].idx)
			serverInfo.roleName = lastServerList[i + 1].roleName
			table.insert(t, serverInfo)
		end
		last_node = ServerNameItem.new({info = t, type = 1})
		self._rootnode.listLastLayer:addChild(last_node)
		last_node:setPosition(last_width / 2, last_height)
		last_height = last_height - last_node:getContentSize().height
		table.insert(last_nodes, last_node)
	end
	
	local height = self._rootnode.listLayer:getContentSize().height
	local width = self._rootnode.listLayer:getContentSize().width
	local itemNum = math.ceil(#serverList / 2)
	if height < itemNum * 70 then
		self._rootnode.listLayer:setContentSize(CCSizeMake(width, itemNum * 70))
		self._rootnode.scrollView:updateInset()
		self._rootnode.scrollView:setContentOffset(CCPointMake(0, height - itemNum * 70), false)
		height = itemNum * 70
	end
	
	local nodes = {}
	local node
	for i = 1, #serverList, 2 do
		local t = {}
		if serverList[i] then
			table.insert(t, serverList[i])
		end
		if serverList[i + 1] then
			table.insert(t, serverList[i + 1])
		end
		node = ServerNameItem.new({info = t})
		self._rootnode.listLayer:addChild(node)
		node:setPosition(width / 2, height)
		height = height - node:getContentSize().height
		table.insert(nodes, node)
	end
	
	local bTouch
	local function onTouchMove(event)
		if math.abs(event.y - event.prevY) > 5 then
			bTouch = false
		end
	end
	
	local function onSelectedServer(type, index)
		if type == 1 and index > #lastServerList or type == 2 and index > #serverList then
			return
		end
		if callback then
			callback(type, index)
		end
		self:removeSelf()
	end
	
	--¹Ø±Õ°´Å¥
	self._rootnode["closeBtn"]:addHandleOfControlEvent(function ()
		if callback then
			callback()
		end
		self:removeSelf()
	end,
	cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
	
	
	local function onTouchEnded(event)
		if bTouch then
			if self.touchNode == 1 then
				dump(nodes)
				for k, v in ipairs(nodes) do
					local pos = v:convertToNodeSpace(cc.p(event.x, event.y))
					dump(pos)
					if self.touchNode == 1 and cc.rectContainsPoint(cc.rect(0, 0, v:getContentSize().width, v:getContentSize().height), pos) then
						local i
						if pos.x > v:getContentSize().width / 2 then
							i = 2
						else
							i = 1
						end
						local index = (k - 1) * 2 + i
						onSelectedServer(2, index)
						return
					end
				end
			elseif self.touchNode == 2 then
				for k, v in ipairs(last_nodes) do
					local pos = v:convertToNodeSpace(cc.p(event.x, event.y))
					if self.touchNode == 2 and cc.rectContainsPoint(cc.rect(0, 0, v:getContentSize().width, v:getContentSize().height), pos) then
						local i
						if pos.x > v:getContentSize().width / 2 then
							i = 2
						else
							i = 1
						end
						local index = (k - 1) * 2 + i
						onSelectedServer(1, index)
						return
					end
				end
			end
		end
	end
	
	local node = {self._rootnode["serverNameNode"], self._rootnode["lastLoginServerNode"]}
	for i = 1, #node do
		local layer = require("utility.MyLayer").new({
		name = "serverNode" ..i,
		size = node[i]:getContentSize(),
		swallow = false,
		touchHandler = function (event)
			--dump(event)
			if event.name == "began" then
				bTouch = true
				return true
			elseif event.name == "moved" then
				onTouchMove(event)
			elseif event.name == "ended" then
				self.touchNode = i
				dump(i)
				onTouchEnded(event)
			end
		end
		})
		node[i]:addChild(layer, 10)
	end
	
end

return ServerChooseLayer
