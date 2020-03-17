--[[
挖宝
wangshuai
]]

_G.WaBaoController = setmetatable({},{__index=IController});
WaBaoController.name = "WaBaoController";

function WaBaoController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_FindTreasureInfo  ,self,self.OnLinePushData)
	MsgManager:RegisterCallBack(MsgType.SC_FindTreasureResult,self,self.OnWabaoResult);
	MsgManager:RegisterCallBack(MsgType.SC_FindTreasureCancel,self,self.OnWaBaoCancel);
	MsgManager:RegisterCallBack(MsgType.SC_FindTreasureCollect,self,self.OnWaBaoCollect);
end;

function WaBaoController:OnLinePushData(msg)
	--trace(msg)
	--print("有遗留寻宝任务")
	WaBaoModel:SetWaBaoInfo(msg.mapid,msg.mapid2,msg.wabaoId,msg.getlvl,msg.lastNum,msg.lookPoint)
end;

function WaBaoController:OnWabaoResult(msg)
	--trace(msg)
	--print('接取结果')
	if msg.result == 0 then --成功
		WaBaoModel:SetWaBaoInfo(msg.mapid,msg.mapid2,msg.wabaoId,msg.getlvl,msg.lastNum,0)
	else-- 失败
		
	end;
end

function WaBaoController:OnWaBaoCancel(msg)
	--trace(msg)
	--print('接取结果')
	if msg.result == 0 then 
		-- 取消成功
		WaBaoModel:ClaerData()
	end;
end;

function WaBaoController:OnWaBaoCollect(msg)
	--trace(msg)
	--print('采集结果')
	if msg.result == 0 then 
		-- 采集点为真
		if msg.resType == 1 then 
			FloatManager:AddActivity(StrConfig['wabao006']);
			local okfun = function () 
				CollectionController:Collect(msg.resId)
				TimerManager:RegisterTimer(function()
					DropItemController:DoPickUp();
				end, 2000, 2)
			end;
			local cfg = t_collection[msg.resId]
			if not cfg then cfg = {}; end;
			local name = cfg.name or "";
			local id = UIConfirm:Open(string.format(StrConfig["wabao008"],name),okfun);
			TimerManager:RegisterTimer(function()
				okfun();
				UIConfirm:Close(id);
			end, 5000, 1)
		elseif msg.resType == 2 then 
			FloatManager:AddActivity(StrConfig['wabao007']);
			
			local okfun = function () 
				AutoBattleController:OpenAutoBattle();
			end;
			local cfg = t_monster[msg.resId]
			if not cfg then cfg = {}; end;
			local name = cfg.name or "";
			local id = UIConfirm:Open(string.format(StrConfig["wabao008"],name),okfun);
			TimerManager:RegisterTimer(function()
				okfun();
				UIConfirm:Close(id);
			end, 5000, 1)
		end;
		WaBaoModel:ClaerData()
	elseif msg.result == 1 then 
		-- 采集点为假
		FloatManager:AddActivity(StrConfig['wabao002']);
		WaBaoModel:SetWaBaoInfoLookPoint(msg.mapId)
		self:ShowUI()
	end;
end;

---c to  s;
-- 接取挖宝
function WaBaoController:SureWabao(quality)
	local msg = ReqFindTreasureMsg:new();
	msg.quality = quality;
	MsgManager:Send(msg);
	--trace(msg)
	--print("接取挖宝")
end;

--取消接取挖宝
function WaBaoController:CancelWaboa()
	local msg = ReqFindTreasureCancelMsg:new();
	MsgManager:Send(msg)
	--trace(msg)
	--print("取消挖宝")
end;

--确认当前点
function WaBaoController:SurePoint(_type)
	local msg = ReqFindTreasureCollectMsg:new();
	if _type then
		msg.type = 0;
	else
		msg.type = 1;
	end
	MsgManager:Send(msg)
	--trace(msg)
	--print("确认当前点")
end;

function WaBaoController:ShowUI()
	local data = WaBaoModel:GetWaBoaInfo()
	if data.pos1 and data.pos1 ~= 0 then 
		UIWaBaoTwo:Show();
	else
		UIWaBao:Show();
	end;
end;