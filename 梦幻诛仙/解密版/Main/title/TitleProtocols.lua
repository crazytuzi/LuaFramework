local TitleProtocols = {}
local TitleInterface = require("Main.title.TitleInterface")
local titleInterface = TitleInterface.Instance()
local STitleNormalInfo = require("netio.protocol.mzm.gsp.title.STitleNormalInfo")
local PersonalHelper = require("Main.Chat.PersonalHelper")
function TitleProtocols.OnSChangePropertyReq(p)
  titleInterface:_SetPro2appellationId(p.appellationId)
  Event.DispatchEvent(ModuleId.TITLE, gmodule.notifyId.title.ActivePropertyChanged, {
    p.appellationId
  })
end
function TitleProtocols.OnSChangeTitleOrAppellationReq(p)
  if p.changeType == STitleNormalInfo.APPELLATION then
    titleInterface:_SetActiveAppellation(p.changeId)
    Event.DispatchEvent(ModuleId.TITLE, gmodule.notifyId.title.ActiveAppellationChanged, {
      p.changeId
    })
    local appellationCfg = TitleInterface.GetAppellationCfg(p.changeId)
    local personAward = {}
    if appellationCfg ~= nil then
      local appArgs = titleInterface:GetAppellationArgs(p.changeId)
      local strAppellation = appellationCfg.appellationName
      if appArgs ~= nil and #appArgs > 0 then
        strAppellation = string.format(appellationCfg.appellationName, unpack(appArgs))
      end
      table.insert(personAward, {
        PersonalHelper.Type.Text,
        string.format(textRes.Title[25], strAppellation)
      })
    else
      table.insert(personAward, {
        PersonalHelper.Type.Text,
        textRes.Title[27]
      })
    end
    PersonalHelper.CommonTableMsg(personAward)
  elseif p.changeType == STitleNormalInfo.TITLE then
    titleInterface:_SetActiveTitle(p.changeId)
    Event.DispatchEvent(ModuleId.TITLE, gmodule.notifyId.title.ActiveTitleChanged, {
      p.changeId
    })
    local titleCfg = TitleInterface.GetTitleCfg(p.changeId)
    local personAward = {}
    if titleCfg ~= nil then
      table.insert(personAward, {
        PersonalHelper.Type.Text,
        string.format(textRes.Title[26], titleCfg.titleName)
      })
    else
      table.insert(personAward, {
        PersonalHelper.Type.Text,
        textRes.Title[28]
      })
    end
    PersonalHelper.CommonTableMsg(personAward)
  end
end
function TitleProtocols.OnSChangeAppellationArgs(p)
  local activeAppellationID = titleInterface:GetActiveAppellation()
  titleInterface:SetAppellationArgs(p.changeId, p.appArgs)
  Event.DispatchEvent(ModuleId.TITLE, gmodule.notifyId.title.ActiveAppellationChanged, {
    p.changeId
  })
  if p.changeId == activeAppellationID then
    local appellationCfg = TitleInterface.GetAppellationCfg(p.changeId)
    if appellationCfg ~= nil then
      local appArgs = titleInterface:GetAppellationArgs(p.changeId)
      local strAppellation = appellationCfg.appellationName
      if appArgs ~= nil and #appArgs > 0 then
        strAppellation = string.format(appellationCfg.appellationName, unpack(appArgs))
      end
      if strAppellation ~= appellationCfg.appellationName then
        local personAward = {
          {
            PersonalHelper.Type.Text,
            string.format(textRes.Title[35], strAppellation)
          }
        }
        PersonalHelper.CommonTableMsg(personAward)
      end
    end
  end
