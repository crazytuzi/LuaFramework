KuaFu1v1ViewRank = KuaFu1v1ViewRank or BaseClass(BaseRender)

local Count = 8
local ListViewDelegate = ListViewDelegate

function KuaFu1v1ViewRank:__init(instance)
	if instance == nil then
		return
	end
    self.select_num = 1
	self.grade_window = self:FindObj("GradeWindow")
	self.role_display = self:FindObj("DisPlay")
	self.title_show_frame = self:FindObj("TitlePanel")
	self.toggle_group = self:FindObj("Scroller"):GetComponent(typeof(UnityEngine.UI.ToggleGroup))
	self.show_title = self:FindVariable("ShowFirstTitle")
	self.show_text_title = {}
    for i=1, 3 do
    	self.show_text_title[i] = self:FindVariable("ShowTextTitle" .. i)
    end

	self.rank_info_list = {}
	for i = 1, Count do
		self.rank_info_list[i] = InfosItemCell.New(self:FindObj("Info" .. i))
		self.rank_info_list[i].parent_view = self
	end

	self.rank_info_myself = {}
	local variable_table = self:FindObj("InfoSelf"):GetComponent(typeof(UIVariableTable))
	self.rank_info_myself.no1 = variable_table:FindVariable("No1")
	self.rank_info_myself.no2 = variable_table:FindVariable("No2")
	self.rank_info_myself.no3 = variable_table:FindVariable("No3")
	self.rank_info_myself.rank = variable_table:FindVariable("Rank")
	self.rank_info_myself.name = variable_table:FindVariable("Name")
	self.rank_info_myself.grade = variable_table:FindVariable("Grade")
	self.rank_info_myself.ji_fen = variable_table:FindVariable("JiFen")
	self.rank_info_myself.reward = variable_table:FindVariable("Reward")

	self.page = self:FindVariable("Page")
	self.rank_yesterday = self:FindVariable("RankYesterday")
	self.rank_reward = self:FindVariable("RankReward")
	self.fp = self:FindVariable("Fp")
	self.first_title = self:FindVariable("FirstTitle")
	self.show_fp = self:FindVariable("ShowFP")
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self:FindObj("RewardItem"))

	self:ListenEvent("OnClickGetReward",
		BindTool.Bind(self.OnClickGetReward, self))
	self:ListenEvent("OnClickShowDetails",
		BindTool.Bind(self.OnClickShowDetails, self))
	self:ListenEvent("OnClickHelp",
		BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickNextPage",
		BindTool.Bind(self.OnClickNextPage, self))
	self:ListenEvent("OnClickPrePage",
		BindTool.Bind(self.OnClickPrePage, self))
	self:ListenEvent("OnClickJumpPage",
		BindTool.Bind(self.OnClickJumpPage, self))
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))

	self.red_point_list = {}
	for i = 1, 10 do
		self:ListenEvent("OnClickRank" .. i,
			function() self:OnClickRank(i) end)
		self.red_point_list[i] = self:FindVariable("ShowRedPoint" .. i)
		self.red_point_list[i]:SetValue(false)
	end

	self:InitScroller()

	self.curret_page = 1
	self.total_page = 1
	self.current_rank = 1

	self.rank_info = {}
	self:FlushModel(1)
	self:InitPreview()
end

function KuaFu1v1ViewRank:__delete()
	if self.single_obj_transform ~= nil then
		GameObject.Destroy(self.single_obj_transform.gameObject)
		self.single_obj_transform = nil
	end

	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for k, v in pairs(self.preview_next_cell) do
		v:DeleteMe()
	end

	self.preview_next_cell = {}

	for k, v in pairs(self.rank_info_list) do
		v:DeleteMe()
	end

	self.rank_info_list = {}
	self.show_text_title = {}
	self.show_title = nil
	self.select_num = nil
	self.show_fp = nil
	self.reward_item = nil
end

function KuaFu1v1ViewRank:GetToggleGroupComponent()
	return self.toggle_group
end

