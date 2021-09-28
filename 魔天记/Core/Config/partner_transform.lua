local partner_transform={
['114003_1']={'114003_1',114003,1,'幻化一阶','370120_1',0,296,22,111,92,0,0,0,0},
['114003_2']={'114003_2',114003,2,'幻化二阶','370120_3',0,592,44,222,185,0,0,0,0},
['114003_3']={'114003_3',114003,3,'幻化三阶','370120_5',0,888,66,333,278,0,0,0,0},
['114003_4']={'114003_4',114003,4,'幻化四阶','370120_7',0,1184,88,445,371,0,0,0,0},
['113002_1']={'113002_1',113002,1,'幻化一阶','370112_1',4685,0,39,200,167,0,0,0,0},
['113002_2']={'113002_2',113002,2,'幻化二阶','370112_3',9370,0,79,401,334,0,0,0,0},
['113002_3']={'113002_3',113002,3,'幻化三阶','370112_5',14055,0,119,601,501,0,0,0,0},
['113002_4']={'113002_4',113002,4,'幻化四阶','370112_7',18741,0,159,802,668,0,0,0,0},
['112002_1']={'112002_1',112002,1,'幻化一阶','370113_1',0,296,22,111,92,0,0,0,0},
['112002_2']={'112002_2',112002,2,'幻化二阶','370113_3',0,592,44,222,185,0,0,0,0},
['112002_3']={'112002_3',112002,3,'幻化三阶','370113_5',0,888,66,333,278,0,0,0,0},
['112002_4']={'112002_4',112002,4,'幻化四阶','370113_7',0,1184,88,445,371,0,0,0,0},
['112003_1']={'112003_1',112003,1,'幻化一阶','370114_1',4685,0,39,200,167,0,0,0,0},
['112003_2']={'112003_2',112003,2,'幻化二阶','370114_3',9370,0,79,401,334,0,0,0,0},
['112003_3']={'112003_3',112003,3,'幻化三阶','370114_5',14055,0,119,601,501,0,0,0,0},
['112003_4']={'112003_4',112003,4,'幻化四阶','370114_7',18741,0,159,802,668,0,0,0,0},
['115009_1']={'115009_1',115009,1,'幻化一阶','370119_1',0,338,53,267,222,0,0,0,0},
['115009_2']={'115009_2',115009,2,'幻化二阶','370119_3',0,676,106,534,445,0,0,0,0},
['115009_3']={'115009_3',115009,3,'幻化三阶','370119_5',0,1014,159,801,668,0,0,0,0},
['115009_4']={'115009_4',115009,4,'幻化四阶','370119_7',0,1353,213,1069,891,0,0,0,0},
['114004_1']={'114004_1',114004,1,'幻化一阶','370121_1',6060,0,68,345,287,0,0,0,0},
['114004_2']={'114004_2',114004,2,'幻化二阶','370121_3',12121,0,137,690,575,0,0,0,0},
['114004_3']={'114004_3',114004,3,'幻化三阶','370121_5',18182,0,206,1035,863,0,0,0,0},
['114004_4']={'114004_4',114004,4,'幻化四阶','370121_7',24243,0,275,1381,1151,0,0,0,0},
['115007_1']={'115007_1',115007,1,'幻化一阶','370117_1',0,338,53,267,222,0,0,0,0},
['115007_2']={'115007_2',115007,2,'幻化二阶','370117_3',0,676,106,534,445,0,0,0,0},
['115007_3']={'115007_3',115007,3,'幻化三阶','370117_5',0,1014,159,801,668,0,0,0,0},
['115007_4']={'115007_4',115007,4,'幻化四阶','370117_7',0,1353,213,1069,891,0,0,0,0},
['115008_1']={'115008_1',115008,1,'幻化一阶','370118_1',6060,0,68,345,287,0,0,0,0},
['115008_2']={'115008_2',115008,2,'幻化二阶','370118_3',12121,0,137,690,575,0,0,0,0},
['115008_3']={'115008_3',115008,3,'幻化三阶','370118_5',18182,0,206,1035,863,0,0,0,0},
['115008_4']={'115008_4',115008,4,'幻化四阶','370118_7',24243,0,275,1381,1151,0,0,0,0},
['115006_1']={'115006_1',115006,1,'幻化一阶','370116_1',0,423,75,378,315,0,0,0,0},
['115006_2']={'115006_2',115006,2,'幻化二阶','370116_3',0,846,151,757,631,0,0,0,0},
['115006_3']={'115006_3',115006,3,'幻化三阶','370116_5',0,1269,226,1136,947,0,0,0,0},
['115006_4']={'115006_4',115006,4,'幻化四阶','370116_7',0,1692,302,1515,1263,0,0,0,0}
}
local ks={partner_level=1,id=2,transform_level=3,transform_name=4,transform_cost=5,hp_max=6,phy_att=7,phy_def=8,hit=9,eva=10,crit=11,fatal=12,tough=13,block=14}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(partner_transform)do setmetatable(v,base)end base.__metatable=false
return partner_transform
