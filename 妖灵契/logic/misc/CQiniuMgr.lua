local CQiniuMgr = class("CQiniuMgr")

function CQiniuMgr.ctor(self)
	self.m_UploadCBs = {}
	self.m_DownloadCBs = {}
	C_api.QiniuCloud.SetAppID("opobzo36f.bkt.clouddn.com", "n1-private")
	C_api.QiniuCloud.SetUploadCallback(callback(self, "OnQiniuUpload"))
	C_api.QiniuCloud.SetDownloadCallback(callback(self, "OnQiniuDowload"))

end

function CQiniuMgr.OnQiniuUpload(self, key, success)
	local cb = self.m_UploadCBs[key]
	if cb then
		cb(key, success)
		self.m_UploadCBs[key] = nil
	end
end

function CQiniuMgr.OnQiniuDowload(self, key, www)
	local cb = self.m_DownloadCBs[key]
	if cb then
		cb(key, www)
		self.m_DownloadCBs[key] = nil
	end
end

function CQiniuMgr.UploadFile(self, key, path, type, cb)
	self.m_UploadCBs[key] = cb
	C_api.QiniuCloud.UploadFile(path, key)
end

function CQiniuMgr.DownloadFile(self, key, cb)
	self.m_DownloadCBs[key] = cb
	C_api.QiniuCloud.DownloadFile(key)
end

return CQiniuMgr