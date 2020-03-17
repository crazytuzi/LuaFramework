--[[
自动战斗设置
郝户
2014年10月21日16:00:48
]]
_G.classlist['UIAutoBattle'] = 'UIAutoBattle'
_G.UIAutoBattle = BaseUI:new("UIAutoBattle");
UIAutoBattle.objName = 'UIAutoBattle'
UIAutoBattle.saved = true; --是否已保存

function UIAutoBattle:Create()
	self:AddSWF("autoBattleSetting.swf", true, "center" );
end

function UIAutoBattle:IsTween()
	return true;
end

function UIAutoBattle:IsShowSound()
	return true;
end

function UIAutoBattle:GetPanelType()
	return 1;
end

function UIAutoBattle:ESCHide()
	return true;
end

function UIAutoBattle:GetWidth()
	return 464;
end

function UIAutoBattle:GetHeight()
	return 688;
end

-------------------------------初始化--------------------------------

function UIAutoBattle:OnLoaded( objSwf, name )
	--恢复设置初始化
	self:InitRecover(objSwf);
	--战斗设置初始化
	self:InitBattle(objSwf);
	--拾取设置初始化
	self:InitPick(objSwf);
	--主面板初始化
	self:InitMainPanel(objSwf);

	self.saved = true;
end

function UIAutoBattle:InitRecover(objSwf)
	--text
	objSwf.txtRecover1.text  = StrConfig["autoBattle02"];
	--下拉菜单
	local dmHp = objSwf.dmHp;
	dmHp.dataProvider:cleanUp();
	for i, dataItem in ipairs(AutoBattleUtils:GetSeqProvider()) do
		dmHp:decodeItem( UIData.encode(dataItem) );
	end
	--输入文本
	--Event handlers--
	objSwf.sliderHp.change = function(e) self:OnSliderHpChange(e) end
	dmHp.change = function(e) self:OnDmHpChange(e) end
	objSwf.chkBoxAutoBuyDrug.select = function(e) self:OnAutoBuySelect(e) end
end

function UIAutoBattle:InitBattle(objSwf)
	--text
	objSwf.txtBattle2.text  = StrConfig["autoBattle08"];
	-- objSwf.txtBattle3.text  = StrConfig["autoBattle09"];
	objSwf.txtBattle4.text  = StrConfig["autoBattle10"];
	objSwf.txtBattle5.text  = StrConfig["autoBattle11"];
	--Event handlers--
	local listNormal  = objSwf.listSkillNormal;
	local listSpecial = objSwf.listSkillSpecial;
	listNormal.itemClick     = function(e) self:OnSkillClick(e, "normalSkillList");  end
	listNormal.itemSetClick  = function(e) self:OnSkillSetClick(e);  end
	listNormal.itemRollOver  = function(e) self:OnSkillRollOver(e); end
	listNormal.itemRollOut   = function() self:OnSkillRollOut(); end
	listSpecial.itemClick    = function(e) self:OnSkillClick(e, "specialSkillList"); end
	listSpecial.itemSetClick = function(e) self:OnSkillSetClick(e); end
	listSpecial.itemRollOver = function(e) self:OnSkillRollOver(e); end
	listSpecial.itemRollOut  = function() self:OnSkillRollOut(); end
	local listTianshen = objSwf.listSkillTianshen
	listTianshen.itemClick    = function(e) self:OnTianShenSkillClick(); end
	listTianshen.itemRollOver = function(e) self:OnSkillRollOver(e); end
	listTianshen.itemRollOut  = function() self:OnSkillRollOut(); end
	objSwf.numStpMonsterRange.change        = function() self:OnNsMonsterRangeChange(); end
	objSwf.chkBoxAutoHang.select            = function(e) self:OnAutoHangSelect(e); end
	objSwf.chkBoxAutoCounter.select         = function(e) self:OnAutoCounterSelect(e); end
	objSwf.chkBoxAutoReviveSitu.select      = function(e) self:OnAutoReviveSituSelect(e); end
	--objSwf.chkBoxNotActiveAttackBoss.select = function(e) self:OnNotActiveAttackBossSelect(e); end
