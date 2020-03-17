--[[ 
装备升品
wangshuai
2014年11月25日10:32:51
]]

_G.UIEquipProduct =  BaseUI:new("UIEquipProduct");

UIEquipProduct.curProductList = {};  --list
UIEquipProduct.curAutoproductlist = {}; 
UIEquipProduct.currPos = nil;
UIEquipProduct.curAutoproduct = 0; -- 当前自动吞噬等级
UIEquipProduct.curEquipItem = nil; --当前装备
UIEquipProduct.baglist = {}
UIEquipProduct.curIsNotTipDesc = nil;

function UIEquipProduct : Create ()
	self:AddSWF("equipProductPanel.swf",true,nil);
end;

function UIEquipProduct : OnLoaded(objSwf)
	--设置模型不接受事件
	objSwf.roleLoaderProdut.hitTestDisable = true;
	-- 规则提示
--	objSwf.btnRule.txt.textField.htmlText = string.format(UIStrConfig['equip227']);
	objSwf.btnRule.rollOver = function() TipsManager:ShowBtnTips(StrConfig['equip218'],TipsConsts.Dir_RightDown); end
	objSwf.btnRule.rollOut = function() TipsManager:Hide(); end
	-- 装备list
	objSwf.list.itemClick = function(e) self:OnRoleEquipItemClick(e); end
	objSwf.list.itemRollOver = function(e) self:OnRoleEquipRollOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	-- 自动吞噬list
	objSwf.ddList.change= function (e) self:OnDlistChange(e);end;
	objSwf.ddList.rowCount = 6;
	-- baglist
	objSwf.baglist.itemClick = function (e) self:OnBagListitemClick(e);end;
	objSwf.baglist.itemRollOver = function (e) self:OnBAgListRollover(e);end;
	objSwf.baglist.itemRollOut = function (e) TipsManager:Hide();end;
	-- btn
	objSwf.btnPrpduct.click = function() self:OnProductClick();end;
	objSwf.btnAutoProduct.click = function() self:OnAutoProductClick();end;
	-- 升品按钮 tips
	objSwf.curEquipPro.click = function () self:OnEquipProclick()end;
	objSwf.curEquipPro.rollOver = function () self:OnEquipProTips()end;
	objSwf.curEquipPro.rollOut = function () TipsManager:Hide() end;
	-- 满级效果
	objSwf.curEquipProMaxLvl.rollOver = function () self:OnEquipProMaxTips()end;
	objSwf.curEquipProMaxLvl.rollOut = function () TipsManager:Hide() end;

	-- objSwf.chenggongfpx:gotoAndStop(34)
	-- objSwf.chenggongfpx.playOver = function() self:ProductPfxPlayOver()end;
end;

function UIEquipProduct:ProductPfxPlayOver()
	-- local objSwf = self.objSwf;
	-- objSwf.chenggongfpx:gotoAndStop(34)
end;

function UIEquipProduct : OnShow()
	self:init()
	self:ShowRoleEquip()  --显示装备list
	self:SHowPrList() -- 显示品阶选项
	self:ShowBagEquip() -- 显示背包装备list
	self:DrawRole();  -- 画人物
	self:OnSetGuideEquip(); -- 自动选择装备
end;

function UIEquipProduct:init()
	self.curProductList =  {};
	self.curAutoproductlist = {};
	self.curAutoproduct = 0;
	self.curEquipItem = nil;
	self.baglist = {};
	--self:ShowEquip() -- 清空当前升品装备
	--print('初始化，调用 73')
	--self:CurAddinfo();
	--self:AutoProdu();
end

