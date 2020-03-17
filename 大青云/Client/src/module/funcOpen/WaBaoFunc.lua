--[[
挖宝功能
lizhuangzhuang
2015年8月7日16:44:21
]]

_G.WaBaoFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.WaBao,WaBaoFunc);

--是否正在显示引导
WaBaoFunc.isShowGuide = false;
WaBaoFunc.closeGuideTimer = nil;

function WaBaoFunc:OnFuncOpen()
	-- TimerManager:RegisterTimer(function()
		-- self.isShowGuide = true;
		-- UIMainQuestAll:ShowQuestGuide(QuestConsts.Type_WaBao,UIFuncGuide.Type_QuestWaBao,StrConfig["funcguide001"]);
		-- self.closeGuideTimer = TimerManager:RegisterTimer(function()
			-- self.closeGuideTimer = nil;
			-- self:CloseGuide();
		-- end,30000,1);
	-- end,1000,1);
end

function WaBaoFunc:CloseGuide()
	-- if self.isShowGuide then
		-- if self.closeGuideTimer then
			-- TimerManager:UnRegisterTimer(self.closeGuideTimer);
			-- self.closeGuideTimer = nil;
		-- end
		-- self.isShowGuide = false;
		-- UIMainQuestAll:CloseQuestGuide(UIFuncGuide.Type_QuestWaBao);
	-- end
end

--点击任务追踪,挖宝
function WaBaoFunc:OnQuestClick()
	self:CloseGuide();
	WaBaoController:ShowUI();
end

--飞到任务栏
function WaBaoFunc:GetFlyPos()
	return {x=_rd.w-130,y=320};
end