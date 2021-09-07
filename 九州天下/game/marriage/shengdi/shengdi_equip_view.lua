ShengDiEquipView = ShengDiEquipView or BaseClass(BaseRender)

function ShengDiEquipView:__init()
	self.bag_cell = {}
	self.task_cell = {}
	self.Layer_data = {}
	self.on_cliclk_index = 1
	self.select_index = 1
	--获取控件
	self.bag_list_view = self:FindObj("ListView")
	local list_delegate = self.bag_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self.task_list_view = self:FindObj("list_view")
	local list_delegateTwo = self.task_list_view.list_simple_delegate
	list_delegateTwo.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCellTwo, self)
	list_delegateTwo.CellRefreshDel = BindTool.Bind(self.BagRefreshCellTwo, self)

	self.item_cell_list = {}
	for i = 1, 7 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("item_" .. i))
		self.item_cell_list[i] = item
	end
	self.show_item = {}
	for i = 5, 7 do
		self.show_item[i] = self:FindVariable("ShowItem" .. i)
	end

	self.IsClick = self:FindVariable("IsClick")
	self.is_show = self:FindVariable("is_show")
	self.show_red = self:FindVariable("ShowRed")
	self.is_get_reward = self:FindVariable("IsGetReward")

	self.Layer_data = MarriageData.Instance:GetShengDiLayerCfg()

	-- self:ListenEvent("OnClicklingqu",BindTool.Bind(self.OnClicklingqu, self))
	self:ListenEvent("OnClickfuben",BindTool.Bind(self.OnClickfuben, self))
	self:ListenEvent("onclick_tips",BindTool.Bind(self.OnClickTips, self))
	self:ListenEvent("OnClickQuick",BindTool.Bind(self.OnClickQuick, self))

	self:OnFlush()
end

function ShengDiEquipView:__delete()
	if self.bag_cell then
		for k,v in pairs(self.bag_cell) do
			v:DeleteMe()
		end
		self.bag_cell = {}
	end

	if self.task_cell then
		for k,v in pairs(self.task_cell) do
			v:DeleteMe()
		end
		self.task_cell = {}
	end

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	self.bag_list_view = nil
	self.IsClick = nil
	self.is_show = nil
	self.show_red = nil
	self.is_get_reward = nil
	self.on_cliclk_index = 1
	self.show_item = {}
end

function ShengDiEquipView:OpenCallBack()
end

function  ShengDiEquipView:SetOnClickIndex(cell)
	local index = cell:GetIndex()
	self.on_cliclk_index = index
	self:FlushAllHl()
	self:FlushItemCell()
end

function ShengDiEquipView:GetOnCliclkIndex()
	return self.on_cliclk_index
end

function ShengDiEquipView:FlushItemCell()
	if self.item_cell_list == {} then return end
	local item_data = self.Layer_data[self.on_cliclk_index]
	for i = 1, 4 do
		self.item_cell_list[i]:SetData({item_id = item_data["show_item_id"..i], is_bind = 0})
	end
end

function ShengDiEquipView:OnFlush()
	local sheng_di_other_cfg =  MarriageData.Instance:GetShengDiOtherCfg()
	local task_info_list = MarriageData.Instance:GetTaskInfoList()

	
	local other_btn_show = MarriageData.Instance:GetIsOtherBtnShow()
	self.IsClick:SetValue(other_btn_show == 2)
	self.show_red:SetValue(other_btn_show == 2)

	local  level  = PlayerData.Instance:GetRoleVo().level
	local num = MarriageData.Instance:GetTaskNum()
	if level >= sheng_di_other_cfg.skip_task_limit_level and num > 0 then
		self.is_show:SetValue(true)
	else
		self.is_show:SetValue(false)
	end

	local reward_item = {}
	if PlayerData.Instance:GetRoleVo().sex == 1 then
		reward_item = sheng_di_other_cfg.male_reward_item
	else
		reward_item = sheng_di_other_cfg.female_reward_item
	end
	local temp_index = 0
	for i = 5, 7 do
		if reward_item[temp_index] then
			self.item_cell_list[i]:SetData(reward_item[temp_index])
			self.item_cell_list[i]:SetImgGray(other_btn_show == 1)
			self.show_item[i]:SetValue(true)
			if other_btn_show == 2 then
				self.item_cell_list[i]:ListenClick(BindTool.Bind(self.OnClicklingqu, self))
			end
		else
			self.show_item[i]:SetValue(false)
		end
		temp_index = temp_index + 1
		--self.item_cell_list[i]:SetRedPoint(other_btn_show == 2)
	end
	if self.bag_list_view then
		self.bag_list_view.scroller:ReloadData(0)
	end
	if self.task_list_view then
		self.task_list_view.scroller:ReloadData(0)
	end
	self:FlushItemCell()

	-- local task_list = self:GetDataList()
	-- for k, v in pairs(table_name) do
	-- 	print(k,v)
	-- end
