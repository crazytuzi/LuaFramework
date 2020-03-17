--[[
技能面板：基础技能
lizhuangzhuang
2014年10月9日14:15:00
houxudong
2016年7月21日17:52:00
]]

_G.UISkillBasic = BaseUI:new("UISkillBasic");

--当前技能id
UISkillBasic.currSkillId = 0;
UISkillBasic.currSkillLvl = 0;
--技能列表
UISkillBasic.skilllist = {};

function UISkillBasic:Create()
	self:AddSWF("skillBasicPanel.swf",true,nil);
end

function UISkillBasic:OnLoaded(objSwf)
	-- objSwf.senloader.hitTestDisable = true;
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
	objSwf.learnPanel.btnLearn.click = function() self:OnBtnLearnClick(); end
	objSwf.lvlUpPanel.btnLvlUp.click = function() self:OnBtnLvlUpClick(); end
	objSwf.lvlUpPanel.btnLvlUp.rollOver = function() self:OnBtnLvlUpRollOver(); end
	objSwf.lvlUpPanel.btnLvlUp.rollOut = function() self:OnBtnLvlUpRollOut(); end
	objSwf.lvlUpPanel.btnquicklyLvlUp.click = function() self:OnBtnQuicklyLvlUpClick(); end
	objSwf.lvlUpPanel.btnquicklyLvlUp.rollOver = function() self:OnBtnLvlUpRollOver(); end
	objSwf.lvlUpPanel.btnquicklyLvlUp.rollOut = function() self:OnBtnLvlUpRollOut(); end
	objSwf.learnPanel.btnToolInfo.rollOver = function() self:OnBtnToolInfoRollOver(); end
	objSwf.learnPanel.btnToolInfo.rollOut = function() TipsManager:Hide(); end
	objSwf.lvlUpPanel.btnToolInfo.rollOver = function() self:OnBtnToolInfoRollOver(); end
	objSwf.lvlUpPanel.btnToolInfo.rollOut = function() TipsManager:Hide(); end
	
	objSwf.PlayerSkill.click = function() self:PalyerSkillGo()end;
	self.PlayerSkillWidth = objSwf.PlayerSkill._width;
end

function UISkillBasic:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UISkillBasic:OnShow()
	self:DrawMagicSkillSen();
	self:ShowList();
	self.PlayFpsList = {};
	self:OnBtnLvlUpRollOut();
	-- self:PalyerSkillGo();
	-- local objSwf = self.objSwf;
	-- if not objSwf then return; end
	-- local loader = self:SetRedPoint(objSwf.PlayerSkill,52,RedPointConst.showRedPoint,RedPointConst.showNum)
	-- loader._x = self.PlayerSkillWidth;
	self:initPanelPoistion()
end

function UISkillBasic:initPanelPoistion()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.list._x,objSwf.list._y = 5,23;
	objSwf.panel3._x,objSwf.panel3._y = 800.10,57.05;
	objSwf.lvlUpPanel._x,objSwf.lvlUpPanel._y = 768.75,90;
	objSwf.learnPanel._x,objSwf.lvlUpPanel._y = 768.75,90;
end

UISkillBasic.isPlaySkill = false;
function UISkillBasic:PalyerSkillGo(boocs)
	local objSwf = self.objSwf;
	if self.isPlaySkill == true then return end;
	objSwf.list._x,objSwf.list._y = 5,23;
	objSwf.panel3._x,objSwf.panel3._y = 800.10,57.05;
	objSwf.lvlUpPanel._x,objSwf.lvlUpPanel._y = 768.75,90;
	objSwf.learnPanel._x,objSwf.lvlUpPanel._y = 768.75,90;

	if boocs == true then return end;

	Tween:To(objSwf.list,0.5,{_x=-287,_y=60,ease=Quart.easeIn},{onComplete = function()
			-- 播放技能
			local con = function()self:skillPlayOver() end
			self.objAvatar:PlayNormalAttackOnUI(self.currSkillId,con)
		end})
	Tween:To(objSwf.panel3,0.5,{_x=1268,_y=24,ease=Quart.easeIn})

	Tween:To(objSwf.lvlUpPanel,0.5,{_x=1345,_y=32.05,ease=Quart.easeIn})
	self.isPlaySkill = true;

	Tween:To(objSwf.learnPanel,0.5,{_x=1345,_y=32.05,ease=Quart.easeIn})
	self.isPlaySkill = true;
	
end;

