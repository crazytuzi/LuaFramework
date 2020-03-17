--[[
帮派:未创建主面板
liyuan
2014年9月24日16:22:09
]]


_G.UIUnionUnCreate = BaseUI:new("UIUnionUnCreate")
UIUnionUnCreate.searchList = {}
UIUnionUnCreate.searchType = nil
UIUnionUnCreate.curPage = 1
UIUnionUnCreate.totalPage = 1
function UIUnionUnCreate:Create()
	self:AddSWF("unionUnCreatePanel.swf", true, "center")
end

function UIUnionUnCreate:OnLoaded(objSwf, name)
	for i=52, 58 do 
		objSwf['labUnion'..i].text = UIStrConfig['union'..i]
	end
	-- objSwf.labTip.text = string.format(UIStrConfig['union47'], t_consts[15].val1)
	
	self.searchList = {}
	table.push(self.searchList, UnionConsts.SearchTypeUnionName)
	table.push(self.searchList, UnionConsts.SearchTypeMasterName)
	objSwf.ddList.dataProvider:cleanUp();
	for i,vo in ipairs(self.searchList) do
		objSwf.ddList.dataProvider:push(vo.searchName);
	end
	objSwf.ddList.change = function(e) self:OnDDListCick(e); end
	objSwf.ddList.rowCount = 2;
	objSwf.ddList.selectedIndex = 0
	self.searchType = self.searchList[objSwf.ddList.selectedIndex+1].searchType;
	
	objSwf.inputSearch.textChange = function() self:OnUnionSearchChange(); end
	
	objSwf.btnPre.click = function() self.curPage = self.curPage - 1 self:GetCurrentPage() end
	objSwf.btnPre1.click = function() self.curPage = 1 self:GetCurrentPage() end
	objSwf.btnNext.click = function() self.curPage = self.curPage + 1 self:GetCurrentPage() end
	objSwf.btnNext1.click = function() self.curPage = self.totalPage self:GetCurrentPage() end
	
	objSwf.listUnion.btnApplyClick = function(e) self:OnBtnApplyClick(e) end
	objSwf.listUnion.btnViewClick = function(e) self:OnBtnViewClick(e) end
	objSwf.listUnion.btnCancelClick = function(e) self:OnBtnCancelClick(e) end
	objSwf.listUnion.btnGMClick = function(e) self:OnBtnGMClick(e); end
	
	-- objSwf.btnCreate.click = function() UIUnionCreateDialog:Show() end
	objSwf.ckAutoAgree.select = function(e) self:OnCkAutoAgreeSelect(e) end
	objSwf.btnRefresh.click = function() self:GetCurrentPage() end
	objSwf.btnSearch.click = function() self:Search() end
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
	objSwf.btnCreate.click = function() UIUnionCreateDialog:Show() end
	-- objSwf.btnJion.click = function() UIUnionCreate:Show() end
end
function UIUnionUnCreate:OnShow(name)
	self:GetCurrentPage()
	
	self:OnLevelUp()
end

function UIUnionUnCreate:OnHide()
	UIUnionInfoDialog:Hide()
end

--消息处理
function UIUnionUnCreate:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if name == NotifyConsts.StageClick then
		local ipSearchTarget = string.gsub(objSwf.inputSearch._target,"/",".");
		local ipSearchTarget1 = string.gsub(objSwf.btnSearch._target,"/",".");
		if string.find(body.target,ipSearchTarget) or string.find(body.target,ipSearchTarget1) then
			return;
		end
		self:OnIpSearchFocusOut()
	elseif name == NotifyConsts.StageFocusOut then
		self:OnIpSearchFocusOut()
	elseif name == NotifyConsts.UnionListUpdate then
		self:ShowUnionList(UnionModel.UnionsList, body.pages)
	elseif name == NotifyConsts.ApplyGuildResult then
		self:ApplyGuildResult()
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:OnLevelUp();
		end
	end
end

-- 消息监听
function UIUnionUnCreate:ListNotificationInterests()
	return {NotifyConsts.StageClick,
			NotifyConsts.StageFocusOut,
			NotifyConsts.UnionListUpdate,
			NotifyConsts.ApplyGuildResult,
			NotifyConsts.PlayerAttrChange};
end
--面板类型
function UIUnionUnCreate:GetPanelType()
	return 1;
end
------------------------------------------------------------------------------
--									UI事件处理
------------------------------------------------------------------------------
-- 在列表中点申请
function UIUnionUnCreate:OnBtnApplyClick(e)
	local guildId = e.item.guildId
	if not guildId then return end
	self:RecoardTipPos(e.renderer.btnApply)
	UnionController:ReqApplyGuild(guildId, 1)
end

-- 在列表中点取消
function UIUnionUnCreate:OnBtnCancelClick(e)
	local guildId = e.item.guildId
	if not guildId then return end
	self:RecoardTipPos(e.renderer.btnCancel)
	UnionController:ReqApplyGuild(guildId, 0)
end

function UIUnionUnCreate:OnBtnGMClick(e)
	local guildId = e.item.guildId;
	if not guildId then return; end
	GMController:GetGMGuildInfo(guildId);