end

function UIAutoBattle:InitPick(objSwf)
	--text
	objSwf.txtPick1.text  = StrConfig["autoBattle13"];
	--下拉菜单
	local dmEquipProf = objSwf.dmEquipProf;
	dmEquipProf.dataProvider:cleanUp();
	for i, dataItem in ipairs(AutoBattleUtils:GetEquipProfProvider()) do
		dmEquipProf:decodeItem( UIData.encode(dataItem) );
	end
	local dmEquipLvl = objSwf.dmEquipLvl;
	dmEquipLvl.rowCount = 10
	dmEquipLvl.dataProvider:cleanUp();
	for i, dataItem in ipairs(AutoBattleUtils:GetEquipLvlProvider()) do
		dmEquipLvl:decodeItem( UIData.encode(dataItem) );
	end
	local dmEquipQuality = objSwf.dmEquipQuality;
	dmEquipQuality.rowCount = 10
	dmEquipQuality.dataProvider:cleanUp();
	for i, dataItem in ipairs(AutoBattleUtils:GetEquipQualityProvider()) do
		dmEquipQuality:decodeItem( UIData.encode(dataItem) );
	end
	--Event handlers--
	objSwf.chkBoxPickEquip.select    = function(e) self:OnPickEquipSelect(e) end
	objSwf.chkBoxPickDrug.select     = function(e) self:OnPickDrugSelect(e) end
	objSwf.chkBoxPickMoney.select    = function(e) self:OnPickMoneySelect(e) end
	objSwf.chkBoxPickMaterial.select = function(e) self:OnPickMaterialSelect(e) end
	objSwf.dmEquipProf.change        = function(e) self:OnDmEquipProfChange(e) end
	objSwf.dmEquipLvl.change         = function(e) self:OnDmEquipLvlChange(e) end
	objSwf.dmEquipQuality.change     = function(e) self:OnDmEquipQualityChange(e) end
end

function UIAutoBattle:InitMainPanel(objSwf)
	-- text
	objSwf.txtHotKey.text = StrConfig["autoBattle14"];
	-- buttons
	objSwf.btnClose.click     = function() self:OnBtnCloseClick(); end
	objSwf.btnStartHang.click = function(e) self:OnBtnStartHangClick(e); end
	objSwf.btnDefault.click   = function() self:OnBtnDefaultClick(); end
	objSwf.btnSave.click      = function() self:OnBtnSaveClick(); end
end


--------------------更新显示---------------------------------

function UIAutoBattle:OnShow(name)
	self:UpdateShow();
end

function UIAutoBattle:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:UpdateRecoverShow(objSwf);
	self:UpdateBattleShow(objSwf);
	self:UpdatePickShow(objSwf);
	self:SwitchHang( AutoBattleController.isAutoHang );
end

function UIAutoBattle:UpdateRecoverShow(objSwf)
	--滑块
	objSwf.sliderHp.value = AutoBattleModel.takeDrugHp;
	--百分比文本
	self:UpdateTxtPer(objSwf.txtHp, AutoBattleModel.takeDrugHp);
	--下拉菜单
	local dmHpIndex = AutoBattleUtils:Seq2Index( AutoBattleModel.takeHpDrugSequence );
	objSwf.dmHp.selectedIndex = dmHpIndex;
	--复选框
	objSwf.chkBoxAutoBuyDrug.selected = AutoBattleModel.autoBuyDrug;
end

function UIAutoBattle:UpdateBattleShow(objSwf)
	--特殊技能列表
	self:UpdateSpecialSkillList(objSwf);
	--普通技能列表
	self:UpdateNormalSkillList(objSwf);
	--天神技能
	self:ShowTianShenSkill(objSwf)
	--自动寻怪半径
	objSwf.numStpMonsterRange.value = AutoBattleModel.findMonsterRange;
	--复选框
	objSwf.chkBoxAutoHang.selected            = AutoBattleModel.autoHang;
	objSwf.chkBoxAutoCounter.selected         = AutoBattleModel.autoCounter;
	objSwf.chkBoxAutoReviveSitu.selected      = AutoBattleModel.autoReviveSitu;
	--objSwf.chkBoxNotActiveAttackBoss.selected = AutoBattleModel.noActiveAttackBoss;
