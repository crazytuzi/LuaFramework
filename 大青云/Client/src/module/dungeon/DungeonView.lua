
--[[
副本面板
郝户
2014年11月19日10:43:54
]]

_G.UIDungeon = BaseUI:new("UIDungeon");

-- 当前显示的副本组
UIDungeon.currentShowGroup = nil;
-- 当前显示的副本
UIDungeon.currentShowDungeon = nil;
--当前选中的副本信息
UIDungeon.currData = nil;

function UIDungeon:Create()
	self:AddSWF("dungeonPanel.swf", true, nil)
	-- self:AddChild( UIDungeonRank, "rank" );
end

function UIDungeon:OnLoaded(objSwf)
	-- self:GetChild( "RewardPreView" ):SetContainer(objSwf.childPanel);
	--
	objSwf.txtDropImprove.autoSize  = "left";
	objSwf.txtExpImprove.autoSize   = "left";

	RewardManager:RegisterListTips( objSwf.dropList );
	RewardManager:RegisterListTips( objSwf.rewardList );

	--objSwf.btnClose.click      = function() self:(); end
	objSwf.btnEnter.click      = function() self:OnBtnEnterClick(); end
	-------------------------------------test -----------------------
	-- objSwf.btnTest.click      = function() self:OnBtnTestClick(); end   --测试按钮
	local listDungeonGroup     = objSwf.listDungeonGroup;
	listDungeonGroup.itemClick = function(e) self:OnDungeonGroupClick(e); end
	local listDungeon = objSwf.listDungeon;
	listDungeon.itemClick    = function(e) self:OnDungeonClick(e); end
	listDungeon.itemRollOver = function(e) self:OnDungeonOver(e); end
	listDungeon.itemRollOut  = function() self:OnDungeonOut(); end
	-- objSwf.btnRank.click     = function() self:OnBtnRankClick(); end
	objSwf.btnRule.rollOver    = function() self:OnBtnRuleRollOver() end
	objSwf.btnRule.rollOut     = function() self:OnBtnRuleRollOut() end

	objSwf.txtTimesInfo1.rollOver = function() self:OnCostrollOver(); end
	objSwf.txtTimesInfo1.rollOut = function() TipsManager:Hide(); end
	objSwf.tickets.rollOver = function() self:OnCostrollOver(); end
	objSwf.tickets.rollOut = function() TipsManager:Hide(); end
	-- objSwf.recordHead.headLoader.loaded = function(e) self:OnRecordHeadLoaded(e); end
	-- objSwf.difficulty.htmlText =  string.format( StrConfig['dungeon241']);
	-- objSwf.challengeLv.rollOver = function() self:OnChangeLvOver(); end
	-- objSwf.challengeLv.rollOut = function() TipsManager:Hide(); end
	objSwf.challengeLv._visible = true;
	objSwf.nextOpenLevels._visible = false
	objSwf.imgdiff._visible = true
	objSwf.btn_previewReward.click = function () self:OnShowPreviewReward() end 
	-- objSwf.tickets._visible = false
end

function UIDungeon:OnShow()
	self:UpdateShow();
	DailyMustDoController:ReqGetDailyMustDoList();
	DungeonController:ReqDungeonUpdate();
	self:InitChanllengeLv()
	local objSwf = self.objSwf;
	for i=1,5 do
		objSwf["difficultyItem"..i]._visible = false;
	end
	UIDungeonRewardPreView:Hide()
end

------事件----------------------

function UIDungeon:OnBtnCloseClick()
	self:Hide();
end

-- 显示等级奖励预览
function UIDungeon:OnShowPreviewReward( )
	local objSwf = self.objSwf
	if not objSwf then return end

	UIDungeonRewardPreView:OnOpen( self.difficityDungeonId ,objSwf.btn_previewReward )
end

function UIDungeon:OnBtnEnterClick()
	if not self.currData then return end
	local dungeonId = self.currData.dungeonId
	if not dungeonId then return end
	-- 正在倒计时的，先弹出放弃确认
	if UIDungeonCountDown.timerKey then
		self:OpenAbstainConfirm( UIDungeonCountDown.dungeonId, dungeonId );   
		return
	end
	print("Enter Dungeon id:",dungeonId)
	UIDungeon:EnterDungeon( dungeonId )
end

-- function  UIDungeon:OnBtnTestClick( )
-- 	local objSwf = self.objSwf;
-- 	UIDungeonSuccess:Open( 401,5)
-- end

