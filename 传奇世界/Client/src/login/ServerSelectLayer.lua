local ServerSelectLayer = class("ServerSelectLayer", function() return cc.Layer:create() end)
local serverListView = class("serverListView",require ("src/TabViewLayer"))
local path = "res/serverlist/"
local color =  MColor.brown-- cc.c3b(30, 30, 30)

local LoginScene = require("src/login/LoginScene")

function ServerSelectLayer:ctor(parent)
	self:addChild(cc.LayerColor:create(cc.c4b(10,10,10,210)))
	local bg = LoginUtils.createBgSprite(self, "选择服务器")
	self.bg = bg
	local bg_size = self.bg:getContentSize()	
	
	-- local bg1 = LoginUtils.createScale9Sprite(bg,"res/common/scalable/panel_inside_scale9.png",cc.p(120 - 88, 640 - 101),cc.size(180, 501),cc.p(0, 1))    
	-- local bg2 = LoginUtils.createScale9Sprite(bg,"res/common/scalable/panel_inside_scale9.png",cc.p(306 - 88, 640 - 101),cc.size(710, 370),cc.p(0, 1))    
	-- local bg3 = LoginUtils.createScale9Sprite(bg,"res/common/scalable/panel_inside_scale9.png",cc.p(306 - 88, 640 - 510),cc.size(710, 92),cc.p(0, 1))

	local bg1 = LoginUtils.createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(120 - 88, 640 - 101),
        cc.size(180, 501),
        5,
        cc.p(0, 1)
    )
	local bg2 = LoginUtils.createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(306 - 88, 640 - 101),
        cc.size(710, 370),
        5,
        cc.p(0, 1)
    )
	local bg3 = LoginUtils.createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(306 - 88, 640 - 510),
        cc.size(710, 92),
        5,
        cc.p(0, 1)
    )

	self.parent = parent
	self.perGroupNum = 30
	self.isFirst = true
	self.serversGroup = {}
	self.tableinfo = {}
	local temp = {}
	--组装服务器列表数据

	if parent.serverInfo.servers then
		for i,v in ipairs(parent.serverInfo.servers) do
			if not v.hide then
				local groupid = math.floor((tonumber(v.id)-1)/self.perGroupNum)
				temp[groupid] = temp[groupid] or {}
				v.groupid = groupid
				v.logicId = v.id
				table.insert(temp[groupid],v)
			end
		end
	end
	
	for k,v in pairs(temp) do
		table.sort(v,function(a,b) return tonumber(a.logicId) < tonumber(b.logicId) end)
		table.insert(self.serversGroup,v)
	end
	
	table.sort(self.serversGroup, function(a,b) return tonumber(a[1].groupid) < tonumber(b[1].groupid) end )
	--左边按钮
	local str = ""
	if LoginUtils.isQQLogin() then
		str = "QQ"
	elseif LoginUtils.isGuestLogin() then
		str = "游客"
	elseif LoginUtils.isWXLogin() then
		str = "微信"
	end

	local leftBtns = {}
	for k,v in pairs(self.serversGroup)do
		local groupid = v[1].groupid
		local begainStr = string.format("%03d", groupid * self.perGroupNum + 1)
		local endStr = string.format("%03d",   (groupid + 1) * self.perGroupNum) --groupid * self.perGroupNum + 1 + tablenums())
		leftBtns[k] = str .. " " .. begainStr .. "-" ..endStr .."服"
	end
    
    self:addTwoServerGroup(leftBtns, parent.serverInfo.default)
	self.select_server_group = 1
	local callback = function(idx)
		if self.select_server_group ~= idx then
			self.select_server_group = idx
			self:reloadData(idx)
		end
	end

	self.left_tab = require("src/LeftSelectNode").new(self.bg, leftBtns, cc.size(180, 497), cc.p(120 - 88 + 3, 40), callback, {def = "res/component/button/40.png", sel = "res/component/button/40_sel.png"}, true, nil, nil, 20)

	--上次登录
	local lastServerID = LoginUtils.getLocalRecordByKey(1, "serverListLastLogin" .. sdkGetOpenId(), -1)
	if lastServerID ~= -1 and self.parent:getServerById(lastServerID) then
		local str = LoginUtils.getStrByKey("login_lastlogin")
		LoginUtils.createLabel(self.bg, str, cc.p(228, 150), cc.p(0, 0.5), 20, true)

		local lastLoginSpr = LoginUtils.createScale9Sprite(self.bg, "res/common/scalable/15.png", cc.p(573, 85), cc.size(348, 78), cc.p(0.5, 0.5))
		--LoginUtils.createTouchItem(self.bg, path .. "table.png", cc.p(560, 153),function() self:touchLastServerBtn(lastServerID) end ,nil,nil,true)
		local size = lastLoginSpr:getContentSize()
		local itemData = self.parent:getServerById(lastServerID)
		local server_lab = LoginUtils.createLabel(lastLoginSpr, itemData.name, cc.p(46, size.height/2), cc.p(0, 0.5), 20, true)
		LoginUtils.createSprite(lastLoginSpr, "res/login/status" .. itemData.status .. ".png", cc.p(25, 39 - 3))
		local tempRoleTab = LoginUtils.getRoleInfo(1, nil, nil, nil, nil, itemData.logicId)
		for i = 1, #tempRoleTab do
			local roleData = tempRoleTab[i]
			local lv, school = 0,0
			if roleData then
				lv = roleData.lv
				school = roleData.school
			end
			local spr = LoginUtils.createSprite(lastLoginSpr, "res/serverlist/role_" .. school .. ".png", cc.p(230 + ( i - 1) * 45, 48))
			LoginUtils.createLabel(lastLoginSpr, "" .. lv .. LoginUtils.getStrByKey("faction_player_level"), cc.p(spr:getPositionX(), 20), cc.p(0.5, 0.5), 16):setColor(MColor.white)
		end		
		local  listenner = cc.EventListenerTouchOneByOne:create()
	    listenner:setSwallowTouches(false)
	    listenner:registerScriptHandler(function(touch, event)
				local pt = self.bg:convertTouchToNodeSpace(touch)
				if cc.rectContainsPoint(lastLoginSpr:getBoundingBox(),pt) then
					return true
				end	    	
				return false
			end,cc.Handler.EVENT_TOUCH_BEGAN)
	    listenner:registerScriptHandler(function(touch, event)
				local pt = self.bg:convertTouchToNodeSpace(touch)
				if cc.rectContainsPoint(lastLoginSpr:getBoundingBox(),pt) then
					self:touchLastServerBtn(lastServerID)
				end
			end,cc.Handler.EVENT_TOUCH_ENDED)
	    local eventDispatcher = lastLoginSpr:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, lastLoginSpr)

	end

	--服务器列表
	self.tablepos = cc.p(306 - 88, 172)
	local listView = serverListView.new(self)
	self.bg:addChild(listView)
	listView:setPosition(self.tablepos)
	self.listView = listView

	--状态机表示

	local stateCfg = {3,2,1,4}
	for k,v in pairs(stateCfg) do
		local i = v
		local spr = LoginUtils.createSprite(self.bg, "res/login/status" .. i .. ".png",cc.p(585 + (k -1) * 80, 150 - 3), cc.p(0, 0.5))
		LoginUtils.createLabel(self.bg, LoginUtils.getStrByKey("server_status" .. i), cc.p(spr:getPositionX() + 28, 150), cc.p(0, 0.5), 20, true)
	end

	local gotoLastServer = function() 
		local left_key = nil
		local right_sub_key = nil
		for k,v in pairs(self.serversGroup)do
			for key ,value in pairs(v)do
				if tonumber(value.logicId) == tonumber(self.parent.serverId) then
					left_key = k
					right_sub_key = key
					break
				end
			end
			if left_key then
				break
			end
		end
	 	if left_key then
	 		self.left_tab:tableCellTouched(self.left_tab:getTableView(), self.left_tab:getTableView():cellAtIndex(left_key-1))
		end
	end
	
    gotoLastServer()
