-- 国家战事（刺探刷新颜色界面）
CiTanCompleteView = CiTanCompleteView or BaseClass(BaseView)

function CiTanCompleteView:__init()
	self.ui_config = {"uis/views/nationalwarfareview", "CiTanComplete"}
	self:SetMaskBg()
	self.item_cell = {}
	self.animation_lists = {}
	self.img_obj_list = {}
	self.citan_list = {}

	self.max_reward = 5 --最高的奖励
end

function CiTanCompleteView:__delete()

end

function CiTanCompleteView:ReleaseCallBack()
	self.residue_number = nil
	self.word_qingbao = nil

	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end

	self.item_cell = {}
	self.animation_lists = {}
	self.img_obj_list = {}
end

function CiTanCompleteView:LoadCallBack()
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

function CiTanCompleteView:OnExplain()
	TipsCtrl.Instance:ShowHelpTipView(181)
end

function CiTanCompleteView:CloseCallBack()
	if self.citan_list.cur_qingbao_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and
		self.citan_list.get_qingbao_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID then
		self.word_qingbao:SetActive(true)
		local pos
		if self.citan_list.cur_qingbao_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID then
			pos = self.img_obj_list[self.citan_list.cur_qingbao_color].transform.localPosition
		else
			pos = self.img_obj_list[self.citan_list.get_qingbao_color].transform.localPosition
		end
		self.word_qingbao.transform.localPosition = Vector3(pos.x, pos.y + 60, pos.z)
	end
end

function CiTanCompleteView:OpenCallBack()
	self:Flush()
end

-- 关闭事件
function CiTanCompleteView:HandleClose()
	ViewManager.Instance:Close(ViewName.CiTanCompleteView)
end

-- 提交任务
function CiTanCompleteView:OnFinishTask()
	CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_COMMIT_TASK, CAMP_TASK_TYPE.CAMP_TASK_TYPE_CITAN)
	self:HandleClose()
end

function CiTanCompleteView:OnFlush(param_t)
	self.citan_list = NationalWarfareData.Instance:GetCampCitanStatus()
	local citan_day_count = NationalWarfareData.Instance:GetCampCitanDayCount()
	local color_cfg = NationalWarfareData.Instance:GetRewardList(self.citan_list.get_qingbao_color, CAMP_TASK_TYPE.CAMP_TASK_TYPE_CITAN,self.citan_list.is_lower_reward)

	local color = self.citan_list.cur_qingbao_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
					self.citan_list.cur_qingbao_color or self.citan_list.get_qingbao_color
	local pos = self.img_obj_list[color].transform.localPosition
	self.word_qingbao.transform.localPosition = Vector3(pos.x, pos.y + 60, pos.z)
	self.animation_lists[color]:SetValue(true)
	self.word_qingbao:SetActive(true)
	
	for k,v in pairs(color_cfg) do
		self.item_cell[k]:SetData(v)
	end	
end