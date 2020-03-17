--[[
VIP Controller
2015年7月22日17:37:50
haohu
]]
---------------------------------------------------------

_G.VipController = setmetatable( {}, {__index = IController} )
VipController.name = "VipController"
VipController.isShowWeekEffect = false
VipController.isShowLvEffect = false
function VipController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_VipExp, self, self.OnVipExp )
	MsgManager:RegisterCallBack( MsgType.SC_VipPeriod, self, self.OnVipPeriod )
	MsgManager:RegisterCallBack( MsgType.SC_VipLevelRewardState, self, self.OnVipLevelRewardState )
	MsgManager:RegisterCallBack( MsgType.SC_VipWeekRewardState, self, self.OnVipWeekRewardState )
	MsgManager:RegisterCallBack( MsgType.SC_VipRenew, self, self.OnVipRenew )
	MsgManager:RegisterCallBack( MsgType.SC_VipLevelRewardAccept, self, self.OnVipLevelRewardAccept )
	MsgManager:RegisterCallBack( MsgType.SC_VipWeekRewardAccept, self, self.OnVipWeekRewardAccept )
	
	MsgManager:RegisterCallBack( MsgType.SC_VipInitState, self, self.OnVipInitStateResult )
	
	MsgManager:RegisterCallBack( MsgType.SC_VipBackInfo, self, self.OnVipBackInfo )
	MsgManager:RegisterCallBack( MsgType.SC_GetVipBack, self, self.OnGetVipBack )
	VipModel:Init()
end

----------------------------------------------Response-----------------------------------------------

-- 服务器通知:vip经验
function VipController:OnVipExp( msg )
	QuestController:TestTrace( "服务器通知:vip经验" )
	QuestController:TestTrace( msg )

	VipModel:SetVipExp( msg.exp )
end

-- 服务器通知:vip剩余时间
function VipController:OnVipPeriod( msg )
	QuestController:TestTrace( "服务器通知:vip剩余时间" )
	QuestController:TestTrace( msg )

	for _, vo in pairs(msg.period) do
		VipModel:SetVipPeriod( vo.vipType, vo.time )
	end
end

-- 服务器通知:vip等级奖励领取状态
function VipController:OnVipLevelRewardState( msg )
	QuestController:TestTrace( "服务器通知:vip等级奖励领取状态" )
	QuestController:TestTrace( msg )
	
	for _, vo in pairs( msg.levelRewardState ) do
		VipModel:SetLevelRewardState( vo.vipLevel, false ) -- 1 已领取 0 未领取
	end
end

-- 服务器通知:vip周奖励领取状态
function VipController:OnVipWeekRewardState( msg )
	QuestController:TestTrace( "服务器通知:vip周奖励领取状态" )
	QuestController:TestTrace( msg )
	
	VipModel:SetWeekRewardState( msg.state )
end

-- 服务器通知:续费(激活)vip结果
function VipController:OnVipRenew( msg )
	QuestController:TestTrace( "服务器通知:续费(激活)vip结果" )
	QuestController:TestTrace( msg )
	
	local result = msg.result
	if result == 0 then
		VipModel:SetVipPeriod( msg.vipType, msg.time )
		Notifier:sendNotification(NotifyConsts.VipJihuoEffect, {vipType = msg.vipType}); 
		return
	end
	if result == 1 then
		FloatManager:AddCenter("元宝不足")
		return
	end
end

-- 服务器通知:领取vip等级奖励结果
function VipController:OnVipLevelRewardAccept( msg )
	QuestController:TestTrace( "服务器通知:领取vip等级奖励结果" )
	QuestController:TestTrace( msg )
	
	local result = msg.result
	if result == 0 then		
		VipModel:SetLevelRewardState( msg.vipLevel, true ) -- 1 已领取 0 未领取
		VipController.isShowLvEffect = false
		return
	end
	VipController.isShowLvEffect = false
end

-- 服务器通知:领取vip每周奖励结果

function VipController:OnVipWeekRewardAccept( msg )
	QuestController:TestTrace( "服务器通知:领取vip每周奖励结果" )
	QuestController:TestTrace( msg )
	
	local result = msg.result
	if result == 0 then		
		VipModel:SetWeekRewardState(1)
		VipController.isShowWeekEffect = false		
		return
	end
	VipController.isShowWeekEffect = false
