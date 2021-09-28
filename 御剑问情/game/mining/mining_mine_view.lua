MiningMineView = MiningMineView or BaseClass(BaseRender)

function MiningMineView:__init(instance)
	self:InitView()
	self.view_type = MINING_VIEW_TYPE.MINE
	self.list_selected_index = 1
	self.list_show_line = 1
	self.list_max_line = 1
	self.list_can_reward = false
	self.mine_list = {}
	self.record_cell = {}
end

function MiningMineView:InitView()
	self.text_mine_num = self:FindVariable("text_mine_num")
	self.text_go_num = self:FindVariable("text_go_num")
	self.text_num = self:FindVariable("text_num")
	self.btn_left_show = self:FindVariable("btn_left_show")
	self.btn_right_show = self:FindVariable("btn_right_show")
	self.btn_enter_show = self:FindVariable("btn_enter_show")
	self.btn_enter_text = self:FindVariable("btn_enter_text")
	self.btn_is_on_text = self:FindVariable("btn_is_on_text")
	self.is_red_show = self:FindVariable("is_red_show")
	self.is_red_record = self:FindVariable("is_red_record")
	self.my_zhan_li = self:FindVariable("my_zhan_li")

	self.text_tip = self:FindVariable("text_tip")
	self.text_tip:SetValue(Language.Mining.MiningMineTip2)

	for i = 0, 4 do
		self["mine_item_" .. i] = MiningMineItem.New(self:FindObj("mine_item_" .. i))
	end

	self:ListenEvent("EnterClick",BindTool.Bind(self.EnterClick, self))
	self:ListenEvent("OpenHelp",BindTool.Bind(self.OpenHelp, self))
	self:ListenEvent("BtnLeftClick", BindTool.Bind(self.BtnLeftClick, self))
	self:ListenEvent("BtnRightClick", BindTool.Bind(self.BtnRightClick, self))
	self:ListenEvent("OnClickRecord", BindTool.Bind(self.OnClickRecord, self))

	for i = 0, 4 do
		self:ListenEvent("OnClickMineItem" .. i,BindTool.Bind(self.OnClickMineItem, self, i))
	end

	self:InitRecordListView()
	self:Flush()
end

function MiningMineView:__delete()
	self:CloseCallBack()
	for i = 0, 4 do
		if nil ~= self["mine_item_" .. i] then
			self["mine_item_" .. i]:RemoveCountDown()
			self["mine_item_" .. i]:DeleteMe()
			self["mine_item_" .. i] = nil
		end
	end
	for k, v in pairs(self.record_cell) do
		v:DeleteMe()
		v = nil 
	end
	self.text_tip = nil 
	self.text_mine_num = nil
	self.text_go_num = nil
	self.btn_left_show = nil 
	self.btn_right_show = nil 
	self.btn_enter_show = nil
	self.btn_enter_text = nil
	self.btn_is_on_text = nil
	self.is_red_record = nil
	self.is_red_show = nil
	self.list_selected_index = 1
	self.list_show_line = 1
	self.list_can_reward = false
end

function MiningMineView:OpenCallBack()
	self:Flush()
	self:RemoveTimeQuest()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(
			BindTool.Bind2(self.AddTimeQuest, self), 30)
	end

	--显示自己战力
	self.my_zhan_li:SetValue(GameVoManager.Instance:GetMainRoleVo().capability)
end

-- 移除启动红点定时器刷新红点
function MiningMineView:RemoveTimeQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function MiningMineView:AddTimeQuest()
	MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_MINING_INFO)
end

function MiningMineView:CloseCallBack()
	self:RemoveCountDown()
	self:RemoveTimeQuest()
end

function MiningMineView:OnFlush()
	self:UpdataTimeText()
	self:UpdataMineList()
	self:UpdataBtnShow()
	self:UpdataRecordList()
	self:UpdataRecordRed()
end

function MiningMineView:UpdataBtnShow()
	local info_data = MiningData.Instance:GetMiningMineMyInfo()
	self:RemoveCountDown()

	local is_show_red = MiningData.Instance:GetMiningMineRemindView()
	self.is_red_show:SetValue(is_show_red == 1)
	if info_data.mining_end_time > 0 then
		local time = math.max(info_data.mining_end_time - TimeCtrl.Instance:GetServerTime(), 0)
    	if time == 0 then
  			self.btn_enter_text:SetValue(Language.Mining.MiningBtnText[3])
   			self.btn_enter_show:SetValue(true)
   			self.list_can_reward = true
   			self.btn_is_on_text:SetValue("")
  		else
  			self:SetCountDown(time)
  			self.btn_enter_text:SetValue(Language.Mining.MiningBtnText[2])
   			self.btn_enter_show:SetValue(false)
   			self.list_can_reward = false
   		end
	else
		self.btn_enter_show:SetValue(true)
		self.btn_enter_text:SetValue(Language.Mining.MiningBtnText[1])
		self.btn_is_on_text:SetValue("")
		self.list_can_reward = false
	end