end
function TitleProtocols.OnSGetNewTitleOrAppellation(p)
  titleInterface:SetTimeOutValue(p.changeId, p.timeout)
  if p.changeType == STitleNormalInfo.APPELLATION then
    titleInterface:SetAppellationArgs(p.changeId, p.appArgs)
    titleInterface:_AddOwnAppellation(p.changeId)
    Event.DispatchEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnAppellationChanged, {
      p.changeId
    })
    local appellationCfg = TitleInterface.GetAppellationCfg(p.changeId)
    local strAppellation = appellationCfg.appellationName
    local appArgs = p.appArgs
    if appArgs ~= nil and #appArgs > 0 then
      strAppellation = string.format(appellationCfg.appellationName, unpack(appArgs))
    end
    local personAward = {
      {
        PersonalHelper.Type.Text,
        string.format(textRes.Title[10], strAppellation)
      }
    }
    PersonalHelper.CommonTableMsg(personAward)
  elseif p.changeType == STitleNormalInfo.TITLE then
    titleInterface:_AddOwnTitle(p.changeId)
    Event.DispatchEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnTitleChanged, {
      p.changeId
    })
    local titleCfg = TitleInterface.GetTitleCfg(p.changeId)
    local personAward = {
      {
        PersonalHelper.Type.Text,
        string.format(textRes.Title[11], titleCfg.titleName)
      }
    }
    PersonalHelper.CommonTableMsg(personAward)
  end
end
function TitleProtocols.OnSInitTitleOrAppellation(p)
  titleInterface._ownTitle = {}
  for k, v in pairs(p.ownTitle) do
    table.insert(titleInterface._ownTitle, v.titleId)
    titleInterface:SetTimeOutValue(v.titleId, v.timeout)
  end
  titleInterface._ownAppellation = {}
  for k, v in pairs(p.ownAppellation) do
    table.insert(titleInterface._ownAppellation, v.appellationId)
    titleInterface:SetTimeOutValue(v.appellationId, v.timeout)
    titleInterface:SetAppellationArgs(v.appellationId, v.appArgs)
  end
  titleInterface:_SetActiveAppellation(p.activeAppellation)
  titleInterface:_SetActiveTitle(p.activeTitle)
  titleInterface:_SetPro2appellationId(p.pro2appellationId)
  Event.DispatchEvent(ModuleId.TITLE, gmodule.notifyId.title.InfoChanged, nil)
end
function TitleProtocols.OnSRemoveTitleOrAppellation(p)
  titleInterface._timeoutTable[p.changeId] = nil
  if p.changeType == STitleNormalInfo.APPELLATION then
    local ownAppellation = {}
    for k, v in pairs(titleInterface._ownAppellation) do
      if v ~= p.changeId then
        table.insert(ownAppellation, v)
      end
    end
    titleInterface._ownAppellation = ownAppellation
    Event.DispatchEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnAppellationDeleted, {
      p.changeId
    })
    local appellationCfg = TitleInterface.GetAppellationCfg(p.changeId)
    local appArgs = titleInterface:GetAppellationArgs(p.changeId)
    local strAppellation = appellationCfg.appellationName
    if appArgs ~= nil and #appArgs > 0 then
      strAppellation = string.format(appellationCfg.appellationName, unpack(appArgs))
    end
    local personAward = {
      {
        PersonalHelper.Type.Text,
        string.format(textRes.Title[20], strAppellation)
      }
    }
    PersonalHelper.CommonTableMsg(personAward)
  elseif p.changeType == STitleNormalInfo.TITLE then
    local ownTitle = {}
    for k, v in pairs(titleInterface._ownTitle) do
      if v ~= p.changeId then
        table.insert(ownTitle, v)
      end
    end
    titleInterface._ownTitle = ownTitle
    Event.DispatchEvent(ModuleId.TITLE, gmodule.notifyId.title.OwnTitleDeleted, {
      p.changeId
    })
    local titleID = titleInterface:GetActiveTitle()
    local titleCfg = TitleInterface.GetTitleCfg(p.changeId)
    Toast(string.format(textRes.Title[21], titleCfg.titleName))
    local personAward = {
      {
        PersonalHelper.Type.Text,
        string.format(textRes.Title[21], titleCfg.titleName)
      }
    }
    PersonalHelper.CommonTableMsg(personAward)
  end
end
function TitleProtocols.OnSTitleNormalInfo(p)
end
return TitleProtocols