end

--请求领取额外奖励
function ShengDiEquipView:OnClicklingqu()
	MarriageCtrl.Instance:SendQingYuanShengDiOperaReq(QYSD_OPERA_TYPE.QYSD_OPERA_TYPE_FETCH_OTHER_REWARD)

end
--请求进入副本
function ShengDiEquipView:OnClickfuben()
	local level = MarryEquipData.Instance:GetMarryInfo().marry_level
	local layer = MarriageData.Instance:GetLayerCfgByLevel(level).layer or 0
	if layer - self.on_cliclk_index > 2 then
		SysMsgCtrl.Instance:ErrorRemind(Language.QingYuanShengDi.MarryLevel_3)
		return
	elseif layer < self.on_cliclk_index then
		SysMsgCtrl.Instance:ErrorRemind(Language.QingYuanShengDi.MarryLevel)
		return
	end

	-- print_error(">>>>>>>>>>>>", GameEnum.FB_CHECK_TYPE.FBCT_SHENGDI_FB, self.on_cliclk_index)
	MarriageData.Instance:SetSceneId(self.on_cliclk_index)
	MarriageData.Instance:SetNowShendiLayer(self.on_cliclk_index)
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_SHENGDI_FB, self.on_cliclk_index)
end

function ShengDiEquipView:OnClickTips()
	local tips_id = 226
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ShengDiEquipView:OnClickQuick()
	local skip_task_consume =  MarriageData.Instance:GetShengDiOtherCfg().skip_task_consume
	local num = MarriageData.Instance:GetTaskNum()
	local gold = num * skip_task_consume
	local str = string.format(Language.QingYuanShengDi.QuickCompletion, gold, num)
	local ok_callback = function ()
		MarriageCtrl.Instance:SendQingYuanShengDiOperaReq(QYSD_OPERA_TYPE.QYSD_OPERA_TYPE_QUICK_FINISH_TASK)
	end
	TipsCtrl.Instance:ShowCommonAutoView("", str, ok_callback, nil, true, nil, nil)
end

function ShengDiEquipView:BagGetNumberOfCells()
	return #self.Layer_data
end

function ShengDiEquipView:BagRefreshCell(cell, cell_index)
	--构造Cell对象.
	local list_cell = self.bag_cell[cell]
	if nil == list_cell then
		list_cell = ShengDiEquipRankCell.New(cell.gameObject,self)
		list_cell:ListenEvent("OnClickItme", BindTool.Bind3(self.SetOnClickIndex, self, list_cell))
		self.bag_cell[cell] = list_cell
	end
	list_cell:SetIndex(cell_index + 1)
	self.select_index = list_cell:SetIndex(cell_index + 1)
	list_cell:SetData(self.Layer_data[cell_index + 1])                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
	list_cell:FlushHl()
end

function ShengDiEquipView:FlushAllHl()
	for k,v in pairs(self.bag_cell) do
		v:FlushHl()
	end
end

function ShengDiEquipView:BagGetNumberOfCellTwo()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function ShengDiEquipView:GetDataList()
	return MarriageData.Instance:GetTaskList()
end

function ShengDiEquipView:BagRefreshCellTwo(cell, data_index)
	--构造Cell对象.
	local list_cell = self.task_cell[cell]
	if nil == list_cell then
		list_cell = ShengDiTaskInfoCell.New(cell.gameObject)
		self.task_cell[cell] = list_cell
	end
	local data_list = self:GetDataList() or {}
	list_cell:SetIndex(data_index + 1)
	list_cell:SetData(data_list[data_index + 1])
end
----------------------------ShengDiEquipRankCell---------------------------------
ShengDiEquipRankCell = ShengDiEquipRankCell or BaseClass(BaseCell)

