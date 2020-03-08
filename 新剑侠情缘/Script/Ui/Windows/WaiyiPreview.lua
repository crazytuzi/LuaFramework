local tbUi = Ui:CreateClass("WaiyiPreview");

tbUi.tbOnDrag =
{
	ShowRole = function (self, szWnd, nX, nY)
		self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
	end,
}

tbUi.WAI_BG = 1;                       --当前选中背景Ui
tbUi.BTNLEVEL = 0;                     --等级
tbUi.BTNCORNER = 2;                    --江湖
tbUi.BTNSHOP = 3;                      --商店

tbUi.BTNOPEN = true;                   --画卷打开状态
tbUi.BTNCLOSE = false;                 --画卷关闭状态

local tbTabMainName =
{
	[tbUi.BTNLEVEL] = "BtnLevel",
	[tbUi.BTNCORNER] = "BtnCorners",
	[tbUi.BTNSHOP] = "BtnShop",
}

tbUi.tbOnClick =
{
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnColour = function (self)                                            --卸下 装备 染色
		if self.fnCallback then
			self.fnCallback(self, self.varParam);
		end
	end,
	BtnPlus = function (self)                                             --染色是否要打开商店
		Ui:OpenWindow("CommonShop", "Treasure", "tabAllShop", Item.tbChangeColor.CONSUME_ITEM);
	end,
	Arms = function (self)
		self:ChangeFeature()
		if self.nWaiyiPos == Item.EQUIPPOS_WAI_HORSE then
			self.pPanel:NpcView_ChangeDir("ShowRole", 180, false);
		end
		if self.nWaiyiPos ~= Item.EQUIPPOS_WAI_WEAPON then
			self.tbSelect[self.nWaiyiPos] = self.nSelectId;          --先再之前部位保存最后一次选中的nSelectId
			self.nWaiyiPos = Item.EQUIPPOS_WAI_WEAPON                --更换选中的部位
			self.nSelectId = self.tbSelect[self.nWaiyiPos];
		end

		local tbColorItem = Item.tbChangeColor:GetColorItemAndSortGroup()
		self.nCurTabMain = (self.nSelectId and tbColorItem[self.nSelectId].nGenre) or tbUi.BTNLEVEL;   --获取当前选中的部位外装为等级还是商店还是江湖

		self:Update()
		if self.nStartIndex then
			self.ScrollView.pPanel:ScrollViewGoToIndex("Main", self.nStartIndex)
		end
		self:RefreshList();
	end,
	Clothes = function (self)
		self:ChangeFeature()
		if self.nWaiyiPos == Item.EQUIPPOS_WAI_HORSE then
		 	self.pPanel:NpcView_ChangeDir("ShowRole", 180, false);
		end
		if self.nWaiyiPos ~= Item.EQUIPPOS_WAIYI then
			self.tbSelect[self.nWaiyiPos] = self.nSelectId;
			self.nWaiyiPos = Item.EQUIPPOS_WAIYI;
			self.nSelectId = self.tbSelect[self.nWaiyiPos];
		end
		local tbColorItem = Item.tbChangeColor:GetColorItemAndSortGroup()
		self.nCurTabMain = (self.nSelectId and tbColorItem[self.nSelectId].nGenre) or tbUi.BTNLEVEL;

		self:Update()
		if self.nStartIndex then
			self.ScrollView.pPanel:ScrollViewGoToIndex("Main", self.nStartIndex)
		end
		self:RefreshList();
	end,
	Headdress = function (self)
		self:ChangeFeature()
		if self.nWaiyiPos == Item.EQUIPPOS_WAI_HORSE then
			self.pPanel:NpcView_ChangeDir("ShowRole", 180, false);
		end
		if self.nWaiyiPos ~= Item.EQUIPPOS_WAI_HEAD then
			self.tbSelect[self.nWaiyiPos] = self.nSelectId;
			self.nWaiyiPos = Item.EQUIPPOS_WAI_HEAD
			self.nSelectId = self.tbSelect[self.nWaiyiPos];
		end
		local tbColorItem = Item.tbChangeColor:GetColorItemAndSortGroup()
		self.nCurTabMain = (self.nSelectId and tbColorItem[self.nSelectId].nGenre) or tbUi.BTNLEVEL;

		self:Update()
		if self.nStartIndex then
			self.ScrollView.pPanel:ScrollViewGoToIndex("Main", self.nStartIndex)
		end
		self:RefreshList();
	end,
	Mount = function (self)
		self:ChangeHorse()
		if self.nWaiyiPos ~= Item.EQUIPPOS_WAI_HORSE then
			self.pPanel:NpcView_ChangeDir("ShowRole", 220, false);
		end
		if self.nWaiyiPos ~= Item.EQUIPPOS_WAI_HORSE then
			self.tbSelect[self.nWaiyiPos] = self.nSelectId;
			self.nWaiyiPos = Item.EQUIPPOS_WAI_HORSE
			self.nSelectId = self.tbSelect[self.nWaiyiPos];
		end
		self.nCurTabMain = tbUi.BTNLEVEL;

		self:Update()
		if self.nStartIndex then
			self.ScrollView.pPanel:ScrollViewGoToIndex("Main", self.nStartIndex)
		end
		self:RefreshList();
	end,
	Pendant = function (self)
		self:ChangeFeature()
		if self.nWaiyiPos == Item.EQUIPPOS_WAI_BACK then
			self.pPanel:NpcView_ChangeDir("ShowRole", 180, false);
		end
		if self.nWaiyiPos ~= Item.EQUIPPOS_WAI_BACK then
			self.tbSelect[self.nWaiyiPos] = self.nSelectId;
			self.nWaiyiPos = Item.EQUIPPOS_WAI_BACK
			self.nSelectId = self.tbSelect[self.nWaiyiPos];
		end
		self.nCurTabMain = tbUi.BTNLEVEL;

		self:Update()
		if self.nStartIndex then
			self.ScrollView.pPanel:ScrollViewGoToIndex("Main", self.nStartIndex)
		end
		self:RefreshList();
	end,
	Cloak = function ( self )
		self:ChangeFeature()
		if self.nWaiyiPos == Item.EQUIPPOS_WAI_BACK2 then
			self.pPanel:NpcView_ChangeDir("ShowRole", 180, false);
		end
		if self.nWaiyiPos ~= Item.EQUIPPOS_WAI_BACK2 then
			self.tbSelect[self.nWaiyiPos] = self.nSelectId;
			self.nWaiyiPos = Item.EQUIPPOS_WAI_BACK2
			self.nSelectId = self.tbSelect[self.nWaiyiPos];
		end
		self.nCurTabMain = tbUi.BTNLEVEL;

		self:Update()
		if self.nStartIndex then
			self.ScrollView.pPanel:ScrollViewGoToIndex("Main", self.nStartIndex)
		end
		self:RefreshList();
	end,
	BgButton = function(self)
		self:ChangeFeature()
		if self.nWaiyiPos == Item.EQUIPPOS_WAI_BACK then
			self.pPanel:NpcView_ChangeDir("ShowRole", 180, false);
		end

		if self.PreviousBtn then
			self.PreviousBtn.pPanel:SetActive("Select",false);
		end
		if self.nWaiyiPos ~= tbUi.WAI_BG then
			self.tbSelect[self.nWaiyiPos] = self.nSelectId;
			self.nWaiyiPos = tbUi.WAI_BG;
			self.nSelectId = self.tbSelect[self.nWaiyiPos];
			self.nCurBgId = Item.tbChangeColor:GetWaiyiBg(me);
		end
		self.pPanel:NpcView_ChangeDir("ShowRole", 180, false);

		self:Update()
		if self.nStartIndex then
			self.ScrollView.pPanel:ScrollViewGoToIndex("Main", self.nStartIndex)
		end
		self:RefreshList();
	end,
	BtnOpen = function(self)
		if self.bBtnOpenState then
			self:CloseScroll()
		else
			self:OpenScroll()
		end
	end,
	BtnLevel = function(self)
		self.nCurTabMain = tbUi.BTNLEVEL;
		self:Update();
		if self.nStartIndex then
			self.ScrollView.pPanel:ScrollViewGoToIndex("Main", self.nStartIndex)
		end
		self:RefreshList();
	end,
	BtnCorners = function (self)
		self.nCurTabMain = tbUi.BTNCORNER;
		self:Update();
		if self.nStartIndex then
			self.ScrollView.pPanel:ScrollViewGoToIndex("Main", self.nStartIndex)
		end
		self:RefreshList();
	end,
	BtnShop = function (self)
		self.nCurTabMain = tbUi.BTNSHOP;
		self:Update();
		if self.nStartIndex then
			self.ScrollView.pPanel:ScrollViewGoToIndex("Main", self.nStartIndex)
		end
		self:RefreshList();
	end,
	BtnCollection = function(self)                                   --收藏
		local tbSetting = House:GetHorseCollectSetting(self.nSelectId)
		if not tbSetting then
			return
		end

		local data = self.tbWaiyiList[self.nSelectId]
		local _, szName = unpack(data)
		local szMsg = string.format("确认消耗[fffe0d]%d%s[-]将坐骑外装[fffe0d]%s[-]收藏吗？收藏后可将[fffe0d]%s[-]放置入家园中且不消耗外装",
			tbSetting.nPrice, Shop:GetMoneyName(tbSetting.szMoneyType), szName, szName)
		me.MsgBox(szMsg, {{"确认", function ()
			RemoteServer.HouseCollectHorse(self.nSelectId)
		end}, {"取消"}})
	end,
}

