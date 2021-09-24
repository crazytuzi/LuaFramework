-- _G.MapData[10100]  -> 场景(地图) 

-- 太平镇
_G.MapData[10100] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10100, -- 地图素材id
			data = { topside = { },move = { [1] = { x=252,w=3329,ty=160,by=10}},before = { [1] = { type=[[spine]],name=[[10100_bf_02]],x=1100,y=620},[2] = { type=[[spine]],name=[[10100_bf_02]],x=2900,y=620}},map = { [1] = { type=[[jpg]],name=[[10100_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10100_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10100_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10100_04]],x=1536,y=0},[5] = { type=[[jpg]],name=[[10100_05]],x=2048,y=0},[6] = { type=[[jpg]],name=[[10100_06]],x=2560,y=0},[7] = { type=[[jpg]],name=[[10100_07]],x=3072,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=3584, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10100    -- 缩略图ID
} 


-- 苗疆
_G.MapData[10200] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10200, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10200_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[10200_qj_02]],x=2224,y=0}},move = { [1] = { x=252,w=2132,ty=200,by=20},[2] = { x=2384,w=100,ty=200,by=20},[3] = { x=2484,w=997,ty=150,by=20}},before = { },map = { [1] = { type=[[jpg]],name=[[10200_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10200_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10200_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10200_04]],x=1536,y=0},[5] = { type=[[jpg]],name=[[10200_05]],x=2048,y=0},[6] = { type=[[jpg]],name=[[10200_06]],x=2560,y=0},[7] = { type=[[jpg]],name=[[10200_07]],x=3072,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=3584, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10200    -- 缩略图ID
} 


-- 黄泉路
_G.MapData[10500] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10500, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10500_qj_02]],x=0,y=0}},move = { [1] = { x=50,w=700,ty=230,by=20},[2] = { x=750,w=148,ty=200,by=30},[3] = { x=898,w=150,ty=190,by=60},[4] = { x=1048,w=50,ty=190,by=60},[5] = { x=1098,w=902,ty=190,by=30}},before = { [1] = { type=[[png]],name=[[10500_qj_01]],x=520,y=60}},map = { [1] = { type=[[jpg]],name=[[10500_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10500_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10500_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10500_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10500    -- 缩略图ID
} 


-- 地府口
_G.MapData[11000] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11000, -- 地图素材id
			data = { topside = { },move = { [1] = { x=200,w=500,ty=90,by=10},[2] = { x=700,w=2200,ty=150,by=10},[3] = { x=2900,w=400,ty=150,by=10},[4] = { x=3300,w=100,ty=110,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[11000_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11000_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11000_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11000_04]],x=1536,y=0},[5] = { type=[[jpg]],name=[[11000_05]],x=2048,y=0},[6] = { type=[[jpg]],name=[[11000_06]],x=2560,y=0},[7] = { type=[[jpg]],name=[[11000_07]],x=3072,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=3584, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11000    -- 缩略图ID
} 


-- 朱紫国
_G.MapData[11800] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11800, -- 地图素材id
			data=nil, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=3584, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11800    -- 缩略图ID
} 


-- 城镇街道
_G.MapData[10101] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10101, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10101_qj_02]],x=1000,y=0},[2] = { type=[[png]],name=[[10101_qj_03]],x=1250,y=0},[3] = { type=[[gaf]],name=[[Snow]],x=732,y=337},[4] = { type=[[png]],name=[[10101_qj_01]],x=50,y=0}},move = { [1] = { x=18,w=1500,ty=160,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[10101_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10101_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10101_03]],x=1024,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=1536, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10101    -- 缩略图ID
} 


-- 城镇街道_通用
_G.MapData[10102] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10102, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10101_qj_02]],x=1000,y=0},[2] = { type=[[png]],name=[[10101_qj_03]],x=1250,y=0},[3] = { type=[[gaf]],name=[[Snow]],x=732,y=337},[4] = { type=[[png]],name=[[10101_qj_01]],x=50,y=0}},move = { [1] = { x=18,w=1500,ty=160,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[10101_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10101_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10101_03]],x=1024,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=1536, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10102    -- 缩略图ID
} 


