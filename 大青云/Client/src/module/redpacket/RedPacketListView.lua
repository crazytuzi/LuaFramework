--[[全服红包界面
zhangshuhui
2015年10月7日19:59:00
]]

_G.UIRedPacketListView = BaseUI:new("UIRedPacketListView")

function UIRedPacketListView:new(szName)
	local obj = BaseUI:new(szName);
	for k, v in pairs(self) do
		if type(v) == "function" then
			obj[k] = v
		end
	end
	return obj
end

function UIRedPacketListView:Create()
	self:AddSWF("redpacketListPanel.swf", true, "center")
end

function UIRedPacketListView:OnLoaded(objSwf,name)
	--关闭
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	objSwf.btnClose1.click = function() self:OnBtnClearClick(); end;
	objSwf.btnClose1.rollOver = function() TipsManager:ShowTips( TipsConsts.Type_Normal, StrConfig["redpacket8"], TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown ); end
	objSwf.btnClose1.rollOut  = function()  TipsManager:Hide();  end
	--领取红包奖励
	objSwf.list.GetRepacketBtnClick = function(e) self:OnListGetRankClick(e); end
	--
	self:Init(objSwf)
end

function UIRedPacketListView:Init(objSwf)
	objSwf.bg:gotoAndPlay("vip")
end

function UIRedPacketListView:GetPanelType()
	return 0;
end

function UIRedPacketListView:IsShowSound()
	return true;
end

--点击关闭按钮
function UIRedPacketListView:OnBtnCloseClick()
	self:Hide();
end

--清空红包
function UIRedPacketListView:OnBtnClearClick()
	self:Hide()
	self:GetModel():SetRedPacket({})
	self:GetRemindView():Hide()
end

function UIRedPacketListView:GetModel()
	return RedPacketModel
end

function UIRedPacketListView:GetRemindView()
	return UIRedPacketRemindView
end

function UIRedPacketListView:OnShow(name)
	--显示
	self:ShowRedPacketInfo();
end

function UIRedPacketListView:OnListGetRankClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not e.item then return; end
	
	local id = e.item.id;
	RedPacketController:ReqGetRedPacketRank(id);
end

-------------------事件------------------
function UIRedPacketListView:OnGetAwardClick(k)
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

function UIRedPacketListView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.RedPacketListUpdata then
		self:ShowRedPacketInfo();
	end
end

function UIRedPacketListView:ListNotificationInterests()
	return {NotifyConsts.RedPacketListUpdata};
end

--显示列表
function UIRedPacketListView:ShowRedPacketInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.imgnoget._visible = false;
	local datalist = {};
	local list = self:GetModel():GetRedPacketList();
	for i,vo in ipairs(list) do
		local listvo = {};
		listvo.id = vo.id;
		listvo.num = vo.num;
		if vo.num == -1 then
			vo.num = 1;
		end
		listvo.strnum = string.format( StrConfig['redpacket5'], vo.num);
		if vo.num == 0 then
			listvo.roleName = string.format( StrConfig['redpacket2'], vo.roleName);
		else
			listvo.roleName = string.format( StrConfig['redpacket3'], vo.roleName);
		end
		table.insert(datalist ,UIData.encode(listvo));
	end
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(datalist));
	objSwf.list:invalidateData();
	
	if #list == 0 or self:IsHaveNotGetRedPacket() == 0 then
		objSwf.imgnoget._visible = true;
		self:GetRemindView():Hide();
	end
end

function UIRedPacketListView:IsHaveNotGetRedPacket()
	local count = 0;
	local list = self:GetModel():GetRedPacketList();
	for i,vo in ipairs(list) do
		if vo.num == -1 then
			count = count + 1;
		else
			count = count + vo.num;
		end
	end
	return count;
end