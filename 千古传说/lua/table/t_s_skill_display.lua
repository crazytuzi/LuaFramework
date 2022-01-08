 
-- 	id = 1, 			
-- 	remote = 0,			是否远程：0近程 1远程
-- 	attackEff = {0},		攻击特效id
-- 	attackEffTime = {0}, 	攻击特效开始时间(毫秒),相对于攻击动作起始点
-- 	attackEffType = {0},  攻击特效类型 0攻击者身上播放 1屏幕中心播放 2打横排 3直线飞行单体 4直线飞行竖排 5攻击者脚下播放 6我方阵容中心播放 7敌方阵容中心播放 8屏幕中心置顶  9我方阵容中心置顶播放 10敌方阵容中心置顶播放 11屏幕中心垫底播放  12特殊-反击时对方闪避也会播放（特效大小为0的一倍）
--  hitEffType = {0},  攻击特效类型 0攻击者身上播放 1屏幕中心播放 2打横排 3直线飞行单体 4直线飞行竖排 5攻击者脚下播放 6我方阵容中心播放 7敌方阵容中心播放 8屏幕中心置顶  9我方阵容中心置顶播放 10敌方阵容中心置顶播放  11屏幕中心垫底播放 12特殊-反击时对方闪避也会播放（特效大小为0的一倍）
-- 	hitAnimTime1 = 100, 受击动作播放时间(毫秒),相对于攻击动作起始点
-- 	textAnimTime1 = 100, 扣血文本播放延迟时间(毫秒)，相对于受击动作播放时间
-- 	hitEff = { 0}, 		受击特效id 所有受击特效在受击者身上播放
--<---------------------------以上是必填项-------------------------------------->
--<---------------------------以下是选填项-------------------------------------->
--  moveDistance = 0,	当remote = 0 需要移动时,攻击者距离目标的距离 不填默认30
--  movePathType = 0,	当remote = 0 需要移动时,攻击者的移动路径 0直线 1曲线 不填默认直线
--  backPathType = 0,	当remote = 0 需要移动时,攻击者的返回路径 0直线 1曲线 不填默认直线
--  needMoveCenter = 0,	移动到屏幕中心释放 默认0
--  xuliEff = 10101, 	蓄力特效id 不填默认0
--  xuliEffTime = 50,   蓄力特效开始时间(毫秒),相对于攻击动作起始点 不填默认0
--  xuliEffOffsetX= 0,  蓄力特效X偏移量，不填默认0
--  xuliEffOffsetY= 0,  蓄力特效Y偏移量，不填默认0
--  attackEffOffsetX= {0},攻击特效X偏移量，不填默认0
--  attackEffOffsetY= {0},攻击特效Y偏移量，不填默认0
--  flyEffRotate= 0,    飞行特效是否旋转，0不旋转 1旋转 不填默认0
-- 	hitAnimTime2 = 200, 多段攻击时第2次受击动作播放时间(毫秒),相对于攻击动作起始点 最多可配置到hitAnimTime10
-- 	hitAnimTime3 = 300, 多段攻击时第3次受击动作播放时间(毫秒),相对于攻击动作起始点 注意后面的时间一定要比前面大 
--  hitEffOffsetX={ 0},   受击特效X偏移量，不填默认0
--  hitEffOffsetY={ 0},   受击特效Y偏移量，不填默认0
-- 	hitEffTime = {0},		受击特效开始时间(毫秒),相对于受击动作起始点	不填默认0
-- 	hitEffShowOnce = 0,	多次受击时是否只显示一次受击特效 默认0
-- 	attackAnimMove = 1,	攻击动作是否带位移，带位移隐藏血条 默认0
--  attackSound = 1000, 攻击音效，文件夹为Resource\sound\effect
--  attackSoundTime = 100, 攻击音效开始时间(毫秒),相对于攻击动作起始点 不填默认0
--  hitSound = 1001, 	受击音效，文件夹为Resource\sound\effect
--  hitSoundTime = 100, 受击音效开始时间(毫秒),相对于受击动作起始点 不填默认0
--  attackAnim = "attack", 攻击动作名称，不填普攻调用attack 技能调用skill
--  needMoveSameRow = 1,移动到目标同一排释放 默认0 近战根据攻击目标（可能在后排）去设置距离，远程根据前排去设置距离。
--  beforeMoveAnim = "drink" 移动前播放的动作
--  shake = 10 屏幕抖动值，未填远程默认6，近战默认3
--  extraShowHit = true 额外buff动画是否显示被击打动画
--  extraEff  额外动画参数 类似 hitEff 改成extraEff就好了
--  effectScale = {0.6,0.9,1.4}, 受击大小
local mapArray = MEMapArray:new()

--1哪吒
mapArray:push({ id = 1, remote = 0, moveDistance = 70,attackEff = {100011}, attackEffTime = {0}, moveDistance = 200,attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 500,attackAnim = "attack",attackSound = 101,hitSound = 41})
mapArray:push({ id = 10100, remote = 1, attackEff = {100013}, attackEffTime = {100}, attackEffType = {0}, hitEff = { 101022},hitAnimTime1 = 2500,hitAnimTime2 = 2700,hitAnimTime3 = 2900, attackSound = 102,hitSound = 12})
mapArray:push({ id = 10102, remote = 0, moveDistance = 70,attackEff = {100011}, attackEffTime = {0}, moveDistance = 200,attackEffType = {0},hitAnimTime1 = 500,beforeMoveAnim = "drink",attackSound = 101,hitSound = 41})

--2至尊宝
mapArray:push({ id = 2, remote = 1, moveDistance = 230,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 700,textAnimTime1 = 700,hitEffOffsetX={ 180},hitEff = { 100022},hitEffType = {12},effectScale = {0.5},attackAnim = "attack",attackSound = 2891,attackSoundTime = 700,hitSound = 41})
mapArray:push({ id = 20100, remote = 0,moveDistance = 300,needMoveCenter = 1,attackEffType = {0},attackEff = {0}, attackEffTime = {0},attackEffOffsetY= {0}, hitAnimTime1 = 10,textAnimTime1 = 300,hitAnimTime2 = 800,hitEffShowOnce = 1,hitEffType = {12},effectScale = {0.5},hitEffOffsetY={ 120},hitEffOffsetX={ 150},hitEff = { 100021},attackAnimMove = 1,beforeMoveAnim = "skill2",attackAnim = "skill", attackSound = 2302,attackSoundTime = 0,hitSound = 41})

--3杨戬
mapArray:push({ id = 3, remote = 0, moveDistance = 280,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 750,hitAnimTime2 = 1400,attackAnim = "attack",attackSound = 301,hitSound = 302})
mapArray:push({ id = 30100, remote = 1, attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 550, hitEff = { 0}, attackSound = 303})
--反击
mapArray:push({ id = 30102, remote = 1, attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 550,textAnimTime1=600, attackAnim = "skill2",hitEff = { 100031}, attackSoundTime=500,attackSound = 306,hitSound = 13})

--4南极仙翁
mapArray:push({ id = 4, remote = 0, moveDistance = 120,attackEff = {100041},attackEffTime = {300}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 300, attackAnim = "attack",attackSound = 401,hitSound = 22})
mapArray:push({ id = 40100, remote = 1, xuliEff = 100043, attackEff = {0},attackEffTime = {500}, attackEffType = {4}, hitAnimTime1 = 1000, hitEff = { 1000021}, attackSound = 402})

--5韩湘子
mapArray:push({ id = 5, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 900, hitEff = { 100051},hitEffType = {12},hitEffOffsetY={ -50},effectScale = {1.2},attackSound = 501,hitSound = 32})
mapArray:push({ id = 50100, remote = 1, moveDistance = 0,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitAnimTime2 = 1300, hitAnimTime3 = 1700, hitEffType = {12},hitEffOffsetY={ -80},effectScale = {1.5},hitEff = { 100051},attackSound = 503,hitSound = 504})

--6雷震子
mapArray:push({ id = 6, remote = 0, moveDistance = 30,attackEff = {100061}, attackEffTime = {0}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 250,moveDistance = 170,attackAnim = "attack", attackSound = 601,hitSound = 43})
mapArray:push({ id = 60100, remote = 1, attackEff = {100063}, attackEffTime = {200}, attackEffType = {0}, hitEff = { 101044},hitAnimTime1 = 1000,attackSound = 602,hitSound = 12})

--7二帮主
mapArray:push({ id = 7, remote = 0, moveDistance = 100,attackEff = {100071}, attackEffTime = {30}, attackEffType = {0},hitAnimTime1 = 200, hitEff = { 702},attackAnim = "attack",attackSound = 701,hitSound = 41})
mapArray:push({ id = 70100, remote = 1, moveDistance = 0,attackEff = {100073}, attackEffTime = {0}, attackEffType = {0},attackAnim = "skill", hitAnimTime1 = 0, hitEff = { 0},attackSound = 702,hitSound = 0})
mapArray:push({ id = 70102, remote = 0, moveDistance = 170,attackEff = {110073}, attackEffTime = {0}, attackEffType = {0},attackAnim = "skill2", hitAnimTime1 = 400, hitEff = { 101022},attackSound = 703,hitSound = 13})

--8哼将郑伦
mapArray:push({ id = 8, remote = 0, moveDistance = 140,attackEff = {100081}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 200, attackAnim = "attack",attackSound = 801,hitSound = 21})
mapArray:push({ id = 80100, remote = 1, attackEff = {100083},  attackEffTime = {0}, attackEffType = {2}, hitAnimTime1 = 600, hitAnimTime2 = 900,hitEff = { 100084},attackSound = 802,hitSound = 14})

--9祝融
mapArray:push({ id = 9, remote = 0, moveDistance = 130,attackEff = {0}, attackEffTime = {700}, attackEffType = {0}, hitEffOffsetY={ 30},hitEff = { 90091},effectScale = {2.0},hitAnimTime1 = 600, attackAnim = "attack",attackSound = 901,hitSound = 902})
mapArray:push({ id = 90100, remote = 1, attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1400, hitEff = { 100091},hitEffType = {12},effectScale = {0.8},attackSound = 903,hitSound = 904})

--10青霞仙子
mapArray:push({ id = 10, remote = 0, attackEff = {100101}, attackEffTime = {0}, attackEffType = {0}, hitEff = { 101022},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 1001,hitSound = 23})
mapArray:push({ id = 100100, remote = 1, attackEff = {930612}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1800, hitAnimTime2 = 1900,hitAnimTime3 = 2100,hitEff = { 101088},attackSound = 1002,hitSound = 33})
mapArray:push({ id = 100102, remote = 0, moveDistance = 100,attackEff = {110103},  needMoveSameRow = 1,attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 101055},attackAnim = "skill2",attackSound = 1002,hitSound = 13})

--11金翅大鹏
mapArray:push({ id = 11, remote = 0, moveDistance = 200, attackEff = {100111}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 101022},attackAnim = "attack",attackSound = 1101,hitSound = 21})
mapArray:push({ id = 110100, remote = 0,moveDistance = 180,attackEff = {100113}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitAnimTime2 = 1200,hitAnimTime3 = 1600,hitEff = { 101077},attackSound = 1102,hitSound = 22})

--12太乙真人
mapArray:push({ id = 12, remote = 0, moveDistance = 200, attackEff = {100121}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 101077},attackAnim = "attack",attackSound = 1201,hitSound = 41})
mapArray:push({ id = 120100, remote = 0,moveDistance = 210,attackEff = {100123}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1500, hitAnimTime2 = 1800,hitAnimTime3 = 2000,hitAnimTime4 = 2700,hitEff = { 101077},attackSound = 1202,hitSound = 42})
--技能配置表没有
mapArray:push({ id = 120101, remote = 0,moveDistance = 210,attackEff = {100125}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1500, hitEffShowOnce = 1, hitEff = { 100124},attackSound = 1202,hitSound = 42})
--打竖排
mapArray:push({ id = 120102, remote = 0,moveDistance = 210,attackEff = {100125}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1= 1400, hitAnimTime2 = 1700,hitAnimTime3= 1900, hitAnimTime4= 2600, hitEffShowOnce = 1, hitEff = {0},hitEffType={0},hitEff = { 100124 },attackSound = 1202,hitSound = 42})--, hitAnimTime2 = 2200,hitAnimTime3 = 2500

--13紫霞
mapArray:push({ id = 13, remote = 0, moveDistance = 150,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 300,hitAnimTime2 = 600,hitEff = { 90131},effectScale = {2.5},hitEffOffsetX={ -40},hitEffOffsetY={ -120},attackAnim = "attack",attackSound = 1301,hitSound = 22})
mapArray:push({ id = 130100, remote = 1,xuliEff = 100131,attackEff = {100131}, attackEffTime = {333}, attackEffType = {0}, hitAnimTime1 = 1850,textAnimTime1=300, hitEff = { 100131,100132},hitEffType = {0},effectScale = {0.8},attackSound = 1302})

--14法海
mapArray:push({ id = 14, remote = 1, moveDistance = 250, attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 1200, hitEff = {100141},hitEffType = {12},effectScale = {0.8},attackAnim = "attack",attackSound = 1402,hitSound = 1401})
mapArray:push({ id = 140100, remote = 1,needMoveSameRow = 1,moveDistance = 150,attackEff = {0},attackEffTime = {0},hitAnimTime1 = 1200,hitAnimTime2 = 2000, hitEff = {0},attackAnim = "skill",attackSound = 1403,hitSound = 1405})
mapArray:push({ id = 140102, remote = 0,needMoveSameRow = 1,moveDistance = 170,attackEff = {0},attackEffTime = {0},hitAnimTime1 = 1400,hitAnimTime2 = 1800,hitAnimTime3 = 2200,hitEff = { 0},attackAnim = "skill2",attackSound = 1404,hitSound = 1405})


--15金吒
mapArray:push({ id = 15, remote = 0, moveDistance = 120,attackEff = {100151}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 200, hitEff = { 101088},hitEffOffsetX={ 0},hitEffOffsetY={ 0},attackAnim = "attack",attackSound = 1501,hitSound = 21})
mapArray:push({ id = 150100, remote = 1, xuliEff = 100156, attackEff = {100153},flyEffRotate = 1,attackEffTime = {600},attackEffOffsetY= {0}, attackEffType = {3}, hitAnimTime1 = 800, hitEff = {101088},attackSound = 1502,hitSound = 23})

--16干将
mapArray:push({ id = 16, remote = 0, moveDistance = 120,attackEff = {100161}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 250, hitEff = { 101044},attackAnim = "attack",attackSound = 1601,hitSound = 23})
mapArray:push({ id = 160100, remote = 1,xuliEff = 100166,attackEff = {100163}, flyEffRotate = 3,attackEffType = {4},attackEffTime = {1000}, hitAnimTime1 = 1200, hitEff = { 100164},attackSound = 1702,hitSound = 21})

--17小蝶
mapArray:push({ id = 17, remote = 0, moveDistance = 150,attackEff = {100171}, attackEffTime = {180}, attackEffType = {0},hitAnimTime1 = 200, hitEff = { 101022},attackAnim = "attack",attackSound = 1701,hitSound = 42})
mapArray:push({ id = 170100, remote = 1,attackEff = {100173}, attackEffTime = {10}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 101088},attackSound = 1702,hitSound = 12})

--18小唯
mapArray:push({ id = 18, remote = 0, moveDistance = 150,attackEff = {100181}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 200, hitEff = { 1802},attackAnim = "attack",attackSound = 1801,hitSound = 43})
mapArray:push({ id = 180100, remote = 1, moveDistance = 180,attackEff = {180101}, attackEffTime = {0}, attackEffType = {0},hitEff = {0},hitAnimTime1 = 900,attackSound = 1802,hitSound = 13})

--19济公
mapArray:push({ id = 19, remote = 0, moveDistance = 150,attackEff = {100191}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 200,hitAnimTime2 = 500,hitAnimTime3 = 900, hitEff = { 101055},attackAnim = "attack",attackSound = 1901,hitSound = 23})
mapArray:push({ id = 190100, remote = 1,xuliEff = 100196, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 1500,hitAnimTime2 = 1800,hitAnimTime3 = 2200,hitEff = { 100194},attackSound = 1902,hitSound = 15})

--21土行孙
mapArray:push({ id = 21, remote = 0, moveDistance = 150,attackEff = {100211}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 100212},attackAnim = "attack",attackSound = 2101,hitSound = 21})
mapArray:push({ id = 210100, remote = 1,moveDistance = 0,attackEff = {110213}, needMoveSameRow = 1,attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 101055}, attackAnimMove = 1, attackSound = 2102,hitSound = 21})
mapArray:push({ id = 210102, remote = 1,moveDistance = 0,needMoveCenter = 1,attackEff = {100213}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 300,hitEff = { 101055}, hitAnimTime2 = 900, hitAnimTime3 = 1400, attackAnim = "skill2",attackAnimMove = 1, attackSound = 2102,hitSound = 23})

--22织女
mapArray:push({ id = 22, remote = 0, moveDistance = 200,attackEff = {100221}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 2201,hitSound = 22})
mapArray:push({ id = 220100, remote = 1,attackEff = {100223}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 8002},attackSound = 2202,hitSound = 14})
mapArray:push({ id = 220102, remote = 1,attackEff = {110223}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600,hitEff = { 0},attackAnim = "skill2",hitEff = { 110224},attackSound = 2202})

--23牛魔王
mapArray:push({ id = 23, remote = 0, moveDistance = 120,attackEff = {100231}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,hitAnimTime2 = 600,attackAnim = "attack",attackSound = 2301,hitSound = 42})
mapArray:push({ id = 230100, remote = 1,moveDistance = 100,attackEff = {100233}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 1000, hitAnimTime3 = 1500,  hitEff = { 0},attackAnim = "skill2",attackSound = 2302,hitSound = 43})
mapArray:push({ id = 230102, remote = 0,moveDistance = 100,attackEff = {100234}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 1000, hitAnimTime3 = 1500,  hitEff = { 101022},attackAnim = "skill1",attackSound = 2303,hitSound = 43})

--24何仙姑
mapArray:push({ id = 24, remote = 1, moveDistance = 0,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 666,textAnimTime1=300,hitEffType={12},hitEffOffsetY={ -50},effectScale = {0.8},hitEff = { 100241},attackAnim = "attack",attackSound = 2401,hitSound = 2402})
mapArray:push({ id = 240100, remote = 1,moveDistance = 0,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 1500,textAnimTime1=300,hitAnimTime2 = 2300,hitEffType={12},hitEffOffsetY={ -50},effectScale = {0.8},hitEff = { 100241},attackSound = 2403,hitSound = 2402})
mapArray:push({ id = 240102, remote = 1,moveDistance = 0,attackEff = {0}, attackEffType = {0},attackEffTime = {0}, hitAnimTime1 = 666,textAnimTime1=300,hitEffType={12},hitEffOffsetY={ -50},effectScale = {0.8},hitEff = { 100241},attackAnim = "skill2",attackSound = 2401,hitSound = 2402})

--27山神
mapArray:push({ id = 27, remote = 0, moveDistance = 100,attackEff = {100271}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 2701,hitSound = 31})
mapArray:push({ id = 270100, remote = 1,attackEff = {100273}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 900, attackSound = 2702,hitSound = 15,attackAnim = "skill2"})

--28待定绿
mapArray:push({ id = 28, remote = 0, moveDistance = 150,attackEff = {100281}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 2801,hitSound = 42})
mapArray:push({ id = 280100, remote = 1,attackEff = {100283}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 550, hitEff = {101088},attackSound = 2802,hitSound = 12})

--29土地公
mapArray:push({ id = 29, remote = 0, moveDistance = 180,attackEff = {100291}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 350,attackAnim = "attack",attackSound = 2901,hitSound = 33})
mapArray:push({ id = 290100, remote = 1,attackEff = {100293}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitAnimTime2 = 700,hitAnimTime3 = 1100,hitEff = { 1000021},attackSound = 2902})
mapArray:push({ id = 290102, remote = 1,attackEff = {100294}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, attackAnim = "skill2",hitEff = { 1000021},attackSound = 2902})

--30青丘狐
mapArray:push({ id = 30, remote = 0, moveDistance = 150,attackEff = {101361}, attackEffTime = {20}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 500,attackAnim = "attack",attackSound = 3001,hitSound = 23})
mapArray:push({ id = 300100, remote = 1,attackEff = {100303}, attackEffTime = {120}, attackEffType = {0}, hitAnimTime1 = 1500, hitEff = { 101088},attackSound = 3002,hitSound = 11})

--31菩提
mapArray:push({ id = 31, remote = 0, moveDistance = 100,attackEff = {100311}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 3101,hitSound = 42})
mapArray:push({ id = 310100, remote = 1,attackEff = {100313}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 1000021},attackSound = 3102})
mapArray:push({ id = 310102, remote = 1,attackEff = {100294}, attackEffTime = {0}, attackEffType = {0}, attackAnim = "skill2",hitAnimTime1 = 600, hitEff = { 1000021},attackSound = 3103})

--35待定绿
mapArray:push({ id = 35, remote = 0, moveDistance = 100,attackEff = {100351}, attackEffTime = {0}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 150,hitAnimTime2 = 250,attackAnim = "attack",attackSound = 3501,hitSound = 23})
mapArray:push({ id = 350100, remote = 0,moveDistance = 200,attackEff = {100353}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitAnimTime2 = 900, hitEff = { 101088},attackSound = 3502,hitSound = 41})

--44洛神
mapArray:push({ id = 44, remote = 1, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 100441},hitEffType = {12},effectScale = {0.5},hitAnimTime1 = 500,textAnimTime1=300,hitEffShowOnce = 1,attackAnim = "attack",attackSound = 4401,hitSound = 4402})
mapArray:push({ id = 440100, remote = 1,moveDistance = 80, attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 2066,textAnimTime1=600,hitEff = { 100442},hitEffType={6},attackSound = 4403,hitSound = 4404})
mapArray:push({ id = 440102, remote = 1,moveDistance = 80, attackEff = {0}, attackEffTime = {0}, attackEffType = {0},attackAnim = "attack",hitEffOffsetY={ -30}, hitAnimTime1 = 700,textAnimTime1=500, hitEff = { 100443},effectScale = {0.8},attackSound = 4405,hitSound = 4404})

--49梁山伯
mapArray:push({ id = 49, remote = 0, moveDistance = 90,attackEff = {100041},attackEffTime = {500}, attackEffType = {0},hitAnimTime1 = 350, hitEff = { 100042},attackAnim = "attack",attackSound = 1,hitSound = 21})
mapArray:push({ id = 490100, remote = 1, xuliEff = 40101, attackEff = {40103},flyEffRotate =0,attackEffTime = {400}, attackEffType = {4}, hitAnimTime1 = 800, hitEff = {402},attackSound = 2,hitSound = 13})

--77吕洞宾
mapArray:push({ id = 77, remote = 0,moveDistance = 220,attackEff = {0}, attackEffTime = {0}, attackEffType = {3},hitAnimTime1 = 350,hitAnimTime2 = 750,hitAnimTime3 = 1400,hitEff = { 100771},effectScale = {2.0},hitEffOffsetY={ 150},attackAnim = "attack",attackSound = 7701,hitSound = 7702})
--技能1
mapArray:push({ id = 770100, remote = 0, needMoveSameRow = 1,moveDistance = 200,attackEff = {0},attackEffType = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 900,hitEff = { 100771},effectScale = {2.0},attackAnim = "skill",attackSound = 7703,hitSound = 22})
--技能2
mapArray:push({ id = 770102, remote = 1,attackEff = {0},attackEffType = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 866,hitAnimTime2 = 1833,hitAnimTime3 = 3000,hitEff = { 0},effectScale = {2.0},attackAnim = "skill5",attackSound = 7703,hitSound = 22})
--技能3
mapArray:push({ id = 770104, remote = 1, moveDistance = 0,needMoveCenter = 1,attackEff = {100772}, shake = 10,attackEffOffsetY= {100},attackEffOffsetX= {-20},attackEffTime = {800}, attackEffType = {10},hitAnimTime1 = 1000,hitAnimTime2 = 1300,hitAnimTime3 = 1600,hitEff = { 100771},attackAnim = "skill3",attackSound = 7707,hitSound = 22})
--77被动技能
mapArray:push({ id = 770103, remote = 0,moveDistance = 220,attackEff = {0}, attackEffTime = {0}, attackEffType = {3},hitAnimTime1 = 350,hitAnimTime2 = 750,hitAnimTime3 = 1400,hitEff = { 100771},effectScale = {2.0},hitEffOffsetY={ 150},attackAnim = "attack",attackSound = 7701,hitSound = 7702})
mapArray:push({ id = 779900,  remote = 0, needMoveSameRow = 1,moveDistance = 200,attackEff = {123456},attackEffType = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 1200,hitEff = { 101022},attackAnim = "skill",attackSound = 7703,hitSound = 12})

--78嫦娥
mapArray:push({ id = 78, remote = 1,moveDistance = 300,needMoveSameRow = 1,attackEff = {0}, attackEffTime = {0}, attackEffType = {3},hitAnimTime1 = 1000,hitEff = {0},attackAnim = "attack",attackSound = 7801,hitSound = 0})
--技能1
mapArray:push({ id = 780100, remote = 1, moveDistance = 0,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 500,textAnimTime1=400,hitAnimTime2 = 1200,hitAnimTime3 = 1400,hitEffShowOnce = 1,hitEff = { 100781},hitEffType = {12},effectScale = {0.5},attackAnim = "skill",attackSound = 7802,hitSound = 7803})
--技能2
mapArray:push({ id = 780102, remote = 1, moveDistance = 120,attackEff = {100783}, attackEffTime = {300}, attackEffType = {0},hitAnimTime1 = 1000,hitEff = { 90783,100783},effectScale = {1.8},hitEffType = {0,0},attackAnim = "skill2",attackSound = 7804,hitSound = 0})
--技能3
mapArray:push({ id = 780103, remote = 1, moveDistance = 120,needMoveCenter = 1,attackEff = {100785,100784}, attackEffTime = {0,1066}, attackEffType = {11,8},hitAnimTime1 = 2866, hitEff = { 100783},effectScale = {3.0},hitEffType = {10},attackAnim = "skill3",attackSound = 7805,hitSound = 0,shake = 7})
mapArray:push({ id = 789900, remote = 1, moveDistance = 0,attackEff = {123456}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 900,textAnimTime1=600,hitEff = { 100781},attackAnim = "skill",attackSound = 7802,hitSound = 7803})

--79聂小倩
mapArray:push({ id = 79, remote = 1, moveDistance = 150,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 100791},hitEffType = {12},effectScale = {0.5},hitEffOffsetY={ -15},attackAnim = "attack",hitAnimTime1 = 1100,textAnimTime1 = 500,attackSound = 7901,hitSound = 7902})
--79技能1
mapArray:push({ id = 790100, remote = 0, moveDistance = 230,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 750,textAnimTime1=300,hitEff = {100794},attackAnim = "skill",attackSound = 7903,hitSound = 7904})
--79技能2
mapArray:push({ id = 790102, remote = 1,needMoveCenter = 1, moveDistance = 300,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 900,textAnimTime1 = 400,hitAnimTime2 = 2000,hitEff = { 100792},hitEffType = {12},effectScale = {0.5},attackAnim = "skill2",attackSound = 7905,hitSound = 0})
--79技能3
mapArray:push({ id = 790103, remote = 1,attackEff = {100793}, attackEffTime = {200}, attackEffType = {11},attackEffOffsetY= {-40},hitAnimTime1 = 600,textAnimTime1 = 300,hitAnimTime2 = 1900,hitEff = { 100795},effectScale = {1.4},hitEffType = {6},attackAnim = "skill3",attackSound = 7906,hitSound = 0})
mapArray:push({ id = 799900, remote = 1, moveDistance = 300,attackEff = {110793}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 1000,hitEff = { 90795},attackAnim = "skill2",attackSound = 7903,hitSound = 21})

