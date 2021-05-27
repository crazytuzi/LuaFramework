----------------------------------------------------
-- LoginServerItem
----------------------------------------------------
LoginServerItem = LoginServerItem or BaseClass(BaseRender)
function LoginServerItem:__init(w, h)
	self.width, self.height = w, 80
	self.view:setContentWH(self.width, self.height + 10)
end

function LoginServerItem:__delete()
	self.have_role_remind = nil
end

function LoginServerItem:CreateChild()
	BaseRender.CreateChild(self)

	local img_btn_bg = ResPath.GetLogin("btn_server_normal")
	self.img_bg = XUI.CreateImageView(self.width / 2, self.height / 2, img_btn_bg)
	self.view:addChild(self.img_bg)

	local point = XUI.CreateImageView(80, self.height / 2, ResPath.GetLogin("btn_blue"))
	self.view:addChild(point, 10)
	
	local btn_select_path = ResPath.GetLogin("btn_server_select")
	self.select_eff = XUI.CreateToggleButton(self.width / 2, self.height / 2, 0, 0, false, nil, btn_select_path, "", true)
	self.select_eff:setTouchEnabled(false)
	self.view:addChild(self.select_eff)

	self.text_server_name = XUI.CreateText(120, self.height / 2, 0, 0, cc.TEXT_ALIGNMENT_LEFT, "", nil, 30, COLOR3B.G_W)
	self.text_server_name:setAnchorPoint(0, 0.5)
	self.view:addChild(self.text_server_name)

	self.text_flag = XUI.CreateText(self.width - 30, self.height / 2, 150, 30, cc.TEXT_ALIGNMENT_RIGHT, "", nil, 30)
	self.text_flag:setAnchorPoint(1, 0.5)
	self.view:addChild(self.text_flag)

	self:OnSelectChange(self:IsSelect())
end

function LoginServerItem:OnFlush()
	local open_tips = ""
	local now_server_time = GLOBAL_CONFIG.server_info.server_time + (Status.NowTime - GLOBAL_CONFIG.client_time)
	-- 开服时间
	if nil ~= self.data.open_time and now_server_time < self.data.open_time then
		local t_time = os.date("*t", self.data.open_time)
		open_tips = string.format(Language.Login.ServerOpenTips, t_time.month, t_time.day, t_time.hour, t_time.min)
	-- 维护时间
	elseif nil ~= self.data.pause_time and now_server_time < self.data.pause_time then
		local t_time = os.date("*t", self.data.pause_time)
		open_tips = string.format(Language.Login.ServerOpenTips, t_time.month, t_time.day, t_time.hour, t_time.min)
	end

	local server_text = ""
	local show_server_id = self.data.id 
	local show_1500 = 1500
	local show_2000 = 2000

	local server_offset = GLOBAL_CONFIG.server_info.server_offset or 0
	if server_offset >= 1500 then
		server_offset = 0
	end
	if show_server_id < show_1500 and show_server_id > server_offset then 	--偏移id
		show_server_id = show_server_id - server_offset
	end

	if show_server_id > show_1500 and show_server_id < show_2000 then
		-- show_server_id = show_server_id - show_1500
		show_server_id = show_server_id % 10
	end
	
	if show_2000 == show_server_id then
		server_text = self.data.name .. open_tips
	elseif nil ~= self.data.special_group_name then
		-- 专服不显示服务器id
		server_text = self.data.name .. open_tips
	else
		server_text = show_server_id .. Language.Login.Fu .. "-" .. self.data.name .. open_tips
	end
	self.text_server_name:setString(server_text)

	local color = (1 == self.data.flag or 5 == self.data.flag) and COLOR3B.RED or COLOR3B.GREEN
	local flag_text = Language.Login[self.data.flag+1] or ""
	self.text_flag:setColor(color)
	self.text_flag:setString(flag_text)

	local have_role = ALL_SERVER_HAVE_ROLES_T[tonumber(self.data.id)] and true or false
	if have_role and not self.have_role_remind then
		self.have_role_remind = XUI.CreateImageView(self.width - 12, self.height - 15, ResPath.GetMainui("remind_flag"), true)
		self.view:addChild(self.have_role_remind, 99)
	elseif self.have_role_remind then
		self.have_role_remind:setVisible(have_role)
	end
