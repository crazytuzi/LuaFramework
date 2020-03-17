--[[
 寄售行 买
 wangshuai
]]
_G.UIConsignmentBuy = BaseUI:new("UIConsignmentBuy")

UIConsignmentBuy.treeData = {};
UIConsignmentBuy.layerOne = {}; 
UIConsignmentBuy.layerTwo = {};
UIConsignmentBuy.layerThree = {};
UIConsignmentBuy.layerFour = {};
UIConsignmentBuy.layerFive = {};
UIConsignmentBuy.layerSix = {};
UIConsignmentBuy.layerSeven = {};
UIConsignmentBuy.layerEight = {};

UIConsignmentBuy.oneIndex = 0; -- 祖
UIConsignmentBuy.twoIndex = 0; -- 父
UIConsignmentBuy.threeIndex = 0; -- 儿

UIConsignmentBuy.curSuperIndex = 0; -- 卓越条数
UIConsignmentBuy.curQualityIndex = 0; -- 品质

UIConsignmentBuy.MyCanBoolean = 1; -- 0是我能用 
UIConsignmentBuy.ItemMaxLvl = 100;
UIConsignmentBuy.ItemMiniLvl = 0;
UIConsignmentBuy.curPage = 1;
UIConsignmentBuy.curQuality = 0;

UIConsignmentBuy.curItemID = nil;



function UIConsignmentBuy:Create()
	self:AddSWF("consignmentBuyPanel.swf",true,nil)
end;

function UIConsignmentBuy:OnLoaded(objSwf)
	objSwf.scrollList.itemClick = function (e)self:ItemClick(e);end
	objSwf.buylist.iconRollOut = function()  TipsManager:Hide() end;
	objSwf.buylist.iconRollOver = function(e) self:OnSetOverTipsData(e)end; 
	objSwf.buylist.itemClick = function(e) self:OnBuyItemSelectde(e)end;
	objSwf.buylist.PriceTipsOver = function(e) self:OnPriceTipsOver(e)end;
	objSwf.buylist.PriceTipsOut = function(e) TipsManager:Hide() end;

	objSwf.minilvl_input.textChange = function() self:OnMiniLvlInput(objSwf.minilvl_input.text)end;
	objSwf.maxLvl_input.textChange = function() self:OnMaxLvlInput(objSwf.maxLvl_input.text)end;
	objSwf.minilvl_input.restrict = "0-9"
	objSwf.minilvl_input.maxChars = 3
	objSwf.maxLvl_input.restrict = "0-9"
	objSwf.maxLvl_input.maxChars = 3

	objSwf.ddQualityList.change= function (e) self:OnQualityDdlistChange(e);end;
	objSwf.ddQualityList.rowCount = 10;

	objSwf.ddSuperList.change= function (e) self:OnSuperDdlistChange(e);end;
	objSwf.ddSuperList.rowCount = 4;

	objSwf.MyCanItem.click = function() self:OnMyCanItemClick()end;

	objSwf.okSearch.click = function() self:OnOkSearchItemClick()end;
	objSwf.okSearch.label = StrConfig["consignment022"]

	objSwf.ReSearch.click = function() self:OnReSearchItem()end;

	-- 翻页组件
	objSwf.btnPre1.click = function() self:PagePre1()end; -- 前
	objSwf.btnNext1.click = function() self:PageNext1()end; -- 后
	objSwf.btnPre.click = function() self:PagePre()end; -- 上一个
	objSwf.btnNext.click = function() self:PageNext()end; -- 下一个

	objSwf.buy_btn.click = function() self:BuyItemClick()end;

	objSwf.updatabtn.click = function() self:OnUpdataClick()end;
	objSwf.updatabtn.label = StrConfig["consignment021"]

	objSwf.moneysort.click = function() self:OnMoneySortClick()end;


end;

function UIConsignmentBuy:OnShow()
	self:InItInfo()
	self:ShowBuyList();
	self:SetUIShowData()
	-- 我的元宝绑银
	self:ShowMyMoneyAndGold();
	-- 请求浏览信息
	UIConsignmentBuy:OnReSearchItem()
	
end;

