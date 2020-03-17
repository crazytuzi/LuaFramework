--[[
	帮派王城战进入ui
	wangshuai
]]

_G.UIUnionCityWar = BaseUI:new("UIUnionCityWar");
 
function UIUnionCityWar:Create()
	self:AddSWF("unionCityWarPanel.swf",true,nil)
--	print("进入加载")
end; 

function UIUnionCityWar:OnLoaded(objSwf)
	objSwf.desc.htmlText = string.format(StrConfig["unioncitywar802"])

	objSwf.enterscene.click = function() self:EntersceneClick() end;
	objSwf.outCurpanel.click = function() self:ReturnClick() end;

	local cfg = t_guildActivity[3];
	local time = CTimeFormat:daystr2sec(cfg.openTime)  -- 那个时间点！
	local daytime = GetDayTime(); -- 今天过了多少秒
	local next = 24*3600*7 +(GetLocalTime() - 8*3600 - daytime) + time + (cfg.duration * 60);
	local y,m,d,h,min,s = CTimeFormat:todate(next,true)
	objSwf.opentime.text = string.format(StrConfig["unionwar224"],cfg.openTime,h,min)

end;
function UIUnionCityWar:OnShow()
	
end;

function UIUnionCityWar:EntersceneClick()
	local unionlvl = UnionModel:GetMyUnionLevel();
	local cfglvl = t_guildActivity[3].guildlv;
	if unionlvl < cfglvl then 
		FloatManager:AddNormal(StrConfig["unionwar225"]);
		return 
	end;

	UnionCityWarController:EnterUnionCityWar()
end;

function UIUnionCityWar:ReturnClick()
	local parent = self.parent;
	if not parent then return; end
	parent:TurnToDungeonListPanel()
end;