end

function LoginServerItem:CreateSelectEffect()
end

-- 选择状态改变
function LoginServerItem:OnSelectChange(is_select)
	if nil == self.select_eff then return end
	self.select_eff:setTogglePressed(is_select)
end

----------------------------------------------------
-- LoginSelectServersItem
----------------------------------------------------
LoginSelectServersItem = LoginSelectServersItem or BaseClass(BaseRender)
function LoginSelectServersItem:__init(w, h)
	self.width, self.height = w, 90
	self.view:setContentWH(self.width, self.height)
end

function LoginSelectServersItem:__delete()
	self.have_role_remind = nil
end

function LoginSelectServersItem:CreateChild()
	BaseRender.CreateChild(self)

	self.img_bg = XUI.CreateImageView(self.width / 2, self.height / 2, "", true)
	self.view:addChild(self.img_bg)

	self.text_desc = XUI.CreateText(self.width / 2, self.height / 2, 170, 28, nil, "", nil, 28, COLOR3B.GOLD)
	self.view:addChild(self.text_desc)

	self:OnSelectChange(self:IsSelect())
end

function LoginSelectServersItem:OnFlush()
	local have_role = false
	if #self.data <= 0 then
		self.text_desc:setString(Language.Login.TuiJian)

		local recommend_server = GLOBAL_CONFIG.server_info.last_server or 1
		local last_server = 0
		local local_last_server = PlatformAdapter:GetShareValueByKey(AgentAdapter:GetPlatName() .. "last_login_server")
		if local_last_server == nil or local_last_server == "" then
			last_server = recommend_servers
		else	
			last_server = tonumber(local_last_server) or 1
		end

		have_role = self:IsHaveRole({{id = recommend_server}}) or self:IsHaveRole({{id = last_server}})
	else
		if self.data[1].id >= 2000 then
			self.text_desc:setString(Language.Common.TestServer)
		elseif self.data[1].special_group_name ~= nil then
			-- 有专服组名的显示专服组名
			self.text_desc:setString(self.data[1].special_group_name)
		else
			self.text_desc:setString(self:GetTxtStr())
		end
		have_role = self:IsHaveRole(self.data)
	end

	if have_role and not self.have_role_remind then
		self.have_role_remind = XUI.CreateImageView(self.width - 28, self.height - 20, ResPath.GetMainui("remind_flag"), true)
		self.view:addChild(self.have_role_remind, 99)
	elseif self.have_role_remind then
		self.have_role_remind:setVisible(have_role)
	end
end

function LoginSelectServersItem:GetTxtStr()
	local str = self.index
	if self.data == nil then return str end
	local min_id = self.data[#self.data].id
	local max_id = self.data[1].id

	local server_offset = GLOBAL_CONFIG.server_info.server_offset or 0
	local show_1500 = 1500
	local show_2000 = 2000
	if server_offset >= show_1500 then
		server_offset = 0
	end

	if min_id < show_1500 and min_id > server_offset then
		min_id = min_id - server_offset
	end

	if min_id > show_1500 and min_id < show_2000 then
		-- min_id = min_id - show_1500
		min_id = min_id % 10
	end

	if max_id < show_1500 and max_id > server_offset then
		max_id = max_id - server_offset
	end

	if max_id > show_1500 and max_id < show_2000 then
		-- max_id = max_id - show_1500
		max_id = max_id % 10
	end

	if min_id == max_id then
		str = min_id .. Language.Login.Fu
	else
		str = min_id .. "-" .. max_id .. Language.Login.Fu
	end
	return str
end

function LoginSelectServersItem:CreateSelectEffect()
end

function LoginSelectServersItem:IsHaveRole(data)
	for k, v in pairs(data or {}) do
		if ALL_SERVER_HAVE_ROLES_T[tonumber(v.id)] then
			return true
		end
	end
	return false
end

-- 选择状态改变
function LoginSelectServersItem:OnSelectChange(is_select)
	if nil == self.img_bg then return end

	if is_select then
		self.img_bg:loadTexture(ResPath.GetCommon("btn_110_select"))
	else 
		self.img_bg:loadTexture(ResPath.GetCommon("btn_110_normal"))
	end
end
