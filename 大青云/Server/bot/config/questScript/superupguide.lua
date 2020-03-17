--[[
卓越铭刻功能引导
lizhuangzhuang
2015年6月6日22:44:40
]]

local bag,pos = -1,-1;--引导提示的背包,格子
local t = 0;

QuestScriptCfg:Add(
{
	name = "superupguide",
	stopQuestGuide = true,--停下来
	disableFuncKey = true,
	log = true,
	
	steps = {
		--打开铭刻
		[1] = {
			type = "normal",
			execute = function() 
				FuncManager:OpenFunc(FuncConsts.EquipSuperUp); 
				return true; 
			end,
			complete = function() return UIEquipSuperUp:IsFullShow(); end,
			Break = function() return false; end
		},
		
		--点击身上空格子装备
		[2] = {
			type = "clickButton",
			button = function() 
				local uiItem = nil;
				uiItem,bag,pos = UIEquipSuperUp:GetSuperUpGuideItem(220000501);
				return uiItem; 
			end,
			Break = function() return (not UIEquipSuperUp:IsShow()) or (not UIEquipBuildMain:IsShow()) ; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=-5},
			text = "点击选择准备铭刻卓越属性的装备",
			autoTime = 10000,
			autoTimeFunc = function() 
				if not bag or bag==-1 then return; end
				if not pos or pos==-1 then return; end
				UIEquipSuperUp:SelectEquip(bag,pos);
			end,
			mask = true,
		},
		
		--提示选择库属性
		[3] = {
			type = "clickButton",
			button = function() 
				return UIEquipSuperUp:GetFirstLibItem(); 
			end,
			Break = function() return (not UIEquipSuperUp:IsShow()) or (not UIEquipBuildMain:IsShow()) ; end,
			arrow = true,
			arrowPos = 4,
			arrowOffset = {x=0,y=0},
			text = "点击选择卓越属性",
			autoTime = 10000,
			autoTimeFunc = function() 
				if not bag or bag==-1 then return; end
				if not pos or pos==-1 then return; end
				UIEquipSuperUp:SelectLibFirst();
			end,
			mask = true,
		},
		
		--提示铭刻
		[4] = {
			type = "clickButton",
			button = function() return UIEquipSuperUp:GetConfirmBtn(); end,
			Break = function() return (not UIEquipSuperUp:IsShow()) or (not UIEquipBuildMain:IsShow()) ; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=-5},
			text = "点击铭刻卓越属性",
			autoTime = 10000,
			autoTimeFunc = function() UIEquipSuperUp:OnBtnConfirmClick(); end,
			mask = true,
		},
		
		--等一会
		[5] = {
			type = "normal",
			execute = function() t = GetCurTime();  return true; end,
			complete = function() 
				if t == 0 then
					t = GetCurTime();
				end
				return GetCurTime()-t > 5000; 
			end,
			Break = function() return false; end,
		},
		
		--关闭UI
		[6] = {
			type = "normal",
			execute = function() t = 0; UIEquipBuildMain:Hide(); return true; end,
			complete = function() return not UIEquipBuildMain:IsShow(); end,
			Break = function() return false; end,
		},
	}
});