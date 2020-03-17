--[[
帮派:帮派列表面板
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionMemberList = BaseUI:new("UIUnionMemberList")
UIUnionMemberList.sortList = nil--true升序false降序
function UIUnionMemberList:Create()
	self:AddSWF("unionMemberListPanel.swf", true, nil);
end

function UIUnionMemberList:OnLoaded(objSwf, name)
	for i=23, 29 do 
		objSwf['labUnion'..i].text = UIStrConfig['union'..i]
	end
	
	objSwf.listPlayer.itemClick = function(e) self:OnMemberListClick(e) end
	objSwf.btnDispose.click = function() 
		UIConfirm:Open(StrConfig['union12'], function() 
			UIConfirm:Open(StrConfig['union13'], function() 
				UnionController:ReqDismissGuild()
			end, nil, StrConfig['union70'])
		end, nil, UIStrConfig['union31'], UIStrConfig['union81'])
	end
	objSwf.btnYaoqing.click = function() 
		if self.noticeTimeKey then
			FloatManager:AddNormal(StrConfig["union76"])
			return
		end
		self.noticeTimeKey = TimerManager:RegisterTimer(function()
			TimerManager:UnRegisterTimer(self.noticeTimeKey);
			self.noticeTimeKey= nil;
		end,1800000);
		ChatController:OnSendCWWorldNotice(ChatConsts.WorldNoticeUnion);
	end
	objSwf.btnExit.click = function()  
		if UnionModel.MyUnionInfo.pos == UnionConsts.DutyLeader  then
			UIConfirm:Open(StrConfig['union15'], function() 
				UnionController:ReqQuitGuild()
			end, nil, StrConfig['union70'])
		else
			UIConfirm:Open(StrConfig['union14'], function() 
				UnionController:ReqQuitGuild()
			end, nil, StrConfig['union24'])
		end
	end
	for i = 1, 7 do
		if objSwf['btnSort'..i] then
			objSwf['btnSort'..i].click = function()
				if not self.sortList then
					self.sortList = {}
				end
				
				if self.sortList[i] then
					self.sortList[i] = false
				else
					self.sortList[i] = true
				end
				
				if self.sortList[i] then
					UnionModel:SortUnionMemberList(i)
				else
					UnionModel:SortUnionMemberList(i..1)
				end
			end
		end
	end
	objSwf.ckOnlyOnline.select = function(e) self:OnCkOnlyOnlineSelect(e) end
	objSwf.btnTanhe.click = function() UIUnionTanheDialog:Show() end
	objSwf.btnTanhe.rollOver = function() TipsManager:ShowBtnTips(StrConfig["union79"],TipsConsts.Dir_RightDown); end
	objSwf.btnTanhe.rollOut  = function() TipsManager:Hide() end
end

function UIUnionMemberList:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	UnionController:ReqMyGuildMems()
	self:UpdatePermission()	
	
	
end


--消息处理
function UIUnionMemberList:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self:GetSWF("UIUnionMemberList")
	if not objSwf then return; end
	
	if name == NotifyConsts.UpdateGuildMemberList then
		self:UpdateMemberList()
	elseif name == NotifyConsts.ChangeLeaderUpdate then
		self:UpdatePermission()	
	end
end

-- 消息监听
function UIUnionMemberList:ListNotificationInterests()
	return {NotifyConsts.ChangeLeaderUpdate,			
			NotifyConsts.UpdateGuildMemberList};
end

function UIUnionMemberList:OnHide()
	local objSwf = self:GetSWF("UIUnionMemberList")
	if not objSwf then return; end
	
	objSwf.btnYaoqing.disabled = false
	if self.timeKey then 
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	
	UIUnionTanheDialog:Hide()
end

-- 选中一成员
function UIUnionMemberList:OnMemberListClick(e)
	local roleId = e.item.id
	local roleName = e.item.name
	local roleDuty = e.item.pos
	
	local roleLv = e.item.level
	local roleVipLv = e.item.vipLevel
	local roleIcon = e.item.iconID
	-- FPrint('UIUnionMemberList:OnMemberListClick(e)'..roleId..roleDuty..roleName)
	
	UIUnionOper:Open(e.renderer,roleDuty,roleId,roleName,roleLv,roleVipLv,roleIcon)
end

------------------------------------------------------------------------------
--									UI逻辑
------------------------------------------------------------------------------
-- 仅显示在线玩家
function UIUnionMemberList:OnCkOnlyOnlineSelect(e)
	-- self:ChangeCfg( "autoHang", e.selected );
	self:UpdateMemberList()
end

-- 更新帮派成员列表
function UIUnionMemberList:UpdateMemberList()
	local objSwf = self:GetSWF("UIUnionMemberList")
	if not objSwf then return; end
	
	local unionMember = UnionModel.UnionMemberList
	if not unionMember then return end
	
	objSwf.listPlayer.dataProvider:cleanUp() 
	for i, memberVO in pairs(unionMember) do
		memberVO.posName = UnionUtils:GetOperDutyName(memberVO.pos)
		-- smart  添加特权图标
		local vipStr = ResUtil:GetVIPIcon(memberVO.vipLevel);
		if vipStr and vipStr ~= "" then 
			vipStr = "<img src='"..vipStr.."'/>";
			memberVO.name = vipStr .. memberVO.name;
		end;
				
		memberVO.contribute = self:GetmapName(memberVO.mapid)
		if memberVO.lineid and memberVO.lineid > 0 then
			memberVO.contribute = memberVO.contribute..' '..memberVO.lineid..'线'
		end
		
		-- local vflagStr = ResUtil:GetVIcon(memberVO.vflag);
		-- if vflagStr and vflagStr ~= "" then 
			-- vflagStr = "<img src='"..vflagStr.."'/>";
			-- memberVO.name = vflagStr..memberVO.name;
		-- end;
		if objSwf.ckOnlyOnline.selected then
			if memberVO.online == 1 then
				objSwf.listPlayer.dataProvider:push( UIData.encode(memberVO) )
			end
		else
			objSwf.listPlayer.dataProvider:push( UIData.encode(memberVO) )
		end
	end
	objSwf.listPlayer:invalidateData()
end

function UIUnionMemberList:GetmapName(mapId)
	local mapCfg = t_map[mapId]
	if not mapCfg then return '' end
	return mapCfg.name
end

-- 更新权限
function UIUnionMemberList:UpdatePermission()
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	-- 解散
	if UnionUtils:GetUnionPermissionByDuty(UnionModel.MyUnionInfo.pos, UnionConsts.dismiss) == 1 then
		objSwf.btnDispose.visible = true
	else
		objSwf.btnDispose.visible = false
	end
end




