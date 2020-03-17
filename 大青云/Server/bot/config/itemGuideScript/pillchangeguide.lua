--[[
	妖丹使用引导
	2015年5月5日, PM 05:10:14
	wangyanwei
]]
QuestScriptCfg:Add(
{
	name = "pillchangeguide",
	steps = {
		[1] = {
			type = "normal",
			execute = function()
			RoleBoegeyPillUtil:SetItemGuideInfo();
			RoleBoegeyPillUtil:UseAllSameItem(RoleBoegeyPillModel:Geteffectitem());
			FuncManager:OpenFunc(FuncConsts.Role,false,"bogeypill"); 
			return true; 
			end,
			complete = function() return UIBogeyPill:IsFullShow(); end,
			Break = function() return false; end
		},
	
		-- [3] = {
			-- type = "clickButton",
			-- button = function() return UIBogeyPill:GetPillBtn(); end,
			-- Break = function() return (not UIBogeyPill:IsShow()) or (not UIRole:IsShow()) ; end,
			-- arrow = true,
			-- arrowPos = 1,
			-- arrowOffset = {x=0,y=-5},
		-- }
	}
}
)