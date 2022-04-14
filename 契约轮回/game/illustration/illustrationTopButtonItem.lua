--三级菜单项
illustrationTopButtonItem = illustrationTopButtonItem or class("illustrationTopButtonItem", BaseItem)

function illustrationTopButtonItem:ctor(parent_node, layer)
    self.abName = "illustration"
	self.assetName = "illustrationTopButtonItem"
    self.layer = layer

    self.ill_model = illustrationModel:GetInstance()

    self.bag_model = BagModel.GetInstance()
    self.bag_model_events = {}

    self.data = nil

    self.red_dot = nil

    BaseItem.Load(self)
end

function illustrationTopButtonItem:dctor()

    if table.nums(self.bag_model_events) > 0 then
        self.bag_model:RemoveTabListener(self.bag_model_events)
        self.bag_model_events = nil
    end

    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end

end

function illustrationTopButtonItem:LoadCallBack()
    self.nodes = {
        "txt_name",
        "img_bg",
        "img_sel",
    }
    self:GetChildren(self.nodes)
   
    self:InitUI()
    self:AddEvent()
    self:UpdateView()
end

function illustrationTopButtonItem:InitUI(  )
    self.txt_name = GetText(self.txt_name)
end

function illustrationTopButtonItem:AddEvent()

      --图鉴背包信息刷新
      local function call_back()
        self:UpdateReddot()    
      end
      self.bag_model_events[#self.bag_model_events+1] = self.bag_model:AddListener(illustrationEvent.LoadillustrationItems, call_back)

    --点击三级菜单项
    local function call_back()
        self.data.panel:SelectTopBtn(self.data.index)
    end
    AddClickEvent(self.img_bg.gameObject,call_back)
end

--data
--index 索引
--name 名字
--panel 所在面板
--is_default_select 是否为默认选择的三级菜单项
--progress 进度
--first_id 一级菜单id
--second_id 二级菜单id
function illustrationTopButtonItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView() 
    end
end

function illustrationTopButtonItem:UpdateView()
    self.txt_name.text = self.data.name .."(".. self.data.progress.. "%)"

    self:Select(self.data.is_default_select)

    self:UpdateReddot()
end

--刷新进度
function illustrationTopButtonItem:UpdateProgress(progress)

    if self.data.progress == progress then
        return
    end

    self.data.progress = progress
    self.txt_name.text = self.data.name .."(".. progress.. "%)"
end

--选中三级菜单项
function illustrationTopButtonItem:Select(is_select)
    SetVisible(self.img_bg,not is_select)
    SetVisible(self.img_sel,is_select)
end

--刷新红点
function illustrationTopButtonItem:UpdateReddot(  )
    local flag = self.ill_model:CheckReddotByTopBtn(self.data.first_id,self.data.second_id,self.data.index)
    if not flag and not self.red_dot then
        return
    end

    self.red_dot = self.red_dot or RedDot(self.transform)
    self.red_dot:SetRedDotParam(flag)
    SetLocalPositionZ(self.red_dot.transform,0)
    SetAnchoredPosition(self.red_dot.transform,56.8,16.2)
end