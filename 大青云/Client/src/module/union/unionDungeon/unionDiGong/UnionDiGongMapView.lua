--[[
帮派地宫争夺战地图
zhangshuhui
]]

_G.UIUnionDiGongMap = BaseMap:new( "UIUnionDiGongMap", MapConsts.Type_Curr, MapConsts.MapName_UnionDiGongWar );

function UIUnionDiGongMap:Create()
	self:AddSWF( "UnionDiGongWarMapPanel.swf", true, nil );
end

function UIUnionDiGongMap:GetScale()
	return 0.3;
end

--到达某icon的时候回调
function UIUnionDiGongMap:OnArriveAtIcon(vo)
	if vo:GetType() == MapConsts.Type_UnionDiGongFlag then
		--UnionDiGongController:DoCollect();
	end
end