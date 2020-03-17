--[[
帮派仓库主界面
wangshuai
]]

_G.UIUnionWareHouseDonation = BaseUI:new("UIUnionWareHouseDonation")

UIUnionWareHouseDonation.bagList = {};
UIUnionWareHouseDonation.wareHoueList = {};
UIUnionWareHouseDonation.equipMoney = 0; --  装备评分熔炼用，就是帮派资金
UIUnionWareHouseDonation.takeeuqipcont = 0;
UIUnionWareHouseDonation.saveeuqipcont = 0;
UIUnionWareHouseDonation.curIsSmlting = false;
function UIUnionWareHouseDonation:Create()
	self:AddSWF("unionWarehouseDonation.swf",nil,true)
end;

function UIUnionWareHouseDonation:OnLoaded(objSwf)
	objSwf.baglist.itemClick = function (e) self:OnBagListitemClick(e);end;
	objSwf.baglist.itemRollOver = function (e) self:OnBAgListRollover(e);end;
	objSwf.baglist.itemRollOut = function (e) TipsManager:Hide();end;

	objSwf.warelist.itemClick = function (e) self:OnWarelistClick(e);end;
	objSwf.warelist.itemRollOver = function (e) self:OnWareRollover(e);end;
	objSwf.warelist.itemRollOut = function () TipsManager:Hide();end;

	objSwf.smeltingbtn.click = function() self:OnSmeltingClick() end;
	objSwf.sure.click = function() self:OnSmelSureClick() end;
	objSwf.cancel.click = function() self:OnSmelCancelClick ()end;
	self.equipMoney = t_consts[54].val1 -- 帮派资金倍率
	self.saveeuqipcont = t_consts[54].val2 -- 存入倍率
	self.takeeuqipcont = t_consts[54].val3 -- 取出倍率

	objSwf.zhongcheng_txt.rollOver = function() self:OnShowZhongChengtips()end;
	objSwf.zhongcheng_txt.rollOut  = function() TipsManager:Hide()end;
end;

function UIUnionWareHouseDonation:OnShowZhongChengtips()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	TipsManager:ShowBtnTips(StrConfig["unionwareHouse511"],TipsConsts.Dir_RightDown);
end;

function UIUnionWareHouseDonation:OnShow()
	self:OninitFun(); -- 显示初始化
	self:OnLeader() -- 是否城主
	self:ShowWareHouseList(); -- 显示仓库list
	self:ShowBagList(); -- 显示背包list
	self:OnContValu(); --设置贡献值
	self:OnSetUnionNum(); -- 帮派格子数
end;
-- show初始化方法
function UIUnionWareHouseDonation:OninitFun()
	local objSwf =self.objSwf;
	objSwf.mcQuickSell._visible = false;
	objSwf.sure._visible = false;
	objSwf.cancel._visible = false;
	self.curIsSmlting = false;
	objSwf.waerscrollBar.position = 0
	objSwf.bagscrollBar.position = 0
end;
--是否帮主
function UIUnionWareHouseDonation:OnLeader()
	local objSwf = self.objSwf;
	local isleader = UnionModel:IsLeader()
	if isleader == true then 
		objSwf.smeltingbtn._visible = true;
	else
		objSwf.smeltingbtn._visible = false;
	end;
end;

--  熔炼按钮
function UIUnionWareHouseDonation:OnSmeltingClick()
	local objSwf = self.objSwf
	objSwf.sure._visible = true;
	objSwf.cancel._visible = true;
	objSwf.mcQuickSell._visible = true;
	objSwf.smeltingbtn._visible = false;
	self.curIsSmlting = true;
end;

