--[[
帮派
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionMemberActivity = BaseUI:new("UIUnionMemberActivity")
UIUnionMemberActivity.clickCreateTime = {}
UIUnionMemberActivity.dubleClickTime = 15*60*1000
local listDic = {}
function UIUnionMemberActivity:Create()
	self:AddSWF("unionMemberActivityPanel.swf", true, nil);
end

function UIUnionMemberActivity:OnLoaded(objSwf, name)
	-- objSwf.scrollbar.scroll = function () self:OnScrollBar()end;
	
	objSwf.worldBossItem.btnSend.click = function() self:OnBtnWorldBossClick(e) end
	objSwf.worldBossItem.ddList.change = function(e) self:OnDDListCick(e); end
	objSwf.listPlayer.btnApplyClick = function(e) self:OnBtnSendClick(e) end
end

-- 点世界boss召集
function UIUnionMemberActivity:OnBtnWorldBossClick(e)
	local objSwf = self.objSwf
	if not objSwf then return; end
	

	local actId = 1
	if not self.clickCreateTime[actId] then
		self.clickCreateTime[actId] = 0
	end

	if GetCurTime() - self.clickCreateTime[actId] > self.dubleClickTime then
		self.clickCreateTime[actId] = GetCurTime()		
		
		local sendTxt = objSwf.worldBossItem.textField2.text
		if sendTxt == t_guildassemble[actId].text then
			sendTxt = ""
		end
		UnionController:ReqSendGuildActivityNotice(1, self.selectedWorldBossId, sendTxt)
		FloatManager:AddNormal( '邀请已发送');
	else
		FloatManager:AddNormal( StrConfig['union73']);
	end	
end

-- 在列表中点召集
function UIUnionMemberActivity:OnBtnSendClick(e)
	local actId = e.item.actId
	if not actId then return end
	
	if not self.clickCreateTime[actId] then
		self.clickCreateTime[actId] = 0
	end
	
	if GetCurTime() - self.clickCreateTime[actId] > self.dubleClickTime then
		self.clickCreateTime[actId] = GetCurTime()		
		
		local sendTxt = e.renderer.textField2.text
		if sendTxt == t_guildassemble[actId].text then
			sendTxt = ""
		end
		UnionController:ReqSendGuildActivityNotice(actId, 0, sendTxt)
		FloatManager:AddNormal( '邀请已发送');
		sendTxt = ChatUtil.filter:filter(sendTxt);
		e.renderer.textField2.text = sendTxt
	else
		FloatManager:AddNormal( StrConfig['union73']);
	end	
end

function UIUnionMemberActivity:OnDDListCick(e)
	if listDic[e.index+1] then
		self.selectedWorldBossId = listDic[e.index+1].id
	end
end

function UIUnionMemberActivity : OnScrollBar()
	-- local objSwf = self.objSwf;
	-- local value = objSwf.scrollbar.position;
	--print(self:IsShow(),"_______________--------")
	--debug.debug();
	-- self:ShowList(value+1);
end;

function UIUnionMemberActivity:OnShow(name)
	local objSwf = self.objSwf;
	if not objSwf then return end

	self:UpdateEventList()
	--UnionController:ReqMyGuildEvents()
end

--消息处理
function UIUnionMemberActivity:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	-- if name == NotifyConsts.UpdateGuildEventList then
		-- self:UpdateEventList()
	-- end
end

-- 消息监听
function UIUnionMemberActivity:ListNotificationInterests()
	-- return {NotifyConsts.UpdateGuildEventList};
end

------------------------------------------------------------------------------
--									UI逻辑
------------------------------------------------------------------------------

-- 更新帮派成员列表
function UIUnionMemberActivity:UpdateEventList()
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	self:initWorldBoss()
	
	local num = 0
	for k,v in pairs(t_guildassemble) do
		num = num + 1
	end
	
	local act1VO = {}
	act1VO.actId = -1
	objSwf.listPlayer.dataProvider:cleanUp()
	objSwf.listPlayer.dataProvider:push( UIData.encode(act1VO) )
	
	for i = 2, num do
		local actVO = {}
		actVO.actId = t_guildassemble[i].id
		actVO.actName = t_guildassemble[i].name
		actVO.actText = t_guildassemble[i].text		
		objSwf.listPlayer.dataProvider:push( UIData.encode(actVO) )
	end
	objSwf.listPlayer:invalidateData()	
	
	-- objSwf.scrollbar:setScrollProperties(5,0,num-5);
	-- objSwf.scrollbar.trackScrollPageSize = 5;
	-- objSwf.scrollbar.position = 0;
end

function UIUnionMemberActivity:initWorldBoss()
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	objSwf.worldBossItem.textField1.text = t_guildassemble[1].name
	objSwf.worldBossItem.textField2.text = t_guildassemble[1].text	
	
	local num = 0
	listDic = {}
	for k,v in pairs (t_worldboss) do
		local worldBossVO = {}
		worldBossVO.id = v.id
		worldBossVO.name = t_monster[v.monster].name
		table.push(listDic, worldBossVO)
		num = num + 1
	end	
	
	table.sort( listDic, function( A, B )
		return A.id < B.id
	end )
	objSwf.worldBossItem.ddList.dataProvider:cleanUp();
	for i,vo in ipairs(listDic) do
		objSwf.worldBossItem.ddList.dataProvider:push(vo.name);
	end
	objSwf.worldBossItem.ddList:invalidateData();
	
	objSwf.worldBossItem.ddList.rowCount = num;
	objSwf.worldBossItem.ddList.selectedIndex = 0
	self.selectedWorldBossId = listDic[objSwf.worldBossItem.ddList.selectedIndex+1].id;
	
end