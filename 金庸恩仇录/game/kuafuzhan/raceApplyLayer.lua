local raceApplyLayer = class("raceApplyLayer", function()
	return display.newLayer("raceApplyLayer")
end)

local kuafuMsg = {
applyInfo = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossApply",
	type = param.type
	}
	RequestHelper.request(msg, _callback, param.errback)
end
}

function raceApplyLayer:ctor(param)
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	self:setContentSize(param.size)
	local bgNode = CCBuilderReaderLoad("kuafu/retrospection_layer.ccbi", self._proxy, self._rootnode, self, param.size)
	self:addChild(bgNode)
	self._parent = param.parent
	self.hasSignUp = true
	for index = 1, 3 do
		self._rootnode["info_node_top" .. index]:setVisible(false)
	end
	self._rootnode.left_title_btn:setEnabled(false)
	self._rootnode.right_title_btn:setEnabled(false)
	self._rootnode.Apply:setVisible(false)
	local phaseIndex = KuafuModel.getShowPhaseLanginfo(KuafuModel.getKuafuPhase())
	self._rootnode.kuafu_title:setString(common:getLanguageString("KuafuTitle", phaseIndex))
	
	self._rootnode.Apply:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if KuafuModel.checkCurretntStep(enumKuafuState.apply, true) then
			if self.hasSignUp then
				KuafuModel.showFormLayer()
			else
				self:showApplyInfo()
			end
		end
	end,
	CCControlEventTouchUpInside)
end

function raceApplyLayer:showApplyInfo()
	local param = {
	showType = 1,
	leftBtnFunc = function()
		KuafuModel.showFormLayer()
	end,
	rightBtnFunc = function()
		kuafuMsg.applyInfo({
		type = 1,
		callback = function(data)
			if data.sign then
				show_tip_label(common:getLanguageString("@baoming") .. common:getLanguageString("@SuccessLabel"))
			else
				show_tip_label(common:getLanguageString("@baoming") .. common:getLanguageString("@FailedLabel"))
			end
			self:setApplyBtn(data.sign)
			KuafuModel.setKuafuSignUp(data.sign)
		end
		})
	end
	}
	local layer = require("game.kuafuzhan.applyMsgBox").new(param)
	self._parent:addChild(layer, 100)
end

function raceApplyLayer:setApplyBtn(signUp)
	self.hasSignUp = signUp
	local name = self.hasSignUp and common:getLanguageString("@PlayRotation") or common:getLanguageString("@baoming")
	self._rootnode.Apply:setVisible(true)
	resetctrbtnString(self._rootnode.Apply, name)
end

function raceApplyLayer:initData()
	kuafuMsg.applyInfo({
	type = 0,
	callback = function(data)
		KuafuModel.setKuafuSignUp(data.sign)
		self:setApplyBtn(data.sign)
	end
	})
end

function raceApplyLayer:onExit()
end

function raceApplyLayer:onEnter()
end

return raceApplyLayer