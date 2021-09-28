local horseSoulPreview = class("horseSoulPreview", import(".panelBase"))
local tip = import(".wingInfo")
horseSoulPreview.ctor = function (self, horseid)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.horseid = horseid

	return 
end
horseSoulPreview.onEnter = function (self)
	self.initPanelUI(self, {
		title = " ﬁªÍ‘§¿¿",
		bg = "pic/panels/wingUpgrade/previewBg.png"
	})
	self.pos(self, display.cx + 320, display.cy)
	self.loadMainPage(self)

	return 
end
horseSoulPreview.loadMainPage = function (self)
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
horseSoulPreview.fillListView = function (self)
	local listView = self.soulList
	self.scrollHeight = 0
	local monSoulUpCfg = def.horseSoul.getMonSoulUpCfg()

	for i, v in ipairs(monSoulUpCfg) do
		if i%10 == 0 then
			local item = display.newSprite(res.gettex2("pic/panels/wingUpgrade/previewItem.png"))

			display.newSprite(res.gettex2("pic/panels/horseSoul/sh_icon.png")):add2(item):pos(35, 36):enableClick(function ()
				local ss = {}
				local level = i
				local lvStr = def.pet.level2str(level)

				table.insert(ss, {
					lvStr,
					cc.c3b(255, 255, 0)
				})

				local job = g_data.player.job
				local props = def.property.dumpPropertyStr(v.PropertyStr):clearZero():toStdProp():grepJob(job)

				for i, v in ipairs(props.props) do
					local p = props.formatPropString(props, v[1])

					table.insert(ss, {
						p,
						display.COLOR_WHITE
					})
				end

				tip.show(ss, item:convertToWorldSpace(cc.p(0, 0)), {})

				return 
			end)
			an.newLabel(" ﬁªÍ", 20, 1, {
				color = cc.c3b(220, 210, 190)
			}).anchor(slot9, 0, 0.5):addto(item):pos(67, 48)
			an.newLabel(def.horseSoul.level2str(i), 20, 1, {
				color = cc.c3b(240, 200, 150)
			}):anchor(0, 0.5):addto(item):pos(67, 22)
			self.listViewPushBack(self, listView, item)

			self.scrollHeight = self.scrollHeight + item.geth(item) + 4
		end
	end

	return 
end

return horseSoulPreview
