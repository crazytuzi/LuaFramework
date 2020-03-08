local ChatRoomMgr = luanet.import_type("ChatRoomMgr");
local Directory = luanet.import_type("System.IO.Directory")
local File = luanet.import_type("System.IO.File")

Pandora.szUploadRecordFileUrl = "http://apps.game.qq.com/jxqy/a20171219album/action/PublishVoiceAction.php"

function Pandora:ClearRecordData()
    if self.szCurRecordFileName then
        ChatRoomMgr.StopRecord()
    end
    self.szCurRecordFileName = nil
    if self.szCurPlayRecordFile then
        ChatRoomMgr.StopPlayVoiceFile()
    end
    self.szCurPlayRecordFile = nil
end

function Pandora:GetRecordFilePath(szFileName)
    local szDirPath = string.format("%s/pandora_record", Ui.ToolFunction.LibarayPath)
    if not Directory.Exists(szDirPath) then
        Directory.CreateDirectory(szDirPath)
    end
    return string.format("%s/%s.record", szDirPath, szFileName)
end

function Pandora:GetRecordFileName(szFilePath)
    local szFileName = string.match(szFilePath, ".*/(.*)[.*]")
    return szFileName
end

function Pandora:StopOtherVoice()
    ChatMgr:StopVoice()
    ChatMgr:CloseChatRoomTmp()
    Ui:SetMusicVolume(0)
    Ui:SetSoundEffect(0)
    ChatMgr.bStartedVoice = true
    self.bStopByMyself = true
end

function Pandora:RestoreOtherVoice()
    if not self.bStopByMyself then
        return
    end

    self.bStopByMyself = false
    ChatMgr.bStartedVoice = false
    ChatMgr:RestoreChatRoomTmp()
    ChatMgr:CheckMusicVolume()
end

function Pandora.StartRecording(tbParam)
    local szFileName = tbParam.fileName
    if Lib:IsEmptyStr(szFileName) then
        Log("Pandora StartRecording FileName Err")
        return
    end

    Pandora:ClearRecordData()
    Pandora:StopOtherVoice()

    local szFullPath = Pandora:GetRecordFilePath(szFileName)
    local nRet = ChatRoomMgr.StartRecord(szFullPath, ChatMgr.GVoiceMode.STT_VOICE)
    if nRet == ChatMgr.GCloudVoiceErr.GCLOUD_VOICE_SUCC then
        Pandora.szCurRecordFileName = szFileName
    else
        Pandora:RestoreOtherVoice()
    end
    Pandora:__DoAction({["type"] = "ReturnStartRecordingResult", ["result"] = nRet, ["fileName"] = szFileName})
end

function Pandora.StopRecording(tbParam)
    if not Pandora.szCurRecordFileName then
        Log("Pandora StopRecording Not Recording", type(tbParam))
        return
    end

    local nRet = ChatRoomMgr.StopRecord()
    Pandora:__DoAction({["type"] = "ReturnStopRecordingResult", ["fileName"] = Pandora.szCurRecordFileName})

    local tbResult = {["type"] = "ReturnRecordingResult", ["result"] = nRet, ["fileName"] = Pandora.szCurRecordFileName, ["size"] = 0, ["length"] = 0}
    if nRet == ChatMgr.GCloudVoiceErr.GCLOUD_VOICE_SUCC then
        local szFullPath = Pandora:GetRecordFilePath(Pandora.szCurRecordFileName) 
        local nLength    = ChatRoomMgr.GetVoiceFileTime(szFullPath)
        local nSize      = ChatRoomMgr.GetVoiceFileSize(szFullPath)
        tbResult.size    = nSize
        tbResult.length  = nLength
    end

    Pandora.szCurRecordFileName = nil
    Pandora:RestoreOtherVoice()
    Pandora:__DoAction(tbResult)
end

function Pandora.PlayRecordedFile(tbParam)
    local szFileName = tbParam.fileName
    if Lib:IsEmptyStr(szFileName) then
        Log("Pandora PlayRecordedFile FileName Err")
        return
    end

    Pandora:StopOtherVoice()
    ChatRoomMgr.SetMode(ChatMgr.GVoiceMode.STT_VOICE)
    local szFullPath = Pandora:GetRecordFilePath(szFileName)
    local nRet = ChatRoomMgr.PlayeVoiceFile(szFullPath)
    if nRet == ChatMgr.GCloudVoiceErr.GCLOUD_VOICE_SUCC then
        Pandora.szCurPlayRecordFile = szCurRecordFileName
    else
        Pandora:RestoreOtherVoice()
    end
    Pandora:__DoAction({["type"] = "ReturnPlayResult", ["result"] = nRet, ["filePath"] = szFullPath})
