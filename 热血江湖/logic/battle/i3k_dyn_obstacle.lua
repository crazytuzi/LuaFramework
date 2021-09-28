------------------------------------------------------
module(..., package.seeall)

local require = require


------------------------------------------------------
i3k_dyn_obstacle = i3k_class("i3k_dyn_obstacle");
function i3k_dyn_obstacle:ctor(guid)
	self._entity		= Engine.MEntity(guid);
	self._guid			= guid;
	self._obstacle		= nil;

	i3k_game_register_entity(guid, self);
end

function i3k_dyn_obstacle:Create(path, pos, dir, obstacleType, obstacleArgs)
	self:CreateResSync(path);

	local _O = require("logic/battle/i3k_obstacle");
	self._obstacle = _O.i3k_obstacle.new(i3k_gen_entity_guid_new(_O.i3k_obstacle.__cname, i3k_gen_entity_guid()));
	if not self._obstacle:Create(pos, dir, obstacleType, obstacleArgs) then
		self._obstacle = nil;
	end

	return true;
end

function i3k_dyn_obstacle:SetPos(pos)
	if self._entity then
		self._entity:SetPosition(pos);
	end
end

function i3k_dyn_obstacle:Show(vis, recursion)
	if self._entity then
		if vis then
			self._entity:FadeIn(300, recursion);
		else
			self._entity:FadeIn(300, recursion);
		end
	end
end

function i3k_dyn_obstacle:CreateResSync(path)
	if self._entity then
		if self._entity:CreateHosterModel(path, string.format("dyn_obstacle_%s", self._guid)) then
			self._entity:SetActionBlendTime(0);

			self._entity:EnterWorld(false);
		end
	end
end

function i3k_dyn_obstacle:Play(action, loop)
	if self._entity then
		self._entity:SelectAction(action, loop);
		self._entity:Play();
	end
end

function i3k_dyn_obstacle:Release()
	if self._obstacle then
		self._obstacle:Release()
		self._obstacle = nil;
	end

	if self._entity then
		self._entity:Release();
		self._entity = nil;
	end

	i3k_game_register_entity(self._guid, nil);
end
