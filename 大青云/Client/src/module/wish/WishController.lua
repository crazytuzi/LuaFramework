--[[
祈愿
wangshuai
]]

_G.WishController = setmetatable({},{__index=IController});
WishController.name = "WishController";

function WishController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_WishInfoUpdata,self,self.WishInfoUpdata);
	MsgManager:RegisterCallBack(MsgType.SC_WishInfoResult,self,self.WishInfoResult);
end

function WishController:WishInfoUpdata(msg)
	for i,info in ipairs(msg.list) do 
		WishModel:Updatainfo(info.id,info.lastnum,info.withnum)
	end;
	Notifier:sendNotification(NotifyConsts.WishInfoUpdata);
end;

function WishController:WishInfoResult(msg)
	if msg.result == 0 then 
		if msg.type == enAttrType.eaExp then 
			FloatManager:AddNormal( StrConfig["wish005"] );
		elseif msg.type == enAttrType.eaZhenQi then 
			FloatManager:AddNormal( StrConfig["wish003"] );
		elseif msg.type == enAttrType.eaBindGold then 
			FloatManager:AddNormal( StrConfig["wish004"] );
		end;
	end;
end;

function WishController:WishBuy(id)
	local info = WishModel:GetWishInfo(id)
	if info.lastnum <= 0 then 
		-- 次数不够
		FloatManager:AddNormal( StrConfig["wish001"] );
		return 
	end;
	local myYuanbao =  MainPlayerModel.humanDetailInfo.eaUnBindMoney
	local needYuanBao = WishModel:GetConsumptionYuanBao(id);
	if needYuanBao > myYuanbao then 
		-- 元宝不足
		FloatManager:AddNormal( StrConfig["wish002"] );
		return 
	end;

	local Type = -1;
	if id == enAttrType.eaExp then 
		Type = 0
	elseif id == enAttrType.eaZhenQi then 
		Type = 1
	elseif id == enAttrType.eaBindGold then 
		Type = 2
	end;

	local msg = ReqStarOperMsg:new()
	msg.type = Type
	MsgManager:Send(msg)
end;
