local common = import("..common.common")
local guild = class("guild", function ()
	return display.newNode()
end)
local guildData = g_data.guild

table.merge(slot1, {
	guildCells = {}
})

guild.ctor = function (self)
	self._supportMove = true

	display.newSprite(res.gettex2("pic/common/black_2.png")):anchor(0, 0):add2(self)

	self.bg = display.newNode():size(625, 400):add2(self)

	self.size(self, 641, 455):anchor(0.5, 0.5):center()
	an.newLabel("行会", 22, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(self.getw(self)*0.5, self.geth(self) - 22):add2(self, 2)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot1, 1, 1):pos(self.getw(self) - 9, self.geth(self) - 9):addto(self, 2)
	self.bingMsg(self)
	scheduler.performWithDelayGlobal(function ()
		if g_data.client:checkLastTime("CM_GildInfo", 3) then
			g_data.client:setLastTime("CM_GildInfo", true)

			local rsb = DefaultClientMessage(CM_GildInfo)

			MirTcpClient:getInstance():postRsb(rsb)
		end

		return 
	end, 0)
	self.setNodeEventEnabled(slot0, true)

	self.guildCells = {}

	return 
end
guild.bingMsg = function (self)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GildList, self, self.onSM_GildList)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GildApply, self, self.onSM_GildApply)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GildInfo, self, self.onSM_GildInfo)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GildExit, self, self.onSM_GildExit)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GildMemberList, self, self.onSM_GildMemberList)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GildSetPosition, self, self.onSM_GildSetPosition)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GildApplyList, self, self.onSM_GildApplyList)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GildApplyCondition, self, self.onSM_GildApplyCondition)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GildApplyApprove, self, self.onSM_GildApplyApprove)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GildDiplomacyList, self, self.onSM_GildDiplomacyList)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GildLogList, self, self.onSM_GildLogList)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GildDeclareWar, self, self.onSM_GildDeclareWar)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_GildSetDiplomacyColor, self, self.onSM_GildSetDiplomacyColor)

	return 
end
local title_name = {
	"会员",
	"精英",
	"长老",
	"副会长",
	"会长"
}

local function createToggle(cb, default)
	local hasTips, tipContent = nil
	config = config or {}
	local base = display.newNode()
	local selsp = display.newFilteredSprite(res.gettex2("pic/common/toggle00.png")):anchor(0, 0):add2(base)

	base.setContentSize(base, selsp.getContentSize(selsp))

	base.setIsSelect = function (self, enable)
		base.isSelected = enable

		if enable then
			base:select()
		else
			base:unselect()
		end

		return 
	end
	base.isSelect = function (self)
		return base.isSelected
	end
	base.select = function (self)
		base.isSelected = true

		if base.temp then
			base.temp:removeSelf()

			base.temp = nil
		end

		selsp:setTex(res.gettex2(config.selectImg or "pic/common/toggle02.png"))

		return 
	end
	base.unselect = function (self)
		if base.temp then
			base.temp:removeSelf()

			base.temp = nil
		end

		base.isSelected = false

		selsp:setTex(res.gettex2("pic/common/toggle00.png"))

		return 
	end

	if default ~= nil then
		base.setIsSelect(slot4, default)
	end

	selsp.setTouchEnabled(selsp, true)
	selsp.addNodeEventListener(selsp, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			base.offsetBeginY = event.y
			base.offsetBeginX = event.x

			return true
		elseif event.name == "ended" then
			local offsetY = event.y - base.offsetBeginY
			local offsetX = event.x - base.offsetBeginX

			if math.abs(offsetY) <= 20 and math.abs(offsetX) <= 20 then
				base:setIsSelect(not base.isSelected)
				cb(base.isSelected)
			end
		end

		return 
	end)
	selsp.setTouchSwallowEnabled(slot5, false)

	return base
end

guild.onSM_GildApplyApprove = function (self, result, protoId)
	if result then
		guildData:delApplyList(result.FUserIDArray)
		self.showGuild(self, 3)
	end

	return 
end
guild.onSM_GildApplyCondition = function (self, result, protoId)
	if result then
		local msgbox = nil
		local needApprove = false
		slot5 = an.newMsgbox("", function (idx)
			if idx == 1 then
				local notice = msgbox.noticeInput:getString()
				local num1 = tonumber(msgbox.LvInput1:getString())

				if not num1 or num1 < 0 then
					main_scene.ui:tip("请输入正确的数字！")

					return 
				end

				local num2 = tonumber(msgbox.LvInput2:getString())

				if not num2 or num2 < 0 then
					main_scene.ui:tip("请输入正确的数字！")

					return 
				end

				if string.find(num1 or "", "%.") or string.find(num2 or "", "%.") then
					main_scene.ui:tip("只能输入整数", 6)

					return 
				end

				local rsb = DefaultClientMessage(CM_GildEditApplyCondition)
				rsb.FLimitLevel = num1*99 + num2
				rsb.FBoApprove = needApprove
				rsb.FApplyNotice = notice

				MirTcpClient:getInstance():postRsb(rsb)
			end

			msgbox:removeSelf()

			return 
		end, {
			title = "招贤设置",
			disableScroll = true,
			manualRemove = true,
			btnTexts = {
				"确 定",
				"取 消"
			}
		})
		msgbox = slot5

		msgbox.bg:pos(display.cx, display.cy - 30)

		msgbox.noticeInput = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 20, {
			label = {
				result.FApplyNotice,
				20,
				1
			},
			bg = {
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-10,
					2
				}
			},
			tip = {
				"在此设置招贤宣言，最多二十个字",
				20,
				1,
				{
					color = cc.c3b(128, 128, 128)
				}
			}
		}):add2(msgbox.bg):pos(msgbox.bg:getw()*0.5 + 10, msgbox.bg:geth()*0.5 + 75)
		msgbox.text1 = an.newLabel("是否需要审批：", 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0, 0):add2(msgbox.bg):pos(35, msgbox.bg:geth()*0.5 + 20)
		msgbox.text2 = an.newLabel("等级要求: ", 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0, 0):add2(msgbox.bg):pos(35, msgbox.bg:geth()*0.5 - 25)
		local chkbox1, chkbox2 = nil

		if result.FBoApprove then
			needApprove = true
		end

		chkbox1 = createToggle(function ()
			if chkbox2:isSelect() then
				chkbox2:unselect()
			end

			if chkbox1:isSelect() == false then
				chkbox1:select()

				return 
			end

			needApprove = true

			return 
		end, slot4):add2(msgbox.bg):pos(175, msgbox.bg:geth()*0.5 + 15)
		msgbox.text3 = an.newLabel("是", 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0, 0):add2(msgbox.bg):pos(215, msgbox.bg:geth()*0.5 + 20)
		chkbox2 = createToggle(function ()
			if chkbox1:isSelect() then
				chkbox1:unselect()
			end

			if chkbox2:isSelect() == false then
				chkbox2:select()

				return 
			end

			needApprove = false

			return 
		end, not needApprove).add2(slot7, msgbox.bg):pos(260, msgbox.bg:geth()*0.5 + 15)
		msgbox.text4 = an.newLabel("否", 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0, 0):add2(msgbox.bg):pos(300, msgbox.bg:geth()*0.5 + 20)
		local bigNum = 0
		local smallNum = 1

		if 99 < result.FLimitLevel then
			bigNum = math.floor(result.FLimitLevel/99)
			smallNum = result.FLimitLevel - bigNum*99
		else
			smallNum = result.FLimitLevel
		end

		msgbox.LvInput1 = an.newInput(0, 0, 60, 40, 2, {
			label = {
				tostring(bigNum),
				20,
				1
			},
			bg = {
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-10,
					2
				}
			},
			tip = {
				"",
				20,
				1,
				{
					color = cc.c3b(128, 128, 128)
				}
			}
		}):add2(msgbox.bg):pos(170, msgbox.bg:geth()*0.5 - 20)
		msgbox.text5 = an.newLabel("转", 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0, 0):add2(msgbox.bg):pos(195, msgbox.bg:geth()*0.5 - 25)
		msgbox.LvInput2 = an.newInput(0, 0, 60, 40, 2, {
			label = {
				tostring(smallNum),
				20,
				1
			},
			bg = {
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-10,
					2
				}
			},
			tip = {
				"",
				20,
				1,
				{
					color = cc.c3b(128, 128, 128)
				}
			}
		}):add2(msgbox.bg):pos(270, msgbox.bg:geth()*0.5 - 20)
		msgbox.text6 = an.newLabel("级", 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0, 0):add2(msgbox.bg):pos(297, msgbox.bg:geth()*0.5 - 25)
	end

	return 
