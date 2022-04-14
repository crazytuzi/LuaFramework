--
-- @Author: chk
-- @Date:   2018-09-01 15:31:28
--
StoneDetailPanel = StoneDetailPanel or class("StoneDetailPanel",BasePanel)
local StoneDetailPanel = StoneDetailPanel

function StoneDetailPanel:ctor()
	self.abName = "system"
	self.assetName = "StoneDetailPanel"
	self.layer = "UI"

	self.events = {}
	self.use_background = true
	self.change_scene_close = true
	self.click_bg_close = true

	self.model = GoodsModel:GetInstance()
end

function StoneDetailPanel:dctor()
	if self.iconStor ~= nil then
		self.iconStor:destroy()
	end
end

function StoneDetailPanel:Open( )
	StoneDetailPanel.super.Open(self)
end

function StoneDetailPanel:LoadCallBack()
	self.nodes = {
		"nameTxt",
		"icon",
		"type/typeValue",
		"lv/lvValue",

		"btnContain/useBtn",
		"btnContain/destoryBtn",
		"btnContain/takeOutBtn",
		"btnContain/storeBtn",
		"btnContain/sellBtn",
	}
	self:GetChildren(self.nodes)

	self:AddEvent()

	self:UpdateInfo(self.model.goodsItem)
end

--function StoneDetailPanel:AddEvent()
--	--丢弃(销毁)道具
--	local function call_back(target,x,y)
--		GoodsController.Instance:RequestChuckItem(self.model.goodsItem.uid,1)
--	end
--	AddClickEvent(self.destoryBtn.gameObject,call_back)
--
--
--	--出售道具
--	local function call_back(target,x,y)
--		local param = {}
--		local kv = {key = self.model.goodsItem.uid,value = 1}
--		table.insert(param,kv)
--		GoodsController.Instance:RequestSellItems(param)
--	end
--	AddClickEvent(self.sellBtn.gameObject,call_back)
--
--
--	--存储道具
--	local function call_back(target,x,y)
--		GoodsController.Instance:RequestStoreItem(self.model.goodsItem.uid,1)
--	end
--	AddClickEvent(self.storeBtn.gameObject,call_back)
--
--
--	--取出道具
--	local function call_back(target,x,y)
--		GoodsController.Instance:RequestTakeOut(self.model.goodsItem.uid,1)
--	end
--	AddClickEvent(self.takeOutBtn.gameObject,call_back)
--
--
--	local function call_back(target,x,y)
--		GoodsController.Instance:RequestUseItem(self.model.goodsItem.uid,1)
--	end
--	AddClickEvent(self.useBtn.gameObject,call_back)
--
--
--	self.events[#self.events + 1] =  GlobalEvent:AddListener(GoodsEvent.Destroy,handler(self,self.DealDestroyGoods))
--end

--处理销毁道具
function StoneDetailPanel:DealDestroyGoods(item)
	if item.uid == self.model.goodsItem.uid then

	end
end

function StoneDetailPanel:OpenCallBack()
	self:UpdateView()
end

function StoneDetailPanel:UpdateView( )

end

function StoneDetailPanel:CloseCallBack(  )

end


function StoneDetailPanel:UpdateInfo( data )
	if self.is_loaded then
		local itemConfig = Config.db_item[data.id]
		self.nameTxt:GetComponent('Text').text = itemConfig.name
		self.lvValue:GetComponent('Text').text = itemConfig.level
		self.typeValue:GetComponent('Text').text = enumName.ITEM_TYPE[itemConfig.type]
		self:UpdateBaseAttr(data.equip.base)
		self:UpdateIcon(data.id)


		self.need_load_end = false
	else
		self.model.goodsItem = data
		self.need_load_end = true
	end

end


--更新属性加成
function StoneDetailPanel:UpdateBaseAttr( data )
	if not table.isempty(data)  then
		self.baseAttrStr = EquipAttrItemSettor(self.Content)
		local	attrInfo = ""
		for k,v in pairs(data) do
			attrInfo = attrInfo .. enumName.ATTR[v.key] .. "+" .. v.value .. "\n"
		end

		self.baseAttrStr:SetData({tile = ConfigLanguage.AttrTypeName.StoneAdd,info = attrInfo})
	end

end


function StoneDetailPanel:UpdateIcon(id)
	self.iconStor = GoodsIconSettorTwo(self.icon)
	local param = {}
	param["model"] = self.model
	param["item_id"] = id
	self.iconStor:SetIcon(param)
	--self.iconStor:UpdateIcon(id)
end
