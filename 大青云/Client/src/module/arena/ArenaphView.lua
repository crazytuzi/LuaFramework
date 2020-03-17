--[[
竞技场内，血量显示面板
wangshuai

]]



_G.UIArenahp = BaseUI:new("UIArenahp");

function UIArenahp : Create()
	self:AddSWF("ArenaHpProgress.swf",true,"story");
end;

function UIArenahp : OnShow()
	self:SetRoleInfo();
end;
function UIArenahp : SetRoleInfo()
	local objSwf = self.objSwf;
	local myvo = ArenaBattle.playerList[1].playerInfo
	local othervo = ArenaBattle.playerList[2].playerInfo

	local icon1 = ArenaBattle.playerList[1].icon
	local icon2 = ArenaBattle.playerList[2].icon

	if icon1 then 
		if objSwf.load1.source ~= ResUtil:GetHeadIcon(icon1) then 
			objSwf.load1.source = ResUtil:GetHeadIcon(icon1);
		end;
	end;
	if icon2 then 
		if objSwf.load2.source ~= ResUtil:GetHeadIcon(icon2) then 
			objSwf.load2.source = ResUtil:GetHeadIcon(icon2);
		end;
	end;
	
	if myvo then 
		objSwf.rolehp1.maximum = myvo[enAttrType.eaMaxHp];
		objSwf.rolehp1.value = myvo[enAttrType.eaHp];
		objSwf.name1.text = myvo[enAttrType.eaName];
	end;
	if othervo then 
		objSwf.rolehp2.maximum = othervo[enAttrType.eaMaxHp];
		objSwf.rolehp2.value =  othervo[enAttrType.eaHp];
		objSwf.name2.text =  othervo[enAttrType.eaName];
	end;
end;
	-- notifaction
function UIArenahp : ListNotificationInterests()
	return {
		NotifyConsts.ArenaRoleInfoChang,
		}
end;
function UIArenahp : HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.ArenaRoleInfoChang then 
		self:SetRoleInfo();
	end;
end;