-- 龙
_G.MapData[10201] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10201, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10201_bf]],x=0,y=0}},move = { [1] = { x=150,w=150,ty=200,by=100},[2] = { x=300,w=200,ty=280,by=180},[3] = { x=500,w=400,ty=270,by=170},[4] = { x=900,w=100,ty=150,by=50},[5] = { x=1000,w=200,ty=160,by=60}},before = { },map = { [1] = { type=[[jpg]],name=[[10201_1]],x=0,y=0},[2] = { type=[[jpg]],name=[[10201_2]],x=500,y=0},[3] = { type=[[jpg]],name=[[10201_3]],x=1000,y=0},[4] = { type=[[jpg]],name=[[10201_4]],x=1500,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=1671, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10201    -- 缩略图ID
} 


-- 龙_通用
_G.MapData[10202] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10202, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10201_bf]],x=0,y=0}},move = { [1] = { x=150,w=150,ty=200,by=100},[2] = { x=300,w=200,ty=280,by=180},[3] = { x=500,w=400,ty=270,by=170},[4] = { x=900,w=100,ty=150,by=50},[5] = { x=1000,w=200,ty=160,by=60}},before = { },map = { [1] = { type=[[jpg]],name=[[10201_1]],x=0,y=0},[2] = { type=[[jpg]],name=[[10201_2]],x=500,y=0},[3] = { type=[[jpg]],name=[[10201_3]],x=1000,y=0},[4] = { type=[[jpg]],name=[[10201_4]],x=1500,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=1671, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10202    -- 缩略图ID
} 


-- 寂静公园
_G.MapData[10301] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10301, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=1948,ty=180,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[10301_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10301_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10301_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10301_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10301    -- 缩略图ID
} 


-- 寂静公园_通用
_G.MapData[10302] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10302, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=1948,ty=180,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[10301_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10301_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10301_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10301_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10302    -- 缩略图ID
} 


-- 乱葬岗
_G.MapData[10401] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10401, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10401_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[10401_qj_02]],x=1300,y=0}},move = { [1] = { x=50,w=1948,ty=200,by=10}},before = { [1] = { type=[[png]],name=[[10401_bf_01]],x=1000,y=400}},map = { [1] = { type=[[jpg]],name=[[10401_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10401_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10401_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10401_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10401    -- 缩略图ID
} 


-- 乱葬岗_通用
_G.MapData[10402] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10402, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10401_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[10401_qj_02]],x=1300,y=0}},move = { [1] = { x=50,w=1948,ty=200,by=10}},before = { [1] = { type=[[png]],name=[[10401_bf_01]],x=1000,y=400}},map = { [1] = { type=[[jpg]],name=[[10401_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10401_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10401_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10401_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10402    -- 缩略图ID
} 


-- 寂静森林
_G.MapData[10501] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10501, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10501_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[10501_qj_02]],x=400,y=0},[3] = { type=[[png]],name=[[10501_qj_03]],x=1866,y=0}},move = { [1] = { x=50,w=1948,ty=180,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[10501_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10501_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10501_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10501_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10501    -- 缩略图ID
} 


-- 寂静森林_通用
_G.MapData[10502] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10502, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10501_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[10501_qj_02]],x=400,y=0},[3] = { type=[[png]],name=[[10501_qj_03]],x=1866,y=0}},move = { [1] = { x=50,w=1948,ty=180,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[10501_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10501_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10501_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10501_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10502    -- 缩略图ID
} 


-- 山脉
_G.MapData[10601] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10601, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10601_qj_01]],x=0,y=0}},move = { [1] = { x=50,w=1948,ty=180,by=10}},before = { [1] = { type=[[gaf]],name=[[smoke2]],x=700,y=150}},map = { [1] = { type=[[jpg]],name=[[10601_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10601_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10601_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10601_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10601    -- 缩略图ID
} 


-- 山脉_通用
_G.MapData[10602] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10602, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10601_qj_01]],x=0,y=0}},move = { [1] = { x=50,w=1948,ty=180,by=10}},before = { [1] = { type=[[gaf]],name=[[smoke2]],x=700,y=150}},map = { [1] = { type=[[jpg]],name=[[10601_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10601_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10601_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10601_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10602    -- 缩略图ID
} 


-- 苗疆森林
_G.MapData[10701] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10701, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=1548,ty=180,by=20},[2] = { x=1598,w=400,ty=180,by=50}},before = { },map = { [1] = { type=[[jpg]],name=[[10701_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10701_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10701_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10701_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10701    -- 缩略图ID
} 


-- 苗疆森林_通用
_G.MapData[10702] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10702, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=1548,ty=180,by=20},[2] = { x=1598,w=400,ty=180,by=50}},before = { },map = { [1] = { type=[[jpg]],name=[[10701_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10701_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10701_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10701_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10702    -- 缩略图ID
} 


-- 苗疆密林
_G.MapData[10801] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10801, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10801_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[10801_qj_02]],x=775,y=0},[3] = { type=[[png]],name=[[10801_qj_03]],x=1621,y=0}},move = { [1] = { x=50,w=100,ty=180,by=10},[2] = { x=150,w=200,ty=180,by=20},[3] = { x=350,w=200,ty=130,by=20},[4] = { x=550,w=100,ty=130,by=20},[5] = { x=650,w=1348,ty=180,by=10}},before = { [1] = { type=[[gaf]],name=[[candle]],x=837,y=245},[2] = { type=[[gaf]],name=[[candle]],x=927,y=245}},map = { [1] = { type=[[jpg]],name=[[10801_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10801_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10801_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10801_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10801    -- 缩略图ID
} 


-- 苗疆密林_通用
_G.MapData[10802] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10802, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10801_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[10801_qj_02]],x=775,y=0},[3] = { type=[[png]],name=[[10801_qj_03]],x=1621,y=0}},move = { [1] = { x=50,w=100,ty=180,by=10},[2] = { x=150,w=200,ty=180,by=20},[3] = { x=350,w=200,ty=130,by=20},[4] = { x=550,w=100,ty=130,by=20},[5] = { x=650,w=1348,ty=180,by=10}},before = { [1] = { type=[[gaf]],name=[[candle]],x=837,y=245},[2] = { type=[[gaf]],name=[[candle]],x=927,y=245}},map = { [1] = { type=[[jpg]],name=[[10801_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10801_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10801_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10801_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10802    -- 缩略图ID
} 


-- 苗疆河流
_G.MapData[10901] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10901, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10901_qj_01]],x=0,y=300},[2] = { type=[[png]],name=[[10901_qj_02]],x=1469,y=0}},move = { [1] = { x=50,w=1948,ty=180,by=10}},before = { [1] = { type=[[gaf]],name=[[dimple]],x=0,y=0},[2] = { type=[[gaf]],name=[[dimple]],x=1469,y=0}},map = { [1] = { type=[[jpg]],name=[[10901_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10901_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10901_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10901_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10901    -- 缩略图ID
} 


-- 苗疆河流_通用
_G.MapData[10902] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10902, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10901_qj_01]],x=0,y=300},[2] = { type=[[png]],name=[[10901_qj_02]],x=1469,y=0}},move = { [1] = { x=50,w=1948,ty=180,by=10}},before = { [1] = { type=[[gaf]],name=[[dimple]],x=0,y=0},[2] = { type=[[gaf]],name=[[dimple]],x=1469,y=0}},map = { [1] = { type=[[jpg]],name=[[10901_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10901_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10901_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10901_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10902    -- 缩略图ID
} 


-- 苗疆圣湖
_G.MapData[11001] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11001, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11001_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11001_qj_02]],x=1524,y=0}},move = { [1] = { x=400,w=224,ty=50,by=10},[2] = { x=624,w=950,ty=100,by=10},[3] = { x=1574,w=10,ty=100,by=20},[4] = { x=1584,w=0,ty=140,by=10}},before = { },map = { [1] = { type=[[png]],name=[[11001_01]],x=0,y=0},[2] = { type=[[png]],name=[[11001_02]],x=512,y=0},[3] = { type=[[png]],name=[[11001_03]],x=1024,y=0},[4] = { type=[[png]],name=[[11001_04]],x=1536,y=0}},bg = { [1] = { type=[[jpg]],name=[[11001_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11001_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11001_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11001_bg_04]],x=1536,y=0}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11001    -- 缩略图ID
} 


-- 苗疆圣湖_通用
_G.MapData[11002] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11002, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11001_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11001_qj_02]],x=1524,y=0}},move = { [1] = { x=400,w=224,ty=50,by=10},[2] = { x=624,w=950,ty=100,by=10},[3] = { x=1574,w=10,ty=100,by=20},[4] = { x=1584,w=0,ty=140,by=10}},before = { },map = { [1] = { type=[[png]],name=[[11001_01]],x=0,y=0},[2] = { type=[[png]],name=[[11001_02]],x=512,y=0},[3] = { type=[[png]],name=[[11001_03]],x=1024,y=0},[4] = { type=[[png]],name=[[11001_04]],x=1536,y=0}},bg = { [1] = { type=[[jpg]],name=[[11001_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11001_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11001_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11001_bg_04]],x=1536,y=0}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11002    -- 缩略图ID
} 


