--[[主面板
zhangshuhui
2015年1月22日16:57:20
]]

_G.UIFashionsMainView = BaseSlotPanel:new("UIFashionsMainView")

--经过的时间
UIFashionsMainView.timelast = 0; 
--终点时间
UIFashionsMainView.remaintime = 0;
--剩余时间定时器key
UIFashionsMainView.lastTimerKey = nil;
--预览的时装组id
UIFashionsMainView.previewgroupid = 0;

UIFashionsMainView.tabButton = {};

UIFashionsMainView.objAvatar = nil;--人物模型
UIFashionsMainView.roleTurnDir = 0;--人物旋转方向 0,不旋转;1左;-1右
UIFashionsMainView.meshDir = 0; --模型的当前方向

function UIFashionsMainView:Create()
	self:AddSWF("fashionsMainPanel.swf", true, "center")
	
	self:AddChild(UIFashionsForeverView, FashionsConsts.TABFOREVER);
	self:AddChild(UIFashionsLimitView, FashionsConsts.TABLIMIT);
end

function UIFashionsMainView:OnLoaded(objSwf,name)
	self:GetChild(FashionsConsts.TABFOREVER):SetContainer(objSwf.childPanel);
	self:GetChild(FashionsConsts.TABLIMIT):SetContainer(objSwf.childPanel);
	objSwf.btnRoleLeft.stateChange = function(e) self:OnBtnRoleLeftStateChange(e.state); end;
	objSwf.btnRoleRight.stateChange = function(e) self:OnBtnRoleRightStateChange(e.state); end;
	
	--关闭
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	
	objSwf.btncurfashions.click = function() self:OnBtnCurFashionsClick(); end;
	
	self.tabButton[FashionsConsts.TABFOREVER] = objSwf.btnForever;
	self.tabButton[FashionsConsts.TABLIMIT] = objSwf.btnLimit;
	for name,btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(name); end;
	end
	
	--初始化格子
	for i=1,FashionsConsts.totalSize do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end
	
	objSwf.BG.hitTestDisable = true;
	--模型防止阻挡鼠标
	objSwf.roleLoader.hitTestDisable = true;

	objSwf.btnRule.rollOver = function(e) self:OnBtnRuleOver() end;
	objSwf.btnRule.rollOut = function(e) TipsManager:Hide() end;
end

function UIFashionsMainView:OnDelete()
	self:RemoveAllSlotItem();
	if self.scene then 
		self.scene:SetUILoader(nil)
	end
end

function UIFashionsMainView:IsShowLoading()
	return true;
end

function UIFashionsMainView:IsTween()
	return true;
end

function UIFashionsMainView:GetPanelType()
	return 1;
end

function UIFashionsMainView:IsShowSound()
	return true;
end

function UIFashionsMainView:GetWidth()
	return 1146;
end

function UIFashionsMainView:GetHeight()
	return 687;
end

function UIFashionsMainView:BeforeTween()
	local func = FuncManager:GetFunc(FuncConsts.Role);
	if not func then return; end
	self.tweenStartPos = func:GetBtnGlobalPos();
end

function UIFashionsMainView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.FashionsDressInfo then
		self:DoUpdateItem(body);
		self:ShowAttr();
		self:DrawRole();
		self:InitData();
	elseif name == NotifyConsts.FashionsDressAdd then
		self:ShowAttr();
	elseif name == NotifyConsts.PlayerModelChange then
		self:DrawRole();
	end
end

function UIFashionsMainView:ListNotificationInterests()
	return {NotifyConsts.FashionsDressInfo, NotifyConsts.FashionsDressAdd,
			NotifyConsts.PlayerModelChange};
end

function UIFashionsMainView:InitData()
	self.previewgroupid = 0;
end

function UIFashionsMainView:OnShow(name)
	self:InitData();
	self:DrawScene();
	self:ShowCurFashions();
	self:ShowAttr();
	self:OnTabButtonClick(FashionsConsts.TABFOREVER);
end

