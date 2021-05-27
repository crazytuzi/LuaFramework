
-- tip显示类型
TIP_SHOW_TYPE = {
	EQUIP = 1,			-- 1 装备
	ITEM = 2,			-- 2 物品
	CARD = 3,			-- 3 图鉴
	BATTLE_LINE = 4,	-- 4 战纹
	EFF_SHOW = 5,		-- 5 带特效展示tips
}

-- 装备tip显示类型配置 格式：[物品类型] = tip显示类型
TIP_SHOW_TYPE_CFG = {
	[0] = 2, -- 未定义类型的物品
	[1] = 1, -- 武器
	[2] = 1, -- 衣服
	[3] = 1, -- 头盔
	[4] = 1, -- 项链
	[5] = 1, -- 手镯
	[6] = 1, -- 戒指
	[7] = 1, -- 腰带
	[8] = 1, -- 鞋子
	[9] = 1, -- 热血神剑
	[10] = 1, -- 热血神甲
	[11] = 1, -- 热血面甲
	[12] = 1, -- 热血护肩
	[13] = 1, -- 热血斗笠
	[14] = 1, -- 热血战鼓
	--[15] = 1, -- 热血吊坠
	--[16] = 1, -- 热血护膝
	[17] = 1, -- 传世_衣服
	[18] = 1, -- 传世_头盔
	[19] = 1, -- 传世_项链
	[20] = 1, -- 传世_手镯
	[21] = 1, -- 传世_戒指
	[22] = 1, -- 传世_腰带
	[23] = 1, -- 传世_鞋子
	[24] = 1, -- 传世_武器
	[25] = 5, -- 灭霸_手套
	[26] = 5, -- 特戒
	[27] = 5, --冲锋枪
	[28] = 5, --敞篷车
	[29] = 5, --皇冠
	[30] = 5, --金骷髅
	[31] = 5, -- 金链子
	[32] = 5, --金烟斗
	[33] = 5, --金骰子
	[34] = 5, --金莲花
	[35] = 5, -- 爵士帽
	[36] = 5, --劳力士
	[37] = 5, --钻戒
	[38] = 5, --绅士靴
	[50] = 1, -- 战宠装备
	[51] = 1, -- 战宠装备
	[52] = 1, -- 战宠装备
	[53] = 1, -- 战宠装备
	[101] = 2, -- 任务物品
	[102] = 2, -- 功能物品，可以双击执行功能脚本的
	[103] = 2, -- 调用BUFFID类型
	[104] = 2, -- 瞬间恢复药品
	[105] = 1, -- 宝石镶嵌材料
	[106] = 2, -- 材料
	[107] = 2, -- 装备强化类，比如强化石等
	[108] = 2, -- 技能的秘籍
	[109] = 2, -- 宠物的技能书
	[110] = 2, -- 宠物普通药品
	[111] = 2, -- 宠物速回药品
	[112] = 2, -- 宠物换皮肤道具
	[113] = 2, -- 经验珠(杀怪自动注入经验)
	[114] = 2, -- 矿物，和普通物品比它的耐久表示纯度和最大纯度
	[115] = 2, -- 宝箱(特殊的) 钻石萌宠系统产出

	[119] = 1, -- 符文
	[120] = 1, -- 时装
	[121] = 1, -- 幻武
	[122] = 1, -- 生肖
	[123] = 2, -- 藏宝图
	[124] = 3, -- 图鉴
	[125] = 1, -- 神翼
	[126] = 1, -- 首篇心法
	[127] = 1, -- 上篇心法
	[128] = 1, -- 中篇心法
	[129] = 1, -- 下篇心法
	[130] = 1, -- 终篇心法
	[131] = 1, -- 青龙圣物
	[132] = 1, -- 白虎圣物
	[133] = 1, -- 朱雀圣物
	[134] = 1, -- 玄武圣物
	[135] = 1, -- 麒麟对物
	[136] = 1, -- 飞羽
	[137] = 1, -- 纤羽
	[138] = 1, -- 绒羽
	[139] = 1, -- 翎羽

	[140] = 2, -- 砂玉丹
	[141] = 2, -- 血牙丹
	[142] = 2, -- 炽凰丹
	
	[143] = 4, -- 战纹
	[145] = 1, -- 星魂
	[146] = 1, -- 守护神装
	[147] = 1, -- 神翼装备
	[148] = 1, -- 真气装备

	-----------------------------------------
	-- 神炉虚拟物品start
	[100000] = 1,	-- 左边特戒
	[100001] = 1,	-- 右边特戒
	[100002] = 1,	-- 龙符
	[100003] = 1,	-- 护盾
	[100004] = 1,	-- 宝石
	[100005] = 1,	-- 龙魂
	[100006] = 1,	-- 神器
	-- 神炉虚拟物品end

	--战神装备
	[41] = 1, --战神头
	[42] = 1,	-- 战神链
	[43] = 1,	--战神手
	[44] = 1,	--战神戒
	[45] = 1,	--战神带
	[46] = 1, -- 战神鞋
	--杀神装备
	[15] = 1, -- 天煞
	[16] = 1, -- 天绝
	[39] = 1, -- 天戒	
	[40] = 1, -- 天命
	-----------------------------------------
}

