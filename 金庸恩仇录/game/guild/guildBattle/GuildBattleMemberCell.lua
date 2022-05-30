local GuildBattleMemberCell = class("GuildBattleMemberCell", function()
  return CCTableViewCell:new()
end)
local cntSize
function GuildBattleMemberCell:getContentSize()
  if cntSize == nil then
    local proxy = CCBProxy:create()
    local rootNode = {}
    local node = CCBuilderReaderLoad("guild/guild_battle_member_cell.ccbi", proxy, rootNode)
    cntSize = rootNode.itemBg:getContentSize()
    self:addChild(node)
    node:removeSelf()
  end
  return cntSize
end
function GuildBattleMemberCell:onExit()
end
function GuildBattleMemberCell:refresh(param)
  self._itemData = param.itemData
  self._btnType = param.btnType
  if self._btnType == 1 then
    self._rootnode.defence_change_btn:setVisible(true)
    self._rootnode.challenge_btn:setVisible(false)
    self._rootnode.die_lbl:setVisible(false)
    resetctrbtnString(self._rootnode.defence_change_btn, common:getLanguageString("@GuildBattleWallBtn2"))
  elseif self._btnType == 2 then
    self._rootnode.defence_change_btn:setVisible(true)
    self._rootnode.challenge_btn:setVisible(false)
    resetctrbtnString(self._rootnode.defence_change_btn, common:getLanguageString("@chakanzhenrong"))
    self._rootnode.die_lbl:setVisible(false)
  elseif self._btnType == 3 then
    self._rootnode.defence_change_btn:setVisible(false)
    self._rootnode.challenge_btn:setVisible(self._itemData.died == 0)
    self._rootnode.die_lbl:setVisible(self._itemData.died ~= 0)
  elseif self._btnType == 4 then
    self._rootnode.defence_change_btn:setVisible(false)
    self._rootnode.challenge_btn:setVisible(self._itemData.died == 0)
    self._rootnode.die_lbl:setVisible(self._itemData.died ~= 0)
  end
  self._rootnode.gang_name:setString(param.union_name)
  self._rootnode.lv_num:setString("LV." .. tostring(self._itemData.level))
  local playerName = self._itemData.role_name
  self._rootnode.player_name:setString(playerName)
  self._rootnode.fight_num:setString(tostring(self._itemData.attack))
  for key, team in ipairs(self._itemData.cards) do
    if key < 5 then
      self._rootnode["icon_" .. key]:setVisible(true)
      local cls = team.cls
      local resId = team.resId
      ResMgr.refreshIcon({
        id = resId,
        itemBg = self._rootnode["icon_" .. key],
        resType = ResMgr.HERO,
        cls = cls
      })
    end
  end
end
function GuildBattleMemberCell:create(param)
  local _id = param.id
  self._itemData = param.itemData
  self._callBackFunc = param.callBackFunc
  dump(self.data)
  self:setNodeEventEnabled(true)
  local proxy = CCBProxy:create()
  self._rootnode = {}
  local node = CCBuilderReaderLoad("guild/guild_battle_member_cell.ccbi", proxy, self._rootnode)
  node:setPosition(display.width / 2, 0)
  self:addChild(node)
  local function addBtnHandler(btn)
    btn:addHandleOfControlEvent(function(eventName, sender)
      GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
      self._callBackFunc(self._itemData)
    end, CCControlEventTouchUpInside)
  end
  addBtnHandler(self._rootnode.challenge_btn)
  addBtnHandler(self._rootnode.defence_change_btn)
  self:refresh(param)
  return self
end
function GuildBattleMemberCell:beTouched()
end
return GuildBattleMemberCell
