TransmitNpcDialogView = TransmitNpcDialogView or BaseClass(BaseView)

local VIEW_SIZE = cc.size(450, 550)
local npc_obj_id = 0
local title_height = 40
local btn_width, btn_height = VIEW_SIZE.width / 2, 53

function TransmitNpcDialogView:__init()
	self.texture_path_list[1] = 'res/xui/npc_dialog.png'
	self.root_node_off_pos = {x = -400, y = 0}
	self.config_tab = {
		{"common2_ui_cfg", 1, {0}},
	}
	
	self:SetIsAnyClickClose(true)
	
	self.scorll_view = nil
	self.title_list = {}
	self.btn_list = {}
	self.btnbg_list = {}
end

function TransmitNpcDialogView:__delete()
end

function TransmitNpcDialogView:LoadCallBack()
	self.scroll_view = XUI.CreateScrollView(225, 280, VIEW_SIZE.width, VIEW_SIZE.height, ScrollDir.Vertical)
	local top_title = XUI.CreateImageView(VIEW_SIZE.width / 2 + 10, VIEW_SIZE.height + 40, ResPath.GetWord("word_transmit"), nil)
	-- local bg = XUI.CreateImageView(0, 0, ResPath.GetBigPainting("transmit_bg", true), nil)
	-- local bg_size = bg:getContentSize()
	-- bg:setPosition(bg_size.width * 0.5 + 20, bg_size.height * 0.5 + 10)
	-- self.node_t_list.layout_board_bottom.node:addChild(bg, 100)
	self.node_t_list.layout_board_bottom.node:addChild(top_title, 100)
	self.node_t_list.layout_board_bottom.node:addChild(self.scroll_view, 150)
end

function TransmitNpcDialogView:ReleaseCallBack()
	self.title_list = {}
	self.btn_list = {}
	self.btnbg_list = {}
end

function TransmitNpcDialogView:ShowIndexCallBack()
	self:Flush()
end

