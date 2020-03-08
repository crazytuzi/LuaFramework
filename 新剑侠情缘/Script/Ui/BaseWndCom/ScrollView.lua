
local tbUi = Ui:CreateClass("ScrollView");

function tbUi:OnCreate()
	self.pPanel:InitScrollView("Main");
end

function tbUi:Update(varCount, fnSetItem, nShowHintRowCount, pBackTop, pBackBottom)
	self.fnSetItem = fnSetItem
	local nCount = type(varCount) == "table" and #varCount or varCount
	self.pPanel:UpdateScrollView(nCount);

	if  nShowHintRowCount and pBackTop and pBackBottom then
		self.pBackTop = pBackTop
		self.pBackBottom = pBackBottom
		pBackTop.pPanel:SetActive("Main", false)
		pBackBottom.pPanel:SetActive("Main", false)
		if nCount > 20 then
			self.nShowGridMax = 0;
			--向上向下的先定死名字为 BackTop，BackBottom, grid class 里需要设置 pScrollView调用函数
			self.nShowHintRowCount = nShowHintRowCount
			self.nItemCountTotal = nCount

			pBackTop.pPanel.OnTouchEvent = function ()
				self:OnClickGoTop()
			end
			pBackBottom.pPanel.OnTouchEvent = function ()
				self:OnClickGoBottom()
			end
		else
			self.nShowHintRowCount = nil
		end
	end
end

function tbUi:UpdateItemHeight(tbHeight)
	self.pPanel:UpdateItemHeight(tbHeight);
end

function tbUi:GoTop()
	self.pPanel:ScrollViewGoTop();
end

function tbUi:GoBottom()
	self.pPanel:ScrollViewGoBottom();
end

function tbUi:IsTop()
	return self.pPanel:ScrollViewIsTop();
end

function tbUi:IsBottom()
	return self.pPanel:ScrollViewIsBottom();
end

--拖动滚动调显示hint 的处理
function tbUi:CheckShowGridMax(itemObj, index)
	itemObj.pScrollView = self;
	if not self.nShowHintRowCount then
		return
	end
	if self.nShowGridMax - index >= self.nShowHintRowCount then
		self.nShowGridMax = index
  	end
	self.nShowGridMax = math.max(self.nShowGridMax, index);
end

function tbUi:OnClickGoTop()
	self:GoTop();
	self.pBackTop.pPanel:SetActive("Main", false)
end

function tbUi:OnClickGoBottom()
	self:GoBottom();
	self.pBackBottom.pPanel:SetActive("Main", false)
end

function tbUi:OnDragList(nY)
	if not self.nShowHintRowCount then
		return
	end

	if nY > 100 or nY < -100 then
		return
	end

	if self.nShowGridMax < self.nShowHintRowCount + 1 or self.nShowGridMax > self.nItemCountTotal - self.nShowHintRowCount then
		return
	end
	if nY < 0 then
		self.pBackBottom.pPanel:SetActive("Main", false)
		self.pBackTop.pPanel:SetActive("Main", true)
	elseif nY > 0  then
		self.pBackTop.pPanel:SetActive("Main", false)
		self.pBackBottom.pPanel:SetActive("Main", true)
	end
end

function tbUi:OnDragEndList()
	if not self.nShowHintRowCount then
		return
	end
	if self.nShowGridMax <= self.nShowHintRowCount then
		self.pBackTop.pPanel:SetActive("Main", false)
		return
	elseif self.nShowGridMax > self.nItemCountTotal - self.nShowHintRowCount then
		self.pBackBottom.pPanel:SetActive("Main", false)
		return
	end

	if self:IsTop() or self:IsBottom() then
		self.pBackTop.pPanel:SetActive("Main", false)
		self.pBackBottom.pPanel:SetActive("Main", false)
	end
end