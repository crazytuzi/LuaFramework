--[[
心法面板
houxudong
2016年5月20日
]]

_G.UIXinfaSkillBasic = BaseUI:new("UIXinfaSkillBasic");

--当前技能id
UIXinfaSkillBasic.currSkillId = 0;    ---当前技能Id
UIXinfaSkillBasic.currSkillLvl = 0;	  ---当前技能等级
--技能列表
UIXinfaSkillBasic.skilllist = {};     ---主动技能列表
UIXinfaSkillBasic.passkilllist = {};  ---被动技能列表
UIXinfaSkillBasic.attrMaxNum = 4;     ---技能最大属性值

UIXinfaSkillBasic.IsPassSkill = true; ---标识这个是被动技能
UIXinfaSkillBasic.viewMagicSkillPort = nil;
UIXinfaSkillBasic.isShow = false;
function UIXinfaSkillBasic:Create()
	self:AddSWF("xinfaskillBasicPanel.swf",true,nil);  
end

local uiMagicSkillShowDes = false
local uiMagicSkillmouseMoveX = 0
function UIXinfaSkillBasic:OnLoaded(objSwf)
	-- objSwf.uiLoader.hitTestDisable = true;
	objSwf.skillPanel.list.itemClick = function(e) 
		self:OnListItemClick(e);
	end
	objSwf.infopanel.learnUpPanel.learnpanel.btnLearn.click = function() self:OnBtnLearnClick(); end  ---学习技能
	objSwf.infopanel.learnUpPanel.lvluppanel.btnLvlUp.click = function() self:OnBtnLvlUpClick(); end  ---升级技能
	objSwf.infopanel.learnUpPanel.tupopanel.btnTupo.click = function() self:OnBtnTupoClick(); end     ---突破技能  
	objSwf.infopanel.learnUpPanel.learnpanel.btnLearn.rollOver = function() self:OnbtnrollOver(); end
	objSwf.infopanel.learnUpPanel.learnpanel.btnLearn.rollOut = function() self:OnBtnRollOut(); end
	objSwf.infopanel.learnUpPanel.lvluppanel.btnLvlUp.rollOver = function() self:OnbtnrollOver(); end
	objSwf.infopanel.learnUpPanel.lvluppanel.btnLvlUp.rollOut = function() self:OnBtnRollOut(); end
	objSwf.infopanel.learnUpPanel.tupopanel.btnTupo.rollOver = function() self:OnbtnrollOver(); end
	objSwf.infopanel.learnUpPanel.tupopanel.btnTupo.rollOut = function() self:OnBtnRollOut(); end

	objSwf.infopanel.learnUpPanel.learnpanel.btnItem.rollOver = function() self:OnLvlUprollOver(1); end
	objSwf.infopanel.learnUpPanel.learnpanel.btnItem.rollOut = function() TipsManager:Hide(); end
	
	objSwf.infopanel.learnUpPanel.lvluppanel.btnItem.rollOver = function() self:OnLvlUprollOver(1); end
	objSwf.infopanel.learnUpPanel.lvluppanel.btnItem.rollOut = function() TipsManager:Hide(); end

	objSwf.infopanel.learnUpPanel.tupopanel.btnItem.rollOver = function() self:OnLvlUprollOver(1); end
	objSwf.infopanel.learnUpPanel.tupopanel.btnItem.rollOut = function() TipsManager:Hide(); end

	objSwf.infopanel.btn_skill.rollOver = function() self:OnSkillRollOver(); end
	objSwf.infopanel.btn_skill.rollOut = function() TipsManager:Hide(); end
	
	objSwf.PlayerSkill._visible = false
	objSwf.PlayerSkill._visible = false
	objSwf.infopanel.learnUpPanel.learnpanel.btn_skill._visible = false
	objSwf.infopanel.learnUpPanel.learnpanel.iconLoader._visible = false
	objSwf.infopanel.learnUpPanel.lvluppanel.btn_skill._visible = false
	objSwf.infopanel.learnUpPanel.lvluppanel.iconLoader._visible = false
	objSwf.infopanel.learnUpPanel.tupopanel.btn_skill._visible = false
	objSwf.infopanel.learnUpPanel.tupopanel.iconLoader._visible = false
	
	objSwf.iconDes._alpha = 0
	objSwf.btnDesShow.rollOver = function()
		if uiMagicSkillShowDes then return end
		local desicon = "";
		if self.currSkillId < 1000000000 then
			desicon = ResUtil:GetMagicSkillIcon("zhudong_des_"..objSwf.skillPanel.list.selectedIndex+1);
		end
		if desicon and desicon ~= "" then
			objSwf.iconDes.desLoader.source = desicon;
		end
		Tween:To(objSwf.iconDes,5,{_alpha=100});
		uiMagicSkillShowDes = true
	end

	objSwf.btnDesShow.rollOut = function()
		self.isMouseDrag = false
		if self.objUIDraw then
		
			self.objUIDraw:OnBtnRoleRightStateChange("out"); 				
		end
		if self.roleRender then
			self.roleRender:OnBtnRoleRightStateChange("out");
		end
		if not uiMagicSkillShowDes then return end
		
		Tween:To(objSwf.iconDes,1,{_alpha=0});
		uiMagicSkillShowDes = false
	end
	
	objSwf.btnDesShow.press = function() 		
		local monsePosX = _sys:getRelativeMouse().x;--获取鼠标位置		
		uiMagicSkillmouseMoveX = monsePosX;   		       
		self.isMouseDrag = true
	end

	objSwf.btnDesShow.release = function()
		self.isMouseDrag = false
		if self.objUIDraw then
			self.objUIDraw:OnBtnRoleRightStateChange("release"); 				
		end
		if self.roleRender then
			self.roleRender:OnBtnRoleRightStateChange("release");
		end
	end
end

function UIXinfaSkillBasic:OnSkillRollOver()
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	if not self.currSkillLvl or not self.currSkillId then return; end
	local tipsInfo = { skillId = self.currSkillId, condition = true,unShowLvlUpPrompt =true, get = self.currSkillLvl > 0 };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

function UIXinfaSkillBasic:OnDelete()
	if self.objSenDraw then
		self.objSenDraw:SetUILoader(nil);
	end

end

function UIXinfaSkillBasic:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
end

function UIXinfaSkillBasic:OnLvlUprollOver(index)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = {};
	if not self.currSkillLvl then return; end
	if self.currSkillLvl <= 0 then
		list = SkillUtil:GetLvlUpCondition(self.currSkillId,true,self.currSkillLvl,true);  
	else
		list = SkillUtil:GetLvlUpCondition(self.currSkillId,false,self.currSkillLvl,true); ----  0:29
	end
	
	local listCfg = {};
	for i,vo in ipairs(list) do
		if vo and vo.id and vo.id > 0 then
			table.push(listCfg,vo);
			-- TipsManager:ShowItemTips(vo.id);
		end
	end
	
	local vo = listCfg[index];
	if not vo then return end
	TipsManager:ShowItemTips(vo.id);