end 

function Pandora.StopPlayRecordedFile(tbParam)
    Pandora.szCurPlayRecordFile = nil
    Pandora:RestoreOtherVoice()
    local nRet = ChatRoomMgr.StopPlayVoiceFile()
    local szFullPath = Pandora:GetRecordFilePath(tbParam.fileName)
    Pandora:__DoAction({["type"] = "ReturnStopResult", ["result"] = nRet, ["filePath"] = szFullPath})
end

function Pandora:OnPlayRecordFilComplete(nCode, szFilePath)
    Pandora.szCurPlayRecordFile = nil
    Pandora:RestoreOtherVoice()
    Pandora:__DoAction({["type"] = "ReturnStopResult", ["result"] = nCode, ["filePath"] = szFilePath})
end

function Pandora.DeleteLocalRecordedFile(tbParam)
    local szFileName = tbParam.fileName
    local szFullPath = Pandora:GetRecordFilePath(szFileName)
    local bExists    = File.Exists(szFullPath)
    File.Delete(szFullPath)
    Pandora:__DoAction({["type"] = "ReturnDeleteLocalRecordedFileResult", ["fileName"] = szFileName, ["result"] = bExists, ["msg"] = bExists and "" or "文件不存在"})
end

function Pandora.UploadRecordedFile(tbParam)
    local szFileName = tbParam.fileName
    local szFullPath = Pandora:GetRecordFilePath(szFileName)
    tbParam.permanent = tonumber(tbParam.permanent) or 0
    ChatRoomMgr.SendVoiceFile(szFullPath, tbParam.permanent > 0)
end

function Pandora:OnUploadReccordFileComplete(szFilePath)
    local szData, nLen = Lib:ReadFileBinary(szFilePath)
    if szData and nLen > 0 then
        szData = Lib:UrlEncode_N(szData)
        local nPlatform    = Sdk:GetLaunchPlatform()
        local nAreaId      = Sdk:GetAreaIdByPlatform(nPlatform)
        local nPartitionId = Sdk:GetServerId()
        local szUid        = Sdk:GetUid()
        local nLength      = ChatRoomMgr.GetVoiceFileTime(szFilePath)
        local nSize        = ChatRoomMgr.GetVoiceFileSize(szFilePath)
        local szFileName   = Pandora:GetRecordFileName(szFilePath) or szFilePath
        local szPostData   = string.format("method=PublishVoice&sArea=%s&sPlatId=%s&sOpenId=%s&sPartition=%s", nAreaId, nPlatform, szUid, nPartitionId)
        szPostData = string.format("%s&sRoleId=%s&sFileName=%s&sVoiceType=1&sFileTime=%s&sFileSize=%s&sFileData=%s", szPostData, me.dwID, szFileName, nLength, nSize, szData)
        local szMD5 = Ui.ToolFunction.GetFileMd5(szFilePath)
        szPostData = string.format("%s&file_md5=%s", szPostData, szMD5)
        local fnUploadCallBack = function (szResult)
            Pandora:__DoAction({["type"] = "ReturnUploadToPandoraResult", ["result"] = szResult})
        end
        Sdk:DoHttpRequest(Pandora.szUploadRecordFileUrl, szPostData, fnUploadCallBack)
    end
end

function Pandora.DownloadRecordedFile(tbParam)
    local szFullPath = Pandora:GetRecordFilePath(tbParam.fileName)
    local bExists = File.Exists(szFullPath)
    if bExists then
        ChatMgr:OnDownloadRecordFileComplete(ChatMgr.GVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE, szFullPath, tbParam.fileId)
    else
        ChatRoomMgr.SetMode(ChatMgr.GVoiceMode.STT_VOICE)
        local nRet = ChatRoomMgr.DownloadVoiceFile(szFullPath, tbParam.fileId)
        Log("Pandora Try DownloadRecordedFile Result", nRet)
    end
end

function Pandora:OnApplicationPause(bPauseStatus)
    local tbRet = {content = ""}
    if not bPauseStatus then
        tbRet.type = "GameIntoForeground"
    else
        tbRet.type = "GameIntoBackground"
    end
    Pandora:__DoAction(tbRet)
end