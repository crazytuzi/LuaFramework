ArchiveExtend = {}
function ArchiveExtend.extend(object, savePath, saveKeys, xxteaKey)
  object.m_AE_SavePath = savePath
  object.m_AE_SaveKeys = saveKeys
  object.m_AE_XxteaKeys = xxteaKey
  function object:_ae_getSaveData()
    local saveDataDict = {}
    for k, v in pairs(object.m_AE_SaveKeys) do
      saveDataDict[v] = object[v]
    end
    return json.encode(saveDataDict)
  end
  function object:_ae_setSaveData(dataStr)
    print("==>object:_ae_setSaveData,dataStr:", dataStr)
    dataStr = crypto.decodeBase64(dataStr) or ""
    dataStr = crypto.decryptXXTEA(dataStr, object.m_AE_XxteaKeys)
    print("==>object:_ae_setSaveData,dataStr:", dataStr)
    if dataStr == nil then
      dataStr = ""
    end
    saveDataDict = json.decode(dataStr) or {}
    for k, v in pairs(saveDataDict) do
      object[k] = v
    end
  end
  function object:SaveArchive()
    local dataStr = object:_ae_getSaveData()
    print("dataStr:" .. dataStr)
    dataStr = crypto.encryptXXTEA(dataStr, object.m_AE_XxteaKeys)
    dataStr = crypto.encodeBase64(dataStr)
    io.writefile(object.m_AE_SavePath, dataStr, "wb")
  end
  function object:LoadArchive()
    print([[

ArchiveExtend:LoadArchive---->]])
    print("存档位置:" .. object.m_AE_SavePath)
    local dataStr
    local file = io.open(object.m_AE_SavePath, "rb")
    if file then
      dataStr = file:read("*a")
      io.close(file)
    end
    if dataStr == nil then
      print("Read File Failed = " .. object.m_AE_SavePath)
      object:SaveArchive()
      return false
    else
      print("Load Archive Succeed")
      object:_ae_setSaveData(dataStr)
      return true
    end
  end
end
return ArchiveExtend
