--[[
	新天神
]]

_G.UINewTianshenStarUp = BaseUI:new('UINewTianshenStarUp');

UINewTianshenStarUp.nMaxCount = 10 --一次最多吞噬8个
UINewTianshenStarUp.selectList = {}
function UINewTianshenStarUp:Create()
	self:AddSWF('newTianShenStarUp.swf',true,nil);
end

function UINewTianshenStarUp:OnLoaded(objSwf)
	objSwf.btnClose.click = function()
		self:Hide()
	end
	objSwf.list.itemClick = function(e)
		self:BagListClick(e)
	end
	objSwf.list1.itemClick = function(e)
		self:SelectListClick(e)
	end
	objSwf.aotoBtn.click = function()
		self:AotoSelectTianshenCard()
	end
	objSwf.lvBtn.click = function()
		self:AskStarUp()
	end

	objSwf.list.itemRollOver = function(e) self:OnBagEquipOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	objSwf.list1.itemRollOver = function(e) self:OnBagEquipOver(e); end
	objSwf.list1.itemRollOut = function(e) TipsManager:Hide(); end

	objSwf.btnRules.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["newtianshen204"],TipsConsts.Dir_RightDown); end
	objSwf.btnRules.rollOut = function(e) TipsManager:Hide(); end
end

function UINewTianshenStarUp:OnShow()
	if not self.args or not self.args[1] then
		self:Hide()
		return
	end
	
	self.selectIndex = self.args[1]
	self.objSwf.txt_des.htmlText = string.format(StrConfig['newtianshen35'], self:GetQualityStr())
	self:ShowTianshenInfo()
	self:ShowBagList()
	self:ShowSelectList()
	self:SetBtnPfx()
end

function UINewTianshenStarUp:GetQualityStr()
	local tianshen = NewTianshenModel:GetTianshenByFightSize(self.selectIndex)
	local needQuality = tianshen:GetStarNeedQuality()
	local count = 0
	local str = ""
	for i = 0, 4 do
		if needQuality[i] then
			count = count + 1
			if count > 1 then
				str = str .. "、"
			end
			str = str .. StrConfig['newtianshen' .. (30 + i)]
		end
	end
	return str
end

function UINewTianshenStarUp:OnBagEquipOver(e)
	if not e.item then return end
	
	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local item = bag:GetItemByPos(e.item.pos);
	if item then
		TipsManager:ShowBagTips(BagConsts.BagType_Tianshen,item.pos);
	end
end

--判断是否选中吞噬的天神
function UINewTianshenStarUp:CheckIsSelectCard(id)
	return self.selectList[id]
end

--获取选中天神的数量
function UINewTianshenStarUp:GetSelectNum()
	local num = 0
	for k, v in pairs(self.selectList) do
		num = num + 1
	end
	return num
end

function UINewTianshenStarUp:ShowBagList()
	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local cards = bag:GetItemListByShowType(BagConsts.ShowType_All);
	local cardsList = {}

	for index,item in pairs(cards) do
		if not self:CheckIsSelectCard(item:GetId()) then
			table.push(cardsList,UIData.encode(self:GetSlotVO(item,index)));
		end
	end
	self.objSwf.list.dataProvider:cleanUp();
	self.objSwf.list.dataProvider:push(unpack(cardsList));
	self.objSwf.list:invalidateData();
end

--获取格子VO
function UINewTianshenStarUp:GetSlotVO(item,index)
	local vo = {};
	vo.hasItem = true;
	vo.myindex = index;
	vo.pos = item:GetPos();
	EquipUtil:GetDataToItemUIVO(vo,item);
	return vo;
end

function UINewTianshenStarUp:ShowTianshenInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	local tianshen = NewTianshenModel:GetTianshenByFightSize(self.selectIndex)
	if not tianshen then
		self:Hide()
		return
	end

	local UI = objSwf.fight0
	NewTianshenUtil:SetTianshenSlot(UI, tianshen)

	UI.itemBtn.rollOver = function(e)
		TipsManager:ShowNewTianshenTips(tianshen)
	end
	UI.itemBtn.rollOut = function(e)
		TipsManager:Hide()
	end

	objSwf.fightLoader = tianshen:GetFightValue()
	for i = 1, 10 do
		if tianshen:GetMaxStar() < i then
			objSwf.star["graystar" ..i]._visible = false
			objSwf.star["star" ..i]._visible = false
		else
			if tianshen:GetStar() >= i then
				objSwf.star["graystar" ..i]._visible = false
				objSwf.star["star" ..i]._visible = true
			else
				objSwf.star["graystar" ..i]._visible = true
				objSwf.star["star" ..i]._visible = false
			end
		end
	end
	objSwf.txt_curStar.text = tianshen:GetStar() .."星"
	objSwf.txt_curfight.text = tianshen:GetFightValue()
	local slot = {}
	local slot1 = {}
	for i=1, 7 do
		table.insert(slot, objSwf['txt_pro' ..i])
		table.insert(slot1, objSwf['txt_pro' ..(i+10)])
	end
	PublicUtil:ShowProInfoForUI(tianshen:GetPro(), slot, nil, nil, nil, true,nil,"#FFFFFF")
	if tianshen:IsMaxStar() then
		for i = 1, 7 do
			objSwf['txt_pro' .. (i+10)].htmlText = "<font color='#00ff00'>已到达上限</font>"
		end
		objSwf.txt_nextStar.htmlText = "<font color='#00ff00'>已到达上限</font>"
		objSwf.txt_nextfight.htmlText = "<font color='#00ff00'>已到达上限</font>"
		objSwf.txt_success.htmlText = ""
		objSwf.txt_suc._visible = false
	else
		PublicUtil:ShowProInfoForUI(tianshen:GetNextStarPro(), slot1, nil, nil, nil, true,nil,"#FFFFFF")
		objSwf.txt_nextStar.text = (tianshen:GetStar() + 1) .. "星"
		objSwf.txt_nextfight.text = tianshen:GetNextStarFight()
		objSwf.txt_success.text = tianshen:GetSuccess()

		objSwf.txt_suc._visible = true
	end
