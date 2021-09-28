require "Core.Module.Common.Panel"

local WingActivePanel = class("WingActivePanel", Panel);
function WingActivePanel:New()
	self = {};
	setmetatable(self, {__index = WingActivePanel});
	return self
end


function WingActivePanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function WingActivePanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
	self._txtPower = UIUtil.GetChildInComponents(txts, "txtPower");
	self._txtProperty1 = UIUtil.GetChildInComponents(txts, "txtProperty1");
	self._txtProperty2 = UIUtil.GetChildInComponents(txts, "txtProperty2");
	self._txtProperty4 = UIUtil.GetChildInComponents(txts, "txtProperty4");
	self._txtProperty3 = UIUtil.GetChildInComponents(txts, "txtProperty3");
	self._txtProperty7 = UIUtil.GetChildInComponents(txts, "txtProperty7");
	self._txtProperty8 = UIUtil.GetChildInComponents(txts, "txtProperty8");
	self._txtProperty6 = UIUtil.GetChildInComponents(txts, "txtProperty6");
	self._txtProperty5 = UIUtil.GetChildInComponents(txts, "txtProperty5");
	self._btnEquip = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnEquip");
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
	self._trsRoleParent = UIUtil.GetChildInComponents(trss, "trsRoleParent");
	local effectParent = UIUtil.GetChildByName(self._trsContent, "effectParent")
    local bg = UIUtil.GetChildByName(self._trsContent,"UISprite","bg")
    
	self._effect = UIEffect:New()
    self._effect:Init(effectParent,bg,0,"ui_trump_show",1)
end

function WingActivePanel:_InitListener()
	self._onClickBtnEquip = function(go) self:_OnClickBtnEquip(self) end
	UIUtil.GetComponent(self._btnEquip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnEquip);
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function WingActivePanel:_OnClickBtnEquip()
	WingProxy.SendUseWing(self.wing_id)
	self:_OnClickBtn_close();
end

function WingActivePanel:_OnClickBtn_close()
	ModuleManager.SendNotification(WingNotes.CLOSE_WINGACTIVEPANEL)
end
function WingActivePanel:SetData(data)
	self.wing_id = data.id;
	
	self.wing = WingManager.GetFashionById(self.wing_id)
	
	
	local dress = {}
	local heroInfo = PlayerManager.GetPlayerInfo()
	dress = WingManager.GetFashionDataById(data.id)
	
	self:CleanWingModel();
	self._uiWingModel = UIAnimationModel:New(dress, self._trsRoleParent, WingCreater)
	
	self._baseAttr = BaseAdvanceAttrInfo:New()
	self._baseAttr:Init(self.wing);
	
	self.currFight = CalculatePower(self._baseAttr);
	
	self._txtName.text = self.wing.name;
	self._txtPower.text = self.currFight;
	
	
	local atts = self._baseAttr:GetPropertyAndDes()
	for i = 1, 8 do
		local att = atts[i];
		if att ~= nil then
			self["_txtProperty" .. i].text = "[caecff]" .. att.des .. "[-] [9cff94]+" .. att.property .. att.sign .. "[-]";
			self["_txtProperty" .. i].gameObject:SetActive(true);
		else
			self["_txtProperty" .. i].gameObject:SetActive(false);
		end
	end
	self._effect:Play()
end


function WingActivePanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function WingActivePanel:_DisposeListener()
	UIUtil.GetComponent(self._btnEquip, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnEquip = nil;
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function WingActivePanel:CleanWingModel()
	if self._uiWingModel ~= nil then
		self._uiWingModel:Dispose();
		self._uiWingModel = nil;
	end
end

function WingActivePanel:_DisposeReference()
	
	self:CleanWingModel();
	
	
	
	self._btnEquip = nil;
	self._btn_close = nil;
	self._txtName = nil;
	self._txtPower = nil;
	self._txtProperty1 = nil;
	self._txtProperty2 = nil;
	self._txtProperty4 = nil;
	self._txtProperty3 = nil;
	self._txtProperty7 = nil;
	self._txtProperty8 = nil;
	self._txtProperty6 = nil;
	self._txtProperty5 = nil;
	self._trsRoleParent = nil;
    self._effect:Dispose()
    self._effect = nil
end
return WingActivePanel 