function UIConsignmentBuy:OnUpdataClick()
	local objSwf = self.objSwf;
	self:OnOkSearchItem();
	self.objSwf.updatabtn.disabled = true;
	local num = 20;
	objSwf.updatabtn.label = num;
	TimerManager:RegisterTimer(function()
			if  objSwf.updatabtn then
				num = num -1 ; 
				objSwf.updatabtn.label = num;
				if num == 0 then 
					objSwf.updatabtn.label = StrConfig["consignment021"]
					objSwf.updatabtn.disabled = false;
				end;
			end
		end, 1000, 20)
end;

function UIConsignmentBuy:SetUIShowData()
	local objSwf = self.objSwf;
	objSwf.minilvl_input.text = self.ItemMiniLvl;
	objSwf.maxLvl_input.text = self.ItemMaxLvl;
	objSwf.ddQualityList.selectedIndex = self.curQualityIndex;
	if self.MyCanBoolean == 0 then 
		objSwf.MyCanItem.selected = true
	else
		objSwf.MyCanItem.selected = false;
	end;
end;

function UIConsignmentBuy:OnHide()
	self.curPage = 1;
	local objSwf = self.objSwf;
	objSwf.buylist.selectedIndex = -1;
	if UIConsignmentSureBuy:IsShow() then 																																																																				
		UIConsignmentSureBuy:Hide();
	end;

end;

function UIConsignmentBuy:InItInfo()
	-- 初始化
	self.layerOne,self.layerFour,self.layerSeven,self.layerEight = ConsignmentUtils:GetCreateInfo()
	self.oneIndex = 0; 
	self.twoIndex = 0;
	self.threeIndex = 0;

	self:NewShowTitleHandler();
	-- ShowDdbList
	self:ShowDdbList()
	
end;

-- 显示我的元宝银两
function UIConsignmentBuy:ShowMyMoneyAndGold()
	local objSwf = self.objSwf
	local myYuanbao = MainPlayerModel.humanDetailInfo.eaUnBindMoney
	local mygold = MainPlayerModel.humanDetailInfo.eaUnBindGold
	objSwf.yuanbao_txt.text = myYuanbao;
	-- objSwf.glod_txt.text = mygold;
end;

-- 是否我能用的物品
function UIConsignmentBuy:OnMyCanItemClick()
	if self.MyCanBoolean == 0 then 
		self.MyCanBoolean = 1
	else
		self.MyCanBoolean = 0;
	end;
	--print(self.MyCanBoolean)
end;



-- 开始搜索
function UIConsignmentBuy:OnOkSearchItemClick()
	local objSwf = self.objSwf;
	self:OnOkSearchItem();
	self.objSwf.okSearch.disabled = true;
	local num = 3;
	objSwf.okSearch.label = num;
	TimerManager:RegisterTimer(function()
			if  objSwf.okSearch then
				num = num -1 ; 
				objSwf.okSearch.label = num;
				if num == 0 then 
					objSwf.okSearch.label = StrConfig["consignment022"]
					objSwf.okSearch.disabled = false;
				end;
			end
		end, 1000, 3)
end;

function UIConsignmentBuy:OnOkSearchItem()
	-- print("最小装备等级",self.ItemMiniLvl)
	-- print("最大装备等级",self.ItemMaxLvl);
	-- print("装备卓越",self.curSuperIndex)
	-- print("装备品质",self.curQualityIndex)
	-- print("是否我能用",self.MyCanBoolean);
	-- print("一级标签",self.oneIndex)
	-- print("二级标签",self.twoIndex)
	-- print("三级标签",self.threeIndex)
	-- print("查看页",self.curPage)
	-- print()
	ConsignmentController:ResqIteminfo(
										self.curPage,
										self.oneIndex,
										self.twoIndex,
										self.threeIndex,
										self.ItemMiniLvl,
										self.ItemMaxLvl,
										self.curQualityIndex,
										self.curSuperIndex,
										self.MyCanBoolean
										)
	if UIConsignmentSureBuy:IsShow() then 
		UIConsignmentSureBuy:Hide();
	end;
end;

-- 重置搜索
function UIConsignmentBuy:OnReSearchItem()
	self.curPage = 1;
	self.ItemMiniLvl = 1 --
	self.ItemMaxLvl = 10 --
	self.curQualityIndex = 0;
	self.curSuperIndex = 1; --
	self.MyCanBoolean = 1; 
	self:SetUIShowData();
	self:OnOkSearchItem();