function KuaFu1v1ViewRank:Flush()
	self.rank_info = KuaFu1v1Data.Instance:GetRankList()
	if self.rank_info then
		local count = #self.rank_info
		self.total_page = count / Count
		self.total_page = math.ceil(self.total_page)
		if self.total_page == 0 then
			self.total_page = 1
		end
	end
	self:FlushSelfInfo()
	self.curret_page = 1
	self:FlushPage(self.curret_page)
	self:FlushGradeInfoWindow()
	self:FlushPreview(self.current_rank)
	self:FlushRedPoint()
end

function KuaFu1v1ViewRank:FlushSelfInfo()
	self.rank_info_myself.no1:SetValue(false)
	self.rank_info_myself.no2:SetValue(false)
	self.rank_info_myself.no3:SetValue(false)
	self.rank_info_myself.rank:SetValue("")

	self.info_self = KuaFu1v1Data.Instance:GetRoleData()
	if self.rank_info and self.info_self then
		self.rank_info_myself.ji_fen:SetValue(self.info_self.cross_score_1v1)
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local role_id = vo.role_id
		local rank = 0
		for k,v in pairs(self.rank_info) do
			if v.role_id ==  role_id then
				rank = k
			end
		end

		if rank == 0 then
			self.rank_info_myself.rank:SetValue(Language.Kuafu1V1.NoRank)
		else
			local _, reward_rank = KuaFu1v1Data:GetRankRewardAndIndex(rank)
			if rank <= 3 then
				self.rank_info_myself["no" .. rank]:SetValue(true)
			else
				self.rank_info_myself.rank:SetValue(rank)
			end

			self.rank_info_myself.reward:SetValue(Language.Kuafu1V1.Reward[reward_rank])
		end
		self.rank_info_myself.name:SetValue(vo.name)
		local config = KuaFu1v1Data.Instance:GetRankByScore(self.info_self.cross_score_1v1)
		if config then
			self.rank_info_myself.grade:SetValue(config.rank_name)
		else
			self.rank_info_myself.grade:SetValue(Language.Common.WuDuanWei)
		end
	end
end

function KuaFu1v1ViewRank:FlushPage(page)
	if page > self.total_page then
		return
	end
	self:ClearPage()
	self.curret_page = page
	self.page:SetValue(self.curret_page .. "/" .. self.total_page)
	for i = 1, Count do
		self.rank_info_list[i]:SetData(page, Count, i)
	end

	self:FlushAllHL()
end

function  KuaFu1v1ViewRank:FlushAllHL()
	for i = 1, Count do
		self.rank_info_list[i]:FlushHL()
	end
end

function KuaFu1v1ViewRank:ClearPage()
	for i = 1, Count do
		self.rank_info_list[i]:ClearInfos()
	end
end

function KuaFu1v1ViewRank:OnClickNextPage()
	self.curret_page = self.curret_page + 1
	if self.curret_page > self.total_page then
		self.curret_page = 1
	end
	self:FlushPage(self.curret_page)
end

function KuaFu1v1ViewRank:OnClickPrePage()
	self.curret_page = self.curret_page - 1
	if self.curret_page < 1 then
		self.curret_page = self.total_page
	end
	self:FlushPage(self.curret_page)
end

function KuaFu1v1ViewRank:OnClickJumpPage()
	-- TipsCtrl.Instance:OpenCommonInputView(nil, BindTool.Bind(self.InputEnd, self), nil, self.total_page)
end

function KuaFu1v1ViewRank:InputEnd(count)
	self.curret_page = count or self.curret_page
	self:FlushPage(self.curret_page)
end

function KuaFu1v1ViewRank:OnClickGetReward()

end

function KuaFu1v1ViewRank:OnClickShowDetails()
	self.grade_window:SetActive(true)
end

function KuaFu1v1ViewRank:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(94)
end

function KuaFu1v1ViewRank:OnClickClose()
	KuaFu1v1Ctrl.Instance.view:OpenMainView()
end

function KuaFu1v1ViewRank:OnClickRank(index)
	self.current_rank = index
	self:FlushGradeInfoWindow()
	self:FlushPreview(self.current_rank)
end

function KuaFu1v1ViewRank:SetSelectNum(select_num)
	self.select_num = select_num
end

function KuaFu1v1ViewRank:GetSelectNum()
	return self.select_num or 0
end

