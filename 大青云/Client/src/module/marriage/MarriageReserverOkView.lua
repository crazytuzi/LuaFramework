--[[
求婚成功界面
wangshuai
]]

_G.UIMarryReserverOk = BaseUI:new("UIMarryReserverOk")

function UIMarryReserverOk:Create()
	self:AddSWF("marryReserveOk.swf",true,"center")
end;

function UIMarryReserverOk:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;

	objSwf.ringItem.rollOver = function() self:OnRingOver() end;
	objSwf.ringItem.rollOut  = function() TipsManager:Hide() end;

	objSwf.surebtn.click = function() self:NextStep() end;

end;

function UIMarryReserverOk:NextStep()

	local mapCfg = MapPoint[10200001];
	local npcVo = {};
	for i,info in pairs(mapCfg.npc) do 
		if info.id == MarriageConsts.NpcYuelao then 
			npcVo = info;
		end;
	end;
	local completeFuc = function()
		NpcController:ShowDialog(MarriageConsts.NpcYuelao);
	end;
	MainPlayerController:DoAutoRun(10200001,_Vector3.new(npcVo.x,npcVo.y,0),completeFuc)
	UIMarryReserverOk:Hide()
	
end;

function UIMarryReserverOk:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	self.data = MarriageModel.ProposaledData;
	if not self.data then return end;

	objSwf.icon1.source = ResUtil:GetHeadIcon(self.data.naProf);
	objSwf.icon2.source = ResUtil:GetHeadIcon(self.data.nvProf);


	local cfg = t_marryRing[self.data.ringId]
	if not cfg then return end;
	local itemvo = RewardSlotVO:new()
	itemvo.id = cfg.itemId
	itemvo.count = 0
	objSwf.ringItem:setData(itemvo:GetUIData());
	
	objSwf.eff1:gotoAndPlay(1);
	objSwf.eff2:gotoAndPlay(1);
	objSwf.eff3:gotoAndPlay(1);
	objSwf.eff4:gotoAndPlay(1);
	objSwf.eff5:gotoAndPlay(1);
end;

function UIMarryReserverOk:OnHide()

end;

function UIMarryReserverOk:OnRingOver()
	if not self.data or self.data.ringId == 0 then 
		return 
	end;
	local cfg = t_marryRing[self.data.ringId]
	if not cfg then return end;
	TipsManager:ShowItemTips(cfg.itemId);
end;

-- 是否缓动
function UIMarryReserverOk:IsTween()
	return true;
end

--面板类型
function UIMarryReserverOk:GetPanelType()
	return 0;
end
--是否播放开启音效
function UIMarryReserverOk:IsShowSound()
	return true;
end

function UIMarryReserverOk:IsShowLoading()
	return true;
end