-- 巫术研究所
_G.MapData[11101] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11101, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11101_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11101_qj_02]],x=512,y=0},[3] = { type=[[png]],name=[[11101_qj_03]],x=1024,y=0},[4] = { type=[[gaf]],name=[[candle]],x=1512,y=50}},move = { [1] = { x=50,w=1464,ty=170,by=30}},before = { [1] = { type=[[gaf]],name=[[magic]],x=780,y=300}},map = { [1] = { type=[[jpg]],name=[[11101_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11101_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11101_03]],x=1024,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=1536, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11101    -- 缩略图ID
} 


-- 巫术研究所_通用
_G.MapData[11102] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11102, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11101_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11101_qj_02]],x=512,y=0},[3] = { type=[[png]],name=[[11101_qj_03]],x=1024,y=0},[4] = { type=[[gaf]],name=[[candle]],x=1512,y=50}},move = { [1] = { x=50,w=1464,ty=170,by=30}},before = { [1] = { type=[[gaf]],name=[[magic]],x=780,y=300}},map = { [1] = { type=[[jpg]],name=[[11101_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11101_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11101_03]],x=1024,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=1536, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11102    -- 缩略图ID
} 


-- 鬼门关
_G.MapData[11201] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11201, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11201_qj_01]],x=400,y=0},[2] = { type=[[png]],name=[[11201_qj_01]],x=1448,y=0},[3] = { type=[[png]],name=[[11201_qj_02]],x=1600,y=0},[4] = { type=[[gaf]],name=[[fire1]],x=520,y=80},[5] = { type=[[gaf]],name=[[fire1]],x=1568,y=80}},move = { [1] = { x=50,w=1950,ty=230,by=20}},before = { },map = { [1] = { type=[[jpg]],name=[[11201_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11201_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11201_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11201_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11201    -- 缩略图ID
} 


-- 鬼门关_通用
_G.MapData[11202] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11202, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11201_qj_01]],x=400,y=0},[2] = { type=[[png]],name=[[11201_qj_01]],x=1448,y=0},[3] = { type=[[png]],name=[[11201_qj_02]],x=1600,y=0},[4] = { type=[[gaf]],name=[[fire1]],x=520,y=80},[5] = { type=[[gaf]],name=[[fire1]],x=1568,y=80}},move = { [1] = { x=50,w=1950,ty=230,by=20}},before = { },map = { [1] = { type=[[jpg]],name=[[11201_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11201_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11201_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11201_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11202    -- 缩略图ID
} 


-- 黄泉路上
_G.MapData[11301] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11301, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=700,ty=230,by=20},[2] = { x=750,w=148,ty=200,by=30},[3] = { x=898,w=150,ty=190,by=60},[4] = { x=1048,w=50,ty=190,by=60},[5] = { x=1098,w=902,ty=190,by=30}},before = { },map = { [1] = { type=[[jpg]],name=[[10500_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10500_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10500_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10500_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11301    -- 缩略图ID
} 


-- 黄泉路上_通用
_G.MapData[11302] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11302, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=700,ty=230,by=20},[2] = { x=750,w=148,ty=200,by=30},[3] = { x=898,w=150,ty=190,by=60},[4] = { x=1048,w=50,ty=190,by=60},[5] = { x=1098,w=902,ty=190,by=30}},before = { },map = { [1] = { type=[[jpg]],name=[[10500_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[10500_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[10500_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[10500_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11302    -- 缩略图ID
} 


-- 古墓
_G.MapData[11401] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11401, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11401_qj_02]],x=0,y=0},[2] = { type=[[png]],name=[[11401_qj_01]],x=1900,y=0}},move = { [1] = { x=50,w=1950,ty=200,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[11401_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11401_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11401_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11401_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2045, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11401    -- 缩略图ID
} 


-- 古墓_通用
_G.MapData[11402] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11402, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11401_qj_02]],x=0,y=0},[2] = { type=[[png]],name=[[11401_qj_01]],x=1900,y=0}},move = { [1] = { x=50,w=1950,ty=200,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[11401_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11401_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11401_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11401_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2045, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11402    -- 缩略图ID
} 


-- 阴曹地界
_G.MapData[11501] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11501, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11501_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11501_qj_01]],x=1953,y=0},[3] = { type=[[spine]],name=12801,x=1000,y=300}},move = { [1] = { x=50,w=350,ty=170,by=20},[2] = { x=400,w=150,ty=170,by=20},[3] = { x=550,w=300,ty=170,by=70},[4] = { x=800,w=580,ty=210,by=130},[5] = { x=1380,w=30,ty=210,by=130},[6] = { x=1410,w=50,ty=210,by=150},[7] = { x=1460,w=450,ty=210,by=130}},before = { },map = { [1] = { type=[[jpg]],name=[[11501_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11501_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11501_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11501_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11501    -- 缩略图ID
} 


-- 阴曹地界_通用
_G.MapData[11502] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11502, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11501_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11501_qj_01]],x=1953,y=0},[3] = { type=[[spine]],name=12801,x=1000,y=300}},move = { [1] = { x=50,w=350,ty=170,by=20},[2] = { x=400,w=150,ty=170,by=20},[3] = { x=550,w=300,ty=170,by=70},[4] = { x=800,w=580,ty=210,by=130},[5] = { x=1380,w=30,ty=210,by=130},[6] = { x=1410,w=50,ty=210,by=150},[7] = { x=1460,w=450,ty=210,by=130}},before = { },map = { [1] = { type=[[jpg]],name=[[11501_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11501_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11501_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11501_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11502    -- 缩略图ID
} 


-- 阎王殿
_G.MapData[11601] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11601, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11601_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11601_qj_02]],x=520,y=0},[3] = { type=[[png]],name=[[11601_qj_03]],x=1751,y=0},[4] = { type=[[gaf]],name=[[flame1]],x=60,y=10},[5] = { type=[[gaf]],name=[[flame2]],x=2048,y=0}},move = { [1] = { x=50,w=1948,ty=190,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[11601_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11601_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11601_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11601_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2046, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11601    -- 缩略图ID
} 


-- 阎王殿_通用
_G.MapData[11602] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11602, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11601_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11601_qj_03]],x=1751,y=0},[3] = { type=[[gaf]],name=[[flame1]],x=60,y=10},[4] = { type=[[gaf]],name=[[flame2]],x=2048,y=0}},move = { [1] = { x=50,w=1948,ty=190,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[11601_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11601_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11601_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11601_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2046, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11602    -- 缩略图ID
} 


-- 流沙河
_G.MapData[10211] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10211, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=1948,ty=300,by=75}},before = { [1] = { type=[[png]],name=[[10211_bf_02]],x=145,y=389}},map = { [1] = { type=[[jpg]],name=10211,x=0,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2048, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10211    -- 缩略图ID
} 


-- 流沙河_通用
_G.MapData[10212] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10212, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=1948,ty=300,by=75}},before = { },map = { [1] = { type=[[jpg]],name=10211,x=0,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2048, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10211    -- 缩略图ID
} 


-- 黑松林
_G.MapData[10221] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10221, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=1948,ty=360,by=20}},before = { },map = { [1] = { type=[[jpg]],name=10221,x=0,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2048, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10221    -- 缩略图ID
} 


-- 黑松林_通用
_G.MapData[10222] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10222, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=1948,ty=360,by=20}},before = { },map = { [1] = { type=[[jpg]],name=10221,x=0,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2048, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10221    -- 缩略图ID
} 


-- 五庄观
_G.MapData[10231] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10231, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=1948,ty=270,by=60}},before = { },map = { [1] = { type=[[jpg]],name=10231,x=0,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2048, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10231    -- 缩略图ID
} 


-- 平顶山
_G.MapData[10241] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10241, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10241_ts_01]],x=383,y=0},[2] = { type=[[png]],name=[[10241_ts_01]],x=1413,y=0}},move = { [1] = { x=50,w=950,ty=310,by=20},[2] = { x=1000,w=100,ty=310,by=20},[3] = { x=1100,w=310,ty=280,by=20},[4] = { x=1420,w=100,ty=270,by=20},[5] = { x=1520,w=478,ty=310,by=40}},before = { },map = { [1] = { type=[[jpg]],name=10241,x=0,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2048, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10241    -- 缩略图ID
} 


-- 海底(长)
_G.MapData[10442] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10442, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=75,ty=260,by=20},[2] = { x=125,w=50,ty=260,by=20},[3] = { x=175,w=1268,ty=320,by=20},[4] = { x=1443,w=50,ty=320,by=20},[5] = { x=1493,w=505,ty=256,by=20},[6] = { x=1998,w=75,ty=260,by=20},[7] = { x=2073,w=50,ty=260,by=20},[8] = { x=2123,w=1268,ty=320,by=20},[9] = { x=3391,w=50,ty=320,by=20},[10] = { x=3441,w=505,ty=256,by=20}},before = { },map = { [1] = { type=[[jpg]],name=10441,x=0,y=0},[2] = { type=[[jpg]],name=10441,x=2048,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=4096, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10441    -- 缩略图ID
} 


-- 悬崖(长)
_G.MapData[10522] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10522, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[10521_ts_01]],x=680,y=0},[2] = { type=[[png]],name=[[10521_ts_01]],x=1704,y=0}},move = { [1] = { x=50,w=4000,ty=275,by=15}},before = { },map = { [1] = { type=[[png]],name=[[10521_01]],x=0,y=0},[2] = { type=[[png]],name=[[10521_02]],x=512,y=0},[3] = { type=[[png]],name=[[10521_03]],x=1024,y=0},[4] = { type=[[png]],name=[[10521_04]],x=1536,y=0},[5] = { type=[[png]],name=[[10521_01]],x=2048,y=0},[6] = { type=[[png]],name=[[10521_02]],x=2560,y=0},[7] = { type=[[png]],name=[[10521_03]],x=3072,y=0},[8] = { type=[[png]],name=[[10521_04]],x=3584,y=0}},bg = { [1] = { type=[[jpg]],name=[[10521_bg_01]],x=0,y=280},[2] = { type=[[jpg]],name=[[10521_bg_02]],x=512,y=280},[3] = { type=[[jpg]],name=[[10521_bg_03]],x=1024,y=280},[4] = { type=[[jpg]],name=[[10521_bg_04]],x=1536,y=280},[5] = { type=[[jpg]],name=[[10521_bg_01]],x=2048,y=280},[6] = { type=[[jpg]],name=[[10521_bg_02]],x=2560,y=280},[7] = { type=[[jpg]],name=[[10521_bg_03]],x=3072,y=280},[8] = { type=[[jpg]],name=[[10521_bg_04]],x=3584,y=280}},bg_translationSpeed=0.6,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=4096, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10521    -- 缩略图ID
} 


