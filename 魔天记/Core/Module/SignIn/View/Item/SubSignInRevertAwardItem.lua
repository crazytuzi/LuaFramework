require "Core.Module.Common.UIItem"

SubSignInRevertAwardItem = UIItem:New();
SubSignInRevertAwardItem.Type = {
	Gold = 1;	
	Money = 2;
};

function SubSignInRevertAwardItem:_Init()
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._trsItem1 = UIUtil.GetChildByName(self.transform, "Transform", "trsItem1");
    self._trsItem2 = UIUtil.GetChildByName(self.transform, "Transform", "trsItem2");
    self._item1 = PropsItem:New();
    self._item1:Init(self._trsItem1, nil);
    self._item2 = PropsItem:New();
    self._item2:Init(self._trsItem2, nil);

    self._icoCost = UIUtil.GetChildByName(self.transform, "UISprite", "icoCost");
    self._txtCost = UIUtil.GetChildByName(self.transform, "UILabel", "icoCost/txtCost");

    self._icoRevert = UIUtil.GetChildByName(self.transform, "UISprite", "icoRevert");
    self._icoRevert.gameObject:SetActive(false);
	self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "txtNum");
	self._btnRevert = UIUtil.GetChildByName(self.transform, "UIButton", "btnRevert");
    self._onRevertClick = function(go) self:_OnRevertClick(go) end
	UIUtil.GetComponent(self._btnRevert, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onRevertClick);

    self:UpdateItem(self.data);
end

function SubSignInRevertAwardItem:_Dispose()
    self._item1:Dispose();
    self._item2:Dispose();

    UIUtil.GetComponent(self._btnRevert, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onRevertClick = nil;
end

function SubSignInRevertAwardItem:UpdateItem(data)
    self.data = data;
end

function SubSignInRevertAwardItem:UpdateItemType(type)
	self.itemType = type;
	if self.data then
		local cfg = SignInManager.GetRevertCfgById(self.data.id);
		self._cfg = cfg;

		local price = 0;
		local num = 1;
		
		if self.data.am1 < self.data.am then
			self._btnRevert.gameObject:SetActive(true);
			self._txtNum.gameObject:SetActive(true);
			self._icoRevert.gameObject:SetActive(false);
			num = math.min(cfg.count, self.data.am - self.data.am1);
		else
			self._btnRevert.gameObject:SetActive(false);
			self._txtNum.gameObject:SetActive(false);
			self._icoRevert.gameObject:SetActive(true);
		end

		
		local awards = nil;
		if type == SubSignInRevertAwardItem.Type.Gold then
			self._icoCost.spriteName = "bangdingxianyu";
			self._icoCost:MakePixelPerfect();
			price = cfg.gold_price;
			awards = cfg.gold_reward;
		else
			self._icoCost.spriteName = "lingshi";
			self._icoCost:MakePixelPerfect();
			price = cfg.money_price;
			awards = cfg.money_reward;
		end

		for i = 1, 2 do
			if awards[i] then
				local tmp = string.split(awards[i], "_");
				local aId = tonumber(tmp[1]);
				local aNum = tonumber(tmp[2]);
				local o = ProductInfo:New();
				o:Init({spId = aId, am = aNum * num});
				self["_trsItem"..i].gameObject:SetActive(true);
				self["_item"..i]:UpdateItem(o);
			else
				self["_item"..i]:UpdateItem(nil);
				self["_trsItem"..i].gameObject:SetActive(false);
			end
		end
		self._costNum = num;
		self._costVal = price * num;
		self._txtCost.text = self._costVal;
		self._txtName.text = cfg.activity_name;

		local val = self.data.am - self.data.am1;
		self._txtNum.text = LanguageMgr.GetColor(val > 0 and "g" or "r",  val .. "/" .. self.data.am);
	end
end

function SubSignInRevertAwardItem:_OnRevertClick()
	if self.data then
		
		if self.itemType == SubSignInRevertAwardItem.Type.Gold then
			MsgUtils.UseBDGoldConfirm2(self._costVal, self, "SignIn/RevertAward/revertWithGold", {name = self._cfg.activity_name, count = self._costNum}, SubSignInRevertAwardItem._DoReqRevert, nil, nil, "common/ok");
			return;
		end

		self:_DoReqRevert();
		
	end
end

function SubSignInRevertAwardItem:_DoReqRevert()
	SignInProxy.ReqRevertAward(self._cfg.activity_id, self.itemType);
end