function ShengDiEquipRankCell:__init(instance, parent)
	self.parent = parent
	self.RawImage = self:FindVariable("RawImage")
	self.FbName = self:FindVariable("FbName")
	self.level = self:FindVariable("level")
	self.show_hl = self:FindVariable("show_hl")
	self.is_show = self:FindVariable("is_show")
	self.show_gaoliang = self:FindVariable("ShouGaoliang")
	self.item_index = 0
end

function ShengDiEquipRankCell:__delete()
	self.RawImage = nil
	self.FbName = nil
	self.level = nil
end

function ShengDiEquipRankCell:SetIndex(index)
	self.item_index = index
end

function ShengDiEquipRankCell:GetIndex()
	return self.item_index
end

function ShengDiEquipRankCell:OnFlush()
	if not next(self.data) then return end
	local bundle, asset = ResPath.GetShengDiRawImage(self.item_index)
	self.RawImage:SetAsset(bundle, asset)
	self.FbName:SetValue(self.data.name)

	local level = MarryEquipData.Instance:GetMarryInfo().marry_level

	local layer = MarriageData.Instance:GetLayerCfgByLevel(level).layer or 0
	self.is_show:SetValue(false)
	if layer - self.data.layer > 2 then
		str = Language.QingYuanShengDi.MarryLevel_2
	elseif self.data.layer <= layer then
		self.is_show:SetValue(true)
		str = Language.QingYuanShengDi.MarryLevel_4
	else
		str = string.format(Language.QingYuanShengDi.Level,self.data.enter_level)
	end
	self.level:SetValue(str)
	self:FlushHl()
end

function ShengDiEquipRankCell:FlushHl()
	if self.show_hl then
		self.show_hl:SetValue(self.parent:GetOnCliclkIndex() == self.item_index)
	end
	self.show_gaoliang:SetValue(self.parent:GetOnCliclkIndex() == self.item_index)
end

----------------------------ShengDiTaskInfoCell---------------------------------
ShengDiTaskInfoCell = ShengDiTaskInfoCell or BaseClass(BaseCell)

function ShengDiTaskInfoCell:__init()
	self.is_click = self:FindVariable("is_click")
	self.task_text = self:FindVariable("task_text")
	self.btn_text = self:FindVariable("btn_text")
	self.show_task_red = self:FindVariable("ShowRed")
	self:ListenEvent("onclick", BindTool.Bind(self.ClickKill, self))
end

function ShengDiTaskInfoCell:__delete()
	self.is_click = nil
	self.task_text = nil
	self.btn_text = nil
	self.show_task_red = nil
end

function ShengDiTaskInfoCell:SetIndex(index)
	self.item_index = index
end

function ShengDiTaskInfoCell:OnFlush()
	if not self.data or not next(self.data) then return end
	local  task_cfg = MarriageData.Instance:GetOneShengDiTaskById(self.data.task_id)
	self.is_click:SetValue(true)

	if self.data.is_fetched_reward == 1 then
		self.is_click:SetValue(false)
		self.btn_text:SetValue(Language.QingYuanShengDi.YiLingQu)
		self.show_task_red:SetValue(false)
	elseif self.data.is_fetched_reward == 0 and self.data.flag == 0 then
		self.btn_text:SetValue(Language.QingYuanShengDi.LingQu)
		self.show_task_red:SetValue(true)
	else
		self.btn_text:SetValue(Language.QingYuanShengDi.LingQu2)
		self.show_task_red:SetValue(false)
	end

	local str =  string.format(Language.QingYuanShengDi.Task[task_cfg.task_type],task_cfg.name_inside, task_cfg.param1, self.data.param, task_cfg.param1)
	self.task_text:SetValue(str)
	
end

function ShengDiTaskInfoCell:ClickKill(is_click)
	local  task_cfg = MarriageData.Instance:GetOneShengDiTaskById(self.data.task_id)
	local data = {}
	if PlayerData.Instance:GetRoleVo().sex == 1 then
		data = task_cfg.reward_item[0]
	else
		data = task_cfg.female_reward_item[0]
	end
	if self.data.flag == 1 then
		TipsCtrl.Instance:ShowStarRewardView(task_cfg.reward_item,true)
	else
		self:QingYuanShengDiReq()
	end
end

function ShengDiTaskInfoCell:QingYuanShengDiReq()
	MarriageCtrl.Instance:SendQingYuanShengDiOperaReq(QYSD_OPERA_TYPE.QYSD_OPERA_TYPE_FETCH_TASK_REWARD,self.data.index)
end