-- 自动吞噬按钮
function UIEquipProduct : OnAutoProductClick()
	self:OnGuideClick()
	--print("自动吞噬，条用")
	self:AutoProdu()
		
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag)
	if #self.curAutoproductlist == 0 then 
		FloatManager:AddNormal(StrConfig['equip227']);
	end;
	local isShowTipWindew = false
	local isShowTipTowWindew = false;

	for i,ca in pairs(self.curAutoproductlist) do 
		local item = bagVO:GetItemById(ca.id)  --装备
		if item then 
			local cof = item:GetCfg() -- 当前装备Config
			if not cof then return end ;
			if cof.quality > BagConsts.Quality_Blue or item:IsValuable() == true then 
				isShowTipWindew = true;
			end;
			local proVal = EquipModel:GetProVal(ca.id);
			if proVal > 0 then 
				isShowTipTowWindew = true;
			end;
		end;
	end;
	
	if self.curIsNotTipDesc then 
		self:OnSendAutoMsg();
		return;
	end;

	-- 判断是否有，高阶装备，还有正在升品的装备。。。。
	if  isShowTipWindew == true or isShowTipTowWindew == true then 
		local okfunb = function (desc)self:OnSendAutoMsg(desc); end;
		UIConfirmWithNoTip:Open(UIStrConfig["equip229"],okfunb);
		return ;
	end;
	self:OnSendAutoMsg();
end;

-- 吞噬按钮 
function UIEquipProduct : OnProductClick()
	self:OnGuideClick();

	if #self.curProductList == 0 then 
 		FloatManager:AddNormal(StrConfig['equip221']);
 		return
 	end
	
 	local isShowTipWindew = false
	local isShowTipTowWindew = false;

	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag)
	for i,ca in pairs(self.curProductList) do 
		local item = bagVO:GetItemById(ca.id)  --装备
		if not item then return end;
		local cof = item:GetCfg() -- 当前装备Config
		if cof.quality > BagConsts.Quality_Blue or item:IsValuable() == true then 
			-- 显示提示当前有橙色装备
			isShowTipWindew = true;
		end;
		local proVal = EquipModel:GetProVal(ca.id);
		if proVal > 0 then 
			isShowTipTowWindew = true;
		end;
	end;
	--print(self.curIsNotTipDesc,"是否显示当前跳过")
	if self.curIsNotTipDesc then 
		self:sendMsg();
		return;
	end;
	-- 判断同时有，高阶装备，还有正在升品的装备。。。。
	if isShowTipWindew == true or isShowTipTowWindew == true then 
		local okfunb = function (desc)self:sendMsg(desc); end;
		UIConfirmWithNoTip:Open(UIStrConfig["equip229"],okfunb);
		return ;
	end;
	self:sendMsg();
end;

-- 该发送消息啦！！
function UIEquipProduct : sendMsg(notip)
	if not self.curIsNotTipDesc then 
		self.curIsNotTipDesc = notip;
	end;
	local item = self.curEquipItem;
	if not item then return end;
	local list = {};
	for i,p in pairs(self.curProductList) do 
		local vo = {};
		vo.id = p.id;
		table.push(list,vo)
	end;
	
	EquipController:EquipPro(item:GetId(),list)
	self.curProductList = {};
end;
--  发送一键吞噬
function UIEquipProduct : OnSendAutoMsg(notip)--cueIsNotTipDesc2
	if not self.curIsNotTipDesc then 
		self.curIsNotTipDesc = notip;
	end;
	--print("没有发送消息吗？")
	local list = {};
	local item = self.curEquipItem;
	if not item then return end;
	--print("没有发送消息吗？22222222")
	for i,p in pairs(self.curAutoproductlist) do 
		local vo = {};
		vo.id = p.id ;
		table.push(list,vo)
	end;
	--trace(list)
	if #list <= 0 then return end; 
	EquipController:EquipPro(item:GetId(),list)
	self.curAutoproductlist = {};
	self.curProductList = {};
end;

--  取下当前装备
function UIEquipProduct:OnEquipProclick()
	self:FlyOut(self.currPos);
	self:OnEmptyProcessing();
end;

-- 当前装备
function UIEquipProduct:OnEquipProTips()
	local objSwf = self.objSwf;
	if not self.curEquipItem then return end; -- 如果当前没有选取要升品的装备 
	local pos = self.curEquipItem:GetPos();
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	local item = bagVO:GetItemByPos(pos);
	if not item then return end;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

