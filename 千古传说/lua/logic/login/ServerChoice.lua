
local ServerChoice = class("ServerChoice", BaseLayer)

function ServerChoice:ctor()
    self.super.ctor(self)
    self:initZoneList()
    self:init("lua.uiconfig_mango_new.login.ServerChoice")

end

function ServerChoice:initUI(ui)
	self.super.initUI(self,ui)

	self.btn_close 		= TFDirector:getChildByPath(ui, 'btn_close')
	self.laye_Scroll 	= TFDirector:getChildByPath(ui, 'laye_Scroll')
	self.laye_zuijin 	= TFDirector:getChildByPath(ui, 'laye_zuijin')

	self.layer_list		= TFDirector:getChildByPath(ui, 'panel_zone')
	self.btn_zone		= TFDirector:getChildByPath(ui, 'btn_zone')

	self.btn_zone:setVisible(false)

	local userInfo 		= SaveManager:getUserInfo()
	-- local serverList 	= SaveManager:getServerList()
	local index = 1
	for k,ip in pairs(userInfo.serverHistory) do
		local serverItem = SaveManager:getServerInfo(ip)
		if serverItem and index < 5  then
			local btn_server = self:getServerBtn(serverItem)

		 	local indexX = index%2
		    if indexX == 0 then
		        indexX = 2
		    end
		    btn_server:setPosition(ccp(10 + (indexX - 1) * 305,  10 + (2 - math.ceil(index/2 )) * 70))
  
			self.laye_zuijin:addChild(btn_server)

			index = index + 1
		end
	end

	-- local row = math.ceil(#serverList/2)

	-- local scrollView = TFScrollView:create()
	-- scrollView:setPosition(ccp(0,0))
	-- scrollView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)

	-- scrollView:setSize(self.laye_Scroll:getSize())
	-- scrollView:setInnerContainerSize(CCSizeMake(self.laye_Scroll:getSize().width , 70 * row + 40))
	-- self.laye_Scroll:addChild(scrollView)
	-- scrollView:setBounceEnabled(true)

	-- for k,serverItem in pairs(serverList) do
	-- 	local i = math.floor((k - 1)/2)
	-- 	local j = (k - 1) % 2
	-- 	-- print(" k , v : ",k,i,j,serverItem)
	-- 	local btn_server = self:getServerBtn(serverItem)
	-- 	btn_server:setPosition(ccp(10 +j * 295, (row - i - 1) * 70 + 40))
	-- 	scrollView:addChild(btn_server)
	-- end

	-- scrollView:scrollToTop()

	local zone = self.ZoneList:getObjectAt(1)
	if zone then
		self:drawServerListWithZoneId(zone.id)
	end

	self:drawZoneList()
end

