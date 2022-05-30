require("zlib")
local IapHttpNetwork = class("IapRequest")
function IapHttpNetwork:ctor()
	self._network = require("framework.network")
	self._json = require("framework.json")
end
function IapHttpNetwork:sendRequest(param)
	self._callback = param.callback
	self._errorCallback = param.errorCallback
	self._url = param.url
	self._timeout = param.timeout or 10
	self._action = param.action or "POST"
	if self._network.isInternetConnectionAvailable() == false and self._network.isLocalWiFiAvailable() == false then
		printf("3G和WIFI网络不好")
		device.showAlert(common:getLanguageString("@wufalj"), "", {
		common:getLanguageString("@Confirm")
		}, function ()
			self:sendRequest(param)
		end)
		return
	end
	dump(self._url)
	self:starRequest()
end
function IapHttpNetwork:starRequest()
	local request = self._network.createHTTPRequest(handler(self, IapHttpNetwork.onRequestFinished), self._url, self._action)
	request:setTimeout(self._timeout)
	request:start()
end
function IapHttpNetwork:onRequestFinished(event)
	local ok = event.name == "completed"
	local request = event.request
	if event.name == "failed" then
		printf("-----  failed:%s", request:getErrorMessage())
		if self._errorCallback ~= nil then
			self._errorCallback()
		end
	end
	if not ok then
		dump(request:getErrorCode(), request:getErrorMessage())
		return
	end
	local code = request:getResponseStatusCode()
	if code ~= 200 then
		device.showAlert("Warning", "Network Warning!", {"OK"}, function ()
			require("utility.LoadingLayer").destroy()
		end)
		dump(code)
		return
	end
	local zipRes = request:getResponseData()
	local res, eof, bin, bout
	if ENABLE_GAME_ZLIB == true then
		res, eof, bin, bout = zlib.inflate()(zipRes)
	else
		res = zipRes
	end
	local codeJson = self._json.decode(res)
	dump(codeJson)
	if self._callback ~= nil then
		self._callback(codeJson)
	end
end
return IapHttpNetwork