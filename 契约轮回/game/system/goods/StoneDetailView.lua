-- @Author: chk
-- @Date:   2018-09-01 15:31:28
--
StoneDetailView = StoneDetailView or class("StoneDetailView",BaseGoodsTipView)
local StoneDetailView = StoneDetailView

function StoneDetailView:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "StoneDetailView"
	self.layer = nil

	self.baseAttrStr = nil
	self.click_bg_close = true


	StoneDetailView.super.Load(self)

	self.btnWidth = 120
end

function StoneDetailView:dctor()

	if self.baseAttrStr ~= nil then
		self.baseAttrStr:destroy()
	end
end

function StoneDetailView:LoadCallBack()

	--self.nodes = {
	--	"btnContain/useBtn",
	--}
	--self:GetChildren(self.nodes)

	StoneDetailView.super.LoadCallBack(self)

	--self:UpdateInfo(self.goodsItem)
end

function StoneDetailView:AddEvent()
	StoneDetailView.super.AddEvent(self)
end

--处理销毁道具
function StoneDetailView:DealDestroyGoods(item)
	if item.uid == self.model.goodsItem.uid then

	end
end

--function StoneDetailView:DelItem(bagId,uid)
--	--if self.model.goodsItem.uid == uid then
--	--	self:Close()
--	--end
--end


function StoneDetailView:OpenCallBack()
	self:UpdateView()
end

function StoneDetailView:UpdateView( )

end

function StoneDetailView:CloseCallBack(  )

end


function StoneDetailView:UpdateInfo( data )
	StoneDetailView.super.UpdateInfo(self,data)

	if self.is_loaded then
		local itemConfig = Config.db_item[data.id]
		self:UpdateBaseAttr(data.equip.base)
	--
	--	self.need_load_end = false
	--else
	--	self.model.goodsItem = data
	--	self.need_load_end = true
	end

end


--更新属性加成
function StoneDetailView:UpdateBaseAttr( data )
	if not table.isempty(data)  then
		self.baseAttrStr = EquipAttrItemSettor(self.Content,"UI")
		local	attrInfo = ""
		for k,v in pairs(data) do
			attrInfo = attrInfo .. enumName.ATTR[v.key] .. "+" .. v.value .. "\n"
		end

		self.baseAttrStr:SetData({tile = ConfigLanguage.AttrTypeName.StoneAdd,info = attrInfo})
	end

end
