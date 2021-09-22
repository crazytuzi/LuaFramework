GDivTask = {}

local GUIDE_TYPE = {
	COMP = 1, -- 强制引导
	WEAK = 2, -- 弱引导
}

local ARROW_TYPE = {
	TOP = 1,
	DOWN = 2,
	LEFT = 3,
	RIGHT = 4,
}

local guideTable = {
	--------------------------------------主线任务引导--------------------------------------
	--任务面板 1
	[1]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "m_lcPartUI",	node = "taskItem1000", arrow = ARROW_TYPE.LEFT, offX = -75,offY=-20},
		--[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "panel_mainTask",	node = "btn_task_change", arrow = ARROW_TYPE.DOWN},
	},
	--召唤神宠
	[2]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rtPartUI",	node = "extend_baobao", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		--[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "panel_mainTask",	node = "btn_task_change", arrow = ARROW_TYPE.DOWN},
	},
	--神炉（合成1）
	[3]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_shenlu", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "1_name", arrow = ARROW_TYPE.DOWN},
		[4]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
	},
	--神炉（合成2）
	[4]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_shenlu", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "2_name", arrow = ARROW_TYPE.DOWN},
		[4]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
	},
	--神炉（合成3）
	[5]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_shenlu", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "3_name", arrow = ARROW_TYPE.DOWN},
		[4]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
	},
	--神炉（合成4）
	[6]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_shenlu", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "4_name", arrow = ARROW_TYPE.DOWN},
		[4]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
	},
	--神炉（合成5）
	[7]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_shenlu", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "5_name", arrow = ARROW_TYPE.DOWN},
		--[4]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "btn_auto_vcoin", arrow = ARROW_TYPE.DOWN},
		[4]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
		--[[
		[5]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
		[6]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
		[7]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
		[8]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
		[9]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
		[10]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
		[11]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
		[12]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
		[13]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
		[14]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
		]]
	},
	--转生
	[8]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_cbPartUI",	node = "progressHpBar_bg", arrow = ARROW_TYPE.DOWN},
		[2]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "main_avatar", node = "tab5", arrow = ARROW_TYPE.LEFT, offX = 0, offY = 0},
		[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "container_reborn",	node = "update_btn", arrow = ARROW_TYPE.DOWN},
	},
	--翅膀
	[9]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_wing", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "btn_main_wing",	node = "btn_upgrade", arrow = ARROW_TYPE.DOWN},
	},
	--摇摇乐
	[10]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "extend_dice", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "extend_dice",	node = "tab2", arrow = ARROW_TYPE.TOP},
		[4]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "extend_dice",	node = "btnShaiZi", arrow = ARROW_TYPE.TOP},
		[5]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "extend_dice",	node = "btnGaiYun", arrow = ARROW_TYPE.TOP},
		[6]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "extend_dice",	node = "btnLing", arrow = ARROW_TYPE.TOP},
		[7]={gType = GUIDE_TYPE.COMP, root = "m_tipsManager",	node = "btnConfirm", arrow = ARROW_TYPE.TOP},
		[8]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "extend_dice",	node = "tab1", arrow = ARROW_TYPE.LEFT, offX = 0, offY = 0},
		[9]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "extend_dice",	node = "lblgetvalue", arrow = ARROW_TYPE.DOWN},
	},
	--洪荒
	[11]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_v10_7", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
	},
	--称号
	[12]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_v10_1", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		[3]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "container_title",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
	},
	--攻速盾
	[13]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_v10_8", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "container_npc_maplist",	node = "updatebtn", arrow = ARROW_TYPE.DOWN},
	},
	--血炼
	[14]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_v10_10", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "container_npc_maplist",	node = "btn2", arrow = ARROW_TYPE.DOWN},
	},
	--血炼
	[15]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_v10_11", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "container_npc_maplist",	node = "btn2", arrow = ARROW_TYPE.DOWN},
	},
	--首充
	[16]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rtPartUI",	node = "extend_firstPay", arrow = ARROW_TYPE.TOP},
	},
	--攻略
	[17]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rtPartUI",	node = "extend_help", arrow = ARROW_TYPE.TOP},
	},
	--血炼
	[18]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rbPartUI",	node = "btn_props4", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 30},
		--[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_v10_11", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		--[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "container_npc_maplist",	node = "btn2", arrow = ARROW_TYPE.DOWN},
	},
	--充值卡使用
	[19]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_bag", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 30},
		[2]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",panel="menu_bag",	node = "18000001", arrow = ARROW_TYPE.TOP},
		--[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_v10_11", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		--[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "container_npc_maplist",	node = "btn2", arrow = ARROW_TYPE.DOWN},
	},
	--打工人第4版
	--封神之路
	[20]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_cbPartUI",	node = "btnVip", arrow = ARROW_TYPE.DOWN},
		[2]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V9_FengShen",	node = "1_name", arrow = ARROW_TYPE.DOWN},
	},
	--强化
	[21]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_qianghua", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		
		[3]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_forge",	node = "item_upgrade", arrow = ARROW_TYPE.LEFT},
		[4]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_forge",	node = "btnQh", arrow = ARROW_TYPE.LEFT},
		[5]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_forge",	node = "panel_close", arrow = ARROW_TYPE.TOP},
	},
	--封神之路
	[22]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_cbPartUI",	node = "btnVip", arrow = ARROW_TYPE.DOWN},
	},
	--神炉（勋章）
	[23]={
		[1]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "btn_container_switch", arrow = ARROW_TYPE.RIGHT, offX = -40, offY = 40},
		[2]={gType = GUIDE_TYPE.COMP, root = "m_rcPartUI",	node = "menu_container_btn_shenlu", arrow = ARROW_TYPE.RIGHT, offX = -30, offY = 40},
		--[3]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "1_name", arrow = ARROW_TYPE.DOWN},
		--[4]={gType = GUIDE_TYPE.COMP, root = "GDivContainer",	panel = "V11_ContainerHeCheng",	node = "upgrade", arrow = ARROW_TYPE.DOWN},
	},
	
	
	
	
	--[[
	--任务面板 1
	[1]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "m_lcPartUI",	node = "taskItem1000", arrow = ARROW_TYPE.LEFT, offX = -75},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "panel_mainTask",	node = "btn_task_change", arrow = ARROW_TYPE.DOWN},
	},
	--继续任务 1
	[2]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "panel_mainTask",	node = "btn_task_change", arrow = ARROW_TYPE.DOWN},
	},
	--回收 1
	[3]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "menu_recycle",	node = "btn_add", arrow = ARROW_TYPE.DOWN},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "menu_recycle",	node = "btn_huishou", arrow = ARROW_TYPE.LEFT},
	},
	[31]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "menu_recycle",	node = "panel_close", arrow = ARROW_TYPE.TOP},
	},
	--接受除魔 1
	[4]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "panel_chumo",	node = "btn_refresh_star", arrow = ARROW_TYPE.LEFT},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "panel_chumo",	node = "btn_accept_task", arrow = ARROW_TYPE.DOWN},
	},
	--完成除魔 1
	[5]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "panel_chumo",	node = "btn_treble_award", arrow = ARROW_TYPE.LEFT},
	},
	--激活战神 
	[6]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "extend_mars",	node = "btnZhaoHuan", arrow = ARROW_TYPE.LEFT},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "extend_mars",	node = "panel_close", arrow = ARROW_TYPE.TOP},
	},
	--随身商店快捷购买
	[7]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "menu_bag",	node = "btnShangDian", arrow = ARROW_TYPE.LEFT},
		-- 需要特殊处理，对按钮进行重命名
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "menu_bag",	node = "btnBuy1", arrow = ARROW_TYPE.LEFT, times = 3},
		[3]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "menu_bag",	node = "btnBuy1", arrow = ARROW_TYPE.LEFT, times = 2},
		[4]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "menu_bag",	node = "btnBuy1", arrow = ARROW_TYPE.LEFT, times = 1},
		[5]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "menu_bag",	node = "panel_close", arrow = ARROW_TYPE.TOP},
	},
	--快捷物品设置
	[8]={
		-- 需要特殊处理，对背包格子进行重命名
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "panel_quickset",	node = "item_quick4", arrow = ARROW_TYPE.DOWN},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "panel_quickset",	node = "item_drug", arrow = ARROW_TYPE.LEFT},
		[3]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "panel_quickset",	node = "panel_close", arrow = ARROW_TYPE.TOP},
	},
	--强化
	[9]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_forge",	node = "item_upgrade", arrow = ARROW_TYPE.LEFT},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_forge",	node = "btnQh", arrow = ARROW_TYPE.LEFT},
		[3]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_forge",	node = "panel_close", arrow = ARROW_TYPE.TOP},
	},
	--个人boss 1
	[10]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "btn_main_boss",	node = "btn_personal_boss", arrow = ARROW_TYPE.LEFT},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "btn_main_boss",	node = "item_boss1", arrow = ARROW_TYPE.LEFT},
		[3]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "btn_main_boss",	node = "btnFuBen", arrow = ARROW_TYPE.LEFT},
	},
	--个人boss 2
	[11]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "btn_main_boss",	node = "btn_personal_boss", arrow = ARROW_TYPE.LEFT},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "btn_main_boss",	node = "item_boss2", arrow = ARROW_TYPE.LEFT},
		[3]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "btn_main_boss",	node = "btnFuBen", arrow = ARROW_TYPE.LEFT},
	},

	--翅膀
	[12]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "btn_main_wing",	node = "btn_upgrade", arrow = ARROW_TYPE.DOWN, times = 3},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "btn_main_wing",	node = "btn_upgrade", arrow = ARROW_TYPE.DOWN, times = 2},
		[3]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "btn_main_wing",	node = "btn_upgrade", arrow = ARROW_TYPE.DOWN, times = 1},
		[4]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "btn_main_wing",	node = "panel_close", arrow = ARROW_TYPE.TOP},
	},

	--烧猪洞
	[13]={
		[1]={gType = GUIDE_TYPE.WEAK, root = "m_lcPartUI",	node = "btn_leiting", arrow = ARROW_TYPE.DOWN,},
		[2]={gType = GUIDE_TYPE.WEAK, root = "m_lcPartUI",	node = "btn_leiting", arrow = ARROW_TYPE.DOWN,},
		[3]={gType = GUIDE_TYPE.WEAK, root = "m_lcPartUI",	node = "btn_leiting", arrow = ARROW_TYPE.DOWN,},
		[4]={gType = GUIDE_TYPE.WEAK, root = "m_lcPartUI",	node = "btn_leiting", arrow = ARROW_TYPE.DOWN,},
		[5]={gType = GUIDE_TYPE.WEAK, root = "m_lcPartUI",	node = "btn_leiting", arrow = ARROW_TYPE.DOWN,},
		[6]={gType = GUIDE_TYPE.WEAK, root = "m_lcPartUI",	node = "btn_shaozhu_start", arrow = ARROW_TYPE.DOWN,},
	},

	--内功
	[15] = {
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_avatar",	node = "tab3", arrow = ARROW_TYPE.LEFT},
		-- 需要特殊处理，对按钮进行重命名
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_avatar",	node = "btn_upgrade", arrow = ARROW_TYPE.DOWN},
		-- [3]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_avatar",	node = "panel_close", arrow = ARROW_TYPE.TOP},
	},
	--护盾
	[16] = {
	-- "btnYupei","btnHudun","btnLongxin","btnLangya"
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_furnace",	node = "tab2", arrow = ARROW_TYPE.LEFT},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_furnace",	node = "Button_jihuo", arrow = ARROW_TYPE.DOWN},
		[3]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_furnace",	node = "panel_close", arrow = ARROW_TYPE.TOP},
	},
	--玉佩
	[19] = {
		-- [1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_furnace",	node = "tab1", arrow = ARROW_TYPE.LEFT},
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_furnace",	node = "Button_jihuo", arrow = ARROW_TYPE.DOWN},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_furnace",	node = "panel_close", arrow = ARROW_TYPE.TOP},
	},
	--龙心
	[21] = {
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_furnace",	node = "tab3", arrow = ARROW_TYPE.LEFT},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_furnace",	node = "Button_jihuo", arrow = ARROW_TYPE.DOWN},
		[3]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_furnace",	node = "panel_close", arrow = ARROW_TYPE.TOP},
	},
	--狼牙
	[22] = {
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_furnace",	node = "tab4", arrow = ARROW_TYPE.LEFT},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_furnace",	node = "Button_jihuo", arrow = ARROW_TYPE.DOWN},
		[3]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_furnace",	node = "panel_close", arrow = ARROW_TYPE.TOP},
	},
	--官位
	[23] = {
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_official",	node = "btn_tab_post", arrow = ARROW_TYPE.LEFT},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_official",	node = "btnGwUp", arrow = ARROW_TYPE.DOWN},
		[3]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "main_official",	node = "panel_close", arrow = ARROW_TYPE.TOP},
	},
	--引导羽毛副本
	[24] = {
-- panel_cailai
		[1]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "panel_cailiao",	node = "tabList", arrow = ARROW_TYPE.LEFT,offY = 110},
		[2]={gType = GUIDE_TYPE.WEAK, root = "GDivContainer",	panel = "panel_cailiao",	node = "btnLingQu", arrow = ARROW_TYPE.DOWN},
	},
	]]

}


