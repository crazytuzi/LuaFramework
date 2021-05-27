local BackRecordView = BaseClass(SubView)

function BackRecordView:__init()
	self.texture_path_list = {
		--'res/xui/boss.png',
	}
    self.config_tab = {
		{"diamond_back_ui_cfg", 6, {0}},
	}
end

function BackRecordView:__delete()
end

function BackRecordView:ReleaseCallBack()
	if self.record_list then
		self.record_list:DeleteMe()
		self.record_list = nil
	end
end

function BackRecordView:LoadCallBack(index, loaded_times)
	self:BackRecordList()
	
	EventProxy.New(DiamondBackData.Instance, self):AddEventListener(DiamondBackData.BACK_RECORD, BindTool.Bind(self.OnBackRecord, self))
end

function BackRecordView:ShowIndexCallBack()
	self:Flush()
end

function BackRecordView:OnBackRecord()
	self:Flush()
end

function BackRecordView:BackRecordList()
	if nil == self.record_list then
		local ph = self.ph_list.ph_record_list
		self.record_list = ListView.New()
		self.record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BackRecordView.RecordRender, nil, nil, self.ph_list.ph_record_item)
		-- self.record_list:GetView():setAnchorPoint(0, 0)
		self.record_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_back_record.node:addChild(self.record_list:GetView(), 100)
	end			
end

function BackRecordView:OnFlush(param_t)
	self.record_list:SetDataList(DiamondBackData.Instance:GetBackRecordList())
end

BackRecordView.RecordRender = BaseClass(BaseRender)
local RecordRender = BackRecordView.RecordRender
function RecordRender:__init()	

end

function RecordRender:__delete()	
end

function RecordRender:CreateChild()
	BaseRender.CreateChild(self)
end

function RecordRender:OnFlush()
	if self.data == nil then return end

	self.node_tree.rec_desc.node:setString(self.data.equ_name)
	local back_time = os.date("*t", self.data.min_time)
	self.node_tree.rec_time.node:setString(back_time.year .. "-" .. back_time.month .. "-" .. back_time.day)
	self.node_tree.rec_player.node:setString(self.data.play_name)
	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
end

function RecordRender:CreateSelectEffect()
end

return BackRecordView