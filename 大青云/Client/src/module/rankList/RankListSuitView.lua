--[[
本服排行
wangshuai
]]

_G.UIRanklistSuit = BaseUI:new("UIRanklistSuit");
UIRanklistSuit.curItemindex = 1;
UIRanklistSuit.curPage = 0;
UIRanklistSuit.curList = {};
UIRanklistSuit.roleId = nil;
UIRanklistSuit.curShowList = {};
UIRanklistSuit.JumpTabeVal = nil;
UIRanklistSuit.codeList ={};
UIRanklistSuit.curShowRightChild = nil;
UIRanklistSuit.MyChildList = {"rightrole","rightmoune","rightShengbing", "rightMingYu","rightLingQi","rightArmor"};
function UIRanklistSuit:Create()
	self:AddSWF("RanklistSuitPanel.swf", true, nil)

	self:AddChild(UIRankListRightRole ,"rightrole")
	self:AddChild(UIRankListRightMount ,"rightmoune")
	self:AddChild(UIRanklistRightShengbing,"rightShengbing")
	self:AddChild(UIRanklistRightMingYu,"rightMingYu")
	self:AddChild(UIRanklistRightLingQi,"rightLingQi")
	self:AddChild(UIRanklistRightArmor,"rightArmor")
	self:AddChild(UIRanklistRightArmor,"rightNewTianShen")

end
function UIRanklistSuit:OnLoaded(objSwf)

	
	self:GetChild("rightrole"):SetContainer(objSwf.childPanel);
	self:GetChild("rightmoune"):SetContainer(objSwf.childPanel);
	self:GetChild("rightShengbing"):SetContainer(objSwf.childPanel);
	self:GetChild("rightMingYu"):SetContainer(objSwf.childPanel);
	self:GetChild("rightLingQi"):SetContainer(objSwf.childPanel);
	self:GetChild("rightArmor"):SetContainer(objSwf.childPanel);
	self:GetChild("rightNewTianShen"):SetContainer(objSwf.childPanel);


	objSwf.list.itemClick = function(e) self:ItemClick(e) end;
	--objSwf.btnPre1.click = function() self:PagePre1()end; -- 前
	--objSwf.btnNext1.click = function() self:PageNext1()end; -- 后
	objSwf.btnPre.click = function() self:PagePre() end; -- 上一个
	objSwf.btnNext.click = function() self:PageNext() end; -- 下一个

	objSwf.rankListPanel1.listtxt.itemClick = function(e) self:RoleItemClick(e) end;
	objSwf.rankListPanel1.listtxt.nameClick = function(e) self:RolenameItemClick(e) end;
	objSwf.rankListPanel2.listtxt.itemClick = function(e) self:RoleItemClick(e) end;
	objSwf.rankListPanel2.listtxt.nameClick = function(e) self:RolenameItemClick(e) end;

	objSwf.btnfind.click = function() self:OnFindClick() end;

	objSwf.teshi_text.htmlText = StrConfig['rankstr006']
end

;
-- 跳转到需要显示的界面
function UIRanklistSuit:JumpTabe(type)
	local objSwf = self.objSwf;
	self.curItemindex = 1;
	local indexlist = 0;

	for i, info in pairs(self.curShowList) do
		if info.type == type then
			self.curItemindex = info.indexc;
			indexlist = i;
			break;
		end;
	end;
	if not objSwf then
		return
	end;
	objSwf.list.selectedIndex = indexlist - 1; --self.curItemindex-1;
	objSwf.rankListPanel1.listtxt.selectedIndex = 0;
	self:SwitchRankListVisible(1);

	self.curPage = 0;
	self:CloseRightPanel();
	if self:IsShow() == true then
		if RankListModel:GetCurListboo(self.curItemindex) == true then
			RankListController:ReqRanlist(self.curItemindex);
			RankListModel:SetCurListboo(self.curItemindex, false);
		else
			self:ShowInitList();
		end;
	end;
	self.JumpTabeVal = nil;
end