function UIFashionsMainView:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	if self.scene then 
		self.scene:SetDraw(false)
	end
	
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self.roleTurnDir = 0;
end

--点击关闭按钮
function UIFashionsMainView:OnBtnCloseClick()
	self:Hide();
end

function UIFashionsMainView:OnBtnCurFashionsClick()
	if self.previewgroupid == 0 then
		return;
	end
	
	self.previewgroupid = 0;
	
	self:DrawRole();
end
--显示当前时装
function UIFashionsMainView:ShowCurFashions()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local datalist = FashionsUtil:GetCurFashionsList();
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(datalist));
	objSwf.list:invalidateData();
end

function UIFashionsMainView:OnTabButtonClick(name)
	if not self.tabButton[name] then
		return;
	end
	local child = self:GetChild(name);
	if not child then
		return;
	end
	self.tabButton[name].selected = true;
	self:ShowChild(name);
end

function UIFashionsMainView:ShowAttr()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.tfgongji.text = "0";
	objSwf.tffangyu.text = "0";
	objSwf.tfhp.text = "0";
	objSwf.tfbaoji.text = "0";
	objSwf.tfshanbi.text = "0";
	objSwf.tfmingzhong.text = "0";
	
	local list = FashionsUtil:GetFashionsAttrList()
	
	objSwf.fight.numFight.num = EquipUtil:GetFight(list);
	
	for i,vo in ipairs(list) do
		if vo.type == enAttrType.eaGongJi then
			objSwf.tfgongji.text = vo.val
		elseif vo.type == enAttrType.eaFangYu then
			objSwf.tffangyu.text = vo.val
		elseif vo.type == enAttrType.eaMaxHp then
			objSwf.tfhp.text = vo.val
		elseif vo.type == enAttrType.eaBaoJi then
			objSwf.tfbaoji.text = vo.val
		elseif vo.type == enAttrType.eaShanBi then
			objSwf.tfshanbi.text = vo.val
		elseif vo.type == enAttrType.eaMingZhong then
			objSwf.tfmingzhong.text = vo.val
		end
	end
end



