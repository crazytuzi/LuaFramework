--[[
	2015年12月11日15:11:32
	wangyanwei
	翅膀升星
]]

_G.UIWingStarUp = BaseUI:new('UIWingStarUp');

function UIWingStarUp:Create()
	self:AddSWF('wingStarLevelUpPanel.swf',true,'center');
end

function UIWingStarUp:OnLoaded(objSwf)

	objSwf.tf_1.text = UIStrConfig['wingstarup1'];
	objSwf.tf_2.text = UIStrConfig['wingstarup2'];
	objSwf.btn_staritem.rollOver = function () self:WingStarItemOver(); end
	objSwf.btn_staritem.rollOut = function () TipsManager:Hide(); end
	
	objSwf.numProgress1.loadComplete = function () self:NumProgressLoaded(); end
	
	objSwf.btn_starUp.click = function () self:CloseAutoStar(); self:OnWingStarUpClick(); end
	objSwf.btn_starUp.rollOver = function () self:NexWingStarAttr(); end
	objSwf.btn_starUp.rollOut = function () self:HideNexAttr(); end
	
	-- for i = 1 , 5 do
		-- objSwf['skill' .. i]._visible = false;
	-- end
	for i = 1 , 7 do
		objSwf['txt_up' .. i]._visible = false;
	end
	objSwf.txt_addfight._visible = false;
	
	objSwf.btn_autoStarUp.click = function () self:AutoStarUpClick(); end
	objSwf.btn_autoStarUp.rollOver = function () self:NexWingStarAttr(); end
	objSwf.btn_autoStarUp.rollOut = function () self:HideNexAttr(); end
	
	objSwf.nameload.loaded = function () objSwf.nameload._x = objSwf.mc_p._x - objSwf.nameload._width / 2; end
end

function UIWingStarUp:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_autoStarUp.label = UIStrConfig['wingstarup4'];
	self:ShowWingStarData();
	self:ShowAddInfoTxt();
	self:ShowStarUpItem();
	self:DrawWing();
end

