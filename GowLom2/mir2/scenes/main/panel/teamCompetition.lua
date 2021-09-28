local teamCompetition = class("teamCompetition", import(".panelBase"))
local tip = import(".wingInfo")
teamCompetition.ctor = function (self, params)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.params = params or {}
	self.page = self.params.page or 1
	self.tabCallbacks = {}

	return 
end
teamCompetition.onEnter = function (self)
	local tabstr = {
		"训\n练\n赛",
		"锦\n标\n赛"
	}
	local tabcb = {
		self.xunLianYing,
		self.jinBiaoSai
	}
	self.tabCallbacks = tabcb

	self.initPanelUI(self, {
		title = "5v5战队赛",
		bg = "pic/common/black_2.png",
		tab = {
			fontsize = 15,
			strs = tabstr,
			default = self.page
		}
	})
	self.pos(self, display.cx - 102, display.cy)
	self.bindNetEvent(self, SM_Group5v5ReqList, self.onSM_Group5v5ReqList)
	self.bindNetEvent(self, SM_Group5v5ReqEnter, self.onSM_Group5v5ReqEnter)
	self.bindNetEvent(self, SM_Group5v5ReqPk, self.onSM_Group5v5ReqPk)
	self.bindNetEvent(self, SM_GroupBattleReqList, self.onSM_GroupBattleReqList)

	return 
end
teamCompetition.onCloseWindow = function (self)
	return self.super.onCloseWindow(self)
end
teamCompetition.clearContentNode = function (self)
	if self.contentNode then
		self.contentNode:removeSelf()

		self.rightNode = nil
	end

	self.contentNode = display.newNode():addTo(self.bg)
	self.contentNode.controls = {}
	self.contentNode.data = {}

	return 
end
teamCompetition.onTabClick = function (self, idx, btn)
	self.clearContentNode(self)

	self.curTab = self.tabCallbacks[idx]
	self.curIdx = idx

	self.tabCallbacks[idx](self)

	return 
