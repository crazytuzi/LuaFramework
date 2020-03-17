--[[限时时装
zhangshuhui
2015年1月22日16:57:20
]]

_G.UIFashionsLimitView = BaseSlotPanel:new("UIFashionsLimitView")


function UIFashionsLimitView:Create()
	self:AddSWF("fashionsLimitPanel.swf", true, nil)
end

function UIFashionsLimitView:OnLoaded(objSwf,name)
	--整理
	-- objSwf.btnPack.click = function() self:OnBtnPackClick(); end;
	
	--初始化格子
	for i=1,FashionsConsts.bagTotalSize do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end
end

function UIFashionsLimitView:OnDelete()
	self:RemoveAllSlotItem();
end

function UIFashionsLimitView:OnShow(name)
	--初始化数据
	self:InitData();
	--显示时装
	self:ShowLimitList();
	--显示数量
	self:ShowNum();
end

function UIFashionsLimitView:OnHide()
end

-------------------事件------------------
function UIFashionsLimitView:OnBtnPackClick()
	-- local objSwf = self.objSwf;
	-- if not objSwf then return; end
	
	local datalist = FashionsUtil:ManagerLimitlist();
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(datalist));
	objSwf.list:invalidateData();
	objSwf.list:scrollToIndex(0);
end

function UIFashionsLimitView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.FashionsDressInfo then
		self:DoUpdateItem(body);
		self:ShowNum();
	elseif name == NotifyConsts.FashionsDressAdd then
		self:FashionsAdd(body);
	end
end

function UIFashionsLimitView:ListNotificationInterests()
	return {NotifyConsts.FashionsDressInfo, NotifyConsts.FashionsDressAdd};
end

function UIFashionsLimitView:InitData()
end

function UIFashionsLimitView:InitUI()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
end

--显示列表
function UIFashionsLimitView:ShowLimitList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local datalist = FashionsUtil:GetLimitlist();
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(datalist));
	objSwf.list:invalidateData();
	objSwf.list:scrollToIndex(0);
end

--显示背包数量
function UIFashionsLimitView:ShowNum()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local count = FashionsUtil:GetFashionsNum();
	-- objSwf.tfSize.text = count.."/99";
end
function UIFashionsLimitView:DoUpdateItem(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local index = 0;
	for i=1,FashionsConsts.bagTotalSize do
		if i == index + 1 then
			local limitindex = 0
			for k,limitvo in pairs(FashionsModel.fashionslimitlist) do
				local vo = t_fashions[limitvo.tid];
				if vo then
					limitindex = limitindex + 1;
					if i == limitindex then
						index = limitindex;
						if vo.id == body.tid or vo.id == body.oldId then
							objSwf.list.dataProvider[i - 1] = FashionsUtil:GetUIData(vo.id, i);
							local uiSlot = objSwf.list:getRendererAt(i - 1);
							if uiSlot then
								uiSlot:setData(FashionsUtil:GetUIData(vo.id, i));
							end
						end
					end
				end
			end
		end
	end
end

function UIFashionsLimitView:FashionsAdd(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if body.time == -1 then
		return;
	end
	
	local index = 0;
	for i=1,FashionsConsts.bagTotalSize do
		if i == index + 1 then
			local limitindex = 0
			for k,limitvo in pairs(FashionsModel.fashionslimitlist) do
				local vo = t_fashions[limitvo.tid];
				if vo then
					limitindex = limitindex + 1;
					if i == limitindex then
						index = limitindex;
						if vo.id == body.tid then
							objSwf.list.dataProvider[i - 1] = FashionsUtil:GetUIData(vo.id, i);
							local uiSlot = objSwf.list:getRendererAt(i - 1);
							if uiSlot then
								uiSlot:setData(FashionsUtil:GetUIData(vo.id, i));
							end
						end
					end
				end
			end
		end
	end
end

function UIFashionsLimitView:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	
	local cfg = t_fashions[data.tid];
	if not cfg then return; end
	cfg.lastTime = FashionsUtil:GetFashionsTime(data.tid);
	
	TipsManager:ShowTips(TipsConsts.Type_Fanshion,{cfg=cfg},TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end

function UIFashionsLimitView:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIFashionsLimitView:OnItemDragBegin(item)

end

function UIFashionsLimitView:OnItemDragin(item)

end

function UIFashionsLimitView:OnItemClick(item)

end

function UIFashionsLimitView:OnItemDoubleClick(item)
	local data = item:GetData();
	if not data then
		return;
	end
	if not data.hasItem  then
		return;
	end
	if data.zhuangbanState == true then
		FashionsController:ReqDressFashion(data.tid, 0);
	else
		FashionsController:ReqDressFashion(data.tid, 1);
	end
end

function UIFashionsLimitView:OnItemRClick(item)
	local data = item:GetData();
	if not data then
		return;
	end
	if not data.hasItem  then
		return;
	end
	if data.zhuangbanState == true then
		FashionsController:ReqDressFashion(data.tid, 0);
	else
		FashionsController:ReqDressFashion(data.tid, 1);
	end
end