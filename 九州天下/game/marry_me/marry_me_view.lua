MarryMeView = MarryMeView or BaseClass(BaseView)

function MarryMeView:__init()
	self.ui_config = {"uis/views/marryme","MarryMeView"}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self:SetMaskBg()
end

function MarryMeView:__delete()

end

function MarryMeView:LoadCallBack()
	self:ListenEvent("OnClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickMarry", BindTool.Bind(self.OnClickMarry, self))

	-- self.item_cell = ItemCell.New(self:FindObj("ItemCell"))

	self.rest_time = self:FindVariable("RestTime")
	self.day = self:FindVariable("Day")
	self.hour = self:FindVariable("Hour")
	self.minute = self:FindVariable("Minute")
	self.title = self:FindVariable("Title")
	self.fp = self:FindVariable("Fp")
	self.number = self:FindVariable("Number")

	-- self.scroller = self:FindObj("Scroller")
	-- self.cell_list = {}
	-- self:InitScroller()

	local config = KaifuActivityData.Instance:GetMarryMeCfg()[1]
	if config then
		-- self.item_cell:SetData(config.reward_item)
		self.number:SetValue(config.couple_count)
		local title_id = config.title_id
		self.title:SetAsset(ResPath.GetTitleIcon(title_id))
		local title_cfg = TitleData.Instance:GetTitleCfg(title_id) or {}
		local title_fp = CommonDataManager.GetCapability(title_cfg) or 0
		self.fp:SetValue(title_fp)
	end

	local open_cfg = KaifuActivityData.Instance:GetKaifuActivityOpenCfg()
	if open_cfg then
		for k,v in pairs(open_cfg) do
			if v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MARRY_ME then
				self.cfg = v
				break
			end
		end
	end
end

function MarryMeView:ReleaseCallBack()
	-- if self.item_cell then
	-- 	self.item_cell:DeleteMe()
	-- 	self.item_cell = nil
	-- end
	-- if self.cell_list then
	-- 	for k,v in pairs(self.cell_list) do
	-- 		v:DeleteMe()
	-- 	end
	-- end
	-- self.cell_list = {}

	-- 清理变量和对象
	self.rest_time = nil
	self.day = nil
	self.hour = nil
	self.minute = nil
	self.title = nil
	self.fp = nil
	self.number = nil
end

function MarryMeView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MARRY_ME, RA_MARRYME_OPERA_TYPE.RA_MARRYME_REQ_INFO)
	self:FlushRestTime()
	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(99999999, 1, BindTool.Bind(self.FlushRestTime, self))
	MarryMeData.Has_Open = true
	RemindManager.Instance:Fire(RemindName.MarryMe)
end

function MarryMeView:CloseCallBack()
	self:RemoveCountDown()
end

function MarryMeView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function MarryMeView:OnClickClose()
	self:Close()
end

function MarryMeView:OnClickMarry()
	local is_open, tips = OpenFunData.Instance:CheckIsHide("marriage")
	if is_open then
		self:Close()
		ViewManager.Instance:Open(ViewName.Wedding)
	else
		if tips then
			SysMsgCtrl.Instance:ErrorRemind(tips)
		end
	end
end

function MarryMeView:OnFlush()
	-- if self.scroller.scroller.isActiveAndEnabled then
 --    	self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
 --    end
end

function MarryMeView:FlushRestTime()
	local rest_time = 0
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.MARRY_ME) then
		rest_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.MARRY_ME) or 0
	end
	if rest_time <= 0 then
		self.day:SetValue(0)
		self.hour:SetValue(0)
		self.minute:SetValue(0)
		self:RemoveCountDown()
		return
	end
	local time_tab = TimeUtil.Format2TableDHM(rest_time)
	if time_tab then
		self.day:SetValue(time_tab.day)
		self.hour:SetValue(time_tab.hour)
		self.minute:SetValue(time_tab.min)
	end
end

function MarryMeView:InitScroller()
	local scroller_delegate = self.scroller.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMaxCellNum, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellList, self)
end

function MarryMeView:GetMaxCellNum()
	local num = 0
	local info = MarryMeData.Instance:GetInfo()
	if info then
		num = info.cur_couple_count or 0
	end
	return num
end

function MarryMeView:RefreshCellList(cell, data_index)
	local info_cell = self.cell_list[cell]
	if info_cell == nil then
		info_cell = MarryMeInfoCell.New(cell.gameObject)
		self.cell_list[cell] = info_cell
	end
	local info = MarryMeData.Instance:GetInfo()
	if info then
		local couple_list = info.couple_list or {}
		info_cell:SetData(couple_list[data_index + 1])
	end
end

-----------------------------MarryMeInfoCell---------------------------------------------
MarryMeInfoCell = MarryMeInfoCell or BaseClass(BaseCell)
function MarryMeInfoCell:__init()
	self.male_name = self:FindVariable("MaleName")
	self.female_name = self:FindVariable("FemaleName")
end

function MarryMeInfoCell:__delete()

end

function MarryMeInfoCell:OnFlush()
	if self.data then
		if self.data.proposer_sex == GameEnum.MALE then
			self.male_name:SetValue(self.data.propose_name)
			self.female_name:SetValue(self.data.accept_proposal_name)
		else
			self.male_name:SetValue(self.data.accept_proposal_name)
			self.female_name:SetValue(self.data.propose_name)
		end
	end
end