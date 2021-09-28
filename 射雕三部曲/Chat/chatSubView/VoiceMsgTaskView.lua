--[[
文件名: VoiceMsgTaskView.lua
描述: 语音任务管理对象
创建人: liaoyuangang
创建时间: 2017.06.14
-- ]]

-- 语音Sdk异步任务队列的数据结构
--[[
    {
        {
            taskType：任务类型，取值在VoiceAsyncTaskType中定义
            filename: 上传文件时，表示需要上传文件的文件名；下载文件时，表示保存文件的文件名
            voiceId: 上传文件时，没有这个参数；下载文件时，表示需要下载语音的Id
        },
        ..
    }
]]

local VoiceMsgTaskView = class("VoiceMsgTaskView", function(params)
    return display.newLayer()
end)

-- 版本设置是否支持语音，
local IsSupportVoice = IPlatform:getInstance():getConfigItem("IsSupportVoice") == "1"
if IsSupportVoice then
    require("Chat.CloudVoiceMng")
end
    
-- 
function VoiceMsgTaskView:ctor()
    -- 输入模式
    self.mInputMode = Enums.ChatInputMode.textInput
	-- 是否获得了语音消息安全密钥key
    self.mHadVoiceKey = false
	-- 当前背景音乐的音量
    self.mMusicVolume = LocalData:getMusicVolume()
	-- 当前正在做语音异步任务
    self.mIsVoiceBusy = false
    -- 当前正在播放语音
    self.mIsPlaying = false
    -- 语音Sdk异步任务队列，数据结构参考文件头出的“语音Sdk异步任务队列的数据结构”
    self.mVoiceTaskList = {}
    -- 语音播放列表
    self.mVoicePlayList = {}

    -- 发送消息函数
    self.sendMsgFunc = nil

    -- 注册语音异步任务相关的事件
    Notification:registerAutoObserver(self, function(nodeObj, postData)
        self:dealVoiceTaskData(postData)
    end, EventsName.eVoiceAsyncTaskReturn)

    -- 注册语音播放结束的事件
    Notification:registerAutoObserver(self, function(nodeObj, postData)
        self:dealVoicePlayEnd(postData)
    end, EventsName.eVoicePlayEndPrefix)
end

-- 初始化语音sdk(GCloudVoice)
--[[
-- 参赛
    applyKeyCallback: 获取语音消息安全密钥key信息结果的回调applyKeyCallback(self.mHadVoiceKey)
]]
function VoiceMsgTaskView:initGVoice(applyKeyCallback)
    if not IsSupportVoice or self.mHadVoiceKey then
        if applyKeyCallback then
            applyKeyCallback(self.mHadVoiceKey)
            applyKeyCallback = nil -- 每次initGVoice只回调一次 
        end
        return 
    end
    require("Chat.CloudVoiceMng")

    CloudVoiceMng:init()
    CloudVoiceMng:setMode(gv.GCloudVoiceMode.Translation)
    CloudVoiceMng:ApplyMessageKey()

    -- 获取语音消息安全密钥key信息成功
    Notification:registerAutoObserver(self, function(nodeObj, postData)
        local completeCode = postData and postData.completeCode or -1
        if completeCode == gv.GCloudVoiceCompleteCode.GV_ON_MESSAGE_KEY_APPLIED_SUCC then
            self.mHadVoiceKey = true

            CloudVoiceMng:SetMaxMessageLength(1 * 60 * 1000) 
            CloudVoiceMng:SetSpeakerVolume(300)
        else
            local tempStr = gv.GCloudVoiceErrnoHint[completeCode] or TR("获取语音消息安全密钥失败，错误码(%d)", completeCode)
            ui.showFlashView(TR("提示：%s", tempStr))
        end    

        -- 回调通知获取语音消息安全密钥key的结果 
        if applyKeyCallback then
            applyKeyCallback(self.mHadVoiceKey)
            applyKeyCallback = nil -- 每次initGVoice只回调一次 
        end  
    end, EventsName.eVoiceApplyMessageKeyReturn)
end

