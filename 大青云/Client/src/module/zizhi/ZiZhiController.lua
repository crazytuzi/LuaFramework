--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/11/13
    Time: 3:24
   ]]

_G.ZiZhiController = setmetatable({}, { __index = IController })

ZiZhiController.name = "ZiZhiController";

function ZiZhiController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_UseZiZhiDan, self, self.OnUseZZD);
end


-- 1、保甲 2 命玉 3神兵 4 法宝  5境界 6坐骑
function ZiZhiController:FeedZZDan(type)
	local msg = ReqUseZiZhiDanMsg:new()
	msg.type = type;
	MsgManager:Send(msg)
end

function ZiZhiController:OnUseZZD(msg)
	if msg.result == 0 then
		FloatManager:AddNormal(StrConfig["mount21"]);
		ZiZhiModel:SetZZNum(msg.type, msg.pillNum)
	end
	self:sendNotification(NotifyConsts.UseZZDChanged);
end