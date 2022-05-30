local HuaShanBattleResultLayer
require("game.GameConst")
local HuaShanBattleResultLayer = class("HuaShanBattleResultLayer", function(data)
  return require("utility.ShadeLayer").new()
end)
function HuaShanBattleResultLayer:initWin(data)
  local proxy = CCBProxy:create()
  local node = CCBuilderReaderLoad("friend/friend_win.ccbi", proxy, self._rootnode)
  node:setPosition(display.width / 2, display.height / 2)
  self:addChild(node)
  local effWin = ResMgr.createArma({
    resType = ResMgr.UI_EFFECT,
    armaName = "zhandoushengli",
    isRetain = true
  })
  effWin:setPosition(self._rootnode.tag_title_anim:getContentSize().width / 2, self._rootnode.tag_title_anim:getContentSize().height)
  self._rootnode.tag_title_anim:addChild(effWin)
  local effTextWin = ResMgr.createArma({
    resType = ResMgr.UI_EFFECT,
    armaName = "zhandoushengli_zi",
    isRetain = true
  })
  effTextWin:setPosition(self._rootnode.tag_title_anim:getContentSize().width / 2, self._rootnode.tag_title_anim:getContentSize().height)
  self._rootnode.tag_title_anim:addChild(effTextWin)
  local zhenrongBtn = self._rootnode.zhenrongBtn
  zhenrongBtn:setVisible(false)
  self._rootnode.zhanbaoBtn:addHandleOfControlEvent(function(eventName, sender)
    show_tip_label(common:getLanguageString("@OpenSoon"))
  end, CCControlEventTouchUpInside)
end
function HuaShanBattleResultLayer:initLost()
  local proxy = CCBProxy:create()
  local node = CCBuilderReaderLoad("huodong/yabiao_lost.ccbi", proxy, self._rootnode)
  node:setPosition(display.width / 2, display.height / 2)
  self:addChild(node)
  local zhenrongBtn = self._rootnode.zhenrongBtn
  zhenrongBtn:setVisible(false)
  self._rootnode.wujiangBtn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE)
  end, CCControlEventTouchUpInside)
  self._rootnode.zhuangbeiBtn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT)
  end, CCControlEventTouchUpInside)
  self._rootnode.goZhenrongBtn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    GameStateManager:ChangeState(GAME_STATE.STATE_ZHENRONG)
  end, CCControlEventTouchUpInside)
  self._rootnode.heroRewardBtn:addHandleOfControlEvent(function(eventName, sender)
    GameStateManager:ChangeState(GAME_STATE.STATE_JIANGHULU)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
  end, CCControlEventTouchUpInside)
  self._rootnode.zhenqiBtn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    GameStateManager:ChangeState(GAME_STATE.STATE_JINGYUAN)
  end, CCControlEventTouchUpInside)
end
function HuaShanBattleResultLayer:ctor(data)
  dump(data)
  self._rootnode = {}
  local result = data.data["1"][1]
  local battleInfo = data.battleInfo
  battleInfo.isPassed = true
  self.acc = battleInfo.id
  if result == 1 then
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
    self:initWin()
  else
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shibai))
    self:initLost()
  end
  self._rootnode.battle_value_left:setString(tostring(data.attack1))
  self._rootnode.battle_value_right:setString(tostring(data.attack2))
  self._rootnode.player_name_left:setString(data.name1)
  self._rootnode.player_name_right:setString(data.name2)
  self._rootnode.confirmBtn:addHandleOfControlEvent(function(eventName, sender)
    display.replaceScene(require("game.huashan.HuaShanScene").new())
  end, CCControlEventTouchUpInside)
  self._rootnode.replayBtn:addHandleOfControlEvent(function(eventName, sender)
    self._rootnode.confirmBtn:setEnabled(false)
    self._rootnode.replayBtn:setEnabled(false)
    local scene = require("game.huashan.HuaShanBattleScene").new(battleInfo)
    display.replaceScene(scene)
  end, CCControlEventTouchUpInside)
end
function HuaShanBattleResultLayer:onExit(...)
  CCTextureCache:sharedTextureCache():removeUnusedTextures()
  display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
end
return HuaShanBattleResultLayer
