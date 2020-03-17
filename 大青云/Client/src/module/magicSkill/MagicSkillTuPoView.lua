--[[
	function: 绝学心法突破
	author:   houxudong
	date:     2016年11月23日11:08:26
--]]

_G.MagicSkillTuPoView = BaseUI:new("MagicSkillTuPoView")
MagicSkillTuPoView.gid = 0
MagicSkillTuPoView.skillId = 0
MagicSkillTuPoView.skillType = 0
MagicSkillTuPoView.TweenScale = 10

function MagicSkillTuPoView:Create()
	self:AddSWF("magicTupoPanel.swf",true,"top");  
end

function MagicSkillTuPoView:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnCloseClick(); end
	objSwf.btnbreakup.click = function() self:OnBreakUpClick(); end
	objSwf.btn_skill.rollOver = function() self:OnSkillRollOver(); end
	objSwf.btn_skill.rollOut = function() TipsManager:Hide(); end
	objSwf.btnItem.rollOver = function() self:OnLvlUprollOver(1); end
	objSwf.btnItem.rollOut = function() TipsManager:Hide(); end
end

function MagicSkillTuPoView:OnShow( )
	self:InitTitle()
	self:InitNeed()
	self:ShowMask()
end 

function MagicSkillTuPoView:InitNeed( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local str = ''
	local check = true
	if self.skillType == MagicSkillConsts.magicSkillType_juexue then
		str = StrConfig['skill8005']
	elseif self.skillType == MagicSkillConsts.magicSkillType_xinfa then
		str = StrConfig['skill8006']
		check = false
	end
	local cfg = nil
	if check then
		cfg = t_skill[self.skillId]
	else
		cfg = t_passiveskill[self.skillId]
	end
	if not cfg then
		Debug("not find skillId in t_skill or t_passiveskill",self.skillId)
		return
	end
	local currSkillLv = cfg.level
	local nextSkillLv = currSkillLv + 1
	local skillLv = SkillModel:GetSkill(self.skillId).lv
	objSwf.curstar.htmlText = string.format(StrConfig['skill8001'],currSkillLv)
	
	if currSkillLv == 20 then
		objSwf.NextStar.htmlText = string.format(StrConfig['skill8004'])
		objSwf.maxtext.htmlText = string.format(StrConfig['skill8000'],str,StrConfig['skill8004'])
	else
		objSwf.NextStar.htmlText = string.format(StrConfig['skill8001'],nextSkillLv)
		objSwf.maxtext.htmlText = string.format(StrConfig['skill8000'],str,nextSkillLv)
	end

	local iconUrl = ResUtil:GetSkllNameIcon(cfg.nameIcon)
	if objSwf.nameLoader1.source ~= iconUrl then
		objSwf.nameLoader1.source = iconUrl
	end
	local skillIconUrl = ResUtil:GetSkillIconUrl(cfg.icon,"54")
	if objSwf.iconLoader.source ~= skillIconUrl then
		objSwf.iconLoader.source = skillIconUrl
	end
	local stritem,itemList,itemIcon,needNum = self:GetItemVo(self.skillId,false,skillLv)
	if self.skillType == MagicSkillConsts.magicSkillType_xinfa then
		stritem,itemList,itemIcon,needNum = self:GetItemVo(self.skillId,false,skillLv,true)
	end
	local num = 0
 	if itemList[1].id < 100 then
 		num = MainPlayerModel.humanDetailInfo.eaBindGold
 	else
 		num = BagModel:GetItemNumInBag(itemList[1].id)
 	end
	-- 消耗模块
	local state,isCanTopo = MountUtil:GetCanLvlUp(self.skillId,false,skillLv)
	if check == false then
		state,isCanTopo = MountUtil:GetCanLvlUp(self.skillId,false,skillLv,true)
	end
	local color = "#00ff00"
	if isCanTopo == false then
		color = "#ff0000"
	end
	objSwf.btnItem.htmlLabel = string.format( StrConfig["skill8002"],stritem[1],needNum[1])
	objSwf.itemNowHave.htmlText = string.format( StrConfig["skill8003"],color,num)
	local currColumn = self:GetColumn()
	local nextColumn = currColumn + 1
	local addFight = self:ShowFight(nextColumn) - self:ShowFight(currColumn) > 0 and self:ShowFight(nextColumn) - self:ShowFight(currColumn) or 0
	objSwf.fightLoader.num = addFight
end

function MagicSkillTuPoView:OnSkillRollOver()
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	local tipsInfo = { skillId = self.skillId, condition = true,unShowLvlUpPrompt =true, get = self.skillId > 0 };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

function MagicSkillTuPoView:InitTitle( )
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.xinfaTuPo._visible = false
	objSwf.juexueTuPo._visible = false
	if self.skillType == MagicSkillConsts.magicSkillType_juexue then
		objSwf.juexueTuPo._visible = true
	elseif self.skillType == MagicSkillConsts.magicSkillType_xinfa then
		objSwf.xinfaTuPo._visible = true
	end
	objSwf.btnbreakup:showEffect(ResUtil:GetButtonEffect10());
end

function MagicSkillTuPoView:OnCloseClick( )
	self:Hide()
end

function MagicSkillTuPoView:OnBreakUpClick()
	local check = true
	-- 为了防止连点
	local skillData = SkillModel:GetSkill(self.skillId)
	if not skillData then
		self:Hide()
		return
	end
	local state,tupoState = MountUtil:GetCanLvlUp(self.skillId,false, SkillModel:GetSkill(self.skillId).lv)
	if self.skillType == MagicSkillConsts.magicSkillType_xinfa then
		check = false
		state,tupoState = MountUtil:GetCanLvlUp(self.skillId,false, SkillModel:GetSkill(self.skillId).lv,true)
	end
	if not state then FloatManager:AddNormal( StrConfig['magicskill5'] ); return; end
	if not tupoState then FloatManager:AddNormal( StrConfig['magicskill5'] ); return; end
	if check then
		SkillController:LearnMagicSkill(MagicSkillConsts.magicSkillType_juexue,MagicSkillConsts.magicSkillOper_tupo,self.gid)
	else
		SkillController:LearnMagicSkill(MagicSkillConsts.magicSkillType_xinfa,MagicSkillConsts.magicSkillOper_tupo,self.gid)
	end
	self:Hide()
end

function MagicSkillTuPoView:OnOpen( gid,skillId,skillType)
	self.gid = gid
	self.skillId = skillId
	self.skillType = skillType
	if self:IsShow() then
		self:OnShow()
	else
		self:Show()
	end
end

--获取item的详细信息
function MagicSkillTuPoView:GetItemVo(skillId,learn,level,IsPassSkill)   
	local list = {}
	if IsPassSkill then
		list = SkillUtil:GetLvlUpCondition(skillId,learn,level,IsPassSkill)
	else
		list = SkillUtil:GetLvlUpCondition(skillId,learn,level) 
	end
	local itemNameStr = {};
	local itemNeedNum = {};
	local itemList = {};
	local itemIcon = {};
	for i,vo in ipairs(list) do
		if vo and vo.id and vo.id > 0 then
			local itemvo = t_item[vo.id];
			table.push(itemIcon,itemvo.icon)
			table.push(itemNameStr,itemvo.name);
			table.push(itemNeedNum,vo.num);
			local itemCfg = {};
			itemCfg.id = itemvo.id;
			itemCfg.num = vo.num;
			table.push(itemList,itemCfg);
		end
	end
	return itemNameStr,itemList,itemIcon,itemNeedNum;
end

function MagicSkillTuPoView:OnLvlUprollOver(index)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = {};
	local skillLv = SkillModel:GetSkill(self.skillId).lv
	if not skillLv then return; end
	if skillLv <= 0 then
		list = SkillUtil:GetLvlUpCondition(self.skillId,true,skillLv);
	else
		list = SkillUtil:GetLvlUpCondition(self.skillId,false,skillLv);
	end
	local listCfg = {};
	for i,vo in ipairs(list) do
		if vo and vo.id and vo.id > 0 then
			table.push(listCfg,vo);
		end
	end
	
	local vo = listCfg[index];
	if not vo then return end
	TipsManager:ShowItemTips(vo.id);
end

-- 得到当前技能对应的行数
function MagicSkillTuPoView:GetColumn()
	local  column = 0
	local skillLv = SkillModel:GetSkill(self.skillId).lv
	if self.skillType == MagicSkillConsts.magicSkillType_juexue then
		for k,v in pairs(t_juexue) do
			if v.id == self.skillId and v.spot == skillLv then
				column = v.column;
			end
		end
	elseif self.skillType == MagicSkillConsts.magicSkillType_xinfa then
		for k,v in pairs(t_xinfa) do
			if v.id == self.skillId and v.spot == skillLv then
				column = v.column;
			end
		end
	end
	return column >= 0 and column or 0
end

-- 战斗力差值
function MagicSkillTuPoView:ShowFight(column)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = {}
	local cfg = nil
	if self.skillType == MagicSkillConsts.magicSkillType_juexue then
		cfg = t_juexue[column]
	elseif self.skillType == MagicSkillConsts.magicSkillType_xinfa then
		cfg = t_xinfa[column]
	end 
	if not cfg then return 0 end
	local attrList = split(cfg.add_attr,'#');
	local vo = {};
	for attStr , attCfg in ipairs(attrList) do
		local cfg = split(attCfg,',');
		vo[cfg[1]] = toint(cfg[2])
	end
	vo = self:OnSortNum(vo);
	local fight = EquipUtil:GetFight(vo);
	fight =  PublicUtil:GetFigthValue(vo)
	local powerFight = cfg.power_point or 0;
	return fight + powerFight
end

function MagicSkillTuPoView:OnSortNum(obj)
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

function MagicSkillTuPoView:ClosePanel( )
	if self:IsShow() then
		self:Hide()
	end
end

function MagicSkillTuPoView:OnResize()
	self:ShowMask()
end

function MagicSkillTuPoView:ShowMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end

function MagicSkillTuPoView:DoTweenShow()
	self:TweenShowEff(function()
		self:DoShow()
	end);
end

function MagicSkillTuPoView:GetWidth()
	return 713;
end

function MagicSkillTuPoView:GetHeight()
	return 344;
end

function MagicSkillTuPoView:DoTweenHide()
	self:DoHide()
end

function MagicSkillTuPoView:IsTween()
	return true;
end

function MagicSkillTuPoView:GetPanelType()
	return 0;
end
function MagicSkillTuPoView:ESCHide()
	return true;
end

function MagicSkillTuPoView:TweenShowEff(callback)
	local objSwf = self.objSwf;
	local endX,endY = self:GetCfgPos();
	local startX = endX + self:GetWidth()/2 - self:GetWidth()*self.TweenScale/100/2;
	local startY = endY + self:GetHeight()/2 - self:GetHeight()*self.TweenScale/100/2;
	objSwf._x = startX;
	objSwf._y = startY;
	objSwf._alpha = 50;
	objSwf._xscale = self.TweenScale;
	objSwf._yscale = self.TweenScale;
	Tween:To( self.objSwf, 0.3, {_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},
			{onComplete=callback})
end

function MagicSkillTuPoView:OnHide( )
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.btnbreakup:clearEffect();
end

function MagicSkillTuPoView:ListNotificationInterests()
	return {
			NotifyConsts.BagItemNumChange,NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagUpdate,
			NotifyConsts.PlayerAttrChange,
			};
end

function MagicSkillTuPoView:HandleNotification(name,body)
	if name==NotifyConsts.BagItemNumChange or name==NotifyConsts.BagAdd or name==NotifyConsts.BagRemove or name==NotifyConsts.BagUpdate then
		self:InitNeed()
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaLevel or body.type==enAttrType.eaZhenQi or 
			body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold then
			self:InitNeed()
		end
	end
end
