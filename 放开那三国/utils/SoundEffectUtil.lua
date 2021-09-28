-- FileName: SoundEffectUtil.lua 
-- Author: licong 
-- Date: 16/6/2 
-- Purpose: 游戏内音效 


module("SoundEffectUtil", package.seeall)

local _lastEffectId = nil

--[[
	@des 	: 播放英雄语音
	@param 	: 
	@return : 
--]]
function playHeroAudio(pAudioName)
	if(pAudioName == nil)then
		print("新手语音:",pAudioName)
		return
	end
	require "script/audio/AudioUtil"
	-- 先停止上一步音效
	if(_lastEffectId)then
		AudioUtil.stopEffect(_lastEffectId)
	end
	-- 播放音效
	local pathStr = "audio/sound/" .. pAudioName
	print("新手语音:",pathStr)
    _lastEffectId = AudioUtil.playEffect(pathStr)
end

--[[
	@des 	: 停掉英雄语音
	@param 	: 
	@return : 
--]]
function stopHeroAudio()
	require "script/audio/AudioUtil"
	-- 先停止上一步音效
	if(_lastEffectId)then
		AudioUtil.stopEffect(_lastEffectId)
	end
end


--[[
	@des 	: 得到英雄语音配置
	@param 	: 
	@return : 
--]]
function getHeroAudioDataByHtid(pHtid)
	require "db/DB_Herossound"
	local retData = DB_Herossound.getDataById(pHtid)
	return retData
end