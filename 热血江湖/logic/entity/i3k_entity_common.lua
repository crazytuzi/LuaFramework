------------------------------------------------------
--2018/08/01
------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = i3k_entity;
------------------------------------------------------
i3k_entity_common = i3k_class("i3k_entity_common", BASE);
function i3k_entity_common:ctor(guid)
	self._entityType	= eET_Common;
	self._guid			= guid
	self:CreateActor()
end

function i3k_entity_common:Create(id)
	self._testModelID = id
	if self._entity then
		self._entity:SyncScenePos(self:IsPlayer());
	end
	self:createModel(id)
end

function i3k_entity_common:OnLogic(dTick)
	BASE.OnLogic(self, dTick);
end

function i3k_entity_common:createModel(id)
	local mcfg = i3k_db_models[id];
	if mcfg then
		self._resCreated = 0
		self._name		= mcfg.desc;
		self._dropEff	= mcfg.dropEff;
		if name then
			self._name = "测试模型动作"; -- 临时参数
		end

		if self._entity:CreateHosterModel(mcfg.path, string.format("entity_%s", self._guid)) then
			self._baseScale = mcfg.scale;
			self:SetScale(self._baseScale);

			self._title = self:CreateTitle();
			self._entity:EnterWorld(false);
			self:SetFaceDir(self._faceDir.x, self._faceDir.y + i3k_db_home_land_base.baseCfg.cameraAngle, self._faceDir.z)
		end
	end
end

function i3k_entity_common:OnSelected(val, ready)
	BASE.OnSelected(self, val)
end

function i3k_entity_common:ValidInWorld()
	return true
end

function i3k_entity_common:IsAttackable(attacker)
	return false;
end
