local horseEat = class("horseEat", import(".panelBase"))
local tip = import(".wingInfo")
horseEat.ctor = function (self, targetName)
	self.super.ctor(self)
	self.setMoveable(self, true)

	return 
end
horseEat.onEnter = function (self)
	self.initPanelUI(self, {
		title = "×øÆïÍÌÊÉ",
		bg = "pic/panels/horseUpgrade/eat_bg.png"
	})
	self.pos(self, display.cx + 340, display.cy + 10)
	self.loadMainPage(self)

	return 
end
horseEat.loadMainPage = function (self)
	self.content = self.bg

	display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(10, 57):size(232, 348):addTo(self.bg)

	local scrollRect = cc.rect(0, 0, 232, 338)
	local wingList = self.newListView(self, 10, 62, scrollRect.width, scrollRect.height, 4, {}):add2(self.bg)
	self.wingList = wingList

	self.fillListView(self)

	local rollbg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 216, 62, cc.size(20, 338)):addTo(self.bg):anchor(0, 0)
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
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"ÍÌ  ÊÉ",
			16,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot5, self.bg):anchor(0.5, 0.5):pos(124, 37)

	return 
end
horseEat.fillListView = function (self)
	local wingList = self.wingList
	self.scrollHeight = 0

	for i, v in ipairs(def.wing.getAllBaseCfg()) do
		if i%10 == 0 then
			local item = display.newSprite(res.gettex2("pic/panels/horseUpgrade/eat_item.png"))

			display.newSprite(res.gettex2("pic/panels/horseUpgrade/head_1_c.png")):add2(item):pos(37, 37):enableClick(function ()
				local ss = {}
				local level = i
				local lvStr = def.wing.level2str(level) .. "¡¤ÓðÒí"

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
			an.newLabel("Óð Òí", 20, 1, {
				color = cc.c3b(220, 210, 190)
			}).anchor(slot8, 0, 0.5):addto(item):pos(67, 48)
			an.newLabel(def.wing.level2str(i), 20, 1, {
				color = cc.c3b(240, 200, 150)
			}):anchor(0, 0.5):addto(item):pos(67, 22)

			item.checked = false

			an.newBtn(res.gettex2("pic/common/toggle12.png"), function (dd)
				print("dsadsadsadsa", dd)

				return 
			end, {
				support = "easy",
				select = {
					res.gettex2("pic/common/toggle13.png"),
					manual = true
				}
			}).anchor(slot8, 0.5, 0.5):pos(177, 20):addTo(item)
			self.listViewPushBack(self, wingList, item)

			self.scrollHeight = self.scrollHeight + item.geth(item) + 4
		end
	end

	return 
end

return horseEat
