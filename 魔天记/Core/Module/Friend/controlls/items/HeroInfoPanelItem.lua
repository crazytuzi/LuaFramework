require "Core.Module.Common.UIAnimationModel";
require "Core.Module.Friend.controlls.items.HeroDealItem";
require "Core.Role.ModelCreater.UIRoleModelCreater"

HeroInfoPanelItem = class("HeroInfoPanelItem");

function HeroInfoPanelItem:New()
	self = {};
	setmetatable(self, {__index = HeroInfoPanelItem});
	return self
end


function HeroInfoPanelItem:Init(heroMc, heroinfoPane, heroDealItemCtrl, index, addHeroItemCtrl)
	self.heroMc = heroMc;
	self.heroinfoPane = heroinfoPane;
	self.addHeroItemCtrl = addHeroItemCtrl;
	
	self.infoPanel = UIUtil.GetChildByName(self.heroinfoPane, "Transform", "infoPanel");
	
	self.bg = UIUtil.GetChildByName(self.heroinfoPane, "UISprite", "bg");
	self.zsIcon = UIUtil.GetChildByName(self.heroinfoPane, "UISprite", "zsIcon");
	
	
	self.nameTxt = UIUtil.GetChildByName(self.infoPanel, "UILabel", "nameTxt");
	self.caree_levelTxt = UIUtil.GetChildByName(self.infoPanel, "UILabel", "caree_levelTxt");
	self.fightTxt = UIUtil.GetChildByName(self.infoPanel, "UILabel", "fightTxt");
	
	self.careeIcon = UIUtil.GetChildByName(self.infoPanel, "UISprite", "careeIcon");
	self.vipIcon = UIUtil.GetChildByName(self.infoPanel, "UISprite", "vipIcon");
	
	
	self.index = index;
	self.heroDealItemCtrl = heroDealItemCtrl;
	
	
	self.heroBt = UIUtil.GetChildByName(self.heroinfoPane, "UIButton", "heroBt");
	
	self.heroBtHandler = function(go) self:HeroBtHandler(self) end
	UIUtil.GetComponent(self.heroBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self.heroBtHandler);
	
	self.hasUpDress = false;
	local info = {};
	info.kind = 101000;
	self.curr_dress = {};
	--  dress":{"a":301000,"b":0,"c":"","w":0,"h":0,"m":0}
	info.dress = {a = 301000, b = 0, c = nil, w = 0, h = 0, m = 0};
	
	
	self.old_kind = 0;
	
	if(self._uiAnimationModel == nil) then
		self._uiAnimationModel = UIAnimationModel:New(info, self.heroMc, UIRoleModelCreater)
	else
		self._uiAnimationModel:ChangeModel(info, self.heroMc)
	end
	
	self.heroMc.gameObject:SetActive(false);
	self.showing = false;
end


function HeroInfoPanelItem:Show(data)
	self:SetData(data);
	
	if self.hasUpDress then
		self.heroMc.gameObject:SetActive(true);
	end
	
	self.infoPanel.gameObject:SetActive(true);
	self.showing = true;
	
	self.zsIcon.spriteName = "zs1";
end

function HeroInfoPanelItem:Hdie()
	self.heroMc.gameObject:SetActive(false);
	self.infoPanel.gameObject:SetActive(false);
	self.showing = false;
	self.zsIcon.spriteName = "zs2";
	self.data = nil;
end


function HeroInfoPanelItem:HeroBtHandler()
	
	
	
	
	if self.data ~= nil then
		self.heroDealItemCtrl:SetData(self.data);
		self.heroDealItemCtrl:Show(self.index);
		
		self.addHeroItemCtrl:SetActive(false);
	else
		-- 自己还没有队伍，和自己是队长的时候才可以有这样的提示
		local mt = PartData.GetMyTeam();
		local b = PartData.MeIsTeamLeader();
		if mt == nil or b then
			self.addHeroItemCtrl:Show(self.index);
			self.heroDealItemCtrl:SetActive(false);
			
		end
		
	end
	
end

-- {"f":1128,"num":1,"k":101000,"id":1,"l":1,"n":"姜小浩"}
function HeroInfoPanelItem:SetData(data)
	
	self.data = data;
	
	local careerCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER);
	local baseInfo = careerCfg[self.data.k];
	
	self.nameTxt.text = data.n;
	--   self.caree_levelTxt.text = baseInfo.career .. "  " .. GetLvDes(self.data.l);
	self.careeIcon.spriteName = "c" .. self.data.k;
	
	self.caree_levelTxt.text = LanguageMgr.Get("Friend/HeroInfoPanelItem/label1", {n = GetLvDes1(self.data.l)});
	self.fightTxt.text = "" .. self.data.f;
	
--	if data.vip ~= nil and data.vip > 0 then
--		self.vipIcon.spriteName = VIPManager.GetVipIconByVip(data.vip);
--		self.vipIcon.gameObject:SetActive(true);
--	else
--		self.vipIcon.gameObject:SetActive(false);
--	end
    self.vipIcon.gameObject:SetActive(false)
	local vc = ColorDataManager.Get_Vip(data.vip)	
	self.nameTxt.text = vc .. self.nameTxt.text
end

--[[0E 获取队员模型
输入：

输出：
dress：：[{id:玩家id，a:spId武器,b:spId衣服,w:spId翅膀,m:载具id,h:spId坐骑,c:模型id,String}]
0x0B0E

]]
function HeroInfoPanelItem:UpDress(arr)
	
	if self.showing then
		
		local len = table.getn(arr);
		
		for i = 1, len do
			local data = arr[i];
			
			local d_id = data.id + 0;
			local m_id = self.data.pid + 0;
			
			if d_id == m_id then
				
				local info = {};
				info.kind = self.data.k;
				info.dress = data;
				
				info.dress.h = 0;
				
				if self.old_kind ~= info.kind or
				self.curr_dress.a ~= info.dress.a or
				self.curr_dress.b ~= info.dress.b or
				self.curr_dress.w ~= info.dress.w or
				self.curr_dress.m ~= info.dress.m or
				self.curr_dress.c ~= info.dress.c then
					
					self.curr_dress = info.dress;
					self.old_kind = info.kind;
					
					self._uiAnimationModel:ChangeModel(info, self.heroMc);
					self.heroinfoPane.gameObject:SetActive(false);
					self.heroinfoPane.gameObject:SetActive(true);
					
					self.heroMc.gameObject:SetActive(true);
					
				end
				
				self.hasUpDress = true;
				
				return;
				
			end
			
		end
		
	end
	
	
end


function HeroInfoPanelItem:Dispose()
	
	self.heroDealItemCtrl = nil;
	
	if(self._uiAnimationModel) then
		self._uiAnimationModel:Dispose()
		self._uiAnimationModel = nil
	end
	UIUtil.GetComponent(self.heroBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self.heroBtHandler = nil;
	
	self.heroMc = nil;
	self.heroinfoPane = nil;
	
	self.infoPanel = nil;
	
	self.bg = nil;
	self.zsIcon = nil;
	
	self.nameTxt = nil;
	self.caree_levelTxt = nil;
	self.fightTxt = nil;
	
	self.heroDealItemCtrl = nil;
	
	self.heroBt = nil;
	
end 