--
-- @Author: LaoY
-- @Date:   2019-11-21 15:39:14
--

require("common/input/GMTestItem")
GMTestPanel = GMTestPanel or class("GMTestPanel",BaseItem)

function GMTestPanel:ctor(parent_node,layer)
	self.abName = "debug"
	self.assetName = "GMTestPanel"
	self.layer = layer

	self.item_list = {}
	GMTestPanel.super.Load(self)
end

function GMTestPanel:dctor()
	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}
end

function GMTestPanel:LoadCallBack()
	self.nodes = {
		"GmItem","GMTestItem"
	}
	self:GetChildren(self.nodes)

	self.GmItem_gameObject = self.GmItem.gameObject
    SetVisible(self.GmItem, false)

    self.GMTestItem_gameObject = self.GMTestItem.gameObject
    SetVisible(self.GMTestItem, false)

	self:AddEvent()

	self:UdpateView()
end

function GMTestPanel:AddEvent()
end

function GMTestPanel:SetData(data)
end

function GMTestPanel:UdpateView()
	local list = {
		{name = "ccmove_upper left",call_back = handler(self,self.TestCCMove1)},
		{name = "ccmove_upper right",call_back = handler(self,self.TestCCMove2)},
		{name = "ccmove_up",call_back = handler(self,self.TestCCMove3)},
		{name = "ccmove_left",call_back = handler(self,self.TestCCMove4)},
		{name = "ccmove_right",call_back = handler(self,self.TestCCMove5)},
		{name = "Ccmove_left lower",call_back = handler(self,self.TestCCMove6)},
		{name = "Ccmove_right lower",call_back = handler(self,self.TestCCMove7)},
		-- {name = "1_EaseOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseOut)},
		-- {name = "2_EaseInOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseInOut)},
		-- {name = "3_EaseExponentialOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseExponentialOut)},
		-- {name = "4_EaseExponentialInOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseExponentialInOut)},
		-- {name = "5_EaseSineOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseSineOut)},
		-- {name = "6_EaseSineInOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseSineInOut)},
		-- {name = "7_EaseElasticOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseElasticOut)},
		-- {name = "8_EaseBounceOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseBounceOut)},
		-- {name = "9_EaseBounceInOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseBounceInOut)},
		-- {name = "10_EaseBackOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseBackOut)},
		-- {name = "11_EaseBackInOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseBackInOut)},
		-- {name = "12_EaseQuadraticActionOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseQuadraticActionOut)},
		-- {name = "13_EaseQuadraticActionInOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseQuadraticActionInOut)},
		-- {name = "14_EaseQuarticActionOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseQuarticActionOut)},
		-- {name = "15_EaseQuarticActionInOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseQuarticActionInOut)},
		-- {name = "16_EaseQuinticActionOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseQuinticActionOut)},
		-- {name = "17_EaseQuinticActionInOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseQuinticActionInOut)},
		-- {name = "18_EaseCircleActionOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseCircleActionOut)},
		-- {name = "19_EaseCircleActionInOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseCircleActionInOut)},
		-- {name = "20_EaseCubicActionOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseCubicActionOut)},
		-- {name = "21_EaseCubicActionInOut",call_back = handler(self,self.TestCCMoveOut,cc.EaseCubicActionInOut)},

		{name = "<color=#eb0000>domove_Upper left</color>",call_back = handler(self,self.TestDoMove1)},
		{name = "<color=#eb0000>domove_Upper right</color>",call_back = handler(self,self.TestDoMove2)},
		{name = "<color=#eb0000>domove_Up</color>",call_back = handler(self,self.TestDoMove3)},
		{name = "<color=#eb0000>domove_Left</color>",call_back = handler(self,self.TestDoMove4)},
		{name = "<color=#eb0000>domove_Right</color>",call_back = handler(self,self.TestDoMove5)},
		{name = "<color=#eb0000>domove_Down left</color>",call_back = handler(self,self.TestDoMove6)},
		{name = "<color=#eb0000>domove_Down right</color>",call_back = handler(self,self.TestDoMove7)},

		{name = "FPS 30",call_back = handler(self,self.FrameRate,30)},
		{name = "FPS 45",call_back = handler(self,self.FrameRate,45)},
		{name = "FPS 60",call_back = handler(self,self.FrameRate,60)},
		{name = "Popup window",call_back = handler(self,self.ShowText)},
	}


	for i,v in ipairs(list) do
		local item = GmItem(self.GmItem_gameObject, self.transform)
		local x = ((i-1)%5 + 1 - 3) * 200
		local y = (3 - math.floor((i-1)/5)) * 70
		item:SetPosition(x,y)
		item:SetCallBack(v.call_back)
		item:SetData(v)
		self.item_list[i] = item
	end
end

function GMTestPanel:FrameRate(rate)
	Application.targetFrameRate = rate
end

function GMTestPanel:TestCCMoveOut(rateAction)
	Yzprint('--rateAction==>',rateAction.__cname)
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartAction(pos(ScreenWidth * 0.5 - 50,ScreenHeight * 0.5 - 50),rateAction)
end

function GMTestPanel:TestCCMove1()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartAction(pos(-ScreenWidth * 0.5 + 50,ScreenHeight * 0.5 - 50))
end

function GMTestPanel:TestCCMove2()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartAction(pos(ScreenWidth * 0.5 - 50,ScreenHeight * 0.5 - 50))
end

function GMTestPanel:TestCCMove3()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartAction(pos(0,ScreenHeight * 0.5 - 50))
end

function GMTestPanel:TestCCMove4()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartAction(pos(-ScreenWidth * 0.5 + 50,0))
end

function GMTestPanel:TestCCMove5()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartAction(pos(ScreenWidth * 0.5 - 50,0))
end

function GMTestPanel:TestCCMove6()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartAction(pos(-ScreenWidth * 0.5 + 50,-ScreenHeight * 0.5 + 50))
end

function GMTestPanel:TestCCMove7()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartAction(pos(ScreenWidth * 0.5 - 50,-ScreenHeight * 0.5 + 50))
end

function GMTestPanel:ShowText()
	Notify.ShowText("Test window")
end


function GMTestPanel:TestDoMove1()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartDoMove(pos(-ScreenWidth * 0.5 + 50,ScreenHeight * 0.5 - 50))
end

function GMTestPanel:TestDoMove2()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartDoMove(pos(ScreenWidth * 0.5 - 50,ScreenHeight * 0.5 - 50))
end

function GMTestPanel:TestDoMove3()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartDoMove(pos(0,ScreenHeight * 0.5 - 50))
end

function GMTestPanel:TestDoMove4()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartDoMove(pos(-ScreenWidth * 0.5 + 50,0))
end

function GMTestPanel:TestDoMove5()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartDoMove(pos(ScreenWidth * 0.5 - 50,0))
end

function GMTestPanel:TestDoMove6()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartDoMove(pos(-ScreenWidth * 0.5 + 50,-ScreenHeight * 0.5 + 50))
end

function GMTestPanel:TestDoMove7()
	local item = GMTestItem(self.GMTestItem_gameObject, self.transform)
	item:StartDoMove(pos(ScreenWidth * 0.5 - 50,-ScreenHeight * 0.5 + 50))
end