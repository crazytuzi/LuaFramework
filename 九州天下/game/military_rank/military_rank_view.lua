MilitaryRankView = MilitaryRankView or BaseClass(BaseView)
local MAX_ATTR_NUM = 3
local MAX_STAR_NUM = 10
local SELECT_LAST_INDEX = 0
local SHOW_ATTR = {
	"gong_ji",
	"fang_yu",
	"max_hp",
}
local CURSTATE = {
	MAXLEVEL = 1,
	NOENOUGH = 2,
	ENOUGH = 3
}

function MilitaryRankView:__init()
	self.ui_config = {"uis/views/militaryrankview", "MilitaryRankView"}
	self:SetMaskBg()
	self.attr_label_list = {}
	self.star_list = {}
	self.cell_list = {}
	self.select_index = 1
end

function MilitaryRankView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil 
	end

	if self.money_bar then 
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	self.attr_label_list = {}
	self.star_list = {}
	self.cell_list = {}
	self.select_index = 1
	self.cur_capability = nil
	self.star_desc = nil
	self.honor_desc = nil
	self.star_is_active = nil
	self.is_last = nil
	self.act_time = nil
	self.is_complete = nil
	self.is_gray = nil
	self.top_name = nil
	self.select_name = nil
	self.need_honor = nil
	self.small_desc = nil
	self.star_num = nil
	self.list_view = nil
	self.star_redpoint = nil
	self.level_redpoint = nil
	self.btn_red = nil
	self.has_done = nil
	self.level_name = nil
	self.btn_close = nil
	self.up_level_button = nil

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.MilitaryRank)
	end
end

function MilitaryRankView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickLast", BindTool.Bind(self.OnClickLast, self))
	self:ListenEvent("UpLevel", BindTool.Bind(self.UpLevel, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))

	for i = 1, MAX_ATTR_NUM do
		self.attr_label_list[SHOW_ATTR[i]] = self:FindVariable("label_" .. i)
	end

	for i = 1, MAX_STAR_NUM do
		self.star_list[i] = self:FindVariable("Star_" .. i)
	end

	self.cur_capability = self:FindVariable("Capability")
	self.star_desc = self:FindVariable("StarDesc")
	self.honor_desc = self:FindVariable("CurHonor")
	-- 是否激活将星
	self.star_is_active = self:FindVariable("ShowStar")
	-- 是否选中将星
	self.is_last = self:FindVariable("Is_last")
	-- 普通军衔激活时间
	self.act_time = self:FindVariable("ActiveTime")
	-- 是否达成军衔
	self.is_complete = self:FindVariable("IsComplete")
	-- 按钮置灰
	self.is_gray = self:FindVariable("IsGray")
	-- 头顶的军衔名字
	self.top_name = self:FindVariable("TitleName")
	self.select_name = self:FindVariable("SelectName")
	-- 需要的荣誉
	self.need_honor = self:FindVariable("UpStar")
	-- 简洁说明
	self.small_desc = self:FindVariable("SmallDesc")

	self.star_num = self:FindVariable("StarNum")

	-- 星级红点
	self.star_redpoint = self:FindVariable("StarUp")
	-- 等级红点
	self.level_redpoint = self:FindVariable("LevelUp")
	self.btn_red = self:FindVariable("BtnRed")
	self.has_done = self:FindVariable("HasDone")
	--将军名字
	self.level_name = self:FindVariable("NameImage")

	--关闭按钮
	self.btn_close = self:FindObj("BtnClose")
	self.up_level_button = self:FindObj("UpLevelButton")

	local display = self:FindObj("RoleDisplay")
	self.role_model = RoleModel.New("military_view")
	self.role_model:SetDisplay(display.ui3d_display)

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.scroller:ReloadData(0)

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	local role_job = job_cfgs[main_role_vo.prof]
	local role_res_id = role_job["model" .. main_role_vo.sex]
	self.role_model:SetModelResInfo(main_role_vo, false, true, true, false, true, false, true)

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.MilitaryRank, BindTool.Bind(self.GetUiCallBack, self))
end

function MilitaryRankView:OpenCallBack()
	MilitaryRankCtrl.Instance:SendAllInfoRequest()
	self:Flush()
end

function MilitaryRankView:GetNumberOfCells()
	return #MilitaryRankData.Instance:GetLevelCfg()
end

function MilitaryRankView:RefreshCell(cell, cell_index)
	local cur_cell = self.cell_list[cell]
	local data_list = MilitaryRankData.Instance:GetLevelCfg()
	if cur_cell == nil then
		cur_cell = MilitaryRankItem.New(cell.gameObject, self)
		self.cell_list[cell] = cur_cell
		cur_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	cell_index = cell_index + 1
	cur_cell:SetIndex(cell_index)
	cur_cell:SetData(data_list[cell_index])
