--[[
	神炉模块
]]
_G.StoveController = setmetatable({},{__index=IController})
StoveController.name = "StoveController"

StoveController.outLookTid = 0;
function StoveController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_HuDunProgress,self,self.OnHuDunProgressResponse);-- 返回护盾增加进度结果
	MsgManager:RegisterCallBack(MsgType.SC_HuDunAutoUp,self,self.OnHuDunAutoUpResponse);-- 返回护盾一键灌注结果
	MsgManager:RegisterCallBack(MsgType.SC_HuDunInfo,self,self.OnHuDunInfoResponse);-- 返回护盾信息
	MsgManager:RegisterCallBack(MsgType.SC_SetShenLuOutLook,self,self.OnSetShenLuOutLook);-- 在面板设置外显时候的返回
	MsgManager:RegisterCallBack(MsgType.SC_ShenLuOutLookInfo,self,self.OnShenLuOutLookInfo);-- 登录返回的外显信息，用于面板显示用

end

function StoveController:ReqOutLook(type, level, enabled)
	local msg = ReqSetShenLuOutLook:new();
	msg.type = type;
	msg.lv = level;
	if enabled then
		msg.operation = 1;
	else
		msg.operation = 0;
	end
	MsgManager:Send(msg);
end

function StoveController:OnSetShenLuOutLook(msg)
	if msg.result == 0 then
		if msg.type == StovePanelView.XUANBING then
			if msg.operation == 1 then
				self.outLookTid = StoveUtil:GetStoveTid(msg.type, msg.lv);
				MainPlayerController:GetPlayer():SetXuanBingModelId(self.outLookTid);
			else
				self.outLookTid = 0;
				MainPlayerController:GetPlayer():SetXuanBingModelId(0);
			end
		end
	end
end

function StoveController:OnShenLuOutLookInfo(msg)
	for k, v in pairs(msg.list) do
		if v.type == StovePanelView.XUANBING then
			if v.set_on == 1 then
				self.outLookTid = v.tid;
			end
		end
	end
end

function StoveController:RequestHuDunProgress(tid, itemid)
	local msg = ReqHuDunProgress:new();
	msg.tid = tid;
	msg.itemid = itemid;
	MsgManager:Send(msg);
end

function StoveController:RequestHuDunAutoUp(tid)
	local msg = ReqHuDunAutoUp:new();
	msg.tid = tid;
	MsgManager:Send(msg);
end

function StoveController:OnHuDunProgressResponse(msg)
	if msg.result == 0 then
		EquipModel:SetStoveInfo(msg.tid, msg.level, msg.value, msg.star);
		StovePanelView:UpdateViewOnResponseInfo();
		--[[
		if UIPerfusionSubPanelView:IsShow() then
			StovePanelView:ShowNextInfoView();
		end
		]]
	end
	if msg.result == -4 then
		FloatManager:AddNormal(StrConfig["stove1000"]);
	end

end

function StoveController:OnHuDunAutoUpResponse(msg)
	if msg.result == 0 then
		EquipModel:SetStoveInfo(msg.tid, msg.level, msg.value, msg.star);
		StovePanelView:UpdateViewOnResponseInfo();
		--[[
		if UIPerfusionSubPanelView:IsShow() then
			StovePanelView:ShowNextInfoView();
		end
		]]
	end
	if msg.result == -4 then
		FloatManager:AddNormal(StrConfig["stove1000"]);
	end
end

function StoveController:OnHuDunInfoResponse(msg)
	-- 登录的时候返回神炉的信息，将这些信息放入EquipModel中进行整理存放
	local list = msg.list;
	if not list then return end
	for k,v in ipairs(list) do
		EquipModel:SetStoveInfo(v.tid, v.step, v.value, v.star)
	end
end
--是否可以激活或者进阶神炉 通过下面类型判断
--[[
StovePanelView.XUANBING = 0;
StovePanelView.BAOJIA = 1;
StovePanelView.MINGYU = 2;
  ]]
function StoveController:IsCanProgress(type)
	local stoveVO = EquipModel:GetStoveInfoVOByType(type);
	if not stoveVO then return false; end
	local currentLevel = stoveVO.currentLevel;
	local currentStar = stoveVO.currentStar;
	if currentLevel >= StovePanelView.MAX_LEVEL and currentStar >= StovePanelView.MAX_STAR then
		return false;
	end
	local result = false;
	local playerinfo = MainPlayerModel.humanDetailInfo;
	for k, v in pairs(t_stoveplay) do
		if v.type == type and v.level == currentLevel then
			local needItemList = StoveUtil:GetStoveNeedItemList(type, currentLevel);
			local costStr = StoveUtil:GetStoveCostItem(type, currentLevel);
			local costItemID = tonumber(costStr[1]);
			local costItemCount = tonumber(costStr[2]);
			for itemK, itemV in pairs(needItemList) do
				if BagModel:GetItemNumInBag(tonumber(itemV)) > 0 and playerinfo[costItemID] >= costItemCount then
					result = true; --有这个道具
					break;
				end
			end
			break;
		end
	end
	return result;
end
--能否进阶一整颗星或者一次激活
--[[
StovePanelView.XUANBING = 0;
StovePanelView.BAOJIA = 1;
StovePanelView.MINGYU = 2;
  ]]
function StoveController:IsCanProgressOnStar(type)
	local stoveVO = EquipModel:GetStoveInfoVOByType(type);
	if not stoveVO then return false; end
	local currentLevel = stoveVO.currentLevel;
	local currentProgress = stoveVO.currentProgress;
	local currentStar = stoveVO.currentStar;
	if currentLevel >= StovePanelView.MAX_LEVEL and currentStar >= StovePanelView.MAX_STAR then
		return false;
	end
	local result = false;
	local playerinfo = MainPlayerModel.humanDetailInfo;
	for k, v in pairs(t_stoveplay) do
		if v.type == type and v.level == currentLevel then
			local needItemList = StoveUtil:GetStoveNeedItemList(type, currentLevel);
			local costStr = StoveUtil:GetStoveCostItem(type, currentLevel);
			local costItemID = tonumber(costStr[1]);
			local costItemCount = tonumber(costStr[2]);
			for itemK, itemV in pairs(needItemList) do
				local needItemID = toint(itemV);
				local itemProgress = t_stoveitem[needItemID].value;
				local progressCount = math.ceil((v.plan - currentProgress) / itemProgress)
				if BagModel:GetItemNumInBag(needItemID) >= progressCount and playerinfo[costItemID] >= costItemCount * progressCount then
					result = true;
					break;
				end
			end
			break;
		end
	end
	return result;
end