function UIDungeon:OnBtnRuleRollOver()
	TipsManager:ShowBtnTips( StrConfig['dungeon310'], TipsConsts.Dir_RightDown )
end

function UIDungeon:OnBtnRuleRollOut()
	TipsManager:Hide()
end

function UIDungeon:OnHide()
	--是否有组队提示
	TeamUtils:UnRegisterNotice(self:GetName())
	self:CloseConfirm()
end;

-- 进入副本
function UIDungeon:EnterDungeon(dungeonId)
	local cfg = t_dungeons[dungeonId];
	if not cfg then return; end
	if cfg.type == DungeonConsts.Team then        --组队
		if TeamModel:IsInTeam() and not TeamUtils:MainPlayerIsCaptain() then
			FloatManager:AddSysNotice( 2005004 ); --只能队长可以发起组队副本
			return;
		end
	end
	local group = cfg.group;
	local dungeonGroup  = DungeonModel:GetDungeonGroup( group );
	local restFreeTimes = dungeonGroup:GetRestFreeTimes()
	local restPayTimes  = dungeonGroup:GetRestPayTimes()
	local isGodVip      = DungeonModel:CheckVip( )   --判断是不是钻石vip
	--@免费进入次数
	if restFreeTimes > 0 then
		-- 单人
		if cfg.type == DungeonConsts.SinglePlayer then
			local fun = function()
				-- debug.debug()
				DungeonController:ReqEnterDungeon( dungeonId )
			end;
			if TeamUtils:RegisterNotice(UIDungeon,fun) then
				return
			end;
		end;
		-- 组队
		DungeonController:ReqEnterDungeon( dungeonId )
	--@消耗道具进入次数
	elseif restPayTimes > 0 then
		local usedPayTimes = dungeonGroup:GetUsedPayTimes()
		local itemNum = usedPayTimes + 1; -- 第几次付费进入，就需要几个道具
		local itemId = cfg.pay_item;
		local itemId2 = cfg.pay_itemdaiti;
		local itemNum1 = BagModel:GetItemNumInBag( itemId )
		local itemNum2;
		if itemId2 then
			itemNum2 = BagModel:GetItemNumInBag( itemId2 )
		else
			itemNum2 = 0;
		end
		-- WriteLog(LogType.Normal,true,'-------------houxudong',itemNum1,itemNum2,itemNum,cfg.pay_item,cfg.pay_itemdaiti)
		if itemNum1 + itemNum2 < itemNum then
			if isGodVip == true then
				if DungeonModel:GetVipEnterNum( ) > 0 then
					self:OpenItemCostConfirm(dungeonId,DungeonConsts.VIP_TypeNoItem)
					return
				end
			end
			-- 道具不够
			FloatManager:AddCenter( StrConfig['dungeon211'] );  -- 道具不足
			return
		else
			local funs = function()
				DungeonController:ReqEnterDungeon( dungeonId )
			end;
			if TeamUtils:RegisterNotice(UIDungeon,funs) then
				return
			end;
			DungeonController:ReqEnterDungeon( dungeonId )
		end
		local confirmStr = ""
		if itemNum1 >= itemNum then
			local itemName = t_item[itemId].name
			confirmStr = string.format( "%sx%s", itemName, itemNum )
		elseif itemNum1 > 0 and itemNum1 + itemNum2 >= itemNum then
			local itemName1 = t_item[itemId].name
			local itemName2 = t_item[itemId2].name
			confirmStr = string.format( "%sx%s，%sx%s", itemName1, itemNum1, itemName2, (itemNum - itemNum1) )
		elseif itemNum2 >= itemNum then
			local itemName = t_item[itemId2].name
			confirmStr = string.format( "%sx%s", itemName, itemNum )
		end
		-- self:OpenItemCostConfirm( confirmStr, dungeonId);
	--@次数不够
	else
		if isGodVip == false then 
			FloatManager:AddNormal( StrConfig['dungeon2321'] )
			return
		else
			-- print("剩余次数黄金vip进入次数:",DungeonModel:GetVipEnterNum( ))
			if DungeonModel:GetVipEnterNum( ) > 0 then
				self:OpenItemCostConfirm(dungeonId,DungeonConsts.VIP_TypeNoTimes)
			else
				FloatManager:AddCenter( StrConfig['dungeon212'] );
			end
		end
	end
end