local skipGuideLevel = {14, 17,18, 20, 27}

local var = {}

--(left) Y : display.height * 0.5, x0 : display.width * 0.5 - 100 - 100, x1 : display.width * 0.5 - 100 + 100
--(right) Y : display.height * 0.5, x0 : display.width * 0.5 + 100 - 100, x1 : display.width * 0.5 + 100 + 100

-- 显示手势引导(双指内外滑切换简化界面和完整界面)
local function showGestureGuide(event)
	if not event then return end

	local layerGesture = cc.LayerColor:create(cc.c4b(0, 0, 0, 255 * 0.5))
		:setName("layer_gesture")
		:addTo(var.layerGuide, 30)


	layerGesture:runAction(cca.seq({
		cca.delay(30),
		cca.cb(function ()
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SWITCH_UI_MODE, mode = (var.slideGuide == "slideIn") and GameConst.UI_COMPLETE or GameConst.UI_SIMPLIFIED})
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_REMOVE_GESTURE_GUIDE, slideGuide = var.slideGuide})
		end)
	}))
	local imgGestureTips = ccui.ImageView:create()
		:align(display.CENTER, display.width * 0.5, display.height * 0.7)
		:addTo(layerGesture)

	local imgArrowLeft = ccui.ImageView:create("ui/image/task_arrow_left.png")
		:align(display.CENTER, display.width * 0.5 - 180, display.height * 0.5)
		:addTo(layerGesture)

	local imgArrowRight = ccui.ImageView:create("ui/image/task_arrow_left.png")
		:align(display.CENTER, display.width * 0.5 + 180, display.height * 0.5)
		:addTo(layerGesture)

	local imgHandLeft = ccui.ImageView:create("image/icon/img_gesture_hand.png")
		:align(display.CENTER, display.width * 0.5 - 150, display.height * 0.5)
		:addTo(layerGesture)

	local imgHandRight = ccui.ImageView:create("image/icon/img_gesture_hand.png")
		:align(display.CENTER, display.width * 0.5 + 150, display.height * 0.5)
		:addTo(layerGesture)
		:setScaleX(-1)

	local x = display.width * 0.5 - 180
	local y = display.height * 0.5 - 50
	local dir = 1
	if event.slideIn then
		var.slideGuide = "slideIn"
		--imgGestureTips:loadTexture("ui/image/tips_gesture_slide_in.png")
		
		asyncload_callback("ui/image/tips_gesture_slide_in.png", imgGestureTips, function(path, texture)
			imgGestureTips:loadTexture(path)
		end)
		
		imgArrowLeft:setScaleX(-1)
	else
		var.slideGuide = "slideOut"
		dir = -1
		--imgGestureTips:loadTexture("ui/image/tips_gesture_slide_out.png")
		
		asyncload_callback("ui/image/tips_gesture_slide_out.png", imgGestureTips, function(path, texture)
			imgGestureTips:loadTexture(path)
		end)
		imgArrowRight:setScaleX(-1)
	end
	local action1 = cca.repeatForever(cca.seq({
		cca.moveTo(0.8, x + 100 * dir, y), 
		cca.spawn({cca.moveTo(0.35, x, y), cca.scaleTo(0.35, 1.3)}), 
		cca.spawn({cca.moveTo(0.35, x - 100 * dir, y), cca.scaleTo(0.35, 1)})
	}))
	imgHandLeft:pos(x - 100 * dir, y)
	imgHandLeft:runAction(action1)

	x = display.width * 0.5 + 180
	local action2 = cca.repeatForever(cca.seq({
		cca.moveTo(0.8, x - 100 * dir, y), 
		cca.spawn({cca.moveTo(0.35, x, y), cca.scaleTo(0.35, -1.3, 1.3)}), 
		cca.spawn({cca.moveTo(0.35, x + 100 * dir, y), cca.scaleTo(0.35, -1, 1)})
	}))
	imgHandRight:pos(x + 100 * dir, y)
	imgHandRight:runAction(action2)
