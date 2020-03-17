--[[
道具合成界面面板
zhangshuhui
2014年12月27日15:20:20
]]

_G.UIToolHeCheng = BaseUI:new("UIToolHeCheng");

UIToolHeCheng.tabButton = {};
UIToolHeCheng.tfcountlist = {};
UIToolHeCheng.materialmax = 5--材料数量

UIToolHeCheng.nextone = 0;
UIToolHeCheng.nexttwo = 0;

--当前道具id
UIToolHeCheng.selid = 0;

--打开特定道具id
UIToolHeCheng.openid = 0;
--打开类型 1合成，2分解
UIToolHeCheng.opentype = 1;

--打开的节点list
UIToolHeCheng.openlist = {};

function UIToolHeCheng:Create()
	self:AddSWF("hechengmainPanel.swf", true, "center");
end

function UIToolHeCheng:OnLoaded(objSwf, name)
	objSwf.list.itemClick1 = function(e) self:OnListItemClick(e); end
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	objSwf.btnhecheng.click = function() self:OnBtnHeChengClick(); end;
	objSwf.btnfenjie.click = function() self:OnBtnFenJieClick(); end;
	objSwf.btnMax.click    = function() self:OnBtnMaxClick(); end
	objSwf.ns.change = function(e) self:OnNsChange(e); end
	--
	--self.tabButton[HeChengConsts.TABHECHENG] = objSwf.tabhecheng;
	--self.tabButton[HeChengConsts.TABFENJIE] = objSwf.tabfenjie;
	--objSwf.tabfenjie.visible = false;
	--for name,btn in pairs(self.tabButton) do
		--btn.click = function() self:OnTabButtonClick(name); end;
	--end

	--材料数量
	self.tfcountlist = {};
	for i=1,self.materialmax do
		self.tfcountlist[i] = objSwf["tfcount"..i];
	end

	RewardManager:RegisterListTips( objSwf.toolList );

	--道具tip
	objSwf.toolitem.rollOver = function(e) self:OnItemRollOver(e); end
	objSwf.toolitem.rollOut  = function() TipsManager:Hide();  end

	objSwf.BG.hitTestDisable = true;
	-- objSwf.fenjiepanel.hitTestDisable = true;
end

function UIToolHeCheng:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
	for k,_ in pairs(self.tfcountlist) do
		self.tfcountlist[k] = nil;
	end
end

-- function UIToolHeCheng:GetWidth()
	-- return 790;
-- end

function UIToolHeCheng:GetWidth()
	return 1146;
end

function UIToolHeCheng:GetHeight()
	return 687;
end

function UIToolHeCheng:IsTween()
	return true;
end

function UIToolHeCheng:GetPanelType()
	return 1;
end

function UIToolHeCheng:IsShowLoading()
	return true;
end

function UIToolHeCheng:IsShowSound()
	return true;
end

function UIToolHeCheng:BeforeTween()
	local func = FuncManager:GetFunc(FuncConsts.Bag);
	if not func then return; end
	self.tweenStartPos = func:GetBtnGlobalPos();
end

---------------------------------消息处理------------------------------------
--处理消息
function UIToolHeCheng:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.ToolHeChengInfo then
		self:RefreshToolInfo(body);
		SoundManager:PlaySfx(2043);
	elseif name == NotifyConsts.BagItemNumChange then
		self:RefreshToolList();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaBindGold then
			self:UpdateHeChengMoney()			
		end
	end
end

--监听消息
function UIToolHeCheng:ListNotificationInterests()
	return {NotifyConsts.ToolHeChengInfo, NotifyConsts.BagItemNumChange,NotifyConsts.PlayerAttrChange};
end

function UIToolHeCheng:IsTween()
	return true;
end

function UIToolHeCheng:GetPanelType()
	return 0;
end

function UIToolHeCheng:ESCHide()
	return true;
end

function UIToolHeCheng:IsShowLoading()
	return true;
end

function UIToolHeCheng:IsShowSound()
	return true;
end

function UIToolHeCheng:BeforeTween()
	local func = FuncManager:GetFunc(FuncConsts.Bag);
	if not func then return; end
	self.tweenStartPos = func:GetBtnGlobalPos();
end

