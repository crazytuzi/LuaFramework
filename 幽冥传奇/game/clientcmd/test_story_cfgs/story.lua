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
                                                    --【剧情目录-新手村-大剧情】--
-------------------------------------------------------------------------------------------------------------------------


return 
    {
		{next_time = 1, actor = "300##curtain", action = "born"},
        {next_time = 0, actor = "999##main_role", action = "disappear##1"},
 
        {next_time = 0, actor = "400##subtitle", action = "born##1.2##0.9##500##40##center##{colorandsize;ffffff;30;哇，感觉好厉害的样子。。}{face;3}{face;3}{face;3}"},
        {next_time = 0, actor = "401##subtitle", action = "born##1.2##0.5##500##40##center##{colorandsize;ffffff;30;听说这游戏不错，过来看看。。}{face;110}{face;110}"},
        {next_time = 0, actor = "402##subtitle", action = "born##1.2##0.7##500##40##center##{colorandsize;ffffff;30;6666666666666}{face;105}"},
        {next_time = 0, actor = "403##subtitle", action = "born##1.2##0.6##500##40##center##{colorandsize;ffffff;30;欢迎各位dalao}{face;107}{face;107}"},
        {next_time = 0, actor = "404##subtitle", action = "born##1.2##0.8##500##40##center##{colorandsize;ffffff;30;坐看土豪开车}{face;132}{face;132}"},
        {next_time = 0, actor = "405##subtitle", action = "born##1.2##0.5##500##40##center##{colorandsize;ffffff;30;这么多人？}"},
        {next_time = 0, actor = "406##subtitle", action = "born##1.2##0.2##500##40##center##{colorandsize;ffffff;30;好多装备啊}{face;04}"},
        {next_time = 0, actor = "407##subtitle", action = "born##1.2##0.9##500##40##center##{colorandsize;ffffff;30;怎么获得这个技能的？}"},
        {next_time = 0, actor = "408##subtitle", action = "born##1.2##0.5##500##40##center##{colorandsize;ffffff;30;这技能有点厉害哦}{face;13}"},
        {next_time = 0, actor = "409##subtitle", action = "born##1.2##0.4##500##40##center##{colorandsize;ffffff;30;这霸者之怒看起来很强啊}"},
        {next_time = 0, actor = "410##subtitle", action = "born##1.2##0.9##500##40##center##{colorandsize;ffffff;30;不错啊 有当年传奇的感觉}{face;04}"},
        {next_time = 0, actor = "411##subtitle", action = "born##1.2##0.7##500##40##center##{colorandsize;ffffff;30;组会啦 一起玩的拉下}"},
        {next_time = 0, actor = "412##subtitle", action = "born##1.2##0.5##500##40##center##{colorandsize;ffffff;30;前排围观}{face;21}"},
        {next_time = 0, actor = "413##subtitle", action = "born##1.2##0.7##500##40##center##{colorandsize;ffffff;30;感觉很大型耶}"},
        {next_time = 0, actor = "414##subtitle", action = "born##1.2##0.3##500##40##center##{colorandsize;ffffff;30;有一起玩的吗？？？开个行会啊}{face;22}"},
        {next_time = 0, actor = "415##subtitle", action = "born##1.2##0.6##500##40##center##{colorandsize;ffffff;30;起飞啊兄弟们}"},
        {next_time = 0, actor = "416##subtitle", action = "born##1.2##0.8##500##40##center##{colorandsize;ffffff;30;看到今天开服过来玩下}"},
        {next_time = 0, actor = "417##subtitle", action = "born##1.2##0.5##500##40##center##{colorandsize;ffffff;30;好玩吗？这个游戏}{face;111}"},
        {next_time = 0, actor = "418##subtitle", action = "born##1.2##0.9##500##40##center##{colorandsize;ffffff;30;好玩啊 一起啊}{face;101}"},
        {next_time = 0, actor = "419##subtitle", action = "born##1.2##0.8##500##40##center##{colorandsize;ffffff;30;打起来不错啊}{face;110}"},
        {next_time = 0, actor = "420##subtitle", action = "born##1.2##0.7##500##40##center##{colorandsize;ffffff;30;可以玩玩}{face;127}"},

		{next_time = 1, actor = "300##curtain", action = "disappear##2##0##1"},
        {next_time = 0, actor = "1##clone_main_role||100##role||101##role", action = "born##70##23##7||born##天下-霸唱##10##39##41##2##100##100##3500##0##0##10##0||born##天下-小主##11##39##43##5##100##100##3500##0##1##10##0"},
        {next_time = 0, actor = "110##role||111##role", action = "born##情谊-绝世##10##58##59##4##100##100##3500##0##0##10##0||born##情谊-素素##11##59##59##6##100##100##3500##0##1##10##0"},
        {next_time = 0, actor = "120##role||121##role", action = "born##烽烟-叶天##10##70##23##3##100##100##3500##0##0##10##0||born##烽烟-菲菲##11##70##23##0##100##100##3500##0##1##10##0"},
        {next_time = 0, actor = "130##role||131##role", action = "born##热血-藏决##20##70##23##1##100##100##3500###0##20##0||born##热血-雅致##21##70##23##7##100##100##3500##0##1##20##0"},
        {next_time = 0, actor = "140##role||141##role", action = "born##浩世-明烈##30##70##23##2##100##100##3500###0##30##0||born##绯月-天鸢##31##70##23##6##100##100##3500##0##1##30##0"},

        {next_time = 2, actor = "10000##camera||10000##camera", action = "fly##39##41||shake##1"},
        {next_time = 0, actor = "416##subtitle", action = "move##-1##0.8##10"},
        {next_time = 0, actor = "417##subtitle", action = "move##-1##0.5##10"},
        {next_time = 1, actor = "100101##effect", action = "born##39##41##35##1####1##0"},       
        {next_time = 0.5, actor = "418##subtitle", action = "move##-1##0.9##10"},



        {next_time = 0, actor = "100##role||101##role||10000##camera", action = "move##53##46##2500||move##60##42##2500||move##59##50"},
        {next_time = 0, actor = "110##role||111##role", action = "move##59##51##2500||move##54##46##3500"},
        {next_time = 0, actor = "120##role||121##role", action = "move##63##46##3500||move##59##50##3500"},
        {next_time = 0, actor = "130##role||131##role", action = "move##59##41##3500||move##64##45##2500"},
        {next_time = 3, actor = "140##role||141##role", action = "move##59##46##3500||move##60##46##3500"},
        {next_time = 0, actor = "400##subtitle", action = "move##-1##0.9##10"},
        {next_time = 0, actor = "401##subtitle", action = "move##-1##0.5##10"},
        {next_time = 0, actor = "402##subtitle", action = "move##-1##0.7##10"},
        {next_time = 0, actor = "403##subtitle", action = "move##-1##0.6##10"},
        {next_time = 3, actor = "1000##npc##3", action = "dialog##{colorandsize;ff00ff;28;天下-霸唱}\n 天下纷乱，战火燎原，各为其主，今日在此与各位决一高低。尽管来吧！"},
        
        {next_time = 0, actor = "413##subtitle", action = "move##-1##0.7##10"},
        {next_time = 0, actor = "100##role||111##role", action = "do_attack##4##2##0||do_attack##8##6##0"},
        {next_time = 0, actor = "110##role||121##role", action = "do_attack##6##4##0||do_attack##7##0##0"},
        {next_time = 0, actor = "120##role||131##role", action = "do_attack##7##3##0||do_attack##18##7##0"},
        {next_time = 0, actor = "130##role||101##role", action = "do_attack##17##1##0||do_attack##6##5##0"},
        {next_time = 1, actor = "140##role||141##role", action = "do_attack##27##2##0||do_attack##28##6##0"},
        {next_time = 0, actor = "100001##effect", action = "born##63##46##12##1####1##0"},
        {next_time = 0, actor = "100002##effect", action = "born##59##50##37##1####1##0"},
        {next_time = 0, actor = "100003##effect", action = "born##60##46##16##1####1##0"},
        {next_time = 0.5, actor = "100004##effect", action = "born##59##46##27##1####1##0"},
 
        {next_time = 0, actor = "404##subtitle", action = "move##-1##0.8##10"},
        {next_time = 0, actor = "405##subtitle", action = "move##-1##0.5##10"},
        {next_time = 0, actor = "406##subtitle", action = "move##-1##0.2##10"},

        {next_time = 0, actor = "100##role||100##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
        {next_time = 0, actor = "101##role||101##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
        {next_time = 0, actor = "110##role||110##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
        {next_time = 0, actor = "111##role||111##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
        {next_time = 0, actor = "120##role||120##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
        {next_time = 0, actor = "121##role||121##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
        {next_time = 0, actor = "130##role||130##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
        {next_time = 0, actor = "131##role||131##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
        {next_time = 0, actor = "140##role||140##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},
        {next_time = 0, actor = "141##role||141##role", action = "change_obj_attr##max_inner##100||change_obj_attr##inner##0"},

        {next_time = 0, actor = "415##subtitle", action = "move##-1##0.6##10"},
        {next_time = 0, actor = "400##subtitle", action = "disappear##1"},       

        {next_time = 0, actor = "100##role||111##role", action = "do_attack##4##2##0||do_attack##8##6##0"},
        {next_time = 0, actor = "110##role||121##role", action = "do_attack##6##4##0||do_attack##7##0##0"},
        {next_time = 0, actor = "120##role||131##role", action = "do_attack##7##3##0||do_attack##18##7##0"},
        {next_time = 0, actor = "130##role||101##role", action = "do_attack##17##1##0||do_attack##6##5##0"},
        {next_time = 1, actor = "140##role||141##role", action = "do_attack##27##2##0||do_attack##28##6##0"},
        {next_time = 0, actor = "100201##effect", action = "born##63##46##12##1####1##0"},
        {next_time = 0, actor = "100202##effect", action = "born##59##50##37##1####1##0"},
        {next_time = 0, actor = "100203##effect", action = "born##60##46##16##1####1##0"},
        {next_time = 0.5, actor = "100204##effect", action = "born##59##46##27##1####1##0"},
        {next_time = 0, actor = "101##role||101##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 0, actor = "110##role||110##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##50"},
        {next_time = 0, actor = "111##role||111##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 0, actor = "120##role||120##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##50"},
        {next_time = 0, actor = "121##role||121##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 0, actor = "130##role||130##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##50"},
        {next_time = 0, actor = "131##role||131##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 0, actor = "140##role||140##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 0, actor = "141##role||141##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 1, actor = "200##fall_item||201##fall_item||202##fall_item||203##fall_item", action = "born##3002##绑金##0xFFFFFF##60##42||born##19##真武战刃##0xde00ff##54##46||born##2130##传世宝刃##0xff8a00##59##50||born##3012##200元宝##0xff8a00##65##45"},

        {next_time = 0, actor = "414##subtitle", action = "move##-1##0.3##10"},
        {next_time = 0, actor = "100##role||110##role", action = "move##58##48##1000||move##59##48##1000"},
        {next_time = 2, actor = "120##role||130##role", action = "move##58##43##1000||move##59##43##1000"},
        {next_time = 0, actor = "100##role||110##role", action = "do_attack##4##2##0||do_attack##8##6##0"},
        {next_time = 0, actor = "120##role||130##role", action = "do_attack##6##2##0||do_attack##17##6##0"},
        {next_time = 0, actor = "100002##effect", action = "born##74##66##37##1####1##0"},
        {next_time = 0, actor = "110##role||110##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 0, actor = "120##role||120##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##25"},
        {next_time = 0, actor = "130##role||130##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 1, actor = "210##fall_item||211##fall_item", action = "born##338##洪武魔带##0xff8a00##59##48||born##309##真武道靴##0xde00ff##59##43"},

        {next_time = 0, actor = "410##subtitle", action = "move##-1##0.9##10"},
        {next_time = 0, actor = "411##subtitle", action = "move##-1##0.7##10"},
        {next_time = 0, actor = "412##subtitle", action = "move##-1##0.5##10"},

        {next_time = 2, actor = "100##role||120##role", action = "move##59##46##500||move##58##46##500"},
        {next_time = 0, actor = "100##role||120##role", action = "do_attack##6##6##0||do_attack##7##2##0"},
        {next_time = 0, actor = "120##role||120##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},
        {next_time = 1, actor = "220##fall_item||221##fall_item", action = "born##1535##3级物攻宝石##0x00ff00##58##46"},
		{next_time = 1, actor = "101##role||110##role||111##role||120##role||121##role||130##role||131##role||140##role||141##role", action = "disappear##2##0##1||disappear##2##0##1||disappear##2##0##1||disappear##2##0##1||disappear##2##0##1||disappear##2##0##1||disappear##2##0##1||disappear##2##0##1||disappear##2##0##1"},

        {next_time = 0, actor = "419##subtitle", action = "move##-1##0.8##10"},
        {next_time = 0, actor = "420##subtitle", action = "move##-1##0.7##10"},

        {next_time = 3, actor = "1000##npc##3", action = "dialog##{colorandsize;ff00ff;28;天下-霸唱}\n 看来最强行会还属我们，我看还有谁敢上决一死战？"},
        {next_time = 3, actor = "1000##main_role", action = "dialog##{colorandsize;ff00ff;28;main_role_name}\n 还有我！谁怕谁！不试试怎知雌雄？"},
        {next_time = 3, actor = "1##clone_main_role", action = "move##58##46##2500"},
        {next_time = 3, actor = "1000##main_role", action = "dialog##{colorandsize;ff00ff;28;main_role_name}\n 感受霸者的怒火吧！"},
        {next_time = 0, actor = "100##role||1##clone_main_role", action = "do_attack##5##6##0||do_attack##31##2##0"},
        {next_time = 1, actor = "100102##effect", action = "born##58##46##28##1####1##0"},
        {next_time = 0, actor = "100##role||100##role", action = "change_obj_attr##max_hp##100||change_obj_attr##hp##0"},

        {next_time = 0, actor = "407##subtitle", action = "move##-1##0.9##10"},
        {next_time = 0, actor = "408##subtitle", action = "move##-1##0.5##10"},
        {next_time = 0, actor = "409##subtitle", action = "move##-1##0.4##10"},

        {next_time = 1, actor = "230##fall_item||231##fall_item", action = "born##2131##传世宝甲##0xff8a00##59##46"},
        {next_time = 3, actor = "1000##main_role", action = "dialog##{colorandsize;ff00ff;28;main_role_name}\n 最强不过如此，夺城之日指日可待。"},
    }