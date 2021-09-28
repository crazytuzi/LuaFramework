--------------------------------------------------------------------------------------
-- 文件名:	ConstTable.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	陆奎安
-- 日  期:	2013-2-12 9:37
-- 版  本:	1.0
-- 描  述:	通用全局table表存放
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

--CCAssert
--1、assert (v [, message])
--　　功能：相当于C的断言，当表达式v为nil或false将触发错误,
--　　message：发生错误时返回的信息，默认为"assertion failed!"
CCAssert = assert

g_tbScrollSliderXY = {}

----------属性ID及图片------------------------------------------
g_BasePropName = 
{
	[1] = _T("武力"),		     	--武力
	[2] = _T("法术"),				--法术
	[3]	= _T("绝技"),	   			--绝技
}

Enum_BasePropType = 
{
	ForcePoints = 1,					--武力
	MagicPoints = 2,				--法术
	SkillPoints = 3,						--绝技
}

g_PropName = 
{
	[1] = _T("气势"),		     	--气势
	[2] = _T("气势上限"),					--气势上限
	[3]	= _T("生命"),	   			--生命
	[4]	= _T("生命上限"),						--生命上限
	[5]	= _T("物理攻击"),					--物理攻击
	[6]	= _T("物理防御"),					--物理防御
	[7]	= _T("法术攻击"),					--法术攻击
	[8]	= _T("法术防御"),					--法术防御
	[9]	= _T("绝技攻击"),				--绝技攻击
	[10] = _T("绝技防御"),				--绝技防御
	[11] = _T("暴击"),			--暴击(几率)
	[12] =	_T("韧性"),		--韧性(几率)
	[13] =	_T("必杀"),			--必杀(几率)
	[14] =	_T("刚毅"), --刚毅(几率)
	[15] =	_T("命中"),				--命中(几率)
	[16] =	_T("闪避"),				--闪避(几率)
	[17] =	_T("破击"),			--破击(几率)
	[18] =	_T("格挡"),				--格挡(几率)
	[19] =	_T("气势"),			--增加气势上限百分比
	[20] =	_T("生命"),				--增加生命上限百分比
	[21] =	_T("物攻"),				--增加物理攻击百分比
	[22] =	_T("物防"),				--增加物理防御百分比
	[23] =	_T("法攻"),				--增加法术攻击百分比
	[24] =	_T("法防"),				--增加法术防御百分比
	[25] =	_T("绝攻"),				--增加绝技攻击百分比
	[26] =	_T("绝防"),				--增加绝技防御百分比
	[27] =	_T("防御"),			--所有防御
	[28] = 	_T("个人先攻"),			--增加卡牌个人先攻值
	[29] =	_T("攻击"),			--所有攻击
	[30] =	_T("防御"),			--所有防御百分比
	[31] =	_T("攻击"),			--所有攻击百分比
}

Enum_PropType = 
{
	Mana = 1,
	ManaMax = 2,
	HP = 3,
	HPMax = 4,
	PhyAttack = 5,
	PhyDefence = 6,
	MagAttack = 7,
	MagDefence = 8,
	SkillAttack = 9,
	SkillDefence = 10,
	CriticalChance = 11,
	CriticalResistance = 12,
	CriticalStrike = 13,
	CriticalStrikeResistance = 14,
	HitChance = 15,
	DodgeChance = 16,
	PenetrateChance = 17,
	BlockChance = 18,
	ManaMaxPercent = 19,
	HPMaxPercent = 20,
	PhyAttackPercent = 21,
	PhyDefencePercent = 22,
	MagAttackPercent = 23,
	MagDefencePercent = 24,
	SkillAttackPercent = 25,
	SkillDefencePercent = 26,
	AllDefence = 27,
	Initiative = 28,
	AllAttack = 29,
	AllDefencePercent = 30,
	AllAttackPercent = 31,
}

