--[[
提醒交旗面板
wangshuao
]]
_G.UIZhchUpFlag = BaseUI:new("UIZhchUpFlag")

function UIZhchUpFlag:Create()
	self:AddSWF("zhanchangFlagremind.swf",true,"center")
end;

function UIZhchUpFlag:OnLoaded(objSwf)
	objSwf.goUpFlag.click = function() self:OnGoUpFlag()end;
end;

function UIZhchUpFlag:OnShow()

end;

function UIZhchUpFlag:OnHide()

end;

function UIZhchUpFlag:OnGoUpFlag()
	local mycamp = ActivityZhanChang:GetMyCamp();
	local cfg = ZhChFlagUpPoint[mycamp];
	if not cfg then return end;
	local mapid = CPlayerMap:GetCurMapID();
	MainPlayerController:DoAutoRun(mapid,_Vector3.new(cfg.x,cfg.y,0),function()end);
end;