--自动升星
UIWingStarUp.autoStarUp = false;
function UIWingStarUp:AutoStarUpClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	for i = 1 , 7 do
		objSwf['txt_up' .. i]._visible = false;
	end
	self.autoStarUp = not self.autoStarUp;
	if not self.autoStarUp then
		self:CloseAutoStar();
		return
	end
	
	local wingStarLevel = WingStarUpModel:GetWingStarLevel();
	if not wingStarLevel then wingStarLevel = 1 end
	local cfg = t_wingequip[wingStarLevel + 1];
	if not cfg then cfg = t_wingequip[#t_wingequip]; end
	local starItemCfg = split(cfg.starItem,',');
	local itemCfg = t_item[toint(starItemCfg[1])];
	if not itemCfg then self.autoStarUp = false; return end
	local bgItemNum = BagModel:GetItemNumInBag(itemCfg.id);
	if bgItemNum < toint(starItemCfg[2]) then  --道具不足
		FloatManager:AddNormal(StrConfig['wingstarup100']);
		self.autoStarUp = false;
		return
	end
	if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < cfg.gold then	--金钱不足
		FloatManager:AddNormal(StrConfig['wingstarup100']);
		self.autoStarUp = false;
		return 
	end
	
	objSwf.btn_autoStarUp.label = UIStrConfig['wingstarup5'];
	local func = function ()
		self:OnWingStarUpClick();
	end
	self.timeKey = TimerManager:RegisterTimer(func,300);
end

--关闭自动升星
function UIWingStarUp:CloseAutoStar()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	objSwf.btn_autoStarUp.label = UIStrConfig['wingstarup4'];
	self.autoStarUp = false;
end

--下阶段星级属性
function UIWingStarUp:NexWingStarAttr()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local nexAttrList = WingStarUtil:GetNextWingStarAttr();
	if not nexAttrList then return end
	for i = 1 , 7 do
		local attrName = objSwf['txt_' .. i].textName;
		for attrIndex , attrStr in pairs(enAttrTypeName) do
			if attrStr == attrName then
				local attr = self:GetInfoName(attrIndex);
				if nexAttrList[attr] then
					objSwf['txt_up' .. i]._visible = true;
					objSwf['txt_up' .. i].textField.text = getAtrrShowVal(attrIndex,nexAttrList[attr]) ;
				end
			end
		end
	end
	objSwf.txt_addfight._visible = true;
	local fight = 0;
	if not nexAttrList then 
		objSwf.numFight.num = fight;
	else
		nexAttrList = self:OnSortNum(nexAttrList);
		fight = EquipUtil:GetFight(nexAttrList);
	end
	objSwf.txt_addfight.textField.text = fight;
end

function UIWingStarUp:HideNexAttr()
	local objSwf = self.objSwf;
	if not objSwf then return end
	for i = 1 , 7 do
		objSwf['txt_up' .. i]._visible = false;
	end
	objSwf.txt_addfight._visible = false;
end

--强化点击
function UIWingStarUp:OnWingStarUpClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	for i = 1 , 7 do
		objSwf['txt_up' .. i]._visible = false;
	end
	objSwf.txt_addfight._visible = false;
	local wingStarLevel = WingStarUpModel:GetWingStarLevel();
	if not wingStarLevel then wingStarLevel = 1 end
	local cfg = t_wingequip[wingStarLevel + 1];
	if not cfg then cfg = t_wingequip[#t_wingequip]; end
	local starItemCfg = split(cfg.starItem,',');
	local itemCfg = t_item[toint(starItemCfg[1])];
	if not itemCfg then self:CloseAutoStar(); return end
	local bgItemNum = BagModel:GetItemNumInBag(itemCfg.id);
	if bgItemNum < toint(starItemCfg[2]) then  --道具不足
		FloatManager:AddNormal(StrConfig['wingstarup100']);
		self:CloseAutoStar();
		return
	end
	if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < cfg.gold then	--金钱不足
		FloatManager:AddNormal(StrConfig['wingstarup101']);
		self:CloseAutoStar();
		return 
	end
	WingController:OnSendWingStarUp();
end

--显示进度星级
function UIWingStarUp:ShowWingStarData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local wingStarLevel = WingStarUpModel:GetWingStarLevel();
	if not wingStarLevel then wingStarLevel = 0; end
	local cfg = t_wingequip[wingStarLevel + 1];
	if not cfg then cfg = t_wingequip[#t_wingequip]; end
	local progressNum = WingStarUpModel:GetWingStarProgress();
	
	for i = 1 , 10 do
		if wingStarLevel >= i then
			objSwf['star_' .. i]._visible = true;
		else
			objSwf['star_' .. i]._visible = false;
		end
	end
	
	if not progressNum then progressNum = 0 ; end
	objSwf.siPro.maximum = cfg.maxVal;
	objSwf.siPro.value = progressNum;
	
	objSwf.numProgress1.num = progressNum;
	objSwf.numProgress2.num = cfg.maxVal;
	if wingStarLevel == t_wingequip[#t_wingequip].level then
		objSwf.siPro.value = cfg.maxVal;
		objSwf.numProgress1.num = cfg.maxVal;
	end
	
	if wingStarLevel >= t_wingequip[#t_wingequip].level and progressNum >= t_wingequip[#t_wingequip].maxVal then
		objSwf.btn_starUp.visible = false;
		objSwf.btn_autoStarUp.visible = false;
	end
	
	
	local wingCfg = WingStarUtil:GetInWingCfg();
	
	objSwf.nameload.source = ResUtil:GetWingHeChengName(wingCfg.nameicon);
	objSwf.num_jie.num = wingCfg.level;
end

function UIWingStarUp:OnFightNum()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local attrList = WingStarUtil:GetAllWingStarAttr();
	local fight = 0;
	if not attrList then 
		objSwf.numFight.num = fight;
	else
		attrList = self:OnSortNum(attrList);
		fight = EquipUtil:GetFight(attrList);
	end
	objSwf.numFight.num = fight;
	objSwf.numFight.loadComplete = function ()
		objSwf.numFight._x = objSwf.mc_fightfloor._x - objSwf.numFight._width / 2 ;
	end
end

function UIWingStarUp:OnSortNum(attrList)
	local vo = {};
	for i , v in pairs (attrList) do
		local cfg = {};
		cfg.type = nil;
		for str , id in pairs(AttrParseUtil.AttMap) do
			if str == i then
				cfg.type = id;
				break;
			end
		end
		cfg.val = v ;
		table.push(vo,cfg);
	end
	return vo
end

function UIWingStarUp:NumProgressLoaded()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.numProgress1._x = objSwf.mc_p._x - objSwf.numProgress1.width;
end

--升星移入效果
function UIWingStarUp:WingStarItemOver()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not self.starUpItemId then return end
	local itemCfg = t_item[self.starUpItemId];
	if not itemCfg then return end
	TipsManager:ShowItemTips(itemCfg.id);
end

--升星道具
UIWingStarUp.starUpItemId = nil;
function UIWingStarUp:ShowStarUpItem()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local wingStarLevel = WingStarUpModel:GetWingStarLevel();
	if wingStarLevel == t_wingequip[#t_wingequip].level then
		objSwf.btn_starUp.visible = false;
		objSwf.btn_autoStarUp.visible = false;
		objSwf.tf_1._visible = false;
		objSwf.tf_2._visible = false;
		objSwf.btn_staritem.visible = false;
		objSwf.txt_money._visible = false;
		objSwf.icon_end._visible = true;
		return
	end
	objSwf.icon_end._visible = false;
	if not wingStarLevel then wingStarLevel = 0 end
	local cfg = t_wingequip[wingStarLevel + 1];
	if not cfg then cfg = t_wingequip[#t_wingequip] end
	local starItemCfg = split(cfg.starItem,',');
	local itemCfg = t_item[toint(starItemCfg[1])];
	if not itemCfg then return end
	self.starUpItemId = itemCfg.id;
	
	local bgItemNum = BagModel:GetItemNumInBag(itemCfg.id);
	if bgItemNum >= toint(starItemCfg[2]) then
		objSwf.btn_staritem.htmlLabel = string.format(StrConfig['wingstarup001'],'#00ff00',itemCfg.name .. starItemCfg[2]);
	else
		objSwf.btn_staritem.htmlLabel = string.format(StrConfig['wingstarup001'],'#ff0000',itemCfg.name .. starItemCfg[2]);
	end
	
	if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < cfg.gold then
		objSwf.txt_money.htmlText = string.format("<font color='#ff0000'>%s</font>",cfg.gold);
	else
		objSwf.txt_money.htmlText = string.format("<font color='#00ff00'>%s银两</font>",cfg.gold);
	end
end

--属性文本
function UIWingStarUp:ShowAddInfoTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local wingStarLevel = WingStarUpModel:GetWingStarLevel();
	if not wingStarLevel or wingStarLevel == 0 then wingStarLevel = 1 end
	local attrStr = WingStarUtil:GetWingStarAttrStr();
	if not attrStr then return end
	for i , v in ipairs(attrStr) do
		local vo = split(v,',');
		local attMapStr = AttrParseUtil.AttMap[vo[1]];
		if attMapStr then
			local attrName = enAttrTypeName[attMapStr]
			if objSwf['txt_' .. i] then
				local txtStr = StrConfig['wingstarup_' .. vo[1]]
				if txtStr then
					objSwf['txt_' .. i].text = txtStr;
				else
					objSwf['txt_' .. i].text = attrName .. ':';
				end
				objSwf['txt_' .. i].textName = attrName;
			end
		end
	end
	
	local attrList = WingStarUtil:GetAllWingStarAttr();
	if not attrList or attrList == {} then
		for i = 1 , 7 do
			if i <= #attrStr then
				objSwf['txt_add' .. i]._visible = true;
				objSwf['txt_add' .. i].text = '0';
			else
				objSwf['txt_add' .. i]._visible = false;
			end
		end
	else
		for i = 1 , 7 do
			local attrName = objSwf['txt_' .. i].textName;
			for attrIndex , attrStr in pairs(enAttrTypeName) do
				if attrStr == attrName then
					local attr = self:GetInfoName(attrIndex);
					if attrList[attr] then
						objSwf['txt_add' .. i].text = getAtrrShowVal(attrIndex,attrList[attr]) ;
					end
				end
			end
			if objSwf['txt_add' .. i].text == '' then
				objSwf['txt_add' .. i]._visible = false;
			end
		end
	end
	
	self:OnFightNum();			--计算战斗力
	
	local wingStarLevel = WingStarUpModel:GetWingStarLevel();
	if not wingStarLevel or wingStarLevel == 0 then
		objSwf.num_star.visible = false;
	else
		objSwf.num_star.visible = true;
		objSwf.num_star.num = '+' .. wingStarLevel;
	end
	
end

--根据汉字属性名称获取英文属性字段
function UIWingStarUp:GetInfoName(attrName)
	for attr , v in pairs(AttrParseUtil.AttMap) do
		if v == attrName then
			return attr;
		end
	end
end


function UIWingStarUp:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self:CloseAutoStar();
	local objSwf = self.objSwf;
	if not objSwf then return end
	for i = 1 , 7 do
		objSwf['txt_up' .. i]._visible = false;
	end
	objSwf.txt_addfight._visible = false;
end

--进度条缓动  1：tween  2：升星直接清空后在tween
function UIWingStarUp:OnTweenProgress(_type)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local wingStarLevel = WingStarUpModel:GetWingStarLevel();
	if not wingStarLevel then wingStarLevel = 0; end
	local cfg = t_wingequip[wingStarLevel + 1];
	if not cfg then cfg = t_wingequip[#t_wingequip]; end
	local progressNum = WingStarUpModel:GetWingStarProgress();
	if _type == 1 then
		objSwf.siPro:tweenProgress( progressNum , cfg.maxVal )
	else
		-- objSwf.siPro.maximum = cfg.maxVal;
		objSwf.siPro:setProgress( progressNum , cfg.maxVal );
	end
	
	objSwf.numProgress1.num = progressNum;
	objSwf.numProgress2.num = cfg.maxVal;
	
	local wingStarLevel = WingStarUpModel:GetWingStarLevel();
	if not wingStarLevel then wingStarLevel = 0 end
	for i = 1 , 10 do
		if wingStarLevel >= i then
			objSwf['star_' .. i]._visible = true;
		else
			objSwf['star_' .. i]._visible = false;
		end
	end
end

local viewWingHeChengPort;
function UIWingStarUp:DrawWing()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local wingItemList = BagUtil:GetBagItemList(BagConsts.BagType_RoleItem,BagConsts.ShowType_All);
	local wingID = nil;
	for i , v in pairs(wingItemList) do
		for j , k in pairs(t_wing) do
			if v.tid == k.itemId and k.itemId ~= 0 then
				wingID = k.id;
				break
			end
		end
	end
	if not wingID then wingID = 1001; end
	local wingCfg = t_wing[wingID];
	if not wingCfg then return end
	
	if not self.objUIDraw then
		if not viewWingHeChengPort then viewWingHeChengPort = _Vector2.new(1279, 732); end
		self.objUIDraw = UISceneDraw:new( "UIWingStarUp", objSwf.load_wing, viewWingHeChengPort);
	end
	self.objUIDraw:SetUILoader(objSwf.load_wing);
	
	self.objUIDraw:SetScene( wingCfg.ui_sen, function()
		local aniName = wingCfg.show_san;
		if not aniName or aniName == "" then return end
		if not wingCfg.ui_node then return end
		local nodeName = split(wingCfg.ui_node, "#")
		if not nodeName or #nodeName < 1 then return end
			
		for k,v in pairs(nodeName) do
			self.objUIDraw:NodeAnimation( v, aniName );
		end
	end );
	self.objUIDraw:SetDraw( true );
end

--进度飘字
function UIWingStarUp:TweenProgressStr(addprogress)
	local objSwf = self.objSwf;
	if not objSwf then return end
	print(addprogress)
	local tipStr = string.format(StrConfig["wingstarup105"], addprogress);
	print(tipStr)
	FloatManager:AddNormal( tipStr , objSwf.mc_p);
end

--消息处理
function UIWingStarUp:HandleNotification(name,body)
	if name == NotifyConsts.WingStarLevelUp then	--升级
		self:CloseAutoStar();
		self:OnTweenProgress(2);
		self:ShowAddInfoTxt();
		self:ShowStarUpItem();
		self:ShowWingStarData();
	elseif name == NotifyConsts.WingStarUpData then--进度刷新
		if body and body.result then
			self:CloseAutoStar();
			return 
		end
		self:OnTweenProgress(1);
		self:TweenProgressStr(body.addprogress);
	elseif name == NotifyConsts.BagItemNumChange then
		if body.id == self.starUpItemId then
			self:ShowStarUpItem();
		end
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold then
			self:ShowStarUpItem();
		end
	end
end

-- 消息监听
function UIWingStarUp:ListNotificationInterests()
	return {
			NotifyConsts.WingStarLevelUp,
			NotifyConsts.WingStarUpData,
			NotifyConsts.BagItemNumChange,
			NotifyConsts.PlayerAttrChange,
			}
end