require "Core.Module.Common.Panel";
require "Core.Info.NpcInfo";
require "Core.Role.ModelCreater.UIRoleModelCreater";

DialogQAPanel = Panel:New();

function DialogQAPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function DialogQAPanel:_InitReference()

	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

	self._trsInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInfo");
    self._txtDialog = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtDialog");
    self._txtName = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtName");
    self._txtTitle = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtTitle");
    self._txtQuestion = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtQuestion");
    
    self._ansItems = {};
    self.txtAnswers = {};
    self.ansIcoA = {};
    self.ansIcoB = {};
    for i = 1, 4 do 
    	local item = UIUtil.GetChildByName(self._trsInfo, "Transform", "trsAnswer" .. i);
    	local answer = UIUtil.GetChildByName(item, "UILabel", "txtAnswer");
    	local icoA = UIUtil.GetChildByName(item, "UISprite", "ico1");
    	local icoB = UIUtil.GetChildByName(item, "UISprite", "ico2");
    	icoA.gameObject:SetActive(false);
    	icoB.gameObject:SetActive(false);
    	self._ansItems[i] = item; 
    	self.txtAnswers[i] = answer;
    	self.ansIcoA[i] = icoA;
    	self.ansIcoB[i] = icoB;
    end

    self._trsImgRole = UIUtil.GetChildByName(self._trsContent, "Transform", "imgRole");
	self._trsRoleParent = UIUtil.GetChildByName(self._trsImgRole, "Transform", "heroCamera/trsRoleParent");

    self._imgCorrect = UIUtil.GetChildByName(self._trsContent, "UITexture", "imgCorrect");
    self._imgWrong = UIUtil.GetChildByName(self._trsContent, "UITexture", "imgWrong");
    self._imgCorrect.gameObject:SetActive(false);
    self._imgWrong.gameObject:SetActive(false);
	
	self._end = 0;
	self._showTime = 0;
end

function DialogQAPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);

    self._onClickItem = function(go) self:_OnClickItem(go) end;
    for i, v in ipairs(self._ansItems) do
		UIUtil.GetComponent(v, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
    end

    UpdateBeat:Add(self.OnUpdate, self)
    
end

function DialogQAPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function DialogQAPanel:_DisposeReference()
	
end

function DialogQAPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;

    for i, v in ipairs(self._ansItems) do
		UIUtil.GetComponent(v, "LuaUIEventListener"):RemoveDelegate("OnClick");
    end
    self._onClickItem = nil;

    UpdateBeat:Remove(self.OnUpdate, self)
end

function DialogQAPanel:_OnClickBtn_close()
	--TaskManager.StopAuto();
    self:_OnClose();
end

function DialogQAPanel:_OnNext()
	ModuleManager.SendNotification(DialogNotes.CLOSE_DIALOGPANEL);
end

function DialogQAPanel:_OnClose()
	ModuleManager.SendNotification(DialogNotes.CLOSE_ALL_DIALOGPANEL);
end

function DialogQAPanel:OnUpdate()
	if self._end > 0 then
		self._showTime = self._showTime - Timer.deltaTime;
		if self._showTime <= 0 then

			self._imgCorrect.gameObject:SetActive(false);
			self._imgWrong.gameObject:SetActive(false);

			--答题完毕
			if self._end == 2 then
				self:OnEnd();
			end
			self._end = 0;
		end
	end
	
end

function DialogQAPanel:OnEnd()
	if self.data.idx < self.data.num then
		self:_OnNext();
	else
		TaskProxy.ReqTaskTrigger(self.data.taskId);
		self:_OnClose();
	end
end


function DialogQAPanel:Update(data)
	--self._uiAnimationModel = UIAnimationModel:New(modelData, self._trsRoleParent, UIRoleModelCreater);
	self.data = data;
	local cfg = TaskManager.GetQuestionCfgById(data.qId);
	local npcId = cfg.npd_id;
	local npcCfg = ConfigManager.GetNpcById(cfg.npd_id);
	self._txtName.text = npcCfg and npcCfg.name or "";
	self._txtQuestion.text = cfg.question;
	self._txtTitle.text = LanguageMgr.Get("task/answer/title", data)

	for i, v in ipairs(self.txtAnswers) do
		v.text = cfg["answer"..i];
		self.ansIcoA[i].gameObject:SetActive(false);
		self.ansIcoB[i].gameObject:SetActive(false);
	end

	if self.showNpcId ~= npcId then
		local npcData = NpcInfo:New(npcId);
	    npcData.position = Vector3.New(0,0,0);

		if self._uiAnimationModel == nil then
			self._uiAnimationModel = UIAnimationModel:New(npcData, self._trsRoleParent, NpcModelCreater);
		else
			self._uiAnimationModel:ChangeModel(npcData, self._trsRoleParent)
		end
		self.showNpcId = npcId;
	end
	
	self._values = {false, false, false, false};
	self._end = 0;
	self._cfg = cfg;
end

function DialogQAPanel:_onLoadedRole(ctor, modelId)
    local role = ctor:GetRole();
    ctor:SetLayer(Layer.UIModel);
    DialogPanel.AdjustPosAndSize(role, modelId);
end

function DialogQAPanel:_OnClickItem(go)
	local idx = tonumber(string.sub(go.name, 10));
	if self._values[idx] == false and self._end < 2 then
		self:DoSelect(idx);
	end
end

function DialogQAPanel:DoSelect(idx)
	if self._cfg.right == idx then
		self.ansIcoA[idx].gameObject:SetActive(true);
		self:OnRight();
	else
		self.ansIcoB[idx].gameObject:SetActive(true);
		self:OnWrong();
	end

	self._values[idx] = true;
end

function DialogQAPanel:OnRight()
	self._end = 2;
	self._imgCorrect.gameObject:SetActive(true);
	self._imgWrong.gameObject:SetActive(false);
	self._showTime = 1;
end

function DialogQAPanel:OnWrong()
	self._end = math.max(1, self._end);
	self._imgCorrect.gameObject:SetActive(false);
	self._imgWrong.gameObject:SetActive(true);
	self._showTime = 1;
end

