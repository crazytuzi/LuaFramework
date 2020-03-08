local Lplus = require("Lplus")
local json = require("Utility.json")
local ECSocialSpaceMan = Lplus.ForwardDeclare("ECSocialSpaceMan")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECDebugOption = require("Main.ECDebugOption")
local Network = require("netio.Network")
local IReqTimeoutChecker = import(".IReqTimeoutChecker")
local SSRequestErrorCode = require("Main.SocialSpace.SSRequestErrorCode")
local TEST_BASE_ADDRESS = "http://ssp-test.zulong.com:3080"
local _baseAddress
local SSRequestBase = Lplus.Class("SSRequestBase")
do
  local def = SSRequestBase.define
  def.const("number").TIMEOUT_SECONDS = 20
  def.field("table").mRequestData = BLANK_TABLE_INIT
  def.field("string").mGetAddress = ""
  def.field("function").mCallBackFuc = nil
  def.field("string").mBaseAddress = ""
  def.field("number").mRequestSendTime = 0
  def.field("number").mRequestExpireTime = 0
  def.field("boolean").mIsDisposed = false
  def.field(IReqTimeoutChecker).mTimeoutChecker = nil
  def.field("number").mRetryCount = -1
  def.static("table").SetSSPConfig = function(sspConfig)
    _baseAddress = sspConfig.address or ""
  end
  def.virtual().InitAddress = function(self)
    self.mGetAddress = ""
  end
  def.method("table").MakeRequestData = function(self, typeData)
    self.mRequestData = {}
    self:FillBaseInfo()
    self:FillTypeInfo(typeData)
  end
  def.virtual().FillBaseInfo = function(self)
    local spaceMan = ECSocialSpaceMan.Instance()
    self.mRequestData.gameId = _G.ZL_GAMEID
    self.mRequestData.serverId = spaceMan:GetHostServerId()
    self.mRequestData.roleId = tostring(_G.GetMyRoleID())
    self.mRequestData.userId = spaceMan:GetHostUserId()
    self.mRequestData.timestamp = spaceMan:GetTokenTimestamp()
    self.mRequestData.sign = spaceMan:GetSignedToken()
  end
  def.virtual("table").FillTypeInfo = function(self, typeData)
    for k, v in pairs(typeData) do
      self.mRequestData[k] = v
    end
  end
  def.method("boolean", "string", "dynamic").OnGetDataFromWeb = function(self, isSuccess, address, data)
    if ECDebugOption.Instance().showSSlog then
      print("onGetDataFromWeb, isSuccess, address, data:", isSuccess, address, tostring(data))
    end
    if self:IsAbortWhenOutWorld() and not _G.IsEnteredWorld() then
      print("OnGetDataFromWeb not in world")
      return
    end
    if self.mRequestData.roleId and self.mRequestData.roleId ~= tostring(_G.GetMyRoleID()) then
      print("OnGetDataFromWeb roleId not match")
      return
    end
    local integralAddress = self:GetIntegralAddress()
    if integralAddress == address then
      local jsonData
      if isSuccess then
        local rawJsonStr = data:get_string()
        jsonData = json.decode(rawJsonStr, 1, true)
        if ECDebugOption.Instance().showSSlog then
          print("rawJsonStr = " .. rawJsonStr)
        end
        local retcode = tonumber(jsonData.retcode)
        jsonData.retcode = retcode
        if self.mRetryCount == -1 then
          if retcode == SSRequestErrorCode.TIMESTAMP_INVALID then
            warn("Space timestamp invalid! try once.")
            self.mRetryCount = 1
          elseif retcode == SSRequestErrorCode.SIGN_INVALID then
            warn("Space sign invalid! try once.")
            self.mRetryCount = 1
          end
        end
        if self.mRetryCount <= 0 then
          if retcode ~= 0 then
            if self:DealSpecialRetcode(retcode) then
              self:Callback(jsonData)
              return
            end
            print("Get Data return retcode:", retcode)
            SSRequestBase.ShowErrorInfo(jsonData)
          end
          self:onGetJsonData(jsonData)
          self:Callback(jsonData)
        end
      elseif ECSocialSpaceMan.Instance():IsDebug() then
        jsonData = self:GetDebugJsonData()
        self:Callback(jsonData)
      else
        local HtmlHelper = require("Main.Chat.HtmlHelper")
        local errorMsg = HtmlHelper.ConvertHtmlKeyWord(data)
        self:DealConnectError(SSRequestErrorCode.UNKONW_ERROR, errorMsg)
      end
    end
  end
  def.virtual("table").onGetJsonData = function(self, jsonData)
  end
  def.method("table", "function").SendRequest = function(self, data, callback)
    self.mRequestSendTime = os.time()
    self.mRequestExpireTime = self.mRequestSendTime + SSRequestBase.TIMEOUT_SECONDS
    if self.mTimeoutChecker then
      self.mTimeoutChecker:AddToCheckList(self)
    end
    self.mCallBackFuc = callback
    self:MakeRequestData(data)
    local postData = self.mRequestData
    local strTable = {}
    for k, v in pairs(postData) do
      local pair = string.format("%s=%s", k, tostring(v):urlencode())
      table.insert(strTable, pair)
    end
    local integralAddress = self:GetIntegralAddress()
    local formStyleData = table.concat(strTable, "&")
    if ECDebugOption.Instance().showSSlog then
      print(string.format("SendRequest %s to %s", formStyleData, integralAddress))
    end
    GameUtil.httpPost(integralAddress, 0, formStyleData, function(success, address, postId, bytes)
      if self.mIsDisposed then
        return
      end
      self:OnGetDataFromWeb(success, address, bytes)
      if self.mRetryCount > 0 then
        self.mRetryCount = self.mRetryCount - 1
        ECSocialSpaceMan.Instance():ReqNewToken(function(self, retcode, msg)
          if retcode == 0 then
            self:SendRequest(data, callback)
          else
            self:DealConnectError(retcode, msg)
          end
        end, self)
      else
        self:Dispose()
      end
    end)
  end
  def.virtual("=>", "string").GetIntegralAddress = function(self)
    return string.format("%s/ss/%s", _baseAddress, self.mGetAddress)
  end
  def.method("number", "=>", "boolean").DealSpecialRetcode = function(self, retcode)
    if self:onDealSpecialRetcode(retcode) then
      return true
    end
    return SSRequestBase.DealCommonRetcode(retcode)
  end
  def.virtual("number", "=>", "boolean").onDealSpecialRetcode = function(self, retcode)
    return false
  end
  def.method("number", "string").DealConnectError = function(self, errorCode, errorMsg)
    if not self:onDealConnectError(errorCode, errorMsg) then
      Toast(errorMsg)
    end
    self:Callback({retcode = errorCode, errorMsg = errorMsg})
  end
  def.virtual("number", "string", "=>", "boolean").onDealConnectError = function(self, errorCode, errorMsg)
    return false
  end
  def.virtual("=>", "table").GetDebugJsonData = function(self)
    return nil
  end
  def.virtual("=>", "boolean").IsAbortWhenOutWorld = function(self)
    return true
  end
  def.method("=>", "boolean").CheckTimeout = function(self)
    local cur = os.time()
    if cur < self.mRequestExpireTime then
      return false
    end
    self:DealConnectError(SSRequestErrorCode.REQUEST_TIMEOUT, textRes.SocialSpace[62] or "Connection timeout")
    return true
  end
  def.method().Dispose = function(self)
    self.mIsDisposed = true
    if self.mTimeoutChecker then
      self.mTimeoutChecker:RemoveFromCheckList(self)
    end
  end
  def.method(IReqTimeoutChecker).SetTimeoutChecker = function(self, timeoutChecker)
    self.mTimeoutChecker = timeoutChecker
  end
  def.method("function").SetCallback = function(self, callback)
    self.mCallBackFuc = callback
  end
  def.method("table").Callback = function(self, data)
    if self.mCallBackFuc then
      self.mCallBackFuc(data)
      self.mCallBackFuc = nil
    end
  end
  def.static("number", "=>", "boolean").DealCommonRetcode = function(retcode)
    if retcode == SSRequestErrorCode.FORBID_TALKING then
      Toast(textRes.SocialSpace.SSError[retcode])
      local request = SSRequestBase()
      request.mGetAddress = "getprofile"
      request:SendRequest({}, function(jsonData)
        if jsonData.retcode ~= 0 then
          return
        end
        ECSocialSpaceMan.Instance():OnGetForbiddenInfo(jsonData.profile)
      end)
      return true
    elseif retcode == SSRequestErrorCode.ROLE_NOT_EXIST or retcode == SSRequestErrorCode.SPACE_NOT_OPEN then
      local errorMsg = textRes.SocialSpace.SSError[retcode]
      Toast(errorMsg)
      return true
    elseif retcode == SSRequestErrorCode.PASSIVE_BLACKLIST or retcode == SSRequestErrorCode.ACTIVE_BLACKLIST or retcode == SSRequestErrorCode.MUTUAL_BLACKLIST or retcode == SSRequestErrorCode.IN_BLACKLIST then
      ECSocialSpaceMan.Instance():LoadHostBlacklist()
      Toast(textRes.SocialSpace.SSError[retcode])
      return true
    end
    return false
  end
  def.static("table").PostDealError = function(data)
    if SSRequestBase.DealCommonRetcode(data.retcode) then
      return
    end
    SSRequestBase.ShowErrorInfo(data)
  end
  def.static("table").ShowErrorInfo = function(data)
    local retcode = data.retcode
    local errorMsg = textRes.SocialSpace.SSError[retcode]
    if errorMsg then
    elseif data.errorMsg then
      errorMsg = data.errorMsg
    else
      errorMsg = "SSError " .. retcode
    end
    warn(string.format("SSRequestError:[%s] %s", retcode, errorMsg))
    Toast(errorMsg)
  end
end
SSRequestBase.Commit()
return SSRequestBase
