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
                                                    --【剧情目录-祖煌殿-大剧情】--
-------------------------------------------------------------------------------------------------------------------------

return {
        {next_time = 1, actor = "10000##camera", action = "donothing"},
        {next_time = 0, actor = "999##main_role", action = "disappear##1"},
        {next_time = 0, actor = "1##clone_main_role||11##monster||12##monster||13##monster||14##monster", action = "born##17##54##4||born##祖煌卫兵##8##16##55##3##100##100##3500||born##祖煌卫兵##8##18##55##5##100##100##3500||born##祖煌卫兵##8##16##53##1##100##100##3500||born##祖煌卫兵##8##18##53##7##100##100##3500"},
        {next_time = 1, actor = "10000##camera", action = "fly##17##54"},
        {next_time = 2, actor = "1000##npc##101", action = "dialog##{colorandsize;ff00ff;28;祖煌大司祭}\n 来人，给我抓住他！"},
        {next_time = 2, actor = "1001##main_role", action = "dialog##{colorandsize;ff00ff;28;main_role_name}\n 想抓我，没那么容易！霸者之怒！"},
        {next_time = 0, actor = "1##clone_main_role", action = "do_attack##31##4##0"},
        {next_time = 1, actor = "100001##effect", action = "born##17##54##28##1####1##0"},
        {next_time = 0, actor = "11##monster||11##monster", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 0, actor = "12##monster||12##monster", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 0, actor = "13##monster||13##monster", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 1, actor = "14##monster||14##monster", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 2, actor = "1002##npc##101", action = "dialog##{colorandsize;ff00ff;28;祖煌大司祭}\n 小子挺狂妄的，让我来会会你！"},
}