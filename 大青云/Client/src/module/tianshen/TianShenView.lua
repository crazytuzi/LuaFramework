--[[
天神附体
 jiayong  
 版本 3.0
2016年8月8日
]]
_G.UITianShenView = BaseUI:new("UITianShenView")
UITianShenView.curstep = nil;
UITianShenView.curmodelId = nil
UITianShenView.currVO = nil;


UITianShenView.selectedTitleId=0
UITianShenView.UIAttr=nil;
function UITianShenView:Create()
	self:AddSWF("tianShenPanel.swf", true, "center")
end
function UITianShenView:OnLoaded(objSwf)

	objSwf.btnClose.click = function() self:Hide(); end
 
	--技能
	objSwf.InitiativeSkill.itemRollOver = function(e) self:OnSkillRollOver(e); end
	objSwf.InitiativeSkill.itemRollOut = function() self:OnSkillRollOut(); end
	-- objSwf.PassivitySkill.itemRollOver = function(e) self:OnSkillRollOver(e); end
	-- objSwf.PassivitySkill.itemRollOut = function() self:OnSkillRollOut(); end

    --切换附体
	objSwf.btnActivate.click = function() self:OnBtnActivateClick(); end
    --激活
	objSwf.ActivePanel.btnActivate.click = function() self:OnBtnActiveClick(); end
	objSwf.ActivePanel.btnConsume.rollOver = function(e) self:OnbtnActiveItemRollOver(); end
	objSwf.ActivePanel.btnConsume.rollOut = function(e) TipsManager:Hide(); end
   --路径
    objSwf.ActivePanel.BtnQuest.click = function() self:OnBtnQuestClick();end
	
	--进阶消耗
	objSwf.advancepanel.btnAdvance.click = function() self:OnBtnAdvanceClick(); end
	objSwf.advancepanel.btnConsume.rollOver = function(e) self:OnbtnAdvanceItemRollOver(); end
	objSwf.advancepanel.btnConsume.rollOut = function(e) TipsManager:Hide(); end
    --突破消耗

    objSwf.breakUpanel.btnbreakup.click = function() self:OnbtnShentuClick(); end
	objSwf.breakUpanel.btnConsume.rollOver = function(e) self:OnbtnStarItemRollOver(); end
	objSwf.breakUpanel.btnConsume.rollOut = function(e) TipsManager:Hide(); end
   -- vip
	objSwf.btnVipLvUp.click = function(e) UIVip:Show() end
    objSwf.btnVipLvUp.rollOver = function(e) self:OnBtnVipLvUpRollOver() end
	objSwf.btnVipLvUp.rollOut = function(e)  VipController:HideAttrTips()end
    
    --规则
	objSwf.rulesBtn.rollOver = function() TipsManager:ShowBtnTips(StrConfig['tianshen048'],TipsConsts.Dir_RightDown); end
	objSwf.rulesBtn.rollOut = function() TipsManager:Hide(); end

     
    objSwf.scrollList.itemClick = function (e) self:ItemClick(e); end
    objSwf.starTitle.siStar.maximum = TianShenConsts.MaxStar
    objSwf.advancepanel.progressBar.trackWidthGap = 26;

end
function UITianShenView:GetPanelType()
	return 1;
end
function UITianShenView:OnShow()

    --初始化
    self:initialize()
	--显示头像列表
	self:OnShowTitlePanel();  --显示初始的方法
   
    self:OnShowStateButton();
    --属性
	self:UpdateInfo(true);
	--技能展示
	self:ShowUpdateSkill(true);
end
function UITianShenView:initialize()
	local objSwf = self.objSwf
	if not objSwf then return end
   
    self.sortList = TianShenModel:GetBianshenList();
	table.sort(self.sortList,function(A,B)
   	if A.tid<B.tid then 
   		return true
   	else
   		return false
   	end
    end)

    local activevo=TianShenModel:GetTianshenActive()
    local zhanbianshen= activevo or TianShenModel:GetFightModel()
    if zhanbianshen then
        self.currVO =zhanbianshen;
        self.selectedTitleId = self.currVO.tid*1000
    else
        self.currVO = self.sortList[1];
    end
	for i=1,TianShenConsts.ListLen do
		if i==self.currVO.column then
		    self.UIAttr= objSwf["attrvalue"..i];
		    self.UIAttr._visible=true;
		else
	        objSwf["attrvalue"..i]._visible=false
		end
    end
