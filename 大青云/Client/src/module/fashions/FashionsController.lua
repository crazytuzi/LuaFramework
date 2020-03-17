--[[
时装衣柜管理
zhangshuhui
2015年1月22日16:57:20
]]
_G.FashionsController = setmetatable({},{__index=IController})
FashionsController.name = "FashionsController";

function FashionsController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_FashionsInfo,self,self.OnFashionsInfoMsg);
	MsgManager:RegisterCallBack(MsgType.SC_DressFashion,self,self.OnDressFashionsRetMsg);
end

---------------------------以下为客户端发送消息-----------------------------
-- 请求装扮时装
function FashionsController:ReqDressFashion(tid, type)
	local msg = ReqDressFashionMsg:new()
	msg.tid = tid;
	msg.type = type;
	MsgManager:Send(msg)
	
	-- print('=========================请求装扮时装')
	-- trace(msg)
end

---------------------------以下为处理服务器返回消息-----------------------------
-- 返回信息
function FashionsController:OnFashionsInfoMsg(msg)
	-- print('=========================返回装扮时装')
	-- trace(msg)
	
	for i,vo in ipairs(msg.fashionlist) do
		if vo and vo.tid > 0 then
			if vo.time == -1 then
				FashionsModel:Updatefashionsforever(vo);
			else
				FashionsModel:Updatefashionslimit(vo);
			end
		end
	end
	
	if FashionsModel.isgetlist == false then
		--限时时装按时间排序
		table.sort(FashionsModel.fashionslimitlist,function(A,B)
			if A.time < B.time then
				return true;
			else
				return false;
			end
		end);
	end
end

-- 返回装扮结果
function FashionsController:OnDressFashionsRetMsg(msg)
	-- print('=========================返回装扮结果')
	-- trace(msg)
	
	if msg.result == 0 then
		FashionsUtil:DressFashions(msg.tid, msg.type);
	end
end

--穿婚礼服
function FashionsController:DressMerryFashions()
	local tid1,tid2,tid3 = FashionsUtil:GetMerryFashions();
	if tid1 > 0 and tid2 > 0 and tid3 > 0 then
		if FashionsModel.fashionsArms ~= tid1 then
			self:ReqDressFashion(tid1, 1);
		end
		if FashionsModel.fashionsDress ~= tid2 then
			self:ReqDressFashion(tid2, 1);
		end
		if FashionsModel.fashionsHead ~= tid3 then
			self:ReqDressFashion(tid3, 1);
		end
	end
end