local crypt = require("cryptext")
local cryptoprotocal4c = {
  adapter = nil,
  handshaked = false,
  debug = false
}
local function dprint(...)
  if cryptoprotocal4c.debug then
    print(...)
  end
end
function cryptoprotocal4c:send(playerObj, msg)
  error("need imple!")
end
function cryptoprotocal4c:step1(playerObj, rawMsgdata)
  local modeData = {step = 1}
  playerObj.m_adaptermodeData = modeData
  modeData.challenge = rawMsgdata
  dprint("finish step1: Server->Client challenge", rawMsgdata)
  self:step2(playerObj, rawMsgdata)
end
function cryptoprotocal4c:step2(playerObj, rawMsgdata)
  local modeData = playerObj.m_adaptermodeData
  modeData.clientkey = crypt.randomkey()
  local exchange = crypt.dhexchange(modeData.clientkey)
  self:send(playerObj, exchange)
  modeData.step = 2
  dprint("finish step2: Client->Server client key", exchange)
end
function cryptoprotocal4c:step3(playerObj, rawMsgdata)
  local modeData = playerObj.m_adaptermodeData
  modeData.step = 3
  dprint("finish step3: gen server key")
  self:step4(playerObj, rawMsgdata)
end
function cryptoprotocal4c:step4(playerObj, rawMsgdata)
  local modeData = playerObj.m_adaptermodeData
  modeData.serverkey = rawMsgdata
  modeData.step = 4
  dprint("finish step4: Server->Client server key", rawMsgdata)
  self:step5(playerObj, rawMsgdata)
end
function cryptoprotocal4c:step5(playerObj, rawMsgdata)
  local modeData = playerObj.m_adaptermodeData
  modeData.secret = crypt.dhsecret(modeData.serverkey, modeData.clientkey)
  modeData.step = 5
  dprint("finish step5: Server/Client secret", modeData.secret)
  self:step6(playerObj, rawMsgdata)
end
function cryptoprotocal4c:step6(playerObj, rawMsgdata)
  local modeData = playerObj.m_adaptermodeData
  local hmac = crypt.hmac64(modeData.challenge, modeData.secret)
  self:send(playerObj, hmac)
  modeData.step = 6
  playerObj.m_adaptermodeEnd = true
  dprint("finish step6", hmac)
  if self.handshakedcallback then
    self:handshakedcallback(playerObj)
  end
end
function cryptoprotocal4c:enCrypto(playerObj, rawMsgdata)
  if playerObj.m_adaptermodeEnd then
    local modeData = playerObj.m_adaptermodeData
    return crypt.desencode(modeData.secret, rawMsgdata)
  else
    return rawMsgdata
  end
end
function cryptoprotocal4c:deCrypto(playerObj, rawMsgdata)
  local modeData = playerObj.m_adaptermodeData
  return crypt.desdecode(modeData.secret, rawMsgdata)
end
function cryptoprotocal4c:autoStep(playerObj, rawMsgdata)
  local modeData = playerObj.m_adaptermodeData
  if not modeData then
    self:step1(playerObj, rawMsgdata)
  elseif modeData.step == 1 then
    self:step2(playerObj, rawMsgdata)
  elseif modeData.step == 2 then
    self:step3(playerObj, rawMsgdata)
  elseif modeData.step == 3 then
    self:step4(playerObj, rawMsgdata)
  elseif modeData.step == 4 then
    self:step5(playerObj, rawMsgdata)
  elseif modeData.step == 5 then
    self:step6(playerObj, rawMsgdata)
  end
end
function cryptoprotocal4c:desencode(deskeyname, data)
  local deskey = crypt.hashkey(deskeyname)
  return crypt.desencode(deskey, data)
end
function cryptoprotocal4c:desdecode(deskeyname, data)
  local deskey = crypt.hashkey(deskeyname)
  return crypt.desdecode(deskey, data)
end
return cryptoprotocal4c
