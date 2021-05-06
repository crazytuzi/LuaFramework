local CTestView = class("CTestView", CViewBase)

function CTestView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Test/TestView.prefab", cb)

	-- self.m_ExtendClose = "Black"
end

function CTestView.OnCreateView(self)
	self.m_TestCnt = 0
	self.m_TestBtn = self:NewUI(1, CButton)
	self.m_Table = self:NewUI(2, CTable)
	self.m_BoxClone = self:NewUI(3, CBox)
	self.m_Texture = self:NewUI(4, CTexture)
	-- self.m_Live2dTexture = self:NewUI(4, CActorTexture)
	self.m_CardClone = self:NewUI(5, CBox)
	self.m_CardGrid = self:NewUI(6, CDragGrid)
	self.m_SelBtn = self:NewUI(7, CBox)
	self.m_SelGrid = self:NewUI(8, CGrid)
	self.m_WrapContent = self:NewUI(9, CWrapContent)
	self.m_WrapBox = self:NewUI(10, CBox)
	self.m_LongPressBtn = self:NewUI(11, CButton)
	self.m_BoxClone:SetActive(false)
	self.m_CardClone:SetActive(false)
	self.m_CloseBtn  =self:NewUI(12, CButton)
	self.m_Label = self:NewUI(13, CLabel)
	self.m_ContentScrollView = self:NewUI(14, CScrollView)
	self.m_MyBox = self:NewUI(15, CBox)
	self.m_SpineTexture = self:NewUI(16, CSpineTexture)
	self.m_SpineTexture:SetActive(false)
	self.m_SpineTexture1 = self:NewUI(17, CSpineTexture)
	self.m_SpineTexture:ShapeCommon(503)
	self.m_SpineTexture1:ShapeCommon(503)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TestBtn:AddUIEvent("click", callback(self, "OnTest10"))

	self.m_ItemScrollView = self:NewUI(18, CScrollView)
	self.m_ItemBox = self:NewUI(19, CBox)
	self.m_ItemGrid = self:NewUI(20, CGrid)
	-- self.m_SelBtn:AddUIEvent("click", callback(self, "OnClickSel"))
	-- self.m_LongPressBtn:AddUIEvent("longpress", callback(self, "OnLongPress"))
	-- self.m_Texture:ChangeShape(1004)
	-- self.m_Texture:LoadModel(1001)
	-- self:OnTest10()
	-- self:OnTest2()
	-- local function f()
	-- 	local w, h = self.m_ActorTexture:GetSize()
	-- 	local texture = Utils.ScreenShoot(g_CameraCtrl:GetUICamera(), w, h)
	-- 	self.m_ActorTexture:SetMainTexture(texture)
	-- end
	-- Utils.AddTimer(f, 0, 0)

	-- self.m_TestBtn:SetText("#w1 001")
	-- self.m_TestBtn:SetText("#w1 0201")
	--self:TestScrollBox()
	--self:OnTest9()
	self:TestPanelBox()
end

function CTestView.OnTest10(self)
	--local t = {1,1,1,1,1,1,1}
	--self.m_WrapContent:SetData(t)
	--self.m_WrapContent:MoveRelative()
	self.m_SpineTexture:ShapeCommon(303)
	--[[
	self.m_SpineTexture1:SetSpineComplete(function ()
		printc("SetSpineComplete")
	end)
	]]
	local time = os.time()
	self.m_SpineTexture1:ShapeCommon(1014, function ()
		
		self.m_SpineTexture1:SetAnimation(0, "idle11", true, 
			function () 
				printc(os.time() - time)
				time = os.time()
				--printc("Start--->>>>>>>>>>>-show") 
			end,
			function () 
				--printc("Complete--->>>>>>>>>>>-show") 
			end
		)
		

		self.m_SpineTexture1:AddAnimation(0, "show", false, nil,
			function () 
				printc(os.time() - time)
				time = os.time()
				--printc("Start--->>>>>>>>>>>-talk") 
			end,
			function () 
				--printc("Complete--->>>>>>>>>>>-talk") 
			end
		)

		self.m_SpineTexture1:AddAnimation(0, "talk", false, nil,
			function () 
				printc(os.time() - time)
				time = os.time()
				--printc("Start--->>>>>>>>>>>-talk") 
			end,
			function () 
				--printc("Complete--->>>>>>>>>>>-talk") 
			end
		)
		

		self.m_SpineTexture1:AddAnimation(0, "idle", true, nil,
			function ()
				printc(os.time() - time)
				time = os.time()
				--printc("Start--->>>>>>>>>>>-idle")
			end,
			function () 
				--printc("Complete--->>>>>>>>>>>-idle") 
			end
		)

		end
	)
