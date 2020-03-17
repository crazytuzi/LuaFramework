-- 帮派资源管理器
_G.UnionResController = {}

function UnionResController:New(objSwf, isShowMoney, isUnionRes)
	local resController = {}
	setmetatable(resController, {__index = UnionResController})
	
	resController.ResItems = {}
	resController.objSwf = objSwf
	resController.isShowMoney = isShowMoney
	resController.GetItemNeedNum = nil
	resController.GetMoneyNeedNum = nil
	resController.isUnionRes = isUnionRes
	
	resController.OnResItemOver = function(resItemId,btn)
		if not resItemId then return; end
		
		TipsManager:ShowItemTips(resItemId)
	end
	
	resController.OnResItemOut = function()
		TipsManager:Hide();
	end
	
	resController.ResItems[UnionConsts.QingtongTokenId] 	= { objSwf.resItem1 };
	resController.ResItems[UnionConsts.BaiyingTokenId] 		= { objSwf.resItem2 };
	resController.ResItems[UnionConsts.HuangjinTokenId] 	= { objSwf.resItem3 };
	if isShowMoney then
		resController.ResItems[UnionConsts.MoneyId] 		= { objSwf.resItem4 };
	end
	
	for resItemId, btns in pairs( resController.ResItems ) do
		for j, btn in ipairs( btns ) do
			btn.rollOver = function() resController.OnResItemOver(resItemId, btn); end
			btn.rollOut  = function() resController.OnResItemOut();  end
		end
	end
	
	return resController
end

-- 更新帮派资源
function UnionResController:UpdateUnionResList()
	local objSwf = self.objSwf
	if not objSwf then return; end

	-- 帮派资源列表
	local moneyNum = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
	
	local resList = UnionModel.MyUnionInfo.GuildResList
	objSwf.tileListResNum.dataProvider:cleanUp() 
	objSwf.tileListRes.dataProvider:cleanUp() 
	local uRes = {}
	for j, unionRes in pairs(resList) do
		local slotVO = RewardSlotVO:new();
		slotVO.id = unionRes.itemId;
		slotVO.count = 0;
		uRes = {}
		if self.isUnionRes then 
			uRes.count = unionRes.count
		else
			uRes.count = BagModel:GetItemNumInBag(unionRes.itemId)
		end
		uRes.intCount = uRes.count
		uRes.itemId = unionRes.itemId
		if self.GetItemNeedNum then
			uRes.needNum = UnionUtils:GetResLevelUpNeedNum(UnionModel.MyUnionInfo.level, unionRes.itemId)
			uRes.intneedNum = uRes.needNum
		end
		objSwf.tileListResNum.dataProvider:push( UIData.encode(uRes) )
		objSwf.tileListRes.dataProvider:push( slotVO:GetUIData() )
	end
	
	if self.isShowMoney then
		uRes = {}
		if self.isUnionRes then 
			local needMoney = UnionUtils:GetUnionLevelUpNeedMoney(UnionModel.MyUnionInfo.level)
			-- FPrint(UnionModel.MyUnionInfo.captial..needMoney)
			uRes.count = self:GetMoneyNumFormat(UnionModel.MyUnionInfo.captial)
			uRes.needNum = self:GetMoneyNumFormat(needMoney)
			
			uRes.intCount = UnionModel.MyUnionInfo.captial
			uRes.intneedNum = needMoney
		else
			uRes.count = self:GetMoneyNumFormat(moneyNum)
			uRes.intCount = moneyNum
			if self.GetMoneyNeedNum then
				uRes.needNum = self.GetMoneyNeedNum()
				uRes.intneedNum = self.GetMoneyNeedNum()
			end
		end
		
		objSwf.tileListResNum.dataProvider:push( UIData.encode(uRes) )
		
		local slotVO = RewardSlotVO:new();
		slotVO.id = UnionConsts.MoneyId
		slotVO.count = 0;
		objSwf.tileListRes.dataProvider:push( slotVO:GetUIData() )
	end
	objSwf.tileListResNum:invalidateData()
	objSwf.tileListRes:invalidateData()
end

function UnionResController:GetUnionResListStr()
	-- 帮派资源列表
	local moneyNum = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
	
	local resList = UnionModel.MyUnionInfo.GuildResList	
	local itemStr = ""
	for j, unionRes in pairs(resList) do
		local itemName = ""
		if t_item[unionRes.itemId] then
			itemName = t_item[unionRes.itemId].name
		elseif t_equip[unionRes.itemId] then
			itemName = t_equip[unionRes.itemId].name
		end
		
		local count = unionRes.count
		local needNum = UnionUtils:GetResLevelUpNeedNum(UnionModel.MyUnionInfo.level, unionRes.itemId)
		
		local colorStr = '<font color="#00ff00">（'..StrConfig['union48']..'）</font>'
		if count < needNum then
			colorStr = '<font color="#ff0000">（'..StrConfig['union49']..'）</font>'
		end
		
		itemStr = itemStr..'<br/><font color="#e59607">'..itemName..'：</font>'..count..'/'..needNum..colorStr
	end
	
	local itemName = ""
	if t_item[UnionConsts.MoneyId] then
		itemName = t_item[UnionConsts.MoneyId].name
	elseif t_equip[UnionConsts.MoneyId] then
		itemName = t_equip[UnionConsts.MoneyId].name
	end
		
	local count = UnionModel.MyUnionInfo.captial
	local needMoney = UnionUtils:GetUnionLevelUpNeedMoney(UnionModel.MyUnionInfo.level)
	
	local colorStr = '<font color="#00ff00">（'..StrConfig['union48']..'）</font>'
	if count < needMoney then
		colorStr = '<font color="#ff0000">（'..StrConfig['union49']..'）</font>'
	end
	
	itemStr = itemStr..'<br/><font color="#e59607">'..itemName..'：</font>'..count..'/'..needMoney..colorStr
	return itemStr
end

function UnionResController:GetMoneyNumFormat(value)
	if value >= 10000 then
		if value >= 100000000 then
			value = toint(value/100000000)
			return string.format(StrConfig['union44'],value)
		end
		
		value = toint(value/10000)
		return string.format(StrConfig['union43'],value)
	end
	
	return value
end

function UnionResController:OnDelete()
	for k,v in pairs (self.ResItems) do
		self.ResItems[k] = nil
	end
	self.objSwf = nil
end
