--------------------------------------------------------------------------
-- MoLongInfoView 远征信息面板
--------------------------------------------------------------------------
ExpeditionView = ExpeditionView or BaseClass(BaseRender)

function ExpeditionView:__init(instance)
	ExpeditionView.Instance = self
	self:InitView()
end

function ExpeditionView:__delete()
	ExpeditionView.Instance = nil
	if self.expedition_left_view ~= nil then
		self.expedition_left_view:DeleteMe()
		self.expedition_left_view = nil
	end

	for k,v in pairs(self.molongout_list) do
		v:DeleteMe()
	end

	if self.recieve_view then
		self.recieve_view:DeleteMe()
	end
end

function ExpeditionView:InitView()
	self.expedition_left_view = ExpeditionLeftView.New(self:FindObj("expedition_left_view"))
	self.is_show_gift = self:FindVariable("is_show_gift")

	self:ListenEvent("help_click",BindTool.Bind(self.OnHelpClick, self))
	self:ListenEvent("close_recieve_click",BindTool.Bind(self.CloseRecieveClick, self))

	self.task_data = MoLongData.Instance:GetTaskInfoCfg()
	self.molongout_list = {}
	self.molongout_obj = {}
	for i=1,6 do
		self.molongout_obj[i] = self:FindObj("MolongOut"..i)
		self.molongout_list[i] = ExpeditionPointView.New(self.molongout_obj[i])
		self.molongout_list[i]:SetData(self.task_data[i])
	end

	self.recieve_view = ReceiveItemView.New(self:FindObj("recieve_view"))

	self.select_yuhun_index = 1
	self.is_out = false
	self:FlushRedPoint()
end

function ExpeditionView:ShowRecieveView(is_show,data)
	self.is_show_gift:SetValue(is_show)
	if is_show then
		self.recieve_view:SetData(data)
	end
end

-- 点击出征后设置
function ExpeditionView:GetExpeditionPoint(index)
	return self.molongout_list[index]
end

function ExpeditionView:FlushDataInOut(data)
	self.is_out = true
	for i=1,6 do
		self.molongout_list[i]:SetData(self.task_data[i])
		self.molongout_list[i]:FlushDataInOut(data)
	end
end

-- 出征完后重置
function ExpeditionView:ReCover()
	for i=1,6 do
		self.molongout_list[i]:FlusGoOut()
	end
end

function ExpeditionView:SetIsOut(is_out)
	self.is_out = is_out
end

function ExpeditionView:GetIsOut()
	return self.is_out
end
-- end

function ExpeditionView:CloseRecieveClick()
	self:ShowRecieveView(false)
end

function ExpeditionView:OnHelpClick()
	local tips_id = 85  -- 远征信息
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ExpeditionView:GetYuHunIndex()
	return self.select_yuhun_index
end

function ExpeditionView:SetYuHunIndex(index)
	self.select_yuhun_index = index
end

function ExpeditionView:FlushExpeditionView()
	self.expedition_left_view:FlushInfo()
	self:SetIsOut(false)
	self:FlushRedPoint()
end

function ExpeditionView:FlushRedPoint()
	local show_red_point = false
	for i=1,5 do
		local cur_yuhun_info = MoLongData.Instance:GetYuHunInfoByIndex(i)
		if cur_yuhun_info.task_status == 0 or cur_yuhun_info.task_status == 2 then
			if cur_yuhun_info.level > 0 then
				show_red_point = true
				break
			end
		else
			local task_time = MoLongData.Instance:GetTaskTotalTimeBySeq(cur_yuhun_info.task_seq)
			local cur_time = TimeCtrl.Instance:GetServerTime()
			local total_time = task_time - (cur_time - cur_yuhun_info.task_begin_timestamp)
			if total_time <= 0 then
				show_red_point = true
				break
			end
		end
	end

	MoLongView.Instance:ExpeditionShowRedPoint(show_red_point)
end

--------------------------------------------------------------------------
-- 左面板
--------------------------------------------------------------------------
ExpeditionLeftView = ExpeditionLeftView or BaseClass(BaseRender)
function ExpeditionLeftView:__init()
	ExpeditionLeftView.Instance = self

	self.icon_cell_list = {}
	self.is_select = false
	self.task_list = {}

	self.current_icon_cell = nil
	self.index_list = {}

	self:InitListView()
end

function ExpeditionLeftView:__delete()
	for k, v in pairs(self.icon_cell_list) do
		v:DeleteMe()
	end
	self.icon_cell_list = {}
end

