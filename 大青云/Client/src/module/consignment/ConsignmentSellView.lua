--[[
寄售行 卖
wangshuaui
]]
_G.UIConsignmentSell = BaseUI:new("UIConsignmentSell")


UIConsignmentSell.curItemindex = 1;
UIConsignmentSell.curPage = 0;
UIConsignmentSell.curList = {};


function UIConsignmentSell:Create()
	self:AddSWF("consignmentSellPanel.swf",true,nil)
end;

function UIConsignmentSell:GetPanelType()
	return 0;
end

function UIConsignmentSell:OnLoaded(objSwf)

	objSwf.selllist.iconRollOut = function()  TipsManager:Hide() end;
	objSwf.selllist.iconRollOver = function(e) self:OnSetOverTipsData(e)end; 
	objSwf.selllist.DownitemClick = function(e) self:OnItemDownClick(e)end; 

	--objSwf.itemUp.click = function() self:OnItemUpClick()end;
	objSwf.itemDown.click = function() self:OnItemAllDownClick()end;
	--objSwf.itemUp.htmlLabel = StrConfig['consignment015']
	-- 翻页组件
	objSwf.btnPre1.click = function() self:PagePre1()end; -- 前
	objSwf.btnNext1.click = function() self:PageNext1()end; -- 后
	objSwf.btnPre.click = function() self:PagePre()end; -- 上一个
	objSwf.btnNext.click = function() self:PageNext()end; -- 下一个

	--bagclick
	objSwf.baglist.itemClick = function(e) self:BagItemClick(e)end;
	objSwf.baglist.itemRollOver = function(e) self:BagItemOver(e)end;
	objSwf.baglist.itemRollOut = function(e) TipsManager:Hide() end;

end;

function UIConsignmentSell:OnShow()
	-- 请求我的信息
	self.curPage = 0;
	ConsignmentController:ResqMyItemInfo()
	self:ShowItemList();
	self:SetCurrencyNum();
	self:ShowBagList();
end;
 
function UIConsignmentSell:OnHide()
	self.curPage = 0;
	ConsignmentConsts.IsAtUpitemIng = false;
	-- if UIBag:IsShow() then 
	-- 	 UIBag:SetConsignmentUpItem()
	-- end;
	if self.erjiPanleId then 
		UIConfirm:Close(self.erjiPanleId)
	end;
end;

function UIConsignmentSell:BagItemClick(e)
	if not e.item then return end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return end;
	local item = bagVO:GetItemByPos(e.item.pos);
	if not item then return end
	ConsignmentController:SetUpItemBagClick(item);
end;

function UIConsignmentSell:BagItemOver(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Bag,pos);
	if not itemTipsVO then return end;
	if not itemTipsVO.id or itemTipsVO.id == 0 then 
		--print("ERROR: cur item at bag is nil,"..pos.."     ",debug.traceback())
		return 
	end;
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end;

function UIConsignmentSell:ShowBagList()
	local objSwf = self.objSwf;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local list = {};
	self.BagListVo = {};
	self.BagListVo = bagVO:GetItemListByShowType(BagConsts.ShowType_All)
	for cao,info in pairs(self.BagListVo) do 
		if info:GetBindState() ~= BagConsts.Bind_Bind then 
			table.push(list,UIData.encode(ConsignmentUtils:GetSlotVO(info,nil,cao)));
		end;
	end;
	objSwf.baglist.dataProvider:cleanUp();
	objSwf.baglist.dataProvider:push(unpack(list));
	objSwf.baglist:invalidateData();
end;

--获取格子VO
function UIConsignmentSell:GetSlotVO(item,isBig,index)
	local vo = {};
	vo.hasItem = true;
	vo.myindex = index;
	vo.pos = item:GetPos();
	vo.isBig = isBig and true or false;
	if t_equip[item:GetTid()] then 
		EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	elseif t_item[item:GetTid()] then 
		vo.qualityUrl = ResUtil:GetSlotQuality(t_item[item:GetTid()].quality);
		vo.quality = t_item[item:GetTid()].quality;
		vo.count = item:GetCount();
		vo.iconUrl = BagUtil:GetItemIcon(item:GetTid());
	end;
	return vo;
end

--  set 货币数量
function UIConsignmentSell:SetCurrencyNum()
	local objSwf = self.objSwf;
	local myYuanbao = MainPlayerModel.humanDetailInfo.eaUnBindMoney
	local myGold = MainPlayerModel.humanDetailInfo.eaUnBindGold
	objSwf.yuanbao.text = myYuanbao
	-- objSwf.gold.text = myGold

	local canNum = ConsignmentModel:GetUpItemSellNum()
	objSwf.canSellnum.text = canNum;
end;


function UIConsignmentSell:OnItemAllDownClick()
	local okfun = function () 
			ConsignmentController:ResqItemOutShelves(0,0) 
			self.curPage = 0;
		end;
	self.erjiPanleId = UIConfirm:Open(StrConfig["consignment003"],okfun);
end;		

function UIConsignmentSell:ShowItemList()
	local objSwf = self.objSwf;
	self.curList = ConsignmentModel:GetMySellItemAllInfo();

	local curTotal = ConsignmentUtils:GetListLenght(self.curList)+1;
	if curTotal <= 1 then 
		self.curPage = 0;
	end;

	local lisc = ConsignmentUtils:GetListPage(self.curList,self.curPage);
	if #lisc == 0 then 
		objSwf.itemDown.disabled = true;
	else
		objSwf.itemDown.disabled = false;
	end;

	local listVo = {};
	for i,info in pairs(lisc) do 
		local vo = ConsignmentUtils:GetBuyItemUIdata(info);
		table.push(listVo,vo)
	end;
	objSwf.selllist.dataProvider:cleanUp();
	objSwf.selllist.dataProvider:push(unpack(listVo));
	objSwf.selllist:invalidateData();
	self:SetPagebtn()
