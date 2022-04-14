---
---Author: YangHongYun
---Date: 2019/9/25 19:44:36
---

StigmataCompoundPanel = StigmataCompoundPanel or class('StigmataCompoundPanel', BaseItem)
local this = StigmataCompoundPanel

function StigmataCompoundPanel:ctor(parent_node, layer)
    self.abName = 'bag'
    self.assetName = 'StigmataCompoundPanel'
    self.layer = layer
   
    self.events = {}
    self.bagModelEvent = nil

    self.model = StigmataModel:GetInstance()

    self.left_menu = nil  --左侧树形菜单
    self.menu = {}  --一级菜单数据
    self.sub_menu = {}  --二级菜单数据
    self.config_tab = {}  --合成目标菜单与子菜单id与对应配置数据
    self.select_targetItem_id = nil --默认选中的合成材料Id

    self.target_item = nil  --合成结果

    --3种合成消耗的UI
    self.item_list = {}

    self.is_enough = true  --合成材料是否足够
    self.target_item_id = nil  --目标合成材料id
    self.cur_menu_id = nil  --当前选中的一级菜单
    self.cur_submenu_id = nil  --当前选中的二级菜单



    BaseItem.Load(self)
end

function StigmataCompoundPanel:dctor()

    self.left_menu:destroy()
    self.left_menu = nil

    self.target_item:destroy()
    self.target_item = nil

    for i, v in pairs(self.item_list) do
        v:destroy()
    end
    self.item_list = nil

    if self.events or #self.events ~= 0 then
        GlobalEvent:RemoveTabListener(self.events)
        self.events = nil
    end

    BagModel:GetInstance():RemoveListener(self.bagModelEvent)
    self.bagModelEvent = nil

    self.menu = nil
    self.sub_menu = nil
    self.config_tab = nil
    self.target_item_id = nil

end



function StigmataCompoundPanel:LoadCallBack()

    self.nodes = {
       "LeftMenu",

       "Right/compound_slot_2/img_lock_2",
       "Right/compound_bg/target_item_content",
       "Right/compound_slot_2/txt_num_2",
       "Right/compound_slot_3/img_lock_3",
       "Right/compound_slot_2/item_content_2",
       "Right/compound_slot_3/txt_num_3",
       "Right/compound_slot_1/txt_num_1",
       "Right/compound_slot_1/img_lock_1",
       "Right/compound_slot_3/item_content_3",
       "Right/compound_slot_1/item_content_1",

       "Right/compound_bg/txt_attr_type2",
       "Right/compound_bg/txt_attr_type1",
       "Right/compound_bg/txt_attr_value2",
       "Right/compound_bg/txt_attr_value1",

       "Right/compound_bg/txt_colon1",
       "Right/compound_bg/txt_colon2",

       "Right/btn_compound",

       "Right/txt_com_lv",

    }
    self:GetChildren(self.nodes)

    self.txt_num_1 = GetText(self.txt_num_1)
    self.txt_num_2 = GetText(self.txt_num_2)
    self.txt_num_3 = GetText(self.txt_num_3)

    self.img_lock_2 = GetImage(self.img_lock_2)
    self.img_lock_3 = GetImage(self.img_lock_3)

    self.txt_attr_type1 = GetText(self.txt_attr_type1)
    self.txt_attr_type2 = GetText(self.txt_attr_type2)
    self.txt_attr_value1 = GetText(self.txt_attr_value1)
    self.txt_attr_value2 = GetText(self.txt_attr_value2)

    self.txt_colon1 = GetText(self.txt_colon1)
    self.txt_colon2 = GetText(self.txt_colon2)

    --合成解锁等级文本
    self.txt_com_lv = GetText(self.txt_com_lv)
  
    self:AddEvent()

    self:InitMenuList()
end

