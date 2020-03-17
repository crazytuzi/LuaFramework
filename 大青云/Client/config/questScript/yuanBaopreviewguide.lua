--[[
超级元宝礼包开启引导--首日目标
]]

local t = 0;
local flyOver = false;

QuestScriptCfg:Add(
{
	name = "yuanBaofuncguide",
	--stopQuestGuide = true,--停下来
	log = true,
	
	steps = {
		--等1S,确定道具肯定进背包了
		[1] = {
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
			
		--显示开启UI
		[2] = {
			type = "normal",
			execute = function() t=0; UIYuanbaoOpen:Show(); return true; end,
			complete = function() return UIYuanbaoOpen:IsFullShow(); end,
			Break = function() return false; end
		},
		
		--等待开启UI关闭
		[3] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() return not UIYuanbaoOpen:IsShow(); end,
			Break = function() return false; end
		},
		
		--开角色面板
		[4] = {
			type = "normal",
			execute = function() flyOver=false; return true; end,
			complete = function() return end,
			Break = function() return false; end
		},
		
		--飞图标 起点屏幕中央
		[5] = {
			type = "normal",
			execute = function()
						return true; 
					end,
			complete = function() return flyOver; end,
			Break = function() return false; end
		},
		
		--装备武器
		[6] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() 
						end,
			Break = function() return false; end
		},
		
		--等200ms
		[7] = {
			type = "normal",
			execute = function() t = GetCurTime();  return true; end,
			complete = function() 
				if t == 0 then
					t = GetCurTime();
				end
				return GetCurTime()-t > 200; 
			end,
			Break = function() return false; end,
		},
		
		--显示装备翅膀特效
		[8] = {
			type = "normal",
			execute = function() t=0; return true; end,
			complete = function() return true; end,
			Break = function() return false; end
		},
	}
});