--[[
	战场地图
	wangshuai
]]

_G.UIZhanChangMap = BaseMap:new( "UIZhanChangMap", MapConsts.Type_Curr, MapConsts.MapName_Zhanchang );

UIZhanChangMap.texiaolist = {};
function UIZhanChangMap:Create()
	self:AddSWF( "ZhanchangMapPanel.swf", true, nil );
end

function UIZhanChangMap:GetScale()
	return 0.35;
end

--到达某icon的时候回调
function UIZhanChangMap:OnArriveAtIcon(vo)
	if vo:GetType() == MapConsts.Type_ZhanchangUnits then
		if vo.unitType == 2 then -- 是旗子点时
			local node = {};
			node.id = vo:GetId();
			node.camp = vo.camp;
			ZhChFlagController:DoCollect(node);
		end
	end
end

function UIZhanChangMap:OnChildShow()
	self:OnSetTexiao();
end

function UIZhanChangMap:OnSetTexiao()
	local objSwf = self.objSwf;
	local mycmp = ActivityZhanChang:GetMyCamp()

	local scfg = ActivityZhanChang.zcFlagList;

	for i, cvo in pairs(ZhChFlagConfig) do 
		local x,y = MapUtils:Point3Dto2D(cvo.x,cvo.y,self.MapId)
		local falgicon = objSwf.map:addIcon("flag"..i,"camptexiao",x*self:GetScale(),y*self:GetScale(),"texiao",0)
		falgicon._visible = false;
		falgicon.data = cvo;
		self.texiaolist[cvo.id] = falgicon
	end;
end;

function UIZhanChangMap:OnShowTexiao(id)
	if not self:IsShow() then return end;
	local objSwf = self.objSwf;
	local icon = self.texiaolist[id];
	if not icon then return end;
	icon._visible = true;
	icon:gotoAndPlay(1)
	TimerManager:RegisterTimer(function()
		icon._visible = false;
	end, 1000, 1)
end;