function ServerChoice:getServerBtn(serverItem)

	local openServer = serverItem.openServer

	--新服 > 推荐 > 火爆 -- 
	local mark = serverItem.mark
	-- print("mark = ", mark)
    -- 1110 -- 火爆 --  推荐 -- 新服
	-- print("mark1 = ", bit_and(mark,2)) -- 0010 -- 新服
	-- print("mark2 = ", bit_and(mark,4)) -- 0100 -- 推荐
	-- print("mark3 = ", bit_and(mark,8)) -- 1000 -- 火爆

	local tag1 = bit_and(mark,2)
	local tag2 = bit_and(mark,4)
	local tag3 = bit_and(mark,8)


	local btn_server = TFTextButton:create()
	btn_server.serverInfo = serverItem


	local serverName = SaveManager:getServerName(serverItem)

	local label = TFLabel:create()
	label:setPosition(ccp(-130,0))
	label:setAnchorPoint(ccp(0,0.5))
	label:setFontSize(24)
	label:setFontName("黑体")
	label:setColor(ccc3(0,0,0))
	btn_server:addChild(label)

	btn_server.logic 		= self

	btn_server:setTextureNormal("ui_new/login/xf_fuwuqidi.png")
	btn_server:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onclickServerNode))

	if openServer == false then
		--serverName = serverName.."(维护中)"
		serverName = stringUtils.format(localizable.serverChoice_stop,serverName)
		label:setText(serverName)

		btn_server:setAnchorPoint(ccp(0,0))
		return btn_server
	else
		label:setText(serverName)
	end

	if tag1 ~= 0 then
		local img_new = TFImage:create("ui_new/login/xf_new.png")
		img_new:setPosition(ccp(86,2))
		img_new:setAnchorPoint(ccp(0,0.5))
		btn_server:addChild(img_new)

	
		btn_server:setAnchorPoint(ccp(0,0))
		return btn_server
	end

	if tag2 ~= 0 then
		local img_jian = TFImage:create("ui_new/login/xf_jian.png")
		img_jian:setPosition(ccp(86,2));
		img_jian:setAnchorPoint(ccp(0,0.5))
		btn_server:addChild(img_jian)

		btn_server:setAnchorPoint(ccp(0,0))
		return btn_server
	end


	
	if tag3 ~= 0 then
		local img_bao = TFImage:create("ui_new/login/xf_bao.png")
		img_bao:setPosition(ccp(86,2))
		img_bao:setAnchorPoint(ccp(0,0.5))
		btn_server:addChild(img_bao)

		btn_server:setAnchorPoint(ccp(0,0))
		return btn_server
	end

	btn_server:setAnchorPoint(ccp(0,0))
	return btn_server
end

function ServerChoice:removeUI()
	self.super.removeUI(self)

	self.laye_Scroll = nil
end

function ServerChoice:registerEvents()
	ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)

	self.severlist_requestCallback = function (events)
		self:initZoneList()	
		local zone = self.ZoneList:getObjectAt(1)
		if zone then
			self:drawServerListWithZoneId(zone.id)
		end

		self:drawZoneList()
	end
	
	TFDirector:addMEGlobalListener(LogonHelper.MSG_DOWNLOAD_SEVERLIST,self.severlist_requestCallback)

end

function ServerChoice:removeEvents()
	TFDirector:removeMEGlobalListener(LogonHelper.MSG_DOWNLOAD_SEVERLIST, self.severlist_requestCallback)
	self.severlist_requestCallback = nil
end

function ServerChoice:initZoneList()
	self.ZoneList = TFArray:new()

	local zoneList = SaveManager:getZoneList()
	for k,v in pairs(zoneList) do
		self.ZoneList:push(v)
	end

	local function zoneSort(zone1, zone2)
		if zone1.id >= zone2.id then
			return true
		end

		return false
	end

	self.ZoneList:sort(zoneSort)
	self.zoneid = -1
	print("zone length = ", self.ZoneList:length())
end

function ServerChoice:initServerList(zoneid)
	self.serverList = TFArray:new()
	print("initServerList zoneid ", zoneid)
	local serverList = SaveManager:getServerList()

	for k,v in pairs(serverList) do
		if v.zoneId == zoneid then
			self.serverList:push(v)
		end
	end
	
	-- print("self.serverList = ", self.serverList)
	if self.serverList:length() < 1 then
		print("zoneid = ", zoneid)
		print("no zoneid server")
		return
	end

	local function ServerSort(zone1, zone2)
		if zone1.zoneId >= zone2.zoneId then
			return true
		end

		return false
	end

	self.serverList:sort(ServerSort)
	print("serverList length = ", self.serverList:length())
end


