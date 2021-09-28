local chkRechargePanel = class("chkRechargePanel", function ()
	return display.newNode()
end)

table.merge(slot0, {})

local respath = g_data.login:getChkResPath()
local configpath = g_data.login:getChkConfigPath()
local jsonData = nil
local btnpos = {}
chkRechargePanel.convertCfg2Pos = function (self, data)
	local x = 0
	local y = 0

	if data.y == nil or data.y == nil or data.orix == nil or data.oriy == nil then
		print("config invalid!")
		print_r(data)
	else
		x = data.x + self.getw(self)/2*data.orix
		y = data.y + self.geth(self)/2*data.oriy
	end

	return x, y
end
chkRechargePanel.ctor = function (self)
	self._supportMove = true
	self.bg = display.newNode():addto(self, 20)
	jsonData = parseJson(configpath .. "ui_chkshop.json")
	btnpos = {}

	for _, v in ipairs(jsonData) do
		btnpos[v.key] = v
	end

	local bgName = "shopbg"
	local newbg = res.get2(respath .. bgName .. ".png"):anchor(0, 0):addto(self)

	self.size(self, cc.size(newbg.getContentSize(newbg).width, newbg.getContentSize(newbg).height))
	self.setPosition(self, display.cx - self.getw(self)/2, display.cy - self.geth(self)/2)

	local moneyData = btnpos.money
	local moneyText = moneyData.moneyName .. ": " .. g_data.player:getIngotShow()
	local lblX, lblY = self.convertCfg2Pos(self, moneyData)
	moneyNumLbl = an.newLabel(moneyText, 22, 0, {
		color = def.colors.Cd2b19c
	}):anchor(0, 0.5):pos(lblX, lblY):addto(newbg)

	print_r(btnpos)

	local data = btnpos.close
	local x, y = self.convertCfg2Pos(self, data)

	an.newBtn(res.gettex2(respath .. "close.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2(respath .. "close.png"),
		size = cc.size(64, 64)
	}).anchor(slot10, 1, 1):pos(x, y):addto(self, 20)

	local testList = {
		{
			FDescription = "额外赠送5%银锭",
			FBoMark = false,
			FName = "6元宝(每天限一次)",
			FPrice = "6",
			FSellPrice = "1.0",
			FProductId = "com.sjfgcq.sdwl.RMB6"
		},
		{
			FDescription = "额外赠送5%银锭",
			FBoMark = false,
			FName = "50元宝",
			FPrice = "50",
			FSellPrice = "1.0",
			FProductId = "com.sjfgcq.sdwl.RMB50"
		},
		{
			FDescription = "额外赠送5%银锭",
			FBoMark = false,
			FName = "98元宝",
			FPrice = "98",
			FSellPrice = "1.0",
			FProductId = "com.sjfgcq.sdwl.RMB98"
		},
		{
			FDescription = "额外赠送5%银锭",
			FBoMark = false,
			FName = "198元宝(每天限一次)",
			FPrice = "198",
			FSellPrice = "1.0",
			FProductId = "com.sjfgcq.sdwl.RMB198"
		},
		{
			FDescription = "额外赠送5%银锭",
			FBoMark = false,
			FName = "328元宝",
			FPrice = "328",
			FSellPrice = "1.0",
			FProductId = "com.sjfgcq.sdwl.RMB328"
		},
		{
			FDescription = "额外赠送5%银锭",
			FBoMark = false,
			FName = "512元宝",
			FPrice = "512",
			FSellPrice = "1.0",
			FProductId = "com.sjfgcq.sdwl.RMB512"
		}
	}
	local chargeList = g_data.chargeList

	if (chargeList == nil or #chargeList == 0) and device.platform == "windows" then
		chargeList = testList
	end

	local chargeItemNum = btnpos.chargeItemNum.num

	for i, v in ipairs(chargeList) do
		if chargeItemNum < i then
			break
		end

		local btnKey = "btn" .. i
		local btnData = btnpos[btnKey]
		local x, y = self.convertCfg2Pos(self, btnData)
		local imgKey = btnData.btnImg or "btnCharge.png"
		local btnImg = respath .. imgKey
		local chargeName = "￥ " .. v.FPrice
		local textSize = moneyData.moneyNameSize or 20

		an.newBtn(res.gettex2(btnImg), function (clickBtn)
			sound.playSound("103")
			main_scene.ui.waiting:show(35, "SHOPPAY", 1)

			self.lastClickPayIndex = clickBtn.getTag(clickBtn)
			local curChargeInfo = chargeList[clickBtn.getTag(clickBtn)]
			local rsb = DefaultClientMessage(CM_NewOrder)
			rsb.FProductId = curChargeInfo.FProductId
			rsb.FPlatType = 0
			rsb.FExtendData = self.lastClickPayIndex
			rsb.FChannelUserId = MirSDKAgent:getUserID() or ""

			if (device.platform == "ios" or device.platform == "android") and not FORCE_ACCOUNT_LOGIN then
				if device.platform == "ios" then
					rsb.FPlatType = 1
				elseif device.platform == "android" then
					rsb.FPlatType = 0
				end
			else
				an.newMsgbox("该版本暂不支持充值" .. curChargeInfo.FPrice .. "，想花钱敬请期待......", nil, {
					btnTexts = {
						"确  定",
						"取  消"
					}
				})
			end

			MirTcpClient:getInstance():postRsb(rsb)

			return 
		end, {
			pressBig = true,
			pressImage = res.gettex2(slot23),
			label = {
				chargeName,
				textSize,
				0,
				{
					color = def.colors.Cf0c896
				}
			}
		}):add2(newbg):anchor(0.5, 0.5):pos(x, y):setTag(i)
	end

	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_NewOrder, self, self.onSM_NewOrder)
	g_data.eventDispatcher:addListener("MONEY_UPDATE", self, self.uptMoneyNum)

	return 