function UIToolHeCheng:OnShow()
	if #self.args > 0 then
		local id = self.args[1];
		--todo
		--显示合成还是分解
		self.opentype = 1;
		--显示道具id
		self.openid = id;
	end
	-- 暂时默认显示合成
	self:OnTabButtonClick(HeChengConsts.TABHECHENG);  --默认显示合成
end

function UIToolHeCheng:Open(id)
	local isHaveId = self:CheckIDInitemcompound(id)
	self.openid = id
	if isHaveId == false then
		self:Hide()
		return
	end
	if self:IsShow() then
		self:OnShow()
	else
		self:Show()
	end
end

-- 检测itemid是否存在合成功能中，如果不存在不打开界面
function UIToolHeCheng:CheckIDInitemcompound( id )
	local isHave = false
	for k,v in pairs(t_itemcompound) do
		if v.id  == id then
			isHave = true
		end
	end
	return isHave
end


--清空数据
function UIToolHeCheng:ClearData()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	self.nextone = 1;
	self.nexttwo = 1;
	self.selid = 0;

	self.openlist = {};
	if self.openid > 0 then
		if self.opentype == 1 then
			self.openlist = HeChengUtil:GetHeChengTreeById(t_itemcompound,self.openid)
		elseif self.opentype == 2 then
			self.openlist = HeChengUtil:GetHeChengTreeById(t_itemresolve,self.openid)
		end
	else
		local vo1 = {};
		vo1.label1 = 1;
		table.push(self.openlist, vo1);
		local vo2 = {};
		vo2.label1 = 1;
		vo2.label2 = 1;
		table.push(self.openlist, vo2);
		local vo3 = {};
		vo3.label1 = 1;
		vo3.label2 = 1;
		vo3.label3 = 1;
		table.push(self.openlist, vo3);
		local vo4 = {};
		vo4.label1 = 1;
		vo4.label2 = 1;
		vo4.label3 = 1;
		vo4.label4 = 1;
		table.push(self.openlist, vo4);
	end

	objSwf.toolList.dataProvider:cleanUp();
	objSwf.toolList:invalidateData();

	for i=1,self.materialmax do
		self.tfcountlist[i].htmlText = "";
	end
end

--点击标签
function UIToolHeCheng:OnTabButtonClick(name)
	--if not self.tabButton[name] then
	--	return;
	--end
	self:ClearData()

--	self.tabButton[name].selected = true;

	--分解
	if name == HeChengConsts.TABFENJIE then
		self:RefreshFenJieList();

	--合成
	else
		self:RefreshHeChengList();
	end
end

--点击关闭按钮
function UIToolHeCheng:OnBtnCloseClick()
	self:Hide();
end

--道具tip
function UIToolHeCheng:OnItemRollOver(e)
	local target = e.target;
	if target.data and target.data.id then
		TipsManager:ShowItemTips( target.data.id);
	end
end

UIToolHeCheng.lastSendTime = 0

--确定合成
function UIToolHeCheng:OnBtnHeChengClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local num = self.objSwf.ns.value or 0;

	if GetCurTime() - self.lastSendTime < 200 then
		return;
	end
	self.lastSendTime = GetCurTime();

	if num == 0 then
		FloatManager:AddNormal( StrConfig['hecheng16'], objSwf.btnhecheng );
		SoundManager:PlaySfx(2043);
		return;
	end

	--银两不足
	local itemvo = t_itemcompound[self.selid];
	if itemvo then
		--判断条件
		local consummeney = itemvo.consume_money * num;
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaBindGold + playerinfo.eaUnBindGold < consummeney then
			FloatManager:AddNormal( StrConfig['hecheng19'], objSwf.btnhecheng );
			SoundManager:PlaySfx(2043);
			return;
		end
	end

	HeChengController:ReqToolHeCheng(self.selid,1,num)
end

--确定分解
function UIToolHeCheng:OnBtnFenJieClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local num = self.objSwf.ns.value or 0;
	if num == 0 then
		FloatManager:AddNormal( StrConfig['hecheng17'], objSwf.btnfenjie );
		return;
	end

	--银两不足
	local itemvo = t_itemresolve[self.selid];
	if itemvo then
		--判断条件
		local consummeney = itemvo.consume_money * num;
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaBindGold + playerinfo.eaUnBindGold < consummeney then
			FloatManager:AddNormal( StrConfig['hecheng19'], objSwf.btnfenjie );
			return;
		end
	end

	HeChengController:ReqToolHeCheng(self.selid,2,num)
