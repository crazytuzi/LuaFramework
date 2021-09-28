local item = import("..common.item")
local rankEquip = class("rankEquip", function ()
	return display.newLayer()
end)
local tip = import(".wingInfo")

table.merge(slot1, {
	equipData = {},
	frame = {},
	items = {},
	equipNameLabel = {}
})

local equipName = {
	"盾牌",
	"玉佩",
	"兵符",
	"花翎",
	"配剑",
	"战旗",
	"官印",
	"兵书"
}
rankEquip.ctor = function (self, _params)
	self.isOther = _params.isOther
	self.items = {}
	self.equipNameLabel = {}
	self.equipData = (_params.isOther and _params.otherEquipList) or g_data.equip
	local job = (_params.isOther and _params.job) or g_data.player.job
	self._supportMove = true
	local panelBg = res.get2("pic/panels/rankEquip/bg.png"):anchor(0, 0):add2(self)
	self.panelBg = panelBg

	self.size(self, panelBg.getContentSize(panelBg)):anchor(0.5, 0.5):pos(display.width - 165, display.cy + 30)

	local px = display.width - 165
	local py = display.cy + 30

	if _params.isOther and main_scene.ui.panels.equipOther then
		px, py = main_scene.ui.panels.equipOther:getPosition()
	elseif not _params.isOther and main_scene.ui.panels.equip then
		px, py = main_scene.ui.panels.equip:getPosition()
	end

	self.pos(self, px, py)
	an.newLabel("军衔装备", 20, 0, {
		color = def.colors.Cf0c896
	}):anchor(0.5, 0.5):pos(panelBg.getw(panelBg)/2, panelBg.geth(panelBg) - 23):addTo(panelBg)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:closePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot6, 0.5, 1):pos(self.getw(self) - 22, self.geth(self) - 8):addto(self, 1)

	local requiredRank = {
		1,
		3,
		5,
		7,
		0,
		0,
		0,
		0
	}
	local RankEquipInfoList = (_params.isOther and _params.RankEquipInfoList) or g_data.player.militaryEquip
	local showingMilitaryRank = (_params.isOther and _params.otherRankLv) or g_data.player.militaryRank
	self.frame = {}
	local tFrameOpened = {
		true,
		true,
		true,
		true,
		true,
		true,
		true,
		true
	}

	for i = 1, #equipName, 1 do
		local posX = 30

		if 5 <= i then
			self.frame[i] = res.get2("pic/panels/rankEquip/frame.png"):addto(panelBg):pos(86, panelBg.geth(panelBg) - 92 - (i - 1 - 4)*73):anchor(0, 0.5)
		else
			self.frame[i] = res.get2("pic/panels/rankEquip/frame.png"):addto(panelBg):pos(19, panelBg.geth(panelBg) - 92 - (i - 1)*73):anchor(0, 0.5)
		end

		if showingMilitaryRank < requiredRank[i] then
			an.newBtn(res.gettex2("pic/panels/storage/icon_lock_bg.png"), function ()
				sound.playSound("103")
				self:showTip(self.frame[i], requiredRank[i], i)

				return 
			end, {
				size = cc.size(64, 64)
			}).pos(slot15, self.frame[i]:getw()/2, self.frame[i]:geth()/2):addto(self.frame[i])

			tFrameOpened[i] = false
		end
	end

	local equipTable = (_params.isOther and self.equipData) or self.equipData.items
	local tEquiped = {
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false
	}

	for k, v in pairs(equipTable) do
		if 17 <= k and k <= 20 then
			local indexFrame = k - 16
			self.items[k] = item.new(v, self, {
				idx = k,
				donotMove = _params.isOther
			}):addto(panelBg, 10):pos(self.frame[indexFrame]:getPositionX() + self.frame[indexFrame]:getw()/2, self.frame[indexFrame]:getPositionY())
			tEquiped[indexFrame] = true
		end
	end

	for i = 1, #RankEquipInfoList, 1 do
		local v = RankEquipInfoList[i]
		local indexFrame = v.FID + 4

		if 0 < v.FLevel then
			tEquiped[indexFrame] = true
			local curEquip = def.militaryEquip.getEquipPropertyByLevel(v.FID, v.FLevel)
			local img = def.militaryEquip.getEquipIcon(curEquip):addto(self.frame[indexFrame], i):pos(self.frame[indexFrame]:getw()/2, self.frame[indexFrame]:geth()/2)

			img.enableClick(img, function ()
				local ss = {}
				local lvStr = curEquip.RELevel .. "级" .. equipName[curEquip.REID + 4]

				table.insert(ss, {
					lvStr,
					cc.c3b(255, 255, 0)
				})

				for i, k in ipairs(def.militaryEquip.dumpPropStr(curEquip.PropertyStr, job)) do
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
					"需要等级:" .. common.getLevelText(curEquip.NeedPlayerLevel),
					display.COLOR_WHITE
				})
				table.insert(ss, {
					curEquip.Desc,
					display.COLOR_WHITE
				})
				tip.show(ss, img:convertToWorldSpace(cc.p(0, 0)), {})

				return 
			end)
		end
	end

	for k, v in ipairs(slot11) do
		if not v and tFrameOpened[k] then
			self.equipNameLabel[k] = an.newLabel(equipName[k], 20, 0, {
				color = cc.c3b(70, 69, 69)
			}):anchor(0.5, 0.5):addto(self.frame[k]):pos(self.frame[k]:getw()/2, self.frame[k]:geth()/2)
		end
	end

	return 