end

function UIXinfaSkillBasic:OnShow()
	self.isShow = false;
	self:ShowList();   ---显示列表
	self:OnBtnLvlUpRollOut();
	self.objSenDraw = nil;
	self.viewMagicSkillPort = nil;
	-- self:StartTimer();
	-- self:DrawMagicSkillSen();
end

---完全展开后显示Avatar
function UIXinfaSkillBasic:OnFullShow()
	-- self:DrawMagicSkillSen();
	-- self:ShowAvatar();
end

function UIXinfaSkillBasic:IsShowLoading()
	return false;
end

--显示列表
function UIXinfaSkillBasic:ShowList()
	self:ShowPassSkillList(true)
end

--显示主动列表
function UIXinfaSkillBasic:ShowPassSkillList(isselectone)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = SkillUtil:GetPassiveSkillListByShow(SkillConsts.ShowType_JuxuePassive);  --基础技能的显示类型hxd
	--过滤普攻
	for i=#list,1,-1 do
		local vo = list[i];
		local cfg = t_passiveskill[vo.skillId];
		local maxLvl = cfg.level;      
		if t_skillgroup[cfg.group_id] then     
			maxLvl = t_skillgroup[cfg.group_id].maxLvl;
		end
		if maxLvl <= 1 then
			table.remove(list,i);
		end
	end
	local curselectedIndex = objSwf.skillPanel.list.selectedIndex;

	objSwf.skillPanel.list.dataProvider:cleanUp();
	local skillindex = 1;
	for i,vo in ipairs(list) do
		local listVO = self:GetSkillListVO(vo.skillId,vo.lvl,skillindex);   --获取技能的vo
		skillindex = skillindex + 1;
		table.push(self.skilllist,listVO);
		objSwf.skillPanel.list.dataProvider:push(UIData.encode(listVO));
	end
	objSwf.skillPanel.list:invalidateData();

	if isselectone then   ---默认第一个
		objSwf.skillPanel.list.selectedIndex = 0;
		self:ShowRight(list[1].skillId,list[1].lvl);  ----显示第一个绝学技能的等级的详情
	else
		objSwf.skillPanel.list.selectedIndex = curselectedIndex;
	end
	-- self:ChangeSkillBg(list[1].skillId)
end

-------------------------------------------------------
function UIXinfaSkillBasic:CheckList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.isCanLvUpNum = 0    --如果红点提示需要显示数字，记录可以升级的数量
	for i,vo in ipairs(self.skilllist) do
		local showLvlUp = false;
		local maxLvl = SkillUtil:GetSkillMaxLvl(vo.skillId);
		local skillVO = SkillModel:GetSkill(vo.skillId);
		if skillVO then
			local iscan,isCanTopo = self:GetSkillCanLvlUp(vo.skillId,vo.lvl);
			showLvlUp = iscan;
			if vo.lvl == 10 then
				showLvlUp = isCanTopo
			end
			if showLvlUp then
				self.isCanLvUpNum = self.isCanLvUpNum +1;
			end
		elseif vo.lvl == 0 then                           --处理技能可以学习时也可有提示
			showLvlUp = self:GetSkillCanLearn(vo.skillId);
			if showLvlUp then
				self.isCanLvUpNum = self.isCanLvUpNum +1;
			end
		else
			showLvlUp = false;
		end

		if vo.showLvlUp ~= showLvlUp then
			-- vo.lvl = SkillModel:GetSkill(vo.skillId) or 0;   
			-- vo.lvlStr = self:GetSkillListVO(vo.skillId,vo.lvl,i).lvlStr;
			vo.showLvlUp = showLvlUp;
			local uiData = UIData.encode(vo);
			objSwf.skillPanel.list.dataProvider[i-1] = uiData;
			local uiItem = objSwf.skillPanel.list:getRendererAt(i-1);
			if uiItem then
				uiItem:setData(uiData);
			end
		end
	end
end

--技能是否可以学习
function UIXinfaSkillBasic:GetSkillCanLearn(skillId)
	local conditionlist = SkillUtil:GetLvlUpCondition(skillId,true,0,true);
	for i,vo in ipairs(conditionlist) do
		if not vo.state then
			return false;
		end
	end
	return true;
end

--获取技能是否可升级
function UIXinfaSkillBasic:GetSkillCanLvlUp(skillId,lv)
	local conditionlist = SkillUtil:GetLvlUpCondition(skillId,false,lv,true);
	local iscan = false;
	local isCanTopo = false;
	for i,vo in ipairs(conditionlist) do
		if vo.state == false then
			return false;
		else
			iscan = true;
		end
		if vo.breach then  	--突破消耗
			isCanTopo = true;
		end
	end
	return iscan,isCanTopo;
end

-------------------------------------------------------
--获取列表VO
function UIXinfaSkillBasic:GetSkillListVO(skillId,lvl,skillindex)
	local vo = {};
	vo.skillId = skillId;
	vo.lvl = lvl;
	vo.lvlUrl = "";
	vo.lvlUrl = ResUtil:GetMagicSkillIcon("level_"..lvl);      ----等级阶数
	vo.lvlStr = math.floor(math.floor(skillId % 10000000) % 1000 ).."级"..lvl.."重";
	local cfg = t_passiveskill[skillId];
	if not cfg then
		vo.name ="" 
	else
		vo.name = cfg.name
	end
	if skillId > 1000000000 then
		if vo.lvl > 0 then
			-- vo.iconUrl = ResUtil:GetMagicSkillIcon("beidongicon_"..skillindex);
			vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon,"54");
			-- vo.iconLoad = ResUtil:GetMagicSkillIcon("beidong_iconname_small_"..skillindex);
			vo.state = MountUtil:GetCanLvlUp(skillId,false,lvl,true);
			local iscan,isCanTopo = MountUtil:GetCanLvlUp(skillId,false,lvl,true); 
			vo.showLvlUp = iscan 
			if lvl == 10 then
				vo.showLvlUp = isCanTopo
				if math.floor(math.floor(skillId % 10000000) % 1000 ) == 20 then
					vo.showLvlUp = false;
				end
			end
		else
			vo.iconUrl = ImgUtil:GetGrayImgUrl(ResUtil:GetSkillIconUrl(cfg.icon,"54"));
			-- vo.iconLoad = ImgUtil:GetGrayImgUrl(ResUtil:GetMagicSkillIcon("beidong_iconname_small_"..skillindex));
			vo.state = MountUtil:GetCanLvlUp(skillId,true,lvl,true);
			vo.showLvlUp = MountUtil:GetCanLvlUp(skillId,true,lvl,true);
		end
	end
	return vo;