g_TbBlendFunc = {
	[1] = GL_ZERO,
	[2] = GL_ONE,
	[3] = GL_SRC_COLOR,
	[4] = GL_ONE_MINUS_SRC_COLOR,
	[5] = GL_DST_COLOR,
	[6] = GL_ONE_MINUS_DST_COLOR,
	[7] = GL_SRC_ALPHA,
	[8] = GL_ONE_MINUS_SRC_ALPHA,
	[9] = GL_DST_ALPHA,
	[10] = GL_ONE_MINUS_DST_ALPHA,
	[11] = GL_SRC_ALPHA_SATURATE,
	[12] = GL_CONSTANT_COLOR,
	[13] = GL_ONE_MINUS_CONSTANT_COLOR,
	[14] = GL_CONSTANT_ALPHA,
	[15] = GL_ONE_MINUS_CONSTANT_ALPHA
}

g_EquipStrengthenLevName = {
	_T("青铜"),
	_T("黑铁"),
	_T("白银"),
	_T("黄金"),
	_T("暗金"),
	_T("红玉"),
	_T("灵器"),
	_T("宝器"),
	_T("仙器"),
	_T("神器"),
	_T("青龙"),
	_T("白虎"),
	_T("朱雀"),
	_T("玄武"),
	_T("天地"),
	_T("玄黄"),
	_T("宇宙"),
	_T("洪荒"),
	_T("传说"),
	_T("逆天")
}

g_Profession = {
	[1] = _T("武圣"),
	[2] = _T("剑灵"),
	[3] = _T("飞羽"),
	[4] = _T("术士"),
	[5] = _T("将星"),
}

g_ProfessionDesc = {
	[1] = _T("擅长防御与攻击，格挡增加1点气势"),
	[2] = _T("擅长闪避与攻击，闪避增加1点气势"),
	[3] = _T("擅长暴击与攻击，暴击增加1点气势"),
	[4] = _T("擅长命中与法术，是战斗中的辅助职业"),
	[5] = _T("擅长单体攻击，霸体变身后伤害大幅提高"),
}

g_CardStarLevelName = {
	[1] = _T("一星"),
	[2] = _T("二星"),
	[3] = _T("三星"),
	[4] = _T("四星"),
	[5] = _T("五星"),
	[6] = _T("六星"),
	[7] = _T("七星"),
	[8] = _T("八星")
}

-------LabelAtlas的星级-----------------------------------------------
g_tbStarLevel = {"1","11","111","1111","11111","111111","1111111","11111111","111111111","1111111111"}

-----------------------------------装备相关的常量配置----------------------------------
--装备主属性类型
g_tbEquipMainProp = 
{
	g_PropName[5],   	 --类型1：拳爪，增加物理攻击
	g_PropName[5],	 --类型2：刀剑，增加物理攻击
	g_PropName[5],	 --类型3：弓弩，增加物理攻击
	g_PropName[7],     --类型4：法杖，增加法术攻击
	g_PropName[5],	 --类型5：枪戟，增加物理攻击

	g_PropName[6],	 --类型6：法袍，增加物理防御
	g_PropName[9],	 --类型7：戒指，增加绝技攻击
	g_PropName[3],	 --类型8：项链，增加生命值
	g_PropName[8],     --类型9：奇物，增加法术防御
	g_PropName[10]	 --类型10：战靴，增加绝技防御
}


--[[新的装备大类型调整如下（与装备部位一一对应）
类型1：武器
类型2：法袍
类型3：戒指
类型4：项链
类型5：奇物
类型6：战靴
新的装备子类型调整如下
类型1：拳爪		物理攻击
类型2：刀剑		物理攻击
类型3：弓弩		物理攻击
类型4：法杖		法术攻击
类型5：枪戟		物理攻击
类型6：法袍		物理防御
类型7：戒指		绝技攻击
类型8：项链		生命值
类型9：奇物		法术防御
类型10：战靴	绝技防御
]]

Enum_EuipMainType = {
	Weapon = 1,
	Clothes = 2,
	Ring = 3,
	Necklace = 4,
	HolyEquip = 5,
	Shoes = 6
}

