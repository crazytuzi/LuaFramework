local _M = {}
_M.__index = _M


local retGardenRecord = GlobalHooks.DB.Find("GuildRecord",{})

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

function _M.SubHTML_str(TargetTable)
  local Targetstr = retGardenRecord[TargetTable.recordType].RecordMsg
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
      local rc = Util.GetQualityColorARGB(nameColorIndex[TargetTable.resultNum])
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

return _M
