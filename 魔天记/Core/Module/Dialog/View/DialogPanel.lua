require "Core.Module.Common.Panel";
require "Core.Module.Common.PropsItem";
require "Core.Module.Common.UIHeroAnimationModel";
require "Core.Info.NpcInfo";
require "Core.Role.ModelCreater.NpcModelCreater";
require "Core.Role.ModelCreater.RoleModelCreater";

DialogPanel = Panel:New();

function DialogPanel:_Init()
	self._luaBehaviour.canPool = true
	self:_InitReference();
	self:_InitListener();
	self._roleId = - 1;
	self._modelCache = {};
end

function DialogPanel:_GetDefaultDepth()
	return 1
end

function DialogPanel:GetUIOpenSoundName()
	return ""
end

function DialogPanel:_InitReference()
	self._icoRoleFrame3 = UIUtil.GetChildByName(self._trsContent, "UITexture", "bg/frame3");
	self._icoRoleFrame4 = UIUtil.GetChildByName(self._trsContent, "UITexture", "bg/frame4");
	
	self._trsShow = UIUtil.GetChildByName(self._trsContent, "Transform", "trsShow");
	self._txtDialog = UIUtil.GetChildByName(self._trsShow, "UILabel", "txtDialog");
	self._txtName = UIUtil.GetChildByName(self._trsShow, "UILabel", "txtName");
	self._trsClickTip = UIUtil.GetChildByName(self._trsShow, "Transform", "trsClickTip");
	
	self._trsImgRole = UIUtil.GetChildByName(self._trsContent, "Transform", "imgRole");
	
	self._trsRoleParent = UIUtil.GetChildByName(self._trsImgRole, "Transform", "heroCamera/trsRoleParent");
	self._trsProduct = UIUtil.GetChildByName(self._trsContent, "Transform", "trsProduct");
	self._trsNpcBtns = UIUtil.GetChildByName(self._trsContent, "Transform", "trsNpcBtns");
	self._bgMask = UIUtil.GetChildByName(self._trsContent, "Transform", "bgMask");
	self._bgup = UIUtil.GetChildByName(self._trsContent, "Transform", "bgUp");
	self._btnSkip = UIUtil.GetChildByName(self._bgup, "Transform", "btnSkip");
	self._bgup = self._bgup.gameObject
	self._bgup:SetActive(false)
	
	self._btn_close = UIUtil.GetChildByName(self._trsNpcBtns, "UIButton", "btn_close");
	self._btnFunc = UIUtil.GetChildByName(self._trsNpcBtns, "UIButton", "btnFunc");
	self._btnFuncLabel = UIUtil.GetChildByName(self._btnFunc, "UILabel", "btnFunLabel");
	
	self._btnTaskComit = UIUtil.GetChildByName(self._trsProduct, "UIButton", "btnTaskComit");
	self._btnTaskExpComit = UIUtil.GetChildByName(self._trsProduct, "UIButton", "btnTaskExpComit");
	self._awardPhalanxInfo = UIUtil.GetChildByName(self._trsProduct, "LuaAsynPhalanx", "product_phalanx", true);
	self._awardPhalanx = Phalanx:New();
	self._awardPhalanx:Init(self._awardPhalanxInfo, PropsItem);
	
	UpdateBeat:Add(self.OnUpdate, self);
end

function DialogPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	self._onClickBtn_func = function(go) self:_OnClickBtn_func(self) end
	UIUtil.GetComponent(self._btnFunc, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_func);
	self._onClickBtn_comit = function(go) self:_OnClickBtn_comit(self) end
	UIUtil.GetComponent(self._btnTaskComit, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_comit);
	self._onClickBtnExpComit = function(go) self:_OnClickBtnExpComit(self) end
	UIUtil.GetComponent(self._btnTaskExpComit, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnExpComit);
	
	self._onClickBg = function(go) self:_OnClickBg(self) end
	UIUtil.GetComponent(self._bgMask, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBg);
	self._onClickSkip = function(go) self:_OnClickSkip(self) end
	UIUtil.GetComponent(self._btnSkip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickSkip);
	
	MessageManager.AddListener(TaskManager, TaskNotes.TASK_END, DialogPanel._OnTaskEnd, self);
end

function DialogPanel:GetData()
	return self._data;
end