end
teamCompetition.xunLianYing = function (self)
	local rsb = DefaultClientMessage(CM_Group5v5ReqList)

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end
teamCompetition.updateXunLianYing = function (self, result)
	self.clearContentNode(self)

	local texts = {
		{
			"1、两队进入战队赛场后，分别传送在赛场两侧。10秒的准备时间后，才可以进入赛场中央战斗区域。\n",
			cc.c3b(255, 255, 255)
		},
		{
			"2、队伍中每有一种职业，全队成员增加",
			cc.c3b(255, 255, 255)
		},
		{
			"10%生命值",
			cc.c3b(255, 0, 0)
		},
		{
			"，最高30%。\n",
			cc.c3b(255, 255, 255)
		},
		{
			"3、每个角色有",
			cc.c3b(255, 255, 255)
		},
		{
			"2次",
			cc.c3b(255, 0, 0)
		},
		{
			"复活次数，角色被击败后5秒自动复活在入场点，没有复活次数的角色被击倒将无法复活。\n",
			cc.c3b(255, 255, 255)
		},
		{
			"4、在战队赛场中不可以使用回复药品。\n",
			cc.c3b(255, 255, 255)
		},
		{
			"5、在战队赛场中断线会回到战队赛准备室，无法继续参赛，请确保你的网络稳定。\n",
			cc.c3b(255, 255, 255)
		},
		{
			"6、",
			cc.c3b(255, 255, 255)
		},
		{
			"5分钟",
			cc.c3b(255, 0, 0)
		},
		{
			"内，击败对方所有成员的战队直接获胜；双方都有玩家存活时，存活人次多的战队获胜；若结果相同，则主队获胜。",
			cc.c3b(255, 255, 255)
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
	}).pos(slot3, 27, 432):addto(self.contentNode)

	local rect = cc.rect(10.5, 60, 620, 345)
	local scroll = an.newScroll(rect.x, rect.y, rect.width, rect.height, {
		dir = 2
	}):addto(self.contentNode)
	local ticketNum = result.Fticket or 0

	an.newLabel("剩余战书：" .. ticketNum, 20, 1, {
		color = cc.c3b(240, 200, 150)
	}):anchor(0, 0.5):pos(20, 35):add2(self.contentNode)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		local rsb = DefaultClientMessage(CM_Group5v5ReqList)

		MirTcpClient:getInstance():postRsb(rsb)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"刷 新",
			20,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot6, self.contentNode):pos(575, 35)

	local function getRoomInfo(id)
		for _k, _v in ipairs(result.FFieldList) do
			if _v.Fid == id then
				return _v
			end
		end

		return 
	end

	for k, v in ipairs(result.FPKList) do
		local bgName = ""
		local titleStr = ""
		local titleColor = nil

		if v.Ffieldid == 1 then
			bgName = "bg_hj.png"
			titleStr = "黄金赛场"
			titleColor = def.colors.Cfad264
		elseif v.Ffieldid == 2 then
			bgName = "bg_by.png"
			titleStr = "白银赛场"
			titleColor = def.colors.Ccf15e1
		elseif v.Ffieldid == 3 then
			bgName = "bg_qt.png"
			titleStr = "青铜赛场"
			titleColor = def.colors.C3794fb
		else
			return 
		end

		local bg = display.newSprite(res.gettex2("pic/panels/teamCompetition/" .. slot12)):anchor(0, 0):pos((k - 1)*185, 5):add2(scroll)

		display.newSprite(res.gettex2("pic/panels/common/titleBg.png")):anchor(0.5, 0.5):pos(90, 315):add2(bg)
		an.newLabel(titleStr, 20, 1, {
			color = titleColor,
			sc = def.colors.C180a07
		}):anchor(0.5, 0.5):pos(90, 315):add2(bg)

		local roomInfo = getRoomInfo(v.Ffieldid) or {}
		local needTicket = roomInfo.Fneedcnt or 0

		local function enterRoom(bPK)
			local texts = {}

			if bPK then
				texts = {
					{
						"确定消耗",
						cc.c3b(255, 255, 255)
					},
					{
						needTicket,
						cc.c3b(255, 0, 0)
					},
					{
						"个战书进入赛场挑战对手吗？",
						cc.c3b(255, 255, 255)
					}
				}
			else
				texts = {
					{
						"确定消耗",
						cc.c3b(255, 255, 255)
					},
					{
						needTicket,
						cc.c3b(255, 0, 0)
					},
					{
						"个战书进入赛场等待对手吗？\n",
						cc.c3b(255, 255, 255)
					},
					{
						"提前入场战队视为主队",
						cc.c3b(255, 0, 0)
					}
				}
			end

			an.newMsgbox(texts, function (idx)
				if idx == 1 then
					if bPK then
						local rsb = DefaultClientMessage(CM_Group5v5ReqPk)
						rsb.Fpkid = v.Fid

						MirTcpClient:getInstance():postRsb(rsb)
					else
						local rsb = DefaultClientMessage(CM_Group5v5ReqEnter)
						rsb.Ffieldid = v.Ffieldid

						MirTcpClient:getInstance():postRsb(rsb)
					end
				end

				return 
			end, {
				center = true,
				btnTexts = {
					"确定",
					"取消"
				}
			})

			return 
		end

		if v.Fstatus == 0 then
			display.newSprite(res.gettex2("pic/panels/teamCompetition/zt_kx.png")).anchor(slot19, 0.5, 0.5):pos(90, 80):add2(bg)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				sound.playSound("103")
				enterRoom(false)

				return 
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				label = {
					"入 场",
					20,
					0,
					{
						color = def.colors.Cf0c896
					}
				}
			}).anchor(slot19, 0.5, 0.5):pos(90, 30):add2(bg)
		elseif v.Fstatus == 1 then
			display.newSprite(res.gettex2("pic/panels/teamCompetition/zt_ddtz.png")):anchor(0.5, 0.5):pos(90, 80):add2(bg)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				sound.playSound("103")

				local leaderName = v.FAleadername or ""
				local leaderJob = v.FLeaderJob or 0
				local leaderLevel = v.FLeaderLevel or 0
				local job_name = {
					[0] = "战士",
					"法师",
					"道士"
				}
				local leaderStr = job_name[leaderJob] or ""
				local texts = {
					{
						"赛场中队伍情况\n",
						cc.c3b(255, 255, 255)
					},
					{
						"队长：",
						cc.c3b(255, 255, 255)
					},
					{
						leaderName .. "\n",
						cc.c3b(255, 0, 0)
					},
					{
						"等级：",
						cc.c3b(255, 255, 255)
					},
					{
						common.getLevelText(leaderLevel) .. "\n",
						cc.c3b(255, 0, 0)
					},
					{
						"职业：",
						cc.c3b(255, 255, 255)
					},
					{
						leaderStr .. "\n",
						cc.c3b(255, 0, 0)
					},
					{
						"是否消耗",
						cc.c3b(255, 255, 255)
					},
					{
						needTicket .. "",
						cc.c3b(255, 0, 0)
					},
					{
						"个战书进入赛场挑战对手",
						cc.c3b(255, 255, 255)
					}
				}

				an.newMsgbox(texts, function (idx)
					if idx == 1 then
						enterRoom(true)
					end

					return 
				end, {
					btnTexts = {
						"确定",
						"取消"
					}
				})

				return 
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				label = {
					"队伍信息",
					20,
					0,
					{
						color = def.colors.Cf0c896
					}
				}
			}).anchor(slot19, 0.5, 0.5):pos(90, 30):add2(bg)
		elseif 2 <= v.Fstatus and v.Fstatus <= 4 then
			display.newSprite(res.gettex2("pic/panels/teamCompetition/zt_tzz.png")):anchor(0.5, 0.5):pos(90, 80):add2(bg)
		end
	end

	return 