end


function VipController:OnVipInitStateResult(msg)
	FTrace(msg, 'vip登录后返回信息')

	VipModel:SetVipExp( msg.exp )
	if msg.weekReward == 1 then-- 1 已领取 0 未领取
		
		VipModel:SetWeekRewardState(1)
	else
		VipModel:SetWeekRewardState(0)
	end
	for level = 1, VipConsts:GetMaxVipLevel() do
		VipModel:SetLevelRewardState( level, true ) 
	end
	for _, vo in pairs( msg.levelRewardState ) do
		VipModel:SetLevelRewardState( vo.vipLevel, false ) 
	end
	for _, vo in pairs(msg.period) do
		VipModel:SetVipPeriod( vo.vipType, vo.time )
	end
end

-- 服务器通知:vip返还信息结果
function VipController:OnVipBackInfo( msg )
	trace( "服务器通知:vip返还信息结果" )
	--trace( msg )
	local backType = msg.backType
	local itemvo = t_item[msg.itemId];
	if itemvo then
		local vo = {};
		vo.ischange   = false;
		vo.itemId     = msg.itemId;
		vo.itemNum    = msg.itemNum;
		vo.numCanBack = msg.numCanBack;
		VipModel:SetBackItemInfo( backType, vo );
	end
end

-- 服务器通知:领取vip返还结果
function VipController:OnGetVipBack( msg )
	FTrace( msg, "服务器通知:领取vip返还结果" )
	local backType = msg.backType
	local result = msg.result
	if result == 0 then
		print(backType,"backType:领取vip返还结果")
		VipModel:SetIsChange( backType, true )
		return
	end
end

----------------------------------------------Resquest-----------------------------------------------

-- 客户端请求:续费(激活)vip
function VipController:ReqRenewVip(vipType)
	QuestController:TestTrace( "客户端请求:续费(激活)vip" )
	QuestController:TestTrace( vipType )
	
	local msg = ReqVipRenewMsg:new()
	msg.vipType = vipType
	MsgManager:Send(msg)
end

-- 客户端请求:领取vip等级奖励
function VipController:ReqAcceptVipLevelReward(vipLevel)
	QuestController:TestTrace( "客户端请求:领取vip等级奖励" )
	QuestController:TestTrace( vipLevel )
	
	local msg = ReqVipLevelRewardAcceptMsg:new()
	msg.vipLevel = vipLevel
	MsgManager:Send(msg)
end

-- 客户端请求:领取vip每周奖励
function VipController:ReqAcceptVipWeekReward()
	QuestController:TestTrace( "客户端请求:领取vip每周奖励" )
	
	MsgManager:Send( ReqVipWeekRewardAcceptMsg:new() )
end

-- 客户端请求:请求vip返还信息
function VipController:ReqVipBackInfo(backType)
	local msg = ReqVipBackInfoMsg:new()
	msg.backType = backType
	MsgManager:Send(msg)
	FTrace( msg, "客户端请求:请求vip返还信息" )
end

-- 客户端请求:领取vip返还结果
function VipController:ReqGetVipBack(backType)
	local msg = ReqGetVipBackMsg:new()
	msg.backType = backType
	MsgManager:Send(msg)
	FTrace( msg, "客户端请求:领取vip返还结果" )
end

-----------------------------------------public interfaces---------------------------------------
--是否黄金
function VipController:IsGoldVip()
	return VipModel:GetVipPeriod( VipConsts.TYPE_GOLD ) > 0
end
-- 是否钻石
function VipController:IsDiamondVip()
	return VipModel:GetVipPeriod( VipConsts.TYPE_DIAMOND ) > 0
end
--是否白银
function VipController:IsSupremeVip()
	return VipModel:GetVipPeriod( VipConsts.TYPE_SUPREME ) > 0
end

--检测所有的vip是否都激活
function VipController:CheckIsFullVip()
	if VipController:IsGoldVip() and VipController:IsDiamondVip() and VipController:IsSupremeVip() then
		return false
	else
		return true
	end
end

--获取最优先显示图标的vip类型
function VipController:GetVipType()
	if self:IsDiamondVip() then
		return VipConsts.TYPE_DIAMOND
	end
	if self:IsGoldVip() then
		return VipConsts.TYPE_GOLD
	end
	if self:IsSupremeVip() then
		return VipConsts.TYPE_SUPREME
	end
	return 0
