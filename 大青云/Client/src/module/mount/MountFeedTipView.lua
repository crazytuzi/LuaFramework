--[[坐骑喂养Tip界面
zhangshuhui
2015年3月27日15:20:20
]]

_G.UIMountFeedTip = BaseUI:new("UIMountFeedTip");
UIMountFeedTip.type = 0;
UIMountFeedTip.levelShow = 10;
function UIMountFeedTip:Create()
	self:AddSWF("mountFeedTip.swf", true, "top")
end

function UIMountFeedTip:OnLoaded(objSwf)
	--特效框
	objSwf.qualityLoader.loaded = function()
									local effect = objSwf.qualityLoader.content.slotQuality;
									if effect then
										effect._x = 27;
										effect._y = 27;
										--effect:playEffect(0);
									end
								end
end

--显示Tip
function UIMountFeedTip:OnShow()
	self:ShowFeedInfo();
	self:UpdatePos();
end

--显示Tip
function UIMountFeedTip:OpenPanel(type)
	self.type = type;
	if self:IsShow() then
		self:ShowFeedInfo();
		self:UpdatePos();
	else
		self:Show();
	end
end

function UIMountFeedTip:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local monsePos = _sys:getRelativeMouse();--获取鼠标位置
	self.posX = monsePos.x;
	self.posY = monsePos.y;
	objSwf._x = monsePos.x + 25;
	objSwf._y = monsePos.y + 26;
end

function UIMountFeedTip:ShowFeedInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.bg._height = 373;
	objSwf.imgLine._y = 193;
	objSwf.tfinfo._y = 206;
	if self.type == 1 then
		self:ShowMountFeedInfo();
	elseif self.type == 2 then
		self:ShowLingShouFeedInfo();
	elseif self.type == 3 then
		self:ShowShenBingFeedInfo();
	elseif self.type == 5 then
		self:ShowQiZhanFeedInfo();
	elseif self.type == 8 then
		self:ShowLingShowFeedInfo();
	-- elseif self.type == 10 then
	-- 	self:ShowWuxinglingmaiFeedInfo();
	elseif self.type == 12 then
		self:ShowLingQiNewFeedInfo();
	elseif self.type == 13 then
		self:ShowMingYuFeedInfo();
	elseif self.type == 14 then
		self:ShowArmorFeedInfo();
	elseif self.type == 15 then
		self:ShowRealmFeedInfo();
	elseif self.type == 101 then
		self:ShowMagicWeaponZZD();
	elseif self.type == 102 then
		self:ShowLingQiZZD();
	elseif self.type == 103 then
		self:ShowMingYuZZD();
	elseif self.type == 104 then
		self:ShowArmorZZD();
	elseif self.type == 105 then
		self:ShowRealmZZD();
	elseif self.type == 106 then
		self:ShowMountZZD();
	end
end

function UIMountFeedTip:GetSXDName(name)
	return string.format("<font color='%s'>%s</font>", "#ffc600", name);
end
function UIMountFeedTip:GetZZDName(name)
	return string.format("<font color='%s'>%s</font>", "#ff9000", name);
end
--显示信息
function UIMountFeedTip:ShowMountFeedInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--常量表id 8  坐骑属性丹的属性加成
	
	local horsecfg = t_horse[MountModel:GetMountLvl()];
	if not horsecfg then
		return;
		
	end
	
	--loader
	--名称
	local sXDItem = t_item[t_consts[8].val1]
	if sXDItem == nil then
		return
	end
	
	objSwf.tfshuxingtitle.text = StrConfig["mount36"];

	objSwf.tfname.htmlText = self:GetSXDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")
	
	local qualityurl = MountUtil:GetQualityUrl(t_consts[8].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end
	
	--喂养数量 
	objSwf.tfnum.text = MountModel.ridedMount.pillNum.."/"..horsecfg.attr_dan;
	
	--属性
	local attr = "";
	local isfirst = true;
	local str = t_consts[8].param;
	local formulaList = AttrParseUtil:Parse(str)
	for i,cfg in pairs(formulaList) do
		if isfirst == true then
			attr = enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
			isfirst = false;
		else
			attr = attr.."<br/>"..enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
		end
	end
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = MountModel:GetMountLvl() > self.levelShow and MountConsts.MountLevelMax or self.levelShow;
	if MountConsts.MountLevelMax < self.levelShow then
		curshowLevel = MountConsts.MountLevelMax;
	end
	--规则
	local str = "";
	for i=5,curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount119"], i, t_horse[i].attr_dan);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount119"], i, t_horse[i].attr_dan);
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end

