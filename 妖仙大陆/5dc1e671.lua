

local _M = {}
_M.__index = _M

local TechInfo = nil
local Contribution = 0

local guild = require 'Zeus.Model.Guild'

local function ChangeSkillList(skillinfo)
  for k,v in pairs(TechInfo.skillList) do
    if v.id == skillinfo.id then
      TechInfo.skillList[k] = skillinfo
      return
    end
  end
end

local function ChangeProductList(id)
  if id then
    for k,v in pairs(TechInfo.productList) do
      if id==v.id then
        v.state = 2
        return
      end
    end
  end
end

function _M.upgradeGuildSkillRequest(skillId,cb) 
  Pomelo.GuildTechHandler.upgradeGuildSkillRequest(skillId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      ChangeSkillList(msg.s2c_skillInfo)
      Contribution = msg.s2c_contribution or Contribution
      guild.setContribution(Contribution)
      EventManager.Fire("Event.UI.ChangeHallUI",{Contribute = Contribution})
      cb()
    end
  end)
end














function _M.getGuildTechInfoRequest(cb)
  Pomelo.GuildTechHandler.getGuildTechInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      TechInfo = msg.s2c_techInfo
      Contribution = msg.s2c_contribution or Contribution
      cb()
    end
  end)
end

function _M.upgradeGuildTechRequest(cb)
  Pomelo.GuildTechHandler.upgradeGuildTechRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      TechInfo.level = TechInfo.level +1
      guild.setFouns(msg.s2c_fund)
      EventManager.Fire('Guild.TechUpLevel',{level = TechInfo.level})
      EventManager.Fire("Event.UI.ChangeHallUI",{fund = msg.s2c_fund})
      cb()
    end
  end)
end

function _M.upgradeGuildBuffRequest(cb)
  Pomelo.GuildTechHandler.upgradeGuildBuffRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      TechInfo.buffInfo = msg.s2c_buffInfo
      EventManager.Fire("Event.UI.ChangeHallUI",{fund = msg.s2c_fund})
      guild.setFouns(msg.s2c_fund)
      cb()
    end
  end)
end

function _M.GetMyTechInfo()
  return TechInfo
end

function _M.GetMycontribution()
  return Contribution
end

function GlobalHooks.DynamicPushs.TechRefreshPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    
    if msg.type == 1 then
      EventManager.Fire('Guild.TechUpLevel',{type = 1})
    elseif msg.type == 2 then
      if TechInfo then
        TechInfo.level = msg.level
        EventManager.Fire('Guild.TechUpLevel',{type = 2})
      end
    end
  end
end

function _M.InitNetWork()
  Pomelo.GuildTechHandler.guildTechRefreshPush(GlobalHooks.DynamicPushs.TechRefreshPush)
end

function _M.initial()

end

return _M
