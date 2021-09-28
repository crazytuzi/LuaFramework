-- Filename: 	RecordUtil.lua
-- Author: 		chengliang
-- Date: 		2015-04-07
-- Purpose: 	语音聊天相关工具

module("RecordUtil", package.seeall)

require "script/ui/chat/ChatCache"

local RECORDER_URL = "http://audiochat.zuiyouxi.com:8001/"

if(g_debug_mode == true)then
	RECORDER_URL = "192.168.1.91:3333/"
end

HTTP_CODE_ERR				= -1 	--请求出错
-- 语音相关错误
EERRO_CODE_OK 				= 0 	--正常
EERRO_CODE_INTER 			= 1 	--服务器内部错误
EERRO_CODE_ADD_AUDIO 		= 2		--存储语音失败
EERRO_CODE_NOT_FOUND_AUDIO 	= 4		--没有找到语音
EERRO_CODE_NOT_FOUND_ASR 	= 8		--没有找到识别结果
EERRO_CODE_WAIT_ASR 		= 16	--识别中

local err_desc_table = {}
err_desc_table[HTTP_CODE_ERR]				= GetLocalizeStringBy("key_10148")
err_desc_table[EERRO_CODE_INTER] 			= GetLocalizeStringBy("key_10149")
err_desc_table[EERRO_CODE_ADD_AUDIO] 		= GetLocalizeStringBy("key_10150")
err_desc_table[EERRO_CODE_NOT_FOUND_AUDIO] 	= GetLocalizeStringBy("key_10151")
err_desc_table[EERRO_CODE_NOT_FOUND_ASR] 	= GetLocalizeStringBy("key_10152")
err_desc_table[EERRO_CODE_WAIT_ASR] 		= GetLocalizeStringBy("key_10153")


local kFlagAudio 	= 1 	-- 只请求录音
local kFlagText 	= 2 	-- 只请求识别文本
local kFlagBoth		= 3 	-- 录音和文本都请求

-- 
local kFlagRecordYes 	= 1  	-- 支持录音
local kFlagRecordNo 	= 2 	-- 不支持录音
local kFlagRecordTip 	= 3 	-- 支持但是这个包不支持，需要更新底包


local _isInitSuc 	= false 	-- 是否初始化成功，


--  获得错误描述
function getErrDesc( errno )
	print("errno==", errno)
	print_t(err_desc_table)
	errno = tonumber(errno)
	local errDess = err_desc_table[errno] or GetLocalizeStringBy("key_10154")
	return errDess
end

-- 初始化
function initRecord()
	if(getSupportRecordStatus() ~= kFlagRecordYes)then
		return
	end
	if( _isInitSuc == false )then
		_isInitSuc = CAudioRecordAndPlay:getInstance():init(false)
	end
	return _isInitSuc
end

function isInitSuccess()
	return _isInitSuc
end

-- 开始录音
function startRecord( ... )
	initRecord()
	if(getSupportRecordStatus() ~= kFlagRecordYes)then
		return
	end
	return CAudioRecordAndPlay:getInstance():startRecording()
end

-- 结束录音
function stopRecord( ... )
	if(getSupportRecordStatus() ~= kFlagRecordYes)then
		return
	end
	local a_length = 0
	return CAudioRecordAndPlay:getInstance():stopRecording(a_length)
end

-- 播放录音
function playRecordBy( aid, p_callback )
	initRecord()
	if(getSupportRecordStatus() ~= kFlagRecordYes)then
		return
	end
	local recorder = ChatCache.getAudioBy(aid)
	if(recorder)then
		print("playRecordBy", aid)
		CAudioRecordAndPlay:getInstance():startPlayout(recorder, p_callback, 0)
	else
		LoadingUI.addLoadingUI()
		getSvrRecordById(aid, function( status, json_table, audio_data  )
			if(status ~= 0)then
				p_callback(-1)
			else
				if(tonumber(json_table.ret) == 0)then
					ChatCache.addAudioBy(aid, audio_data)
					playRecordBy(aid, p_callback)
				else
					p_callback(tonumber(json_table.ret))
				end
			end
			LoadingUI.reduceLoadingUI()
		end)
	end
end

