
ChatPrivateObjItem = ChatPrivateObjItem or BaseClass(BaseRender)
ChatPrivateObjItem.DEF_H = 100

function ChatPrivateObjItem:__init(w)
	self.render_w = w
	self.view:setContentWH(self.render_w, ChatPrivateObjItem.DEF_H)

	self.role_head = nil
end

function ChatPrivateObjItem:__delete()
	if nil ~= self.role_head then
		self.role_head:DeleteMe()
		self.role_head = nil
	end
end

function ChatPrivateObjItem:CreateChild()
	BaseRender.CreateChild(self)

	local img_bg = XUI.CreateImageViewScale9(self.render_w / 2, ChatPrivateObjItem.DEF_H / 2, self.render_w, ChatPrivateObjItem.DEF_H,
		ResPath.GetCommon("img9_102"), true)
	self.view:addChild(img_bg, -1, -1)

	-- Í·Ïñ
	self.role_head = RoleHeadCell.New()
	self.role_head:SetPosition(46, ChatPrivateObjItem.DEF_H / 2)
	self.role_head:AddClickEventListener()
	self.role_head:RemoveItems(Language.Menu.PrivateChat)
	self.view:addChild(self.role_head:GetView())

	self.label_name = XUI.CreateText(92, ChatPrivateObjItem.DEF_H / 2 + 3, 150, 22, cc.TEXT_ALIGNMENT_LEFT, "", COMMON_CONSTS.FONT, 22)
	self.label_name:setAnchorPoint(0, 0)
	self.view:addChild(self.label_name)

	self.label_lv = XUI.CreateText(92, ChatPrivateObjItem.DEF_H / 2 - 7, 150, 22, cc.TEXT_ALIGNMENT_LEFT, "", COMMON_CONSTS.FONT, 22 ,cc.c3b(255,255,0))
	self.label_lv:setAnchorPoint(0, 1)
	self.view:addChild(self.label_lv)

	self.num_bg = XUI.CreateImageView(self.render_w - 16, ChatPrivateObjItem.DEF_H - 15, ResPath.GetCommon("remind_bg"), true)
	self.view:addChild(self.num_bg, 100, 100)

	self.label_unread = XUI.CreateText(self.render_w - 16, ChatPrivateObjItem.DEF_H - 15, 20, 20, 
		cc.TEXT_ALIGNMENT_CENTER, "", COMMON_CONSTS.FONT, 18)
	self.view:addChild(self.label_unread, 101, 101)
end

function ChatPrivateObjItem:OnFlush()
	local sex_color_cfg = SEX_COLOR[self.data.sex] or SEX_COLOR[1]
	self.label_name:setString(self.data.username)
	self.label_name:setColor(sex_color_cfg[3])

	self.label_lv:setString(RoleData.GetLevelString(self.data.level))

	self.role_head:SetRoleInfo(self.data.role_id, self.data.username, self.data.prof, true)

	local is_visible = self.data.unread_num > 0
	self.num_bg:setVisible(is_visible)
	self.label_unread:setVisible(is_visible)
	self.label_unread:setString(tostring(self.data.unread_num))
end
