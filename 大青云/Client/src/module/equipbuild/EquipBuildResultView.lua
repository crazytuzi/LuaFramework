--[[
 装备打造结果
 wangshuai
]]

_G.UIEquipBuildResult = BaseUI:new("UIEquipBuildResult")

UIEquipBuildResult.curData = {}
UIEquipBuildResult.curItem = {};

function UIEquipBuildResult:Create()
	self:AddSWF("equipBuildResult.swf",true,"center")
end;

function UIEquipBuildResult:OnLoaded(objSwf)
	objSwf.closeBtn.click = function() self:ClosePanel()end;
	objSwf.btnOKOK.click = function() self:ClosePanel()end; 
	objSwf.btnGoBag.click = function() self:BtnGoBag()end;

	objSwf.rewardlist.itemRollOver = function(e) self:RewardOver(e)end;
	objSwf.rewardlist.itemRollOut = function()TipsManager:Hide()end;

	objSwf.fpx1.playOver = function() self:FpxPlayerOver()end;
end;

function UIEquipBuildResult:FpxPlayerOver()
	local objSwf = self.objSwf;
	objSwf.fpx1:gotoAndStop(35)
	objSwf.fpx2:gotoAndStop(35)
end;
function UIEquipBuildResult:SetFpx()
	local objSwf = self.objSwf;
	objSwf.fpx1:gotoAndPlay(1);
	objSwf.fpx2:gotoAndPlay(1);
end;

function UIEquipBuildResult:RewardOver(e)
	if not e.item then return end;
	if not e.item.indexc then return end;
	local index = e.item.indexc
	local cfg = self.curDatalist[index];

	local objSwf = self.objSwf;
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(e.item.id,1,1);
	if not itemTipsVO then return; end
	itemTipsVO.superVO = {};
	itemTipsVO.superVO.superList = cfg.superList;
	itemTipsVO.superVO.superNum = cfg.superNum;
	itemTipsVO.newSuperList = cfg.newSuperList;
	itemTipsVO.extraLvl = cfg.extraLvl
	itemTipsVO.groupId = cfg.groupId;
	itemTipsVO.groupId2 = cfg.groupId2;
	itemTipsVO.groupId2Level = cfg.groupId2Level;
	itemTipsVO.bindState = cfg.bind == 1 and  BagConsts.Bind_Bind or BagConsts.Bind_UseUnBind;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;



function UIEquipBuildResult:RewardOut()

end;

function UIEquipBuildResult:OnShow()
	self:SetData();
	self:SetItem();
	self:SetFpx();
end

function UIEquipBuildResult:OnHide()

end;

function UIEquipBuildResult:SetData()
	self.curDatalist = EquipBuildModel.ResultDataList;
	self:Show()
end;

function UIEquipBuildResult:SetItem()
	local objSwf = self.objSwf;
	local list = {};
	for i,info  in ipairs(self.curDatalist) do 
		local itemvo = RewardSlotVO:new()
		itemvo.id = info.cid
		itemvo.count = 1;
		itemvo.bind = info.bind == 1 and  BagConsts.Bind_Bind or BagConsts.Bind_None;
		local itemvo2 = UIData.decode(itemvo:GetUIData())
		itemvo2.indexc = i;
		table.push(list,UIData.encode(itemvo2))
	end;
	objSwf.rewardlist.dataProvider:cleanUp();
	objSwf.rewardlist.dataProvider:push(unpack(list));
	objSwf.rewardlist:invalidateData()
end;



function UIEquipBuildResult:ClosePanel()
	self:Hide();
end;

function UIEquipBuildResult:BtnGoBag()
	FuncManager:OpenFunc(FuncConsts.Bag)
	self:Hide();
end; 

