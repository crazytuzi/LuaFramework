
DrawRecordView = DrawRecordView or BaseClass(BaseView)

function DrawRecordView:__init()
	self:SetModal(true)
	self.config_tab = {
		{"openserviceacitivity_ui_cfg", 11, {0}},
	}
	self:SetIsAnyClickClose(true)
end

function DrawRecordView:__delete()
end

function DrawRecordView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DrawRecordView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DrawRecordView:ReleaseCallBack()
end

function DrawRecordView:LoadCallBack(index, loaded_times)
	EventProxy.New(OpenServiceAcitivityData.Instance, self):AddEventListener(OpenServiceAcitivityData.DrawRecordLogCharge, BindTool.Bind(self.OnFlushLogList, self))
	self:CreateLogList()
end

function DrawRecordView:CreateLogList()
	local ph = self.ph_list.ph_log_list
	self.draw_record_list = ListView.New()
	self.draw_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, DrawRecordItemRender, nil, nil, self.ph_list.ph_log_item)
	self.draw_record_list:GetView():setAnchorPoint(0, 0)
	self.node_t_list.layout_draw_record.node:addChild(self.draw_record_list:GetView(), 100)
	self.draw_record_list:SetItemsInterval(1)
	self.draw_record_list:SetJumpDirection(ListView.Top)
end

function DrawRecordView:ShowIndexCallBack(index)

end

function DrawRecordView:OnFlushLogList()
	local log_list = OpenServiceAcitivityData.Instance:GetDrawServerRecording()
	self.draw_record_list:SetDataList(log_list)
end

DrawRecordItemRender = DrawRecordItemRender or BaseClass(BaseRender)

function DrawRecordItemRender:__init()
end

function DrawRecordItemRender:__delete()
end

function DrawRecordItemRender:CreateChild()
	DrawRecordItemRender.super.CreateChild(self)
	-- XUI.AddClickEventListener(self.node_tree.lbl_prize.node, BindTool.Bind(self.OnClickPrize, self), true)
end

function DrawRecordItemRender:OnFlush()
	if nil == self.data then
		return
	end
	local item_name = ItemData.Instance:GetItemName(self.data.item_id)
	local item_color = ItemData.Instance:GetItemColor(self.data.item_id)
	self.node_tree.lbl_name.node:setString(self.data.player_name)
	self.node_tree.lbl_prize.node:setColor(item_color)
	self.node_tree.lbl_prize.node:setString(item_name)
end

-- 创建选中特效
function DrawRecordItemRender:CreateSelectEffect()
end

-- function DrawRecordItemRender:OnClickPrize()
-- 	TipCtrl.Instance:OpenItem({item_id = self.data.item_id, num = 1, is_bind = 1}, EquipTip.FROM_NORMAL)
-- end
