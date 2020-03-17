--[[
	2014年12月24日, PM 12:24:17
	帮派外交
	wangyanwei
]]
_G.UIDiplomacyPanel = BaseUI:new("UIDiplomacyPanel");


function UIDiplomacyPanel:Create()
	self:AddSWF("unionDiplomacyPanel.swf", true, nil);
end

function UIDiplomacyPanel:OnLoaded(objSwf)
	objSwf.txt_fuli.htmlText = UIStrConfig['union200'];
	objSwf.dippanel._visible = not objSwf.dippanel._visible;
	objSwf.btn_1.selected = true;
	objSwf.dippanel.btn_close.click = function () objSwf.dippanel._visible = false; end
	objSwf.btn_1.click = function () self:OnShowDipPanel() end 
	objSwf.btn_2.click = function () self:OnShowUnionInfo() end 
	
	objSwf.dippanel.btn_submit.click = function () self:OnSendDiplomacyHandler() end  --申请结盟 
	
	objSwf.basePanel.txt_1.text = UIStrConfig['union10'];
	objSwf.basePanel.txt_2.text = UIStrConfig['union7'];
	objSwf.basePanel.txt_3.text = UIStrConfig['union11'];
	objSwf.basePanel.txt_4.text = UIStrConfig['union9'];
	objSwf.basePanel.txt_5.text = UIStrConfig['union8'];
	objSwf.basePanel.txt_6.text = UIStrConfig['union12'];
	objSwf.dippanel.listPlayer.itemClick = function (e)
		self.guiId = e.item.guildId;
		self.guildName = e.item.name;
		self.guildLevel = e.item.levelNum;
	end
end

function UIDiplomacyPanel:OnShow()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.appPanel._visible = false;
	objSwf.basePanel._visible = true;
	if UnionModel.MyUnionInfo.pos < 5 then 
		objSwf.btn_2._visible = false;
	end
	if UnionModel.MyUnionInfo.level < 2 then
		objSwf.maskPage._visible = true;
		objSwf.maskPage.txt_need.htmlText = UIDiplomacyPanel:OnChangeDiplomacyTxtInfo();
		objSwf.maskPage.diplomacy_btn.disabled = true;
		objSwf.basePanel.txt_unionName.htmlText = UIStrConfig['union154'];
		objSwf.basePanel.txt_bossName.htmlText = UIStrConfig['union154'];
		objSwf.basePanel.txt_unionLevel.htmlText = UIStrConfig['union154'];
		objSwf.basePanel.txt_unionRank.htmlText = UIStrConfig['union154'];
		objSwf.basePanel.txt_unionPower.htmlText = UIStrConfig['union154'];
		objSwf.basePanel.txt_unionMemcnt.htmlText = UIStrConfig['union154'];
		objSwf.btn_1.disabled = true;
		objSwf.btn_2.disabled = true;
	else
		if UnionModel.MyUnionInfo.alianceGuildId == "0_0" then
			objSwf.maskPage._visible = true;
			objSwf.maskPage.txt_need.htmlText = UIDiplomacyPanel:OnChangeDiplomacyTxtInfo();
			objSwf.maskPage.diplomacy_btn.disabled = false;
			objSwf.basePanel.txt_unionName.htmlText = UIStrConfig['union154'];
			objSwf.basePanel.txt_bossName.htmlText = UIStrConfig['union154'];
			objSwf.basePanel.txt_unionLevel.htmlText = UIStrConfig['union154'];
			objSwf.basePanel.txt_unionRank.htmlText = UIStrConfig['union154'];
			objSwf.basePanel.txt_unionPower.htmlText = UIStrConfig['union154'];
			objSwf.basePanel.txt_unionMemcnt.htmlText = UIStrConfig['union154'];
			objSwf.basePanel.list.visible = false;
			objSwf.btn_1.disabled = false;
			objSwf.btn_2.disabled = false;
		else
			objSwf.maskPage._visible = false;
			objSwf.btn_1.disabled = false;
			objSwf.btn_2.disabled = false;
			objSwf.basePanel.list.visible = true;
			UnionController:ReqSendDipPlayerList();
			objSwf.maskPage.txt_need.htmlText = UIDiplomacyPanel:OnChangeDiplomacyTxtInfo();
		end
	end	
	objSwf.maskPage.diplomacy_btn.click = function () self:OnDiplomacyClickHandler(); end
	objSwf.basePanel.btn_diss.disabled = UnionModel.MyUnionInfo.alianceGuildId == "0_0";
