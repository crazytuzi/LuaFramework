require "Core.Module.Common.UIComponent"

ArathiPointState = class("ArathiPointState", UIComponent)

function ArathiPointState:New()
	self = {};
	setmetatable(self, {__index = ArathiPointState});
	self.id = 0;
	self._camp = - 1;
	return self;
end

function ArathiPointState:_Init()
	-- self._button = UIUtil.GetComponent(self._transform, "UIButton");
	self._imgState = UIUtil.GetComponent(self._transform, "UISprite");
	self._imgCamp = UIUtil.GetChildByName(self._transform, "UISprite", "imgCamp");
	self._imgFight = UIUtil.GetChildByName(self._transform, "UISprite", "imgFight");
	self._txtName = UIUtil.GetChildByName(self._transform, "UILabel", "txtName");
	self._imgFight.gameObject:SetActive(true);
	
	local tColor = Color.New(0, 0, 0)	
	self._imgState.color = tColor
	-- self._button.defaultColor = tColor
	-- self._button.hover = tColor
	-- self._button.pressed = tColor
	
	self._onClick = function(go) self:_OnClick() end
	UIUtil.GetComponent(self._imgState, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
end

function ArathiPointState:Reset()
	local tColor = Color.New(0, 0, 0)
	self._imgState.color = tColor
	-- self._button.defaultColor = tColor
	-- self._button.hover = tColor
	-- self._button.pressed = tColor
	self._imgCamp.gameObject:SetActive(false);
	self._imgFight.gameObject:SetActive(false);
end

function ArathiPointState:SetName(name)
	if(name ~= nil) then
		self._txtName.text = name;
	else
		self._txtName.text = "";
	end
end

function ArathiPointState:SetFightState(active)
	self._imgFight.gameObject:SetActive(active)
end

function ArathiPointState:SetCamp(camp)
	if(self._camp ~= camp) then
		self._camp = camp
		if(camp and camp ~= 0) then
			local tColor = Color.New(1, 1, 1)
			self._imgState.color = tColor
			-- self._button.defaultColor = tColor
			-- self._button.hover = tColor
			-- self._button.pressed = tColor
			self._imgCamp.spriteName = "arathiIcon" .. camp;
			self._imgState.spriteName = "arathiResBar" .. camp;
			self._imgCamp.gameObject:SetActive(true);
		else
			local tColor = Color.New(0, 0, 0)
			self._imgState.color = tColor
			-- self._button.defaultColor = tColor
			-- self._button.hover = tColor
			-- self._button.pressed = tColor
			self._imgCamp.gameObject:SetActive(false);
		end
	end
end

function ArathiPointState:_OnClick()	
	if(self.position) then
		PlayerManager.hero:MoveTo(self.position);
	end
end

function ArathiPointState:_Dispose()	
	UIUtil.GetComponent(self._imgState, "LuaUIEventListener"):RemoveDelegate("OnClick");	
	self._onClick = nil;
	-- self._button = nil;
	self._imgState = nil;
	self._imgCamp = nil;
	self._imgFight = nil;
	self._txtName = nil;
end 