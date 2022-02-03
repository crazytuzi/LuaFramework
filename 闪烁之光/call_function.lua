----------------------------------------------------
---- 对外调用接口
---- @author cloud
---- @date   2016.12.26
------------------------------------------------------
IS_NEW_VERSION = nil -- 是否有新版本
AUDIO_RECORD_TYPE = 10   -- 0原录音机制 10新录音机制
-- if PLATFORM == cc.PLATFORM_OS_WINDOWS then
--     AUDIO_RECORD_TYPE = 0
-- end
AUDIO_RECORD_FILE = "zsyz" -- 录音生成文件
AUDIO_WAV_FILE_ENCODE_OUT = "zsyz_encode_out.wav" -- 打包压缩文件
AUDIO_WAV_FILE_DECODE_IN = "zsyz_decode_in.wav"   -- 接收到压缩文件

--防错设置 ChatHelp 迁移到这里
function getChatFileName(name)
    if AUDIO_RECORD_TYPE == 10 then
        return string.format("%s%s", string.gsub(name, "-", "_"), ".wav")
    else
        return string.format("%s%s", string.gsub(name, "-", "_"), ".mp3")
    end
end
-- 语音压缩
function callSpeexEncode(infile, outfile)
    infile = infile or PathTool.getVoicePath(getChatFileName(AUDIO_RECORD_FILE)) --ChatHelp.formatFileName(AUDIO_RECORD_FILE)
    outfile = outfile or PathTool.getVoicePath(AUDIO_WAV_FILE_ENCODE_OUT)
    print("speex_encode=====", infile, outfile)
    return cc.CCGameLib:getInstance():speex_encode(infile, outfile)
end

-- 语音解压
function callSpeexDecode(infile, outfile)
    if PLATFORM == cc.PLATFORM_OS_WINDOWS or PLATFORM == cc.PLATFORM_OS_MAC then return end
    infile = infile or PathTool.getVoicePath(AUDIO_WAV_FILE_DECODE_IN)
    print("speex_decode=====", infile, outfile)
    cc.CCGameLib:getInstance():speex_decode(infile, outfile)
end

-- 讯飞语音初始化
function callSpeechInit()
    -- if PLATFORM == cc.PLATFORM_OS_WINDOWS then return end
    if not _callSpeechInit then
        _callSpeechInit = true
        print("callSpeechInit====")
        sdkCallFunc("speechInit", "", 0, 0, "")
    end
end

-- 讯飞语音翻译处理
function callSpeechRecognizeDo(name, fun)
    callSpeechRecognize(name, readBinaryFile(PathTool.getVoicePath(AUDIO_RECORD_FILE..".wav")))
    _speech_recognize_fun = fun
end

-- 讯飞语音识别文件
function callSpeechRecognizeFile(key, filepath)
    callSpeechInit()
    sdkCallFunc("speechRecognize", filepath, 0, 0, key)
end

-- 讯飞语音识别
function callSpeechRecognize(key, audioData, len)
    if PLATFORM == cc.PLATFORM_OS_WINDOWS then return end
    callSpeechInit()
    len = len or string.len(audioData)
    print("speechRecognize=====>>>", key, len)
    cc.GameDevice:speechRecognize(key, audioData, len)
end

-- 讯飞语音识别结果回调
function callBackSpeech(code, msg) 
    print("callBackSpeech=====", code, msg)
    -- message("["..code.."]"..msg)
    if _speech_recognize_fun and code == 0 then
        _speech_recognize_fun(msg)
    end
    _speech_recognize_fun = nil
end

-- 录音初始化,这里需要动态判断一下权限....
function callAudioInit(filepath, rate, force)
    filepath = filepath or PathTool.getVoicePath(ChatHelp.formatFileName(AUDIO_RECORD_FILE))
    rate = rate or 16000
    if not _callAudioInit then
        _callAudioInit = true
        print("callAudioInit=====", filepath, rate)
        sdkCallFunc("audioInit", filepath, rate, 2, "")
        delayOnce(function() sdkCallFunc("audioStart", "", 0, 0, "") end, 0.1)
        delayOnce(function() 
            sdkCallFunc("audioStop", "", 0, 0, "") 
            delayOnce(function() 
                AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.SCENE, "s_001", true)
            end, 0.1)
        end, 0.2)
    elseif force then
        sdkCallFunc("audioInit", filepath, rate, 0, "")
    end