end

local function removeGestureGuide(event)
	if (not event.slideGuide) or event.slideGuide == var.slideGuide then
		if not var.layerGuide:getChildByName("layer_gesture") then return end
		var.layerGuide:removeChildByName("layer_gesture")
		GameSocket:PushLuaTable("map.kingjia.onDoneGuide",GameUtilSenior.encode({guideType = var.slideGuide}));
	end
end

--引导箭头的悬浮动画
local function handleGuideAnimation()
	-- print("/////////////////handleGuideAnimation//////////////////")
	if var.guideSprite then
		var.guideSprite:stopAllActions()
		local lblGuide = var.guideSprite:getChildByName("lbl_guide")
		local conf = guideTable[var.guideLevel][var.guideIndex]
		-- local posX1, posY1, posY2, posY2
		local pos1, pos2
		local anchor
		if conf.arrow == ARROW_TYPE.TOP then
			var.guideSprite:loadTexture("img_guide_arrow1", ccui.TextureResType.plistType)
			pos1 = cc.p(0, -20)
			pos2 = cc.p(0, 0)
			local pSize = var.guideSprite:getContentSize()
			lblGuide:align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5 - 12)
			anchor = cc.p(0.5, 1)
		elseif conf.arrow == ARROW_TYPE.DOWN then
			var.guideSprite:loadTexture("img_guide_arrow2", ccui.TextureResType.plistType)
			pos1 = cc.p(0, 20)
			pos2 = cc.p(0, 0)
			local pSize = var.guideSprite:getContentSize()
			lblGuide:align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5 + 12)
			anchor = cc.p(0.5, 0)
		elseif conf.arrow == ARROW_TYPE.LEFT then
			var.guideSprite:loadTexture("img_guide_arrow3", ccui.TextureResType.plistType)
			pos1 = cc.p(20, 0)
			pos2 = cc.p(0, 0)
			local pSize = var.guideSprite:getContentSize()
			lblGuide:align(display.CENTER, pSize.width * 0.5 + 10, pSize.height * 0.5)
			anchor = cc.p(0, 0.5)
		elseif conf.arrow == ARROW_TYPE.RIGHT then
			var.guideSprite:loadTexture("img_guide_arrow4", ccui.TextureResType.plistType)
			pos1 = cc.p(-20, 0)
			pos2 = cc.p(0, 0)
			local pSize = var.guideSprite:getContentSize()
			lblGuide:align(display.CENTER, pSize.width * 0.5 - 10, pSize.height * 0.5)
			anchor = cc.p(1, 0.5)
		end
		var.guideSprite:setAnchorPoint(anchor)
		var.guideSprite:setPosition(pos2)
		var.guideSprite:runAction(cca.repeatForever(cca.seq({cca.moveTo(0.35, pos1.x, pos1.y), cca.moveTo(0.35, pos2.x, pos2.y)})))
		--var.guideSprite:setScaleX((conf.arrow == ARROW_TYPE.RIGHT) and -1 or 1)
	end
