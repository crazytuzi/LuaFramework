local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetThunderFighter = class("QUIWidgetThunderFighter", QUIWidget)
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetThunderFighter:ctor(options)
	local ccbFile = "ccb/Widget_ThunderKing_client.ccbi"
  	local callBacks = {}
	QUIWidgetThunderFighter.super.ctor(self,ccbFile,callBacks,options)
	self._handlers = {}
end

function QUIWidgetThunderFighter:onExit()
	QUIWidgetThunderFighter.super.onExit(self)
	if self._star ~= nil then
		self._star:disappear()
	end
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
	end
	if self._handlers ~= nil then
		for _,handler in pairs(self._handlers) do
			scheduler.unscheduleGlobal(handler)
		end
	end
end

function QUIWidgetThunderFighter:setInfo(index, config, lastIndex, star, perStar)
	star = star or 0
	self._ccbOwner.tf_name:setString("第"..(config.thunder_floor-1)*3+index.."关")
	self._ccbOwner.avatar:setVisible(true)
	self._ccbOwner.node_battle:setVisible(false)
	if self._avatar == nil then
		self._avatar = QUIWidgetHeroInformation.new()
		self._ccbOwner.avatar:addChild(self._avatar)
		self._avatar:setBackgroundVisible(false)
		self._avatar:setNameVisible(false)
		-- self._avatar:setProVisible(false)
	end
	local dungeonConfig = QStaticDatabase:sharedDatabase():getDungeonConfigByID(config["dungeon"..index.."_easy"])
	local monsterConfig = QStaticDatabase:sharedDatabase():getMonstersById(dungeonConfig.monster_id)
	local actorId = nil
	if monsterConfig ~= nil and #monsterConfig > 0 then
		for i,value in pairs(monsterConfig) do
			-- TOFIX: SHRINK
			local value = q.cloneShrinkedObject(value)
			if actorId == nil or value.is_boss then
				actorId = value.npc_id
			end
		end
	end
	self._avatar:setAvatarByHeroInfo(nil, actorId, dungeonConfig.boss_size or 1)
	if dungeonConfig.stars_high ~= nil then
		self._ccbOwner.node_battle:setPositionY(self._ccbOwner.node_battle:getPositionY() + dungeonConfig.stars_high)
	end
	makeNodeFromNormalToGray(self._avatar)
	if star > 0 then
		self._avatar:setVisible(false)
	end
	self._avatar:pauseAnimation()
	if index ~= lastIndex then
		if index < lastIndex and star > 0 and star <= 3 then
			self._star = QUIWidgetAnimationPlayer.new()
			self._ccbOwner.node_star:addChild(self._star)

			if (remote.thunder:getIsBattle() or remote.thunder:getIsFast()) and index+1 == lastIndex then
				if remote.thunder:getIsFast() == true and remote.thunder.battleType == 1 then
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderFastBattle"})
					remote.thunder:setFastUserComeBackRatio(1)
					self._ccbOwner.sp_pass:setVisible(index < lastIndex)
					self._star:playAnimation("Widget_ThunderKing_star.ccbi",nil,nil,false)
					self._star:playByName("star3", function (ccbOwner)
						for i=1,3 do
							ccbOwner["node_"..i]:setVisible(i==star)
						end
					end)
				else
					self._schedulerHandler = scheduler.performWithDelayGlobal(function ()
						self._schedulerHandler = nil
						self._star:playAnimation("Widget_ThunderKing_star.ccbi",nil,function ()
							self._ccbOwner.sp_pass:setVisible(index < lastIndex)
						end,false)
						self._star:playByName(star.."star")
					end,0.5)
					if index < 3 then
						remote.thunder:setIsBattle(false,false)
					end
				end
			else
				self._ccbOwner.sp_pass:setVisible(index < lastIndex)
				self._star:playAnimation("Widget_ThunderKing_star.ccbi",nil,nil,false)
				self._star:playByName("star3", function (ccbOwner)
					for i=1,3 do
						ccbOwner["node_"..i]:setVisible(i==star)
					end
				end)
			end
			self._ccbOwner.tf_name:setString("")
		else
			self._ccbOwner.sp_pass:setVisible(index < lastIndex)
		end
	elseif index == lastIndex then
		if remote.thunder:getIsBattle() and perStar ~= nil then
			-- local handler = scheduler.performWithDelayGlobal(function ()
				makeNodeFromGrayToNormal(self._avatar)
				self._ccbOwner.node_battle:setVisible(true)
				self._avatar:setVisible(true)
				self._avatar:resumeAnimation()
				-- end,1 + perStar*0.3)
			-- table.insert(self._handlers, handler)
		else
			makeNodeFromGrayToNormal(self._avatar)
			self._ccbOwner.node_battle:setVisible(true)
			self._avatar:setVisible(true)
			self._avatar:resumeAnimation()
		end
		self._ccbOwner.sp_pass:setVisible(index < lastIndex)
	end
end

function QUIWidgetThunderFighter:setLockState(state)
	if state == nil then return end
	self._ccbOwner.sp_unlock_elite:setVisible(state)
end

return QUIWidgetThunderFighter