end
--星级
local lastStar = 0;
function UITianShenView:ShowStarUpdate()
	local objSwf = self.objSwf
	if not objSwf then return; end
	local star = self.currVO.star;
	objSwf.starTitle.siStar.value = star
    local active=self.currVO.state==0;
    local title=star == 0
    objSwf.greytitle._visible=title and not active;
    objSwf.starTitle.titleImg._visible= not title;
    objSwf.starTitle.titleImg:gotoAndStop(star);
	-- self:PlayStarEffect(star);
end
--------------- 技能 ----------------------
UITianShenView.PassivitySkill = {};
UITianShenView.InitiativeSkill = {};
function UITianShenView:ShowTianShenSkill()

	local objSwf = self.objSwf;
	if not objSwf then return; end
    local lv=self.currVO.step;
    if self.currVO.step== 0 then 
    	lv=self.currVO.tid *1000
    end

	-- local paskill =TianShenConsts:GetPassivitySkill(lv)
	-- local PassivitySkill = objSwf.PassivitySkill;
	-- PassivitySkill.dataProvider:cleanUp();
	-- local listVO = TianShenUtil:GetSkillListVO(paskill);
	-- table.push(self.PassivitySkill, listVO);
	-- PassivitySkill.dataProvider:push(UIData.encode(listVO));
	-- PassivitySkill:invalidateData();
	--主动技能

	local list1 = self.currVO.attachedSkills or TianShenConsts:GetAttachedSkills(lv);
	local InitiativeSkill = objSwf.InitiativeSkill;
	InitiativeSkill.dataProvider:cleanUp();
	for i =1,#list1 do
		local skill = list1[i]; 
 		local listVO = TianShenUtil:GetSkillListVO(skill.skillId);
		table.push(self.InitiativeSkill, listVO);
		InitiativeSkill.dataProvider:push(UIData.encode(listVO));
	end
	InitiativeSkill:invalidateData();
end

UITianShenView.PlayFpsList = {};
function UITianShenView:OnSkillRollOver(e)
    
	TipsManager:ShowTips(TipsConsts.Type_Skill, { skillId = e.item.skillId }, TipsConsts.ShowType_Normal,
	TipsConsts.Dir_RightUp);
end
function UITianShenView:OnSkillRollOut(e)
	TipsManager:Hide();
end
--激活
function UITianShenView:OnBtnActiveClick()

   local objSwf = self.objSwf;
   if not objSwf then return; end
   local roleid=self.currVO.tid;
   if t_tianshen[roleid] and t_tianshen[roleid].act_item then
	local desTable = t_tianshen[roleid].act_item
	local itemid = tonumber(desTable[1]);
	local NbNum = BagModel:GetItemNumInBag(itemid);
	local stritem = t_item[itemid].name .. desTable[2]
	if MainPlayerModel.humanDetailInfo.eaLevel < t_tianshen[roleid].act_level then
		FloatManager:AddNormal(string.format(StrConfig['tianshen016'], t_tianshen[roleid].act_level), objSwf.advancepanel.btnactive);
		return
	end
	if NbNum < tonumber(desTable[2]) then
		FloatManager:AddNormal(StrConfig["tianshen014"], objSwf.advancepanel.btnactive);
		return;
	end
   end
    TianShenController:ReqActiveBianShen(roleid);	
end
--升阶
function UITianShenView:OnBtnAdvanceClick()

	local objSwf = self.objSwf;
	if not objSwf then return; end
    if TianShenUtil:IsLevelFull(self.currVO) then return end
    if TianShenUtil:IsBreakUp(self.currVO) then return end;
    local itemId, itemNum = TianShenConsts:GetLevelItem(self.curmodelId)
	local itemCfg = t_item[itemId];
    local bagnum=BagModel:GetItemNumInBag(itemId)
	local itemId, itemNum = TianShenConsts:GetLevelItem(self.curmodelId)
	if bagnum < itemNum then
		UIQuickBuyConfirm:Open(self,itemId);
		return;
	end
	TianShenController:ReqConsumerBianShen(self.currVO.tid)
