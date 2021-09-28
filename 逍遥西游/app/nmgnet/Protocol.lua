local cryptExt = require("cryptext")
local pro_2_func = {}
local last_decode_failed_data
local ProtocolEncryptType = 1
local DesEncryptReady = true
local DHServerKey, DHClientKey
local DesKey = "12345678"
local CheckChallenge
function ProtocolDataEncrypt(data)
  if ProtocolEncryptType == 1 and DesEncryptReady then
    return cryptExt.base64encode(cryptExt.desencode(DesKey, data)), true
  else
    return data, false
  end
end
function ProtocolDataDecrypt(data)
  if ProtocolEncryptType == 1 and DesKey then
    local debase64Data = cryptExt.base64decode(data)
    local len = string.len(debase64Data)
    if len % 8 ~= 0 then
      return nil
    end
    return cryptExt.desdecode(DesKey, debase64Data)
  else
    return data
  end
end
function ProtocolUnpackData(data)
  local ret, data1 = pcall(ProtocolDataDecrypt, data)
  if ret == true and data1 then
    return json.decode(data1)
  end
  print("-->> 解包出错, 需要分包")
  return nil
end
function HadReciveData(data)
  if data == nil then
    printLog("Protocol", "服务器返回的数据为空!")
    return
  end
  local data_ = json.decode(data)
  if last_decode_failed_data ~= nil then
    last_decode_failed_data = nil
  end
  if type(data_[1]) == "number" then
    data_ = netprotocolextrecv.dealPackData(data_)
    if data_ == nil then
      return
    end
  end
  local p = data_.p
  local s = data_.s
  local a = data_.a
  print(string.format("[PROTOCOL]p=%s, s=%s", tostring(p), tostring(s)))
  if p and s then
    local k = p .. "." .. s
    if ProtocolFunc[p] then
      local func_wc = ProtocolFunc[p][PTC_FUNC_WILDCARD]
      if func_wc then
        func_wc(a, p, s)
      end
    end
    local func = pro_2_func[k]
    if func then
      func(a, p, s)
      return
    end
    local d = ProtocolFunc[p]
    if d then
      func = d[s]
    end
    if func == nil then
      local e = netcommand[p]
      if e then
        func = e[s]
        if func then
        end
      end
    else
    end
    if func then
      pro_2_func[k] = func
      func(a, p, s)
    else
      printLog("ERROR", "找不到协议对应的函数[%s.%s]", p, s)
    end
  end
  return true
end
