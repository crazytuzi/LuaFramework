ScoietyFriendView = ScoietyFriendView or BaseClass(BaseRender)
function ScoietyFriendView:__init()
	self.show_onekey_red = self:FindVariable("ShowOneKeyRed")
	self.auto_kick_toggle = self:FindObj("AutoKickToggle").toggle
	self.auto_kick_toggle.isOn = ScoietyData.Instance:GetIsAutoDef() == 1

	self:ListenEvent("ClickAddFriend",BindTool.Bind(self.ClickAddFriend, self))
	self:ListenEvent("ClickLotAdd",BindTool.Bind(self.ClickLotAdd, self))
	self:ListenEvent("ClickLotDel",BindTool.Bind(self.ClickLotDel, self))
	self:ListenEvent("ClickBlackList",BindTool.Bind(self.ClickBlackList, self))
	self:ListenEvent("ClickEmpty",BindTool.Bind(self.ClickEmpty, self))
	-- self:ListenEvent("OpenGiftRecord",BindTool.Bind(self.OpenGiftRecord, self))
	-- self:ListenEvent("ClickHelp",BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("OnClickAutoKick",BindTool.Bind(self.OnClickAutoKick, self))

	-- 生成滚动条
	self.cell_list = {}
	self.scroller_data = {}
	self.scroller = self:FindObj("FriendList")
	local scroller_delegate = self.scroller.list_simple_delegate
	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local friend_cell = self.cell_list[cell]
		if friend_cell == nil then
			friend_cell = ScrollerFriendCell.New(cell.gameObject)
			friend_cell.root_node.toggle.group = self.scroller.toggle_group
			friend_cell.friend_view = self
			friend_cell:SetClickCallBack(BindTool.Bind(self.GiftOnClick, self))
			self.cell_list[cell] = friend_cell
		end

		friend_cell:SetIndex(data_index)
		friend_cell:SetData(self.scroller_data[data_index])
	end

	self.scroller.scroller.scrollerScrollingChanged = function ()
		ScoietyCtrl.Instance:CloseOperaList()
	end

	--引导用按钮
	self.friend_lot_add = self:FindObj("FriendLotAdd")
end

function ScoietyFriendView:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function ScoietyFriendView:GiftOnClick(cell)
	if nil == cell then
		return
	end
	local data = cell:GetData()
	if 0 == data.is_online then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.OnlineLimitDes)
		return
	end

	--查看后送礼红点消失
	if RemindManager.Instance:GetRemind(RemindName.ScoietyOtherFriend) > 0 and not ScoietyData.Instance:GetIsCheckGift() then
		ScoietyData.Instance:SetIsCheckGift(true)
		RemindManager.Instance:Fire(RemindName.ScoietyOtherFriend)
	end

	local data = cell:GetData()
	data.user_name = data.gamename
	FlowersCtrl.Instance:SetFriendInfo(data)
	ViewManager.Instance:Open(ViewName.Flowers)

	for _, v in pairs(self.cell_list) do
		v:SetShowRedPoint(false)
	end
end

function ScoietyFriendView:CloseFriendView()
	self.select_index = nil
end

--打开收礼记录面板
function ScoietyFriendView:OpenGiftRecord()
	ScoietyCtrl.Instance:ShowFriendRecordView()
end

function ScoietyFriendView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(4)
end

function ScoietyFriendView:ClickAddFriend()
	TipsCtrl.Instance:ShowAddFriendView()
end
-- 批量添加
function ScoietyFriendView:ClickLotAdd()
	self.show_onekey_red:SetValue(false)
	ScoietyData.Instance:SetShowOneKeyRemind(false)
	RemindManager.Instance:Fire(RemindName.ScoietyOneKeyFriend)
	ScoietyCtrl.Instance:ShowFriendRecView()
end
-- 批量删除
function ScoietyFriendView:ClickLotDel()
	ScoietyCtrl.Instance:ShowDeleteView()
end
-- 黑名单
function ScoietyFriendView:ClickBlackList()
	ScoietyCtrl.Instance:ShowBlackListView()
end

function ScoietyFriendView:ClickEmpty()
	ScoietyCtrl.Instance:CloseOperaList()
end

function ScoietyFriendView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ScoietyFriendView:GetSelectIndex()
	return self.select_index or 0
end

