--[[
城主特权，
wangshuai
]]
_G.UISuperGloryView = BaseUI:new("UISuperGloryView")

UISuperGloryView.curRewardItem = {};
function UISuperGloryView:Create()
	self:AddSWF("superGloryPanel.swf",true,"center")
	self:AddChild(UISuperGloryTwo,"erjipanel")
	self:AddChild(UISuperGloryThree,"sanjipanel")
	self:AddChild(UISuperGloryRules,"rulespanel")
	self:AddChild(UISuperGloryLibao,"libaopanel")
end;

function UISuperGloryView:OnLoaded(objSwf)
	self:GetChild("erjipanel"):SetContainer(objSwf.childPanel)
	self:GetChild("sanjipanel"):SetContainer(objSwf.childPanel)
	self:GetChild("rulespanel"):SetContainer(objSwf.childPanel)
	self:GetChild("libaopanel"):SetContainer(objSwf.childPanel)

	objSwf.closebtn.click = function() self:ClosePanle() end;

	objSwf.rewardItemBtn.click = function() self:RewardItemClick() end;
	objSwf.rewardItemBtn.rollOver = function() self:ResardItemOver() end;
	objSwf.rewardItemBtn.rollOut  = function() TipsManager:Hide() end;

	objSwf.btncuo.rollOver = function() self:btncuoOver() end;
	objSwf.btncuo.rollOut  = function() TipsManager:Hide() end;

	objSwf.Wroship.click = function() self:WroshipClick()end;
	objSwf.Wroship.rollOver = function() self:WroshipOver() end;
	objSwf.Wroship.rollOut  = function() TipsManager:Hide() end;

	objSwf.SetDeputy.click = function() self:SetDeputyClick()end;
	objSwf.Goactivity.click = function() self:GoactivityClick()end;
	objSwf.lookZcRules.click = function() self:LookZcRulesClick()end;

	objSwf.btnrole.rollOver = function() self:RoleTipsOver() end;
	objSwf.btnrole.rollOut = function() self:RoleTipsOut() end;

	objSwf.jiangli_btn.click = function() self:OnJiangliClick()end;
	objSwf.jiangli_btn.rollOver = function() TipsManager:ShowBtnTips( StrConfig["SuperGlory829"],TipsConsts.Dir_RightDown); end;
	objSwf.jiangli_btn.rollOut  = function() TipsManager:Hide() end;

	-- objSwf.btnmount.rollOver = function() self:MountTipsOver() end;
	-- objSwf.btnmount.rollOut = function() self:MountTipsOut() end;

	objSwf.list.itemClick = function(e) self:ModelRoleClick(e) end;
end;

-- 面板类型
function UISuperGloryView:GetPanelType()
	return 1;
end;

function UISuperGloryView:IsTween()
	return true;
end

function UISuperGloryView:IsShowLoading()
	return true;
end

function UISuperGloryView:IsShowSound()
	return true;
end

function UISuperGloryView:OnJiangliClick()
	self:ShowErjiPanel("erjipanel");
end;


function UISuperGloryView:OnFullShow()
	self:UpdateMask()
	self:UpdateCloseButton();
end;

function UISuperGloryView:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
	self:UpdateCloseButton();
end


function UISuperGloryView:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	-- objSwf.closebtn._x = math.min( math.max( wWidth - 50, 1280 ), 1320 )
end

function UISuperGloryView:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 200
	objSwf.mcMask._height = wHeight + 100
end

function UISuperGloryView:ShowErjiPanel(name)
	local child = self:GetChild(name);
	if not child then return end;
	self:ShowChild(name)
end;

function UISuperGloryView:OnShow()
	self:UpdateMask();
	self:UpdateCloseButton();

	--请求信息
	SuperGloryController:ReqSuperGloryRoleinfo()
	
	
	self:ShowRoleInfo();
	self:ShowSuperInfo();
end;


