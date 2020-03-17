--[[
装备分解
wangshuai
]]
_G.UIEquipDecomp = BaseUI:new("UIEquipDecomp")

UIEquipDecomp.AutoDecompList = {};

UIEquipDecomp.ToCrushList = {};-- 要粉碎的装备

UIEquipDecomp.RewardItemListC = {} -- 奖励预览

UIEquipDecomp.BagListVo = {};
UIEquipDecomp.BagHasEquip = false;--背包列表是否有装备
UIEquipDecomp.FenjieHasEquip = false;--分解列表是否有装备
UIEquipDecomp.IsDecompRewardlist = false;


function UIEquipDecomp:Create()
	self:AddSWF("smithingFenjiePanel.swf",true,nil)
end;
 
function UIEquipDecomp:OnLoaded(objSwf)

	objSwf["quality"..1].visible = false
	objSwf["quality"..4].visible = false
	objSwf["quality"..5].visible = false
	
	-- 品质勾选框
	for qu=1,8 do 
		objSwf["quality"..qu].textField.text = StrConfig['smithing0'..qu] ;
		objSwf["quality"..qu].click =function() self:FunQualityClick(qu) end;
	end;

	objSwf.autoSave.click = function() self:FunAutoSaveEquip()end;
	objSwf.godecomp.click = function() self:FunGoGoDecomp()end;

	objSwf.baglist.itemClick = function(e) self:FunBagListClick(e)end;
	objSwf.baglist.itemRollOver = function(e) self:FunBagListOver(e)end;
	objSwf.baglist.itemRollOut = function() TipsManager:Hide();end;

	objSwf.decomplist.itemClick = function(e) self:FunDecompListClick(e)end;
	objSwf.decomplist.itemRollOver = function(e) self:FunBagListOver(e)end;
	objSwf.decomplist.itemRollOut = function() TipsManager:Hide();end;
	
	RewardManager:RegisterListTips(objSwf.rewardlist);
	
	objSwf.rult.rollOver = function() TipsManager:ShowBtnTips(StrConfig['equipbuild103'],TipsConsts.Dir_RightDown); end
	objSwf.rult.rollOut = function() TipsManager:Hide(); end

end;

function UIEquipDecomp:OnShow()
	-- print('---------------UIEquipDecomp:OnShow()')
	self.IsDecompRewardlist = true;
	--  初始信息
	self:InitInfo()

	-- 初始化品质选择框
	self:FunInitAutoDecompList();
	-- 初始化背包装备
	self:FunShowList()
end

function UIEquipDecomp:OnHide()
	-- print('---------------UIEquipDecomp:OnHide()')
	self:InitInfo();
	self.IsDecompRewardlist = false;
	self.FenjieHasEquip = false
	self.BagHasEquip = false
end;

-- 初始化信息
function UIEquipDecomp:InitInfo()
	UIEquipDecomp.AutoDecompList = {};
	UIEquipDecomp.ToCrushList = {};-- 要粉碎的装备
	UIEquipDecomp.RewardItemListC = {};
	local objSwf = self.objSwf;

	objSwf.decomplist.dataProvider:cleanUp();
	objSwf.decomplist.dataProvider:push(unpack({}));
	objSwf.decomplist:invalidateData();

	objSwf.baglist.dataProvider:cleanUp();
	objSwf.baglist.dataProvider:push(unpack({}));
	objSwf.baglist:invalidateData();

	objSwf.rewardlist.dataProvider:cleanUp();
	objSwf.rewardlist.dataProvider:push(unpack({}));
	objSwf.rewardlist:invalidateData()
