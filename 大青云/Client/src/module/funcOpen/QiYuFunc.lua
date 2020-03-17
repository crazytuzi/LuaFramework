--[[
奇遇功能
lizhuangzhuang
2015年8月7日18:32:38
]]

_G.QiYuFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.RandomQuest,QiYuFunc);

--是否正在显示引导
QiYuFunc.isShowGuide = false;
QiYuFunc.closeGuideTimer = nil;

function QiYuFunc:OnFuncOpen()
	-- TimerManager:RegisterTimer(function()
		-- self.isShowGuide = true;
		-- UIMainQuestAll:ShowQuestGuide(QuestConsts.Type_Random,UIFuncGuide.Type_QuestQiYu,StrConfig["funcguide003"]);
		-- self.closeGuideTimer = TimerManager:RegisterTimer(function()
			-- self.closeGuideTimer = nil;
			-- self:CloseGuide();
		-- end,30000,1);
	-- end,1000,1);
end

function QiYuFunc:CloseGuide()
	-- if self.isShowGuide then
		-- if self.closeGuideTimer then
			-- TimerManager:UnRegisterTimer(self.closeGuideTimer);
			-- self.closeGuideTimer = nil;
		-- end
		-- self.isShowGuide = false;
		-- UIMainQuestAll:CloseQuestGuide(UIFuncGuide.Type_QuestQiYu);
	-- end
end

function QiYuFunc:OnQuestClick()
	self:CloseGuide();
end

--飞到任务栏
function QiYuFunc:GetFlyPos()
	return {x=_rd.w-130,y=320};
end