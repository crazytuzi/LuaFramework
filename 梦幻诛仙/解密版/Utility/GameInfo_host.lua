local Lplus = require("Lplus")
local GameInfo = require("Utility.GameInfo")
local TableProxy = require("Utility.TableProxy")
local ECHostPlayer = Lplus.ForwardDeclare("ECHostPlayer")
local l_hostplayer
local HostProperty = {}
do
  local host = HostProperty
  function host.name()
    if l_hostplayer then
      return l_hostplayer.InfoData.Name
    else
      return ""
    end
  end
  function host.id()
    if l_hostplayer then
      return l_hostplayer.ID
    else
      return ZeroUInt64
    end
  end
  function host.level()
    if l_hostplayer then
      return l_hostplayer.InfoData.Lv
    else
      return 0
    end
  end
  function host.gender()
    if l_hostplayer then
      return l_hostplayer.InfoData.Gender
    else
      return 0
    end
  end
  function host.is_male()
    if l_hostplayer then
      return l_hostplayer.InfoData.Gender == 0
    else
      return true
    end
  end
  function host.profession()
    if l_hostplayer then
      return l_hostplayer.InfoData.Prof
    else
      return 0
    end
  end
  function host.portrait()
    if l_hostplayer then
      local isMale = l_hostplayer.InfoData.Gender == 0
      return isMale and 624 or 623
    else
      return 0
    end
  end
  function host.icon()
    if l_hostplayer then
      local isMale = l_hostplayer.InfoData.Gender == 0
      return isMale and 1532 or 1028
    else
      return 0
    end
  end
  function host.fight_data()
    if l_hostplayer then
      return l_hostplayer.InfoData.FightData
    else
      return nil
    end
  end
end
local HostMethod = Lplus.Class()
do
  local def = HostMethod.define
  def.static("number", "=>", "boolean").has_skill = function(skill_id)
    if l_hostplayer then
      local userskill = l_hostplayer:GetUserSkill(skill_id)
      if userskill then
        return true
      end
    end
    return false
  end
  def.static("number", "=>", "number").skill_level = function(skill_id)
    if l_hostplayer then
      local userskill = l_hostplayer:GetUserSkill(skill_id)
      if userskill then
        return userskill:GetLevel()
      end
    end
    return 0
  end
  def.static("number", "=>", "boolean").has_task = function(task_id)
    local ECTaskInterface = require("Task.ECTaskInterface")
    return ECTaskInterface.HasTask(task_id)
  end
  def.static("number", "=>", "number").faction_reputation = function(reputation_id)
    if l_hostplayer then
      return l_hostplayer:GetFactionReputation(reputation_id)
    end
    return 0
  end
end
HostMethod.Commit()
local l_hostInfo = TableProxy.createReadonlyPropertyProxy(HostProperty, HostMethod)
GameInfo.set("host", l_hostInfo)
local GameInfo_host = Lplus.Class()
do
  local def = GameInfo_host.define
  def.static(ECHostPlayer).setHostPlayer = function(hostplayer)
    l_hostplayer = hostplayer
  end
end
return GameInfo_host.Commit()
