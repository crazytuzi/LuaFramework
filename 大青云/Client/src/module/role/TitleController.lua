--[[
	称号控制面板
	2014年11月24日, PM 01:57:42
	wangyanwei
]]
_G.TitleController = setmetatable({},{__index=IController})

TitleController.name="TitleController";

function TitleController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_TitleBackInfo,self,self.OnBackTitleInfo);	--返回的称号信息
	MsgManager:RegisterCallBack(MsgType.SC_TitleGetTitleInfo,self,self.OnGetTitleInfo);	--返回的称号信息
end
---------------------------------客户端发送-------------------------------------

-- 穿戴|脱下称号
function TitleController:OnEquipTitle(obj)
	local msg = ReqTitleEpuipMsg:new();
	msg.id = obj.id;
	msg.state = obj.state;
	MsgManager:Send(msg);
end

---------------------------------服务器返回-------------------------------------

--返回的称号信息
function TitleController:OnBackTitleInfo(msg)
	local titleListVO = msg.list;
	TitleModel:OnUpDataTitleInfo(titleListVO);
	TitleModel:Create();
end

--获得或者被动删除称号信息
function TitleController:OnGetTitleInfo(msg)
	local titleListVO = msg;
	print('获得或者删除称号 tim：-1  获得永久')
	-- trace(msg);
	TitleModel:OnGetTitleBcakInfo(titleListVO);
	TitleModel:Create();
end