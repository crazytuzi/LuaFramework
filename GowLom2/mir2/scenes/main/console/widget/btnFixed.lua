local btnFixed = class("btnFixed", function ()
	return display.newNode()
end)

table.merge(slot0, {
	data,
	config,
	modeChooseNode,
	curModeChooseIsShow
})

btnFixed.ctor = function (self, config, data)
	local bg = "pic/console/fixedBtn/btnbg10.png"
	local bg2 = "pic/console/fixedBtn/btnbg11.png"
	local text, text_offset = nil

	if config.key == "btnMap" then
		text = "pic/console/fixedBtn/text_map.png"
		text_offset = cc.p(-3, 0)
	elseif config.key == "btnExit" then
		text = "pic/console/fixedBtn/text_exit.png"
		text_offset = cc.p(-3, 0)
	elseif config.key == "btnMode" then
		text = "pic/console/modes/quanti.png"
		text_offset = cc.p(-3, 0)
	elseif config.key == "btnTask" then
		text = "pic/console/fixedBtn/text_task.png"
		text_offset = cc.p(-3, 0)
	elseif config.key == "btnDiy" then
		text = "pic/console/fixedBtn/text_diy.png"
		text_offset = cc.p(-3, 0)
	end

	self.btn = an.newBtn(res.gettex2(bg), handler(self, self.click), {
		pressImage = res.gettex2(bg2),
		sprite = res.gettex2(text),
		spriteOffset = text_offset
	}):anchor(0, 0):add2(self)
	self.data = data
	self.config = config

	self.size(self, self.btn:getContentSize()):anchor(0.5, 0.5):pos(data.x, data.y)
	self.upt(self)

	return 
end
btnFixed.click = function (self)
	sound.playSound("103")

	if self.config.key == "btnExit" then
		if g_data.player:getIsCrossServer() then
			main_scene.ui:tip("跨服中不可小退")

			return 
		end

		if g_data.setting.base.quickexit then
			main_scene:smallExit()
		else
			an.newMsgbox("是否确定退出?", function (isOk)
				if isOk == 1 then
					main_scene:smallExit()
				end

				return 
			end, {
				center = true,
				hasCancel = true
			})
		end
	elseif self.config.key == "btnMap" then
		if main_scene.ui.panels.minimap then
			main_scene.ui.hidePanel(slot1, "minimap")
		else
			main_scene.ui:showPanel("minimap")
		end
	elseif self.config.key == "btnMode" then
		self.showModeSelect(self, not self.curModeChooseIsShow)
	elseif self.config.key == "btnTask" then
		if main_scene.ui.panels.task then
			main_scene.ui:hidePanel("task")
		else
			main_scene.ui:showPanel("task")
		end
	elseif self.config.key == "btnDiy" then
		main_scene.ui:togglePanel("diy")
	end

	return 
end
btnFixed.showModeSelect = function (self, b)
	if self.curModeChooseIsShow == b then
		return 
	end

	self.curModeChooseIsShow = b
	local space = 40

	if not self.modeChooseNode then
		local texts = {
			{
				"quanti",
				"全体"
			},
			{
				"heping",
				"和平"
			},
			{
				"bianzu",
				"编组"
			},
			{
				"hanghui",
				"行会"
			},
			{
				"didui",
				"敌对"
			}
		}
		self.modeChooseNode = res.get2("pic/console/modesBg.png"):anchor(1, 0):pos(self.data.x - self.getw(self)/2 + 2, self.data.y - self.geth(self)/2):add2(main_scene.ui.console, self.getLocalZOrder(self))

		for i, v in ipairs(texts) do
			res.get2("pic/console/modes/" .. v[1] .. ".png"):pos((i - 1)*space + space/2, self.modeChooseNode:geth()/2):add2(self.modeChooseNode, 9):enableClick(function ()
				local rsb = DefaultClientMessage(CM_ATTACKMODE)
				rsb.AttackMode = i - 1

				MirTcpClient:getInstance():postRsb(rsb)
				self:showModeSelect()

				return 
			end, {
				size = cc.size(slot2, self.modeChooseNode:geth())
			})
		end
	end

	self.modeChooseNode:stopAllActions()
	self.stopAllActions(self)

	if b then
		if game.deviceFix then
			self.modeChooseNode:show()
		end

		self.modeChooseNode:runs({
			cc.MoveTo:create(0.1, cc.p(self.data.x - self.getw(self)/2 + 2 + self.modeChooseNode:getw() + 20, self.modeChooseNode:getPositionY())),
			cc.MoveTo:create(0.1, cc.p(self.data.x - self.getw(self)/2 + 2 + self.modeChooseNode:getw(), self.modeChooseNode:getPositionY()))
		})
		self.runs(self, {
			cc.MoveTo:create(0.1, cc.p(self.data.x + self.modeChooseNode:getw() + 20, self.getPositionY(self))),
			cc.MoveTo:create(0.1, cc.p(self.data.x + self.modeChooseNode:getw(), self.getPositionY(self)))
		})
	else
		if game.deviceFix then
			self.modeChooseNode:hide()
		end

		self.modeChooseNode:runs({
			cc.MoveTo:create(0.1, cc.p((self.data.x - self.getw(self)/2 + 2) - 20, self.modeChooseNode:getPositionY())),
			cc.MoveTo:create(0.1, cc.p(self.data.x - self.getw(self)/2 + 2, self.modeChooseNode:getPositionY()))
		})
		self.runs(self, {
			cc.MoveTo:create(0.1, cc.p(self.data.x - 20, self.getPositionY(self))),
			cc.MoveTo:create(0.1, cc.p(self.data.x, self.getPositionY(self)))
		})
	end

	return 
end
btnFixed.mode2filename = function (self, mode)
	local names = {
		全体 = "quanti",
		敌对 = "didui",
		和平 = "heping",
		编组 = "bianzu",
		行会 = "hanghui"
	}
	local filename = nil

	for k, v in pairs(names) do
		if string.find(mode, k) then
			filename = v

			break
		end
	end

	return filename or "heping"
end
btnFixed.upt = function (self)
	if self.config.key == "btnMode" then
		self.btn.sprite:setTex(res.gettex2("pic/console/modes/" .. self.mode2filename(self, g_data.player.attackMode) .. ".png"))
	end

	return 
end
btnFixed.update = function (self, dt)
	if self.config.key == "btnExit" then
		if main_scene.ui.panels.minimap then
			self.pos(self, self.data.x, self.data.y - 50)
		else
			self.pos(self, self.data.x, self.data.y)
		end
	elseif self.config.key == "btnMap" then
		if main_scene.ui.panels.minimap then
			if g_data.login:isChangeSkinCheckServer() then
				main_scene.ui:hidePanel("minimap")
			else
				self.pos(self, self.data.x - main_scene.ui.panels.minimap:getw(), self.data.y)
			end
		else
			self.pos(self, self.data.x, self.data.y)
		end
	end

	return 
end

return btnFixed
