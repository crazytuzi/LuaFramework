--[[
头顶血条
]]
_G.classlist['BaseHeadBoard'] = 'BaseHeadBoard'
_G.BaseHeadBoard = {};
BaseHeadBoard.objName = 'BaseHeadBoard'
function BaseHeadBoard:new()
	local obj = setmetatable({},{__index=self});
	
	return obj;
end

function BaseHeadBoard:Update()

end

function BaseHeadBoard:Destory()

end

