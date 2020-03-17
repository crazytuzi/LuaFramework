--[[
帮派战ui
wangshuai
]]
_G.UIUnionWar = BaseUI:new("UIUnionWar")


function UIUnionWar:Create()
	self:AddSWF("unionWarPanel.swf",true,nil)
end;

function UIUnionWar:OnLoaded(objSwf)
	objSwf.desc.htmlText = string.format(StrConfig["unionwar201"]);
	objSwf.enterscene.click = function() self:EntersceneClick() end;
	objSwf.outCurpanel.click = function() self:ReturnClick() end;

	local cfg = t_guildActivity[2];
	local time = CTimeFormat:daystr2sec(cfg.openTime)  -- 那个时间点！
	local daytime = GetDayTime(); -- 今天过了多少秒
	local next = 24*3600*7 +(GetLocalTime() - 8*3600 - daytime) + time + (cfg.duration * 60);
	local y,m,d,h,min,s = CTimeFormat:todate(next,true)
	objSwf.opentime.text = string.format(StrConfig["unionwar224"],cfg.openTime,h,min)
end;

function UIUnionWar:EntersceneClick()
	-- 请求进入场景
	local unionlvl = UnionModel:GetMyUnionLevel();
	local cfglvl = t_guildActivity[2].guildlv;
	if unionlvl < cfglvl then 
		FloatManager:AddNormal(StrConfig["unionwar225"]);
		return 
	end;
	UnionWarController:ReqAddUnionWar()
	--UIUnionWarMap:Show();
end;

function UIUnionWar:ReturnClick()
	local parent = self.parent;
	if not parent then return; end
	parent:TurnToDungeonListPanel()
end;
function UIUnionWar:OnShow()

end;

function UIUnionWar:OnHide()
end;
-- 得到当前服务器开启天数
--MainPlayerController:GetServerOpenDay()

