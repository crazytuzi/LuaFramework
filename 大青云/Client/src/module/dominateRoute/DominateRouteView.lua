	--[[
	主宰之路UI
	2015年5月26日, PM 02:24:22
	wangyanwei
]]--
_G.UIDominateRoute = BaseUI:new('UIDominateRoute');

function UIDominateRoute:Create()
	self:AddSWF('dominateRoutePanel.swf',true,'center');
end

function UIDominateRoute:OnLoaded(objSwf)
	local cfg = t_consts[69];
	-- 暂时屏蔽一键扫荡
	objSwf.btnQuicklysaodang._visible = false;
	objSwf.btnQuicklysaodang.disabled = true;

	--[[
	objSwf.tf1.htmlText = string.format(StrConfig['dominateRoute0100'],cfg.fval,cfg.val1/60);
	objSwf.tf2.htmlText = StrConfig['dominateRoute0101'];
	--]]
	-- 章节左右选择按钮
	objSwf.btn_Pre.click = function () self:OnPreClickHandler();self:OnLRBtnIsDisabled(); end
	objSwf.btn_Next.click = function () self:OnNextClickHandler();self:OnLRBtnIsDisabled(); end
	-- 章节list
	objSwf.titleBar.list.itemClick = function (e) self:OnItemClick(e) end
	objSwf.titleBar.list.handlerRewardClick = function (e) self:BoxRewardClick(e.item.id); end
	objSwf.titleBar.list.handlerRewardRollOver = function (e) UIDominateRouteTip:Open(e.item.id) end
	objSwf.titleBar.list.handlerRewardRollOut = function (e) 
	if UIDominateRouteTip:IsShow() then 
		UIDominateRouteTip:Hide(); 
		end 
	end
	
	-- 副本item奖励
	-- 副本通关奖励
	objSwf.downListPanel.list.itemRewardRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.downListPanel.list.itemRewardRollOut = function () TipsManager:Hide(); end
	-- 副本3星奖励
	objSwf.downListPanel.list.itemRewardRollOvers = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.downListPanel.list.itemRewardRollOuts = function () TipsManager:Hide(); end

	-- 挑战
	objSwf.downListPanel.list.challengeClick = function (e) self:OnChallengeClick(e) end
	-- 扫荡
	objSwf.downListPanel.list.mopupClick = function (e) self:OnMopupClick(e); end
	-- 购买进入次数
	objSwf.downListPanel.list.buyTimesClick = function (e) self:GoBuyEnterTimes(e); end
	-- 点击获取三星奖励
	objSwf.downListPanel.list.getThrerStarrewardClick = function (e) self:GetThreeStarRewardClick(e); end
	
	objSwf.btn_zhangjiePre.click = function () self:OnZhangJieTweenClick(1); end
	objSwf.btn_zhangjieNext.click = function () self:OnZhangJieTweenClick(2); end
	
	objSwf.btn_close.click = function () self:Hide(); end
	-- 一键扫荡
	objSwf.btnQuicklysaodang.click = function () self:QuicklySaodang(); end
	-- 首次通关所有奖励
	objSwf.firstRewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.firstRewardList.itemRollOut = function () TipsManager:Hide(); end
	
	--滚动条事件
	-- objSwf.btn_buyJingli.click = function () self:OnJingLiClick(); end
	-- objSwf.btn_buyJingli.rollOver = function () self:OnShowJingLiTip(); end
	-- objSwf.btn_buyJingli.rollOut = function () TipsManager:Hide(); end
	
	--一键扫荡
	--[[
	for i = 1 , 5 do
		objSwf.propanel['pro' .. i].tf.text = StrConfig['dominateRoute0300'];
		objSwf.propanel['pro' .. i].btn_rapid.click = function () 
		
			local func = function ()
				DominateRouteController:SendDominateRouteImmediately()
			end
			local str = string.format(StrConfig['dominateRoute0150'],math.ceil((objSwf.propanel['pro' .. i].pro.maximum - objSwf.propanel['pro' .. i].pro.value)/t_consts[71].val2) * t_consts[71].val3);
			UIConfirm:Open(str,func); 
		
		end
	end
	--]]
	-- objSwf.txt_jingliNum.loadComplete = function ()
	-- 	-- objSwf.txt_jingliNum._x = objSwf.jingliPro._x + objSwf.jingliPro._width/2 - objSwf.txt_jingliNum._width/2;
	-- end
	-- objSwf.btn_vip.click = function () UIVip:Show() end
end

function UIDominateRoute:OnShow()
	-- 刷新页码
	self:GetNextPage();
	-- 刷新标题list
	self:OnShowTitleList();
	-- 刷新下面的章节
	self:OnLineList();
	-- 剩余次数
	self:LeftTimes();
	-- self:OnParBarTime();
	-- self:OnScrollBar();
	-- 显示精力值
	-- self:OnShowJingLiHandler();
	-- 显示vip状态
	-- self:ChangeVipButton();
	
	self.lineIndex = -1;
	-- 做个判断,如果不是第一章,做个打开UI后往左滚动你的效果
	if self.firstIsTween then
		self:OnDisabled();
	else
		self:OnTitleIsDisabled();
		self:OnLRBtnIsDisabled();
	end
end

function UIDominateRoute:OnFullShow()
	if self.firstIsTween then
		self:OnZhangJieTweenClick(2);
	end
	self:OnTitleIsDisabled();
	self:OnLRBtnIsDisabled();
end