--80姜子牙
mapArray:push({ id = 80, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 450, hitEff = { 100801},effectScale = {1.5},attackAnim = "attack",attackSound = 8001,hitSound = 32})
--80技能1
mapArray:push({ id = 800103, remote = 0,moveDistance = 180,attackEff = {100803,100803}, attackEffTime = {0,550}, attackEffType = {0,0}, hitAnimTime1 = 700,hitAnimTime2 = 1100,hitEff = {0},attackAnim = "skill",attackSound = 8001,hitSound = 31})
--80技能2
mapArray:push({ id = 800102, remote = 1,needMoveSameRow = 1,moveDistance = 300,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1300, textAnimTime1 = 300,hitEff = { 100802},hitEffType = {12},effectScale = {0.5},attackAnim = "skill2",attackSound = 8001,hitSound = 43})
--80技能3
mapArray:push({ id = 800100, remote = 1,needMoveSameRow = 1,moveDistance = 300,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1300, textAnimTime1 = 300,hitEff = { 100802},hitEffType = {12},effectScale = {0.5},attackAnim = "skill3",attackSound = 8001,hitSound = 43})
--80被动技能
mapArray:push({ id = 800104, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 450, hitEff = { 100801},effectScale = {1.5},attackAnim = "attack",attackSound = 8001,hitSound = 32})
mapArray:push({ id = 809900, remote = 0, moveDistance = 180,attackEff = {123456}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 450, hitEff = { 100801},effectScale = {1.5},attackAnim = "attack",attackSound = 8001,hitSound = 32})


--81秦王
mapArray:push({ id = 81, remote = 0, moveDistance = 100,attackEff = {100811}, attackEffTime = {100}, attackEffType = {0},hitAnimTime1 = 600, hitEff = { 101088},attackAnim = "attack",attackSound = 8101,hitSound = 23})
mapArray:push({ id = 810100, remote = 1,attackEff = {100813}, attackEffTime = {90}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 1500, hitEff = { 8002},attackSound = 8102,hitSound = 14})

--82哮天犬
mapArray:push({ id = 82, remote = 0, moveDistance = 250,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 166,hitAnimTime2 = 566,hitAnimTime3 = 900,hitAnimTime4 = 1200,hitAnimTime5 = 1700,hitEff = { 0},attackAnim = "attack",attackSound = 8201,hitSound = 21})
mapArray:push({ id = 820100, remote = 1,attackEff = {0}, attackEffTime = {250}, attackEffType = {0}, hitEffOffsetY={ -50}, hitAnimTime1 = 1533,hitAnimTime2 = 1833, hitAnimTime3 = 2066,hitAnimTime4 = 2399,hitEffShowOnce = 1,hitEff = {100821},hitEffType = {12},effectScale = {0.5},attackSound = 8203,hitSound = 21})

--83木吒
mapArray:push({ id = 83, remote = 0, moveDistance = 150,attackEff = {100831}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200, hitEff = { 3702},attackAnim = "attack",attackSound = 8301,hitSound = 22})
mapArray:push({ id = 830100, remote = 0,moveDistance = 100,attackEff = {100833}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 300, hitAnimTime2 = 800,hitAnimTime3 = 1200,hitEff = { 3702},attackSound = 8302,hitSound = 21})

--84莫邪
mapArray:push({ id = 84, remote = 0, moveDistance = 80,attackEff = {100841}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 250, hitEff = { 402},attackAnim = "attack",attackSound = 8401,hitSound = 31})
mapArray:push({ id = 840100, remote = 1,xuliEff = 100846,attackEff = {100843}, attackEffTime = {0},attackEffType = {1}, hitAnimTime1 = 800, hitAnimTime2 = 1200,hitAnimTime3 = 1500,hitEff = { 101044},attackSound = 8402,hitSound = 22})

--85神龟
mapArray:push({ id = 85, remote = 0, moveDistance = 100,attackEff = {0}, attackEffTime = {150}, attackEffType = {0},hitAnimTime1 = 200,hitAnimTime2 = 400,hitAnimTime3 = 620,hitAnimTime4 = 833, hitEff = {0},attackAnim = "attack",attackSound = 8501,hitSound = 31})
mapArray:push({ id = 850100, remote = 1,moveDistance = 100,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 1500,attackSound = 8503,hitSound = 8504})

--86愚公
mapArray:push({ id = 86, remote = 0, moveDistance = 80,attackEff = {100861}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 8601,hitSound = 32})
mapArray:push({ id = 860100, remote = 0,moveDistance = 100,attackEff = {100863}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800,hitEff = { 101022},attackSound = 8602,hitSound = 11})

--87三圣母
mapArray:push({ id = 87, remote = 1, moveDistance = 100,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 100871},hitAnimTime1 = 500,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 8701,hitSound = 8702})
mapArray:push({ id = 870100, remote = 1,moveDistance = 170,needMoveSameRow = 1,attackEff = {100872}, attackEffTime = {800}, attackEffType = {0}, hitAnimTime1 = 1300,hitEff = { 99992},attackAnim = "skill",attackSound = 8703,hitSound = 8704})

--88许仙
mapArray:push({ id = 88, remote = 1, attackEff = {0},attackEffTime = {0},attackEffType = {3}, hitAnimTime1 = 1000, hitEff = {100881,100882},attackAnim = "attack",attackSound = 2301,hitSound = 31})
mapArray:push({ id = 880100, remote = 1,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 500,hitAnimTime2 = 700, hitAnimTime3 = 1200,hitEffShowOnce = 1,hitEff = {100883},attackSound = 8004})

--89哈将陈奇
mapArray:push({ id = 89, remote = 0, moveDistance = 100,attackEff = {100891}, attackEffTime = {200}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 200,hitAnimTime2 = 600,attackAnim = "attack",attackSound = 8901,hitSound = 23})
mapArray:push({ id = 890100, remote = 0,moveDistance = 100,attackEff = {100893}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitAnimTime2 = 800,hitAnimTime3 = 1300,hitEff = { 101088},attackSound = 8902,hitSound = 22})

--90夸父
mapArray:push({ id = 90, remote = 0, moveDistance = 100,attackEff = {100901}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,hitAnimTime2 = 500,attackAnim = "attack",attackSound = 9001,hitSound = 22})
mapArray:push({ id = 900100, remote = 1,xuliEff = 100906,moveDistance = 100,flyEffRotate = 1,attackEff = {100903}, attackEffTime = {430}, attackEffType = {4}, hitAnimTime1 = 600, hitEff = { 101088},attackAnim = "skill2",attackSound = 9002,hitSound = 23})
mapArray:push({ id = 900102, remote = 1,moveDistance = 100,attackEff = {110903}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 950, hitAnimTime2 = 1100,hitAnimTime3 = 1500,hitEff = { 99991},attackAnim = "skill",attackSound = 9002,hitSound = 23})

--91孟婆
mapArray:push({ id = 91, remote = 0, moveDistance = 150,attackEff = {100911}, attackEffTime = {300}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 9101,hitSound = 21})
mapArray:push({ id = 910100, remote = 1,xuliEff = 100916,moveDistance = 250,attackEff = {100914}, attackEffType = {1},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitAnimTime2 = 1300,hitEff = { 99991},attackSound = 9102,hitSound = 12})

--94刑天
mapArray:push({ id = 94, remote = 0, moveDistance = 150,attackEff = {100941}, attackEffTime = {50}, attackEffType = {0},hitEff = { 402},hitAnimTime1 = 450,attackAnim = "attack",attackSound = 9401,hitSound = 21})
mapArray:push({ id = 940100, remote = 1,moveDistance = 250,attackEff = {100943}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitEff = { 0},attackSound = 9402,hitSound = 13})

--95九天玄女
mapArray:push({ id = 95, remote = 0, moveDistance = 200,attackEff = {100951}, attackEffTime = {50}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 9501,hitSound = 21})
mapArray:push({ id = 950100, remote = 0,moveDistance = 250,attackEff = {100953}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitEff = { 100955},attackSound = 9502,hitSound = 14})

--96荆轲
mapArray:push({ id = 96, remote = 0, moveDistance = 150,attackEff = {100961}, attackEffTime = {50}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 270,attackAnim = "attack",attackSound = 101,hitSound = 22})
mapArray:push({ id = 960100, remote = 0,moveDistance = 200,attackEff = {100963}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600,attackAnim = "skill2",hitEff = { 101044},attackSound = 9602,hitSound = 31})
mapArray:push({ id = 960102, remote = 1,moveDistance = 200,attackEff = {110963}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200,hitAnimTime2 = 500,hitAnimTime3 = 1000,hitEffShowOnce = 1,attackAnim = "skill",hitEff = {110964},attackSound = 9603,hitSound = 23})

--97祝英台
mapArray:push({ id = 97, remote = 0, moveDistance = 200,attackEff = {100971}, attackEffTime = {120}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 9701,hitSound = 23})
mapArray:push({ id = 970100, remote = 1,moveDistance = 150,attackEff = {100973}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800,hitEff = { 1000021},attackSound = 9702})
mapArray:push({ id = 970102, remote = 1,moveDistance = 150,attackEff = {100294}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitAnimTime2 = 800,hitAnimTime3 = 1000,hitEff = { 1000021},attackSound = 9702})

--98牛郎
mapArray:push({ id = 98, remote = 0, moveDistance = 150,attackEff = {100981}, attackEffTime = {50}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 270,attackAnim = "attack",attackSound = 9801,hitSound = 23})
mapArray:push({ id = 980100, remote = 1,moveDistance = 200,attackEff = {100983}, attackEffTime = {100}, attackEffType = {0}, hitAnimTime1 = 1300,hitAnimTime2 = 1600, hitEff = { 101055},attackSound = 9802,hitSound = 22})

--99马良
mapArray:push({ id = 99, remote = 0, moveDistance = 100,attackEff = {100991}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 200,hitAnimTime2 = 500,attackAnim = "attack",attackSound = 9901,hitSound = 41})
mapArray:push({ id = 990100, remote = 1,moveDistance = 0,xuliEff = 100996,needMoveCenter = 1,attackEff = {100993}, attackEffTime = {1}, attackEffType = {1}, hitAnimTime1 = 800,hitEff = { 0},attackSound = 9902,hitSound = 14})

--100牛头
mapArray:push({ id = 100, remote = 0, moveDistance = 120,attackEff = {101001}, attackEffTime = {120}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 10001,hitSound = 43})
mapArray:push({ id = 1000100, remote = 1,moveDistance = 150,attackEff = {101003}, attackEffTime = {100}, attackEffType = {0}, hitAnimTime1 = 1500, hitAnimTime2 = 2000,hitAnimTime3 = 2500,hitEff = { 99991},attackSound = 10002,hitSound = 14})

--101共工
mapArray:push({ id = 101, remote = 1, attackEff = {0}, attackEffTime = {50}, attackEffType = {0},hitEff = { 101011},effectScale = {1.5},hitEffShowOnce = 1,hitAnimTime1 = 800,hitAnimTime2 = 1100,hitEffType = {12},effectScale = {0.8},attackAnim = "attack",attackSound = 10101,hitSound = 10102})
mapArray:push({ id = 1010100, remote = 1,attackEff = {101012}, attackEffTime = {800}, attackEffType = {7}, hitAnimTime1 = 1200, hitAnimTime2 = 1700,hitAnimTime3 = 2200,hitEffShowOnce = 1,hitEff = { 0},attackSound = 10103,hitSound = 10104,shake = 5})

--102牡丹仙子
mapArray:push({ id = 102, remote = 1, attackEff = {0}, hitEff = { 101021},hitEffType = {12},effectScale = {0.5},hitAnimTime1 = 333,textAnimTime1=500,attackAnim = "attack",attackSound = 10201,hitSound = 10202})
mapArray:push({ id = 1020100, remote = 1,moveDistance = 250,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1800, textAnimTime1=300,attackAnim = "skill",hitEff = { 101023},hitEffType = {12},effectScale = {0.5},hitEffShowOnce = 1,attackSound = 10203,hitSound = 10204})

--103铁拐李
mapArray:push({ id = 103, remote = 1, moveDistance = 100,attackEff = {0}, attackEffTime = {80}, attackEffType = {0},hitEff = { 101031},hitAnimTime1 = 1150,textAnimTime1=100,hitAnimTime2=1400,hitEffType = {12},effectScale = {0.5},attackAnim = "attack",attackSound = 10301,hitSound = 10302})
mapArray:push({ id = 1030100, remote = 1,moveDistance = 100,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000,textAnimTime1=200, hitEffType = {12},effectScale = {0.5},hitEff = {101032},attackSound = 10303,hitSound = 10304})

--104白骨精
mapArray:push({ id = 104, remote = 0, moveDistance = 70,attackEff = {101041}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 200,hitAnimTime2 = 700,attackAnim = "attack",attackSound = 10401,hitSound = 21})
mapArray:push({ id = 1040100, remote = 1,xuliEff = 101046,attackEff = {101043}, attackEffTime = {350}, attackEffType = {3},attackEffType = {4}, hitAnimTime1 = 600, hitEff = { 101055},attackSound = 10402,hitSound = 21})

--106姥姥
mapArray:push({ id = 106, remote = 0, moveDistance = 180,attackEff = {101061}, attackEffTime = {50}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,hitAnimTime2 = 600,attackAnim = "attack",attackSound = 10601,hitSound = 22})
mapArray:push({ id = 1060100, remote = 1,moveDistance = 250,attackEff = {101063}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = { 0},attackSound = 10602,hitSound = 22})
mapArray:push({ id = 1060102, remote = 0,moveDistance = 250,attackEff = {101064}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitAnimTime2 = 800,hitEff = { 101088},attackSound = 10603,hitSound = 22})

--107宁采臣
mapArray:push({ id = 107, remote = 0, moveDistance = 300,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101071},hitAnimTime1 = 1033,hitEffType = {12},effectScale = {0.5},attackAnim = "attack",attackSound = 10701,hitSound = 10702})
mapArray:push({ id = 1070100, remote = 1,moveDistance = 150,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1533,hitEff = { 101072},hitEffType = {12},effectScale = {1.0},attackSound = 10703,hitSound = 12})

--108铁扇公主
mapArray:push({ id = 108, remote = 0, moveDistance = 150,attackEff = {101081}, attackEffTime = {0}, attackEffType = {0},hitEff = { 402},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 10801,hitSound = 22})
mapArray:push({ id = 1080100, remote = 0,moveDistance = 150,attackEff = {101083}, attackEffTime = {250}, attackEffType = {0}, hitAnimTime1 = 1700, hitAnimTime2 = 2000,hitEff = { 101044},attackSound = 10802,hitSound = 41})

--109李靖
mapArray:push({ id = 109, remote = 0, moveDistance = 120,attackEff = {101091}, attackEffTime = {50}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 10901,hitSound = 23})
mapArray:push({ id = 1090100, remote = 0,moveDistance = 250,attackEff = {101093}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000,hitEff = { 101022},attackSound = 800,hitSound = 11})

--110王母娘娘
mapArray:push({ id = 110, remote = 1, moveDistance = 140,attackEff = {0}, attackEffTime = {50}, attackEffType = {0},hitEff = { 101101},hitEffType = {12},effectScale = {0.5},hitEffShowOnce = 1,hitAnimTime1 = 550,hitAnimTime2 = 900,hitAnimTime3 = 1500,attackAnim = "attack",attackSound = 11001,hitSound = 11002})
mapArray:push({ id = 1100100, remote = 1,moveDistance = 150,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 900,hitAnimTime2 = 1300,hitAnimTime3 = 2100,hitEff = { 101102},hitEffType = {12},effectScale = {0.5},attackSound = 11003,hitSound = 11004})

--111河伯
mapArray:push({ id = 111, remote = 1, moveDistance = 100,attackEff = {0}, attackEffTime = {20}, attackEffType = {0},hitEff = { 101111},hitEffType = {12},effectScale = {0.6},hitAnimTime1 = 666,textAnimTime1=466,attackAnim = "attack",attackSound = 11101})
mapArray:push({ id = 1110100, remote = 1,moveDistance = 130,attackEff = {101112}, attackEffTime = {133}, attackEffType = {1}, hitAnimTime1 = 1600,textAnimTime1=200,hitAnimTime2 = 2000,textAnimTime2=300,hitAnimTime3 = 2500,textAnimTime3=300,hitEffShowOnce = 1,hitEff = { 0},hitEffType = {0},attackSound = 11103,hitSound = 11104})

--117马文才
mapArray:push({ id = 117, remote = 0, moveDistance = 250,attackEff = {101171},  attackEffTime = {300}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 11701,hitSound = 23})
mapArray:push({ id = 1170100, remote = 0, moveDistance = 250,attackEff = {101173}, attackEffTime = {500}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 3702},attackSound = 11702,hitSound = 22})

--123黑无常
mapArray:push({ id = 123, remote = 0, moveDistance = 80,attackEff = {10121}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 100,hitAnimTime2 = 400,attackAnim = "attack",attackSound = 12301,hitSound = 43})
mapArray:push({ id = 1230100, remote = 0, moveDistance = 80,attackEff = {101233}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 300, hitAnimTime2 = 600,hitAnimTime3 = 900,hitAnimTime4 = 1500,hitEff = { 101022},attackSound = 12302,hitSound = 43})

--124白无常
mapArray:push({ id = 124, remote = 0, moveDistance = 50,attackEff = {101241}, attackEffTime = {150}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 200,hitAnimTime2 = 400,attackAnim = "attack",attackSound = 12401,hitSound = 43})
mapArray:push({ id = 1240100, remote = 0, moveDistance = 80,attackEff = {101243}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitAnimTime2 = 500,hitAnimTime3 = 800,hitAnimTime4 = 1200,hitEff = { 1802},attackSound = 12402,hitSound = 41})

--126马面
mapArray:push({ id = 126, remote = 0, moveDistance = 150,attackEff = {101261}, attackEffTime = {100}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 450,attackAnim = "attack",attackSound = 12601,hitSound = 41})
mapArray:push({ id = 1260100, remote = 1, moveDistance = 80,attackEff = {101263}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 900,hitEff = { 0},attackSound = 12602})
mapArray:push({ id = 1260102, remote = 1, moveDistance = 80,attackEff = {101264}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 101055},attackAnim = "skill2",attackSound = 12603,hitSound = 11})

--138金炉童子
mapArray:push({ id = 138, remote = 0, moveDistance = 150,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 400,hitAnimTime2 = 900,attackAnim = "attack",attackSound = 13801,hitSound = 21})
mapArray:push({ id = 1380100, remote = 1, moveDistance = 250,attackEff = {0},attackEffTime = {5}, attackEffType = {0},  hitAnimTime1 = 800,hitAnimTime2 = 1100,hitAnimTime3 = 1500,hitAnimTime4 = 1900,hitEff = { 0},attackSound = 13803,hitSound = 13804})

--140银炉童子
mapArray:push({ id = 140, remote = 0, moveDistance = 150,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 400,hitAnimTime2 = 900,attackAnim = "attack",attackSound = 14001,hitSound = 21})
mapArray:push({ id = 1400100, remote = 1, moveDistance = 250,attackEff = {0},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800,hitAnimTime2 = 1100,hitAnimTime3 = 1500,hitAnimTime4 = 1900,hitEff = {0},attackSound = 14003,hitSound = 13804})

--141孟姜女
mapArray:push({ id = 141, remote = 0, moveDistance = 250,attackEff = {101411}, attackEffTime = {200}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 14101,hitSound = 32})
mapArray:push({ id = 1410100, remote = 0, moveDistance = 180,attackEff = {101413},attackEffTime = {200}, attackEffType = {0}, hitAnimTime1 = 450, hitAnimTime2 = 750,hitEff = { 99991},attackSound = 14102,hitSound = 32})

--145六耳猕猴
mapArray:push({ id = 145, remote = 0, moveDistance = 150,attackEff = {101451}, attackEffTime = {50}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 100,hitAnimTime2 = 700,attackAnim = "attack",attackSound = 14501,hitSound = 21})
mapArray:push({ id = 1450100, remote = 0, moveDistance = 200,attackEff = {101453},attackEffTime = {100}, attackEffType = {0}, hitAnimTime1 = 400,hitAnimTime2 = 800,hitAnimTime3 = 1500, hitEff = { 99991},attackSound = 14502,hitSound = 22})

--146小青
mapArray:push({ id = 146, remote = 0, moveDistance = 150,attackEff = {0}, attackEffOffsetY= {50},attackEffTime = {500}, attackEffType = {0},hitEff = { 91461},hitAnimTime1 = 400,hitAnimTime2 = 700,hitAnimTime3 = 1300,attackAnim = "attack",attackSound = 14601,hitSound = 14602})
mapArray:push({ id = 1460100, remote = 1, needMoveCenter = 1,xuliEff = 0,attackEff = {101461},attackEffTime = {1300}, attackEffType = {11}, hitAnimTime1 = 1300, hitEff = {0}, attackSound = 14603,hitSound = 14604})

--151申公豹
mapArray:push({ id = 151, remote = 0, moveDistance = 120,attackEff = {101511}, attackEffTime = {120}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 200,hitAnimTime2 = 500,hitAnimTime3 = 800,attackAnim = "attack",attackSound = 15101,hitSound = 23})
mapArray:push({ id = 1510100, remote = 1, moveDistance = 0,  attackEff = {101513},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1300, hitEff = { 101055},attackSound = 15102,hitSound = 15})

--156精卫
mapArray:push({ id = 156, remote = 0, moveDistance = 80,attackEff = {101561}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 600,attackAnim = "attack",hitEff = { 101564},attackSound = 101,hitSound = 43})
mapArray:push({ id = 1560100, remote = 1,moveDistance = 100,attackEff = {101563}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1200, hitEff = { 101564},attackSound = 202,hitSound = 41})

--157红孩儿
mapArray:push({ id = 1570100, remote = 1,moveDistance = 200,attackEff = {101573}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000,hitAnimTime2 = 1300,hitAnimTime3 = 1500, hitEff = { 101022},attackSound = 15702,hitSound = 13})
mapArray:push({ id = 157, remote = 0, moveDistance = 150,attackEff = {101571}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,hitAnimTime2 = 500,hitAnimTime3 = 900,attackAnim = "attack",attackSound = 15701,hitSound = 41})

--158东海龙王
mapArray:push({ id = 158, remote = 0, moveDistance = 170,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 433,hitAnimTime2 = 1100,hitEff = { 99992},effectScale = {2.0},hitEffOffsetY={ 20},attackAnim = "attack",attackSound = 15801,hitSound = 15802})
mapArray:push({ id = 1580100, remote = 1,moveDistance = 200,needMoveSameRow = 1,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1300, hitEff = { 0},attackSound = 15803,hitSound = 15804})

--159燕赤霞
mapArray:push({ id = 159, remote = 0, moveDistance = 220,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101591},hitAnimTime1 = 1500,attackAnim = "attack",attackSound = 15901,hitSound = 42})
mapArray:push({ id = 1590100, remote = 1,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 2500,hitEff = { 101592},hitEffType = {12},effectScale = {0.5},attackSoundTime=1500,attackSound = 15903,hitSound = 15904})

--161貔貅
mapArray:push({ id = 161, remote = 0, moveDistance = 100,attackEff = {101611}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 100,hitAnimTime2 = 800,attackAnim = "attack",attackSound = 16101,hitSound = 23})
mapArray:push({ id = 1610100, remote = 0,moveDistance = 250,attackEff = {101613}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800,hitAnimTime2 = 1100,hitAnimTime3 = 1500, hitEff = { 99991},attackSound = 16102,hitSound = 23})

--252女娲
mapArray:push({ id = 252, remote = 0, moveDistance = 160,attackEff = {0}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 366,hitAnimTime2 = 766,hitAnimTime3 = 1033,attackAnim = "attack",hitSound = 31})
mapArray:push({ id = 2520100, remote = 1,moveDistance = 0, shake = 10, attackEff = {102521},  attackEffTime = {1400}, attackEffType = {7},attackEffOffsetY= {80}, hitAnimTime1 = 1800,hitAnimTime2 = 2200,hitAnimTime3 = 2600, hitEffShowOnce = 1,hitEff = {0},attackAnim = "skill",attackSound = 25203,hitSound = 25204})
mapArray:push({ id = 2520101, remote = 1, moveDistance = 0,attackEff = {0}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 500,textAnimTime1=400,hitAnimTime2 = 1200,textAnimTime2=200,hitAnimTime3 = 1600,textAnimTime3=300,hitEff = { 92522},hitEffType = {12},attackAnim = "skill",attackSound = 25205,hitSound = 25206})

--273夏禹
mapArray:push({ id = 273, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 600,attackAnim = "attack",hitEff = { 0},attackSound = 27301,hitSound = 27302})
mapArray:push({ id = 2730100, remote = 1,moveDistance = 250, needMoveSameRow = 1,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1800, textAnimTime1=340, hitEff = {102731},hitEffType = {12},effectScale = {0.8},shake = 8,attackSound = 27303,hitSound = 27304})
mapArray:push({ id = 2730101, remote = 1,moveDistance = 0, attackEff = {0}, attackEffTime = {0}, attackEffType = {0} ,hitAnimTime1 = 1200,textAnimTime1=500, hitEff = { 102732},hitEffType = {12},effectScale = {0.7},attackAnim = "skill2",attackSound = 27305,hitSound = 27306})

--274炎帝
mapArray:push({ id = 274, remote = 0, moveDistance = 200,attackEff = {102741}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 200,hitAnimTime2 = 1000,attackAnim = "attack",hitEff = { 99991},hitSound = 2401})
mapArray:push({ id = 2740100, remote = 1,moveDistance = 0, attackEff = {102745}, xuliEff = 102743, xuliEffOffsetX = 25,attackEffTime = {1400}, attackEffType = {2}, attackEffOffsetX = {480},attackEffOffsetY = {150},hitAnimTime1 = 1600,hitAnimTime2 = 1800,hitAnimTime3 = 2000,hitSoundTime = 150, hitEff = { 102744},attackSoundTime= 500,attackSound = 27401,hitSound = 13,shake = 10})
mapArray:push({ id = 2740101, remote = 0,moveDistance = 180,attackEff = {112743}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 550, hitEff = { 101022},attackAnim = "skill2",hitSoundTime = 100,attackSound = 7802,hitSound = 42})
--275阎罗王
mapArray:push({ id = 275, remote = 0, moveDistance = 120,attackEff = {102751}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 500,hitAnimTime2 = 1000,attackAnim = "attack",hitEff = { 101055},attackSound = 2751})
mapArray:push({ id = 2750100, remote = 1,moveDistance = 0,attackEff = {102755}, xuliEff = 102753, attackEffTime = {1400}, attackEffType = {3}, attackEffOffsetY = {150}, hitAnimTime1 = 1650, hitEff = { 102754},attackSound = 27501})
mapArray:push({ id = 2750101, remote = 1,moveDistance = 0,attackEff = {112753}, attackEffTime = {270}, attackEffType = {0}, attackEffOffsetX = {60}, attackEffOffsetY = {0}, hitAnimTime1 = 300,hitAnimTime2 = 600, hitEff = { 1000021},attackAnim = "skill2",attackSound = 402,hitSound = 13})

--276沉香
mapArray:push({ id = 276, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 400,hitAnimTime2 = 1100,attackAnim = "attack",hitEff = { 0},attackSound = 27601,hitSound = 27603})
mapArray:push({ id = 2760100, remote = 1,moveDistance = 100,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1100,hitEffOffsetX={ 150},hitEffOffsetY={ 50},textAnimTime1 = 500, hitEff = { 102761},attackSound = 27601,attackSoundTime = 1000,attackAnim = "skill",hitSound = 27603, attackSound = 27602})

--277闻仲
mapArray:push({ id = 277, remote = 0, moveDistance = 120,attackEff = {102771}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 450,hitAnimTime2 = 860,attackAnim = "attack",hitSound = 32,attackSound = 2701})
mapArray:push({ id = 2770100, remote = 1,moveDistance = 0,attackEff = {102773}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 2500,hitEffShowOnce = 0, hitEff = { 102774},attackSoundTime= 100,attackSound = 27701})
mapArray:push({ id = 2770101, remote = 1,moveDistance = 0,attackEff = {112773}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = { 0},attackAnim = "skill2",attackSound = 202,hitSound = 13})

