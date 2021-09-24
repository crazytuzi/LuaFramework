worldGroundCfg=
{
	--id: 地形的ID,1山地,2沙漠,3平原,4森林,5沼泽,6城市
	--name: 地形的名字
	--desc: 地形的描述
	--attType: 效果类型 100攻击,102命中,103闪避,106暴击,107装甲,108血量, 109免伤, 此处与playerSkillCfg中保持一致
	--attValue: 效果生效的数值, 是一个百分比, 要除以100之后再用
	{id=1,name="world_ground_name_1",attType={107,106},attValue={20,-10}},
	{id=2,name="world_ground_name_2",attType={106,102},attValue={20,-10}},
	{id=3,name="world_ground_name_3",attType={102,103},attValue={20,-10}},
	{id=4,name="world_ground_name_4",attType={103,107},attValue={20,-10}},
	{id=5,name="world_ground_name_5",attType={109,100},attValue={20,-10}},
	{id=6,name="world_ground_name_6",attType={100,109},attValue={10,10}},
}