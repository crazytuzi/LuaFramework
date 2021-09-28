MonomerListView = MonomerListView or BaseClass(BaseView)

function MonomerListView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","MonomerList"}
	self.view_layer = UiLayer.Pop
end

function MonomerListView:__delete()
	
end

function MonomerListView:LoadCallBack()
	-- 生成滚动条
	self.monomer_cell_list = {}
	self.monomer_data = {}
	self.monomer_scroller = self:FindObj("MonomerList")
	local scroller_delegate = self.monomer_scroller.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCell, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.onlysex_checkbox = self:FindObj("OnlySexCheckBox")
	self.onlysex_checkbox.toggle:AddValueChangedListener(BindTool.Bind(self.OnCheckBoxChange,self))

	self:ListenEvent("Close",BindTool.Bind(self.ClickClose, self))
end

function MonomerListView:ReleaseCallBack()
	self.monomer_cell_list = {}
	self.monomer_scroller = nil
	self.onlysex_checkbox = nil
end


function MonomerListView:OpenCallBack()
	self.onlysex_checkbox.toggle.isOn = true
	local only_other_sex = true
	self.monomer_data = MarriageData.Instance:GetAllTuoDanList(only_other_sex)
	self.monomer_scroller.scroller:ReloadData(0)
end

function MonomerListView:OnCheckBoxChange(isOn)
	self.monomer_data = MarriageData.Instance:GetAllTuoDanList(isOn)
	self.monomer_scroller.scroller:ReloadData(0)
end

function MonomerListView:FlushTuoDanList()
	local only_other_sex = self.onlysex_checkbox.toggle.isOn
	self.monomer_data = MarriageData.Instance:GetAllTuoDanList(only_other_sex)
	self.monomer_scroller.scroller:RefreshAndReloadActiveCellViews(true)
end

function MonomerListView:ClickClose()
	self:Close()
end

function MonomerListView:GetNumberOfCell()
	return #self.monomer_data
end

function MonomerListView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local monomer_cell = self.monomer_cell_list[cell]
	if not monomer_cell then
		monomer_cell = MonomerItemCell.New(cell.gameObject)
		self.monomer_cell_list[cell] = monomer_cell
	end
	monomer_cell:SetIndex(data_index)
	monomer_cell:SetData(self.monomer_data[data_index])
end

-------------我要脱单ItemCell------------------------
MonomerItemCell = MonomerItemCell or BaseClass(BaseCell)

function MonomerItemCell:__init()
	self.raw_image = self:FindObj("RawImage")

	self.image_res = self:FindVariable("ImageRes")
	self.raw_image_res = self:FindVariable("RawImageRes")
	self.is_image = self:FindVariable("IsImage")

	self.name = self:FindVariable("Name")
	self.level = self:FindVariable("Level")
	self.power = self:FindVariable("Power")
	self.declaration = self:FindVariable("Declaration")
	self.is_boy = self:FindVariable("IsBoy")
	self.btn_time = self:FindVariable("BtnTime")
	self.is_send_time = self:FindVariable("IsSendTime")

	self:ListenEvent("ClickGood", BindTool.Bind(self.ClickGood, self))
	self:ListenEvent("ClickHead", BindTool.Bind(self.ClickHead, self))
end

function MonomerItemCell:__delete()
	self:StopCountDown()
end

function MonomerItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end
	if self.data.sex == 1 then
		self.is_boy:SetValue(true)
	else
		self.is_boy:SetValue(false)
	end

	self.name:SetValue(self.data.name)
	self.power:SetValue(self.data.capability)

	local level_des = PlayerData.GetLevelString(self.data.level)
	self.level:SetValue(level_des)

	self.declaration:SetValue(self.data.notice)

	--设置头像
	local role_id = self.data.uid

	CommonDataManager.NewSetAvatar(role_id, self.is_image, self.image_res, self.raw_image, self.data.sex, self.data.prof, false)
	
	self:StartCountDown()
