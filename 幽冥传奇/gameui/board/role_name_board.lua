
RoleNameBoard = RoleNameBoard or BaseClass(NameBoard)

RoleNameBoard.shift_y = 30

function RoleNameBoard:__init()
	self.partner_name_text_rich = XUI.CreateRichText(0, RoleNameBoard.shift_y, 200, 24)
	XUI.RichTextSetCenter(self.partner_name_text_rich)
	self.root_node:addChild(self.partner_name_text_rich, -2)

	self.guild_name_text_rich = XUI.CreateRichText(0, RoleNameBoard.shift_y * 2, 200, 24)
	XUI.RichTextSetCenter(self.guild_name_text_rich)
	self.root_node:addChild(self.guild_name_text_rich, -1)

	self.office_name_text_rich = XUI.CreateRichText(0, RoleNameBoard.shift_y * 3, 200, 24)
	XUI.RichTextSetCenter(self.office_name_text_rich)
	self.root_node:addChild(self.office_name_text_rich,2)

	self.office_name_img = XUI.CreateImageView(0, RoleNameBoard.shift_y * 3, "")
	self.root_node:addChild(self.office_name_img, 2)

	self.is_simple = false

	self.c_x = 0
	self.c_y = 0
	self.roll_effect_t = {}
end

function RoleNameBoard:__delete()
	self.roll_effect_t = {}
	Runner.Instance:RemoveRunObj(self)
end

function RoleNameBoard:SetRole(role_vo, logic_pos_x, logic_pos_y)
	self.role_vo = role_vo
	local name_list, special_list = Scene.Instance:GetSceneLogic():GetRoleNameBoardText(role_vo)
	if GlobalData.is_show_role_pos and logic_pos_x and logic_pos_y then
		local text = string.format("(%d, %d)", logic_pos_x, logic_pos_y)
		table.insert(name_list, {text = text, color = COLOR3B.WHITE})
	end
	self:SetNameList(name_list)
	self:SetRollEffect(special_list)
	if not self.is_simple then
		self:SetPartnerNameList(Scene.Instance:GetSceneLogic():GetPartnerNameBoardText(role_vo))
		self:SetGuildNameList(Scene.Instance:GetSceneLogic():GetGuildNameBoardText(role_vo))
		-- self:SetOfficeName(Scene.Instance:GetSceneLogic():GetOfficeNameText(role_vo))
		self:SetOfficeImg(role_vo)
		-- local office_h = "" == role_vo.guild_name and 24 or 48
		-- self.office_name_text_rich:setPositionY(office_h)
		self:CheckNameBoardsPosY(role_vo)
	else
		self:SetGuildNameList()
		self:SetOfficeName()
		self:SetOfficeImg()
	end
end

function RoleNameBoard:CheckNameBoardsPosY(role_vo)
	local office_h = RoleNameBoard.shift_y
	local guild_h = RoleNameBoard.shift_y
	if role_vo.partner_name and role_vo.partner_name ~= "" then
		office_h = office_h + RoleNameBoard.shift_y
		guild_h = guild_h + RoleNameBoard.shift_y
	end
	if role_vo.guild_name and role_vo.guild_name ~= "" then
		office_h = office_h + RoleNameBoard.shift_y
	end

	self.office_name_text_rich:setPositionY(office_h)
	self.office_name_img:setPositionY(office_h+3)
	self.guild_name_text_rich:setPositionY(guild_h)
end

function RoleNameBoard:SetGuildNameList(name_list)
	self.guild_name_text_rich:removeAllElements()
	if nil ~= name_list then
		local is_gc, gc_color = WangChengZhengBaData.Instance:GetIsChangeNameColor(), WangChengZhengBaData.GetGCNameColor(self.role_vo)
		for i, v in ipairs(name_list) do
			XUI.RichTextAddText(self.guild_name_text_rich, v.text, COMMON_CONSTS.FONT, NameBoard.FontSize, is_gc and gc_color or v.color, 255, nil, 1)
		end
	end
end

function RoleNameBoard:SetOfficeName(name_list)
	self.office_name_text_rich:removeAllElements()
	if nil ~= name_list then
		local is_gc, gc_color = WangChengZhengBaData.Instance:GetIsChangeNameColor(), WangChengZhengBaData.GetGCNameColor(self.role_vo)
		for i, v in ipairs(name_list) do
			XUI.RichTextAddText(self.office_name_text_rich, v.text, COMMON_CONSTS.FONT, NameBoard.FontSize, is_gc and gc_color or v.color, 255, nil, 1)
		end
	end
end

