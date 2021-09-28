------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =
	require("logic/entity/i3k_entity_net").i3k_entity_net;


------------------------------------------------------
i3k_home_pet = i3k_class("i3k_home_pet", BASE);
function i3k_home_pet:ctor(guid)
	self._cfg = {}
	self._cfg.speed 	= 800
	self._entityType	= eET_HomePet;
	self._birthPos		= Engine.SVector3(0, 0, 0);
	self._timetick		= 0;
	self._groupType		= eGroupType_N -- 中立
	self._properties 	= self:InitProperties();
	self._petInfo		= {}
end


function i3k_home_pet:CreateHomePetRes(petInfo)
	self._id = petInfo.id
	self._petInfo = petInfo
	self:EnableOccluder(false);
	local modelId = i3k_db_mercenaries[petInfo.id].modelID
	if petInfo.iArgs[2] == 1 then
		modelId = i3k_db_mercenariea_waken_property[petInfo.id].modelID
	end
	self:CreateRes(modelId)
end

function i3k_home_pet:InitProperties()
	local properties =
	{
		[ePropID_speed] = i3k_entity_property.new(self, ePropID_speed, 0)
	}
	properties[ePropID_speed]:Set(0, ePropType_Base, true);
	return properties;
end

function i3k_home_pet:OnPropUpdated(id, value)
	BASE.OnPropUpdated(self, id, value)
end

function i3k_home_pet:OnIdleState()
	self:Play(i3k_db_common.engine.defaultAttackIdleAction, -1)
end

function i3k_home_pet:SetRotation(rotation)
	local r_x = rotation.x;
	local r_y = rotation.y;
	local r_z = rotation.z;
	local r = i3k_vec3_angle2(i3k_vec3(r_x,r_y,r_z), i3k_vec3(1, 0, 0));
	local Dir = {x = 0 ,y = r ,z = 0 }
	self:SetFaceDir(Dir.x, Dir.y, Dir.z);
end

function i3k_home_pet:CreateTitle(reset)
	if reset then
		if self._title and self._title.node then
			self._title.node:Release();
			self._title.node = nil;
		end
		self._title = nil;
	end
	local title = { };
	local petCfg = g_i3k_game_context:getCurHomePetData()
	if petCfg and petCfg[self._petInfo.iArgs[3]] and petCfg[self._petInfo.iArgs[3]].mood then
		local _T = require("logic/entity/i3k_entity_title");
		
		title.node = _T.i3k_entity_title.new();
		if title.node:Create("car_title_node_" .. self._guid) then
			local color = tonumber("0xffffff00", 16)
			local petName = self._petInfo.vArgs[1] ~= "" and self._petInfo.vArgs[1] or i3k_db_mercenaries[self._id].name
			local petMoodCfg = g_i3k_db.i3k_db_get_home_pet_mood_icon(petCfg[self._petInfo.iArgs[3]].mood)
			title.node:AddTextLable(-0.5, 1, -0.5, 0.5, color, petName);
			local titleIconID = g_i3k_db.i3k_db_get_scene_icon_path(petMoodCfg.titlePath)
			title.node:AddImgLable(-0.6, 1.1, -1.0, 1.1, titleIconID)
		else
			title.node = nil;
		end
	end
	return title
end

function i3k_home_pet:UpdateHomePetTitle()
	if self._title and self._title.node then
		self._title = self:CreateTitle(true)
		if self._title and self._title.node then
			self._title.node:SetVisible(true);
			self._title.node:EnterWorld();
			local modelId = i3k_db_mercenaries[self._petInfo.id].modelID
			if self._petInfo.iArgs[2] == 1 then
				modelId = i3k_db_mercenariea_waken_property[self._petInfo.id].modelID
			end
			self._entity:AddTitleNode(self._title.node:GetTitle(), i3k_db_models[modelId].titleOffset)
		end
	end
end

function i3k_home_pet:PlayPetRunAction()
	self:Play("run", -1)
end

function i3k_home_pet:OnSelected(val)
	--BASE.OnSelected(self, val);
	if val then
		g_i3k_ui_mgr:OpenUI(eUIID_HomePetDialogue)
		g_i3k_ui_mgr:RefreshUI(eUIID_HomePetDialogue, self._petInfo)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_HomePetDialogue)
	end
end

function i3k_home_pet:GetAliveTick()
	return self._aliveTick;
end

function i3k_home_pet:OnLogic(dTick)
	BASE.OnLogic(self, dTick);

	return true;
end

function i3k_home_pet:CanRelease()
	return true;
end
