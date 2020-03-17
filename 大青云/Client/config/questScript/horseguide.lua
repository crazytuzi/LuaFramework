--[[
坐骑功能引导
lizhuangzhuang
2015年4月28日11:28:28
]]

local t = 0;

QuestScriptCfg:Add(
{
	name = "horseguide",
	stopQuestGuide = true,--停下来
	disableFuncKey = true,--屏蔽快捷键
	log = true,
	
	steps = {
		--打开坐骑UI
		[1] = {
			type = "normal",
			execute = function() 
				if not FuncManager:GetFuncIsOpen(FuncConsts.Horse) then
					return false;
				end
				FuncManager:OpenFunc(FuncConsts.Horse); 
				return true; 
			end,
			complete = function() return UIMountBasic:IsFullShow(); end,
			Break = function() return false; end
		},
		
		--关闭所有会阻挡的UI
		[2] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() 
						EquipNewTipsManager:CloseAll();
						UIItemGuide:CloseAll();
						UIItemGuideUse:CloseAll();
						return true;
					end,
			Break = function() return false; end,
		},
		
		--箭头指向坐骑升阶界面内的升阶按钮，点击升阶按钮后1秒箭头消失，开着界面且不点的情况下，箭头一直指向，不消失
		--5秒后自动执行点击
		[3] = {
			type = "clickButton",
			button = function() return UIMountBasic:GetJinJieBtn(); end,
			Break = function() return not UIMount:IsShow(); end,
			arrow = true,
			arrowPos = 2,
			arrowOffset = {x=0,y=-5},
			text = "点击进阶坐骑",
			autoTime = 20000,
			autoTimeFunc = function() UIMountBasic:OnBtnJinJieClick(); end,
			mask=true
		},
		[4] = {
			type = "clickButton",
			button = function() return UIMountBasic:GetJinJieBtn(); end,
			Break = function() return not UIMount:IsShow(); end,
			arrow = true,
			arrowPos = 2,
			arrowOffset = {x=0,y=-5},
			text = "再次点击还能更强",
			autoTime = 5000,
			autoTimeFunc = function() UIMountBasic:OnBtnJinJieClick(); end,
			mask=true
		},
		[5] = {
			type = "clickButton",
			button = function() return UIMountBasic:GetJinJieBtn(); end,
			Break = function() return not UIMount:IsShow(); end,
			arrow = true,
			arrowPos = 2,
			arrowOffset = {x=0,y=-5},
			text = "再点一下",
			autoTime = 5000,
			autoTimeFunc = function() UIMountBasic:OnBtnJinJieClick(); end,
			mask=true
		},
		--等一会
		[6] = {
			type = "normal",
			execute = function() t = GetCurTime();  return true; end,
			complete = function() 
				if t == 0 then
					t = GetCurTime();
				end
				return GetCurTime()-t > 2000; 
			end,
			Break = function() return false; end,
		},
		--关闭UI
		[7] = {
			type = "normal",
			execute = function() UIMount:Hide(); return true; end,
			complete = function() return not UIMount:IsShow(); end,
			Break = function() return false; end,
		},
	}
});