function KuaFu1v1ViewRank:FlushModel(info_num)
	if not self.role_model then
		self.role_model = RoleModel.New("kuafu1v1_panel")
		self.role_model:SetDisplay(self.role_display.ui3d_display)
	end
	if not info_num or info_num == 0 then
		return 
	end

	local get_curshizhuang, index = KuaFu1v1Data.Instance:GetRankRewardAndIndex(info_num)
	if not get_curshizhuang then
		return 
	end

	local shizhuang_id = 0
	local wuqi_id = 0
	local title_id = 0
    if get_curshizhuang then
    	shizhuang_id = get_curshizhuang.shizhuang_show or 0
    	wuqi_id = get_curshizhuang.weapon_show or 0
    	title_id = get_curshizhuang.title_show or 0
    end

    local rank_info = KuaFu1v1Data.Instance:GetRankList()

    ---没有排名时显示第一套
    if rank_info[1] == nil then
    	if info_num ~= 1 then
    	    return
    	end

    	if self.role_model then
			self.role_model:ResetRotation()
			local vo = GameVoManager.Instance:GetMainRoleVo() 
			if nil ~= vo then
				local info = {sex = vo.sex, prof = vo.prof}
				info.appearance = {fashion_body = shizhuang_id, fashion_wuqi = wuqi_id}
				self.role_model:SetModelResInfo(info, false, true, true)
		    end
	    end

		self:FlushFp(info_num)
		self:LoadSingleTitle(title_id or 0, index)
		self:SetSelectNum(0)
		self:FlushAllHL()
    end
    
	if not rank_info[info_num] then
       return 
    end
	if self.role_model then
		self.role_model:ResetRotation()
		local neirong = rank_info[info_num] 
		if nil ~= neirong then
			local info = {sex = neirong.sex, prof = neirong.prof}
			info.appearance = {fashion_body = shizhuang_id, fashion_wuqi = wuqi_id}
			self.role_model:SetModelResInfo(info, false, true, true)
	    end
	end

    self:FlushFp(info_num)
    self:LoadSingleTitle(title_id or 0, index)
    self:SetSelectNum(info_num)
    self:FlushAllHL()
end

function KuaFu1v1ViewRank:FlushFp(num)
	local info = KuaFu1v1Data.Instance:GetShiZhuangInfo() 
	local get_curshizhuang, index = KuaFu1v1Data.Instance:GetRankRewardAndIndex(num)
	local shizhuang_id = 0
	local wuqi_id = 0
	local title_id = 0
    if get_curshizhuang then
    	shizhuang_id = get_curshizhuang.shizhuang_show or 0
    	wuqi_id = get_curshizhuang.weapon_show or 0
    	title_id = get_curshizhuang.title_show or 0
    end

	local shizhuang_cfg = FashionData.Instance:GetClothingConfig(shizhuang_id) or {}
	local wuqi_cfg = FashionData.Instance:GetWuqiConfig(wuqi_id) or {}
	local fp = CommonDataManager.GetCapabilityCalculation(shizhuang_cfg) or 0
	local fp_wuqi = CommonDataManager.GetCapabilityCalculation(wuqi_cfg)
	local title_cfg = TitleData.Instance:GetTitleCfg(title_id) or {}
	local title_fp = CommonDataManager.GetCapabilityCalculation(title_cfg) or 0
	fp = fp + title_fp + fp_wuqi
	self.fp:SetValue(fp)
	self.show_fp:SetValue(index <= 4)
	self.reward_item:SetData({item_id = ResPath.CurrencyToIconId.kuafu_jifen[1], num = get_curshizhuang.honor_show or 0})
end

function KuaFu1v1ViewRank:LoadSingleTitle(title_id, num)
	if title_id > 0 then
	    self.first_title:SetAsset(ResPath.GetTitleIcon(title_id))
	    self.show_title:SetValue(true)
    else
    	self.show_title:SetValue(false)
    end
    
    if not self.show_text_title then 
        return
    end

    for k, v in pairs(self.show_text_title) do
		self.show_text_title[k]:SetValue(k == num)
	end
end

