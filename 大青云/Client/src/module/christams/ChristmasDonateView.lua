--[[
	2015年12月18日11:53:44
	wangyanwei
	圣诞兑换活动
]]

_G.UIChristmasDonate = BaseUI:new('UIChristmasDonate');

function UIChristmasDonate:Create()
	self:AddSWF('christmasDonate.swf',true,nil);
end

function UIChristmasDonate:OnLoaded(objSwf)
	objSwf.input1.textChange = function() self:OnContributeChange(); end
	objSwf.input2.textChange = function() self:OnContributeChange(); end
	objSwf.input3.textChange = function() self:OnContributeChange(); end
	objSwf.input4.textChange = function() self:OnContributeChange(); end
	
	objSwf.donatelist.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.donatelist.itemRollOut = function () TipsManager:Hide(); end
	
	for i = 1 , 4 do
		objSwf['btn_' .. i].click = function () self:OnDonateClick(i); end
		objSwf['btn_' .. i].rollOver = function () self:BtnItemRollOver(i); end
		objSwf['btn_' .. i].rollOut = function () TipsManager:Hide(); end
		objSwf['mc_point' .. i].reward.click = function () ChristmasController:ChristmasDonateReward(i) end
		objSwf['mc_point' .. i].reward.rollOver = function () self:ChristmasDonateRewardOver(i) end
		objSwf['mc_point' .. i].reward.rollOut = function () TipsManager:Hide(); end
	end
	
	objSwf.progress.rollOver = function () 
		local value = ChristamsModel:GetDonateValue();
		local cfg = t_consts[177];
		if not cfg then return end
		local maxValue = cfg.val1;
		
		local str = string.format(StrConfig['christmas200'],value,maxValue);
		TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown);
	end
	objSwf.progress.rollOut = function () TipsManager:Hide(); end
end

function UIChristmasDonate:ProBarRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
end

