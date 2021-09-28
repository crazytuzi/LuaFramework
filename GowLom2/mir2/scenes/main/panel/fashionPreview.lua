local fashionPreview = class("fashionPreview", import(".panelBase"))
local tip = import(".TipInfo")
fashionPreview.ctor = function (self, param)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.data = param.data
	self.job = param.job or g_data.player.job

	return 
end
fashionPreview.onEnter = function (self)
	self.initPanelUI(self, {
		title = "预览",
		bg = "pic/panels/wingUpgrade/previewBg.png"
	})
	self.pos(self, display.cx + 370, display.cy)
	self.loadMainPage(self)

	return 
end
fashionPreview.loadMainPage = function (self)
	self.content = self.bg
	local scrollRect = cc.rect(0, 0, 200, 400)
	local fashionList = self.newListView(self, 10, 8, scrollRect.width, scrollRect.height, 4, {}):add2(self.bg)
	self.fashionList = fashionList

	self.fillListView(self)

	local rollbg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 174, 8, cc.size(20, 400)):addTo(self.bg):anchor(0, 0)
	local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)

	fashionList.setScrollOffset(fashionList, 0, -10)
	fashionList.setListenner(fashionList, function (event)
		if event.name == "moved" then
			local x, y = fashionList:getScrollOffset()
			local scrollHeight = self.scrollHeight
			local maxOffset = scrollHeight - fashionList:geth()

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
	fashionList.setScrollOffset(slot2, 0, 0)

	return 
end
fashionPreview.fillListView = function (self)
	local info = def.fashion.getFashionInfoByIdx(self.data.idx)
	self.scrollHeight = 0

	for i, v in ipairs(def.fashion.getAllLevelByIdx(self.data.idx)) do
		if self.data.FLevel + 1 == v.FELevel then
			local itemImg = res.gettex2("pic/panels/wingUpgrade/previewItem.png")
			local itembg = nil
			slot9 = an.newBtn(itemImg, function ()
				local job = self.job
				local props = def.property.dumpPropertyStr("")
				local tmpProps = def.property.dumpPropertyStr(v.ProStr)

				props.mergeProp(props, tmpProps)
				props.clearZero(props):toStdProp():grepJob(job)

				local ss = {}

				table.insert(ss, {
					self:numToGBK(v.FELevel) .. "星" .. info.FEName,
					cc.c3b(255, 255, 0)
				})

				if 0 < v.UpNeedLv then
					table.insert(ss, {
						"需要人物等级:" .. tostring(common.getLevelText(v.UpNeedLv) .. "级"),
						display.COLOR_WHITE
					})
				end

				if 0 < v.UpNeedSvrStep then
					table.insert(ss, {
						"需要服务器阶段:" .. self:numToGBK(v.UpNeedSvrStep) .. "阶",
						display.COLOR_WHITE
					})
				end

				for j, p in ipairs(props.props) do
					local valueStr = (p[3] ~= nil and p[2] .. "-" .. p[3]) or "+" .. p[2]

					table.insert(ss, {
						p[1] .. ":" .. valueStr,
						display.COLOR_WHITE
					})
				end

				local x, y = itembg:getPosition()
				local xoffset, yoffset = self.fashionList:getScrollOffset()

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
			itembg = slot9

			res.get(self.data.itemaltlas, self.data.itemid):addto(itembg):anchor(0.5, 0.5):pos(37, 37)
			an.newLabel(self.numToGBK(self, v.FELevel) .. "星", 20, 0, {
				color = def.colors.Cf0c896
			}):addTo(itembg):pos(itembg.getw(itembg)/2 + 20, itembg.geth(itembg)/2 - 15):anchor(0.5, 0.5)
			an.newLabel(info.FEName, 20, 0, {
				color = def.colors.Cdcd2be
			}):addTo(itembg):pos(itembg.getw(itembg)/2 + 20, itembg.geth(itembg) - 20):anchor(0.5, 0.5)
			self.listViewPushBack(self, self.fashionList, itembg)

			self.scrollHeight = self.scrollHeight + itembg.geth(itembg)
		end
	end

	return 
end
fashionPreview.numToGBK = function (self, num)
	local TXT_NUM = {
		[0] = "零",
		"一",
		"二",
		"三",
		"四",
		"五",
		"六",
		"七",
		"八",
		"九",
		"十"
	}

	if TXT_NUM[num] then
		return TXT_NUM[num]
	else
		return TXT_NUM[1]
	end

	return 
end

return fashionPreview