function UISuperGloryView:OnHide()
	local objSwf = self.objSwf;
	if UISuperGloryWindow:IsShow() then 
		UISuperGloryWindow:Hide()
	end;
	if self.objUISceneDraw then 
		self.objUISceneDraw:SetDraw( false );
	end;
	for i = 1, 6 do
		if self.avatList[i] then 
			self.avatList[i]:ExitMap();
			self.avatList[i] = nil;
		end;
	end
end;

function UISuperGloryView:ModelRoleClick(e)
	local index = e.index;
	local vo = e.item;
	if index == 0 then return end;
	UISuperGloryWindow:SetShowData(vo.roleID)
	UISuperGloryWindow:Show();
end;
-- 显示人物模型list
function UISuperGloryView:ShowRoleInfo()
	local objSwf = self.objSwf;
	local list = SuperGloryModel:GetSuperRoleInfo();
	local index = 6;
	--trace(list)
	for i=1,index do
		local vo = list[i];
		local listvo = {};
		if not vo then 
			local item = objSwf["item"..i];
			listvo.roleID = 0;
			listvo.name = StrConfig["SuperGlory818"];
			local cfg = t_citywar[i];
			-- print('=========================UISuperGloryView  i',i)
			local title = t_title[cfg.title];
			-- print('=========================UISuperGloryView  cfg.title',cfg.title)
			listvo.descUrl = ResUtil:GetTitleIconSwf(title.bigIcon);
			-- print('=========================UISuperGloryView  title.bigIcon',title.bigIcon,cfg.title)
			listvo.ranktype = i;
			item:setData(UIData.encode(listvo))
		else
			local cfg = t_citywar[vo.ranktype];
			if not cfg  then 
				print("ERROR: cur vo.ranktype is error val"..vo.ranktype)
				return end;
			local title = t_title[cfg.title];
			if not title then 
				print("ERROR: cur cfg.title is error val "..cfg.title)
			return end;
			local item = objSwf["item"..vo.ranktype];
			listvo.roleID = vo.roleID;
			print(vo.roleName)
			listvo.name =  vo.roleName;
			listvo.descUrl = ResUtil:GetTitleIconSwf(title.bigIcon);
			listvo.ranktype = vo.ranktype;
			item:setData(UIData.encode(listvo))
		end;
	end;

	-- for i,info in ipairs(list) do 
	-- 	local item = objSwf["item"..info.ranktype];
	-- 	local vo = {};
	-- 	vo.roleID = info.roleID;
	-- 	vo.name = info.roleName;
	-- 	vo.desc = StrConfig["SuperGloryRankType00"..info.ranktype]
	-- 	vo.descUrl = ResUtil:GetSuperGloryTitleNameURL(i)
	-- 	item:setData(UIData.encode(vo))
	-- end;

	local superManInfo = SuperGloryModel:GetSuperManInfo();
	if not superManInfo then return end;
	objSwf.superName.text = superManInfo.roleName;

end;	
-- 显示详细信息
function UISuperGloryView:ShowSuperInfo()
	local objSwf = self.objSwf;

	local infovo = SuperGloryModel:GetAllSuperInfo()
	if not infovo.cont then return end;
	local level;
	if infovo.cont<1 then
		level = 1
	else
		level = infovo.cont
	end
	local cfg = t_guildwangchengextra[level].reward;
	local list = split(cfg,",")
	self.curRewardItem = RewardSlotVO:new();
	self.curRewardItem.id = tonumber(list[1]);
	objSwf.rewardItem:setData(self.curRewardItem:GetUIData())



	local zuobiao = {152,147,142}
	objSwf.lanxunum.num =  infovo.cont;
	if infovo.cont < 10 then 
		objSwf.lanxunum._x = zuobiao[1];
	elseif infovo.cont < 100 then 
		objSwf.lanxunum._x = zuobiao[2];
	elseif infovo.cont < 1000 then
		objSwf.lanxunum._x = zuobiao[3];
	end;
	objSwf.WroshipNum.text = infovo.worship;
	if infovo.defName == "" then 
		objSwf.shouName.htmlText = StrConfig["SuperGlory817"];
	else
		objSwf.shouName.htmlText = infovo.defName;
	end;

	if infovo.atkName == "" then 
		objSwf.gongName.htmlText = StrConfig["SuperGlory817"];
	else
		objSwf.gongName.htmlText = infovo.atkName;
	end;
