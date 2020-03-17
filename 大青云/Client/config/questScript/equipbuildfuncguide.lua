--[[
装备打造功能引导
lizhuangzhuang
2015年6月6日14:10:24
]]
--第1次引导打造衣服
local t = 0;

QuestScriptCfg:Add(
{
	name = "equipbuildfuncguide",
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
			complete = function() UIEquipBuild:ShowSelecteIndex(1); return true; end,
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
	
		--关闭UI后，弹出剧情对话【21】
		[6] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() UIStoryDialog:PlayStoryDialog(20); return true; end,
			Break = function() return false; end,
		},
	}
});	