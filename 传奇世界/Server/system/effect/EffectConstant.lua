--EffectConstant.lua
--物品效果常量

--效果表
EffectRecord = {}

--礼包表
GiftRecord = {}


function __initConfig()
	--效果
	local effect = require "data.EffectDB"
	local effectSize = #effect

	for i=1, effectSize do
		local tmp = {}
		local tmpEff = effect[i]
		tmp.effectType = tmpEff.q_effectType
		tmp.task = tonumber(tmpEff.q_task) or 0
		tmp.script = tmpEff.q_script or 0
		tmp.gift = tonumber(tmpEff.q_gift) or 0
		tmp.ui = tmpEff.q_ui or 0
		tmp.mapID = tonumber(tmpEff.q_mapID) or 0
		tmp.xPos = tonumber(tmpEff.q_xPos) or 0
		tmp.yPos = tonumber(tmpEff.q_yPos) or 0
		tmp.drug = tmpEff.q_drug and unserialize("{"..tmpEff.q_drug.."}") or {}
		tmp.buff = tonumber(tmpEff.q_buff) or 0
		tmp.effectAttr = tmpEff.q_effect_attr and unserialize("{"..tmpEff.q_effect_attr.."}") or {}
		tmp.skillLvl = tonumber(tmpEff.q_skillLvl) or 0
		tmp.lvlExp = tonumber(tmpEff.q_level) or 0
		tmp.expMoney = unserialize(tmpEff.q_exp) or {}
		tmp.dropID = tonumber(tmpEff.dropID) or 0
		tmp.pickPer = tonumber(tmpEff.wkjl) or 0
		tmp.bagIdx = tonumber(tmpEff.bagIdx) or 1
		tmp.act_id = tonumber(tmpEff.act_id) or 0
		tmp.act_module_id = tonumber(tmpEff.act_module_id) or 0
		tmp.q_id = tonumber(tmpEff.q_id) or 0
		if EffectRecord[tmpEff.q_id] then
			table.deepCopy1(tmp, EffectRecord[tmpEff.q_id])
		else
			table.insert(EffectRecord, tmpEff.q_id, tmp)
		end
	end
	--礼包
	local giftConfig = require "data.GiftDB"
	for _, con in pairs(giftConfig) do
		local tmp = {}
		tmp.giftName = con.q_gift_name  or ""
		tmp.giftType = con.q_gift_type  or 0
		tmp.usualItem = unserialize(con.q_gift_data) or {}	--格式（道具ID,数量,绑定（0,1绑定）,消失时间,强化等级,）格式：{{40102001,1,0,0,0}, {10502001,2,0,1,0},.......... }
		tmp.randItem = unserialize(con.q_random_gift_data) or {}
		tmp.bindMoney = con.q_gift_money  or 0
		tmp.bindIngot = con.q_gift_gold  or 0
		tmp.needIngot = con.q_unfreegold  or 0
		tmp.freeChance = con.q_gift_freetime  or 0
		tmp.bindSign = con.q_bind or 0
		tmp.usedTime = con.q_usetime  or 0
		if GiftRecord[con.q_gift_id] then
			table.deepCopy1(tmp, GiftRecord[con.q_gift_id])
		else
			table.insert(GiftRecord, con.q_gift_id, tmp)
		end
	end
end


EffectType = 
{
	ChangeAttribute = 0x01,	--改变玩家属性
	Send = 0x02,	--传送
	AddBuff = 0x03,	--添加BUFF
	RandSend = 0x04,	--随机传送
	LearnSkill = 0x05,	--学习技能通过技能ID
	ItemGift = 0x06,	--礼包
	ItemChest = 0x07,	--宝箱
	AddConquerTask = 0x08,	--讨伐任务
	ItemDropChest = 12,	--根据掉落给物品的宝箱
	Potential = 13,	--潜能丹
	ActivityUse = 20, --活动使用
	CommandBook = 21, --密令卷轴
	EnvoyExpEffect = 22,	--炼狱体验
	TreasureExpEffect = 23,	--宝地体验
	MarriageDrinkEffect = 91,	--婚礼会场喝酒
}



