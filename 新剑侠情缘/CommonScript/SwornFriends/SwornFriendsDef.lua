SwornFriends.Def = {
	--
	-- 以下由策划配置
	--
	nMinPlayer = 2,	--最少结拜人数
	nMaxPlayer = 4,	--最多结拜人数
	nMinLevel = 50,	--最低角色等级
	nMinImitity = 20,	--最低亲密度

	nTitleHeadMin = 1,	--主称号首部字数下限
	nTitleHeadMax = 4,	--主称号首部字数上限
	nTitleTailMin = 1,	--主称号尾部字数下限
	nTitleTailMax = 2,	--主称号尾部字数上限
	nPersonalTitleMin = 1,	--个人称号字数下限
	nPersonalTitleMax = 4,	--个人称号字数上限

	nConnectItemId = 3368,	--结拜消耗的物品ID
	nPersonalTitleItemId = 3370,	--编辑个人结拜称号的物品id

	nTitleId = 6501,	--称号id

	nConnectDistance = 500,	--结拜时,队友在npc周围最大半径

	nCityNpcId = 629,	--城市中的npc id(用于自动寻路)
	nCityMapId = 10,	--城市的map id

    nSwornMapId = 10,	--结拜场景的map id

    szText1 = "黄天在上，后土在下。我",
    szText2 = "今日义结金兰，此后有福同享，有难同当，同心协力，不离不弃，守望相助，肝胆相照。天地作证，山河为盟，一生坚守，誓不相违！",
    nSwornTextInterval = 0.2,	--誓言文字播放速度，多少秒播放一个字（秒）
    nActionWaitTime = 3, --切换地图后，跪拜剧情等待开始时间（秒）
    nConnectActId = 4,	--跪拜动作id
    nConnectSkillDelay = 5,	--誓言文字结束后，继续跪拜时长（秒）
    tbSkillCastPoint = {17597, 18563},	--跪拜时面朝坐标点（用来固定朝向）
    tbConnectPos = {	--跪拜坐标点
    	{17015,18689},
    	{17015,18416},
		{17114,18970},
    	{17114,18115},
    },

    nTeamBuffId = 1085,	--组队buff id
    nTeamBuffLevel = 1,	--组队buff等级
    nTeamBuffDuration = 3*24*3600, --组队buff持续最长时间(秒)

    --
    -- 以下由程序配置
    --
	nMaxSavePerScriptData = 500,	--一个ScriptData存储条数上限,测试极限情况可以保存1300左右
}

-- 海外特殊需求覆盖
if version_vn or version_kor then
	SwornFriends.Def.nTitleHeadMin = 4	--主称号首部字数下限
	SwornFriends.Def.nTitleHeadMax = 12	--主称号首部字数上限
	SwornFriends.Def.nTitleTailMin = 4	--主称号尾部字数下限
	SwornFriends.Def.nTitleTailMax = 8	--主称号尾部字数上限
	SwornFriends.Def.nPersonalTitleMin = 4	--个人称号字数下限
	SwornFriends.Def.nPersonalTitleMax = 8	--个人称号字数上限
elseif version_th then
	SwornFriends.Def.nTitleHeadMin = 6	--主称号首部字数下限
	SwornFriends.Def.nTitleHeadMax = 10	--主称号首部字数上限
	SwornFriends.Def.nTitleTailMin = 3	--主称号尾部字数下限
	SwornFriends.Def.nTitleTailMax = 6	--主称号尾部字数上限
	SwornFriends.Def.nPersonalTitleMin = 6	--个人称号字数下限
	SwornFriends.Def.nPersonalTitleMax = 10	--个人称号字数上限
end