Enum_EuipSubType = {
	Gloves = 1,
	Sword = 2,
	Bow = 3,
	Staff = 4,
	Spear = 5,
	Clothes = 6,
	Ring = 7,
	Necklace = 8,
	HolyEquip = 9,
	Shoes = 10
}

Enum_EquipMainPropType = {
	[1] = Enum_PropType.PhyAttack,
	[2] = Enum_PropType.PhyAttack,
	[3] = Enum_PropType.PhyAttack,
	[4] = Enum_PropType.MagAttack,
	[5] = Enum_PropType.PhyAttack,
	[6] = Enum_PropType.PhyDefence,
	[7] = Enum_PropType.SkillAttack,
	[8] = Enum_PropType.HPMax,
	[9] = Enum_PropType.MagDefence,
	[10] = Enum_PropType.SkillDefence
}

Enum_EquipDanYaoPropType = {
	[1] = Enum_PropType.HPMax,
	[2] = Enum_PropType.PhyAttack,
	[3] = Enum_PropType.PhyDefence,
	[4] = Enum_PropType.HPMax,
	[5] = Enum_PropType.MagAttack,
	[6] = Enum_PropType.MagDefence,
	[7] = Enum_PropType.HPMax,
	[8] = Enum_PropType.SkillAttack,
	[9] = Enum_PropType.SkillDefence,
}

--装备主属性名称
g_tbMainPropName = 
{
	_T("物攻"),
	_T("物攻"),
	_T("物攻"),
	_T("法攻"),
	_T("物攻"),

	_T("物防"),
	_T("绝攻"),
	_T("生命"),
	_T("法防"),
	_T("绝防")
}

--异兽属性类型
Enum_FatePropType = {
	[1] = Enum_PropType.ManaMax,
	[2] = Enum_PropType.HPMax,
	[3] = Enum_PropType.PhyAttack,
	[4] = Enum_PropType.PhyDefence,
	[5] = Enum_PropType.MagAttack,
	[6] = Enum_PropType.MagDefence,
	[7] = Enum_PropType.SkillAttack,
	[8] = Enum_PropType.SkillDefence,
	[9] = Enum_PropType.CriticalChance,
	[10] = Enum_PropType.CriticalResistance,
	[11] = Enum_PropType.CriticalStrike,
	[12] = Enum_PropType.CriticalStrikeResistance,
	[13] = Enum_PropType.HitChance,
	[14] = Enum_PropType.DodgeChance,
	[15] = Enum_PropType.PenetrateChance,
	[16] = Enum_PropType.BlockChance,
}

--异兽类型名称
g_tbFatePropName = 
{
	_T("气势"),   	 --类型1：气势异兽
	_T("生命"),	 --类型2：生命异兽
	_T("物攻"),	 --类型3：物理攻击异兽
	_T("物防"),     --类型4：物理防御异兽
	_T("法攻"),	 --类型5：法术攻击异兽
	_T("法防"),	 --类型6：法术防御异兽
	_T("绝攻"),     --类型7：绝技攻击异兽
	_T("绝防"),	 --类型8：绝技防御异兽
	_T("暴击"),	 --类型9：暴击异兽
	_T("韧性"),	 --类型10：韧性异兽
	_T("必杀"),	 --类型11：必杀异兽
	_T("刚毅"),	 --类型12：刚毅异兽
	_T("命中"),	 --类型13：命中异兽
	_T("闪避"),	 --类型14：闪避异兽
	_T("破击"),	 --类型15：破击异兽
	_T("格挡")	 --类型16：格挡异兽
}

--上香属性名
-- g_tbEquipMainProp = 
-- {
	-- [4] =	"生命",				--增加生命上限
	-- [5] =	"物攻",				--增加物理攻击
	-- [6] =	"物防",				--增加物理防御
	-- [7] =	"法攻",				--增加法术攻击
	-- [8] =	"法防",				--增加法术防御
	-- [9] =	"绝攻",				--增加绝技攻击
	-- [10] =	"绝防",				--增加绝技防御
-- }

