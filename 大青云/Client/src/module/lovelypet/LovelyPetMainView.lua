--[[萌宠主面板
zhangshuhui
2015年6月17日11:41:11
]]

_G.UILovelyPetMainView = BaseUI:new("UILovelyPetMainView")

UILovelyPetMainView.objUIDraw = nil;--3d渲染器

UILovelyPetMainView.lovelypetid = 0;

UILovelyPetMainView.timerKey = nil;

UILovelyPetMainView.lovelypettime = 0;
UILovelyPetMainView.actionTime = 0;
UILovelyPetMainView.actionTimeMax = 15;
UILovelyPetMainView.buff_id = 1012000;

function UILovelyPetMainView:Create()
	self:AddSWF("lovelyPetMainPanel.swf", true, "center")
	
	self:AddChild(UILovelyPetRenewView, LovelyPetConsts.LOVELYPETRENEW);
end

function UILovelyPetMainView:OnLoaded(objSwf,name)
	self:GetChild(LovelyPetConsts.LOVELYPETRENEW):SetContainer(objSwf.childPanel);
	--关闭
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	
	--激活
	objSwf.btn_active.click = function() self:OnBtnActiveClick() end
	
	--出战
	objSwf.btn_fight.click = function() self:OnBtnFightClick() end
	
	--休息
	objSwf.btn_rest.click = function() self:OnBtnRestClick() end
	
	--续费
	objSwf.btn_renew.click = function() self:OnBtnRenewClick() end
	-- objSwf.btn_renew1.click = function() self:OnBtnRenewClick() end
	
	objSwf.activeinfopanel.toolpanel.btnTool.rollOver = function() self:OnBtnToolRollOver(); end
	objSwf.activeinfopanel.toolpanel.btnTool.rollOut  = function()  TipsManager:Hide();  end
	
	objSwf.tileListLovelyPet.change = function() self:ShowLovelyPetInfo(); end
	
	--战斗力值居中
	self.numFightx = objSwf.fightLoader._x
	objSwf.fightLoader.loadComplete = function()
									objSwf.fightLoader._x = self.numFightx - objSwf.fightLoader.width / 2
								end
end

function UILovelyPetMainView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

-- function UILovelyPetMainView:Update()
	-- local objSwf = self.objSwf;
	-- if not objSwf then return end
	-- if not self.bShowState then return end
	
	-- local cfg = t_horse[self.lovelypetid];
	-- if not cfg then
		-- Error("Cannot find config of horse. level:"..self.lovelypetid);
		-- return;
	-- end
	-- local ui_node =  MountUtil:GetMountSen(cfg.ui_node,MainPlayerModel.humanDetailInfo.eaProf);
	
	-- if self.objUIDraw then
		-- self.objUIDraw:Update(ui_node);
	-- end
-- end

function UILovelyPetMainView:IsShowLoading()
	return true;
end

function UILovelyPetMainView:IsTween()
	return true;
end

function UILovelyPetMainView:GetPanelType()
	return 1;
end

function UILovelyPetMainView:IsShowSound()
	return true;
end

function UILovelyPetMainView:GetWidth()
	return 1146
end

function UILovelyPetMainView:GetHeight()
	return 687
end

function UILovelyPetMainView:OnShow(name)
	--初始化数据
	self:InitData();
	--初始化UI
	self:InitUI();
	--计时器
	self:StartTimer();
	--显示
	self:ShowLovelyPetInfo();
	
	self:UpdateMask();
	-- self:UpdateCloseButton();
end

function UILovelyPetMainView:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
	-- self:UpdateCloseButton()
end

function UILovelyPetMainView:UpdateMask()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	-- objSwf.mcMask._width = wWidth + 10
	-- objSwf.mcMask._height = wHeight + 10
end

function UILovelyPetMainView:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min( math.max( wWidth - 50, 1280 ), 1380 )
end

function UILovelyPetMainView:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	
	self:DelTimerKey();
	RemindController:AddRemind(RemindConsts.Type_LovelyPetFight, 0);
	RemindController:AddRemind(RemindConsts.Type_LovelyPet, 0);
end

--点击关闭按钮
function UILovelyPetMainView:OnBtnCloseClick()
	self:Hide();
	SoundManager:StopSfx()
end

