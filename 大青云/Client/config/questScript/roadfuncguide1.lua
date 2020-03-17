--[[
主宰之路功能引导
lizhuangzhuang
2015年6月7日19:10:15
]]

local id = 0;

QuestScriptCfg:Add(
{
	name = "roadfuncguide1",
	stopQuestGuide = true,--停下来
	disableFuncKey = true,
	log = true,
	
	steps = {
		--打开UI
		[1] = {
			type = "normal",
			execute = function() 
				--如果上一次引导没通过，继续引导上一次
				if DominateRouteModel:GetDominateRouteIsPass(10001) then
					id = 10002;
				else
					id = 10001;
				end
				FuncManager:OpenFunc(FuncConsts.DominateRoute,false,id);
				return true; 
			end,
			complete = function() return UIDominateRoute:IsFullShow(); end,
			Break = function() return false; end
		},
		
		--取消组队状态
		[2] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() TeamController:QuitTeam(); return true; end,
			Break = function() return false; end,
		},
		
		--指引章节
		[3] = {
			type = "clickButton",
			button = function() return UIDominateRoute:GetChallengeBtn(id); end,
			Break = function() return not UIDominateRoute:IsShow() ; end,
			arrow = true,
			arrowPos = 4,
			arrowOffset = {x=0,y=0},
			text = "点击箭头提示位置",
			autoTime = 10000,
			autoTimeFunc = function() 
				DominateRouteController:SendDominateRouteChallenge(id);
				UIDominateRoute:OnGuideClick();				
			end,
			mask=true
		},
		
		--等待追踪面板打开
		[4] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() return UIDominateRouteInfo:IsFullShow(); end,
			Break = function() return false; end,
		},
		
	}
});