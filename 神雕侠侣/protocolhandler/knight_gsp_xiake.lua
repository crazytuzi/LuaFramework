knight_gsp_xiake = {}

function knight_gsp_xiake.SRefreshXiakeExp_Lua_Process(p)
	return true;
end

function knight_gsp_xiake.SReqXiakeSWTask_Lua_Process(p)
	return true;
end

function knight_gsp_xiake.SSendXiakePracticeResult_Lua_Process(p)
	return true;
end

function knight_gsp_xiake.SUpgradeSkillPreview_Lua_Process(p)
	return true;
end

function knight_gsp_xiake.SChangeSkill_Lua_Process(p)
	return true;
end

function knight_gsp_xiake.SDelXiakeChips_Lua_Process(p)

	return true;
end

function knight_gsp_xiake.SExchangeXiake_Lua_Process(p)

	return true;
end

function knight_gsp_xiake.SOpenXiakeJiuguan_Lua_Process(p)
	print("---------------SOpenXiakeJiuguan------------");
--	local pp = KnightClient.toCOpenXiakeJiuguan(p);
--	for k,v in pairs(pp) do
--		print(tostring(k).."---"..tostring(v).."---"..tostring(type(v)));
--	end
--	for k,v in pairs(
	return true;
end

function knight_gsp_xiake.SReqXiayiValue_Lua_Process(p)

	return true;
end

function knight_gsp_xiake.SSkillInfo_Lua_Process(p)

	return true;
end

function knight_gsp_xiake.SXiakeChips_Lua_Process(p)

	return true;
end

return knight_gsp_xiake;
