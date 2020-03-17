--[[
	帮派地宫争夺战进入ui
	zhangshuhui
]]

_G.UIUnionDiGong = BaseUI:new("UIUnionDiGong");
 
function UIUnionDiGong:Create()
	self:AddSWF("unionDiGongPanel.swf",true,nil)
	self:AddChild(UIUnionDiGongBidListView, "bidList");
--	print("进入加载")
end; 

function UIUnionDiGong:OnLoaded(objSwf)
	self:GetChild("bidList"):SetContainer(objSwf.childPanel);
	local list = objSwf.list;
	objSwf.list.itemBtnEnterClick   = function(e) self:OnBtnEnterClick(e); end
	objSwf.list.itemRewardRollOver  = function(e) self:OnRewardRollOver(e); end
	objSwf.list.itemRewardRollOut   = function(e) self:OnRewardRollOut(e); end
	
	for i=1,3 do
		objSwf["btnGoIn"..i].click  = function() UnionDiGongController:ReqUnionEnterDiGongWar(i); end
	end
	
	objSwf.btnPre.click  = function() self:OnBtnPreClick(); end
	objSwf.btnNext.click = function() self:OnBtnNextClick(); end
	objSwf.btnPre.visible = false;
	objSwf.btnNext.visible = false;

	objSwf.btnReturn.click = function() 
		local parent = self.parent;
		if not parent then return; end
		parent:TurnToDungeonListPanel();
	end;
	objSwf.btnReturn.rollOver = function() TipsManager:ShowBtnTips(StrConfig["unionhell043"],TipsConsts.Dir_RightDown) end;
	objSwf.btnReturn.rollOut = function() TipsManager:Hide() end;
end

function UIUnionDiGong:OnShow()
	self:UpdateShow();
	UnionDiGongController:ReqUnionDiGongInfo();
	self:ShowBtnGoIn();
end

function UIUnionDiGong:ShowBtnGoIn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if isDebug then
		for i=1,3 do
			objSwf["btnGoIn"..i]._visible = true;
		end
	else
		for i=1,3 do
			objSwf["btnGoIn"..i]._visible = false;
		end
	end
end

function UIUnionDiGong:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- 帮派副本列表
	local list = objSwf.list;
	list.dataProvider:cleanUp();
	local dungeonListUIData = self:GetDungeonListUIData();
	list.dataProvider:push( unpack(dungeonListUIData) );
	list:invalidateData();
	-- 左右导航按钮状态
	self:CheckNavigateBtnState();
end

function UIUnionDiGong:GetDungeonListUIData()
	local list = {};
	local digonglist = UnionDiGongModel:GetDiGongUnionList();
	local dgstate = UnionDiGongUtils:GetCurState();
	local vo;
	for id=1, #t_guilddigong do
		vo = {};
		vo.id = id;
		vo.digongname         = t_guilddigong[id].name;
		vo.bgURL           	  = ResUtil:GetUnionDiGongBgImg( id );
		vo.state              = UnionDiGongConsts.State_Nil;
		vo.enterLabel      	  = UIStrConfig['unionDiGong012'];
		vo.curUnionName       = "";
		vo.unionName1         = "";
		vo.unionName2         = "";
		vo.strdes             = t_guilddigong[id].describe;
		vo.havetime           = "";
		if MainPlayerController:GetServerOpenDay() <= 7 then
			vo.strdes2        = StrConfig["unionDiGong017"]
		else
			vo.strdes2        = StrConfig["unionDiGong018"]
		end
		vo.enterdisable       = false;
		local finalStr = "";
		local majorStr = "";
		local rewardStr = "";
		local digongcfg = digonglist[id];
		if digongcfg then
			if digongcfg.UnionName ~= "" then
				vo.curUnionName       = digongcfg.UnionName;
			else
				vo.curUnionName       = StrConfig["unionDiGong008"];
			end
			vo.state = dgstate;
			if dgstate == UnionDiGongConsts.State_Bid then
				vo.enterLabel      	  = UIStrConfig['unionDiGong007'];
				if digongcfg.UnionName1 ~= "" then
					vo.unionName1         = string.format( StrConfig["unionDiGong004"],digongcfg.UnionName1);
				else
					vo.unionName1         = StrConfig["unionDiGong008"];
				end
				if digongcfg.UnionName2 ~= "" then
					vo.unionName2         = string.format( StrConfig["unionDiGong005"],digongcfg.UnionName2);
				else
					vo.unionName2         = StrConfig["unionDiGong008"];
				end
			elseif dgstate == UnionDiGongConsts.State_ZhanLing or dgstate == UnionDiGongConsts.State_Waite or dgstate == UnionDiGongConsts.State_Fight then
				vo.enterLabel      	  = UIStrConfig['unionDiGong012'];
				if digongcfg.UnionName1 ~= "" then
					vo.unionName1         = digongcfg.UnionName1;
				else
					vo.unionName1         = StrConfig["unionDiGong008"];
				end
				if digongcfg.UnionName2 ~= "" then
					vo.unionName2         = digongcfg.UnionName2;
				else
					vo.unionName2         = StrConfig["unionDiGong008"];
				end
				
				if dgstate == UnionDiGongConsts.State_Fight then
					if digongcfg.UnionName1 == "" then
						vo.enterLabel      	  = UIStrConfig['unionDiGong012'];
						vo.enterdisable    = false;
					else
						vo.enterLabel      	  = UIStrConfig['unionDiGong013'];
						if UnionModel:GetMyUnionId() and (UnionModel:GetMyUnionId() == digongcfg.unionid1 or UnionModel:GetMyUnionId() == digongcfg.unionid2) then
							vo.enterdisable    = false;
						else
							vo.enterdisable    = true;
						end
					end
				end
			end
		end
		local allRewardStr = self:ConvertRewardStr( t_guilddigong[id].reward );
		local rewardList   = RewardManager:Parse( allRewardStr );
		local rewardStr    = table.concat(rewardList, "*");
		majorStr     = UIData.encode(vo);
		finalStr = majorStr .. "*" .. rewardStr;
		table.push(list, finalStr);
	end
	return list;