end

--显示右侧信息
function UIXinfaSkillBasic:ShowRight(skillId,lvl)
	self.currSkillId = skillId;
	self.currSkillLvl = lvl;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:ChangeSkillBg(skillId)
	local cfg = t_passiveskill[skillId];
	if cfg then
		local iconUrl = ResUtil:GetSkllNameIcon(cfg.nameIcon)
		if objSwf.infopanel.nameLoader1.source ~= iconUrl then
			objSwf.infopanel.nameLoader1.source = iconUrl
		end
		local skillIconUrl = ResUtil:GetSkillIconUrl(cfg.icon,"54");
		if objSwf.infopanel.iconLoader.source ~= skillIconUrl then
			objSwf.infopanel.iconLoader.source = skillIconUrl
		end
		objSwf.infopanel.tfLvl.htmlText = string.format(StrConfig['magicskill001'],math.floor(math.floor(skillId % 10000000) % 1000),lvl);   ---%s/%s重
		objSwf.infopanel.tfdes.htmlText = SkillTipsUtil:GetSkillEffectStr(skillId);
		objSwf.infopanel.learnUpPanel.learnpanel._visible = false;
		objSwf.infopanel.tfLvl._visible = true;
		objSwf.infopanel.learnUpPanel.lvluppanel._visible = false;
		objSwf.infopanel.learnUpPanel.tupopanel._visible = false;
		if lvl == 0 then
			objSwf.infopanel.learnUpPanel.learnpanel._visible = true;
			objSwf.infopanel.tfLvl._visible = false;
		else
			objSwf.infopanel.learnUpPanel.lvluppanel._visible = true;
		end
		self:ShowAttrs(cfg.add_attr);
		self:ShowFight();
		self:ShowLearnUpPanel();          
	end
end

----显示下已等级的属性加成
function UIXinfaSkillBasic:OnbtnrollOver(  )
	self.isShow = true
	self:CheckShowOrFalse(true)
end
----隐藏下已等级的属性加成
function UIXinfaSkillBasic:OnBtnRollOut(  )
	self.isShow = false
	self:CheckShowOrFalse(false)
	
end

