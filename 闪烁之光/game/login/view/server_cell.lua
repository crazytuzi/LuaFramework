-- --------------------------------------------------------------------
-- 
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
ServerCell = class("ServerCell", function() 
	return ccui.Widget:create()
end)

local controller = LoginController:getInstance()
local model = controller:getModel()

function ServerCell:ctor()
	self.rolesNum = 0
	self.roles = {}
	self.role_cell_list = {}
	self.scroll_h = 100
	self.isOpenRoles = false

	self.root_wnd = createCSBNote(PathTool.getTargetCSB("login/server_cell"))
	self:addChild(self.root_wnd)

	local size = self.root_wnd:getContentSize()
    self:retain()
	self:setContentSize(size)
	self:setAnchorPoint(0,1)
	self:setCascadeOpacityEnabled(true)
	self.cell_w = size.width
	self.cell_h = size.height

	self.select_bg = self.root_wnd:getChildByName("select_bg")
	self.state_icon = self.root_wnd:getChildByName("state_icon")
	self.close_icon = self.root_wnd:getChildByName("close_icon")
	self.icon_state = self.root_wnd:getChildByName("icon_state")
	self.server_id = self.root_wnd:getChildByName("server_id")
	self.server_name = self.root_wnd:getChildByName("server_name")
	self.role_info = self.root_wnd:getChildByName("role_info")
	self.role_lev = self.role_info:getChildByName("role_sum")
end

--==============================--
--desc:设置服务器数据，以及当前角色信息
--time:2018-06-25 07:04:13
--@data:
--@return 
--==============================--
function ServerCell:setBaseData(data, is_role)
	if data == nil or data.v == nil then return end

	self.data = data
	self.idx = data.idx

	local state_type = 1
	if self.data.v.isClose then
		state_type = 2
		self.close_icon:setVisible(true)
		self.state_icon:setVisible(false)
	else
		self.close_icon:setVisible(false)
		if self.data.v.isNew then
			state_type = 0
			self.state_icon:setVisible(true)
		else
			self.state_icon:setVisible(false)
		end
	end
	self.icon_state:loadTexture(PathTool.getResFrame("login2", "login2_100".. state_type), LOADTEXT_TYPE_PLIST)

	-- 动态控制尺寸大小
	self:addRolesSelectPanel()

	-- 服务器名字可以提前设置
	self.server_name:setString(self.data.v.srv_name)
	if is_role then
		self.server_name:setPositionX(309)
		self.server_id:setString(LoginController:getInstance():getModel():getSrvGroupNameByGroupId(self.data.v.group_id) .. string.format(TI18N("%s服"), self.data.v.group_num))
	else
		self.server_name:setPositionX(222)
		self.server_id:setString(string.format(TI18N("%s服"), self.data.v.group_num))
	end

	self.role_first = {}
	self.role_first.isEmpty = true
	local role_count = data.v.role_count
	if role_count > 0 then
		self.role_lev:setString(data.role_count)
		self.role_info:setVisible(true)
		self.role_lev:setVisible(true)
	else
		self.role_lev:setVisible(false)
		self.role_info:setVisible(false)
	end 
end

--==============================--
--desc:更新具体角色数据
--time:2018-06-25 07:08:29
--@roles:
--@return 
--==============================--
function ServerCell:updateRoleData(roles)
	if roles then
		self.roles = roles
		self.rolesNum = #roles
		table.sort(self.roles, function(a,b) return b.lev<a.lev end)
		self:updateRoleCellContentSize()
		self:update()
	end
end

-- 添加 多角色面板
function ServerCell:addRolesSelectPanel()
	if self.data == nil or self.data.v == nil then return end
	--[[if self.arrow == nil then
		self.arrow = createImage(self, PathTool.getResFrame("login2","login2_1008"), 40, -8, cc.p(0.5, 0.5), true)
	end--]]
	local cell_h = 84 -- 角色列表的单位高度
	local scroll_h = cell_h
	-- 后端说这里的 role_count 是不准的,于是要等请求回来角色数据再刷新高度和位置
	--[[local role_count = self.data.v.role_count
	if role_count <= 1 then
		scroll_h = cell_h + 0
	else
		scroll_h = cell_h * 2 + 5
	end--]]
    scroll_h = scroll_h + 10
	if self.roleSelectedPanel == nil then
		self.roleSelectedPanel = ccui.Layout:create()
		self.roleSelectedPanel:setAnchorPoint(cc.p(0, 1))
		self.roleSelectedPanel:setPosition(cc.p(16, 0))
		self.roleSelectedPanel:setTouchEnabled(false)
		self:addChild(self.roleSelectedPanel)
		self.roleSelectedPanel:setCascadeOpacityEnabled(true)
	end
	self.roleSelectedPanel:setContentSize(cc.size(397, scroll_h))

	if self.scroll_view == nil then
		self.scroll_view = createScrollView(397,163, 0, 0, self.roleSelectedPanel, ccui.ScrollViewDir.vertical)
		self.scroll_view:setCascadeOpacityEnabled(true)
		self.scroll_view:setAnchorPoint(0, 0)
	end
	self.scroll_view:setContentSize(cc.size(397, scroll_h))
	self.roleSelectedPanel:setVisible(false)
	--self.arrow:setVisible(false)

	self.scroll_h = scroll_h
end

-- 根据真实角色数量调整高度
function ServerCell:updateRoleCellContentSize(  )
	if not self.roleSelectedPanel or not self.scroll_view then return end

	local cell_h = 84 -- 角色列表的单位高度
	local scroll_h = 0
	if self.rolesNum <= 1 then
		scroll_h = cell_h + 0
	else
		scroll_h = cell_h * 2 + 5
	end
    scroll_h = scroll_h + 10
    self.roleSelectedPanel:setContentSize(cc.size(397, scroll_h))
    self.scroll_view:setContentSize(cc.size(397, scroll_h))
    self.scroll_h = scroll_h
