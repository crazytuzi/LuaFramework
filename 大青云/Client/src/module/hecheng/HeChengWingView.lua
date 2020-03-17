--[[
翅膀合成界面面板
zhangshuhui
2015年7月23日15:20:20
]]

_G.UIWingHeCheng = BaseUI:new("UIWingHeCheng");

UIWingHeCheng.tfcountlist = {};
UIWingHeCheng.materialmax = 8--材料数量
UIWingHeCheng.objUIDraw = nil;--3d渲染器
UIWingHeCheng.meshDir = 0; --模型的当前方向
--当前道具id
UIWingHeCheng.selid = 0;
UIWingHeCheng.IsSelectFirst = true;


--打开特定道具id
UIWingHeCheng.openid = 0;

--打开的节点list
UIWingHeCheng.openlist = {};

--属性最大数量
UIWingHeCheng.attrMax = 5;

function UIWingHeCheng:Create()
	self:AddSWF("hechengWingPanel.swf", true, nil);
end

function UIWingHeCheng:OnLoaded(objSwf, name)
	objSwf.list.itemClick1 = function(e) self:OnListItemClick(e); end
	objSwf.btnhecheng.click = function() self:OnBtnHeChengClick(); end;
	objSwf.scrollBar._visible = false;
	
	for i=1,self.materialmax do
		objSwf["btnAddSucItem"..i].click = function() self:OnBtnAddSucItemClick(i); end;
	end
	--战斗力值居中
	self.numFightx = objSwf.numLoaderFight._x
	objSwf.numLoaderFight.loadComplete = function()
									objSwf.numLoaderFight._x = self.numFightx - objSwf.numLoaderFight.width / 2
								end
	RewardManager:RegisterListTips( objSwf.toolList );
	for i=1,self.materialmax do
		objSwf["sucitem"..i].click = function() self:OnToolItemClick(i); end
		objSwf["sucitem"..i].rollOver = function() self:OnToolItemrollOver(i); end
		objSwf["sucitem"..i].rollOut = function() TipsManager:Hide(); end
	end
	--模型防止阻挡鼠标
	objSwf.modelload.hitTestDisable = true;
	objSwf.mcTimeout._visible = false;
	objSwf.mcTimeout3._visible = false;
	objSwf.mcTimeout.btnGuide.click = function() self:OnBtnTimeOutGuideClick(); end
	objSwf.mcTimeout3.btnGuide.click = function() self:OnBtnGoShopClick(); end
	--objSwf.mcTimeout.textfield._visible = false;
	objSwf.mcTimeout.btnGuide._visible = false;
end

function UIWingHeCheng:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIWingHeCheng:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil)
		UIDrawManager:RemoveUIDraw(self.objUIDraw)
		self.objUIDraw = nil
	end
	HeChengModel:ClearRantItemList();
	self.IsSelectFirst = true
end

--点击添加
function UIWingHeCheng:OnBtnAddSucItemClick(i)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	UIWingShortCutSet:Open(objSwf["btnAddSucItem"..i], i);
end

function UIWingHeCheng:OnToolItemClick(index)
	local vo = {};
	vo.index = index;
	vo.cid = 0;
	vo.tid = 0;
	HeChengModel:AddRantItem(vo);
	self:UpdateSucRateTool();
	self:UpdateSucRate();
end

function UIWingHeCheng:OnToolItemrollOver(i)
	local vo = HeChengModel:GetRantItemVO(i);
	if vo then
		TipsManager:ShowItemTips(vo.tid);
	end
end
		
---------------------------------消息处理------------------------------------
--处理消息
function UIWingHeCheng:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.ToolHeChengInfo then
		self:ShowWingList();
		self:UpdateMaterialInfo();
		self:UpdateSucRateTool();
		self:UpdateSucRate();
		self:UpdateHeChengMoney();
		-- self:CheckTimeOutGuide();
		SoundManager:PlaySfx(2043);
	elseif name == NotifyConsts.BagItemNumChange then
		self:UpdateMaterialInfo();
		self:UpdateRantItemList();
		self:UpdateSucRateTool();
		self:UpdateSucRate();
		self:ShowBtnEffect();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold then
			self:UpdateSucRate();
		end
	end
end

--监听消息
function UIWingHeCheng:ListNotificationInterests()
	return {NotifyConsts.ToolHeChengInfo, NotifyConsts.BagItemNumChange,
			NotifyConsts.PlayerAttrChange};
end