function DialogPanel:Update(dialogData)
	self._autoTime = 0;
	self._data = dialogData;
	self._txtDialog.text = dialogData.dialog;
	self._trsClickTip.gameObject:SetActive(dialogData.type == DialogDataType.DIALOG or dialogData.type == DialogDataType.DRAMA);
	-- NPC对话按钮
	if(dialogData.type == DialogDataType.NPC) then
		self._trsNpcBtns.gameObject:SetActive(true);
		if(dialogData.showfunc) then
			-- self._btnFunc.isEnabled = true;
			self._btnFunc.gameObject:SetActive(true);
			self._btnFuncLabel.text = dialogData.funcLabel;
			self._func = dialogData.func;
		else
			-- self._btnFunc.isEnabled = false;
			self._btnFunc.gameObject:SetActive(false);
		end
	else
		self._trsNpcBtns.gameObject:SetActive(false);
	end
	-- 任务奖励
	if(dialogData.type == DialogDataType.TASK) then
		self._trsProduct.gameObject:SetActive(true);
		local count = table.getn(dialogData.awards);
		self._awardPhalanx:Build(1, count, dialogData.awards);
		
		self._btnTaskExpComit.gameObject:SetActive(dialogData.param == true);
	else
		self._trsProduct.gameObject:SetActive(false);
	end
	-- 名字
	local imgPos = self._trsImgRole.localPosition;
	local tipsPos = self._trsClickTip.transform.localPosition;
	local roleId = dialogData.roleId;
	-- Warning(tostring(roleId) .. "____" ..tostring(roleId ~= 0))
	if(roleId ~= 0) then
		local npcCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_NPC) [roleId];
		self._txtName.text = npcCfg.name;
		self._icoRoleFrame3.gameObject:SetActive(true);
		self._icoRoleFrame4.gameObject:SetActive(false);
		imgPos = Vector3.New(- 450, imgPos.y, imgPos.z);
		tipsPos = Vector3.New(20, tipsPos.y, tipsPos.z);
	else
		local info = HeroController.GetInstance().info;
		self._txtName.text = info and info.name or "";
		self._icoRoleFrame3.gameObject:SetActive(false);
		self._icoRoleFrame4.gameObject:SetActive(true);
		imgPos = Vector3.New(450, imgPos.y, imgPos.z);
		tipsPos = Vector3.New(- 332, tipsPos.y, tipsPos.z);
	end
	Util.SetLocalPos(self._trsImgRole, imgPos.x, imgPos.y, imgPos.z)
	Util.SetLocalPos(self._trsClickTip, tipsPos.x, tipsPos.y, tipsPos.z)
	
	-- 更新形象.
	if(self._roleId ~= roleId) then
		for k, v in pairs(self._modelCache) do
			v:SetActive(k == roleId);
		end
		
		if(self._modelCache[roleId] == nil) then
			local _roleCreater = nil;
			if(roleId ~= 0) then
				_roleCreater = NpcModelCreater:New(self:_GetNpcData(roleId), self._trsRoleParent, true, function(ctor)
					self:_onLoadedRole(ctor, roleId);
				end);
			else
				local myInfo = self:_GetPlayerData();
				_roleCreater = UIRoleModelCreater:New(myInfo, self._trsRoleParent, false, true, function(ctor)
					self:_onLoadedRole(ctor, myInfo.kind);
				end);
			end
			
			self._modelCache[roleId] = _roleCreater;
		end
		self._roleId = roleId;
	end
	
	self:_StartSpeak()
	-- 开始说话
	if self._data.ShowSkipBtn then self:ShowSkipBtn() end
end

function DialogPanel:_StartSpeak()
	self._speak = self._data.speakSpeed and self._data.speakSpeed > 0
	if self._speak then
		self.speekCount = 1
		self.dialogLen = string.len(self._data.dialog)
		self:_OnSpeak()
		self.speakTimer = Timer.New(function() self:_OnSpeak() end, self._data.speakSpeed, - 1, false):Start()
	end
end
function DialogPanel:_OnSpeak()
	-- Warning(self.speekCount .."-" .. self.dialogLen .. "___" .. os.clock())
	self._txtDialog.text = string.sub(self._data.dialog, 1, self.speekCount)
	self.speekCount = self.speekCount + 1
	self._speak = self.dialogLen > self.speekCount
	if not self._speak then
		if self.speakTimer then
			self.speakTimer:Stop()
			self.speakTimer = nil
		end
		if self._data.closeDelay and self._data.closeDelay > 0 then
			self.delayTimer = Timer.New(function() self:_OnDelayed() end, self._data.closeDelay, 1, false):Start()
		end
	end
end
function DialogPanel:_OnDelayed()
	self.delayTimer = nil
	self:_OnClickBtn_close()
end
function DialogPanel:_ClearTime()
	if self.delayTimer then
		self.delayTimer:Stop()
		self.delayTimer = nil
	end
	if self.speakTimer then
		self.speakTimer:Stop()
		self.speakTimer = nil
	end
end