function tbUi:CloseScroll()
	self["BtnOpen"].pPanel:ChangeRotate("Sprite",0);                                                    --改变按钮方向
	self.pPanel:SetActive("TabMain",false);

	self.pPanel:Toggle_SetChecked(tbTabMainName[self.nCurTabMain], false);
	local nAnimatorLen = self.pPanel:GetAnimatorLength("Main", "DressColour_close");	                        --获取动画时间

	self.pPanel:Play_Animator("Main", "DressColour_close");
	self.bBtnOpenState = tbUi.BTNCLOSE;
	self.bNeedChangePartRes = false;

	self.nBtnCloseTimer = Timer:Register(math.ceil(Env.GAME_FPS*nAnimatorLen), function (self)
	if not self.bBtnOpenState then
		self.pPanel:SetActive("ScrollView",false);
	end
	self.nBtnCloseTimer = nil;
	end, self)
end

function tbUi:OpenScroll()
	self.pPanel:SetActive("DressColourBg",true);
	self["BtnOpen"].pPanel:ChangeRotate("Sprite",180);
	self.pPanel:Animator_SetEnabled("Main",true)
	self.bBtnOpenState = tbUi.BTNOPEN;
	self.bNeedChangePartRes = true;
	self:Update();
	if self.nStartIndex then
		self.ScrollView.pPanel:ScrollViewGoToIndex("Main", self.nStartIndex)
	end
	self:RefreshList();
	self.pPanel:SetActive("ScrollView",true);
	self.pPanel:Play_Animator("Main", "DressColour_open");
	local nAnimatorLen = self.pPanel:GetAnimatorLength("Main", "DressColour_open");

	self.nBtnOpenTimer = Timer:Register(math.ceil(Env.GAME_FPS*nAnimatorLen) + 1, function (self)
	if  self.bBtnOpenState then
		self.pPanel:SetActive("Floor",false);
		self.pPanel:SetActive("Floor",true);
		if self.bViewPlayerInform then
			self.pPanel:SetActive("Charm",false);
		else
			self.pPanel:SetActive("Charm",false);
			self.pPanel:SetActive("Charm",true);
		end
	end
	self.nBtnOpenTimer = nil;
	end, self)
end

