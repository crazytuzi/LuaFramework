-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_select_server = i3k_class("wnd_select_server",ui.wnd_base)

local STATE_ICON = {1911, 1912, 1913} --正常，爆满，维护
local IS_SELECT_ICON = {2900, 2901} -- 当前，推荐
--后面这个state改成3位数字的状态XYZ
--最低位Z：表示是否是推荐服，1表示推荐，0表示不推荐
--次低位Y：表示是否是新服，1表示新服，0表示老服
--最高位X：表示当前服务器状态，1表示正常，2表示爆满，3表示维护

--X当前服务器的三种状态
local STATE_NORMAL		= 1 	--正常
local STATE_FULL		= 2		--爆满
local STATE_SERVICING	= 3 	--维护


local LAYER_FWQLBT2 = "ui/widgets/fwqlbt2"
local LAYER_FWQLBT3 = "ui/widgets/fwqlbt3"
local RowitemCount = 3
	
function wnd_select_server:ctor()
	self._serverId = 0
end

function wnd_select_server:configure()
	local widgets = self._layout.vars
	
	--self.lastScroll = widgets.lastScroll
	self.allScroll	= widgets.allScroll
	--self.noLast		= widgets.noLast
	widgets.closeBtn:onClick(self, self.onCloseUI)
end



function wnd_select_server:refresh(serverId)
	self._serverId = serverId
	
	--self:updateLastScroll()
	self:updateAllScroll()
end

function wnd_select_server:updateLastScroll()
	local info = i3k_get_recent_server_data()
	local data = {}
	for i, e in ipairs(info) do
		if #data < 4 then
			table.insert(data, e)
		end
	end
	self.lastScroll:removeAllChildren()
	local all_layer = self.lastScroll:addChildWithCount(LAYER_FWQLBT2, RowitemCount, #data)
	for i, e in ipairs(data) do
		local widget = all_layer[i].vars
		self:updateWidget(widget, e)
	end
	self.lastScroll:stateToNoSlip()
	--self.noLast:setVisible(#data <= 0)
end

function wnd_select_server:updateAllScroll()
	local recentServerInfo = i3k_get_recent_server_data()
	local data = {}
	for i, e in ipairs(recentServerInfo) do
		if #data < 6 then
			table.insert(data, e)
		end
	end
	local info = i3k_get_server_list()
	local newList = i3k_get_new_server_list(info)
	table.sort(info, function (a,b)
		return a.id > b.id
	end)
	local nodeRecent = require(LAYER_FWQLBT3)()
	if next(data) then
		nodeRecent.vars.labelName:setText("最近登录")
	else
		nodeRecent.vars.labelName:setText("推荐服务器")
		table.insert(data, newList[#newList])
	end
	local nodeAll = require(LAYER_FWQLBT3)()
	nodeAll.vars.labelName:setText("服务器列表")
	self.allScroll:removeAllChildren()
	self.allScroll:addItem(nodeRecent)
	local recentServer = self.allScroll:addItemAndChild(LAYER_FWQLBT2, RowitemCount, #data)
	for i, e in ipairs(data) do
		local widget = recentServer[i].vars
			self:updateWidget(widget, e)
			
		end
	self.allScroll:addItem(nodeAll)
	local all_layer = self.allScroll:addItemAndChild(LAYER_FWQLBT2, RowitemCount, #info)
	for i, e in ipairs(info) do
			local widget = all_layer[i].vars
			self:updateWidget(widget, e)
	end
end

function wnd_select_server:updateWidget(widget, data)
	local serverState, isNew, isRecommend = i3k_get_split_server_state(data.state)

	widget.serverName:setText(data.name)
	if not serverState then --如果最高位X配置错误则不显示服务器状态
		widget.state:setVisible(false)
	else
		widget.state:setVisible(true)
		widget.state:setImage(g_i3k_db.i3k_db_get_icon_path(STATE_ICON[serverState]))
	end
	local icon = self._serverId == data.serverId and IS_SELECT_ICON[1] or IS_SELECT_ICON[2]
	widget.tag:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
	widget.tag:setVisible(self._serverId == data.serverId or isRecommend == 1)
	widget.isNewServer:setVisible(isNew == 1)
	data.serverState = serverState or STATE_SERVICING
	widget.selectBtn:onClick(self, self.selectSever, data)
end

function wnd_select_server:selectSever(sender, data)
	if data.serverState == STATE_SERVICING then
		g_i3k_ui_mgr:PopupTipMessage("服务器维护中")
		return
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Login, "updateServerLabel", data.addr, data.name, data.serverId)
	g_i3k_ui_mgr:CloseUI(eUIID_SelectServer)
end

function wnd_create(layout)
	local wnd = wnd_select_server.new()
	wnd:create(layout)
	return wnd
end