end
teamCompetition.onSM_Group5v5ReqList = function (self, result)
	if result and result.Fres == 0 and self.curTab == self.xunLianYing then
		self.updateXunLianYing(self, result)
	end

	return 
end
teamCompetition.onSM_Group5v5ReqEnter = function (self, result)
	if result and result.Fres == 0 and self.curTab == self.xunLianYing then
		if self.onCloseWindow(self) then
			self.hidePanel(self)
		else
			print("阻止了窗口关闭")
		end
	end

	return 
end
teamCompetition.onSM_Group5v5ReqPk = function (self, result)
	if result and result.Fres == 0 and self.curTab == self.xunLianYing then
		if self.onCloseWindow(self) then
			self.hidePanel(self)
		else
			print("阻止了窗口关闭")
		end
	end

	return 
end
teamCompetition.jinBiaoSai = function (self)
	local rsb = DefaultClientMessage(CM_GroupBattleReqList)

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end
teamCompetition.updateJinBiaoSai = function (self)
	display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(12, 70):size(125, 336):addTo(self.contentNode)
	display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(140, 70):size(490, 336):addTo(self.contentNode)

	local leftScroll = self.newListView(self, 12, 73, 125, 330, 7, {}):add2(self.contentNode)
	local leftItemName = {
		"积分赛",
		"淘汰赛"
	}
	local leftItemCb = {
		self.jiFenComp,
		self.taoTaiComp
	}

	local function onItemSelect(btn)
		for k, v in ipairs(self.contentNode.controls.leftItems) do
			v.unselect(v)
			v.setTouchEnabled(v, true)
		end

		btn.select(btn)
		btn.setTouchEnabled(btn, false)

		if leftItemCb[btn.key] then
			leftItemCb[btn.key](self)
		end

		return 
	end

	self.contentNode.controls.leftItems = {}

	for i, v in ipairs(slot2) do
		local item = an.newBtn(res.gettex2("pic/common/btn60.png"), function (btn)
			sound.playSound("103")
			onItemSelect(btn)

			return 
		end, {
			support = "scroll",
			select = {
				res.gettex2("pic/common/btn61.png")
			},
			label = {
				v,
				20,
				0,
				{
					color = def.colors.Cf0c896
				}
			}
		})
		item.key = i

		table.insert(self.contentNode.controls.leftItems, slot10)
		self.listViewPushBack(self, leftScroll, item, {
			left = 9
		})
	end

	onItemSelect(self.contentNode.controls.leftItems[1])

	return 