end; 

function UISuperGloryView:TimerCountdown()
	local objSwf = self.objSwf;
	local curState = SuperGloryModel:GetUnionCityWarState()
	if curState == 1 then 
		-- kai qi
		objSwf.curState.text = StrConfig["SuperGlory805"]
	else 
		objSwf.curState.text = StrConfig["SuperGlory806"]
	end;
	local nexttime = SuperGloryModel:GetLastTimer()
	local toke = CTimeFormat:toweekEx(nexttime)

	local year, month, day, hour, minute, second = CTimeFormat:todate(nexttime,true);
	if minute < 10 then  minute = "0"..minute end;
	if second < 10 then  second = "0"..second end;
	objSwf.nextTime.htmlText = string.format(StrConfig["SuperGlory807"],year,month,day,hour, minute)..StrConfig["SuperGloryWeek00"..toke];

end;
-- 奖励物品，点击
function UISuperGloryView:RewardItemClick()
	if not UISuperGloryLibao:IsShow() then 
		UISuperGloryLibao:Show();
	else
		UISuperGloryLibao:Hide();
	end;
end;
-- 奖励物品 移入
function UISuperGloryView:ResardItemOver()
	local vo = self.curRewardItem;
	if not vo then return end;
	if not vo:GetTipsInfo() then return end;
	local tips = vo:GetTipsInfo();
	TipsManager:ShowTips(tips.tipsType,tips.info,tips.tipsShowType, TipsConsts.Dir_RightDown)
end;
-- 奖励物品 移除
function UISuperGloryView:ResardItemOut()

end;

-- 属性
function UISuperGloryView:btncuoOver()
	local atkSuperlist = AttrParseUtil:Parse(t_consts[41].param);
	local infovo = SuperGloryModel:GetAllSuperInfo()
	local html = ""..StrConfig['SuperGlory820'];
	local baval = infovo.cont or 1;
	for i,info in ipairs(atkSuperlist) do 
		html = html.."<font color='#d5b772'>"..enAttrTypeName[info.type].."+  </font><font color='#00ff00'>".. info.val* baval .."%</font><br/>"
	end;
	TipsManager:ShowBtnTips(html);
end;

function UISuperGloryView:WroshipOver()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local cfg = t_consts[45].param;
	if not cfg then return end;
	cfg = split(cfg,",")
	if not cfg then return end;
	TipsManager:ShowBtnTips(string.format(StrConfig["SuperGlory830"],cfg[2]),TipsConsts.Dir_RightDown)
end;


-- 膜拜
function UISuperGloryView:WroshipClick()
	local isDuke = SuperGloryModel:GetIsDuke();


	local list = SuperGloryModel:GetSuperRoleInfo()
	if not list[1] then 
		FloatManager:AddNormal(StrConfig['SuperGlory819']);
		return;
	end;

	if isDuke == 1 then
		FloatManager:AddNormal(StrConfig['SuperGlory809']);
		return;
	end;

	SuperGloryController:ReqSuperGloryWroship()
end;

-- 是否显示设置副手按钮
function UISuperGloryView:SetShowDeputy()
	local objSwf = self.objSwf;
	local isDuke = SuperGloryModel:GetIsDuke();
	if isDuke == 1 then 
		objSwf.SetDeputy._visible = true;
	else
		objSwf.SetDeputy._visible = false;
	end;
end;
-- 设置副手
function UISuperGloryView:SetDeputyClick()
	local isDuke = SuperGloryModel:GetIsDuke();
	if isDuke ~= 1 then return end;
	-- 城主请求设置副手
	self:ShowErjiPanel("sanjipanel")
end;
-- 去参加活动
function UISuperGloryView:GoactivityClick()
	-- 请求进入帮派王城战活动
	UnionCityWarController:EnterUnionCityWar()
