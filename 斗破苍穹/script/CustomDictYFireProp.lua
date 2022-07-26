require"Lang"
CustomDictYFireProp = {
    --   【名称】            【品阶ID】      【星级ID】         【装备异火数量】     【属性ID】(以;隔开)       【属性值】(以;隔开)
    { name = Lang.CustomDictYFireProp1, qualityId = 4, starLevelId = 4, equipFireCount = 1, fightPropId = "1;8;9", fightPropValue = "20;20;20" },
    { name = Lang.CustomDictYFireProp2, qualityId = 5, starLevelId = 4, equipFireCount = 2, fightPropId = "1;8;9", fightPropValue = "40;40;40" },
    { name = Lang.CustomDictYFireProp3, qualityId = 6, starLevelId = 5, equipFireCount = 3, fightPropId = "1;8;9", fightPropValue = "60;60;60" },
}

dp.FireEquipGrid = {
    --【第一个位置】
    { qualityId = 4, starLevelId = 3 },

    --【第二个位置】
    { qualityId = 5, starLevelId = 2 },

    --【第三个位置】
    { qualityId = 6, starLevelId = 2 }
}