function ExpeditionLeftView:GetMolongOutListData(index,pos)
	for k,v in pairs(self.icon_cell_list) do
		if v:GetIndex() == index then
			v:GetCurPos(pos)
			return
		end
	end
end

function ExpeditionLeftView:GetMolongOutObj(index)
	for k,v in pairs(self.icon_cell_list) do
		if v:GetIndex() == index then
			return v:GetObj()
		end
	end
end

function ExpeditionLeftView:SetMoLongOutState(is_back)
	for k,v in pairs(self.icon_cell_list) do
		v:FlushGoOutData(is_back)
	end
end

function ExpeditionLeftView:ClearMolongGoOutClick()
	for k,v in pairs(self.icon_cell_list) do
		v:SetIsClickGoOutBt(false)
	end
end

function ExpeditionLeftView:BagJumpPage(page)
	local jump_index = page
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.scroller_list_view.scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = nil
	self.scroller_list_view.scroller:JumpToDataIndex(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

--ListView逻辑
function ExpeditionLeftView:InitListView()
	self.scroller_list_view = self:FindObj("icon_list_view")
	local list_delegate = self.scroller_list_view.list_simple_delegate
	-- 有有多少个cell
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- 更新cell
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function ExpeditionLeftView:GetNumberOfCells()
	return #self.task_list or 0
end

function ExpeditionLeftView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local icon_cell = self.icon_cell_list[cell]
	if icon_cell == nil then
		icon_cell = ExpeditionLeftCell.New(cell.gameObject, self)
		icon_cell.root_node.toggle.group = self.scroller_list_view.toggle_group
		self.icon_cell_list[cell] = icon_cell
	end
	icon_cell:SetIndex(data_index)
	icon_cell:SetData(self.task_list[data_index])
end

function ExpeditionLeftView:FlushInfo()
	local task_list = MoLongData.Instance:GetMitamaStarList()
	self.task_list = task_list
	self.scroller_list_view.scroller:RefreshActiveCellViews()
end

--------------------------------------------------------------------------
--ExpeditionLeftCell 	左格子
--------------------------------------------------------------------------
ExpeditionLeftCell = ExpeditionLeftCell or BaseClass(BaseCell)

function ExpeditionLeftCell:__init(instance, left_view)
	self.left_view = left_view

	self:IconInit()
end

function ExpeditionLeftCell:__delete()
	if self.MolongModel then
		self.MolongModel:DeleteMe()
		self.MolongModel = nil
	end

	if self.tweener then
		self.tweener:Pause()
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function ExpeditionLeftCell:IconInit()
	self.icon_sprite = self:FindObj("icon_sprite")
	self.icon_select = self:FindObj("icon_select")
	self.name = self:FindVariable("name")
	self.tips_text = self:FindVariable("tips_text")
	self.tips = self:FindObj("tips_tab")
	self.show_red_point = self:FindVariable("show_red_point")
	self.show_head = self:FindVariable("show_head")
	self.bt_text = self:FindVariable("bt_text")
	self.Obj = self:FindObj("Obj")
	self.path_line = self:FindObj("PathLine")

	self.yuhun_info = {}
	self.Button = self:FindObj("Button")

	self:ListenEvent("icon_btn_click",BindTool.Bind(self.IconOnClick, self))
	self:ListenEvent("fight_click",BindTool.Bind(self.OnFightClick, self))
	-- 飞行
	self.center_display = self:FindObj("CenterDisplay")

	self.is_select = false
	self.is_fly = false
	self.is_go_out_click = false
	self:InitMolongModel()
end

-- 飞
function ExpeditionLeftCell:GetObj()
	return self.Obj
end

function ExpeditionLeftCell:SetIsClickGoOutBt(is_go_out_click)
	self.is_go_out_click = is_go_out_click
end

function ExpeditionLeftCell:FlushGoOutData(is_back)
	if is_back then
		if self.is_go_out_click then
			self.Button:SetActive(true)
			self.bt_text:SetValue(Language.YuHun.ButtonLabel[1])
		else
			self.Button:SetActive(false)
		end
	else
		if self.yuhun_info.task_status == 0 then
			self.path_line:SetActive(false)
			self.MolongModel:SetVisible(false)
			if self.yuhun_info.level < 1 then
				self.tips:SetActive(true)
				self.tips_text:SetValue(Language.YuHun.ButtonLabel[3])
				self.Button:SetActive(false)
				self.show_red_point:SetValue(false)
			else
				self.tips:SetActive(false)
				self.bt_text:SetValue(Language.YuHun.ButtonLabel[0])
				self.show_red_point:SetValue(true)
				self.Button:SetActive(true)
			end
		elseif self.yuhun_info.task_status == 1 then
			self.path_line:SetActive(true)
			self.tips:SetActive(true)
			self.Button:SetActive(false)
			self.show_red_point:SetValue(false)
			self:FlushTime()
			self:FlushMolongModel()
		end
		if self.yuhun_info.task_status == 2 then
			self.MolongModel:SetVisible(false)
			self.tips:SetActive(false)
			self.Button:SetActive(true)
			self.bt_text:SetValue(Language.YuHun.ButtonLabel[2])
			self.show_red_point:SetValue(true)
		end
	end
end

function ExpeditionLeftCell:FlushMolongModel()
	local res_id = MoLongData.Instance:GetMolongModelBySeq(self.data.seq)
	local bubble, asset = ResPath.GetNpcModel(res_id)
	self.MolongModel:SetVisible(true)
	self.MolongModel:SetMainAsset(bubble, asset)
end

function ExpeditionLeftCell:InitMolongModel()
	if not self.MolongModel then
		self.MolongModel = RoleModel.New()
		self.MolongModel:SetDisplay(self.center_display.ui3d_display)
	end
end

function ExpeditionLeftCell:GetCurPos(pos)
	self.target_pos = {x = pos.x, y = pos.y, z = 0}
end

function ExpeditionLeftCell:OnFightClick()
	self.root_node.toggle.isOn = true
	ExpeditionView.Instance:SetYuHunIndex(self.index)
	if self.yuhun_info.task_status == 0 then
		self.is_go_out_click = not self.is_go_out_click
		self.left_view:SetMoLongOutState(self.is_go_out_click)
		if self.is_go_out_click then
			ExpeditionView.Instance:FlushDataInOut(self.data)
		else
			ExpeditionView.Instance:SetIsOut(false)
			ExpeditionView.Instance:ReCover()
		end
	elseif self.yuhun_info.task_status == 2 then
		MoLongCtrl.Instance:SendMitamaOperaReq(MITAMA_REQ_TYPE.MITAMA_REQ_TYPE_TASK_AWARD, self.index - 1)
	else
		MoLongCtrl.Instance:SendMitamaOperaReq(MITAMA_REQ_TYPE.MITAMA_REQ_TYPE_TASK_AWARD, self.index - 1)
	end
end

function ExpeditionLeftCell:IconOnClick()
	self.root_node.toggle.isOn = true
	local select_index = ExpeditionView.Instance:GetYuHunIndex()
	if select_index == self:GetIndex() then
		return
	end
	ExpeditionView.Instance:SetYuHunIndex(self.index)
end

function ExpeditionLeftCell:GetIsSelect()
	return self.root_node.toggle.isOn
end

function ExpeditionLeftCell:OnFlush()
	if not next(self.data) then return end

	-- 刷新选中特效
	local select_index = ExpeditionView.Instance:GetYuHunIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end

	local yuhun_info = MoLongData.Instance:GetYuHunInfoByIndex(self.index)
	self.yuhun_info = yuhun_info

	if yuhun_info.level > 0 then
		self.show_head:SetValue(true)
	else
		self.show_head:SetValue(false)
	end

	if yuhun_info.task_status == 0 then
		self.MolongModel:SetVisible(false)
		self.path_line:SetActive(false)
		if yuhun_info.level < 1 then
			self.tips:SetActive(true)
			self.tips_text:SetValue(Language.YuHun.ButtonLabel[3])
			self.Button:SetActive(false)
			self.show_red_point:SetValue(false)
		else
			self.tips:SetActive(false)
			self.bt_text:SetValue(Language.YuHun.ButtonLabel[0])
			self.show_red_point:SetValue(true)
			self.Button:SetActive(true)
		end
	elseif yuhun_info.task_status == 1 then
		self.MolongModel:SetVisible(true)
		self.tips:SetActive(true)
		self.Button:SetActive(false)
		self.show_red_point:SetValue(false)
		self.path_line:SetActive(true)
		self:FlushTime()
		self:FlushMolongModel()
	end

	if yuhun_info.task_status == 2 then
		self.MolongModel:SetVisible(false)
		self.tips:SetActive(false)
		self.Button:SetActive(true)
		self.bt_text:SetValue(Language.YuHun.ButtonLabel[2])
		self.path_line:SetActive(false)
		self.show_red_point:SetValue(true)
	end

	self.name:SetValue(self.data.name)
	if self.is_go_out_click then
		self.is_go_out_click = false
		ExpeditionView.Instance:SetIsOut(false)
		ExpeditionView.Instance:ReCover()
	end
end

function ExpeditionLeftCell:FlushTime()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	local task_time = MoLongData.Instance:GetTaskTotalTimeBySeq(self.yuhun_info.task_seq)
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local total_time = task_time - (cur_time - self.yuhun_info.task_begin_timestamp)
	local cur_elapse_time = cur_time - self.yuhun_info.task_begin_timestamp
	local cur_rest_of_time = math.ceil(task_time - cur_elapse_time)

	if cur_rest_of_time > 3600 then
		self.tips_text:SetValue(string.format(Language.YuHun.MissionState[0],math.floor(cur_rest_of_time/3600),math.floor((cur_rest_of_time/60)%60)))
	elseif cur_rest_of_time >= 60 then
		self.tips_text:SetValue(string.format(Language.YuHun.MissionState[0],math.floor((cur_rest_of_time/60)%60),cur_rest_of_time % 60))
	else
		self.tips_text:SetValue(string.format(Language.YuHun.MissionState[1],cur_rest_of_time % 60))
	end

	GlobalTimerQuest:AddDelayTimer(function ()
		self:FlushFlyAni(cur_rest_of_time,true)
	end, 0)

	self.count_down = CountDown.Instance:AddCountDown(total_time, 0.2, BindTool.Bind(self.DelayTime, self))
end

function ExpeditionLeftCell:DelayTime(elapse_time, total_time)
	local rest_of_time = math.ceil(total_time - elapse_time)
	local hour = math.floor(rest_of_time/3600)
	local second = math.floor((rest_of_time/60)%60)
	local miao = rest_of_time % 60

	if rest_of_time > 3600 then
		self.tips_text:SetValue(string.format(Language.YuHun.MissionState[0],hour,second))
	elseif rest_of_time >= 60 then
		self.tips_text:SetValue(string.format(Language.YuHun.MissionState[0],second,miao))
	else
		self.tips_text:SetValue(string.format(Language.YuHun.MissionState[1],miao))
	end
	self:FlushFlyAni(rest_of_time)

	if(total_time - elapse_time <= 0) then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self.Button:SetActive(true)
		self.tips:SetActive(false)
		self.MolongModel:SetVisible(false)
		self.bt_text:SetValue(Language.YuHun.ButtonLabel[2])
		self.show_red_point:SetValue(true)
		self.path_line:SetActive(false)
	end
end

function ExpeditionLeftCell:FlushFlyAni(rest_of_time,is_turn)
	ExpeditionView.Instance:GetExpeditionPoint(self.yuhun_info.task_seq + 1):SetCurMoLongData(self.data)
	ExpeditionView.Instance:GetExpeditionPoint(self.yuhun_info.task_seq + 1):GetCurPos()
	local task_time = MoLongData.Instance:GetTaskTotalTimeBySeq(self.yuhun_info.task_seq)
	local pos = Vector3(rest_of_time * self.target_pos.x / task_time,rest_of_time * self.target_pos.y / task_time,0)
	local position = Vector3(self.target_pos.x - pos.x,self.target_pos.y - pos.y,0)
	local angle = math.deg(math.atan2(self.target_pos.y - position.y, self.target_pos.x - position.x))
	local line_angle = 0
	local mode_angle = 0

	if position.x > self.target_pos.x then
		line_angle = angle - 90
		mode_angle = angle
	else
		mode_angle = angle - 180
		line_angle = angle - 90
	end

	self.path_line.rect:SetLocalPosition(position.x, position.y, 0)
	self.path_line.rect.localRotation = Quaternion.Euler(0, 0, line_angle)
	self.path_line.rect.sizeDelta = Vector2(5,math.sqrt((pos.x*pos.x) + (pos.y*pos.y)))
	self.center_display.rect:SetLocalPosition(position.x, position.y, 0)
	-- if is_turn then
	-- 	self.center_display.ui3d_display:ResetRotation()
	-- 	self.center_display.ui3d_display:SetRotation(Vector3(0, mode_angle, 0))
	-- end
end

-------------------------  远征点类
ExpeditionPointView = ExpeditionPointView or BaseClass(BaseRender)
function ExpeditionPointView:__init()
	ExpeditionPointView.Instance = self
	self:ListenEvent("OnClick",BindTool.Bind(self.OnClick, self))

	self.time = self:FindVariable("time")
	self.name = self:FindVariable("name")
	self.flag_bt = self:FindObj("flag_bt")

	self.cur_molong_data = {}
	-- self.star_list = {}
	self.data = {}
	-- for i=1,6 do
	-- 	self.star_list[i] = self:FindObj("star"..i)
	-- end
end

function ExpeditionPointView:__delete()
	ExpeditionPointView.Instance = nil
end

function ExpeditionPointView:GetCurPos()
	--获取指引按钮的屏幕坐标
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.flag_bt.rect.position)

	--转换屏幕坐标为本地坐标
	local rect = ExpeditionLeftView.Instance:GetMolongOutObj(self.cur_molong_data.seq + 1):GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))
	ExpeditionLeftView.Instance:GetMolongOutListData(self.cur_molong_data.seq + 1,local_pos_tbl)