-- 显示背包物品
function UIUnionWareHouseDonation:ShowBagList()
	local objSwf = self.objSwf;
	local bagVo = BagModel:GetBag(BagConsts.BagType_Bag);
	local listvo = bagVo:GetItemListByShowType(BagConsts.ShowType_All)
	local list = {};
	for i,info in pairs(listvo) do
		if info:GetTid() then 
			-- if t_equip[info:GetTid()] then 
				-- if info:GetBindState() ~= BagConsts.Bind_Bind then 
					-- local cfg = t_equip[info:GetTid()];
					-- if cfg then 
						-- if cfg.quality >= BagConsts.Quality_Green2 then 
							-- table.push(list,info)
						-- end;
					-- end;
				-- end;
			-- elseif t_item[info:GetTid()] then 
				-- if info:GetBindState() ~= BagConsts.Bind_Bind then 
					-- local cfg = t_item[info:GetTid()];
					-- if cfg then 
						-- if cfg.isEnterUnion > 0 then 
							-- table.push(list,info)
						-- end;
					-- end;
				-- end;
			-- end;
			for ca,fu in pairs(t_guildblank) do 
				if fu.id == info:GetTid() and info:GetBindState() ~= BagConsts.Bind_Bind then 
					table.push(list,info)
				end;
			end;
		end;
	end;
	self.baglist = {};
	objSwf.baglist.dataProvider:cleanUp();
	for i,info in ipairs(list) do
		local id = info:GetId();
		local pos = info:GetPos();
		local item = bagVo:GetItemByPos(pos);
		local vo = {};
		vo.pos = pos;
		vo.id = id;
		vo.tid = item:GetTid()
		if t_equip[item:GetTid()] then 
			EquipUtil:GetDataToEquipUIVO(vo,item,false)
		elseif t_item[item:GetTid()] then 
			--vo.iconUrl = BagUtil:GetItemIcon(item:GetTid(),isBig);
			vo.qualityUrl = ResUtil:GetSlotQuality(t_item[item:GetTid()].quality);
			vo.quality = t_item[item:GetTid()].quality;
			vo.strenLvl = 0
			vo.super = 0;
			vo.count = item:GetCount();
			--vo.showBind = item:GetBindState()==BagConsts.Bind_GetBind or item:GetBindState()==BagConsts.Bind_Bind;
		end
		vo.iconUrl = BagUtil:GetItemIcon(item:GetTid());
		vo.state = false;
		vo.tipbo = true;
		table.push(self.baglist,vo);
		objSwf.baglist.dataProvider:push(UIData.encode(vo));
	end;
	objSwf.baglist:invalidateData();
	--objSwf.baglist:scrollToIndex(0);
end;
-- 背包click  存入装备
function UIUnionWareHouseDonation:OnBagListitemClick(e)
	local item = e.item;
	-- print("--存入第一步")
	if not item then return end;
	-- print("--存入第二步")
	local id = e.item.id
	if not id then return end;
	-- print("--存入第三步")
	local maxin = UnionModel:GetUnionInfoDo().maxIn;
	if maxin <= 0 then 
		FloatManager:AddNormal(StrConfig["unionwareHouse507"]);
		return
	end;

	local backFun = function(num) 
		UnionController:ReqWareHouseSaveItem(id,num)
	end;
	if UIWarehouseWindow:SetItemUid(e.item.tid,e.item.count,backFun,1) then 
		return 
	end;
	UnionController:ReqWareHouseSaveItem(id,0)
	--
end;
-- 背包移入
function UIUnionWareHouseDonation:OnBAgListRollover(e)
	if not e.item then return end;
	--if e.renderer:GetIsData() == false then return end;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	local item = bagVO:GetItemByPos(e.item.pos);

	if not item then print("item为空") return end;

	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Bag,e.item.pos);
	if not itemTipsVO then return; end
	item.strenLvl = EquipModel:GetStrenLvl(item:GetId());
	item.attrAddLvl = EquipModel:GetExtraLvl(item:GetId());
	itemTipsVO.contrState = 2; -- 存入
	local bo,val = UnionUtils:GetCurEquipScore(item)
	itemTipsVO.contrVla = val * self.saveeuqipcont;
	itemTipsVO.isUnionContr = true;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;
--function ItemTipsUtil:GetItemTipsVO(id,count,bind)