end
teamCompetition.jiFenComp = function (self)
	if self.contentNode.RightNode then
		self.contentNode.RightNode:removeSelf()
	end

	self.contentNode.RightNode = display.newNode():addTo(self.contentNode)
	local Titlelabel = {
		"敌对队长",
		"结果",
		"击败数",
		"耗时"
	}
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(480, 42)):anchor(0, 1):pos(145, 402):add2(self.contentNode.RightNode)

	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(143.25, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(255.5, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(367.75, 0):add2(titlebg)

	for k, v in ipairs(Titlelabel) do
		local posBegin = 87.125

		if k == 1 then
			posBegin = 71.625
		end

		an.newLabel(v, 20, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(posBegin + (k - 1)*112.25, titlebg.geth(titlebg)/2):addTo(titlebg)
	end

	local jbsData = self.contentNode.data.JinBiaoSaiData

	if not jbsData then
		return 
	end

	local jifenData = jbsData.FAHistory or {}
	local cellHeight = 42
	local rect = cc.rect(140, 72, 486, 288)
	local scroll = self.newListView(self, rect.x, rect.y, rect.width, rect.height, 4, {}):add2(self.contentNode.RightNode)

	scroll.setScrollSize(scroll, rect.width, math.max(rect.height + 1, #jifenData*cellHeight))

	local posY = math.max(rect.height + 1, #jifenData*cellHeight)

	for k, v in ipairs(jifenData) do
		local cellBg = res.getframe2((k%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png")
		local cell = an.newBtn(cellBg, function ()
			return 
		end, {
			support = "scroll",
			scale9 = cc.size(rect.width, slot5)
		}):anchor(0, 1):pos(5, posY):addto(scroll)

		an.newLabel(v.Fleadername, 18, 0, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(71.625, cell.geth(cell)/2):addTo(cell)

		local resStr = (v.Fwarres == 1 and "胜") or "负"

		an.newLabel(resStr, 18, 0, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(199.375, cell.geth(cell)/2):addTo(cell)
		an.newLabel(v.Fwincnt, 18, 0, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(311.625, cell.geth(cell)/2):addTo(cell)

		local timeStr = os.date("%M:%S", v.Fdt)

		an.newLabel(timeStr, 18, 0, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(423.875, cell.geth(cell)/2):addTo(cell)

		posY = posY - cellHeight
	end

	local timeStr = os.date("%H:%M", jbsData.FNextWarTime)

	an.newLabel("下轮开始时间：", 18, 0, {
		color = def.colors.Cf0c896
	}):anchor(0, 0.5):pos(15, 40):addTo(self.contentNode.RightNode)
	an.newLabel(timeStr, 18, 0, {
		color = cc.c3b(220, 210, 190)
	}):anchor(0, 0.5):pos(140, 40):addTo(self.contentNode.RightNode)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		main_scene.ui:togglePanel("teamCompetitionTop")

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"当前排行",
			20,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot10, self.contentNode.RightNode):pos(580, 40)

	return 
end
teamCompetition.taoTaiComp = function (self)
	if self.contentNode.RightNode then
		self.contentNode.RightNode:removeSelf()
	end

	self.contentNode.RightNode = display.newNode():addTo(self.contentNode)
	local Titlelabel = {
		"敌对队长",
		"结果",
		"击败数",
		"耗时"
	}
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(480, 42)):anchor(0, 1):pos(145, 402):add2(self.contentNode.RightNode)

	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(143.25, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(255.5, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(367.75, 0):add2(titlebg)

	for k, v in ipairs(Titlelabel) do
		local posBegin = 87.125

		if k == 1 then
			posBegin = 71.625
		end

		an.newLabel(v, 20, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(posBegin + (k - 1)*112.25, titlebg.geth(titlebg)/2):addTo(titlebg)
	end

	local jbsData = self.contentNode.data.JinBiaoSaiData

	if not jbsData then
		return 
	end

	local taotaiData = jbsData.FBHistory or {}
	local cellHeight = 42
	local rect = cc.rect(140, 72, 486, 288)
	local scroll = self.newListView(self, rect.x, rect.y, rect.width, rect.height, 4, {}):add2(self.contentNode.RightNode)

	scroll.setScrollSize(scroll, rect.width, math.max(rect.height + 1, #taotaiData*cellHeight))

	local posY = math.max(rect.height + 1, #taotaiData*cellHeight)

	for k, v in ipairs(taotaiData) do
		local cellBg = res.getframe2((k%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png")
		local cell = an.newBtn(cellBg, function ()
			return 
		end, {
			support = "scroll",
			scale9 = cc.size(rect.width, slot5)
		}):anchor(0, 1):pos(5, posY):addto(scroll)

		an.newLabel(v.Fleadername, 18, 0, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(71.625, cell.geth(cell)/2):addTo(cell)

		local resStr = (v.Fwarres == 1 and "胜") or "负"

		an.newLabel(resStr, 18, 0, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(199.375, cell.geth(cell)/2):addTo(cell)
		an.newLabel(v.Fwincnt, 18, 0, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(311.625, cell.geth(cell)/2):addTo(cell)

		local timeStr = os.date("%M:%S", v.Fdt)

		an.newLabel(timeStr, 18, 0, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(423.875, cell.geth(cell)/2):addTo(cell)

		posY = posY - cellHeight
	end

	local timeStr = os.date("%H:%M", jbsData.FNextWarTime)

	an.newLabel("下轮开始时间：", 18, 0, {
		color = def.colors.Cf0c896
	}):anchor(0, 0.5):pos(15, 40):addTo(self.contentNode.RightNode)
	an.newLabel(timeStr, 18, 0, {
		color = cc.c3b(220, 210, 190)
	}):anchor(0, 0.5):pos(140, 40):addTo(self.contentNode.RightNode)
	an.newLabel("剩余队伍数量：", 18, 0, {
		color = def.colors.Cf0c896
	}):anchor(0, 0.5):pos(330, 40):addTo(self.contentNode.RightNode)
	an.newLabel(jbsData.FBLeftGroupCnt, 18, 0, {
		color = cc.c3b(220, 210, 190)
	}):anchor(0, 0.5):pos(455, 40):addTo(self.contentNode.RightNode)

	return 
end
teamCompetition.onSM_GroupBattleReqList = function (self, result)
	if result and result.Fres == 0 and self.curTab == self.jinBiaoSai then
		self.contentNode.data.JinBiaoSaiData = result

		self.updateJinBiaoSai(self)
	end

	return 
end

return teamCompetition