end
rankEquip.onExit = function (self)
	return 
end
rankEquip.closePanel = function (self)
	self.removeSelf(self)
	cc.Director:getInstance():getEventDispatcher():dispatchNodeEvent("LuaNode_removeSelf", self)

	if main_scene.ui.panels.equip and not self.isOther then
		main_scene.ui.panels.equip:adjustTouchFrame(true)
	end

	return 
end
rankEquip.showTip = function (self, _frame, _reqRankLevel, _index)
	local nodeEquipInfo = display.newNode():size(display.width, display.height):addto(display.getRunningScene(), an.z.max)

	nodeEquipInfo.setTouchEnabled(nodeEquipInfo, true)
	nodeEquipInfo.setTouchSwallowEnabled(nodeEquipInfo, false)
	nodeEquipInfo.enableClick(nodeEquipInfo, function ()
		nodeEquipInfo:removeSelf()

		nodeEquipInfo = nil

		return 
	end)

	local labels = {}
	local maxWidth = 180

	function add(text, color, fontSize)
		text = text or ""
		labels[#labels + 1] = an.newLabel(text, fontSize or 20, 1, {
			color = color
		})

		if maxWidth < labels[#labels]:getw() then
			labels[#labels]:setWidth(maxWidth)
			labels[#labels]:setLineBreakWithoutSpace(true)
			labels[#labels]:updateContent()
		end

		return 
	end

	local frameName = {
		"盾牌",
		"玉佩",
		"兵符",
		"花翎"
	}

	add(frameName[_index] .. "格:军衔达到" .. def.militaryRank.getMilitaryPropertyByRank(slot2).MilitaryRankName .. "开启", display.COLOR_WHITE)

	local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale24.png")):addto(nodeEquipInfo):anchor(0, 1)
	local w = 0
	local h = 7
	local space = -2

	for i = #labels, 1, -1 do
		local lh = 0
		w = math.max(w, labels[i]:getw())
		lh = labels[i]:geth()

		labels[i]:addto(bg, 99):pos(10, h):anchor(0, 0)

		local words = utf8strs(labels[i]:getString())
		h = h + lh + space
	end

	local content = an.newLabelM(maxWidth, 20, 1):anchor(0, 0):addto(bg, 99):pos(10, h):anchor(0, 0)
	w = math.max(w, content.widthCnt)
	w = w + 20
	h = h + 10

	bg.size(bg, w, h)

	local rect = cc.rect(0, 0, display.width, display.height)
	local p = _frame.convertToWorldSpace(_frame, cc.p(_frame.getw(_frame)/2, _frame.geth(_frame)/2))

	if p.x < rect.x then
		p.x = rect.x
	end

	if rect.width < p.x + w then
		p.x = p.x - w + 5
	end

	if rect.height < p.y then
		p.y = rect.height
	end

	if p.y - h < rect.y then
		p.y = p.y + h
	end

	bg.pos(bg, p.x, p.y)

	return 
end
rankEquip.setItem = function (self, makeIndex)
	local k, v = self.equipData:getItem(makeIndex)

	if 17 <= k and k <= 20 then
		if self.items[k] then
			self.items[k]:removeSelf()

			self.items[k] = nil
		end

		local indexFrame = k - 16
		self.items[k] = item.new(v, self, {
			idx = k
		}):addto(self.panelBg, 10):pos(self.frame[indexFrame]:getPositionX() + self.frame[indexFrame]:getw()/2, self.frame[indexFrame]:getPositionY())

		if self.equipNameLabel[indexFrame] then
			self.equipNameLabel[indexFrame]:removeSelf()

			self.equipNameLabel[indexFrame] = nil
		end
	end

	return 
end
rankEquip.delItem = function (self, makeIndex)
	for k, v in pairs(self.items) do
		if v.data.FItemIdent == tonumber(makeIndex) then
			self.items[k]:removeSelf()

			self.items[k] = nil
			local frameIndex = k - 16
			self.equipNameLabel[frameIndex] = an.newLabel(equipName[frameIndex], 20, 0, {
				color = cc.c3b(70, 69, 69)
			}):anchor(0.5, 0.5):addto(self.frame[frameIndex]):pos(self.frame[frameIndex]:getw()/2, self.frame[frameIndex]:geth()/2)
		end
	end

	return 
end
rankEquip.pos2idx = function (self, x, y)
	for k, v in ipairs(self.frame) do
		local rect = cc.rect(v.getPositionX(v) - v.getw(v)/2, v.getPositionY(v) - v.geth(v)/2, v.getw(v), v.geth(v))

		if cc.rectContainsPoint(rect, cc.p(x, y)) then
			return k + 16
		end
	end

	return -1
end
rankEquip.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname

	if form == "bag" then
		local putIdx = self.pos2idx(self, x, y)

		if putIdx ~= -1 then
			item.use(item, putIdx)
		end
	end

	return 
end

return rankEquip
