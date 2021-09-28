require "Core.Module.Common.UIComponent"
require "Core.Module.Common.StarItem"

RealmCompactButton = class("RealmCompactButton", UIComponent);

function RealmCompactButton:New(transform, info, info2)
	self = { };
	setmetatable(self, { __index = RealmCompactButton });
	if (transform) then
		self:Init(transform);
		self.info = info;
		self.info2 = info2;
        self.layer = 0
	end
	return self
end

function RealmCompactButton:SetSelected(value)
	if (self._isSelected ~= value) then
		self._isSelected = value;		
		if (value) then
			if (self._owner and self._handler) then
				self._handler(self._owner, self);
			end
		end
		self:_RefreshSelectedUI();
	end
end

function RealmCompactButton:IsSelected()
	return self._isSelected;
end

function RealmCompactButton:SetEnabled(value)
	if (self._isEnabled ~= value) then
		self._isEnabled = value
		self:_RefreshEnabledUI();
	end
end
function RealmCompactButton:SetEnabled2(value)
	if (self._isEnabled2 ~= value) then
		self._isEnabled2 = value
		self:_RefreshEnabledUI();
	end
end

function RealmCompactButton:IsEnabled()
	return self._isEnabled;
end
function RealmCompactButton:IsEnabled2()
	return self._isEnabled2;
end

function RealmCompactButton:_Init()
	self._isSelected = false;
	self._isEnabled = false;
	self._isEnabled2 = false;
	self:_InitReference();
	self:_InitListener();
end

function RealmCompactButton:AddClickListener(owner, handler)
	self._owner = owner;
	self._handler = handler;
end


function RealmCompactButton:_InitReference()
	self._imgLevel = UIUtil.GetChildByName(self._transform, "UISprite", "imgLevel");
	self._imgIcon = UIUtil.GetChildByName(self._transform, "UISprite", "imgIcon");
	self._animator = UIUtil.GetChildByName(self._transform, "Animator", "imgIcon");
	self:_RefreshEnabledUI();
	self:_RefreshSelectedUI();
end

function RealmCompactButton:_RefreshSelectedUI()
	if (self._animator) then
		if (self._isSelected) then
            self._animator:CrossFade("selected",0.2);
		else			
            self._animator:CrossFade("stand",0.2);
		end
	end
end

function RealmCompactButton:_RefreshEnabledUI()
	if (self._imgLevel) then
		if (self._isEnabled or self._isEnabled2) then
			self._imgLevel.color = Color.New(1, 1, 1, 1);
		else
			self._imgLevel.color = Color.New(0, 0, 0, 0.6);
		end
	end
end

function RealmCompactButton:_InitListener()
	self._onClickHandler = function(go) self:_OnClickHandler(self) end
	UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHandler);
end

function RealmCompactButton:_OnClickHandler()
	if (not self._isSelected) then
		self:SetSelected(true);
	end
end
  
function RealmCompactButton:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function RealmCompactButton:_DisposeListener()
	UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickHandler = nil
	self._owner = nil;
	self._handler = nil;
end

function RealmCompactButton:_DisposeReference()
    self._imgLevel = nil;
	self._imgIcon = nil;
	self._animator = nil;
end