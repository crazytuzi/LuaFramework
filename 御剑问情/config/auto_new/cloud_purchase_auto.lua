-- Y-一元夺宝.xls
return {
other={
{}},

ticket_type={
{},
{seq=1,gold_price=100,rmb_price=10,qianggou_ticket_item_id="27995:10:1",},
{seq=2,gold_price=640,rmb_price=64,qianggou_ticket_item_id="27995:64:1",},
{seq=3,gold_price=1880,rmb_price=188,qianggou_ticket_item_id="27995:188:1",},
{seq=4,gold_price=2880,rmb_price=288,qianggou_ticket_item_id="27995:288:1",},
{seq=5,gold_price=5880,rmb_price=588,qianggou_ticket_item_id="27995:588:1",}},

item_cfg={
{need_count=3888,},
{seq=1,reward_item={item_id=22330,num=1,is_bind=0},need_count=3688,},
{seq=2,reward_item={item_id=24552,num=1,is_bind=0},need_count=3888,},
{seq=3,reward_item={item_id=22272,num=1,is_bind=0},},
{seq=4,reward_item={item_id=27501,num=1,is_bind=1},},
{seq=5,reward_item={item_id=27988,num=1,is_bind=1},},
{seq=6,reward_item={item_id=28538,num=1,is_bind=1},need_count=988,},
{seq=7,reward_item={item_id=31167,num=1,is_bind=1},need_count=488,},
{seq=8,reward_item={item_id=27767,num=1,is_bind=0},need_count=288,},
{seq=9,reward_item={item_id=23532,num=1,is_bind=1},need_count=88,},
{seq=10,reward_item={item_id=26110,num=5,is_bind=1},need_count=68,},
{seq=11,reward_item={item_id=28854,num=20,is_bind=1},need_count=38,}},

convert_cfg={
{cost_score=5888,current_prize=1,image_type=4,},
{seq=1,cost_score=5688,item_id="22330:1:1",res_id=22330,image_type=26,},
{seq=2,cost_score=5888,item_id="24552:1:1",res_id=24552,image_type=3,},
{seq=3,item_id="22272:1:1",res_id=22272,image_type=5,},
{seq=4,item_id="27501:1:1",res_id=27501,image_type=7,},
{seq=5,item_id="27988:1:1",res_id=27988,image_type=16,},
{seq=6,cost_score=1588,item_id="28538:1:1",res_id=28538,image_type=16,},
{seq=7,cost_score=988,item_id="28783:1:1",res_id=28783,image_type=16,},
{seq=8,cost_score=488,item_id="27767:1:1",res_id=27767,size=1.3,},
{seq=9,cost_score=148,item_id="23532:1:1",res_id=23532,size=1.3,},
{seq=10,cost_score=128,item_id="26110:5:1",res_id=26110,size=1.3,},
{seq=11,cost_score=68,item_id="28854:20:1",res_id=28854,size=1.3,}},

copies_cfg={
{},
{buy_copies=10,},
{buy_copies=64,},
{buy_copies=288,}},

other_default_table={buy_interval=120,draw_lottery_time_interval=1,ticket_gold_price=10,qianggou_ticket_item_id=27995,score_per_gold=1,},

ticket_type_default_table={seq=0,gold_price=50,rmb_price=5,qianggou_ticket_item_id="27995:5:1",},

item_cfg_default_table={seq=0,need_ticket_num=1,reward_item={item_id=22380,num=1,is_bind=0},need_count=1888,},

convert_cfg_default_table={seq=0,cost_score=2888,item_id="22380:1:1",convert_count_limit=1,res_id=22380,is_show=1,current_prize=0,image_type=6,size=1,},

copies_cfg_default_table={buy_copies=1,}

}

