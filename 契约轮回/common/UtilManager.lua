-- 
-- @Author: LaoY
-- @Date:   2018-08-16 18:53:05
-- 
UtilManager = UtilManager or {}

UtilManager.DataPath = Util.DataPath

function UtilManager:GetScreenshotNotSave(width,height)
	return Util.GetScreenshotNotSave(width,height)
end


function UtilManager.GetCameraCaptureNotSave(camera_name,width,height)
	return Util.GetCameraCaptureNotSave(camera_name,width,height)
end

function UtilManager:ScreenshotSave(width,height,filename,callback)
	if callback then
		Util.GetCameraCaptureNotSave(width,height,filename,callback)
	else
		Util.GetCameraCaptureNotSave(width,height,filename)
	end
end

--[[
	@author LaoY
	@des	添加高斯模糊材质 如果已经存在就复用
--]]
function UtilManager.CameraBlur(transform)
	Util.CameraBlur(transform,ScreenWidth,ScreenHeight)
end

--[[
	@author LaoY
	@des	释放高斯模糊的材质
	关闭所有UI层级界面的时候调用一次
--]]
function UtilManager.ReleaseCameraMaterial()
	Util.ReleaseCameraMaterial()
end

function UtilManager:GetRelativePath()
	return Util.GetRelativePath()
end