--异兽属性类型
g_PrestigeLevel = {
	[1] = 10000,
	[2] = 20000,
	[3] = 30000,
	[4] = 40000,
	[5] = 50000,
	[6] = 60000,
	[7] = 70000,
	[8] = 80000,
	[9] = 90000,
	[10] = 100000,
	[11] = 110000,
	[12] = 120000,
	[13] = 130000,
	[14] = 140000,
	[15] = 150000
}

do
	g_WidgetModel = {}
	local root = GUIReader:shareReader():widgetFromJsonFile("Game_ItemPNL.json")
	root:retain()
	g_WidgetModel.root = root 
	local itemModel = nil

	itemModel = root:getChildByName("Image_DropCard")
	CCAssert(itemModel, "Image_DropCard")
	itemModel:setVisible(true)
	g_WidgetModel.Image_DropCard = itemModel
	
	itemModel = root:getChildByName("Image_DropEquip")
	CCAssert(itemModel, "Image_DropEquip")
	itemModel:setVisible(true)
	g_WidgetModel.Image_DropEquip = itemModel
	
	itemModel = root:getChildByName("Image_DropFate")
	CCAssert(itemModel, "Image_DropFate")
	itemModel:setVisible(true)
	g_WidgetModel.Image_DropFate = itemModel
	
	itemModel = root:getChildByName("Image_DropHunPoItem")
	CCAssert(itemModel, "Image_DropHunPoItem")
	itemModel:setVisible(true)
	g_WidgetModel.Image_DropHunPoItem = itemModel
	
	itemModel = root:getChildByName("Image_DropItemMaterial")
	CCAssert(itemModel, "Image_DropItemMaterial")
	itemModel:setVisible(true)
	g_WidgetModel.Image_DropItemMaterial = itemModel
	
	itemModel = root:getChildByName("Image_DropItemSkillFrag")
	CCAssert(itemModel, "Image_DropItemSkillFrag")
	itemModel:setVisible(true)
	g_WidgetModel.Image_DropItemSkillFrag = itemModel
	
	itemModel = root:getChildByName("Image_DropItemUseItem")
	CCAssert(itemModel, "Image_DropItemUseItem")
	itemModel:setVisible(true)
	g_WidgetModel.Image_DropItemUseItem = itemModel
	
	itemModel = root:getChildByName("Image_DropItemFormula")
	CCAssert(itemModel, "Image_DropItemFormula")
	itemModel:setVisible(true)
	g_WidgetModel.Image_DropItemFormula = itemModel
	
	itemModel = root:getChildByName("Image_DropItemEquipPack")
	CCAssert(itemModel, "Image_DropItemEquipPack")
	itemModel:setVisible(true)
	g_WidgetModel.Image_DropItemEquipPack = itemModel
	
	itemModel = root:getChildByName("Image_DropCardSoul")
	CCAssert(itemModel, "Image_DropCardSoul")
	itemModel:setVisible(true)
	g_WidgetModel.Image_DropCardSoul = itemModel
	
	itemModel = root:getChildByName("Image_DropResource")
	CCAssert(itemModel, "Image_DropResource")
	itemModel:setVisible(true)
	g_WidgetModel.Image_DropResource = itemModel
	
	itemModel = root:getChildByName("Image_DropError")
	CCAssert(itemModel, "Image_DropError")
	itemModel:setVisible(true)
	g_WidgetModel.Image_DropError = itemModel
	
	itemModel = root:getChildByName("Image_RewardCard")
	CCAssert(itemModel, "Image_RewardCard")
	itemModel:setVisible(true)
	g_WidgetModel.Image_RewardCard = itemModel
	
	itemModel = root:getChildByName("Image_RewardEquip")
	CCAssert(itemModel, "Image_RewardEquip")
	itemModel:setVisible(true)
	g_WidgetModel.Image_RewardEquip = itemModel
	
	itemModel = root:getChildByName("Image_RewardFate")
	CCAssert(itemModel, "Image_RewardFate")
	itemModel:setVisible(true)
	g_WidgetModel.Image_RewardFate = itemModel
	
	itemModel = root:getChildByName("Image_RewardHunPo")
	CCAssert(itemModel, "Image_RewardHunPo")
	itemModel:setVisible(true)
	g_WidgetModel.Image_RewardHunPo = itemModel
	
	itemModel = root:getChildByName("Image_RewardMaterial")
	CCAssert(itemModel, "Image_RewardMaterial")
	itemModel:setVisible(true)
	g_WidgetModel.Image_RewardMaterial = itemModel
	
	itemModel = root:getChildByName("Image_RewardFrag")
	CCAssert(itemModel, "Image_RewardFrag")
	itemModel:setVisible(true)
	g_WidgetModel.Image_RewardFrag = itemModel
	
	itemModel = root:getChildByName("Image_RewardUseItem")
	CCAssert(itemModel, "Image_RewardUseItem")
	itemModel:setVisible(true)
	g_WidgetModel.Image_RewardUseItem = itemModel
	
	itemModel = root:getChildByName("Image_RewardFormula")
	CCAssert(itemModel, "Image_RewardFormula")
	itemModel:setVisible(true)
	g_WidgetModel.Image_RewardFormula = itemModel
	
	itemModel = root:getChildByName("Image_RewardEquipPack")
	CCAssert(itemModel, "Image_RewardEquipPack")
	itemModel:setVisible(true)
	g_WidgetModel.Image_RewardEquipPack = itemModel
	
	itemModel = root:getChildByName("Image_RewardSoul")
	CCAssert(itemModel, "Image_RewardSoul")
	itemModel:setVisible(true)
	g_WidgetModel.Image_RewardSoul = itemModel
	
	itemModel = root:getChildByName("Image_RewardResource")
	CCAssert(itemModel, "Image_RewardResource")
	itemModel:setVisible(true)
	g_WidgetModel.Image_RewardResource = itemModel
	
	--布阵界面的头像模板
	itemModel = root:getChildByName("Panel_Member")
	itemModel:setVisible(true)
	--屏蔽点击声音
	itemModel:getChildByName("ImageView_Base"):setEnablePlaySound(false)
	g_WidgetModel.Panel_Member = itemModel
	
	--猎命异兽
	itemModel = root:getChildByName("Panel_HuntFate")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_HuntFate = itemModel
	
	--警告飘字
	itemModel = root:getChildByName("Image_SysWarningTipPNL")
	itemModel:setVisible(true)
	g_WidgetModel.Image_SysWarningTipPNL = itemModel
	
	--飘字
	itemModel = root:getChildByName("Image_SysTipPNL")
	itemModel:setVisible(true)
	g_WidgetModel.Image_SysTipPNL = itemModel

    itemModel = root:getChildByName("Image_EuipeIconRect")
	itemModel:setVisible(true)
	g_WidgetModel.Image_EuipeIconRect = itemModel

    itemModel = root:getChildByName("Image_EuipeIconCircle")
	itemModel:setVisible(true)
	g_WidgetModel.Image_EuipeIconCircle = itemModel

    itemModel = root:getChildByName("Image_PackageIconEquip")
	itemModel:setVisible(true)
    itemModel:setPositionXY(0,0)
	g_WidgetModel.Image_PackageIconEquip = itemModel

    itemModel = root:getChildByName("Panel_EuipeRow")
	itemModel:setVisible(true)
	g_WidgetModel.PanelEuipeRow = itemModel 
	
	itemModel = root:getChildByName("Image_PlayerInfoPNL")
	itemModel:setVisible(true)
	g_WidgetModel.Image_PlayerInfoPNL = itemModel
	
    itemModel = root:getChildByName("Panel_CardTitle")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_CardTitle = itemModel

    itemModel = root:getChildByName("Button_CardItemHasSummon")
	itemModel:setVisible(true)
	g_WidgetModel.Button_CardItemHasSummon = itemModel

    itemModel = root:getChildByName("Button_CardItemUnSummon")
	itemModel:setVisible(true)
	g_WidgetModel.Button_CardItemUnSummon = itemModel
	
	itemModel = root:getChildByName("Image_EquipWorkMaterial")
	itemModel:setVisible(true)
    itemModel:setPositionXY(0,0)
	g_WidgetModel.EquipWorkMaterial = itemModel	
	
	itemModel = root:getChildByName("Image_EquipWorkFormula")
	itemModel:setVisible(true)
    itemModel:setPositionXY(0,0)
	g_WidgetModel.EquipWorkFormula = itemModel
	
	itemModel = root:getChildByName("Image_EquipWorkFrag")
	itemModel:setVisible(true)
    itemModel:setPositionXY(0,0)
	g_WidgetModel.Image_EquipWorkFrag = itemModel
	
	itemModel = root:getChildByName("Button_FilterItem")
	itemModel:setVisible(true)
	g_WidgetModel.Button_FilterItem = itemModel
	
	itemModel = root:getChildByName("Label_RandomProp")
	itemModel:setVisible(true)
    itemModel:setPositionXY(0,0)
	g_WidgetModel.RandomProp = itemModel

    itemModel = root:getChildByName("Image_PackageIconEquip")
	itemModel:setVisible(true)
	g_WidgetModel.Image_PackageIconEquip = itemModel

    itemModel = root:getChildByName("Image_PackageIconHunPo")
	itemModel:setVisible(true)
	g_WidgetModel.Image_PackageIconHunPo = itemModel

    itemModel = root:getChildByName("Image_PackageIconUseItem")
	itemModel:setVisible(true)
	g_WidgetModel.Image_PackageIconUseItem = itemModel

    itemModel = root:getChildByName("Image_PackageIconMaterial")
	itemModel:setVisible(true)
	g_WidgetModel.Image_PackageIconMaterial = itemModel
	
	itemModel = root:getChildByName("Image_PackageIconFormula")
	itemModel:setVisible(true)
	g_WidgetModel.Image_PackageIconFormula = itemModel
	
	itemModel = root:getChildByName("Image_PackageIconEquipPack")
	itemModel:setVisible(true)
	g_WidgetModel.Image_PackageIconEquipPack = itemModel

    itemModel = root:getChildByName("Image_PackageIconSoul")
	itemModel:setVisible(true)
	g_WidgetModel.Image_PackageIconSoul = itemModel
	
	itemModel = root:getChildByName("Image_PackageIconSkillFrag")
	itemModel:setVisible(true)
	g_WidgetModel.Image_PackageIconSkillFrag = itemModel
	
	itemModel = root:getChildByName("Panel_MailBoxItem")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_MailBoxItem = itemModel

    itemModel = root:getChildByName("Panel_FateRow")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_FateRow = itemModel
	
	itemModel = root:getChildByName("Button_DailyRewardsItem")
	itemModel:setVisible(true)
	g_WidgetModel.Button_DailyRewardsItem = itemModel
	
	itemModel = root:getChildByName("Button_CardItemLevelUp1")
	itemModel:setVisible(true)
	g_WidgetModel.Button_CardItemLevelUp1 = itemModel
	
	itemModel = root:getChildByName("Image_HuntFateItem")
	itemModel:setVisible(true)
	g_WidgetModel.Image_HuntFateItem = itemModel

    itemModel = root:getChildByName("Image_FateItem")
	itemModel:setVisible(true)
    itemModel:setPosition(ccp(-50, -50))
	g_WidgetModel.Image_FateItem = itemModel
	
	itemModel = root:getChildByName("Panel_CardPos")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_CardPos = itemModel
	
	itemModel = root:getChildByName("Image_NPCGuideTipPNL")
	itemModel:setVisible(true)
	g_WidgetModel.Image_NPCGuideTipPNL = itemModel
	
	itemModel = root:getChildByName("Image_BattleMember")
	itemModel:setVisible(true)
	g_WidgetModel.Image_BattleMember = itemModel
	
	itemModel = root:getChildByName("Panel_EctypeItem")
	if itemModel then
	itemModel:setVisible(true)
	g_WidgetModel.Panel_EctypeItem = itemModel
	end
	
	
	itemModel = root:getChildByName("Image_CardGroupPNL")
	itemModel:setVisible(true)
	g_WidgetModel.Image_CardGroupPNL = itemModel
	
	itemModel = root:getChildByName("Image_CardGroupViewPNL")
	itemModel:setVisible(true)
	g_WidgetModel.Image_CardGroupViewPNL = itemModel
	
	itemModel = root:getChildByName("Panel_SocialItem_Neighbor")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_SocialItem_Neighbor = itemModel
	
	itemModel = root:getChildByName("Panel_SocialItem_Friend")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_SocialItem_Friend = itemModel
	
	itemModel = root:getChildByName("Panel_SocialItem_Application")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_SocialItem_Application = itemModel
	
	itemModel = root:getChildByName("Panel_NpcItem")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_NpcItem = itemModel
	
	itemModel = root:getChildByName("Panel_Enemy")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_Enemy = itemModel
	
	itemModel = root:getChildByName("Image_ZhenFaRowPNL")
	itemModel:setVisible(true)
	g_WidgetModel.Image_ZhenFaRowPNL = itemModel
	
	itemModel = root:getChildByName("Image_XinFaRowPNL")
	itemModel:setVisible(true)
	g_WidgetModel.Image_XinFaRowPNL = itemModel
	
	itemModel = root:getChildByName("Image_ZhanShuRowPNL")
	itemModel:setVisible(true)
	g_WidgetModel.Image_ZhanShuRowPNL = itemModel
	
	itemModel = root:getChildByName("Panel_RankItem")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_RankItem = itemModel
	
	itemModel = root:getChildByName("Panel_WorldChatItem")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_WorldChatItem = itemModel
	
	itemModel = root:getChildByName("Panel_ChatListItemMe")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_ChatListItemMe = itemModel
	
	itemModel = root:getChildByName("Panel_ChatListItemDiv")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_ChatListItemDiv = itemModel
	
	itemModel = root:getChildByName("Panel_ChatListItemOther")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_ChatListItemOther = itemModel
	
	itemModel = root:getChildByName("Panel_GroupChatItem")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_GroupChatItem = itemModel
	
	itemModel = root:getChildByName("Panel_SystemBrocastItem")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_SystemBrocastItem = itemModel
	
	itemModel = root:getChildByName("Panel_FriendsItem")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_FriendsItem = itemModel
	
	itemModel = root:getChildByName("Panel_BugReportItem")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_BugReportItem = itemModel
	
	itemModel = root:getChildByName("Panel_ZhenFaItem")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_ZhenFaItem = itemModel
	
	itemModel = root:getChildByName("Panel_LogItem")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_LogItem = itemModel
	
	--系统公告
	itemModel = root:getChildByName("Panel_SystemBrocast")
	itemModel:setVisible(true)
	g_WidgetModel.Panel_SystemBrocast = itemModel
	
	local imageName = {
		"Image_TenSummonCard","Image_TenSummonEquip","Image_TenSummonFate",
		"Image_TenSummonHunPo","Image_TenSummonMaterial","Image_TenSummonSkillFrag",
		"Image_TenSummonUseItem","Image_TenSummonFormula","Image_TenSummonSoul","Image_TenSummonEquipPack",
	}
	for key, value in ipairs(imageName) do 
		itemModel = root:getChildByName(value)
		itemModel:setPosition(ccp(0,0))
		itemModel:setVisible(true)
		g_WidgetModel[value] = itemModel
	end
