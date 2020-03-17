--[[
	2015年10月19日15:49:54
	wangyanwei
	礼包卡片WTF一系列礼包
]]

_G.GiftsController = setmetatable({},{__index=GiftsController});
GiftsController.name = "GiftsController";

function GiftsController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_ItemCardResult,self,self.OnItemCardResult);
end

function GiftsController:OnItemCardResult(msg)
	local result = msg.result ;
	if result == 0 then
		UIUpGradeStoneCard:Hide();
	elseif result == -1 then
		FloatManager:AddNormal( StrConfig['stone111'] )
	elseif result == -2 then
		FloatManager:AddNormal( StrConfig['stone112'] )
	elseif result == -3 then
		FloatManager:AddNormal( StrConfig['stone113'] )
	elseif result == -4 then
		FloatManager:AddNormal( StrConfig['stone114'] )
	elseif result == -5 then
		FloatManager:AddNormal( StrConfig['stone115'] )
	elseif result == -7 then
		FloatManager:AddNormal( StrConfig['stone117'] )
	end
end


--C TO S
function GiftsController:SendOpenItemCard(guid,_type)
	local msg = ReqOpenItemCardMsg:new();
	msg.itemCardID = guid;
	msg.type = _type;
	MsgManager:Send(msg);
end