--278钟馗
mapArray:push({ id = 278, remote = 0, moveDistance = 120,attackEff = {102781}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 450,hitAnimTime2 = 1000,attackAnim = "attack",hitEffShowOnce =1,hitEff = { 102782},hitSound = 31})
mapArray:push({ id = 2780100, remote = 1,moveDistance = 0, attackEff = {102783}, attackEffType = {0}, attackEffTime = {0}, hitAnimTime1 = 1500, hitAnimTime2 = 1800,hitAnimTime3 = 2200,hitEffShowOnce = 1,hitEff = { 102784},attackSound = 27801,hitSound = 12,hitEffTime = {0}})
mapArray:push({ id = 2780101, remote = 1,moveDistance = 0, attackEff = {112785}, needMoveSameRow = 1,xuliEff = 112783, attackEffTime = {400}, attackEffType = {3} ,attackEffOffsetX = {130}, hitAnimTime1 = 600,hitEffOffsetY = {-50},hitEffOffsetX = {-10}, hitEff = { 112784},attackAnim = "skill2",attackSound = 27802,hitSound = 21})

--279神农
mapArray:push({ id = 279, remote = 0, moveDistance = 120,attackEff = {102791}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 400,attackAnim = "attack",hitEff = { 102792},hitEffTime = {100},attackSound = 2791})
mapArray:push({ id = 2790100, remote = 1,moveDistance = 0,attackEff = {102795, 102796,102797},xuliEff = 102793, attackEffTime = {100,80,1500}, attackEffType = {6,8,5}, hitAnimTime1 = 1500, hitAnimTime2 = 1900,hitAnimTime3 = 2300,hitEffShowOnce = 1, hitEff = { 102794, 102797} , hitEffType = {0,5},hitEffTime = {0},attackSoundTime = 400,attackSound = 27901, hitSound = 27902})
mapArray:push({ id = 2790101, remote = 1,moveDistance = 0,attackEff = {112793}, attackEffTime = {50}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = {112794,112795},hitEffType = {0,5} ,hitEffOffsetX = {-10},attackAnim = "skill2",attackSound = 2502, hitSound = 27904})

--280白泽
mapArray:push({ id = 280, remote = 0, moveDistance = 110,attackEff = {102801}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 250,hitAnimTime2 = 550,hitAnimTime3 =850,attackAnim = "attack",hitEff = { 0},hitEffTime = {0},hitSound = 21, attackSound = 0})--
mapArray:push({ id = 2800100, remote = 1,moveDistance = 0,attackEff = {102803}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, extraEffTime = {0,2050},hitEff = { 102804,102806},extraEff = { 0,102807 },extraEffType = {0},hitEffType = {0,5,0}, hitAnimTime1 = 750,hitEffOffsetX = {0,-15,-15}, hitEffOffsetY = {0,-8,0},hitEffTime = {0,0,2000},attackSound = 28001,hitSound = 0})
mapArray:push({ id = 2800101, remote = 1,moveDistance = 0,attackEff = {112803}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitEffOffsetX= {-20}, hitEff = {112804},attackAnim = "skill2",attackSound = 28002,attackSoundTime = 500,hitSound = 0})

--289后羿
mapArray:push({ id = 289, remote = 1, moveDistance = 300,attackEff = {0},needMoveSameRow = 1, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 1400,attackAnim = "attack",hitEff = { 0},hitEffTime = {0},attackSoundTime = 300,hitSound = 22, attackSound = 28901})
mapArray:push({ id = 2890100, remote = 1,moveDistance = 300,attackEff = {0}, needMoveSameRow = 1, attackEffTime = {400}, attackEffType = {0}, hitAnimTime1 = 1300, hitAnimTime2 = 1600,hitAnimTime3 = 1900, hitEff = {0},attackSound = 28902,hitSound = 22})
mapArray:push({ id = 2890101, remote = 0,moveDistance = 200,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitEff = {0},attackAnim = "skill2",hitEffTime = {0},attackSoundTime = 0,attackSound = 1702,hitSound = 22})


--290蚩尤
mapArray:push({ id = 290, remote = 0, moveDistance = 130,attackEff = {102901}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 400,hitAnimTime2 = 650,attackAnim = "attack",hitEffOffsetY = {0},hitEff = { 0},hitEffTime = {0},attackSoundTime = 0,hitSound = 21, attackSound = 2401,hitSound = 22})--
mapArray:push({ id = 2900100, remote = 1,moveDistance = 0,attackEff = {102903,102904}, attackEffTime = {0,1500}, attackEffType = {0,10}, attackEffOffsetY = {0,110}, attackEffOffsetX = {0,-350}, hitAnimTime1 = 1500 ,hitAnimTime2 = 2000 , hitAnimTime3 = 2300, hitEffShowOnce =1, hitEff = {0 }, hitEffType={0},attackSound = 29001,hitSound = 22})--
mapArray:push({ id = 2900101, remote = 0,moveDistance = 90,attackEff = {112903}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 550,hitAnimTime2 = 1550, hitEff = {0} , attackEffOffsetX = {-30} ,attackEffOffsetY = {-20} ,attackAnim = "skill2",attackSoundTime = 0,attackSound = 18202,hitSound = 22})

--295白素贞
mapArray:push({ id = 295, remote = 1, moveDistance = 110,attackEff = {0}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 600,attackAnim = "attack",hitEff = {102951},hitEffType = {12},effectScale = {0.8},hitEffTime = {0},hitSound = 29501, attackSound = 4402})
mapArray:push({ id = 2950100, remote = 1,moveDistance = 200,xuliEff = 0,attackEff = {102952},attackEffOffsetX= {260}, needMoveSameRow = 1, attackEffTime = {825}, attackEffType = {2}, hitAnimTime1 = 1400, hitEff = {102951},hitEffTime = {500},effectScale = {1.2,1.8,2.8},attackSound = 29502 ,attackSoundTime = 300,hitSound = 29501})
--被动技能
mapArray:push({ id = 2950101, remote = 1,moveDistance = 0,attackEff = {0}, attackEffTime = {0},hitEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = {102953},attackAnim = "skill3",attackSound = 0,hitSound = 29503})
-- mapArray:push({ id = 2950101, remote = 1,moveDistance = 0,attackEff = {0}, attackEffTime = {0},hitEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 0}, hitXuliEff = 102954,attackAnim = "skill2",attackSound = 0,hitSound = 12})

--296伏羲
mapArray:push({ id = 296, remote = 0, moveDistance = 110,attackEff = {102961}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 250,attackAnim = "attack",hitEff = { 0},hitEffTime = {0},hitSound = 1,hitSoundTime = 10,attackSound = 0})
mapArray:push({ id = 2960100, remote = 1, attackEff = {102964}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = {0}, attackSound = 29601})
mapArray:push({ id = 2960101, remote = 1, attackEff = {102967}, attackEffTime = {600}, attackEffType = {1},attackEffOffsetY= {100},hitEff = {0},attackAnim = "skill3",hitAnimTime1 = 1400, attackSound = 29602,hitSound = 12,hitEffShowOnce = 1})
mapArray:push({ id = 2960102, remote = 1,attackEff = {102968}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = {1029610},attackAnim = "skill2",attackSound = 2202,hitSound = 14})

--298太上老君
mapArray:push({ id = 298, remote = 1, moveDistance = 0,attackEff = {0}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 666,textAnimTime1=833,attackAnim = "attack",hitEff = { 102981},hitEffType={12},effectScale = {0.5},hitEffTime = {0},attackSound = 29801, hitSound = 0})
--技能攻击
mapArray:push({ id = 2980100, remote = 1,moveDistance = 0,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1133,textAnimTime1=200,attackAnim = "skill",hitEff = {102982},hitEffType={12},effectScale = {0.5},hitEffTime = {0},attackSound = 29803,hitSound = 29804})
--技能治疗
mapArray:push({ id = 2980102, remote = 1,moveDistance = 0,attackEff = {102983,102984,102985}, attackEffTime = {166,233,333}, attackEffType = {5,0,0}, hitAnimTime1 = 1433,textAnimTime1=300,  hitEff = {102986,102987,102988},hitEffType = {5,0,0},attackAnim = "skill2",attackSound = 29805,hitSound = 29806})
--被动技能
mapArray:push({ id = 2980101, remote = 1,moveDistance = 0,attackEff = {0}, attackEffTime = {0}, attackEffOffsetY= {0},attackEffType = {0}, attackAnim = "skill3",hitAnimTime1 = 800,textAnimTime1=400,hitEff = {102989},effectScale = {0.5},hitEffType={12},hitEffTime = {0},attackSound = 29807,hitSound = 29808})

--297黄帝
mapArray:push({ id = 297, remote = 0, moveDistance = 230,attackEff = {102971}, attackEffTime = {50},attackEffType = {0},hitAnimTime1 = 600,attackAnim = "attack",hitEffOffsetY = {0},hitEff = { 0},hitEffTime = {0},attackSoundTime = 0,hitSound = 42, attackSound = 6901})--
mapArray:push({ id = 2970100, remote = 1, attackEff = {102972,102973,102975}, attackEffTime = {0,0,3500}, attackEffType = {0,0,1},attackEffOffsetY = {0,0,70}, attackEffOffsetX = {0,0,105}, hitEff = {101022},hitAnimTime1 = 2700,hitAnimTime2 = 2800,hitAnimTime3 = 3500, attackSound = 29701,hitSound = 12,hitEffShowOnce = 1})
mapArray:push({ id = 2970101, remote = 0, moveDistance = 230,attackEff = {102976}, attackEffTime = {0}, attackEffType = {0},attackEffOffsetY = {0}, attackEffOffsetX = {0}, hitEff = {102974},hitEffOffsetY = {-20},attackAnim = "skill2",hitAnimTime1 = 800,hitAnimTime2 = 1400,attackSound = 102,hitSound = 12})


--怪物

--121持戒僧
mapArray:push({ id = 121, remote = 0,moveDistance = 240, attackEff = {0}, attackEffTime = {300}, attackEffType = {0},hitAnimTime1 = 1000,textAnimTime1 = 200,hitEff = { 100861},effectScale = {2.0},hitEffOffsetX={ -150},hitEffOffsetY={ 30},attackAnim = "attack",attackSound = 12101,hitSound = 12103})
mapArray:push({ id = 1210100, remote = 1, moveDistance = 0,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},attackAnim = "skill", hitAnimTime1 = 0, hitEff = { 0},attackSound = 12102,hitSound = 12104})
--mapArray:push({ id = 1210100, remote = 0,moveDistance = 160, attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1450,textAnimTime1 = 100, hitEff = { 100861},attackAnim = "skill",attackSound = 12102,hitSound = 21})

--122护寺僧
mapArray:push({ id = 122, remote = 0, moveDistance = 130,attackEff = {0}, attackEffTime = {300}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 800,attackAnim = "attack",attackSound = 12201,hitSound = 0})
mapArray:push({ id = 1220100, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {700}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 90003},effectScale = {1.5},hitEffOffsetY={35},attackAnim = "skill",attackSound = 12202,hitSound = 0})

--178持刀天兵
mapArray:push({ id = 178, remote = 0, moveDistance = 210,attackEff = {101783}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},effectScale = {2.5},hitEffOffsetY={ -120},hitEffOffsetX={ -20},hitAnimTime1 = 600,attackAnim = "attack",attackSound = 17801,hitSound = 22})
mapArray:push({ id = 1780100, remote = 0,moveDistance = 200,attackEff = {101781}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 420,hitAnimTime2 = 1000, hitEff = { 99992},effectScale = {2.0},hitEffOffsetY={ 20},attackSound = 17802,hitSound = 22})
--179持盾天兵
mapArray:push({ id = 179, remote = 0, moveDistance = 190,attackEff = {101791}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 550,attackAnim = "attack",attackSound = 17901,hitSound = 17902})
mapArray:push({ id = 1790100, remote = 0,moveDistance =190,attackEff = {101793}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 450,hitAnimTime2 = 900,hitAnimTime3 = 1650, hitEff = { 99991},attackSound = 17903,hitSound = 0})
--180双锤天兵
mapArray:push({ id = 180, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 1800100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})
--181粉衣仙女
mapArray:push({ id = 181, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 450,attackAnim = "attack",attackSound = 18101,hitSound = 33})
mapArray:push({ id = 1810100, remote = 0,moveDistance = 280,attackEff = {930612}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1350,hitAnimTime2 = 1550,hitAnimTime3 = 1950, hitEff = { 0},attackSound = 2,hitSound = 33})

--怪物
--3001虎贲勇士
mapArray:push({ id = 3001, remote = 0, moveDistance = 190,attackEff = {101791}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 550,attackAnim = "attack",attackSound = 17901,hitSound = 17902})
mapArray:push({ id = 30010100, remote = 0,moveDistance =190,attackEff = {101793}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 450,hitAnimTime2 = 900,hitAnimTime3 = 1650, hitEff = { 99991},attackSound = 17903,hitSound = 0})

--3011巨力天兵--
mapArray:push({ id = 3011, remote = 0, moveDistance = 190,attackEff = {130111}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 550,attackAnim = "attack",attackSound = 17901,hitSound = 17902})
mapArray:push({ id = 30110100, remote = 0,moveDistance =190,attackEff = {130112}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 450,hitAnimTime2 = 900,hitAnimTime3 = 1650, hitEff = { 99991},attackSound = 17903,hitSound = 0})

--3021无畏天兵--
mapArray:push({ id = 3021, remote = 0, moveDistance = 210,attackEff = {130211}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},effectScale = {2.5},hitEffOffsetY={ -120},hitEffOffsetX={ -20},hitAnimTime1 = 600,attackAnim = "attack",attackSound = 17801,hitSound = 22})
mapArray:push({ id = 30210100, remote = 0,moveDistance = 200,attackEff = {130212}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 420,hitAnimTime2 = 1000, hitEff = { 99992},effectScale = {2.0},hitEffOffsetY={ 20},attackSound = 17802,hitSound = 22})

--3031伏魔天兵
mapArray:push({ id = 3031, remote = 0, moveDistance = 210,attackEff = {101783}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},effectScale = {2.5},hitEffOffsetY={ -120},hitEffOffsetX={ -20},hitAnimTime1 = 600,attackAnim = "attack",attackSound = 17801,hitSound = 22})
mapArray:push({ id = 30310100, remote = 0,moveDistance = 200,attackEff = {101781}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 420,hitAnimTime2 = 1000, hitEff = { 99992},effectScale = {2.0},hitEffOffsetY={ 20},attackSound = 17802,hitSound = 22})

--3041天兵校尉
mapArray:push({ id = 3041, remote = 0, moveDistance = 210,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 400,hitAnimTime2 = 1233,hitEff = { 0},attackAnim = "attack",attackSound = 17801,hitSound = 304102})
mapArray:push({ id = 30410100, remote = 0,moveDistance = 200,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 733, hitEff = { 0},attackSoundTime=400,attackSound = 304103,hitSound = 304104})

--3051旌旗卫军
mapArray:push({ id = 3051, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 399,hitAnimTime2 = 1066,attackAnim = "attack",attackSound = 17801,hitSound = 305102})
mapArray:push({ id = 30510100, remote = 1,moveDistance = 0,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1366, hitEff = { 130511},hitEffType={12},effectScale = {0.5},attackSound = 305103,hitSound = 305104})

--3061唤风素女--
mapArray:push({ id = 3061, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 450,attackAnim = "attack",attackSound = 18101,hitSound = 33})
mapArray:push({ id = 30610100, remote = 0,moveDistance = 280,attackEff = {930612}, attackEffTime = {0}, attackEffType = {0}, hitEffShowOnce = 1,hitAnimTime1 = 1350,hitAnimTime2 = 1550,hitAnimTime3 = 1950, hitEff = { 0},attackSound = 2,hitSound = 33})

--3071白水青女
mapArray:push({ id = 3071, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 450,attackAnim = "attack",attackSound = 18101,hitSound = 33})
mapArray:push({ id = 30710100, remote = 0,moveDistance = 280,attackEff = {930612}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1350,hitAnimTime2 = 1550,hitAnimTime3 = 1950, hitEff = { 0},attackSound = 2,hitSound = 33})

--3081偃月天将
mapArray:push({ id = 3081, remote = 0, moveDistance = 210,attackEff = {101783}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},effectScale = {2.5},hitEffOffsetY={ -120},hitEffOffsetX={ -20},hitAnimTime1 = 600,attackAnim = "attack",attackSound = 17801,hitSound = 22})
mapArray:push({ id = 30810100, remote = 0,moveDistance = 200,attackEff = {101781}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 420,hitAnimTime2 = 1000, hitEff = { 99992},effectScale = {2.0},hitEffOffsetY={ 20},attackSound = 17802,hitSound = 22})

