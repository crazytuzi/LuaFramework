--
-- @Author: chk
-- @Date:   2018-09-08 19:53:55
--
MailView = MailView or class("MailView",BaseItem)
local MailView = MailView

function MailView:ctor(parent_node,layer)
	self.abName = "mail"
	self.assetName = "MailView"
	self.layer = layer

	self.events = {}
	self.model = MailModel:GetInstance()
	self.iconSettors = {}
	self.mailitem_list = {}
	MailView.super.Load(self)
end

function MailView:dctor()
	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	self.model.lastItemSettor = nil
	self.model.readingMail = nil
	self.events = {}

	self.model:SortMail()

	for i, v in pairs(self.iconSettors) do
		v:destroy()
	end
	for i=1, #self.mailitem_list do
		self.mailitem_list[i]:destroy()
	end

	self.iconSettors = nil
	self.model = nil
end

function MailView:LoadCallBack()
	self.nodes = {
		"leftInfo",
		"rightInfo",
		"empty",
		"rightInfo/ContentScrollView/Viewport/Content",
		"rightInfo/ContentScrollView/Viewport/Content/from",
		"rightInfo/ContentScrollView/Viewport/Content/mailInfo",
		"leftInfo/oneKeyGetBtn",
		"leftInfo/delReadedBtn",
		"rightInfo/hadGet",
		"rightInfo/delMailBtn",
		"rightInfo/getMailBtn",
		"rightInfo/Enclosure",
		"rightInfo/Enclosure/ScrollView/Viewport/goodsContent",
		"rightInfo/title/titleName",
		"rightInfo/ContentScrollView",
		"rightInfo/ContentScrollView/Viewport/Content/mailText",
		"leftInfo/ScrollView",
		"leftInfo/ScrollView/Viewport/itemContent",
		"rightInfo/line1",
		"rightInfo/line1/time1",
		"rightInfo/line2",
		"rightInfo/line2/time2",
		"leftInfo/ScrollView/Viewport/itemContent/mailItem",
	}
	self:GetChildren(self.nodes)
	self.scrollRect = self.ScrollView:GetComponent('ScrollRect')
	self.mailInfoContentRect = self.Content:GetComponent('RectTransform')
	self.titleTxt = self.titleName:GetComponent('Text')
	self.fromTxt = self.from:GetComponent('Text')
	self.mailTxt = self.mailInfo:GetComponent('Text')
	self.mailInfoRect = self.mailInfo:GetComponent('RectTransform')
	self.contentRectTra = self.ContentScrollView:GetComponent('RectTransform')
	self.time1Txt = self.time1:GetComponent('Text')
	self.time2Txt = self.time2:GetComponent('Text')
	self.mailItem_gameobject = self.mailItem.gameObject
	SetVisible(self.mailItem_gameobject, false)

	--self:LoadItems()
	self:AddEvent()
	MailController.Instance:RequestMailList()
end

