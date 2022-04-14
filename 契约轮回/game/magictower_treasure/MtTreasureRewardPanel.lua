--
-- @Author: LaoY
-- @Date:   2018-12-22 16:50:08
--

MtTreasureRewardPanel = MtTreasureRewardPanel or class("MtTreasureRewardPanel",BaseRewardPanel)

function MtTreasureRewardPanel:ctor()
	self.abName = "magictower_treasure"
	self.assetName = "MtTreasureRewardPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true

	self.use_close_btn = true

	self.item_list = {}
	self.model = MagictowerTreasureModel:GetInstance()

	self.btn_list = {
		{btn_res = "common:btn_blue_2",btn_name = "Hunt x1",text = handler(self,self.GetButtonText,1),call_back = handler(self,self.ClickButton,1)},
		{btn_res = "common:btn_yellow_2",btn_name = "Hunt x10",text = handler(self,self.GetButtonText,2),call_back = handler(self,self.ClickButton,2)},
	}
end

function MtTreasureRewardPanel:dctor()
	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}
end

function MtTreasureRewardPanel:GetButtonText(index)
	local item_id,cost_count = self:GetCostInfo(index)
	local abName,assetName = GoodIconUtil:GetResNameByItemID(item_id)
	local name = ""
	local cf = Config.db_item[item_id]
	if cf then
		name = cf.name
	end
	local name = GoodIconUtil:GetGoodsName(item_id)
	local number = RoleInfoModel:GetInstance():GetRoleValue(item_id)
	local str = string.format("<quad name=%s:%s size=20 width=1 />%s (%s/%s)",abName,assetName,name,number,cost_count)
	return str
end

function MtTreasureRewardPanel:GetCostInfo(index)
	local cf = Config.db_mchunt[index]
	local cost = String2Table(cf.cost)[1]
	return cost[1],cost[2]
end

function MtTreasureRewardPanel:ClickButton(index)
	local item_id,cost_count = self:GetCostInfo(index)
	local function ok_func()
		self.model:Brocast(MagictowerTreasureEvent.REQ_HUNT,index)
		self:Close()
	end
	self.model:CheckGoods(cost_count,ok_func)
end

function MtTreasureRewardPanel:Open(reward)
	self.data = reward
	MtTreasureRewardPanel.super.Open(self)
end

function MtTreasureRewardPanel:LoadCallBack()
	self.nodes = {
		"con","text_des","GiftRewardMaigcItem",
	}
	self:GetChildren(self.nodes)

	self.text_des_component = self.text_des:GetComponent('Text')
	self.GiftRewardMaigcItem_gameobject = self.GiftRewardMaigcItem.gameObject
	SetVisible(self.GiftRewardMaigcItem,false)

	self:SetTitlePosition(195)

	self:AddEvent()
end

function MtTreasureRewardPanel:QuitMtT()
	-- lua_panelMgr:ClosePanel(MtTreasureMainPanel)
	self:Close()
end

function MtTreasureRewardPanel:ContinueMtT()
	lua_panelMgr:OpenPanel(MtTreasureMainPanel,1)
	self:Close()
end

function MtTreasureRewardPanel:AddEvent()

end

function MtTreasureRewardPanel:OpenCallBack()
	self:UpdateView()
end

function MtTreasureRewardPanel:UpdateView( )
	-- self.data = {
	-- 	[90010003] = 1,
	-- 	[90010004] = 1,
	-- 	[90010005] = 1,
	-- 	[20001] = 1,
	-- 	[20002] = 1,
	-- 	[20003] = 1,
	-- 	[20004] = 1,
	-- 	[20005] = 1,
	-- 	[20006] = 4,
	-- }
	if not self.data then
		return
	end
	local count = 0
	local money_list = {}
	local tab = Stack2List(self.data,true)
	local len = #tab
	for i=1,len do
		local item_id = tab[i][1]
		local num = tab[i][2]
		local cf = Config.db_item[item_id]
		if cf and cf.type == enum.ITEM_TYPE.ITEM_TYPE_MONEY then
			money_list[#money_list+1] = {cf.id,num}
		else
			count = count + 1
			local item = self.item_list[count]
			if not item then
				item = GiftRewardMaigcItem(self.GiftRewardMaigcItem_gameobject,self.con)
				self.item_list[count] = item
			else
				item:SetVisible(true)
			end
			item:SetData(count,item_id,num)
		end
	end

	for i=count+1,#self.item_list do
		local item = self.item_list[i]
		item:SetVisible(false)
	end

	if count <= 5 then
		self:SetButtonConPosition(-250)
		self:SetBackgroundHeight(302)
		SetLocalPositionY(self.con,35)
		SetLocalPositionY(self.text_des,-90)
	else
		SetLocalPositionY(self.con,0)
		self:SetButtonConPosition(-300)
		self:SetBackgroundHeight(430)
		SetLocalPositionY(self.text_des,-215)
	end

	if not table.isempty(money_list) then
		SetVisible(self.text_des,true)
		self.text_des_component.text = self:GetMoneyTypeText(money_list)
	else
		SetVisible(self.text_des,false)
	end
end

function MtTreasureRewardPanel:CloseCallBack(  )

end