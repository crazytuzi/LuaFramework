GuildRedPacketView = GuildRedPacketView or BaseClass(BaseView)
local COLUMN = 3
function GuildRedPacketView:__init()
	self.ui_config = {"uis/views/guildview_prefab","GuildRedPackerView"}
end

-- 仙盟红包
function GuildRedPacketView:LoadCallBack()
	self.jilu_cell_list = {}
	self.jilu_list = self:FindObj("JiLuList")
	local list_delegate = self.jilu_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfJiLuCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshJiLuCell, self)

	self.red_pocket_cell_list = {}
	self.red_pocket_list = self:FindObj("RedPacketList")
	local list_delegate = self.red_pocket_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ListenEvent("OnClickRedPocketTips", BindTool.Bind(self.OnClickRedPocketTips, self))
	self:ListenEvent("OnClickCloseHandler", BindTool.Bind(self.OnClickCloseHandler, self))
end

function GuildRedPacketView:OpenCallBack()
	GuildCtrl.Instance:SendGuildRedPocketOperate()
end

function GuildRedPacketView:GetNumberOfJiLuCells()
	local red_pocket_info = GuildData.Instance:GetRedPocketListInfo()
	return #red_pocket_info
end

function GuildRedPacketView:RefreshJiLuCell(cell, data_index)
	local record_item = self.jilu_cell_list[cell]
	if record_item == nil then
		record_item = RedPocketJiLuItemRender.New(cell.gameObject)
		self.jilu_cell_list[cell] = record_item
	end
	local red_pocket_info = GuildData.Instance:GetJiluList()
	record_item:SetData(red_pocket_info[data_index + 1])
end

function GuildRedPacketView:GetNumberOfCells()
	local new_data = GuildData.Instance:GetRedPocketListInfoPrune()
	return math.ceil(#new_data/COLUMN)
end

function GuildRedPacketView:RefreshCell(cell, data_index)
	local group_cell = self.red_pocket_cell_list[cell]
	if not group_cell then
		group_cell = RedPacketGroupCell.New(cell.gameObject)
		self.red_pocket_cell_list[cell] = group_cell
	end

	local new_data = GuildData.Instance:GetRedPocketListInfoPrune()
	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		local data = new_data[index]
		group_cell:SetActive(i, data ~= nil)
		group_cell:SetData(i, data)
		group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function GuildRedPacketView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end
	GuildData.Instance:SetSaveRedPocketInfo(data)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if data.status == GUILD_RED_POCKET_STATUS.UN_DISTRIBUTED and role_id ~= data.owner_role_id then
		GuildCtrl.Instance:SendChatRedPaperReq(data.red_paper_index)
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Guild.RenPocketTips)
		return
	elseif data.status == GUILD_RED_POCKET_STATUS.DISTRIBUTED then    -- 获取红包
		if data.is_fetch < 1 then
			HongBaoCtrl.Instance:SendRedPaperFetchReq(data.id)
		end
		HongBaoCtrl.Instance:SendRedPaperQueryDetailReq(data.id)
	elseif data.status == GUILD_RED_POCKET_STATUS.DISTRIBUTE_OUT then   -- 查看红包状态
		HongBaoCtrl.Instance:SendRedPaperQueryDetailReq(data.id)
	end
	GuildCtrl.Instance:OpenGuildRedPacketView()
end

