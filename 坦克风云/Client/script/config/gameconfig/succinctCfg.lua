succinctCfg={
 --精炼工程师等级
engineerLvLimit=40,
 --攻击&生命上限,百分比显示                                                                                                                                                                                                                                                    
attLifeLimit={0.15,0.16,0.17,0.18,0.19,0.2,0.21,0.22,0.23,0.24,0.25,0.26,0.27,0.28,0.29,0.3,0.31,0.32,0.33,0.34,0.35,0.36,0.37,0.38,0.39,0.4,0.41,0.42,0.43,0.44,0.45,0.46,0.47,0.48,0.49,0.5,0.51,0.52,0.53,0.54,0.55,0.56,0.57,0.58,0.59,0.6,0.61,0.62,0.63,0.64,0.65,0.66,0.67,0.68,0.69,0.7,0.71,0.72,0.73,0.74,},
 --击破&防护上限,整数显示
arpArmorLimit={6,6.4,6.8,7.2,7.6,8,8.4,8.8,9.2,9.6,10,10.4,10.8,11.2,11.6,12,12.4,12.8,13.2,13.6,14,14.4,14.8,15.2,15.6,16,16.4,16.8,17.2,17.6,18,18.4,18.8,19.2,19.6,20,20.4,20.8,21.2,21.6,22,22.4,22.8,23.2,23.6,24,24.4,24.8,25.2,25.6,26,26.4,26.8,27.2,27.6,28,28.4,28.8,29.2,29.6,},
 --精炼工程师经验
engineerExp={0,5,25,75,175,325,575,975,1575,2425,3575,5075,6975,9375,12275,15775,19875,24675,30175,36475,43575,51575,60475,70375,81275,93275,106275,120275,135275,151275,168275,186275,205275,225275,247275,271275,297275,325275,355275,387275,421275,457275,495275,535275,577275,621275,667275,715275,765275,818275,874275,933275,995275,1060275,1128275,1199275,1273275,1350275,1430275,1513275,},
 --等级对应特权
privilege_1=3,--自动精炼
privilege_2=5,--专家精炼
privilege_3=7,--自动精炼次数上限20
privilege_4=9,--大师精炼
privilege_5=12,--基础精炼9折
privilege_6=16,--自动精炼次数上限50
privilege_7=20,--专家精炼9折
privilege_8=25,--大师精炼9折
privilege_9=30,--自动精炼次数上限100
privilege_10=35,--基础精炼8折
privilege_11=40,--专家精炼8折

privilege={
{[12]=0.9,[35]=0.8}, --基础
{[20]=0.9,[40]=0.8}, --专家
{[25]=0.9}, --大师
},


 --不同精炼方式增加的经验
add_exp={1,5,10,},



price={
{{u={r4=1000000}},{e={p8=30}},{u={gems=20}},}, --配件1(基础,专家,大师)
{{u={r4=1000000}},{e={p8=30}},{u={gems=20}},}, --配件2(基础,专家,大师)
{{u={r4=1000000}},{e={p8=30}},{u={gems=20}},}, --配件3(基础,专家,大师)
{{u={r4=1000000}},{e={p8=30}},{u={gems=20}},}, --配件4(基础,专家,大师)
{{u={r4=1000000}},{e={p9=30}},{u={gems=20}},}, --配件5(基础,专家,大师)
{{u={r4=1000000}},{e={p9=30}},{u={gems=20}},}, --配件6(基础,专家,大师)
{{u={r4=1000000}},{e={p10=30}},{u={gems=20}},}, --配件7(基础,专家,大师)
{{u={r4=1000000}},{e={p10=30}},{u={gems=20}},}, --配件8(基础,专家,大师)
},
 --不同精炼方式属性上限
 --第一个括号是增加 att&life 第二个货号是增加 arp&amor 里面的第一个值是下限系数，第二个值是上限增加值
addLvValue={
{{0.1,0.021},{0.1,0.7},},
{{0.2,0.033},{0.2,1.1},},
{{0.4,0.048},{0.4,1.6},},
},

----旧属性
----暴伤增加110
----暴伤减少111
----攻击100
----血量108
----防护201
----穿透202
----精准102
----闪避103
----暴击104
----装甲105

----新增属性
----对[坦克]伤害增加211
----对[歼击车]伤害增加212
----对[自行火炮]伤害增加213
----对[火箭车]伤害增加214
----受[坦克]伤害减少221
----受[歼击车]伤害减少222
----受[自行火炮]伤害减少223
----受[火箭车]伤害减少224




    bounsAtt={
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[221]=7}},
             {{[201]=18},{[213]=7}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[224]=10}},
             {{[201]=18},{[212]=5}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[223]=7}},
             {{[201]=18},{[211]=7}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[222]=5}},
             {{[201]=18},{[214]=10}},
        },
        {
             {{[108]=0.2},{[111]=7}},
             {{[100]=0.3},{[110]=7}},
             {{[202]=15},{[221]=8}},
             {{[201]=18},{[213]=8}},
        },
        {
             {{[108]=0.2},{[111]=7}},
             {{[100]=0.3},{[110]=7}},
             {{[202]=15},{[224]=15}},
             {{[201]=18},{[212]=5}},
        },
        {
             {{[108]=0.2},{[111]=8}},
             {{[100]=0.3},{[110]=8}},
             {{[202]=15},{[223]=8}},
             {{[201]=18},{[211]=8}},
        },
        {
             {{[108]=0.2},{[111]=8}},
             {{[100]=0.3},{[110]=8}},
             {{[202]=15},{[222]=5}},
             {{[201]=18},{[214]=15}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[222]=7}},
             {{[201]=18},{[214]=7}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[221]=10}},
             {{[201]=18},{[213]=5}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[224]=7}},
             {{[201]=18},{[212]=7}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[223]=5}},
             {{[201]=18},{[211]=10}},
        },
        {
             {{[108]=0.2},{[111]=7}},
             {{[100]=0.3},{[110]=7}},
             {{[202]=15},{[222]=8}},
             {{[201]=18},{[214]=8}},
        },
        {
             {{[108]=0.2},{[111]=7}},
             {{[100]=0.3},{[110]=7}},
             {{[202]=15},{[221]=15}},
             {{[201]=18},{[213]=5}},
        },
        {
             {{[108]=0.2},{[111]=8}},
             {{[100]=0.3},{[110]=8}},
             {{[202]=15},{[224]=8}},
             {{[201]=18},{[212]=8}},
        },
        {
             {{[108]=0.2},{[111]=8}},
             {{[100]=0.3},{[110]=8}},
             {{[202]=15},{[223]=5}},
             {{[201]=18},{[211]=15}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[223]=7}},
             {{[201]=18},{[211]=7}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[222]=10}},
             {{[201]=18},{[214]=5}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[221]=7}},
             {{[201]=18},{[213]=7}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[224]=5}},
             {{[201]=18},{[212]=10}},
        },
        {
             {{[108]=0.2},{[111]=7}},
             {{[100]=0.3},{[110]=7}},
             {{[202]=15},{[223]=8}},
             {{[201]=18},{[211]=8}},
        },
        {
             {{[108]=0.2},{[111]=7}},
             {{[100]=0.3},{[110]=7}},
             {{[202]=15},{[222]=15}},
             {{[201]=18},{[214]=5}},
        },
        {
             {{[108]=0.2},{[111]=8}},
             {{[100]=0.3},{[110]=8}},
             {{[202]=15},{[221]=8}},
             {{[201]=18},{[213]=8}},
        },
        {
             {{[108]=0.2},{[111]=8}},
             {{[100]=0.3},{[110]=8}},
             {{[202]=15},{[224]=5}},
             {{[201]=18},{[212]=15}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[224]=7}},
             {{[201]=18},{[212]=7}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[223]=10}},
             {{[201]=18},{[211]=5}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[222]=7}},
             {{[201]=18},{[214]=7}},
        },
        {
             {{[108]=0.2},{[111]=5}},
             {{[100]=0.3},{[110]=5}},
             {{[202]=15},{[221]=5}},
             {{[201]=18},{[213]=10}},
        },
        {
             {{[108]=0.2},{[111]=7}},
             {{[100]=0.3},{[110]=7}},
             {{[202]=15},{[224]=8}},
             {{[201]=18},{[212]=8}},
        },
        {
             {{[108]=0.2},{[111]=7}},
             {{[100]=0.3},{[110]=7}},
             {{[202]=15},{[223]=15}},
             {{[201]=18},{[211]=5}},
        },
        {
             {{[108]=0.2},{[111]=8}},
             {{[100]=0.3},{[110]=8}},
             {{[202]=15},{[222]=8}},
             {{[201]=18},{[214]=8}},
        },
        {
             {{[108]=0.2},{[111]=8}},
             {{[100]=0.3},{[110]=8}},
             {{[202]=15},{[221]=5}},
             {{[201]=18},{[213]=15}},
    },
},
}