--[[
    Created by IntelliJ IDEA.
    战印/灵宝 兑换商店界面
    User: Hongbin Yang
    Date: 2016/8/8
    Time: 10:05
   ]]


_G.UIWarPrintExchange = BaseUI:new("UIWarPrintExchange")

UIWarPrintExchange.curSelectedTab = 0;
--用page作为key
UIWarPrintExchange.tabButton = {};
UIWarPrintExchange.exchangeConfirmID = nil;
function UIWarPrintExchange:Create()
	self:AddSWF("spiritWarPrintExchange.swf", true, "center")
end


function UIWarPrintExchange:OnShow()
	self:InitView();
end


function UIWarPrintExchange:OnLoaded(objSwf)
	objSwf.closepanel.click = function() self:OnClosePanel() end;

	objSwf.exchangeList.exchangeClick = function(e) self:OnExchangeClick(e) end
	objSwf.exchangeList.lingBaoRollOver = function(e) self:OnLingBaoRollOver(e) end
	objSwf.exchangeList.lingBaoRollOut = function(e) self:OnLingBaoRollOut(e) end
end


function UIWarPrintExchange:InitView()
	self:InitTabButton();

	for name, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(name); end;
	end

	-- 查看args中第一位的参数有没有，如果有的话，说明是要直接跳转到某一个tab
	if #self.args > 0 then
		local args1 = tonumber(self.args[1]);
		if self.tabButton[args1] then
			self:OnTabButtonClick(args1);
			return;
		end
	end
	-- 默认打开第一个tab
	self:OnTabButtonClick(1);
end

function UIWarPrintExchange:InitTabButton()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.tabButton = {};
	for k, v in pairs(t_zhanyinexchangepage) do
		local depth = objSwf:getNextHighestDepth();
		local tab = objSwf:attachMovie("WarPrirntExchangeTabButton", "tabButton" .. v.page, depth);
		tab.label = v.pagename;
		tab.group = "exchangeTabGroup";
		self.tabButton[toint(v.page)] = tab;
	end
	UIDisplayUtil:HLayout(self.tabButton, 92, 48, 62);
end

--点击标签
function UIWarPrintExchange:OnTabButtonClick(page)
	self:UpdateExchange(page);
end

