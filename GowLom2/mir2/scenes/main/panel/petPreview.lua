local petPreview = class("petPreview", import(".panelBase"))
local tip = import(".wingInfo")
petPreview.ctor = function (self, horseid)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.horseid = horseid

	return 
end
petPreview.onEnter = function (self)
	self.initPanelUI(self, {
		title = "≥ËŒÔ‘§¿¿",
		bg = "pic/panels/wingUpgrade/previewBg.png"
	})
	self.pos(self, display.cx + 320, display.cy)
	self.loadMainPage(self)

	return 
end
petPreview.loadMainPage = function (self)
	self.content = self.bg
	local scrollRect = cc.rect(0, 0, 175, 400)
	local wingList = self.newListView(self, 10, 8, scrollRect.width, scrollRect.height, 4, {}):add2(self.bg)
	self.wingList = wingList

	self.fillListView(self)

	local rollbg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 174, 8, cc.size(20, 400)):addTo(self.bg):anchor(0, 0)
	local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)

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
petPreview.fillListView = function (self)
	local listView = self.wingList
	self.scrollHeight = 0
	local cfg = def.pet:getBaseCfgByID(self.horseid)

	for i, v in ipairs(def.pet:getUpgradeCfg()) do
		if i <= cfg.MaxUpLv and i%10 == 0 then
			local item = display.newSprite(res.gettex2("pic/panels/wingUpgrade/previewItem.png"))

			display.newSprite(res.gettex2("pic/panels/petUpgrade/" .. cfg.Img .. ".png")):add2(item):pos(37, 37):enableClick(function ()
				local ss = {}
				local level = i
				local lvStr = def.pet.level2str(level) .. "°§" .. cfg.Name

				table.insert(ss, {
					lvStr,
					cc.c3b(255, 255, 0)
				})

				local job = cfg.Job - 1
				local wingCfg = def.pet:getUpgradeCfgByLevel(level)
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
			end).scale(slot9, 0.5)
			an.newLabel(cfg.Name, 20, 1, {
				color = cc.c3b(220, 210, 190)
			}):anchor(0, 0.5):addto(item):pos(67, 48)
			an.newLabel(def.pet.level2str(i), 20, 1, {
				color = cc.c3b(240, 200, 150)
			}):anchor(0, 0.5):addto(item):pos(67, 22)
			self.listViewPushBack(self, listView, item)

			self.scrollHeight = self.scrollHeight + item.geth(item) + 4
		end
	end

	return 
end

return petPreview
