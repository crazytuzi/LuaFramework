local soliderPreview = class("soliderPreview", import(".panelBase"))
local tip = import(".wingInfo")
soliderPreview.ctor = function (self, id)
	self.super.ctor(self)

	self.id = id

	self.setMoveable(self, true)

	return 
end
soliderPreview.onEnter = function (self)
	self.initPanelUI(self, {
		title = "神兵预览",
		bg = "pic/panels/wingUpgrade/previewBg.png"
	})
	self.pos(self, display.cx + 320, display.cy)
	self.loadMainPage(self)

	return 
end
soliderPreview.loadMainPage = function (self)
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
soliderPreview.fillListView = function (self)
	local wingList = self.wingList
	self.scrollHeight = 0
	local img = def.solider.imgCfg[self.id]
	local name = def.solider.nameCfg[self.id]

	for i, v in ipairs(def.solider.allUpCfg) do
		if v.ID == self.id and v.GodWeaponLevel ~= 0 and v.GodWeaponLevel%10 == 0 then
			local item = display.newSprite(res.gettex2("pic/panels/wingUpgrade/previewItem.png"))

			display.newSprite(res.gettex2("pic/panels/solider/" .. img .. ".png")):add2(item):pos(37, 37):enableClick(function ()
				local ss = {}
				local lvStr = def.wing.level2str(v.GodWeaponLevel) .. "·" .. name

				table.insert(ss, {
					lvStr,
					cc.c3b(255, 255, 0)
				})

				local job = g_data.player.job
				local props = def.solider:getProps(self.id, v.GodWeaponLevel, job)

				for i, v in ipairs(props.props) do
					local p = props.getPropStrings(props, v[1])
					local valueStr = (p[3] ~= nil and p[2] .. "-" .. p[3]) or "+" .. p[2]
					local str = ""

					if p[1] == "神兽形象改变" then
						if job == 2 then
							str = def.solider:convertPropName(p[1])
						end
					else
						str = string.format("%s: %s", def.solider:convertPropName(p[1]), valueStr)
					end

					table.insert(ss, {
						str,
						display.COLOR_WHITE
					})
				end

				tip.show(ss, item:convertToWorldSpace(cc.p(0, 0)), {})

				return 
			end)
			an.newLabel(slot3, 20, 1, {
				color = cc.c3b(220, 210, 190)
			}):anchor(0, 0.5):addto(item):pos(67, 48)
			an.newLabel(def.wing.level2str(v.GodWeaponLevel), 20, 1, {
				color = cc.c3b(240, 200, 150)
			}):anchor(0, 0.5):addto(item):pos(67, 22)
			self.listViewPushBack(self, wingList, item)

			self.scrollHeight = self.scrollHeight + item.geth(item) + 4
		end
	end

	return 
end

return soliderPreview
