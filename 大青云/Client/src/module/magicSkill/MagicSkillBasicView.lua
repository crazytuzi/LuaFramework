--[[
绝学基础技能面板
houxudong
2016年5月15日
]]

_G.UIMagicSkillBasic = BaseUI:new("UIMagicSkillBasic");

--当前技能id
UIMagicSkillBasic.currSkillId = 0;    ---当前技能Id
UIMagicSkillBasic.currSkillLvl = 0;	  ---当前技能等级
--技能列表
UIMagicSkillBasic.skilllist = {};     ---主动技能列表
UIMagicSkillBasic.passkilllist = {};  ---被动技能列表
UIMagicSkillBasic.attrMaxNum = 4;     ---技能最大属性值
UIMagicSkillBasic.isShow = true;      ---点击后是否显示
UIMagicSkillBasic.isShow = false;

function UIMagicSkillBasic:Create()
	self:AddSWF("magicskillBasicPanel.swf",true,nil);  
end

local uiMagicSkillShowDes = false
local uiMagicSkillmouseMoveX = 0
function UIMagicSkillBasic:OnLoaded(objSwf)
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

	objSwf.PlayerSkill.click = function() self:PalyerSkillGo()end;
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

function UIMagicSkillBasic:OnSkillRollOver()
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	local tipsInfo = { skillId = self.currSkillId, condition = true,unShowLvlUpPrompt =true, get = self.currSkillLvl > 0 };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

function UIMagicSkillBasic:OnDelete()
	if self.objSenDraw then
		self.objSenDraw:SetUILoader(nil);
	end

end

function UIMagicSkillBasic:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
end

function UIMagicSkillBasic:OnLvlUprollOver(index)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = {};
	--print("鼠标悬浮的当前技能等级:",self.currSkillLvl)
	if not self.currSkillLvl then return; end
	if self.currSkillLvl <= 0 then
		list = SkillUtil:GetLvlUpCondition(self.currSkillId,true,self.currSkillLvl);
	else
		list = SkillUtil:GetLvlUpCondition(self.currSkillId,false,self.currSkillLvl); ----  0:29
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

function UIMagicSkillBasic:OnShow()
	self.isShow = false;
	self:ShowList();   			--显示列表
	-- self:DrawMagicSkillSen();
	self.PlayFpsList = {};
	self:OnBtnLvlUpRollOut();
	-- self:PalyerSkillGo();
	self:initPanelPoistion()
end


function UIMagicSkillBasic:initPanelPoistion()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.skillPanel._x,objSwf.skillPanel._y = 188.3,-143.15;
	objSwf.infopanel._x,objSwf.infopanel._y = 786,3.2;
end

function UIMagicSkillBasic:OnFullShow()
	-- self:DrawMagicSkillSen();
end

function UIMagicSkillBasic:IsShowLoading()
	return true;
end

--显示列表
function UIMagicSkillBasic:ShowList()
	self:ShowSkillList(true);
	--self:ShowPasSkillList()
end

--显示主动列表
function UIMagicSkillBasic:ShowSkillList(isselectone)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- print("role type：",SkillConsts:GetBasicShowType())      ---显示玩家类型   1 quannv  2 yaonv  3 guinan  4 shounan
	local list = SkillUtil:GetSkillListByShowMagicSkill(SkillConsts:GetBasicShowType() + 4);  --基础技能的显示类型
	for i=#list,1,-1 do
		local vo = list[i];
		local cfg = t_skill[vo.skillId];
		if not cfg then return; end
		local maxLvl = cfg.level;      
		if t_skillgroup[cfg.group_id] then     
			maxLvl = t_skillgroup[cfg.group_id].maxLvl;
		end
		if maxLvl <= 1 then
			table.remove(list,i);
		end
	end
	local curselectedIndex = objSwf.skillPanel.list.selectedIndex;

	self.skilllist = {};
	objSwf.skillPanel.list.dataProvider:cleanUp();
	local skillindex = 1;
	for i,vo in ipairs(list) do
		local listVO = self:GetSkillListVO(vo.skillId,vo.lvl,skillindex);
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
end

