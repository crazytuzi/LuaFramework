-- created by uiedit 

 return {
-- index 1
	{t="layout",n="layout_common",x=59,y=27,w=1065,h=617,
		{t="img9",n="autoname_18467",x=533,y=204,w=1064,h=409,p="res/xui/common/img9_149.png",cx=24,cy=26,cw=13,ch=8,},
		{t="img",n="autoname_6334",x=532,y=507,w=1041,h=196,p="res/xui/painting/knight_font.jpg",sx=1.0,sy=1.0,},
		{t="img9",n="autoname_41",x=532,y=308,w=1065,h=617,p="res/xui/common/img9_149.png",cx=24,cy=26,cw=13,ch=8,},
		{t="text",n="txt_day",x=21,y=450,w=150,h=29,txt="剩余时间:",tfs=20,r=255,g=255,b=255,ta=0,},
		{t="text",n="txt_pro",x=160,y=450,w=145,h=29,txt="完成进度：",tfs=20,r=255,g=255,b=255,ta=1,},
		{t="img9",n="autoname_41",x=389,y=436,w=200,h=32,p="res/xui/common/prog_107.png",cx=41,cy=11,cw=5,ch=10,},
		{t="prog9",n="prog_knight",x=389,y=436,w=158,h=22,progress="res/xui/common/prog_107_progress.png",cx=7,cy=5,cw=3,ch=5,},
		{t="text",n="txt_uplev",x=352,y=447,w=73,h=24,txt="text",tfs=20,r=255,g=255,b=255,ta=1,},
		{t="ph",n="ph_pos",x=801,y=498,w=149,h=18,},},

-- index 2
	{t="layout",n="layout_content",x=57,y=39,w=1059,h=386,
		{t="layout",n="layout_1",x=15,y=0,w=1038,h=384,
			{t="img9",n="autoname_6334",x=519,y=192,w=1038,h=384,p="res/xui/common/bg_145.png",cx=12,cy=15,cw=18,ch=21,},
			{t="ph",n="ph_knight_list",x=520,y=193,w=1028,h=380,},
			{t="ph",n="ph_knight_item",x=9,y=1,w=144,h=376,
				{t="img",n="pic_nochapter",x=72,y=188,w=144,h=375,p="res/xui/knight/task_bottom_2.png",sx=1.0,sy=1.0,},
				{t="img",n="img_chapter",x=72,y=188,w=144,h=375,p="res/xui/knight/task_bottom_2.png",sx=1.0,sy=1.0,},
				{t="img",n="pic_chapter",x=72,y=215,w=65,h=228,p="res/xui/knight/txt_bottom.png",sx=1.0,sy=1.0,},
				{t="rich",n="txt_chapter",x=15,y=368,w=110,h=33,txt="第一章",tfs=26,r=227,g=224,b=173,ta=1,},
				{t="img",n="pic_word",x=72,y=229,w=49,h=193,p="res/xui/knight/task_1.png",sx=1.0,sy=1.0,},
				{t="img",n="pic_nochapter",x=72,y=42,w=94,h=39,p="res/xui/knight/login_bottom.png",sx=1.0,sy=1.0,},
				{t="text",n="txt_finish",x=37,y=56,w=70,h=29,txt="0/8",tfs=24,r=227,g=224,b=173,ta=1,},
				{t="img9",n="img_lock",x=71,y=166,w=140,h=332,p="res/xui/knight/knight_lock.png",cx=57,cy=134,cw=37,ch=63,},
				{t="img",n="remind_name",x=131,y=363,w=26,h=26,p="res/xui/mainui/remind_flag.png",sx=1.0,sy=1.0,},},},
		{t="layout",n="layout_2",x=0,y=2,w=1059,h=384,
			{t="img9",n="autoname_41",x=533,y=192,w=1037,h=384,p="res/xui/common/bg_145.png",cx=12,cy=15,cw=18,ch=21,},
			{t="ph",n="ph_reward_list",x=603,y=238,w=823,h=283,},
			{t="ph",n="ph_reward_item",x=194,y=283,w=820,h=94,
				{t="img9",n="autoname_32391",x=410,y=47,w=820,h=94,p="res/xui/common/img9_156.png",cx=21,cy=26,cw=13,ch=9,},
				{t="text",n="txt_task",x=16,y=63,w=310,h=29,txt="text",tfs=24,r=255,g=255,b=255,ta=0,},
				{t="btn",n="btn_get",x=724,y=45,w=102,h=50,pn="res/xui/common/btn_101.png",txt="领取",tfs=20,r=255,g=255,b=255,},
				{t="ph",n="ph_quick_links",x=394,y=51,w=96,h=27,},
				{t="layout",n="layout_task_cells",x=475,y=7,w=165,h=80,
					{t="ph",n="ph_gift_cell_1",x=0,y=0,w=80,h=80,sx=1.0,sy=1.0,},
					{t="ph",n="ph_gift_cell_2",x=85,y=0,w=80,h=80,sx=1.0,sy=1.0,},},
				{t="img",n="img_unsuccess",x=725,y=46,w=99,h=30,p="res/xui/common/stamp_3.png",sx=1.0,sy=1.0,},
				{t="img",n="img_already_get",x=726,y=46,w=98,h=29,p="res/xui/common/stamp_9.png",sx=1.0,sy=1.0,},
				{t="text",n="txt_percent",x=267,y=63,w=76,h=27,txt="text",tfs=22,r=204,g=204,b=204,ta=1,},},
			{t="img9",n="autoname_41",x=604,y=94,w=820,h=4,p="res/xui/knight/shadow.png",cx=0,cy=0,cw=0,ch=0,},
			{t="img",n="pic_chapter",x=120,y=190,w=144,h=375,p="res/xui/knight/task_bottom_2.png",sx=1.0,sy=1.0,},
			{t="text",n="txt_chapter",x=62,y=362,w=110,h=29,txt="第一章",tfs=24,r=227,g=224,b=173,ta=1,},
			{t="img",n="autoname_41",x=119,y=218,w=65,h=228,p="res/xui/knight/txt_bottom.png",sx=1.0,sy=1.0,},
			{t="img",n="pic_word",x=119,y=230,w=49,h=193,p="res/xui/knight/task_1.png",sx=1.0,sy=1.0,},
			{t="img",n="autoname_18467",x=121,y=44,w=94,h=39,p="res/xui/knight/login_bottom.png",sx=1.0,sy=1.0,},
			{t="text",n="txt_finish",x=86,y=58,w=70,h=29,txt="0/8",tfs=24,r=227,g=224,b=173,ta=1,},
			{t="img9",n="autoname_323999",x=605,y=47,w=820,h=87,p="res/xui/common/bg_146.png",cx=16,cy=22,cw=16,ch=15,},
			{t="btn",n="btn_proreceive",x=913,y=50,w=102,h=50,pn="res/xui/common/btn_101.png",txt="领取",tfs=20,r=255,g=255,b=255,},
			{t="text",n="txt_protask",x=206,y=65,w=170,h=33,txt="text",tfs=22,r=0,g=255,b=0,ta=0,},
			{t="text",n="finish_count",x=384,y=65,w=80,h=34,txt="text",tfs=22,r=255,g=255,b=255,ta=0,},
			{t="layout",n="layout_progress_cells",x=667,y=7,w=165,h=80,
				{t="ph",n="ph_gift_cell_1",x=0,y=0,w=80,h=80,sx=1.0,sy=1.0,},
				{t="ph",n="ph_gift_cell_2",x=85,y=0,w=80,h=80,sx=1.0,sy=1.0,},},
			{t="img",n="img_unsuccess_pro",x=913,y=51,w=99,h=30,p="res/xui/common/stamp_3.png",sx=1.0,sy=1.0,},
			{t="img",n="img_already_pro",x=914,y=51,w=98,h=29,p="res/xui/common/stamp_9.png",sx=1.0,sy=1.0,},
			{t="img",n="pic_right",x=1033,y=206,w=51,h=76,p="res/xui/common/btn_right.png",sx=1.0,sy=1.0,},
			{t="img",n="pic_left",x=25,y=206,w=51,h=76,p="res/xui/common/btn_right.png",sx=-1.0,sy=1.0,},
			{t="img",n="remind_left",x=23,y=234,w=20,h=20,p="res/xui/mainui/remind_flag.png",sx=0.80000001192092896,sy=0.80000001192092896,},
			{t="img",n="remind_right",x=1038,y=234,w=20,h=20,p="res/xui/mainui/remind_flag.png",sx=0.80000001192092896,sy=0.80000001192092896,},},},

-- index 3
	{t="layout",n="layout_display_show",x=58,y=25,w=576,h=496,
		{t="img9",n="customImage",x=273,y=239,w=535,h=460,p="res/xui/common/img9_141.png",cx=16,cy=18,cw=7,ch=5,},
		{t="img9",n="customImage",x=275,y=239,w=550,h=479,p="res/xui/common/img9_149.png",cx=24,cy=26,cw=13,ch=8,},
		{t="btn",n="btn_close_window",x=548,y=467,w=56,h=57,pn="res/xui/common/btn_close.png",},
		{t="ph",n="ph_display",x=260,y=197,w=63,h=18,},}
}