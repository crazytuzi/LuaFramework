--[[
王城战，选择副帮主ui
wangshuai
]]
_G.UISuperGloryThree = BaseUI:new("UISuperGloryThree")

UISuperGloryThree.SetDeputyroleId = nil;
UISuperGloryThree.IsMyinfo = false;
function UISuperGloryThree:Create()
	self:AddSWF("superGloryThreePanel.swf",true,nil)
end;

function UISuperGloryThree:OnLoaded(objSwf)
	objSwf.list.itemClick = function(e) self:OnItemClick(e) end;
	objSwf.upDeputy.click = function() self:UpDeputyClick() end;
	objSwf.closebtn.click = function() self:ClosePanel() end;
end;

function UISuperGloryThree:ClosePanel()
	self:Hide();
end;
function UISuperGloryThree:OnShow()
	SuperGloryController:ReqSuperGloryReqSetDeputy()
	self.IsMyinfo = true;
end;

function UISuperGloryThree:UpDeputyClick()
	if not self.SetDeputyroleId then return end;
	SuperGloryController:ReqSuperGlorySetDeputy(self.SetDeputyroleId)
--	FloatManager:AddNormal(StrConfig['SuperGlory808']);
end;
function UISuperGloryThree:OnItemClick(e)
	self.SetDeputyroleId = e.item.roleID;
end;
function UISuperGloryThree:ShowList()
	local objSwf = self.objSwf;
	local listvo = SuperGloryModel:GetSuperGloryUnionRoleinfo();
	local list = {};
	for i,info in ipairs(listvo) do
		local vo = {}
		if info.pos ~= 5 then 
			vo.roleID = info.roleID;
			vo.pos = t_guildtitle[info.pos].posname;
			vo.name = info.roleName;
			vo.lvl = info.lvl;
			table.push(list,UIData.encode(vo));
		end;
	end;

	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(list));
	objSwf.list:invalidateData();
end;
function UISuperGloryThree:OnHide()
 
end;

	-- notifaction
function UISuperGloryThree:ListNotificationInterests()
	return {
		NotifyConsts.SuperGloryUnionRoleList,
		}
end;
function UISuperGloryThree:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.SuperGloryUnionRoleList then
		--if self.IsMyinfo == true then 
			self:ShowList();
		--end;
	end;
end;