end

--[[
g_tbAtlasStr = 
{
	[0] = "0",
	[1] = "1",
	[2] = "2",
	[3] = "3",
	[4] = "4",
	[5] = "5",
	[6] = "6",
	[7] = "7",
	[8] = "8",
	[9] = "9",
	[10] = ":",
	[11] = ";",
	[12] = "<",
	[13] = "=",
	[14] = "?",
	[15] = "@",
	[16] = "A",
	[17] = "B",
	[18] = "C",
	[19] = "D",
	[20] = "E",
	[21] = "F",
}
]]
g_tbRealmName = 
{
	[0] = _T("凡夫俗子"),
	[1] = _T("练气初期"),
	[2] = _T("练气中期"),
	[3] = _T("练气后期"),
	[4] = _T("筑基初期"),
	[5] = _T("筑基中期"),
	[6] = _T("筑基后期"),
	[7] = _T("结丹初期"),
	[8] = _T("结丹中期"),
	[9] = _T("结丹后期"),
	[10] = _T("元婴初期"),
	[11] = _T("元婴中期"),
	[12] = _T("元婴后期"),
	[13] = _T("化神初期"),
	[14] = _T("化神中期"),
	[15] = _T("化神后期"),
	[16] = _T("炼虚初期"),
	[17] = _T("炼虚中期"),
	[18] = _T("炼虚后期"),
	[19] = _T("合体初期"),
	[20] = _T("合体中期"),
	[21] = _T("合体后期"),
	[22] = _T("大乘初期"),
	[23] = _T("大乘中期"),
	[24] = _T("大乘后期"),
	[25] = _T("渡劫初期"),
	[26] = _T("渡劫中期"),
	[27] = _T("渡劫后期")
}