--获取列表VO
function UIMagicSkillBasic:GetSkillListVO(skillId,lvl,skillindex)
	local vo = {};
	vo.skillId = skillId;
	vo.lvl = lvl;
	vo.lvlUrl = "";
	vo.lvlUrl = ResUtil:GetMagicSkillIcon("level_"..lvl);      ----等级阶数
	
	local cfg = t_skill[skillId];

	if not cfg then
		vo.name ="" 
	else
		vo.name = cfg.name
	end
	vo.lvlStr = cfg.level.."级"..lvl.."重";
	local level;
	if skillId < 1000000000 then
		if vo.lvl > 0 then  ---更具等级获取不同的资源
			-- local skillIconUrl = ResUtil:GetSkillIconUrl(cfg.icon,"54");
			-- if objSwf.infopanel.iconLoader.source ~= skillIconUrl then
			-- 	objSwf.infopanel.iconLoader.source = skillIconUrl
			-- end

			vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon,"54");
			-- vo.iconUrl = ResUtil:GetMagicSkillIcon("zhudongicon_"..skillindex);              --- 鼠标事件显示技能描述
			vo.iconLoad = ResUtil:GetMagicSkillIcon("zhudong_iconname_small_"..skillindex);  --- 技能的icon名字
			vo.state = MountUtil:GetCanLvlUp(skillId,false,lvl);   --- 是否可以升级
			local iscan,isCanTopo = MountUtil:GetCanLvlUp(skillId,false,lvl); 
			vo.showLvlUp = iscan 
			if lvl == 10 then
				vo.showLvlUp = isCanTopo
				for k,v in pairs(t_skill) do
					if v.id == self.currSkillId then
						level = v.level
					end
				end
				if level == 20 then
					vo.showLvlUp = false;
				end
			end
		else
			vo.iconUrl = ImgUtil:GetGrayImgUrl(ResUtil:GetSkillIconUrl(cfg.icon,"54"));
			vo.iconLoad = ImgUtil:GetGrayImgUrl(ResUtil:GetMagicSkillIcon("zhudong_iconname_small_"..skillindex));
			vo.state = MountUtil:GetCanLvlUp(skillId,true,lvl);
			vo.showLvlUp = MountUtil:GetCanLvlUp(skillId,true,lvl);
		end
	end
	return vo;
end

--显示右侧信息
function UIMagicSkillBasic:ShowRight(skillId,lvl)
	self.currSkillId = skillId;
	self.currSkillLvl = lvl;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:ChangeSkillBg(skillId)
	local cfg = t_skill[skillId];
	if not cfg then
		return;
	end
	if cfg then
		if skillId < 1000000000 then
			local iconUrl = ResUtil:GetSkllNameIcon(cfg.nameIcon)
			if objSwf.infopanel.nameLoader1.source ~= iconUrl then
				objSwf.infopanel.nameLoader1.source = iconUrl
			end
			local level;
			for k,v in pairs(t_skill) do
				if v.id == self.currSkillId then
					level = v.level
				end
			end
			if not level then return; end
			objSwf.infopanel.tfLvl.htmlText = string.format(StrConfig['magicskill001'],level,lvl);   ---%s/%s重
		end
		if cfg.icon == nil then
			return;
		end
		local skillIconUrl = ResUtil:GetSkillIconUrl(cfg.icon,"54");
		if objSwf.infopanel.iconLoader.source ~= skillIconUrl then
			objSwf.infopanel.iconLoader.source = skillIconUrl
		end
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

function UIMagicSkillBasic:OnbtnrollOver(  )
	self.isShow = true
	self:CheckShowOrFalse(true)
	
end
----隐藏下已等级的属性加成
function UIMagicSkillBasic:OnBtnRollOut(  )
	self.isShow = false
	self:CheckShowOrFalse(false)
	
end

function UIMagicSkillBasic:CheckShowOrFalse( isShow )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not isShow then
		local attrs = {};
		self:ShowAttrs(attrs)
		return;
	end
	local attrList;
	local nextAttrList;
	for i=1,self.attrMaxNum do 
		local column;
		for k,v in pairs(t_juexue) do
			if v.spot == self.currSkillLvl and v.id == self.currSkillId then
				column = v.column
			end
		end
		if not column then return; end
		local cfg = t_juexue[column]
		local nextCfg = t_juexue[column + 1]
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
		 			end
				end
			end
	end
end

