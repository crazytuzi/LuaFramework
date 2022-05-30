local raceCourseLayer = class("raceCourseLayer", function()
	return display.newLayer("raceCourseLayer")
end)

local msg = {
getReportSize = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossReportSize"
	}
	RequestHelper.request(msg, _callback, param.errback)
end
}

function raceCourseLayer:ctor(param)
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	self:setContentSize(param.size)
	local bgNode = CCBuilderReaderLoad("kuafu/final_schedule_layer.ccbi", self._proxy, self._rootnode, self, param.size)
	self:addChild(bgNode)
	self._parent = param.parent
	local phaseIndex = KuafuModel.getShowPhaseLanginfo(KuafuModel.getKuafuPhase())
	self._rootnode.kuafu_title:setString(common:getLanguageString("KuafuTitle", phaseIndex))
	
	--调整阵容
	self._rootnode.setting_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self._rootnode.setting_btn:setEnabled(false)
		KuafuModel.getKuafuSignUp(function(signUp)
			self._rootnode.setting_btn:setEnabled(true)
			if signUp then
				self:settingBtnFunc()
			else
				show_tip_label(common:getLanguageString("@kuafuNotHaveRace"))
			end
		end)
	end,
	CCControlEventTouchUpInside)
	
	--赛事查看
	self._rootnode.race_consult_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local curState = KuafuModel.getKuafuState()
		if curState <= enumKuafuState.apply then
			show_tip_label(common:getLanguageString("@kuafuRaceNotStart"))
		elseif curState == enumKuafuState.knockout then
			msg.getReportSize({
			callback = function(data)
				dump(data)
				local param = {
				showType = 2,
				count = data.count
				}
				local layer = require("game.kuafuzhan.applyMsgBox").new(param)
				self._parent:addChild(layer, 100)
			end
			})
		else
			local scene = require("game.kuafuzhan.raceStakeListScene").new()
			push_scene(scene)
		end
	end,
	CCControlEventTouchUpInside)
	
	--奖励预览
	self._rootnode.reward_preview_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local param = {}
		param.miPageId = 3
		param.typeTbl = {2, 3}
		param.props_title = common:getLanguageString("@ViewRewardText2")
		local layer = require("game.huashan.HuaShanRewardShow").new(param)
		self._parent:addChild(layer, 100)
	end,
	CCControlEventTouchUpInside)
	
	self:updateRaceList()
end

function raceCourseLayer:settingBtnFunc()
	local curState = KuafuModel.getKuafuState()
	if curState == enumKuafuState.Bet16To8 or curState == enumKuafuState.Bet8To4 or curState == enumKuafuState.Bet4To2 or curState == enumKuafuState.Bet2To1 or curState == enumKuafuState.apply then
		KuafuModel.showFormLayer()
	elseif curState >= enumKuafuState.zhanshi then
		show_tip_label(common:getLanguageString("@kuafuFinishRace"))
	else
		show_tip_label(common:getLanguageString("@canNotSettingFormTip"))
	end
end

function raceCourseLayer:stateChanged(curState)
	self:updateRaceList()
end

local showMaxNum = 1

function raceCourseLayer:updateRaceList()
	local curState = KuafuModel.getKuafuState()
	local data_kuafuzhanconfig_kuafuzhanconfig = require("data.data_kuafuzhanconfig_kuafuzhanconfig")
	local index = 0
	for key, data in ipairs(data_kuafuzhanconfig_kuafuzhanconfig) do
		if data.onthetab == 1 then
			self._rootnode["moment_name0" .. index]:setString(data.lang)
			if key == curState then
				self._rootnode["moment_name0" .. index]:setColor(cc.c3b(255, 38, 0))
			else
				self._rootnode["moment_name0" .. index]:setColor(cc.c3b(112, 51, 0))
			end
			index = index + 1
			if index > 9 then
				break
			end
		end
	end
end

function raceCourseLayer:initData()
end

function raceCourseLayer:onExit()
end

function raceCourseLayer:onEnter()
end

return raceCourseLayer