-- 错层测试
_G.MapData[10105] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10105, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=1948,ty=150,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[11000_03]],x=0,y=0},[2] = { type=[[jpg]],name=[[11000_04]],x=512,y=0},[3] = { type=[[jpg]],name=[[11000_05]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11000_06]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10105    -- 缩略图ID
} 


-- 地雷区
_G.MapData[10999] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=16, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=10999, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[8050_ts_01]],x=950,y=0},[2] = { type=[[png]],name=[[8050_ts_01]],x=1900,y=0},[3] = { type=[[png]],name=[[8050_ts_01]],x=3000,y=0}},move = { [1] = { x=50,w=1460,ty=270,by=10},[2] = { x=1510,w=25,ty=270,by=10},[3] = { x=1535,w=509,ty=200,by=120},[4] = { x=2044,w=25,ty=200,by=120},[5] = { x=2069,w=1485,ty=270,by=10}},before = { },map = { [1] = { type=[[png]],name=[[8050_03]],x=1550,y=150},[2] = { type=[[png]],name=[[8050_04]],x=1515,y=0},[3] = { type=[[png]],name=[[8050_05]],x=2010,y=0},[4] = { type=[[png]],name=[[8050_01]],x=0,y=0},[5] = { type=[[png]],name=[[8050_02]],x=512,y=0},[6] = { type=[[png]],name=[[8050_01]],x=1024,y=0},[7] = { type=[[png]],name=[[8050_06]],x=1540,y=60},[8] = { type=[[png]],name=[[8050_02]],x=2079,y=0},[9] = { type=[[png]],name=[[8050_01]],x=2591,y=0},[10] = { type=[[png]],name=[[8050_02]],x=3103,y=0},[11] = { type=[[png]],name=[[8050_03]],x=320,y=270},[12] = { type=[[png]],name=[[8050_03]],x=2680,y=270}},bg = { [1] = { type=[[jpg]],name=[[8050_bg]],x=0,y=0},[2] = { type=[[jpg]],name=[[8050_bg]],x=1536,y=0},[3] = { type=[[jpg]],name=[[8050_bg]],x=3072,y=0}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=3580, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 10999    -- 缩略图ID
} 


-- 三界妖王【世界BOSS】
_G.MapData[8010] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=8010, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11901_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11901_qj_02]],x=2820,y=0}},move = { [1] = { x=50,w=2972,ty=250,by=10}},before = { [1] = { type=[[gaf]],name=[[fire1]],x=1410,y=410},[2] = { type=[[gaf]],name=[[fire1]],x=1655,y=410},[3] = { type=[[gaf]],name=[[fire4]],x=1530,y=300}},map = { [1] = { type=[[png]],name=[[11901_04]],x=0,y=0},[2] = { type=[[png]],name=[[11901_01]],x=512,y=0},[3] = { type=[[png]],name=[[11901_02]],x=1024,y=0},[4] = { type=[[png]],name=[[11901_03]],x=1536,y=0},[5] = { type=[[png]],name=[[11901_04]],x=2048,y=0},[6] = { type=[[png]],name=[[11901_01]],x=2560,y=0}},bg = { [1] = { type=[[jpg]],name=[[11901_bg_04]],x=0,y=0},[2] = { type=[[jpg]],name=[[11901_bg_01]],x=512,y=0},[3] = { type=[[jpg]],name=[[11901_bg_02]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11901_bg_03]],x=1536,y=0},[5] = { type=[[jpg]],name=[[11901_bg_04]],x=2048,y=0},[6] = { type=[[jpg]],name=[[11901_bg_01]],x=2560,y=0}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=3072, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 8010    -- 缩略图ID
} 


-- 灵妖竞技场
_G.MapData[8020] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=8020, -- 地图素材id
			data = { topside = { },move = { [1] = { x=100,w=1000,ty=180,by=40}},before = { [1] = { type=[[gaf]],name=[[8020_arena]],x=100,y=350},[2] = { type=[[gaf]],name=[[smoke1]],x=600,y=300}},map = { [1] = { type=[[jpg]],name=[[8020_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[8020_02]],x=500,y=0},[3] = { type=[[jpg]],name=[[8020_03]],x=1000,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=1200, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 8020    -- 缩略图ID
} 


-- 洞府争霸【帮派战】
_G.MapData[8030] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=8030, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12601_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[12601_qj_02]],x=1930,y=0},[3] = { type=[[png]],name=[[12601_qj_03]],x=500,y=0}},move = { [1] = { x=50,w=2972,ty=260,by=10}},before = { [1] = { type=[[gaf]],name=[[smoke3]],x=1230,y=350},[2] = { type=[[gaf]],name=[[smoke3]],x=3278,y=350},[3] = { type=[[png]],name=[[12601_bf_01]],x=1595,y=459},[4] = { type=[[gaf]],name=[[dimple]],x=600,y=0},[5] = { type=[[spine]],name=12601,x=1480,y=280}},map = { [1] = { type=[[jpg]],name=[[12601_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12601_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12601_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12601_04]],x=1536,y=0},[5] = { type=[[jpg]],name=[[12601_01]],x=2048,y=0},[6] = { type=[[jpg]],name=[[12601_02]],x=2560,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=3072, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 8030    -- 缩略图ID
} 


-- 竞技场
_G.MapData[8040] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=8040, -- 地图素材id
			data = { topside = { },move = { [1] = { x=60,w=1444,ty=180,by=10}},before = { [1] = { type=[[spine]],name=8040,x=1000,y=290}},map = { [1] = { type=[[jpg]],name=8040,x=0,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=1536, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 8040    -- 缩略图ID
} 


-- 三界妖王【世界BOSS】
_G.MapData[8050] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=8050, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12101_qj_01]],x=0,y=460},[2] = { type=[[png]],name=[[12101_qj_03]],x=0,y=0},[3] = { type=[[png]],name=[[12101_qj_03]],x=2046,y=0},[4] = { type=[[png]],name=[[12101_qj_04]],x=1548,y=0},[5] = { type=[[png]],name=[[12101_qj_01]],x=2050,y=460},[6] = { type=[[png]],name=[[12101_qj_02]],x=1230,y=396},[7] = { type=[[png]],name=[[12101_qj_04]],x=2572,y=0}},move = { [1] = { x=50,w=2972,ty=250,by=25}},before = { },map = { [1] = { type=[[png]],name=[[12101_01]],x=0,y=0},[2] = { type=[[png]],name=[[12101_02]],x=512,y=0},[3] = { type=[[png]],name=[[12101_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12101_04]],x=1536,y=0},[5] = { type=[[png]],name=[[12101_01]],x=2048,y=0},[6] = { type=[[png]],name=[[12101_02]],x=2560,y=0}},bg = { [1] = { type=[[jpg]],name=[[12101_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12101_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12101_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12101_bg_04]],x=1536,y=0},[5] = { type=[[jpg]],name=[[12101_bg_01]],x=2048,y=0},[6] = { type=[[jpg]],name=[[12101_bg_02]],x=2560,y=0}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=3072, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 8050    -- 缩略图ID
} 


