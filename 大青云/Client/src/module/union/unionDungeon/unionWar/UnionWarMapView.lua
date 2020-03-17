--[[
帮派战地图
wangshuai
]]

_G.UIUnionWarMap = BaseMap:new( "UIUnionWarMap", MapConsts.Type_Curr, MapConsts.MapName_UnionWar )

function UIUnionWarMap:Create()
	self:AddSWF("unionWarMapPanel.swf", true, nil)
end

function UIUnionWarMap:GetScale()
	return 0.4;
end

--到达某icon的时候回调
function UIUnionWarMap:OnArriveAtIcon(vo)
	if vo:GetType() == MapConsts.Type_UnionWarBuilding then
		AutoBattleController:OpenAutoBattle();
	end
end

-- ----- ---- ----  notifaction

-- -- handle other notifications which has nothing to do with map
-- function BaseMap:HandleOtherNotification( name, body )
-- 	-- 子类实现
-- end

-- function UIUnionWarMap:ListNotificationInterests()
-- 	return {
-- 			NotifyConsts.UnionWarAllinfo,
-- 		}
-- end;
-- function UIUnionWarMap:HandleNotification(name,body)
-- 	if not self.bShowState then return; end  -- 关闭等于False
-- 	if name == NotifyConsts.UnionWarAllinfo then 
 		
-- 	end;
-- end;


function UIUnionWarMap:OnSetBtnState()
	
end;