_G.UISmithingCollect = BaseUI:new("UISmithingCollect");

UISmithingCollect.index = 1
local t_equipCollect = {3, 6, 11}
local s_strRed = "<font color='#FF0000'>%s</font>"
local s_strYellow = "<font color='#00ff00'>%s</font>"

UISmithingCollect.btnSelecte = {}

function UISmithingCollect:Create()
	self:AddSWF("smithingCollectPanelV.swf",true,"center");
end

function UISmithingCollect:OnLoaded(objSwf)
	objSwf.list.click1 = function(e) self:OnListItemClick(e); end
	objSwf.btn_close.click = function() self:Hide() end
	objSwf.rewardBtn.click = function() self:GetReward() end
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end
	objSwf.equipList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.equipList.itemRollOut = function () TipsManager:Hide(); end
	for i = 1, 3 do
		objSwf.panel1["getBtn" ..i].click = function() self:AskActiveInfo(i) end
	end
	-- for i = 1, 8 do
	-- 	objSwf["pageBtn" ..i].click = function() self:OnPageBtnClick(i) end
	-- end
	self.objSwf.panelBtn1.click = function() self.objSwf.panel1._visible = true self.objSwf.panel2._visible = false end
	self.objSwf.panelBtn2.click = function() self.objSwf.panel2._visible = true self.objSwf.panel1._visible = false end
	objSwf.reward1.visible = false
	objSwf.rewardBtn.visible = false
	objSwf.txt_Label._visible = false
end

function UISmithingCollect:OnShow()
	if self.args and self.args[1] then
		self.index = self.args[1]
	else
		local bHaveIndex = false
		for i = 1, #t_equipcollectionbasis do
			if SmithingModel:IsEquipCollectCanOperate(i) then
				self.index = i
				bHaveIndex = true
				break
			end
		end
		if not bHaveIndex then
			for i = 1, #t_equipcollectionbasis do
				if not SmithingModel:IsEquipCollectGetAll(i) then
					self.index = i
					break
				end
			end
		end
	end
	self.objSwf.panelBtn1.selected = true
	self.objSwf.panel1._visible = true
	self.objSwf.panel2._visible = false
	self:ShowPageList()
	self:ShowCollectInfo()
	self:ShowEquip()
	self:DrawScene()
end

function UISmithingCollect:OnListItemClick(e)
	if not e.item then return end
	if e.item.id > 10000 then
		self.objSwf.list:selectedState(e.item.id)
		self.objSwf.list:invalidateData();
		self:OnPageBtnClick(e.item.id - 10000)
	end
end

function UISmithingCollect:ShowPageList()
	local objSwf = self.objSwf
	if not objSwf then return end
 	UIData.cleanTreeData( objSwf.list.dataProvider.rootNode);
 	self.treeData = {}
	self.treeData.label = "root";
	self.treeData.open = true;
	self.treeData.isShowRoot = false;
	self.treeData.nodes = {};
	local cfg = t_equipcollectionbasis[self.index]
	for i = 1, SmithingModel:GetEquipCollectGroupNum() do
		local scrollNode = {};
		scrollNode.open = false;
		scrollNode.nodes = {};
		scrollNode.id = i;
		scrollNode.ischild = false;
		scrollNode.star = 0
		scrollNode.nameUrl = SmithingModel:GetCollectIcon(i)
		scrollNode.canOperate = false
		if cfg.sequence == i then
			scrollNode.open = true
		end
		local list = SmithingModel:GetCollectInfoByGroup(i)
		for j, k in ipairs(list) do
			local nodeThree = {};
			nodeThree.nodeType = 2;
			nodeThree.ischild = true;
			nodeThree.name = k.name2
			nodeThree.id = 10000+k.id;
			nodeThree.btnSelected = false;
			nodeThree.star = k.star
			if SmithingModel:IsEquipCollectCanOperate(k.id) then
				scrollNode.canOperate = true
				nodeThree.canOperate = true
			else
				nodeThree.canOperate = false
			end
			if k.id == self.index then
			   nodeThree.btnSelected = true;
			end
			table.push(scrollNode.nodes, nodeThree)
		end
		table.push(self.treeData.nodes, scrollNode);
	end
	UIData.copyDataToTree(self.treeData,objSwf.list.dataProvider.rootNode);
	objSwf.list.dataProvider:preProcessRoot();
	objSwf.list:invalidateData();