function GuildRedPacketView:ReleaseCallBack()
	self.jilu_list = nil
	self.red_pocket_list = nil
	for k,v in pairs(self.red_pocket_cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.red_pocket_cell_list = {}
	for k,v in pairs(self.jilu_cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.jilu_cell_list = {}
end

function GuildRedPacketView:OnFlush()
	self.jilu_list.scroller:ReloadData(0)
	-- self.red_pocket_list.scroller:ReloadData(0)
	self.red_pocket_list.scroller:RefreshActiveCellViews()
end

function GuildRedPacketView:OnClickCloseHandler()
	self:Close()
end

function GuildRedPacketView:OnClickRedPocketTips()
	TipsCtrl.Instance:ShowHelpTipView(180)
end

-------------------RedPacketGroupCell-----------------------
RedPacketGroupCell = RedPacketGroupCell or BaseClass(BaseCell)
function RedPacketGroupCell:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = RedPocketGridItemRender.New(self:FindObj("Item" .. i))
		table.insert(self.item_list, bag_item)
	end
end

function RedPacketGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function RedPacketGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function RedPacketGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function RedPacketGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end


--RedPocketGridItemRender
----------------------------------------------------------------------------
RedPocketGridItemRender = RedPocketGridItemRender or BaseClass(BaseCell)
function RedPocketGridItemRender:__init()	
	self.state_img = self:FindVariable("state_img")
	self.lbl_tips = self:FindVariable("lbl_tips")
	self.lbl_desc = self:FindVariable("lbl_desc")
	self.lbl_role_name = self:FindVariable("lbl_role_name")

	self.image_obj = self:FindObj("RoleImage")
	self.raw_image_obj = self:FindObj("RawImage")

	self.image_res = self:FindVariable("ImageRes")
	self.rawimage_res = self:FindVariable("RawImageRes")
	self.show_red_point = self:FindVariable("show_red_point")
	self.show_line = self:FindVariable("show_line")
	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function RedPocketGridItemRender:__delete()
	self.state_img = nil
	self.lbl_tips = nil
	self.lbl_desc = nil
	self.lbl_role_name = nil
	self.image_obj = nil
	self.raw_image_obj = nil
	self.image_res = nil
	self.rawimage_res = nil
	self.show_red_point = nil
	self.show_line = nil
end

function RedPocketGridItemRender:OnFlush()
	if not self.data or not next(self.data) then return end
	self.lbl_role_name:SetValue(self.data.owner_role_name)
	AvatarManager.Instance:SetAvatarKey(self.data.owner_role_id, self.data.avatar_key_big, self.data.avatar_key_small)
	if self.data.avatar_key_small == 0 then
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		self.image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if not self.image_obj or IsNil(self.image_obj.gameObject) or not self.raw_image_obj or IsNil(self.raw_image_obj.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(self.data.owner_role_id, false)
			end
			self.raw_image_obj.raw_image:LoadSprite(path, function ()
				if self.data.avatar_key_small == 0 then
					self.image_obj.gameObject:SetActive(true)
					self.raw_image_obj.gameObject:SetActive(false)
					return
				end
				self.image_obj.gameObject:SetActive(false)
				self.raw_image_obj.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(self.data.owner_role_id, false, callback)
	end

	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local red_pocket_cfg = GuildData.Instance:GetRedPocketListDesc(self.data.red_paper_seq)
	self.lbl_desc:SetValue(red_pocket_cfg.descript)
	self.show_red_point:SetValue(false)
	self.show_line:SetValue(false)
	self.lbl_tips:SetValue("")
	if self.data.status == GUILD_RED_POCKET_STATUS.UN_DISTRIBUTED and role_id ~= self.data.owner_role_id then -- 别人未发放
		self.state_img:SetAsset(ResPath.GetGuildImg("img_red_nosend"))
		self.lbl_tips:SetValue(Language.Guild.GuildHongBaoDes1)
		self.show_line:SetValue(true)
	elseif self.data.status == GUILD_RED_POCKET_STATUS.UN_DISTRIBUTED and role_id == self.data.owner_role_id then
		self.state_img:SetAsset(ResPath.GetGuildImg("img_red_send"))	-- 自己发
		self.lbl_tips:SetValue(Language.Guild.GuildHongBaoDes2)
	elseif self.data.status == GUILD_RED_POCKET_STATUS.DISTRIBUTED and self.data.is_fetch == 0 then --领取
		self.state_img:SetAsset(ResPath.GetGuildImg("img_red_open"))
		self.lbl_tips:SetValue(Language.Guild.GuildHongBaoDes3)
	elseif self.data.is_fetch > 0 then  --已领取
		self.state_img:SetAsset(ResPath.GetGuildImg("img_red_noopen"))
		self.lbl_tips:SetValue(Language.Guild.GuildHongBaoDes4)
		self.show_red_point:SetValue(true)
	elseif self.data.status == GUILD_RED_POCKET_STATUS.DISTRIBUTE_OUT then                    --已抢的红包
		self.state_img:SetAsset(ResPath.GetGuildImg("img_red_noopen"))
		self.lbl_tips:SetValue(Language.Guild.GuildHongBaoDes4)
		self.show_red_point:SetValue(true)
	end

	if self.data.status == GUILD_RED_POCKET_STATUS.UN_DISTRIBUTED and role_id == self.data.owner_role_id then
		-- self.show_red_point:SetValue(true)
	end
end

--RedPocketJiLuItemRender
----------------------------------------------------------------------------
RedPocketJiLuItemRender = RedPocketJiLuItemRender or BaseClass(BaseCell)
function RedPocketJiLuItemRender:__init()	
	self.rich_jilu_desc = self:FindVariable("rich_jilu_desc")
end

function RedPocketJiLuItemRender:__delete()
	self.rich_jilu_desc = nil
end

function RedPocketJiLuItemRender:OnFlush()
	if not self.data then return end

	local history_params = os.date("*t", self.data.create_timestamp - 86400)
	mount = string.format(Language.Common.XXMXXD, history_params.month, history_params.day)
	day = string.format(Language.Common.XXHXXM, history_params.hour, history_params.min)

	local time = "【" .. mount.. day .. "】"
	local red_pocket_cfg = GuildData.Instance:GetRedPocketListDesc(self.data.red_paper_seq)
	local red_desc = string.format(Language.Guild.RenPocketListTips, time, self.data.owner_role_name, red_pocket_cfg.name, red_pocket_cfg.bind_gold)
	self.rich_jilu_desc:SetValue(red_desc)
end