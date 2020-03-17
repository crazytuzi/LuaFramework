--[[
升级
wangshuai
]]

QuestScriptCfg:Add(
{
	name = "refinguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.EquipRefin); return true; end,
			complete = function() return UIEquip:IsFullShow(); end,
			Break = function() return false; end
		},
		-- [2] = {
		-- 	type = "normal",
		-- 	execute = function()  return true; end,
		-- 	complete = function() UIRefinView:ShowTexiao(true); return true end,
		-- 	Break = function() return not UIEquip:IsShow(); end,
		-- },
	}
})