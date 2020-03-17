--[[
升品吞噬
wangshuai
]]

QuestScriptCfg:Add(
{
	name = "productguide",--升品引导
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.EquipProduct); return true; end,
			complete = function() return UIEquipProduct:IsFullShow(); end,
			Break = function() return false; end
		},
		-- [2] = {
		-- 	type = "normal",
		-- 	execute = function()  return true; end,
		-- 	complete = function() UIEquipProduct:OnSetGuideEquip(); return true end,
		-- 	Break = function() return not UIEquip:IsShow(); end,
		-- },
		
		
		-- [3] = {
			-- type = "clickButton",
			-- button = function() return UIEquipProduct:GetAutoProductBtn() end,
			-- Break = function() return (not UIEquipProduct:IsShow()) or (not UIEquip:IsShow()) ; end,
			-- arrow = true,
			-- arrowPos = 1,
			-- arrowOffset = {x=0,y=-5},
		-- }
	}
})