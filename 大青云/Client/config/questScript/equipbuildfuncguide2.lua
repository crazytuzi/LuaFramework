--[[
装备打造功能引导
lizhuangzhuang
2015年6月6日14:10:24
]]
--第3次引导打造腰带
local t = 0;
local id = 1;

QuestScriptCfg:Add(
{
	name = "equipbuildfuncguide2",
	stopQuestGuide = true,--停下来
	disableFuncKey = true,
	log = true,
	
	steps = {
		--打开UI
		[1] = {
			type = "normal",
			execute = function() 
				if not FuncManager:GetFuncIsOpen(FuncConsts.EquipBuild) then
					return false;
				end
				FuncManager:OpenFunc(FuncConsts.EquipBuild); 
				return true; 
			end,
			complete = function() return UIEquipBuild:IsFullShow(); end,
			Break = function() return false; end
		},
		--选中指定打造
		--关闭UI
		[2] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() UIEquipBuild:ShowSelecteIndex(3); return true; end,
			Break = function() return false; end,
		},
		
		--指向打造
		[3] = {
			type = "clickButton",
			button = function() return UIEquipBuild:GetBuildBtn(); end,
			Break = function() return (not UIEquipBuild:IsShow()) or (not UIEquipBuildMain:IsShow()) ; end,
			arrow = true,
			arrowPos = 2,
			arrowOffset = {x=0,y=0},
			text = "点击打造极品卓越装备",
			autoTime = 20000,
			autoTimeFunc = function() UIEquipBuild:OnDazaoaClick(); end,
			mask=true
		},
		
		--等一会
		[4] = {
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
		[5] = {
			type = "normal",
			execute = function() 
				t = 0; 
				UIEquipBuildMain:Hide();
				UIEquipBuildResult:Hide();
				UIEquipBuildResultTwo:Hide();
				return true; 
			end,
			complete = function() return not UIEquipBuildMain:IsShow(); end,
			Break = function() return false; end,
		},
	
	}
});	