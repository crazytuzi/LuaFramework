--[[兵魂面板
zhangshuhui
2015年5月20日11:09:16
]]

_G.UIBingHunView = BaseUI:new("UIBingHunView")

UIBingHunView.objUIDraw = nil;--3d渲染器

UIBingHunView.typeCount = 6; --list可显示的是6个类型
UIBingHunView.attrMaxNum = 6;

function UIBingHunView:Create()
	self:AddSWF("binghunMainPanel.swf", true, nil)
end

local isShowBingHunDes = false
local bingHunmouseMoveX = 0
function UIBingHunView:OnLoaded(objSwf,name)
	objSwf.listBingHun.change = function() if not self.bShowState then return; end self:InitData();self:ShowBingHunInfo(); end
	objSwf.statepanel.btnQiYong.click = function() self:OnBtnQiYongClick(); end;
	objSwf.statepanel.btnCancelQiYong.click = function() self:OnBtnCancelQiYongClick(); end;
	objSwf.getpanel.btnactiveinfo.rollOver = function() self:OnActiveInfoRollOver(); end
	objSwf.getpanel.btnactiveinfo.rollOut  = function()  TipsManager:Hide(); end
	objSwf.statepanel.yishiyongeffect.complete = function()
									objSwf.statepanel.imgqiyong._visible = true;
									objSwf.statepanel.btnCancelQiYong.visible = true;
								end	
	objSwf.btnskill.rollOver = function() self:OnBtnSkillRollOver(); end
	objSwf.btnskill.rollOut  = function()  TipsManager:Hide();  end
	--战斗力值居中
	self.numFightx = objSwf.numLoaderFight._x
	objSwf.numLoaderFight.loadComplete = function()
									objSwf.numLoaderFight._x = self.numFightx - objSwf.numLoaderFight.width / 2
								end
								
	objSwf.iconDes._alpha = 0
	objSwf.btnDesShow.rollOver = function()
		if isShowBingHunDes then return end
		local mountId = self.curBingHunOrder
		if not mountId or mountId <= 0 then
			FPrint("要显示的圣器id不正确")
			return
		end
		local cfg = t_binghun[self.curBingHunOrder]
		if not cfg then return end
		if cfg and cfg.des_icon then
			objSwf.iconDes.desLoader.source = ResUtil:GetBingHunIconName(cfg.des_icon);
		end
		Tween:To(objSwf.iconDes,5,{_alpha=100});
		isShowBingHunDes = true
	end
	
	objSwf.btnDesShow.rollOut = function()
		self.isMouseDrag = false
		if self.objUIDraw then
			self.objUIDraw:OnBtnRoleRightStateChange("out"); 				
		end
		if not isShowBingHunDes then return end
		
		Tween:To(objSwf.iconDes,1,{_alpha=0});
		isShowBingHunDes = false
	end
	
	objSwf.btnDesShow.press = function() 		
		local monsePosX = _sys:getRelativeMouse().x;--获取鼠标位置		
		bingHunmouseMoveX = monsePosX;   		       
		self.isMouseDrag = true
	end

	objSwf.btnDesShow.release = function()
		self.isMouseDrag = false
		if self.objUIDraw then
			self.objUIDraw:OnBtnRoleRightStateChange("release"); 				
		end
	end
end

function UIBingHunView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIBingHunView:OnShow(name)
	--初始化数据
	--self:InitData();
	--初始化UI
	self:InitUI();
	--显示
	--self:ShowBingHunInfo();
end

function UIBingHunView:OnHide()
	local objSwf = self.objSwf
	if not objSwf then return end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.curBingHunOrder = 1;
	self.preBingHunOrder = 0;
end

--启用
function UIBingHunView:OnBtnQiYongClick()
	local binghunvo = BingHunModel:GetBingHunById(self.curBingHunOrder);
	if binghunvo then
		if binghunvo.time ~= 0 then
			BingHunController:ReqBingHunChangeModel(self.curBingHunOrder);
		end
	end
end

--取消启用
function UIBingHunView:OnBtnCancelQiYongClick()
	local binghunvo = BingHunModel:GetBingHunById(self.curBingHunOrder);
	if binghunvo then
		if binghunvo.time ~= 0 then
			BingHunController:ReqBingHunChangeModel(0);
		end
	end
