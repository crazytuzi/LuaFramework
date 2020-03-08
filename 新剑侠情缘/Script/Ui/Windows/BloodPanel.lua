
local tbUi = Ui:CreateClass("BloodPanel");

tbUi.nShowSpecialNpcHpBarDis = 700; 

function tbUi:OnOpen(tbCampNpcs)	
	if not tbCampNpcs or not next(tbCampNpcs) then
		return 0;
	end
	self.tbCampNpcs = tbCampNpcs
	self.nUseMapTempalteId = me.nMapTemplateId
	self:CloseTimer()
	self.pPanel:SetActive("BarBg", false)
	self.nTimerId = Timer:Register(Env.GAME_FPS , function ()
		if not self:CheckShowNpcHp() then
			self.pPanel:SetActive("BarBg", false)
		end
		return  true
	end)
end

function tbUi:AddCampNpcID(nNpcID)
	self.tbCampNpcs = self.tbCampNpcs or {};
	self.tbCampNpcs[nNpcID] = 1;
end	

function tbUi:OnClose()
	self:CloseTimer()
end

function tbUi:CloseTimer()
	if self.nTimerId then
		Timer:Close(self.nTimerId)
		self.nTimerId = nil;
	end
end

function tbUi:CheckShowNpcHp()
	local tbCampNpcs = self.tbCampNpcs
	
	local _, x1, y1 = me.GetWorldPos()
	local nShowSpecialNpcHpBarDis = self.nShowSpecialNpcHpBarDis
	for nNpcId, v in pairs(tbCampNpcs) do
		local pNpc = KNpc.GetById(nNpcId)
		if pNpc then
			local _, x2, y2 = pNpc.GetWorldPos()
			if Lib:GetDistsSquare(x1, y1, x2, y2) <= nShowSpecialNpcHpBarDis^2 then
				self.pPanel:SetActive("BarBg",  true)
				self.pPanel:Label_SetText("Name", pNpc.szName)
				local fPersetn = pNpc.nCurLife / pNpc.nMaxLife
				self.pPanel:Label_SetText("Percent", string.format("%.1f%%", fPersetn* 100))
				self.pPanel:SliderBar_SetValue("BarBg", fPersetn);
				return true
			end
		end
	end
end

function tbUi:OnMapEnter(nMapTemplateID)
	if nMapTemplateID ~= self.nUseMapTempalteId then
		Ui:CloseWindow(self.UI_NAME)
	end
end


function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_MAP_ENTER,           		  self.OnMapEnter},
    };
end