end

--白银vip等级
-- 未开通-1 
function VipController:GetSupremeVipLevel()
	if not self:IsSupremeVip() then
		return -1
	end	
	local vipLevel = VipController:GetVipLevel() if vipLevel <= 0 then return 0	end
	return vipLevel
end

--黄金vip等级
-- 未开通-1 
function VipController:GetGoldVipLevel()
	if not self:IsGoldVip() then
		return -1
	end	
	local vipLevel = VipController:GetVipLevel() if vipLevel <= 0 then return 0	end
	return vipLevel
end

--钻石vip等级
-- 未开通-1 
function VipController:GetDiamondVipLevel()
	if not self:IsDiamondVip() then
		return -1
	end	
	local vipLevel = VipController:GetVipLevel() if vipLevel <= 0 then return 0	end
	return vipLevel
end

--vip等级
function VipController:GetVipLevel()
	-- FPrint('vip等级'..MainPlayerModel.humanDetailInfo.eaVIPLevel)
	return MainPlayerModel.humanDetailInfo.eaVIPLevel
end

function VipController:GetLevelUpExp()
	local vipLevel = VipController:GetVipLevel()
	local maxLevel = VipConsts:GetMaxVipLevel()
	if vipLevel == maxLevel then
		local cfg = t_vip[vipLevel]
		return cfg and cfg.vip_exp
	end
	local cfg = t_vip[vipLevel + 1]
	return cfg and cfg.vip_exp
end

function VipController:GetPower(vipId)
	local vipCfg = t_vippower[vipId]
	if not vipCfg then return false end
	if not vipCfg.type then return false end	
	
	if vipCfg.type == 1 then
		return self:IsSupremeVip()
	elseif vipCfg.type == 2 then
		return self:IsGoldVip()
	elseif vipCfg.type == 3 then
		return self:IsDiamondVip()
	end
	
	return false
end

function VipController:GetPowerByIndex(index)
	local cfg = self:GetVipCfgByIndex(index)
	if not cfg then return false; end
	return self:GetPower(cfg.id);
end

function VipController:GetPowerByType(vipType)
	if vipType == 1 then
		return self:IsSupremeVip()
	elseif vipType == 2 then
		return self:IsGoldVip()
	elseif vipType == 3 then
		return self:IsDiamondVip()
	end
	
	return false
end

function VipController:GetVipNameByIndex(index)
	local vipCfg = self:GetVipCfgByIndex(index)
	if not vipCfg then
		--FPrint('找不到vip配置文件index' .. index)
		return ""
	end
			
	if vipCfg.type == 1 then
		return '白银'
	elseif vipCfg.type == 2 then
		return '黄金'
	elseif vipCfg.type == 3 then
		return '钻石'
	end
	return ""
end

function VipController:GetVipCfgByIndex(index)
	for k,v in pairs(t_vippower) do
		if index == v.index then
			return v
		end
	end
	
	return nil	
end

function VipController:GetVipPowerValueByIndex(index, lv)
	local cfg = self:GetVipCfgByIndex(index)
	if not cfg then
		--print('找不到vip配置文件index' .. index)
		return -1 
	end

	if not self:GetPower(cfg.id) and (not lv) then
		return -1
	end	
	
	if cfg.opened == 1 then
		return -1
	end
	
	local vipLevel = VipController:GetVipLevel() 
	-- if vipLevel <= 0 and (not lv) then return 0 end
	if lv then vipLevel = lv end
	if not cfg['c_v'..vipLevel] then return 0 end
	return cfg['c_v'..vipLevel] or 0
end

function VipController:GetVipPowerPersentByIndex(index, lv)
	local cfg = self:GetVipCfgByIndex(index)
	if not cfg then
		--print('找不到vip配置文件index' .. index)
		return 0 
	end
	if (not self:GetPower(cfg.id)) and (not lv) then
		print('未开通vip权限' .. index)
		return 0
	end
	local vipLevel = VipController:GetVipLevel() if vipLevel <= 0 and (not lv) then
		print('vip等级不足' .. index)
		return 0 
	end
	if cfg.opened == 1 then
		return 0
	end
	if lv then vipLevel = lv end
	if not cfg['c_v'..vipLevel] then return 0 end
	return cfg['c_v'..vipLevel]/100 or 0
