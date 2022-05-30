local GuildBattleBossInfoLayer = class("GuildBattleBossInfoLayer", function()
  return require("utility.ShadeLayer").new()
end)
local msg = {
  getBossInfo = function(param)
    local _callback = param.callback
    local msg = {m = "union", a = "guardInfo"}
    RequestHelper.request(msg, _callback, param.errback)
  end
}
function GuildBattleBossInfoLayer:ctor(param)
  local isAttack = param.data.isAttack
  local bossData = param.data
  self._parent = param.parent
  local proxy = CCBProxy:create()
  local rootnode = {}
  local node = CCBuilderReaderLoad("guild/guild_battle_boss_info.ccbi", proxy, rootnode, self, param.size)
  node:setPosition(param.size.width / 2, param.size.height / 2)
  self:addChild(node)
  self._rootnode = rootnode
  local function closeFunc()
    self._parent:showCenterLayer(GuildBattleLayerType.CityLayer, {remove = true})
  end
  if isAttack then
    rootnode.confirmBtn:setVisible(true)
  else
    rootnode.confirmBtn:setVisible(false)
  end
  rootnode.backBtn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    closeFunc()
  end, CCControlEventTouchUpInside)
  rootnode.confirmBtn:addHandleOfControlEvent(function(eventName, sender)
    self._rootnode.shader_layer:setVisible(false)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    if isAttack then
      local callBackFunc = function(data)
        dump(data)
        local heros = data.rtnObj
        local scenes = require("game.scenes.formSettingBaseScene").new({
          heros = heros,
          save_form_title = GuildBattleModel.saveFormTitle,
          formSettingType = FormSettingType.BangPaiZhanType,
          confirmFunc = function(fmtStr)
            local callBackFunc = function()
              pop_scene()
            end
            GuildBattleModel.startFight(fmtStr, {}, 2, callBackFunc)
          end
        })
        push_scene(scenes)
      end
      if self.boss_curLife <= 0 then
        show_tip_label(common:getLanguageString("@GuildBattleBossTitle") .. common:getLanguageString("@GuildBattleBossDeaded"))
        return
      end
      GuildBattleModel.getSelfHeroInfo(callBackFunc)
    else
      closeFunc()
    end
  end, CCControlEventTouchUpInside)
  rootnode.boss_icon:setDisplayFrame(ResMgr.getHeroFrame(4902, 0))
  rootnode.boss_icon:setScale(0.6)
  rootnode.boss_icon:runAction(CCRepeatForever:create(transition.sequence({
    CCMoveBy:create(0.7, CCPoint(0, 10)),
    CCDelayTime:create(0.2),
    CCMoveBy:create(0.7, CCPoint(0, -10)),
    CCDelayTime:create(0.2)
  })))
  for i = 1, 4 do
    local effect = ResMgr.createArma({
      resType = ResMgr.UI_EFFECT,
      armaName = "UI_bangpaizhan_1",
      isRetain = true
    })
    self._rootnode["door_effect" .. i]:addChild(effect)
  end
  for i = 1, 4 do
    do
      local btn = self._rootnode["door_btn" .. i]
      btn:addHandleOfControlEvent(function(eventName, sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
        self:showDoorInfo(i)
      end, CCControlEventTouchUpInside)
    end
  end
  self._rootnode.shader_layer:setNodeEventEnabled(true)
  self._rootnode.shader_layer:setVisible(false)
  self._rootnode.closeBtn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    self._rootnode.shader_layer:setVisible(false)
  end, CCControlEventTouchUpInside)
  addTouchListener(self._rootnode.boss_icon, function(sender, eventType)
    if eventType == EventType.ended then
      local cityWallInfo = GuildBattleModel.getCityWallInfo()
      if cityWallInfo.union_member == GUILD_JOB_TYPE.others and not isAttack then
        show_tip_label(common:getLanguageString("@GuildBattleWarTips4"))
      end
    end
  end)
end
function GuildBattleBossInfoLayer:showDoorInfo(index)
  self._rootnode.shader_layer:setVisible(true)
  local data_ui_ui = require("data.data_ui_ui")
  local stateStr = {
    "@StateActivate",
    "@StateUnActivate"
  }
  if self.guards[index] == 0 then
    stateStr = common:getLanguageString("@StateUnActivate")
  else
    stateStr = common:getLanguageString("@StateActivate")
  end
  local doorTips = common:getLanguageString("@GuildBattleDoor" .. index) .. " (" .. stateStr .. ")"
  self._rootnode.doorNameLbl:setString(doorTips)
  self._rootnode.itemDesLbl:setString(data_ui_ui[16 + index].content)
end
function GuildBattleBossInfoLayer:setWallInfo()
  local pngStr = {
    "#boss_info_btn",
    "#boss_info_btn_press"
  }
  for i = 1, 4 do
    local showType = self.guards[i] == 0 and 2 or 1
    resetctrbtnimage(self._rootnode["door_btn" .. i], pngStr[showType] .. i .. ".png")
    self._rootnode["door_effect" .. i]:setVisible(self.guards[i] ~= 0)
  end
  local curLife = self.boss_curLife
  local maxLife = self.boss_maxLife
  self._rootnode.blood_lbl:setString(curLife .. "/" .. maxLife)
  local percent = curLife / maxLife
  local normalBar = self._rootnode.normalBar
  local bar = self._rootnode.addBar
  local rotated = false
  if bar:isTextureRectRotated() == true then
    rotated = true
  end
  bar:setTextureRect(CCRectMake(bar:getTextureRect().origin.x, bar:getTextureRect().origin.y, normalBar:getContentSize().width * percent, bar:getTextureRect().size.height), rotated, CCSizeMake(normalBar:getContentSize().width * percent, normalBar:getContentSize().height * percent))
end
function GuildBattleBossInfoLayer:initData()
  msg.getBossInfo({
    callback = function(data)
      self.boss_curLife = data.rtnObj.curLife
      self.boss_maxLife = data.rtnObj.maxLife
      self.guards = data.rtnObj.guards
      if self.boss_curLife == 0 then
        local cityInfo = GuildBattleModel.getCityInfo()
        if cityInfo.boss_died ~= 1 then
          GuildBattleModel.baseDataInit()
          cityInfo.boss_died = 1
        end
      end
      self:setWallInfo()
    end
  })
end
function GuildBattleBossInfoLayer:onEnter()
end
function GuildBattleBossInfoLayer:onExit()
end
return GuildBattleBossInfoLayer
