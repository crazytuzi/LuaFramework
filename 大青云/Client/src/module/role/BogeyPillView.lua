--[[
	妖丹
	2014年12月11日, PM 04:53:01
	wangyanwei
]]
_G.UIBogeyPill = BaseUI:new("UIBogeyPill");
UIBogeyPill.nowYaoDanList = {};  --妖丹可以使用list
UIBogeyPill.usePreFightNum = 0;  --使用丹药之前的战斗力
UIBogeyPill.listrowmax = 4;

function UIBogeyPill:Create()
	self:AddSWF("roleAttributePanel.swf", true, nil);
end

function UIBogeyPill:OnLoaded(objSwf)

	objSwf.rulesbtn.rollOver = function () TipsManager:ShowBtnTips(StrConfig['role200'],TipsConsts.Dir_RightDown);  end
	objSwf.rulesbtn.rollOut = function () TipsManager:Hide(); end
	
	self:OnShowTxt();
	objSwf.txtName_4.text = UIStrConfig['role106'];
	objSwf.txtName_5.text = UIStrConfig['role107'];
	objSwf.txtName_6.text = UIStrConfig['role105'];
	-- objSwf.txtName_7.text = UIStrConfig['role117'];
	--使用普通妖丹
	objSwf.btnuse.click = function() self:OnUseBogeyPillClick(); end
	--前往合成
	objSwf.btnhecheng.click = function() self:OnHeChengClick(); end
	--使用VIP妖丹
	--objSwf.btnusevip.click = function(e) self:OnUseVIPBogeyPillClick(e); end
	--objSwf.btnusevip._visible = false   --changer ：houxudong
	--objSwf.btnuse。
	objSwf.btnuse.rollOver = function () TipsManager:ShowBtnTips(StrConfig['role422'],TipsConsts.Dir_RightDown);  end
	objSwf.btnuse.rollOut = function () TipsManager:Hide(); end
	--objSwf.btnusevip.rollOver = function () TipsManager:ShowBtnTips(StrConfig['role423'],TipsConsts.Dir_RightDown);  end
	--objSwf.btnusevip.rollOut = function () TipsManager:Hide(); end
	
	objSwf.list.rollOver1 = function(e) self:OnItemRollOver(e); end
	objSwf.list.RollOut1 = function(e) TipsManager:Hide(); end
	objSwf.list.click1 = function(e) self:OnItemClick(e); end
	RewardManager:RegisterListTips(objSwf.matList)
	objSwf.txthechengcailiao._visible = false;

end

function UIBogeyPill:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIBogeyPill:OnShow()
	self:ShowAvatar();
	self:OnChangeListData();
	self:OnShowTxt();
	self:ShowBtnUseEffect();
end

-----------------------------------------------------------new
-----------------------------------------------------------new
-----------------------------------------------------------new

--[[
	妖丹
	changer：houxudong
	date：2016年4月28日, PM 05:40:01
--]]
 
 --妖丹list鼠标悬浮显示详情 
function UIBogeyPill:OnItemRollOver(e)
	local item = e.item;
	if item and item.id then
		TipsManager:ShowItemTips( item.id);
	end
end

function UIBogeyPill:OnItemClick(e)
	local item = e.item;
	if item and item.id then
		local id = item.id;
		local cfg = t_itemcompound[id]
		if not cfg then
			self.objSwf.matList.dataProvider:cleanUp();
			self.objSwf.matList:invalidateData();
			return;
		end
		local matStr = cfg.materialitem;
		-- local itemList = HeChengUtil:ToolParse(matStr);

		-- self.objSwf.matList.dataProvider:cleanUp();
		-- self.objSwf.matList.dataProvider:push(unpack(itemList));
		self.objSwf.matList:invalidateData();
		self.objSwf.matList.dataProvider:cleanUp();
		self.objSwf.matList:invalidateData();
		-- if #itemList > 0 then
		-- 	self.objSwf.txthechengcailiao._visible = false;
		-- end
	end
end

function UIBogeyPill:OnMatItemRollOver(item)
	if not item then
		return;
	end
	local data = item:GetData();
	if not data.hasItem then return; end;
	TipsManager:ShowItemTips(data.tid);
end

