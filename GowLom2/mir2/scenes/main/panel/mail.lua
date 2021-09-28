local common = import("..common.common")
local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local titleTips = import("..common.titleInfo")
local mail = class("mail", function ()
	return display.newNode()
end)

table.merge(slot4, {
	container = {},
	offset = {},
	nodes = {},
	items = {}
})

local special = common.getSpecialItemIcon()
mail.operatorMail = function (self, action, id)
	if action == "list" then
		local rsb = DefaultClientMessage(CM_QUERY_MAIL_LIST)

		MirTcpClient:getInstance():postRsb(rsb)
	elseif action == "get" then
		local rsb = DefaultClientMessage(CM_QUERY_MAIL_INFO)
		rsb.MailId = id

		MirTcpClient:getInstance():postRsb(rsb)
	elseif action == "attach" then
		g_data.client:setLastMail(id)

		local rsb = DefaultClientMessage(CM_DISPOSE_MAIL)
		rsb.MailID = id
		rsb.DisposeType = 1

		MirTcpClient:getInstance():postRsb(rsb)
	elseif action == "attachOfftm" then
		local rsb = DefaultClientMessage(CM_GET_ALL_MAIlITEMS)

		MirTcpClient:getInstance():postRsb(rsb)
	elseif action == "del" then
		g_data.client:setLastMail(id)

		local rsb = DefaultClientMessage(CM_DISPOSE_MAIL)
		rsb.MailID = id
		rsb.DisposeType = 2

		MirTcpClient:getInstance():postRsb(rsb)
		self.removeNodebyID(self, id)
	elseif action == "clear" then
		local rsb = DefaultClientMessage(CM_DISPOSE_MAIL)
		rsb.MailID = id
		rsb.DisposeType = 3

		MirTcpClient:getInstance():postRsb(rsb)

		local num = 1

		for k = 1, 50, 1 do
			if self.nodes and self.nodes[num] then
				if self.nodes[num].data and self.nodes[num].data.mailState and not self.nodes[num].data.attachState then
					local nodeId = self.nodes[num].data.id

					g_data.mail:delByMailId(nodeId)
					self.nodes[num]:removeSelf()
					table.remove(self.nodes, num)
					p2("other", "clear mail -- mailID: " .. nodeId)
				else
					num = num + 1
				end
			end
		end

		self.resetRightPanel(self)

		if 0 < #self.nodes and self.nodes[1].data then
			self.sysMail(self, self.nodes[1].data.id)
		end
	end

	return 