--显示信息
function UIMountFeedTip:ShowLingShouFeedInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--常量表id 117 灵兽属性丹的属性加成
	
	local wuhuncfg = t_wuhun[SpiritsModel.currentWuhun.wuhunId];
	if not wuhuncfg then
		return;
		
	end
	
	--loader
	--名称
	local sXDItem = t_item[t_consts[117].val1]
	if sXDItem == nil then
		return
	end
	objSwf.tfshuxingtitle.text = StrConfig["mount37"];

	objSwf.tfname.htmlText = self:GetSXDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")
	
	local qualityurl = MountUtil:GetQualityUrl(t_consts[117].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end
	
	--喂养数量 
	objSwf.tfnum.text = SpiritsModel:GetPillNum().."/"..wuhuncfg.lingshoudan;
	
	--属性
	local attr = "";
	local isfirst = true;
	local str = t_consts[117].param;
	local formulaList = AttrParseUtil:Parse(str)
	for i,cfg in pairs(formulaList) do
		if isfirst == true then
			attr = enAttrTypeName[cfg.type].."  <font color='#32961e'>+"..(cfg.val*2).."</font>";
			isfirst = false;
		else
			attr = attr.."<br/>"..enAttrTypeName[cfg.type].."  <font color='#32961e'>+"..(cfg.val*2).."</font>";
		end
	end
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = SpiritsModel.currentWuhun.wuhunId - SpiritsConsts.SpiritsDownId > self.levelShow and SpiritsModel:GetMaxLevel() or self.levelShow;
	if SpiritsModel:GetMaxLevel() < self.levelShow then
		curshowLevel = SpiritsModel:GetMaxLevel();
	end
	--规则
	local str = "";
	for i=5,curshowLevel do
		for j,vo in pairs(t_wuhun) do
			if vo.order == i then
				if str == "" then
					str = string.format( StrConfig["Mount120"], i, vo.lingshoudan);
				else
					str = str .."<br/>" .. string.format( StrConfig["Mount120"], i, vo.lingshoudan);
				end
				break;
			end
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end


--显示信息
function UIMountFeedTip:ShowShenBingFeedInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	--常量表id 118  神兵属性丹的属性加成

	local shenbingcfg = t_shenbing[MagicWeaponModel:GetLevel()];
	if not shenbingcfg then
		return;
	end
	--loader
	--名称
	local sXDItem = t_item[t_consts[118].val1]
	if sXDItem == nil then
		return
	end
	objSwf.tfshuxingtitle.text = StrConfig["mount38"];

	objSwf.tfname.htmlText = self:GetSXDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")

	local qualityurl = MountUtil:GetQualityUrl(t_consts[118].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end

	--喂养数量
	objSwf.tfnum.text = MagicWeaponModel:GetPillNum().."/"..shenbingcfg.shenbingdan;

	--属性
	local attr = "";
	local isfirst = true;
	local str = t_consts[118].param;
	local formulaList = AttrParseUtil:Parse(str)
	for i,cfg in pairs(formulaList) do
		if isfirst == true then
			attr = enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
			isfirst = false;
		else
			attr = attr.."<br/>"..enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
		end
	end
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = MagicWeaponModel:GetLevel() > self.levelShow and MagicWeaponConsts:GetMaxLevel() or self.levelShow;
	if MagicWeaponConsts:GetMaxLevel() < self.levelShow then
		curshowLevel = MagicWeaponConsts:GetMaxLevel();
	end
	--规则
	local str = "";
	for i=5,curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount121"], i, t_shenbing[i].shenbingdan);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount121"], i, t_shenbing[i].shenbingdan);
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end

