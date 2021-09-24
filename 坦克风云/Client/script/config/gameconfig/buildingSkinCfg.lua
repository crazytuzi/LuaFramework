buildingSkinAddress ={["mapSkin"]={ [1]={}, [2]={} },["mainSkin"]={},["graySkin"]={},["commonSkin"]={},["baseSkin"]={},["isSnowing"]=nil}---皮肤的父类地址，对应的type值
--mapskin ={ 1=地图地址名称，2=size,3=parent }
--buildingSkinAddress["worldMapNeedSHowIndexs"] --世界地图块数
-- buildingSkinAddress["worldMap"] --世界地图冬季皮肤，不为nil 表示下载成功

buildingSkinCfg = {-- winterSkin 基地内各个建筑的冬季皮肤
	
	[1]={
		  winterSkin="tie_kuang_building_win.png"
	},
	[2]={
		  winterSkin="shi_you_building_win.png"
	},
	[4]={
		  winterSkin="tai_kuang_building_win.png"
	},
	[8]={
		  winterSkin="ke_ji_zhong_xin_building_win.png"
	},
	[16]={
		  winterSkin="junshiyanxi_building_win.png"
	},
	[17]={
		  winterSkin="basementBuilding_win.png"
	},
	[9]={
		  winterSkin="dao_ju_building_win.png"
	},
	[101]={
		  winterSkin="refiningBuilding_win.png"
	},
	[5]={
		  winterSkin="shui_jing_gong_chang_building_win.png"
	},
	[10]={
		  winterSkin="cang_ku_building_win.png"
	},
	[11]={
		  winterSkin="alien_tech_building_1_win.png"
	},
	[3]={
		  winterSkin="qian_kuang_building_win.png"
	},
	[6]={
		  winterSkin="tan_ke_gong_chang_bulding_win.png"
	},
	[12]={
		  winterSkin="militaryAcademy_win.png"
	},
	[13]={
		  winterSkin="alien_tech_factory_building_win.png"
	},
	[102]={
		  winterSkin="superWeaponBuilding_win.png"
	},
	[7]={
		  winterSkin="zhu_ji_di_building_win.png"
	},
	[14]={
		  winterSkin="gai_zhuang_chang_building_win.png"
	},
	[104]={
		  winterSkin="emblemBuilding_win.png"
	},
	[103]={
		  winterSkin="ladderBuilding_win.png"
	},
	[15]={
		  winterSkin="gong_hui_building_win.png"
	},
  	[105]={
		  winterSkin="armorMatrix_win.png"
	},
  	[106]={
		  winterSkin="planeBuilding_win.png"
	},

	common={--世界地图上资源建筑的冬季皮肤
        {winterSkin="world_island_1_win.png"},
        {winterSkin="world_island_2_win.png"},
        {winterSkin="world_island_3_win.png"},
        {winterSkin="world_island_4_win.png"},
        {winterSkin="world_island_5_win.png"},
    },

}

mapForSnowCfg={
	--beginTime:下雪开始时间
	--lastTime:下雪持续时间  单位（分）
	[1]={
		beginTime={{9,28},{11,40},{13,10},{16,24},{22,3}},
		lastTime={{5},{5},{3},{10},{15}},
	},
	[2]={
		beginTime={{10,28},{12,10},{15,5},{19,24},{1,3}},
		lastTime={{5},{8},{9},{15},{3}},
	},
	[3]={
		beginTime={{10,28},{11,55},{14,10},{19,1},{23,30}},
		lastTime={{5},{10},{5},{7},{20}},
	},
	[4]={
		beginTime={{8,28},{9,40},{13,10},{17,24},{21,10}},
		lastTime={{6},{11},{5},{8},{15}},
	},
	[5]={
		beginTime={{9,1},{11,40},{16,10},{21,50},{1,30}},
		lastTime={{15},{5},{10},{3},{8}},
	},
	[6]={
		beginTime={{8,55},{11,10},{17,10},{20,24},{23,3}},
		lastTime={{10},{5},{5},{6},{5}},
	},
	[7]={
		beginTime={{9,50},{11,40},{14,10},{18,24},{1,3}},
		lastTime={{12},{5},{8},{5},{10}},
	},
}