end

function ExpeditionPointView:OnClick()
	if ExpeditionView.Instance:GetIsOut() then
		local func = function ()
		    MoLongCtrl.Instance:SendMitamaOperaReq(MITAMA_REQ_TYPE.MITAMA_REQ_TYPE_TASK_FIGHTING, ExpeditionView.Instance:GetYuHunIndex() - 1, self.data.seq)
			ExpeditionView.Instance:SetIsOut(false)
			ExpeditionView.Instance:ReCover()
			ExpeditionLeftView.Instance:ClearMolongGoOutClick()
			ExpeditionLeftView.Instance:SetMoLongOutState(true)
			self:GetCurPos()
		end
		local str = string.format(Language.YuHun.MissionState[2],self.cur_molong_data.name,self.data.name,math.floor(self.data.need_time/60))
		TipsCtrl.Instance:ShowCommonTip(func,nil,str)
	else
		ExpeditionView.Instance:ShowRecieveView(true,self.data)
	end
end

function ExpeditionPointView:SetData(data)
	self.data = data
	self:FlushData()
end

function ExpeditionPointView:SetCurFightIndex(index)
	self.index = index
end

function ExpeditionPointView:FlushData()
	if not next(self.data) then return end

	-- for i=1, 6 do
	-- 	self.star_list[i]:SetActive(false)
	-- end

	-- for i=1, self.data.level do
	-- 	self.star_list[i]:SetActive(true)
	-- end

	self.name:SetValue(self.data.name)
	local temp_time = math.floor(self.data.need_time/60)
	self.time:SetValue(string.format(Language.YuHun.MissionState[3], temp_time))