--点击激活按钮
function UILovelyPetMainView:OnBtnActiveClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local lovelypetid = self:GetCurLovelyPetId();
	local state = LovelyPetUtil:GetLovelyPetState(lovelypetid);
	if state ~= LovelyPetConsts.type_notactive then
		return;
	end
	local cfg = t_lovelypet[lovelypetid];
	if not cfg then
		return;
	end
	if cfg.gettype == 1 then
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaLevel < tonumber(cfg.getcondition) then
			FloatManager:AddNormal( StrConfig["lovelypet21"], objSwf.btn_active);
			return;
		end
	elseif cfg.gettype == 2 then
		local attrvo = split(cfg.getcondition,",");
		local itemNum = BagModel:GetItemNumInBag(tonumber(attrvo[1]));
		if itemNum < tonumber(attrvo[2]) then
			UIShoppingMall:Show();
			FloatManager:AddNormal( StrConfig["lovelypet25"], objSwf.btn_active);
			return;
		end
	end
	LovelyPetController:ReqActiveLovelyPet(lovelypetid);
end

--点击出战按钮
function UILovelyPetMainView:OnBtnFightClick()
	local lovelypetid = self:GetCurLovelyPetId();
	
	local state = LovelyPetUtil:GetLovelyPetState(lovelypetid);
	if state ~= LovelyPetConsts.type_rest then
		return;
	end
	if ActivityController:GetCurrId() == ActivityConsts.Lunch then
		 FloatManager:AddSkill("当前活动中不能与萌宠相伴")
		return;
	end
	
	LovelyPetController:ReqSendLovelyPet(lovelypetid, LovelyPetConsts.type_fight);
end

--点击休息按钮
function UILovelyPetMainView:OnBtnRestClick()
	local lovelypetid = self:GetCurLovelyPetId();
	local state = LovelyPetUtil:GetLovelyPetState(lovelypetid);
	if state ~= LovelyPetConsts.type_fight then
		return;
	end
	
	LovelyPetController:ReqSendLovelyPet(lovelypetid, LovelyPetConsts.type_rest);
end

--点击续费按钮
function UILovelyPetMainView:OnBtnRenewClick()
	local lovelypetid = self:GetCurLovelyPetId();
	local lovelypettime,servertime = LovelyPetUtil:GetLovelyPetTime(lovelypetid);
	if lovelypettime == -1 then
		FloatManager:AddNormal( StrConfig["lovelypet27"]);
		return;
	end
	UILovelyPetRenewView.lovelypetid = lovelypetid;
	if not UILovelyPetRenewView.bShowState then
		-- print('=====================UILovelyPetMainView 111')
		self:ShowChild(LovelyPetConsts.LOVELYPETRENEW);
	else
		-- print('=====================UILovelyPetMainView 222')
		UILovelyPetRenewView:Open();
	end
end

function UILovelyPetMainView:OnBtnToolRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local lovelypetid = self:GetCurLovelyPetId();
	local cfg = t_lovelypet[lovelypetid];
	if cfg then
		if cfg.gettype == 2 then
			local attrvo = split(cfg.getcondition,",");
			TipsManager:ShowItemTips(tonumber(attrvo[1]));
		end
	end
end

function UILovelyPetMainView:InitData()
	-- local list = {}
	-- local vo = {};
	-- vo.id = 1;
	-- vo.state = LovelyPetConsts.type_rest;
	-- vo.time = 3600;
	-- table.push(list,vo);
	-- LovelyPetModel:SetLovelyPetList(list);
	-- LovelyPetModel:SetLovelyPetListTime(GetServerTime());
end

function UILovelyPetMainView:InitCurData()
	self.lovelypetid = self:GetCurLovelyPetId();
	self.lovelypettime = 0;
	
	--非战斗状态不倒计时
	local id, state = LovelyPetUtil:GetCurLovelyPetState(self.lovelypetid);
	local lovelypettime,servertime = LovelyPetUtil:GetLovelyPetTime(self.lovelypetid);
	if lovelypettime <= 0 then
		self.lovelypettime = lovelypettime;
	else
		self.lovelypettime = lovelypettime - (GetServerTime()-servertime);
	end
end

function UILovelyPetMainView:InitUI()
	local objSwf = self.objSwf;
	if not objSwf then return; end
end


--处理消息
function UILovelyPetMainView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.LovelyPetStateUpdata then
		if body.index == 2 then
			self:InitCurData();
		end
		self:ShowLovelyPetList();
		self:ShowBtnState(body.id);
		self:ShowRemainTime(body.id);
	elseif name == NotifyConsts.LovelyPetTimeUpdata then
		self:InitCurData();
		self:ShowRestTime(body.id);
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaLevel then
			self:ShowBtnState();
		end
	elseif name == NotifyConsts.BagItemNumChange then
		self:ShowBtnState();
	end