end

--VIP表情
function VipController:VIPFace()
	local cfg = self:GetVipCfgByIndex(111);
	if not cfg then return false; end
	return self:GetPower(cfg.id);
end

--每周福利礼包
function VipController:GetWeekReward()
	return self:GetVipPowerValueByIndex(212)
end

--提前签次数
function VipController:GetTiqianqianNum()
	return self:GetVipPowerValueByIndex(314)	
end

--提前签次数表
function VipController:GetTiqianqianList()	
	local cfg = self:GetVipCfgByIndex(314)
	return cfg
end

--补签次数
function VipController:GetBuqianNum()
	return self:GetVipPowerValueByIndex(311)	
end


--补签次数表
function VipController:GetBuqianNumList()
	local cfg = self:GetVipCfgByIndex(311)
	return cfg
end

--聚灵碗免费灌注次数
function VipController:GetJulingwanFreeNum()	
	return self:GetVipPowerValueByIndex(315)	
end

--聚灵碗灵力累积上限增加 百分比
function VipController:GetJulingwanShangxianZengjia()
	return self:GetVipPowerPersentByIndex(102)
end

--打造活力值上限
function VipController:GetDazaoHuolizhiMax()
	return self:GetVipPowerValueByIndex(115)	
end

--副本通关额外奖励
--@return 未开通白银-1 等级不够0
function VipController:GetFubenTongguanJiangli()
	return self:GetVipPowerValueByIndex(108)	
end

--免费开启30格背包
--@return 未开通白银-1 等级不够0
function VipController:GetFubenTongguanJiangli()
	return self:GetVipPowerValueByIndex(106)
end

--免费开启30格仓库
--@return 未开通白银-1 等级不够0
function VipController:GetFubenTongguanJiangli()
	return self:GetVipPowerValueByIndex(107)
end

--vip主宰精力上限
function VipController:GetZhuzaiJinglishangxian()
	return self:GetVipPowerValueByIndex(113)
end

--主宰之路精力恢复速度提高 百分比
function VipController:GetZhuzaiJingValue()
	return self:GetVipPowerPersentByIndex(114)
end

--打造活力值在线每小时恢复速度
function VipController:GetHuolizhiOnlineSpeed(level, forceLevel)
	local cfg = self:GetVipCfgByIndex(116)
	if not cfg then
		--FPrint('找不到vip配置文件index' .. 116)
		return -1 
	end

	if not self:GetPower(cfg.id) then
		return -1
	end
	
	local addLevel = level or 0
	local vipLevel = forceLevel or VipController:GetVipLevel() + addLevel
	if not cfg['c_v'..vipLevel] then return 0 end
	return cfg['c_v'..vipLevel] or 0
end

--打造活力值在线每小时恢复速度
function VipController:GetHuolizhiOnlineVal(level, forceLevel)
	local cfg = self:GetVipCfgByIndex(116)
	if not cfg then
		--FPrint('找不到vip配置文件index' .. 116)
		return -1 
	end
	
	local addLevel = level or 0
	local vipLevel = forceLevel or VipController:GetVipLevel() + addLevel
	if not cfg['c_v'..vipLevel] then return 0 end
	return cfg['c_v'..vipLevel] or 0
end

--悬赏次数增加
function VipController:GetAgoraAddTimes()
	local times = self:GetVipPowerValueByIndex(121)
	if times > 0 then
		return times;
	end
	return  0;
end

--聚灵碗灵力产出加成（每分钟的百分比） 百分比
function VipController:GetJulingwanChanchu(level)
	return self:GetVipPowerPersentByIndex(101,level)
end

--无限地图免费传送
function VipController:GetFreeTeleport()
	return self:GetVipPowerValueByIndex(208)
end

--至尊灵藏中现有的快速采集功能
function VipController:GetQuickCollection()
	local result = self:GetVipPowerValueByIndex(210)
	if result > 0 then
		return true
	end
	
	return false
end

--VIP的发送红包功能
function VipController:GetCanSendRepacket()
	local result = self:GetVipPowerValueByIndex(308)
	if result > 0 then
		return true
	end
	
	return false
end

--一键完成日环任务
function VipController:GetOneKeyFinish()
	return self:GetVipPowerValueByIndex(211)
end

