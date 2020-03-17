--[[
 全服排行
 wangshuai
]]

_G.UIAllTheServerRankView = BaseUI:new("UIAllTheServerRankView");
UIAllTheServerRankView.curItemindex = 1;
UIAllTheServerRankView.curPage = 0;
UIAllTheServerRankView.curList = {};
UIAllTheServerRankView.roleId = nil;


function UIAllTheServerRankView:Create()
	self:AddSWF("RanklistSuitPanel.swf",true,nil)--AllTheServerPanle
end;

function UIAllTheServerRankView:OnLoaded(objSwf)
	objSwf.list.itemClick = function(e) self:ItemClick(e)end;
--	objSwf.btnPre1.click = function() self:PagePre1()end; -- 前
	--objSwf.btnNext1.click = function() self:PageNext1()end; -- 后
	objSwf.btnPre.click = function() self:PagePre()end; -- 上一个
	objSwf.btnNext.click = function() self:PageNext()end; -- 下一个
	objSwf.listtxt.itemClick = function(e) self:RoleItemClick(e)end;
	--objSwf.listtxt.nameClick = function(e) self:RolenameItemClick(e)end;
	objSwf.btnfind.click = function() self:OnFindClick()end;

	objSwf.teshi_text.htmlText = StrConfig['rankstr005']
end;
-- 跳转到需要显示的界面
function UIAllTheServerRankView:JumpTabe(type)
	local objSwf = self.objSwf;
	self.curItemindex = type;
	if not objSwf then 
		return 
	end;
	objSwf.list.selectedIndex = self.curItemindex-1;
	objSwf.listtxt.selectedIndex = 0;
	self.curPage = 0;
	self:CloseRightPanle();
	if self:IsShow() == true then 
		if RankListModel:AtServerGetCurListboo(self.curItemindex) == true then 
			RankListController:AtServerReqList(self.curItemindex);  -- 改
			RankListModel:AtServerSetCurListboo(self.curItemindex,false);
		else 
			self:ShowInitList();
		end;
	end;

end;
function UIAllTheServerRankView:OnShow()
	self:InitFunction();
end;

function UIAllTheServerRankView:InitFunction()
	local objSwf = self.objSwf;
	local listcc = RankListConsts.RankName;
	self.curShowList = {};
	objSwf.list.dataProvider:cleanUp();
	local num = 0;	

	for i,infoIndex in pairs(RankListConsts.itemOpenOrder) do
		local info = listcc[infoIndex]
		local cfg = t_ranking[infoIndex];
		local isOpen = FuncManager:GetFuncIsOpen(cfg.funid);
		local rolelvl = MainPlayerModel.humanDetailInfo.eaLevel;
		local name = cfg.name;
		if GMModule:IsGM() then
			local vo = {};
			num = num + 1;
			vo.name = name;
			vo.indexc = infoIndex;
			vo.type = info;
			vo.sort = cfg.rank;
			table.push(self.curShowList,vo)
		else
			if isOpen then
				local vo = {};
				num = num + 1;
				vo.name = name;
				vo.indexc = infoIndex;
				vo.type = info;
				vo.sort = cfg.rank;
				table.push(self.curShowList,vo)
			end;
		end
	end;
	table.sort(self.curShowList, function(A, B)
		return A.sort < B.sort;
	end)
	for k, v in pairs(self.curShowList) do
		self.curShowList[k] = UIData.encode(self.curShowList[k]);
	end
	objSwf.list.dataProvider:push(unpack(self.curShowList));
	objSwf.list:invalidateData();

	self.curItemindex = RankListConsts.itemOpenOrder[1]
	objSwf.list.selectedIndex=0;
	if RankListModel:AtServerGetCurListboo(self.curItemindex) == true then 
		RankListController:AtServerReqList(self.curItemindex);
		RankListModel:AtServerSetCurListboo(self.curItemindex,false);
	else 
		self:ShowInitList();
	end;
end;
function UIAllTheServerRankView:ItemClick(e)
	local objSwf = self.objSwf;
	self.curItemindex = e.item.indexc;
	self.curPage = 0;
	objSwf.listtxt.selectedIndex = 0;
	if RankListModel:AtServerGetCurListboo(self.curItemindex) == true then 
		RankListController:AtServerReqList(self.curItemindex); -- 改
		RankListModel:AtServerSetCurListboo(self.curItemindex,false);
	else
		self:ShowInitList();
	end;
end;