function RoleNameBoard:SetOfficeImg(vo)
	if nil ~= vo then
		local val = vo[OBJ_ATTR.ACTOR_WARPATH_ID] or 0
		local office_level = bit:_and(bit:_rshift(val, 16), 0xffff)
		local fs_lv = math.min((office_level - 1 - (office_level - 1) % 11) / 11 + 1, 20) 
		if fs_lv > 0 then
			self.office_name_img:loadTexture(ResPath.GetScene("map_name_" .. fs_lv))
		end
	end
end

function RoleNameBoard:SetPartnerNameList(name_list)
	self.partner_name_text_rich:removeAllElements()
	if nil ~= name_list then
		local is_gc, gc_color = WangChengZhengBaData.Instance:GetIsChangeNameColor(), WangChengZhengBaData.GetGCNameColor(self.role_vo)
		for i, v in ipairs(name_list) do
			XUI.RichTextAddText(self.partner_name_text_rich, v.text, COMMON_CONSTS.FONT, NameBoard.FontSize, is_gc and gc_color or v.color, 255, nil, 1)
		end
	end
end

function RoleNameBoard:SetIsSimple(is_simple)
	if self.is_simple == is_simple then return end
	self.is_simple = is_simple
	if self.role_vo then
		self:SetRole(self.role_vo)
	end
end

function RoleNameBoard:SetRollCenter()
	self.name_text_rich:refreshView()
	local width = self.name_text_rich:getInnerContainerSize().width
	if width > 0 then
		self.c_x = - width * 0.5 - 35
		self.c_y = 2
	end
end

function RoleNameBoard:SetRollEffect(effect_lsit)
	if effect_lsit == nil then
		return
	end

	local num = #effect_lsit
	if num >= 2 then
		self:SetRollCenter()
		
		local create_t = {}

		for k, v in pairs(self.roll_effect_t) do
			v.should_del = true
		end

		for k, v in pairs(effect_lsit) do
			if v.key then
				local is_new = true
				for key, value in pairs(self.roll_effect_t) do
					if value.key == v.key then
						is_new = false
						value.should_del = false
					end
				end
				if is_new == true then
					-- 没有此effect,加入创建列表
					create_t[#create_t + 1] = v
				end
			end
		end

		local had_del = false
		-- 移除多余的effect
		for k, v in pairs(self.roll_effect_t) do
			if v.should_del == true then
				had_del = true
				v.node:removeFromParent()
				table.remove(self.roll_effect_t, k)
			end
		end

		-- 有新增effect或者删除过effect,才更新
		if #create_t > 0 or had_del == true then
			for k, v in pairs(create_t) do
				local empty_node = nil
				if v.effect_id then
					local anim_path, anim_name = v.path_func(v.effect_id)
					local eff = RenderUnit.CreateAnimSprite(anim_path, anim_name, 0.15, 20, nil)
					empty_node = cc.Node:create()
					empty_node:setContentSize(0, 0)
					empty_node:addChild(eff)
				elseif v.img_path then
					local img = XUI.CreateImageView(0, 0, v.img_path, true)
					empty_node = cc.Node:create()
					empty_node:setContentSize(0, 0)
					empty_node:addChild(img)
				elseif v.text then
					local rich = XUI.CreateRichText(0, 0, 100, 22, true)
					rich:setHorizontalAlignment(RichHAlignment.HA_CENTER)
					RichTextUtil.ParseRichText(rich, v.text)
					empty_node = cc.Node:create()
					empty_node:setContentSize(0, 0)
					empty_node:addChild(rich)
				end
				if empty_node ~= nil then
					self.root_node:addChild(empty_node, -1)
					self.roll_effect_t[#self.roll_effect_t + 1] = {angle = 0, node = empty_node, key = v.key}
				end
			end

			-- 更新位置
			local angle = self.roll_effect_t[1].angle
			local len = #self.roll_effect_t
			for k, v in ipairs(self.roll_effect_t) do
				v.angle = angle
				angle = angle + (360 / len)
			end

			Runner.Instance:AddRunObj(self, 10)
		end
	else
		self:ClearRollEffect()
	end
end

function RoleNameBoard:ClearRollEffect()
	for k, v in pairs(self.roll_effect_t) do
		v.node:removeFromParent()
	end
	self.roll_effect_t = {}
	Runner.Instance:RemoveRunObj(self)
end

function RoleNameBoard:Update(now_time, elapse_time)
	for k, v in pairs(self.roll_effect_t) do
		self:RollEffect(v)
	end
end

function RoleNameBoard:RollEffect(data)
	local r = 18
	local pi = 3.14
	local angle_interval = 2

	data.angle = (data.angle + angle_interval) % 360
	x = self.c_x + math.sin(data.angle / 180 * pi) * r
	y = self.c_y - math.cos(data.angle / 180 * pi) * r

	data.node:setPosition(x, y)
end
