MailItem = MailItem or class("MailItem",BaseCloneItem)
local MailItem = MailItem

function MailItem:ctor(obj,parent_node,layer)
	MailItem.super.Load(self)
end

function MailItem:dctor()
	self.model:RemoveTabListener(self.events)
	self.model = nil
end

function MailItem:LoadCallBack()
	self.nodes = {
		"select",
		"mailIcon",
		"mailRead",
		"goodsIcon",
		"name",
		"time",
		"Image",
	}
	self:GetChildren(self.nodes)
	self.events = {}
	self.model = MailModel:GetInstance()
	self:AddEvent()
end

function MailItem:AddEvent()

	local function call_back(target,x,y)
		self.model:Brocast(MailEvent.SelectMail, self.data.id)
	end
	AddClickEvent(self.Image.gameObject,call_back)

	local function call_back(mail_id)
		if self.data.id == mail_id then
			self:SelectItem()
		else
			self:ShowSelectBG(false)
		end
	end
	self.events[#self.events+1] = self.model:AddListener(MailEvent.SelectMail, call_back)
	self.events[#self.events+1] = self.model:AddListener(MailEvent.ReadMail,handler(self,self.DealReadMail))
	self.events[#self.events+1] = self.model:AddListener(MailEvent.FetchMail, handler(self,self.DealFetch))
end

function MailItem:DealReadMail(mail_id)
	if self.data ~= nil and self.data.id == mail_id then
		SetVisible(self.mailIcon.gameObject,false)
		SetVisible(self.mailRead.gameObject,true)
		SetVisible(self.select.gameObject,true)
	end
end

--处理提出附件
function MailItem:DealFetch(mail_id)
	if self.data ~= nil and self.data.id == mail_id then
		SetVisible(self.goodsIcon.gameObject,false)
		SetVisible(self.mailIcon.gameObject,false)
		SetVisible(self.mailRead.gameObject,true)
	end
end

--data:p_mail
function MailItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function MailItem:UpdateView()
	if self.data ~= nil then
		self.name:GetComponent('Text').text = self.data.title
		self.time:GetComponent('Text').text = self.model:GetMailDifTime(self.data.send,TimeManager.Instance:GetServerTime())

		if self.data.attach and not self.data.fetch then
			SetVisible(self.goodsIcon.gameObject,true)
		else
			SetVisible(self.goodsIcon.gameObject,false)
		end

		if self.data.read then
			SetVisible(self.mailIcon.gameObject,false)
			SetVisible(self.mailRead.gameObject,true)
		else
			SetVisible(self.mailIcon.gameObject,true)
			SetVisible(self.mailRead.gameObject,false)
		end
	end
	self:ShowSelectBG(false)
end

function MailItem:ShowSelectBG(showed)
	SetVisible(self.select.gameObject, showed)
end

function MailItem:SelectItem()
	if self.model.readedMailList[self.data.id] ~= nil then
		self.model.readingMail = self.model.readedMailList[self.data.id]
		self.model:Brocast(MailEvent.ShowMailContent)
		self:UpdateView()
	else
		MailController.Instance:RequestReadMail(self.data.id)
	end

	self:ShowSelectBG(true)
end