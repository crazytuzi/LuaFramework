--[[
排行界面
]]

_G.UIInterServiceRongyaoRanking = BaseUI:new("UIInterServiceRongyaoRanking");

UIInterServiceRongyaoRanking.curPage = 0;
UIInterServiceRongyaoRanking.curList = {};
UIInterServiceRongyaoRanking.onePage = 10;
UIInterServiceRongyaoRanking.timerKey = nil;
UIInterServiceRongyaoRanking.curCfg = nil

function UIInterServiceRongyaoRanking:Create()
	self:AddSWF("interServerRongyaoRankPanel.swf", true, "top");
end;
function UIInterServiceRongyaoRanking:OnLoaded(objSwf)	
	objSwf.btnClose.click = function() self:CloseClick() end
	objSwf.btnPre1.click = function() self:PagePre1() end
	objSwf.btnPre.click = function() self:PagePre() end
	objSwf.btnNext.click = function() self:PageNext() end
	objSwf.btnNext1.click = function() self:PageNext1() end
	objSwf.txtPage.text = '1/1'
	objSwf.txtInfo.htmlText = StrConfig['interServiceDungeon25']
	RewardManager:RegisterListTips( objSwf.rewardList )
	objSwf.btnPeview.click = function() 
		self.isNext = not self.isNext
		self:SetShowState()
	end
	objSwf.Getitem.click = function()
		InterServicePvpController:ReqGetPvpRongyaoReward()
	end
end;
function UIInterServiceRongyaoRanking:OnShow()
	self.isNext = false	
	-- self:UpdateInfo()
	self:JumpTabe()
	InterServicePvpController:ReqKuafuRongyaoInfo()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function() 
			self:Ontimer()
		end,1000,0);
	self:Ontimer();	
end;

function UIInterServiceRongyaoRanking:SetShowState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local cfg = nil
	if self.isNext then	
		objSwf.btnPeview.htmlLabel = StrConfig['interServiceDungeon26']
		
		if self.curCfg then cfg = t_kuafubenfu[self.curCfg.id + 1] end
		objSwf.Getitem.disabled = true
	else
		objSwf.btnPeview.htmlLabel = StrConfig['interServiceDungeon27']
		cfg = self.curCfg
		if InterServicePvpModel.isAward == 1 then
			objSwf.Getitem.disabled = false;
		else
			objSwf.Getitem.disabled = true
		end
	end
	
	if cfg then
		local bzNum = InterServicePvpModel.benfuBZNum or 0
		local cfgNum = self:GetCfgNum(cfg.id)
		
		local colorStr = '#ff0000'
		if bzNum >= cfgNum then
			colorStr = '#29CC00'
		end
		objSwf.txtReach.htmlText = string.format(StrConfig['interServiceDungeon24'],colorStr, bzNum, cfgNum)
		
		objSwf.rewardList.dataProvider:cleanUp()
		objSwf.rewardList.dataProvider:push( unpack( RewardManager:Parse( cfg.reward ) ) )
		objSwf.rewardList:invalidateData()
	end
end

function UIInterServiceRongyaoRanking : Ontimer()
	local objSwf = self.objSwf;
	if not objSwf then return end

	local time = GetDayTime();  -- 今天过了多少秒
	local refreshTime = 22*3600
	local tc = 0
	if refreshTime >= time then
		tc = 22*3600-time;
	else
		tc = 46*3600-time;
	end
	-- if tc == 0 then
		-- InterServicePvpModel.isAward = 1		
		-- objSwf.Getitem.disabled = false;
	-- end
	
	local t,s,m = ArenaModel : GetCurtime(nil,tc)--CTimeFormat:sec2format(tc)
	objSwf.txtTime.text = string.format(StrConfig["arena137"],t,s,m);
end;

function UIInterServiceRongyaoRanking:UpdateInfo()
	local objSwf = self.objSwf;	
	if not objSwf then 
		return 
	end;

	local bzNum = InterServicePvpModel.benfuBZNum or 0
	local isAward = InterServicePvpModel.isAward or 0
	self.curCfg = self:GetCfgByNum(bzNum)
		
	objSwf.txtNum.text = bzNum..'人'	
	if self.curCfg then 
		local maxLevel = InterServicePvpModel:GetMaxLevel()
		if self.curCfg.id >= maxLevel then
			objSwf.btnPeview.visible = false
		else
			objSwf.btnPeview.visible = true
		end
	end
	self:SetShowState()
end

function UIInterServiceRongyaoRanking:OnHide()
	TimerManager:UnRegisterTimer(self.timerKey);
	self.timerKey = nil;
end;

function UIInterServiceRongyaoRanking:CloseClick()
	self:Hide();
end;

-- 跳转到需要显示的界面
function UIInterServiceRongyaoRanking:JumpTabe()
	local objSwf = self.objSwf;	
	if not objSwf then 
		return 
	end;

	self.curPage = 0;
	if self:IsShow() then 
		InterServicePvpController:ReqKuafuRankDuanweiList(2);
	end;
end;

-- 显示初始化list
function UIInterServiceRongyaoRanking:ShowInitList()
	local objSwf = self.objSwf;	if not objSwf then return end
	-- 清空数据
	objSwf.listtxt.dataProvider:cleanUp();
	objSwf.listtxt.dataProvider:push(unpack({}));
	objSwf.listtxt:invalidateData();

	self.curList = InterServicePvpModel:GetInterServiceRongyaoList()
	local lisc = self:GetListPage(self.curList,self.curPage);
	-- FTrace(lisc)
	if not lisc then return end;
	local voc = {}
	for i,info in ipairs(lisc) do
		local vo = self:GetRoleItemUIdata(info,10)
		if not vo then break end;
		table.push(voc,vo)
	end;
	objSwf.listtxt.dataProvider:cleanUp();
	objSwf.listtxt.dataProvider:push(unpack(voc));
	objSwf.listtxt:invalidateData();
	-- 设置当前已经是最前
	self:SetPagebtn();