end

-- 将配表中配的奖励字符串中的数量转为0（以达到界面中奖励不显示数量目的）
function UIUnionDiGong:ConvertRewardStr( str )
	local tab = {};
	local itemStrTab = split(str, "#");
	for _, itemStr in pairs(itemStrTab) do
		local itemTab = split(itemStr, ",");
		itemTab[2] = 0;
		local newItemStr = table.concat( itemTab, "," );
		table.push( tab, newItemStr);
	end
	return table.concat( tab, "#" );
end

-- 切换到点击的帮派副本子页面
function UIUnionDiGong:OnBtnEnterClick(e)
	local unionDungeonVO = e.item;
	local id = unionDungeonVO and unionDungeonVO.id;
	
	--self:ShowDungeon(id);
	local dgstate = UnionDiGongUtils:GetCurState();
	--前往
	if dgstate == UnionDiGongConsts.State_ZhanLing or dgstate == UnionDiGongConsts.State_Waite then
		self:GoInDiGong(id);
	--竞标
	elseif dgstate == UnionDiGongConsts.State_Bid then
		UIUnionDiGongBidListView.curid = id;
		if not UIUnionDiGongBidListView.bShowState then
			self:ShowChild("bidList");
		end
		UnionDiGongController:ReqUnionDiGongBidList(id);
	--战斗
	elseif dgstate == UnionDiGongConsts.State_Fight then
		local digonglist = UnionDiGongModel:GetDiGongUnionList();
		local digongcfg = digonglist[id];
		if digongcfg.UnionName1 == "" then
			self:GoInDiGong(id);
		else
			UnionDiGongController:ReqUnionEnterDiGongWar(id);
		end
	end
	
	local renderer = e.renderer
	if not renderer then return end
	renderer:setState("up")
end

--本帮派传送到地宫
function UIUnionDiGong:GoInDiGong(id)
	if UnionModel.MyUnionInfo and UnionModel.MyUnionInfo.guildId and UnionModel.MyUnionInfo.guildId ~= '0_0' then
		if UnionModel.MyUnionInfo.guildId == UnionDiGongUtils:GetUnionIdById(id) then
			local swyjCfg = t_swyj[id];
			if not swyjCfg then return; end
			if UnionUtils:CheckMyUnion() and UnionModel:GetMyUnionId()==UnionDiGongModel:GetGuildIdById(id) then
				ActivityController:EnterActivity(swyjCfg.activityId,{param1=1})
			else
				local position = swyjCfg.position;
				local posCfg = split(position,',');
				if #posCfg < 1 then return end
				MainPlayerController:DoAutoRun(toint(posCfg[1]),_Vector3.new(toint(posCfg[2]),toint(posCfg[3]),0));
			end
		else
			local tpos = split( t_guilddigong[id].position1, "," );
			MainPlayerController:DoAutoRun(tonumber(tpos[1]), _Vector3.new(tonumber(tpos[2]),tonumber(tpos[3]),0));
		end
	else
		local tpos = split( t_guilddigong[id].position1, "," );
		MainPlayerController:DoAutoRun(tonumber(tpos[1]), _Vector3.new(tonumber(tpos[2]),tonumber(tpos[3]),0));
	end
end

-- 悬浮奖励
function UIUnionDiGong:OnRewardRollOver(e)
	local slotVO = RewardSlotVO:new();
	slotVO.id = e.item.id;
	slotVO.count = e.item.count;
	slotVO.bind = e.item.bind;
	local tipsInfo = slotVO:GetTipsInfo();
	TipsManager:ShowTips( tipsInfo.tipsType, tipsInfo.info, tipsInfo.tipsShowType, TipsConsts.Dir_RightDown);
end

-- 划出奖励
function UIUnionDiGong:OnRewardRollOut(e)
	TipsManager:Hide();
end

function UIUnionDiGong:OnBtnPreClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.list;
	local curPos = list.scrollPosition;
	list.scrollPosition = curPos - 1;
	self:CheckNavigateBtnState();
end

function UIUnionDiGong:OnBtnNextClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.list;
	local curPos = list.scrollPosition;
	list.scrollPosition = curPos + 1;
	self:CheckNavigateBtnState();
end

function UIUnionDiGong:CheckNavigateBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.list;
	objSwf.btnPre.disabled = list.scrollPosition == 0;
	local numUnionDungeon = list.dataProvider.length;
	local numOnePage = UnionDungeonConsts.NumDungeonsOnePage;
	objSwf.btnNext.disabled = list.scrollPosition == numUnionDungeon - numOnePage;
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIUnionDiGong:ListNotificationInterests()
	return {
		NotifyConsts.UnionDiGongInfoUpdate,
	};
end

--处理消息
function UIUnionDiGong:HandleNotification(name, body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.UnionDiGongInfoUpdate then
		self:UpdateShow();
	end
end