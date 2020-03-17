--[[
翅膀开启引导
lizhuangzhuang
2015年7月10日11:35:37
]]

local t = 0;
local flyOver = false;

QuestScriptCfg:Add(
{
	name = "wingfuncguide",
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
			execute = function() t=0; UIWingOpen:Show(); return true; end,
			complete = function() return UIWingOpen:IsFullShow(); end,
			Break = function() return false; end
		},
		
		--等待开启UI关闭
		[3] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() return not UIWingOpen:IsShow(); end,
			Break = function() return false; end
		},
		
		--开角色面板
		[4] = {
			type = "normal",
			execute = function() flyOver=false; UIRole:Show(); return true; end,
			complete = function() return UIRole:IsFullShow(); end,
			Break = function() return false; end
		},
		
		--飞图标 起点屏幕中央
		[5] = {
			type = "normal",
			execute = function()
						local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
						if bagVO then
							local winglist = bagVO:BagItemListBySub(BagConsts.SubT_Wing);
							if #winglist > 0 then
								local bagItem = winglist[1];
								local flyVO = {};
								flyVO.url = BagUtil:GetItemIcon(bagItem:GetTid());
								local func = FuncManager:GetFunc(FuncConsts.Bag);
								flyVO.startPos = func:GetBtnGlobalPos();
								flyVO.endPos = UIRoleBasic:GetWingSlotPos()
								flyVO.time = 1;
								flyVO.onComplete = function()
									flyOver = true;
								end
								FlyManager:FlyIcon(flyVO);
							end
						end
						return true; 
					end,
			complete = function() return flyOver; end,
			Break = function() return false; end
		},
		
		--装备翅膀
		[6] = {
			type = "normal",
			execute = function() return true; end,
			complete = function() 
							local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
							if bagVO then
								local winglist = bagVO:BagItemListBySub(BagConsts.SubT_Wing);
								if #winglist > 0 then
									local bagItem = winglist[1];
									BagController:EquipWing(BagConsts.BagType_Bag,bagItem:GetPos());
								end
							end
							return true;
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
			complete = function() UIRoleBasic:PlayWingSlotEff(); return true; end,
			Break = function() return false; end
		},
	}
});