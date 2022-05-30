local GuildBattleMainLayer = class("GuildBattleMainLayer", function()
  return display.newLayer("GuildBattleMainLayer")
end)
function GuildBattleMainLayer:ctor(param)
  self._proxy = CCBProxy:create()
  self._rootnode = {}
  self:setContentSize(param.size)
  local bgNode = CCBuilderReaderLoad("guild/guild_battle_main_scene.ccbi", self._proxy, self._rootnode, self, param.size)
  self:addChild(bgNode)
  self._viewSize = param.size
  self._parent = param.parent
  self._upLayer = {}
  self._rootnode.backBtn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    GameStateManager:ChangeState(GAME_STATE.STATE_GUILD)
  end, CCControlEventTouchUpInside)
  self._rootnode.act_desc:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    if self:initUplayer(3) then
      local layer = require("game.SplitStove.SplitDescLayer").new(40)
      self._upLayer[3] = layer
      CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000)
    end
  end, CCControlEventTouchUpInside)
  self._rootnode.patrol_btn:addHandleOfControlEvent(function(eventName, sender)
    if self:initUplayer(2) then
      GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
      local layer = require("game.guild.guildBattle.GuildBattleXunluoLayer").new()
      CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000)
      self._upLayer[2] = layer
    end
  end, CCControlEventTouchUpInside)
  self._rootnode.shop_btn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    if self:initUplayer(1) then
      local layer = require("game.guild.guildBattle.GuildBattleExchangeLayer").new({
        size = self._viewSize
      })
      self:addChild(layer)
      self._upLayer[1] = layer
    end
  end, CCControlEventTouchUpInside)
  self._rootnode.city_btn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    self._parent:showCenterLayer(GuildBattleLayerType.CityLayer)
  end, CCControlEventTouchUpInside)
end
local upLayerTag = 7800
function GuildBattleMainLayer:initUplayer(index)
  local oldLayer = tolua.cast(self._upLayer[index], "CCLayer")
  if oldLayer then
    return false
  end
  for i = 1, 3 do
    if i ~= index and tolua.cast(self._upLayer[i], "CCLayer") then
      self._upLayer[i]:removeFromParentAndCleanup(true)
      self._upLayer[i] = nil
    end
  end
  return true
end
function GuildBattleMainLayer:initData(data)
  self._parent._bottomNode:setVisible(false)
  self.cityInfo = GuildBattleModel.getCityInfo()
  self.guildInfo = game.player:getGuildMgr():getGuildInfo()
  self:refreashOccupationInfo()
end
function GuildBattleMainLayer:refreashOccupationInfo()
  if self.cityInfo.union_name == "" then
    self.cityInfo.union_name = common:getLanguageString("@NotHave")
  end
  self._rootnode.occupation_name:setString(self.cityInfo.union_name)
  self._rootnode.occupation_level:setString(self.cityInfo.union_level)
  self._rootnode.occupation_point:setString(self.cityInfo.union_attack)
  local stateType = self.cityInfo.fight_status
  if stateType == GuildBattleFightStatus.war and self.cityInfo.boss_died ~= 0 then
    stateType = 4
  end
  self._rootnode.occupation_state:setString(common:getLanguageString("@GuildBattleState" .. stateType))
  if self.cityInfo.fight_status == GuildBattleFightStatus.war and self.cityInfo.boss_died == 0 then
    if not self._battle_tip_effect then
      local xunhuanEffect = ResMgr.createArma({
        resType = ResMgr.UI_EFFECT,
        armaName = "ui_gczzdz",
        isRetain = true
      })
      self._rootnode.battle_tip_node:addChild(xunhuanEffect, -10)
      self._battle_tip_effect = xunhuanEffect
    end
    self._battle_tip_effect:setVisible(true)
  elseif self._battle_tip_effect then
    self._battle_tip_effect:setVisible(false)
  end
end
function GuildBattleMainLayer:onEnter()
end
function GuildBattleMainLayer:onExit()
end
return GuildBattleMainLayer
