--[[
LingLiHuiZhangUtil
zhangshuhui
2015年5月13日11:09:16
]]

_G.LingLiHuiZhangUtil = {};

--得到当前等阶单次增加的属性list
function LingLiHuiZhangUtil:GetSingleAttrList()
	local list = {};
	local cfg = t_huizhang[LingLiHuiZhangModel:GetHuiZhangOrder()];
	if cfg then
		for _, type in pairs( LingLiHuiZhangConsts.Attrs ) do
			local vo = {};
			vo.type = AttrParseUtil.AttMap[type];
			vo.val = cfg[type];
			
			if vo.val and vo.val > 0 then
				table.push(list,vo);
			end
		end
	end
	
	return list;
end

--属性值是否满了
function LingLiHuiZhangUtil:GetIsAttrFull()
	local cfg = t_huizhang[LingLiHuiZhangModel:GetHuiZhangOrder()];
	if cfg then
		for _, type in pairs( LingLiHuiZhangConsts.Attrs ) do
			if cfg[type.."max"] > 0 then
				if LingLiHuiZhangUtil:GetAttrVal(type) < cfg[type.."max"] then
					return false;
				end
			end
		end
		
		return true;
	end
	
	return false;
end

--得到某一个属性的当前值
function LingLiHuiZhangUtil:GetAttrVal(type)
	for i, vo in pairs( LingLiHuiZhangModel:GetAttrList() ) do
		if AttrParseUtil.AttMap[type] == vo.type then
			return vo.val;
		end
	end
	
	return 0;
end

--是否达到突破的条件  道具是否满足
function LingLiHuiZhangUtil:GetIsCanUp()
	local cfg = t_huizhang[LingLiHuiZhangModel:GetHuiZhangOrder()];
	if cfg then
		local list = RewardManager:ParseToVO(cfg.items);
		
		local playerinfo = MainPlayerModel.humanDetailInfo;
		for i, vo in pairs(list) do
			--是否背包里都有道具
			if vo.id == enAttrType.eaZhenQi then
				if playerinfo.eaZhenQi < vo.count then
					return false;
				end
			else
				local intemNum = BagModel:GetItemNumInBag(vo.id);
				if intemNum < vo.count then
					return false;
				end
			end
		end
		
		return true;
	end
	
	return false;
end

--获得上一阶的最大属性
function LingLiHuiZhangUtil:GetAttrMax(type)
	local cfg = t_huizhang[LingLiHuiZhangModel:GetHuiZhangOrder() - 1];
	if cfg then
		if type == enAttrType.eaGongJi then
			return cfg.attmax;
		elseif type == enAttrType.eaFangYu then
			return cfg.defmax;
		elseif type == enAttrType.eaMaxHp then
			return cfg.hpmax;
		elseif type == enAttrType.eaBaoJi then
			return cfg.crimax;
		elseif type == enAttrType.eaRenXing then
			return cfg.defcrimax;
		elseif type == enAttrType.eaMingZhong then
			return cfg.hitmax;
		elseif type == enAttrType.eaShanBi then
			return cfg.dodgemax;
		end
	end
	
	return 0;
end

--当前VIP免费领取的总次数
function LingLiHuiZhangUtil:GetAllFreeNum()
	-- local playerinfo = MainPlayerModel.humanDetailInfo;
	-- local cfg = VipController:GetJulingwanFreeNum()	
	-- local vipvo = t_vip[playerinfo.eaVIPLevel];
	-- if vipvo then
		-- return cfg['c_v'..playerinfo.eaVIPLevel]
	-- end
	
	return VipController:GetJulingwanFreeNum()
end

-- 获取战斗力
function LingLiHuiZhangUtil:GetFight()
	local list = LingLiHuiZhangModel:GetAttrList();
	return EquipUtil:GetFight( list );
end

-- 当前聚灵是否超过10%
function LingLiHuiZhangUtil:GetIsOverpercent()
	local huizhangcfg = t_huizhang[LingLiHuiZhangModel:GetHuiZhangOrder()];
	if huizhangcfg then
		local playerinfo = MainPlayerModel.humanDetailInfo;
		local zhenqimax = huizhangcfg.zhenqimax;
		
		if playerinfo and playerinfo.eaVIPLevel then
			if playerinfo.eaVIPLevel > 0 then
				zhenqimax = zhenqimax * (100 + VipController:GetJulingwanShangxianZengjia()) / 100;
			end
		end
		
		if LingLiHuiZhangModel:GetJuLingCount() >= zhenqimax * 0.015 then
			return true;
		end
	end
	
	return false;
end

-- 当前聚灵是否已满
function LingLiHuiZhangUtil:GetIsFull()
	local huizhangcfg = t_huizhang[LingLiHuiZhangModel:GetHuiZhangOrder()];
	if huizhangcfg then
		local playerinfo = MainPlayerModel.humanDetailInfo;
		local zhenqimax = huizhangcfg.zhenqimax;
		
		if playerinfo and playerinfo.eaVIPLevel then
			if playerinfo.eaVIPLevel > 0 then
				zhenqimax = zhenqimax * (100 + VipController:GetJulingwanShangxianZengjia()) / 100;
			end
		end
		
		if LingLiHuiZhangModel:GetJuLingCount() >= zhenqimax then
			return true;
		end
	end
	
	return false;
end