local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local RecyclingItems = class("RecyclingItems", function ()
	return display.newNode()
end)

table.merge(slot2, {})

local functionInstructionTxt = {
	" 拖入物品可查看\n回收后获得的物品",
	"这个东西我用不上\n还是你自己留着吧"
}
ccui.TouchEventType = {
	moved = 1,
	began = 0,
	canceled = 3,
	ended = 2
}
RecyclingItems.ctor = function (self)
	self.setNodeEventEnabled(self, true)

	self._scale = self.getScale(self)
	self._supportMove = true
	self.rootPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("ui/RecyclingItems/RecyclingItems_1.csb")
	self.img_weapon = ccui.Helper:seekWidgetByName(self.rootPanel, "img_weapon")
	self.txtDragItems = ccui.Helper:seekWidgetByName(self.rootPanel, "TextField_48")

	self.txtDragItems:setVisible(false)

	self.imgItemPromptBg = ccui.Helper:seekWidgetByName(self.rootPanel, "panel_get")
	local bg = self.rootPanel

	self.size(self, bg.getw(bg), bg.geth(bg)):anchor(0, 1):pos(10, display.height - 81)
	bg.add2(bg, self)

	local btnClose = ccui.Helper:seekWidgetByName(self.rootPanel, "btn_close")

	btnClose.removeFromParent(btnClose)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:rebackBag(self.itemData)
		self:hidePanel()
		main_scene.ui:hidePanel("bag")

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot3, 1, 1):pos(369, 448):addto(self.rootPanel, 10)

	local function clickIdentify()
		if self.itemData == nil then
			main_scene.ui:tip("请拖入想要回收的物品", 6)

			return 
		end

		local data = self.serverdata

		if data then
			if data.FBoCanRecycle then
				if not data.FConditionStr or (data.FConditionStr and data.FConditionStr == "") then
					local function sendNet()
						if not self.itemData then
							return 
						end

						local rsb = DefaultClientMessage(CM_Recycle_item)
						rsb.FItemIdent = self.itemData.FItemIdent

						print("rsb.FItemIdent", rsb.FItemIdent)
						MirTcpClient:getInstance():postRsb(rsb)

						return 
					end

					if data.FBoNeedConfirm then
						local name = self.itemData.getVar(slot2, "name")
						local msg = {
							{
								"确定要回收",
								cc.c3b(240, 200, 150)
							},
							{
								name,
								cc.c3b(230, 105, 70)
							},
							{
								"吗?\n回收后，物品将消失",
								cc.c3b(240, 200, 150)
							}
						}
						local msgBox = an.newMsgbox("", function (isOk)
							if isOk == 1 then
								sendNet()
							end

							return 
						end, {
							center = true,
							hasCancel = true
						})
						local labelM = an.newLabelM(250, 20, nil, {
							center = true
						})

						for i, v in ipairs(slot3) do
							labelM.addLabel(labelM, unpack(v))
						end

						labelM.add2(labelM, msgBox.bg):anchor(0.5, 0.5):pos(msgBox.bg:getw()*0.5, msgBox.bg:geth()/2 + 15)
					else
						sendNet()
					end

					return 
				end

				main_scene.ui:tip("物品回收条件未达到", 6)

				return 
			else
				main_scene.ui:tip("物品不可回收", 6)

				return 
			end
		end
	end

	self.btn_identify = ccui.Helper.seekWidgetByName(slot4, self.rootPanel, "btn_identify")

	self.btn_identify:removeFromParent()
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		clickIdentify()

		return 
	end, {
		label = {
			"确定回收",
			20,
			0,
			{
				color = cc.c3b(240, 200, 150)
			}
		},
		pressImage = res.gettex2("pic/common/btn21.png")
	}).anchor(slot4, 1, 1):pos(235, 70):addto(self.rootPanel)

	local itemMsgBg = self.imgItemPromptBg:getContentSize()
	self.txtItemMsg = an.newLabelM(itemMsgBg.width, 20, nil, {
		center = true
	}):add2(self.imgItemPromptBg):pos(itemMsgBg.width/2, itemMsgBg.height/2):anchor(0.5, 0.5)

	self.txtItemMsg:addLabel(functionInstructionTxt[1], cc.c3b(240, 200, 150))
	self.showBag(self)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_Recycle_item_query, self, self.onSM_Recycle_item_query)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_Recycle_item, self, self.onSM_Recycle_item)

	return 
end
RecyclingItems.rebackBag = function (self, data)
	if not data then
		return 
	end

	self.itemData = nil

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	self.img_weapon:removeAllChildren()

	return 
end
RecyclingItems.showBag = function (self)
	if main_scene.ui.panels then
		if main_scene.ui.panels.bag then
			local w = self.getw(self)

			main_scene.ui.panels.bag:pos(395, display.height - 80):anchor(0, 1)
		else
			main_scene.ui:togglePanel("bag")
			main_scene.ui.panels.bag:pos(self.getw(self) + 10, display.height - 80)
		end
	end

	return 
