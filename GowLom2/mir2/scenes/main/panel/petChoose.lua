local petChoose = class("petChoose", import(".panelBase"))
local tip = import(".wingInfo")
petChoose.ctor = function (self, params)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.params = params
	self.items = {}
	self.scrollHeight = 1

	return 
end
petChoose.onEnter = function (self)
	self.initPanelUI(self, {
		title = "我的宠物",
		bg = "pic/panels/horseUpgrade/eat_bg.png"
	})
	self.pos(self, display.cx + 340, display.cy + 10)

	if self.params.type == 1 then
		self.loadPageChoose(self)
	elseif self.params.type == 2 then
		self.loadPageEat(self)
	end

	return 
end
petChoose.onCloseWindow = function (self)
	g_data.eventDispatcher:dispatch("PET_CHOOSE_CLOSE_WIN")

	return self.super.onCloseWindow(self)
end
petChoose.loadPageChoose = function (self)
	self.content = self.bg
	local params = self.params

	display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(10, 10):size(232, 398):addTo(self.bg)

	local scrollRect = cc.rect(0, 0, 232, 388)
	local listView = self.newListView(self, 10, 12, scrollRect.width, scrollRect.height, 4, {}):add2(self.bg)
	self.listView = listView
	local curPetInfo = g_data.pet:getPetByIdent(params.curIdent)
	local data = {}

	for i, v in ipairs(g_data.pet.FList) do
		if params.curIdent ~= v.FCliPetIdent and g_data.pet.FCurrIdent ~= v.FCliPetIdent then
			local petInfo = g_data.pet:getPetByIdent(v.FCliPetIdent)

			if 0 < petInfo.quaEatGetExp and petInfo.rarity == curPetInfo.rarity then
				data[#data + 1] = petInfo
			end
		end
	end

	if 0 < #data then
		self.fillListViewChoose(self, {
			data = data
		})
	else
		local lblTip = an.newLabelM(160, 18, 1, {
			manual = false,
			center = true
		}):add2(self.content):anchor(0.5, 0.5):pos(self.content:getw()/2, self.content:geth()/2)

		lblTip.nextLine(lblTip)
		lblTip.addLabel(lblTip, "只有同稀有度，且品质为：蓝、紫、橙色的宠物，才能作为突破材料", cc.c3b(220, 210, 190))
	end

	local rollbg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 216, 12, cc.size(20, 388)):addTo(self.bg):anchor(0, 0)
	local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)

	listView.setListenner(listView, function (event)
		if event.name == "moved" then
			local x, y = listView:getScrollOffset()
			local scrollHeight = self.scrollHeight
			local maxOffset = scrollHeight - listView:geth()

			if y < 0 then
				y = 0
			end

			if maxOffset < y then
				y = maxOffset or y
			end

			local s = (rollbg:geth() - 42)*(y/maxOffset - 1)

			rollCeil:setPositionY(s)
		end

		return 
	end)

	return 
end
petChoose.loadPageEat = function (self)
	self.content = self.bg
	local params = self.params

	display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(10, 57):size(232, 348):addTo(self.bg)

	local scrollRect = cc.rect(0, 0, 232, 338)
	local listView = self.newListView(self, 10, 62, scrollRect.width, scrollRect.height, 4, {}):add2(self.bg)
	self.listView = listView
	local data = {}

	for i, v in ipairs(g_data.pet.FList) do
		if params.curIdent ~= v.FCliPetIdent and v.FCliPetIdent ~= g_data.pet.FCurrIdent then
			local petInfo = g_data.pet:getPetByIdent(v.FCliPetIdent)
			data[#data + 1] = petInfo
		end
	end

	if 0 < #data then
		self.fillListViewEat(self, {
			data = data
		})
	else
		an.newLabel("暂无宠物可吞噬", 20, 1, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(self.content:getw()/2, self.content:geth()/2):add2(self.content)
	end

	local rollbg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 216, 62, cc.size(20, 338)):addTo(self.bg):anchor(0, 0)
	local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)

	listView.setListenner(listView, function (event)
		if event.name == "moved" then
			local x, y = listView:getScrollOffset()
			local scrollHeight = self.scrollHeight
			local maxOffset = scrollHeight - listView:geth()

			if y < 0 then
				y = 0
			end

			if maxOffset < y then
				y = maxOffset or y
			end

			local s = (rollbg:geth() - 42)*(y/maxOffset - 1)

			rollCeil:setPositionY(s)
		end

		return 
	end)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function (btn)
		sound.playSound("103")
		g_data.eventDispatcher:dispatch("PET_CHOOSE_EAT_CLICK")

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"吞  噬",
			16,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot7, self.bg):anchor(0.5, 0.5):pos(124, 37)

	return 