function UIXinfaSkillBasic:CheckShowOrFalse( isShow )
	local objSwf = self.objSwf;
	if not isShow then
		local attrs = {};
		self:ShowAttrs(attrs)
		return;
	end
	local attrList;
	local nextAttrList;
	for i=1,self.attrMaxNum do 
		local column;
		for k,v in pairs(t_xinfa) do
			if v.spot == self.currSkillLvl and v.id == self.currSkillId then
				column = v.column
			end
		end
		if not column then return; end
		local cfg = t_xinfa[column]
		local nextCfg = t_xinfa[column + 1]
		if not cfg then return; end
		if not nextCfg then return; end
		local strattr = cfg.add_attr
		local nextStrattr = nextCfg.add_attr
		attrList = split(strattr,"#");
		nextAttrList = split(nextStrattr,"#");  
		for i,attrStr in ipairs(attrList) do
			objSwf.infopanel["nextAddAtt"..i]._visible = isShow;
			objSwf.infopanel["tfvaltext"..i]._visible = isShow;
		end
	end
	-------------------------------处理特殊的下级显示效果---------------------------------------
	--@adder:侯旭东
	--@date:2016/7/15
		if #attrList == #nextAttrList then
			return;
		else
			if isShow == true then
			for i=1,self.attrMaxNum do    ---最大属性值
				objSwf.infopanel["labletype"..i].text = "";
					objSwf.infopanel["tfval"..i].text = "";
					objSwf.infopanel["nextAddAtt"..i]._visible = not isShow;
					objSwf.infopanel["tfvaltext"..i]._visible = not isShow;
				end
			end
			local isHave = false;
			for j,attrStr in ipairs(attrList) do
				local attrvo = split(attrStr,",");
				local vo = {};
				vo.type = AttrParseUtil.AttMap[attrvo[1]];
				vo.val = tonumber(attrvo[2]);
				--@reason 属性匹配
				local nextattr;
				local nextVo;
				for i,nextAttrvo in ipairs(nextAttrList) do
					nextattr = split(nextAttrvo,",");
					nextVo = {};
					nextVo.type = AttrParseUtil.AttMap[nextattr[1]];
					nextVo.val = tonumber(nextattr[2]);
					if nextVo.type == enAttrType.eaGongJi then 
						objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaGongJi];
		 				if vo.type == enAttrType.eaGongJi then 
		 					objSwf.infopanel["nextAddAtt"..i]._visible = true;
		 					objSwf.infopanel["tfvaltext"..i]._visible = true; 
		 					objSwf.infopanel["tfval"..i].text = vo.val;
		 					objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
		 				end
		 				isHave = false
						for k,attrStr in ipairs(attrList) do
							local attrvo = split(attrStr,",");
							local vo = {};
							vo.type = AttrParseUtil.AttMap[attrvo[1]];
							if vo.type == enAttrType.eaFangYu then
								isHave = true
							end
						end
						if not isHave then
							objSwf.infopanel["tfval"..i].text = nextVo.val;
						end
					elseif nextVo.type == enAttrType.eaFangYu then                         --def
						objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaFangYu];
						if vo.type == enAttrType.eaFangYu then 
							objSwf.infopanel["nextAddAtt"..i]._visible = true;
							objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
							objSwf.infopanel["tfval"..i].text = vo.val;
		 					objSwf.infopanel["tfvaltext"..i]._visible = true; 
						end
						isHave = false
						for k,attrStr in ipairs(attrList) do
							local attrvo = split(attrStr,",");
							local vo = {};
							vo.type = AttrParseUtil.AttMap[attrvo[1]];
							if vo.type == enAttrType.eaFangYu then
								isHave = true
							end
						end
						if not isHave then
							objSwf.infopanel["tfval"..i].text = nextVo.val;
						end
					elseif nextVo.type == enAttrType.eaMaxHp then                           --hp
			 			objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaMaxHp];
			 			if vo.type == enAttrType.eaMaxHp then 
			 				objSwf.infopanel["nextAddAtt"..i]._visible = true;
			 				objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
			 				objSwf.infopanel["tfval"..i].text = vo.val;
		 					objSwf.infopanel["tfvaltext"..i]._visible = true; 
			 			end
			 			isHave = false
						for k,attrStr in ipairs(attrList) do
							local attrvo = split(attrStr,",");
							local vo = {};
							vo.type = AttrParseUtil.AttMap[attrvo[1]];
							if vo.type == enAttrType.eaFangYu then
								isHave = true
							end
						end
						if not isHave then
							objSwf.infopanel["tfval"..i].text = nextVo.val;
						end
		 			elseif nextVo.type == enAttrType.eaDefJianSu then                   --jiansu 
			 			objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaDefJianSu];
			 			if vo.type == enAttrType.eaDefJianSu then 
			 				objSwf.infopanel["nextAddAtt"..i]._visible = true;
			 				objSwf.infopanel["tfval"..i].text = vo.val;
			 				objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
			 				objSwf.infopanel["tfvaltext"..i]._visible = true;
			 			end
			 			isHave = false
						for k,attrStr in ipairs(attrList) do
							local attrvo = split(attrStr,",");
							local vo = {};
							vo.type = AttrParseUtil.AttMap[attrvo[1]];
							if vo.type == enAttrType.eaFangYu then
								isHave = true
							end
						end
						if not isHave then
							objSwf.infopanel["tfval"..i].text = nextVo.val;
						end
		 			elseif nextVo.type == enAttrType.eaDefXuanYun then                 --xuanyun

			 			objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaDefXuanYun];
			 			if vo.type == enAttrType.eaDefXuanYun then 
			 				objSwf.infopanel["nextAddAtt"..i]._visible = true;
			 				objSwf.infopanel["tfval"..i].text = vo.val;
			 				objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
			 				objSwf.infopanel["tfvaltext"..i]._visible = true;
			 			end
			 			isHave = false
						for k,attrStr in ipairs(attrList) do
							local attrvo = split(attrStr,",");
							local vo = {};
							vo.type = AttrParseUtil.AttMap[attrvo[1]];
							if vo.type == enAttrType.eaFangYu then
								isHave = true
							end
						end
						if not isHave then
							objSwf.infopanel["tfval"..i].text = nextVo.val;
						end
		 			elseif nextVo.type == enAttrType.eaDefChenMo then                   --chenmo
			 			objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaDefChenMo];
			 			if vo.type == enAttrType.eaDefChenMo then 
			 				objSwf.infopanel["nextAddAtt"..i]._visible = true;
			 				objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
			 				objSwf.infopanel["tfval"..i].text = vo.val;
			 				objSwf.infopanel["tfvaltext"..i]._visible = true;
			 			end
			 			isHave = false
						for k,attrStr in ipairs(attrList) do
							local attrvo = split(attrStr,",");
							local vo = {};
							vo.type = AttrParseUtil.AttMap[attrvo[1]];
							if vo.type == enAttrType.eaFangYu then
								isHave = true
							end
						end
						if not isHave then
							objSwf.infopanel["tfval"..i].text = nextVo.val;
						end
		 			elseif nextVo.type == enAttrType.eaDefDingShen then               --dingshen   

			 			objSwf.infopanel["labletype"..i].text = PublicStyle:GetAttrNameStr(enAttrTypeName[enAttrType.eaDefDingShen]);
			 			if vo.type == enAttrType.eaDefDingShen then 
			 				objSwf.infopanel["nextAddAtt"..i]._visible = true;
			 				objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
			 				objSwf.infopanel["tfval"..i].text = vo.val;
			 				objSwf.infopanel["tfvaltext"..i]._visible = true;
			 			end
			 			isHave = false
						for k,attrStr in ipairs(attrList) do
							local attrvo = split(attrStr,",");
							local vo = {};
							vo.type = AttrParseUtil.AttMap[attrvo[1]];
							if vo.type == enAttrType.eaFangYu then
								isHave = true
							end
						end
						if not isHave then
							objSwf.infopanel["tfval"..i].text = nextVo.val;
						end
		 			elseif nextVo.type == enAttrType.eaDefYuLiu then                     --YuLiu 
			 			objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaDefYuLiu];
			 			if vo.type == enAttrType.eaDefYuLiu then 
			 				objSwf.infopanel["nextAddAtt"..i]._visible = true;
			 				objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
			 				objSwf.infopanel["tfval"..i].text = vo.val;
			 				objSwf.infopanel["tfvaltext"..i]._visible = true;
			 			end
			 			isHave = false
						for k,attrStr in ipairs(attrList) do
							local attrvo = split(attrStr,",");
							local vo = {};
							vo.type = AttrParseUtil.AttMap[attrvo[1]];
							if vo.type == enAttrType.eaFangYu then
								isHave = true
							end
						end
						if not isHave then
							objSwf.infopanel["tfval"..i].text = nextVo.val;
						end
		 			end
				end
			end
	end
end