-----------------------------------------------------预览-----------------------------------------------------------
function KuaFu1v1ViewRank:InitPreview()
	self.preview_next_cell = {}
	for i = 1, 2 do
		self.preview_next_cell[i] = ItemCell.New(self:FindObj("ItemCell" .. i))
		self.preview_next_cell[i]:SetActive(false)
	end

	self.preview_show_next_reward = self:FindVariable("ShowNextReward")
	self.preview_name = self:FindVariable("Name")
	self.preview_title = self:FindVariable("Title")
	self.preview_is_can_get = self:FindVariable("IsCanGet")
	self.titlepower = self:FindVariable("TitlePower")
	self:ListenEvent("OnClickGet",
		BindTool.Bind(self.GetReward, self))
	self:FlushPreview(1)
end

function KuaFu1v1ViewRank:FlushPreview(index)
	local info = KuaFu1v1Data.Instance:GetRoleData()
	local history_cfg = KuaFu1v1Data.Instance:GetHistoryConfig()
	if info and history_cfg then
		self.preview_show_next_reward:SetValue(true)
		if index == #history_cfg + 1 then
			self.preview_show_next_reward:SetValue(false)
		end
		local cfg = KuaFu1v1Data.Instance:GetHistoryCfgByIndex(index) or {}
		local need_score = cfg.score or 0
		-- 如果这个历史奖励未领取过，且当前积分大于要求积分
		if KuaFu1v1Data.Instance:GetRewardFlagByIndex(index - 1) and info.cross_score_1v1 >= need_score then
			self.preview_is_can_get:SetValue(true)
		else
			self.preview_is_can_get:SetValue(false)
		end
		local next_cfg = history_cfg[index]
		if next_cfg then
			for k,v in pairs(next_cfg.reward_item) do
				if v.item_id > 0 then
					local cell = self.preview_next_cell[k + 1]
					if cell then
						cell:SetActive(true)
						cell:SetData(v)
					end
				end
			end
			self.preview_name:SetValue(next_cfg.name)
			self.preview_title:SetAsset(ResPath.GetTitleIcon(next_cfg.title_id))
			local cfg = TitleData.Instance:GetTitleCfg(next_cfg.title_id)
			if nil ~= cfg then
				local power =  CommonDataManager.GetCapabilityCalculation(cfg)
				self.titlepower:SetValue(power)
			end
		end
	end
end

function KuaFu1v1ViewRank:GetReward()
	local info = KuaFu1v1Data.Instance:GetRoleData()
	if info then
		if not KuaFu1v1Data.Instance:GetRewardFlagByIndex(self.current_rank - 1) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Kuafu1V1.CantReward)
			return
		end
		KuaFu1v1Ctrl.Instance:SendGetCross1V1RankRewardReq(self.current_rank - 1)
	end
end

function KuaFu1v1ViewRank:FlushRedPoint()
	local info = KuaFu1v1Data.Instance:GetRoleData()
	for i = 1, 7 do
		local cfg = KuaFu1v1Data.Instance:GetHistoryCfgByIndex(i) or {}
		local need_score = cfg.score or 0
		-- 最后一个段位不显示红点
		if i < 7 and KuaFu1v1Data.Instance:GetRewardFlagByIndex(i - 1) and info.cross_score_1v1 >= need_score then
			self.red_point_list[i]:SetValue(true)
		else
			self.red_point_list[i]:SetValue(false)
		end
	end
end

-----------------------------------------------------------------GradeInfoWindow--------------------------------------------------------

--初始化滚动条
function KuaFu1v1ViewRank:InitScroller()
	self.list_view_delegate = ListViewDelegate()
	self.scroller = self:FindObj("Scroller")
	self.cell_list = {}

	PrefabPool.Instance:Load(AssetID("uis/views/kuafu1v1_prefab", "GradeInfo"), function (prefab)
		if nil == prefab then
			return
		end
		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		PrefabPool.Instance:Free(prefab)

		self.enhanced_cell_type = enhanced_cell_type
		self.scroller.scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
end

--滚动条数量
function KuaFu1v1ViewRank:GetNumberOfCells()
	local count = KuaFu1v1Data.Instance:GetRankCountByType(self.current_rank)
	return count
end

--滚动条大小
function KuaFu1v1ViewRank:GetCellSize(data_index)
	return 50
end

--滚动条刷新
function KuaFu1v1ViewRank:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)
	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = KuaFu1v1GradeInfoCell.New(cell_view)
		cell = self.cell_list[cell_view]
		cell:SetGroupByHandle(self)
		cell.sell_view = self
	end
	local data = KuaFu1v1Data.Instance:GetRankByIndex(self.current_rank, data_index + 1)
	if data then
		cell:SetData(data)
	end
	return cell_view