--当前装备满级效果
function UIEquipProduct:OnEquipProMaxTips()
	local objSwf = self.objSwf;
	if not self.curEquipItem then return end; -- 如果当前没有选取要升品的装备 
	local cfg = self.curEquipItem:GetCfg();
	if not cfg then return  end ;
	local po = cfg.quality;
	 local prolvl = cfg.proid;
	if po >= BagConsts.Quality_Lilac then return end;
	local item = ItemTipsUtil:GetItemTipsVO(prolvl)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,self.curEquipItem:GetCfg().pos);
	if not itemTipsVO then return; end
	itemTipsVO.id = item.id;
	itemTipsVO.cfg = item.cfg;
	itemTipsVO.iconUrl = item.iconUrl;
	itemTipsVO.levelAccord = item.levelAccord;
	itemTipsVO.isInBag = false;
	itemTipsVO.equiped = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

-- 自动吞噬下拉框
function UIEquipProduct:SHowPrList()
	self.objSwf.ddList.dataProvider:cleanUp();
	--self.objSwf.ddList.dataProvider:push("");
	for i=1,6,1 do
		if i == 1 then 
			local name = BagConsts:GetEquipProduct(i-1)..StrConfig["equip220"];
			self.objSwf.ddList.dataProvider:push(name);
		else
			local name = BagConsts:GetEquipProduct(i-1)..StrConfig["equip219"];
			self.objSwf.ddList.dataProvider:push(name);
		end;
	end;
	self.objSwf.ddList.selectedIndex = 0;
	self.curAutoproduct = 0;
end;

function UIEquipProduct:OnDlistChange(e)
	if not self.bShowState then return end;
	local index = e.index 
	if index == -1 then return end;
	self.curAutoproductlist = {};
	self.curAutoproduct = index  -- 记录当前一键吞噬等级
	--print("这里也执行首次出发了") 
	self:AutoProdu();
end;

function UIEquipProduct:noProdu()
	self.objSwf.ddList.selectedIndex = 1;
end;

-- 选择可以吞噬的装备
function UIEquipProduct:AutoProdu()
	if not self.curEquipItem then return end;
	--print("进入自动选择吞噬装备")
	local index = self.curAutoproduct;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag)
 	--- 重新渲染item
	for i,a in ipairs(self.baglist) do
		--print(a.pos)
		local item = bagVO:GetItemByPos(a.pos);
		--print(a.pos,"当前装备伟")
		if item  then 
			local cof = item:GetCfg();
			local qu = cof.quality;
			if qu > index then 
				--设置当前大于的状态为false
				a.state = false;
				local uiData = UIData.encode(a);
				self.objSwf.baglist.dataProvider[i-1] = uiData;
				local uiItem = self.objSwf.baglist:getRendererAt(i-1);
				if uiItem then
					uiItem:setData(uiData);
				end
			end;
		end;
	end;
	-- 删除等级大的装备
	for i,ca in ipairs(self.curProductList) do 
		local item = bagVO:GetItemById(ca.id)  --装备
		if not item then break end;
		local cof = item:GetCfg() -- 当前装备Config
		local itemlvl = cof.quality ;
		if itemlvl > index then 
			if self.curProductList[i].render:GetIsData() then 
				self.curProductList[i].render:GetIsData();
			end;
			self.curProductList[i] = nil;
		end;
	end;
	-- 添加等级小的装备
	local vo = bagVO:GetItemListByShowType(BagConsts.ShowType_Equip)
	for p,co in pairs(vo) do 
		local cof = co:GetCfg() -- 当前装备Config
		local olvl = cof.quality -- 当前装备品阶
		if olvl <= index then 
			local cov = {};
			cov.id = co:GetId();
			cov.tid = co:GetTid();
			table.push(self.curAutoproductlist,cov)
		end;
	end;
	--print("这里调用AutoProdu  324")
 	-- 更新进度条
	self:CurAddinfo()
