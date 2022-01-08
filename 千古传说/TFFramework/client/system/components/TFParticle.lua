--[[--
	粒子控件:

	--By: xiaoda.zhuang
	--2014/1/6
]]

local _pcreate = TFParticle.create
function TFParticle:create(szFileName)
	local obj = _pcreate(TFParticle, szFileName)
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj
	if val.particleViewModel and val.particleViewModel.szParticlePath ~= "" then
		obj = TFParticle:create(val.particleViewModel.szParticlePath)
	else
		obj = TFParticle:create()
	end
	if parent and obj then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	if obj then
		obj:initMEParticle(val, parent)
	end
	return true, obj
end
rawset(TFParticle, "initControl", initControl)

return TFParticle