function tbUi:OnOpen(nTemplateId, nFaction, nSex)
	if GetTimeFrameState(Item.tbPiFeng.OPEN_TIME_FRAME) == 1 then
		self.pPanel:SetActive("Cloak", true)
		self.pPanel:ChangePosition("BgButton", 231.7,13.03002)
	else
		self.pPanel:SetActive("Cloak", false)
		self.pPanel:ChangePosition("BgButton", 156,13.03001)
	end

	self["BtnOpen"].pPanel:ChangeRotate("Sprite",0);                                          --改变按键方向
	self.PreviousBtn = nil;                                                                   --背景记录上一次选中的BgItem，用来把上次的select 置为false
	self.bBtnOpenState = tbUi.BTNCLOSE;                                                       --画卷状态是关闭
	self.bNeedChangePartRes = true;                                                           --是否需要改变PartRes
	self.tbClosePage = self.tbClosePage or {};
	self.nPreviewId = Item.tbChangeColor:GetChangeId(nTemplateId);
	self.nFixFaction = me.nFaction;
	self.nSex = Player:Faction2Sex(self.nFixFaction, me.nSex);
	self.bBtnOpenState = false;

	if nTemplateId then
		self.nSelectId = nTemplateId;
		self.nFixFaction = nFaction or self.nFixFaction;
		self.nSex = Player:Faction2Sex(self.nFixFaction, self.nSex);
		self.nSex = nSex or self.nSex
		self.bViewPlayerInform = true;                                 --这个是查看玩家信息坐骑时候打开的界面需要隐藏魅力和按钮
		self.pPanel:SetActive("Charm",false);
	else
		self.bViewPlayerInform = false;
		self.pPanel:SetActive("Charm",true);
		local pCurWaiYi = me.GetEquipByPos(Item.EQUIPPOS_WAIYI);
		local pCurWaiWeapon = me.GetEquipByPos(Item.EQUIPPOS_WAI_WEAPON);
		local pCurWaiHorse = me.GetEquipByPos(Item.EQUIPPOS_WAI_HORSE);
		local pCurWaiHead = me.GetEquipByPos(Item.EQUIPPOS_WAI_HEAD);
		local pCurWaiBack = me.GetEquipByPos(Item.EQUIPPOS_WAI_BACK);
		local pCurCloak = me.GetEquipByPos(Item.EQUIPPOS_WAI_BACK2);

		self.nSelectId = Item.tbChangeColor:GetWaiyiBg(me);
		self:UpdateBg();

		self.nSelectId = pCurWaiYi and pCurWaiYi.dwTemplateId;                                 --刚开始打开的是外衣
		self.nCurBgId = Item.tbChangeColor:GetWaiyiBg(me);                                     --背景Id

		self.tbSelect =
		{
			[Item.EQUIPPOS_WAIYI]		= pCurWaiYi and pCurWaiYi.dwTemplateId,
			[Item.EQUIPPOS_WAI_WEAPON]	= pCurWaiWeapon and pCurWaiWeapon.dwTemplateId,
			[Item.EQUIPPOS_WAI_HORSE]	= pCurWaiHorse and pCurWaiHorse.dwTemplateId,
			[Item.EQUIPPOS_WAI_HEAD]   = pCurWaiHead and pCurWaiHead.dwTemplateId,
			[Item.EQUIPPOS_WAI_BACK]   = pCurWaiBack and pCurWaiBack.dwTemplateId,
			[Item.EQUIPPOS_WAI_BACK2] = pCurCloak and pCurCloak.dwTemplateId,
			[tbUi.WAI_BG] = self.nCurBgId,                                                        --背景为当前选中
		}
	end

	self.pPanel:NpcView_Open("ShowRole", self.nFixFaction or me.nFaction, self.nSex or me.nSex);
	self.pPanel:NpcView_SetModePos("ShowRole",0,41,0)
	self.pPanel:NpcView_UseDynamicBone("ShowRole", true);
	self.nWaiyiPos = Item.EQUIPPOS_WAIYI
	if self.nSelectId then
		self.nWaiyiPos = KItem.GetEquipPos(self.nSelectId)
	end

	local tbColorItem = Item.tbChangeColor:GetColorItemAndSortGroup()
	self.nCurTabMain = (self.nSelectId and tbColorItem[self.nSelectId].nGenre) or tbUi.BTNLEVEL;
	self.pPanel:Toggle_SetChecked("Clothes", self.nWaiyiPos == Item.EQUIPPOS_WAIYI);
	self.pPanel:Toggle_SetChecked("Arms", self.nWaiyiPos == Item.EQUIPPOS_WAI_WEAPON);
	self.pPanel:Toggle_SetChecked("Mount", self.nWaiyiPos == Item.EQUIPPOS_WAI_HORSE);
	self.pPanel:Toggle_SetChecked("Headdress", self.nWaiyiPos == Item.EQUIPPOS_WAI_HEAD);
	self.pPanel:Toggle_SetChecked("Pendant", self.nWaiyiPos == Item.EQUIPPOS_WAI_BACK);
	self.pPanel:Toggle_SetChecked("BgButton", self.nWaiyiPos == tbUi.WAI_BG);
	self.pPanel:Toggle_SetChecked(tbTabMainName[tbUi.BTNLEVEL], false);
	self.pPanel:Toggle_SetChecked(tbTabMainName[tbUi.BTNCORNER], false);
	self.pPanel:Toggle_SetChecked(tbTabMainName[tbUi.BTNSHOP], false);

	self.tbPart = {};
	self.tbPartEffect = {};
	self:CloseRoleAniTimer();
	self:Update();

	if not next(self.tbDataList) and not next(self.tbHasWaiyi) then
		self.pPanel:NpcView_Close("ShowRole");
		me.CenterMsg("您目前没有任何外装")
		return 0;
	end

	if not self.nTimer then
		self.nTimer = Timer:Register(Env.GAME_FPS * 30, self.Update, self)		-- 刷新有效期的Timer
	end

	if me.nLevel <= WaiYiTry.Def.nMaxLevel then
		if Guide:IsFinishGuide(WaiYiTry.Def.nGuideOpenBag) ~= 0 then
			Guide:StartGuideById(WaiYiTry.Def.nGuideChangeColor, false, false, true)
		end
	end
end

function tbUi:OnOpenEnd( nTemplateId, nFaction, nSex)
	if nTemplateId then
		local nEquipPos = KItem.GetEquipPos(nTemplateId)
		if nEquipPos == Item.EQUIPPOS_WAI_HORSE then
			self.pPanel:NpcView_ChangeDir("ShowRole", 220, false);
		else
			self.pPanel:NpcView_ChangeDir("ShowRole", 180, false);
		end
	end

	self:OpenScroll();
end