--3091巨灵天将--
mapArray:push({ id = 3091, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 30910100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3101利刃恶煞
mapArray:push({ id = 3101, remote = 0, moveDistance = 140,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 833,attackAnim = "attack",attackSound = 310101,hitSound = 310102})
mapArray:push({ id = 31010100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400,hitAnimTime2 = 1230,hitEff = { 0},attackSound = 310103,hitSound = 22})

--3111夜行煞
mapArray:push({ id = 3111, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 400,attackAnim = "attack",attackSoundTime=350, attackSound = 311101,hitSound = 21})
mapArray:push({ id = 31110100, remote = 1,moveDistance =0,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 766,textAnimTime1=400,hitEff = { 131111,131112},hitEffType={12,0},hitEffOffsetX={-180},effectScale={0.5},attackSound = 311103,hitSound = 311104})

--3121魔焰武士
mapArray:push({ id = 3121, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 31210100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3131陨火蛊师
mapArray:push({ id = 3131, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 31310100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3141青面巨怪
mapArray:push({ id = 3141, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 31410100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3151赤相巨怪
mapArray:push({ id = 3151, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 31510100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3161利爪魅妖
mapArray:push({ id = 3161, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 131611},hitAnimTime1 = 366,attackAnim = "attack",attackSound = 316101,hitSound = 23})
mapArray:push({ id = 31610100, remote = 1,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 800,hitAnimTime3 = 1100,hitEff = { 931612},hitEffOffsetY={ 50},effectScale = {2.0},hitEffShowOnce = 1,attackSound = 316103,hitSound = 316104})

--3171医蛊魔女
mapArray:push({ id = 3171, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 31710100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3181夜叉
mapArray:push({ id = 3181, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 31810100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3191罗刹
mapArray:push({ id = 3191, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 31910100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3201蓝鱼精
mapArray:push({ id = 3201, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 32010100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3211赤鱼精
mapArray:push({ id = 3211, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 32110100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3221魅惑蚌妖
mapArray:push({ id = 3221, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 32210100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3231渭水蚌仙
mapArray:push({ id = 3231, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 32310100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3241虾兵
mapArray:push({ id = 3241, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 32410100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3251蟹将
mapArray:push({ id = 3251, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 32510100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3301三尾狡狐
mapArray:push({ id = 3301, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 33010100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3311妩媚狐妖
mapArray:push({ id = 3311, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 33110100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3321巡天鸦
mapArray:push({ id = 3321, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 33210100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3321金乌
mapArray:push({ id = 3321, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 33210100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3331巨翅雕
mapArray:push({ id = 3331, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 33310100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3341幻咒蝶妖
mapArray:push({ id = 3341, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 33410100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3351彩蝶妖
mapArray:push({ id = 3351, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 33510100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3361金毛虎精
mapArray:push({ id = 3361, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 33610100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3371赤冠虎王
mapArray:push({ id = 3371, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 33710100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3381黑熊精
mapArray:push({ id = 3381, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 33810100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3391铁鬃熊精
mapArray:push({ id = 3391, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 33910100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3401怒焰冤魂
mapArray:push({ id = 3401, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 34010100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3411施咒冤魂
mapArray:push({ id = 3411, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 34110100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3421十恶亡魂
mapArray:push({ id = 3421, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 34210100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3431禁地亡魂
mapArray:push({ id = 3431, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 34310100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3441判官
mapArray:push({ id = 3441, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 350,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 18001,hitSound = 0})
mapArray:push({ id = 34410100, remote = 0,moveDistance =160,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 0},attackSound = 18002,hitSound = 0})

--3451护寺僧--
mapArray:push({ id = 3451, remote = 0, moveDistance = 130,attackEff = {0}, attackEffTime = {300}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 800,attackAnim = "attack",attackSound = 12201,hitSound = 0})
mapArray:push({ id = 34510100, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {700}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 90091},effectScale = {1.5},hitEffOffsetY={35},attackAnim = "skill",attackSound = 12202,hitSound = 0})

--3461苦修僧
mapArray:push({ id = 3461, remote = 0, moveDistance = 150,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = { 0},hitAnimTime1 = 800,attackAnim = "attack",attackSound = 346101,attackSoundTime=700,hitSound = 346102})
mapArray:push({ id = 34610100, remote = 1, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 900,hitEff = { 134611},hitEffType={12}, effectScale = {0.7},attackAnim = "skill",attackSound = 346103,attackSoundTime=700,hitSound = 346104})

--3471戒律僧
mapArray:push({ id = 3471, remote = 0, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 333,hitEff = { 934711},hitEffOffsetY={ 50},effectScale = {1.7},attackAnim = "attack",attackSound = 347101,attackSoundTime=500,hitSound = 31})
mapArray:push({ id = 34710100, remote = 0, moveDistance = 220,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 666,hitAnimTime2 = 866, hitEff = { 934712},hitEffOffsetY={ 50},effectScale = {2.0},attackAnim = "skill",attackSound = 347103,hitSound = 347104})

--3481持戒僧--
mapArray:push({ id = 3481, remote = 0,moveDistance = 240, attackEff = {0}, attackEffTime = {300}, attackEffType = {0},hitAnimTime1 = 1000,textAnimTime1 = 200,hitEff = { 934811},effectScale = {2.0},hitEffOffsetX={ -150},hitEffOffsetY={ 30},attackAnim = "attack",attackSound = 12101,hitSound = 12103})
mapArray:push({ id = 34810100, remote = 1, moveDistance = 0,attackEff = {134812,134811},attackEffOffsetX= {90}, attackEffTime = {100,1000}, attackEffType = {0,3},attackAnim = "skill", hitAnimTime1 = 1100, hitEff = { 134811},attackSound = 12102,hitSound = 12104})
mapArray:push({ id = 34810101, remote = 1, moveDistance = 0,attackEff = {134813}, attackEffTime = {100}, attackEffType = {0},attackAnim = "skill", hitAnimTime1 = 0, hitEff = { 0},attackSound = 12102,hitSound = 12104})






--伏魔录boss
--BOSS共工主动技能
mapArray:push({ id = 6000301, remote = 1, moveDistance = 230,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitEff = {102951},effectScale = {2.0},hitAnimTime1 = 800,attackAnim = "skill",attackSound = 15801,hitSound = 42})
--BOSS白素贞主动技能
mapArray:push({ id = 6000101, remote = 1,moveDistance = 200,xuliEff = 0,attackEff = {0},attackEffOffsetX= {260}, needMoveSameRow = 1, attackEffTime = {825}, attackEffType = {2}, hitAnimTime1 = 1400, hitEff = {102951},hitEffTime = {-500},effectScale = {1.2,1.8,2.8},attackSound = 29801 ,hitSound = 15})
--BOSS小青主动技能
mapArray:push({ id = 6000201, remote = 1, needMoveCenter = 1,xuliEff = 0,attackEff = {101461},attackEffTime = {1300}, attackEffType = {11}, hitAnimTime1 = 1300, hitEff = {0}, attackSound = 10802,hitSound = 13})



--第一版未用
--普通攻击
mapArray:push({ id = 9999, remote = 0, attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 100, hitEff = { 90001},attackAnim = "attack",attackSound = 101,hitSound = 1001})
mapArray:push({ id = 20, remote = 0, moveDistance = 150,attackEff = {100201}, attackEffTime = {220}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 2001,hitSound = 32})
mapArray:push({ id = 25, remote = 0, moveDistance = 150,attackEff = {100251}, attackEffTime = {350}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 400,attackAnim = "attack",attackAnim = "attack",attackSound = 2501,hitSound = 23})
mapArray:push({ id = 26, remote = 0, moveDistance = 200,attackEff = {100261}, attackEffTime = {200}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 2601,hitSound = 21})
mapArray:push({ id = 32, remote = 0, moveDistance = 150,attackEff = {100321}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 100,attackAnim = "attack",attackSound = 3201,hitSound = 23})
mapArray:push({ id = 33, remote = 0, moveDistance = 150,attackEff = {100331}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 500,attackAnim = "attack",attackSound = 3301,hitSound = 43})
mapArray:push({ id = 34, remote = 0, moveDistance = 150,attackEff = {100341}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 3401,hitSound = 33})
mapArray:push({ id = 36, remote = 0, moveDistance = 160,attackEff = {100361}, attackEffTime = {200}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 350,attackAnim = "attack",attackSound = 3601,hitSound = 22})
mapArray:push({ id = 37, remote = 0, moveDistance = 150,attackEff = {100371}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 350,hitEff = { 99992},attackAnim = "attack",attackSound = 3701,hitSound = 42})
mapArray:push({ id = 38, remote = 0, moveDistance = 160,attackEff = {100381}, attackEffTime = {100}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 3801,hitSound = 23})
mapArray:push({ id = 39, remote = 0, moveDistance = 100,attackEff = {100391}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99992},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 3901,hitSound = 22})
mapArray:push({ id = 40, remote = 0, moveDistance = 100,attackEff = {100401}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 150,hitEff = { 4002},attackAnim = "attack",attackSound = 4001,hitSound = 21})
mapArray:push({ id = 41, remote = 0, moveDistance = 100,attackEff = {100401}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 4002},attackAnim = "attack",attackSound = 4301,hitSound = 21})
mapArray:push({ id = 42, remote = 0, moveDistance = 100,attackEff = {100431}, attackEffTime = {50}, attackEffType = {0},hitAnimTime1 = 150,hitEff = { 4002},attackAnim = "attack",attackSound = 4301,hitSound = 22})
mapArray:push({ id = 43, remote = 0, moveDistance = 100,attackEff = {100431}, attackEffTime = {50}, attackEffType = {0},hitAnimTime1 = 150,hitEff = { 4002},attackAnim = "attack",attackSound = 4301,hitSound = 23})
mapArray:push({ id = 45, remote = 0, moveDistance = 150,attackEff = {100451}, attackEffTime = {330}, attackEffType = {0},hitEff = { 99992},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 4501,hitSound = 21})
mapArray:push({ id = 46, remote = 0, moveDistance = 150,attackEff = {100451}, attackEffTime = {330}, attackEffType = {0},hitEff = { 99992},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 4801,hitSound = 22})
mapArray:push({ id = 47, remote = 0, moveDistance = 150,attackEff = {100451}, attackEffTime = {330}, attackEffType = {0},hitEff = { 99992},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 4801,hitSound = 23})
mapArray:push({ id = 48, remote = 0, moveDistance = 150,attackEff = {100451}, attackEffTime = {330}, attackEffType = {0},hitEff = { 99992},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 4801,hitSound = 22})
mapArray:push({ id = 50, remote = 0, moveDistance = 220,attackEff = {100221}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99992},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 2201,hitSound = 22})
mapArray:push({ id = 51, remote = 0, moveDistance = 150,attackEff = {100511}, attackEffTime = {180}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 1701,hitSound = 41})
mapArray:push({ id = 56, remote = 0, moveDistance = 120,attackEff = {0},attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 60, hitEff = { 402},attackAnim = "attack",attackSound = 5501,hitSound = 22})
mapArray:push({ id = 57, remote = 0, moveDistance = 120,attackEff = {0},attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 60, hitEff = { 402},attackAnim = "attack",attackSound = 5501,hitSound = 23})
mapArray:push({ id = 52, remote = 0, moveDistance = 150,attackEff = {100511}, attackEffTime = {180}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 1701,hitSound = 42})
mapArray:push({ id = 53, remote = 0, moveDistance = 150,attackEff = {100511}, attackEffTime = {180}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 1701,hitSound = 43})
mapArray:push({ id = 54, remote = 0, moveDistance = 150,attackEff = {100511}, attackEffTime = {180}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 1701,hitSound = 42})
mapArray:push({ id = 55, remote = 0, moveDistance = 120,attackEff = {0},attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 100, hitEff = { 402},attackAnim = "attack",attackSound = 5501,hitSound = 21})
mapArray:push({ id = 58, remote = 0, moveDistance = 190,attackEff = {100581}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 5501,hitSound = 31})
mapArray:push({ id = 59, remote = 0, moveDistance = 190,attackEff = {100581}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 5501,hitSound = 32})
mapArray:push({ id = 60, remote = 0, moveDistance = 190,attackEff = {100581}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 5501,hitSound = 33})
mapArray:push({ id = 61, remote = 0, moveDistance = 150,attackEff = {100201}, attackEffTime = {300}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 17701,hitSound = 32})
mapArray:push({ id = 62, remote = 0, moveDistance = 100,attackEff = {100621}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 20501,hitSound = 42})
mapArray:push({ id = 63, remote = 0, moveDistance = 100,attackEff = {100621}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 20501,hitSound = 42})
mapArray:push({ id = 64, remote = 0, moveDistance = 100,attackEff = {100621}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 20501,hitSound = 42})
mapArray:push({ id = 65, remote = 0, moveDistance = 100,attackEff = {100621}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 20501,hitSound = 42})
mapArray:push({ id = 66, remote = 0, moveDistance = 100,attackEff = {100621}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 20501,hitSound = 42})
mapArray:push({ id = 68, remote = 0, moveDistance = 100,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 99991},attackAnim = "attack",attackSound = 6801,hitSound = 23})
mapArray:push({ id = 69, remote = 0, moveDistance = 160,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 7002},attackAnim = "attack",attackSound = 6901,hitSound = 23})
mapArray:push({ id = 70, remote = 0, moveDistance = 150,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 150,hitEff = { 99991},attackAnim = "attack",attackSound = 7001,hitSound = 32})
mapArray:push({ id = 71, remote = 0, moveDistance = 100,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 7002},attackAnim = "attack",attackSound = 6801,hitSound = 23})
mapArray:push({ id = 72, remote = 0, moveDistance = 160,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 99991},attackAnim = "attack",attackSound = 6901,hitSound = 23})
mapArray:push({ id = 73, remote = 0, moveDistance = 150,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 150,hitEff = { 7002},attackAnim = "attack",attackSound = 7001,hitSound = 33})
mapArray:push({ id = 74, remote = 0, moveDistance = 100,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 99991},attackAnim = "attack",attackSound = 6801,hitSound = 22})
mapArray:push({ id = 75, remote = 0, moveDistance = 160,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 7002},attackAnim = "attack",attackSound = 6901,hitSound = 22})
mapArray:push({ id = 76, remote = 0, moveDistance = 150,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 150,hitEff = { 99991},attackAnim = "attack",attackSound = 7001,hitSound = 33})
mapArray:push({ id = 92, remote = 0, moveDistance = 100,attackEff = {100921}, attackEffTime = {50}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 50,attackAnim = "attack",attackSound = 9201,hitSound = 22})
mapArray:push({ id = 93, remote = 0, moveDistance = 150,attackEff = {100931}, attackEffTime = {50}, attackEffType = {0},hitEff = {99992},hitAnimTime1 = 130,attackAnim = "attack",attackSound = 9301,hitSound = 23})
mapArray:push({ id = 105, remote = 0, moveDistance = 150,attackEff = {100921}, attackEffTime = {50}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 1,hitSound = 23})
mapArray:push({ id = 112, remote = 0, moveDistance = 30,attackEff = {100921}, attackEffTime = {50}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 1,hitSound = 21})
mapArray:push({ id = 113, remote = 0, moveDistance = 100,attackEff = {101131}, attackEffTime = {400}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 11301,hitSound = 42})
mapArray:push({ id = 114, remote = 0, moveDistance = 120,attackEff = {101141}, attackEffTime = {400}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 11401,hitSound = 21})
mapArray:push({ id = 115, remote = 0, moveDistance = 200,attackEff = {101151}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 11501,hitSound = 11})
mapArray:push({ id = 116, remote = 0, moveDistance = 80,attackEff = {101161},  attackEffTime = {300}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 350,attackAnim = "attack",attackSound = 11601,hitSound = 23})
mapArray:push({ id = 118, remote = 0, moveDistance = 100,attackEff = {101181},  attackEffTime = {250}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 350,attackAnim = "attack",attackSound = 11801,hitSound = 22})
mapArray:push({ id = 119, remote = 0, moveDistance = 150,attackEff = {101131}, attackEffTime = {400}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 11301,hitSound = 41})
mapArray:push({ id = 120, remote = 0, moveDistance = 80,attackEff = {101231},  attackEffTime = {200}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,hitAnimTime2 = 600,attackAnim = "attack",attackSound = 12001,hitSound = 42})
mapArray:push({ id = 125, remote = 0, moveDistance = 100,attackEff = {100391}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99992},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 3901,hitSound = 23})
mapArray:push({ id = 127, remote = 0, moveDistance = 80,attackEff = {101271}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 12701,hitSound = 22})
mapArray:push({ id = 128, remote = 0, moveDistance = 150,attackEff = {101281}, attackEffTime = {300}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 13001,hitSound = 11})
mapArray:push({ id = 129, remote = 0, moveDistance = 150,attackEff = {101281}, attackEffTime = {300}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 13001,hitSound = 12})
mapArray:push({ id = 130, remote = 0, moveDistance = 150,attackEff = {101301}, attackEffTime = {300}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 13001,hitSound = 43})
mapArray:push({ id = 131, remote = 0, moveDistance = 120,attackEff = {101311}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 50,attackAnim = "attack",attackSound = 13101,hitSound = 32})
mapArray:push({ id = 132, remote = 0, moveDistance = 120,attackEff = {101321}, attackEffTime = {350}, attackEffType = {0},hitEff = { 99992},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 13201,hitSound = 41})
mapArray:push({ id = 133, remote = 0, moveDistance = 180,attackEff = {101331}, attackEffTime = {100}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 101,hitSound = 32})
mapArray:push({ id = 134, remote = 0, moveDistance = 150,attackEff = {101341}, attackEffTime = {100}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,hitAnimTime2 = 500,attackAnim = "attack",attackSound = 13401,hitSound = 43})
mapArray:push({ id = 135, remote = 0, moveDistance = 120,attackEff = {101351}, attackEffTime = {10}, attackEffType = {0},hitEff = { 99992},hitAnimTime1 = 150,attackAnim = "attack",attackSound = 1,hitSound = 21})
mapArray:push({ id = 136, remote = 0, moveDistance = 200,attackEff = {101361}, attackEffTime = {20}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 500,attackAnim = "attack",attackSound = 13601,hitSound = 43})
mapArray:push({ id = 137, remote = 0, moveDistance = 150,attackEff = {101371}, attackEffTime = {200}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 13701,hitSound = 23})
mapArray:push({ id = 139, remote = 0, moveDistance = 150,attackEff = {101391}, attackEffTime = {200}, attackEffType = {0},hitEff = { 402},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 13901,hitSound = 31})
mapArray:push({ id = 142, remote = 0, moveDistance = 150,attackEff = {100931}, attackEffTime = {50}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 100,attackAnim = "attack",attackSound = 9301,hitSound = 21})
mapArray:push({ id = 143, remote = 0, moveDistance = 150,attackEff = {101431}, attackEffTime = {150}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 14301,hitSound = 21})
mapArray:push({ id = 144, remote = 0, moveDistance = 100,attackEff = {101441}, attackEffTime = {300}, attackEffType = {0},hitEff = { 99992},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 14401,hitSound = 32})
mapArray:push({ id = 147, remote = 0, moveDistance = 70,attackEff = {101471}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 14701,hitSound = 23})
mapArray:push({ id = 148, remote = 0, moveDistance = 100,attackEff = {101471}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 14701,hitSound = 23})
mapArray:push({ id = 149, remote = 0, moveDistance = 150,attackEff = {101491}, attackEffTime = {250}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 14901,hitSound = 33})
mapArray:push({ id = 150, remote = 0, moveDistance = 100,attackEff = {101501}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 15001,hitSound = 22})
mapArray:push({ id = 152, remote = 0, moveDistance = 160,attackEff = {102051}, attackEffTime = {0}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101,hitSound = 33})
mapArray:push({ id = 153, remote = 0, moveDistance = 160,attackEff = {102051}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101,hitSound = 33})
mapArray:push({ id = 154, remote = 0, moveDistance = 140,attackEff = {102051}, attackEffTime = {0}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101,hitSound = 33})
mapArray:push({ id = 155, remote = 0, moveDistance = 120,attackEff = {100231}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,hitAnimTime2 = 600,attackAnim = "attack",attackSound = 3001,hitSound = 43})
mapArray:push({ id = 160, remote = 0, moveDistance = 80,attackEff = {101601}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 16001,hitSound = 23})
mapArray:push({ id = 162, remote = 0, moveDistance = 120,attackEff = {101641}, attackEffTime = {15}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 16301,hitSound = 23})
mapArray:push({ id = 163, remote = 0, moveDistance = 120,attackEff = {101631}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 16301,hitSound = 33})
mapArray:push({ id = 164, remote = 0, moveDistance = 120,attackEff = {101641}, attackEffTime = {15}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 16401,hitSound = 33})
mapArray:push({ id = 165, remote = 0, moveDistance = 120,attackEff = {101651}, attackEffTime = {60}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 100,attackAnim = "attack",attackSound = 16501,hitSound = 32})
mapArray:push({ id = 166, remote = 0, moveDistance = 120,attackEff = {101661}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99992},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 16601,hitSound = 23})
mapArray:push({ id = 167, remote = 0, moveDistance = 120,attackEff = {101661}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 16601,hitSound = 31})
mapArray:push({ id = 168, remote = 0, moveDistance = 100,attackEff = {101681}, attackEffTime = {0}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 16801,hitSound = 23})
mapArray:push({ id = 169, remote = 0, moveDistance = 50,attackEff = {101471}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 14701,hitSound = 23})
mapArray:push({ id = 170, remote = 0, moveDistance = 40,attackEff = {101471}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 14701,hitSound = 43})
mapArray:push({ id = 171, remote = 0, moveDistance = 40,attackEff = {101471}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 14701,hitSound = 23})
mapArray:push({ id = 172, remote = 0, moveDistance = 40,attackEff = {101471}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 14701,hitSound = 23})
mapArray:push({ id = 173, remote = 0, moveDistance = 200,attackEff = {101651}, attackEffTime = {300}, attackEffType = {0},hitEff = { 99992},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 8701,hitSound = 42})
mapArray:push({ id = 174, remote = 0, moveDistance = 100,attackEff = {100401}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 4002},attackAnim = "attack",attackSound = 4301,hitSound = 23})
mapArray:push({ id = 175, remote = 0, moveDistance = 100,attackEff = {101211}, attackEffTime = {300}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101,hitSound = 23})
mapArray:push({ id = 176, remote = 0, moveDistance = 120,attackEff = {101311}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 50,hitAnimTime2 = 300,attackAnim = "attack",attackSound = 101,hitSound = 42})
mapArray:push({ id = 177, remote = 0, moveDistance = 150,attackEff = {100201}, attackEffTime = {300}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 17701,hitSound = 32})


mapArray:push({ id = 182, remote = 0, moveDistance = 120,attackEff = {101821}, attackEffTime = {400}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 18201,hitSound = 23})
mapArray:push({ id = 183, remote = 0, moveDistance = 120,attackEff = {101821}, attackEffTime = {400}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 18201})
mapArray:push({ id = 184, remote = 0, moveDistance = 120,attackEff = {101821}, attackEffTime = {400}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 18201})
mapArray:push({ id = 185, remote = 0, moveDistance = 80,attackEff = {101221}, attackEffTime = {300}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 186, remote = 0, moveDistance = 80,attackEff = {101221}, attackEffTime = {300}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 187, remote = 0, moveDistance = 80,attackEff = {101221}, attackEffTime = {300}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 188, remote = 0, moveDistance = 80,attackEff = {101221}, attackEffTime = {300}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 189, remote = 0, moveDistance = 100,attackEff = {4001}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 100,hitAnimTime2 = 400,hitEff = { 101892},attackAnim = "attack",attackSound = 18901,hitSound = 23})
mapArray:push({ id = 190, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 191, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 192, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 193, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 194, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 195, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 196, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 197, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 198, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 199, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 200, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 16601,hitSound = 23})
mapArray:push({ id = 201, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 202, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 203, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 204, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 205, remote = 0, moveDistance = 120,attackEff = {102051}, attackEffTime = {0}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackAnim = "attack",attackSound = 20501,hitSound = 31})
mapArray:push({ id = 206, remote = 0, moveDistance = 120,attackEff = {102051}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackAnim = "attack",attackSound = 20501,hitSound = 31})
mapArray:push({ id = 207, remote = 0, moveDistance = 120,attackEff = {102051}, attackEffTime = {0}, attackEffType = {0},hitEff = { 99991},hitAnimTime1 = 300,attackAnim = "attack",attackAnim = "attack",attackSound = 20501,hitSound = 31})
mapArray:push({ id = 208, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 209, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 210, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 211, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 212, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 213, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
mapArray:push({ id = 258, remote = 0, moveDistance = 120,attackEff = {25200}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 500,hitAnimTime2 = 1000,attackAnim = "attack",hitSound = 31})
mapArray:push({ id = 299, remote = 0, moveDistance = 230,attackEff = {102991}, attackEffTime = {50},attackEffType = {0},hitAnimTime1 = 250,hitAnimTime2 = 700,hitAnimTime3 = 1200,attackAnim = "attack",hitEffOffsetY = {0},hitEff = { 0},hitEffTime = {0},attackSoundTime = 0,hitSound = 21, attackSound = 0})--
mapArray:push({ id = 308, remote = 0, moveDistance = 120,attackEff = {103081}, attackEffTime = {50},attackEffType = {0},hitAnimTime1 = 600,hitAnimTime2 = 1050,attackAnim = "attack",hitEffOffsetY = {0},hitEff = { 0},hitEffTime = {0},attackSoundTime = 0,hitSound = 21, attackSound = 100101})--



--技能

mapArray:push({ id = 200100, remote = 0,moveDistance = 200,attackEff = {100203}, attackEffTime = {500}, attackEffType = {0}, hitAnimTime1 = 300, hitAnimTime2 = 500,hitAnimTime3 = 850,hitEff = { 200102}, attackSound = 2002,hitSound = 31})
mapArray:push({ id = 250100, remote = 1,moveDistance = 100,attackEff = {100294}, attackEffTime = {200}, attackEffType = {0}, hitAnimTime1 = 700, hitAnimTime2 = 900,hitAnimTime3 = 1200,hitEff = { 1000021},attackSound = 2502})
mapArray:push({ id = 260100, remote = 1,xuliEff = 100265, attackEff = {100263},attackEffTime ={850}, attackEffType = {3}, hitAnimTime1 = 1000, hitEff = { 260103},attackSound = 2602,hitSound = 42})
mapArray:push({ id = 320100, remote = 0,moveDistance = 150,attackEff = {100323}, attackEffTime = {0},attackEffType = {0}, hitAnimTime1 = 200,hitAnimTime2 = 400,hitAnimTime3 = 800,hitAnimTime4 = 1200, hitEff = {1802},attackSound = 3202,hitSound = 23})
mapArray:push({ id = 330100, remote = 0,moveDistance = 200,attackEff = {100333}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 900, hitEff = { 101044},attackSound = 3302,hitSound = 42})
mapArray:push({ id = 340100, remote = 1,attackEff = {100343}, attackEffTime = {200}, attackEffType = {0}, hitAnimTime1 = 1500, hitEff = { 99991},attackSound = 3402,hitSound = 32})
mapArray:push({ id = 360100, remote = 0,moveDistance = 200,attackEff = {100363}, attackEffTime = {300}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 402},attackSound = 3602,hitSound = 12})
mapArray:push({ id = 370100, remote = 1,xuliEff = 100375,attackEff = {100373}, attackEffOffsetX = {80},attackEffOffsetY = {220},attackEffTime = {1000}, attackEffType = {4}, hitAnimTime1 = 1300, hitEff = { 99992},attackSound = 3702,hitSound = 11})
mapArray:push({ id = 380100, remote = 0,moveDistance = 200,attackEff = {100383}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 101044},attackSound = 3802,hitSound = 21})
mapArray:push({ id = 390100, remote = 0,moveDistance = 150,attackEff = {100393}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = {99992},attackSound = 3902,hitSound = 21})
mapArray:push({ id = 400100, remote = 0,moveDistance = 80, attackEff = {100403}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 200,hitEff = {4002},hitAnimTime2= 500,hitAnimTime3 = 700,attackSound = 4002,hitSound = 12})
mapArray:push({ id = 410100, remote = 0,moveDistance = 100, attackEff = {100433}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 300,hitAnimTime2= 500,hitAnimTime3 = 900,attackSound = 4302,hitSound = 12})
mapArray:push({ id = 420100, remote = 0,moveDistance = 100, attackEff = {100433}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 300,hitAnimTime2= 500,hitAnimTime3 = 900,attackSound = 4302,hitSound = 12})
mapArray:push({ id = 430100, remote = 0,moveDistance = 100, attackEff = {100433}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 300,hitAnimTime2= 500,hitAnimTime3 = 900,attackSound = 4302,hitSound = 12})
mapArray:push({ id = 450100, remote = 0,moveDistance = 150,attackEff = {100453}, attackEffTime = {270}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 99991},attackSound = 4502,hitSound = 22})
mapArray:push({ id = 460100, remote = 0,moveDistance = 150,attackEff = {100453}, attackEffTime = {270}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 99991},attackSound = 4802,hitSound = 22})
mapArray:push({ id = 470100, remote = 0,moveDistance = 150,attackEff = {100453}, attackEffTime = {270}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 99991},attackSound = 4802,hitSound = 22})
mapArray:push({ id = 480100, remote = 0,moveDistance = 150,attackEff = {100453}, attackEffTime = {270}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 99991},attackSound = 4802,hitSound = 22})
mapArray:push({ id = 500100, remote = 1,attackEff = {100223}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 99992},attackSound = 2202,hitSound = 23})
mapArray:push({ id = 510100, remote = 1,attackEff = {100173}, attackEffTime = {400}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 99991},attackSound = 1702,hitSound = 13})
mapArray:push({ id = 520100, remote = 1,attackEff = {100173}, attackEffTime = {400}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 99991},attackSound = 1702,hitSound = 13})
mapArray:push({ id = 530100, remote = 1,attackEff = {100173}, attackEffTime = {400}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 99991},attackSound = 1702,hitSound = 13})
mapArray:push({ id = 540100, remote = 1,attackEff = {100173}, attackEffTime = {400}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 99991},attackSound = 1702,hitSound = 13})
mapArray:push({ id = 550100, remote = 1, xuliEff = 40101, attackEff = {40103},flyEffRotate =0,attackEffTime = {500}, attackEffType = {4}, hitAnimTime1 = 800, hitEff = { 402},attackSound = 5502,hitSound = 23})
mapArray:push({ id = 560100, remote = 1, xuliEff = 40101, attackEff = {40103},flyEffRotate =0,attackEffTime = {500}, attackEffType = {4}, hitAnimTime1 = 800, hitEff = { 402},attackSound = 5502,hitSound = 23})
mapArray:push({ id = 570100, remote = 1, xuliEff = 40101, attackEff = {40103},flyEffRotate =0,attackEffTime = {500}, attackEffType = {4}, hitAnimTime1 = 800, hitEff = { 402},attackSound = 5502,hitSound = 23})
mapArray:push({ id = 580100, remote = 0, moveDistance = 250,attackEff = {100583},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 101088},attackSound = 5502,hitSound = 31})
mapArray:push({ id = 590100, remote = 0, moveDistance = 250,attackEff = {100583},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 101088},attackSound = 5502,hitSound = 31})
mapArray:push({ id = 600100, remote = 0, moveDistance = 200,attackEff = {100583},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 101088},attackSound = 5502,hitSound = 31})
mapArray:push({ id = 610100, remote = 0,moveDistance = 200,attackEff = {100613}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 402},attackSound = 17702,hitSound = 22})
mapArray:push({ id = 620100, remote = 1,moveDistance = 100,attackEff = {100623}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 650, hitEff = { 101044},attackSound = 20502,hitSound = 13})
mapArray:push({ id = 630100, remote = 1,moveDistance = 100,attackEff = {100623}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 650, hitEff = { 101044},attackSound = 20502,hitSound = 13})
mapArray:push({ id = 640100, remote = 1,moveDistance = 100,attackEff = {100623}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 650, hitEff = { 101044},attackSound = 20502,hitSound = 13})
mapArray:push({ id = 650100, remote = 1,moveDistance = 100,attackEff = {100623}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 650, hitEff = { 101044},attackSound = 20502,hitSound = 13})
mapArray:push({ id = 660100, remote = 1,moveDistance = 100,attackEff = {100623}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 650, hitEff = { 101044},attackSound = 20502,hitSound = 13})
mapArray:push({ id = 670100, remote = 0,moveDistance = 20,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 0},attackSound = 202,hitSound = 11})
mapArray:push({ id = 680100, remote = 0,moveDistance = 70,attackEff = {100713}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 99991},attackSound = 6802,hitSound = 11})
mapArray:push({ id = 690100, remote = 0,moveDistance = 100,attackEff = {100723}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 402},attackSound = 6902,hitSound = 11})
mapArray:push({ id = 700100, remote = 0,moveDistance = 80,attackEff = {100733}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 101022},attackSound = 7002,hitSound = 11})
mapArray:push({ id = 710100, remote = 0,moveDistance = 70,attackEff = {100713}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 99991},attackSound = 6802,hitSound = 11})
mapArray:push({ id = 720100, remote = 0,moveDistance = 100,attackEff = {100723}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 402},attackSound = 6902,hitSound = 11})
mapArray:push({ id = 730100, remote = 0,moveDistance = 100,attackEff = {100733}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 101022},attackSound = 7002,hitSound = 11})
mapArray:push({ id = 740100, remote = 0,moveDistance = 70,attackEff = {100713}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 99991},attackSound = 6802,hitSound = 11})
mapArray:push({ id = 750100, remote = 0,moveDistance = 100,attackEff = {100723}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 402},attackSound = 6902,hitSound = 11})
mapArray:push({ id = 760100, remote = 0,moveDistance = 80,attackEff = {100733}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 101022},attackSound = 7002,hitSound = 11})
mapArray:push({ id = 920100, remote = 0,moveDistance = 150,attackEff = {100923}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitAnimTime2 = 400,hitAnimTime3 = 1200,hitEff = { 101044},attackSound = 9202,hitSound = 23})
mapArray:push({ id = 930100, remote = 0,moveDistance = 200,attackEff = {100933}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitAnimTime2 = 800,hitEff = {99992},attackSound = 9302,hitSound = 12})
mapArray:push({ id = 1050100, remote = 1,moveDistance = 150,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitEff = { 1000021},attackSound = 2})
mapArray:push({ id = 1120100, remote = 0,moveDistance = 130,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitAnimTime2 = 500,hitAnimTime3 = 800,hitEff = { 0},attackSound = 2})
mapArray:push({ id = 1130100, remote = 0,moveDistance = 130,attackEff = {101133}, attackEffTime = {500}, attackEffType = {0}, hitAnimTime1 = 500, hitAnimTime2 = 1200,hitAnimTime3 = 1600,hitEff = { 101022},attackSound = 11302,hitSound = 41})
mapArray:push({ id = 1140100, remote = 0, moveDistance = 100,attackEff = {101143}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600,hitEff = { 99992},attackSound = 11402,hitSound = 23})
mapArray:push({ id = 1150100, remote = 0, moveDistance = 200,attackEff = {101153}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200,hitAnimTime2 = 500,hitAnimTime3 = 1300,hitEff = { 101055},attackSound = 11502,hitSound = 12})
mapArray:push({ id = 1160100, remote = 0, moveDistance = 130,attackEff = {101163}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 550,hitEff = { 7002},attackSound = 11602,hitSound = 13,hitSound = 23})
mapArray:push({ id = 1180100, remote = 0, moveDistance = 230,attackEff = {101183}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1300, hitEff = { 402},attackSound = 11802,hitSound = 12})
mapArray:push({ id = 1190100, remote = 0,moveDistance = 130,attackEff = {101133}, attackEffTime = {500}, attackEffType = {0}, hitAnimTime1 = 500, hitAnimTime2 = 1200,hitAnimTime3 = 1600,hitEff = { 101022},attackSound = 11402,hitSound = 12})
mapArray:push({ id = 1200100, remote = 0, moveDistance = 130,attackEff = {101203}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitAnimTime2 = 1000,hitEff = { 101022},attackSound = 12002,hitSound = 14})
mapArray:push({ id = 1250100, remote = 0,moveDistance = 150,attackEff = {100393}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 99992},attackSound = 3902,hitSound = 15})
mapArray:push({ id = 1270100, remote = 1, moveDistance = 30,attackEff = {101273}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitEff = { 99992},attackSound = 12702})
mapArray:push({ id = 1280100, remote = 0, moveDistance = 180,attackEff = {101303}, attackEffTime = {500},attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 7002},attackSound = 13002,hitSound = 13})
mapArray:push({ id = 1290100, remote = 0, moveDistance = 180,attackEff = {101303}, attackEffTime = {500},attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 99991},attackSound = 13002,hitSound = 13})
mapArray:push({ id = 1300100, remote = 0, moveDistance = 180,attackEff = {101303}, attackEffTime = {500}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 7002},attackSound = 13002,hitSound = 43})
mapArray:push({ id = 1310100, remote = 0, moveDistance = 100,attackEff = {101313},attackEffTime = {700}, attackEffType = {0}, hitAnimTime1 = 750, hitEff = { 101055},attackSound = 13102,hitSound = 31})
mapArray:push({ id = 1320100, remote = 0, moveDistance = 100,attackEff = {101323},attackEffTime = {390}, attackEffType = {0}, hitAnimTime1 = 500,hitEff = { 99991},attackSound = 13202,hitSound = 42})
mapArray:push({ id = 1330100, remote = 0, moveDistance = 180,attackEff = {101333},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 700, hitEff = { 99991},attackSound = 202,hitSound = 14})
mapArray:push({ id = 1340100, remote = 0, moveDistance = 80,attackEff = {101343},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitEff = { 99991},attackSound = 13402,hitSound = 42})
mapArray:push({ id = 1340102, remote = 0, moveDistance = 280,attackEff = {111343},attackEffTime = {550}, attackEffType = {0},needMoveSameRow = 1, hitAnimTime1 =800, hitEff = { 111345},attackAnim = "skill2",attackSound = 13402,hitSound = 12})
mapArray:push({ id = 1350100, remote = 1, moveDistance = 250,attackEff = {111353},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 111354},attackSound = 13502,hitSound = 14})
mapArray:push({ id = 1360100, remote = 1,moveDistance = 300,needMoveCenter = 1,attackEff = {100303}, attackEffTime = {120}, attackEffType = {0}, hitAnimTime1 = 1500, hitEff = { 101022},attackSound = 13602,hitSound = 14})
mapArray:push({ id = 1365100, remote = 1,moveDistance = 300,needMoveCenter = 1,attackEff = {100303}, attackEffTime = {120}, attackEffType = {0}, hitAnimTime1 = 1500, hitEff = { 101022},attackSound = 13602,hitSound = 14})
mapArray:push({ id = 1370100, remote = 0, moveDistance = 100,attackEff = {101373},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 1802},attackSound = 13702,hitSound = 14})
mapArray:push({ id = 1390100, remote =1, moveDistance = 150,attackEff = {101393},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 800, hitAnimTime2 = 900,hitAnimTime3 = 1100,hitEff = {101044},attackSound = 13902,hitSound = 32})
mapArray:push({ id = 1420100, remote = 0, moveDistance = 250,attackEff = {100933}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitAnimTime2 = 700,hitAnimTime3 = 900,hitEff = { 101022},attackSound = 9302,hitSound = 14})
mapArray:push({ id = 1430100, remote = 0, moveDistance = 100,attackEff = {101433},attackEffTime = {80}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 1802},attackSound = 14302,hitSound = 41})
mapArray:push({ id = 1440100, remote = 0, moveDistance = 130,attackEff = {101443},attackEffTime = {200}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 99992},attackSound = 14402,hitSound = 32})
mapArray:push({ id = 1470100, remote = 0, moveDistance = 100,attackEff = {101473},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 700,hitEff = { 1802},attackSound = 14702,hitSound = 22})
mapArray:push({ id = 1480100, remote = 0,moveDistance = 100,attackEff = {101473},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 700,hitEff = { 1802},attackSound = 14702,hitSound = 14})
mapArray:push({ id = 1490100, remote = 0, moveDistance = 130,attackEff = {101493},attackEffTime = {30}, attackEffType = {0}, hitAnimTime1 = 900, hitEff = {402},attackSound = 14902,hitSound = 32})
mapArray:push({ id = 1500100, remote = 0, moveDistance = 130,attackEff = {101503},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 101055},attackSound = 15002,hitSound = 21})
mapArray:push({ id = 1515100, remote = 1, moveDistance = 0,  attackEff = {101513},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1300, hitEff = { 101055},attackSound = 15102,hitSound = 15})
mapArray:push({ id = 1520100, remote = 0,moveDistance = 100,attackEff = {102053}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 7002},attackSound = 202,hitSound = 15})
mapArray:push({ id = 1530100, remote = 0,moveDistance = 100,attackEff = {102053}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 99991},attackSound = 202,hitSound = 15})
mapArray:push({ id = 1540100, remote = 0,moveDistance = 100,attackEff = {102053}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 99991},attackSound = 202,hitSound = 15})
mapArray:push({ id = 1550100, remote = 1,moveDistance = 100,attackEff = {100233}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 1000, hitAnimTime3 = 1500,  hitEff = { 0},attackAnim = "skill2",attackSound = 2302,hitSound = 43})
mapArray:push({ id = 1550102, remote = 0,moveDistance = 100,attackEff = {100234}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 1000, hitAnimTime3 = 1500,  hitEff = { 101022},attackAnim = "skill1",attackSound = 2303,hitSound = 43})
mapArray:push({ id = 1600100, remote = 0,moveDistance = 100,attackEff = {101603}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400,hitAnimTime2 = 800, hitEff = { 99991},attackSound = 16002,hitSound = 23})
mapArray:push({ id = 1620100, remote = 0,moveDistance = 80,attackEff = {101633}, attackEffTime = {200}, attackEffType = {0}, hitAnimTime1 = 100,hitAnimTime2 = 400,hitAnimTime3 =650, hitEff = { 101022},attackSound = 16302,hitSound = 13})
mapArray:push({ id = 1630100, remote = 0,moveDistance = 80,attackEff = {101633}, attackEffTime = {200}, attackEffType = {0}, hitAnimTime1 = 100,hitAnimTime2 = 400,hitAnimTime3 =700,hitEff = {101022},attackSound = 16302,hitSound = 23})
mapArray:push({ id = 1640100, remote = 0,moveDistance = 80,attackEff = {101643}, attackEffTime = {350}, attackEffType = {0}, hitAnimTime1 = 400,hitAnimTime2 = 800,hitAnimTime3 = 1300, hitEff = { 101022},attackSound = 16402,hitSound = 13})
mapArray:push({ id = 1650100, remote = 0,moveDistance = 150,attackEff = {101653}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 99992},attackSound = 16502,hitSound = 33})
mapArray:push({ id = 1660100, remote = 0,moveDistance = 120,attackEff = {101663}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 99991},attackSound = 16602,hitSound = 23})
mapArray:push({ id = 1670100, remote = 0,moveDistance = 120,attackEff = {101663}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 99991},attackSound = 16602,hitSound = 13})
mapArray:push({ id = 1680100, remote = 0,moveDistance = 150,attackEff = {101683}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 99992},attackSound = 16802,hitSound = 23})
mapArray:push({ id = 1690100, remote = 0, moveDistance = 100,attackEff = {101473},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 800,hitEff = { 1802},attackSound = 14702,hitSound = 23})
mapArray:push({ id = 1700100, remote = 0, moveDistance = 100,attackEff = {101473},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 800,hitEff = { 1802},attackSound = 14702,hitSound = 43})
mapArray:push({ id = 1710100, remote = 0, moveDistance = 100,attackEff = {101473},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 800,hitEff = { 1802},attackSound = 14702,hitSound = 23})
mapArray:push({ id = 1720100, remote = 0, moveDistance = 100,attackEff = {101473},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 800,hitEff = { 1802},attackSound = 14702,hitSound = 23})
mapArray:push({ id = 1730100, remote = 0,moveDistance = 120,attackEff = {100873}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1300, hitEff = { 99991},attackSound = 8702,hitSound = 43})
mapArray:push({ id = 1740100, remote = 0,moveDistance = 80,attackEff = {100403}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 100,hitAnimTime2= 300,hitAnimTime3 = 500,hitAnimTime4 = 700,attackSound = 4302,hitSound = 23})
mapArray:push({ id = 1750100, remote = 0, moveDistance = 80,attackEff = {101213}, attackEffTime = {150}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 99992},attackSound = 202,hitSound = 23})
mapArray:push({ id = 1760100, remote = 0, moveDistance = 100,attackEff = {101313},attackEffTime = {800}, attackEffType = {0}, hitAnimTime1 = 800, hitEff = { 101055},attackSound = 202,hitSound = 43})
mapArray:push({ id = 1770100, remote = 0,moveDistance = 200,attackEff = {100613},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 402},attackSound = 17702,hitSound = 22})


mapArray:push({ id = 1820100, remote = 0,moveDistance = 110,attackEff = {101823}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 99991},attackSound = 18202,hitSound = 23})
mapArray:push({ id = 1830100, remote = 0,moveDistance = 110,attackEff = {101823}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 99991},attackSound = 18202,hitSound = 14})
mapArray:push({ id = 1840100, remote = 0,moveDistance = 110,attackEff = {101823}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 99991},attackSound = 18202,hitSound = 14})
mapArray:push({ id = 1850100, remote = 0, moveDistance = 50,attackEff = {101223}, attackEffTime = {700}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 4002},attackSound = 202,hitSound = 22})
mapArray:push({ id = 1860100, remote = 0, moveDistance = 50,attackEff = {101223}, attackEffTime = {700}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 4002},attackSound = 202,hitSound = 22})
mapArray:push({ id = 1870100, remote = 0, moveDistance = 50,attackEff = {101223}, attackEffTime = {700}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 4002},attackSound = 202,hitSound = 22})
mapArray:push({ id = 1880100, remote = 0, moveDistance = 50,attackEff = {101223}, attackEffTime = {700}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 4002},attackSound = 202,hitSound = 22})
mapArray:push({ id = 1890100, remote = 0,moveDistance = 80,attackEff = {101893}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 100,hitAnimTime2 = 600,hitAnimTime3 = 1000, hitEff = { 99991},attackSound = 18902,hitSound = 23})
mapArray:push({ id = 1900100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
mapArray:push({ id = 1910100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
mapArray:push({ id = 1920100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
mapArray:push({ id = 1930100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
mapArray:push({ id = 1940100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
mapArray:push({ id = 1950100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
mapArray:push({ id = 1960100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
mapArray:push({ id = 1970100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
mapArray:push({ id = 1980100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
mapArray:push({ id = 1990100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
mapArray:push({ id = 2000100, remote = 0,moveDistance = 120,attackEff = {101663}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 99992},attackSound = 16602,hitSound = 23})
mapArray:push({ id = 2010100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
mapArray:push({ id = 2020100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
mapArray:push({ id = 2030100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 12})
mapArray:push({ id = 2040100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 12})
mapArray:push({ id = 2050100, remote = 0,moveDistance = 80,attackEff = {102053}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 99991},attackSound = 20502,hitSound = 32})
mapArray:push({ id = 2060100, remote = 0,moveDistance = 80,attackEff = {102053}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 99991},attackSound = 20502,hitSound = 32})
mapArray:push({ id = 2070100, remote = 0,moveDistance = 80,attackEff = {102053}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 99991},attackSound = 20502,hitSound = 32})
mapArray:push({ id = 2080100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 12})
mapArray:push({ id = 2090100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 12})
mapArray:push({ id = 2100100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 12})
mapArray:push({ id = 2990100, remote = 1, attackEff = {102992}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = {0}, attackSound = 27901})
mapArray:push({ id = 2990101, remote = 1, attackEff = {102993,102994}, attackEffTime = {650}, attackEffType = {0},attackAnim = "skill2",hitAnimTime1 = 0,hitSoundTime = 650,hitSound = 28002})
mapArray:push({ id = 3080100, remote = 0,moveDistance = 35,attackEff = {103083}, attackEffTime = {0}, attackEffType = {0},attackEffOffsetY={0},attackEffOffsetX={0},hitAnimTime1= 500,hitAnimTime2 = 900,hitAnimTime3= 1300,hitAnimTime4= 1600, hitAnimTime5 = 2400,hitEffShowOnce = 1, hitEff = {0},hitEffTime ={2000,0},hitEffType={0},hitEffOffsetX={-310,-340},hitEffOffsetY={50,60},attackSound = 30801,hitSound = 0})--, hitAnimTime2 = 2200,hitAnimTime3 = 2500
mapArray:push({ id = 3080101, remote = 1,moveDistance = 0,attackEff = {113083}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0,hitAnimTime2 = 200,hitEffShowOnce = 1, hitEff = {113084},attackAnim = "skill2",attackSound = 30802,hitSound = 0})


--伏魔录boss
--mapArray:push({ id = 60003, remote = 0, moveDistance = 230,attackEff = {101581}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 15801,hitSound = 42})

--mapArray:push({ id = 2, remote = 0,moveDistance = 0,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = { 0},attackSound = 202,hitSound = 13})
--mapArray:push({ id = 1, remote = 0,moveDistance = 0,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = {0},attackAnim = "skill2",attackSound = 402,hitSound = 13})

return mapArray
--备份数据
-- local mapArray = MEMapArray:new()
-- 普通攻击
-- mapArray:push({ id = 9999, remote = 0, attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 100, hitEff = { 90001},attackAnim = "attack",attackSound = 101,hitSound = 1001})
-- mapArray:push({ id = 1, remote = 0, moveDistance = 70,attackEff = {100011}, attackEffTime = {0}, moveDistance = 200,attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 500,attackAnim = "attack",attackSound = 101,hitSound = 41})
-- mapArray:push({ id = 2, remote = 0, moveDistance = 100,attackEff = {100021}, attackEffTime = {100}, attackEffType = {0},hitAnimTime1 = 350,hitAnimTime2 = 650,hitEff = { 100022},attackAnim = "attack",attackSound = 201,hitSound = 41})
-- mapArray:push({ id = 3, remote = 0, moveDistance = 120,attackEff = {100031}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 350,attackAnim = "attack",attackSound = 301,hitSound = 41})
-- mapArray:push({ id = 4, remote = 0, moveDistance = 120,attackEff = {100041},attackEffTime = {300}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 300, attackAnim = "attack",attackSound = 401,hitSound = 22})
-- mapArray:push({ id = 5, remote = 0, moveDistance = 80,attackEff = {100051}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 450, hitEff = { 100052},attackSound = 501,hitSound = 32})
-- mapArray:push({ id = 6, remote = 0, moveDistance = 30,attackEff = {100061}, attackEffTime = {0}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 250,moveDistance = 170,attackAnim = "attack", attackSound = 601,hitSound = 43})
-- mapArray:push({ id = 7, remote = 0, moveDistance = 100,attackEff = {100071}, attackEffTime = {30}, attackEffType = {0},hitAnimTime1 = 200, hitEff = { 702},attackAnim = "attack",attackSound = 701,hitSound = 41})
-- mapArray:push({ id = 8, remote = 0, moveDistance = 140,attackEff = {100081}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 200, attackAnim = "attack",attackSound = 801,hitSound = 21})
-- mapArray:push({ id = 9, remote = 0, moveDistance = 130,attackEff = {100091}, attackEffTime = {700}, attackEffType = {0}, hitEff = { 101022},hitAnimTime1 = 800, attackAnim = "attack",attackSound = 901,hitSound = 42})
-- mapArray:push({ id = 10, remote = 0, attackEff = {100101}, attackEffTime = {0}, attackEffType = {0}, hitEff = { 101022},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 1001,hitSound = 23})
-- mapArray:push({ id = 11, remote = 0, moveDistance = 200, attackEff = {100111}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 101022},attackAnim = "attack",attackSound = 1101,hitSound = 21})
-- mapArray:push({ id = 12, remote = 0, moveDistance = 200, attackEff = {100121}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 101077},attackAnim = "attack",attackSound = 1201,hitSound = 41})
-- mapArray:push({ id = 13, remote = 0, moveDistance = 150,attackEff = {100131}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 300,hitAnimTime2 = 800,hitAnimTime3 = 1000, hitAnimTime4 = 1300,hitEff = { 101022},attackAnim = "attack",attackSound = 1301,hitSound = 22})
-- mapArray:push({ id = 14, remote = 0, moveDistance = 250, attackEff = {100141}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 100, hitEff = {101044},attackAnim = "attack",attackSound = 1401,hitSound = 32})
-- mapArray:push({ id = 15, remote = 0, moveDistance = 120,attackEff = {100151}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 200, hitEff = { 101088},hitEffOffsetX={ 0},hitEffOffsetY={ 0},attackAnim = "attack",attackSound = 1501,hitSound = 21})
-- mapArray:push({ id = 16, remote = 0, moveDistance = 120,attackEff = {100161}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 250, hitEff = { 101044},attackAnim = "attack",attackSound = 1601,hitSound = 23})
-- mapArray:push({ id = 17, remote = 0, moveDistance = 150,attackEff = {100171}, attackEffTime = {180}, attackEffType = {0},hitAnimTime1 = 200, hitEff = { 101022},attackAnim = "attack",attackSound = 1701,hitSound = 42})
-- mapArray:push({ id = 18, remote = 0, moveDistance = 150,attackEff = {100181}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 200, hitEff = { 1802},attackAnim = "attack",attackSound = 1801,hitSound = 43})
-- mapArray:push({ id = 19, remote = 0, moveDistance = 150,attackEff = {100191}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 200,hitAnimTime2 = 500,hitAnimTime3 = 900, hitEff = { 101055},attackAnim = "attack",attackSound = 1901,hitSound = 23})
-- mapArray:push({ id = 20, remote = 0, moveDistance = 150,attackEff = {100201}, attackEffTime = {220}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 2001,hitSound = 32})
-- mapArray:push({ id = 21, remote = 0, moveDistance = 150,attackEff = {100211}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 100212},attackAnim = "attack",attackSound = 2101,hitSound = 21})
-- mapArray:push({ id = 22, remote = 0, moveDistance = 200,attackEff = {100221}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 2201,hitSound = 22})
-- mapArray:push({ id = 23, remote = 0, moveDistance = 120,attackEff = {100231}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,hitAnimTime2 = 600,attackAnim = "attack",attackSound = 2301,hitSound = 42})
-- mapArray:push({ id = 24, remote = 0, moveDistance = 170,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 250,hitEff = { 101088},attackAnim = "attack",attackSound = 2401,hitSound = 33})
-- mapArray:push({ id = 25, remote = 0, moveDistance = 150,attackEff = {100251}, attackEffTime = {350}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 400,attackAnim = "attack",attackAnim = "attack",attackSound = 2501,hitSound = 23})
-- mapArray:push({ id = 26, remote = 0, moveDistance = 200,attackEff = {100261}, attackEffTime = {200}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 2601,hitSound = 21})
-- mapArray:push({ id = 27, remote = 0, moveDistance = 100,attackEff = {100271}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 2701,hitSound = 31})

-- mapArray:push({ id = 28, remote = 0, moveDistance = 150,attackEff = {100281}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 2801,hitSound = 42})
-- mapArray:push({ id = 29, remote = 0, moveDistance = 180,attackEff = {100291}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 350,attackAnim = "attack",attackSound = 2901,hitSound = 33})
-- mapArray:push({ id = 30, remote = 0, moveDistance = 150,attackEff = {101361}, attackEffTime = {20}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 500,attackAnim = "attack",attackSound = 3001,hitSound = 23})
-- mapArray:push({ id = 31, remote = 0, moveDistance = 100,attackEff = {100311}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 3101,hitSound = 42})

-- mapArray:push({ id = 32, remote = 0, moveDistance = 150,attackEff = {100321}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 100,attackAnim = "attack",attackSound = 3201,hitSound = 23})
-- mapArray:push({ id = 33, remote = 0, moveDistance = 150,attackEff = {100331}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 500,attackAnim = "attack",attackSound = 3301,hitSound = 43})
-- mapArray:push({ id = 34, remote = 0, moveDistance = 150,attackEff = {100341}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 3401,hitSound = 33})
-- mapArray:push({ id = 35, remote = 0, moveDistance = 100,attackEff = {100351}, attackEffTime = {0}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 150,hitAnimTime2 = 250,attackAnim = "attack",attackSound = 3501,hitSound = 23})

-- mapArray:push({ id = 36, remote = 0, moveDistance = 160,attackEff = {100361}, attackEffTime = {200}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 350,attackAnim = "attack",attackSound = 3601,hitSound = 22})
-- mapArray:push({ id = 37, remote = 0, moveDistance = 150,attackEff = {100371}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 350,hitEff = { 3702},attackAnim = "attack",attackSound = 3701,hitSound = 42})
-- mapArray:push({ id = 38, remote = 0, moveDistance = 160,attackEff = {100381}, attackEffTime = {100}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 3801,hitSound = 23})
-- mapArray:push({ id = 39, remote = 0, moveDistance = 100,attackEff = {100391}, attackEffTime = {0}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 3901,hitSound = 22})
-- mapArray:push({ id = 40, remote = 0, moveDistance = 100,attackEff = {100401}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 150,hitEff = { 4002},attackAnim = "attack",attackSound = 4001,hitSound = 21})
-- mapArray:push({ id = 41, remote = 0, moveDistance = 100,attackEff = {100401}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 4002},attackAnim = "attack",attackSound = 4301,hitSound = 21})
-- mapArray:push({ id = 42, remote = 0, moveDistance = 100,attackEff = {100431}, attackEffTime = {50}, attackEffType = {0},hitAnimTime1 = 150,hitEff = { 4002},attackAnim = "attack",attackSound = 4301,hitSound = 22})
-- mapArray:push({ id = 43, remote = 0, moveDistance = 100,attackEff = {100431}, attackEffTime = {50}, attackEffType = {0},hitAnimTime1 = 150,hitEff = { 4002},attackAnim = "attack",attackSound = 4301,hitSound = 23})

-- mapArray:push({ id = 44, remote = 0, moveDistance = 120,attackEff = {100441}, attackEffTime = {0}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 4401,hitSound = 42})
-- mapArray:push({ id = 45, remote = 0, moveDistance = 150,attackEff = {100451}, attackEffTime = {330}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 4501,hitSound = 21})
-- mapArray:push({ id = 46, remote = 0, moveDistance = 150,attackEff = {100451}, attackEffTime = {330}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 4801,hitSound = 22})
-- mapArray:push({ id = 47, remote = 0, moveDistance = 150,attackEff = {100451}, attackEffTime = {330}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 4801,hitSound = 23})
-- mapArray:push({ id = 48, remote = 0, moveDistance = 150,attackEff = {100451}, attackEffTime = {330}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 4801,hitSound = 22})
-- mapArray:push({ id = 49, remote = 0, moveDistance = 90,attackEff = {100041},attackEffTime = {500}, attackEffType = {0},hitAnimTime1 = 350, hitEff = { 100042},attackAnim = "attack",attackSound = 1,hitSound = 21})
-- mapArray:push({ id = 50, remote = 0, moveDistance = 220,attackEff = {100221}, attackEffTime = {0}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 2201,hitSound = 22})

-- mapArray:push({ id = 51, remote = 0, moveDistance = 150,attackEff = {100511}, attackEffTime = {180}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 1701,hitSound = 41})
-- mapArray:push({ id = 52, remote = 0, moveDistance = 150,attackEff = {100511}, attackEffTime = {180}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 1701,hitSound = 42})
-- mapArray:push({ id = 53, remote = 0, moveDistance = 150,attackEff = {100511}, attackEffTime = {180}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 1701,hitSound = 43})
-- mapArray:push({ id = 54, remote = 0, moveDistance = 150,attackEff = {100511}, attackEffTime = {180}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 1701,hitSound = 42})

-- mapArray:push({ id = 55, remote = 0, moveDistance = 120,attackEff = {0},attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 100, hitEff = { 402},attackAnim = "attack",attackSound = 5501,hitSound = 21})
-- mapArray:push({ id = 56, remote = 0, moveDistance = 120,attackEff = {0},attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 60, hitEff = { 402},attackAnim = "attack",attackSound = 5501,hitSound = 22})
-- mapArray:push({ id = 57, remote = 0, moveDistance = 120,attackEff = {0},attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 60, hitEff = { 402},attackAnim = "attack",attackSound = 5501,hitSound = 23})

-- mapArray:push({ id = 58, remote = 0, moveDistance = 190,attackEff = {100581}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 5501,hitSound = 31})
-- mapArray:push({ id = 59, remote = 0, moveDistance = 190,attackEff = {100581}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 5501,hitSound = 32})
-- mapArray:push({ id = 60, remote = 0, moveDistance = 190,attackEff = {100581}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 5501,hitSound = 33})

-- mapArray:push({ id = 61, remote = 0, moveDistance = 150,attackEff = {100201}, attackEffTime = {300}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 17701,hitSound = 32})

-- mapArray:push({ id = 62, remote = 0, moveDistance = 100,attackEff = {100621}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 20501,hitSound = 42})
-- mapArray:push({ id = 63, remote = 0, moveDistance = 100,attackEff = {100621}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 20501,hitSound = 42})
-- mapArray:push({ id = 64, remote = 0, moveDistance = 100,attackEff = {100621}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 20501,hitSound = 42})
-- mapArray:push({ id = 65, remote = 0, moveDistance = 100,attackEff = {100621}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 20501,hitSound = 42})
-- mapArray:push({ id = 66, remote = 0, moveDistance = 100,attackEff = {100621}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 20501,hitSound = 42})

-- mapArray:push({ id = 68, remote = 0, moveDistance = 100,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 8002},attackAnim = "attack",attackSound = 6801,hitSound = 23})
-- mapArray:push({ id = 69, remote = 0, moveDistance = 160,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 7002},attackAnim = "attack",attackSound = 6901,hitSound = 23})
-- mapArray:push({ id = 70, remote = 0, moveDistance = 150,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 150,hitEff = { 8002},attackAnim = "attack",attackSound = 7001,hitSound = 32})

-- mapArray:push({ id = 71, remote = 0, moveDistance = 100,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 7002},attackAnim = "attack",attackSound = 6801,hitSound = 23})
-- mapArray:push({ id = 72, remote = 0, moveDistance = 160,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 8002},attackAnim = "attack",attackSound = 6901,hitSound = 23})
-- mapArray:push({ id = 73, remote = 0, moveDistance = 150,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 150,hitEff = { 7002},attackAnim = "attack",attackSound = 7001,hitSound = 33})
-- mapArray:push({ id = 74, remote = 0, moveDistance = 100,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 8002},attackAnim = "attack",attackSound = 6801,hitSound = 22})
-- mapArray:push({ id = 75, remote = 0, moveDistance = 160,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 7002},attackAnim = "attack",attackSound = 6901,hitSound = 22})
-- mapArray:push({ id = 76, remote = 0, moveDistance = 150,attackEff = {100711}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 150,hitEff = { 8002},attackAnim = "attack",attackSound = 7001,hitSound = 33})

-- mapArray:push({ id = 77, remote = 0, moveDistance = 150,attackEff = {100771}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 230,attackAnim = "attack",hitEff = { 3702},attackAnim = "attack",attackSound = 7701,hitSound = 21})
-- mapArray:push({ id = 78, remote = 0, moveDistance = 150,attackEff = {100781}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 230,hitAnimTime2 = 700,hitEff = { 101088},attackAnim = "attack",attackSound = 7801,hitSound = 42})
-- mapArray:push({ id = 79, remote = 0, moveDistance = 150,attackEff = {100791}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 250,attackSound = 7901,hitSound = 23})
-- mapArray:push({ id = 80, remote = 0, moveDistance = 120,attackEff = {100801}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,hitAnimTime2 = 800, hitEff = { 8002},attackAnim = "attack",attackSound = 8001,hitSound = 32})

-- mapArray:push({ id = 81, remote = 0, moveDistance = 100,attackEff = {100811}, attackEffTime = {100}, attackEffType = {0},hitAnimTime1 = 600, hitEff = { 101088},attackAnim = "attack",attackSound = 8101,hitSound = 23})
-- mapArray:push({ id = 82, remote = 0, moveDistance = 150,attackEff = {100821}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 300,hitEff = { 8002},attackAnim = "attack",attackSound = 8201,hitSound = 21})
-- mapArray:push({ id = 83, remote = 0, moveDistance = 150,attackEff = {100831}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200, hitEff = { 3702},attackAnim = "attack",attackSound = 8301,hitSound = 22})
-- mapArray:push({ id = 84, remote = 0, moveDistance = 80,attackEff = {100841}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 250, hitEff = { 402},attackAnim = "attack",attackSound = 8401,hitSound = 31})
-- mapArray:push({ id = 85, remote = 0, moveDistance = 100,attackEff = {100851}, attackEffTime = {150}, attackEffType = {0},hitAnimTime1 = 350, hitEff = {101022},attackAnim = "attack",attackSound = 8501,hitSound = 22})
-- mapArray:push({ id = 86, remote = 0, moveDistance = 80,attackEff = {100861}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 8601,hitSound = 32})
-- mapArray:push({ id = 87, remote = 0, moveDistance = 100,attackEff = {100871}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 420,attackAnim = "attack",attackSound = 8701,hitSound = 31})
-- mapArray:push({ id = 88, remote = 0, moveDistance = 130,attackEff = {100881}, attackEffTime = {0}, attackEffType = {0},hitEff = { 402},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 12701,hitSound = 23})
-- mapArray:push({ id = 89, remote = 0, moveDistance = 100,attackEff = {100891}, attackEffTime = {200}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 200,hitAnimTime2 = 600,attackAnim = "attack",attackSound = 8901,hitSound = 23})
-- mapArray:push({ id = 90, remote = 0, moveDistance = 100,attackEff = {100901}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,hitAnimTime2 = 500,attackAnim = "attack",attackSound = 9001,hitSound = 22})
-- mapArray:push({ id = 91, remote = 0, moveDistance = 150,attackEff = {100911}, attackEffTime = {300}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 9101,hitSound = 21})
-- mapArray:push({ id = 92, remote = 0, moveDistance = 100,attackEff = {100921}, attackEffTime = {50}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 50,attackAnim = "attack",attackSound = 9201,hitSound = 22})
-- mapArray:push({ id = 93, remote = 0, moveDistance = 150,attackEff = {100931}, attackEffTime = {50}, attackEffType = {0},hitEff = {3702},hitAnimTime1 = 130,attackAnim = "attack",attackSound = 9301,hitSound = 23})
-- mapArray:push({ id = 94, remote = 0, moveDistance = 150,attackEff = {100941}, attackEffTime = {50}, attackEffType = {0},hitEff = { 402},hitAnimTime1 = 450,attackAnim = "attack",attackSound = 9401,hitSound = 21})
-- mapArray:push({ id = 95, remote = 0, moveDistance = 200,attackEff = {100951}, attackEffTime = {50}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 9501,hitSound = 21})
-- mapArray:push({ id = 96, remote = 0, moveDistance = 150,attackEff = {100961}, attackEffTime = {50}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 270,attackAnim = "attack",attackSound = 101,hitSound = 22})
-- mapArray:push({ id = 97, remote = 0, moveDistance = 200,attackEff = {100971}, attackEffTime = {120}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 9701,hitSound = 23})
-- mapArray:push({ id = 98, remote = 0, moveDistance = 150,attackEff = {100981}, attackEffTime = {50}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 270,attackAnim = "attack",attackSound = 9801,hitSound = 23})
-- mapArray:push({ id = 99, remote = 0, moveDistance = 100,attackEff = {100991}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 200,hitAnimTime2 = 500,attackAnim = "attack",attackSound = 9901,hitSound = 41})

-- mapArray:push({ id = 100, remote = 0, moveDistance = 120,attackEff = {101001}, attackEffTime = {120}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 10001,hitSound = 43})
-- mapArray:push({ id = 101, remote = 0, moveDistance = 100,attackEff = {101011}, attackEffTime = {50}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 300,hitAnimTime2 = 700,attackAnim = "attack",attackSound = 10101,hitSound = 43})

-- mapArray:push({ id = 102, remote = 0, moveDistance = 150,attackEff = {101021}, attackEffTime = {50}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 10201,hitSound = 22})
-- mapArray:push({ id = 103, remote = 0, moveDistance = 100,attackEff = {101031}, attackEffTime = {80}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 10301,hitSound = 43})
-- mapArray:push({ id = 104, remote = 0, moveDistance = 70,attackEff = {101041}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 200,hitAnimTime2 = 700,attackAnim = "attack",attackSound = 10401,hitSound = 21})
-- mapArray:push({ id = 105, remote = 0, moveDistance = 150,attackEff = {100921}, attackEffTime = {50}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 1,hitSound = 23})
-- mapArray:push({ id = 106, remote = 0, moveDistance = 180,attackEff = {101061}, attackEffTime = {50}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,hitAnimTime2 = 600,attackAnim = "attack",attackSound = 10601,hitSound = 22})
-- mapArray:push({ id = 107, remote = 0, moveDistance = 100,attackEff = {101071}, attackEffTime = {200}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 10701,hitSound = 21})
-- mapArray:push({ id = 108, remote = 0, moveDistance = 150,attackEff = {101081}, attackEffTime = {0}, attackEffType = {0},hitEff = { 402},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 10801,hitSound = 22})
-- mapArray:push({ id = 109, remote = 0, moveDistance = 120,attackEff = {101091}, attackEffTime = {50}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 10901,hitSound = 23})
-- mapArray:push({ id = 110, remote = 0, moveDistance = 140,attackEff = {101101}, attackEffTime = {50}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 400,hitAnimTime2 = 650,attackAnim = "attack",attackSound = 11001,hitSound = 21})
-- mapArray:push({ id = 111, remote = 0, moveDistance = 100,attackEff = {101111}, attackEffTime = {20}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 550,attackAnim = "attack",attackSound = 11101,hitSound = 42})
-- mapArray:push({ id = 112, remote = 0, moveDistance = 30,attackEff = {100921}, attackEffTime = {50}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 1,hitSound = 21})
-- mapArray:push({ id = 113, remote = 0, moveDistance = 100,attackEff = {101131}, attackEffTime = {400}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 11301,hitSound = 42})
-- mapArray:push({ id = 114, remote = 0, moveDistance = 120,attackEff = {101141}, attackEffTime = {400}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 11401,hitSound = 21})
-- mapArray:push({ id = 115, remote = 0, moveDistance = 200,attackEff = {101151}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 11501,hitSound = 11})
-- mapArray:push({ id = 116, remote = 0, moveDistance = 80,attackEff = {101161},  attackEffTime = {300}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 350,attackAnim = "attack",attackSound = 11601,hitSound = 23})
-- mapArray:push({ id = 117, remote = 0, moveDistance = 250,attackEff = {101171},  attackEffTime = {300}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 11701,hitSound = 23})
-- mapArray:push({ id = 118, remote = 0, moveDistance = 100,attackEff = {101181},  attackEffTime = {250}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 350,attackAnim = "attack",attackSound = 11801,hitSound = 22})
-- mapArray:push({ id = 119, remote = 0, moveDistance = 150,attackEff = {101131}, attackEffTime = {400}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 11301,hitSound = 41})
-- mapArray:push({ id = 120, remote = 0, moveDistance = 80,attackEff = {101231},  attackEffTime = {200}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,hitAnimTime2 = 600,attackAnim = "attack",attackSound = 12001,hitSound = 42})

-- mapArray:push({ id = 121, remote = 0, moveDistance = 100,attackEff = {101211}, attackEffTime = {300}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 12101,hitSound = 23})
-- mapArray:push({ id = 122, remote = 0, moveDistance = 80,attackEff = {101221}, attackEffTime = {300}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 12201,hitSound = 22})

-- mapArray:push({ id = 123, remote = 0, moveDistance = 80,attackEff = {10121}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 100,hitAnimTime2 = 400,attackAnim = "attack",attackSound = 12301,hitSound = 43})

-- mapArray:push({ id = 124, remote = 0, moveDistance = 50,attackEff = {101241}, attackEffTime = {150}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 200,hitAnimTime2 = 400,attackAnim = "attack",attackSound = 12401,hitSound = 43})
-- mapArray:push({ id = 125, remote = 0, moveDistance = 100,attackEff = {100391}, attackEffTime = {0}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 3901,hitSound = 23})
-- mapArray:push({ id = 126, remote = 0, moveDistance = 150,attackEff = {101261}, attackEffTime = {100}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 450,attackAnim = "attack",attackSound = 12601,hitSound = 41})
-- mapArray:push({ id = 127, remote = 0, moveDistance = 80,attackEff = {101271}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 12701,hitSound = 22})
-- mapArray:push({ id = 128, remote = 0, moveDistance = 150,attackEff = {101281}, attackEffTime = {300}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 13001,hitSound = 11})
-- mapArray:push({ id = 129, remote = 0, moveDistance = 150,attackEff = {101281}, attackEffTime = {300}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 13001,hitSound = 12})
-- mapArray:push({ id = 130, remote = 0, moveDistance = 150,attackEff = {101301}, attackEffTime = {300}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 13001,hitSound = 43})

-- mapArray:push({ id = 131, remote = 0, moveDistance = 120,attackEff = {101311}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 50,attackAnim = "attack",attackSound = 13101,hitSound = 32})
-- mapArray:push({ id = 132, remote = 0, moveDistance = 120,attackEff = {101321}, attackEffTime = {350}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 13201,hitSound = 41})
-- mapArray:push({ id = 133, remote = 0, moveDistance = 180,attackEff = {101331}, attackEffTime = {100}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 101,hitSound = 32})
-- mapArray:push({ id = 134, remote = 0, moveDistance = 150,attackEff = {101341}, attackEffTime = {100}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,hitAnimTime2 = 500,attackAnim = "attack",attackSound = 13401,hitSound = 43})
-- mapArray:push({ id = 135, remote = 0, moveDistance = 120,attackEff = {101351}, attackEffTime = {10}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 150,attackAnim = "attack",attackSound = 1,hitSound = 21})
-- mapArray:push({ id = 136, remote = 0, moveDistance = 200,attackEff = {101361}, attackEffTime = {20}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 500,attackAnim = "attack",attackSound = 13601,hitSound = 43})

-- mapArray:push({ id = 137, remote = 0, moveDistance = 150,attackEff = {101371}, attackEffTime = {200}, attackEffType = {0},hitEff = { 1802},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 13701,hitSound = 23})
-- mapArray:push({ id = 138, remote = 0, moveDistance = 200,attackEff = {101381}, attackEffTime = {100}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 13801,hitSound = 23})
-- mapArray:push({ id = 139, remote = 0, moveDistance = 150,attackEff = {101391}, attackEffTime = {200}, attackEffType = {0},hitEff = { 402},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 13901,hitSound = 31})
-- mapArray:push({ id = 140, remote = 0, moveDistance = 200,attackEff = {101401}, attackEffTime = {200}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 14001,hitSound = 21})
-- mapArray:push({ id = 141, remote = 0, moveDistance = 250,attackEff = {101411}, attackEffTime = {200}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 14101,hitSound = 32})
-- mapArray:push({ id = 142, remote = 0, moveDistance = 150,attackEff = {100931}, attackEffTime = {50}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 100,attackAnim = "attack",attackSound = 9301,hitSound = 21})

-- mapArray:push({ id = 143, remote = 0, moveDistance = 150,attackEff = {101431}, attackEffTime = {150}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 14301,hitSound = 21})
-- mapArray:push({ id = 144, remote = 0, moveDistance = 100,attackEff = {101441}, attackEffTime = {300}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 14401,hitSound = 32})
-- mapArray:push({ id = 145, remote = 0, moveDistance = 150,attackEff = {101451}, attackEffTime = {50}, attackEffType = {0},hitEff = { 101088},hitAnimTime1 = 100,hitAnimTime2 = 700,attackAnim = "attack",attackSound = 14501,hitSound = 21})
-- mapArray:push({ id = 146, remote = 0, moveDistance = 100,attackEff = {101461}, attackEffTime = {100}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,hitAnimTime2 = 500,attackAnim = "attack",attackSound = 14601,hitSound = 22})
-- mapArray:push({ id = 147, remote = 0, moveDistance = 70,attackEff = {101471}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 14701,hitSound = 23})
-- mapArray:push({ id = 148, remote = 0, moveDistance = 100,attackEff = {101471}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 14701,hitSound = 23})
-- mapArray:push({ id = 149, remote = 0, moveDistance = 150,attackEff = {101491}, attackEffTime = {250}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 14901,hitSound = 33})
-- mapArray:push({ id = 150, remote = 0, moveDistance = 100,attackEff = {101501}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 15001,hitSound = 22})
-- mapArray:push({ id = 151, remote = 0, moveDistance = 120,attackEff = {101511}, attackEffTime = {120}, attackEffType = {0},hitEff = { 101055},hitAnimTime1 = 200,hitAnimTime2 = 500,hitAnimTime3 = 800,attackAnim = "attack",attackSound = 15101,hitSound = 23})

-- mapArray:push({ id = 152, remote = 0, moveDistance = 160,attackEff = {102051}, attackEffTime = {0}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101,hitSound = 33})
-- mapArray:push({ id = 153, remote = 0, moveDistance = 160,attackEff = {102051}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101,hitSound = 33})
-- mapArray:push({ id = 154, remote = 0, moveDistance = 140,attackEff = {102051}, attackEffTime = {0}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101,hitSound = 33})
-- mapArray:push({ id = 155, remote = 0, moveDistance = 120,attackEff = {100231}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,hitAnimTime2 = 600,attackAnim = "attack",attackSound = 3001,hitSound = 43})
-- mapArray:push({ id = 156, remote = 0, moveDistance = 80,attackEff = {101561}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 600,attackAnim = "attack",hitEff = { 101564},attackSound = 101,hitSound = 43})
-- mapArray:push({ id = 157, remote = 0, moveDistance = 150,attackEff = {101571}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,hitAnimTime2 = 500,hitAnimTime3 = 900,attackAnim = "attack",attackSound = 15701,hitSound = 41})
-- mapArray:push({ id = 158, remote = 0, moveDistance = 170,attackEff = {101581}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 15801,hitSound = 42})
-- mapArray:push({ id = 159, remote = 0, moveDistance = 80,attackEff = {101591}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 300,hitAnimTime2 =500,attackAnim = "attack",attackSound = 15901,hitSound = 42})
-- mapArray:push({ id = 160, remote = 0, moveDistance = 80,attackEff = {101601}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 16001,hitSound = 23})
-- mapArray:push({ id = 161, remote = 0, moveDistance = 100,attackEff = {101611}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 100,hitAnimTime2 = 800,attackAnim = "attack",attackSound = 16101,hitSound = 23})
-- mapArray:push({ id = 162, remote = 0, moveDistance = 120,attackEff = {101641}, attackEffTime = {15}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 16301,hitSound = 23})
-- mapArray:push({ id = 163, remote = 0, moveDistance = 120,attackEff = {101631}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 16301,hitSound = 33})
-- mapArray:push({ id = 164, remote = 0, moveDistance = 120,attackEff = {101641}, attackEffTime = {15}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,hitAnimTime2 = 1000,attackAnim = "attack",attackSound = 16401,hitSound = 33})
-- mapArray:push({ id = 165, remote = 0, moveDistance = 120,attackEff = {101651}, attackEffTime = {60}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 100,attackAnim = "attack",attackSound = 16501,hitSound = 32})
-- mapArray:push({ id = 166, remote = 0, moveDistance = 120,attackEff = {101661}, attackEffTime = {0}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 16601,hitSound = 23})
-- mapArray:push({ id = 167, remote = 0, moveDistance = 120,attackEff = {101661}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 16601,hitSound = 31})
-- mapArray:push({ id = 168, remote = 0, moveDistance = 100,attackEff = {101681}, attackEffTime = {0}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 250,attackAnim = "attack",attackSound = 16801,hitSound = 23})
-- mapArray:push({ id = 169, remote = 0, moveDistance = 50,attackEff = {101471}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 14701,hitSound = 23})
-- mapArray:push({ id = 170, remote = 0, moveDistance = 40,attackEff = {101471}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 14701,hitSound = 43})
-- mapArray:push({ id = 171, remote = 0, moveDistance = 40,attackEff = {101471}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 14701,hitSound = 23})
-- mapArray:push({ id = 172, remote = 0, moveDistance = 40,attackEff = {101471}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 400,attackAnim = "attack",attackSound = 14701,hitSound = 23})
-- mapArray:push({ id = 173, remote = 0, moveDistance = 200,attackEff = {101651}, attackEffTime = {300}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 8701,hitSound = 42})
-- mapArray:push({ id = 174, remote = 0, moveDistance = 100,attackEff = {100401}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 200,hitEff = { 4002},attackAnim = "attack",attackSound = 4301,hitSound = 23})
-- mapArray:push({ id = 175, remote = 0, moveDistance = 100,attackEff = {101211}, attackEffTime = {300}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101,hitSound = 23})
-- mapArray:push({ id = 176, remote = 0, moveDistance = 120,attackEff = {101311}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 50,hitAnimTime2 = 300,attackAnim = "attack",attackSound = 101,hitSound = 42})
-- mapArray:push({ id = 177, remote = 0, moveDistance = 150,attackEff = {100201}, attackEffTime = {300}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 17701,hitSound = 32})
-- mapArray:push({ id = 178, remote = 0, moveDistance = 120,attackEff = {101783}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 17801,hitSound = 23})
-- mapArray:push({ id = 179, remote = 0, moveDistance = 120,attackEff = {101791}, attackEffTime = {150}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 17901,hitSound = 23})
-- mapArray:push({ id = 180, remote = 0, moveDistance = 120,attackEff = {101791}, attackEffTime = {150}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 17901,hitSound = 21})
-- mapArray:push({ id = 181, remote = 0, moveDistance = 120,attackEff = {101811}, attackEffTime = {0}, attackEffType = {0},hitEff = { 3702},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 18101,hitSound = 21})
-- mapArray:push({ id = 182, remote = 0, moveDistance = 120,attackEff = {101821}, attackEffTime = {400}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 18201,hitSound = 23})
-- mapArray:push({ id = 183, remote = 0, moveDistance = 120,attackEff = {101821}, attackEffTime = {400}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 18201})
-- mapArray:push({ id = 184, remote = 0, moveDistance = 120,attackEff = {101821}, attackEffTime = {400}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 18201})
-- mapArray:push({ id = 185, remote = 0, moveDistance = 80,attackEff = {101221}, attackEffTime = {300}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 186, remote = 0, moveDistance = 80,attackEff = {101221}, attackEffTime = {300}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 187, remote = 0, moveDistance = 80,attackEff = {101221}, attackEffTime = {300}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 188, remote = 0, moveDistance = 80,attackEff = {101221}, attackEffTime = {300}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 189, remote = 0, moveDistance = 100,attackEff = {4001}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 100,hitAnimTime2 = 400,hitEff = { 101892},attackAnim = "attack",attackSound = 18901,hitSound = 23})
-- mapArray:push({ id = 190, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 191, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 192, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 193, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 194, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 195, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 196, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 197, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 198, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 199, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 200, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 16601,hitSound = 23})
-- mapArray:push({ id = 201, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 202, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 203, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 204, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 205, remote = 0, moveDistance = 120,attackEff = {102051}, attackEffTime = {0}, attackEffType = {0},hitEff = { 7002},hitAnimTime1 = 300,attackAnim = "attack",attackAnim = "attack",attackSound = 20501,hitSound = 31})
-- mapArray:push({ id = 206, remote = 0, moveDistance = 120,attackEff = {102051}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackAnim = "attack",attackSound = 20501,hitSound = 31})
-- mapArray:push({ id = 207, remote = 0, moveDistance = 120,attackEff = {102051}, attackEffTime = {0}, attackEffType = {0},hitEff = { 8002},hitAnimTime1 = 300,attackAnim = "attack",attackAnim = "attack",attackSound = 20501,hitSound = 31})
-- mapArray:push({ id = 208, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 209, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 210, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 211, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 212, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})
-- mapArray:push({ id = 213, remote = 0, moveDistance = 120,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",attackSound = 101})

-- mapArray:push({ id = 252, remote = 0, moveDistance = 120,attackEff = {25200}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 500,hitAnimTime2 = 1000,attackAnim = "attack",hitSound = 31})
-- mapArray:push({ id = 258, remote = 0, moveDistance = 120,attackEff = {25200}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 500,hitAnimTime2 = 1000,attackAnim = "attack",hitSound = 31})


-- mapArray:push({ id = 274, remote = 0, moveDistance = 200,attackEff = {102741}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 200,hitAnimTime2 = 1000,attackAnim = "attack",hitEff = { 8002},hitSound = 2401})
-- mapArray:push({ id = 275, remote = 0, moveDistance = 120,attackEff = {102751}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 500,hitAnimTime2 = 1000,attackAnim = "attack",hitEff = { 101055},attackSound = 2751})
-- mapArray:push({ id = 276, remote = 0, moveDistance = 120,attackEff = {102761}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 400,hitAnimTime2 = 1100,attackAnim = "attack",hitEff = { 8002},attackSound = 2761})
-- mapArray:push({ id = 277, remote = 0, moveDistance = 120,attackEff = {102771}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 450,hitAnimTime2 = 860,attackAnim = "attack",hitSound = 32,attackSound = 2701})

-- mapArray:push({ id = 278, remote = 0, moveDistance = 120,attackEff = {102781}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 450,hitAnimTime2 = 1000,attackAnim = "attack",hitEffShowOnce =1,hitEff = { 102782},hitSound = 31})

-- mapArray:push({ id = 273, remote = 0, moveDistance = 100,attackEff = {102731}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 300,attackAnim = "attack",hitEff = { 102732},hitEffOffsetY = {70},hitEffOffsetX = {-40},attackSound = 8003})
-- mapArray:push({ id = 279, remote = 0, moveDistance = 120,attackEff = {102791}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 400,attackAnim = "attack",hitEff = { 102792},hitEffTime = {100},attackSound = 2791})--, hitSound = 21
-- mapArray:push({ id = 289, remote = 0, moveDistance = 180,attackEff = {102891}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 400,attackAnim = "attack",hitEffOffsetY = {-20},hitEff = { 102892},hitEffTime = {0},attackSoundTime = 0,hitSound = 22, attackSound = 2891})
-- mapArray:push({ id = 290, remote = 0, moveDistance = 130,attackEff = {102901}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 400,hitAnimTime2 = 650,attackAnim = "attack",hitEffOffsetY = {0},hitEff = { 0},hitEffTime = {0},attackSoundTime = 0,hitSound = 21, attackSound = 2401})--


-- --技能
-- mapArray:push({ id = 10100, remote = 1, attackEff = {100013}, attackEffTime = {100}, attackEffType = {0}, hitEff = { 101022},hitAnimTime1 = 2500,hitAnimTime2 = 2700,hitAnimTime3 = 2900, attackSound = 102,hitSound = 12})
-- mapArray:push({ id = 10102, remote = 0, moveDistance = 70,attackEff = {100011}, attackEffTime = {0}, moveDistance = 200,attackEffType = {0},hitAnimTime1 = 500,beforeMoveAnim = "drink",attackSound = 101,hitSound = 41})
-- mapArray:push({ id = 20100, remote = 1, attackEff = {100023}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1200, hitAnimTime2 = 1500,hitAnimTime3 = 1700,hitEff = { 100024}, attackSound = 202,hitSound = 13})
-- mapArray:push({ id = 30100, remote = 1, attackEff = {100033}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 550, hitEff = { 100034}, attackSound = 302})
-- mapArray:push({ id = 40100, remote = 1, xuliEff = 100043, attackEff = {0},attackEffTime = {500}, attackEffType = {4}, hitAnimTime1 = 1000, hitEff = { 1000021}, attackSound = 402})
-- mapArray:push({ id = 50100, remote = 1, xuliEff = 100056, attackEff = {100053}, flyEffRotate = 0,attackEffTime = {600}, attackEffType = {4}, hitAnimTime1 = 800,  hitAnimTime2 = 1000,  hitAnimTime3 = 1200, hitEffShowOnce = 1,hitEff = { 100054},attackSound = 502,hitSound = 11})
-- mapArray:push({ id = 60100, remote = 1, attackEff = {100063}, attackEffTime = {200}, attackEffType = {0}, hitEff = { 101044},hitAnimTime1 = 1000,attackSound = 602,hitSound = 12})
-- mapArray:push({ id = 70100, remote = 1, moveDistance = 0,attackEff = {100073}, attackEffTime = {0}, attackEffType = {0},attackAnim = "skill", hitAnimTime1 = 0, hitEff = { 0},attackSound = 702,hitSound = 0})
-- mapArray:push({ id = 70102, remote = 0, moveDistance = 170,attackEff = {110073}, attackEffTime = {0}, attackEffType = {0},attackAnim = "skill2", hitAnimTime1 = 400, hitEff = { 101022},attackSound = 703,hitSound = 13})
-- mapArray:push({ id = 80100, remote = 1, attackEff = {100083},  attackEffTime = {0}, attackEffType = {2}, hitAnimTime1 = 600, hitAnimTime2 = 900,hitEff = { 100084},attackSound = 802,hitSound = 14})
-- mapArray:push({ id = 90100, remote = 1, attackEff = {100093}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1100, hitEff = { 100094},attackSound = 902,hitSound = 12})
-- mapArray:push({ id = 100100, remote = 1, attackEff = {100103}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1800, hitAnimTime2 = 1900,hitAnimTime3 = 2100,hitEff = { 101088},attackSound = 1002,hitSound = 33})
-- mapArray:push({ id = 100102, remote = 0, moveDistance = 100,attackEff = {110103},  needMoveSameRow = 1,attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 101055},attackAnim = "skill2",attackSound = 1002,hitSound = 13})

-- mapArray:push({ id = 110100, remote = 0,moveDistance = 180,attackEff = {100113}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitAnimTime2 = 1200,hitAnimTime3 = 1600,hitEff = { 101077},attackSound = 1102,hitSound = 22})

-- mapArray:push({ id = 120100, remote = 0,moveDistance = 210,attackEff = {100123}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1500, hitAnimTime2 = 1800,hitAnimTime3 = 2000,hitAnimTime4 = 2700,hitEff = { 101077},attackSound = 1202,hitSound = 42})
-- mapArray:push({ id = 120101, remote = 0,moveDistance = 210,attackEff = {100125}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1500, hitEffShowOnce = 1, hitEff = { 100124},attackSound = 1202,hitSound = 42})
-- mapArray:push({ id = 120102, remote = 0,moveDistance = 210,attackEff = {100125}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1= 1400, hitAnimTime2 = 1700,hitAnimTime3= 1900, hitAnimTime4= 2600, hitEffShowOnce = 1, hitEff = {0},hitEffType={0},hitEff = { 100124 },attackSound = 1202,hitSound = 42})--, hitAnimTime2 = 2200,hitAnimTime3 = 2500


-- mapArray:push({ id = 130100, remote = 1,moveDistance = 250,attackEff = {100133}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 0},attackSound = 1302,hitSound = 23})
-- mapArray:push({ id = 140100, remote = 1,attackEff = {100143}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000,hitEff = { 1802},attackSound = 1402,hitSound = 14})
-- mapArray:push({ id = 140102, remote = 1,xuliEff = 140110,attackEff = {140111}, attackEffTime = {0}, needMoveSameRow = 1,attackEffType = {3}, hitAnimTime1 = 500,hitEff = { 140112},attackSound = 1402,hitSound = 14})
-- mapArray:push({ id = 140102, remote = 1,xuliEff = 140110,attackEff = {140111}, attackEffTime = {0}, needMoveSameRow = 1,attackEffType = {3}, hitAnimTime1 = 500,hitEff = { 140112},attackSound = 1402,hitSound = 14})

-- mapArray:push({ id = 150100, remote = 1, xuliEff = 100156, attackEff = {100153},flyEffRotate = 1,attackEffTime = {600},attackEffOffsetY= {0}, attackEffType = {3}, hitAnimTime1 = 800, hitEff = {101088},attackSound = 1502,hitSound = 23})
-- mapArray:push({ id = 160100, remote = 1,xuliEff = 100166,attackEff = {100163}, flyEffRotate = 3,attackEffType = {4},attackEffTime = {1000}, hitAnimTime1 = 1200, hitEff = { 100164},attackSound = 1702,hitSound = 21})
-- mapArray:push({ id = 170100, remote = 1,attackEff = {100173}, attackEffTime = {10}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 101088},attackSound = 1702,hitSound = 12})
-- mapArray:push({ id = 180100, remote = 1, moveDistance = 180,attackEff = {180101}, attackEffTime = {0}, attackEffType = {0},hitEff = {0},hitAnimTime1 = 900,attackSound = 1802,hitSound = 13})
-- mapArray:push({ id = 190100, remote = 1,xuliEff = 100196, moveDistance = 180,attackEff = {0}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 1500,hitAnimTime2 = 1800,hitAnimTime3 = 2200,hitEff = { 100194},attackSound = 1902,hitSound = 15})
-- mapArray:push({ id = 200100, remote = 0,moveDistance = 200,attackEff = {100203}, attackEffTime = {500}, attackEffType = {0}, hitAnimTime1 = 300, hitAnimTime2 = 500,hitAnimTime3 = 850,hitEff = { 200102}, attackSound = 2002,hitSound = 31})

-- mapArray:push({ id = 210100, remote = 1,moveDistance = 0,attackEff = {110213}, needMoveSameRow = 1,attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 101055}, attackAnimMove = 1, attackSound = 2102,hitSound = 21})
-- mapArray:push({ id = 210102, remote = 1,moveDistance = 0,needMoveCenter = 1,attackEff = {100213}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 300,hitEff = { 101055}, hitAnimTime2 = 900, hitAnimTime3 = 1400, attackAnim = "skill2",attackAnimMove = 1, attackSound = 2102,hitSound = 23})

-- mapArray:push({ id = 220100, remote = 1,attackEff = {100223}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 8002},attackSound = 2202,hitSound = 14})
-- mapArray:push({ id = 220102, remote = 1,attackEff = {110223}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600,hitEff = { 0},attackAnim = "skill2",hitEff = { 110224},attackSound = 2202})

-- mapArray:push({ id = 230100, remote = 1,moveDistance = 100,attackEff = {100233}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 1000, hitAnimTime3 = 1500,  hitEff = { 0},attackAnim = "skill2",attackSound = 2302,hitSound = 43})
-- mapArray:push({ id = 230102, remote = 0,moveDistance = 100,attackEff = {100234}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 1000, hitAnimTime3 = 1500,  hitEff = { 101022},attackAnim = "skill1",attackSound = 2303,hitSound = 43})
-- mapArray:push({ id = 240100, remote = 0,moveDistance = 200,attackEff = {100243}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 700,hitAnimTime2 = 1200,hitAnimTime3 = 1700,hitEff = { 100244},attackSound = 2402,hitSound = 21})
-- mapArray:push({ id = 240102, remote = 1,xuliEff = 110246,xuliEffTime = 200,attackEff = {110243}, attackEffType = {3},attackEffTime = {550}, attackEffOffsetX= {0},attackEffOffsetY= {0},hitAnimTime1 = 650,hitEff = { 110244},attackAnim = "skill2",hitEffOffsetX ={ 0},attackSound = 2402,hitSound = 32})
-- mapArray:push({ id = 250100, remote = 1,moveDistance = 100,attackEff = {100294}, attackEffTime = {200}, attackEffType = {0}, hitAnimTime1 = 700, hitAnimTime2 = 900,hitAnimTime3 = 1200,hitEff = { 1000021},attackSound = 2502})
-- mapArray:push({ id = 260100, remote = 1,xuliEff = 100265, attackEff = {100263},attackEffTime ={850}, attackEffType = {3}, hitAnimTime1 = 1000, hitEff = { 260103},attackSound = 2602,hitSound = 42})
-- mapArray:push({ id = 270100, remote = 1,attackEff = {100273}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 900, attackSound = 2702,hitSound = 15,attackAnim = "skill2"})
-- mapArray:push({ id = 280100, remote = 1,attackEff = {100283}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 550, hitEff = {101088},attackSound = 2802,hitSound = 12})
-- mapArray:push({ id = 290100, remote = 1,attackEff = {100293}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitAnimTime2 = 700,hitAnimTime3 = 1100,hitEff = { 1000021},attackSound = 2902})
-- mapArray:push({ id = 290102, remote = 1,attackEff = {100294}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, attackAnim = "skill2",hitEff = { 1000021},attackSound = 2902})
-- mapArray:push({ id = 300100, remote = 1,attackEff = {100303}, attackEffTime = {120}, attackEffType = {0}, hitAnimTime1 = 1500, hitEff = { 101088},attackSound = 3002,hitSound = 11})
-- mapArray:push({ id = 310100, remote = 1,attackEff = {100313}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 1000021},attackSound = 3102})
-- mapArray:push({ id = 310102, remote = 1,attackEff = {100294}, attackEffTime = {0}, attackEffType = {0}, attackAnim = "skill2",hitAnimTime1 = 600, hitEff = { 1000021},attackSound = 3103})
-- mapArray:push({ id = 320100, remote = 0,moveDistance = 150,attackEff = {100323}, attackEffTime = {0},attackEffType = {0}, hitAnimTime1 = 200,hitAnimTime2 = 400,hitAnimTime3 = 800,hitAnimTime4 = 1200, hitEff = {1802},attackSound = 3202,hitSound = 23})
-- mapArray:push({ id = 330100, remote = 0,moveDistance = 200,attackEff = {100333}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 900, hitEff = { 101044},attackSound = 3302,hitSound = 42})
-- mapArray:push({ id = 340100, remote = 1,attackEff = {100343}, attackEffTime = {200}, attackEffType = {0}, hitAnimTime1 = 1500, hitEff = { 8002},attackSound = 3402,hitSound = 32})
-- mapArray:push({ id = 350100, remote = 0,moveDistance = 200,attackEff = {100353}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitAnimTime2 = 900, hitEff = { 101088},attackSound = 3502,hitSound = 41})
-- mapArray:push({ id = 360100, remote = 0,moveDistance = 200,attackEff = {100363}, attackEffTime = {300}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 402},attackSound = 3602,hitSound = 12})
-- mapArray:push({ id = 370100, remote = 1,xuliEff = 100375,attackEff = {100373}, attackEffOffsetX = {80},attackEffOffsetY = {220},attackEffTime = {1000}, attackEffType = {4}, hitAnimTime1 = 1300, hitEff = { 3702},attackSound = 3702,hitSound = 11})
-- mapArray:push({ id = 380100, remote = 0,moveDistance = 200,attackEff = {100383}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 101044},attackSound = 3802,hitSound = 21})
-- mapArray:push({ id = 390100, remote = 0,moveDistance = 150,attackEff = {100393}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = {3702},attackSound = 3902,hitSound = 21})
-- mapArray:push({ id = 400100, remote = 0,moveDistance = 80, attackEff = {100403}, attackEffTime = {200}, attackEffType = {0},hitAnimTime1 = 200,hitEff = {4002},hitAnimTime2= 500,hitAnimTime3 = 700,attackSound = 4002,hitSound = 12})
-- mapArray:push({ id = 410100, remote = 0,moveDistance = 100, attackEff = {100433}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 300,hitAnimTime2= 500,hitAnimTime3 = 900,attackSound = 4302,hitSound = 12})
-- mapArray:push({ id = 420100, remote = 0,moveDistance = 100, attackEff = {100433}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 300,hitAnimTime2= 500,hitAnimTime3 = 900,attackSound = 4302,hitSound = 12})
-- mapArray:push({ id = 430100, remote = 0,moveDistance = 100, attackEff = {100433}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101044},hitAnimTime1 = 300,hitAnimTime2= 500,hitAnimTime3 = 900,attackSound = 4302,hitSound = 12})
-- mapArray:push({ id = 440100, remote = 1,moveDistance = 80, attackEff = {100443}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitAnimTime2 = 1200,hitEff = { 1000021},attackSound = 4402})
-- mapArray:push({ id = 440102, remote = 1,moveDistance = 80, attackEff = {100294}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700, hitAnimTime2 = 900, hitAnimTime3 = 1200,hitEff = { 1000021},attackSound = 4403})
-- mapArray:push({ id = 450100, remote = 0,moveDistance = 150,attackEff = {100453}, attackEffTime = {270}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 8002},attackSound = 4502,hitSound = 22})
-- mapArray:push({ id = 460100, remote = 0,moveDistance = 150,attackEff = {100453}, attackEffTime = {270}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 8002},attackSound = 4802,hitSound = 22})
-- mapArray:push({ id = 470100, remote = 0,moveDistance = 150,attackEff = {100453}, attackEffTime = {270}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 8002},attackSound = 4802,hitSound = 22})
-- mapArray:push({ id = 480100, remote = 0,moveDistance = 150,attackEff = {100453}, attackEffTime = {270}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 8002},attackSound = 4802,hitSound = 22})
-- mapArray:push({ id = 490100, remote = 1, xuliEff = 40101, attackEff = {40103},flyEffRotate =0,attackEffTime = {400}, attackEffType = {4}, hitAnimTime1 = 800, hitEff = {402},attackSound = 2,hitSound = 13})

