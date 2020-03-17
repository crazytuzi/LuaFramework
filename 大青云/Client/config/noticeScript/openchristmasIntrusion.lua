--[[
	2015年12月22日22:08:10
	wangyanwei
	圣诞雪人入侵
]]
NoticeScriptCfg:Add(
{
	name = "openchristmasIntrusion",
	execute = function()
		local level = MainPlayerModel.humanDetailInfo.eaLevel;
		if level < 10 then
			FloatManager:AddNormal( StrConfig['christmas004'] );
			return
		end
		UIChristmasBasic:Open('christmasIntrusion')
		return true;
	end
}
);