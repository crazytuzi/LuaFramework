local netprotocolextsend = {}
function netprotocolextsend.scene(mapId, x, y, force, flag)
  local pack
  if mapId == 0 then
    pack = {1, 0}
  else
    if force == nil then
      force = 0
    end
    pack = {
      1,
      mapId,
      x,
      y,
      force,
      flag
    }
  end
  NetSendExt(pack)
end
return netprotocolextsend