end
ccui.TouchEventType = {
	moved = 1,
	began = 0,
	canceled = 3,
	ended = 2
}
local money_name = {
	"gold",
	"yb",
	"prestige",
	"silver",
	"grid",
	"vitality",
	"vigour",
	"experience",
	"contribution",
	"credit",
	"merit",
	"canJuan",
	"jiangQuan"
}
mail.refreshMailNums = function (self)
	local mails = g_data.mail.sys
	local notRead = 0
	local notAttach = 0
	local finish = 0

	for k, v in pairs(mails) do
		if not v.mailState then
			notRead = notRead + 1
		end

		if v.attachState then
			notAttach = notAttach + 1
		end

		if v.mailState and not v.attachState then
			finish = finish + 1
		end
	end

	local lblMailContent = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_mailContent_val")
	local lblUnread = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_unread_val")
	local lblUnattach = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_unattach_val")
	local lblFinish = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_finish_val")

	lblMailContent.setString(lblMailContent, #mails .. "/50")
	lblUnread.setString(lblUnread, notRead)
	lblUnattach.setString(lblUnattach, notAttach)
	lblFinish.setString(lblFinish, finish)

	if notRead == 0 then
		g_data.pointTip:set("mail", false)
	end

	return 
end
mail.resetRightPanel = function (self)
	local lblTitle = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_title")

	lblTitle.setString(lblTitle, "")

	if self.mailContent then
		self.mailContent:removeSelf()

		self.mailContent = nil
	end

	self.removeItems(self)

	return 
end
mail.resetMask = function (self, i)
	for k, v in pairs(self.nodes) do
		if v.mask then
			v.mask:removeSelf()

			v.mask = nil
		end
	end

	self.nodes[i].mask = res.get2("pic/panels/mail/nodeBg2.png"):addTo(self.nodes[i], 1):pos(self.nodes[i]:getw()/2, self.nodes[i]:geth()/2):anchor(0.5, 0.5)

	return 
end
mail.resetnewMailTip = function (self, mailID)
	for k, v in pairs(self.nodes) do
		if v.data and v.data.id == mailID and v.newMailTip then
			v.newMailTip:removeSelf()

			v.newMailTip = nil
		end
	end

	return 
end
mail.resetpicAttach = function (self, mailID)
	for k, v in pairs(self.nodes) do
		if v.data and v.data.id == mailID and v.picAttach then
			v.picAttach:removeSelf()

			v.picAttach = nil
		end
	end

	return 
end
mail.resetMaskById = function (self, mailID)
	for k, v in pairs(self.nodes) do
		if v.data and v.data.id == mailID then
			self.resetMask(self, k)
		end
	end

	return 
end

local function gdataMailDel(needId)
	for k, v in pairs(g_data.mail.sys) do
		if v.mailId == needId then
			table.remove(g_data.mail.sys, k)
		end
	end

	return 
end

mail.removeNodebyID = function (self, mailID)
	for k = 1, #self.nodes, 1 do
		if self.nodes[k].data.id == mailID then
			self.nodes[k]:removeSelf()
			table.remove(self.nodes, k)

			if 0 < #self.nodes then
				for i = k, #self.nodes, 1 do
					self.nodes[i]:pos(self.nodes[i]:getPositionX(), self.nodes[i]:getPositionY() + 60)
				end
			end

			break
		end
	end

	local num = #self.nodes

	g_data.mail:delByMailId(mailID)

	return 
end
mail.removeItems = function (self)
	for k, v in pairs(self.items) do
		if v and v.isItem then
			v.removeSelf(v)

			self.items[k] = nil
		end
	end

	for i = 1, 4, 1 do
		local widgetName = "panel_type_" .. i
		local widget = ccui.Helper:seekWidgetByName(self.rootPanel, widgetName)

		if widget then
			widget.removeSelf(widget)
		end
	end

	return 
end
mail.ctor = function (self, params)
	self._supportMove = true
	self.rootPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("ui/mail/mail.csb")
	local bg = self.rootPanel

	self.size(self, bg.getw(bg), bg.geth(bg)):anchor(0.5, 0.5):center()
	bg.add2(bg, self)

	local function clickClose(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		self:hidePanel()

		return 
	end

	local btnClose = ccui.Helper.seekWidgetByName(slot4, self.rootPanel, "btn_close")

	btnClose.addTouchEventListener(btnClose, clickClose)
	self.operatorMail(self, "list")

	local function clickAttachMail(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		local data = g_data.mail.infos.sys[self.mailId]

		if data == nil then
			return 
		end

		if not data.attachState then
			main_scene.ui:tip("没有奖励可以领取.")
		else
			self:operatorMail("attach", self.mailId)
		end

		return 
	end

	local btnAttachMail = ccui.Helper.seekWidgetByName(slot6, self.rootPanel, "btn_attach_mail")

	btnAttachMail.addTouchEventListener(btnAttachMail, clickAttachMail)

	local function clickDelete(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		local data = g_data.mail.infos.sys[self.mailId]

		if data == nil then
			return 
		end

		if data.attachState then
			an.newMsgbox("还有未领取的附件,删除后无法恢复。\n确认是否删除邮件?", function (idx)
				if idx == 1 then
					self:operatorMail("del", self.mailId)
				end

				return 
			end, {
				center = true,
				hasCancel = true
			})
		else
			self.operatorMail(slot3, "del", self.mailId)
		end

		return 
	end

	local btnDelete = ccui.Helper.seekWidgetByName(slot8, self.rootPanel, "btn_delete_mail")

	btnDelete.addTouchEventListener(btnDelete, clickDelete)

	local function clickAttachAll(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		self:operatorMail("attachOfftm")

		return 
	end

	local btnAttachAll = ccui.Helper.seekWidgetByName(slot10, self.rootPanel, "btn_attach_all")

	btnAttachAll.addTouchEventListener(btnAttachAll, clickAttachAll)

	local function clickDeleteAll(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		self:operatorMail("clear")

		return 
	end

	local btnDeleteAll = ccui.Helper.seekWidgetByName(slot12, self.rootPanel, "btn_delete_all")

	btnDeleteAll.addTouchEventListener(btnDeleteAll, clickDeleteAll)
	main_scene.ui.notice:removeMailCnt()
	self.refreshMailNums(self)

	return 
end
mail.refresh = function (self)
	self.showContentByTag(self, 1)

	return 
end
mail.removeAttached = function (self)
	g_data.mail:removeAttached()

	return 
end
mail.newLayer = function (self)
	self.container = {}

	if self.layer then
		self.layer:removeSelf()
	end

	self.layer = display.newNode():addTo(self)

	return self.layer
end
mail.showContentByTag = function (self, tag)
	local layer = self.newLayer(self)
	local cfg = g_data.mail:cfg()
	local msgs = {
		{
			tag = "sys",
			str = "当前暂无系统邮件。"
		},
		{
			tag = "sell",
			str = "当前暂无物品售卖信息。"
		},
		{
			tag = "offtm",
			str = "当前暂无摊位退回物品。"
		},
		{
			tag = "msg",
			str = "当前暂无玩家留言。"
		}
	}

	for i = 1, #msgs, 1 do
		if tag == cfg[msgs[i].tag] and (table.nums(g_data.mail[msgs[i].tag]) ~= 0 or false) then
			self[msgs[i].tag .. "MailShow"](self)
		end
	end

	return 
end
mail.updateScroll = function (self)
	local scroll = self.layer.scroll

	print(type(scroll))

	return 
end
mail.sysMailShow = function (self)
	local layer = self.layer
	self.scroll = an.newScroll(20, 400, 200, 274):addTo(layer):anchor(0, 1)
	local w = 484
	local h = 60
	local y = nil

	for i = 1, #g_data.mail.sys, 1 do
		local data = setmetatable({}, {
			__index = g_data.mail.sys[i]
		})
		y = (i - 1)*h - 274 - h/2
		self.nodes[i] = res.get2("pic/panels/mail/nodeBg1.png"):addTo(self.scroll):pos(0, y):anchor(0, 0.5)
		self.nodes[i].data = data

		self.extendNode(self, self.nodes[i], "sys", self.scroll)
		an.newLabel("系统邮件" .. os.date("%m-%d-%y", data.time), 18, 1, {
			color = def.colors.labelYellow
		}):addTo(self.nodes[i], 2):pos(28, h/2):anchor(0, 0)

		local title = g_data.player:fixStrLen(data.title, 7)

		an.newLabel(title, 18, 1, {
			color = def.colors.labelGray
		}):addTo(self.nodes[i], 2):pos(28, 5):anchor(0, 0)

		if data.mailState and not data.attachState then
			self.nodes[i].picFinish = res.get2("pic/panels/mail/finish.png"):addTo(self.nodes[i], 2):pos(8, h/2):anchor(0, 0.5)
		end

		if data.attachState then
			self.nodes[i].picAttach = res.get2("pic/panels/mail/picAttach.png"):addTo(self.nodes[i], 2):pos(-7, h):anchor(0, 1)
		end

		if not data.mailState then
			self.nodes[i].newMailTip = res.get2("pic/panels/mail/newMailTip.png"):addTo(self.nodes[i], 2):pos(180, h - 10):anchor(0.5, 0.5)
		end
	end

	self.refreshMailNums(self)
	self.resetMask(self, 1)

	return 
end
mail.showMail = function (self, id, from)
	self.mailId = id

	self.resetRightPanel(self)

	if from == "sys" then
		self.sysMail(self, id)
	elseif from == "sell" then
		self.sellMail(self, id)
	else
		p2("error", "[Sys mail] function showMail: Invalid mail id, the mail from is unknow !")
	end

	return 
end
mail.delMail = function (self, id, from)
	if from == "sell" then
		self.delMailFromContainer(self, id)
	else
		p2("error", "[Sys mail] function delMail: Invalid mail id, the mail from is unknow !")
	end

	return 
end
mail.newMailcontent = function (self)
	if self.mailContent then
		self.mailContent:removeSelf()
	end

	self.mailContent = display.newNode():addTo(self)

	return self.mailContent
end
mail.sysMail = function (self, id)
	if not id then
		return 
	end

	local data = g_data.mail.infos.sys[id]

	if not data then
		self.operatorMail(self, "get", id)

		return 
	end

	local lblTitle = ccui.Helper:seekWidgetByName(self.rootPanel, "lbl_title")

	lblTitle.setString(lblTitle, data.title)

	if self.mailContent then
		self.mailContent:removeSelf()

		self.mailContent = nil
	end

	self.mailContent = an.newScroll(230, 350, 360, 105, {
		labelM = {
			18,
			1,
			params = {
				subWordNum = 1
			}
		}
	}):addTo(self):anchor(0, 1)

	self.mailContent.labelM:addLabel(data.context)

	if data.attachState then
		for i = 1, 6, 1 do
			if data.items and data.items[i] then
				local imgBox = ccui.Helper:seekWidgetByName(self.rootPanel, "img_box" .. i)
				local tmpItem = nil

				if data.items[i].type and data.items[i].type == "称号" then
					tmpItem = res.get2("pic/common/title.png"):pos(imgBox.getContentSize(imgBox).width/2, imgBox.getContentSize(imgBox).height/2):add2(imgBox, 1)

					tmpItem.setTouchEnabled(tmpItem, true)
					tmpItem.addNodeEventListener(tmpItem, cc.NODE_TOUCH_EVENT, function (event)
						if event.name == "began" then
							return true
						elseif event.name == "ended" then
							local data = {
								honourID = data.items[i].honourID,
								honourUsableTime = data.items[i].Time,
								get = function (self, param)
									return data[param]
								end
							}

							titleTips.show(i, event)
						end

						return 
					end)
				else
					tmpItem = item.new(data.items[i], titleTips, {
						donotMove = true
					}):addTo(imgBox, 1):pos(imgBox.getContentSize(imgBox).width/2, imgBox.getContentSize(imgBox).height/2):anchor(0.5, 0.5)
				end

				self.items[#self.items + 1] = tmpItem
				self.items[#self.items].isItem = true
			end
		end
	end

	local function getString(num)
		local str = ""
		num = tonumber(num)

		if 10000 < num then
			str = string.format("%.2f", num/10000) .. "万"
		else
			str = tostring(num)
		end

		return str
	end

	if data.attachState then
		local count = 1
		local spaceX = 0
		local originX = 0
		local panel = ccui.Helper.seekWidgetByName(slot8, self.rootPanel, "panel_type")

		for i = 1, 4, 1 do
			local widgetName = "panel_type_" .. i
			local widget = ccui.Helper:seekWidgetByName(self.rootPanel, widgetName)

			if widget then
				widget.removeSelf(widget)
			end
		end

		local originX, originY = panel.getPosition(panel)

		for key, value in pairs(data) do
			if special[key] then
				local panel_temp = panel.clone(panel)

				panel_temp.setName(panel_temp, "panel_type_" .. tostring(count))
				panel_temp.setVisible(panel_temp, true)
				self.rootPanel:addChild(panel_temp)

				local lbl = an.newLabel("", 20, 0, {
					color = cc.c3b(250, 210, 100)
				})

				lbl.setPosition(lbl, 35, 40)
				lbl.anchor(lbl, 0, 0.5)
				panel_temp.addChild(panel_temp, lbl)

				if key == "元宝" or key == "银锭" then
					lbl.setString(lbl, common.getMoneyShowText(value))
				else
					lbl.setString(lbl, getString(value))
				end

				local img = res.get("items", special[key])

				img.setPosition(img, 10, 40)
				panel_temp.addChild(panel_temp, img)
				panel_temp.setPosition(panel_temp, (count - 1)*130 + 240, 100)

				count = count + 1
			end
		end
	end

	return 
end
mail.extendNode = function (self, node, type, scroll)
	node.setTouchEnabled(node, true)
	node.setTouchSwallowEnabled(node, false)

	local y, move = nil

	node.addNodeEventListener(node, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			node.select = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(node:getw(), node:geth())):anchor(0, 0):addTo(node)
			y = event.y
			move = false

			return true
		elseif event.name == "moved" then
			if 10 < math.abs(y - event.y) then
				move = true

				if node.select then
					node.select:removeSelf()

					node.select = nil
				end
			end
		elseif event.name == "ended" then
			if not move then
				if type == "sys" then
					if g_data.mail.infos.sys[node.data.id] then
						local mailId = node.data.id
						self.mailId = mailId

						if not g_data.mail:readMail(node.data.id) then
							main_scene.ui:tip("没有此邮件")
						end

						self:showMail(mailId, type)
					else
						self:operatorMail("get", node.data.id)
					end
				elseif node.state then
					self:hideSellInfo(node)
				elseif g_data.mail.infos.sell[node.data.id] then
					self:showMail(node.data.id, type)
				else
					self:operatorMail("get", node.data.id)
				end

				if node.select then
					node.select:removeSelf()

					node.select = nil
				end

				for k, v in pairs(self.nodes) do
					if v.mask then
						v.mask:removeSelf()

						v.mask = nil
					end
				end

				node.mask = res.get2("pic/panels/mail/nodeBg2.png"):addTo(node, 1):pos(node:getw()/2, node:geth()/2):anchor(0.5, 0.5)

				if node.newMailTip then
					node.newMailTip:removeSelf()

					node.newMailTip = nil
				end
			end

			y = nil
			move = false
		end

		return 
	end)

	return 
end
mail.updateMailUi = function (self)
	return 
end

return mail
