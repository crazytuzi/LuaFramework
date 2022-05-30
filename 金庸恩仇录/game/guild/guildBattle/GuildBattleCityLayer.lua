local GuildBattleCityLayer = class("GuildBattleCityLayer", function()
  return display.newLayer("GuildBattleCityLayer")
end)
function GuildBattleCityLayer:ctor(param)
  self._proxy = CCBProxy:create()
  self._rootnode = {}
  self:setContentSize(param.size)
  local bgNode = CCBuilderReaderLoad("guild/guild_battle_city_layer.ccbi", self._proxy, self._rootnode, self, param.size)
  self:addChild(bgNode)
  self._parent = param.parent
  self._rootnode.backBtn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    self._parent:showCenterLayer(GuildBattleLayerType.MainLayer)
  end, CCControlEventTouchUpInside)
  for i = 1, 4 do
    do
      local wallBtn = self._rootnode["guild_door_btn" .. i]
      wallBtn:addHandleOfControlEvent(function(eventName, sender)
        local function getCityWallInfo(data)
          self._parent:showCenterLayer(GuildBattleLayerType.WallList, {doorType = i})
        end
        GuildBattleModel.CityWallInfoInit(getCityWallInfo, self._cityInfo.fight_status == GuildBattleFightStatus.war)
      end, CCControlEventTouchUpInside)
    end
  end
  self._rootnode.city_btn:addHandleOfControlEvent(function(eventName, sender)
    local function getCityWallInfo(data)
      local isAttack
      if self._cityInfo.fight_status == GuildBattleFightStatus.war and data.union_member == GUILD_JOB_TYPE.others then
        isAttack = true
      end
      self._parent:showCenterLayer(GuildBattleLayerType.BossInfo, {isAttack = isAttack})
    end
    GuildBattleModel.CityWallInfoInit(getCityWallInfo)
  end, CCControlEventTouchUpInside)
end
function GuildBattleCityLayer:initData()
  self._cityInfo = GuildBattleModel.getCityInfo()
  if self._cityInfo.fight_status == GuildBattleFightStatus.war and self._cityInfo.boss_died == 0 then
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
function GuildBattleCityLayer:onEnter()
end
function GuildBattleCityLayer:onExit()
end
return GuildBattleCityLayer
