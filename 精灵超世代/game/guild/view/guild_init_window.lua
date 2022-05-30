-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会的初始窗体，包含了创建公会，公会列表以及公会查找标签页
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildInitWindow = GuildInitWindow or BaseClass(BaseView)

function GuildInitWindow:__init()
	self.ctrl = GuildController:getInstance()
	self.model = self.ctrl:getModel()
	self.win_type = WinType.Full
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guild", "guild"), type = ResourcesType.plist},
	}
	self.tab_info_list = {
		{
			label = TI18N("公会列表"),
			notice = TI18N(""),
			index = GuildConst.init_type.list,
			status = true
		}, 
		{
			label = TI18N("创建公会"),
			notice = TI18N(""),
			index = GuildConst.init_type.create,
			status = true
		},
        {
            label = TI18N("查找公会"),
            notice = TI18N(""),
            index = GuildConst.init_type.serach,
            status = true
        } 
	}
	self.show_close_btn = false
	self.panel_list = {}
	self.cur_panel = nil
end 

function GuildInitWindow:open_callback()
end

function GuildInitWindow:register_event()
end

function GuildInitWindow:openRootWnd(index)
	index = index or GuildConst.init_type.list
	self:setSelecteTab(index, true) 
end

function GuildInitWindow:selectedTabCallBack(index)
	if index == GuildConst.init_type.create then
		self:changeTitleName(TI18N("创建公会"))
	elseif index == GuildConst.init_type.list then
		self:changeTitleName(TI18N("公会列表"))
	elseif index == GuildConst.init_type.serach then
		self:changeTitleName(TI18N("查找公会")) 
	end
	self:changePanel(index)
end

function GuildInitWindow:changePanel(index)
	if self.cur_panel ~= nil then
		self.cur_panel:addToParent(false)
		self.cur_panel = nil
	end
	local cur_panel = self.panel_list[index]
	if cur_panel == nil then
		if index == GuildConst.init_type.create then
			cur_panel = GuildCreatePanel.new()
		elseif index == GuildConst.init_type.list then
			cur_panel = GuildListPanel.new()
		elseif index == GuildConst.init_type.serach then
			cur_panel = GuildSearchPanel.new()
		end
		self.panel_list[index] = cur_panel

		if cur_panel ~= nil then
			self.container:addChild(cur_panel)
		end
	end

	if cur_panel ~= nil then
		cur_panel:addToParent(true) 
		self.cur_panel = cur_panel
		self.cur_index = index
	end
end

function GuildInitWindow:close_callback()
    self.ctrl:openGuildInitWindow(false)
	for k,panel in pairs(self.panel_list) do
		panel:DeleteMe()
	end
	self.panel_list = nil
end