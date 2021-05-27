----------------------------------------------------
-- 角色头像(小头像)
----------------------------------------------------
RoleHeadCell = RoleHeadCell or BaseClass(BaseRender)

-- 默认菜单项
RoleHeadDefItems = {0, 2, 3, 4, 5, 6, 10}
RoleHeadOnlineItems = {2, 3, 4, 5, 6, 10}

function RoleHeadCell:__init(has_bg, is_show)
	self.view:setContentWH(110, 110)
	self.view:setAnchorPoint(0.5, 0.5)

	self.vo = {
		role_id = 0,
		role_name = "",
		prof = 0,
		is_online = true,
		sex = 0,
	}

	self.is_show = true
	if is_show ~= nil then
		self.is_show = is_show
	end
	if nil == self.has_bg then self.has_bg = true end

	self.add_items = {}								-- 要添加的菜单项
	self.remove_items = {}							-- 要移除的菜单项
end

function RoleHeadCell:__delete()
	if nil ~= self.img_role_head then
		AvatarManager.Instance:CancelUpdateAvatar(self.img_role_head)
	end
end

-- 设置角色信息
function RoleHeadCell:SetRoleInfo(role_id, role_name, prof, is_online, sex)
	self.vo.role_id = role_id or 0
	self.vo.role_name = role_name
	self.vo.prof = prof or 0
	self.vo.is_online = is_online
	self.vo.sex = sex or 0
	if self.is_show then
		self:Flush()
	end
end

-- 添加菜单项
function RoleHeadCell:AddItems(...)
	self.add_items = {...}
end

-- 移除菜单项
function RoleHeadCell:RemoveItems(...)
	for i, v in ipairs({...}) do
		self.remove_items[v] = true
	end
end

function RoleHeadCell:CreateChild()
	BaseRender.CreateChild(self)
	-- if self.has_bg then
	-- 	local img_head_bg = XUI.CreateImageView(55, 55, ResPath.GetMainui("role_head_bg"), true)
	-- 	self.view:addChild(img_head_bg)
	-- end

	self.img_role_head = XUI.CreateImageView(55, 55, "", true)
	self.view:addChild(self.img_role_head)

	-- local img_head_frame = XUI.CreateImageView(55, 55, ResPath.GetMainui("role_head_frame"), true)
	-- self.view:addChild(img_head_frame)
	self.is_load = true
end

function RoleHeadCell:OnFlush()
	if not self.is_load then return end
	AvatarManager.Instance:CancelUpdateAvatar(self.img_role_head)
	if self.vo.prof > 0 then
		AvatarManager.Instance:UpdateAvatarImg(self.img_role_head, self.vo.role_id, self.vo.prof, false, not self.vo.is_online, self.vo.sex)
	else
		if "system" == self.vo.role_name then
			self.img_role_head:loadTexture(ResPath.GetChat("head_icon"))
		end
	end
end

function RoleHeadCell:OnClick()
	BaseRender.OnClick(self)
	self:OpenMenu()
end

function RoleHeadCell:OpenMenu()
	if 0 == self.vo.role_id and "" == self.vo.role_name then
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo[OBJ_ATTR.ENTITY_ID] == self.vo.role_id then
		return
	end

	local items = {}
	for k, v in pairs(RoleHeadDefItems) do
		if self:CanAddMenu(v, vo) then
			table.insert(items, {menu_index = v})
		end
	end
	for k, v in pairs(self.add_items) do
		if self:CanAddMenu(v, vo) then
			table.insert(items, v)
		end
	end
	UiInstanceMgr.Instance:OpenCustomMenu(items, self.vo)
end

-- 判断是否可以添加菜单项
function RoleHeadCell:CanAddMenu(menu_index, mainrole_vo)
	if nil ~= self.remove_items[menu_index] then
		return false
	end

	-- if self.vo.is_online ~= nil and not self.vo.is_online then
	-- 	-- 离线时不显示的菜单项
	-- 	for k,v in pairs(RoleHeadOnlineItems) do
	-- 		if v == menu_index then
	-- 			return false
	-- 		end
	-- 	end
	-- end

	return true
end