end

function UIAutoBattle:UpdateNormalSkillList(objSwf)
	local listSkillNormal = objSwf.listSkillNormal;
	local normalSkillShowList = self:GetSkillShowList(AutoBattleModel.normalSkillList, AutoBattleConsts.NumSkill);
	listSkillNormal.dataProvider:cleanUp();
	for i, vo in ipairs( normalSkillShowList ) do
		listSkillNormal.dataProvider:push( UIData.encode(vo) );
	end
	listSkillNormal:invalidateData();
end

function UIAutoBattle:ShowTianShenSkill(objSwf)
	if not objSwf then return end
	if not TianShenModel:GetFightModel() then
		objSwf.listSkillTianshen.dataProvider:cleanUp()
		return
	end
	local vo = {}
	vo.skillId = 5000001
	vo.iconUrl = ResUtil:GetSkillIconUrl(t_skill[5000001].icon);
	vo.selected = AutoBattleModel.autoCastTianShenSkill == 1 and true or false
	objSwf.listSkillTianshen.dataProvider:cleanUp()
	objSwf.listSkillTianshen.dataProvider:push(UIData.encode(vo));
	objSwf.listSkillTianshen:invalidateData()
end

function UIAutoBattle:OnTianShenSkillClick()
	if not TianShenModel:GetFightModel() then
		return
	end
	if AutoBattleModel.autoCastTianShenSkill == 1 then
		AutoBattleModel.autoCastTianShenSkill = 0
	else
		AutoBattleModel.autoCastTianShenSkill = 1
	end
	self:ShowTianShenSkill(self.objSwf)
	AutoBattleController:SaveAutoBattleSetting()
end

function UIAutoBattle:UpdateSpecialSkillList(objSwf)
	local listSkillSpecial = objSwf.listSkillSpecial;
	local specialSkillShowList = self:GetSkillShowList(AutoBattleModel.specialSkillList, AutoBattleConsts.NumSkillSpecial);
	listSkillSpecial.dataProvider:cleanUp();
	for i, vo in ipairs( specialSkillShowList ) do
		if SkillUtil:IsShortcutSkill(vo.skillId) then
			listSkillSpecial.dataProvider:push( UIData.encode(vo) );
		end
	end
	listSkillSpecial:invalidateData();
end

