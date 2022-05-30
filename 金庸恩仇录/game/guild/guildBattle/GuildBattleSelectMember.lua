local GuildBattleSelectMember = class("GuildBattleSelectMember", function()
  return display.newLayer("GuildBattleSelectMember")
end)
function GuildBattleSelectMember:ctor(param)
  self._proxy = CCBProxy:create()
  self._rootnode = {}
  self:setContentSize(param.size)
  local bgNode = CCBuilderReaderLoad("guild/guild_battle_wall_layer.ccbi", self._proxy, self._rootnode, self, param.size)
  self:addChild(bgNode)
  self._parent = param.parent
  resetctrbtnString(self._rootnode.tab1, common:getLanguageString("@GuildMembers"))
  self._rootnode.defence_info_node:setVisible(false)
  self._rootnode.backBtn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    self._parent:showCenterLayer(GuildBattleLayerType.WallList)
  end, CCControlEventTouchUpInside)
  local boardWidth = self._rootnode.listView_node:getContentSize().width
  local boardHeight = self._rootnode.listView_node:getContentSize().height - self._rootnode.up_node:getContentSize().height
  local listViewSize = CCSizeMake(boardWidth, boardHeight)
  local function memberChangeFunc(selectMember)
    if self._curMemberId == 0 and #self._allMemberList[self._doorType] >= GuildBattleModel.wallMaxMemberCount then
      show_tip_label(common:getLanguageString("@GuildBattleWallEnough"))
      return
    end
    local function confirmFunc()
      GuildBattleModel.setLineUp(selectMember.role_id, self._curMemberId, self._doorType, function(data)
        if self._curMemberId == 0 then
          self:initData({
            doorType = self._doorType
          })
        else
          self._parent:showCenterLayer(GuildBattleLayerType.WallList)
        end
      end)
    end
    if 0 < selectMember.pos then
      local tips = selectMember.role_name .. common:getLanguageString("@GuildBattleWallHasIn", common:getLanguageString("@GuildBattleDoor" .. selectMember.pos)) .. common:getLanguageString("@GuildBattleConfirmChange")
      local layer = require("utility.MsgBox").new({
        size = CCSizeMake(500, 250),
        content = tips,
        leftBtnFunc = function()
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
  local function createFunc(index)
    local item = require("game.guild.guildBattle.GuildBattleSelectMemberCell").new()
    return item:create({
      itemData = self._memberList[index + 1],
      callBackFunc = memberChangeFunc
    })
  end
  local function refreshFunc(cell, index)
    cell:refresh({
      itemData = self._memberList[index + 1]
    })
  end
  self.listTableView = require("utility.TableViewExt").new({
    size = listViewSize,
    direction = kCCScrollViewDirectionVertical,
    createFunc = createFunc,
    refreshFunc = refreshFunc,
    cellNum = 0,
    cellSize = require("game.guild.guildBattle.GuildBattleSelectMemberCell").new():getContentSize()
  })
  self._rootnode.listView_node:addChild(self.listTableView)
end
function GuildBattleSelectMember:initData(data)
  if data then
    self._doorType = data.doorType
    self._curMemberId = data.member and data.member.role_id or 0
  end
  self._cityWallInfo = GuildBattleModel.getCityWallInfo()
  self._allMemberList = self._cityWallInfo.role_card
  self.cityInfo = GuildBattleModel.getCityInfo()
  self._memberList = {}
  for i = 0, 4 do
    if self._doorType ~= i then
      for key, member in pairs(self._allMemberList[i]) do
        table.insert(self._memberList, member)
      end
    end
  end
  self.listTableView:resetListByNumChange(#self._memberList)
end
function GuildBattleSelectMember:onEnter()
end
function GuildBattleSelectMember:onExit()
end
return GuildBattleSelectMember