end;

-- 人物装备Item点击
function UIEquipProduct : OnRoleEquipItemClick(e)
	--Debug(e.item.pos) -- 当前装备点击
	if self.currPos == e.item.pos then return end;
	if not e.item.pos == 0 then return end; 
	local pos = e.item.pos;
	--self.currPos = pos;
	self:OnAutoSelectEquip(pos)
end;

function UIEquipProduct:OnAutoSelectEquip(pos,isPrompt)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role); -- 获取人物穿戴 list
	if not bagVO then return end;
	local item = bagVO:GetItemByPos(pos); -- 从穿戴list中取出点击装备
	if not item then return end
	local cof = item:GetCfg();
	local curquality = cof.quality
	if curquality > BagConsts.Quality_Blue then 
		--  如果当前点击装备品质大于蓝色
		if isPrompt == true then return end;
			FloatManager:AddNormal(StrConfig['equip223']);
		return ;
	end;
	
	self.curEquipItem = item;
	
	if self.currPos ~= pos then 
		if self.currPos then 
			self:FlyOut(self.currPos);
		end;
		self:FlyIn(pos);
	end;
	print("OnAutoSelectEquip 358  调用")
	self:CurAddinfo();
	self:ShowEquip(pos);
	-- 记录上一次id
	local id = self.curEquipItem:GetCfg().id;
	self.itemcccID = id
end;

--显示装备信息
function UIEquipProduct:ShowEquip(pos)
	self.objSwf.curEquipPro:setData(UIData.encode({}));  --显示 
	self.objSwf.curEquipProMaxLvl:setData(UIData.encode({}));  --显示 
	 --- 添加本次的数据
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return end;
	local item = bagVO:GetItemByPos(pos);
	if not item then return end;
	local vo = EquipUtil:GetEquipUIVO(pos,true); -- 获取数据
	self.objSwf.curEquipPro:setData(UIData.encode(vo));  --显示 
	local eproid = t_equip[item:GetTid()]
	if not eproid then print("Error: eproid is nil  at UIEquipProduct 389")return end;  -- 当前物品id取不到装备
	local tcfg = t_equip[eproid.proid]
	if not tcfg then print("Error: tcfg is nil  at UIEquipProduct 391")return end; -- 取不到 升品以后的装备
	local tid = tcfg.id
	local voc = {};
	voc.pos = pos;
	voc.isBig = false;
	voc.showBind = item:GetBindState();
	voc.hasItem = true;
	voc.iconUrl = BagUtil:GetItemIcon(tid,true)
	voc.qualityUrl = ResUtil:GetSlotQuality(t_equip[tid].quality,54);
	voc.quality = t_equip[tid].quality;
	voc.strenLvl = EquipModel:GetStrenLvl(item:GetId());
	self.objSwf.curEquipProMaxLvl:setData(UIData.encode(voc));  --显示 
	if not self.currpos then
		self.objSwf.curEquipPro.hide = true;
	end
	self.currPos = pos;
end

UIEquipProduct.curbagitem = {};
-- 背包装备点击事件
function UIEquipProduct : OnBagListitemClick(e)
	if e.renderer:GetIsData() == false then return end;
	
	if not self.curEquipItem then 
		FloatManager:AddNormal(StrConfig['equip225']);
		return 
	end;
	--  当前装备
	local mainCof = self.curEquipItem:GetCfg();
	if mainCof.quality >= BagConsts.Quality_Lilac then 
		FloatManager:AddNormal(StrConfig['equip226']);
		return;
	end;
	self.curbagitem = e
	local curid = e.item.id
	local curpro = EquipModel:GetProVal(curid);
	if curpro > 0 then 
		if e.item.state == true then self:NextFun(); return  end;
		local okfun = function () self:NextFun(); end;
		local nofun = function () end;
		--UIEquipProductWTow:init(okfun,nofun)
		UIConfirm:Open(UIStrConfig["equip224"],okfun,nofun);
	else 
		self:NextFun();
	end;