end

--显示道具信息
function UIToolHeCheng:RefreshToolList()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	--分解
	--if self.tabButton[HeChengConsts.TABFENJIE].selected == true then
	--	self:RefreshFenJieList();

	--合成
	--else
		self:RefreshHeChengList();
	--end
end

--显示道具分解
function UIToolHeCheng:RefreshFenJieList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	-- objSwf.hechengpanel._visible = false;
	-- objSwf.fenjiepanel._visible = true;
	local treeData, id = HeChengUtil:GetHeChengTree(t_itemresolve, 2, self.openlist);
	if self.selid == 0 then
		self.selid = id;
	end
	if self.openid > 0 then
		self.selid = self.openid;
		self.openid = 0;
	end

	if self.selid ~= 0 then
		--合成数量
		ns._value = 0;
		ns:updateLabel();
		self:UpdateFenJieNum();

		--更新道具材料信息
		self:UpdateToolInfo();

		self:UpdateFenJieMoney();
	end

	--分解可获得材料
	objSwf.tfnummiaoshu.text = StrConfig["hecheng6"];

	if not treeData then return; end
	UIData.cleanTreeData( objSwf.list.dataProvider.rootNode);
	UIData.copyDataToTree(treeData,objSwf.list.dataProvider.rootNode);
	objSwf.list.dataProvider:preProcessRoot();
	objSwf.list:invalidateData();

	objSwf.btnhecheng.visible = false;
	objSwf.btnfenjie.visible = true;
end

--刷新列表
function UIToolHeCheng:RefreshHeChengList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	-- objSwf.hechengpanel._visible = true;
	-- objSwf.fenjiepanel._visible = false;

	local treeData, id = HeChengUtil:GetHeChengTree(t_itemcompound, 1, self.openlist);
	if self.selid == 0 then
		self.selid = id;
	end
	if self.openid > 0 then
		self.selid = self.openid;
		self.openid = 0;
	end

	if self.selid ~= 0 then
		--合成数量
		ns._value = 0;
		ns:updateLabel();

		--更新道具材料信息
		self:UpdateToolInfo();

		self:UpdateHeChengMoney();
	end

	--需要材料
	objSwf.tfnummiaoshu.text = StrConfig["hecheng5"];

	if not treeData then return; end
	UIData.cleanTreeData( objSwf.list.dataProvider.rootNode);
	UIData.copyDataToTree(treeData,objSwf.list.dataProvider.rootNode);
	objSwf.list.dataProvider:preProcessRoot();
	objSwf.list:invalidateData();


	objSwf.btnhecheng.visible = true;
	objSwf.btnfenjie.visible = false;
end