-- 显示仓库物品
function UIUnionWareHouseDonation:ShowWareHouseList()
	local objSwf =self.objSwf;
	self.wareHoueList = {};
	local itemlist = UnionModel:GetItemList()
	local list = {};
	for i,info in pairs(itemlist) do 
		local vo ={};
		vo.pos = 0;
		vo.tid = info.cid;
		vo.uid = info.uid;
		vo.isApply = info.apply or 0;
		
		if t_equip[info.cid] then 
			--EquipUtil:GetDataToEquipUIVO(vo,item,false)
			vo.qualityUrl = ResUtil:GetSlotQuality(t_equip[info.cid].quality);
			vo.quality = t_equip[info.cid].quality;
			vo.attrAddLvl = info.attrAddLvl;
			vo.superNum = info.superNum;
			vo.super = 0;
			if vo.quality == BagConsts.Quality_Green2 then
				vo.super = 2;
			elseif vo.quality == BagConsts.Quality_Green3 then
				vo.super = 3;
			end
			vo.strenLvl = info.strenLvl--EquipModel:GetStrenLvl(item:GetId());
		elseif t_item[info.cid] then 
			--vo.iconUrl = BagUtil:GetItemIcon(info.cid,false);
			vo.qualityUrl = ResUtil:GetSlotQuality(t_item[info.cid].quality);
			vo.quality = t_item[info.cid].quality;
			vo.strenLvl = 0
			vo.count = info.strenLvl
			--vo.showBind = item:GetBindState()==BagConsts.Bind_GetBind or item:GetBindState()==BagConsts.Bind_Bind;
		end
		vo.iconUrl = BagUtil:GetItemIcon(info.cid);
		vo.showBind = false;
		vo.state = false;
		vo.tipbo = true;
		table.push(list,UIData.encode(vo))
		table.push(self.wareHoueList,vo)
	end;
	local curleng = UnionModel:GetListLenght(self.wareHoueList)+1;
	local unionLvl = UnionModel:GetMyUnionLevel();
	local allnum = t_guild[unionLvl].warehouse;
	for i=curleng,allnum do 
		table.push(list,UIData.encode({}));
	end;
	objSwf.warelist.dataProvider:cleanUp();
	objSwf.warelist.dataProvider:push(unpack(list));
	objSwf.warelist:invalidateData();
end;

-- 仓库click
function UIUnionWareHouseDonation:OnWarelistClick(e)
	local item = e.item;
	if not item then return end;
	if not item.uid then return end;
	if item.isApply == 1 then return end
	
	if self.curIsSmlting == true then 
		-- 多选熔炼
		self:OnSmeltingItem(item);
	else -- 单选取出
		self:OnTakeItem(item)
	end;
	--UnionController:ReqWareHouseTakeItem(item.uid)
end;
-- 多选熔炼
function UIUnionWareHouseDonation:OnSmeltingItem(item)
	local objSwf = self.objSwf;
	local curid = item.uid;
	if not curid then return end;
	for i,vo in ipairs(self.wareHoueList) do 
		if t_item[vo.tid] then 
			FloatManager:AddNormal( StrConfig["unionwareHouse508"] );
			return 
		end; 
		if vo.uid == curid then 
			vo.state = not vo.state;
			local uiData = UIData.encode(vo);
			objSwf.warelist.dataProvider[i-1] = uiData;
			local uiItem = objSwf.warelist:getRendererAt(i-1);
			if uiItem then 
				uiItem:setData(uiData);
			end;
			break;
		end;
	end;
end;

-- 熔炼确定
function UIUnionWareHouseDonation:OnSmelSureClick()
	local objSwf = self.objSwf
	--print("熔炼确定")
	objSwf.sure._visible = false;
	objSwf.cancel._visible = false;
	objSwf.mcQuickSell._visible = false;
	objSwf.smeltingbtn._visible = true;
	self.curIsSmlting = false;
	-- 确定熔炼
	local list =  {};
	local allmoney = 0;
	for i,info in ipairs(self.wareHoueList) do 
		if info.state == true then 
			local vo = {};
			allmoney = allmoney + (UnionUtils:GetCurEquipScore(info,true) * self.equipMoney);
			vo.uid = info.uid;
			table.push(list,vo)
		end;
	end;
	if allmoney >= 1 then 
		local okfun = function () self:OnSureSmelting(list); end;
		local nofun = function () self:OnSmelCancelClick() end;
		UIConfirm:Open(string.format(StrConfig["unionwareHouse504"],allmoney),okfun,nofun);
	end;
	