;
function UIRanklistSuit:OnShow()
	self:InitFunction();
	if self.JumpTabeVal then
		self:JumpTabe(self.JumpTabeVal)
	end;

	-- if not self.curShowRightChild then return end;
	-- self.curShowRightChild:Show();
end

;
function UIRanklistSuit:InitFunction()
	local objSwf = self.objSwf;
	local listcc = RankListConsts.RankName;
	self.curShowList = {};
	self.codeList ={};
	objSwf.list.dataProvider:cleanUp();
	local num = 0;
	for i, infoIndex in pairs(RankListConsts.itemOpenOrder) do
		local info = listcc[infoIndex]
		
		local cfg = t_ranking[infoIndex];
		if not cfg then return end
        
		local isOpen = RankListUtils:IsOpen(cfg.funid)
		local rolelvl = MainPlayerModel.humanDetailInfo.eaLevel;
		local name = cfg.name;
		if GMModule:IsGM() then
			local vo = {};
			num = num + 1;
			vo.name = name;
			vo.indexc = infoIndex;
			vo.type = info;
			vo.sort = cfg.rank;
			table.push(self.curShowList, vo)
		else
			if isOpen then
				local vo = {};
				num = num + 1;
				vo.name = name;
				vo.indexc = infoIndex;
				vo.type = info;
				vo.sort = cfg.rank;
				table.push(self.curShowList, vo)

			end;
		end
	end;
	table.sort(self.curShowList, function(A, B)
		return A.sort < B.sort;
	end)

	for k, v in pairs(self.curShowList) do
	    self.codeList[k]= UIData.encode(self.curShowList[k]);
	end
	objSwf.list.dataProvider:push(unpack(self.codeList));
	objSwf.list:invalidateData();

	self.curItemindex = RankListConsts.itemOpenOrder[1]
	objSwf.list.selectedIndex = 0;
	if RankListModel:GetCurListboo(self.curItemindex) == true then
		RankListController:ReqRanlist(self.curItemindex);
		RankListModel:SetCurListboo(self.curItemindex, false);
	else
		self:ShowInitList();
	end;

end

;
function UIRanklistSuit:ItemClick(e)
	local objSwf = self.objSwf;
	self.curItemindex = e.item.indexc --+1;
	self.curPage = 0;
	objSwf.rankListPanel1.listtxt.selectedIndex = 0;
	self:SwitchRankListVisible(1);


	if RankListModel:GetCurListboo(self.curItemindex) == true then
		RankListController:ReqRanlist(self.curItemindex);
		RankListModel:SetCurListboo(self.curItemindex, false);
	else
		self:ShowInitList();
	end;
end

;


-- 显示初始化list
function UIRanklistSuit:ShowInitList()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	objSwf.rankListPanel1.listtxt.dataProvider:cleanUp();
	objSwf.rankListPanel1.listtxt:invalidateData();

	self:SetRankType(self.curItemindex)
	self.curList = RankListUtils:GetList(self.curItemindex)
	local lisc = RankListUtils:GetListPage(self.curList, self.curPage);
	if not lisc then return end;
	local voc = {}
	for i, info in pairs(lisc) do

		local vo = RankListUtils:GetRoleItemUIdata(info, self.curItemindex)

		if not vo then break end;
		table.push(voc, vo)
	end;

	if self.curPage <= 0 then
		self:SwitchRankListVisible(1);
	else
		self:SwitchRankListVisible(2);
	end

	self:GetShowingRankList().listtxt.dataProvider:cleanUp();
	self:GetShowingRankList().listtxt.dataProvider:push(unpack(voc));
	self:GetShowingRankList().listtxt:invalidateData();
	self:GetShowingRankList().listtxt.selectedIndex = 0;


	self:SetMyItemInfo();
	-- 设置当前已经是最前
	self:SetPagebtn();
	self:ShowRightPanel(lisc)
	-- 设置文本框
	objSwf.kuang:gotoAndStop(self.curItemindex)
end

