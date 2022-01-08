TFClientNewUpdate = {
	szErr       		= nil,
	netHttp 			= nil,
	szCurVersion 		= nil,  --client cur version num
	szToVersion  		= nil,  --client cur update to verson num
	szLastVersion 		= nil,  --server res version number
	szClientVerRec 		= nil,  --client record version file name
	szClientVerFilePath = nil,  --client record version file path
	szServerVerFile   	= nil,  --server version file
	szServerFilelistN  	= nil,  --server new verison file list name
	szClientFilelistN	= nil,  --client file list name
	szClientFileListPath= nil,  --client file list write path 
	szDefWritePath 		= nil,  --getWriateablePath
	szWriteRootPath 	= nil,  --for some config file 
	szWriteResPath 		= nil,  --download res write path  
	pRequsetVerisonCB 	= nil,  --param ret,nUpdateResultCode,szErr,szLastVersion,nTotUpdateSize,nTotFileCount
	pUpdateCompleteCB   = nil,  --param ret,nUpdateResultCode,szeErr,fileName,nTotUpdateSize,nHasDownLoadSize
	pHasUpdateSizeCB  	= nil,  --param nTotUpdateSize,nHasDownLoadSize
	bShouldDeleteOld 	= false,--new apk or ipa should delete old resource
	nUpdateResultCode	= 0,
	nDownloadStatus  	= 0,    
	nTotFileCount    	= 0, --this update total file count
	nHasRecvFCount      = 0, --this update complete file count
	nTotUpdateSize   	= 0, --this update all the total size of files 
	nHasDownLoadSize 	= 0, --this update has udpate size
	szCachePath      	= nil, --cache dir
	szCfgZipFile     	= nil, --record update zip files
	szCfgDelFile     	= nil, --record new version has deleted files
	szEditionDir     	= nil, --server filelist.lua  dir
	szServerRoot     	= nil, --server url root dir
	szServerSourceRoot  = nil, --server should update file root  path
	szClientLastDownFile= nil, --client last download success file
	tUpdateList      	= nil, --after compare this table will record update list:zip files ,delete files android so on
	tServerFileList     = nil, --server file list will write to client when update complete
	eDownLoadStatus  = {
		TF_NEWUPDATE_DO_NOTHING   = 0,
		TF_NEWUPDATE_DUR_DOWNFILE = 1,
		TF_NEWUPDATE_DUR_UNZIP 	  = 2,
		TF_NEWUPDATE_DUR_COPY 	  = 3,
		TF_NEWUPDATE_DUR_DELCACHE = 4,
		TF_NEWUPDATE_DUR_DELFILE  = 5,
	},
	eUpdateReultCode = {
		UPDATE_NO_ERR		= 0,
		FILE_FORMAT_ERR     = 1,
		PARSE_VERCFG_ERR	= 2,
		REQ_VERCFG_ERR 		= 3,
		CONNECT_SERVER_ERR  = 4,
		RW_FILE_ERR       	= 5,
		DEL_FILEORDIR_ERR   = 6,
		COPY_FILEORDIR_ERR  = 7,
		UNZIP_FILE_ERR		= 8,
		NO_ENOUGH_SPACE     = 9,
		THE_OTHER_ERR       = 10,
		THE_UPDATE_SUCCESS  = 11,
	},
}

function TFClientNewUpdate:getCurVersion()
	return self.szCurVersion
end

function TFClientNewUpdate:setMaxConnectSec(nSec)
	-- body
	if self.netHttp ~= nil then
		self.netHttp:setMaxConnectSec(nSec)
	end
end

function TFClientNewUpdate:setClientFileListN(szName)
	self.szClientFilelistN = szName
end

function TFClientNewUpdate:setMaxRecvSec(nSec)
	-- body
	if self.netHttp ~= nil then
		self.netHttp:setMaxRecvSec(nSec)
	end
end

function TFClientNewUpdate:setClientVerRecFile(szFileName)
	self.szClientVerRec  = szFileName
end

function TFClientNewUpdate:setServerVerFile(szFileName)
	self.szServerVerFile  = szFileName
end

