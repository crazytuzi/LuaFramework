require "Core.Module.Common.Panel"
require "Core.Module.WildBoss.View.Item.WildBossRankItem"

WildBossRankPanel = class("WildBossRankPanel", Panel);
local insert = table.insert

function WildBossRankPanel:New()
	self = {};
	setmetatable(self, {__index = WildBossRankPanel});
	return self
end

function WildBossRankPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function WildBossRankPanel:_InitReference()
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._txtContent = UIUtil.GetChildByName(self._trsContent, "UILabel", "content")
end

function WildBossRankPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

local green = "   [" .. ColorDataManager.ConventToColorCode(ColorDataManager.Get_green()) .. "]"
local wildBossRankNotice = LanguageMgr.Get("WildBossRankPanel/wildBossRankNotice")

function WildBossRankPanel:UpdatePanel(data)	
	if(data) then
		local str = ""
		local l = table.getCount(data.l)
		if(l > 0) then
			for k, v in ipairs(data.l) do
				str = str .. v.time .. green .. v.kn .. "[-]" .. wildBossRankNotice
				if(k ~= l) then
					str = str .. "\n"
				end
			end
		end
		self._txtContent.text = str
	end
end

function WildBossRankPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(WildBossNotes.CLOSE_WILDBOSSRANKPANEL)
end

function WildBossRankPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function WildBossRankPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");	
	self._onClickBtn_close = nil;
	
end

function WildBossRankPanel:_DisposeReference()	
	self._btn_close = nil;
end 