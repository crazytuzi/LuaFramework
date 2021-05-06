local CHttpCtrl = class("CHttpCtrl")

function CHttpCtrl.ctor(self)
	self.m_Instance = C_api.WWWRequest.Instance
	self.m_Requests = {}
end

function CHttpCtrl.AblortTimeup(self, www)
	if self.m_Requests[www] then
		www:Dispose()
		self.m_Requests[www] = nil
	end
end

function CHttpCtrl.FormatUrl(self, sUrl, tUrlArg)
	if next(tUrlArg) then
		sUrl = sUrl.."?"
		for k, v in pairs(tUrlArg) do
			sUrl = sUrl..tostring(k).."="..tostring(v).."&"
		end
		sUrl = string.sub(sUrl, 0, #sUrl-1)
	end
	return sUrl
end

function CHttpCtrl.Get(self, url, cb, tArgs)
	tArgs = tArgs or {}
	local timeout = tArgs.timeout or 30
	local www = self.m_Instance:Get(url, callback(self, "OnGetResult"))
	local timer = Utils.AddTimer(callback(self, "AblortTimeup", www), 0, timeout)
	self.m_Requests[www] = {cb= cb, timer = timer, json_result =tArgs.json_result}
	print("http get ->", url)
end

function CHttpCtrl.OnGetResult(self, www)
	self:CommonProcess(www)
end

function CHttpCtrl.Post(self, url, cb, headers, bytes, tArgs)
	tArgs = tArgs or {}
	local timeout = tArgs.timeout or 30
	headers = headers or {}
	local www = self.m_Instance:Post(url, headers, bytes, callback(self, "OnPostResult"))
	self.m_Requests[www] = {cb= cb}
	local timer = Utils.AddTimer(callback(self, "AblortTimeup"), 0, timeout)
	self.m_Requests[www] = {cb= cb, timer = timer, json_result =tArgs.json_result}
	table.print({url=url,headers=headers},"http post ->")
end

function CHttpCtrl.OnPostResult(self, www)
	self:CommonProcess(www)
end

function CHttpCtrl.CommonProcess(self, www)
	local info  = self.m_Requests[www]
	table.print(info, "CommonProcess->")
	if info then
		if info.cb then
			local success = www.isDone and (www.error == nil or www.error == "")
			local tResult = {}
			if success then
				if info.json_result then
					tResult = decodejson(www.text)
				end
				-- table.print(www.responseHeaders, "www.responseHeaders->")
				table.print(tResult, "cb tResult->")
			end
			xxpcall(info.cb, success, tResult)
		end
		if info.timer then
			Utils.DelTimer(info.timer)
		end
		self.m_Requests[www] = nil
	end
end

return CHttpCtrl