end

--点击建立同盟请求显示帮派列表
UIDiplomacyPanel.curPage = 1;
UIDiplomacyPanel.totalpages = 0; --一共的页数
function  UIDiplomacyPanel:OnDiplomacyClickHandler()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	if UnionModel.MyUnionInfo.pos < 5 then 
		FloatManager:AddNormal( StrConfig['union107'] );
		return ;
	end
	objSwf.dippanel._visible = not objSwf.dippanel._visible;
	UnionController:ReqGuildList(self.curPage, 0);
	objSwf.dippanel.btnPre.click = function ()
		if self.curPage < 2 then return end
		self.curPage = self.curPage - 1; 
		UnionController:ReqGuildList(self.curPage, 0);
	end
	objSwf.dippanel.btnPre1.click = function () 
		if self.curPage == 1 then return end
		self.curPage = 1;
		UnionController:ReqGuildList(self.curPage, 0);
	end
	objSwf.dippanel.btnNext.click = function () 
		if self.curPage == self.totalpages then return end
		self.curPage = self.curPage + 1;
		UnionController:ReqGuildList(self.curPage, 0);
	end
	objSwf.dippanel.btnNext1.click = function () 
		if self.curPage == self.totalpages then return end
		self.curPage = self.totalpages;
		UnionController:ReqGuildList(self.curPage, 0);
	end
end

--申请结盟
function UIDiplomacyPanel:OnSendDiplomacyHandler()
	if UnionModel.MyUnionInfo.guildId == self.guiId then
		FloatManager:AddNormal( StrConfig['union105'] );
		return ;
	end
	local func = function () 
		if self.guildLevel < 2 then
			FloatManager:AddNormal( StrConfig['union108'] );
			return 
		end
		UnionController:ReqSendDiplomacyGuild(self.guiId);
		FloatManager:AddNormal( StrConfig['union109'] );
	end
	UIConfirm:Open(string.format(UIStrConfig['union190'],self.guildName),func);
end

--显示出所有帮派的信息
UIDiplomacyPanel.guiId = 0;
UIDiplomacyPanel.guildName = 0;
UIDiplomacyPanel.guildLevel = 0;
function UIDiplomacyPanel:OnShowAllUnionInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.dippanel.listPlayer.dataProvider:cleanUp();
	local list = UnionModel.UnionsList;
	for i , v in ipairs (list) do
		local obj = {};
		obj.index = v.rank;
		obj.guildId = v.guildId;
		obj.name = v.guildName;
		obj.level = v.level .. "级";
		obj.levelNum = v.level;
		obj.capa = v.power;
		obj.playerNum = v.memCnt;
		objSwf.dippanel.listPlayer.dataProvider:push(UIData.encode(obj));
	end
	self.guiId = list[1].guildId;
	self.guildName = list[1].guildName;
	objSwf.dippanel.listPlayer.selectedIndex = 0;
	objSwf.dippanel.listPlayer:invalidateData();
	self:OnChangeBtnState();
end	
--改变换页按钮的状态
function UIDiplomacyPanel:OnChangeBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local mc = objSwf.dippanel;
	mc.btnPre1.disabled = false;
	mc.btnPre.disabled = false;
	mc.btnNext.disabled = false;
	mc.btnNext1.disabled = false;
	if self.curPage == 1 then 
		mc.btnPre1.disabled = true;
		mc.btnPre.disabled = true;
	end
	if self.curPage == self.totalpages then
		mc.btnNext.disabled = true;
		mc.btnNext1.disabled = true;
	end
	mc.txtPage.text = self.curPage..'/'..self.totalpages;
end
--显示申请列表
function UIDiplomacyPanel:OnShowUnionInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.dippanel._visible = false;
	objSwf.maskPage._visible = false;
	objSwf.basePanel._visible = false;
	
	objSwf.appPanel._visible = true;
	
	UnionController:ReqSendAppDipList();
