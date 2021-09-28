local isTestAutoRegAndLogin = false
local selServerId = "ucltt_ios_1"
local test_account = device.getOpenUDID()
local ext_data = ""
local regTimes = 0
local test_pwd = "111111"
local TestAutoRegAndLogin = class("TestAutoRegAndLogin")
function TestAutoRegAndLogin:ctor()
  if isTestAutoRegAndLogin then
    MessageEventExtend.extend(self)
    self:ListenMessage(MsgID_Connect)
    local roleIdList = {
      11001,
      11006,
      12001,
      12006,
      13001,
      13008
    }
    self.m_RoleTypeId = roleIdList[math.random(1, #roleIdList)]
    self.m_CreateRoleHandler = nil
    function device.showAlert(...)
    end
  end
end
function TestAutoRegAndLogin:isTestMode()
  return isTestAutoRegAndLogin
end
function TestAutoRegAndLogin:OnMessage(msgSID, ...)
  if isTestAutoRegAndLogin ~= true then
    return
  end
  local arg = {
    ...
  }
  if msgSID == MsgID_RegResult then
    if arg[1] == true then
      self:RegSucceed()
    else
      self:startReg()
    end
  elseif msgSID == MsgID_LoginResult then
    print("[TestAutoRegAndLogin]MsgID_LoginResult 登录成功 :")
    dump(arg, "arg")
    if arg[1] == LOGIN_SUCCEED then
    else
      self:startReg()
    end
  elseif msgSID == MsgID_DataServer_ConnSucceed then
    print("\n 链接数据中心成功， \n")
    self:DetectLogin()
  elseif msgSID == MsgID_HadGetServerList then
    self:LoginSucceed()
  elseif msgSID == MsgID_HadGetRoleInfoFromSvr then
    print("[TestAutoRegAndLogin]MsgID_HadGetRoleInfoFromSvr 获取到角色列表 :")
    if arg[1] == 0 then
      self:createNewRole()
    elseif self.m_CreateRoleHandler ~= nil then
      scheduler.unscheduleGlobal(self.m_CreateRoleHandler)
      self.m_CreateRoleHandler = nil
    end
  end
end
function TestAutoRegAndLogin:DetectLogin()
  print("=-==>>[TestAutoRegAndLogin]DetectLogin:", isTestAutoRegAndLogin)
  if isTestAutoRegAndLogin ~= true then
    return
  end
  scheduler.performWithDelayGlobal(function()
    local a, p = getLoginAccountAndPwd()
    print("[TestAutoRegAndLogin]-->>a, p:", a, p)
    if a and p then
      g_DataMgr:loginToDataServerWithNmg(a, p)
    else
      self:startReg()
    end
  end, 1)
end
function TestAutoRegAndLogin:startReg()
  if regTimes > 5 then
    return
  end
  test_account = test_account .. ext_data
  ext_data = ext_data .. "O"
  regTimes = regTimes + 1
  setLoginAccountAndPwd(test_account, test_pwd)
  g_DataMgr:registerToDataServerWithNmg(test_account, test_pwd)
end
function TestAutoRegAndLogin:LoginSucceed()
  g_DataMgr:LoginToServer(selServerId)
end
function TestAutoRegAndLogin:RegSucceed()
  self:DetectLogin()
end
function TestAutoRegAndLogin:_RandomName()
  if math.random(1, 2) == 1 then
    return GetRandomName_Male()
  else
    return GetRandomName_Female()
  end
end
function TestAutoRegAndLogin:createNewRole()
  print("createNewRole")
  if self.m_CreateRoleHandler == nil then
    self.m_CreateRoleHandler = scheduler.scheduleGlobal(function()
      print("---->> 重新创建角色")
      g_NetConnectMgr:ConnectSvrAndCreatRole(self.m_RoleTypeId, self:_RandomName(), g_ServerData.m_ServerRoleNum + 1)
    end, 2)
  end
end
g_TestAutoRegAndLogin = TestAutoRegAndLogin.new()
