local GuildBattleWallListLayer = class("GuildBattleWallListLayer", function()
  return display.newLayer("GuildBattleWallListLayer")
end)
local WallListMsg = {
  getEnemyInfo = function(param)
    local _callback = param.callback
    local msg = {
      m = "union",
      a = "roleInfo",
      type = param.type,
      aid = param.aid
    }
    RequestHelper.request(msg, _callback, param.errback)
  end
}
function GuildBattleWallListLayer:ctor(param)
  self._proxy = CCBProxy:create()
  self._rootnode = {}
  self:setContentSize(param.size)
  local bgNode = CCBuilderReaderLoad("guild/guild_battle_wall_layer.ccbi", self._proxy, self._rootnode, self, param.size)
  self:addChild(bgNode)
  self._parent = param.parent
  resetctrbtnString(self._rootnode.tab1, common:getLanguageString("@GuildBattleWallTip1"))
  self._rootnode.backBtn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    self._parent:showCenterLayer(GuildBattleLayerType.CityLayer)
  end, CCControlEventTouchUpInside)
  local boardWidth = self._rootnode.listView_node:getContentSize().width
  local boardHeight = self._rootnode.listView_node:getContentSize().height - self._rootnode.defence_info_node:getContentSize().height - self._rootnode.up_node:getContentSize().height
  local listViewSize = CCSizeMake(boardWidth, boardHeight)
  self.cityInfo = GuildBattleModel.getCityInfo()
  local function memberChangeFunc(member)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    if self._btnType == 1 then
      if self.cityInfo.fight_status ~= GuildBattleFightStatus.peace then
        show_tip_label(common:getLanguageString("@GuildBattleWarTips"))
      elseif self._cityWallInfo.union_member == GUILD_JOB_TYPE.assistant or self._cityWallInfo.union_member == GUILD_JOB_TYPE.leader then
        self._parent:showCenterLayer(GuildBattleLayerType.SelectMember, {
          doorType = self._doorType,
          member = member
        })
      else
        show_tip_label(common:getLanguageString("@GuildBattleWarTips2"))
      end
    elseif self._btnType == 2 then
      local layer = require("game.form.EnemyFormLayer").new(1, member.role_acc)
      layer:setPosition(0, 0)
      self._parent:addChild(layer, 10000000)
    elseif self._btnType == 3 then
      self:challengeFunc(member)
    elseif self._btnType == 4 then
      show_tip_label(common:getLanguageString("@GuildBattleWarTips3"))
    end
  end
  local function createFunc(index)
    local item = require("game.guild.guildBattle.GuildBattleMemberCell").new()
    return item:create({
      itemData = self._memberList[index + 1],
      btnType = self._btnType,
      callBackFunc = memberChangeFunc,
      union_name = self.cityInfo.union_name
    })
  end
  local function refreshFunc(cell, index)
    cell:refresh({
      itemData = self._memberList[index + 1],
      btnType = self._btnType,
      union_name = self.cityInfo.union_name
    })
  end
  self.listTableView = require("utility.TableViewExt").new({
    size = listViewSize,
    direction = kCCScrollViewDirectionVertical,
    createFunc = createFunc,
    refreshFunc = refreshFunc,
    cellNum = 0,
    cellSize = require("game.guild.guildBattle.GuildBattleMemberCell").new():getContentSize()
  })
  self._rootnode.listView_node:addChild(self.listTableView)
  self._rootnode.defence_change_btn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    if self.cityInfo.fight_status ~= GuildBattleFightStatus.peace then
      show_tip_label(common:getLanguageString("@GuildBattleWarTips"))
    elseif #self._memberList >= GuildBattleModel.wallMaxMemberCount then
      show_tip_label(common:getLanguageString("@GuildBattleWallEnough"))
    elseif self._cityWallInfo.union_member == GUILD_JOB_TYPE.assistant or self._cityWallInfo.union_member == GUILD_JOB_TYPE.leader then
      self._parent:showCenterLayer(GuildBattleLayerType.SelectMember, {
        doorType = self._doorType,
        member = nil
      })
    else
      self:addToWall()
    end
  end, CCControlEventTouchUpInside)
