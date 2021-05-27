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
                                                    --【剧情目录-红名村-大剧情】--
-------------------------------------------------------------------------------------------------------------------------

return     
	{
		{next_time = 1, actor = "300##curtain", action = "born"},
		{next_time = 0, actor = "999##main_role", action = "disappear##1"},
        {next_time = 0, actor = "10000##camera", action = "fly##31##35"},
        {next_time = 1, actor = "10##role||11##role||12##role||13##role", action = "born##纳斯丁阿凡提##10##29##38##7##100##100##3500##0##0##10##0||born##柔弱女子##21##30##38##3##100##100##3500##0##1##0##0||born##无辜女子##21##26##32##4##100##100##3500##0##1##0##0||born##纤弱女子##31##34##32##6##100##100##3500##0##1##0##0"},
		{next_time = 2, actor = "300##curtain", action = "disappear##2##0##1"},
        {next_time = 2, actor = "1000##npc##2", action = "dialog##{colorandsize;ff00ff;28;柔弱女子}\n 救命啊！来人啊！救命啊！"},

        
        {next_time = 0, actor = "10##role", action = "do_attack##3##2"},
        {next_time = 0.5, actor = "11##role||11##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
        {next_time = 0, actor = "10##role", action = "do_attack##3##2"},
        {next_time = 1, actor = "11##role||11##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 1, actor = "200##fall_item||201##fall_item||202##fall_item||203##fall_item||204##fall_item", action = "born##3002##绑金##0xFFFFFF##30##38||born##63##赤血道衣(女)##0x00FF00##29##38||born##2130##传世宝刃##0xff8a00##30##37||born##3012##200元宝##0xff8a00##29##37||born##676##超级经验丹##0xff8a00##31##38"},
        
        {next_time = 1, actor = "10##role", action = "move##27##32##1000"},
        {next_time = 0, actor = "10##role", action = "do_attack##7##6"},
        {next_time = 0.5, actor = "12##role||12##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
        {next_time = 0, actor = "10##role", action = "do_attack##7##6"},
        {next_time = 1, actor = "12##role||12##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 1, actor = "210##fall_item||211##fall_item||212##fall_item||213##fall_item||214##fall_item", action = "born##683##超级金条##0xff0000##26##32||born##22##圣武战刃##0xde00ff##25##32||born##310##圣武战盔##0xde00ff##27##32||born##2132##传世宝铠##0xff8a00##26##31||born##2143##王·传世宝链##0xff0000##26##33"},
        
        {next_time = 1, actor = "10##role", action = "move##33##32##1000"},
        {next_time = 0, actor = "10##role", action = "do_attack##6##2"},
        {next_time = 0.5, actor = "13##role||13##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
        {next_time = 0, actor = "10##role", action = "do_attack##6##2"},
        {next_time = 1, actor = "13##role||13##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 1, actor = "220##fall_item||221##fall_item||222##fall_item||223##fall_item||224##fall_item", action = "born##113##龙武战甲(女)##0xff0000##34##32||born##117##龙武道衣(女)##0xff0000##34##31||born##378##龙武道镯##0xff0000##34##33||born##281##裂天魔链##0x00c0ff##33##32||born##308##真武道带##0xde00ff##35##32"},
		{next_time = 2, actor = "1001##npc##1", action = "dialog##{colorandsize;ff00ff;28;纳斯丁阿凡提}\n 哈哈哈，为所欲为的感觉真好！"},

        {next_time = 0.5, actor = "1##clone_main_role", action = "born##33##11##2"},
        {next_time = 1, actor = "10000##camera", action = "fly##33##11"},
        {next_time = 3, actor = "1002##main_role", action = "dialog##{colorandsize;ff00ff;28;main_role_name}\n 如此恶行，实在无法容忍！原来这就是罪犯聚集的红名村，让我来将你们一一撕碎，为民除害！"},
        {next_time = 1, actor = "1##clone_main_role||10000##camera", action = "move##31##34##2500||move##31##34##500"},

        {next_time = 2, actor = "10##role", action = "move##31##33##500"},
        {next_time = 0, actor = "1##clone_main_role||10##role", action = "do_attack##0##4||do_attack##3##0"},
        {next_time = 0.5, actor = "10##role||10##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
        {next_time = 0, actor = "1##clone_main_role||10##role", action = "do_attack##0##4||do_attack##3##0"},
        {next_time = 1, actor = "10##role||10##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},

		{next_time = 2, actor = "1001##npc##1", action = "dialog##{colorandsize;ff00ff;28;纳斯丁阿凡提}\n 小子，你给我等着，老子这就喊人砍死你！"},

    }   