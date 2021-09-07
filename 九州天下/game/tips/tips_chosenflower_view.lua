require("game/flowers/flowers_ctrl")

TipsChosenFlowerView = TipsChosenFlowerView or BaseClass(BaseView)

function TipsChosenFlowerView:__init()
	self.ui_config = {"uis/views/tips/chosenflowertips","FlowerListView"}

	self.callback = nil

	self.flower_name1 = Language.Flower.OneRose
	self.flower_name2 = Language.Flower.Rose99
	self.flower_name3 = Language.Flower.Rose520
	self.flower_name4 = Language.Flower.Rose999

	self.flower_id1 = 26903
	self.flower_id2 = 26904
	self.flower_id3 = 26905
	self.flower_id4 = 26906

	self.flower_num1 = 0
	self.flower_num2 = 0
	self.flower_num3 = 0
	self.flower_num4 = 0
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsChosenFlowerView:__delete()
	self.callback = nil
end

function TipsChosenFlowerView:ReleaseCallBack()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil

	-- 清理变量和对象
	self.flower_text1 = nil
	self.flower_text2 = nil
	self.flower_text3 = nil
	self.flower_text4 = nil
end

function TipsChosenFlowerView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseView,self))

	self:ListenEvent("ChosenFlower01", BindTool.Bind(self.ChosenFlower01,self))
	self:ListenEvent("ChosenFlower02", BindTool.Bind(self.ChosenFlower02,self))
	self:ListenEvent("ChosenFlower03", BindTool.Bind(self.ChosenFlower03,self))
	self:ListenEvent("ChosenFlower04", BindTool.Bind(self.ChosenFlower04,self))

	self.flower_text1 = self:FindVariable("flower_text1")
	self.flower_text2 = self:FindVariable("flower_text2")
	self.flower_text3 = self:FindVariable("flower_text3")
	self.flower_text4 = self:FindVariable("flower_text4")

	self.item_list = {}
	for i = 1, 4 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item" .. i))
		item_cell:SetData()
		table.insert(self.item_list, item_cell)
	end
end

function TipsChosenFlowerView:OpenCallBack()
	self.flower_num1 = ItemData.Instance:GetItemNumInBagById(self.flower_id1)
	self.flower_num2 = ItemData.Instance:GetItemNumInBagById(self.flower_id2)
	self.flower_num3 = ItemData.Instance:GetItemNumInBagById(self.flower_id3)
	self.flower_num4 = ItemData.Instance:GetItemNumInBagById(self.flower_id4)

	self.flower_text1:SetValue(self.flower_num1)
	self.flower_text2:SetValue(self.flower_num2)
	self.flower_text3:SetValue(self.flower_num3)
	self.flower_text4:SetValue(self.flower_num4)

	for k, v in ipairs(self.item_list) do
		local item_data = {}
		item_data.item_id = self["flower_id" .. k]
		item_data.num = 1
		item_data.is_bind = 0
		v:SetData(item_data)
	end
end

function TipsChosenFlowerView:CloseView()
	self:Close()
end

function TipsChosenFlowerView:ChosenFlower01()
	if self.callback ~= nil then
		self.callback(self.flower_name1,self.flower_id1,self.flower_num1)
	end
	self:Close()
end

function TipsChosenFlowerView:ChosenFlower02()
	if self.callback ~= nil then
		self.callback(self.flower_name2,self.flower_id2,self.flower_num2)
	end
	self:Close()
end

function TipsChosenFlowerView:ChosenFlower03()
	if self.callback ~= nil then
		self.callback(self.flower_name3,self.flower_id3,self.flower_num3)
	end
	self:Close()
end

function TipsChosenFlowerView:ChosenFlower04()
	if self.callback ~= nil then
		self.callback(self.flower_name4,self.flower_id4,self.flower_num4)
	end
	self:Close()
end

function TipsChosenFlowerView:SetCallBack(callback)
	self.callback = callback
end