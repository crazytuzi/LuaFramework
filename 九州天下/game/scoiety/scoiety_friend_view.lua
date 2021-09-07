ScoietyFriendView = ScoietyFriendView or BaseClass(BaseRender)
function ScoietyFriendView:__init()
	self.cell_list = {}
end

function ScoietyFriendView:LoadCallBack()
	self:ListenEvent("ClickAddFriend",BindTool.Bind(self.ClickAddFriend, self))
	self:ListenEvent("ClickLotAdd",BindTool.Bind(self.ClickLotAdd, self))
	self:ListenEvent("ClickLotDel",BindTool.Bind(self.ClickLotDel, self))
	self:ListenEvent("ClickBlackList",BindTool.Bind(self.ClickBlackList, self))
	self:ListenEvent("ClickEmpty",BindTool.Bind(self.ClickEmpty, self))
	self:ListenEvent("OpenGiftRecord",BindTool.Bind(self.OpenGiftRecord, self))
	self:ListenEvent("ClickHelp",BindTool.Bind(self.ClickHelp, self))

	-- 生成滚动条
	
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

function ScoietyFriendView:OnFlush()
	self:FlushFriendView()
end

function ScoietyFriendView:FlushFriendView()
	self.scroller_data = ScoietyData.Instance:GetFriendInfo()
	self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
end


----------------------------------------------------------------------------
--ScrollerFriendCell 		好友滚动条格子
----------------------------------------------------------------------------

ScrollerFriendCell = ScrollerFriendCell or BaseClass(BaseCell)

function ScrollerFriendCell:__init()

	self.role_name = self:FindVariable("Name")
	self.last_online = self:FindVariable("LastOnline")
	--self.last_online_lev = self:FindVariable("IntimacyLev")
	self.lev = self:FindVariable("Lev")
	self.prof = self:FindVariable("Prof")
	self.zhanli = self:FindVariable("ZhanLi")
	self.gray = self:FindVariable("Gray")

	--头像UI
	self.image_obj = self:FindObj("RoleImage")
	self.raw_image_obj = self:FindObj("RawImage")
	self.send_gift_btn = self:FindObj("SendGiftBtn")

	self.image_res = self:FindVariable("ImageRes")
	self.rawimage_res = self:FindVariable("RawImageRes")

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
	self:ListenEvent("ClickSendGift", BindTool.Bind(self.ClickSendGift, self))
end

function ScrollerFriendCell:__delete()
	self.role_name = nil
	self.last_online = nil
	self.lev = nil
	self.prof = nil
	self.zhanli = nil
	self.gray = nil
	self.image_obj = nil
	self.raw_image_obj = nil
	self.send_gift_btn = nil
	self.image_res = nil
	self.rawimage_res = nil
end

function ScrollerFriendCell:ClickSendGift()
	ScoietyCtrl.Instance:SendGiftReq(self.data.user_id)
end

function ScrollerFriendCell:OnFlush()
	if not self.data or not next(self.data) then return end

	if self.data.gift_count and self.data.gift_count <= 0 then
		self.send_gift_btn:SetActive(true)
	elseif not self.data.gift_count then
		self.send_gift_btn:SetActive(true)
	else
		self.send_gift_btn:SetActive(false)
	end

	self.role_name:SetValue(CampData.Instance:GetCampNameByCampType(self.data.camp, true) .. self.data.gamename)


	--设置角色头像
	local avatar_key_small = AvatarManager.Instance:GetAvatarKey(self.data.user_id)
	if avatar_key_small == 0 then
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		-- self.image_obj.image:LoadSprite(bundle, asset)
		self.image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.image_obj.gameObject) or IsNil(self.raw_image_obj.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(self.data.user_id, false)
			end
			self.raw_image_obj.raw_image:LoadSprite(path, function ()
				if avatar_key_small == 0 then
					self.image_obj.gameObject:SetActive(true)
					self.raw_image_obj.gameObject:SetActive(false)
					return
				end
				self.image_obj.gameObject:SetActive(false)
				self.raw_image_obj.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(self.data.user_id, false, callback)
	end



	local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
	local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.lev:SetValue(level_des)
	--self.prof:SetValue(PlayerData.GetProfNameByType(self.data.prof, self.data.is_online ~= 1))--Language.Common.ProfName prof_type
	--self.prof:SetValue(PlayerData.GetProfNameByType(self.data.prof))
	self.prof:SetValue(Language.Common.ProfName[self.data.prof])
	self.zhanli:SetValue(self.data.capability)

	-- local intimacy_list = ScoietyData.Instance:GetIntimacyCfg()
	-- local intimacy_lev = 0
	-- for k, v in ipairs(intimacy_list) do
	-- 	if self.data.intimacy >= v.need_intimacy then
	-- 		intimacy_lev = v.level
	-- 	end
	-- end
	-- self.last_online_lev:SetValue(intimacy_lev)
	

	

	-- 刷新选中特效
	local select_index = self.friend_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end

	--好友最近上线时间
	local leave_time = math.ceil(TimeCtrl.Instance:GetServerTime()) - self.data.last_logout_timestamp
	--1为在线
	if self.data.is_online ~= 1 then
		self.gray:SetValue(true)
		self.last_online:SetValue(TimeUtil.LastDonateTime(leave_time))
	else
		self.gray:SetValue(false)
		self.last_online:SetValue(Language.Common.OnLine)
	end
end

function ScrollerFriendCell:ClickItem()
	self.root_node.toggle.isOn = true
	self.friend_view:SetSelectIndex(self.index)

	local function canel_callback()
		if self.friend_view ~= nil then
			self.friend_view:SetSelectIndex(0)
		end
		
		if self.root_node ~= nil then
			self.root_node.toggle.isOn = false
		end
	end

	local click_obj = self.friend_view.scroller
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.gamename, click_obj, canel_callback)
end