------------------------------------------------------
module(..., package.seeall)

local require = require


------------------------------------------------------
i3k_equip = i3k_class("i3k_equip");
function i3k_equip:ctor()
	self._partID		= -1;
	self._skin			= { valid = false, path = "" };
	self._model			= {valid = false, models = {}}
	self._properties	= { };
end

function i3k_equip:Create(hoster, eid, gender)
	local ecfg = g_i3k_db.i3k_db_get_equip_item_cfg(eid)
	if not ecfg then
		return false;
	end
	local bwType = 0
	if hoster._bwType then
		bwType = hoster._bwType
	end
	self._partID = ecfg.partID;

	local ids = ecfg.skin_M_ID;
	if gender == eGENDER_FEMALE then
		ids = ecfg.skin_F_ID;
		if bwType == 1 then
			ids = ecfg.skin_ZF_ID;
		elseif bwType == 2 then
			ids = ecfg.skin_XF_ID;
		end
	else
		if bwType == 1 then
			ids = ecfg.skin_ZM_ID;
		elseif bwType == 2 then
			ids = ecfg.skin_XM_ID;
		end
	end

	self._skin = { valid = false, skins = { } };
	self._model = {valid = false, models = {}}
	if ids then
		if self._partID ~= eEquipFlying then
		for k, v in ipairs(ids) do
			local scfg = i3k_db_skins[v];
			if scfg then
				self._skin.valid = true;

				local skin = { };
					skin.name = string.format("hero_skin_%s_%d_%d_%d", hoster._guid, self._partID, v, k);
					skin.path = scfg.path;
					skin.effectID = scfg.effectID
				table.insert(self._skin.skins, skin);
				end
			end
		else
			for k, v in ipairs(ids) do
				local scfg = i3k_db_models[v];
				if scfg then
					self._model.valid = true
					local models = {}
					models.id = v
					models.path = scfg.path
					models.name = string.format("hero_fly_equip_%s", hoster._guid)
					table.insert(self._model.models, models)
		end
	end
		end
	end
	return true;
end

function i3k_equip:Release()
end

