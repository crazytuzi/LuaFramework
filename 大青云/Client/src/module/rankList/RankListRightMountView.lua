--[[
排行榜右侧 坐骑基础信息面，
wangshuai
]]

_G.UIRankListRightMount = BaseSlotPanel:new("UIRankListRightMount");

UIRankListRightMount.SlotTotalNum = 4;
UIRankListRightMount.skillTotalNum = 6;--UI上技能总数


UIRankListRightMount.skillicon = {}
UIRankListRightMount.skilllist = {}

function UIRankListRightMount:Create()
	self:AddSWF("RanklistRightMountPanel.swf",true,nil)
end;

function UIRankListRightMount:OnLoaded(objSwf)
	for i=1,self.SlotTotalNum do 
		--self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end;
	objSwf.closebtn.click = function() self:ClosePanle()end;

	objSwf.list.itemRollOver = function(e) self:ItemOver(e)end;
	objSwf.list.itemRollOut = function() self:ItemOut()end;

	--技能
	for i=1,self.skillTotalNum do
		self.skillicon[i] = objSwf["skill"..i]
		self.skillicon[i].btnskill.rollOver = function(e) self:SkillItemOver(i); end
		self.skillicon[i].btnskill.rollOut  = function() TipsManager:Hide();  end
	end
	
	-- --名字居中
	-- objSwf.nameLoader.loaded = function()
	-- 								objSwf.nameLoader.content._x = 0 - objSwf.nameLoader.content._width / 2
	-- 							end

 end;
 
function UIRankListRightMount:OnDelete()
	self:RemoveAllSlotItem()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end
 
function UIRankListRightMount:ItemOver(e)
	if not e.item.hasItem then
		TipsManager:ShowBtnTips(BagConsts:GetHorseEquipNameByPos(e.item.pos));
		return;
	end
	
	local itemTipsVO = RankListUtils:GetMountEquipTipVO(e.item.tid);
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

function UIRankListRightMount:ItemOut()
	TipsManager:Hide();
end;

function UIRankListRightMount:SkillItemOver(i)
	local skillId = self.skilllist[i].skillId;
	local get = self.skilllist[i].lvl > 0;
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=skillId,condition=false,get=get},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightUp);
end;
function UIRankListRightMount:SkillItemOut()
	TipsManager:Hide();
end;
function UIRankListRightMount:ShowSkillList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	for i=1, self.skillTotalNum do
		self.skillicon[i].visible = true
		self.skillicon[i].btnskill.visible = false
		self.skillicon[i].imgup.visible = false
		self.skillicon[i].iconLoader.visible = false
	end
	
	local list = RankListUtils:GetOtherMountSortSkill();
	for i= 1, self.skillTotalNum do
		local listvo = RankListUtils:GetMountSkillListVO(list[i].skillId,list[i].lvl)
		if listvo then
			self.skillicon[i].btnskill.visible = true
			self.skillicon[i].iconLoader.visible = true
			
			if listvo.lvl == 0 then
				self.skillicon[i].iconLoader.source = ImgUtil:GetGrayImgUrl(listvo.iconUrl)
			else
				self.skillicon[i].iconLoader.source = listvo.iconUrl
			end
			
			self.skilllist[i] = listvo
		end
	end
end

function UIRankListRightMount:OnShow()
	self:ShowList();
	if RankListModel.mountDetaied.rideLevel > 0 then 
		local modelid = RankListUtils:GetPlayerMountModelId(RankListModel.mountDetaied.rideLevel,RankListModel.mountDetaied.roleID)
		self:MountDraw(modelid);
		--技能

		self:ShowSkillList();
	end;
end;
function UIRankListRightMount:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil)
	end
	if self.objAvatar then 
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end;
end;
function UIRankListRightMount:ShowList()
	local objSwf = self.objSwf;
	--local listvo = RankListUtils:GetMountEquipItemList()

	 local listvo = OtherRoleUtil:GetMountEquipUIList(RankListModel.mountEquip)
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(listvo));
	objSwf.list:invalidateData();


	local listvo = RankListUtils:GetMountListVo(RankListModel.mountDetaied.roleID) --人物信息  
	if not listvo then return end;
	local ridelevel = RankListModel.mountDetaied.rideLevel
	local mountinfo = RankListUtils:GetMountVO(ridelevel)
	if not mountinfo then return end;
	local iconname = MountUtil:GetMountIconName(mountinfo.mountLevel, "shuzi_nameIcon", listvo.role)--RankListModel.roleDetaiedinfo.prof
	objSwf.nameLoader.source =  ResUtil:GetMountIconName(iconname)
	
	local lvlStr = tostring(mountinfo.mountLevel);
	lvlStr = RankListUtils:GetlvlSource(lvlStr)
	objSwf.lvlLoader.num = lvlStr
--	objSwf.tflevel.text = string.format( StrConfig['rankstr003'],listvo.lvl)
end;
function UIRankListRightMount:ClosePanle()
	self:Hide();
end;


function UIRankListRightMount:RefreshData()
	-- 刷新数据就行
	self:ShowList();
	self:ShowSkillList();
	if RankListModel.mountDetaied.rideLevel > 0 then 
		local modelid = RankListUtils:GetPlayerMountModelId(RankListModel.mountDetaied.rideLevel,RankListModel.mountDetaied.roleID)
		self:MountDraw(modelid);
	end;
end;

function UIRankListRightMount:MountDraw(modelid)
	--print(modelid,"这怎么了")
	if not modelid then return end;
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local mountAvatar = CHorseAvatar:new(modelid)
	mountAvatar:Create(modelid);
	
	self.curModel = mountAvatar;
	local drawcfg = UIDrawMountConfigMax[modelid]
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();
		return 
	end;
	
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("RanklistMount",mountAvatar, objSwf.modelload,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000,"UIMount");
	else 
		self.objUIDraw:SetUILoader(objSwf.modelload);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(mountAvatar);
	end;
	-- 模型旋转
	self.curModel.objMesh.transform:setRotation(0,0,1,drawcfg.Rotation);
	self.objUIDraw:SetDraw(true);

end;

UIRankListRightMount.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
									VPort = _Vector2.new(1200,800),
									Rotation = 0,
								  };

function UIRankListRightMount:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end;