function DialogPanel:_onLoadedRole(ctor, modelId)
	local role = ctor:GetRole();
	ctor:SetLayer(Layer.UIModel);
	DialogPanel.AdjustPosAndSize(role, modelId);
end

-- 构建展示的NPC数据
function DialogPanel:_GetNpcData(npcId)
	local data = NpcInfo:New(npcId);
	data.position = Vector3.New(0, 0, 0);
	return data;
end

-- 构建展示的玩家数据.
function DialogPanel:_GetPlayerData()
	
	local player = PlayerManager.GetPlayerInfo();
	local data = RoleModelCreater.CloneDress(player, false, false, false);
	-- data.kind = player.kind;
	-- data.dress = RoleModelCreater.CloneDress(player, false, false, false)
	return data;
end

function DialogPanel.AdjustPosAndSize(role, npcId)
	local npcCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_NPC) [npcId];
	if(npcCfg ~= nil) then
		Util.SetLocalPos(role.transform, 0, 0, 0)
		
		--        role.transform.localPosition = Vector3.New(0, 0, 0);
		role.transform.localScale = Vector3.New(npcCfg.portrait_rate, npcCfg.portrait_rate, npcCfg.portrait_rate);
	end
end

function DialogPanel:_OnTaskEnd(id)
	if(self._data and self._data.taskId == id) then
		self:_OnClickBtn_close();
	end
end

function DialogPanel:_OnClickBtn_close()
	if not self._data.speakSkip then return end
	if self._speak then
		self.speekCount = self.dialogLen
		self:_OnSpeak()
		return false
	end
	ModuleManager.SendNotification(DialogNotes.CLOSE_DIALOGPANEL);
	return true
end

function DialogPanel:_OnClickBtn_func()
	self:_OnNav();
	ModuleManager.SendNotification(DialogNotes.CLOSE_DIALOGPANEL);
end

function DialogPanel:_OnClickBtn_comit()
	if(self._data.taskId > 0) then
		TaskProxy.ReqTaskFinish(self._data.taskId);
	end
end

function DialogPanel:_OnClickBtnExpComit()
	if(self._data.taskId > 0) then
		TaskProxy.ReqTaskFinish(self._data.taskId, 1);
	end
end

function DialogPanel:_OnClickBg()
	if(self._data.type == DialogDataType.DIALOG or self._data.type == DialogDataType.DRAMA) then
		self:_OnClickBtn_close();
	end
end

function DialogPanel:_OnClickSkip()
	ModuleManager.SendNotification(DialogNotes.CLOSE_DIALOGPANEL)
	DramaDirector.Skip(true)
end
function DialogPanel:ShowSkipBtn()
	self._bgup:SetActive(true)
end

function DialogPanel:_OnNav()
	if self._func then
		if string.sub(self._func, 1, 3) == "Nav" then
			local args = string.split(self._func, "_");
			local instanceId = tonumber(args[2]);
			GameSceneManager.GoToFB(instanceId, self._data.npcId);
		else
			ModuleManager.SendNotification(self._func);
		end
	else
		error("配置有问题. NPC功能配置错误 -> " .. self._data.npcId);
	end
end

function DialogPanel:OnUpdate()
	if(self._data and self._data.type == DialogDataType.DIALOG) then
		if TaskManager.IsAuto() then
			if self._autoTime > 7 then
				self._autoTime = 0;
				self:_OnClickBtn_close();
				return;
			end
			self._autoTime = self._autoTime + Timer.deltaTime;
		end
	end
end

function DialogPanel:_Dispose()
	self._roleId = - 1;
	
	for k, v in pairs(self._modelCache) do
		v:Dispose();
		v = nil;
	end
	NGUITools.DestroyChildren(self._trsRoleParent);
	
	self:_DisposeListener();
	self:_DisposeReference();
end

function DialogPanel:_DisposeListener()
	MessageManager.RemoveListener(TaskManager, TaskNotes.TASK_END, DialogPanel._OnTaskEnd);
	
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._btnFunc, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._btnTaskComit, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._btnTaskExpComit, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._bgMask, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._btnSkip, "LuaUIEventListener"):RemoveDelegate("OnClick");
	
	self:_ClearTime()
	
	UpdateBeat:Remove(self.OnUpdate, self);
end

function DialogPanel:_DisposeReference()
	self._onClickBtn_close = nil;
	self._onClickBtn_func = nil;
	self._onClickBtn_comit = nil;
	self._onClickBtnExpComit = nil;
	self._onClickBg = nil;
	self._onClickSkip = nil
	
	self._btn_close = nil;
	self._btnFunc = nil;
	self._btnTaskComit = nil;
	self._btnTaskExpComit = nil;
	self._config = nil;
	
	self._awardPhalanx:Dispose();
	self._awardPhalanx = nil;
end
