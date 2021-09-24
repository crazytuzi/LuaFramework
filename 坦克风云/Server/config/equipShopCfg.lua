local  equipShopCfg={
 --单抽库
payTicket={
{100},
{88,70,30,70,70,30,70,70,30,60,70,50,100,90,52,8,7,7,7,7,7,7,},
{{"equip_e1",100},{"equip_e1",300},{"equip_e1",1000},{"equip_e2",100},{"equip_e2",300},{"equip_e2",1000},{"equip_e3",100},{"equip_e3",300},{"equip_e3",1000},{"props_p446",5},{"props_p447",1},{"props_p448",1},{"props_p601",1},{"props_p601",5},{"userinfo_gems",50},{"props_p481",1},{"props_p482",1},{"props_p483",1},{"props_p484",1},{"props_p485",1},{"props_p486",1},{"props_p487",1},},
},
 --10连抽库
payTicket1={
{100},
{82,70,30,70,70,30,70,70,30,60,70,50,100,90,60,8,8,8,8,8,8,},
{{"equip_e1",100},{"equip_e1",300},{"equip_e1",1000},{"equip_e2",100},{"equip_e2",300},{"equip_e2",1000},{"equip_e3",100},{"equip_e3",300},{"equip_e3",1000},{"props_p446",5},{"props_p447",1},{"props_p448",1},{"props_p601",1},{"props_p601",5},{"userinfo_gems",50},{"props_p482",1},{"props_p483",1},{"props_p484",1},{"props_p485",1},{"props_p486",1},{"props_p487",1},},
},

 --十连抽在此库出现一次 其余物品不能在出现
once={"props_p482","props_p483","props_p484","props_p485","props_p486","props_p487",},

payTicketBouns={props_p933=1}, --单次抽奖赠送 觉醒石碎片
payTenTicketBouns={props_p481=1}, --十次抽奖必给 觉醒石
payitem="p932", --单抽代替道具
buyitem="p933", --觉醒商店购买消耗道具
freeTicketTime=72000,  -- 多少秒后免费抽奖

payTicketCost=98, --单抽价格
payTicketTenCost=880, --十连抽价格

 --展示道具
canReward={p={p481=1,p482=1,p483=1,p484=1,p485=1,p486=1,p487=1,}},

pShopItems=
{
i1={id="i1",price=20,reward={p={{p481=1}}},serverReward={props_p481=1}},
i2={id="i2",price=240,reward={p={{p489=1}}},serverReward={props_p489=1}},
i3={id="i3",price=360,reward={p={{p491=1}}},serverReward={props_p491=1}},
i4={id="i4",price=240,reward={p={{p493=1}}},serverReward={props_p493=1}},
i5={id="i5",price=360,reward={p={{p494=1}}},serverReward={props_p494=1}},
i6={id="i6",price=480,reward={p={{p496=1}}},serverReward={props_p496=1}},
i7={id="i7",price=120,reward={p={{p498=1}}},serverReward={props_p498=1}},
i8={id="i8",price=120,reward={p={{p499=1}}},serverReward={props_p499=1}},
},



}


return equipShopCfg