end;

function UIUnionWareHouseDonation:OnSureSmelting(list)
	--- 删除返回以后刷新
	UnionController:ReqWareHouseSmeliting(list)
	--UnionModel:OnWareHouseRemoveItem(list)
end;
-- 熔炼取消
function UIUnionWareHouseDonation:OnSmelCancelClick()
	local objSwf = self.objSwf
	--print("熔炼取消")
	objSwf.sure._visible = false;
	objSwf.cancel._visible = false;
	objSwf.mcQuickSell._visible = false;
	objSwf.smeltingbtn._visible = true;
	self.curIsSmlting = false;
	self:ShowWareHouseList()
end;
UIUnionWareHouseDonation.curIstipWindow = false;
-- 单选取出
function UIUnionWareHouseDonation:OnTakeItem(item)
	local uid = item.uid;
	if not uid then return end;
	if not item then return end;
	local item = self:GetCurWareHouseItem(uid)
	local curp = UnionUtils:GetCurEquipScore(item,true);
	local equipname = ""

	local xiaohao = "";
	local num = 0;
	if t_equip[item.tid] then 
		equipname = t_equip[item.tid].name
		xiaohao = curp*self.takeeuqipcont
		num = 1;
	elseif t_item[item.tid] then 
		local backFun = function(num) 
			equipname = t_item[item.tid].name
			xiaohao = (curp * num) * self.takeeuqipcont;
			num = num;
			if self.curIstipWindow == true then 
				self:OnSureTakeItem(true,uid,num)
				return 
			end;
			local okfun = function (bo) self:OnSureTakeItem(bo,uid,num); end;
			local nofun = function () end;
			UIConfirmWithNoTip:Open(string.format(StrConfig["unionwareHouse505"],equipname,num,xiaohao),okfun,nofun);
		end;
		if UIWarehouseWindow:SetItemUid(item.tid,item.count,backFun,2) then 
		 	return 
		end;
	end;
	if self.curIstipWindow == true then 
		self:OnSureTakeItem(true,uid,num)
		return 
	end;
	local okfun = function (bo) self:OnSureTakeItem(bo,uid); end;
	local nofun = function () end;
	UIConfirmWithNoTip:Open(string.format(StrConfig["unionwareHouse505"],equipname,num,xiaohao),okfun,nofun);
end;
function UIUnionWareHouseDonation:OnSureTakeItem(bo,uid,num)
	self.curIstipWindow = bo
	UnionController:ReqWareHouseTakeItem(uid,num)
end;
--仓库装备over
function UIUnionWareHouseDonation:OnWareRollover(e)
	local item = e.item
	if not item then return end;
	local id = e.item.tid;
	if not id then return end;
	local info = UnionModel.WareHouseItemList[item.uid];
	if not info then return; end
	local itemTipsVO = {};
	if t_equip[id] then 
		itemTipsVO = ItemTipsUtil:GetItemTipsVO(id,1,false)
		itemTipsVO.strenLvl = item.strenLvl;
		itemTipsVO.extraLvl = item.attrAddLvl;
		itemTipsVO.groupId = info.groupId;
		itemTipsVO.groupId2 = info.groupId2;
		itemTipsVO.groupId2Level = info.group2Level;
		itemTipsVO.superVO = {};
		itemTipsVO.superVO.superNum = info.superNum;
		itemTipsVO.superVO.superList = info.superList;
		itemTipsVO.newSuperList = info.newSuperList;
		itemTipsVO.contrState = 1;-- 取;
		itemTipsVO.contrVla = UnionUtils:GetCurEquipScore(item,true) * self.takeeuqipcont;
	elseif t_item[id] then 
		 itemTipsVO = ItemTipsUtil:GetItemTipsVO(id,info.strenLvl,false)
	end;

	--print(itemTipsVO.contrVla,"取出需要这个额，",self.takeeuqipcont,UnionUtils:GetCurEquipScore(item,true))
	itemTipsVO.isUnionContr = true;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end; 