--更新道具和材料信息
function UIToolHeCheng:RefreshToolInfo(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	--分解
	--if self.tabButton[HeChengConsts.TABFENJIE].selected == true then
		--道具成功分解
	--	FloatManager:AddCenter(StrConfig["hecheng8"]);

	--	if body.type == 2 and body.Id == self.selid  then
		--	self:RefreshFenJieInfo();
		--end

	--合成
	--else
		--道具成功合成
		FloatManager:AddNormal(StrConfig["hecheng7"]);
		-- 飞图标
		local rewardList = RewardManager:ParseToVO(toint(self.selid));
		local startPos = UIManager:PosLtoG(objSwf.toolitem);
		RewardManager:FlyIcon(rewardList,startPos,5,true,60);
		if body.type == 1 and body.Id == self.selid then
			self:RefreshHeChengInfo();
		end
	--end
end
--显示道具分解
function UIToolHeCheng:RefreshFenJieInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	local treeData = HeChengUtil:GetHeChengTree(t_itemresolve, 2, self.openlist);

	--更新道具材料信息
	self:UpdateToolInfo();

	self:UpdateFenJieMoney();

	if not treeData then return; end
	UIData.cleanTreeData( objSwf.list.dataProvider.rootNode);
	UIData.copyDataToTree(treeData,objSwf.list.dataProvider.rootNode);
	objSwf.list.dataProvider:preProcessRoot();
	objSwf.list:invalidateData();
end

--显示道具合成
function UIToolHeCheng:RefreshHeChengInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	local treeData = HeChengUtil:GetHeChengTree(t_itemcompound, 1, self.openlist);

	--更新道具材料信息
	self:UpdateToolInfo();

	self:UpdateHeChengMoney();

	if not treeData then return; end
	UIData.cleanTreeData( objSwf.list.dataProvider.rootNode);
	UIData.copyDataToTree(treeData,objSwf.list.dataProvider.rootNode);
	objSwf.list.dataProvider:preProcessRoot();
	objSwf.list:invalidateData();
end

--点击列表
function UIToolHeCheng:OnListItemClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not e.item then return; end

	local lvl = e.item.lvl;
	if  lvl == 4 then
		self.selid = e.item.id;
	end

	self:UpdateOpenList(e.item);

	self:RefreshToolList();
end

function UIToolHeCheng:UpdateOpenList(node)
	--如果是第四层，需要先删除其他的第四层显示item，在添加node
	local isfour = false;
	if node.lvl == 4 then
		isfour = true;
	end
	local isfind = false;
	for i,vo in pairs(self.openlist) do
		if vo then
			--是否有选中4层
			if isfour == true then
				if vo["label"..node.lvl] then
					isfind = false;
					self.openlist[i] = {};
					break;
				end
			end

			local ishave = true;
			for i=1,HeChengConsts.CENGMAX do
				if node["label"..i] and vo["label"..i] then
					if node["label"..i] ~= vo["label"..i] then
						ishave = false;
						break;
					end
				elseif (not node["label"..i] and vo["label"..i]) or (node["label"..i] and not vo["label"..i]) then
					ishave = false;
					break;
				end
			end

			if ishave == true then
				isfind = true;
				self.openlist[i] = {};
				break;
			end
		end
	end

	--添加
	if isfind == false then
		local vo = {};
		for i=1,HeChengConsts.CENGMAX do
			if node["label"..i] then
				vo["label"..i] = node["label"..i];
			end
		end
		table.push(self.openlist, vo);
	end
end

--刷新道具信息
function UIToolHeCheng:UpdateToolInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	--if self.tabButton[HeChengConsts.TABHECHENG].selected == true then
		self:UpdateHeChengNum();
		self:UpdateToolHeChengInfo();
		self:UpdateHeChengMaterialNum(ns._value);
	--else
		--self:UpdateFenJieNum();
		--self:UpdateToolFenJieInfo();
		--self:UpdateFenJieMaterialNum(ns._value);
	--end
end

--刷新道具合成信息
function UIToolHeCheng:UpdateToolHeChengInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	for i=1,self.materialmax do
		self.tfcountlist[i].htmlText = "";
	end

	--道具
	local slotVO = RewardSlotVO:new();
	slotVO.id = self.selid;
	slotVO.count = 0;
	objSwf.toolitem:setData( slotVO:GetUIData() );
	local toolItem = t_item[self.selid];
	objSwf.tftoolname.text = "";
	if not toolItem then
		toolItem = t_equip[self.selid];
	end
	objSwf.tftoolname.text = toolItem.name;

	local itemvo = t_itemcompound[self.selid];
	if itemvo then
		--材料
		local itemList = HeChengUtil:ToolParse( itemvo.materialitem );
		objSwf.toolList.dataProvider:cleanUp();
		objSwf.toolList.dataProvider:push(unpack(itemList));
		objSwf.toolList:invalidateData();

		--材料数量
		local materiallist = HeChengUtil:GetHeChengMaterialList(self.selid);
		local list = RewardManager:ParseToVO( itemvo.materialitem );
		for i,vo in ipairs(list) do
			if vo then
				local intemNum = materiallist[i];
				if ns._value == 0 then
					self.tfcountlist[i].htmlText = string.format( StrConfig['hecheng2'], intemNum.."/"..vo.count);
				else
					self.tfcountlist[i].htmlText = string.format( StrConfig['hecheng1'], intemNum.."/"..(vo.count*ns._value));
				end
			end
		end
	end
end

--刷新道具分解信息
function UIToolHeCheng:UpdateToolFenJieInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	for i=1,self.materialmax do
		self.tfcountlist[i].htmlText = "";
	end

	--道具
	local slotVO = RewardSlotVO:new();
	slotVO.id = self.selid;
	slotVO.count = 0;
	objSwf.toolitem:setData( slotVO:GetUIData() );

	local itemvo = t_itemresolve[self.selid];
	if itemvo then
		--材料
		local itemList = RewardManager:Parse( itemvo.materialitem );
		objSwf.toolList.dataProvider:cleanUp();
		objSwf.toolList.dataProvider:push(unpack(itemList));
		objSwf.toolList:invalidateData();

		--材料数量
		local materiallist = HeChengUtil:GetHeChengMaterialList(self.selid);
		local list = RewardManager:ParseToVO( itemvo.materialitem );
		for i,vo in ipairs(list) do
			if vo then
				local intemNum = materiallist[i];
				if ns._value == 0 then
					self.tfcountlist[i].htmlText = string.format( StrConfig['hecheng2'], vo.count);
				else
					self.tfcountlist[i].htmlText = string.format( StrConfig['hecheng1'], vo.count*ns._value);
				end
			end
		end
	end
end

--刷新合成道具信息
function UIToolHeCheng:UpdateHeChengMaterialNum(hechengcount)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not hechengcount then return end
	for i=1,self.materialmax do
		self.tfcountlist[i].htmlText = "";
	end

	local itemvo = t_itemcompound[self.selid];
	if itemvo then
		--材料数量
		local materiallist = HeChengUtil:GetHeChengMaterialList(self.selid);
		local list = RewardManager:ParseToVO( itemvo.materialitem );
		for i,vo in ipairs(list) do
			if vo then
				local intemNum = materiallist[i];
				if intemNum < vo.count then
					self.tfcountlist[i].htmlText = string.format( StrConfig['hecheng2'], intemNum.."/"..vo.count);
				else
					if hechengcount <= 0 then
						self.tfcountlist[i].htmlText = string.format( StrConfig['hecheng1'], intemNum.."/"..vo.count);
					else
						self.tfcountlist[i].htmlText = string.format( StrConfig['hecheng1'], intemNum.."/"..(vo.count*hechengcount));
					end
				end
			end
		end
	end
end
--刷新分解道具信息
function UIToolHeCheng:UpdateFenJieMaterialNum(fenjiecount)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	for i=1,self.materialmax do
		self.tfcountlist[i].htmlText = "";
	end

	local itemvo = t_itemresolve[self.selid];
	if itemvo then
		--材料数量
		local list = RewardManager:ParseToVO( itemvo.materialitem );
		for i,vo in ipairs(list) do
			if vo then
				if fenjiecount == 0 then
					self.tfcountlist[i].htmlText = string.format( StrConfig['hecheng2'], vo.count);
				else
					self.tfcountlist[i].htmlText = string.format( StrConfig['hecheng1'], vo.count*fenjiecount);
				end
			end
		end
	end
end

--更新合成数量
function UIToolHeCheng:UpdateHeChengNum()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	local itemvo = t_itemcompound[self.selid];
	if itemvo then
		local hechengcount = HeChengUtil:GetHeChengMax(self.selid);
		if ns.value ~= 0 then
			--当前显示的数量大于最大数量
			if ns.value > hechengcount then
				if hechengcount == 0 then
					ns._value = 0;
				else
					ns._value = 1;
				end

				ns:updateLabel();
			end
		else
			--从0数量切换到非0数量
			if hechengcount > 0 then
				ns._value = 1;
				ns:updateLabel();
			end
		end
	end
end

--更新分解数量
function UIToolHeCheng:UpdateFenJieNum()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	local itemvo = t_itemresolve[self.selid];
	if itemvo then
		local fenjiecount = HeChengUtil:GetFenJieMax(self.selid);
		if ns.value ~= 0 then
			--当前显示的数量大于最大数量
			if ns.value > fenjiecount then
				if fenjiecount == 0 then
					ns._value = 0;
				else
					ns._value = 1;
				end

				ns:updateLabel();
			end
		else
			--从0数量切换到非0数量
			if fenjiecount > 0 then
				ns._value = 1;
				ns:updateLabel();
			end
		end
	end
end

function UIToolHeCheng:UpdateHeChengMoney()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	local itemvo = t_itemcompound[self.selid];
	if itemvo then
		--判断条件
		local consummeney = 0
		if ns._value then
			consummeney = itemvo.consume_money * ns._value;
		end
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaBindGold + playerinfo.eaUnBindGold < consummeney then
			objSwf.tfconsum.htmlText = string.format( StrConfig['hecheng36'], consummeney);
		else
			objSwf.tfconsum.htmlText = string.format( StrConfig['hecheng35'], consummeney);
		end
	end
end

function UIToolHeCheng:UpdateFenJieMoney()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	local itemvo = t_itemresolve[self.selid];
	if itemvo then
		--判断条件
		local consummeney = itemvo.consume_money * ns._value;
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaBindGold + playerinfo.eaUnBindGold < consummeney then
			objSwf.tfconsum.htmlText = string.format( StrConfig['hecheng36'], consummeney);
		else
			objSwf.tfconsum.htmlText = string.format( StrConfig['hecheng35'], consummeney);
		end
	end
end

function UIToolHeCheng:OnBtnMaxClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	--if self.tabButton[HeChengConsts.TABHECHENG].selected == true then
		self:HeChengMax();
	--else
	--	self:FenJieMax();
	--end
end
function UIToolHeCheng:HeChengMax()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	local hechengcount = HeChengUtil:GetHeChengMax(self.selid);

	if hechengcount == 0 then
		FloatManager:AddNormal( StrConfig['hecheng15'] );
		SoundManager:PlaySfx(2043);
	else
		if hechengcount == ns.value then
			FloatManager:AddNormal( StrConfig['hecheng13'] );
			SoundManager:PlaySfx(2043);
		else
			ns.value = hechengcount;
		end
	end

	self:UpdateHeChengMaterialNum(hechengcount);
	self:UpdateHeChengMoney();
end
function UIToolHeCheng:FenJieMax()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;

	local fenjiecount = HeChengUtil:GetFenJieMax(self.selid);

	if fenjiecount == 0 then
		FloatManager:AddNormal( StrConfig['hecheng14'] );
	else
		if fenjiecount == ns.value then
			FloatManager:AddNormal( StrConfig['hecheng13'] );
		else
			ns.value = fenjiecount;
		end
	end

	self:UpdateFenJieMaterialNum(fenjiecount);
	self:UpdateFenJieMoney();
end

function UIToolHeCheng:OnNsChange(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--if self.tabButton[HeChengConsts.TABHECHENG].selected == true then
		self:OnHeChengNsChange(e);
	--else
		--self:OnFenJieNsChange(e);
	--end
end
function UIToolHeCheng:OnHeChengNsChange(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = e.target;

	local hechengcount = HeChengUtil:GetHeChengMax(self.selid);
	if ns.value ~= 0 then
		if ns.value > hechengcount then
			ns._value = hechengcount;
			ns:updateLabel();

			if hechengcount == 0 then
				FloatManager:AddNormal( StrConfig['hecheng15'], objSwf.ns );
			else
				FloatManager:AddNormal( StrConfig['hecheng13'], objSwf.ns );
			end
		end

		self:UpdateHeChengMaterialNum(ns.value);
	else
		if hechengcount > 0 then
			ns._value = 1;
			ns:updateLabel();

			self:UpdateHeChengMaterialNum(ns.value);
		end
	end

	self:UpdateHeChengMoney();
end
function UIToolHeCheng:OnFenJieNsChange(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = e.target;

	local fenjiecount = HeChengUtil:GetFenJieMax(self.selid);
	if ns.value ~= 0 then
		if ns.value > fenjiecount then
			ns._value = fenjiecount;
			ns:updateLabel();

			if fenjiecount == 0 then
				FloatManager:AddNormal( StrConfig['hecheng14'], objSwf.ns );
			else
				FloatManager:AddNormal( StrConfig['hecheng13'], objSwf.ns );
			end
		end

		self:UpdateFenJieMaterialNum(ns.value);
	else
		if fenjiecount > 0 then
			ns._value = 1;
			ns:updateLabel();

			self:UpdateFenJieMaterialNum(ns.value);
		end
	end

	self:UpdateFenJieMoney();
end
