require "Core.Module.Common.Panel"
require "Core.Module.MainUI.View.Item.SimpleWorldBosHurtRankItem"

SimpleWorldBosHurtRankPanel = class("SimpleWorldBosHurtRankPanel", UIComponent);

local autoCloseTime = 5
function SimpleWorldBosHurtRankPanel:New()
	self = { };
	setmetatable(self, { __index = SimpleWorldBosHurtRankPanel });
	return self
end


function SimpleWorldBosHurtRankPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function SimpleWorldBosHurtRankPanel:_InitReference()
	local trsContent = UIUtil.GetChildByName(self._gameObject, "Transform", "trsContent");

	self._txtTitle = UIUtil.GetChildByName(trsContent, "UILabel", "txtTitle")
	self._btnRank = UIUtil.GetChildByName(trsContent, "UIButton", "btnRank")
	self._phalanxInfo = UIUtil.GetChildByName(trsContent, "LuaAsynPhalanx", "trsList/phalanx")

	self._trsMy = UIUtil.GetChildByName(trsContent, "Transform", "trsMy");
	self._icoRank = UIUtil.GetChildByName(self._trsMy, "UISprite", "icoRank");
    self._txtRank = UIUtil.GetChildByName(self._trsMy, "UILabel", "txtRank");
	self._txtName = UIUtil.GetChildByName(self._trsMy, "UILabel", "txtName");
	self._txtHurt = UIUtil.GetChildByName(self._trsMy, "UILabel", "txtHurt");

	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, SimpleWorldBosHurtRankItem)
	self._timer = Timer.New( function() SimpleWorldBosHurtRankPanel._OnTimerHandler(self) end, 1.5, -1, false);
end

function SimpleWorldBosHurtRankPanel:_InitListener()
	self._onClickBtnRank = function(go) self:_OnClickBtnRank(self) end
	UIUtil.GetComponent(self._btnRank, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRank);

	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WorldBossSimpleHurtRank, SimpleWorldBosHurtRankPanel._WorldBossSimpleHurtRankHandler, self);
end

function SimpleWorldBosHurtRankPanel:_OnClickBtnRank()
	ModuleManager.SendNotification(WorldBossNotes.OPEN_WORLDBOSSHURTRANKPANEL);
	--ModuleManager.SendNotification(WorldBossNotes.OPEN_WORLDBOSSPANEL);
end

function SimpleWorldBosHurtRankPanel:_Dispose()
	if (self._timer) then
		self._timer:Stop()
		self._timer = nil
	end
	self:_DisposeListener();
	self:_DisposeReference();
end

function SimpleWorldBosHurtRankPanel:SetActive(active)
	if (self._gameObject) then
		self._gameObject:SetActive(active);
	end

	if (active) then
		self._kind = PlayerManager.hero.info.kind;
		self._txtTitle.text = PlayerManager.hero.info.career .. LanguageMgr.Get("WorldBoss/hurtrank/title");
		if (GameSceneManager.map) then
			self._mapType = GameSceneManager.map.info.type;
		else
			self._mapType = nil;
		end
		if (self._mapType == 7 and self._kind) then
			self:_OnTimerHandler()
			self._timer:Start();
		else
			self._timer:Stop();
		end
	else
		self._timer:Stop();
	end
end

function SimpleWorldBosHurtRankPanel:_WorldBossSimpleHurtRankHandler(cmd, data)
	local ls = {};
	local cmy = false;	
	local pid = PlayerManager.hero.id;
	if (data.l) then
		for i,v in pairs(data.l) do
			if (v and v.pi == pid) then
				if (not cmy) then
					self:_UpdateItem(v)					
					cmy = true;
				else
					ls[v.id] = v					
				end
			else
				ls[v.id] = v
			end
		end
	end
	if (not cmy) then
		self:_UpdateItem(nil)
		
	end
	self._phalanx:Build(table.getn(ls), 1, ls);
end

function SimpleWorldBosHurtRankPanel:_UpdateItem(data)
	if (data) then
		if (data.id > 3) then
			self._txtRank.text = data.id;			
			self._icoRank.gameObject:SetActive(false);
		else
			self._icoRank.spriteName = "no"..data.id;
			self._txtRank.text = "";
			self._icoRank.gameObject:SetActive(true);
		end
		self._txtName.text = data.pn;
		self._txtHurt.text = data.h;
		self._trsMy.gameObject:SetActive(true);
	else
		self._trsMy.gameObject:SetActive(false);
	end
end

function SimpleWorldBosHurtRankPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnRank, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnRank = nil;

	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WorldBossSimpleHurtRank, SimpleWorldBosHurtRankPanel._WorldBossSimpleHurtRankHandler, self);
end

function SimpleWorldBosHurtRankPanel:_DisposeReference()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
    self._txtTitle = nil;
	self._btnRank = nil;
	self._phalanxInfo = nil;
	self._trsMy = nil;
	self._icoRank = nil;
    self._txtRank = nil;
	self._txtName = nil;
	self._txtHurt = nil;
	self._phalanx:Dispose()
    self._phalanx = nil;
end


function SimpleWorldBosHurtRankPanel:_OnTimerHandler()
	if (self._kind and self._mapType == 7) then
		SocketClientLua.Get_ins():SendMessage(CmdType.WorldBossSimpleHurtRank, { kind = self._kind });
	end
end