function TransmitNpcDialogView:OnFlush(param_list, index)
	local view_data = ViewDef.TransmitNpcDialog.view_data
	if nil == view_data then
		return
	end

	npc_obj_id = view_data.obj_id

	for k, v in pairs(self.title_list) do
		v:SetVisible(false)
	end
	for k, v in pairs(self.btnbg_list) do
		v:setVisible(false)
	end
	for k, v in pairs(self.btn_list) do
		v:SetVisible(false)
	end
	
	local h_offset = 0
	local title, btn, btn_bg, btn_index = nil, nil, nil, 1

	for i, v in ipairs(view_data.area_list) do
		title = self:GetTitle(i)
		title:SetData(i)
		h_offset = h_offset + title_height
		title:SetPosition(0, VIEW_SIZE.height - h_offset)

		local off_h = (i == 2 and  #v.btn_list <= 16) and btn_height or 0
		-- btn_bg = self:GetBtnBg(i)
		-- btn_bg:setPosition(10, VIEW_SIZE.height - h_offset)
		-- btn_bg:setContentWH(VIEW_SIZE.width - 20, math.ceil(#v.btn_list / 4) * btn_height + 20 + off_h)

		h_offset = h_offset + 10
		for i2, v2 in ipairs(v.btn_list) do
			if i2 % 2 == 1 then
				h_offset = h_offset + btn_height
			end
			btn = self:GetBtn(btn_index)
			btn:IgnoreSceneLimit(i == #view_data.area_list)
			btn_index = btn_index + 1
			btn:SetData(v2)
			btn:SetPosition(btn_width * ((i2 - 1) % 2), VIEW_SIZE.height - h_offset)
		end
		h_offset = h_offset + off_h
		h_offset = h_offset + 10
	end
end

function TransmitNpcDialogView:GetTitle(index)
	if self.title_list[index] == nil then
		self.title_list[index] = TransmitNpcTitleRender.New()
		self.scroll_view:addChild(self.title_list[index]:GetView())
	end
	self.title_list[index]:SetVisible(true)
	return self.title_list[index]
end

-- function TransmitNpcDialogView:GetBtnBg(index)
-- 	if self.btnbg_list[index] == nil then
-- 		self.btnbg_list[index] = XUI.CreateImageViewScale9(0, 0, 100, 100, ResPath.GetBigPainting("transmit_bg_" .. index), false, cc.rect(5, 5, 942, 254))
-- 		self.btnbg_list[index]:setAnchorPoint(0, 1)
-- 		self.scroll_view:addChild(self.btnbg_list[index])
-- 	end
-- 	self.btnbg_list[index]:setVisible(true)
-- 	return self.btnbg_list[index]
-- end

function TransmitNpcDialogView:GetBtn(index)
	if self.btn_list[index] == nil then
		self.btn_list[index] = TransmitNpcBtnRender.New()
		self.scroll_view:addChild(self.btn_list[index]:GetView())
	end
	self.btn_list[index]:SetVisible(true)
	return self.btn_list[index]
end

function TransmitNpcDialogView:OnObjDelete(obj)
	if obj:GetObjId() == npc_obj_id then
		self:CloseHelper()
	end
end

------------------------------------------------------------------------
TransmitNpcTitleRender = TransmitNpcTitleRender or BaseClass(BaseRender)
function TransmitNpcTitleRender:__init()
	
end

function TransmitNpcTitleRender:__delete()

end

function TransmitNpcTitleRender:CreateChild()
	BaseRender.CreateChild(self)

	self.view:setContentWH(VIEW_SIZE.width, title_height)

	self.img_left_bg = XUI.CreateImageView(VIEW_SIZE.width / 2 + 10, title_height / 2, ResPath.GetCommon("orn_111"), true)
	self.view:addChild(self.img_left_bg)

	-- self.img_right_bg = XUI.CreateImageView(VIEW_SIZE.width / 2 + 100, title_height / 2, ResPath.GetCommon("orn_119"), true)
	-- self.view:addChild(self.img_right_bg)

	self.text_title = XUI.CreateImageView(VIEW_SIZE.width / 2+ 10, title_height / 2, ResPath.GetWord("word_transmit_1"), true)
	self.view:addChild(self.text_title)
end

function TransmitNpcTitleRender:OnFlush()
	self.text_title:loadTexture(ResPath.GetWord("word_transmit_" .. self.data))
end

------------------------------------------------------------------------
TransmitNpcBtnRender = TransmitNpcBtnRender or BaseClass(BaseRender)
local normal_scene, now_scene, risk_scene = 1, 2, 3
local color_list = {
	[normal_scene] = COLOR3B.DEEP_ORANGE,	-- 普通
	[now_scene] = COLOR3B.WHITE,		-- 当前场景
	[risk_scene] = COLOR3B.RED,			-- 等级不足
}

function TransmitNpcBtnRender:__init()
	self.ignore_scene_limit = false
end

function TransmitNpcBtnRender:__delete()
end

function TransmitNpcBtnRender:CreateChild()
	BaseRender.CreateChild(self)

	self.view:setContentWH(btn_width, btn_height)

	self.img_flag = XUI.CreateImageView(40, btn_height / 2, ResPath.GetCommon("orn_100"), true)
	self.view:addChild(self.img_flag)

	self.text_name = XUI.CreateText(60, btn_height / 2, 0, 0, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20, color_list[normal_scene], cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
	self.text_name:setAnchorPoint(0, 0.5)
	self.text_name:setUnderLine(true)
	self.view:addChild(self.text_name)

	XUI.AddClickEventListener(self.text_name, BindTool.Bind(self.OnClickName, self), false)

	self.text_level = XUI.CreateText(160, btn_height / 2, 0, 0, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20, COLOR3B.WHITE, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
	self.text_level:setAnchorPoint(0, 0.5)
	self.view:addChild(self.text_level)
end

function TransmitNpcBtnRender:OnFlush()
	self.text_level:setColor(COLOR3B.WHITE)
	if not self.ignore_scene_limit and self.data.scene_id == Scene.Instance:GetSceneId() then
		self.text_name:setColor(color_list[now_scene])
	else
		if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= self.data.level
			and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) >= self.data.circle then
			self.text_name:setColor(color_list[normal_scene])
		else
			self.text_name:setColor(color_list[risk_scene])
			self.text_level:setColor(color_list[risk_scene])
		end                                                     
	end
	self.text_name:setString(self.data.btn_name)

	if self.data.level > 0 then
		self.text_level:setString("(" .. self.data.level .. Language.Common.Ji .. ")")
	else
		self.text_level:setString("(" .. self.data.circle .. Language.Common.Zhuan .. ")")
	end
	self.text_level:setPositionX(62 + self.text_name:getContentSize().width)
end

function TransmitNpcBtnRender:IgnoreSceneLimit(value)
	self.ignore_scene_limit = value
end

function TransmitNpcBtnRender:OnClickName()
	if not self.ignore_scene_limit and self.data.scene_id == Scene.Instance:GetSceneId() then
		return
	end
	if 1 ~= self.data.type then
		ViewManager.Instance:OpenViewByStr(self.data.func_name)
	else
		TaskCtrl.SendNpcTalkReq(npc_obj_id, self.data.func_name)
	end
	ViewManager.Instance:CloseViewByDef(ViewDef.TransmitNpcDialog)
end