-- 显示初始化list
function UIAllTheServerRankView:ShowInitList()
	local objSwf = self.objSwf;
	-- 清空数据	
	objSwf.listtxt.dataProvider:cleanUp();
	objSwf.listtxt.dataProvider:push(unpack({}));
	objSwf.listtxt:invalidateData();
	self:SetRankType(self.curItemindex)
	self.curList = RankListUtils:AtServerGetList(self.curItemindex)
	local lisc = RankListUtils:GetListPage(self.curList,self.curPage);
	if not lisc then return end;
	--if RankListUtils:GetListLenght(self.curList) <= 0 then return end;
	local voc = {}
	for i,info in ipairs(lisc) do
		local vo = RankListUtils:GetRoleItemUIdata(info,self.curItemindex)
		if not vo then break end;
		table.push(voc,vo)
	end;
	objSwf.listtxt.dataProvider:cleanUp();
	objSwf.listtxt.dataProvider:push(unpack(voc));
	objSwf.listtxt:invalidateData();
	objSwf.listtxt.selectedIndex = 0;
	self:SetMyItemInfo();
	-- 设置当前已经是最前
	self:SetPagebtn();
	self:ShowRightPanel(lisc)
	-- 设置文本框
	objSwf.kuang:gotoAndStop(self.curItemindex)
end;
function UIAllTheServerRankView:OnHide()
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
end;

function UIAllTheServerRankView:SetRankType(type)
	local  objSwf = self.objSwf;
	objSwf.ranktype1.textField.text = string.format(StrConfig["ranktype00"..type]);
end;

-- 设置我的数据
function UIAllTheServerRankView:SetMyItemInfo()
	local strxy = RankListConsts.TabPage[self.curItemindex]
	local objSwf = self.objSwf;
	local vodata = {};
	vodata.roleName = MainPlayerModel.humanDetailInfo.eaName
	local info = RankListUtils:FindMyDesc(self.curList,vodata.roleName);
	if not info then info={} end;
	if not info.rank then info.rank = string.format(StrConfig["rankstr101"]); end;
	vodata.rank = info.rank -- 这里被干掉了
	vodata.lvl = MainPlayerModel.humanDetailInfo.eaLevel
	vodata.role = MainPlayerModel.humanDetailInfo.eaProf
	vodata.fight = MainPlayerModel.humanDetailInfo.eaFight
	vodata.mountId = MountModel.ridedMount.mountLevel;
	vodata.jingjieVlue = RealmModel:GetRealmOrder(); --   境界等级
	local cfglingshou = t_wuhun[SpiritsModel:GetWuhunId()]; -- 灵兽等级
	if not cfglingshou then 
		vodata.lingshouName = "";
		vodata.lingshouOrder = 0;
	else
		vodata.lingshouName = cfglingshou.name;
		vodata.lingshouOrder = cfglingshou.order;
	end;
	vodata.killNum = 0; --极限挑战 bos 
	vodata.monsterNum = 0; -- 极限挑战 monster


	vodata.vipLvl = MainPlayerModel.humanDetailInfo.eaVIPLevel;  -- vip 等级
	vodata.vflag = VplanModel:GetVFlag() -- v计划等级
	vodata.sbValue = MagicWeaponModel:GetLevel() or 0;-- 神兵
	local cfgShengb = t_shenbing[vodata.sbValue]
	if cfgShengb then
		vodata.sbName = cfgShengb.name;
	else
		vodata.sbName = "";
	end;

	--[[vodata.myValue = MingYuModel:GetLevel() or 0;-- 玉佩
	local cfgMingYu = t_mingyu[vodata.myValue]
	if cfgMingYu then
		vodata.myName = cfgMingYu.name;
	else
		vodata.myName = "";
	end;
]]
	local vo = UIData.decode(RankListUtils:GetRoleItemUIdata(vodata,self.curItemindex))
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
	objSwf.myitem:setData(UIData.encode(vo));
end;
------ 消息处理 ---- 
function UIAllTheServerRankView:ListNotificationInterests()
	return {
		NotifyConsts.AllTheServerListUpdata,
		NotifyConsts.StageClick,
		NotifyConsts.StageFocusOut,
		NotifyConsts.PlayerAttrChange,
		}
