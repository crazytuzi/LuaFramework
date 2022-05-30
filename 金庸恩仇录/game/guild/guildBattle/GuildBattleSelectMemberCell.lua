local GuildBattleSelectMemberCell = class("GuildBattleSelectMemberCell", function()
  return CCTableViewCell:new()
end)
local cntSize
function GuildBattleSelectMemberCell:getContentSize()
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
function GuildBattleSelectMemberCell:onExit()
end
function GuildBattleSelectMemberCell:refresh(param)
  self._itemData = param.itemData
  self._rootnode.guild_name_lbl:setString(self._itemData.role_name)
  self._rootnode.guild_lv_lbl:setString("LV." .. tostring(self._itemData.level))
  self._rootnode.power_lbl:setString(self._itemData.attack)
  self._rootnode.arena_lbl:setString(self._itemData.rank)
  self._rootnode.total_gongxian_lbl:setString(self._itemData.contribute)
  self._rootnode.mem_normal_lbl:setString(GUILD_JOB_NAME[self._itemData.jop_type + 1])
  if self._itemData.jop_type == GUILD_JOB_TYPE.normal then
    self._rootnode.mem_normal_lbl:setColor(ccc3(119, 62, 5))
  else
    self._rootnode.mem_normal_lbl:setColor(ccc3(255, 196, 23))
  end
  local plyaerCard = self._itemData.cards[1]
  ResMgr.refreshIcon({
    id = plyaerCard.resId,
    itemBg = self._rootnode.player_icon,
    resType = ResMgr.HERO,
    cls = plyaerCard.cls
  })
  if self._itemData.pos == 0 then
    self._rootnode.has_in_wall:setVisible(false)
  else
    self._rootnode.has_in_wall:setVisible(true)
    local tips = common:getLanguageString("@GuildBattleWallTip3", common:getLanguageString("@GuildBattleDoor" .. self._itemData.pos))
    self._rootnode.has_in_wall:setString(tips)
  end
end
function GuildBattleSelectMemberCell:create(param)
  local _id = param.id
  self._itemData = param.itemData
  self._callBackFunc = param.callBackFunc
  dump(self.data)
  self:setNodeEventEnabled(true)
  local proxy = CCBProxy:create()
  self._rootnode = {}
  local node = CCBuilderReaderLoad("guild/guild_battle_select_member_cell.ccbi", proxy, self._rootnode)
  node:setPosition(display.width / 2, 0)
  self:addChild(node)
  self._rootnode.defence_btn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    self._callBackFunc(self._itemData)
  end, CCControlEventTouchUpInside)
  self:refresh(param)
  return self
end
function GuildBattleSelectMemberCell:beTouched()
end
return GuildBattleSelectMemberCell
