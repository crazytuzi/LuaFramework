ScoietyMailView = ScoietyMailView or BaseClass(BaseRender)
function ScoietyMailView:__init()
	self.item_list = {}
	self.cell_list = {}
	
end

function ScoietyMailView:LoadCallBack()
	self.select_data = {}

	--获取变量
	self.recv_time = self:FindVariable("GetTime")
	self.recv_time:SetValue("")
	self.have_item = self:FindVariable("HaveItem")
	self.write_text = self:FindVariable("WriteText")

	-- 获取UI
	self.rich_text = self:FindObj("RichText")
	self.scroller = self:FindObj("MailList")

	-- 监听事件
	self:ListenEvent("ClickDelRead",BindTool.Bind(self.ClickDelRead, self))
	self:ListenEvent("ClickGetAllReward",BindTool.Bind(self.ClickGetAllReward, self))
	self:ListenEvent("ClickGetReward",BindTool.Bind(self.ClickGetReward, self))
	self:ListenEvent("ClickWrite",BindTool.Bind(self.ClickWrite, self))
	self:ListenEvent("ClickDel",BindTool.Bind(self.ClickDel, self))
	ScoietyData.Instance:DelMailDetail()

	--获取变量
	-- self.content = self:FindVariable("Content")

	-- 生成滚动条
	self:ClearSelect()
	self.cell_list = {}
	self.scroller_data = {}
	local scroller_delegate = self.scroller.list_simple_delegate
	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local mail_cell = self.cell_list[cell]
		if mail_cell == nil then
			mail_cell = ScrollerMailCell.New(cell.gameObject)
			mail_cell.root_node.toggle.group = self.scroller.toggle_group
			mail_cell.mail_view = self
			self.cell_list[cell] = mail_cell
		end
		mail_cell:SetIndex(data_index)
		mail_cell:SetData(self.scroller_data[data_index])

		if 1 == data_index and self.select_index == nil then
			mail_cell:ClickItem()
		end
	end

	

	for i = 1, 5 do
		local item_cell = ItemCell.New(self:FindObj("Item" .. i))
		item_cell:SetData(nil)
		item_cell:SetActive(false)
		table.insert(self.item_list, item_cell)
	end
end

function ScoietyMailView:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for k, v in ipairs(self.item_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.item_list = {}
end

function ScoietyMailView:OpenCallBack()
	self:ClearSelect()
	ScoietyData.Instance:DelMailDetail()
end

function ScoietyMailView:ClearItem()
	for k, v in ipairs(self.item_list) do
		if v then
			v:SetData(nil)
			v:SetActive(false)
		end
	end
end

function ScoietyMailView:CloseMailView()
	self:ClearSelect()
	ScoietyData.Instance:DelMailDetail()
end

function ScoietyMailView:ItemClick(cell)
	local data = cell:GetData()
	TipsCtrl.Instance:OpenItem(data)
end

function ScoietyMailView:ClickDelRead()
	local mail_list = ScoietyData.Instance:GetMailList()
	if not mail_list.mails or not next(mail_list.mails) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NoMail)
		--self:SetContent("")
		return
	end
	ScoietyCtrl.Instance:MailCleanReq()
end

function ScoietyMailView:ClickGetAllReward()
	local mail_list = ScoietyData.Instance:GetMailList()
	if not mail_list.mails or not next(mail_list.mails) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NoMail)
		self.rich_text.rich_text:Clear()
		return
	end
	ScoietyCtrl.Instance:MailOneKeyFetchAttachmentReq()
end

function ScoietyMailView:ClickWrite()
	ScoietyData.Instance:SetSendName("")
	ScoietyCtrl.Instance:ShowWriteMailView()
	ScoietyCtrl.Instance:SendCSRoleLoginTimeSeq()
end

function ScoietyMailView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ScoietyMailView:GetSelectIndex()
	return self.select_index or 0
end

function ScoietyMailView:SetContent(des)
	if self.rich_text and des == "" then
		self.rich_text.rich_text:Clear()
		self.recv_time:SetValue(des)
		self.have_item:SetValue(false)
	end
