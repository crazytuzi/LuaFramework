--[[
	 家园弟子经验
	 wangshuai
]]

_G.UIHomesAddPupilExp = BaseUI:new("UIHomesAddPupilExp")

function UIHomesAddPupilExp:Create()
	self:AddSWF("homesteadPupilExpAddPanel.swf",true,nil)
end;

function UIHomesAddPupilExp:OnLoaded(objSwf)
	objSwf.close_btn.click = function() self:Hide()end;
	RewardManager:RegisterListTips(objSwf.rewardlist);
	for i=1,4 do
		objSwf["use"..i.."_btn"].click = function() self:UseClick(i)end;
	end;
end;

function UIHomesAddPupilExp:OnShow()
	self:ShowExpList();
end;

function UIHomesAddPupilExp:OnHide()

end;

function UIHomesAddPupilExp:SetPupilUid(uid)
	self.pupilUid = uid;
end;

function UIHomesAddPupilExp:UseClick(type)
	local cfg = t_homepupilexpitem[type];
	local vo = HomesteadModel:GetApupilList(self.pupilUid)
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	if vo.lvl >= myLevel then 
		FloatManager:AddNormal(StrConfig["homestead069"])
		return 
	end;
	if not t_homepupilexp[vo.lvl + 1] then 
		local ccfg = t_homepupilexp[vo.lvl].pupilExp;
		if ccfg then 
			if vo.exp >= ccfg then 
				FloatManager:AddNormal(StrConfig["homestead069"])
				return 
			end;
		end;
	end;
	--local func = function ()
	HomesteadController:PupilUseExp(self.pupilUid,cfg.itemid)
	--end
	--UIConfirm:Open(StrConfig['beicangjie080'],func);

end;

function UIHomesAddPupilExp:ShowExpList()
	local objSwf = self.objSwf;
	local cfg = t_homepupilexpitem;
	local rewardList = {};
	for i,info in ipairs(cfg) do 
		local reward = RewardSlotVO:new()
		reward.count = BagModel:GetItemNumInBag(info.itemid) 
		reward.id = info.itemid;
		table.push(rewardList,reward:GetUIData())
		objSwf["name"..i.."_txt"].htmlText = info.image_man;
		if info.expType == 0 then 
			objSwf["exp"..i.."_txt"].htmlText = info.expNum;
		elseif info.expType == 1 then 
			objSwf["exp"..i.."_txt"].htmlText = info.expNum.."%";
		end;

	end;
	objSwf.rewardlist.dataProvider:cleanUp();
	objSwf.rewardlist.dataProvider:push(unpack(rewardList));
	objSwf.rewardlist:invalidateData();
end;

-- 居中
function UIHomesAddPupilExp:AutoSetPos()
	if self.parent == nil then return; end
	if not self.isLoaded then return; end
	if not self.swfCfg then return; end
	if not self.swfCfg.objSwf then return; end
	local objSwf = self.swfCfg.objSwf;
	local Vx = toint(HomesteadConsts.MainViewWH.width / 2) - objSwf._width/2
	local Vy = toint(HomesteadConsts.MainViewWH.height / 2) - objSwf._height/2
	objSwf.content._x = Vx--toint(x or objSwf.content._x,  -1); 
	objSwf.content._y = Vy--toint(y or objSwf.content._y, -1);
end;

	-- notifaction
function UIHomesAddPupilExp:ListNotificationInterests()
	return {
			NotifyConsts.BagAdd,
			NotifyConsts.BagRemove,
			NotifyConsts.BagUpdate,
		}
end;
function UIHomesAddPupilExp:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then 
		self:ShowExpList();
	end;
end;