function UIWingHeCheng:OnShow()
	self:ClearData();
	self:ShowWingList();
	self:ShowWingInfo();
	self:ShowAttrInfo();
	self:ShowFight();
	self:UpdateMaterialInfo();
	self:UpdateSucRate();
	self:UpdateHeChengMoney();
	self:ShowBtnEffect();
	-- self:CheckTimeOutGuide();
end
function UIWingHeCheng:ShowBtnEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self:GetIsToolCanHeCheng() and self:GetIsMoneyCanHeCheng() then
		objSwf.btnhecheng:showEffect(ResUtil:GetButtonEffect10());
	else
		objSwf.btnhecheng:clearEffect();
	end
end
--清空数据
function UIWingHeCheng:ClearData()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local WingId = self:CanHeChengWing()
	if toint(WingId)>0 then--是否有可合成的翅膀
		self.selid = WingId
	else--玩家已穿戴某阶神翼后，再次打开神翼界面可默认选中下一阶神翼
		local cfg = WingStarUtil:GetInWingCfg()
		if cfg then	
			self.selid = cfg.id+1;
			if cfg.id+1==1009 then
				self.selid = 1008
			end
		else
			self.selid = 0;
		end
	end
	self.openlist = {};
	if self.openid > 0 then
		if self.opentype == 1 then
			self.openlist = HeChengUtil:GetHeChengTreeById(t_wing,self.openid)
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
		vo4.id = 1001;
		table.push(self.openlist, vo4);
	end
	
	objSwf.toolList.dataProvider:cleanUp();
	objSwf.toolList:invalidateData();

	
	for i=1,self.materialmax do
		objSwf["tfcount"..i].htmlText = "";
		objSwf["sucitem"..i]._visible = false;
		if i == 1 then
			objSwf["btnAddSucItem"..i]._visible = false;
		else
			objSwf["btnAddSucItem"..i]._visible = false;
			objSwf["AddSucRate"..i]._visible = false;
		end
	end
end
--显示翅膀列表
function UIWingHeCheng:ShowWingList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local treeData, selid = HeChengUtil:GetWingList(t_wing, self.openlist);
	
	if self.selid == 0 then
		self.selid = selid;
	end
	
	if not treeData then return; end
	UIData.cleanTreeData( objSwf.list.dataProvider.rootNode);
	UIData.copyDataToTree(treeData,objSwf.list.dataProvider.rootNode);
	objSwf.list.dataProvider:preProcessRoot();
	objSwf.list:invalidateData();
	if self.IsSelectFirst then
		objSwf.list:selectedState(self.selid);
		self.IsSelectFirst = false
	end
end

--显示翅膀信息 
function UIWingHeCheng:ShowWingInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--模型
	self:DrawWingModel();
	--名称
	local wingcfg = t_wing[self.selid];
	if not wingcfg then
		return;
	end
	objSwf.nameLoader.source =  ResUtil:GetWingHeChengName(wingcfg.nameicon);
	-- objSwf.lvlLoader.num = self.selid-1000;
	objSwf.lvlLoader.num = wingcfg.level
	if self.selid-1000 >= 10 then
		objSwf.lvlLoader.num = "a";
	end
end

local viewWingHeChengPort;
--显示模型
function UIWingHeCheng:DrawWingModel()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = {};
	cfg = t_wing[self.selid];
	if not cfg then
		return;
	end
	if not self.objUIDraw then
		if not viewWingHeChengPort then viewWingHeChengPort = _Vector2.new(1279, 732); end
		self.objUIDraw = UISceneDraw:new( "UIWingHeCheng", objSwf.modelload, viewWingHeChengPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelload);
	
	self.objUIDraw:SetScene( cfg.ui_sen, function()
		local aniName = cfg.show_san;
		if not aniName or aniName == "" then return end
		if not cfg.ui_node then return end
		
		local nodeName = split(cfg.ui_node, "#")
		if not nodeName or #nodeName < 1 then return end	
		for k,v in pairs(nodeName) do
			self.objUIDraw:NodeAnimation( v, aniName );
		end
	end );
	--self.objUIDraw:NodeVisible(cfg.ui_node,true);
	self.objUIDraw:SetDraw( true );
end

function UIWingHeCheng:Clearmodel( )
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil)
		UIDrawManager:RemoveUIDraw(self.objUIDraw)
		self.objUIDraw = nil
	end
end