-- 阴山老道
_G.MapData[11701] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11701, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11701_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11701_qj_02]],x=1100,y=0},[3] = { type=[[gaf]],name=[[candle]],x=92,y=95}},move = { [1] = { x=50,w=1948,ty=240,by=10}},before = { },map = { [1] = { type=[[png]],name=[[11701_01]],x=0,y=0},[2] = { type=[[png]],name=[[11701_02]],x=512,y=0},[3] = { type=[[png]],name=[[11701_03]],x=1024,y=0},[4] = { type=[[png]],name=[[11701_04]],x=1536,y=0}},bg = { [1] = { type=[[jpg]],name=[[11701_bg_01]],x=0,y=250},[2] = { type=[[jpg]],name=[[11701_bg_02]],x=512,y=250},[3] = { type=[[jpg]],name=[[11701_bg_03]],x=1024,y=250},[4] = { type=[[jpg]],name=[[11701_bg_04]],x=1536,y=250},[5] = { type=[[png]],name=[[11701_bg_cloud]],x=0,y=300},[6] = { type=[[png]],name=[[11701_bg_moom]],x=1000,y=400}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11701    -- 缩略图ID
} 


-- 阴山老道_通用
_G.MapData[11702] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11702, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11701_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11701_qj_02]],x=1100,y=0},[3] = { type=[[gaf]],name=[[candle]],x=92,y=95}},move = { [1] = { x=50,w=1948,ty=250,by=10}},before = { },map = { [1] = { type=[[png]],name=[[11701_01]],x=0,y=0},[2] = { type=[[png]],name=[[11701_02]],x=512,y=0},[3] = { type=[[png]],name=[[11701_03]],x=1024,y=0},[4] = { type=[[png]],name=[[11701_04]],x=1536,y=0}},bg = { [1] = { type=[[jpg]],name=[[11701_bg_01]],x=0,y=250},[2] = { type=[[jpg]],name=[[11701_bg_02]],x=512,y=250},[3] = { type=[[jpg]],name=[[11701_bg_03]],x=1024,y=250},[4] = { type=[[jpg]],name=[[11701_bg_04]],x=1536,y=250},[5] = { type=[[png]],name=[[11701_bg_cloud]],x=0,y=300},[6] = { type=[[png]],name=[[11701_bg_moom]],x=1000,y=400}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11702    -- 缩略图ID
} 


-- 阴山老道_3K循环
_G.MapData[11801] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11801, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11701_qj_01]],x=2100,y=0},[2] = { type=[[png]],name=[[11701_qj_02]],x=3600,y=0},[3] = { type=[[gaf]],name=[[candle]],x=2192,y=95}},move = { [1] = { x=50,w=2972,ty=250,by=10}},before = { },map = { [1] = { type=[[png]],name=[[11701_01]],x=0,y=0},[2] = { type=[[png]],name=[[11701_02]],x=512,y=0},[3] = { type=[[png]],name=[[11701_03]],x=1024,y=0},[4] = { type=[[png]],name=[[11701_04]],x=1536,y=0},[5] = { type=[[png]],name=[[11701_01]],x=2048,y=0},[6] = { type=[[png]],name=[[11701_02]],x=2560,y=0}},bg = { [1] = { type=[[jpg]],name=[[11701_bg_01]],x=0,y=250},[2] = { type=[[jpg]],name=[[11701_bg_02]],x=512,y=250},[3] = { type=[[jpg]],name=[[11701_bg_03]],x=1024,y=250},[4] = { type=[[jpg]],name=[[11701_bg_04]],x=1536,y=250},[5] = { type=[[jpg]],name=[[11701_bg_01]],x=2048,y=250},[6] = { type=[[jpg]],name=[[11701_bg_02]],x=2560,y=250},[7] = { type=[[png]],name=[[11701_bg_cloud]],x=0,y=300},[8] = { type=[[png]],name=[[11701_bg_cloud]],x=900,y=300},[9] = { type=[[png]],name=[[11701_bg_moom]],x=1000,y=400}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=3072, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11801    -- 缩略图ID
} 


-- 18层地狱
_G.MapData[11901] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11901, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11901_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11901_qj_02]],x=1800,y=0}},move = { [1] = { x=50,w=1948,ty=250,by=10}},before = { [1] = { type=[[gaf]],name=[[fire1]],x=898,y=410},[2] = { type=[[gaf]],name=[[fire1]],x=1143,y=410},[3] = { type=[[gaf]],name=[[fire4]],x=1018,y=300}},map = { [1] = { type=[[png]],name=[[11901_01]],x=0,y=0},[2] = { type=[[png]],name=[[11901_02]],x=512,y=0},[3] = { type=[[png]],name=[[11901_03]],x=1024,y=0},[4] = { type=[[png]],name=[[11901_04]],x=1536,y=0}},bg = { [1] = { type=[[jpg]],name=[[11901_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11901_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11901_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11901_bg_04]],x=1536,y=0}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11901    -- 缩略图ID
} 


-- 阴山老道_4K循环
_G.MapData[11802] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11802, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11701_qj_01]],x=2100,y=0},[2] = { type=[[png]],name=[[11701_qj_02]],x=3600,y=0},[3] = { type=[[gaf]],name=[[candle]],x=2192,y=95}},move = { [1] = { x=50,w=3998,ty=250,by=10}},before = { },map = { [1] = { type=[[png]],name=[[11701_01]],x=0,y=0},[2] = { type=[[png]],name=[[11701_02]],x=512,y=0},[3] = { type=[[png]],name=[[11701_03]],x=1024,y=0},[4] = { type=[[png]],name=[[11701_04]],x=1536,y=0},[5] = { type=[[png]],name=[[11701_01]],x=2048,y=0},[6] = { type=[[png]],name=[[11701_02]],x=2560,y=0},[7] = { type=[[png]],name=[[11701_03]],x=3072,y=0},[8] = { type=[[png]],name=[[11701_04]],x=3584,y=0}},bg = { [1] = { type=[[jpg]],name=[[11701_bg_01]],x=0,y=250},[2] = { type=[[jpg]],name=[[11701_bg_02]],x=512,y=250},[3] = { type=[[jpg]],name=[[11701_bg_03]],x=1024,y=250},[4] = { type=[[jpg]],name=[[11701_bg_04]],x=1536,y=250},[5] = { type=[[jpg]],name=[[11701_bg_01]],x=2048,y=250},[6] = { type=[[jpg]],name=[[11701_bg_02]],x=2560,y=250},[7] = { type=[[jpg]],name=[[11701_bg_03]],x=3072,y=250},[8] = { type=[[jpg]],name=[[11701_bg_04]],x=3584,y=250},[9] = { type=[[png]],name=[[11701_bg_cloud]],x=0,y=300},[10] = { type=[[png]],name=[[11701_bg_cloud]],x=900,y=300},[11] = { type=[[png]],name=[[11701_bg_moom]],x=1000,y=400}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=4096, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11802    -- 缩略图ID
} 


