require "Core.Module.Pattern.Proxy"

OtherInfoProxy = Proxy:New();
OtherInfoProxy.cache = nil;

function OtherInfoProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetOtherInfo, OtherInfoProxy._RspOtherDetailInfo);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetOtherPetInfo, OtherInfoProxy._RspOtherPet);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetOtherTeamPetInfo, OtherInfoProxy._RspOtherTeamPet);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetOtherSkillInfo, OtherInfoProxy._RspOtherSkill);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetOtherFightInfo, OtherInfoProxy._RspOtherFight);
end

function OtherInfoProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetOtherInfo, OtherInfoProxy._RspOtherDetailInfo);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetOtherPetInfo, OtherInfoProxy._RspOtherPet);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetOtherTeamPetInfo, OtherInfoProxy._RspOtherTeamPet);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetOtherSkillInfo, OtherInfoProxy._RspOtherSkill);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetOtherFightInfo, OtherInfoProxy._RspOtherFight);
end

--信息
function OtherInfoProxy.ReqOtherInfo(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.GetOtherInfo, {id = id});
end

function OtherInfoProxy._RspOtherDetailInfo(cmd, data)
	if(data == nil or data.errCode ~= nil) then
        return;
    end
    OtherInfoProxy.cache = data;
	MessageManager.Dispatch(OtherInfoNotes, OtherInfoNotes.RSP_DETAIL_INFO, data);
end

--技能
function OtherInfoProxy.ReqOtherSkill(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.GetOtherSkillInfo, {id = id});
end

function OtherInfoProxy._RspOtherSkill(cmd, data)
	if(data == nil or data.errCode ~= nil) then
        return;
    end
	MessageManager.Dispatch(OtherInfoNotes, OtherInfoNotes.RSP_SKILL_INFO, data);
end

--宠物
function OtherInfoProxy.ReqOtherPet(id, pid)
	SocketClientLua.Get_ins():SendMessage(CmdType.GetOtherPetInfo, {id = id, pet_id = pid});
end

function OtherInfoProxy._RspOtherPet(cmd, data)
	if(data == nil or data.errCode ~= nil) then
        return;
    end
	MessageManager.Dispatch(OtherInfoNotes, OtherInfoNotes.RSP_PET_INFO, data);
end

--上阵宠物
function OtherInfoProxy.ReqOtherTeamPet(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.GetOtherTeamPetInfo, {id = id});
end

function OtherInfoProxy._RspOtherTeamPet(cmd, data)
	if(data == nil or data.errCode ~= nil) then
        return;
    end
	MessageManager.Dispatch(OtherInfoNotes, OtherInfoNotes.RSP_PET_TEAM_INFO, data);
end

--战斗力
function OtherInfoProxy.ReqOtherFight(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.GetOtherFightInfo, {id = id});
end

function OtherInfoProxy._RspOtherFight(cmd, data)
	if(data == nil or data.errCode ~= nil) then
        return;
    end
    OtherInfoProxy.otherFightData = data;
	MessageManager.Dispatch(OtherInfoNotes, OtherInfoNotes.RSP_FIGHT_INFO, data);
end