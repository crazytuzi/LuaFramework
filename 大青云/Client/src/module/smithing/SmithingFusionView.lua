--[[
装备融合界面
houxudong
2016年5月4日18:13:04 
]]

_G.UISmithingFusion = BaseUI:new("UISmithingFusion");
UISmithingFusion.currSelect = nil;

UIEquipDecomp.EquipOneHave = true     		--控制第一个位置是否有装备
UIEquipDecomp.EquipTwoHave = false 			--同时控制第一个位置和第三个位置
-------------卓越属性id-------------
UISmithingFusion.itemProf1 = 0;             --第一个装备位的两条属性
UISmithingFusion.itemProf2 = 0;  

UISmithingFusion.itemProf3 = 0;             --第二个装备位的两条属性
UISmithingFusion.itemProf4 = 0;
-------------分别用来存储角色装备和背包装备-------------
UIEquipDecomp.RoleListVo = {};      		--临时角色装备道具
UIEquipDecomp.BagListVo = {};     			--临时背包装备道具

-------------发给服务器的字段-------------
UISmithingFusion.guidOne = 0       			--装备cid
UISmithingFusion.guidTwo = 0
UISmithingFusion.bagTypeOne = 0    			--背包类型
UISmithingFusion.bagTypeTwo = 0

UISmithingFusion.roleEuipCount = 0         	--角色装备数量 
UISmithingFusion.BagEuipCount = 0         	--背包装备数量
UISmithingFusion.currentNum = 0  			--道具当前数量
UISmithingFusion.totalNum = 0				--道具总数量
UISmithingFusion.lv = 0           			--装备阶数
UISmithingFusion.pos = 0           			--装备位置
UISmithingFusion.equipOneSelect  = false    --装备第一位置
UISmithingFusion.equipTwoSelect  = false    --装备第二位置
UISmithingFusion.equipPropSelect = false    --装备预览位置
UISmithingFusion.spendCost = 0              --消耗银两
-----------------------------------------
UISmithingFusion.mergeid = 0    			--合成后预览id

function UISmithingFusion:Create()
	self:AddSWF("smithingRonghePanel.swf",true,nil);
end

function UISmithingFusion:OnLoaded(objSwf)
	objSwf.roleEquipList.itemClick = function(e) self:OnBodyEquipClick(e); end
	objSwf.roleEquipList.itemRollOver = function(e) self:OnBodyEquipOver(e); end
	objSwf.roleEquipList.itemRollOut = function(e) TipsManager:Hide(); end

	objSwf.bagList.itemClick = function(e) self:OnBagEquipClick(e); end
	objSwf.bagList.itemRollOver = function(e) self:OnBagEquipOver(e); end
	objSwf.bagList.itemRollOut = function(e) TipsManager:Hide(); end

	objSwf.tfNeedItem.rollOver = function(e) self:OnCostItemOver(e) end
	objSwf.tfNeedItem.rollOut = function(e) TipsManager:Hide() end

	objSwf.btnRonghe.click = function(e) self:OnFusionClick(e); end
	
	objSwf.btnRules.rollOver =  function() TipsManager:ShowBtnTips(StrConfig['equipbuild103'],TipsConsts.Dir_RightDown); end  ---equipbuild103规则由策划配置到strConfig里面
	objSwf.btnRules.rollOut = function(e) TipsManager:Hide(); end

	objSwf.effect.itempanel.iconEquip1.click = function (e) self:OnEquipOneClick(e); end
	objSwf.effect.itempanel.iconEquip1.rollOver = function(e) self:OnEquipOneOver(e); end
	objSwf.effect.itempanel.iconEquip1.rollOut = function(e) TipsManager:Hide(e); end	

	objSwf.effect.itempanel.iconEquip2.click = function (e) self:OnEquipTwoClick(e); end
	objSwf.effect.itempanel.iconEquip2.rollOver = function(e) self:OnEquipTwoOver(e); end
	objSwf.effect.itempanel.iconEquip2.rollOut = function() TipsManager:Hide(); end

	objSwf.effect.itempanel.iconPreview.rollOver = function() self:OnEquipPreviewOver(); end
	objSwf.effect.itempanel.iconPreview.rollOut = function() TipsManager:Hide(); end	
end

