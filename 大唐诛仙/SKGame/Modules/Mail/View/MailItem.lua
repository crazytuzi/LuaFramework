MailItem = BaseClass(LuaUI)
function MailItem:__init(root, data)
	self:RegistUI()
	root:AddChild(self.ui)
	self:Config()
	self:SetData(data)
end
function MailItem:RegistUI()
	self.ui = UIPackage.CreateObject("Mail","MailItem")
	self.bg = self.ui:GetChild("bg")
	self.txtDate = self.ui:GetChild("txtDate")
	self.delDay = self.ui:GetChild("delDay")
	self.delDay.visible = false
	self.icon = self.ui:GetChild("icon")
	self.title = self.ui:GetChild("title")
	self.line = self.ui:GetChild("line")
	self.selected = self.ui:GetChild("selected")
	self.imgLibao = self.ui:GetChild("imgLibao")
end

function MailItem:Config()
	self.readUrl = UIPackage.GetItemURL("Mail" ,"read")
	self.newUrl = UIPackage.GetItemURL("Mail" ,"new")
end

function MailItem:SetClickCallback( cb )
	self.ui.onClick:Add(function (e) cb(self) end)
end

function MailItem:SetSelected( bool )
	self.selected.visible = bool == true
end

function MailItem:SetData( data )
	self.data = data or {}
	self:Update()
end

function MailItem:Update()
	data = self.data
	self.id = data.mailInboxID
	self.txtDate.text = StringFormat("{0}", TimeTool.getYMD2(toLong(data.receiveTime or 0)))
	--self.delDay.text = StringFormat("{0}天",data.remainDays) 
	self:HasAttachment(data.haveAttachment == 1 and data.haveReceiveAttachment == 0) -- 是否领取附件
	self:SetAttachVisible(data.haveAttachment == 1)
	self.icon.url = data.state == 1 and self.readUrl or self.newUrl
	self.title.text = data.theme
end

function MailItem:HasAttachment(bool)
	if bool then
		self.imgLibao.icon = EmailConst.LibaoGuanbiUrl
	else
		self.imgLibao.icon = EmailConst.LibaoDakaiUrl
	end
end

function MailItem:SetAttachVisible(bool)
	self.imgLibao.visible = bool
end

function MailItem:__delete()
	self.data = nil
end