local ChatDecorate = ChatMgr.ChatDecorate

function ChatDecorate:ApplyDecorate(tbData)
	-- To Do Delete(新包服务器更新后删除)
	if self:IsOldServer() then
		return
	end

	if not tbData or not next(tbData) then
		return 
	end

	if ChatDecorate:GetCurHeadFrame(me) == tbData[ChatDecorate.PartsType.HEAD_FRAME] 
		and ChatDecorate:GetCurBubble(me) == tbData[ChatDecorate.PartsType.BUBBLE] then
		return
	end

	RemoteServer.TryApplyDecorate(tbData)
end

function ChatDecorate:IsOldServer()
	return false
end

function ChatDecorate:TryCheckValid()
	-- To Do Delete(新包服务器更新后删除)
	if self:IsOldServer() then
		return
	end
	if ChatDecorate:CheckValidTime(me) or ChatDecorate:CheckConditionOverdure(me) or ChatDecorate:CheckTimeOverdue(me)  then
		RemoteServer.CheckChatDecorate()	
	end
end

function ChatDecorate:OnDecorateChange()
	if self:IsOldServer() then
		return
	end
	Ui:SetRedPointNotify("Theme")
	Client:SetFlag("nChatDecorate", 1)
end

function ChatDecorate:OnLogin()
	if self:IsOldServer() then
		return
	end
	 Ui:ClearRedPointNotify("Theme")
	local nChatDecorate = Client:GetFlag("nChatDecorate") or 0
	if nChatDecorate == 1 then
		Ui:SetRedPointNotify("Theme")
	end
end

-- 等级红点指引
function ChatDecorate:ChatDecorateGuide(nLevel)
	-- To Do Delete(新包服务器更新后删除)
	if self:IsOldServer() then
		return
	end

	if nLevel == 10 then
		self:OnDecorateChange()
	end
end

-- vip解锁主题红点
function ChatDecorate:OnVipChange(nVipLevel)
	if self:CheckVip(nVipLevel) then
		self:OnDecorateChange()
	end
end

function ChatDecorate:OnPartsReset()
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_THEME_OVERDUE,true)
end

-- 家族宝贝主题红点
function ChatDecorate:ChanePosition(nCareer,nOldCareer)
	if nOldCareer and nOldCareer == Kin.Def.Career_Mascot then
		me.CenterMsg("您的「家族宝贝」头像框已经过期",true)
		-- 职位改变之后手动请求最新的职位信息,因为每次发信息都会在客户端检查是否重置
		self:ApplyKinData()
	elseif nCareer and nCareer == Kin.Def.Career_Mascot then
		self:OnDecorateChange()
	end
end

function ChatDecorate:ApplyKinData()
	if Kin:HasKin() then
		Kin:UpdateMemberCareer()
	end
end