end
local err_msg = {
	[1.0] = "角色账号错误"
}
chkRechargePanel.onSM_NewOrder = function (self, result, proIc)
	local curChargeInfo, errLog = nil

	print("shop:onSM_NewOrder")
	print_r(result)

	while true do
		if not result then
			errLog = "not result"

			break
		end

		if result.Flag ~= 0 then
			errLog = "flag not 0"

			break
		end

		local errcode = result.FErr

		if errcode and errcode ~= 0 then
			errLog = err_msg[errcode] or tostring(result.FErr)

			break
		end

		if not result.FOrderId or result.FOrderId == "" then
			errLog = "result.FOrderId is empty"

			break
		end

		local curPayIndex = self.lastClickPayIndex

		if result.FProductId and result.FProductId ~= "" then
			curPayIndex = result.FExtendData
			curChargeInfo = g_data.chargeList[curPayIndex]

			if curChargeInfo.FProductId ~= result.FProductId then
				curChargeInfo = nil
				errLog = "curChargeInfo.FProductId ~= result.FProductId"

				break
			end
		else
			curChargeInfo = g_data.chargeList[curPayIndex]
		end

		if not curChargeInfo then
			errLog = "not charge info"

			break
		end

		local pruductInfo = {
			coinName = "元宝",
			productDesc = "",
			orderId = tostring(result.FOrderId),
			productID = tostring(curChargeInfo.FProductId),
			productName = tostring(curChargeInfo.FName),
			productPrice = tostring(curChargeInfo.FPrice),
			productAmount = tostring(1),
			roleId = tostring(g_data.select:getCurUserId()),
			roleName = tostring(g_data.select:getCurName()),
			roleLevel = tostring(g_data.select:getCurLevel()),
			serverId = tostring(g_data.login.zoneId),
			serverName = tostring(g_data.login.zoneId),
			ext = tostring(curChargeInfo.FProductId)
		}

		dump(pruductInfo)
		MirSDKAgent:payForProduct(pruductInfo, function (code, msg)
			release_print("===>payForProduct callback code", code, msg)

			if code == 0 then
			end

			return 
		end)

		break
	end

	main_scene.ui.waiting.close(slot5, "SHOPPAY")

	if curChargeInfo == nil and result.FOrderId and result.FOrderId ~= "" and (device.platform == "ios" or device.platform == "android") and not FORCE_ACCOUNT_LOGIN then
		an.newMsgbox("支付异常，请确认网络正常后重试！", nil, {
			btnTexts = {
				"确  定",
				"取  消"
			}
		})
	end

	return 
end
chkRechargePanel.uptMoneyNum = function (self)
	if self.moneyNumLbl then
		local moneyData = btnpos.money
		local moneyText = moneyData.moneyName .. ": " .. g_data.player:getIngotShow()

		self.moneyNumLbl:setString(moneyText)
	end

	return 
end

return chkRechargePanel