;
function UIRanklistSuit:OnHide()
	self.curItemindex = 1;
	self.curPage = 0;
	self.curList = {};
	self.roleId = nil;
	if UIRankListRightMount:IsShow() then
		UIRankListRightMount:Hide();
	end;
	if UIRankListRightRole:IsShow() then
		UIRankListRightRole:Hide();
	end;
	self.objSwf.rankListPanel1.listtxt.dataProvider:cleanUp();
	self.objSwf.rankListPanel1.listtxt:invalidateData();
	self.objSwf.rankListPanel2.listtxt.dataProvider:cleanUp();
	self.objSwf.rankListPanel2.listtxt:invalidateData();
end

;

function UIRanklistSuit:SetRankType(type)
	local objSwf = self.objSwf;
	objSwf.ranktype1.textField.text = string.format(StrConfig["ranktype00" .. type]);
end

;

-- 设置我的数据
function UIRanklistSuit:SetMyItemInfo()
	local strxy = RankListConsts.TabPage[self.curItemindex]
	local objSwf = self.objSwf;
	local vodata = {};
	vodata.roleName = MainPlayerModel.humanDetailInfo.eaName
	local info = RankListUtils:FindMyDesc(self.curList, vodata.roleName);
	if not info then info = {} end;
	if not info.rank then info.rank = string.format(StrConfig["rankstr101"]); end;
	vodata.rank = info.rank -- 这里被干掉了
	vodata.lvl = MainPlayerModel.humanDetailInfo.eaLevel
	vodata.role = MainPlayerModel.humanDetailInfo.eaProf
	vodata.fight = MainPlayerModel.humanDetailInfo.eaFight
	vodata.mountId = MountModel.ridedMount.mountLevel;
	vodata.jingjieVlue = RealmModel:GetRealmOrder(); --   境界等级
	-- local cfglingshou = t_wuhun[SpiritsModel:GetWuhunId()]; -- 灵兽等级
	-- if not cfglingshou then 
	-- 	vodata.lingshouName = "";
	-- 	vodata.lingshouOrder = 0;
	-- else
	-- 	vodata.lingshouName = cfglingshou.name;
	-- 	vodata.lingshouOrder = cfglingshou.order;
	-- end;

	vodata.sbValue = MagicWeaponModel:GetLevel() or 0; -- 神兵
	local cfgShengb = t_shenbing[vodata.sbValue]
	if cfgShengb then
		vodata.sbName = cfgShengb.name;
	else
		vodata.sbName = "";
	end;

	vodata.myValue = MingYuModel:GetLevel() or 0; -- 神兵
	local cfgMingYu = t_mingyu[vodata.myValue]
	if cfgMingYu then
		vodata.myName = cfgMingYu.name;
	else
		vodata.myName = "";
	end;

	vodata.lqValue = LingQiModel:GetLevel() or 0; -- 灵器
	local cfgLingQi = t_lingqi[vodata.lqValue]
	if cfgLingQi then
		vodata.lqName = cfgLingQi.name;
	else
		vodata.lqName = "";
	end;

	vodata.armorValue = ArmorModel:GetLevel() or 0; -- 宝甲
	local cfgArmor = t_newbaojia[vodata.armorValue]
	if cfgArmor then
		vodata.armorName = cfgArmor.name;
	else
		vodata.armorName = "";
	end;

	local roleid = MainPlayerController:GetRoleID();
	vodata.killNum = RankListUtils:GetJxtzInfo(roleid, RankListConsts.JixianBoss) -- 0; --极限挑战 bos
	vodata.monsterNum = RankListUtils:GetJxtzInfo(roleid, RankListConsts.JixianMonster) --0; -- 极限挑战 monster


	vodata.vipLvl = MainPlayerModel.humanDetailInfo.eaVIPLevel; -- vip 等级
	vodata.vflag = VplanModel:GetVFlag() -- v计划等级
	local vo = UIData.decode(RankListUtils:GetRoleItemUIdata(vodata, self.curItemindex, true))
	if type(vo.rank) == "string" then
		if vo.rank == string.format(StrConfig["rankstr101"]) then
			vo.isrank = vo.rank;
			vo.rank = ""
		else
			vo.rank = vo.rank;
			vo.isrank = ""
		end;
	elseif type(vo.rank) == "number" then
		vo.rank = vo.rank;
		vo.isrank = ""
	end;
	vo.isShowRank = true;
	objSwf.myitem:setData(UIData.encode(vo));