end

function UITianShenView:OnbtnShentuClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if TianShenUtil:IsLevelFull(self.currVO) then return end
	local itemId, itemNum = TianShenConsts:GetStarItem(self.currVO.step)
	local itemCfg = t_item[itemId];
	if BagModel:GetItemNumInBag(itemId) < itemNum then
        UIQuickBuyConfirm:Open(self,itemId);
		return;
	end
	if TianShenUtil:IsBreakUp(self.currVO) then 
        UITianshensmallView:OpenPanel(self.currVO)
     	return 
    end
end
--激活 
function UITianShenView:ShowActiveInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
    
	objSwf.ActivePanel.btnConsume.htmlText = "";
	local itemId, itemNum = TianShenConsts:GetActiveItem(self.currVO.tid)
	local itemCfg = t_item[itemId];
	if not itemCfg then return; end
    
	local itemName = itemCfg and itemCfg.name or "无道具";
	local labelItemColor = BagModel:GetItemNumInBag(itemId) >= itemNum and "#00ff00" or "#ff0000";
	objSwf.ActivePanel.btnConsume.htmlLabel = string.format(StrConfig['tianshen020'], labelItemColor, itemName, itemNum);
    local isplaylv=MainPlayerModel.humanDetailInfo.eaLevel >= t_tianshen[self.currVO.tid].act_level;
    if BagModel:GetItemNumInBag(itemId) >= itemNum and isplaylv then 
	    objSwf.ActivePanel.btnActivate:showEffect(ResUtil:GetButtonEffect10())
    else
        objSwf.ActivePanel.btnActivate:clearEffect();
    end
    local colorlv=isplaylv and "#00ff00" or "#ff0000"
    objSwf.ActivePanel.activelv.htmlLabel= string.format(StrConfig['tianshen046'], colorlv,t_tianshen[self.currVO.tid].act_level);
	local cfg=t_tianshen[self.currVO.tid] 
	if not cfg then return end
	objSwf.ActivePanel.BtnQuest.htmlLabel = string.format(StrConfig['tianshen024'], "#00ff00", cfg.describe);
end
--进阶
function UITianShenView:ShowAdvanceInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
    local itemId, itemNum;
	objSwf.advancepanel.btnConsume.htmlText = "";
	itemId, itemNum = TianShenConsts:GetLevelItem(self.curmodelId)
	local itemCfg = t_item[itemId];
	local bagnum=BagModel:GetItemNumInBag(itemId)
	if not itemCfg then return; end
	local itemName = itemCfg and itemCfg.name or "无道具";
	local labelItemColor = bagnum >= itemNum and "#00ff00" or "#ff0000";
	local numcolor = bagnum >= itemNum and StrConfig['tianshen022'] or StrConfig['tianshen023']

	objSwf.advancepanel.btnConsume.htmlLabel = string.format(StrConfig['tianshen045'], labelItemColor, itemName,itemNum);	
	objSwf.advancepanel.consumeNum.htmlText=bagnum..")";
    if bagnum >= itemNum then 
	    objSwf.advancepanel.btnAdvance:showEffect(ResUtil:GetButtonEffect10())
    else
        objSwf.advancepanel.btnAdvance:clearEffect();
    end
end
function UITianShenView:ShowBreakUpInfo()


	local objSwf = self.objSwf;
	if not objSwf then return; end
	local staritemId, staritemNum = TianShenConsts:GetStarItem(self.currVO.step)
	local staritemCfg = t_item[staritemId];
	if not staritemCfg then return; end

	local staritemName = staritemCfg and staritemCfg.name or "无道具";
	local starbagnum = BagModel:GetItemNumInBag(staritemId)
	
	local starlabelItemColor = starbagnum >= staritemNum and "#00ff00" or "#ff0000";
	objSwf.breakUpanel.btnConsume.htmlLabel = string.format(StrConfig['tianshen020'], starlabelItemColor, staritemName, staritemNum);
	local numcolor = starbagnum >= staritemNum and StrConfig['tianshen022'] or StrConfig['tianshen023']
	objSwf.breakUpanel.consumeNum.htmlText=starbagnum..")";
    if starbagnum >= staritemNum then 
	   objSwf.breakUpanel.btnbreakup:showEffect(ResUtil:GetButtonEffect10())
    else
       objSwf.breakUpanel.btnbreakup:clearEffect();
    end
    objSwf.breakUpanel.attrdescribe.htmlText=StrConfig['tianshen0'..self.currVO.column];
