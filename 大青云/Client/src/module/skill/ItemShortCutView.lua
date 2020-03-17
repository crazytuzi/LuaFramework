--[[
技能栏物品设置
lizhuangzhuang
2015年6月19日14:41:03
]]

_G.UIItemShortCut = BaseUI:new("UIItemShortCut");

UIItemShortCut.mc = nil;
UIItemShortCut.itemList = {};

function UIItemShortCut:Create()
	self:AddSWF("itemShortCut.swf",true,"center");
end

function UIItemShortCut:OnLoaded(objSwf,name)
	objSwf.list.itemClick = function(e) self:OnItemClick(e); end
	objSwf.list.itemRollOver = function(e) self:OnItemRollOver(e); end
	objSwf.list.itemRollOut = function(e) self:OnItemRollOut(e); end
end

function UIItemShortCut:OnResize()
	self:Hide();
end

function UIItemShortCut:Open(mc)
	self.mc = mc;
	if self:IsShow() then
		self:SetUIPos();
	else
		self:Show();
	end
end

function UIItemShortCut:OnShow()
	self:ShowList();
	self:SetUIPos();
end

function UIItemShortCut:OnHide()
	self.mc = nil;
end

function UIItemShortCut:SetUIPos()
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

function UIItemShortCut:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.itemList = {};
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	for i,bagItem in pairs(bagVO.itemlist) do
		local cfg = t_item[bagItem:GetTid()];
		--屏蔽了 药瓶 cfg.sub==BagConsts.SubT_Recover
		if cfg and   cfg.sub==BagConsts.SubT_XueChi then
			local hasFind = false;
			for i,vo in ipairs(self.itemList) do
				if vo.id == bagItem:GetTid() then
					vo.count = vo.count + bagItem:GetCount();
					hasFind = true;
					break;
				end
			end
			if not hasFind then
				local vo = {};
				vo.hasItem = true;
				vo.id = bagItem:GetTid();
				vo.count = bagItem:GetCount();
				vo.iconUrl = BagUtil:GetItemIcon(bagItem:GetTid());
				table.push(self.itemList,vo);
			end
		end
	end
	--
	local rows = toint(#self.itemList/6,1);
	rows = rows<1 and 1 or rows;
	objSwf.list.bg._height = rows*60 + 10;
	objSwf.list.dataProvider:cleanUp();
	for i,vo in ipairs(self.itemList) do
		objSwf.list.dataProvider:push(UIData.encode(vo));
	end
	--不足6个补齐
	local lastRowNum = #self.itemList % 6;
	if lastRowNum>0 and lastRowNum<6 then
		for i=lastRowNum+1,6 do
			local listVO = {};
			listVO.hasItem = false;
			objSwf.list.dataProvider:push( UIData.encode(listVO) );
		end
	end
	objSwf.list:invalidateData();
	objSwf.bg._height = objSwf.list._y + objSwf.list.bg._height;
	objSwf.mcArrow._y = objSwf.list._y + objSwf.list.bg._height-2;
end

function UIItemShortCut:OnItemRollOver(e)
	if not e.item.hasItem then return; end
	local tipsInfo = {};
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(e.item.id,1);
	if not itemTipsVO then return; end
	tipsInfo.tipsShowType = itemTipsVO.tipsShowType;
	tipsInfo.tipsType = itemTipsVO.tipsType;
	tipsInfo.info = itemTipsVO;
	TipsManager:ShowTips(tipsInfo.tipsType,tipsInfo.info,tipsInfo.tipsShowType, TipsConsts.Dir_RightUp);
end

function UIItemShortCut:OnItemRollOut()
	TipsManager:Hide();
end

function UIItemShortCut:OnItemClick(e)
	if not e.item.hasItem then return; end
	SkillController:ItemShortCut(e.item.id);
	TipsManager:Hide();
	self:Hide();
end

function UIItemShortCut:HandleNotification(name,body)
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
	elseif name == NotifyConsts.BagItemNumChange then
		local cfg = t_item[body.id];
		if cfg and (cfg.sub==BagConsts.SubT_Recover or cfg.sub==BagConsts.SubT_XueChi) then
			self:ShowList();
			self:SetUIPos();
		end
	end
end

function UIItemShortCut:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut,
			NotifyConsts.BagItemNumChange};
end