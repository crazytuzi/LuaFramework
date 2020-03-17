--[[
	2015年12月31日16:14:55
	wangyanwei
	圣器
]]
_G.UIHallows = BaseUI:new('UIHallows');

function UIHallows:Create()
	self:AddSWF('hallowspanel.swf',true,'center');
end

function UIHallows:OnLoaded(objSwf)
	objSwf.getpanel.txt_open.htmlText = StrConfig['hallows102'];
	objSwf.binghunlist.itemClick = function (e)
		self.hallowSelected = e.index;
		self:DrawHallow();
		self:DrawIconPostion();				--孔位置
		self:OnShowLockIcon();			    --锁
		self:DrawHallowItem();			--镶嵌信息
		self:ShowFight();				--战斗力
		self:ShowIsOpen();
	end
	objSwf.load_hole.loaded = function ()
		objSwf.load_hole._x = self:GetWidth() / 2 - objSwf.load_hole._width / 2 ;
		objSwf.load_hole._y = self:GetHeight() / 2 - objSwf.load_hole._height / 2 ;
	end
	objSwf.load_weapon.loaded = function ()
		local binghunCfg = t_binghun[self.hallowSelected + 1];
		if not binghunCfg then return end
		local prof = MainPlayerModel.humanDetailInfo.eaProf;
		local deviCfg = split(binghunCfg.deviation,'#')[prof];
		if not deviCfg then return end
		local postionCfg = split(deviCfg,',');
		objSwf.load_weapon._x = self:GetWidth() / 2 - objSwf.load_weapon._width / 2 + toint(postionCfg[1]);
		objSwf.load_weapon._y = self:GetHeight() / 2 - objSwf.load_weapon._height / 2 + toint(postionCfg[2]);
	end
	objSwf.numFight.loadComplete = function ()
		objSwf.numFight._x = objSwf.mc_fightfloor._x - objSwf.numFight._width / 2 ;
	end
	objSwf.btn_bg.click = function () if UIHallowsBG:IsShow() then UIHallowsBG:Hide(); return end UIHallowsBG:Show(); end
	objSwf.list.itemClick = function (e) self:PeelHallowsClick(e.item); end
	objSwf.list.itemRollOver = function (e) self:OnHallowsRollOver(e.item); end
	objSwf.list.itemRollOut = function (e) TipsManager:Hide(); end
end

UIHallows.ConstsNum = 1000;
function UIHallows:OnHallowsRollOver(item)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local id = item.id;
	local hallowData = HallowsModel:GetHallows(self.hallowSelected + 1);
	if not hallowData then
		return
	else
		local index = item.index;
		local holeNum = hallowData:GetOpenHole();
		if index > holeNum then
			local level = hallowData:GetAllLevel();
			local gridCfg = t_binghungrid[(self.hallowSelected + 1) * self.ConstsNum + index];
			local str = '';
			if gridCfg then
				str = string.format(StrConfig['hallows101'],level,gridCfg.level);
			end
			TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown);
		else
			if not t_binghungem[id] then return end
			if not t_item[id] then return end
			TipsManager:ShowItemTips(id);
		end
	end
end

function UIHallows:PeelHallowsClick(item)
	local id = item.id;
	local index = item.index;
	local gemcfg = t_binghungem[id];
	if not gemcfg then return end
	if not t_item[id] then return end
	HallowsController:PeelHallows(self.hallowSelected + 1,index);
end

--该圣器是否激活
function UIHallows:ShowIsOpen()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.getpanel._visible = not BingHunUtil:GetIsBingHunActive(self.hallowSelected + 1);
end

function UIHallows:OnShow()
	HallowsController:SendHallows();
	self:ShowList();			--左侧list
	self:DrawHallow();			--BG图
	self:DrawIconPostion();		--位置
	self:OnShowLockIcon();		--锁
	self:DrawHallowItem();		--镶嵌信息
	self:ShowIsOpen();
end

function UIHallows:OnHide()
	UIHallowsBG:Hide();
end

function UIHallows:DrawIconPostion()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local binghunCfg = t_binghun[self.hallowSelected + 1];
	if not binghunCfg then return end
	local prof = MainPlayerModel.humanDetailInfo.eaProf;
	local holeCfg = split(binghunCfg.holePoint,'*')[prof];
	local holePosCfg = split(holeCfg,'#');
	for i = 1 , 7 do
		local pos = split(holePosCfg[i],',');
		objSwf['lock_' .. i]._x = toint(pos[1]);
		objSwf['lock_' .. i]._y = toint(pos[2]);
		objSwf['item' .. i]._x = objSwf['lock_' .. i]._x;
		objSwf['item' .. i]._y = objSwf['lock_' .. i]._y;
	end
end

