local Lplus = require("Lplus")
local DirVersionXMLHelper = Lplus.Class("DirVersionXMLHelper")
local SLAXML = require("Utility.SLAXML.slaxdom")
local def = DirVersionXMLHelper.define
local versionxmldoc, doctime
local DOC_EXPIRE_TIME = 300
def.static("=>", "table").GetXmlDoc = function()
  local versionXML = GameUtil.GetDirVersion()
  if versionXML == nil or versionXML == "" then
    return nil
  end
  if versionxmldoc and doctime and math.abs(os.time() - doctime) < DOC_EXPIRE_TIME then
    return versionxmldoc
  end
  local doc = SLAXML:dom(versionXML)
  if doc == nil then
    return nil
  end
  versionxmldoc = doc
  doctime = os.time()
  return doc
end
def.static("=>", "string").GetXmlString = function()
  local SLAXML = require("Utility.SLAXML.slaxdom")
  local versionXML = GameUtil.GetDirVersion() or ""
  return versionXML
end
return DirVersionXMLHelper.Commit()
