ChatFaceView = ChatFaceView or BaseClass(XuiBaseView)

function ChatFaceView:__init()
	self.ctrl = ChatCtrl.Instance
	
	-- self.is_modal = true
	self:SetRootNodeOffPos({x = 40, y = -46})
	self:SetIsAnyClickClose(true)
	self.def_index = 1
	self:LoadConfig()
end

function ChatFaceView:LoadConfig()
	self.texture_path_list[1] = 'res/xui/chat.png'
	self.texture_path_list[2] = 'res/xui/face.png'
	self.config_tab = {{"chat_ui_cfg", 3, {0}}}
end

function ChatFaceView:ReleaseCallBack()
	self.face_scrollview = nil
	self.big_face_scrollview = nil
end
function ChatFaceView:LoadCallBack(index, loaded_times)
	if index == 1 then
		self:InitFace()
	elseif index == 2 then
		-- self:InitBigFace()
	end
	if loaded_times <= 1 then
		self:RegisterFaceEvent()
	end
end

function ChatFaceView:InitFace()
	local bg_x, bg_y = self.node_t_list.img9_face_bg.node:getPosition()
	local bg_size = self.node_t_list.img9_face_bg.node:getContentSize()

	self.face_scrollview = XUI.CreateScrollView(bg_x+20, bg_y, bg_size.width - 60, bg_size.height - 8, ScrollDir.Horizontal)
	self.node_t_list.layout_face.node:addChild(self.face_scrollview, 100, 100)

	local draw_node = cc.DrawNode:create()
	self.face_scrollview:addChild(draw_node)

	local layout_size = self.face_scrollview:getContentSize()
	local color_4f = cc.c4f(0.404, 0.368, 0.294, 0.5)

	local page, row, col = 2, 4, 7
	self.face_scrollview:setInnerContainerSize(cc.size((bg_size.width - 120) * page, bg_size.height - 8))
	local layout_size = self.face_scrollview:getInnerContainerSize()
	local avg_w, avg_h = layout_size.width / col / page, layout_size.height / row

	-- 网格线
	for i = 1, row - 1 do
		draw_node:drawSegment(cc.p(5, avg_h * i), cc.p(layout_size.width, avg_h * i), 1, color_4f)
	end
	for i = 1, col * page do
		draw_node:drawSegment(cc.p(avg_w * i, 0), cc.p(avg_w * i, layout_size.height), 1, color_4f)
	end

	-- 在对应的格子创建表情按钮
	local index = 0
	for p = 1, page do
		for i = 1, row do
			for j = 1, col do
				index = (i - 1) * col + j + (p - 1) * row * col
				if index > 32 then return end
				local x, y = j * avg_w - avg_w / 2 + (p -1) * avg_w * col, (row - i) * avg_h + avg_h / 2
				local btn_face = XUI.CreateButton(x, y, 0, 0, false, ResPath.GetFace(index), "", "", true)
				if nil ~= btn_face then
					btn_face:setScale(1.2)
					XUI.AddClickEventListener(btn_face, BindTool.Bind2(self.OnClickFace, self, index))
					self.face_scrollview:addChild(btn_face, 1, 1)
				end
			end
		end
	end
end	

function ChatFaceView:InitBigFace()
	local bg_x, bg_y = self.node_t_list.img9_face_bg.node:getPosition()
	local bg_size = self.node_t_list.img9_face_bg.node:getContentSize()

	self.big_face_scrollview = XUI.CreateScrollView(bg_x - 60, bg_y, bg_size.width - 120, bg_size.height - 8, ScrollDir.Horizontal)
	self.node_t_list.layout_face.node:addChild(self.big_face_scrollview, 100, 100)

	local draw_node = cc.DrawNode:create()
	self.big_face_scrollview:addChild(draw_node)

	local color_4f = cc.c4f(0.404, 0.368, 0.294, 0.5)

	local page, row, col = 2, 4, 7
	self.big_face_scrollview:setInnerContainerSize(cc.size((bg_size.width - 120) * page, bg_size.height - 8))
	local layout_size = self.big_face_scrollview:getInnerContainerSize()
	local avg_w, avg_h = layout_size.width / col / page, layout_size.height / row

	-- 网格线
	for i = 1, row - 1 do
		draw_node:drawSegment(cc.p(5, avg_h * i), cc.p(layout_size.width, avg_h * i), 1, color_4f)
	end
	for i = 1, col * page do
		draw_node:drawSegment(cc.p(avg_w * i, 0), cc.p(avg_w * i, layout_size.height), 1, color_4f)
	end

	-- 在对应的格子创建表情按钮
	local index = 0
	local face_res_id = 10--COMMON_CONSTS.BIGCHATFACE_ID_FIRST

	for p = 1, page do
		for i = 1, row do
			for j = 1, col do
				if face_res_id > 20 then return end

				index = (i - 1) * col + j + (p -1) * row * col
				local x, y = j * avg_w - avg_w / 2 + (p -1) * avg_w * col, (row - i) * avg_h + avg_h / 2
				local anim_path, anim_name = ResPath.GetFaceEffectAnimPath(face_res_id)

				local sprite = RenderUnit.CreateAnimSprite(anim_path, anim_name, 0.15, 20)
				sprite:setPosition(x, y)

				self.big_face_scrollview:addChild(sprite, 100, 1)

				local btn = XUI.CreateButton(x, y, 70, 65, true, "", "", "", true)
				self.big_face_scrollview:addChild(btn, 10, 1)
				XUI.AddClickEventListener(btn, BindTool.Bind2(self.OnClickBigFace, self, face_res_id))

				face_res_id = face_res_id + 1
			end
		end
	end
end

function ChatFaceView:RegisterFaceEvent()
	XUI.AddClickEventListener(self.node_t_list.btn_chat_face_tab2.node, BindTool.Bind2(self.ChangeToIndex, self, 1))
	-- XUI.AddClickEventListener(self.node_t_list.btn_chat_face_tab1.node, BindTool.Bind2(self.ChangeToIndex, self, 2))
	self.node_t_list.btn_chat_face_tab1.node:setVisible(false)
	self.node_t_list.btn_chat_face_tab2.node:setTitleText("免\n费")
end

function ChatFaceView:ShowIndexCallBack(index)
	if self.face_scrollview then
		self.face_scrollview:setVisible(index == 1)
	end
	if self.big_face_scrollview then
		self.big_face_scrollview:setVisible(index == 2)
	end
end

function ChatFaceView:OnClickFace(index)
	local face_id = string.format("%02d", index)
	local edit_text = self.edit_text or self.ctrl:GetEditTextByCurPanel()
	if edit_text and ChatData.ExamineEditText(edit_text:getText(), 3) then
		edit_text:setText(edit_text:getText() .. "/" .. face_id)
		ChatData.Instance:InsertFaceTab(face_id)
	end
end

function ChatFaceView:SetPosition(x, y)
	if nil ~= self.root_node then
		self.root_node:setPosition(x, y)
	end
end

function ChatFaceView:SetEditOpen(edit_text)
	self.edit_text = edit_text
	self:Open()
end

function ChatFaceView:CloseCallBack()
	self.edit_text = nil
end