end

--监听消息
function UILovelyPetMainView:ListNotificationInterests()
	return {NotifyConsts.LovelyPetStateUpdata,NotifyConsts.LovelyPetTimeUpdata,
			NotifyConsts.PlayerAttrChange,NotifyConsts.BagItemNumChange};
end

--显示信息
function UILovelyPetMainView:ShowLovelyPetInfo()
	self:ShowLovelyPetList();
	self:InitCurData();
	self:Show3DLovelyPet();
	self:ShowName();
	self:ShowFight();
	self:ShowLovelyPetAttr();
	self:ShowBtnState();
	self:ShowRemainTime();
	self:ShowSkillInfo();
end

function UILovelyPetMainView:GetCurLovelyPetId()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.tileListLovelyPet;
	if list.selectedIndex == -1 then list.selectedIndex = 0; end
	local curListUIData = list.dataProvider[list.selectedIndex];
	local LovelyPetData = curListUIData and UIData.decode(curListUIData);
	if not LovelyPetData then
		Debug("no selected lovelypet");
		return;
	end
	local curLovelyPetId = LovelyPetData and LovelyPetData.id;
	if curLovelyPetId then
		self.lovelypetid = curLovelyPetId;
	end
	return self.lovelypetid;
end

--显示萌宠list
function UILovelyPetMainView:ShowLovelyPetList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local list = objSwf.tileListLovelyPet;
	list.dataProvider:cleanUp();
	local lovelypetUIList = LovelyPetUtil:GetLovelyPetUIList();
	list.dataProvider:push( unpack(lovelypetUIList) );
	list:invalidateData();
end

-- 显示模型
local viewLovelyPetPort;
function UILovelyPetMainView:Show3DLovelyPet()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.actionTime = 0;
	local lovelypetid = self:GetCurLovelyPetId();
	
	local cfg = t_lovelypet[lovelypetid];
	if not cfg then
		Error("Cannot find config of t_lovelypet. id:"..lovelypetid);
		return;
	end
	
	local modelId = cfg.model;
	
	local modelCfg = t_petmodel[modelId];
	if not modelCfg then
		Error("Cannot find config of t_petmodel. id:"..modelId);
		return;
	end
	if not self.objUIDraw then
		if not viewLovelyPetPort then viewLovelyPetPort = _Vector2.new(1850, 900); end  --1500 900
		self.objUIDraw = UISceneDraw:new( "UILovelyPetMainView", objSwf.modelload, viewLovelyPetPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelload);
	self.objUIDraw:SetScene( cfg.ui_sen, function()
		local aniName = modelCfg.san_idle;
		if not aniName or aniName == "" then return end
		if not cfg.ui_node then return end
		local nodeName = split(cfg.ui_node, "#")
		if not nodeName or #nodeName < 1 then return end
			
		for k,v in pairs(nodeName) do
			self.objUIDraw:NodeAnimation( v, aniName );
		end
	end );
	self.objUIDraw:NodeVisible(cfg.ui_node,true);
	self.objUIDraw:SetDraw( true );
	local musicId = cfg.music
	if musicId and musicId > 0 then
		SoundManager:StopSfx()
		SoundManager:PlaySfx(musicId)
	end
end

--播放休闲动作
function UILovelyPetMainView:PlayerXiuXian()
	local lovelypetid = self:GetCurLovelyPetId();
	local cfg = t_lovelypet[lovelypetid];
	if not cfg then
		Error("Cannot find config of t_lovelypet. id:"..lovelypetid);
		return;
	end
	local modelId = cfg.model;
	local modelCfg = t_petmodel[modelId];
	if not modelCfg then
		Error("Cannot find config of t_petmodel. id:"..modelId);
		return;
	end
	local aniName = modelCfg.san_idle;
	if not aniName or aniName == "" then return end
	if not cfg.ui_node then return end
	local nodeName = split(cfg.ui_node, "#")
	if not nodeName or #nodeName < 1 then return end
	
	if self.objUIDraw then
		for k,v in pairs(nodeName) do
			self.objUIDraw:NodeAnimation( v, aniName );
		end
	end
end

--显示名称
function UILovelyPetMainView:ShowName()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local lovelypetid = self:GetCurLovelyPetId();
	
	local petcfg = t_lovelypet[lovelypetid];
	if not petcfg then
		return;
	end
	
	objSwf.nameloader.source = ResUtil:GetLovelyPetIcon(petcfg.nameicon);
	if petcfg.quality2 > 0 then
		objSwf.nameQualityloader.source = ResUtil:GetLovelyPetQualityName(petcfg.quality2);
	else
		objSwf.nameQualityloader:unload();
	end