end

function ScoietyMailView:SetSelectMailIndex(index)
	self.mail_index = index
end

function ScoietyMailView:ClickGetReward()
	if not self.select_index then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NoSelect)
		return
	end
	if not ScoietyData.Instance:IsNotGet(self.mail_index) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NoFuJian)
		return
	end
	local param_t = {}
	param_t.mail_index = self.mail_index
	ScoietyCtrl.Instance:MailFetchAttachmentReq(param_t)
end

function ScoietyMailView:ClickDel()
	if not self.select_index then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NoSelect)
		return
	end
	if ScoietyData.Instance:IsNotGet(self.mail_index) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.CanNotDelwithFujian)
		return
	end

	ScoietyCtrl.Instance:MailDeleteReq(self.mail_index)

	-- table.remove(self.scroller_data, self.select_index)
end

function ScoietyMailView:ClearSelect()
	-- 清除选中
	self.select_index = nil
	self.select_data = {}
	self.item_count = 0
	self:SetContent("")
	if self.write_text then
		self.write_text:SetValue(Language.Society.WriteText1)
	end
	self:ClearItem()
end

function ScoietyMailView:SetSelectData(data)
	self.select_data = data
end

function ScoietyMailView:SetActive(value)
	self.root_node:SetActive(value)
end

function ScoietyMailView:OnFlush()
	self:FlushMailView()
end

function ScoietyMailView:FlushMailView()
	-- ScoietyCtrl.Instance:MailGetListReq()
	self:FlushLeft()
	self:FlushRight()
end

function ScoietyMailView:FlushLeft()
	self:ClearSelect()
	local mail_index_list = ScoietyData.Instance:GetMailIndexList()
	local main_list = {}
	local main_list_red = {}
	local main_list_nored = {}
	for k, v in ipairs(mail_index_list) do
		local mail = ScoietyData.Instance:GetMailByIndex(v)
		if ScoietyData.Instance:IsNotGet(v) then
		    table.insert(main_list_red, mail)
		else
			table.insert(main_list_nored,mail)
	    end
	end	

	local function SortMailByTime(a,b)
		return a.mail_status.recv_time>b.mail_status.recv_time
	end 
    table.sort( main_list_red,SortMailByTime)
	table.sort( main_list_nored, SortMailByTime)

    for i,v in ipairs(main_list_red) do
    	table.insert(main_list,v)
    end
    for i,v in ipairs(main_list_nored) do
    	table.insert(main_list,v)
    end

	self.scroller_data = main_list
	if self.scroller then
		self.scroller.scroller:ReloadData(0)
		if self.scroller.scroller.isActiveAndEnabled then
			self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function ScoietyMailView:SetItemData(data_list)
	if data_list then
		local temp_list = {}
		self.item_count = 0
		for k, v in ipairs(data_list) do
			if v.item_id ~= 0 then
				table.insert(temp_list, v)
			end
		end
		for k, v in ipairs(self.item_list) do
			-- v:SetData(nil)
			-- v:SetInteractable(false)
			if temp_list[k] then
				self.item_count = self.item_count + 1
				v:SetActive(true)
				v:SetNotShowRedPoint(true)
				v:SetData(temp_list[k])
				v:SetInteractable(true)
			else
				v:SetActive(false)
				v:SetData(nil)
				v:SetInteractable(false)
			end
			v:SetHighLight(false)
		end
	end
end