end

function MiningMineView:SetCountDown(time)
	if not self.count_down then
		self.btn_is_on_text:SetValue("00:00")
		if time > 0 then
			self:DiffTime(0, time)
			self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.DiffTime, self))
		end
	end
end

function MiningMineView:DiffTime(elapse_time, total_time)
	local left_time = math.floor(total_time - elapse_time)
	local the_time_text = TimeUtil.FormatSecond2MS(left_time)
	self.btn_is_on_text:SetValue(the_time_text)
	if left_time <= 0 then
		MiningController.Instance:OpenMiningRewardView()
		self:RemoveCountDown()
	end
end

function MiningMineView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
		self.btn_is_on_text:SetValue("")
	end
end

function MiningMineView:EnterClick()
	if self.list_can_reward then
		MiningController.Instance:OpenMiningRewardView()
	else
		MiningController.Instance:OpenMiningSelectedView()
	end
end

function MiningMineView:OpenHelp()
	local tips_id = 200
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MiningMineView:BtnLeftClick()
	self.list_show_line = (self.list_show_line - 1) > 0 and (self.list_show_line - 1) or 0
	self.list_selected_index = self:GetIndexByLine(self.list_show_line)
	self:UpdataMineListShow()
end

function MiningMineView:BtnRightClick()
	self.list_show_line = (self.list_show_line + 1) <= self.list_max_line and (self.list_show_line + 1) or self.list_max_line
	self.list_selected_index = self:GetIndexByLine(self.list_show_line)
	self:UpdataMineListShow()
end

function MiningMineView:OnClickRecord()
	MiningController.Instance:OpenMiningRecordListView(self.view_type)
end

function MiningMineView:OnClickMineItem(index)
	if self["mine_item_" .. index] ~= nil then
		local item_data = self["mine_item_" .. index]:GetItemData()
		if item_data ~= nil then
			if MiningData.Instance:GetIsMyMining(item_data.owner_uid) == false then
				MiningController.Instance:OpenMiningTargetView(self.view_type, MINING_TARGET_TYPE.QIANG_DUO, item_data)
				-- MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_ROB_MINE, 0, item_data.owner_uid)
			end
		end
	end
end

function MiningMineView:UpdataTimeText()
	if self.text_mine_num ~= nil then
		local num = MiningData.Instance:GetMiningMineDayTimes()
		local color = num > 0 and "#FFFFFFFF" or "#FE3030FF"
		self.text_mine_num:SetValue(ToColorStr(num, color))
	end
	if self.text_go_num ~= nil then
		local go_num = MiningData.Instance:GetMiningMineRobTimes()
		self.text_go_num:SetValue(go_num)
		local go_color = go_num > 0 and "#FFFFFFFF" or "#FE3030FF"
		self.text_num:SetValue(ToColorStr(go_num, go_color))
		
	end
end

function MiningMineView:UpdataMineList()
	self.mine_list, self.list_len = MiningData.Instance:GetMiningMineList()

	self.list_max_line = self:GetLineByIndex(self.list_len)

	self:UpdataMineListShow()
end

function MiningMineView:GetLineByIndex(index)
	if index == nil then
		return 0
	end
	return math.max(math.floor((index - 1) / 5), 0)
end

function MiningMineView:GetIndexByLine(line)
	if line == nil then
		return 1
	end
	return (line * 5) + 1
end

function MiningMineView:UpdataMineListShow()
	local now_line = self:GetLineByIndex(self.list_selected_index)
	self.list_show_line = now_line

	if self.list_show_line > self.list_max_line then
		self.list_show_line = self.list_max_line
		self.list_selected_index = self:GetIndexByLine(self.list_show_line)
	end

	self.btn_left_show:SetValue(self.list_show_line > 0)
	self.btn_right_show:SetValue((self.list_show_line ~= self.list_max_line) and self.list_len > 5)
	local now_show_line = self:GetIndexByLine(self.list_show_line)

	for i = 0, 4 do
		if self.mine_list[now_show_line + i] ~= nil then
			self["mine_item_" .. i]:SetActive(true)
			self["mine_item_" .. i]:SetItemData(self.mine_list[now_show_line + i])
		else
			self["mine_item_" .. i]:RemoveCountDown()
			self["mine_item_" .. i]:SetActive(false)
		end
	end
end

-------------------全服抽奖记录---------------------
function MiningMineView:InitRecordListView()
	self.record_list_view = self:FindObj("record_list")
	local list_delegate = self.record_list_view.list_simple_delegate
	-- 有有多少个cell
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRecordInfoCount, self)
	-- 更新cell
	list_delegate.CellRefreshDel = BindTool.Bind(self.RecordRefreshCell, self)
end

function MiningMineView:GetRecordInfoCount()
	return #MiningData.Instance:GetMineRecordClientList() or 0
end