end;

---翻页控制
-- 最前
function UIInterServiceRongyaoRanking:PagePre1()
	local objSwf = self.objSwf;	if not objSwf then return end
	self.curPage = 0;
	UIInterServiceRongyaoRanking:ShowInitList()
end;
-- 前
function UIInterServiceRongyaoRanking:PagePre()
	local objSwf = self.objSwf;	if not objSwf then return end
	self.curPage = self.curPage-1;
	UIInterServiceRongyaoRanking:ShowInitList()
end;
-- 最后
function UIInterServiceRongyaoRanking:PageNext1()
	local objSwf = self.objSwf;	if not objSwf then return end
	local len = RankListUtils:GetListLenght(self.curList)
	self.curPage = len;
	UIInterServiceRongyaoRanking:ShowInitList()
end;
-- 后
function UIInterServiceRongyaoRanking:PageNext()
	local objSwf = self.objSwf;	if not objSwf then return end
	self.curPage = self.curPage+1;
	local len = RankListUtils:GetListLenght(self.curList)
	UIInterServiceRongyaoRanking:ShowInitList()
end;

-- 得到当前页数下的itemlist
function UIInterServiceRongyaoRanking:GetListPage(list,page)
	local vo = {};
	page = page + 1;
	for i=(self.onePage*page)-self.onePage+1,(self.onePage*page) do 
		table.push(vo,list[i])
	end;
	return vo
end;

function UIInterServiceRongyaoRanking:GetRoleItemUIdata(info)
	if not info then return end;
	
	local vo = {};
	vo.roleid = info.roleid;
	vo.prof = info.role;
	vo.roleName = info.roleName;
	vo.roleLvl = info.lvl;
	vo.vipLvl  = info.vipLvl;
	local vipStr = ResUtil:GetVIPIcon(info.vipLvl);
	if vipStr and vipStr ~= "" then 
		vipStr = "<img src='"..vipStr.."'/>";
		vo.roleName = vipStr .. vo.roleName;
	end;
	-- local vflagStr = ResUtil:GetVIcon(info.vflag);
	-- if vflagStr and vflagStr ~= "" then 
		-- vflagStr = "<img src='"..vflagStr.."'/>";
		-- vo.roleName = vflagStr..vo.roleName;
	-- end;
	vo.isFirst = false;
	if info.rank == 3 then 
		vo.rank = "c";
		vo.isFirst = true;
	elseif info.rank == 2 then 
		vo.rank = "b";
		vo.isFirst = true;
	elseif info.rank == 1 then 
		vo.rank = "a";
		vo.isFirst = true;
	else 
		vo.rank = info.rank;
		vo.isFirst = false;
	end;
	-- vo.head = ResUtil:GetHeadIcon60(info.role)	
	-- FPrint(vo.head)
	vo.rankvlue = InterServicePvpModel:GetMyDuanwei(info.rankvlue)
	vo.fight = InterServicePvpModel:GetMyDuanwei(info.rankvlue)
	
	if info.role <= 0 or info.role > 4 then 
		print("*******Error********：abot roleType is nil . No ShowList   AT  ranklistSuitview  '119' line")
		return 
	end;	
	return UIData.encode(vo)
end;

function UIInterServiceRongyaoRanking:SetPagebtn()
	local objSwf = self.objSwf;	if not objSwf then return end
	local curpage = self.curPage+1;
	local curTotal = RankListUtils:GetListLenght(self.curList)+1;
	if curTotal < 1 then curTotal = 1 end
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

function UIInterServiceRongyaoRanking:GetCfgByNum(num)
	for k,v in pairs(t_kuafubenfu) do
		local arr = split(v.number, ',')
		if num >= toint(arr[1]) and num <= toint(arr[2]) then
			return v
		end
	end
	
	local cfg = t_kuafubenfu[1]
	-- cfg.id = 0
	return cfg
end

function UIInterServiceRongyaoRanking:GetCfgNum(cfgId)
	if cfgId == 0 then cfgId = 1 end
	local cfg = t_kuafubenfu[cfgId]
	if not cfg then return 0 end
	
	local arr = split(cfg.number, ',')
	return toint(arr[1])		
end

------ 消息处理 ---- 
function UIInterServiceRongyaoRanking:ListNotificationInterests()
	return {
		NotifyConsts.InterServerPvpRongyaoUpdata,
		NotifyConsts.InterServerKuafuRongyaoInfo,
		NotifyConsts.InterServerKuafuRongyaoReward,
		}
end;
function UIInterServiceRongyaoRanking:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.InterServerPvpRongyaoUpdata then 
		self:ShowInitList();
	elseif name == NotifyConsts.InterServerKuafuRongyaoInfo then
		self:UpdateInfo()
	elseif name == NotifyConsts.InterServerKuafuRongyaoReward then	
		self:GoRewardfun()
	end

end;

function UIInterServiceRongyaoRanking:GoRewardfun()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	if InterServicePvpModel.isAward == 1 then
		objSwf.Getitem.disabled = false;
	else
		objSwf.Getitem.disabled = true
	end
	
	if not self.curCfg then return end
	local rewardList = RewardManager:ParseToVO(self.curCfg.reward);
	local startPos = UIManager:PosLtoG(objSwf.item_l1,0,0);
	RewardManager:FlyIcon(rewardList,startPos,5,true,60);
	SoundManager:PlaySfx(2041);	
end;