------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =
	require("logic/entity/i3k_entity_net").i3k_entity_net;


------------------------------------------------------
i3k_pet_race = i3k_class("i3k_pet_race", BASE);
function i3k_pet_race:ctor(guid)
	self._cfg = {}
	self._cfg.speed 	= 10
	self._entityType	= eET_PetRace;
	self._birthPos		= Engine.SVector3(0, 0, 0);
	self._timetick		= 0;
	self._groupType		= eGroupType_N -- 中立
	self._properties 	= self:InitProperties();

end


function i3k_pet_race:CreatePetRaceRes(id, modelID)
	self._id = id
	self:EnableOccluder(true);
	self:CreateRes(modelID)
end

function i3k_pet_race:InitProperties()
	local properties =
	{
		[ePropID_speed] = i3k_entity_property.new(self, ePropID_speed, 0)
	}
	properties[ePropID_speed]:Set(0, ePropType_Base, true);
	return properties;
end

function i3k_pet_race:OnPropUpdated(id, value)
	-- if id == ePropID_speed then
	-- 	return true
	-- end
	BASE.OnPropUpdated(self, id, value)
end

function i3k_pet_race:OnIdleState()
	self:Play("stand", -1)
end

function i3k_pet_race:SetRotation(rotation)
	local r_x = rotation.x;
	local r_y = rotation.y;
	local r_z = rotation.z;
	local r = i3k_vec3_angle2(i3k_vec3(r_x,r_y,r_z), i3k_vec3(1, 0, 0));
	local Dir = {x = 0 ,y = r ,z = 0 }
	self:SetFaceDir(Dir.x, Dir.y, Dir.z);
end

function i3k_pet_race:CreateTitle()
	local _T = require("logic/entity/i3k_entity_title");
	local title = { };
	title.node = _T.i3k_entity_title.new();
	local nameID = i3k_db_common.petRacePets[self._id] and i3k_db_common.petRacePets[self._id].name
	local name = i3k_get_string(nameID)
	if title.node:Create("car_title_node_" .. self._guid) then
		title.name	= title.node:AddTextLable(-0.5, 0.15, 0.5, 0.5, tonumber("0xffffffff", 16), name or "");
	else
		title.node = nil;
	end
	return title
end

function i3k_pet_race:PlayPetRunAction()
	self:Play("run", -1)
end

-- function i3k_pet_race:PlayPetStandAction()
-- 	self:Play("stand", -1)
-- end

function i3k_pet_race:OnSelected(val)
	BASE.OnSelected(self, val);
	if val then
		-- g_i3k_logic:openBattlePetRace() -- 暂时弃用
	end
end

function i3k_pet_race:popMessage(text)
	local uiids = { eUIID_MonsterPop, eUIID_MonsterPop2, eUIID_MonsterPop3}
	for k, v in ipairs(uiids) do
		if not g_i3k_ui_mgr:GetUI(v) then
			g_i3k_ui_mgr:OpenUI(v)
			g_i3k_ui_mgr:RefreshUI(v, text, self)
			return
		end
	end
end


function i3k_pet_race:GetAliveTick()
	return self._aliveTick;
end

function i3k_pet_race:OnLogic(dTick)
	BASE.OnLogic(self, dTick);

	return true;
end

function i3k_pet_race:CanRelease()
	return true;
end