function MailView:AddEvent()
	local function call_back(target,x,y)                                         --一键提取
		MailController.GetInstance():RequestFetchMail(0)
	end
	AddClickEvent(self.oneKeyGetBtn.gameObject,call_back)


	local function call_back(target,x,y)                                           --删除己读
		local mail_ids = self.model:GetCanDelMailIds()
		if table.nums(mail_ids) > 0 then
			MailController.GetInstance():RequestDelMail(mail_ids)
		else
			Notify.ShowText(ConfigLanguage.Mail.NotReadedMail)
		end

	end
	AddClickEvent(self.delReadedBtn.gameObject,call_back)

	local function call_back(target,x,y)                                           --删除当前阅读邮件                            
		if self.model.readingMail ~= nil then
			local delMail = {}                                                     
			table.insert(delMail,self.model.readingMail.mail_id)
			MailController.GetInstance():RequestDelMail(delMail)
		end
	end
	AddClickEvent(self.delMailBtn.gameObject,call_back)



	local function call_back(target,x,y)
		if self.model.readingMail ~= nil then
			MailController.GetInstance():RequestFetchMail(self.model.readingMail.mail_id)
		end	
	end
	AddClickEvent(self.getMailBtn.gameObject,call_back)

	self.events[#self.events+1] = self.model:AddListener(MailEvent.DelMails,handler(self,self.DelMailItems))
	self.events[#self.events+1] = self.model:AddListener(MailEvent.ShowMailContent,handler(self,self.ShowContent))
	self.events[#self.events+1] = self.model:AddListener(MailEvent.FetchMail,handler(self,self.DealFetchMail))
	self.events[#self.events+1] = self.model:AddListener(MailEvent.ReadMail,handler(self,self.DealReadMail))
	self.events[#self.events+1] = self.model:AddListener(MailEvent.LoadMailItem,handler(self,self.LoadItems))
end

function MailView:OnEnable()
	--self:LoadItems()
end

function MailView:OnDisable()
	--self:dctor()
end


function MailView:DealReadMail()

	--self.model:SortMail()
	--self.scrollView:ResetItemIndex()
	--self.scrollView:ResetContentSize(table.nums(self.model.mailList))
	--self.scrollView:ResetPosition(true)
end

function MailView:DealFetchMail(mail_id)
	if self.model.readingMail.mail_id == mail_id then
		SetVisible(self.hadGet.gameObject,true)
		SetVisible(self.getMailBtn.gameObject,false)
		SetVisible(self.delMailBtn.gameObject,true)
	end
end

function MailView:DelMailItems(mailIds)
	--[[local delSelf = false
	local mail = self.model:GetMailById(self.model.readingMail.mail_id)
	for i, v in pairs(mailIds) do
		if v == self.model.readingMail.mail_id then
			delSelf = true
		end


		local settor = self.model:GetItemSettorById(v)
		if settor ~= nil then
			self.scrollView:DelItemByIndex(settor.__item_index)
			self.model:DeItemSettor(settor)
		end

	end

	local nums = table.nums(self.model.mailList)
	if nums > 0 then
		self.model:SortMail()
		self.model.lastItemSettor = nil
		self.scrollView:ResetItemIndex()
		self.scrollView:ResetContentSize(nums)
		self.scrollView:ResetPosition(true)
		local item = self.scrollView:GetScrollItemByIdx(1)
		if item then
			item:SelectItem()
		end
	else
		SetVisible(self.rightInfo.gameObject,false)
		SetVisible(self.leftInfo.gameObject,false)

		SetVisible(self.empty.gameObject,true)
	end--]]
	self:LoadItems()

end


function MailView:LoadItems()
	--self.model:SetFstNotReadMail()
	if #self.model.sort_list <= 0 then
		SetVisible(self.leftInfo.gameObject,false)
		SetVisible(self.rightInfo.gameObject,false)
		SetVisible(self.empty.gameObject,true)
	else
		SetVisible(self.leftInfo.gameObject,true)
		SetVisible(self.rightInfo.gameObject,true)
		SetVisible(self.empty.gameObject,false)
		
		for i=1, #self.model.sort_list do 
			local item = self.mailitem_list[i] or MailItem(self.mailItem_gameobject, self.itemContent)
			item:SetData(self.model.sort_list[i])
			self.mailitem_list[i] = item
		end
		--删除多余的项
		if #self.mailitem_list > #self.model.sort_list then
			for i=#self.mailitem_list, #self.model.sort_list+1, -1 do
				self.mailitem_list[i]:destroy()
				self.mailitem_list[i] = nil
			end
		end
		--选择第一封邮件
		self.model:Brocast(MailEvent.SelectMail, self.model.sort_list[1].id)
		SetLocalPositionY(self.itemContent.transform, 0)
	end
end

function MailView:ResetContentScroll()
	local mail = self.model:GetMailById(self.model.readingMail.mail_id)
	if not mail.attach then  --没有附件
		SetVisible(self.Enclosure.gameObject,false)
		SetVisible(self.getMailBtn.gameObject,false)
		SetVisible(self.hadGet.gameObject,false)
		if mail.read then
			SetVisible(self.delMailBtn.gameObject,true)
		end
		self.contentRectTra.sizeDelta = Vector2(self.contentRectTra.sizeDelta.x,343)
	else
		self.contentRectTra.sizeDelta = Vector2(self.contentRectTra.sizeDelta.x,226)
		SetVisible(self.Enclosure.gameObject,true)

		if mail.fetch then
			SetVisible(self.getMailBtn.gameObject,false)
			SetVisible(self.delMailBtn.gameObject,true)
			SetVisible(self.hadGet.gameObject,true)
		else
			SetVisible(self.getMailBtn.gameObject,true)
			SetVisible(self.delMailBtn.gameObject,false)
			SetVisible(self.hadGet.gameObject,false)
		end
		for i, v in pairs(self.iconSettors) do
			v:destroy()
		end
		self.iconSettors = {}

		local tab = self.model.readingMail.items
		
		table.sort(tab, function (a, b)
			local c1 = Config.db_item[a.id]
			local c2 = Config.db_item[b.id]
			if c1.color == c2.color then
				return  c1.stype < c2.stype
			else
				return c1.color > c2.color
			end
		end)
		
		for i=1, #tab do
			local param = {}
			local pitem = tab[i]
			param["item_id"] = pitem.id
			param["can_click"] = true
			param["p_item"] = pitem
			param["model"] = self.model
			param["num"] = tonumber(pitem.num)
			
			local iconSettor = GoodsIconSettorTwo(self.goodsContent)
			iconSettor:SetIcon(param)
			table.insert(self.iconSettors,iconSettor)
		end

		for i, v in pairs(self.model.readingMail.money) do
			local param = {}
			local cfg = Config.db_item[i]
			param["cfg"] = cfg
			param["can_click"] = true
			param["num"] = tonumber(v)
			param["model"] = self.model
			param["bind"] = (cfg.isbind == 1 or 2)

			local iconSettor = GoodsIconSettorTwo(self.goodsContent)
			iconSettor:SetIcon(param)
			table.insert(self.iconSettors,iconSettor)
		end
	end
end


function MailView:ShowContent()
	if self.is_loaded then

		if not self.rightInfo.gameObject.activeSelf then
			SetVisible(self.rightInfo.gameObject,true)
			--SetVisible(self.rightEmpty.gameObject,false)
		end

		self:ResetContentScroll()

		local mail = self.model:GetMailById(self.model.readingMail.mail_id)
		local difDay = TimeManager.Instance:GetDifDay (mail.expire,TimeManager.Instance:GetServerTime())
		local content = ""

		self.titleTxt.text = mail.title
		self.fromTxt.text = mail.from

		content = content .. self.model.readingMail.text

		self.mailTxt.text = content
		self.mailInfoRect.sizeDelta = Vector2(self.mailInfoRect.sizeDelta.x,self.mailTxt.preferredHeight)
		self.mailInfoContentRect.sizeDelta = Vector2(self.mailInfoContentRect.sizeDelta.x,self.mailTxt.preferredHeight + 26)
		self.time1Txt.text = ConfigLanguage.Mix.ValidDay .. difDay .. ConfigLanguage.Mix.Day
		self.time2Txt.text = ConfigLanguage.Mix.Time .. " " .. TimeManager.Instance:FormatTime2Date(mail.send)
	end

end

function MailView:SetData(data)

end

--[[function MailView:CreateCellCB(itemCls)
	table.insert(self.model.mailItemSettors,itemCls)
	self:updateCellCB(itemCls)
end

function MailView:updateCellCB(itemCls)
	itemCls:UpdateInfo()
end--]]