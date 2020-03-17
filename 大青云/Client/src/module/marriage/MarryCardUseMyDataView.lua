--[[
婚礼喜帖使用前，自己的数据
wangshuai
]]

_G.UIMarryCardMyData = BaseUI:new("UIMarryCardMyData")

UIMarryCardMyData.Friendlist = {}
UIMarryCardMyData.Unionlist = {}

function UIMarryCardMyData:Create()
	self:AddSWF("marryCardUsePanel.swf",true,"center")
end;

function UIMarryCardMyData:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;

	objSwf.enterBtn.click = function() self:btnOk() end;
	
	objSwf.friendList.itemClick = function(e) self:OnFriendClick(e)end;
	objSwf.unionList.itemClick = function(e) self:OnUnionClick(e)end;
end;	

function UIMarryCardMyData:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	UnionController:ReqMyGuildMems()
	self:ShowFriendList();
	self:ShowUnionList();

	objSwf.cardAllNum.htmlText = self.MaxNum or 0;
	local data = MarriageModel.MyCardUseData
	--trace(data)
	local myProf = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
	local cfg = t_playerinfo[myProf];
	if not cfg or not data then 
		objSwf.tfName22.htmlText = ""
		objSwf.tfName11.htmlText = ""
		objSwf.time_text.htmlText = ""
	end;
	if cfg.sex == 0 then --女性
		objSwf.tfName22.htmlText = MainPlayerModel.humanDetailInfo.eaName
		objSwf.tfName11.htmlText = data.beRoleName or "";
	elseif cfg.sex == 1 then --男性
		objSwf.tfName11.htmlText = MainPlayerModel.humanDetailInfo.eaName
		objSwf.tfName22.htmlText = data.beRoleName or "";
	end
	local year, month, day, hour, minute, second = CTimeFormat:todate(data.time or 0,true);
	objSwf.time_text.htmlText = string.format('%02d-%02d-%02d',year, month, day) .."<br/>" .. string.format('%02d:%02d:%02d',hour, minute, second);
	

	
end;
	
UIMarryCardMyData.MaxNum = 0;
UIMarryCardMyData.curTid = 0;

function UIMarryCardMyData:SetNum(num,id)
	self.MaxNum = num;
	self.curTid = id;
end;

function UIMarryCardMyData:OnHide()

end;

function UIMarryCardMyData:OnFriendClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	--e.item.roleId
	if not e.item then return end;
	local roleId = e.item.roleId;
	for i,info in ipairs(self.Friendlist) do 
		if info.roleId == roleId then 
			info.imgState = info.imgState == 1 and 0 or 1
			local vo = UIData.encode(info);
			objSwf.friendList.dataProvider[e.index] = vo;
			local uiItem = objSwf.friendList:getRendererAt(e.index);
			if uiItem then
				uiItem:setData(vo);
			end
		end;
	end;
end;

function UIMarryCardMyData:OnUnionClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local roleId = e.item.roleId;
	for i,info in ipairs(self.Unionlist) do 
		if info.roleId == roleId then 
			info.imgState = info.imgState == 1 and 0 or 1
			local vo = UIData.encode(info);
			objSwf.unionList.dataProvider[e.index] = vo;
			local uiItem = objSwf.unionList:getRendererAt(e.index);
			if uiItem then
				uiItem:setData(vo);
			end
		end;
	end;
end;

function UIMarryCardMyData:btnOk()
	local listData = {}
	for i,info in ipairs(self.Friendlist) do 
		local vo = {}
		vo.roleID = info.roleId;
		if info.imgState == 1 then 
			listData[info.roleId] = vo;
		end;
	end;
	for is,infos in ipairs(self.Unionlist) do 
		local vo = {}
		vo.roleID = infos.roleId;
		if infos.imgState == 1 then 
			listData[infos.roleId] = vo;
		end;
	end;
	local data = {}
	for bb,pp in pairs(listData) do 
		local vo = {};
		vo.roleID = pp.roleID;
		table.push(data,vo)
	end;

	if #data <= 0 then 
		FloatManager:AddNormal(StrConfig["marriage204"])
		return 
	end;

	MarriagController:ReqMarryCardUse(data,self.curTid);
	--self:Hide();
end;

function UIMarryCardMyData:ShowFriendList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local data = FriendModel.friendList
	--trace(data)
	--print("收到消息")
	self.Friendlist = {};
	local uidata = {}
	for i,info in pairs(data) do 
		local vo = {};
		vo.roleId = info.roleId;
		vo.name = info.roleName;
		vo.imgState = 0; 
		table.push(self.Friendlist,vo)
		table.push(uidata,UIData.encode(vo))
	end;
	--trace(uidata)
	objSwf.friendList.dataProvider:cleanUp();
	objSwf.friendList.dataProvider:push(unpack(uidata));
	objSwf.friendList:invalidateData();
end;

function UIMarryCardMyData:ShowUnionList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local data = UnionModel.UnionMemberList
	--trace(data)
	--print("收到消息")
	self.Unionlist = {};
	local uidata = {}
	local myroleid = MainPlayerController:GetRoleID(); --自己的uid
	for i,info in pairs(data) do 
		if info.id ~= myroleid then 
			local vo = {};
			vo.roleId= info.id;
			vo.name = info.name;
			vo.imgState = 0; 
			table.push(self.Unionlist,vo)
			table.push(uidata,UIData.encode(vo))
		end;
	end;
	--trace(uidata)
	objSwf.unionList.dataProvider:cleanUp();
	objSwf.unionList.dataProvider:push(unpack(uidata));
	objSwf.unionList:invalidateData();
end;


-- 是否缓动
function UIMarryCardMyData:IsTween()
	return true;
end

--面板类型
function UIMarryCardMyData:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIMarryCardMyData:IsShowSound()
	return true;
end

function UIMarryCardMyData:IsShowLoading()
	return true;
end

	-- notifaction
function UIMarryCardMyData:ListNotificationInterests()
	return {
		NotifyConsts.UpdateGuildMemberList,
		}
end;
function UIMarryCardMyData:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.UpdateGuildMemberList then
		self:ShowUnionList();
	end;
end;