end

-- 开始录音
function callAudioStart()
    print("callAudioStart=====")
    if AUDIO_RECORD_TYPE == 10 then
        if sdkCallFunc("audioStart", "", 0, 0, "") ~= 1 then
            print("录音开始失败")
            __audio_record_err = (__audio_record_err or 0) + 1
            if __audio_record_err > 2 then
                callAudioInit(nil, nil, true)
            end
        else
            __audio_record_err = 0
        end
    else
        cc.FmodexManager:startRecord(AUDIO_RECORD_FILE, AUDIO_RECORD_TYPE)
    end
end

-- 停止录音
function callAudioStop()
    print("callAudioStop=====")
    if AUDIO_RECORD_TYPE == 10 then
        sdkCallFunc("audioStop", "", 0, 0, "")
    else
        cc.FmodexManager:stopRecord()
    end
end

-- 设置语音大小
function callAudioSetVolume(vol)
    print("callAudioSetVolume=====", vol)
    local voice_open = SysEnv:getInstance():getBool(SysEnv.keys.voice_is_open,true)
    print("---------voice_open--callfunction---",voice_open)
    if voice_open then
        sdkCallFunc("audioSetVolume", "", vol, 0, "")
    else
        sdkCallFunc("audioSetVolume", "", 0, 0, "")
    end
end

-- 获取语音大小
function callAudioGetVolume()
    print("callAudioGetVolume=====")
    return sdkCallFunc("audioGetVolume", "", 0, 0, "")
end

-- 判断当前是否在录音
function callAudioIsRecording()
    print("callAudioIsRecording=====")
    return sdkCallFunc("audioIsRecording", "", 0, 0, "") == 1
end

-- 打开相机
function callWebcamTakePhoto(filepath, filename)
    if CAN_USE_CAMERA == true then    -- 旧版本不支持
        filepath = filepath or PathTool.getPhotoPath()
        filename = filename or "photo.jpg"
        if IS_IOS_PLATFORM == true then
            sdkCallFunc("webcam", filepath, 3, 0, filename)
        else
            if callFunc("checkcamera") == "true" then
                sdkCallFunc("webcam", filepath, 3, 0, filename)
            else
                message(TI18N("未获取相机权限"))
            end
        end
    else
        if IS_IOS_PLATFORM == true then
            message(TI18N("该功能需最新版本安装包才可使用，请耐心等待。"))
        else
            message(TI18N("请下载最新的安装包进行游戏体验，非常抱歉给你带来不好的游戏体验。"))
        end
    end
end

-- 打开相册
function callWebcamOpenPhotoGallery(filepath, filename)
    if CAN_USE_CAMERA == true then      -- 旧版本不支持
        filepath = filepath or PathTool.getPhotoPath()
        filename = filename or "photo.jpg"
        if IS_IOS_PLATFORM == true then
            sdkCallFunc("webcam", filepath, 4, 0, filename)
        else
            if callFunc("checkcamera") == "true" then
                sdkCallFunc("webcam", filepath, 4, 0, filename)
            else
                message(TI18N("未获取相机权限"))
            end
        end
    else
        if IS_IOS_PLATFORM == true then
            message(TI18N("该功能需最新版本安装包才可使用，请耐心等待。"))
        else
            message(TI18N("请下载最新的安装包进行游戏体验，非常抱歉给你带来不好的游戏体验。"))
        end
    end
end

-- 保存图片到相册
function saveImageToPhoto(file, num)
    sdkCallFunc("savePhoto", file, num)
end