--显示属性
function UIWingHeCheng:ShowAttrInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.teshupanel._visible = false;
	for i=1,UIWingHeCheng.attrMax do
		objSwf["tfattrname"..i].htmlText = "";
		objSwf["tfattrvalue"..i].htmlText = "";
	end
	
	local wingcfg = t_wing[self.selid];
	if wingcfg then
		--特殊属性
		if wingcfg.sattr ~= "" then
			local sattrvo = split(wingcfg.sattr,",");
			local sattrtype = AttrParseUtil.AttMap[sattrvo[1]];
			local sattrval = tonumber(sattrvo[2]);
			objSwf.teshupanel._visible = true;
			objSwf.teshupanel.tfteshuname.htmlText = enAttrTypeName[sattrtype];
			objSwf.teshupanel.tfteshuvalue.htmlText = string.format( "%0.2f", sattrval*100 ).."%";
		end
		
		--基础属性
		local attrList = split(wingcfg.attr,"#");
		for i,attrStr in ipairs(attrList) do
			local attrvo = split(attrStr,",");
			local val = tonumber(attrvo[2]);
			objSwf["tfattrname"..i].htmlText = PublicStyle:GetAttrNameStr(HeChengConsts:GetAttrName(attrvo[1]));
			local type = AttrParseUtil.AttMap[attrvo[1]];
			if type == enAttrType.eaHurtAdd or type == enAttrType.eaHurtSub then
				objSwf["tfattrvalue"..i].htmlText = PublicStyle:GetAttrValStr(string.format( "%0.2f", val*100 ).."%");
			else
				objSwf["tfattrvalue"..i].htmlText = PublicStyle:GetAttrValStr(val);
			end
		end
	end
end

--显示战斗力
function UIWingHeCheng:ShowFight()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local fightnum = 0;
	local wingcfg = t_wing[self.selid];
	if wingcfg then
		fightnum = wingcfg.fight;
	end
	objSwf.numLoaderFight.num = fightnum;
end

--刷新材料信息
function UIWingHeCheng:UpdateMaterialInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	for i=1,self.materialmax do
		objSwf["tfcount"..i].htmlText = "";
	end
	
	local itemvo = t_wing[self.selid];
	if itemvo then
		--材料
		local itemList = HeChengUtil:ToolParse( itemvo.compound );
		objSwf.toolList.dataProvider:cleanUp();
		objSwf.toolList.dataProvider:push(unpack(itemList));
		objSwf.toolList:invalidateData();
		
		--材料数量
		local materiallist = HeChengUtil:GetWingMaterialList(self.selid);
		local list = RewardManager:ParseToVO( itemvo.compound );
		for i,vo in ipairs(list) do
			if vo then
				local intemNum = materiallist[i];
				if intemNum >= vo.count then
					objSwf["tfcount"..i].htmlText = string.format( StrConfig['hecheng1'], intemNum.."/"..vo.count);
				else
					objSwf["tfcount"..i].htmlText = string.format( StrConfig['hecheng2'], intemNum.."/"..vo.count);
				end
			end
		end
	end
end

--合成条件是否道具满足
function UIWingHeCheng:GetIsToolCanHeCheng()
	local itemvo = t_wing[self.selid];
	if itemvo then
		local materiallist = HeChengUtil:GetWingMaterialList(self.selid);
		local list = RewardManager:ParseToVO( itemvo.compound );
		for i,vo in ipairs(list) do
			if vo then
				local intemNum = materiallist[i];
				if intemNum < vo.count then
					return false;
				end
			end
		end
	end
	return true;
end

--得到是否金钱足够
function UIWingHeCheng:GetIsMoneyCanHeCheng()
	local itemvo = t_wing[self.selid];
	if itemvo then
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaBindGold + playerinfo.eaUnBindGold >= itemvo.consume_money then
			return true;
		end
	end
	return false;
end
--判断是否有能合成的翅膀
function UIWingHeCheng:CanHeChengWing()
	local WingId = 0
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local num = 0
	for k,v in pairs(t_wing) do
		if v.id then
			num = num +1
		end
	end
	for i=1 , num do
		local IsCan = true;
		local materiallist = HeChengUtil:GetWingMaterialList(t_wing[i+1001].id);
		local list = RewardManager:ParseToVO( t_wing[i+1001].compound );
		for i,vo in ipairs(list) do
			if vo then
				local intemNum = materiallist[i];
				if intemNum < vo.count then
					IsCan = false
				end
			end
		end
		if IsCan==true then
			if playerinfo.eaBindGold + playerinfo.eaUnBindGold >= t_wing[i+1001].consume_money then
				WingId = t_wing[i+1001].id;
			end
		end
	end
	return WingId;
