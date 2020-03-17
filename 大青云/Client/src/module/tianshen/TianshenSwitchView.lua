--变身切换

_G.UITianshenSwitch = BaseUI:new("UITianshenSwitch");
UITianshenSwitch.curoldeid=0;
UITianshenSwitch.pos=nil;
UITianshenSwitch.list={}
function UITianshenSwitch:Create()
	self:AddSWF("TianshenSwitchPanel.swf", false, "highTop");
end

function UITianshenSwitch:OnLoaded(objSwf)
	

	objSwf.tileListTianshen.itemClick = function(e) self:SwitchTianshen(e) end
	--objSwf.tileListTianshen.itemRollOut  = function(e)  TipsManager:Hide();UITransforSkillTips:Close() end
	--objSwf.tileListTianshen.itemRollOver = function(e) self:showTianshenTips(e); end
	
	
end
function UITianshenSwitch:OnBtnCloseClick()
	self:Hide();
end
function UITianshenSwitch:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:showTianshen()
	self:SetUIPos();

end

function UITianshenSwitch:GetWidth()
	return 327;	
end
function UITianshenSwitch:GetHeight()
	return 231;
end

function UITianshenSwitch:OnHide()
	TipsManager:Hide();
end
function UITianshenSwitch:showTianshenTips(e)
	if not e.item then
		return;
	end
	local vo=TianShenModel:GetTianShenVO(e.item.id)
	if vo then 
	   UITransforSkillTips:Open(vo);
	end

end
function UITianshenSwitch:SwitchTianshen(e)               
    
	if not e.item then
		self:Hide();
		return;
	end
	-- if TianShenModel.isTransfor then 
 --        FloatManager:AddNormal(StrConfig['tianshen026']);
 --        return

	-- end

	local zhanbianshen=	TianShenModel:GetFightModel();
	if zhanbianshen then 
	     if self.curoldeid==e.item.id then 
	 	    self:Hide();
		return
	    else
            TianShenController:SendChangeTianshen(zhanbianshen.tid,1)
	        TianShenController:SendChangeTianshen(e.item.id,2)     
	     end
	else 
	TianShenController:SendChangeTianshen(e.item.id,2)
    end
	self:Hide()
	
end
function UITianshenSwitch:GetHeight()
	return 120;
end

function UITianshenSwitch:GetWidth()
	return 318
end
function UITianshenSwitch:showTianshen()
    
   
    local tianshen=TianShenModel:GetTianshenActivate()
	self.objSwf.tileListTianshen.dataProvider:cleanUp();
	for i,vo in ipairs(tianshen) do
	    self.objSwf.tileListTianshen.dataProvider:push(UIData.encode(vo));
	end
	self.objSwf.tileListTianshen:invalidateData();
	self.objSwf.tileListTianshen.selectedIndex = -1;
end
function UITianshenSwitch:ListNotificationInterests()
	return {NotifyConsts.TianShenChangeModel,NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end	
function UITianshenSwitch:HandleNotification(name,body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.TianShenChangeModel then
	
	--点击其他地方,关闭
	elseif name == NotifyConsts.StageClick then
		if not FuncOpenController.keyEnable then return; end
		local target = string.gsub(objSwf._target, "/",".");
		if string.find(body.target,target) then
			return
		end
		if self.args[1] then
			local target = string.gsub(self.args[1], "/",".");
			if string.find(body.target,target) then
				return;
			end
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	end
end
function UITianshenSwitch:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
end
function UITianshenSwitch:SetUIPos()
    local objSwf = self.objSwf;
	if not objSwf then return; end
	local wWidth, wHeight = UIManager:GetWinSize();
	objSwf._x = wWidth/2+100;

	objSwf._y = wHeight - 300;
end
function UITianshenSwitch:OnResize()
	self:SetUIPos()
end