end

function UIBingHunView:OnActiveInfoRollOver()
	local binghunvo = BingHunModel:GetBingHunById(self.curBingHunOrder);
	if not binghunvo then
		local binghuncfg = t_binghun[self.curBingHunOrder];
		if binghuncfg then
			--道具
			if binghuncfg.activation == 3 then
				local titem = split(binghuncfg.param, ",")
				local itemid = tonumber(titem[1]);
				TipsManager:ShowItemTips(itemid);
			end
		end
	end
end

function UIBingHunView:OnBtnSkillRollOver()
	local cfg = t_binghun[self.curBingHunOrder];
	if cfg then
		local get = false;
		local binghunvo = BingHunModel:GetBingHunById(self.curBingHunOrder);
		if binghunvo then
			if binghunvo.time ~= 0 then
				get = true;
			end
		end
		local skillid = cfg.skill;
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=skillid,condition=false,get=get},TipsConsts.ShowType_Normal,
							TipsConsts.Dir_RightUp);
	end
end
-------------------事件------------------

function UIBingHunView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.BagItemNumChange then
		self:ShowActiveInfo();
	elseif name == NotifyConsts.BingHunUpdate then
		self:InitData();
		self:ShowBingHunInfo();
		self:PlayYiShiYongEffect(body);
	end
end

function UIBingHunView:ListNotificationInterests()
	return {NotifyConsts.BagItemNumChange,NotifyConsts.BingHunUpdate};
end

function UIBingHunView:InitData()
	self.curBingHunOrder = self:GetCurBingHunId();
end

function UIBingHunView:InitUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.listBingHun.selectedIndex = nil;
	-- 当前b兵魂的索引
	if BingHunModel.BingHunselectid == 0 then
		self.curBingHunOrder = 1;
	else
		self.curBingHunOrder = BingHunModel.BingHunselectid;
	end
	self.preBingHunOrder = 0;
	-- local listIndex = objSwf.listBingHun.selectedIndex
	-- if not listIndex or listIndex < 0 then
		-- if BingHunModel.BingHunselectid == 0 then
			-- objSwf.listBingHun.selectedIndex = 0
			-- listIndex = 0
		-- else
			-- objSwf.listBingHun.selectedIndex = BingHunModel.BingHunselectid - 1;
			-- listIndex = BingHunModel.BingHunselectid - 1;
		-- end
	-- else
		-- --self:ShowBingHunInfo();
	-- end
end

function UIBingHunView:ClearUI()
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

function UIBingHunView:GetCurBingHunId(order)
	local objSwf = self.objSwf
	if not objSwf then return end
	-- 当前b兵魂的索引
	local listIndex = objSwf.listBingHun.selectedIndex
	if not listIndex or listIndex < 0 then
		if BingHunModel.BingHunselectid == 0 then
			objSwf.listBingHun.selectedIndex = 0
			listIndex = 0
		else
			objSwf.listBingHun.selectedIndex = BingHunModel.BingHunselectid - 1;
			listIndex = BingHunModel.BingHunselectid - 1;
		end
	end
	if order and order > 0 then
		objSwf.listBingHun.selectedIndex = order
		if order > self.typeCount then
			objSwf.listBingHun.scrollPosition = order - self.typeCount;
		end
		listIndex = order - 1;
	end
	
	-- 当前兵魂的id
	local curBingHunId = listIndex;
	if curBingHunId then
		self.curBingHunOrder = curBingHunId + 1
	end
	return self.curBingHunOrder
end

--显示
function UIBingHunView:ShowBingHunInfo()
	--属性
	self:ShowAttrInfo();
	--战斗力
	self:ShowFight();
	--激活条件
	self:ShowActiveInfo();
	--按激活钮
	self:ShowActiveBtn();
	--显示兵魂list
	self:ShowBingHunList();
	--技能
	self:ShowBingHunSkill();
	--显示升阶信息
	self:ShowOrderUpInfo();
	--模型
	self:DrawBingHun(self.curBingHunOrder, true);
end

