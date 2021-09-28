

local _M = {}
_M.__index = _M

local Item = require "Zeus.Model.Item"
local Util = require "Zeus.Logic.Util"
local GdDepotRq = require 'Zeus.Model.GuildDepot'
local Guild = require 'Zeus.Model.Guild'
local retGuildRecord = GlobalHooks.DB.Find("GuildRecord",{})
local retCond = GlobalHooks.DB.Find("GuildCondition", {})

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

function _M.SubHTML_str(TargetTable)
  local Targetstr =retGuildRecord[TargetTable.recordType].RecordMsg
  if not Targetstr then
    return ""
  end

  local timestr = string.format("<f color='ff00d600'>%s</f>",TargetTable.time)

  local strRole1 = ""
  if TargetTable.role1 then
    local rc = GameUtil.GetProColorARGB(TargetTable.role1.pro)
    strRole1 = string.format("<f color='%x'>%s</f>",rc,TargetTable.role1.name)
  end

  local strRole2 = ""
  if TargetTable.role2 then
    local rc = GameUtil.GetProColorARGB(TargetTable.role2.pro)
    strRole2 = string.format("<f color='%x'>%s</f>",rc,TargetTable.role2.name)
  end

  local buildStr = ""
  if TargetTable.build then
    local rc = Util.GetQualityColorARGB(tonumber(1))
    buildStr = string.format("<f color='ff00d600'>%s</f>",TargetTable.build)
  end

  local resultStr = ""
  if TargetTable.resultStr then
    if TargetTable.recordType == 5 then
      local rc = Util.GetQualityColorARGB(tonumber(5-TargetTable.resultNum))
      resultStr = string.format("<f color='%x'>%s</f>",rc,TargetTable.resultStr)
    else
      resultStr = string.format("<f color='ff00d600'>%s</f>",TargetTable.resultStr)
    end
  end

  local itemStr = ""
  if TargetTable.item then
    
    
  
    local rc = Util.GetQualityColorARGB(tonumber(TargetTable.item.qColor))
    itemStr = string.format("<f color='%x'>%s</f>",rc,TargetTable.item.name)
  end

  return string.gsub('<b size="18">'..Targetstr..'</b>','{(%w+)}',{RecordTime=timestr,Role1 = strRole1,Role2 = strRole2,result = resultStr,item = itemStr,build = buildStr})
end

function _M.GetItemIsDepotInterval(equipDetial)
  local ret = GlobalHooks.DB.Find("GuildSetting", {})

  if equipDetial.Qcolor<ret[1].WarehouseMinQ or equipDetial.LevelReq<ret[1].WarehouseMinLv then
    
    return false
  end

  local depotinfo = GdDepotRq.GetDepotInfo()
  local Myinfo = Guild.GetMyInfoFromGuild()
  if Myinfo.job > depotinfo.depotCond.useCond.job then
    
    return false
  end

  if equipDetial.LevelReq<depotinfo.depotCond.minCond.level or equipDetial.LevelReq>depotinfo.depotCond.maxCond.level then
    
    return false
  end

  if equipDetial.Qcolor<depotinfo.depotCond.minCond.qColor or equipDetial.Qcolor>depotinfo.depotCond.maxCond.qColor then
    
    return false
  end

  return true
end

function _M.GetCurUplvIndex(uplv)
  if retCond then
    for k,v in pairs(retCond) do
      if uplv == v.UpLevel then
        return k
      end
    end
    return 1
  end
  return 1
end

function _M.ColseAllGuildUI()
  for i=3300,3323 do
    local node, luaobj = GlobalHooks.FindUI(i, 0)
    if node then
      node:Close()
    end
  end
end

return _M