-- 钻石vip会员进入确认界面
function UIDungeon:OpenItemCostConfirm(dungeonId,type)
	local cfg = t_dungeons[dungeonId]
	if not cfg then
		Debug("not find cfg in t_dungeons",dungeonId) 
		return 
	end
	local dungeonName = ''
	dungeonName = cfg.name
	local type = type
	local content      = string.format(StrConfig["dungeon507"..type],dungeonName) 
	local confirmFunc  = function() DungeonController:ReqEnterDungeon( dungeonId ); end
	local confirmLabel = StrConfig["dungeon508"];
	local cancelLabel  = StrConfig["dungeon504"];
	local cancelFunc   = function()
		self:CloseConfirm()
	end 
	self.confirmUid = UIConfirm:Open( content, confirmFunc, cancelFunc, confirmLabel, cancelLabel );
end

function UIDungeon:CloseConfirm()
	if self.confirmUid then
		UIConfirm:Close( self.confirmUid )
		self.confirmUid = nil
	end
end

-- @param abstainId: 放弃的副本id
-- @param enterId: 要进入的副本id
function UIDungeon:OpenAbstainConfirm(abstainId, enterId)
	local cfg = t_dungeons[abstainId];
	if cfg then
		local dungeonName = cfg.name;
		local content = string.format( StrConfig["dungeon505"], dungeonName, dungeonName)
		local confirmFunc = function()
			UIDungeonCountDown:AbstainDungeon();
			self:EnterDungeon(enterId);
		end
		local confirmLabel = StrConfig["dungeon503"];
		local cancelLabel  = StrConfig["dungeon504"];
		self:CloseConfirm()
		self.confirmUid = UIConfirm:Open( content, confirmFunc, nil, confirmLabel, cancelLabel );
	end
end

function UIDungeon:OnDungeonGroupClick(e)
	local data = e.item;
	local group = data.group;
	if not group then return; end
	if group ~= self.currentShowGroup then
		self:UpdateDungeonGroup(group);   ---附魔组id  1 2 3 4
	end
	self.currentShowGroup = group;
	if UIDungeonRewardPreView:IsShow() then
		UIDungeonRewardPreView:Hide()
	end
end

function UIDungeon:OnDungeonClick(e)
	local dungeonInfo = e.item;
	if not dungeonInfo then return; end
	if dungeonInfo.dungeonId ~= self.currentShowDungeon then
		-- self:UpdateDungeon(dungeonInfo);
	end
end

function UIDungeon:OnDungeonOver(e)
	local data = e.item;
	if not data then return end
	local dungeonId           = data.dungeonId
	local diff                = data.difficulty
	local diffColor           = DungeonConsts:GetDifficultyColor( diff )
	local name                = data.name
	local diffName            = DungeonConsts:GetDifficultyName( diff )
	local cfg                 = t_dungeons[dungeonId];
	local enterLevel          = cfg.min_level;
	local levelEnough         = MainPlayerModel.humanDetailInfo.eaLevel >= enterLevel
	local levelReachStr       = levelEnough and StrConfig['dungeon225'] or StrConfig['dungeon226']
	local levelReachColor     = levelEnough and "##2FE00D" or "#dc2f2f"
	local canEnter            = data.canEnter
	local conditionReachStr   = canEnter and StrConfig['dungeon225'] or StrConfig['dungeon226']
	local conditionReachColor = canEnter and "##2FE00D" or "#dc2f2f"
	local conditionFormat     = (diff == DungeonConsts.Normal) and StrConfig['dungeon234'] or StrConfig['dungeon240']
	local conditionDes        = string.format( conditionFormat, enterLevel );
 -- 难度颜色，副本名称，副本难度，评分颜色，评分，进入等级颜色，达成状态
 -- 条件颜色，条件达成状态，条件描述
	local tipStr = string.format( StrConfig['dungeon232'], diffColor, name, diffName, levelReachColor,
		enterLevel, levelReachStr, conditionReachColor, conditionReachStr, conditionDes )
	TipsManager:ShowBtnTips( tipStr )
end

function UIDungeon:OnDungeonOut()
	TipsManager:Hide();
end

--[[
function UIDungeon:OnBtnRankClick()
	if not UIDungeonRank:IsShow() then
		self:ShowChild("rank");
	else
		UIDungeonRank:Hide();
	end
end
--]]

function UIDungeon:OnRecordHeadLoaded(e)
	-- local img = e.target.content;
	-- if img then
	-- 	img._width = 80;
	-- 	img._height = 80;
	-- end