end;

-- 下拉框
function UIConsignmentBuy:ShowDdbList()
	self.objSwf.ddQualityList.dataProvider:cleanUp();
	for i=1,5,1 do
		-- if i == 5 then 
			-- local name =BagConsts:GetEquipProduct(i-1)..StrConfig["equip220"];
			-- self.objSwf.ddQualityList.dataProvider:push(name);
		-- else
			-- local name = BagConsts:GetEquipProduct(i-1)..StrConfig["equip230"];
			-- self.objSwf.ddQualityList.dataProvider:push(name);
		local name = StrConfig["consignmentQuality"..i];
		self.objSwf.ddQualityList.dataProvider:push(name);
		-- end;
	end;
	self.objSwf.ddQualityList.selectedIndex = 0;

	self.objSwf.ddSuperList.dataProvider:cleanUp();
	for i=1,5,1 do
		local name = StrConfig["consigsuperatb"..100+i]
		self.objSwf.ddSuperList.dataProvider:push(name);
	end;
	self.objSwf.ddSuperList.selectedIndex = 0;

end;

-- 下拉框点击事件
function UIConsignmentBuy:OnQualityDdlistChange(e)
	-- print('=================================下拉框点击事件',self.oneIndex)
	if not self.bShowState then return end;
	local index = e.index 
	if index == -1 then return end;
	self.curQualityIndex = index  -- 记录当前品质
	self.curQuality = index;
	if self.oneIndex>0 and self.oneIndex<8 then
		self:OnOkSearchItem()
	elseif self.oneIndex == 20 then
		self:OnOkSearchItem()
	else
		self.curQualityIndex = 0
	end
	--print(self.curQualityIndex)
end;

function UIConsignmentBuy:OnSuperDdlistChange(e)
	if not self.bShowState then return end;
	local index = e.index 
	if index == -1 then return end;
	self.curSuperIndex = index  -- 记录当前卓越
	--print(self.curSuperIndex)
end;

-- input text
function UIConsignmentBuy:OnMiniLvlInput(text)
	local objSwf = self.objSwf;
	local lvl = toint(text)
	if not lvl then return end;
	if lvl <= 0  then 
		objSwf.minilvl_input.text = 0;
	end;
	self.ItemMiniLvl = toint(text)
end;

function UIConsignmentBuy:OnMaxLvlInput(text)
	local objSwf = self.objSwf;
	local lvl = toint(text)	
	if not lvl then return end;
	if lvl > 300 then 
		objSwf.maxLvl_input.text = 300;
	end;
	self.ItemMaxLvl = toint(text)
end;

function UIConsignmentBuy:OnBuyItemSelectde(e)
	--print("选中了当前物品，出售人",e.item.roleName)
	self.curItemID = e.item.uid;
end;

function UIConsignmentBuy:BuyItemClick()
	if self.curItemID then 
		UIConsignmentSureBuy:SetData(self.curItemID)
		self.curItemID = nil
		local objSwf = self.objSwf;
		objSwf.buylist.selectedIndex = -1;
	else
		FloatManager:AddNormal(StrConfig['consignment019'])
	end;
end;

function UIConsignmentBuy:OnSetOverTipsData(e)
	if not e.item then return end;
	if not e.item.id then return end;

	local objSwf = self.objSwf;
	local cid = e.item.id;
	local uid = e.item.uid;	     
	local cfg = ConsignmentModel:getCertainBuitemInfo(uid)

	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(cid,1,1);
	if not itemTipsVO then return; end
	itemTipsVO.superVO = {};
	itemTipsVO.superVO.superList = cfg.superList
	itemTipsVO.superVO.superNum = cfg.superNum
	--trace(itemTipsVO.superVO)
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
	
	if t_equip[cid] then 
		local hasEquipItem = BagUtil:GetCompareEquip(BagConsts.BagType_Role,t_equip[cid].pos);
		if hasEquipItem then
			itemTipsVO.compareTipsVO = ItemTipsVO:new();
			ItemTipsUtil:CopyItemDataToTipsVO(hasEquipItem,itemTipsVO.compareTipsVO);
			itemTipsVO.compareTipsVO.isInBag = false;
			itemTipsVO.tipsShowType = TipsConsts.ShowType_Compare;
			TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Compare, TipsConsts.Dir_RightDown);
		else
			TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
		end
	else
		TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
	end;
