--[[
地图元素工厂
2015年4月6日21:43:21
haohu
]]

_G.MapVOFactory = {};

function MapVOFactory:CreateMapElem(elemType)
	local class;
	if elemType == MapConsts.Type_MainPlayer then
		class = MapMainPlayerVO;
	elseif elemType == MapConsts.Type_Player then
		class = MapPlayerVO;
	elseif elemType == MapConsts.Type_NpcS then
		class = MapNpcSVO;
	elseif elemType == MapConsts.Type_Npc then
		class = MapNpcVO;
	elseif elemType == MapConsts.Type_Monster then
		class = MapMonsterVO;     --小地图中的怪物
	elseif elemType == MapConsts.Type_MonsterArea then
		class = MapMonsterAreaVO; --M地图中的怪物
	elseif elemType == MapConsts.Type_Special then
		class = MapSpecialVO;
	elseif elemType == MapConsts.Type_Path then
		class = MapPathPointVO;
	elseif elemType == MapConsts.Type_Portal then
		class = MapPortalVO;
	elseif elemType == MapConsts.Type_Hang then
		class = MapHangPointVO;
	elseif elemType == MapConsts.Type_UnionWarBuilding then
		class = MapUnionWarBuildingVO;
	elseif elemType == MapConsts.Type_UnionCityUnits then
		class = MapUnionCityUnitVO;
	elseif elemType == MapConsts.Type_ZhanchangUnits then
		class = MapZhanchangUnitVO;
	elseif elemType == MapConsts.Type_UnionDiGongFlag then
		class = MapDiGongFlagVO;
	end
	if not class then
		Error( string.format( "cannot create map element, element type: %s", elemType ) );
		return;
	end
	return MapObjectPool:GetObject( class );
end