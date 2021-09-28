local nettest = {}
function nettest.echo(param, ptc_main, ptc_sub)
  print([[


--------------->>>>>>>>>>>>>>>>>>>>>>]])
  print("nettest.setPvpBaseInfo:", param, ptc_main, ptc_sub)
end
function nettest.testLongTextPro()
  local dataTable = {}
  for i = 1, 40960 do
    dataTable[i] = math.random(0, 9)
  end
  s = table.concat(dataTable, "")
  local data = {}
  data.str = s
  for i = 1, 10 do
    NetSend(data, S2C_Test, "echo")
  end
end
return nettest