end

-- 点击出征后刷新
function ExpeditionPointView:FlushDataInOut(data)
	self.cur_molong_data = data
	local cur_yuhun_info = MoLongData.Instance:GetYuHunInfoByIndex(ExpeditionView.Instance:GetYuHunIndex())
	if cur_yuhun_info.task_status == 0 then
		if cur_yuhun_info.level >= self.data.level then
			self.flag_bt.button.interactable = true
			self.flag_bt.grayscale.GrayScale = 0
		else
			self.flag_bt.button.interactable = false
			self.flag_bt.grayscale.GrayScale = 254
		end
	end
end

function ExpeditionPointView:SetCurMoLongData(data)
	self.cur_molong_data = data
end

function ExpeditionPointView:FlusGoOut()
	self.flag_bt.button.interactable = true
	self.flag_bt.grayscale.GrayScale = 0
end

--------------------------    奖励道具类
ReceiveItemView =  ReceiveItemView or BaseClass(BaseRender)
function ReceiveItemView:__init()
	self.item_list = {}
	for i=1,4 do
		local item_cell = ReceiveGridItem.New(self:FindObj("item_" .. i))
		table.insert(self.item_list, item_cell)
	end
end

function ReceiveItemView:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
end

function ReceiveItemView:SetData(data)
	local item_list = data.reward_item_list
	local item_num = 1
	for k, v in pairs(item_list) do
		self.item_list[item_num]:SetData(v)
		item_num = item_num + 1
	end
end

---------------------------------------------------------------------------- 道具类
ReceiveGridItem = ReceiveGridItem or BaseClass(BaseRender)

function ReceiveGridItem:__init()
	self.item_cell = {}
	self.item_cell = ItemCell.New(self:FindObj("ItemCell"))
end

function ReceiveGridItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ReceiveGridItem:SetData(data)
	self.data = data
	if not next(self.data) then
		self:SetActive(false)
		return
	end
	self:SetActive(true)

	local item_data = {}
	item_data.item_id = self.data.item_id
	item_data.num = self.data.num
	item_data.is_bind = self.data.is_bind
	self.item_cell:SetData(item_data)
end