--显示属性
function UIMagicSkillBasic:ShowAttrs(strattr)
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
		for k,v in pairs(t_juexue) do
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
		local cfg = t_juexue[column]
		local nextCfg = t_juexue[column+1]
		if not cfg then return; end
		strattr = cfg.add_attr
		if nextCfg then
			nextAttr = nextCfg.add_attr
		else
			-- 处理最底部的边界问题
			nextAttr = strattr
		end
		--@reason 特殊处理边界问题
		--[[
		if self.currSkillLvl == 10 then
			nextAttr = cfg.add_attr
		end
		--]]
		
	end
	local attrList = split(strattr,"#");      --当前的属性list
	local nextAttrList = split(nextAttr,"#"); --下一级的属性list
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

			if vo.type == enAttrType.eaGongJi and nextVo.type == enAttrType.eaGongJi then           -- att
		 		-- objSwf.infopanel["labletype"..i].text = UIStrConfig["lovelypet1001"];
		 		objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaGongJi];
		 		objSwf.infopanel["tfval"..i].text = vo.val;
		 		objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
			elseif vo.type == enAttrType.eaFangYu and nextVo.type == enAttrType.eaFangYu then       -- def
				objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaFangYu];
				objSwf.infopanel["tfval"..i].text = vo.val;
		 		objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
			elseif vo.type == enAttrType.eaMaxHp and nextVo.type == enAttrType.eaMaxHp then         -- hp
			 	objSwf.infopanel["labletype"..i].text = enAttrTypeName[enAttrType.eaMaxHp];
			 	objSwf.infopanel["tfval"..i].text = vo.val;
		 		objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
		 	end
		 	
		end
		-- local nextattrvo = split(nextAttrList[i],",");
		-- local nextVo = {};
		-- nextVo.type = AttrParseUtil.AttMap[nextattrvo[1]];
		-- nextVo.val = tonumber(nextattrvo[2]);

		-- if vo.type == enAttrType.eaGongJi then           --- att
		--  objSwf.infopanel["labletype"..i].text = UIStrConfig["lovelypet1001"]..":";
		--  elseif vo.type == enAttrType.eaFangYu then      --- def
		-- 	objSwf.infopanel["labletype"..i].text = UIStrConfig["lovelypet1002"];
		-- elseif vo.type == enAttrType.eaMaxHp then        --- hp
		-- 	 objSwf.infopanel["labletype"..i].text = UIStrConfig["lovelypet1003"];
		--  end
		-- objSwf.infopanel["labletype"..i].text = enAttrTypeName[AttrParseUtil.AttMap[attrvo[1]]];
		-- objSwf.infopanel["tfval"..i].text = vo.val;
		-- objSwf.infopanel["tfvaltext"..i].text =nextVo.val - vo.val;
	end
	if self.isShow then
		self:CheckShowOrFalse(true)
	end
end

--显示战斗力
function UIMagicSkillBasic:ShowFight()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local  column;
	for k,v in pairs(t_juexue) do
		if v.id == self.currSkillId and v.spot == self.currSkillLvl then
			column = v.column;
		end
	end
	if not column then
		objSwf.infopanel.numFight.num = 0  
		return; 
	end
	local cfg = t_juexue[column]
	if not cfg then return end
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
	objSwf.infopanel.numFight.num = fight + powerFight;
end

