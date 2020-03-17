--[[
	2016年10月14日, PM 15:48:26
	诛仙阵主界面
	houxudong
]]

_G.UIGodDynastyDungeon = BaseUI:new('UIGodDynastyDungeon');

function UIGodDynastyDungeon:Create()
	self:AddSWF("GodDynastyDungeon.swf",true,nil);
end

function UIGodDynastyDungeon:OnLoaded( objSwf )
	objSwf.rewardlist.btn_challenge.click = function () self:OnChallengeClick(); end
	objSwf.rewardlist.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.btnRule.rollOver    = function() self:OnBtnRuleRollOver() end
	objSwf.btnRule.rollOut     = function() self:OnBtnRuleRollOut() end
	objSwf.rewardlist.rewardList.itemRollOut = function () TipsManager:Hide(); end
	objSwf.rewardlist.btn_rank.click = function () self:ShowGodDynastyRank(); end
	objSwf.ranklist.btn_back.click = function () self:ShowGodDynastyReward(); end
end

function UIGodDynastyDungeon:OnShow()
	-- 请求诛仙阵信息
	GodDynastyDungeonController:OnGetGodDynastyInfo();
	-- 处理右侧list
	self:InitRightList()
	-- 处理左侧文本信息
	self:InitRightInfo()
	self:ShowDungeonWorkOut()
end