end
--清除申请列表
function UIDiplomacyPanel:OnClearList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.appPanel.list.dataProvider:cleanUp();
end
--给列表刷数据
function UIDiplomacyPanel:OnChangeAppDipList(body)
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.appPanel.list.dataProvider:cleanUp();
	if body == {} then return end
	for i , v in pairs(body) do
		if v ~= {} then
			local obj = {};
			obj.unionName = v.name;
			obj.unionLevel = v.level;
			obj.unionPower = v.power;
			obj.unionPlayerNum = v.memCnt;
			obj.unionTime = self:OnBackNowLeaveTime(v.time); --v.time;
			obj.id = v.id;
			objSwf.appPanel.list.dataProvider:push(UIData.encode(obj));
			end
	end
	objSwf.appPanel.list:invalidateData();
	objSwf.appPanel.list.btnApplyClick = function(e) 
		if UnionModel.MyUnionInfo.alianceGuildId ~= "0_0" then FloatManager:AddNormal( StrConfig['union106'] ); return end
		local obj1 = {}; 
		obj1.verify = 0; 
		obj1.list = {};
		table.push(obj1.list,{});
		obj1.list[1].guild = e.item.id;
		UnionController:ReqSendDipVerify(obj1);
		FloatManager:AddNormal( t_sysnotice[2005058].text );
	end
	objSwf.appPanel.list.btnCancelClick = function(e) 
		local obj = {};
		obj.verify = 1;
		obj.list = {};
		table.push(obj.list,{});
		obj.list[1].guild = e.item.id;
		UnionController:ReqSendDipVerify(obj);
		FloatManager:AddNormal( t_sysnotice[2005059].text );
		--单个忽略
	end
	objSwf.appPanel.btn_allLose.click = function () 
		if UnionModel.DipAppList == {} then return end
		local obj = {};
		obj.verify = 1;
		for i , v  in pairs(UnionModel.DipAppList) do
			obj.list = {};
			local cfg = {};
			cfg.guild = v.id;
			table.push(obj.list,cfg);
		end
		UnionController:ReqSendDipVerify(obj);
		FloatManager:AddNormal( t_sysnotice[2005060].text );
		--全部忽略
	end
end
--显示同盟界面
function UIDiplomacyPanel:OnShowDipPanel()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.dippanel._visible = false;
	objSwf.appPanel._visible = false;
	objSwf.basePanel._visible = true;
	if UnionModel.MyUnionInfo.level < 2 then
		objSwf.maskPage._visible = true;
	else
		if UnionModel.MyUnionInfo.alianceGuildId == "0_0" or not UnionModel.MyUnionInfo.alianceGuildId then
			objSwf.maskPage._visible = true;
		else
			objSwf.maskPage._visible = false;
		end
	end
	
	 UnionController:ReqSendDipPlayerList();
end
--根据当前帮派的信息 来改变建立同盟帮派需求的文本
function UIDiplomacyPanel:OnChangeDiplomacyTxtInfo()
	local str = "";
	if UnionModel.MyUnionInfo.level < 2 then
		str = StrConfig['union100'] .. string.format(StrConfig['union101'],2) .. StrConfig['union103'];
	else
		str = StrConfig['union100'] .. string.format(StrConfig['union102'],2) .. StrConfig['union104'];
	end
	return str ;
end

