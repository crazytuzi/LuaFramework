AlertMlutiButton = AlertMlutiButton or BaseClass(XuiBaseView)

function AlertMlutiButton:__init(str, ok_func, func_list, close_func, has_checkbox, is_show_action, is_any_click_close)
	self.zorder = COMMON_CONSTS.PANEL_MAX_ZORDER
  
	self.config_tab = {
		{"dialog_ui_cfg", 3, {0},},
	}
	self.is_async_load = false
	self.is_any_click_close = nil == is_any_click_close and true or is_any_click_close
	self.is_modal = true
	self.content_str = nil ~= str and str or ""
	self.func_list = func_list
	self.btn_str_list = {}
	self.data = nil

end

function AlertMlutiButton:__delete()

end

function AlertMlutiButton:OpenCallBack()
	self:SetBtnString(self.btn_str_list)
end

function AlertMlutiButton:LoadCallBack()
	self.is_modal = true
	
	self.rich_dialog_param = {}
	self.rich_dialog_param.x, self.rich_dialog_param.y = self.node_t_list.rich_dialog.node:getPosition()
	local size = self.node_t_list.rich_dialog.node:getContentSize()
	self.rich_dialog_param.w, self.rich_dialog_param.h = size.width, size.height
	self.node_t_list.rich_dialog.node:setVerticalAlignment(RichVAlignment.VA_CENTER)
	
	self:SetLableString(self.content_str)

	for i=1, 3 do	
		self.node_t_list["btn_" .. i].node:addClickEventListener(BindTool.Bind(self.OnClick, self, i))
	end
end

function AlertMlutiButton:OnClick(tag)
	local can_close = true
	if nil ~= self.func_list[tag] then
		TaskCtrl.SendNpcTalkReq(TaskCtrl.Instance.npc_obj_id, self.func_list[tag])
	end
	if can_close then
		self:Close()
	end
end

-- 设置内容
function AlertMlutiButton:SetLableString(str)
	if nil ~= str and "" ~= str then
		self.content_str = str

		if nil ~= self.node_t_list.rich_dialog then
			RichTextUtil.ParseRichText(self.node_t_list.rich_dialog.node, self.content_str, 24, COLOR3B.OLIVE)
			self.node_t_list.rich_dialog.node:refreshView()

			local text_renderer_size = self.node_t_list.rich_dialog.node:getInnerContainerSize()
			local text_x = self.rich_dialog_param.x + (self.rich_dialog_param.w - text_renderer_size.width) / 2
			local text_y = self.rich_dialog_param.y  - (self.rich_dialog_param.h - text_renderer_size.height) / 2
			self.node_t_list.rich_dialog.node:setPosition(text_x, text_y)
		end
	end
end

-- 设置确定按钮文字
function AlertMlutiButton:SetBtnString(str_list)
	if nil == str_list then return end
	self.btn_str_list = str_list
	for k,v in pairs(str_list) do
		if nil ~= v and "" ~= v then
			if nil ~= self.node_t_list["btn_" .. k] then
				self.node_t_list["btn_" .. k].node:setTitleText(v)
			end
		end
	end
end

-- 设置确定回调
function AlertMlutiButton:SetFuncList(func_list)
	self.func_list = func_list
end

function AlertMlutiButton:SetData(value)
	self.data = value
end


function AlertMlutiButton:OnCloseHandler()
	if self.close_before_func then
		self.close_before_func()
	else

		self:Close()
	end
end