end

function KuaFu1v1ViewRank:FlushGradeInfoWindow()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

--------------------------------------------------------------GradeInfoCell---------------------------------------------------------
KuaFu1v1GradeInfoCell = KuaFu1v1GradeInfoCell or BaseClass(BaseCell)

function KuaFu1v1GradeInfoCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)

	self.grade = self:FindVariable("Grade")
	self.wei_wang = self:FindVariable("WeiWang")
	self.ji_fen = self:FindVariable("JiFen")
end

function KuaFu1v1GradeInfoCell:__delete()

end

function KuaFu1v1GradeInfoCell:SetGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function KuaFu1v1GradeInfoCell:SetGroupByHandle(handle)
	self.handle = handle
	self.root_node.toggle.group = handle:GetToggleGroupComponent()
end

function KuaFu1v1GradeInfoCell:Flush()
	if self.data then
		local item_list = Split(self.data.reward, ":")
		self.grade:SetValue(self.data.rank_name)
		if item_list and item_list[2] then
			self.wei_wang:SetValue(item_list[2])
		end
		self.ji_fen:SetValue(self.data.rank_score)
	end
end

----------------------------------InfosItemCell----------------------------------

InfosItemCell = InfosItemCell or BaseClass(BaseCell)

function  InfosItemCell:__init()
	self.info_num = 0
	self.no_list = {}
	for i = 1, 3 do
		self.no_list[i] = self:FindVariable("No" .. i)
	end
    
	self.rank = self:FindVariable("Rank")
	self.name = self:FindVariable("Name")
	self.grade = self:FindVariable("Grade")
	self.ji_fen = self:FindVariable("JiFen")
	self.reward = self:FindVariable("Reward")
	self.show_hl = self:FindVariable("ShowHL")
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))	
end

function InfosItemCell:__delete()
    self.no_list = {}
	self.rank = nil	
	self.name = nil
	self.grade = nil
	self.ji_fen = nil
	self.reward = nil
	self.info_num = nil
	self.show_hl = nil
	self.parent_view = nil
end

function InfosItemCell:ClearInfos()
	for i = 1, 3 do
		self.no_list[i]:SetValue(false)
	end
	self.info_num = 0
	self.rank:SetValue("")
	self.name:SetValue("")
	self.grade:SetValue("")
	self.ji_fen:SetValue("")
	self.reward:SetValue("")
end

function InfosItemCell:FlushHL()
	if self.parent_view ~= nil then
		local num = self.parent_view:GetSelectNum() or 0
		self.show_hl:SetValue(num == self.info_num)
    end
end

function InfosItemCell:OnClickGet()
	if self.parent_view ~= nil then
        self.parent_view:FlushModel(self.info_num)
    end
end

function InfosItemCell:SetData(page, Count, item_num)
	local rank_info = KuaFu1v1Data.Instance:GetRankList()
	if not rank_info then
       return 
    end

    self.info_num = (page - 1) * Count + item_num
	local info = rank_info[self.info_num]
	if not info then 
		return 
	end

	if page == 1 then
		if item_num <= 3 then
			self.no_list[item_num]:SetValue(true)
		else
			self.rank:SetValue(self.info_num)
		end
	else
		self.rank:SetValue(self.info_num)
	end


	local _, reward_rank = KuaFu1v1Data:GetRankRewardAndIndex(self.info_num)
	self.reward:SetValue(Language.Kuafu1V1.Reward[reward_rank] or Language.Common.No)

	self.name:SetValue(info.name or "")
	self.ji_fen:SetValue(info.score or 0)
	local config = KuaFu1v1Data.Instance:GetRankByScore(info.score)
	if config and config.rank_name then
		self.grade:SetValue(config.rank_name or "")
	else
		self.grade:SetValue(Language.Common.WuDuanWei)
	end
end


