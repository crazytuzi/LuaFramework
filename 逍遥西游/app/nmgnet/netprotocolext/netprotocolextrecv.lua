local netprotocolextrecv = {}
function netprotocolextrecv.dealPackData(data)
  local pronum = tonumber(data[1])
  local func = netprotocolextrecv.func[pronum]
  if func then
    return func(data)
  else
    print(string.format("[ERROR]protocol {%s} does not found deal func", tostring(pronum)))
    return nil
  end
end
function netprotocolextrecv.ptc_map(data)
  print("netprotocolextrecv.ptc_map:")
  dump(data, "data")
  local mapId = data[2]
  local x = data[3]
  local y = data[4]
  local pid = data[5]
  local isforce = data[6]
  local flag = data[7]
  local i_h = 0
  if mapId == 0 then
    i_h = 1
  end
  local t_loc
  if x ~= nil and y ~= nil then
    t_loc = {x, y}
  end
  local data_ = {
    p = "scene",
    s = "P1",
    a = {
      i_pid = pid,
      i_scene = mapId,
      t_loc = t_loc,
      i_flag = flag,
      i_h = i_h,
      i_f = isforce
    }
  }
  return data_
end
netprotocolextrecv.func = {
  [1] = netprotocolextrecv.ptc_map
}
return netprotocolextrecv
