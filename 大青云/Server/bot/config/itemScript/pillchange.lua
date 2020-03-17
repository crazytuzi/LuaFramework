--[[
	获得妖丹数量变化
	2015年5月5日, PM 03:32:31
	wangyanwei
]]

ItemNumCScriptCfg:Add(
{
	name = "pillchange",
	execute = function(bag,pos,tid)
		if RoleBoegeyPillUtil:OnCanFeedPill(tid) then
			RoleBoegeyPillUtil:OnSetPillPage(tid);
			UIItemGuide:Open(2);
		end
	end
}
);