end;

function UIConsignmentBuy:OnPriceTipsOver(e)
	if not e.item then return end;
	if not e.item.id then return end;
	local objSwf = self.objSwf;
	local cid = e.item.id;
	local uid = e.item.uid;	     
	local cfg = ConsignmentModel:getCertainBuitemInfo(uid)
	if not cfg then return end;
	local price = cfg.price;
	TipsManager:ShowBtnTips(string.format(StrConfig['consignment018'],price),TipsConsts.Dir_RightDown)
end;

-- 显示购买预览 list
function UIConsignmentBuy:ShowBuyList()
	local objSwf = self.objSwf;
	local list = ConsignmentModel:GetBuyItenInfo();
	local uilist = {}
	for i,info in ipairs(list) do 
		local str = ConsignmentUtils:GetBuyItemUIdata(info)
		table.push(uilist,str)
	end;
	objSwf.buylist.dataProvider:cleanUp();
	objSwf.buylist.dataProvider:push(unpack(uilist));
	objSwf.buylist:invalidateData();
	self.curPage = ConsignmentModel:GetBuItemPageInfo().curpage
	self:SetPagebtn();
end;

----------------------翻页
-- 最前
function UIConsignmentBuy:PagePre1()
	self.curPage = 1;
	UIConsignmentBuy:OnOkSearchItem()
end;
-- 前
function UIConsignmentBuy:PagePre()
	self.curPage = self.curPage - 1;
	UIConsignmentBuy:OnOkSearchItem()
end;
-- 最后
function UIConsignmentBuy:PageNext1()
	local pageinfo = ConsignmentModel:GetBuItemPageInfo();
	self.curPage = pageinfo.tatlpage
	UIConsignmentBuy:OnOkSearchItem()
end;
-- 后
function UIConsignmentBuy:PageNext()
	self.curPage = self.curPage + 1;
	UIConsignmentBuy:OnOkSearchItem()
end;
--  更新翻页状态
function UIConsignmentBuy:SetPagebtn()
	local objSwf = self.objSwf;
	local pageinfo = ConsignmentModel:GetBuItemPageInfo();
	local curpage = pageinfo.curpage
	local curTotal = pageinfo.tatlpage
	if curpage == 0 then 
		curpage = 1;
	end;
	objSwf.txtPage.text = string.format(StrConfig["rankstr004"],curpage,curTotal)
	--trace(pageinfo)
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

---------------------tree list

--treelist 点击事件
function UIConsignmentBuy:ItemClick(e)
	local objSwf = self.objSwf;
	if not e.item.id then return end
	-- print('------------------------UIConsignmentBuy:ItemClick(e)',e.item.id)
	local id = e.item.id;
	local parentTwo = e.item.parentTwo;
	local parentOne = e.item.parentOne;

	local objSwf = self.objSwf;
	objSwf.scrollList:SetselectedState(id);

	-- 不正常选项
	self.curPage = 1;
	if e.item.itemSelected == false then 
		if id < 200 then
			self.twoIndex = 0;
			self.threeIndex = 0
			if id < 100 then 
				self.oneIndex = 0;
				self.twoIndex = 0;
				self.threeIndex = 0
			end;
			if self.oneIndex>0 and self.oneIndex<8 then
				self.curQualityIndex = self.curQuality;
			elseif self.oneIndex == 20 then
				self.curQualityIndex = self.curQuality;
			else
				self.curQualityIndex = 0
			end
			self:OnOkSearchItem()
			
			return 
		end;
	end;

	-- 正常选三项
	if id < 200 then
		--print("小于200",id)
		self.twoIndex = id - 100;
		self.threeIndex = 1;
		if id < 100 then 
		--	print("小于100",id)
			
			self.oneIndex = parentOne;
			self.twoIndex = 1;
			self.threeIndex = 1
			-- 特殊，2以后都不分职业
			if id > 1 and id < 4 then 
				self.twoIndex = 0;
			end;
		end;
		if self.oneIndex>0 and self.oneIndex<8 then
			self.curQualityIndex = self.curQuality;
		elseif self.oneIndex == 20 then
			self.curQualityIndex = self.curQuality;
		else
			self.curQualityIndex = 0
		end
		self:OnOkSearchItem()
		return 
	end;
	self.oneIndex = parentOne;
	self.twoIndex = parentTwo or 0;
	self.threeIndex = id - 200;
	-- self.curQualityIndex = 0
	if self.oneIndex>0 and self.oneIndex<8 then
		self.curQualityIndex = self.curQuality;
	elseif self.oneIndex == 20 then
		self.curQualityIndex = self.curQuality;
	else
		self.curQualityIndex = 0
	end
	self:OnOkSearchItem()

