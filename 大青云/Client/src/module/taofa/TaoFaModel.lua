--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/10/6
    Time: 17:56
   ]]

_G.TaoFaModel = Module:new();

TaoFaModel.curTaskID = 0;
TaoFaModel.curFinishedTimes = 0;
TaoFaModel.BossId = 0;
TaoFaModel.BossNum = 0;
TaoFaModel.MonsterId = 0;
TaoFaModel.MonsterNum = 0;

function TaoFaModel:SetTaskID(id)
	self.curTaskID = id;
end

function TaoFaModel:SetDungeonInfo(msg)
	self.BossId = msg.boss_id;
	self.BossNum = msg.boss_num;
	self.MonsterId = msg.monster_id;
	self.MonsterNum = msg.monster_num;
end

function TaoFaModel:GetDungeonInfo()
	return self.BossId,self.BossNum,self.MonsterId,self.MonsterNum
end