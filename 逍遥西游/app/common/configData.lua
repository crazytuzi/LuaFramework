local ConfigIniFilePath = device.writablePath .. "setting.ini"
local config = {}
function getConfigByName(configName)
  return config[configName]
end
function setConfigData(configName, configValue, isSave)
  if isSave == nil then
    isSave = true
  end
  config[configName] = configValue
  if isSave then
    saveConfigData()
  end
end
function saveConfigData()
  local data = json.encode(config)
  printLog("configData", "saveConfigData:%s", data)
  io.writefile(ConfigIniFilePath, data)
end
function loadConfigData()
  config = {}
  local dataStr = io.readfile(ConfigIniFilePath)
  printLog("ConfigIniFilePath", ":%s", ConfigIniFilePath)
  if dataStr then
    printLog("configData", ":%s", dataStr)
    local d = json.decode(dataStr)
    if type(d) == "table" then
      config = d
    end
  end
end
function setLoginAccountAndPwd(account, pwd)
  local d = {
    account = account,
    pwd = pwd,
    r = string.format("%05da%.05f", math.random(10000, 99999), math.random())
  }
  local cryptoD = crypto.encodeBase64(crypto.encryptXXTEA(json.encode(d), "c21>/23|"))
  setConfigData("logininfo", cryptoD)
end
function getLoginAccountAndPwd()
  local cryptoD = getConfigByName("logininfo")
  if cryptoD then
    cryptoD = crypto.decodeBase64(cryptoD)
    local ds = crypto.decryptXXTEA(cryptoD, "c21>/23|")
    if type(ds) == "string" then
      local d = json.decode(ds)
      if type(d) == "table" then
        return d.account, d.pwd
      end
    end
  end
  return "", ""
end
function setMomoUserId(userID)
  local d = {
    userID = userID,
    r = string.format("%05da%.05f", math.random(10000, 99999), math.random())
  }
  local cryptoD = crypto.encodeBase64(crypto.encryptXXTEA(json.encode(d), "c21>/23|"))
  setConfigData("mmusersinfo", cryptoD)
end
function getMomoUserId()
  local cryptoD = getConfigByName("mmusersinfo")
  if cryptoD then
    cryptoD = crypto.decodeBase64(cryptoD)
    local ds = crypto.decryptXXTEA(cryptoD, "c21>/23|")
    if type(ds) == "string" then
      local d = json.decode(ds)
      if type(d) == "table" then
        return d.userID
      end
    end
  end
  return nil
end
function setLastLoginServerId(serverId)
  local d = {
    serverId = serverId,
    r = string.format("%05da%.05f", math.random(10000, 99999), math.random())
  }
  local cryptoD = crypto.encodeBase64(crypto.encryptXXTEA(json.encode(d), "45sd.s3,"))
  setConfigData("LastLoginServerId", cryptoD)
end
function getLastLoginServerId()
  local cryptoD = getConfigByName("LastLoginServerId")
  if cryptoD then
    cryptoD = crypto.decodeBase64(cryptoD)
    local ds = crypto.decryptXXTEA(cryptoD, "45sd.s3,")
    if type(ds) == "string" then
      local d = json.decode(ds)
      if type(d) == "table" then
        return d.serverId
      end
    end
  end
  return nil
end
function getSyncPlayerTypeFromConfig()
  local syncType = getConfigByName("SyncPlayerType")
  if syncType and type(syncType) == "string" then
    syncType = tonumber(syncType)
  end
  return syncType
end
