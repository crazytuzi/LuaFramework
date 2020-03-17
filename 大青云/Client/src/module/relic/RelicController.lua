_G.RelicController = setmetatable({},{__index=IController});
RelicController.name = "RelicController";

function RelicController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_LevelupRelicItemResult,self,self.OnRelicUpResult);
end

-- 圣物升级结果
function RelicController:OnRelicUpResult(msg)
	if msg.result == 0 then
		self:sendNotification(NotifyConsts.RelicUpdata)
		FloatManager:AddNormal("精炼成功")
	end
end

-- 申请圣物升级
function RelicController:SendRelicLvUp(id, bag)
	local msg = ReqLevelupRelicItemMsg:new();
	msg.bag = bag;
	msg.id = id;
	MsgManager:Send(msg);
end