--显示属性
function UIXinfaSkillBasic:ShowAttrs(strattr)
	local objSwf = self.objSwf;
	for i=1,self.attrMaxNum do    ---最大属性值
		objSwf.infopanel["labletype"..i].text = "";
		objSwf.infopanel["tfval"..i].text = "";
		objSwf.infopanel["nextAddAtt"..i]._visible = false;
		objSwf.infopanel["tfvaltext"..i]._visible = false;
	end
	local column;
	local nextAttr;
	if #strattr == 0 then
		for k,v in pairs(t_xinfa) do
			if v.spot == self.currSkillLvl and v.id == self.currSkillId then
				column = v.column
			end
			if self.currSkillLvl == 0 then
				local lv = 1;
				if v.spot == lv and v.id == self.currSkillId then
					column = v.column;
				end
			end
		end
		if not column then return; end
		local cfg = t_xinfa[column]
		local nextCfg = t_xinfa[column+1]
		if not cfg then return; end;
		strattr = cfg.add_attr

		if nextCfg then
			nextAttr = nextCfg.add_attr
		else
			-- 处理最底部的边界问题
			nextAttr = strattr
		end
	end
	local attrList = split(strattr,"#");   --- 最多四个
	local nextAttrList = split(nextAttr,"#");
	for i,attrStr in ipairs(attrList) do
		local attrvo = split(attrStr,",");
		local vo = {};
		vo.type = AttrParseUtil.AttMap[attrvo[1]];
		vo.val = tonumber(attrvo[2]);
		--@reason 属性匹配
		local nextattr;
		local nextVo;
		for j,nextAttrvo in ipairs(nextAttrList) do
			nextattr = split(nextAttrvo,",");
			nextVo = {};
			nextVo.type = AttrParseUtil.AttMap[nextattr[1]];
			nextVo.val = tonumber(nextattr[2]);
			if vo.type == enAttrType.eaGongJi and nextVo.type == enAttrType.eaGongJi then                             --att
		 		objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaGongJi];
		 		objSwf.infopanel["tfval"..i].text = vo.val;
		 		objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
			elseif vo.type == enAttrType.eaFangYu and nextVo.type == enAttrType.eaFangYu then                         --def
				objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaFangYu];
				objSwf.infopanel["tfval"..i].text = vo.val;
		 		objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
			elseif vo.type == enAttrType.eaMaxHp and nextVo.type == enAttrType.eaMaxHp then                           --hp
			 	objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaMaxHp];
			 	objSwf.infopanel["tfval"..i].text = vo.val;
		 		objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
		 	elseif vo.type == enAttrType.eaDefJianSu and nextVo.type == enAttrType.eaDefJianSu then                   --jiansu 
			 	objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaDefJianSu];
			 	objSwf.infopanel["tfval"..i].text = vo.val;
		 		objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
		 	elseif vo.type == enAttrType.eaDefXuanYun and nextVo.type == enAttrType.eaDefXuanYun then                 --xuanyun
			 	objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaDefXuanYun];
			 	objSwf.infopanel["tfval"..i].text = vo.val;
		 		objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
		 	elseif vo.type == enAttrType.eaDefChenMo and nextVo.type == enAttrType.eaDefChenMo then                   --chenmo
			 	objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaDefChenMo];
			 	objSwf.infopanel["tfval"..i].text = vo.val;
		 		objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
		 	elseif vo.type == enAttrType.eaDefDingShen and nextVo.type == enAttrType.eaDefDingShen then               --dingshen     
			 	objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaDefDingShen];
			 	objSwf.infopanel["tfval"..i].text = vo.val;
		 		objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
		 	elseif vo.type == enAttrType.eaDefYuLiu and nextVo.type == enAttrType.eaDefYuLiu then                     --YuLiu 
			 	objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaDefYuLiu];
			 	objSwf.infopanel["tfval"..i].text = vo.val;
		 		objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
		 	end
		end
		-- local nextattrvo = split(nextAttrList[i],",");
		-- local nextVo = {};
		-- nextVo.type = AttrParseUtil.AttMap[nextattrvo[1]];
		-- nextVo.val = tonumber(nextattrvo[2]);
		-- objSwf.infopanel["labletype"..i].text = enAttrTypeName[AttrParseUtil.AttMap[attrvo[1]]];
		-- objSwf.infopanel["tfval"..i].text = vo.val;
		-- objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
	end
	if self.isShow then
		self:CheckShowOrFalse(true)	
	end
end

--显示战斗力
function UIXinfaSkillBasic:ShowFight()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local  column;
	for k,v in pairs(t_xinfa) do
		if v.id == self.currSkillId and v.spot == self.currSkillLvl then
			column = v.column;
		end
	end
	if not column then
		objSwf.infopanel.numFight.num = 0  
		return; 
	end
	local cfg = t_xinfa[column]
	if not cfg then return end
	local attrList = split(cfg.add_attr,'#');
	local vo = {};
	
	for attStr , attCfg in ipairs(attrList) do
		local cfg = split(attCfg,',');
		vo[cfg[1]] = toint(cfg[2])
	end
	
	vo = self:OnSortNum(vo);
	local fight =  PublicUtil:GetFigthValue(vo)
	local powerFight = cfg.power_point or 0;
	objSwf.infopanel.numFight.num = fight + powerFight;
end

function UIXinfaSkillBasic:OnSortNum(obj)
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

