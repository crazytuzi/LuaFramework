--[[
	主宰之路MODEL
	2015年5月27日, PM 04:24:14
	wangyanwei
]]

_G.DominateRouteModel = Module:new();

--UI上的数据
DominateRouteModel.dominateRouteData = {};      --UI上的基本数据
DominateRouteModel.dominateRouteEnterNum = 0;   --剩余进入次数

--3星奖励领取状态
DominateRouteModel.dominateRouteThreeStarRewardGetSate = 0;

DominateRouteModel.StageConstsNum = 10000;

--第一次收到数据
function DominateRouteModel:OnSetDominateRouteData(stageList,enterNum)
	
	-- if not verlList then return; end
	-- if #verlList < 1 then
	-- 	return
	-- end
	if #stageList < 1 then
		return
	end
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	
	local openList = {};
	for i , v in ipairs(t_roadbox) do
		if level >= v.level then
			local vo1 = DominateRouteVeilVO:new();
			vo1.id = t_roadbox[i].id;
			-- vo1.rewardState = verlList[i].rewardState;
			table.push(openList,vo1);
		end
	end
	local vo ={};
	for i , v in ipairs(stageList) do
		local stage = toint(v.id/self.StageConstsNum);
		if not vo[stage] then
			vo[stage] = {};
		end
		local dominateCfg = t_zhuzairoad[ v.id ];
		if dominateCfg then
			local titleVO = DominateRouteStageVO:new();
			titleVO.id = v.id;
			titleVO.state = v.state;    -- 领奖状态  0 不能领取 1  可以领取  2已领取
			titleVO.starLevel = v.evaluate;
			titleVO.num = dominateCfg.daliyNum and dominateCfg.daliyNum - v.num;     --每个小章节剩余的次数
			titleVO.timeNum = v.timeNum;
			titleVO.maxNum = v.maxNum;
			table.push(vo[stage],titleVO);
		end
	end
	for i , v in pairs(vo) do
		if #v > 1 then
			table.sort(v,function(A,B)
				return A:GetStageID() < B:GetStageID()
			end)
		end
	end
	local openListNum = 0;
	for i , v in ipairs(openList) do
		local cfg = vo[i];
		if not cfg then return; end
		self.dominateRouteData[i] = {};
		--标题data
		self.dominateRouteData[i].title = v;
		--章节data
		self.dominateRouteData[i].data = {};
		
		local starNum = 0;
		
		for j = 1 , cfg[#cfg]:GetStageID() % self.StageConstsNum do
			for o , p in ipairs(cfg) do
				if p.id %self.StageConstsNum == j then
					self.dominateRouteData[i].data[j] = p;
				end
			end
			--如果没有发这条数据，就是默认值  没有正在被扫荡，并且三星满状态、次数
			if not self.dominateRouteData[i].data[j] then
				local newVo = DominateRouteStageVO:new();
				newVo.id = t_zhuzairoad[ i*self.StageConstsNum + j ].id;
				newVo.state = DominateRouteConsts.DOMINATEROUTELEISURE;
				newVo.starLevel = 3;
				newVo.maxNum = 0;
				newVo.num = enterNum;
				self.dominateRouteData[i].data[j] = newVo;
			end
			starNum = starNum + self.dominateRouteData[i].data[j]:GetStageLevel();
		end
		self.dominateRouteData[i].title:SetStarNum(starNum);
	end
	self:OnAddInitData();
	-- local cfgNum = self:GetOpenRodeTotalNum()
	-- local times = cfgNum > t_consts[71].fval and t_consts[71].fval or cfgNum
	-- self.dominateRouteEnterNum = times - (enterNum or 0)
	-- self:sendNotification(NotifyConsts.DominateRouteTimeUpData);
	self:OnSetenterNum(enterNum)
end

function DominateRouteModel:OnSetenterNum( num )
	self.enterNum = num
end

function DominateRouteModel:GetDominateNum()
	
end

function DominateRouteModel:GetEnterNum( )
	return self.enterNum or 0
end

--储存已购买精力次数
DominateRouteModel.jingliBuyBum = 0;
function DominateRouteModel:OnBackJingliBuyNum(num)
	self.jingliBuyBum = num;
end

function DominateRouteModel:GetJingLiBugNum()
	return self.jingliBuyBum;
end

--获取剩余总次数
function DominateRouteModel:OnGetEnterNum()
	local cfgNum = self:GetOpenRodeTotalNum()
	local times = cfgNum > t_consts[71].fval and t_consts[71].fval or cfgNum
	return times - self:GetEnterNum()
end

--进入成功 扣除剩余次数1
function DominateRouteModel:OnCutEnterNum(num)
	if not num then
		return
	else
		self:OnSetenterNum(num)
	end
end

--返回领奖协议
function DominateRouteModel:BoxRewardUpData(id)
	local boxCfg = self:GetDominateRouteTitleInfo(id);
	boxCfg:SetRewardState(DominateRouteConsts.REWARDPOSSESS);
end

--刷新协议
function DominateRouteModel:OnDominateUpData(num,state,time,id)
	if not self:GetIsHaveStage(id) then
		self:InitDominateRouteData(num,state,time,id);
	end
	
	for i , cfg in ipairs(self.dominateRouteData) do
		for j , dominateRoute in ipairs(cfg.data) do
			if dominateRoute:GetStageID() == id then 
				dominateRoute:SetDaliyNum(t_zhuzairoad[ id ].daliyNum - num);
				dominateRoute:SetStageState(state);
				dominateRoute:SetTimeNum(time);
				return
			end
		end
	end
end

--刷新等级
function DominateRouteModel:OnUpDataLevel(id,level)
	for i , cfg in ipairs(self.dominateRouteData) do
		--把刷新的星级加上
		local titleCfg = self.dominateRouteData[i].title;
		
		for j , dominateRoute in ipairs(cfg.data) do
			if dominateRoute:GetStageID() == id then 
				if level > dominateRoute:GetStageLevel() then
					titleCfg:AddStarNum(level - dominateRoute:GetStageLevel());
				end
				dominateRoute:SetStageLevel(level);
				return
			end
		end
	end
end

--根据ID获取title信息  取得星级和领奖状态
function DominateRouteModel:GetDominateRouteTitleInfo(index)
	local cfg = self.dominateRouteData[index];
	if not cfg then return nil end
	return cfg.title;
end

--返回扫荡信息 有新的副本扫荡了
function DominateRouteModel:OnHaveDominateRouteMopup(id,num)
	for i , cfg in ipairs(self.dominateRouteData) do
		for j , dominateRoute in ipairs(cfg.data) do
			if dominateRoute:GetStageID() == id then 
				-- dominateRoute:SetStageState(DominateRouteConsts.DOMINATEROUTEMOPUP);
				-- dominateRoute:SetTimeNum(t_zhuzairoad[id].sweep_limit * num);  --
				-- dominateRoute:SetMaxNum(num);
				-- self:OnMopupTimeHandler();
				-- local leftNum = dominateRoute:GetDaliyNum();   --当前剩余的次数
				local daliyNum = toint(t_zhuzairoad[id].daliyNum);
				local curNum  = daliyNum - num
				dominateRoute:SetDaliyNum(curNum)
				return
			end
		end
	end
end

-- 检测已开通关卡3星可挑战的次数
function DominateRouteModel:GetTimes()
	for i , cfg in ipairs(self.dominateRouteData) do
		for j , dominateRoute in ipairs(cfg.data) do
			if dominateRoute:GetStageLevel() == 3 then 
				if dominateRoute:GetDaliyNum() > 0 then
					return true
				end
			end
		end
	end
	return false;
end

--一键扫荡获取三星可以扫荡（且扫荡次数满足）的总奖励
function DominateRouteModel:GetMopupTaotalReward( )
	local rewardStrs = ''
	local num = 0
	for i,cfg in ipairs(self.dominateRouteData) do
		for j , dominateRoute in ipairs(cfg.data) do
			if dominateRoute:GetStageLevel() == 3 then
				if dominateRoute:GetDaliyNum() > 0 then
					local cfgs = t_zhuzairoad[cfg.data[j].id]
					if not cfgs then return end
					num = num +1
					if num == 1 then
						rewardStrs = cfgs.rewardStr
					else
						rewardStrs = rewardStrs ..'#'.. cfgs.rewardStr
					end
				end
			end
		end
	end
	local rewardList = split(rewardStrs,'#')
	local lists = {}
	for k,v in pairs(rewardList) do
		local vo = split(v,',')
		table.push(lists,vo)
	end
	table.sort( lists, function(A,B)
		return toint(A[1]) < toint(B[1])
	end )
	for k,v in pairs(lists) do
		for i=1,k-1 do
			if toint(lists[k][1]) == toint(lists[i][1]) then
				lists[k][2] = lists[k][2] + lists[i][2]
				lists[i][1] = 0
			end
		end
	end
	local strList = {}
	for i=1,#lists do
		if toint(lists[i][1]) ~= 0 then
			local vo = {}
			vo[1] = lists[i][1]
			vo[2] = lists[i][2]
			table.push(strList,vo)
		end
	end
	local rewardStr = ''
	for i,vo in ipairs(strList) do
		rewardStr = rewardStr .. ( i >= #strList and vo[1] .. ',' .. vo[2] or vo[1] .. ',' .. vo[2] .. '#'  )
	end
	return rewardStr
end

--返回扫荡信息---所有的副本扫荡
function DominateRouteModel:OnHaveDominateQuicklySaodang(stagelist,num)
	for i,cfg in ipairs(self.dominateRouteData) do
		for j , dominateRoute in ipairs(cfg.data) do
			for i,v in ipairs(stagelist) do
				if dominateRoute:GetStageID() == v.id then
					local daliyNum = dominateRoute:GetDaliyNum()
					local curNum = daliyNum - v.num >= 0 and daliyNum - v.num or 0
					dominateRoute:SetDaliyNum(curNum)
				end
			end
		end
	end
	self:OnCutEnterNum(num)
end

--返回领奖结果
function DominateRouteModel:RodBoxRewardUpData(id,state)
	for i,cfg in ipairs(self.dominateRouteData) do
		for j , dominateRoute in ipairs(cfg.data) do
			if dominateRoute:GetStageID() == id then
				dominateRoute:SetStageState(state);
			end
		end
	end
end

--检测第一个大章节对应的第一个小章节的三星通关奖励有没有领取
function DominateRouteModel:CheckFirstRewardState()
	if not self.dominateRouteData then return false end
	for i,cfg in ipairs(self.dominateRouteData) do
		for j , dominateRoute in ipairs(cfg.data) do
			if dominateRoute:GetStageID() == 10001 then
				if dominateRoute:GetStageState() == 1 then
					return true
				end
			end
		end
	end
	return false
end

--扫荡副本计时
function DominateRouteModel:OnMopupTimeHandler()
	if not self:OnGetIsMopup() then
		return
	end
	local vo = self:GetInMopup();
	local num = vo:GetMaxNum() * t_zhuzairoad[vo:GetStageID()].sweep_limit;
	local minNum = vo:GetMaxNum() * t_zhuzairoad[vo:GetStageID()].sweep_limit - vo:GetTimeNum();
	local func = function ()
		minNum = minNum + 1;
		if minNum > num then
			if self.timeKey then
				TimerManager:UnRegisterTimer(self.timeKey);
				self.timeKey = nil;
			end
		end
		self:sendNotification(NotifyConsts.DominateRouteTimeUpData,{num = minNum});
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

--关掉定时
function DominateRouteModel:CloseTime()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

--获取UI上要显示已开通的关卡
function DominateRouteModel:OnGetOpenDonminate()
	return self.dominateRouteData;
end

--根据ID获取VO
function DominateRouteModel:OnGetDominateVO(id)
	for i , cfg in ipairs(self.dominateRouteData) do
		for j , dominateRoute in ipairs(cfg.data) do
			if dominateRoute:GetStageID() == id then 
				return dominateRoute;
			end
		end
	end
	return nil
end

--是否通关过  false 未打过 
function DominateRouteModel:GetDominateRouteIsPass(id)
	local dominateRoute = self:OnGetDominateVO(id);
	if not dominateRoute then return nil end
	return dominateRoute:GetStageLevel() ~= 0
end

--是否有正在扫荡的副本
function DominateRouteModel:OnGetIsMopup()
	for i , cfg in ipairs(self.dominateRouteData) do
		for j , dominateRoute in ipairs(cfg.data) do
			if dominateRoute:GetTimeNum() ~= 0 then 
				return true;
			end
		end
	end
	return false;
end

--获取正在扫荡的VO
function DominateRouteModel:GetInMopup()
	for i , cfg in ipairs(self.dominateRouteData) do
		for j , dominateRoute in ipairs(cfg.data) do
			if dominateRoute:GetTimeNum() ~= 0 then 
				return dominateRoute
			end
		end
	end
end

--有没有这个阶段
function DominateRouteModel:GetIsHaveStage(id)
	local stage = toint(id/self.StageConstsNum);
	if not self.dominateRouteData[stage] then
		return false;
	end
	return true;
end

--刷新新的副本
function DominateRouteModel:InitDominateRouteData(num,state,time,id)
	local stage = toint(id/self.StageConstsNum);
	self.dominateRouteData[stage] = {};
	self.dominateRouteData[stage].data = {};
	
	local cfg = t_roadbox[stage];
	if not cfg then 
		print('Error--------------' .. id .. '----ID错误！！！！！！！！！！')
		print('Error--------------' .. id .. '----ID错误！！！！！！！！！！')
		print('Error--------------' .. id .. '----ID错误！！！！！！！！！！')
		print('Error--------------' .. id .. '----ID错误！！！！！！！！！！')
		print('Error--------------' .. id .. '----ID错误！！！！！！！！！！')
		print('Error--------------' .. id .. '----ID错误！！！！！！！！！！')
		return 
	end
	local vo1 = DominateRouteVeilVO:new();
	vo1.id = t_roadbox[stage].id;
	vo1.rewardState = DominateRouteConsts.REWARDNONE;
	vo1.starNum = 0;
	self.dominateRouteData[stage].title = vo1;
	
	local vo = DominateRouteStageVO:new();
	vo.id = id;
	vo.starLevel = 0;
	vo.state = state;
	vo.num = num;
	vo.maxNum = 0;
	vo.timeNum = time;
	self.dominateRouteData[stage].data[id % self.StageConstsNum] = vo;
end

--新副本添加
function DominateRouteModel:addDominateRouteData(id)
	for i , cfg in ipairs(self.dominateRouteData) do
		for j , dominateRoute in ipairs(cfg.data) do
			if dominateRoute:GetStageID() == id then 
				local newCfg = t_zhuzairoad[id + 1];
				if self:OnGetDominateVO(id + 1) then
					return
				end
				if not newCfg then
					return
				else
					local vo = DominateRouteStageVO:new();
					vo.id = newCfg.id;
					vo.starLevel = 0;
					vo.state = DominateRouteConsts.DOMINATEROUTELEISURE;
					vo.num = newCfg.daliyNum;
					vo.maxNum = 0;
					vo.timeNum = 0;
					table.push(cfg.data,vo);
					return
				end
			end
		end
	end
end

--补充因没有挑战过服务器不发的副本  或者因条件满足，但等级不够开启,升级后检测
function DominateRouteModel:OnAddInitData()
	for i , cfg in ipairs(self.dominateRouteData) do
		local data = cfg.data[#cfg.data]
		local level = MainPlayerModel.humanDetailInfo.eaLevel;
		-- if data:GetStageLevel() > 0 then
		if t_zhuzairoad[data:GetStageID() + 1] and level >= t_zhuzairoad[data:GetStageID() + 1].cond then
			self:addDominateRouteData(data:GetStageID())
		end
		-- end
	end
end

-- 获得已经开启章节的总进入次数
function DominateRouteModel:GetOpenRodeTotalNum( )
	local max,min = DominateRouteModel:OnGetMaxDominateData()
	-- print("客户端计算得出最大章节，最小章节",max,min)
	local count = 0
	for i , v in pairs(t_roadbox) do
		if i < max then
			local cfg = DominateRouteModel:OnGetOpenDonminate()[i];
			for _, v in pairs(t_zhuzairoad) do
				local nums = 0;
				if toint(v.id / DominateRouteModel.StageConstsNum) == i then
					nums = nums + 1;
					count = count + v.daliyNum or 0
				end
			end
		elseif i == max then
			local cfg = DominateRouteModel:OnGetOpenDonminate()[max];
			local nums = 0;
			for j, v in pairs(t_zhuzairoad) do
				if toint(v.id / DominateRouteModel.StageConstsNum) == max then
					if j <= max*DominateRouteModel.StageConstsNum + min then
						nums = nums + 1;
						count = count + v.daliyNum or 0
					end
				end
			end
		end
	end
	return count;
end

local isOpen = function(index, selectedID)
	local indexCfg = t_zhuzairoad[index + selectedID * UIDominateRoute.lineNumConsts]
	if not indexCfg then
		return false
	end
	if indexCfg.cond > MainPlayerModel.humanDetailInfo.eaLevel then
		return false
	end
	local cfg = DominateRouteModel:OnGetOpenDonminate()[selectedID]
	if not cfg then
		return false
	end
	if cfg.data[index-1] and cfg.data[index-1].starLevel >0 then
		return true
	end
	if index > 1 then return false end

	local page = selectedID - 1
	if page == 0 then
		return false
	end
	local preCfg = DominateRouteModel:OnGetOpenDonminate()[page]
	if not preCfg then
		return false
	end
	local count = 0
	for i , v in pairs(t_zhuzairoad) do
		if toint(v.id / DominateRouteModel.StageConstsNum) == page then
			count = count + 1
		end
	end
	if preCfg.data[count] and preCfg.data[count].starLevel >0 then
		return true
	end
	return false
end

--返回最大的已开通章节
function DominateRouteModel:OnGetMaxDominateData()
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	local maxBoxIndex = 0;			--已开启的大章节
	local roadIndex = 0;			--大章节中已开启小章节的最大index
	for i , roadbox in ipairs(t_roadbox) do
		if level >= roadbox.level then 
			local count = 0
			for _, v in pairs(t_zhuzairoad) do
				if toint(v.id / DominateRouteModel.StageConstsNum) == i then
					count = count + 1
				end
			end
			for j = 1, count do
				if isOpen(j, i) then
					maxBoxIndex = i
					roadIndex = j
				end
			end
		end
	end
	-- print("maxBoxIndex,roadIndex",maxBoxIndex,roadIndex)
	if maxBoxIndex == 0 then
		return 1, 1
	else
		return maxBoxIndex, roadIndex
	end
	
	--[[
	local dominateRouteData = t_zhuzairoad[maxBoxIndex * self.StageConstsNum + 1];
	if not dominateRouteData then return end
	
	local allData = self:OnGetOpenDonminate();
	
	local maxBoxIndeData = allData[maxBoxIndex];
	if not maxBoxIndeData then
		roadIndex = 1;
		return maxBoxIndex,roadIndex;
	end
	local maxBoxData = maxBoxIndeData.data;
	if not maxBoxData then
		roadIndex = 1;
		return maxBoxIndex,roadIndex;
	end
	if #maxBoxData < 1 then
		roadIndex = 1;
		return maxBoxIndex,roadIndex;
	end
	-- ---------------
	if not maxBoxData then	--如果这个大章节没有数据  默认便是1;
		roadIndex = 1;
		return maxBoxIndex,roadIndex;
	else
		local maxRoadData = maxBoxData[#maxBoxData];
		if not maxRoadData then			--如果大章节中没有data数据  默认为1
			roadIndex = 1;
		else
			if maxRoadData.starLevel < 1 then		--最大章节星级小于1
				local cfg = t_zhuzairoad[maxRoadData.id]; 
				if level >=  cfg.cond then
					roadIndex = maxRoadData.id % self.StageConstsNum;
				else
					roadIndex = maxRoadData.id % self.StageConstsNum - 1;
				end
			else
				local nextDominateRoute = t_zhuzairoad[maxRoadData.id + 1];
				if not nextDominateRoute then		--不小于1  判断下个章节是否存在and下个章节的开启等级是否达到
					roadIndex = #maxBoxData;
				else
					if level >= nextDominateRoute.cond then
						roadIndex = #maxBoxData + 1;
					else
						roadIndex = #maxBoxData;
					end
				end
			end
		end
	end
	-- print(maxBoxIndex,roadIndex)
	-- print('↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑')
	return maxBoxIndex,roadIndex;		--大章节index，小章节index;
	--]]
end

--验证已开通最后的关卡是否已被挑战   根据大章节最后一个关卡的星级个数判断
function DominateRouteModel:OpenNewDominateRoute()
	if not DominateRouteController.DominateRouteIsData then
		return false		--如果没有收到主宰之路的协议  不执行此方法  (角色精力信息未收到)
	end
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	local enterNum = self:OnGetEnterNum();
	if enterNum < 1 then return false end
	local allData = self:OnGetOpenDonminate();
	local num = MainPlayerModel.humanDetailInfo.eaDominJingLi;  --精力
	--先判断第一章第一节
	local minDominate = allData[1]--.data[1];
	if not minDominate then				--没有第一章节任何数据
		return true
	end
	local lieData = minDominate.data;
	if not lieData then					--没有第一章节data小章节的任何数据
		return true
	end
	if #lieData < 1 then 				--小章节信息长度为0
		return true
	end
	if lieData[1].starLevel < 1 and #allData <= 1 then	--第一个小章节的挑战星级为0
		return true 
	end
	--以上所有判断算出当前角色没有任何主宰之路的信息，说明从未挑战过，所以主宰之路闪烁判断为  true
	--遍历所有章的最大一节，星级是否为0
	for i , v in ipairs(allData) do
		local dominateRoute = v.data[#v.data];
		if not dominateRoute then return false;end
		local cfg = t_zhuzairoad[dominateRoute.id];
		if dominateRoute.starLevel > 0 then
			cfg = t_zhuzairoad[dominateRoute.id + 1];
		end
		if cfg and i >= #allData then
			if level >= cfg.cond and num >= cfg.level_energy then
				return true
			end
		end
	end
	--有未开启章节刷新第一节查看等级是否到达开启条件
	for i = 1 , #t_roadbox do
		local data = allData[i];
		if not data then
			local dominateRoute = t_zhuzairoad[self.StageConstsNum * i + 1];
			if level >= dominateRoute.cond and num >= dominateRoute.level_energy then
				return true
			end
		end
	end
	return false
end


--验证已开通最后通关的章节
function DominateRouteModel:GetOpenMaxID()
	if not DominateRouteController.DominateRouteIsData then
		return false		--如果没有收到主宰之路的协议  不执行此方法  (角色精力信息未收到)
	end
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	local allData = self:OnGetOpenDonminate();
	--先判断第一章第一节
	local minDominate = allData[1]--.data[1];
	if not minDominate then				--没有第一章节任何数据
		return 0
	end
	local lieData = minDominate.data;
	if not lieData then					--没有第一章节data小章节的任何数据
		return 0
	end
	if #lieData < 1 then 				--小章节信息长度为0
		return 0
	end
	if lieData[1].starLevel < 1 and #allData <= 1 then	--第一个小章节的挑战星级为0
		return 0 
	end
	--以上所有判断算出当前角色没有任何主宰之路的信息，说明从未挑战过，所以主宰之路闪烁判断为  true
	--遍历所有章的最大一节，星级是否为0
	local maxID;
	for i , v in ipairs(allData) do
		
		for j , k in ipairs(v.data) do
			if k.starLevel > 0 then
				if not maxID then 
					maxID = k.id;
				else
					maxID = k.id > maxID and k.id or maxID;
				end
			end
		end
	end
	return maxID or 0
end
 
-- 是否已经通过第一章的全部关卡
function DominateRouteModel:IsPassMaxOneDomiante( )
	local max,min = self:OnGetMaxDominateData();
	local starLevel = 0
	if self.dominateRouteData[1] then
		if self.dominateRouteData[1].data[11] then
			starLevel = self.dominateRouteData[1].data[11]:GetStageLevel()
		end	
	end
	if max and starLevel > 1 then
		return true
	else
		return false
	end
end