end
guild.onSM_GildSetDiplomacyColor = function (self, result, protoId)
	if result then
		guildData:uptSocialColor(result.FGildID, result.FColor)

		for k, v in pairs(self.socialCells) do
			if v.data.FGildID == result.FGildID then
				local clrcell = v.getChildByName(v, "guildcolor")

				if clrcell then
					clrcell.setColor(clrcell, def.colors.get(result.FColor, true))
				end

				break
			end
		end
	end

	return 
end
guild.onSM_GildSetPosition = function (self, result, protoId)
	if result then
		guildData:uptMemberTitle(result.FUserId, result.FPosition)

		for k, v in pairs(self.memberCells) do
			if v.data.FUserID == result.FUserId then
				v.getChildByName(v, "FPosition"):setText(title_name[result.FPosition])

				break
			end
		end
	end

	return 
end
guild.onSM_GildDeclareWar = function (self, result, protoId)
	if result then
		guildData:uptSocialColor(result.FGildID, result.FColor)

		for k, v in pairs(self.socialCells) do
			if v.data.FGildID == result.FGildID then
				v.getChildByName(v, "guildstate"):setText("宣战中")

				local clr = def.colors.get(result.FColor, true)

				cc.LayerColor:create(clr):anchor(0.5, 0.5):size(25, 25):add2(v):pos(360, 15):setName("guildcolor")

				break
			end
		end
	end

	return 
end
guild.onSM_GildLogList = function (self, result, protoId)
	if result then
		guildData.socialLogList = result.FDiplomacyLogList
		guildData.memberLogList = result.FMemberLogList

		table.insert(guildData.memberLogList, "06/15 09:00 bikaiu加入了aaa行会")
		table.insert(guildData.memberLogList, "06/15 09:10 bikaiu1加入了aaa行会")
		table.insert(guildData.memberLogList, "06/15 09:20 bikaiu2加入了aaa行会")
		table.insert(guildData.memberLogList, "06/15 09:30 bikaiu3加入了aaa行会")
		table.insert(guildData.memberLogList, "06/15 09:40 bikaiu4加入了aaa行会")
		table.insert(guildData.memberLogList, "06/15 09:50 bikaiu5加入了aaa行会")
		table.insert(guildData.memberLogList, "06/16 10:30 bikaiu6加入了aaa行会")
		table.insert(guildData.memberLogList, "06/15 10:40 bikaiu7加入了aaa行会")
		print("======guildData.memberLogList========", json.encode(guildData.memberLogList))
		self.showLog(self)
	end

	return 
end
guild.onSM_GildApplyList = function (self, result, protoId)
	if result then
		guildData.applyList = result.FGildApplyList

		self.showApply(self)
	end

	return 
end
guild.onSM_GildDiplomacyList = function (self, result, protoId)
	if result then
		guildData.socialList = result.FGildDiplomacyList

		self.showSocial(self)
	end

	return 
end
guild.onSM_GildMemberList = function (self, result, protoId)
	if result then
		guildData.memberList = result.FGildMemberList

		print("==============", json.encode(guildData.memberList))
		table.insert(guildData.memberList, {
			FUserID = "88888888",
			classid = 50111,
			FPosition = 1,
			FLastOnlineDate = 0,
			FName = "bikaqiu",
			FLevel = 55
		})
		table.insert(guildData.memberList, {
			FUserID = "88888888",
			classid = 50111,
			FPosition = 1,
			FLastOnlineDate = 0,
			FName = "bikaqiu1",
			FLevel = 55
		})
		table.insert(guildData.memberList, {
			FUserID = "88888888",
			classid = 50111,
			FPosition = 1,
			FLastOnlineDate = 0,
			FName = "bikaqiu2",
			FLevel = 55
		})
		table.insert(guildData.memberList, {
			FUserID = "88888888",
			classid = 50111,
			FPosition = 1,
			FLastOnlineDate = 0,
			FName = "bikaqiu3",
			FLevel = 55
		})
		print("==============", json.encode(guildData.memberList))
		self.showGuildMember(self)
	end

	return 
end
guild.onSM_GildExit = function (self, result, protoId)
	if result then
		if result.FUserId == g_data.player.roleid then
			local rsb = DefaultClientMessage(CM_GildInfo)

			MirTcpClient:getInstance():postRsb(rsb)
		else
			local index = 1
			local delCellPos = nil

			while self.memberCells[index] do
				local cell = self.memberCells[index]

				if delCellPos then
					local old = cc.p(cell.getPosition(cell))

					cell.setPosition(cell, delCellPos.x, delCellPos.y)

					delCellPos = old
				end

				if cell.data.FUserID == result.FUserId then
					delCellPos = cc.p(cell.getPosition(cell))

					cell.removeSelf(cell)
					table.remove(self.memberCells, index)
					guildData:delMember(result.FUserId)
				else
					index = index + 1
				end
			end
		end
	end

	return 
end
guild.onSM_GildInfo = function (self, result, protoId)
	if result then
		guildData.homeInfo = {
			guildName = result.FGildName,
			onlineCount = result.FOnlineCount,
			totalCount = result.FTotalCount,
			notice = result.FGildNotice,
			title = result.FPosition,
			createdate = result.FCreateDate
		}
		g_data.player.guildInfo.guildName = result.FGildName
		g_data.player.guildInfo.title = result.FPosition

		self.showGuild(self, 1)
	end

	return 
end
guild.onSM_GildList = function (self, result, protoId)
	if result then
		g_data.guild.guildList = result.FGildList

		self.showDefaultUI(self)
	end

	return 
end
guild.onSM_GildApply = function (self, result, protoId)
	if result then
		for k, v in ipairs(g_data.guild.guildList) do
			if v.FGildID == result.FGildID then
				v.FBoApply = true

				break
			end
		end

		for k, v in ipairs(self.guildCells) do
			if v.data == result.FGildID then
				v.removeChildByName(v, "guildState")
				an.newLabel("申请中", 18, 0, {
					color = def.colors.cellNor
				}):add2(v):anchor(0.5, 0.5):pos(530, 25)

				break
			end
		end
	end

	return 
