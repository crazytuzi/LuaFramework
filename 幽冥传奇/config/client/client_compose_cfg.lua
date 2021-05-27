ClientComposeType = {
	Cailiao = 1,  --合成类型
	Gem = 2,
	xinghun = 3, --星魂
	fashion = 4, --时装
}

ClientSecondComposeType = {
	LevelDan =1, 
	skill = 2, 
}

--物品合成列表，对应ItemSynthesisConfig中的key
ClientComposeCfg = { --背包合成索引
	8,2,13,4
}


ClientGodEquip = {
	 [1] = {
		     btn_name = "【热血】霸者面甲", -- 按钮名字
		     max_num = 1,
		     index = 12, -- 对应--ItemSynthesisConfig中的key 也就是第几个
		     child_index = 1, --对应配置 需要新加字段 child_index  
	      },
     [2] = {
		     btn_name = "【热血】霸者护肩", -- 按钮名字
		     max_num = 1,
		     index = 12, -- 对应--ItemSynthesisConfig中的key 也就是第几个
		     child_index = 2, --对应配置 需要新加字段 child_index  
	      },
     [3] = {
             btn_name = "【热血】霸者吊坠", -- 按钮名字
             max_num = 1,
             index = 12, -- 对应--ItemSynthesisConfig中的key 也就是第几个
             child_index = 3, --对应配置 需要新加字段 child_index  
        },
     [4] = {
            btn_name = "【热血】霸者护膝", -- 按钮名字
            max_num = 1,
            index = 12, -- 对应--ItemSynthesisConfig中的key 也就是第几个
            child_index = 4, --对应配置 需要新加字段 child_index  
        },
}