end

;
------ 消息处理 ---- 
function UIRanklistSuit:ListNotificationInterests()
	return {
		NotifyConsts.RanklistRoleInfo,
		NotifyConsts.StageClick,
		NotifyConsts.StageFocusOut,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.RanklistRoleDetaiedInfo,
		NotifyConsts.RanklistMountDetaiedInfo,
		NotifyConsts.RanklistLingshouDetaiedInfo,
		NotifyConsts.RanklistShengbingDetaiedInfo,
		NotifyConsts.RanklistMingYuDetaiedInfo,
		NotifyConsts.RanklistLingQiDetaiedInfo,
		NotifyConsts.RanklistArmorDetaiedInfo,
		NotifyConsts.RanklistNewTianShenDetaiedInfo,
		
	}
end

;
function UIRanklistSuit:HandleNotification(name, body)
	if not self.bShowState then return; end -- 关闭等于False
	if name == NotifyConsts.RanklistRoleInfo then
		-- 显示人物list
		self:ShowInitList()
		--输入
	elseif name == NotifyConsts.StageFocusOut or name == NotifyConsts.StageClick then
		self:OnIpSearchFocusOut();

	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:InitFunction();
		end;
	end;
		if name == NotifyConsts.RanklistRoleDetaiedInfo then 
		if UIRankListRightRole:IsShow() then 
			UIRankListRightRole:RefreshData();
		else
			self:ShowChildPanel("rightrole")
		end;
	elseif name == NotifyConsts.RanklistMountDetaiedInfo then 
		if UIRankListRightMount:IsShow() then 
			UIRankListRightMount:RefreshData() 
		else
			self:ShowChildPanel("rightmoune")
		end;
	elseif name == NotifyConsts.RanklistShengbingDetaiedInfo then
		if UIRanklistRightShengbing:IsShow() then
	 		UIRanklistRightShengbing:RefreshData()
	 	else
	 		self:ShowChildPanel("rightShengbing")
	 	end;
	elseif name == NotifyConsts.RanklistMingYuDetaiedInfo then
		if UIRanklistRightMingYu:IsShow() then
			UIRanklistRightMingYu:RefreshData()
		else
			self:ShowChildPanel("rightMingYu")
		end;
	elseif name == NotifyConsts.RanklistLingQiDetaiedInfo then
		if UIRanklistRightLingQi:IsShow() then
			UIRanklistRightLingQi:RefreshData()
		else
			self:ShowChildPanel("rightLingQi")
		end;
	elseif name == NotifyConsts.RanklistArmorDetaiedInfo then
		if UIRanklistRightArmor:IsShow() then
			UIRanklistRightArmor:RefreshData()
		else
			self:ShowChildPanel("rightArmor")
		end;
	elseif name == NotifyConsts.RanklistNewTianShenDetaiedInfo then
		if UIRanklistRightNewTianShen:IsShow() then
			UIRanklistRightNewTianShen:RefreshData()
		else
			self:ShowChildPanel("rightNewTianShen")
		end;
	end
end

;

-- 人物list nameclick
function UIRanklistSuit:RolenameItemClick(e)
	local roleid = e.item.roleid;
	self.roleId = roleid;
	local myroleid = MainPlayerController:GetRoleID();
	if roleid == myroleid then
		return
	end;
	local friendVO = {};
	friendVO.roleId = roleid;
	friendVO.roleName = e.item.roleName;
	friendVO.roleLvl = e.item.roleLvl;
	friendVO.prof = e.item.prof;
	friendVO.vipLvl = e.item.vipLvl;
	if not friendVO then return end;
	UIRankListOper:Open(friendVO, 0, false);
