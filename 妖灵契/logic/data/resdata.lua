 module(...)
GCStep = 1024 -- lua gc step 大小
UnloadAtlasCount = 5 -- 达到次数则释放图集
MapGCTime = 180 -- 超时则切图gc
GcAssetReleaseCnt = 1
CloneCacheMaxSize = 30
ObjectCacheMaxSize = 30

CachedTime = 60
CostPerFrame = 5

DynamicLevel = 
{
	TaskNpc = 12,
	Npc = 11,
	Player = 10,
}

Config = {
	--View缓存
		--需在OnShowView的时候重置界面
		--需在OnHideView的时候清掉不需要的东西
	["CWarResultView"] = {cache_time = 300},
	-- ["CPartnerMainView"] = {cache_time = 30},
	-- ["CFriendMainView"] = {cache_time = 10},
	["CMainMenuView"] = {cache_time = 60},
	["CGmView"] = {cache_time = 120},
	--Box缓存
	["CGmView.m_CloneTabBtn"] = {lv=1001},
	["CGmView.m_CloneBtnInfoListBtn"] = {lv=1000},
	["CWarSpeedControlBox.AvatarBoxL"] = {cache_time = 120},
	["CWarSpeedControlBox.AvatarBoxR"] = {cache_time = 120},
	["CWarOrderMenu.MagicBox"] = {cache_time = 120},
	["CWarAutoMenu.MagicBox"] = {cache_time = 120},

	--Path
	["UI/Magic/WarStartView.prefab"] = {cache_time=3600},
	["UI/Hud/NameHud.prefab"] = {lv=20},
	["UI/Hud/BloodHud.prefab"] = {lv=20},
	["UI/Hud/WarriorOrderHud.prefab"] = {lv=19},
	["Model/Character/110/Prefabs/model110.prefab"] = {lv=9},
	["Model/Character/120/Prefabs/model120.prefab"] = {lv=9},
	["Model/Character/130/Prefabs/model130.prefab"] = {lv=9},
	["Model/Character/140/Prefabs/model140.prefab"] = {lv=9},
	["Model/Character/150/Prefabs/model150.prefab"] = {lv=9},
	["Model/Character/160/Prefabs/model160.prefab"] = {lv=9},
	["Model/Character/302/Prefabs/model302.prefab"] = {lv=9},
	["Model/Weapon/2000/Prefabs/weapon2000.prefab"] = {lv=-2},
	["Model/Weapon/2100/Prefabs/weapon2100.prefab"] = {lv=-2},
	["Model/Weapon/2200/Prefabs/weapon2200.prefab"] = {lv=-2},
	["Model/Weapon/2400/Prefabs/weapon2400.prefab"] = {lv=-2},
	["Model/Weapon/2300/Prefabs/weapon2300_1.prefab"] = {lv=-1},
	["Model/Weapon/2300/Prefabs/weapon2300_2.prefab"] = {lv=-1},
	["Model/Weapon/2500/Prefabs/weapon2500_1.prefab"] = {lv=-1},
	["Model/Weapon/2500/Prefabs/weapon2500_2.prefab"] = {lv=-1},
}