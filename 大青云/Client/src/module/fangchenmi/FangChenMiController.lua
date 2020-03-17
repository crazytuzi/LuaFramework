--[[
防沉迷管理
zhangshuhui
2015年3月25日16:57:20
]]
_G.FangChenMiController = setmetatable({},{__index=IController})
FangChenMiController.name = "FangChenMiController";

function FangChenMiController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_FangChenMi,self,self.OnFangChenMiMsg);
	MsgManager:RegisterCallBack(MsgType.SC_FangChenMiBiaoJi,self,self.OnFangChenMiBiaoJiMsg);
end

---------------------------以下为处理服务器返回消息-----------------------------
-- 返回信息
function FangChenMiController:OnFangChenMiMsg(msg)
	-- print('========================返回防沉迷在线时间')
	-- trace(msg)
	UIFangChenMiView:OpenPanel(msg.onlinetime);
end

-- 返回标记
function FangChenMiController:OnFangChenMiBiaoJiMsg(msg)
	-- print('========================返回防沉迷标记')
	-- trace(msg)
	if msg.is_adult == 0 then
		UIFangChenMiView:OpenPanel();
	end
end