end

function UIUnionUnCreate:RecoardTipPos(mc)
	if not mc then
		self.TipPos = _sys:getRelativeMouse();
	else
		self.TipPos = UIManager:PosLtoG(mc,mc._width/2,0)
	end
end

-- 在列表中点查看
function UIUnionUnCreate:OnBtnViewClick(e)
	local guildId = e.item.guildId
	if not guildId then return end
	
	if UIUnionInfoDialog:IsShow() then  
		UIUnionInfoDialog:ShowUnionInfo(guildId,  e.item.applyFlag)
	else
		UIUnionInfoDialog:Open(guildId,  e.item.applyFlag)
	end
end

function UIUnionUnCreate:OnCkAutoAgreeSelect(e)
	-- self:ChangeCfg( "autoHang", e.selected );
	self.curPage = 1
	self:GetCurrentPage()
end

--输入文本失去焦点
function UIUnionUnCreate:OnIpSearchFocusOut()
	local objSwf = self.objSwf
	if not objSwf then return; end
	if objSwf.inputSearch.focused then
		objSwf.inputSearch.focused = false;
	end
end

--选择搜索类型
function UIUnionUnCreate:OnDDListCick(e)
	if self.searchList[e.index+1] then
		self.searchType = self.searchList[e.index+1].searchType
	end
end
------------------------------------------------------------------------------
--									UI逻辑
------------------------------------------------------------------------------

-- 请求当前页的列表
function UIUnionUnCreate:GetCurrentPage()
	local objSwf = self.objSwf
	if not objSwf then return end
	local onlyAgree = 0
	if objSwf.ckAutoAgree.selected then
		onlyAgree = 1
	end
	
	if self.curPage < 1 then self.curPage = 1 FPrint('请求联盟列表页数小于1'..self.curPage..'/'..self.totalPage) end
	if self.curPage > self.totalPage then self.curPage = self.totalPage FPrint('请求联盟列表页数大于总页数'..self.curPage..'/'..self.totalPage) end
	
	UnionController:ReqGuildList(self.curPage, onlyAgree)
end

function UIUnionUnCreate:Search()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local stype = objSwf.ddList.selectedIndex
	
	if objSwf.inputSearch.text == '' or objSwf.inputSearch.text == objSwf.inputSearch.defaultText then FloatManager:AddSysNotice(2005022); return end --当前搜索内容为空或不存在
	
	UnionController:ReqSearchGuild(stype, objSwf.inputSearch.text)
end

-- 获得当前页数据 更新帮派列表
function UIUnionUnCreate:ShowUnionList(guildList, pages)
	local objSwf = self.objSwf
	if not objSwf then return end

	if not guildList then return end

	objSwf.listUnion.dataProvider:cleanUp() 
	for i, guildVO in pairs(guildList) do
		local extendNum = guildVO.extendNum or 0
		guildVO.maxMemCnt = UnionUtils:GetUnionMemMaxNum(guildVO.level) + extendNum
		guildVO.isGM = GMModule:IsGM();
		objSwf.listUnion.dataProvider:push( UIData.encode(guildVO) )
	end
	objSwf.listUnion:invalidateData()
	
	self:UpdatePageBtnState(pages)
end

function UIUnionUnCreate:ApplyGuildResult()
	
end

function UIUnionUnCreate:OnUnionSearchChange()
	
end

-- 更新翻页按钮状态
function UIUnionUnCreate:UpdatePageBtnState(totalPage)
	if totalPage == -1 then return end
	
	local objSwf = self.objSwf
	if not objSwf then return end
	
	self.totalPage = totalPage
	
	objSwf.btnNext1.disabled = false	
	objSwf.btnPre1.disabled = false
	objSwf.btnPre.disabled = false
	objSwf.btnNext.disabled = false
	if self.curPage <= 1 then
		self.curPage = 1
		objSwf.btnPre.disabled = true
		objSwf.btnPre1.disabled = true
	end
	
	if self.curPage >= totalPage then
		self.curPage = totalPage
		objSwf.btnNext.disabled = true
		objSwf.btnNext1.disabled = true
	end
	
	objSwf.txtPage.text = self.curPage..'/'..self.totalPage
end

function UIUnionUnCreate:OnLevelUp()
	local objSwf = self.objSwf
	if not objSwf then return end

	local mainPlayerLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	--只有达到解锁等级后创建帮派
	if mainPlayerLevel >= t_consts[15].val1 then 
		-- objSwf.btnCreate.disabled = false
	else
		-- objSwf.btnCreate.disabled = true
	end
end


function UIUnionUnCreate:GetWidth(name)
	return 1146
end

function UIUnionUnCreate:GetHeight(name)
	return 687
end

function UIUnionUnCreate:IsTween()
	return true
end

function UIUnionUnCreate:OnBtnCloseClick()
	self:Hide()
end
function UIUnionUnCreate:IsShowSound()
	return true;
end

function UIUnionUnCreate:IsShowLoading()
	return true;
end