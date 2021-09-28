local StartTestNetSend = function()
  NetSend({
    a = 1,
    b = 99.9,
    c = "c"
  }, "ctest", "echo")
end
local StartTestNetConn = function()
  local ConnectListener = function(conresult)
    print("==========>> 连接结果:", conresult)
    if conresult == NMGNET_STATUS_SUCCEED then
    elseif conresult == NMGNET_STATUS_FAILED then
    elseif conresult == NMGNET_STATUS_LOST then
    end
  end
  NetConn(ConnectListener)
end
local testProtocol = function()
  local data = json.encode({
    p = S2C_LOGIN,
    s = S2C_LOGIN_REG,
    a = {
      a = 1,
      b = 99.9,
      c = "c"
    }
  })
  print("data=:", data)
  HadReciveData(data)
end
function testNet(nodeObj)
  local __luaSocketLabel = ui.newTTFLabelMenuItem({
    text = "lua socket connect",
    size = 32,
    x = display.cx,
    y = display.top - 32,
    listener = StartTestNetConn
  })
  local __luaSocket1000Label = ui.newTTFLabelMenuItem({
    text = "testProtocol",
    size = 32,
    x = display.cx,
    y = display.top - 64,
    listener = testProtocol
  })
  local test_netconn = ui.newTTFLabelMenuItem({
    text = "test register",
    size = 32,
    x = display.cx,
    y = display.top - 96,
    listener = function()
      NetSend("test test", S2C_LOGIN, S2C_LOGIN_REG)
    end
  })
  local test_common = ui.newTTFLabelMenuItem({
    text = "test login",
    size = 32,
    x = display.cx,
    y = display.top - 128,
    listener = function()
      NetSend("test test", S2C_LOGIN, S2C_LOGIN_SIGN)
    end
  })
  nodeObj:addChild(ui.newMenu({
    __luaSocketLabel,
    __luaSocket1000Label,
    test_netconn,
    test_common
  }))
end