function UIChristmasDonate:BtnItemRollOver(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_chjuanxian[index];
	if not cfg then return end
	local itemNum = toint(objSwf['input' .. index].text);
	if itemNum == 0 then itemNum = 1 end
	local str = string.format(StrConfig['christmas050'],itemNum) .. '<br/>';
	local rewardCfg = split(cfg.reward,'#');
	for i , v in ipairs(rewardCfg) do
		local vo = split(v,',');
		local itemCfg = t_item[toint(vo[1])] or t_equip[toint(vo[1])];
		str = str .. '<font color="#00ff00">' .. itemCfg.name .. '*' .. getNumShow(vo[2] * itemNum) .. '</font>' .. '<br/>'
	end
	TipsManager:ShowBtnTips( str,TipsConsts.Dir_RightDown);
end

function UIChristmasDonate:ChristmasDonateRewardOver(id)
	local cfg = t_chjuanxianreward[id];
	if not cfg then return end
	local itemID = split(cfg.reward,',')[1];
	TipsManager:ShowItemTips(toint(itemID));
end

function UIChristmasDonate:OnDonateClick(id)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_chjuanxian[id];
	if not cfg then return end
	local itemId = cfg.item;
	local maxNum = BagModel:GetItemNumInBag(itemId);
	local donateNum = toint(objSwf['input' .. id].text);
	if maxNum >= donateNum then
		ChristmasController:ChristmasDonate(id,donateNum)
	end
end

function UIChristmasDonate:OnShow()
	ChristmasController:ChristmasDonateInfo();			--请求信息
	self:ShowDonateItem();
	self:ShowProBarPoint();
	
	self:ShowTimeTxt();
	self:DrawChristmasTree();  --绘制模型
	self:ShowItemNum();			--提交默认值
	self:OnContributeChange();
end

function UIChristmasDonate:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.christmasTreeID = nil;
end

--提交默认值
function UIChristmasDonate:ShowItemNum()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if #t_chjuanxian < 4 then
		return
	end
	
	local christmasDonateID_1 = t_chjuanxian[1].item;
	local christmasDonateID_2 = t_chjuanxian[2].item;
	local christmasDonateID_3 = t_chjuanxian[3].item;
	local christmasDonateID_4 = t_chjuanxian[4].item;
	
	local christmasDonate1 = BagModel:GetItemNumInBag(christmasDonateID_1);
	local christmasDonate2 = BagModel:GetItemNumInBag(christmasDonateID_2);
	local christmasDonate3 = BagModel:GetItemNumInBag(christmasDonateID_3);
	local christmasDonate4 = BagModel:GetItemNumInBag(christmasDonateID_4);
	
	objSwf.input1.text = christmasDonate1;
	objSwf.input2.text = christmasDonate2;
	objSwf.input3.text = christmasDonate3;
	objSwf.input4.text = christmasDonate4;
end

--活动结束倒计时
function UIChristmasDonate:ShowTimeTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_activity[ActivityConsts.ChristamTree];
	if not cfg then return end
	
	local nowTime = GetServerTime();
	
	local openList = split(cfg.openDay, '-')
	local startTime = _G.GetTimeByDate(openList[1], openList[2], openList[3], openList[4], openList[5], openList[6])
	if startTime > nowTime then
		objSwf.txt_time.text = StrConfig['christmas003'];
		return
	end
	
	local closeList = split(cfg.closeDay, '-')
	local closeTime = _G.GetTimeByDate(closeList[1], closeList[2], closeList[3], closeList[4], closeList[5], closeList[6])
	
	if closeTime < nowTime then
		objSwf.txt_time.text = StrConfig['christmas002'];
		return
	end
	
	local day,hour,min,sec = CTimeFormat:sec2formatEx( closeTime - nowTime );
	if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end
	if sec < 10 then sec = '0' .. sec; end
	objSwf.txt_time.htmlText = string.format(StrConfig['christmas001'],day,hour,min,sec);
	
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local func = function ()
		nowTime = GetServerTime();
		if closeTime < nowTime then
			objSwf.txt_time.text = StrConfig['christmas002'];
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			return
		end
		local day,hour,min,sec = CTimeFormat:sec2formatEx( closeTime - nowTime );
		if hour < 10 then hour = '0' .. hour; end
		if min < 10 then min = '0' .. min; end
		if sec < 10 then sec = '0' .. sec; end
		objSwf.txt_time.htmlText = string.format(StrConfig['christmas001'],day,hour,min,sec);
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

--右侧奖励阶段位置
function UIChristmasDonate:ShowProBarPoint()
	local objSwf = self.objSwf;
	if not objSwf then return end
	for i = 1 , #t_chjuanxianreward do
		local _height = objSwf.pointBar._height / 100;
		if objSwf['mc_point' .. i] then
			objSwf['mc_point' .. i]._y = objSwf.pointBar._y - _height * t_chjuanxianreward[i].percent;
			objSwf['mc_point' .. i].reward:gotoAndStop(1);
		end
	end
end

function UIChristmasDonate:ShowDonateItem()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	if #t_chjuanxian < 4 then
		return
	end
	local christmasDonateID_1 = t_chjuanxian[1].item;
	local christmasDonateID_2 = t_chjuanxian[2].item;
	local christmasDonateID_3 = t_chjuanxian[3].item;
	local christmasDonateID_4 = t_chjuanxian[4].item;
	
	local christmasDonate1 = BagModel:GetItemNumInBag(christmasDonateID_1);
	local christmasDonate2 = BagModel:GetItemNumInBag(christmasDonateID_2);
	local christmasDonate3 = BagModel:GetItemNumInBag(christmasDonateID_3);
	local christmasDonate4 = BagModel:GetItemNumInBag(christmasDonateID_4);
	
	local str = '' .. christmasDonateID_1 .. ',0#'
				.. christmasDonateID_2 .. ',0#'
				.. christmasDonateID_3 .. ',0#'
				.. christmasDonateID_4 .. ',0';
	
	local donatelist = RewardManager:Parse(str);
	objSwf.donatelist.dataProvider:cleanUp();
	objSwf.donatelist.dataProvider:push(unpack(donatelist));
	objSwf.donatelist:invalidateData();
end

function UIChristmasDonate:OnContributeChange()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	if #t_chjuanxian < 4 then
		return
	end
	
	local christmasDonateID_1 = t_chjuanxian[1].item;
	local christmasDonateID_2 = t_chjuanxian[2].item;
	local christmasDonateID_3 = t_chjuanxian[3].item;
	local christmasDonateID_4 = t_chjuanxian[4].item;
	
	local christmasDonate1 = BagModel:GetItemNumInBag(christmasDonateID_1);
	local christmasDonate2 = BagModel:GetItemNumInBag(christmasDonateID_2);
	local christmasDonate3 = BagModel:GetItemNumInBag(christmasDonateID_3);
	local christmasDonate4 = BagModel:GetItemNumInBag(christmasDonateID_4);
	
	objSwf.input1.text = _G.strtrim(objSwf.input1.text)
	objSwf.input2.text = _G.strtrim(objSwf.input2.text)
	objSwf.input3.text = _G.strtrim(objSwf.input3.text)
	objSwf.input4.text = _G.strtrim(objSwf.input4.text)
	if objSwf.input1.text == "" or toint(objSwf.input1.text) == nil then objSwf.input1.text = "0" end
	if objSwf.input2.text == "" or toint(objSwf.input2.text) == nil then objSwf.input2.text = "0" end
	if objSwf.input3.text == "" or toint(objSwf.input3.text) == nil then objSwf.input3.text = "0" end
	if objSwf.input4.text == "" or toint(objSwf.input4.text) == nil then objSwf.input4.text = "0" end
	
	if toint(objSwf.input1.text) > christmasDonate1 then objSwf.input1.text = christmasDonate1 end
	if toint(objSwf.input2.text) > christmasDonate2 then objSwf.input2.text = christmasDonate2 end
	if toint(objSwf.input3.text) > christmasDonate3 then objSwf.input3.text = christmasDonate3 end
	if toint(objSwf.input4.text) > christmasDonate4 then objSwf.input4.text = christmasDonate4 end
	
	if toint(objSwf.input1.text) <= 0 then objSwf.btn_1.disabled = true else objSwf.btn_1.disabled = false end
	if toint(objSwf.input2.text) <= 0 then objSwf.btn_2.disabled = true else objSwf.btn_2.disabled = false end
	if toint(objSwf.input3.text) <= 0 then objSwf.btn_3.disabled = true else objSwf.btn_3.disabled = false end
	if toint(objSwf.input4.text) <= 0 then objSwf.btn_4.disabled = true else objSwf.btn_4.disabled = false end
	
end

--输入文本失去焦点
function UIChristmasDonate:OnIpSearchFocusOut()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	for i = 1, 4 do
		if objSwf['input'..i] and objSwf['input'..i].focused then
			objSwf['input'..i].focused = false;
		end
	end
end

--右侧宝箱状态
function UIChristmasDonate:ShowRewardState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local rewardList = ChristamsModel:GetDonateList();
	if not rewardList then return end
	for i = 1 , #rewardList do
		if rewardList[i].isReward then
			objSwf['mc_point' .. i].reward:gotoAndStop(2);
		else
			if rewardList[i].isOpen then
				objSwf['mc_point' .. i].reward:gotoAndStop(3);
			else
				objSwf['mc_point' .. i].reward:gotoAndStop(1);
			end
		end
	end
end

--进度条
function UIChristmasDonate:ShowProBarValue()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local value = ChristamsModel:GetDonateValue();
	local cfg = t_consts[177];
	if not cfg then return end
	local maxValue = cfg.val1;
	objSwf.progress.maximum = 100;
	objSwf.progress.value = math.floor(value / maxValue * 100) ;
	objSwf.progress.tfscore.htmlText = string.format('%0.2f%%',value / maxValue * 100);
end

--绘制模型
UIChristmasDonate.christmasTreeID = nil;
function UIChristmasDonate:DrawChristmasTree()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_consts[177];
	if not cfg then return end
	local maxValue = cfg.val1;
	local nowValue = ChristamsModel:GetDonateValue();
	local index = nil;
	for i = 1 , #t_chjuanxianreward do
		local value = math.ceil(t_chjuanxianreward[i].percent /100 * maxValue);
		if nowValue >= value then
			index = i;
		end
	end
	if not index then 
		index = 1;
	else
		index = 1 + index;
	end
	if self.christmasTreeID == index then
		return
	end
	self.christmasTreeID = index;
	local treeID = split(cfg.param,',')[index];
	if not treeID then print('not treeID！！！！！！！！！！')return end
	
	if not self.viewPort then self.viewPort = _Vector2.new(1300,600); end
	if not self.objUIDraw then
		self.objUIDraw = UISceneDraw:new('UIChristmasDonate', objSwf.npcLoader, self.viewPort, true);
	end
	self.objUIDraw:SetUILoader( objSwf.npcLoader )
	
	local src = treeID;
	self.objUIDraw:SetScene(src);
	self.objUIDraw:SetDraw(true);
	
	
	-- self.npcAvatar = nil;
	-- self.npcAvatar = NpcAvatar:NewNpcAvatar(toint(treeID));
	-- self.npcAvatar:InitAvatar();
	-- local drawCfg = self:GetDefaultCfg();
	-- if not self.objUIDraw then 
		-- self.objUIDraw = UIDraw:new("UIChristmasDonate",self.npcAvatar, objSwf.npcLoader,
							-- drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							-- 0x00000000,"UINpc");
	-- else
		-- self.objUIDraw:SetUILoader(objSwf.npcLoader);
		-- self.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		-- self.objUIDraw:SetMesh(self.npcAvatar);
	-- end
	-- local rotation = drawCfg.Rotation or 0;
	-- self.npcAvatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
	-- self.objUIDraw:SetDraw(true);
end

UIChristmasDonate.defaultCfg = {
	EyePos = _Vector3.new(10,40,0),
	LookPos = _Vector3.new(0,0,20),
	VPort = _Vector2.new(1300,600),
	Rotation = 0
};

function UIChristmasDonate:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

--消息处理
function UIChristmasDonate:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if name == NotifyConsts.StageClick then
		self:OnIpSearchFocusOut()
	elseif name == NotifyConsts.StageFocusOut then
		self:OnIpSearchFocusOut()
	elseif name == NotifyConsts.ChristmasDonateUpData then	--圣诞节兑换信息
		self:ShowRewardState();
		self:ShowProBarValue();
		self:ShowTimeTxt();
		self:DrawChristmasTree();  --绘制模型
		self:ShowItemNum();			--提交默认值
		self:OnContributeChange();
	elseif name == NotifyConsts.ChristmasDonateResult then	--圣诞节兑换结果
		self:ShowRewardState();
		self:ShowProBarValue();
		self:ShowItemNum();			--提交默认值
		self:OnContributeChange();
		self:DrawChristmasTree();
	elseif name == NotifyConsts.ChristmasDonateReward then	--圣诞节兑换领奖结果
		self:ShowRewardState();
	end
end

-- 消息监听
function UIChristmasDonate:ListNotificationInterests()
	return {NotifyConsts.StageClick,
			NotifyConsts.StageFocusOut,
			NotifyConsts.ChristmasDonateUpData,
			NotifyConsts.ChristmasDonateResult,
			NotifyConsts.ChristmasDonateReward,
			};
end