function TFClientNewUpdate:setCurVersion(szVerion)
	local _,_,recVer = self:readClientVer()
	if not recVer then
		recVer = self.szCurVersion
		self:writeLastUpdateFile(recVer,"","")
	end

	if recVer < szVerion then
		self.szCurVersion = szVerion
		print(self.szCurVersion)
	end

	if self.szToVersion < szVerion then
		self.szToVersion  = szVerion
		if not self:deleteCache() or self:removeFile(self.szClientFileListPath) ~= true then
			return false
		else
			self.nDownloadStatus = self.eDownLoadStatus['TF_NEWUPDATE_DO_NOTHING']
			self:writeLastUpdateFile(szVerion,"","")
		end
	end
end

-- if client no filelist file mean no need compare
function TFClientNewUpdate:getClientFilelist()
	if not self.szClientFileListPath then return true end
	local ret,tFileList = self:readFileContentToTbl(self.szClientFileListPath)
	if not ret then return false end
	if tFileList == nil or (type(tFileList) ~= 'table' and #tFileList < 1) then --filelist content is null
		return true
	elseif type(tFileList) ~= 'table' then
		self.nUpdateResultCode = self.eUpdateReultCode['FILE_FORMAT_ERR']
		self.szErr             =  self.szClientFileListPath .." file content format error"
		return false
	end

	return true,tFileList
end

--when client file list compare server file list will use this create the update list
--[[tUpdateList = {
	[1] = "filename",
	[2] = "md5",
	[3] = "filesize",
}
]]
function TFClientNewUpdate:buildUpdateList()
	local tUpdateList  = {}
	local tZipFileList = {}
	local filePath = nil
	local fileMd5  = nil
	local fileSize = nil
	self.nTotFileCount = 0
	self.tUpdateList['fileInfoList'] = {}
	for k,v in pairs(self.tUpdateList['updateList']) do
		tUpdateList[k]= string.split(v, ":")
		filePath = tUpdateList[k][1]
		fileMd5  = tUpdateList[k][2]
		fileSize = tUpdateList[k][3]
		if string.sub(filePath,#filePath-3) == ".zip" then
			tZipFileList[#tZipFileList+1]= filePath	
		end
		self.nTotUpdateSize = self.nTotUpdateSize + fileSize
		self.nTotFileCount = self.nTotFileCount + 1
		self.tUpdateList['fileInfoList'][filePath] = fileMd5
	end
	self.nHasRecvFCount = 0
	self.tUpdateList['updateList']  = tUpdateList
	self.tUpdateList['zipFileList'] = tZipFileList
	return true
end

function TFClientNewUpdate:cmpClientWithServerFileList(tClient,tServer)
	if not tServer or #tServer< 1 then 
		self.szErr = "server filelist read to tbl is null"
		self.nResultCode = self.eUpdateReultCode['FILE_FORMAT_ERR']
		return false 
	end
	
	self.tUpdateList['updateList'] = nil
	self.tUpdateList['delFileList'] =nil
	if tClient == nil or #tClient < 1 then
		self.tUpdateList['updateList']  = tServer
	else
		local tClientFileList = tClient
		local tServerFileList = tServer
		table.walk(tServer,function(v,k)
			for key,value in pairs(tClient) do
				if v == value then --remove the not change file
					tClientFileList[key] = nil
					tServerFileList[k]   = nil
					break
				end
			end
		end)

		for i = #tClientFileList ,1,-1 do
			if tClientFileList[i] == nil then
				table.remove(tClientFileList,i)
			end
		end

		for i = #tServerFileList ,1,-1 do
			if tServerFileList[i] == nil then
				table.remove(tServerFileList,i)
			end
		end

		self.tUpdateList['updateList']  = tServerFileList
		self.tUpdateList['delFileList'] = tClientFileList
	end

	return self:buildUpdateList()
end

function TFClientNewUpdate:checkVerFormatEqual()
	local a = ''
	local b = ''
	local nLast = '' 
	local nCur = '' 
	local bEqual = false
	a,nLast = string.gsub(self.szLastVersion,"%.",".")
	b,nCur  = string.gsub(self.szCurVersion,"%.",".")

	if nCur ~= nLast then
		bEqual = false
		self.nUpdateResultCode = self.eUpdateReultCode['FILE_FORMAT_ERR']
		self.szErr = "server version content format error"
	else
		bEqual = true
	end
	return bEqual
end

function TFClientNewUpdate:checkShouldDownload()
	local bShouldDownload = false
	if self.szLastVersion <= self.szCurVersion then
		self.nUpdateResultCode = self.eUpdateReultCode['THE_UPDATE_SUCCESS']
		self.szErr = "client version >= server version"
		return bShouldDownload
	elseif self.szToVersion and self.szLastVersion > self.szToVersion  then --client has download some source ?
		self.bShouldDeleteOld = true
	end

	bShouldDownload = true
	return bShouldDownload
end

--just get the filelist.zip
local function onRequestFileListCallBack(nType,nRet,pData)
	local self = TFClientNewUpdate
	local bRet = false
	if nRet ~= 200 or type(pData) ~= 'string' then
		self.nUpdateResultCode = self.eUpdateReultCode['THE_OTHER_ERR']
		self.szErr = "request versoin file error"
		bRet = false
	else
		local nSize =  string.len(pData)
		local szContent = nil
		local szLastVersion = nil 
		local tServerFileList     = nil
		local tNameInZip    = self.szServerFilelistN .. ".lua"

		szContent = TFFileUtil:getFileDataFromZipBuffer(pData,nSize,tNameInZip)
		tServerFileList = loadstring(szContent)()
		self.tServerFileList = tServerFileList

		if not tServerFileList or type(tServerFileList) ~= 'table' then
			self.nUpdateResultCode = self.eUpdateReultCode['FILE_FORMAT_ERR']
			self.szErr             = tNameInZip .. "file content format error"
		else
			local ret,tClientFileList = self:getClientFilelist()
			if ret then
				ret = self:cmpClientWithServerFileList(tClientFileList,tServerFileList)
			end
			bRet = ret
		end
	end 

	if self.pRequsetVerisonCB then
		self.pRequsetVerisonCB(bRet,self.nUpdateResultCode,self.szErr,self.szLastVersion,self.nTotUpdateSize,self.nTotFileCount)
	end
end

--just get the version.lua
local function onRequestVersionCallBack(nType,nRet,pData)
	local self = TFClientNewUpdate
	local serverFormatOK = false
	if nRet ~= 200 or type(pData) ~= 'string' then
		self.nUpdateResultCode = self.eUpdateReultCode['CONNECT_SERVER_ERR']
		self.szErr = "request versoin file error"
	else
		self.szLastVersion = string.trim(pData)
	    self.szLastVersion = string.gsub(self.szLastVersion, '^["]', "")
		self.szLastVersion = string.gsub(self.szLastVersion, '["]', "")

		shouldUpdate   = self:checkShouldDownload()
		serverFormatOK = self:checkVerFormatEqual()
		if self.pRequsetVerisonCB then
			if not serverFormatOK  then
				self.pRequsetVerisonCB(false,self.nUpdateResultCode,self.szErr,nil,nil,nil)
			elseif not shouldUpdate then
				self.pRequsetVerisonCB(true,self.nUpdateResultCode,self.szErr,self.szLastVersion,nil,nil)
			else
				local filelistURL = self.szServerRoot .. self.szServerFilelistN .. '.zip'
				self.netHttp:addMERecvListener(onRequestFileListCallBack)
				self.netHttp:httpRequest(TFHTTP_TYPE_GET,filelistURL)
			end
		end
	end	
end

function TFClientNewUpdate:checkUpdate(szServerRootURL,callback)
	if not callback or not self.netHttp then 
		do return end
	end

	self.szServerRoot = szServerRootURL
	local szVersionURL = szServerRootURL .. self.szServerVerFile
	local _,_,curVer = self:readClientVer() -- init curVerion lastVersion hasDownloadsize downloadStatus
	if not curVer then
		if callback then
			callback(false,self.nUpdateResultCode,self.szErr,nil,nil,nil)
		end
		do return end
	end
	self.pRequsetVerisonCB = callback 
	self.netHttp:addMERecvListener(onRequestVersionCallBack)
	self.netHttp:httpRequest(TFHTTP_TYPE_GET,szVersionURL)
end

function TFClientNewUpdate:checkSpaceIsEnough()
	local bEnough = false
	local nFreeSpace = 0
	if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 then
		local sdPath = TFDeviceInfo.getSDPath()
		if type(sdPath) == 'string' and #sdPath > 1  then
			ret,nFreeSpace = TFLuaOcJava.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper", "getExternalMemLeftSize",nil,"()I")
			if not ret then
				nFreeSpace = 0
			end
		else
			nFreeSpace = TFDeviceInfo.getMachineFreeSpace()
		end
	else
		return true
	end
	
	if nFreeSpace * 1024 * 1024 > self.nTotUpdateSize - self.nHasDownLoadSize then
		bEnough = true
	else
		bEnough = false
		self.nUpdateResultCode = self.eUpdateReultCode['NO_ENOUGH_SPACE']
		self.szErr             = "space is not enough"
	end
	return bEnough
end


function TFClientNewUpdate:createDirIfNotExist(szPath)
	-- body
	local dir = string.match(szPath,".*/")
	if not dir then
		self.szErr = szPath .. " format error"
		self.nUpdateResultCode = self.eUpdateReultCode['FILE_FORMAT_ERR']
		return false
	end

	if not self:checkFileExist(dir) then
		bCreateDir = TFFileUtil:createDir(dir)
		if not bCreateDir then
			self.nUpdateResultCode = self.eUpdateReultCode['RW_FILE_ERR']
			self.szErr             = "wirte file " .. szPath .."error"
			return false
		end
	end

	return true
end

function TFClientNewUpdate:writeToFile(szPath,szContent)
	-- body
	if not szPath then return end

	local fileHandle = nil
	local bWriteRet  = false
	local bCreateDir = false
	
	if not self:createDirIfNotExist(szPath) then
		return false
	end

	fileHandle = io.open(szPath,"wb",szPath)
	if not fileHandle then
		self.nUpdateResultCode = self.eUpdateReultCode['RW_FILE_ERR']
		self.szErr             = "wirte file " .. szPath .." error"
		return false
	else
		if szContent then
			bWriteRet = fileHandle:write(szContent)
		end
		fileHandle:close()
	end

	return true
end

--http get file call back
local function onRequestFileCallBack(bGetRet,fileName,szContent,szErr)
	self = TFClientNewUpdate
	if bGetRet and fileName then
		local fullPath = self.szCachePath ..fileName
		local md5 = self.tUpdateList['fileInfoList'][fileName]
		if not self:writeToFile(fullPath,szContent) then
			if self.pRequsetVerisonCB then
				self.pRequsetVerisonCB(false,self.nUpdateResultCode,self.szErr,nil,self.nTotFileCount,self.nHasRecvFCount)
			end
		end

		self.nHasRecvFCount = self.nHasRecvFCount + 1
		self.nHasDownLoadSize = self.nHasDownLoadSize + string.len(szContent)
		self.nDownloadStatus = self.eDownLoadStatus['TF_NEWUPDATE_DUR_DOWNFILE']
		if not self:writeLastUpdateFile(self.szCurVersion,fileName,md5) then
			self.nUpdateResultCode = self.eUpdateReultCode['RW_FILE_ERR']
			self.szErr             = "wirte file " .. self.szClientVerRec .." error"
			return false
		end
		if self.pHasUpdateSizeCB then
			self.pHasUpdateSizeCB(self.nTotUpdateSize,self.nHasDownLoadSize)
		end

		if self.nHasRecvFCount == self.nTotFileCount then
			local bRet1 = true
			local bRet2 = true
			fileName 	= ""
			md5 	 	= ""
			self.nDownloadStatus = self.eDownLoadStatus['TF_NEWUPDATE_DUR_COPY']
			if not bRet1 or not bRet2 then
				self:sendMessage(false)
			else
				self:updateComplete(true,true)
			end

			do return end
		end
	elseif not bGetRet and self.pCompleteCB then
		self.szErr = szErr
		self.pUpdateCompleteCB(bRet,self.nUpdateResultCode,self.szErr,nil,self.nTotFileCount,self.nHasRecvFCount)
		self.pUpdateCompleteCB = nil
	end
end

function TFClientNewUpdate:updateByLastRec(szLastFile)
	if not szLastFile then 
		return false
	end
	local filePath = ""
	if tonumber(self.nDownloadStatus) == self.eDownLoadStatus['TF_NEWUPDATE_DUR_DOWNFILE'] then
		local nFindNextIndex = 1
		for i = 1,#self.tUpdateList['updateList'] do
			filePath = self.tUpdateList['updateList'][i][1]
			if szLastFile == self.tUpdateList['updateList'][i][1] and i ~= #self.tUpdateList['updateList'] then
				nFindNextIndex = i + 1
				break
			else
				nFindNextIndex = #self.tUpdateList['updateList']
			end
		end
		if nFindNextIndex == #self.tUpdateList['updateList'] then --last update file is the update list last file
			self:updateComplete(true,true)
		else
			self:getFile(nFindNextIndex,self.tUpdateList['updateList'])
		end
	else
		self:updateComplete(true,true)
	end
end

function TFClientNewUpdate:getFile(nIdx,tbl)
	-- body
	if nIdx < 1 or nIdx >#tbl then 
		nIdx = 1
	end
	
	for i = nIdx,#tbl do
		filePath = self.tUpdateList['updateList'][i][1]
		fileURL  =  self.szServerSourceRoot .. filePath
		self.nTotFileCount = self.nTotFileCount + 1
		self.netHttp:httpGetFile(fileURL,filePath)
	end
end

function TFClientNewUpdate:downFiles()
	-- body
	if type (self.szClientLastDownFile) == 'string' and string.len(self.szClientLastDownFile) > 1 then --last update no complete
		self:updateByLastRec(self.szClientLastDownFile)
	else
		self:getFile(1,self.tUpdateList['updateList'])
	end
end

function TFClientNewUpdate:sendMessage(bRet)
	-- body
	if self.pUpdateCompleteCB then
		self.pUpdateCompleteCB(bRet,self.nUpdateResultCode,self.szErr)
	end
end

function TFClientNewUpdate:startUpdate(szServerSource,pCompleteCB,pHasUpdateSizeCB)
	if not szServerSource or not pCompleteCB then 
		print("szServerSource or pCompleteCB should not nil")
		return 
	end
	self.szServerSourceRoot = szServerSource
	self.pUpdateCompleteCB  = pCompleteCB
	self.pHasUpdateSizeCB   = pHasUpdateSizeCB

	if not self:checkShouldDownload() then
		return self:sendMessage(true)
	end

	if not self:checkSpaceIsEnough() then
		return self:sendMessage(false)
	end

	if table.count(self.tUpdateList) < 1 then
		self.nUpdateResultCode = self.eUpdateReultCode['UPDATE_NO_ERR']
		self.szErr             = "no file need update"
		self:updateComplete(true,false)
	else
		local fileURL  = nil
		local filePath = nil
		if not self:createDirIfNotExist(self.szWriteRootPath) then
			return self:sendMessage(false)
		end
		if not self:createDirIfNotExist(self.szCachePath) then
			return self:sendMessage(false)
		end
		self.nTotFileCount 	 = 0
		self.nHasRecvFCount  = 0
		self.netHttp:addGetFileListener(onRequestFileCallBack)
		if tonumber(self.nDownloadStatus) <= tonumber(self.eDownLoadStatus['TF_NEWUPDATE_DUR_DOWNFILE']) then
			self:downFiles()
		else
			self:updateComplete(true,true)
		end
	end
end

function TFClientNewUpdate:initSomePath()
	if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
		local sdPath = TFDeviceInfo.getSDPath()
	    if sdPath and #sdPath >1 then	
	        local  sPackName = TFDeviceInfo.getPackageName()
	        self.szWriteRootPath = sdPath.."playmore/" .. sPackName .. "/"
	    else
	    	self.szWriteRootPath = self.szDefWritePath
	    end
	elseif CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
		self.szWriteRootPath = self.szDefWritePath .. "../Library/"
	elseif CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
		self.szWriteRootPath = self.szDefWritePath .. "../Library/"
	end
	self.szCachePath  	= self.szWriteRootPath .. "downloadCache/"
	self.szCfgZipFile 	= self.szWriteRootPath .. "cfgZip.bin"
	self.szCfgDelFile 	= self.szWriteRootPath .. "cfgDel.bin"
	self.szWriteResPath = self.szWriteRootPath .. "TFDebug/"
	self.szClientFileListPath  = self.szWriteRootPath .. self.szClientFilelistN
	self.szClientVerFilePath   = self.szWriteRootPath .. self.szClientVerRec
end


function TFClientNewUpdate:init()
	self.szCurVersion     = "0.0.0"
	self.szToVersion	  = "0.0.0"
	self.szLastVersion	  = "0.0.0"
	self.szClientVerRec   = "lastfile.bin"
	self.szServerVerFile  = "version.lua"
	self.szServerFilelistN= "filelist"
	self.szEditionDir     = "edition/"
	self.szClientFilelistN= "Cfilelist.bin"
	self.tUpdateList      = {
		['updateList']  = nil,
		['delFileList'] = nil,
		['zipFileList'] = nil,
		['fileInfoList']= nil,
	}
	self.szDefWritePath   =  me.FileUtils:getWritablePath()
	self.netHttp = TFClientNetHttp:GetInstance()
	self:initSomePath()
end

function TFClientNewUpdate:readFile(szFile)
	local fileHandle = nil
	local szContent = nil

	local sFile = me.FileUtils:fullPathForFilename(szFile)
	if not self:checkFileExist(sFile) then
		return nil
	end

	fileHandle = io.open(sFile,"r")
	if not fileHandle then
		return nil
	else
		szContent = fileHandle:read("*all")
		fileHandle:close()	
	end

	return szContent
end

function TFClientNewUpdate:readFileContentToTbl(file)
	local fileHandle = nil
	local szContent  = nil
	local tContent   = {} 
	local fullPath   = me.FileUtils:fullPathForFilename(file)
	self.nUpdateResultCode = self.eUpdateReultCode['UPDATE_NO_ERR']
	self.szErr = "update no err"
	if not self:checkFileExist(fullPath) then
		return true
	end
	fileHandle = io.open(fullPath,"r")
	if fileHandle then
		szContent = fileHandle:read("*all")
		if not szContent then return true end
		tContent = loadstring(szContent)()
	else
		self.nUpdateResultCode = self.eUpdateReultCode['RW_FILE_ERR']
		self.szErr = "read file ".. fullPath .. " error"
		return false
	end
	return true,tContent
end

function TFClientNewUpdate:writeTblToFile(szFile,tTbl)
	-- body
	if type(tTbl) ~= 'table' then
		return false
	end

	local szTbl = "return { \n"
	local szContent = ""
	if table.count(tTbl) > 0 then
		szTbl = szTbl .. "'"
		for i = 1, #tTbl-1 do
			szContent = szContent .. tTbl[i] .. "',\n'" 
		end
		szTbl = szTbl ..szContent .. tTbl[#tTbl] .. "',\n"
	end
	szTbl = szTbl .. '}'
	return self:writeToFile(szFile,szTbl)
end

--will return file md5 version
function TFClientNewUpdate:readClientVer()
	local file    = nil
	local md5     = nil 
	local version = nil
	local szContent = nil
	szContent = self:readFile(self.szClientVerFilePath)

	if szContent then
		local nFileIdxb,nFileIdxe  = string.find(szContent,"%[File:%]")
		local nMd5Idxb,nMd5Idxe    = string.find(szContent,"%[Md5:%]")
		local nDSiIdxb,nDSiIdxe    = string.find(szContent,"%[HasDownload:%]")
		local nVerIdxb,nVerIdxe    = string.find(szContent,"%[Version:%]")
		local nToVIdxb,nToVIdxe    = string.find(szContent,"%[ToVersion:%]")
		local nDStIdxb,nDStIdxe	   = string.find(szContent,"%[Status:%]")
		if nVerIdxb == nil or nil == nFileIdxb or nil== nMd5Idxb or nil == nDSiIdxb or nil == nDStIdxb or nil == nToVIdxb then
			self.nUpdateResultCode = self.eUpdateReultCode['FILE_FORMAT_ERR']
			self.szErr = self.szClientVerFilePath .. " format error"
			return nil,nil,nil
		end

		local dSize   = 0
		local dStatus = 0
		local sToVer  = 0
		file  	= string.sub(szContent,nFileIdxe+ 1,nMd5Idxb - 1)
		md5   	= string.sub(szContent,nMd5Idxe + 1,nDSiIdxb - 1) 
		dSize 	= string.sub(szContent,nDSiIdxe + 1,nVerIdxb - 1)
		version = string.sub(szContent,nVerIdxe + 1,nToVIdxb - 1)
		sToVer  = string.sub(szContent,nToVIdxe + 1,nDStIdxb - 1)
		dStatus = string.sub(szContent,nDStIdxe + 1,#szContent)

		self.szCurVersion         = version 
		self.nHasDownLoadSize 	  = dSize
		self.nDownloadStatus   	  = dStatus
		self.szToVersion      	  = sToVer
		self.szClientLastDownFile = file
		print(string.format("file:%s,md5:%s,hasdownsize:%s,version:%s,toversion:%s,downstatus:%s",file,md5,dSize,version,sToVer,dStatus))
	else
		version = self.szCurVersion
	end

	return file,md5,version
end

-- if version md5 nil will just write unzip file or del file
function TFClientNewUpdate:writeLastUpdateFile(version,fileName,md5)
	local sLast = ""
	local filePath = ""
	local fileHandle = nil
	local szContent = nil
	filePath = me.FileUtils:fullPathForFilename(self.szClientVerFilePath)
	if not self:createDirIfNotExist(filePath) then
		return false
	end

	fileHandle = io.open(filePath,"wb")
	if not fileHandle then
		self.nUpdateResultCode = self.eUpdateReultCode['RW_FILE_ERR']
		self.szErr = "read file " .. filePath .. " error"
		return false
	else
		sLast = sLast .. "[File:]"
		sLast = sLast .. fileName
		sLast = sLast .. "[Md5:]"
		sLast = sLast .. md5
		sLast = sLast .. "[HasDownload:]"
		sLast = sLast .. self.nHasDownLoadSize
		sLast = sLast .. "[Version:]"
		sLast = sLast .. version
		sLast = sLast .. "[ToVersion:]"
		sLast = sLast ..  self.szLastVersion
		sLast = sLast .. "[Status:]"
		sLast = sLast .. self.nDownloadStatus
	end

	fileHandle:write(sLast)
	fileHandle:close()
	return true
end

function TFClientNewUpdate:updateComplete(bResult,bNeedCopy)
	local bRet = bResult
	if bResult and bNeedCopy then
		if type(self.tUpdateList['zipFileList']) == 'table' and #self.tUpdateList['zipFileList'] >= 1 then
			bRet1 = self:writeTblToFile(self.szCfgZipFile,self.tUpdateList['zipFileList'])
		end

		if type(self.tUpdateList['delFileList']) == 'table' and #self.tUpdateList['delFileList'] >= 1 then
			bRet2 = self:writeTblToFile(self.szCfgDelFile,self.tUpdateList['delFileList'])
		end

		bRet = self:copyCacheToWrite()
	end

	self:sendMessage(bRet)
end

function TFClientNewUpdate:checkFileExist(szFullPath)
	if not szFullPath then return true end

	if szFullPath[#szFullPath] == "/" then
		return TFFileUtil:existFile(szFullPath)
	else
		local fileHandle = io.open(szFullPath,'r')
		if not fileHandle then
			return false
		else
			fileHandle:close()
		end

		return true
	end
end

function TFClientNewUpdate:copyCache()
	-- body
	local ret =false 
	self.nDownloadStatus = self.eDownLoadStatus['TF_NEWUPDATE_DUR_DELCACHE']
	local fullPath = me.FileUtils:fullPathForFilename(self.szCachePath)
	if not self:checkFileExist(fullPath) then
		return true
	end

	if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
		fullPath = fullPath .."*"
	end

	ret  = TFFileUtil:copyFloder(fullPath,self.szWriteResPath)
	
	if not ret  then
		self.szErr = "copy " ..fullPath .. " to " .. self.szWriteResPath .." error "
		self.nUpdateResultCode = self.eUpdateReultCode['COPY_FILEORDIR_ERR']
	end

	return  ret 
end

function TFClientNewUpdate:deleteCache()
	local bRet = false
	local fullPath = me.FileUtils:fullPathForFilename(self.szCachePath)
	if not self:checkFileExist(fullPath) then
		return true
	end

	self.nDownloadStatus = self.eDownLoadStatus['TF_NEWUPDATE_DUR_DELCACHE']
	bRet = TFFileUtil:deleteDir(fullPath,false)
	if not bRet then
		self.nUpdateResultCode = self.eUpdateReultCode['DEL_FILEORDIR_ERR']
		self.szErr = "del " .. self.szCachePath .. "error"
	end
	return bRet
end

function TFClientNewUpdate:removeFile(szFullPath)
	-- body
	local ret = true
	local szErr = "success"
	ret ,szErr = os.remove(szFullPath)
	if not ret then
		self.nUpdateResultCode = self.eUpdateReultCode['DEL_FILEORDIR_ERR']
		self.szErr = szErr
	end
	return ret,szErr
end

--delete the new version has been deleted files
function TFClientNewUpdate:deleteFiles()
	local ret = false
	local szErr = nil
	local szFile = nil
	local tContent = {}
	local fullPath = me.FileUtils:fullPathForFilename(self.szCfgDelFile)
	if not self:checkFileExist(fullPath) then
		return true
	end

	self.nDownloadStatus = self.eDownLoadStatus['TF_NEWUPDATE_DUR_DELFILE']
	ret,tContent = self:readFileContentToTbl(self.szCfgDelFile)
	if not ret then
		return false
	elseif tContent == nil then --no content mean no file need delete
		return true
	end

	local tDelete = {}
	local tmp = {}
	for k,v in pairs(tContent) do
		tmp[k]= string.split(v, ":")
		tDelete[#tDelete+1] = tmp[k][1]
	end
	for i=1,#tDelete do
		szFile = self.szWriteResPath .. tDelete[i]
		if self:checkFileExist(szFile) then --if not exist mean had delete 
			ret,szErr = self:removeFile(szFile)
			if ret then
				if not self:writeLastUpdateFile(self.szCurVersion,tDelete[i],"") then
					return false
				end
			else 
				return false
			end
		end
	end

	self:removeFile(self.szCfgDelFile)
	return true
end

--unzip some zip file
function TFClientNewUpdate:unzipFiles()
	local ret = false
	local szErr = nil
	local szFile = nil
	local szExtract = nil
	local tContent = {}
	local indxe = 0
	local fullPath = nil
	
	local fullPath = me.FileUtils:fullPathForFilename(self.szCfgZipFile)
	if not self:checkFileExist(fullPath) then
		return true
	end

	self.nDownloadStatus = self.eDownLoadStatus['TF_NEWUPDATE_DUR_UNZIP']
	ret,tContent = self:readFileContentToTbl(self.szCfgZipFile)
	if not ret then
		return false
	elseif tContent == nil then --no content mean no file need unzip
		return true
	end
	for i =1,#tContent do
		szFile = self.szCachePath .. tContent[i]
		index = string.find(szFile,"/[^/]*$")
		if not index then 
			self.nUpdateResultCode = self.eUpdateReultCode['FILE_FORMAT_ERR']
			self.szErr = "cfgZip.bin file content format error"
			return false
		end
		if self:checkFileExist(szFile) then --not exist mean had unzip complete
			szExtract = string.sub(szFile,0,index -1)
			ret = TFFileUtil:unzipWholeZip(szFile,szExtract)
			if not ret then
				self.nUpdateResultCode = self.eUpdateReultCode['UNZIP_FILE_ERR']
				self.szErr = "unzip "..szFile.."error" 
				return ret
			else
				ret,szErr = self:removeFile(szFile)
				if ret then
					if not self:writeLastUpdateFile(self.szCurVersion,tContent[i],"") then
						return false
					end
				else 
					return false
				end
			end
		end
	end
	
	self:removeFile(self.szCfgZipFile)
	return true
end

function TFClientNewUpdate:copyCacheToWrite()
	local ret = false
	self.nUpdateResultCode = self.eUpdateReultCode['UPDATE_NO_ERR']
	self.szErr = "update no err"
	self.nDownloadStatus = self.eDownLoadStatus['TF_NEWUPDATE_DUR_COPY']

	ret = self:unzipFiles()
	if not ret then return false end

	ret = self:copyCache()
	if not ret then return false end

	ret = self:deleteCache()
	if not ret then return false end

	ret = self:deleteFiles()
	if not ret then return false end

	ret = self:writeTblToFile(self.szClientFileListPath,self.tServerFileList)
	if not ret then return false end

	self.nHasDownLoadSize = 0
	self.nDownloadStatus = self.eDownLoadStatus['TF_NEWUPDATE_DO_NOTHING']
	self.szErr   = "this update success"
	self.nUpdateResultCode = self.eUpdateReultCode['THE_UPDATE_SUCCESS']
	self:writeLastUpdateFile(self.szLastVersion,"","")

	return ret
end

TFClientNewUpdate:init()
return  TFClientNewUpdate