end;
--UIEquipDecomp.ToCrushList = {};-- 要粉碎的装备
--UIEquipDecomp.RewardItemListC = {} -- 奖励预览
-- 奖励碎片预览
function UIEquipDecomp:FunDecompRewardPreview()
	local objSwf = self.objSwf;
	local list = {};
	local list1 = {};
	for i,info in pairs(self.ToCrushList) do 
		local cfg = t_equip[info:GetTid()];
		local id = 100000 + (cfg.pos * 1000) + (cfg.level * 10) + cfg.quality;
		local decompCfg = t_decompose[id];
		if decompCfg then 
			local cfglist = split(decompCfg.result1,"#");
			for i,info in pairs(cfglist) do 
				local itemlist = split(info,",")
				if list[itemlist[1]] then 
					local vo = list[itemlist[1]];
					vo.num = vo.num + itemlist[2];
				else
					local vo  = {};
					vo.id = itemlist[1];
					vo.num = itemlist[2];
					list[itemlist[1]] = vo;
				end;
			end;
			
			local cfglist1 = split(decompCfg.result,"#");
			for j,info in pairs(cfglist1) do 
				local itemlist1 = split(info,",")
				if list1[itemlist1[1]] then 
					local vo = list1[itemlist1[1]];
					vo.num = vo.num + itemlist1[2];
				else
					local vo  = {};
					vo.id = itemlist1[1];
					vo.num = itemlist1[2];
					list1[itemlist1[1]] = vo;
				end;
			end;
		else
			print(debug.traceback("id at config is nil  == "..id))
		end;
	end;
	local listcoo = {};
	for i,info in pairs(list) do 
		local itemvo = RewardSlotVO:new()
		itemvo.id = toint(info.id);
		itemvo.count = toint(info.num);
		local vo = UIData.decode(itemvo:GetUIData());
		 vo.showCount = itemvo.count;
		table.push(listcoo,UIData.encode(vo));
		self.RewardItemListC[itemvo.id] = itemvo
	end;
	
	for i,info in pairs(list1) do 
		local itemvo = RewardSlotVO:new()
		itemvo.id = toint(info.id);
		itemvo.count = toint(info.num);
		local vo = UIData.decode(itemvo:GetUIData());
		vo.showCount = "?";
		table.push(listcoo,UIData.encode(vo));
		self.RewardItemListC[itemvo.id] = itemvo
	end;	
	
	objSwf.rewardlist.dataProvider:cleanUp();
	objSwf.rewardlist.dataProvider:push(unpack(listcoo));
	objSwf.rewardlist:invalidateData();

end;
-- 粉碎listClick
function UIEquipDecomp:FunDecompListClick(e)
	if not e.item then return end;
	if not e.item.myindex then return end;
	local myindex = e.item.myindex
	local item = self.ToCrushList[myindex];
	if not item then return end;
	table.push(self.BagListVo,item)
	self.ToCrushList[myindex] = nil;

	-- 刷新list
	self:FunShowToCreshList();
	self:FunUpdataShowList();
	self:FunDecompRewardPreview();
end;

-- 粉碎 list over
function UIEquipDecomp:FunDecompListOver(e)

end;

-- 背包移入
function UIEquipDecomp:FunBagListOver(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Bag,pos);
	if not itemTipsVO then return; end
	if not itemTipsVO.id or itemTipsVO.id == 0 then 
		print("ERROR: cur item at bag is nil,"..pos.."     ",debug.traceback())
		return 
	end;
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end;

-- 背包click
function UIEquipDecomp:FunBagListClick(e)
	if not e.item then return end;
	if not e.item.myindex then return end;
	local myindex = e.item.myindex
	local item = self.BagListVo[myindex];
	if not item then return end;
	-- 如果有套装石，不可放入
	if self:CheckHasGroupStone( item:GetId() ) then
		FloatManager:AddNormal( StrConfig["equipbuild104"] )
		return
	end
	self.BagListVo[myindex] = nil;
	table.push(self.ToCrushList,item)
	-- 刷新list
	self:FunShowToCreshList();
	self:FunUpdataShowList();
	self:FunDecompRewardPreview();
end;

function UIEquipDecomp:CheckHasGroupStone( id )
	local groupId2 = EquipModel:GetGroupId2(id) 
	return groupId2 and groupId2 > 0
end

