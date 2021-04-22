--[[
    Class name QSoundEffect
    Create by julian 
    This class is a base class of play sound effect in battle.
--]]

local QSoundEffect = class("QSoundEffect")

local QStaticDatabase = import("..controllers.QStaticDatabase")

function QSoundEffect:ctor(soundId, options)
	assert(soundId ~= nil, "soundId is nil value")

	if options == nil then options = {} end
	
	local soundInfo = QStaticDatabase.sharedDatabase():getSoundById(soundId)
	assert(soundInfo ~= nil, soundId .." is a invalid id of sound")

	self._soundId = soundId
	-- TOFIX: SHRINK
	self._soundInfo = q.cloneShrinkedObject(soundInfo)

	-- fill default value
	if self._soundInfo.delay == nil then
		self._soundInfo.delay = options.effectDelay or 0
	else
		self._soundInfo.delay = self._soundInfo.delay + (options.effectDelay or 0)
	end
	if self._soundInfo.volume == nil then
		self._soundInfo.volume = 1.0
	end
	if self._soundInfo.count == nil then
		self._soundInfo.count = 1
	end
	if self._soundInfo.prjor == nil then
		self._soundInfo.prjor = 0
	end

	-- get sound file
	if self._soundInfo.sound == nil then
		printInfo("sound file is nil of sound id " .. soundId)
		self._soundInfo.sound = "unknow.mp3"
	end
	local suffix = string.sub(self._soundInfo.sound, -4)
	if suffix ~= ".mp3" then
		if self._soundInfo.count == 1 then
			self._soundInfo.sound = self._soundInfo.sound .. ".mp3"
		else
			local index = math.random(1, 10240) % self._soundInfo.count + 1
        	self._soundInfo.sound = self._soundInfo.sound .. "_" .. tostring(index) .. ".mp3"
		end
	end

	-- other options
	self._soundHandle = nil
    self._isLoop = false
    self._delayHandle = nil
    if options ~= nil and options.isInBattle == true and app.battle ~= nil then
    	self._schedulerInBattle = true 
    else
    	self._schedulerInBattle = false
    end
end

function QSoundEffect:play(isLoop)
	if isLoop == nil then
		isLoop = false
	end

	self._isLoop = isLoop

	if self._soundInfo.delay > 0 then
		local delayCallback = function()
				self._delayHandle = nil
				self:_doPlay()
			end
		if self._schedulerInBattle == true then
			self._delayHandle = app.battle:performWithDelay(delayCallback, self._soundInfo.delay)
		else
			self._delayHandle = scheduler.performWithDelayGlobal(delayCallback, self._soundInfo.delay)
		end
	else
		self:_doPlay()
	end
end

function QSoundEffect:_doPlay()
	if app:getSystemSetting():getSoundState() ~= "on" then
		return
	end

	if self._isLoop == true and nil ~= app.battle and device.platform == "android" then
		self._soundHandle = audio.playSound(self._soundInfo.sound, false, self._soundInfo.volume, self._soundInfo.prjor)
		self._loopHandle = app.battle:performWithDelay(handler(self, self._doPlay), self._soundInfo.duration)
	else
		self._soundHandle = audio.playSound(self._soundInfo.sound, self._isLoop, self._soundInfo.volume, self._soundInfo.prjor)
	end
end

function QSoundEffect:stop()
    if self._delayHandle ~= nil then
    	if self._schedulerInBattle == true then
    		app.battle:removePerformWithHandler(self._delayHandle)
    	else
    		scheduler.unscheduleGlobal(self._delayHandle)
    	end
    	self._delayHandle = nil
    else
    	if self._soundHandle ~= nil then
    		audio.stopSound(self._soundHandle)
    		self._soundHandle = nil
    		self._isLoop = false
    	end
    end
    if nil ~= self._loopHandle and app.battle then
    	app.battle:removePerformWithHandler(self._loopHandle)
    end
end

function QSoundEffect:stopDelay()
    if self._delayHandle ~= nil then
    	if self._schedulerInBattle == true then
    		app.battle:removePerformWithHandler(self._delayHandle)
    	else
    		scheduler.unscheduleGlobal(self._delayHandle)
    	end
    	self._delayHandle = nil
    end
end

function QSoundEffect:pause()
	if self._soundHandle ~= nil then
		audio.pauseSound(self._soundHandle)
	end
end

function QSoundEffect:resume()
	if self._soundHandle ~= nil then
		audio.resumeSound(self._soundHandle)
	end
end

function QSoundEffect:getSoundId()
	return self._soundId
end

function QSoundEffect:isLoop()
	return self._isLoop
end

return QSoundEffect