function UISkillBasic:skillPlayOver()
	local objSwf = self.objSwf;
	Tween:To(objSwf.list,0.5,{_x=5,_y=23,ease=Quart.easeIn},{onComplete = function()
			self.isPlaySkill = false; 
			end})

	Tween:To(objSwf.panel3,0.5,{_x=800.10,_y=57.05,ease=Quart.easeIn})

	Tween:To(objSwf.lvlUpPanel,0.5,{_x=768.75,_y=90,ease=Quart.easeIn})

	Tween:To(objSwf.learnPanel,0.5,{_x=768.75,_y=90,ease=Quart.easeIn})

	local skillConfig = t_skill[self.currSkillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local groupId = skill_action.id;
    if groupId == 102 or groupId == 302 or groupId == 402 then
    	if self.objAvatar then 
  			self.objAvatar:ResetAnima();
			self.isPlaySkill = false;
  		end;
		if self.objAvatar then
			self.objAvatar:ExitMap();
			self.objAvatar = nil;
		end
		self:DrawMagicSkillSen()
    end
end;

function UISkillBasic:OnBtnToolInfoRollOver()
	local conditionlist = {};
	if self.currSkillLvl == 0 then
		conditionlist = SkillUtil:GetLvlUpCondition(self.currSkillId,true);
	else
		conditionlist = SkillUtil:GetLvlUpCondition(self.currSkillId);
	end
	if #conditionlist > 0 then
		for i,vo in ipairs(conditionlist) do
			--道具
			local itemCfg = t_item[vo.id];
			if itemCfg then
				TipsManager:ShowItemTips(vo.id);
			end
		end
	end
end

function UISkillBasic:OnFullShow()
	-- 播放技能
	--self:PlaySkill();
end
-- 播放技能
UISkillBasic.PlayFpsList = {};
function UISkillBasic:PlaySkill()
	local ro = 0;
	local groupid = t_skill[self.currSkillId].group_id
	local cof = UIDrawSkillCfg[groupid];
	if not cof then 
		ro = 0 return 
	else
		ro = cof.Rotation
	end;

	self.objAvatar.objMesh.transform:setTranslation(0,0,0);
	self.objAvatar.objMesh.transform:setRotation(0,0,1,ro);

	local state = self.PlayFpsList[self.currSkillId];
	if not state then 
		self.objAvatar:PlaySkillOnUI(self.currSkillId)
		self.PlayFpsList[self.currSkillId] = true;
	end;
end;

--显示列表
function UISkillBasic:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = SkillUtil:GetSkillListByShow(SkillConsts:GetBasicShowType());
	--过滤普攻
	-- WriteLog(LogType.Normal,true,'-------------技能过滤前数量:',#list,SkillConsts:GetBasicShowType())
	for i=#list,1,-1 do
		local vo = list[i];
		local cfg = t_skill[vo.skillId];
		local maxLvl = cfg.level;
		if t_skillgroup[cfg.group_id] then
			maxLvl = t_skillgroup[cfg.group_id].maxLvl;
		end
		if maxLvl < 1 then
			table.remove(list,i);
		end
	end
	self.skilllist = {};
	objSwf.list.dataProvider:cleanUp();
	for i,vo in ipairs(list) do
		local listVO = self:GetSkillListVO(vo.skillId,vo.lvl);  
		-- trace(listVO)
		table.push(self.skilllist,listVO);
		objSwf.list.dataProvider:push(UIData.encode(listVO));
	end
	objSwf.list:invalidateData();

	--处理一下showUp
	self.showUpSkillList = {};
	self.groupIdList ={};
	for i,vo in pairs(self.skilllist) do
		if vo.showLvlUp then
			local cfg = t_skill[vo.skillId];
			if not cfg then return; end
			local vo ={};
			vo.index = cfg.group_id;
			vo.indexNum = i;
			table.push(self.groupIdList,vo)	
			table.push(self.showUpSkillList,self.skilllist[i])
		end
	end
	table.sort(self.groupIdList,function(A,B) 
		return A.index < B.index
		end);
	if #self.showUpSkillList > 0 then
		objSwf.list:scrollToIndex(self.showUpSkillList[0]);                --list滚动指到第一个item
	else
		objSwf.list:scrollToIndex(0);  
	end
	if #list > 0 then
		objSwf.list.selectedIndex = 0;
		if #self.showUpSkillList > 0 then
			objSwf.list.selectedIndex = self.groupIdList[1].indexNum -1;   --指针从0开始
			self:ShowRight(list[self.groupIdList[1].indexNum].skillId,list[self.groupIdList[1].indexNum].lvl);
		else
			self:ShowRight(list[1].skillId,list[1].lvl);
		end
	end
end

--获取列表VO    ----changer:hoxuudong date:2016/5/11 16:08
function UISkillBasic:GetSkillListVO(skillId,lvl)
	local vo = {};
	vo.skillId = skillId;
	local cfg = t_skill[skillId];
	if cfg then
		vo.name = cfg.name;
		vo.lvl = lvl;
		vo.showEffects = false;      --默认刚进入时不播放升级特效
		local maxLvl = SkillUtil:GetSkillMaxLvl(skillId);
		if lvl == 0 then
			vo.lvlStr = "";
			vo.noxue = true;
			vo.showLvlUp = self:GetSkillCanLearn(skillId);       --处理技能可以学习时也可有提示
			vo.iconUrl = ImgUtil:GetGrayImgUrl(ResUtil:GetSkillIconUrl(cfg.icon,"54"));   --添加灰色按钮
		else
			vo.noxue = false;
			vo.lvlStr = "";
			local skillVO = SkillModel:GetSkill(skillId);
			local info = MainPlayerModel.humanDetailInfo;
			local playerLv = info.eaLevel;
			if skillVO and lvl < maxLvl then    
				vo.showLvlUp = self:GetSkillCanLvlUp(skillId);   --显示是否可以升级
			else
				vo.showLvlUp = false;
			end
			vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon,"54");
		end
		local str = lvl.."/"..maxLvl.."重"   
		vo.lvlStr = str
		
		vo.iconLoad = "";
		vo.skillType = cfg.type;
	end
	return vo;
end

function UISkillBasic:GetCanLvUpNum( )
	return self.isCanLvUpNum or 0;
end
--点击列表
function UISkillBasic:OnListItemClick(e)
	local objSwf = self.objSwf;
	--objSwf.lvlUpPanel.scrollbarcc.position = 0;
	--objSwf.lvlUpPanel.scrollbarccc.position = 0;
	--objSwf.learnPanel.scrollbarccaa.positing = 0;
	self:ShowRight(e.item.skillId,e.item.lvl);
	-- self:PalyerSkillGo();
	-- if self.objAvatar then 
 --  		self.objAvatar:ResetAnima();
	-- 	self.isPlaySkill = false;
 --  	end;
	-- if self.objAvatar then
	-- 	self.objAvatar:ExitMap();
	-- 	self.objAvatar = nil;
	-- end
	-- self:DrawMagicSkillSen();
	--self.objAvatar:PlaySkillOnUI(e.item.skillId)
	--self:PlaySkill();
	self.currSkillId = e.item.skillId;
end

--显示右侧信息
function UISkillBasic:ShowRight(skillId,lvl)
	self.currSkillId = skillId;
	self.currSkillLvl = lvl;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = t_skill[skillId];
	if cfg then
		objSwf.panel3.numFight.num = cfg.power_point;    --技能中的战斗力用的是中和殿
		objSwf.panel3.nameLoader.text = cfg.name--ResUtil:GetSkillNameIconUrl(cfg.nameIcon);
		objSwf.panel3.iconLoader.source = ResUtil:GetSkillIconUrl(cfg.icon,"54");
	end
	objSwf.learnPanel._visible = (lvl==0);
	objSwf.lvlUpPanel._visible = not (lvl==0);

	if lvl == 0 then
		self:ShowSkillLearn();
	else
		self:ShowSkillLvlUp();
	end
	--self:ShowAvatar();
	--self:DrawMagicSkillSen();
end

function UISkillBasic:GetWidth()
	return 708
end;
function UISkillBasic:GetHeight()
	return 548
end;
-- drawAvatar 
function UISkillBasic:ShowAvatar()
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业


	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	-- trace(info)
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
		-- self.objAvatar:Create( 0, prof );
		self.objAvatar:CreateByVO(vo);
	end
	local info = MainPlayerModel.sMeShowInfo;
	local cfg = t_playerinfo[prof];
	-- self.objAvatar:SetProf(prof);
	-- self.objAvatar:SetDress(cfg.create_dress);
 --    self.objAvatar:SetArms(cfg.create_arm);    

    local groupid = t_skill[self.currSkillId].group_id;
    local x,y = UIManager:GetWinSize();
    local cfg = UIDrawSkillCfg[groupid];
    if not cfg then 
    	cfg= {
				EyePos = _Vector3.new(0,-40,20),
				LookPos = _Vector3.new(0,0,10),		
				VPort = _Vector2.new(1000,600),  -- 1000,600
				Rotation = 0,
			 }
    end;
    if not self.objUIDraw then
		local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
		self.objUIDraw = UIDraw:new("roleSkillPanelPlayer", self.objAvatar, self.objSwf.uiLoader,
							cfg.VPort, cfg.EyePos, cfg.LookPos,
							0x00000000, nil, prof);
	else 
		self.objUIDraw:SetUILoader(self.objSwf.uiLoader);
		self.objUIDraw:SetCamera(cfg.VPort,cfg.EyePos,cfg.LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end

	self.meshDir = cfg.Rotation;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
end


------------------------------------------------


--得到场景文件名
function UISkillBasic:GetGodSkillSen()
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
function UISkillBasic:DrawMagicSkillSen()
	local objSwf = self.objSwf;
	if not objSwf then return end; 
	local w,h = 4000, 2000;
	if not self.objSenDraw then
		--local w,h = UIManager:GetWinSize();
		viewMagicSkillPort = _Vector2.new(w, h);
		self.objSenDraw = UISceneDraw:new( "UISkillBasic", objSwf.senloader, viewMagicSkillPort);
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
			-- vo.wing = info.dwWing;  --干掉翅膀
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
				-- self.objAvatar:Create( 0, prof );
			end
			local info = MainPlayerModel.sMeShowInfo;
			-- local cfg = t_playerinfo[prof];
			-- self.objAvatar:SetProf(prof);
			-- self.objAvatar:SetDress(cfg.create_dress);
			-- self.objAvatar:SetArms(cfg.create_arm);
			self.objAvatar:SetArms(info.dwArms);
			self.objAvatar.objMesh.transform:setScaling(0.6, 0.6, 0.6);
			local list = self.objSenDraw:GetMarkers()
			local indexc = "marker"
			self.objAvatar:EnterUIScene(self.objSenDraw.objScene,list[indexc].pos,list[indexc].dir,list[indexc].scale, enEntType.eEntType_Player)
		end)
	self.objSenDraw:SetDraw( true );
	UISceneDraw:Destroy()
end


------------------------------------------------



--显示技能学习信息
function UISkillBasic:ShowSkillLearn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panel = objSwf.learnPanel;
	--技能描述信息
	-- local str = self:GetHtmlText(StrConfig['skill11'].."：","#d1c0a5");
	-- str = str .. self:GetHtmlText(SkillTipsUtil:GetSkillEffectStr(self.currSkillId),"#ff8f43");
	-- str = str .. "<br/>";

	local strc = "";--self:GetHtmlText(StrConfig['skill11'].."：","#d1c0a5");
	strc = strc .. self:GetHtmlText(SkillTipsUtil:GetSkillEffectStr(self.currSkillId),"#d5b772");
	strc = strc .. "<br/>";
	panel.tfTitle.htmlText = strc
	local str = ""
	local maxLvlId = SkillUtil:GetMaxSkillID(self.currSkillId);
	str = str .. self:GetHtmlText(StrConfig['skill13'].."：","#be8c44",TipsConsts.TitleSize_Two);
	str = str .. self:GetHtmlText(SkillTipsUtil:GetSkillEffectStr(maxLvlId),"#d5b772");
	panel.tfSkillInfo.htmlText = "";  --未学习的0重技能在下级技能效果描述栏中不显示下级技能效果，为空；

	-- 技能介绍
	local cfg = t_skill[self.currSkillId];
	local str = "";
--	str = str .. self:GetHtmlText(StrConfig['skill1'].."：","#d1c0a5",false);
--	str = str .. self:GetHtmlText(SkillConsts:GetSkillTypeName(cfg.type),TipsConsts.Default_Color);
	str = str .. self:GetHtmlText(StrConfig['skill2'].."：","#D2A930",nil,false);
	str = str .. self:GetHtmlText(string.format(StrConfig['skill10'],cfg.cd/1000),"#00ff00"); 
--	str = str .. self:GetHtmlText(StrConfig['skill3'].."：","#d1c0a5",false);
--	str = str .. self:GetHtmlText(SkillConsts:GetSkillHurtTypeName(cfg.type),TipsConsts.Default_Color);
	-- smart 隐藏内力消耗 学习面板
	--str = str .. self:GetHtmlText(StrConfig['skill4'].."：","#d1c0a5",false);
	--str = str .. self:GetHtmlText(SkillConsts:GetSkillConsumStr(self.currSkillId),TipsConsts.Default_Color,false);
	--str;
	--新增诗句信息
	panel.tfdes.htmlText = cfg.des;
	local nextCfg = t_skill[cfg.next_lv];

	panel.tflengque.htmlText = str;
	self:ShowSkillLearnCondition();
end

--显示技能学习条件
function UISkillBasic:ShowSkillLearnCondition()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panel = objSwf.learnPanel;
	local str =""   --StrConfig['skill103'];
	--学习条件赋值
	-- local conditionlist = SkillUtil:GetLvlUpCondition(self.currSkillId,false)---true
	-- GetLvlUpConditionForSkill
	local conditionlist = SkillUtil:GetLvlUpConditionForSkill(self.currSkillId,true)---true
	-- print("____________",#conditionlist)
	-- UILog:print_table(conditionlist)
	-- debug.debug()
	if #conditionlist > 0 then
		str = str .. self:GetConditionStrs(conditionlist);
		local ZhenQi = MainPlayerModel.humanDetailInfo.eaZhenQi;
		-- str = str .. string.format(StrConfig['skill116'],ZhenQi);
		panel.tfLearnCondition.htmlText = str;
		panel.btnToolInfo.htmlLabel = self:GetToolConditionStr(conditionlist);
	else
		panel.tfLearnCondition.htmlText = "";
	end
	local cfg = t_skill[self.currSkillId];
	if cfg then 
		local atbtxt = self:GetHtmlText(StrConfig['skill113'],"#8cbbd3");
		local atbcfg = cfg.add_attr;
		if atbcfg then 
			local list = AttrParseUtil:Parse(atbcfg);
			for i,info in ipairs(list) do 
				local name = enAttrTypeName[info.type]
				atbtxt = atbtxt .. "<font color='#c8c8c8'>"..name..": <font/><font color='#c8c8c8'>"..info.val.."         "
			end;
		end;
		--panel.tfLearnAtbCondition.htmlText = atbtxt
	end;
	for i,vo in ipairs(conditionlist) do
		if not vo.state then
			panel.btnLearn.disabled = true;
			return;
		end
	end

	panel.btnLearn.disabled = false;
end

--显示技能升级信息
function UISkillBasic:ShowSkillLvlUp()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panel = objSwf.lvlUpPanel;
	--技能等级
	local cfg = t_skill[self.currSkillId];
	if not cfg then return; end
	local maxLvl = cfg.level;
	if t_skillgroup[cfg.group_id] then
		maxLvl = t_skillgroup[cfg.group_id].maxLvl;
	end
	panel.tfLvl.htmlText = string.format(StrConfig['skill102'],cfg.level,maxLvl);   ---%s/%s重
	--title

	--技能冷却
	local str = "";
--	str = str .. self:GetHtmlText(StrConfig['skill1'].."：","#d1c0a5",false);
--	str = str .. self:GetHtmlText(SkillConsts:GetSkillTypeName(cfg.type),TipsConsts.Default_Color);
	str = str .. self:GetHtmlText(StrConfig['skill2'].."：","#D2A930",nil,false);
	str = str .. self:GetHtmlText(string.format(StrConfig['skill10'],cfg.cd/1000),"#00ff00"); 
--	str = str .. self:GetHtmlText(StrConfig['skill3'].."：","#d1c0a5",false);
--	str = str .. self:GetHtmlText(SkillConsts:GetSkillHurtTypeName(cfg.type),TipsConsts.Default_Color);

	-- smart 隐藏内力消耗  升级面板
--	str = str .. self:GetHtmlText(StrConfig['skill4'].."：","#d1c0a5",false);
--	str = str .. self:GetHtmlText(SkillConsts:GetSkillConsumStr(self.currSkillId),TipsConsts.Default_Color,false);
	panel.tflengque.htmlText = str;

	--技能描述信息
	local str = "";--self:GetHtmlText(StrConfig['skill11'].."：","#d1c0a5");
	str = str .. self:GetHtmlText(SkillTipsUtil:GetSkillEffectStr(self.currSkillId),"#d5b772");
	str = str;
	panel.tfTitle.htmlText = str;
	-- print("----------------------",str)
	--新增诗句信息
	panel.tfdes.htmlText = cfg.des;
	local nextCfg = t_skill[cfg.next_lv];
	local tfStr = "";
	if nextCfg then
		--str = self:GetHtmlText(StrConfig['skill12'].."：","#be8c44",TipsConsts.TitleSize_Two);  --取消二级标签
		tfStr = tfStr .. self:GetHtmlText(SkillTipsUtil:GetSkillEffectStr(cfg.next_lv),"#d5b772");
	end
	panel.tfSkillInfo.htmlText = tfStr;
	self:ShowSkillLvlUpCondition();
end

--显示技能升级条件
function UISkillBasic:ShowSkillLvlUpCondition()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panel = objSwf.lvlUpPanel;
	--显示升级条件
	local str = '';   --- = StrConfig['skill104'];
	local conditionlist = SkillUtil:GetLvlUpConditionForSkill(self.currSkillId,false);
	if #conditionlist > 0 then
		str = str .. self:GetConditionStrs(conditionlist);
		-- local ZhenQi = MainPlayerModel.humanDetailInfo.eaZhenQi;
		-- str = str .. string.format(StrConfig['skill116'],ZhenQi);  --当前修为
		panel.tfLvlUpCondition.htmlText = str;
		panel.btnToolInfo.htmlLabel = self:GetToolConditionStr(conditionlist);
	else
		panel.tfLvlUpCondition.htmlText = str;
	end
	local cfg = t_skill[self.currSkillId];
	local atbtxt = self:GetHtmlText(StrConfig['skill112'],"#8cbbd3");
	local atbcfg = cfg.add_attr;
	if atbcfg then 
		local list = AttrParseUtil:Parse(atbcfg);
		for i,info in ipairs(list) do 
			local name = enAttrTypeName[info.type]
			atbtxt = atbtxt .. "<font color='#c8c8c8'>"..name..": <font/><font color='#c8c8c8'>"..info.val.."         "
		end;
	end;
	--panel.tfLvlUpAtbCondition.htmlText = atbtxt;
	local nextCfg = t_skill[cfg.next_lv];
	if nextCfg then 
		local nextatbcfg = nextCfg.add_attr;
		if nextatbcfg then 
			local nextlist = AttrParseUtil:Parse(nextatbcfg);
			local list = AttrParseUtil:Parse(atbcfg);
			for i,info in ipairs(nextlist) do 
				local name = enAttrTypeName[info.type]
				local nextatb = (info.val-list[i].val)
				--panel.tfLvlUpAtbCondition2["atb"..i].htmlText = nextatb;
			end; 
		end;
	end;
	if cfg.next_lv == 0 then -- 最大等级    
		panel.tfLvlUpCondition.htmlText ="";--StrConfig["skill108"];
		panel.btnLvlUp.disabled = true;
		panel.btnLvlUp:clearEffect();
		panel.btnquicklyLvlUp:clearEffect();
		-- panel.btnLvlUp2._visible = false;
		panel.btnLvlUp._visible = false;
		panel.btnquicklyLvlUp.disabled = true;
		panel.btnquicklyLvlUp._visible = false;
		panel.maxlvl._visible = true
		self:OnBtnLvlUpRollOut()
		return;
	end
	for i,vo in ipairs(conditionlist) do  -- 条件不足，
		if not vo.state then
			panel.btnLvlUp.disabled = true;
			panel.btnLvlUp:clearEffect();
			panel.btnquicklyLvlUp:clearEffect();
			panel.btnquicklyLvlUp.disabled = true
			-- panel.btnLvlUp2._visible = true;
			panel.btnLvlUp._visible = true;
			panel.btnquicklyLvlUp._visible = true  --SkillUtil.debugQuickly;   --暂时屏蔽快速购买功能
			panel.maxlvl._visible = false
			return;
		end
	end
	--可以升级
	panel.maxlvl._visible = false
	panel.btnLvlUp.disabled = false;
	panel.btnLvlUp:showEffect(ResUtil:GetButtonEffect7());
	panel.btnquicklyLvlUp:showEffect(ResUtil:GetButtonEffect7());
	panel.btnquicklyLvlUp.disabled = false --not SkillUtil.debugQuickly;
	-- panel.btnLvlUp2._visible = false;
	panel.btnLvlUp._visible = true;
	panel.btnquicklyLvlUp._visible = true --SkillUtil.debugQuickly;   --暂时屏蔽快速购买功能
end

function UISkillBasic:GetHtmlText(text,color,size,withBr)
	if withBr==nil then withBr = true; end
	if not size then size = TipsConsts.Default_Size; end
	local str = "<font color='" ..color.."' size='" .. size .. "'>" ..text.. "</font>";
	if withBr then
		str = str .. "<br/>"
	end
	return str;
end
--格式化升级学习条件
function UISkillBasic:GetConditionStrs(list)
	local str = "";
	for i,vo in ipairs(list) do
		local itemCfg = t_item[vo.id];
		if not itemCfg then
			local name,num = SkillUtil:GetConditionStr(vo);
			if vo.state then 
				str = str .. string.format(StrConfig['skill105'],name,num);
				str = str .. "<br/>";
			else
				str = str .. string.format(StrConfig['skill106'],name,num);
				str = str .. "<br/>";
			end;
		end
	end
	return str;
end
--得到道具条件
function UISkillBasic:GetToolConditionStr(list)
	local str = "";
	local canLearn = false;
	for i,vo in ipairs(list) do
		--道具
		local itemCfg = t_item[vo.id];
		if itemCfg then
			local num = BagModel:GetItemNumInBag(vo.id);
			if num >= vo.num then
				str = string.format(StrConfig['skill114'],itemCfg.name,num.."/"..vo.num);
				canLearn = true;
			else
				str = string.format(StrConfig['skill115'],itemCfg.name,num.."/"..vo.num);
				canLearn = false;
			end
		end
	end
	return str,canLearn;
end

--点击学习
function UISkillBasic:OnBtnLearnClick()
--	print("当前技能的id：",self.currSkillId)
	SkillController:LearnSkill(self.currSkillId);
end

--点击升级
function UISkillBasic:OnBtnLvlUpClick()
--	print("当前技能的id：",self.currSkillId)
	SkillController:LvlUpSkill(self.currSkillId);
end
--快速升级技能
function UISkillBasic:OnBtnQuicklyLvlUpClick()
	SkillController:QuicklyLvUpSkill()
end

--升级tips
function UISkillBasic:OnBtnLvlUpRollOver()
	--[[
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local cfg = t_skill[self.currSkillId];
	local nextCfg = t_skill[cfg.next_lv];
	if not nextCfg then return end;

	--self.objSwf.lvlUpPanel.tfLvlUpAtbCondition2._visible = true;
	if objSwf.lvlUpPanel.btnLvlUp.disabled then
		TipsManager:ShowBtnTips(StrConfig["skill110"]);
	end
	--]]
end
function UISkillBasic:OnBtnLvlUpRollOut()
	-- TipsManager:Hide();
	--self.objSwf.lvlUpPanel.tfLvlUpAtbCondition2._visible = false;
end;

function UISkillBasic:ListNotificationInterests()
	return {NotifyConsts.SkillLearn,NotifyConsts.SkillLvlUp,
			NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagUpdate,
			NotifyConsts.PlayerAttrChange,NotifyConsts.SkillQuicklyLvlUp};
end

function UISkillBasic:HandleNotification(name,body)
	if name == NotifyConsts.SkillLearn then
		self:OnSkillLearn(body.skillId);
	elseif name == NotifyConsts.SkillLvlUp then
		self:OnSkillLvlUp(body.skillId,body.oldSkillId);
		-- self:ChooseItemIndex();
	elseif name==NotifyConsts.BagAdd or name==NotifyConsts.BagRemove or name==NotifyConsts.BagUpdate then
		if body.type == BagConsts.BagType_Bag then
			self:CheckList();
			self:ChooseItemIndex();
			if self.currSkillLvl == 0 then
				self:ShowSkillLearnCondition();
			else
				self:ShowSkillLvlUpCondition();
			end
		end
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaLevel or body.type==enAttrType.eaZhenQi or 
			body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold then
			self:CheckList();
			self:ChooseItemIndex();
			if self.currSkillLvl == 0 then
				self:ShowSkillLearnCondition();
			else
				self:ShowSkillLvlUpCondition();
			end
		end
	elseif name == NotifyConsts.SkillQuicklyLvlUp then
		self:CheckList();
	end
end

--技能是否可以学习
function UISkillBasic:GetSkillCanLearn(skillId)
	local conditionlist = SkillUtil:GetLvlUpConditionForSkill(skillId,true,nil);
	for i,vo in ipairs(conditionlist) do
		if not vo.state then
			return false;
		end
	end
	return true;
end

-- adder:houxudong date:2016/9/25 21:29:25
--如果有可以升级的定位到可升级的item,如果没有可以升级的停在当前位置
-- 自动定位到可以升级的item
function UISkillBasic:ChooseItemIndex( )
	--[[
	-- 满级时的跳转
	local cfg = t_skill[self.currSkillId];
	if cfg.next_lv == 0 then -- 最大等级    
		if #self.showUpSkillList > 0 then
			self:ShowList()
		end
		return;
	end
	--]]
	-- 自动寻找可以升级的技能组
	local conditionlist = SkillUtil:GetLvlUpConditionForSkill(self.currSkillId,false);
	for i,vo in ipairs(conditionlist) do
		if not vo.state then                   --如果当前技能的可升级状态为false的时候，寻找可以升级的技能组
			if SkillFunc:CheckCanLvlUp() then  --如果当前有升级的技能时
				self:ShowList()
			end
			return;
		end
	end
end

--检查列表是否显示特效
function UISkillBasic:CheckList()
	local objSwf = self.objSwf;
	self.isCanLvUpNum = 0    --如果红点提示需要显示数字，记录可以升级的数量
	if not objSwf then return; end
	for i,vo in ipairs(self.skilllist) do
		local cfg = t_skill[vo.skillId];
		local showLvlUp = false;
		local learnCanLvUp = false;
		local maxLvl = SkillUtil:GetSkillMaxLvl(vo.skillId);
		local skillVO = SkillModel:GetSkill(vo.skillId);
		if skillVO and vo.lvl < maxLvl then
			showLvlUp = self:GetSkillCanLvlUp(vo.skillId);
			if showLvlUp then
				self.isCanLvUpNum = self.isCanLvUpNum +1;
			end
		elseif vo.lvl == 0 then  				--处理技能可以学习时也可有提示
			showLvlUp = self:GetSkillCanLearn(vo.skillId);
			if showLvlUp then
				self.isCanLvUpNum = self.isCanLvUpNum +1;
			end
		else
			showLvlUp = false;     --满级不再显示绿色箭头
		end
		if vo.showLvlUp ~= showLvlUp then
			local cfg = t_skill[vo.skillId];
			vo.lvl = SkillModel:GetSkill(vo.skillId) and cfg.level or 0;  
			vo.lvlStr = self:GetSkillListVO(vo.skillId,vo.lvl).lvlStr;
			vo.showEffects = false;    --检测系统可以升级状态时不显示升级特效
			vo.showLvlUp = showLvlUp;
			local uiData = UIData.encode(vo);
			objSwf.list.dataProvider[i-1] = uiData;
			local uiItem = objSwf.list:getRendererAt(i-1);
			if uiItem then
				uiItem:setData(uiData);
			end
		end
	end
	Notifier:sendNotification(NotifyConsts.RedPointSkill,{isCanLvUpNum = self.isCanLvUpNum})
end


function UISkillBasic:OnSkillLearn(skillId)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i,vo in ipairs(self.skilllist) do
		if vo.skillId == skillId then
			vo.lvlStr = self:GetSkillListVO(skillId,1).lvlStr;
			vo.lvl = 1;
			vo.showEffects = true;   --技能可以学习时显示升级特效     
			vo.iconUrl = self:GetSkillListVO(skillId,1).iconUrl;   --加载高亮技能图片资源
			vo.showLvlUp = self:GetSkillCanLvlUp(skillId);
			local uiData = UIData.encode(vo);
			objSwf.list.dataProvider[i-1] = uiData;
			local uiItem = objSwf.list:getRendererAt(i-1);
			if uiItem then
				uiItem:setData(uiData);
			end
			break;
		end
	end
	if skillId == self.currSkillId then
		self:ShowRight(skillId,1);
	end
end

function UISkillBasic:OnSkillLvlUp(skillId,oldSkillId)
	self:PlyLvUpEff()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = t_skill[skillId];
	if not cfg then return; end
	for i,vo in ipairs(self.skilllist) do
		if vo.skillId == oldSkillId then
			local newVO = self:GetSkillListVO(skillId,cfg.level);
			vo.skillId = skillId;
			vo.lvl = cfg.level;
			vo.lvlStr = newVO.lvlStr;
			vo.showEffects = true;   --当前升级的技能显示升级特效
			vo.showLvlUp = self:GetSkillCanLvlUp(skillId);
			local uiData = UIData.encode(vo);
			objSwf.list.dataProvider[i-1] = uiData;
			local uiItem = objSwf.list:getRendererAt(i-1);
			if uiItem then
				uiItem:setData(uiData);
			end
			break;
		end
	end
	if oldSkillId == self.currSkillId then
		self:ShowRight(skillId,cfg.level);
	end
end

--获取技能是否可升级
function UISkillBasic:GetSkillCanLvlUp(skillId)
	local conditionlist = SkillUtil:GetLvlUpConditionForSkill(skillId,false,nil);
	-- local conditionlist = SkillUtil:GetLvlUpCondition(skillId,false);
	-- trace(conditionlist)
	for i,vo in ipairs(conditionlist) do
		if not vo.state then
			return false;
		end
	end
	return true;
end

function UISkillBasic:PlyLvUpEff()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.skillLvUpFloat:stopEffect()
	objSwf.refreshEff:stopEffect()
	objSwf.skillLvUpFloat:playEffect(1)
	objSwf.refreshEff:playEffect(1)
end

-- 关闭操作
function UISkillBasic:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
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
	local objSwf = self.objSwf;
	if not objSwf then return; end
	Tween:KillOf(objSwf.list)
	Tween:KillOf(objSwf.panel3)
	Tween:KillOf(objSwf.lvlUpPanel)
	Tween:KillOf(objSwf.learnPanel)
	SkillUtil.debugQuickly = false
end;

function UISkillBasic:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	if self.objSenDraw then
		self.objSenDraw:SetDraw(false);
		self.objSenDraw:SetUILoader(nil);
	end
end

-------------------------引导接口------------------
function UISkillBasic:GetLvlUpBtn()
	if not self:IsShow() then return; end
	return self.objSwf.lvlUpPanel.btnLvlUp;
end