--显示信息
function UIMountFeedTip:ShowLingQiNewFeedInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	--常量表id 317  灵器属性丹的属性加成
	local shenbingcfg = t_lingqi[LingQiModel:GetLevel()];
	if not shenbingcfg then
		return;

	end

	--loader
	--名称
	local constsID = 317;
	local sXDItem = t_item[t_consts[constsID].val1]
	if sXDItem == nil then
		return
	end
	objSwf.tfshuxingtitle.text = StrConfig["mount41"];

	objSwf.tfname.htmlText = self:GetSXDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")

	local qualityurl = MountUtil:GetQualityUrl(t_consts[constsID].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end

	--喂养数量
	objSwf.tfnum.text = LingQiModel:GetPillNum().."/"..shenbingcfg.shenbingdan;

	--属性
	local attr = "";
	local isfirst = true;
	local str = t_consts[constsID].param;
	local formulaList = AttrParseUtil:Parse(str)
	for i,cfg in pairs(formulaList) do
		if isfirst == true then
			attr = enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
			isfirst = false;
		else
			attr = attr.."<br/>"..enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
		end
	end
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = LingQiModel:GetLevel() > self.levelShow and LingQiConsts:GetMaxLevel() or self.levelShow;
	if LingQiConsts:GetMaxLevel() < self.levelShow then
		curshowLevel = LingQiConsts:GetMaxLevel();
	end
	--规则
	local str = "";
	for i=5,curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount139"], i, t_lingqi[i].shenbingdan);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount139"], i, t_lingqi[i].shenbingdan);
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end

function UIMountFeedTip:ShowMingYuFeedInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	--常量表id 329  灵器属性丹的属性加成
	local shenbingcfg = t_mingyu[MingYuModel:GetLevel()];
	if not shenbingcfg then
		return;

	end

	--loader
	--名称
	local constsID = 329;
	local sXDItem = t_item[t_consts[constsID].val1]
	if sXDItem == nil then
		return
	end
	objSwf.tfshuxingtitle.text = StrConfig["mount42"];

	objSwf.tfname.htmlText = self:GetSXDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")

	local qualityurl = MountUtil:GetQualityUrl(t_consts[constsID].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end

	--喂养数量
	objSwf.tfnum.text = MingYuModel:GetPillNum().."/"..shenbingcfg.shenbingdan;

	--属性
	local attr = "";
	local isfirst = true;
	local str = t_consts[constsID].param;
	local formulaList = AttrParseUtil:Parse(str)
	for i,cfg in pairs(formulaList) do
		if isfirst == true then
			attr = enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
			isfirst = false;
		else
			attr = attr.."<br/>"..enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
		end
	end
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = MingYuModel:GetLevel() > self.levelShow and MingYuConsts:GetMaxLevel() or self.levelShow;
	if MingYuConsts:GetMaxLevel() < self.levelShow then
		curshowLevel = MingYuConsts:GetMaxLevel();
	end
	--规则
	local str = "";
	for i=5,curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount140"], i, t_mingyu[i].shenbingdan);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount140"], i, t_mingyu[i].shenbingdan);
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end