function ScoietyFriendView:FlushFriendView()
	if RemindManager.Instance:GetRemind(RemindName.ScoietyOneKeyFriend) > 0 then
		self.show_onekey_red:SetValue(true)
	else
		self.show_onekey_red:SetValue(false)
	end

	self.scroller_data = ScoietyData.Instance:GetFriendInfo()
	self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
end

function ScoietyFriendView:OnClickAutoKick(switch)
	local flag = switch and 1 or 0
	ScoietyCtrl.Instance:SendOfflineFriendAutoDecFlag(flag)
	ScoietyData.Instance:SetIsAutoDef(flag)
end

----------------------------------------------------------------------------
--ScrollerFriendCell 		好友滚动条格子
----------------------------------------------------------------------------

ScrollerFriendCell = ScrollerFriendCell or BaseClass(BaseCell)

function ScrollerFriendCell:__init()
	self.avatar_key = 0

	self.role_name = self:FindVariable("Name")
	self.intimacy = self:FindVariable("Intimacy")
	self.intimacy_lev = self:FindVariable("IntimacyLev")
	self.lev = self:FindVariable("Lev")
	self.prof = self:FindVariable("Prof")
	self.zhanli = self:FindVariable("ZhanLi")
	self.gray = self:FindVariable("Gray")
	self.show_red_point = self:FindVariable("ShowRedPoint")

	self.gift_animator = self.root_node:GetComponent(typeof(UnityEngine.Animator))

	--头像UI
	self.show_image = self:FindVariable("ShowImage")
	self.image_res = self:FindVariable("ImageRes")
	self.raw_image_obj = self:FindObj("RawImage")

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
	self:ListenEvent("ClickSendGift", BindTool.Bind(self.OnClick, self))
end

function ScrollerFriendCell:__delete()
	if self.friend_view then
		self.friend_view = nil
	end
end

function ScrollerFriendCell:SetShowRedPoint(state)
	if self.data then
		self.show_red_point:SetValue(state and self.data.is_online)
	end
end

function ScrollerFriendCell:OnFlush()
	if not self.data or not next(self.data) then return end

	local flower_state = ScoietyData.Instance:GetFlowerTimes()
	if self.data.is_online == 1 and RemindManager.Instance:GetRemind(RemindName.ScoietyOtherFriend) > 0 and flower_state then
		self.show_red_point:SetValue(true)
	else
		self.show_red_point:SetValue(false)
	end

	self.role_name:SetValue(self.data.gamename)

	local role_id = self.data.user_id

	local function download_callback(path)
		if nil == self.raw_image_obj or IsNil(self.raw_image_obj.gameObject) then
			return
		end
		if self.data.user_id ~= role_id then
			return
		end
		local avatar_path = path or AvatarManager.GetFilePath(role_id, true)
		self.raw_image_obj.raw_image:LoadSprite(avatar_path,
		function()
			if self.data.user_id ~= role_id then
				return
			end
			self.show_image:SetValue(false)
		end)
	end
	CommonDataManager.NewSetAvatar(role_id, self.show_image, self.image_res, self.raw_image_obj, self.data.sex, self.data.prof, false, download_callback)

	local level_des = PlayerData.GetLevelString(self.data.level)
	self.lev:SetValue(level_des)
	self.prof:SetValue(PlayerData.GetProfNameByType(self.data.prof, self.data.is_online ~= 1))
	self.zhanli:SetValue(self.data.capability)

	local intimacy_list = ScoietyData.Instance:GetIntimacyCfg()
	local intimacy_lev = 0
	for k, v in ipairs(intimacy_list) do
		if self.data.intimacy >= v.need_intimacy then
			intimacy_lev = v.level
		end
	end
	self.intimacy_lev:SetValue(intimacy_lev)
	self.intimacy:SetValue(self.data.intimacy)

	if self.data.is_online ~= 1 then
		self.gray:SetValue(true)
	else
		self.gray:SetValue(false)
	end
	-- GlobalTimerQuest:AddDelayTimer(function()
	-- 	self.gift_animator:SetBool("start_ani", self.data.is_online == 1)
	-- end, 0)

	-- 刷新选中特效
	local select_index = self.friend_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function ScrollerFriendCell:ClickItem()
	self.root_node.toggle.isOn = true
	self.friend_view:SetSelectIndex(self.index)

	local function canel_callback()
		if self.friend_view then
			self.friend_view:SetSelectIndex(0)
			self.root_node.toggle.isOn = false
		end
	end

	local click_obj = self.friend_view.scroller
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.gamename, click_obj, canel_callback)
end