local role = import(".role")
local common = import("..main.common.common")
local baseScene = import("..baseScene", ...)
local scene = class("select", baseScene)

table.merge(scene, {})

local sceneW = display.width
local sceneH = display.height
local dew = display.width/sceneW
local deh = display.height/sceneH
local rolePos = {
	function ()
		return display.cx - 208, display.height - 140
	end,
	function ()
		return display.cx + 158, display.height - 140
	end
}
local namepos = {
	function ()
		return display.cx - 318, 114
	end,
	function ()
		return display.cx + 237, 114
	end
}
local editPos = {
	function ()
		return display.cx - 168, display.height - 240
	end,
	function ()
		return display.cx + 208, display.height - 240
	end
}

local function recoveryPos()
	return display.cx - 168, display.height - 260
end

local roleUpperLimit = 4
local newRoleErrorMsg = {
	[-6.0] = "服务端注册名字失败",
	[-10.0] = "新建角色通用失败",
	[-4.0] = "非法角色数据",
	[-7.0] = "服务端禁止注册",
	[-3.0] = "可用角色数量超过限制",
	[-5.0] = "含有违禁字符",
	[-2.0] = "角色名已存在",
	[-1.0] = "角色名不符合规则"
}
scene.onSM_NewChrRsp = function (self, result, proIc)
	if result then
		self.hideMask(self)

		if result.Flag ~= 1 then
			tip(newRoleErrorMsg[result.Flag])
			self.getRoleListSuccess(self)

			self.newRoleName = nil
		else
			g_data.select.hasNewChr = true
			g_data.select.newRoleEnterGame = true
		end
	end

	return 
end
local scErrorMsg = {
	[-6.0] = "选角色排队等待",
	[-1.0] = "角色被锁定，暂时不可使用",
	[-4.0] = "角色数据读取失败",
	[-7.0] = "您的账号被封停，请联系客服",
	[-3.0] = "游戏服务器暂时不可用",
	[-5.0] = "该角色已经删除",
	[-2.0] = "角色不存在",
	[-8.0] = "选择角色通用失败协议"
}
scene.onSM_SelChrRsp = function (self, result, proIc)
	if not result then
		return 
	end

	if result.Flag == 1 then
		audio.stopMusic(true)
		g_data.setting.init(g_data.select:getCurName())
		game.gotoscene("notice", nil, "fade", 0.5, display.COLOR_BLACK)

		local data = g_data.select.roles[g_data.select.selectIndex]

		MirSDKAgent:logEvent("OnRoleLogined", {
			createTimestamp = data.createTime,
			roleId = data.userId,
			roleLevel = data.level,
			roleName = data.name,
			sex = data.sex,
			job = data.job,
			zoneId = g_data.login.localLastSer.id,
			zoneName = g_data.login.localLastSer.name
		})
	elseif result.Flag == -9 then
		an.newMsgbox(result.FHintMsg, nil, {
			center = true
		})
		self.hideMask(self)
	else
		tip(scErrorMsg[result.Flag])
		self.hideMask(self)
	end

	return 
end
scene.onSM_CharacterInfo = function (self, result, proIc)
	if result then
		self.hideMask(self)
		g_data.select:receiveRoles(result)

		self.pageIdx = math.ceil(g_data.select.selectIndex/2)

		self.pageBtn[1]:setVisible(2 < #g_data.select.roles)
		self.pageBtn[2]:setVisible(2 < #g_data.select.roles)
		self.getRoleListSuccess(self)

		if self.newRoleName then
			g_data.select.selectIndex = #g_data.select.roles

			self.enterGameRequest(self, self.newRoleName)

			self.newRoleName = nil
		end
	end

	return 
end
scene.ctor = function (self)
	g_data.login:setLoginState(GameStateType.selected)

	self.mask = nil
	self.timeoutHandler = nil
	self.area = nil
	self.closedMsgbox = nil
	self.entered = false
	self.roles = {}
	self.del_roles = {}
	self.del_selectIdx = nil

	return 
end
scene.bindMsg = function (self)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_NewChrRsp, self, self.onSM_NewChrRsp)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_SelChrRsp, self, self.onSM_SelChrRsp)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ChrList, self, self.onSM_CharacterInfo)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_DelChrRsp, self, self.onSM_DelChrRsp)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_RecoveChrRsp, self, self.onSM_RecoveChrRsp)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_DelChrList, self, self.onSM_DelChrList)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_SELCHR_EXIT, self, self.onSM_SELCHR_EXIT)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_OUTOFCONNECTION_KICKOUT, self, self.onSM_OUTOFCONNECTION_KICKOUT)

	return 
