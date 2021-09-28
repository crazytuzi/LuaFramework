require "Core.Role.ModelCreater.BaseModelCreater"
NpcModelCreater = class("NpcModelCreater", BaseModelCreater);

local playerName = {"tqm", "tyg", "tgz", "mxz"}

function NpcModelCreater:New(data, parent, asyncLoad, onLoadedSource)
	self = {};
	setmetatable(self, {__index = NpcModelCreater});
	if(asyncLoad ~= nil) then
		self.asyncLoadSource = asyncLoad
	else
		self.asyncLoadSource = true
	end
	self.onLoadedSource = onLoadedSource
	self.hasCollider = true
	self.showShadow = true
	self:Init(data, parent);
	return self;
end

--
function NpcModelCreater:_Init(data)
	-- local config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MONSTER)[data.kind]
	self.onEnableOpen = true
	self.model_id = data.model_id
end

function NpcModelCreater:_GetModern()
	return "Roles", self.model_id;
end

function NpcModelCreater:_GetSourceDir()
	return "Npc"
end

function NpcModelCreater:GetDefaultAction()
	return "stand"
end

function NpcModelCreater:_GetModelDefualt()
	return "n_mgz023";
end


function NpcModelCreater:_OnInitRender()
	local render = self._render
	if render then
		render.receiveShadows = false
		render.castShadows = true
		
		if not self._bv then
			self._bv = render:GetComponent("BecameVisible")
			if not self._bv then
				self._bv = render.gameObject:AddComponent("BecameVisible")
			end
			self._bv.OnVisible = function(val) self:_OnVisible(val) end
		end
	end
	if render and self.hasCollider then
		self:_InitCollider(render)
	end
end
function NpcModelCreater:_OnVisible(val)
	if self.controller then self.controller.visible = val end
end

function NpcModelCreater:_Dispose()
	if self._bv then
		self._bv.OnVisible = nil
		self._bv = nil
	end
end



