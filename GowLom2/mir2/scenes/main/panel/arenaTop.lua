local arenaTop = class("arenaTop", function ()
	return display.newNode()
end)
local common = import("..common.common")

table.merge(slot0, {})

arenaTop.ctor = function (self, params)
	params = params or {}
	self.tag2 = params.tag2 or "arena"
	local bg = res.get2("pic/common/black_2.png")
	local bgSize = bg.getContentSize(bg)

	bg.anchor(bg, 0, 0)
	bg.addto(bg, self)

	self.bg = bg

	self.size(self, bgSize)
	self.pos(self, display.width/2 - bgSize.width/2 + 50, display.height/2 - bgSize.height/2)
	self.setTouchSwallowEnabled(self, true)

	self._supportMove = true

	an.newLabel("跨服竞技排行", 20, 0, {
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

	local texts = {
		{
			"1.排行榜实时刷新。\n"
		},
		{
			"2.本榜单只显示跨服竞技中前200名玩家。\n"
		},
		{
			"3.排行榜每周重置。\n"
		}
	}

	an.newBtn(res.gettex2("pic/common/question.png"), function ()
		sound.playSound("103")
		an.newMsgbox(texts, nil, {
			contentLabelSize = 20,
			title = "提示"
		})

		return 
	end, {
		pressBig = true,
		pressImage = res.gettex2("pic/common/question.png")
	}).pos(slot5, 24, 432):addto(bg)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ArenaReqTop100, self, self.onSM_ArenaReqTop100)
	self.query(self)

	return 
end
arenaTop.onSM_ArenaReqTop100 = function (self, result, protoId)
	if not result or result.Fres ~= 0 then
		return 
	end

	local rankList = result.Flist or {}

	if self.tag2Node then
		self.tag2Node:removeSelf()
	end

	self.tag2Node = display.newNode():addTo(self.bg)
	local job_name = {
		[0] = "战士",
		"法师",
		"道士"
	}

	display.newScale9Sprite(res.getframe2("pic/common/black_4.png")):anchor(0, 0):pos(12, 67):size(618, 339):addTo(self.tag2Node)

	local infoView = an.newScroll(12, 62.5, 618, 300):add2(self.tag2Node)

	infoView.enableTouch(infoView, false)

	local minePos = -1
	local showCount = #rankList or 0
	local tRankList = {}
	local width = {
		72,
		160,
		160,
		92,
		150
	}
	local Titlelabel = {
		"排名",
		"名称",
		"职业",
		"等级",
		"服务器"
	}
	local posOffset = 16
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(self.getw(self) - posOffset - 15, 42)):anchor(0, 1):pos(posOffset, self.geth(self) - 52):add2(self.tag2Node)

	for i, v in ipairs(width) do
		an.newLabel(Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v*0.5, self.bg:geth() - 72):add2(self.tag2Node, 2)

		posOffset = posOffset + v

		if i == #width then
			break
		end

		display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(posOffset, self.geth(self) - 94):add2(self.tag2Node)
	end

	if type(rankList) == "table" and 0 < #rankList then
		local roleID = g_data.player.roleid

		table.sort(rankList, function (a, b)
			return tonumber(a.Fidx) < tonumber(b.Fidx)
		end)

		for i = 1, math.min(slot7, #rankList), 1 do
			local v = rankList[i]

			if not tRankList[math.ceil(i/7)] then
				tRankList[math.ceil(i/7)] = {}
			end

			local tRecode = tRankList[math.ceil(i/7)]
			tRecode[#tRecode + 1] = v

			if roleID == v.Fuserid then
				minePos = math.ceil(i/7)
			end
		end
	else
		an.newLabel("暂时没有排名", 22, 1, def.colors.labelGray):anchor(0.5, 0.5):pos(infoView.getw(infoView)/2, infoView.geth(infoView)*0.5 + 30):add2(infoView)
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
		local cellHeight = 42

		infoView:setScrollSize(615, cellHeight*7)

		self.currentIndex = 0
		local selectedBox = display.newScale9Sprite(res.getframe2("pic/common/select.png"), 0, 0, cc.size(618, cellHeight)):anchor(0, 0):pos(-1, infoView:getScrollSize().height + cellHeight):add2(tTableNode, 100)

		local function selectCallBack(nIndex, roleID)
			if self.currentIndex == nIndex then
				if g_data.client:checkLastTime("equipOther_Top", 0.8) then
					g_data.client:setLastTime("equipOther_Top", true)

					local rsb = DefaultClientMessage(CM_ArenaReqUserinfo)
					rsb.Fuserid = roleID
					rsb.Fquerytype = 0

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

			if v.Fuserid ~= roleID or not {
				color = cc.c3b(255, 205, 55)
			} then
				local tmpColor = {
					color = def.colors.labelGray
				}
			end

			local cellBg = res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png")
			local cell = an.newBtn(slot12, function ()
				selectCallBack(i, v.Fuserid)

				return 
			end, {
				size = cc.size(615, tTableNode),
				scale9 = cc.size(615, cellHeight),
				pressImage = cellBg
			}):pos(infoView:getScrollSize().width/2 - 1, infoView:getScrollSize().height - i*cellHeight + cellHeight/2):addto(tTableNode)

			an.newLabel(v.Fidx, 18, 1, tmpColor):anchor(0.5, 0.5):pos(width[1]*0.5 + 4, cell.geth(cell)*0.5):add2(cell)
			an.newLabel(v.Fusername, 18, 1, tmpColor):anchor(0.5, 0.5):pos(width[1] + width[2]*0.5 + 4, cell.geth(cell)*0.5):add2(cell)
			an.newLabel(job_name[v.Fjob], 18, 1, tmpColor):anchor(0.5, 0.5):pos(width[1] + width[2] + width[3]*0.5 + 4, cell.geth(cell)*0.5):add2(cell)

			local strlvl = common.getLevelText(v.Flevel) .. "级"

			an.newLabel(strlvl, 18, 1, tmpColor):anchor(0.5, 0.5):pos(width[1] + width[2] + width[3] + width[4]*0.5 + 4, cell.geth(cell)*0.5):add2(cell)

			if tonumber(v.Fuserzoneid) == 0 then
				an.newLabel("无", 18, 1, tmpColor):anchor(0.5, 0.5):pos(width[1] + width[2] + width[3] + width[4] + width[5]*0.5, cell.geth(cell)*0.5):add2(cell)
			else
				local severId = 0

				if 1 <= tonumber(v.Fuserzoneid) and tonumber(v.Fuserzoneid) <= 10000 then
					severId = tonumber(v.Fuserzoneid)
				elseif tonumber(v.Fuserzoneid) == 30000 then
					severId = 1
				else
					severId = tonumber(v.Fuserzoneid)%10000
				end

				an.newLabel(severId .. "区", 18, 1, tmpColor):anchor(0.5, 0.5):pos(width[1] + width[2] + width[3] + width[4] + width[5]*0.5, cell.geth(cell)*0.5):add2(cell)
			end
		end

		return 
	end

	slot15(1)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		main_scene.ui:togglePanel("arenaRankReward")

		return 
	end, {
		label = {
			"排名奖励",
			20,
			0,
			{
				color = def.colors.Cf0c896
			}
		},
		pressImage = res.gettex2("pic/common/btn21.png")
	}).pos(slot16, (self.bg:getw() + 34) - 500, 38):addto(self.tag2Node)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		switchPage(1)

		return 
	end, {
		label = {
			"首页",
			20,
			0,
			{
				color = def.colors.Cf0c896
			}
		},
		pressImage = res.gettex2("pic/common/btn21.png")
	}).pos(slot16, (self.bg:getw() + 34) - 400, 38):addto(self.tag2Node)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		switchPage(nPageIndex - 1)

		return 
	end, {
		label = {
			"上一页",
			20,
			0,
			{
				color = def.colors.Cf0c896
			}
		},
		pressImage = res.gettex2("pic/common/btn21.png")
	}).pos(slot16, (self.bg:getw() + 34) - 300, 38):addto(self.tag2Node)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		switchPage(nPageIndex + 1)

		return 
	end, {
		label = {
			"下一页",
			20,
			0,
			{
				color = def.colors.Cf0c896
			}
		},
		pressImage = res.gettex2("pic/common/btn21.png")
	}).pos(slot16, (self.bg:getw() + 34) - 200, 38):addto(self.tag2Node)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if minePos == -1 then
			an.newMsgbox("你没有上榜或不在该榜")
		else
			switchPage(minePos)
		end

		return 
	end, {
		label = {
			"我的排行",
			20,
			0,
			{
				color = def.colors.Cf0c896
			}
		},
		pressImage = res.gettex2("pic/common/btn21.png")
	}).pos(slot16, (self.bg:getw() + 34) - 100, 38):addto(self.tag2Node)

	return 
end
arenaTop.query = function (self)
	local rsb = DefaultClientMessage(CM_ArenaReqTop100)

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end

return arenaTop
