--FightTeamMember.lua

FightTeamMember = class()

local prop = Property(FightTeamMember)


prop:accessor("fightID", 0)
prop:accessor("roleSID")
prop:accessor("name", "")
prop:accessor("level",1)
prop:accessor("school",1)
prop:accessor("ability", 0)	--战斗力
prop:accessor("position", FIGHTTEAM_POSITION.Mem)	--职务

function FightTeamMember:__init(roleSID, fightID)
	prop(self, "fightID", fightID)
	prop(self, "roleSID", roleSID)
end

--写数据转字符串
function FightTeamMember:updateMem(fightID)
	local luaBuf2 = self:writeString()
	g_entityDao:updateFightTeamMember(self:getRoleSID(),fightID, luaBuf2, #luaBuf2)
end

--写数据转字符串
function FightTeamMember:writeString()
	local data = {}
	data.position = self:getPosition()
	return protobuf.encode("FightMemProtocol", data)
end

--读数据解析字符串
function FightTeamMember:readString(buff)
	if #buff > 0 then
		local datas = protobuf.decode("FightMemProtocol", buff)
		self:setPosition(datas.position)
	end
end