end

function UINewTianshenStarUp:ShowSelectList()
	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local cards = bag:GetItemListByShowType(BagConsts.ShowType_All);
	local cardsList = {}

	for index,item in pairs(cards) do
		if self:CheckIsSelectCard(item:GetId()) then
			table.push(cardsList,UIData.encode(self:GetSlotVO(item,index)));
		end
	end
	if #cardsList < self.nMaxCount then
		for i = #cardsList, self.nMaxCount do
			local vo = {}
			vo.hasItem = false
			table.push(cardsList,UIData.encode(vo));
		end
	end
	self.objSwf.list1.dataProvider:cleanUp();
	self.objSwf.list1.dataProvider:push(unpack(cardsList));
	self.objSwf.list1:invalidateData();
end

function UINewTianshenStarUp:AotoSelectTianshenCard()
	local tianshen = NewTianshenModel:GetTianshenByFightSize(self.selectIndex)
	local needQuality = tianshen:GetStarNeedQuality()
	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local cards = bag:GetItemListByShowType(BagConsts.ShowType_All);
	local cardsList = {}

	for index,item in pairs(cards) do
		local quality
		if NewTianshenUtil:IsExpCard(item:GetTid()) then
			quality = t_item[item:GetTid()].quality
			if quality == 5 then
				quality = 3
			end
		else
			quality = NewTianshenUtil:GetQualityByZizhi(item:GetParam())
		end
		if needQuality[quality] and self:GetSelectNum() < self.nMaxCount then
			if not self:CheckIsSelectCard(item:GetId()) then
				self.selectList[item:GetId()] = 1
			end
		end
	end
	self:ShowSelectList()
	self:ShowBagList()
	self:SetBtnPfx()
end

function UINewTianshenStarUp:BagListClick(e)
	if not e.item then return end

	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local item = bag:GetItemByPos(e.item.pos);
	if not item then
		return
	end
	local tianshen = NewTianshenModel:GetTianshenByFightSize(self.selectIndex)
	local needQuality = tianshen:GetStarNeedQuality()
	if NewTianshenUtil:IsExpCard(item:GetTid()) then
		local quality = t_item[item:GetTid()].quality
		if quality == 5 then
			quality = 3
		end
		if not needQuality[quality] then
			FloatManager:AddNormal(string.format(StrConfig['newtianshen108'], self:GetQualityStr()))
			return
		end
	elseif not needQuality[NewTianshenUtil:GetQualityByZizhi(item:GetParam())] then
		FloatManager:AddNormal(string.format(StrConfig['newtianshen108'], self:GetQualityStr()))
		return
	end
	if self:GetSelectNum() >= self.nMaxCount then
		--满了
		FloatManager:AddNormal(StrConfig['newtianshen105'])
		return
	end
	if not self:CheckIsSelectCard(item:GetId()) then
		self.selectList[item:GetId()] = 1
	end
	self:ShowBagList()
	self:ShowSelectList()
	self:SetBtnPfx()
end

function UINewTianshenStarUp:SelectListClick(e)
	if not e.item then return end

	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local item = bag:GetItemByPos(e.item.pos);
	if not item then
		return
	end

	if not self:CheckIsSelectCard(item:GetId()) then
		return
	end
	self.selectList[item:GetId()] = nil
	self:ShowBagList()
	self:ShowSelectList()
	self:SetBtnPfx()
end

function UINewTianshenStarUp:AskStarUp()
	if self:GetSelectNum() < 10 then
		--必须要10个
		FloatManager:AddNormal(StrConfig['newtianshen106'])
		return
	end
	local starlist = {}
	for k, v in pairs(self.selectList) do
		table.insert(starlist, {id = k})
	end

	local tianshen = NewTianshenModel:GetTianshenByFightSize(self.selectIndex)
	if tianshen:IsMaxStar() then
		FloatManager:AddNormal(StrConfig['newtianshen116'])
		return
	end
	NewTianshenController:AskStarUp(tianshen:GetId(), starlist)
end

function UINewTianshenStarUp:OnHide()
	self.selectList = {}
end

function UINewTianshenStarUp:SetBtnPfx()
	local objSwf = self.objSwf
	if not objSwf then return end
	local tianshen = NewTianshenModel:GetTianshenByFightSize(self.selectIndex)
	objSwf.aotoBtn.pfx._visible = NewTianshenUtil:IsCanStarUpBySize(tianshen:GetPos()) and (self:GetSelectNum() ~= 10)
	objSwf.lvBtn.pfx._visible = (not tianshen:IsMaxStar()) and (self:GetSelectNum() == 10)
end

function UINewTianshenStarUp:ListNotificationInterests()
	return {NotifyConsts.tianShenStarUpUpdata,NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagUpdate,}
end

function UINewTianshenStarUp:HandleNotification(name,body)
	if name == NotifyConsts.tianShenStarUpUpdata then
		if body[1] == 0 then
			if self.objSwf then
				self.objSwf.starpfx:gotoAndPlay(2)
			end
		else
			if self.objSwf then
				self.objSwf.starpfx1:gotoAndPlay(2)
			end
		end
		self.selectList = {}
		self:ShowTianshenInfo()
		self:ShowBagList()
		self:ShowSelectList()
	else
		self:ShowBagList()
	end
	self:SetBtnPfx()
end