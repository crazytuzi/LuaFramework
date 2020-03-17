--[[
副本功能引导
lizhuangzhuang
2015年6月28日13:58:28
]]

QuestScriptCfg:Add(
{
	name = "dungeonguide",
	stopQuestGuide = true,--停下来
	disableFuncKey = false,--禁止快捷键
	log = true,
	
	steps = {
		--指向副本按钮
		[1] = {
			type = "clickButton",
			button = function() 
						local func = FuncManager:GetFunc(FuncConsts.Dungeon);
						return func.button;
					end,
			Break = function() return false; end,
			arrow = true,
			arrowPos = 4,
			arrowOffset = {x=0,y=0},
			text = "挑战副本可获得卓越属性装备及大量商城道具",
			mask=false
		},
		
		--打开副本UI
		[2] = {
			type = "normal",
			execute = function() 
				if not FuncManager:GetFuncIsOpen(FuncConsts.Dungeon) then
					return false;
				end
				FuncManager:OpenFunc(FuncConsts.Dungeon,false);
				return true; 
			end,
			complete = function() return UIDungeon:IsFullShow(); end,
			Break = function() return false; end
		},
		
		--箭头指向进入按钮
		[3] = {
			type = "clickButton",
			button = function() return UIDungeon:GetEnterButton(); end,
			Break = function() return not UIDungeon:IsShow(); end,
			arrow = true,
			arrowPos = 4,
			arrowOffset = {x=0,y=0},
			text = "点击进入副本",
			autoTime = 10000,
			autoTimeFunc = function() 
				UIDungeon:OnBtnEnterClick();				
			end,
			mask=false
		},
		
		--等待追踪面板打开
		[4] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() return UIDungeonStory:IsFullShow(); end,
			Break = function() return false; end,
		},
		
		--指引追踪栏内的链接追踪
		[5] = {
			type = "clickButton",
			button = function() return UIDungeonStory:GetGuildBtn(); end,
			Break = function() return not UIDungeonStory:IsShow() ; end,
			arrow = true,
			arrowPos = 4,
			arrowOffset = {x=0,y=0},
			text = "点击开始挑战",
			autoTime = 5000,
			autoTimeFunc = function() UIDungeonStory:OnBtnGuildClick(); end,
		},
	}
});