function UIMagicSkillBasic:OnSortNum(obj)
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
function UIMagicSkillBasic:ShowLearnUpPanel()
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
		local stritem,itemList,itemIcon,needNum = self:GetItemVo(self.currSkillId,true,0);   ----区分
		if #itemList == 0 then
			return;
		end
		local num1 = BagModel:GetItemNumInBag(itemList[1].id) or 0;
		local state = MountUtil:GetCanLvlUp(self.currSkillId,true,self.currSkillLvl);
		objSwf.infopanel.learnUpPanel.learnpanel.iconLoader.source = ResUtil:GetSpecialSkillIconUrl(itemIcon[1],"54");
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
		local stritem,itemList,itemIcon,needNum = self:GetItemVo(self.currSkillId,false,self.currSkillLvl);        ----区分
		if #itemList == 0 then
			return;
		end
		local num1 = BagModel:GetItemNumInBag(itemList[1].id) or 0;
		objSwf.infopanel.learnUpPanel.lvluppanel.iconLoader.source = ResUtil:GetSpecialSkillIconUrl(itemIcon[1],"54");
		-- objSwf.infopanel.learnUpPanel.lvluppanel.btnItem.htmlLabel = string.format(stritem[1]).. string.format( StrConfig["magicskill12"],needNum[1]);
		-- 进度条文本
		-- objSwf.infopanel.learnUpPanel.lvluppanel.loaderTxt.htmlText = self.currSkillLvl..'/'..10
		objSwf.infopanel.learnUpPanel.lvluppanel.loaderTxt.htmlText = string.format(StrConfig['skill00011'],self.currSkillLvl,10);
		if UIMagicSkillBasic:CanFeedItem(itemList[1].id,itemList[1].num) then   --- 消耗物品的id和物品的数量
			objSwf.infopanel.learnUpPanel.lvluppanel.btnLvlUp:showEffect(ResUtil:GetButtonEffect10());
			objSwf.infopanel.learnUpPanel.lvluppanel.btnItem2.htmlLabel = StrConfig['magicskill4'] .. string.format( StrConfig["magicskill1"],num1);   ----升级条件
			objSwf.infopanel.learnUpPanel.lvluppanel.btnItem.htmlLabel = string.format( StrConfig["magicski1"],stritem[1],needNum[1]);
		else
			objSwf.infopanel.learnUpPanel.lvluppanel.btnLvlUp:clearEffect();
			objSwf.infopanel.learnUpPanel.lvluppanel.btnItem2.htmlLabel = StrConfig['magicskill4'] .. string.format( StrConfig["magicskill2"],num1);   ---红色, 升级条件不足
			objSwf.infopanel.learnUpPanel.lvluppanel.btnItem.htmlLabel = string.format( StrConfig["magicski2"],stritem[1],needNum[1]);
		end
		objSwf.infopanel.learnUpPanel.lvluppanel.siGrowValue:setProgress(self.currSkillLvl, 10 )
	elseif self.currSkillLvl == maxLvl then
		local level;
		for k,v in pairs(t_skill) do
			if v.id == self.currSkillId then
				level = v.level
			end
		end
		 if level == 20 then
		 	objSwf.infopanel.learnUpPanel.imgLevelMax._visible = true;
		 else
		 	local stritem,itemList,itemIcon,needNum = self:GetItemVo(self.currSkillId,false,self.currSkillLvl); 
		 	objSwf.infopanel.learnUpPanel.tupopanel.iconLoader.source = ResUtil:GetSpecialSkillIconUrl(itemIcon[1],"54");--"img://resfile/itemicon/itemicon_ziyuan_lingli_54.png";
		 	-- 进度条文本
			-- objSwf.infopanel.learnUpPanel.tupopanel.loaderTxt.htmlText = self.currSkillLvl..'/'..10
			objSwf.infopanel.learnUpPanel.tupopanel.loaderTxt.htmlText = string.format(StrConfig['skill00011'],self.currSkillLvl,10);
		 	local num1 = 0
		 	if itemList[1].id < 100 then
		 		num1 = MainPlayerModel.humanDetailInfo.eaBindGold ;
		 	else
		 		num1 = BagModel:GetItemNumInBag(itemList[1].id) ;
		 	end
		 	local state,isCanTopo = MountUtil:GetCanLvlUp(self.currSkillId,false,self.currSkillLvl);
		 	if not stritem then return; end
		 	-- 物品名称
		 	objSwf.infopanel.learnUpPanel.tupopanel.btnItem.htmlLabel = string.format(stritem[1]).. string.format( StrConfig["magicskill12"],needNum[1]);
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
function UIMagicSkillBasic:GetItemVo(skillId,learn,level)   
	local list = SkillUtil:GetLvlUpCondition(skillId,learn,level);     ----学习 learn = true || 升级  shengji = false 
	local itemNameStr = {};
	local itemNeedNum = {};
	local itemList = {};
	local itemIcon = {};
	for i,vo in ipairs(list) do
		if vo and vo.id and vo.id > 0 then
			local itemvo = t_item[vo.id];
			table.push(itemIcon,itemvo.icon)
			table.push(itemNameStr,itemvo.name);  --.."X"..vo.num
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
function UIMagicSkillBasic:CanFeedItem(id,num)
	local BgItemNum = BagModel:GetItemNumInBag(id);
	return BgItemNum >= num
end

--点击学习
function UIMagicSkillBasic:OnBtnLearnClick()
	-- print("---------------点击学习按钮",self.currSkillId,self.currSkillLvl)
	local state = MountUtil:GetCanLvlUp(self.currSkillId,true,self.currSkillLvl);
	if not state then FloatManager:AddNormal( StrConfig['magicskill5'] ); return end
	if not self.currSkillId then return; end
	local cfgs;
	for k,v in pairs(t_juexue) do	
		if v.id == self.currSkillId and v.spot == 1 then
			local  column = v.column
			cfgs = t_juexue[column]
		end
	end
	local gid = cfgs.juexuezu;
	-- print("---------------learn gid:",gid)
	SkillController:LearnMagicSkill(MagicSkillConsts.magicSkillType_juexue,MagicSkillConsts.magicSkillOper_xuexi,gid)
end