--显示激活条件
function UIBingHunView:ShowActiveInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.getpanel._visible = false;
	objSwf.getpanel.btnactiveinfo.htmlLabel = "";
	objSwf.getpanel.tfactiveinfo.htmlText = "";
	objSwf.statepanel.imgqiyong._visible = false;
	objSwf.statepanel.btnQiYong.visible = false;
	objSwf.statepanel.btnCancelQiYong.visible = false;
	objSwf.imgnotget._visible = false;
	objSwf.statepanel.yishiyongeffect:stopEffect();
	objSwf.statepanel.yishiyongeffect._visible = false;
	local binghunvo = BingHunModel:GetBingHunById(self.curBingHunOrder);
	if binghunvo then
		if BingHunModel:GetBingHunSelect() == self.curBingHunOrder then
			objSwf.statepanel.imgqiyong._visible = true;
			objSwf.statepanel.btnCancelQiYong.visible = true;
		else
			if binghunvo.time ~= 0 then
				objSwf.statepanel.btnQiYong.visible = true;
			else
				objSwf.imgnotget._visible = true;
			end
		end
	else
		objSwf.imgnotget._visible = true;
		local binghuncfg = t_binghun[self.curBingHunOrder];
		if binghuncfg then
			--任务激活
			if binghuncfg.activation == 2 then
				objSwf.getpanel._visible = true;
				objSwf.getpanel.tfactiveinfo.htmlText = binghuncfg.txt;
			--道具激活
			elseif binghuncfg.activation == 3 then
				local titem = split(binghuncfg.param, ",")
				local itemid = tonumber(titem[1]);
				local intemNum = BagModel:GetItemNumInBag(itemid);
				local stritem = "";
				if intemNum > 0 then
					stritem = "<font color='#00ff00'><u>"..t_item[itemid].name.."</u></font>";
				else
					stritem = "<font color='#cc0000'><u>"..t_item[itemid].name.."</u></font>";
				end
				objSwf.getpanel._visible = true;
				objSwf.getpanel.btnactiveinfo.htmlLabel = string.format( binghuncfg.txt, stritem)
			end
		end
	end
end

