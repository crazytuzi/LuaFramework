--[[
打宝活力值Controller
2015年1月22日17:08:37
haohu
]]

_G.DropValueController = setmetatable( {}, {__index = IController} );
DropValueController.name = "DropValueController";

function DropValueController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_SetDynamicDrop, self, self.OnSetDynamicDrop );
	MsgManager:RegisterCallBack( MsgType.SC_DynamicDropItems, self, self.OnDynamicDropItemsReply );
end

------------------------------response-----------------------------
function DropValueController:OnSetDynamicDrop( msg )
	local level = msg.level;
	DropValueModel:SetDropValueLevel(level);
end

function DropValueController:OnDynamicDropItemsReply( msg )
	local flag = msg.flag;
	local items = msg.dropItems;
	if flag == 0 then -- 新增掉宝
		DropValueModel:AddDropItems( items );
		if FuncManager:GetFuncIsOpen( FuncConsts.DropVal ) then
			RemindController:AddRemind( RemindConsts.Type_DropItem, 1 );
		end
	elseif flag == 1 then -- 本次登录全部掉宝
		DropValueModel:SetDropItems( items );
	end
end

------------------------------request-----------------------------
function DropValueController:SetDynamicDrop( level )
	local msg = ReqSetDynamicDropMsg:new();
	msg.level = level;
	MsgManager:Send(msg);
end

function DropValueController:ReqDropItems()
	local msg = ReqDynamicDropItemsMsg:new();
	MsgManager:Send(msg);
end