MailPanel = BaseClass(LuaUI)
function MailPanel:__init( container )
	self.ui = UIPackage.CreateObject("Mail","MailPanel")
	self.line = self.ui:GetChild("line")
	self.labelSender = self.ui:GetChild("labelSender")
	self.labelTheme = self.ui:GetChild("labelTheme")
	self.txtSender = self.ui:GetChild("txtSender")
	self.txtTheme = self.ui:GetChild("txtTheme")
	self.txtContent = self.ui:GetChild("txtContent")
	self.mailCon = self.ui:GetChild("mailCon")
	self.goodsCon = self.ui:GetChild("goodsCon")
	self.btnDel = self.ui:GetChild("btnDel")
	self.btnGet = self.ui:GetChild("btnGet")
	self.contentGroup = self.ui:GetChild("contentGroup")
	self.txtMailNum = self.ui:GetChild("txtMailNum")

	container:AddChild(self.ui)
	self:SetXY(150, 104)
	self:Config()
	self:InitEvent()
	self:Update()
end
function MailPanel:Config()
	self.model = EmailModel:GetInstance()
	self.selected = nil
	self.items = {} -- 邮件列表
	self.cells = {} -- 附件列表
	self.btnGet.visible = false
end
function MailPanel:InitEvent()
	self.btnDel.onClick:Add(function ( e )
		if self.selected then
			local data = self.selected.data
			if data and data.haveAttachment == 1 and data.haveReceiveAttachment == 0 then -- 是否含有附件
				UIMgr.Win_Confirm("注意", "您的邮件中含有附件物品，是否要删除？", "删除", "取消", 
				function()
					EmailController:GetInstance():C_DeleteMail(data.mailInboxID)
				end,nil)
			else
				EmailController:GetInstance():C_DeleteMail(data.mailInboxID)
			end
		end
	end)
	self.btnGet.onClick:Add(function ( e )
		if self.selected then
			EmailController:GetInstance():C_ReceiveAttachment(self.selected.data.mailInboxID)
		end
	end)
	self.mailCon.scrollPane.inertiaDisabled = false
	self.mailCon.scrollPane.onScrollEnd:Add(function ( e )
		if e.sender.isBottomMost then 
			EmailController:GetInstance():C_GetMailPageList()
		end
	end)
	self.handler1 = self.model:AddEventListener(EmailConst.DelEmail, function() self:RefreshMailNum() end)
	self.handler2 = self.model:AddEventListener(EmailConst.GetAfterDel, function() EmailController:GetInstance():C_GetMailPageList() end)
end

function MailPanel:Update()
	local model = self.model
	local dataList = model.emailList
	local items = self.items
	local item = nil

	local function callback( obj )
		if not obj then return end
		self:SelectItem(obj)
		if obj.data.state == 0 then
			EmailController:GetInstance():C_ReadMail( obj.id )
		end
	end
	for i,v in ipairs(dataList) do
		item = items[i]
		if item then
			item:SetData(v)
		else
			item = MailItem.New(self.mailCon, v)
			item:SetXY(0, (i-1)*116)
			item:SetClickCallback(callback)
			items[i] = item
		end
	end
	-- if self.selected ~= items[1] and #items ~= 0 then
	-- 	self:SelectItem(items[1])
	-- end
	if #items ~= 0 then
		for i,item in ipairs(items) do
			if item.data.state == 0 then
				self:SelectItem(item)
				break
			end
		end
	end
	if #items==0 then
		self.btnGet.visible = false
		self.txtSender.text = ""
		self.txtTheme.text = ""
		self.txtContent.text = ""
		for i,v in ipairs(self.cells) do
			v:Destroy()
		end
		self.cells = {}
		self.goodsCon.visible = false
	end
	self.contentGroup.visible = #items ~= 0
	self:RefreshMailNum()
end

function MailPanel:RefreshMailNum()
	local cfg = GetCfgData("constant"):Get(21)
	local totalNum = 0
	if cfg then
		totalNum = cfg.value
	end
	local str = StringFormat("邮件数量:{0}/{1}", self.model:GetCurNum(), totalNum)
	self.txtMailNum.text = str
end

function MailPanel:SelectItem( item )
	if self.selected then
		self.selected:SetSelected(false)
	end
	self.selected = item
	item:SetSelected(true)
	local data = item.data
	self.btnGet.visible = (data.haveAttachment == 1) and (data.haveReceiveAttachment == 0)
	self.txtSender.text = data.senderName
	self.txtTheme.text = data.theme
	self.txtContent.text = data.content

	for i,v in ipairs(self.cells) do
		v:Destroy()
	end
	self.cells = {}
	if data.haveAttachment == 1 and data.haveReceiveAttachment == 0 then -- 是否含有附件
		local goodsData = StringToTable(tostring(data.attachment))
		if goodsData then
			for i,v in ipairs(goodsData) do
				local cell = PkgCell.New(self.goodsCon)
				cell:SetXY((i-1)*90, 0)
				cell:SetDataByCfg( v[1], v[2], v[3], v[4] )
				self.cells[i] = cell
				cell:OpenTips( true, v[1]==GoodsVo.GoodType.equipment)
			end
		end
	end
	self.goodsCon.visible = data.haveAttachment == 1 and data.haveReceiveAttachment == 0
end

function MailPanel:UpdateList( id, isRemove )
	local num = 0
	local items = self.items
	for i,v in ipairs(items) do
		if v.id == id then
			if isRemove then
				if self.selected == v then
					for _,cell in ipairs(self.cells) do
						cell:Destroy()
					end
					self.btnGet.visible = false
					self.selected = nil
				end
				table.remove(items, i)
				self.goodsCon.visible = false
				v:Destroy()
			else
				v:Update()
				if self.selected == v then
					self.btnGet.visible = v.data.haveAttachment == 1 and v.data.haveReceiveAttachment == 0
					self.goodsCon.visible = v.data.haveAttachment == 1 and v.data.haveReceiveAttachment == 0
				end
			end
			break
		end
		num = i
	end
	if isRemove then
		for i = num+1, #items do
			local item = items[i]
			item:SetXY(0, (i-1)*116)
		end
	end
	if self.selected == nil and #items ~= 0 then
		self:SelectItem(items[1])
	end
	if #items==0 then
		self.btnGet.visible = false
		self.txtSender.text = ""
		self.txtTheme.text = ""
		self.txtContent.text = ""
		for i,v in ipairs(self.cells) do
			v:Destroy()
		end
		self.cells = {}
		self.goodsCon.visible = false
	end
	self.contentGroup.visible = #items ~= 0
end

function MailPanel:RemoveEvents()
	if self.model then
		self.model:RemoveEventListener(self.handler1)
		self.model:RemoveEventListener(self.handler2)
	end
end

function MailPanel:__delete()
	for i,v in ipairs(self.items) do
		v:Destroy()
	end
	if self.model then
		self.model:ResetQuitPanel()
	end
	self:RemoveEvents()
	self.selected = nil
	self.items = nil
end