--点击升级
function UIMagicSkillBasic:OnBtnLvlUpClick()
	-- print("---------------点击升级按钮",self.currSkillId,SkillModel:GetSkill(self.currSkillId).lv)
	local state = MountUtil:GetCanLvlUp(self.currSkillId,false,SkillModel:GetSkill(self.currSkillId).lv);   --- add self.currSkillLvl
	self.currSkillLvl = SkillModel:GetSkill(self.currSkillId).lv
	if not state then FloatManager:AddNormal( StrConfig['magicskill5'] ); return end
	local cfgs;
	for k,v in pairs(t_juexue) do
		if v.id == self.currSkillId and v.spot == SkillModel:GetSkill(self.currSkillId).lv then
			local  column = v.column
			cfgs = t_juexue[column]
		end
	end
	local gid = cfgs.juexuezu;
	self.objSwf.infopanel.learnUpPanel.lvluppanel.btnLvlUp.disabled = true;
	SkillController:LearnMagicSkill(MagicSkillConsts.magicSkillType_juexue,MagicSkillConsts.magicSkillOper_shengji,gid)
end

--点击突破
function UIMagicSkillBasic:OnBtnTupoClick()
	local level = nil;
	for k,v in pairs(t_skill) do
		if v.id == self.currSkillId then
			level = v.level
		end
	end
	if not level then return; end
	if level == 20 and SkillModel:GetSkill(self.currSkillId).lv == 10 then  
		 self:ShowLearnUpPanel()
		return;
	end
	local skill = SkillModel:GetSkill(self.currSkillId)
	if skill then
		local state , tupoState= MountUtil:GetCanLvlUp(self.currSkillId,false,SkillModel:GetSkill(self.currSkillId).lv);   --- add self.currSkillLvl
		self.currSkillLvl = SkillModel:GetSkill(self.currSkillId).lv
		if not state then FloatManager:AddNormal( StrConfig['magicskill5'] ); return; end
		if not tupoState then FloatManager:AddNormal( StrConfig['magicskill5'] ); return; end
		local cfgs;
		for k,v in pairs(t_juexue) do
			if v.id == self.currSkillId and v.spot == SkillModel:GetSkill(self.currSkillId).lv then
				local  column = v.column
				cfgs = t_juexue[column]
			end
		end
		if not cfgs then return; end
		local gid = cfgs.juexuezu;
		-- print("---------------点击突破:",self.currSkillId,SkillModel:GetSkill(self.currSkillId).lv,gid)
		if MagicSkillTuPoView:IsShow() then
			return
		else
			MagicSkillTuPoView:OnOpen( gid,self.currSkillId,MagicSkillConsts.magicSkillType_juexue)
		end
	end
end


--升级tips
function UIMagicSkillBasic:OnBtnLvlUpRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local cfg = t_skill[self.currSkillId];
	local nextCfg = t_skill[cfg.next_lv];
	if not nextCfg then return end;
end
function UIMagicSkillBasic:OnBtnLvlUpRollOut()
	TipsManager:Hide();
end;

---服务器返回学习技能后进行的操作及显示右侧信息 
function UIMagicSkillBasic:OnSkillLearn(skillId)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = {};
	self.currSkillId = skillId
	if skillId < 1000000000 then
		for i,vo in ipairs(self.skilllist) do
			if vo.skillId == skillId then
				vo.lvl = 1; 
				local cfg = t_skill[skillId];
				vo.lvlStr = cfg.level.."级1重";
				local cfg = t_skill[skillId];
				if not cfg then
					vo.name ="" 
				else
					vo.name = cfg.name
				end         

				vo.lvlUrl = ResUtil:GetMagicSkillIcon("level_"..vo.lvl);
				vo.iconUrl =  ResUtil:GetSkillIconUrl(cfg.icon,"54")
				-- vo.iconUrl = ResUtil:GetMagicSkillIcon("zhudongicon_"..i);
				vo.iconLoad = ResUtil:GetMagicSkillIcon("zhudong_iconname_small_"..i);
				vo.showLvlUp = MountUtil:GetCanLvlUp(self.currSkillId,false,self.currSkillLvl);
				local uiData = UIData.encode(vo);
				objSwf.skillPanel.list.dataProvider[i-1] = uiData;  ---i-1
				local uiItem = objSwf.skillPanel.list:getRendererAt(i-1);
				if uiItem then
					uiItem:setData(uiData);
				end
				break;
			end
		end
	end
	self:ShowRight(skillId,1);   
end