--做个判断  如果不是第一章  做个打开UI后往左滚动你的效果
function UIDominateRoute:OnDisabled()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_zhangjieNext.disabled = true;
	objSwf.btn_zhangjiePre.disabled = true;
	objSwf.btn_Next.disabled = true;
	objSwf.btn_Pre.disabled = true;
end

-- 左下角剩余次数
function UIDominateRoute:LeftTimes()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local enterNum = DominateRouteModel:OnGetEnterNum();
	local color = "#00ff00"   --默认绿色
	if enterNum < 1 then
		color = "#ff0000"
		objSwf.leftTimes.htmlText = string.format(StrConfig['dominateRoute003'],color,enterNum); -- 今日可挑战次数
	else
		objSwf.leftTimes.htmlText = string.format(StrConfig['dominateRoute003'],color,enterNum); -- 今日可挑战次数
	end
end


--[[
function UIDominateRoute:ChangeVipButton()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local isVip = VipController:IsDiamondVip();
	if not isVip then
		objSwf.btn_vip.htmlLabel = UIStrConfig['dominateRoute102'];
	else
		objSwf.btn_vip.htmlLabel = UIStrConfig['dominateRoute103'];
	end
end

--精力购买点击
function UIDominateRoute:OnJingLiClick()
	local buyNum = DominateRouteModel:GetJingLiBugNum();
	if buyNum >= #t_roadnum then
		FloatManager:AddNormal( StrConfig['dominateRoute0701'] );
		return 
	end
	local jingli = t_roadnum[buyNum + 1].addEnergy;
	local yuanbao = t_roadnum[buyNum + 1].unbindMoney;
	local func = function ()
		DominateRouteController:SendDominateRouteVigor()
	end
	UIConfirm:Open(string.format(StrConfig['dominateRoute0700'],yuanbao,jingli),func);
end

--购买精力tips
function UIDominateRoute:OnShowJingLiTip()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local buyNum = DominateRouteModel:GetJingLiBugNum();
	local maxBuyNum = #t_roadnum ;
	local str = '';
	if buyNum >= maxBuyNum then
		str = str .. StrConfig['dominateRoute0805'];
		TipsManager:ShowBtnTips( str,TipsConsts.Dir_RightDown);
		return;
	end
	str = str .. string.format(StrConfig['dominateRoute0801'],maxBuyNum - buyNum) .. '<br/>';
	local nowBuyNum = t_roadnum[buyNum + 1].unbindMoney;
	local nowBuyJingLi = t_roadnum[buyNum + 1].addEnergy;
	str = str .. string.format(StrConfig['dominateRoute0802'],nowBuyNum) .. '<br/>';
	str = str .. string.format(StrConfig['dominateRoute0803'],nowBuyJingLi) .. '<br/>';
	str = str .. StrConfig['dominateRoute0804'];
	TipsManager:ShowBtnTips( str,TipsConsts.Dir_RightDown);
end
--]]

--listIndex 被左侧盖住的title selectedID 选中title的ID 
-- pass
UIDominateRoute.lineIndex = -1;
UIDominateRoute.firstIsTween = false;	--第一次打开UI的时候是否要缓动一下
function UIDominateRoute:GetNextPage()
	if not DominateRouteModel:OnGetMaxDominateData() then return end
	local maxBoxIndex,roadIndex = DominateRouteModel:OnGetMaxDominateData();
	self:ShowAllFirstReward(maxBoxIndex)
	-- maxBoxIndex 大章节index
	-- roadIndex   小章节index
	self.clickIndex = maxBoxIndex;   --最大通过章节
	local cfg = t_roadbox[self.clickIndex];
	if not cfg then
		self.clickIndex = 1;
		cfg = t_roadbox[self.clickIndex] 
	end
	self.selectedID = cfg.id; 
	if self.clickIndex > self.ItemConsts then   --上面的list滚动跑到指定位置
		self.listIndex = self.clickIndex - self.ItemConsts;
		self.clickIndex = self.ItemConsts;
	end
	
	local newVo = {};
	for i , v in pairs(t_zhuzairoad) do
		if toint(v.id / DominateRouteModel.StageConstsNum) == maxBoxIndex then
			table.push(newVo,v);
		end
	end
	-- local calNum = DominateRouteModel:GetOpenRodeTotalNum()
	-- local enterNums = DominateRouteModel:GetEnterNum( )
	-- local times = calNum > t_consts[71].fval and t_consts[71].fval or calNum
	-- local leftNum = times - enterNums
	-- DominateRouteModel.dominateRouteEnterNum = leftNum
	print("-----大章节index",maxBoxIndex)
	print("-----小章节index",roadIndex)
	-- 没有滚动效果
	if roadIndex < self.lineListNumConsts then
		self.lineListIndex = 0;
		return
	end
	-- self.lineListIndex  小章节的index
	self.lineListIndex = roadIndex - 2;          --toint(math.random() * 5) + 6--
	
	if self.lineListIndex > #newVo - self.lineListNumConsts  then
		self.lineListIndex = #newVo - self.lineListNumConsts;
	end
	-- 未打过
	if self.lineListIndex > 0 and DominateRouteModel:GetDominateRouteIsPass(maxBoxIndex * DominateRouteModel.StageConstsNum + roadIndex) == false then
		self.lineListIndex = self.lineListIndex - 1;
		self.firstIsTween = true;
	end
end

