--+----------------------------------------------------------------------------------------------------------------------
--| next_time     进入下一步骤时间
--+----------------------------------------------------------------------------------------------------------------------
--| action        action##xxx||action##xxx   ##：参数分隔符号, xxx：动作参数, ||：可连接多个动作(和actor对象一一对应)
--+----------------------------------------------------------------------------------------------------------------------
--| "born",                  --生成对象                  参数：actor##xxx##xxx##xxx
--| "dialog",                --对话                      参数：对话内容 dialog##"{colorandsize;ff00ff;28;祖煌}\n 喂，小子"
--| "appear",                --出现                      参数：出现类型(1直接出现,2淡入)#特效id#淡入时间（秒）
--| "disappear",             --消失                      参数：消失类型(1直接消失,2淡出)#特效id#淡出时间（秒）
--| "move",                  --移动                      参数：x#y#速度或时间
--| "moveback",              --移动回去                  参数：无
--| "fly",                   --直接飞到某地              参数：x#y
--| "flyback",               --飞回原地                  参数：x#y
--| "donothing",             --不做任何事                参数：无
--| "do_attack",             --打人                      参数：skill_id#朝向#判断主角职业
--| "change_obj_attr",       --改变对象属性              参数：(hp:血量低于或等于零时，对象死亡, dir:方向, name:名字)#数值
--| "shake",                 --特效震动                  参数：震级(1,2,3)
--+----------------------------------------------------------------------------------------------------------------------
--| born 第一个参数 actor         id##actor||id##actor      id：场景对象唯一的标识, actor：对象类型, ||：可连接多个动作(和action一一对应)
--+----------------------------------------------------------------------------------------------------------------------
--| "clone_main_role",       --克隆主角                      生成对象参数：（x##y##朝向）
--| "role",                  --角色                          生成对象参数：（名字##模型资源id##x##y##朝向##最大血量##当前血量##移动速度##职业##性别##武器##翅膀）
--| "monster",               --怪物                          生成对象参数：（名字##模型资源id##x##y##朝向##最大血量##当前血量##移动速度）
--| "npc",                   --NPC                           生成对象参数：（名字##模型资源id##x##y）
--| "camera",                --摄象机
--| "effect",                --特效                          生成对象参数：（x##y##特效资源id##循环次数##播放速度##大小缩放因数##判断主角职业）
--| "curtain",               --幕布
--| "patting",               --插画
--| "fall_item",             --掉落物品                      生成对象参数：（icon资源id##物品名字##颜色值##x##y）
--| "main_role",             --主角
--+----------------------------------------------------------------------------------------------------------------------
--| change_obj_attr 所有可改变的属性
--+----------------------------------------------------------------------------------------------------------------------
--| max_hp			-- 最大hp
--| hp				-- hp(血量低于或等于零时，对象死亡)
--| max_inner		-- 最大内功值
--| inner			-- 当前内功值
--| dir				-- 朝向
--| name			-- 名字
--+----------------------------------------------------------------------------------------------------------------------
--| 其它说明
--+----------------------------------------------------------------------------------------------------------------------
--| 朝向dir  0:上 1:右上 2:右 3:右下 4:下 5:左下 6:左 7:左上
--+----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------
-- 改动以下配置(t表)，按下键盘"R"键热加载配置（不需要关闭游戏），按下键盘"F"键开始表演
-- 按下键盘"G"键，会在该文件底部生成当前配置的最终可提交的配置的show_list字段
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
                                                    --【剧情目录-王城-大剧情】--
-------------------------------------------------------------------------------------------------------------------------