function UIGodDynastyDungeon:ShowDungeonWorkOut( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local imgUrl = ''
	local funcID = 0
	local name = ''
	for k,v in pairs(DungeonConsts.DungeonOpenFuncIdAnaImgUrl) do
		if v[1] == FuncConsts.zhuxianDungeon then
			imgUrl = v[2]
			funcID = v[3]
			name   = v[4]
			break;
		end
	end
	local imgWorkOutBgURL = ResUtil:GetAllDungeonOutPutImg( imgUrl );
	if objSwf.outputLoader.source ~= imgWorkOutBgURL then
		objSwf.outputLoader.source = imgWorkOutBgURL
	end
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
	objSwf.toGet.htmlLabel = string.format("<font><u><font color='#00ff00'>我的%s</font></u></font>",name);
end

-- 处理右侧list
function UIGodDynastyDungeon:InitRightList()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.rewardlist._visible = true
	objSwf.ranklist._visible = false
end

-- 处理左侧文本信息
function UIGodDynastyDungeon:InitRightInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.lblOpenTimes.htmlText  = StrConfig['goddynasity2']
	local openLevel = _G.t_funcOpen[121].open_prama
	objSwf.lblConditions.htmlText = string.format( StrConfig['goddynasity3'], openLevel )
	objSwf.lblRule.htmlText = string.format( StrConfig['goddynasity4'] )
end

-- 右侧界面信息
function UIGodDynastyDungeon:OnChangeRewardListPanelData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local godDynastyData = GodDynastyDungeonModel.godDynastyData;
	-- 我的历史挑战最高层数
	objSwf.rewardlist.txt_max.htmlText = string.format(StrConfig['goddynasity7'],godDynastyData.maxHistoryLayer or 0);
	-- 产出物品预览
	if godDynastyData.layer == 0 then
		godDynastyData.layer = 1;
	end
	local cfg = t_zhuxianzhen[godDynastyData.layer]
	self:OnDrawRewardList(cfg)
	-- 满层条件判定
	local dailyMaxLayer = 0;
	if t_consts[318] then
		dailyMaxLayer = toint(t_consts[318].val1);
	end
	objSwf.rewardlist.dailyMaxTxt._visible = false
	objSwf.rewardlist.dailyMaxTxt.htmlText = ""
	if godDynastyData.maxLayer >= dailyMaxLayer then
		objSwf.rewardlist.dailyMaxTxt._visible = true
		objSwf.rewardlist.dailyMaxTxt.htmlText = string.format(StrConfig['goddynasity1']);
		objSwf.rewardlist.btn_challenge.disabled = true;
	else
		objSwf.rewardlist.btn_challenge.disabled = false;
	end
end

-- 预览奖励(根据权重随机获得)
function UIGodDynastyDungeon:OnDrawRewardList(cfg)
	local objSwf = self.objSwf
	if not cfg or not objSwf then return end
	local isShowNum = false
	local rewardList = split(cfg.reward,'#')
	if not rewardList then
		return;
	end
	local rewardStr = '';
	for i,v in ipairs(rewardList) do
		local vo = split(rewardList[i],',')
		table.remove(vo,3)
		if isShowNum then                --物品上显示数量
			rewardStr = rewardStr .. ( i >= #rewardList and vo[1] .. ',' .. vo[2] or vo[1] .. ',' .. vo[2] .. '#'  )
		else
			rewardStr = rewardStr .. ( i >= #rewardList and vo[1] or vo[1] ..'#'  )
		end
	end
	local rl = RewardManager:Parse(rewardStr);
	objSwf.rewardlist.rewardList.dataProvider:cleanUp();
	objSwf.rewardlist.rewardList.dataProvider:push(unpack(rl));
	objSwf.rewardlist.rewardList:invalidateData();
	local itemList = {};
	itemList[1] = objSwf.rewardlist.item1;
	itemList[2] = objSwf.rewardlist.item2;
	itemList[3] = objSwf.rewardlist.item3;
	itemList[4] = objSwf.rewardlist.item4;
	UIDisplayUtil:HCenterLayout(#rl, itemList, 58, 145, 343);
	itemList = nil;
end


-- 显示排行榜信息
function UIGodDynastyDungeon:OnChangeRankList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.ranklist.listPlayer.dataProvider:cleanUp();
	objSwf.ranklist.listMy.dataProvider:cleanUp();
	local list = GodDynastyDungeonModel.rankListInfo;
	if list == {} then return end
	objSwf.ranklist.name.htmlText = list[1].name  -- 特殊处理排名第一的玩家
	objSwf.ranklist.layer.htmlText = StrConfig['goddynasity5'];
	objSwf.ranklist.layerNum.htmlText = list[1].tier;
	for i , v in ipairs(list)  do
		if i > 1 then
			local vo = {};
			vo.rank = i;
			vo.playerLevel = v.level;
			vo.layer = string.format(StrConfig['goddynasity6'],v.tier);
			vo.playerName = v.name
			objSwf.ranklist.listPlayer.dataProvider:push(UIData.encode(vo));
		end
	end
	objSwf.ranklist.listPlayer:invalidateData();

	local roleID = MainPlayerController:GetRoleID()
	local index = 0;
	for i,v in ipairs(list) do
		if v.roleID == roleID then
			local vo = {};
			vo.rank =  i;
			vo.layer = string.format(StrConfig['goddynasity6'],v.tier);
			vo.playerName = v.name
			objSwf.ranklist.listMy.dataProvider:push(UIData.encode(vo));
			objSwf.ranklist.listMy:invalidateData();
		else
			index = index +1;
		end
	end
	--未上榜
	if index >= #list then
		local info = MainPlayerModel.humanDetailInfo
		local vo = {};
		vo.playerName = info.eaName
		vo.rank = 'z';   --未上榜 默认为z和字体资源保持一致
		local godDynastyData = GodDynastyDungeonModel.godDynastyData;
		vo.layer = string.format(StrConfig['goddynasity6'],godDynastyData.maxLayer or 0);
		objSwf.ranklist.listMy.dataProvider:push(UIData.encode(vo));
		objSwf.ranklist.listMy:invalidateData();
	end
end

function UIGodDynastyDungeon:ShowGodDynastyRank()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.rewardlist._visible = false
	GodDynastyDungeonController:OnGetGodDynastyRankList();  --请求排行榜数据
	objSwf.ranklist._visible = true
end

function UIGodDynastyDungeon:ShowGodDynastyReward()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.rewardlist._visible = true
	objSwf.ranklist._visible = false
end

-- 进入挑战
function UIGodDynastyDungeon:OnChallengeClick()
	-- 挑战层数超过今日最大挑战层数
	local godDynastyData = GodDynastyDungeonModel.godDynastyData;
	local curLayer = godDynastyData.layer or 0
	local dailyMaxLayer = 0;
	if t_consts[318] then
		dailyMaxLayer = toint(t_consts[318].val1);
	end
	if curLayer >= dailyMaxLayer then
		FloatManager:AddNormal( StrConfig["goddynasity1"] );
		return
	end
	local func = function() 
		GodDynastyDungeonController:OnGetEnterGodDynasty()
	end
	-- 组队禁止进入
	if TeamModel:IsInTeam() then
		if TeamUtils:RegisterNotice( UIGodDynastyDungeon,func ) then
			return
		end
	end
	func()
end

function UIGodDynastyDungeon:OnBtnRuleRollOver()
	TipsManager:ShowBtnTips( StrConfig['goddynasity9'], TipsConsts.Dir_RightDown )
end

function UIGodDynastyDungeon:OnBtnRuleRollOut()
	TipsManager:Hide()
end

function UIGodDynastyDungeon:IsShowLoading()
	return true;
end

-----------------------消息监听----------------------------
-----------------------------------------------------------
function UIGodDynastyDungeon:HandleNotification(name,body)
	if name == NotifyConsts.GodDynastyRankUpdate then
		self:OnChangeRankList()
	elseif name == NotifyConsts.GodDynastyUpData then
		self:OnChangeRewardListPanelData()
	end
end

function UIGodDynastyDungeon:ListNotificationInterests()
	return {
		NotifyConsts.GodDynastyRankUpdate,
		NotifyConsts.GodDynastyUpData,
	}
end

function UIGodDynastyDungeon:InitData ()
	local objSwf = self.objSwf
	if not objSwf then return end;
end