-- 根据物品类型屏蔽描述 item_cfg.desc 
IS_NOT_SHOW_DESC = SetBag{
	25,		-- 灭霸手套
	26,		-- 特戒
	27,		-- //冲锋枪
	28,		-- //敞篷车
	29,		-- //皇冠
	30,		-- //金骷髅
	31,		-- // 金链子
	32,		-- //金烟斗
	33,		-- //金骰子
	34,		-- //金莲花
	35,		-- // 爵士帽
	36,		-- //劳力士
	37,		-- //钻戒
	38,		-- //绅士靴	
}

IS_TYPE_REXUE = {
	[9] = 1, -- 热血神剑
	[10] = 1, -- 热血神甲
	[11] = 1, -- 热血面甲
	[12] = 1, -- 热血护肩
	[13] = 1, -- 热血护膝
	[14] = 1, -- 热血吊坠

	[41] = 1, --战神头
	[42] = 1,	-- 战神链
	[43] = 1,	--战神手
	[44] = 1,	--战神戒
	[45] = 1,	--战神带
	[46] = 1, -- 战神鞋
	--杀神装备
	[15] = 1, -- 天煞
	[16] = 1, -- 天绝
	[39] = 1, -- 天戒	
	[40] = 1, -- 天命	
}
EquipTip = {} 

EquipTip.FROM_NORMAL = 0						--无
EquipTip.FROM_BAG = 1 							--在背包界面中（没有打开仓库和出售）
EquipTip.FROM_BAG_ON_BAG_STORAGE = 2			--打开仓库界面时，来自背包
EquipTip.FROM_STORAGE_ON_BAG_STORAGE = 3		--打开仓库界面时，来自仓库
EquipTip.FROM_BAG_ON_BAG_SALE = 4				--打开售卖界面时，来自背包
EquipTip.FROM_BAG_EQUIP = 5						--在装备界面时，来自装备
EquipTip.FROME_BROWSE_ROLE = 6					--查看角色界面时，来自查看
EquipTip.FROME_BAG_STONE = 7					--背包宝石镶嵌
EquipTip.FROME_EQUIP_STONE = 8					--身上宝石卸下
EquipTip.FROM_BAG_ON_GUILD_STORAGE = 9			--打开行会仓库界面时， 来自背包
EquipTip.FROM_STORAGE_ON_GUILD_STORAGE = 10		--打开行会仓库界面时， 来自行会仓库
EquipTip.FROM_HERO_EQUIP = 11					--打开战将界面时， 来自战将装备
EquipTip.FROM_BAG_ON_RECYCLE = 12				--打回收将界面时， 来自背包
EquipTip.FROM_RECYCLE = 13						--打回收将界面时， 来自回收
EquipTip.FROM_CONSIGN_ON_BUY = 14 				--打开购买界面时， 来自寄售
EquipTip.FROM_CONSIGN_ON_SELL = 15 				--打开出售界面时， 来自寄售
EquipTip.FROM_XUNBAO_BAG = 16 					--取出仓库物品，   来自寻宝
EquipTip.FROM_EQUIP_COMPARE = 17 				--来自装备对比
EquipTip.FROM_WING_STONE = 18 					--来自翅膀魂石
EquipTip.FROM_CHAT_BAG = 19 					--来自聊天背包
EquipTip.FROM_EXCHANGE_BAG = 20					--来自交易背包
EquipTip.FROM_STRFB = 21						--来自闯关副本
EquipTip.FROM_RUNE = 22							--来自符文
EquipTip.FROM_FASHION_CLOTHES = 23				--来自时装
EquipTip.FROM_FULING_TO_MAIN = 24				--来自附灵，放入主装备
EquipTip.FROM_FULING_TO_MATE = 25				--来自附灵，放入材料装备
EquipTip.FROM_FULING_TAKE_MAIN = 26				--来自附灵主装备，放回背包
EquipTip.FROM_FULING_TAKE_MATE = 27				--来自附灵材料装备，放回背包
EquipTip.FROM_FULING_SHIFT_TO_MAIN = 28			--来自附灵转移，放入主装备
EquipTip.FROM_FULING_SHIFT_TO_MATE = 29			--来自附灵转移，放入材料装备
EquipTip.FROM_FULING_SHIFT_TAKE_MAIN = 30	    --来自附灵转移主装备，放回背包
EquipTip.FROM_FULING_SHIFT_TAKE_MATE = 31		--来自附灵转移材料装备，放回背包
EquipTip.FROM_BAG_ON_CARD_DESCOMPOSE = 32		--打开图鉴分解界面时，来自背包
EquipTip.FROM_CARD_DESCOMPOSE = 33				--来自图鉴分解，放回背包
EquipTip.FROM_HOLY_SYNTHESIS = 34				--来自圣物合成
EquipTip.FROM_EQUIP_GODFURANCE = 35				--在主角装备界面打开神炉装备
EquipTip.FROM_WING_BAG = 36 					--在神翼来自神翼背包
EquipTip.FROM_WING_CL_SHOW = 37 				--在神翼来自材料显示
EquipTip.FROM_WING_EQUIP_SHOW = 38 				--在神翼影翼装备
EquipTip.FROM_HOROSCOPE = 39 				    --在星盘
EquipTip.FROM_COLLECTION = 40 					--来自星魂收藏
EquipTip.FROM_COLLECTION_BAG = 41 				--来自星魂收藏背包
EquipTip.FROM_MEIBA_BAG = 42 					--在灭霸手套材料背包
EquipTip.FROM_WING_EQUIP = 43 				    --来自翅膀装备槽位
EquipTip.FROM_GUN_OR_CAR = 44 					--来自豪装界面抢或者车
EquipTip.FROM_CS_BAG = 45						--来自传世升阶背包
EquipTip.FROM_CS_CONSUM = 46					--来自传世升阶材料
EquipTip.FROM_CS_DECOMPOSE_BAG = 47				--来自传世分解背包
EquipTip.FROM_CS_DECOMPOSE_VIEW = 48			--来自传世分解界面
EquipTip.FROM_SHI_ZHUANG_GUI = 49   			--来自时装柜 
EquipTip.FROM_SPECIAL_RING_BAG = 50   			--来自时特戒背包
EquipTip.FROM_ROlE_CHUANG_SHI = 51  			-- 来自人物传世界面
EquipTip.FROM_BROWSE_ROlE_CHUANG_SHI = 52 		--来自查看人物传世界面
EquipTip.FROM_ROlE_NEWREXUE_EQUIP = 53 			--来自人物界面热血装备
EquipTip.FROM_ZHANGCHONG = 54 					--来自战宠技能获取提示
EquipTip.FROM_BROWSE_HOROLOPE = 55 				--来自星魂
EquipTip.FROM_ROLE_HAND = 56 			--来自人物界面手套