end

function CTestView.OnLongPress(self, oBtn, bPress)
	g_NotifyCtrl:FloatMsg("长按"..tostring(bPress))
end

function CTestView.OnTest9(self)
	self.m_WrapContent:SetCloneChild(self.m_WrapBox, 
		function(oChild)
			oChild.m_Grid = oChild:NewUI(1, CGrid)
			oChild.m_Star = oChild:NewUI(2, CSprite)
			oChild.m_Star:SetActive(false)
			return oChild
		end)
	
	self.m_WrapContent:SetRefreshFunc(function(oChild, dData)
		if dData then
			printc(oChild.m_Grid:GetCount())
			oChild.m_Grid:InitChild(function (obj, index)
				local oBox = CBox.New(obj)
				return obj
				-- body
			end)

			oChild.m_Grid:Clear()
			for i = 1, dData do
				local star = oChild.m_Star:Clone()
				star:SetActive(true)
				oChild.m_Grid:AddChild(star)
			end
			oChild:SetActive(true)
		else
			oChild:SetActive(false)
		end
	end)
	local t = {10}
	self.m_WrapContent:SetData(t)
end


function CTestView.OnTest6(self)
	self.m_CardGrid:Clear()
end

function CTestView.OnClickSel(self, oBox)
	if oBox:GetSelected() then
		printc("seleced")
	else
		printc("not seleced")
	end
end

function CTestView.OnTest7(self)
	self.m_SelGrid:Clear()
	self.m_SelBtn:SetActive(false)
	for i=1, 10 do
		local btn = self.m_SelBtn:Clone()
		btn:SetActive(true)
		btn:SetGroup(self.m_SelGrid:GetInstanceID())
		self.m_SelGrid:AddChild(btn)
	end
	self.m_SelGrid:Reposition()


	for i = 1, 4 do
		local btn = self.m_SelGrid:GetChild(i)
		if btn then
			btn:SetSelected(true)
		end
	end
end

function CTestView.OnTest5(self)
	-- for i=1, 10 do
	-- 	local oClone = self.m_CardClone:Clone()
	-- 	oClone:SetActive(true)
	-- 	local oLabel = oClone:NewUI(1, CLabel)
	-- 	oLabel:SetText(tostring(i))
	-- 	self.m_CardGrid:AddChild(oClone)
	-- end
	self.m_CardGrid.m_CellWidth = 100
	self.m_CardGrid.m_ShowCnt = 2
	self.m_CardGrid.m_WaitShowCnt = 1
	self.m_CardGrid.m_WaitOffset = Vector3.New(-12, -15, 0)
	self.m_CardGrid:SetCloneChild(self.m_CardClone, 
		function(oChild, idx)
			oChild:SetName(tostring(idx))
			oChild.m_Label = oChild:NewUI(1, CLabel)
			oChild:SetActive(true)
			return oChild
		end)
	self.m_CardGrid:SetRefreshFunc(function(oChild, dData)
		oChild.m_Label:SetText(tostring(dData))
	end)
	local t = {}
	for i =1, 3 do
		table.insert(t, i)
	end
	self.m_CardGrid:InitGrid()
	self.m_CardGrid:RefresAll(t)
end

