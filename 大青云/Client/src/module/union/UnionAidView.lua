--[[
	帮派加持
	2014年12月30日, PM 05:14:52
	wangyanwei
]]

_G.UIUnionAidPanel = BaseUI:new("UIUnionAidPanel");

function UIUnionAidPanel:Create()
	self:AddSWF("unionAidPanel.swf", true, 'center');
end

function UIUnionAidPanel:OnLoaded(objSwf)
	objSwf.btn_close.click = function () self:Hide(); end
	objSwf.btn_upLevel.label = StrConfig['union161'];
	objSwf.btn_bap.label = StrConfig['union162'];
	objSwf.txt_add.text = StrConfig['union155'];

	objSwf.nextLevelPanel._visible = false;
	objSwf.nextPanel._visible = false;
	
	objSwf.upLevel._visible = false;
	objSwf.upLevel.txt_upLevel.text = StrConfig['union200'];
	objSwf.upLevel.txt_needlevel.text = StrConfig['union201'];
	objSwf.upLevel.txt_needGX.text = StrConfig['union202'];
	objSwf.aidTip._visible = false;
	objSwf.aidTip.txt_aid.text = StrConfig["union203"];
	objSwf.aidTip.txt_needGX.text = StrConfig["union202"];
	objSwf.btn_tip.rollOver = function () TipsManager:ShowBtnTips(StrConfig['union300'],TipsConsts.Dir_RightDown); end
	objSwf.btn_tip.rollOut = function () TipsManager:Hide(); end
end

function UIUnionAidPanel:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	UnionController:ReqAidInfo();
end

--刷新界面上面的信息
UIUnionAidPanel.panelState = 0;   --0是升级状态    1是洗炼状态
function UIUnionAidPanel:OnUpDateAidInfo(obj)
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:OnShowAidNum(obj);
	local cfg = t_guildwash[obj.aidLevel];
	objSwf.btn_upLevel.click = function () self:UnionAidClickLevel(obj.aidLevel) end -- 点击升级跟保存的按钮
	objSwf.btn_upLevel.rollOver = function () self:OnOverAidUpLevel(); end -- 移入升级按钮
	objSwf.btn_upLevel.rollOut = function () self:OnoutAidUplevel() end -- 移出升级按钮

	objSwf.btn_upLevel.label = StrConfig['union161'];
	
	objSwf.btn_bap.click = function () self:UnionBapClickHandler(obj.aidLevel) end -- 点击洗炼按钮
	objSwf.btn_bap.rollOver = function () 
		if UnionModel.MyUnionInfo.contribution >= cfg.washcost then
			objSwf.aidTip.txt_needGXNum.htmlText = cfg.washcost .. StrConfig['union210'];
		else
			objSwf.aidTip.txt_needGXNum.htmlText = cfg.washcost .. StrConfig['union211'];
		end
		objSwf.aidTip._visible = true; 
	end -- 点击洗炼按钮
	objSwf.btn_bap.rollOut = function () objSwf.aidTip._visible = false; end -- 点击洗炼按钮
end

--显示属性文本
function UIUnionAidPanel:OnShowAidNum(obj)
	local objSwf = self.objSwf;
	local cfg = t_guildwash[obj.aidLevel];
	if not cfg then 
		cfg = {};
		cfg.expadd = 0;
		cfg.moneyadd = 0;
		cfg.zazenadd = 0;
	end
	objSwf.txt_1.htmlText = string.format(StrConfig['union151'],obj.aidLevel);
	objSwf.txt_2.htmlText = string.format(StrConfig['union152'],cfg.expadd);
	objSwf.txt_3.htmlText = string.format(StrConfig['union153'],cfg.moneyadd);
	objSwf.txt_4.htmlText = string.format(StrConfig['union154'],cfg.zazenadd);
	objSwf.txt_5.htmlText = string.format(StrConfig['union157'],obj.att);
	objSwf.txt_6.htmlText = string.format(StrConfig['union158'],obj.def);
	objSwf.txt_7.htmlText = string.format(StrConfig['union159'],obj.maxhp);
	objSwf.txt_8.htmlText = string.format(StrConfig['union160'],obj.cri);
	objSwf.maxPanel.max_1.htmlText = string.format(StrConfig['union165'],cfg.atkmax);
	objSwf.maxPanel.max_2.htmlText = string.format(StrConfig['union165'],cfg.defmax);
	objSwf.maxPanel.max_3.htmlText = string.format(StrConfig['union165'],cfg.hpmax);
	objSwf.maxPanel.max_4.htmlText = string.format(StrConfig['union165'],cfg.subdefmax);
end
--返回洗炼的属性
function UIUnionAidPanel:UnionAidInfoHandler(obj)
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	self.panelState = 1 ;  --将按钮状态调为保存状态
	objSwf.btn_upLevel.label = StrConfig['union163'];
	
	objSwf.nextPanel._visible = true;
	
	self:OnShowUpDownHandler(obj)  --烦烦烦呐发难烦烦
	
	for i = 1 , 4 do
		objSwf.nextPanel['mc_' .. i].txt_maxNum.htmlText = "";
	end
end

