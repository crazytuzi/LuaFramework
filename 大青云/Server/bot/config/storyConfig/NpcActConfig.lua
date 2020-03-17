﻿--[[
	NPC动作脚本
	类型：acttype = 动作 1 位移 2
	
	npc=			npc表id
	gid=			npc唯一id
	actId =			NPC动作id
	bActLoop = 		动作是否循环
	isDelete = 		删除
	playerActId=	主角动作id  ['mainPlayer1001'] = {playerActId = 1,bActLoop = false,offsetPos={0,0,20},offsetTime=1000}
	roleEffect =    人物特效
	talk = 冒泡 TalkStringConfig的id
	movoToDir = 朝向
	movoToPos = 坐标点id
	jiguanId 机关Id (主角的动作脚本里)
	jiguanSan 机关动作 (主角的动作脚本里)
	AddSpeedUpEffect = true 添加加速效果
    DelSpeedUpEffect = true 删除加速效果
	loadAllLocalNpc = true 显示所有npc
	delay = 500 延时
	appSpeed = 1 正常
    appSpeed = 0.5 变慢
	needHide = true 动作完成后隐藏
	RemoveWing = true 删除翅膀
	AddCollection = 2000(时间)
    RemoveCollection = 1
    AddCollectionStr = 文字
	AddBinghun = 添加兵魂
	DeleteBinghun = 删除兵魂
	
	位移
	offsetPos = 			位移{0,0,20}
	offsetTime = 			位移时间
	offsetActStart = 		位移前动作
	offsetActStartLoop = 	位移前动作循环
	offsetActEnd = 			位移后动作，没有就是待机
	offsetActEndLoop = 		位移后动作循环
	offsetRoleEffectStart = 位移前人物特效
	offsetSceneEffectEnd = 	位移后场景特效
	offsetSceneEffectPos =  场景特效坐标
	dir	= 位移后朝向

	
--]]
_G.NpcActConfig = {
	['nj1001'] = {{acttype =2,npc=20300001,gid=3,offsetPos ={20,0,0},offsetTime =3500}},
	['nj1002'] = {{acttype =2,npc=20300005,gid=8,offsetPos ={0,0,-50},offsetTime =3500,offsetActStart ='trans',offsetActStartLoop =false,offsetRoleEffectStart ='hlhf_zhaohuan.pfx'}},
	['nj1003'] = {{acttype =2,npc=20300004,gid=9,offsetPos ={0,30,0},offsetTime =3000,offsetActStart ='walk',offsetActStartLoop =true}},
	['nj1004'] = {{acttype =1,npc=20300004,gid=9,actId ='stun',bActLoop = false}},
	['nj1005'] = {{acttype =1,npc=20300010,gid=4,isDelete =20300010}},
	['nj1006'] = {{acttype =1,npc=20300002,gid=5,actId ='hurt',bActLoop = false},{acttype =1,npc=20300001,gid=3,isDelete =20300001},{acttype =1,npc=20300009,gid=20,isDelete =20300009}},
	['nj1007'] = {{acttype =1,npc=20300008,gid=6,isDelete =20300008}},
	['nj1008'] = {{acttype =1,npc=20300001,gid=3,isDelete =20300001}},
	['nj1009'] = {{acttype =1,npc=20300007,gid=19,actId = 'leisure',bActLoop = false}},
	['nj1010'] = {{acttype =1,npc=20300002,gid=5,isDelete =20300002}},
	['nj1011'] = {{acttype =2,npc=20300012,gid=21,offsetPos ={-10,-10,0},offsetTime =4000,offsetActStart ='hurt',offsetActStartLoop =false},{acttype =1,npc=20300011,gid=1,actId = 'born',bActLoop = true}},
	['nj1012'] = {{acttype =2,npc=20300020,gid=25,offsetPos ={0,0,0},offsetTime =0,offsetActStart ='trans',offsetActStartLoop =false}},
	['nj1013'] = {{acttype =2,npc=20300021,gid=26,offsetPos ={0,0,0},offsetTime =0,offsetActStart ='trans',offsetActStartLoop =false}},
	['nj1014'] = {{acttype =2,npc=20300022,gid=27,offsetPos ={0,0,0},offsetTime =0,offsetActStart ='trans',offsetActStartLoop =false}},
	['nj1015'] = {{acttype =2,npc=20300023,gid=28,offsetPos ={0,0,0},offsetTime =0,offsetActStart ='trans',offsetActStartLoop =false}},
	['nj1016'] = {{acttype=2,npc=20300006,gid=7,offsetPos={0,-13,115},offsetTime=100,offsetActStart ='move',offsetActStartLoop =false,offsetActEnd ='move',offsetActEndLoop =false}},
	['nj1017'] = {{acttype=1,npc=20300006,gid=7,actId ='fly',roleEffect ='blhf_xiaoaoe.pfx'}},
	['nj1018'] = {{acttype =1,npc=20300020,gid=25,isDelete =20300020}},
	['nj1019'] = {{acttype =1,npc=20300021,gid=26,isDelete =20300021}},
	['nj1020'] = {{acttype =1,npc=20300022,gid=27,isDelete =20300022}},
	['nj1021'] = {{acttype =1,npc=20300023,gid=28,isDelete =20300023}},
	['nj1022'] = {{acttype =1,npc=20300018,gid=23,actId ='leisure',bActLoop = false}},
	['nj1023'] = {{acttype =1,npc=20300019,gid=24,actId ='fly',bActLoop = true}},
	['nj1024'] = {{acttype =1,npc=20300010,gid=32,actId ='born',bActLoop = false}},
	['nj1025'] = {{acttype =1,npc=20300010,gid=32,isDelete =20300010}},
	['nj1026'] = {{acttype =1,npc=20300033,gid=35}},
	['nj1027'] = {{acttype =1,npc=20300027,gid=34,actId ='trans',bActLoop = false},{acttype =1,npc=20300033,gid=35,actId ='trans',bActLoop = false}},
	['nj1028'] = {{acttype =1,npc=20300033,gid=35}},
	['nj1029'] = {{acttype =1,npc=20300034,gid=39,actId ='dead',bActLoop = false}},
	['nj1030'] = {{acttype =1,npc=20300037,gid=41,actId ='born',bActLoop = true}},
	['nj1031'] = {{acttype =1,npc=20300037,gid=41,actId ='atk',bActLoop = false}},
	['nj1032'] = {{acttype =1,npc=20300041,gid=45,talk=55}},
	['nj1033'] = {{acttype =1,npc=20300041,gid=46,talk=56,movoToDir =5.64,actId ='leisure',bActLoop = false}},
	['nj1034'] = {{acttype =1,npc=20300037,gid=41,actId ='dead',bActLoop = false}},
	['nj1035'] = {{acttype =1,npc=20100007,actId ='trans',bActLoop = false}},
	['nj1036'] = {{acttype =1,npc=20300050,gid=52,actId ='deadfly',bActLoop = false},
	              {acttype =1,npc=20300050,gid=53,actId ='deadfly',bActLoop = false},
				  {acttype =1,npc=20300050,gid=54,actId ='deadfly',bActLoop = false},
				  {acttype =1,npc=20300050,gid=55,actId ='deadfly',bActLoop = false},
				  {acttype =1,npc=20300051,gid=56,actId ='deadfly',bActLoop = false},
				  {acttype =1,npc=20300051,gid=57,actId ='deadfly',bActLoop = false},
				  {acttype =1,npc=20300051,gid=58,actId ='deadfly',bActLoop = false},
				  {acttype =1,npc=20300051,gid=59,actId ='deadfly',bActLoop = false}},
	['nj1037'] = {{acttype =1,npc=20300049,gid=60,actId ='trans',bActLoop = false}},
	['nj1038'] = {{acttype =1,npc=20300050,gid=52,isDelete =20300050},
	              {acttype =1,npc=20300050,gid=53,isDelete =20300050},
				  {acttype =1,npc=20300050,gid=54,isDelete =20300050},
				  {acttype =1,npc=20300050,gid=55,isDelete =20300050},
				  {acttype =1,npc=20300051,gid=56,isDelete =20300051},
				  {acttype =1,npc=20300051,gid=57,isDelete =20300051},
				  {acttype =1,npc=20300051,gid=58,isDelete =20300051},
				  {acttype =1,npc=20300051,gid=59,isDelete =20300051}},
    ['nj1039'] = {{acttype =1,npc=20300099,gid=130,isDelete =20300099}},
    ['nj1040'] = {{acttype =1,npc=20300100,gid=131,isDelete =20300100}},
    ['nj1041'] = {{acttype =1,npc=20300113,gid=135,actId = 'dialog',bActLoop = false}},
    ['nj1042'] = {{acttype =1,npc=20300113,gid=135,actId = 'trans',bActLoop = false}},
    ['nj1043'] = {{acttype =1,npc=20300114,gid=138,actId = 'dialog',bActLoop = false}},
    ['nj1044'] = {{acttype =1,npc=20300114,gid=138,actId = 'trans',bActLoop = false}},
    ['nj1045'] = {{acttype =1,npc=20300115,gid=145,actId = 'dialog',bActLoop = false}},
    ['nj1046'] = {{acttype =1,npc=20300115,gid=145,actId = 'trans',bActLoop = false}},
    ['nj1047'] = {{acttype =1,npc=20300117,gid=147,actId = 'dialog',bActLoop = false}},
    ['nj1048'] = {{acttype =1,npc=20300117,gid=147,actId = 'trans',bActLoop = false}},
    ['nj1049'] = {{acttype =1,npc=20300118,gid=148,actId = 'dialog',bActLoop = false}},
    ['nj1050'] = {{acttype =1,npc=20300118,gid=148,actId = 'trans',bActLoop = false}},
    ['nj1051'] = {{acttype =1,npc=20300119,gid=149,actId = 'dialog',bActLoop = false}},
    ['nj1052'] = {{acttype =1,npc=20300119,gid=149,actId = 'trans',bActLoop = false}},
    ['nj1053'] = {{acttype =1,npc=20300116,gid=146,actId = 'dialog',bActLoop = false}},
    ['nj1054'] = {{acttype =1,npc=20300116,gid=146,actId = 'trans',bActLoop = false}},
    ['nj1055'] = {{acttype =1,npc=20300120,gid=150,actId = 'dialog',bActLoop = false}},
    ['nj1056'] = {{acttype =1,npc=20300120,gid=150,actId = 'trans',bActLoop = false}},
	['mainPlayer1001'] = {playerActId=10,bActLoop=false,movoToDir =4.56,movoToPos =3001},
	['mainPlayer1002'] = {playerActId=11,bActLoop=false,movoToDir =5.30,movoToPos =3001},
	['mainPlayer1003'] = {playerActId=12,bActLoop=false,movoToDir =4.60,movoToPos =3001},
	['mainPlayer1004'] = {playerActId=13,bActLoop=false,movoToDir =2.60,movoToPos =3002},
	['mainPlayer1005'] = {playerActId=12,bActLoop=false,movoToDir =2.60,movoToPos =3002},
	['mainPlayer1006'] = {playerActId=14,bActLoop=false,movoToDir =2.67,movoToPos =3003},
	['mainPlayer1007'] = {playerActId=15,bActLoop=false,movoToDir =1.37,movoToPos =3004},
	['mainPlayer1008'] = {movoToDir =3.11,mountID={60100001,60200001,60300001,60400001}},
	['mainPlayer10081'] = {acttype=1,leisure = true,movoToDir =3.11},
	['mainPlayer1009'] = {movoToDir =4.64,movoToPos =3007},
	['mainPlayer1010'] = {acttype=2,playerActId=16,bActLoop=true,movoToDir =4.64,offsetPos ={-70,0,0},offsetTime =333},
	['mainPlayer1011'] = {acttype=2,playerActId=17,bActLoop=true,movoToDir =4.64,offsetPos ={-100,0,30},offsetTime =555},
	['mainPlayer1012'] = {acttype=2,playerActId=18,bActLoop=true,movoToDir =4.64,offsetPos ={-50,0,0},offsetTime =2400},
	['mainPlayer1018'] = {acttype=2,playerActId=24,bActLoop=false,movoToDir =4.64,offsetPos ={-50,0,0},offsetTime =1000,AddWing = true},
	['mainPlayer1013'] = {acttype=2,playerActId=19,bActLoop=true,movoToDir =4.64,offsetPos ={-50,8,-175},offsetTime =500,AddSpeedUpEffect = true},
	['mainPlayer1014'] = {acttype=2,playerActId=20,bActLoop=true,movoToDir =4.64,offsetPos ={-185,0,0},offsetTime =500,AddSpeedUpEffect = true},
	['mainPlayer1015'] = {acttype=2,playerActId=21,bActLoop=true,movoToDir =4.64,offsetPos ={-582,85,390},offsetTime =1600,AddSpeedUpEffect = true},
	['mainPlayer1016'] = {acttype=2,playerActId=22,bActLoop=true,movoToDir =0,offsetPos ={0,0,-160},offsetTime =544,DelSpeedUpEffect = true},
	['mainPlayer1017'] = {acttype=2,playerActId=23,bActLoop=false,movoToDir =0,offsetPos ={0,0,0},offsetTime =2333,RemoveWing = true},
	['mainPlayer1019'] = {acttype=2,playerActId=25,bActLoop=true,movoToDir =4.64,offsetPos ={-30,-10,-50},offsetTime =555},
	['mainPlayer1020'] = {acttype=2,playerActId=26,bActLoop=true,movoToDir =4.64,offsetPos ={-200,0,120},offsetTime =555},
	['mainPlayer1021'] = {movoToDir =1.52,movoToPos =3008},
	['mainPlayer1022'] = {acttype=2,playerActId=27,bActLoop=true,movoToDir =1.62,offsetPos ={80,0,0},offsetTime =666},
	['mainPlayer1023'] = {acttype=2,playerActId=28,bActLoop=true,movoToDir =1.62,offsetPos ={80,-18,80},offsetTime =600},
	['mainPlayer1024'] = {acttype=2,playerActId=29,bActLoop=true,movoToDir =1.62,offsetPos ={50,0,130},offsetTime =900},
	['mainPlayer1025'] = {acttype=2,playerActId=30,bActLoop=true,movoToDir =1.62,offsetPos ={217,0,-420},offsetTime =555,AddSpeedUpEffect = true},
	['mainPlayer1026'] = {acttype=2,playerActId=31,bActLoop=false,movoToDir =1.62,offsetPos ={0,0,0},offsetTime =2333,DelSpeedUpEffect = true},
	['mainPlayer1027'] = {movoToDir =2.51,movoToPos =3010},
	['mainPlayer1028'] = {acttype=1,playerActId=32,movoToDir =1.51,bActLoop=false,appSpeed = 0.6},
	['mainPlayer1029'] = {appSpeed = 1},
	['mainPlayer1030'] = {appSpeed = 1},
	['mainPlayer1031'] = {acttype=2,offsetPos ={0,0,120},offsetTime =100,dir =1.76},
	['mainPlayer1032'] = {{loginPlayer =1,movoToDir =1.29,movoToPos =3011},
	                      {loginPlayer =2,movoToDir =1.29,movoToPos =3012},
						  {loginPlayer =3,movoToDir =1.29,movoToPos =3013},
						  {loginPlayer =4,movoToDir =1.29,movoToPos =3014}},
	['mainPlayer1033'] = {{loginPlayer =2,acttype=2,playerActId=36,bActLoop=true,movoToDir =1.29,offsetPos ={190,0,0},offsetTime =2500,delay = 200},
	                      {loginPlayer =1,acttype=2,playerActId=36,bActLoop=true,movoToDir =1.29,offsetPos ={190,0,0},offsetTime =2500,delay = 200},
						  {loginPlayer =3,acttype=2,playerActId=36,bActLoop=true,movoToDir =1.29,offsetPos ={190,0,0},offsetTime =2500,delay = 200},
						  {loginPlayer =4,acttype=2,playerActId=36,bActLoop=true,movoToDir =1.29,offsetPos ={190,0,0},offsetTime =2500,delay = 200}},
	['mainPlayer1034'] = {{loginPlayer =2,acttype=2,playerActId=37,bActLoop=false,movoToDir =1.29,offsetPos ={0,0,0},offsetTime =466,delay = 200,needHide = true},
	                      {loginPlayer =1,acttype=2,playerActId=37,bActLoop=false,movoToDir =1.29,offsetPos ={0,5,0},offsetTime =466,delay = 200,needHide = true},
						  {loginPlayer =3,acttype=2,playerActId=37,bActLoop=false,movoToDir =1.29,offsetPos ={0,-5,0},offsetTime =466,delay = 200,needHide = true},
						  {loginPlayer =4,acttype=2,playerActId=37,bActLoop=false,movoToDir =1.29,offsetPos ={0,-10,0},offsetTime =466,delay = 200,needHide = true}},
	['mainPlayer1035'] = {{loginPlayer =1,acttype=2,playerActId=38,bActLoop=false,movoToDir =1.59,offsetPos ={0,0,0},offsetTime =2100,needIdle = true}},
	['mainPlayer1036'] = {{loginPlayer =2,acttype=2,playerActId=38,bActLoop=false,movoToDir =1.29,offsetPos ={0,0,0},offsetTime =2100,needIdle = true}},
	['mainPlayer1037'] = {{loginPlayer =3,acttype=2,playerActId=38,bActLoop=false,movoToDir =1.09,offsetPos ={0,0,0},offsetTime =2100,needIdle = true}},
	['mainPlayer1038'] = {{loginPlayer =4,acttype=2,playerActId=38,bActLoop=false,movoToDir =0.69,offsetPos ={0,0,0},offsetTime =2100,needIdle = true}},
	['mainPlayer1039'] = {{loginPlayer =1,acttype=2,playerActId=37,bActLoop=false,movoToDir =1.29,offsetPos ={0,0,0},offsetTime =466,needHide = true},
						  {loginPlayer =3,acttype=2,playerActId=37,bActLoop=false,movoToDir =1.29,offsetPos ={0,0,0},offsetTime =466,needHide = true},
						  {loginPlayer =4,acttype=2,playerActId=37,bActLoop=false,movoToDir =1.29,offsetPos ={0,0,0},offsetTime =466,needHide = true}},
    ['mainPlayer1040'] = {playerActId=39,bActLoop=true,movoToDir =4.56,movoToPos =3003},
	['mainPlayer1041'] = {acttype=2,playerActId=39,bActLoop=true,movoToDir =4.56,offsetPos ={-34,0,0},offsetTime =2500},
	['mainPlayer1042'] = {playerActId=1,bActLoop=true},
	['mainPlayer1043'] = {acttype=1,movoToDir =3.14,movoToPos =3016,playerActId=07,bActLoop =false},
	['mainPlayer1044'] = {acttype=1,movoToDir =3.14,movoToPos =3016,playerActId=08,bActLoop =true},
	['mainPlayer1045'] = {acttype=1,movoToDir =4.65,movoToPos =3017,playerActId=40,bActLoop =false},
	['mainPlayer1046'] = {appSpeed = 0.4},
	['mainPlayer1047'] = {acttype=1,movoToDir =4.25,movoToPos =3018,playerActId=41,bActLoop =true,AddCollection = 10000,AddCollectionStr="汲取圣器能量中，无法移动"},
	['mainPlayer1048'] = {acttype=1,movoToDir =1.25,movoToPos =3018,playerActId=07,bActLoop =false,AddBinghun = 1},
	['mainPlayer1049'] = {acttype=1,movoToDir =4.24,movoToPos =5056,playerActId=41,bActLoop =true,AddCollection = 10000,AddCollectionStr="汲取秘籍力量中，无法移动"},
	['mainPlayer1050'] = {acttype=1,movoToDir =1.25,movoToPos =5056,playerActId=07,bActLoop =false},
	['mainPlayer1051'] = {acttype=1,movoToDir =4.73,movoToPos =3019,playerActId=42,bActLoop =false},
	['mainPlayer1052'] = {acttype=1,movoToDir =4.73,movoToPos =3019,playerActId=01,bActLoop =false},
	['jiguan1'] = {jiguanId='bly_jiguanqiao',jiguanSan='BLY_jiguanqiao_daiji.san'},
	['jiguan2'] = {{jiguanId='bly_jiguanbosstai',jiguanSan='bly_jiguanbosstai_shangsheng.san',jiguanId1='bly_jiguanbosstai',jiguanSan1='bly_jiguanbosstai_xiajiang.san',loop1 = true},
	               {jiguanId='bly_jiguanyuantai',jiguanSan='BLY_jiguanyuantai_kai.san',jiguanId1='bly_jiguanyuantai',jiguanSan1='BLY_jiguanyuantai_kaihou.san',loop1 = true}},
	['jiguan3'] = {jiguanId='bly_jiguanyuantai',jiguanSan='BLY_jiguanyuantai_kai.san',jiguanId1='bly_jiguanyuantai',jiguanSan1='BLY_jiguanyuantai_kaihou.san',loop1 = true},
	['jiguan4'] = {jiguanId='guai_shanyanjushou',jiguanSan='guai_shanyanjushou_chusheng.san',jiguanId1='guai_shanyanjushou',jiguanSan1='guai_shanyanjushou_xiaoshi.san',loop1 = true},
	['jiguan5'] = {jiguanId='xsc_zhanchang_taizi02',jiguanSan='XSC_zhanchang_taizi02.san',jiguanId1='xsc_zhanchang_taizi02',jiguanSan1='XSC_zhanchang_taizi02_jieshu.san',loop1 = true},
	['jiguan6'] = {jiguanId='boss_shangguboss_chuchang',jiguanSan='BOSS_shangguboss_dixia.san',jiguanId1='boss_shangguboss_chuchang',jiguanSan1='BOSS_shangguboss_dixia.san',loop1 = true},
	['dh1001'] = {{acttype =1,npc=20100016,actId ='leisure',bActLoop = false}},
	['dh1002'] = {{acttype =1,npc=20100012,actId ='leisure',bActLoop = false}},
	['dh1003'] = {{acttype =1,npc=20100021,actId ='leisure',bActLoop = false}},
	['dp1001'] = {{acttype =2,npc=2031000,gid=42,actId ='atk',bActLoop = false,offsetPos ={80,0,0},offsetTime =5000,offsetActStart ='walk',offsetActStartLoop =true}},
	['dp1002'] = {{acttype =2,npc=2031000,gid=43,actId ='atk',bActLoop = false,offsetPos ={100,0,0},offsetTime =5000,offsetActStart ='walk',offsetActStartLoop =true}},
	['dp1003'] = {{acttype =2,npc=2031000,gid=44,actId ='atk',bActLoop = false,offsetPos ={80,0,0},offsetTime =5000,offsetActStart ='walk',offsetActStartLoop =true}},
	['yun1001'] = {{acttype =2,npc=20300062,gid=61,offsetPos ={-32,22,0},offsetTime =1000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300063,gid=62,offsetPos ={-37,27,0},offsetTime =1000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300063,gid=63,offsetPos ={-45,35,0},offsetTime =1000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300064,gid=64,offsetPos ={-65,50,0},offsetTime =1500,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300064,gid=65,offsetPos ={-109,92,0},offsetTime =2000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300064,gid=66,offsetPos ={-65,50,0},offsetTime =1500,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300064,gid=67,offsetPos ={-109,92,0},offsetTime =2000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300064,gid=68,offsetPos ={-65,50,0},offsetTime =1500,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300064,gid=69,offsetPos ={-109,92,0},offsetTime =2000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300064,gid=70,offsetPos ={-65,50,0},offsetTime =1500,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300064,gid=71,offsetPos ={-109,92,0},offsetTime =2000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300064,gid=72,offsetPos ={-65,50,0},offsetTime =1500,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300059,gid=73,offsetPos ={22,-29,0},offsetTime =1000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300060,gid=74,offsetPos ={22,-29,0},offsetTime =1000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300061,gid=75,offsetPos ={87,-84,0},offsetTime =2000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300061,gid=76,offsetPos ={87,-84,0},offsetTime =1500,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300061,gid=77,offsetPos ={87,-84,0},offsetTime =2000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300061,gid=78,offsetPos ={87,-84,0},offsetTime =1500,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300061,gid=79,offsetPos ={78,-73,0},offsetTime =2000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300061,gid=80,offsetPos ={42,-50,0},offsetTime =2000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300061,gid=81,offsetPos ={78,-73,0},offsetTime =1500,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300061,gid=82,offsetPos ={78,-73,0},offsetTime =2000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300061,gid=83,offsetPos ={42,-50,0},offsetTime =1500,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true},
	              {acttype =2,npc=20300061,gid=84,offsetPos ={42,-50,0},offsetTime =2000,offsetActStart ='move',offsetActStartLoop =true,offsetActEnd ='atk',offsetActEndLoop =true}},
  	['zs1001'] = {{acttype =1,npc=20300062,gid=86,actId ='deadfly',bActLoop = false},
	              {acttype =1,npc=20300062,gid=87,actId ='deadfly',bActLoop = false},
				  {acttype =1,npc=20300062,gid=88,actId ='deadfly',bActLoop = false},
				  {acttype =1,npc=20300062,gid=89,actId ='deadfly',bActLoop = false},
				  {acttype =1,npc=20300062,gid=90,actId ='deadfly',bActLoop = false},
				  {acttype =1,npc=20300063,gid=91,actId ='deadfly',bActLoop = false},
				  {acttype =1,npc=20300063,gid=92,actId ='deadfly',bActLoop = false},
				  {acttype =1,npc=20300063,gid=93,actId ='deadfly',bActLoop = false},
				  {acttype =1,npc=20300063,gid=94,actId ='deadfly',bActLoop = false}},
  	['zs1002'] = {{acttype =1,npc=20300067,gid=95,actId ='trans',bActLoop = false}},	
  	['zs1003'] = {{acttype =1,npc=20300067,gid=95,isDelete =20300067}},	
  	['zs1004'] = {{acttype =1,npc=20300068,gid=101,isDelete =20300068}},	
  	['zs1005'] = {{acttype =1,npc=20300074,gid=102,isDelete =20300074}},	
  	['zs1006'] = {{acttype =1,npc=20300075,gid=103,isDelete =20300075}},	
  	['zs1007'] = {{acttype =1,npc=20300076,gid=104,isDelete =20300076}},
    ['zs1008'] = {{acttype =1,npc=20300066,gid=105,isDelete =20300066}},	
    ['zs1009'] = {{acttype =1,npc=20300077,gid=110,isDelete =20300077},{acttype =1,npc=20300079,gid=111,isDelete =20300079}},
    ['zs1010'] = {{acttype =1,npc=20300078,gid=112,isDelete =20300078},{acttype =1,npc=20300080,gid=113,isDelete =20300080}},
    ['zs1011'] = {{acttype =1,npc=20300077,gid=110,actId ='stun',bActLoop = false}},
    ['zs1012'] = {{acttype =1,npc=20300077,gid=114,isDelete =20300077}},	
    ['zs1013'] = {{acttype =2,npc=20300079,gid=111,offsetPos ={0,0,40},offsetTime =2000,offsetActStart ='idle',offsetActStartLoop =true}},
    ['zs1014'] = {{acttype =1,npc=20300079,gid=117,isDelete =20300079}},		
    ['zs1015'] = {{acttype =1,npc=20300094,gid=119,actId ='trans',bActLoop = false}},
    ['zs1016'] = {{acttype =1,npc=20300096,gid=127,actId ='trans',bActLoop = true}},
    ['zs1017'] = {{acttype =2,npc=20300087,gid=124,offsetPos ={-27,0,2},offsetTime =1000,offsetActStart ='trans',offsetActStartLoop =false}},

	


}