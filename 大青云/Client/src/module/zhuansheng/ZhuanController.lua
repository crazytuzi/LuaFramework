--[[
祈愿
wangshuai
]]

_G.ZhuanContoller = setmetatable({},{__index=IController});
ZhuanContoller.name = "ZhuanContoller";

function ZhuanContoller:Create()
	-- MsgManager:RegisterCallBack(MsgType.SC_Turnlifeinfo,self,self.Zhuanshinfo);
	-- MsgManager:RegisterCallBack(MsgType.SC_TurnlifeMoney,self,self.ZhuanshMoneyResult);
	-- MsgManager:RegisterCallBack(MsgType.SC_TurnlifeEnter,self,self.ZhuanshEnter);
	-- MsgManager:RegisterCallBack(MsgType.SC_TurnlifeOut,self,self.ZhuanshOut);
	MsgManager:RegisterCallBack(MsgType.SC_TurnlifeStep,self,self.ZhuanStepUpdata)
	MsgManager:RegisterCallBack(MsgType.SC_Turnlifefinish,self,self.ZhuanFinish)   --转生完成

end

local MaxStype = 3;
function ZhuanContoller:ShowOpenView(bo,visible)
	local stype = MainPlayerModel.humanDetailInfo.eaZhuansheng
	stype = stype + 1;
	if stype > MaxStype then 
		if UIZhuanshOpen:IsShow() then 
			UIZhuanshOpen:Hide();
		end;
		if UIZhuanSheng:IsShow() then
			UIZhuanSheng:Hide();
		end;
		return 
	end;
	if bo == true then 
		if not UIZhuanshOpen:IsShow() then 
			UIZhuanshOpen:Show(visible);
		else 
			UIZhuanshOpen:UpdataUiData();
		end;
	else
		if UIZhuanshOpen:IsShow() then 
			UIZhuanshOpen:Hide();
		end;
	end;
end;

function ZhuanContoller:StoryPlayOver()
	if not ZhuanModel:GetZhuanActState() then 
		return 
	end;
	if UIZhuanWindow.isAutoing then 
		UIZhuanWindow:GoStepClick()
	end;
end;

local mat =_Matrix3D.new()
function ZhuanContoller:PlayStoryEffect(effectCfg)
	if not t_position[toint(effectCfg[2])] then return; end
	local t = split(t_position[toint(effectCfg[2])].pos,"|");
	if #t<=0 then return; end
	for index, posVO in pairs(t) do
		local pos = split(posVO,",");
		local eName = "storyEffect"..effectCfg[1]
		local offsetZ = CPlayerMap:GetSceneMap():getSceneHeight(tonumber(pos[2]), tonumber(pos[3]))
		mat:setTranslation(_Vector3.new(tonumber(pos[2]), tonumber(pos[3]), offsetZ))
		local scenePfx = CPlayerMap:GetSceneMap():PlayerPfxByMat(eName, effectCfg[1], mat)
	end
end

-- 换线成功
function ZhuanContoller:OnChangeSceneMap()
	local mapid = CPlayerMap:GetCurMapID();
	local mapCfg = t_map[mapid];
	if mapCfg.heibai == 1 then 
		MainPlayerController:MakeViewGray(true,500)
	else
		MainPlayerController:MakeViewGray(false)
	end;
end;

--转生类型
function ZhuanContoller:Zhuanshinfo(msg)
	--trace(msg)
	--print("转生类型")
	ZhuanModel:SetZhuansType(msg.type);
	Notifier:sendNotification(NotifyConsts.ZhuanshengChange);
end;

--花费转生
function ZhuanContoller:ZhuanshMoneyResult(msg)
	--trace(msg)
	--print("花费转生结果")
	if msg.result == 0 then
		-- 成功
		self:ShowOpenView(true,true)
		FloatManager:AddNormal( StrConfig["zhuansheng001"] );
	elseif msg.result == 1 then 
		--失败
		FloatManager:AddNormal( StrConfig["zhuansheng002"] );
	elseif msg.result == 2 then 
		--元宝不足
		FloatManager:AddNormal( StrConfig["zhuansheng003"] );
	end;