--特殊绑元券每日开启次数上限增加（10绑元的道具）tips
function VipController:GetTeshuLijinNum()
	return self:GetVipPowerValueByIndex(209)
end

--装备强化成功率增加（前面为显示的，后面为真实的，避免超过100%发生） 百分比
--@return 未开通黄金vip0 
function VipController:GetZhuangbeiQianghua()
	return self:GetVipPowerPersentByIndex(216)
end

--竞技场每日挑战次数上限购买 
function VipController:GetJingjichangNum()
	return self:GetVipPowerValueByIndex(312)
end

--属性丹每日使用总次数上限增加药单界面tips
function VipController:YaodanNum(lv)
	return self:GetVipPowerValueByIndex(310,lv)
end

--宝箱每日使用次数增加
function VipController:GetBaoxiangNum()
	return self:GetVipPowerValueByIndex(318)
end

--资源追回100%追回功能
function VipController:GetZiyuanzhuihui100()
	return self:GetVipPowerValueByIndex(319)
end

--扫荡功能100%扫荡功能
function VipController:GetSaodang100()
	return self:GetVipPowerPersentByIndex(320)
end

--宝石属性百分比提升 百分比
function VipController:GetBaoshishuxingUp(lvl)
	return self:GetVipPowerPersentByIndex(305,lvl)
end

--返还坐骑升阶消耗的灵力
function VipController:GetIsMountBack()
	return self:GetVipPowerValueByIndex(201)
end

--返还境界升阶消耗的灵力
function VipController:GetIsJingJieBack()
	return self:GetVipPowerValueByIndex(217)
end

--返还灵兽进阶的道具（最多累计300颗升阶道具，当前阶升阶成功后才可领取）
function VipController:GetIsLingshouBack()
	return self:GetVipPowerValueByIndex(202)
end

--装备强化灵力返还（升级消耗的10%）
function VipController:GetIsEquipBack()
	return self:GetVipPowerValueByIndex(204)
end

--坐骑升阶属性百分比加成 百分比
function VipController:GetMountLvUp(lv)
	return self:GetVipPowerPersentByIndex(self:GetIndexBySystemName(UIVipAttrTips.zq), lv)
end

--灵兽升阶属性百分比加成 百分比
function VipController:GetLingshouLvUp(lv)
	return self:GetVipPowerPersentByIndex(self:GetIndexBySystemName(UIVipAttrTips.ls), lv)
end

--神兵升阶属性百分比提升 百分比
function VipController:GetShengbingLvUp(lv)
	return self:GetVipPowerPersentByIndex(self:GetIndexBySystemName(UIVipAttrTips.sb), lv)
end

--境界升阶属性百分比提升 百分比
function VipController:GetJingjieLvUp(lv)
	return self:GetVipPowerPersentByIndex(self:GetIndexBySystemName(UIVipAttrTips.jj), lv)
end
--灵器升阶属性百分比提升 百分比
function VipController:GetLingQiLvUp(lv)
	return self:GetVipPowerPersentByIndex(self:GetIndexBySystemName(UIVipAttrTips.lq), lv)
end
--图鉴属性百分比
function VipController:GetFumoLvUp(lv)
	return self:GetVipPowerPersentByIndex(self:GetIndexBySystemName(UIVipAttrTips.tj), lv)
end

--星图属性百分比
function VipController:GetXingtuLvUp(lv)
	return self:GetVipPowerPersentByIndex(self:GetIndexBySystemName(UIVipAttrTips.xt), lv)
end
--天神属性百分比
function VipController:GetTianShenLvUp(lv)
	return self:GetVipPowerPersentByIndex(self:GetIndexBySystemName(UIVipAttrTips.ts), lv)
end

function VipController:GetIndexBySystemName(systemName)
	if systemName == UIVipAttrTips.sb then
		return 303
	elseif systemName == UIVipAttrTips.jj then
		return 220
	elseif systemName == UIVipAttrTips.ls then
		return 302
	elseif systemName == UIVipAttrTips.zq then
		return 301
	elseif systemName == UIVipAttrTips.lq then
		return 122
	elseif systemName == UIVipAttrTips.tj then
		return 219
	elseif systemName == UIVipAttrTips.xt then
		return 118
	elseif systemName == UIVipAttrTips.ts then
		return 119
	end
	return 0;
end

