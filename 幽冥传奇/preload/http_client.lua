HttpClient = {}

function HttpClient:Start()
	if nil == self.downloader then 
		self.downloader = HttpDownloader:create()
		self.downloader:retain()
		self.downloader:setCallback(LUA_CALLBACK(self, self.DownloadCallback))
		self.download_list = {}
	end

	if nil == self.uploader then 
		self.uploader = HttpUploader:create()
		self.uploader:retain()
		self.uploader:setCallback(LUA_CALLBACK(self, self.UploadCallback))
		self.upload_list = {}
	end

	if nil == self.requester then 
		self.requester = HttpRequester:create()
		self.requester:retain()
		self.requester:setCallback(LUA_CALLBACK(self, self.RequestCallback))
		self.request_list = {}
	end
end

function HttpClient:Update(dt)
end

function HttpClient:Stop()
	if nil ~= self.downloader then
		self.downloader:release()
		self.downloader = nil
		self.download_list = nil
	end

	if nil ~= self.uploader then
		self.uploader:release()
		self.uploader = nil
		self.upload_list = nil
	end

	if nil ~= self.requester then
		self.requester:release()
		self.requester = nil
		self.request_list = nil
	end
end

-- 下载
function HttpClient:Download(url, path, callback)
	if nil == self.downloader then return end

	local t = self.download_list[url]
	if nil == t then
		if not self.downloader:addRequest(url, path, 0) then
			print("HttpDownload fail url:" .. url)
			return false
		end
		self.download_list[url] = { callback_list={[1]=callback}, is_complete=false}
	else
		table.insert(t.callback_list, callback)
	end

	return true
end

-- 取消下载
function HttpClient:CancelDownload(url, callback)
	if nil == self.downloader then return end

	local t = self.download_list[url]
	if nil ~= t then
		for k, v in pairs(t.callback_list) do
			if v == callback then
				table.remove(t.callback_list, k)
				break
			end
		end

		if #t.callback_list == 0 then
			self.downloader:delRequest(url)
			self.download_list[url] = nil
		end
	end
end

-- 下载完成，path与data只会有一个有效
function HttpClient:DownloadCallback(url, path, data, size)
	if nil == self.downloader then return end

	if nil ~= self.download_list[url] then
		for k, v in pairs(self.download_list[url].callback_list) do
			v(url, path, size)
		end
		self.download_list[url] = nil
	end
end

-- 上传
function HttpClient:Upload(url, path, callback)
	if nil == self.uploader then return end

	local t = self.upload_list[url]
	if nil == t then
		if not self.uploader:addRequest(url, path, 0) then
			print("HttpUpload fail url:" .. url)
			return false
		end
		self.upload_list[url] = { callback_list={[1]=callback} }
	else
		table.insert(t.callback_list, callback)
	end

	return true
end

-- 取消上传
function HttpClient:CancelUpload(url, callback)
	if nil == self.uploader then return end

	local t = self.upload_list[url]
	if nil ~= t then
		for k, v in pairs(t.callback_list) do
			if v == callback then
				table.remove(t.callback_list, k)
				break
			end
		end

		if #t.callback_list == 0 then
			self.uploader:delRequest(url)
			self.upload_list[url] = nil
		end
	end
end

-- 上传完成，path与data只会有一个有效
function HttpClient:UploadCallback(url, path, size)
	if nil == self.uploader then return end

	if nil ~= self.upload_list[url] then
		for k, v in pairs(self.upload_list[url].callback_list) do
			v(url, path, size)
		end
		self.upload_list[url] = nil
	end
end

-- 请求
function HttpClient:Request(url, arg, callback)
	if nil == self.requester then return end

	local key = self.requester:addRequest(url, arg, 0)
	if key < 0 then
		-- print("HttpRequest fail url:" .. url)
		return false
	end

	self.request_list[key] = callback
	return true
end

function HttpClient:RequestCallback(url, arg, data, size, key)
	if nil == self.requester then return end

	local callback = self.request_list[key]
	if nil ~= callback then
		callback(url, arg, data, size)
		self.request_list[key] = nil
	end
end

function HttpClient:UrlEncode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end

HttpClient:Start()