end
scene.onSM_OUTOFCONNECTION_KICKOUT = function (self, result, proIc)
	if result then
		an.newMsgbox("已经被其他用户踢下线", function (idx)
			common.gotoLogin(true)

			return 
		end, {
			center = true
		})
	end

	return 
end
scene.onSM_SELCHR_EXIT = function (self, result, protoId)
	if result then
		common.gotoLogin(true)
	end

	return 
end
scene.onSM_DelChrList = function (self, result, protoId)
	if result then
		if 0 < result.FCount then
			self.receiveDelChrs(self, result)
			self.ShowDelChrList(self)
		else
			tip("没有找到被删除的角色")
		end
	end

	return 
end
scene.receiveDelChrs = function (self, result)
	self.del_selectIdx = nil
	self.del_roles = {}

	for i = 1, result.FCount, 1 do
		self.del_roles[#self.del_roles + 1] = {
			name = result.FChrList[i].FName,
			job = result.FChrList[i].FJob,
			hair = result.FChrList[i].FHair,
			level = result.FChrList[i].FLevel,
			sex = result.FChrList[i].FSex
		}
	end

	return 
end
scene.onSM_DelChrRsp = function (self, result, protoId)
	if result then
		if result.Flag == 0 then
			tip("删除角色失败")
		elseif result.Flag == 2 then
			tip("当天删除角色数已达上限")
		end
	end

	return 
end
scene.onSM_RecoveChrRsp = function (self, result, protoId)
	if result and (result.Flag ~= 1 or false) and result.Flag == 3 then
		tip("你最多只能为一个帐号设置4个角色")
	end

	return 
end
scene.onEnter = function (self)
	print("select.scene:onEnter")
	self.super.onEnter(self)
	_G.def.items.initFilt()

	return 
end
scene.onExit = function (self)
	print("select.scene:onExit")
	self.super.onExit(self)

	return 
end
scene.enterGameRequest = function (self, curName)
	if self.mask ~= nil then
		self.hideMask(self)
	elseif self.checkTcpConnect(self) then
		local rsb = DefaultClientMessage(CM_SelChr)
		rsb.FName = curName
		rsb.FUserid = g_data.select:getUserIdByName(curName)

		MirTcpClient:getInstance():postRsb(rsb)
	end

	self.showMask(self)

	if 0 < DEBUG then
		print("g_data.login.groupIndex:" .. g_data.login.groupIndex)
		print("g_data.login.selectIndex:" .. g_data.login.selectIndex)
		print("g_data.login.ac:" .. g_data.login.ac)
		print("g_data.select:getCurName:" .. g_data.select:getCurName())

		local selCurRole = g_data.select.roles[g_data.select.selectIndex]

		if selCurRole ~= nil then
			print(" g_data.select.roles[" .. g_data.select.selectIndex .. "].name:" .. selCurRole.name)
			print(" g_data.select.roles[" .. g_data.select.selectIndex .. "].job:" .. selCurRole.job)
			print(" g_data.select.roles[" .. g_data.select.selectIndex .. "].hair:" .. selCurRole.hair)
			print(" g_data.select.roles[" .. g_data.select.selectIndex .. "].level:" .. selCurRole.level)
			print(" g_data.select.roles[" .. g_data.select.selectIndex .. "].sex:" .. selCurRole.sex)
		end
	end

	return 
