local group = class("group", function ()
	return display.newNode()
end)
local common = import("..common.common")

table.merge(slot0, {
	lightBtn,
	namesLayer,
	groupLeader = false
})

group.ctor = function (self)
	self._supportMove = true
	self.groupLeader = false
	local bg = display.newSprite(res.gettex2("pic/common/black_0.png")):anchor(0, 0):add2(self)

	self.size(self, bg.getw(bg), bg.geth(bg)):anchor(0.5, 0.5):center()
	an.newLabel("组队", 22, 0, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(self.getw(self)*0.5, self.geth(self) - 22):add2(bg)

	local width = {
		210,
		60,
		60,
		150
	}
	self.Titlelabel = {
		"角色名",
		"等级",
		"职业",
		"所属行会"
	}
	local posOffset = 143
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(self.getw(self) - posOffset - 16, 42)):anchor(0, 1):pos(posOffset, self.geth(self) - 52):add2(bg)

	for i, v in ipairs(width) do
		self.Titlelabel[i] = an.newLabel(self.Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v*0.5, self.geth(self) - 74):add2(self)
		posOffset = posOffset + v

		if i == 4 then
			break
		end

		display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(posOffset, self.geth(self) - 94):add2(self)
	end

	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot5, 1, 1):pos(self.getw(self) - 9, self.geth(self) - 9):addto(self)

	if 1 < #g_data.player.groupMembers then
		g_data.player.groupEnable = true
	end

	self.stateLabel = an.newLabel("允许组队", 18, 1, {
		color = def.colors.labelGray
	}):anchor(1, 0.5):add2(bg):pos(110, 38)

	local function click()
		if 1 < #g_data.player.groupMembers then
			return 
		end

		local rsb = DefaultClientMessage(CM_GroupMode)
		rsb.FOpen = not self.groupBtn.isSelect

		MirTcpClient:getInstance():postRsb(rsb)
		self.groupBtn:setIsSelect(not self.groupBtn.isSelect)

		return 
	end

	self.groupBtn = an.newBtn(res.gettex2("pic/common/toggle10.png"), slot5, {
		support = "easy",
		select = {
			res.gettex2("pic/common/toggle11.png"),
			manual = true
		}
	}):anchor(0, 0.5):pos(118, 38):add2(bg)

	self.groupBtn:setIsSelect(g_data.player.groupEnable)

	self.labelTitle = {
		mine = {
			"角色名",
			"等级",
			"职业",
			"所在地图",
			{
				"退出队伍",
				"添加",
				"队伍链接",
				"踢出队伍"
			},
			"当前未组队。",
			{
				"退出队伍",
				"添加",
				"队伍链接",
				"踢出队伍"
			}
		},
		near = {
			"角色名",
			"等级",
			"职业",
			"所属行会",
			{
				"其他操作"
			},
			"当前附近无其他玩家。",
			{
				"操作"
			}
		},
		group = {
			"队长名",
			"等级",
			"人数",
			"队长行会",
			{
				"申请入队"
			},
			"当前附近无其他队伍。",
			{
				"申请入队"
			}
		},
		friends = {
			"角色名",
			"等级",
			"职业",
			"所属行会",
			{
				"邀请入队"
			},
			"当前无好友在线。",
			{
				"邀请入队"
			}
		}
	}
	local texts = {
		"我的队伍",
		"附近玩家",
		"附近队伍",
		"在线好友"
	}
	local texts2 = {
		"mine",
		"near",
		"group",
		"friends"
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
		end

		if btn.page ~= self.page then
			self.page = btn.page

			if self.page == "near" then
				self:showPageInfo(btn.page)
			elseif self.page == "friends" then
				local data = g_data.relation:getFriends()
				local online = {}

				for i, v in ipairs(data) do
					if v.FIsOnline then
						online[#online + 1] = v
					end
				end

				self:showPageInfo(btn.page, online)
			elseif self.page == "mine" then
				local rsb = DefaultClientMessage(CM_QueryGroupMembers)

				MirTcpClient:getInstance():postRsb(rsb)
				self:showPageInfo(btn.page, g_data.player.groupMembers)
			elseif self.page == "group" then
				self:showPageInfo(btn.page)
				print("CM_QUERY_NEARBYGROUP")

				local rsb = DefaultClientMessage(CM_QueryNearbyGroup)

				MirTcpClient:getInstance():postRsb(rsb)
			end
		end

		return 
	end

	for i, v in ipairs(slot6) do
		tabs[i] = an.newBtn(res.gettex2("pic/common/btn60.png"), click, {
			support = "easy",
			label = {
				v,
				20,
				0,
				{
					color = def.colors.Cf0c896
				}
			},
			anchor = {
				0.5,
				0.5
			},
			select = {
				res.gettex2("pic/common/btn61.png"),
				manual = true
			}
		}):add2(bg):anchor(0, 0.5):pos(18, (i - 1)*54 - 370)
		tabs[i].page = texts2[i]
	end

	click(tabs[1])
	self.enableAllow(self)

	return 
end
group.enableAllow = function (self)
	self.groupBtn:setIsSelect(g_data.player.groupEnable)

	return 
end

function sortData(page, data)
	if page == "mine" then
		table.sort(data, function (a, b)
			if a.FIsCaptain then
				return true
			elseif b.FIsCaptain then
				return false
			elseif tonumber(a.FJoinTime) < tonumber(b.FJoinTime) then
				return true
			else
				return false
			end

			return 
		end)
	end

	return data
end

group.showPageInfo = function (self, page, data)
	data = data and sortData(page, data)

	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():addto(self)

	self.content:size(539, 387):anchor(1, 1):pos(self.getw(self) - 16, self.geth(self) - 70)

	data = data or {}

	if page == "near" then
		local list = {}

		if main_scene.ground.map then
			list = main_scene.ground.map:getHeroInfoList()
		end

		data = list
	end

	self.groupBtn:setTouchEnabled(#g_data.player.groupMembers == 0)

	local selectRole, selectRoleId = nil

	local function clickfunc(cmd, name, roleId)
		if cmd == "退出队伍" then
			if #g_data.player.groupMembers == 0 then
				main_scene.ui:tip("您还没有队伍。")

				return 
			end

			local msgbox = nil
			slot4 = an.newMsgbox("", function (isOk)
				if isOk == 1 then
					g_data.client:setLastTime("group", true)

					g_data.player.groupEnable = false
					local rsb = DefaultClientMessage(CM_DelGroupMember)
					rsb.FName = common.getPlayerName()

					MirTcpClient:getInstance():postRsb(rsb)
				end

				return 
			end, {
				hasCancel = true
			})
			msgbox = slot4

			an.newLabel("您确定退出队伍吗？", 20, 1, {
				color = def.colors.cellNor
			}):addTo(msgbox.bg):pos(msgbox.bg:getw()/2, 180):anchor(0.5, 0.5)
		elseif cmd == "队伍链接" then
			local leaderName = g_data.player:getLeaderName()

			if leaderName and leaderName ~= "" then
				if main_scene.ui.panels.chat then
					main_scene.ui.panels.chat.input.keyboard:setText(string.format("{#gr%s|的队伍}", leaderName))
				end

				if main_scene.ui.panels.relation and main_scene.ui.panels.relation.keyboard then
					main_scene.ui.panels.relation.keyboard:setText(string.format("{#gr%s|的队伍}", leaderName))
				end

				if main_scene.ui.console.widgets.chat.input.keyboard then
					main_scene.ui.console.widgets.chat.input.keyboard:setText(string.format("{#gr%s|的队伍}", leaderName))
				end
			else
				main_scene.ui:tip("你没有队伍，不可发送队伍链接")
			end
		elseif cmd == "添加" then
			if 0 < #g_data.player.groupMembers and not g_data.player.isTeamLeader then
				main_scene.ui:tip("不是队长不能添加成员。")

				return 
			end

			local msgbox = nil
			slot4 = an.newMsgbox("  输入邀请组队的玩家名.", function (idx)
				if idx == 1 then
					if msgbox.nameInput:getString() == "" then
						return 
					end

					if msgbox.nameInput:getString() == common.getPlayerName() then
						main_scene.ui:tip("不可邀请自己组队。")

						return 
					end

					g_data.client:setLastTime("group", true)

					if #g_data.player.groupMembers == 0 then
						local rsb = DefaultClientMessage(CM_CreateGroup)
						rsb.FName = msgbox.nameInput:getString()

						MirTcpClient:getInstance():postRsb(rsb)
					else
						local rsb = DefaultClientMessage(CM_AddGroupMember)
						rsb.FName = msgbox.nameInput:getString()

						MirTcpClient:getInstance():postRsb(rsb)
					end
				end

				return 
			end, {
				disableScroll = true,
				hasCancel = true
			})
			msgbox = slot4
			msgbox.nameInput = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 14, {
				checkCLen = true,
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
					"",
					20,
					1,
					{
						color = cc.c3b(128, 128, 128)
					}
				}
			}):add2(msgbox.bg):pos(msgbox.bg:getw()*0.5 + 10, msgbox.bg:geth()*0.5 + 20)
		end

		if not name then
			return 
		end

		if cmd == "邀请入队" then
			local msgbox = nil
			slot4 = an.newMsgbox("", function (isOk)
				if isOk == 1 then
					g_data.client:setLastTime("group", true)

					if #g_data.player.groupMembers == 0 then
						local rsb = DefaultClientMessage(CM_CreateGroup)
						rsb.FName = name

						MirTcpClient:getInstance():postRsb(rsb)
					else
						local rsb = DefaultClientMessage(CM_AddGroupMember)
						rsb.FName = name

						MirTcpClient:getInstance():postRsb(rsb)
					end
				end

				return 
			end, {
				hasCancel = true
			})
			msgbox = slot4

			an.newLabel("您确定邀请 " .. name .. " 加入队伍吗？", 20, 1, {
				color = def.colors.cellNor
			}):addTo(msgbox.bg):pos(msgbox.bg:getw()/2, 180):anchor(0.5, 0.5)
		elseif cmd == "申请入队" then
			if 0 < #g_data.player.groupMembers then
				main_scene.ui:tip("您已有队伍。")
			else
				local msgbox = nil
				slot4 = an.newMsgbox("", function (isOk)
					if isOk == 1 then
						g_data.client:setLastTime("group", true)

						local rsb = DefaultClientMessage(CM_JoinGroup)
						rsb.FName = name

						MirTcpClient:getInstance():postRsb(rsb)
					end

					return 
				end, {
					hasCancel = true
				})
				msgbox = slot4

				an.newLabel("您确定申请加入 " .. name .. " 的队伍吗？", 20, 1, {
					color = def.colors.cellNor
				}):addTo(msgbox.bg):pos(msgbox.bg:getw()/2, 180):anchor(0.5, 0.5)
			end
		elseif cmd == "踢出队伍" then
			print("踢出队伍")

			if #g_data.player.groupMembers == 0 then
				main_scene.ui:tip("您还没有队伍。")

				return 
			end

			if 0 < #g_data.player.groupMembers and not g_data.player.isTeamLeader then
				main_scene.ui:tip("不是队长不能踢出成员。")

				return 
			end

			if 0 < #g_data.player.groupMembers and g_data.player.isTeamLeader and common.getPlayerName() == name then
				main_scene.ui:tip("队长不可将自己踢出队伍")

				return 
			end

			local msgbox = nil
			slot4 = an.newMsgbox("", function (isOk)
				if isOk == 1 then
					g_data.client:setLastTime("group", true)

					local rsb = DefaultClientMessage(CM_DelGroupMember)
					rsb.FName = name

					MirTcpClient:getInstance():postRsb(rsb)
				end

				return 
			end, {
				hasCancel = true
			})
			msgbox = slot4

			an.newLabel("您确定要求 " .. name .. " 离开队伍吗？", 20, 1, {
				color = def.colors.cellNor
			}):addTo(msgbox.bg):pos(msgbox.bg:getw()/2, 180):anchor(0.5, 0.5)
		elseif cmd == "其他操作" then
			local menuPos = self:convertToWorldSpaceAR(cc.p(188, -162))

			main_scene.ui:togglePanel("commonMenu", {
				pos = menuPos,
				name = name,
				id = roleId
			})
		end

		return 
	end

	local labels = self.labelTitle[page] or {}

	for i = 1, 4, 1 do
		self.Titlelabel[i].setString(slot11, labels[i] or "")
	end

	labels[5] = labels[5] or {}
	local btnSpr = labels[7] or {}

	for i, v in ipairs(labels[5]) do
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")
			clickfunc(v, selectRole, selectRoleId)

			return 
		end, {
			label = {
				btnSpr[i],
				20,
				0,
				{
					color = def.colors.Cf0c896
				}
			},
			pressImage = res.gettex2("pic/common/btn21.png")
		}).add2(slot13, self.content):anchor(0.5, 0.5):pos(i*100 - 580, 38)
	end

	local infoView = an.newScroll(58, 62, 478, 300):add2(self.content)
	local h = 42

	infoView.setScrollSize(infoView, 530, math.max(320, #data*h))

	local selectPic, selectData = nil

	if #data == 0 then
		an.newLabel(labels[6] or "", 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(self.content:getw()/2 + 40, self.content:geth()/2 + 30):add2(self.content, 2)
	end

	for i, v in ipairs(data) do
		local info = {}
		local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(530, h)):anchor(0, 0):pos(0, infoView.getScrollSize(infoView).height - i*h):add2(infoView)
		local tmpColor = (((page == "mine" and v.FIsOnLine) or page == "near" or page == "group" or (page == "friends" and v.FIsOnline)) and cc.c3b(255, 255, 255)) or def.colors.cellOffline

		if page ~= "group" or not v.FLeaderName then
			local name = g_data.player:fixStrLen(v.FName or "", 8)
		end

		info[#info + 1] = an.newLabel(name or "", 18, 1, {
			color = tmpColor
		}):add2(cell):anchor(0.5, 0.5):pos(105, h*0.5)
		local label = (page == "group" and v.FLeaderLevel) or v.FLevel .. ""
		label = common.getLevelText(label) .. "级"
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = tmpColor
		}):add2(cell):anchor(0.5, 0.5):pos(240, h*0.5)
		label = (page == "group" and v.FMemberCount .. "") or g_data.player:getOtherJobStr(v.FJob)
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = tmpColor
		}):add2(cell):anchor(0.5, 0.5):pos(300, h*0.5)

		if page == "mine" then
			label = (v.FIsOnLine and v.FMapDesc) or "离线"
		elseif page == "group" then
			label = v.FLeaderGuildName or ""
		else
			label = v.FGuildName or ""
		end

		info[#info + 1] = an.newLabel(label or "", 18, 1, {
			color = tmpColor
		}):add2(cell):anchor(0.5, 0.5):pos(405, h*0.5)

		if v.FIsCaptain then
			res.get2("pic/panels/group/icon.png"):add2(cell):anchor(0.5, 0.5):pos(30, h*0.48)
		end

		cell.setTouchEnabled(cell, true)
		cell.setTouchSwallowEnabled(cell, false)
		cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				cell.offsetBeginY = event.y

				return true
			elseif event.name == "ended" then
				local offsetY = event.y - cell.offsetBeginY

				if math.abs(offsetY) <= 5 then
					if selectPic then
						for i, v in ipairs(selectPic.info) do
							v.setColor(v, selectPic.color or def.colors.cellNor)
						end

						selectPic:removeSelf()

						selectPic = nil
					end

					selectRole = (page == "group" and v.FLeaderName) or v.FName
					selectRoleId = v.FUserId
					selectPic = display.newScale9Sprite(res.getframe2("pic/common/select.png"), 0, 0, cc.size(481, h)):anchor(0, 0):pos(-2, 0):add2(cell)
					selectPic.info = info
					selectPic.color = tmpColor

					for i, v in ipairs(info) do
						v.setColor(v, def.colors.cellSel)
					end
				end
			end

			return 
		end)

		if i == 1 then
			selectRole = (page == "group" and v.FLeaderName) or v.FName
			selectRoleId = v.FUserId
			selectPic = display.newScale9Sprite(res.getframe2("pic/common/select.png"), 0, 0, cc.size(481, slot9)):anchor(0, 0):pos(-2, 0):add2(cell)
			selectPic.info = info
			selectPic.color = tmpColor

			for i, v in ipairs(info) do
				v.setColor(v, def.colors.cellSel)
			end
		end
	end

	return 
end
group.allowRequest = function (self)
	return not g_data.client.lastTime.group or 5 < socket.gettime() - g_data.client.lastTime.group
end

return group