end

local function updateGuideBubble()
	if not var.guideSprite then return end
	if not (var.guideLevel and var.guideIndex) then return end
	local conf = guideTable[var.guideLevel][var.guideIndex]
	if not conf then return end
	local lblBubble = var.guideSprite:getChildByName("lbl_guide")
	if not lblBubble then return end

	local num = 0
	local text = "点  击"
	if conf.times then
		text = "点击   次"
		num = conf.times
	end
	lblBubble:setString(text)
	local lblNum = lblBubble:getChildByName("lbl_times"):setString("")

	if num > 0 then
		lblNum:setString(num)
		local pSize = lblBubble:getContentSize()
		lblNum:align(display.CENTER, pSize.width * 0.5 + 10, pSize.height * 0.5)
	end

end

local function createBubble()
	if not (var.guideLevel and var.guideIndex) then return end
	local conf = guideTable[var.guideLevel][var.guideIndex]
	if not conf then return end

	local params = {
		text= "点  击", 
		fontSize= 22, 
		color = GameBaseLogic.getColor(0xfff38e), 
		outlineColor = GameBaseLogic.getColor(0x1e0b00),
		outlineStrength = 1
	}
	
	local lblBubble = GameUtilSenior.newUILabel(params)

	params.text= ""
	params.color= GameBaseLogic.getColor(0x30ff00)
	params.fontSize= 24
	local pSize = lblBubble:getContentSize()
	local lblNum = GameUtilSenior.newUILabel(params)
		:align(display.CENTER, pSize.width * 0.5 + 10, pSize.height * 0.5)
		:addTo(lblBubble)
		:setName("lbl_times")
	return lblBubble