end
function UITianShenView:OnBtnVipLvUpRollOver()
	VipController:ShowAttrTips(TianShenUtil:GetAttrMap(),UIVipAttrTips.ts,VipConsts.TYPE_SUPREME)
end
function UITianShenView:OnbtnActiveItemRollOver()
    
   	if t_tianshen[self.currVO.tid] and t_tianshen[self.currVO.tid].act_item then
		local desTable = t_tianshen[self.currVO.tid].act_item
		local itemid = tonumber(desTable[1]);
		if t_item[itemid] then
			TipsManager:ShowItemTips(itemid);
		end
	end
end
function UITianShenView:OnbtnAdvanceItemRollOver()

	if t_tianshenlv[self.curmodelId] and t_tianshenlv[self.curmodelId].item_cost then
		local desTable = split(t_tianshenlv[self.curmodelId].item_cost, ",")
		local itemid = tonumber(desTable[1]);
		if t_item[itemid] then
			TipsManager:ShowItemTips(itemid);
		end
	end
end

function UITianShenView:OnbtnStarItemRollOver()

	if t_tianshenlv[self.curmodelId] and t_tianshenlv[self.curmodelId].item_cost1 then
		local desTable = split(t_tianshenlv[self.curmodelId].item_cost1, ",")
		local itemid = tonumber(desTable[1]);
		if t_item[itemid] then
			TipsManager:ShowItemTips(itemid);
		end
	end
end
UITianShenView.layerOne={};
UITianShenView.treeData={};
function UITianShenView:OnShowTitlePanel()

	local objSwf = self.objSwf;
	if not objSwf then return end

	self.layerOne=TianShenUtil:GetCreateInfo();
    UIData.cleanTreeData( objSwf.scrollList.dataProvider.rootNode);
	self.treeData.label = "root";
	self.treeData.open = true;
	self.treeData.isShowRoot = false;
	self.treeData.nodes = {};
	for i , vo in ipairs(self.layerOne) do
		local scrollNode = {};
		scrollNode.open = true;
		scrollNode.withIcon = true;
		scrollNode.str = vo.name;
		scrollNode.nodes = {};
		scrollNode.nodeType = 1;
		scrollNode.id = i;
     for j, k in ipairs(TianShenModel:GetTitleTable(vo.type)) do
		local nodeThree = {};
		local strname;
		nodeThree.nodeType = 2;
	    if k.state==0 then
         strname=string.format(StrConfig['tianshen041'] or "",k.name)
	    else
         strname=string.format(StrConfig['tianshen000'..vo.type] or "",k.name)
	    end
		nodeThree.title2 =strname;
		nodeThree.id = TianShenConsts.roleid*k.id;
		nodeThree.index=i;
		nodeThree.btnSelected = false;
		if k.id*1000 == self.selectedTitleId then
		   nodeThree.btnSelected = true;
		end
		table.push(scrollNode.nodes, nodeThree)
		end
	table.push(self.treeData.nodes, scrollNode);
	end
	UIData.copyDataToTree(self.treeData,objSwf.scrollList.dataProvider.rootNode);
	objSwf.scrollList.dataProvider:preProcessRoot();
	objSwf.scrollList:invalidateData();
end
--点击事件
function UITianShenView:ItemClick(e)
	
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not e.item.id then
		return;
	end
	objSwf.scrollList:selectedState(e.item.id);
	if e.item.nodeType == 2 then 
	    if self.selectedTitleId==e.item.id then 
	    	return 
	    end;
		self:OnChangeTreeList(e);
	end
	self.selectedTitleId = e.item.id;
