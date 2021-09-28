local crypt = require("cryptext")
local cryptoprotocal = {
  adapter = nil,
  handshaked = false,
  debug = false
}
local function dprint(...)
  if cryptoprotocal.debug then
    print(...)
  end
end
function cryptoprotocal:send(playerObj, msg)
  error("need imple!")
end
function cryptoprotocal:step1(playerObj, rawMsgdata)
  local modeData = {step = 1}
  playerObj.m_adaptermodeData = modeData
  modeData.challenge = crypt.randomkey()
  self:send(playerObj, modeData.challenge)
  dprint("finish step1: Server->Client challenge", modeData.challenge)
end
function cryptoprotocal:step2(playerObj, rawMsgdata)
  local modeData = playerObj.m_adaptermodeData
  local handshake = rawMsgdata
  modeData.clientkey = handshake
  modeData.step = 2
  dprint("finish step2: Client->Server client key", handshake)
  self:step3(playerObj)
end
function cryptoprotocal:step3(playerObj, rawMsgdata)
  local modeData = playerObj.m_adaptermodeData
  modeData.serverkey = crypt.randomkey()
  modeData.step = 3
  dprint("finish step3: gen server key")
  self:step4(playerObj)
end
function cryptoprotocal:step4(playerObj, rawMsgdata)
  local modeData = playerObj.m_adaptermodeData
  local exchange = crypt.dhexchange(modeData.serverkey)
  self:send(playerObj, exchange)
  modeData.step = 4
  dprint("finish step4: Server->Client server key", exchange)
  self:step5(playerObj)
end
function cryptoprotocal:step5(playerObj, rawMsgdata)
  local modeData = playerObj.m_adaptermodeData
  modeData.secret = crypt.dhsecret(modeData.clientkey, modeData.serverkey)
  modeData.step = 5
  dprint("finish step5: Server/Client secret", modeData.secret)
end
function cryptoprotocal:step6(playerObj, rawMsgdata)
  local rphmac = crypt.base64encode(rawMsgdata)
  local modeData = playerObj.m_adaptermodeData
  local hmac = crypt.hmac64(modeData.challenge, modeData.secret)
  dprint("doing step6", hmac)
  hmac = crypt.base64encode(hmac)
  if rphmac ~= hmac then
    error(string.format("challenge failed: %s | %s", rphmac, hmac))
  end
  modeData.step = 6
  playerObj.m_adaptermodeEnd = true
  dprint("finish step6")
  if self.handshakedcallback then
    self:handshakedcallback(playerObj)
  end
end
function cryptoprotocal:enCrypto(playerObj, rawMsgdata)
  if playerObj.m_adaptermodeEnd then
    local modeData = playerObj.m_adaptermodeData
    return crypt.desencode(modeData.secret, rawMsgdata)
  else
    return rawMsgdata
  end
end
function cryptoprotocal:deCrypto(playerObj, rawMsgdata)
  local modeData = playerObj.m_adaptermodeData
  return crypt.desdecode(modeData.secret, rawMsgdata)
end
function cryptoprotocal:autoStep(playerObj, rawMsgdata)
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
function cryptoprotocal:desencode(deskeyname, data)
  local deskey = crypt.hashkey(deskeyname)
  return crypt.desencode(deskey, data)
end
function cryptoprotocal:desdecode(deskeyname, data)
  local deskey = crypt.hashkey(deskeyname)
  return crypt.desdecode(deskey, data)
end
return cryptoprotocal