-- 拍照相关回调
function callBackWebcam(code, msg)
    print("callBackWebcam======", code, msg)
    if code ~= 0 then
        message(msg)
    else
        MainuiController:getInstance():updateCustomHeadImg(msg)  -- 选择好头像之后,准备上传,这里其实还有一个就是展示头像,等有UI之后做处理
    end
end

-- 这个接口暂时不知道哪里调用,
function OnPhotoReceive( state, filepath )
    print(state, filepath)
    if state == 1 then
        MainuiController:getInstance():updateCustomHeadImg(msg)
    end
end

-- cos下载自定义头像返回
function cosDownloadImageCallback(code, msg)
end

-- cos上传自定义头像成功
function cosUploadImageCallback(code, msg)
    if code == 0 then
        if PLATFORM_NAME == "release2" then
            CommonAlert.show(string.format("头像上传失败：%s", msg), TI18N("确定"))
        else
            message(TI18N("上传图片失败"))
        end
    else
        RoleController:getInstance():tellServerCustomSuccess()
    end
end

-- 获取设备号
function callIDFA()
    return callFunc("idfa")
end

-- 获取绑定手机号 为空表示未绑定
function getBindPhone()
    return callFunc("getBindPhone")
end

-- 绑定手机号  code='' 时 请求验证码
function bindPhone(number, code, func)
    if number == nil or number == "" then return end
    __bind_phone_back_func = func
    callFunc("bindPhone", number, 0, 0, code)
end

-- 绑定手机号返回信息
function bindPhoneBack(code, msg)
    if __bind_phone_back_func then
        __bind_phone_back_func(code, msg)
        __bind_phone_back_func = nil
    end
end

-- 弹出实名验证窗口
function showRealNameWindow()
    -- callFunc("displayRealNameWindow")
    callFunc("realNameVerify")
end

-- 请求实名验证信息
function queryRealNameInfo()
    return callFunc("queryRealName")
end

-- 实名验证成功回调 (age =< 0 未验证, >0验证)
function sdkBackRealName(age, msg)
    if age <= 0 then
        age = 0
        DO_NOT_REALNAME_STATUS = true               -- 未实名认证
    else
        DO_NOT_REALNAME_STATUS = false              -- 已经认证了
        OPEN_SDK_VISITIOR_WINDOW = false            -- 认证窗体关掉
        NEED_OPEN_OPEN_SDK_VISITIOR_WINDOW = false  -- 不需要打开认证窗体了
    end
    RoleController:getInstance():sender10395(age)
end

-- 文本分享(scene 0:好友对话 1:朋友圈 2:收藏)
function wxShareText(text, scene)
    callFunc("wx_share_text", text, scene or 1)
end

-- 图片分享(scene 0:好友对话 1:朋友圈 2:收藏)
function wxSharePhoto(title, content, photoPath, thumbPath, scene, thumbWidth)
    thumbPath = thumbPath or photoPath
    local info = table.concat({title, content, photoPath, thumbPath}, "#")
    callFunc("wx_share_photo", info, scene or 1, thumbWidth or 200)
end

-- URL分享(scene 0:好友对话 1:朋友圈 2:收藏)
function wxShareUrl(title, content, url, thumbPath, scene, thumbWidth)
    local info = table.concat({title, content, url, thumbPath}, "#")
    callFunc("wx_share_url", info, scene or 1, thumbWidth or 200)
end

-- 微信分享结果 (code, 0:成功 1:失败)
function wxShareBack(code, msg)
    game_print("wxShareBack===>", code, msg)
    message(msg)
    if code == 0 then
        PartnersummonController:getInstance():send23203()
    end
end

-- 公共调用接口 返回相应字符串
function callFunc(funname, str1, num1, num2, str2)
    if not cc.GameDevice.callFunc then return "" end
    if funname == nil or funname == "" then return "" end
    str1 = str1 or ""
    num1 = num1 or 0
    num2 = num2 or 0
    str2 = str2 or ""
    -- print("callfunc==", funname, str1, num1, num2, str2)
    return cc.GameDevice:callFunc(funname, str1, num1, num2, str2)
end