function ScoietyMailView:SetSpecialItem(content_info)
	if self.item_count >= 5 then
		return
	end
	for k, v in ipairs(content_info.virtual_item_list) do 										--k为1到15
		for i, j in pairs(ScoietyData.MailVirtualItem) do 										--i为0到14
			if i == k - 1 then
				if v > 0 then
					local item_data = {}
					self.item_count = self.item_count + 1
					item_data.item_id = j
					item_data.num = v
					if self.item_list[self.item_count] then
						self.item_list[self.item_count]:SetNotShowRedPoint(true)
						self.item_list[self.item_count]:SetActive(true)
						self.item_list[self.item_count]:SetData(item_data)
						-- if j == FuBenDataExpItemId.ItemId then
						-- 	self.item_list[self.item_count]:SetInteractable(false)
						-- else
						-- 	self.item_list[self.item_count]:SetInteractable(true)
						-- end
					end
				end
				if self.item_count >= 5 then
					return
				end
			end
		end
	end

	local function add_item(item_id, num)
		self.item_count = self.item_count + 1
		local item_data = {}
		item_data.item_id = item_id
		item_data.num = num
		if self.item_list[self.item_count] then
			self.item_list[self.item_count]:SetActive(true)
			self.item_list[self.item_count]:SetNotShowRedPoint(true)
			self.item_list[self.item_count]:SetData(item_data)
			self.item_list[self.item_count]:SetInteractable(true)
		end
	end

	if content_info.coin > 0 then
		add_item(ScoietyData.MailVirtualItem[MAIL_VIRTUAL_ITEM_COIN], content_info.coin)
	end

	if content_info.coin_bind > 0 then
		add_item(ScoietyData.MailVirtualItem[MAIL_VIRTUAL_ITEM_BIND_COIN], content_info.coin_bind)
	end

	if content_info.gold > 0 then
		add_item(ScoietyData.MailVirtualItem[MAIL_VIRTUAL_ITEM_GOLD], content_info.gold)
	end

	if content_info.gold_bind > 0 then
		add_item(ScoietyData.MailVirtualItem[MAIL_VIRTUAL_ITEM_BIND_GOLD], content_info.gold_bind)
	end

	if self.item_count > 5 then
		self.item_count = 5
	end
end

function ScoietyMailView:FlushRight()
	local detail_info = ScoietyData.Instance:GetMailDetail()
	local content_info = detail_info.content_param

	if content_info then
		RichTextUtil.ParseRichText(self.rich_text.rich_text, content_info.contenttxt, 23, "#84410AFF", nil, nil, true)
		self:SetItemData(content_info.item_list)
		self:SetSpecialItem(content_info)
	end

	if next(self.select_data) then
		local mail_status = self.select_data.mail_status
		local recv_time = os.date("%Y-%m-%d  %X", mail_status.recv_time)
		self.recv_time:SetValue(recv_time)
		if ScoietyData.Instance:GetIsPriviteMail() then
			self.write_text:SetValue(Language.Society.WriteText2)
		else
			self.write_text:SetValue(Language.Society.WriteText1)
		end
	end

	if self.item_count > 0 then
		self.have_item:SetValue(true)
	else
		self.have_item:SetValue(false)
	end
end

----------------------------------------------------------------------------
--ScrollerMailCell 		邮件滚动条格子
----------------------------------------------------------------------------

ScrollerMailCell = ScrollerMailCell or BaseClass(BaseCell)

function ScrollerMailCell:__init()
	-- 获取变量
	--self.title_text = self:FindVariable("TitleText")
	self.text = self:FindVariable("Text")
	--self.title_bg = self:FindVariable("TitleBg")
	self.mail_icon_fal = self:FindVariable("Mail_Icon_Fal")

	-- 获取UI
	self.point = self:FindObj("Point")
	--self.title_img = self:FindObj("TitleBg")
	self.text_obj = self:FindObj("Text")
	self.text1_obj = self:FindObj("Text1")
	self.text2_obj = self:FindObj("Text2")
	self.gift_img = self:FindVariable("Gift")
	self.whether_read = self:FindVariable("Is_Read")
	self.icon = self:FindObj("Icon")
	self.icon_res = self:FindVariable("IconRes")

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
	self.subject = ""
end

function ScrollerMailCell:__delete()

end

