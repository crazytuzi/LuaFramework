--资源管理器
_G.classlist['CResStation'] = 'CResStation'
_G.CResStation = {}
_G.CResStation.objName = 'CResStation'
------------------------
local ImageManager 	= {}--图片管理
_G.classlist['ImageManager'] = 'ImageManager'
ImageManager.objName = 'ImageManager'
function ImageManager:new()
	local mgr = setmetatable({},{__index = ImageManager});
	mgr.obj = {}
	--mgr.obj = setmetatable({},{__mode="v"});
	return mgr;
end
--获取
function ImageManager:GetImage(szImageName)
    --Debug("#################GetImage: " , szImageName)
	if not szImageName then return end;
	local img = self.obj[szImageName]
	if not img then
		self.obj[szImageName] = _Image.new(szImageName)
		img = self.obj[szImageName]
	end
	return img
end
--清除
function ImageManager:Clear()
	self.obj = {}
	--self.obj = setmetatable({},{__mode="v"})
end

-------------------------------------------------
CResStation.ImageManager 	= ImageManager:new()
-----------------------------------资源管理器方法
--获取图片
function CResStation:GetImage(szImageName)
	return self.ImageManager:GetImage(szImageName)
end

--清空
function CResStation:Clear()
	self.ImageManager:Clear()
end
---------------------------------------------------