function UIMountFeedTip:ShowArmorFeedInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	--常量表id 331  灵器属性丹的属性加成
	local shenbingcfg = t_newbaojia[ArmorModel:GetLevel()];
	if not shenbingcfg then
		return;

	end

	--loader
	--名称
	local constsID = 331;
	local sXDItem = t_item[t_consts[constsID].val1]
	if sXDItem == nil then
		return
	end
	objSwf.tfshuxingtitle.text = StrConfig["mount43"];

	objSwf.tfname.htmlText = self:GetSXDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")

	local qualityurl = MountUtil:GetQualityUrl(t_consts[constsID].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end

	--喂养数量
	objSwf.tfnum.text = ArmorModel:GetPillNum().."/"..shenbingcfg.shenbingdan;

	--属性
	local attr = "";
	local isfirst = true;
	local str = t_consts[constsID].param;
	local formulaList = AttrParseUtil:Parse(str)
	for i,cfg in pairs(formulaList) do
		if isfirst == true then
			attr = enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
			isfirst = false;
		else
			attr = attr.."<br/>"..enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
		end
	end
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = ArmorModel:GetLevel() > self.levelShow and ArmorConsts:GetMaxLevel() or self.levelShow;
	if ArmorConsts:GetMaxLevel() < self.levelShow then
		curshowLevel = ArmorConsts:GetMaxLevel();
	end
	--规则
	local str = "";
	for i=5,curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount141"], i, t_newbaojia[i].shenbingdan);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount141"], i, t_newbaojia[i].shenbingdan);
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end

function UIMountFeedTip:ShowRealmFeedInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local cfgItem = t_jingjie[RealmModel.realmOrder];
	if not cfgItem then
		return;

	end

	--loader
	--名称
	local constsID = 341;
	local sXDItem = t_item[t_consts[constsID].val1]
	if sXDItem == nil then
		return
	end
	objSwf.tfshuxingtitle.text = StrConfig["mount44"];

	objSwf.tfname.htmlText = self:GetSXDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")

	local qualityurl = MountUtil:GetQualityUrl(t_consts[constsID].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end

	--喂养数量
	objSwf.tfnum.text = RealmModel:GetPillNum().."/"..cfgItem.jingjie_dan;

	--属性
	local attr = "";
	local isfirst = true;
	local str = t_consts[constsID].param;
	local formulaList = AttrParseUtil:Parse(str)
	for i,cfg in pairs(formulaList) do
		if isfirst == true then
			attr = enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
			isfirst = false;
		else
			attr = attr.."<br/>"..enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
		end
	end
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = RealmModel.realmOrder > self.levelShow and RealmConsts:GetMaxLevel() or self.levelShow;
	if RealmConsts:GetMaxLevel() < self.levelShow then
		curshowLevel = RealmConsts:GetMaxLevel();
	end
	--规则
	local str = "";
	for i=5,curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount142"], i, t_jingjie[i].jingjie_dan);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount142"], i, t_jingjie[i].jingjie_dan);
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end

--显示信息
function UIMountFeedTip:ShowQiZhanFeedInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--常量表id 146  骑战属性丹的属性加成
	local level = QiZhanModel:GetLevel();
	if level == 0 then
		level = QiZhanConsts.Downid + 1;
	end
	local qizhancfg = t_ridewar[level];
	if not qizhancfg then
		return;
		
	end
	
	--loader
	--名称
	local sXDItem = t_item[t_consts[146].val1]
	if sXDItem == nil then
		return
	end
	objSwf.tfshuxingtitle.text = StrConfig["mount40"];
	objSwf.tfname.htmlText = self:GetSXDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")
	
	local qualityurl = MountUtil:GetQualityUrl(t_consts[146].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end
	
	--喂养数量
	objSwf.tfnum.text = QiZhanModel:GetPillNum().."/"..qizhancfg.attr_dan;
	
	--属性
	local attr = "";
	local isfirst = true;
	local str = t_consts[146].param;
	local formulaList = AttrParseUtil:Parse(str)
	for i,cfg in pairs(formulaList) do
		if isfirst == true then
			attr = enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
			isfirst = false;
		else
			attr = attr.."<br/>"..enAttrTypeName[cfg.type].."  <font color='#00ff00'>+"..cfg.val.."</font>";
		end
	end
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = QiZhanModel:GetLevel()-QiZhanConsts.Downid  > self.levelShow and QiZhanModel:GetMaxLevel() - QiZhanConsts.Downid or self.levelShow;
	if QiZhanModel:GetMaxLevel() - QiZhanConsts.Downid < self.levelShow then
		curshowLevel = QiZhanModel:GetMaxLevel() - QiZhanConsts.Downid;
	end
	--规则
	local str = "";
	for i=QiZhanConsts.Downid + 5,QiZhanConsts.Downid + curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount123"], i-QiZhanConsts.Downid, t_ridewar[i].attr_dan);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount123"], i-QiZhanConsts.Downid, t_ridewar[i].attr_dan);
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end