-- mapArray:push({ id = 500100, remote = 1,attackEff = {100223}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 3702},attackSound = 2202,hitSound = 23})
-- mapArray:push({ id = 510100, remote = 1,attackEff = {100173}, attackEffTime = {400}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 8002},attackSound = 1702,hitSound = 13})
-- mapArray:push({ id = 520100, remote = 1,attackEff = {100173}, attackEffTime = {400}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 8002},attackSound = 1702,hitSound = 13})
-- mapArray:push({ id = 530100, remote = 1,attackEff = {100173}, attackEffTime = {400}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 8002},attackSound = 1702,hitSound = 13})
-- mapArray:push({ id = 540100, remote = 1,attackEff = {100173}, attackEffTime = {400}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 8002},attackSound = 1702,hitSound = 13})

-- mapArray:push({ id = 550100, remote = 1, xuliEff = 40101, attackEff = {40103},flyEffRotate =0,attackEffTime = {500}, attackEffType = {4}, hitAnimTime1 = 800, hitEff = { 402},attackSound = 5502,hitSound = 23})
-- mapArray:push({ id = 560100, remote = 1, xuliEff = 40101, attackEff = {40103},flyEffRotate =0,attackEffTime = {500}, attackEffType = {4}, hitAnimTime1 = 800, hitEff = { 402},attackSound = 5502,hitSound = 23})
-- mapArray:push({ id = 570100, remote = 1, xuliEff = 40101, attackEff = {40103},flyEffRotate =0,attackEffTime = {500}, attackEffType = {4}, hitAnimTime1 = 800, hitEff = { 402},attackSound = 5502,hitSound = 23})