end

function GDivTask.init()
	var = {
		layerGuide,

		layerBlock,
		layerRespond,

		guideLevel,
		guideIndex,
		guideHand,
		guideBubble,
		guideClip,
		-- guideStencil,
		waitingPanel,
		panelDict = {},

		clipNode,
		guideWidget,
		isComGuide = false,

		redPanels = {},
		panelRedParams = {},

		guideArray = {},

		forbidTouch = false, -- 屏蔽层屏蔽控制变量

		slideGuide = nil,
	}

	var.layerGuide = ccui.Widget:create()

	var.layerGuide:setContentSize(cc.size(display.width, display.height))
	var.layerGuide:align(display.CENTER, display.cx, display.cy)

	-- var.layerBlock = cc.LayerColor:create(cc.c4b(127, 127, 127, 255 * 0.4))
	var.layerBlock = cc.Layer:create()
		:addTo(var.layerGuide, 20)

	var.layerRespond = cc.Layer:create()
		:addTo(var.layerGuide, 10)

	GDivTask.initLayerBlock()
	GDivTask.initLayerRespond()

	local listener=cc.EventProxy.new(GameSocket, var.layerGuide)
			:addEventListener(GameMessageCode.EVENT_UPDATE_PANELDICT, GDivTask.handlePanelDictUpdate)
			:addEventListener(GameMessageCode.EVENT_OPEN_PANEL, GDivTask.handlePanelOpen)
			-- :addEventListener(GameMessageCode.EVENT_CHANGE_MAP,GDivTask.handleChangeMap)
			:addEventListener(GameMessageCode.EVENT_SHOW_GESTURE_GUIDE, showGestureGuide)
			:addEventListener(GameMessageCode.EVENT_REMOVE_GESTURE_GUIDE, removeGestureGuide)
	if listener then
		listener:addEventListener(GameMessageCode.EVENT_SHOW_GUIDE, GDivTask.handleGuideArray)
		listener:addEventListener(GameMessageCode.EVENT_END_GUIDE, GDivTask.handleStopGuide)
	end

	return var.layerGuide
end

function GDivTask.handlePanelOpen(event)
	if var.guideLevel == 6 and var.guideIndex == 1 then
		GDivTask.handleGuideEnded()
	end
	if GameUtilSenior.isObjectExist(var.guideWidget) and var.guideWidget:getName() == "task_name" then
		GDivTask.handleGuideEnded()
	end
end

----------------触摸屏蔽层----------------
function GDivTask.initLayerBlock()
	local function onTouchBegan(touch,event)
		-- if var.forbidTouch then return true end
		if not var.isComGuide or not var.guideWidget then return false end 
		local touchPos = touch:getLocation()
		if not GameUtilSenior.hitTest(var.guideWidget,touchPos) then return true end
	end

	local function onTouchMoved(touch, event)
		
	end

	local function onTouchEnded(touch, event)
	
	end

	var.layerBlock:setTouchEnabled(true)
	local _touchListener = cc.EventListenerTouchOneByOne:create()
	_touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	_touchListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	_touchListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	_touchListener:setSwallowTouches(true)
	local eventDispatcher = var.layerBlock:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(_touchListener, var.layerBlock)