EffectAttrMap = {
	[1] = PLAYER_XP,	--经验
	[2] = ROLE_HP,	--血
	[3] = ROLE_MP,	--蓝
	[4] = ROLE_LEVEL,	--等级
	[5] = ROLE_MIN_AT,	--物攻下限
	[6] = ROLE_MAX_AT,	--物攻上限
	[7] = ROLE_MIN_DF,	--道术下限
	[8] = ROLE_MAX_DF,	--道术上限
	[9] = ROLE_MIN_MT,	--魔法下限
	[10] = ROLE_MAX_MT,	--魔法上限
	[11] = ROLE_MIN_MF,	--魔防下限
	[12] = ROLE_MAX_MF,	--魔防上限
	[13] = ROLE_MIN_DT,	--物防下限
	[14] = ROLE_MAX_DT,	--物防上限
	[15] = ROLE_HIT,	--命中
}


ITEM_BIND_MONEY_ID = 999999
ITEM_MONEY_ID = 999998
ITEM_EXP_ID = 444444
ITEM_BIND_INGOT_ID = 888888
ITEM_INGOT_ID = 222222
ITEM_VITAL_ID = 777777
ITEM_FCONT_ID = 111111	--帮贡
ITEM_HONOUR_ID = 333333	--荣誉
MAX_UNSIGNEDINT_NUM = 2000000000

ITEM_STR = {}
--获取经验元宝真气等的utf-8编码字符串
function initConstName()
	local configMgr = g_entityMgr:getConfigMgr()
	local proto = configMgr:getItemProto(ITEM_INGOT_ID)
	if proto then
		ITEM_STR.INGOT = proto.name 
	end
	proto = configMgr:getItemProto(ITEM_BIND_INGOT_ID)
	if proto then
		ITEM_STR.BINDINGOT = proto.name 
	end
	proto = configMgr:getItemProto(ITEM_VITAL_ID)
	if proto then
		ITEM_STR.VITAL = proto.name 
	end
	proto = configMgr:getItemProto(ITEM_BIND_MONEY_ID)
	if proto then
		ITEM_STR.BINDMONEY = proto.name 
	end
	proto = configMgr:getItemProto(ITEM_MONEY_ID)
	if proto then
		ITEM_STR.MONEY = proto.name 
	end
	proto = configMgr:getItemProto(ITEM_EXP_ID)
	if proto then
		ITEM_STR.EXP = proto.name 
	end
end

Item_OP_Result_GetItem = 1	--获得物品
Item_OP_Result_GainSkill = 2	--通过道具学会技能
Item_OP_Result_ReduceItem = 3	--失去物品
Item_OP_Result_GainLuck = 4	--增加幸运值，参数一个
Item_OP_Result_ReduceLuck = 5	--减少幸运值参数一个
Item_OP_Result_FullLuck	= 6	--幸运值已满
Item_OP_Result_LuckFailed = 7	--使用祝福油加幸运值失败
Item_OP_Result_NOPK	= 8		--没有PK值不能使用
Item_OP_Result_ReducePK	= 9	--减少PK值
Item_OP_Result_CannotUseSendItem = 10	--副本中不能使用传送类道具
Item_OP_Result_CannotUseBuffItem = 11	--已经拥有了某种BUFF，不能继续使用某物品添加BUFF
Item_OP_Result_MAXLEVEL = 12 --已经达到最大等级
Item_OP_Result_MAXMONEY = 13	--货币已经达到上限了
Item_OP_Result_CannotBatchUse = 14	--不能批量使用
Item_OP_Result_MaxCntUseUp = 15	--使用数量已经达到上限，具体能使用多少看道具的tips
Item_OP_Result_MAXPICKAX  = 16	--每日使用锄头次数达到最大
Item_OP_Result_OPENBAGSLOT = 17	--使用开苞符成功，提示开启多少个格子
Item_OP_Result_OPENBANKSLOT = 18	--使用开仓符成功，提示开启多少个格子