function VipController:ShowAttrTips(attMap, systemName,type)

	local isVip 	  = self:GetPowerByIndex(self:GetIndexBySystemName(systemName))
	local vipLevel    = self:GetVipLevel()
	local addition    = self:GetShowAddition(systemName)
	local tipsStr     = self:GetLevelUpTips(attMap, addition)
	local fight       = self:GetVipAdditionFight(type)
	UIVipAttrTips:Open( addition, tipsStr, fight, systemName, isVip )
end

function VipController:GetShowAddition(systemName)
	local add = 0
	if systemName == UIVipAttrTips.sb then
	 	add = self:GetShengbingLvUp()
	 	add = add > 0 and add or self:GetShengbingLvUp(0)
	elseif systemName == UIVipAttrTips.jj then
		add = self:GetJingjieLvUp()
		add = add > 0 and add or self:GetJingjieLvUp(0)
	elseif systemName == UIVipAttrTips.ls then
		add = self:GetLingshouLvUp()
		add = add > 0 and add or self:GetLingshouLvUp(VipConsts:GetMaxVipLevel())
	elseif systemName == UIVipAttrTips.zq then
		add = self:GetMountLvUp()
		add = add > 0 and add or self:GetMountLvUp(0)
	elseif systemName == UIVipAttrTips.lq then
		add = self:GetLingQiLvUp()
		add = add > 0 and add or self:GetLingQiLvUp(0)
	elseif systemName == UIVipAttrTips.tj then
		add = self:GetFumoLvUp()
		add = add > 0 and add or self:GetFumoLvUp(0)
	elseif systemName == UIVipAttrTips.xt then
		add = self:GetXingtuLvUp()
		add = add > 0 and add or self:GetXingtuLvUp(0)
	elseif systemName == UIVipAttrTips.ts then
		add = self:GetTianShenLvUp()
		add = add > 0 and add or self:GetTianShenLvUp(0)
		
	end
	return add
end


function VipController:GetVipAdditionFight(type)

    --白银战斗加成
    if type ==VipConsts.TYPE_SUPREME then 
        local fumoFightAddition			= PublicUtil.GetVipShowFight(FumoUtil:GetAllPro(), UIVipAttrTips.tj)
	    local xituFightAddition			= PublicUtil.GetVipShowFight(XingtuUtil:GetAllPro(), UIVipAttrTips.xt)
	    local tianshenFightAddition	    = PublicUtil.GetVipShowFight(NewTianshenUtil:GetAllPro(), UIVipAttrTips.ts)
	    return  fumoFightAddition + xituFightAddition  +tianshenFightAddition;
	--钻石战斗加成
    elseif type ==VipConsts.TYPE_DIAMOND then 
        local magicWeaponFightAddition 	= UIMagicWeapon:GetVIPFightAdd() -- 神兵
	    local lingQiFightAddition 		= UILingQi:GetVIPFightAdd() -- 灵器
	    local mountFightAddition       	= MountUtil:GetVIPFightAdd() -- 坐骑
	    local realmFightAddition		= UIRealmMainView:GetVIPFightAdd()--境界 
        return magicWeaponFightAddition + lingQiFightAddition + mountFightAddition + realmFightAddition
    end
end


function VipController:HideAttrTips()
	UIVipAttrTips:Hide()
end

-- 升阶属性加成的tips
-- {att=100, def=100, hp=100, hit=100, dodge=100, critical=100, defcri = 100}
-- 20
function VipController:GetLevelUpTips(attMap, addition)
	local upRate = addition;
--[[	local upRate = VipController:GetMountLvUp()
	if upRate <= 0 then
		upRate = VipController:GetMountLvUp(VipConsts:GetMaxVipLevel())
	end]]
	local str = ''
	if attMap then 
		for k,v in pairs (attMap) do
			local attName = tostring(v.proKey)
			local attrType = AttrParseUtil.AttMap[attName] or "missing"
			local showVal = _G.getAtrrShowVal( attrType, v.proValue * upRate / 100 )
			if type(showVal) == "number" then
				showVal = toint( showVal, 0.5 )
			end
			str = str .. self:GetAttName( attName, showVal ) ..'<br/>'
		end
	end
	return str
end

-- --升阶属性加成的tips
-- --{att=100, def=100, hp=100, hit=100, dodge=100, critical=100, defcri = 100}
-- --20
-- function VipController:GetLevelUpTips(attMap, upRate, nextRate)
-- 	if upRate < 0 then upRate = 0 end
	
