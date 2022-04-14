--
-- @Author: chk
-- @Date:   2018-09-30 10:49:56
--
GoodsJumpItemSettor = GoodsJumpItemSettor or class("GoodsJumpItemSettor",BaseWidget)
local GoodsJumpItemSettor = GoodsJumpItemSettor

function GoodsJumpItemSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "GoodsJumpItem"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	self.jumpItemItemSettors = {}
	GoodsJumpItemSettor.super.Load(self)
end

function GoodsJumpItemSettor:dctor()
	for i, v in pairs(self.jumpItemItemSettors) do
		v:destroy()
	end
	self.jumpItemItemSettors = {}
end

function GoodsJumpItemSettor:LoadCallBack()
	self.nodes = {
		"grid",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self.itemRectTra = self.transform:GetComponent('RectTransform')
	if self.need_loadend_end then
		self:CreateJumpItems(self.jumpInfo,self.posY)
	end
end

function GoodsJumpItemSettor:AddEvent()
end

function GoodsJumpItemSettor:SetData(data)

end

function GoodsJumpItemSettor:CreateJumpItems(jump, posY, icon)
	if self.is_loaded then
		local jumpTbl = String2Table(jump)
		local icons = String2Table(icon)
		for i=1, #jumpTbl do
			local v = jumpTbl[i]
			local icon = icons[i]
			self.jumpItemItemSettors[#self.jumpItemItemSettors+1] = GoodsJumpItemItemSettor(self.grid)
			self.jumpItemItemSettors[#self.jumpItemItemSettors]:ShowJumpInfo(v, icon)
		end
		self.need_loadend_end = false

		self.itemRectTra.anchoredPosition = Vector2(self.itemRectTra.anchoredPosition.s,-posY)
	else
		self.posY = posY
		self.jumpInfo = jump
		self.need_loadend_end = true
	end

end

function GoodsJumpItemSettor:SetGridPosX(x)
	SetLocalPositionZ(self.grid,0)
	SetAnchoredPosition(self.grid,x,self.grid.anchoredPosition.y)
end