-- 显示要粉碎的装备
function UIEquipDecomp:FunShowToCreshList()
	local objSwf = self.objSwf;
	local list = {};
	-- print('=====================-- 显示要粉碎的装备',#self.ToCrushList)
	if #self.ToCrushList==0 then
		self.FenjieHasEquip = false;
		self:ShowBtnEffect()
	end
	for k,item in pairs(self.ToCrushList) do
		table.push(list,UIData.encode(self:GetSlotVO(item,nil,k,1)));
	end
	objSwf.decomplist.dataProvider:cleanUp();
	objSwf.decomplist.dataProvider:push(unpack(list));
	objSwf.decomplist:invalidateData();	
end;
--播放按钮特效
function UIEquipDecomp:ShowBtnEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.FenjieHasEquip then
		-- print('====================FenjieHasEquip')
		objSwf.godecomp:showEffect(ResUtil:GetButtonEffect10());--开始分解按钮特效
		objSwf.autoSave:clearEffect();--一键放入按钮特效
	else
		-- print('====================not FenjieHasEquip')
		objSwf.godecomp:clearEffect();
		if not self.BagHasEquip then
			-- print('====================not BagHasEquip')
			objSwf.autoSave:clearEffect();
			return;
		end
		objSwf.autoSave:showEffect(ResUtil:GetButtonEffect10());
	end
end

--  一键存入
function UIEquipDecomp:FunAutoSaveEquip()
	local list = self.AutoDecompList;
	local vo = false;
	for i,info in pairs(list) do 
		if info == true then 
			vo = true;
		end;
	end;
	if vo == false then 
		FloatManager:AddNormal(StrConfig["equipbuild101"]);
		return
	end;
	if #self.BagListVo == 0 then 
		FloatManager:AddNormal(StrConfig["equipbuild102"]);
	end;
	for i,info in pairs(self.BagListVo) do 
		local cfg = info:GetCfg()
		local index = cfg.quality + 1;
		if list[index] == true then
			if not self:CheckHasGroupStone(info:GetId()) then
				table.push(self.ToCrushList,info)
			end
		end;
	end;
	for cao,ao in pairs(self.ToCrushList) do 
		local index = self:GetListIndex(ao);
		if index ~= -1 then 
			self.BagListVo[index] = nil
		end;
	end;
	-- 刷新list
	self:FunShowToCreshList();
	self:FunUpdataShowList();
	self:FunDecompRewardPreview();
end;

function UIEquipDecomp:GetListIndex(vo)
	for i,info in pairs(self.BagListVo) do 
		if info.id == vo.id then 
			return i;
		end;
	end;
	return -1;
end;

-- 确定分解
function UIEquipDecomp:FunGoGoDecomp()

	if #self.ToCrushList <= 0 then
		FloatManager:AddNormal(StrConfig["equipbuild013"]);
		return;
	end
	local list = {};
	for i,info in pairs(self.ToCrushList) do
		local vo = {};
		vo.guid = info.id;
		table.push(list,vo)
	end;
	EquipBuildController:ReqDecompEquip(list)
end;

-- 刷新背包
function UIEquipDecomp:FunUpdataShowList()
	local objSwf = self.objSwf;
	local list = {};
	if #self.BagListVo==0 then
		self.BagHasEquip = false;
		self:ShowBtnEffect()
	end
	for k,item in pairs(self.BagListVo) do
		table.push(list,UIData.encode(self:GetSlotVO(item,nil,k,0)));
	end
	objSwf.baglist.dataProvider:cleanUp();
	objSwf.baglist.dataProvider:push(unpack(list));
	objSwf.baglist:invalidateData();
end;
-- 显示背包
function UIEquipDecomp:FunShowList()
	local objSwf = self.objSwf;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local list = {};
	self.BagListVo = {};
	self.BagListVo = bagVO:GetEquipList()

	-- 同步粉碎list
	for i,info in pairs(self.ToCrushList) do 
		for ca,fu in pairs(self.BagListVo) do 
			if fu:GetId() == info:GetId() then 
				self.BagListVo[ca] = nil;
				break;
			end;
		end;
	end;
	if #self.BagListVo==0 then
		self.BagHasEquip = false;
		self:ShowBtnEffect()
	end
	for cao,a in pairs(self.BagListVo) do
		if t_equip[a:GetTid()].resolve then
			table.push(list,UIData.encode(self:GetSlotVO(a,nil,cao,0)));
		else
			self.BagListVo[cao] = nil
		end
	end;
	objSwf.baglist.dataProvider:cleanUp();
	objSwf.baglist.dataProvider:push(unpack(list));
	objSwf.baglist:invalidateData();
end;

--获取格子VO  背包列表：inType=0,分解列表：inType=1
function UIEquipDecomp:GetSlotVO(item,isBig,index,inType)
	-- WriteLog(LogType.Normal,true,'---------------------UILoadingScene:OnShow()',inType)
	local vo = {};
	vo.hasItem = true;
	vo.myindex = index;
	vo.pos = item:GetPos();
	vo.isBig = isBig and true or false;
	local isEquip = t_equip[item:GetTid()] and true or false
	if isEquip then
		if inType==0 then
			--判断背包列表是否有装备
			-- print('========================背包列表是有装备')
			self.BagHasEquip = true;
		else
			--判断分解列表是否有装备
			-- print('========================分解列表是有装备')
			self.FenjieHasEquip = true;
		end
	end
	self:ShowBtnEffect();
	EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	return vo;
end

-- 初始化品质选择框
function UIEquipDecomp:FunInitAutoDecompList()
	local objSwf = self.objSwf;
	for ao=1,8 do 
		if ao == 2 or ao == 3 then
			self.AutoDecompList[ao] = true
		else
	 		self.AutoDecompList[ao] = false;
	 	end
	 	objSwf["quality"..ao].selected = self.AutoDecompList[ao]
	end;
end;

function UIEquipDecomp:FunQualityClick(i)
	self.AutoDecompList[i] = not self.AutoDecompList[i]
end;

function UIEquipDecomp:ListNotificationInterests()
	return {
		NotifyConsts.EquipDecompResult,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.BagRefresh,
	}
end

function UIEquipDecomp:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.EquipDecompResult then
		self:GetRewardFlyIcon()
		--  初始信息
		self:InitInfo()
		-- -- 初始化品质选择框
		self:FunInitAutoDecompList();
		-- 初始化背包装备
		self:FunShowList()
	elseif  name == NotifyConsts.BagAdd or name == NotifyConsts.BagRefresh then
		-- 初始化背包装备
		self:FunShowList()
	elseif name == NotifyConsts.BagRemove then 
		-- 初始化背包装备
		self:FunShowList()
		if self:GetEquipIsAtDecompList(body.id) then 
			self:FunShowToCreshList()
			self:FunDecompRewardPreview();
		end;
	elseif name == NotifyConsts.BagUpdate then 
		-- 初始化背包装备
		self:FunShowList()
		if self:GetEquipIsAtDecompList(body.id) then 
			self:FunShowToCreshList()
			self:FunDecompRewardPreview();
		end;
	end
end

function UIEquipDecomp:GetEquipIsAtDecompList(uid)
	for i,info in pairs(self.ToCrushList) do 
		local id = info:GetId();
		if id == uid then 
			self.ToCrushList[i] = nil
			return true;
		end;
	end;
	return false;
end;

function UIEquipDecomp:GetRewardFlyIcon()
	local objSwf = self.objSwf;
	local startPos = UIManager:PosLtoG(objSwf.rewardlist,0,0);

	local list = {};
	--trace(self.RewardItemListC)
	for i,info in pairs(self.RewardItemListC) do 
		local vo = {};
		vo.bind = 0;
		vo.id = info.id;
		vo.count = 1;
		table.push(list,vo)
	end;
	RewardManager:FlyIcon(list,startPos,5,false,44,45);
end;
