gamereset = {}
gamereset.__resetFuncList = {}
function gamereset.registerResetFunc(func)
  local funcList = gamereset.__resetFuncList
  funcList[#funcList + 1] = func
end
function gamereset.resetAll(reload)
  g_WarAiInsList = {}
  local cnt = 0
  for _, func in pairs(gamereset.__resetFuncList) do
    if func then
      cnt = cnt + 1
      func(reload)
    end
  end
  print(string.format("----->>>执行清理函数%d个", cnt))
  if _gamelogRefresh ~= nil then
    _gamelogRefresh()
  end
end
gamereset.__resetFuncList_Reconnect = {}
function gamereset.registerResetFuncForReconnect(func)
  local funcList = gamereset.__resetFuncList_Reconnect
  funcList[#funcList + 1] = func
end
function gamereset.resetAllForReconnect()
  local cnt = 0
  for _, func in pairs(gamereset.__resetFuncList_Reconnect) do
    if func then
      cnt = cnt + 1
      func()
    end
  end
  print(string.format("---resetAllForReconnect-->>>执行清理函数%d个", cnt))
end