end

--刷新增加成功率道具
function UIWingHeCheng:UpdateRantItemList()
	-- local list = {};
	-- for i=1,self.materialmax do
		-- if HeChengModel.rantitemlist[i] then
			-- local itemId = HeChengModel.rantitemlist[i].tid;
			-- local intemNum = BagModel:GetItemNumInBag(itemId);
			-- if list[itemId] then
				-- list[itemId] = list[itemId] + 1;
			-- else
				-- list[itemId] = 1;
			-- end
			
			-- if intemNum < list[itemId] then
				-- HeChengModel.rantitemlist[i].tid = 0;
			-- end
		-- end
	-- end
end

--刷新增加成功率道具
function UIWingHeCheng:UpdateSucRateTool()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	-- local isfind = false;
	-- for i=1,self.materialmax do
		-- if HeChengModel.rantitemlist[i] and HeChengModel.rantitemlist[i].tid > 0 then
			-- objSwf["btnAddSucItem"..i]._visible = false;
			-- objSwf["sucitem"..i]._visible = true;
			-- if i > 1 then
				-- objSwf["AddSucRate"..i]._visible = false;
			-- end
			
			-- local slotVO = RewardSlotVO:new();
			-- slotVO.id = HeChengModel.rantitemlist[i].tid;
			-- slotVO.count = 0;
			-- objSwf["sucitem"..i]:setData( slotVO:GetUIData() );
		-- else
			-- objSwf["btnAddSucItem"..i]._visible = false;
			-- objSwf["sucitem"..i]._visible = false;
			-- if isfind == false then
				-- isfind = true;
				-- objSwf["btnAddSucItem"..i]._visible = true;
				
				-- if i > 1 then
					-- objSwf["AddSucRate"..i]._visible = false;
				-- end
			-- else
				-- objSwf["AddSucRate"..i]._visible = true;
			-- end
		-- end
	-- end
end

--显示成功率
function UIWingHeCheng:UpdateSucRate()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.textXiaohao._visible = true;
	objSwf.tfconsum._visible = true;
	objSwf.textMoney._visible = true;
	objSwf.tfconsum.htmlText = "";
	local itemvo = t_wing[self.selid];
	if itemvo then
		if toint(itemvo.consume_money) == 0 then
			objSwf.textXiaohao._visible = false;
			objSwf.tfconsum._visible = false;
			objSwf.textMoney._visible = false;
			return
		end
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaBindGold + playerinfo.eaUnBindGold >= itemvo.consume_money then
			objSwf.tfconsum.htmlText = string.format( StrConfig['hecheng1'], itemvo.consume_money);
		else
			objSwf.tfconsum.htmlText = string.format( StrConfig['hecheng2'], itemvo.consume_money);
		end
	end
end

--银两消耗
function UIWingHeCheng:UpdateHeChengMoney()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	
end

--刷新列表
function UIWingHeCheng:RefreshToolList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	-- local treeData, id = HeChengUtil:GetHeChengTree(t_wing, 1, self.openlist);
	-- if self.selid == 0 then
		-- self.selid = id;
	-- end
	-- if self.openid > 0 then
		-- self.selid = self.openid;
		-- self.openid = 0;
	-- end
	
	-- if self.selid ~= 0 then
		
		-- --更新道具材料信息
		-- self:UpdateToolInfo();
		
		-- self:UpdateHeChengMoney();
	-- end
	
	-- if not treeData then return; end
	-- objSwf.list.dataProvider:cleanUp();
	-- UIData.copyDataToTree(treeData,objSwf.list.dataProvider.rootNode);
	-- objSwf.list.dataProvider:preProcessRoot();
	-- objSwf.list:invalidateData();
end

--点击列表
function UIWingHeCheng:OnListItemClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not e.item then return; end
	if self.selid == e.item.id then
		self.IsSelectFirst = true
		self:ShowWingList();
		return;
	end
	-- objSwf.list:selectedState(e.item.id);
	local lvl = e.item.lvl;
	if  lvl == 4 then
		self.selid = e.item.id;
	end
	
	self:UpdateOpenList(e.item);
	self:Clearmodel()
	HeChengModel:ClearRantItemList();
	self:ShowWingList();
	self:ShowWingInfo();
	self:ShowAttrInfo();
	self:ShowBtnEffect();
	self:ShowFight();
	self:UpdateMaterialInfo();
	self:UpdateSucRateTool();
	self:UpdateSucRate();
	self:UpdateHeChengMoney();
	-- self:CheckTimeOutGuide();
