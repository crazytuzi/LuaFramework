require "Core.Module.Common.UIItem"

GuildTaskItem = UIItem:New();

function GuildTaskItem:_Init()
    local txts = UIUtil.GetComponentsInChildren(self.transform, "UILabel");
    self._txtTaskDesc = UIUtil.GetChildInComponents(txts, "txtTaskDesc");
    self._txtAward1 = UIUtil.GetChildInComponents(txts, "txtAward1");
    self._txtAward2 = UIUtil.GetChildInComponents(txts, "txtAward2");
    self._txtAward3 = UIUtil.GetChildInComponents(txts, "txtAward3");

    local btns = UIUtil.GetComponentsInChildren(self.transform, "UIButton");
    self._btnAcc = UIUtil.GetChildInComponents(btns, "btnAcc");
    self._btnComit = UIUtil.GetChildInComponents(btns, "btnComit");
    self._btnHelp = UIUtil.GetChildInComponents(btns, "btnHelp");
    self._btnComplete = UIUtil.GetChildInComponents(btns, "btnComplete");
    self._btnGoto = UIUtil.GetChildInComponents(btns, "btnGoto");

    self._imgTaskColor = UIUtil.GetChildByName(self.transform, "UISprite", "imgTaskColor");
    self._imgTaskIco = UIUtil.GetChildByName(self.transform, "UISprite", "imgTaskIco");
    self._icoTaskStatus = UIUtil.GetChildByName(self.transform, "UISprite", "icoTaskStatus");

    self._icoItem1 = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgAward1");
    self._icoItem2 = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgAward2");
    self._icoItem3 = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgAward3");

	self._onClickBtnAcc = function(go) self:_OnClickBtnAcc(self) end
    UIUtil.GetComponent(self._btnAcc, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAcc);   
    self._onClickBtnComit = function(go) self:_OnClickBtnComit(self) end
    UIUtil.GetComponent(self._btnComit, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnComit);
    self._onClickBtnGoto = function(go) self:_OnClickBtnGoto(self) end
    UIUtil.GetComponent(self._btnGoto, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGoto);
    self._onClickBtnHelp = function(go) self:_OnClickBtnHelp(self) end
    UIUtil.GetComponent(self._btnHelp, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnHelp);
    self._onClickBtnComplete = function(go) self:_OnClickBtnComplete(self) end
    UIUtil.GetComponent(self._btnComplete, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnComplete);

    self:UpdateItem(self.data);
end

function GuildTaskItem:_Dispose()
    UIUtil.GetComponent(self._btnAcc, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAcc = nil;
    UIUtil.GetComponent(self._btnComit, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnComit = nil;
    UIUtil.GetComponent(self._btnGoto, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnGoto = nil;
    UIUtil.GetComponent(self._btnHelp, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnHelp = nil;
    UIUtil.GetComponent(self._btnComplete, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnComplete = nil;

end

function GuildTaskItem:UpdateItem(data)
    self.data = data;
    
    if data then
    	local config = data:GetConfig();
        self._imgTaskColor.spriteName = "color"..config.quality;
        self._imgTaskIco.spriteName = config.rewardIcon;
        self._icoTaskStatus.gameObject:SetActive(data.status == TaskConst.Status.FINISH);

        self._txtTaskDesc.text = LanguageMgr.GetColor("d", TaskUtils.GetTaskDesc(data, config));
        
        self:UpdateAward(config.reward);
        self:UpdateBtns(data.status);
    else
    	self._imgTaskColor.spriteName = "";
    	self._imgTaskIco.spriteName = "";
    	self._icoTaskStatus.gameObject:SetActive(false);
    	self._txtTaskDesc.text = "";
    	self:UpdateAward();
        self:UpdateBtns(nil);
    end
end

function GuildTaskItem:UpdateAward(reward)
	for i = 1, 3 do
		if reward and reward[i] then
			local tmp = string.split(reward[i], "_");
	        local itemId = tonumber(tmp[1]);
	        local num = tmp[2];

	        local ico = self["_icoItem" .. i];
	        if itemId > 0 then
	            local cfg = ConfigManager.GetProductById(itemId);
	            ProductManager.SetIconSprite(ico, cfg["icon_id"]);
	            --                ico.mainTexture = UIUtil.GetTexture(EquipDataManager.GetItemTexturePath(cfg["icon_id"]));
	        else
	            ico.spriteName = ""
	        end

	        self["_txtAward" .. i].text = num;
		else
			self["_icoItem" .. i].spriteName = ""
			self["_txtAward" .. i].text = "";
		end
       
    end
end

function GuildTaskItem:UpdateBtns(showType)
    
	if showType == TaskConst.Status.UNACCEPTABLE then

        self._btnAcc.gameObject:SetActive(true);
        self._btnComit.gameObject:SetActive(false);
        self._btnGoto.gameObject:SetActive(false);
        self._btnComplete.gameObject:SetActive(false);
        self._btnHelp.gameObject:SetActive(false);

    elseif showType == TaskConst.Status.IMPLEMENTATION then

        self._btnAcc.gameObject:SetActive(false);
        self._btnComit.gameObject:SetActive(false);
        
        if self.data.tType == TaskConst.Target.COLLECT_ITEM then
            self._btnHelp.gameObject:SetActive(true);
            self._btnComplete.gameObject:SetActive(true);
        	self._btnGoto.gameObject:SetActive(false); 
        else
        	self._btnHelp.gameObject:SetActive(false);
            self._btnComplete.gameObject:SetActive(false);
        	self._btnGoto.gameObject:SetActive(true);
        end

    elseif showType == TaskConst.Status.FINISH then

        self._btnAcc.gameObject:SetActive(false);
        self._btnComit.gameObject:SetActive(true);
        self._btnGoto.gameObject:SetActive(false);
        self._btnComplete.gameObject:SetActive(false);
        self._btnHelp.gameObject:SetActive(false);

    else

    	self._btnAcc.gameObject:SetActive(false);
        self._btnComit.gameObject:SetActive(false);
        self._btnGoto.gameObject:SetActive(false);
        self._btnComplete.gameObject:SetActive(false);
        self._btnHelp.gameObject:SetActive(false);

    end
end

function GuildTaskItem:_OnClickBtnAcc()
	TaskProxy.ReqTaskAccess(self.data.id);
end
function GuildTaskItem:_OnClickBtnComit()
	TaskProxy.ReqTaskFinish(self.data.id);
end
function GuildTaskItem:_OnClickBtnGoto()
	if self.data then
        TaskManager.Auto(self.data.id);
    else
        log("GuildTaskItem.data is nil")
    end
    
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILD_OTHER_PANEL, GuildNotes.OTHER.TASK);
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDPANEL);
    ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
end

function GuildTaskItem:_OnClickBtnHelp()
	--TaskProxy.ReqTaskNeedHelp(self.data.id);
    MsgUtils.UseBDGoldConfirm(10, self, "task/payComplete", nil, GuildTaskItem.ConfirmPay, nil, nil, "common/ok");
end

function GuildTaskItem:ConfirmPay()
    TaskProxy.ReqTaskComplete(self.data.id);
end

function GuildTaskItem:_OnClickBtnComplete()
	TaskProxy.ReqTaskDoCollectItem(self.data.id);
end
