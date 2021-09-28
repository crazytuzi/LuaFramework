require "Core.Module.Common.Panel"

UIRequestPanel = class("UIRequestPanel",Panel);
function UIRequestPanel:New()
	self = { };
	setmetatable(self, { __index =UIRequestPanel });
	return self
end

function UIRequestPanel:GetUIOpenSoundName( )
    return ""
end

function UIRequestPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    --log("UIRequestPanel:_Init:" .. tostring(self._luaBehaviour.canPool));
    self._luaBehaviour.canPool = true;
    --log("UIRequestPanel:_Init222:" .. tostring(self._luaBehaviour.canPool));
end

function UIRequestPanel:_InitReference()
end

function UIRequestPanel:_InitListener()
end

function UIRequestPanel:_Dispose()
	self:_DisposeReference();
end

function UIRequestPanel:_DisposeReference()
end


function UIRequestPanel:IsFixDepth()
    return true;
end

function UIRequestPanel:IsPopup()
	return false;
end
