--- Created by Admin.
--- DateTime: 2019/10/30 16:44
GodsItem =  GodsItem or class("GodsItem", BaseItem)
local this = GodsItem

function GodsItem:ctor(parent_node, layer)
    self.abName = "dungeon"
    self.assetName = "GodsItem"

    self.layer = layer
    self.rewardState = 0
    self.model= DungeonModel:GetInstance()
    self.type = enum.SCENE_STYPE.SCENE_STYPE_DUNGE_GOD
    GodsItem.Load(self)
end

function GodsItem:dctor()
    if self.item then
        self.item:destroy()
    end
    self.item = nil

    if self.effect then
        self.effect:destroy()
    end
    self.effect= nil

end
function GodsItem:LoadCallBack()
    self.nodes = {
        "BG", "record", "pos","Text","noactive","select","record2","received","redDot"
    }
    self:GetChildren(self.nodes);
    self.countTex = GetText(self.Text)

    if self.is_loaded then
        self:UpdateView()
    end
    SetVisible(self.gameObject, true)
end

function GodsItem:SetData(id, data, index, wave, isGet)
    self.stencil_id = id
    self.data = data
    self.index = index
    self.wave = wave
    self.isGet = isGet
    if self.is_loaded then
        self:UpdateView()
    end
end

function GodsItem:UpdateView()
    SetVisible(self.record.gameObject, false)
	SetVisible(self.record2.gameObject, false)
    local v = String2Table(self.data.first)
    self.countTex.text = string.format("Wave %s", self.index)


    local function call_back(go, x, y)
        if self.rewardState == 5 then
            DungeonCtrl:GetInstance():RequestFetch(self.type, self.index)
        else
            self.item:ClickEvent();
        end
    end

    local param = {}
    param["model"] = self.model
    param["item_id"] = v[1][1]
    param["num"] = v[1][2]
    param["bind"] = v[1][3]
    param["can_click"] = true
    param["out_call_back"] = call_back
    param["is_showtip"] = true
    param["stencil_id"] = self.stencil_id
    param["stencil_type"] = 3
    if not self.item then
        self.item =  GoodsIconSettorTwo(self.pos)
    end
    self.item:SetIcon(param)

    if self.wave >= self.index then
        if self.isGet then
            self:SetBg(4)
        else
            self:SetBg(5)
        end
        if self.index % 4 == 0 then
           self:SetRecord(true)
        end
    else
        self:SetBg(2)
        if self.index % 4 == 0 then
            self:SetRecord(false)
        end
    end


end


-- 2 未激活  4 已领取  5 可领取
function GodsItem:SetBg(index)
    SetVisible(self.noactive.gameObject, index == 2)
    --SetVisible(self.select.gameObject, index == 3)   现在不需要选中状态

    self.rewardState = index
    SetVisible(self.received.gameObject, index == 4)
    SetVisible(self.redDot.gameObject, index == 5)
    if self.effect then
        self.effect:destroy()
    end
    self.item:SetIconNormal()
    if index == 4 then
        self.item:SetIconGray()
    end
    if index == 5 then
        self.effect = UIEffect(self.pos,10302)
        self.effect:SetConfig({useStencil = true,scale = 0.8,stencilId = self.stencil_id, stencilType = 3})
    end

end
function GodsItem:IsRecord()
    return Config.db_dunge_god[self.index].record == 1
end
function GodsItem:SetRecord(bool)
    SetVisible(self.record.gameObject,not bool)
    SetVisible(self.record2.gameObject, bool)
end





