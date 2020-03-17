--[[
	2015年1月16日, PM 03:47:59
	设置Consts
	wangyanwei 
]]
_G.SetSystemConsts = {};

SetSystemConsts.MUSICOPEN = 1;		--音乐效果
SetSystemConsts.MUSICBGOPEN = 2;	--背景音乐效果
SetSystemConsts.TEAMISOPEN = 4;		--禁止组队
SetSystemConsts.DEALISOPEN = 8;		--禁止交易
SetSystemConsts.FRIENDISOPEN = 16;	--禁止好友
SetSystemConsts.UNIONISOPEN = 32;	--禁止工会
SetSystemConsts.UNSHOWNUMZERO = 64; --全部隐藏
SetSystemConsts.UNSHOWNUMTEN = 128; --显示10
SetSystemConsts.UNSHOWNUMTWENTY = 256; --显示20
SetSystemConsts.UNSHOWNUMTHIRTY = 512; --显示30
SetSystemConsts.UNSHOWNUMALL = 1024; --全部显示
SetSystemConsts.UNSHOWNUMNAME = 2048; --只显示名字
SetSystemConsts.ISSHOWSKILL = 4096; --屏蔽他人技能特效
SetSystemConsts.ISOPENFLASH = 8192; --屏蔽低血量闪屏特效
SetSystemConsts.ISSHOWCOMMONMONSTER = 16384; --屏蔽普通怪物造型
SetSystemConsts.ISSHOWTITLE = 2097152; --屏蔽他人称号

SetSystemConsts.ROLEAUTOPOINTSET = 32768; --人物加点是否自动





SetSystemConsts.HIGHDEFINITION = 65536; --高光
SetSystemConsts.FLOWRIGHT = 131072; --泛光

--配置
SetSystemConsts.DRAWLOW = 262144; --低配
SetSystemConsts.DRAWMID = 524288; --推荐
SetSystemConsts.DRAWHIGH = 1048576; --高配

--双倍视角
SetSystemConsts.DOUBLEOVERLOOKS = 4194304;	--开关双倍视角

SetSystemConsts.ININTSHOWMODEL = 721920; --默认初始值↑↑↑↑↑

SetSystemConsts.TEAMINVITE = 8388608; --禁止接受他人的组队邀请
SetSystemConsts.TEAMAPPLAY = 16777216; --禁止接受他人的入队申请

SetSystemConsts.KeyConsts = {
	[_System.KeyA] = 'A',
	[_System.KeyB] = 'B',
	[_System.KeyC] = 'C',
	[_System.KeyD] = 'D',
	[_System.KeyE] = 'E',
	[_System.KeyF] = 'F',
	[_System.KeyG] = 'G',
	[_System.KeyH] = 'H',
	[_System.KeyI] = 'I',
	[_System.KeyJ] = 'J',
	[_System.KeyK] = 'K',
	[_System.KeyL] = 'L',
	[_System.KeyN] = 'N',
	[_System.KeyO] = 'O',
	[_System.KeyQ] = 'Q',
	[_System.KeyR] = 'R',
	[_System.KeyS] = 'S',
	[_System.KeyT] = 'T',
	[_System.KeyX] = 'X',
	[_System.KeyW] = 'W',
	[_System.KeyY] = 'Y',
	[_System.Key1] = '1',
	[_System.Key2] = '2',
	[_System.Key3] = '3',
	[_System.Key4] = '4',
	[_System.Key5] = '5',
	[_System.Key6] = '6',
	[_System.Key7] = '7',
	[_System.Key8] = '8',
	[_System.Key9] = '9',
	[_System.Key0] = '0',
	[1001] = 'left',
	[1002] = 'right',
};

SetSystemConsts.KeyStrConsts = {
	[_System.KeyA] = 'A',
	[_System.KeyB] = 'B',
	[_System.KeyC] = 'C',
	[_System.KeyD] = 'D',
	[_System.KeyE] = 'E',
	[_System.KeyF] = 'F',
	[_System.KeyG] = 'G',
	[_System.KeyH] = 'H',
	[_System.KeyI] = 'I',
	[_System.KeyJ] = 'J',
	[_System.KeyK] = 'K',
	[_System.KeyL] = 'L',
	[_System.KeyM] = 'M',
	[_System.KeyN] = 'N',
	[_System.KeyO] = 'O',
	[_System.KeyP] = 'P',
	[_System.KeyQ] = 'Q',
	[_System.KeyR] = 'R',
	[_System.KeyS] = 'S',
	[_System.KeyT] = 'T',
	[_System.KeyU] = 'U',
	[_System.KeyV] = 'V',
	[_System.KeyW] = 'W',
	[_System.KeyX] = 'X',
	[_System.KeyY] = 'Y',
	[_System.KeyZ] = 'Z',
	[_System.Key1] = '1',
	[_System.Key2] = '2',
	[_System.Key3] = '3',
	[_System.Key4] = '4',
	[_System.Key5] = '5',
	[_System.Key6] = '6',                                  
	[_System.Key7] = '7',                                                      
	[_System.Key8] = '8',
	[_System.Key9] = '9',
	[_System.Key0] = '0',
	[_System.KeySpace] = StrConfig['setsys50'],
	[1001] = StrConfig['setsys51'],
	[1002] = StrConfig['setsys52'],
};

SetSystemConsts.KeyFuncID = {
	[1] = FuncConsts.Role, --角色
	[2] = FuncConsts.Bag, --背包
};

SetSystemConsts.SkillKeyMap = {
	[1] = 0,
	[2] = 1,
	[3] = 2,
	[4] = 3,
	[5] = 4,
	[6] = 5,
	[7] = 6,
	--
	[8] = 7,
	[9] = 8,
	[10] = 9,
	[11] = 11,
	[12] = 12,
	[13] = 13,
	[14] = 14,
	[15] = 15,
	--
	--[16] = 15,
	--[17] = 17,
	--[18] = 18,
};

SetSystemConsts.DrugKeyMap = {
	[1] = SkillConsts.ShortCutItemKey;
}

SetSystemConsts.cameraMaxHeightMultiple = 2