local jumpIds = {
{23, 1},
{23, 2},
{23, 3},
{23, 4},
{23, 5},
{23, 6},
{
23,
7,
OPENCHECK_TYPE.ShenMi_Shop
},
{23, 8},
{23, 9},
{23, 10},
{
23,
11,
OPENCHECK_TYPE.LimitHero
},
{23, 12},
{23, 13},
{
23,
14,
OPENCHECK_TYPE.TanBao
},
{
23,
15,
OPENCHECK_TYPE.WaBao
},
{
23,
16,
OPENCHECK_TYPE.SHOP
},
{23, 17}
}
function JumpTo(pageData)
	dump(pageData)
	local pageIndex = tonumber(pageData.id[1])
	local pageSubIndex = tonumber(pageData.id[2])
	local msg
	if pageIndex == GAME_STATE.STATE_JINGCAI_HUODONG then
		msg = pageSubIndex
	elseif pageIndex == GAME_STATE.STATE_DUOBAO then
		msg = {}
	else
		msg = {}
	end
	for k, v in pairs(jumpIds) do
		if v[1] == pageIndex and v[2] == pageSubIndex and v[3] then
			local bHasOpen, prompt = OpenCheck.getOpenLevelById(v[3], game.player:getLevel(), game.player:getVip())
			if not bHasOpen then
				show_tip_label(prompt)
				return
			end
		end
	end
	GameStateManager:ChangeState(pageIndex, msg)
end