--显示信息
function UIMountFeedTip:ShowLingShowFeedInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--常量表id 196  零售坐骑属性丹的属性加成
	local level = MountLingShouModel:GetMountLvl();
	if level == 0 then
		level = MountConsts.LingShouSpecailDownid + 1;
	end
	local lingqicfg = t_horselingshou[level];
	if not lingqicfg then
		return;
		
	end
	
	--loader
	--名称
	local sXDItem = t_item[t_consts[196].val1]
	if sXDItem == nil then
		return
	end
	objSwf.tfshuxingtitle.text = StrConfig["Mount128"];
	objSwf.tfname.htmlText = self:GetSXDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")
	
	local qualityurl = MountUtil:GetQualityUrl(t_consts[196].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end
	
	--喂养数量
	objSwf.tfnum.text = MountLingShouModel:GetZZPillNum().."/"..lingqicfg.dan_num;
	
	--属性
	local attr = "";
	attr = StrConfig["Mount130"].."  <font color='#00ff00'>+"..t_consts[196].val2.."%</font>";
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = level-MountConsts.LingShouSpecailDownid > self.levelShow and MountLingShouModel:GetMaxLevel() or self.levelShow;
	if MountLingShouModel:GetMaxLevel() < self.levelShow then
		curshowLevel = MountLingShouModel:GetMaxLevel();
	end
	--规则
	local str = "";
	for i=MountConsts.LingShouSpecailDownid + 5,MountConsts.LingShouSpecailDownid + curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount129"], i - MountConsts.LingShouSpecailDownid, t_horselingshou[i].dan_num);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount129"], i - MountConsts.LingShouSpecailDownid, t_horselingshou[i].dan_num);
		end
	end
	objSwf.tfinfo.htmlText = str;
	
	objSwf.imgLine._y = 135;
	objSwf.tfinfo._y = 150;
	objSwf.tfinfo._height = 190 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 190 + (curshowLevel - 5) * 25;
end

function UIMountFeedTip:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.StageMove then
		local monsePos = _sys:getRelativeMouse();--获取鼠标位置
		if self.posX ~= monsePos.x or self.posY ~= monsePos.y then
			self.posX = monsePos.x;
			self.posY = monsePos.y;
			objSwf._x = monsePos.x + 25;
			objSwf._y = monsePos.y + 26;
			self:Top();
		end
	elseif name == NotifyConsts.MountUsePillChanged then
		self:ShowFeedInfo();
	elseif name == NotifyConsts.UseZZDChanged then
		self:ShowFeedInfo();
	end
end

function UIMountFeedTip:ListNotificationInterests()
	return {NotifyConsts.StageMove,
		NotifyConsts.MountUsePillChanged,
		NotifyConsts.UseZZDChanged,};
end

