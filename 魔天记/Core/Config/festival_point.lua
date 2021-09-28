local festival_point={
[1]={1,'仙玉消耗','303',303,1,10000},
[2]={2,'剧情副本','richang_09',70,5,50},
[3]={3,'赏金任务','richang_02',166,2,100},
[4]={4,'仙盟聚饮','richang_06',167,5,30},
[5]={5,'小炎界','fb_xyj',159,10,60},
[6]={6,'玄榜任务','richang_01',164,2,100},
[7]={7,'竞技场','richang_03',71,4,60},
[8]={8,'虚灵塔','richang_08',163,10,60},
[9]={9,'九幽王座','fb_jy',175,10,60},
[10]={10,'禁忌之地','fb_zx07',177,10,60},
[11]={11,'无尽试炼','152',152,10,60},
[12]={12,'海皇宫','fb_hhg',154,10,60},
[13]={13,'螟族入侵','huodong_04',170,10,60},
[14]={14,'伏蛟山','fb_fjs',176,10,60}
}
local ks={id=1,activity_name=2,icon=3,fun_id=4,point_once=5,point_all=6}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(festival_point)do setmetatable(v,base)end base.__metatable=false
return festival_point
