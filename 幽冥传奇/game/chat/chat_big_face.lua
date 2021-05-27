ChatBigFaceView = ChatBigFaceView or BaseClass(XuiBaseView)

function ChatBigFaceView:__init()
	self.ctrl = ChatCtrl.Instance
	self.is_modal = true
	self.is_any_click_close = true
	self:LoadConfig()
	-- UiAction.SetScaleShowAction(self)

	self.big_chat_face_num = 14
end

function ChatBigFaceView:delete()
	
end

function ChatBigFaceView:LoadConfig()
	self.texture_path_list[1] = "res/xui/face.png"
	self.config_tab = {{"chat_ui_cfg", 5, {0}}}
end

function ChatBigFaceView:LoadCallBack()
	self:InitBigFace()
	self:RegisterFaceEvent()
end

function ChatBigFaceView:InitBigFace()
	local bg_x, bg_y = self.node_t_list.img9_autoname_2.node:getPosition()
	local bg_size = self.node_t_list.img9_autoname_2.node:getContentSize()

	local face_layout = XUI.CreateLayout(bg_x, bg_y, bg_size.width - 8, bg_size.height - 8)
	self.node_t_list.layout_face.node:addChild(face_layout, 100, 100)

	local draw_node = cc.DrawNode:create()
	face_layout:addChild(draw_node)

	local layout_size = face_layout:getContentSize()
	local color_4f = cc.c4f(0.0664, 0.293, 0.523, 0.8)

	local row, col = 3, 5
	local avg_w, avg_h = layout_size.width / col, layout_size.height / row

	-- 网格线
	for i = 1, row - 1 do
		draw_node:drawSegment(cc.p(0, avg_h * i), cc.p(layout_size.width , avg_h * i), 1, color_4f)
	end
	for i = 1, col - 1 do
		draw_node:drawSegment(cc.p(avg_w * i, 0), cc.p(avg_w * i, layout_size.height), 1, color_4f)
	end

	-- 在对应的格子创建表情按钮
	local index = 0
	local face_res_id = 100
	for i = 1, row do
		for j = 1, col do
			if face_res_id >= 100 + self.big_chat_face_num then return end

			index = (i - 1) * col + j + 49
			local x, y = j * avg_w - avg_w / 2, (row - i) * avg_h + avg_h / 2
			local anim_path, anim_name = ResPath.GetFaceEffectAnimPath(face_res_id)

			local sprite = RenderUnit.CreateAnimSprite(anim_path, anim_name, 0.15, 20)
			sprite:setPosition(x, y)

			face_layout:addChild(sprite, 100, 1)

			local btn = XUI.CreateButton(x, y, 70, 65, true, "", "", "", true)
			face_layout:addChild(btn, 10, 1)
			XUI.AddClickEventListener(btn, BindTool.Bind2(self.OnClickBigFace, self, index))

			face_res_id = face_res_id + 1
		end
	end
end

function ChatBigFaceView:RegisterFaceEvent()
	XUI.AddClickEventListener(self.node_t_list.btn_close_face.node, BindTool.Bind1(self.Close, self))
end

function ChatBigFaceView:OnClickBigFace(index)
	-- if not ExpressionData.Instance:GetActiveStatus() then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Expression.NotActive)
	-- 	return
	-- end

	-- local face_id = string.format("%02d", index)
	-- local edit_text = self.ctrl:GetEditTextByCurPanel()
	-- if edit_text and ChatData.ExamineEditText(edit_text:getText(), 3) then
	-- 	edit_text:setText(edit_text:getText() .. "/" .. face_id)
	-- 	ChatData.Instance:InsertFaceTab(face_id)
	-- end
end