-- 	local str = ''
-- 	str = str .. '<font size = "18" color = "#be8c44">'..StrConfig['vip11']..'</font>'..'<font size = "18" color = "#00ff00">'.. VipController:GetVipLevel() ..'</font><br/>'
-- 	str = str .. BaseTips:GetLine()
-- 	str = str .. '<font size = "14" color = "#c8c8c8">'..StrConfig['vip12']..'</font>'..'<font size = "14" color = "#c8c8c8">'..upRate..'%</font>' ..'<br/>'
-- 	if attMap then 
-- 		for k,v in pairs (attMap) do
-- 			local attName = tostring(v.proKey)
-- 			local attrType = AttrParseUtil.AttMap[attName] or "missing"
-- 			local attValueStr = _G.getAtrrShowVal( attrType, math.floor(v.proValue * upRate / 100) )
-- 			str = str .. self:GetAttName( attName, attValueStr ) ..'<br/>'
-- 		end
-- 	end
-- 	str = str .. BaseTips:GetLine()
-- 	str = str .. '<font size = "16" color = "#d2a930">'..StrConfig['vip13']..'</font>'..'<font size = "16" color = "#29cc00">'..nextRate ..'%</font><br/>'
-- 	str = str .. '<font size = "16" color = "#d2a930">'..StrConfig['vip14']..'</font>'
-- 	return str
-- end

-- function VipController:GetNoVipTips(attMap, upRate)
-- 	-- if not attMap then return "" end
-- 	if upRate < 0 then upRate = 0 end
-- 	local str = ''
-- 	str = str .. '<font size = "14" color = "#c8c8c8">'..StrConfig['vip15']..'</font>'..'<font size = "14" color = "#c8c8c8">'..upRate..'%</font>' ..'<br/>'
-- 	if attMap then
-- 		for k,v in pairs (attMap) do
-- 			local attName = tostring(v.proKey)
-- 			local attrType = AttrParseUtil.AttMap[attName] or "missing"
-- 			local attValueStr = _G.getAtrrShowVal( attrType, math.floor(v.proValue * upRate / 100) )
-- 			str = str .. self:GetAttName( attName, attValueStr ) ..'<br/>'
-- 		end	
-- 	end
-- 	str = str .. BaseTips:GetLine()
-- 	str = str .. '<font size = "16" color = "#d2a930">'..StrConfig['vip16']..'</font>'
	
-- 	return str
-- end

function VipController:GetAttrType(attName)
	
end

function VipController:GetAttName(attname, attValue)
	if attname == 'att' then
		return '<font size = "14" color = "#E59445">攻击:  </font>'..'<font size = "14" color = "#D5D0C2">'.. attValue ..'</font>'
	elseif attname == 'def' then
		return '<font size = "14" color = "#E59445">防御:  </font>'..'<font size = "14" color = "#D5D0C2">'.. attValue ..'</font>'
	elseif attname == 'hp' then
		return '<font size = "14" color = "#E59445">生命:  </font>'..'<font size = "14" color = "#D5D0C2">'.. attValue ..'</font>'
	elseif attname == 'hit' then
		return '<font size = "14" color = "#E59445">命中:  </font>'..'<font size = "14" color = "#D5D0C2">'.. attValue ..'</font>'
	elseif attname == 'dodge' then
		return '<font size = "14" color = "#E59445">闪避:  </font>'..'<font size = "14" color = "#D5D0C2">'.. attValue ..'</font>'
	elseif attname == 'critical' then
		return '<font size = "14" color = "#E59445">暴击:  </font>'..'<font size = "14" color = "#D5D0C2">'.. attValue ..'</font>'
	elseif attname == 'defcri' then
		return '<font size = "14" color = "#E59445">韧性:  </font>'..'<font size = "14" color = "#D5D0C2">'.. attValue ..'</font>'
	elseif attname == 'cri' then
		return '<font size = "14" color = "#E59445">暴击:  </font>'..'<font size = "14" color = "#D5D0C2">'.. attValue ..'</font>'
	elseif attname == 'crivalue' then
		return '<font size = "14" color = "#E59445">暴伤:  </font>'..'<font size = "14" color = "#D5D0C2">'.. attValue ..'</font>'
	elseif attname == 'speed' then
		return '<font size = "14" color = "#E59445">速度:  </font>'..'<font size = "14" color = "#D5D0C2">'.. attValue ..'</font>'
	end
	
	return ''