function tbUi:Update()
    self.pPanel:ChangePanelSoftness("ScrollView",0,0);
	self.nStartIndex = nil
	self.nGroupCount = 0;
	self.tbSelectDefault = {};                              --这个是默认打开的图标
	self.tbWaiyiList = {};
	self.tbDataList = {};
	self.tbHeight = {};                                    --设置ScrollView的Item的高度
	self.tbChangeId = {};
	local tbAllWaiyi = me.FindItemInPlayer("waiyi");
	self.tbHasWaiyi = {}
	self.tbNameSubDesc = {};
	self.tbGroupCharm = {}
	self.nEquipTemplateId = 0;

	local pCurWaiZhuang = me.GetEquipByPos(self.nWaiyiPos)
	if pCurWaiZhuang then                                                                     --当前所穿外衣的id
		self.nEquipTemplateId = pCurWaiZhuang.dwTemplateId
	end

	self.nPart = Item.tbItemPosToNpcPart[self.nWaiyiPos]
	self:ControlTab();                                                                         --控制Tab中图片显示
	self:ControlTabMain();

	if self.nWaiyiPos ~= tbUi.WAI_BG then
		local tbTimeOutChangeId = {};
		local tbColorItem, tbSortGroup = Item.tbChangeColor:GetColorItemAndSortGroup()
		for _, pCurItem in pairs(tbAllWaiyi) do
			local nTemplateId = pCurItem.dwTemplateId
			local nTimeOut = pCurItem.GetBaseIntValue(4)
			self.tbHasWaiyi[nTemplateId] = 1;
			local tbColorItem = Item.tbChangeColor:GetColorItemAndSortGroup()
			if tbColorItem[nTemplateId] then
				local nChangeId = Item.tbChangeColor:GetChangeId(nTemplateId)
				self.tbChangeId[nChangeId] = self.tbChangeId[nChangeId] or {}
				if nTimeOut > 0 then
					tbTimeOutChangeId[nChangeId] = math.max(tbTimeOutChangeId[nChangeId] or 0, nTimeOut)
				end
				table.insert(self.tbChangeId[nChangeId], pCurItem.dwId)
			end
		end

		local nCurTime = GetTime();
		for _, tbGroup in ipairs(tbSortGroup) do
			if (not self.nPreviewId and self.tbChangeId[tbGroup.nId] and tbGroup.nPart == self.nPart and tbGroup.nGenre == self.nCurTabMain)
			 or tbGroup.nId == self.nPreviewId then
				local szGroupName = tbGroup.tbNameList[self.nFixFaction][self.nSex]
				local tbBaseProp = KItem.GetItemBaseProp(tbGroup.tbItemSort[1])
				if tbBaseProp.nFactionLimit == 0 or self.nFixFaction == tbBaseProp.nFactionLimit then
					local nGroupNameIndex = string.find(szGroupName,"<");
					if nGroupNameIndex and #szGroupName > nGroupNameIndex then                    --截取系列名字
						szGroupName = string.sub(szGroupName,nGroupNameIndex,#szGroupName);
					end

					table.insert(self.tbDataList, szGroupName)	                                   -- 标题
					local nIndex = #self.tbDataList
					if tbTimeOutChangeId[tbGroup.nId] and tbTimeOutChangeId[tbGroup.nId] > 0 then
						self.tbNameSubDesc[nIndex] = Lib:TimeDesc13(tbTimeOutChangeId[tbGroup.nId] - nCurTime)
					end

					table.insert(self.tbHeight, 60)     -- 标题高度
					local nGroupCharm = 0
					for _, nTemplateId in ipairs(tbGroup.tbItemSort)do
						local szName = Item:GetItemTemplateShowInfo(nTemplateId, self.nFixFaction, self.nSex)
						self.tbWaiyiList[nTemplateId] = {nTemplateId, szName, tbGroup.nPart, self.tbHasWaiyi[nTemplateId], tbGroup.nId, 0}
						if self.tbHasWaiyi[nTemplateId] then
							local nFirstCharm, nNextCharm = Item.tbChangeColor:GetCharmInfo(nTemplateId);
							nGroupCharm = nGroupCharm + (nGroupCharm > 0 and nNextCharm or nFirstCharm);
						end

						local bShowItem = self.tbHasWaiyi[nTemplateId]
										or Item.tbChangeColor:CanColorItemShow(me, nTemplateId)
										or self.nSelectId == nTemplateId;

						if not self.tbClosePage[szGroupName] and bShowItem then
							local varLastNode = self.tbDataList[#self.tbDataList]
							if type(varLastNode) == "string" or #varLastNode > 3 then
								table.insert(self.tbDataList, {})
								table.insert(self.tbHeight, 110)			                             -- 展开的面板高度
								varLastNode = self.tbDataList[#self.tbDataList]
							end
							table.insert(varLastNode, nTemplateId);
						end

						if not self.nSelectId and bShowItem then
							self.nSelectId = nTemplateId;
						end

						if self.nSelectId == nTemplateId and bShowItem then
							self.nStartIndex = #self.tbDataList
						end
					end

					self.tbGroupCharm[nIndex] = nGroupCharm
				end
			end
		end
	else
		self:UpdateBg();
	end

	local nTotalCharm = Item.tbChangeColor:GetTotalCharm(tbAllWaiyi)
	self.pPanel:Label_SetText("CharmNum", tostring(nTotalCharm))
	self.pPanel:SetActive("AddNum", false)

	self:RefreshList();
	return true;
end

function tbUi:ControlTab()                                                                        --控制Tab衣服，武器，头饰等图片显示
	if self.nPreviewId then
		self.pPanel:SetActive("Tab", false)
	else
		self.pPanel:SetActive("Tab", true)
		local pWaiyi = me.GetEquipByPos(Item.EQUIPPOS_WAIYI)
		local pWaiWeapon = me.GetEquipByPos(Item.EQUIPPOS_WAI_WEAPON)
		local pWaiHorse = me.GetEquipByPos(Item.EQUIPPOS_WAI_HORSE)
		local pWaiHead = me.GetEquipByPos(Item.EQUIPPOS_WAI_HEAD)
		local pWaiBack = me.GetEquipByPos(Item.EQUIPPOS_WAI_BACK)
		local pCloak = me.GetEquipByPos(Item.EQUIPPOS_WAI_BACK2)

		self.tbSelectDefault["Clothes"] = pWaiyi and pWaiyi.dwTemplateId or -1;
		self.tbSelectDefault["Arms"] = pWaiWeapon and pWaiWeapon.dwTemplateId or -1;
		self.tbSelectDefault["Mount"] = pWaiHorse and pWaiHorse.dwTemplateId or -1;
		self.tbSelectDefault["Headdress"] = pWaiHead and pWaiHead.dwTemplateId or -1;
		self.tbSelectDefault["Pendant"] = pWaiBack and pWaiBack.dwTemplateId or -1;
		self.tbSelectDefault["Cloak"] = pCloak and pCloak.dwTemplateId or -1;
		self.tbSelectDefault["BgButton"] = self.nCurBgId or -1;

		for szKey,nId in pairs(self.tbSelectDefault) do                                                     --显示和隐藏默认图片
			if nId == -1 then
				self[szKey].pPanel:SetActive("Sprite",true);
			else
				self[szKey].pPanel:SetActive("Sprite",false);
			end
		end

		self.Clothes:SetItemByTemplate(pWaiyi and pWaiyi.dwTemplateId)
		self.Arms:SetItemByTemplate(pWaiWeapon and pWaiWeapon.dwTemplateId)
		self.Mount:SetItemByTemplate(pWaiHorse and pWaiHorse.dwTemplateId)
		self.Headdress:SetItemByTemplate(pWaiHead and pWaiHead.dwTemplateId)
		self.Pendant:SetItemByTemplate(pWaiBack and pWaiBack.dwTemplateId)
		self.Cloak:SetItemByTemplate(pCloak and pCloak.dwTemplateId);
		local tbWaiyiBg = Item.tbChangeColor:GetWaiyiBgSetting();
		local szBgSmallName = tbWaiyiBg[self.nCurBgId].BgSmallPic;
		local szSpritePath = "UI/Atlas/NewAtlas/DressBg/DressBg.prefab";
		self["BgButton"].pPanel:Sprite_SetSprite("ItemLayer",szBgSmallName,szSpritePath);
	end
end

function tbUi:ControlTabMain()                                                                                  --等级，商城，江湖
	if self.bBtnOpenState == tbUi.BTNOPEN and (self.nWaiyiPos == Item.EQUIPPOS_WAIYI or
	self.nWaiyiPos == Item.EQUIPPOS_WAI_HEAD  or self.nWaiyiPos == Item.EQUIPPOS_WAI_WEAPON) then             --坐骑挂饰背景不需要"TabMain"
		self.pPanel:SetActive("TabMain",true);
		if self.nWaiyiPos == Item.EQUIPPOS_WAI_WEAPON then
			self.pPanel:SetActive("BtnCorners",false);
			self.pPanel:Toggle_SetChecked(tbTabMainName[tbUi.BTNCORNER], false);
		else
			self.pPanel:SetActive("BtnCorners",true);
		end

		self.pPanel:Toggle_SetChecked(tbTabMainName[self.nCurTabMain], true);
	else
		self.pPanel:SetActive("TabMain",false);
	end
end

tbUi.STATE_NONE = 1
tbUi.STATE_CHANGEABLE = 2
tbUi.STATE_HAS = 3
tbUi.STATE_EQUIPING = 4
tbUi.STATE_LOCKING = 5
tbUi.STATE_USEING = 6

tbUi.tbStateDesc = {"未获得", "可染色", "[6cdd00]已拥有[-]", "[6cdd00]装备中[-]"}
function tbUi:SetEquipInfo(pButton, nTemplateId, fnClickCallback)
	local data = self.tbWaiyiList[nTemplateId];
	local nTemplateId, szName, nPart, nHasWaiyi, nChangeId, nState = unpack(data)

	nState = self.STATE_NONE;
	if self.tbChangeId[nChangeId] and #self.tbChangeId[nChangeId] > 0 then
		nState = self.STATE_CHANGEABLE;
	end
	if nHasWaiyi then
		nState = self.STATE_HAS;
		pButton.pPanel:SetActive("Lock", false)
		pButton.pPanel:SetActive("Gray", false)
	else
		pButton.pPanel:SetActive("Lock", true)
		pButton.pPanel:SetActive("Gray", true)
	end
	if nTemplateId == self.nEquipTemplateId then
		nState = self.STATE_EQUIPING;
		pButton.pPanel:SetActive("Equip", true)
	else
		pButton.pPanel:SetActive("Equip", false);
	end
	data[6] = nState;

	if szName then
		local tbSplitName = Lib:SplitStr(szName,"·");
		szName = tbSplitName[#tbSplitName];
		tbSplitName = Lib:SplitStr(szName,"-");                   --海外版本
		szName = tbSplitName[#tbSplitName];
	end

	pButton.pPanel:Label_SetText("TxtItemName",szName);
	pButton.nTemplateId = nTemplateId;
	pButton.pPanel.OnTouchEvent = fnClickCallback;
	pButton.pPanel:Toggle_SetChecked("Main", self.nSelectId == nTemplateId)
	pButton.Item:SetItemByTemplate(nTemplateId, nil, self.nFixFaction, self.nSex)
	local fnOnClickItemLayer = function ()
		pButton.pPanel:Toggle_SetChecked("Main", true)
		fnClickCallback(pButton)
	end
	pButton.Item.fnClick = fnOnClickItemLayer;

end

function tbUi:CanShowBtnCollection(nTemplateId)
	return not not (self.nWaiyiPos == Item.EQUIPPOS_WAI_HORSE and
		House:GetHorseCollectSetting(nTemplateId) and
		not House:IsHorseCollected(me, nTemplateId))
end

function tbUi:RefreshList()
	self.fnOnSelect = function (btn)
		local data = self.tbWaiyiList[btn.nTemplateId];
		local nBgId = btn.nTemplateId;
		if self.nWaiyiPos ~= tbUi.WAI_BG and not data then
			self.pPanel:SetActive("Consume", false);
			self.pPanel:SetActive("BtnColour", false);
			self.pPanel:SetActive("BtnCollection", false)
			self.fnCallback = nil;
			return
		end

		local nTemplateId, szName, nPart, nHasWaiyi, nChangeId, nState = nil;
		if self.nWaiyiPos ~= tbUi.WAI_BG then
			nTemplateId, szName, nPart, nHasWaiyi, nChangeId, nState = unpack(data)
			if self.bBtnOpenState ~= tbUi.BTNCLOSE or self.bNeedChangePartRes == true then                                  --是否改变PartRes
				local nRes,nEffectResId = Item.tbChangeColor:GetWaiZhuanRes(nTemplateId, self.nFixFaction, self.nSex)
				self.nSelectId = nTemplateId
				if nPart == Npc.NpcResPartsDef.npc_part_horse then
					self:ChangeHorse(self.nSelectId);
				else
					local tbChanePartParams,tbChanePartParamsEffect = { [nPart] = nRes },{[nPart] = nEffectResId}
					self:ChangeFeature(tbChanePartParams,tbChanePartParamsEffect);
				end
			end
		else
			self.nSelectId = btn.nTemplateId;
			if self.PreviousBtn then                                                            --上一次选中的背景变成false
				self.PreviousBtn.pPanel:SetActive("Select",false);
			end

			if btn then                                                                         --这次选中的背景变成false
				btn.pPanel:SetActive("Select",true);
				self.PreviousBtn = btn;
			end

			if Item.tbChangeColor:IsUnlockedBg(me,nBgId) then
				nState = self.STATE_USEING;
			else
				nState = self.STATE_LOCKING;
			end
			self:UpdateBg();
		end

		 if self.bViewPlayerInform then                                                            --如果是玩家查看界面打开的界面
		 	nState = nil;
		 end

		if nState == self.STATE_CHANGEABLE then
			self.pPanel:SetActive("BtnColour", true);
			self.pPanel:Button_SetText("BtnColour", "染色")
			self.pPanel:SetActive("Consume", true);
			local nConsumeItem, nConsumeCount = Item.tbChangeColor:GetConsumeInfo(nTemplateId);
			local nCount = me.GetItemCountInAllPos(nConsumeItem)
			self.ConsumeItem:SetItemByTemplate(nConsumeItem)
			self.pPanel:Label_SetText("TxtConsumeCount", string.format("%s%d/%d", nCount >= nConsumeCount and "" or "[ff0000]", nCount, nConsumeCount))
			self.fnCallback = self.DoChangeColor;
		elseif nState == self.STATE_EQUIPING then
			self.pPanel:SetActive("BtnColour", true);
			self.pPanel:SetActive("Consume", false);
			self.pPanel:SetActive("BtnCollection", self:CanShowBtnCollection(nTemplateId))
			self.pPanel:Button_SetText("BtnColour", "卸下")
			self.fnCallback = self.DoUnEquip;
			self.varParam = KItem.GetEquipPos(nTemplateId)
		elseif nState == self.STATE_HAS then
			self.pPanel:SetActive("BtnColour", true);
			self.pPanel:SetActive("Consume", false);
			self.pPanel:SetActive("BtnCollection", self:CanShowBtnCollection(nTemplateId))
			self.pPanel:Button_SetText("BtnColour", "装备")
			self.fnCallback = self.DoEquip;
		elseif nState == self.STATE_LOCKING then
			self.pPanel:SetActive("BtnColour", true);
			self.pPanel:SetActive("Consume", false);
			self.pPanel:SetActive("BtnCollection", self:CanShowBtnCollection(nTemplateId))
			self.pPanel:Button_SetText("BtnColour", "解锁")
			self.fnCallback = self.UnLockBg;
		elseif nState == self.STATE_USEING then
			self.pPanel:SetActive("BtnColour", true);
			self.pPanel:SetActive("Consume", false);
			self.pPanel:SetActive("BtnCollection", self:CanShowBtnCollection(nTemplateId))
			self.pPanel:Button_SetText("BtnColour", "使用")
			self.fnCallback = self.UseBg;
		else
			self.pPanel:SetActive("Consume", false);
			self.pPanel:SetActive("BtnColour", false);
			self.pPanel:SetActive("BtnCollection", false)
			self.fnCallback = nil;
		end

		local nFirstCharm, nNextCharm = Item.tbChangeColor:GetCharmInfo(nTemplateId)
		local tbStateCharm = {nFirstCharm, nNextCharm}
		if tbStateCharm[nState] then
			self.pPanel:SetActive("AddNum", true)
			self.pPanel:Label_SetText("AddNum", string.format("(+%d)", tbStateCharm[nState]))
		else
			self.pPanel:SetActive("AddNum", false)
		end

	end

	self.fnOnBannerClick = function (btn)
		self.tbClosePage[btn.szGroupName] = not self.tbClosePage[btn.szGroupName]
		self:Update();
	end

	local fnSetItem = function(itemObj, index)
		itemObj.pPanel:SetActive("BgItem",false);
		local varData = self.tbDataList[index]
		local szSubDesc = self.tbNameSubDesc[index]
		local nCharm = self.tbGroupCharm[index]
		if type(varData) == "table" then
			itemObj.pPanel:SetActive("Equipment", true);
			itemObj.pPanel:SetActive("BtnName", false);
			for i = 1, 4 do
				local nTemplateId = varData[i];
				local tbData = self.tbWaiyiList[nTemplateId];
				if tbData then
					itemObj.pPanel:SetActive("item"..i, true);
					self:SetEquipInfo(itemObj["item"..i], nTemplateId, self.fnOnSelect)
				else
					itemObj.pPanel:SetActive("item"..i, false);
				end
			end
		elseif type(varData) == "string" then
			itemObj.pPanel:SetActive("Equipment", false);
			itemObj.pPanel:SetActive("BtnName", true);
			itemObj.BtnName.pPanel:Label_SetText("Name", varData);
			if szSubDesc then
				itemObj.BtnName.pPanel:SetActive("Time", true);
				itemObj.BtnName.pPanel:Label_SetText("Time", szSubDesc)
			else
				itemObj.BtnName.pPanel:SetActive("Time", false);
			end
			itemObj.BtnName.pPanel:Label_SetText("Charm", string.format("魅力值：%d", nCharm or 0))
			itemObj.BtnName.pPanel.OnTouchEvent = self.fnOnBannerClick;

			itemObj.BtnName.szGroupName = varData
			itemObj.pPanel:SetActive("item1", false);
			itemObj.pPanel:SetActive("item2", false);
			itemObj.pPanel:SetActive("item3", false);
			itemObj.pPanel:SetActive("item4", false);

			if self.tbClosePage[varData] then
				itemObj.BtnName.pPanel:Sprite_SetSprite("Mark", "ListMarkNormal")
			else
				itemObj.BtnName.pPanel:Sprite_SetSprite("Mark", "ListMarkPress")
			end
		end
	end

	local fnSetBgItem = function (itemObj, index)
		local varData = self.tbBgDataList[index];
		itemObj.pPanel:SetActive("Equipment", false);
		if type(varData) == "table" then
			local nBgId,bHave,szBgTipsPic,szRequirementText = unpack(varData);
			itemObj["BgItemButton"].nTemplateId = nBgId;
			itemObj["BgItemButton"].pPanel.OnTouchEvent = self.fnOnSelect;

			if nBgId == self.nCurBgId then
				itemObj["BgItemButton"].pPanel:SetActive("Equip",true);
			else
				itemObj["BgItemButton"].pPanel:SetActive("Equip",false);
			end

			if self.nSelectId == nBgId then
				itemObj["BgItemButton"].pPanel:SetActive("Select",true);
				self.fnOnSelect(itemObj["BgItemButton"]);
			else
				itemObj["BgItemButton"].pPanel:SetActive("Select",false);
			end

			if bHave then
				itemObj["BgItemButton"].pPanel:SetActive("Lock",false);
				itemObj["BgItemButton"].pPanel:SetActive("Gray",false);
			else
				itemObj["BgItemButton"].pPanel:SetActive("Lock",true);
				itemObj["BgItemButton"].pPanel:SetActive("Gray",true);
			end

			itemObj.pPanel:Toggle_SetChecked("BgItemButton", self.nSelectId == nBgId);
			itemObj.pPanel:SetActive("BtnName",false);
			itemObj.pPanel:SetActive("BgItem", true);
			itemObj.pPanel:SetActive("BgItemButton", true);
			itemObj["BgItemButton"].pPanel:Sprite_SetSprite("Sprite", szBgTipsPic);
		else
			itemObj["BtnName"].pPanel:Label_SetText("Name", varData);
			itemObj.pPanel:SetActive("BtnName",true);
			itemObj.pPanel:SetActive("BtnName",true);
		end
	end


	self.ScrollView:UpdateItemHeight(self.tbHeight)

	if self.nWaiyiPos ~= tbUi.WAI_BG then
		self.ScrollView:Update(self.tbDataList, fnSetItem);
	else
		self.ScrollView:Update( self.tbBgDataList, fnSetBgItem);
	end

	if self.nSelectId then
		if self.nWaiyiPos ~= tbUi.WAI_BG then
			self.fnOnSelect({nTemplateId = self.nSelectId})
		end
	else
		if self.nWaiyiPos == Item.EQUIPPOS_WAI_HORSE then
			self:ChangeHorse();
		else
			self:ChangeFeature();
		end
		self.pPanel:SetActive("BtnColour", false);
		self.pPanel:SetActive("Consume", false);
		self.pPanel:SetActive("BtnCollection", false)
	end
end

function tbUi:DoChangeColor()
	local nChangeId = Item.tbChangeColor:GetChangeId(self.nSelectId)
	if not self.tbChangeId or not self.tbChangeId[nChangeId] then
		me.CenterMsg("您没有这件外装的其他颜色，不能染色");
		return;
	end
	local fnAgree = function (nItemId, nTargetId)
		RemoteServer.DoChangeEquipColor(nItemId, nTargetId);
	end
	local nItemId = self.tbChangeId[nChangeId][1]
	if nItemId then
		local nConsumeItem, nConsumeCount = Item.tbChangeColor:GetConsumeInfo(self.nSelectId);
		if not nConsumeItem then
			return;
		end
		local tbBaseProp = KItem.GetItemBaseProp(nConsumeItem);
		local szName = Item:GetItemTemplateShowInfo(self.nSelectId, self.nFixFaction, self.nSex)
		Ui:OpenWindow("MessageBox", string.format("你确定要染成[fffe0d]%s[-]吗？\n需要消耗%d个%s", szName, nConsumeCount, tbBaseProp.szName),
			{ {fnAgree, nItemId, self.nSelectId},{} },
			{"同意", "取消"});
	end
end

function tbUi:DoEquip()
	local nChangeId = Item.tbChangeColor:GetChangeId(self.nSelectId)
	for _, nId in ipairs(self.tbChangeId[nChangeId]) do
		local pItem = me.GetItemInBag(nId)
		if pItem and pItem.dwTemplateId == self.nSelectId then
			Player:UseEquip(pItem.dwId)
			return
		end
	end
end

function tbUi:UnLockBg()
	local tbWaiyiBg = Item.tbChangeColor:GetWaiyiBgSetting();
	if self.nSelectId then
		local szRequire =  tbWaiyiBg[self.nSelectId].RequirementText;
		Ui:OpenWindow("MessageBox",szRequire,{},{"确定"});
	end
end

function tbUi:UseBg()
	if self.nSelectId then
		self.nCurBgId = self.nSelectId;
		RemoteServer.DoChangeWaiyiBg(self.nSelectId);
		self:Update();
	end
end

function tbUi:DoUnEquip(nPos)
	Player:ClientUnUseEquip( nPos )
end

function tbUi:ChangeFeature(tbChanePartParams,tbChanePartParamsEffect)
	if self.nOnTimerFeature then
		Timer:Close(self.nOnTimerFeature);
		self.nOnTimerFeature = nil;
	end
	--临时解决头部丢失的问题
	self.nOnTimerFeature = Timer:Register(1, self.OnTimerChangeFeature, self, tbChanePartParams,tbChanePartParamsEffect)
end

function tbUi:OnTimerChangeFeature(tbChanePartParams,tbChanePartParamsEffect)
	self.nOnTimerFeature = nil;
	if tbChanePartParams then
		for nChangePart, nWaiZhuanRes in pairs(tbChanePartParams) do
            self.tbPart[nChangePart] = nWaiZhuanRes;
        end
	end

	if tbChanePartParamsEffect then
		for nChangePart, nWaiZhuanRes in pairs(tbChanePartParamsEffect) do
            self.tbPartEffect[nChangePart] = nWaiZhuanRes;
        end
    end

	local tbFactionInfo = KPlayer.GetPlayerInitInfo(self.nFixFaction, self.nSex)
	local tbNpcRes, tbEffectRes;
	if self.nFixFaction == me.nFaction then
		tbNpcRes, tbEffectRes = me.GetNpcResInfo();
	else
		tbNpcRes, tbEffectRes = {}, {}
		tbNpcRes[0] = tbFactionInfo.nBodyResId;
		tbNpcRes[1] = tbFactionInfo.nWeaponResId;
		tbNpcRes[4] = tbFactionInfo.nHeadResId
		for i = 0, Npc.NpcResPartsDef.npc_res_part_count - 1 do
			tbNpcRes[i] = tbNpcRes[i] or 0;
			tbEffectRes[i] = 0;
		end
	end

	-- local tbFactionScale = {0.92, 1, 1.15, 1}	-- 贴图缩放比例
	local fScale = 1;--tbFactionScale[self.nFixFaction] or 1
	for nPartId, nResId in pairs(tbNpcRes) do
		local nCurResId = nResId
		if nCurResId == 0 then
			if nPartId == Npc.NpcResPartsDef.npc_part_body then
				nCurResId = tbFactionInfo.nBodyResId
			elseif nPartId == Npc.NpcResPartsDef.npc_part_head then
				nCurResId = tbFactionInfo.nHeadResId
			end
		end

		if nPartId == Npc.NpcResPartsDef.npc_part_horse then
			nCurResId = 0;
		elseif self.tbPart[nPartId] then
			nCurResId = self.tbPart[nPartId];
		end

		self.pPanel:NpcView_ChangePartRes("ShowRole", nPartId, nCurResId);
	end
	for nPartId, nEffectResId in pairs(tbEffectRes) do
		local nCurResId = nEffectResId
		if self.tbPartEffect[nPartId] then
			nCurResId = self.tbPartEffect[nPartId];
		end
		self.pPanel:NpcView_ChangePartEffect("ShowRole", nPartId, nCurResId);
	end

	self.pPanel:NpcView_SetScale("ShowRole", fScale);
	if self.bLoadRoleRes then
		self:PlayRoleAnimation();
	end
end

function tbUi:ChangeHorse(dwTemplateId)
	local nNpcRes;
	if dwTemplateId then
		nNpcRes = Item:GetHorseShoNpc(dwTemplateId)
	end
	if not nNpcRes then
		local pHorse = me.GetEquipByPos(Item.EQUIPPOS_WAI_HORSE) or me.GetEquipByPos(Item.EQUIPPOS_HORSE)
		if pHorse then
			nNpcRes = Item:GetHorseShoNpc(pHorse.dwTemplateId);
		end
	end
	if nNpcRes then
		self.szRideActionName = KNpc.GetRideActionName(nNpcRes) or "hst";
		self.pPanel:NpcView_ShowNpc("ShowRole", nNpcRes);
		self.pPanel:NpcView_ChangePartRes("ShowRole", Npc.NpcResPartsDef.npc_part_weapon, 0);
		self.pPanel:NpcView_ChangePartRes("ShowRole", Npc.NpcResPartsDef.npc_part_head, 0);
		self.pPanel:NpcView_ChangePartRes("ShowRole", Npc.NpcResPartsDef.npc_part_back, 0);
		self.pPanel:NpcView_ChangePartRes("ShowRole", Npc.NpcResPartsDef.npc_part_wing, 0);
		for nPartId = 0, Npc.NpcResPartsDef.npc_res_part_count - 1 do
			self.pPanel:NpcView_ChangePartEffect("ShowRole", nPartId, 0);
		end

		self.pPanel:NpcView_SetScale("ShowRole", 0.7);
	else
		-- 界面上不使用 ShowRole 的SetActive操作了，不然同时打开多个有showrole的界面时setactiv 会显示其模型
		-- self.pPanel:SetActive("ShowRole", false);
	end
end

function tbUi:OnClose()
	if self.nOnTimerFeature then
		Timer:Close(self.nOnTimerFeature);
		self.nOnTimerFeature = nil;
	end

	if self.nBtnOpenTimer then
		Timer:Close(self.nBtnOpenTimer);
		self.nBtnOpenTimer = nil;
	end

	if self.nBtnCloseTimer then
		Timer:Close(self.nBtnCloseTimer);
		self.nBtnCloseTimer = nil;
	end

	self.pPanel:NpcView_Close("ShowRole");
	self:CloseRoleAniTimer();
	self.nSelectId = nil;
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
	if self.PreviousBtn then
		self.PreviousBtn.pPanel:SetActive("Select",false);
	end
	self.bViewPlayerInform = false;
end

function tbUi:OnSyncItem(nItemId)
	self:Update();
end

function tbUi:PlayStandAnimaion()
	self.nPlayStTimer = nil;
	if self.nWaiyiPos ~= Item.EQUIPPOS_WAI_HORSE then
		self.pPanel:NpcView_PlayAnimationByActId("ShowRole", Npc.ActionId.act_stand, 0.1, true);
	else
		self.pPanel:NpcView_PlayAnimation("ShowRole", self.szRideActionName, 0.0, true);
	end
end

function tbUi:PlayNextRoleAnimation(nActId)
	self.nPlayNextTimer = nil;
	if self.nPlayStTimer then
		Timer:Close(self.nPlayStTimer);
		self.nPlayStTimer = nil;
	end

	if self.nWaiyiPos ~= Item.EQUIPPOS_WAI_HORSE then
		self.pPanel:NpcView_PlayAnimationByActId("ShowRole", nActId, 0.0, false);
		ViewRole:CheckPlayeRoleAniEffect(self,nActId)

		local nPlayTime = self.pPanel:NpcView_GetPlayAniTime("ShowRole");
		nPlayTime = math.max(math.floor(nPlayTime * Env.GAME_FPS), 2);
		self.nPlayStTimer  = Timer:Register(nPlayTime, self.PlayStandAnimaion, self);
		self.nPlayNextTimer = nil;
		self:PlayRoleAnimation();
	end
end

function tbUi:PlayRoleAnimation()
	local tbSkillIniSet = FightSkill.tbSkillIniSet;
	local nTotalID = #tbSkillIniSet.tbActStandID;
	if nTotalID <= 0 then
		return 0;
	end

	local nFrame = tbSkillIniSet.nActStandMinFrame;
	local nMaxFrame = tbSkillIniSet.nActStandMaxFrame - tbSkillIniSet.nActStandMinFrame;
	if nMaxFrame > 0 then
	   nFrame = MathRandom(nMaxFrame) + tbSkillIniSet.nActStandMinFrame;
	end

	local nAniIndex = MathRandom(nTotalID);
	local nActId    = tbSkillIniSet.tbActStandID[nAniIndex];
	local tbActionInfo = Npc:GetNpcActionInfo(nActId);

	if self.nPlayNextTimer then
		Timer:Close(self.nPlayNextTimer);
		self.nPlayNextTimer = nil;
	end

	if not tbActionInfo then
		return;
	end

	local pNpc = me.GetNpc();
	if not pNpc then
		return;
	end

	local nActFrame = pNpc.GetActionFrame(nActId);
	if nActFrame <= 2 then
		nActFrame = 70;
	end

	self.nPlayNextTimer  = Timer:Register(nFrame + nActFrame, self.PlayNextRoleAnimation, self, nActId);
end

function tbUi:CloseRoleAniTimer()
	if self.nPlayStTimer then
		Timer:Close(self.nPlayStTimer);
		self.nPlayStTimer = nil;
	end

	if self.nPlayNextTimer then
		Timer:Close(self.nPlayNextTimer);
		self.nPlayNextTimer = nil;
	end
end

function tbUi:OnLoadResFinish()
	if self.nWaiyiPos == Item.EQUIPPOS_WAI_HORSE then
		self.pPanel:NpcView_PlayAnimation("ShowRole", self.szRideActionName, 0.0, true);
	else
		self:PlayRoleAnimation();
		self.bLoadRoleRes = true;
	end
end

function tbUi:UpdateBg()
	self.tbBgDataList = {};
	self.tbHeight = {};
	local nI = 1;
	local tbWaiyiBg = Item.tbChangeColor:GetWaiyiBgSetting();
	for nBgId,tbInfo in pairs(tbWaiyiBg) do
		table.insert(self.tbHeight, 100)			-- 展开的面板高度

		if Item.tbChangeColor:IsUnlockedBg(me,nBgId) then
			self.tbBgDataList[nI] = {nBgId,true,tbInfo.BgTipsPic,tbInfo.BgTexture};
		else
			self.tbBgDataList[nI] = {nBgId,false,tbInfo.BgTipsPic,tbInfo.BgTexture};
		end
		nI = nI + 1;

		if self.nSelectId == nBgId then
			self.nStartIndex = #self.tbBgDataList;
		end

		if Item.tbChangeColor:IsUnlockedBg(me, self.nSelectId) and nBgId == self.nSelectId then
			self.pPanel:Texture_SetTexture("Bg", tbInfo.BgTexture);
			if tbInfo.EffectId > 0 then
				self.pPanel:ShowEffect("Bg", tbInfo.EffectId,0,2)
			else
				self.pPanel:HideEffect("Bg")
			end
		end

	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_ITEM,			self.OnSyncItem },
		{ UiNotify.emNOTIFY_LOAD_RES_FINISH,    self.OnLoadResFinish, self},
	}
	return tbRegEvent;
end

