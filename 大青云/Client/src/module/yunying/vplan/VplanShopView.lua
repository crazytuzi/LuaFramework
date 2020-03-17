--[[
v计划，商城打折
wangshuai
]]

_G.UIVplanShop = BaseUI:new("UIVplanShop");

UIShoppingMall.curPage = 0;
UIShoppingMall.curList = {};

function UIVplanShop:Create()
	self:AddSWF("vplanShopPanel.swf",true,nil)
end;

function UIVplanShop:OnLoaded(objSwf)

	objSwf.list.itemCCClick = function(e) self:OnItemClick(e)end;
	objSwf.list.iconRollOver = function(e) self:OnIconOver(e) end;
	objSwf.list.iconRollOut = function() TipsManager:Hide(); end;
	objSwf.list.itemopenVipClick = function() self:OnOpenVipClick();end;


	objSwf.btnPre1.click = function() self:PagePre1()end; -- 前
	objSwf.btnNext1.click = function() self:PageNext1()end; -- 后
	objSwf.btnPre.click = function() self:PagePre()end; -- 上一个
	objSwf.btnNext.click = function() self:PageNext()end; -- 下一个

end;

function UIVplanShop:OnShow()
	self.curPage = 0;
	self:OnShowList();
end;

function UIVplanShop:OnItemClick(e)
	local id = e.item.id;
	UIShopBuyConfirm:Open(id);
end;

function UIVplanShop:OnIconOver(e)
	local target = e.renderer;
	local cid = e.item.id;
	local cfg = t_shop[cid];
	TipsManager:ShowItemTips(cfg.itemId,1,TipsConsts.Dir_RightDown);
end;

function UIVplanShop:OnOpenVipClick() 
	VplanController:ToMRecharge()
end;

function UIVplanShop:OnShowList()
	local objSwf = self.objSwf;
	self.curList = ShopModel:GetVplanItemlist();
	local list = self:GetListPage(self.curList,self.curPage)
	local listvo = {};
	for i,info in ipairs(list) do 
		local cfg = info:GetCfg();
		local itemCfg = t_item[cfg.itemId]

		local iconData = {};
		local rewardSlotVO = RewardSlotVO:new();
		rewardSlotVO.id = cfg.itemId;
		rewardSlotVO.count = 0;
		rewardSlotVO.bind = info:GetBind();
		

		local itemData = {};
		itemData.id = cfg.id;
		itemData.nameColor = ShopUtils:GetItemQualityColor(cfg.itemId);
		itemData.name = ShopUtils:GetItemNameById(cfg.itemId);
		itemData.moneyX = string.format(StrConfig['vplan802'],cfg.price)
		itemData.moneyY = string.format(StrConfig['vplan803'],cfg.oPrice)
		itemData.moneySourceY = ResUtil:GetMoneyIconURL(cfg.moneyType)
		itemData.moneySourceX = ResUtil:GetMoneyIconURL(cfg.moneyType)
		itemData.IsVip = VplanModel:GetIsVplan();

		local str = UIData.encode(itemData).."*"..rewardSlotVO:GetUIData()

		table.push(listvo,str)
	end;
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(listvo));
	objSwf.list:invalidateData();

	-- 刷新按钮状态
	self:SetPagebtn();
end;

function UIVplanShop:OnHide()

end;





--------------- 分页

---翻页控制
-- 最前
function UIVplanShop:PagePre1()
	local objSwf = self.objSwf;
	self.curPage = 0;
	UIVplanShop:OnShowList()
end;
-- 前
function UIVplanShop:PagePre()
	local objSwf = self.objSwf;
	self.curPage = self.curPage-1;
	UIVplanShop:OnShowList()
end;
-- 最后
function UIVplanShop:PageNext1()
	local objSwf = self.objSwf;
	local len = self:GetListLenght(self.curList)
	self.curPage = len;
	UIVplanShop:OnShowList()
end;
-- 后
function UIVplanShop:PageNext()
	local objSwf =self.objSwf;
	self.curPage = self.curPage+1;
	local len = self:GetListLenght(self.curList)
	UIVplanShop:OnShowList()
end;

function UIVplanShop:SetPagebtn()
	local objSwf = self.objSwf;
	local curpage = self.curPage+1;
	local curTotal = self:GetListLenght(self.curList)+1;
	objSwf.txtPage.text = string.format(StrConfig["vplan804"],curpage,curTotal)
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

UIVplanShop.onePage = 9;
-- 得到当前页数下的itemlist
function UIVplanShop:GetListPage(list,page)
	local vo = {};
	page = page + 1;
	for i=(self.onePage*page)-self.onePage+1,(self.onePage*page) do 
		table.push(vo,list[i])
	end;
	return vo
end;

function UIVplanShop:GetListLenght(list)
	local lenght = #list/self.onePage;
	return math.ceil(lenght)-1;
end;


function UIVplanShop:HandleNotification(name,body)
	if name==NotifyConsts.VFlagChange then
		self:OnShowList();
	end
end

function UIVplanShop:ListNotificationInterests()
	return {NotifyConsts.VFlagChange};
end