end

function ServerCell:update()
	if self.scroll_view then
		self.scroll_view:removeAllChildren()
	end
	local function click_callback(item)
		local is_agree = SysEnv:getInstance():getBool(SysEnv.keys.user_proto_agree, false)
	    if checkUserProto and checkUserProto() and not is_agree then
	    	message(TI18N("请勾选同意开始游戏按钮下方的 诗悦游戏用户协议 和 隐私保护指引,即可进入游戏")) 
	        return
	    end

		if self.data == nil or self.data.v == nil then return end
		if NEED_CHECK_CLOSE == true and self.data.v.isClose then return end
		if not GameNet:getInstance():IsServerConnect() then
			local login_data = model:getLoginData()
			login_data.host = self.data.v.host
			login_data.open_time = self.data.v.open_time
			if login_data and login_data.usrName and login_data.usrName ~= "" and not self.connecting then
				self.connecting = true
				controller:requestLoginGame(login_data.usrName, self.data.v.ip, self.data.v.port, false)
				delayOnce(function() 
					self.connecting = false
				end, 0.5)
			end
		else
            sdkSubmitUserData(1) -- 选择服务器时 上报SDK
			if item.isEmpty then
				controller:request10101Create()
			else
				controller:request10102Login(item.data.rid, item.data.srv_id)
			end
		end
		model:setCurSrv(self.data.v, true)
	end

    local index, _y = 0
	local total = 88
	if #self.roles > 0 then
		local sum = #self.roles
		total = sum * 78 + (sum + 1) * 5
		local scroll_size = self.scroll_view:getContentSize()
		local maxH = math.max(total, scroll_size.height)
		self.scroll_view:setInnerContainerSize(cc.size(scroll_size.width, maxH)) 
		for i, v in ipairs(self.roles) do
			local cell = RoleLoginCell.new(v, self.scroll_view)
			_y = maxH - (5 + (i - 1) * (78 + 10))
			cell:setPosition(0, _y)
			cell:addCallBack(click_callback)
			index = index + 1
			self.role_cell_list[i] = cell
		end
	else
		local emptyVo = {}
		emptyVo.isEmpty = true
		local cell = RoleLoginCell.new(emptyVo, self.scroll_view)
		cell:setPosition(0, total)
		cell:addCallBack( click_callback )
		index = index + 1
	end

	local scroll_size = self.scroll_view:getContentSize()

    local max_height = math.max(scroll_size.height, total)
    self.scroll_view:setInnerContainerSize(cc.size(scroll_size.width,max_height))
end

function ServerCell:addCallBack(call_fun)
	local function click_callback(item)
		if self.data == nil or self.data.v == nil then return end
		if NEED_CHECK_CLOSE == true and self.data.v.isClose then return end
		if not GameNet:getInstance():IsServerConnect() then
			local login_data = model:getLoginData()
			login_data.host = self.data.v.host
			login_data.open_time = self.data.v.open_time
			if login_data and login_data.usrName and login_data.usrName ~= "" and not self.connecting then
				self.connecting = true
				controller:requestLoginGame(login_data.usrName, self.data.v.ip, self.data.v.port, false)
				delayOnce(function() 
					self.connecting = false
				end, 0.5)
			end
		else
            sdkSubmitUserData(1) -- 选择服务器时 上报SDK
			if item.isEmpty then
				controller:request10101Create()
			else
				controller:request10102Login(item.rid, item.srv_id)
			end
		end
	end

	self.callBack = call_fun
	self:setTouchEnabled(true)
	self:addTouchEventListener(function(sender, eventType) 
		if eventType == ccui.TouchEventType.ended then
			if self.data == nil or self.data.v == nil then return end
			if NEED_CHECK_CLOSE == true and (self.data.v.isClose or GameNet:getInstance():getTime() - self.data.v.open_time < 0) then
				model:checkReloadServerData(self.data.v)
			else
				if self.callBack ~= nil then
					self.callBack(self)
				end
			end
		end
	end)
end

function ServerCell:setSelected(status)
	if self.select_bg then
		self.select_bg:setVisible(status)
	end
	if status == true then
		self.server_id:setTextColor(cc.c4b(162,62,1,255))
		self.server_name:setTextColor(cc.c4b(162,62,1,255))
	else
		self.server_id:setTextColor(cc.c4b(104,69,42,255))
		self.server_name:setTextColor(cc.c4b(104,69,42,255))
	end
end

-- 展开多角色界面
function ServerCell:showRoles()
	--self.arrow:setVisible(true)
	self.roleSelectedPanel:setVisible(true)
	self:setSelected(true)
	self.isOpenRoles = true
end

-- 关闭多角色界面
function ServerCell:closeRoles()
	--self.arrow:setVisible(false)
	self.roleSelectedPanel:setVisible(false)
	self:setSelected(false)
	self.isOpenRoles = false
end

function ServerCell:clearLayout()
	--self.selected:stopAllActions()
	self:setSelected(false)
	self:removeFromParent()
end

function ServerCell:DeleteMe()
	--self.selected:stopAllActions()
	if self.role_cell_list then
		for _,item in ipairs(self.role_cell_list) do
			if item then
				if item["DeleteMe"] then
					item:DeleteMe()
				end
			end
		end
	end
	self:removeAllChildren()
	self:removeFromParent()
	self:release()
end

function ServerCell:getData()
	return self.data
end
