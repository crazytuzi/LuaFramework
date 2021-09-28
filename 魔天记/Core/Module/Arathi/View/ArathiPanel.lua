require "Core.Module.Common.Panel";
require "Core.Module.Arathi.View.Item.ArathiAwardItem"

local timeCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_TIME);
local battleCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_CONFIG);
local pointCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_POINT);
local mapCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP);
local arathiActivityItem = ActivityDataManager.GetCfByInterface_id(ActivityDataManager.interface_id_15);
local sin = math.sin(math.rad(45))
local cos = math.cos(math.rad(45))
local rsin = math.sin(math.rad(- 45))
local rcos = math.cos(math.rad(- 45))
local rad = 45

ArathiPanel = Panel:New();

function ArathiPanel:_Init()
	self:_InitReference();
	self:_InitListener();
	ArathiProxy.ArathiData();
end

function ArathiPanel:_InitReference()
	local txtDesc = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsInfo/txtDesc");
	txtDesc.text = LanguageMgr.Get("Arathi/Desc");
	
	self._txtLevel = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsInfo/titleLevel/txtLevel");
	self._txtTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsInfo/titleTime/txtTime");
	self._txtNum = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsInfo/titleNum/txtNum");
	--    self._txtWinAward = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsInfo/titleWinAward/txtWinAward");
	--    self._txtAward = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsInfo/titleAward/txtAward");
	self._txtPoint = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtPoint");
	self._txtPoint.text = PlayerManager.spend;
	
	self._txtMatching = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsMap/txtMatching");
	self._txtMatching.gameObject:SetActive(false);
	
	self._btnShop = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnShop");
	
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
	self._btnHelp = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnHelp");
	self._btnTip = UIUtil.GetChildByName(self._trsContent, "UIButton", "trsMap/btnTip");
	self._btnSignup = UIUtil.GetChildByName(self._trsContent, "UIButton", "trsMap/btnSignup");
	
	self._imgMap = UIUtil.GetChildByName(self._trsContent, "UITexture", "trsMap/trsMap/map");
	self._goPoint = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMap/trsMap/map/txtItem").gameObject;
	
	local mapTexture = "map/" .. mapCfg[battleCfg[1].map_id].minimap;
	self._imgMap.mainTexture = UIUtil.GetTexture(mapTexture);
	
	self._awards = {};
	local res = battleCfg[1].award_show;
	
	for i = 1, 5 do
		local tran = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInfo/awards/res" .. i);
		local item = ArathiAwardItem:New(tran);
		local p = res[i];
		if(p) then
			local sp = string.split(p, "_");
			item:SetProductId(tonumber(sp[1]));
		end
		self._awards[i] = item;
	end
	
	local mapInfo = mapCfg[battleCfg[1].map_id];
	if(mapInfo) then
		for i, v in pairs(pointCfg) do
			if(v.l_name ~= "") then
				local go = NGUITools.AddChild(self._imgMap.gameObject, self._goPoint);
				local label = go:GetComponent("UILabel");
				local pos = Convert.PointFromServer(v.x, v.y, v.z);
				if(label) then
					label.text = v.l_name;
					if(v.id == 1 or v.id == 2) then
						label.color = ColorDataManager.GetCampColor(v.id);
					end
				end
				Util.SetLocalPos(go, self:_TransferWorldToLocal(pos, mapInfo))
				
				--                go.transform.localPosition = self:_TransferWorldToLocal(pos, mapInfo)
			end
		end
	end
	self._goPoint:SetActive(false);
	self._txtLevel.text = arathiActivityItem.min_lev;
end

function ArathiPanel:_TransferWorldToLocal(pos, mapInfo)
	local result = Vector3((((pos.x * cos + pos.z * sin) - mapInfo.offsetX) / mapInfo.mapXSize) * self._imgMap.width,
	(((pos.z * cos - pos.x * sin) - mapInfo.offsetY) / mapInfo.mapYSize) * self._imgMap.height, 0)
	return result
