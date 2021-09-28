local battleRankList = class("battleRankList", function ()
	return display.newNode()
end)
local common = import("..common.common")

table.merge(slot0, {})

battleRankList.ctor = function (self, params)
	params = params or {}
	local bg = res.get2("pic/common/black_2.png")
	local bgSize = bg.getContentSize(bg)

	bg.anchor(bg, 0, 0)
	bg.addto(bg, self)

	self.bg = bg

	self.size(self, bgSize)
	self.pos(self, display.width/2 - bgSize.width/2, display.height/2 - bgSize.height/2)
	self.setTouchSwallowEnabled(self, true)

	self._supportMove = true

	display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(621, 336)):anchor(0, 0):pos(10, 70):add2(self.bg)
	an.newLabel("排行榜", 20, 0, {
		color = def.colors.Cd2b19c
	}):anchor(0.5, 0.5):addTo(bg):pos(bg.getw(bg)/2, bg.geth(bg) - 22)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).addTo(slot4, bg):pos(bg.getw(bg) - 9, bg.geth(bg) - 9):anchor(1, 1)
	self.processUpt(self, params.LolerList or {})

	return 
end
battleRankList.processUpt = function (self, LolerList)
	local infoView = an.newScroll(10, 67, 621, 296):add2(self.bg)

	infoView.enableTouch(infoView, false)

	local minePos = -1
	local cellHeight = 0
	local width = {
		95,
		120,
		100,
		100,
		100,
		100
	}
	local showCount = 1000
	local tRankList = {}
	local Titlelabel = {
		"名次",
		"角色名",
		"等级",
		"职业",
		"积分",
		"阵营"
	}
	local posOffset = 14

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/panels/equip/titlebg.png"), 0, 0, cc.size(v - 2, 40)):anchor(0.5, 0.5):pos(posOffset + v*0.5, self.bg:geth() - 73):add2(self.bg)
		an.newLabel(Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v*0.5, self.bg:geth() - 75):add2(self.bg)

		posOffset = posOffset + v
	end

	if type(LolerList) == "table" and 0 < #LolerList then
		local roleID = g_data.player.roleid

		table.sort(LolerList, function (a, b)
			return tonumber(a.FRank) < tonumber(b.FRank)
		end)

		for i = 1, math.min(slot6, #LolerList), 1 do
			local v = LolerList[i]

			if not tRankList[math.ceil(i/7)] then
				tRankList[math.ceil(i/7)] = {}
			end

			local tRecode = tRankList[math.ceil(i/7)]
			tRecode[#tRecode + 1] = v

			if roleID == v.FUserId then
				minePos = math.ceil(i/7)
			end
		end
	else
		an.newLabel("暂时没有排名", 22, 1, def.colors.labelGray):anchor(0.5, 0.5):pos(infoView.getw(infoView)/2, infoView.geth(infoView)*0.5 + 20):add2(infoView)
	end

	local tTableNode = nil
	local nPageIndex = 1

	local function switchPage(nIndex)
		local recode = tRankList[nIndex]

		if not recode then
			return 
		end

		nPageIndex = nIndex

		if tTableNode then
			tTableNode:removeSelf()
		end

		tTableNode = display.newNode():addTo(infoView)
		cellHeight = 42

		infoView:setScrollSize(631, cellHeight*7)

		self.currentIndex = 0
		local selectedBox = display.newScale9Sprite(res.getframe2("pic/scale/scale25.png"), 0, 0, cc.size(621, cellHeight)):anchor(0, 0):pos(-1, infoView:getScrollSize().height + cellHeight):add2(tTableNode, 100)

		local function selectCallBack(nIndex, roleID)
			if self.currentIndex == nIndex then
				if g_data.client:checkLastTime("equipOther_Top", 0.8) then
					g_data.client:setLastTime("equipOther_Top", true)

					local rsb = DefaultClientMessage(CM_QUERYUSERSTATE)
					rsb.FPlayerByID = roleID

					MirTcpClient:getInstance():postRsb(rsb)
				end
			else
				self.currentIndex = nIndex

				selectedBox:pos(-1, infoView:getScrollSize().height - nIndex*cellHeight)
			end

			return 
		end

		local roleID = g_data.player.roleid

		for i = 1, math.min(7, #recode), 1 do
			local v = recode[i]

			if v.FUserId ~= roleID or not {
				color = cc.c3b(255, 205, 55)
			} then
				local tmpColor = {
					color = def.colors.labelGray
				}
			end

			local cellBg = res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png")
			local cell = an.newBtn(slot11, function ()
				selectCallBack(i, v.FUserId)

				return 
			end, {
				size = cc.size(631, cellHeight),
				scale9 = cc.size(631, cellHeight),
				pressImage = cellBg
			}).pos(slot12, infoView:getScrollSize().width/2 - 1, infoView:getScrollSize().height - i*cellHeight + cellHeight/2):addto(tTableNode)
			local contentlabel = {
				v.FRank,
				v.FUserName,
				v.FLevel,
				v.Fjob,
				v.FScore,
				v.FGroup
			}
			posOffset = 14

			for i, v in ipairs(width) do
				an.newLabel(contentlabel[i], 18, 1, tmpColor):anchor(0.5, 0.5):pos((posOffset + v*0.5) - 10, cell.geth(cell)*0.5):add2(cell)

				posOffset = posOffset + v
			end
		end

		return 
	end

	slot12(1)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		switchPage(1)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/top/sy.png")
	}).pos(slot13, (self.bg:getw() + 34) - 400, 38):addto(self.bg)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		switchPage(nPageIndex - 1)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/top/syy.png")
	}).pos(slot13, (self.bg:getw() + 34) - 300, 38):addto(self.bg)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		switchPage(nPageIndex + 1)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/top/xyy.png")
	}).pos(slot13, (self.bg:getw() + 34) - 200, 38):addto(self.bg)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if minePos == -1 then
			an.newMsgbox("你没有上榜或不在该榜", nil, {
				center = true
			})
		else
			switchPage(minePos)
		end

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/top/wdpm.png")
	}).pos(slot13, (self.bg:getw() + 34) - 100, 38):addto(self.bg)

	return 
end

return battleRankList
