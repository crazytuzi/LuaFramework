--[[
宝石升级
wangshuai
]]

QuestScriptCfg:Add(
{
	name = "gemguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.EquipGem); return true; end,
			complete = function() return UIEquipGem:IsFullShow(); end,
			Break = function() return false; end
		},
		[2] = {
			type = "normal",
			execute = function()  return true; end,
			complete = function() UIEquipGem:SetCurMiniLvlGem(); return true end,
			Break = function() return not UIEquip:IsShow(); end,
		},
		
		
		-- [4] = {
			-- type = "clickButton",
			-- button = function() return UIEquipGem:GetLvlUpBtn(); end,
			-- Break = function() return (not UIEquipGem:IsShow()) or (not UIEquip:IsShow()) ; end,
			-- arrow = true,
			-- arrowPos = 1,
			-- arrowOffset = {x=0,y=-5},
		-- }
	}
})