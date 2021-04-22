local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetStormQuickChangeTeam = class("QUIWidgetStormQuickChangeTeam",QUIWidget)
local QUIWidgetStormQuickChangeTeamHead = import("..widgets.QUIWidgetStormQuickChangeTeamHead")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetStormQuickChangeTeam.EVENT_SELECTED = "EVENT_SELECTED"
QUIWidgetStormQuickChangeTeam.EVENT_CHANGE = "EVENT_CHANGE"

function QUIWidgetStormQuickChangeTeam:ctor(options)
	local ccbFile = "ccb/Widget_StormArena_yijian.ccbi"
  	local callBacks = {
      {ccbCallbackName = "onTriggerChange", callback = handler(self, QUIWidgetStormQuickChangeTeam._onTriggerChange)},
      {ccbCallbackName = "onTriggerDevelop", callback = handler(self, QUIWidgetStormQuickChangeTeam._onTriggerDevelop)},
  }
	QUIWidgetStormQuickChangeTeam.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
  	self:resetAll()
    self._index = options.index
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/StormArena.plist")
    if self._index == 1 then
      self._ccbOwner.sp_team:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("S_dyd.png"))
    elseif self._index == 2 then
      self._ccbOwner.sp_team:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("S_ded.png"))
    elseif self._index == 3 then
      self._ccbOwner.sp_team:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("S_dsd.png"))
    end
    local teamIndex = 1
    if self._index == 2 then
      teamIndex = 2
    elseif self._index == 3 then
      teamIndex = 4
    end
    self._lockedSlot = QStaticDatabase:sharedDatabase():getStormArenaUnlockLevel(remote.user.level, teamIndex)
    table.sort(self._lockedSlot, function (a,b)
      return a < b
    end)
end

function QUIWidgetStormQuickChangeTeam:resetAll()
	self._ccbOwner.tf_force:setString("")
	self._ccbOwner.node_btn_change:setVisible(false)
	self._ccbOwner.node_btn_change:setVisible(true)
  if self._heads == nil then
    self._heads = {}
    for i=1,4 do
      local head = QUIWidgetStormQuickChangeTeamHead.new()
      table.insert(self._heads, head)
      self._ccbOwner["node"..i]:addChild(head)
    end
  end
end

function QUIWidgetStormQuickChangeTeam:setTeamInfo(teamInfo)
	self._ccbOwner.node_btn_develop:setVisible(teamInfo.selected == 0)
	self._ccbOwner.node_btn_change:setVisible(teamInfo.selected == 1)
  for _,heroHead in ipairs(self._heads) do
    heroHead:resetAll()
  end
	local force = 0
  for i=1,4 do
      local heroHead = self._heads[i]
      heroHead:setVisible(true)
      local isLock = i > teamInfo.maxCount
      heroHead:setIsLock(isLock)
      if i > 4-#self._lockedSlot then
        heroHead:setLockLevel(self._lockedSlot[i-(4-#self._lockedSlot)])
      end
      local actorId = teamInfo.team[i]
      if actorId ~= nil then
        local heroInfo = remote.herosUtil:getHeroByID(actorId)
        force = force + remote.herosUtil:createHeroProp(heroInfo):getBattleForce()
        heroHead:setHero(actorId)
        heroHead:setLevel(heroInfo.level)
        heroHead:setBreakthrough(heroInfo.breakthrough)
        heroHead:setGodSkillShowLevel(heroInfo.godSkillGrade)
        heroHead:setStar(heroInfo.grade)
        heroHead:showSabc()
      elseif isLock == false then
        heroHead:setEmpty()
      end
  end
    local num,unit = q.convertLargerNumber(force)
    self._ccbOwner.tf_force:setString(num..(unit or ""))
end

function QUIWidgetStormQuickChangeTeam:getHeadByPos(pos, isCheck)
  if isCheck == true then
    for index,heroHead in ipairs(self._heads) do
      if heroHead:getIsLock() == false and heroHead:getHeroId() ~= nil and self:_checkPosInHead(heroHead, pos) then
        return heroHead, index
      end
    end
  else
    local fristEmptyHead = nil
    for index,heroHead in ipairs(self._heads) do
      if heroHead:getHeroId() == nil and fristEmptyHead == nil then
        fristEmptyHead = index
      end
      if heroHead:getIsLock() == false and self:_checkPosInHead(heroHead, pos) then
        if heroHead:getHeroId() == nil then
          return self._heads[fristEmptyHead], fristEmptyHead
        else
          return heroHead, index
        end
      end
    end
  end
end

function QUIWidgetStormQuickChangeTeam:_checkPosInHead(heroHead, pos)
  local pos = heroHead:convertToNodeSpaceAR(pos)
  if pos.x > -50 and pos.x < 50 and pos.y < 50 and pos.y > -50 then
    return true
  end
  return false
end

function QUIWidgetStormQuickChangeTeam:_onTriggerChange()
  app.sound:playSound("common_confirm")
  self:dispatchEvent({name = QUIWidgetStormQuickChangeTeam.EVENT_CHANGE, index = self._index})
end

function QUIWidgetStormQuickChangeTeam:_onTriggerDevelop()
  app.sound:playSound("common_small")
  self:dispatchEvent({name = QUIWidgetStormQuickChangeTeam.EVENT_SELECTED, index = self._index})
end

return QUIWidgetStormQuickChangeTeam