-- 检查执行语音异步任务
function VoiceMsgTaskView:checkVoiceTask()
    if self.mIsVoiceBusy or #self.mVoiceTaskList == 0 then
        return 
    end
    local firstItem = self.mVoiceTaskList[1]
    table.remove(self.mVoiceTaskList, 1)

    local errno
    if firstItem.taskType == VoiceAsyncTaskType.eUpload then
        errno = CloudVoiceMng:UploadRecordedFile(firstItem.filename)
    elseif firstItem.taskType == VoiceAsyncTaskType.eDownload then
        errno = CloudVoiceMng:DownloadRecordedFile(firstItem.voiceId, firstItem.filename)
    elseif firstItem.taskType == VoiceAsyncTaskType.eSpeechToText then
        errno = CloudVoiceMng:SpeechToText({voiceId = firstItem.voiceId})
    end

    if errno == gv.GCloudVoiceErrno.GCLOUD_VOICE_SUCC then
        self.mIsVoiceBusy = true
    elseif errno then
        local tempStr = gv.GCloudVoiceErrnoHint[errno] or TR("未知错误")
        local hintStr = TR("提示：%s, 请稍后重试！", tempStr)

        local okBtnInfo = {
            text = TR("重试"),
            clickAction = function(msgLayer, btnObj)
                LayerManager.removeLayer(msgLayer)
                table.insert(self.mVoiceTaskList, 1, firstItem)
                self:checkVoiceTask()
            end
        }

        local cancelBtnInfo = {
            text = TR("取消"),
            clickAction = function(msgLayer, btnObj)
                LayerManager.removeLayer(msgLayer)
                self:checkVoiceTask()
            end
        }

        MsgBoxLayer.addOKCancelLayer(hintStr, TR("提示"), okBtnInfo, cancelBtnInfo, nil, false, true)
    else
        self:checkVoiceTask()
    end
end

-- 添加上传语音文件任务
function VoiceMsgTaskView:addUploadTask(recordFilename)
    local tempItem = {
        taskType = VoiceAsyncTaskType.eUpload,
        filename = recordFilename,
        voiceId = nil,
    }
    table.insert(self.mVoiceTaskList, tempItem)

    -- 检查执行语音异步任务
    self:checkVoiceTask()
end

-- 添加下载语音文件任务
function VoiceMsgTaskView:addDownloadTask(voiceId)
    local tempItem = {
        taskType = VoiceAsyncTaskType.eDownload,
        filename = string.format("%s.spx", tostring(os.time())),
        voiceId = voiceId,
    }
    table.insert(self.mVoiceTaskList, tempItem)

    -- 检查执行语音异步任务
    self:checkVoiceTask()
end

-- 添加语音转文字任务
function VoiceMsgTaskView:addSpeechToTextTask(voiceId, filename)
    local tempItem = {
        taskType = VoiceAsyncTaskType.eSpeechToText,
        filename = filename,
        voiceId = voiceId,
    }
    -- 语音转文字任务优先执行
    table.insert(self.mVoiceTaskList, 1, tempItem)

    -- 检查执行语音异步任务
    self:checkVoiceTask()
end

-- 处理语音异步任务返回数据
function VoiceMsgTaskView:dealVoiceTaskData(retData)
    self.mIsVoiceBusy = false

    -- 错误提示框
    local function showHintMsgBox(completeCode,  retryData)
        local tempStr = gv.GCloudVoiceErrnoHint[completeCode] or TR("未知错误")
        local hintStr = TR("提示：%s, 请稍后重试！", tempStr)
        local okBtnInfo = {
            text = TR("重试"),
            clickAction = function(msgLayer, btnObj)
                LayerManager.removeLayer(msgLayer)
                
                table.insert(self.mVoiceTaskList, 1, retryData)
                -- 执行下一个任务
                self:checkVoiceTask()
            end
        }
        local cancelBtnInfo = {
            text = TR("取消"),
            clickAction = function(msgLayer, btnObj)
                LayerManager.removeLayer(msgLayer)
                -- 执行下一个任务
                self:checkVoiceTask()
            end
        }
        MsgBoxLayer.addOKCancelLayer(hintStr, TR("提示"), okBtnInfo, cancelBtnInfo, nil, false, true)
    end 

    retData = retData or {}
    if retData.taskType == VoiceAsyncTaskType.eUpload then -- 文件上传成功
        if retData.completeCode == gv.GCloudVoiceCompleteCode.GV_ON_UPLOAD_RECORD_DONE then
            -- 如果是在语音转文字的模式下需要调用语音转文字的接口
            self:addSpeechToTextTask(retData.voiceId, retData.filename)
        else
            showHintMsgBox(retData.completeCode, {
                taskType = VoiceAsyncTaskType.eUpload,
                filename = retData.filename,
            })
        end
    elseif retData.taskType == VoiceAsyncTaskType.eDownload then -- 文件下载成功
        if retData.completeCode == gv.GCloudVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE then -- 下载文件成功
            self:addVoicePlay(retData.filename, retData.voiceId)
        end
        -- 执行下一个任务
        self:checkVoiceTask()
    elseif retData.taskType == VoiceAsyncTaskType.eSpeechToText then -- 语音转文字成功
        if retData.completeCode == gv.GCloudVoiceCompleteCode.GV_ON_STT_SUCC then
            local filename = CloudVoiceMng:getFilenameByVoiceId(retData.voiceId)
            if self.mInputMode == Enums.ChatInputMode.voiceInput then
                -- 语音模式需要获取语音的播放时间 
                local fileInfo = CloudVoiceMng:GetFileParam(filename)
                fileInfo.VoiceId = retData.voiceId
                if self.sendMsgFunc then
                	self.sendMsgFunc(retData.text, cjson.encode(fileInfo))
               	end
            else
                -- 转换文字成功后把语音文件删掉
                CloudVoiceMng:deleteRecordFile(filename)
                if self.sendMsgFunc then
                	self.sendMsgFunc(retData.text, "")
                end
            end
            
            -- 执行下一个任务
            self:checkVoiceTask()
        else
            showHintMsgBox(retData.completeCode, {
                taskType = VoiceAsyncTaskType.eSpeechToText,
                voiceId = retData.voiceId,
            })
        end
    end