-- mapArray:push({ id = 580100, remote = 0, moveDistance = 250,attackEff = {100583},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 101088},attackSound = 5502,hitSound = 31})
-- mapArray:push({ id = 590100, remote = 0, moveDistance = 250,attackEff = {100583},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 101088},attackSound = 5502,hitSound = 31})
-- mapArray:push({ id = 600100, remote = 0, moveDistance = 200,attackEff = {100583},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 101088},attackSound = 5502,hitSound = 31})

-- mapArray:push({ id = 610100, remote = 0,moveDistance = 200,attackEff = {100613}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 402},attackSound = 17702,hitSound = 22})
-- mapArray:push({ id = 620100, remote = 1,moveDistance = 100,attackEff = {100623}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 650, hitEff = { 101044},attackSound = 20502,hitSound = 13})
-- mapArray:push({ id = 630100, remote = 1,moveDistance = 100,attackEff = {100623}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 650, hitEff = { 101044},attackSound = 20502,hitSound = 13})
-- mapArray:push({ id = 640100, remote = 1,moveDistance = 100,attackEff = {100623}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 650, hitEff = { 101044},attackSound = 20502,hitSound = 13})
-- mapArray:push({ id = 650100, remote = 1,moveDistance = 100,attackEff = {100623}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 650, hitEff = { 101044},attackSound = 20502,hitSound = 13})
-- mapArray:push({ id = 660100, remote = 1,moveDistance = 100,attackEff = {100623}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 650, hitEff = { 101044},attackSound = 20502,hitSound = 13})
-- mapArray:push({ id = 670100, remote = 0,moveDistance = 20,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 0},attackSound = 202,hitSound = 11})
-- mapArray:push({ id = 680100, remote = 0,moveDistance = 70,attackEff = {100713}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 8002},attackSound = 6802,hitSound = 11})
-- mapArray:push({ id = 690100, remote = 0,moveDistance = 100,attackEff = {100723}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 402},attackSound = 6902,hitSound = 11})
-- mapArray:push({ id = 700100, remote = 0,moveDistance = 80,attackEff = {100733}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 101022},attackSound = 7002,hitSound = 11})
-- mapArray:push({ id = 710100, remote = 0,moveDistance = 70,attackEff = {100713}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 8002},attackSound = 6802,hitSound = 11})
-- mapArray:push({ id = 720100, remote = 0,moveDistance = 100,attackEff = {100723}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 402},attackSound = 6902,hitSound = 11})
-- mapArray:push({ id = 730100, remote = 0,moveDistance = 100,attackEff = {100733}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 101022},attackSound = 7002,hitSound = 11})
-- mapArray:push({ id = 740100, remote = 0,moveDistance = 70,attackEff = {100713}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 8002},attackSound = 6802,hitSound = 11})
-- mapArray:push({ id = 750100, remote = 0,moveDistance = 100,attackEff = {100723}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 402},attackSound = 6902,hitSound = 11})
-- mapArray:push({ id = 760100, remote = 0,moveDistance = 80,attackEff = {100733}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 101022},attackSound = 7002,hitSound = 11})

