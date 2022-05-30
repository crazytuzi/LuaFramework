MSG_HEAD = MSG_HEAD or {
name = "wx",
build = "appstore",
version = "100",
pid = "",
did = ""
}
NetworkHelper = {}
local network = require("framework.network")
local json = require("framework.json")

local function request(param)
	local _listener = param.listener
	local _url = param.url
	local _action = param.action or "POST"
	local _data = param.data
	local _timeout = param.timeout or 10
	dump(_url)
	local reqst = network.createHTTPRequest(_listener, _url, _action)
	reqst:setTimeout(_timeout)
	if _action == "POST" then
		dump(_data)
		reqst:setPOSTData(_data)
	elseif _action == "GET" then
	else
		assert(false, "request action error!!")
	end
	reqst:start()
	return reqst
end

function NetworkHelper.download(url, listener, action)
	if network.isLocalWiFiAvailable() ~= true then
		show_tip_label(common:getLanguageString("@xiazaits"))
	end
	request({
	url = url,
	listener = listener,
	action = action,
	timeout = 1200
	})
end

function NetworkHelper.request(url, param, listener, action, bNoTip)
	if network.isInternetConnectionAvailable() == false and network.isLocalWiFiAvailable() == false then
		dump(common:getLanguageString("@wangluobh"))
		device.showAlert(common:getLanguageString("@wufalj"), "", {
		common:getLanguageString("@Confirm")
		}, function ()
			NetworkHelper.request(url, param, listener, action, bNoTip)
		end)
		return
	end
	local msg = {}
	msg.Head = MSG_HEAD
	if device.platform == "windows" then
		msg.Head.DID = device.getOpenUDID()
	else
		msg.Head.DID = device.getOpenUDID()
	end
	msg.Head.ReqID = 1
	msg.Head.PID = ""
	msg.Body = param
	dump(string.urldecode(tostring(msg.Body.info)))
	local num = 2
	local callback
	function callback(event)
		if event.name == "completed" then
			if bNoTip ~= true then
				local request = event.request
				if request:getResponseStatusCode() ~= 200 then
					device.showAlert(common:getLanguageString("@Hint"), common:getLanguageString("@wangluoljyc"), {
					common:getLanguageString("@OK")
					}, function ()
					end)
				elseif listener then
					local res = request:getResponseData()
					listener(json.decode(res))
				end
			end
		elseif event.name == "failed" then
			if num > 0 then
				request({
				url = url,
				listener = callback,
				action = action or "POST",
				data = json.encode(msg)
				})
			elseif num ~= 0 or bNoTip then
			else
				show_tip_label(common:getLanguageString("@wangluoyc1"))
			end
			num = num - 1
		end
	end
	if action == "GET" then
		url = url .. "?"
		for k, v in pairs(param) do
			url = string.format("%s&%s=%s", url, k, v)
		end
		local i, j = string.find(url, "/?&")
		if i then
			url = string.sub(url, 1, j - 1) .. string.sub(url, j + 1)
		end
		dump(url)
	end
	request({
	url = url,
	listener = callback,
	action = action or "POST",
	data = json.encode(msg)
	})
end

return NetworkHelper