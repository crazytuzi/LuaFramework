--[[
确定面板
lizhuangzhuang
2014年8月6日11:10:21
]]

_G.UIConfirm = BaseUI:new("UIConfirm");

--缓存队列
UIConfirm.waitList = {};
--当前处理的VO
UIConfirm.currVO = nil;
--获取一个新的UID
UIConfirm.uidIndex = 0;

function UIConfirm:new(szName)
	local obj = BaseUI:new(szName);
	for k, v in pairs(self) do
		if type(v) == "function" then
			obj[k] = v
		end
	end
	obj.waitList = {}
	obj.uidIndex = 0
	return obj
end

function UIConfirm:Create()
	self:AddSWF("confirmPanel.swf", true, "highTop" );
end

function UIConfirm:OnLoaded( objSwf )
	objSwf.btnClose.click   = function() self:OnBtnCloseClick() end 
	objSwf.btnCancel.click  = function() self:OnBtnCancelClick() end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick() end
	objSwf.tfContent.autoSize = "center";
	self:RegisterExtendEvents( objSwf )
	RewardManager:RegisterListTips( objSwf.rewardList )
end

function UIConfirm:RegisterExtendEvents( objSwf )
	-- override
end

function UIConfirm:GetWidth()
	return 280;
end

function UIConfirm:GetHeight()
	return 208;
end

function UIConfirm:ESCHide()
	return true;
end

function UIConfirm:OnESC()
	self:OnBtnCloseClick();
end

function UIConfirm:OnShow()
	self:ShowInfo();
	SoundManager:PlaySfx(2045);
end

function UIConfirm:ShowInfo()
	self:Top();
	self:ShowBasicInfo()
	self:ShowExtendInfo()
	self:UpdateMask();
end

function UIConfirm:ShowBasicInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfContent.htmlText = self.currVO.content;
	-- objSwf.tfContent._y = ( 100 - objSwf.tfContent._height ) / 2 + 40;
	if objSwf.rewardList then
		objSwf.rewardList.dataProvider:cleanUp();
		objSwf.rewardList.dataProvider:push(unpack(RewardManager:Parse(self.currVO.reward)));
		objSwf.rewardList:invalidateData();
	end
	objSwf.btnConfirm.label = self.currVO.confirmLabel;
	objSwf.btnCancel.label = self.currVO.cancelLabel;
end

function UIConfirm:ShowExtendInfo()
	-- body
end

function UIConfirm:ShowNext()
	self.currVO = nil;
	if #self.waitList > 0 then
		self.currVO = table.remove(self.waitList, 1, 1);
		self:ShowInfo();
	else
		self:Hide();
	end
end

function UIConfirm:OnBtnConfirmClick()
	self:Confirm();
end

function UIConfirm:OnBtnCancelClick()
	self:Cancel();
end

function UIConfirm:OnBtnCloseClick()
	if self.currVO and self.currVO.cancelFunc and not self.currVO.closeDifferCancel then
		self.currVO.cancelFunc();
	end 
	self:ShowNext();
end

function UIConfirm:Confirm()
	if self.currVO and self.currVO.confirmFunc then
		self.currVO.confirmFunc();
	end 
	self:ShowNext();
end

function UIConfirm:Cancel()
	if self.currVO and self.currVO.cancelFunc then
		self.currVO.cancelFunc()
	end 
	self:ShowNext();
end

-------------------------------------public functions-------------------------------------------
--打开面板
--@param content 内容
--@param confirmFunc 确定回调
--@param cancelFunc 取消回调
--@param confirmLabel 确认按钮label
--@param cancelLabel 取消按钮label
--@param noRemindLabel [checkbox label]
--@param closeDifferCancel 为true时, 点×不等于点cancel, 默认为false
--@param mask 是否显示Mask
function UIConfirm:Open( content, confirmFunc, cancelFunc, confirmLabel, cancelLabel, noRemindLabel, closeDifferCancel,mask, reward)
	if self.currVO then
		if self.currVO.content == content then 
			return self.currVO.uid; 
		end
		if #self.waitList > 0 then
			if self.waitList[#self.waitList].content == content then
				return self.waitList[#self.waitList].uid;
			end
		end
	end
	local vo = {};
	vo.uid = self:GetNewUID();
	vo.content = content;
	vo.confirmFunc = confirmFunc;
	vo.cancelFunc = cancelFunc;
	vo.confirmLabel = confirmLabel or StrConfig["confirmName2"];
	vo.cancelLabel = cancelLabel or StrConfig["confirmName3"];
	vo.noRemindLabel = noRemindLabel or StrConfig["confirmName11"];
	vo.closeDifferCancel = closeDifferCancel;
	vo.isShowMask = mask and true or false;
	vo.reward = reward or ""
	if self.currVO then
		table.push(self.waitList, vo);
	else
		self.currVO = vo;
		self:Show();
	end
	return vo.uid;
end

--通过open时返回的uid来关闭
function UIConfirm:Close(uid)
	if not uid then return; end
	if self.currVO and self.currVO.uid==uid then
		self:ShowNext();
		return;
	end
	for i,vo in ipairs(self.waitList) do
		if vo.uid == uid then
			table.remove(self.waitList,i,1);
			return;
		end
	end
end

function UIConfirm:OnHide()
	self.currVO = nil
end

function UIConfirm:GetNewUID()
	self.uidIndex = self.uidIndex + 1;
	return self.uidIndex;
end

function UIConfirm:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
end

function UIConfirm:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.currVO then return; end
	if not self.currVO.isShowMask then 
		objSwf.draw._visible = true;
		objSwf.mcMask._visible =  false;
		objSwf.mcMask.hitTestDisable = true;
		return 
	end;
	objSwf.draw._visible = false;
	objSwf.mcMask._visible =  true;
	objSwf.mcMask.hitTestDisable = false;

	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._x = 0
	objSwf.mcMask._y = 0
	objSwf.mcMask._width = wWidth + 300
	objSwf.mcMask._height = wHeight + 300
end