return {
    {next_time = 2, actor = "10000##camera", action = "donothing"},
    {next_time = 0, actor = "12##role||13##role||14##role", action = "born##布拉格の无情##10##31##39##3##100##100##3500##0##1##10##14||born##布拉格の神灯##21##29##37##3##100##100##3500##0##0##20##12||born##布拉格の孤独##30##33##41##3##100##100##3500##0##0##30##11"},
    {next_time = 2, actor = "10000##camera", action = "fly##31##39"},
    {next_time = 0, actor = "999##main_role", action = "disappear##1"},
    {next_time = 0, actor = "1##clone_main_role||10##role||11##role", action = "born##51##11##7||born##狼族...山鸡##10##50##10##7##100##100##3500##0##0##10##0||born##狼族...浩南##11##52##12##7##100##100##3500##0##1##10##0"},
    {next_time = 1, actor = "10000##camera", action = "fly##51##11"},
    {next_time = 2, actor = "1000##main_role", action = "dialog##{colorandsize;ff00ff;28;main_role_name}\n 还记得当年王城一战，你们恃强凌弱，以多欺少。今日必将报一箭之仇！"},
    {next_time = 2, actor = "10000##camera||10000##camera", action = "fly##31##39||shake##2"},
    {next_time = 2, actor = "1001##npc##4", action = "dialog##{colorandsize;ff00ff;28;布拉格の无情}\n 无毛小儿还敢叫嚣，拿刀来战。"},
    {next_time = 1, actor = "10000##camera", action = "fly##64##13"},
    {next_time = 3, actor = "1002##main_role", action = "dialog##{colorandsize;ff00ff;28;main_role_name}\n 冲啊，弟兄们，为了荣耀！"},
    {next_time = 2.5, actor = "1##clone_main_role||10##role||11##role||10001##camera", action = "move##32##38##3500||move##30##36##3500||move##34##40##3900||move##32##38##500"},
    {next_time = 0, actor = "1##clone_main_role||12##role", action = "do_attack##0##7||do_attack##3##3"},
    {next_time = 0, actor = "10##role||13##role", action = "do_attack##7##7||do_attack##12##3"},
    {next_time = 1, actor = "11##role||14##role", action = "do_attack##6##7||do_attack##28##3"},
    {next_time = 0, actor = "100000##effect", action = "born##30##36##3##1####1##0"},
    {next_time = 0.5, actor = "100001##effect", action = "born##34##40##27##1####1##0"},
    {next_time = 0, actor = "1##clone_main_role||1##clone_main_role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
    {next_time = 0, actor = "10##role||10##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
    {next_time = 0.5, actor = "11##role||11##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
    {next_time = 0, actor = "1##clone_main_role||12##role", action = "do_attack##0##7||do_attack##3##3"},
    {next_time = 0, actor = "10##role||13##role", action = "do_attack##7##7||do_attack##12##3"},
    {next_time = 1, actor = "11##role||14##role", action = "do_attack##6##7||do_attack##28##3"},
    {next_time = 0, actor = "100000##effect", action = "born##30##36##3##1####1##0"},
    {next_time = 0.5, actor = "100001##effect", action = "born##34##40##27##1####1##0"},
    {next_time = 0, actor = "1##clone_main_role||1##clone_main_role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##50"},
    {next_time = 0, actor = "10##role||10##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
    {next_time = 0, actor = "11##role||11##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
    {next_time = 1, actor = "200##fall_item||201##fall_item", action = "born##358##神武道盔##0xff8a00##30##36||born##315##圣武战靴##0xde00ff##34##40"},
    {next_time = 1, actor = "13##role||14##role", action = "move##31##37##600||move##33##39##600"},
    {next_time = 0, actor = "1##clone_main_role||12##role", action = "do_attack##0##7||do_attack##3##3"},
    {next_time = 0.5, actor = "1##clone_main_role||1##clone_main_role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##25"},
    {next_time = 0.5, actor = "1##clone_main_role||12##role||13##role||14##role", action = "do_attack##3##7||do_attack##3##3||do_attack##12##1||do_attack##28##5"},
    {next_time = 0, actor = "100000##effect", action = "born##32##38##3##1####1##0"},
    {next_time = 0, actor = "100001##effect", action = "born##32##38##27##1####1##0"},
    {next_time = 0, actor = "1##clone_main_role||1##clone_main_role", action = "change_obj_attr##max_hp##25||change_obj_attr##hp##0"},
    {next_time = 2, actor = "210##fall_item", action = "born##364##龙武战盔##0xff0000##32##38"},
    {next_time = 1, actor = "10000##camera", action = "fly##51##11"},
    {next_time = 1, actor = "1##clone_main_role", action = "born##51##11##4"},
    {next_time = 3, actor = "1003##main_role", action = "dialog##{colorandsize;ff00ff;28;main_role_name}\n 一支穿云箭，千军万马来相见！兄弟们速来集合！！！"},
    {next_time = 0, actor = "10000##camera", action = "req_server_start_play"},
    {next_time = 2, actor = "1##clone_main_role", action = "do_attack##31##4"},
}