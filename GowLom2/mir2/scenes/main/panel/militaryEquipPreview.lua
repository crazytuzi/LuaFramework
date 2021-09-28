local militaryEquipPreview = class("militaryEquipPreview", import(".panelBase"))
local item = import("..common.item")
local tip = import(".wingInfo")
militaryEquipPreview.ctor = function (self, params)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.equipType = params.equipType
	self.title = params.menu[params.equipType]
	self.job = params.job

	self.initPanelUI(self, {
		bg = "pic/panels/wingUpgrade/previewBg.png",
		title = self.title .. "预览"
	})
	self.pos(self, display.cx + 320, display.cy)
	self.loadMainPage(self)

	return 
end
militaryEquipPreview.loadMainPage = function (self)
	self.content = self.bg
	local scrollRect = cc.rect(0, 0, 175, 400)
	local soulList = self.newListView(self, 10, 8, scrollRect.width, scrollRect.height, 4, {}):add2(self.bg)
	self.soulList = soulList

	self.fillListView(self)

	local rollbg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 174, 8, cc.size(20, 400)):addTo(self.bg):anchor(0, 0)
	local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)

	soulList.setListenner(soulList, function (event)
		if event.name == "moved" then
			local x, y = soulList:getScrollOffset()
			local scrollHeight = self.scrollHeight
			local maxOffset = scrollHeight - soulList:geth()

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
militaryEquipPreview.fillListView = function (self)
	local listView = self.soulList
	self.scrollHeight = 0
	local equipList = def.militaryEquip.getPreviewList(self.equipType)

	for i, v in ipairs(equipList) do
		local itemBg = display.newSprite(res.gettex2("pic/panels/wingUpgrade/previewItem.png"))
		local img = def.militaryEquip.getEquipIcon(v):add2(itemBg, 2):pos(35, 36)

		img.enableClick(img, function ()
			local ss = {}
			local lvStr = v.RELevel .. "级" .. self.title

			table.insert(ss, {
				lvStr,
				cc.c3b(255, 255, 0)
			})

			for i, k in ipairs(def.militaryEquip.dumpPropStr(v.PropertyStr, self.job)) do
				local property = (k[3] ~= nil and k[2] .. "-" .. k[3]) or "+" .. k[2]

				table.insert(ss, {
					k[1] .. ":" .. property,
					display.COLOR_WHITE
				})
			end

			table.insert(ss, {
				"\n",
				display.COLOR_WHITE
			})
			table.insert(ss, {
				"需要等级:" .. common.getLevelText(v.NeedPlayerLevel),
				display.COLOR_WHITE
			})
			table.insert(ss, {
				v.Desc,
				display.COLOR_WHITE
			})
			tip.show(ss, img:convertToWorldSpace(cc.p(0, 0)), {})

			return 
		end)
		an.newLabel(self.title, 20, 1, {
			color = cc.c3b(220, 210, 190)
		}).anchor(slot10, 0, 0.5):addto(itemBg):pos(67, 48)
		an.newLabel(v.RELevel .. "级", 20, 1, {
			color = cc.c3b(240, 200, 150)
		}):anchor(0, 0.5):addto(itemBg):pos(67, 22)
		self.listViewPushBack(self, listView, itemBg)

		self.scrollHeight = self.scrollHeight + itemBg.geth(itemBg) + 4
	end

	return 
end

return militaryEquipPreview