end;
function UIAllTheServerRankView:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False`
	if name == NotifyConsts.AllTheServerListUpdata then 
		-- 显示人物等级list
		self:ShowInitList()
	elseif name == NotifyConsts.StageFocusOut or name == NotifyConsts.StageClick then 
		self:OnIpSearchFocusOut();
	elseif name == NotifyConsts.PlayerAttrChange then 
		if body.type == enAttrType.eaLevel then 
			self:InitFunction();
		end;
	end;

end;

-- 人物list nameclick
function UIAllTheServerRankView:RolenameItemClick(e)
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
	UIRankListOper:Open(friendVO,0,false);
end;

function UIAllTheServerRankView:ShowRightPanel(lisc)
	if not lisc[1] then return end;
	self.roleId = lisc[1].roleid;
	local e = {};
	e.item = {};
	e.item.roleid = self.roleId
	self:RoleItemClick(e )
end;


-- 人物list itemclick
function UIAllTheServerRankView:RoleItemClick(e)
	local roleid = e.item.roleid;
	self.roleId = roleid;

	if self.curItemindex == RankListConsts.LvlRank 
	or self.curItemindex == RankListConsts.FigRank 
	or self.curItemindex == RankListConsts.jingJie
	or self.curItemindex == RankListConsts.JixianBoss
	or self.curItemindex == RankListConsts.JixianMonster
	then 
		RankListController:AtServerReqRoleinfo(roleid,0,2);
	elseif self.curItemindex == RankListConsts.ZuoRank then 
		local typemount =  OtherRoleConsts.OtherRole_Mount;
		RankListController:AtServerReqRoleinfo(roleid,typemount,2);
	elseif self.curItemindex == RankListConsts.Lingshou then 
		local typeLingshow =  OtherRoleConsts.OtherRole_Spirits;
		local roleinfo = OtherRoleConsts.OtherRole_Base;
		RankListController:AtServerReqRoleinfo(roleid,typeLingshow + roleinfo,2);
	-- elseif self.curItemindex == RankListConsts.LingZhen then 
	-- 	local typelingzhen = OtherRoleConsts.OtherRole_LingZhen;
	-- 	local roleinfo = OtherRoleConsts.OtherRole_Base;
	-- 	RankListController:AtServerReqRoleinfo(roleid,typelingzhen + roleinfo,2);
	-- elseif self.curItemindex == RankListConsts.Shengbing then 
	-- 	local typeshengbing = OtherRoleConsts.OtherRole_ShengBing;
	-- 	local roleinfo = OtherRoleConsts.OtherRole_Base;
	-- 	RankListController:AtServerReqRoleinfo(roleid,typeshengbing + roleinfo,2);
	end;
end;

---翻页控制
-- 最前
function UIAllTheServerRankView:PagePre1()
	local objSwf = self.objSwf;
	self.curPage = 0;
	UIAllTheServerRankView:ShowInitList()
end;
-- 前
function UIAllTheServerRankView:PagePre()
	local objSwf = self.objSwf;
	self.curPage = self.curPage-1;
	UIAllTheServerRankView:ShowInitList()
end;
-- 最后
function UIAllTheServerRankView:PageNext1()
	local objSwf = self.objSwf;
	local len = RankListUtils:GetListLenght(self.curList)
	self.curPage = len;
	UIAllTheServerRankView:ShowInitList()
end;
-- 后
function UIAllTheServerRankView:PageNext()
	local objSwf =self.objSwf;
	self.curPage = self.curPage+1;
	local len = RankListUtils:GetListLenght(self.curList)
	UIAllTheServerRankView:ShowInitList()
end;

function UIAllTheServerRankView:SetPagebtn()
	local objSwf = self.objSwf;
	local curpage = self.curPage+1;
	local curTotal = RankListUtils:GetListLenght(self.curList)+1;
	objSwf.txtPage.text = string.format(StrConfig["rankstr004"],curpage,curTotal)
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
-- 搜索 
function UIAllTheServerRankView:OnFindClick()
	local objSwf = self.objSwf;
	local txt = objSwf.input.text;
	if txt == "" then 
		--return;
	end;
	local resuVo = RankListUtils:FindDesc(self.curList,txt)

	if #resuVo == 0 then 
		FloatManager:AddNormal(StrConfig['rankstr002']);
		return ;
	end;
	local voc = {};
	local vo = {};
	for i,info in ipairs(resuVo) do 
		local vo = RankListUtils:GetRoleItemUIdata(info,self.curItemindex)
		table.push(voc,vo)
	end;
	objSwf.listtxt.dataProvider:cleanUp();
	objSwf.listtxt.dataProvider:push(unpack(voc));
	objSwf.listtxt:invalidateData();

	objSwf.btnPre1.disabled = true;
	objSwf.btnPre.disabled = true;
	objSwf.btnNext.disabled = true;
	objSwf.btnNext1.disabled = true;
	local len = RankListUtils:GetListLenght(resuVo)
	if len <= 0 then 
		len = 1;
	end;
	objSwf.txtPage.text = "1/"..len
end;
--输入文本失去焦点
function UIAllTheServerRankView:OnIpSearchFocusOut()
	local objSwf = self.objSwf
	if not objSwf then return; end
	if objSwf.input.focused then
		objSwf.input.focused = false;
	end
end

function UIAllTheServerRankView:CloseRightPanle()
	-- if UIRankListRightMount:IsShow() then 
	-- 	UIRankListRightMount:Hide();
	-- end;
	-- if UIRankListRightRole:IsShow() then 
	-- 	UIRankListRightRole:Hide();
	-- end;
end;