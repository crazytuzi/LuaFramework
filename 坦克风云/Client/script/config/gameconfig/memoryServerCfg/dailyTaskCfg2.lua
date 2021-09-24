dailyTaskCfg2={
    --经验基数
    exp={500,600,600,700,700,800,800,900,900,1000,1000,1100,1100,1200,1200,1200,1200,1300,1300,1300,1300,1300,1400,1400,1400,1400,1400,1500,1500,1500,1500,1500,1600,1600,1800,1900,2100,2300,2500,2700,2900,3100,3300,3600,3800,4100,4400,4700,5000,5400,5700,6100,6500,6900,7300,7700,8200,8700,9200,10300,113000,125000,139000,151000,164000,176000,187000,202000,215000,226000,235000,244000,251000,261000,268000,275000,285000,294000,302000,307000,313000,322000,332000,342000,351000,361000,372000,381000,392000,402000,410000,418000,428000,439000,451000,463000,474000,486000,499000,511000,523000,535000,547000,559000,571000,583000,595000,607000,619000,631000,643000,655000,667000,679000,691000,703000,715000,727000,739000,751000,},
    
    --资源基数
    resource={10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,12000,13000,15000,17000,20000,21000,24000,26000,30000,32000,37000,40000,45000,48000,54000,57000,64000,68000,75000,79000,89000,94000,104000,110000,122000,128000,142000,149000,164000,172000,186000,194000,210000,220000,237000,247000,267000,278000,300000,311000,334000,348000,372000,385000,409000,422000,449000,463000,492000,507000,543000,563000,601000,624000,666000,692000,738000,765000,816000,845000,895000,928000,984000,1019000,1078000,1119000,1183000,1228000,1298000,1346000,1418000,1467000,1550000,1604000,1688000,1747000,1853000,1917000,2033000,2104000,2175000,2246000,2317000,2388000,2459000,2530000,2601000,2672000,2743000,2814000,2885000,2956000,3027000,3098000,3169000,3240000,3311000,3382000,3453000,3524000,},
    
    --group：跳转
    --sortId：任务排序
    --require：完成条件
    --needLv：任务所需等级  等级未达到，任务不显示
    --switch：功能开关  开关未开，任务不显示
    --point：活跃点  完成任务获得的活跃点数
    --award1：变化奖励  奖励计算方式：根据玩家等级去相应经验/资源基数中取相应的数，乘以award1中的系数
    --award2：固定奖励
    --raising：军团资金
    task={
        [1]={
            s1001={sid="1001",type=4,group="15",schedule="schedule_count",name="daily_task_name_1001",description="daily_task_des_1001",style="TankLv1.png",sortId="1",require={10},needLv=1,point=10,award={u={{exp=0.1,index=1},{r1=0.5,index= 2}},p={{p19=5,index=3},{p3333=10,index=4}}}},
            s1002={sid="1002",type=4,group="30",schedule="schedule_count",name="daily_task_name_1002",description="daily_task_des_1002",style="Icon_zhu_ji_di.png",sortId="2",require={1},needLv=1,point=10,award={u={{exp=0.1,index=1},{r2=0.5,index= 2}},p={{p19=5,index=3},{p3333=10,index=4}}}},
            s1003={sid="1003",type=4,group="32",schedule="schedule_count",name="daily_task_name_1003",description="daily_task_des_1003",style="Icon_ke_yan_zhong_xin.png",sortId="3",require={1},needLv=1,point=10,award={u={{exp=0.1,index=1},{r3=0.5,index= 2}},p={{p19=5,index=3},{p3333=10,index=4}}}},
            s1004={sid="1004",type=4,group="2",schedule="schedule_count",name="daily_task_name_1004",description="daily_task_des_1004",style="tech_fight_exp_up.png",sortId="4",require={2},needLv=1,point=10,award={u={{exp=0.1,index=1},{r4=0.5,index= 2}},p={{p19=5,index=3},{p3333=10,index=4}}}},
            s1005={sid="1005",type=4,group="22",schedule="schedule_count",name="daily_task_name_1005",description="daily_task_des_1005",style="icon_build.png",sortId="8",require={1},needLv=8,switch="ifAccessoryOpen",point=15,award={u={{exp=0.1,index=1},{gold=1,index= 2}},e={{p3=3,index=3}},p={{p3333=10,index=4}}}},
            s1006={sid="1006",type=4,group="23",schedule="schedule_count",name="daily_task_name_1006",description="daily_task_des_1006",style="icon_supply_lines.png",sortId="9",require={1},needLv=8,switch="ifAccessoryOpen",point=15,award={u={{exp=0.1,index=1},{r1=0.5,index= 2}},e={{p2=2,index=3}},p={{p3333=10,index=4}}}},
            s1007={sid="1007",type=4,group="40",schedule="schedule_count",name="daily_task_name_1007",description="daily_task_des_1007",style="recruitIcon.png",sortId="11",require={2},needLv=20,switch="heroSwitch",point=15,award={u={{exp=0.12,index=1},{r2=0.5,index= 2}},p={{p819=1,index=3},{p3333=10,index=4}}}},
            s1008={sid="1008",type=4,group="41",schedule="schedule_count",name="daily_task_name_1008",description="daily_task_des_1008",style="heroEquipLabIcon.png",sortId="15",require={1},needLv=30,switch="heroSwitch,he",point=10,award={u={{exp=0.12,index=1},{r3=0.5,index= 2}},e={{p1=2,index=3}},p={{p3333=10,index=4}}}},
            s1009={sid="1009",type=4,group="26",schedule="schedule_count",name="daily_task_name_1009",description="daily_task_des_1009",style="Icon_mainui_02.png",sortId="5",require={5},needLv=1,point=15,award={u={{exp=0.12,index=1},{r4=0.5,index= 2}},a={{point=20,index=3}},p={{p3333=10,index=4}}},raising=20},
            s1010={sid="1010",type=4,group="25",schedule="schedule_count",name="daily_task_name_1010",description="daily_task_des_1010",style="icon_alliance_war.png",sortId="6",require={2},needLv=1,point=20,award={u={{exp=0.12,index=1},{r1=1,index= 2}},p={{p19=5,index=3},{p3333=10,index=4}}}},
            s1011={sid="1011",type=4,group="24",schedule="schedule_count",name="daily_task_name_1011",description="daily_task_des_1011",style="arenaIcon.png",sortId="10",require={3},needLv=10,switch="ma",point=20,award={u={{exp=0.12,index=1},{gold=2,index= 2}},p={{p601=1,index=3},{p3333=10,index=4}}}},
            s1012={sid="1012",type=4,group="42",schedule="schedule_count",name="daily_task_name_1012",description="daily_task_des_1012",style="sw_3.png",sortId="12",require={1},needLv=25,switch="ifSuperWeaponOpen",point=10,award={u={{exp=0.24,index=1},{r2=1,index= 2}},p={{p601=1,index=3},{p3333=10,index=4}}}},
            s1013={sid="1013",type=4,group="43",schedule="schedule_count",name="daily_task_name_1013",description="daily_task_des_1013",style="sw_2.png",sortId="13",require={1},needLv=25,switch="ifSuperWeaponOpen",point=10,award={u={{exp=0.24,index=1},{r3=1,index= 2}},p={{p601=1,index=3},{p3333=10,index=4}}}},
            s1014={sid="1014",type=4,group="44",schedule="schedule_count",name="daily_task_name_1014",description="daily_task_des_1014",style="epdtIcon.png",sortId="14",require={1},needLv=25,switch="expeditionSwitch",point=15,award={u={{exp=0.15,index=1},{gold=2,index= 2}},p={{p601=1,index=3},{p3333=15,index=4}}}},
            s1015={sid="1015",type=4,group="1",schedule="schedule_count",name="daily_task_name_1015",description="daily_task_des_1015",style="rebelIcon.png",sortId="7",require={1},needLv=1,switch="isRebelOpen",point=20,award={u={{exp=0.15,index=1},{gold=5,index= 2}},p={{p415=2,index=3},{p3333=20,index=4}}}},
            s1016={sid="1016",type=4,group="45",schedule="schedule_count",name="daily_task_name_1016",description="daily_task_des_1016",style="emblemBuildIcon.png",sortId="16",require={2},needLv=30,switch="emblemSwitch",point=15,award={u={{exp=0.3,index=1},{r4=1,index= 2}},p={{p415=2,index=3},{p3333=15,index=4}}}},
            s1017={sid="1017",type=4,group="31",schedule="schedule_count",name="daily_task_name_1017",description="daily_task_des_1017",style="resourse_normal_gem.png",sortId="17",require={300},needLv=1,point=30,award={u={{exp=0.2,index=1},{gold=3,index= 2}},p={{p1366=5,index=3},{p3333=20,index=4}}}},
        },
        [2]={
            s1001={sid="1001",type=4,group="15",schedule="schedule_count",name="daily_task_name_1001",description="daily_task_des_1001",style="TankLv1.png",sortId="1",require={10},needLv=1,point=10,award={u={{exp=0.12,index=1},{r1=2,index= 2}},p={{p19=5,index=3},{p3333=10,index=4}}}},
            s1002={sid="1002",type=4,group="30",schedule="schedule_count",name="daily_task_name_1002",description="daily_task_des_1002",style="Icon_zhu_ji_di.png",sortId="2",require={1},needLv=1,point=10,award={u={{exp=0.12,index=1},{r2=2,index= 2}},p={{p19=5,index=3},{p3333=10,index=4}}}},
            s1003={sid="1003",type=4,group="32",schedule="schedule_count",name="daily_task_name_1003",description="daily_task_des_1003",style="Icon_ke_yan_zhong_xin.png",sortId="3",require={1},needLv=1,point=10,award={u={{exp=0.12,index=1},{r3=2,index= 2}},p={{p19=5,index=3},{p3333=10,index=4}}}},
            s1004={sid="1004",type=4,group="2",schedule="schedule_count",name="daily_task_name_1004",description="daily_task_des_1004",style="tech_fight_exp_up.png",sortId="4",require={2},needLv=1,point=10,award={u={{exp=0.12,index=1},{r4=2,index= 2}},p={{p19=5,index=3},{p3333=10,index=4}}}},
            s1005={sid="1005",type=4,group="22",schedule="schedule_count",name="daily_task_name_1005",description="daily_task_des_1005",style="icon_build.png",sortId="8",require={1},needLv=8,switch="ifAccessoryOpen",point=15,award={u={{exp=0.12,index=1},{gold=4,index= 2}},e={{p3=5,index=3}},p={{p3333=10,index=4}}}},
            s1006={sid="1006",type=4,group="23",schedule="schedule_count",name="daily_task_name_1006",description="daily_task_des_1006",style="icon_supply_lines.png",sortId="9",require={1},needLv=8,switch="ifAccessoryOpen",point=15,award={u={{exp=0.12,index=1},{r1=2,index= 2}},e={{p2=4,index=3}},p={{p3333=10,index=4}}}},
            s1007={sid="1007",type=4,group="40",schedule="schedule_count",name="daily_task_name_1007",description="daily_task_des_1007",style="recruitIcon.png",sortId="11",require={2},needLv=20,switch="heroSwitch",point=15,award={u={{exp=0.15,index=1},{r2=2,index= 2}},p={{p819=2,index=3},{p3333=10,index=4}}}},
            s1008={sid="1008",type=4,group="41",schedule="schedule_count",name="daily_task_name_1008",description="daily_task_des_1008",style="heroEquipLabIcon.png",sortId="15",require={1},needLv=30,switch="heroSwitch,he",point=10,award={u={{exp=0.15,index=1},{r3=2,index= 2}},e={{p1=4,index=3}},p={{p3333=10,index=4}}}},
            s1009={sid="1009",type=4,group="26",schedule="schedule_count",name="daily_task_name_1009",description="daily_task_des_1009",style="Icon_mainui_02.png",sortId="5",require={5},needLv=1,point=15,award={u={{exp=0.15,index=1},{r4=2,index= 2}},a={{point=20,index=3}},p={{p3333=10,index=4}}},raising=20},
            s1010={sid="1010",type=4,group="25",schedule="schedule_count",name="daily_task_name_1010",description="daily_task_des_1010",style="icon_alliance_war.png",sortId="6",require={2},needLv=1,point=20,award={u={{exp=0.15,index=1},{r1=3,index= 2}},p={{p19=5,index=3},{p3333=10,index=4}}}},
            s1011={sid="1011",type=4,group="24",schedule="schedule_count",name="daily_task_name_1011",description="daily_task_des_1011",style="arenaIcon.png",sortId="10",require={3},needLv=10,switch="ma",point=20,award={u={{exp=0.15,index=1},{gold=4,index= 2}},p={{p601=2,index=3},{p3333=10,index=4}}}},
            s1012={sid="1012",type=4,group="42",schedule="schedule_count",name="daily_task_name_1012",description="daily_task_des_1012",style="sw_3.png",sortId="12",require={1},needLv=25,switch="ifSuperWeaponOpen",point=10,award={u={{exp=0.18,index=1},{r2=2,index= 2}},p={{p601=2,index=3},{p3333=10,index=4}}}},
            s1013={sid="1013",type=4,group="43",schedule="schedule_count",name="daily_task_name_1013",description="daily_task_des_1013",style="sw_2.png",sortId="13",require={1},needLv=25,switch="ifSuperWeaponOpen",point=10,award={u={{exp=0.18,index=1},{r3=2,index= 2}},p={{p601=2,index=3},{p3333=10,index=4}}}},
            s1014={sid="1014",type=4,group="44",schedule="schedule_count",name="daily_task_name_1014",description="daily_task_des_1014",style="epdtIcon.png",sortId="14",require={1},needLv=25,switch="expeditionSwitch",point=15,award={u={{exp=0.18,index=1},{gold=4,index= 2}},p={{p601=2,index=3},{p3333=15,index=4}}}},
            s1015={sid="1015",type=4,group="1",schedule="schedule_count",name="daily_task_name_1015",description="daily_task_des_1015",style="rebelIcon.png",sortId="7",require={1},needLv=1,switch="isRebelOpen",point=20,award={u={{exp=0.18,index=1},{gold=10,index= 2}},p={{p415=5,index=3},{p3333=20,index=4}}}},
            s1016={sid="1016",type=4,group="45",schedule="schedule_count",name="daily_task_name_1016",description="daily_task_des_1016",style="emblemBuildIcon.png",sortId="16",require={2},needLv=30,switch="emblemSwitch",point=15,award={u={{exp=0.45,index=1},{r4=2,index= 2}},p={{p416=10,index=3},{p3333=15,index=4}}}},
            s1017={sid="1017",type=4,group="31",schedule="schedule_count",name="daily_task_name_1017",description="daily_task_des_1017",style="resourse_normal_gem.png",sortId="17",require={300},needLv=1,point=30,award={u={{exp=0.24,index=1},{gold=6,index= 2}},p={{p1366=10,index=3},{p3333=20,index=4}}}},
        },
    },
    levelGroup={1,40},
    maxPoint=150,    --进度条最大活跃点
    finalTask={
        [1]={
            s2001={sid="2001",style="taskBox1.png",require={30},award={u={{honors=10,index=1}},p={{p3326=20,index=2}},u={{exp=2000,index=3}}}},
            s2002={sid="2002",style="taskBox2.png",require={60},award={u={{honors=20,index=1}},p={{p673=2,index=2}},u={{gems=10,index=3}}}},
            s2003={sid="2003",style="taskBox3.png",require={90},award={u={{honors=30,index=1}},p={{p416=2,index=2}},u={{gems=20,index=3}}}},
            s2004={sid="2004",style="taskBox4.png",require={120},award={u={{honors=40,index=1}},p={{p417=2,index=2}},u={{gems=30,index=3}}}},
            s2005={sid="2005",style="taskBox5.png",require={150},award={u={{honors=50,index=1}},p={{p3412=2,index=2}},u={{gems=60,index=3}}}},
        },
        [2]={
            s2001={sid="2001",style="taskBox1.png",require={30},award={u={{honors=10,index=1}},p={{p3326=20,index=2}},u={{exp=10000,index=3}}}},
            s2002={sid="2002",style="taskBox2.png",require={60},award={u={{honors=20,index=1}},p={{p673=4,index=2}},u={{gems=15,index=3}}}},
            s2003={sid="2003",style="taskBox3.png",require={90},award={u={{honors=30,index=1}},p={{p416=5,index=2}},u={{gems=25,index=3}}}},
            s2004={sid="2004",style="taskBox4.png",require={120},award={u={{honors=40,index=1}},p={{p417=3,index=2}},u={{gems=35,index=3}}}},
            s2005={sid="2005",style="taskBox5.png",require={150},award={u={{honors=50,index=1}},p={{p3413=1,index=2}},u={{gems=70,index=3}}}},
        },
    },
}
