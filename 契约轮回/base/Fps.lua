--
-- @Author: LaoY
-- @Date:   2019-06-03 20:40:02
--


Fps = {}

Fps.frameCount = 0
Fps.deltaTime = 0
Fps.fps = 0
function Fps:Update(deltaTime)
	Fps.frameCount = Fps.frameCount + 1
	Fps.deltaTime = Fps.deltaTime + deltaTime
	if Fps.deltaTime > 1 then
		Fps:SetFps()
	end
end

function Fps:SetFps()
	Fps.fps = Fps.deltaTime/Fps.frameCount
	Fps.frameCount = 0
	Fps.deltaTime = 0
end

UpdateBeat:Add(Fps.Update,Fps)