end

--获取vip剩余时间
function VipController:GetOpenLastTime(endTime)
	local now = GetServerTime()
	
	local day,hour,min = CTimeFormat:sec2formatEx(endTime - now)
	-- FPrint('获取vip剩余时间'..endTime..','..now..','..day)
	return day
end

--获取激活vip奖励
function VipController:GetActAward(vipType)
	local itemId = 0
	local cfg = t_viptype[vipType]
	if cfg then
		local dwProf = MainPlayerModel.humanDetailInfo.eaProf
		local list = split(cfg['reward'..dwProf],'#')
		local list1 = split(list[1],',')
		itemId = toint(list1[1])
	end
	
	return itemId
end

local MAX_VIP_TYPE = 3
-- vip类型是否开通
function VipController:GetVipTypeStateByFlag(vipflag, vipType)
	local temp = vipflag
	local bitIndex = 32 - MAX_VIP_TYPE
	bitIndex = bitIndex + vipType - 1
	
	bitIndex = bit.lshift(1,bitIndex)
	return bit.band(temp, bitIndex)	== bitIndex and 1 or 0
end
-- vip等级
function VipController:GetVipLevelByFlag(vipflag)
	local temp = vipflag
	temp = bit.lshift(temp,MAX_VIP_TYPE)
	temp = bit.rshift(temp,MAX_VIP_TYPE)
	return temp
end

-- 通过vip串取百分比的值
-- @串
-- @vip表里的index
function VipController:GetVipPowerPersentByIndexFlag(vipflag, index)
	local cfg = self:GetVipCfgByIndex(index)
	if not cfg then
		FPrint('找不到vip配置文件index' .. index)
		return 0 
	end

	if self:GetPowerByFlag(vipflag, cfg.id) == 0 then
		FPrint('self:GetPowerByFlag' .. index)
		return 0
	end
	
	local vipLevel = self:GetVipLevelByFlag(vipflag)
	if vipLevel <= 0 then 
		FPrint('vipLevel <= 0' .. index)
		return 0 
	end
	
	if not cfg['c_v'..vipLevel] then return 0 end
	return cfg['c_v'..vipLevel]/100 or 0
end

function VipController:GetPowerByFlag(vipflag, vipId)
	local vipCfg = t_vippower[vipId]
	if not vipCfg then return false end
	if not vipCfg.type then return false end	
	
	return self:GetVipTypeStateByFlag(vipflag, vipCfg.type)
end

--根据int获得vip的图标
function VipController:GetSelfVipIcon(vipflag)
	local vipLevel = self:GetVipLevelByFlag(vipflag)
	if self:GetVipTypeStateByFlag(vipflag, VipConsts.TYPE_DIAMOND) == 1 then-- 是否钻石
		return self:GetVipIcon(3, vipLevel)
	elseif self:GetVipTypeStateByFlag(vipflag, VipConsts.TYPE_GOLD) == 1 then--是否黄金
		return self:GetVipIcon(2, vipLevel)
	elseif self:GetVipTypeStateByFlag(vipflag, VipConsts.TYPE_SUPREME) == 1 then--是否白银
		return self:GetVipIcon(1, vipLevel)
	end
	return self:GetVipIcon(0, vipLevel)
end

--根据vip信息获得vip的图标
function VipController:GetVipIcon(vipType, vipLevel)
	if vipLevel <= 0 then
		return ""
	end
	return ResUtil:GetVipIconUrl(vipType, vipLevel)
end

function VipController:BagExtraNumTips(index,vipUseNum)
	local cfg = VipController:GetVipCfgByIndex(index)
	if not cfg then
		--FPrint('找不到vip配置文件index' .. index)
		return "" 
	end
	
	local vipLevel = VipController:GetVipLevel() 
	-- if vipLevel <= 0 then vipLevel = 1 end			
	if not cfg['c_v'..vipLevel] then return '' end
	local num = cfg['c_v'..vipLevel] or 0
	
	local vipName = VipController:GetVipNameByIndex(index)
	return  '成为'..vipName..'vip额外使用次数：<font color="#65c47e">'..num..'</font>'
end








