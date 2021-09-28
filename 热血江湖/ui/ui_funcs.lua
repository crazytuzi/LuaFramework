function ui_set_hero_model(ui, hero,equipInfo, isshowFashion, armor, size, defaultAct, flyingWearID)
	if type(hero)=="number" then
		local modelID = i3k_engine_check_is_use_stock_model(hero)
		if modelID then
			local mcfg = i3k_db_models[modelID];
			if mcfg then
				ui:setSprite(mcfg.path);
				ui:setSprSize(size or mcfg.uiscale);
				if defaultAct and defaultAct ~= "0.0" then
					ui:pushActionList(defaultAct, 1)
					ui:pushActionList("stand", -1)
					ui:playActionList(alist, 1)
				else
					ui:playAction("stand");
				end
				ui:setColor( tonumber(mcfg.color, 16) or 0xFFFFFFF);
			end
		end
	else
		if hero then
			local fashion = hero._fashion
			if fashion then
				local modelID = i3k_engine_check_is_use_stock_model(fashion.modelID)
				if modelID then
					local mcfg = i3k_db_models[modelID];
					if mcfg then
						ui:setSprite(mcfg.path);
						ui:setSprSize(size or mcfg.uiscale);
						ui.isSprite3d = true
						if i3k_hero_set_skin(ui, hero, equipInfo, armor, isshowFashion, ui.setSkin, ui.linkChild, nil, flyingWearID, ui.unlinkChild) then
							if defaultAct then
								ui:playAction(defaultAct)
							else
								local data 
								if type(armor) == 'table' then
									if i3k_db_under_wear_cfg[armor.id] then
										data =  i3k_db_under_wear_cfg[armor.id].playStandbyAction
									end
									if data then
										ui:playAction(data[1])
									else
										ui:playAction(getMappingAct(hero));
									end
								else
									ui:playAction(getMappingAct(hero));
								end
							end
							ui:setColor( tonumber(mcfg.color, 16) or 0xFFFFFFF);
						end
					end
				end
			end
		end
	end
end

--家园装备映射动作
function getMappingAct(hero, act)
	local dbCfg = i3k_db_home_land_base.fishActCfg
	local dbCommon = i3k_db_common.engine
	local actName = act or dbCommon.defaultStandAction
	local actionMap = {
		[dbCommon.defaultStandAction]		= dbCfg.itemStandAct,
	}
	if (hero and hero.GetIsBeingHomeLandEquip) and hero:GetIsBeingHomeLandEquip() and actionMap[actName] then --家园装备特殊动作
		local dbCfg = i3k_db_home_land_base.fishActCfg
		actName = dbCfg.itemStandAct
	end
	return actName
end