--[[
    Created by IntelliJ IDEA.
    集会所 新屠魔 新悬赏
    User: Hongbin Yang
    Date: 2016/10/28
    Time: 0:09
   ]]


_G.AgoraFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Agora,AgoraFunc);

AgoraFunc.timerKey = nil;


function AgoraFunc:OnBtnInit()
	self:RegisterTimes()
	self:InitRedPoint()
end

function AgoraFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

function AgoraFunc:InitRedPoint()
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		PublicUtil:SetRedPoint(self.button, RedPointConst.showNum, AgoraModel:GetDayLeftCount())
	end,1000,0);
end