end;
-- 战场规则
function UISuperGloryView:LookZcRulesClick()
	self:ShowErjiPanel("rulespanel")
end;

function UISuperGloryView:ClosePanle()
	self:Hide();
end;


-- 城主人物tips
function UISuperGloryView:RoleTipsOut()
	UISuperGloryRoleTips:Hide();
end;

function UISuperGloryView:RoleTipsOver()
	UISuperGloryRoleTips:Show();
end;

--  城主坐骑tips
function UISuperGloryView:MountTipsOut()
	UISuperGloryMountTips:Hide();
end;

function UISuperGloryView:MountTipsOver()
	UISuperGloryMountTips:Show();
end;


	-- notifaction
function UISuperGloryView:ListNotificationInterests()
	return {
		NotifyConsts.SuperGloryAllInfo,NotifyConsts.SuperGloryRoleInfo;
		}
end;
function UISuperGloryView:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.SuperGloryAllInfo then
		self:ShowSuperInfo();
		self:SetShowDeputy();
	elseif name == NotifyConsts.SuperGloryRoleInfo then 
		self:ShowRoleInfo();
		--self:DrawRole();
		self:SceneLoadFun()
	end;
end;


-- drwa scene
_G.SUPERGLORY_DRAW_SCENE_UI = "SuperGloryDrawSceneUI"
function UISuperGloryView:SceneLoadFun()
	local objSwf = self.objSwf;
	if not self.viewPort then self.viewPort = _Vector2.new(1299, 735); end
	if not self.objUISceneDraw then
		self.objUISceneDraw = UISceneDraw:new(_G.SUPERGLORY_DRAW_SCENE_UI, objSwf.sceneLoad, self.viewPort, true);
	end
	self.objUISceneDraw:SetUILoader( objSwf.sceneLoad )
	local src = "v_pwt_dixing.sen"
	self.objUISceneDraw:SetScene(src, function()
		--self:ShowFristRank();
		print("加载完成")
		self:DrawRole();
	end );
	print("执行完毕")
	self.objUISceneDraw:SetDraw( true );
end;

UISuperGloryView.avatList = {};

function UISuperGloryView:DrawRole()
	local objSwf = self.objSwf;
	local list = SuperGloryModel:GetSuperRoleInfo();
	--for ic,info in pairs(list) do 
	for ic=1,6 do 
		local info = list[ic]
		if not info  then 
			info = {};
			if ic > 2 then 
				info.prof = ic - 2;
			elseif ic == 1 then 
				info.prof = 3
			elseif ic == 2 then 
				info.prof = 4
			end;
			info.dress = 0;
			info.arms = 0;
			info.shoulder = 0;
			info.fashionshead = 0;
			info.fashionsarms = 0;
			info.fashionsdress = 0;
			info.wuhunId = 0;
			info.wing = 0;
			info.suitflag = 0;
			info.ranktype = ic;
		else
			info.wing = 0;
		end;
		if self.avatList[ic] ~= nil then 
			self.avatList[ic]:ExitMap();
			self.avatList[ic] = nil;
		end;
		self.avatList[ic] =  CPlayerAvatar:new();
		--self.curModel = self.avatList[ic];
		self.avatList[ic]:CreateByVO(info);
		local list = self.objUISceneDraw:GetMarkers();

		local indexc = "marker"..ic
		self.avatList[ic]:EnterUIScene(self.objUISceneDraw.objScene,list[indexc].pos,list[indexc].dir,list[indexc].scale, enEntType.eEntType_Player)
		if info.ranktype == 1 then 
			-- self.avatList[ic]:PlaySuperGloryZuoAction()
			self.avatList[ic]:PlaySuperGloryZanAction()
		else
			self.avatList[ic]:PlaySuperGloryZanAction()
		end;
	end;

end;


function UISuperGloryView:GetWidth()
	return 1397
end;
function UISuperGloryView:GetHeight()
	return 823
end;