end
scene.onEnterTransitionFinish = function (self)
	self.bindMsg(self)

	local layer = display.newNode():size(sceneW, sceneH):anchor(0.5, 0.5):center():addTo(self)
	local bg = res.get2("pic/login/select_bg.png"):anchor(0.5, 0.5):addTo(layer):pos(display.width/2, display.height/2)
	local h = bg.geth(bg)

	bg.scaleY(bg, display.height/h)
	res.get2("pic/login/severBg.png"):anchor(0.5, 1):addTo(layer):pos(display.cx, display.height - 5)

	self.area = an.newLabel(g_data.login.localLastSer.name, 18, 1):anchor(0.5, 1):pos(display.cx, display.height - 5):addto(layer):hide()

	res.get2("pic/login/figure_left.png"):anchor(0.5, 1):addTo(layer):pos(display.cx - 180, display.height - 60)
	res.get2("pic/login/figure_right.png"):anchor(0.5, 1):addTo(layer):pos(display.cx + 185, display.height - 60)

	local function clickBtn(i)
		sound.playSound("103")

		if self.mask then
			return 
		end

		if not self:checkTcpConnect() then
			return 
		end

		if i == 1 then
			if #g_data.select.roles == 0 then
				an.newMsgbox("你还没创建角色.", nil, {
					center = true
				})
			else
				local curName = g_data.select:getCurName()

				self:enterGameRequest(curName)
			end
		elseif i == 2 then
			if 20 <= #g_data.select.roles and IS_PLAYER_DEBUG then
				an.newMsgbox("您的角色已满20个", nil, {
					center = true
				})
			elseif roleUpperLimit <= #g_data.select.roles and not IS_PLAYER_DEBUG then
				an.newMsgbox("您的角色已满" .. roleUpperLimit .. "个", nil, {
					center = true
				})
			else
				self:showCreate()
			end
		elseif i == 3 then
			if #g_data.select.roles == 0 then
				return 
			end

			an.newMsgbox("[" .. g_data.select:getCurName() .. "]删除的角色是不能被恢复的,\n一段时间内您将不能使用相同的角色名称.\n你真的确定要删除吗？", function (idx)
				if idx == 1 then
					an.newMsgbox("再次确认你真的确定要删除吗？", function (idx)
						if idx == 1 then
							local rsb = DefaultClientMessage(CM_DelChr)
							rsb.FName = g_data.select.roles[g_data.select.selectIndex].name

							MirTcpClient:getInstance():postRsb(rsb)
						end

						return 
					end, {
						center = true,
						hasCancel = true
					})
				end

				return 
			end, {
				hasCancel = true
			})
		elseif i == 4 then
			local rsb = DefaultClientMessage(CM_QueryDelChr)

			MirTcpClient.getInstance(slot2):postRsb(rsb)
		elseif i == 5 then
			local rsb = DefaultClientMessage(CM_SELCHR_EXIT)

			MirTcpClient:getInstance():postRsb(rsb)
		end

		return 
	end

	res.get2("pic/login/centerBg.png").anchor(slot5, 0.5, 1):addTo(layer):pos(display.cx, 190)
	res.get2("pic/login/select1.png"):anchor(0.5, 1):addTo(layer):pos(display.cx - 280, 190)
	res.get2("pic/login/select2.png"):anchor(0.5, 1):addTo(layer):pos(display.cx + 280, 190)

	for i = 1, 5, 1 do
		local x, y = nil

		if i == 1 or i == 5 then
			y = 104
			x = layer.getw(layer)/2 + ((i == 1 and -100) or 100)
		else
			y = (i - 4)*40 + 64
			x = layer.getw(layer)/2
		end

		if i == 1 then
			local btn = nil
			btn = an.newBtn(res.gettex2("pic/login/tab1.png"), function ()
				clickBtn(i)

				return 
			end, {
				pressImage = res.gettex2("pic/login/tab2.png")
			}).pos(slot12, x, y):addto(layer)

			if not g_data.player.smallExit then
				btn.setTouchEnabled(btn, false)

				local mask = cc.LayerColor:create(cc.c4b(0, 0, 0, 180)):anchor(0, 0):pos(0, 0):addto(btn):size(btn.getContentSize(btn).width, btn.getContentSize(btn).height)
				local percent = 0

				mask.runAction(mask, cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
					percent = percent + 2

					if 100 < percent then
						btn:setTouchEnabled(true)
						mask:stopAllActions()
						mask:removeSelf()
					else
						mask:pos(0, 0):size(btn:getContentSize().width, btn:getContentSize().height*(percent/100 - 1))
					end

					return 
				end))))
			end
		elseif i == 5 then
			an.newBtn(res.gettex2("pic/login/tab9.png"), function ()
				self.returnBtn = true

				clickBtn(i)

				return 
			end, {
				pressImage = res.gettex2("pic/login/tab10.png")
			}).pos(slot11, x, y):addto(layer)
		else
			an.newBtn(res.gettex2("pic/login/tab" .. i*2 - 1 .. ".png"), function ()
				clickBtn(i)

				return 
			end, {
				pressImage = res.gettex2("pic/login/tab" .. i*2 .. ".png")
			}).pos(slot11, x, y):addto(layer)
		end
	end

	local function clickSelect(idx)
		sound.playSound("104")

		if not self.roles[idx] or idx == g_data.select.selectIndex then
			return 
		end

		sound.playSound("101")

		for k, v in pairs(self.roles) do
			if k == g_data.select.selectIndex then
				v.model:setState("unselected")
			elseif k == idx then
				v.model:setState("selected")
			end
		end

		g_data.select:setSelectIndex(idx)

		return 
	end

	an.newBtn(res.getuitex(1, 66), function ()
		clickSelect((self.pageIdx - 1)*2 + 1)

		return 
	end, {
		pressShow = true
	}).pos(slot6, display.cx - 240, 153):addto(layer)
	an.newBtn(res.getuitex(1, 66), function ()
		clickSelect((self.pageIdx - 1)*2 + 2)

		return 
	end, {
		pressShow = true
	}).pos(slot6, display.cx + 318, 153):addto(layer)

	local function clickPage(idx)
		local pages = math.ceil(#g_data.select.roles/2)

		if idx == 1 then
			self.pageIdx = (0 < self.pageIdx - 1 and self.pageIdx - 1) or pages
		else
			self.pageIdx = (self.pageIdx + 1 <= pages and self.pageIdx + 1) or 1
		end

		self:getRoleListSuccess()

		return 
	end

	self.pageIdx = math.ceil(g_data.select.selectIndex/2)
	self.pageBtn = {}

	for i = 1, 2, 1 do
		self.pageBtn[i] = an.newBtn(res.gettex2("pic/login/updown0_" .. slot10 .. ".png"), function ()
			clickPage(i)

			return 
		end, {
			pressImage = res.gettex2("pic/login/updown1_" .. slot10 .. ".png")
		}):addTo(layer):pos(display.cx, display.height - 160 - i*60)

		self.pageBtn[i]:setVisible(2 < #g_data.select.roles)
	end

	sound.playMusic("main_theme", true)
	self.getRoleListSuccess(self)

	if g_data.login.queue then
		self.queueUp(self, g_data.login.queue.pos, g_data.login.queue.cnt, g_data.login.queue.sec)
		g_data.login:setQueueData()
	end

	local posx, posy = rolePos[1]()

	display.newNode():pos(display.cx - 200, display.height - 240):size(315, 400):anchor(0.5, 0.5):addto(layer):enableClick(function ()
		clickSelect((self.pageIdx - 1)*2 + 1)

		return 
	end)

	posx, slot10 = rolePos[2]()
	posy = slot10

	display.newNode():pos(display.cx + 208, display.height - 240):size(315, 400):anchor(0.5, 0.5):addto(layer):enableClick(function ()
		clickSelect((self.pageIdx - 1)*2 + 2)

		return 
	end)

	if g_data.login.isChangeSkinCheckServer(slot9) then
		self.setVisible(self, false)
		self.runs(self, {
			cc.DelayTime:create(0.2),
			cc.CallFunc:create(function ()
				clickBtn(1)

				return 
			end)
		})
	end

	return 
end
scene.onLoseConnect = function (self)
	print("mir2.scene.main.scene:onLoseConnect")
	scheduler.performWithDelayGlobal(function ()
		an.newMsgbox("与服务器断开连接，请稍后重试！", function ()
			common.gotoLogin()

			return 
		end, {
			center = true
		})

		return 
	end, 0)

	return 
end

if device.platform == "android" then
	scene.onNetworkStateChange = function (self, currentState)
		print("mir2.scene.main.scene:onNetworkStateChange android")
		scheduler.performWithDelayGlobal(function ()
			an.newMsgbox("与服务器断开连接，请稍后重试！", function ()
				common.gotoLogin()

				return 
			end, {
				center = true
			})

			return 
		end, 0)

		return 
	end
else
	scene.onNetworkStateChange = function (self, currentState)
		print("mir2.scene.main.scene:onNetworkStateChange ios", currentState)

		if network.isHostNameReachable("www.baidu.com") then
			scheduler.performWithDelayGlobal(function ()
				an.newMsgbox("与服务器断开连接，请稍后重试！", function ()
					common.gotoLogin()

					return 
				end, {
					center = true
				})

				return 
			end, 0)
		end

		return 
	end
end

scene.getRoleListSuccess = function (self)
	for k, v in pairs(self.roles) do
		if v.layer then
			v.layer:removeSelf()
		end
	end

	self.roles = {}

	for i = 1, 2, 1 do
		local idx = (self.pageIdx - 1)*2 + i

		if g_data.select.roles[idx] then
			self.createPlayer(self, idx, g_data.select.roles[idx])
		end
	end

	self.area:setVisible(true)

	return 
end
scene.checkTcpConnect = function (self)
	local connected = true

	if MirTcpClient:getInstance():isConnected() == false then
		connected = false

		an.newMsgbox("与服务器断开连接，请重新登录！", function ()
			common.gotoLogin()

			return 
		end, {
			center = true,
			noclose = true
		})
	end

	return connected
end
local ttimeout = 10
scene.showMask = function (self, msg, timeoutMsg)
	if self.mask then
		self.mask:removeSelf()

		self.mask = nil
	end

	if self.timeoutHandle then
		scheduler.unscheduleGlobal(self.timeoutHandle)

		self.timeoutHandle = nil
	end

	self.mask = cc.LayerColor:create(cc.c4b(0, 0, 0, 0)):addto(self):runs({
		cc.FadeTo:create(0.3, 192),
		cc.DelayTime:create(1)
	})

	if msg then
		an.newLabel(msg, 22, 2, {
			color = cc.c3b(222, 198, 60),
			sc = display.COLOR_BLACK
		}):anchor(0.5, 0.5):add2(self.mask):pos(display.width/2, display.height/3)
	end

	if timeoutMsg then
		self.timeoutHandler = scheduler.performWithDelayGlobal(function ()
			if self and self.mask then
				self:hideMask()
				an.newMsgbox(timeoutMsg, function ()
					common.gotoLogin()

					return 
				end, {
					center = true,
					noclose = true
				})
			end

			return 
		end, ttimeout)
	end

	return 
end
scene.hideMask = function (self)
	if self.mask then
		self.mask:removeSelf()

		self.mask = nil
	end

	if self.timeoutHandle then
		scheduler.unscheduleGlobal(self.timeoutHandle)

		self.timeoutHandle = nil
	end

	return 
end
scene.showCreate = function (self)
	for i, v in pairs(self.roles) do
		if v.model then
			v.model:setVisible(false)
		end
	end

	self.area:show()

	local layer = display.newNode():size(display.width, display.height):addto(self):enableClick(function ()
		return 
	end)
	local createIndex = (table.nums(g_data.select.roles)%2 == 0 and 1) or 2
	local edit_bg = res.get2("pic/common/new_role_bg.png").anchor(slot3, 0.5, 0.5):pos(editPos[({
		2,
		1
	})[createIndex]]()):addto(layer, 0):scaleY(0.85)
	local edit = display.newNode():size(300, 417):addto(layer, 1):anchor(0.5, 0.5):pos(editPos[({
		2,
		1
	})[createIndex]]())

	local function onEdit(event, editbox)
		if (event ~= "began" or false) and (event ~= "changed" or false) and (event ~= "ended" or false) and event == "return" then
			local text = editbox.getText(editbox)

			if 12 < ycFunction:getStringCount(text) then
				editbox.setText(editbox, getStrWithSize(text, 12))
			end
		end

		return 
	end

	local function addlabel(text, fontsize, color, x, y)
		an.newLabel(text, fontsize, 2, {
			color = color,
			sc = display.COLOR_BLACK
		}):anchor(0.5, 0.5):add2(edit):pos(x, y)

		return 
	end

	local offset = 20

	slot6("姓名", 20, cc.c3b(0, 112, 192), 140, offset - 357)

	local editBox1 = an.newInput(0, 0, 150, 30, 6, {
		label = {
			"",
			20,
			1
		},
		bg = {
			tex = res.gettex2("pic/common/black.png"),
			offset = {
				-10,
				2
			}
		}
	}):add2(edit):pos(145, offset - 317)
	local model, workIndex, sexIndex = nil
	local btns = {}

	addlabel("选择职业", 20, cc.c3b(0, 112, 192), 140, offset - 277)
	addlabel("性别", 20, cc.c3b(0, 112, 192), 140, offset - 178)

	local function clickBtn(idx)
		if workIndex == idx or idx - 3 == sexIndex then
			return 
		end

		if 3 < idx then
			sexIndex = idx - 3
		else
			workIndex = idx
		end

		for i = 1, 3, 1 do
			btns[i]:setIsSelect(workIndex == i)
		end

		for i = 4, 5, 1 do
			btns[i]:setIsSelect(sexIndex == i - 3)
		end

		if model then
			model:removeSelf()
		end

		if workIndex and sexIndex then
			model = role.new(workIndex, sexIndex):setState("new"):pos(rolePos[createIndex]()):addto(layer)
		end

		return 
	end

	local btn_tip = {
		"战士",
		"法师",
		"道士",
		"男",
		"女"
	}

	for i = 1, 5, 1 do
		local x = (i <= 3 and (i - 1)*75 + 60) or (i - 4)*90 + 90
		local y = (i <= 3 and offset - 242) or offset - 145

		slot6(btn_tip[i], 16, cc.c3b(255, 153, 51), x, y - 30)

		btns[i] = an.newBtn(res.getuitex(1, (i + 74) - 1), function ()
			sound.playSound("104")
			clickBtn(i)

			return 
		end, {
			pressBig = true,
			select = {
				res.getuitex(1, (i + 55) - 1),
				manual = true
			}
		}).pos(slot21, x, y):addto(edit)
	end

	clickBtn(1)
	clickBtn(4)

	local function hideCreate()
		layer:removeSelf()

		return 
	end

	local function decodeNames(filename)
		local str = res.getfile(filename)
		local names = {}

		for k, v in ipairs(string.split(str, "\n")) do
			for k, n in ipairs(string.split(v, ",")) do
				table.insert(names, n)
			end
		end

		return names
	end

	local boyName = def.nameBoy
	local girlName = def.nameGirl
	local boyNameLast = def.nameBoyLast
	local girlNameLast = def.nameGirlLast

	local function random()
		local name = nil

		if sexIndex == 1 then
			name = boyName[math.random(#boyName)] .. boyNameLast[math.random(#boyNameLast)]
		else
			name = girlName[math.random(#girlName)] .. girlNameLast[math.random(#girlNameLast)]
		end

		editBox1:setText(name)

		return 
	end

	an.newBtn(res.gettex2("pic/common/random.png"), function ()
		sound.playSound("103")
		random()

		return 
	end, {
		pressBig = true
	}).pos(slot22, 235, offset - 317):add2(edit)
	random()

	local close_btn = an.newBtn(res.getuitex(1, 64), function (event)
		sound.playSound("103")
		hideCreate()
		self:getRoleListSuccess()

		return 
	end, {
		pressShow = false,
		scale = 1.5,
		size = {
			96,
			96
		}
	}).pos(slot22, 256, 355):addto(edit):scaleY(0.8)

	an.newBtn(res.gettex2("pic/login/tab11.png"), function ()
		sound.playSound("104")

		if not self:checkTcpConnect() then
			return 
		end

		if editBox1:getText() ~= "" then
			self.newRoleName = editBox1:getText()
			local len = ycFunction:getStringCount(self.newRoleName)

			if 12 < len then
				an.newMsgbox("输入名字过长", nil, {
					center = true
				})
				editBox1:setText(getStrWithSize(self.newRoleName, 12))

				return 
			elseif len < 4 then
				an.newMsgbox("输入名字过短", nil, {
					center = true
				})

				return 
			end

			if string.find(self.newRoleName, "\n") or string.find(self.newRoleName, "\r") then
				an.newMsgbox("输入名字包含非法字符", nil, {
					center = true
				})

				return 
			end

			if not def.wordfilter.check(self.newRoleName) then
				an.newMsgbox("输入名字包含敏感字符", nil, {
					center = true
				})

				return 
			end

			local rsb = DefaultClientMessage(CM_NewChr)
			rsb.FChrInfo.FName = self.newRoleName
			rsb.FChrInfo.FHair = 1
			rsb.FChrInfo.FJob = workIndex - 1
			rsb.FChrInfo.FSex = sexIndex - 1
			g_data.select.newChrName = self.newRoleName

			if not g_data.roleCreateTest then
				MirTcpClient:getInstance():postRsb(rsb)
			end

			hideCreate()
			self:showMask("创建角色中，请耐心等待...", "服务器未响应,请检查连接是否正常,再重新登录")
		else
			an.newMsgbox("角色名未输入", nil, {
				center = true
			})
		end

		return 
	end, {
		pressImage = res.gettex2("pic/login/tab12.png")
	}).pos(slot23, 140, 60):addto(edit)

	return 
end
scene.createPlayer = function (self, idx, info)
	self.roles[idx] = {
		name = info.name,
		work = info.job + 1,
		sex = info.sex + 1,
		level = info.level
	}

	self.createInfo(self, idx, self.roles[idx])

	return 
end
scene.createInfo = function (self, idx, info)
	info.layer = display.newNode():addto(self)
	info.model = role.new(info.work, info.sex, g_data.select.selectIndex ~= idx)

	info.model:pos(rolePos[(idx - 1)%2 + 1]()):addto(info.layer)

	local x, y = namepos[(idx - 1)%2 + 1]()
	local lvlstr = common.getLevelText(info.level)

	an.newLabel(info.name, 16, 1):pos(x, y - 2):addto(info.layer)
	an.newLabel(lvlstr .. "级", 16, 1):pos(x, y - 31):addto(info.layer)
	an.newLabel(({
		"战士",
		"法师",
		"道士"
	})[info.work], 16, 1):pos(x, y - 62 + 1):addto(info.layer)

	return 
end
scene.getCurDelName = function (self)
	if self.del_selectIdx <= #self.del_roles then
		return self.del_roles[self.del_selectIdx].name
	end

	return ""
end
scene.ShowDelChrList = function (self)
	if #self.del_roles <= 0 then
		return 
	end

	local layer = display.newNode():size(display.width, display.height):addto(self):enableClick(function ()
		return 
	end)
	local del = res.getui(3, 406).pos(slot2, recoveryPos()):addTo(layer):scaleY(0.9)
	local scroll = an.newScroll(24, 70, 222, 225, {}):addTo(del)
	local cells = {}

	for k, v in ipairs(self.del_roles) do
		local cell = display.newNode():addTo(scroll):size(scroll.getw(scroll), 26):pos(0, scroll.geth(scroll) - k*25)
		cells[#cells + 1] = cell
		local labels = {
			[#labels + 1] = an.newLabel(v.name, 14, 1):addTo(cell):pos(45, cell.geth(cell)/2):anchor(0.5, 0.5),
			[#labels + 1] = an.newLabel(v.level, 14, 1):addTo(cell):pos(113, cell.geth(cell)/2):anchor(0.5, 0.5),
			[#labels + 1] = an.newLabel(getJobStr(v.job), 14, 1):addTo(cell):pos(155, cell.geth(cell)/2):anchor(0.5, 0.5),
			[#labels + 1] = an.newLabel(getSexStr(v.sex), 14, 1):addTo(cell):pos(200, cell.geth(cell)/2):anchor(0.5, 0.5)
		}
		cell.setColor = function (self, color)
			for k, v in ipairs(labels) do
				v.setColor(v, color)
			end

			return 
		end

		cell.enableClick(slot10, function ()
			if self.del_selectIdx then
				cells[self.del_selectIdx]:setColor(display.COLOR_WHITE)
			end

			self.del_selectIdx = k

			cell:setColor(display.COLOR_RED)

			return 
		end, {
			support = "scroll"
		})
	end

	local function hideDel()
		layer:removeSelf()

		return 
	end

	an.newBtn(res.getuitex(1, 64), function (event)
		sound.playSound("103")
		hideDel()

		return 
	end, {
		pressShow = true,
		size = {
			48,
			48
		}
	}).pos(slot6, 256, 375):addto(del)
	an.newBtn(res.getuitex(3, 407), function ()
		if self.del_selectIdx then
			sound.playSound("104")

			if not IS_PLAYER_DEBUG and roleUpperLimit <= #g_data.select.roles then
				an.newMsgbox("您的角色已满" .. roleUpperLimit .. "个", nil, {
					center = true
				})

				return 
			end

			local rsb = DefaultClientMessage(CM_RecoverChr)
			rsb.FName = self:getCurDelName()

			MirTcpClient:getInstance():postRsb(rsb)
			hideDel()
		end

		return 
	end, {
		pressImage = res.getuitex(3, 408)
	}).pos(slot6, 140, 35):addto(del)

	return 
end
scene.reconectFuc = function (self, info)
	if self.reconnectBox then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	if not self.reconnectBox then
		self.reconnectBox = an.newMsgbox(info, function (idx)
			common.gotoLogin({
				logout = true
			})

			self.reconnectBox = nil

			return 
		end, {
			center = true
		})
	end

	return 
end
scene.onLoseConnect = function (self)
	if self.reconnectBox then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	print("scene:onLoseConnect")

	self.reconnectBox = self.reconectFuc(self, "网络连接已断开!")

	return 
end
scene.onNetworkStateChange = function (self, currentState)
	local connectable = network.isHostNameReachable("www.baidu.com")

	if not tolua.isnull(self.reconnectBox) then
		if connectable then
			self.reconnectBox:removeSelf()

			self.reconnectBox = nil
		else
			return 
		end
	end

	if connectable then
		self.reconectFuc(self, "切换到 " .. ((currentState == cc.kCCNetworkStatusReachableViaWiFi and "WIFI网络") or "蜂窝网络"))
	end

	return 
end
scene.queueUp = function (self, pos, cnt, sec)
	if pos == 0 then
		if self.layer then
			self.layer:removeSelf()

			self.layer = nil
		end

		return 
	end

	if not self.layer then
		self.layer = display.newNode():addTo(self):size(display.width, display.height):setTouchEnabled(true)

		self.layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function ()
			return 
		end)
	end

	local layer = self.layer
	local posStr = "您排在第" .. slot1 .. "位"

	if sec == 0 then
		slot6 = "正在估算..."
	else
		local waitStr = "预计等待" .. ((60 < sec and math.ceil(sec/60) .. "分钟") or sec .. "秒")
	end

	if not layer.queueUpTip then
		local bg = res.get2("pic/common/msgbox.png"):addTo(layer):pos(display.cx, display.cy)

		bg.setTouchEnabled(bg, true)
		bg.addNodeEventListener(bg, cc.NODE_TOUCH_EVENT, function ()
			return 
		end)
		res.get2("pic/login/queue.png").addTo(slot8, bg):pos(bg.getw(bg)/2, bg.geth(bg) - 6):anchor(0.5, 1)

		local function cancel()
			return 
		end

		an.newBtn(res.gettex2("pic/common/close10.png"), slot8, {
			pressImage = res.gettex2("pic/common/close11.png")
		}):addTo(bg):pos(bg.getw(bg) - 8, bg.geth(bg) - 5):anchor(1, 1)
		an.newBtn(res.gettex2("pic/common/btn20.png"), cancel, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/common/cancel.png")
		}):addTo(bg):pos(bg.getw(bg)/2, 30):anchor(0.5, 0.5)
		an.newLabel("服务器爆满需要排队", 20, 1):addTo(bg):pos(bg.getw(bg)/2, 190):anchor(0.5, 0.5)

		bg.pos = an.newLabel(posStr, 20, 1):addTo(bg):pos(bg.getw(bg)/2, 150):anchor(0.5, 0.5)
		bg.wait = an.newLabel(waitStr, 20, 1):addTo(bg):pos(bg.getw(bg)/2, 110):anchor(0.5, 0.5)
		layer.queueUpTip = bg
	else
		layer.queueUpTip.pos:setText(posStr)
		layer.queueUpTip.wait:setText(waitStr)
	end

	return 
end
scene.socketEvent = function (self, data, status)
	if status == 3 then
		if self.returnBtn then
			return 
		end

		self.reconectFuc(self, (self.reconnect and "连接超时中断，重连失败") or "与服务器断开连接")
	elseif status == 2 then
		self.reconectFuc(self, "连接服务器失败，请检查网络并稍后再试")
	end

	return 
end

return scene
