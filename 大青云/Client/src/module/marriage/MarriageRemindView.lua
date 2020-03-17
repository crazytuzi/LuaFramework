--[[
婚礼时间到，提醒双方
wangshuai
]]

_G.UIMarryRemindV = BaseUI:new("UIMarryRemindV")

function UIMarryRemindV:Create()
	self:AddSWF("marryRemindPanel.swf",true,"center")
end;

function UIMarryRemindV:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;


	objSwf.goBtn.click = function() self:NextStep() end;
	objSwf.btnTael.click = function() self:NextStep() end;

end;

function UIMarryRemindV:NextStep()
	local mapId = CPlayerMap:GetCurMapID();
	local cfg = t_map[mapId];
	if not cfg then return; end
	if cfg.type~=1 and cfg.type~=2 then
		FloatManager:AddNormal(StrConfig['marriage086']);
		return;
	end
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
	UIMarryRemindV:Hide()
	
end;

function UIMarryRemindV:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end;

end;

function UIMarryRemindV:OnHide()

end;

-- 是否缓动
function UIMarryRemindV:IsTween()
	return true;
end

--面板类型
function UIMarryRemindV:GetPanelType()
	return 0;
end
--是否播放开启音效
function UIMarryRemindV:IsShowSound()
	return true;
end

function UIMarryRemindV:IsShowLoading()
	return true;
end