local militaryRankPreview = class("militaryRankPreview", import(".panelBase"))
local tip = import(".TipInfo")
militaryRankPreview.ctor = function (self, param)
	self.super.ctor(self)
	self.setMoveable(self, true)

	return 
end
militaryRankPreview.onEnter = function (self)
	self.initPanelUI(self, {
		title = "æ¸œŒ‘§¿¿",
		bg = "pic/panels/wingUpgrade/previewBg.png"
	})
	self.pos(self, display.cx + 285, display.cy)
	self.loadMainPage(self)

	return 
end
militaryRankPreview.loadMainPage = function (self)
	self.content = self.bg
	local scrollRect = cc.rect(0, 0, 200, 400)
	local militaryRankList = self.newListView(self, 10, 8, scrollRect.width, scrollRect.height, 4, {}):add2(self.bg)
	self.militaryRankList = militaryRankList

	self.fillListView(self)

	local rollbg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 174, 8, cc.size(20, 400)):addTo(self.bg):anchor(0, 0)
	local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)

	militaryRankList.setScrollOffset(militaryRankList, 0, -10)
	militaryRankList.setListenner(militaryRankList, function (event)
		if event.name == "moved" then
			local x, y = militaryRankList:getScrollOffset()
			local scrollHeight = self.scrollHeight
			local maxOffset = scrollHeight - militaryRankList:geth()

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
	militaryRankList.setScrollOffset(slot2, 0, 0)

	return 
end
militaryRankPreview.fillListView = function (self)
	self.scrollHeight = 0

	for i, v in ipairs(def.militaryRank.getMilitaryPropertyByFilter("ŒÂµ»")) do
		local itemImg = res.gettex2("pic/panels/militaryRank/btnUnselect.png")
		local itembg = nil
		slot8 = an.newBtn(itemImg, function ()
			local job = g_data.player.job
			local props = def.property.dumpPropertyStr("")
			local tmpProps = def.property.dumpPropertyStr(v.PropertyStr)

			props.mergeProp(props, tmpProps)
			props.clearZero(props):toStdProp():grepJob(job)

			local ss = {}

			table.insert(ss, {
				v.MilitaryRankName,
				cc.c3b(255, 255, 0)
			})

			for j, p in ipairs(props.props) do
				local valueStr = (p[3] ~= nil and p[2] .. "-" .. p[3]) or "+" .. p[2]

				table.insert(ss, {
					p[1] .. ":" .. valueStr,
					display.COLOR_WHITE
				})
			end

			local x, y = itembg:getPosition()
			local xoffset, yoffset = self.militaryRankList:getScrollOffset()

			tip.show(ss, {
				x = x + 60,
				y = y + yoffset
			}, {
				parent = self
			})

			return 
		end, {
			support = "scroll",
			pressImage = itemImg
		})
		itembg = slot8
		local rank = v.MilitaryRankLv

		an.newLabel(v.MilitaryRankName, 20, 0, {
			color = def.militaryRank.getColorByRank(rank)
		}):addTo(itembg):pos(itembg.getw(itembg)/2, itembg.geth(itembg)/2):anchor(0.5, 0.5)
		self.listViewPushBack(self, self.militaryRankList, itembg)

		self.scrollHeight = self.scrollHeight + itembg.geth(itembg)
	end

	return 
end

return militaryRankPreview
