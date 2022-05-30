Config = Config or {}
Config.city_data = {
	[1] = {
		id=1
	,res_id='centercity'
	,layer_sum=5
	,name='主城'
	,width=2160
	,height=1280
	,	building_list={--type1为建筑2为特效3为npc4为图片
			{bid=4 ,name='天空之塔' ,res='scene_13' ,dun_id=0 ,x=1812 ,y=288 ,name_x=166 ,name_y=80 ,dir=0 ,type=1 ,layer=2,orderZ = 10,redPoint_x = 242 ,redPoint_y = 100},
			{bid=5 ,name='捕捉' ,res='scene_4' ,dun_id=0 ,x=920 ,y=806 ,name_x=100 ,name_y=10 ,dir=0 ,type=1 ,layer=3,orderZ = 10,redPoint_x = 156 ,redPoint_y = 26},
			{bid=3 ,name='竞技场' ,res='scene_11' ,dun_id=0 ,x=989 ,y=548 ,name_x=138 ,name_y=12 ,dir=0 ,type=1 ,layer=2,orderZ = 10,redPoint_x = 192 ,redPoint_y = 28},
			{bid=7 ,name='宝可研究所' ,res='scene_6' ,dun_id=10010 ,x=424 ,y=260 ,name_x=200 ,name_y=16 ,dir=0 ,type=1 ,layer=2,orderZ = 10,redPoint_x = 316 ,redPoint_y = 46},
			{bid=8 ,name='狩猎地带' ,res='scene_14' ,dun_id=0 ,x=1440 ,y=608 ,name_x=100 ,name_y=10 ,dir=0 ,type=1 ,layer=3,orderZ = 10,redPoint_x = 0 ,redPoint_y = 0},
			{bid=10 ,name='超市' ,res='scene_3' ,dun_id=0 ,x=838 ,y=198 ,name_x=168 ,name_y=20 ,dir=0 ,type=1 ,layer=2,orderZ = 10,redPoint_x = 220 ,redPoint_y = 34},
			{bid=1 ,name='商城' ,res='scene_1' ,dun_id=0 ,x=1230 ,y=290 ,name_x=126 ,name_y=80 ,dir=0 ,type=1 ,layer=2,orderZ = 10,redPoint_x = 0 ,redPoint_y = 0},
			{bid=2 ,name='锻造屋' ,res='scene_10' ,dun_id=0 ,x=511 ,y=648 ,name_x=100 ,name_y=38 ,dir=0 ,type=1 ,layer=2,orderZ = 10,redPoint_x = 0 ,redPoint_y = 0},
			{bid=11 ,name='考验之地' ,res='scene_7' ,dun_id=10010 ,x=1268 ,y=826 ,name_x=108 ,name_y=10 ,dir=0 ,type=1 ,layer=3,orderZ = 10,redPoint_x = 172 ,redPoint_y = 25},
			{bid=12 ,name='跨服战场' ,res='scene_15' ,dun_id=10010 ,x=80 ,y=460 ,name_x=170 ,name_y=80 ,dir=0 ,type=1 ,layer=2,orderZ = 10,redPoint_x = 258 ,redPoint_y = 105},
			{bid=15 ,name='原力水晶' ,res='scene_12' ,dun_id=10010 ,x=1498 ,y=198 ,name_x=116 ,name_y=-8 ,dir=0 ,type=1 ,layer=2,orderZ = 10,redPoint_x = 202 ,redPoint_y = 22},
			{bid=16 ,name='幸运探宝' ,res='scene_9' ,dun_id=0 ,x=488 ,y=844 ,name_x=106 ,name_y=20 ,dir=0 ,type=1 ,layer=3,orderZ = 10,redPoint_x = 0 ,redPoint_y = 0},
			{bid=202 ,name='主城云白天图片' ,res='scene_16' ,dun_id=0 ,x=1480 ,y=800 ,name_x=100 ,name_y=100 ,dir=0 ,type=4 ,layer=3,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			{bid=203 ,name='竞技场树白天图片1' ,res='scene_18' ,dun_id=0 ,x=1000 ,y=632 ,name_x=100 ,name_y=100 ,dir=0 ,type=4 ,layer=2,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=204 ,name='竞技场树白天图片2' ,res='scene_19' ,dun_id=0 ,x=1260 ,y=602 ,name_x=100 ,name_y=100 ,dir=0 ,type=4 ,layer=2,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=205 ,name='锅炉白天图片' ,res='scene_2' ,dun_id=0 ,x=168 ,y=168 ,name_x=100 ,name_y=100 ,dir=0 ,type=4 ,layer=2,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},

			--{bid=14 ,name='宝可梦乐园' ,res='scene_4' ,dun_id=0 ,x=140 ,y=510 ,name_x=100 ,name_y=100 ,dir=0 ,type=1,layer=2,orderZ = 10,redPoint_x = 0 ,redPoint_y = 0},
			--{bid=201 ,name='礼物箱图片' ,res='scene_3' ,dun_id=0 ,x=728 ,y=142 ,name_x=100 ,name_y=100 ,dir=0 ,type=4 ,layer=2,orderZ = 10,redPoint_x = 0 ,redPoint_y = 0},
			--{bid=206 ,name='宝可梦乐园白天图片' ,res='scene_5' ,dun_id=0 ,x=168 ,y=228 ,name_x=100 ,name_y=100 ,dir=0 ,type=4 ,layer=2,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},

			--{bid=110 ,name='竞技场特效' ,res='dc_jingjichang' ,dun_id=0 ,x=1080 ,y=640 ,name_x=106 ,name_y=20 ,dir=0 ,type=2 ,layer=2,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			--{bid=111 ,name='超市特效' ,res='dc_chaoshi' ,dun_id=0 ,x=962 ,y=314 ,name_x=106 ,name_y=20 ,dir=0 ,type=2 ,layer=2,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			--{bid=112 ,name='乐园特效' ,res='dc_leyuan' ,dun_id=0 ,x=260 ,y=45 ,name_x=106 ,name_y=20 ,dir=0 ,type=2 ,layer=2,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			--{bid=104 ,name='商城特效' ,res='dc_shangcheng' ,dun_id=0 ,x=1298 ,y=379 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=2,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			--{bid=117 ,name='宝可研究所特效' ,res='dc_yanjiusuo' ,dun_id=0 ,x=577 ,y=400 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=2 ,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},

			{bid=101 ,name='锻造屋特效' ,res='dc_duanzaowu' ,dun_id=0 ,x=544 ,y=683 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=2,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=102 ,name='锅炉特效' ,res='dc_guoluhuo' ,dun_id=0 ,x=228 ,y=158 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=2,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=103 ,name='跨服战场特效' ,res='kaufuzhanchang_zjm' ,dun_id=0 ,x=206 ,y=610 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=2,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=104 ,name='原力水晶特效' ,res='dc_molishuijin' ,dun_id=0 ,x=1570 ,y=231 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=2,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=105 ,name='幸运探宝特效1' ,res='dc_xinyuntanbao' ,dun_id=0 ,x=585 ,y=873 ,name_x=106 ,name_y=20 ,dir=0 ,type=2 ,layer=3,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=106 ,name='幸运探宝特效2' ,res='dc_xinyuntanbao' ,dun_id=0 ,x=667 ,y=817 ,name_x=106 ,name_y=20 ,dir=0 ,type=2 ,layer=3,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=107 ,name='捕捉特效' ,res='dc_buzhuo' ,dun_id=0 ,x=960 ,y=768 ,name_x=106 ,name_y=20 ,dir=0 ,type=2 ,layer=3,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=108 ,name='考验之地特效' ,res='dc_kaoyanzhidi' ,dun_id=0 ,x=1328 ,y=868 ,name_x=106 ,name_y=20 ,dir=0 ,type=2 ,layer=3,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=109 ,name='狩猎捕捉特效' ,res='dc_shouliebuzhuo' ,dun_id=0 ,x=1478 ,y=616 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=3 ,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			
			{bid=110 ,name='鸟风筝白天' ,res='E54509' ,dun_id=1 ,x=253 ,y=139 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=3 ,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},			
			
			{bid=111 ,name='灯萤火虫夜' ,res='E54533' ,dun_id=2 ,x=377 ,y=566 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=2 ,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=112 ,name='灯萤火虫夜' ,res='E54533' ,dun_id=2 ,x=843 ,y=388 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=2 ,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=113 ,name='灯萤火虫夜' ,res='E54533' ,dun_id=2 ,x=1288 ,y=655 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=2 ,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=114 ,name='灯萤火虫夜' ,res='E54533' ,dun_id=2 ,x=1720 ,y=360 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=2 ,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=115 ,name='星光夜晚' ,res='E54530' ,dun_id=2 ,x=873 ,y=610 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=3 ,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=116 ,name='星光夜晚' ,res='E54530' ,dun_id=2 ,x=273 ,y=610 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=3 ,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			{bid=117 ,name='星光夜晚' ,res='E54530' ,dun_id=2 ,x=1473 ,y=610 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=3 ,orderZ = 11,redPoint_x = 0 ,redPoint_y = 0},
			
			--{bid=302 ,name='鼻涕熊' ,res='dc_bitixiong' ,dun_id=0 ,x=1488 ,y=520 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=2 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			--{bid=309 ,name='喵喵' ,res='dc_miaomiao' ,dun_id=0 ,x=988 ,y=550 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=2 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			--{bid=311 ,name='球球海狮' ,res='dc_qiuqiuhaishi' ,dun_id=0 ,x=1548 ,y=758 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=3 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},

			{bid=301 ,name='小船白天' ,res='chuan' ,dun_id=1 ,x=1102 ,y=728 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=3 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			{bid=302 ,name='泡泡木木枭白天' ,res='dc_mumuxiao' ,dun_id=1 ,x=868 ,y=418 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=2 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			{bid=303 ,name='泡泡皮卡丘白天' ,res='dc_pikaqiu' ,dun_id=1 ,x=838 ,y=778 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=3 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			{bid=304 ,name='可达鸭白天' ,res='dc_kedaya' ,dun_id=1 ,x=1450 ,y=520 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=2 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			{bid=305 ,name='负电宝宝白天' ,res='dc_fudianbaobao' ,dun_id=1 ,x=388 ,y=98 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=2 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			{bid=306 ,name='正电宝宝白天' ,res='dc_zhengdianbaobao' ,dun_id=1 ,x=308 ,y=188 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=2 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			{bid=307 ,name='呆呆熊白天' ,res='dc_daidaixiong' ,dun_id=1 ,x=1250 ,y=132 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=2 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			{bid=308 ,name='蝴蝶白天' ,res='E54557' ,dun_id=1 ,x=1150 ,y=298 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=2 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			{bid=309 ,name='蝴蝶白天2' ,res='E54558' ,dun_id=1 ,x=1388 ,y=548 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=2 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			
			{bid=310 ,name='呆呆熊夜' ,res='dc_daidaixiong' ,dun_id=2 ,x=508 ,y=128 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=2 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			{bid=311 ,name='泡泡木木枭夜' ,res='dc_mumuxiao' ,dun_id=2 ,x=1568 ,y=412 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=2 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			{bid=312 ,name='可达鸭夜' ,res='dc_kedaya' ,dun_id=2 ,x=748 ,y=660 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=2 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			{bid=313 ,name='泡泡皮卡丘' ,res='dc_pikaqiu' ,dun_id=2 ,x=1120 ,y=820 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=3 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},
			{bid=314 ,name='泡泡帕奇利兹夜' ,res='dc_paqilizi' ,dun_id=2 ,x=268 ,y=208 ,name_x=100 ,name_y=100 ,dir=0 ,type=3 ,layer=2 ,orderZ = 9,redPoint_x = 0 ,redPoint_y = 0},

		}
	},
	[2] = {
		id=2
	,res_id='centercity_2'
	,layer_sum=1
	,name='主城_2'
	,width=720
	,height=1280
	,building_list={
			{bid=1 ,name='商城' ,res='1' ,dun_id=10010 ,x=403 ,y=582 ,name_x=100 ,name_y=100 ,dir=0 ,type=1 ,layer=1},
			{bid=2 ,name='铁匠铺' ,res='2' ,dun_id=10010 ,x=97 ,y=708 ,name_x=100 ,name_y=100 ,dir=0 ,type=1 ,layer=1},
			{bid=3 ,name='竞技场' ,res='3' ,dun_id=10010 ,x=608 ,y=517 ,name_x=100 ,name_y=100 ,dir=0 ,type=1 ,layer=1},
			{bid=4 ,name='试练塔' ,res='4' ,dun_id=10010 ,x=511 ,y=886 ,name_x=100 ,name_y=100 ,dir=0 ,type=1 ,layer=1},
			{bid=5 ,name='召唤' ,res='5' ,dun_id=10010 ,x=317 ,y=449 ,name_x=100 ,name_y=100 ,dir=0 ,type=1 ,layer=1},
			{bid=6 ,name='融合祭坛' ,res='6' ,dun_id=10010 ,x=176 ,y=850 ,name_x=100 ,name_y=100 ,dir=0 ,type=1 ,layer=1},
			{bid=7 ,name='祭祀小屋' ,res='7' ,dun_id=10010 ,x=679 ,y=803 ,name_x=100 ,name_y=100 ,dir=0 ,type=1 ,layer=1},
			{bid=8 ,name='先知圣殿' ,res='8' ,dun_id=10010 ,x=418 ,y=733 ,name_x=100 ,name_y=100 ,dir=0 ,type=1 ,layer=1},
			{bid=9 ,name='图书馆' ,res='9' ,dun_id=10010 ,x=271 ,y=705 ,name_x=100 ,name_y=100 ,dir=0 ,type=1 ,layer=1},
			{bid=10 ,name='杂货店' ,res='10' ,dun_id=10010 ,x=124 ,y=429 ,name_x=100 ,name_y=100 ,dir=0 ,type=1 ,layer=1},
		}
	},
	[3] = {
		id=3
	,res_id='business'
	,layer_sum=3
	,name='商业街'
	,width=1080
	,height=1106
	,building_list={
			{bid=1 ,name='积分商店' ,res='1' ,dun_id=0 ,x=322 ,y=392 ,name_x=60 ,name_y=-80 ,dir=0 ,type=1 ,layer=1},
			{bid=2 ,name='精灵商店' ,res='2' ,dun_id=0 ,x=298 ,y=634 ,name_x=72 ,name_y=-75 ,dir=0 ,type=1 ,layer=1},
			{bid=3 ,name='礼包商店' ,res='3' ,dun_id=0 ,x=646 ,y=734 ,name_x=-15 ,name_y=-140 ,dir=0 ,type=1 ,layer=1},
			{bid=4 ,name='皮肤商店' ,res='4' ,dun_id=0 ,x=404 ,y=796 ,name_x=50 ,name_y=-40 ,dir=0 ,type=1 ,layer=1},
			{bid=5 ,name='圣羽商店' ,res='5' ,dun_id=0 ,x=771 ,y=1066 ,name_x=60 ,name_y=-105 ,dir=0 ,type=1 ,layer=2},
			{bid=6 ,name='道具商城' ,res='6' ,dun_id=0 ,x=751 ,y=385 ,name_x=10 ,name_y=-100 ,dir=0 ,type=1 ,layer=1},
			{bid=20 ,name='飞艇特效' ,res='E27303' ,dun_id=0 ,x=625 ,y=760 ,name_x=100 ,name_y=100 ,dir=0 ,type=2 ,layer=1},
		}
	},
}