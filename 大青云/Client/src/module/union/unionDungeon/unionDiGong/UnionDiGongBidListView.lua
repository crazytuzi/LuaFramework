--[[帮派地宫竞标列表界面
zhangshuhui
]]

_G.UIUnionDiGongBidListView = BaseUI:new("UIUnionDiGongBidListView")

UIUnionDiGongBidListView.curid = 0;

function UIUnionDiGongBidListView:Create()
	self:AddSWF("unionDiGongBidListPanel.swf", true, "center")
end

function UIUnionDiGongBidListView:OnLoaded(objSwf,name)
	--关闭
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	objSwf.btnBid.click = function() self:OnBtnBidClick(); end;
end

function UIUnionDiGongBidListView:GetPanelType()
	return 0;
end

function UIUnionDiGongBidListView:IsShowSound()
	return true;
end

-- function UIRedPacketView:GetWidth()
	-- return xxxx;
-- end

-- function UIRedPacketView:GetHeight()
	-- return xxxx;
-- end

--点击关闭按钮
function UIUnionDiGongBidListView:OnBtnCloseClick()
	self:Hide();
end

--竞标帮派列表
function UIUnionDiGongBidListView:OnBtnBidClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--如果非帮主 非副帮主
	if not UnionModel:IsLeader() and not UnionModel:IsDutySubLeader() then
		FloatManager:AddNormal( StrConfig["unionDiGong013"], objSwf.btnBid);
		return;
	end
	UIUnionDiGongBidMoneyView:OpenPanel(self.curid);
end

function UIUnionDiGongBidListView:OnShow(name)
	--显示
	self:ShowBidListInfo();
	
end
function UIUnionDiGongBidListView:OnHide()
	UIUnionDiGongBidMoneyView:Hide();
end

function UIUnionDiGongBidListView:OpenPanel(curid)
	self.curid = curid;
	if self:IsShow() then
		self:ShowBidListInfo();
	else
		self:Show();
	end
	UnionDiGongController:ReqUnionDiGongBidList(curid);
end

-------------------事件------------------
function UIUnionDiGongBidListView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.UnionDiGongBidListUpdate then
		self:ShowBidListInfo();
	end
end

function UIUnionDiGongBidListView:ListNotificationInterests()
	return {NotifyConsts.UnionDiGongBidListUpdate};
end

--显示列表
function UIUnionDiGongBidListView:ShowBidListInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local datalist = {};
	local bidlist = UnionDiGongModel:GetUnionBidList();
	for i,bidvo in ipairs(bidlist) do
		local listvo = {};
		--listvo.id = vo.id;
		if i == 1 then 
			listvo.rank = "a"
		elseif i == 2 then 
			listvo.rank = "b"
		elseif i == 3 then 
			listvo.rank = "c"
		else
			listvo.rank = i;
		end;

		listvo.unionName = bidvo.unionName;
		listvo.bidmoney = toint(bidvo.bidmoney / UnionDiGongConsts.rate , -1) .. "万"
		table.insert(datalist ,UIData.encode(listvo));
	end
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(datalist));
	objSwf.list:invalidateData();
	objSwf.curName.text = t_guilddigong[self.curid].name.."竞标";
	local unionindex,bidmoney = UnionDiGongUtils:GetMyUnionRankInfo();
	if unionindex == 0 then
		objSwf.tfRank.text = "未参与";
	else
		objSwf.tfRank.text = unionindex;
	end
	
	objSwf.tfBidMoney.text = toint(bidmoney / UnionDiGongConsts.rate , -1) .. "万"
end