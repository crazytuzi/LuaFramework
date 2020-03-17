--[[
魂兵替换面板
zhangshuhui
2015年10月7日17:42:53
]]

_G.UIBingHunShortCutSet = BaseUI:new("UIBingHunShortCutSet");

UIBingHunShortCutSet.pos = 0;
UIBingHunShortCutSet.mc = nil;
--道具信息list
UIBingHunShortCutSet.binghunList = {};

UIBingHunShortCutSet.currPanelY = 0;

function UIBingHunShortCutSet:Create()
	self:AddSWF("binghunShortCutSetting.swf",true,"top");
end

function UIBingHunShortCutSet:OnLoaded(objSwf,name)
	objSwf.binghunlistpanel.itemList.itemClick = function(e) self:OnBingHunClick(e); end
end

function UIBingHunShortCutSet:OnResize()
	self:Hide();
end

--@param mc 点击目标格子mc
function UIBingHunShortCutSet:Open(mc)
	self.mc = mc;
	if self:IsShow() then
		self:SetUIPos();
	else
		self:Show();
	end
end

function UIBingHunShortCutSet:OnShow()
	self:ShowTitle();
	self:ShowList();
	self:SetUIPos();
end

function UIBingHunShortCutSet:OnHide()
	self.mc = nil;
end

function UIBingHunShortCutSet:SetUIPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local pos = nil;
	if self.mc then
		pos = UIManager:GetMcPos(self.mc);
		local width = self.mc.width or self.mc._width;
		pos.x = pos.x + width / 2;
	else
		pos = _sys:getRelativeMouse();
	end
	objSwf._x = pos.x - objSwf._width / 2;
	objSwf._y = pos.y - objSwf._height;
end

function UIBingHunShortCutSet:ShowTitle()
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

function UIBingHunShortCutSet:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.binghunList = {};
	local list = {};
	local cancelvo = {};
	cancelvo.iscancel = true;
	cancelvo.id = 0;
	table.push (self.binghunList, UIData.encode(cancelvo));
	
	for i=1,BingHunConsts.BingHunMax do
		local binghunvo = BingHunModel:GetBingHunById(i);
		if binghunvo then
			local vo = {};
			vo.iscancel = false;
			vo.id = i;
			vo.iconurl = ResUtil:GetBingHunIconName(BingHunUtil:GetBingHunHeadIcon(t_binghun[i].item_icon,MainPlayerModel.humanDetailInfo.eaProf));
			table.push (self.binghunList, UIData.encode(vo));
		end
	end
	
	--
	self.currPanelY = 20;
	self:ShowBingHunList();
	objSwf.bg._height = self.currPanelY + 40;
end

function UIBingHunShortCutSet:ShowBingHunList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panel = objSwf.binghunlistpanel;
	local rows = toint(#self.binghunList/4,1);
	rows = rows<1 and 1 or rows;
	panel.itemList.bg._height = rows*62 + 10;
	panel._y = self.currPanelY;
	panel.itemList.dataProvider:cleanUp();
	-- trace(self.binghunList)
	for i, listVO in ipairs(self.binghunList) do
		panel.itemList.dataProvider:push( listVO );
	end
	-- --不足6个补齐
	-- local lastRowNum = #self.binghunList % 6;
	-- if lastRowNum>0 and lastRowNum<6 then
		-- for i=lastRowNum+1,6 do
			-- local vo = RewardSlotVO:new();
			-- vo.id = 0;
			-- vo.count = 0;
			-- vo.bind = BagConsts.Bind_None;
			-- vo.hasItem = false;
			-- panel.itemList.dataProvider:push( vo:GetUIData() );
		-- end
	-- end
	panel.itemList:invalidateData();
	self.currPanelY = self.currPanelY + rows*62 + 10;
end

function UIBingHunShortCutSet:OnBingHunClick(e)
	self:Hide();
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not e.item then return; end
	if e.item.id then
		BingHunController:ReqBingHunChangeModel(e.item.id);
	end
end

function UIBingHunShortCutSet:OnBingHunRollOver(e)
	
end

function UIBingHunShortCutSet:OnBingHunRollOut(e)
	
end

function UIBingHunShortCutSet:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.StageClick then
		local target = string.gsub(objSwf._target, "/",".");
		if string.find(body.target,target) then
			return
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	end
end

function UIBingHunShortCutSet:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end