function CTestView.OnTest(self)
	local sCacheKey = "CTestView.Box"
	self.m_Table:Recycle(function(oBox) return {name = oBox:GetName()} end)
	-- self.m_Table:Clear()

	for i = 1, Utils.RandomInt(1,50) do
		local atlasname = table.randomkey(data.dynamicatlasdata.DATA)
		local key = table.randomkey(data.dynamicatlasdata.DATA[atlasname])
		local name = string.format("%s_%s", atlasname, key)
		-- local oBox = self.m_BoxClone:Clone()
		local oBox = g_ResCtrl:GetObjectFromCache(sCacheKey, {name=name})
		if not oBox then
			oBox = self.m_BoxClone:Clone()
			oBox:SetCacheKey(sCacheKey)
			oBox:SetActive(true)
			oBox.m_Sprite = oBox:NewUI(1, CSprite)
		end
		oBox:SetName(name)
		oBox.m_Sprite:DynamicSprite(atlasname, key)
		self.m_Table:AddChild(oBox)
	end
end

function CTestView.OnTest2(self)
	local list = {130,140, 130, 140}
	self.m_TestCnt = self.m_TestCnt % #list + 1

	local list2 = {2100, 2000, 2000, 2100}
	self.m_ActorTexture:ChangeShape(list[self.m_TestCnt], {weapon = list2[self.m_TestCnt]})
end

function CTestView.OnTest3(self)
	-- for 
end

function CTestView.TestScrollBox(self)
	self.m_BtnList = {}
	for i = 1, 3 do
		local btn = self.m_MyBox:NewUI(i, CButton)
		self.m_BtnList[i] = btn
	end
	self.m_Touch = self.m_MyBox:NewUI(5, CWidget)
	self.m_BtnWidget = self.m_MyBox:NewUI(4, CWidget)
	self.m_Touch:AddUIEvent("drag", callback(self, "OnDrag"))
	self.m_Touch:AddUIEvent("dragend", callback(self, "OnDragEnd"))
end

function CTestView.OnDrag(self, obj, moveDelta)
	--table.print(obj)
	printc(moveDelta)
	local v = self.m_BtnWidget:GetLocalPos()
	v.x = v.x+moveDelta.x
	self.m_BtnWidget:SetLocalPos(v)
end

function CTestView.OnDragEnd(self)
	printc("dragend")
end

function CTestView.OnDragStart(self)
	printc("OnDragStart")
end

function CTestView.OnDrag(self, obj, delta)
	table.print(delta,"---------------------delta")
end

function CTestView.OnDragEnd(self)
	printc("OnDragEnd")
end

function CTestView.TestPanelBox(self)
	--[[
	self.m_Items = {}
	self.m_Pos = Vector3.New(0, 0, 0)
	for i=1,10 do
		local oBox = self.m_ItemBox:Clone()
		oBox.m_Sprite = oBox:NewUI(1, CSprite)
		self.m_Pos.x = 100 * i
		oBox:SetParent(self.m_ItemScrollView.m_Transform)
		oBox:SetLocalPos(self.m_Pos)
		oBox:SetLocalScale(Vector3.one)
		oBox:SetActive(true)
		self.m_Items[i] = oBox
	end
	]]
	--Utils.AddTimer(callback(self, "UpdateDepth"), 0, 0)
	self.m_ItemBox:SetActive(false)
	self.m_Items = {}
	for i=1,10 do
		local oBox = self.m_ItemBox:Clone()
		oBox:SetActive(true)
		oBox:AddUIEvent("click", callback(self, "OnCenter"))
		self.m_ItemGrid:AddChild(oBox)
		self.m_Items[i] = oBox
	end
	self.m_ItemGrid:Reposition()

	Utils.AddTimer(callback(self, "UpdateScale"), 0, 0)
end

function CTestView.UpdateScale(self)
	local tablePos = self.m_ItemScrollView:GetLocalPos().x
	for i,v in ipairs(self.m_Items) do
		local scaleValue = 1 - (math.abs(v:GetLocalPos().x + tablePos)) * 0.002
		if scaleValue < 0.5 then
			scaleValue = 0.5
		end
		v:SetDepth(self:GetDepth() + 100 * scaleValue)
		v:SetLocalScale(Vector3.New(scaleValue, scaleValue, scaleValue))
	end
	return true
end

function CTestView.OnCenter(self, oBox)
	self.m_ItemScrollView:CenterOn(oBox.m_Transform)
end

return CTestView