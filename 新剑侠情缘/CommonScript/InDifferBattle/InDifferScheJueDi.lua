-- OnAddSingleRoomNpc -- nNpcTemplate, nLiveTime 单房间存在的npc，配置在 tbSingleRoomNpc
-- AddRandPosNpcSet Templateid, nLevel, nRoomIndex, 随机点集合，随机个数，重生时间(不传就不重生)
-- AddRandPosBuffSet, szDropBuff, nRoomIndex, tbPosSet, tbRandNum ,"1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", 1, {"last_buff_1", "last_buff_2", "last_buff_3", "last_buff_4"}, {1,1} };
-- AddRandTypeSet
-- AddRandTypeSetTimer
-- AddMapNpcByPosName nTemplateId, nLevel, nLiveTime, nRoomIndex, szPosName, nReviveTime
-- AddDropBuffByPosName szParam, nRoomIndex, szPosName



InDifferBattle.tbActiveTransJueDiFormat = {
  { 1,25,   {"ProcChoooseFaction"} };
  { 1,45,   {"ProcChoooseFaction"} };
  { 1,60,   {"SynGameTime"} };
  { 1,60,   {"ProcChoooseFaction"} };
  { 1,70,   {"AutoSelectFaction"} }; --自动将没选门派的选上门派,流程必须配置
  { 1,70,   {"ProcChoooseFaction"} };
  { 1,80,   {"SynGameTime"} };
  { 1,80,   {"ProcChoooseFaction"} };

  { 2,0,   {"BroatcastStartState", 2}}; --开始进入战斗状态
  { 2,1,   {"StartFightMode"}}; --开始进入战斗状态
  { 2,1,   {"UpdateLeftTeamNum"}}; --同步显示剩余队伍数
  

--随机房间添加buff
  --buffParam:--如：1|20;2|30;5   1号buff概率20   2号buff概率30   总共随机5次；1号是buffid这个对应的是在  Setting\Item\DropBuffList.tab，这个表里的nObjId对应模型是在 Setting\Item\ObjData.tab 里
-- buffParam, 房间组合, 房间数，buff数范围
  -- {2,1, {"AddRandRoomBuff", "1000|30;1001|15;1002|15;1003|15;1004|15;1005|10;1", 1, 3, {2,2} }};

--随机房间刷怪 --随机npc组合, npc等级，房间集合组合，房间数，npc个数范围，存活时间（不填就不消失）
  --{ 2,1 ,   {"AddRandRoomRandNpc", 1, 1, 1, 2, {1, 1}, 60*10 } };
  --刷新采集资源也是用上面的操作 
  --门派采集的class 是 IndifferChangeFaction, 参数是采集时间
  --行囊采集的class 是 IndiffeItemBag ，参数是采集时间
  --强化采集物的class是 IndifferEnhance， 参数是 采集时间， 对应强化等级在 tbEnhanceNpcLevel 里配置
  --坐骑采集class是 IndifferHorse 参数是 采集时间
  --秘籍采集class是 IndifferGatherBook 参数是 采集时间 ，npcid对应初中高在 tbSkillBookNpc 里配置
  --采集获得固定道具class 是 IndiffeGatherItem， 参数是采集时间, npcId对应获得道具在 tbGatherGetItemNpc
  --使用获得buff的道具, class 是 IndifferAddBuff， 参数1是id，2是等级，3是时间
  
  --第一次基础产出
  { 1, 5,  {"AddRandRoomRandNpc", 1,  1, 1, 18, {1, 1}, 660} }; --门派
  { 1, 10, {"AddRandRoomRandNpc", 2,  1, 1, 25, {1, 2}, 660} }; --行囊
  { 1, 15, {"AddRandRoomRandNpc", 5,  1, 1, 25, {1, 2}, 660} }; --强化
  { 1, 20, {"AddRandRoomRandNpc", 8,  1, 1, 29, {1, 2}, 660} }; --秘籍
  { 1, 25, {"AddRandRoomRandNpc", 11, 1, 1, 20, {1, 2}, 660} }; --坐骑
  { 1, 30, {"AddRandRoomRandNpc", 12, 1, 1, 29, {1, 2}, 660} }; --药品和技能
  { 1, 35, {"AddRandRoomRandNpc", 13, 1, 1, 20, {1, 2}, 660} }; --附魔石
  --第二次基础产出
  { 5, 1,  {"OnWorldNotify", "幻境中出现了新的资源，各位侠士快去寻找！"}};
  { 5, 1,  {"AddRandRoomRandNpc", 1,  1, 1, 18, {1, 1}, 660} }; --门派
  { 5, 1,  {"AddRandRoomRandNpc", 3,  1, 1, 25, {1, 2}, 660} }; --行囊
  { 5, 1,  {"AddRandRoomRandNpc", 6,  1, 1, 25, {1, 2}, 660} }; --强化
  { 5, 1,  {"AddRandRoomRandNpc", 9,  1, 1, 29, {1, 2}, 660} }; --秘籍
  { 5, 1,  {"AddRandRoomRandNpc", 11, 1, 1, 20, {1, 2}, 660} }; --坐骑
  { 5, 1,  {"AddRandRoomRandNpc", 12, 1, 1, 29, {1, 2}, 660} }; --药品和技能
  { 5, 1,  {"AddRandRoomRandNpc", 14, 1, 1, 20, {1, 2}, 660} }; --附魔石
  
  --刷出心魔怪物
  { 2, 30,  {"AddRandRoomRandNpc", 16, 99, 1, 25, {3, 5}, 60*2 } }; --怪物
  { 2, 151, {"AddRandRoomRandNpc", 16, 99, 1, 25, {3, 5}, 60*2 } }; --怪物
  { 4, 30,  {"AddRandRoomRandNpc", 16, 99, 1, 25, {3, 5}, 60*2 } }; --怪物
  { 4, 151, {"AddRandRoomRandNpc", 16, 99, 1, 25, {3, 5}, 60*2 } }; --怪物
  { 6, 30,  {"AddRandRoomRandNpc", 16, 99, 1, 25, {3, 5}, 60*2 } }; --怪物
  { 6, 151, {"AddRandRoomRandNpc", 16, 99, 1, 25, {3, 5}, 60*2 } }; --怪物

  --刷出buff
  {3,10,  {"AddRandRoomBuff", "2000|100;2001|100;2002|100;1", 1, 18, {1,3}}};  --buff
  {5,10,  {"AddRandRoomBuff", "2000|100;2001|100;2002|100;1", 1, 18, {1,3}}};  --buff
  {7,10,  {"AddRandRoomBuff", "2000|100;2001|100;2002|100;1", 1, 18, {1,3}}};  --buff
  {8,30,  {"AddRandRoomBuff", "2000|100;2001|100;2002|100;1", 1, 36, {1,3}}};  --buff
  {8,90,  {"AddRandRoomBuff", "2000|100;2001|100;2002|100;1", 1, 36, {1,3}}};  --buff
  {8,150, {"AddRandRoomBuff", "2000|100;2001|100;2002|100;1", 1, 36, {1,3}}};  --buff
  {8,210, {"AddRandRoomBuff", "2000|100;2001|100;2002|100;1", 1, 36, {1,3}}};  --buff

  --增加存活分，加上一阶段的存活分
  {3,0,{"AddLastAlivePlayerScore"}};
  {4,0,{"AddLastAlivePlayerScore"}};
  {5,0,{"AddLastAlivePlayerScore"}};
  {6,0,{"AddLastAlivePlayerScore"}};
  {7,0,{"AddLastAlivePlayerScore"}};
  {8,0,{"AddLastAlivePlayerScore"}}; --最后一阶段的有在stopfight里加

--只刷新在安全区的单房间就一个的npc，如幻象，首领, npc要配置到tbSingleRoomNpc，不同与普通版，这个不只是安全区会刷
  
  --幻兽首领
  { 2,100, {"OnAddSingleRoomNpc", 2105, 100} };
  { 2,100, {"OnWorldNotify", "幻境中出现了心魔幻兽（可通过地图查看出现区域）"}};
  { 2,201, {"OnAddSingleRoomNpc", 2105, 100} };
  { 2,201, {"OnWorldNotify", "幻境中出现了心魔幻兽（可通过地图查看出现区域）"}};

  { 4,100, {"OnAddSingleRoomNpc", 2105, 100} };
  { 4,100, {"OnWorldNotify", "幻境中出现了心魔幻兽（可通过地图查看出现区域）"}};
  { 4,201, {"OnAddSingleRoomNpc", 2105, 100} };
  { 4,201, {"OnWorldNotify", "幻境中出现了心魔幻兽（可通过地图查看出现区域）"}};

  { 6,100, {"OnAddSingleRoomNpc", 2105, 100} };
  { 6,100, {"OnWorldNotify", "幻境中出现了心魔幻兽（可通过地图查看出现区域）"}};
  { 6,201, {"OnAddSingleRoomNpc", 2105, 100} };
  { 6,201, {"OnWorldNotify", "幻境中出现了心魔幻兽（可通过地图查看出现区域）"}};

  --心魔幻象
  { 3,60, {"OnAddSingleRoomNpc", 2101, 3*60} };
  { 3,60, {"OnWorldNotify", "幻境中出现了心魔幻象（可通过地图查看出现区域）"}};

  { 5,60, {"OnAddSingleRoomNpc", 2101, 3*60} };
  { 5,60, {"OnWorldNotify", "幻境中出现了心魔幻象（可通过地图查看出现区域）"}};

  { 7,60, {"OnAddSingleRoomNpc", 2101, 3*60} };
  { 7,60, {"OnWorldNotify", "幻境中出现了心魔幻象（可通过地图查看出现区域）"}};

  --上古凶兽
  { 4, 5, {"StartFreshMonsterTimer", 10, 30} }; --开始安全区刷新凶兽的操作 ，参数1-提前预告时间，参数2-房间停留时间 ，瘴气弥漫后会停止刷新需要重新加到流程里
  { 6, 5, {"StartFreshMonsterTimer", 10, 30} };

  --瘴气流程
  { 2,0,  {"MarkDangerouRoomCurByRange", 4 } };  --第一次标记瘴气，随机一个4*4的范围为标记的非安全区


  { 3,52, {"BroatcastSpecialTips", "瘴气即将弥漫"} }; --弥漫客户端提示
  { 4,0, {"ChangeDangerousRoom", 2} }; --第一次标记瘴气弥漫，每调一次毒气加深一次

  { 4,1, {"MarkDangerouRoomCurByRange", 2 }}; --第二次标记瘴气, 2*2
  { 5,52, {"BroatcastSpecialTips", "瘴气即将弥漫"} }; --弥漫客户端提示
  { 6,0, {"ChangeDangerousRoom", 6} }; --第二次标记瘴气弥漫

  { 6,1, {"MarkDangerouRoomCurByRange", 1 }}; --第三次标记瘴气, 1*1
  
  { 7,52, {"BroatcastSpecialTips", "瘴气即将弥漫"} }; --弥漫客户端提示
  { 8,0, {"ChangeDangerousRoom", 10} }; --第三次标记瘴气弥漫  
  { 8,0, {"ForbitPlayerChangeActionMode"} }; --禁止骑马
};



