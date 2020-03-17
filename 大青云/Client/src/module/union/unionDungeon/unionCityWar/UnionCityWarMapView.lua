--[[
帮派王城战地图
wangshuai
]]

_G.UIUnionCityWarMap = BaseMap:new( "UIUnionCityWarMap", MapConsts.Type_Curr, MapConsts.MapName_UnionCityWar );

function UIUnionCityWarMap:Create()
	self:AddSWF( "UnionCityWarMapPanel.swf", true, nil );
end

function UIUnionCityWarMap:GetScale()
	return 0.3;
end

--到达某icon的时候回调
function UIUnionCityWarMap:OnArriveAtIcon(vo)
	if vo:GetType() == MapConsts.Type_UnionCityUnits then
		AutoBattleController:OpenAutoBattle();
	end
end