end
--changer:houxudong date:2016/8/12
---------------------------------玩家根据自身等级挑战不同等级的副本-----------------
UIDungeon.difficityDungeonId = 0;   --当前副本难度id
function UIDungeon:InitChanllengeLv( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	local playerLv = MainPlayerModel.humanDetailInfo.eaLevel
	local totaldIfficulty = 0;     --当前组最大难度等级
	for k,v in pairs(t_dungeons) do
		if v.group == self.currentShowGroup then
			if playerLv >= v.min_level and playerLv <= v.max_level then
				self.difficityDungeonId = v.id;
			end
			if v.hide == 1 then   --显示奖励多少级显示
				totaldIfficulty = totaldIfficulty + 1;
			end
		end
	end
	local groupMaxCfg = t_dungeons[self.currentShowGroup*100 +totaldIfficulty];
	if not groupMaxCfg then
		Debug("not find suitable data in table")
		return
	end
	if groupMaxCfg.max_level and playerLv > groupMaxCfg.max_level then
		self.difficityDungeonId = self.currentShowGroup*100 +totaldIfficulty;
	end
	--  特殊条件
	local groupSpecialCfg = t_dungeons[self.currentShowGroup*100 +1]
	if playerLv >= groupSpecialCfg.unlock_level and playerLv < groupSpecialCfg.min_level then
		self.difficityDungeonId = self.currentShowGroup*100 +1
	end
	local diffCfg = t_dungeons[self.difficityDungeonId]
	if diffCfg then
		local minLevel = diffCfg.min_level or 0
		local maxLevel = diffCfg.max_level or 0
		objSwf.challengeLv.htmlText = string.format(StrConfig["dungeon242"],self.difficityDungeonId % 100,minLevel,maxLevel)
	end
	self:ShowNextChangeLv()
end

function UIDungeon:ShowNextChangeLv()
	local nextLv = self.difficityDungeonId % 100 + 1;    --下一等级
	local totaldIfficulty = 0;                           --当前组副本最大难度
	for k,v in pairs(t_dungeons) do
		if v.group == self.currentShowGroup then
			totaldIfficulty = totaldIfficulty + 1;
		end
	end
	local nextDungeonId = self.difficityDungeonId + 1;
	local minLevel = 0;                                   --下一等级最小开启等级
 	for k,v in pairs(t_dungeons) do
		if v.id == nextDungeonId then
			minLevel = v.min_level;
		end
	end
	local tips = ""
	if self.difficityDungeonId % 100 < totaldIfficulty then
		tips = string.format(StrConfig["dungeon243"],minLevel)
	else
		tips = string.format(StrConfig["dungeon244"])
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.nextOpenLevels.htmlText = tips
	-- TipsManager:ShowBtnTips(tips,TipsConsts.Dir_RightDown)
end

------------------------------------------------------------------------------------

function UIDungeon:UpdateShow()
	self:UpdateDungeonGroupList();
end

-- 更新副本列表
function UIDungeon:UpdateDungeonGroupList()
	-- 副本列表
	if not self.objSwf then return; end
	local list = self.objSwf.listDungeonGroup;
	list.dataProvider:cleanUp();
	local dungeonListData = self:GetDungeonGroupListData();
	-- 默认打开显示的副本id
	local defaultId = self.args and self.args[1]
	local cfg = defaultId and t_dungeons[defaultId]
	local defaultGroup = cfg and cfg.group
	local defaultIndex = 0
	for index, dungeonGroupData in ipairs(dungeonListData) do
		list.dataProvider:push( UIData.encode(dungeonGroupData) );
		if dungeonGroupData.group == defaultGroup then
			defaultIndex = index - 1
		end
	end
	list:invalidateData();
	list.selectedIndex = defaultIndex
	local currentRenderer = list:getRendererAt( defaultIndex );
	local currentGroup = currentRenderer and currentRenderer.data.group;
	-- 更新显示副本
	if currentGroup then
		self:UpdateDungeonGroup(currentGroup);
	end
end

-- 更新显示副本
function UIDungeon:UpdateDungeonGroup( group )
	self.currentShowGroup = group;
	-- 更新显示副本描述
	self:ReqUpdateDesInfo(group);

	-- self:UpdateDungeonList(group);
	self:UpdateDungeon()  -- 更新副本列表
	-- 更新进入次数信息
	self:UpdateTimesRestShow( group );
	-- 更新显示副本产出
	self:UpdateDungeonWorkOut(group);
end

function UIDungeon:ReqUpdateDesInfo( group )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local imgDesBgURL = ResUtil:GetDungeonDesBg( group );
	if objSwf.desBgLoader.source ~= imgDesBgURL then
		objSwf.desBgLoader.source = imgDesBgURL
	end
	local imgDesURL = ResUtil:GetDungeonDesImg( group );
	-- if objSwf.desLoader.source ~= imgDesURL then
	-- 	objSwf.desLoader.source = imgDesURL
	-- end
end

function UIDungeon:UpdateDungeonWorkOut( group )
	local objSwf = self.objSwf
	if not objSwf then return end
	local imgWorkOutBgURL = ResUtil:GetDungeonOutPutImg( group );
	if objSwf.outputLoader.source ~= imgWorkOutBgURL then
		objSwf.outputLoader.source = imgWorkOutBgURL
	end
	local groupInfo = DungeonUtils:GetGroupCfgInfo(group);
	local idAndName = groupInfo and groupInfo.funcID
	local funcID =  toint(split(idAndName,',')[1])
	objSwf.toGet.click = function() 
		if not FuncManager:GetFuncIsOpen(funcID) then
			local cfg = t_funcOpen[funcID]
			if not cfg then
				Debug("not find cfgData in t_funcOpen:",funcID)
			return
			end
			FloatManager:AddNormal(string.format(StrConfig['shopExtra007'],cfg.open_level,cfg.name))
			return
		end
		FuncManager:OpenFunc(funcID,true)
	end
	objSwf.openOtherFunc.htmlText = string.format("查看");
	objSwf.toGet.htmlLabel = string.format("<font><u><font color='#00ff00'>我的%s</font></u></font>",split(idAndName,',')[2]);
end

--进入消耗
UIDungeon.itemCfg = nil;
function UIDungeon:UpdateTimesRestShow(group)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not group then group = self.currentShowGroup end;
	local strings = {};
	local dungeonGroup  = DungeonModel:GetDungeonGroup( group )
	if not dungeonGroup then return end
	local restFreeTimes = dungeonGroup:GetRestFreeTimes()
	local restPayTimes  = dungeonGroup:GetRestPayTimes()
	local txtColorFree  = restFreeTimes > 0 and "#00FF00" or "#FF0000";
	local txtColorPay   = restPayTimes > 0 and "#00FF00" or "#FF0000";
	local groupCfg      = dungeonGroup:GetGroupCfg()
	local numFreeTimes  = groupCfg.free_times;
	local numPayTimes   = groupCfg.pay_times;
	-- 次数
	local leftEnterTimes = restFreeTimes + restPayTimes;         --当日剩余的进入次数
	local dailyCanEnterAllNum = numFreeTimes + numPayTimes       --当日可以进入的总次数
	local enterColor ="#FF0000"
	if leftEnterTimes == 0 then
		enterColor = "#FF0000"
	else
		enterColor = "#00FF00"
	end
	local strFreeTimes  = string.format( StrConfig['dungeon213'], enterColor, leftEnterTimes, dailyCanEnterAllNum )
	table.push( strings, strFreeTimes );
	-- 门票
	local str =""
	local costColor = "#00FF00"
	if restFreeTimes > 0 then
		str = StrConfig['dungeon906']
		objSwf.txtTimesInfo1._visible = false
	else
		objSwf.txtTimesInfo1._visible = true
	end
	if leftEnterTimes == 0 then
		str = StrConfig['dungeon907']
		objSwf.txtTimesInfo1._visible = false
	end
	local strExtraTimes = string.format( StrConfig['dungeon214'], costColor, str );
	table.push( strings, strExtraTimes );
	objSwf.txtTimesInfo1.htmlLabel = ""
	-- if restFreeTimes == 0 and restPayTimes > 0 then
		local needItem1 = groupCfg.pay_item;
		local needItem2 = groupCfg.pay_itemdaiti;
		local usedPayTimes = numPayTimes - restPayTimes;
		local needNum = usedPayTimes + 1; -- 第n次使用付费次数，就花费n个道具
		local itemNum1 = BagModel:GetItemNumInBag( needItem1 )
		local itemNum2 = BagModel:GetItemNumInBag( needItem2 )
		local itemEnough1 = itemNum1 >= needNum
		local itemEnough2 = itemNum2 >= needNum
		local itemEnough = itemNum1 + itemNum2 >= needNum
		local itemId = needItem1
		if not itemEnough1 and itemEnough2 then
			itemId = needItem2
		end
		self.itemCfg = t_item[itemId];
		if not self.itemCfg then
			Error( string.format( "can not find item id:%s in t_item config.", itemId ) );
			return;
		end
		local quality = self.itemCfg.quality
		if not quality then
			Error( string.format( "can not find item quality:%s in t_item config.", itemId ) );
			return;
		end
		local itemQualityColor = TipsConsts:GetItemQualityColor(quality)
		local txtColorItem = itemEnough and itemQualityColor or "#FF0000";
		local showItemName = self.itemCfg.name or "missing"
		objSwf.txtTimesInfo1.htmlLabel = string.format( "<font color='%s'><u>%s×%s</u></font>", txtColorItem, showItemName, needNum );
		-- table.push( strings, strItem );
	-- end
	local textField;
	for i = 2, 3 do
		textField = objSwf[ "txtTimesInfo" .. i ];
		textField.htmlText = table.remove( strings ) or "";
	end

	-- 副本说明信息
	objSwf.note1.htmlText = string.format(StrConfig['quest2000'],"#00FF00",numFreeTimes) --txtColorFree,restFreeTimes
	-- objSwf.note2.htmlText = string.format(StrConfig['quest2001'],"#00FF00",numPayTimes)  --txtColorPay ,restPayTimes
	objSwf.note3.htmlText = string.format(StrConfig['quest2002'])
	objSwf.note4.htmlText = string.format(StrConfig['quest2003'])
	objSwf.tickets.htmlLabel = string.format( "<font color='%s'><u>%s</u></font>", itemQualityColor, showItemName );
end

function UIDungeon:OnCostrollOver( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.itemCfg then return; end
	local id = self.itemCfg.id
	TipsManager:ShowItemTips(id);
end

--请求更新副本纪录信息
function UIDungeon:ReqUpdateRecordInfo(dungeonId)
	DungeonController:ReqDungeonRank(dungeonId);
end

--更新神话最快通关纪录信息
function UIDungeon:UpdateRecordInfo( dungeonId )
	local objSwf = self.objSwf;
	if not objSwf then return end
	--纪录信息
	local rankInfo = DungeonModel:GetRank( dungeonId );
	local championInfo = rankInfo and rankInfo.rankList and rankInfo.rankList[1];
	local championId = championInfo and championInfo.id;
	if championId == nil or championId == "0_0" then
		objSwf.txtRecordScore.htmlText = string.format( "<font color='#ff0000'>%s</font>", StrConfig['dungeon222'] );
		objSwf.txtRoleName.text = StrConfig['dungeon231'];
		objSwf.recordHead.headLoader:unload();
	else
		local highScore = DungeonUtils:ParseTime( championInfo.time )
		objSwf.txtRecordScore.htmlText = string.format( "<font color='#00FF00'>%s</font>", highScore );
		objSwf.txtRoleName.text = championInfo.name;
		local loader = objSwf.recordHead.headLoader;
		local source = ResUtil:GetHeadIcon( rankInfo.championIcon,false,true);
		if loader.source ~= source then
			loader.source = source;
		end
	end
end

-- 更新我的最高分数
function UIDungeon:UpdateMyHighScore( dungeonId )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local myTime = self:GetMyTime( dungeonId );
	-- print("--------我的通关时间:",myTime,dungeonId)
	local myScore = ""
	if myTime == 0 then
		myScore = StrConfig['dungeon230']
	else
		myScore = "<font color='#00FF00'>"..DungeonUtils:ParseTime( myTime ).."</font>"
	end
	-- local myScore = myTime == 0 and  or  "<font color='#2FE00D'>"..DungeonUtils:ParseTime( myTime ).."</font>"
	local myScoreTxt = string.format( StrConfig['dungeon233'], myScore );

	objSwf.txtMyScore.htmlText = myScoreTxt;
end


-----更新副本显示list
function UIDungeon:UpdateDungeonList(group)
	if not group then
		group = self.currentShowGroup;
	end
	if not self.objSwf then return; end
	local list = self.objSwf.listDungeon;
	list.dataProvider:cleanUp();
	local dungeonListData = self:GetDungeonListData(self.currentShowGroup);  --group
	if not dungeonListData then return; end
	-- 默认打开显示的副本id
	local defaultId = self.args and self.args[1]
	local defaultIndex = 0
	for index, dungeonVO in ipairs(dungeonListData) do
		list.dataProvider:push( UIData.encode(dungeonVO) );
		if defaultId ~= nil and dungeonVO.dungeonId == defaultId then
			defaultIndex = index - 1
		else
			local dungeonGroup = DungeonModel:GetDungeonGroup( self.currentShowGroup )  --group
			local currentCanEnterDiff = dungeonGroup:GetCurrentCanEnterDifficulty()
			defaultIndex = currentCanEnterDiff - 1
		end
	end
	list:invalidateData();
	list.selectedIndex = defaultIndex
	local currentRenderer = list:getRendererAt( defaultIndex );
	local currentDungeonInfo = currentRenderer and currentRenderer.data;
	if not currentDungeonInfo then return; end
	self:UpdateDungeon( currentDungeonInfo );
end

-- 更新副本获取信息
function UIDungeon:UpdateDungeon( )
	self:InitChanllengeLv()
	local dungeonId = self.difficityDungeonId	     --当前难度等级副本id
	-- local dungeonIds = dungeonInfo.dungeonId;
	-- local groupDungeonIdOne = math.floor(dungeonIds / 100);
	-- local groupDungeonIdOTwo = math.floor(dungeonId / 100);
	-- if groupDungeonIdOne == groupDungeonIdOTwo then
	-- 	dungeonId = dungeonId
	-- else
	-- 	FloatManager:AddCenter("请联系GM")
	-- 	return;
	-- end
	print("current dungeonId is:",dungeonId)
	if not dungeonId then return; end
	-- 请求更新副本纪录信息
	self:ReqUpdateRecordInfo(dungeonId);
	-- 更新我的最高分数
	self:UpdateMyHighScore(dungeonId);
	-- 更新进入条件文本显示
	self:UpdatePreconditionTxt(dungeonId);
	-- 更新副本掉落奖励信息
	self:UpdateDropInfo(dungeonId);
	-- 更新通关奖励信息
	self:UpdateRewardInfo(dungeonId);
	-- 更新进入按钮
	local canEnter = self:CheckDungeonItemCanEnter(dungeonId) --dungeonInfo.canEnter;
	print("update canCome InDungeon:",canEnter)
	self:UpdateEnterButton(dungeonId, canEnter);
	
	self.currentShowDungeon = dungeonId;
end

function UIDungeon:CheckDungeonItemCanEnter(dungeonId)
	local cfg = t_dungeons[dungeonId]
	local state = true
	if not cfg then return false end
	local openMinLevel = toint(cfg.min_level)
	local playLevel = MainPlayerModel.humanDetailInfo.eaLevel
	if playLevel < openMinLevel then
		state = false
	end
	return state
	
end

function UIDungeon:UpdatePreconditionTxt( dungeonId )
	if not self.objSwf then return; end
	-- self.objSwf.txtPrecondition.htmlText = DungeonUtils:GetConditionDes( dungeonId );
end

-- 更新副本掉落信息
function UIDungeon:UpdateDropInfo( dungeonId )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = t_dungeons[dungeonId];
	if not cfg then return; end
	-- 文本
	-- objSwf.txtDropImprove.text = cfg.drop_des;
	-- slots list
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	local cfgKey = string.format( "prof%s_show", prof )
	local dropItemList = RewardManager:Parse( cfg[cfgKey] );
	objSwf.dropList.dataProvider:cleanUp();
	objSwf.dropList.dataProvider:push( unpack(dropItemList) );
	objSwf.dropList:invalidateData();
	objSwf.dropItem1.visible = false;
	objSwf.dropItem2.visible = false;
	objSwf.dropItem3.visible = false;
	objSwf.dropItem4.visible = false;
end

-- 更新副本奖励信息
function UIDungeon:UpdateRewardInfo( dungeonId )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = t_dungeons[dungeonId];
	if not cfg then return; end
	-- 文本
	-- objSwf.txtExpImprove.text = cfg.reward_des;
	-- slots list
	local rewardItemList = RewardManager:Parse( cfg.rewards );
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push( unpack(rewardItemList) );
	objSwf.rewardList:invalidateData();
end

-- 更新进入按钮
function UIDungeon:UpdateEnterButton(dungeonId, canEnter)
	local objSwf = self.objSwf;
	local btn = objSwf and objSwf.btnEnter
	if not btn then return; end
	self.currData = {dungeonId = dungeonId, canEnter = canEnter};
	btn.disabled = not canEnter;
end

------------------------------
-- 获取副本组
function UIDungeon:GetDungeonGroupListData()
	local list = {};
	local srcList = DungeonModel:GetDungeonGroupList( DungeonConsts.ShowType_Normal )  --DungeonConsts.ShowType_Normal = 1
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	for group, dungeonGroup in pairs( srcList ) do
		--只有达到解锁等级后可见
		if dungeonGroup:IsUnlocked() then
			local cfgInfo  = dungeonGroup:GetGroupCfg()
			local minLevel = cfgInfo.min_level
			local maxLevel = cfgInfo.max_level;
			local vo = {};
			vo.group             = group;
			vo.restTimesDes      = dungeonGroup:GetRestTimeDes();
			vo.name              = cfgInfo.name
			vo.nameImgURL        = dungeonGroup:GetNameImgURL()
			vo.imgURL            = dungeonGroup:GetBgURL()
			-- vo.kindTxt           = DungeonConsts:GetDungeonRewardTypeTxt( cfgInfo.reward_type );  --可以获得的装备
			vo.needLevelTxt      = string.format( StrConfig['dungeon204'], cfgInfo.min_level );
			local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
			vo.needLevelTxtColor = myLevel >= cfgInfo.min_level and 0x00FF00 or 0xFF0000;
			-- vo.typeTxt           = DungeonConsts:GetDungeonTypeTxt( cfgInfo.type );    --组队状态
			vo.getName1          = split(string.format(cfgInfo.output),'#')[1]    --产出
			vo.getName2          = split(string.format(cfgInfo.output),'#')[2]
			vo.dailymustnum 	 = DailyMustDoUtil:GetDungeonDailyMustNum(group*100+ 1);
			local restFreeTimes,cfgFreeTimes = dungeonGroup:GetRestFreeTimes()
			vo.redPointNum       = restFreeTimes or 0
			vo.IsOpenEd          = myLevel >= cfgInfo.min_level and true or false
			table.push( list, vo );
		end
	end
	table.sort( list, function(A, B) return A.group < B.group end );
	return list;
end

-- 获取某副本组的各个难度副本列表
function UIDungeon:GetDungeonListData(group)
	local list = {};
	local dungeonGroup = DungeonModel:GetDungeonGroup( group );
	local groupCfgInfo = DungeonUtils:GetGroupCfgInfo( group );
	if not dungeonGroup then return; end
	for _, difficulty in ipairs( DungeonConsts.AllDiff ) do
		local vo = {};
		vo.dungeonId  = DungeonUtils:GetDungeonId(group, difficulty)
		vo.difficulty = difficulty
		vo.time       = dungeonGroup:GetMyTimeOfDifficulty( difficulty )
		vo.name       = groupCfgInfo.name
		-- 进入条件是否已达成
		vo.canEnter = true --DungeonUtils:CheckCanEnter( group, difficulty );
		local cfg   = t_dungeons[vo.dungeonId]
		if not cfg then return list; end
		vo.level    = cfg.min_level;
		table.push(list, vo);
	end
	-- table.sort( list, function(A, B) return A.difficulty < B.difficulty end );
	return list;
end

-- 获取我的难度最快通关用时
function UIDungeon:GetMyTime( dungeonId )
	local cfg = t_dungeons[dungeonId]
	if not cfg then return end
	local group        = cfg.group
	local difficulty   = cfg.difficulty
	local dungeonGroup = DungeonModel:GetDungeonGroup( group );
	-- print("------+++++++++:",dungeonGroup,dungeonGroup:GetMyTimeOfDifficulty( self.difficityDungeonId % 100 ))
	return dungeonGroup and dungeonGroup:GetMyTimeOfDifficulty( self.difficityDungeonId % 100 );
end

-- 当前显示的副本组
function UIDungeon:GetCurrentShowGroup()
	return self.currentShowGroup;
end

-- 当前显示的副本
function UIDungeon:GetCurrentShowDungeon()
	return self.currentShowDungeon;
end

function UIDungeon:IsShowLoading()
	return true;
end


---------------------------消息处理--------------------------------------

--监听消息列表
function UIDungeon:ListNotificationInterests()
	return {
		NotifyConsts.DungeonGroupChange,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.DungeonRank,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
	};
end

--处理消息
function UIDungeon:HandleNotification(name, body)
	if name == NotifyConsts.DungeonGroupChange then
		self:UpdateDungeonGroupList();
		-- self:UpdateDungeon();
	elseif name == NotifyConsts.DungeonRank then
		if body == self.currentShowDungeon then
			self:UpdateRecordInfo(body);
		end
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:UpdateDungeonGroupList();
			self:InitChanllengeLv();
			-- self:UpdateDungeon();
		end
	elseif name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		if body.type == BagConsts.BagType_Bag then
			self:UpdateTimesRestShow();
			-- debug.debug()
		end
	end
end

--
--------------------------------以下是功能引导相关接口-------------------
function UIDungeon:GetEnterButton()
	if not self:IsShow() then return; end
	return self.objSwf.btnEnter;
end

--面板中详细信息为隐藏面板，不计算到总宽度内
function UIRole:GetWidth()
	return 1146;
end

function UIRole:GetHeight()
	return 687;
end