end

--显示战斗力
function UILovelyPetMainView:ShowFight()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local lovelypetid = self:GetCurLovelyPetId();
	
	objSwf.fightLoader.num = LovelyPetUtil:GetLovelyPetFight(lovelypetid);
end

--显示技能
function UILovelyPetMainView:ShowSkillInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.tfskillname.text = "";
	objSwf.tfskillinfo.text = "";
	
	local lovelypetid = self:GetCurLovelyPetId();
	
	local petcfg = t_lovelypet[lovelypetid];
	if not petcfg then
		return;
	end
	objSwf.tfskillname.text = petcfg.skillname;
	objSwf.tfskillinfo.htmlText = petcfg.skillinfo;
end

--显示属性
function UILovelyPetMainView:ShowLovelyPetAttr()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local lovelypetid = self:GetCurLovelyPetId();
	
	for i=1,LovelyPetConsts.attrMaxNum do
		objSwf["labletype"..i].text = "";
		objSwf["tfval"..i].text = "";
	end
	
	local petcfg = t_lovelypet[lovelypetid];
	if not petcfg then
		return 0;
	end
	
	local attrList = split(petcfg.attr,"#");
	for i,attrStr in ipairs(attrList) do
		local attrvo = split(attrStr,",");
		local vo = {};
		vo.type = AttrParseUtil.AttMap[attrvo[1]];
		vo.val = tonumber(attrvo[2]);
		objSwf["labletype"..i].htmlText = PublicStyle:GetAttrNameStr(PublicAttrConfig.roleProName[attrvo[1]]);
		objSwf["tfval"..i].htmlText = vo.val;
		if vo.type == enAttrType.eaAdddamagebossx then
			objSwf["tfval"..i].htmlText = PublicStyle:GetAttrValStr(getAtrrShowVal(enAttrType.eaAdddamagebossx, vo.val));
		elseif vo.type == enAttrType.eaAdddamagemonx then
			objSwf["tfval"..i].htmlText = PublicStyle:GetAttrValStr(getAtrrShowVal(enAttrType.eaAdddamagemonx, vo.val));
		elseif vo.type == enAttrType.eaSuper then
			objSwf["tfval"..i].htmlText = PublicStyle:GetAttrValStr(getAtrrShowVal(enAttrType.eaSuper, vo.val));
		end
	end
end

