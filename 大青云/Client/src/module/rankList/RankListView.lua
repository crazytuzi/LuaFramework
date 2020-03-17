--[[
排行榜 主面板
wangshuai
]]
_G.UIRankList = BaseUI:new("UIRankList");

UIRankList.tabButton = {};
UIRankList.MyChildList = {"rightrole","rightmoune","rightShengbing", "rightMingYu","rightLingQi","rightArmor"};
UIRankList.curShowRightChild = nil;
UIRankList.curShowChild = nil;
function UIRankList:Create()
	self:AddSWF("RankListpanel.swf",true,"center")
	self:AddChild(UIRankSupreme   ,"supreme")
	self:AddChild(UIRanklistSuit  ,"suit");
	self:AddChild(UIAllTheServerRankView, "ATServer")
      

end;
function UIRankList:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:ClosePanel()end;
    objSwf.bg.hitTestDisable=true
	self:GetChild("supreme"):SetContainer(objSwf.childPanel);
	self:GetChild("suit")   :SetContainer(objSwf.childPanel);
	self:GetChild("ATServer")   :SetContainer(objSwf.childPanel);
   
	self.tabButton["supreme"] = objSwf.supreme;
	self.tabButton["suit"] = objSwf.suit;
	self.tabButton["ATServer"] = objSwf.AtSer;
	--关闭跨服排行，
	objSwf.AtSer._visible=false;
	
	-- objSwf.AtSerss.rollOver = function()
	-- 	TipsManager:ShowBtnTips(StrConfig["rankstr007"],TipsConsts.Dir_RightDown);
	-- end;
	-- objSwf.AtSerss.rollOut  = function() TipsManager:Hide()end;
	for name,btn in pairs(self.tabButton) do 
		btn.click = function() self:OnTabButtonClick(name);end;
	end;
end;

function UIRankList:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

function UIRankList:OnShow()
	-- 请求首名list
	-- if RankListModel:GetCurListboo(0) == true then 
	-- 	RankListController:ReqRanlist(0);
	-- 	RankListModel:SetCurListboo(0);
	-- end;
	UIRankList:OnTabButtonClick("supreme")
	self:UpdateMask();
	self:SetAllServerBtnState();
end;

function UIRankList:SetAllServerBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local lvl = MainPlayerModel.humanDetailInfo.eaLevel;
	if lvl >= RankListConsts.RankAllServerOpenLvl then 
		objSwf.AtSer.disabled = false;
		objSwf.AtSerss.disabled = true;
		objSwf.AtSerss._visible = false;
	else
		objSwf.AtSer.disabled = true;
		objSwf.AtSerss.disabled = false;
		objSwf.AtSerss._visible = true;
	end;
end;

function UIRankList:OnTabButtonClick(name)
	self.curShowChild = name;
	if not self.tabButton[name] then return end;
	local child = self:GetChild(name);
	if not child then return end;
	self.tabButton[name].selected = true;
	self:ShowChild(name)
	if name == "supreme" then 
		--UIRankList:HideChildPanel();
		return end;
	-- if not self.curShowRightChild then return end;
	-- self.curShowRightChild:Show();
end;


function UIRankList:ClosePanel()
	self:Hide();
end;
function UIRankList:OnHide()

end;

-- 面板 附带资源
function UIRankList:WithRes()
	return { "RanklistMinePanel.swf","RanklistRightRolePanel.swf" };
end;
-- 实现接口
function UIRankList:IsTween()
	return true;
end;
function UIRankList:GetPanelType()
	return 1;
end;

function UIRankList:IsShowLoading()
	return true;
end

function UIRankList:IsShowSound()
	return true;
end

function UIRankList:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
end

function UIRankList:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
    local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mcMask._x = -x;
	objSwf.mcMask._y = -y;
	objSwf.mcMask._width = wWidth;
	objSwf.mcMask._height = wHeight;
	self:UpdateCloseButton();
end

function UIRankList:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.closebtn._x = math.min( math.max( wWidth - 50, 1280 ), 1480 )

end

------ 消息处理 ---- 
function UIRankList:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		}
end;
function UIRankList:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False

	if name == NotifyConsts.PlayerAttrChange then 
		if body.type == enAttrType.eaLevel then
			self:SetAllServerBtnState();
		end;
	end;

end;
function UIRankList:GetWidth()
	return 1580;
end;

function UIRankList:GetHeight()
	return 900;
end;