---服务器返回升级技能后进行的操作及显示右侧信息 
function UIMagicSkillBasic:OnMagicSkillLvlUp(skillId,lv)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.currSkillId = skillId;
	self.currSkillLvl = lv;
	local cfg;
	local cfgs;
	local gid;
	local juexueGid;
	if skillId < 1000000000 then
		-- trace(self.skilllist)
		for i,vo in ipairs(self.skilllist) do
			--@reason 获取当前技能列表技能的组id
			for k,v in pairs(t_juexue) do
				if v.id == vo.skillId then
					local skill = SkillModel:GetSkill(vo.skillId)
					--[[
					if skill and v.spot == skill.lv then
						local column = v.column;
						cfg = t_juexue[column]
						gid  = cfg.juexuezu
					end
					--]]
					if v.spot == 1 then
						local column = v.column;
						cfg = t_juexue[column]
						gid  = cfg.juexuezu
						-- print("--------gid",gid)
					end
				end
			end
			-- 获得当前技能的组id
			for k,v in pairs(t_juexue) do
				if v.id == skillId and v.spot == lv then
					local  column = v.column
					cfgs = t_juexue[column]
					juexueGid = cfgs.juexuezu
					-- print("--------juexueGid",juexueGid)
				end
			end
			if  gid == juexueGid then 
				vo.skillId = skillId;
				vo.lvl = lv;
				local cfg = t_skill[skillId];
				if not cfg then return; end
				-- debug.debug()
				vo.lvlStr = cfg.level.."级"..lv.."重";
				local cfg = t_skill[skillId];
				if not cfg then
					vo.name ="" 
				else
					vo.name = cfg.name
				end
				vo.lvlUrl = ResUtil:GetMagicSkillIcon("level_"..lv);
				vo.iconUrl =  ResUtil:GetSkillIconUrl(cfg.icon,"54")
				-- vo.iconUrl = ResUtil:GetMagicSkillIcon("zhudongicon_"..i);
				vo.iconLoad = ResUtil:GetMagicSkillIcon("zhudong_iconname_small_"..i);
				local iscan,isCanTopo = MountUtil:GetCanLvlUp(self.currSkillId,false,self.currSkillLvl);
				vo.showLvlUp = iscan 
				if self.currSkillLvl == 10 then
					vo.showLvlUp = isCanTopo
					if cfg.level == 20 then
						vo.showLvlUp = false;
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
	end
	self:ShowRight(skillId,lv);
end

--检查列表是否显示特效
function UIMagicSkillBasic:CheckList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.isCanLvUpNum = 0    --如果红点提示需要显示数字，记录可以升级的数量
	for i,vo in ipairs(self.skilllist) do
		local showLvlUp = false;
		local learnCanLvUp = false;
		local skillVO = SkillModel:GetSkill(vo.skillId);
		-- print("技能的id,lv",vo.skillId,vo.lvl)
		if skillVO then
			local iscan,isCanTopo = self:GetSkillCanLvlUp(vo.skillId,vo.lvl);
			showLvlUp = iscan;
			if vo.lvl == 10 then
				showLvlUp = isCanTopo;
			end
			-- print("sss1",showLvlUp)
			if showLvlUp then
				self.isCanLvUpNum = self.isCanLvUpNum +1;
			end
		elseif vo.lvl == 0 then                           --处理技能可以学习时也可有提示
			showLvlUp = self:GetSkillCanLearn(vo.skillId);
			-- print("sss2",showLvlUp)
			if showLvlUp then
				self.isCanLvUpNum = self.isCanLvUpNum +1;
			end
		else
			-- print("sss3",showLvlUp)
			showLvlUp = false;
		end
		if vo.showLvlUp ~= showLvlUp then
			local cfg = t_skill[vo.skillId];
			-- vo.lvl = SkillModel:GetSkill(vo.skillId) and cfg.level or 0;   
			-- vo.lvlStr = self:GetSkillListVO(vo.skillId,vo.lvl,1).lvlStr;
			vo.showLvlUp = showLvlUp;
			local uiData = UIData.encode(vo);
			objSwf.skillPanel.list.dataProvider[i-1] = uiData;
			local uiItem = objSwf.skillPanel.list:getRendererAt(i-1);
			if uiItem then
				uiItem:setData(uiData);
			end
		end
	end
	-- print("有几个可以升级呢:",self.isCanLvUpNum)
	-- Notifier:sendNotification(NotifyConsts.RedPointMagicSkill,{isCanLvUpNum = self.isCanLvUpNum})
end

--点击列表
function UIMagicSkillBasic:OnListItemClick(e)
	if e.item.skillId ~= self.currSkillId then
		-- self:ChangeSkillBg(e.item.skillId)
		self:ShowRight(e.item.skillId,e.item.lvl);
	end
	self.currSkillId = e.item.skillId;
	-- self:PalyerSkillGo();
	if MagicSkillTuPoView:IsShow() then
		MagicSkillTuPoView:ClosePanel()
	end
end

-- 修改背景
function UIMagicSkillBasic:ChangeSkillBg( itemId )
	local objSwf = self.objSwf
	if not objSwf then return; end
	local imgDesBgURL = ResUtil:GetMagicOrXinfaIcon( itemId,t_juexue,t_juexuezu);
	if objSwf.desBgLoader.source ~= imgDesBgURL then
		objSwf.desBgLoader.source = imgDesBgURL
	end
