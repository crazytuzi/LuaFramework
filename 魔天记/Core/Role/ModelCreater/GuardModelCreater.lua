
require "Core.Role.ModelCreater.MonsterModelCreater"
GuardModelCreater = class("GuardModelCreater", MonsterModelCreater);

function GuardModelCreater:New(data, parent, asyncLoad, onLoadedSource)
	self = {};
	setmetatable(self, {__index = GuardModelCreater});
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
function GuardModelCreater:_Init(data)
	local config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MONSTER) [data.kind]
	self.kind = data.kind
	self.onEnableOpen = true
	self.model_id = config.model_id
	self._isDispose = false
end

function GuardModelCreater:_OnModelLoaded()
	self.super._OnModelLoaded(self)
	local equipConfig = ConfigManager.GetMonsterWeapon(self.kind)
	if(equipConfig) then
		local handpoint = self:GetHangingPoint(equipConfig.hang_point[1])
		
		Resourcer.GetAsync("Equip/Weapon", equipConfig.model_id, handpoint, System.Action_UnityEngine_GameObject(function(go)
			if self._isDispose or IsNil(self._parent) then
				if go then Resourcer.Recycle(go) end
				return
			end
			
			self._goEquipModel = go
		end))
		if(equipConfig.hang_point[2] ~= nil) then
			handpoint = self:GetHangingPoint(equipConfig.hang_point[2])
			Resourcer.GetAsync("Equip/Weapon", equipConfig.model_id, handpoint, System.Action_UnityEngine_GameObject(function(go)
				if self._isDispose or IsNil(self._parent) then
					if go then Resourcer.Recycle(go) end
					return
				end
				
				self._goEquipModel = go
			end))
		end
	end
	
end


function GuardModelCreater:_DisposeModel()	
	if(self._goEquipModel1) then
		Resourcer.Recycle(self._goEquipModel, false)
		self._goEquipModel1 = nil
	end
	
	if(self._goEquipModel2) then
		Resourcer.Recycle(self._goEquipModel2, false)
		self._goEquipModel2 = nil
	end
	
	if not IsNil(self._role) then
		Resourcer.Recycle(self._role, self:_CanPoolMode())
		self._role = nil
	end
end