function MiningMineView:RecordRefreshCell(cell, data_index)
	data_index = data_index + 1
	local record_cell = self.record_cell[cell]
	if record_cell == nil then
		record_cell = RecordListClientItem.New(cell.gameObject)
		record_cell.root_node.toggle.group = self.record_list_view.toggle_group
		self.record_cell[cell] = record_cell
	end
 	
	local record_cell_info = MiningData.Instance:GetMineRecordClientList()
	if record_cell_info then
		local data = record_cell_info[data_index]
		record_cell:SetIndex(data_index)
		record_cell:SetData(data)
	end
end

function MiningMineView:UpdataRecordList()
 	if self.record_list_view and self.record_list_view.scroller.isActiveAndEnabled then
		self.record_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function MiningMineView:UpdataRecordRed()
 	self.is_red_record:SetValue(MiningData.Instance:GetFightingBeenRobMine())
end

-------------------------------------------矿物item
MiningMineItem = MiningMineItem or BaseClass(BaseRender)
function MiningMineItem:__init()
	self.img_icon = self:FindVariable("icon")
	self.icon_time = self:FindVariable("icon_time")
	self.icon_name = self:FindVariable("icon_name")
	self.tip_show = self:FindVariable("tip_show")
	self.tip_show_text = self:FindVariable("tip_show_text")
	self.tip_show_bg = self:FindVariable("tip_show_bg")
	self.is_male = self:FindVariable("is_male")
	self.zhan_li = self:FindVariable("zhan_li")
	self.show_zhanli = self:FindVariable("show_zhanli")

	self.effect = self:FindObj("effect")
	self.tip = self:FindObj("tip")
	self.item_data = nil
	self:Flush()
end

function MiningMineItem:__delete()
	self:RemoveCountDown()
	self.effect = nil
	self.tip = nil
	self.img_icon = nil
	self.icon_time = nil
	self.icon_name = nil
	self.tip_show = nil
	self.tip_show_text = nil
	self.tip_show_bg = nil
	self.item_data = nil
	self.is_male = nil
end

function MiningMineItem:OnFlush()
	self:UpdataIconShow()
end

function MiningMineItem:SetItemData(info_data)
	self.item_data = info_data
	self:UpdataIconShow()
end

function MiningMineItem:GetItemData()
	return self.item_data
end

function MiningMineItem:UpdataIconShow()
	if self.item_data ~= nil then
		self.img_icon:SetAsset(ResPath.GetMiningRes("mining_mine_" .. self.item_data.cur_type))
		self:RemoveCountDown()
		local time = math.max(self.item_data.mining_end_time - TimeCtrl.Instance:GetServerTime(), 0)
		if time > 0 then
			self:SetCountDown(time)
		end
		-- self.is_male:SetValue(self.item_data.sex == 0)

    	-- self.icon_time:SetValue(TimeUtil.FormatSecond2MS(time))
    	self.icon_time:SetValue("")
		self.icon_time:SetValue(self.item_data.index)

		local name = self.item_data.owner_name
		if MiningData.Instance:GetIsMyMining(self.item_data.owner_uid) == true then
			local info_data = MiningData.Instance:GetMiningMineCfg(self.item_data.cur_type)

			local item_name = ""
			if info_data ~= nil then
				item_name = info_data.name 
			end
			name = string.format(Language.Mining.Myself, item_name)
			
	    elseif self.item_data.random_index >= 0 and self.item_data.owner_uid == 0 then
	        name = MiningData.Instance:GetRandomNameByRandNum(self.item_data.random_index)
	    end
	    local name_color = MiningData.Instance:GetMiningNameColor(self.item_data.cur_type)
		self.icon_name:SetValue(ToColorStr(name,name_color))

		self.tip_show:SetValue(MiningData.Instance:GetIsMyMining(self.item_data.owner_uid) == false)
		
		if MiningData.Instance:GetIsMyMining(self.item_data.owner_uid) then
			self.show_zhanli:SetValue(false)
		else
			self.show_zhanli:SetValue(true)
			local capability = self.item_data.capability
			if GameVoManager.Instance:GetMainRoleVo().capability >= self.item_data.capability then
				capability = ToColorStr(capability, TEXT_COLOR.GREEN)
			else
				capability = ToColorStr(capability, TEXT_COLOR.RED)
			end
			self.zhan_li:SetValue(capability)
		end
	end
end

function MiningMineItem:SetCountDown(time)
	if not self.count_down then
		if time > 0 then
			self:DiffTime(0, time)
			self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.DiffTime, self))
		end
	end
end

function MiningMineItem:DiffTime(elapse_time, total_time)
	local left_time = math.floor(total_time - elapse_time)
	local the_time_text = TimeUtil.FormatSecond2MS(left_time)
	self.icon_time:SetValue(the_time_text)
	if left_time <= 0 then
		self:RemoveCountDown()
		self.icon_time:SetValue("")
	end
end

function MiningMineItem:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end