end
petChoose.fillListViewChoose = function (self, params)
	local data = params.data or {}
	self.scrollHeight = 1

	for i, v in ipairs(data) do
		local data = v

		if self.params.curIdent ~= data.ident and g_data.pet.FCurrIdent ~= data.ident then
			local item = display.newSprite(res.gettex2("pic/panels/horseUpgrade/eat_item.png"))

			display.newSprite(res.gettex2("pic/panels/petUpgrade/" .. data.img .. ".png")):add2(item):pos(37, 37):scale(0.5)
			an.newLabel(string.format("%s", data.name), 20, 1, {
				color = def.pet:getRareColor(data.quality)
			}):anchor(0, 0.5):addto(item):pos(67, 48)
			an.newLabel(def.pet.level2str(data.level), 20, 1, {
				color = cc.c3b(240, 200, 150)
			}):anchor(0, 0.5):addto(item):pos(67, 22)

			item.checked = false
			item.data = v

			an.newBtn(res.gettex2("pic/common/toggle12.png"), function (sender)
				sound.playSound("103")

				item.checked = not item.checked

				sender.setIsSelect(sender, item.checked)
				g_data.eventDispatcher:dispatch("M_PET_CHOOSE_LIST_CHG")

				return 
			end, {
				support = "scroll",
				select = {
					res.gettex2("pic/common/toggle13.png"),
					manual = true
				}
			}).anchor(slot10, 0.5, 0.5):pos(177, 20):addTo(item)
			self.listViewPushBack(self, self.listView, item)

			self.scrollHeight = self.scrollHeight + item.geth(item) + 4
			self.items[#self.items + 1] = item
		end
	end

	return 
end
petChoose.fillListViewEat = function (self, params)
	local data = params.data or {}
	self.scrollHeight = 1

	for i, v in ipairs(data) do
		local data = v

		if 0 < data.upEatGetExp then
			local item = display.newSprite(res.gettex2("pic/panels/horseUpgrade/eat_item.png"))

			display.newSprite(res.gettex2("pic/panels/petUpgrade/" .. data.img .. ".png")):add2(item):pos(37, 37):scale(0.5)
			an.newLabel(string.format("%s", data.name), 20, 1, {
				color = def.pet:getRareColor(data.quality)
			}):anchor(0, 0.5):addto(item):pos(67, 48)
			an.newLabel(def.pet.level2str(data.level), 20, 1, {
				color = cc.c3b(240, 200, 150)
			}):anchor(0, 0.5):addto(item):pos(67, 22)

			item.checked = false
			item.data = v

			an.newBtn(res.gettex2("pic/common/toggle12.png"), function (sender)
				sound.playSound("103")

				item.checked = not item.checked

				sender.setIsSelect(sender, item.checked)
				g_data.eventDispatcher:dispatch("M_PET_CHOOSE_LIST_CHG")

				return 
			end, {
				support = "scroll",
				select = {
					res.gettex2("pic/common/toggle13.png"),
					manual = true
				}
			}).anchor(slot10, 0.5, 0.5):pos(177, 20):addTo(item)
			self.listViewPushBack(self, self.listView, item)

			self.scrollHeight = self.scrollHeight + item.geth(item) + 4
			self.items[#self.items + 1] = item
		end
	end

	return 
end
petChoose.getSelectData = function (self)
	local lst = {}

	for i, v in ipairs(self.items) do
		if v.checked then
			lst[#lst + 1] = v.data
		end
	end

	return lst
end

return petChoose