end;

-- 下架操作
function UIConsignmentSell:OnItemDownClick(e)
	--print("怎么咬吗？")
	if not e.item then return end;
	--print("怎么不要了")
	if not e.item.uid then return end;
	--print("什么情况")
	ConsignmentController:ResqItemOutShelves(e.item.uid,1)
end;
--icon 移入
function UIConsignmentSell:OnSetOverTipsData(e)
	if not e.item then return end;
	if not e.item.id then return end;

	local objSwf = self.objSwf;
	local cid = e.item.id;
	local uid = e.item.uid;
	--print(uid)

	local cfg = ConsignmentModel:GetMySellItemInfo(uid)
	--trace(cfg)
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(cid,1,1);
	if not itemTipsVO then return; end
	itemTipsVO.superVO = {};
	itemTipsVO.superVO.superList = cfg.superList
	itemTipsVO.superVO.superNum = cfg.superNum
	if itemTipsVO.superVO then
		itemTipsVO.superHoleList = {};
		for i=1,itemTipsVO.superVO.superNum do
			itemTipsVO.superHoleList[i] = 0
		end
	end
	itemTipsVO.extraLvl = cfg.attrAddLvl
	itemTipsVO.groupId = cfg.groupId;
	itemTipsVO.groupId2 = cfg.groupId2;
	itemTipsVO.groupId2Level = cfg.groupId2Level;
	itemTipsVO.newSuperList = cfg.newSuperList
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);

end;




-- notifaction
function UIConsignmentSell:ListNotificationInterests()
	return {
		NotifyConsts.ConsignmentBagIteminfo,
		NotifyConsts.ConsignmentMyUpItemInfo,
		NotifyConsts.ConsignmentMyUpItemNum,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate
		}
end;
function UIConsignmentSell:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.ConsignmentBagIteminfo then  
		if not UIConsignmentUpItem:IsShow() then 
			UIConsignmentUpItem:Show();
		else
			UIConsignmentUpItem:UpdataItemInfo();
		end;
	elseif name == NotifyConsts.ConsignmentMyUpItemInfo then 
		self:ShowItemList();
		self:SetCurrencyNum();
	elseif name == NotifyConsts.ConsignmentMyUpItemNum then 
		self:SetCurrencyNum();


	elseif  name == NotifyConsts.BagAdd  then
		-- 初始化背包装备
		self:ShowBagList()
	elseif name == NotifyConsts.BagRemove then 
		-- 初始化背包装备
		self:ShowBagList()
		if self:GetEquipIsAtUpItem(body.id) then 
			if UIConsignmentSureBuy:IsShow() then 
				UIConsignmentSureBuy:Hide();
			end;
		end;
	elseif name == NotifyConsts.BagUpdate then 
		-- 初始化背包装备
		self:ShowBagList()
			if self:GetEquipIsAtUpItem(body.id) then 
			if UIConsignmentSureBuy:IsShow() then 
				UIConsignmentSureBuy:Hide();
			end;
		end;
	end;
end;

function UIConsignmentSell:GetEquipIsAtUpItem(id)
	local item = ConsignmentModel:GetUpItemBagInfo();
	if not item then return end;
	if item:GetId() == id then 
		return true;
	end;
	return false;
end;




----------------------翻页
---翻页控制
-- 最前
function UIConsignmentSell:PagePre1()
	local objSwf = self.objSwf;
	self.curPage = 0;
	UIConsignmentSell:ShowItemList()
end;
-- 前
function UIConsignmentSell:PagePre()
	local objSwf = self.objSwf;
	self.curPage = self.curPage-1;
	UIConsignmentSell:ShowItemList()
end;
-- 最后
function UIConsignmentSell:PageNext1()
	local objSwf = self.objSwf;
	local len = ConsignmentUtils:GetListLenght(self.curList)
	self.curPage = len;
	UIConsignmentSell:ShowItemList()
end;
-- 后
function UIConsignmentSell:PageNext()
	local objSwf =self.objSwf;
	self.curPage = self.curPage+1;
	local len = ConsignmentUtils:GetListLenght(self.curList)
	UIConsignmentSell:ShowItemList()
end;

--  更新翻页状态
function UIConsignmentSell:SetPagebtn()
	local objSwf = self.objSwf;
	local curpage = self.curPage+1;
	local curTotal = ConsignmentUtils:GetListLenght(self.curList)+1;
	if curTotal <= 1 then 
		self.curPage = 1;
	end;
	if #self.curList == 0 then 
		curpage = 1;
	end;
	if curTotal == 0 then 
		curTotal = curTotal +1;
	end;
	objSwf.txtPage.text = string.format(StrConfig["consignment004"],curpage,curTotal)
	if curpage == 1 then 
		objSwf.btnPre1.disabled = true;
		objSwf.btnPre.disabled = true;
		objSwf.btnNext.disabled = false;
		objSwf.btnNext1.disabled = false;
	elseif curpage >= curTotal then 
		objSwf.btnPre1.disabled = false;
		objSwf.btnPre.disabled = false;
		objSwf.btnNext.disabled = true;
		objSwf.btnNext1.disabled = true;
	elseif curpage ~= 0 and curpage ~= curTotal then 
		objSwf.btnPre1.disabled = false;
		objSwf.btnPre.disabled = false;
		objSwf.btnNext.disabled = false;
		objSwf.btnNext1.disabled = false;
	end;
	if curTotal <= 1 then 
		objSwf.btnPre1.disabled = true;
		objSwf.btnPre.disabled = true;
		objSwf.btnNext.disabled = true;
		objSwf.btnNext1.disabled = true;
	end;
end;