end

--示好
function MonomerItemCell:ClickGood()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.data.uid == main_vo.role_id then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotGoodDes)
		return
	end

	local private_obj = {}
	if nil == ChatData.Instance:GetPrivateObjByRoleId(self.data.uid) then
		private_obj = ChatData.CreatePrivateObj()
		private_obj.role_id = self.data.uid
		private_obj.username = self.data.name
		private_obj.sex = self.data.sex
		private_obj.prof = self.data.prof
		private_obj.avatar_key_small = self.data.avatar_key_small
		private_obj.level = self.data.level
		ChatData.Instance:AddPrivateObj(private_obj.role_id, private_obj)
	end

	local text = MarriageData.Instance:GetTuoDanDes()

	local msg_info = ChatData.CreateMsgInfo()
	msg_info.from_uid = main_vo.role_id
	local real_role_id = CrossServerData.Instance:GetRoleId()				--获取真实id，防止在跨服聊天出问题
	real_role_id = real_role_id > 0 and real_role_id or main_vo.role_id
	msg_info.role_id = real_role_id
	msg_info.username = main_vo.name
	msg_info.sex = main_vo.sex
	msg_info.camp = main_vo.camp
	msg_info.prof = main_vo.prof
	msg_info.authority_type = main_vo.authority_type
	msg_info.avatar_key_small = main_vo.avatar_key_small
	msg_info.level = main_vo.level
	msg_info.vip_level = main_vo.vip_level
	msg_info.channel_type = CHANNEL_TYPE.PRIVATE
	msg_info.content = text
	msg_info.send_time_str = TimeUtil.FormatTable2HMS(TimeCtrl.Instance:GetServerTimeFormat())
	msg_info.content_type = CHAT_CONTENT_TYPE.TEXT
	msg_info.tuhaojin_color = CoolChatData.Instance:GetTuHaoJinCurColor() or 0			--土豪金
	msg_info.channel_window_bubble_type = CoolChatData.Instance:GetSelectSeq()					--气泡框
	msg_info.is_read = 1

	ChatData.Instance:AddPrivateMsg(self.data.uid, msg_info)
	ChatCtrl.SendSingleChat(self.data.uid, text, CHAT_CONTENT_TYPE.TEXT)

	SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.GoodSuccDes)

	--设置冷却时间
	MarriageData.Instance:AddSendGoodTimeList(self.data.uid)
	self:StartCountDown()

	ChatCtrl.Instance.guild_chat_view:Flush("new_chat", {CHANNEL_TYPE.PRIVATE, self.data.uid})
end

--开始倒计时
function MonomerItemCell:StartCountDown()
	self:StopCountDown()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local last_send_time = MarriageData.Instance:GetSendGoodTime(self.data.uid) or 0
	local end_cd_time = last_send_time + 10
	if server_time >= end_cd_time then
		self.is_send_time:SetValue(false)
		return
	end

	local function timer_func(elapse_time, total_time)
		if IsNil(self.root_node.gameObject) then
			self:StopCountDown()
			return
		end
		if elapse_time >= total_time then
			self:StopCountDown()
			self.is_send_time:SetValue(false)
			return
		end
		local time = math.ceil(total_time - elapse_time)
		self.btn_time:SetValue(time)
		self.is_send_time:SetValue(true)
	end

	local left_time = math.ceil(end_cd_time - server_time)
	self.count_down = CountDown.Instance:AddCountDown(left_time, 1, timer_func)
	self.btn_time:SetValue(left_time)
	self.is_send_time:SetValue(true)
end

--停止倒计时
function MonomerItemCell:StopCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function MonomerItemCell:ClickHead()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.data.uid == main_vo.role_id then
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotGoodDes)
		return
	end
	local open_type = ScoietyData.DetailType.Default
	ScoietyCtrl.Instance:ShowOperateList(open_type, self.data.name)
end