end

function UISmithingCollect:UpdateBtnPfx()
	self.objSwf.list:clearPfxState()
	for i = 1, SmithingModel:GetEquipCollectGroupNum() do
		local list = SmithingModel:GetCollectInfoByGroup(i)
		for k, v in pairs(list) do
			if SmithingModel:IsEquipCollectCanOperate(v.id) then
				self.objSwf.list:setPfxState(10000 +v.id)
				self.objSwf.list:setPfxState(i)
				break
			end
		end
	end
	self.objSwf.list:invalidateData()
end

function UISmithingCollect:OnPageBtnClick(i)
	if self.index == i then
		return
	end
	self.index = i
	self:ShowCollectInfo()
	self:ShowEquip()
	self:ChangeAvatarEquips()
end

local s_Pro = {"three_active", "six_activity", "nine_activity"}
function UISmithingCollect:ShowCollectInfo()
	local objSwf = self.objSwf
	if not objSwf then return end

	local info = SmithingModel:GetEquipCollectInfo(self.index)
	local value = 0
	for i = 1, 11 do
		local cfg = t_equipcollectionplace[self.index * 100 + i]
		if info.actlist[i] and info.actlist[i] == 1 then
			value = value + 1
			objSwf['txt_get'..i]._visible = true --string.format(s_strYellow, StrConfig['equipcollect1'])
			objSwf['txt_noget'..i]._visible = false
			objSwf["btnGo"..i].htmlLabel = string.format("<font color = '#00ff00'><u>%s</u></font>", cfg.fun_txt)
		else
			objSwf['txt_get'..i]._visible = false --string.format(s_strRed, StrConfig['equipcollect2'])
			objSwf['txt_noget'..i]._visible = true
			objSwf["btnGo"..i].htmlLabel = string.format("<font color = '#00ff00'><u>%s</u></font>", cfg.fun_txt)
		end
	end
	objSwf.panel1.progressBar.maximum = 11
	objSwf.panel1.progressBar.value = value
	objSwf.panel1.txt_jindu.text = string.format(StrConfig['equipcollect3'], value, 11)
	-- if info.get == 1 then
	-- 	objSwf.rewardBtn.visible = false
	-- elseif value >= 9 then
	-- 	objSwf.rewardBtn.visible = true
	-- 	objSwf.rewardBtn.disabled = false
	-- else
	-- 	objSwf.rewardBtn.visible = true
	-- 	objSwf.rewardBtn.disabled = true
	-- end

	local allPro = {}
	local cfg = t_equipcollectionbasis[self.index]
	for i = 1, 3 do
		local btn = objSwf.panel1["getBtn" ..i]
		btn.visible = true
		-- objSwf["proPfx" ..i]._visible = false
		local slot = {}
		table.insert(slot, objSwf.panel1['txt_pro' .. (3*(i -1) + 1)])
		table.insert(slot, objSwf.panel1['txt_pro' .. (3*(i -1) + 2)])
		table.insert(slot, objSwf.panel1['txt_pro' .. (3*(i -1) + 3)])

		local pro = AttrParseUtil:Parse(cfg[s_Pro[i]])
		local color1, color2 = "#5a5a5a", "#5a5a5a"
		if info['pro' ..i] == 1 then
			color1 = nil
			color2 = nil
			btn.visible = false
			objSwf.panel1['txt_act' ..i].htmlText = StrConfig['equipcollect4']
			allPro = PublicUtil:GetFightListPlus(allPro, pro)
			btn:clearEffect()
		elseif value >= t_equipCollect[i] then
			-- objSwf["proPfx" ..i]._visible = true
			btn.visible = true
			objSwf.panel1['txt_act' ..i].htmlText = ""
			btn:showEffect(ResUtil:GetButtonEffect7())
		else
			objSwf.panel1['txt_act' ..i].htmlText = StrConfig['equipcollect5']
			btn.visible = false
			btn:clearEffect()
		end
		
		PublicUtil:ShowProInfoForUI(pro, slot, nil, nil, nil, nil, color1, color2, true)
	end

	local slot = {}
	table.insert(slot, objSwf.panel1.txt_proall1)
	table.insert(slot, objSwf.panel1.txt_proall2)
	table.insert(slot, objSwf.panel1.txt_proall3)
	PublicUtil:ShowProInfoForUI(allPro, slot, nil, nil, nil, nil, nil, nil, true)
	objSwf.panel1.fight.fightLoader.num = cfg.fighting --PublicUtil:GetFigthValue(allPro)
	self:ShowPanel2Info()
