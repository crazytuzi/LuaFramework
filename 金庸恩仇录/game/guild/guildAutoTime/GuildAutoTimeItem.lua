local GuildAutoTimeItem = class("GuildAutoTimeItem", function()
  return CCTableViewCell:new()
end)
local format_time = function(t)
  local hour = math.floor(t / 60)
  if hour < 10 then
    hour = "0" .. hour or hour
  end
  local min = t % 60
  if min < 10 then
    min = "0" .. min or min
  end
  local str = hour .. ":" .. min
  return str, hour, min
end
function GuildAutoTimeItem:count_time()
  local hour = tonumber(self._rootnode.guild_hour:getString())
  local min = tonumber(self._rootnode.guild_min:getString())
  return hour * 60 + min
end
function GuildAutoTimeItem:create(param)
  self.callback = param.callback
  local proxy = CCBProxy:create()
  self._rootnode = {}
  local node = CCBuilderReaderLoad("guild/guild_guildAutoTime_item.ccbi", proxy, self._rootnode)
  node:setPosition(param.viewWidth / 2, 0)
  self:addChild(node)
  self._rootnode.hourBG:addHandleOfControlEvent(function(eventName, sender)
    local param = {}
    param.title = common:getLanguageString("@contentautosettinghour")
    param.limitNum = 23
    param.had = tonumber(self._rootnode.guild_hour:getString())
    function param.listener(num)
      if num < 10 then
        num = tostring(0) .. num
      end
      self._rootnode.guild_hour:setString(num)
    end
    local popup = require("game.guild.guildAutoTime.GuildAutoTimeChoose").new(param)
    popup:setPositionY(0)
    display.getRunningScene():addChild(popup, 1000000)
  end, CCControlEventTouchUpInside)
  self._rootnode.minBG:addHandleOfControlEvent(function(eventName, sender)
    local param = {}
    param.title = common:getLanguageString("@contentautosettingmin")
    param.limitNum = 50
    param.ismin = true
    param.had = tonumber(self._rootnode.guild_min:getString())
    function param.listener(num)
      if num < 10 then
        num = tostring(0) .. num
      end
      self._rootnode.guild_min:setString(num)
    end
    local popup = require("game.guild.guildAutoTime.GuildAutoTimeChoose").new(param)
    popup:setPositionY(0)
    display.getRunningScene():addChild(popup, 1000000)
  end, CCControlEventTouchUpInside)
  self._rootnode.openBtn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    local autoTime = self:count_time()
    local str, hour, min = format_time(autoTime)
    local lbl1 = ResMgr.createOutlineMsgTTF({
      text = common:getLanguageString("@contentautosettingconfirm1"),
      color = ccc3(139, 69, 19)
    })
    local lbl2 = ResMgr.createOutlineMsgTTF({
      text = common:getLanguageString("@contentautosettingconfirm2", str),
      color = ccc3(0, 255, 0)
    })
    local lbl3 = ResMgr.createOutlineMsgTTF({
      text = common:getLanguageString("@contentautosettingconfirm3"),
      color = ccc3(255, 0, 0)
    })
    local msgBox = require("utility.MsgBoxEx").new({
      resTable = {
        {lbl1},
        {lbl2},
        {lbl3}
      },
      confirmFunc = function(msgBox)
        local param = {}
        param.id = self.param.activityId
        param.time = self:count_time()
        function param.callback(data)
          if data.err ~= "" then
            show_tip_label(data_error_error[data.errCode].prompt)
            return
          end
          if self.callback then
            self.callback(data.rtnObj)
          end
          self:refresh(data.rtnObj)
        end
        GameRequest.Guild.setTimeState(param)
        msgBox:removeSelf()
      end,
      closeFunc = function(msgBox)
        msgBox:removeSelf()
      end,
      backFunc = function(msgBox)
        msgBox:removeSelf()
      end
    })
    game.runningScene:addChild(msgBox, 1000000)
  end, CCControlEventTouchUpInside)
  self._rootnode.cancelBtn:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    local param = {}
    param.id = self.param.activityId
    function param.callback(data)
      if data.err ~= "" then
        show_tip_label(data_error_error[data.errCode].prompt)
        return
      end
      if self.callback then
        self.callback(data.rtnObj)
      end
      self:refresh(data.rtnObj)
    end
    GameRequest.Guild.cancelAutoState(param)
  end, CCControlEventTouchUpInside)
  self:refresh(param.data)
  return self
end
function GuildAutoTimeItem:refresh(param)
  self.param = param
  self._rootnode.title_lbl:setString(param.name)
  self._rootnode.guild_titletext:setString(common:getLanguageString("@contentAutoqinglong", param.name))
  self._rootnode.guild_name:setString(common:getLanguageString("@contentqinglongtime", param.name))
  if param.setUp == 1 then
    self._rootnode.openBtn:setEnabled(false)
    self._rootnode.cancelBtn:setEnabled(true)
  else
    self._rootnode.openBtn:setEnabled(true)
    self._rootnode.cancelBtn:setEnabled(false)
  end
  if param.autoTime == -1 then
    self._rootnode.guild_is_set:setColor(ccc3(255, 0, 0))
    self._rootnode.guild_is_set:setString(common:getLanguageString("contentcancelAuto"))
    self._rootnode.guild_min:setString("00")
    self._rootnode.guild_hour:setString("00")
  else
    self._rootnode.guild_is_set:setColor(ccc3(78, 143, 0))
    local str, hour, min = format_time(param.autoTime)
    self._rootnode.guild_is_set:setString(str)
    self._rootnode.guild_min:setString(min)
    self._rootnode.guild_hour:setString(hour)
  end
  if param.setUp == 1 and param.autoTime == -1 then
    self._rootnode.openBtn:setEnabled(false)
    self._rootnode.cancelBtn:setEnabled(false)
  end
  local str = ""
  if param.activityStatus == 1 then
    self._rootnode.guild_is_open:setColor(ccc3(255, 0, 0))
    if param.activityTypeId == 1 then
      str = common:getLanguageString("@contentshaokaonotbegin")
    elseif param.activityTypeId == 2 then
      str = common:getLanguageString("contentqinglongnotbegin")
    end
  else
    self._rootnode.guild_is_open:setColor(ccc3(78, 143, 0))
    if param.activityTypeId == 1 then
      str = common:getLanguageString("@contentshaokaoisover")
    elseif param.activityTypeId == 2 then
      str = common:getLanguageString("@contentqinglongisover")
    end
  end
  self._rootnode.guild_is_open:setString(str)
  alignNodesOneByOne(self._rootnode.guild_name, self._rootnode.guild_is_set, 0)
end
return GuildAutoTimeItem
