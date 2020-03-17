--[[
装备升品引导
lizhuangzhuang
2015年4月28日11:28:28
]]

local t = 0;

QuestScriptCfg:Add(
{
	name = "equipproguide",
	stopQuestGuide = true,
	disableFuncKey = true,
	
	steps = {
		--打开升品
		[1] = {
			type = "normal",
			execute = function() 
				if not FuncManager:GetFuncIsOpen(FuncConsts.EquipProduct) then
					return false;
				end
				FuncManager:OpenFunc(FuncConsts.EquipProduct); 
				return true; 
			end,
			complete = function() return UIEquipProduct:IsFullShow(); end,
			Break = function() return false; end
		},
		
		--自动填充装备
		[2] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() UIEquipProduct:SelecteProductEquip({220002502}); return true end,
			Break = function() return not UIEquip:IsShow(); end,
		},
		
		--箭头指向一键升阶按钮，点击按钮后1秒箭头消失，开着界面且不点的情况下，箭头一直指向，不消失
		[3] = {
			type = "clickButton",
			button = function() return UIEquipProduct:GetProductBtn(); end,
			Break = function() return (not UIEquipProduct:IsShow()) or (not UIEquip:IsShow()) ; end,
			arrow = true,
			arrowPos = 1,
			arrowOffset = {x=0,y=0},
			autoTime = 20000,
			text = "点击进行装备升品",
			autoTimeFunc = function() UIEquipProduct:OnAutoProductClick(); end,
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
				return GetCurTime()-t > 1000; 
			end,
			Break = function() return false; end,
		},
		
		--关闭UI
		[5] = {
			type = "normal",
			execute = function() t = 0; UIEquip:Hide(); return true; end,
			complete = function() return not UIEquip:IsShow(); end,
			Break = function() return false; end,
		},
		
		--等一会
		[6] = {
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
		[7] = {
			type = "normal",
			execute = function() t = 0; UIEquipProductResult:Hide(); return true; end,
			complete = function() return not UIEquipProductResult:IsShow(); end,
			Break = function() return false; end,
		},
		
		--剧情对话框：【20】
		--剧情对话框结束后再继续跑任务。
		[8] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() UIStoryDialog:PlayStoryDialog(20); return true; end,
			Break = function() return false; end,
		},
	}
});