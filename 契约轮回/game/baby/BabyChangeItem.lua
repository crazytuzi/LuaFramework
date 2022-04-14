--- Created by Admin.
--- DateTime: 2019/12/19 11:57

BabyChangeItem = BabyChangeItem or class("BabyChangeItem", BaseCloneItem)
local BabyChangeItem = BabyChangeItem

function BabyChangeItem:ctor(parent_node, layer)
    self.is_act = false
    self.model = BabyModel.GetInstance()
    BabyChangeItem.super.Load(self)
end

function BabyChangeItem:dctor()
    if self.redDot then
        self.redDot:destroy()
		self.redDot = nil
    end
end

function BabyChangeItem:LoadCallBack()
    self.nodes = {
        "item_select","icon","item_name","starContainer/starNum","item_bg/item_bg_2",
        "nohave","JIhuo","ShenXing","starContainer/item_wear","item_bg/item_bg_1",
    }
    self:GetChildren(self.nodes)
    self.itemName = GetText(self.item_name)
    self.starNum = GetText(self.starNum)
    self.iconBg = GetImage(self.item_bg_2)
	self.iconBg2 = GetImage(self.item_bg_1)
    self.itemBg = GetImage(self.icon)

    self.redDot = RedDot(self.transform, nil, RedDot.RedDotType.Nor);
    self.redDot:SetPosition(69, 35);

    self:AddEvent()
 
end

function BabyChangeItem:AddEvent()
    local function call_back()
        self.model:Brocast(BabyEvent.BabyWingItemClick,self.config.id)
    end
    AddClickEvent(self.icon.gameObject, call_back)
end

function BabyChangeItem:SetData(config)
    self.config = config
	self:UpdateView()
end


function BabyChangeItem:UpdateView()
    if self.config then
        local res = "Q_Bg_".. self.config.color
		local res2 = "Q_Frame_".. self.config.color
        lua_resMgr:SetImageTexture(self, self.iconBg, "pet_image", res, true, nil, false)
		lua_resMgr:SetImageTexture(self, self.iconBg2, "pet_image", res2, true, nil, false)
        lua_resMgr:SetImageTexture(self, self.itemBg, 'iconasset/icon_babywing', self.config.res, false)
        self.itemName.text = self.config.name

        local k,v = self.model:GetWingByID(self.config.id)
        local count = self.model:GetNeedNum(self.config.id) or 0

        local id = self.config.id .."@"..v
        local c = Config.db_baby_wing_star[id]
        local nedNum = String2Table(c.cost)[2]
		if v == 5 then
			self.redDot:SetRedDotParam(false)
		else
			self.redDot:SetRedDotParam(count >= nedNum)
		end
        self.is_act = k

        if k then
            if v == 5 then
                self:SetTopBg(4)
            else
                if count >= nedNum then
                    self:SetTopBg(3)
                else
                    self:SetTopBg(4)
                end
            end
            self.starNum.text = v
            ShaderManager:GetInstance():SetImageNormal(self.itemBg)
        else
            self.starNum.text = 0
            ShaderManager:GetInstance():SetImageGray(self.itemBg)
            if count and count > 0 then
                self:SetTopBg(2)
            else
                self:SetTopBg(1)
            end
        end

        local is_wear = self.model:GetWingIsShowByid(self.config.id)
        if is_wear then
            self:SetTopBg(4)
        end
        SetVisible(self.item_wear, is_wear)
    end
end


-- 1 未拥有 2 可激活 3 可升星
function BabyChangeItem:SetTopBg(idx)
    SetVisible(self.nohave, idx == 1)
    SetVisible(self.JIhuo, idx == 2)
    SetVisible(self.ShenXing, idx == 3)
end

function BabyChangeItem:SelectBg(v)
    SetVisible(self.item_select, v)
  --[[  if v then
        ShaderManager:GetInstance():SetImageNormal(self.itemBg)
    else
        if not self.is_act then
            ShaderManager:GetInstance():SetImageGray(self.itemBg)
        end
    end--]] 
end

function BabyChangeItem:GetWingID()
    return self.config.id
end


