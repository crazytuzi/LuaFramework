--
-- @Author: chk
-- @Date:   2018-08-24 11:14:53
--
BaseBagGoodsSettor = BaseBagGoodsSettor or class("BaseBagGoodsSettor",BaseWidget)
local BaseBagGoodsSettor = BaseBagGoodsSettor

function BaseBagGoodsSettor:ctor(parent_node,layer)
	self.model = BagModel:GetInstance()
	self.events = self.events or {}
	self.globalEvents = {}
end

function BaseBagGoodsSettor:__clear()
	BaseBagGoodsSettor.super.__clear(self)
end

function BaseBagGoodsSettor:__reset(...)
    BaseBagGoodsSettor.super.__reset(self, ...)
    SetLocalPosition(self.transform, 0, 0, 0)
end

function BaseBagGoodsSettor:dctor()
	if self.ui_effect ~= nil then
		self.ui_effect:destroy()
		self.ui_effect = nil
	end
	if self.score_effect then
		self.score_effect:destroy()
		self.score_effect = nil
	end
	if self.score_effect2 then
		self.score_effect2:destroy()
		self.score_effect2 = nil
	end
	self.model.baseGoodSettorCLS = nil

	for k,v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end

	self.countTxt = nil
	self.model = nil

	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
end

function BaseBagGoodsSettor:Load()
	BaseBagGoodsSettor.super.Load(self)
end

function BaseBagGoodsSettor:LoadCallBack()
	self.nodes = {
		"bindIcon",
		"icon",
		"quality",
		"selectBg",
		"starContain",
		"countBG",
		"countBG/count",
		"touch",
		"lv",
	}
	
	self:GetChildren(self.nodes)
	self:AddEvent()

	self.countTxt = self.count:GetComponent('Text')
	self.iconImg = self.icon:GetComponent('Image')
	self.qualityImg = self.quality:GetComponent('Image')

	if self.lv then
		self.lv = GetText(self.lv)
	end
	
end

function BaseBagGoodsSettor:ResponeAddItems()
end