end

-- 显示tree list
function UIConsignmentBuy:NewShowTitleHandler()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	UIData.cleanTreeData( objSwf.scrollList.dataProvider.rootNode);
	self.treeData.label = "root";
	self.treeData.open = true;
	self.treeData.isShowRoot = false;
	self.treeData.nodes = {};
	for i , v in ipairs(self.layerOne) do
		local scrollNode = {};
		scrollNode.str = v.name;
		scrollNode.nodes = {};
		-- if i == self.oneIndex then
		 	-- scrollNode.open = true;
		 	-- scrollNode.itemSelected = true;
		-- else
			scrollNode.open = false;
		 	scrollNode.itemSelected = false;
		-- end;
		scrollNode.withIcon = true;
		scrollNode.nodeType = 1;
		scrollNode.id = v.id;
		scrollNode.isOpen = true;
		scrollNode.parentOne = i+19;

		-- if v.id == 2 then --法宝系列
			-- for three,thrVo in pairs(self.layerSeven) do 
				-- local nodeThree = {};
				-- if three == self.threeIndex then 
					-- nodeThree.itemSelected = true;
				-- else
					-- nodeThree.itemSelected = false;
				-- end;
				-- nodeThree.labelthree = thrVo.name;
				-- nodeThree.id = thrVo.id;
				-- nodeThree.parentTwo = i;
				-- nodeThree.parentOne = three+100;
				-- nodeThree.nodeType = 3;
				-- table.push(scrollNode.nodes, nodeThree)
			-- end;
		if v.id == 2 then --道具系列
			for three,thrVo in pairs(self.layerFour) do 
				local nodeThree = {};
				-- if three == self.threeIndex then 
					-- nodeThree.itemSelected = true;
				-- else
					nodeThree.itemSelected = false;
				-- end;
				nodeThree.labelthree = thrVo.name;
				nodeThree.id = thrVo.id;
				nodeThree.parentTwo = i;
				nodeThree.parentOne = three+11;
				nodeThree.nodeType = 3;
				table.push(scrollNode.nodes, nodeThree)
			end;
		else
			for three,thrVo in pairs(self.layerEight) do --装备系列
				local nodeThree = {};
				-- if three == self.threeIndex then 
					-- nodeThree.itemSelected = true;
				-- else
					nodeThree.itemSelected = false;
				-- end;
				nodeThree.labelthree = thrVo.name;
				nodeThree.id = thrVo.id;
				nodeThree.parentTwo = i;
				nodeThree.parentOne = three;
				nodeThree.nodeType = 3;
				table.push(scrollNode.nodes, nodeThree)
			end;
		end;
		table.push(self.treeData.nodes, scrollNode);
	end
	UIData.copyDataToTree(self.treeData,objSwf.scrollList.dataProvider.rootNode);
	objSwf.scrollList.dataProvider:preProcessRoot();
	objSwf.scrollList:invalidateData();
end


-- notifaction
function UIConsignmentBuy:ListNotificationInterests()
	return {
			NotifyConsts.ConsignmentBuyItemInfo;
		}
end;
function UIConsignmentBuy:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.ConsignmentBuyItemInfo then  
		--print("没有收到消息吗?")
		self:ShowBuyList();
		self:ShowMyMoneyAndGold()
		self.curItemID = nil
	end;
end;

UIConsignmentBuy.SortBoolean = true
--item 排序
function UIConsignmentBuy:OnMoneySortClick()
	ConsignmentUtils:SetListSort(self.SortBoolean)
	self:ShowBuyList()
	self.SortBoolean = not self.SortBoolean 
end;


