local QVideoPlayer = class("QVideoPlayer", function()
    return display.newNode()
end)

function QVideoPlayer:ctor()
    self._completedCallback = nil

    self:setAnchorPoint(ccp(0.5, 0.5))
    if device.platform ~= "windows" then
        local backLayer = CCLayerColor:create(ccc4(0, 0, 0, 255), display.width * 2, display.height * 2)
        backLayer:setPosition(-display.width,-display.height)
        self:addChild(backLayer, 10)
    end

    self._videoPlayer = VideoPlayer:create()
    self:addChild(self._videoPlayer)

    local function onVideoEventCallback(sener, eventType)
        if eventType == VideoPlayerEventType.PLAYING then
        elseif eventType == VideoPlayerEventType.PAUSED then
        elseif eventType == VideoPlayerEventType.STOPPED then
        elseif eventType == VideoPlayerEventType.COMPLETED then
            if self._completedCallback then
                self:_completedCallback()
            end
       end
    end

    self._videoPlayer:addEventListener(onVideoEventCallback)
end

function QVideoPlayer:setCompletedCallback(callback)
    self._completedCallback = callback
end

function QVideoPlayer:removeEventListener()
    self._videoPlayer:addEventListener(nil)
end

-- 播放
function QVideoPlayer:play()
    if VIDEOPLAYER_ENABLE then
        self._videoPlayer:play()
    else
        self:onPlayEvent(VideoPlayerEventType.COMPLETED)
    end
end

-- 设置全屏播放
function QVideoPlayer:setFullScreenEnabled(enable)
    self._videoPlayer:setFullScreenEnabled(enable)
end

function QVideoPlayer:isFullScreenEnabled()
    return self._videoPlayer:isFullScreenEnabled()
end

-- 设置保持缩放比
function QVideoPlayer:setKeepAspectRatioEnabled(enable)
    self._videoPlayer:setKeepAspectRatioEnabled(enable)
end

function QVideoPlayer:isKeepAspectRatioEnabled()
    return self._videoPlayer:isKeepAspectRatioEnabled()
end

-- 设置播放的本地视频路径
function QVideoPlayer:setFileName(fileName)
    self._videoPlayer:setFileName(fileName)
end

function QVideoPlayer:getFileName()
    return self._videoPlayer:getFileName()
end

-- 设置播放的网络视频路径(未经测试，可能不完善)
function QVideoPlayer:setURL(url)
    self._videoPlayer:setURL(url)
end

function QVideoPlayer:getURL()
    self._videoPlayer:getURL()
end

-- android平台移除视频之前需要调用stop接口
function QVideoPlayer:stop()
    self._videoPlayer:stop()
end

-- 快进函数，设置播放进度
function QVideoPlayer:seekTo(sec)
    self._videoPlayer:seekTo(sec)
end

function QVideoPlayer:isPlaying()
    self._videoPlayer:isPlaying()
end

function QVideoPlayer:onPlayEvent(eventType)
    self._videoPlayer:onPlayEvent(eventType)
end

return QVideoPlayer