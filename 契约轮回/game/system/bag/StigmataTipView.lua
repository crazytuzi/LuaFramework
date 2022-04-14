StigmataTipView = StigmataTipView or class("StigmataTipView", BaseGoodsTip)
local this = StigmataTipView

function StigmataTipView:ctor(parent_node, layer)
	self.abName = "system"
	self.assetName = "StigmataDetailView"
	self.layer = layer
    
	self:BeforeLoad()
end

function StigmataTipView:BeforeLoad()
	StigmataTipView.super.Load(self)
end

function StigmataTipView:dctor()
    
    if self.attrStr then
        self.attrStr:destroy()
        self.attrStr = nil
    end

    if self.getStr then
        self.getStr:destroy()
        self.getStr = nil
    end

    self.model = nil

end

function StigmataTipView:InitData()
	StigmataTipView.super.InitData(self)
	

	self.minScrollViewHeight = 90

    self.addValueTemp = 130
    
    self.attrStr = nil
    self.getStr = nil

   
end

function StigmataTipView:LoadCallBack()
	self.nodes = {
        "had_put_on",  --已装备
        "wearLV",
		"wearLV/wareValue",  --圣痕等级
		
        "equipPos/PosTxt",  --圣痕位置
		
	}
    self:GetChildren(self.nodes)
    
    StigmataTipView.super.LoadCallBack(self)

	self.PosTxt = GetText(self.PosTxt)
    self.wareValue = GetText(self.wareValue)
    self.valueTempTxt = GetText(self.valueTemp)
    
end

function StigmataTipView:AddEvent()
	self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
	self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.CloseTipView, handler(self, self.CloseTipView))

end

function StigmataTipView:SetData(data)
	
end

--param包含参数
--cfg  该物品(装备)的配置
--p_item 服务器给的，服务器没给，只传cfg就好
--model 管理该tip数据的实例
--is_compare --是否有对比
--operate_param --操作参数
function StigmataTipView:ShowTip(param)
    self.is_compare = param["is_compare"]


	StigmataTipView.super.ShowTip(self, param)
	
	
	self:DealCreateAttEnd()
	
	if not self.is_compare then
		GlobalEvent:Brocast(GoodsEvent.CloseTipView)
		
		self:AddClickCloseBtn()
		self:SetViewPosition()
		
		self:AddEvent()
	else
		SetVisible(self.mask.gameObject, false)
	end
    
    self:SetHead(param["p_item"])
    
    self:SetAttr(param["p_item"])

    --非双属性圣痕 刷新分解获得信息
    local base = String2Table(Config.db_soul[param["p_item"].id].base)
    if #base ~=  2 then
        self:UpdateDecomposeGet(param["p_item"])
    end

    --刷新获取途径
    local itemCfg = Config.db_item[param["p_item"].id]
    self:SetJump(itemCfg.gainway,itemCfg.gainwayitem)

    self:DealCreateAttEnd()
    self:SetViewPosition()

   
  
end

--刷新tip头
function StigmataTipView:SetHead(p_item)

    local slot = Config.db_soul[p_item.id].slot  --圣痕类型

    self.wareValue.text = p_item.extra

    --0碎片 1普通 2核心
    if slot == 0 then
        self.PosTxt.text = "Unavailable"
        SetVisible(self.wearLV.transform,false)
    elseif slot == 1 then
        self.PosTxt.text = "Common"
    elseif slot == 2 then
        self.PosTxt.text = "Core"
    end
end

--刷新圣痕属性
function StigmataTipView:SetAttr(p_item)

    local attrString = ""


    local slot = Config.db_soul[p_item.id].slot  --圣痕类型

    if slot ~= 0 then
        local db_soul_level = Config.db_soul_level[tostring(p_item.id) .."@".. tostring(p_item.extra)]
        local attribute = String2Table(db_soul_level.attrib)
    
        --基础属性
        local baseAttribute = String2Table(Config.db_soul[p_item.id].base)
    
        --local type1 = attribute[1][1] > 12
        local type1 = Config.db_attr_type[attribute[1][1]].type == 2
        local value1 = attribute[1][2] + baseAttribute[1][2]
        if type1  then
            --处理百分比属性
           value1 = (value1 / 100) .. "%"
       end
    


       attrString =  attrString.format("<color=#675344>%s</color>", StigmataModel:GetInstance():GetAttrNameByIndex(attribute[1][1]) ..":  " ).. attrString.format("<color=#2FAD25>%s</color>",value1)
    
       if #attribute > 1 then
          -- 第二条属性
        --local type2 = attribute[2][1] > 12
        local type2 = Config.db_attr_type[attribute[2][1]].type == 2
        local value2 =attribute[2][2] + baseAttribute[2][2]
    
        if type2 then
            --处理百分比属性
           value2 = (value2 / 100) .. "%"
        end
    
        attrString = attrString .. "\n" .. attrString.format("<color=#675344>%s</color>", StigmataModel:GetInstance():GetAttrNameByIndex(attribute[2][1]) ..":  " ).. attrString.format("<color=#2FAD25>%s</color>",value2)
       end

    else
        --碎片没有属性
        attrString = "<color=#675344>None</color>"
    end


    

   self.attrStr = EquipTwoAttrItemSettor(self.Content)

   self.valueTempTxt.text = attrString
   local height = self.valueTempTxt.preferredHeight + 25 + 10 + 10
   self.attrStr:UpdatInfo({ title = ConfigLanguage.AttrTypeName.StigmataAttr, info1 = attrString, info2 = nil,
                posY = self.height, itemHeight = height })
   self.height = self.height + height
end

--刷新分解获得信息
function StigmataTipView:UpdateDecomposeGet(p_item)

    local info = {}
    local baseTable= String2Table(Config.db_soul[p_item.id].gain)
    info.costNum = baseTable[1][2] -- 本身分解

    local slot = Config.db_soul[p_item.id].slot  --圣痕类型

    if slot ~= 0 then
        --非碎片 需要加上升级消耗
        local itemcfg = Config.db_soul_level[p_item.id .. "@" .. p_item.extra]
        local getTable = String2Table(itemcfg.total_cost)
        info.costNum = info.costNum + getTable[2] --本身分解 + 升级消耗
    end

    self.getStr = DecomposeGetItemSettor(self.Content)
    self.valueTempTxt.text = info.costNum
    local height = self.valueTempTxt.preferredHeight + 25 + 10 + 20

    info.posY = self.height
    info.itemHeight = height
  
    self.itemHeight = height
    self.getStr:UpdateInfo(info)

    self.height = self.height + height
    
end
