--法宝切换

_G.UIFabaoSwitch = BaseUI:new("UIFabaoSwitch");

function UIFabaoSwitch:Create()
	self:AddSWF("fabaoSwitchPanel.swf", false, "highTop");
end

function UIFabaoSwitch:OnLoaded(objSwf)
	

	objSwf.tileListFabao.itemClick = function(e) self:SwitchFabao(e) end
	objSwf.tileListFabao.itemRollOut  = function(e) TipsManager:Hide(); end
	objSwf.tileListFabao.itemRollOver = function(e) self:OnItemOver(e); end
	
	objSwf.btnCancel.click = function() self:OnCancelClick(); end
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
end
function UIFabaoSwitch:ListNotificationInterests()
	return {NotifyConsts.FabaoListChange,NotifyConsts.FabaoChange,NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end

function UIFabaoSwitch:OnBtnCloseClick()
	self:Hide();
end

function UIFabaoSwitch:HandleNotification(name,body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.FabaoChange then
		-- if body == self.currSelect then
			-- self:SetSelect(self.currSelect);
		-- end
		self:showFabao()
	--点击其他地方,关闭
	elseif name == NotifyConsts.StageClick then
		local target = string.gsub(objSwf._target, "/",".");
		if string.find(body.target,target) then
			return
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	end
end

function UIFabaoSwitch:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:showFabao()
end

function UIFabaoSwitch:GetWidth()
	return 327;
end
function UIFabaoSwitch:GetHeight()
	return 231;
end

function UIFabaoSwitch:OnHide()
	TipsManager:Hide();
end

function UIFabaoSwitch:OnItemOver(e)
	if not e.item then
		return;
	end
	local fabao = FabaoModel:GetFabao(e.item.id,e.item.modelId);
	TipsManager:ShowFabaoTips(fabao);
end

function UIFabaoSwitch:SwitchFabao(e)
	if not e.item then
		self:Hide();
		-- self.objSwf["item" ..(e.index+ 1)].selected = false;
		return;
	end
	local zhanFabao = FabaoModel:GetFighting()
	if zhanFabao then 
	     if zhanFabao.id==e.item.id then 
	        self:Hide();
	        return;
		 else
		 	 local fabao = FabaoModel:GetFabao(zhanFabao.id,zhanFabao.modelId);
		     if fabao then
				 FabaoController:SendCallFabao(fabao.id,0);
				 FabaoController:SendCallFabao(e.item.id,1);
				 -- self:Hide()
			 end
	     end
	else
	    FabaoController:SendCallFabao(e.item.id,1);
	end
	self:Hide()
	
end

function UIFabaoSwitch:OnCancelClick()
	local zhanFabao = FabaoModel:GetFighting()
	if not zhanFabao then 
	self:Hide()
	return;
	end
	local fabao = FabaoModel:GetFabao(zhanFabao.id,zhanFabao.modelId);
	FabaoController:SendCallFabao(fabao.id,0);
	self:Hide()
end

function UIFabaoSwitch:GetHeight()
	return 120;
end

function UIFabaoSwitch:GetWidth()
	return 318
end

-- function UIFabaoSwitch:OnResize(dwWidth,dwHeight)
	-- local objSwf = self.objSwf
	-- if not objSwf then return end
	-- objSwf._y = objSwf._y + dy
-- end

function UIFabaoSwitch:showFabao()
	self.objSwf.tileListFabao.dataProvider:cleanUp();
	local list = nil;
	list = FabaoModel.list;
	if UIMainSkill.objAvatar == nil then
		for id,vo in pairs(list) do
			self.objSwf.tileListFabao.dataProvider:push(UIData.encode(vo.view));
		end
		self.objSwf.tileListFabao:invalidateData();
		self.objSwf.tileListFabao:scrollToIndex(-1);
		self.objSwf.tileListFabao.selectedIndex = -1;
		for i = FabaoModel:GetCount(),14 do
			if i==0 then
				i = 1;
			end
			self.objSwf["item"..i].selected = false;
		end
		return;
	else
		local zhanFabao = FabaoModel:GetFighting()
		local count = 0;
		for id,vo in pairs(list) do
			if zhanFabao == vo then
				count = -1*count;
			else
				if count>=0 then
					count = count + 1;
				end
			end
			self.objSwf.tileListFabao.dataProvider:push(UIData.encode(vo.view));
		end
		self.objSwf.tileListFabao:invalidateData();
		count = -1*count;
		count = math.max(count,0);
		self.objSwf.tileListFabao:scrollToIndex(count);

		self.objSwf.tileListFabao.selectedIndex = count;
	end
end
function UIFabaoInfo:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
end


------------------------------------------------ 新手引导自动切换法宝---------------------------------------------

--- 这里由于是用来做引导 所以默认玩家不佩戴法宝
function UIFabaoSwitch:ChangeFabao()
	local Fabao = FabaoModel:GetRandomFabao()
	if Fabao then
		FabaoController:SendCallFabao(Fabao.id,1);
	end
	self:Hide()
end

------------------------------------------------ 外部获取借口	-------------------------------------------------
function UIFabaoSwitch:GetItemBtn()
	local objSwf = self.objSwf
	if objSwf then
		return self.objSwf.item1
	else
		return nil
	end
end