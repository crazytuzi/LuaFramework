local OpenServiceAcitivityWangChengBaYeView = OpenServiceAcitivityWangChengBaYeView or BaseClass(SubView)

function OpenServiceAcitivityWangChengBaYeView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/openserviceacitivity.png'
	self.config_tab = {
		{"openserviceacitivity_ui_cfg", 3, {0}},
		{"openserviceacitivity_ui_cfg", 9, {0}},
	}
end

function OpenServiceAcitivityWangChengBaYeView:LoadCallBack()
	self:CreateAwardList()
	self.node_t_list.lbl_activity_time.node:setString(self.panel_info.activity_time_interval)
	RichTextUtil.ParseRichText(self.node_t_list.rich_tips.node, self.panel_info.tips, 19, COLOR3B.OLIVE)
end

function OpenServiceAcitivityWangChengBaYeView:ReleaseCallBack()
	if self.award_list then
		for k, v in pairs(self.award_list) do
			v:DeleteMe()
			v = {}
		end
		self.award_list = {}
	end
	self.panel_info = {}
end

function OpenServiceAcitivityWangChengBaYeView:ShowIndexCallBack()
	self.node_t_list.img_top_bg.node:loadTexture(ResPath.GetBigPainting("open_service_acitivity_bg1"))
end

function OpenServiceAcitivityWangChengBaYeView:CreateAwardList()
	self.panel_info = OpenServiceAcitivityData.Instance:GetWangChengBaYeInfo()
	if nil ~= self.award_list then return end
	local total_len = #self.panel_info.award_list * 77 + (#self.panel_info.award_list - 1) * 30
	local x, y = self.ph_list.ph_award.x - total_len / 2, self.ph_list.ph_award.y
	local x_interval = 107
	for k, v in pairs(self.panel_info.award_list) do
		local award_cell = BaseCell.New()
		self.node_t_list.layout_wangchengbaye.node:addChild(award_cell:GetView(), 99)
		award_cell:SetAnchorPoint(0, 0.5)
		award_cell:SetPosition(x, y)
		award_cell:SetData(v)
		x = x + x_interval
	end
end

return OpenServiceAcitivityWangChengBaYeView