end
function UITianShenView:OnChangeTreeList(e)
    
    local objSwf = self.objSwf;
	if not objSwf then return end

    local roleid=e.item.id/1000
    local vo = TianShenModel:GetTianShenVO(roleid);
	self.currVO = vo;
    

	for i=1,TianShenConsts.ListLen do
		if i==self.currVO.column then
		   self.UIAttr= objSwf["attrvalue"..i];
		   self.UIAttr._visible=true;
		else
	        objSwf["attrvalue"..i]._visible=false
		end
    end
    self:UpdateInfo(true);
	self:ShowUpdateSkill(true);
	self:OnShowStateButton();
end
function UITianShenView:ShowUpdateSkill(bFirst)
	if not self.currVO then
		return;
	end
	self:ShowStarUpdate();
	self:ShowTianShenSkill()
end
function UITianShenView:UpdateInfo(bFirst)
	if not self.currVO then
		return;
	end

	self:showTianshenModel(bFirst);
	self:ShowAttrInfo(bFirst);
	self:ShowFightInfo();
end
function UITianShenView:UpdateData(vo)
	if not vo then return; end

    local zhanbianshen =TianShenModel:GetFightModel()
    if zhanbianshen and zhanbianshen.tid==vo.tid then 
    self.currVO=vo
    else
    self.currVO=TianShenModel:GetTianShenVO(self.currVO.tid)
    end
end
--显示属性
function UITianShenView:ShowAttrInfo(bFirst)

	local objSwf = self.objSwf
	if not objSwf then return; end
    
   -- objSwf["attrvalue"..i]._visible=i==self.currVO.tid;
    for i=1,7 do
        self.UIAttr["proattr"..i]._visible=false
    end

	local roleid=self.currVO.tid;
	local rolestar=self.currVO.star;
	local cfg = t_tianshenlv[self.curmodelId];

	local allattr=TianShenUtil:GetMaxProForCurLv(self.currVO.tid)
	local proattr=TianShenUtil:GetCurPro(self.currVO.tid);
	local proLv = TianShenUtil:GetAttrLv(self.currVO.tid)
    local attr=TianShenUtil:GetOpenAttr(self.currVO.tid)
	local attrlv=0;
	local allattrlv=0;
	local Attrs=TianShenUtil:GetActiveAttr(self.currVO.tid)
	for i, att in ipairs(Attrs) do
      local UI = self.UIAttr['proattr' ..i]
		if proattr[att.name] then
        UI._visible = true
  		UI.progress._visible = true
  		local color=t_bianshenmodel[self.currVO.tid].color;
        
  		UI.washLv.htmlLabel = string.format(StrConfig['tianshen6'..self.currVO.column],enAttrTypeName[AttrParseUtil.AttMap[att.name]],proLv[att.name] or 0);
  		UI.progress.washName.htmlLabel=string.format(StrConfig['tianshen037'],proattr[att.name],allattr[att.name]);
  		if bFirst or  TianShenUtil:GetIsActive(self.currVO.step) then
  		    UI.progress:setProgress(proattr[att.name],allattr[att.name]);
  		else
  		    UI.progress:tweenProgress(proattr[att.name],allattr[att.name]);
  		end
        attrlv=attrlv+(proLv[att.name] or 0);
        else
        UI._visible = true

	    UI.washLv.htmlLabel = StrConfig['tianshen034']
	    UI.progress.washName.htmlLabel = string.format(StrConfig['tianshen035'],attr[att.name]);
	    UI.progress:setProgress(0,attr[att.name]);
		end
	end
    local maxnum=TianShenUtil:GetNextLevel(self.currVO)
    objSwf.advancepanel.maxnum.htmlText=maxnum
    objSwf.advancepanel.attrfight.num=attrlv
    local nextstar=rolestar+1;  
    objSwf.advancepanel.attrdescribe.htmlText=StrConfig["tianshen3"..self.currVO.column]
    objSwf.advancepanel.attrquality.htmlLabel=string.format(StrConfig["tianshen000"..self.currVO.column],cfg.quality);

    local nextstar=self.currVO.star+1<5 and self.currVO.star+1 or 5;       
    objSwf.breakUpanel.curstar.htmlText=self.currVO.star;
    objSwf.breakUpanel.NextStar.htmlText=nextstar;
    objSwf.breakUpanel.MaxStep.htmlText=attrlv;
    objSwf.breakUpanel.NextStep.htmlText=maxnum;
    objSwf.advancepanel.progressBar:setProgress(attrlv,maxnum)
