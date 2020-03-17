--[[
封妖常量
zhangshuhui
2014年12月04日14:20:20
]]

_G.FengYaoConsts = {};

--封妖任务状态
FengYaoConsts.ShowType_NoAccept = 0;--未接受
FengYaoConsts.ShowType_Accepted = 1;--1已接受
FengYaoConsts.ShowType_NoAward = 2;--2可领奖
FengYaoConsts.ShowType_Awarded = 3;--3已领奖

--封妖宝箱状态
FengYaoConsts.ShowType_NoGetBox = 0;--积分不到
FengYaoConsts.ShowType_NotGetBox = 1;--未领奖
FengYaoConsts.ShowType_GetBox = 2;--2已领奖

--封妖最多次数
FengYaoConsts.FengYaoMaxCount = t_consts[19].val2;
--封妖动作间隔时间 15秒
FengYaoConsts.ActionSpaceTime = 150;

--封妖动作延迟时间0.5秒
FengYaoConsts.BeforePlayTime = 5;
--封妖最大积分
function FengYaoConsts:GetMaxScore()
	return toint(t_fengyaojifen[6].needStore);
end