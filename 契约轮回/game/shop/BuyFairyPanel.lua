BuyFairyPanel = BuyFairyPanel or class("BuyFairyPanel",BasePanel)
local BuyFairyPanel = BuyFairyPanel

function BuyFairyPanel:ctor()
	self.abName = "shop"
	self.assetName = "BuyFairyPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.is_click_bg_close = true
	self.is_hide_other_panel = true
	self.use_gold = false

	self.model = ShopModel:GetInstance()
end

function BuyFairyPanel:dctor()
end

function BuyFairyPanel:Open(uid, item_id)
	if item_id == 11020147 then
		item_id = 11020144
	end
	self.uid = uid
	self.item_id = item_id
	BuyFairyPanel.super.Open(self)
end

function BuyFairyPanel:LoadCallBack()
	self.nodes = {
		"btn_close","btn_ok","tip","myspirite","togglegroup/ToggleBGold","togglegroup/ToggleGold","big_bg",
		"togglegroup/ToggleBGold/Labelbgold","togglegroup/ToggleGold/Labelgold","myspirite/Camera",
	}
	self:GetChildren(self.nodes)
	self.tip = GetImage(self.tip)
	self.ToggleBGold = GetToggle(self.ToggleBGold)
	self.ToggleGold = GetToggle(self.ToggleGold)
	self.render_texture = CreateRenderTexture() 
	self.myspirite_com = self.myspirite:GetComponent("RawImage")
	self.Camera_com = self.Camera:GetComponent("Camera")
	self.myspirite_com.texture = self.render_texture
	self.Camera_com.targetTexture = self.render_texture
	self.big_bg = GetImage(self.big_bg)
	self.Labelbgold = GetText(self.Labelbgold)
	self.Labelgold = GetText(self.Labelgold)

	self:AddEvent()
	--local res = "buy_spirite_bg"
	--lua_resMgr:SetImageTexture(self,self.big_bg, "iconasset/icon_big_bg_" .. res, res)
	self.effect = UIEffect(self.btn_ok, 10121)
end

function BuyFairyPanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.btn_close.gameObject,call_back)

	local function call_back(target,x,y)
		local mall_id = self.mall_id
		if not self.use_gold then
			mall_id = self.mall_id_b
		end
		local arr = String2Table(Config.db_mall[mall_id].price)
		local gold_id = arr[1]
		local need_gold = arr[2]
		local gold = ""
		if gold_id == enum.ITEM.ITEM_GOLD then
			gold = Constant.GoldType.Gold
		else
			gold = Constant.GoldType.BGold
		end
		local bo = RoleInfoModel:GetInstance():CheckGold(need_gold, gold)
		if not bo then
			return
		end
		ShopController:GetInstance():RequestValidate(mall_id, self.uid)
		self:Close()
	end
	AddClickEvent(self.btn_ok.gameObject,call_back)

	local function call_back(target, value)
		if value then
			self.use_gold = false
		end
	end
	AddValueChange(self.ToggleBGold.gameObject, call_back)

	local function call_back(target, value)
		if value then
			self.use_gold = true
		end
	end
	AddValueChange(self.ToggleGold.gameObject, call_back)
end

function BuyFairyPanel:OpenCallBack()
	self:UpdateView()
end

function BuyFairyPanel:UpdateView( )
	local tips_img = "sprite_tips1"
	if self.item_id == 11020143 then
		tips_img = "sprite_tips2"
	end
	lua_resMgr:SetImageTexture(self,self.tip, 'shop_image', tips_img)
	local mall_ids = self.model:GetMallIdByItemId(self.item_id)
	local mall_item = Config.db_mall[mall_ids[1]]
	local mall_item2 = Config.db_mall[mall_ids[2]]
	if String2Table(mall_item.mall_type)[2] == 1 then
		self.mall_id = mall_ids[1]
		self.mall_id_b = mall_ids[2]
		self.Labelgold.text = String2Table(mall_item.price)[2]
		self.Labelbgold.text = String2Table(mall_item2.price)[2]
	else
		self.mall_id = mall_ids[2]
		self.mall_id_b = mall_ids[1]
		self.Labelgold.text = String2Table(mall_item2.price)[2]
		self.Labelbgold.text = String2Table(mall_item.price)[2]
	end
	local model_id = Config.db_fairy[self.item_id].resource
	self.monster_model = UIFairyModel(self.myspirite, model_id, handler(self,self.HandleCreepLoaded))
end

function BuyFairyPanel:HandleCreepLoaded( ... )
	SetLocalRotation(self.monster_model.transform,0,173,0)
    SetLocalPosition(self.monster_model.transform,2152,-129,215)
end

function BuyFairyPanel:CloseCallBack(  )
	if self.monster_model then
		self.monster_model:destroy()
	end
	if self.myspirite_com then
		self.myspirite_com.texture = nil
	end
	if self.Camera_com then
		self.Camera_com.targetTexture = nil
	end
	if self.render_texture then
		ReleseRenderTexture(self.render_texture)
		self.render_texture = nil
	end
	if self.effect then
		self.effect:destroy()
		self.effect = nil
	end
end