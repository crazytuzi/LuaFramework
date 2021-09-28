local netcangku = {}
function netcangku.setItemIntoCangku(i_iid, i_num)
  print("netcangku.setItemIntoCangku")
  NetSend({i_iid = i_iid, i_num = i_num}, "cangku", "P1")
end
function netcangku.getItemFromCangku(i_iid, i_num)
  print("netcangku.getItemFromCangku")
  NetSend({i_iid = i_iid, i_num = i_num}, "cangku", "P2")
end
function netcangku.reqZhengliCangku()
  print("netcangku.reqZhengliCangku")
  NetSend({}, "cangku", "P3")
end
function netcangku.reqExpendCangku()
  print("netcangku.reqExpendCangku")
  NetSend({}, "cangku", "P4")
end
return netcangku