end
----------------触摸响应层----------------
local stopSlide = {
	[20]={guideLevel=20,guideIndex=2,panelDesp="gerenboss"},
	[25]={guideLevel=25,guideIndex=2,panelDesp="gerenboss"},
	[26]={guideLevel=26,guideIndex=2,panelDesp="gerenboss"},
	[31]={guideLevel=31,guideIndex=3,panelDesp="qianghua"},
}
function GDivTask.initLayerRespond()
	-- local isMove = false
	local function onTouchBegan(touch,event)
		-- if not GameBaseLogic.guiding then return false end
		-- isMove = false
		-- if var.guideLevel and stopSlide[var.guideLevel] and var.guideIndex and var.guideIndex==stopSlide[var.guideLevel].guideIndex then	
		-- 	-- local x = 
		-- 	var.layerGuide:runAction(
		-- 		cca.seq({
		-- 			cca.delay(0.7),
		-- 			cca.cb(function()
		-- 				GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_STOP_SLIDE, panelDesp = stopSlide[var.guideLevel].panelDesp , stopType=false})
		-- 			end)
		-- 		})
		-- 	)
		-- end

		-- print(var.guideWidget,var.guideLevel,var.guideIndex,"1111111111111111111",stopSlide[var.guideLevel].guideIndex)
		if not GameBaseLogic.guiding or not var.guideWidget then return false end
		local touchPos = touch:getLocation()
		if GameUtilSenior.hitTest(var.guideWidget,touchPos) then return true end
		
	end

	local function onTouchMoved(touch, event)
		-- if var.guideWidget:getDescription()~="Button" then
		-- 	isMove = true
		-- end
	end

	local function onTouchEnded(touch, event)
		-- if isMove then return end
		local touchPos = touch:getLocation()
		if GameUtilSenior.hitTest(var.guideWidget,touchPos) then

			if var.guideLevel and stopSlide[var.guideLevel] and var.guideIndex and var.guideIndex==stopSlide[var.guideLevel].guideIndex+1 then	
				GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_STOP_SLIDE, panelDesp = stopSlide[var.guideLevel].panelDesp , stopType=true})
			end
			var.guideWidget.guideLv = nil
			var.guideWidget.guideIndex = nil
			var.guideWidget = nil
			GameBaseLogic.guiding = false
			var.forbidTouch = true 
			if var.guideIndex == #guideTable[var.guideLevel] then --执行下级引导
				var.layerGuide:runAction(
					cca.seq({
						-- cca.delay(0.3),
						cca.cb(function()
							GDivTask.doNextGuide()
						end)
					})
				) -- 延时处理，避免需要指向的控件未处理完成
				-- GDivTask.handleGuideEnded()
			else
				var.guideIndex = var.guideIndex + 1
				-- var.layerGuide:runAction(
				-- 	cca.seq({
				-- 		cca.delay(0.3),
				-- 		cca.cb(function()
				-- 			GDivTask.handleGuideAction()
				-- 		end)
				-- 	})
				-- ) -- 延时处理，避免需要指向的控件未处理完成
			end
		end
	end

	var.layerRespond:setTouchEnabled(true)
	local _touchListener = cc.EventListenerTouchOneByOne:create()
	_touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	_touchListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	_touchListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	_touchListener:setSwallowTouches(false)
	local eventDispatcher = var.layerRespond:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(_touchListener, var.layerRespond)
end

function GDivTask.handleGuideEnded(event)
	if var.guideHand then 
		var.guideHand:hide() 
		var.guideSprite:stopAllActions()
	end

	if var.guideBubble then var.guideBubble:hide() end
	if var.guideClip then var.guideClip:hide() end
	
	var.waitingPanel = nil
	if GameUtilSenior.isObjectExist(var.guideWidget) then
		var.guideWidget.guideLv = nil
		var.guideWidget.guideIndex = nil
	end
	var.guideWidget = nil
	GameBaseLogic.guiding = false
	var.forbidTouch = false
	if GameSocket.guideTab[1] then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_NEWFUNC, data = GameSocket.guideTab[1]})
		GameSocket.guideTab={}
	end
	var.guideArray = {}
	
	if var.isComGuide then --强制引导结束自动任务追踪
		if not table.indexof(skipGuideLevel, var.guideLevel) then
			-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CONTINUE_TASK})
		end
		var.isComGuide = false
	end
	var.guideLevel = nil
	var.guideIndex = nil
	GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_HANDLE_ALL_TRANSLUCENTBG, visible = true})
end

---------34 35除魔奖励领取引导-------------
local noClosePanel = {14, 34, 35, 45}

--这些引导需要打开打开功能隐藏
local needShow = {11,20,25,26,33,38,41}  

function GDivTask.handleGuideArray(event)
	-- print("/////////////////////////////GDivTask.handleGuideArray/////////////////////////////")
	if event.lv then
		-- if table.indexof(needShow, event.lv) then
		-- 	 GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_ONEKEY_VISIBLE,visible=true})
		-- end
		-- if not table.indexof(noClosePanel, event.lv) then
		-- 	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "all"})
		-- end
		if type(event.lv) == "table" then
			for i,v in ipairs(event.lv) do
				if i == 1 then
					GDivTask.handleGuideStart({lv = v})
				else
					table.insert(var.guideArray, v)
				end
			end
		elseif type(event.lv) == "number" then
			GDivTask.handleGuideStart(event)
		end
	end
end

function GDivTask.doNextGuide()
	if #var.guideArray > 0 then
		GDivTask.handleGuideStart({lv = var.guideArray[1]})
		table.remove(var.guideArray, 1)
	else
		GDivTask.handleGuideEnded()
	end
end

function GDivTask.handleGuideStart(event)
	if GameBaseLogic.isNewFunc then return end

	local guideLv = event.lv or 6
	local guideIndex = event.index or 1

	if guideTable[guideLv] and guideTable[guideLv][guideIndex] then
		var.guideLevel = guideLv
		var.guideIndex = guideIndex
		local param = guideTable[guideLv][guideIndex]
		if param.gType == GUIDE_TYPE.COMP then -- 强制引导会暂停玩家当前动作
			-- local  mainAvatar = cc.GhostManager:getInstance():getMainAvatar()
			if GameCharacter._mainAvatar then GameCharacter._mainAvatar:clearAutoMove() end
			GameCharacter._moveToNearAttack = false
			GameCharacter.stopAutoFight()
		end

		GDivTask.handleGuideAction()
	end
end

