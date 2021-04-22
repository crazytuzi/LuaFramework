-- @Author: xurui
-- @Date:   2018-10-25 11:14:34
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-14 15:58:54
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolyFingerguessing = class("QUIDialogMonopolyFingerguessing", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogMonopolyFingerguessing:ctor(options)
	local ccbFile = "ccb/Widget_monopoly_hammer.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick1", callback = handler(self, self._onTriggerClick1)},
		{ccbCallbackName = "onTriggerClick2", callback = handler(self, self._onTriggerClick2)},
		{ccbCallbackName = "onTriggerClick3", callback = handler(self, self._onTriggerClick3)},
		{ccbCallbackName = "onTriggerStart", callback = handler(self, self._onTriggerStart)},
    }
    QUIDialogMonopolyFingerguessing.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
	q.setButtonEnableShadow(self._ccbOwner.btn_action)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end

    self._ccbOwner.node_btn_close:setVisible(false)
    self._ccbOwner.btn_one:setPositionX(103)
    --1, 是剪刀；2，是拳；3，是布
    self._chooseFinger = 1
end

function QUIDialogMonopolyFingerguessing:viewDidAppear()
	QUIDialogMonopolyFingerguessing.super.viewDidAppear(self)

	self:setChooseStated()
end

function QUIDialogMonopolyFingerguessing:viewWillDisappear()
  	QUIDialogMonopolyFingerguessing.super.viewWillDisappear(self)
end

function QUIDialogMonopolyFingerguessing:setChooseStated()
	self._ccbOwner.sp_normal_1:setVisible(not (self._chooseFinger == 1))
	self._ccbOwner.sp_normal_2:setVisible(not (self._chooseFinger == 2))
	self._ccbOwner.sp_normal_3:setVisible(not (self._chooseFinger == 3))
end

function QUIDialogMonopolyFingerguessing:playFigerguessEffect()
	math.randomseed(q.OSTime())
	local enemyFinger = math.random(1, 3)

	-- 1，是赢；2，是输；3，是平局
	local isWin = 3
	if self._chooseFinger ~= enemyFinger then
		if self._chooseFinger == 1 then
			if enemyFinger == 2 then
				isWin = 2
			else
				isWin = 1
			end
		elseif self._chooseFinger == 2 then
			if enemyFinger == 1 then
				isWin = 1
			else
				isWin = 2
			end
		elseif self._chooseFinger == 3 then
			if enemyFinger == 1 then
				isWin = 2
			else
				isWin = 1
			end
		end
	end

	if self._fingerEffcet == nil then
		self._fingerEffcet = QUIWidgetAnimationPlayer.new()
		self:getView():addChild(self._fingerEffcet)
	end

	self._fingerEffcet:playAnimation("effects/Widget_monopoly_caiquan.ccbi", function(ccbOwner)
			ccbOwner.sp_win:setVisible(false)
			ccbOwner.sp_lose:setVisible(false)
			ccbOwner.sp_perfect:setVisible(false)
			ccbOwner.node_win_effect:setVisible(false)
			if isWin == 1 then
				if remote.monopoly.fingerGuessWinCount == 2 then
					ccbOwner.sp_perfect:setVisible(true)
				else
					ccbOwner.sp_win:setVisible(true)
				end
				ccbOwner.node_win_effect:setVisible(true)
			elseif isWin == 2 then
				-- remote.monopoly.fingerGuessWinCount = 0
			 --  	remote.monopoly:monopolyGetFingerRewardRequest(remote.monopoly.fingerGuessWinCount, nil)
				ccbOwner.sp_lose:setVisible(true)
			end

			local enemyPath = QResPath("monopolyFinger")[enemyFinger]
			local myPath = QResPath("monopolyFinger")[self._chooseFinger]
			if enemyPath then
				QSetDisplayFrameByPath(ccbOwner.sp_enemy, enemyPath)
			end
			if myPath then
				QSetDisplayFrameByPath(ccbOwner.sp_my, myPath)
			end
		end, function()
			if isWin == 3 then
				-- self:playFigerguessEffect()
				self._ccbOwner.node_parent:setVisible(true)
				self:setChooseStated()
			elseif isWin == 2 then
				remote.monopoly.fingerGuessWinCount = 0
				-- app.tip:floatTip("你输掉了比试，什么都没有获得")
				-- self:playEffectOut()
			  	remote.monopoly:monopolyGetFingerRewardRequest(remote.monopoly.fingerGuessWinCount, function()
			  			if self:safeCheck() then
				  			app.tip:floatTip("你输掉了比试，什么都没有获得")
							self:playEffectOut()
						end
			  		end)
			else
				remote.monopoly.fingerGuessWinCount = remote.monopoly.fingerGuessWinCount + 1
				self:showWinAward()
			end
		end)
end

function QUIDialogMonopolyFingerguessing:showWinAward()
	self._showAwards = true
	self:playEffectOut()
end

function QUIDialogMonopolyFingerguessing:_onTriggerClick1()
	if self._chooseFinger == 1 then return end

	self._chooseFinger = 1
	self:setChooseStated()
end

function QUIDialogMonopolyFingerguessing:_onTriggerClick2()
	if self._chooseFinger == 2 then return end

	self._chooseFinger = 2
	self:setChooseStated()
end

function QUIDialogMonopolyFingerguessing:_onTriggerClick3()
	if self._chooseFinger == 3 then return end

	self._chooseFinger = 3
	self:setChooseStated()
end

function QUIDialogMonopolyFingerguessing:_onTriggerStart()
	app.sound:playSound("common_small")

	if self._chooseFinger < 1 and self._chooseFinger > 3 then
		return
	end

	self._ccbOwner.node_parent:setVisible(false)

	self:playFigerguessEffect()
end

function QUIDialogMonopolyFingerguessing:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if self._showAwards then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonopolyFingerguessingAwards"})
	end
end

return QUIDialogMonopolyFingerguessing
