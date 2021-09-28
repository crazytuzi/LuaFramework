local teamCompetitionTop = class("teamCompetitionTop", function ()
	return display.newNode()
end)
local common = import("..common.common")

table.merge(slot0, {})

teamCompetitionTop.ctor = function (self)
	local bg = res.get2("pic/common/black_6.png")
	local bgSize = bg.getContentSize(bg)

	bg.anchor(bg, 0, 0)
	bg.addto(bg, self)

	self.bg = bg

	self.size(self, bgSize)
	self.pos(self, display.width/2 - bgSize.width/2 + 50, display.height/2 - bgSize.height/2)
	self.setTouchSwallowEnabled(self, true)

	self._supportMove = true

	an.newLabel("当前排行", 20, 0, {
		color = def.colors.Cd2b19c
	}):anchor(0.5, 0.5):addTo(bg):pos(bg.getw(bg)/2, bg.geth(bg) - 22)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).addTo(slot3, bg):pos(bg.getw(bg) - 9, bg.geth(bg) - 9):anchor(1, 1)

	local Titlelabel = {
		"排行",
		"战队队长",
		"胜场",
		"击败数",
		"胜场用时"
	}
	local titleWidth = {
		70,
		150,
		60,
		75,
		103
	}
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(458, 42)):anchor(0, 1):pos(10, 407):add2(self.bg)

	for k, v in ipairs(Titlelabel) do
		local posX = 0

		if 1 < k then
			for i = 1, k - 1, 1 do
				posX = posX + titleWidth[i]
			end

			display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(posX, 0):add2(titlebg)
		end

		posX = posX + titleWidth[k]/2

		an.newLabel(v, 20, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(posX, titlebg.geth(titlebg)/2):addTo(titlebg)
	end

	local rect = cc.rect(10, 12, 458, 352)
	self.scroll = an.newScroll(rect.x, rect.y, rect.width, rect.height):addto(self.bg)

	self.scroll:setScrollSize(rect.width, rect.height + 1)

	local rollbg = display.newScale9Sprite(res.getframe2("pic/common/sliderBg4.png"), 470, 12, cc.size(20, 394)):addTo(self.bg):anchor(0, 0)
	local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)

	self.scroll:setListenner(function (event)
		if event.name == "moved" then
			local x, y = self.scroll:getScrollOffset()
			local maxOffset = self.scroll:getScrollSize().height - self.scroll:geth()

			if y < 0 then
				y = 0
			end

			if maxOffset < y then
				y = maxOffset or y
			end

			rollCeil:setPositionY((rollbg:geth() - 42)*(y/maxOffset - 1))
		end

		return 
	end)
	MirTcpClient.getInstance(slot9):subscribeMemberOnProtocol(SM_GroupBattleReqRank, self, self.onSM_GroupBattleReqRank)

	local rsb = DefaultClientMessage(CM_GroupBattleReqRank)

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end
teamCompetitionTop.onSM_GroupBattleReqRank = function (self, result, protoId)
	if result.Fres ~= 0 then
		return 
	end

	if self.scroll then
		self.scroll:removeAllChildren()
	end

	local rankList = result.FRank or {}
	local cellHeight = 42
	local rect = cc.rect(10, 12, 458, 352)
	local titleWidth = {
		70,
		150,
		60,
		75,
		103
	}
	local scrollHeight = math.max(cellHeight*#rankList, rect.height + 1)

	self.scroll:setScrollSize(rect.width, scrollHeight)

	for k, v in ipairs(rankList) do
		local cellBg = res.getframe2((k%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png")
		local cell = an.newBtn(cellBg, function ()
			return 
		end, {
			support = "scroll",
			scale9 = cc.size(rect.width, slot4)
		}):anchor(0, 1):pos(0, scrollHeight - cellHeight*(k - 1)):addto(self.scroll)

		an.newLabel(k .. "", 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(35, cell.geth(cell)/2):addTo(cell)
		an.newLabel(v.Fleadername, 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(145, cell.geth(cell)/2):addTo(cell)
		an.newLabel(v.Fwarres, 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(250, cell.geth(cell)/2):addTo(cell)
		an.newLabel(v.Fwincnt, 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(318, cell.geth(cell)/2):addTo(cell)

		local timeStr = os.date("%M:%S", v.Fdt)

		an.newLabel(timeStr, 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(405, cell.geth(cell)/2):addTo(cell)
	end

	return 
end

return teamCompetitionTop