end

UIWingHeCheng.lastSendTime = 0;
--确定合成
function UIWingHeCheng:OnBtnHeChengClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	if GetCurTime() - self.lastSendTime < 200 then
		return;
	end
	self.lastSendTime = GetCurTime();


	if self:GetIsToolCanHeCheng() == false then
		FloatManager:AddNormal( StrConfig["hecheng29"], objSwf.btnhecheng);
		return;
	end
	if self:GetIsMoneyCanHeCheng() == false then
		FloatManager:AddNormal( StrConfig["hecheng32"], objSwf.btnhecheng);
		return;
	end
	local list = {};
	for i,vo in ipairs(HeChengModel.rantitemlist) do
		local void = {};
		void.id = vo.tid;
		table.push(list,void);
	end
	
	local wingcfg = t_wing[self.selid];
	if wingcfg then
		HeChengController:ReqWingHeCheng(self.selid,list);
	end
end

function UIWingHeCheng:UpdateOpenList(node)
	--如果是第四层，需要先删除其他的第四层显示item，在添加node
	local isfour = false;
	if node.lvl == 4 then
		isfour = true;
	end
	
	--是否有第一层
	local ishaveone = true;
	
	local isfind = true;
	for i,vo in pairs(self.openlist) do
		if vo then
			--是否有选中4层
			if isfour == true then
				if vo.id then
					isfind = false;
					self.openlist[i] = {};
					break;
				end
			else
				local ishave = true;
				--当前该层打开着，需要关闭
				if vo.label1 and not vo.label2 and not vo.id then
					self.openlist[i] = {};
					ishaveone = false;
					break;
				end
			end
		end
	end
	
	if isfour == false and ishaveone == true then
		isfind = false;
	end
	
	--添加
	if isfind == false then
		local vo = {};
		for i=1,HeChengConsts.CENGMAX do
			vo.label1 = 1;
		end
		
		if node.lvl == 4 then
			vo.id = node.id;
		end
		table.push(self.openlist, vo);
	end
end

UIWingHeCheng.WingLevelToShop = 3;--3阶翅膀前往商城
--检查是否翅膀到期引导
function UIWingHeCheng:CheckTimeOutGuide()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local wingcfg = t_wing[self.selid];
	if not wingcfg then return; end
	local userWingLevel = WingController:GetWingMaxLevel();--玩家当前的翅膀等级
	if wingcfg.level > UIWingHeCheng.WingLevelToShop then
		objSwf.mcTimeout3._visible = false;
		objSwf.mcTimeout._visible = false;
		objSwf.lvlLoader._visible = true;
		objSwf.nameLoader._visible = true;
		return;
	elseif wingcfg.level == UIWingHeCheng.WingLevelToShop then
		if userWingLevel >= UIWingHeCheng.WingLevelToShop then
			objSwf.mcTimeout3._visible = false;
			objSwf.mcTimeout._visible = false;
			objSwf.lvlLoader._visible = true;
			objSwf.nameLoader._visible = true;
		else
			-- objSwf.mcTimeout3._visible = true;
			objSwf.mcTimeout._visible = false;
			objSwf.lvlLoader._visible = false;
			objSwf.nameLoader._visible = false;
		end
	elseif wingcfg.level == WingController.WingGiveLevel then
		if userWingLevel >= WingController.WingGiveLevel then
			objSwf.mcTimeout3._visible = false;
			objSwf.mcTimeout._visible = false;
			objSwf.lvlLoader._visible = true;
			objSwf.nameLoader._visible = true;
		else
			objSwf.mcTimeout3._visible = false;
			-- objSwf.mcTimeout._visible = true;
			objSwf.lvlLoader._visible = false;
			objSwf.nameLoader._visible = false;
		end
	elseif wingcfg.level == 1 then
		if userWingLevel >= 1 then
			objSwf.mcTimeout3._visible = false;
			objSwf.mcTimeout._visible = false;
			objSwf.lvlLoader._visible = true;
			objSwf.nameLoader._visible = true;
		else
			objSwf.mcTimeout3._visible = false;
			objSwf.mcTimeout._visible = true;
			objSwf.lvlLoader._visible = false;
			objSwf.nameLoader._visible = false;
		end
	end
end

function UIWingHeCheng:OnBtnTimeOutGuideClick()
	UIVip:Show();
end

function UIWingHeCheng:OnBtnGoShopClick()
	UIShoppingMall:OpenPanel(1, 0);
end