--显示按钮状态
function UILovelyPetMainView:ShowBtnState(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local lovelypetid = self:GetCurLovelyPetId();
	
	if id and id ~= lovelypetid then
		return;
	end
	
	objSwf.btn_active.visible = false;
	objSwf.btn_fight.visible = false;
	objSwf.btn_rest.visible = false;
	objSwf.btn_renew.visible = false;
	objSwf.activeinfopanel._visible = false;
	
	local state = LovelyPetUtil:GetLovelyPetState(lovelypetid);

	-- WriteLog(LogType.Normal,true,'-------------宠物状态:',state)
	if state == LovelyPetConsts.type_notactive then     --未激活
		objSwf.btn_active.visible = true;
		objSwf.activeinfopanel._visible = true;
		self:UpdateActiveInfo(lovelypetid);
	elseif state == LovelyPetConsts.type_rest then      --休息
		objSwf.btn_fight.visible = true;
		if self.lovelypettime >= 0 then  
			objSwf.btn_renew.visible = true;
		end
	elseif state == LovelyPetConsts.type_fight then     --出战
		objSwf.btn_rest.visible = true;  
		if self.lovelypettime >= 0 then
			objSwf.btn_renew.visible = true;
		end
	elseif state == LovelyPetConsts.type_passtime then  --过期
		objSwf.btn_renew.visible = true;
	end
end

--显示激活条件
function UILovelyPetMainView:UpdateActiveInfo(lovelypetid)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.activeinfopanel.lvlpanel._visible = false;
	objSwf.activeinfopanel.toolpanel._visible = false;
	local cfg = t_lovelypet[lovelypetid];
	if cfg then
		if cfg.gettype == 1 then
			objSwf.activeinfopanel.lvlpanel._visible = true;
			local playerinfo = MainPlayerModel.humanDetailInfo;
			if playerinfo.eaLevel >= tonumber(cfg.getcondition) then
				objSwf.activeinfopanel.lvlpanel.tflvl.htmlText = string.format( StrConfig["lovelypet19"],cfg.getcondition );
			else
				objSwf.activeinfopanel.lvlpanel.tflvl.htmlText = string.format( StrConfig["lovelypet20"],cfg.getcondition );
			end
		elseif cfg.gettype == 2 then
			objSwf.activeinfopanel.toolpanel._visible = true
			local attrvo = split(cfg.getcondition,",");
			local itemNum = BagModel:GetItemNumInBag(tonumber(attrvo[1]));
			if itemNum >= tonumber(attrvo[2]) then
				objSwf.activeinfopanel.toolpanel.btnTool.htmlLabel = string.format( StrConfig["lovelypet14"],t_item[tonumber(attrvo[1])].name.."*"..attrvo[2]);
			else
				objSwf.activeinfopanel.toolpanel.btnTool.htmlLabel = string.format( StrConfig["lovelypet15"],t_item[tonumber(attrvo[1])].name.."*"..attrvo[2]);
			end
		end
	end
end

--显示剩余时间
function UILovelyPetMainView:ShowRemainTime(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local lovelypetid = self:GetCurLovelyPetId();
	
	if id and id ~= lovelypetid then
		return;
	end
	
	objSwf.tfdaojishi.text = "";
	objSwf.tfpasstime._visible = false;
	objSwf.tftimetitle._visible = true;
	local state = LovelyPetUtil:GetLovelyPetState(lovelypetid);
	if state == LovelyPetConsts.type_notactive then
		objSwf.tftimetitle._visible = false;
		return;
	elseif state == LovelyPetConsts.type_passtime then
		objSwf.tftimetitle._visible = false;
		objSwf.tfpasstime._visible = true;
		return;
	end
	local str = "";
	if self.lovelypettime <= -1 then
		str = StrConfig["lovelypet26"];
	else
		local day,t,s,m  = self:GetTime(self.lovelypettime);
		local daynum = toint(day);
		if daynum > 0 then
			if daynum >= 10 then
				str = string.format( StrConfig["lovelypet24"], day,t,s);
			else
				str = string.format( StrConfig["lovelypet6"], day,t,s,m);
			end
		else
			str = string.format( StrConfig["lovelypet3"], t,s,m);
		end
	end
	objSwf.tfdaojishi.text = str;
end

--当前休息状态刷新倒计时
function UILovelyPetMainView:ShowRestTime(id)
	local lovelypetid = self:GetCurLovelyPetId();
	
	if id and id ~= lovelypetid then
		return;
	end
	
	local state = LovelyPetUtil:GetLovelyPetState(lovelypetid);
	if state == LovelyPetConsts.type_rest then
		self:ShowRemainTime(lovelypetid);
	end
end

function UILovelyPetMainView:StartTimer()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.OnTimer,1000,0);
end

function UILovelyPetMainView:DelTimerKey()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

--计时器
function UILovelyPetMainView:OnTimer()
	--动作计时
	UILovelyPetMainView.actionTime = UILovelyPetMainView.actionTime + 1;
	if UILovelyPetMainView.actionTime >= UILovelyPetMainView.actionTimeMax then
		UILovelyPetMainView.actionTime = 0;
		UILovelyPetMainView:PlayerXiuXian();
	end
	--非战斗状态不倒计时
	local id, state = LovelyPetUtil:GetCurLovelyPetState(UILovelyPetMainView.lovelypetid);
	if state ~= LovelyPetConsts.type_fight and state ~= LovelyPetConsts.type_rest then
		return;
	end
	if UILovelyPetMainView.lovelypettime > -1 then
		UILovelyPetMainView.lovelypettime = UILovelyPetMainView.lovelypettime - 1;
		
		if UILovelyPetMainView.lovelypettime < 0 then
			UILovelyPetMainView.lovelypettime = 0;
		end
	end
	
	
	UILovelyPetMainView:ShowRemainTime();
end;

function UILovelyPetMainView:GetTime(time)
	if not time then return end;
	if time <= 0 then return "00","00","00","00" end;
	local ti = time / 60 -- 分
	local tim = (ti % 1)*60 + 0.1
	local m = toint(tim)
	if m < 10 then 
		m = "0"..m
	end;
	local s = toint(ti)
	local t = 0;
	local day = 0;
	if s >= 60 then 
		t = toint(s/60);
		s = s%60;
		if t > 24 then
			day = toint(t/24);
			t = toint(t%24);
		end
	end;

	if s < 10 then 
		s = "0"..s
	end;

	if t < 10 then 
		t = "0"..t;
	end;

	return day,t,s,m
end;