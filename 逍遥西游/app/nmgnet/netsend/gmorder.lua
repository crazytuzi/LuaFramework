local gm = {}
function gm.order(orderStr)
  NetSend({s_gm = orderStr}, "gm", "P1")
end
return gm
