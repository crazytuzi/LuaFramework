local tbUi = Ui:CreateClass("AwardTips");

local ANI_MOVE_TIME = 2; --延迟关闭时间

local FULL_WIDTH = 110 * 5
local FULL_HEIGH = 110 * 3



function tbUi:OnOpen(tbAward, nLogWay)
	local tbShowAward = {}
	local tbCanGetType = self.tbCanGetType
	for i,v in ipairs(tbAward) do
		local nType = Player.AwardType[v[1]]
		if nType and nType ~= Player.award_type_exp and nType ~= Player.award_type_basic_exp and nType ~= Player.award_type_cook_material then
			table.insert(tbShowAward, v)
		end
		if #tbShowAward >= 15 then
			break;
		end
	end

	local nNum = #tbShowAward
	if nNum == 0 then
		return 0;
	end
	local nLine = math.ceil(nNum / 5)
	self.nLine = nLine

	local nCurWidth = FULL_WIDTH
	if nLine == 1 and nNum < 5 then
		nCurWidth = nCurWidth * nNum / 5
	end

	local nCurHeight = 110 * self.nLine

	for i = 2, nLine do
		self.pPanel:SetActive("Container" .. i, true)
	end

	for i = nLine + 1, 3 do
		self.pPanel:SetActive("Container" .. i, false)
	end

	for i, v in ipairs(tbShowAward) do
		local tbGrid = self["itemframe" ..i]
		tbGrid.pPanel:SetActive("Main", true)
		tbGrid:SetGenericItem(v)
		tbGrid.fnClick = tbGrid.DefaultClick
		tbGrid.pPanel:ChangePosition("Main", -330  + 110 *( i - 5 * (math.floor((i -1)/5))),  0)
		tbGrid.pPanel:Wnd_Scale("Main", 0.7,0.7)
	end
	for i = nNum + 1, 5 * nLine do
		self["itemframe" ..i].pPanel:SetActive("Main", false)
	end

	local nPosX, nPosY = ( FULL_WIDTH - nCurWidth ) / 2, 45;-- (nCurHeight - FULL_HEIGH) / 2
	if nLine ~= 1 then
		nPosY = 70;
	end

	self.pPanel:ChangePosition("Main", nPosX, nPosY)

	self.pPanel:PlayUiAnimation("AwardTip", false, false, {});

	self.nCLoseTimer = Timer:Register(math.floor(Env.GAME_FPS * ANI_MOVE_TIME) , function ()
		self.nCLoseTimer = nil;
		Ui:CloseWindow(self.UI_NAME)
	end)
end

function tbUi:OnClose()
	self.pPanel:StopUiAnimation("AwardTip_" ..  self.UI_NAME);
	if self.nCLoseTimer then
		Timer:Close(self.nCLoseTimer);
		self.nCLoseTimer = nil;
	end
end