end
RecyclingItems.showItem = function (self)
	if self.img_weapon and self.itemData then
		self.img_weapon:removeAllChildren()
		item.new(self.itemData, self, {
			donotMove = false
		}):addto(self.img_weapon):pos(self.img_weapon:getw()*0.5, self.img_weapon:geth()*0.5)
		self.updateItemDescription(self, self.itemData)
	end

	return 
end
RecyclingItems.putItem = function (self, itemIn, posx, posy)
	local form = itemIn.formPanel.__cname

	if form ~= "bag" then
		return 
	end

	if self.itemData then
		self.rebackBag(self, self.itemData)
	end

	self.itemData = itemIn.data

	self.getItemFromBg(self, self.itemData)
	self.showItem(self)

	return 
end
RecyclingItems.getItemFromBg = function (self, data)
	if not data then
		return 
	end

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(data.FItemIdent)
	end

	return 
end
RecyclingItems.rebackBag = function (self, data)
	if not data then
		return 
	end

	self.itemData = nil

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	self.img_weapon:removeAllChildren()

	return 
end
RecyclingItems.updateItemDescription = function (self, data, fromNet, result)
	if data then
		local itemname = data.getVar(data, "name")

		self.txtItemMsg:clear()

		local tiplist = {}

		if fromNet then
			if result.FBoCanRecycle then
				if result.FConditionStr == "" then
					if result.FExchangeItem ~= "" then
						local itemsT = string.split(result.FExchangeItem, "/")

						for m, n in pairs(itemsT) do
							local item = string.split(n, "|")

							if item[1] ~= "" then
								local name = item[1]
								local num = tonumber(item[2]) or 1

								if data.isPileUp and data.isPileUp(data) then
									num = num*data.FDura
								end

								table.insert(tiplist, {
									name,
									cc.c3b(255, 0, 0)
								})

								local str = "\n"

								if #itemsT < m + 1 then
									str = ""
								end

								table.insert(tiplist, {
									"*" .. num .. str,
									cc.c3b(255, 255, 255)
								})
							end
						end
					end
				elseif 0 < string.len(result.FConditionStr) then
					table.insert(tiplist, {
						result.FConditionStr,
						cc.c3b(230, 105, 70)
					})
				end
			else
				table.insert(tiplist, {
					functionInstructionTxt[2],
					cc.c3b(230, 105, 70)
				})
			end
		else
			local itemtype = 1
			local itemident = data.FItemIdent

			if itemname == "黑铁矿石" then
				itemtype = 2
			end

			local rsb = DefaultClientMessage(CM_Recycle_item_query)
			rsb.FAtype = itemtype
			rsb.FItemName = data.getVar(data, "name")
			rsb.FitemIdent = itemident

			MirTcpClient:getInstance():postRsb(rsb)
		end

		if fromNet and #tiplist == 0 then
			table.insert(tiplist, {
				"无",
				cc.c3b(230, 105, 70)
			})
		end

		for i, v in ipairs(tiplist) do
			self.txtItemMsg:addLabel(unpack(v))
		end

		self.txtDragItems:setVisible(false)
	else
		self.txtDragItems:setVisible(false)
	end

	return 
end
RecyclingItems.getItemDCfgata = function (self, name)
	for k, v in pairs(def.itemRecycleAbilAward) do
		print("def.itemRecycleAbilAward")
		print(k, v)
	end

	local cfgdata = nil

	for k, v in pairs(def.recyleItem) do
		if name == v.ItemName then
			cfgdata = v

			break
		end
	end

	return cfgdata
end
RecyclingItems.onSM_Recycle_item_query = function (self, result)
	print("SM_Recycle_item_query")
	print("")
	print_r(result)

	if result then
		self.serverdata = result

		self.updateItemDescription(self, self.itemData, true, result)
	end

	return 
end
RecyclingItems.onSM_Recycle_item = function (self, result)
	print("onSM_Recycle_item")
	print_r(result)

	if result then
		print("result.FBoOk = ", result.FBoOk)
		print("result.FItemIdent = ", result.FItemIdent)

		if result.FBoOk and self.itemData.FItemIdent == result.FItemIdent then
			main_scene.ui:tip("回收成功", 6)

			self.itemData = nil

			self.img_weapon:removeAllChildren()
			self.txtItemMsg:clear()
			self.txtItemMsg:addLabel(functionInstructionTxt[1], cc.c3b(240, 200, 150))
			self.txtDragItems:setVisible(false)

			self.serverdata = nil
		end
	end

	return 
end
RecyclingItems.delItem = function (self, item)
	if item.data == self.itemData then
		self.rebackBag(self, self.itemData)
		self.img_weapon:removeAllChildren()

		self.itemData = nil

		self.img_weapon:removeAllChildren()
		self.txtItemMsg:clear()
		self.txtItemMsg:addLabel(functionInstructionTxt[1], cc.c3b(240, 200, 150))
		self.txtDragItems:setVisible(false)

		self.serverdata = nil
	end

	return 
end

return RecyclingItems
