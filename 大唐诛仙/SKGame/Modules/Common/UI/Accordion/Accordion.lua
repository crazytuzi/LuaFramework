--[[口风琴组件
	数据元素:
		{[1]="大类唯一Id", [2]="大类名称", [3]={[1]= {[1]=小类Id1, [2]="小类名称1",}, [2]= {[1]=小类Id2, [2]="小类名称2", }}
	eg.
	 data ={
	 	[1]={[1]="1", [2]="战力榜", [3]={[1]= {[1]=1, [2]="综合",}, [2]={[1]= 2, [2]="龙卫",}},
	 	[2]={[1]="2", [2]="神兵榜", [3]={[1]= {[1]=1, [2]="综合",}, [2]={[1]= 2, [2]="龙卫",}},
	 	...
	 }
	 local accordion = Accordion.New()
	 accordion:SetData(data, function(selectData) 
	 		print(selectData[1]) 选中大类
	 		print(selectData[2]) 选中小类
	 end, 2, 1)
--]]
Accordion = BaseClass(LuaUI)
function Accordion:__init()
	self.ui = UIPackage.CreateObject("Common" , "CustomLayerV")
	self.ui:SetSize(180, 550)
	self.btns = {}
	self.curShow = nil
	self.callBack = nil
	self.selectItem = nil
	self.arrowVisible = true --  显示箭头
	self.clickBigInternal = 0.2
	self.clickSamllInternal = 0.3

	self.canClick = true
end

function Accordion:Touchable()
	self.ui.touchable = true
end

function Accordion:UnTouchable()
	self.ui.touchable = false
end

--设置数据
--@param data 数据
--@param callBack 选择回调
--@param defaultBig 默认选中大类
--@param defaultSamll 默认选中小类
function Accordion:SetData(data, callBack, defaultBig, defaultSamll)
	self.data = data
	self.callBack = callBack

	local y = 0
	for i = 1, #self.data do
		local tabBtn = AccordionBtn.New(self.arrowVisible)
		tabBtn:SetData(self.data[i], self)
		tabBtn:SetXY(2, y)
		y = y + tabBtn:GetMyHeight()
		self.ui:AddChild(tabBtn.ui)
		table.insert(self.btns, tabBtn)
	end

	if defaultBig then
		for i = 1, #self.btns do
			if self.btns[i].bigType == defaultBig then
				self.btns[i]:SelectSelf(true)
				return self.btns[i]:SetSelect(defaultSamll)
			end
		end
		return false
	end
end
-- 设置隐藏箭头更新成另一种复选 状态
function Accordion:SetArrowVisible( bool )
	self.arrowVisible = bool == true
end
-- 定向选择 (返回 是否找到)
function Accordion:SetSelect( bigType, subType )
	if bigType then
		for i = 1, #self.btns do
			if self.btns[i].bigType == bigType then
				return self.btns[i]:SetSelect(subType)
			end
		end
	end
	-- if #self.btns ~= 0 then
	-- 	self.btns[1]:SetSelect()
	-- end
	return false
end

function Accordion:HideAll()
	for i = 1, #self.btns do
		self.btns[i]:Hide()
	end
end

function Accordion:Layout()
	local y = 0
	for i = 1, #self.btns do
		self.btns[i]:SetXY(2, y)
		y = y + self.btns[i]:GetMyHeight()
	end
end

function Accordion:__delete()
	for i = 1, #self.btns do
		self.btns[i]:Destroy()
	end
	
	self.callBack = nil
	self.curShow = nil
	self.btns = nil
	self.selectItem = nil
end