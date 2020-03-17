--[[
灵力徽章管理
zhangshuhui
2015年5月13日11:09:16
]]
_G.LingLiHuiZhangController = setmetatable({},{__index=IController})
LingLiHuiZhangController.name = "LingLiHuiZhangController";

function LingLiHuiZhangController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_HuiZhangInfo,self,self.OnHuiZhangInfoResult);
	MsgManager:RegisterCallBack(MsgType.SC_HuiZhangPractice,self,self.OnHuiZhangPracticeRet);
	MsgManager:RegisterCallBack(MsgType.SC_BreakHuiZhang,self,self.OnBreakHuiZhangRet);
	
	MsgManager:RegisterCallBack(MsgType.SC_HuiZhangJuLingInfo,self,self.OnHuiZhangJuLingRet);
	MsgManager:RegisterCallBack(MsgType.SC_GetJuLing,self,self.OnGetJuLingRet);
	MsgManager:RegisterCallBack(MsgType.SC_KillGetLingLiInfo,self,self.OnKillGetLingLiInfo);
end

---------------------------以下为客户端发送消息-----------------------------
-- 请求徽章注灵
function LingLiHuiZhangController:ReqHuiZhangPractice(type)
	local msg = ReqHuiZhangPracticeMsg:new()
	msg.type = type;
	MsgManager:Send(msg)
	
	-- print('===============请求徽章注灵')
	-- trace(msg)
end

-- 请求突破徽章
function LingLiHuiZhangController:ReqBreakHuiZhang()
	local msg = ReqBreakHuiZhangMsg:new()
	MsgManager:Send(msg)
	
	-- print('===============请求突破徽章')
	-- trace(msg)
end

-- 请求聚灵收益
function LingLiHuiZhangController:ReqGetJuLing()
	local msg = ReqGetJuLingMsg:new()
	MsgManager:Send(msg)
	
	-- print('===============请求聚灵收益')
	-- trace(msg)
end

---------------------------以下为处理服务器返回消息-----------------------------
-- 返回徽章信息
function LingLiHuiZhangController:OnHuiZhangInfoResult(msg)
	-- print('===============返回徽章信息')
	-- trace(msg)
	
	LingLiHuiZhangModel:SetHuiZhangOrder(msg.huizhangOrder);
	LingLiHuiZhangModel:SetFreeNum(msg.freeNum);
	LingLiHuiZhangModel:SetJuLingCount(msg.linglinum);
	LingLiHuiZhangModel:SetKillLingLiNum(msg.killlinglinum);
	
	local list = {};
	for i,voattr in pairs(msg.attrlist) do
		local vo = {};
		vo.type = voattr.type;
		vo.val = voattr.value;
		table.push(list,vo);
	end
	LingLiHuiZhangModel:SetAttrList(list);
	
	--聚灵右下角提示
	if LingLiHuiZhangUtil:GetIsOverpercent() == true then
		--UIItemGuide:Open(11, string.format(StrConfig["linglihuizhang40"],LingLiHuiZhangModel:GetJuLingCount()));
	end
	
	--启动定时器,每600秒检测一次聚灵满时右下角提示
	TimerManager:RegisterTimer(function()
		if LingLiHuiZhangUtil:GetIsFull() then
			--UIItemGuide:Open(11, string.format(StrConfig["linglihuizhang40"],LingLiHuiZhangModel:GetJuLingCount()));
		end
	end,600000,0);
end

--返回徽章注灵结果
function LingLiHuiZhangController:OnHuiZhangPracticeRet(msg)
	-- print('===============返回徽章注灵结果')
	-- trace(msg)
	
	if msg.result == 0 then
		if msg.type == 1 then
			local freenum = LingLiHuiZhangModel:GetFreeNum();
			if freenum < LingLiHuiZhangUtil:GetAllFreeNum() then
				LingLiHuiZhangModel:SetFreeNum(freenum + 1);
			end
		end
		
		local list = {};
		for i,voattr in pairs(msg.attrlist) do
			local vo = {};
			vo.type = voattr.type;
			vo.val = voattr.value;
			table.push(list,vo);
		end
		LingLiHuiZhangModel:UpdateAttrList(list);
		
		
	end
end

--返回徽章突破结果
function LingLiHuiZhangController:OnBreakHuiZhangRet(msg)
	-- print('===============返回徽章突破结果')
	-- trace(msg)
	
	if msg.result == 0 then
		local curOrder = LingLiHuiZhangModel:GetHuiZhangOrder();
		LingLiHuiZhangModel:SetHuiZhangUpOrder(curOrder + 1)
		
		--播放升阶音效
		SoundManager:PlaySfx(2030);
	end
end

--聚灵信息通知
function LingLiHuiZhangController:OnHuiZhangJuLingRet(msg)
	-- print('===============聚灵信息通知')
	-- trace(msg)
	
	local curlingcount = LingLiHuiZhangModel:GetJuLingCount();
	LingLiHuiZhangModel:SetJuLingCount(curlingcount + msg.linglinum);
	
	--聚灵右下角提示
	if LingLiHuiZhangUtil:GetIsOverpercent() == true then
		--UIItemGuide:Open(11, string.format(StrConfig["linglihuizhang40"],LingLiHuiZhangModel:GetJuLingCount()));
	end
end

--返回聚灵收益结果
function LingLiHuiZhangController:OnGetJuLingRet(msg)
	-- print('===============返回聚灵收益结果')
	-- trace(msg)
	
	if msg.result == 0 then
		LingLiHuiZhangModel:SetJuLingCount(0);
		Notifier:sendNotification(NotifyConsts.GetShouYiUpdate);
		FloatManager:AddNormal( StrConfig["linglihuizhang42"]);
		--播放领取收益音效
		SoundManager:PlaySfx(2033);
	end
end

--击杀怪物得到灵力
function LingLiHuiZhangController:OnKillGetLingLiInfo(msg)
	-- print('===============击杀怪物得到灵力')
	-- trace(msg)
	
	LingLiHuiZhangModel:SetKillLingLiNum(msg.killlinglinum);
end