end;

function UIEquipProduct : NextFun()
	local e = self.curbagitem
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local curid = e.item.id;
	local curpos = e.item.pos;
	local render = e.renderer;
	local bo = not e.item.state
	for i,vo in ipairs(self.baglist) do
		if vo.id == curid then
			vo.state = not vo.state;
			local uiData = UIData.encode(vo);
			objSwf.baglist.dataProvider[i-1] = uiData;
			local uiItem = objSwf.baglist:getRendererAt(i-1);
			if uiItem then
				uiItem:setData(uiData);
			end
			break;
		end;
	end;
	if bo == false then 
		-- 移除
		for i,csa in ipairs(self.curProductList) do 
			 if curid == csa.id then  --self.curProductList[i] = nil;
			 	table.remove(self.curProductList,i,1);
			 end;
		end;
	elseif bo == true then 
		--添加
		local vo = {};
		vo.id = curid;
		vo.render = render;
		table.push(self.curProductList,vo);
	end;
	--print('nextfun 调用  lin 481')
	self:CurAddinfo();
end;

-- 刷新当前进度条
function UIEquipProduct:CurAddinfo()
	--print('刷新进度条执行了几次？')
	local userAddNum = 0;
	local mainitem = self.curEquipItem;
	if not mainitem then 
	-- 判断当前装备是否有 ， 没有弹出
		self.objSwf.siStrenVal:setProValu(0,0,0);
		self.objSwf.siStrenVal.tf.htmlText = string.format(StrConfig["equip224"],0,0,0)
		return 
	end;
	local mainbagVO = BagModel:GetBag(BagConsts.BagType_Role);
	local itemc = mainbagVO:GetItemByPos(mainitem:GetPos());
	if not itemc then 
		-- 判断当前装备是否有 ， 没有弹出
		self.objSwf.siStrenVal:setProValu(0,0,0);
		self.objSwf.siStrenVal.tf.htmlText = string.format(StrConfig["equip224"],0,0,0)
		return 
	end;

	local maincof =mainitem:GetCfg();
	local mainlvl = maincof.level;
	local mainque = maincof.quality;
	if maincof.quality >= BagConsts.Quality_Lilac then 
		self.curProductList = {};  -- 当前吞噬list
		self.curAutoproductlist = {}; -- 当前自动吞噬list
	end;
	local id = tonumber(tostring(mainlvl) .. tostring(mainque));
	local info = t_equipdevour[id];
	if mainque < BagConsts.Quality_Lilac then 
		local bagVO = BagModel:GetBag(BagConsts.BagType_Bag)
		for i,ca in pairs(self.curProductList) do 
			local item = bagVO:GetItemById(ca.id)  --装备
			if not item then break end;
			local curcof = item:GetCfg();
			local curlvl = curcof.level;
			local curque = curcof.quality;
			local uid = tostring(curlvl) .. tostring(curque);
			local myuserinfo = t_equipdevour[toint(id)]["lv"..uid] or 0 
			userAddNum = userAddNum + myuserinfo;
		end;
	end;
	local max = self:GetProMaxInfo(mainitem:GetPos());
	--print(mainitem:GetId())
	local vlu = EquipModel:GetProVal(mainitem:GetId());
	local vl2 = userAddNum
	local vl3 = 0;
	for i,info in pairs(self.curProductList) do 
		vl3 = vl3 + EquipModel:GetProVal(info.id)
	end;
	if max == 0 then 
		max = 0;
		vlu = 0;
		vl2 = 0;
	end;
	self.objSwf.siStrenVal:setProValu(vlu,vlu+vl2+vl3,max);
	self.objSwf.siStrenVal.tf.htmlText = string.format(StrConfig["equip224"],vlu,vl2+vl3,max)
end;

