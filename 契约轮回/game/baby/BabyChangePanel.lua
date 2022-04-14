--- Created by Admin.
--- DateTime: 2019/12/19 10:50

BabyChangePanel = BabyChangePanel or class("BabyChangePanel", BaseItem)
local BabyChangePanel = BabyChangePanel

function BabyChangePanel:ctor(parent_node, layer)
    self.abName = "baby"
    self.assetName = "BabyChangePanel"
    self.layer = layer
    self.events = {}
    self.cur_id = 0
    self.items = {}
    self.cur_item  = nil
	self.is_click = false
    self.model = BabyModel.GetInstance()
    BaseItem.Load(self)
end

function BabyChangePanel:dctor()
    self.model:RemoveTabListener(self.events)
    destroyTab(self.items)
    self.cur_id = nil
    self.cur_item  = nil

    if self.redDot then
        self.redDot:destroy()
		self.redDot = nil
    end
	
	if self.item then
		self.item:destroy()
		self.item = nil
	end
	if self.modelView then
		self.modelView:destroy()
		self.modelView = nil
	end
end

function BabyChangePanel:LoadCallBack()
    self.nodes = {
        "wing_title_text","left/item_0","left/ScrollView/Viewport/Content","wingCon","right/count",
        "right/jihuoBtn","right/huaBtn","right/icon","zhanliItems/zhanliText",
        "right/upStarBtn","right/upStarBtn/upstar_label","right/PropItems","right",
        "right/exp","right/exp/exp_bg","right/exp/exp_bar","right/exp/progressText",
    }
    self:GetChildren(self.nodes)
    self.wingName = GetText(self.wing_title_text)
    self.upstar_label = GetText(self.upstar_label)
    self.zhanliText = GetText(self.zhanliText);
    self.countTex = GetText(self.count)

    self:AddEvent()
    self:InitPanel()
end

function BabyChangePanel:AddEvent()
    local function call_back()
        BabyController:GetInstance():RequestShow(self.cur_id)
    end
    AddClickEvent(self.huaBtn.gameObject, call_back)

    local function call_back()
		if self.is_click then
			BabyController:GetInstance():RequestWingUpLevel(self.cur_id)
		else
			if self.is_all then
				Notify.ShowText("Max Stars")
			else
				Notify.ShowText("Not enough")
			end	
		end
      
    end
    AddClickEvent(self.upStarBtn.gameObject, call_back)
	
	
	local function call_back()
		if self.is_click then
			BabyController:GetInstance():RequestWingUpLevel(self.cur_id)
			BabyController:GetInstance():RequestShow(self.cur_id)
		else
			Notify.ShowText("Not enough")	
		end	
	end
	AddClickEvent(self.jihuoBtn.gameObject, call_back)

    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyWingUpdate,handler(self,self.HandleUpdateData))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyWingItemClick,handler(self,self.HandleClickItem))
end

function BabyChangePanel:InitPanel()
    local tab = Config.db_baby_wing_morph
    local tab1 = {}
    for k, v in pairs(tab) do
		local idx = v.order
		tab1[idx] = v
    end
	for i = 1, #tab1 do
		self.items[i] = BabyChangeItem(self.item_0.gameObject, self.Content)
		self.items[i]:SetData(tab1[i])
	end

	
    self.PropItems = PropItems(self.PropItems)
    self.PropItems:HideLines(0)
    self.redDot = RedDot(self.right, nil, RedDot.RedDotType.Nor)
    self.redDot:SetPosition(500, -235);

    local id = self:GetFirstID(tab1)
    self:HandleClickItem(id)
end