-- 18层地狱_通用
_G.MapData[11902] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=11902, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11901_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11901_qj_02]],x=1800,y=0}},move = { [1] = { x=50,w=1948,ty=250,by=10}},before = { [1] = { type=[[gaf]],name=[[fire1]],x=898,y=410},[2] = { type=[[gaf]],name=[[fire1]],x=1143,y=410},[3] = { type=[[gaf]],name=[[fire4]],x=1018,y=300}},map = { [1] = { type=[[png]],name=[[11901_01]],x=0,y=0},[2] = { type=[[png]],name=[[11901_02]],x=512,y=0},[3] = { type=[[png]],name=[[11901_03]],x=1024,y=0},[4] = { type=[[png]],name=[[11901_04]],x=1536,y=0}},bg = { [1] = { type=[[jpg]],name=[[11901_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11901_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11901_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11901_bg_04]],x=1536,y=0}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 11902    -- 缩略图ID
} 


-- 18层地狱_3K循环
_G.MapData[12001] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12001, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11901_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11901_qj_02]],x=2820,y=0}},move = { [1] = { x=50,w=2972,ty=250,by=10}},before = { [1] = { type=[[gaf]],name=[[fire1]],x=1410,y=410},[2] = { type=[[gaf]],name=[[fire1]],x=1655,y=410},[3] = { type=[[gaf]],name=[[fire4]],x=1530,y=300}},map = { [1] = { type=[[png]],name=[[11901_04]],x=0,y=0},[2] = { type=[[png]],name=[[11901_01]],x=512,y=0},[3] = { type=[[png]],name=[[11901_02]],x=1024,y=0},[4] = { type=[[png]],name=[[11901_03]],x=1536,y=0},[5] = { type=[[png]],name=[[11901_04]],x=2048,y=0},[6] = { type=[[png]],name=[[11901_01]],x=2560,y=0}},bg = { [1] = { type=[[jpg]],name=[[11901_bg_04]],x=0,y=0},[2] = { type=[[jpg]],name=[[11901_bg_01]],x=512,y=0},[3] = { type=[[jpg]],name=[[11901_bg_02]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11901_bg_03]],x=1536,y=0},[5] = { type=[[jpg]],name=[[11901_bg_04]],x=2048,y=0},[6] = { type=[[jpg]],name=[[11901_bg_01]],x=2560,y=0}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=3072, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12001    -- 缩略图ID
} 


-- 18层地狱_4K循环
_G.MapData[12002] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12002, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[11901_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[11901_qj_02]],x=3900,y=0}},move = { [1] = { x=50,w=3998,ty=250,by=10}},before = { [1] = { type=[[gaf]],name=[[fire1]],x=898,y=410},[2] = { type=[[gaf]],name=[[fire1]],x=1143,y=410},[3] = { type=[[gaf]],name=[[fire4]],x=1018,y=300},[4] = { type=[[gaf]],name=[[fire1]],x=2946,y=410},[5] = { type=[[gaf]],name=[[fire1]],x=3191,y=410},[6] = { type=[[gaf]],name=[[fire4]],x=3066,y=300}},map = { [1] = { type=[[png]],name=[[11901_01]],x=0,y=0},[2] = { type=[[png]],name=[[11901_02]],x=512,y=0},[3] = { type=[[png]],name=[[11901_03]],x=1024,y=0},[4] = { type=[[png]],name=[[11901_04]],x=1536,y=0},[5] = { type=[[png]],name=[[11901_01]],x=2048,y=0},[6] = { type=[[png]],name=[[11901_02]],x=2560,y=0},[7] = { type=[[png]],name=[[11901_03]],x=3072,y=0},[8] = { type=[[png]],name=[[11901_04]],x=3584,y=0}},bg = { [1] = { type=[[jpg]],name=[[11901_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[11901_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[11901_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11901_bg_04]],x=1536,y=0},[5] = { type=[[jpg]],name=[[11901_bg_01]],x=2048,y=0},[6] = { type=[[jpg]],name=[[11901_bg_02]],x=2560,y=0},[7] = { type=[[jpg]],name=[[11901_bg_03]],x=3072,y=0},[8] = { type=[[jpg]],name=[[11901_bg_04]],x=3584,y=0}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=4096, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12002    -- 缩略图ID
} 


-- 19层炼狱
_G.MapData[12101] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12101, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12101_qj_01]],x=0,y=461},[2] = { type=[[png]],name=[[12101_qj_03]],x=0,y=0},[3] = { type=[[png]],name=[[12101_qj_02]],x=1210,y=396},[4] = { type=[[png]],name=[[12101_qj_04]],x=1548,y=0}},move = { [1] = { x=50,w=1948,ty=250,by=25}},before = { },map = { [1] = { type=[[png]],name=[[12101_01]],x=0,y=0},[2] = { type=[[png]],name=[[12101_02]],x=512,y=0},[3] = { type=[[png]],name=[[12101_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12101_04]],x=1536,y=0}},bg = { [1] = { type=[[jpg]],name=[[12101_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12101_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12101_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12101_bg_04]],x=1536,y=0}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12101    -- 缩略图ID
} 


-- 19层炼狱_通用
_G.MapData[12102] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12102, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12101_qj_01]],x=0,y=461},[2] = { type=[[png]],name=[[12101_qj_03]],x=0,y=0},[3] = { type=[[png]],name=[[12101_qj_02]],x=1210,y=396},[4] = { type=[[png]],name=[[12101_qj_04]],x=1548,y=0}},move = { [1] = { x=50,w=1948,ty=250,by=25}},before = { },map = { [1] = { type=[[png]],name=[[12101_01]],x=0,y=0},[2] = { type=[[png]],name=[[12101_02]],x=512,y=0},[3] = { type=[[png]],name=[[12101_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12101_04]],x=1536,y=0}},bg = { [1] = { type=[[jpg]],name=[[12101_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12101_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12101_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12101_bg_04]],x=1536,y=0}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12102    -- 缩略图ID
} 


-- 19层炼狱_3K循环
_G.MapData[12201] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12201, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12101_qj_01]],x=0,y=460},[2] = { type=[[png]],name=[[12101_qj_03]],x=0,y=0},[3] = { type=[[png]],name=[[12101_qj_03]],x=2046,y=0},[4] = { type=[[png]],name=[[12101_qj_04]],x=1548,y=0},[5] = { type=[[png]],name=[[12101_qj_01]],x=2050,y=460},[6] = { type=[[png]],name=[[12101_qj_02]],x=1230,y=396},[7] = { type=[[png]],name=[[12101_qj_04]],x=2572,y=0}},move = { [1] = { x=50,w=2972,ty=250,by=25}},before = { },map = { [1] = { type=[[png]],name=[[12101_01]],x=0,y=0},[2] = { type=[[png]],name=[[12101_02]],x=512,y=0},[3] = { type=[[png]],name=[[12101_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12101_04]],x=1536,y=0},[5] = { type=[[png]],name=[[12101_01]],x=2048,y=0},[6] = { type=[[png]],name=[[12101_02]],x=2560,y=0}},bg = { [1] = { type=[[jpg]],name=[[12101_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12101_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12101_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12101_bg_04]],x=1536,y=0},[5] = { type=[[jpg]],name=[[12101_bg_01]],x=2048,y=0},[6] = { type=[[jpg]],name=[[12101_bg_02]],x=2560,y=0}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=3072, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12201    -- 缩略图ID
} 