--使用普通妖丹
-- 一键使用丹药
function UIBogeyPill:OnUseBogeyPillClick()
	local list = RoleBoegeyPillUtil:GetBogeyPillList(false);
	self.nowYaoDanList = {}
	for i=1,#list do
		local vo = {}
		vo.item_tid = list[i].item_tid
		vo.item_count = list[i].item_count
		table.push(self.nowYaoDanList,vo)
	end
	--获取妖丹使用之前的战斗力
	self.usePreFightNum = self:GetPrePillFight()
	if #list <= 0 then
		FloatManager:AddNormal( StrConfig["role420"] );  --没有可使用的妖丹
		return
	end
	BagController:UseAllItem(BagConsts.BagType_Bag,list);
end

--获取妖丹的战斗力
function UIBogeyPill:GetPrePillFight( )
	local obj = RoleBoegeyPillUtil:GetBogyePillAttr();
	local vo = {};
	vo.def = obj[1];
	vo.att = obj[2];
	vo.hp = obj[3];
	vo = self:OnSortNum(vo);
	return PublicUtil:GetFigthValue(vo)   --根据属性计算战斗力
end

-- 服用丹药列表
function UIBogeyPill:OpenCanUsePillList( )
	local difFight = self:GetPrePillFight() - self.usePreFightNum  --战斗力
	if self.nowYaoDanList then
		UIBogeyPilluseListView:OnOpen(self.nowYaoDanList,difFight)
	end
end