--升级事件
function UIUnionAidPanel:UnionAidClickLevel(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local cfg = {};
	local nextCfg = {};
	
	if index ~= nil  then
		cfg = t_guildwash[index];          --所处于第几阶段的表
		nextCfg = t_guildwash[index + 1];
	end
	
	local contribution = UnionModel.MyUnionInfo.contribution; --自己在帮派的贡献
	
	if self.panelState == 0 then  --界面状态  0是在出于升级状态， 1是出于洗炼状态
		if UnionModel.MyUnionInfo.level < nextCfg.guildlv then
			FloatManager:AddNormal( StrConfig["union251"] );
			return 
		end	
		if contribution >= cfg.lvconst then
			UnionController:ReqAidUpLevel();
		else
			FloatManager:AddNormal( StrConfig["union252"] );
		end
	else
		UnionController:ReqClearBapAidInfo(1)
		self.panelState = 0 ;  --切换到升级状态
		self:OnOverAidUpLevel();
	end
end	

--洗炼事件
function UIUnionAidPanel:UnionBapClickHandler(index)
	local cfg = t_guildwash[index];
	local contribution = UnionModel.MyUnionInfo.contribution;
	if contribution >= cfg.washcost then
		UnionController:ReqUnionBapAid();
	else
		FloatManager:AddNormal( StrConfig["union253"] );
	end
end

--升级移入事件
function UIUnionAidPanel:OnOverAidUpLevel()
	--如果是0 就是升级状态 移入框可显
	local objSwf = self.objSwf;
	if self.panelState == 0 then
		objSwf.nextPanel._visible = true;
		local lv = UnionModel.aidInfo.aidLevel;
		local cfg = t_guildwash[lv + 1];
		if not cfg then
			objSwf.nextPanel._visible = false;
			return 
		else
			for i = 1 , 4 do
				objSwf.nextPanel['mc_' .. i].mc_down._visible = false;
				objSwf.nextPanel['mc_' .. i].mc_up._visible = true;
			end
			objSwf.nextPanel.mc_1.txt_lastNum.htmlText = string.format(StrConfig['union157'],cfg.atkadd);
			objSwf.nextPanel.mc_1.txt_maxNum.htmlText = string.format(StrConfig['union165'],cfg.atkmax);
			objSwf.nextPanel.mc_2.txt_lastNum.htmlText = string.format(StrConfig['union158'],cfg.defadd);
			objSwf.nextPanel.mc_2.txt_maxNum.htmlText = string.format(StrConfig['union165'],cfg.defmax);
			objSwf.nextPanel.mc_3.txt_lastNum.htmlText = string.format(StrConfig['union159'],cfg.hpadd);
			objSwf.nextPanel.mc_3.txt_maxNum.htmlText = string.format(StrConfig['union165'],cfg.hpmax);
			objSwf.nextPanel.mc_4.txt_lastNum.htmlText = string.format(StrConfig['union160'],cfg.subdefadd);
			objSwf.nextPanel.mc_4.txt_maxNum.htmlText = string.format(StrConfig['union165'],cfg.subdefmax);
			
			objSwf.nextLevelPanel._visible = true;
			objSwf.nextLevelPanel.mc_1.txt_lastNum.htmlText = string.format(StrConfig['union215'],cfg.lv);
			objSwf.nextLevelPanel.mc_2.txt_lastNum.htmlText = string.format(StrConfig['union164'],cfg.expadd);
			objSwf.nextLevelPanel.mc_3.txt_lastNum.htmlText = string.format(StrConfig['union164'],cfg.moneyadd);
			objSwf.nextLevelPanel.mc_4.txt_lastNum.htmlText = string.format(StrConfig['union164'],cfg.zazenadd);
		end
	--	txt_levelNum	txt_needGXNum
		objSwf.upLevel._visible = true;
		if UnionModel.MyUnionInfo.level >= cfg.guildlv then
			objSwf.upLevel.txt_levelNum.htmlText = string.format(StrConfig['union215'],cfg.lv) .. StrConfig['union210'];
		else
			objSwf.upLevel.txt_levelNum.htmlText = string.format(StrConfig['union215'],cfg.lv) .. StrConfig['union211'];
		end
		
		if UnionModel.MyUnionInfo.contribution >= cfg.lvconst then
			objSwf.upLevel.txt_needGXNum.htmlText = cfg.lvconst .. StrConfig['union210'];
		else
			objSwf.upLevel.txt_needGXNum.htmlText = cfg.lvconst .. StrConfig['union211'];
		end
	end
end

--升级移出事件
function UIUnionAidPanel:OnoutAidUplevel()
	local objSwf = self.objSwf;
	if self.panelState == 0 then
		objSwf.nextPanel._visible = false;
		objSwf.nextLevelPanel._visible = false;
		objSwf.upLevel._visible = false;
	end
end

--打开面板
function UIUnionAidPanel:OpenPanel()
	if self:IsShow() then
		self:Hide();
	end
	self:Show();
end

--关闭面板
function UIUnionAidPanel:OnHide()
	self.panelState = 0 ;
	UnionController:ReqClearBapAidInfo(0);
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.nextPanel._visible = false;
end

--烦呐发难烦呐
function UIUnionAidPanel:OnShowUpDownHandler(obj)
	local objSwf = self.objSwf;
	if obj.att > UnionModel.aidInfo.att then
		objSwf.nextPanel.mc_1.txt_lastNum.htmlText = string.format(StrConfig['union181'],math.abs(UnionModel.aidInfo.att - obj.att));
		objSwf.nextPanel.mc_1.mc_up._visible = true;
		objSwf.nextPanel.mc_1.mc_down._visible = false;
	elseif obj.att == UnionModel.aidInfo.att then
		objSwf.nextPanel.mc_1.mc_up._visible = false;
		objSwf.nextPanel.mc_1.mc_down._visible = false;
		objSwf.nextPanel.mc_1.txt_lastNum.htmlText = '_';
	else
		objSwf.nextPanel.mc_1.txt_lastNum.htmlText = string.format(StrConfig['union180'],math.abs(UnionModel.aidInfo.att - obj.att));
		objSwf.nextPanel.mc_1.mc_up._visible = false;
		objSwf.nextPanel.mc_1.mc_down._visible = true;
	end
	
	if obj.def > UnionModel.aidInfo.def then
		objSwf.nextPanel.mc_2.txt_lastNum.htmlText = string.format(StrConfig['union181'],math.abs(UnionModel.aidInfo.def - obj.def));
		objSwf.nextPanel.mc_2.mc_up._visible = true;
		objSwf.nextPanel.mc_2.mc_down._visible = false;
	elseif obj.def == UnionModel.aidInfo.def then
		objSwf.nextPanel.mc_2.mc_up._visible = false;
		objSwf.nextPanel.mc_2.mc_down._visible = false;
		objSwf.nextPanel.mc_2.txt_lastNum.htmlText = '_';
	else
		objSwf.nextPanel.mc_2.txt_lastNum.htmlText = string.format(StrConfig['union180'],math.abs(UnionModel.aidInfo.def - obj.def));
		objSwf.nextPanel.mc_2.mc_up._visible = false;
		objSwf.nextPanel.mc_2.mc_down._visible = true;
	end
	
	if obj.maxhp > UnionModel.aidInfo.maxhp then
		objSwf.nextPanel.mc_3.txt_lastNum.htmlText = string.format(StrConfig['union181'],math.abs(UnionModel.aidInfo.maxhp - obj.maxhp));
		objSwf.nextPanel.mc_3.mc_up._visible = true;
		objSwf.nextPanel.mc_3.mc_down._visible = false;
	elseif obj.maxhp == UnionModel.aidInfo.maxhp then
		objSwf.nextPanel.mc_3.mc_up._visible = false;
		objSwf.nextPanel.mc_3.mc_down._visible = false;
		objSwf.nextPanel.mc_3.txt_lastNum.htmlText = '_';
	else
		objSwf.nextPanel.mc_3.txt_lastNum.htmlText = string.format(StrConfig['union180'],math.abs(UnionModel.aidInfo.maxhp - obj.maxhp));
		objSwf.nextPanel.mc_3.mc_up._visible = false;
		objSwf.nextPanel.mc_3.mc_down._visible = true;
	end
	
	if obj.cri > UnionModel.aidInfo.cri then
		objSwf.nextPanel.mc_4.txt_lastNum.htmlText = string.format(StrConfig['union181'],math.abs(UnionModel.aidInfo.cri - obj.cri));
		objSwf.nextPanel.mc_4.mc_up._visible = true;
		objSwf.nextPanel.mc_4.mc_down._visible = false;
	elseif obj.cri == UnionModel.aidInfo.cri then
		objSwf.nextPanel.mc_4.mc_up._visible = false;
		objSwf.nextPanel.mc_4.mc_down._visible = false;
		objSwf.nextPanel.mc_4.txt_lastNum.htmlText = '_';
	else
		objSwf.nextPanel.mc_4.txt_lastNum.htmlText = string.format(StrConfig['union180'],math.abs(UnionModel.aidInfo.cri - obj.cri));
		objSwf.nextPanel.mc_4.mc_up._visible = false;
		objSwf.nextPanel.mc_4.mc_down._visible = true;
	end
end
function UIUnionAidPanel:GetPanelType()
	return 0;
end

function UIUnionAidPanel:ESCHide()
	return true;
end

-----------------------------------------------------------------------------------
------------------------------        UI      -------------------------------------
-----------------------------------------------------------------------------------
--侦听人物等级开启新的珍宝阁
function UIUnionAidPanel:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.UnionAidInfoUpDate then	--返回了加持属性（打开面板返回）
		self:OnUpDateAidInfo(body);
	elseif name == NotifyConsts.UnionAidLevelUpDate then  --升级
		self:OnShowAidNum(body)
	elseif name == NotifyConsts.UnionAidInfo then --返回洗炼
		self:UnionAidInfoHandler(body);
	end
	
end
function UIUnionAidPanel:ListNotificationInterests()
	return {
		NotifyConsts.UnionAidInfoUpDate,NotifyConsts.UnionAidLevelUpDate,
		NotifyConsts.UnionAidInfo
	}
end