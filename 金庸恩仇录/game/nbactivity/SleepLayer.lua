local SleepLayer = class("SleepLayer", function()
	return display.newNode()
end)
local SLEEP_GET_VALUE = 50
local hasExitSleep

function SleepLayer:ctor(param)
	self:setNodeEventEnabled(true)
	local viewSize = param.viewSize
	local proxy = CCBProxy:create()
	local rootnode = {}
	local contentNode = CCBuilderReaderLoad("nbhuodong/nbhuodong_scene.ccbi", proxy, rootnode, self, viewSize)
	self:addChild(contentNode)
	self.rootnode = rootnode
	self.rootnode.rightLian:setVisible(false)
	self.rootnode.leftLian:setVisible(false)
	if display.widthInPixels / display.heightInPixels > 0.67 then
		rootnode.bg2:setPositionY(rootnode.bg2:getPositionY() - rootnode.bg2:getContentSize().height * 0.06)
	end
	local function onGetup()
		show_tip_label(common:getLanguageString("@CongratsStrGet", SLEEP_GET_VALUE))
		ccb.nbHuodongCtrl.mAnimationManager:runAnimationsForSequenceNamed("getupAnim")
		rootnode.girlSprite:runAction(transition.sequence({
		CCDelayTime:create(2),
		CCShow:create(),
		CCFadeIn:create(0.8),
		CCCallFunc:create(function()
			self.rootnode.rightLian:setVisible(false)
			self.rootnode.leftLian:setVisible(false)
		end)
		}))
	end
	local function onRestBtn()
		self.rootnode.rightLian:setVisible(true)
		self.rootnode.leftLian:setVisible(true)
		rootnode.girlSprite:runAction(transition.sequence({
		CCFadeOut:create(0.5),
		CCHide:create(),
		CCCallFunc:create(function()
			if hasExitSleep then
				return
			end
			local schedule = require("framework.scheduler")
			self._schedule = schedule.performWithDelayGlobal(function()
				if hasExitSleep then
					return
				end
				local particle = CCParticleSystemQuad:create("ccs/particle/p_kezhan_xiuxi_1.plist")
				rootnode.particleNode:addChild(particle)
				local particle = CCParticleSystemQuad:create("ccs/particle/p_kezhan_xiuxi_2.plist")
				rootnode.particleNode:addChild(particle)
				self._schedule = schedule.performWithDelayGlobal(function()
					onGetup()
				end,
				2.25)
			end,
			2.5)
			ccb.nbHuodongCtrl.mAnimationManager:runAnimationsForSequenceNamed("sleepAnim")
		end)
		}))
	end
	rootnode.restBtn:addHandleOfControlEvent(function()
		RequestHelper.nbHuodong.sleep({
		callback = function(data)
			if string.len(data["0"]) > 0 then
				CCMessageBox(data["0"], "Tip")
			else
				onRestBtn()
				rootnode.restBtn:setVisible(false)
				game.player:setStrength(data["1"])
			end
		end
		})
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchDown)
	
	self.rootnode.restBtn:setVisible(false)
end

function SleepLayer:clear()
	if self._schedule ~= nil then
		local schedule = require("framework.scheduler")
		schedule.unscheduleGlobal(self._schedule)
		self._schedule = nil
	end
	if self.hotelSound then
		audio.stopSound(self.hotelSound)
		self.hotelSound = nil
	end
	self.rootnode.girlSprite:stopAllActions()
	hasExitSleep = true
end

function SleepLayer:onEnter()
	RequestHelper.nbHuodong.state({
	callback = function(data)
		if #data["0"] > 0 then
			CCMessagBox(data["0"])
		elseif data["1"] > 0 then
			self.rootnode.restBtn:setVisible(true)
			self.hotelSound = ResMgr.playSfx("hotelMM.mp3", ResMgr.PERSION_SFX)
		else
			self.rootnode.restBtn:setVisible(false)
		end
	end
	})
	hasExitSleep = false
end

function SleepLayer:onExit()
	self:clear()
end

return SleepLayer