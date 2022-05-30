local MAX_ZORDER = 101
local listViewDisH = 95
local GuildAutoTimeLayer = class("GuildAutoTimeLayer", function()
  return require("utility.ShadeLayer").new()
end)
function GuildAutoTimeLayer:ctor(param)
  self:setNodeEventEnabled(true)
  local proxy = CCBProxy:create()
  self._rootnode = {}
  local node = CCBuilderReaderLoad("guild/guild_guildFuli_bg.ccbi", proxy, self._rootnode, self, CCSizeMake(display.width, display.height * 0.94))
  node:setPosition(display.width / 2, display.height / 2)
  self:addChild(node)
  self._rootnode.titleLabel:setString(common:getLanguageString("@btnGuildAutoOption"))
  self._rootnode.tag_close:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    self:removeFromParentAndCleanup(true)
  end, CCControlEventTouchUpInside)
  local param = {}
  function param.callback(data)
    dump(data)
    if data.err and data.err ~= "" then
      show_tip_label(data_error_error[data.errCode].prompt)
      return
    end
    if self.showGuildAutoTimeLayer ~= nil and self.showGuildAutoTimeLayer == true then
      self.param = data.rtnObj
      self:refreshUI()
    end
  end
  GameRequest.Guild.autoState(param)
end
function GuildAutoTimeLayer:onEnter()
  self.showGuildAutoTimeLayer = true
end
function GuildAutoTimeLayer:onExit()
  self.showGuildAutoTimeLayer = false
end
function GuildAutoTimeLayer:refreshUI()
  if self._listViewTable then
    self._listViewTable:reloadData()
    return
  end
  local boardWidth = self._rootnode.listView:getContentSize().width
  local boardHeight = self._rootnode.listView:getContentSize().height - listViewDisH
  local function callback(data)
    for k, v in ipairs(self.param) do
      if v.activityTypeId == data.activityTypeId then
        self.param[k] = data
      end
    end
    self:refreshUI()
  end
  local function createFunc(index)
    local item = require("game.guild.guildAutoTime.GuildAutoTimeItem").new()
    return item:create({
      viewWidth = boardWidth,
      data = self.param[index + 1],
      callback = callback
    })
  end
  local function refreshFunc(cell, index)
    cell:refresh(self.param[index + 1])
  end
  self._listViewTable = require("utility.TableViewExt").new({
    size = CCSizeMake(boardWidth, boardHeight),
    direction = kCCScrollViewDirectionVertical,
    createFunc = createFunc,
    refreshFunc = refreshFunc,
    cellNum = #self.param,
    cellSize = CCSizeMake(610, 250)
  })
  self._listViewTable:setPosition(0, 0)
  self._rootnode.listView:addChild(self._listViewTable)
end
function GuildAutoTimeLayer:onExit()
end
return GuildAutoTimeLayer
