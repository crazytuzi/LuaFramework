------------------------------------------------------
local require = require;

require "i3k_global";
require "i3k_math";

------------------------------------------------------
i3k_collision_mgr = i3k_class("i3k_collision_mgr")
function i3k_collision_mgr.SolveCollision(entity1, entity2)
	local minDist = entity1._radius + entity2._radius;

	local p1 = entity1._curPos;
	local p2 = entity2._curPos;
	local tmpDist = i3k_vec3_len(i3k_vec3_sub1(p1, p2));

	if tmpDist < minDist then
		local angle = i3k_vec3_angle_self(i3k_vec3_sub1(p1, p2));
		local distance = minDist - tmpDist + 1;
		local distance1 = 0.5 * distance;--(1 - entity1._mass / (entity1._mass + entity2._mass)) * distance;
		local distance2 = distance - distance1

		entity1:SetPos(i3k_vec3_2_int(i3k_rotate_by_angle(i3k_vec3_add1(i3k_vec3( distance1, 0, 0), p1), p1, angle)));
		entity2:SetPos(i3k_vec3_2_int(i3k_rotate_by_angle(i3k_vec3_add1(i3k_vec3(-distance2, 0, 0), p2), p2, angle)));
	end
end

function i3k_collision_mgr.Collision(entities, idx, entity)
	for k = idx + 1, #entities do
		if entities[k] and entities[k].entity then
			local test = entities[k].entity;
			if test:CanMove() and not test:IsDead() and test._guid ~= entity._guid then
				i3k_collision_mgr.SolveCollision(entity, test);
			end
		end
	end
end

-- only update monster`s collision
function i3k_collision_mgr.OnLogic(dTick)
	local logic = i3k_game_get_logic();
	local world = logic:GetWorld();
	if world then
		local player = logic:GetPlayer();
		if player then
			local entities = world:GetAliveEntities(player:GetHero(), eGroupType_E);
			for k = 1, #entities do
				local entity = entities[k].entity;

				if not entity:IsDead() and entity:CanMove() then
					i3k_collision_mgr.Collision(entities, k, entity);
				end
			end

		--[[
			entities = world:GetAliveEntities(player:GetHero(), eGroupType_O);
			for k = 1, #entities do
				local entity = entities[k];

				if not entity:IsDead() then
					i3k_collision_mgr.Collision(entities, k, entity);
				end
			end
			]]
		end
	end
end

