--[[
	开发者：houxudong
	时间:   2016年10月20日 17:35:29
	功能:   牧野之战工具类
]]

_G.MakinoBattleDungeonUtil = {};

--今日剩余进入次数和总次数
function MakinoBattleDungeonUtil:GetNowCanEnterNum()
	local dungeondata = MakinoBattleDungeonModel:GetMakinoDungeonData( );
	if not dungeondata then return 0,0 end
	local cfg = t_consts[323];
	if not cfg then return end
	local num = cfg.val3 - dungeondata.enterNum ;
	if num < 0 then num = 0 end
	return num or 0,cfg.val3 or 0;
end