-- mapArray:push({ id = 770100, remote = 0, moveDistance = 170,attackEff = {100773}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 1200,hitEff = { 101088},attackAnim = "skill",attackSound = 7702,hitSound = 21})
-- mapArray:push({ id = 770102, remote = 0, moveDistance = 150,attackEff = {110773}, attackEffTime = {50}, attackEffType = {0},hitAnimTime1 = 900,hitEff = { 101022},attackAnim = "skill2",attackSound = 7703,hitSound = 11})
-- mapArray:push({ id = 770103, remote = 1, moveDistance = 200,attackEff = {120773}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 800,hitAnimTime2 = 1000,hitEff = { 101088},attackAnim = "skill3",attackSound = 7704,hitSound = 21})
-- mapArray:push({ id = 770104, remote = 1, moveDistance = 0,needMoveCenter = 1,attackEff = {130773}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 200,hitAnimTime2 = 500,hitAnimTime3 = 700,hitAnimTime4 = 1200,hitEff = { 101022},attackAnim = "skill4",attackSound = 7705,hitSound = 22})


-- mapArray:push({ id = 780100, remote = 0, moveDistance = 170,attackEff = {100783}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 500,hitEff = { 101022},attackAnim = "skill",attackSound = 7802,hitSound = 42})
-- mapArray:push({ id = 780102, remote = 1, moveDistance = 120,attackEff = {110783}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 1100,hitEff = { 1000021},attackAnim = "skill2",attackSound = 7803})
-- mapArray:push({ id = 780103, remote = 1, moveDistance = 120,attackEff = {120783}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 800,hitAnimTime2 = 1000,hitAnimTime3 = 1200,hitEff = { 8002},attackAnim = "skill3",attackSound = 7804,hitSound = 41})

-- mapArray:push({ id = 790100, remote = 0, moveDistance = 150,attackEff = {100793}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 500,hitAnimTime2 = 800,hitAnimTime3 = 1100,hitEff = { 8002},attackAnim = "skill",attackSound = 7902,hitSound = 21})
-- mapArray:push({ id = 790102, remote = 1, moveDistance = 300,attackEff = {110793}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 1400,hitEff = { 101055},attackAnim = "skill2",attackSound = 7903,hitSound = 41})
-- mapArray:push({ id = 790103, remote = 0, moveDistance = 150,attackEff = {120793}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 500,hitAnimTime2 = 800,hitAnimTime3 = 1200,hitEff = { 101055},attackAnim = "skill3",attackSound = 7904,hitSound = 22})

-- mapArray:push({ id = 800100, remote = 0,moveDistance = 100,attackEff = {100803}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 300,hitAnimTime2 = 700, hitAnimTime3 = 1100,hitAnimTime4 = 1500,hitEff = { 8002},attackAnim = "skill",attackSound = 8002,hitSound = 31})
-- mapArray:push({ id = 800102, remote = 0,moveDistance = 70,attackEff = {110803}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 300,hitAnimTime2 = 500, hitAnimTime3 = 900,hitEff = { 8002},attackAnim = "skill2",attackSound = 8003,hitSound = 31})
-- mapArray:push({ id = 800103, remote = 0,moveDistance = 90,attackEff = {120803}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 700,hitEff = { 8002},attackAnim = "skill3",attackSound = 8004,hitSound = 33})
-- mapArray:push({ id = 800104, remote = 1,moveDistance = 150,attackEff = {130803}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400,hitAnimTime2 = 600, hitAnimTime3 = 900,hitEff = { 8002},attackAnim = "skill4",attackSound = 8005,hitSound = 33})

-- mapArray:push({ id = 810100, remote = 1,attackEff = {100813}, attackEffTime = {90}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 1500, hitEff = { 8002},attackSound = 8102,hitSound = 14})
-- mapArray:push({ id = 820100, remote = 0,moveDistance = 80,attackEff = {100823}, attackEffTime = {250}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 800, hitAnimTime3 = 1200,hitEff = {8002},attackSound = 8202,hitSound = 21})
-- mapArray:push({ id = 830100, remote = 0,moveDistance = 100,attackEff = {100833}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 300, hitAnimTime2 = 800,hitAnimTime3 = 1200,hitEff = { 3702},attackSound = 8302,hitSound = 21})
-- mapArray:push({ id = 840100, remote = 1,xuliEff = 100846,attackEff = {100843}, attackEffTime = {0},attackEffType = {1}, hitAnimTime1 = 800, hitAnimTime2 = 1200,hitAnimTime3 = 1500,hitEff = { 101044},attackSound = 8402,hitSound = 22})
-- mapArray:push({ id = 850100, remote = 1,moveDistance = 100,attackEff = {100853}, attackEffTime = {0}, attackEffType = {0},hitEff = { 100854},hitAnimTime1 = 100,attackSound = 8502,hitSound = 21})
-- mapArray:push({ id = 860100, remote = 0,moveDistance = 100,attackEff = {100863}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800,hitEff = { 101022},attackSound = 8602,hitSound = 11})
-- mapArray:push({ id = 870100, remote = 0,moveDistance = 170,attackEff = {100873}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1300,hitEff = { 3702},attackSound = 8702,hitSound = 34})
-- mapArray:push({ id = 880100, remote = 1,moveDistance = 100,attackEff = {100883}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 700, hitAnimTime3 = 1200,  hitEff = { 1000021},attackSound = 12702})
-- mapArray:push({ id = 890100, remote = 0,moveDistance = 100,attackEff = {100893}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitAnimTime2 = 800,hitAnimTime3 = 1300,hitEff = { 101088},attackSound = 8902,hitSound = 22})

-- mapArray:push({ id = 900100, remote = 1,xuliEff = 100906,moveDistance = 100,flyEffRotate = 1,attackEff = {100903}, attackEffTime = {430}, attackEffType = {4}, hitAnimTime1 = 600, hitEff = { 101088},attackAnim = "skill2",attackSound = 9002,hitSound = 23})
-- mapArray:push({ id = 900102, remote = 1,moveDistance = 100,attackEff = {110903}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 950, hitAnimTime2 = 1100,hitAnimTime3 = 1500,hitEff = { 8002},attackAnim = "skill",attackSound = 9002,hitSound = 23})

-- mapArray:push({ id = 910100, remote = 1,xuliEff = 100916,moveDistance = 250,attackEff = {100914}, attackEffType = {1},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitAnimTime2 = 1300,hitEff = { 8002},attackSound = 9102,hitSound = 12})
-- mapArray:push({ id = 920100, remote = 0,moveDistance = 150,attackEff = {100923}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitAnimTime2 = 400,hitAnimTime3 = 1200,hitEff = { 101044},attackSound = 9202,hitSound = 23})
-- mapArray:push({ id = 930100, remote = 0,moveDistance = 200,attackEff = {100933}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitAnimTime2 = 800,hitEff = {3702},attackSound = 9302,hitSound = 12})
-- mapArray:push({ id = 940100, remote = 1,moveDistance = 250,attackEff = {100943}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitEff = { 0},attackSound = 9402,hitSound = 13})
-- mapArray:push({ id = 950100, remote = 0,moveDistance = 250,attackEff = {100953}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitEff = { 100955},attackSound = 9502,hitSound = 14})

-- mapArray:push({ id = 960100, remote = 0,moveDistance = 200,attackEff = {100963}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600,attackAnim = "skill2",hitEff = { 101044},attackSound = 9602,hitSound = 31})
-- mapArray:push({ id = 960102, remote = 1,moveDistance = 200,attackEff = {110963}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200,hitAnimTime2 = 500,hitAnimTime3 = 1000,hitEffShowOnce = 1,attackAnim = "skill",hitEff = {110964},attackSound = 9603,hitSound = 23})

-- mapArray:push({ id = 970100, remote = 1,moveDistance = 150,attackEff = {100973}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800,hitEff = { 1000021},attackSound = 9702})
-- mapArray:push({ id = 970102, remote = 1,moveDistance = 150,attackEff = {100294}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitAnimTime2 = 800,hitAnimTime3 = 1000,hitEff = { 1000021},attackSound = 9702})
-- mapArray:push({ id = 980100, remote = 1,moveDistance = 200,attackEff = {100983}, attackEffTime = {100}, attackEffType = {0}, hitAnimTime1 = 1300,hitAnimTime2 = 1600, hitEff = { 101055},attackSound = 9802,hitSound = 22})
-- mapArray:push({ id = 990100, remote = 1,moveDistance = 0,xuliEff = 100996,needMoveCenter = 1,attackEff = {100993}, attackEffTime = {1}, attackEffType = {1}, hitAnimTime1 = 800,hitEff = { 0},attackSound = 9902,hitSound = 14})
-- mapArray:push({ id = 1000100, remote = 1,moveDistance = 150,attackEff = {101003}, attackEffTime = {100}, attackEffType = {0}, hitAnimTime1 = 1500, hitAnimTime2 = 2000,hitAnimTime3 = 2500,hitEff = { 8002},attackSound = 10002,hitSound = 14})
-- mapArray:push({ id = 1010100, remote = 1,moveDistance = 150,attackEff = {101013}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1500, hitAnimTime2 = 2000,hitAnimTime3 = 2500,hitEff = { 1802},attackSound = 10102,hitSound = 15})
-- mapArray:push({ id = 1020100, remote = 0,moveDistance = 250,attackEff = {101023}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitAnimTime2 = 1100,hitEff = { 3702},attackSound = 10202,hitSound = 13})
-- mapArray:push({ id = 1030100, remote = 0,moveDistance = 100,attackEff = {101033}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitAnimTime2 = 500,hitAnimTime3 = 1200,hitEff = {101055},attackSound = 10302,hitSound = 42})

-- mapArray:push({ id = 1040100, remote = 1,xuliEff = 101046,attackEff = {101043}, attackEffTime = {350}, attackEffType = {3},attackEffType = {4}, hitAnimTime1 = 600, hitEff = { 101055},attackSound = 10402,hitSound = 21})

-- mapArray:push({ id = 1050100, remote = 1,moveDistance = 150,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitEff = { 1000021},attackSound = 2})
-- mapArray:push({ id = 1060100, remote = 1,moveDistance = 250,attackEff = {101063}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = { 0},attackSound = 10602,hitSound = 22})
-- mapArray:push({ id = 1060102, remote = 0,moveDistance = 250,attackEff = {101064}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitAnimTime2 = 800,hitEff = { 101088},attackSound = 10603,hitSound = 22})
-- mapArray:push({ id = 1070100, remote = 1,moveDistance = 150,xuliEff = 101076,attackEff = {101073}, attackEffTime = {3}, attackEffType = {0}, hitAnimTime1 = 500,hitEff = { 3702},attackSound = 10702,hitSound = 12})
-- mapArray:push({ id = 1080100, remote = 0,moveDistance = 150,attackEff = {101083}, attackEffTime = {250}, attackEffType = {0}, hitAnimTime1 = 1700, hitAnimTime2 = 2000,hitEff = { 101044},attackSound = 10802,hitSound = 41})
-- mapArray:push({ id = 1090100, remote = 0,moveDistance = 250,attackEff = {101093}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000,hitEff = { 101022},attackSound = 800,hitSound = 11})
-- mapArray:push({ id = 1100100, remote = 0,moveDistance = 150,attackEff = {101103}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitAnimTime2 = 500,hitAnimTime3 = 1000,hitEff = { 101088},attackSound = 11002,hitSound = 11})
-- mapArray:push({ id = 1110100, remote = 1,moveDistance = 130,attackEff = {101113}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1500, hitAnimTime2 = 1700,hitAnimTime3 = 1900,hitEff = { 0},attackSound = 11102,hitSound = 43})
-- mapArray:push({ id = 1120100, remote = 0,moveDistance = 130,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitAnimTime2 = 500,hitAnimTime3 = 800,hitEff = { 0},attackSound = 2})
-- mapArray:push({ id = 1130100, remote = 0,moveDistance = 130,attackEff = {101133}, attackEffTime = {500}, attackEffType = {0}, hitAnimTime1 = 500, hitAnimTime2 = 1200,hitAnimTime3 = 1600,hitEff = { 101022},attackSound = 11302,hitSound = 41})
-- mapArray:push({ id = 1140100, remote = 0, moveDistance = 100,attackEff = {101143}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600,hitEff = { 3702},attackSound = 11402,hitSound = 23})
-- mapArray:push({ id = 1150100, remote = 0, moveDistance = 200,attackEff = {101153}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200,hitAnimTime2 = 500,hitAnimTime3 = 1300,hitEff = { 101055},attackSound = 11502,hitSound = 12})
-- mapArray:push({ id = 1160100, remote = 0, moveDistance = 130,attackEff = {101163}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 550,hitEff = { 7002},attackSound = 11602,hitSound = 13,hitSound = 23})
-- mapArray:push({ id = 1170100, remote = 0, moveDistance = 250,attackEff = {101173}, attackEffTime = {500}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 3702},attackSound = 11702,hitSound = 22})
-- mapArray:push({ id = 1180100, remote = 0, moveDistance = 230,attackEff = {101183}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1300, hitEff = { 402},attackSound = 11802,hitSound = 12})
-- mapArray:push({ id = 1190100, remote = 0,moveDistance = 130,attackEff = {101133}, attackEffTime = {500}, attackEffType = {0}, hitAnimTime1 = 500, hitAnimTime2 = 1200,hitAnimTime3 = 1600,hitEff = { 101022},attackSound = 11402,hitSound = 12})
-- mapArray:push({ id = 1200100, remote = 0, moveDistance = 130,attackEff = {101203}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitAnimTime2 = 1000,hitEff = { 101022},attackSound = 12002,hitSound = 14})
-- mapArray:push({ id = 1210100, remote = 0, moveDistance = 80,attackEff = {101213}, attackEffTime = {150}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 3702},attackSound = 12102,hitSound = 21})
-- mapArray:push({ id = 1220100, remote = 0, moveDistance = 50,attackEff = {101223}, attackEffTime = {700}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 8002},attackSound = 12202,hitSound = 22})
-- mapArray:push({ id = 1230100, remote = 0, moveDistance = 80,attackEff = {101233}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 300, hitAnimTime2 = 600,hitAnimTime3 = 900,hitAnimTime4 = 1500,hitEff = { 101022},attackSound = 12302,hitSound = 43})
-- mapArray:push({ id = 1240100, remote = 0, moveDistance = 80,attackEff = {101243}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitAnimTime2 = 500,hitAnimTime3 = 800,hitAnimTime4 = 1200,hitEff = { 1802},attackSound = 12402,hitSound = 41})
-- mapArray:push({ id = 1250100, remote = 0,moveDistance = 150,attackEff = {100393}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 3702},attackSound = 3902,hitSound = 15})
-- mapArray:push({ id = 1260100, remote = 1, moveDistance = 80,attackEff = {101263}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 900,hitEff = { 0},attackSound = 12602})
-- mapArray:push({ id = 1260102, remote = 1, moveDistance = 80,attackEff = {101264}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700,hitEff = { 101055},attackAnim = "skill2",attackSound = 12603,hitSound = 11})


-- mapArray:push({ id = 1270100, remote = 1, moveDistance = 30,attackEff = {101273}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitEff = { 3702},attackSound = 12702})


-- mapArray:push({ id = 1280100, remote = 0, moveDistance = 180,attackEff = {101303}, attackEffTime = {500},attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 7002},attackSound = 13002,hitSound = 13})
-- mapArray:push({ id = 1290100, remote = 0, moveDistance = 180,attackEff = {101303}, attackEffTime = {500},attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 8002},attackSound = 13002,hitSound = 13})
-- mapArray:push({ id = 1300100, remote = 0, moveDistance = 180,attackEff = {101303}, attackEffTime = {500}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 7002},attackSound = 13002,hitSound = 43})
-- mapArray:push({ id = 1310100, remote = 0, moveDistance = 100,attackEff = {101313},attackEffTime = {700}, attackEffType = {0}, hitAnimTime1 = 750, hitEff = { 101055},attackSound = 13102,hitSound = 31})
-- mapArray:push({ id = 1320100, remote = 0, moveDistance = 100,attackEff = {101323},attackEffTime = {390}, attackEffType = {0}, hitAnimTime1 = 500,hitEff = { 8002},attackSound = 13202,hitSound = 42})
-- mapArray:push({ id = 1330100, remote = 0, moveDistance = 180,attackEff = {101333},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 700, hitEff = { 8002},attackSound = 202,hitSound = 14})
-- mapArray:push({ id = 1340100, remote = 0, moveDistance = 80,attackEff = {101343},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitEff = { 8002},attackSound = 13402,hitSound = 42})
-- mapArray:push({ id = 1340102, remote = 0, moveDistance = 280,attackEff = {111343},attackEffTime = {550}, attackEffType = {0},needMoveSameRow = 1, hitAnimTime1 =800, hitEff = { 111345},attackAnim = "skill2",attackSound = 13402,hitSound = 12})

-- mapArray:push({ id = 1350100, remote = 1, moveDistance = 250,attackEff = {111353},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 111354},attackSound = 13502,hitSound = 14})
-- mapArray:push({ id = 1360100, remote = 1,moveDistance = 300,needMoveCenter = 1,attackEff = {100303}, attackEffTime = {120}, attackEffType = {0}, hitAnimTime1 = 1500, hitEff = { 101022},attackSound = 13602,hitSound = 14})
-- mapArray:push({ id = 1365100, remote = 1,moveDistance = 300,needMoveCenter = 1,attackEff = {100303}, attackEffTime = {120}, attackEffType = {0}, hitAnimTime1 = 1500, hitEff = { 101022},attackSound = 13602,hitSound = 14})