end

function UISmithingCollect:ShowPanel2Info()
	local objSwf = self.objSwf
	if not objSwf then return end
	local cfg = t_equipcollectionbasis[self.index]
	local slot = {}
	for i = 1, 7 do
		table.insert(slot, objSwf.panel2['txt_proall' ..i])
	end
	local pro = AttrParseUtil:Parse(cfg.basis_att)
	PublicUtil:ShowProInfoForUI(pro, slot, nil, nil, nil, true)

	local str = split(cfg.recommend, ",")
	for i = 1, 8 do
		local slot = objSwf.panel2['txt_proall1' ..i]
		if str[i] then
			slot.htmlText = str[i]
		else
			slot.htmlText = ""
		end
	end

	local fight = cfg.fighting1 or 0
	objSwf.panel2.fight.fightLoader.num = fight
	objSwf.panel2.fight.fightLoader._x = 0 - string.len(tostring(fight)) *5
end

function UISmithingCollect:ShowEquip()
	local objSwf = self.objSwf
	if not objSwf then return end

	local cfg = t_equipcollectionbasis[self.index];
	if not cfg then return; end
	
	-- 奖励
	-- local randomList = RewardManager:Parse(cfg.reward);
	-- objSwf.rewardList.dataProvider:cleanUp();
	-- objSwf.rewardList.dataProvider:push(unpack(randomList));
	-- objSwf.rewardList:invalidateData();

	--- 装备
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	local str = ""
	for i = 1, 11 do
		local cfg = t_equipcollectionplace[self.index * 100 + i]
		if cfg then
			local item = split(cfg.equipgroup, ",")
			if #item ~= 0 then
				if #item > 1 then
					str = str .. split(item[prof], "#")[1] .. "," .. "0"
				else
					str = str .. split(item[1], "#")[1] .. "," .. "0"
				end
				if i ~= 11 then
					str = str .. "#"
				end
			end
		end
		objSwf['btnGo'..i].click = function() FuncManager:OpenFunc(cfg.fun_id) end
	end
	local equipList = RewardManager:Parse(str);
	objSwf.equipList.dataProvider:cleanUp();
	objSwf.equipList.dataProvider:push(unpack(equipList));
	objSwf.equipList:invalidateData();
end

function UISmithingCollect:DrawScene()
	local objSwf = self.objSwf
	if not objSwf then return end

	local prof = MainPlayerModel.humanDetailInfo.eaProf; 
	if prof == 4 then
		if not self.viewPort then self.viewPort = _Vector2.new(1400, 795); end  --795
	else
		if not self.viewPort then self.viewPort = _Vector2.new(1300, 815); end  --795
	end
	if not self.scene then
		self.scene = UISceneDraw:new("UISmithingCollect", objSwf.loader, self.viewPort, false);
	end
	self.scene:SetUILoader(objSwf.loader)
	
	local src = Assets:GetRolePanelSen(MainPlayerModel.humanDetailInfo.eaProf);
	self.scene:SetScene(src, function()
		self:DrawRole();
	end );
	self.scene:SetDraw( true );