end

function ServerSelectLayer:touchLastServerBtn(serverId)
	AudioEnginer.playEffect("sounds/uiMusic/ui_click2.mp3", false)
    if serverId then
		local item = self.parent:getServerById(serverId)	
		if item then
			local id = tonumber(item.logicId)
			LoginScene.serverId = id
		 	self.parent:addSuggestedServer()
			self:removeFromParent()
		end
	end
end

function ServerSelectLayer:selectFunc(index)
	if index then
		local item = self.serversGroup[self.select_server_group][index]	
		if item then
			local id = tonumber(item.logicId)
            self:touchLastServerBtn(id)
		end
	end
end

function ServerSelectLayer:addTwoServerGroup(btns, defaultList)
	--推荐服务器
	table.insert(btns, 1, "推荐区服")
	table.insert(self.serversGroup, 1, {})

	if type(defaultList) == "table" and #defaultList > 0 then
		--如果推荐服务器是列表
		for i,v in ipairs(defaultList) do
			local server = self.parent:getServerById(v)
			if server then
				server.logicId = v
				table.insert(self.serversGroup[1], server)
			end
		end
	else
		--如果没有推荐服务器.就拿最新的5个服务器
		local temp = {}
		for i,v in ipairs(self.parent.serverInfo.servers) do
			temp[i] = v
			temp[i].logicId = v.id
		end
		table.sort(temp, function (a, b) return tonumber(a.logicId) > tonumber(b.logicId) end)

		local i = 1
		for k,v in pairs(temp) do
			if i < 6 then
				table.insert(self.serversGroup[1], v)
			else
				break
			end
			i = i + 1
		end
	end

	table.sort(self.serversGroup[1], function(a,b) return tonumber(a.logicId) < tonumber(b.logicId) end)

	--登录过的服务器
	local serStr = LoginUtils.getLocalRecordByKey(2, "loginHistory" .. sdkGetOpenId(), "")
	local ret = require("json").decode(serStr)
    if ret and #ret > 0 then
		local temp = {}
		for i,v in ipairs(ret) do
			local server = self.parent:getServerById(v)
			if server then
				server.logicId = server.id
				table.insert(temp, 1, server)
			end
		end
		if #temp > 0 then
			table.insert(btns, 2, LoginUtils.getStrByKey("server_haveLogin"))
			table.insert(self.serversGroup, 2, {})
			self.serversGroup[2] = temp
		end
    end