-- mapArray:push({ id = 1370100, remote = 0, moveDistance = 100,attackEff = {101373},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 1802},attackSound = 13702,hitSound = 14})
-- mapArray:push({ id = 1380100, remote = 0, moveDistance = 100,attackEff = {101383},attackEffTime = {5}, attackEffType = {0},  hitAnimTime1 = 400,hitAnimTime2 = 1000,hitEff = { 101088},attackSound = 13802,hitSound = 22})
-- mapArray:push({ id = 1390100, remote =1, moveDistance = 150,attackEff = {101393},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 800, hitAnimTime2 = 900,hitAnimTime3 = 1100,hitEff = {101044},attackSound = 13902,hitSound = 32})
-- mapArray:push({ id = 1400100, remote = 0, moveDistance = 130,attackEff = {101403},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 200, hitAnimTime2 = 400,hitEff = {3702},attackSound = 14002,hitSound = 22})
-- mapArray:push({ id = 1410100, remote = 0, moveDistance = 180,attackEff = {101413},attackEffTime = {200}, attackEffType = {0}, hitAnimTime1 = 450, hitAnimTime2 = 750,hitEff = { 8002},attackSound = 14102,hitSound = 32})
-- mapArray:push({ id = 1420100, remote = 0, moveDistance = 250,attackEff = {100933}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitAnimTime2 = 700,hitAnimTime3 = 900,hitEff = { 101022},attackSound = 9302,hitSound = 14})
-- mapArray:push({ id = 1430100, remote = 0, moveDistance = 100,attackEff = {101433},attackEffTime = {80}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 1802},attackSound = 14302,hitSound = 41})
-- mapArray:push({ id = 1440100, remote = 0, moveDistance = 130,attackEff = {101443},attackEffTime = {200}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 3702},attackSound = 14402,hitSound = 32})
-- mapArray:push({ id = 1450100, remote = 0, moveDistance = 200,attackEff = {101453},attackEffTime = {100}, attackEffType = {0}, hitAnimTime1 = 400,hitAnimTime2 = 800,hitAnimTime3 = 1500, hitEff = { 8002},attackSound = 14502,hitSound = 22})
-- mapArray:push({ id = 1460100, remote = 1, moveDistance = 250,xuliEff = 0,attackEff = {101463},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 100, hitEff = { 101416}, attackSound = 14602,hitSound = 14})
-- mapArray:push({ id = 1470100, remote = 0, moveDistance = 100,attackEff = {101473},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 700,hitEff = { 1802},attackSound = 14702,hitSound = 22})
-- mapArray:push({ id = 1480100, remote = 0,moveDistance = 100,attackEff = {101473},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 700,hitEff = { 1802},attackSound = 14702,hitSound = 14})
-- mapArray:push({ id = 1490100, remote = 0, moveDistance = 130,attackEff = {101493},attackEffTime = {30}, attackEffType = {0}, hitAnimTime1 = 900, hitEff = {402},attackSound = 14902,hitSound = 32})
-- mapArray:push({ id = 1500100, remote = 0, moveDistance = 130,attackEff = {101503},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 101055},attackSound = 15002,hitSound = 21})

-- mapArray:push({ id = 1510100, remote = 1, moveDistance = 0,  attackEff = {101513},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1300, hitEff = { 101055},attackSound = 15102,hitSound = 15})
-- mapArray:push({ id = 1515100, remote = 1, moveDistance = 0,  attackEff = {101513},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1300, hitEff = { 101055},attackSound = 15102,hitSound = 15})

-- mapArray:push({ id = 1520100, remote = 0,moveDistance = 100,attackEff = {102053}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 7002},attackSound = 202,hitSound = 15})
-- mapArray:push({ id = 1530100, remote = 0,moveDistance = 100,attackEff = {102053}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 8002},attackSound = 202,hitSound = 15})
-- mapArray:push({ id = 1540100, remote = 0,moveDistance = 100,attackEff = {102053}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 8002},attackSound = 202,hitSound = 15})

-- mapArray:push({ id = 1550100, remote = 1,moveDistance = 100,attackEff = {100233}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 1000, hitAnimTime3 = 1500,  hitEff = { 0},attackAnim = "skill2",attackSound = 2302,hitSound = 43})
-- mapArray:push({ id = 1550102, remote = 0,moveDistance = 100,attackEff = {100234}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 1000, hitAnimTime3 = 1500,  hitEff = { 101022},attackAnim = "skill1",attackSound = 2303,hitSound = 43})

-- mapArray:push({ id = 1560100, remote = 1,moveDistance = 100,attackEff = {101563}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1200, hitEff = { 101564},attackSound = 202,hitSound = 41})
-- mapArray:push({ id = 1570100, remote = 1,moveDistance = 200,attackEff = {101573}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000,hitAnimTime2 = 1300,hitAnimTime3 = 1500, hitEff = { 101022},attackSound = 15702,hitSound = 13})
-- mapArray:push({ id = 1580100, remote = 0,moveDistance = 200,attackEff = {101583}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitAnimTime2 = 1400,hitEff = { 101022},attackSound = 15802,hitSound = 13})
-- mapArray:push({ id = 1590100, remote = 1,moveDistance = 80,attackEff = {101593}, attackEffTime = {0}, attackEffType = {0},hitAnimTime1 = 500,hitEff = { 101594},attackSound = 15902,hitSound = 43})
-- mapArray:push({ id = 1600100, remote = 0,moveDistance = 100,attackEff = {101603}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400,hitAnimTime2 = 800, hitEff = { 8002},attackSound = 16002,hitSound = 23})
-- mapArray:push({ id = 1610100, remote = 0,moveDistance = 250,attackEff = {101613}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800,hitAnimTime2 = 1100,hitAnimTime3 = 1500, hitEff = { 8002},attackSound = 16102,hitSound = 23})
-- mapArray:push({ id = 1620100, remote = 0,moveDistance = 80,attackEff = {101633}, attackEffTime = {200}, attackEffType = {0}, hitAnimTime1 = 100,hitAnimTime2 = 400,hitAnimTime3 =650, hitEff = { 101022},attackSound = 16302,hitSound = 13})
-- mapArray:push({ id = 1630100, remote = 0,moveDistance = 80,attackEff = {101633}, attackEffTime = {200}, attackEffType = {0}, hitAnimTime1 = 100,hitAnimTime2 = 400,hitAnimTime3 =700,hitEff = {101022},attackSound = 16302,hitSound = 23})
-- mapArray:push({ id = 1640100, remote = 0,moveDistance = 80,attackEff = {101643}, attackEffTime = {350}, attackEffType = {0}, hitAnimTime1 = 400,hitAnimTime2 = 800,hitAnimTime3 = 1300, hitEff = { 101022},attackSound = 16402,hitSound = 13})
-- mapArray:push({ id = 1650100, remote = 0,moveDistance = 150,attackEff = {101653}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 3702},attackSound = 16502,hitSound = 33})
-- mapArray:push({ id = 1660100, remote = 0,moveDistance = 120,attackEff = {101663}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 8002},attackSound = 16602,hitSound = 23})
-- mapArray:push({ id = 1670100, remote = 0,moveDistance = 120,attackEff = {101663}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 8002},attackSound = 16602,hitSound = 13})
-- mapArray:push({ id = 1680100, remote = 0,moveDistance = 150,attackEff = {101683}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 3702},attackSound = 16802,hitSound = 23})
-- mapArray:push({ id = 1690100, remote = 0, moveDistance = 100,attackEff = {101473},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 800,hitEff = { 1802},attackSound = 14702,hitSound = 23})
-- mapArray:push({ id = 1700100, remote = 0, moveDistance = 100,attackEff = {101473},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 800,hitEff = { 1802},attackSound = 14702,hitSound = 43})
-- mapArray:push({ id = 1710100, remote = 0, moveDistance = 100,attackEff = {101473},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 800,hitEff = { 1802},attackSound = 14702,hitSound = 23})
-- mapArray:push({ id = 1720100, remote = 0, moveDistance = 100,attackEff = {101473},attackEffTime = {0}, attackEffType = {0},  hitAnimTime1 = 800,hitEff = { 1802},attackSound = 14702,hitSound = 23})
-- mapArray:push({ id = 1730100, remote = 0,moveDistance = 120,attackEff = {100873}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1300, hitEff = { 8002},attackSound = 8702,hitSound = 43})
-- mapArray:push({ id = 1740100, remote = 0,moveDistance = 80,attackEff = {100403}, attackEffTime = {0}, attackEffType = {0},hitEff = { 4002},hitAnimTime1 = 100,hitAnimTime2= 300,hitAnimTime3 = 500,hitAnimTime4 = 700,attackSound = 4302,hitSound = 23})
-- mapArray:push({ id = 1750100, remote = 0, moveDistance = 80,attackEff = {101213}, attackEffTime = {150}, attackEffType = {0}, hitAnimTime1 = 500, hitEff = { 3702},attackSound = 202,hitSound = 23})
-- mapArray:push({ id = 1760100, remote = 0, moveDistance = 100,attackEff = {101313},attackEffTime = {800}, attackEffType = {0}, hitAnimTime1 = 800, hitEff = { 101055},attackSound = 202,hitSound = 43})
-- mapArray:push({ id = 1770100, remote = 0,moveDistance = 200,attackEff = {100613},attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 402},attackSound = 17702,hitSound = 22})
-- mapArray:push({ id = 1780100, remote = 0,moveDistance = 200,attackEff = {101781}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 300, hitEff = { 3702},attackSound = 17802,hitSound = 23})
-- mapArray:push({ id = 1790100, remote = 0,moveDistance = 220,attackEff = {101793}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 8002},attackSound = 17902,hitSound = 23})
-- mapArray:push({ id = 1800100, remote = 0,moveDistance = 220,attackEff = {101793}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 8002},attackSound = 17902,hitSound = 13})
-- mapArray:push({ id = 1810100, remote = 0,moveDistance = 150,attackEff = {101813}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitEff = { 101022},attackSound = 18102,hitSound = 23})
-- mapArray:push({ id = 1820100, remote = 0,moveDistance = 110,attackEff = {101823}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 8002},attackSound = 18202,hitSound = 23})
-- mapArray:push({ id = 1830100, remote = 0,moveDistance = 110,attackEff = {101823}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 8002},attackSound = 18202,hitSound = 14})
-- mapArray:push({ id = 1840100, remote = 0,moveDistance = 110,attackEff = {101823}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 600, hitEff = { 8002},attackSound = 18202,hitSound = 14})
-- mapArray:push({ id = 1850100, remote = 0, moveDistance = 50,attackEff = {101223}, attackEffTime = {700}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 4002},attackSound = 202,hitSound = 22})
-- mapArray:push({ id = 1860100, remote = 0, moveDistance = 50,attackEff = {101223}, attackEffTime = {700}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 4002},attackSound = 202,hitSound = 22})
-- mapArray:push({ id = 1870100, remote = 0, moveDistance = 50,attackEff = {101223}, attackEffTime = {700}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 4002},attackSound = 202,hitSound = 22})
-- mapArray:push({ id = 1880100, remote = 0, moveDistance = 50,attackEff = {101223}, attackEffTime = {700}, attackEffType = {0}, hitAnimTime1 = 700, hitEff = { 4002},attackSound = 202,hitSound = 22})
-- mapArray:push({ id = 1890100, remote = 0,moveDistance = 80,attackEff = {101893}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 100,hitAnimTime2 = 600,hitAnimTime3 = 1000, hitEff = { 8002},attackSound = 18902,hitSound = 23})
-- mapArray:push({ id = 1900100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
-- mapArray:push({ id = 1910100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
-- mapArray:push({ id = 1920100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
-- mapArray:push({ id = 1930100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
-- mapArray:push({ id = 1940100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
-- mapArray:push({ id = 1950100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
-- mapArray:push({ id = 1960100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
-- mapArray:push({ id = 1970100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
-- mapArray:push({ id = 1980100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
-- mapArray:push({ id = 1990100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
-- mapArray:push({ id = 2000100, remote = 0,moveDistance = 120,attackEff = {101663}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 3702},attackSound = 16602,hitSound = 23})
-- mapArray:push({ id = 2010100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
-- mapArray:push({ id = 2020100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 13})
-- mapArray:push({ id = 2030100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 12})
-- mapArray:push({ id = 2040100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 12})
-- mapArray:push({ id = 2050100, remote = 0,moveDistance = 80,attackEff = {102053}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 8002},attackSound = 20502,hitSound = 32})
-- mapArray:push({ id = 2060100, remote = 0,moveDistance = 80,attackEff = {102053}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 8002},attackSound = 20502,hitSound = 32})
-- mapArray:push({ id = 2070100, remote = 0,moveDistance = 80,attackEff = {102053}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 8002},attackSound = 20502,hitSound = 32})
-- mapArray:push({ id = 2080100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 12})
-- mapArray:push({ id = 2090100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 12})
-- mapArray:push({ id = 2100100, remote = 0,moveDistance = 80,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 400, hitEff = { 0},attackSound = 202,hitSound = 12})
-- --17日新增
-- mapArray:push({ id = 2730100, remote = 1,moveDistance = 0, attackEff = {102733}, attackEffTime = {400}, attackEffOffsetX = {-40} ,attackEffType = {0}, hitXuliEff = 102736 , hitXuliEffType = 5,hitXuliEffTimeDelay = 500,hitXuliEffTime = 0,hitAnimTime1 = 750, hitAnimTime2 = 1050, hitEffTime = {0},hitEffShowOnce = 1,hitEff = {102734},hitEffOffsetX = {0},hitEffOffsetY = {5},hitEffType = {0},attackSound = 27301,hitSound = 0})
-- mapArray:push({ id = 2730101, remote = 1,moveDistance = 0, attackEff = {112735}, needMoveSameRow = 1, attackEffTime = {700}, attackEffType = {3} ,attackEffOffsetX = {100}, hitAnimTime1 = 1000, hitEff = { 112734},attackAnim = "skill2",attackSound = 27302 ,attackSoundTime = 500,hitSound = 27303})

-- mapArray:push({ id = 2740100, remote = 1,moveDistance = 0, attackEff = {102745}, xuliEff = 102743, xuliEffOffsetX = 25,attackEffTime = {1400}, attackEffType = {2}, attackEffOffsetX = {480},attackEffOffsetY = {150},hitAnimTime1 = 1600,hitAnimTime2 = 1800,hitAnimTime3 = 2000,hitSoundTime = 150, hitEff = { 102744},attackSoundTime= 500,attackSound = 27401,hitSound = 13,shake = 10})
-- mapArray:push({ id = 2740101, remote = 0,moveDistance = 180,attackEff = {112743}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 550, hitEff = { 101022},attackAnim = "skill2",hitSoundTime = 100,attackSound = 7802,hitSound = 42})

-- mapArray:push({ id = 2750100, remote = 1,moveDistance = 0,attackEff = {102755}, xuliEff = 102753, attackEffTime = {1400}, attackEffType = {3}, attackEffOffsetY = {150}, hitAnimTime1 = 1650, hitEff = { 102754},attackSound = 27501})
-- mapArray:push({ id = 2750101, remote = 1,moveDistance = 0,attackEff = {112753}, attackEffTime = {270}, attackEffType = {0}, attackEffOffsetX = {60}, attackEffOffsetY = {0}, hitAnimTime1 = 300,hitAnimTime2 = 600, hitEff = { 1000021},attackAnim = "skill2",attackSound = 402,hitSound = 13})

-- mapArray:push({ id = 2760100, remote = 1,moveDistance = 0,attackEff = {102763}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1200, hitEff = { 102764},attackSound = 27601,hitSound = 12, attackSoundTime = 300})

-- mapArray:push({ id = 2770100, remote = 1,moveDistance = 0,attackEff = {102773}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 500,hitAnimTime2 = 2500,hitEffShowOnce = 0, hitEff = { 102774},attackSoundTime= 100,attackSound = 27701})
-- mapArray:push({ id = 2770101, remote = 1,moveDistance = 0,attackEff = {112773}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = { 0},attackAnim = "skill2",attackSound = 202,hitSound = 13})


-- mapArray:push({ id = 2790100, remote = 1,moveDistance = 0,attackEff = {102795, 102796,102797},xuliEff = 102793, attackEffTime = {100,80,1500}, attackEffType = {6,8,5}, hitAnimTime1 = 1500, hitAnimTime2 = 1900,hitAnimTime3 = 2300,hitEffShowOnce = 1, hitEff = { 102794, 102797} , hitEffType = {0,5},hitEffTime = {0},attackSoundTime = 400,attackSound = 27901, hitSound = 27902})
-- mapArray:push({ id = 2790101, remote = 1,moveDistance = 0,attackEff = {112793}, attackEffTime = {50}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = {112794,112795},hitEffType = {0,5} ,hitEffOffsetX = {-10},attackAnim = "skill2",attackSound = 2502, hitSound = 27904})

-- mapArray:push({ id = 2890100, remote = 1,moveDistance = 200,attackEff = {102893,102895}, needMoveSameRow = 1, attackEffTime = {0,100}, attackEffType = {2,5}, hitAnimTime1 = 3300, hitAnimTime2 = 3500,hitAnimTime3 = 3700, hitEff = {102892},attackSound = 28901 ,hitSound = 15})
-- mapArray:push({ id = 2890101, remote = 0,moveDistance = 200,attackEff = {112893}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 300, hitAnimTime2 = 800,hitAnimTime3 = 1350, hitEff = {102892},attackAnim = "skill2",hitEffOffsetY = {-20},hitEffTime = {0},attackSound = 100101,hitSound = 22})

-- mapArray:push({ id = 2900100, remote = 1,moveDistance = 0,attackEff = {102903,102904}, attackEffTime = {0,1500}, attackEffType = {0,10}, attackEffOffsetY = {0,110}, attackEffOffsetX = {0,-350}, hitAnimTime1 = 1500 ,hitAnimTime2 = 2000 , hitAnimTime3 = 2300, hitEffShowOnce =1, hitEff = {0 }, hitEffType={0},attackSound = 29001,hitSound = 0})--
-- mapArray:push({ id = 2900101, remote = 0,moveDistance = 90,attackEff = {112903}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 550,hitAnimTime2 = 1550, hitEff = {0} , attackEffOffsetX = {-30} ,attackEffOffsetY = {-20} ,attackAnim = "skill2",attackSoundTime = 0,attackSound = 29002,hitSound = 0})

-- --1.22
-- mapArray:push({ id = 2520100, remote = 1,moveDistance = 0, needMoveCenter = 1,attackEff = {25201},  attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000,hitAnimTime2 = 1200,hitAnimTime3 = 1400, hitEff = { 0},attackSound = 25201,hitSound = 11})
-- mapArray:push({ id = 2520101, remote = 0,moveDistance = 120,attackEff = {112523}, attackEffTime = {0}, attackEffType = {0} ,hitAnimTime1 = 950, hitAnimTime2 = 1100,hitEff = { 0},attackAnim = "skill2",attackSound = 25202,hitSound = 15})

-- mapArray:push({ id = 2780100, remote = 1,moveDistance = 0, attackEff = {102783}, attackEffType = {0}, attackEffTime = {0}, hitAnimTime1 = 1500, hitAnimTime2 = 1800,hitAnimTime3 = 2200,hitEffShowOnce = 1,hitEff = { 102784},attackSound = 27801,hitSound = 12,hitEffTime = {0}})
-- mapArray:push({ id = 2780101, remote = 1,moveDistance = 0, attackEff = {112785}, needMoveSameRow = 1,xuliEff = 112783, attackEffTime = {400}, attackEffType = {3} ,attackEffOffsetX = {130}, hitAnimTime1 = 600,hitEffOffsetY = {-50},hitEffOffsetX = {-10}, hitEff = { 112784},attackAnim = "skill2",attackSound = 27802,hitSound = 21})

-- --2.18
-- mapArray:push({ id = 280, remote = 0, moveDistance = 110,attackEff = {102801}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 250,hitAnimTime2 = 550,hitAnimTime3 =850,attackAnim = "attack",hitEff = { 0},hitEffTime = {0},hitSound = 21, attackSound = 0})--

-- mapArray:push({ id = 2800100, remote = 1,moveDistance = 0,attackEff = {102803}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, extraEffTime = {0,2050},hitEff = { 102804,102806},extraEff = { 0,102807 },extraEffType = {0},hitEffType = {0,5,0}, hitAnimTime1 = 750,hitEffOffsetX = {0,-15,-15}, hitEffOffsetY = {0,-8,0},hitEffTime = {0,0,2000},attackSound = 28001,hitSound = 0})
-- mapArray:push({ id = 2800101, remote = 1,moveDistance = 0,attackEff = {112803}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 800, hitEffOffsetX= {-20}, hitEff = {112804},attackAnim = "skill2",attackSound = 28002,attackSoundTime = 500,hitSound = 0})

-- --3.28
-- mapArray:push({ id = 295, remote = 0, moveDistance = 110,attackEff = {102951}, attackEffTime = {250},attackEffType = {0},hitAnimTime1 = 250,hitAnimTime2 = 850,attackAnim = "attack",hitEff = { 0},hitEffTime = {0},hitSound = 2602,hitSoundTime = -40000, attackSound = 0})
-- mapArray:push({ id = 2950100, remote = 1,moveDistance = 200,attackEff = {102952}, needMoveSameRow = 1, attackEffTime = {1200}, attackEffType = {2}, hitAnimTime1 = 2900, hitEff = {102953},hitEffOffsetY={90},hitEffOffsetX={-80},hitEffTime = {0},effectScale = {1,1.3,1.5},attackSound = 29501 ,attackSoundTime = 600,hitSound = 15})
-- mapArray:push({ id = 2950101, remote = 1,moveDistance = 0,attackEff = {0}, attackEffTime = {0},hitEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = { 0}, hitXuliEff = 102954,attackAnim = "skill2",attackSound = 0,hitSound = 12})

-- mapArray:push({ id = 296, remote = 0, moveDistance = 110,attackEff = {102961}, attackEffTime = {0},attackEffType = {0},hitAnimTime1 = 250,attackAnim = "attack",hitEff = { 0},hitEffTime = {0},hitSound = 1,hitSoundTime = 10,attackSound = 0})
-- mapArray:push({ id = 2960100, remote = 1, attackEff = {102964}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = {0}, attackSound = 29601})
-- mapArray:push({ id = 2960101, remote = 1, attackEff = {102967}, attackEffTime = {600}, attackEffType = {1},attackEffOffsetY= {100},hitEff = {0},attackAnim = "skill3",hitAnimTime1 = 1400, attackSound = 29602,hitSound = 12,hitEffShowOnce = 1})
-- mapArray:push({ id = 2960102, remote = 1,attackEff = {102968}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1000, hitEff = {1029610},attackAnim = "skill2",attackSound = 2202,hitSound = 14})

-- mapArray:push({ id = 308, remote = 0, moveDistance = 120,attackEff = {103081}, attackEffTime = {50},attackEffType = {0},hitAnimTime1 = 600,hitAnimTime2 = 1050,attackAnim = "attack",hitEffOffsetY = {0},hitEff = { 0},hitEffTime = {0},attackSoundTime = 0,hitSound = 21, attackSound = 100101})--

-- --mapArray:push({ id = 3080100, remote = 0,moveDistance = 180,attackEff = {103083,103085}, attackEffTime = {0,50}, attackEffType = {0,0},attackEffOffsetY={0,80},attackEffOffsetX={0,-50},hitAnimTime1= 400,hitAnimTime2 = 800,hitAnimTime3= 1200,hitAnimTime4= 1500, hitAnimTime5 = 2400,hitEffShowOnce = 1, hitEff = {103084},hitEffTime ={1900},hitEffType={0},hitEffOffsetX={-330},hitEffOffsetY={50},attackSound = 0,hitSound = 0})--, hitAnimTime2 = 2200,hitAnimTime3 = 2500
-- mapArray:push({ id = 3080100, remote = 0,moveDistance = 35,attackEff = {103083}, attackEffTime = {0}, attackEffType = {0},attackEffOffsetY={0},attackEffOffsetX={0},hitAnimTime1= 500,hitAnimTime2 = 900,hitAnimTime3= 1300,hitAnimTime4= 1600, hitAnimTime5 = 2400,hitEffShowOnce = 1, hitEff = {0},hitEffTime ={2000,0},hitEffType={0},hitEffOffsetX={-310,-340},hitEffOffsetY={50,60},attackSound = 30801,hitSound = 0})--, hitAnimTime2 = 2200,hitAnimTime3 = 2500
-- mapArray:push({ id = 3080101, remote = 1,moveDistance = 0,attackEff = {113083}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0,hitAnimTime2 = 200,hitEffShowOnce = 1, hitEff = {113084},attackAnim = "skill2",attackSound = 30802,hitSound = 0})

-- mapArray:push({ id = 298, remote = 0, moveDistance = 150,attackEff = {102981}, attackEffTime = {50},attackEffType = {0},hitAnimTime1 = 600,attackAnim = "attack",hitEffOffsetY = {0},hitEff = { 0},hitEffTime = {0},attackSoundTime = 0, hitSound = 32})--
-- mapArray:push({ id = 2980100, remote = 0,moveDistance = 200,attackEff = {102984}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 1800,hitEff = {102982},hitEffOffsetY={-20},hitEffOffsetX={10},hitEffTime = {0},attackSound = 29801,hitSound = 0})
-- mapArray:push({ id = 2980102, remote = 1,moveDistance = 0,attackEff = {102988,102989}, attackEffTime = {0,0}, attackEffType = {0,5}, hitAnimTime1 = 500,  hitEff = {102983},attackAnim = "skill3",attackSound = 28002,attackSoundTime = 500,hitSound = 0})
-- mapArray:push({ id = 2980101, remote = 1,moveDistance = 0,attackEff = {102985,102986}, attackEffTime = {0,450}, attackEffOffsetY= {0,0},attackEffType = {0,3}, attackAnim = "skill2",hitAnimTime1 = 700,hitEff = {102987},hitEffOffsetY = {100},hitEffTime = {0},attackSound = 16802,hitSound = 0})

-- mapArray:push({ id = 297, remote = 0, moveDistance = 230,attackEff = {102971}, attackEffTime = {50},attackEffType = {0},hitAnimTime1 = 600,attackAnim = "attack",hitEffOffsetY = {0},hitEff = { 0},hitEffTime = {0},attackSoundTime = 0,hitSound = 42, attackSound = 6901})--
-- mapArray:push({ id = 2970100, remote = 1, attackEff = {102972,102973,102975}, attackEffTime = {0,0,3500}, attackEffType = {0,0,1},attackEffOffsetY = {0,0,70}, attackEffOffsetX = {0,0,105}, hitEff = {101022},hitAnimTime1 = 2700,hitAnimTime2 = 2800,hitAnimTime3 = 3500, attackSound = 29701,hitSound = 12,hitEffShowOnce = 1})
-- mapArray:push({ id = 2970101, remote = 0, moveDistance = 230,attackEff = {102976}, attackEffTime = {0}, attackEffType = {0},attackEffOffsetY = {0}, attackEffOffsetX = {0}, hitEff = {102974},hitEffOffsetY = {-20},attackAnim = "skill2",hitAnimTime1 = 800,hitAnimTime2 = 1400,attackSound = 102,hitSound = 12})

-- mapArray:push({ id = 299, remote = 0, moveDistance = 230,attackEff = {102991}, attackEffTime = {50},attackEffType = {0},hitAnimTime1 = 250,hitAnimTime2 = 700,hitAnimTime3 = 1200,attackAnim = "attack",hitEffOffsetY = {0},hitEff = { 0},hitEffTime = {0},attackSoundTime = 0,hitSound = 21, attackSound = 0})--
-- mapArray:push({ id = 2990100, remote = 1, attackEff = {102992}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = {0}, attackSound = 27901})
-- mapArray:push({ id = 2990101, remote = 1, attackEff = {102993,102994}, attackEffTime = {650}, attackEffType = {0},attackAnim = "skill2",hitAnimTime1 = 0,hitSoundTime = 650,hitSound = 28002})


-- --伏魔录boss
-- mapArray:push({ id = 60003, remote = 0, moveDistance = 230,attackEff = {101581}, attackEffTime = {0}, attackEffType = {0},hitEff = { 101022},hitAnimTime1 = 200,attackAnim = "attack",attackSound = 15801,hitSound = 42})

-- --mapArray:push({ id = 2, remote = 0,moveDistance = 0,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = { 0},attackSound = 202,hitSound = 13})
-- --mapArray:push({ id = 1, remote = 0,moveDistance = 0,attackEff = {0}, attackEffTime = {0}, attackEffType = {0}, hitAnimTime1 = 0, hitEff = {0},attackAnim = "skill2",attackSound = 402,hitSound = 13})