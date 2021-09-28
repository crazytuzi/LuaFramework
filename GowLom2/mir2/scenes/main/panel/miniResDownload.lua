local miniResDownload = class("miniResDownload", function ()
	return display.newNode()
end)

table.merge(slot0, {})

miniResDownload.ctor = function (self)
	self._supportMove = true
	local bg = res.get2("pic/common/black_2.png"):anchor(0, 0):addto(self)

	self.size(self, bg.getContentSize(bg)):anchor(0.5, 0.5):pos(display.cx, display.cy)
	self.setNodeEventEnabled(self, true)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).addTo(slot2, bg):pos(bg.getw(bg) - 9, bg.geth(bg) - 9):anchor(1, 1)
	self.showDownloadMiniPage(self)

	return 
end
miniResDownload.onCleanup = function (self)
	slot1 = MirMiniResDownMgr and slot1
	slot1 = self.downPercent and slot1

	return 
end
miniResDownload.showDownloadMiniPage = function (self)
	if self.nodeActItem then
		self.nodeActItem:removeSelf()
	end

	self.nodeActItem = display.newNode():addTo(self, 20)

	if not self.downPercent then
		local isFull = MirMiniResDownMgr:getInstance():isFullPackage()
		self.downPercent = cache.getDebug("downloadPercent") or (isFull and "100.00") or "0.0"
	else
		self.downPercent = cache.getDebug("downloadPercent") or (MirMiniResDownMgr:getInstance():isFullPackage() and "100.00") or "0.0"
	end

	self.processBar = display.newScale9Sprite(res.getframe2("pic/voice/voiceBtn.png"), 177, 146, cc.size(312, 25)):anchor(0, 0.5):addTo(self.nodeActItem)

	self.processBar:setScaleX(tonumber(self.downPercent)/100)

	self.downPercentLbl = an.newLabel(self.downPercent .. "%", 20, 0, {
		color = def.colors.Cdcd2be
	}):anchor(0, 0.5):add2(self.nodeActItem):pos(420, 180)
	self.downTips = an.newLabel("下载中...", 16, 0, {
		color = def.colors.labelYellow
	}):anchor(0.5, 0.5):add2(self.nodeActItem):pos(552, 176)

	self.downTips:setVisible(false)

	local dwonText = "点击下载"

	if self.downPercent == "100.00" then
		dwonText = "已完成"
	end

	self.downState = false
	self.downBtn = an.newBtn(res.gettex2("pic/panels/guild/btn.png"), function ()
		if self.downPercent == "100.00" then
			main_scene.ui:tip("下载已完成")

			return 
		end

		sound.playSound("103")

		if device.platform ~= "windows" and network.getInternetConnectionStatus() ~= cc.kCCNetworkStatusReachableViaWiFi then
			main_scene.ui:tip("下载失败，必须wifi环境才可下载")

			return 
		end

		self.downState = not self.downState

		if not self.downState then
			self.downBtn.label:setText("点击下载")
			self.downTips:setVisible(false)
			MirMiniResDownMgr:getInstance():reset()
		else
			self.downTips:setVisible(true)
			self.downBtn.label:setText("暂停")
			MirMiniResDownMgr:getInstance():reset()
			MirMiniResDownMgr:getInstance():downloadRes(main_scene, main_scene.downloadMiniResEnd)
		end

		return 
	end, {
		pressImage = res.gettex2("pic/panels/guild/btnh.png"),
		label = {
			dwonText,
			18,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot2, self.nodeActItem):anchor(0.5, 0.5):pos(556, 144)

	an.newLabel("请在连接WIFI的情况下下载", 20, 0, {
		color = def.colors.labelYellow
	}):anchor(0.5, 0.5):add2(self.nodeActItem):pos(294, 180)
	an.newLabel("关闭界面将继续下载", 16, 0, {
		color = def.colors.labelYellow
	}):anchor(0.5, 0.5):add2(self.nodeActItem):pos(418, 120)

	return 
end
miniResDownload.downloadMiniResEnd = function (self, percent)
	if not self.processBar then
		return 
	end

	if not self.downState then
		self.downTips:setVisible(true)
		self.downBtn.label:setText("暂停")

		self.downState = true
	end

	self.downPercent = string.format("%.2f", percent)

	self.processBar:setScaleX(tonumber(self.downPercent/100))
	self.downPercentLbl:setText(self.downPercent .. "%")

	if self.downPercent == "100.00" then
		self.downBtn.label:setText("已完成")
		self.downTips:setVisible(false)
	end

	return 
end

return miniResDownload
