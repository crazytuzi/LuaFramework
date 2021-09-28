------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =
	require("logic/entity/i3k_monster").i3k_monster_base;

------------------------------------------------------
i3k_marry_cruise = i3k_class("i3k_marry_cruise", BASE);
function i3k_marry_cruise:ctor(guid)
	self._entityType	= eET_MarryCruise;
	self._birthPos		= Engine.SVector3(0, 0, 0);
	self._timetick		= 0;
	self._speed = nil
end

function i3k_marry_cruise:Create(id, manID, womanID, manName, womanName, location)
	local nCfg = i3k_db_marry_car[id];
	local basecfg = i3k_db_npc[nCfg.marryCarID]
	local cfg = i3k_db_monsters[basecfg.monsterID];
	if not cfg then
		return false;
	end
	for i=1, 10 do
		local carID = nCfg["carModer" .. i]
		if carID ~= 0 then
			self:createOtherCarEntity(id, i, carID, location)
		end
	end
	local name = manName .. "|" .. womanName
	return self:CreateFromCfg(id, name, cfg, 1, { });
end

function i3k_marry_cruise:Release()
	BASE.Release(self);
	local logic = i3k_game_get_logic();
	local world = logic:GetWorld()
	for _,v in ipairs(self._carEntityTab) do
		world:ReleaseEntity(v, true);
	end
end

function i3k_marry_cruise:OnAsyncLoaded()
	BASE.OnAsyncLoaded(self);

end

function i3k_marry_cruise:CreateTitle()
	local _T = require("logic/entity/i3k_entity_title");

	local title = { };

	title.node = _T.i3k_entity_title.new();
	if title.node:Create("car_title_node_" .. self._guid) then
		local owerName = string.split(self._name, "|");
		title.name	= title.node:AddTextLable(-0.5, 1, 0, 0.5, tonumber("0xffffffff", 16), owerName[1]);
		title.name	= title.node:AddTextLable(-0.5, 0.15, 0.5, 0.5, tonumber("0xffffffff", 16), owerName[2]);
	else
		title.node = nil;
	end

	return title;
end

function i3k_marry_cruise:OnInitBaseProperty(props)
	local properties = i3k_entity.OnInitBaseProperty(self, props);
	properties[ePropID_speed]:Set(0, ePropType_Base);

	return properties;
end

function i3k_marry_cruise:OnPropUpdated(id, value)
	if id == ePropID_speed then
		return true;
	end

	BASE.OnPropUpdated(self, id, value);
end

function i3k_marry_cruise:Bind(hero)
	self._hoster = hero;
end

function i3k_marry_cruise:createOtherCarEntity(cfgID, index, id, location)
	local nCfg = i3k_db_marry_car[cfgID];
	local bcfg = i3k_db_npc[id]
	local cfg = i3k_db_monsters[bcfg.monsterID];
	local x = location.position.x;
	local y = location.position.y;
	local z = location.position.z;
	local r_x = location.rotation.x;
	local r_y = location.rotation.y;
	local r_z = location.rotation.z;
	local StartPos = {x = x + nCfg.carOffSet[index].x, y = y, z = z + nCfg.carOffSet[index].z}
	local Pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(StartPos))));
	local r = i3k_vec3_angle2(i3k_vec3(r_x,r_y,r_z), i3k_vec3(1, 0, 0));
	local Dir = {x = 0 ,y = r ,z = 0 }
	local world = i3k_game_get_world();
	local SCar = require("logic/entity/i3k_entity_net");
	local MarryCruise = SCar.i3k_entity_net.new(i3k_gen_entity_guid_new(i3k_gen_entity_cname(eET_NPC),id+index));
	if MarryCruise:Create(cfg.id, cfg.name, nil, nil, nil,1,{},cfg,eET_NPC, false) then
		MarryCruise:SetGroupType(eGroupType_O);
		MarryCruise:SetFaceDir(Dir.x, Dir.y, Dir.z);
		MarryCruise:SetPos(Pos);
		MarryCruise:Show(true, true);
		MarryCruise:SetHittable(false);
		self._carEntityTab[index] = MarryCruise
	end
end

function i3k_marry_cruise:OnLogic(dTick)
	BASE.OnLogic(self, dTick);

	self._timetick = self._timetick + dTick * i3k_engine_get_tick_step();
	
	return true;
end

function i3k_marry_cruise:SetPos(pos)
	if not BASE.SetPos(self, pos) then
		return false;
	end

	local nCfg = i3k_db_marry_car[self._id]
	for i,e in ipairs(self._carEntityTab) do
		local nPos = i3k_vec3_clone(pos)
		nPos.x = nPos.x + (nCfg.carOffSet[i].x * self._orientation.x - nCfg.carOffSet[i].z * self._orientation.z)
		nPos.z = nPos.z + (nCfg.carOffSet[i].x * self._orientation.z + nCfg.carOffSet[i].z * self._orientation.x)
		local nPos1 = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(nPos))))
		e:SetPos(i3k_vec3(nPos.x, nPos1.y, nPos.z))
	end

	return true;
end

function i3k_marry_cruise:StartTurnTo(dir)
	BASE.StartTurnTo(self, dir)
	for i,e in ipairs(self._carEntityTab) do
		e:StartTurnTo(dir)
	end
end

function i3k_marry_cruise:SetFaceDir(x, y, z)
	BASE.SetFaceDir(self, x, y, z)
	for i,e in ipairs(self._carEntityTab) do
		e:SetFaceDir(x, y, z)
	end
end

function i3k_marry_cruise:Play(actionName, loopTimes)
	BASE.Play(self, actionName, loopTimes)
	for i,e in ipairs(self._carEntityTab) do
		e:Play(actionName, loopTimes)
	end
end