--打开同盟成员的列表
function UIDiplomacyPanel:OnShowDipplayerList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_1.selected = true;
	objSwf.btn_2.selected = false;
	--隐藏掉一些冲突的
	objSwf.dippanel._visible = false;
	objSwf.maskPage._visible = false;
	objSwf.appPanel._visible = false;
	--显示同盟队友的list
	objSwf.basePanel.list._visible = true;
	objSwf.basePanel._visible = true;
	
	local cfg = UnionModel.dipPlayerList;
	if cfg == {} then 
		objSwf.basePanel.list._visible = false;
		objSwf.basePanel._visible = true;
		objSwf.maskPage._visible = true;
		return;
	end
	objSwf.basePanel.txt_unionName.text = cfg.guildName;
	--objSwf.txt_bossName.text = cfg.
	objSwf.basePanel.txt_unionLevel.text = cfg.level;
	objSwf.basePanel.txt_unionRank.text = cfg.rank;
	objSwf.basePanel.txt_unionPower.text = cfg.power;
	objSwf.basePanel.txt_unionMemcnt.text = cfg.memCnt;
	local cfg = cfg.GuildMemList;
	if not cfg then return end
	
	objSwf.basePanel.list.dataProvider:cleanUp();
	
	for i , v in ipairs (cfg) do
		local obj = {};
		obj.index = v.name;
		print(v.time);
		obj.playerNum = self:OnBackNowLeaveTime(v.time);
		obj.name = v.level;
		obj.capa = v.power;
		obj.level = UnionUtils:GetOperDutyName(v.pos);
		if v.pos == 5 then objSwf.basePanel.txt_bossName.text = v.name ; end
		if v.online == 1 then obj.playerNum = "在线"; end
		objSwf.basePanel.list.dataProvider:push(UIData.encode(obj));
	end
	objSwf.basePanel.list:invalidateData();
	objSwf.basePanel.btn_diss.click = function () 
		local func = function () 
			UnionController:ReqSendDissDiplomacy(); 
		end
		local cfg = UnionModel.dipPlayerList;
		UIConfirm:Open(string.format(UIStrConfig["union191"],cfg.guildName),func);
	end
end

--同盟被解散或主动解散
function UIDiplomacyPanel:OnChangeeDipPanel()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.basePanel.list.visible = false;
	objSwf.basePanel.list.dataProvider:cleanUp();
	objSwf.basePanel.list:invalidateData();
	objSwf.basePanel._visible = true;
	objSwf.maskPage._visible = true;objSwf.appPanel._visible = false;
	objSwf.dippanel._visible = false;
	objSwf.basePanel.txt_unionName.htmlText = UIStrConfig['union154'];
	objSwf.basePanel.txt_bossName.htmlText = UIStrConfig['union154'];
	objSwf.basePanel.txt_unionLevel.htmlText = UIStrConfig['union154'];
	objSwf.basePanel.txt_unionRank.htmlText = UIStrConfig['union154'];
	objSwf.basePanel.txt_unionPower.htmlText = UIStrConfig['union154'];
	objSwf.basePanel.txt_unionMemcnt.htmlText = UIStrConfig['union154'];
	
	objSwf.btn_1.selected = true;
	objSwf.btn_2.selected = false;
end

--关闭面板
function UIDiplomacyPanel:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.dippanel._visible = false;
	objSwf.btn_1.selected = true;
	objSwf.btn_2.selected = false;
end

--换算求时间
--@ _time 传入上次登录的时间
function UIDiplomacyPanel:OnBackNowLeaveTime(_time)
	local nowTime = GetServerTime();
	if not _time then _time = 0 end
	local day,hour,min = CTimeFormat:sec2formatEx(nowTime - _time);
	if day > 0 then 
		return day .. "天前";
	elseif hour > 0 then 
		return hour .. "小时前";
	else
		return min .. "分钟前";
	end
end

-----------------------------------------------------------------------------------
------------------------------        UI      -------------------------------------
-----------------------------------------------------------------------------------
function UIDiplomacyPanel:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.UnionListUpdate then
		self.totalpages = body.pages;
		self:OnShowAllUnionInfo()
	elseif name == NotifyConsts.UpdateDiplomacy then
		self:OnChangeeDipPanel();
		--结盟解散
	elseif name == NotifyConsts.UpdateDiplomacyPlayer then
		UnionController:ReqSendDipPlayerList();
	elseif name == NotifyConsts.UpdateDiplomacyPlayerList then
		self:OnShowDipplayerList(body);
		--有了同盟
	elseif name == NotifyConsts.UpdateDiplomacyList then
		--有列表了
		self:OnChangeAppDipList(body);
	end
	
end
function UIDiplomacyPanel:ListNotificationInterests()
	return {
		NotifyConsts.UnionListUpdate,NotifyConsts.UpdateDiplomacy,NotifyConsts.UpdateDiplomacyPlayer,NotifyConsts.UpdateDiplomacyList,
		NotifyConsts.UpdateDiplomacyPlayerList
	}
end