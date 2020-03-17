--[[
帮派管理
lizhuangzhuang
2015年10月9日15:55:50
]]

_G.UIGMGuild = BaseUI:new("UIGMGuild");

UIGMGuild.guildName = "";
UIGMGuild.guildUid = nil;
UIGMGuild.list = nil;
UIGMGuild.timeNow = 0;

function UIGMGuild:Create()
	self:AddSWF("gmGuild.swf",true,"center");
end

function UIGMGuild:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:Hide(); end
	objSwf.btnJieSan.click = function() self:OnBtnJieSanClick(); end
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
end

function UIGMGuild:OnShow()
	if not self.guildUid then return; end
	self:ShowInfo();
end

function UIGMGuild:OnHide()
	self.guildUid = nil;
end

function UIGMGuild:SetData(guildName,guildUid,timeNow,list)
	self.guildName = guildName;
	self.guildUid = guildUid;
	self.timeNow = timeNow;
	self.list = list;
	if self:IsShow() then
		self:ShowInfo();
	end
end

function UIGMGuild:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfGuildName.text = StrConfig["gm022"] .. self.guildName;
	--
	objSwf.list.dataProvider:cleanUp();
	for i,listVO in ipairs(self.list) do
		local uiVo = {};
		uiVo.id = listVO.id;
		uiVo.tf1 = listVO.name;
		uiVo.tf2 = "Lv." .. listVO.level;
		uiVo.tf3 = UnionUtils:GetOperDutyName(listVO.pos);
		uiVo.tf4 = listVO.power;
		uiVo.tf5 = listVO.contribute;
		uiVo.tf6 = listVO.allcontribute;
		if listVO.online == 1 then
			uiVo.tf7 = string.format(StrConfig['union72'])--显示在线
		else
			uiVo.tf7 = UnionUtils:GetLoginTime(self.timeNow - listVO.time)--最后登录显示
		end
		objSwf.list.dataProvider:push(UIData.encode(uiVo));
	end
	objSwf.list:invalidateData();
end

function UIGMGuild:OnListItemClick(e)
	if not self.guildUid then return; end
	if not e.item then return; end
	local id = e.item.id;
	if not id then return; end
	if id == "0_0" then return; end
	UIGMGuildOper:Open(id,self.guildUid);
end

function UIGMGuild:OnBtnJieSanClick()
	if not self.guildUid then return; end
	UIConfirm:Open(StrConfig["gm023"],function()
		if not self:IsShow() then return; end
		if not self.guildUid then return; end
		GMController:DismissGuild(self.guildUid);
	end);
end