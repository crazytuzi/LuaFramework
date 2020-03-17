--[[
卓越剥离功能引导
lizhuangzhuang
2015年6月6日22:36:57
]]

local bag,pos = -1,-1;--引导提示的背包,格子
local t = 0;

QuestScriptCfg:Add(
{
	name = "superdownguide",
	stopQuestGuide = true,--停下来
	disableFuncKey = true,
	steps = {
		--打开剥离
		[1] = {
			type = "normal",
			execute = function() 
				FuncManager:OpenFunc(FuncConsts.EquipSuperDown); 
				return true; 
			end,
			complete = function() return UIEquipSuperDown:IsFullShow(); end,
			Break = function() return false; end
		},
		
		--提示选择背包里装备
		[2] = {
			type = "clickButton",
			button = function()
				local uiItem = nil;
				uiItem,bag,pos = UIEquipSuperDown:GetSuperDownGuideItem(220000500);
				return uiItem; 
			end,
			Break = function() return (not UIEquipSuperDown:IsShow()) or (not UIEquipBuildMain:IsShow()) ; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=-5},
			text = "点击选择想要剥离属性的装备",	
			autoTime = 10000,
			autoTimeFunc = function() 
				if not bag or bag==-1 then return; end
				if not pos or pos==-1 then return; end
				UIEquipSuperDown:SelectEquip(bag,pos);
			end,
			mask = true,
		},
		
		--提示剥离
		[3] = {
			type = "clickButton",
			button = function() return UIEquipSuperDown:GetConfirmBtn(); end,
			Break = function() return (not UIEquipSuperDown:IsShow()) or (not UIEquipBuildMain:IsShow()) ; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=-5},
			text = "点击剥离选中的卓越属性",
			autoTime = 10000,
			autoTimeFunc = function() UIEquipSuperDown:OnBtnConfirmClick(); end,
			mask = true,
		},
		
		--等一会
		[4] = {
			type = "normal",
			execute = function() t = GetCurTime();  return true; end,
			complete = function() 
				if t == 0 then
					t = GetCurTime();
				end
				return GetCurTime()-t > 1000; 
			end,
			Break = function() return false; end,
		},
		
		--关闭UI
		[5] = {
			type = "normal",
			execute = function() t = 0; UIEquipBuildMain:Hide(); return true; end,
			complete = function() return not UIEquipBuildMain:IsShow(); end,
			Break = function() return false; end,
		},
	}
});