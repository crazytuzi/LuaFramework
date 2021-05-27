--[[
    {--升一级内功
        id = 1, -- id不重复就可以了
        trigger_type = 1,   -- 触发条件 1:有任务
        trigger_param = 7,  -- 触发参数 任务id
        step_list = {-- 步骤列表
            {
                view_name = "MainUi",           -- 主界面
                node_name = "MainuiTaskMain",   -- 任务栏#主线
                arrow = "left",                 -- 指针指向左
                is_modal = true,                -- 是否模态(模态中会不允许其它操作)
                arrow_text = "点击按钮",        -- 指针显示文字
            },
            {
                view_name = "Role#Inner",           -- 角色#内功
                node_name = "btn_1",                -- 提升
                arrow = "down",                     -- 指针指向下
                is_modal = true,                    -- 模态中会不允许其它操作)
                arrow_text = "点击按钮",
            },
            {
                view_name = "Role",                 -- 角色
                node_name = "btn_close_window",     -- 关闭按钮
                arrow = "up",
                is_modal = true,
                arrow_text = "关闭",
            },
        },
    },
]]
return {

{--提升战宠
        id = 1,
        trigger_type = 1,
        trigger_param = 7,
        step_list = {
            {
                view_name = "MainUi",
                node_name = "MainuiTaskMain",
                arrow = "left",
                is_modal = true,
                arrow_text = "点击任务",
            },          
        },
    },
{--提升战宠
        id = 2,
        trigger_type = 1,
        trigger_param = 15,
        step_list = {
            {
                view_name = "MainUi",
                node_name = "MainuiTaskMain",
                arrow = "left",
                is_modal = true,
                arrow_text = "点击任务",
            },          
			{
                view_name = "ZhanjiangView",
                node_name = "btn_close_window",
                pos = cc.p(970, 104),
                arrow = "down",
                is_modal = true,
                arrow_text = "点击升级",
            },
            {
                view_name = "ZhanjiangView",
                node_name = "btn_close_window",
                pos = cc.p(970, 104),
                arrow = "down",
                is_modal = true,
                arrow_text = "点击升级",
            },
            {
                view_name = "ZhanjiangView",
                node_name = "btn_close_window",
                pos = cc.p(970, 104),
                arrow = "down",
                is_modal = true,
                arrow_text = "点击升级",
            },
            {
                view_name = "ZhanjiangView",
                node_name = "btn_close_window",
                arrow = "up",
                is_modal = true,
                arrow_text = "关闭",
            },
        },
    },
	
{--更改攻击模式
       id = 3,
       trigger_type = 1,
       trigger_param = 18,
       step_list = {
           --{
           --    view_name = "MainUi",
           --    node_name = "MainuiTaskMain",
           --    arrow = "left",
           --    is_modal = true,
           --    arrow_text = "点击任务",
           --},
           {
               view_name = "MainUi",
               node_name = "pk_state",
			   -- pos = cc.p(208, 696),
               arrow = "left",
               is_modal = true,
               arrow_text = "更改模式",
           },
		   {
               view_name = "MainUi",
               node_name = "pk_state_shan_e",
			   -- pos = cc.p(228, 532),
               arrow = "left",
               is_modal = true,
               arrow_text = "善恶模式",
           },    
       },
   },
	{--vip闯关
        id = 4,
        trigger_type = 1,
        trigger_param = 26,
        step_list = {
            {
                view_name = "MainUi",
                node_name = "MainuiTaskMain",
                arrow = "left",
                is_modal = true,
                arrow_text = "点击任务",
            },
            {
                view_name = "MainUi",
                node_name = "MainuiTaskMain",
				pos = cc.p(921, 65),
                arrow = "left",
                is_modal = true,
                arrow_text = "打开VIP",
            },
			{
                view_name = "Vip",
                node_name = "btn_close_window",
				pos = cc.p(602, 429),
                arrow = "left",
                is_modal = true,
                arrow_text = "选择关卡",
            },
			{
                view_name = "Vip",
                node_name = "btn_close_window",
				pos = cc.p(698, 158),
                arrow = "down",
                is_modal = true,
                arrow_text = "前往挑战",
            },
            {
                view_name = "Role",
                node_name = "btn_close_window",
                arrow = "up",
                is_modal = true,
                arrow_text = "关闭",
            },     
        },
    },
	{--vip专属BOSS
        id = 5,
        trigger_type = 1,
        trigger_param = 27,
        step_list = {
            {
                view_name = "MainUi",
                node_name = "MainuiTaskMain",
                arrow = "left",
                is_modal = true,
                arrow_text = "打开面板",
            },
			{
                view_name = "NewlyBossView",
                node_name = "btn_close_window",--NewlyBossView#Wild#Specially
				pos = cc.p(344, 548),
                arrow = "up",
                is_modal = true,
                arrow_text = "选择VIP专属",
            },
            {
                view_name = "NewlyBossView",
                node_name = "btn_close_window",
				pos = cc.p(782, 108),
                arrow = "down",
                is_modal = true,
                arrow_text = "前往挑战",
            },
        },
    },

    {--激活萌宠
        id = 6,
        trigger_type = 1,
        trigger_param = 28,
        step_list = {
            {
                view_name = "MainUi",
                node_name = "MainuiTaskMain",
                arrow = "left",
                is_modal = true,
                arrow_text = "点击任务",
            },
            {
                view_name = "DiamondPet",
                node_name = "btn_close_window",
                pos = cc.p(689, 156),
                arrow = "up",
                is_modal = true,
                arrow_text = "打开回收面板",
            },
            {
                view_name = "DiamondPet",
                node_name = "btn_close_window",
                --pos = cc.p(689, 156),
                arrow = "up",
                is_modal = true,
                arrow_text = "关闭",
            },
        },
    },



	{--再次回收装备
        id = 7,
        trigger_type = 1,
        trigger_param = 34,
        step_list = {
            {
                view_name = "MainUi",
                node_name = "MainuiTaskMain",
                arrow = "left",
                is_modal = true,
                arrow_text = "点击任务",
            },
            {
                view_name = "MainBagView",
                node_name = "btn_close_window",
                pos = cc.p(778, 99),
                arrow = "down",
                is_modal = true,
                arrow_text = "打开回收面板",
            },
            {
                view_name = "Recycle",
                node_name = "btn_close_window",
                pos = cc.p(975, 120),
                arrow = "down",
                is_modal = true,
                arrow_text = "点击回收",
            },
            {
                view_name = "Recycle",
                node_name = "btn_close_window",
                arrow = "up",
                is_modal = true,
                arrow_text = "关闭",
            },
            {
                view_name = "MainBagView",
                node_name = "btn_close_window",
                arrow = "up",
                is_modal = true,
                arrow_text = "关闭",
            },       
        },
    },
	{--积分商城
        id = 8,
        trigger_type = 1,
        trigger_param = 35,
        step_list = {
            {
                view_name = "MainUi",
                node_name = "MainuiTaskMain",
                arrow = "left",
                is_modal = true,
                arrow_text = "点击任务",
            },
            {
                view_name = "Shop",
                node_name = "btn_close_window",
                pos = cc.p(223, 299),
                arrow = "left",
                is_modal = true,
                arrow_text = "选择积分商城",
            },           
            {
                view_name = "Shop",
				
                node_name = "btn_close_window",
                arrow = "up",
                is_modal = true,
                arrow_text = "关闭",
            },       
        },
    },
	{--试炼
        id = 9,
        trigger_type = 1,
        trigger_param = 42,
        step_list = {
            {
                view_name = "MainUi",
                node_name = "MainuiTaskMain",
                arrow = "left",
                is_modal = true,
                arrow_text = "点击任务",
            },
            {
                view_name = "MainUi",
                node_name = "shilian_icon",
				-- pos = cc.p(1346, 591),
                arrow = "right",
                is_modal = true,
                arrow_text = "前往试炼",
            },
			{
                view_name = "Experiment",
                node_name = "btn_close_window",
				pos = cc.p(700, 107),
                arrow = "down",
                is_modal = true,
                arrow_text = "挑战关卡",
            },
   
        },
    },
   {--进行转生
        id = 10,
        trigger_type = 1,
        trigger_param = 45,
        step_list = {
            {
                view_name = "MainUi",
                node_name = "MainuiTaskMain",
                arrow = "left",
                is_modal = true,
                arrow_text = "点击任务",
            },
            {
                view_name = "Role",
                node_name = "btn_close_window",
                pos = cc.p(1089, 166),
                arrow = "down",
                is_modal = true,
                arrow_text = "兑换修为",
            },
            {
                view_name = "Role",
                node_name = "btn_close_window",
                pos = cc.p(583, 274),
                arrow = "down",
                is_modal = true,
                arrow_text = "确认兑换",
            },
			{
                view_name = "Role",
                node_name = "btn_close_window",
                pos = cc.p(1089, 166),
                arrow = "down",
                is_modal = true,
                arrow_text = "兑换修为",
            },
            {
                view_name = "Role",
                node_name = "btn_close_window",
                pos = cc.p(583, 274),
                arrow = "down",
                is_modal = true,
                arrow_text = "确认兑换",
            },
            {
                view_name = "Role",
                node_name = "btn_close_window",
                pos = cc.p(482, 112),
                arrow = "down",
                is_modal = true,
                arrow_text = "进行转生",
            },
            {
                view_name = "Role",
                node_name = "btn_close_window",
                pos = cc.p(969, 263),
                arrow = "down",
                is_modal = true,
                arrow_text = "进行加点",
            },
            {
                view_name = "Role",
                node_name = "btn_close_window",
                pos = cc.p(714, 581),
                arrow = "down",
                is_modal = true,
                arrow_text = "推荐加点",
            },
            {
                view_name = "Role",
                node_name = "btn_close_window",
                pos = cc.p(491, 120),
                arrow = "down",
                is_modal = true,
                arrow_text = "确认加点",
            },
            {
                view_name = "Role",
                node_name = "btn_close_window",
                pos = cc.p(699, 127),
                arrow = "down",
                is_modal = true,
                arrow_text = "返回转生",
            },
            {
                view_name = "Role",
                node_name = "btn_close_window",
                arrow = "up",
                is_modal = true,
                arrow_text = "关闭",
            },
        },
    },
}