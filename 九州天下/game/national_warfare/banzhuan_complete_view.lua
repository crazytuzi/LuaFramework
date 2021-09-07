-- 国家战事（搬砖刷新颜色界面）
BanZhuanCompleteView = BanZhuanCompleteView or BaseClass(BaseView)

function BanZhuanCompleteView:__init()
	self.ui_config = {"uis/views/nationalwarfareview", "BanZhuanComplete"}
	self:SetMaskBg()
	self.item_cell = {}
	self.animation_lists = {}
	self.banzhuan_list = {}
	self.img_obj_list = {}

	self.max_reward = 5 --最高的奖励
end

function BanZhuanCompleteView:__delete()

end

function BanZhuanCompleteView:ReleaseCallBack()
	self.residue_number = nil
	self.word_qingbao = nil

	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end

	self.item_cell = {}
	self.animation_lists = {}
	self.img_obj_list = {}
end

function BanZhuanCompleteView:LoadCallBack()
	self.residue_number = self:FindVariable("ResidueNumber")
	self.word_qingbao = self:FindObj("WordObj")

	self.key = 0
	self.last_refresh_time = 0

	for i = 1, 3 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		item:SetData(nil)
		table.insert(self.item_cell, item)
	end

	for i = 1, 5 do
		self.animation_lists[i] = self:FindVariable("light_" .. i)
		self.img_obj_list[i] = self:FindObj("image" .. i)
	end

	self:ListenEvent("OnClose", BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("FinishTask", BindTool.Bind(self.OnFinishTask, self))
	self:ListenEvent("Explain", BindTool.Bind(self.OnExplain, self))
	-- self:ListenEvent("AddResidue", BindTool.Bind(self.AddBanZhuanResidue, self))
end

function BanZhuanCompleteView:OnExplain()
	TipsCtrl.Instance:ShowHelpTipView(182)
end

function BanZhuanCompleteView:CloseCallBack()
	if self.banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and
		self.banzhuan_list.get_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID then
		self.word_qingbao:SetActive(true)
		local pos
		if self.banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID then
			pos = self.img_obj_list[self.banzhuan_list.cur_color].transform.localPosition
		else
			pos = self.img_obj_list[self.banzhuan_list.get_color].transform.localPosition
		end
		self.word_qingbao.transform.localPosition = Vector3(pos.x, pos.y + 60, pos.z)
	end
end

function BanZhuanCompleteView:OpenCallBack()
	self:Flush()
end

-- 关闭事件
function BanZhuanCompleteView:HandleClose()
	ViewManager.Instance:Close(ViewName.BanZhuanCompleteView)
end

-- 提交任务
function BanZhuanCompleteView:OnFinishTask()
	CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_COMMIT_TASK, CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN)
	self:HandleClose()
end

function BanZhuanCompleteView:OnFlush(param_t)
	self.banzhuan_list = NationalWarfareData.Instance:GetCampBanzhuanStatus()
	local citan_day_count = NationalWarfareData.Instance:GetCampBanzhuanDayCount()
	local color_cfg = NationalWarfareData.Instance:GetRewardList(self.banzhuan_list.get_color, CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN,self.banzhuan_list.is_lower_reward)
	
	local color = self.banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
							self.banzhuan_list.cur_color or self.banzhuan_list.get_color
	local pos = self.img_obj_list[color].transform.localPosition
	self.word_qingbao.transform.localPosition = Vector3(pos.x, pos.y + 60, pos.z)
	self.animation_lists[color]:SetValue(true)
	self.word_qingbao:SetActive(true)

	for k,v in pairs(color_cfg) do
		self.item_cell[k]:SetData(v)
	end
end