--------------------资质丹----------------------------
function UIMountFeedTip:ShowMagicWeaponZZD()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local constsID = 338
	local model = MagicWeaponModel
	local sysConsts = MagicWeaponConsts
	local zznum = ZiZhiModel:GetZZNum(3);
	local cfgFile = t_shenbing
	local cfg = cfgFile[model:GetLevel()];
	if not cfg then	return;	end
	--名称
	local sXDItem = t_item[t_consts[constsID].val1]
	if sXDItem == nil then return; end
	objSwf.tfshuxingtitle.text = StrConfig["mount38"];
	objSwf.tfname.htmlText = self:GetZZDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")
	local qualityurl = MountUtil:GetQualityUrl(t_consts[constsID].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end
	--喂养数量
	objSwf.tfnum.text = zznum .."/"..cfg.zizhi_dan;
	--属性
	local attr = "";
	attr = string.format(StrConfig["Mount250"], t_consts[constsID].val2, "%", t_consts[constsID].val2 * zznum, "%")
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = model:GetLevel() > self.levelShow and sysConsts:GetMaxLevel() or self.levelShow;
	if sysConsts:GetMaxLevel() < self.levelShow then
		curshowLevel = sysConsts:GetMaxLevel();
	end
	--规则
	local str = "";
	for i=5,curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount200"], i, cfgFile[i].zizhi_dan);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount200"], i, cfgFile[i].zizhi_dan);
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end
function UIMountFeedTip:ShowLingQiZZD()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local constsID = 339
	local model = LingQiModel
	local sysConsts = LingQiConsts
	local zznum = ZiZhiModel:GetZZNum(4);
	local cfgFile = t_lingqi
	local cfg = cfgFile[model:GetLevel()];
	if not cfg then	return;	end
	--名称
	local sXDItem = t_item[t_consts[constsID].val1]
	if sXDItem == nil then return; end
	objSwf.tfshuxingtitle.text = StrConfig["mount41"];
	objSwf.tfname.htmlText = self:GetZZDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")
	local qualityurl = MountUtil:GetQualityUrl(t_consts[constsID].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end
	--喂养数量
	objSwf.tfnum.text = zznum .."/"..cfg.zizhi_dan;
	--属性
	local attr = "";
	attr = string.format(StrConfig["Mount251"], t_consts[constsID].val2, "%", t_consts[constsID].val2 * zznum, "%")
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = model:GetLevel() > self.levelShow and sysConsts:GetMaxLevel() or self.levelShow;
	if sysConsts:GetMaxLevel() < self.levelShow then
		curshowLevel = sysConsts:GetMaxLevel();
	end
	--规则
	local str = "";
	for i=5,curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount201"], i, cfgFile[i].zizhi_dan);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount201"], i, cfgFile[i].zizhi_dan);
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end
function UIMountFeedTip:ShowMingYuZZD()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local constsID = 337
	local model = MingYuModel
	local sysConsts = MingYuConsts
	local zznum = ZiZhiModel:GetZZNum(2);
	local cfgFile = t_mingyu
	local cfg = cfgFile[model:GetLevel()];
	if not cfg then	return;	end
	--名称
	local sXDItem = t_item[t_consts[constsID].val1]
	if sXDItem == nil then return; end
	objSwf.tfshuxingtitle.text = StrConfig["mount42"];
	objSwf.tfname.htmlText = self:GetZZDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")
	local qualityurl = MountUtil:GetQualityUrl(t_consts[constsID].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end
	--喂养数量
	objSwf.tfnum.text = zznum .."/"..cfg.zizhi_dan;
	--属性
	local attr = "";
	attr = string.format(StrConfig["Mount252"], t_consts[constsID].val2, "%", t_consts[constsID].val2 * zznum, "%")
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = model:GetLevel() > self.levelShow and sysConsts:GetMaxLevel() or self.levelShow;
	if sysConsts:GetMaxLevel() < self.levelShow then
		curshowLevel = sysConsts:GetMaxLevel();
	end
	--规则
	local str = "";
	for i=5,curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount202"], i, cfgFile[i].zizhi_dan);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount202"], i, cfgFile[i].zizhi_dan);
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end
function UIMountFeedTip:ShowArmorZZD()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local constsID = 336
	local model = ArmorModel
	local sysConsts = ArmorConsts
	local zznum = ZiZhiModel:GetZZNum(1);
	local cfgFile = t_newbaojia
	local cfg = cfgFile[model:GetLevel()];
	if not cfg then	return;	end
	--名称
	local sXDItem = t_item[t_consts[constsID].val1]
	if sXDItem == nil then return; end
	objSwf.tfshuxingtitle.text = StrConfig["mount43"];
	objSwf.tfname.htmlText = self:GetZZDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")
	local qualityurl = MountUtil:GetQualityUrl(t_consts[constsID].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end
	--喂养数量
	objSwf.tfnum.text = zznum .."/"..cfg.zizhi_dan;
	--属性
	local attr = "";
	attr = string.format(StrConfig["Mount253"], t_consts[constsID].val2, "%", t_consts[constsID].val2 * zznum, "%")
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = model:GetLevel() > self.levelShow and sysConsts:GetMaxLevel() or self.levelShow;
	if sysConsts:GetMaxLevel() < self.levelShow then
		curshowLevel = sysConsts:GetMaxLevel();
	end
	--规则
	local str = "";
	for i=5,curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount203"], i, cfgFile[i].zizhi_dan);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount203"], i, cfgFile[i].zizhi_dan);
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end

