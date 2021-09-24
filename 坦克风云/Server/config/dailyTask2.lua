local dailyTask2={
    --经验基数
    exp={5000,5500,6000,6500,7000,7500,8000,8500,9000,9500,10000,10500,11000,11500,12000,12200,12400,12600,12800,13000,13200,13400,13600,13800,14000,14200,14400,14600,14800,15000,15200,15400,15600,16000,18000,19000,21000,23000,25000,27000,29000,31000,33000,36000,38000,41000,44000,47000,50000,54000,57000,61000,65000,69000,73000,77000,82000,87000,92000,103000,113000,125000,139000,151000,164000,176000,187000,202000,215000,226000,235000,244000,251000,261000,268000,275000,285000,294000,302000,307000,313000,322000,332000,342000,351000,361000,372000,381000,392000,402000,410000,418000,428000,439000,451000,463000,474000,486000,499000,511000,523000,535000,547000,559000,571000,583000,595000,607000,619000,631000,},
    
    --资源基数
    resource={10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,12000,13000,15000,17000,20000,21000,24000,26000,30000,32000,37000,40000,45000,48000,54000,57000,64000,68000,75000,79000,89000,94000,104000,110000,122000,128000,142000,149000,164000,172000,186000,194000,210000,220000,237000,247000,267000,278000,300000,311000,334000,348000,372000,385000,409000,422000,449000,463000,492000,507000,543000,563000,601000,624000,666000,692000,738000,765000,816000,845000,895000,928000,984000,1019000,1078000,1119000,1183000,1228000,1298000,1346000,1418000,1467000,1550000,1604000,1688000,1747000,1853000,1917000,2033000,2104000,2175000,2246000,2317000,2388000,2459000,2530000,2601000,2672000,2743000,2814000,},
    --type:任务类型  1：基础：生产X辆坦克  2：基础：升级X次建筑  3：基础：升级X次科技  4：基础：攻打X次关卡  5：配件：强化X次配件  6：配件：攻打X次补给线（扫荡、失败）  7：将领：进行X次将领招募（普通、精锐、连续）  8：将领：进行X次装备探索  9：军团：进行X次捐献  10：军团：攻打X次军团副本  11：军演：进行X次军事演习  12：超武：掠夺X次玩家  13：超武：攻打X次神秘组织（扫荡、失败）  14：远征：攻打X次远征（扫荡、失败）  15：叛军：攻打叛军X次 16：军徽抽取X次 17：活跃点达到X
    --condition：完成条件
    --needLv：任务所需等级  等级未达到，任务不显示
    --switch：功能开关  开关未开，任务不显示
    --point：活跃点  完成任务获得的活跃点数
    --award1：变化奖励  奖励计算方式：根据玩家等级去相应经验/资源基数中取相应的数，乘以award1中的系数
    --award2：固定奖励
    --raising：军团资金
    task={
        s1001={condition=10,needLv=1,point=10,award1={userinfo_exp=0.1,userinfo_r1=0.5},award2={props_p19=5}},
        s1002={condition=1,needLv=1,point=10,award1={userinfo_exp=0.1,userinfo_r2=0.5},award2={props_p19=5}},
        s1003={condition=1,needLv=1,point=10,award1={userinfo_exp=0.1,userinfo_r3=0.5},award2={props_p19=5}},
        s1004={condition=2,needLv=1,point=10,award1={userinfo_exp=0.1,userinfo_r4=0.5},award2={props_p19=5}},
        s1005={condition=1,needLv=8,point=10,award1={userinfo_exp=0.1,userinfo_gold=1},award2={accessory_p3=3}},
        s1006={condition=1,needLv=8,point=10,award1={userinfo_exp=0.1,userinfo_r1=0.5},award2={accessory_p2=1}},
        s1007={condition=2,needLv=20,point=10,award1={userinfo_exp=0.15,userinfo_r2=0.5},award2={props_p819=1}},
        s1008={condition=1,needLv=30,point=10,award1={userinfo_exp=0.15,userinfo_r3=0.5},award2={accessory_p1=1}},
        s1009={condition=5,needLv=1,point=10,award1={userinfo_exp=0.15,userinfo_r4=0.5},raising=20},
        s1010={condition=2,needLv=1,point=10,award1={userinfo_exp=0.15,userinfo_r1=1},award2={props_p601=1}},
        s1011={condition=3,needLv=10,point=10,award1={userinfo_exp=0.15,userinfo_gold=2},award2={props_p601=1}},
        s1012={condition=1,needLv=30,point=10,award1={userinfo_exp=0.2,userinfo_r2=1},award2={props_p601=1}},
        s1013={condition=1,needLv=30,point=10,award1={userinfo_exp=0.2,userinfo_r3=1},award2={props_p601=1}},
        s1014={condition=1,needLv=25,point=15,award1={userinfo_exp=0.25,userinfo_gold=2},award2={props_p601=1}},
        s1015={condition=1,needLv=1,point=20,award1={userinfo_exp=0.25,userinfo_gold=5},award2={props_p415=2}},
        s1016={condition=2,needLv=25,point=15,award1={userinfo_exp=0.25,userinfo_r4=1},award2={props_p415=2}},
        s1017={condition=3,needLv=25,point=10,award1={userinfo_exp=0.1,userinfo_gold=1},award2={props_p415=2}},
        s1018={condition=1,needLv=40,point=10,award1={userinfo_exp=0.1,userinfo_r2=0.5},award2={props_p415=2}},
    },
    finalTask={
        s2001={condition=30,award={userinfo_honors=10,props_p4001=8}},
        s2002={condition=60,award={userinfo_honors=20,props_p673=1}},
        s2003={condition=90,award={userinfo_honors=30,props_p416=2}},
        s2004={condition=120,award={userinfo_honors=40,props_p417=1}},
        s2005={condition=160,award={userinfo_honors=50,props_p4000=1}},
    },
}

return dailyTask2
