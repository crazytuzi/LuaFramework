--[[
家园引导
lizhuangzhuang
2015年9月21日15:12:22
]]

QuestScriptCfg:Add(
{
	name = "homequestguide",
	stopQuestGuide = true,--停下来
	disableFuncKey = true,--屏蔽快捷键
	log = true,
	
	steps = {
		--指向主界面，引导打开宗门
		[1] = {
			type = "clickButton",
			button = function() return UIMainSkill:GetHomeBtn(); end,
			Break = function() return false; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=0},
			text = "点击打开宗门",
			autoTime = 10000,
			autoTimeFunc = function() UIMainSkill:OnBtnHomeClick(); end,
			mask=true
		},
		
		--等待家园打开
		[2] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() return UIHomesteadMainView:IsFullShow() end,
			Break = function() return false; end,
		},
		
		--引导点击激活宗门任务殿
		--5秒后自动执行，激活后，默认打开宗门任务列表界面。
		[3] = {
			type = "clickButton",
			button = function() return UIHomesteadMainView:GetQuestBuilding(); end,
			Break = function() return false; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=0},
			text = "点击激活任务殿，任务殿可完成宗门任务获得大量奖励",
			autoTime = 10000,
			autoTimeFunc = function() HomesteadController:BuildUplvl(HomesteadConsts.ZongmengBuild,true) end,
			mask=true
		},
		
		--打开任务殿界面
		[4] = {
			type = "normal",
			execute = function() UIHomesMainQuest:Show({"list"}); return true; end,
			complete = function() return UIHomesQuestList:IsFullShow(); end,
			Break = function() return false; end,
		},
	
		--点击第一任务,查看详情
		[5] = {
			type = "clickButton",
			button = function() return UIHomesQuestList:GetFirstQuestBtn(); end,
			Break = function() return false; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=0},
			text = "点击派遣弟子完成任务",
			autoTime = 10000,
			autoTimeFunc = function() UIHomesQuestList:OpenFirstQuest();  end,
			mask=true
		},
		
		--等待打开任务详情
		[6] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() return UIHomesAQuestVo:IsShow(); end,
			Break = function() return false; end,
		},

		--指引玩家点击放入执行任务的弟子
		[7] = {
			type = "clickButton",
			button = function() return UIHomesAQuestVo:GetFirstPupil(); end,
			Break = function() return false; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=0},
			text = "点击选择该弟子进行任务",
			autoTime = 10000,
			autoTimeFunc = function() UIHomesAQuestVo:ClickFirstPupil();  end,
			mask=true
		},
		
		--指引玩家点击开始任务
		[8] = {
			type = "clickButton",
			button = function() return UIHomesAQuestVo:GetGetQuestBtn(); end,
			Break = function() return false; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=0},
			text = "点击开始任务",
			autoTime = 10000,
			autoTimeFunc = function() UIHomesAQuestVo:OnGetQuset();  end,
			mask=true
		}
	}
});