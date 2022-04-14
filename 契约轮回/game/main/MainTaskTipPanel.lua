--
-- @Author: LaoY
-- @Date:   2019-05-16 17:11:31
--
MainTaskTipPanel = MainTaskTipPanel or class("MainTaskTipPanel",BasePanel)

function MainTaskTipPanel:ctor()
	self.abName = "main"
	self.assetName = "MainTaskTipPanel"
	self.layer = LayerManager.LayerNameList.Bottom

	self.use_background = true
	self.click_bg_close = true

	self.item_list = {}
end

function MainTaskTipPanel:dctor()
	for k,v in pairs(self.item_list) do
		v:destroy()
	end
	self.item_list = {}
end

function MainTaskTipPanel:Open(link_list)
	self.link_list = link_list
	MainTaskTipPanel.super.Open(self)
end

function MainTaskTipPanel:LoadCallBack()
	self.nodes = {
		"MainTaskTipItem","img_bg",
	}
	self:GetChildren(self.nodes)

	if self.background_img then
		SetColor(self.background_img, 0, 0, 0, 0)
	end

	local height = GetSizeDeltaY(self.img_bg)
	local y = GetLocalPositionY(self.img_bg)
	self.img_top_y = y + height * 0.5

	SetAlignType(self.transform, bit.bor(AlignType.Left, AlignType.Null))

	self.MainTaskTipItem_gameObject = self.MainTaskTipItem.gameObject
	SetVisible(self.MainTaskTipItem,false)
	self:AddEvent()
end

function MainTaskTipPanel:AddEvent()

end

function MainTaskTipPanel:OpenCallBack()
	self:UpdateView()
end

function MainTaskTipPanel:UpdateView( )
	local tab = self.link_list or self:GetDefalutShowList()


	local list = tab
	local len = #tab
	local function callback()
		self:Close()
	end

	local img_height = 15
	for i=1, len do
		local item = self.item_list[i]
		if not item then
			item = MainTaskTipItem(self.MainTaskTipItem_gameObject,self.img_bg)
			self.item_list[i] = item
			item:SetCallBack(callback)
		else
			item:SetVisible(true)
		end
		item:SetData(i,list[i])
		img_height = img_height + 50
	end

	SetSizeDeltaY(self.img_bg,img_height)
	local y = self.img_top_y - img_height * 0.5
	SetLocalPositionY(self.img_bg,y)
end

function MainTaskTipPanel:GetDefalutShowList()
	local t = {}
	if TaskModel.GetInstance():GetTaskIdByType(enum.TASK_TYPE.TASK_TYPE_DAILY) then
		t[#t+1] = {text = "Daily Quests",param = function()
			TaskModel.GetInstance():DoTaskByType(enum.TASK_TYPE.TASK_TYPE_DAILY)
		end}
	end

	if DungeonModel:GetInstance():GetExpDunTimes() then
		t[#t+1] = {text = "Temple of Trial",param = {150,1,1,2}}
	end

	if WelfareModel:GetInstance():CheckGrailTimes() then
		t[#t+1] = {text = "Daily Prayer",param = {500,1,5}}
	end

	if FactionEscortModel:GetInstance():IsShowEscort() then
		t[#t+1] = {text = "Polar Breakthrough",param = {400,1}}
	end

	t[#t+1] = {text = "Auto Play",param = function()
			DailyModel:GetInstance():GoCurHookPos()
		end}
	return t
end

function MainTaskTipPanel:CloseCallBack(  )

end