function GDivTask.handleGuideAction()
	----------先隐藏当前引导--------------
	if var.guideHand then 
		var.guideHand:hide() 
		var.guideSprite:stopAllActions()
	end
	if var.guideBubble then var.guideBubble:hide() end
	if var.guideClip then var.guideClip:hide() end
	if var.guideLevel and var.guideIndex then
		local param = guideTable[var.guideLevel][var.guideIndex]
		if param.root == "GDivContainer" then
			if var.panelDict[param.panel] then --面板已经存在，直接引导
				if param.gType == GUIDE_TYPE.COMP then
					GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_HANDLE_ALL_TRANSLUCENTBG, visible = false})
				end
				GDivTask.doGuideAction()
			else -- 面板不存在，引导等待
				var.waitingPanel = param.panel
			end
		else
			GDivTask.doGuideAction()
		end
	end
end

function GDivTask.doGuideAction()

	local param = guideTable[var.guideLevel][var.guideIndex]
	local target = GUIMain.getGuideWidget(param, "") --取引导控件pos
	-- print("/////////doGuideAction///////", target)
	if not target then return end

	if param.gType == GUIDE_TYPE.RED or param.gType == GUIDE_TYPE.COMP then -- 引导控件序号设置
		target.guideLv = var.guideLevel
		target.guideIndex = var.guideIndex 
	end
	var.guideWidget = target

	if (var.guideWidget:getName() == "img_arrow_left" or var.guideWidget:getName() == "btn_fuben") and var.guideWidget.showFlag then
		var.guideWidget.guideLv = nil
		var.guideWidget.guideIndex = nil
		var.guideWidget = nil
		var.guideIndex = var.guideIndex + 1
		GDivTask.handleGuideAction()
		return
	end
	
	-- GameBaseLogic.guiding = true

	-- cc(target):addNodeEventListener(cc.NODE_EVENT, function(event)
	-- 	if event.name == "exit" then
	-- 		-- if var.guideLevel and var.guideIndex and guideTable[var.guideLevel] and guideTable[var.guideLevel][var.guideIndex] then
	-- 		-- 	if target:getName() == guideTable[var.guideLevel][var.guideIndex].node then
	-- 		-- 		print("exitexitexitexitexitexit")
	-- 		-- 		GDivTask.handleGuideEnded()
	-- 		-- 	end
	-- 		-- end
	-- 	end
	-- end)

	if param.gType == GUIDE_TYPE.COMP then
		var.isComGuide = true
	elseif param.gType == GUIDE_TYPE.WEAK then
		var.isComGuide = false
	end

	if not var.guideHand then
		var.guideHand = ccui.Widget:create()
			:addTo(var.layerGuide, 5)
			:hide()
		-- var.guideSprite = cc.Sprite:create()
		var.guideSprite = ccui.ImageView:create("null", ccui.TextureResType.plistType)
			:align(display.CENTER, 0, 0)
			:addTo(var.guideHand)

		local lblGuide = createBubble():addTo(var.guideSprite):setName("lbl_guide")
	end

	updateGuideBubble()

	var.guideHand:hide()
	var.guideSprite:stopAllActions()
	if var.guideBubble then var.guideBubble:hide() end
	if var.guideClip then var.guideClip:hide() end

	local wPos = GameUtilSenior.getWidgetCenterPos(target)
	
	if wPos then
		-- var.guideSprite:runAction(cca.)
		-- if cc.AnimManager:getInstance():getBinAnimateAsync(var.guideSprite,4,990003,0) then
			handleGuideAnimation()
			var.guideHand:show()--:pos(wPos.x, wPos.y)
		-- end

		if param.bubble then -- 设置气泡位置，以及气泡样式
			GDivTask.showGuidBubble(param.bubble, wPos)
		end

		if var.isComGuide then -- 设置遮罩裁剪位置
			GDivTask.showGuideStencil(wPos)
		end

		if var.guideLevel and stopSlide[var.guideLevel] and var.guideIndex and var.guideIndex==stopSlide[var.guideLevel].guideIndex then	
			GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_STOP_SLIDE, panelDesp = stopSlide[var.guideLevel].panelDesp , stopType=false})
		end
	end
	GameBaseLogic.guiding = true
	var.forbidTouch = false

	GDivTask.updateGuidePosition()
end

function GDivTask.showGuideStencil(wPos)
	if not var.guideClip then
		var.guideClip = cc.ClippingNode:create()
			:addTo(var.layerGuide)
			:setInverted(true)
			:setAlphaThreshold(0)
		local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 255 * 0.5))
			:addTo(var.guideClip)
		local stencil = cc.Sprite:createWithSpriteFrameName("btn_circle")
		var.guideClip:setStencil(stencil)
	end
	var.guideClip:show()
end

function GDivTask.showGuidBubble(str, wPos)
	if not var.guideBubble then
		var.guideBubble = ccui.ImageView:create("img_guide_bg",ccui.TextureResType.plistType)
			:addTo(var.layerGuide, 5)

		local labelBubble=cc.Label:create()
			:setSystemFontName("image/typeface/game.ttf")
			:setSystemFontSize(24)
			:setDimensions(200, 0)
			:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
			:addTo(var.guideBubble)
			:setName("labelBubble")
			:setTextColor(cc.c4b(0, 0, 0, 255))
	end
	local labelBubble = var.guideBubble:getChildByName("labelBubble")
	labelBubble:setString(str)
	local lblSize = labelBubble:getContentSize()
	local bubbleWidth = lblSize.width + 30 > 75 and lblSize.width + 30  or 75
	local bubbleHeight = lblSize.height + 30 > 85 and lblSize.height + 30  or 85
	var.guideBubble:setScale9Enabled(true):setContentSize(cc.size(bubbleWidth, bubbleHeight))
	labelBubble:align(display.LEFT_TOP, 15, var.guideBubble:getContentSize().height - 10)
	var.guideBubble:show()
