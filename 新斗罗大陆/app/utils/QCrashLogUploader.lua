
local QCrashLogUploader = class("QCrashLogUploader")

function QCrashLogUploader:sharedCrashLogUploader()
	if app._crashLogUploader == nil then
        app._crashLogUploader = QCrashLogUploader.new()
    end
    return app._crashLogUploader
end

function QCrashLogUploader:ctor()
	
end

function QCrashLogUploader:start(url, env)
	if url == nil or string.len(url) == 0 then
		return 
	end

	if env == nil or string.len(env) == 0 then
		return 
	end

	self._uploadURL = url
	self._uploadENV = env

	local fileUtil = CCFileUtils:sharedFileUtils()
	self._localPath = fileUtil:getWritablePath() .. "crash"

	self._uploader = QUploader:create(self._localPath, self._uploadURL, self._uploadENV)

	if CCNetwork:isLocalWiFiAvailable() == true and self._uploader:canStart() == true then
		self._uploader:start()
	end
end

return QCrashLogUploader