end

function ArathiPanel:_InitListener()
	self._onClickBtnShop = function(go) self:_OnClickBtnShop(self) end
	UIUtil.GetComponent(self._btnShop, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnShop);
	
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	
	self._onClickHelp = function(go) self:_OnClickHelp(self) end
	UIUtil.GetComponent(self._btnHelp, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHelp);
	
	self._onClickTip = function(go) self:_OnClickTip(self) end
	UIUtil.GetComponent(self._btnTip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTip);
	
	self._onClickSignup = function(go) self:_OnClickSignup(self) end
	UIUtil.GetComponent(self._btnSignup, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickSignup);
	
	MessageManager.AddListener(ArathiNotes, ArathiNotes.EVENT_ARATHIDATA, ArathiPanel._OnDataHandler, self);
	MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_XIUWEI_CHANGE, ArathiPanel.OnMoneyChange, self);
end

function ArathiPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function ArathiPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnShop, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnShop = nil;
	
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	
	UIUtil.GetComponent(self._btnHelp, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickHelp = nil;
	
	UIUtil.GetComponent(self._btnTip, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickTip = nil;
	
	UIUtil.GetComponent(self._btnSignup, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickSignup = nil;
	
	MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_ARATHIDATA, ArathiPanel._OnDataHandler);
	MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_XIUWEI_CHANGE, ArathiPanel.OnMoneyChange, self);
end

function ArathiPanel:_DisposeReference()
	for i, v in pairs(self._awards) do
		v:Dispose()
	end
	self._awards = nil;
	self._txtLevel = nil;
	self._txtTime = nil;
	self._txtNum = nil;
	self._txtWinAward = nil;
	self._txtAward = nil;
	self._txtPoint = nil;
	self._txtMatching = nil;
	self._btnShop = nil;
	self._btnClose = nil;
	self._btnHelp = nil;
	self._btnTip = nil;
	self._btnSignup = nil;
	self._imgMap = nil;
end

function ArathiPanel:OnMoneyChange()
	if(self._txtPoint) then
		self._txtPoint.text = PlayerManager.spend;
	end
end

function ArathiPanel:_OnClickBtnShop()
	--ModuleManager.SendNotification(TShopNotes.OPEN_TSHOP, {type = TShopNotes.Shop_type_fightScene}); 
	ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 5});
	
	
end

function ArathiPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIPANEL)
end

function ArathiPanel:_OnClickHelp()
	ModuleManager.SendNotification(ArathiNotes.OPEN_ARATHIHELPPANEL)	
end

function ArathiPanel:_OnClickTip()
	ModuleManager.SendNotification(ArathiNotes.OPEN_ARATHITIPSPANEL)
end


function ArathiPanel:_OnClickSignup()
	-- if (self._data) then
	--ModuleManager.SendNotification(ArathiNotes.OPEN_ARATHISIGNUPPANEL, self._data);
	-- end

	ArathiProxy.EnterReadyScene();

end

function ArathiPanel:_GetOpenTimeByTurn(turn)
	local item1 = timeCfg[1];
	local item2 = timeCfg[2];
   
	if(item1 and item2) then
		return item1["notice_time"] .. "-" .. item2["end"];
	end
	return ""
end

local notice = LanguageMgr.Get("Arathi/ArathiPanel/open")
function ArathiPanel:_OnDataHandler(data)
	local maxCount = 2;
	if(arathiActivityItem) then maxCount = arathiActivityItem.activity_times end
	if(data.bts > maxCount) then data.bts = maxCount end
	self._data = data
	self._currCount = maxCount - data.bts 
	if(data.flag == 1) then
		self._txtTime.text =  notice 
	else
		self._txtTime.text = "[ff454a]" .. self:_GetOpenTimeByTurn(data.turn) .. "[-]";
	end
	 
	self._txtNum.text = self._currCount .. "/" .. maxCount;
end 