function BaseBagGoodsSettor:AddEvent()
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum,handler(self,self.UpdateNum))

	local function call_back()
		self:UpdateHighEffect(self.uid)
	end
	self.events[#self.events+1] = self.model:AddListener(BagEvent.UpdateHighScore, call_back)
	--self.events[#self.events+1] = self.model:AddListener(BagEvent.UpdateStar,handler(self,self.UpdateStar))
	--self.events[#self.events+1] = self.model:AddListener(BagEvent.UpdateQuqlity,handler(self,self.UpdateQuqlity))

	
	--AddButtonEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end

--点击事件(要重载)
function BaseBagGoodsSettor:ClickEvent( )
	--if self.selectI
	if self.model.baseGoodSettorCLS ~= nil then
		self.model.baseGoodSettorCLS:SetSelected(false)
	end

	self:SetSelected(true)
	self.model.baseGoodSettorCLS = self

	GoodsController.Instance:RequestItemInfo(self.bag,self.uid)
end


function BaseBagGoodsSettor:SetData(data)

end

--bag  当前所在背包
--bind 是否绑定
--outTime 过期时间戳
function BaseBagGoodsSettor:UpdateInfo(param)
	self.__item_index = param["itemIndex"]

	self.type = param["type"]
	self.uid = param["uid"]
	self.id = param["id"]
	self.num = param["num"]
	self.bag = param["bag"]
	self.bind = param["bind"]
	self.outTime = param["outTime"]
	self.model = param["model"]
	self.itemSize = param["itemSize"]
	self.sex = param["sex"]
	self.stencil_id = param["stencil_id"]
	--self.itemSize = param["itemSize"]
	local quality = Config.db_item[param.id].color



	self.cfg = nil
	if Config.db_item[param.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST then
		self.cfg = Config.db_beast_equip[param.id]
	elseif Config.db_item[param.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BABY then
		self.cfg = Config.db_baby_equip[param.id]
	elseif Config.db_item[param.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_GOD then
		self.cfg = Config.db_god_equip[param.id]
	elseif Config.db_item[param.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_MECHA then
		self.cfg = Config.db_mecha_equip[param.id]
	elseif Config.db_item[param.id].type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
		--宠物装备
		self.cfg = Config.db_item[param.id]
	elseif Config.db_item[param.id].type == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP then
		self.cfg = Config.db_totems_equip[param.id]
	else
		self.cfg = Config.db_equip[param.id]
	end
	self:UpdateIcon(param.bag,param.uid,self.iconImg,param.id,param.custom_icon_id)
	self:UpdateQuality(param.bag,param.uid,quality)
	self:UpdateEffect(quality)
	self:UpdateHighEffect(param.uid)
	self:UpdateEffectById(param["effect_id"])
	self:UpdateNum(param.bag, param.uid,param.num)
	self:UpdateBind(param.bag,param.uid,param.bind)
	self:UpdateSize(param["itemSize"] or param["cellSize"])
	self:UpdateReddot(param["show_reddot"] or false)

	self:UpdateLV(param["lv"])
end

function BaseBagGoodsSettor:UpdateBind(bagId,uid,bind)
	--if self.bag == bagId and self.uid == uid then
		SetVisible(self.bindIcon.gameObject,bind)
	--end
end

function BaseBagGoodsSettor:UpdateSize(itemSize)
	if itemSize ~= nil then
		local itemRect = self.transform:GetComponent('RectTransform')
		itemRect.sizeDelta = Vector2(itemSize.x,itemSize.y)
	end
end

function BaseBagGoodsSettor:UpdateIcon(bagId,uid,iconImg,item_id,custom_icon_id)
	GoodIconUtil.Instance:CreateIconBySex(self,iconImg,item_id,true,self.sex,custom_icon_id)
end

--更新数量
function BaseBagGoodsSettor:UpdateNum(bagId,uid,num)
	--Chkprint("updateNum_____" , self.__cname,self.id)
	if self.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
		SetVisible(self.countBG.gameObject,false)
	elseif self.countTxt ~= nil and self.bag == bagId and self.uid == uid and num then
		self.countTxt.text = GetShowNumber(num)
		if num == nil or num == 1 then
			SetVisible(self.countBG.gameObject,false)
		else
			SetVisible(self.countBG.gameObject,true)
		end
	end
end

--更新等级
function BaseBagGoodsSettor:UpdateLV(lv)

	if not lv then
		SetVisible(self.lv,false)
		return
	end

	SetVisible(self.lv,true)
	self.lv.text = "LV."..lv
	
end

----更新品质
--function BaseBagGoodsSettor:UpdateStar(bag, uid,star)
--	if self.bag == bag and  self.uid == uid then
--
--	end
--end

--更新品质
function BaseBagGoodsSettor:UpdateQuality(bag,uid,quality)
	--if self.bag == bag and self.uid == uid then
		lua_resMgr:SetImageTexture(self,self.qualityImg,"common_image","com_icon_bg_" .. quality,true)
	--end
end

--是否激活射线检测（接收点击事件）
function BaseBagGoodsSettor:UpdateRayTarget(visable)
	GetImage(self.touch).raycastTarget = visable
end

function BaseBagGoodsSettor:UpdateEffect(color)
	local scale = (self.itemSize and self.itemSize.x or 80)/96
	local pos = {x=0,y=0,z=0}
	if color > 6 then
		if not self.ui_effect then
        	local effect_id = self.model:GetEffectIdByColor(color, 1)
	        if effect_id > 0 then
	            self.ui_effect = UIEffect(self.icon, effect_id)
	        end
        end
        self.ui_effect:SetConfig({ useStencil = true, stencilId = self.stencil_id, stencilType = 3,scale=scale,pos=pos })
    else
    	if self.ui_effect then
    		self.ui_effect:destroy()
    		self.ui_effect = nil
    	end
    end
end

--更新最高评分特效
function BaseBagGoodsSettor:UpdateHighEffect(uid)
	if not self.model then
		return
	end
	local pitembase = self.model:GetItemByUid(uid)
	if not pitembase then
		return
	end
	local slot_scores = self.model.slot_scores
	if not slot_scores then
		return
	end
	local equipcfg = Config.db_equip[pitembase.id]
	if equipcfg then
		local slot = equipcfg.slot
		local putonitem = EquipModel.GetInstance():GetEquipBySlot(slot)
		local puton_score = (putonitem and putonitem.score or 0)
		local high_uid = (slot_scores[slot] and slot_scores[slot].uid or 0)
		if uid == high_uid and pitembase.score > puton_score then
			if not self.score_effect then
				self.score_effect = UIEffect(self.icon, 20429)
				self.score_effect:SetConfig({ useStencil = true, stencilId = self.stencil_id, stencilType = 3 })
			end
		else
			if self.score_effect then
				self.score_effect:destroy()
				self.score_effect = nil
			end
		end
	else
		if self.score_effect then
			self.score_effect:destroy()
			self.score_effect = nil
		end
	end
end

--根据特效ID更新特效
function BaseBagGoodsSettor:UpdateEffectById(effect_id)
	
	if effect_id ~= nil and effect_id > 0 then
		local pos = { x = 0, y = 0, z = 0 }

        self.score_effect2 = self.score_effect2 or UIEffect(self.icon, effect_id)
        self.score_effect2:SetConfig({useStencil = true, stencilId = self.stencil_id, stencilType = 3, pos = pos })
    else
        if self.score_effect2 then
            self.score_effect2:destroy()
            self.score_effect2 = nil
        end
    end
end

--刷新红点
function BaseBagGoodsSettor:UpdateReddot(visible)

    --不需要显示红点 并且没实例化过红点的 就不需要后续处理了
	if not visible and not self.reddot then
		return
	end

	if self.reddot and visible == self.reddot:GetVisible() then
		return
	end

	self.reddot = self.reddot or RedDot(self.transform)
	SetLocalPositionZ(self.reddot.transform,0)
	SetAnchoredPosition(self.reddot.transform, 34.5, 35)
	SetVisible(self.reddot, visible)
end