function UIDominateRoute:ChangeLeftTime()
	local calNum = DominateRouteModel:GetOpenRodeTotalNum()
	local enterNums = DominateRouteModel:GetEnterNum( )
	local times = calNum > t_consts[71].fval and t_consts[71].fval or calNum
	local leftNum = times - enterNums
	DominateRouteModel.dominateRouteEnterNum = leftNum
end

-- 显示每章的所有首通奖励
function UIDominateRoute:ShowAllFirstReward(index)
	local objSwf = self.objSwf
	if not objSwf then return end
	local boxAllRewardList = {}
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	for k,v in pairs(t_zhuzairoad) do
		if math.floor(v.id / 10000) == index then
			local vo = {}
			vo.index = v.id
			if #split(v.firstrewardStr,'#') == 4 then
				vo.idNum = split(v.firstrewardStr,'#')[prof]
			else
				vo.idNum = v.firstrewardStr
			end
			table.push(boxAllRewardList,vo)
		end
	end
	table.sort( boxAllRewardList, function(A,B)
		return A.index < B.index
	end )
	
	for k,v in pairs(boxAllRewardList) do
		for i=1,k-1 do
			if toint(boxAllRewardList[k].index) ~= 0 then
				if toint(split(boxAllRewardList[k].idNum,',')[1]) == toint(split(boxAllRewardList[i].idNum,',')[1])  then
					boxAllRewardList[i].index = 0
				end
			end
		end
	end
	local eliminateRewardList = {}   --过滤重复id后的堆集
	for i=1,#boxAllRewardList do
		if boxAllRewardList[i].index ~= 0 then
			local vo = {}
			vo.idNum = boxAllRewardList[i].idNum
			table.push(eliminateRewardList,vo)
		end
	end
	if #eliminateRewardList == 0 then return end
	-- trace(eliminateRewardList)
	-- print("------------------")
	local rewardStr = ''
	for i=1,#eliminateRewardList do
		rewardStr = rewardStr .. (i >= #eliminateRewardList and eliminateRewardList[i].idNum or  eliminateRewardList[i].idNum..'#')
	end
	local rewardList = RewardManager:Parse(rewardStr)
	objSwf.firstRewardList.dataProvider:cleanUp()
	objSwf.firstRewardList.dataProvider:push(unpack(rewardList))
	objSwf.firstRewardList:invalidateData()
end

function UIDominateRoute:OnHide()
	self.lineIndex = -1;
	self.listIndex = 0;
	
	self.lineListIndex = 0;
	self.firstIsTween = false;
	if UIDominateRouteMopup:IsShow() then
		UIDominateRouteMopup:Hide();
	end
	if UIDominateRouteTip:IsShow() then
		UIDominateRouteTip:Hide();
	end
	--是否有组队提示
	TeamUtils:UnRegisterNotice(self:GetName())
	-- 第一个三星奖励领取
	-- local isCan = DominateRouteModel:CheckFirstRewardState()
	-- if not isCan then return end
	-- if not DominateRouteFuncTip:IsShow() then
	-- 	DominateRouteFuncTip:Open()
	-- end
end

--精力值-----------

function UIDominateRoute:OnShowJingLiHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local num = MainPlayerModel.humanDetailInfo.eaDominJingLi;
	local maxJingLi = 0;
	
	-- local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;
	-- local cfg = t_vip[vipLevel];
	
	local vipMax = VipController:GetZhuzaiJinglishangxian()
	local vipValue = VipController:GetZhuzaiJingValue()
	
	local huifuCfg = t_consts[69];
	local huifuJingLi = huifuCfg.fval;
	
	if vipMax <= 0 then
		maxJingLi = t_consts[69].val3;
	else
		maxJingLi = vipMax--cfg.vip_jinglimax;
		-- huifuJingLi = toint((cfg.vip_jingli + 100) * huifuCfg.fval / 10) / 10;
		huifuJingLi = toint((vipValue + 100) * huifuCfg.fval / 10) / 10;
	end
	-- objSwf.jingliPro.maximum = maxJingLi;
	-- objSwf.jingliPro.value = num;
	-- objSwf.txt_jingliNum.num = num .. 'a' .. maxJingLi;
	
	-- objSwf.tf1.htmlText = string.format(StrConfig['dominateRoute0100'],huifuJingLi,huifuCfg.val1/60);
	-- objSwf.tf2.htmlText = string.format(StrConfig['dominateRoute0101'],toint(huifuJingLi / huifuCfg.fval * 100));
end

function UIDominateRoute:OnChangeJingLiProBar()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local num = MainPlayerModel.humanDetailInfo.eaDominJingLi;
	local maxJingLi = 0;
	
	-- local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;
	-- local cfg = t_vip[vipLevel];
	local vipMax = VipController:GetZhuzaiJinglishangxian()
	
	if vipMax <= 0 then
		maxJingLi = t_consts[69].val3;
	else
		maxJingLi = vipMax--cfg.vip_jinglimax;
	end
	-- objSwf.jingliPro.value = num;
	-- objSwf.txt_jingliNum.num = num .. 'a' .. maxJingLi;
end

-- 进入挑战
function UIDominateRoute:OnChallengeClick(e)
	-- local enterNum = DominateRouteModel:OnGetEnterNum();  --进入次数
	-- if enterNum < 1 then
	-- 	FloatManager:AddNormal( StrConfig['dominateRoute0213'] );
	-- 	return 
	-- end
	--[[
	local num = MainPlayerModel.humanDetailInfo.eaDominJingLi;
	if num < 1 then
		FloatManager:AddNormal( StrConfig['dominateRoute0210'] );
		return
	end
	--]]
	-- if TeamModel:IsInTeam() then
	-- 	FloatManager:AddNormal( StrConfig['dominateRoute0211'] );
	-- 	return
	-- end

	if UIDominateRouteMopup:IsShow() then
		UIDominateRouteMopup:Hide();
	end
	self:OnGuideClick()
	local id = e.item.id
	local leftNums = e.item.daliyNum
	if leftNums < 1 then
		FloatManager:AddNormal( StrConfig['dominateRoute0213'] );
		return 
	end
	local enterNum = DominateRouteModel:OnGetEnterNum()
	if enterNum < 1 then
		FloatManager:AddNormal( StrConfig['dominateRoute0207'] );
		return 
	end
	print("---挑战id：",id)
	DominateRouteController:SendDominateRouteChallenge(id)
end

--  单个扫荡
function UIDominateRoute:OnMopupClick(e)
	-- local enterNum = DominateRouteModel:OnGetEnterNum();
	-- if enterNum < 1 then
	-- 	FloatManager:AddNormal( StrConfig['dominateRoute0213'] );
	-- 	return 
	-- end
	--[[
	local num = MainPlayerModel.humanDetailInfo.eaDominJingLi;
	if num < 1 then
		FloatManager:AddNormal( StrConfig['dominateRoute0210'] );
		return
	end
	--]]
	local id = e.item.id
	print("扫荡id：",id)
	local leftNums = e.item.daliyNum
	if leftNums < 1 then
		FloatManager:AddNormal( StrConfig['dominateRoute0213'] );
		return 
	end
	local enterNum = DominateRouteModel:OnGetEnterNum()
	if enterNum < 1 then
		FloatManager:AddNormal( StrConfig['dominateRoute0207'] );
		return 
	end
	UIDominateRouteMopup:Open(id);
end

-- 购买进入次数
function UIDominateRoute:GoBuyEnterTimes(e)
	local id = e.item.id
	-- print("购买进入的次数",id)
end

-- 点击获取三星奖励
function UIDominateRoute:GetThreeStarRewardClick( e )
	local id = e.item.id
	print("------------点击获取三星奖励",id)
	DominateRouteController:ReqDominateRouteBoxReward(id)
end

-- 一键扫荡
function UIDominateRoute:QuicklySaodang( )
	local leftTimes = DominateRouteModel:OnGetEnterNum()
	if leftTimes <= 0 then
		FloatManager:AddNormal(StrConfig['dominateRoute0207'])
		return;
	end
	if DominateRouteModel:GetTimes() == false then
		FloatManager:AddNormal(StrConfig['dominateRoute0208'])
		return;
	end
	local str = DominateRouteModel:GetMopupTaotalReward( )
	if not str then
		Debug("error:数据错误,reason:未找到相关数据") 
		return 
	end
	UIDominateRouteQuickMopup:Open(str)
end


--宝箱点击
function UIDominateRoute:BoxRewardClick(index)
	if UIDominateRouteTip:IsShow() then UIDominateRouteTip:Hide(); end
	local boxCfg = DominateRouteModel:GetDominateRouteTitleInfo(index);
	if not boxCfg then print('该阶段未开启'..index) return end
	local cfg = t_roadbox[boxCfg:GetVeilId()];
	if boxCfg:GetStarNum() >= cfg.openStar then
		DominateRouteController:SendDominateRouteBoxReward(index)
		return
	end
	FloatManager:AddNormal( StrConfig['dominateRoute0200'] );
end

-- list点击
UIDominateRoute.clickIndex = 1;
UIDominateRoute.selectedID = 1;
function UIDominateRoute:OnItemClick(e)
	self.clickIndex = e.index;
	self.selectedID = e.item.id;
	self.lineListIndex = 0;
	self:OnLineList();   --刷新下面的章节
	-- self:OnScrollBar();
	self:OnLRBtnIsDisabled();
	self:OnTitleIsDisabled();
	self:ShowAllFirstReward(e.index)
end

-- 下面的章节--节选list
function UIDominateRoute:OnLineList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.downListPanel.list.dataProvider:cleanUp();
	local allData = self:OnGetAllData();  --获得下面小章节的数据
	objSwf.downListPanel.list.dataProvider:push( unpack(allData) );
	objSwf.downListPanel.list:invalidateData();
	
end

--章节切换tween  state 1 左   2 右
UIDominateRoute.zhangjieTweening = false;
UIDominateRoute.ZhangjieWidthConsts = 296;
function UIDominateRoute:OnZhangJieTweenClick(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.zhangjieTweening then return end
	if state == 1 then
		if self.lineListIndex < 1 then
			return
		end
		self.zhangjieTweening = true;
		self.lineListIndex = self.lineListIndex - 1;
		objSwf.downListPanel._x = objSwf.downListPanel._x - self.ZhangjieWidthConsts;
		-- objSwf.propanel._x = objSwf.propanel._x - self.ZhangjieWidthConsts;
		self:OnLineList();
		-- self:OnScrollBar();
		-- Tween:To(objSwf.propanel , 0.5 ,{_x = objSwf.propanel._x + self.ZhangjieWidthConsts},{onComplete = function ()
		-- end
		-- },false)
		Tween:To(objSwf.downListPanel , 0.5,{_x = objSwf.downListPanel._x + self.ZhangjieWidthConsts},{onComplete = function ()
		self:OnZJTweenComplete();
		end
		},false);
	elseif state == 2 then
		local vo = {};
		for i , v in pairs(t_zhuzairoad) do
			if toint(v.id / self.lineNumConsts) == self.selectedID then
				table.push(vo,v);
			end
		end
		table.sort(vo,function (A,B)
			return A.id < B.id;
		end)
		if vo[#vo].id - self.lineListSelectID < self.lineListNumConsts + 1 then
			return
		end
		self.zhangjieTweening = true;
		self.lineListIndex = self.lineListIndex + 1;
		objSwf.downListPanel._x = objSwf.downListPanel._x + self.ZhangjieWidthConsts;
		-- objSwf.propanel._x = objSwf.propanel._x + self.ZhangjieWidthConsts;
		self:OnLineList();
		-- self:OnScrollBar();
		-- Tween:To(objSwf.propanel , 0.5 ,{_x = objSwf.propanel._x - self.ZhangjieWidthConsts},{onComplete = function ()
		-- end
		-- },false)
		Tween:To(objSwf.downListPanel , 0.5,{_x = objSwf.downListPanel._x - self.ZhangjieWidthConsts},{onComplete = function ()
		self:OnZJTweenComplete();
		end
		},false);
	end
end

--章节左右按钮置灰判断
function UIDominateRoute:OnLRBtnIsDisabled()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local vo = {};
	for i , v in pairs(t_zhuzairoad) do
		if toint(v.id / self.lineNumConsts) == self.selectedID then
			table.push(vo,v);
		end
	end
	table.sort(vo,function (A,B)
		return A.id < B.id;
	end)
	objSwf.btn_zhangjieNext.disabled = vo[#vo].id - self.lineListSelectID < self.lineListNumConsts + 1;
	objSwf.btn_zhangjiePre.disabled = self.lineListIndex < 1;
end

function UIDominateRoute:OnZJTweenComplete()
	self.zhangjieTweening = false
	self:OnLRBtnIsDisabled();
end

local isOpen = function(index)
	local indexCfg = t_zhuzairoad[index + UIDominateRoute.selectedID * UIDominateRoute.lineNumConsts]
	if not indexCfg then
		return false
	end
	if indexCfg.cond > MainPlayerModel.humanDetailInfo.eaLevel then
		return false
	end
	local cfg = DominateRouteModel:OnGetOpenDonminate()[UIDominateRoute.selectedID]
	if not cfg then
		return false
	end
	if cfg.data[index-1] and cfg.data[index-1].starLevel >0 then
		return true
	end
	if cfg.data[index-1] then
		return false
	end
	local page = UIDominateRoute.selectedID - 1
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

-- 获取所有数据
UIDominateRoute.lineListIndex = 0;
UIDominateRoute.lineListNumConsts = 4;
UIDominateRoute.lineListSelectID = 0;
UIDominateRoute.lineNumConsts = 10000;
function UIDominateRoute:OnGetAllData()
	local list = {}
	local vo;
	local newVo = {};
	local index = self.lineListIndex ;   --第几个小章节
	-- self.selectedID   选中的大章节index
	-- self.lineListSelectID   小面小章节的id  4+2*10000
	self.lineListSelectID = index + self.selectedID * self.lineNumConsts;
	for i , v in pairs(t_zhuzairoad) do
		if toint(v.id / DominateRouteModel.StageConstsNum) == self.selectedID then
			table.push(newVo,v);
		end
	end
	-- newVo   每个大章节对应的小章节数据
	table.sort(newVo,function(A,B)
		return A.id < B.id
	end)
	
	-- 开通的关卡
	-- DominateRouteModel:OnGetOpenDonminate()  已经开通的关卡
	local cfg = DominateRouteModel:OnGetOpenDonminate()[self.selectedID];
	
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	-- 是否有正在扫荡的副本
	-- local mopup = DominateRouteModel:OnGetIsMopup();
	
	--获取最大章节的ID
	-- maxBoxIndex 已开启的大章节
	-- roadIndex 大章节中已开启小章节的最大index
	local maxBoxIndex,roadIndex = DominateRouteModel:OnGetMaxDominateData();
	local maxID = maxBoxIndex * self.lineNumConsts + roadIndex;
	--精力值
	-- local num = MainPlayerModel.humanDetailInfo.eaDominJingLi;

	for i = 1, self.lineListNumConsts + 2 do
		vo = {};
		local rewardList = '';
		local firstRewardList = '';
		local prof = MainPlayerModel.humanDetailInfo.eaProf
		if newVo[index] then
			vo.id = newVo[index].id;
			if vo.id == maxID then
				vo.isMaxID = true;   --是否达到最大这个大章节的最大小章节id
			end
			-- 下面四行已经废除
			vo.titleInfo = newVo[index].titleInfo;  --原著信息
			local strVo = split(vo.titleInfo,'#');
			vo.zhangjie = strVo[1];       --章节
			vo.zhangjiename = strVo[2];   --章节名字
			-- 小章节title
			vo.title = ResUtil:GetMuBGIcon(t_zhuzairoad[newVo[index].id].roundName);
			-- 单个小章节副本进入次数
			-- local enterNum = DominateRouteModel:OnGetEnterNum();
			local threeStarRewardState = 0;  --未领取
			if not cfg then
				vo.openState = false;
				vo.bgUrl = ResUtil:GetMuBGIcon(t_zhuzairoad[vo.id].titleUrl);  --显示灰色图片 (现在读取正常图片)
				-- vo.needStr = t_zhuzairoad[vo.id].level_energy;
				-- vo.daliyStr = t_zhuzairoad[newVo[index].id].daliyNum;
				rewardList = t_zhuzairoad[newVo[index].id].rewardStr;       --首通奖励
				local size = split(t_zhuzairoad[newVo[index].id].firstrewardStr,'#')
				if #size == 1 then      --通用装备
					firstRewardList = size[1]
				elseif #size == 4 then  --根据职业给予相应装备
					firstRewardList = size[prof]
				end
				-- firstRewardList = t_zhuzairoad[newVo[index].id].firstrewardStr;  --3星奖励
				vo.levelOpen = string.format(StrConfig['dominateRoute006'],t_zhuzairoad[newVo[index].id].cond);
				vo.daliyNum = toint(t_zhuzairoad[newVo[index].id].daliyNum)
			else
				-- 之前规则：玩家等级只要大于对应小章节的开启等级，就开启目前改章节
				-- 现在规则：根据小章节星星数量是否不等于0来判断是否开启小章节
				-- trace(cfg.data[index])
				if cfg.data[index] then  --cfg.data[index] and level >= t_zhuzairoad[newVo[index].id].cond
					if cfg.data[index].id == 10001 or isOpen(index) then
						-- vo.isMaxID = true;   --是否达到最大这个大章节的最大小章节id
						vo.openState = true;
						vo.bgUrl = ResUtil:GetMuBGIcon(t_zhuzairoad[vo.id].titleUrl);
						--3星数量
						vo.starLevel = cfg.data[index]:GetStageLevel();   
						rewardList = t_zhuzairoad[newVo[index].id].rewardStr;
						local size = split(t_zhuzairoad[newVo[index].id].firstrewardStr,'#')
						if #size == 1 then
							firstRewardList = size[1]
						elseif #size == 4 then
							firstRewardList = size[prof]
						end
						-- firstRewardList = t_zhuzairoad[newVo[index].id].firstrewardStr;  --3星奖励
						-- 3星奖励领取状态
						vo.state = cfg.data[index]:GetStageState();
						vo.roadId = cfg.data[index].id;
						-- 每日剩余次数
						vo.daliyNum = cfg.data[index]:GetDaliyNum();
					else
						vo.openState = false;
						vo.bgUrl = ResUtil:GetMuBGIcon(t_zhuzairoad[vo.id].titleUrl);  --显示灰色图片
						rewardList = t_zhuzairoad[newVo[index].id].rewardStr;
						local size = split(t_zhuzairoad[newVo[index].id].firstrewardStr,'#')
						if #size == 1 then
							firstRewardList = size[1]
						elseif #size == 4 then
							firstRewardList = size[prof]
						end
						-- firstRewardList = t_zhuzairoad[newVo[index].id].firstrewardStr;  --3星奖励
						vo.levelOpen = string.format(StrConfig['dominateRoute006'],t_zhuzairoad[newVo[index].id].cond);
						vo.daliyNum = toint(t_zhuzairoad[newVo[index].id].daliyNum)

						-- 3星奖励领取状态
						-- vo.state = true
					end
				else
					vo.openState = false;
					vo.bgUrl = ResUtil:GetMuBGIcon(t_zhuzairoad[vo.id].titleUrl);  --显示灰色图片
					rewardList = t_zhuzairoad[newVo[index].id].rewardStr;
					local size = split(t_zhuzairoad[newVo[index].id].firstrewardStr,'#')
					if #size == 1 then
						firstRewardList = size[1]
					elseif #size == 4 then
						firstRewardList = size[prof]
					end
					-- firstRewardList = t_zhuzairoad[newVo[index].id].firstrewardStr;  --3星奖励
					vo.levelOpen = string.format(StrConfig['dominateRoute006'],t_zhuzairoad[newVo[index].id].cond);
					vo.daliyNum = toint(t_zhuzairoad[newVo[index].id].daliyNum)
				end
			end
			--[[
			if t_zhuzairoad[vo.id].level_energy <= num then
				vo.needStr = t_zhuzairoad[vo.id].level_energy;
			else
				vo.needStr = string.format(StrConfig['dominateRoute004'],t_zhuzairoad[vo.id].level_energy);
			end
			--]]
			-- 单个章节进入次数 
			local color = "#00ff00"   --默认绿色
			if vo.daliyNum < 1 then
				color = "#ff0000"
				vo.daliyStr = string.format(StrConfig['dominateRoute003'],color,vo.daliyNum); -- 今日可挑战次数
			else
				vo.daliyStr = string.format(StrConfig['dominateRoute003'],color,vo.daliyNum); -- 今日可挑战次数
			end
			vo.mopup = false --mopup;   --取消挑战中.....
			vo.openLevel = t_zhuzairoad[newVo[index].id].cond
			vo.myLevel = level;
		end
		index = index + 1;
		local majorStr = UIData.encode(vo);
		local rewardStr = table.concat(RewardManager:Parse(rewardList), "*");
		local firstRewardStr = table.concat(RewardManager:Parse(firstRewardList), "*");
		local finalStr = majorStr .. "*" .. rewardStr .. "&" .. firstRewardStr;
		table.push(list, finalStr);
	end
	return list
end
 
-- titleList数据  大章节数据
UIDominateRoute.listIndex = 0;
UIDominateRoute.ItemConsts = 4;   --UI上显示几个titleItem
function UIDominateRoute:OnShowTitleList(indexs)
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.titleBar.list.dataProvider:cleanUp();
	local index = self.listIndex ;
	-- if index >= #t_roadbox - self.ItemConsts then
	-- 	index = #t_roadbox - self.ItemConsts;
	-- end
	
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	
	local data = DominateRouteModel:OnGetOpenDonminate();
	for j = 1 , self.ItemConsts + 2 do
		local vo = {};
		for i , v in ipairs(t_roadbox) do
			if i == index then
				vo.titleIndex = i;
				vo.id = v.id;
				vo.mu = v.titleIcon;
				vo.name = v.picName;
				if myLevel < v.level then
					vo.level = string.format(StrConfig['dominateRoute0105'],v.level)
					vo.bgUrl = ResUtil:GetMuBGIcon(v.picUrl,true);
				else
					vo.level = string.format(StrConfig['dominateRoute0106'],v.level)
					vo.bgUrl = ResUtil:GetMuBGIcon(v.picUrl);
				end
				break
			end
		end	
		index = index + 1;
		objSwf.titleBar.list.dataProvider:push(UIData.encode(vo));
	end
	objSwf.titleBar.list:invalidateData();
	if indexs then
		if indexs == 1 then
			if objSwf.titleBar.list.selectedIndex >= self.ItemConsts then
				objSwf.titleBar.list.selectedIndex = self.ItemConsts;
				self.selectedID = self.selectedID - 1;
				self.lineListIndex = 0;
				self:OnLineList();
			else
				self.clickIndex = self.clickIndex + 1;
				objSwf.titleBar.list.selectedIndex = self.clickIndex;
			end
		else
			if objSwf.titleBar.list.selectedIndex <= 1 then
				objSwf.titleBar.list.selectedIndex = 1;
				self.selectedID = self.selectedID + 1;
				self.lineListIndex = 0;
				self:OnLineList();
			else
				self.clickIndex = self.clickIndex - 1;
				objSwf.titleBar.list.selectedIndex = self.clickIndex;
			end
		end
	else
		objSwf.titleBar.list.selectedIndex = self.clickIndex;
	end
end

-- 不滚动的情况下切换list
function UIDominateRoute:OnChangeTitleList(state)
	local objSwf = self.objSwf;
	if state == 1 then
		self.clickIndex = self.clickIndex - 1;
		self.selectedID = self.selectedID - 1;
		objSwf.titleBar.list.selectedIndex = self.clickIndex;
	else
		self.clickIndex = self.clickIndex + 1;
		self.selectedID = self.selectedID + 1;
		objSwf.titleBar.list.selectedIndex = self.clickIndex;
	end
	self.lineListIndex = 0;
	self:ShowAllFirstReward(self.selectedID)
	self:OnLineList();
end

-- 上一页
UIDominateRoute.tweening = false;
function UIDominateRoute:OnPreClickHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.tweening then
		return 
	end
	if self.listIndex < 1 and objSwf.titleBar.list.selectedIndex > 1 then
		self:OnChangeTitleList(1);
		self:OnTitleIsDisabled();
		return
	end
	if self.listIndex < 1 then
		return
	end
	self.listIndex = self.listIndex - 1;
	self.tweening = true;
	self:OnTweenHandler(1);
end

-- 下一页
function UIDominateRoute:OnNextClickHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.tweening then
		return 
	end
	if self.listIndex > #t_roadbox - (self.ItemConsts + 1) and objSwf.titleBar.list.selectedIndex < self.ItemConsts then
		self:OnChangeTitleList(2);
		self:OnTitleIsDisabled();
		return
	end
	if self.listIndex > #t_roadbox - (self.ItemConsts + 1) then
		return
	end
	self.tweening = true;
	self.listIndex = self.listIndex + 1;
	self:OnTweenHandler(2);
end

-- 滚动
UIDominateRoute.ItemWidthConsts = 200;			--滚动宽度
function UIDominateRoute:OnTweenHandler(tweenState)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if tweenState == 1 then
		objSwf.titleBar._x = objSwf.titleBar._x - self.ItemWidthConsts;
		self:OnShowTitleList(1);
		Tween:To(objSwf.titleBar , 0.5,{_x = objSwf.titleBar._x + self.ItemWidthConsts},{onComplete = function ()
		self:OnTweenComplete();
		end
		},false);
	else
		objSwf.titleBar._x = objSwf.titleBar._x + self.ItemWidthConsts;
		self:OnShowTitleList(2);
		Tween:To(objSwf.titleBar , 0.5,{_x = objSwf.titleBar._x - self.ItemWidthConsts},{onComplete = function ()
		self:OnTweenComplete();
		end
		},false);
	end
end

--滚动条事件
function UIDominateRoute:OnScrollBar()
	local objSwf = self.objSwf;
	if not objSwf then return end
	return;
	--[[
	-- local mopup = DominateRouteModel:OnGetIsMopup();
	-- if not mopup then
	-- 	objSwf.propanel._visible = false;
	-- 	return
	-- end
	-- local data = DominateRouteModel:OnGetOpenDonminate()[self.selectedID];
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	-- if not data then
	-- 	objSwf.propanel._visible = false;
	-- 	return
	-- end
	-- objSwf.propanel._visible = true;
	local pos = self.lineListSelectID % self.lineNumConsts - 1
	for i = 1 , 5 do
		if not data.data[i + pos] then
			objSwf.propanel['pro' .. i]._visible = false;
		else
			local zhuzaiCfg = t_zhuzairoad[data.data[i + pos].id];
			if not zhuzaiCfg then print('Error~~~~zhuzaiRodeID') return end
			if level >= zhuzaiCfg.cond then			
				objSwf.propanel['pro' .. i]._visible = true;
				objSwf.propanel['pro' .. i].btn_rapid.visible = false;
				objSwf.propanel['pro' .. i].tf._visible = true;
				if data.data[i + pos]:GetStageState() == DominateRouteConsts.DOMINATEROUTEMOPUP then
					objSwf.propanel['pro' .. i].btn_rapid.visible = true;
					objSwf.propanel['pro' .. i].tf._visible = false;
				end
			else
				objSwf.propanel['pro' .. i]._visible = false;
			end
		end
	end
	--]]
end

--进度条进度设置
function UIDominateRoute:OnParBarTime()
	return;
	--[[
	local mopup = DominateRouteModel:OnGetIsMopup();
	local objSwf = self.objSwf;
	if not mopup then 
		objSwf.propanel._visible = false;
		return
	end
	objSwf.propanel._visible = true;
	local vo = DominateRouteModel:GetInMopup();
	for i = 1 , 5 do
		objSwf.propanel['pro' .. i].pro.maximum = t_zhuzairoad[vo:GetStageID()].sweep_limit * vo:GetMaxNum();
		objSwf.propanel['pro' .. i].pro.value = objSwf.propanel['pro' .. i].pro.maximum - vo:GetTimeNum();
		local min,sec = self:OnBackNowLeaveTime(objSwf.propanel['pro' .. i].pro.maximum - objSwf.propanel['pro' .. i].pro.value);
		objSwf.propanel['pro' .. i].txt_pro.text = string.format(StrConfig['dominateRoute0500'],min,sec);
	end
	--]]
end

--时间刷新
function UIDominateRoute:OnTimeChangeTxt(num)
	--[[
	local objSwf = self.objSwf;
	for i = 1 , 5 do
		objSwf.propanel['pro' .. i].pro.value = num;
		local min,sec = self:OnBackNowLeaveTime(objSwf.propanel['pro' .. i].pro.maximum - num);
		objSwf.propanel['pro' .. i].txt_pro.text = string.format(StrConfig['dominateRoute0500'],min,sec);
	end
	--]]
end

--时间换算
function UIDominateRoute:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	return min,sec
end

-- 滚动完执行的方法
function UIDominateRoute:OnTweenComplete()
	self.tweening = false;
	self:OnTitleIsDisabled();
end

--title左右标签是否disabled
function UIDominateRoute:OnTitleIsDisabled()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_Pre.disabled = self.selectedID <= 1;
	objSwf.btn_Next.disabled = self.selectedID >= #t_roadbox --- (self.ItemConsts + 1);
end

function UIDominateRoute:GetWidth()
	return 1146
end

function UIDominateRoute:GetHeight()
	return 687
end

function UIDominateRoute:IsTween()
	return true;
end

function UIDominateRoute:GetPanelType()
	return 1;
end

function UIDominateRoute:IsShowSound()
	return true;
end

function UIDominateRoute:IsShowLoading()
	return true;
end

function UIDominateRoute:HandleNotification(name,body)
	if name == NotifyConsts.DominateRouteMopupUpData then
		--扫荡
		--刷新list
		-- self:GetNextPage();
		self:LeftTimes();
		self:OnLineList();
		self:OnTitleIsDisabled();
		self:OnLRBtnIsDisabled();
		--设置进度条
		-- self:OnParBarTime();
		-- self:OnScrollBar();
	elseif name == NotifyConsts.DominateQuicklySaodangBackUpData then
		self:OnLineList();
		-- 刷新进入次数
		self:LeftTimes();
	elseif name == NotifyConsts.DominateRouteUpData then
		--副本刷新
		self:OnLineList();
		self:OnShowTitleList();
		-- 刷新进入次数
		self:LeftTimes();
		-- self:OnParBarTime();
		-- self:OnScrollBar();
	elseif name == NotifyConsts.DominateRouteTimeUpData then
		--时间刷新
		-- self:OnTimeChangeTxt(body.num);
	elseif name == NotifyConsts.DominateRouteBoxUpData then
		--副本刷新
		self:OnLineList();
	elseif name == NotifyConsts.DominateRouteAddJingLi then
		self:OnChangeJingLiProBar();
		self:OnLineList();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			-- self:ChangeLeftTime();
			self:GetNextPage();
			self:OnShowTitleList();
			self:OnLineList();
			self:LeftTimes();
		end
	end
end

function UIDominateRoute:ListNotificationInterests()
	return {
		NotifyConsts.DominateRouteMopupUpData,NotifyConsts.DominateRouteUpData,
		NotifyConsts.DominateRouteTimeUpData,NotifyConsts.DominateRouteBoxUpData,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.DominateQuicklySaodangBackUpData,NotifyConsts.DominateRouteAddJingLi,
	}
end

----------------------------------  点击任务接口 ----------------------------------------

function UIDominateRoute:OnGuideClick()
	QuestController:TryQuestClick( QuestConsts.DominateRoadClick1 )
	QuestController:TryQuestClick( QuestConsts.DominateRoadClick2 )
end

------------------------------------------------------------------------------------------
--------------------------------引导相关接口-----------------------------------------
function UIDominateRoute:GetChallengeBtn(id)
	local index = id % 10000;
	if not self:IsShow() then return; end
	local uiItem = self.objSwf.downListPanel.list:getRendererAt(index);
	if not uiItem then return nil; end
	return uiItem.btn_challenge;
end