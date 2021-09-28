local wingPreview = class("wingPreview", import(".panelBase"))
local tip = import(".wingInfo")
wingPreview.ctor = function (self, targetName)
	self.super.ctor(self)
	self.setMoveable(self, true)

	return 
end
wingPreview.onEnter = function (self)
	self.initPanelUI(self, {
		title = "”“Ì‘§¿¿",
		bg = "pic/panels/wingUpgrade/previewBg.png"
	})
	self.pos(self, display.cx + 320, display.cy)
	self.loadMainPage(self)

	return 
end
wingPreview.loadMainPage = function (self)
	self.content = self.bg
	local scrollRect = cc.rect(0, 0, 175, 400)
	local wingList = self.newListView(self, 10, 8, scrollRect.width, scrollRect.height, 4, {}):add2(self.bg)
	self.wingList = wingList

	self.fillListView(self)

	local rollbg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 174, 8, cc.size(20, 400)):addTo(self.bg):anchor(0, 0)
	local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)

	wingList.setScrollOffset(wingList, 0, -10)
	wingList.setListenner(wingList, function (event)
		if event.name == "moved" then
			local x, y = wingList:getScrollOffset()
			local scrollHeight = self.scrollHeight
			local maxOffset = scrollHeight - wingList:geth()

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
wingPreview.fillListView = function (self)
	local wingList = self.wingList
	self.scrollHeight = 0

	for i, v in ipairs(def.wing.getAllBaseCfg()) do
		if i%10 == 0 then
			local item = display.newSprite(res.gettex2("pic/panels/wingUpgrade/previewItem.png"))

			display.newSprite(res.gettex2("pic/panels/wingUpgrade/wingIcon.png")):add2(item):pos(37, 37):enableClick(function ()
				local ss = {}
				local level = i
				local lvStr = def.wing.level2str(level) .. "°§”“Ì"

				table.insert(ss, {
					lvStr,
					cc.c3b(255, 255, 0)
				})

				local job = g_data.player.job
				local wingCfg = def.wing.getUpgradeCfg(level)
				local props = def.property.dumpPropertyStr(wingCfg.PropertyStr):clearZero():toStdProp():grepJob(job)

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
			an.newLabel("” “Ì", 20, 1, {
				color = cc.c3b(220, 210, 190)
			}).anchor(slot8, 0, 0.5):addto(item):pos(67, 48)
			an.newLabel(def.wing.level2str(i), 20, 1, {
				color = cc.c3b(240, 200, 150)
			}):anchor(0, 0.5):addto(item):pos(67, 22)
			self.listViewPushBack(self, wingList, item)

			self.scrollHeight = self.scrollHeight + item.geth(item) + 4
		end
	end

	return 
end

return wingPreview
