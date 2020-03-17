--[[
	珍宝阁引导
	2015年5月6日, AM 11:40:31
	wangyanwei
]]


QuestScriptCfg:Add(
{
	name = "jewellerychangeguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function() FuncManager:OpenFunc(FuncConsts.ZhanBaoGe); return true; end,
			complete = function() return UIJewellPanel:IsFullShow(); end,
			Break = function() return false; end
		},
		
		
		[2] = {
			type = "clickButton",
			button = function() return UIJewellPanel:GetPillBtn(); end,
			Break = function() return (not UIJewellPanel:IsShow())  end,
		}
	}
}
)