g_tbRealmFatherName = 
{
	[0] = "",
	[1] = _T("炼气"),
	[2] = _T("筑基"),
	[3] = _T("结丹"),
	[4] = _T("元婴"),
	[5] = _T("化神"),
	[6] = _T("炼虚"),
	[7] = _T("合体"),
	[8] = _T("大乘"),
	[9] = _T("渡劫")
}


g_profession = 
{
	[0] = _T("IT/通信/电子/互联网"),
	[1] = _T("生产/工艺/制造"),
	[2] = _T("金融/银行/投资/保险"),
	[3] = _T("房产/建筑/装修"),
	[4] = _T("贸易/批发/零售/租赁"),
	[5] = _T("商业/服务业/个体经营"),
	[6] = _T("交通/运输/物流/仓储"),
	[7] = _T("文化/广告/传媒"),
	[8] = _T("娱乐/艺术/表演/体育"),
	[9] = _T("医疗/护理/制药"),
	[10] = _T("律师/法务"),
	[11] = _T("教育/培训"),
	[12] = _T("公务员/事业单位"),
	[13] = _T("能源/矿产/环保"),
	[14] = _T("农业/林业/畜牧业/农副产品/渔业"),
	[15] = _T("学生"),
	[16] = _T("无")
}

g_SkillBaseAttackArea = 
{
	[0] = _T("单体攻击"),
	[1] = _T("单体攻击"),
	[2] = _T("纵向攻击"),
	[3] = _T("横向攻击"),
	[4] = _T("全体攻击"),
	[5] = _T("前排攻击"),
	[6] = _T("后排攻击"),
	[7] = _T("血量最低"),
	[8] = _T("随机目标"),
	[9] = _T("怒气最高"),
	[10] = _T("血量最低"),
	[11] = _T("二连击"),
	[12] = _T("三连击")
}

g_social_sex =
{
	_T("男"),
	_T("女")
} 

--游戏背景音乐
g_GameMusic = "Sound/Music/Backgound_Sad.mp3"

--按钮自动增加频率（可用于元神自动增加之类），值越小，速度越快
g_AutoIncrSpd = 0.025

--CCJson =  require "cjson"
INT_MIN = (-2147483647 - 1) 
INT_MAX = 2147483647 

g_MaxPropID = #g_PropName --属性ID的个数
g_BasePercent = 10000
g_nMaxSp = 100
g_PressingEventDelayTime = 0.5

-- 副本ID号从 2000001（等于大于） 开始表示为精英副本
ELITE_ECTYPE_START_ID = 2000001 

DU_JIE_S = false --记录是否渡劫成功了 
YI_SHOU_S = false --记录是否打开过妖兽界面
DAN_YAO_S = false --记录丹药界面
CHANG_CHENG_S = false --记录传承界面