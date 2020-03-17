--[[
跨服场景界面
]]

_G.UIInterSSTeam = BaseUI:new("UIInterSSTeam");

UIInterSSTeam.curClickInex = 1;

function UIInterSSTeam:Create()
	self:AddSWF("InterSerSceneTeamMain.swf", true, "interserver");
end;
function UIInterSSTeam:OnLoaded(objSwf)
	for i=1,3 do 
		objSwf['btn'..i].click = function() self:SetQesCurIndex(i) end;
	end;

	objSwf.list.btnRClick = function(e) self:ItemClick(e) end;
	objSwf.closebtn.click = function() self:Hide()end;

	objSwf.createTeam_btn.click = function() self:CreateTeamClick() end;
	objSwf.outTeam_btn.click = function() self:OutTeamClick() end;
end;
function UIInterSSTeam:OnShow()
	self:UpdataShow();
	self:SetQesCurIndex(self.curClickInex);

end;

function UIInterSSTeam:OnHide()
	self.curClickInex = 1;
end;

function UIInterSSTeam:OutTeamClick()
	InterSerSceneController:ReqInterSSTeamOut()
end;

function UIInterSSTeam:CreateTeamClick()
	InterSerSceneController:ReqInterSSTeamCreate()
end;

function UIInterSSTeam:ItemClick(e)
	-- print(e.item.btnTxt)
	-- print(e.item.desc)
	-- -- 
	if self.curClickInex == 1 then 
		---是队长，踢人，o
		InterSerSceneController:ReqInterSSTeamkick(e.item.desc)
	elseif self.curClickInex == 2 then 
		--申请加入组队
		InterSerSceneController:RespInterSSTeamApproveRole(e.item.desc)
	elseif self.curClickInex == 3 then 
		--邀请玩家
		InterSerSceneController:ReqInterSSTeamInviteRole(e.item.desc)
	end;
end;

function UIInterSSTeam:UpdataShow()
	self:SetBtnStata();
	self:UpdataUIList();
end;

function UIInterSSTeam:SetBtnStata()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local myIsHavaTeam,islead = InterSerSceneModel:GetMyIsHavaTeam()
	if myIsHavaTeam then 
		objSwf.createTeam_btn._visible = false;
		objSwf.outTeam_btn._visible = true;
	else
		objSwf.createTeam_btn._visible = true;
		objSwf.outTeam_btn._visible = false;
	end;
end;

function UIInterSSTeam:SetQesCurIndex(index)
	self.curClickInex = index;
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.curClickInex == 1 then 
		InterSerSceneController:ReqInterServiceSceneMyTeam()
	elseif self.curClickInex == 2 then 
		InterSerSceneController:ReqInterSSTeamNearbyTeam()
	elseif self.curClickInex == 3 then 
		InterSerSceneController:ReqInterSSTeamNearbyRole()
	end;
	self:UpdataUIList();
end;

function UIInterSSTeam:UpdataUIList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.title.textField.text = StrConfig['interServiceDungeon41'..self.curClickInex];

	local data = {};
	if self.curClickInex == 1 then 
		objSwf.btn1.selected = true;
		data = InterSerSceneUtil:ShowMyTeamList()
	elseif self.curClickInex == 2 then 
		objSwf.btn2.selected = true;
		data = InterSerSceneUtil:ShowNearbyTeam()
	elseif self.curClickInex == 3 then 
		objSwf.btn3.selected = true;
		data = InterSerSceneUtil:ShowNearbyRole();
	end;
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(data));
	objSwf.list:invalidateData();
end;

-- notifaction
function UIInterSSTeam:ListNotificationInterests()
	return {
		NotifyConsts.InterSerSceneTeamUpdata,
		}
end;

function UIInterSSTeam:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.InterSerSceneTeamUpdata then
		self:UpdataShow();
	end;
end;

function UIInterSSTeam:ESCHide()
	return true;
end;