local common = import("..common.common")
local screenshotShare = class("screenshotShare", function ()
	return display.newNode()
end)

table.merge(slot1, {})

screenshotShare.ctor = function (self)
	self._supportMove = false

	self.setNodeEventEnabled(self, true)
	sound.playSound("screen")
	self.showContent(self)

	return 
end
screenshotShare.showContent = function (self)
	local contentbg = res.get2("public/shareContent.png"):add2(self):pos(display.cx, display.cy):anchor(0.5, 0.5)

	self.size(self, display.width, display.height):anchor(0.5, 0.5):center()

	local shareBg = res.get2("pic/panels/activity/share/shareBtnBg.png"):add2(contentbg):pos(contentbg.getw(contentbg)/2, 0):anchor(0.5, 0)

	an.newLabel("点击右侧图标进行存储或分享！", 28, 0, {
		color = def.colors.Cffffff
	}):anchor(0, 0.5):pos(180, shareBg.geth(shareBg)/2 - 20):add2(shareBg)
	an.newBtn(res.gettex2("pic/panels/activity/share/closeShare.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/panels/activity/share/closeShare.png")
	}).anchor(slot3, 0.5, 0.5):pos(shareBg.getw(shareBg) - 50, shareBg.geth(shareBg) - 45):addto(shareBg)

	local shareBtns = {}

	if device.platform == "ios" then
		shareBtns = {
			{
				id = 21,
				icon = "sns_icon_21.png"
			}
		}
	else
		shareBtns = {
			{
				id = 22,
				icon = "sns_icon_22.png"
			},
			{
				id = 23,
				icon = "sns_icon_23.png"
			},
			{
				id = 24,
				icon = "sns_icon_24.png"
			}
		}
	end

	for k, v in ipairs(shareBtns) do
		local shareBtn = an.newBtn(res.gettex2("pic/panels/activity/share/" .. v.icon), function (btn)
			sound.playSound("103")

			local btnId = btn.id
			local file = cc.FileUtils:getInstance():fullPathForFilename("public/shareContent.png")

			if device.platform == "ios" and btnId == 21 then
				local devInstance = MirDevices and MirDevices:getInstance()

				if devInstance and devInstance.savePhotoAlbum ~= nil then
					devInstance.savePhotoAlbum(devInstance, file)
					main_scene.ui:tip("图片已存入相册，可用QQ或微信等分享", 6)
				end
			else
				local platform = tostring(btnId)

				MirSDKAgent:shareImage(platform, "", "", file, "")
			end

			local rsb = DefaultClientMessage(CM_Share)
			rsb.FRet = 1
			rsb.FExt = ""

			MirTcpClient:getInstance():postRsb(rsb)

			if self.hidePanel then
				self:hidePanel()
			end

			return 
		end, {
			pressImage = res.gettex2("pic/panels/activity/share/" .. v.icon)
		}).anchor(slot9, 0.5, 0.5):pos(k*110 + 525, shareBg.geth(shareBg)/2 - 22):addto(shareBg)
		shareBtn.id = v.id
	end

	return 
end

return screenshotShare
