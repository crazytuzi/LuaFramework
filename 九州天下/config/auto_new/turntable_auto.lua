local config = {
reward_cfg={
{is_notice=1,},
{reward_item={item_id=26500,num=1,is_bind=1},weight=2000,item_index=1,},
{reward_item={item_id=22013,num=1,is_bind=1},weight=2000,item_index=2,},
{reward_item={item_id=26500,num=3,is_bind=1},weight=1000,item_index=3,},
{reward_item={item_id=22013,num=2,is_bind=1},weight=1500,item_index=4,},
{reward_item={item_id=26500,num=2,is_bind=1},weight=1500,item_index=5,},
{reward_item={item_id=22013,num=3,is_bind=1},weight=1000,item_index=6,},
{reward_item={item_id=26500,num=5,is_bind=1},item_index=7,}},

roll_cfg={
{}},

turntable_show_cfg={
{},
{gather_num=10,},
{gather_num=15,},
{gather_num=20,}},

reward_cfg_default_table={turntable_type=0,reward_item={item_id=26000,num=1,is_bind=1},weight=500,is_notice=0,item_index=0,},

roll_cfg_default_table={turntable_type=0,lucky_max=60,great_item_index=0,need_item_id=26000,need_item_num=1,},

turntable_show_cfg_default_table={gather_num=5,}

}

---------------------------索引表分割线-----------------------

local db = nil 
db = nil
return config

