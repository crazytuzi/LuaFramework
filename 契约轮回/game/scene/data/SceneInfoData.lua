--
-- @Author: LaoY
-- @Date:   2018-11-24 10:36:23
--

SceneInfoData = SceneInfoData or class("SceneInfoData",BaseMessage)
local SceneInfoData = SceneInfoData
function SceneInfoData:ctor()
end

function SceneInfoData:dctor()
end

function SceneInfoData:ChangeMessage(message)
    SceneInfoData.super.ChangeMessage(self, message)

    if self.lines then
        self:BrocastData("lines")
    end
end

function SceneInfoData:GetLines()
	return self.lines
end