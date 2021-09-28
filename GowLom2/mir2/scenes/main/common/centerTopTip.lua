local tip = class("centerTopTip", function ()
	return display.newNode()
end)

table.merge(slot0, {
	configs,
	curNode
})

tip.ctor = function (self)
	self.configs = {
		resumePos = {
			"是不是卡位了？",
			"恢复原位",
			def.cmds.custom.卡位恢复
		},
		relive = {
			"是否立即复活？",
			"回城复活",
			def.cmds.custom.回城复活
		}
	}
	self.curNode = nil

	return 
end
tip.show = function (self, type)
	local config = self.configs[type]

	if not config then
		return 
	end

	if self.curNode then
		self.curNode:removeSelf()

		self.curNode = nil
	end

	local ntime = 1650
	local reliveBtn = an.newBtn(res.gettex2("pic/common/relive0.png"), function ()
		sound.playSound("103")

		if 1590 < ntime then
			if MirTcpClient:getInstance():isConnected() == false then
				reConnectLogic:manualConnect()

				return 
			end

			local rsb = DefaultClientMessage(CM_Relive)

			MirTcpClient:getInstance():postRsb(rsb)
		elseif 90 < ntime and ntime <= 1590 then
			reConnectLogic:manualConnect()
		elseif 0 <= ntime and ntime <= 90 then
			main_scene:bigExit()

			return 
		end

		main_scene.ui.waiting:show(10, "RELIVE_CALLBACK")

		return 
	end, {
		pressImage = res.gettex2("pic/common/relive1.png")
	}).anchor(slot4, 0, 0)
	self.curNode = display.newNode():add(reliveBtn):size(reliveBtn.getw(reliveBtn), reliveBtn.geth(reliveBtn)):anchor(0.5, 0.5):opacity(0):add2(self)
	local timeLabel = nil
	slot6 = an.newLabel("60秒内点击复活按钮进行复活", 20, 1, {
		color = def.colors.labelYellow
	}):anchor(0.5, 0.5):pos(self.curNode:getw()*0.5, -10):opacity(255):add2(self.curNode):run(cc.RepeatForever:create(transition.sequence({
		cc.DelayTime:create(5),
		cc.CallFunc:create(function ()
			ntime = ntime - 5

			if ntime <= 0 then
				self.curNode:removeSelf()

				self.curNode = nil
			elseif 90 < ntime and ntime <= 1590 then
				an.newLabel("与服务器断开连接", 20, 1, {
					color = def.colors.labelYellow
				}):anchor(0.5, 0.5):pos(self.curNode:getw()*0.5, -10):opacity(255):add2(self.curNode)
				timeLabel:pos(self.curNode:getw()*0.5, -35):setString(tostring(ntime - 90) .. "秒内点击复活按钮进行重连")
			elseif 0 <= ntime and ntime <= 90 then
				timeLabel:setString("点击复活按钮重新登陆")
			elseif 1590 < ntime then
				timeLabel:setString(tostring(ntime - 1590) .. "秒内点击复活按钮进行复活")
			end

			return 
		end)
	})))
	timeLabel = slot6

	self.curNode:pos(display.cx, display.height - 120)
	self.curNode:moveTo(0.3, display.cx, display.height - 80)

	return 
end
tip.hide = function (self)
	main_scene.ui.waiting:close("RELIVE_CALLBACK")

	if self.curNode then
		self.curNode:removeSelf()

		self.curNode = nil
	end

	return 
end

return tip
