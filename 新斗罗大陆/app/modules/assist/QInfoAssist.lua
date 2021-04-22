local QBaseAssist = import(".QBaseAssist")
local QInfoAssist = class("QInfoAssist", QBaseAssist)

function QInfoAssist:ctor(options)
    QInfoAssist.super.ctor(self, options)
end

function QInfoAssist:run(callback)
    QInfoAssist.super.run(self, callback)
    self:logger("----------print user info:")
    self:logger("versionURL: "..VERSION_URL)
    self:logger("garyId: "..app.gray:getGrayId())
    self:logger("loginId: "..app.gray:getLoginId())
    self:logger("version: "..GAME_VERSION)
    self:logger("----------print end")
    self:complete()
end

return QInfoAssist