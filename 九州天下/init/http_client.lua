
HttpClient = HttpClient or {
	download_list = {},
	upload_list = {},
	request_list = {},
}

-- 下载
function HttpClient:Download(url, path, callback)
	local t = self.download_list[url]
	if nil == t then
		self.download_list[url] = {callback}
		UtilU3d.Download(url, path, function(is_succ, data) HttpClient:DownloadCallback(url, path, is_succ, data) end)
	else
		table.insert(t, callback)
	end

	return true
end

-- 取消下载
function HttpClient:CancelDownload(url, callback)
	local t = self.download_list[url]
	if nil ~= t then
		for k, v in pairs(t) do
			if v == callback then
				table.remove(t, k)
				break
			end
		end

		if #t == 0 then
			self.download_list[url] = nil
		end
	end
end

-- 下载完成
function HttpClient:DownloadCallback(url, path, is_succ, data)
	if nil ~= self.download_list[url] then
		for k, v in pairs(self.download_list[url]) do
			v(url, path, is_succ, data)
		end
		self.download_list[url] = nil
	end
end

-- 上传
function HttpClient:Upload(url, path, callback)
	local t = self.upload_list[url]
	if nil == t then
		if UtilU3d.Upload(url, path, function(is_succ, data) HttpClient:UploadCallback(url, path, is_succ, data) end) then
			self.upload_list[url] = {callback}
			return true
		end
		return false
	else
		table.insert(t, callback)
	end

	return true
end

-- 取消上传
function HttpClient:CancelUpload(url, callback)
	-- local t = self.upload_list[url]
	-- if nil ~= t then
	-- 	print("#############  t.callback_list", t.callback)
	-- 	for k, v in pairs(t.callback_list) do
	-- 		if v == callback then
	-- 			table.remove(t.callback_list, k)
	-- 			break
	-- 		end
	-- 	end

	-- 	if #t.callback_list == 0 then
	-- 		self.upload_list[url] = nil
	-- 	end
	-- end

	local callback_list = self.upload_list[url]
	if nil ~= callback_list then
		for k, v in pairs(callback_list) do
			if v == callback then
				table.remove(callback_list, k)
				break
			end
		end

		if #callback_list == 0 then
			self.upload_list[url] = nil
		end
	end
end

-- 上传完成
function HttpClient:UploadCallback(url, path, is_succ, data)
	if nil ~= self.upload_list[url] then
		for k, v in pairs(self.upload_list[url]) do
			v(url, path, is_succ, data)
		end
		self.upload_list[url] = nil
	end
end

-- 请求
function HttpClient:Request(url, callback)
	self.request_list[callback] = callback
	UtilU3d.RequestGet(url, function(is_succ, data)
		if nil ~= self.request_list[callback] then
			self.request_list[callback] = nil
			callback(url, is_succ, data)
		end
	end)
	return true
end

-- 取消请求
function HttpClient:CancelRequest(callback)
	self.request_list[callback] = nil
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