function UIBogeyPill:ShowBtnUseEffect( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local panel = objSwf and objSwf.btnuse
	local list = RoleBoegeyPillUtil:GetBogeyPillList(false)
	if #list > 0 then
		panel:showEffect(ResUtil:GetButtonEffect7());
	else
		panel:clearEffect();
	end
	-- 可以合成丹药
	if HeChengUtil:CheckCanUsePill( ) then
		PublicUtil:SetRedPoint(objSwf.btnhecheng, nil, 1,true)
	else
		PublicUtil:SetRedPoint(objSwf.btnhecheng)
	end
end

--前往合成
function UIBogeyPill:OnHeChengClick()
	UIToolHeCheng:Show();
end

--使用VIP妖丹
function UIBogeyPill:OnUseVIPBogeyPillClick(e)
	local list = RoleBoegeyPillUtil:GetBogeyPillList(true);
	if #list <= 0 then
		FloatManager:AddNormal( StrConfig["role420"] );
		return
	end
	BagController:UseAllItem(BagConsts.BagType_Bag,list);
end

--点击切换
UIBogeyPill.bogeySelectIndex = 0;
function UIBogeyPill:OnBogeyPillClick(e)
	self.bogeySelectIndex = e.index;
	self:OnChangeListData();
end

--画出妖丹list
function UIBogeyPill:OnChangeListData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local index = self.bogeySelectIndex;  --itemRenderer
	
	local bogeylist = {};
	local treeData = RoleBoegeyPillUtil:GetBoegeyPillList(bogeylist);
	UIData.cleanTreeData( objSwf.list.dataProvider.rootNode);
	UIData.copyDataToTree(treeData,objSwf.list.dataProvider.rootNode);
	objSwf.list.dataProvider:preProcessRoot();
	objSwf.list:invalidateData();
	
	--超过2页的话 滚动条会向下滚动
	if RoleBoegeyPillModel:GetpillPage() and RoleBoegeyPillModel:GetpillPage() > 2 then
		objSwf.list.scrollPosition = RoleBoegeyPillModel:GetpillPage() - 2;
	end
end

-----------------------------------------------------------new
-----------------------------------------------------------new
-----------------------------------------------------------new

--左上角总属性文本赋值
function UIBogeyPill:OnShowTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	--获取妖丹的属性
	local obj = RoleBoegeyPillUtil:GetBogyePillAttr();
	for i = 1 , 3 do  --for i = 4 , 6 do
		if not obj[i] then 
			objSwf["txt_" .. i].text = "+0"
		else
			objSwf["txt_" .. i].text = "+" .. obj[i];   ---显示加成数值
		end
	end
	local vo = {};
	--[[
	vo.att = nil; --obj[1];
	vo.def = nil;--obj[2];
	vo.hp = nil;--obj[3];
	vo.hl = obj[4];
	vo.tp = obj[5];
	vo.sf = obj[6]; 
	vo.js = obj[7];
	vo.eaMaxHp = obj[1];
	vo.att = obj[2];
	vo.def = obj[3];
	--]]
	-- trace(obj)
	vo.def = obj[1];
	vo.att = obj[2];
	vo.hp = obj[3];
	vo = self:OnSortNum(vo);
	local fight = PublicUtil:GetFigthValue(vo)   --根据属性计算战斗力
	objSwf.numFight.num = fight;   
end

--排序属性
function UIBogeyPill:OnSortNum(obj)
	local vo = {};
	for i , v in pairs (obj) do
		local cfg = {};
		cfg.type = nil;
		for str , id in pairs(AttrParseUtil.AttMap) do
			if str == i then
				cfg.type = id;
			end
		end
		cfg.val = v ;
		table.push(vo,cfg);
	end
	return vo
end


--显示人物打坐模型
function UIBogeyPill:ShowAvatar()
	local danyaoLoader = self.objSwf.danyaoLoader;
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
	local viewPort = _Vector2.new(900, 605);

	if not self.scene then
		self.scene = UISceneDraw:new(self:GetName(), danyaoLoader, viewPort, false);
	end
	self.scene:SetUILoader(danyaoLoader)

	self.scene:SetScene(RoleBoegeyPillUtil.panelUISEN, function()
		self:DrawAvatar(drawCfg);
	end );
	self.scene:SetDraw( true );
end

function UIBogeyPill:DrawAvatar()
	local uiLoader = self.objSwf.uiLoader;
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业

	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf
	vo.arms = info.dwArms
	vo.dress = info.dwDress
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = info.dwFashionsHead
	vo.fashionsArms = info.dwFashionsArms
	vo.fashionsDress = info.dwFashionsDress
	vo.wuhunId = SpiritsModel:GetFushenWuhunId()
	vo.wing = info.dwWing
	vo.suitflag = info.suitflag
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(vo);

	self.objAvatar:PlaySitAction();
	-- self.objAvatar:PlayLandEatAction();
	-- self.objAvatar:StopLandEatAction()
	-- self.objAvatar:PlayZhuoBianEatAction();
--[[
	if not self.objUIDraw then
		local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
		self.objUIDraw = UIDraw:new("roleBogeyPillPlayer", self.objAvatar, uiLoader,
			UIDrawBogeyPillConfig[prof].VPort,UIDrawBogeyPillConfig[prof].EyePos,UIDrawBogeyPillConfig[prof].LookPos,
			0x00000000,"UIRole", prof);
	else
		self.objUIDraw:SetUILoader(uiLoader);
		self.objUIDraw:SetCamera(UIDrawBogeyPillConfig[prof].VPort,UIDrawBogeyPillConfig[prof].EyePos,UIDrawBogeyPillConfig[prof].LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
	]]
	self.scene:SetCamera(UIDrawBogeyPillConfig[prof].VPort,UIDrawBogeyPillConfig[prof].EyePos,UIDrawBogeyPillConfig[prof].LookPos);
	self.objAvatar:EnterUIScene(self.scene.objScene, _Vector3.new(3.32,0,-2.33),nil,nil, enEntType.eEntType_Npc);
end

function UIBogeyPill:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.objAvatar then
		self.objAvatar = nil;
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.scene then
		self.scene:SetDraw(false)
	end
	self.objSwf.matList.dataProvider:cleanUp();
	self.objSwf.matList:invalidateData();
	UIBogeyPill.selecteIndex = 1;

end

--得到指引需要的page按钮与妖丹按钮
function UIBogeyPill:GetPillBtn()
	if not self:IsShow() then return; end
	local obj = RoleBoegeyPillUtil:GetPillPageOrIndex();
	if not obj or obj == {} then return end
	if self:IsShow() then
		self:OnSetYaoDanIndexHandler(RoleBoegeyPillUtil.pillPage);
	end
	return self.objSwf["btn_" .. obj.index];
end

--得到标签
function UIBogeyPill:GetTabPage()
	if not self:IsShow() then return; end
	local obj = RoleBoegeyPillUtil:GetPillPageOrIndex();
	if not obj or obj == {} then return end
	return obj.page;

end

--面板显示侦听
function UIBogeyPill:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.UpdataBogeyPillChangeList then
		RoleBoegeyPillModel:SetIsShowEffect(true);
		self:OnShowTxt();
		self:OnChangeListData();
		RoleBoegeyPillUtil:ClearItemGuideInfo();
		FloatManager:AddNormal( StrConfig["role419"] )
		self:ShowBtnUseEffect()
		-- self:OpenCanUsePillList()    --屏蔽丹药预览
	elseif name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate or name == NotifyConsts.VipJihuoEffect then
		self:ShowBtnUseEffect()
	end
end
function UIBogeyPill:ListNotificationInterests()
	return {
		NotifyConsts.UpdataBogeyPillChangeList,NotifyConsts.UpdataYaoHunChangeList,
		NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagUpdate,NotifyConsts.VipJihuoEffect,
	}
end