-- 19层炼狱_4K循环
_G.MapData[12202] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12202, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12101_qj_01]],x=0,y=460},[2] = { type=[[png]],name=[[12101_qj_03]],x=0,y=0},[3] = { type=[[png]],name=[[12101_qj_03]],x=2046,y=0},[4] = { type=[[png]],name=[[12101_qj_03]],x=1548,y=0},[5] = { type=[[png]],name=[[12101_qj_01]],x=2050,y=461},[6] = { type=[[png]],name=[[12101_qj_02]],x=1230,y=396},[7] = { type=[[png]],name=[[12101_qj_02]],x=3258,y=396},[8] = { type=[[png]],name=[[12101_qj_04]],x=3596,y=0}},move = { [1] = { x=50,w=3996,ty=250,by=25}},before = { },map = { [1] = { type=[[png]],name=[[12101_01]],x=0,y=0},[2] = { type=[[png]],name=[[12101_02]],x=512,y=0},[3] = { type=[[png]],name=[[12101_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12101_04]],x=1536,y=0},[5] = { type=[[png]],name=[[12101_01]],x=2048,y=0},[6] = { type=[[png]],name=[[12101_02]],x=2560,y=0},[7] = { type=[[png]],name=[[12101_03]],x=3072,y=0},[8] = { type=[[png]],name=[[12101_04]],x=3584,y=0}},bg = { [1] = { type=[[jpg]],name=[[12101_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12101_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12101_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12101_bg_04]],x=1536,y=0},[5] = { type=[[jpg]],name=[[12101_bg_01]],x=2048,y=0},[6] = { type=[[jpg]],name=[[12101_bg_02]],x=2560,y=0},[7] = { type=[[jpg]],name=[[12101_bg_03]],x=3072,y=0},[8] = { type=[[jpg]],name=[[12101_bg_04]],x=3584,y=0}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=4096, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12202    -- 缩略图ID
} 


-- 奈何桥
_G.MapData[12301] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12301, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12301_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[12301_qj_02]],x=512,y=0},[3] = { type=[[png]],name=[[12301_qj_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12301_qj_04]],x=1536,y=0}},move = { [1] = { x=50,w=1948,ty=250,by=20}},before = { },map = { [1] = { type=[[png]],name=[[12301_01]],x=0,y=0},[2] = { type=[[png]],name=[[12301_02]],x=512,y=0},[3] = { type=[[png]],name=[[12301_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12301_04]],x=1536,y=0}},bg = { [1] = { type=[[jpg]],name=[[12301_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12301_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12301_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12301_bg_04]],x=1536,y=0},[5] = { type=[[png]],name=[[12301_bf_01]],x=0,y=300},[6] = { type=[[png]],name=[[12301_bf_02]],x=1400,y=300}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12301    -- 缩略图ID
} 


-- 奈何桥_通用
_G.MapData[12302] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12302, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12301_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[12301_qj_02]],x=512,y=0},[3] = { type=[[png]],name=[[12301_qj_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12301_qj_04]],x=1536,y=0}},move = { [1] = { x=50,w=1948,ty=250,by=20}},before = { },map = { [1] = { type=[[png]],name=[[12301_01]],x=0,y=0},[2] = { type=[[png]],name=[[12301_02]],x=512,y=0},[3] = { type=[[png]],name=[[12301_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12301_04]],x=1536,y=0}},bg = { [1] = { type=[[jpg]],name=[[12301_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12301_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12301_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12301_bg_04]],x=1536,y=0},[5] = { type=[[png]],name=[[12301_bf_01]],x=0,y=300},[6] = { type=[[png]],name=[[12301_bf_02]],x=1400,y=300}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12302    -- 缩略图ID
} 


-- 奈何断桥
_G.MapData[12401] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12401, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12301_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[12301_qj_02b]],x=512,y=0},[3] = { type=[[png]],name=[[12301_qj_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12301_qj_04b]],x=1536,y=0}},move = { [1] = { x=50,w=1848,ty=250,by=20}},before = { [1] = { type=[[gaf]],name=[[smoke2]],x=800,y=300}},map = { [1] = { type=[[png]],name=[[12301_01]],x=0,y=0},[2] = { type=[[png]],name=[[12301_02]],x=512,y=0},[3] = { type=[[png]],name=[[12301_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12301_05]],x=1536,y=0}},bg = { [1] = { type=[[jpg]],name=[[12301_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12301_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12301_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12301_bg_04]],x=1536,y=0},[5] = { type=[[png]],name=[[12301_bf_01]],x=0,y=300}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12401    -- 缩略图ID
} 


-- 奈何断桥_通用
_G.MapData[12402] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12402, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12301_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[12301_qj_02b]],x=512,y=0},[3] = { type=[[png]],name=[[12301_qj_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12301_qj_04b]],x=1536,y=0}},move = { [1] = { x=50,w=1848,ty=250,by=20}},before = { [1] = { type=[[gaf]],name=[[smoke2]],x=800,y=300}},map = { [1] = { type=[[png]],name=[[12301_01]],x=0,y=0},[2] = { type=[[png]],name=[[12301_02]],x=512,y=0},[3] = { type=[[png]],name=[[12301_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12301_05]],x=1536,y=0}},bg = { [1] = { type=[[jpg]],name=[[12301_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12301_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12301_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12301_bg_04]],x=1536,y=0},[5] = { type=[[png]],name=[[12301_bf_01]],x=0,y=300}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12402    -- 缩略图ID
} 


-- 奈何桥_3K循环
_G.MapData[12501] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12501, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12301_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[12301_qj_02b]],x=512,y=0},[3] = { type=[[png]],name=[[12301_qj_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12301_qj_04b]],x=1536,y=0},[5] = { type=[[png]],name=[[12301_qj_01]],x=2048,y=0},[6] = { type=[[png]],name=[[12301_qj_02b]],x=2560,y=0}},move = { [1] = { x=150,w=2772,ty=250,by=20}},before = { [1] = { type=[[gaf]],name=[[smoke2]],x=800,y=300}},map = { [1] = { type=[[png]],name=[[12301_01]],x=0,y=0},[2] = { type=[[png]],name=[[12301_02]],x=512,y=0},[3] = { type=[[png]],name=[[12301_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12301_04]],x=1536,y=0},[5] = { type=[[png]],name=[[12301_01]],x=2048,y=0},[6] = { type=[[png]],name=[[12301_02]],x=2560,y=0}},bg = { [1] = { type=[[jpg]],name=[[12301_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12301_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12301_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12301_bg_04]],x=1536,y=0},[5] = { type=[[jpg]],name=[[12301_bg_01]],x=2048,y=0},[6] = { type=[[jpg]],name=[[12301_bg_02]],x=2560,y=0},[7] = { type=[[png]],name=[[12301_bf_01]],x=0,y=300},[8] = { type=[[png]],name=[[12301_bf_02]],x=2600,y=300}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=3072, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12501    -- 缩略图ID
} 