end

function UISmithingCollect:DrawRole()
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	
	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf;
	vo.arms = info.dwArms;
	vo.dress = info.dwDress;
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = info.dwFashionsHead;
	vo.fashionsArms = info.dwFashionsArms;
	vo.fashionsDress = info.dwFashionsDress;
	vo.wuhunId = SpiritsModel:GetFushenWuhunId();
	vo.wing = info.dwWing;
	vo.suitflag = info.suitflag;
	vo.shenwuId = info.shenwuId;
	
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar.bIsAttack = false;
	self.objAvatar:CreateByVO(vo);
	
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self:ChangeAvatarEquips()
	
	local markers = self.scene:GetMarkers();
	local indexc = "marker2";
	self.objAvatar:EnterUIScene(self.scene.objScene,markers[indexc].pos,markers[indexc].dir,markers[indexc].scale, enEntType.eEntType_Player);
end

--- 角色换装
function UISmithingCollect:ChangeAvatarEquips()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.objAvatar then return end

	local cfg =t_equipcollectionbasis[self.index]
	if cfg then
		if objSwf.panel1.icon_des.source ~= ResUtil:GetEquipCollectIcon(cfg.name1) then
			objSwf.panel1.icon_des.source = ResUtil:GetEquipCollectIcon(cfg.name1)
		end
		if cfg.name3 and cfg.name3 ~= "" then
			objSwf.loader1._visible = true
			if objSwf.loader1.source ~= ResUtil:GetEquipCollectIcon(cfg.name3) then
				objSwf.loader1.source = ResUtil:GetEquipCollectIcon(cfg.name3)
			end
		else
			objSwf.loader1._visible = false
		end
	end

	self.objAvatar:RemoveAllEquips()
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	for i = 1, 11 do
		local cfg = t_equipcollectionplace[self.index * 100 + i]
		if cfg then
			local item = split(cfg.equipgroup, ",")
			if #item ~= 0 then
				if #item > 1 then
					self.objAvatar:AddEquip(toint(split(item[prof], "#")[1]))
				else
					self.objAvatar:AddEquip(toint(split(item[1], "#")[1]))
				end
			end
		end
	end
end

-- 申请激活
function UISmithingCollect:AskActiveInfo(i)
	if SmithingModel:IsEquipCollectCanActive(self.index, i) then
		SmithingController:AskEquipCollectActive(self.index, i)
	end
end

-- 获取奖励
function UISmithingCollect:GetReward()
	if SmithingModel:IsEquipCollectCanGetReward(self.index) then
		SmithingController:GetEquipCollectReward(self.index)
	end
end

function UISmithingCollect:GetWidth()
	return 1146;
end

function UISmithingCollect:GetHeight()
	return 687;
end

--面板类型
function UISmithingCollect:GetPanelType()
	return 1;
end


function UISmithingCollect:IsShowSound()
	return true
end

function UISmithingCollect:OnHide()
	if SmithingModel:IsEquipCollectCanOperate1() then
		RemindController:AddRemind(RemindConsts.Type_SmithingCollection, 1);
	else
		RemindController:AddRemind(RemindConsts.Type_SmithingCollection, 0);
	end
	if self.scene then
		self.scene:SetDraw(false)
		self.scene:SetUILoader(nil)
		UIDrawManager:RemoveUIDraw(self.scene)
		self.scene = nil
	end
	
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self.showList = nil
	self.btnSelecte = {}
end
function UISmithingCollect:IsTween()
	return true;
end
function UISmithingCollect:HandleNotification(name,body)
	self:ShowCollectInfo()
	self:UpdateBtnPfx()
end
function UISmithingCollect:ListNotificationInterests()
	return {
		NotifyConsts.EquipCollectUpdate,
	}
end