function UIWarPrintExchange:UpdateExchange(page)
	if not self:IsShow() then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.curSelectedTab = page;
	self.tabButton[page].selected = true;
	local cfg = WarPrintUtils:GetExchangeCFGListByPage(page);
	local eItems = {};
	for k, v in pairs(cfg) do
		local zhanyinCFG = t_zhanyin[v.id];
		local vo = {};
		vo.tid = toint(v.id);
		vo.targetIconUrl = ResUtil:GetSpiritWarPrintIconURL(zhanyinCFG.iconName);
		vo.targetLv = string.format("Lv.%s", zhanyinCFG.lvl);
		vo.targetNameTxt = string.format("%s", zhanyinCFG.name);
		local matList = {};
		local needCFGList = split(v.lingbao, "#");
		local canExchange = 1;
		for matK, matV in pairs(needCFGList) do
			local matID = toint(split(matV, ",")[1]);
			local matNeedNum = toint(split(matV, ",")[2]);
			local matCFG = t_zhanyin[matID];
			if matCFG then
				local matVO = {};
				matVO[1] = ResUtil:GetSpiritWarPrintIconURL(matCFG.iconName);
				matVO[2] = string.format("%s", matCFG.name);
				--检查背包和仓库共有多少个这个灵宝
				local hasNum = WarPrintUtils:GetItemNumByID(WarPrintModel.spirit_Bag, matID) + WarPrintUtils:GetItemNumByID(WarPrintModel.spirit_House, matID);
				if hasNum >= matNeedNum then
					matVO[3] = string.format("<font color='#00FF00'>%s/%s</font>", hasNum, matNeedNum);
				else
					matVO[3] = string.format("<font color='#FF0000'>%s/%s</font>", hasNum, matNeedNum);
				end
				matVO[4] = matID;
				matVO[5] = string.format("Lv.%s", matCFG.lvl);
				if hasNum < matNeedNum then
					canExchange = 0;
				end
				table.push(matList, matVO);
			end
		end
		table.sort(matList, function(a, b)
			return a[4] > b[4];
		end);
		for k1, v1 in pairs(matList) do
			matList[k1] = table.concat(matList[k1], "&");
		end
		--以下部分是固定添加的天河星沙显示
		local tianheCFG = t_zhanyin[WarPrintModel.tianHeXingShaID]; --天河星沙  写死 固定ID
		local tianheMat = {};
		tianheMat[1] = ResUtil:GetSpiritWarPrintIconURL(tianheCFG.iconName);
		tianheMat[2] = string.format("%s", tianheCFG.name);
		if WarPrintModel.curDebris >= v.num then
			tianheMat[3] = string.format("<font color='#00FF00'>%s/%s</font>", WarPrintModel.curDebris, v.num);
		else
			tianheMat[3] = string.format("<font color='#FF0000'>%s/%s</font>", WarPrintModel.curDebris, v.num);
		end
		tianheMat[4] = tianheCFG.id;
		tianheMat[5] = "";
		if WarPrintModel.curDebris < v.num then
			canExchange = 0;
		end
		table.push(matList, table.concat(tianheMat, "&"));

		vo.xianjieTipTxt = "";
		if HuoYueDuModel:GetHuoyueLevel() < v.xianjie then
			vo.xianjieTipTxt = string.format(StrConfig["warprintstore034"], v.xianjie);
			canExchange = 0;
			end
		vo.canExchange = canExchange;
		vo.matStr = table.concat(matList, "*");
		table.push(eItems, vo);
	end
	table.sort(eItems, function(a, b)
							return a.tid < b.tid;
						end);
	for k, v in pairs(eItems) do
		eItems[k] = UIData.encode(eItems[k]);
	end
	objSwf.exchangeList.dataProvider:cleanUp();
	objSwf.exchangeList.dataProvider:push(unpack(eItems));
	objSwf.exchangeList:invalidateData();
end

function UIWarPrintExchange:OnExchangeClick(e)
	local exchangeCFG = t_zhanyinexchange[e.item];
	if exchangeCFG.xianjie > HuoYueDuModel:GetHuoyueLevel() then
		FloatManager:AddNormal(string.format(StrConfig["warprintstore031"], exchangeCFG.xianjie));
		return;
	end
	if exchangeCFG.num > WarPrintModel.curDebris then
		FloatManager:AddNormal(string.format(StrConfig["warprintstore032"], exchangeCFG.num));
		return;
	end
	local okfunc = function()
		WarPrintController:OnReqStoreItem(e.item, 1)
	end;
	local zhanyinCFG = t_zhanyin[exchangeCFG.id];
	local color = TipsConsts:GetItemQualityColor(zhanyinCFG.quality);
	self.exchangeConfirmID = UIConfirm:Open(string.format(StrConfig["warprintstore035"], color, zhanyinCFG.name, zhanyinCFG.lvl),okfunc);
end

function UIWarPrintExchange:OnLingBaoRollOver(e)
	local tipsvo = WarPrintUtils:OnGetStoreItemTipsVO(toint(e.item));
	if not tipsvo then
		print("Log : itemdata UIWarPrintEquip #85")
		return
	end;
	TipsManager:ShowTips(TipsConsts.Type_SpiritWarPrint, tipsvo, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

function UIWarPrintExchange:OnLingBaoRollOut(e)
	TipsManager:Hide();
end

function UIWarPrintExchange:OnClosePanel()
	self:Hide();
end

function UIWarPrintExchange:OnHide()
	if self.exchangeConfirmID then
		UIConfirm:Close(self.exchangeConfirmID);
	end;
	for k, v in pairs(self.tabButton) do
		v:removeMovieClip();
		v = nil;
	end
	self.tabButton = nil;
end


function UIWarPrintExchange:ListNotificationInterests()
	return {
		NotifyConsts.SpiritWarPrintDebris,
	}
end

function UIWarPrintExchange:HandleNotification(name, body)
	if not self.bShowState then return end;
	if name == NotifyConsts.SpiritWarPrintDebris then
		self:UpdateExchange(self.curSelectedTab);
	end;
end