end
guild.showDefaultUI = function (self)
	self.bg:removeAllChildren()

	self.guildCells = {}
	local back1 = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(614, 336)):anchor(0, 0):pos(14, 64):add2(self.bg)
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(608, 42)):anchor(0, 0):pos(4, back1.geth(back1) - 46):add2(back1)

	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(160, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(280, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(440, 0):add2(titlebg)
	an.newLabel("行会名称", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(80, back1.geth(back1) - 23):add2(back1)
	an.newLabel("人数", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(220, back1.geth(back1) - 23):add2(back1)
	an.newLabel("会长名称", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(360, back1.geth(back1) - 23):add2(back1)

	local dataList = g_data.guild.guildList

	if #dataList == 0 then
		an.newLabel("当前无行会", 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(back1.getw(back1)/2, back1.geth(back1)/2):add2(back1, 2)
	end

	table.sort(dataList, function (l, r)
		if l.FOnlineCount == r.FOnlineCount then
			if l.FMemberCount == r.FMemberCount then
				return l.FCreateDate < r.FCreateDate
			else
				return r.FMemberCount < l.FMemberCount
			end
		else
			return r.FOnlineCount < l.FOnlineCount
		end

		return 
	end)

	local infoView = an.newScroll(4, 4, 608, 288).add2(slot4, back1)
	local h = 50

	infoView.setScrollSize(infoView, 608, math.max(288, #dataList*h))
	infoView.enableClick(infoView, function ()
		return 
	end)

	local moreCell = nil

	local function resetScrollView()
		self.maxGuildNum = 5
		self.guildIndex = 1

		for k, v in pairs(self.guildCells) do
			v.removeSelf(v)
		end

		self.guildCells = {}

		return 
	end

	local function refreshGuildInfo(data)
		for i = self.guildIndex, #data, 1 do
			self.guildIndex = i

			if self.maxGuildNum < self.guildIndex then
				break
			end

			local v = data[i]
			local cell = display.newScale9Sprite(res.getframe2((self.guildIndex%2 == 0 and "pic/panels/guild/joinbg2.png") or "pic/panels/guild/joinbg1.png"), 0, 0, cc.size(608, h)):anchor(0, 0):pos(0, infoView:getScrollSize().height - self.guildIndex*h):add2(infoView)
			cell.data = v.FGildID
			self.guildCells[#self.guildCells + 1] = cell

			an.newLabel(v.FGildName, 18, 0, {
				color = def.colors.cellNor
			}):add2(cell):anchor(0.5, 0.5):pos(80, h*0.5)
			an.newLabel(v.FOnlineCount .. "/" .. v.FMemberCount, 18, 0, {
				color = def.colors.cellNor
			}):add2(cell):anchor(0.5, 0.5):pos(220, h*0.5)
			an.newLabel(v.FLeaderName, 18, 0, {
				color = def.colors.cellNor
			}):add2(cell):anchor(0.5, 0.5):pos(360, h*0.5)

			if v.FBoApply == false then
				an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
					sound.playSound("103")

					if g_data.player:getIsCrossServer() then
						main_scene.ui:tip("该功能不能使用")

						return 
					end

					local level = tonumber(g_data.player.ability.FLevel)

					if level < 22 then
						main_scene.ui:tip("勇士达到22级才可以申请加入行会", 6)

						return 
					end

					local msgText = {
						{
							v.FApplyNotice or "",
							def.colors.Cdcd2be
						}
					}
					local msgbox = an.newMsgbox(msgText, function ()
						if g_data.player.ability.FLevel < v.FLimitLevel then
							main_scene.ui:tip("等级不满足要求")

							return 
						end

						local rsb = DefaultClientMessage(CM_GildApply)
						rsb.FGildID = v.FGildID

						MirTcpClient:getInstance():postRsb(rsb)

						return 
					end, {
						title = "招贤条件",
						btnTexts = {
							"申  请"
						}
					})

					display.newSprite(res.gettex2("pic/common/b4.png")).anchor(slot3, 0.5, 0.5):pos(msgbox.bg:getw()*0.5, 170):add2(msgbox.bg)
					an.newLabel("需要审批：" .. ((v.FBoApprove == true and "是") or "否"), 18, 0, {
						color = def.colors.Cf0c896
					}):anchor(0, 0):add2(msgbox.bg):pos(30, 135)
					an.newLabel("等级要求: " .. common.getLevelText(v.FLimitLevel) .. " 级", 18, 0, {
						color = def.colors.Cf0c896
					}):anchor(0, 0):add2(msgbox.bg):pos(30, 110)

					return 
				end, {
					label = {
						"申请加入",
						18,
						0,
						{
							color = def.colors.btn
						}
					},
					pressImage = res.gettex2("pic/common/btn21.png")
				}).add2(slot7, cell):anchor(0.5, 0.5):pos(530, h*0.5):setName("guildState")
			else
				an.newLabel("申请中", 18, 0, {
					color = def.colors.cellNor
				}):add2(cell):anchor(0.5, 0.5):pos(530, h*0.5)
			end
		end

		if #data <= self.maxGuildNum then
			if moreCell then
				moreCell:setVisible(false)
			end

			return 
		end

		if moreCell then
			moreCell:setTexture((self.guildIndex%2 == 0 and "pic/panels/guild/joinbg2.png") or "pic/panels/guild/joinbg1.png")
			moreCell:pos(0, infoView:getScrollSize().height - self.guildIndex*h)
			moreCell:setVisible(true)
		end

		return 
	end

	moreCell = display.newSprite(res.getframe2("pic/panels/guild/joinbg2.png"), 0, 0, cc.size(608, slot5)):anchor(0, 0):add2(infoView)

	an.newLabel("点击加载更多", 18, 0, {
		color = def.colors.cellNor
	}):add2(moreCell):anchor(0.5, 0.5):pos(moreCell.getContentSize(moreCell).width*0.5, h*0.5):enableClick(function ()
		self.maxGuildNum = self.maxGuildNum + 5

		refreshGuildInfo(dataList)

		return 
	end)
	moreCell.setVisible(slot6, false)
	resetScrollView()
	refreshGuildInfo(dataList)

	local filterInput = nil
	filterInput = an.newInput(0, 0, 196, 40, 5, {
		label = {
			self.filterString or "",
			20,
			1
		},
		bg = {
			tex = res.gettex2("pic/scale/edit.png"),
			offset = {
				-10,
				2
			}
		},
		tip = {
			"输入行会关键字    ",
			20,
			1,
			{
				color = cc.c3b(128, 128, 128)
			}
		},
		stop_call = function ()
			local key = filterInput:getString()

			if key == "" then
				resetScrollView()
				refreshGuildInfo(dataList)

				return 
			end

			local filtedGuild = {}

			for k, v in pairs(dataList) do
				if string.find(v.FGildName, key) then
					filtedGuild[#filtedGuild + 1] = v
				end
			end

			resetScrollView()
			refreshGuildInfo(filtedGuild)

			return 
		end
	}).add2(slot10, self.bg):anchor(0, 0):pos(25, 14):add(res.get2("pic/common/button_search.png"):pos(170, 20))

	an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
		sound.playSound("103")

		if g_data.player:getIsCrossServer() then
			main_scene.ui:tip("该功能不能使用")

			return 
		end

		local level = tonumber(g_data.player.ability.FLevel)

		if level < 22 then
			main_scene.ui:tip("勇士达到22级才可以申请加入行会", 6)

			return 
		end

		local guildInfo = nil

		for k, v in pairs(dataList) do
			if v.FLimitLevel == 1 and v.FBoApprove == false and v.FBoFull == false then
				guildInfo = v

				break
			end
		end

		if guildInfo then
			local rsb = DefaultClientMessage(CM_GildApply)
			rsb.FGildID = guildInfo.FGildID

			MirTcpClient:getInstance():postRsb(rsb)
		else
			main_scene.ui:tip("加入失败，条件不满足")
		end

		return 
	end, {
		label = {
			"快速加入",
			18,
			0,
			{
				color = def.colors.btn
			}
		},
		pressImage = res.gettex2("pic/panels/guild/btnh.png")
	}).add2(slot10, self.bg):anchor(0, 0):pos(365, 14)

	local isCanCreateGuild = true
	local hour = tonumber(os.date("%H", g_data.serverTime:getTime()))

	if hour < 9 and g_data.client.openDay <= 7 then
		isCanCreateGuild = false
	end

	an.newBtn(res.gettex2("pic/panels/guild/createguild.png"), function ()
		sound.playSound("103")

		if g_data.player:getIsCrossServer() then
			main_scene.ui:tip("该功能不能使用")

			return 
		end

		local msgbox = nil
		slot1 = an.newMsgbox("创建行会需信用分验证、500万金币和31级以上", function (idx)
			if idx == 1 then
				if not isCanCreateGuild then
					main_scene.ui:tip("开服七天内，每日0点至9点间无法创建行会", 6)

					return 
				end

				if msgbox.nameInput:getString() == "" then
					main_scene.ui:tip("行会创建失败，行会名不能为空")

					return 
				end

				local old = msgbox.nameInput:getString()
				local new = def.wordfilter.run(old)

				if old ~= new then
					main_scene.ui:tip("行会创建失败，行会名不符合规范")

					return 
				end

				local rsb = DefaultClientMessage(CM_GildCreate)
				rsb.FGildName = old

				MirTcpClient:getInstance():postRsb(rsb)
			end

			return 
		end, {
			disableScroll = true,
			btnTexts = {
				"创建",
				"取消"
			}
		})
		msgbox = slot1
		msgbox.nameInput = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 5, {
			label = {
				"",
				20,
				1
			},
			bg = {
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-10,
					2
				}
			},
			tip = {
				"点击输入行会名(最多输入5个字)",
				20,
				1,
				{
					color = cc.c3b(128, 128, 128)
				}
			}
		}):add2(msgbox.bg):pos(msgbox.bg:getw()*0.5 + 10, msgbox.bg:geth()*0.5)

		return 
	end, {
		label = {
			"创建行会",
			18,
			0,
			{
				color = def.colors.btn
			}
		},
		pressImage = res.gettex2("pic/panels/guild/createguildh.png")
	}).add2(slot12, self.bg):anchor(0, 0):pos(485, 14)

	return 
end
guild.showGuild = function (self, curIndex)
	self.bg:removeAllChildren()

	self.leftPanel = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(127, 392)):addTo(self.bg):pos(12, 405):anchor(0, 1)
	self.rightBg = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 392)):addTo(self.bg):pos(145, 405):anchor(0, 1)
	self.rightPanel = display.newNode():size(480, 392):pos(146, 405):anchor(0, 1):add2(self.bg)
	local texts = {
		"主 页",
		"成 员",
		"招 贤",
		"外 交",
		"日 志"
	}
	local tabs = {}

	local function click(btn)
		sound.playSound("103")

		for i, v in ipairs(tabs) do
			if v == btn then
				v.select(v)
			else
				v.unselect(v)
			end

			if btn.index ~= self.tabIndex then
				self.tabIndex = btn.index

				if self.tabIndex == 1 then
					if g_data.client:checkLastTime("GuildHome", 3) then
						g_data.client:setLastTime("GuildHome", true)

						local rsb = DefaultClientMessage(CM_GildInfo)

						MirTcpClient:getInstance():postRsb(rsb)
						print("________CM_GildInfo")
					else
						self:showGuildHome()
					end
				elseif self.tabIndex == 2 then
					if g_data.client:checkLastTime("GuildMember", 3) then
						g_data.client:setLastTime("GuildMember", true)

						local rsb = DefaultClientMessage(CM_GildMemberList)

						MirTcpClient:getInstance():postRsb(rsb)
						print("________CM_GildMemberList")
					else
						self:showGuildMember()
					end
				elseif self.tabIndex == 3 then
					if g_data.client:checkLastTime("GuildApply", 3) then
						g_data.client:setLastTime("GuildApply", true)

						local rsb = DefaultClientMessage(CM_GildApplyList)

						MirTcpClient:getInstance():postRsb(rsb)
						print("________CM_GildApplyList")
					else
						self:showApply()
					end
				elseif self.tabIndex == 4 then
					if g_data.client:checkLastTime("GuildSocial", 5) then
						g_data.client:setLastTime("GuildSocial", true)

						local rsb = DefaultClientMessage(CM_GildDiplomacyList)

						MirTcpClient:getInstance():postRsb(rsb)
						print("________CM_GildSocialList")
					else
						self:showSocial()
					end
				elseif self.tabIndex == 5 then
					if g_data.client:checkLastTime("GuildLog", 3) then
						g_data.client:setLastTime("GuildLog", true)

						local rsb = DefaultClientMessage(CM_GildLogList)

						MirTcpClient:getInstance():postRsb(rsb)
						print("________CM_GildLogList")
					else
						self:showLog()
					end
				end
			end
		end

		return 
	end

	for i, v in ipairs(slot2) do
		tabs[i] = an.newBtn(res.gettex2("pic/common/btn60.png"), click, {
			support = "easy",
			anchor = {
				0.5,
				0.5
			},
			label = {
				v,
				22,
				0,
				{
					color = def.colors.btn
				}
			},
			select = {
				res.gettex2("pic/common/btn61.png"),
				manual = true
			}
		}):add2(self.leftPanel):anchor(0, 0.5):pos(10, (i - 1)*52 - 360)
		tabs[i].index = i
	end

	curIndex = curIndex or 1
	self.tabIndex = nil

	click(tabs[curIndex])

	return 
end
guild.showGuildHome = function (self)
	self.rightPanel:removeAllChildren()
	self.rightBg:size(480, 332)
	display.newSprite(res.getframe2("pic/panels/guild/homebar.png"), 0, 0):addTo(self.rightPanel):pos(0, 385):anchor(0, 1)

	local guimdName = an.newLabel(guildData.homeInfo.guildName, 20, 0, {
		color = def.colors.btn
	}):anchor(0, 1):pos(8, 382):add2(self.rightPanel, 2)
	local onlineMember = an.newLabel("在线人数: " .. guildData.homeInfo.onlineCount .. "/" .. guildData.homeInfo.totalCount, 20, 0, {
		color = def.colors.text
	}):anchor(1, 1):pos(475, 382):add2(self.rightPanel, 2)
	self.noticeLbl = an.newLabelM(450, 20, 1):anchor(0, 1):pos(15, 340):add2(self.rightPanel)

	self.noticeLbl:addLabel(guildData.homeInfo.notice, def.colors.text)

	local exitBtnPos = cc.p(370, 4)

	if guildData.homeInfo.title == 5 or guildData.homeInfo.title == 4 then
		exitBtnPos = cc.p(250, 4)
	end

	if guildData.homeInfo.title ~= 5 then
		an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
			sound.playSound("103")

			if g_data.player:getIsCrossServer() then
				main_scene.ui:tip("该功能不能使用")

				return 
			end

			an.newMsgbox({
				{
					"你确定退出" .. guildData.homeInfo.guildName .. "行会么?必须在安全区才可退出行会。",
					color = def.colors.text
				}
			}, function (idx)
				if idx == 1 then
					local rsb = DefaultClientMessage(CM_GildExit)

					MirTcpClient:getInstance():postRsb(rsb)
				end

				return 
			end, {
				disableScroll = true,
				hasCancel = true,
				btnTexts = {
					"退出",
					"取消"
				}
			})

			return 
		end, {
			label = {
				"退出行会",
				18,
				0,
				{
					color = def.colors.btn
				}
			},
			pressImage = res.gettex2("pic/panels/guild/btnh.png")
		}).add2(slot4, self.rightPanel):anchor(0, 0):pos(exitBtnPos.x, exitBtnPos.y)
	end

	if guildData.homeInfo.title == 5 or guildData.homeInfo.title == 4 then
		an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
			sound.playSound("103")

			local createdate = tonumber(guildData.homeInfo.createdate)
			local curTime = g_data.serverTime:getTime()
			local newAreaCreateTime = curTime - tonumber(os.date("%H", curTime))*3600 - tonumber(os.date("%M", curTime))*60 - tonumber(os.date("%S", curTime)) - (g_data.client.openDay - 1)*24*3600

			if createdate <= newAreaCreateTime + 604800 and curTime - createdate < 259200 then
				main_scene.ui:tip("新区创建的行会72小时内不可更改公告", 6)

				return 
			end

			local msgbox = nil
			slot4 = an.newMsgbox("", function (idx)
				if idx == 1 then
					local old = msgbox.nameInput:getString()
					local rsb = DefaultClientMessage(CM_GildEditNotice)
					rsb.FGildNotice = old

					MirTcpClient:getInstance():postRsb(rsb)
				end

				return 
			end, {
				disableScroll = true,
				btnTexts = {
					"保存",
					"取消"
				}
			})
			msgbox = slot4
			msgbox.nameInput = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 125, {
				label = {
					guildData.homeInfo.notice,
					20,
					1
				},
				bg = {
					tex = res.gettex2("pic/scale/edit.png"),
					offset = {
						0,
						2
					}
				},
				tip = {
					"点击进行编辑",
					20,
					1,
					{
						color = cc.c3b(128, 128, 128)
					}
				}
			}):add2(msgbox.bg):pos(msgbox.bg:getw()*0.5 + 10, msgbox.bg:geth()*0.5 + 20)

			return 
		end, {
			label = {
				"编辑公告",
				18,
				0,
				{
					color = def.colors.btn
				}
			},
			pressImage = res.gettex2("pic/panels/guild/btnh.png")
		}).add2(slot4, self.rightPanel):anchor(0, 0):pos(370, 4)
	end

	an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
		if g_data.player:getIsCrossServer() then
			main_scene.ui:tip("该功能不能使用")

			return 
		end

		main_scene.ui:togglePanel("redPacket", 2)

		return 
	end, {
		label = {
			"发红包",
			18,
			0,
			{
				color = def.colors.btn
			}
		},
		pressImage = res.gettex2("pic/panels/guild/btnh.png")
	}).add2(slot4, self.rightPanel):anchor(0, 0):pos(0, 4)

	return 