function UIFashionsMainView:DoUpdateItem(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local uiDataStr = objSwf.list.dataProvider[body.pos - 1];
	if not uiDataStr then return; end
	
	objSwf.list.dataProvider[body.pos - 1] = FashionsUtil:GetRoleUIData(body.tid, body.pos)
	local uiSlot = objSwf.list:getRendererAt(body.pos - 1);
	if uiSlot then
		uiSlot:setData(FashionsUtil:GetRoleUIData(body.tid, body.pos));
	end
end

function UIFashionsMainView:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	
	local cfg = t_fashions[data.tid];
	if not cfg then return; end
	cfg.lastTime = FashionsUtil:GetFashionsTime(data.tid);
	TipsManager:ShowTips(TipsConsts.Type_Fanshion,{cfg=cfg},TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end

function UIFashionsMainView:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIFashionsMainView:OnItemDragBegin(item)

end

function UIFashionsMainView:OnItemDragin(item)

end

function UIFashionsMainView:OnItemClick(item)

end

function UIFashionsMainView:OnItemDoubleClick(item)
	local data = item:GetData();
	if not data then
		return;
	end
	if not data.hasItem  then
		return;
	end
	if not data.lightState then
		return;
	end
	
	FashionsController:ReqDressFashion(data.tid, 0);
end

function UIFashionsMainView:OnItemRClick(item)
	local data = item:GetData();
	
	if not data then
		return;
	end
	if not data.hasItem  then
		return;
	end
	if not data.lightState then
		return;
	end
	
	FashionsController:ReqDressFashion(data.tid, 0);
end


---------------------------------以下是绘制模型的------------------------------------------
-- 创建配置文件
UIFashionsMainView.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
									VPort = _Vector2.new(640,690),
									Rotation = 0,
								  };
function UIFashionsMainView : GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = self.defaultCfg.Rotation;
	return cfg;
end

--预览时装
function UIFashionsMainView:PreviewFashions(groupid)
	if self.previewgroupid == groupid then
		return;
	end
	
	self.previewgroupid = groupid;
	local uiLoader = self.objSwf.roleLoader;
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --玩家职业
	
	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf
	vo.arms = info.dwArms
	vo.dress = info.dwDress
	
	for i,cfg in pairs(t_fashions) do
		if cfg then
			if cfg.suit == groupid then
				--武器
				if cfg.pos == 1 then
					vo.fashionsArms = cfg.id;
				--衣服
				elseif cfg.pos == 2 then
					vo.fashionsDress = cfg.id;
				--头
				elseif cfg.pos == 3 then
					vo.fashionsHead = cfg.id;
				end
			end
		end
	end
	
	vo.wuhunId = SpiritsModel:GetFushenWuhunId()
	vo.wing = info.dwWing;
	self:DrawRole(vo);
end

--模型旋转
function UIFashionsMainView:OnBtnRoleLeftStateChange(state)
	if state == "down" then
		self.roleTurnDir = 1;
	elseif state == "release" then
		self.roleTurnDir = 0;
	elseif state == "out" then
		self.roleTurnDir = 0;
	end
end
function UIFashionsMainView:OnBtnRoleRightStateChange(state)
	if state == "down" then
		self.roleTurnDir = -1;
	elseif state == "release" then
		self.roleTurnDir = 0;
	elseif state == "out" then
		self.roleTurnDir = 0;
	end
end

function UIFashionsMainView:Update()
	if not self.bShowState then return; end
	if self.roleTurnDir == 0 then
		return;
	end
	if not self.objAvatar then
		return;
	end
	self.meshDir = self.meshDir + math.pi/40*self.roleTurnDir;
	if self.meshDir < 0 then
		self.meshDir = self.meshDir + math.pi*2;
	end
	if self.meshDir > math.pi*2 then
		self.meshDir = self.meshDir - math.pi*2;
	end
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
end

function UIFashionsMainView:DrawScene()
	local objSwf = self.objSwf
	if not objSwf then return end

	local prof = MainPlayerModel.humanDetailInfo.eaProf; 
	if prof == 4 then
		if not self.viewPort then self.viewPort = _Vector2.new(1400, 795); end  --795
	else
		if not self.viewPort then self.viewPort = _Vector2.new(1300, 815); end  --795
	end
	if not self.scene then
		self.scene = UISceneDraw:new("UIFashionsMainView", objSwf.roleLoader, self.viewPort, false);
	end
	self.scene:SetUILoader(objSwf.roleLoader)
	
	local src = Assets:GetRolePanelSen(MainPlayerModel.humanDetailInfo.eaProf);
	self.scene:SetScene(src, function()
		self:DrawRole();
	end );
	self.scene:SetDraw( true );
end

function UIFashionsMainView:DrawRole(vo)
	if not self.scene then return; end
	vo = vo or {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf;
	vo.arms = info.dwArms;
	vo.dress = info.dwDress;
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = vo.fashionsHead or info.dwFashionsHead;
	vo.fashionsArms = vo.fashionsArms or info.dwFashionsArms;
	vo.fashionsDress = vo.fashionsDress or info.dwFashionsDress;
	vo.wuhunId = SpiritsModel:GetFushenWuhunId();
	vo.wing = info.dwWing;
	vo.suitflag = info.suitflag;
	vo.shenwuId = info.shenwuId;
	
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar.bIsAttack = false;
	self.objAvatar:CreateByVO(vo);
	
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	
	local markers = self.scene:GetMarkers();
	local indexc = "marker2";
	self.objAvatar:EnterUIScene(self.scene.objScene,markers[indexc].pos,markers[indexc].dir,markers[indexc].scale, enEntType.eEntType_Player);
		--播放特效
	local sex = MainPlayerModel.humanDetailInfo.eaSex;
	local pfxName = "ui_role_sex" ..sex.. ".pfx";
	local name,pfx = self.scene:PlayPfx(pfxName);
end

function UIFashionsMainView:OnBtnRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	TipsManager:ShowBtnTips(StrConfig["fashions6"],TipsConsts.Dir_RightDown);
end