-- 达到升品上线的处理
function UIEquipProduct:OnEmptyProcessing()
	self.curEquipItem = nil;
	--self.curAutoproductlist = {};
	self.curProductList = {};
	self.currPos = nil;
	self.objSwf.curEquipPro:setData(UIData.encode({}));
	self.objSwf.curEquipProMaxLvl:setData(UIData.encode({}));  --显示 
	self:ShowRoleEquip();
	self:ShowBagEquip();
	--print('上线处理， 544')
	self:CurAddinfo()
end;

-- 显示背包装备list
function UIEquipProduct:ShowBagEquip()
	local objSwf = self.objSwf;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag)
	objSwf.baglist.dataProvider:cleanUp();
	self.baglist = {};
	local list = bagVO:GetItemListByShowType(BagConsts.ShowType_Equip)
	for q,a in ipairs(list) do
			local id = a:GetId();
			local pos = a:GetPos();
		--	print("当前装备位置",pos)
			local item = bagVO:GetItemByPos(pos);
			local voc = {};
			voc.pos = pos;
			voc.id = id;
			EquipUtil:GetDataToEquipUIVO(voc,item)
			voc.qualityUrl = ResUtil:GetSlotQuality(t_equip[item:GetTid()].quality);
			voc.iconUrl = BagUtil:GetItemIcon(item:GetTid(),false);
			voc.state = false;
			voc.tipbo = true;
			voc.tid = item:GetTid();
			voc.quality = t_equip[item:GetTid()].quality
			table.push(self.baglist,voc);
			objSwf.baglist.dataProvider:push(UIData.encode(voc));
	end;
	objSwf.baglist:invalidateData();
	objSwf.baglist:scrollToIndex(0);
end;

-- 背包tips
function UIEquipProduct : OnBAgListRollover(e)
	if e.renderer:GetIsData() == false then return end;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	local item = bagVO:GetItemByPos(e.item.pos);
	if not item then return end;
	TipsManager:ShowBagTips(BagConsts.BagType_Bag,e.item.pos)
end;

--  显示人物装备list
function UIEquipProduct:ShowRoleEquip()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local list = {};
	for i,pos in ipairs(EquipConsts.EquipStrenType) do
		table.push(list,UIData.encode(EquipUtil:GetEquipUIVO(pos)));
	end
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(list));
	objSwf.list:invalidateData();
end
 
--玩家装备tips
function UIEquipProduct:OnRoleEquipRollOver(e)
	local pos = e.item.pos;
	if self.currPos == pos then return end;
	local uiItem = self.objSwf.list:getRendererAt(pos);
	if uiItem.hide == true then return end;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end

--------------------------Notification
function UIEquipProduct:ListNotificationInterests()
	return {NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagUpdate,NotifyConsts.BagRefresh,
			NotifyConsts.EquipAttrChange,NotifyConsts.BagItemNumChange,NotifyConsts.EquipProductUpdata};
end

function UIEquipProduct:HandleNotification(name,body)
	if not self.bShowState then return; end
	if not self.objSwf then return; end
	if name == NotifyConsts.EquipProductUpdata then 
		if body == 1 then 
			self:OnSetDataShowResult()
			TimerManager:RegisterTimer(function()
				self:FlyOut(self.currPos,true);
				self:OnEmptyProcessing();
			
			end,1000,1);
			return 
		end
		--print("消息回来 调用  632")
		self:CurAddinfo()
		--self:ShowRoleEquip();
		self:ShowBagEquip();

	elseif name==NotifyConsts.BagAdd or name==NotifyConsts.BagRemove then
		if body.type==BagConsts.BagType_Role and body.pos==self.currPos then
			self:OnEmptyProcessing();
		end
		
	end;
end;