EquipTip.HANDLE_EQUIP = 1						--装备
EquipTip.HANDLE_USE = 2							--使用
EquipTip.HANDLE_DISCARD = 3						--丢弃
EquipTip.HANDLE_STRENGTHEN = 4					--强化
EquipTip.HANDLE_INLAY = 5						--镶嵌
EquipTip.HANDLE_SPLIT = 6						--拆分
EquipTip.HANDLE_TAKEOFF= 7						--卸下
EquipTip.HANDLE_INPUT = 8						--投入
EquipTip.HANDLE_EXCHANGE = 9					--兑换
EquipTip.HANDLE_DESTROY = 10					--摧毁
EquipTip.HANDLE_TAKEOUT = 11					--取出
EquipTip.HANDLE_BUY = 12 						--购买
EquipTip.HANDLE_ZHURU = 13						--注入
EquipTip.HANDLE_SHOW = 14						--展示
EquipTip.HANDLE_XUELIAN = 15					--血炼
EquipTip.HANDLE_QUICK_USE = 18					--快速使用
EquipTip.HANDLE_CANCEL_USE = 19					--取消使用
EquipTip.HANDLE_FIND_PATH = 20					--寻路
EquipTip.HANDLE_DECOMPOSE = 21					--分解
EquipTip.HANDLE_ONEKEY_USE = 22 				--一键使用
EquipTip.HANDLE_HUANHUA = 23 					--幻化
EquipTip.HANDLE_COLLECT = 24 					--收藏
EquipTip.HANDLE_NOT_HUANHUA = 25 				--取消幻化
EquipTip.HANDLE_UPGRADE = 26 				    --升阶
EquipTip.HANDLE_HUISHOU = 27 					--放入时装柜
EquipTip.HANDLE_GANGWEN = 28 					--钢纹
EquipTip.HANDLE_GET = 29 						--获取
EquipTip.HANDLE_UPGRADE2 = 30 					--升级
EquipTip.HANDLE_ADD = 31 						--增幅
EquipTip.HANDLE_ONEKEY_SYNTHETIC = 32 			--一键合成


function EquipTip.GetEquipName(equip_cfg, equip_data, fromView)
	local name = equip_cfg.name
	if equip_data.slot_apotheosis and equip_data.slot_apotheosis > 0 then
		local limit_level, circle_level = ItemData.GetItemLevel(equip_cfg.item_id)
		local limit_god_lv = AffinageData.GetLimitAffinageLevel(limit_level, circle_level)
		if limit_god_lv then
			local god_lv = equip_data.slot_apotheosis > limit_god_lv and limit_god_lv or equip_data.slot_apotheosis
			local god_name = AffinageData.GetGodLevelName(god_lv)
			name = string.format("%s·%s", god_name, name)
		end
	end
	return name
end