end

function ServerSelectLayer:reloadData(idx)
	if not self.isFirst then
		self.listView:removeFromParent()
		local listView = serverListView.new(self)
		self.bg:addChild(listView)
		listView:setPosition(self.tablepos)
		self.listView = listView	
	else
		self.isFirst = false
	end
	self.listView:reloadData()
end

----------------------------------------------------------------
function serverListView:ctor(parent)
	self.parent = parent
	self.serversGroup = self.parent.serversGroup
	self.select_server_group = self.parent.select_server_group
	self:createTableView(self, cc.size(710, 365), cc.p(0, 0), true, true)
end

function serverListView:cellSizeForTable(table,idx)
	return 82, 710
end

function serverListView:numberOfCellsInTableView(table)
	if self.select_server_group == 2 then
		return math.ceil((#self.serversGroup[self.select_server_group])/2)
	else
		return math.ceil((#self.serversGroup[self.select_server_group])/3)
	end
end

function serverListView:reloadData()
	self.select_sever_idx = nil
	self.select_server_group = self.parent.select_server_group
	self:getTableView():reloadData()
end

function serverListView:tableCellAtIndex(table,idx)
	local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end
   	
	local touchInfo = function(bg,num)
		local listenner = cc.EventListenerTouchOneByOne:create()
		local flag = false
	    listenner:registerScriptHandler(function(touch, event) 
									    	local pt = cell:convertTouchToNodeSpace(touch)
									    	bg.pt = cell:getParent():convertTouchToNodeSpace(touch)
											if cc.rectContainsPoint(bg:getBoundingBox(), pt) then
													flag = true
											end
	    									return true 
	    								end, cc.Handler.EVENT_TOUCH_BEGAN)	    
	    listenner:registerScriptHandler(function(touch, event)
    		local start_pos = touch:getStartLocation()
    		local now_pos = touch:getLocation()
    		local nowPt = cell:getParent():convertTouchToNodeSpace(touch)
			local span_pos = cc.p(now_pos.x-start_pos.x,now_pos.y-start_pos.y)
			local span_pos2 = cc.p(nowPt.x - bg.pt.x, nowPt.y - bg.pt.y)	
    		if  math.abs(span_pos.x) < 30 and math.abs(span_pos.y) < 30 and 
				math.abs(span_pos2.x) < 30 and math.abs(span_pos2.y) < 30 then
				local pt = cell:convertTouchToNodeSpace(touch)
				if flag and cc.rectContainsPoint(bg:getBoundingBox(), pt) then
					performWithDelay(cell, function() self.parent:selectFunc(num) end, 0.0)
				end
			end
		end, cc.Handler.EVENT_TOUCH_ENDED)
	    local eventDispatcher = bg:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, bg)			
	end

   	if self.select_server_group ~= 2 then
    	local itemData = {}
		itemData[1] = self.serversGroup[self.select_server_group][idx*3+1]
		itemData[2] = self.serversGroup[self.select_server_group][idx*3+2]
		itemData[3] = self.serversGroup[self.select_server_group][idx*3+3]
		for k,v in pairs(itemData) do
			local bg = LoginUtils.createScale9Sprite(cell, "res/common/scalable/15.png", cc.p(4 + (k -1) * 235, 1), cc.size(232, 78), cc.p(0, 0))
			LoginUtils.createSprite(bg, "res/login/status" .. itemData[k].status .. ".png", cc.p(25, 39 -3))
			LoginUtils.createLabel(bg, "" ..itemData[k].logicId .. itemData[k].name,cc.p(116, 39), cc.p(0.5,0.5), 20, true)
			
			touchInfo(bg, idx*3+k)
		end
	else
		local itemData = {}
		itemData[1] = self.serversGroup[self.select_server_group][idx*2+1]
		itemData[2] = self.serversGroup[self.select_server_group][idx*2+2]
		for k,v in pairs(itemData) do
			local bg = LoginUtils.createScale9Sprite(cell, "res/common/scalable/15.png", cc.p(4 + (k -1) * 352, 1), cc.size(348, 78), cc.p(0, 0))
			LoginUtils.createSprite(bg, "res/login/status" .. itemData[k].status .. ".png", cc.p(25, 39- 3))
			LoginUtils.createLabel(bg, "" .. itemData[k].name,cc.p(46, 39), cc.p(0,0.5), 20, true)
			
			touchInfo(bg, idx*2+k)

			local tempRoleTab = LoginUtils.getRoleInfo(1, nil, nil, nil, nil, itemData[k].logicId)
			for i = 1, #tempRoleTab do
				local roleData = tempRoleTab[i]
				local lv, school = 0,0
				if roleData then
					lv = roleData.lv
					school = roleData.school
				end
				local spr = LoginUtils.createSprite(bg, "res/serverlist/role_" .. school .. ".png", cc.p(230 + ( i - 1) * 45, 48))
				LoginUtils.createLabel(bg, "" .. lv .. LoginUtils.getStrByKey("faction_player_level"), cc.p(spr:getPositionX(), 20), cc.p(0.5, 0.5), 16):setColor(MColor.white)
			end
		end		
	end
	return cell
end

return ServerSelectLayer