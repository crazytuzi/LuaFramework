WeddingInviteView = WeddingInviteView or BaseClass(BaseView)

local InviteIndex = {
	"toggle_friend",
	"toggle_guild",
	"toggle_stranger",
}

function WeddingInviteView:__init()
	self.ui_config = {"uis/views/marriageview","InviteGuestsView"}
	self.invite_list = {}
	self.uninvite_list = {}
	self.list_data = {}
	self.item_data = {}
	self.select_page = 0

	self:SetMaskBg()
end

function WeddingInviteView:ReleaseCallBack()
	self.cur_quantity = nil
	self.all_quantity = nil
	self.weding_type = nil
	self.invite_view = nil
	self.uninvite_view = nil

	if self.invite_list then
		for k,v in pairs(self.invite_list) do
			v:DeleteMe()
		end
	end
	self.invite_list = {}

	if self.uninvite_list then
		for k,v in pairs(self.uninvite_list) do
			v:DeleteMe()
		end
	end
	self.uninvite_list = {}

	for i = 1, 3 do
		self[InviteIndex[i]] = nil
	end
end

function WeddingInviteView:LoadCallBack()
	self.cur_quantity = self:FindVariable("cur_quantity")
	self.all_quantity = self:FindVariable("all_quantity")
	self.weding_type = self:FindVariable("weding_type")

	for i = 1, 3 do
		self[InviteIndex[i]] = self:FindObj("toggle_".. i)
		self[InviteIndex[i]].toggle:AddValueChangedListener(BindTool.Bind(self.Flush, self))
	end

	self:InitScroller()
	self:ListenEvent("Close",BindTool.Bind(self.ClickClose, self))
	self:ListenEvent("AddQuantity",BindTool.Bind(self.OnAddQuantity, self))

	self.invite_view = self:FindObj("ListView_2")
	local list_delegate = self.invite_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetInvitedNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshInvitedListView, self)
	MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_GET_YUYUE_INFO)
	self:Flush()
end

function WeddingInviteView:ClickClose()
	self:Close()
end

function WeddingInviteView:OpenCallBack()
	 MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_GET_APPLICANT_INFO)
end

function WeddingInviteView:OnAddQuantity()
	local other_cfg = MarriageData.Instance:GetMarriageConditions()
	if other_cfg then
		local yes_func = function()
			MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_BUY_GUEST_NUM)
		end
		local content = string.format(Language.Marriage.FbBuyCountTips, other_cfg.wedding_buy_guest_price)
		TipsCtrl.Instance:ShowCommonAutoView("", content, yes_func)
	end
end

function WeddingInviteView:CloseCallBack()
	self.is_invite_list = {}
	if self.friend_callback ~= nil then
		GlobalEventSystem:UnBind(self.friend_callback)
	end
	if self.guild_callback ~= nil then
		GlobalEventSystem:UnBind(self.guild_callback)
	end
end

function WeddingInviteView:GetInvitedNumberOfCells()
	return #MarriageData.Instance:GetInviteGuests().data or 0
end

--刷新ListView
function WeddingInviteView:RefreshInvitedListView(cell, data_index)
	data_index = data_index + 1
	local invite_cell = self.invite_list[cell]
    if invite_cell == nil then
        invite_cell = WedingInviteListCell.New(cell.gameObject)
        self.invite_list[cell] = invite_cell
    end

    self.item_data = MarriageData.Instance:GetInviteGuests().data
    invite_cell:SetIndex(data_index)
    invite_cell:SetData(self.item_data[data_index])
end

function WeddingInviteView:OnFlush()
	local data = nil

	local guests_data = MarriageData.Instance:GetInviteGuests()
	self.cur_quantity:SetValue(guests_data.can_num - guests_data.has_num)
	self.all_quantity:SetValue(guests_data.can_num)
	self.weding_type:SetValue(Language.Marriage.HunYanType[guests_data.wedding_type])

	self.list_data = {}
	if self.toggle_friend.toggle.isOn then
		data = MarriageData.Instance:InviteListData(ScoietyData.Instance:GetFriendInfo())
	elseif self.toggle_guild.toggle.isOn then
		data = MarriageData.Instance:InviteListData(GuildDataConst.GUILD_MEMBER_LIST.list)
	else
		data = MarriageData.Instance:GetHaveApplicantInfo()
	end
	if data ~= nil and self.uninvite_view then
		self.list_data = data
		self.uninvite_view.scroller:ReloadData(0)
	end
	self.invite_view.scroller:ReloadData(0)
end

function WeddingInviteView:InitScroller()
	self.uninvite_view = self:FindObj("ListView_1")
	self.list_data = {}
	local delegate = self.uninvite_view.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.list_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index)
		local uninvite_cell = self.uninvite_list[cell]
	    if uninvite_cell == nil then
	        uninvite_cell = WedingUnInviteListCell.New(cell.gameObject)
	        self.uninvite_list[cell] = uninvite_cell
	    end

		local data = self.list_data[data_index + 1]
		uninvite_cell:SetIndex(data_index)
		uninvite_cell:SetData(data)
	end
end

------------------------------------未邀请的列表-------------------------------------
WedingUnInviteListCell = WedingUnInviteListCell or BaseClass(BaseCell)
function WedingUnInviteListCell:__init()
	self.role_name = self:FindVariable("role_name")
	self.show_delete = self:FindVariable("show_delete")

	self:ListenEvent("Invite_friend", BindTool.Bind(self.InviteFriend, self))
end

function WedingUnInviteListCell:__delete()

end

function WedingUnInviteListCell:OnFlush()
	if not self.data then return end
	self.role_name:SetValue(self.data.role_name or self.data.gamename)
end

function WedingUnInviteListCell:InviteFriend()
	MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_INVITE_GUEST, self.data.user_id or self.data.uid)
end

------------------------------------已邀请的列表-------------------------------------
WedingInviteListCell = WedingInviteListCell or BaseClass(BaseCell)
function WedingInviteListCell:__init()
	self.role_name = self:FindVariable("role_name")
	self.show_delete = self:FindVariable("show_delete")

	self:ListenEvent("Invite_friend", BindTool.Bind(self.InviteFriend, self))
	self:ListenEvent("remove", BindTool.Bind(self.Remove, self))
end

function WedingInviteListCell:__delete()

end

function WedingInviteListCell:OnFlush()
	if not self.data then return end

	self.role_name:SetValue(self.data.name or self.data.role_name)
	self.show_delete:SetValue(true)
end

function WedingInviteListCell:InviteFriend()
	MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_INVITE_GUEST, self.data.user_id or self.data.uid)
end

function WedingInviteListCell:Remove()
	MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_REMOVE_GUEST, self.data.user_id or self.data.uid)
end