--显示激活升级突破信息
function UIXinfaSkillBasic:ShowLearnUpPanel()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.infopanel.learnUpPanel._visible = true;
	objSwf.infopanel.learnUpPanel.learnpanel._visible = false;
	objSwf.infopanel.tfLvl._visible = true;
	objSwf.infopanel.learnUpPanel.lvluppanel._visible = false;
	objSwf.infopanel.learnUpPanel.imgLevelMax._visible = false;
	objSwf.infopanel.learnUpPanel.tupopanel._visible = false;
	local maxLvl = 10 --SkillUtil:GetSkillMaxLvl(self.currSkillId);
	--学习
	if self.currSkillLvl <= 0 then
		objSwf.infopanel.learnUpPanel.learnpanel._visible = true;
		objSwf.infopanel.tfLvl._visible = false;
		local stritem,itemList,itemIcon,needNum= self:GetItemVo(self.IsPassSkill,self.currSkillId,true,0);   ----区分
		if #itemList == 0 then
			return;
		end
		local num1 = BagModel:GetItemNumInBag(itemList[1].id) or 0;
		local state = MountUtil:GetCanLvlUp(self.currSkillId,true,self.currSkillLvl,true);
		local iconUrl = ResUtil:GetSpecialSkillIconUrl(itemIcon[1],"54");
		if objSwf.infopanel.learnUpPanel.learnpanel.iconLoader.source ~= iconUrl then
			objSwf.infopanel.learnUpPanel.learnpanel.iconLoader.source = iconUrl
		end
		-- objSwf.infopanel.learnUpPanel.learnpanel.btnItem.htmlLabel = string.format(stritem[1]);
		-- objSwf.infopanel.learnUpPanel.learnpanel.btnItem.htmlLabel = string.format(stritem[1]).. string.format( StrConfig["magicskill12"],needNum[1]);
		if state == true then
			-- 增加按钮特效
			objSwf.infopanel.learnUpPanel.learnpanel.btnLearn:showEffect(ResUtil:GetButtonEffect10());
			objSwf.infopanel.learnUpPanel.learnpanel.btnItem2.htmlLabel = StrConfig['magicskill4'] .. string.format( StrConfig["magicskill1"],num1);  
			objSwf.infopanel.learnUpPanel.learnpanel.btnItem.htmlLabel = string.format( StrConfig["magicski1"],stritem[1],needNum[1]);
		else
			objSwf.infopanel.learnUpPanel.learnpanel.btnLearn:clearEffect();
			objSwf.infopanel.learnUpPanel.learnpanel.btnItem2.htmlLabel = StrConfig['magicskill4'] .. string.format( StrConfig["magicskill2"],num1);
			objSwf.infopanel.learnUpPanel.learnpanel.btnItem.htmlLabel = string.format( StrConfig["magicski2"],stritem[1],needNum[1]);
		end
	--升级
	elseif self.currSkillLvl < maxLvl then
		objSwf.infopanel.learnUpPanel.lvluppanel._visible = true;        
		local stritem,itemList,itemIcon,needNum = self:GetItemVo(self.IsPassSkill,self.currSkillId,false,self.currSkillLvl);        ----区分
		if #itemList == 0 then
			return;
		end
		local num1 = BagModel:GetItemNumInBag(itemList[1].id) or 0;
		local iconUrl = ResUtil:GetSpecialSkillIconUrl(itemIcon[1],"54");
		if objSwf.infopanel.learnUpPanel.lvluppanel.iconLoader.source  ~= iconUrl then
			objSwf.infopanel.learnUpPanel.lvluppanel.iconLoader.source =  iconUrl
		end
		objSwf.infopanel.learnUpPanel.lvluppanel.loaderTxt.htmlText = string.format(StrConfig['skill00011'],self.currSkillLvl,10);
		if UIMagicSkillBasic:CanFeedItem(itemList[1].id,itemList[1].num) then   --- 消耗物品的id和物品的数量
			objSwf.infopanel.learnUpPanel.lvluppanel.btnLvlUp:showEffect(ResUtil:GetButtonEffect10());
			objSwf.infopanel.learnUpPanel.lvluppanel.btnItem2.htmlLabel = StrConfig['magicskill4'] .. string.format( StrConfig["magicskill1"],num1);   ----升级条件
			objSwf.infopanel.learnUpPanel.lvluppanel.btnItem.htmlLabel = string.format( StrConfig["magicski1"],stritem[1],needNum[1]);
		else
			objSwf.infopanel.learnUpPanel.lvluppanel.btnLvlUp:clearEffect();
			objSwf.infopanel.learnUpPanel.lvluppanel.btnItem2.htmlLabel = StrConfig['magicskill4'] .. string.format( StrConfig["magicskill2"], needNum[1],num1);   ---红色, 升级条件不足
			objSwf.infopanel.learnUpPanel.lvluppanel.btnItem.htmlLabel = string.format( StrConfig["magicski2"],stritem[1],needNum[1]);
		end
		objSwf.infopanel.learnUpPanel.lvluppanel.siGrowValue:setProgress(self.currSkillLvl, 10 )
	elseif self.currSkillLvl == maxLvl then
		 if math.floor(math.floor(self.currSkillId % 10000000) % 1000 )== 20 then
		 	objSwf.infopanel.learnUpPanel.imgLevelMax._visible = true;
		 else
		 	local stritem,itemList,itemIcon,needNum = self:GetItemVo(self.IsPassSkill,self.currSkillId,false,self.currSkillLvl);
		 	local iconUrl = ResUtil:GetSpecialSkillIconUrl(itemIcon[1],"54");
		 	if objSwf.infopanel.learnUpPanel.tupopanel.iconLoader.source ~= iconUrl then
		 		objSwf.infopanel.learnUpPanel.tupopanel.iconLoader.source = icon
		 	end
		 	local num1 = 0
		 	if itemList[1].id < 100 then
		 		num1 = MainPlayerModel.humanDetailInfo.eaBindGold ;
		 	else
		 		num1 = BagModel:GetItemNumInBag(itemList[1].id) ;
		 	end
		 	-- 进度条文本
			objSwf.infopanel.learnUpPanel.tupopanel.loaderTxt.htmlText = string.format(StrConfig['skill00011'],self.currSkillLvl,10);
		 	local state,isCanTopo = MountUtil:GetCanLvlUp(self.currSkillId,false,self.currSkillLvl,true);
		 	-- 消耗显示
		 	if isCanTopo == true then
		 		objSwf.infopanel.learnUpPanel.tupopanel.btnTupo:showEffect(ResUtil:GetButtonEffect10());
				objSwf.infopanel.learnUpPanel.tupopanel.btnItem2.htmlLabel = StrConfig['magicskill4'] .. string.format( StrConfig["magicskill1"],num1);  
				objSwf.infopanel.learnUpPanel.tupopanel.btnItem.htmlLabel = string.format( StrConfig["magicski1"],stritem[1],needNum[1]);
			else
				objSwf.infopanel.learnUpPanel.tupopanel.btnTupo:clearEffect();
				objSwf.infopanel.learnUpPanel.tupopanel.btnItem2.htmlLabel = StrConfig['magicskill4'] .. string.format( StrConfig["magicskill2"],num1);
				objSwf.infopanel.learnUpPanel.tupopanel.btnItem.htmlLabel = string.format( StrConfig["magicski2"],stritem[1],needNum[1]);
			end
			objSwf.infopanel.learnUpPanel.tupopanel._visible = true;
			objSwf.infopanel.learnUpPanel.tupopanel.siGrowValue:setProgress( self.currSkillLvl, 10 )
		 end
	 end
end

----获取item的详细信息
function UIXinfaSkillBasic:GetItemVo(IsPassSkill,skillId,learn,level)   
	local list = SkillUtil:GetLvlUpCondition(skillId,learn,level,IsPassSkill);     ----学习 learn = true || 升级  shengji = false ,IsPassSkill 是用来区别绝学和被动技能
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

--是否可以提交珍宝启灵材料
function UIXinfaSkillBasic:CanFeedItem(id,num)
	local BgItemNum = BagModel:GetItemNumInBag(id);
	return BgItemNum >= num
end

--点击学习
function UIXinfaSkillBasic:OnBtnLearnClick()
	local state = MountUtil:GetCanLvlUp(self.currSkillId,true,self.currSkillLvl,true);
	if not state then FloatManager:AddNormal( StrConfig['magicskill5'] ); return end
	if not self.currSkillId then return; end
	local gid = nil;
	for k,v in pairs(t_xinfazu) do
		if v.startid == self.currSkillId then
			gid = v.id;
		end
	end
	if not gid then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.infopanel.learnUpPanel.learnpanel.btnLearn.disabled = true;
	SkillController:LearnMagicSkill(MagicSkillConsts.magicSkillType_xinfa,MagicSkillConsts.magicSkillOper_xuexi,gid)
end

--点击升级
function UIXinfaSkillBasic:OnBtnLvlUpClick()
	local state = MountUtil:GetCanLvlUp(self.currSkillId,false,SkillModel:GetSkill(self.currSkillId).lv,true);   --- add self.currSkillLvl
	self.currSkillLvl = SkillModel:GetSkill(self.currSkillId).lv
	if not state then FloatManager:AddNormal( StrConfig['magicskill5'] ); return end
	local gid = 0;
	for k,v in pairs(t_xinfa) do
		if v.spot == self.currSkillLvl and v.id == self.currSkillId then
			gid = v.juexuezu;
		end
	end
	if gid == 0 then return; end
	self.objSwf.infopanel.learnUpPanel.lvluppanel.btnLvlUp.disabled = true; 
	SkillController:LearnMagicSkill(MagicSkillConsts.magicSkillType_xinfa,MagicSkillConsts.magicSkillOper_shengji,gid)
end

