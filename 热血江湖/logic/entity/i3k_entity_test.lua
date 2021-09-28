------------------------------------------------------
--2018/08/01
------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = i3k_entity;
------------------------------------------------------
i3k_entity_test = i3k_class("i3k_entity_test", BASE);
function i3k_entity_test:ctor(guid)
	self._entityType	= eET_Test;
	self._guid			= guid
	self:CreateActor()
end

function i3k_entity_test:Create(id)
	self._testModelID = id
	if self._entity then
		self._entity:SyncScenePos(self:IsPlayer());
	end
	self:createModel(id)
end

function i3k_entity_test:OnLogic(dTick)
	BASE.OnLogic(self, dTick);
end

function i3k_entity_test:createModel(id)
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

function i3k_entity_test:OnSelected(val, ready)
	BASE.OnSelected(self, val)
	
	if val then 
		g_i3k_ui_mgr:PopupTipMessage("就是个测试模型~");
	end 
end

function i3k_entity_test:ValidInWorld()
	return true
end

function i3k_entity_test:IsAttackable(attacker)
	return false;
end