end

-- 检查播放语音
function VoiceMsgTaskView:checkPlayVoice()
    if self.mIsPlaying or #self.mVoicePlayList == 0 then
        if not self.mIsPlaying then
            LocalData:setMusicVolume(self.mMusicVolume)
        end
        return 
    end
    LocalData:setMusicVolume(self.mMusicVolume)
    
    local firstItem = self.mVoicePlayList[1]
    table.remove(self.mVoicePlayList, 1)

    if firstItem.filename and firstItem.filename ~= "" then
        self.mIsPlaying = true
        CloudVoiceMng:PlayRecordedFile(firstItem.filename)

    elseif firstItem.voiceId and firstItem.voiceId ~= "" then
        if CloudVoiceMng:haveLocalFile(firstItem.voiceId) then
            self.mIsPlaying = true
            LocalData:setMusicVolume(10)
            CloudVoiceMng:PlayRecordedByFileId(firstItem.voiceId)
        else
            self:addDownloadTask(firstItem.voiceId)
        end
    end

    -- 如果没有播放成功，则播放下一条
    if not self.mIsPlaying then
        self:checkPlayVoice()
    end
end

-- 添加语音播放任务
--[[
-- 参数
    filename: 语音文件名
    voiceId: 语音Id
    isPriority: 是否优先播放
]]
function VoiceMsgTaskView:addVoicePlay(filename, voiceId, isPriority)
    local tempItem = {
        voiceId = voiceId,
        filename = filename,
    }
    if isPriority then
        table.insert(self.mVoicePlayList, 1, tempItem)
        -- 停止播放当前这条
        self.mIsPlaying = false
        CloudVoiceMng:StopPlayFile()
    else
        table.insert(self.mVoicePlayList, tempItem)
    end

    -- 检查播放下一条
    self:checkPlayVoice()
end

-- 处理语音播放结束的事件
function VoiceMsgTaskView:dealVoicePlayEnd(retData)
    self.mIsPlaying = false
    -- 检查播放下一条
    self:checkPlayVoice()
end

-- 清空任务
function VoiceMsgTaskView:clearTask()
	-- 需要删除语音异步任务列表和删除语音播放列表
    self.mVoiceTaskList = {}
    self.mVoicePlayList = {}
    -- 停止播放语音
    self.mIsPlaying = false
    if IsSupportVoice then
        CloudVoiceMng:StopPlayFile()
    end
end

-- 判断是否支持语音
function VoiceMsgTaskView:isSupportVoice()
	return IsSupportVoice
end

-- 判断是否已获取语音消息安全密钥key
function VoiceMsgTaskView:getHadVoiceKey()
	return self.mHadVoiceKey
end

-- 设置发送消息的函数
function VoiceMsgTaskView:setSendMsgFunc(sendMsgFunc)
	-- 发送消息函数
    self.sendMsgFunc = sendMsgFunc
end

-- 设置当前的输入模式
--[[
-- 参数
    inputMode: 当前输入模式，取值在“Enums.lua”中的“Enums.ChatInputMode” 枚举
]]
function VoiceMsgTaskView:setInputMode(inputMode)
    self.mInputMode = inputMode
end

-- 获取当前的输入模式
function VoiceMsgTaskView:getInputMode()
    return self.mInputMode
end

return VoiceMsgTaskView