end;

--进入转生
function ZhuanContoller:ZhuanshEnter(msg)
	--trace(msg)
	--print("进入转生结果")
	if msg.result == 0 then 
		MainMenuController:HideRightTop();
		ZhuanModel:SetZhuanActState(true)
	elseif msg.result == -2 then 
		FloatManager:AddNormal( StrConfig["zhuansheng016"] );
	elseif msg.result == -3 then 
		FloatManager:AddNormal( StrConfig["zhuansheng017"] );
	elseif msg.result == -4 then 
		FloatManager:AddNormal( StrConfig["zhuansheng021"] );
	elseif msg.result == -5 then 
		FloatManager:AddNormal( StrConfig["zhuansheng018"] );
	elseif msg.result == -6 then 
		FloatManager:AddNormal( StrConfig["zhuansheng019"] );
	elseif msg.result == -7 then 
		FloatManager:AddNormal( StrConfig["zhuansheng020"] );
	else
		FloatManager:AddNormal( StrConfig["zhuansheng007"] );
	end;
end;

function ZhuanContoller:ZhuanStepUpdata(msg)
	--trace(msg)
	--print("进入转生卧槽，这东西呢-----")
	ZhuanModel:SetZhuanInfo(msg.monsterList,msg.copyId)
	ZhuanModel:SetZhuanActState(true)

	if t_dunstep[msg.copyId] then 
		local cfgd = t_dunstep[msg.copyId];
		if cfgd.dunEffect and cfgd.dunEffect ~= "" then 
			local effectCfg = GetCommaTable(cfgd.dunEffect)
			self:PlayStoryEffect(effectCfg)
		end;
	end;

	if not UIZhuanWindow:IsShow() then 
		UIZhuanWindow:Show()
	else
		UIZhuanWindow:UpdataStep();
	end;
	if UIZhuanSheng:IsShow() then 
		UIZhuanSheng:Hide();
	end;
	if UIZhuanWindow.isAutoing then 
		if msg.copyId == 103002 then 
			--如果id为对话1就不执行自动逻辑，等待mv播放完执行
			return 
		end;
		UIZhuanWindow:GoStepClick()
	end;
end;

--退出转生
function ZhuanContoller:ZhuanshOut(msg)
	--trace(msg)
	--print("退出转生")
	MainMenuController:UnhideRightTop();
	ZhuanModel:SetZhuanActState(false)	
	if UIZhuanWindow:IsShow() then 
		UIZhuanWindow:Hide();
	end;
end;

--完成转生
function ZhuanContoller:ZhuanFinish(msg)
	if UIZhuanWindow:IsShow() then 
		UIZhuanWindow:Hide();
		if not UIZhuanResult:IsShow() then 
			local sCfg = t_zhuansheng[ZhuanModel:GetZhuanType()]
			if not sCfg then 
				sCfg = {};
				sCfg.endtime = 14;
			end;
			TimerManager:RegisterTimer(function()
				UIZhuanResult:Show();
				self:ShowOpenView(true,true)
			end, sCfg.endtime, 1)
		end;
	end;
end;

--------
function ZhuanContoller:ReqDungeonNpCTalkEnd()
	local msg = ReqDungeonNpcTalkEndMsg:new()
	msg.step = ZhuanModel:GetZhuanCopyid()
	MsgManager:Send(msg)
end

function ZhuanContoller:MoneyZhuan()
	local msg = ReqTurnlifeMoneyMsg:new();
	MsgManager:Send(msg);
	--print("请求花费转生--------")
end;

function ZhuanContoller:EnterZhuan()
	local msg = ReqTurnlifeEnterMsg:new();
	MsgManager:Send(msg)
	--print("进入转生")
end;

function ZhuanContoller:OutZhuan()
	local msg = ReqTurnlifeOutMsg:new()
	MsgManager:Send(msg)
	--print("退出转生")
end;

