local godRingLvlPreview = class("godRingLvlPreview", import(".panelBase"))
local tip = import(".wingInfo")
godRingLvlPreview.ctor = function (self, godRingId)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.godRingId = godRingId

	return 
end
godRingLvlPreview.onEnter = function (self)
	self.initPanelUI(self, {
		title = "Éý¼¶Ô¤ÀÀ",
		bg = "pic/panels/wingUpgrade/previewBg.png"
	})
	self.pos(self, display.cx + 320, display.cy)
	self.loadMainPage(self)

	return 
end
godRingLvlPreview.loadMainPage = function (self)
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
godRingLvlPreview.fillListView = function (self)
	local listView = self.soulList
	self.scrollHeight = 0
	local godCfg = def.godring.getGodRingLevelById(self.godRingId)

	for i, v in ipairs(godCfg) do
		if v.Level%10 == 0 and 0 < v.Level then
			local item = display.newSprite(res.gettex2("pic/panels/wingUpgrade/previewItem.png"))

			display.newSprite(res.gettex2("pic/panels/godRing/" .. def.godring.imgCfg[self.godRingId] .. ".png")):add2(item):pos(35, 36):enableClick(function ()
				local ss = {}
				local lvStr = v.Level .. "¼¶" .. def.godring.nameCfg[self.godRingId]

				table.insert(ss, {
					lvStr,
					cc.c3b(255, 255, 0)
				})

				local job = g_data.player.job
				local lvProp = def.godring.getPropByIdAndLevel(self.godRingId, v.Level, job)

				for i, v in ipairs(lvProp) do
					table.insert(ss, {
						v,
						display.COLOR_WHITE
					})
				end

				tip.show(ss, item:convertToWorldSpace(cc.p(0, 0)), {})

				return 
			end)
			an.newLabel(def.godring.nameCfg[self.godRingId], 20, 1, {
				color = cc.c3b(220, 210, 190)
			}).anchor(slot9, 0, 0.5):addto(item):pos(67, 48)
			an.newLabel(v.Level .. "¼¶", 20, 1, {
				color = cc.c3b(240, 200, 150)
			}):anchor(0, 0.5):addto(item):pos(67, 22)
			self.listViewPushBack(self, listView, item)

			self.scrollHeight = self.scrollHeight + item.geth(item) + 4
		end
	end

	return 
end

return godRingLvlPreview
