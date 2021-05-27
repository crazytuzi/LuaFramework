RotatePanelAwardResultWnd = RotatePanelAwardResultWnd or BaseClass(XuiBaseView)

function RotatePanelAwardResultWnd:__init(ok_func, ten_time_func, one_more_func, close_func, is_any_click_close)
	-- self.zorder = COMMON_CONSTS.PANEL_MAX_ZORDER
  	self.texture_path_list = {
  								'res/xui/explore.png',
  								'res/xui/strength_fb.png',
  							}
	self.config_tab = {
		{"itemtip_ui_cfg", 22, {0},},
	}
	self.is_async_load = false
	self.is_any_click_close = nil == is_any_click_close and true or is_any_click_close
	self.is_modal = true
	self.ten_time_func = ten_time_func
	self.one_more_func = one_more_func
	self.ok_func = ok_func
	self.close_func = close_func
	self.pos_x = HandleRenderUnit:GetWidth() / 2
	self.pos_y = HandleRenderUnit:GetHeight() / 2
	self.data = nil
	self.oper_type = 2
end

function RotatePanelAwardResultWnd:__delete()

end

function RotatePanelAwardResultWnd:ReleaseCallBack()
	if self.awards_show_list then 
		for k, v in pairs(self.awards_show_list) do
			v:DeleteMe()
		end
		self.awards_show_list = nil
	end

	self.data = nil
end

function RotatePanelAwardResultWnd:OpenCallBack()

end

function RotatePanelAwardResultWnd:CloseCallBack()
	self.oper_type = 2

end

function RotatePanelAwardResultWnd:ShowIndexCallBack()
	self:Flush()
	-- self.node_t_list.btn_close_window.node:setVisible(true)

	-- if self.is_no_closeBtn then
	-- 	self:NoCloseButton()
	-- end
end

function RotatePanelAwardResultWnd:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		-- self.node_t_list.jiesuan_yes_btn.node:addClickEventListener(BindTool.Bind1(self.OnClickOK, self))

		-- XUI.AddClickEventListener(self.node_t_list.jiesuan_more_btn.node, BindTool.Bind(self.OnClickMoreTenTime, self), true)
		-- XUI.AddClickEventListener(self.node_t_list.jiesuan_one_more_btn.node, BindTool.Bind(self.OnClickOneMoreTime, self), true)
		self:CreateAwardsList()
	end
	-- local screen_w = HandleRenderUnit:GetWidth()
	-- local screen_h = HandleRenderUnit:GetHeight()
	-- local pos_x, pos_y = self.root_node:getPosition()
	-- self.pos_x, self.pos_y = pos_x, pos_y
	-- self.root_node:setPosition(self.pos_x - 194, self.pos_y - 30)
	-- ClientCommonButtonDic[CommonButtonType.COMMON_ALERT_OK_BTN] = self.node_t_list.btn_OK.node
end

function RotatePanelAwardResultWnd:OnFlush()
	self:EmptyAwardsCellList()
	self:SetAwardsCellListData()
	-- self:SetOperBtnVis()
end

function RotatePanelAwardResultWnd:Open()
	XuiBaseView.Open(self)
	if self:IsOpen() then
		self:Flush()
	end
end

function RotatePanelAwardResultWnd:SetData(value)
	self.data = value
end

function RotatePanelAwardResultWnd:CreateAwardsList()
	if not self.awards_show_list then
		self.awards_show_list = {}
		for i = 1, 1 do
			local ph = self.ph_list["ph_award_cell" .. i]
			local cell = BaseCell.New()
			cell:GetView():setPosition(ph.x, ph.y)
			cell:GetView():setAnchorPoint(0.5, 0.5)
			self.node_t_list.layout_jiesuan_2.node:addChild(cell:GetView(), 100)
			self.awards_show_list[i] = cell
		end
	end
end

function RotatePanelAwardResultWnd:SetAwardsCellListData()
	if not self.data or not self.awards_show_list then return end
	for i, v in ipairs(self.data) do
		if self.awards_show_list[i] then
			self.awards_show_list[i]:SetData(v)
		end
	end
end

function RotatePanelAwardResultWnd:EmptyAwardsCellList()
	if self.awards_show_list then
		for k, v in ipairs(self.awards_show_list) do
			if v then
				v:SetData(nil)
			end
		end
	end
end

function RotatePanelAwardResultWnd:OnClickOK()
	-- local can_close = true
	-- if nil ~= self.ok_func then
	-- 	can_close = self.ok_func(self.is_nolonger_tips, self.data)
	-- 	if nil == can_close then can_close = true end
	-- end
	self:Close()
end

function RotatePanelAwardResultWnd:OnClickMoreTenTime()
	if self.ten_time_func then
		self.ten_time_func()
	end
end

function RotatePanelAwardResultWnd:OnClickOneMoreTime()
	if self.one_more_func then
		self.one_more_func()
	end
end

-- 设置确定回调
function RotatePanelAwardResultWnd:SetOkFunc(ok_func)
	self.ok_func = ok_func
end

-- 设置确定按钮文字
function Alert:SetOkBtnString(str)
	if nil ~= str and "" ~= str then
		self.ok_btn_text = str

		if nil ~= self.node_t_list.jiesuan_yes_btn then
			self.node_t_list.jiesuan_yes_btn.node:setTitleText(self.ok_btn_text)
		end
	end
end

-- 设置再来10次按钮文字
function Alert:SetMoreBtnString(str)
	if nil ~= str and "" ~= str then
		self.more_btn_text = str

		if nil ~= self.node_t_list.jiesuan_more_btn then
			self.node_t_list.jiesuan_more_btn.node:setTitleText(self.more_btn_text)
		end
	end
end

-- 设置再来10次回调
function RotatePanelAwardResultWnd:SetTenTimeFunc(ten_time_func)
	self.ten_time_func = ten_time_func
end

function RotatePanelAwardResultWnd:SetOneMoreTimeFunc(one_more_func)
	self.one_more_func = one_more_func
end

function RotatePanelAwardResultWnd:SetOperType(oper_type)
	self.oper_type = oper_type
end

function RotatePanelAwardResultWnd:SetOperBtnVis()
	if self.node_t_list.jiesuan_more_btn then
		self.node_t_list.jiesuan_more_btn.node:setVisible(self.oper_type > 1)
	end
	if self.node_t_list.jiesuan_one_more_btn then
		self.node_t_list.jiesuan_one_more_btn.node:setVisible(self.oper_type <= 1)
	end
end

function RotatePanelAwardResultWnd:SetWndPos(x, y)
	if x then
		self.pos_x = x
	end
	if y then
		self.pos_y = y
	end
	self.root_node:setPosition(self.pos_x, self.pos_y)
end
