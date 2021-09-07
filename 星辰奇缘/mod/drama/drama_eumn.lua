-- --------------------------
-- 剧情枚举
-- --------------------------
DramaEumn = DramaEumn or {}

-- 剧情动作枚举
DramaEumn.ActionType = {
     Opensys = 1-- 开启新功能
    ,Endplot = 2-- 剧情结束动作
    ,Camerareset = 100-- 镜头重置
    ,Cameramoveto = 101-- 镜头移动到点
    ,Camerafollow = 102-- 镜头跟随单位
    ,Camerazoom = 103-- 镜头在指定时间内缩放到特定比率
    ,Camerashake = 104-- 镜头以指定模式晃动
    ,Camerafilter = 105-- 镜头执行指定的滤镜
    ,Pressscreen = 106-- 压屏
    ,Animationplay = 200-- 播放指定动画
    ,Animationplayonrole = 201-- 在角色身上播放指定特效动画
    ,Animationplayonunit = 202-- 在某个单位模型上播放指定的特效动画
    ,Animationplaypoint = 203-- 在某个点播放指定的特效动画
    ,Playplot = 204-- 播放剧本
    ,Prelude = 205-- 播放序幕
    ,Openpanel = 206-- 打开面板
    ,Closepanel = 207-- 关闭面板
    ,Playguide = 208-- 播放指引
    ,Closeguide = 209-- 关闭指引
    ,Hide = 210-- 屏蔽模式
    ,Unlockpanel = 211-- 解锁窗口
    ,Getuseitem = 212-- 获得使用物品
    ,Actrole = 213-- 角色动作
    ,Actunit = 214-- 单位动作
    ,Unitdir = 215-- 单位方向
    ,Playeffect = 216-- 播放特效
    ,Getuseitems = 217-- 获得使用物品(批量)
    ,Studyskill = 219-- 学习技能
    ,Playtalk = 220-- 播放对白
    ,Multiaction = 221--多动作
    ,Inter_monologue = 222--内心独白
    ,First_pet = 223--活的宠物
    ,PetItemSkillGuide = 224--获得一本宠物技能书
    ,Soundplay = 300-- 播放声音
    ,Rescache = 400-- 通知客户端预加载资源
    ,Unittalk = 401-- 播放单位对白
    ,Unittalkbubble = 402-- 播放单位泡泡
    ,Roletalk = 403-- 播放角色对白
    ,Roletalkbubble = 404-- 播放角色泡泡
    ,Plotunitcreate = 405-- 创建剧情单位
    ,Plotunitmove = 406-- 剧情单位移动
    ,Plotunitmoverole = 407-- 剧情单位移动到角色旁边
    ,Plotunitdel = 408-- 剧情单位移除
    ,Plotunitsetlooks = 409-- 剧情单位更新外观
    ,Modcache = 410-- 通知客户端预加载模块
    ,Roleselect = 411-- 角色选择性动作
    ,Unitselect = 412-- 单位选择性动作
    ,Unittalkhead = 413-- 播放单位头顶对白
    ,Roletalkhead = 414-- 播放角色头顶对白
    ,Unittalkface = 415-- 播放单位表情泡泡
    ,Roletalkface = 416-- 播放角色表情泡泡
    ,Role_jump = 417--角色跳跃
    ,Wayfindingpoint = 500-- 寻路到场景
    ,Wayfinding = 501-- 寻路到指定单位旁边
    ,Roledir = 502-- 角色朝向
    ,Transmit = 503-- 角色漂移
    ,Worldmap = 504-- 世界地图
    ,Useitem = 505-- 通知客户端使用使用指定物品
    ,Questtrace = 506-- 任务追踪
    ,Wait = 600 --等待
    ,WaitClient = 601 --等待(客户端做延时处理)
    ,CustomMultiaction = 602 --新增自定义多动作
    -- 自己加的，客户端用
    ,TouchNpc = 900 -- 操作npc

}

-- 一次性引导类型
DramaEumn.OnceGuideType = {
    PetAddpoint = 1, -- 宠物加点
    OfferQuest = 2, -- 悬赏任务
    Arena = 3, -- 竞技场
    GuardHelp = 4, -- 守护助战
}