end

function GDivTask.handlePanelDictUpdate(event)
	if event and event.panels then
		var.panelDict = (table.nums(event.panels) > 0 and event.panels) or {}
		if event.pName and event.pName == var.waitingPanel then
			local param = guideTable[var.guideLevel][var.guideIndex]
			if param.gType == GUIDE_TYPE.COMP then
				GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_HANDLE_ALL_TRANSLUCENTBG, visible = false})
			end
			GDivTask.doGuideAction()
		end
		if (not event.pName) and (not var.panelDict[var.waitingPanel]) then --当前引导面板被关闭则停止引导
			if var.guideLevel and var.guideIndex then
				local param = guideTable[var.guideLevel][var.guideIndex]
				print("var.waitingPanel",param.root,var.waitingPanel)
				if param.root == "GDivContainer" and param.panel == var.waitingPanel then
					GDivTask.handleGuideEnded()
				end
			end
		end
		if event.pName and var.panelRedParams[event.pName] and #var.panelRedParams[event.pName] > 0 then
			for _,v in ipairs(var.panelRedParams[event.pName]) do
				GDivTask.showRedPoint(v)
			end
		end
	end
end

function GDivTask.updateGuidePosition()
	-- print("///////////updateGuidePosition/////////////////", GameUtilSenior.isObjectExist(var.guideWidget), var.guideLevel, var.guideIndex)
	if GameUtilSenior.isObjectExist(var.guideWidget) then
		local wPos = GameUtilSenior.getWidgetCenterPos(var.guideWidget)
		local pSize = var.guideWidget:getContentSize()

		if var.guideHand and var.guideHand:isVisible() then --引导手指
			-- var.guideHand:pos(wPos.x, wPos.y)
			local pSize = var.guideWidget:getContentSize()
			local conf = guideTable[var.guideLevel][var.guideIndex]
			local handPos = cc.p(wPos.x, wPos.y)
			local anchorPoint = cc.p(0.5, 0.5)
			if conf.arrow == ARROW_TYPE.TOP then
				handPos.y =  wPos.y - pSize.height * 0.5
				anchorPoint.y = 1
			elseif conf.arrow == ARROW_TYPE.DOWN then
				handPos.y =  wPos.y + pSize.height * 0.5
				anchorPoint.y = 0
			elseif conf.arrow == ARROW_TYPE.LEFT then
				handPos.x =  wPos.x + pSize.width * 0.5
				anchorPoint.x = 0
			elseif conf.arrow == ARROW_TYPE.RIGHT then
				handPos.y =  wPos.y - pSize.width * 0.5
				anchorPoint.x = 1
			end
			if conf.offX then
				handPos.x = handPos.x + conf.offX
			end
			if conf.offY then
				handPos.y = handPos.y + conf.offY
			end
			var.guideHand:setAnchorPoint(anchorPoint);
			var.guideHand:pos(handPos.x, handPos.y)
		end

		if var.guideBubble and var.guideBubble:isVisible() then
			local bubblePos = cc.p(wPos.x, wPos.y)
			local anchorPoint = cc.p(0.5, 0)
			local pSize = var.guideWidget:getContentSize()
			if wPos.y > display.height * 0.8 or wPos.y > display.height * 0.2 then 
				bubblePos.y =  wPos.y - pSize.height * 0.5
				anchorPoint.y = 1
			-- elseif wPos.y < display.height * 0.2 then 
			-- 	bubblePos.y =  wPos.y - pSize.height * 0.5
			-- 	anchorPoint.y = 1
			else
				bubblePos.y = wPos.y + pSize.height * 0.5
				anchorPoint.y = 0
			end
			if wPos.x < display.width * 0.2 then 
				anchorPoint.x = 0
			elseif wPos.x > display.width * 0.8 then 
				anchorPoint.x = 1
			end
			var.guideBubble:setAnchorPoint(anchorPoint):pos(bubblePos.x, bubblePos.y):show()
		end

		if var.guideClip and var.guideClip:isVisible() then
			local stencil = var.guideClip:getStencil()
			stencil:setScaleX(pSize.width / stencil:getContentSize().width)
				:setScaleY(pSize.height / stencil:getContentSize().height)
				:align(display.CENTER, wPos.x, wPos.y)
			-- var.guideClip:show()
		end

	elseif var.guideLevel and var.guideIndex and guideTable[var.guideLevel] and guideTable[var.guideLevel][var.guideIndex] then
		
		local mParam = guideTable[var.guideLevel][var.guideIndex]
		-- if mParam.root == "GDivContainer" and var.panelDict[mParam.panel] then
			GDivTask.doGuideAction()

		-- end
	end
end

function GDivTask.handleStopGuide(event)
	if event and event.lv then
		if event.lv == var.guideLevel then
			GDivTask.handleGuideEnded()
		end
	else
		GDivTask.handleGuideEnded()
	end

end