-- 停止播放
function stopPlayRecord()
	if(getSupportRecordStatus() ~= kFlagRecordYes)then
		return
	end
	CAudioRecordAndPlay:getInstance():stopPlayout()
end

-- 发送录音
function sendRecorder( recordData, p_ms, p_callback )
	local arrField = {
						ms 		= p_ms,
						len 	= string.len(recordData),
						pid 	= Platform.getPid(),
						time 	= TimeUtil.getSvrTimeByOffset(),
					}
	local hashStr = "pid" .. arrField.pid .. "ms" .. arrField.ms .. "len" .. arrField.len.. "time" .. arrField.time .. "dfae8d317f6536"
	arrField.hash = BTUtil:getMd5SumByString(hashStr)

	local cjson = require "cjson"
	local jsonStr = cjson.encode(arrField)
	print("jsonStrjsonStrjsonStr==", jsonStr)
	local len = string.len(jsonStr)
    local b4 = string.char( len % 256 );
    len  =  math.floor(len / 256);
    local b3 = string.char( len % 256 );
    len  =  math.floor(len / 256);
    local b2 = string.char( len % 256 );
    len  =  math.floor(len / 256);
    local b1 = string.char( len % 256 );
    local postData = b1..b2..b3..b4.. jsonStr .. recordData

    local url = RECORDER_URL .. '?method=audio.send'
    Logger.debug('url:%s,string.len:%s, postData:%s' , url,string.len(postData), postData )

    local httpClient =  CCHttpRequest:open(url, kHttpPost, postData)
    local arrHeader = CCArray:create()
    arrHeader:addObject(CCString:create("Expect:"))
    httpClient:setHeaders(arrHeader)
    httpClient:sendWithHandler(
        function(res, hnd)
                local status = res:getResponseCode()
                Logger.debug('sendAudio. status:%d ' , status )
                if ( status == 200  ) then
                	local data = res:getResponseData()
                	Logger.debug('sendAudio. status:%d, data:%s' , status, data )
                    p_callback(0, data)
                else
                    p_callback(-1)
                end
        end
    )
end

-- 当前录音分贝
function getCurVoiceLevel()
	local v_level = 0
	local v_DB = CAudioRecordAndPlay:getInstance():getCurRecordDbLevel()
	if(v_DB >-20)then
		v_level = 5
	elseif(v_DB >-35)then
		v_level = 4
	elseif(v_DB >-55)then
		v_level = 3
	elseif(v_DB >-65)then
		v_level = 2
	elseif(v_DB >-80)then
		v_level = 1
	else
		v_level = 0
	end
	print("getCurVoiceLevel: v_DB=%d, v_level=%d", v_DB, v_level)
	return v_level
end

-- 获取录音
function getSvrRecordById( aid, p_callback )
	getSvrRecordOrTextBy(aid, kFlagAudio, p_callback)
end

-- 获取识别文字
function getSvrRecordTextById( aid, p_callback )
	getSvrRecordOrTextBy(aid, kFlagText, p_callback)
end

-- 获取录音 or 识别文字 flag: 1:语音，2：识别结果，3：两个都要
function getSvrRecordOrTextBy( aid, flag, p_callback )
	local url = RECORDER_URL .. "?method=audio.get&id=".. aid .. "&flag=" .. flag
	CCHttpRequest:open(url, kHttpGet):sendWithHandler(
        function(res, hnd)
                local status = res:getResponseCode()
                Logger.debug('audio.get:%d ' , status )
                if ( status == 200  ) then
                	local data = res:getResponseData()
                	Logger.debug('audio.get:%d, data:%s' , status, data )
                	local jsonLen = string.byte( data, 1)
				    jsonLen = jsonLen * 256 + string.byte( data, 2)
				    jsonLen = jsonLen * 256 + string.byte( data, 3)
				    jsonLen = jsonLen * 256 + string.byte( data, 4)

				    if jsonLen > string.len(data) - 4 then
				        Logger.warning("invalid data:%s", data)
				        p_callback(-1)
				        return
				    end

				    local jsonStr = string.sub(data, 5, jsonLen+4)

				    local audio_data = string.sub(data, jsonLen+5, string.len(data))
				    local cjson = require "cjson"
				    local dataJson = cjson.decode( jsonStr )
				    print_t(dataJson)
                    p_callback(0, dataJson, audio_data)
                else
                    p_callback(-1)
                end
        end
    )
