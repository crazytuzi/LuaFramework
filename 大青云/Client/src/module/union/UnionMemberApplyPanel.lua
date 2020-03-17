--[[
帮派:帮派列表面板
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionMemberApply = BaseUI:new("UIUnionMemberApply")
UIUnionMemberApply.clickCreateTime = 0
UIUnionMemberApply.dubleClickTime = 500
function UIUnionMemberApply:Create()
	self:AddSWF("unionMemberApplyPanel.swf", true, nil);
end

function UIUnionMemberApply:OnLoaded(objSwf, name)
	for i=35, 40 do 
		objSwf['labUnion'..i].text = UIStrConfig['union'..i]
	end
	
	objSwf.listPlayer.btnApplyClick = function(e) self:OnBtnAgreeClick(e) end
	objSwf.listPlayer.btnCancelClick = function(e) self:OnBtnRejectClick(e) end
	objSwf.btnAllReject.click = function() self:OnBtnAllReject() end
	objSwf.btnAllAgree.click = function() self:OnBtnAllAgree() end
	objSwf.checkAuto.click = function(e) 
		local lvAuto = objSwf.ddList.selectedIndex+1
		if objSwf.checkAuto.selected then 
			UnionController:ReqSetAutoVerify(1, lvAuto)
		else
			UnionController:ReqSetAutoVerify(0, 0)
		end
	end
	objSwf.ddList.dataProvider:cleanUp();
	for i,vo in ipairs(UnionConsts.AutoAgreeList) do
		objSwf.ddList.dataProvider:push(vo);
	end
	objSwf.ddList.change = function(e) self:OnLevelChange(); end
	objSwf.ddList.rowCount = 5;
	objSwf.ddList.selectedIndex = 0
end

function UIUnionMemberApply:OnShow(name)
	UnionController:ReqMyGuildApplys()
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	--FPrint(UnionModel.MyUnionInfo.autoagree)
	if UnionModel.MyUnionInfo.autoagree and UnionModel.MyUnionInfo.autoagree > 0 then
		--FPrint('UnionModel.MyUnionInfo.autoagree')
		objSwf.checkAuto.selected = true
		objSwf.ddList.selectedIndex = UnionModel.MyUnionInfo.autoagree - 1
	else
		--FPrint('UnionModel.MyUnionInfo.autoagree1')
		objSwf.checkAuto.selected = false
	end
end

--消息处理
function UIUnionMemberApply:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	if name == NotifyConsts.UpdateGuildApplyList then
		self:UpdateApplyList(UnionModel.UnionMemApplyList)
	end
end

-- 消息监听
function UIUnionMemberApply:ListNotificationInterests()
	return {NotifyConsts.UpdateGuildApplyList};
end

------------------------------------------------------------------------------
--									UI事件处理
------------------------------------------------------------------------------

function UIUnionMemberApply:OnLevelChange()
	local objSwf = self.objSwf
	if not objSwf then return; end

	local lvAuto = objSwf.ddList.selectedIndex+1
	if objSwf.checkAuto.selected then 
		UnionController:ReqSetAutoVerify(1, lvAuto)
	end
end

-- 在列表中点同意
function UIUnionMemberApply:OnBtnAgreeClick(e)
	--FPrint(e.item.id)
	local roleId = e.item.id
	if not roleId then return end
	
	if GetCurTime() - self.clickCreateTime > self.dubleClickTime then
		self.clickCreateTime = GetCurTime()
		UnionController:ReqVerifyGuildApply({roleId}, 0)
	end	
end

-- 在列表中点拒绝
function UIUnionMemberApply:OnBtnRejectClick(e)
	--FPrint(e.item.id)
	local roleId = e.item.id
	if not roleId then return end
	
	if GetCurTime() - self.clickCreateTime > self.dubleClickTime then
		self.clickCreateTime = GetCurTime()
		UnionController:ReqVerifyGuildApply({roleId}, 1)
	end
end

function UIUnionMemberApply:OnBtnAllAgree()
	local roleList={}
	for i, v in pairs (UnionModel.UnionMemApplyList) do
		if v.applyFlag == 0 then
			table.push(roleList, v.id)
		end
	end
	
	UnionController:ReqVerifyGuildApply(roleList, 0)
end

function UIUnionMemberApply:OnBtnAllReject()
	local roleList={}
	for i, v in pairs (UnionModel.UnionMemApplyList) do
		if v.applyFlag == 0 then
			table.push(roleList, v.id)
		end
	end
	
	UnionController:ReqVerifyGuildApply(roleList, 1)
end

------------------------------------------------------------------------------
--									UI逻辑
------------------------------------------------------------------------------

-- 更新帮派申请列表
function UIUnionMemberApply:UpdateApplyList(UnionMemApplyList)
	local objSwf = self.objSwf
	if not objSwf then return; end
	if not UnionMemApplyList then return end
	objSwf.listPlayer.dataProvider:cleanUp() 
	for i, unionMemVO in pairs(UnionMemApplyList) do
		objSwf.listPlayer.dataProvider:push( UIData.encode(unionMemVO) )
	end
	objSwf.listPlayer:invalidateData()
end