function UIMountFeedTip:ShowRealmZZD()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local constsID = 340
	local model = RealmModel
	local sysConsts = RealmConsts
	local zznum = ZiZhiModel:GetZZNum(5);
	local cfgFile = t_jingjie
	local cfg = cfgFile[model:GetLevel()];
	if not cfg then	return;	end
	--名称
	local sXDItem = t_item[t_consts[constsID].val1]
	if sXDItem == nil then return; end
	objSwf.tfshuxingtitle.text = StrConfig["mount44"];
	objSwf.tfname.htmlText = self:GetZZDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")
	local qualityurl = MountUtil:GetQualityUrl(t_consts[constsID].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end
	--喂养数量
	objSwf.tfnum.text = zznum .."/"..cfg.zizhi_dan;
	--属性
	local attr = "";
	attr = string.format(StrConfig["Mount254"], t_consts[constsID].val2, "%", t_consts[constsID].val2 * zznum, "%")
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = model:GetLevel() > self.levelShow and sysConsts:GetMaxLevel() or self.levelShow;
	if sysConsts:GetMaxLevel() < self.levelShow then
		curshowLevel = sysConsts:GetMaxLevel();
	end
	--规则
	local str = "";
	for i=5,curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount204"], i, cfgFile[i].zizhi_dan);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount204"], i, cfgFile[i].zizhi_dan);
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end
function UIMountFeedTip:ShowMountZZD()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local constsID = 335
	local model = MountModel
	local sysConsts = MountUtil
	local zznum = ZiZhiModel:GetZZNum(6);
	local cfgFile = t_horse
	local cfg = cfgFile[model.ridedMount.mountLevel];
	if not cfg then	return;	end
	--名称
	local sXDItem = t_item[t_consts[constsID].val1]
	if sXDItem == nil then return; end
	objSwf.tfshuxingtitle.text = StrConfig["mount45"];
	objSwf.tfname.htmlText = self:GetZZDName(sXDItem.name);
	objSwf.shuxingdanloader.source =  ResUtil:GetItemIconUrl(sXDItem.icon,"54")
	local qualityurl = MountUtil:GetQualityUrl(t_consts[constsID].val1, false)
	if qualityurl ~= "" then
		objSwf.qualityLoader.source = qualityurl;
	else
		objSwf.qualityLoader:unload();
	end
	--喂养数量
	objSwf.tfnum.text = zznum .."/"..cfg.zizhi_dan;
	--属性
	local attr = "";
	attr = string.format(StrConfig["Mount255"], t_consts[constsID].val2, "%", t_consts[constsID].val2 * zznum, "%")
	objSwf.tfattr.htmlText = attr;
	local curshowLevel = model.ridedMount.mountLevel > self.levelShow and sysConsts:GetMaxLevel() or self.levelShow;
	if sysConsts:GetMaxLevel() < self.levelShow then
		curshowLevel = sysConsts:GetMaxLevel();
	end
	--规则
	local str = "";
	for i=5,curshowLevel do
		if str == "" then
			str = string.format( StrConfig["Mount205"], i, cfgFile[i].zizhi_dan);
		else
			str = str .."<br/>" .. string.format( StrConfig["Mount205"], i, cfgFile[i].zizhi_dan);
		end
	end
	objSwf.tfinfo.htmlText = str;
	objSwf.tfinfo._height = 240 + (curshowLevel - 5) * 25;
	objSwf.bg._height = 240 + (curshowLevel - 5) * 25;
end