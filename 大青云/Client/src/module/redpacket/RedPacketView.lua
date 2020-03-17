--[[全服红包界面
zhangshuhui
2015年10月7日19:59:00
]]

_G.UIRedPacketView = BaseUI:new("UIRedPacketView")
UIRedPacketView.id = 0;

function UIRedPacketView:new(szName)
	local obj = BaseUI:new(szName);
	for k, v in pairs(self) do
		if type(v) == "function" then
			obj[k] = v
		end
	end
	obj.id = 0
	return obj
end

function UIRedPacketView:Create()
	self:AddSWF("redpacketPanel.swf", true, "center")
end

function UIRedPacketView:OnLoaded(objSwf,name)
	--关闭
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	objSwf.btnClose2.click = function() self:OnBtnCloseClick(); end;
	--领取红包奖励
	objSwf.btnget.click = function() self:OnBtnGetClick(); end;
	
	--战斗力值居中
	self.rewardnumx = objSwf.numReward._x
	objSwf.numReward.loadComplete = function()
									objSwf.numReward._x = self.rewardnumx - objSwf.numReward.width / 2
								end
	self:InitShow(objSwf)
end

function UIRedPacketView:InitShow(objSwf)
	-- 显示为vip全服红包
	objSwf.nameImg:gotoAndStop(1)
	objSwf.img22._visible = true;
end

function UIRedPacketView:IsShowLoading()
	return true;
end

function UIRedPacketView:IsTween()
	return true;
end

function UIRedPacketView:GetPanelType()
	return 0;
end

function UIRedPacketView:IsShowSound()
	return true;
end

--点击关闭按钮
function UIRedPacketView:OnBtnCloseClick()
	self:Hide();
end

function UIRedPacketView:OnBtnGetClick()
	RedPacketController:ReqGetRedPacket(self:GetModel():GetCurId());
end

function UIRedPacketView:OnShow(name)
	--显示
	self:ShowRedPacketInfo();
end
function UIRedPacketView:OnHide()
end

function UIRedPacketView:GetModel()
	return RedPacketModel
end

-------------------事件------------------
function UIRedPacketView:OnGetAwardClick(k)
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

function UIRedPacketView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.RedPacketUpdata then
		self:ShowRedPacketInfo();
	end
end

function UIRedPacketView:ListNotificationInterests()
	return {NotifyConsts.RedPacketUpdata};
end

--显示列表
function UIRedPacketView:ShowRedPacketInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.imgbestback._visible = false;
	local datalist = {};
	local hongbaoModel = self:GetModel()
	objSwf.numReward._visible = true;
	objSwf.numReward.num = hongbaoModel:GetRewardNum();
	objSwf.tftoolname.text = t_item[hongbaoModel:GetCurtId()].name;
	objSwf.tfroleName.text = hongbaoModel:GetSenderName();
	objSwf.tfnumtitle._visible = false;
	objSwf.tfhavenum.text = "";
	objSwf.imgyiqiangguang._visible = false;
	objSwf.btnClose2._visible = false;
	objSwf.btnget._visible = true;
	
	local list = hongbaoModel:GetRedPacketList();
	if not list then
		objSwf.tfnumtitle._visible = false;
		objSwf.tfhavenum.text = "";
		objSwf.imgyiqiangguang._visible = true;
		objSwf.btnClose2._visible = true;
		objSwf.numReward._visible = false;
		objSwf.btnget._visible = false;
		objSwf.tftoolname.text = "";
	end
	local isfind = false;
	for i,vo in ipairs(list) do
		if hongbaoModel:GetCurId() == vo.id then
			isfind = true;
			objSwf.tfnumtitle._visible = true;
			objSwf.tfhavenum.text = vo.num;
			if vo.num == 0 and hongbaoModel:GetRewardNum() <= 0 then
				objSwf.tfnumtitle._visible = false;
				objSwf.tfhavenum.text = "";
				objSwf.imgyiqiangguang._visible = true;
				objSwf.btnClose2._visible = true;
				objSwf.numReward._visible = false;
				objSwf.btnget._visible = false;
				objSwf.tftoolname.text = "";
			end
			break;
		end
	end
	if isfind == false then
		objSwf.tfnumtitle._visible = false;
		objSwf.tfhavenum.text = "";
		objSwf.imgyiqiangguang._visible = true;
		objSwf.btnClose2._visible = true;
		objSwf.numReward._visible = false;
		objSwf.btnget._visible = false;
		objSwf.tftoolname.text = "";
	end
	
	if hongbaoModel:GetRewardNum() > 0 then
		objSwf.btnget.disabled = true;
		objSwf.tfnumtitle._visible = false;
		objSwf.tfhavenum.text = "";
	else
		objSwf.btnget.disabled = false;
	end
	for i,vo in ipairs(hongbaoModel:GetPacketRankList()) do
		local listvo = {};
		if i == 1 then
			listvo.roleName = string.format( StrConfig['redpacket2'], vo.roleName);
		else
			listvo.roleName = string.format( StrConfig['redpacket3'], vo.roleName);
		end
		
		listvo.num = vo.num;
		listvo.toolname = t_item[hongbaoModel:GetCurtId()].name;
		table.insert(datalist ,UIData.encode(listvo));
	end
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(datalist));
	objSwf.list:invalidateData();
	
	if #hongbaoModel:GetPacketRankList() > 0 then
		objSwf.imgbestback._visible = true;
	end
end