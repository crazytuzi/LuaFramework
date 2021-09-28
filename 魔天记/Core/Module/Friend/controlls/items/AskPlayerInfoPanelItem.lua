require "Core.Module.Common.UIItem"
require "Core.Module.Friend.controlls.PartData"


AskPlayerInfoPanelItem = class("AskPlayerInfoPanelItem", UIItem);

function AskPlayerInfoPanelItem:New()
	self = {};
	setmetatable(self, {__index = AskPlayerInfoPanelItem});
	return self
end

function AskPlayerInfoPanelItem:UpdateItem(data)
	self.data = data
	
	self:SetData(data);
end

function AskPlayerInfoPanelItem:Init(gameObject, data)
	
	self.data = data
	self.gameObject = gameObject
	
	self.caree_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "caree_txt");
	self.name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "name_txt");
	self.level_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "level_txt");
	self.fight_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "fight_txt");
	
	self.askFro_bt = UIUtil.GetChildByName(self.gameObject, "UIButton", "askFro_bt");
	
	self.askFro_bt_btHandler = function(go) self:AskFro_bt_btHandler(self) end
	UIUtil.GetComponent(self.askFro_bt, "LuaUIEventListener"):RegisterDelegate("OnClick", self.askFro_bt_btHandler);
	
	self:UpdateItem(self.data);
	
end

function AskPlayerInfoPanelItem:AskFro_bt_btHandler()
	
	
	local num = PartData.GetMyTeamNunberNum();
	if num >= 4 then
		
		MsgUtils.ShowTips("friend/AskPlayerInfoPanelItem/tip1");
	else
		FriendProxy.AskFroAessJointPartyDeal(1, self.infoData.pid);
		-- self.askFro_bt.gameObject:SetActive(false);
	end
	
	
end



function AskPlayerInfoPanelItem:SetActive(v)
	self.gameObject:SetActive(v);
end

--[[l:[{pid:玩家id，n:玩家昵称,k：玩家kind,l:等级,f:战斗力},..]

]]
--[[11:31:12.705-517: 1--f= [33435]
  --n= [王立阳]
  --kind= [101000]
  --l= [96]
  --pid= [10100039]
]]
function AskPlayerInfoPanelItem:SetData(infoData)
	
	self.infoData = infoData;
	
	
	local careerCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER);
	local baseInfo = careerCfg[self.infoData.kind];
	
	if self.infoData.l == nil then
		self.infoData.l = 1;
	end
	
	
	self.caree_txt.text = baseInfo.career;
	self.name_txt.text = self.infoData.n;
	self.level_txt.text = GetLvDes1(self.infoData.l);
	
	
	self.fight_txt.text = "" .. self.infoData.f;
	
	self:SetActive(true);
end


function AskPlayerInfoPanelItem:_Dispose()
	self.gameObject = nil;
	self.data = nil;
	
	self.caree_txt = nil;
	self.name_txt = nil;
	self.level_txt = nil;
	self.fight_txt = nil;
	
	
	UIUtil.GetComponent(self.askFro_bt, "LuaUIEventListener"):RemoveDelegate("OnClick");
	
	self.askFro_bt = nil;
	
	self.askFro_bt_btHandler = nil;
	
end 