ActLingquAwardAlertView = ActLingquAwardAlertView or BaseClass(BaseView)

function ActLingquAwardAlertView:__init()
	self:SetModal(true)
	self.config_tab = {
		{"act_canbaoge_ui_cfg", 3, {0}},
	}
	self.def_index = 1
	self.itemconfig_change_callback = BindTool.Bind1(self.ItemConfigChangeCallback, self)	  --监听Config
	self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)           -- 监听物品数据变化、
end

function ActLingquAwardAlertView:__delete()
end

function ActLingquAwardAlertView:ReleaseCallBack()
	if self.cell_list then
		self.cell_list:DeleteMe()
		self.cell_list = nil
	end
end

function ActLingquAwardAlertView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCellList()
		self.node_t_list.btn_OK.node:addClickEventListener(BindTool.Bind1(self.OnClickOK, self))
		self.node_t_list.btn_cancel.node:addClickEventListener(BindTool.Bind1(self.OnClickCancel, self))
	end
end

function ActLingquAwardAlertView:OpenCallBack()
	ItemData.Instance:NotifyItemConfigCallBack(self.itemconfig_change_callback)
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActLingquAwardAlertView:CloseCallBack(is_all)
	ItemData.Instance:UnNotifyItemConfigCallBack(self.itemconfig_change_callback)
	ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActLingquAwardAlertView:ItemDataChangeCallback()
	self:Flush()
end

function ActLingquAwardAlertView:SetOkFunc(call_back)
	self.ok_func = call_back
end
function ActLingquAwardAlertView:OnClickOK()
	if self.ok_func then
		self.ok_func()
	end
end

function ActLingquAwardAlertView:OnClickCancel()
	self:Close()
end

function ActLingquAwardAlertView:CreateCellList()
	self.cell_list = ListView.New()
	self.cell_list:Create(20, 150, 500, 90, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_list:GetView():setAnchorPoint(0, 0)
	self.cell_list:SetItemsInterval(10)
	
	self.node_t_list.layout_award_alert.node:addChild(self.cell_list:GetView(), 300)
end

function ActLingquAwardAlertView:ItemConfigChangeCallback()
	self:Flush()
end

function ActLingquAwardAlertView:OnFlush(param_t, index)
	RichTextUtil.ParseRichText(self.node_t_list.rich_dialog.node, param_t.all.desc, 22)
	self.cell_list:SetDataList(param_t.all.item_list)
end
