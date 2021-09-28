require "Core.Module.Common.UIItem"

GuildHelpListItem = UIItem:New();

function GuildHelpListItem:_Init()

	self._trsItem = UIUtil.GetChildByName(self.transform, "Transform", "trsItem");
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
	self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "txtNum");
    self._icoPlayer = UIUtil.GetChildByName(self.transform, "UISprite", "icoPlayer");
    self._txtPlayer = UIUtil.GetChildByName(self.transform, "UILabel", "txtPlayer");
    self._icoAward = UIUtil.GetChildByName(self.transform, "UISprite", "icoAward");
    self._txtAward = UIUtil.GetChildByName(self.transform, "UILabel", "txtAward");
    self._btnComit = UIUtil.GetChildByName(self.transform, "UIButton", "btnComit");
    self._btnGold = UIUtil.GetChildByName(self.transform, "UIButton", "btnGold");

    self._onClickBtnComit = function(go) self:_OnClickBtnComit(self) end
    UIUtil.GetComponent(self._btnComit, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnComit);

    self._onClickBtnGold = function(go) self:_OnClickBtnGold(self) end
    UIUtil.GetComponent(self._btnGold, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGold);

    self.item = PropsItem:New();
	self.itemGo = UIUtil.GetUIGameObject(ResID.UI_PropsItem);
	UIUtil.AddChild(self._trsItem, self.itemGo.transform);
	self.item:Init(self.itemGo, nil);
    self.item:AddBoxCollider();
    self:UpdateItem(self.data);
end

function GuildHelpListItem:_Dispose()

    UIUtil.GetComponent(self._btnComit, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnComit = nil;

    self.item:Dispose();
    Resourcer.Recycle(self.itemGo, true);
end

function GuildHelpListItem:UpdateItem(data)
    self.data = data;
    local cfg = TaskManager.GetConfigById(data.id);
    if data and cfg then

    	self._icoPlayer.spriteName = "c" .. (data.kind or -1);
    	self._txtPlayer.text = data.pn;
    	
    	local spId = tonumber(cfg.target[1]);
    	local d = ProductInfo:New();
        d:Init({spId = spId, am = 1});
        self.item:UpdateItem(d);
        self._txtName.text = d:GetName();
        
        local bagNum = BackpackDataManager.GetProductTotalNumBySpid(spId);
        local txtStr = LanguageMgr.Get("common/numMax", {num = bagNum, max = cfg.target_num});
        if bagNum >= cfg.target_num then
            self._txtNum.text = LanguageMgr.GetColor("g", txtStr);
        else
            self._txtNum.text = LanguageMgr.GetColor("r", txtStr);
        end

        local awStr = string.split(cfg.target[2], "_");
        local aw = ProductInfo:New();
        local awNum = tonumber(awStr[2]);
        aw:Init({spId = tonumber(awStr[1]), am = awNum});

        ProductManager.SetIconSprite(self._icoAward, aw:GetIcon_id());
        self._txtAward.text = awNum;

        self._btnComit.gameObject:SetActive(data.pi ~= PlayerManager.playerId);
        self._btnGold.gameObject:SetActive(data.pi ~= PlayerManager.playerId);
    else
    	self._txtName.text = "";
		self._txtNum.text = "";
	    self._icoPlayer.spriteName = "";
	    self._txtPlayer.text = "";
        self._icoAward.spriteName = "";
        self._txtAward.text = "";
    	self.item:UpdateItem(nil);
    	self._btnComit.gameObject:SetActive(false);
        self._btnGold.gameObject:SetActive(false);
    end
end


function GuildHelpListItem:_OnClickBtnComit()
	if self.data then
		TaskProxy.ReqTaskHelpCollectItem(1, self.data.id, self.data.pi);
	end
end

function GuildHelpListItem:_OnClickBtnGold()
    if self.data then
        MsgUtils.UseBDGoldConfirm(1000, self, "task/guild/goldHelp", nil, GuildHelpListItem.ConfirmGold, nil, nil, "common/ok");
    end 
end

function GuildHelpListItem:ConfirmGold()
    TaskProxy.ReqTaskHelpCollectItem(2, self.data.id, self.data.pi);
end