end
--显示战斗力信息
function UITianShenView:ShowFightInfo()

	local objSwf = self.objSwf
	if not objSwf then return; end
    local proattr=TianShenUtil:GetCurPro(self.currVO.tid);
    local proattrinfo=TianShenUtil:GetTransforNum(proattr)
    local allproattr=TianShenUtil:GetAllFight();
    local allproattrinfo=TianShenUtil:GetTransforNum(allproattr)
	objSwf.fightLoader.num = PublicUtil:GetFigthValue(proattrinfo);
	objSwf.allfightLoader.num=PublicUtil:GetFigthValue(allproattrinfo);
end
function UITianShenView:HideIncrement()
	self.attrIncrementPolicy = nil
	local objSwf = self.objSwf;
	if not objSwf then return; end
end
function UITianShenView:showTianshenModel(bFirst)

	local objSwf = self.objSwf;
	if not objSwf then return; end
    local level=self.currVO.step;
    local title=self.currVO.star==0;

    if not level or level==0 then
        level=TianShenConsts.roleid*self.currVO.tid;
    end
    self.curmodelId=level;
    local active=self.currVO.state==0;
    
    local advance=TianShenUtil:IsBreakUp(self.currVO);

    local isfull=TianShenUtil:IsLevelFull(self.currVO)
    objSwf.ActivePanel._visible=active;
    objSwf.starTitle.siStar._visible=not active;
     
    objSwf.advancepanel._visible=not isfull and not advance and not active;
    objSwf.breakUpanel._visible=not isfull and advance and not active;

	objSwf.btnActivate._visible= not active;
	objSwf.iconAdactive._visible=active;

	objSwf.greytitle._visible=title and not active;
	if active then self:ShowActiveInfo();end
	if objSwf.advancepanel._visible then self:ShowAdvanceInfo(); end 
    if objSwf.breakUpanel._visible then self:ShowBreakUpInfo(); end
    objSwf.levelfull._visible= isfull;
	self:ShowFairyLandModel(level, bFirst,self.currVO.star);
end
function UITianShenView:OnBtnQuestClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
    
    local cfg=t_tianshen[self.currVO.tid];
    if not cfg then return end
    if cfg.funcopen then
    	if FuncManager:GetFunc(cfg.funcopen) then 
    	    FuncManager:OpenFunc(cfg.funcopen,true);
    	end
    else
       --if self.currVO.tid==1 then 

    end
end
function UITianShenView:OnBtnActivateClick()


	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not TianShenModel:IsActive(self.currVO.tid) then return end
   
	local vo = TianShenModel:GetFightModel();
	if vo then
		if vo.tid == self.currVO.tid then
			TianShenController:SendChangeTianshen(vo.tid, 1);
		else
			TianShenController:SendChangeTianshen(vo.tid, 1);
			TianShenController:SendChangeTianshen(self.currVO.tid, 2)
		end
	else
		TianShenController:SendChangeTianshen(self.currVO.tid, 2)
	end
end
function UITianShenView:OnShowStateButton()

    local objSwf = self.objSwf
	if not objSwf then return end

    local zhanbianshenshen = TianShenModel:GetFightModel();
	if zhanbianshenshen then
		if zhanbianshenshen.tid == self.currVO.tid then
           objSwf.btnActivate.selected=true; 
		else
	       objSwf.btnActivate.selected=false;
		end
	else
         objSwf.btnActivate.selected=false;
	end
	--vo.column
end
--模型
function UITianShenView:ShowFairyLandModel(level, bFirst,star)
	local objSwf = self.objSwf;
	if not objSwf then return; end
    if not bFirst then return end

	local cfg = t_tianshenlv[level];
	if not cfg then
		Error("Cannot find config of tianshen. level:" .. level);
		return;
	end

    local wWidth, wHeight = 4000,2000;
	if not self.objUIDraw then
		local viewPort = _Vector2.new(wWidth, wHeight);
		self.objUIDraw = UISceneDraw:new("UITianShenView", self.objSwf.fairylandloader, viewPort);
	end
	self.objSwf.fairylandloader._x=-1200;
	self.objSwf.fairylandloader._y=-500;
	self.objUIDraw:SetUILoader(self.objSwf.fairylandloader);


	if bFirst then
		self.objUIDraw:SetScene(cfg.ui_sen, function()
			self:PlayAnimal(level);
			-- self:PlayStarEffect(star);
		end);
	else
		self.objUIDraw:SetScene(cfg.ui_sen,function()
			-- self:PlayStarEffect(star);
		end);
	end

	self.objUIDraw:SetDraw(true)
	objSwf.cfgImg.source = ResUtil:GetTianshenNameUrl(level);
