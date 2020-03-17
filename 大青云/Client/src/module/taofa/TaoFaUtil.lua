--[[
    Created by IntelliJ IDEA.
    讨伐相关操作
    User: Hongbin Yang
    Date: 2016/10/6
    Time: 16:36
   ]]

_G.TaoFaUtil = {};

function TaoFaUtil:GetDayMaxCount()
	local cfg = t_consts[315];
	if not cfg then return 0; end
	return cfg.val1;
end

function TaoFaUtil:IsTodayFinish()
	return (TaoFaUtil:GetDayMaxCount() - TaoFaModel.curFinishedTimes) <= 0;
end