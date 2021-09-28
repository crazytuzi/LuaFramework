UIComponent = class("UIComponent")

-- UIComponent = {
--    _gameObject = nil,
--    _transform = nil
-- };
function UIComponent:New(transform)
	self = {};
	setmetatable(self, {__index = UIComponent});
	if(transform) then		
		self:Init(transform);
	end
	return self;
end

function UIComponent:_Init()
	
end

function UIComponent:SetActive(active)
	if(self._gameObject and self._isActive ~= active) then
		self._gameObject:SetActive(active);
		self._isActive = active;
	end
end
function UIComponent:GetActive()
	return self._isActive
end

function UIComponent:SetEnable(enable)
	SetUIEnable(self._transform, enable)
end

function UIComponent:SetParent(parent)
	if(self._transform) then
		self._transform:SetParent(parent)
	end
end

function UIComponent:Init(transform)
	self._transform = transform;
	self._gameObject = transform.gameObject;
	self._btns = {}
	self._onBtnsClickFunc = function(go) self:_OnBtnsClick(go) end
	self._isActive = self._gameObject.activeSelf;
	self._dispose = false
	self:_Init();
end

function UIComponent:_Dispose()
	
end

function UIComponent:Dispose()
	self:_Dispose();
	self:_RemoveBtnListen()
	self._transform = nil;
	self._gameObject = nil;
	for k, v in pairs(self) do
		self[k] = nil
	end
	self._dispose = true
	self._isActive = false
end


function UIComponent:_AddBtnListen(btn)
	local listen = UIUtil.GetComponent(btn.gameObject, "LuaUIEventListener")
	listen:RegisterDelegate("OnClick", self._onBtnsClickFunc);
	self._btns[btn] = listen
end

function UIComponent:_RemoveBtnListen()
	if(self._btns and table.getCount(self._btns) > 0) then
		for k, v in pairs(self._btns) do
			if(v) then
				v:RemoveDelegate("OnClick");
			end
		end
	end
	self._onBtnsClickFunc = nil
end


function UIComponent:_OnBtnsClick(go)
	
end 