function StigmataCompoundPanel:AddEvent()
    --监听树形菜单点击事件
    --GlobalEvent.AddEventListenerInTab(CombineEvent.LeftSecondMenuClick .. self.__cname, handler(self, self.HandleLeftSecItemClick), self.events);
    --GlobalEvent.AddEventListenerInTab(CombineEvent.LeftFirstMenuClick .. self.__cname, handler(self, self.HandleLeftFirstClick), self.events);
    self.events[#self.events + 1] = GlobalEvent:AddListener(CombineEvent.LeftSecondMenuClick .. self.__cname, handler(self, self.HandleLeftSecItemClick))
    self.events[#self.events + 1] = GlobalEvent:AddListener(CombineEvent.LeftFirstMenuClick .. self.__cname, handler(self, self.HandleLeftFirstClick))

    
    --监听圣痕背包刷新事件
    self.bagModelEvent = BagModel:GetInstance():AddListener(StigmataEvent.LoadStigmataItems,handler(self,self.LoadItems))

    --合成按钮
    local function call_back()

        local playerLV = RoleInfoModel:GetInstance():GetMainRoleLevel()
        if self.config_tab[self.cur_menu_id][self.cur_submenu_id].com_lv > playerLV then
            Notify.ShowText("Level too low")
            return
        end

        if not self.is_enough then
            Notify.ShowText("Insufficient items")
            return
        end    
        
        if self.target_item_id == 0 then
            logError("合成目标圣痕id不正确")
            return
        end

       StigmataController:GetInstance():RequestSoulCombine(self.target_item_id)
    end
    AddClickEvent(self.btn_compound.gameObject,call_back)



end



--初始化左侧树形菜单数据
function StigmataCompoundPanel:InitMenuList()
    self.left_menu = StigmataCompoundFoldMenu(self.LeftMenu, nil, self, StigmataCompoundOneMenu, StigmataCompoundTwoMenu)
    self.left_menu:SetStickXAxis(8.5)

    local config = Config.db_soul_combine

    --各类数据的初始化
    for i=1,#config do
        self.menu[config[i].type_id] = {config[i].type_id,config[i].name}  

        self.sub_menu[config[i].type_id] = self.sub_menu[config[i].type_id] or {}
        self.sub_menu[config[i].type_id][config[i].sub_type_id] = {config[i].sub_type_id,config[i].sname}
        
        self.config_tab[config[i].type_id] = self.config_tab[config[i].type_id] or {}
        self.config_tab[config[i].type_id][config[i].sub_type_id] = config[i]
 
      
    end

    self.left_menu:SetData(self.menu, self.sub_menu, 1, 2, 2)
    
    --默认选中的菜单项
    if self.target_item_id then
       self:ToTargetItem(self.target_item_id)
    else
        self:ToTargetMenu(1,1)
    end
    
end

function StigmataCompoundPanel:HandleLeftSecItemClick(menuId, subId)
     --print("点击了二级树形菜单："..menuId.."-"..subId)
     self:UpdateRightView(menuId,subId)
end

function StigmataCompoundPanel:HandleLeftFirstClick(index)
    --print("点击了一级树形菜单："..index)
    self:UpdateRightView(index,1)
end   

function StigmataCompoundPanel:UpdateRightView(menuId,subId)

    self.cur_menu_id = menuId
    self.cur_submenu_id = subId

    local data = self.config_tab[menuId][subId]

    self.is_enough = true  

    --消耗材料
    local cost = String2Table(data.cost)
    local costItem_id = cost[1]
    local costNum = cost[2]
    self:UpdateItemUI(costItem_id,self.img_lock_1,self.txt_num_1,1,self.item_content_1,costNum,false)
   
    --消耗圣痕
    self:UpdateItemUI(data.c_item_id1,self.img_lock_2,self.txt_num_2,2,self.item_content_2,1,true)
    self:UpdateItemUI(data.c_item_id2,self.img_lock_3,self.txt_num_3,3,self.item_content_3,1,true)

    --合成结果
    self.target_item = self.target_item or GoodsIconSettorTwo(self.target_item_content)
    self.target_item_id = data.r_item_id
    local param = {}
    local cfg = Config.db_item[data.r_item_id]

    if not cfg then
       logError(data.r_item_id .."不存在item表中")
       return
    end

    param["cfg"] = cfg
    param["bind"] = 2
    param["can_click"] = true
    self.target_item:SetIcon(param)

    --结果圣痕的属性数据
    SetVisible(self.txt_attr_type2,false)
    SetVisible(self.txt_attr_value2,false)
    SetVisible(self.txt_colon2,false)

    local soul_data = Config.db_soul[data.r_item_id]

    local type1 = nil
    local value1 = nil
    local value1Type = nil

    local type2 = nil
    local value2 = nil
    local value2Type = nil
  
    local attr_data = String2Table(soul_data.base)

    --第一条属性
    type1 = StigmataModel:GetInstance():GetAttrNameByIndex(attr_data[1][1])
    value1 = attr_data[1][2]

    --value1Type = attr_data[1][1] > 12
    value1Type = Config.db_attr_type[attr_data[1][1]].type == 2
    if value1Type then
        --处理百分比属性
        value1 = (value1 / 100) .. "%"
    end

    self.txt_attr_type1.text = type1
    self.txt_attr_value1.text = value1

    --第二条属性
    if #attr_data >= 2 then
        SetVisible(self.txt_attr_type2,true)
        SetVisible(self.txt_attr_value2,true)
        SetVisible(self.txt_colon2,true)

        type2 = StigmataModel:GetInstance():GetAttrNameByIndex(attr_data[2][1])
        value2 = attr_data[2][2]

        --value2Type = attr_data[2][1] > 12
        value2Type = Config.db_attr_type[attr_data[2][1]].type == 2
        if value2Type then
            --处理百分比属性
            value2 = (value2 / 100) .. "%"
        end

        self.txt_attr_type2.text = type2
        self.txt_attr_value2.text = value2
    end

    --合成解锁等级
    local playerLV = RoleInfoModel:GetInstance():GetMainRoleLevel()
    if data.com_lv > playerLV then
        SetVisible(self.txt_com_lv,true)
        self.txt_com_lv.text = data.com_lv
    else
        SetVisible(self.txt_com_lv,false)
    end
end



function StigmataCompoundPanel:UpdateItemUI(item_id,img_lock,txt_num,index,item_content,needNum,isStigmata)
    if item_id == 0 then
        --上锁
        SetVisible(img_lock,true)
        SetVisible(item_content,false)
        txt_num.text = "None"
        SetColor(txt_num,11,142,210,255)
        return
    end

    SetVisible(img_lock,false)
    SetVisible(item_content,true)
    self.item_list[index] = self.item_list[index] or GoodsIconSettorTwo(item_content)

    local param = {}
    local cfg = Config.db_item[item_id]
    param["cfg"] = cfg
    param["bind"] = 2
    param["can_click"] = true

    self.item_list[index]:SetIcon(param)

    --获取材料数量
    local item_num = 0

    if isStigmata then
        --圣痕数量
        local souls = self.model:GetPlayerSoul(item_id)
        item_num = #souls
    else
        --货币数量
        item_num =  RoleInfoModel:GetInstance():GetRoleValue(item_id) or 0
    end
    
    if item_num < needNum then
        --数量不足 修改文本颜色为红色
        self.is_enough = false
        SetColor(txt_num,229,16,15,255)
    else
        --数量足够 修改文本颜色为蓝色
        SetColor(txt_num,11,142,210,255)
    end

    txt_num.text = item_num.."/"..needNum
end


function StigmataCompoundPanel:LoadItems()
    self:UpdateRightView(self.cur_menu_id,self.cur_submenu_id)
end

--根据ItemId打开对应菜单
function StigmataCompoundPanel:ToTargetItem(item_id)
    if not self.is_loaded then
        self.target_item_id= item_id
    else
        local tab = Config.db_soul_combine[item_id]
        self:ToTargetMenu(tab.type_id,tab.sub_type_id)
    end
  
end

--打开指定序号的菜单
function StigmataCompoundPanel:ToTargetMenu(menu_id,submenu_id)
    if not menu_id or not submenu_id then
        return
    end

    if self.cur_menu_id == menu_id and self.cur_submenu_id == submenu_id then
        return
    end

    self.left_menu:SetDefaultSelected(menu_id,submenu_id)
    
end
