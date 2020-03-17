--[[
跨服战场，util
wangshuai
]]

_G.InterSerSceneUtil = {};


function InterSerSceneUtil:ShowMyTeamList()
	local list = InterSerSceneModel:GetMyTeamInfo()
	local uidata = {};
	for i,info in ipairs(list) do 
		local vo = {};
		vo.txt_1 = info.roleName;
		vo.txt_2 = info.lvl;
		vo.txt_3 = info.fight;
		local bo = InterSerSceneModel:GetIsTeamLeader()
		vo.btnState = not bo
		local myroleid = MainPlayerController:GetRoleID();
		if myroleid == info.roleID then 
			vo.btnState = true;
		end;
		vo.btnTxt = StrConfig["interServiceDungeon406"]
		vo.desc = info.roleID
		table.push(uidata,UIData.encode(vo))
	end;
	return uidata
end;

function InterSerSceneUtil:ShowNearbyTeam()
	local list = InterSerSceneModel:GetNearbyTeamInfo();
	local uidata = {};
	for i,info in ipairs(list) do 
		local vo = {};
		vo.txt_1 = info.leaderName;
		vo.txt_2 = info.maxRoleFight;
		vo.txt_3 = info.roleNum .. "/" .. 4;
		vo.desc = info.teamId;
		vo.btnState = false;
		vo.btnTxt = StrConfig["interServiceDungeon407"]
		table.push(uidata,UIData.encode(vo))
	end;
	return uidata
end;

function InterSerSceneUtil:ShowNearbyRole()
	local list = InterSerSceneModel.nearbyRole;
	local uidata = {};
	for i,info in ipairs(list) do 
		local vo = {};
		vo.txt_1 = info.roleName;
		vo.txt_2 = info.level;
		vo.txt_3 = info.fight;
		vo.desc = info.roleID;
		vo.btnState = false;
		vo.btnTxt = StrConfig["interServiceDungeon408"]
		table.push(uidata,UIData.encode(vo))
	end;
	return uidata
end;