end
local challengeEnemyFormTag = 2151
function GuildBattleWallListLayer:challengeFunc(member)
  local function challengeCallBackFunc(data)
    if self._parent:getChildByTag(challengeEnemyFormTag) then
      return
    end
    local roleData = data.rtnObj
    local _info = {}
    _info.name = roleData.name
    _info.combat = roleData.attack
    _info.cards = roleData.cards
    dump(_info.cards)
    local formLayer = require("game.scenes.showEnemyFormLayer").new({
      info = _info,
      confirmFunc = function()
        local function callBackFunc(data)
          dump(data)
          self._formLayer:removeFromParentAndCleanup(true)
          local heros = data.rtnObj
          local scenes = require("game.scenes.formSettingBaseScene").new({
            heros = heros,
            save_form_title = GuildBattleModel.saveFormTitle,
            formSettingType = FormSettingType.BangPaiZhanType,
            confirmFunc = function(fmtStr)
              local callBackFunc = function()
                pop_scene()
              end
              roleData.cards = nil
              roleData.id = member.role_id
              GuildBattleModel.startFight(fmtStr, roleData, 1, callBackFunc)
            end,
            btnName = common:getLanguageString("@Kaishitiaozhan")
          })
          push_scene(scenes)
        end
        GuildBattleModel.getSelfHeroInfo(callBackFunc)
      end
    })
    self._formLayer = formLayer
    self._parent:addChild(formLayer, 10, challengeEnemyFormTag)
  end
  WallListMsg.getEnemyInfo({
    type = 1,
    aid = member.role_id,
    callback = challengeCallBackFunc
  })
end
function GuildBattleWallListLayer:addToWall()
  if self._cityWallInfo.union_pos == self._doorType then
    show_tip_label(common:getLanguageString("@Nin") .. common:getLanguageString("@GuildBattleWallHasIn", common:getLanguageString("@GuildBattleDoor" .. self._cityWallInfo.union_pos)))
  else
    do
      local function confirmFunc()
        GuildBattleModel.setLineUp(game.player.m_playerID, 0, self._doorType, function(data)
          self:initData()
        end)
      end
      if self._cityWallInfo.union_pos > 0 then
        local tips = common:getLanguageString("@GuildBattleWallHasIn", common:getLanguageString("@GuildBattleDoor" .. self._cityWallInfo.union_pos)) .. common:getLanguageString("@GuildBattleConfirmChange")
        local layer = require("utility.MsgBox").new({
          size = CCSizeMake(500, 250),
          content = tips,
          rightBtnFunc = function()
          end,
          rightBtnName = common:getLanguageString("@Confirm"),
          leftBtnName = common:getLanguageString("@NO"),
          rightBtnFunc = function()
            confirmFunc()
          end
        })
        self._parent:addChild(layer, 100)
      else
        confirmFunc()
      end
    end
  end
end
function GuildBattleWallListLayer:initData(data)
  if data then
    self._doorType = data.doorType
  end
  self._cityWallInfo = GuildBattleModel.getCityWallInfo()
  self._memberList = self._cityWallInfo.role_card[self._doorType]
  self._btnType = 1
  if self._cityWallInfo.union_member == GUILD_JOB_TYPE.others then
    if self.cityInfo.fight_status ~= GuildBattleFightStatus.war then
      self._btnType = 2
    else
      self._btnType = 3
    end
    self._rootnode.defence_change_btn:setVisible(false)
  elseif self.cityInfo.fight_status == GuildBattleFightStatus.war then
    self._btnType = 4
    self._rootnode.defence_change_btn:setVisible(false)
  end
  self.listTableView:resetListByNumChange(#self._memberList)
  local doorTitle = common:getLanguageString("@GuildBattleDoor" .. self._doorType)
  local tips
  if self._btnType <= 2 then
    tips = doorTitle .. common:getLanguageString("@GuildBattleWallTip2") .. #self._memberList .. "/" .. GuildBattleModel.wallMaxMemberCount
  else
    local count = 0
    for key, member in pairs(self._memberList) do
      if member.died == 0 then
        count = count + 1
      end
    end
    tips = doorTitle .. common:getLanguageString("@GuildBattleWallTip4") .. count .. "/" .. #self._memberList
  end
  self._rootnode.defence_hero_num:setString(tips)
end
function GuildBattleWallListLayer:onEnter()
end
function GuildBattleWallListLayer:onExit()
end
return GuildBattleWallListLayer