function UIEquipProduct:OnSetDataShowResult(bo)
	local item = self.curEquipItem; -- 新装备cfg
	local nowcfg = item:GetCfg();
	local oldId = self.itemcccID; -- 老装备id
	local oldcfg = t_equip[oldId];
	if not oldcfg then return end;
	local vo = {};
	vo.oldlist = AttrParseUtil:Parse(oldcfg.baseAttr);
	vo.nowlist = AttrParseUtil:Parse(nowcfg.baseAttr)

	vo.oldquality = oldcfg.quality;
	vo.nowquality = nowcfg.quality;
	vo.pos = self.currPos
	--trace(oldlist)
	--trace(nowlist)
	
	vo.nowsuepr = EquipModel:GetSuperVO(item:GetId());
	UIEquipProductResult:ProductResultData(vo)

end;

function UIEquipProduct : EquipUpOk()
	local objSwf = self.objSwf;
	FloatManager:AddNormal(StrConfig['equip257'],objSwf.levelUp);
end;

-----------------------------readConfig --------
-- 当前装备精度条最大值
function UIEquipProduct:GetProMaxInfo(pos)
	local qua,level = self:GetQuality(pos)
	if not qua or not level then 
		 print("pos = "..qua,"level = "..level,debug.traceback())
	end;
	local id = level*100+qua;
	local curEquip = t_equippro[id];
	local curProMax = 0;
	if qua == BagConsts.Quality_White  then 
		-- 当前装备为白装
		curProMax = curEquip.write;
	end;
	if qua == BagConsts.Quality_Green then 
		-- 当前装备为绿装
		curProMax = curEquip.green;
	end;
	if qua == BagConsts.Quality_Blue then 
		-- 当前装备为蓝装
		curProMax = curEquip.blue;
	end;
	return curProMax;
end;