end

--技能是否可以学习
function UIMagicSkillBasic:GetSkillCanLearn(skillId)
	local conditionlist = SkillUtil:GetLvlUpCondition(skillId,true,0);
	for i,vo in ipairs(conditionlist) do
		if not vo.state then
			return false;
		end
	end
	return true;
end

--获取技能是否可升级
function UIMagicSkillBasic:GetSkillCanLvlUp(skillId,lv)

	local conditionlist = SkillUtil:GetLvlUpCondition(skillId,false,lv);
	local iscan = false;
	local isCanTopo = false;
	for i,vo in ipairs(conditionlist) do
		if vo.state == false then
			return false;
		else
			iscan = true;
		end
		if vo.breach then  --突破消耗
			isCanTopo = true;
		end
	end
	return iscan,isCanTopo;
end

-- 关闭操作
function UIMagicSkillBasic:OnHide()
	if self.objSenDraw then
		self.objSenDraw:SetDraw(false);
		self.objSenDraw:SetUILoader(nil);
	end
	if self.objAvatar then 
  		self.objAvatar:ResetAnima();
		self.isPlaySkill = false;
  	end;
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	local objSwf = self.objSwf;
	objSwf.skillPanel.list.selectedIndex = -1;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	Tween:KillOf(objSwf.infopanel)
	Tween:KillOf(objSwf.skillPanel)
	self.skilllist ={};
	objSwf.infopanel.learnUpPanel.learnpanel.btnLearn:clearEffect();
	objSwf.infopanel.learnUpPanel.lvluppanel.btnLvlUp:clearEffect();
	objSwf.infopanel.learnUpPanel.tupopanel.btnTupo:clearEffect();
	if MagicSkillTuPoView:IsShow() then
		MagicSkillTuPoView:ClosePanel()
	end
end

function UIMagicSkillBasic:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	if self.objSenDraw then
		self.objSenDraw:SetDraw(false);
		self.objSenDraw:SetUILoader(nil);
	end
end

---------------------------------*********加载**********----------------------------

UIMagicSkillBasic.isPlaySkill = false;  --控制技能没有释放完点击
function UIMagicSkillBasic:PalyerSkillGo(boocs)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if boocs == true then return end;
	if self.isPlaySkill == true then return end;
	--需要移动图层的初始位置，需和flash上面的保持一致 
	objSwf.skillPanel._x,objSwf.skillPanel._y = 188.3,-143.15;
	objSwf.infopanel._x,objSwf.infopanel._y = 786,3.2;

	local cfg = t_skill[self.currSkillId];
	if not cfg then
		FloatManager:AddNormal( StrConfig["magicskill6"], objSwf.PlayerSkill);
		return 
	end;

	Tween:To(objSwf.skillPanel,0.5,{_x=-76,_y=-136.45,ease=Quart.easeIn},{onComplete = function()
			-- 播放技能
			local con = function()self:skillPlayOver() end
			if self.objAvatar then
				self.objAvatar:PlayTragetPfxForMagicSkillOnUI(self.currSkillId,con)
			end
		end})

	Tween:To(objSwf.infopanel,0.5,{_x=1046,_y=3.2,ease=Quart.easeIn})
	self.isPlaySkill = true;


	--[[
	local con = function()self:skillPlayOver() end    --con是技能释放后的回调函数
	self.objAvatar:PlaySkillOnUI(self.currSkillId,con)
	self.isPlaySkill = true;
	--]]

end;

function UIMagicSkillBasic:skillPlayOver()
	-- self.isPlaySkill = false; 
	local objSwf = self.objSwf;
	Tween:To(objSwf.skillPanel,0.5,{_x=188.3,_y=-143.15,ease=Quart.easeIn},{onComplete = function()
			self.isPlaySkill = false; 
			end})

	Tween:To(objSwf.infopanel,0.5,{_x=786,_y=3.2,ease=Quart.easeIn})
end;

-- 播放技能
UIMagicSkillBasic.PlayFpsList = {};
function UIMagicSkillBasic:PlaySkill()
	local ro = 0;
	local groupid = t_skill[self.currSkillId].group_id
	local cof = UIDrawSkillCfg[groupid];   ---获取人物技能配置  contain players pos and rotation
	if not cof then 
		ro = 0 return 
	else
		ro = cof.Rotation
	end;

	--self.objAvatar.objMesh.transform:setTranslation(0,0,0);
	--self.objAvatar.objMesh.transform:setRotation(0,0,1,ro);
	local state = self.PlayFpsList[self.currSkillId];
	if not state then 
		self.objAvatar:PlaySkillOnUI(self.currSkillId)
		self.PlayFpsList[self.currSkillId] = true;
	end;