--点击突破
function UIXinfaSkillBasic:OnBtnTupoClick()
	 if math.floor(math.floor(self.currSkillId % 10000000) % 1000) == 20  and SkillModel:GetSkill(self.currSkillId).lv == 10 then  
		 self:ShowLearnUpPanel()
		return;
	end
	local state , tupoState= MountUtil:GetCanLvlUp(self.currSkillId,false,SkillModel:GetSkill(self.currSkillId).lv,true);   --- add self.currSkillLvl
	self.currSkillLvl = SkillModel:GetSkill(self.currSkillId).lv
	if not state then FloatManager:AddNormal( StrConfig['magicskill5'] ); return end
	if not tupoState then FloatManager:AddNormal( StrConfig['magicskil23'] ); return end
	local gid = 0;
	for k,v in pairs(t_xinfa) do
		if v.spot == self.currSkillLvl and v.id == self.currSkillId then
			gid = v.juexuezu;
		end
	end
	if gid == 0 then return; end
	-- self.objSwf.infopanel.learnUpPanel.tupopanel.btnTupo.disabled = true
	if MagicSkillTuPoView:IsShow() then
		return
	else
		MagicSkillTuPoView:OnOpen( gid,self.currSkillId,MagicSkillConsts.magicSkillType_xinfa)
	end
	-- SkillController:LearnMagicSkill(MagicSkillConsts.magicSkillType_xinfa,MagicSkillConsts.magicSkillOper_tupo,gid)
end


--升级tips
function UIXinfaSkillBasic:OnBtnLvlUpRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local cfg = t_passiveskill[self.currSkillId];
	local nextCfg = t_passiveskill[cfg.next_lv];
	if not nextCfg then return end;
end

function UIXinfaSkillBasic:OnBtnLvlUpRollOut()
	TipsManager:Hide();
end;

---服务器返回学习技能后进行的操作及显示右侧信息 
function UIXinfaSkillBasic:OnSkillLearn(skillId)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--objSwf.infopanel.learnUpPanel.learnpanel.btnLearn.disabled = true;
	local list = {};
	self.currSkillId = skillId
	-- trace(self.skilllist)
	for i,vo in ipairs(self.skilllist) do
		if vo.skillId == skillId then
			vo.lvl = 1; 
			vo.lvlStr =math.floor(math.floor(skillId % 10000000) % 1000 ).."级1重";
			local cfg = t_passiveskill[skillId];
			if not cfg then
				vo.name ="" 
			else
				vo.name = cfg.name
			end         
			vo.lvlUrl = ResUtil:GetMagicSkillIcon("level_"..vo.lvl);
			-- vo.iconUrl = ResUtil:GetMagicSkillIcon("zhudongicon_"..i);
			vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon,"54")
			-- vo.iconLoad = ResUtil:GetMagicSkillIcon("zhudong_iconname_small_"..i);
			vo.showLvlUp = MountUtil:GetCanLvlUp(self.currSkillId,false,self.currSkillLvl,true);
			local uiData = UIData.encode(vo);
			objSwf.skillPanel.list.dataProvider[i-1] = uiData; 
			local uiItem = objSwf.skillPanel.list:getRendererAt(i-1);
			if uiItem then
				uiItem:setData(uiData);
			end
			break;
		end
	end
	self:ShowRight(skillId,1);   
end

---服务器返回升级技能后进行的操作及显示右侧信息 
function UIXinfaSkillBasic:OnMagicSkillLvlUp(skillId,lv)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.currSkillId = skillId;
	self.currSkillLvl = lv;
	for i,vo in ipairs(self.skilllist) do
		if math.floor(math.floor(vo.skillId / 1000000 ) * 100 + math.floor(vo.skillId % 1000000) / 1000 ) == math.floor(math.floor(skillId / 1000000 ) * 100 + math.floor(skillId % 1000000) / 1000 ) then
			vo.skillId = skillId;
			vo.lvl = lv;
			vo.lvlStr =math.floor(math.floor(skillId % 10000000) % 1000 ).."级"..lv.."重"; 
			local cfg = t_passiveskill[skillId];
			if not cfg then
				vo.name ="" 
			else
				vo.name = cfg.name
			end
			vo.lvlUrl = ResUtil:GetMagicSkillIcon("level_"..lv);
			vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon,"54")
			-- vo.iconUrl = ResUtil:GetMagicSkillIcon("beidongicon_"..i);
			-- vo.iconLoad = ResUtil:GetMagicSkillIcon("zhudong_iconname_small_"..i);
			local iscan,isCanTopo = MountUtil:GetCanLvlUp(self.currSkillId,false,self.currSkillLvl,true);
			-- vo.showLvlUp = iscan
			if self.currSkillLvl == 10 then
				-- vo.showLvlUp = isCanTopo
				if self.currSkillId == 20 then
					-- vo.showLvlUp = false;
				end
			end
			local uiData = UIData.encode(vo);
			objSwf.skillPanel.list.dataProvider[i-1] = uiData;
			local uiItem = objSwf.skillPanel.list:getRendererAt(i-1);   --得到list里的第n个item
			if uiItem then
				uiItem:setData(uiData);
			end
			break;
		end
	end
	self:ShowRight(skillId,lv);
end


--点击列表
function UIXinfaSkillBasic:OnListItemClick(e)
	if e.item.skillId ~= self.currSkillId then
		-- self:ChangeSkillBg(e.item.skillId)
		self:ShowRight(e.item.skillId,e.item.lvl);
	end
	self.currSkillId = e.item.skillId;
	if MagicSkillTuPoView:IsShow() then
		MagicSkillTuPoView:ClosePanel()
	end
end

-- 修改背景
function UIXinfaSkillBasic:ChangeSkillBg( itemId )
	local objSwf = self.objSwf
	if not objSwf then return; end
	local imgDesBgURL = ResUtil:GetMagicOrXinfaIcon( itemId,t_xinfa,t_xinfazu);
	if objSwf.desBgLoader.source ~= imgDesBgURL then
		objSwf.desBgLoader.source = imgDesBgURL
	end
end

-- 关闭操作
function UIXinfaSkillBasic:OnHide()
	if self.objSenDraw then
		self.objSenDraw:SetDraw(false);
		self.objSenDraw:SetUILoader(nil);
		self.viewMagicSkillPort = nil
	end
    if self.objAvatar then 
  		self.objAvatar:ResetAnima();
  	end;
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.skillPanel.list.selectedIndex = -1;
	self.skilllist ={};
	objSwf.infopanel.learnUpPanel.learnpanel.btnLearn:clearEffect();
	objSwf.infopanel.learnUpPanel.lvluppanel.btnLvlUp:clearEffect();
	objSwf.infopanel.learnUpPanel.tupopanel.btnTupo:clearEffect();
	if MagicSkillTuPoView:IsShow() then
		MagicSkillTuPoView:ClosePanel()
	end
end;

function UIXinfaSkillBasic:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	if self.objSenDraw then
		self.objSenDraw:SetDraw(false);
		self.objSenDraw:SetUILoader(nil);
	end