function ScrollerMailCell:OnFlush()
	if not self.data or not next(self.data) then return end
	self.mail_status = self.data.mail_status

	--local title_text = ""
	--local title_bg = "New_TitleBg1"
	
	--local text_color = Color.New(1, 1, 1, 1)
	local icon_str = "official"
	if self.mail_status.kind == MAIL_TYPE.MAIL_TYPE_PERSONAL then
		self.subject = self.data.subject
		icon_str = "private"
	elseif self.mail_status.kind == MAIL_TYPE.MAIL_TYPE_SYSTEM then

		if self.mail_status.is_read == 1 then
			self.subject = ToColorStr(Language.Society.TitleSystem, '#84410AFF')
		else
			self.subject = ToColorStr(Language.Society.TitleSystem, TEXT_COLOR.BLUE)
		end

	elseif self.mail_status.kind == MAIL_TYPE.MAIL_TYPE_GUILD then
		self.subject = Language.Society.TitleGuild
	elseif self.mail_status.kind == MAIL_TYPE.MAIL_TYPE_CHONGZHI then

		if self.mail_status.is_read == 1 then
			self.subject = ToColorStr(Language.Society.TitleGuangFang, '#84410AFF')
		else
			self.subject = ToColorStr(Language.Society.TitleGuangFang, TEXT_COLOR.BLUE)
		end

	end
	-- self.title_text:SetValue(title_text)
	self.text:SetValue(self.subject)
	--self.text_obj.text.color = text_color					--控制邮件字体颜色

	-- self.title_bg:SetAsset(ResPath.GetImages(title_bg))
	if self.icon_res ~= nil then
		local bundle, asset = ResPath.GetImages("icon_mail_" .. icon_str)
		self.icon_res:SetAsset(bundle, asset)
	end

	--控制邮件字体颜色
	if self.mail_status.is_read == 1 then
		self:SetGray(true)
		--self.whether_read:SetValue(true)
	else
		self:SetGray(false)
		--self.whether_read:SetValue(false)
	end

	local bundle, asset = ResPath.GetMaillScoietyIcon(1)
	local bundle1, asset1 = ResPath.GetMaillScoietyIcon(0)
	if self.data.has_attachment == 1 then
		self.mail_icon_fal:SetAsset(bundle, asset)
		self:SetPointVisible(true)
	else
		self.mail_icon_fal:SetAsset(bundle1, asset1)
		self:SetPointVisible(false)
	end
	-- 刷新选中特效
	local select_index = self.mail_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif not self.root_node.toggle.isOn and select_index == self.index then
		self.root_node.toggle.isOn = true
	end

end

function ScrollerMailCell:ClickItem()
	self.root_node.toggle.isOn = true
	if self.index == self.mail_view:GetSelectIndex() then
		return
	end
	self.mail_status.is_read = 1
	self:SetGray(true)					--控制邮件字体颜色
	self.mail_view:SetSelectData(self.data)
	self.mail_view:SetSelectIndex(self.index)
	self.mail_view:SetSelectMailIndex(self.data.mail_index)
	if self.mail_status.kind == MAIL_TYPE.MAIL_TYPE_PERSONAL then
		ScoietyData.Instance:SetIsPriviteMail(true)
		ScoietyData.Instance:SetSendName(self.mail_status.sender_name)
	else
		ScoietyData.Instance:SetIsPriviteMail(false)
		ScoietyData.Instance:SetSendName("")
	end
	--发送协议
	ScoietyCtrl.Instance:MailReadReq(self.data.mail_index)

	if self.mail_status.is_read == 1 then
		self:SetGray(true)
		--self.whether_read:SetValue(true)
	else
		self:SetGray(false)
		--self.whether_read:SetValue(false)
	end

	self:Flush()
end

function ScrollerMailCell:SetPointVisible(value)
	self.point:SetActive(value)
	self.gift_img:SetValue(value)
end

function ScrollerMailCell:SetGray(value)
	if value then
		self.text:SetValue(ToColorStr(self.subject, '#84410AFF'))
		self.text_obj.grayscale.GrayScale = 255
		self.text1_obj.grayscale.GrayScale = 255
		self.text2_obj.grayscale.GrayScale = 255
		-- self.icon.grayscale.GrayScale = 255
		self.whether_read:SetValue(true)
	else
		self.text_obj.grayscale.GrayScale = 0
		self.text1_obj.grayscale.GrayScale = 0
		self.text2_obj.grayscale.GrayScale = 0
		self.whether_read:SetValue(false)
		-- self.icon.grayscale.GrayScale = 0
	end
end