end

function MilitaryRankView:OnFlush(param_t)
	local cur_level = MilitaryRankData.Instance:GetCurLevel()
	local max_level = #MilitaryRankData.Instance:GetLevelCfg()
	for k,v in pairs(param_t) do
		if k == "all" then
			if SELECT_LAST_INDEX == self.select_index then
				self:FlushLastInfo()
			else
				self:FlushNormalInfo()
			end
			self.star_is_active:SetValue(cur_level >= max_level)
			self.list_view.scroller:ReloadData(0)
		end
	end
	self:CheckJumpIndex()
	local cur_cfg = MilitaryRankData.Instance:GetLevelSingleCfg(cur_level)
	if not cur_cfg then return end
	self.top_name:SetValue(cur_cfg.name)
	self.level_name:SetAsset(ResPath.GetImageName(cur_level))
end

function MilitaryRankView:SetSelectIndex(index)
	self.select_index = index
	self:FlushNormalInfo()
end

function MilitaryRankView:GetSelectIndex()
	return self.select_index
end

function MilitaryRankView:FlushAllHl()
	for k,v in pairs(self.cell_list) do
		v:FlushHl()
	end
end

function MilitaryRankView:OnClickLast()
	local cur_level = MilitaryRankData.Instance:GetCurLevel()
	local max_level = #MilitaryRankData.Instance:GetLevelCfg()
	if cur_level < max_level then
		SysMsgCtrl.Instance:ErrorRemind(Language.MilitaryRank.NotEnoughLevel)
		return 
	end

	self.is_last:SetValue(true)
	self.is_complete:SetValue(false)
	self.select_index = SELECT_LAST_INDEX
	self:FlushAllHl()
	self:FlushLastInfo()
end

function MilitaryRankView:UpLevel()
	if self.cur_state == CURSTATE.MAXLEVEL then
		SysMsgCtrl.Instance:ErrorRemind(Language.MilitaryRank.HasComplete)
		return
	elseif self.cur_state == CURSTATE.NOENOUGH then
		SysMsgCtrl.Instance:ErrorRemind(Language.MilitaryRank.NotEnoughJunGong)
		return
	end

	if SELECT_LAST_INDEX == self.select_index then
		MilitaryRankCtrl.Instance:SendUpStarRequest()
	else
		local cur_level = MilitaryRankData.Instance:GetCurLevel()
		local cur_jungong = MilitaryRankData.Instance:GetCurJunGong()
		local select_cfg = MilitaryRankData.Instance:GetLevelSingleCfg(self.select_index)
		if not select_cfg then return end

		-- if select_cfg.need_jungong > cur_jungong then 
		-- 	SysMsgCtrl.Instance:ErrorRemind(Language.MilitaryRank.NotEnoughJunGong)
		-- 	return 
		-- end

		if self.select_index > cur_level + 1 then            
			SysMsgCtrl.Instance:ErrorRemind(Language.MilitaryRank.CanNotShow)
			return 
		end
		MilitaryRankCtrl.Instance:OpenDecreeView(DECREE_SHOW_TYPE.ACCEPT_TASK)
	end
end

function MilitaryRankView:CheckJumpIndex()
	local cur_level = MilitaryRankData.Instance:GetCurLevel()
	if cur_level == 0 then return end
	local max_level = #MilitaryRankData.Instance:GetLevelCfg()
	self.select_index = cur_level + 1
	if cur_level < max_level then
		self.list_view.scroller:JumpToDataIndexForce(self.select_index - 1)
	end
	if cur_level >= max_level then
		self:OnClickLast() 
	end
	local cur_cfg = MilitaryRankData.Instance:GetLevelSingleCfg(cur_level+1)
	if cur_cfg then
		self:SetContentInfo(cur_cfg)
	end
end

-- 刷新列表中军衔的信息
function MilitaryRankView:FlushNormalInfo()
	self.is_last:SetValue(false)
	local cur_cfg = MilitaryRankData.Instance:GetLevelSingleCfg(self.select_index)
	local cur_level = MilitaryRankData.Instance:GetCurLevel()
	local cur_honor = MilitaryRankData.Instance:GetCurJunGong()
	if not cur_cfg or not next(cur_cfg) then print_error("junxian_config:", cur_cfg) return end
	self:SetContentInfo(cur_cfg)
	if cur_level + 1 == cur_cfg.level and cur_honor >= cur_cfg.need_jungong then
		self.level_redpoint:SetValue(true)
		self.btn_red:SetValue(true)
		-- self.is_gray:SetValue(false)
		self.cur_state = CURSTATE.ENOUGH
		self.has_done:SetValue(Language.MilitaryRank.UpLevelText)
	else
		self.level_redpoint:SetValue(false)
		self.btn_red:SetValue(false)
		-- self.is_gray:SetValue(true)
		if cur_level >= cur_cfg.level then
			self.cur_state = CURSTATE.MAXLEVEL
			self.has_done:SetValue(Language.MilitaryRank.MaxLevelText)
		else
			self.cur_state = CURSTATE.NOENOUGH
			self.has_done:SetValue(Language.MilitaryRank.UpLevelText)
		end
	end
	-- self.honor_desc:SetValue("Honor" .. self.select_index)

	self.is_complete:SetValue(cur_level >= cur_cfg.level)
	local complete_time = os.date("%Y-%m-%d", MilitaryRankData.Instance:GetActiveTimeByIndex(self.select_index))
	self.act_time:SetValue(complete_time)
