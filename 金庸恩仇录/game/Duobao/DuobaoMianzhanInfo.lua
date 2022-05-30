local DuobaoMianzhanInfo = class("DuobaoMianzhanInfo", function()
	return require("utility.ShadeLayer").new()
end)

function DuobaoMianzhanInfo:mianzhanFunc(useCoins)
	if useCoins and self._gold < 20 then
		show_tip_label(common:getLanguageString("@PriceEnough"))
		self._rootnode.coinBtn:setEnabled(true)
		return
	elseif not useCoins and self._warFreeCnt <= 0 then
		show_tip_label(common:getLanguageString("@PropNumberEnough"))
		self._rootnode.mianzhanBtn:setEnabled(true)
		return
	end
	local t = "1"
	if useCoins then
		t = "2"
	end
	RequestHelper.Duobao.useMianzhan({
	t = t,
	callback = function(data)
		dump(data)
		if useCoins then
			self._rootnode.coinBtn:setEnabled(true)
		else
			self._rootnode.mianzhanBtn:setEnabled(true)
		end
		if string.len(data["0"]) > 0 then
			show_tip_label(data["0"])
		else
			local isAwoidTime = data["4"]
			if isAwoidTime == 1 then
				show_tip_label(common:getLanguageString("@NoFightTime"))
			else
				show_tip_label(common:getLanguageString("@SuccessFourNoFight"))
				game.player:updateMainMenu({
				gold = data["3"]
				})
				self._gold = data["3"]
				if not useCoins then
					self._warFreeCnt = self._warFreeCnt - 1
				end
				local warFreeTime = data["2"]
				self._callback(warFreeTime, self._gold, self._warFreeCnt)
				self:closeFunc()
			end
		end
	end
	})
end

function DuobaoMianzhanInfo:closeFunc()
	if self._closeFunc ~= nil then
		self._closeFunc()
	end
	self:removeSelf()
end

function DuobaoMianzhanInfo:ctor(param)
	self._warFreeCnt = param.warFreeCnt or 0
	self._gold = param.gold or 0
	self._callback = param.callback
	self._closeFunc = param.closeFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("duobao/duobao_mianzhan_bg.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.titleLabel:setString(common:getLanguageString("@NoFight"))
	self._rootnode.numLbl:setString(tostring(self._warFreeCnt))
	self._rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	local mianzhanBtn = self._rootnode.mianzhanBtn
	mianzhanBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		mianzhanBtn:setEnabled(false)
		self:mianzhanFunc(false)
	end,
	CCControlEventTouchUpInside)
	
	local coinBtn = self._rootnode.coinBtn
	coinBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		coinBtn:setEnabled(false)
		self:mianzhanFunc(true)
	end,
	CCControlEventTouchUpInside)
	
	alignNodesOneByAllCenterX(self._rootnode.duobao_label_1:getParent(), {
	self._rootnode.duobao_label_1,
	self._rootnode.duobao_label_2,
	self._rootnode.duobao_label_3,
	self._rootnode.duobao_label_4,
	self._rootnode.duobao_label_5
	})
end

return DuobaoMianzhanInfo