--按钮data
function UIHallows:DrawHallowItem()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local hallowData = HallowsModel:GetHallows(self.hallowSelected + 1);
	if not hallowData then
		objSwf.list.dataProvider:cleanUp();
		for i = 1 , 7 do
			local listVO = {};
			listVO.iconUrl = nil;
			listVO.id = 0;
			listVO.index = i;
			objSwf.list.dataProvider:push(UIData.encode(listVO));
		end
		objSwf.list:invalidateData();
		return
	end
	local sortList = hallowData:GetSortList();
	objSwf.list.dataProvider:cleanUp();
	for i = 1 , 7 do
		local listVO = {};
		local cfg = sortList[i];
		if cfg then
			local itemCfg = t_item[cfg.id];
			if itemCfg then
				listVO.levelStr = string.format('lv:%s',t_binghungem[itemCfg.id].gem);
				listVO.iconUrl = ResUtil:GetItemIconUrl(itemCfg.icon);
			else
				listVO.iconUrl = nil;
			end
			listVO.id = cfg.id
			listVO.index = i
		end
		objSwf.list.dataProvider:push(UIData.encode(listVO));
	end
	objSwf.list:invalidateData();
end

function UIHallows:DrawHallow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_binghun[self.hallowSelected + 1];
	if not cfg then return end
	local prof = MainPlayerModel.humanDetailInfo.eaProf;
	local bgName = split(cfg.base_pic,',')[prof];
	if not bgName then return end
	local bgUrl = ResUtil:GetHallowsBgIcon(bgName);
	objSwf.load_weapon.source = bgUrl;
	local holeName = split(cfg.hole,',')[prof];
	if not holeName then return end
	local holeUrl = ResUtil:GetHallowsHoleIcon(holeName);
	objSwf.load_hole.source = holeUrl;
end

function UIHallows:OnShowLockIcon()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local hallowData = HallowsModel:GetHallows(self.hallowSelected + 1);
	if not hallowData then
		for i = 1 , 7 do
			objSwf['lock_' .. i]._visible = true;
		end
		return
	end
	local openNum = hallowData:GetOpenHole();
	for i = 1 , 7 do
		objSwf['lock_' .. i]._visible = i > openNum;
	end
end

--显示战斗力 
function UIHallows:ShowFight()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local hallowData = HallowsModel:GetHallows(self.hallowSelected + 1);
	
	if not hallowData then
		for i = 1 , 9 do
			objSwf['txt_' .. i]._visible = false;
			objSwf['txt_add' .. i]._visible = false;
		end
		objSwf.numFight.num = 0;
		return
	end
	local sortList = hallowData:GetSortList();
	-- trace(sortList)
	local attrList = {};
	for i , v in pairs(sortList) do
		local hallowGemCfg = t_binghungem[v.id];
		if hallowGemCfg then
			local attrCfg = split(hallowGemCfg.attr,',');
			if attrList[attrCfg[1]] then
				attrList[attrCfg[1]] = attrList[attrCfg[1]] + toint(attrCfg[2]);
			else
				attrList[attrCfg[1]] = toint(attrCfg[2]);
			end
		end
	end
	local _attrList = self:OnSortNum(attrList);
	local fight = EquipUtil:GetFight(_attrList);
	objSwf.numFight.num = fight;
	
	--增加属性文字
	local index = 1;
	for attr , attrVO in pairs(attrList) do
		local attrType = AttrParseUtil.AttMap[attr];
		if attrType then
			objSwf['txt_' .. index]._visible = true;
			objSwf['txt_add' .. index]._visible = true;
			objSwf['txt_' .. index].text = StrConfig['hallows_' .. attr];
			objSwf['txt_add' .. index].text = attrVO;
			index = index + 1;
		end
	end
	for i = index , 9 do
		objSwf['txt_' .. i]._visible = false;
		objSwf['txt_add' .. i]._visible = false;
	end
end

function UIHallows:OnSortNum(attrList)
	local vo = {};
	for i , v in pairs (attrList) do
		local cfg = {};
		cfg.type = nil;
		for str , id in pairs(AttrParseUtil.AttMap) do
			if str == i then
				cfg.type = id;
				break;
			end
		end
		cfg.val = v ;
		table.push(vo,cfg);
	end
	return vo
end

--显示兵魂list
UIHallows.hallowSelected = 0;
function UIHallows:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local list = objSwf.binghunlist;
	list.dataProvider:cleanUp();
	
	local binghunlist = self:GetBingHunShowList()
	for _, vo in ipairs( binghunlist ) do
		list.dataProvider:push( UIData.encode( vo ) );
	end
	list:invalidateData();
	list.selectedIndex = self.hallowSelected;
end

function UIHallows:GetBingHunShowList()
	local sList = {}
	for order=1, BingHunConsts.BingHunMax do
		local uiVO = self:GetListUIVO( order )
		table.push( sList, uiVO )
	end
	table.sort( sList, function( A, B )
		return A.order < B.order
	end )
	return sList
end

function UIHallows:GetListUIVO(order)
	local cfg = t_binghun[order]
	if not cfg then return end
	local vo = {}
	vo.order = order;
	for i=1,3 do
		vo["icon"..i] = ResUtil:GetBingHunIconName(BingHunUtil:GetBingHunHeadIcon(cfg.head_icon,MainPlayerModel.humanDetailInfo.eaProf).."_"..i);
	end
	vo.nameicon = ResUtil:GetBingHunIconName(cfg.name_icon);
	return vo
end

function UIHallows:HandleNotification(name,body)
	if name == NotifyConsts.HallowsUpData then
		self:ShowFight();				--战斗力
		self:OnShowLockIcon();			--锁
		self:DrawHallowItem();			--镶嵌信息
	end
end

function UIHallows:ListNotificationInterests()
	return {
		NotifyConsts.HallowsUpData,
	};
end