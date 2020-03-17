--[[
Monster常量
haohu
2014年8月13日18:11:38
]]
_G.classlist['MonsterConsts'] = 'MonsterConsts'
_G.MonsterConsts = {};
_G.MonsterConsts.objName = 'MonsterConsts'

--怪物类型(详细)
MonsterConsts.Type_Normal = 1; --普通怪
MonsterConsts.Type_Elite = 2; --精英怪
MonsterConsts.Type_Boss_Normal = 3; --普通boss
MonsterConsts.Type_Boss_World = 4; --世界boss
MonsterConsts.Type_Quest = 5; --任务怪
MonsterConsts.Type_Boss_Quest = 6; --任务boss
MonsterConsts.Type_Boss_Instance = 7; --副本boss
MonsterConsts.Type_Dungeon_Thing = 8;--副本部件
MonsterConsts.Type_False = 9;--假怪
MonsterConsts.Type_Boss_Field = 10;--野外boss
MonsterConsts.Type_Boss_Person = 11;--个人boss
MonsterConsts.Type_Boss_Digong = 12;--地宫boss
MonsterConsts.Type_Delay = 13;--增加时长怪
MonsterConsts.Type_Create_Count = 14;--增加刷怪数
MonsterConsts.Type_Boss_Digong_Small = 15;--地宫小boss
MonsterConsts.Type_Field_Treasure = 16;--野外掉宝怪
MonsterConsts.Type_Boss_XianYuanCave = 17;--打宝地宫BOSS
MonsterConsts.Type_Boss_XianYuanCave_Small = 18;--打宝地宫小怪
MonsterConsts.Type_Boss_XianYuanCave_JingYing = 19;--打宝地宫精英怪
--怪物头衔
MonsterConsts.Normal = 1;
MonsterConsts.Elite  = 2;
MonsterConsts.Boss   = 3;


--获取怪物作为选中目标时的"选中目标类型"  TargetConsts.TargetType
function MonsterConsts:GetTargetMonsterType( monster )
	if not monster.GetMonsterId then return; end

	local monsterId = monster:GetMonsterId();
	if self:IsBoss( monsterId ) then
		return TargetConsts.TargetType.Boss;
	else
		return TargetConsts.TargetType.Monster;
	end
end
--根据monster表中的id一列，判断是不是boss
function MonsterConsts:IsBoss( monsterID )
	local type = t_monster[monsterID].type;
	if type == self.Type_Boss_Normal or type == self.Type_Boss_World or
			type == self.Type_Boss_Instance or type == MonsterConsts.Type_Boss_Field or type == MonsterConsts.Type_Boss_Quest or
			type == self.Type_Boss_Person or type == MonsterConsts.Type_Boss_Digong or
			type == self.Type_Boss_Digong_Small or type == MonsterConsts.Type_Boss_XianYuanCave then
		return true;
	else
		return false;
	end
	return false;
end

MonsterBelongType = {
	Belong_None = 0,
	Belong_Player = 1, 			--相同ID自己不可攻击
	Belong_Player_Atk = 2, 		--相同ID只有自己可攻击
	Belong_Guild = 3,			--相同ID所属帮派不可攻击
	Belong_Guild_Atk = 4,		--相同ID只有所属帮派可攻击
	Belong_Player_See = 5, 		--归属可见
	Belong_Server = 6,			--相同ID同服务器不可攻击
	Belong_Server_Atk = 7,		--相同ID只有所属服务器可攻击
}