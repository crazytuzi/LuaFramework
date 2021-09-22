local GameMusic={}

GameMusic.cache={}
GameMusic.musicName=""
GameMusic.effstate = true
GameMusic.musstate = true

local preloadlist = {
"music/55.mp3",
"music/54.mp3",
"music/53.mp3",
"music/52.mp3",
"music/51.mp3",
"music/50.mp3",
"music/49.mp3",
"music/48.mp3",
"music/47.mp3",
"music/46.mp3",
"music/45.mp3",
"music/44.mp3",
"music/43.mp3",
"music/42.mp3",
"music/41.mp3",
"music/40.mp3",
"music/39.mp3",
"music/38.mp3",
"music/37.mp3",
"music/36.mp3",
"music/35.mp3",
"music/34.mp3",
"music/33.mp3",
"music/32.mp3",
"music/31.mp3",
"music/30.mp3",
"music/29.mp3",
"music/28.mp3",
"music/27.mp3",
"music/26.mp3",
"music/25.mp3",
"music/24.mp3",
"music/23.mp3",
"music/22.mp3",
"music/21.mp3",
"music/20.mp3",
"music/19.mp3",
"music/18.mp3",
"music/17.mp3",
"music/16.mp3",
"music/15.mp3",
"music/14.mp3",
"music/13.mp3",
"music/12.mp3",
"music/11.mp3",
"music/10.mp3",
"music/9.mp3",
"music/8.mp3",
"music/7.mp3",
"music/6.mp3",
"music/5.mp3",
"music/4.mp3",
"music/3.mp3",
"music/2.mp3",
"music/1.mp3",
}

function GameMusic.preload()
	for k,v in ipairs(preloadlist) do
		ccexp.AudioEngine.preload(v)
	end
end

function GameMusic.mapMusic(mapid)
	if PLATFORM_BANSHU then return end

	if G_SwitchMusic > 0 or not music or not GameMusic.musstate then 
		return
	end

	-- local music="music/map_dongxue.mp3"
	
	-- if mapid=="v217" or mapid=="v218" then
	-- 	music="music/map_shaba.mp3"
	-- elseif mapid=="v001" or mapid=="v003" then
	-- 	music="music/map_yewai.mp3"
	-- elseif mapid=="v002" then
	-- 	music="music/map_cheng.mp3"
	-- end

	GameMusic.music(music)
end

function GameMusic.music(music)
	if PLATFORM_BANSHU then return end

	if G_SwitchMusic > 0 or not music or not GameMusic.musstate then 
		return
	end

	if GameMusic.cache["music"] and GameMusic.musicName~="" then
		ccexp.AudioEngine:stop(GameMusic.cache["music"])
		GameMusic.cache["music"]=cc.AUDIO_INVAILD_ID
		ccexp.AudioEngine:uncache(GameMusic.musicName)
	end

	GameMusic.musicName = music
	GameMusic.cache["music"]=ccexp.AudioEngine:play2d(music,true,0.7)
end

function GameMusic.playcallback(id,sound)
	-- print("=====================play end:"..id.."="..sound)
	if device.platform == "ios" then
		-- if sound and GameMusic.cache[sound] then
			ccexp.AudioEngine:stop(id)
		-- end
	end
end

function GameMusic.playcallnull(id,sound)

end

function GameMusic.play(sound,volume)
	-- if PLATFORM_BANSHU then return end
	
	if not volume then volume = 0.7 end

	if G_SwitchEffect > 0 or not sound or not GameMusic.effstate then 
		return
	end

	-- if GameMusic.cache[sound] then
	-- 	ccexp.AudioEngine:setFinishCallback(GameMusic.cache[sound],GameMusic.playcallnull)
	-- end
	GameMusic.cache[sound]=ccexp.AudioEngine:play2d(sound,false,volume)
	ccexp.AudioEngine:setFinishCallback(GameMusic.cache[sound],GameMusic.playcallback)
end

function GameMusic.stop(sound)
	if sound and GameMusic.cache[sound] then
		ccexp.AudioEngine:stop(GameMusic.cache[sound])
		GameMusic.cache[sound]=cc.AUDIO_INVAILD_ID
		ccexp.AudioEngine:uncache(sound)
	end
	if sound == "music" then
		GameMusic.musicName=""
	end
end

function GameMusic.pause()

	GameMusic.effstate = false
	GameMusic.musstate = false

	-- ccexp.AudioEngine:pauseAll()
end

function GameMusic.resume()

	GameMusic.effstate = true
	GameMusic.musstate = true

	-- ccexp.AudioEngine:resumeAll()
end
function checkBackgrounM()
	-- body
	-- if GameSetting and GameSetting["getInfos"] then
	-- 	local sm=GameSetting.getInfos("G_SwitchMusic","Data")
		if G_SwitchMusic and G_SwitchMusic<1 then
			GameMusic.stop("music")
		end
	-- end
	
end
checkBackgrounM()
return GameMusic