end

;

function UIRanklistSuit:ShowRightPanel(lisc)
	if not lisc[1] then return end;
	self.roleId = lisc[1].roleid;
	local e = {};
	e.item = {};
	e.item.roleid = self.roleId
	self:RoleItemClick(e)
end

-- 人物list itemclick
function UIRanklistSuit:RoleItemClick(e)
	local roleid = e.item.roleid;
	self.roleId = roleid;

	if self.curItemindex == RankListConsts.LvlRank
			or self.curItemindex == RankListConsts.FigRank
			or self.curItemindex == RankListConsts.jingJie
			or self.curItemindex == RankListConsts.JixianBoss
			or self.curItemindex == RankListConsts.JixianMonster
	then
		RankListController:ReqHumanInfo(roleid, 0);
	elseif self.curItemindex == RankListConsts.ZuoRank then
		local typemount = OtherRoleConsts.OtherRole_Mount;
		RankListController:ReqHumanInfo(roleid, typemount);
	elseif self.curItemindex == RankListConsts.Lingshou then
		local typeLingshow = OtherRoleConsts.OtherRole_Spirits;
		local roleinfo = OtherRoleConsts.OtherRole_Base;
		RankListController:ReqHumanInfo(roleid, typeLingshow + roleinfo);
		-- elseif self.curItemindex == RankListConsts.LingZhen then
		-- 	local typelingzhen = OtherRoleConsts.OtherRole_LingZhen;
		-- 	local roleinfo = OtherRoleConsts.OtherRole_Base;
		-- 	RankListController:ReqHumanInfo(roleid,typelingzhen + roleinfo);
	elseif self.curItemindex == RankListConsts.Shengbing then
		 	local type = OtherRoleConsts.OtherRole_ShengBing;
		 	local roleinfo = OtherRoleConsts.OtherRole_Base;
		 	RankListController:ReqHumanInfo(roleid, roleinfo + type);
	elseif self.curItemindex == RankListConsts.MingYu then
		local type = OtherRoleConsts.OtherRole_MingYu;
		local roleinfo = OtherRoleConsts.OtherRole_Base;
		RankListController:ReqHumanInfo(roleid, roleinfo + type);
	elseif self.curItemindex == RankListConsts.LingQi then
		local type = OtherRoleConsts.OtherRole_LingQi;
		local roleinfo = OtherRoleConsts.OtherRole_Base;
		RankListController:ReqHumanInfo(roleid, roleinfo + type);
	elseif self.curItemindex == RankListConsts.Armor then
		local type = OtherRoleConsts.OtherRole_Armor;
		local roleinfo = OtherRoleConsts.OtherRole_Base;
		RankListController:ReqHumanInfo(roleid, roleinfo + type);
	end;
end

;

--- 翻页控制
-- 最前
function UIRanklistSuit:PagePre1()
	local objSwf = self.objSwf;
	self.curPage = 0;
	UIRanklistSuit:ShowInitList()
end

;
-- 前
function UIRanklistSuit:PagePre()
	local objSwf = self.objSwf;
	self.curPage = self.curPage - 1;
	UIRanklistSuit:ShowInitList()
end

;
-- 最后
function UIRanklistSuit:PageNext1()
	local objSwf = self.objSwf;
	local len = RankListUtils:GetListLenght(self.curList)
	self.curPage = len;
	UIRanklistSuit:ShowInitList()
end

;
-- 后
function UIRanklistSuit:PageNext()
	local objSwf = self.objSwf;
	self.curPage = self.curPage + 1;
	local len = RankListUtils:GetListLenght(self.curList)
	UIRanklistSuit:ShowInitList()
end

;

