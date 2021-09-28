GuildRedPacketTips = GuildRedPacketTips or BaseClass(BaseView)

function GuildRedPacketTips:__init()
	self.ui_config = {"uis/views/guildview_prefab","GuildHongBaoDetailView"}
	self.red_pocket_num = 10
end

function GuildRedPacketTips:__delete()

end

function GuildRedPacketTips:ReleaseCallBack()
	if next(self.cell_list) then
		for _,v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.cell_list = {}
	end
	self.image_obj = nil
	self.raw_image_obj = nil
	self.image_res = nil
	self.rawimage_res = nil
	self.red_pocket_list = nil
	self.is_send = nil
	self.mine_gold = nil
	self.have_mine = nil
	self.have_next = nil
	self.from_name = nil
	self.money_text = nil
	self.red_count = nil
	self.red_pocket_num = 10
	self.red_pocket_max_num = 0
end

function GuildRedPacketTips:LoadCallBack()
	self.is_send = self:FindVariable("IsSend")
	self.mine_gold = self:FindVariable("mine_gold")
	self.have_mine = self:FindVariable("have_mine")
	self.have_next = self:FindVariable("have_next")
	self.from_name = self:FindVariable("FromName")
	self.money_text = self:FindVariable("MoneyText")

	self.red_count = self:FindVariable("red_count")
	self.red_count:SetValue(self.red_pocket_num)
	-- self.count_input = self:FindObj("CountInput")			--红包个数
	self.image_obj = self:FindObj("image_obj")
	self.raw_image_obj = self:FindObj("raw_image_obj")

	self.image_res = self:FindVariable("image_res")
	self.rawimage_res = self:FindVariable("rawimage_res")


	self.cell_list = {}
	self.red_pocket_list = self:FindObj("Panel4List")
	local list_delegate = self.red_pocket_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ListenEvent("OnClickCount", BindTool.Bind(self.OnInputClickHandler, self))
	self:ListenEvent("OnClickSend", BindTool.Bind(self.OnClickSend, self))
	self:ListenEvent("OnClickNext", BindTool.Bind(self.OnClickNext, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
end


function GuildRedPacketTips:GetNumberOfCells()
	local fetch_info_list = GuildData.Instance:GetRedPocketDistributeInfo()
	return #fetch_info_list
end

function GuildRedPacketTips:RefreshCell(cell, data_index)
	local decs_item = self.cell_list[cell]
	if decs_item == nil then
		decs_item = RedPocketListItemRender.New(cell.gameObject)
		self.cell_list[cell] = decs_item
	end
	local fetch_info_list = GuildData.Instance:GetRedPocketDistributeInfo()
	decs_item:SetData(fetch_info_list[data_index + 1])
end

function GuildRedPacketTips:ShowIndexCallBack()
	self:Flush()
end

function GuildRedPacketTips:OnFlush()
	local info = GuildData.Instance:GetSaveRedPocketInfo()
	local red_pocket_data = GuildData.Instance:GetRedPocketInfo(info.id)
	if nil ~= info then
		local cfg = GuildData.Instance:GetRedPocketListDesc(info.red_paper_seq)
		self.red_pocket_max_num = cfg.bind_gold
		if info.status == GUILD_RED_POCKET_STATUS.DISTRIBUTED or info.status == GUILD_RED_POCKET_STATUS.DISTRIBUTE_OUT then --显示列表
			self.is_send:SetValue(false)
			self.from_name:SetValue(info.owner_role_name)
			
			AvatarManager.Instance:SetAvatarKey(info.owner_role_id, info.avatar_key_big, info.avatar_key_small)
			if info.avatar_key_small == 0 then
				self.image_obj.gameObject:SetActive(true)
				self.raw_image_obj.gameObject:SetActive(false)
				local bundle, asset = AvatarManager.GetDefAvatar(info.prof, false, info.sex)
				self.image_res:SetAsset(bundle, asset)
			else
				local function callback(path)
					if IsNil(self.image_obj.gameObject) or IsNil(self.raw_image_obj.gameObject) then
						return
					end
					if path == nil then
						path = AvatarManager.GetFilePath(info.owner_role_id, false)
					end
					self.raw_image_obj.raw_image:LoadSprite(path, function ()
						if info.avatar_key_small == 0 then
							self.image_obj.gameObject:SetActive(true)
							self.raw_image_obj.gameObject:SetActive(false)
							return
						end
						self.image_obj.gameObject:SetActive(false)
						self.raw_image_obj.gameObject:SetActive(true)
					end)
				end
				AvatarManager.Instance:GetAvatar(info.owner_role_id, false, callback)
			end
			self.red_pocket_list.scroller:ReloadData(0)
			local own_red = GuildData.Instance:GetOwnRedPocket()
			if own_red then
				self.have_mine:SetValue(true)
				self.money_text:SetValue(own_red.gold_num)
			else
				self.have_mine:SetValue(false)
			end 
			local next_id = GuildData.Instance:GetNextRedId()
			self.have_next:SetValue(next_id ~= -1)

			-- local desc = string.format(Language.Guild.FetchListTips, red_pocket_data.fetch_count, info.total_count, cfg.bind_gold)
			-- RichTextUtil.ParseRichText(self.node_t_list.rich_fetch_tips.node, desc, 18)
		else
			self.is_send:SetValue(true)
			self.mine_gold:SetValue(self.red_pocket_max_num)
		end
	end
end

function GuildRedPacketTips:OnInputClickHandler()
	local guildvo = GuildDataConst.GUILDVO
	local red_num = math.min(self.red_pocket_max_num, guildvo.max_member_count)
	TipsCtrl.Instance:OpenCommonInputView(0, BindTool.Bind(self.CountValueChange, self), nil, red_num)
end

function GuildRedPacketTips:CountValueChange(str)
	if str == "" then
		return
	end
	local num = tonumber(str)
	if num < 10 then num = 10 end
	self.red_pocket_num = num
	self.red_count:SetValue(self.red_pocket_num)
end

function GuildRedPacketTips:OnClickSend()
	local info = GuildData.Instance:GetSaveRedPocketInfo()
	if info and next(info) then
		GuildCtrl.Instance:SendCreateGuildRedPaperReq(info.red_paper_seq, self.red_pocket_num, info.red_paper_index)
		self:Close()
	end
end

function GuildRedPacketTips:OnClickNext()
	local next_id = GuildData.Instance:GetNextRedId()
	HongBaoCtrl.Instance:SendRedPaperFetchReq(next_id)
	HongBaoCtrl.Instance:SendRedPaperQueryDetailReq(next_id)
end

function GuildRedPacketTips:OnClickClose()
	self:Close()
end

-----------------------------------------------------------
RedPocketListItemRender = RedPocketListItemRender or BaseClass(BaseCell)

function RedPocketListItemRender:__init()
	self.lbl_name = self:FindVariable("Name")
	self.lbl_red_gold = self:FindVariable("Score")
	self.biggest = self:FindVariable("IsLuck")
end

function RedPocketListItemRender:__delete()
	self.lbl_name = nil
	self.lbl_red_gold = nil
	self.biggest = nil
end

function RedPocketListItemRender:OnFlush()
	if not self.data then return end
	self.lbl_name:SetValue(self.data.name)
	self.lbl_red_gold:SetValue(self.data.gold_num)
	local zuijia_id = GuildData.Instance:GetRedPocketZuiJia()
	self.biggest:SetValue(zuijia_id == self.data.uid)
end