--------------------------------getConfig ---- 
--  得到当前pos物品品质
function UIEquipProduct : GetQuality(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	local item = bagVO:GetItemByPos(pos);
	if not item then return 0,0 end;
	local cof = item:GetCfg();
	local qua = cof.quality;
	local level = cof.level;
	--print(qua,level,"卧槽尼玛，这个值")
	return qua,level;
end

---------------------------图标飞效果-----------------------------------------
--飞入
function UIEquipProduct:FlyIn(fromPos)

	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(fromPos);
	if not item then return; end
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	local uiItem = objSwf.list:getRendererAt(fromPos);
	if not uiItem then return; end
	flyVO.startPos = UIManager:PosLtoG(uiItem.iconLoader,0,0);
	flyVO.endPos = UIManager:PosLtoG(objSwf.curEquipPro.iconLoader,0,0);
	flyVO.time = 0.5;
	flyVO.url = BagUtil:GetItemIcon(item:GetTid(),true);
	flyVO.onStart = function(loader)
		loader._width = 40;
		loader._height = 40;
		uiItem.hide = true;
		objSwf.curEquipPro.hide = true;
	end
	flyVO.tweenParam = {};
	flyVO.tweenParam._width = 54;
	flyVO.tweenParam._height = 54;
	flyVO.onUpdate = function()
	objSwf.curEquipPro.hide = true;
	uiItem.hide = true;
	end
	flyVO.onComplete = function()
		objSwf.curEquipPro.hide = false;
	end
	FlyManager:FlyIcon(flyVO);
end

--飞出
function UIEquipProduct:FlyOut(toPos,bo)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	local uiItem = objSwf.list:getRendererAt(toPos);
	if not uiItem then return; end
	if bo == true then 
		flyVO.startPos = UIManager:PosLtoG(objSwf.curEquipProMaxLvl.iconLoader,0,0);
	else
		flyVO.startPos = UIManager:PosLtoG(objSwf.curEquipPro.iconLoader,0,0);
	end;

	flyVO.endPos = UIManager:PosLtoG(uiItem.iconLoader,0,0);
	flyVO.time = 0.5;
	flyVO.url = BagUtil:GetItemIcon(item:GetTid(),true);
	flyVO.onStart = function(loader)
		loader._width = 54;
		loader._height = 54;
	end
	flyVO.tweenParam = {};
	flyVO.tweenParam._width = 40;
	flyVO.tweenParam._height = 40;
	flyVO.onComplete = function()
		uiItem.hide = false;
	end
	FlyManager:FlyIcon(flyVO);
end

function UIEquipProduct:OnHide()
	-- 清空上一次的数据
	if self.objSwf then
	self.objSwf.curEquipPro:setData(UIData.encode({}));  --显示 
	self.objSwf.curEquipProMaxLvl:setData(UIData.encode({}));  --显示 
	end;	
	self.currPos = nil;

	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self:init();
end

function UIEquipProduct:OnDelete()
	if self.objUIDraw then 
		self.objUIDraw:SetUILoader(nil);
	end;
end;

--画模型
function UIEquipProduct:DrawRole()
	local uiLoader = self.objSwf.roleLoaderProdut;

	
	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf
	vo.arms = info.dwArms
	vo.dress = info.dwDress
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = info.dwFashionsHead
	vo.fashionsArms = info.dwFashionsArms
	vo.fashionsDress = info.dwFashionsDress
	vo.wuhunId = 0;--SpiritsModel:GetFushenWuhunId()
	vo.wing = info.dwWing
	vo.suitflag = info.suitflag
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;	
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(vo);
	--
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
    if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("rolePanelPlayerProduct", self.objAvatar, uiLoader,
							UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos,
							0x00000000,"UIRole", prof);
	else
		self.objUIDraw:SetUILoader(uiLoader);
		self.objUIDraw:SetCamera(UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
	self.objAvatar:PlayLianhualuAction()
end


--------- 引导
function UIEquipProduct:GetAutoProductBtn()
	if not self:IsShow() then return end;
	return self.objSwf.btnAutoProduct;
end;

function UIEquipProduct:GetProductBtn()
	if not self:IsShow() then return; end
	return self.objSwf.btnPrpduct;
end

function UIEquipProduct:OnSetGuideEquip()
	--print('调用， OnSetGuideEquip   835')
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	local roleEquip = bagVO:GetItemListByShowType(BagConsts.ShowType_Equip);
	local endpos = 0;
	for i,info in ipairs(roleEquip) do 
		local pos = info.pos;
		local cfg = t_equip[info:GetTid()];
		if cfg.quality < BagConsts.Quality_Lilac then 
			endpos = info.pos;
			break;
		end;
	end;
	local objSwf = self.objSwf;
	--  设置当前装备
	if not objSwf then return end;
	self.curpos = endpos;
	self:OnAutoSelectEquip(endpos,true)
 	--   设置一键吞噬，为蓝色
	self.curAutoproduct = BagConsts.Quality_Blue;
	self.objSwf.ddList.selectedIndex = self.curAutoproduct;
	--print("自动选择装备，调用 引导")
	--self:AutoProdu();
end;

----------------------------------  点击任务接口 ----------------------------------------

function UIEquipProduct:OnGuideClick()
	QuestController:TryQuestClick( QuestConsts.EquipProductClick ) 
end

------------------------------------------------------------------------------------------



----------------------------------选择吞噬装备接口
function UIEquipProduct:SelecteProductEquip(list)
	if not self.bShowState then return; end
	for bag,item in ipairs(self.baglist) do 
		for i,info in ipairs(list) do 
			if info == item.tid then
				item.state = true;
			end;
		end;
	end;
	self:ShowSelectequipList();
end;

function UIEquipProduct:ShowSelectequipList()
	local objSwf = self.objSwf;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag)
	for i,a in ipairs(self.baglist) do
		if a.state == true then 
			local item = bagVO:GetItemByPos(a.pos);
			local uiData = UIData.encode(a);
			self.objSwf.baglist.dataProvider[i-1] = uiData;
			local uiItem = self.objSwf.baglist:getRendererAt(i-1);
			if uiItem then
				uiItem:setData(uiData);
			end;
			local voc = {};
			voc.id = item:GetId();
			voc.tid = item:GetTid();
			table.push(self.curProductList,voc)
		end;
	end;
 	-- 更新进度条
 	--print('选中状态list  918  lin')
	self:CurAddinfo()
end;
