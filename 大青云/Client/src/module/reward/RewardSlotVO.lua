--[[
奖励格子VO(显示VO)
lizhuangzhuang
2014年8月26日18:16:013
]]

_G.RewardSlotVO = {}

RewardSlotVO.id = 0;--物品id
RewardSlotVO.count = 0;--物品数量
RewardSlotVO.bind = BagConsts.Bind_None;--绑定状态
RewardSlotVO.isBlack = false;--是否是黑的

function RewardSlotVO:new()
	local obj = {};
	for k,v in pairs(RewardSlotVO) do
		obj[k] = v;
	end
	return obj;
end

--显示数量
function RewardSlotVO:GetShowCount()
	if self.count<=1 then
		return "";
	end
	if self.count < 10000 then
		return self.count;
	elseif self.count < 100000000 then
		return toint(self.count/10000,-1).."万";
	else
		return toint(self.count/100000000,-1).."亿";
	end
end

--获取是否显示绑定图标
function RewardSlotVO:GetShowBind()
	if self.id < 999 then
		return false;
	end
	if self.bind==BagConsts.Bind_GetBind or self.bind==BagConsts.Bind_Bind then
		return true;
	end
	return false;
end

--获取图标
function RewardSlotVO:GetIcon(size)
	if t_equip[self.id] then
		if self.isBlack then
			return ImgUtil:GetGrayImgUrl(ResUtil:GetItemIconUrl(t_equip[self.id].icon,size));
		end
		return ResUtil:GetItemIconUrl(t_equip[self.id].icon,size);
	elseif t_item[self.id] then
		if self.isBlack then
			return ImgUtil:GetGrayImgUrl(ResUtil:GetItemIconUrl(t_item[self.id].icon,size));
		end
		return ResUtil:GetItemIconUrl(t_item[self.id].icon,size);
	end
	return "";
end

--获取品质
function RewardSlotVO:GetQualityUrl(isSmall,is64)
	local quality = self:GetQuality()
	local size = is64 and 64 or (not isSmall and 54 or nil)
	return ResUtil:GetSlotQuality(quality,size);
end

--获取品质
function RewardSlotVO:GetQuality()
	if t_equip[self.id] then
		return t_equip[self.id].quality;
	end
	local cfg = t_item[self.id]
	if cfg then
		if cfg.sub == BagConsts.SubT_Tianshenka then
			return NewTianshenUtil:GetShowQuality(NewTianshenUtil:GetTianshenCardZizhi(self.id))
		end
		return cfg.quality;
	end
	return 0;
end

--装备卓越星级
function RewardSlotVO:GetSuper()
	local cfg = t_equip[self.id];
	if cfg then
		if cfg.pos > 10 then
			return 0;
		end
		if cfg.quality == BagConsts.Quality_Green1 then
			return 1;
		elseif cfg.quality == BagConsts.Quality_Green2 then
			return 2;
		elseif cfg.quality == BagConsts.Quality_Green3 then
			return 3;
		end
	end
	return 0;
end

--强化星级
function RewardSlotVO:GetStrenLvl()
	local cfg = t_equip[self.id];
	if cfg then
		return cfg.star;
	end
	return 0;
end

--获取编码后的UI数据
function RewardSlotVO:GetUIData()
	local data = {};
	data.id = self.id;
	data.count = self.count;
	data.showCount = self:GetShowCount();
	data.iconUrl = self:GetIcon();
	data.bigIconUrl = self:GetIcon("54");
	data.iconUrl64 = self:GetIcon("64");
	data.bind = self.bind;
	data.showBind = self:GetShowBind();
	data.qualityUrl = self:GetQualityUrl(true);
	data.bigQualityUrl = self:GetQualityUrl();
	data.qualityUrl64 = self:GetQualityUrl(false,true);
	data.quality = self:GetQuality();
	data.isBlack = self.isBlack and true or false;
	data.super = self:GetSuper();
	data.strenLvl = self:GetStrenLvl();
	data.biaoshiUrl = self:GetBiaoshi();
	data.bigBiaoshiUrl = self:GetBiaoshi("54");
	data.biaoshiUrl64 = self:GetBiaoshi("64");
	return UIData.encode(data);
end

--标识路径
function RewardSlotVO:GetBiaoshi(size)
	return BagUtil:GetItemBiaoShiUrl(self.id, size)
end

--获取tips信息
function RewardSlotVO:GetTipsInfo()
	local tipsInfo = {};
	tipsInfo.tipsShowType = TipsConsts.ShowType_Normal;
	--基础物品
	if self.id < 999 then
		tipsInfo.itemID = self.id
		tipsInfo.tipsType = TipsConsts.Type_Normal;
		if self.id == enAttrType.eaExp then
			tipsInfo.info = StrConfig['tips100'];
		elseif self.id == enAttrType.eaBindGold then
			tipsInfo.info = StrConfig['tips101'];
		elseif self.id == enAttrType.eaUnBindGold then
			tipsInfo.info = StrConfig['tips102'];
		elseif self.id == enAttrType.eaUnBindMoney then
			tipsInfo.info = StrConfig['tips103'];
		elseif self.id == enAttrType.eaBindMoney then
			tipsInfo.info = StrConfig['tips104'];
		elseif self.id == enAttrType.eaZhenQi then
			tipsInfo.info = StrConfig['tips105'];
		-- elseif self.id == enAttrType.eaRealmExp then
		-- 	tipsInfo.info = StrConfig['tips109'];
		elseif self.id == enAttrType.eaHonor then  -- 荣誉
			tipsInfo.info = StrConfig['tips106'];
		elseif self.id == 64 then  -- 家园弟子经验
			tipsInfo.info = StrConfig['tips110'];
		elseif self.id == 80 then  -- 帮贡
			tipsInfo.info = StrConfig['tips107'];
		elseif self.id == 81 then --帮派忠诚度
			tipsInfo.info = StrConfig['tips112'];	
		elseif self.id == 102 then  -- 帮派活跃度
			tipsInfo.info = StrConfig['tips108'];
		elseif self.id == enAttrType.eaLingZhi then --灵值
			tipsInfo.info = StrConfig['tips111'];
		elseif self.id == 62 then --功勋
			tipsInfo.info = StrConfig['tips113'];
		elseif self.id == 59 then --积分
			tipsInfo.info = StrConfig['tips114'];
		elseif self.id == enAttrType.eaTianShen then
			tipsInfo.info = StrConfig['tips115'];
		else
			tipsInfo.info = "";
		end
		tipsInfo.info = string.format(tipsInfo.info,self.count);
		return tipsInfo;
	end
	--装备物品
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(self.id,self.count,self.bind);
	if not itemTipsVO then return; end
	tipsInfo.tipsShowType = itemTipsVO.tipsShowType;
	tipsInfo.tipsType = itemTipsVO.tipsType;
	tipsInfo.info = itemTipsVO;
	return tipsInfo;
end