end;

--得到场景文件名
function UIMagicSkillBasic:GetGodSkillSen()
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaProf == 1 then
		return "luoli_godskill.sen";
	elseif playerinfo.eaProf == 2 then
		return "mozu_godskill.sen";
	elseif playerinfo.eaProf == 3 then
		return "renzu_godskill.sen";
	elseif playerinfo.eaProf == 4 then
		return "yujie_godskill.sen";
	end
	return "";
end

--加载场景
local viewMagicSkillPort;
function UIMagicSkillBasic:DrawMagicSkillSen()
	local objSwf = self.objSwf;
	if not objSwf then return end;  
	local w,h = 4000, 2000;
	if not self.objSenDraw then
		--local w,h = UIManager:GetWinSize();
		viewMagicSkillPort = _Vector2.new(w, h);
		self.objSenDraw = UISceneDraw:new( "UIMagicSkillBasic", objSwf.senloader, viewMagicSkillPort); 
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
			if self.objAvatar then
				self.objAvatar:ExitMap();
				self.objAvatar = nil;
			end
			if not self.objAvatar then
				self.objAvatar = CPlayerAvatar:new();
				self.objAvatar.bIsAttack = false;
				self.objAvatar:CreateByVO(vo);
			end
			local info = MainPlayerModel.sMeShowInfo;
			local cfg = t_playerinfo[prof];
			-- self.objAvatar:SetProf(prof);
			-- self.objAvatar:SetDress(cfg.create_dress);
			self.objAvatar:SetArms(info.dwArms);
			self.objAvatar.objMesh.transform:setScaling(0.6, 0.6, 0.6);
			local list = self.objSenDraw:GetMarkers()
			local indexc = "marker"
			self.objAvatar:EnterUIScene(self.objSenDraw.objScene,list[indexc].pos,list[indexc].dir,list[indexc].scale, enEntType.eEntType_Player)
		end)
	self.objSenDraw:SetDraw( true );
	UISceneDraw:Destroy()
end
-------------------------界面监听-------------------------

function UIMagicSkillBasic:ListNotificationInterests()
	return {NotifyConsts.SkillLearn,NotifyConsts.SkillLvlUp,
			NotifyConsts.BagItemNumChange,NotifyConsts.MagicSkillLearn,
			NotifyConsts.MagicSkillUpgrade,NotifyConsts.MagicSkillTupo,
			NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagUpdate,
			NotifyConsts.PlayerAttrChange};
end

function UIMagicSkillBasic:HandleNotification(name,body)
-- BagItemNumChange
	if name==NotifyConsts.BagAdd or name==NotifyConsts.BagRemove or name==NotifyConsts.BagUpdate then
		self:ShowLearnUpPanel();
		self:CheckList();
	elseif name == NotifyConsts.MagicSkillLearn then
		 FloatManager:AddNormal( StrConfig['magicskill7'] );
		 self:OnSkillLearn(self.currSkillId);   
		 self:CheckList();
	elseif name ==  NotifyConsts.MagicSkillUpgrade then
		 FloatManager:AddNormal( StrConfig['magicskill9'] );
		 self.objSwf.infopanel.learnUpPanel.lvluppanel.siGrowValue:tweenProgress( SkillModel:GetSkill(self.currSkillId).lv, 10 )
		 self:OnMagicSkillLvlUp(self.currSkillId,SkillModel:GetSkill(self.currSkillId).lv);
		 self.objSwf.infopanel.learnUpPanel.lvluppanel.btnLvlUp.disabled = false;
		 self:CheckList();
	elseif name ==  NotifyConsts.MagicSkillTupo then
		 FloatManager:AddNormal( StrConfig['magicskil21'] );
		 self.currSkillId = self.currSkillId +1;
		 self:OnMagicSkillLvlUp(self.currSkillId,SkillModel:GetSkill(self.currSkillId).lv);
		 self.objSwf.infopanel.learnUpPanel.tupopanel.btnTupo.disabled = false;
		 self:CheckList();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaLevel or body.type==enAttrType.eaZhenQi or 
			body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold then
			self:CheckList();
			self:ShowLearnUpPanel();
			-- self:ShowRight(self.currSkillId,SkillModel:GetSkill(self.currSkillId).lv)
		end
	end
end

--面板中详细信息为隐藏面板，不计算到总宽度内
function UIMagicSkillBasic:GetWidth()
	return 1146;
end

function UIMagicSkillBasic:GetHeight()
	return 687;
end