--更新信息
function UIBingHunView:PlayYiShiYongEffect(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.statepanel.yishiyongeffect:stopEffect();
	objSwf.statepanel.yishiyongeffect._visible = false;
	if body and body.ischange and body.ischange == true then
		if BingHunModel:GetBingHunSelect() == self.curBingHunOrder then
			objSwf.statepanel.yishiyongeffect._visible = true;
			objSwf.statepanel.yishiyongeffect:playEffect(1);
			objSwf.statepanel.btnQiYong.visible = false;
			objSwf.statepanel.imgqiyong._visible = false;
		end
	end
end

--显示属性
function UIBingHunView:ShowAttrInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=1,self.attrMaxNum do
		objSwf["tftitle"..i].text = "";
		objSwf["tfvalue"..i].text = "";
	end
	local cfg = t_binghun[self.curBingHunOrder];
	if cfg then
		local attrList = split(cfg.add_attr,"#");
		for i,attrStr in ipairs(attrList) do
			local attrvo = split(attrStr,",");
			local vo = {};
			vo.type = AttrParseUtil.AttMap[attrvo[1]];
			vo.val = tonumber(attrvo[2]);
			
			-- if vo.type == enAttrType.eaGongJi then
				-- objSwf.infopanel["labletype"..i].text = UIStrConfig["lovelypet1001"];
			-- elseif vo.type == enAttrType.eaFangYu then
				-- objSwf.infopanel["labletype"..i].text = UIStrConfig["lovelypet1002"];
			-- elseif vo.type == enAttrType.eaMaxHp then
				-- objSwf.infopanel["labletype"..i].text = UIStrConfig["lovelypet1003"];
			-- end
			objSwf["tftitle"..i].text = enAttrTypeName[AttrParseUtil.AttMap[attrvo[1]]];
			if attrvo[1] == "defparry" then
				objSwf["tfvalue"..i].text = string.format("%.2f",vo.val * 100).."%";
			else
				objSwf["tfvalue"..i].text = vo.val;
			end
		end
	end
	
	self:ShowAttrAddInfo();
end
--显示增加属性
function UIBingHunView:ShowAttrAddInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf["tfFightAdd"].text = "";
	objSwf["imgFightAdd"]._visible = false;
	for index=1, self.attrMaxNum do
		objSwf["tfvalue"..index.."Add"].text = "";
		objSwf["imgattr"..index.."Add"]._visible = false;
	end
end
--显示战斗力
function UIBingHunView:ShowFight()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = {};
	local cfg = t_binghun[self.curBingHunOrder];
	if cfg then
		local attrList = split(cfg.add_attr,"#");
		for i,attrStr in ipairs(attrList) do
			local attrvo = split(attrStr,",");
			local vo = {};
			vo.type = AttrParseUtil.AttMap[attrvo[1]];
			vo.val = tonumber(attrvo[2]);
			table.push(list,vo);
		end
	end
	objSwf.numLoaderFight.num = EquipUtil:GetFight(list);
end

--显示激活按钮
function UIBingHunView:ShowActiveBtn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

--显示冰魂list
function UIBingHunView:ShowBingHunList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local list = objSwf.listBingHun;
	list.dataProvider:cleanUp();
	
	self.showList = self:GetBingHunShowList()
	for _, vo in ipairs( self.showList ) do
		list.dataProvider:push( UIData.encode( vo ) );
	end
	list:invalidateData();
end

function UIBingHunView:GetBingHunShowList()
	local sList = {}
	for order=1, BingHunConsts.BingHunMax do
		local uiVO = self:GetListUIVO( order )
		table.push( sList, uiVO )
	end
	table.sort( sList, function( A, B )
		return A.order < B.order
	end )
	return sList
end

function UIBingHunView:GetListUIVO(order)
	local cfg = t_binghun[order]
	if not cfg then return end
	local vo = {}
	vo.order           = order;
	for i=1,3 do
		vo["icon"..i] = ResUtil:GetBingHunIconName(BingHunUtil:GetBingHunHeadIcon(cfg.head_icon,MainPlayerModel.humanDetailInfo.eaProf).."_"..i);
	end
	vo.nameicon = ResUtil:GetBingHunIconName(cfg.name_icon);
	return vo
end

--显示兵魂技能
function UIBingHunView:ShowBingHunSkill()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfskillinfo.htmlText = "";
	local cfg = t_binghun[self.curBingHunOrder];
	if cfg then
		local skillid = cfg.skill;
		local skillvo = t_skill[skillid];
		if skillvo then
			objSwf.iconLoader.source = ResUtil:GetSkillIconUrl(skillvo.icon);
			objSwf.tfskillinfo.htmlText = skillvo.des;
		end
	end
end

--显示升阶信息
function UIBingHunView:ShowOrderUpInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

--刷新升阶信息
function UIBingHunView:RefreshOrderUpInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
end
	
-- 显示类型为level的3d兵魂模型
-- showActive: 是否播放激活动作
local viewBingHunPort;
function UIBingHunView : DrawBingHun( level, showActive )
	if self.preBingHunOrder == level then
		return;
	end
	self.preBingHunOrder = level;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not level then
		level = self:GetCurBingHunId();
	end
	local cfg = {};
	cfg = t_binghun[level];
	if not cfg then
		Error("Cannot find config of binghun. level:"..level);
		return;
	end
	if not self.objUIDraw then
		if not viewBingHunPort then viewBingHunPort = _Vector2.new(1279, 732); end
		self.objUIDraw = UISceneDraw:new( "UIBingHunView", objSwf.modelload, viewBingHunPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelload);

	local prof = MainPlayerModel.humanDetailInfo.eaProf
	local ui_sen = cfg["model" .. prof]
	--local show_san = cfg["san_show_" .. prof]
	-- if showActive then
		-- self.objUIDraw:SetScene( ui_sen, function()
			-- if not show_san or show_san == "" then return end
			-- if not cfg.ui_node then return end
			-- local nodeName = split(cfg.ui_node, "#")
			-- if not nodeName or #nodeName < 1 then return end
			-- for k,v in pairs(nodeName) do
				-- self.objUIDraw:NodeAnimation( v, show_san );
			-- end
		-- end );
	-- else
		self.objUIDraw:SetScene( ui_sen, nil );
	--end

	self.objUIDraw:SetDraw(true)

end