end

-- 刷新最后一个军衔信息
function MilitaryRankView:FlushLastInfo()
	local cur_star = MilitaryRankData.Instance:GetCurStar()
	local cur_cfg = MilitaryRankData.Instance:GetStarSingleCfg(cur_star < MAX_STAR_NUM and cur_star + 1 or cur_star)
	local cur_honor = MilitaryRankData.Instance:GetCurJunGong()
	if not cur_cfg or not next(cur_cfg) then return end
	self:SetContentInfo(cur_cfg)
	for i = 1, MAX_STAR_NUM do
		if cur_star >= i and self.star_list[i] then
			self.star_list[i]:SetValue(true)
		elseif self.star_list[i] then
			self.star_list[i]:SetValue(false)
		end
	end
	self.star_num:SetValue(cur_star)

	if cur_star >= MAX_STAR_NUM then
		self.need_honor:SetValue(ToColorStr(Language.MilitaryRank.MaxStar, COLOR.GREEN))
		self.star_redpoint:SetValue(false)
		self.btn_red:SetValue(false)
		self.cur_state = CURSTATE.MAXLEVEL
		self.has_done:SetValue(Language.MilitaryRank.MaxLevelText)
		-- self.is_gray:SetValue(true)
	elseif cur_honor >= cur_cfg.need_jungong then
		self.star_redpoint:SetValue(true)
		self.btn_red:SetValue(true)
		self.cur_state = CURSTATE.ENOUGH
			self.has_done:SetValue(Language.MilitaryRank.UpLevelText)
		-- self.is_gray:SetValue(false)
	else
		self.star_redpoint:SetValue(false)
		self.btn_red:SetValue(false)
		self.cur_state = CURSTATE.NOENOUGH
			self.has_done:SetValue(Language.MilitaryRank.UpLevelText)
		-- self.is_gray:SetValue(true)
	end
end

function MilitaryRankView:SetContentInfo(cur_cfg)
	local attr_list = CommonDataManager.GetAttributteByClass(cur_cfg)
	self.select_name:SetValue(cur_cfg.name)
	for k,v in pairs(attr_list) do
		if self.attr_label_list[k] and v > 0 then
			local attr_str = string.format(Language.MilitaryRank.ShowAttr, CommonDataManager.GetAttrName(k), v)
			self.attr_label_list[k]:SetValue(attr_str)
		end
	end
	local cfg_level = cur_cfg.level or cur_cfg.star_level
	local cur_level = cur_cfg.level and MilitaryRankData.Instance:GetCurLevel() or MilitaryRankData.Instance:GetCurStar()
	local cur_honor = MilitaryRankData.Instance:GetCurJunGong()
	local color = TEXT_COLOR.GREEN_4
	local str = cur_cfg.need_jungong .. Language.MilitaryRank.Enough
	if cur_honor < cur_cfg.need_jungong then
		color = TEXT_COLOR.RED
		str = cur_cfg.need_jungong .. Language.MilitaryRank.NotEnough
	-- 	self.is_gray:SetValue(true)
	-- elseif cur_level >= cfg_level then
	-- 	self.is_gray:SetValue(true)
	-- else
	-- 	self.is_gray:SetValue(false)
	end
	self.need_honor:SetValue(ToColorStr(str, color))
	self.honor_desc:SetValue(CommonDataManager.ConverMoney(cur_honor))
	self.cur_capability:SetValue(CommonDataManager.GetCapability(cur_cfg))
	self.star_desc:SetValue(cur_cfg.desc or "")
	self.small_desc:SetValue(cur_cfg.small_desc or "")		
end

function MilitaryRankView:OnClickHelp()
	local tips_id = 188                             -- 玩法说明
	if self.select_index == SELECT_LAST_INDEX then
		tips_id = 189                               -- 星级说明
	end
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MilitaryRankView:OnClickGet()
	ViewManager.Instance:Open(ViewName.NationalWarfare)
	HelperCtrl.Instance:GetView():Flush("jungong")
end

function MilitaryRankView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.UpLevelButton then
		if self.up_level_button then
			return self.up_level_button, BindTool.Bind(self.UpLevel, self)
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end