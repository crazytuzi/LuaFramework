MapChoseSpriteRenderEffect = {};
MapChoseSpriteRenderEffect.__index = MapChoseSpriteRenderEffect;

local _instance;
function MapChoseSpriteRenderEffect:new()
	local self = {};
	setmetatable(self, MapChoseSpriteRenderEffect);
	return self;
end


function MapChoseSpriteRenderEffect.performPostRenderFunctions(id)
	if MapChoseDlg.GetSingleton() ~= nil then
		MapChoseDlg.GetSingleton():DrawSprite(id);
	end
end
return MapChoseSpriteRenderEffect