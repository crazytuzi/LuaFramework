local Lplus = require("Lplus")
local ECObject = require("Object.ECObject")
local ECNPC = require("NPCs.ECNPC")
local ECMatter = require("Object.ECMatter")
local ECDebugHelper = Lplus.Class("ECDebugHelper")
do
  local def = ECDebugHelper.define
  def.static("string", "=>", "string").FormatObjectInfo = function(objId)
    local ECGame = require("Main.ECGame")
    local obj
    if objId == ECGame.Instance().m_HostPlayer.ID then
      obj = ECGame.Instance().m_HostPlayer
    else
      obj = ECGame.Instance().m_CurWorld:FindObject(objId)
    end
    if obj then
      local specificInfo = ""
      local type = "invalid"
      if obj:is(ECNPC) then
        specificInfo = ", tid: " .. obj.InfoData.Tid
      elseif obj:is(ECMatter) then
        specificInfo = ", tid: " .. obj.MatterInfo.tid
      end
      local pos = obj:GetPos()
      return ([[
id: %s,new_id: %d
name: %s, pos: (%.1f, %.1f, %.1f), scene: %d, type: %s, camp: 0x%08x%s]]):format(LuaUInt64.ToString(objId), obj.new_id, obj.InfoData.Name, pos.x, pos.y, pos.z, ECGame.Instance().m_curSceneId, tostring(obj:getTypeTable()), obj.CampMask, specificInfo)
    else
      return "invalid"
    end
  end
  def.static("userdata", "=>", "string").FormatGameObjectInfo = function(gameObj)
    local strBuilder = {}
    while gameObj do
      table.insert(strBuilder, 1, gameObj.name)
      gameObj = gameObj.transform.parent
    end
    return table.concat(strBuilder, ".")
  end
end
return ECDebugHelper.Commit()
