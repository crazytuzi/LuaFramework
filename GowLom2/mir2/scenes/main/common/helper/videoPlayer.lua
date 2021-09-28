local video = class("videoPlayer")
video.setRunner = function (self, runner)
	video.runner = runner

	return 
end
video.setEvtCallback = function (self, func)
	self.evtCallback = func

	return 
end
local VideoPlayerEvent = {
	PLAYING = 0,
	STOPPED = 2,
	PAUSED = 1,
	COMPLETED = 3
}
video.play = function (self, fileName, params)
	params = params or {}
	local affix = nil

	if device.platform == "windows" then
		fileName = fileName .. ".mp4"
	else
		fileName = fileName .. ".mp4"
	end

	local fileutils = cc.FileUtils:getInstance()

	if device.platform ~= "android" then
		fileName = fileutils.fullPathForFilename(fileutils, fileName)
	end

	print("playVideo:", fileName)

	if not fileutils.isFileExist(fileutils, fileName) then
		print("Err file not exist", fileName)

		return 
	end

	local video = nil
	local evtCallback = self.evtCallback

	local function videoEventListener(sender, tag)
		if tag == VideoPlayerEvent.PAUSED then
			video:performWithDelay(function ()
				video:resume()
				video:play()

				return 
			end, 0)
		elseif tag == VideoPlayerEvent.COMPLETED or device.platform == "mac" or device.platform == "windows" then
			if evtCallback then
				evtCallback("VideoComplete")
			end

			video.stop(evtCallback)
			video:run(cca.removeSelf())
		end

		return 
	end

	local scene = cc.Director.getInstance(slot8):getRunningScene()

	scheduler.performWithDelayGlobal(function ()
		if device.platform == "mac" or device.platform == "windows" then
			video = display.newNode():add2(scene):center()

			video:performWithDelay(handler(video, videoEventListener), 5)
			an.newLabel(string.format("假装这里在播视频。。。\n%s\n(MAC模拟器下暂无播放视频接口)", fileName)):add2(video):anchor(0.5, 0.5)
		else
			video = ccexp.VideoPlayer:create():add2(scene)

			video:addEventListener(videoEventListener)
			video:size(display.width, display.height):center()
			video:setFullScreenEnabled(true)

			if params.keepAspectRatio then
				video:setKeepAspectRatioEnabled(true)
			end

			video:setFileName(fileName)
			video:play()
		end

		return 
	end, 0)

	return 
end
video.test = function (self)
	return 
end

return video