end
--------------------------------------------加载------------------------------------------
--得到场景文件名
function UIXinfaSkillBasic:GetGodSkillSen()
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaProf == 1 then
		return "luoli_godskill.sen";
	elseif playerinfo.eaProf == 2 then
		return "mozu_godskill.sen";
	elseif playerinfo.eaProf == 3 then
		return "renzu_godskillforxinfa.sen";
	elseif playerinfo.eaProf == 4 then
		return "yujie_godskill.sen";
	end
	return "";
end

--加载场景

function UIXinfaSkillBasic:DrawMagicSkillSen()
	local objSwf = self.objSwf;
	if not objSwf then return end; 
	local objSwfPos = UIManager:GetMcPos(objSwf)
	objSwf.senloader._x = -objSwfPos.x;
	objSwf.senloader._y = -objSwfPos.y;
	if self.objSenDraw then
		self.objSenDraw:SetUILoader(objSwf.senloader);
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end

	local w,h = 4000, 2000;
	if not self.objSenDraw then
		
		self.viewMagicSkillPort = _Vector2.new(w, h); 
		
		self.objSenDraw = UISceneDraw:new( "UIXinfaSkillBasic", objSwf.senloader, self.viewMagicSkillPort); 
	end
	self.objSenDraw:SetUILoader(objSwf.senloader);
	objSwf.senloader._x = 1050 / 2 - w / 2;
	objSwf.senloader._y = - (h / 2) - 50;
	self.objSenDraw:SetScene( self:GetGodSkillSen(), function()
			local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
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

			if not self.objAvatar then
				self.objAvatar = CPlayerAvatar:new();
				self.objAvatar.bIsAttack = false;
				self.objAvatar:CreateByVO(vo);
			end
			self.objAvatar:PlaySitAction();
			local info = MainPlayerModel.sMeShowInfo;
			local cfg = t_playerinfo[prof];
			-- self.objAvatar:SetProf(prof);
			-- self.objAvatar:SetDress(cfg.create_dress);
			self.objAvatar:SetArms(info.dwArms);
			self.objAvatar.objMesh.transform:setScaling(0.6, 0.6, 0.6);
			local list = self.objSenDraw:GetMarkers()
			-- UILog:print_table(list)
			local pos = list["marker"].pos;
			local pindex =  UIManager:GetMcPos(list["marker"].pos);
			local indexc = "marker"
			self.objAvatar:EnterUIScene(self.objSenDraw.objScene,list[indexc].pos,list[indexc].dir,list[indexc].scale, enEntType.eEntType_Player)
			--debug.debug()
		end)
	self.objSenDraw:SetDraw( true );
	self:OnTimer();
end


---------------------------------------------------------------
function UIXinfaSkillBasic:ShowAvatar()
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
	-- if not self.objAvatar then
	-- 	self.objAvatar = CPlayerAvatar:new();
	-- 	self.objAvatar:Create( 0, prof );
	-- end
	-- local info = MainPlayerModel.sMeShowInfo;
	-- local cfg = t_playerinfo[prof];
	-- self.objAvatar:SetProf(prof);
	-- self.objAvatar:SetDress(cfg.create_dress);
 --    self.objAvatar:SetArms(cfg.create_arm);   



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


    -- local groupid = t_xinfa[self.currSkillId].group_id;
    local cfg = nil;  --UIDrawSkillCfg[groupid];
    if not cfg then 
    	cfg= {
				EyePos = _Vector3.new(0,-20,20),  --0 -40 ,20
				LookPos = _Vector3.new(0,0,10),
				VPort = _Vector2.new(1000,600),
				Rotation = 0,
			 }
    end;

    if not self.objUIDraw then
		local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
		self.objUIDraw = UIDraw:new("UIXinfaSkillBasic", self.objAvatar, self.objSwf.uiLoader,
							cfg.VPort, cfg.EyePos, cfg.LookPos,
							0x00000000, nil, prof);
	else 
		self.objUIDraw:SetUILoader(self.objSwf.uiLoader);
		self.objUIDraw:SetCamera(cfg.VPort,cfg.EyePos,cfg.LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end

	self.meshDir = cfg.Rotation;
	self.objAvatar.objMesh.transform:setRotation(-10,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
end

---------------------------------------------------------------
local timerKey;
function UIXinfaSkillBasic:StartTimer()
	if timerKey then 
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
	end
	timerKey = TimerManager:RegisterTimer( function()
		self:OnTimer();
	end, 20000, 0); -- 20s 播放一次动作
end

function UIXinfaSkillBasic:OnTimer()	
	if not self.objAvatar then return end;
	self.objAvatar:PlayLeisureAction();
end

-------------------------界面监听-------------------------

function UIXinfaSkillBasic:ListNotificationInterests()
	return {NotifyConsts.SkillLearn,NotifyConsts.SkillLvlUp,
			NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagUpdate,
			NotifyConsts.XinfaSkillLearn,
			NotifyConsts.XinfaSkillUpgrade,NotifyConsts.XinfaSkillTupo,
			NotifyConsts.PlayerAttrChange,};
end

function UIXinfaSkillBasic:HandleNotification(name,body)
	if name==NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate  then
		self:ShowLearnUpPanel();
		self:CheckList()
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaBindGold then
			self:ShowLearnUpPanel();
		end
		self:CheckList()
	elseif name == NotifyConsts.XinfaSkillLearn then 
		 FloatManager:AddNormal( StrConfig['magicskill7'] );
		 self:OnSkillLearn(self.currSkillId);   
		 self.objSwf.infopanel.learnUpPanel.learnpanel.btnLearn.disabled = false;
		 self:CheckList()
	elseif name ==  NotifyConsts.XinfaSkillUpgrade then
		 FloatManager:AddNormal( StrConfig['magicskill9'] );
		 self.objSwf.infopanel.learnUpPanel.lvluppanel.siGrowValue:tweenProgress( SkillModel:GetSkill(self.currSkillId).lv, 10 )
		 self:OnMagicSkillLvlUp(self.currSkillId,SkillModel:GetSkill(self.currSkillId).lv);
		 self.objSwf.infopanel.learnUpPanel.lvluppanel.btnLvlUp.disabled = false;
		 self:CheckList()
	elseif name ==  NotifyConsts.XinfaSkillTupo then
		 FloatManager:AddNormal( StrConfig['magicskil21'] );
		 self.currSkillId = self.currSkillId +1;
		 self:OnMagicSkillLvlUp(self.currSkillId,SkillModel:GetSkill(self.currSkillId).lv);
		 self.objSwf.infopanel.learnUpPanel.tupopanel.btnTupo.disabled = false;
		 self:CheckList()
	end
	
end

----------------------------checklist------------------------------

--检查列表是否显示特效


