------------------------------------------------------
--vip权限管理
------------------------------------------------------
VipPowerId =
{
	scene_fly 						= 0,			-- 传送
	key_dialy_task 					= 1,			-- 一键日常
	husong_buy_times 				= 2,			-- 购买护送次数
	vip_level_reward				= 3,			-- vip等级礼包
	qianghua_suc					= 4,			-- 强化成功率
	vip_revive 						= 9, 			-- vip免费复活

	four_outline_exp				= 12,			-- 离线4倍经验领取
	exp_fb_buy_times				= 13,			-- 经验本扫荡次数
	coin_fb_buy_times				= 14,			-- 铜币本扫荡次数
	jingling_catch					= 16, 			-- 精灵捕获
	daoju_fb_buy_times				= 17, 			-- 道具副本扫荡次数
	clean_merdian_cd 				= 18,			--清除经脉CD
	lingyu_fb_buy_times 			= 19,			--灵玉挑战副本可购买次数
	lingyu_fb_free_times 			= 20,			--灵玉挑战副本免费扫荡次数

	tili 							= 1,			--体力
	yao_money 						= 2,			--摇钱
	yao_jingyuan 					= 3,			--摇精元
	yao_xianhun						= 4,			--摇仙魂
	exp_fbsd_free_times 			= 6,			--经验本扫荡免费次数
	buy_enter_suoyaota	 			= 7,			--购买锁妖塔次数
	buy_enter_yaoshouplaza 			= 8,			--购买妖兽广场次数
	auto_dialy_task 				= 10,			--自动日常
	buy_act_reward 					= 12,			--购买活动奖励
	key_answer 						= 13,			--一键答题
	xunbao_150_times 				= 14,			--150次寻宝
	weapon_fb_buy_times     		= 15,			--过图本购买次数
	weapon_fbsd_free_auto_times    	= 16,			--过图免费扫荡次数
	tower_fb_buy_times    			= 17,			--塔防购买次数
	tower_fbsd_free_auto_times    	= 18,			--塔防免费扫荡次数
	quality_fb_buy_times 			= 19,			--挑战本重置次数
	quality_fbsd_free_auto_times 	= 20,			--挑战本免费扫荡次数
	shop_discount 					= 21,			--市场手续费折扣
	act_qibing 						= 22,			--激活骑兵
	xianmeng_jiuhui_cd 				= 24,			--仙盟酒会CD
	peri_leido 						= 25,			--仙女掠夺额外次数
	clean_qifu_cd					= 26,			--忽略祈福cd
	tower_defend_buy_count			= 27,			--个人塔防可购买次数
	auto_shengwu_chou				= 28,			--圣物自动回收碎片
	auto_shengwu_ten				= 29,			--圣物10次回收
	push_common_buy_times			= 31,			--购买元素试炼挑战次数
	push_special_buy_times			= 32,			--购买炼狱试炼挑战次数
}


VipPower = VipPower or BaseClass()
function VipPower:__init()
	if VipPower.Instance ~= nil then
		print_error("[VipPower] Attemp to create a singleton twice !")
	end
	VipPower.Instance = self
end

function VipPower:__delete()
	VipPower.Instance = nil
end

function VipPower:GetPowerCfg(power_id)
	local vip_power_cfg_list = ConfigManager.Instance:GetAutoConfig("vip_auto").level
	return vip_power_cfg_list[power_id]
end

--获得当前vip权限下的参数
function VipPower:GetParam(power_id)
	local vip_cfg = self:GetPowerCfg(power_id)
	if vip_cfg == nil then
		return 0
	end

	local vip_level = PlayerData.Instance.role_vo.vip_level
	local power_value = vip_cfg["param_" .. vip_level] or 0
	return power_value
end

--获得vip等级限制
--@返回该权限的最低vip等级要求
--@param默认为1，如果次数请传具体值
function VipPower:GetMinVipLevelLimit(power_id, param)
	local vip_cfg = self:GetPowerCfg(power_id)
	if vip_cfg == nil then
		return 0
	end
	param = param or 1
	local vip_level = PlayerData.Instance.role_vo.vip_level
	local vip_power_cfg_list = ConfigManager.Instance:GetAutoConfig("vip_auto").level
	for k,v in pairs(vip_power_cfg_list) do
		if v.auth_type == power_id then --对应的权限
			for i=0, 15 do --vip最高10级
				local vip_param = v["param_".. i] or 0
				if vip_param >= param then
					return i, vip_param
				end
			end
		end
	end
	return -1, param
end