end

function UITianShenView:PlayStarEffect(star)
	if not self.objUIDraw then
		return;
	end
	local nodes = self.objUIDraw:GetNodes();
	if not nodes or #nodes<1 then
		return;
	end
	
	local node = nil;
	for i,v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton then
			node = v;
			break
		end
	end
	if not node then
		return;
	end
	local skl = node.mesh.skeleton;
	local player = skl.pfxPlayer;
	if not player then
		return;
	end
	
	node.star = node.star or 0;
	local pfx = 'v_jiaodiguanghuan_'..node.star..'.pfx';
	player:stop(pfx, true);
	node.star = star or 0;
	pfx = 'v_jiaodiguanghuan_'..node.star..'.pfx';
	if star ~= 0 then
		self.effectMat = self.effectMat or _Matrix3D.new();
		self.effectMat:identity();
		self.effectPos = self.effectPos or _Vector3.new();
		node.transform:getTranslation(self.effectPos);
		self.effectPos.z = self.effectPos.z + 30;
		self.effectMat:setTranslation(self.effectPos);
		pfx = player:play(pfx,pfx);
		pfx.bind = true;
		pfx.keepInPlayer = false;
		pfx.transform:set(self.effectMat);
	end
end

function UITianShenView:PlayAnimal(level)
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.objUIDraw then return end
	local cfg = t_bianshenmodel[self.currVO.id]
	if not cfg then return end
	
	self.objUIDraw:NodeAnimation(cfg.skn_ui, cfg.bianshen_idle)
end
function UITianShenView:GetVIPFightAdd()
   local list={};
   local attMap = TianShenUtil:GetMaxProForCurLv(self.currVO.tid);
   for attr,value in pairs(attMap) do
     table.push(list,{proKey = attr, proValue = value})
   end
   return list;
end
function UITianShenView:DisposeFairyLand()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil);
	end
end
function UITianShenView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end
function UITianShenView:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false)
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil
	end
	
	self.effectMat = nil;
	self.effectPos = nil;
end
function UITianShenView:GetWidth()
	return 1397;
end
function UITianShenView:GetHeight()
	return 823
end
function UITianShenView:ESCHide()
	return true;
end
function UITianShenView:IsTween()
	return true;
end
--------------------------- 消息处理---------------------------------
-- 监听消息列表
function UITianShenView:ListNotificationInterests()
	return {
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.BagItemNumChange,
		NotifyConsts.TianShenActiveUpdate,
		NotifyConsts.TianShenChangeModel,
		NotifyConsts.TianShenStarUpdate,
		NotifyConsts.TianShenUpdate,
		NotifyConsts.TianShenLevelUpdate, 
		NotifyConsts.PlayerAttrChange,
	};
end
--处理消息
function UITianShenView:HandleNotification(name,body)
	local objSwf = self.objSwf
	if not objSwf then return; end
    
    if name ==NotifyConsts.TianShenActiveUpdate then
       self:OnShowTitlePanel()
	elseif name == NotifyConsts.TianShenUpdate then
		self:UpdateData(boby);
		self:UpdateInfo();
	elseif name == NotifyConsts.BagItemNumChange then
		self:ShowActiveInfo();
		self:ShowBreakUpInfo();
		self:ShowAdvanceInfo();
	elseif name == NotifyConsts.TianShenStarUpdate then
		self:ShowUpdateSkill();
		objSwf.stareffect:playEffect(1)
	elseif name == NotifyConsts.TianShenChangeModel then
        self:OnShowStateButton();
    elseif name == NotifyConsts.TianShenLevelUpdate then 
        objSwf.leveleffect:playEffect(1)
    elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
		   self:ShowActiveInfo()
		end
	end
end