end
local job_name = {
	[0] = "战士",
	"法师",
	"道士"
}
guild.showGuildMember = function (self)
	self.rightPanel:removeAllChildren()

	local orderPicDown = display.newSprite(res.getframe2("pic/panels/guild/downarrow.png"), 0, 0):anchor(0, 0):add2(self.rightPanel, 2):pos(202, self.rightPanel:geth() - 35)
	local orderPicUp = display.newSprite(res.getframe2("pic/panels/guild/downarrow.png"), 0, 0):anchor(0, 0):add2(self.rightPanel, 2):pos(223, self.rightPanel:geth() - 18):rotation(180)

	orderPicUp.setVisible(orderPicUp, false)

	local dataList = guildData.memberList

	local function orderMember(order, key, tagPos, tfunc)
		local mySelf = dataList[1]

		table.remove(dataList, 1)

		local func = nil

		if order then
			function func(l, r)
				if key == "FName" then
					return l.FName < r.FName
				else
					if l[key] == r[key] then
						return l.FName < r.FName
					end

					return tfunc(l[key], r[key])
				end

				return 
			end

			orderPicDown.setVisible(slot6, true)
			orderPicUp:setVisible(false)
		else
			function func(l, r)
				if key == "FName" then
					return r.FName < l.FName
				else
					if l[key] == r[key] then
						return l.FName < r.FName
					end

					return not tfunc(l[key], r[key])
				end

				return 
			end

			orderPicDown.setVisible(slot6, false)
			orderPicUp:setVisible(true)
		end

		print("sort前")
		print("=======##%$^%&&====", json.encode(dataList))
		print(func)
		table.sort(dataList, func)
		print("sort后 ")
		print("=======##%$^%&&====", json.encode(dataList))
		table.insert(dataList, 1, mySelf)
		orderPicDown:setPositionX(tagPos)
		orderPicUp:setPositionX(tagPos + 21)

		return 
	end

	self.rightBg.size(slot5, 480, 392)

	local refreshMemberInfo = nil
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(470, 42)):anchor(0, 0):pos(4, self.rightPanel:geth() - 46):add2(self.rightPanel)

	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(220, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(285, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(375, 0):add2(titlebg)

	local nameOrder = true

	an.newLabel("昵称", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(73, self.rightPanel:geth() - 23):add2(self.rightPanel, 2):enableClick(function ()
		orderMember(nameOrder, "FName", 120)

		nameOrder = not nameOrder

		refreshMemberInfo()

		return 
	end)

	local lvOrder = true

	an.newLabel("等级", 20, 0, {
		color = def.colors.labelTitle
	}).anchor(slot9, 0.5, 0.5):pos(182, self.rightPanel:geth() - 23):add2(self.rightPanel, 2):enableClick(function ()
		orderMember(lvOrder, "FLevel", 202, function (l, r)
			return r < l
		end)

		lvOrder = not lvOrder

		refreshMemberInfo()

		return 
	end)

	local jobOrder = true

	an.newLabel("职业", 20, 0, {
		color = def.colors.labelTitle
	}).anchor(slot10, 0.5, 0.5):pos(255, self.rightPanel:geth() - 23):add2(self.rightPanel, 2):enableClick(function ()
		orderMember(jobOrder, "FJob", 270, function (l, r)
			return l < r
		end)

		jobOrder = not jobOrder

		refreshMemberInfo()

		return 
	end)

	local titleOrder = true

	an.newLabel("职务", 20, 0, {
		color = def.colors.labelTitle
	}).anchor(slot11, 0.5, 0.5):pos(330, self.rightPanel:geth() - 23):add2(self.rightPanel, 2):enableClick(function ()
		orderMember(titleOrder, "FPosition", 350, function (l, r)
			return r < l
		end)

		titleOrder = not titleOrder

		refreshMemberInfo()

		return 
	end)

	local onlineOrder = true

	an.newLabel("状态", 20, 0, {
		color = def.colors.labelTitle
	}).anchor(slot12, 0.5, 0.5):pos(420, self.rightPanel:geth() - 23):add2(self.rightPanel, 2):enableClick(function ()
		orderMember(onlineOrder, "FLastOnlineDate", 440, function (l, r)
			return l < r
		end)

		onlineOrder = not onlineOrder

		refreshMemberInfo()

		return 
	end)

	local opFunc = {
		{
			"查看",
			function (v)
				local rsb = DefaultClientMessage(CM_QUERYUSERSTATE)
				rsb.FPlayerByID = v.FUserID

				MirTcpClient:getInstance():postRsb(rsb)

				return 
			end
		},
		{
			"添加好友",
			function (v)
				local rsb = DefaultClientMessage(CM_AddDelRelation)
				rsb.FTargetName = v.FName
				rsb.FRelationMark = 0
				rsb.FIfAdd = true

				MirTcpClient:getInstance():postRsb(rsb)

				return 
			end
		},
		{
			"私聊",
			function (v)
				common.changeChatStyle({
					{
						"target",
						v.FName
					},
					{
						"channel",
						"私聊"
					}
				})
				sound.playSound("103")
				self:hidePanel()

				return 
			end
		},
		{
			"踢出行会",
			function (v)
				an.newMsgbox({
					{
						"你确定将" .. v.FName .. "踢出行会么?确认后将" .. v.FName .. "玩家踢出行会",
						color = def.colors.text
					}
				}, function (idx)
					if idx == 2 then
						local rsb = DefaultClientMessage(CM_GildKickout)
						rsb.FUserId = v.FUserID

						MirTcpClient:getInstance():postRsb(rsb)
					end

					return 
				end, {
					disableScroll = true,
					hasCancel = true,
					btnTexts = {
						"取消",
						"确认"
					}
				})

				return 
			end
		},
		{
			"设副会长",
			function (v)
				local rsb = DefaultClientMessage(CM_GildSetPosition)
				rsb.FUserId = v.FUserID
				rsb.FPosition = 4

				MirTcpClient:getInstance():postRsb(rsb)

				return 
			end
		},
		{
			"设为长老",
			function (v)
				local rsb = DefaultClientMessage(CM_GildSetPosition)
				rsb.FUserId = v.FUserID
				rsb.FPosition = 3

				MirTcpClient:getInstance():postRsb(rsb)

				return 
			end
		},
		{
			"设为精英",
			function (v)
				local rsb = DefaultClientMessage(CM_GildSetPosition)
				rsb.FUserId = v.FUserID
				rsb.FPosition = 2

				MirTcpClient:getInstance():postRsb(rsb)

				return 
			end
		},
		{
			"设为会员",
			function (v)
				local rsb = DefaultClientMessage(CM_GildSetPosition)
				rsb.FUserId = v.FUserID
				rsb.FPosition = 1

				MirTcpClient:getInstance():postRsb(rsb)

				return 
			end
		},
		{
			"转让会长",
			function (v)
				an.newMsgbox({
					{
						"你确定转让会长给" .. v.FName .. "么?确认后将会长转为" .. v.FName .. "，同时自己变为会员",
						color = def.colors.text
					}
				}, function (idx)
					if idx == 2 then
						local rsb = DefaultClientMessage(CM_GildChangeChairMan)
						rsb.FUserId = v.FUserID

						MirTcpClient:getInstance():postRsb(rsb)
					end

					return 
				end, {
					disableScroll = true,
					hasCancel = true,
					btnTexts = {
						"取消",
						"确认"
					}
				})

				return 
			end
		}
	}
	local popupMenu = {
		{
			[0] = {
				1,
				2,
				3
			},
			{
				1,
				2,
				3
			}
		},
		[5] = {
			[0] = {
				1,
				2,
				3,
				4,
				5,
				6,
				7,
				9
			},
			{
				1,
				2,
				3,
				4,
				8,
				9
			}
		},
		[4] = {
			[0] = {
				1,
				2,
				3,
				4,
				6,
				7
			},
			{
				1,
				2,
				3,
				4,
				8
			}
		},
		[3] = {
			[0] = {
				1,
				2,
				3,
				4,
				7
			},
			{
				1,
				2,
				3,
				4,
				8
			}
		},
		[2] = {
			[0] = {
				1,
				2,
				3
			},
			{
				1,
				2,
				3
			}
		}
	}

	slot4(lvOrder, "FLevel", 202, function (l, r)
		return r < l
	end)

	lvOrder = not lvOrder
	local infoView = an.newScroll(4, 4, 480, 345).add2(slot14, self.rightPanel)
	local h = 50

	infoView.setScrollSize(infoView, 480, math.max(345, #dataList*h))
	infoView.enableClick(infoView, function ()
		return 
	end)

	local popupRoot = display.newNode().add2(slot16, main_scene.ui, 1000):size(display.width, display.height)

	popupRoot.enableClick(popupRoot, function ()
		popupRoot:setVisible(false)

		return 
	end)
	popupRoot.setVisible(slot16, false)

	local popupBg = display.newScale9Sprite(res.getframe2("pic/panels/guild/popupbg.png"), 0, 0, cc.size(160, 100)):anchor(0.5, 0.5):add2(popupRoot, 2):pos(display.width*0.5, display.height*0.5)
	local mySelf = nil

	function refreshMemberInfo()
		local mIndex = 1
		self.memberCells = {}

		infoView:removeAllChildren()

		local selectCell = display.newScale9Sprite(res.getframe2("pic/common/select.png"), 0, 0, cc.size(470, 48)):anchor(0, 0):add2(infoView)

		selectCell.setVisible(selectCell, false)

		while dataList[mIndex] do
			local last = socket.gettime()
			local v = dataList[mIndex]
			local infoColor = def.colors.cellNor

			if mIndex == 1 then
				mySelf = v
				infoColor = cc.c3b(230, 105, 70)
			elseif v.FLastOnlineDate ~= -1 then
				infoColor = def.colors.cellOffline
			end

			local cell = display.newScale9Sprite(res.getframe2((mIndex%2 == 0 and "pic/panels/guild/joinbg2.png") or "pic/panels/guild/joinbg1.png"), 0, 0, cc.size(470, h)):anchor(0, 0):pos(0, infoView:getScrollSize().height - mIndex*h):add2(infoView)
			cell.data = v

			cell.enableClick(cell, function ()
				selectCell:setVisible(true)
				selectCell:pos(cell:getPositionX(), cell:getPositionY())

				if v.FName == mySelf.FName then
					return 
				end

				popupRoot:setVisible(true)
				popupBg:removeAllChildren()

				local ops = {
					1,
					2,
					3
				}

				if v.FPosition < mySelf.FPosition then
					ops = popupMenu[mySelf.FPosition][0]

					if v.FPosition ~= 1 then
						ops = popupMenu[mySelf.FPosition][1]
					end
				end

				popupBg:setVisible(true)
				popupBg:size(160, #ops*48 + 50)
				an.newLabel(v.FName, 18, 0, {
					color = infoColor
				}):add2(popupBg):anchor(0.5, 0.5):pos(80, popupBg:geth() - 20)

				for k, v1 in pairs(ops) do
					an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
						sound.playSound("103")
						opFunc[v1][2](v)
						popupRoot:setVisible(false)

						return 
					end, {
						label = {
							opFunc[v1][1],
							18,
							0,
							{
								color = def.colors.btn
							}
						},
						pressImage = res.gettex2("pic/panels/guild/btnh.png")
					}).add2(popupMenu, popupBg):anchor(0.5, 0.5):pos(80, popupBg:geth() - 15 - k*48)
				end

				return 
			end, {
				support = "scroll"
			})

			self.memberCells[#self.memberCells + 1] = cell

			an.newLabel(v.FName, 18, 0, {
				color = infoColor
			}).add2(popupBg, cell):anchor(0.5, 0.5):pos(73, h*0.5)
			an.newLabel(common.getLevelText(v.FLevel), 18, 0, {
				color = infoColor
			}):add2(cell):anchor(0.5, 0.5):pos(182, h*0.5)
			an.newLabel(job_name[v.FJob], 18, 0, {
				color = infoColor
			}):add2(cell):anchor(0.5, 0.5):pos(255, h*0.5)
			an.newLabel(title_name[v.FPosition], 18, 0, {
				color = infoColor
			}):add2(cell):anchor(0.5, 0.5):pos(330, h*0.5):setName("FPosition")

			local onlineState = ""

			if v.FLastOnlineDate == -1 then
				onlineState = "在线"
			elseif v.FLastOnlineDate == 0 then
				onlineState = "离线"
			else
				onlineState = v.FLastOnlineDate .. "天前"
			end

			an.newLabel(onlineState, 18, 0, {
				color = infoColor
			}):add2(cell):anchor(0.5, 0.5):pos(420, h*0.5)

			mIndex = mIndex + 1
		end

		return 
	end

	slot5()

	return 
end
guild.showApply = function (self)
	self.rightPanel:removeAllChildren()
	self.rightBg:size(480, 332)

	local selectAllChkBox = nil
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(470, 42)):anchor(0, 0):pos(4, self.rightPanel:geth() - 46):add2(self.rightPanel)

	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(145, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(240, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(340, 0):add2(titlebg)
	an.newLabel("昵称", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(80, self.rightPanel:geth() - 23):add2(self.rightPanel, 2)
	an.newLabel("等级", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(200, self.rightPanel:geth() - 23):add2(self.rightPanel, 2)
	an.newLabel("职业", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(295, self.rightPanel:geth() - 23):add2(self.rightPanel, 2)
	an.newLabel("全选", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(400, self.rightPanel:geth() - 23):add2(self.rightPanel, 2)

	local userIds = {}

	if guildData.homeInfo.title == 5 or guildData.homeInfo.title == 4 or guildData.homeInfo.title == 3 then
		selectAllChkBox = createToggle(function ()
			userIds = {}

			if selectAllChkBox:isSelect() then
				for k, v in pairs(self.requestCells) do
					v.getChildByName(v, "chkBox"):select()

					userIds[#userIds + 1] = v.data.FUserID
				end
			else
				for k, v in pairs(self.requestCells) do
					v.getChildByName(v, "chkBox"):unselect()
				end
			end

			return 
		end, false).pos(slot4, 430, self.rightPanel:geth() - 40):add2(self.rightPanel, 2)
	end

	local dataList = guildData.applyList

	table.sort(dataList, function (l, r)
		if l.FLevel == r.FLevel then
			return l.FName < r.FName
		else
			return r.FLevel < l.FLevel
		end

		return 
	end)

	local infoView = an.newScroll(4, 62, 480, 285).add2(slot5, self.rightPanel)

	infoView.setScrollSize(infoView, 480, math.max(285, #dataList*50))
	infoView.enableClick(infoView, function ()
		return 
	end)

	self.requestCells = {}

	local function refreshApplyInfo()
		local mIndex = 1

		infoView:removeAllChildren()

		while dataList[mIndex] do
			local v = dataList[mIndex]
			local infoColor = def.colors.cellNor
			local cell = display.newScale9Sprite(res.getframe2((mIndex%2 == 0 and "pic/panels/guild/joinbg2.png") or "pic/panels/guild/joinbg1.png"), 0, 0, cc.size(470, 50)):anchor(0, 0):pos(0, infoView:getScrollSize().height - mIndex*50):add2(infoView)
			cell.data = v
			self.requestCells[#self.requestCells + 1] = cell

			an.newLabel(v.FName, 18, 0, {
				color = infoColor
			}):add2(cell):anchor(0.5, 0.5):pos(80, cell.geth(cell)*0.5)
			an.newLabel(common.getLevelText(v.FLevel), 18, 0, {
				color = infoColor
			}):add2(cell):anchor(0.5, 0.5):pos(200, cell.geth(cell)*0.5)
			an.newLabel(job_name[v.FJob], 18, 0, {
				color = infoColor
			}):add2(cell):anchor(0.5, 0.5):pos(295, cell.geth(cell)*0.5)
			display.newSprite(res.getframe2("pic/common/button_search.png"), 0, 0):anchor(0, 0):add2(cell):pos(362, 2):enableClick(function ()
				local rsb = DefaultClientMessage(CM_QUERYUSERSTATE)
				rsb.FPlayerByID = v.FUserID

				MirTcpClient:getInstance():postRsb(rsb)

				return 
			end)

			if guildData.homeInfo.title == 5 or guildData.homeInfo.title == 4 or guildData.homeInfo.title == 3 then
				local chkBox = nil
				chkBox = createToggle(function ()
					if chkBox:isSelect() then
						userIds[#userIds + 1] = v.FUserID
					else
						selectAllChkBox:unselect()

						for k1, v1 in pairs(userIds) do
							if v1 == v.FUserID then
								table.remove(userIds, k1)

								break
							end
						end
					end

					return 
				end, false).pos(guildData, 430, 10):add2(cell)

				chkBox.setName(chkBox, "chkBox")
			end

			mIndex = mIndex + 1
		end

		return 
	end

	slot6()

	if guildData.homeInfo.title == 5 or guildData.homeInfo.title == 4 or guildData.homeInfo.title == 3 then
		an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
			sound.playSound("103")

			local rsb = DefaultClientMessage(CM_GildApplyCondition)

			MirTcpClient:getInstance():postRsb(rsb)

			return 
		end, {
			label = {
				"招贤设置",
				18,
				0,
				{
					color = def.colors.btn
				}
			},
			pressImage = res.gettex2("pic/panels/guild/btnh.png")
		}).add2(slot7, self.rightPanel):anchor(0, 0):pos(0, 4)
		an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
			sound.playSound("103")

			if #userIds == 0 then
				main_scene.ui:tip("未选择任何玩家")

				return 
			end

			local rsb = DefaultClientMessage(CM_GildApplyApprove)
			rsb.FBoApprove = false
			rsb.FUserIDArray = userIds

			MirTcpClient:getInstance():postRsb(rsb)

			return 
		end, {
			label = {
				"拒 绝",
				18,
				0,
				{
					color = def.colors.btn
				}
			},
			pressImage = res.gettex2("pic/panels/guild/btnh.png")
		}).add2(slot7, self.rightPanel):anchor(0, 0):pos(240, 4)
		an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
			if #userIds == 0 then
				main_scene.ui:tip("未选择任何玩家")

				return 
			end

			sound.playSound("103")

			local rsb = DefaultClientMessage(CM_GildApplyApprove)
			rsb.FBoApprove = true
			rsb.FUserIDArray = userIds

			MirTcpClient:getInstance():postRsb(rsb)

			return 
		end, {
			label = {
				"同 意",
				18,
				0,
				{
					color = def.colors.btn
				}
			},
			pressImage = res.gettex2("pic/panels/guild/btnh.png")
		}).add2(slot7, self.rightPanel):anchor(0, 0):pos(370, 4)
	end

	return 
end
guild.showSocial = function (self)
	self.rightPanel:removeAllChildren()
	self.rightBg:size(480, 332)

	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(470, 42)):anchor(0, 0):pos(4, self.rightPanel:geth() - 46):add2(self.rightPanel)

	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(240, 0):add2(titlebg)
	an.newLabel("行会名称", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(120, self.rightPanel:geth() - 23):add2(self.rightPanel, 2)
	an.newLabel("外交状态", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(360, self.rightPanel:geth() - 23):add2(self.rightPanel, 2)

	local dataList = guildData.socialList

	table.sort(dataList, function (l, r)
		if l.FState == r.FState then
			if l.FOnlineCount == r.FOnlineCount then
				if l.FMemberCount == r.FMemberCount then
					return l.FGildName < r.FGildName
				else
					return r.FMemberCount < l.FMemberCount
				end
			else
				return r.FOnlineCount < l.FOnlineCount
			end
		else
			return r.FState < l.FState
		end

		return 
	end)

	local infoView = an.newScroll(4, 62, 480, 285).add2(slot3, self.rightPanel)

	infoView.setScrollSize(infoView, 480, math.max(285, #dataList*50))
	infoView.enableClick(infoView, function ()
		return 
	end)

	self.requestCells = {}
	local lastSelected = nil
	local popupRoot = display.newNode().add2(slot5, main_scene.ui, 1000):size(display.width, display.height)

	popupRoot.enableClick(popupRoot, function ()
		popupRoot:setVisible(false)

		return 
	end)
	popupRoot.setVisible(slot5, false)

	local popupBg = display.newScale9Sprite(res.getframe2("pic/panels/guild/popupbg.png"), 0, 0, cc.size(160, 100)):anchor(0.5, 0.5):add2(popupRoot, 2):pos(display.width*0.5, display.height*0.5)
	local ATTENTION_COLORS = {
		69,
		253,
		254,
		5
	}
	self.socialCells = {}

	local function refreshMemberInfo(data)
		lastSelected = nil
		self.socialCells = {}
		local mIndex = 1

		infoView:removeAllChildren()

		while data[mIndex] do
			local v = data[mIndex]
			local infoColor = def.colors.cellNor
			local cell = display.newScale9Sprite(res.getframe2((mIndex%2 == 0 and "pic/panels/guild/joinbg2.png") or "pic/panels/guild/joinbg1.png"), 0, 0, cc.size(470, 50)):anchor(0, 0):pos(0, infoView:getScrollSize().height - mIndex*50):add2(infoView)
			cell.data = v
			self.socialCells[#self.socialCells + 1] = cell

			cell.enableClick(cell, function ()
				if lastSelected ~= cell then
					if lastSelected then
						lastSelected:removeChildByName("select")
					end

					display.newScale9Sprite(res.getframe2("pic/common/select.png"), 0, 0, cc.size(470, 48)):anchor(0, 0):add2(cell):setName("select")

					lastSelected = cell
				end

				if guildData.homeInfo.title == 5 or guildData.homeInfo.title == 4 then
					popupRoot:setVisible(true)
					popupBg:removeAllChildren()

					if v.FState == 0 then
						popupBg:size(160, 100)
						an.newLabel(v.FGildName, 18, 0, {
							color = infoColor
						}):add2(popupBg):anchor(0.5, 0.5):pos(80, popupBg:geth() - 20)
						an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
							sound.playSound("103")
							popupRoot:setVisible(false)

							local rsb = DefaultClientMessage(CM_GildDeclareWar)
							rsb.FGildID = v.FGildID

							MirTcpClient:getInstance():postRsb(rsb)

							return 
						end, {
							label = {
								"宣战",
								18,
								0,
								{
									color = def.colors.btn
								}
							},
							pressImage = res.gettex2("pic/panels/guild/btnh.png")
						}).add2(lastSelected, popupBg):anchor(0.5, 0.5):pos(80, popupBg:geth() - 15 - 48)
					else
						popupBg:size(160, 200)
						an.newLabel("设置颜色", 18, 0, {
							color = infoColor
						}):add2(popupBg):anchor(0.5, 0.5):pos(80, popupBg:geth() - 20)

						for k1, v1 in ipairs(ATTENTION_COLORS) do
							local clr = def.colors.get(v1, true)
							local node = display.newNode():add2(popupBg):size(120, 25):pos(20, popupBg:geth() - 30 - k1*35):enableClick(function ()
								popupRoot:setVisible(false)

								local rsb = DefaultClientMessage(CM_SetGildDiplomacyColor)
								rsb.FGildID = v.FGildID
								rsb.FColor = v1

								MirTcpClient:getInstance():postRsb(rsb)

								return 
							end)

							display.newColorLayer(v):anchor(0.5, 0.5):size(120, 25):add2(node)
						end
					end
				end

				return 
			end, {
				support = "scroll"
			})

			self.requestCells[#self.requestCells + 1] = cell

			an.newLabel(v.FGildName, 18, 0, {
				color = infoColor
			}).add2(popupBg, cell):anchor(0.5, 0.5):pos(120, cell.geth(cell)*0.5)

			if v.FState ~= 0 then
				an.newLabel("宣战中", 18, 0, {
					color = infoColor
				}):add2(cell):anchor(0.5, 0.5):pos(295, cell.geth(cell)*0.5)

				local clr = def.colors.get(v.FColor, true)

				cc.LayerColor:create(clr):anchor(0.5, 0.5):size(25, 25):add2(cell):pos(360, 15):setName("guildcolor")
			else
				an.newLabel("", 18, 0, {
					color = infoColor
				}):add2(cell):anchor(0.5, 0.5):pos(295, cell.geth(cell)*0.5):setName("guildstate")
			end

			mIndex = mIndex + 1
		end

		return 
	end

	slot8(dataList)

	local filterInput = nil
	filterInput = an.newInput(0, 0, 196, 40, 5, {
		label = {
			self.filterString or "",
			20,
			1
		},
		bg = {
			tex = res.gettex2("pic/scale/edit.png"),
			offset = {
				-10,
				2
			}
		},
		tip = {
			"输入关键字查找      ",
			20,
			1,
			{
				color = cc.c3b(128, 128, 128)
			}
		},
		stop_call = function ()
			local key = filterInput:getString()

			if key == "" then
				if #self.socialCells ~= #dataList then
					refreshMemberInfo(dataList)
				end

				return 
			end

			local filtedGuild = {}

			for k, v in pairs(dataList) do
				if string.find(v.FGildName, key) then
					filtedGuild[#filtedGuild + 1] = v
				end
			end

			refreshMemberInfo(filtedGuild)

			return 
		end
	}).add2(slot10, self.rightPanel):anchor(0, 0):pos(8, 4):add(res.get2("pic/common/button_search.png"):pos(170, 20))

	an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
		sound.playSound("103")

		if g_data.client:checkLastTime("GuildSocial", 5) then
			g_data.client:setLastTime("GuildSocial", true)

			local rsb = DefaultClientMessage(CM_GildDiplomacyList)

			MirTcpClient:getInstance():postRsb(rsb)
		else
			main_scene.ui:tip("你刷新的太快了")
		end

		return 
	end, {
		label = {
			"刷 新",
			18,
			0,
			{
				color = def.colors.btn
			}
		},
		pressImage = res.gettex2("pic/panels/guild/btnh.png")
	}).add2(slot10, self.rightPanel):anchor(0, 0):pos(370, 4)

	return 
end
guild.showLog = function (self)
	self.rightPanel:removeAllChildren()
	self.rightBg:size(480, 392)

	local memCheck, socialCheck, refreshMemberInfo = nil
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(470, 42)):anchor(0, 0):pos(4, self.rightPanel:geth() - 46):add2(self.rightPanel)

	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(240, 0):add2(titlebg)

	memCheck = createToggle(function ()
		if socialCheck:isSelect() then
			socialCheck:unselect()
		end

		if memCheck:isSelect() == false then
			memCheck:select()

			return 
		end

		refreshMemberInfo(guildData.memberLogList)

		return 
	end, true).pos(slot5, 40, self.rightPanel:geth() - 40):add2(self.rightPanel, 2)
	local orderPicDown = display.newSprite(res.getframe2("pic/panels/guild/downarrow.png"), 0, 0):anchor(0, 0):add2(self.rightPanel, 2):pos(202, self.rightPanel:geth() - 35)
	local orderPicUp = display.newSprite(res.getframe2("pic/panels/guild/downarrow.png"), 0, 0):anchor(0, 0):add2(self.rightPanel, 2):pos(223, self.rightPanel:geth() - 18):rotation(180)

	orderPicUp.setVisible(orderPicUp, false)

	local crr = {}
	local dataList = guildData.memberLogList

	print("=======dataList ====", json.encode(dataList))

	local function orderMember(order, tfunc)
		for i, v in ipairs(dataList) do
			local temp = string.sub(v, string.find(v, "%d%d/%d%d %d%d:%d%d"))
			crr[i] = {
				time = temp,
				str = v
			}
		end

		local func = nil

		if order then
			function func(l, r)
				if l.time == r.time then
					return l.time < r.time
				end

				return tfunc(l.time, r.time)
			end

			orderPicDown.setVisible(orderPicUp, true)
			orderPicUp:setVisible(false)
		else
			function func(l, r)
				if l.time == r.time then
					return l.time < r.time
				end

				return not tfunc(l.time, r.time)
			end

			orderPicDown.setVisible(orderPicUp, false)
			orderPicUp:setVisible(true)
		end

		print("===排列前")
		print("=======##%$^%&&====", json.encode(crr))
		table.sort(crr, func)
		print("===排列后")
		print("=======##%$^%&&====", json.encode(crr))

		for i = 1, #crr, 1 do
			dataList[i] = crr[i].str

			print("=======##%$^%&&====", json.encode(dataList))
		end

		return 
	end

	local lvOrder = true

	an.newLabel("成员日志", 20, 0, {
		color = def.colors.labelTitle
	}).anchor(slot11, 0.5, 0.5):pos(120, self.rightPanel:geth() - 23):add2(self.rightPanel, 2):enableClick(function ()
		orderMember(lvOrder, function (l, r)
			return r < l
		end)

		lvOrder = not lvOrder

		refreshMemberInfo(dataList)

		return 
	end)

	socialCheck = createToggle(function ()
		if memCheck:isSelect() then
			memCheck:unselect()
		end

		if socialCheck:isSelect() == false then
			socialCheck:select()

			return 
		end

		refreshMemberInfo(guildData.socialLogList)

		return 
	end, false).pos(slot11, 280, self.rightPanel:geth() - 40):add2(self.rightPanel, 2)

	an.newLabel("外交日志", 20, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(360, self.rightPanel:geth() - 23):add2(self.rightPanel, 2)

	local infoView = an.newScroll(4, 4, 480, 342):add2(self.rightPanel)

	infoView.enableClick(infoView, function ()
		return 
	end)

	function refreshMemberInfo(data)
		infoView:setScrollSize(480, 2500)
		infoView:removeAllChildren()

		for i = 1, 50, 1 do
			local v = data[i]
			local infoColor = def.colors.cellNor
			local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/panels/guild/joinbg2.png") or "pic/panels/guild/joinbg1.png"), 0, 0, cc.size(470, 50)):anchor(0, 0):pos(0, infoView:getScrollSize().height - i*50):add2(infoView)

			if v then
				an.newLabel(v, 16, 0, {
					color = infoColor
				}):add2(cell):anchor(0, 0.5):pos(8, cell.geth(cell)*0.5)
			end
		end

		return 
	end

	slot3(guildData.memberLogList)

	return 
end
guild.onEnter = function (self)
	print("guild:onEnter()")

	return 
end
guild.onExit = function (self)
	print("guild:onExit()")

	return 
end

return guild