function UIRanklistSuit:SetPagebtn()
	local objSwf = self.objSwf;
	local curpage = self.curPage + 1;
	local curTotal = RankListUtils:GetListLenght(self.curList);
	objSwf.txtPage.text = string.format(StrConfig["rankstr004"], curpage, curTotal)
	if curpage == 1 then
		--objSwf.btnPre1.disabled = true;
		objSwf.btnPre.disabled = true;
		objSwf.btnNext.disabled = false;
		--objSwf.btnNext1.disabled = false;
	elseif curpage >= curTotal then
		--objSwf.btnPre1.disabled = false;
		objSwf.btnPre.disabled = false;
		objSwf.btnNext.disabled = true;
		--objSwf.btnNext1.disabled = true;
	elseif curpage ~= 0 and curpage ~= curTotal then
		--	objSwf.btnPre1.disabled = false;
		objSwf.btnPre.disabled = false;
		objSwf.btnNext.disabled = false;
		--objSwf.btnNext1.disabled = false;
	end;
	if curTotal <= 1 then
		--objSwf.btnPre1.disabled = true;
		objSwf.btnPre.disabled = true;
		objSwf.btnNext.disabled = true;
		--	objSwf.btnNext1.disabled = true;
	end;
end

;
-- 搜索 
function UIRanklistSuit:OnFindClick()
	local objSwf = self.objSwf;
	local txt = objSwf.input.text;
	if txt == "" then
		--return;
	end;
	local resuVo = RankListUtils:FindDesc(self.curList, txt)

	if #resuVo == 0 then
		FloatManager:AddNormal(StrConfig['rankstr002']);
		return;
	end;
	local voc = {};
	for i, info in pairs(resuVo) do
		local vo = RankListUtils:GetRoleItemUIdata(info, self.curItemindex, true)
		table.push(voc, vo)
	end;
	self:SwitchRankListVisible(2);
	objSwf.rankListPanel2.listtxt.dataProvider:cleanUp();
	objSwf.rankListPanel2.listtxt.dataProvider:push(unpack(voc));
	objSwf.rankListPanel2.listtxt:invalidateData();
	--objSwf.btnPre1.disabled = true;
	objSwf.btnPre.disabled = true;
	objSwf.btnNext.disabled = true;
	--objSwf.btnNext1.disabled = true;
	local len = RankListUtils:GetListLenght(resuVo)
	if len <= 0 then
		len = 1;
	end;
	objSwf.txtPage.text = "1/" .. len
end

;
--输入文本失去焦点
function UIRanklistSuit:OnIpSearchFocusOut()
	local objSwf = self.objSwf
	if not objSwf then return; end
	if objSwf.input.focused then
		objSwf.input.focused = false;
	end
end

function UIRanklistSuit:SwitchRankListVisible(rankID)
	if rankID == 1 then
		self.objSwf.rankListPanel1._visible = true;
		self.objSwf.rankListPanel2._visible = false;
	elseif rankID == 2 then
		self.objSwf.rankListPanel1._visible = false;
		self.objSwf.rankListPanel2._visible = true;
	end
end

function UIRanklistSuit:GetShowingRankList()
	if self.objSwf.rankListPanel1._visible == true then
		return self.objSwf.rankListPanel1;
	else
		return self.objSwf.rankListPanel2;
	end
end

function UIRanklistSuit:CloseRightPanel()
	-- if UIRankListRightMount:IsShow() then 
	-- 	UIRankListRightMount:Hide();
	-- end;
	-- if UIRankListRightRole:IsShow() then 
	-- 	UIRankListRightRole:Hide();
	-- end;
end
 ---显示右侧面板
function UIRanklistSuit:ShowChildPanel(name)
	-- if self.curShowChild == 'supreme' then 
	-- 	return 
	-- end;
	local child = self:GetChild(name);
	if not child then return end;
	child:Show();
	self.curShowRightChild = child;
	for i,info in ipairs(self.MyChildList) do 
		if info ~= name then 
			local chi = self:GetChild(info)
			chi:Hide();
		end;
	end;
end;

--关闭右侧面板
function UIRanklistSuit:HideChildPanel(name)
	if not name then 
		for i,info in pairs(self.MyChildList) do 
			local chi = self:GetChild(info)
			chi:Hide();
		end;
		return 
	end;
	local chi = self:GetChild(info)
	chi:Hide();
end;