function BabyChangePanel:UpdateModel(id)
    local config = Config.db_baby_wing_morph[id]
    if config then
        self:ClearModel()
		local c= {}
		c.scale = { x = config.ratio * 5, y = config.ratio * 5, z = config.ratio * 5 };
		c.rotate = { x = 0, y = 0, z = 0 };
		c.offset = { x = 4000, y = 80, z = -450 };
		c.rotate = { x = 0, y = 180, z = 0 };
		c.cameraPos = { x = 2000, y = -50, z = 0 }
		
        local id = config.res
		local stype = enum.ITEM_STYPE.ITEM_STYPE_BABY_WING_MORPH
		--self.modelView = UIModelManager:GetInstance():InitModel(stype, id, self.wingCon, call_back, false, 1)
		self.modelView = UIMountCamera(self.wingCon.transform, nil, id, stype, nil, true)
		self.modelView:SetConfig(c)
    else
        logError("子女翅膀iD不存在".. id)
    end
end

function BabyChangePanel:UpdateRightView(id)
    local config = Config.db_baby_wing_morph[id]
    local show = self.model:GetWingIsShowByid(id)
    SetVisible(self.huaBtn, not show)
	
    local k,v = self.model:GetWingByID(id)
    local count = self.model:GetNeedNum(id) or 0
    local idx = id .."@"..v
    local c = Config.db_baby_wing_star[idx]
	local nedNum = String2Table(c.cost)[2]
	
	if v == 5 then
		self.redDot:SetRedDotParam(false) 
		self.countTex.text = ""
		self.is_all = true
	else
		self.is_all = false
		self.is_click = count >= nedNum
		self.redDot:SetRedDotParam(count >= nedNum)
		if count >= nedNum then
			self.countTex.text = "<color=#3ab60e>".. count .. "</color>/".. nedNum
		else
			self.countTex.text = "<color=#eb0000>".. count .. "</color>/".. nedNum
		end
	end

	self.zhanliText.text = c.power

    self:SetBtn(k)
	
	if v == 5 then
		self.upstar_label.text = "Max Stars";
		self.PropItems:HideCompare(false);
	else
		self.upstar_label.text = "Star up";
		self.PropItems:HideCompare(true);
	end

    if k then
        local nextTab = Config.db_baby_wing_star[id.."@"..(v + 1)]
        self.PropItems:UpdateValues(c, nextTab)
		self.wingName.text = v .. "Star·" .. config.name
    else
        self.PropItems:UpdateValuesSingle(c, true)
		self.wingName.text = config.name
    end


    if not self.item then
        self.item = GoodsIconSettorTwo(self.icon.transform)
    end

    local param = {}
    param["item_id"] = String2Table(config.cost)[1]
    param["can_click"] = true
    param["bind"] = true
    param["num"] = 1
    self.item:SetIcon(param);
end

function BabyChangePanel:UpdateItemView()
    for i, v in pairs(self.items) do
          v:UpdateView()
    end
end

function BabyChangePanel:SetBtn(bool)
    SetVisible(self.jihuoBtn,not bool)
    SetVisible(self.upStarBtn, bool)
end

function BabyChangePanel:HandleUpdateData()
    self:UpdateRightView(self.cur_id)
    self:UpdateItemView(self.cur_id)
end


function BabyChangePanel:HandleClickItem(id)
    if self.cur_id == id then return end

    self:UpdateRightView(id)
    self:UpdateModel(id)
    self:SelectItem(id)
end

function BabyChangePanel:SelectItem(id)
    if self.cur_item then
        self.cur_item:SelectBg(false)
    end
	self.cur_id = id
    for i, v in pairs(self.items) do
        if v:GetWingID() == id then
            v:SelectBg(true)
            self.cur_item = v
            break
        end
    end
end

function BabyChangePanel:GetFirstID(tab)
    for i = 1, #tab do
        local k,v = self.model:GetWingByID(tab[i].id)
        local count = self.model:GetNeedNum(tab[i].id) or 0
        local idx = tab[i].id .."@"..v
        local c = Config.db_baby_wing_star[idx]
        local nedNum = String2Table(c.cost)[2]
        if k then
            if v ~= 5  and count >= nedNum then
                return tab[i].id
            end
        else
            if count > 0 then
                return tab[i].id
            end
        end
    end

    return tab[1].id
end


function BabyChangePanel:ClearModel()
    if self.modelView  then
        self.modelView:destroy()
    end
end