end


-- 屏蔽 录音
function isRecordOpen()
	if(kFlagRecordNo == getSupportRecordStatus())then
		return false
	else
		return true
	end
end

-- 打开了但是底包不支持 逗比兼容问题
function isSupportRecord()
	return getSupportRecordStatus() == kFlagRecordYes
end

-- 屏蔽 录音
function getSupportRecordStatus()
	local c_stauts = nil
	if(g_system_type == kBT_PLATFORM_IOS or g_system_type == kBT_PLATFORM_ANDROID) then
		if(CAudioRecordAndPlay ~= nil)then
			c_stauts = kFlagRecordYes
		else
			-- 底包不支持 录音类
			c_stauts = kFlagRecordTip
		end
	else
		-- wp 不支持语音
		c_stauts = kFlagRecordNo
	end

	c_stauts = kFlagRecordNo
	print("c_stauts===", c_stauts)
	return c_stauts
end

--  ios设备是否已经授权
function isRecordPermisson()
	local isPermisson = true
	if(g_system_type == kBT_PLATFORM_IOS)then
		isPermisson = CCUserDefault:sharedUserDefault():getBoolForKey("check_record_permisson")
	end
	return isPermisson
end


local pack_url_arr = {}
-- pack_url_arr["chphone_test"]		= "http://bcs.91.com/rbreszy/iphone/soft/2015/4/24/24f36a76929c4ad48b35029aa6718155/com.babeltime.91.ios.sango_4.2.6_4.2.6_635654936929990428.ipa"
-- pack_url_arr["91phone"]		= "http://bcs.91.com/rbreszy/iphone/soft/2015/4/24/24f36a76929c4ad48b35029aa6718155/com.babeltime.91.ios.sango_4.2.6_4.2.6_635654936929990428.ipa"
-- pack_url_arr["dlphone"]		= "http://res5.d.cn/6675bec3c11fecc85be912f8f4d16d529ba71d10dc641ea28c4cdcfd3f40117e8bee7b68c8cd7ba24c9607bfe8d32714d5bc81bc4608de9e.ipa?f=web"
-- pack_url_arr["itoolsphone"]	= "http://c-dxms1.itools.hk:9080/ipa/49/60/10087_10011_2.ipa"
pack_url_arr["kyphone"]		= "http://iphoneapp.kuaiyong.com/m/com.babeltime.kuaiyong.ios.sango"
pack_url_arr["ppphone"]		= "http://ios.25pp.com/app/1088347/"
-- pack_url_arr["tbtphone"] 	= "http://app.tongbu.com/10003971_fangkainasanguo.html"
-- pack_url_arr["ppsphone"]	= "http://cdn.data.video.iqiyi.com/cdn/ppsgame/20150423/upload/unite/pps/IOS/fknsg/0423/fknsg0423.ipa"
pack_url_arr["haima"]		= "http://game.haimawan.com/Details.aspx?fromPage=webgame&sw_id=a9292625-b699-4fe0-a36f-8167c3528e48&t=0#"
pack_url_arr["aszhushou"]	= "http://d.app6.i4.cn/soft/2015/04/27/15/s1430119948131_107494.ipa"
pack_url_arr["xyzhushou"]	= "http://www.xyzs.com/app/100000300.html"
-- pack_url_arr["360iosphone"]	= "http://down.coolsrv.com/150427/b679f6fda39f04980c6a18a59327a9fa/com.babeltime.360.ios.sango_4.2.6.ipa"


-- 显示下载
function showDownloadTip()

	local downloadUrl = pack_url_arr[Platform.getPlName()] or CheckVerionLogic.getPackDownloadUrl()
	if(downloadUrl == nil)then
		return
	end

	local function tipFunc( is_corform)
		print("downloadUrl == ",downloadUrl)
		if(is_corform == true)then
			Platform.openUrl(downloadUrl)
		end
	end 
	AlertTip.showAlert(GetLocalizeStringBy("cl_1018"),tipFunc, false, nil, GetLocalizeStringBy("cl_1019"), GetLocalizeStringBy("cl_1020"))
	return
end