-- 贡献值
function UIUnionWareHouseDonation:OnContValu()
	local vla = UnionModel:GetMyloyalty()
	--UnionModel.MyUnionInfo.contribution;
	self.objSwf.txthonor.text = UnionModel.MyUnionInfo.contribution;

	local maxin = UnionModel:GetUnionInfoDo().maxIn or 0;
	self.objSwf.txtMaxIn.text = maxin
end;
-- 帮派仓库格子数量
function UIUnionWareHouseDonation:OnSetUnionNum()
	local unionLvl = UnionModel:GetMyUnionLevel();
	local allnum = t_guild[unionLvl].warehouse;
	local curnum = UnionModel:GetListLenght(self.wareHoueList);
	local txt = string.format(StrConfig["unionwareHouse503"],curnum,allnum)
	self.objSwf.txtNum.text = txt;
end;

-- 根据当前uid，取出我存的装备
function UIUnionWareHouseDonation:GetCurWareHouseItem(uid)
	for i,info in ipairs(self.wareHoueList) do 
		if info.uid == uid then 
			return info
		end
	end;
end;
--------------------------Notification
function UIUnionWareHouseDonation:ListNotificationInterests()
	return {
			NotifyConsts.UnionWareHouseItemUpdate,
			NotifyConsts.UpdateContribute,
			NotifyConsts.BagAdd,
			NotifyConsts.BagRemove,
			NotifyConsts.BagUpdate,
			NotifyConsts.BagRefresh,
			};
end
function UIUnionWareHouseDonation:HandleNotification(name,body)
	if not self.bShowState then return; end

	if name == NotifyConsts.UnionWareHouseItemUpdate then 
		--print("收到item更新")
		self:ShowWareHouseList();
		self:ShowBagList();
		self:OnSetUnionNum();
		self:OnContValu();
	elseif name == NotifyConsts.UpdateContribute then 
		self:OnContValu();
	elseif name == NotifyConsts.BagAdd 
		or name == NotifyConsts.BagRemove 
		or name == NotifyConsts.BagUpdate 
		or name == NotifyConsts.BagRefresh then 
		--print("收到item更新")
		--self:ShowWareHouseList();
		self:ShowBagList();
		self:OnSetUnionNum();
		self:OnContValu();
	end;
end;


function UIUnionWareHouseDonation:OnHide()

end;

function UIUnionWareHouseDonation:TextInfoClick()
	local list = {};
	for i=0,10,2 do 
		local vo = {};
		vo.uid = "0000000_12345"..i
		vo.cid = 220604000 + i;
		vo.strenLvl = math.random(20);
		vo.attrAddLvl = math.random(3);
		vo.superNum = 1;

		vo.superList = {};
		vo.superList[1] = {};
		vo.superList[1].val2 = 0;
		vo.superList[1].val1 = 7;
		vo.superList[1].uid = "1125898_1428504023";
		vo.superList[1].id = 2011;
		table.push(list,vo)
	end;
	UnionModel:OnWareHouseRemoveItem(list)
end;

function UIUnionWareHouseDonation:OnTextInfoClck2()
	local list = {};
	for i=0,10,2 do 
		local vo = {};
		vo.uid = "0000000_12345"..i
		vo.cid = 220604000 + i;
		vo.strenLvl = math.random(20);
		vo.attrAddLvl = math.random(3);
		vo.superNum = 1;

		vo.superList = {};
		vo.superList[1] = {};
		vo.superList[1].val2 = 0;
		vo.superList[1].val1 = 7;
		vo.superList[1].uid = "1125898_1428504023";
		vo.superList[1].id = 2011;
		table.push(list,vo)
	end;
	UnionModel:OnWareHouseAddItem(list)
end;