-- 奈何桥_4K循环
_G.MapData[12502] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12502, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12301_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[12301_qj_02b]],x=512,y=0},[3] = { type=[[png]],name=[[12301_qj_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12301_qj_04b]],x=1536,y=0},[5] = { type=[[png]],name=[[12301_qj_01]],x=2048,y=0},[6] = { type=[[png]],name=[[12301_qj_02b]],x=2560,y=0},[7] = { type=[[png]],name=[[12301_qj_03]],x=3072,y=0},[8] = { type=[[png]],name=[[12301_qj_04b]],x=3584,y=0}},move = { [1] = { x=50,w=3998,ty=260,by=10}},before = { },map = { [1] = { type=[[png]],name=[[12301_01]],x=0,y=0},[2] = { type=[[png]],name=[[12301_02]],x=512,y=0},[3] = { type=[[png]],name=[[12301_03]],x=1024,y=0},[4] = { type=[[png]],name=[[12301_04]],x=1536,y=0},[5] = { type=[[png]],name=[[12301_01]],x=2048,y=0},[6] = { type=[[png]],name=[[12301_02]],x=2560,y=0},[7] = { type=[[png]],name=[[12301_03]],x=3072,y=0},[8] = { type=[[png]],name=[[12301_04]],x=3584,y=0}},bg = { [1] = { type=[[jpg]],name=[[12301_bg_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12301_bg_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12301_bg_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12301_bg_04]],x=1536,y=0},[5] = { type=[[jpg]],name=[[12301_bg_01]],x=2048,y=0},[6] = { type=[[jpg]],name=[[12301_bg_02]],x=2560,y=0},[7] = { type=[[jpg]],name=[[12301_bg_03]],x=3072,y=0},[8] = { type=[[jpg]],name=[[12301_bg_04]],x=3584,y=0},[9] = { type=[[png]],name=[[12301_bf_01]],x=0,y=300},[10] = { type=[[png]],name=[[12301_bf_02]],x=3448,y=300}},bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=4098, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12502    -- 缩略图ID
} 


-- 苗疆战场
_G.MapData[12601] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12601, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12601_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[12601_qj_02]],x=1750,y=0},[3] = { type=[[png]],name=[[12601_qj_03]],x=500,y=0}},move = { [1] = { x=50,w=1950,ty=260,by=10}},before = { [1] = { type=[[gaf]],name=[[smoke3]],x=1230,y=350},[2] = { type=[[png]],name=[[12601_bf_01]],x=1596,y=455},[3] = { type=[[gaf]],name=[[dimple]],x=600,y=0},[4] = { type=[[spine]],name=12601,x=480,y=280}},map = { [1] = { type=[[jpg]],name=[[12601_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12601_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12601_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12601_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12601    -- 缩略图ID
} 


-- 苗疆战场_通用
_G.MapData[12602] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12602, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12601_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[12601_qj_02]],x=1750,y=0},[3] = { type=[[png]],name=[[12601_qj_03]],x=500,y=0}},move = { [1] = { x=50,w=1950,ty=260,by=10}},before = { [1] = { type=[[gaf]],name=[[smoke3]],x=1230,y=350},[2] = { type=[[png]],name=[[12601_bf_01]],x=1596,y=455},[3] = { type=[[gaf]],name=[[dimple]],x=600,y=0},[4] = { type=[[spine]],name=12601,x=480,y=280}},map = { [1] = { type=[[jpg]],name=[[12601_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12601_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12601_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12601_04]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12602    -- 缩略图ID
} 


-- 苗疆战场_3K循环
_G.MapData[12701] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12701, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12601_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[12601_qj_02]],x=1930,y=0},[3] = { type=[[png]],name=[[12601_qj_03]],x=500,y=0}},move = { [1] = { x=50,w=2972,ty=260,by=10}},before = { [1] = { type=[[gaf]],name=[[smoke3]],x=1230,y=350},[2] = { type=[[gaf]],name=[[smoke3]],x=3278,y=350},[3] = { type=[[png]],name=[[12601_bf_01]],x=1596,y=455},[4] = { type=[[gaf]],name=[[dimple]],x=600,y=0},[5] = { type=[[spine]],name=12601,x=1480,y=280}},map = { [1] = { type=[[jpg]],name=[[12601_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12601_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12601_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12601_04]],x=1536,y=0},[5] = { type=[[jpg]],name=[[12601_01]],x=2048,y=0},[6] = { type=[[jpg]],name=[[12601_02]],x=2560,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=3072, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12701    -- 缩略图ID
} 


-- 苗疆战场_4K循环
_G.MapData[12702] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12702, -- 地图素材id
			data = { topside = { [1] = { type=[[png]],name=[[12601_qj_01]],x=0,y=0},[2] = { type=[[png]],name=[[12601_qj_02]],x=1930,y=0},[3] = { type=[[png]],name=[[12601_qj_03]],x=500,y=0},[4] = { type=[[png]],name=[[12601_qj_02]],x=3150,y=0},[5] = { type=[[png]],name=[[12601_qj_03]],x=3500,y=0}},move = { [1] = { x=50,w=3996,ty=260,by=10}},before = { [1] = { type=[[gaf]],name=[[smoke3]],x=1230,y=350},[2] = { type=[[gaf]],name=[[smoke3]],x=3278,y=350},[3] = { type=[[png]],name=[[12601_bf_01]],x=1596,y=455},[4] = { type=[[gaf]],name=[[dimple]],x=600,y=0},[5] = { type=[[png]],name=[[12601_bf_01]],x=3646,y=455},[6] = { type=[[gaf]],name=[[dimple]],x=3550,y=100},[7] = { type=[[spine]],name=12601,x=2500,y=280}},map = { [1] = { type=[[jpg]],name=[[12601_01]],x=0,y=0},[2] = { type=[[jpg]],name=[[12601_02]],x=512,y=0},[3] = { type=[[jpg]],name=[[12601_03]],x=1024,y=0},[4] = { type=[[jpg]],name=[[12601_04]],x=1536,y=0},[5] = { type=[[jpg]],name=[[12601_01]],x=2048,y=0},[6] = { type=[[jpg]],name=[[12601_02]],x=2560,y=0},[7] = { type=[[jpg]],name=[[12601_03]],x=3072,y=0},[8] = { type=[[jpg]],name=[[12601_04]],x=3584,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=4098, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12702    -- 缩略图ID
} 


-- 地府(保卫)
_G.MapData[12801] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12801, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=710,ty=150,by=10},[2] = { x=760,w=0,ty=150,by=10},[3] = { x=760,w=2,ty=190,by=10},[4] = { x=762,w=0,ty=190,by=10},[5] = { x=762,w=1186,ty=150,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[11000_03]],x=0,y=0},[2] = { type=[[jpg]],name=[[11000_04]],x=512,y=0},[3] = { type=[[jpg]],name=[[11000_05]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11000_06]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12801    -- 缩略图ID
} 


-- 地府(保卫)_通用
_G.MapData[12802] = {
			mx= 0 , -- 限行
			jump_x= 0 , -- 地图移动x
			jump_y= 0 , -- 地图移动y
			speedRatio=0.6, --速度 
			speedMap=0, --速度（船/地平）
			yRatio=0, --y轴缩放
			type=1, -- 地图类型
			id=12802, -- 地图素材id
			data = { topside = { },move = { [1] = { x=50,w=710,ty=150,by=10},[2] = { x=760,w=0,ty=150,by=10},[3] = { x=760,w=2,ty=190,by=10},[4] = { x=762,w=0,ty=190,by=10},[5] = { x=762,w=1186,ty=150,by=10}},before = { },map = { [1] = { type=[[jpg]],name=[[11000_03]],x=0,y=0},[2] = { type=[[jpg]],name=[[11000_04]],x=512,y=0},[3] = { type=[[jpg]],name=[[11000_05]],x=1024,y=0},[4] = { type=[[jpg]],name=[[11000_06]],x=1536,y=0}},bg=nil,bg_translationSpeed=1,bg_upDownSpeed=1}, -- 地图数据
			excessBottom=0, -- 底部多余部份
			mapWidth=2047, -- 地图宽度
			lx=0, -- 左边区域
			heightWidth=640, -- 地图宽度
			pieceWidth=1, -- 地图块宽度
			small_id= 12802    -- 缩略图ID
} 

