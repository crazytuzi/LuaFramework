local WangChengZhengBaGloryView = WangChengZhengBaGloryView or BaseClass(SubView)

WangChengZhengBaGloryView.RolePostMaxCount = 6

function WangChengZhengBaGloryView:__init() 
	self.texture_path_list[1] = 'res/xui/wangchengzhengba.png'
	self.config_tab = {
		{"wangchengzhengba_ui_cfg", 2, {0}},
	}
end

function WangChengZhengBaGloryView:__delete()
end

function WangChengZhengBaGloryView:ReleaseCallBack()
	if nil ~= self.role_display_list then
		for k,v in pairs(self.role_display_list) do
			v:DeleteMe()
		end
		self.role_display_list = nil
	end

	self.layout_role_list = nil
end

function WangChengZhengBaGloryView:ShowIndexCallBack(index)
	self:OnFlushRole()
end

function WangChengZhengBaGloryView:LoadCallBack(index, loaded_times)
	self:CreateDisplayRoles()
	EventProxy.New(WangChengZhengBaData.Instance, self):AddEventListener(WangChengZhengBaData.GloryDataChangeEvent, BindTool.Bind(self.OnFlushRole, self))
end

function WangChengZhengBaGloryView:CreateDisplayRoles()
	if nil ~= self.layout_role_list or nil ~= self.role_display_list then return end
	self.layout_role_list = {}
	self.role_display_list = {}
	local flip_x_list = {2, 4, 6}
	for i=1,WangChengZhengBaGloryView.RolePostMaxCount do
		local layout_role = self.node_t_list["layout_display_role_" .. i]
		if nil == layout_role then
			ErrorLog("[wangchengzhengba_glory.lua][layout_role index: " .. i .. "] is nil!")
			break
		end
		layout_role.post.node:loadTexture(ResPath.GetWangChengZhengBa("post_" .. i))

		local pos_img = layout_role.img_role_display and layout_role.img_role_display.node
		if nil ~= pos_img then
			local x, y = pos_img:getPosition()
			local role_display = RoleDisplay.New(layout_role.node, 100, false, false, true, true)
			role_display:SetPosition(x, y)
			-- local mainrole = Scene.Instance:GetMainRole()
			-- if nil ~= mainrole then
			-- 	role_display:Reset(mainrole)
			-- end
			role_display:SetVisible(false)
			role_display:SetScale(0.6)

			self.role_display_list[i] = role_display

			pos_img:setVisible(false)
		end

		self.layout_role_list[i] = layout_role
		self.layout_role_list[i].node:setLocalZOrder(1)
	end


	for k,v in pairs(flip_x_list) do
		if self.role_display_list[v] then
			self.role_display_list[v]:SetRoleDisplayFlipX(true)
		end
	end
end

function WangChengZhengBaGloryView:SetGloryRoleDisplay(post, vo)
	local tag
	if post == SOCIAL_MASK_DEF.GUILD_LEADER then
		tag = 1
	elseif post == SOCIAL_MASK_DEF.GUILD_ASSIST_LEADER then
		tag = 2
	elseif post == SOCIAL_MASK_DEF.GUILD_TANGZHU_FOU then
		tag = 6
	elseif post == SOCIAL_MASK_DEF.GUILD_TANGZHU_THI then
		tag = 4
	elseif post == SOCIAL_MASK_DEF.GUILD_TANGZHU_SRC then
		tag = 5
	elseif post == SOCIAL_MASK_DEF.GUILD_TANGZHU_FIR then
		tag = 3

	end

	if not tag then return end
	if self.layout_role_list[tag] and self.role_display_list[tag] then
		if vo then
			self.layout_role_list[tag].lbl_role_name.node:setString(vo.name)
			self.role_display_list[tag]:SetVisible(true)
			self.role_display_list[tag]:SetRoleVo(vo)
		else
			self.layout_role_list[tag].lbl_role_name.node:setString(Language.WangChengZhengBa.NoPost)
			self.role_display_list[tag]:SetVisible(false)
		end
	end
end

-------------------------------
-- 刷新
function WangChengZhengBaGloryView:OnFlushRole()
	self:OnFlushRoleSBKOpenDate()
	self:OnFlushRoleDisplays()
	self:OnFlushGuildName()
end

function WangChengZhengBaGloryView:OnFlushRoleSBKOpenDate()
	local date_str = WangChengZhengBaData.GetNextOpenTimeDateStr()
	if not date_str then return end
	self.node_t_list.lbl_opening_time.node:setString(date_str)
end

function WangChengZhengBaGloryView:OnFlushRoleDisplays()
	-- local data = WangChengZhengBaData.Instance:GetSbkBaseMsg()
	-- 初始化为空
	for i = SOCIAL_MASK_DEF.GUILD_TANGZHU_FIR, SOCIAL_MASK_DEF.GUILD_LEADER do
		self:SetGloryRoleDisplay(i)
	end

	-- if data and data.guild_main_mb_list then
	-- 	for k,v in pairs(data.guild_main_mb_list) do
	-- 		if v.mb_state ~= 0 then
	-- 			if v.guild_position and v.vo then self:SetGloryRoleDisplay(v.guild_position, v.vo) end
	-- 		end
	-- 	end
	-- end
	for i = SOCIAL_MASK_DEF.GUILD_TANGZHU_FIR, SOCIAL_MASK_DEF.GUILD_LEADER do
		local vo = WangChengZhengBaData.Instance:GetSbkRoleVo(i)
		if vo then self:SetGloryRoleDisplay(i, vo) end
	end

end

function WangChengZhengBaGloryView:OnFlushGuildName()
	local data = WangChengZhengBaData.Instance:GetSbkBaseMsg()
	self.node_t_list.lbl_guild_name.node:setString(data and data.guild_name or "未占领")
end

return WangChengZhengBaGloryView