function ServerChoice:drawServerListWithZoneId(zoneid)
	local userInfo 		= SaveManager:getUserInfo()
	local serverList 	= SaveManager:getServerList()
	print("self.zoneid = ", self.zoneid)
	print("zoneid = ", zoneid)
	if self.zoneid == zoneid then
		return
	end

	self:initServerList(zoneid)

	self.zoneid = zoneid

	-- local scrollView = self.laye_Scroll:getChildByTag(167)
	if self.scrollView then
		self.scrollView:removeFromParentAndCleanup(true)
		self.scrollView = nil
	-- else
	end
	

	local length = self.serverList:length()


	if length < 1 then
		return
	end

	local row = math.ceil(length/2)

	local scrollView = TFScrollView:create()
	scrollView:setPosition(ccp(0,0))
	scrollView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)


	scrollView:setSize(self.laye_Scroll:getSize())
	local height = self.laye_Scroll:getSize().height
	local height2 =  70 * row + 40
	-- if height2 < height then
	-- 	height2 = height
	-- end

	scrollView:setInnerContainerSize(CCSizeMake(self.laye_Scroll:getSize().width , height2))
	self.laye_Scroll:addChild(scrollView)
	scrollView:setBounceEnabled(true)
	scrollView:setTag(617)

	self.scrollView = scrollView

	-- for k = 1, length in pairs(serverList) do
	for k = 1, length do
		local i = math.floor((k - 1)/2)
		local j = (k - 1) % 2
		local serverItem = self.serverList:getObjectAt(k)
		-- print('serverItem = ', serverItem)
		local btn_server = self:getServerBtn(serverItem)
		btn_server:setPosition(ccp(10 +j * 305, (row - i - 1) * 70 + 40))
		scrollView:addChild(btn_server)
	end

	scrollView:scrollToTop()
end

function ServerChoice:drawZoneList()
	if self.tableView ~= nil then
		self.tableView:reloadData()
        return
    end

    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.layer_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    -- tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLBOTTOMUP)
    tableView:setPosition(self.layer_list:getPosition())
    self.tableView = tableView
    self.tableView.logic = self


    -- tableView:addMEListener(TFTABLEVIEW_TOUCHED, ServerChoice.tableCellTouched)
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, ServerChoice.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, ServerChoice.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, ServerChoice.numberOfCellsInTableView)
    tableView:reloadData()

    self.layer_list:getParent():addChild(self.tableView,1)

end

function ServerChoice.numberOfCellsInTableView(table)
	local self = table.logic

    return self.ZoneList:length()
end

function ServerChoice.cellSizeForTable(table,idx)
    return 95, 151
end

function ServerChoice.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = self.btn_zone:clone()

        node:setPosition(ccp(100, 50))
        cell:addChild(node)
        node:setTag(617)
        node.logic = self
        node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.touchZoneEvent))
    end

    node = cell:getChildByTag(617)
    node.index = idx + 1
    self:drawOutNode(node)

    node:setVisible(true)
    return cell
end

function ServerChoice:drawOutNode(node)
    local index = node.index
    local lbl_name  = TFDirector:getChildByPath(node, "lbl_name")

    local zone = self.ZoneList:getObjectAt(index)
	if zone then
		lbl_name:setText(zone.zoneName)

		local cellPicName = "ui_new/login/xf_tab1.png"
		if self.zoneid == zone.id then
			cellPicName = "ui_new/login/xf_tab2.png"
		end
		node:setTextureNormal(cellPicName)
	end
end

function ServerChoice.touchZoneEvent(sender)
    local self = sender.logic

    local index = sender.index

    local zone = self.ZoneList:getObjectAt(index)
	if zone then
		self:drawServerListWithZoneId(zone.id)
	end
    
	self:drawZoneList()
end

function ServerChoice.onclickServerNode(sender)
	local self = sender.logic
	
	local serverInfo = sender.serverInfo

	-- print("serverInfo = ", serverInfo)
	local open = serverInfo.openServer
	if serverInfo and open ~= nil and open == false then
		--local msg = "服务器维护中"
		local msg = localizable.serverChoice_serverstop
		if serverInfo.upkeepMessage then
			msg = serverInfo.upkeepMessage
		end

		toastMessage(msg)
		return
	end

	self.logic:ServerChoice(serverInfo)
	AlertManager:close()
	CommonManager:closeConnection()
end

return ServerChoice
