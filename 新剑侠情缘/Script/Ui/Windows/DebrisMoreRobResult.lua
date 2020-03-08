
local tbUi = Ui:CreateClass("DebrisMoreRobResult");

local tbAniSetting = 
{
	{
	
		{300, 207, 0, 207, 0.5},
		{0, 1, 0.5},
	},
	{
	
		{300, 99, 0, 99, 0.5},
		{0, 1, 0.5},
	},
	{
	
		{300, -9, 0, -9, 0.5},
		{0, 1, 0.5},
	},
	{
	
		{300, -117, 0, -117, 0.5},
		{0, 1, 0.5},
	},
	{
	
		{300, -225, 0, -225, 0.5},
		{0, 1, 0.5},
	},
}


function tbUi:OnOpen(tbAwards)
	self.nGetDebrrisItemId = nil
	
	for i = 1, 5 do
		self.pPanel:SetActive("list"..i, false)
	end

	self.tbAwards = tbAwards
	self:ShowAward(1);
end

function tbUi:OnClose()
	self.tbAwards = nil;
end

function tbUi:ShowAward(i)
	local tbAward = self.tbAwards[i]
	if not tbAward then
		return
	end
	local szList = "list" .. i;
	self.pPanel:SetActive(szList, true)
	self.pPanel:Tween_RunWhithStartPos(szList, unpack(tbAniSetting[i][1]) )
	self.pPanel:Tween_AlphaWithStart(szList, unpack(tbAniSetting[i][2]))

	local itemGrid = self["itemframe" .. i]
	itemGrid.fnClick = itemGrid.DefaultClick
	
	if tbAward[1] == "item" then
		itemGrid:SetItemByTemplate(tbAward[2], tbAward[3])
	elseif tbAward[1] == "EquipDebris" then
		self.nGetDebrrisItemId = tbAward[2]
		local tbBaseInfo = KItem.GetItemBaseProp(self.nGetDebrrisItemId);
		me.CenterMsg(string.format("恭喜您抢得了%s碎片%s", tbBaseInfo.szName, Lib:Transfer4LenDigit2CnNum(tbAward[3])))
		
		itemGrid:SetItemByTemplate(tbAward[2], nil, nil, nil, nil, tbAward[3]) 
	else
		itemGrid:SetDigitalItem(unpack(tbAward) );
	end
	Timer:Register(Env.GAME_FPS * 0.5, self.ShowAward, self, i + 1)
end
 
tbUi.tbOnClick = {}

function tbUi.tbOnClick:btnClose()
	Ui:CloseWindow(self.UI_NAME)
	if  self.nGetDebrrisItemId then
		UiNotify.OnNotify(UiNotify.emNOTIFY_GET_DEBRIS, self.nGetDebrrisItemId)
	end
end