function UISmithingFusion:OnShow( )
	-- 初始信息
	self:ClearInfoView();

	--初始化角色装备 
	self:ShowBodyEquips(); 

	--初始化背包装备   
	self:ShowBagEquips();

	--播放动画
	self:PlayEffect();

end

--播放动画
function UISmithingFusion:PlayEffect( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.effect:play()
end

----------------------------------------界面右侧显示处理----------------------------------------
--角色装备
function UISmithingFusion:ShowBodyEquips( )
	local RoleBagVO = BagModel:GetBag(BagConsts.BagType_Role);   
	self.RoleListVo = RoleBagVO:GetItemListByShowType(BagConsts.ShowType_Equip);
	self:ChooseEquipList(self.RoleListVo,self.objSwf.roleEquipList);
end

--背包装备
function UISmithingFusion:ShowBagEquips( )
	local Bag = BagModel:GetBag(BagConsts.BagType_Bag);
	self.BagListVo = Bag:GetItemListByShowType(BagConsts.ShowType_Equip);  --根据显示分类获取物品列表
	self:ChooseEquipList(self.BagListVo,self.objSwf.bagList);
end

--过滤装备列表
function UISmithingFusion:ChooseEquipList(equips,list)
	if not list or not equips then
		return;
	end
	list.dataProvider:cleanUp();  
	for index,equip in ipairs(equips) do
		local config = equip:GetCfg();
		if config.quality == 6 then   --装备的品质为6
			self.lv = config.level
			self.pos = config.pos
			local view = self:GetEquipViewData(equip,nil,index);
			list.dataProvider:push(UIData.encode(view));
		end
	end
	list:invalidateData();
end

--获取格子VO
function UISmithingFusion:GetEquipViewData(equip,isBig,index)
	local vo = {};
	if equip then
		vo.hasItem = true;
		vo.bagType = equip:GetBagType();
		vo.pos = equip:GetPos();
		vo.isBig = false;
		vo.myindex = index;   --位置
		EquipUtil:GetDataToEquipUIVO(vo,equip,isBig);
	else
		vo.hasItem = false;
	end
	return vo;
end

----------------------------------------------------------------------------------------------


-------------------------------------点击，悬浮事件-------------------------------------------
---角色装备
function UISmithingFusion:OnBodyEquipClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not e.item then return; end
	if not e.item.myindex then return end;
	local myindex = e.item.myindex
	-- print("当前所处的位置:",myindex)
	local chooseItem = self.RoleListVo[myindex]   --当前选择的item
	self.currSelect = chooseItem
	if self:InitRightItem() then
		table.remove(self.RoleListVo, myindex)
		self:ChooseEquipList(self.RoleListVo,objSwf.roleEquipList);
	else
		print("The Right TwoEquip is all have init")
	end
end

function UISmithingFusion:OnBodyEquipOver(e)
	if not e.item then
		return;
	end
	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	local item = bag:GetItemByPos(e.item.pos);
	if item then
		TipsManager:ShowBagTips(BagConsts.BagType_Role,item.pos);	
	end
end

---背包装备
function UISmithingFusion:OnBagEquipClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not e.item then return; end
	if not e.item.myindex then return end;
	local myindex = e.item.myindex
	-- print("当前所处的位置:",myindex)
	local chooseItem = self.BagListVo[myindex]
	self.currSelect = chooseItem
	if self:InitRightItem() then
		table.remove(self.BagListVo, myindex)
		self:ChooseEquipList(self.BagListVo,self.objSwf.bagList);
	else
		print("The Right TwoEquip is all have init")
	end
	
end

function UISmithingFusion:OnBagEquipOver(e)
	if not e.item then
		return;
	end
	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
	local item = bag:GetItemByPos(e.item.pos);
	if item then
		TipsManager:ShowBagTips(BagConsts.BagType_Bag,item.pos);	
	end
end

--消耗物品
function UISmithingFusion:OnCostItemOver(e)
	if not self.currSelect then
		return;
	end
	local itemId = self.currSelect.tid
	local config = t_fuse[itemId];
	if not config then return; end
	TipsManager:ShowItemTips(config.item);
end

----------------------------------------------------------------------------------------------
function UISmithingFusion:getSelectVo()
	local config = t_equip[self.currSelect:GetTid()]
	local data = {}
	data.id = config.id;
	data.count = self.currSelect:GetCount();
	data.showCount = "";
	data.iconUrl = ResUtil:GetItemIconUrl(config.icon);
	data.bigIconUrl = ResUtil:GetItemIconUrl(config.icon,54);
	data.iconUrl64 = ResUtil:GetItemIconUrl(config.icon,64);
	data.bind = self.currSelect:GetBindState();
	data.showBind = data.bind==BagConsts.Bind_GetBind or data.bind==BagConsts.Bind_Bind
	data.qualityUrl = ResUtil:GetSlotQuality(config.quality);
	data.bigQualityUrl = ResUtil:GetSlotQuality(config.quality, 54)
	data.qualityUrl64 = ResUtil:GetSlotQuality(config.quality, 64)
	data.quality = config.quality
	data.isBlack = false;
	data.super = 0;
	if data.quality == BagConsts.Quality_Green2 then
		data.super = 2;
	elseif data.quality == BagConsts.Quality_Green3 then
		data.super = 3;
	end
	data.strenLvl = EquipModel:GetStrenLvl(self.currSelect:GetId());
	data.biaoshiUrl = ResUtil:GetBiaoShiUrl(config.identifying)
	data.bigBiaoshiUrl = ResUtil:GetBiaoShiUrl(config.identifying, 54)
	data.biaoshiUrl64 = ResUtil:GetBiaoShiUrl(config.identifying, 64)
	return UIData.encode(data)
end


-------------------------------------------右侧界面处理----------------------------------------
---刷新右侧显示
function UISmithingFusion:InitRightItem()
	if not self.currSelect then   
		return false;
	end

	local NewAttrId = {}
	local equip = SmithingModel:GetEquipAttrInfo(self.currSelect);     --获得装备的卓越属性
	for i,vo in ipairs(equip.newSuperList) do
		table.insert(NewAttrId,vo.id)
	end
	for k,v in pairs(NewAttrId) do                                     --测试用，后期删除
		print(k,v)
	end
	--如果第一个融合装备位没有装备
	if not self.equipOneSelect then   --if self.EquipOneHave then
		self.objSwf.effect.itempanel.iconEquip1:setData(UIData.encode(self:GetEquipViewData(self.currSelect))); 
		self.equipOneSelect = self.currSelect
		if self.currSelect.bagType == BagConsts.BagType_Role then      
			self.bagTypeOne = BagConsts.BagType_Role
		else
			self.bagTypeOne = BagConsts.BagType_Bag
		end
		self.guidOne = self.currSelect.id
		self.itemProf1 = NewAttrId[1]
		self.itemProf2 = NewAttrId[2]
		return true
	end

	--如果第二个装备位没有装备，第一个装备位有装备
	if not self.equipTwoSelect and self.equipOneSelect then
		self.itemProf3 = NewAttrId[1]
		self.itemProf4 = NewAttrId[2]
		if self.itemProf1 == self.itemProf3 and self.itemProf2 == self.itemProf4 then
			self.objSwf.effect.itempanel.iconEquip2:setData(UIData.encode(self:GetEquipViewData(self.currSelect))); 
			self.equipTwoSelect = self.currSelect 
				if self.currSelect.bagType == BagConsts.BagType_Role then
					self.bagTypeTwo = BagConsts.BagType_Role
				else
					self.bagTypeTwo = BagConsts.BagType_Bag
				end
				self.guidTwo = self.currSelect.id
				self:ShowExpend()
				self:ShowPreview() 
				-- self.objSwf.iconLoader1._visible = true;
				-- self.objSwf.iconLoader2._visible = true;
				return true
		else
			FloatManager:AddNormal( StrConfig["role430"] );     --装备类型不匹配，请重新选择
		end
	end
end

--------------------------------------右侧slot悬浮事件----------------------------------------

function UISmithingFusion:OnEquipOneClick( e )
	if not self.equipOneSelect then
		return;
	end
	if self.equipTwoSelect then          --规则：如果第二个装备没有卸下来之前，第一个装备是卸不掉的
		return;
	end

	local bagType = self.equipOneSelect:GetBagType()
	self:CheckBagTypeRefresh(bagType,self.equipOneSelect)  --刷新左侧列表
	self.objSwf.effect.itempanel.iconEquip1:setData(UIData.encode({}))
	self.equipOneSelect = false
	
end

function UISmithingFusion:OnEquipOneOver( e )
	if not self.equipOneSelect then
		return;
	end
	local equipType = self.equipOneSelect:GetBagType()
	TipsManager:ShowBagTips(equipType,self.equipOneSelect.pos);	
end

function UISmithingFusion:OnEquipTwoClick( e )
	if not self.equipTwoSelect then   
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.objSwf.effect.itempanel.iconEquip2:setData(UIData.encode({}))
	self.objSwf.effect.itempanel.iconPreview:setData(UIData.encode({}))

	local bagType = self.equipTwoSelect:GetBagType()
	self:CheckBagTypeRefresh(bagType,self.equipTwoSelect)

	self.equipTwoSelect = false;

	objSwf.tfNeedItem.label = '';
	objSwf.tfMoney.htmlText = '';
	-- objSwf.iconLoader1._visible = false;
	-- objSwf.iconLoader2._visible = false;
end

function UISmithingFusion:OnEquipTwoOver(e)
	if not self.equipTwoSelect then
		return;
	end	
	local equipType = self.equipTwoSelect:GetBagType()
	TipsManager:ShowBagTips(equipType,self.equipTwoSelect.pos);	
end


--根据背包类型刷新不同的临时数据表 
function UISmithingFusion:CheckBagTypeRefresh( bagType,currSelect)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if bagType == BagConsts.BagType_Role then
		table.push(self.RoleListVo, currSelect)
		self:ChooseEquipList(self.RoleListVo,self.objSwf.roleEquipList);
	else
		table.push(self.BagListVo, currSelect)
		self:ChooseEquipList(self.BagListVo,self.objSwf.bagList);
	end
end


------------------------------------------------------------------------------------------

--显示消耗
function UISmithingFusion:ShowExpend( )
	if not self.currSelect then return; end
	local itemId = self.currSelect.tid
	local config = t_fuse[itemId];
	if not config then return; end
	self.currentNum = BagModel:GetItemNumInBag(config.item)
	self.totalNum = config.itemnum
	local color = self.currentNum < self.totalNum and "#FF0000" or "#00FF00";
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.equipTwoSelect and self.equipOneSelect then
		objSwf.tfNeedItem.htmlLabel = string.format( StrConfig['smithing024'], color, t_item[config.item].name, self.currentNum..'/'..config.itemnum ); 
		local unBindGold = MainPlayerModel.humanDetailInfo.eaUnBindGold
		local colors = config.gold > unBindGold and "#FF0000" or "#00FF00";
		objSwf.tfMoney.htmlText = string.format(StrConfig['smithing029'],colors,unBindGold.."/"..config.gold);
	end
	self.spendCost = config.gold;
	self.mergeid = config.mergeid    --合成后的装备id

	-- objSwf.iconLoader1.source = ResUtil:GetItemIconUrl( t_item[config.item].icon,"54");
	-- objSwf.iconLoader2.source = ResUtil:GetItemIconUrl( t_item[11].icon,"54"); 
end

function UISmithingFusion:OnEquipPreviewOver(  )
	if not self.equipTwoSelect then
		return;
	end
	TipsManager:ShowItemTips(self.mergeid);
end

---显示预览
function UISmithingFusion:ShowPreview()
	--[[
	local randProp1 --= math.random(newTable[1],newTable[5])
	local id = t_zhuoyueshuxing[self.itemProf1]
	local props1 = EquipModel:GetSuperVO(self.itemProf1)
	local randProp2 --= math.random(self.itemProf3,self.itemProf4)
	local randProp3 = 0    ----随机生成三卓越装备的第三条属性
	local indexId = 0      ---t_zhuoyue3属性id
	WriteLog(LogType.Normal,true,'-------------houxudong',id)
	for k,v in pairs(t_zhuoyue3) do
		if v.lv == lv and v.pos == pos and v.quality == 6 then
			indexId = split(v["attr3"],',')
		end
	end
	if not indexId then return; end
	local id = tonumber(indexId[1])
	local config = t_zhuoyueshuxing[id]
	if not config then return; end
	local randNums = math.random(1,100)
	local dataVal = split(config["val"],',')
	if randNums <= tonumber(split(dataVal[2],'#')[1]) then
		randProp3 = tonumber(dataVal[1])
	elseif randNums <= tonumber(split(dataVal[2],'#')[1]) + tonumber(split(dataVal[3],'#')[1]) then
		randProp3 = split(dataVal[2],'#')[2]
	elseif randNums <=tonumber(split(dataVal[2],'#')[1]) + tonumber(split(dataVal[3],'#')[1]) + tonumber(split(dataVal[4],'#')[1]) then
		randProp3 = tonumber(split(dataVal[3],'#')[2])
	else
		randProp3 =tonumber(split(dataVal[4],'#')[2])
	end
	local NewSuperList = {}
	local NewSuperVO = {};
	NewSuperVO.id = self.mergeid
	NewSuperVO.newSuperList = NewSuperList
	--]]
	self.objSwf.effect.itempanel.iconPreview:setData(UIData.encode(self:GetEquipViewData(self.currSelect))); 
end

function UISmithingFusion:OnFusionClick( )
	if not self.equipOneSelect or not self.equipTwoSelect then
		FloatManager:AddNormal( StrConfig["role441"] );             --请选择装备
		return;
	end
	if self.currentNum < self.totalNum then
		FloatManager:AddNormal( StrConfig["role438"] );             --材料不够
		return;
	end
	if self.spendCost > MainPlayerModel.humanDetailInfo.eaUnBindGold  then
		FloatManager:AddNormal( StrConfig["role432"] );             --银两不足
		return;
	end
	if self.spendCost > 0 and self.currentNum > 0 then
		SmithingController:SendEquipFusion(self.guidOne,self.guidTwo,self.bagTypeOne,self.bagTypeTwo);
	else
		FloatManager:AddNormal( StrConfig["role440"] );             --策划表有问题！！！！
	end
end

-------------------------------------------------------------------------------------------------

---清空右侧数据显示
function UISmithingFusion:ClearInfoView()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	objSwf.tfNeedItem.label = '';
	objSwf.tfMoney.htmlText = '';

	objSwf.effect.itempanel.iconEquip1:setData(UIData.encode({}))
	objSwf.effect.itempanel.iconEquip2:setData(UIData.encode({}))
	objSwf.effect.itempanel.iconPreview:setData(UIData.encode({}))

	-- objSwf.iconLoader1.source = ""
	-- objSwf.iconLoader2.source = ""
	-- objSwf.iconLoader1._visible = false;
	-- objSwf.iconLoader2._visible = false;

	if self.equipOneSelect then
		self.equipOneSelect = false;
	end
	
	if self.equipTwoSelect then
		self.equipTwoSelect = false;
	end
end

function UISmithingFusion:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	self.currSelect = nil;
	self.equipOneSelect = nil;
	self.equipTwoSelect = nil;

	-- objSwf.iconLoader1.source = ""
	-- objSwf.iconLoader2.source = ""
	-- objSwf.iconLoader1._visible = false;
	-- objSwf.iconLoader2._visible = false;

	objSwf.effect.itempanel.iconEquip1:setData(UIData.encode({}))
	objSwf.effect.itempanel.iconEquip2:setData(UIData.encode({}))
	objSwf.effect.itempanel.iconPreview:setData(UIData.encode({}))

	objSwf.bagList.dataProvider:cleanUp();
	objSwf.bagList.dataProvider:push(unpack({}));
	objSwf.bagList:invalidateData()

	objSwf.roleEquipList.dataProvider:cleanUp();
	objSwf.roleEquipList.dataProvider:push(unpack({}));
	objSwf.roleEquipList:invalidateData()

end

--------------------------界面监听-----------------------

function UISmithingFusion:HandleNotification(name,body)
	if name == NotifyConsts.EquipMergeResult then
		self:ClearInfoView();
		FloatManager:AddNormal( StrConfig["role433"] );
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaLevel or body.type==enAttrType.eaUnBindGold then
			self:ShowExpend()
		end
	elseif name==NotifyConsts.BagAdd or name==NotifyConsts.BagRemove or name==NotifyConsts.BagUpdate or name == NotifyConsts.BagRefresh then
		self:ShowExpend()
	end
end

function UISmithingFusion:ListNotificationInterests()
	return {
		NotifyConsts.EquipMergeResult,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.BagRefresh,
		NotifyConsts.PlayerAttrChange,
	}
end




