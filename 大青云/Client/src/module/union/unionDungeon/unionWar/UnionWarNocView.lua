--[[
npc 面板
wangshuai
]]
_G.UIUnionWarNpcWin = BaseUI:new("UIUnionWarNpcWin")

function UIUnionWarNpcWin:Create()
	self:AddSWF("unionWarWindowpanlTow.swf",true,"center")
end;

function UIUnionWarNpcWin:OnLoaded(objSwf)
	objSwf.rule.rollOver = function() self:RuleOver()end;
	objSwf.rule.rollOut  = function() TipsManager:Hide()  end;

	objSwf.daNpc.click = function() self:DaNpc() end;
	objSwf.goNpc.click = function() self:DaNpc() end;

	objSwf.outZhch.click = function() self:OnCloseActivity() end;
end;	 

function UIUnionWarNpcWin:OnShow()
	self:UpTime();
end;

function UIUnionWarNpcWin:OnHide()

end;

function UIUnionWarNpcWin:UpTime()
	local time = UnionWarModel:GetWarAllInfo().UnionTime;
	local objSwf = self.objSwf;
	local t,s,m = UnionWarModel:GetTimer(time)
	if not objSwf then return end;
	if not time  then return end;
	objSwf.lastTime.text = string.format(StrConfig["unionwar210"],t,s,m);
end;

function UIUnionWarNpcWin:RuleOver() 
	--TipsManager:ShowBtnTips(string.format(StrConfig["unionwar200"]));--unionwar202
	TipsManager:ShowBtnTips(string.format(StrConfig["union404"]));
end;

function UIUnionWarNpcWin:DaNpc()
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	local cfg = UnionWarNpcCfg.npc;
	local mapid = CPlayerMap:GetCurMapID();
	MainPlayerController:DoAutoRun(mapid,_Vector3.new(cfg.x,cfg.y,0),completeFuc);
end;

function UIUnionWarNpcWin:OnCloseActivity()
		-- 退出战场
	self:Hide();
	UnionWarController:Outwar()
end;