function UIAutoBattle:GetSkillShowList(srcList, size)
	local list = table.clone(srcList);
	for i = #list, 1, -1 do
		local vo = list[i];
		if not AutoBattleUtils:ShowInSetting(vo.skillId) then
			table.remove(list, i);
		end
	end
	while(#list < size) do table.insert(list, {}); end
	return list;
end

function UIAutoBattle:UpdatePickShow(objSwf)
	--复选框
	local autoPickEquip = AutoBattleModel.autoPickEquip;
	objSwf.chkBoxPickEquip.selected    = autoPickEquip;
	objSwf.chkBoxPickDrug.selected     = AutoBattleModel.autoPickDrug;
	objSwf.chkBoxPickMoney.selected    = AutoBattleModel.autoPickMoney;
	objSwf.chkBoxPickMaterial.selected = AutoBattleModel.autoPickMaterial;
	--下拉菜单
	local dmEquipProf    = objSwf.dmEquipProf;
	local dmEquipLvl     = objSwf.dmEquipLvl;
	local dmEquipQuality = objSwf.dmEquipQuality;
	dmEquipProf.disabled    = not autoPickEquip;
	dmEquipLvl.disabled     = not autoPickEquip
	dmEquipQuality.disabled = not autoPickEquip
	dmEquipProf.selectedIndex    = AutoBattleUtils:EquipProf2Index( AutoBattleModel.autoPickEquipProf );
	dmEquipLvl.selectedIndex     = AutoBattleUtils:EquipLvlRange2Index( AutoBattleModel.autoPickEquipLvl );
	dmEquipQuality.selectedIndex = AutoBattleUtils:EquipQuality2Index( AutoBattleModel.autoPickEquipQuality );
end
-------------------------------------

function UIAutoBattle:OnBeforeHide()
	if not self.saved then
		local content = StrConfig['autoBattle31'];
		local confirmFunc = function()
			self:Save();
			self:Hide();
		end
		local cancelFunc   = function()
			self.saved = true;
			self:Hide();
		end
		local confirmLabel = StrConfig['autoBattle32'];
		local cancelLabel  = StrConfig['autoBattle33'];
		UIConfirm:Open( content, confirmFunc, cancelFunc, confirmLabel, cancelLabel, nil, true--[[true表示点确认面板×的时候不执行cancel func, 就不会点x同时关闭挂机设置]] );
		return false;
	end
	return true;
end

function UIAutoBattle:OnHide()
	TipsManager:Hide();
end

-------------------恢复设置事件处理---------------------
function UIAutoBattle:OnSliderHpChange(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local value = objSwf.sliderHp.value;
	self:ChangeCfg( "takeDrugHp", value );
	self:UpdateTxtPer(objSwf.txtHp, value);
end

function UIAutoBattle:OnDmHpChange(e)
	local sequence = e.data.seq;
	self:ChangeCfg( "takeHpDrugSequence", sequence );
end

function UIAutoBattle:OnAutoBuySelect(e)
	self:ChangeCfg( "autoBuyDrug", e.selected );
end

--更新textfield百分比显示
function UIAutoBattle:UpdateTxtPer(txt, per)
	local percentage = toint(per * 100, 1); --percentage: 百分数乘过100后向上取整的数
	txt.text = percentage.."%";
	txt.textColor = AutoBattleUtils:GetTakeDrugTxtColor( percentage );
end


--------------------战斗设置事件处理-----------------------


function UIAutoBattle:OnSkillRollOver(e)
	local skillId = e.item and e.item.skillId;
	if not skillId then return; end
	TipsManager:ShowTips( TipsConsts.Type_Skill, { skillId = skillId }, TipsConsts.ShowType_Normal,
			TipsConsts.Dir_RightUp );
end

function UIAutoBattle:OnSkillRollOut()
	TipsManager:Hide();
end

function UIAutoBattle:OnSkillClick(e, skillCfgType)
	local skillId = e.item and e.item.skillId;
	local canSelected, failFlag = AutoBattleUtils:CheckCanSelected(skillId)
	if e.renderer.checkBox.selected and false == canSelected then
		e.renderer.checkBox.selected = false;
		e.renderer.data.selected = false;
		if failFlag == -1 then -- 连续技不能选中。
			FloatManager:AddNormal( StrConfig['autoBattle38'] )
		elseif failFlag == -2 then -- 灵阵技能不可选中
			FloatManager:AddNormal( StrConfig['autoBattle39'] )
		elseif failFlag == -3 then
			FloatManager:AddNormal("普通技能最多选中6个")
		elseif failFlag == -4 then
			FloatManager:AddNormal("特殊技能最多选中3个")
		end
		return;
	end
	-- add end
	local skillList = AutoBattleUtils:SkillsFromView(e.target);
	if skillCfgType == "specialSkillList" then
		for k, v in pairs(AutoBattleModel.specialSkillList) do
		if not SkillUtil:IsShortcutSkill(v.skillId) then
			table.push(skillList, v)
		end
	end
	end
	self:ChangeCfg( skillCfgType, skillList );
end

function UIAutoBattle:OnSkillSetClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local listNormal = objSwf.listSkillNormal
	if not listNormal then return; end
	local listSpecial = objSwf.listSkillSpecial
	if not listSpecial then return; end
	local skillType;
	if e.target == listNormal then
		skillType = AutoBattleConsts.Normal
	elseif e.target == listSpecial then
		skillType = AutoBattleConsts.Special
	end
	if not skillType then return; end
	UISkillShortCutSet:Open( e.renderer.index, e.renderer, SkillConsts.AutoBattle, skillType );
end

function UIAutoBattle:OnNsMonsterRangeChange()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:ChangeCfg( "findMonsterRange", objSwf.numStpMonsterRange.value );
end

function UIAutoBattle:OnAutoHangSelect(e)
	self:ChangeCfg( "autoHang", e.selected );
end

function UIAutoBattle:OnAutoCounterSelect(e)
	self:ChangeCfg( "autoCounter", e.selected );
end

function UIAutoBattle:OnAutoReviveSituSelect(e)
	self:ChangeCfg( "autoReviveSitu", e.selected );
end

function UIAutoBattle:OnNotActiveAttackBossSelect(e)
	self:ChangeCfg( "noActiveAttackBoss", e.selected );
end

--------------------拾取设置事件处理-----------------------

function UIAutoBattle:OnPickEquipSelect(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local disabled = not e.selected;
	objSwf.dmEquipProf.disabled = disabled;
	objSwf.dmEquipLvl.disabled = disabled;
	objSwf.dmEquipQuality.disabled = disabled;
	--
	self:ChangeCfg( "autoPickEquip", e.selected );
end

function UIAutoBattle:OnPickDrugSelect(e)
	self:ChangeCfg( "autoPickDrug", e.selected );
end

function UIAutoBattle:OnPickMoneySelect(e)
	self:ChangeCfg( "autoPickMoney", e.selected );
end

function UIAutoBattle:OnPickMaterialSelect(e)
	self:ChangeCfg( "autoPickMaterial", e.selected );
end

function UIAutoBattle:OnDmEquipProfChange(e)
	local equipProf = e.data.prof;
	self:ChangeCfg( "autoPickEquipProf", equipProf );
end

function UIAutoBattle:OnDmEquipLvlChange(e)
	local range = e.data.range;
	self:ChangeCfg( "autoPickEquipLvl", range );
end

function UIAutoBattle:OnDmEquipQualityChange(e)
	local quality = e.data.quality;
	self:ChangeCfg( "autoPickEquipQuality", quality );
end

--------------------主面板事件处理-------------------------

-- 点击关闭
function UIAutoBattle:OnBtnCloseClick()
	self:Hide();
end

function UIAutoBattle:ChangeCfg( name, value )
	if self.saved == false then
		AutoBattleModel:ChangeCfg(name, value)
	else
		self.saved = not AutoBattleModel:ChangeCfg(name, value);
	end
end

--点击保存设置
function UIAutoBattle:OnBtnSaveClick()
	self:Save();
end

--保存
function UIAutoBattle:Save()
	--写入本地文件
	AutoBattleController:SaveAutoBattleSetting();
	--
	self.saved = true;
end

--点击恢复默认
function UIAutoBattle:OnBtnDefaultClick()
	AutoBattleController:UseDefaultSetting();
end

--开始/取消 挂机
function UIAutoBattle:OnBtnStartHangClick(e)
	AutoBattleController:SetAutoHang();
	-- 点击开启挂机，关闭面板
	if AutoBattleController.isAutoHang then
		self:Hide();
	end
end

--根据挂机状态切换显示 1.btn开始/取消 2.主界面挂机中
function UIAutoBattle:SwitchHang(hanging)
	UIAutoBattleIndicator:SwitchHang(hanging);
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if hanging then
		objSwf.btnStartHang.label = StrConfig['autoBattle37'];
	else
		objSwf.btnStartHang.label = StrConfig['autoBattle36'];
	end
end

-------------------消息处理--------------------------------
--处理消息
function UIAutoBattle:HandleNotification(name, body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end

	if name == NotifyConsts.AutoBattleSetInvalidate then
		self:UpdateShow();
	elseif name == NotifyConsts.AutoBattleNormalSkillAdded or name == NotifyConsts.AutoBattleNormalSkillRemoved then
		self:UpdateNormalSkillList(objSwf);
	elseif name == NotifyConsts.AutoBattleSpecialSkillAdded or name == NotifyConsts.AutoBattleSpecialSkillRemoved then
		self:UpdateSpecialSkillList(objSwf);
	elseif name == NotifyConsts.AutoBattleCfgChange then
		if body.cfgName == "takeDrugHp" then
			self:OnTakeDrugHpChange(body.value);
		elseif body.cfgName == "takeDrugMp" then
			self:OnTakeDrugMpChange(body.value);
		end
	elseif name == NotifyConsts.TianShenUpdate then
		self:ShowTianShenSkill(objSwf)
	else
		self:UpdateSpecialSkillList(objSwf)
	end
end

--监听的消息
function UIAutoBattle:ListNotificationInterests()
	return {
		NotifyConsts.AutoBattleSetInvalidate,
		NotifyConsts.AutoBattleNormalSkillAdded,
		NotifyConsts.AutoBattleNormalSkillRemoved,
		NotifyConsts.AutoBattleSpecialSkillAdded,
		NotifyConsts.AutoBattleSpecialSkillRemoved,
		NotifyConsts.AutoBattleCfgChange,
		NotifyConsts.SkillShortCutRefresh,
		NotifyConsts.SkillShortCutChange,
		NotifyConsts.TianShenUpdate,
	};
end

function UIAutoBattle:OnTakeDrugHpChange(value)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.sliderHp.value = value;
	self:UpdateTxtPer(objSwf.txtHp, value);
end

---------------------public functions---------------------

--设置普通技能
--@param index : 技能在列表中的index
function UIAutoBattle:SetNormalSkill(index, skillId)
	local objSwf = self.objSwf;
	local listSkillNormal = objSwf and objSwf.listSkillNormal;
	if not listSkillNormal then return; end
	self:SetSkill( listSkillNormal, index, skillId );
	local skillList = AutoBattleUtils:SkillsFromView(listSkillNormal);
	self:ChangeCfg( "normalSkillList", skillList );
end

--设置特殊技能
--@param index : 技能在列表中的index
function UIAutoBattle:SetSpecialSkill(index, skillId)
	local objSwf = self.objSwf;
	local listSkillSpecial = objSwf and objSwf.listSkillSpecial;
	if not listSkillSpecial then return; end
	self:SetSkill( listSkillSpecial, index, skillId );
	local skillList = AutoBattleUtils:SkillsFromView(listSkillSpecial);
	for k, v in pairs(AutoBattleModel.specialSkillList) do
		if not SkillUtil:IsShortcutSkill(v.skillId) then
			table.push(skillList, v)
		end
	end
	self:ChangeCfg( "specialSkillList", skillList );
end


---------------------private functions----------------------

--设置技能
--@param listSkill : 显示技能的列表组件(com.mars.autoBattle.AutoBattleSkillList)
--@param index : 技能在列表中的index
function UIAutoBattle:SetSkill(listSkill, index, skillId)
	--即将填入格子的新的技能数据
	local newVO = {};
	--目标格子中原来的技能数据
	local oldVO = {};

	local renderer = listSkill.renderers[index];
	if not renderer then return; end
	-- --保存目标格子原来的数据
	local oldData  = renderer.data;
	if oldData then
		oldVO.skillId  = oldData.skillId;
		if oldData.skillId == skillId then return; end
		oldVO.iconUrl  = oldData.iconUrl;
		oldVO.selected = oldData.selected;
	end
	-- 查找其他格子，如果新设置的技能在其他的格子中，将这个格子设置为目标格子的原数据
	for i = 0, (AutoBattleConsts.NumSkill - 1) do
		if i ~= index then
			local oRenderer = listSkill.renderers[i];
			local data = oRenderer and oRenderer.data;
			--如果查找到，交换两个格子中的技能
			if data and data.skillId == skillId then
				--将目标格子设置为原格子中的技能
				newVO.skillId  = data.skillId;
				newVO.iconUrl  = data.iconUrl;
				newVO.selected = data.selected;
				renderer:setData( UIData.encode(newVO) );
				--将原格子设置为目标格子的原技能
				oRenderer:setData( UIData.encode(oldVO) );
				--
				return;
			end
		end
	end
	--如果没有查找到，将目标格子设置为新的数据
	newVO.skillId  = skillId;
	local cfg   = t_skill[skillId];
	newVO.iconUrl  = cfg and ResUtil:GetSkillIconUrl(cfg.icon);
	newVO.selected = true;
	renderer:setData( UIData.encode(newVO) );
	--
end